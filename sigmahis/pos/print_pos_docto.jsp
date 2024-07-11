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
<jsp:useBean id="htDet" scope="session" class="java.util.Hashtable" />
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

String cliente  = (request.getParameter("cliente")==null?"":request.getParameter("cliente"));
String subtotal = (request.getParameter("subtotal")==null?"":request.getParameter("subtotal"));
String descuento = (request.getParameter("descuento")==null?"":request.getParameter("descuento"));
String itbm = (request.getParameter("itbm")==null?"":request.getParameter("itbm"));
String total = (request.getParameter("total")==null?"":request.getParameter("total"));
String comment = (request.getParameter("comment")==null?"":request.getParameter("comment"));
String mensaje = "";
	CommonDataObject cdoQry = new CommonDataObject();
	StringBuffer sbQry = new StringBuffer();
	sbQry.append("select get_sec_comp_param(");
	sbQry.append((String) session.getAttribute("_companyId"));
	sbQry.append(", 'MENSAJE_PROFORMA') mensaje from dual");
	cdoQry = SQLMgr.getData(sbQry.toString());
	if(cdoQry!=null) mensaje = cdoQry.getColValue("mensaje");

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
	String title = "PROFORMA";
	String subtitle = "";
	String xtraSubtitle = " ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	Vector tblCS = new Vector();
	tblCS.addElement("12.5");
	tblCS.addElement("12.5");
	tblCS.addElement("12.5");
	tblCS.addElement("12.5");
	tblCS.addElement("12.5");
	tblCS.addElement("12.5");
	tblCS.addElement("12.5");
	tblCS.addElement("12.5");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(tblCS);

	footer.createTable();
	
	
	footer.setFont(10, 1);
	footer.addBorderCols("Subtotal:",1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols(""+CmnMgr.getFormattedDecimal(subtotal),1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols("Descuento:",1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols(""+CmnMgr.getFormattedDecimal(descuento),1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols("ITBM:",1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols(""+CmnMgr.getFormattedDecimal(itbm),1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols("Total:",1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addBorderCols(""+CmnMgr.getFormattedDecimal(total),1,1,0.0f,0.1f,0.0f,0.0f);
	if(!mensaje.equals("")){
	footer.setFont(8, 0);
	footer.addBorderCols(mensaje,0,tblCS.size(),0.0f,0.1f,0.0f,0.0f);
	}
	

	footer.addBorderCols("Preparado Por:"+(String) session.getAttribute("_userName"),1,tblCS.size(),0.0f,0.1f,0.0f,0.0f);
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".60");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.addBorderCols("Cliente:  "+cliente,0, dHeader.size(),0.0f,0.0f,0.0f,0.0f);
	if(!comment.equals("")){
	pc.addBorderCols("Comentario:  "+comment,0, dHeader.size(),0.0f,0.0f,0.0f,0.0f);
	}

	pc.addBorderCols("CODIGO",1);
	pc.addBorderCols("DESCRIPCION",1);
	pc.addBorderCols("CANTIDAD",1);
	pc.addBorderCols("PRECIO",1);
	pc.addBorderCols("TOTAL",1);
	
	pc.setTableHeader(2);//create de table header

	//table body
	if (htDet.size() > 0) al = CmnMgr.reverseRecords(htDet, false);

	for (int i=0; i<htDet.size(); i++){
		String key = al.get(i).toString();
		CommonDataObject cd = (CommonDataObject) htDet.get(key);

			pc.setFont(7, 0);
			pc.addCols(cd.getColValue("codigo").replaceAll("I@","").replaceAll("D@","").replaceAll("@",""),1,1);
			pc.addCols((cd.getColValue("itbm").equals("S")?"* ":"")+cd.getColValue("descripcion"),0,1);
			pc.addCols(cd.getColValue("cantidad"),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("########0.00", cd.getColValue("precio")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("########0.00", cd.getColValue("total")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>