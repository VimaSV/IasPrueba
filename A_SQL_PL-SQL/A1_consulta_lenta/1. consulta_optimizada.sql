
-- A1: Consulta optimizada propuesta
-- Se eliminan funciones sobre columnas filtradas.
-- Se utiliza EXISTS para validar clientes activos.

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

-- Índice compuesto evaluado en laboratorio:
-- CREATE INDEX IDX_GESTION_SOL_FECHA
-- ON GESTION(ID_SOLICITUD, FECHA_GESTION);
