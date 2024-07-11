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

String tipo_pos  = (request.getParameter("tipo_pos")==null?"":request.getParameter("tipo_pos"));
String desc = (request.getParameter("desc")==null?"":request.getParameter("desc"));


	sbSql.append("select precio4, precio5, precio6, precio7, precio8, tipo, es_menu_dia, id, codigo, descripcion, id_familia, estado, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, nvl(precio1, 0) precio1, nvl(precio2, 0) precio2, nvl(precio3, 0) precio3, decode(tipo, 'D', 'Desayuno', 'A', 'Almuerzo', 'C', 'Cena') tipo_desc, decode(es_menu_dia, 'Y', 'Si', 'N', 'No') es_menu_dia_desc, decode(estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc from TBL_CAF_MENU where id is not null ");
	sbSql.append(appendFilter);
	sbSql.append(" order by id");

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
	String title = "LISTA DE MENU";
	String subtitle = "";
	String xtraSubtitle = " ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		if(tipo_pos.equals("CAF")){
		dHeader.addElement(".10");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		} else {
		dHeader.addElement(".15");
		dHeader.addElement(".40");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		}



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.addBorderCols("Código",1);
	pc.addBorderCols("Descripción",1);
	pc.addBorderCols("Estado",1);
	if(tipo_pos.equals("CAF")){
	pc.addBorderCols("Tipo",1);
	pc.addBorderCols("Es menú del día",1);
	}
	pc.addBorderCols("Precio Normal",1);
	pc.addBorderCols("Precio Ejecutivo",1);
	pc.addBorderCols("Precio Colaborador",1);
	
	pc.setTableHeader(2);//create de table header

	//table body

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cd = (CommonDataObject) al.get(i);

			pc.setFont(7, 0);
			pc.addCols(cd.getColValue("codigo"),0,1);
			pc.addCols(cd.getColValue("descripcion"),0,1);
			pc.addCols(cd.getColValue("estado_desc"),1,1);
			if(tipo_pos.equals("CAF")){
			pc.addCols(cd.getColValue("tipo_desc"),1,1);
			pc.addCols(cd.getColValue("es_menu_dia_desc"),1,1);
			}
			pc.addCols(CmnMgr.getFormattedDecimal(cd.getColValue("precio1")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cd.getColValue("precio2")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cd.getColValue("precio3")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>