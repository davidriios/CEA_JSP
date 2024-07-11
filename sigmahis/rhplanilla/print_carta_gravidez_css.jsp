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
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: Tirza Monteza.                   -->
<!-- Reporte: carta_licencia_gravidez	                  -->
<!-- Reporte: CARTA DE GRAVIDEZ  	                      -->
<!-- Clínica Hospital San Fernando                      -->
<!-- Fecha: 05/09/2011                                  -->

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
ArrayList alA = new ArrayList(); // aumentos
ArrayList alV = new ArrayList(); // vacaciones
CommonDataObject cdo   = new CommonDataObject();
CommonDataObject cdoF   = new CommonDataObject();

String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String appendFilter2 	 = "";
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
String compania 			 = (String) session.getAttribute("_companyId");
String empIdCert			 = request.getParameter("empIdCert");
String nombreEmpRepr	 = request.getParameter("nombreEmpRepr");
String cargoEmpRepr	 	 = request.getParameter("cargoEmpRepr");
String observacion	 	 = request.getParameter("observacion");
String dirigidoA		 	 = request.getParameter("dirigidoA");
String nota		 	 			 = request.getParameter("nota");
double salarioNeto=0.00, totalDeduc=0.00;

String fg 	 = request.getParameter("fg");

if (appendFilter 	== null) appendFilter = "";
if (empIdCert 		== null) empIdCert = "";
if (nombreEmpRepr == null) nombreEmpRepr = "";
if (cargoEmpRepr 	== null) cargoEmpRepr = "";
if (observacion 	== null) observacion = "";
if (dirigidoA 		== null) dirigidoA = "";
if (nota			 		== null) nota = "";

//--------------Parámetros--------------------//
if (!compania.equals(""))		appendFilter += " and a.compania = "+compania;

if (!empIdCert.equals("")) appendFilter += " and a.emp_id = "+empIdCert;

	sql = "select 'Mediante la presente le comunicamos a usted, que '||decode(a.sexo,'F','la   Sra. ','el   Sr. ')||a.nombre_empleado||',    con cédula de identidad personal número  '||a.cedula1||'   y seguro social número  '||decode(a.num_ssocial,'9999999',a.cedula1,a.num_ssocial)||',   tiene fecha probable de parto el día   '||to_char(max(nvl(b.fecha_parto,b.fecha_inicio)),'DD \"DE\" FMMONTH \" DE \" YYYY','NLS_DATE_LANGUAGE=SPANISH' )||' , de acuerdo a certificación de embarazo emitida por el médico . ' certificacion_linea1,    'Que basado en lo anterior, se acogerá a Licencia por Gravidez a partir del  '||to_char(max(b.fecha_inicio),'DD \"DE\" FMMONTH \" DE \" YYYY','NLS_DATE_LANGUAGE=SPANISH' )||'  al  '||to_char(max(b.fecha_final),'DD \"DE\" FMMONTH \" DE \" YYYY','NLS_DATE_LANGUAGE=SPANISH')||',   razón por la  cual no le reportaremos salario en planilla durante ese periodo.' certificacion_linea2  from vw_pla_empleado a, tbl_pla_cc_licencia b where a.emp_id = b.emp_id and a.compania = b.compania and b.motivo_falta =37 "+appendFilter+"  group by a.sexo, a.nombre_empleado, a.num_ssocial, a.cedula1 ";
	cdo = SQLMgr.getData(sql);
	
	sql = "select 'Panamá, '||to_char(sysdate,'dd')||' de '||to_char(sysdate,'FMmonth','NLS_DATE_LANGUAGE=SPANISH')||' de '||to_char(sysdate,'yyyy') fechaCarta, 'No. Patronal '||num_patronal patrono from tbl_sec_compania where codigo="+compania;
	cdoF = SQLMgr.getData(sql);


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
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subtitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 9;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".50");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(1);
	// titulos de columnas
	pc.setFont(7, 1);

	pc.setFont(10, 0);
	// lineas en blanco
	pc.addCols("",1,dHeader.size(),cHeight*10);
	// fecha de la carta
	pc.addCols("",0,1);
	pc.addCols(cdoF.getColValue("fechaCarta"),0,5);
	// lineas en blanco
	pc.addCols("",1,dHeader.size(),cHeight*4);
	// dirigida a
	pc.addCols("",0,1);
	pc.addCols("Señores",0,5);
	pc.setFont(10,1);
	pc.addCols("",0,1);
	pc.addCols("Departamento de Pensiones y Subsidios",0,5);
	pc.addCols("",0,1);
	pc.addCols("Sección de Incapacidad Común, Maternidad,",0,5);
	pc.addCols("",0,1);
	pc.addCols("Funerales y Lentes",0,5);
	pc.addCols("",0,1);
	pc.addCols("Caja de Seguro Social",0,5);
	pc.setFont(10,0);
	pc.addCols("",0,1);
	pc.addCols("Presente.-",0,5);
	pc.addCols("",0,1);
	pc.addCols("",1,dHeader.size(),cHeight*2);
	pc.setFont(10,0);

	// saludo
	pc.addCols("",0,1);
	pc.addCols("Estimados Señores:",0,5);
	pc.addCols("",1,dHeader.size(),cHeight*2);
	pc.setFont(10,0);

	if (cdo!= null)
	{
		// cuerpo del a carta
		pc.addCols("",1,1);
		pc.addCols("          "+cdo.getColValue("certificacion_linea1"),0,4);
		pc.addCols("",1,1);
	
		// lineas en blanco
		pc.addCols("",1,dHeader.size(),cHeight*2);
	
		// parrafo#2
		pc.addCols("",1,1);
		pc.addCols("          "+cdo.getColValue("certificacion_linea2"),0,4);
		pc.addCols("",1,1);
	} else
	{
		// parrafo#2
		pc.addCols("",1,1);
		pc.addCols(" * * * * NO HAY INFORMACION DE LICENCIA REGISTRADA * * * * ",0,4);
		pc.addCols("",1,1);	
	}
	
	// lineas en blanco
	pc.addCols("",1,dHeader.size(),cHeight*2);
	// texto final carta
	pc.setFont(10,0);
	pc.addCols("",1,1);
	pc.addCols("En espera que la información brindada sea la solicitada por ustedes, queda de usted,",0,5);
	pc.addCols("",1,dHeader.size(),cHeight*2);
	// firma
	pc.setFont(10,0);
	pc.addCols("",1,1);
	pc.addCols("Atentamente,",0,5);
	pc.addCols("",1,dHeader.size(),cHeight*3);
	pc.addCols("",1,1);
	pc.addCols("Lic. "+nombreEmpRepr,0,5);
	pc.addCols("",1,1);
	pc.addCols(cargoEmpRepr,0,5);
	pc.addCols("",1,1);
	pc.setFont(10,1);
	pc.addCols(cdoF.getColValue("patrono"),0,5);
	pc.addCols("",1,1);
	pc.setFont(10,0);
	//pc.addCols("/"+userName,0,dHeader.size());



	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

