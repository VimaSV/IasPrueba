CREATE OR REPLACE EDITIONABLE PROCEDURE "PRUEBA_IAS"."CERRAR_SOLICITUD" (p_id IN NUMBER) AS
    v_estado_actual solicitud.estado%TYPE;
    v_aprobadas NUMBER;
BEGIN
    -- Verificar que la solicitud exista y obtener su estado
    SELECT estado
    INTO v_estado_actual
    FROM solicitud
    WHERE id_solicitud = p_id
    FOR UPDATE;

    -- Evitar procesar solicitudes ya procesadas
    IF v_estado_actual = 'PROCESADA' THEN
        RAISE_APPLICATION_ERROR(-20002, 'La solicitud ya esta PROCESADA');
    END IF;

    -- Verificar que exista al menos una gestion aprobada
    SELECT COUNT(*)
    INTO v_aprobadas
    FROM gestion
    WHERE id_solicitud = p_id
      AND resultado = 'APROBADA';

    IF v_aprobadas = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'La solicitud no tiene gestiones aprobadas');
    END IF;

    -- Actualizar la solicitud
    UPDATE solicitud
    SET estado = 'PROCESADA',
        fecha_actualizacion = SYSDATE
    WHERE id_solicitud = p_id;

    -- Registrar la auditoria
    INSERT INTO auditoria_solicitud (
        id,
        id_solicitud,
        estado_anterior,
        estado_nuevo,
        fecha,
        detalle
    ) VALUES (
        seq_auditoria.NEXTVAL,
        p_id,
        v_estado_actual,
        'PROCESADA',
        SYSDATE,
        'Cierre automatico'
    );

    -- Confirmar ambas operaciones
    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'La solicitud no existe');

    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;