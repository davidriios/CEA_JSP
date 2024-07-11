CREATE TABLE TBL_OSET_HEADER2_DET
(
    OSET_HEADER1    NUMBER
        NOT NULL ENABLE,
    OSET_HEADER2    NUMBER
        NOT NULL ENABLE,
    OSET_DET_ID     NUMBER
        NOT NULL ENABLE,
    DISP_ORDER      NUMBER
        NOT NULL ENABLE,
    DISPLAY_TEXT    VARCHAR2(500 BYTE)
        NOT NULL ENABLE,
    REF_NAME        VARCHAR2(500 BYTE),
    OM_TYPE         NUMBER,
    REF_CODE        VARCHAR2(30 BYTE),
    ADD_INFO_TEXT   VARCHAR2(1024 BYTE) DEFAULT '-',
    CREATED_BY      VARCHAR2(30 BYTE)
        NOT NULL ENABLE,
    MODIFIED_BY     VARCHAR2(30 BYTE),
    CREATED_DATE    DATE DEFAULT SYSDATE
        NOT NULL ENABLE,
    MODIFIED_DATE   DATE,
    STATUS          CHAR(1 BYTE),
    FRECUENCIA      VARCHAR2(30 BYTE),
    DOSIS           VARCHAR2(30 BYTE),
    OBSERVACION     VARCHAR2(500 BYTE),
    CAN_CHANGE      CHAR(1 BYTE) DEFAULT 'Y'
);

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.OSET_HEADER1 IS
    'FK header1';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.OSET_HEADER2 IS
    'FK header2';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.OSET_DET_ID IS
    'PK det';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.DISP_ORDER IS
    'display order in which its displayed';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.DISPLAY_TEXT IS
    'display text can be same as ref_name';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.REF_NAME IS
    'Name of medicine or procedure or diet etc..';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.OM_TYPE IS
    'fk from tbl_oset_tipo_om_config';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.REF_CODE IS
    'item_code or procedure code';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.ADD_INFO_TEXT IS
    'additional info displayed on order set, can be instruction or blank'
;

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.STATUS IS
    'A=Active,I=Inactive';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.FRECUENCIA IS
    'additional data used for Medicine OM or LIS or RIS OM'
;

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.DOSIS IS
    'additional info';

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.OBSERVACION IS
    'Observation field for all type of OM when generated.'
;

COMMENT ON COLUMN TBL_OSET_HEADER2_DET
.CAN_CHANGE IS
    'el campo que controla si medico uede quitar el check de seleccion cuando genera orden medica'
;

COMMENT ON TABLE TBL_OSET_HEADER2_DET
IS
    'Detailed table for order set where info of OM type to generate and its data is saved'
;

--Josué 20200124
alter table TBL_OSET_HEADER2_DET add (
    PRIORIDAD         CHAR(1 BYTE),
    CONCENTRACION     VARCHAR2(100 BYTE),
    FORMA             NUMBER(3,0),
    CANTIDAD          NUMBER(3,0),
    VIA               NUMBER(3,0),
    CENTRO_SERVICIO   NUMBER(10,0)
);

--Josué 20200505
ALTER TABLE TBL_OSET_HEADER2_DET ADD motivo number(10);