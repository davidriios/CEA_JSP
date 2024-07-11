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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

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
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
StringBuffer sbBody = new StringBuffer();

if (fg==null) fg = "";

sql = " select nombre_paciente nombrePaciente, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula from vw_adm_paciente Where pac_id="+pacId;

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";
	String monthES = null;

	if(mon.equals("01")) {month = "january"; monthES = "Enero";}
	else if(mon.equals("02")) {month = "february"; monthES = "Febrero";}
	else if(mon.equals("03")) {month = "march"; monthES = "Marzo";}
	else if(mon.equals("04")) {month = "april"; monthES = "Abril";}
	else if(mon.equals("05")) {month = "may"; monthES = "Mayo";}
	else if(mon.equals("06")) {month = "june"; monthES = "Junio";}
	else if(mon.equals("07")) {month = "july"; monthES = "Julio";}
	else if(mon.equals("08")) {month = "august"; monthES = "Agosto";}
	else if(mon.equals("09")) {month = "september"; monthES = "Septiembre";}
	else if(mon.equals("10")) {month = "october"; monthES = "Octubre";}
	else if(mon.equals("11")) {month = "november"; monthES = "Noviembre";}
	else {month = "december"; monthES = "Diciembre";}

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
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISI�N";
	String subTitle = "CONSENTIMIENTO FOTOGR�FICO";
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}
	
	//control images
		
		Vector tblImg = new Vector();
			tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
		pc.addTable();

	Vector dHeader = new Vector();
		
		dHeader.addElement(".01"); //yo
		dHeader.addElement(".05"); //raya
		dHeader.addElement(".04"); //con cedula
		dHeader.addElement(".04"); //raya
		dHeader.addElement(".03"); //blanco
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

	pc.setFont(12, 1);

	pc.addCols(" ", 1, dHeader.size());
	pc.addCols(title, 1, dHeader.size(),20.2f);
	pc.addCols(subTitle, 1, dHeader.size());
	pc.setFont(11, 0);
	
	sbBody.append("Los padres de el(los) reci�n nacido(s) dan su consentimiento para que el Hospital ");
	sbBody.append(_comp.getNombre());
	
	sbBody.append(" a trav�s ");
	if (fg.trim().equals("HC")){
	   sbBody.append("de un funcionario de Relaciones P�blicas, Admisi�n o Enfermer�a ");
	}else sbBody.append("  ..........................................................................................,");
	
	sbBody.append(" realice fotograf�as de su(s) beb�(s) nacido(s) en nuestro Hospital para uso �nicamente de los padres como recordatorio del nacimiento de su(s) beb�(s).");
		
	if (!fg.trim().equals("HC")) {
	   sbBody.append(" en el Hospital ");
	   sbBody.append(_comp.getNombre());
	   sbBody.append(". ");
	}

	pc.addCols(sbBody.toString() ,3, dHeader.size());
			
	sbBody = new StringBuffer();
	sbBody.append("\n\nAdicionalmente autorizo al Hospital ");
	sbBody.append(_comp.getNombre());
	sbBody.append(" a incorporar las fotograf�a(s) tomadas de mi(s) beb�(s) en la P�gina Web del Hospital");
	
	if (fg.trim().equals("HC")){
	  sbBody.append(".");
	}
	else sbBody.append(", las cuales s�lo podr�n ser vistas a trav�s de un usuario y contrase�a que me proporcionar�n s�lo a mi persona a trav�s de un correo electr�nico, para poder acceder a las fotograf�as  y que podr� compartir con mis familiares y amigos si s�lo yo comparto dicha contrase�a.");
	
	pc.addCols(sbBody.toString(), 3, dHeader.size());
	
	pc.addCols("\n" ,0, dHeader.size());
	
	pc.addCols("Yo ", 0, 1, 15.2f); 
	pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 30.2f); 
	pc.addCols("con c�dula o Pasaporte", 0, 1); 
	pc.addBorderCols(cdo.getColValue("cedula"), 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);  		
	pc.addCols("Acepto el acuerdo detallado en la presente, el d�a "+day+" del mes de "+monthES+" del "+year+".", 0, dHeader.size(), 15.2f); 
	
	pc.addCols("\n\n" ,0, dHeader.size());	
	pc.addCols("Autorizo: ", 0, 2);
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f); 
	
	pc.addCols("No Autorizo: ", 0, 2); 
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f); 
	
	pc.addCols("De Autorizar: ", 0, dHeader.size(), 25.2f);
	
	pc.addCols("Nombre: ", 0, 2);
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 
	
	pc.addCols("E Mail: ", 0, 2);
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 
	
	pc.addCols("Tel�fonos: ", 0, 2); 
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 
	
	pc.addCols("C�dula: ", 0,2); 
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 

	pc.setFont(11, 1);	
    pc.addCols("\n\n\nAdjuntar copia de C�dula.", 0, dHeader.size());
	
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>