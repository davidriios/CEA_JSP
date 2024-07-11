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
String filter = "";
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

sql = "SELECT a.codigo, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,'',' '||b.apellido_casada)) as nombre, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento as cedula, b.cargo, decode(a.puntaje_total,null,' ',puntaje_total) as puntajeTotal, to_char(a.periodo_evdesde,'dd-mm-yyyy') as evDesde, to_char(a.periodo_evhasta,'dd-mm-yyyy') as evHasta, b.emp_id as empId, b.num_empleado numero from tbl_pla_evaluacion a, tbl_pla_empleado b where a.provincia=b.provincia(+) and a.sigla=b.sigla(+) and a.tomo=b.tomo(+) and a.asiento=b.asiento(+) " +appendFilter+" and a.emp_id=b.emp_id(+) and a.compania=b.compania(+) and a.compania="+(String) session.getAttribute("_companyId");
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
	String title = "RECUERSOS HUMANOS";
	String subtitle = " LISTADO DE EMPLEADOS EVALUADOS ";
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
		dHeader.addElement(".30");
		dHeader.addElement(".20");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		  pc.addBorderCols("# Empleado",0);
		  pc.addBorderCols("Cédula",0);
		  pc.addBorderCols("Nombre del Empleado",0);
		  pc.addBorderCols("Puntaje de Evaluación",1);	
			pc.addBorderCols("Evaluado Desde",1);
		  pc.addBorderCols("Hasta",1);	
		
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;

			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
    	
					
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		 
			pc.addCols(" "+cdo.getColValue("numero"),0,1);
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);
	  	pc.addCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo.getColValue("puntajeTotal"),1,1);
	    pc.addCols(" "+cdo.getColValue("evDesde"),1,1);
			pc.addCols(" "+cdo.getColValue("evHasta"),1,1);
			
	    
				
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
	
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>