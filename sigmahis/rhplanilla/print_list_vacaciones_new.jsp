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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String anio = CmnMgr.getCurrentDate("yyyy");


if (appendFilter == null) appendFilter = "";

	sql=" select * from( SELECT distinct e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null, e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada, e.primer_apellido)), e.primer_apellido) nombre_empleado, decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||decode(e.sigla,'00','  ','0','  ', e.sigla) ||'-'||to_char(e.tomo)||'-'||to_char(e.asiento)  cedula, e.provincia, e.sigla, e.tomo, e.asiento, e.num_empleado, decode(e.estado,'2','RETORNA','SALE') estatus,  e.estado, e.emp_id, u.descripcion, e.ubic_fisica, to_char(e.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, e.salario_base, to_char(to_date(sv.periodof_inicio,'dd/mm/yyyy'),'dd/mm/yyyy') fInicial, to_char(to_date(sv.periodof_final,'dd/mm/yyyy'),'dd/mm/yyyy') fFinal, sv.dias_tiempo, sv.dias_dinero, 0 pendiente  FROM tbl_pla_empleado e,  tbl_sec_unidad_ejec u, tbl_pla_sol_vacacion sv WHERE   e.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and e.emp_id = sv.emp_id and e.compania = sv.compania and e.ubic_fisica = u.codigo and e.compania = u.compania and ((trunc(sv.periodof_final) >= to_date('"+fecha+"','dd/mm/yyyy') and trunc(sv.periodof_inicio) <= to_date('"+fecha+"','dd/mm/yyyy')) or (trunc(sv.periodof_final) < to_date('"+fecha+"','dd/mm/yyyy'))) and e.estado not in (3,13)  union all SELECT e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null, e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada, e.primer_apellido)), e.primer_apellido) nombre_empleado, decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||decode(e.sigla,'00','  ','0','  ', e.sigla) ||'-'||to_char(e.tomo)||'-'||to_char(e.asiento)  cedula, e.provincia, e.sigla, e.tomo, e.asiento, e.num_empleado, decode(e.estado,'2','RETORNA','SALE') estatus,  e.estado, e.emp_id, u.descripcion, e.ubic_fisica, to_char(e.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, e.salario_base, to_char(to_date(v.periodof_inicio,'dd/mm/yyyy'),'dd/mm/yyyy') fInicial, to_char(to_date(v.periodof_final,'dd/mm/yyyy'),'dd/mm/yyyy') fFinal, 0  dias_tiempo,0 dias_dinero, v.dias_pendiente pendiente  FROM tbl_pla_empleado e,  tbl_sec_unidad_ejec u, tbl_pla_vacacion v WHERE   e.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and e.emp_id = v.emp_id and e.compania = v.cod_compania and e.ubic_fisica = u.codigo and e.compania = u.compania  and e.estado not in (3,13) and  v.dias_pendiente > 0 ) order by ubic_fisica, emp_id, to_date(fInicial,'dd/mm/yyyy') ";

 al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String subtitle = " LISTADO DE ESTATUS DE VACACIONES EMPLEADOS ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".40");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
	
		
	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Cedula ",0);	
		pc.addBorderCols("Nombre del Colaborador",1);
		pc.addBorderCols("Num. Empleado ",1);
		pc.addBorderCols("Fecha Ingreso",1);
		pc.addBorderCols("Salario Base ",1);			
		pc.addCols(" ",1,2);
		
		
		pc.addCols("",0,2);	
		pc.addBorderCols(" Fecha Inicio ",1);
		pc.addBorderCols(" Fecha Final ",1);
		pc.addBorderCols("Días Tiempo ",1);			
		pc.addBorderCols("Días Dinero ",1);
		pc.addBorderCols("Días Pendientes ",1);
	
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    	int  ret = 0;
			int  van = 0;
			
			String tipo = "RETORNA";
			String ubic = "";
			String emp = "";
			String estatus = "";
			
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		 if (!ubic.equalsIgnoreCase(cdo.getColValue("ubic_fisica")))
   			{
			pc.setFont(7, 1);
		pc.addCols(" Area  : [ "+cdo.getColValue("ubic_fisica")+" ] " +cdo.getColValue("descripcion"),0,dHeader.size());
		pc.addCols("",0,dHeader.size());
		    }
			
		 if (!emp.equalsIgnoreCase(cdo.getColValue("emp_id")))
			 {
				pc.setFont(7, 1);
		    pc.addCols(" "+cdo.getColValue("cedula"),1,1);
			pc.addCols(" "+cdo.getColValue("nombre_empleado"),0,1);	
			pc.addCols(" "+cdo.getColValue("num_empleado"),1,1);	
			pc.addCols(" "+cdo.getColValue("fecha_ingreso"),1,1);	
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_base")),1,1);
			pc.addCols(" ",1,2);
			}
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		 
			pc.addCols(" ",1,2);
		    pc.addCols(" "+cdo.getColValue("fInicial"),1,1);
			pc.addCols(" "+cdo.getColValue("fFinal"),0,1);	
			pc.addCols(" "+cdo.getColValue("dias_tiempo"),1,1);	
			pc.addCols(" "+cdo.getColValue("dias_dinero"),1,1);	
			pc.addCols(" "+cdo.getColValue("pendiente"),0,1);	
		
	ubic=cdo.getColValue("ubic_fisica");
	emp=cdo.getColValue("emp_id");
	ret++;	
		
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
	pc.setFont(7, 1);
	pc.addCols("",0,dHeader.size());
	pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>