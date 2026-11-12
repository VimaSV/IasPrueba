# Registro de uso de herramientas de IA

Conforme a la seccion 7 del enunciado: se utilizaron herramientas de IA de forma transversal en los cinco bloques de la prueba, principalmente para apoyar la redaccion, la estructuracion de las respuestas y la revision del codigo. Todo el material fue revisado, verificado y ajustado antes de incorporarlo, contrastandolo con los requisitos del PDF y, cuando fue posible, con ejecucion en el entorno de laboratorio.

## Uso por bloque

| Bloque | Uso de la IA | Resultado obtenido | Verificacion y ajustes |
|---|---|---|---|
| A1 | Apoyo en el diagnostico de la consulta y en la redaccion de la respuesta | `respuesta.md`, `consulta_original.sql` y `1. consulta_optimizada.sql` | Planes y costos (147 / 109 / 110) medidos en Oracle 23ai Free. Se verifico que la reescritura SQL no mostraba ventaja adicional frente al indice y se documento esa limitacion en lugar de afirmar mejoras no demostradas |
| A2 | Apoyo en el analisis de riesgos del procedimiento y en la redaccion de la correccion | `cerrar_solicitud.sql` corregido y `respuesta.md` | Pruebas ejecutadas en laboratorio (cierre exitoso, errores controlados y prueba de rollback simulada), documentadas en `respuesta.md` |
| A3 | Apoyo en la estructura del script y en la redaccion de los supuestos | `diagnostico_correccion.sql` y `respuesta.md` | Diagnostico y conteos verificados en laboratorio. La correccion se limito al ID 2 con tabla de respaldo y el estado `EN GESTION` queda documentado como supuesto |
| B1 | Apoyo en el analisis del fragmento Java y en la redaccion de la correccion | `respuesta.md` con el metodo corregido | Codigo revisado manualmente contra el error reportado. No se ejecuto al no disponer del proyecto completo |
| B2 | Apoyo en la definicion de los casos de prueba | `respuesta.md` con pseudopruebas documentadas | Casos contrastados con el comportamiento del codigo corregido. No se ejecutaron como pruebas JUnit |

## Ejecutado frente a propuesto

| Bloque | Ejecutado en laboratorio | Propuesto o documentado (no ejecutado) |
|---|---|---|
| A1 | Medicion de planes y costos | Reescritura SQL y nuevo indice (propuesta pendiente de validar en produccion) |
| A2 | Pruebas del procedimiento corregido | Ninguna alternativa funcional adicional |
| A3 | Diagnostico de inconsistencias | Correccion (ID 2) y reversa, dejadas preparadas para ejecucion controlada |
| B1 | No ejecutado | Codigo corregido propuesto |
| B2 | No ejecutado (pseudopruebas) | Casos verificables documentados |

## Consideraciones

- No se copio informacion sensible en prompts.
- Las afirmaciones de resultados corresponden a lo documentado en cada `respuesta.md`; lo no ejecutado esta identificado explicitamente como propuesta o pseudoprueba.
