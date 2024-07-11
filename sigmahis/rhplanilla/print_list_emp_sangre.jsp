<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
String tipo = request.getParameter("tipo");
String rh = request.getParameter("rh");

String filter = "";
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if (tipo == null) tipo = "";
if (rh == null) rh = "";


 if (!tipo.equals(""))   appendFilter += " and  e.tipo_sangre = '"+tipo+"'";
 if (!rh.equals(""))     appendFilter += " and  e.rh = '"+rh+"'";



sql= "select e.primer_nombre||' '|| decode(e.sexo,'f',decode(e.apellido_casada, null,e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) as nombre, e.num_empleado, e.num_ssocial  num_ssocial, decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||decode(e.sigla,'00','  ','0','  ', e.sigla) ||'-'||to_char(e.tomo)||'-'||to_char(e.asiento)  cedula, e.tipo_sangre|| decode(e.rh,'P','+','N','-') as sangre, u.descripcion as descripcion , e.tipo_sangre||e.rh as tipo from tbl_pla_empleado e, tbl_bds_tipo_sangre t, tbl_sec_unidad_ejec u  where u.compania = e.compania and	e.compania_uniorg = u.compania and e.unidad_organi = u.codigo and t.tipo_sangre = e.tipo_sangre||decode(e.rh,'P','+','N','-') and t.rh = e.rh and e.estado not in (3,13) and e.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter+ " order by e.tipo_sangre, e.rh , u.descripcion , e.primer_nombre, e.segundo_nombre, e.primer_apellido ";

 al = SQLMgr.getDataList(sql);

 	sql= "select e.tipo_sangre||decode(e.rh,'P','+','N','-') as tipo, count(e.num_empleado) as total from tbl_pla_empleado e, tbl_bds_tipo_sangre t, tbl_sec_unidad_ejec u where u.compania = e.compania and	e.compania_uniorg = u.compania and e.unidad_organi = u.codigo and t.tipo_sangre = e.tipo_sangre||decode(e.rh,'P','+','N','-') and t.rh = e.rh and e.estado not in (3,13) and e.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter+ " group by e.tipo_sangre||decode(e.rh,'P','+','N','-') order by 1 ";
 
 al2 = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	Hashtable htUni = new Hashtable();


	for (int i=0; i<al2.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al2.get(i);

		htUni.put(cdo1.getColValue("tipo"),cdo1.getColValue("total"));
	}
	

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
	String title = "RECURSOS HUMANOS";
	String subtitle = " LISTADO DE EMPLEADOS POR TIPO DE SANGRE ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".50");
		dHeader.addElement(".30");
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addCols("CEDULA",0,1);
		pc.addCols("NOMBRE DEL EMPLEADO ",0,1);	
		pc.addCols("UNIDAD ADMINISTRATIVA",1,1);
		
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = ""; 
	
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
    	
			if (!un.equalsIgnoreCase(cdo.getColValue("sangre")))
			{
			un = cdo.getColValue("sangre");
			pc.setFont(7, 1);
			pc.addCols("TIPO DE SANGRE :  ",0,1);
			pc.addCols(" "+cdo.getColValue("sangre"),0,1);
			pc.addCols("Total de Empleados : ... "+htUni.get(un),1,1);
		
			}
			 	
		
		pc.setFont(7, 0);
		pc.setVAlignment(0); 
		 
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);
	  		pc.addCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
	   
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			
			
			un = cdo.getColValue("sangre");
			
			
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
	
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(" Total de Empleados. . .  "+al.size(),1,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>