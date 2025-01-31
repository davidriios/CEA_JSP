CREATE TABLE TBL_OSET_ORDEN_MEDICAS
(
    PAC_ID            NUMBER
        NOT NULL ENABLE,
    ADMISION          NUMBER
        NOT NULL ENABLE,
    GENERAR_OM        CHAR(1 BYTE)
        NOT NULL ENABLE,
    OM_REFID1         NUMBER,
    OM_REFID2         NUMBER,
    OM_GENRATE_DATE   DATE,
    OM_APPROVE_DATE   DATE,
    OSET_HEADER1      NUMBER
        NOT NULL ENABLE,
    OSET_HEADER2      NUMBER
        NOT NULL ENABLE,
    OSET_DET_ID       NUMBER
        NOT NULL ENABLE,
    DISP_ORDER        NUMBER
        NOT NULL ENABLE,
    DISPLAY_TEXT      VARCHAR2(500 BYTE)
        NOT NULL ENABLE,
    REF_NAME          VARCHAR2(500 BYTE),
    OM_TYPE           NUMBER,
    REF_CODE          VARCHAR2(30 BYTE),
    ADD_INFO_TEXT     VARCHAR2(1024 BYTE) DEFAULT '-',
    CREATED_BY        VARCHAR2(30 BYTE)
        NOT NULL ENABLE,
    MODIFIED_BY       VARCHAR2(30 BYTE),
    CREATED_DATE      DATE DEFAULT SYSDATE
        NOT NULL ENABLE,
    MODIFIED_DATE     DATE,
    STATUS            CHAR(1 BYTE),
    FRECUENCIA        VARCHAR2(30 BYTE),
    DOSIS             VARCHAR2(30 BYTE),
    OBSERVACION       VARCHAR2(500 BYTE),
    CAN_CHANGE        CHAR(1 BYTE) DEFAULT 'Y',
    PRIORIDAD         CHAR(1 BYTE),
    CONCENTRACION     VARCHAR2(100 BYTE),
    FORMA             NUMBER(3,0),
    CANTIDAD          NUMBER(3,0),
    VIA               NUMBER(3,0)
);

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.GENERAR_OM IS
    'N=PENDIENTE QUE MEDICO O ENFERMERA GENERARA,Y= YA MEDICO O ENFERMERA EJECUTO BOTON DE GENRAR'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OM_REFID1 IS
    'REFID DE ORDEN MEDICA GENERADA EN EXPEDIENTE'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OM_REFID2 IS
    'REFID OTRO CAMPO DE ORDEN MEDICA GENERADA EN EXPEDIENTE'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OM_GENRATE_DATE IS
    'FECHAHORA QUE MEDICO APRUEBA PARA ACTIVAR ORDER SET'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OM_APPROVE_DATE IS
    'FECHAHORA QUE EJECUTA PARA GENERAR ORDENES EN EXPEDIENTE'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OSET_HEADER1 IS
    'FK header1';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OSET_HEADER2 IS
    'FK header2';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OSET_DET_ID IS
    'PK det';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.DISP_ORDER IS
    'display order in which its displayed';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.DISPLAY_TEXT IS
    'display text can be same as ref_name';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.REF_NAME IS
    'Name of medicine or procedure or diet etc..';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OM_TYPE IS
    'fk from tbl_oset_tipo_om_config';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.REF_CODE IS
    'item_code or procedure code';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.ADD_INFO_TEXT IS
    'additional info displayed on order set, can be instruction or blank'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.STATUS IS
    'P=PENDIENTE,A=APPROVED,I=INACTIVE';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.FRECUENCIA IS
    'additional data used for Medicine OM or LIS or RIS OM'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.DOSIS IS
    'additional info';

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.OBSERVACION IS
    'Observation field for all type of OM when generated.'
;

COMMENT ON COLUMN TBL_OSET_ORDEN_MEDICAS
.CAN_CHANGE IS
    'el campo que controla si medico uede quitar el check de seleccion cuando genera orden medica'
;

COMMENT ON TABLE TBL_OSET_ORDEN_MEDICAS
IS
    'Detailed table for order set where info of OM type to generate and its data is saved'
;

--Josu� 20200122
alter table TBL_OSET_ORDEN_MEDICAS add centro_servicio number(10) null;

--Josu� 20200504
ALTER TABLE TBL_OSET_ORDEN_MEDICAS ADD (
	medico_interconsulta varchar2(15),
	especialidad_interconsulta varchar2(4),
	med_int_name varchar2(500),
	espe_med_int varchar2(500),
	fecha_interconsulta date
);

--Josu� 20200505
ALTER TABLE TBL_OSET_ORDEN_MEDICAS ADD motivo number(10);

