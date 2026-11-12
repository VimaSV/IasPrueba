# Prueba Tecnica - Desarrollador de Soporte (IAS SOFTWARE)

Solucion a la prueba tecnica para el cargo de Desarrollador de Soporte.

## Entorno de pruebas

- Motor: Oracle Database 23ai Free.
- Esquema: `PRUEBA_IAS` con datos ficticios. No se usan datos reales de clientes.

## Estructura

| Carpeta | Contenido |
|---|---|
| `A_SQL_PL-SQL/A1_consulta_lenta` | Diagnostico y version optimizada de la consulta lenta |
| `A_SQL_PL-SQL/A2_procedimiento` | Analisis y correccion del procedimiento `cerrar_solicitud` |
| `A_SQL_PL-SQL/A3_diagnostico` | Script de diagnostico y correccion controlada |
| `B_Java/B1_diagnostico` | Analisis y correccion del servicio Java |
| `B_Java/B2_pruebas` | Pseudopruebas documentadas de la correccion Java |

Cada carpeta contiene un archivo `respuesta.md` con el analisis y los archivos `.sql` o el codigo correspondiente.

## Notas

- `A3/diagnostico_correccion.sql`: el `UPDATE` y el `COMMIT` estan limitados al ID 2 con tabla de respaldo. Revisar el contenido antes de ejecutar cualquier sentencia.
- `B_Java`: la correccion es una propuesta de codigo y las pruebas son pseudopruebas documentadas, no ejecutadas. Ver `B2_pruebas/respuesta.md` y `uso_IA.md`.
