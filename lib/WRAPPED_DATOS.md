# De dónde sale cada dato del Wrapped

Documento orientado a desarrollo y producto: qué significa cada pieza de información, en qué archivo se calcula y, cuando aplica, qué tipo de líneas del export de WhatsApp la alimentan.

**Flujo general:** el usuario sube un `.txt` → `WhatsAppProcessor.processFile()` en `whatsapp_processor.dart` devuelve un `WhatsAppData` → el slideshow (`wrapped_slideshow.dart`) elige flujo **individual** (≤2 participantes) o **grupal** (>2) → opcionalmente se guarda en favoritos como `WrappedModel` (`wrapped_screen.dart`, `services/wrapped_storage.dart`).

**Índice de pantallas (orden, widgets):** `WRAPPED_PANTALLAS.md`  
**Duración por pantalla (individual + grupal pantalla 9):** `wrapped_screen_durations.dart`  
**Tiempo en flujo grupal (pantallas 1–8):** `WRAPPED_GRUPO_DURACION.md`

---

## 1. Formato del archivo de WhatsApp (txt)

Cada **mensaje** debe encajar en uno de estos patrones (línea que empieza el mensaje):

| Plataforma | Formato típico | Regex en código |
|------------|----------------|-----------------|
| Android    | `d/m/aa, hh:mm - Nombre: texto` | `WhatsAppProcessor.androidLineRegex` |
| iOS        | `[d/m/aa, hh:mm] Nombre: texto` | `WhatsAppProcessor.iosLineRegex` |

De ahí se extraen **fecha** (normalizada a `YYYY-MM-DD`), **hora**, **remitente** (`user`) y **texto**. Las líneas siguientes sin cabecera se **concatenan** al mensaje actual (mensajes multilínea).

---

## 2. Nombre del grupo (solo metadato del export, no es un “mensaje” normal)

**Campo en datos:** `WhatsAppData.groupNameFromExport`

**Cálculo:** `WhatsAppProcessor.extractLastGroupNameFromExport(content)` recorre **todas** las líneas del txt (en orden) y guarda el nombre nuevo de la **última** coincidencia. Antes quita marcas bidi (`‎`, RTL/LTR embed, etc.).

**Patrones reconocidos (substring en la línea):**

- Español: `cambió el nombre del grupo de "…" a "…"` (comillas rectas `"`).
- Inglés: `changed the group name from "…" to "…"` (sin distinguir mayúsculas).

**Ejemplo:**  
`18/1/24, 20:37 - Laura cambió el nombre del grupo de "Familia" a "Los tres michinicos 🐱".`  
→ valor guardado: `Los tres michinicos 🐱`.

**Uso en la app:**

- **Favoritos – título** del wrapped **grupal** (ver §6).
- **Primera pantalla grupal:** texto encima de las bolitas de participantes (`wrapped_group_first_screen.dart`).

Si no hay ninguna línea que coincida, el campo queda `null` (el título de favoritos usa entonces el fallback de participantes).

---

## 3. Lista de participantes y relacionados

| Campo | Origen (resumen) |
|-------|-------------------|
| `participants` | Cada vez que se parsea una cabecera de mensaje válida, se hace `participants.add(user)` con el `user` del regex. Al final se **excluyen** quienes figuren como “salidos” → `leftParticipants`. Lista ordenada según aparición en el chat. |
| `leftParticipants` | Líneas de sistema del grupo que indican que alguien **salió** (parsing específico en el bucle principal; ver regex alrededor de “salió” / equivalentes en inglés). |
| `totalParticipantsWhoLeft` | `leftParticipants.length`. |

**Nota:** Los nombres son **tal cual** aparecen en el export (incluidos espacios o caracteres raros si WhatsApp los incluye).

---

## 4. Primer mensaje “visible” para la historia

| Campo | Origen |
|-------|--------|
| `firstMessageDate` | Fecha ISO del **primer día** que tenga al menos un mensaje contado en `dailyMessageCounts` (primera entrada al ordenar fechas; ver construcción de `datesWithMessages`). |
| `firstMessageUser` / `firstMessageText` | Primer mensaje **no omitido** según reglas del procesador (no multimedia omitido, no solo borrado/editado placeholder, etc.). Se asigna la primera vez que un mensaje pasa el filtro `skipMessage`. |

**Pantalla 1 (intro):** frase “todo empezó…”, “Desde entonces…” y días transcurridos se derivan de `firstMessageDate` y `firstMessageText` vía `wrapped_intro_shared.dart` (truncado a 72 caracteres en límite de palabra).

---

## 5. Resto de campos de `WhatsAppData` (agregados en `processFile`)

Todos se actualizan al procesar mensajes que **no** entran en `skipMessage` (multimedia omitido, borrados puros, etc.), salvo donde se indique procesamiento aparte (p. ej. patrones multimedia).

