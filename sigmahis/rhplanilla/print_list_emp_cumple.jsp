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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String mes = request.getParameter("mes");

String filter = "";
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if (mes == null) mes = "";

 if (mes != "")   appendFilter = " and to_char(e.fecha_nacimiento,'mm') = "+mes;

           	sql= "select e.primer_nombre||' '|| decode(e.sexo,'f',decode(e.apellido_casada, null,e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) nombre, e.num_empleado, e.num_ssocial  num_ssocial, decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||decode(e.sigla,'00','  ','0','  ', e.sigla) ||'-'||to_char(e.tomo)||'-'||to_char(e.asiento)  cedula, e.cargo, ca.denominacion, e.unidad_organi unidad, e.ubic_seccion useccion, e.seccion seccion, c.nombre  nombre_cia, to_char(e.fecha_nacimiento,'dd') fechaNac, to_char(e.fecha_nacimiento,'mm') fecha, decode(to_char(e.fecha_nacimiento,'mm'),'01','ENERO' ,'02','FEBRERO' ,'03','MARZO' ,'04','ABRIL' ,'05','MAYO' ,'06','JUNIO' ,'07','JULIO' ,'08','AGOSTO' ,'09','SEPTIEMBRE' ,'10','OCTUBRE' ,'11','NOVIEMBRE' ,'12','DICIEMBRE' ) mes, d.descripcion departamento, d.codigo, e.num_empleado, e.num_ssocial from  tbl_pla_empleado e, tbl_sec_compania c, tbl_pla_cargo ca, tbl_sec_unidad_ejec d where c.codigo = e.compania and ca.codigo = e.cargo and ca.compania = e.compania  and  (d.codigo = nvl(e.ubic_fisica,e.ubic_seccion) and d.compania = e.compania ) and e.estado not in (3,13) and e.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter+ " order by to_char(e.fecha_nacimiento,'mm'), to_char(e.fecha_nacimiento,'dd'), e.primer_nombre,e.segundo_nombre, e.primer_apellido, e.segundo_apellido";
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
	String subtitle = " CUMPLEA�EROS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".12");
		dHeader.addElement(".30");
		dHeader.addElement(".25");
		dHeader.addElement(".33");
				
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("Dia de Cumplea�os",1,1);
		pc.addBorderCols("          Nombre del Empleado ",0,1);	
		pc.addBorderCols("             Area.",0,1);
		pc.addBorderCols("             Cargo.",0,1);
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String meses = ""; 
		int count = 0;
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
    	
			if (!meses.equalsIgnoreCase(cdo.getColValue("fecha")))
			{
			 	  
			   pc.setFont(7, 0);
		      pc.addCols("",0,dHeader.size());
			  
				pc.setFont(11, 3);
				pc.addCols(" CUMPLEA�EROS DEL MES DE :    "+cdo.getColValue("mes"),0,4);
			//pc.addCols("Total de Empleados : ... ",0,2);
			//pc.addCols(" "+htUni.get(un),2,1);
			}
			 	
		///pc.addNewPage();
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		  pc.addCols(" "+cdo.getColValue("fechaNac"),1,1);
		  pc.addCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo.getColValue("departamento"),0,1);
			pc.addCols(" "+cdo.getColValue("denominacion"),0,1);
	   	
	    
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
	
		
			count++;
			meses = cdo.getColValue("fecha");
			
			
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