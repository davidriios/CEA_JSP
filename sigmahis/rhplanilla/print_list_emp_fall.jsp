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

String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String seccion = request.getParameter("sec");
String tipo = request.getParameter("tipo");


if (appendFilter == null) appendFilter = "";

if (mes==null) mes = "";
if (anio==null) anio = "";
if (tipo==null) tipo = "";

if (!mes.trim().equals(""))  appendFilter += " and  to_char(a.fecha,'mm') in ("+mes+") ";
 if (!anio.trim().equals(""))  appendFilter += " and  to_char(a.fecha,'yyyy') in ("+anio+") ";
 
  
	sql="select a.compania,a.provincia,a.sigla,a.tomo,a.asiento, a.anio_des, a.quincena_des, to_char(a.fecha_des,'dd-mm-yyyy') as fecha_des, to_number(to_char(a.fecha,'MM')) mes, a.pariente,d.nombre||' '||d.apellido as nombre_pariente, to_char(a.fecha,'dd-mm-yyyy') as fecha_fallecimiento, b.primer_nombre||' '||decode(b.sexo,'F',decode(b.apellido_casada, null, b.primer_apellido, decode(b.usar_apellido_casada,'S','DE '||b.apellido_casada,b.primer_apellido)),b.primer_apellido) as  nombre_empleado, decode(b.provincia,0,' ',00,' ',11,'B',12,'C',b.provincia)||decode(b.sigla,'00','  ','0','  ',b.sigla)||'-'||to_char(b.tomo)||'-'||to_char(b.asiento) as cedula_empleado, b.num_empleado, c.descripcion	 from tbl_pla_pariente_muerte a, tbl_pla_empleado b, tbl_pla_parentesco c, tbl_pla_pariente d where a.provincia = b.provincia and	a.sigla = b.sigla and a.tomo = b.tomo and a.asiento = b.asiento and	a.compania	= b.compania and	 a.provincia = d.emp_provincia  and	a.sigla	= d.emp_sigla and a.tomo = d.emp_tomo and a.asiento	= d.emp_asiento and a.compania	= d.cod_compania and a.pariente	= d.codigo and d.parentesco	= c.codigo and a.estado	= 'PA' and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.fecha, b.primer_nombre, b.primer_apellido";
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
	String subtitle = " LISTADO DE FALLECIMIENTO DE PARIENTES DE EMPLEADOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  	dHeader.addElement(".15");
	  	dHeader.addElement(".05");
		dHeader.addElement(".25");
		dHeader.addElement(".20");
		dHeader.addElement(".25");
		dHeader.addElement(".10");
			
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
							
		pc.setFont(7, 1);
		pc.addBorderCols("CEDULA",1,1);
		pc.addBorderCols("No.",1,1);
		pc.addBorderCols("NOMBRE DEL EMPLEADO",1,1);		
		pc.addBorderCols("PARENTESCO",1,1);		
		pc.addBorderCols("NOMBRE DEL PARIENTE",1,1);
		pc.addBorderCols("FECHA DECESO",1,1);
							
							
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String tip = "";
	//if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("cedula_empleado"),0,1);
			pc.addCols(" "+cdo.getColValue("num_empleado"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre_empleado"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre_pariente"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha_des"),1,1);
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>