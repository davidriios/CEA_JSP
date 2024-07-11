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
<!-- Desarrollado por: José A. Acevedo C.        -->
<!-- Reporte: "Informe de Pacientes Fallecidos"  -->
<!-- Reporte: ADM3087                         -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 25/02/2010                        -->
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
	String title = "CONSENTIMIENTO FOTOGRÁFICO";
	String subTitle = ""; //"ADMISIÓN";
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	//------------------------------------------------------------------------------------
	String conFinancieroBody = "Los padres de los recién nacido(s) dan su consentimiento para que el"+
	" Hospital Punta Pacífica a través de LITTLE SMILES PANAMA, realice fotografías de su(s) bebé(s) "+
	" nacido(s) en nuestro Hospital par uso únicamente de los padres como recordatorio del nacimiento"+
	" de su(s) bebé(s) en el Hospital de Punta Pacífica.";

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	//control images
		
		Vector tblImg = new Vector();
			tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),90.0f,1);
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

	pc.setFont(10, 1);

		
	pc.addCols(" ", 1, dHeader.size());
	pc.addCols(title, 1, dHeader.size(),20.2f);
	pc.addCols(subTitle, 1, dHeader.size());
	pc.setFont(8, 0);

	pc.addCols(conFinancieroBody , 0, dHeader.size());
		
	pc.addCols("Yo ", 0, 1, 15.2f); 
	pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 30f); 
	pc.addCols("con cédula o Pasaporte", 0, 1); 
	pc.addBorderCols(cdo.getColValue("cedula"), 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);  
	//pc.addCols("", 0, 1);
		
	pc.addCols(" Acepto el acuerdo detallado en la presente, el día "+day+" del mes de "+monthES+" del "+year, 0, dHeader.size(), 15.2f); 
	
	/*pc.addBorderCols(day, 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f); 
	pc.addCols(" ",0,1,15.2f);
	
	pc.addCols(" del mes ", 0, 2,20.2f); 
	pc.addBorderCols(" de "+monthES, 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		 
	pc.addCols(" de "+year, 0, 3,15.2f); */
	//pc.addCols(" ", 0, 3); 
		
	pc.addCols("\n\nAdicionalmente autorizo al Hospital Punta Pacífica a incorporar las fotografía(s) "+
	"tomadas de mi(s) bebé(s) en la Página Web del Hospital, las cuales sólo podrán ser vistas "+
	"a través de un usuario y contraseña que me proporcionarán sólo a mi persona a través "+
	"de un correo electrónico, para poder acceder a las fotografías  y que podré compartir "+
	"con mis familiares y amigos si sólo yo comparto dicha contraseña.", 0, dHeader.size());
	
	pc.addCols(" ", 1, dHeader.size(),15.2f);
		
	pc.addCols("Autorizo: ", 0, 2);
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f); 
	//pc.addCols(" ", 0, 2); 
	
	pc.addCols("No Autorizo: ", 0, 2); 
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f); 
	//pc.addCols(" ", 0, 2); 
	
	pc.addCols("De Autorizar: ", 0, dHeader.size(), 25.2f);
	
	pc.addCols("Nombre: ", 0, 2);
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 
	//pc.addCols(" ", 0, 2); 
	
	pc.addCols("E Mail: ", 0, 2);
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 
	//pc.addCols(" ", 0, 2); 
	
	pc.addCols("Teléfonos: ", 0, 2); 
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 
    //pc.addCols(" ", 0, 2); 
	
	pc.addCols("Cédula: ", 0,2); 
	pc.addBorderCols(" ", 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f); 
	//pc.addCols(" ", 0, 2); 

    pc.addCols("Adjuntar copia de Cédula.", 0, dHeader.size(), 25.2f);
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>