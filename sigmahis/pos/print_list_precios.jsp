<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>

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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String ref_id  = (request.getParameter("ref_id")==null?"":request.getParameter("ref_id"));
String refer_to = (request.getParameter("refer_to")==null?"":request.getParameter("refer_to"));

	CommonDataObject cdoQry = new CommonDataObject();
	StringBuffer sbQry = new StringBuffer();
	sbQry.append("select query from tbl_gen_query where id = 1 and refer_to = '");
	sbQry.append(refer_to);
	sbQry.append("'");
	cdoQry=SQLMgr.getData(sbQry.toString());

	/*sbSql.append("select a.compania, a.ref_id, a.ref_desc, a.refer_to, a.codigo, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, a.dv, nvl(b.id, 0) id, nvl(b.id_precio, 0) id_precio, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado, decode(b.id_precio, 1, 'NORMAL', 2, 'EJECUTIVO', 3, 'COLABORADOR', 4, 'PRECIO 4', 5, 'PRECIO 5', 6, 'PRECIO 6', 7, 'PRECIO 7', 8, 'PRECIO 8', '') id_precio_desc from vw_fac_otros_clientes a, tbl_clt_lista_precio b where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" and a.refer_to = b.tipo_clte(+) and a.ref_id = b.ref_id(+) and a.codigo = b.id_clte(+) order by ref_desc, nombre");*/

	sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, a.dv, nvl(b.id_precio, 0) id_precio, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado, nvl(b.id, 0) id, decode(b.id_precio, 1, 'NORMAL', 2, 'EJECUTIVO', 3, 'COLABORADOR', 4, 'PRECIO 4', 5, 'PRECIO 5', 6, 'PRECIO 6', 7, 'PRECIO 7', 8, 'PRECIO 8', '') id_precio_desc, (select descripcion from tbl_fac_tipo_cliente where codigo = ");
	sbSql.append(ref_id);
	sbSql.append(") ref_desc from (");
	sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
	sbSql.append(") a, tbl_clt_lista_precio b where nvl(compania, 1) = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" and a.refer_to = b.tipo_clte(+) and a.codigo = b.id_clte(+) and b.ref_id(+) = ");
	sbSql.append(ref_id);
	sbSql.append(" order by nombre");
	
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
	String title = "LISTA DE PRECIOS";
	String subtitle = "";
	String xtraSubtitle = " ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".38");
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		dHeader.addElement(".05");
		dHeader.addElement(".12");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.addBorderCols("Tipo Cliente",1);
	pc.addBorderCols("Nombre",1);
	pc.addBorderCols("Código",1);
	pc.addBorderCols("RUC",1);
	pc.addBorderCols("DV",1);
	pc.addBorderCols("Tipo",1);
	
	pc.setTableHeader(2);//create de table header

	//table body

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cd = (CommonDataObject) al.get(i);

			pc.setFont(7, 0);
			pc.addCols(cd.getColValue("ref_desc"),0,1);
			pc.addCols(cd.getColValue("nombre"),0,1);
			pc.addCols((cd.getColValue("refer_to").equals("EMPL")?cd.getColValue("num_empleado"):cd.getColValue("codigo")),1,1);
			pc.addCols(cd.getColValue("ruc"),1,1);
			pc.addCols(cd.getColValue("dv"),1,1);
			pc.addCols(cd.getColValue("id_precio_desc"),0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>