<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
String gerencia = request.getParameter("gerencia");
String filter = "";
String userName = UserDet.getUserName();
String printSal = request.getParameter("printSal");
String compania = (String)session.getAttribute("_companyId");
String type = "";

Hashtable emp_x_dir = new Hashtable();

if (appendFilter == null) appendFilter = "";
if (cargo == null) cargo = "";
if (depto == null) depto = "";
if (gerencia == null) gerencia = "";
if (printSal == null ) printSal = "";

 if (cargo != "")   appendFilter = " and  e.cargo = "+cargo;
 if (depto != "")   appendFilter = " and  e.unidad_organi = "+depto;
 if (gerencia != "") appendFilter = " and  AT.gerencia = "+gerencia;

 sql= "SELECT e.nombre_empleado nombreEmpleado, e.num_empleado numEmpleado, NVL(e.cedula1,e.cedula_beneficiario) cedula, e.cargo, ca.denominacion, AT.gerencia codGerencia, g.descripcion descGerencia, e.unidad_organi unidadOrgani, u.descripcion descUnidad, NVL(e.seccion,e.unidad_organi) seccion, s.descripcion descSeccion, trim(to_char(NVL(e.salario_base,0),'9,999,999,9990.00')) salarioBase, TO_CHAR(e.fecha_ingreso,'dd/mm/yyyy') fechaIngreso FROM VW_PLA_EMPLEADO e, tbl_pla_cargo ca, tbl_sec_unidad_ejec u, tbl_sec_unidad_ejec s, tbl_sec_unidad_ejec g, (SELECT t.ue_codigo gerencia, t.compania, t.codigo FROM tbl_sec_unidad_ejec t) AT /*gerencia*/ WHERE  ca.codigo = e.cargo AND ca.compania = e.compania AND e.estado <> 3  AND ((u.codigo = e.unidad_organi) AND (u.compania = e.compania )) AND (s.codigo = NVL(e.seccion,e.unidad_organi) AND s.compania = e.compania) /*Seccion*/ AND (AT.codigo = e.unidad_organi AND AT.compania = e.compania) AND (g.codigo = AT.gerencia AND g.compania = AT.compania) AND e.compania_uniorg = "+compania+" "+appendFilter+" /*and rownum<20*/ ORDER BY codGerencia, unidadOrgani, seccion";
 
 al = SQLMgr.getDataList(sql);



al2 = SQLMgr.getDataList("SELECT 'GER' unit, a.codgerencia code, COUNT (a.codgerencia) total FROM ("+sql+") a GROUP BY 1, codgerencia UNION SELECT 'DEPT' unit, b.unidadOrgani code, COUNT (b.unidadOrgani) total FROM ("+sql+") b GROUP BY 1, unidadOrgani UNION SELECT 'SEC' unit, c.seccion code, COUNT (c.seccion) total FROM ("+sql+") c GROUP BY 1, seccion");

