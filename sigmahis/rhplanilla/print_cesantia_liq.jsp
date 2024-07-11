<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList tot = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String userName = UserDet.getUserName();
String fechaProc = request.getParameter("fecha"); 
String anio = request.getParameter("anio");
String trimestre = request.getParameter("trimestre");
String mes1 = ""; 
String mes2 = "";
String mes3 = "";
String fecha_inicio = request.getParameter("fecha_inicio");
String fecha_final = request.getParameter("fecha_final");

CommonDataObject cdo2 = null;
if (fp == null) fp="";

if (appendFilter == null) appendFilter = "";

sql = "select a.primer_nombre||' '||decode(a.sexo,'F',decode(a.apellido_casada, null, a.primer_apellido, decode(a.usar_apellido_casada,'S','DE '|| a.apellido_casada, a.primer_apellido)),a.primer_apellido)  nombre_empleado, a.num_empleado, a.rata_hora, b.anio, b.provincia, b.sigla, b.tomo, b.asiento, to_char(a.fecha_egreso,'dd/mm/yyyy') fecha_egreso, sum(nvl(b.salario,0)) sal_bruto, sum(nvl(b.vacacion,0)) vacacion, sum(nvl(b.sal_neto,0)) sal_neto, sum(nvl(b.extra,0)) extra, sum(nvl(b.seg_social,0)) seg_social, sum(nvl(b.seg_educativo,0)) seg_educativo, sum(nvl(b.imp_renta,0)) imp_renta, sum(nvl(b.otras_ded,0)) otras_ded, sum(nvl(b.total_ded,0)) total_ded, sum(nvl(b.gasto_rep,0)) gasto_rep, sum(nvl(b.otros_ing,0)) otros_ing, sum(nvl(b.indemnizacion,0)) indemnizacion, sum(nvl(b.preaviso,0)) preaviso, sum(nvl(b.xiii_mes,0)) xiii_mes, sum(nvl(b.prima_antiguedad,0)) prima_antiguedad, sum(nvl(b.bonificacion,0)) bonificacion, 0 incentivo from tbl_pla_empleado a, tbl_pla_pago_liquidacion b where b.emp_id = a.emp_id and b.cod_compania = a.compania and b.anio = "+anio+" and b.cod_planilla = 8 and b.cod_compania= "+(String) session.getAttribute("_companyId")+ appendFilter +" and trunc(a.fecha_egreso) >= to_date('"+fecha_inicio+"','dd/mm/yyyy') and trunc(a.fecha_egreso) <= to_date('"+fecha_final+"','dd/mm/yyyy') /* and b.estado = 'AC' and b.actualizar='S'*/ group by a.primer_nombre||' '||decode(a.sexo,'F', decode(a.apellido_casada, null,a.primer_apellido, decode(a.usar_apellido_casada,'S','DE '||a.apellido_casada, a.primer_apellido)), a.primer_apellido), a.num_empleado, a.rata_hora, a.fecha_egreso, b.anio, b.provincia, b.sigla, b.tomo, b.asiento";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String montoTotal = "";
	
	Hashtable htUni = new Hashtable();

	
	
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

	float height = 72 * 8.5f;//612height
	float width = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CESANTÍAS DEL "+fecha_inicio+ " AL "+fecha_final;
	String subtitle = "PLANILLAS DE LIQUIDACION";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".04");
		dHeader.addElement(".12");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		
		
		

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addCols("No.",1,1);
		pc.addCols("Nombre del Empleado",0,1);
		pc.addCols("Fecha Cesantía",1,1);
		pc.addCols("Salario Regular",1,1);
		pc.addCols("Vacaciones",1,1);
		pc.addCols("XIII Mes",1,1);
		pc.addCols("Prima Antiguedad",1,1);
		pc.addCols("Preaviso",1,1);
		pc.addCols("Indemnización",1,1);
		pc.addCols("Impuesto S/Renta",1,1);
		pc.addCols("Seguro Social",1,1);
		pc.addCols("Seguro Educativo",1,1);
		pc.addCols("Otras Deducciones",1,1);
		pc.addCols("Total ",2,1);
		
		
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
		/*	
		pc.setFont(7, 1);
		pc.addCols("FECHA DE AUMENTO :  "+fechaProc,1,2);
		pc.addCols(" ",0,4);
		
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
			*/
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
    String sec = "";
	String totalAcr = "";
	double totAcr = 0.00;
	double totSala = 0.00;
	double totSaln = 0.00;
	int cont=0;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("num_empleado"),0,1);
		pc.addCols(cdo.getColValue("nombre_empleado"),0,1);
		pc.addCols(cdo.getColValue("fecha_egreso"),1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("sal_bruto")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("vacacion")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("xiii_mes")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("prima_antiguedad")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("preaviso")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("indemnizacion")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("imp_renta")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("seg_social")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("seg_educativo")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("otras_ded")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("sal_neto")),2,1);
	
	
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0)
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	 pc.addTable();
	pc.close();
	
	}
	else

  pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>