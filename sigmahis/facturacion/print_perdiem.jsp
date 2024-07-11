<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
String appendFilter = request.getParameter("appendFilter");
StringBuffer sbSql = new StringBuffer();
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

sbSql.append("select z.pac_id, z.admi_secuencia as admision, to_char(z.fecha,'dd/mm/yyyy') as fecha, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' DE '||apellido_de_casada)) from tbl_adm_paciente where pac_id = z.pac_id) as nombre, nvl((select sum(decode(tipo_transaccion,'D',-cantidad,cantidad) * (monto + nvl(recargo,0))) from tbl_fac_detalle_transaccion where pac_id = z.pac_id and fac_secuencia = z.admi_secuencia),0) as monto_cargo, sum(z.grang_total) as monto_factura, sum(z.monto_descuento) as monto_descuento, nvl(sum((select sum(decode(lado_mov,'D',monto,-monto)) from vw_con_adjustment_gral a where compania = z.compania and factura = z.codigo and not exists (select null from tbl_fac_tipo_ajuste where compania = z.compania and group_type in ('E') and codigo = a.tipo_ajuste))),0) as monto_ajuste, nvl(sum((select sum(a.monto_aplicado - a.monto_cubierto) from tbl_fac_limit_det a where exists (select null from tbl_fac_limit where id = a.id and pac_id = z.pac_id and admision = z.admi_secuencia and factura = z.codigo and compania = z.compania))),0) as monto_perdiem from tbl_fac_factura z where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(appendFilter);
sbSql.append("and facturar_a <> 'O' and estatus <> 'A' group by z.pac_id, z.admi_secuencia, z.fecha order by 3, 4");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "PERDIEM";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".26");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Pac. ID",1);
		pc.addBorderCols("Admisión",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Monto Cargos",1);
		pc.addBorderCols("Monto Fact.",1);
		pc.addBorderCols("Descuentos",1);
		pc.addBorderCols("Ajustes",1);
		pc.addBorderCols("PERDIEM",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	double tc = 0.0, tf = 0.0, td = 0.0, ta = 0.0, tp = 0.0;
	for (int i=0; i<al.size(); i++) {
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		tc += Double.parseDouble(cdo.getColValue("monto_cargo"));
		tf += Double.parseDouble(cdo.getColValue("monto_factura"));
		td += Double.parseDouble(cdo.getColValue("monto_descuento"));
		ta += Double.parseDouble(cdo.getColValue("monto_ajuste"));
		tp += Double.parseDouble(cdo.getColValue("monto_perdiem"));

		pc.setFont(8,0);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(cdo.getColValue("pac_id"),2,1);
		pc.addCols(cdo.getColValue("admision"),2,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cargo")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_factura")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_descuento")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_ajuste")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_perdiem")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
		pc.setFont(8,1);
		pc.addCols("T O T A L E S",2,4);
		pc.addCols(CmnMgr.getFormattedDecimal(tc),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tf),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(td),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(ta),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(tp),2,1);

		pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>