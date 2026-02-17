# Formato de exportación de WhatsApp (TXT)

Documentación del formato del archivo de texto que exporta WhatsApp y cómo se extraen los atributos.

---

## Android

### Formato de los mensajes

```
D/M/AA, H:MM - Usuario: texto del mensaje
D/M/AAAA, H:MM:SS - Usuario: texto del mensaje
```

**Ejemplos:**
```
13/9/23, 20:30 - Pepito: Hola, ¿qué tal?
17/2/26, 20:37 - David: 
1/12/24, 9:15:32 - María: <Multimedia omitido>
```

**Patrón regex usado:**
```
^(\d{1,2})/(\d{1,2})/(\d{2,4}),\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s[-–]\s([^:]+):\s?([\s\S]*)$
```

| Parte | Significado |
|-------|-------------|
| `D/M/AA` o `D/M/AAAA` | Día, mes y año (2 o 4 dígitos para el año) |
| `H:MM` o `H:MM:SS` | Hora, minutos y opcionalmente segundos |
| ` - ` | Espacio, guión (o guión largo –), espacio |
| `Usuario:` | Nombre del participante seguido de dos puntos |
| `texto` | Contenido del mensaje (puede ser multilínea si las siguientes líneas no empiezan con fecha) |

---

## iOS

### Formato de los mensajes

```
[D/M/AA, H:MM] Usuario: texto del mensaje
[D/M/AAAA, H:MM:SS] Usuario: texto del mensaje
```

**Ejemplos:**
```
[13/9/23, 20:30] Pepito: Hola, ¿qué tal?
[17/2/26, 20:37] David: 
[1/12/24, 9:15:32] María: <Multimedia omitido>
```

**Patrón regex usado:**
```
^\[(\d{1,2})/(\d{1,2})/(\d{2,4}),\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\]\s([^:]+):\s?([\s\S]*)$
```

| Parte | Significado |
|-------|-------------|
| `[ ... ]` | Fecha y hora entre corchetes |
| Resto | Igual que en Android (Usuario: texto) |

**Diferencia principal:** En iOS la fecha y hora van entre corchetes `[...]` y no hay guión `-` entre el timestamp y el nombre.

---

## Casos especiales de mensajes

### Mensaje vacío = Foto temporal (1 foto)

Cuando el mensaje está vacío (o contiene solo `null`), representa una **foto temporal** (view once):

```
17/2/26, 20:37 - David: 
17/2/26, 20:37 - David: null
```

Se cuenta en `oneTimePhotosByParticipant`.

---

### &lt;Multimedia omitido&gt; = Archivo o multimedia

Cuando el texto es exactamente `<Multimedia omitido>` (español) o `<Media omitted>` (inglés), representa un **archivo adjunto** (imagen, vídeo, audio, documento, etc.):

```
17/2/26, 20:37 - David: <Multimedia omitido>
17/2/26, 20:37 - María: <Media omitted>
```

Se cuenta en `multimediaByParticipant`.

---

### Otros patrones especiales

| Texto | Significado | Atributo |
|-------|-------------|----------|
| `Eliminaste este mensaje` / `You deleted this message` | Mensaje eliminado por el subidor del chat | `deletedMessagesByParticipant` |
| `Se eliminó este mensaje` / `This message was deleted` | Mensaje eliminado por otro participante | `deletedMessagesByParticipant` |
| `<Se editó este mensaje.>` / `<This message was edited>` | Mensaje editado | `editedMessagesByParticipant` |
| Ubicación con `maps.google.com`, `goo.gl/maps`, etc. | Compartió ubicación | `locationsByParticipant` |
| `.vcf` con `(archivo adjunto)` | Compartió contacto | `contactsByParticipant` |

---

## Mensajes multilínea

Si una línea **no** empieza con el patrón de fecha (Android o iOS), se considera **continuación** del mensaje anterior:

```
13/9/23, 20:30 - Pepito: Hola
esto es la segunda línea
y la tercera
14/9/23, 9:00 - María: Nuevo mensaje
```

---

## Atributos extraídos

### Información básica
- **participants**: Lista de participantes (usuarios que han enviado mensajes)
- **leftParticipants**: Participantes que salieron del grupo
- **firstMessageDate**, **firstMessageUser**, **firstMessageText**: Primer mensaje válido

### Estadísticas de mensajes
- **participantMessageCounts**: Mensajes por participante
- **dailyMessageCounts**, **monthlyMessageCounts**: Mensajes por día/mes
- **timeRangeCounts**: Madrugada (0-6h), Mañana (6-13h), Tarde (13-19h), Noche (19-24h)
- **hourlyMessageCounts**: Mensajes por hora (0-23)

### Día y mes más activos
- **dayWithMostMessages**, **monthWithMostMessages**
- **longestStreak**: Racha más larga de días consecutivos con mensajes

---

## Cómo se calcula "Quién inicia más conversaciones"

Se considera que un usuario **inicia una conversación** cuando:

1. **Es el primer mensaje del chat** → cuenta como inicio para ese usuario.

2. **Han pasado 4 o más horas** desde el último mensaje de cualquiera. El siguiente mensaje cuenta como inicio para el usuario que lo envía.

**Ejemplo:**
- 10:00 - Ana: Hola  
- 10:05 - Pedro: Qué tal  
- 10:10 - Ana: Bien  
- **15:00** - Pedro: ¿Has visto la peli? ← **4+ horas después → Pedro inicia conversación**
- 15:02 - Ana: Sí

Aquí Ana habría iniciado 1 vez (el primer mensaje) y Pedro 1 vez (tras el gap de 4 horas).

El valor por defecto del gap es **4 horas** (`conversationGapHours = 4`).

---

## Cómo se calcula "Tiempo medio de respuesta"

El tiempo de respuesta se mide **solo cuando un usuario responde a otro** (cambio de emisor):

1. Se toma el **timestamp** del mensaje anterior y del mensaje actual.
2. Se calcula la **diferencia en minutos** entre ambos.
3. Solo se cuenta si el emisor del mensaje actual **es distinto** al del mensaje anterior (es una respuesta, no mensajes consecutivos del mismo usuario).
4. No se cuenta si han pasado **4 o más horas** (en ese caso se considera nuevo inicio de conversación, no respuesta).
5. Se hace la **media** de todos esos tiempos para cada participante.
6. Se muestra en formato `MM:SS` o `HH:MM:SS` según la duración.

**Ejemplo:**
- 10:00:00 - Ana: Hola  
- 10:05:30 - Pedro: Hola (respuesta en 5,5 min)  
- 10:06:00 - Ana: ¿Qué tal? (respuesta en 0,5 min)  
- 10:10:00 - Pedro: Bien (respuesta en 4 min)

Tiempo medio de Ana: 0,5 min → "0:30"  
Tiempo medio de Pedro: (5,5 + 4) / 2 = 4,75 min → "4:45"

### Respuestas rápidas (< 5 minutos)

Los mensajes enviados **menos de 5 minutos** después del mensaje anterior (siendo usuario distinto) se cuentan en **quickResponseCounts** ("Respuestas rápidas").
