<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="FPMgr" scope="page" class="issi.admin.FileMgr"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoHeader = new CommonDataObject();
CommonDataObject cdoSep = new CommonDataObject();

String docPath = ResourceBundle.getBundle("path").getString("docs").replace(ResourceBundle.getBundle("path").getString("root"),"");
String fileName = null;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer xtraFilter = new StringBuffer();
StringBuffer sbSep = new StringBuffer();
String fp = request.getParameter("fp");
String docType = request.getParameter("docType");
String fecha =request.getParameter("fecha");
String tipoCuenta = request.getParameter("tipoCuenta");
String aseguradora = request.getParameter("aseguradora");
String categoria = request.getParameter("categoria");
String pacId = request.getParameter("pacId");
String banco = request.getParameter("banco");
String fDesde = request.getParameter("fDesde");
String fHasta = request.getParameter("fHasta");
String tipo = request.getParameter("tipo");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String fechaPago = request.getParameter("fechaPago");
String trimestre = request.getParameter("trimestre");
String codReporte = request.getParameter("codReporte");
String codPlanilla = request.getParameter("codPlanilla");
String noPlanilla = request.getParameter("noPlanilla");
String nombreRuta = request.getParameter("nombreRuta");
String vista = request.getParameter("vista");
String inTrx = request.getParameter("inTrx");
String tipoPago = request.getParameter("tipoPago");
String id_lote="";
String noCuenta = request.getParameter("noCuenta");
String tipo_orden = request.getParameter("tipo_orden");
String separador = "";
String agrupa_hon = request.getParameter("agrupa_hon");
String tipoComprob = request.getParameter("tipoComprob");
String cuentaPrincipal = request.getParameter("cuentaPrincipal");
String id = request.getParameter("id");
String colDebCre = request.getParameter("colDebCre");
String showHeader = request.getParameter("showHeader");
String fisco = request.getParameter("fisco");
String pExcluyeCheque = request.getParameter("pExcluyeCheque");
String pMes13 = request.getParameter("pMes13");
String pRegManual = request.getParameter("pRegManual");

if (fp == null) fp = "";
if (docType == null) docType = "";
if (fecha == null) fecha = "";
if (tipoCuenta == null) tipoCuenta = "";
if (aseguradora == null) aseguradora = "";
if (categoria == null) categoria = "";
if (pacId == null) pacId = "";
if (banco == null) banco = "";
if (fDesde == null) fDesde = "";
if (fHasta == null) fHasta = "";
if (tipo == null) tipo = "";
if (mes == null) mes = "";
if (anio == null) anio = "";
if (fechaPago == null) fechaPago = "";
if (trimestre == null) trimestre = "";
if (codReporte == null) codReporte = "";
if (codPlanilla == null) codPlanilla = "";
if (noPlanilla == null) noPlanilla = "";
if (nombreRuta == null) nombreRuta = "";
if (vista == null) vista = "";
if (inTrx == null) inTrx = "";
if (tipoPago == null) tipoPago = "";
if (noCuenta == null) noCuenta = "";
if (tipo_orden == null) tipo_orden = "";
if (tipoComprob == null) tipoComprob = "";
if (cuentaPrincipal == null) cuentaPrincipal = "";
if (id == null) id = "";
if (colDebCre==null)colDebCre="N";
if(showHeader==null)showHeader="N";
if(agrupa_hon==null) agrupa_hon = "";
if (fisco == null) fisco = "";
if (pExcluyeCheque == null) pExcluyeCheque = "";
if (pMes13 == null) pMes13 = "";
if (pRegManual == null) pRegManual = "";

if (fp.trim().equals("")) throw new Exception("El Origen no es válido. Por favor consulte con su Administrador!");
if (docType.trim().equals("")) throw new Exception("El Documento no es válido. Por favor consulte con su Administrador!");

    sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'ADMIN_FILE_SEP'),'P') as fileSep from dual");
	cdoSep = SQLMgr.getData(sbSql.toString());
	sbSql = new StringBuffer();
	
	if (cdoSep == null) {	
		cdoSep = new CommonDataObject();
		cdoSep.addColValue("fileSep","P");		
	}
	separador = cdoSep.getColValue("fileSep");
	sbSep = new StringBuffer();
	   if(separador.trim().equals("P"))sbSep.append("CHR(124)");
	   else if(separador.trim().equals("T"))sbSep.append("CHR(9)");
	   else if(separador.trim().equals("C"))sbSep.append("CHR(44)"); 
	
