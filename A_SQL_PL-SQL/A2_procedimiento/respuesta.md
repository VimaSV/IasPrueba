# A2. Comprension y correccion de PL/SQL
## 1. Analisis del procedimiento original

El procedimiento `cerrar_solicitud` recibe el identificador de una solicitud, verifica si tiene gestiones aprobadas y, si encuentra alguna, actualiza su estado a `PROCESADA` y registra el cambio en la tabla de auditoria.

Se identificaron los siguientes problemas:

1. COMMIT antes de la auditoria: si falla el INSERT de auditoria, la solicitud queda procesada sin que se registre el cambio.
2. WHEN OTHERS THEN NULL: oculta los errores e impide que soporte identifique la causa del problema.
3. Estado anterior fijo: registra siempre `PENDIENTE`, aunque la solicitud pudiera tener otro estado.
4. Falta de validacion de existencia: no informa claramente cuando el identificador no corresponde a una solicitud.
5. Falta de control de solicitudes procesadas: permite intentar cerrar nuevamente una solicitud que ya esta procesada.

## 2. Correccion propuesta

Se implemento una version corregida que incorpora las siguientes validaciones:

- Consulta la solicitud y obtiene su estado actual.
- Utiliza `FOR UPDATE` para bloquear la fila durante el proceso.
- Rechaza solicitudes que ya estan `PROCESADA`.
- Verifica que exista al menos una gestion con resultado `APROBADA`.
- Actualiza el estado de la solicitud.
- Registra en auditoria el estado anterior real y el nuevo estado.
- Ejecuta un unico `COMMIT` despues de completar ambas operaciones.
- Si ocurre un error, ejecuta `ROLLBACK` y permite identificar la causa.

El procedimiento definitivo se encuentra en el archivo `cerrar_solicitud.sql`.

## 3. Manejo de escenarios

Se definieron las siguientes respuestas:

| Escenario | Comportamiento |
|---|---|
| Solicitud inexistente | Genera error ORA-20001 |
| Solicitud ya procesada | Genera error ORA-20002 |
| Sin gestiones aprobadas | Genera error ORA-20003 |
| Solicitud con gestion aprobada | Actualiza el estado y registra la auditoria |

Los errores controlados permiten identificar la situacion sin ocultar informacion util para soporte.

## 4. Pruebas realizadas

Las pruebas se ejecutaron en Oracle, utilizando datos ficticios del esquema `PRUEBA_IAS`.

| Prueba | Registro | Resultado |
|---|---|---|
| Cierre exitoso | ID 4 | Estado actualizado y auditoria registrada |
| Sin gestiones aprobadas | ID 1 | Error ORA-20003 |
| Cierre repetido | ID 4 | Error ORA-20002 |
| Solicitud inexistente | ID 999999 | Error ORA-20001 |
| Fallo simulado antes de auditoria | ID 8 | Error ORA-20010 y actualizacion revertida |

### Validacion transaccional

Para comprobar la consistencia se modifico temporalmente el procedimiento, introduciendo un error controlado despues del UPDATE y antes del INSERT de auditoria.

Al ejecutar la prueba se produjo el error ORA-20010. Posteriormente se verifico que la solicitud 8 permanecia en estado `PENDIENTE`, demostrando que el ROLLBACK revirtio la actualizacion.

Despues se restauro el procedimiento definitivo y se ejecuto nuevamente el cierre. La solicitud quedo `PROCESADA` y se registro su auditoria.

## 5. Conclusion

La correccion evita que una solicitud quede procesada sin su correspondiente registro de auditoria cuando ocurre un error durante el cierre.

Tambien permite controlar los escenarios de ausencia de datos, evitar cierres repetidos y mantener los errores visibles para soporte.

Las pruebas realizadas en el entorno de laboratorio validaron el funcionamiento del procedimiento y la consistencia de las operaciones.