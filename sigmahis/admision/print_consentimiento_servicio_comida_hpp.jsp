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

//--------------Query para obtener datos de Pacientes Fallecidos----------------------------------------//

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
	String title = "Servicio de comida Kosher en el Hospital Punta Pacífica";
	String subTitle = "";
	//String subtitle = "INFORME DE PACIENTES FALLECIDOS";
	String xtraSubtitle = "";//"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	
	//------------------------------------------------------------------------------------
	String servicioComidaKosherBody = "El Hospital Punta Pacífica, afiliado a Johns Hopkins Medicine Internacional, "+ 
		"esta en disposición de ofrecer el servicio de comida Kosher, "+
		"preparada por el Centro Cultural Hebreo de Panamá, "+
		"tomando en cuenta las normas de terapia nutricional brindadas por el "+
		"Departamento de Nutrición del Hospital Punta Pacífica. Este servicio NO "+
		"está considerado en el costo de la habitación por lo que "+
		"representa un cargo extra. Si usted esta interesado favor leer "+
		"detenidamente las siguientes condiciones "+
		"que rigen el servicio de comida Kosher en el Hospital Punta Pacífica: "+
		"\n\n * El servicio es ofrecido por el Club Hebreo de Panamá de Lunes "+
		"a Viernes, para la alimentación de almuerzos y cenas, sólo a través del "+
		"Departamento de Nutrición del Hospital Punta Pacífica.\n\n" +
		" * Para solicitar este servicio, se debe gestionar el pedido para el "+
		"almuerzo antes de las 9:00 a.m. y para las cenas antes de las 2:00 p.m. "+
		"De no solicitarlo en este horario, lamentamos no poder ofrecerle "+
		"los diferentes menús Kosher.\n\n"+
		" * Se excluyen del servicio las diferentes dietas líquidas claras y dietas "+ 
		"terapéuticas por diferentes  patologías\n\n\n\n\n\n\n";
										
		                            
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
		dHeader.addElement(".25"); 
		dHeader.addElement(".25"); 
		dHeader.addElement(".29");
		dHeader.addElement(".20");
		dHeader.addElement(".17");
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(2);

	pc.setFont(10, 1);
	pc.addCols(title, 1, dHeader.size(),20.2f);
	pc.addCols(subTitle, 1, dHeader.size());
	
		pc.setFont(8, 0);

		pc.addCols(servicioComidaKosherBody , 3, dHeader.size());
		
		pc.addCols("Yo ", 0, 1, 15.2f);
		pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 3, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols("con Cédula o Pasaporte", 0, 2, 15.2f);
		pc.addBorderCols(cdo.getColValue("cedula"), 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols("firmo que leí, comprendí y en caso de tener dudas debo preguntarle a mi", 0, 4, 20.2f);
		pc.addCols("medico tratante.", 0, dHeader.size(), 20.2f);
		
		pc.addCols(" ", 1, dHeader.size(), 25.2f);
		
		pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
		pc.addBorderCols(" ", 1, 2, 0.0f, 0.0f, 0.0f, 0.0f, 20.2f);
		pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
		
		pc.addCols("Firma del paciente", 1, 2);
		pc.addBorderCols(" ", 1, 2, 0.0f, 0.0f, 0.0f, 0.0f, 20.2f);
		pc.addCols("Firma del Oficial de Admisión", 1, 2);
		
		pc.addCols("", 1, dHeader.size(), 25.2f);
		
		pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
		pc.addBorderCols(" ", 1, 2, 0.0f, 0.0f, 0.0f, 0.0f, 20.2f);
	    pc.addBorderCols(cDateTime, 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);

		pc.addCols("Habitación", 1, 2);
		pc.addCols(" ", 1, 2);
		pc.addCols("Fecha", 1, 2);
		
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>