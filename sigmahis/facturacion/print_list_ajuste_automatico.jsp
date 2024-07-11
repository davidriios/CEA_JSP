<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
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
CommonDataObject cdo = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");
String rechazadas =  request.getParameter("rechazadas");
String aseguradora =  request.getParameter("aseguradora");
String lista =  request.getParameter("lista");
String anio =  request.getParameter("anio");
String tipo_ajuste =  request.getParameter("tipo_ajuste");
String titulo =  request.getParameter("titulo");
if (rechazadas == null) rechazadas = "";
if (aseguradora == null) aseguradora = "";
if (lista == null) lista = "";
if (tipo_ajuste == null) tipo_ajuste = "";
if (anio == null) anio = "";
if (titulo == null) titulo = "";

if(fg==null) fg = "AFA";
if (appendFilter == null) appendFilter = "";


if (fg.equalsIgnoreCase("POS")) {

	sbSql.append("select distinct decode(a.facturar_a,'O',a.nombre_cliente,'E',(select nombre from tbl_adm_empresa where codigo = a.cod_empresa),(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, (select descripcion from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referDesc from tbl_fac_factura a where a.estatus <> 'A' and  a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" order by 1");

} else if(fg.equalsIgnoreCase("ajuste_automatico")){

	sbSql.append("select x.*,(case when nvl(saldo,0) > 0 then 'N' else 'S' end) puede_cancelar  from (select a.codigo as cod_factura, a.f_anio, a.numero_factura, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo, a.estatus, a.grang_total, a.admi_codigo_paciente as codigo, decode(a.facturar_a,'O',a.nombre_cliente,(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre,a.admi_secuencia, a.pac_id, a.cod_empresa, decode(a.facturar_a,'P','Paciente','E','Empresa','O','Otros') as tipo_factura, to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.admi_codigo_paciente, (select d.nombre from tbl_adm_empresa d where d.codigo = a.cod_empresa) as nombre_empresa, decode(a.estatus,'A','ANULADA','P','PENDIENTE','C','CANCELADA') as estatusDesc, a.lista, a.tipo_cobertura, a.compania, a.facturar_a, nvl((select count(*) from tbl_fac_dgi_documents where tipo_docto in ('FACP','FACT') and impreso = 'Y' and codigo = a.codigo),0) as facImpresa, nvl((select id from tbl_fac_dgi_documents where tipo_docto in('FACP','FACT') and codigo = a.codigo and rownum = 1),0) as ref_dgi, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, get_fac_pagos_fac(a.codigo, a.compania) pagado, fn_cja_saldo_fact(a.facturar_a, a.compania,a.codigo,a.grang_total) as saldo, nvl((select sum(monto) from tbl_cja_distribuir_pago  dp, tbl_cja_transaccion_pago tp  where dp.fac_codigo = a.codigo and dp.compania = a.compania and tp.codigo=dp.codigo_transaccion and tp.compania=dp.compania and tp.anio=dp.tran_anio and tp.rec_status <> 'I' ),0) as monto_dist, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = a.pac_id) as f_nac from tbl_fac_factura a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and exists (select null from tbl_cxc_cuentasm cm where cm.compania = a.compania and cm.factura = a.codigo and cm.lista = ");
	sbSql.append(lista);
	sbSql.append(" and cm.anio = ");
	sbSql.append(anio);
	sbSql.append(" and cm.tipo_ajuste = '");
	sbSql.append(tipo_ajuste);
	sbSql.append("' and cm.status != 'I')");
	sbSql.append(" and estatus <> 'A') x /*where monto_dist > 0 */");
	sbSql.append(" order by f_anio desc, numero_factura desc");

} 
else {

	sbSql.append("select x.*,(case when nvl(saldo,0) > 0 then 'N' else 'S' end) puede_cancelar  from (select a.codigo as cod_factura, a.f_anio, a.numero_factura, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo, a.estatus, a.grang_total, a.admi_codigo_paciente as codigo, decode(a.facturar_a,'O',a.nombre_cliente,(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombre,a.admi_secuencia, a.pac_id, a.cod_empresa, decode(a.facturar_a,'P','Paciente','E','Empresa','O','Otros') as tipo_factura, to_char(a.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.admi_codigo_paciente, (select d.nombre from tbl_adm_empresa d where d.codigo = a.cod_empresa) as nombre_empresa, decode(a.estatus,'A','ANULADA','P','PENDIENTE','C','CANCELADA') as estatusDesc, a.lista, a.tipo_cobertura, a.compania, a.facturar_a, nvl((select count(*) from tbl_fac_dgi_documents where tipo_docto in ('FACP','FACT') and impreso = 'Y' and codigo = a.codigo),0) as facImpresa, nvl((select id from tbl_fac_dgi_documents where tipo_docto in('FACP','FACT') and codigo = a.codigo and rownum = 1),0) as ref_dgi, a.cliente_otros as ref_type, cod_otro_cliente as ref_id, (select refer_to from tbl_fac_tipo_cliente where codigo = a.cliente_otros and compania = a.compania) as referTo, get_fac_pagos_fac(a.codigo, a.compania) pagado, fn_cja_saldo_fact(a.facturar_a, a.compania,a.codigo,a.grang_total) as saldo, nvl((select sum(monto) from tbl_cja_distribuir_pago  dp, tbl_cja_transaccion_pago tp  where dp.fac_codigo = a.codigo and dp.compania = a.compania and tp.codigo=dp.codigo_transaccion and tp.compania=dp.compania and tp.anio=dp.tran_anio and tp.rec_status <> 'I' ),0) as monto_dist, (select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id = a.pac_id) as f_nac from tbl_fac_factura a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	//sbSql.append(" and a.facturar_a in('E','P') ");
	sbSql.append(appendFilter);
	sbSql.append(" and estatus <> 'A' and facturar_a ='E') x where saldo > 0 ");
	if(rechazadas.trim().equals(""))sbSql.append(" and saldo < grang_total ");
	else sbSql.append(" and saldo = grang_total ");
	sbSql.append(" order by f_anio desc, numero_factura desc");

}
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	float footerHeight = 0.0f;//tamaño del footer
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = (fg.equals("ajuste_automatico")?"AJUSTE POR LOTE":"AJUSTES AUTOMATICOS");
	String subtitle = aseguradora+(fg.equals("ajuste_automatico") && !titulo.equals("")?titulo:"");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".07");
		dHeader.addElement(".22");
		dHeader.addElement(".05");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
		footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
		footer.setFont(9, 0);
		footer.setVAlignment(1);
		footer.addCols("APROBADO POR: _______________________________________",0,dHeader.size());

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("Factura",0);
		pc.addBorderCols("Tipo Fact.",1);
		pc.addBorderCols("Fecha Fact.",1);
		pc.addBorderCols("      No. Paciente",0);
		pc.addBorderCols("      No. Admisión",0);
		pc.addBorderCols("Fecha Nac.",1);
		pc.addBorderCols("Nombre",0);
		pc.addBorderCols("Lista",0);
		pc.addBorderCols("Monto",1);
		pc.addBorderCols("Pagado",0);
		pc.addBorderCols("Saldo",0);
		pc.addBorderCols("Dist.",0);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);

	double totMonto = 0.00, grang_total = 0.00, pagado = 0.00, saldo = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		boolean _continue = cdo.getColValue("monto_dist")!=null && !cdo.getColValue("monto_dist").equals("") && Double.parseDouble(cdo.getColValue("monto_dist")) > 0.0;
		pc.addCols(" "+cdo.getColValue("cod_factura"),0,1);
		pc.addCols(" "+cdo.getColValue("tipo_factura"),1,1);
		pc.addCols(" "+cdo.getColValue("fecha"),0,1);
		pc.addCols(" "+cdo.getColValue("admi_codigo_paciente"),1,1);
		pc.addCols(" "+cdo.getColValue("admi_secuencia"),1,1);
		pc.addCols(" "+cdo.getColValue("f_nac"),0,1);
		pc.addCols(" "+cdo.getColValue("nombre"),0,1);
		pc.addCols(" "+cdo.getColValue("lista"),0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("pagado")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);
		pc.addCols(" "+(_continue?"SI":"NO"),0,1);
		grang_total += Double.parseDouble(cdo.getColValue("grang_total"));
		pagado += Double.parseDouble(cdo.getColValue("pagado"));
		saldo += Double.parseDouble(cdo.getColValue("saldo"));
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
		pc.addBorderCols("Cant. Registros: "+al.size(),0,7, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(" Total:",2,1, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(grang_total),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(pagado),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(saldo),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(" ",0,1, 0.0f, 0.5f, 0.0f, 0.0f);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>