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
<!-- Desarrollado por: Oscar Hawkins        -->
<!-- Reporte: "Informe de Valores del paciente"  -->
<!-- Reporte: ADM3087                         -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 18/10/2010                        -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
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

String compania = (String) session.getAttribute("_companyId");

String pac_id       = request.getParameter("pac_id");

 sql = " select nombre_paciente nombre, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula from vw_adm_paciente Where pac_id="+pac_id;

cdo = SQLMgr.getData(sql);
al = SQLMgr.getDataList(sql); 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";
		
	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");	
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";	
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 75.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "VALORES DEL PACIENTE";
	String subtitle = "";
	String xtraSubtitle = " ";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
							 

	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	//imagen
		
		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();
		
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
		pc.addTable();	
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".04");	
		dHeader.addElement(".10");	
		dHeader.addElement(".10");	
		dHeader.addElement(".10");	
		dHeader.addElement(".10");	
		dHeader.addElement(".10");
		dHeader.addElement(".10");		
		dHeader.addElement(".10");		
		dHeader.addElement(".10");		
		dHeader.addElement(".10");		
		dHeader.addElement(".06");		
		  	
			
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	    pc.setFont(10, 1);
		pc.addCols(title, 1, dHeader.size(),20.2f);
		pc.addCols("",1, dHeader.size(),10.2f);
		pc.addCols(subtitle, 1, dHeader.size(),20.2f);
		pc.addCols("", 1, dHeader.size(),10.2f);
	
		pc.setFont(8, 0);
		
		pc.addCols("Yo,",0,1);
		pc.addBorderCols(cdo.getColValue("nombre"),0,6,0.5f,0.0f,0.0f,0.0f,cHeight);		
		pc.addCols("con cédula de identidad personal o",1,4);
		pc.addCols("pasaporte Nº",0,2);
		pc.addBorderCols(cdo.getColValue("cedula"),0,2,0.5f,0.0f,0.0f,0.0f,cHeight);					

		pc.addCols("me rehúso a guardar los valores en las cajas de seguridad del hospital, destinadas,",0,7);
		pc.addCols("para tal propósito y eximo al Hospital Punta Pacífica de toda responsabilidad.",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
	
		//pc.addCols(consentimientoGeneral,0,7);	
		pc.addCols("Firma:__________________________________",0,6); 		
		pc.addCols("Fecha:",1,0);
		pc.addBorderCols(fecha,0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("",0,dHeader.size());
		pc.addCols("",0,dHeader.size());  	  		
		pc.addCols("",0,dHeader.size()); 	
	pc.setTableHeader(2);
	
	String groupBy = "", pacId = "";
	int pxc = 0, pcant = 0;
	pc.addTable();  
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>