for ( int i = 0; i<al2.size(); i++ ){
   CommonDataObject cdo2 = (CommonDataObject)al2.get(i);
   
   if ( cdo2.getColValue("unit").equalsIgnoreCase("GER") ){
       emp_x_dir.put(cdo2.getColValue("code"), cdo2.getColValue("total"));
   }else if (cdo2.getColValue("unit").equalsIgnoreCase("DEPT")){
       emp_x_dir.put(cdo2.getColValue("code"), cdo2.getColValue("total"));
   }else{
      emp_x_dir.put(cdo2.getColValue("code"), cdo2.getColValue("total"));
   }
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String subtitle = " LISTADO DE EMPLEADOS POR GERENCIA, DEPARTAMENTO Y SECCION ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".09"); //
		dHeader.addElement(".06"); //no
		dHeader.addElement(".10"); //ced
		dHeader.addElement(".28");//nom
		dHeader.addElement(".20");//cargo
		dHeader.addElement(".10");//salario
		dHeader.addElement(".10");//f. ingreso
		dHeader.addElement(".07"); //


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addCols(" ",0,dHeader.size());
		//second row
		pc.setFont(8, 1);
		pc.addCols(" ",1,1);
		pc.addCols("NO.",1,1);
		pc.addCols("CEDULA",1,1);
		pc.addCols("NOMBRE DEL EMPLEADO ",1,1);
		pc.addCols("      CARGO",0,1);
		pc.addCols("SALARIO",1,1);
		pc.addCols("F. INGRESO",1,1);
		pc.addCols(" ",1,1);
		
		pc.addCols(" ", 0,dHeader.size());



	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	int no = 0;
	String groupGerencia = "", groupDepto = "", groupSec = "";
	String totxDir = "",  totxDept = "", totxSec = "";
	
	int totxDepto = 0;
	int sectot = 0;
	String secDes = "";
	String secDepto = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!groupGerencia.trim().equals(cdo.getColValue("codgerencia")))
			{
			
			if ( i != 0 ){
						
			 pc.addCols("Total de Empleados en la sección "+secDes+" --> "+sectot,2,dHeader.size());
			 pc.addCols("Total de Empleados en el departamento "+secDepto+" --> "+emp_x_dir.get(groupDepto),2,dHeader.size());
			
			totxDir = cdo.getColValue("codgerencia");
			pc.setFont(8, 0);
			pc.setVAlignment(1);
						
			pc.addCols("GERENCIA:    "+cdo.getColValue("codgerencia"),0,2,20f,Color.lightGray);
						
			pc.setFont(9,1);
			pc.addCols(cdo.getColValue("descGerencia"),1,4,20f,Color.lightGray);
						
			pc.setFont(8,0);
			pc.addCols("TOTAL EMPLEADO: "+emp_x_dir.get(totxDir),0,2,20f,Color.lightGray);
			
			pc.setFont(8, 0);
						pc.addCols("DEPTO:   ",2,1);
						pc.addCols("    "+cdo.getColValue("unidadorgani"),0,1);
						pc.setFont(9,1);
					  	pc.addCols(cdo.getColValue("descunidad"),0,6);
			pc.addCols(" ", 0,dHeader.size(),10f);
			
			groupDepto = cdo.getColValue("unidadorgani");
			groupSec = cdo.getColValue("seccion");
			}
			else
			{
			
			totxDir = cdo.getColValue("codgerencia");
			pc.setFont(8, 0);
			pc.setVAlignment(1);
			
			pc.addCols("GERENCIA:    "+cdo.getColValue("codgerencia"),0,2,20f,Color.lightGray);
			
			pc.setFont(9,1);
			pc.addCols(cdo.getColValue("descGerencia"),1,4,20f,Color.lightGray);
			
			pc.setFont(8,0);
			pc.addCols("TOTAL EMPLEADO: "+emp_x_dir.get(totxDir),0,2,20f,Color.lightGray);
			
			sectot = 0;
			}
			}
			if (!groupDepto.trim().equals(cdo.getColValue("unidadorgani")))
			{
			
			if ( i != 0 ){
			
			 pc.addCols("Total de Empleados en la sección "+secDes+" --> "+sectot,2,dHeader.size());
			 
			  pc.addCols("Total de Empleados en el departamento "+secDepto+" --> "+emp_x_dir.get(groupDepto),2,dHeader.size());
			
			}
			
			pc.setFont(8, 0);
			pc.addCols("DEPTO:   ",2,1);
			pc.addCols("    "+cdo.getColValue("unidadorgani"),0,1);
			pc.setFont(9,1);
		  	pc.addCols(cdo.getColValue("descunidad"),0,6);
			pc.addCols(" ", 0,dHeader.size(),10f);pc.setFont(8, 0);
			pc.addCols("SECCION:   ",2,1);
			pc.addCols("    "+cdo.getColValue("seccion"),0,1);
		  	pc.addCols(cdo.getColValue("descseccion"),0,6);
		  	
		  
			pc.addCols(" ", 0,dHeader.size(),10f);
			groupSec = cdo.getColValue("seccion");
			
			sectot = 0;
			
			}
			
			if (!groupSec.trim().equals(cdo.getColValue("seccion")))
			{
			
			if ( i != 0 ){
			   pc.addCols("Total de Empleados en la sección "+secDes+" --> "+sectot,2,dHeader.size());
			 pc.setFont(8, 0);
			 			pc.addCols("SECCION:   ",2,1);
			 			pc.addCols("    "+cdo.getColValue("seccion"),0,1);
			 		  	pc.addCols(cdo.getColValue("descseccion"),0,6);
			 		  	
			 		  
			pc.addCols(" ", 0,dHeader.size(),10f);
			sectot = 0;
			}
			
			else
			{
			pc.setFont(8, 0);
			pc.addCols("SECCION:   ",2,1);
			pc.addCols("    "+cdo.getColValue("seccion"),0,1);
		  	pc.addCols(cdo.getColValue("descseccion"),0,6);
		  	
		  
			pc.addCols(" ", 0,dHeader.size(),10f);
			sectot = 0;
			}
			}
    
		pc.setFont(8, 0);
		
		pc.setVAlignment(0);
		  pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("numempleado"),0,1);
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);
	  	    pc.addCols(" "+cdo.getColValue("nombreempleado"),0,1);
			pc.addCols(" "+cdo.getColValue("denominacion"),0,1);
			if(printSal.equalsIgnoreCase("N")){
			   pc.addCols("- - - - - -",1,1);
			}else{
			   pc.addCols(" "+cdo.getColValue("salariobase"),1,1);
			}
	              pc.addCols(" "+cdo.getColValue("fechaingreso"),1,1);
			pc.addCols(" ",0,1);

			pc.setFont(8, 0);
			pc.addCols("",0,dHeader.size());
			
			/*if (!groupDepto.trim().equals(cdo.getColValue("unidadorgani")))
			{
			  totxDept = cdo.getColValue("unidadorgani");
			 
			}*/
		sectot++;
			groupGerencia = cdo.getColValue("codgerencia");
			groupDepto = cdo.getColValue("unidadorgani");
			groupSec = cdo.getColValue("seccion");
			secDepto = cdo.getColValue("descUnidad");
			secDes = cdo.getColValue("descSeccion");
			
			
			

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		pc.setFont(8, 0);
		pc.addCols("",0,dHeader.size());

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
	   pc.addCols("Total de Empleados en la sección "+secDes+" --> "+emp_x_dir.get(groupSec),2,dHeader.size());
	   			 
	pc.addCols("Total de Empleados en el departamento "+secDepto+" --> "+emp_x_dir.get(groupDepto),2,dHeader.size());
	
	
	pc.setFont(9,1); 
	pc.setVAlignment(1);
	pc.addCols(" ",0,dHeader.size());
	pc.addCols("                               TOTAL FINAL DE EMPLEADOS        "+al.size(),0,dHeader.size(),20f, Color.lightGray);
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>