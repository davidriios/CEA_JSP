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

sql="select distinct   nvl(b.pasaporte,b.cedula1) as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, b.num_empleado as numEmpleado, f.descripcion as descripcion, b.emp_id as empId, a.anio, a.cod_planilla,  a.anio||'-'||a.cod_planilla||'-'||a.num_planilla as codigoPla, c.denominacion, a.num_planilla, decode(a.estado,'PE','PENDIENTE','AC','ACTUALIZADO','AP','APROBADO') as estado, g.descripcion as estadodesc, to_char(a.fecha_cheque,'dd/mm/yyyy') as fecha, a.secuencia as codigo, b.num_empleado as numEmpleado, nvl(b.rata_hora,'1') as rataHora, b.ubic_seccion as grupo, a.emp_id as filtro, to_char(nvl(a.sal_bruto,0) + nvl(a.vacacion,0) + nvl(a.pago_40porc,0) + nvl(a.extra,0) + nvl(a.gasto_rep,0) + nvl(a.otros_ing,0) + nvl(a.otros_ing_fijos,0) + nvl(a.indemnizacion,0) + nvl(a.preaviso,0) + nvl(a.xiii_mes,0) + nvl(a.prima_antiguedad,0) + nvl(a.bonificacion,0) + nvl(a.incentivo,0) + nvl(a.prima_produccion,0) - (nvl(a.otros_egr,0) + nvl(a.ausencia,0) + nvl(a.tardanza,0)),'999,999,990.00') as montoBruto,  to_char(nvl(a.sal_bruto,0) + nvl(a.vacacion,0) + nvl(a.pago_40porc,0) + nvl(a.extra,0) + nvl(a.gasto_rep,0) + nvl(a.otros_ing,0) + nvl(a.otros_ing_fijos,0) + nvl(a.indemnizacion,0) + nvl(a.preaviso,0) + nvl(a.xiii_mes,0) + nvl(a.prima_antiguedad,0) + nvl(a.bonificacion,0) + nvl(a.incentivo,0) + nvl(a.prima_produccion,0) - (nvl(a.otros_egr,0) + nvl(a.ausencia,0) + nvl(a.tardanza,0) + nvl(a.total_ded,0)),'999,999,990.00') as montoNeto, to_char(nvl(a.total_ded,0),'999,999,990.00') as montoDesc, p.nombre as nombrePla from vw_pla_empleado b, tbl_sec_unidad_ejec f, tbl_pla_cargo c, tbl_pla_estado_emp g, tbl_pla_pago_ajuste a, tbl_pla_planilla p where b.compania = f.compania and b.ubic_seccion = f.codigo and b.compania = c.compania and b.cargo = c.codigo and b.estado = g.codigo and b.emp_id = a.emp_id and b.compania=a.cod_compania and a.cod_planilla = p.cod_planilla and a.cod_compania = p.compania and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.ubic_seccion, b.emp_id";



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
	String subtitle = "TRANSACCIONES PARA AJUSTE DE PLANILLA";
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
		dHeader.addElement(".25");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 0);
		pc.addBorderCols("Sec.",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Tipo de Planilla",1);
		pc.addBorderCols("Planilla Ajustada  (Año/Código/Número)",1);
		pc.addBorderCols("Estado",1);
		pc.addBorderCols("Monto Bruto",1);
		pc.addBorderCols("Descuentos ",1);
		pc.addBorderCols("Monto Neto ",1);


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
			pc.addCols("",0,dHeader.size());
			pc.setFont(7, 4);
			pc.addCols(" "+cdo.getColValue("seccion")+" - "+cdo.getColValue("descripcion"),0,8);
			}
			 if (!empid.equalsIgnoreCase(cdo.getColValue("empId")))
			{

			pc.setFont(7, 0);
			pc.addCols("   [ "+cdo.getColValue("cedula")+" ]   "+cdo.getColValue("nombre")+" [ "+cdo.getColValue("numEmpleado")+" ] ",0,8);
			}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha"),0,1);
			pc.addCols(" "+cdo.getColValue("nombrePla"),0,1);
			pc.addCols(" "+cdo.getColValue("codigoPla"),1,1);
			pc.addCols(" "+cdo.getColValue("estado"),0,1);
			pc.addCols(" "+cdo.getColValue("montoBruto"),2,1);
			pc.addCols(" "+cdo.getColValue("montoDesc"),2,1);
			pc.addCols(" "+cdo.getColValue("montoNeto"),2,1);


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
