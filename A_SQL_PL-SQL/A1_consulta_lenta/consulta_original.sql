
-- A1: Consulta original suministrada en la prueba técnica
-- Motor utilizado para las pruebas: Oracle Database 23ai Free
-- Esquema: PRUEBA_IAS

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
WHERE TRUNC(s.fecha_creacion) >= TRUNC(SYSDATE - 30)
  AND UPPER(s.estado) <> 'CERRADA'
  AND s.documento IN (
      SELECT c.documento
      FROM cliente c
      WHERE NVL(c.activo, 'N') = 'S'
  )
ORDER BY s.fecha_creacion DESC;