| Campo(s) | Idea de cálculo |
|-----------|-----------------|
| `participantMessageCounts` | +1 por mensaje válido por `user`. |
| `timeRangeCounts` | Franjas: Madrugada 0–5h, Mañana 6–12, Tarde 13–18, Noche 19–23 (hora local del export). |
| `dayOfWeekTimeBandCounts` | Matriz 7×4: día de la semana (lunes=0) × franja. |
| `hourlyMessageCounts` | 24 buckets, por hora del mensaje. |
| `dailyMessageCounts` / `monthlyMessageCounts` | Conteos por día `YYYY-MM-DD` y mes `YYYY-MM`. |
| `dayWithMostMessages`, `dayWithMostMessagesCount` | Día con mayor `dailyMessageCounts`. |
| `monthWithMostMessages`, `monthWithMostMessagesCount` | Mes con mayor `monthlyMessageCounts`. |
| `longestStreak` | Máxima racha de **días consecutivos** con al menos un mensaje (sobre fechas ordenadas de `dailyMessageCounts`). |
| `conversationStarters` | Tras **≥4 h** sin mensajes, el siguiente mensaje suma inicio de conversación a ese usuario; el **primer** mensaje del chat también cuenta. |
| `conversationStartersAfter12h` | Misma lógica que la fila anterior pero con umbral **≥12 h** sin mensajes (pantalla grupal 3, rol «Hola chic@s»). El primer mensaje del chat también suma 1 aquí. |
| `participantWordTotals` | Por mensaje válido (mismos filtros que el conteo de `participantMessageCounts`), suma de **palabras** tras la tokenización de `processWords` (minúsculas, sin puntuación; URLs sustituidas antes de contar). |
| `nightOwlMessageCounts` | Por participante: mensajes cuya **hora local del export** cumple «modo noche»: de **20:00** a **06:00** (incluye 20–23 y 0–5; excluye 6 en punto). |
| `earlyBirdMessageCounts` | Por participante: mensajes entre **06:00** y **12:00** (incluye 6, excluye 12 en punto), hora local del export. |
| `averageResponseTimes` | Por destinatario: media de minutos entre su mensaje y el mensaje previo de **otro** usuario (misma hebra, sin el gap de 4 h que resetea conversación). Formato `M:SS` o `H:MM:SS`. |
| `quickResponseCounts` | Respuestas del otro usuario en **< 5 minutos**. |
| `mostConsecutiveMessages` / `User` / `Date` | Mayor racha de mensajes **seguidos del mismo autor** (contiguos en el txt). |
| `emojiStatsByParticipant` | Conteo de emojis por usuario (lógica de normalización en el procesador). |
| `wordStatsByYear`, `totalUniqueWords`, `topWordByLengthByParticipant`, `topWordByLength` | Tokenización de palabras, filtros de longitud (p. ej. pantalla de palabras usa longitudes 4–14). |
| `totalQuestions` | Conteo de grupos `?` / `¿` en texto (`countQuestions`). |
| `deletedMessagesByParticipant`, `editedMessagesByParticipant` | Patrones tipo “Eliminaste…”, “Se eliminó…”, “This message was deleted”, `<Se editó este mensaje.>`, etc. |
| `multimediaByParticipant` | `<Multimedia omitido>` / `<Media omitted>`. |
| `locationsByParticipant` | Texto con ubicación y enlaces maps. |
| `contactsByParticipant` | `.vcf` con adjunto. |
| `oneTimePhotosByParticipant` | Heurística sobre textos `null` / vacíos en ciertos contextos (ver código). |
| `sharedUrlsByParticipant` | URLs `http(s)`, `www.`, dominios tipo `marca.com` (`countUrlsInText`). |

Para el detalle exacto de cada rama, el archivo fuente es **`whatsapp_processor.dart`** (un solo paso lineal sobre el txt).

---

## 6. Título en **Favoritos** (`WrappedModel.title`)

Se asigna en `wrapped_screen.dart` al guardar:

| Condición | Título |
|-----------|--------|
| **Grupo** (`participants.length > 2`) **y** `groupNameFromExport` no vacío | Texto de `groupNameFromExport` (último cambio de nombre del grupo, §2). |
| En cualquier otro caso | `Participants` concatenados: cada nombre **máximo 8 caracteres**, unidos por ` - `. Si no hay nombres: `WHALYZE <año actual>`. |

La pestaña **Individual / Grupo** en `favorites_screen.dart` usa la misma regla de “grupo”: `participants.length > 2`. El **título mostrado** es siempre `wrapped.title` guardado (no se recalcula del `data` al listar).

---

## 7. Individual vs grupal en el slideshow

**Regla:** `wrapped_slideshow.dart` → `_isGroupChat` es `true` si `widget.data.participants.length > 2`.

- **Individual:** pantallas `WrappedFirstScreen` … `WrappedWordsScreen` + `WrappedFinalScreen`.
- **Grupal:** `WrappedGroupFirstScreen`, placeholders `WrappedGroupSecondScreen` … `WrappedGroupEighthScreen`, y cierre `WrappedGroupNinthScreen` (delega en `WrappedFinalScreen`).

Las **bolitas** de color en varias pantallas usan `getParticipantColor` / `getParticipantInitials` en `utils/participant_utils.dart` (color estable por hash del nombre).

---

## 8. Qué datos usa cada pantalla (flujo individual)

