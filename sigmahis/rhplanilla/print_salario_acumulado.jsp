<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String subTitle = "";
String empId = request.getParameter("empId");
String noEmpleado = request.getParameter("noEmpleado");
if (empId == null) empId = "";
if (noEmpleado == null) noEmpleado = "";

CommonDataObject cdo2 = null;
if (fp == null) fp="";

if (appendFilter == null) appendFilter = "";
if (!empId.trim().equals(""))appendFilter+=" and a.emp_id="+empId;
if (!noEmpleado.trim().equals(""))appendFilter+=" and a.num_empleado='"+noEmpleado+"'";

sql = "SELECT ALL DECODE(d.provincia,0,' ',00,' ',d.provincia)||RPAD(DECODE(d.sigla,'00','  ','0','  ',d.sigla),2,' ')||'-'||LPAD(TO_CHAR(d.tomo),5,'0')||'-'||LPAD(TO_CHAR(d.asiento),6,'0') cedula,d.compania, d.nombre_empleado, d.num_empleado, d.num_ssocial, d.num_dependiente, d.salario_base, d.rata_hora, d.tipo_renta, d.valor_renta, d.gasto_rep, NVL(a.sal_bruto,0) salarios, NVL(a.imp_renta,0) impuesto_renta,p.quincena||' QUINCENA DE '||decode(p.periodo,0,'.',TO_CHAR(TO_DATE(ROUND(p.periodo/2,0)||'-'||"+anio+",'MM-YYYY'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH')||' DE ') titulo FROM vw_pla_empleado d, tbl_pla_acumulado_empleado a, (select nvl(max(p.periodo),0)periodo,DECODE(MOD(MAX(p.periodo),2),0,'SEGUNDA','PRIMERA') quincena FROM TBL_PLA_PLANILLA_ENCABEZADO p WHERE p.cod_compania = "+(String) session.getAttribute("_companyId")+" and p.cod_planilla = 1 and p.anio = "+anio+") p WHERE d.estado <> 3 and a.anio = "+anio+" and d.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter+ " and d.emp_id = a.emp_id and d.compania = a.cod_compania ORDER BY d.num_empleado";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	cdo2 = (CommonDataObject) al.get(0);
	subTitle = cdo2.getColValue("titulo");
	
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

	float height = 72 * 8.5f;//612height
	float width = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "SALARIO E IMPUESTO SOBRE LA RENTA";
	String subtitle = "ACUMULADOS HASTA LA "+subTitle+" "+anio ;
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
		dHeader.addElement(".55");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".10");

		//table header
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("No. EMPLEADO",0,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("CÉDULA",1,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("NOMBRE DEL EMPLEADO",0,1,1.5f,1.5f,0.0f,0.0f);	
		pc.addBorderCols("SALARIOS",2,1,1.5f,1.5f,0.0f,0.0f);	
		pc.addBorderCols(" ",2,1,1.5f,1.5f,0.0f,0.0f);	
		pc.addBorderCols("IMPUESTO   SOBRE LA RENTA",2,1,1.5f,1.5f,0.0f,0.0f);	
		
		pc.addCols("",0,dHeader.size());
			
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
    
		//table body
		double totSalarios = 0.00;
		double totImpuesto = 0.00;
		
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
				 
		pc.setFont(8, 0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("num_empleado"),0,1);
		pc.addCols(cdo.getColValue("cedula"),0,1);
		pc.addCols(cdo.getColValue("nombre_empleado"),0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salarios")),2,1);
		pc.addCols("",0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("impuesto_renta")),2,1);
		
		 totSalarios += Double.parseDouble(cdo.getColValue("salarios"));	
		 totImpuesto += Double.parseDouble(cdo.getColValue("impuesto_renta"));	
				
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
 	pc.setFont(8, 1);
	pc.addCols(" ",0,2);
	pc.addCols("TOTAL DE EMPLEADOS ==> "+" . . . "+al.size(),1,1);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totSalarios),2,1,0.0f,1.0f,0.0f,0.0f);
	pc.addCols("",0,1);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totImpuesto),2,1,0.0f,1.0f,0.0f,0.0f);
	}
  	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>