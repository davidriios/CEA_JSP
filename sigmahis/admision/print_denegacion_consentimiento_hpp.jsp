<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pac_id = request.getParameter("pac_id");

String compania = (String) session.getAttribute("_companyId");

//--------------Query para obtener datos del Paciente----------------------------------------//

sql = " select nombre_paciente nombrePaciente, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula from vw_adm_paciente Where pac_id="+pac_id;

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String month1 = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

	if(mon.equals("01")) month1 = "enero";
	else if(mon.equals("02")) month1 = "febrero";
	else if(mon.equals("03")) month1 = "marzo";
	else if(mon.equals("04")) month1 = "abril";
	else if(mon.equals("05")) month1 = "mayo";
	else if(mon.equals("06")) month1 = "junio";
	else if(mon.equals("07")) month1 = "julio";
	else if(mon.equals("08")) month1 = "augosto";
	else if(mon.equals("09")) month1 = "septiembre";
	else if(mon.equals("10")) month1 = "octubre";
	else if(mon.equals("11")) month1 = "noviembre";
	else month1 = "diciembre";
		
	if (mon.equals("01")) month = "january";
	else if (mon.equals("02")) month = "february";
	else if (mon.equals("03")) month = "march";
	else if (mon.equals("04")) month = "april";
	else if (mon.equals("05")) month = "may";
	else if (mon.equals("06")) month = "june";
	else if (mon.equals("07")) month = "july";
	else if (mon.equals("08")) month = "august";
	else if (mon.equals("09")) month = "september";
	else if (mon.equals("10")) month = "october";
	else if (mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 52 * 8.5f;//612 
	float height = 62 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 30.0f; //9.0f
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISIÓN";
	String subTitle = "DENEGACIÓN DE CONSENTIMIENTO";
	String xtraSubtitle = "";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	
//---------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------------------------
PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

//control image
		
		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),90.0f,1);
		pc.addTable();


	Vector dHeader = new Vector();
		
		dHeader.addElement(".05");
		dHeader.addElement(".20"); 
		dHeader.addElement(".05");
		dHeader.addElement(".11"); 
		dHeader.addElement(".05");
		dHeader.addElement(".06");
		dHeader.addElement(".12");
		dHeader.addElement(".17");

		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(2);

	pc.setFont(10, 1);
	pc.addCols(title, 1, dHeader.size(),20.2f);
	pc.addCols(subTitle, 1, dHeader.size());
	
	pc.setFont(8, 0);

	pc.addCols("\nPanamá," + day + " de " + month1 + " de " + year + "\n\n" , 1, dHeader.size());
		
	pc.addCols("Yo ", 0, 1, 15.2f);
	pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 30f);
	pc.addCols("con cédula", 0, 3, 15.2f);
	pc.addBorderCols(cdo.getColValue("cedula"), 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
	//pc.addCols("", 1, 1, 15.2f);
	//pc.addCols(" ", 0, 1);
		
	pc.addCols("después de ser informado de la naturaleza y riesgos del", 0, 4, 15.2f);
	pc.addCols("tratamiento médico", 0, 3,15.2f);
	pc.addBorderCols("", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f,15.2f);
	//pc.addCols(" que se me ha sido propuesto, ", 0, 2,15.2f);
		
	pc.addCols("manifiesto de forma libre y consciente mi DENEGACIÓN DE CONSENTIMIENTO  para que me sea aplicado, haciéndome responsable de las consecuencias que pueden derivarse de esta decisión.", 3, dHeader.size());
		
	pc.addCols(" ", 1, dHeader.size(), 25.2f);
		
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		
	pc.addCols("Firma del paciente ", 1, 2, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addCols("Firma testigo ", 1, 2, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addCols("Firma del médico ", 1, 2, 15.2f);
		
	pc.addCols(" ", 1, dHeader.size(), 20.2f);
		
	pc.addBorderCols(cdo.getColValue("cedula"), 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		
	pc.addCols("Cédula de Identidad ", 1, 2, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addCols("Cédula", 1, 2, 15.2f);
	pc.addCols(" ", 1, 1, 15.2f);
	pc.addCols("Cédula de Identidad ", 1, 2, 15.2f);
				
	pc.addCols("", 1, dHeader.size(), 20.2f);
	pc.addCols("En caso de Incapacidad, el representante legal en uso de sus facultades", 0, dHeader.size());
		
	pc.addCols("\n\nYo, ", 0, 1);
	pc.addBorderCols(" ", 0, 3, 0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" con cédula ", 0, 2);
	pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f);
	//pc.addCols(" ", 0, 1);	
		
	pc.addCols("Representante legal/familiar del paciente,", 0, 3, 15.2f);	
	pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 5, 0.5f,0.0f,0.0f,0.0f);
	//pc.addCols(" ", 0, 1);	
		
	pc.addCols("que ha sido considerado incapaz de tomar por sí mismo la desición de aceptar o rechazar el tratamiento médico con, ", 0, dHeader.size(), 15.2f);
	pc.addBorderCols(" ", 0, 4, 0.5f, 0.0f, 0.0f, 0.0f);
	pc.addCols("DENIEGO la autorización para que le sea aplicado dicho ", 0, 4, 15.2f);
		
	pc.addCols("tratamiento asumiendo la responsabilidd que pueda derivarse de dicha decisión.\n\n\n\n\n", 0, dHeader.size());
		
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>