String docDesc = "";
if (docType.equalsIgnoreCase("CXCMOR"))
{
	//MorMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.cxc").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fecha_inicial",fecha);
	cdo.addColValue("tipo_cta",tipoCuenta);
	cdo.addColValue("aseguradora",aseguradora);
	cdo.addColValue("categoria",categoria);
	cdo.addColValue("pac_id",pacId);

	//fileName = MorMgr.createFile(cdo);
	//if (fileName == null) throw new Exception(MorMgr.getErrException());
	docDesc = "MOROSIDAD CXC";
}
else if (docType.equalsIgnoreCase("CXPACH"))
{
	//OPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.cxp").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("banco",banco);
	cdo.addColValue("fecha_desde",fDesde);
	cdo.addColValue("fecha_hasta",fHasta);
	cdo.addColValue("p_valor",tipo);

	//fileName = OPMgr.createFile(cdo);
	//if (fileName == null) throw new Exception(OPMgr.getErrException());
	docDesc = "ACH CXP";
}
else if (docType.equalsIgnoreCase("ACHACR"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.planilla").replace(ResourceBundle.getBundle("path").getString("root"),"");


	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("mes",""+mes);
	cdo.addColValue("anio",""+anio);
	cdo.addColValue("fecha_efectiva",""+fechaPago);
	cdo.addColValue("fg","ACHACR");
	cdo.addColValue("name","ACHACR");
	cdo.addColValue("vista","CCC");

	  sbSql = new StringBuffer();
	  sbSql.append("select (LTRIM(RTRIM(NVL(E.RUC,E.COD_ACREEDOR))))||','||");
	  sbSql.append("translate(REPLACE(REPLACE(E.NOMBRE,'Ñ','N'),',',' '),'ÁÉÍÓÚ','AEIOU')||','||LPAD(NVL(p.RUTA,0),9,'0')||','||p.CUENTA_BANCARIA");
	  sbSql.append("||','||decode(SUBSTR(p.CUENTA_BANCARIA,1,2),'07','7',p.TIPO_CUENTA)||','||ltrim(rtrim(TO_CHAR(p.monto_acreedor,'0000009.90')))");
	  sbSql.append("||','||'C'||','||'REF*TXT**PAGO DE DESCUENTOS DEL MES DE '||ltrim(rtrim(nvl((select descripcion from tbl_pla_vac_parametro where");
	  sbSql.append(" mes =");
	  sbSql.append(cdo.getColValue("mes"));
	  sbSql.append("),to_char(to_date('01/'||");
	  sbSql.append(cdo.getColValue("mes"));
	  sbSql.append("||'/'||");
	  sbSql.append(cdo.getColValue("anio"));

	  sbSql.append(",'DD/MM/YYYY'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH'))))||' DE '||");
	  sbSql.append(cdo.getColValue("anio"));
	  sbSql.append(" texto from tbl_pla_temporal_cheque p, tbl_pla_acreedor E where p.cod_compania=");
	  sbSql.append(cdo.getColValue("compania"));
	  sbSql.append(" and mes =");
	  sbSql.append(cdo.getColValue("mes"));
	  sbSql.append(" and e.cod_acreedor = p.cod_acreedor");
	  sbSql.append(" and e.compania = p.cod_compania order by p.cod_acreedor");


	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ACH ACR";
}
else if (docType.equalsIgnoreCase("FCESAN"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.planilla").replace(ResourceBundle.getBundle("path").getString("root"),"");


	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("anio",""+anio);
	cdo.addColValue("trimestre",""+trimestre);
	cdo.addColValue("fg","FCESAN");
	cdo.addColValue("name","CESANTIA");
	cdo.addColValue("vista","CCC");

	fileName = FPMgr.createFile(cdo,"",false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "FONDO DE CESANTIA";
}
else if (docType.equalsIgnoreCase("SYSMECA"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.planilla").replace(ResourceBundle.getBundle("path").getString("root"),"");


	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("mes",""+mes);
	cdo.addColValue("anio",""+anio);
	cdo.addColValue("codReporte",""+codReporte);
	cdo.addColValue("fg","SYSMECA");
	cdo.addColValue("name","DETALLE");
	cdo.addColValue("vista","CCC");

	  sbSql = new StringBuffer();
	  sbSql.append("SELECT TO_CHAR(NVL(c.tipo_reg,2))||TO_CHAR(c.correlativo)||LPAD(NVL(SUBSTR(a.num_empleado,1,5),0),5,'0') ||LPAD(NVL(e.num_ssocial,0),7,'0') || LPAD(DECODE(a.provincia,0,DECODE(a.sigla,'00',' ','P','P ','PE','  ','N','N  ','E','E ',''),00,' ', 11,'B ', 12,'C ',a.provincia),2,'0') || RPAD(DECODE(a.sigla,'00','  ','0','  ','E','  ','N','  ','P','  ','PE','PE',a.sigla),2,' ')||LPAD(TO_CHAR(a.tomo),5,'0') || LPAD(TO_CHAR(a.asiento),6,'0') ||REPLACE(RPAD(SUBSTR(DECODE(sexo,'F',DECODE(apellido_casada,NULL, primer_apellido,DECODE(usar_apellido_casada,'S','DE'||apellido_casada,primer_apellido)),primer_apellido),1,14),14,' ')|| RPAD(e.primer_nombre,14,' '),'Ñ','N')|| e.sexo||LPAD(NVL(a.excepciones,0),2,'0')||LPAD(NVL(a.departamento,'00'),2,' ')||'00'||LPAD(TO_CHAR(TRUNC(NVL(a.sal_bruto,0))),5,'0')||LPAD(TO_CHAR(MOD(NVL(a.sal_bruto,0),1) * 100),2,'0')||LPAD(TO_CHAR(TRUNC(NVL(a.imp_renta,0))),5,'0')||LPAD(TO_CHAR(MOD(NVL(a.imp_renta,0),1) * 100),2,'0')||NVL(e.tipo_renta,'C')||DECODE(NVL(e.num_dependiente,0),10,'O',11,'P',12,'Q',13,'R',14,'S',15,'T',16,'U',17,'V',18,'X',19,'Y',20,'Z',NVL(e.num_dependiente,0))|| NVL(a.ajuste,' ')||' '||'000'||DECODE(a.nv_provincia,NULL,'  ', LPAD(DECODE(a.nv_provincia,0,DECODE(a.sigla,'00',' ','P','P ','PE','  ','N','N ','E','E ',''),00,' ',11,'B ',12,'C ',a.provincia),2,'0') ) ||DECODE( a.nv_sigla,NULL,'  ', RPAD(DECODE(a.sigla,'00','  ','0','  ','E','  ','N','  ','PE','PE',a.sigla),2,' '))||DECODE(a.nv_tomo,NULL,'     ', LPAD(TO_CHAR(a.nv_tomo),5,'0')) ||DECODE(a.nv_asiento,NULL,'      ',LPAD(TO_CHAR(a.nv_asiento),6,'0') ) ||' '||LPAD(TO_CHAR(TRUNC(NVL(a.decimo,0))),5,'0')||LPAD(TO_CHAR(MOD(NVL(a.decimo,0),1) * 100),2,'0')   texto FROM TBL_PLA_RETENCIONES a, TBL_PLA_REPORTE_ENCABEZADO b,        TBL_PLA_PARAMETROS c,TBL_PLA_EMPLEADO e WHERE e.compania=a.cod_compania AND c.cod_compania = a.cod_compania AND b.cod_compania = a.cod_compania AND a.cod_compania =");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND a.anio = ");
sbSql.append(cdo.getColValue("anio"));
sbSql.append(" AND a.mes = ");
sbSql.append(cdo.getColValue("mes"));
sbSql.append(" AND a.cod_reporte = ");
sbSql.append(cdo.getColValue("codReporte"));
sbSql.append(" AND a.anio = b.anio AND a.mes = b.mes AND a.cod_reporte = b.cod_reporte AND a.emp_id = e.emp_id AND c.estado = 'A' ORDER BY LPAD(DECODE(a.provincia,0,DECODE(a.sigla,'00',' ','P','P ','PE','  ','N','N ','E','E ',''),00,' ',11,'B',12,'C ',a.provincia),2,'0')  ||RPAD(DECODE(a.sigla,'00','  ','0','  ','E','  ','N','  ','PE','PE',a.sigla),2,' ')||LPAD(TO_CHAR(a.tomo),5,'0')||LPAD(TO_CHAR(a.asiento),6,'0')");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "SYSMECA";
}
else if (docType.equalsIgnoreCase("ACHEMP"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.planilla").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("anio",""+anio);
	cdo.addColValue("noPlanilla",""+noPlanilla);
	cdo.addColValue("codPlanilla",""+codPlanilla);
	cdo.addColValue("ruta",""+banco);
	cdo.addColValue("nombreRuta",""+nombreRuta);
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("name",""+docType+"_"+nombreRuta);
	cdo.addColValue("vista","CCC");

	  sbSql.append("SELECT DECODE(e.provincia,0,'',00,'',11,'B',12,'C',e.provincia)||DECODE(e.sigla,'00','','0','',e.sigla)||'-'||TO_CHAR(e.tomo)||'-'||TO_CHAR(e.asiento) ||'|'||translate(replace(REPLACE(primer_nombre||' '||DECODE(sexo,'F',DECODE(apellido_casada,NULL,primer_apellido,DECODE(usar_apellido_casada,'S','DE '||apellido_casada,primer_apellido)),primer_apellido),'Ñ','N'),',',' '),'ÁÉÍÓÚ','AEIOU') ||'|'||NVL(e.ruta_bancaria,0) ||'|'||NVL(e.num_cuenta,0) ||'|'||DECODE(e.tipo_cuenta,'A','4','C','3','4')||'|'||REPLACE(TO_CHAR(a.sal_neto,'999999990.00'),' ','') ||'|'||'C' ||'|'||'REF*TXT**'||RPAD(b.nombre,15,' ')||' '||TO_CHAR(c.fecha_inicial,'dd-mon-yyyy') ||' al '||TO_CHAR(c.fecha_final,'dd-mon-yyyy') texto,e.num_ssocial from tbl_pla_pago_empleado a, tbl_pla_empleado e, tbl_pla_planilla b,tbl_pla_planilla_encabezado c where a.emp_id = e.emp_id and a.cod_compania = e.compania and a.anio = ");
sbSql.append(cdo.getColValue("anio"));
sbSql.append(" and a.cod_planilla = ");
sbSql.append(cdo.getColValue("codPlanilla"));

sbSql.append(" and a.num_planilla = ");
sbSql.append(cdo.getColValue("noPlanilla"));
sbSql.append(" and a.cod_compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" and e.ruta_bancaria ='");
sbSql.append(cdo.getColValue("ruta"));
sbSql.append("' and nvl(a.sal_neto,0) > 0 and e.forma_pago = 2 and e.num_cuenta is not null and e.ruta_bancaria is not null and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and a.cod_compania = c.cod_compania and a.anio = c.anio ");

sbSql.append(" union all "); 
sbSql.append("SELECT DECODE(e.provincia,0,'',00,'',11,'B',12,'C',e.provincia)||DECODE(e.sigla,'00','','0','',e.sigla)||'-'||TO_CHAR(e.tomo)||'-'||TO_CHAR(e.asiento) ||'|'||translate(replace(REPLACE(primer_nombre||' '||DECODE(sexo,'F',DECODE(apellido_casada,NULL,primer_apellido,DECODE(usar_apellido_casada,'S','DE '||apellido_casada,primer_apellido)),primer_apellido),'Ñ','N'),',',' '),'ÁÉÍÓÚ','AEIOU') ||'|'||NVL(e.ruta_bancaria,0) ||'|'||NVL(e.num_cuenta,0) ||'|'||DECODE(e.tipo_cuenta,'A','4','C','3','4')||'|'||REPLACE(TO_CHAR(a.sal_neto,'999999990.00'),' ','') ||'|'||'C' ||'|'||'REF*TXT**'||RPAD(b.nombre,15,' ')||' '||TO_CHAR(c.fecha_inicial,'dd-mon-yyyy') ||' al '||TO_CHAR(c.fecha_final,'dd-mon-yyyy') texto,e.num_ssocial from tbl_pla_pago_liquidacion a, tbl_pla_empleado e, tbl_pla_planilla b,tbl_pla_planilla_encabezado c where a.emp_id = e.emp_id and a.cod_compania = e.compania and a.anio = ");
sbSql.append(cdo.getColValue("anio"));
sbSql.append(" and a.cod_planilla = ");
sbSql.append(cdo.getColValue("codPlanilla"));
sbSql.append(" and a.num_planilla = ");
sbSql.append(cdo.getColValue("noPlanilla"));
sbSql.append(" and a.cod_compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" and e.ruta_bancaria ='");
sbSql.append(cdo.getColValue("ruta"));
sbSql.append("' and nvl(a.sal_neto,0) > 0  and e.forma_pago = 2 and e.num_cuenta is not null and e.ruta_bancaria is not null and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and a.cod_compania = c.cod_compania and a.anio = c.anio ");
sbSql.append(" order by 2 ");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ACH EMPLEADO";
}
else if (docType.equalsIgnoreCase("FACTPROV"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.cxp").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("docPath","cxp");
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("mes",mes);
	cdo.addColValue("anio",anio);
	cdo.addColValue("name","FACT_PROV_"+cdo.getColValue("mes")+"_"+cdo.getColValue("anio"));
	cdo.addColValue("vista","CCC");

	sbSql = new StringBuffer();
	/*
	sbSql.append("select b.tipo_persona || chr(9) || b.ruc || chr(9) || lpad(b.digito_verificador, 2, '0') || chr(9) || b.nombre_proveedor || chr(9) || a.numero_factura || chr(9) || to_char(a.fecha_documento, 'yyyymmdd') || chr(9) || a.cod_concepto || chr(9) || b.local_internacional || chr(9) || a.monto_total || chr(9) || a.itbm texto");
	sbSql.append(" from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_con_conceptos c,tbl_inv_documento_recepcion doc ");
	sbSql.append(" where a.estado = 'R' and a.fre_documento =doc.documento and doc.informe_43='S' and a.cod_proveedor = b.cod_provedor and a.compania = ");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(" and to_date(to_char(a.fecha_documento, 'mm/yyyy'), 'mm/yyyy') = to_date('");
	sbSql.append(cdo.getColValue("mes"));
	sbSql.append("/");
	sbSql.append(cdo.getColValue("anio"));
	sbSql.append("','mm/yyyy')  and a.cod_concepto = c.codigo(+) order by a.fecha_documento desc");
	*/
	sbSql.append("select decode(tipo_persona, 1, 'N', 2, 'J', 3, 'E',tipo_persona) || chr(9) || ruc || chr(9) || lpad(dv, 2, '0') || chr(9) || nombre_proveedor || chr(9) || numero_factura || chr(9) || to_char(fecha, 'yyyymmdd') || chr(9) || cod_concepto || chr(9) || local_internacional || chr(9) || monto_total || chr(9) || itbm texto");
	sbSql.append(" from (select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, a.numero_factura, a.fecha_documento fecha, to_char(a.fecha_documento, 'yyyymmdd') fecha_documento, a.cod_concepto, a.compania, a.anio_recepcion, (a.monto_total - a.itbm) + (NVL((SELECT sum(decode (aa.codigo_ajuste, 1, aa.total - aa.itbm, -aa.total + aa.itbm)) FROM tbl_inv_ajustes aa WHERE aa.estado = 'A' and aa.cod_proveedor = b.cod_provedor and aa.anio_doc = a.anio_recepcion and aa.numero_doc = a.numero_documento and aa.compania = a.compania and to_date(to_char(aa.fecha_ajuste, 'mm/yyyy'), 'mm/yyyy') = to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy')");
	sbSql.append("), 0) + NVL((SELECT sum(-aa.monto + aa.itbm) FROM tbl_inv_devolucion_prov aa WHERE aa.anulado_sino = 'N' and aa.tipo_dev = 'N' and aa.cod_provedor = b.cod_provedor and aa.anio_recepcion = a.anio_recepcion and aa.numero_recepcion = a.numero_documento and aa.compania = a.compania and to_date(to_char(aa.fecha, 'mm/yyyy'), 'mm/yyyy') = to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy')");
	sbSql.append("), 0) + nvl((SELECT sum(decode(aa.cod_tipo_ajuste,1,aa.monto,-aa.monto)) FROM tbl_cxp_ajuste_saldo_enc aa WHERE aa.estado = 'R' /*and aa.ref_id = to_char (b.cod_provedor)*/ and aa.destino_ajuste in ('P', 'G') and aa.numero_factura = a.numero_factura and aa.ref_id = to_char (a.cod_proveedor) and aa.compania = a.compania and to_date(to_char(aa.fecha, 'mm/yyyy'), 'mm/yyyy') = to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy')");
	sbSql.append("), 0)) monto_total, a.itbm, to_char(a.cod_proveedor) cod_proveedor, a.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode(b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_con_conceptos c ,tbl_inv_documento_recepcion doc where a.estado = 'R' and a.fre_documento =doc.documento and doc.informe_43='S'  and a.cod_proveedor = b.cod_provedor and a.compania = ");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(" and a.cod_concepto = c.codigo union all select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, rm.numero_factura, a.fecha_ajuste, to_char(a.fecha_ajuste, 'yyyymmdd') fecha_documento, rm.cod_concepto, a.compania, a.anio_ajuste, decode(a.codigo_ajuste, 1, a.total-a.itbm, -a.total+a.itbm), decode(a.codigo_ajuste, 1, a.itbm, -a.itbm), to_char(a.cod_proveedor) cod_proveedor, rm.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode(b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_inv_ajustes a, tbl_com_proveedor b, tbl_inv_recepcion_material rm, tbl_con_conceptos c, tbl_inv_documento_recepcion doc where a.estado = 'A' and a.compania = ");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(" and a.cod_proveedor = b.cod_provedor and a.anio_doc = rm.anio_recepcion and a.numero_doc = rm.numero_documento and a.compania = rm.compania and rm.cod_concepto = c.codigo and rm.fre_documento = doc.documento and doc.informe_43 = 'S' and trunc(rm.fecha_documento) < to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy')");
	sbSql.append(" union all select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, rm.numero_factura, a.fecha, to_char(a.fecha, 'yyyymmdd') fecha_documento, rm.cod_concepto, a.compania, a.anio, -a.monto+a.itbm, -a.itbm, to_char(a.cod_provedor) cod_proveedor, rm.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode (b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_inv_devolucion_prov a, tbl_com_proveedor b, tbl_inv_recepcion_material rm, tbl_con_conceptos c, tbl_inv_documento_recepcion doc where a.anulado_sino = 'N' and a.tipo_dev = 'N' and a.compania = ");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(" and a.cod_provedor = b.cod_provedor and a.anio_recepcion = rm.anio_recepcion and a.numero_recepcion = rm.numero_documento and a.compania = rm.compania and rm.cod_concepto = c.codigo and rm.fre_documento = doc.documento and doc.informe_43 = 'S' and trunc(rm.fecha_documento) < to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy')");
	sbSql.append(" union all select b.tipo_persona, decode(b.tipo_persona, 1, 'Natural', 2, 'Juridico', 3, 'Extranjero') tipo_persona_desc, b.ruc, b.digito_verificador dv, b.nombre_proveedor, a.numero_factura, a.fecha, to_char(a.fecha, 'yyyymmdd') fecha_documento, rm.cod_concepto, a.compania, a.anio,decode(a.cod_tipo_ajuste,1,a.monto,-a.monto) as monto, 0 itbm, a.ref_id cod_provedor, rm.cod_concepto || ' - ' || c.descripcion concepto, b.local_internacional, decode (b.local_internacional, 1, 'LOCALES', 2, 'IMPORTACIONES') local_internacional_desc from tbl_cxp_ajuste_saldo_enc a, tbl_com_proveedor b, tbl_inv_recepcion_material rm, tbl_con_conceptos c, tbl_inv_documento_recepcion doc where a.estado = 'R' and a.compania = ");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(" and a.ref_id = to_char(b.cod_provedor) and a.destino_ajuste in ('P', 'G') and a.numero_factura = rm.numero_factura and a.ref_id = to_char(rm.cod_proveedor) and rm.cod_concepto = c.codigo and rm.fre_documento = doc.documento and doc.informe_43 = 'S' and trunc(rm.fecha_documento) < to_date('");
		sbSql.append(mes);
		sbSql.append("/");
		sbSql.append(anio);
		sbSql.append("', 'mm/yyyy')");
	sbSql.append(") where compania = ");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(" and to_date(to_char(fecha, 'mm/yyyy'), 'mm/yyyy') = to_date('");
	sbSql.append(cdo.getColValue("mes"));
	sbSql.append("/");
	sbSql.append(cdo.getColValue("anio"));
	sbSql.append("','mm/yyyy') order by fecha desc");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "INFORME MEF (43)";
}
else if (docType.equalsIgnoreCase("ACHPROV"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.cxp").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("docPath","cxp");
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("fecha_desde",fDesde);
	cdo.addColValue("fecha_hasta",fHasta);
	cdo.addColValue("banco",banco);
	cdo.addColValue("tipo",tipo);
	cdo.addColValue("vista",vista);
	cdo.addColValue("fecha", CmnMgr.getCurrentDate("ddmmyyyy"));
	cdo.addColValue("name",CmnMgr.getCurrentDate("ddmmyyyy")+cdo.getColValue("tipo")+"_");
	if (cdo.getColValue("vista") != null && cdo.getColValue("vista").toLowerCase().endsWith("_csv")) cdo.addColValue("extension",".csv");

	sbSql.append("select nvl(to_number(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CXP_ACH_TXT_LN_SIZE_");
	sbSql.append(cdo.getColValue("vista").toUpperCase());
	sbSql.append("')),0) as lineSize from dual");
	int lnSize = CmnMgr.getCount(sbSql.toString());
	
	if(vista.equalsIgnoreCase("VW_CON_ACH_BAC_FILE")){
		sbSql = new StringBuffer();
		sbSql.append("select text || replace(to_char(nvl(monto, 0), '9999999999.00'), '.') || lpad(num_trx, 5, ' ') text_header from (");
		sbSql.append("select 'B2799                              '||to_char(sysdate, 'yyyy')||to_char(sysdate, 'mm')||to_char(sysdate, 'dd') text, sum(monto) monto, count(*) num_trx from VW_CON_ACH_BAC_FILE ");
		sbSql.append(" where cod_compania = ");
		sbSql.append(cdo.getColValue("compania"));
		sbSql.append(" and p_valor = ");
		sbSql.append(cdo.getColValue("tipo"));
		
		sbSql.append(" and banco = '");
		sbSql.append(cdo.getColValue("banco"));
		sbSql.append("'");
		if(cdo.getColValue("tipo").equals("5") && tipo_orden.equals("H") && agrupa_hon.equals("Y")){
			sbSql.append(" and tipo_orden in ('M', 'S')");
		} else if(cdo.getColValue("tipo").equals("5") && !tipo_orden.equals("")){
			sbSql.append(" and tipo_orden = '");
			sbSql.append(tipo_orden);
			sbSql.append("'");
		} else if(cdo.getColValue("tipo").equals("4") && !tipo_orden.equals("")){
			sbSql.append(" and tipo_orden = '");
			sbSql.append(tipo_orden);
			sbSql.append("'");
		}
		
		sbSql.append(" and f_emision >= to_date('");
		sbSql.append(cdo.getColValue("fecha_desde"));
		sbSql.append("','dd/mm/yyyy') and f_emision <= to_date('");
		sbSql.append(cdo.getColValue("fecha_hasta"));
		sbSql.append("', 'dd/mm/yyyy') group by 'B2799                         '||to_char(sysdate, 'yyyy')||to_char(sysdate, 'mm')||to_char(sysdate, 'dd'))");
		cdoHeader = SQLMgr.getData(sbSql.toString());
		if(cdoHeader == null) throw new Exception("No existen registros para generar archivo!.");
		cdo.addColValue("text_header", cdoHeader.getColValue("text_header"));
		
	}

	sbSql = new StringBuffer();
	sbSql.append("select ");
	if (lnSize != 0) { sbSql.append("rpad("); }
	sbSql.append("decode(linea,2,replace(texto,'@desc','DEL ");
	sbSql.append(cdo.getColValue("fecha_desde"));
	sbSql.append(" AL ");
	sbSql.append(cdo.getColValue("fecha_hasta"));
	sbSql.append("'),texto)");
	if (lnSize != 0) { sbSql.append(","); sbSql.append(lnSize); sbSql.append(",' ')"); }
	sbSql.append(" as texto, '' as num_tarjeta from ");
	sbSql.append(cdo.getColValue("vista"));
	sbSql.append(" where cod_compania = ");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(" and p_valor = ");
	sbSql.append(cdo.getColValue("tipo"));
	
	sbSql.append(" and banco = '");
	sbSql.append(cdo.getColValue("banco"));
	sbSql.append("'");
	if(cdo.getColValue("tipo").equals("5") && tipo_orden.equals("H") && agrupa_hon.equals("Y")){
		sbSql.append(" and tipo_orden in ('M', 'S')");
	} else if(cdo.getColValue("tipo").equals("5") && !tipo_orden.equals("")){
		sbSql.append(" and tipo_orden = '");
		sbSql.append(tipo_orden);
		sbSql.append("'");
	} else if(cdo.getColValue("tipo").equals("4") && !tipo_orden.equals("")){
			sbSql.append(" and tipo_orden = '");
			sbSql.append(tipo_orden);
			sbSql.append("'");
		}
	
	sbSql.append(" and f_emision >= to_date('");
	sbSql.append(cdo.getColValue("fecha_desde"));
	sbSql.append("','dd/mm/yyyy') and f_emision <= to_date('");
	sbSql.append(cdo.getColValue("fecha_hasta"));
	sbSql.append("','dd/mm/yyyy') order by p_valor, banco, cuenta, num_cheque, nombre, orden");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "CXP - ACH ";
	
	CommonDataObject param = new CommonDataObject();
	param.setSql("call sp_cxp_set_lote_ach (?,?,?,?,?,?,?)");
	param.addInStringStmtParam(1,cdo.getColValue("compania"));
	param.addInStringStmtParam(2,IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
	param.addInStringStmtParam(3,tipoPago);
	param.addInStringStmtParam(4,cdo.getColValue("fecha_desde"));
	param.addInStringStmtParam(5,cdo.getColValue("fecha_hasta"));
	param.addInStringStmtParam(6,inTrx);
	param.addOutStringStmtParam(7);
	param = SQLMgr.executeCallable(param,false,true);
		System.out.println("id_lote...........................................................="+param.getStmtParams().size());
	for (int i=0; i<param.getStmtParams().size(); i++) {
		CommonDataObject.StatementParam pp = param.getStmtParam(i);
		if (pp.getType().contains("o")) {
			if (pp.getIndex() == 7) id_lote = pp.getData().toString();
		}
	}
		System.out.println("id_lote...........................................................="+id_lote);
	
	/*sbSql = new StringBuffer();
	sbSql.append("call sp_cxp_set_lote_ach(");
	sbSql.append(cdo.getColValue("compania"));
	sbSql.append(",'");
	sbSql.append(IBIZEscapeChars.forSingleQuots(((String) session.getAttribute("_userName")).trim()));
	sbSql.append("',");
	sbSql.append(tipoPago);
	sbSql.append(",'");
	sbSql.append(cdo.getColValue("fecha_desde"));
	sbSql.append("','");
	sbSql.append(cdo.getColValue("fecha_hasta"));
	sbSql.append("', '");
	sbSql.append(inTrx);
	sbSql.append("')");
	SQLMgr.execute(sbSql.toString());*/
}
else if (docType.equalsIgnoreCase("AUDTRX"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.conta").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId")); 
	cdo.addColValue("fecha_desde",fDesde);
	cdo.addColValue("fecha_hasta",fHasta); 
	cdo.addColValue("noCuenta",""+noCuenta);
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("name","aud_trx_"+cdo.getColValue("fecha_desde").replace("/","")+"_"+cdo.getColValue("fecha_hasta").replace("/",""));
	cdo.addColValue("docPath","conta"); 
	cdo.addColValue("vista","CCC");
	
	if(fDesde != null && !fDesde.trim().equals("")){ sbFilter.append(" and trunc(ec.fecha_comp) >= to_date('");sbFilter.append(fDesde);sbFilter.append("','dd/mm/yyyy')");}
	if(fHasta != null && !fHasta.trim().equals("")){ sbFilter.append(" and trunc(ec.fecha_comp) <= to_date('");sbFilter.append(fHasta);sbFilter.append("','dd/mm/yyyy')");}
	if(!tipoComprob.trim().equals("")){ sbFilter.append(" and ec.clase_comprob =");sbFilter.append(tipoComprob);}
	
	if(pMes13.trim().equals("S"))
	{  
	    sbFilter.append(" and ec.mes =13");
	    if(pRegManual.trim().equals("S")) sbFilter.append(" and ec.creado_por = 'RCM' ");
	}

	if(noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0")){ xtraFilter.append(" where no_cta like '%");xtraFilter.append(noCuenta);xtraFilter.append("%'");}
	if(cuentaPrincipal != null && !cuentaPrincipal.trim().equals("")&& !cuentaPrincipal.trim().equals("0"))
	{ 
		if(noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0"))xtraFilter.append(" and ");
		else xtraFilter.append(" where ");
		
		xtraFilter.append(" cuenta_principal=");xtraFilter.append(cuentaPrincipal);
	}
	if(tipoCuenta != null && !tipoCuenta.trim().equals("")&& !tipoCuenta.trim().equals("0"))
	{ 
		if((noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0"))|| (cuentaPrincipal != null && !cuentaPrincipal.trim().equals("")&& !cuentaPrincipal.trim().equals("0")))xtraFilter.append(" and ");
		else xtraFilter.append(" where ");
		
		xtraFilter.append(" tipo_cuenta=");xtraFilter.append(tipoCuenta);
	}

	  sbSql = new StringBuffer();
	   
	   
	  sbSql.append(" select   num_cuenta||");
	  sbSql.append(sbSep);
	  sbSql.append("||replace (replace (translate(replace (replace (desc_cuenta, 'Ñ', 'N'), ',', ' '),'ÁÉÍÓÚ','AEIOU'),'?','%'),',',' ')||");
	  sbSql.append(sbSep);
	  sbSql.append("||replace (replace (translate(replace (replace (desc_comprob, 'Ñ', 'N'), ',', ' '),'ÁÉÍÓÚ','AEIOU'),'?','%'),',',' ')||");
	  sbSql.append(sbSep);
	  sbSql.append("||replace (replace (translate(replace (replace (tipo_doc, 'Ñ', 'N'), ',', ' '),'ÁÉÍÓÚ','AEIOU'),'?','%'),',',' ')||");
	  sbSql.append(sbSep);
	  sbSql.append("||replace (replace (translate(replace (replace (id_doc, 'Ñ', 'N'), ',', ' '),'ÁÉÍÓÚ','AEIOU'),'?','%'),',',' ')||"); 
	  sbSql.append(sbSep);
	  sbSql.append("||fecha||");
	  sbSql.append(sbSep);
	  sbSql.append("||creado_por||");
	  sbSql.append(sbSep);
	  sbSql.append("||fecha_trx||");
	  sbSql.append(sbSep);
	  sbSql.append("||lado||");
	  sbSql.append(sbSep);
	  sbSql.append("||debito||");
	  sbSql.append(sbSep);
	  sbSql.append("||credito||");
	  sbSql.append(sbSep);
	  sbSql.append("||total||");
	  sbSql.append(sbSep);
	  sbSql.append("||replace (replace (translate(replace (replace (others3, 'Ñ', 'N'), ',', ' '),'ÁÉÍÓÚ','AEIOU'),'?','%'),',',' ') as texto");
	    
	   sbSql.append(" ,no_cta, '' as num_tarjeta,fecha_doc,rownum from ( select at.consecutivo, (select num_cuenta from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) as num_cuenta, (select descripcion from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) desc_cuenta ,nvl(others2,(select descripcion from tbl_con_clases_comprob where codigo_comprob =at.codigo_comprob and tipo='C')) desc_comprob , (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =at.codigo_comprob and tipo='C')as tipo_doc,replace(at.id_doc,'|','-') as id_doc , to_char(at.fecha_doc ,'dd/mm/yyyy') as fecha,'A' creado_por, to_char(at.fecha_doc,'dd/mm/yyyy') as fecha_trx,at.lado,sum(decode(at.lado,'DB',at.monto,0)) as debito,sum(decode(at.lado,'CR',at.monto,0)) as credito,(sum(decode(at.lado,'DB',at.monto,0)) - sum(decode(at.lado,'CR',at.monto,0))) as total,at.fecha_doc ,at.compania,ec.ea_ano as anio,ec.mes,at.num_cuenta as no_cta,at.others3,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal from tbl_con_encab_comprob ec,tbl_con_aud_transaccional at where  ec.consecutivo =at.consecutivo and ec.ea_ano = at.anio_comprob and ec.compania=at.compania and ec.tipo=1 and ec.reg_type ='D' and ec.compania = ");
	  sbSql.append(cdo.getColValue("compania"));

sbSql.append(" and ec.status = 'AP' AND ec.estado = 'A' and  ec.clase_comprob not in (select column_value  from table( select split((select get_sec_comp_param(ec.compania,'AUD_EXCLU_COMPROB') from dual),',') from dual  )) ");
sbSql.append(sbFilter);
sbSql.append(" group by at.others3, at.num_cuenta,at.compania,at.codigo_comprob,at.consecutivo,replace(at.id_doc,'|','-'),to_char(at.fecha_doc,'dd/mm/yyyy'),at.lado,at.fecha_doc,others2,ec.mes,ec.ea_ano ");
sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C') desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'M', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Manuales' ,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal  from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='D' and ec.creado_por <> 'SP' group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6");
sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')||' - HIST' desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'H', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Manuales' ,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal  from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='H' group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6");

sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C') desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'M', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Costos',(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal  from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='D' and  ec.clase_comprob in (select column_value  from table( select split((select get_sec_comp_param(ec.compania,'AUD_EXCLU_COMPROB') from dual),',') from dual  )) group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6");

sbSql.append("  )x  ");
sbSql.append(xtraFilter);
sbSql.append(" order by no_cta asc, fecha_doc asc");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ARCHIVO TXT PARA AUDITORIA"; 
}
else if (docType.equalsIgnoreCase("AUDTRXRES"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.conta").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId")); 
	cdo.addColValue("fecha_desde",fDesde);
	cdo.addColValue("fecha_hasta",fHasta); 
	cdo.addColValue("noCuenta",""+noCuenta);
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("name","aud_trx_"+cdo.getColValue("fecha_desde").replace("/","")+"_"+cdo.getColValue("fecha_hasta").replace("/",""));
	cdo.addColValue("docPath","conta"); 
	cdo.addColValue("vista","CCC");
	
	if(fDesde != null && !fDesde.trim().equals("")){ sbFilter.append(" and trunc(ec.fecha_comp) >= to_date('");sbFilter.append(fDesde);sbFilter.append("','dd/mm/yyyy')");}
	if(fHasta != null && !fHasta.trim().equals("")){ sbFilter.append(" and trunc(ec.fecha_comp) <= to_date('");sbFilter.append(fHasta);sbFilter.append("','dd/mm/yyyy')");}
	if(!tipoComprob.trim().equals("")){ sbFilter.append(" and ec.clase_comprob =");sbFilter.append(tipoComprob);}
	if(pMes13.trim().equals("S"))
	{  
	    sbFilter.append(" and ec.mes =13");
	    if(pRegManual.trim().equals("S")) sbFilter.append(" and ec.creado_por = 'RCM' ");
	}
	if(noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0")){ xtraFilter.append(" where no_cta like '%");xtraFilter.append(noCuenta);xtraFilter.append("%'");}
	if(cuentaPrincipal != null && !cuentaPrincipal.trim().equals("")&& !cuentaPrincipal.trim().equals("0"))
	{ 
		if(noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0"))xtraFilter.append(" and ");
		else xtraFilter.append(" where ");
		
		xtraFilter.append(" cuenta_principal=");xtraFilter.append(cuentaPrincipal);
	}
	if(tipoCuenta != null && !tipoCuenta.trim().equals("")&& !tipoCuenta.trim().equals("0"))
	{ 
		if((noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0"))|| (cuentaPrincipal != null && !cuentaPrincipal.trim().equals("")&& !cuentaPrincipal.trim().equals("0")))xtraFilter.append(" and ");
		else xtraFilter.append(" where ");
		
		xtraFilter.append(" tipo_cuenta=");xtraFilter.append(tipoCuenta);
	}

	  sbSql = new StringBuffer();
	   sbSep = new StringBuffer();
	   if(separador.trim().equals("P"))sbSep.append("CHR(124)");
	   else if(separador.trim().equals("T"))sbSep.append("CHR(9)");
	   else if(separador.trim().equals("C"))sbSep.append("CHR(44)"); 
	   
	  sbSql.append(" select   consecutivo||");
	  sbSql.append(sbSep);
	  sbSql.append("||num_cuenta||");
	  sbSql.append(sbSep);
	  sbSql.append("||replace (replace (translate(replace (replace (desc_cuenta, 'Ñ', 'N'), ',', ' '),'ÁÉÍÓÚ','AEIOU'),'?','%'),',',' ')||");
	  sbSql.append(sbSep);  
	  sbSql.append("||sum(debito)||");
	  sbSql.append(sbSep);
	  sbSql.append("||sum(credito)||");
	  sbSql.append(sbSep);
	  sbSql.append("||sum(total)|| "); 
	  sbSql.append(sbSep);
	  sbSql.append("||(select sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito_c from tbl_con_detalle_comprob dc where dc.consecutivo =x.consecutivo and dc.ano = x.anio and dc.compania=x.compania and dc.tipo =1 and dc.reg_type = 'D' and dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6=x.no_cta)|| ");
	   sbSql.append(sbSep);
	    sbSql.append("||(select  sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito_c from tbl_con_detalle_comprob dc where dc.consecutivo =x.consecutivo and dc.ano = x.anio and dc.compania=x.compania and dc.tipo =1 and dc.reg_type = 'D' and dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6=x.no_cta ) ");
	  sbSql.append(" as texto");
	    
	   sbSql.append(", '' as num_tarjeta,consecutivo,num_cuenta,desc_cuenta,no_cta  from ( select at.consecutivo, (select num_cuenta from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) as num_cuenta, (select descripcion from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) desc_cuenta ,nvl(others2,(select descripcion from tbl_con_clases_comprob where codigo_comprob =at.codigo_comprob and tipo='C')) desc_comprob , (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =at.codigo_comprob and tipo='C')as tipo_doc,replace(at.id_doc,'|','-') as id_doc , to_char(at.fecha_doc ,'dd/mm/yyyy') as fecha,'A' creado_por, to_char(at.fecha_doc,'dd/mm/yyyy') as fecha_trx,at.lado,sum(decode(at.lado,'DB',at.monto,0)) as debito,sum(decode(at.lado,'CR',at.monto,0)) as credito,(sum(decode(at.lado,'DB',at.monto,0)) - sum(decode(at.lado,'CR',at.monto,0))) as total,at.fecha_doc ,at.compania,ec.ea_ano as anio,ec.mes,at.num_cuenta as no_cta,at.others3,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal from tbl_con_encab_comprob ec,tbl_con_aud_transaccional at where  ec.consecutivo =at.consecutivo and ec.ea_ano = at.anio_comprob and ec.compania=at.compania and ec.tipo=1 and ec.reg_type ='D' and ec.compania = ");
	  sbSql.append(cdo.getColValue("compania"));

sbSql.append(" and ec.status = 'AP' AND ec.estado = 'A' and  ec.clase_comprob not in (select column_value  from table( select split((select get_sec_comp_param(ec.compania,'AUD_EXCLU_COMPROB') from dual),',') from dual  )) ");
sbSql.append(sbFilter);
sbSql.append(" group by at.others3, at.num_cuenta,at.compania,at.codigo_comprob,at.consecutivo,replace(at.id_doc,'|','-') ,to_char(at.fecha_doc,'dd/mm/yyyy'),at.lado,at.fecha_doc,others2,ec.mes,ec.ea_ano,ec.tipo,ec.reg_type ");
sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C') desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'M', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Manuales' ,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal  from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='D' and ec.creado_por <> 'SP' group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6");
sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')||' - HIST' desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'H', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Manuales' ,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal  from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='H' group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6");

sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C') desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'M', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Costos',(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='D' and  ec.clase_comprob in (select column_value  from table( select split((select get_sec_comp_param(ec.compania,'AUD_EXCLU_COMPROB') from dual),',') from dual  )) group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6");

sbSql.append("  )x  ");
sbSql.append(xtraFilter);
sbSql.append(" group by consecutivo,num_cuenta,desc_cuenta,no_cta,x.anio,x.compania order by no_cta asc, consecutivo asc");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ARCHIVO TXT PARA AUDITORIA RESUMIDA "; 
}
else if (docType.equalsIgnoreCase("AUDTRX2"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.conta").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId")); 
	cdo.addColValue("fecha_desde",fDesde);
	cdo.addColValue("fecha_hasta",fHasta); 
	cdo.addColValue("noCuenta",""+noCuenta);
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("name","aud_trx_"+cdo.getColValue("fecha_desde").replace("/","")+"_"+cdo.getColValue("fecha_hasta").replace("/",""));
	cdo.addColValue("docPath","conta"); 
	cdo.addColValue("vista","CCC");
	
	if(fDesde != null && !fDesde.trim().equals("")){ sbFilter.append(" and trunc(ec.fecha_comp) >= to_date('");sbFilter.append(fDesde);sbFilter.append("','dd/mm/yyyy')");}
	if(fHasta != null && !fHasta.trim().equals("")){ sbFilter.append(" and trunc(ec.fecha_comp) <= to_date('");sbFilter.append(fHasta);sbFilter.append("','dd/mm/yyyy')");}
	if(!tipoComprob.trim().equals("")){ sbFilter.append(" and ec.clase_comprob =");sbFilter.append(tipoComprob);}
	if(pMes13.trim().equals("S"))
	{  
	    sbFilter.append(" and ec.mes =13");
	    if(pRegManual.trim().equals("S")) sbFilter.append(" and ec.creado_por = 'RCM' ");
	}
	if(noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0")){ xtraFilter.append(" where no_cta like '%");xtraFilter.append(noCuenta);xtraFilter.append("%'");}
	if(cuentaPrincipal != null && !cuentaPrincipal.trim().equals("")&& !cuentaPrincipal.trim().equals("0"))
	{ 
		if(noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0"))xtraFilter.append(" and ");
		else xtraFilter.append(" where ");
		
		xtraFilter.append(" cuenta_principal=");xtraFilter.append(cuentaPrincipal);
	}
	if(tipoCuenta != null && !tipoCuenta.trim().equals("")&& !tipoCuenta.trim().equals("0"))
	{ 
		if((noCuenta != null && !noCuenta.trim().equals("")&& !noCuenta.trim().equals("0"))|| (cuentaPrincipal != null && !cuentaPrincipal.trim().equals("")&& !cuentaPrincipal.trim().equals("0")))xtraFilter.append(" and ");
		else xtraFilter.append(" where ");
		
		xtraFilter.append(" tipo_cuenta=");xtraFilter.append(tipoCuenta);
	}

	  sbSql = new StringBuffer();
	   sbSep = new StringBuffer();
	   if(separador.trim().equals("P"))sbSep.append("CHR(124)");
	   else if(separador.trim().equals("T"))sbSep.append("CHR(9)");
	   else if(separador.trim().equals("C"))sbSep.append("CHR(44)");
	  if(showHeader.trim().equals("S")){  
      sbSql.append(" select   '- Transaccional por Cuenta Auditoria - Archivo (Detallado) TXT -'||");	  
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");	//  numcta
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||"); 
	  sbSql.append(sbSep);
	  sbSql.append("||null||");//fecha_sistema
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");//status
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);	  
	  sbSql.append("||null|| "); // 
	  sbSql.append(sbSep);	
	  sbSql.append("||null|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||null|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||null|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||null|| ");
	  sbSql.append(sbSep);	
	  sbSql.append("||''|| ");
	  sbSql.append(sbSep);	
	  sbSql.append("||null|| ");//
	  sbSql.append(sbSep);	
	  if(colDebCre.trim().equals("S")){
	  sbSql.append("||null||");	
	  sbSql.append(sbSep);	
	  sbSql.append("||null  ");	}
	  else sbSql.append("||null  ");	  
	  sbSql.append("  as texto,null as no_cta, '' as num_tarjeta, null as fecha_doc,rownum , 1 as ord from dual  ");  
	  
	  sbSql.append(" union all  ");
	  sbSql.append(" select   'consecutivo'||");	  
	  sbSql.append(sbSep);
	  sbSql.append("||'compania'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'blanco_01'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'numcta'||");	//  numcta
	  sbSql.append(sbSep);
	  sbSql.append("||'anio'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'mes'||"); 
	  sbSql.append(sbSep);
	  sbSql.append("||'fecha_sistema'||");//fecha_sistema
	  sbSql.append(sbSep);
	  sbSql.append("||'hora ing'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'fec conta'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'status'||");//status
	  sbSql.append(sbSep);
	  sbSql.append("||'consecutivo'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'codigo_comprob'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'flag_generado_sistema'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'id_doc'||");
	  sbSql.append(sbSep);	  
	  sbSql.append("||'desc_comprob'|| "); // 
	  sbSql.append(sbSep);	
	  sbSql.append("||'usuing'|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||'usuapr'|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||'blanco_02'|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||'blanco_03'|| ");
	  sbSql.append(sbSep);	
	  sbSql.append("||'blanco_04'|| ");
	  sbSql.append(sbSep);	
	  sbSql.append("||'lado'|| ");//
	  sbSql.append(sbSep);	
	  if(colDebCre.trim().equals("S")){
	  sbSql.append("||'Deb'||");	
	  sbSql.append(sbSep);	
	  sbSql.append("||'Cred'  ");	}
	  else sbSql.append("||'Monto' ");	  
	  sbSql.append("  as texto,null as no_cta, '' as num_tarjeta, null as fecha_doc,rownum , 2 as ord from dual  ");  
	  sbSql.append(" union all  ");
	  sbSql.append(" select   'Numero consecutivo del comprobante'||");	  
	  sbSql.append(sbSep);
	  sbSql.append("||'compania'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Espacio para comentarios'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Número de Cuenta'||");	//  numcta
	  sbSql.append(sbSep);
	  sbSql.append("||'Anio'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Mes'||"); 
	  sbSql.append(sbSep);
	  sbSql.append("||'fecha del registro en sistema'||");//fecha_sistema
	  sbSql.append(sbSep);
	  sbSql.append("||'Hora de registro'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Fecha contabilidad'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Estatus Aprobado'||");//status
	  sbSql.append(sbSep);
	  sbSql.append("||'Consecutivo del Comprobante'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Codigo del comprobante'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Valor generado por sistema'||");
	  sbSql.append(sbSep);
	  sbSql.append("||'Id del Documento'||");
	  sbSql.append(sbSep);	   
	  sbSql.append("||'Descripcion del comprobante'|| "); // 
	  sbSql.append(sbSep);	
	  sbSql.append("||'Usuario que realizo el registro'|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||'Usuario que lo aprobo.'|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||'-'|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||'-'|| ");
	  sbSql.append(sbSep);	
	  sbSql.append("||'-'|| ");
	  sbSql.append(sbSep);	
	  sbSql.append("||'Lado del Mov.'|| ");//
	  sbSql.append(sbSep);	
	  if(colDebCre.trim().equals("S")){
	  sbSql.append("||'Monto Debito'||");	
	  sbSql.append(sbSep);	
	  sbSql.append("||'Monto Credito' ");	}
	  else sbSql.append("||'Monto' ");	  
	  sbSql.append("  as texto,null as no_cta, '' as num_tarjeta, null as fecha_doc,rownum , 3 as ord from dual  ");  
	  sbSql.append(" union all  ");	  
	  }
	  
	  sbSql.append(" select consecutivo||");
	  sbSql.append(sbSep);
	  sbSql.append("||compania||");
	  sbSql.append(sbSep);
	  sbSql.append("||null||");
	  sbSql.append(sbSep);
	  sbSql.append("||replace(no_cta,'.','-')||");	//  numcta
	  sbSql.append(sbSep);
	  sbSql.append("||anio||");
	  sbSql.append(sbSep);
	  sbSql.append("||mes||"); 
	  sbSql.append(sbSep);
	  sbSql.append("||fecing||");//fecha_sistema
	  sbSql.append(sbSep);
	  sbSql.append("||horing||");
	  sbSql.append(sbSep);
	  sbSql.append("||feccon||");
	  sbSql.append(sbSep);
	  sbSql.append("||'AP'||");//status
	  sbSql.append(sbSep);
	  sbSql.append("||consecutivo||");
	  sbSql.append(sbSep);
	  sbSql.append("||codigo_comprob||");
	  sbSql.append(sbSep);
	  sbSql.append("||'real'||");
	  sbSql.append(sbSep);
	  sbSql.append("||id_doc||");//descripcion - desmvt
	  sbSql.append(sbSep);	  
	  sbSql.append("||desc_comprob|| "); // 
	  sbSql.append(sbSep);	
	  sbSql.append("||usuing|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||usuapr|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||null|| "); 
	  sbSql.append(sbSep);	
	  sbSql.append("||null|| ");//codrev
	  sbSql.append(sbSep);	
	  sbSql.append("||''|| ");//codmon
	  sbSql.append(sbSep);	
	  sbSql.append("||lado|| ");//debcre
	  sbSql.append(sbSep);	
	  if(colDebCre.trim().equals("S")){
	  sbSql.append("||decode(lado,'DB',debito,0)||");	
	  sbSql.append(sbSep);	
	  sbSql.append("||decode(lado,'CR',credito,0)  ");	}
	  else sbSql.append("||decode(lado,'DB',debito,credito)  ");	 
	   System.out.println("colDebCre =="+colDebCre);
	  sbSql.append("  as texto"); 
	  
	   sbSql.append(" ,no_cta, '' as num_tarjeta, fecha_doc,rownum,5 ord from ( select at.consecutivo, (select num_cuenta from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) as num_cuenta, (select descripcion from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) desc_cuenta ,nvl(others2,(select descripcion from tbl_con_clases_comprob where codigo_comprob =at.codigo_comprob and tipo='C')) desc_comprob , (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =at.codigo_comprob and tipo='C')as tipo_doc,replace(at.id_doc,'|','-') as id_doc , to_char(at.fecha_doc ,'dd/mm/yyyy') as fecha,'A' creado_por, to_char(at.fecha_doc,'dd/mm/yyyy') as fecha_trx,at.lado,sum(decode(at.lado,'DB',at.monto,0)) as debito,sum(decode(at.lado,'CR',at.monto,0)) as credito,(sum(decode(at.lado,'DB',at.monto,0)) - sum(decode(at.lado,'CR',at.monto,0))) as total,at.fecha_doc ,at.compania,ec.ea_ano as anio,ec.mes,at.num_cuenta as no_cta,at.others3,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6=at.num_cuenta and cg.compania=at.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal,to_char (ec.fecha_sistema, 'mm/dd/yyyy') as fecing,to_char (ec.fecha_sistema, 'hh:mi:ss am') horing,to_char (ec.fecha_comp, 'dd/mm/yyyy') as feccon,at.codigo_comprob,nvl(at.usuario_trx,ec.usuario_creacion) as usuing,ec.usuario_aprob as usuapr from tbl_con_encab_comprob ec,tbl_con_aud_transaccional at where  ec.consecutivo =at.consecutivo and ec.ea_ano = at.anio_comprob and ec.compania=at.compania and ec.tipo=1 and ec.reg_type ='D' and ec.compania = ");
	  sbSql.append(cdo.getColValue("compania"));

sbSql.append(" and ec.status = 'AP' AND ec.estado = 'A' and  ec.clase_comprob not in (select column_value  from table( select split((select get_sec_comp_param(ec.compania,'AUD_EXCLU_COMPROB') from dual),',') from dual  )) ");
sbSql.append(sbFilter);
sbSql.append(" group by at.others3,at.num_cuenta,at.compania,at.codigo_comprob,at.consecutivo,replace(at.id_doc,'|','-'),to_char(at.fecha_doc,'dd/mm/yyyy'),at.lado,at.fecha_doc,others2,ec.mes, ec.ea_ano,to_char (ec.fecha_sistema,'mm/dd/yyyy'),to_char(ec.fecha_sistema, 'hh:mi:ss am'),to_char(ec.fecha_comp, 'dd/mm/yyyy'),nvl(at.usuario_trx,ec.usuario_creacion) ,ec.usuario_aprob");


sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C') desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'M', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Manuales' ,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal,to_char(ec.fecha_sistema, 'mm/dd/yyyy') as fecing,to_char (ec.fecha_sistema, 'hh:mi:ss am') horing,to_char (ec.fecha_comp, 'dd/mm/yyyy') as feccon,ec.clase_comprob,ec.usuario_creacion as usuing,ec.usuario_aprob as usuapr  from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='D' and ec.creado_por <> 'SP' group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6, to_char(ec.fecha_sistema, 'mm/dd/yyyy'),to_char (ec.fecha_sistema, 'hh:mi:ss am'),to_char (ec.fecha_comp, 'dd/mm/yyyy'),ec.usuario_creacion,ec.usuario_aprob ");

sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')||' - HIST' desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'H', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Historicos' ,(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal,to_char(ec.fecha_sistema, 'mm/dd/yyyy') as fecing,to_char (ec.fecha_sistema, 'hh:mi:ss am') horing,to_char (ec.fecha_comp, 'dd/mm/yyyy') as feccon,ec.clase_comprob,ec.usuario_creacion as usuing,ec.usuario_aprob as usuapr  from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='H' group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6, to_char(ec.fecha_sistema, 'mm/dd/yyyy'),to_char (ec.fecha_sistema, 'hh:mi:ss am'),to_char (ec.fecha_comp, 'dd/mm/yyyy'),ec.usuario_creacion,ec.usuario_aprob ");

sbSql.append(" union all ");
sbSql.append(" select ec.consecutivo, dc.num_cuenta, (select descripcion from tbl_con_catalogo_gral where num_cuenta=dc.num_cuenta and compania=dc.compania) desc_cuenta,(select descripcion from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C') desc_comprob, (select tipo_trx from tbl_con_clases_comprob where codigo_comprob =ec.clase_comprob and tipo='C')as tipo_doc, ec.ea_ano||'-'||ec.consecutivo as doc_id, to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha,'M', to_char(ec.fecha_comp,'dd/mm/yyyy') as fecha_trx, dc.tipo_mov as lado,sum(decode(dc.tipo_mov,'DB',dc.valor,0)) as debito,sum(decode(dc.tipo_mov,'CR',dc.valor,0)) as credito,(sum(decode(dc.tipo_mov,'DB',dc.valor,0)) -sum(decode(dc.tipo_mov,'CR',dc.valor,0))) as total,ec.fecha_comp,dc.compania,ec.ea_ano,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6,'Comprobantes Costos',(select tipo_cuenta from tbl_con_catalogo_gral cg where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania) as tipo_cuenta,(select xx.codigo_prin from tbl_con_catalogo_gral cg,tbl_con_cla_ctas xx  where cg.num_cuenta=dc.num_cuenta and cg.compania=dc.compania and cg.tipo_cuenta = xx.codigo_clase ) as cuenta_principal,to_char(ec.fecha_sistema, 'mm/dd/yyyy') as fecing,to_char (ec.fecha_sistema, 'hh:mi:ss am') horing,to_char (ec.fecha_comp, 'dd/mm/yyyy') as feccon,ec.clase_comprob,ec.usuario_creacion as usuing,ec.usuario_aprob as usuapr from tbl_con_encab_comprob ec,tbl_con_detalle_comprob dc where ec.consecutivo =dc.consecutivo and ec.ea_ano = dc.ano and ec.compania=dc.compania and ec.tipo =dc.tipo and ec.reg_type = dc.reg_type and ec.compania = ");
sbSql.append(cdo.getColValue("compania"));
sbSql.append(" AND ec.status = 'AP' AND ec.estado = 'A'");
sbSql.append(sbFilter);
sbSql.append(" and ec.tipo=1 and ec.reg_type ='D' and  ec.clase_comprob in (select column_value  from table( select split((select get_sec_comp_param(ec.compania,'AUD_EXCLU_COMPROB') from dual),',') from dual  )) group by ec.consecutivo,dc.num_cuenta,dc.compania ,ec.clase_comprob ,dc.tipo_mov, to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.creado_por,ec.ea_ano,ec.fecha_comp,ec.mes,dc.cta1||'.'||dc.cta2||'.'||dc.cta3||'.'||dc.cta4||'.'||dc.cta5||'.'||dc.cta6, to_char(ec.fecha_sistema,'mm/dd/yyyy'),to_char(ec.fecha_sistema,'hh:mi:ss am'),to_char(ec.fecha_comp,'dd/mm/yyyy'),ec.usuario_creacion,ec.usuario_aprob");

sbSql.append("  )x  ");
sbSql.append(xtraFilter);
sbSql.append(" order by 6, 2 asc, 4 asc");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ARCHIVO TXT PARA AUDITORIA"; 
}
else if (docType.equalsIgnoreCase("MEF72")||docType.equalsIgnoreCase("MEF94"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.conta").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId")); 
	cdo.addColValue("fecha_desde",fDesde);
	cdo.addColValue("fecha_hasta",fHasta);  
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("name",docType+"_"+cdo.getColValue("fecha_desde").replace("/","")+"_"+cdo.getColValue("fecha_hasta").replace("/",""));
	cdo.addColValue("docPath","conta"); 
	cdo.addColValue("vista","CCC");
	
	if(fDesde != null && !fDesde.trim().equals("")){ sbFilter.append(" and trunc(a.fecha_doc) >= to_date('");sbFilter.append(fDesde);sbFilter.append("','dd/mm/yyyy')");}
	if(fHasta != null && !fHasta.trim().equals("")){ sbFilter.append(" and trunc(a.fecha_doc) <= to_date('");sbFilter.append(fHasta);sbFilter.append("','dd/mm/yyyy')");}
	 
	  sbSql = new StringBuffer();
	   sbSep = new StringBuffer();
	   if(separador.trim().equals("P"))sbSep.append("CHR(124)");
	   else if(separador.trim().equals("T"))sbSep.append("CHR(9)");
	   else if(separador.trim().equals("C"))sbSep.append("CHR(44)");
	   
	   //tbl_con_aud_transaccional
	  sbSql.append(" select nvl(to_char(tipo_persona),' ')||");
	  sbSql.append(sbSep);
	  sbSql.append("||rpad(nvl(ruc,' '),20,' ')||");
	  sbSql.append(sbSep);
	  sbSql.append("||lpad(nvl(lpad(dv,2,0),' '),2,' ')||");
	  sbSql.append(sbSep);
	  sbSql.append("||rPAD(rpad(substr(nvl(rtrim(others2),' '),0,100),100,' '),100,' ')||");
	  sbSql.append(sbSep);	  
	  sbSql.append("||2||");
	  sbSql.append(sbSep);
	  sbSql.append("||a.concepto||");
	  sbSql.append(sbSep);
	  sbSql.append("||LPAD (trim(TO_CHAR (sum(monto), '99999999.90')), 13,' ')||");
	  sbSql.append(sbSep);
	  sbSql.append("||nvl(a.periodo,1) as texto,rPAD(rpad(substr(nvl(rtrim(others2),' '),0,100),100,' '),100,' ') as nombre ");
	  sbSql.append(" from ( select coalesce(c.tipo_persona,a.tipo_persona,(select pr.tipo_persona from tbl_com_proveedor pr where trim(pr.ruc)=trim(nvl(c.ruc,a.ruc)) and rownum=1)) tipo_persona,nvl(c.ruc,a.ruc) ruc,to_char(nvl(c.dv,a.dv),'fm09') dv,decode(a.tipo_trx,'CO-PAC','COSTO INVENTARIO PACIENTE','ENT-UND','ENTREGA UNIDADES','DEV-UND','DEVOLUCION UNIDADES',trim(others2)) as others2,a.periodo, sum(decode(a.lado,'DB',monto,'CR',-monto))  as monto,");
	  if(docType.trim().equals("MEF72")) sbSql.append(" b.cod_72 "); 
	  else sbSql.append(" b.cod_94 "); 
 sbSql.append(" as concepto from tbl_con_aud_transaccional a , tbl_con_catalogo_anexomef b,(select a.id,decode(b.tipo_orden,2,(select pr.ruc from tbl_com_proveedor pr where pr.compania=b.cod_compania and pr.cod_provedor=b.cod_proveedor),b.ruc) as ruc,b.cod_proveedor,decode(b.tipo_orden,2,(select pr.digito_verificador from tbl_com_proveedor pr where pr.compania=b.cod_compania and pr.cod_provedor=b.cod_proveedor),b.dv) as dv,decode(b.tipo_orden,2,(select pr.tipo_persona from tbl_com_proveedor pr where pr.compania=b.cod_compania and pr.cod_provedor=b.cod_proveedor),a.tipo_persona) as tipo_persona from tbl_con_aud_transaccional a,tbl_con_cheque b where  a.compania =");
 sbSql.append(cdo.getColValue("compania"));
 sbSql.append(sbFilter);
 sbSql.append(" and tipo_trx in ('CK','CKAN') and a.compania=b.cod_compania and b.cod_banco||'-'||b.cuenta_banco||'- CK:'||b.num_cheque=replace(a.id_doc,'CK-AN','CK')) c where a.id=c.id(+) and a.num_cuenta = b.cta1||'.'||b.cta2||'.'||b.cta3||'.'||b.cta4||'.'||b.cta5||'.'||b.cta6 and a.compania=b.compania and a.compania =");
 sbSql.append(cdo.getColValue("compania"));
 sbSql.append(sbFilter);
 if(docType.trim().equals("MEF72")) sbSql.append(" and b.cod_72  is not null "); 
 else sbSql.append(" and b.cod_94 is not null ");  
 if(pExcluyeCheque.trim().equals("S")) sbSql.append(" and a.tipo_trx not in ('CK','CKAN') "); 
 
sbSql.append(" group by a.tipo_persona,a.ruc,a.dv,c.tipo_persona,c.ruc,c.dv,trim(others2),a.periodo,TIPO_TRX ");
 if(docType.trim().equals("MEF72")) sbSql.append(" ,b.cod_72"); 
 else sbSql.append(" , b.cod_94 ");  
sbSql.append(" )a having sum(monto) <> 0 group by nvl(to_char(tipo_persona),' '),rpad(nvl(ruc,' '),20,' ') ,lpad(nvl(lpad(dv,2,0),' '),2,' '),rPAD(rpad(substr(nvl(rtrim(others2),' '),0,100),100,' '),100,' '),1,a.concepto,nvl(a.periodo,1) order by 2 "); 
	   
	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ARCHIVO TXT INFORME "+(docType.trim().equals("MEF72")?" 72 ":" 94 ")+" MEF "; 
}
else if (docType.equalsIgnoreCase("ASEGFILE"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.files_aseg").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("fg","ASEGFILE"+aseguradora);
	cdo.addColValue("name","FILE"+aseguradora);
	cdo.addColValue("vista","CCC");
	cdo.addColValue("aseguradora",aseguradora);
	cdo.addColValue("id",id);
	cdo.addColValue("docPath","files_aseg");
	cdo.addColValue("lineaBlanco","N");
	cdo.addColValue("fileDet","S");
	cdo.addColValue("nameAddTime","N");
	
	  sbSql = new StringBuffer();
	  sbSql.append("select campo1,campo2||admision as campo2,campo3,campo4,campo5,campo6,campo7,campo8,campo9,campo10,campo11,campo12,campo13,campo14||pac_id||admision as campo14 from vw_fac_file_aseg where compania=");
	  sbSql.append(cdo.getColValue("compania"));
	  sbSql.append(" and aseguradora =");
	  sbSql.append(cdo.getColValue("aseguradora"));
	  sbSql.append(" and id =");
	  sbSql.append(cdo.getColValue("id"));
	  sbSql.append(" order by pac_id");

	fileName = FPMgr.createFileAsegDet(cdo,sbSql.toString(),false,false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ARCHIVO PARA ASEGURADORA";
}
else if (docType.equalsIgnoreCase("ANEXO03"))
{
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.planilla").replace(ResourceBundle.getBundle("path").getString("root"),"");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId")); 
	cdo.addColValue("anio",""+anio); 
	cdo.addColValue("fg","ANEXO03");
	cdo.addColValue("name","ANEXO03_"+anio);
	cdo.addColValue("vista","CCC");

	  sbSql = new StringBuffer();
	  sbSql.append("select 'Planilla 03' as texto from dual union all  select  case when nvl(x.impuesto_causado,0) <> 0 then 2 else 1 end ||");
	  sbSql.append(sbSep);
	  sbSql.append("||x.tipo_id||");
	  sbSql.append(sbSep);
	  sbSql.append("||nvl(x.pasaporte,x.cedula)||"); 
	  sbSql.append(sbSep);
	  sbSql.append("||x.dv||"); 
	  sbSql.append(sbSep);
	  sbSql.append("||x.nombre_emp||"); //5
	  sbSql.append(sbSep);
	  sbSql.append("||x.tipo_renta||");//6
	  sbSql.append(sbSep);
	  //sbSql.append("||x.num_dependiente||");
	  //sbSql.append(sbSep);
	  sbSql.append("||x.v_periodos||");//7
	  sbSql.append(sbSep);
	  sbSql.append("||x.total_ingresos||");//8
	  sbSql.append(sbSep);
	  sbSql.append("||x.salario_especie||");//9
	  sbSql.append(sbSep);
	  sbSql.append("||x.g_representacion||");//10
	  sbSql.append(sbSep);
	  sbSql.append("||x.ingreso_sin_ret||");//11
	  sbSql.append(sbSep);
	  sbSql.append("||0||");//12
	  //sbSql.append(sbSep);
	  //sbSql.append("||x.seg_educativo||");
	  sbSql.append(sbSep);
	  sbSql.append("||x.intereses_hipotecarios||");//13
	  sbSql.append(sbSep);
	  sbSql.append("||x.intereses_educativos||");//14
	  sbSql.append(sbSep);
	  sbSql.append("||x.primas_seguro||");//15
	  sbSql.append(sbSep);
	  sbSql.append("||x.fondo_jubilacion||");//16
	  sbSql.append(sbSep);
	  sbSql.append("||(nvl(x.deducciones_dep,0)+nvl(x.seg_educativo,0)+nvl(x.intereses_hipotecarios,0)+nvl(x.intereses_educativos,0)+ nvl(x.primas_seguro,0)+nvl(x.fondo_jubilacion,0))||");//17
	  sbSql.append(sbSep);
	  sbSql.append("||(nvl(x.total_ingresos,0)+nvl(x.salario_especie,0)+nvl(x.g_representacion,0)+nvl(x.ingreso_sin_ret,0) )||");//18
	  sbSql.append(sbSep);
	  sbSql.append("||x.impuesto_causado||");//crear funcion para imp_causado 19
	  sbSql.append(sbSep);
	  sbSql.append("||x.ajuste_imp_causado||");//20
	  //sbSql.append(sbSep);
	  //sbSql.append("||x.extension_ley||");
	  sbSql.append(sbSep);
	  sbSql.append("||x.imp_renta||");//21
	  sbSql.append(sbSep);
	  sbSql.append("||x.imp_renta_gasto||");//22
	  sbSql.append(sbSep);
	  //sbSql.append("||x.ajuste_a_favor_emp||");
	  sbSql.append("||x.imp_renta||");//23
	  //sbSql.append(sbSep);
	  //sbSql.append("||(x.imp_renta+x.imp_renta_gasto + ajuste_a_favor_emp)||"); 
	  sbSql.append(sbSep);
	  sbSql.append("|| case when (x.impuesto_causado - (x.imp_renta+x.imp_renta_gasto + ajuste_a_favor_emp)) < 0 then 0 else  (x.impuesto_causado - (x.imp_renta+x.imp_renta_gasto + ajuste_a_favor_emp)) end  ||"); //a favor del fisco
	   sbSql.append(sbSep);
	   sbSql.append("|| case when (x.impuesto_causado - (x.imp_renta+x.imp_renta_gasto + ajuste_a_favor_emp)) < 0 then -1 * (x.impuesto_causado - (x.imp_renta+x.imp_renta_gasto + ajuste_a_favor_emp)) else 0 end as texto"); //a favor del Empleado
	  
	sbSql.append("   from ( ");
	  
	  sbSql.append(" SELECT z.*, CASE WHEN ROUND (NVL (z.periodos, 0) / 2, 0) > 12 THEN 12 WHEN ROUND (NVL (z.periodos, 0) / 2, 0) = 0 THEN 1 ELSE ROUND (NVL (z.periodos, 0) / 2, 0) END v_periodos, z.sal_bruto total_ingresos, /*z.sal_bruto + g_representacion total_ingresos,*/ NVL (z.pago_base, 0) + NVL (z.num_dependiente, 0) * NVL (z.valor_dependiente, 0) deducciones_dep, DECODE ( SIGN( (z.sal_bruto + g_representacion) - (NVL (z.pago_base, 0) + NVL (z.num_dependiente, 0) * NVL (z.valor_dependiente, 0))), -1, 0, ( (z.sal_bruto + g_representacion) - (NVL (z.pago_base, 0) + NVL (z.num_dependiente, 0) * NVL (z.valor_dependiente, 0))) ) tot_ingresos, /*CASE WHEN ROUND (NVL (z.periodos, 0) / 2, 0) >= 12 THEN*/ getimpuestosisr ( 0, z.gr_porc_no_renta, z.gr_limite_no_renta, DECODE ( SIGN( (z.sal_bruto) - (NVL (z.pago_base, 0) + NVL (z.num_dependiente, 0) * NVL (z.valor_dependiente, 0))), -1, 0, ( (z.sal_bruto) - (NVL (z.pago_base, 0) + NVL (z.num_dependiente, 0) * NVL (z.valor_dependiente, 0))) ), 'S', 'N' ) + getimpuestosisr ( 0, z.gr_porc_no_renta, z.gr_limite_no_renta, DECODE (SIGN ( (z.g_representacion)), -1, 0, NVL (z.g_representacion, 0)), 'G', 'N' ) /* ELSE 0 END*/ /* se comenta por que se agrega gasto rep case when round(nvl(z.periodos,0)/2,0) >= 12 then getimpuestosisr(0,z.gr_porc_no_renta,z.gr_limite_no_renta,decode(sign((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) + nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))),-1,0,((z.sal_bruto + g_representacion)- (nvl(z.pago_base,0) + nvl(z.num_dependiente,0) * nvl(z.valor_dependiente,0))) ) ,'S','N') else 0 end */ impuesto_causado /******************/ , 0 ingreso_sin_ret , 0 intereses_hipotecarios , 0 intereses_educativos , 0 primas_seguro , 0 fondo_jubilacion , 0 ajuste_a_favor_emp /******************/,0 ajuste_imp_causado,0 extension_ley FROM (");
	  
	  sbSql.append(" SELECT ALL e.ubic_depto, e.ubic_seccion, DECODE (e.provincia, 0, '', 00, '', 11, 'B', 12, 'C', e.provincia) || decode(DECODE (e.sigla, '00', '', '0', '', e.sigla),null,'','-'||decode(e.sigla, '00', '','0', '',e.sigla)) || '-' || TO_CHAR (e.tomo) || '-' || TO_CHAR (e.asiento) cedula, translate(REPLACE(REPLACE(e.nombre_empleado,'Ñ','N'),',',' '),'ÁÉÍÓÚ','AEIOU') nombre_emp, DECODE (NVL (e.gasto_rep, 0), 0, 'N', 'S') declarante,cr.codigo_dgi as tipo_renta, NVL (e.num_dependiente, 0) num_dependiente, DECODE (e.digito_verificador, NULL, ' ', LPAD (e.digito_verificador, 2, '0')) dv, a.anio, e.fecha_ingreso, NVL (p.valor_dependiente, 0) valor_dependiente, NVL (p.gr_porc_no_renta, 0) gr_porc_no_renta, NVL (p.gr_limite_no_renta, 0) gr_limite_no_renta, SUM( ( NVL (a.sal_bruto, 0) + NVL (a.salario_especie, 0) + NVL (a.prima_produccion, 0) - NVL (a.indemnizacion, 0) - NVL (a.prima_antiguedad, 0) - NVL (a.preaviso, 0))) sal_bruto, SUM (NVL (a.g_representacion, 0)) g_representacion, SUM (NVL (a.salario_especie,0)) salario_especie, SUM( ( NVL (a.sal_bruto, 0) + NVL (a.g_representacion, 0) - NVL (a.indemnizacion, 0) - NVL (a.prima_antiguedad, 0) - NVL (a.preaviso, 0))) ingresos, SUM (NVL (a.imp_renta, 0)) imp_renta, 0 seg_educativo, SUM (NVL (a.periodos, 0)) periodos, NVL (cr.pago_base, 0) pago_base ,sum (nvl(a.imp_renta_gasto,0)) imp_renta_gasto,case when e.pasaporte is null then 1 else 2 end as tipo_id,e.pasaporte  FROM tbl_pla_acumulado_empleado a, vw_pla_empleado e, tbl_pla_parametros p, tbl_pla_temporal_emp te, tbl_pla_clave_renta cr WHERE e.compania = ");
	 sbSql.append(cdo.getColValue("compania"));
	  
	  sbSql.append(" AND e.emp_id = a.emp_id AND a.emp_id = te.emp_id AND a.num_empleado = te.num_empleado AND a.cod_compania = te.cod_compania AND te.escoger = 'S' AND e.compania = a.cod_compania AND p.cod_compania = e.compania AND a.anio =");
	  sbSql.append(cdo.getColValue("anio"));
	  
	    sbSql.append(" /** OPTIONAL FILTERS **/ AND a.sal_bruto > 0 AND e.tipo_renta = cr.clave(+) GROUP BY e.ubic_depto, e.ubic_seccion, DECODE (e.provincia, 0, '', 00, '', 11, 'B', 12, 'C', e.provincia) || decode(DECODE (e.sigla, '00', '', '0', '', e.sigla),null,'','-'||decode(e.sigla, '00', '','0', '',e.sigla)) || '-' || TO_CHAR (e.tomo) || '-' || TO_CHAR (e.asiento), e.nombre_empleado, DECODE (NVL (e.gasto_rep, 0), 0, 'N', 'S'), cr.codigo_dgi, NVL (e.num_dependiente, 0), DECODE (e.digito_verificador, NULL, ' ', LPAD (e.digito_verificador, 2, '0')), a.anio, e.fecha_ingreso, NVL (p.valor_dependiente, 0), NVL (p.gr_porc_no_renta, 0), NVL (p.gr_limite_no_renta, 0), NVL (cr.pago_base, 0) ,case when e.pasaporte is null then 1 else 2 end,e.pasaporte,e.num_dependiente HAVING SUM( ( NVL (a.sal_bruto, 0) + NVL (a.salario_especie, 0) + NVL (a.prima_produccion, 0) - NVL (a.indemnizacion, 0) - NVL (a.prima_antiguedad, 0) - NVL (a.preaviso, 0))) + SUM (NVL (a.g_representacion, 0)) > 0 ORDER BY e.ubic_depto, e.ubic_seccion, DECODE (e.provincia, 0, '', 00, '', 11, 'B', 12, 'C', e.provincia) || decode(DECODE (e.sigla, '00', '', '0', '', e.sigla),null,'','-'||decode(e.sigla, '00', '','0', '',e.sigla)) || '-' || TO_CHAR (e.tomo) || '-' || TO_CHAR (e.asiento), e.nombre_empleado ) z ");
		
		
		sbSql.append(" ) x ");
		if(fisco.trim().equals("S"))sbSql.append(" where (impuesto_causado <> imp_renta) ");
	  
	   


	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "ANEXO 03 DGI";
}
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Generar Archivo - '+document.title;
<%
if (docType.equalsIgnoreCase("ACHPROV")){
%>
function viewComprobante(){
	<%if(cdo.getColValue("tipo").equals("5")){%>
	abrir_ventana1('../cxp/print_comprobantes_hsf.jsp?id_lote=<%=id_lote%>&tipo_pago=<%=tipoPago%>&tipo_orden=<%=tipo_orden%>&agrupa_hon=<%=agrupa_hon%>&tipo=<%=cdo.getColValue("tipo")%>');
	<%} else {%>
	abrir_ventana1('../cxp/print_comprobantes.jsp?id_lote=<%=id_lote%>&tipo_pago=<%=tipoPago%>');
	<%}%>
}
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("tipoCuenta",tipoCuenta)%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("banco",banco)%>
<%=fb.hidden("fDesde",fDesde)%>
<%=fb.hidden("fHasta",fHasta)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("fechaPago",fechaPago)%>
<%=fb.hidden("trimestre",trimestre)%>
<%=fb.hidden("codReporte",codReporte)%>
<%=fb.hidden("codPlanilla",codPlanilla)%>
<%=fb.hidden("noPlanilla",noPlanilla)%>
<%=fb.hidden("nombreRuta",nombreRuta)%>
<%=fb.hidden("vista",vista)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("colDebCre",colDebCre)%>
<%=fb.hidden("showHeader",showHeader)%>
<%=fb.hidden("pExcluyeCheque",pExcluyeCheque)%>

		<tr class="TextHeader" align="center">
			<td><cellbytelabel>ARCHIVO GENERADO</cellbytelabel> <%=docDesc%></td>
		</tr>
		<%if (!docType.equalsIgnoreCase("ASEGFILE")){%>
		<tr class="TextRow01">
			<td align="center"><cellbytelabel>Para descargar el archivo haga</cellbytelabel> <a href="<%=request.getContextPath()%><%=docPath%>/<%=fileName%>" class="Link00"><cellbytelabel>click aqu&iacute;</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>)</td>
		</tr>	
		<%}%>
<%if (docType.equalsIgnoreCase("ACHPROV")){%>		
		<tr class="TextRow01">
			<td align="center"><cellbytelabel><a href="javascript:viewComprobante();" class="Link00">IMPRIMIR COMPROBANTES DE PAGO</a></cellbytelabel></td>
		</tr>
<%}%>
		<tr class="TextHeader" align="center">
			<td align="center">
				<%=fb.button("cancel","Cancelar",false,false,"Text10",null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
		</tr>
<%=fb.formEnd()%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
%>