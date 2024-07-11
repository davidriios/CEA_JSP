<%@ page errorPage="../error.jsp"%>
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
String cargo = request.getParameter("cargo");
String depto = request.getParameter("depto");
String seccion = request.getParameter("sec");
String clave = request.getParameter("clave");
String filter = "";
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if (cargo == null) cargo = "";
if (depto == null) depto = "";
if (seccion == null) seccion = "";
if (clave == null) clave = "";

 if (cargo != "")   appendFilter += " and  e.cargo = "+cargo;
 if (depto != "")   appendFilter += " and  e.ubic_depto = "+depto;
 if (seccion != "") appendFilter += " and  e.seccion = "+seccion;
 if (clave != "") appendFilter += " and  e.tipo_renta = '"+clave+"'";

	                	sql= "select e.primer_nombre||' '|| decode(e.sexo,'f',decode(e.apellido_casada, null,e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) nombre, e.num_empleado, e.num_ssocial  num_ssocial, decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||decode(e.sigla,'00','  ','0','  ', e.sigla) ||'-'||to_char(e.tomo)||'-'||to_char(e.asiento)  cedula, e.cargo, ca.denominacion, e.unidad_organi unidad, e.ubic_seccion useccion, e.seccion seccion, c.nombre  nombre_cia,  e.tipo_renta||e.num_dependiente as renta, to_char(e.fecha_ingreso,'dd-mm-yyyy') fecha_ingreso, d.descripcion departamento, f.descripcion seccionDesc from  tbl_pla_empleado e, tbl_sec_compania c, tbl_pla_cargo ca, tbl_sec_unidad_ejec d, tbl_sec_unidad_ejec f where c.codigo = e.compania and ca.codigo = e.cargo and ca.compania = e.compania and (d.codigo = e.unidad_organi and d.compania = e.compania)  and  (f.codigo = nvl(e.seccion,e.ubic_seccion) and f.compania = e.compania ) and e.estado not in (3,13) and e.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter+ " order by e.unidad_organi, e.seccion, e.primer_nombre,e.segundo_nombre, e.primer_apellido, e.segundo_apellido";
 al = SQLMgr.getDataList(sql);
 
 	sql= "select 'AU' as unit, e.unidad_organi unidad, count(e.num_empleado) as total from  tbl_pla_empleado e, tbl_sec_compania c, tbl_pla_cargo ca, tbl_sec_unidad_ejec d, tbl_sec_unidad_ejec f where c.codigo = e.compania and ca.codigo = e.cargo and ca.compania = e.compania and (d.codigo = e.unidad_organi and d.compania = e.compania)  and  (f.codigo = nvl(e.seccion,e.ubic_seccion) and f.compania = e.compania ) and e.estado not in (3,13) and e.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter;
	sql +=" group by 'AU',e.unidad_organi union ";
	
	sql += "select 'SE' as unit, e.seccion unidad,  count(e.num_empleado) as total from  tbl_pla_empleado e, tbl_sec_compania c, tbl_pla_cargo ca, tbl_sec_unidad_ejec d, tbl_sec_unidad_ejec f where c.codigo = e.compania and ca.codigo = e.cargo and ca.compania = e.compania and (d.codigo = e.unidad_organi and d.compania = e.compania)  and  (f.codigo = nvl(e.seccion,e.ubic_seccion) and f.compania = e.compania ) and e.estado not in (3,13) and e.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter+" group by 'SE',e.seccion order by 1,2 " ;
 
 al2 = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	Hashtable htUni = new Hashtable();
	Hashtable htSec = new Hashtable();

	for (int i=0; i<al2.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al2.get(i);

		if(cdo1.getColValue("unit").trim().equals("AU"))
		{
			htUni.put(cdo1.getColValue("unidad"),cdo1.getColValue("total"));
		}
		else
		{
			htSec.put(cdo1.getColValue("unidad"),cdo1.getColValue("total"));
		}
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
	String title = "RECUERSOS HUMANOS";
	String subtitle = " LISTADO DE EMPLEADOS POR CLAVE DE RENTA POR DIRECCION Y SECCION ";
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
		dHeader.addElement(".40");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		
		
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		
		pc.addBorderCols("No.",1,1);
		pc.addBorderCols("Cédula",1,1);
		pc.addBorderCols("Nombre del Empleado ",1,1);	
		pc.addBorderCols("No.Seguro Soc.",1,1);
		pc.addBorderCols("Clave Renta",1,1);
			
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		int countd = 0;
		int counts = 0; 
	    String un = ""; 
		String sc = ""; 
		String unDesc = ""; 
		String scDesc = ""; 
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
    	
			if (!un.equalsIgnoreCase(cdo.getColValue("unidad")))
			{
			if (i!= 0)
			{
			pc.setFont(7, 1);
				pc.addCols("Total por : ... ",2,2);
				pc.addCols(" "+unDesc+"        "+htUni.get(un),0,3);
				countd = 0;
				unDesc = "";
				
				pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			}
			un = cdo.getColValue("unidad");
			unDesc = cdo.getColValue("departamento");
			pc.setFont(7, 1);
			pc.addCols(" "+cdo.getColValue("unidad")+" - "+cdo.getColValue("departamento"),0,5);
			//pc.addCols("Total de Empleados : ... ",0,1);
			//pc.addCols(" "+htUni.get(un),2,1);
			}
			 	
			if (!sc.equalsIgnoreCase(cdo.getColValue("seccion")))
			{
		    sc = cdo.getColValue("seccion");
			scDesc = cdo.getColValue("seccionDesc");
			pc.setFont(7, 1);
			pc.addCols("   [ "+cdo.getColValue("seccion")+" ] "+cdo.getColValue("seccionDesc"),0,5);
		    //	pc.addCols("Total por Sección: ... ",0,1);
			//	pc.addCols(" "+htSec.get(sc),2,1);
			}
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("num_empleado"),1,1);
			pc.addCols(" "+cdo.getColValue("cedula"),1,1);
	  		pc.addCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo.getColValue("num_ssocial"),1,1);
	    	pc.addCols(" "+cdo.getColValue("renta"),1,1);
			
	    
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
			
			countd++;
			counts++;
			un = cdo.getColValue("unidad");
			sc = cdo.getColValue("seccion");
			
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
	
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else 
	{
	//	pc.setFont(7, 1);
	//			pc.addCols("Total por Sección: ... ",0,2);
	//			pc.addCols(" "+scDesc+"        "+htSec.get(sc),0,3);
			pc.setFont(7, 1);
			pc.addCols("Total por : ... ",2,2);
			pc.addCols(" "+unDesc+"        "+htUni.get(un),0,3);
	
	
	pc.addCols(" Total de Empleados. . .  "+al.size(),1,dHeader.size());
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>