Referencias a `widget.data.*` en código:

| Índice | Pantalla | Campos principales |
|--------|----------|--------------------|
| 0 | `wrapped_first_screen.dart` | `firstMessage*`, `participants`, textos derivados `wrapped_intro_shared` |
| 1 | `wrapped_second_screen.dart` | `participantMessageCounts`, `dayWithMostMessages*`, `monthWithMostMessages*` |
| 2 | `wrapped_third_screen.dart` | `emojiStatsByParticipant`, `participants` |
| 3 | `wrapped_fifth_screen.dart` | `conversationStarters`, `averageResponseTimes`, `quickResponseCounts`, `participants` |
| 4 | `wrapped_sixth_screen.dart` | `dayOfWeekTimeBandCounts`, `hourlyMessageCounts` |
| 5 | `wrapped_seventh_screen.dart` | `dailyMessageCounts`, `mostConsecutive*`, `totalQuestions`, `multimediaByParticipant` (resumen) |
| 6 | `wrapped_eighth_screen.dart` | `multimediaByParticipant`, `oneTimePhotosByParticipant`, `sharedUrlsByParticipant`, `deletedMessagesByParticipant`, `participants` |
| 7 | `wrapped_words_screen.dart` | `topWordByLength` |
| 8 | `wrapped_final_screen.dart` | (UI de cierre; no depende de `WhatsAppData`) |

**Flujo grupal (pantallas 2–8):** pantalla 1 usa `groupNameFromExport` (§2). Pantalla 2: ranking de mensajes (`participantMessageCounts`). Pantallas 4–8: aún placeholders. Pantalla 3: roles (ver §8b).

---

## 8b. Pantalla grupal 3 — «Asi se reparten los roles»

**Widgets:** `wrapped_group_third_screen.dart` (UI y animación escalonada cada 2 s). **Cálculo de ganadores:** `buildGroupRoleDisplays()` en `wrapped_group_roles.dart`.

En pantalla solo se muestran **frases cortas** (p. ej. «Más mensajes por la noche»). Las reglas del tipo «no puede ser el MVP» son **solo de cálculo** (exclusión del ganador del MVP en búho y madrugador), no texto de la tarjeta.

Los nombres salen del **orden estable** `data.participants` (en empates, antes en la lista del export gana).

| Rol (emoji) | Ganador(a) | Datos y reglas |
|-------------|------------|----------------|
| ⭐ MVP | Mayor `participantMessageCounts`. | Mensajes válidos (no omitidos como multimedia/borrado, etc.). |
| 🦉 El búho | Mayor conteo nocturno **excluyendo al MVP** (empate → orden de `participants`). | Noche = mensajes con hora local **≥20 o &lt;6** (`nightOwlMessageCounts` al procesar el txt). |
| 🥷 Asesino silencioso | Menor **media palabras/mensaje** si existen `participantWordTotals` por persona; si esos mapas vienen vacíos (p. ej. favorito muy antiguo), **proxy:** quien menos mensajes tiene entre los que al menos escribieron uno. | Palabras: misma tokenización que al rellenar `participantWordTotals` en `processWords`. |
| 🌅 Madrugador/a | Mayor conteo matinal **excluyendo al MVP**. | Mañana = hora local **≥6 y &lt;12** (`earlyBirdMessageCounts`). |
| 🎙️ La voz del grupo | Mayor `participantWordTotals`. | Suma de palabras (mensajes válidos). |
| 💬 Hola chic@s | Mayor `conversationStartersAfter12h`. | Tras **≥12 h** sin mensajes, el siguiente autor suma 1; el primer mensaje del chat también cuenta. |

**Favoritos sin conteos por persona** (`nightOwlMessageCounts`, `earlyBirdMessageCounts`, etc. vacíos): se **reparte** el total nocturno/matinal que sí viene en `hourlyMessageCounts` entre participantes en proporción a `participantMessageCounts` (enteros con suma exacta al total horario). Para «Hola chic@s», si no hay datos de 12 h se usa como respaldo `conversationStarters` (umbral 4 h del procesador). Con reimportación del txt los mapas por persona son los definitivos.

Si aun así no hay candidato (p. ej. nadie fuera del MVP con mensajes nocturnos repartidos en 0), el nombre se muestra como «—».

---
</think>


<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>
Shell

## 9. Persistencia (`WrappedModel`)

Al guardar favoritos:

- `data`: JSON completo de `WhatsAppData.toJson()` (incluye `groupNameFromExport` si existía al importar).
- `participants`: copia de la lista en el modelo (redundante con `data` pero usada para pestañas y UI rápida).
- `totalLines`: número de líneas del fichero original (`fileContent.split('\n').length`).

Los wrapped viejos sin `groupNameFromExport` en el JSON mostrarán título por participantes hasta que se **vuelva a importar** el chat.

---

## 10. Cómo mantener este documento

- Si cambia un regex o un campo de `WhatsAppData`, actualizar **este archivo** y el comentario junto al campo en `whatsapp_processor.dart` si hace falta.
- Si se añade una pantalla nueva o se conectan datos en los placeholders grupales, actualizar la tabla del §8.
