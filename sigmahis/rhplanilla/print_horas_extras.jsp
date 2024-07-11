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
String anio = request.getParameter("anio");
String periodo = request.getParameter("periodo");
String planilla = request.getParameter("planilla");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");




if (appendFilter == null) appendFilter = "";

// extras
sql= "select  b.ubic_fisica as unidad, a.codigo, b.emp_id as empId, a.the_codigo as tipoTrx, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha, a.cantidad, a.saldo, a.comentario, a.forma_pago, to_char(a.monto,'999,999,990.00') as monto, a.cantidad_aprob, a.anio_pag||' - '||a.cod_planilla_pag||' - '||a.quincena_pag as periodoPago, a.mes_pag as mesPago, a.quincena_pag as quincenaPago, a.cod_planilla_pag as planillaPago, decode(a.estado_pag,'PE','PENDIENTE','PA','PAGADA') as estado, a.vobo_estado as voboEstado,b.nombre_empleado nomEmpleado, to_char(b.rata_hora,'999,990.00') as rataHora, to_char(b.salario_base,'999,990.00') as salarioBase,substr(e.descripcion,1,15) as descTrx, b.tipo_renta||'-'||to_char(b.num_dependiente,'990') as tipoRenta, substr(d.nombre,10,10) as descripcion, c.denominacion, d.nombre as planilla, b.provincia||'-'||decode(b.sigla,'0','')||b.tomo||' '||b.asiento as cedula, b.num_empleado as numEmpleado, a.the_codigo||' - '||e.descripcion as descTrx, f.descripcion, decode(a.forma_pago,'DI','PAGAR','') as accion from tbl_pla_t_extraordinario a, vw_pla_empleado b, tbl_pla_cargo c, tbl_pla_planilla d, tbl_pla_t_horas_ext e, tbl_sec_unidad_ejec f where a.emp_id = b.emp_id and a.compania = b.compania and a.compania = c.compania and b.cargo = c.codigo and b.compania = f.compania and b.ubic_fisica = f.codigo and a.compania=d.compania and a.the_codigo = e.codigo and d.cod_planilla = a.cod_planilla_pag  and a.comentario ='TRX_SEGUN_MARCACION'  and  b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.anio_pag = "+anio+" and a.quincena_pag = "+periodo+" and a.cod_planilla_pag = 1 ";

// Ausencias y Tardanzas
//sql += "union "; 
//sql += "select  b.ubic_fisica as unidad, a.secuencia as codigo, b.emp_id as empId, a.tipo_trx as tipoTrx, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tiempo, a.tiempo, a.comentario, a.accion, to_char(a.monto,'999,999,990.00') as monto, a.cantidad as cantidad_aprob, a.anio_des||' - '||a.cod_planilla_des||' - '||a.quincena_des as periodoPago, a.mes_des as mesPago, a.quincena_des as quincenaPago, a.cod_planilla_des as planillaPago, decode(a.estado_des,'PE','PENDIENTE','DS','DESCONTADA') as estado, a.vobo_estado as voboEstado,   b.primer_nombre||' '||decode(b.sexo,'F',decode(b.apellido_casada, null,b.primer_apellido,decode(b.usar_apellido_casada,'S','DE '||b.apellido_casada, b.primer_apellido)), b.primer_apellido) as nomEmpleado, to_char(b.rata_hora,'999,990.00') as rataHora,  to_char(b.salario_base,'999,990.00') as salarioBase, substr(e.descripcion,1,15) as descTrx, b.tipo_renta||'-'||to_char(b.num_dependiente,'990') as tipoRenta, substr(d.nombre,10,10) as descripcion, c.denominacion, d.nombre as planilla, b.provincia||'-'||decode(b.sigla,'0','')||b.tomo||' '||b.asiento as cedula, b.num_empleado as numEmpleado, a.motivo_falta||' - '||e.descripcion as descTrx, f.descripcion, decode(a.accion,'DS','DESCONTAR','ND','NO DESCONTAR') as accion from tbl_pla_aus_y_tard a, tbl_pla_empleado b, tbl_pla_cargo c, tbl_pla_planilla d, tbl_pla_motivo_falta e, tbl_sec_unidad_ejec f where a.emp_id = b.emp_id and a.compania = b.compania and a.compania = c.compania and b.cargo = c.codigo and b.compania = f.compania and b.ubic_fisica = f.codigo and a.compania=d.compania and a.motivo_falta = e.codigo and d.cod_planilla = a.cod_planilla_des  and a.comentario like('%Kronox%') and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.anio_des = "+anio+" and a.quincena_des = "+periodo+" and a.cod_planilla_des = 1";
sql += " order by 1,3 ";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";
	


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
	String subtitle = "TRANSACCIONES GENERADAS POR MARCACION / APROBADAS";
	String xtraSubtitle = "Correspondientes a la Planilla Quincenal No. "+periodo+ " del " +anio;
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
		dHeader.addElement(".10");
		dHeader.addElement(".10");
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
		pc.setFont(7, 1);
		pc.addBorderCols("Sec.",0);
		pc.addBorderCols("Fecha",1);								
		pc.addBorderCols("Tipo Transaccion",1);	
		pc.addBorderCols("Estado",1);	
		pc.addBorderCols("Cantidad",2);								
		pc.addBorderCols("Cant. Aprobada",2);	
		pc.addBorderCols("Monto ",2);	
		pc.addBorderCols("Planilla Aplica ",1);	
		pc.addBorderCols("Acción ",1);
	
		
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
			pc.addCols(" "+cdo.getColValue("unidad")+" - "+cdo.getColValue("descripcion"),0,9);
			}
			 if (!empid.equalsIgnoreCase(cdo.getColValue("empId")))
			{
			
			pc.setFont(7, 2);
			pc.addCols("   [ "+cdo.getColValue("cedula")+" ]   "+cdo.getColValue("nomEmpleado")+" [ "+cdo.getColValue("numEmpleado")+" ]   [ "+cdo.getColValue("rataHora")+" ]    [ "+cdo.getColValue("salarioBase")+" ]",0,9);
			}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);	
			pc.addCols(" "+cdo.getColValue("descTrx"),0,1);	
			pc.addCols(" "+cdo.getColValue("estado"),1,1);																		
			pc.addCols(" "+cdo.getColValue("cantidad"),2,1);																			
			pc.addCols(" "+cdo.getColValue("saldo"),2,1);	
			pc.addCols(" "+cdo.getColValue("monto"),2,1);																			
			pc.addCols(" "+cdo.getColValue("periodoPago"),1,1);
			pc.addCols(" "+cdo.getColValue("accion"),1,1);
			
			
		uni=cdo.getColValue("descripcion");	
		empid=cdo.getColValue("empId");	

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>