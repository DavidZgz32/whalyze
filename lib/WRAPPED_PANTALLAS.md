# Índice de pantallas del Wrapped (chat de 2 personas)

**Tipo:** Chat entre 2 personas (1 a 1). Las pantallas para chats grupales serán distintas en el futuro.

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
| 7      | 8                  | Palabras más usadas                   | `WrappedPlaceholderScreen` (título) |
| 8      | 9                  | Botón de volver (última pantalla)    | `WrappedPlaceholderScreen` (título) |

Total: **9 pantallas**. Las duraciones por pantalla están en `wrapped_screen_durations.dart`.
