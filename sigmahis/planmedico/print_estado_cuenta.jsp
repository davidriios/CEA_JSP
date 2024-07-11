<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alBen = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String factura = request.getParameter("factura");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

boolean shortFormat = false, verFechaCrea = false;
if(request.getParameter("verFechaCrea")!=null && request.getParameter("verFechaCrea").equals("S")) verFechaCrea = true;
sbSql = new StringBuffer();
if (shortFormat) {

	StringBuffer sbUrl = new StringBuffer();
	sbUrl.append("../planmedico/print_estado_cuenta_det.jsp");
	response.sendRedirect(sbUrl.toString());
}
	String contrato = request.getParameter("contrato") == null?"":request.getParameter("contrato");
sbSql.append("select id_cliente from tbl_pm_solicitud_contrato where id = ");
sbSql.append(contrato);
CommonDataObject _ci = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
	String compId=(String) session.getAttribute("_companyId");
	String fg = request.getParameter("fg");
	String clientId = _ci.getColValue("id_cliente");//(request.getParameter("clientId")==null?"":request.getParameter("clientId"));
	String fechaIni = request.getParameter("fechaIni") == null?"":request.getParameter("fechaIni");
	String fechaFin = request.getParameter("fechaFin") == null?"":request.getParameter("fechaFin");
	String clientName = request.getParameter("clientName") == null?"":request.getParameter("clientName");
	String mostrar_fact_si = request.getParameter("mostrar_fact_si") == null?"S":request.getParameter("mostrar_fact_si");
	String showFactCancelSI = request.getParameter("showFactCancelSI") == null?"N":request.getParameter("showFactCancelSI");

	if (clientId.trim().equals("")) throw new Exception("clientId: Parámetro inválido. Contacte un administrador!");

	sbSql.append("select nvl(to_char((select min(least(fecha_ini_plan,fecha_creacion)) from tbl_pm_solicitud_contrato c where c.id_cliente = ");//toma la fecha min entre ambas
	sbSql.append(clientId);
	sbSql.append("),'dd/mm/yyyy'),'01/'||to_char(sysdate,'mm/yyyy')) as fecha_ini, to_char(sysdate,'dd/mm/yyyy') as fecha_fin from dual");

	CommonDataObject _si = SQLMgr.getData(sbSql.toString());

	if(fechaIni.equals("")) fechaIni = _si.getColValue("fecha_ini");
	if(fechaFin.equals("")) fechaFin = _si.getColValue("fecha_fin");

	sbSql = new StringBuffer();
	sbSql.append("select (select count (*) from (select distinct id_sol_contrato, anio, mes from tbl_pm_factura f where f.id_regtran is not null and f.estado = 'A') where id_sol_contrato = a.id) meses_pagados, /*(select anio || '-' || mes from (  select a.id_sol_contrato, a.anio, max (b.mes) mes from (select  id_sol_contrato, anio, mes, sum(monto) monto, sum(monto_apl_regtran) monto_apl_regtran from tbl_pm_factura where id_regtran is not null and estado = 'A' group by id_sol_contrato, anio, mes having sum(monto_apl_regtran) = sum(monto)) b, (select id_sol_contrato, max (anio) anio from tbl_pm_factura f where f.id_regtran is not null and monto_apl_regtran = monto and f.estado = 'A' group by id_sol_contrato) a where a.id_sol_contrato = b.id_sol_contrato and a.anio = b.anio group by a.id_sol_contrato, a.anio) x where x.id_sol_contrato = a.id)*/ getPagadoHasta(a.id) mes_ultimo_pago, lpad(a.id, 10, '0')||'-0' contrato, a.cuota_mensual, c.nombre_paciente, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, a.id, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, c.edad, decode(a.afiliados, 1, 'PLAN FAMILIAR', 2, 'PLAN TERCERA EDAD') tipo_plan, nvl((select 'PENALIZACION '||porcentaje||'%' from tbl_pm_cuota_extra x where x.id_solicitud = a.id and x.estado = 'F' and x.tipo_cuota = 'P' and x.id = (select max(id) from tbl_pm_cuota_extra xx where xx.estado = 'F' and xx.id_solicitud = a.id and xx.tipo_cuota = 'P')), '') penalizacion, decode(a.estado, 'A', 'APROBADO', 'F', 'FINALIZADO') estado_descJ, a.estado, nvl(num_pagos, 0) || ' - ' ||to_char(add_months(fecha_ini_plan, nvl(num_pagos, 0)-1), 'dd/mm/yyyy') fecha_ini_num_pagos from vw_pm_cliente c, tbl_pm_solicitud_contrato a where a.id_cliente = c.codigo and rownum = 1 and a.estado in ('A','F') and c.codigo = ");
	sbSql.append(clientId);
	if(contrato!=null){sbSql.append(" and a.id = ");sbSql.append(contrato);}

	CommonDataObject cdoH = SQLMgr.getData(sbSql.toString());
	if(contrato!=null) cdoH.addColValue("id", contrato);

	sbSql = new StringBuffer();
	sbSql.append("select no_contrato||' - '|| c.nombre_paciente as beneficiario, c.edad, to_char(z.fecha_inicio, 'dd/mm/yyyy') fecha_creacion, nvl((select descripcion from tbl_pla_parentesco where disponible_en_pm = 'S' and codigo != 0 and codigo = z.parentesco),'PRINCIPAL') || decode(z.estado, 'I', ' * Inactivo', '') as parentesco, z.costo_mensual as cuota, nvl(to_char(z.fecha_finaliza, 'dd/mm/yyyy'), 'MAL CUOTA') fecha_fin, z.estado from tbl_pm_sol_contrato_det z, vw_pm_cliente c where (z.estado = 'A'  or (z.estado = 'I' and nvl(fecha_sale_contrato, trunc(sysdate)+1) <= trunc(sysdate) and not exists (select null from tbl_pm_sol_contrato_det x where x.id_solicitud = z.id_solicitud and x.id_cliente = z.id_cliente and x.estado = 'A'))) and z.id_cliente = c.codigo and z.id_solicitud = ");
	sbSql.append(cdoH.getColValue("id"));
	sbSql.append(" order by no_contrato");
	alBen = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();

	sbSql.append("select nvl(sum(monto_fact)-sum(monto_trx), 0) saldo_inicial from (select monto monto_fact, 0 monto_trx from tbl_pm_factura where estado = 'A' and id_clie = ");
	sbSql.append(clientId);
	sbSql.append(" and compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(fecha) < to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
	}
	if(mostrar_fact_si.equals("N")) sbSql.append(" and nvl(observacion, 'NA') != 'S/I' ");
	sbSql.append(" union all ");
	sbSql.append(" select 0, monto_app monto_trx from tbl_pm_regtran_det where estado = 'A' and id_cliente = ");
	sbSql.append(clientId);
	sbSql.append(" and compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(fecha_creacion) < to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(" union all select 0, (nvl(b.debito, 0)-nvl(b.credito, 0)) from tbl_pm_ajuste a, tbl_pm_ajuste_det b where a.compania = b.compania and a.id = b.id and a.estado = 'A' and b.estado = 'A' and a.tipo_ben = 1 and a.id_referencia = '");
	sbSql.append(clientId);
	sbSql.append("' and a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.id_solicitud = ");
	sbSql.append(cdoH.getColValue("id"));
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(a.fecha_creacion) < to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(")");
	_si = new CommonDataObject();
	_si = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();

	sbSql.append("select 'FAC' doc, numero_factura fac_cod, ");
	if(showFactCancelSI.equals("S")){
		sbSql.append(" (case when cancela_saldo_ini = 'S' then '* ' else '' end) ||");
	}
	sbSql.append("'Cuota plan #'||f.id_sol_contrato||' para el mes de '|| trim(to_char(to_date('01/'||lpad(f.mes, 2, '0')||'/'||f.anio,'dd/mm/yyyy'), 'Month','NLS_DATE_LANGUAGE=SPANISH'))||' de '||f.anio fac_desc, f.anio, f.mes, to_char(f.fecha, 'dd/mm/yyyy') fecha_dsp, trunc(f.fecha) fecha, sum(f.monto) fac_monto, sum(0) pago_total, '' cod_pago, f.estado, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, nvl(cancela_saldo_ini, 'N') cancela_saldo_ini from tbl_pm_factura f where estado = 'A'");
	sbSql.append(" and f.id_clie = ");
	sbSql.append(clientId);
	sbSql.append(" and f.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and f.id_sol_contrato = ");
	sbSql.append(cdoH.getColValue("id"));
	if(mostrar_fact_si.equals("N")) sbSql.append(" and nvl(f.observacion, 'NA') != 'S/I' ");

	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(f.fecha) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(" group by 'FAC', numero_factura, ");
	if(showFactCancelSI.equals("S")){
		sbSql.append(" (case when cancela_saldo_ini = 'S' then '* ' else '' end) ||");
	}
	sbSql.append("'Cuota plan #'||f.id_sol_contrato||' para el mes de '|| trim(to_char(to_date('01/'||lpad(f.mes, 2, '0')||'/'||f.anio,'dd/mm/yyyy'), 'Month','NLS_DATE_LANGUAGE=SPANISH'))||' de '||f.anio, to_char(f.fecha, 'dd/mm/yyyy') , trunc(f.fecha) , 0, f.anio, f.mes, f.estado, to_char(fecha_creacion, 'dd/mm/yyyy'), nvl(cancela_saldo_ini, 'N')");

	sbSql.append(" union all ");
	sbSql.append("select 'PAG', (select join(cursor(select substr(id_fac, 1, 6) from tbl_pm_factura where id_regtran = r.id and estado = 'A' order by id_fac), ', ') from dual) fac_cod, (select 'PAGO Ref. '||join(cursor(select decode(a.fp_codigo,2,nvl(a.no_referencia,nvl(a.num_cheque,'')),a.no_referencia) as noReferencia from tbl_cja_trans_forma_pagos a where a.compania = tp.compania and a.tran_anio = tp.anio and a.tran_codigo = tp.codigo), ', ') from tbl_cja_transaccion_pago tp where tp.compania = r.compania and tp.anio = r.anio_ref and tp.codigo = r.id_ref), r.anio, r.mes, to_char(r.fecha_creacion, 'dd/mm/yyyy') fecha_dsp, (r.fecha_creacion) fecha, 0, sum(dr.monto), (select recibo from tbl_cja_transaccion_pago tp where tp.compania = r.compania and tp.anio = r.anio_ref and tp.codigo = r.id_ref) cod_pago, r.estado, to_char(r.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, 'N' cancela_saldo_ini from tbl_pm_regtran r, tbl_pm_regtran_det dr where r.estado = 'A' and r.id = dr.id and r.tipo_trx = 'RECIBO' and dr.id_cliente = ");
	sbSql.append(clientId);
	sbSql.append(" and r.compania = dr.compania and r.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and dr.id_contrato = ");
	sbSql.append(cdoH.getColValue("id"));
	sbSql.append("");

	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(r.fecha_creacion) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}

	sbSql.append(" group by 'PAG', r.compania, r.anio_ref, r.id_ref, r.id, 'PAGO', to_char(r.fecha_creacion, 'dd/mm/yyyy'), (r.fecha_creacion), 0, to_char(r.id_ref), r.anio, r.mes, r.estado, to_char(r.fecha_creacion, 'dd/mm/yyyy'), 'N'");
	sbSql.append(" union all ");
	sbSql.append("select decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL'), '' fac_cod, decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL')||(case when r.tipo_trx = 'M' then ' Com.: '|| nvl(dr.comentario, 'NA') || ' Ref.: ' || nvl(dr.referencia, 'NA') else '' end), r.anio, r.mes, to_char (r.fecha_creacion, 'dd/mm/yyyy') fecha_dsp,  (r.fecha_creacion) fecha, 0, sum (decode(dr.tipo_trx, 'M', dr.monto_app, dr.monto*dr.periodo)), to_char (r.id) cod_pago, r.estado, to_char(r.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, 'N' cancela_saldo_ini from tbl_pm_regtran r, tbl_pm_regtran_det dr where r.compania = dr.compania and r.id = dr.id and r.tipo_trx in ('ACH', 'TC', 'M') and (r.estado = 'A' or (r.estado = 'I' and fecha_anulacion is not null)) and dr.estado in ('A', 'I') and dr.id_cliente = ");
	sbSql.append(clientId);
	sbSql.append(" and r.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and dr.id_contrato = ");
	sbSql.append(cdoH.getColValue("id"));
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(r.fecha_creacion) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(" group by decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL'), '', decode(r.tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL')||(case when r.tipo_trx = 'M' then ' Com.: '|| nvl(dr.comentario, 'NA') || ' Ref.: ' || nvl(dr.referencia, 'NA') else '' end), to_char (r.fecha_creacion, 'dd/mm/yyyy'),  (r.fecha_creacion), 0, to_char (r.id), r.anio, r.mes, r.estado, to_char(r.fecha_creacion, 'dd/mm/yyyy'), 'N'");
	sbSql.append(" union all ");
	sbSql.append("select 'AJUSTE', '' fac_cod, 'AJUSTE '||decode(a.tipo_aju, 1, 'Descuento a Cuota', 2, 'Anular Pago', 3, 'Nota de Credito', 4, 'Nota de Credito CxP', 5, 'Nota de Debito')||' ['||(case when tipo_aju in (1, 3, 5) then 'Fact. ' || b.id_ref when tipo_aju = 4 then 'Pago. '||b.id_ref when tipo_aju = 2 then b.id_ref end) ||']' , to_number(to_char(a.fecha_creacion, 'yyyy')) anio, to_number(to_char(a.fecha_creacion, 'mm')) mes, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_dsp, a.fecha_creacion fecha, nvl(b.debito, 0), nvl(b.credito, 0), to_char(a.id), a.estado, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, 'N' cancela_saldo_ini from tbl_pm_ajuste a, tbl_pm_ajuste_det b where a.estado = 'A' and b.estado = 'A' and a.compania = b.compania and a.id = b.id and a.tipo_ben = 1 and a.id_referencia = '");
	sbSql.append(clientId);
	sbSql.append("'");
	sbSql.append(" and a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.id_solicitud = ");
	sbSql.append(cdoH.getColValue("id"));
	if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
		sbSql.append(" and trunc(a.fecha_creacion) between to_date('");
		sbSql.append(fechaIni);
		sbSql.append("','dd/mm/yyyy')");
		sbSql.append(" and to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy')");
	}
	sbSql.append(" order by 7, 2, 1, 4, 5 ");

	al = SQLMgr.getDataList(sbSql.toString());



