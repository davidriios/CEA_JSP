CREATE OR REPLACE TRIGGER trigger trg_oset_orden_med 
after INSERT or DELETE  ON TBL_EXP_OSET_ACTIVOXMRN REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW

BEGIN
    BEGIN
        IF INSERTING THEN

            INSERT INTO TBL_OSET_ORDEN_MEDICAS (
                PAC_ID, ADMISION, GENERAR_OM, OSET_HEADER1, OSET_HEADER2, OSET_DET_ID, DISP_ORDER,DISPLAY_TEXT,
                REF_NAME, OM_TYPE, REF_CODE, ADD_INFO_TEXT, CREATED_BY, CREATED_DATE,CAN_CHANGE,
                concentracion, FRECUENCIA, DOSIS, cantidad, forma, via ,prioridad, centro_servicio, OBSERVACION, motivo
            )
            select :NEW.PAC_ID, :NEW.ADMISION, 'P', OSET_HEADER1, OSET_HEADER2, OSET_DET_ID, DISP_ORDER,DISPLAY_TEXT,
            REF_NAME, OM_TYPE, REF_CODE, ADD_INFO_TEXT, :NEW.CREATED_BY, SYSDATE, CAN_CHANGE,
            concentracion, FRECUENCIA, DOSIS, cantidad, forma, via ,prioridad, centro_servicio, OBSERVACION, motivo
            from tbl_oset_header2_det
            WHERE OSET_HEADER1 = :NEW.OSET_ID;

        END IF;

        IF DELETING THEN
            DELETE FROM TBL_OSET_ORDEN_MEDICAS WHERE PAC_ID = :OLD.PAC_ID AND ADMISION = :OLD.ADMISION AND OSET_HEADER1 = :OLD.OSET_ID;
        END IF;

    END;
END; 