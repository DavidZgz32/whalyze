# Índice de pantallas del Wrapped

**De dónde sale cada dato (export, favoritos, campos del modelo):** ver [`WRAPPED_DATOS.md`](WRAPPED_DATOS.md).

**Tipo:** Chat **1 a 1** (≤2 participantes) o **grupal** (>2 participantes); el slideshow elige el flujo en `wrapped_slideshow.dart`.

Orden y contenido de cada pantalla. El **índice** es el que se usa en código (`_currentScreen`, `getDurationMs(screenIndex)`).

| Índice | Pantalla (usuario) | Título / contenido                    | Widget / archivo                |
|--------|--------------------|---------------------------------------|----------------------------------|
| 0      | 1                  | Bienvenid@ a tu Whatsapp Wrapped      | `WrappedFirstScreen`             |
| 1      | 2                  | Vamos a analizar vuestros mensajes   | `WrappedSecondScreen`            |
| 2      | 3                  | Emojis más usados                     | `WrappedThirdScreen`             |
| 3      | 4                  | ¿Quién mueve el chat?                 | `WrappedFifthScreen`             |
| 4      | 5                  | Horarios de mensajes                  | `WrappedSixthScreen`             |
| 5      | 6                  | Hitos del chat                        | `WrappedSeventhScreen`           |
| 6      | 7                  | Media                                 | `WrappedEighthScreen`            |
| 7      | 8                  | Palabras más usadas                   | `WrappedWordsScreen`               |
| 8      | 9                  | Botón de volver (última pantalla)    | `WrappedPlaceholderScreen` (título) |

Total: **9 pantallas**. Las duraciones por pantalla están en `wrapped_screen_durations.dart`.

---

## Comportamiento de pausa

**En todas las pantallas del wrapped, siempre:** al pulsar *Pausar*, las animaciones de esa pantalla deben pausarse (y al pulsar *Play*, reanudarse). Cada pantalla con animaciones debe implementar `pauseAnimations()` y `resumeAnimations()` y el slideshow (`wrapped_slideshow.dart`) debe invocarlos según la pantalla actual.
