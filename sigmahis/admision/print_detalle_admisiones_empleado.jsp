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
<!-- Desarrollado por: Tirza Monteza     -->
<!-- Reporte: Detalle admisiones con beneficio de empleado  -->
<!-- Reporte: fac71018                   -->
<!-- Clínica Hospital San Fernando       -->
<!-- Fecha: 04/08/2010                   -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");/*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo0 = new CommonDataObject();

ArrayList al0 = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania = (String) session.getAttribute("_companyId");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos ---------------------------------//

// detalle de admisiones
sql = "select distinct(t.fecha_nacimiento||t.codigo_paciente||t.secuencia) paciente, to_char(t.fecha_nacimiento,'dd-mm-yyyy')||' - '||t.codigo_paciente||' - '||t.secuencia admision, p.primer_apellido||' '||p.segundo_apellido||' '||p.apellido_de_casada||', '||p.primer_nombre||' '||p.segundo_nombre nombre, getResponsableNombrePar(t.fecha_nacimiento,t.codigo_paciente,t.secuencia) responsable from  temp_urg_estadist t,  adm_paciente p  where  t.aseguradora = 81 /*EMPLEADO*/ and    (p.fecha_nacimiento = t.fecha_nacimiento  and     p.codigo = t.codigo_paciente) order by 3 ";
al0 = SQLMgr.getDataList(sql);


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
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "CUARTO DE URGENCIAS - ADMISIONES CON BENEFICIO DE EMPLEADO";
	String xtraSubtitle = "DESDE "+fechaini+"  HASTA  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".40"); //
		dHeader.addElement(".20");
		dHeader.addElement(".40");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);


	pc.setFont(8, 1);
	pc.addBorderCols("Nombre del Paciente",1,1);
	pc.addBorderCols("Admisión",1,1);
	pc.addBorderCols("Responsable  - [ Parentesco ]",1,1);

	pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	pc.addCols(" ",0,dHeader.size());

	//==========================================================================
	// DETALLE DE PACIENTES ATENDIDOS CON BENEFICIO EMPLEADO
	for (int i=0; i<al0.size(); i++)
	{
      cdo0 = (CommonDataObject) al0.get(i);

			// imprimir detalle de pacientes
			pc.setFont(8, 0);
	    pc.addCols(cdo0.getColValue("nombre"),0,1);
	    pc.addCols(cdo0.getColValue("admision"),1,1);
	    pc.addCols(cdo0.getColValue("responsable"),0,1);

	}

	if (al0.size() > 0)
	{
		pc.setFont(8, 1);
		// totales por tipo
		pc.addCols("Total de Pacientes con Beneficio EMPLEADO . . . . . . ",2,1);
		pc.addCols(String.valueOf(al0.size()),0,2);
	}


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
