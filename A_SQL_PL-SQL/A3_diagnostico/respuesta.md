# A3. Diagnostico y correccion controlada

## 1. Diagnostico

Se identificaron 5.000 solicitudes en estado `PROCESADA` que no tienen ninguna gestion con resultado `APROBADA`.

Adicionalmente, se encontraron 7.500 gestiones asociadas con resultado `PENDIENTE` y ninguna de las solicitudes candidatas tiene registros de auditoria.

## 2. Criterio de seleccion

Se consideran candidatas las solicitudes que cumplen estas condiciones:

- Su estado actual es `PROCESADA`.
- No tienen ninguna gestion `APROBADA`.

No se asume que todas sean errores confirmados, ya que no existe auditoria que permita determinar su estado anterior.

## 3. Correccion controlada

Se creo una tabla de respaldo con el estado y la fecha de actualizacion originales.

Se preparo una actualizacion de prueba sobre una sola solicitud, utilizando `EN GESTION` como estado propuesto, considerando que sus gestiones estan `PENDIENTE`.

Este estado es un supuesto para el entorno de pruebas

## 4. Validacion y reversa

Se verifican los registros antes y despues de la actualizacion.

La tabla de respaldo permite recuperar el estado y la fecha originales si se requiere revertir el cambio.

La correccion se limita a los identificadores previamente revisados y autorizados, evitando actualizaciones masivas sin validacion.

## Conclusion

Se preparo un procedimiento de diagnostico y correccion controlada que permite identificar posibles inconsistencias, conservar los datos originales, verificar los cambios y disponer de una estrategia de restauracion.
