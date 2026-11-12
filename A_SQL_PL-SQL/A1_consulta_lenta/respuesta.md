# A1. Diagnóstico de consulta lenta

## 1. Problemas identificados

Se identificaron cuatro aspectos que pueden afectar el rendimiento:

1. **TRUNC(fecha_creacion):** aplicar una función sobre la columna puede impedir el aprovechamiento directo del índice existente sobre la fecha.
2. **UPPER(estado):** transforma la columna durante el filtrado y puede dificultar el uso del índice convencional.
3. **NVL(activo, 'N'):** es innecesario para comprobar si el cliente está activo, ya que los valores nulos tampoco cumplen `activo = 'S'`.
4. **Subconsulta correlacionada:** obtener `MAX(fecha_gestion)` para cada solicitud puede generar un costo importante con los 14 millones de registros de gestión de producción.

También deben considerarse el ordenamiento y las operaciones de combinación entre tablas.

## 2. Consulta optimizada propuesta

```sql
SELECT
    s.id_solicitud,
    s.documento,
    s.estado,
    s.fecha_creacion,
    (
        SELECT MAX(g.fecha_gestion)
        FROM gestion g
        WHERE g.id_solicitud = s.id_solicitud
    ) AS ultima_gestion
FROM solicitud s
WHERE s.fecha_creacion >= TRUNC(SYSDATE) - 30
  AND s.estado <> 'CERRADA'
  AND EXISTS (
      SELECT 1
      FROM cliente c
      WHERE c.documento = s.documento
        AND c.activo = 'S'
  )
ORDER BY s.fecha_creacion DESC;
```

**Cambios realizados:**

- Se elimina `TRUNC()` de la columna de fecha.
- Se elimina `UPPER()` bajo el supuesto de que los estados están normalizados en mayúsculas.
- Se reemplaza `NVL()` por una comparación directa.
- Se utiliza `EXISTS` para comprobar la existencia de un cliente activo.

Se conserva la subconsulta de última gestión para mantener la lógica original.

## 3. Índice compuesto evaluado

Se creó el siguiente índice en el entorno de laboratorio:

```sql
CREATE INDEX IDX_GESTION_SOL_FECHA
ON GESTION(ID_SOLICITUD, FECHA_GESTION);
```

Se eligió porque la consulta relaciona GESTION mediante `ID_SOLICITUD` y obtiene la fecha máxima mediante `FECHA_GESTION`.

**Resultados de los planes de ejecución:**

| Escenario | Costo estimado |
|---|---:|
| Consulta original, sin índice compuesto | 147 |
| Consulta original, con índice compuesto | 109 |
| Consulta optimizada, con índice compuesto | 110 |

Con el índice compuesto, Oracle pasó de un acceso completo a la tabla GESTION a utilizar `INDEX FAST FULL SCAN`.

La consulta original y la optimizada devolvieron 990 registros en las pruebas realizadas.

Los resultados muestran una reducción del costo estimado después de incorporar el índice, pero no demuestran una ventaja adicional de la reescritura SQL frente a la consulta original.

**Riesgos del índice:** requiere almacenamiento adicional y aumenta el trabajo de mantenimiento durante inserciones, actualizaciones y eliminaciones. Por ello, su implementación en producción debe justificarse con pruebas de rendimiento y análisis del impacto sobre las operaciones de escritura.

## 4. Validaciones antes de producción

Antes de implementar los cambios se recomienda:

- Revisar el plan de ejecución real y no solamente el costo estimado.
- Verificar estadísticas y cardinalidades de las tablas.
- Comparar tiempos de ejecución y lecturas lógicas.
- Probar con volúmenes representativos de producción.
- Evaluar el impacto del índice sobre las operaciones de escritura.
- Confirmar que los estados estén normalizados antes de eliminar `UPPER()`.

## Conclusión

La consulta propuesta simplifica los filtros y facilita el posible aprovechamiento de los índices existentes. El índice compuesto evaluado modificó el plan de ejecución y redujo el costo estimado de 147 a 109 en la consulta original.

Sin embargo, las pruebas de laboratorio no permiten garantizar una mejora equivalente en producción. Se recomienda validar los cambios con datos reales y mediciones controladas antes de implementarlos.