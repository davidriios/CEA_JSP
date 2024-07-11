<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String seccion = request.getParameter("sec");
String tipo = request.getParameter("tipo");
String empId = request.getParameter("empId");

if (appendFilter == null) appendFilter = "";

if (mes==null) mes = "";
if (anio==null) anio = "";
if (empId==null) empId = "";

if (!mes.trim().equals(""))  appendFilter += " and  to_char(l.fecha_des,'mm') in ("+mes+") ";
 if (!anio.trim().equals(""))  appendFilter += " and  to_char(l.fecha_des,'yyyy') in ("+anio+") ";
  if (!empId.trim().equals(""))   appendFilter += " and  l.emp_id = "+empId;
  
	sql= "SELECT a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento AS cedula, a.provincia, a.sigla, a.tomo, a.asiento,   a.primer_nombre||' '||a.primer_apellido||' '||a.segundo_apellido AS nombre , a.ubic_seccion AS seccion, ' [ '||a.ubic_seccion||' ] '||b.descripcion AS descripcion, a.emp_id AS empId, a.num_empleado AS numero, TO_CHAR(a.gasto_rep,'99,999,990.00') AS gasto, a.tipo_renta||'-'||NVL(a.num_dependiente,'0') renta, TO_CHAR(a.salario_base,'99,999,990.00') AS salario, TO_CHAR(a.rata_hora,'99,990.00') AS rata, TO_CHAR(a.fecha_nacimiento,'dd-mm-yyyy') nacimiento, a.horas_base horas, a.estado, e.descripcion estadoDesc,TO_CHAR(l.fecha_des,'dd-mm-yyyy') AS inicio, TO_CHAR(l.fecha_des,'dd-mm-yyyy') AS FINAL, d.denominacion AS cargo, l.motivo_falta AS motivo, '[ '||l.motivo_falta||' ] '||m.descripcion AS motivoDesc, DECODE(l.tipo_trx,'1','Ausencia','2','Tardanza') tipo, l.tipo_trx, l.anio_des, l.mes_des, l.quincena_des,l.anio_dev , l.accion, l.estado_des, l.tiempo, nvl(l.monto,0) monto, nvl(l.tiempo,0) cantidad, l.vobo_estado, NVL(l.cantidad, l.tiempo) conteo FROM TBL_PLA_EMPLEADO a, TBL_SEC_UNIDAD_EJEC b, TBL_PLA_CARGO d, TBL_PLA_ESTADO_EMP e, TBL_PLA_AUS_Y_TARD l, TBL_PLA_MOTIVO_FALTA m WHERE a.compania = b.compania AND a.emp_id = l.emp_id AND a.compania = l.compania AND a.ubic_fisica = b.codigo AND a.estado = e.codigo AND a.cargo = d.codigo AND a.compania = d.compania AND l.motivo_falta = m.codigo AND a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" ORDER BY l.emp_id, l.tipo_trx, a.ubic_fisica,  l.fecha_des";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = " HORAS DE AUSENCIA Y CERTIFICADAS POR EMPLEADOS ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  	dHeader.addElement(".10");
	  	dHeader.addElement(".25");
		dHeader.addElement(".25");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		
		
		
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
							
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String tip = "";
		double totHoras = 0;
		double totMonto = 0;
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!tip.equalsIgnoreCase(cdo.getColValue("nombre")))
		{
		
		if(i!=0)
		{
		pc.addCols("Totales por Empleado:   ",2,3);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totHoras),2,1,0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totMonto),2,1,0.0f, 0.5f, 0.0f, 0.0f);
		totHoras = 0;
		totMonto = 0;
		}
		
		pc.setFont(7, 0);
		pc.addCols(" ",0,dHeader.size());
			
			pc.setFont(7, 1);
			pc.addBorderCols(" [ "+cdo.getColValue("cedula")+" ] "+cdo.getColValue("nombre"),0,3);
			pc.addBorderCols("  "+cdo.getColValue("descripcion"),2,2);
			
		pc.setFont(7, 0);
		pc.addBorderCols("Codigo",0,1);
		pc.addBorderCols("Motivo de Falta",1,1);		
		pc.addBorderCols("Fecha Procesada",1,1);		
		pc.addBorderCols("Cantidad",2,1);
		pc.addBorderCols("Monto",2,1);
		
	
		
		}
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("tipo"),0,1);
			pc.addCols(" "+cdo.getColValue("motivoDesc"),0,1);
			pc.addCols(" "+cdo.getColValue("inicio"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("cantidad")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
			
			totHoras += (Double.parseDouble(cdo.getColValue("cantidad")));	
			totMonto += (Double.parseDouble(cdo.getColValue("monto")));		
			
		tip=cdo.getColValue("nombre");	
	
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else 
		{
		pc.addCols("Totales por Empleado:   ",2,3);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totHoras),2,1,0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totMonto),2,1,0.0f, 0.5f, 0.0f, 0.0f);
		}
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>