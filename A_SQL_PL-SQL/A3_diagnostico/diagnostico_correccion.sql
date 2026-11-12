
-- A3. DIAGNOSTICO Y CORRECCION CONTROLADA

-- 1. DIAGNOSTICO DE SOLICITUDES INCONSISTENTES
-- Identificar solicitudes PROCESADA sin gestion APROBADA.

SELECT
    s.id_solicitud,
    s.documento,
    s.estado,
    s.fecha_actualizacion,
    COUNT(g.id_gestion) AS total_gestiones
FROM solicitud s
LEFT JOIN gestion g
    ON g.id_solicitud = s.id_solicitud
WHERE s.estado = 'PROCESADA'
  AND NOT EXISTS (
      SELECT 1
      FROM gestion ga
      WHERE ga.id_solicitud = s.id_solicitud
        AND ga.resultado = 'APROBADA'
  )
GROUP BY
    s.id_solicitud,
    s.documento,
    s.estado,
    s.fecha_actualizacion
ORDER BY s.id_solicitud;


-- 2. RESPALDO DE LOS REGISTROS CANDIDATOS
-- EJECUTAR UNA SOLA VEZ.

 CREATE TABLE respaldo_a3_solicitud AS
 SELECT
     s.id_solicitud,
     s.estado AS estado_original,
     s.fecha_actualizacion AS fecha_original
 FROM solicitud s
 WHERE s.estado = 'PROCESADA'
   AND NOT EXISTS (
       SELECT 1
       FROM gestion g
       WHERE g.id_solicitud = s.id_solicitud
        AND g.resultado = 'APROBADA'
 );


-- 3. VERIFICAR EL RESPALDO

SELECT COUNT(*) AS total_respaldado
FROM respaldo_a3_solicitud;


-- 4. MOSTRAR LOS REGISTROS QUE SERIAN AFECTADOS
-- Revisar antes de ejecutar cualquier UPDATE.

SELECT
    s.id_solicitud,
    s.estado AS estado_actual,
    r.estado_original,
    COUNT(g.id_gestion) AS total_gestiones
FROM solicitud s
JOIN respaldo_a3_solicitud r
    ON r.id_solicitud = s.id_solicitud
LEFT JOIN gestion g
    ON g.id_solicitud = s.id_solicitud
WHERE s.estado = 'PROCESADA'
  AND s.id_solicitud IN (2)
  AND NOT EXISTS (
      SELECT 1
      FROM gestion ga
      WHERE ga.id_solicitud = s.id_solicitud
        AND ga.resultado = 'APROBADA'
  )
GROUP BY
    s.id_solicitud,
    s.estado,
    r.estado_original;


-- 5. CORRECCION CONTROLADA
-- Prueba sobre una sola solicitud: ID 2.
--
-- SUPUESTO: EN GESTION es el estado propuesto porque
-- sus gestiones asociadas tienen resultado PENDIENTE.


UPDATE solicitud s
SET
    s.estado = 'EN GESTION',
    s.fecha_actualizacion = SYSDATE
WHERE s.id_solicitud IN (2)
  AND s.estado = 'PROCESADA'
  AND EXISTS (
      SELECT 1
      FROM respaldo_a3_solicitud r
      WHERE r.id_solicitud = s.id_solicitud
        AND r.estado_original = 'PROCESADA'
  )
  AND NOT EXISTS (
      SELECT 1
      FROM gestion g
      WHERE g.id_solicitud = s.id_solicitud
        AND g.resultado = 'APROBADA'
  );

-- No confirmar todavia hasta revisar el resultado.


-- 6. VALIDACION POSTERIOR

SELECT
    s.id_solicitud,
    s.estado AS estado_actual,
    r.estado_original,
    s.fecha_actualizacion
FROM solicitud s
JOIN respaldo_a3_solicitud r
    ON r.id_solicitud = s.id_solicitud
WHERE s.id_solicitud = 2;


-- 7. CONFIRMAR LA CORRECCION
-- Ejecutar despues de verificar que el resultado es correcto.
COMMIT;


-- 8. REVERSA / RESTAURACION
-- Ejecutar si se necesita recuperar el estado original.
-- Limitar la restauracion al ID que fue modificado.

 UPDATE solicitud s
 SET
     s.estado = r.estado_original,
     s.fecha_actualizacion = r.fecha_original
 FROM respaldo_a3_solicitud r
 WHERE s.id_solicitud = r.id_solicitud
   AND s.id_solicitud = 2;

-- En Oracle dependiendo la version se utiliza la siguiente sintaxis:

-- UPDATE solicitud s
-- SET
--     estado = (
--         SELECT r.estado_original
--         FROM respaldo_a3_solicitud r
--         WHERE r.id_solicitud = s.id_solicitud
--     ),
--     fecha_actualizacion = (
--         SELECT r.fecha_original
--         FROM respaldo_a3_solicitud r
--         WHERE r.id_solicitud = s.id_solicitud
--     )
-- WHERE s.id_solicitud = 2
--   AND EXISTS (
--       SELECT 1
--       FROM respaldo_a3_solicitud r
--       WHERE r.id_solicitud = s.id_solicitud
--   );

-- COMMIT;