if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);



	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";


	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ESTADO DE CUENTA"+(cdoH.getColValue("estado").equals("F")?"[FINALIZADO]":"");
	String subtitle = fechaIni+" - "+fechaFin;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".37");
		dHeader.addElement(".11");
		dHeader.addElement(".06");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
	Vector dDetail = new Vector();
		dDetail.addElement(".13");
		dDetail.addElement(".40");
		dDetail.addElement(".10");
		dDetail.addElement(".10");
		dDetail.addElement(".10");
		dDetail.addElement(".10");
		dDetail.addElement(".07");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable("header");
		pc.setFont(headerFontSize,1);
		pc.addBorderCols("No. Contrato:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoH.getColValue("contrato"),0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Responsable:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("["+clientId+"] "+cdoH.getColValue("nombre_paciente"),0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Pagado Hasta:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoH.getColValue("mes_ultimo_pago"),0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Fecha Ini.:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoH.getColValue("fecha_ini_plan"),0,1,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("Cuota:",0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoH.getColValue("cuota_mensual"))+" más Impuesto"/*+(!cdoH.getColValue("penalizacion").equals("")?"      "+cdoH.getColValue("penalizacion"):"")*/,0,2);
		pc.addCols(""/*cdoH.getColValue("fecha_ini_num_pagos")*/,0,1);
		pc.addCols("Plan:",0,1);
		pc.addCols(cdoH.getColValue("tipo_plan"),0,3);

		if (alBen.size() > 0) {
			pc.addCols(" ",1,1);
			pc.addBorderCols("Beneficiario",1,2);
			pc.addBorderCols("Parentesco",1,1);
			pc.addBorderCols("Cuota",1,1);
			pc.addBorderCols("Edad",1,1);
			pc.addBorderCols("Fecha Ini.",1,1);
			pc.addBorderCols("Cambio Cuota",1,1);
			for (int i=0; i<alBen.size(); i++) {
				CommonDataObject ben = (CommonDataObject) alBen.get(i);
				if(ben.getColValue("estado").equals("I")) pc.setFont(headerFontSize,1, Color.RED);
				else pc.setFont(headerFontSize,1);
				pc.addCols(" ",1,1);
				pc.addCols(ben.getColValue("beneficiario"),0,2);
				pc.addCols(ben.getColValue("parentesco"),0,1);
				pc.addCols(CmnMgr.getFormattedDecimal(ben.getColValue("cuota")),2,1);
				pc.addCols(ben.getColValue("edad"),1,1);
				pc.addCols(ben.getColValue("fecha_creacion"),0,1);
				pc.addCols(ben.getColValue("fecha_fin"),1,1);
			}
		}

	pc.setNoColumnFixWidth(dDetail);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetail.size());

		pc.addTableToCols("header",0,dDetail.size());

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("#Documento",1);
		pc.addBorderCols("Descripcion",1, 2);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Débito",1);
		pc.addBorderCols("Crédito",1);
		pc.addBorderCols("Saldo",1);
	pc.setTableHeader(3);
	//table body
	String groupBy = "";
	double saldo = Double.parseDouble(_si.getColValue("saldo_inicial"));
	pc.addCols("Saldo Inicial",2,6);
	pc.addCols(CmnMgr.getFormattedDecimal(_si.getColValue("saldo_inicial")),2,1);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if(showFactCancelSI.equals("S") && cdo.getColValue("cancela_saldo_ini").equals("S")) saldo = saldo;
		else saldo += Double.parseDouble(cdo.getColValue("fac_monto"))-Double.parseDouble(cdo.getColValue("pago_total"));

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		if(cdo.getColValue("estado").equals("I")){
			pc.resetFont();
			pc.setFont(contentFontSize, 0, Color.RED);
		}
		pc.addCols((cdo.getColValue("doc").equalsIgnoreCase("FAC")?cdo.getColValue("fac_cod"):cdo.getColValue("cod_pago")),1,1);
		pc.addCols(cdo.getColValue("fac_desc")+(cdo.getColValue("doc").equalsIgnoreCase("PAG")?"-Cuota.:"+cdo.getColValue("fac_cod")+" "+cdo.getColValue("cod_pago"):""),0,2);
		if(verFechaCrea) pc.addCols(cdo.getColValue("fecha_creacion"),1,1);
		else pc.addCols(cdo.getColValue("fecha_dsp"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("fac_monto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pago_total")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dDetail.size());
	pc.flushTableBody(true);
	pc.close();
	//response.sendRedirect(redirectFile);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function closeWindow(){window.close();}
function filtrarImpresion(tipoServ, fechaIni, fechaFin){
	window.location = '../planmedico/print_estado_cuenta.jsp?clientId=<%=clientId%>&clientName=<%=clientName%>&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&contrato=<%=contrato%>';
}
function buscar(){
var fechaIni = document.formPrinted.fechaIni.value;
var fechaFin = document.formPrinted.fechaFin.value;
var showFactCancelSI = document.formPrinted.showFactCancelSI.value;
var mostrar_fact_si = (document.formPrinted.mostrar_fact_si)?document.formPrinted.mostrar_fact_si.value:'S';
var verFechaCrea = (document.formPrinted.verFechaCrea)?document.formPrinted.verFechaCrea.value:'N';
window.location = '../planmedico/print_estado_cuenta.jsp?clientId=<%=clientId%>&clientName=<%=clientName%>&fechaIni='+fechaIni+'&fechaFin='+fechaFin+'&contrato=<%=contrato%>&mostrar_fact_si='+mostrar_fact_si+'&verFechaCrea='+verFechaCrea+'&showFactCancelSI='+showFactCancelSI;
}
function chkFechaHasta(){
	var x=1;
	if(document.formPrinted.edit_fecha_hasta) x=2;
	else {
		document.formPrinted.resetfechaFin.disabled=true;
		document.formPrinted.fechaFin.readOnly=true;
	}
}
</script>
</head>
<body onLoad="javascript:chkFechaHasta();">
<table width="100%" height="100%" cellpadding="5" cellspacing="0" align="center">
<%fb = new FormBean("formPrinted",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("contrato", contrato)%>
<authtype type='50'>
<%=fb.hidden("edit_fecha_hasta", "S")%>
</authtype>
<tr class="TextRow02">
	<td align="center" class="TableBorder">
		Fecha:
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="nameOfTBox1" value="fechaIni" />
		<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
		<jsp:param name="nameOfTBox2" value="fechaFin" />
		<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="buttonClass" value="Text10" />
		</jsp:include>
		<%//if(UserDet.getUserProfile().contains("0")){%>Mostrar Cuota Saldo Inicial
		<%=fb.select("mostrar_fact_si","S=Si,N=No","S",false,false,0,null,null,"")%>
		Mostrar Fecha Crea.?
		<%=fb.select("verFechaCrea","S=Si,N=No","N",false,false,0,null,null,"")%>
		<%//}%>
		Ver Fact. Canceladas S.I.
		<%=fb.select("showFactCancelSI","S=Si,N=No",showFactCancelSI,false,false,0,null,null,"")%>
		<%=fb.button("_filtrar","Filtrar",false,false,null,null,"onClick=\"javascript:buscar();\"")%>
		<%=fb.button("close","Cerrar",false,false,null,null,"onClick=\"javascript:window.close();\"")%>
	</td>
</tr>

<%=fb.formEnd(true)%>
</table>
<div class="dhtmlgoodies_aTab">
<iframe name="cargos_net" id="cargos_net" frameborder="0" align="center" width="100%" height="550" scrolling="no" src="<%=redirectFile%>"></iframe>
</div>
</body>
</html>
<%
}//GET
%>