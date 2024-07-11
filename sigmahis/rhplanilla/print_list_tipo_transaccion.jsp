<%@ page errorPage="../error.jsp"%>
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

if (appendFilter == null) appendFilter = "";

sql="select a.codigo, a.tipo_trx as tipoTrx, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.cantidad, to_char(a.monto,'999,999,990.00') as monto, to_char(a.fecha_inicio,'dd/mm/yyyy') as fechaInicial, to_char(a.fecha_final,'dd-mm-yyyy') as fechaFinal, a.anio_pago||' - '||a.cod_planilla_pago||' - '||a.quincena_pago as periodoPago, a.mes_pago as mesPago, a.quincena_pago as quincenaPago, a.cod_planilla_pago as planillaPago, a.estado_pago as estado, to_char(a.fecha_pago,'dd-mm-yyyy') as fechaPago, a.comentario, decode(a.accion,'PA','PAGAR','DE','DESCONTAR')as accion, a.vobo_estado as voboEstado, a.grupo, a.sub_tipo_trx as subTrx, a.monto_unitario as montoUnitario, a.aprobacion_estado as aprobacionEstado, a.anio_reporta as anioReporta, a.quincena_reporta as quincenaReporta, a.cod_planilla_reporta as codPlanilla, b.emp_id as empId,  b.nombre_empleado  as nomEmpleado, to_char(b.rata_hora,'999,990.00') as rataHora, substr(e.descripcion,1,15) as descTrx, b.tipo_renta||'-'||to_char(b.num_dependiente,'990') as tipoRenta, substr(d.nombre,10,10) as descripcion, c.denominacion, d.nombre as planilla, b.cedula1 as cedula, b.num_empleado as numEmpleado, a.tipo_trx||' - '||e.descripcion as descTrx, f.descripcion, b.ubic_seccion as unidad from tbl_pla_transac_emp a, vw_pla_empleado b, tbl_pla_cargo c, tbl_pla_planilla d, tbl_pla_tipo_transaccion e, tbl_sec_unidad_ejec f where a.emp_id = b.emp_id and a.compania = b.compania and a.compania = c.compania and b.cargo = c.codigo and b.compania = f.compania and b.ubic_seccion = f.codigo and a.compania=d.compania and a.compania = e.compania and a.tipo_trx = e.codigo and d.cod_planilla = a.cod_planilla_pago and a.estado_pago = 'PE' and a.aprobacion_estado = 'S' and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.ubic_seccion, b.emp_id, a.codigo ";
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
	String subtitle = "TRANSACCIONES REGISTRADAS APROBADAS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		
		

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Sec.",0);
		pc.addBorderCols("Fecha",1);								
		pc.addBorderCols("Tipo Transaccion",1);	
		pc.addBorderCols("Fecha Inicial",1);								
		pc.addBorderCols("Fecha Final",1);	
		pc.addBorderCols("Cantidad",1);								
		pc.addBorderCols("Monto Unitario",1);	
		pc.addBorderCols("Monto ",1);	
		pc.addBorderCols("Fecha Pago ",1);	
		pc.addBorderCols("Accion ",1);
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String uni = "";
		String empid = "";
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!uni.equalsIgnoreCase(cdo.getColValue("descripcion")))
			{
			
			pc.setFont(7, 4);
			pc.addCols(" "+cdo.getColValue("unidad")+" - "+cdo.getColValue("descripcion"),0,10);
			}
			 if (!empid.equalsIgnoreCase(cdo.getColValue("empId")))
			{
			
			pc.setFont(7, 2);
			pc.addCols("   [ "+cdo.getColValue("cedula")+" ]   "+cdo.getColValue("nomEmpleado")+" [ "+cdo.getColValue("numEmpleado")+" ] ",0,10);
			}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),1,1);
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);	
			pc.addCols(" "+cdo.getColValue("descTrx"),0,1);	
			pc.addCols(" "+cdo.getColValue("fechaInicial"),1,1);	
			pc.addCols(" "+cdo.getColValue("fechaFinal"),1,1);	
			pc.addCols(" "+cdo.getColValue("cantidad"),2,1);
			pc.addCols(" "+cdo.getColValue("montoUnitario"),2,1);	
			pc.addCols(" "+cdo.getColValue("monto"),2,1);
			pc.addCols(" "+cdo.getColValue("periodoPago"),1,1);
			pc.addCols(" "+cdo.getColValue("accion"),1,1);
			
			
		uni=cdo.getColValue("descripcion");	
		empid=cdo.getColValue("empId");	

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>