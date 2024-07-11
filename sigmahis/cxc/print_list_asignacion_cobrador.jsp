<%@ page errorPage="../error.jsp"%>
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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String docType = request.getParameter("docType");
String cobrador = request.getParameter("cobrador");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if (docType == null) docType = "";
if (cobrador == null) cobrador = "";

sbSql = new StringBuffer();
if (docType.trim().equals("") || docType.equalsIgnoreCase("F"))
{
	sbSql.append("select 'F' as doc_type, a.fecha, a.codigo, 0 as anio, to_char(a.fecha,'dd/mm/yyyy') as doc_date, decode(a.cobrador,null,' ',(select nombre_cobrador from tbl_cxc_cobrador where codigo = a.cobrador and compania = a.compania)) as cobrador, decode(a.tipo_cobro,null,' ',(select descripcion from tbl_cxc_tipo_analista where tipo = a.tipo_cobro)) as tipo_cobro, nvl(to_char(a.fecha_asignacion,'dd/mm/yyyy'),' ') as fecha_asignacion, nvl(b.nombre_paciente,' ') as paciente from tbl_fac_factura a, vw_adm_paciente b where a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if (!cobrador.trim().equals("")) { sbSql.append(" and a.cobrador = "); sbSql.append(cobrador); }
	sbSql.append(" and a.pac_id = b.pac_id(+)");
	sbSql.append(" and a.facturar_a <> 'O' and a.estatus <> 'A' ");
	sbSql.append(appendFilter);
}
sbSql.append(" order by 2 desc");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String title = "CUENTAS POR COBRAR";
	String subtitle = "ASIGNACION DE COBRADOR A FACTURA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".09");
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".26");
		dHeader.addElement(".21");
		dHeader.addElement(".18");
		dHeader.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Tipo Doc.",1);
		pc.addBorderCols("No. Doc.",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Paciente",1);
		pc.addBorderCols("Cobrador",1);
		pc.addBorderCols("Tipo Cobro",1);
		pc.addBorderCols("Fecha Asigna",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String type = "FACTURA";
		if (cdo.getColValue("doc_type").equalsIgnoreCase("R")) type = "REMANENTE";

		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(type,1,1);
		pc.addCols(cdo.getColValue("codigo"),1,1);
		pc.addCols(cdo.getColValue("doc_date"),1,1);
		pc.addCols(cdo.getColValue("paciente"),0,1);
		pc.addCols(cdo.getColValue("cobrador"),0,1);
		pc.addCols(cdo.getColValue("tipo_cobro"),0,1);
		pc.addCols(cdo.getColValue("fecha_asignacion"),1,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>