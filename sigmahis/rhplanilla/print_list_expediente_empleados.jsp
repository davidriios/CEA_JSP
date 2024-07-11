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

	//sql="select a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, a.provincia, a.sigla, a.tomo, a.asiento,   a.primer_nombre||' '||a.primer_apellido||' '||a.segundo_apellido as nombre , a.ubic_fisica as seccion, ' [ '||a.ubic_fisica||' ] '||b.descripcion as descripcion, a.emp_id as empId, a.num_empleado as numero, a.num_ssocial as social, a.tipo_renta||'-'||nvl(a.num_dependiente,'0') renta, to_char(a.salario_base,'99,999,990.00') as salario, to_char(a.rata_hora,'99,990.00') as rata, to_char(a.fecha_nacimiento,'dd-mm-yyyy') nacimiento, to_char(a.fecha_ingreso,'dd-mm-yyyy') ingreso, a.horas_base horas, a.estado, e.descripcion estadoDesc, d.denominacion as cargo from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo d, tbl_pla_estado_emp e where a.compania = b.compania and a.ubic_fisica = b.codigo and a.estado = e.codigo and a.cargo = d.codigo and a.compania = d.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.ubic_seccion, a.primer_apellido";
	
	sql="select nvl(a.pasaporte,a.cedula1) as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.nombre_empleado  as nombre ,a.primer_nombre, a.primer_apellido, a.ubic_fisica as seccion, a.num_ssocial as social,a.tipo_renta||'-'||nvl(a.num_dependiente,'0') renta,a.num_empleado as numero,to_char(a.fecha_ingreso,'dd-mm-yyyy') ingreso, b.descripcion as descripcion, a.emp_id as empId, a.estado, c.denominacion as cargo, d.descripcion as estadodesc, a.num_empleado as numEmpleado, a.horas_base horas,to_char(a.rata_hora,'99,990.00') as rata, to_char(a.fecha_ingreso,'dd/mm/yyyy') as  fechaIngreso from vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo c, tbl_pla_estado_emp d where a.compania = b.compania(+) and a.ubic_fisica = b.codigo(+) and a.compania = c.compania(+) and a.cargo = c.codigo(+) and a.estado = d.codigo(+) and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.ubic_fisica, a.nombre_empleado";
	
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String time = CmnMgr.getCurrentDate("ddmmyyyyhh12missam");

	String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+time+"-"+UserDet.getUserId()+".pdf";

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
	String subtitle = "EMPLEADOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("# Empleado",0,1);
		pc.addBorderCols("Cédula",1,1);		
		pc.addBorderCols("Nombre",1,1);
		pc.addBorderCols("Seg.Social",1,1);		
		pc.addBorderCols("Fecha Ingreso",1,1);
		pc.addBorderCols("Cargo",1,1);
		pc.addBorderCols("Clave Renta",1,1);	
		pc.addBorderCols("Rata x Hora",1,1);		
		pc.addBorderCols("Estado",1,1);
						
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String sec = "";
	
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!sec.equalsIgnoreCase(cdo.getColValue("seccion")))
			{
			
			pc.setFont(7, 1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,dHeader.size());
			}
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("numero"),0,1);
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre"),0,1);	
			pc.addCols(" "+cdo.getColValue("social"),0,1);
			pc.addCols(" "+cdo.getColValue("ingreso"),1,1);
			pc.addCols(" "+cdo.getColValue("cargo"),0,1);
			pc.addCols(" "+cdo.getColValue("renta"),1,1);
			pc.addCols(" "+cdo.getColValue("rata"),2,1);
			pc.addCols(" "+cdo.getColValue("estadoDesc"),0,1);		
			
			sec=cdo.getColValue("seccion");	
	
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>