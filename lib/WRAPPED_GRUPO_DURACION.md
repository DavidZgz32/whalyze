# Tiempo de cada pantalla en el Wrapped **grupal**

## Resumen

En el flujo **individual**, la barra superior usa una duración fija por índice definida en `wrapped_screen_durations.dart`.

En el flujo **grupal** (`participants.length > 2`), las pantallas **0 a 7** tienen **duraciones variables** según cuántos participantes haya y cuántas animaciones se reproduzcan. No tiene sentido un único tiempo fijo para todos los grupos.

## Comportamiento (implementado en `wrapped_slideshow.dart`)

1. Al entrar en la diapositiva grupal **i** (con **i** entre 0 y 7), el **segmento** actual de la barra superior se **rellena de forma lineal** (estilo Instagram), en un tiempo total `D_estimado + 1 s`, donde `D_estimado` depende del índice y del tipo de pantalla (ver `_groupContentEstimateMs` en `wrapped_slideshow.dart`).
2. Mientras las animaciones de contenido pueden seguir, la barra **no supera** la fracción `D_estimado / (D_estimado + 1 s)`: si llega ahí antes de que acabe el contenido, **espera** (sin bucles ni indeterminado).
3. Cuando la pantalla considera que **ha terminado la última animación**, llama a  
   `onGroupScreenAnimationsComplete(índice)` (mismo índice que el slideshow).
4. Entonces ya puede completar el tramo hasta el 100 % del segmento; el último tramo corresponde al **margen** de `_groupPostAnimationHoldMs` (1 s) dentro de la misma línea de tiempo (estilo “historia” que termina y pasa a la siguiente).
5. Al completarse el segmento al 100 %, el auto-avance es el mismo que en el flujo individual.

Si el usuario **pausa** antes de que termine el punto 3, las animaciones de la pantalla se detienen; al reanudar, continúan hasta el final y luego ocurre 4–5.

Si el usuario **pausa** durante el segundo de margen del punto 4, la barra queda parada; al reanudar, sigue desde el mismo punto.

## Pantalla 8 (cierre)

La última pantalla (índice 8), grupal o individual, sigue usando **`WrappedScreenDurations.pantalla8`**: no hay señal de “animaciones terminadas” específica; el tiempo es el configurado en `wrapped_screen_durations.dart`.

## Constante

Duración del margen post-animación (grupal 0–7):  
`wrapped_slideshow.dart` → `_groupPostAnimationHoldMs` (1000 ms).

## Quién avisa “animaciones listas”

| Índice | Widget | Momento del aviso |
|--------|--------|-------------------|
| 0 | `WrappedGroupFirstScreen` | Fin de la secuencia async de título, bolitas, textos. |
| 1 | `WrappedGroupSecondScreen` | Tras el último fade (filas escalonadas + pie del carro si existe). |
| 2 | `WrappedGroupThirdScreen` | Tras el último fade de la última tarjeta de rol (5×2 s de escalón + 400 ms de fade + 2s extra). |
| 3 | `WrappedGroupFourthScreen` | Tras el último fade de la última tarjeta de rol (4×2 s de escalón + 400 ms de fade + 2s extra). |
| 4–7 | `WrappedGroupPlaceholderScreen` | Un frame después del primer layout (sin animaciones). |

Los índices deben coincidir con `_currentScreen` en el slideshow; si no, el aviso se ignora (p. ej. tras saltar de pantalla).
