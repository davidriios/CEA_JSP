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
String banco = request.getParameter("banco");
String fDesde = request.getParameter("fDesde");
String fHasta = request.getParameter("fHasta");
String tipo = request.getParameter("tipo");
String vista = request.getParameter("vista");
String tipoPago = request.getParameter("tipoPago");
String no_lista = request.getParameter("no_lista");
String rehacer = request.getParameter("rehacer");
String id_lote="";
String separador = "";
String inTrx = "N";

if (fp == null) fp = "";
if (docType == null) docType = "";
if (fecha == null) fecha = "";
if (banco == null) banco = "";
if (fDesde == null) fDesde = "";
if (fHasta == null) fHasta = "";
if (tipo == null) tipo = "";
if (vista == null) vista = "";
if (tipoPago == null) tipoPago = "";
if (no_lista == null) no_lista = "";
if (rehacer == null) rehacer = "N";

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

String docDesc = "";
if (docType.equalsIgnoreCase("ACHTC"))
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


	sbSql.append("select nvl(to_number(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CXP_ACH_TXT_LN_SIZE_");
	sbSql.append(cdo.getColValue("vista").toUpperCase());
	sbSql.append("')),0) as lineSize from dual");
	int lnSize = CmnMgr.getCount(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select (case b.tipo when 'T' then '\"1\"'");
		sbSql.append("||chr(9)||'\"@num_tarjeta\"'");
		sbSql.append("||chr(9)||'\"'||to_char(b.fecha_vence,'yymm')||'\"'");
		sbSql.append("||chr(9)||'\"'||getpmmontoach_tc(a.id,'"); sbSql.append((tipo.equals("C"))?"ACH":"TC"); sbSql.append("')||'\"'");
		sbSql.append("||chr(9)||'\"0.00\"'");
		sbSql.append("||chr(9)||'\"'||to_char(sysdate,'dd/mm/yyyy')||'\"'");
		sbSql.append("||chr(9)||'\"          \"'");
		sbSql.append("||chr(9)||'\"'||(select nombre_paciente_ach from vw_pm_cliente c where c.codigo = a.id_cliente)||'\"'");
		sbSql.append("||chr(9)||'\"'||a.id||'\"'");
	sbSql.append(" when 'C' then (select rpad(substr(replace(replace(id_paciente,'-D',''),'-',''),1,18),18,' ')");
		sbSql.append("||rpad(substr(nombre_paciente_ach,1,40),40,' ') from vw_pm_cliente c where c.codigo = a.id_cliente)");
		sbSql.append("||'@num_tarjeta'");
		sbSql.append("||substr(lpad(b.cod_banco,10,'0'),1,10)");
		sbSql.append("||lpad(replace(trim(to_char(");
		if(rehacer.equals("S")){
			sbSql.append("getpmmontoach_tc_x_rt(a.id,'"); sbSql.append((tipo.equals("C"))?"ACH":"TC"); sbSql.append("', ");
			sbSql.append(no_lista);
			sbSql.append(")");
		} else{
			sbSql.append("getpmmontoach_tc(a.id,'"); sbSql.append((tipo.equals("C"))?"ACH":"TC"); sbSql.append("')");
		}
		sbSql.append(",'000000000000.00')),'.',''),14,'0')");
		sbSql.append("||b.tipo_tarjeta");
		sbSql.append("||rpad(a.id,40,' ')");
	sbSql.append(" else '' end) as texto");
	sbSql.append(", b.num_tarjeta_cta num_tarjeta, a.id, a.id_cliente from tbl_pm_solicitud_contrato a, tbl_pm_cta_tarjeta b where a.id = b.id_solicitud and b.estado = 'A' and a.estado = 'A' and exists (select null from tbl_pm_regtran r, tbl_pm_regtran_det rd where r.id = rd.id");
	if(rehacer.equals("S")){
		sbSql.append(" and r.estado = 'A' and rd.estado = 'A' and r.id = ");sbSql.append(no_lista);
	} else sbSql.append(" and r.estado = 'P' and rd.estado = 'P'");
	sbSql.append(" and r.tipo_trx = '");
	if(tipo.equals("C")) sbSql.append("ACH");
	else if(tipo.equals("T")) sbSql.append("TC");
	sbSql.append("' and a.id = rd.id_contrato)");
	sbSql.append(" and b.tipo = '");
	sbSql.append(tipo);
	sbSql.append("' and a.fecha_ini_plan <= ");

	sbSql.append("to_date('");
	sbSql.append(cdo.getColValue("fecha_hasta"));
	sbSql.append("', 'dd/mm/yyyy')");
	if(tipo.equals("T")){
	//sbSql.append(" and b.fecha_vence > trunc(sysdate)");
	}
	sbSql.append(" and b.fecha_inicio <= to_date('");
	sbSql.append(cdo.getColValue("fecha_hasta"));
	sbSql.append("', 'dd/mm/yyyy') order by a.id desc, a.id_cliente");
	System.out.println("sql.........."+sbSql.toString());
	cdoHeader = SQLMgr.getData(sbSql.toString());
	if(cdoHeader == null) throw new Exception("No existen registros para generar archivo!.");
	//if(tipo.equals("T"))cdo.addColValue("text_header", "107");

	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
	docDesc = "CXP - ACH ";

	CommonDataObject param = new CommonDataObject();
	if(!rehacer.equals("S")){
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
	}
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
} else if(docType.equalsIgnoreCase("SUPERINTEN")){
	FPMgr.setConnection(ConMgr);
	docPath = ResourceBundle.getBundle("path").getString("docs.superinten").replace(ResourceBundle.getBundle("path").getString("root"),"");
	cdo.addColValue("docPath","superinten");
	cdo.addColValue("fg",""+docType);
	cdo.addColValue("tipo",tipo);
	cdo.addColValue("vista","");
	cdo.addColValue("name",CmnMgr.getCurrentDate("ddmmyyyy")+cdo.getColValue("tipo")+"_");
	if(tipo.equals("C")){
		cdo.addColValue("text_header", "ANO|MES|IDENASEG|NUMPOL|NUMCERT|STSASEG|TIPOASEG|FECNAC|SEXO|INICIO_VIG|FINAL_VIG|FECVIG|OCUPACION|Prima Anual|Prima Suscrita|LIMPOL|LIM_CONS|EDAD|Deducible_local|DEDUCIBLEEXT|MAX_DES|FECEMI|CODPLAN|DESCPLAN|Fecexc|Fecanul|tipo_pol");
		sbSql.append("/*select 'AÑO|MES|IDENASEG|NUMPOL|NUMCERT|STSASEG|TIPOASEG|FECNAC|SEXO|INICIO_VIG|FINAL_VIG|FECVIG|OCUPACION|Prima Anual|Prima Suscrita|LIMPOL|LIM_CONS|EDAD|Deducible_local|DEDUCIBLEEXT|MAX_DES|FECEMI|CODPLAN|DESCPLAN|Fecexc|Fecanul' texto from dual union*/ select c.anio || '|' || c.mes || '|' || (select id_paciente from vw_pm_cliente pc where codigo = d.id_beneficiario) || '|' || lpad (c.id, 10, '0') || '|' || (select max(no_contrato) from tbl_pm_sol_contrato_det where id_solicitud = d.id_sol_contrato and id_cliente = d.id_beneficiario) || '|' || (case when exists (select null from tbl_pm_sol_contrato_det cd where cd.id_solicitud = d.id_sol_contrato and cd.estado = 'A' and cd.id_cliente = d.id_beneficiario) then 'ACTIVO' else 'INACTIVO' end) || '|' || (case when tipo = 'R' then 'RESPONSABLE' else 'BENEFICIARIO' end) || '|' || (select to_char (fecha_nacimiento, 'dd/mm/yyyy') from tbl_pm_cliente where codigo = d.id_beneficiario) || '|' || (select decode (sexo, 'M', 'MASCULINO', 'FEMENIFO') from tbl_pm_cliente where codigo = d.id_beneficiario) || '|' || (select substr((select to_char (max(cd.fecha_inicio), 'dd/mm/yyyy') from tbl_pm_sol_contrato_det cd where cd.id_solicitud = d.id_sol_contrato and cd.id_cliente = d.id_beneficiario), 1, 6) || ");
        sbSql.append(fDesde.substring(6, 10));
        sbSql.append(" from dual) || '|' || (select to_char(add_months(to_date(substr((select to_char (max(cd.fecha_inicio), 'dd/mm/yyyy') from tbl_pm_sol_contrato_det cd where cd.id_solicitud = d.id_sol_contrato and cd.id_cliente = d.id_beneficiario), 1, 6) || ");
        sbSql.append(fDesde.substring(6, 10));
        sbSql.append(", 'dd/mm/yyyy'), 12), 'dd/mm/yyyy') from dual) || '|' || '' || '|' || (select puesto_que_ocupa from tbl_pm_cliente where codigo = d.id_beneficiario) || '|' || (d.sub_total * 12) || '|' || d.sub_total || '|' || nvl ((select max(cd.limite_anual) from tbl_pm_sol_contrato_det cd where cd.id_solicitud = d.id_sol_contrato and cd.id_cliente = d.id_beneficiario), 500000) || '|' || nvl((select sum(nvl(lr.gastos_farmacia, 0)+nvl(lr.gastos_medicos, 0)-nvl(l.copago, 0)) from tbl_pm_liquidacion_reclamo l, (select dr.compania, dr.secuencia, dr.fac_codigo_paciente, sum (case when to_char (centro_servicio) = get_sec_comp_param (dr.compania, 'CDS_FAR') then cantidad * monto else 0 end) gastos_farmacia, sum (case when to_char (centro_servicio) != get_sec_comp_param (dr.compania, 'CDS_FAR') then cantidad * monto else 0 end) gastos_medicos from tbl_pm_det_liq_reclamo dr group by dr.compania, dr.secuencia, dr.fac_codigo_paciente) lr where l.status not in ('N', 'R') and l.compania = lr.compania and l.codigo = lr.secuencia and l.admi_codigo_paciente = lr.fac_codigo_paciente and l.poliza = to_char(id_sol_contrato) and l.admi_codigo_paciente = d.id_beneficiario and l.fecha_creacion between to_date('01/01/");
        sbSql.append(fHasta.substring(6, 10));
        sbSql.append("', 'dd/mm/yyyy') and to_date('");
        sbSql.append(fHasta);
        sbSql.append("', 'dd/mm/yyyy')), 0) || '|' || (select replace(get_age(fecha_nacimiento, to_date('");
        sbSql.append(fHasta);
        sbSql.append("','dd/mm/yyyy'), 'y'), 'y', '') from vw_pm_cliente where codigo = d.id_beneficiario) || '|' || '0' || '|' || '0' || '|' || '0' || '|' || c.fecha_ini_plan || '|' || c.afiliados || '|' || decode (c.afiliados, 1, 'PLAN FAMILIAR', 'PLAN TERCERA EDAD') || '|' || (select to_char (max(cd.fecha_sale_contrato), 'dd/mm/yyyy') from tbl_pm_sol_contrato_det cd where cd.id_solicitud = d.id_sol_contrato and cd.id_cliente = d.id_beneficiario) || '|' || '' || '|COLECTIVA'  texto from (select id, afiliados, ");
        sbSql.append(fDesde.substring(6, 10));
        sbSql.append(" anio, to_char (fecha_ini_plan, 'mm') mes, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan from tbl_pm_solicitud_contrato ) c, (select distinct id_sol_contrato, id_beneficiario, (select sub_total from tbl_pm_factura_det fd where fd.estado = 'A' and fd.id_sol_contrato = d.id_sol_contrato and fd.id_beneficiario = d.id_beneficiario and to_char(fecha, 'mm/yyyy') = (select to_char(max(fecha), 'mm/yyyy') from tbl_pm_factura_det ff where ff.estado = 'A' and ff.id_sol_contrato = fd.id_sol_contrato and ff.id_beneficiario = fd.id_beneficiario and ff.fecha <= TO_DATE ('");
		sbSql.append(fHasta);
		sbSql.append("', 'dd/mm/yyyy'))) sub_total, tipo from tbl_pm_factura_det d WHERE d.estado = 'A' and d.fecha between to_date ('");
		sbSql.append(fDesde);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(fHasta);
		sbSql.append("', 'dd/mm/yyyy')) d where c.id = d.id_sol_contrato");
	} else if(tipo.equals("R")){
		cdo.addColValue("text_header", "ANO_PAG|MES_PAG|IDENASEG|NUMPOL|NUMCERT|CODPLAN|DESCPLAN|INICIO_VIG|FINAL_VIG|IDENSIN|IDENTRAM|STSSIN|STSTRAM|TIPO_ASEG|SEXO|EDADOCUR|FECOCUR|FECREC|FECPAG|TOTALFAC|NOCUB|DESC|DEDUCIBLE|COPAGO|COASEG|OTRONOCUB|PAGADO|RESERVA|FECINIHOS|FECFINHOS|DIASHOS|IND_BENEF|CODICD|DESCICDC|CODBENEF|DESBENEF|CODCOB|DESCOB|DESMAT|LUG_OCC|DESPAIS|DEDLOC|DEDEXT|TIPOPOL|DESCRIPCION|CENTROSERVICIO");
		sbSql.append("/*select 'ANO_PAG|MES_PAG|IDENASEG|NUMPOL|NUMCERT|CODPLAN|DESCPLAN|INICIO_VIG|FINAL_VIG|IDENSIN|IDENTRAM|TIPO_ASEG|SEXO|EDADOCUR|FECOCUR|FECREC|FECPAG|TOTALFAC|NOCUB|DESC|DEDUCIBLE|COPAGO|COASEG|OTRONOCUB|PAGADO|RESERVA|CODBENEF|DESBENEF|CODCOB|DESCOB|LUG_OCC|DESPAIS|DEDLOC|DEDEXT' texto from dual union*/ SELECT ");
        sbSql.append(fDesde.substring(6, 10));
        sbSql.append("||'|'||TO_CHAR (l.fecha_creacion, 'mm')||'|'||cedula_cliente||'|'||l.poliza||'|'||nvl(l.id_contrato,0)||'|'||(SELECT afiliados FROM tbl_pm_solicitud_contrato c WHERE TO_CHAR (c.id) = l.poliza)||'|'||(SELECT DECODE (afiliados, 1, 'PLAN FAMILIAR', 2, 'PLAN TERCERA EDAD') FROM tbl_pm_solicitud_contrato c WHERE TO_CHAR (c.id) = l.poliza)||'|'||(select substr((select to_char (max(cd.fecha_inicio), 'dd/mm/yyyy') from tbl_pm_sol_contrato_det cd where to_char (cd.id_solicitud) = l.poliza and cd.id_cliente = l.admi_codigo_paciente), 1, 6) || ");
        sbSql.append(fDesde.substring(6, 10));
        sbSql.append(" from dual)||'|'||(select to_char(add_months(to_date(substr((select to_char (max(cd.fecha_inicio), 'dd/mm/yyyy') from tbl_pm_sol_contrato_det cd where to_char (cd.id_solicitud) = l.poliza and cd.id_cliente = l.admi_codigo_paciente), 1, 6) || ");
        sbSql.append(fDesde.substring(6, 10));
        sbSql.append(", 'dd/mm/yyyy'), 12), 'dd/mm/yyyy') from dual)||'|'||l.no_aprob|| '|' || lpad(lr.centro_servicio, 4, '0')||lr.tipo_cargo || '|' || 'FINALIZADA' || '|' || '' || '|'||DECODE (nvl(l.id_contrato,0), 0, 'PRINCIPAL', 'DEPENDIENTE')||'|'||(SELECT DECODE (sexo,  'M', 'MASCULINO',  'F', 'FEMENINO') FROM tbl_pm_cliente WHERE codigo = l.admi_codigo_paciente)||'|'||(select replace(get_age(fecha_nacimiento, l.fecha_reclamo, 'y'), 'y', '') from vw_pm_cliente where codigo = l.admi_codigo_paciente)||'|'||TO_CHAR (l.fecha_reclamo, 'dd/mm/yyyy')||'|'||TO_CHAR (l.fecha_creacion, 'dd/mm/yyyy') ||'|'||TO_CHAR (l.fecha_creacion, 'dd/mm/yyyy')||'|'||(nvl(lr.gastos_farmacia, 0)+nvl(lr.gastos_medicos, 0))||'|'||0 ||'|'||0||'|'||0||'|'||round(decode(NVL (l.copago, 0), 0, 0, ((NVL (lr.gastos_farmacia, 0) + NVL (lr.gastos_medicos, 0)) * (NVL (l.copago, 0)/l.total_calculado*100 ))/100), 2)||'|'||0 ||'|'||0||'|'||(nvl(lr.gastos_farmacia, 0)+nvl(lr.gastos_medicos, 0)-(round(decode(NVL (l.copago, 0), 0, 0, ((NVL (lr.gastos_farmacia, 0) + NVL (lr.gastos_medicos, 0)) * (NVL (l.copago, 0)/l.total_calculado*100 ))/100), 2)))|| '|' || '' || '|' || to_char (l.fecha_ingreso, 'dd/mm/yyyy') || '|' || to_char (l.fecha_egreso, 'dd/mm/yyyy') || '|' || trunc (l.fecha_egreso-l.fecha_ingreso) ||'|' || decode(cat_reclamo, 'HO', 'HOSPITALIZACION', 'AMBULATORIO') || '|' || '' || '|' || '' || '|' ||(case when cat_reclamo = 'HO' then (case when hosp_si_no = 'S' then hosp_tipo_si else hosp_tipo_no end) else l.tipo_atencion end)||'|'||(case when cat_reclamo = 'HO' then (case when hosp_si_no = 'S' then decode(hosp_tipo_si, 1,'INCAPACIDAD', 2, 'NERVIOSA', 3, 'PARTO NORMAL', 4, 'CESAREA') else decode(hosp_tipo_no, 1, 'URGENCIA MEDICA', 2, 'LABORATORIO/RAYOS-X', 3, 'CIRUGIA AMBULATORIA', 4, 'URGENCIA POR ACCIDENTE', 5, 'RES. MAGNETICA / M.I.B.I.', 6, 'CAT. CARDIACO', 7, 'ANGIOPLASTIA', 8, 'ENDOSCOPIA/CISTOSCOPIA', 9,'INYECCION', 10, 'FISIOTERAPIA O INHALOTERAPIA', 11, 'PRUEBA DE ESFUERZO /HOLTER /ECO', 12, 'MAMOGRAFIA- CAMPIMETRIA', 13, 'DENSIT. OSEA', 14, 'URODINAMIA', 15, 'QUIMIO/RADIO/HEMODIALISIS', 16, 'MEDICINA NUCLEAR') end) else (select nombre from tbl_pm_liq_recl_tipo_atencion where codigo = l.tipo_atencion) end)||'|'||decode(l.cat_reclamo, 'CE', categoria, (case when hosp_si_no = 'S' and hosp_tipo_si in (3, 4) then 5 else categoria end))|| '|' || (case when cat_reclamo = 'HO' then (case when hosp_si_no = 'S' and hosp_tipo_si in (3, 4) then 'MATERNIDAD' else (select descripcion from tbl_adm_categoria_admision where codigo = l.categoria) end) else (select descripcion from tbl_adm_categoria_admision where codigo = l.categoria) end) || '|'||(case when cat_reclamo = 'HO' then (case when hosp_si_no = 'S' then decode (hosp_tipo_si, 3, 'PARTO NORMAL', 4, 'CESAREA', '') end) else decode(tipo_atencion, 3, 'PARTO', '') end)||'|'||'PANAMA'||'|'||0||'|'||0|| '||' || 'COLECTIVO' || '|' || lr.descripcion || '|' || (select descripcion from tbl_cds_centro_servicio where codigo=lr.centro_servicio and compania_unorg=l.compania) texto FROM (select l.*, (select sum(nvl(cantidad, 0)*nvl(monto, 0)) from tbl_pm_det_liq_reclamo z where z.compania = l.compania and z.secuencia = l.codigo) total_calculado from tbl_pm_liquidacion_reclamo l) l, (select dr.compania, dr.secuencia, dr.fac_codigo_paciente,dr.descripcion, dr.centro_servicio, dr.tipo_cargo, sum (case when to_char (centro_servicio) = get_sec_comp_param (dr.compania, 'CDS_FAR') then cantidad * monto else 0 end) gastos_farmacia, sum (case when to_char (centro_servicio) != get_sec_comp_param (dr.compania, 'CDS_FAR') then cantidad * monto else 0 end) gastos_medicos from tbl_pm_det_liq_reclamo dr group by dr.compania, dr.secuencia, dr.fac_codigo_paciente,dr.descripcion, dr.centro_servicio, dr.tipo_cargo) lr where l.status not in ('N', 'R') and l.compania = lr.compania and l.codigo = lr.secuencia and l.admi_codigo_paciente = lr.fac_codigo_paciente and l.fecha_creacion between to_date('");
		sbSql.append(fDesde);
		sbSql.append("', 'dd/mm/yyyy') and to_date('");
		sbSql.append(fHasta);
		sbSql.append("', 'dd/mm/yyyy') AND EXISTS (select null from tbl_pm_solicitud_contrato c, tbl_pm_sol_contrato_det dc where c.estado in ('A','F') and c.id = l.poliza and c.id = dc.id_solicitud /*and dc.estado = 'A'*/ and dc.id_cliente = lr.fac_codigo_paciente)");
	}
	fileName = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName == null) throw new Exception(FPMgr.getErrException());
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
	abrir_ventana1('../cxp/print_comprobantes.jsp?id_lote=<%=id_lote%>&tipo_pago=<%=tipoPago%>');
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
<%=fb.hidden("banco",banco)%>
<%=fb.hidden("fDesde",fDesde)%>
<%=fb.hidden("fHasta",fHasta)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("vista",vista)%>

		<tr class="TextHeader" align="center">
			<td><cellbytelabel>ARCHIVO GENERADO</cellbytelabel> <%=docDesc%></td>
		</tr>
		<tr class="TextRow01">
			<td align="center"><cellbytelabel>Para descargar el archivo haga</cellbytelabel> <a href="<%=request.getContextPath()%><%=docPath%>/<%=fileName%>" class="Link00"><cellbytelabel>click aqu&iacute;</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>)</td>
		</tr>
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