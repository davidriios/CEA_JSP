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
ArrayList tot = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String userName = UserDet.getUserName();
String fechaProc = request.getParameter("fecha"); 
String anio = request.getParameter("anio");
String trimestre = request.getParameter("trimestre");
String mes1 = ""; 
String mes2 = "";
String mes3 = "";

CommonDataObject cdo2 = null;
if (fp == null) fp="";

if (appendFilter == null) appendFilter = "";

if(trimestre.equals("1")) 
{ mes1 ="ENERO";
	mes2 ="FEBRERO";
	mes3 ="MARZO";
} else if(trimestre.equals("2")) 
{ mes1 ="ABRIL";
	mes2 ="MAYO";
	mes3 ="JUNIO";
} else if(trimestre.equals("3")) 
{ mes1 ="JULIO";
	mes2 ="AGOSTO";
	mes3 ="SEPTIEMBRE";
} else if(trimestre.equals("4")) 
{ mes1 ="OCTUBRE";
	mes2 ="NOVIEMBRE";
	mes3 ="DICIEMBRE";
	}


sql = "select  a.anio, a.trimestre, to_char(a.provincia,'9')||'-'||a.sigla||'-'||to_char(a.tomo,'00009')||'-'||to_char(a.asiento,'000009') cedula, a.provincia, a.sigla, a.tomo, a.asiento, nvl(a.salario_mes1,0) salario_mes1 , a.mes1, nvl(a.salario_mes2,0) salario_mes2, a.mes2, nvl(a.salario_mes3,0) salario_mes3, a.mes3, a.salario_prom, a.salario_base, nvl(a.prima,0)prima, nvl(a.indemnizacion,0)indemnizacion, nvl(a.prima,0) + nvl(a.indemnizacion,0) total, a.observacion, e.primer_nombre||' '||decode(e.sexo,'F', decode(e.apellido_casada, null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada, e.primer_apellido)),e.primer_apellido) nombre_empl, e.num_empleado, e.num_ssocial, e.sexo, to_char(e.fecha_ingreso,'dd/mm/yyyy') fecha from tbl_pla_empleado e, tbl_pla_fondo_cesantia a where e.emp_id = a.emp_id and e.compania = a.cod_compania and a.trimestre = "+trimestre+" and a.anio = "+anio+"  and a.cod_compania= "+(String) session.getAttribute("_companyId")+ appendFilter + " order by e.num_empleado";
al = SQLMgr.getDataList(sql);



if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String montoTotal = "";
	
	Hashtable htUni = new Hashtable();

	
	
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
	String title = "FONDO DE CESANTÍA";
	String subtitle = " "+trimestre+" TRIMESTRE "+anio;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".04");
		dHeader.addElement(".12");
		dHeader.addElement(".09");
		dHeader.addElement(".05");
		dHeader.addElement(".04");
		dHeader.addElement(".07");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".11");
		
		

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addCols(" # ASIG.",1,1);
		pc.addCols("NOMBRE DEL EMPLEADO",0,1);
		pc.addCols("CEDULA",1,1);
		pc.addCols("SEGURO SOCIAL",1,1);
		pc.addCols("SEXO",1,1);
		pc.addCols("FECHA INGRESO",1,1);
		pc.addCols("SALARIO MES 1 "+mes1,1,1);
		pc.addCols("SALARIO MES 2 "+mes2,1,1);
		pc.addCols("SALARIO MES 3 "+mes3,1,1);
		pc.addCols("SALARIO PROMEDIO",2,1);
		pc.addCols("SALARIO BASE",2,1);
		pc.addCols("APORTE PRIMA ANT.",2,1);
		pc.addCols("APORTE INDEMNIZACION",2,1);
		pc.addCols("TOTAL PAGAR",2,1);
		pc.addCols("OBSERVACION",1,1);
		
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
		/*	
		pc.setFont(7, 1);
		pc.addCols("FECHA DE AUMENTO :  "+fechaProc,1,2);
		pc.addCols(" ",0,4);
		
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size());
			*/
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
    String sec = "";
	String totalAcr = "";
	double totalPrima = 0.00;
	double totalInden = 0.00;
	double totalSalario = 0.00;
	int cont=0;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(""+cdo.getColValue("num_empleado"),0,1);
		pc.addCols(""+cdo.getColValue("nombre_empl"),0,1);
		pc.addCols(""+cdo.getColValue("cedula"),1,1);
		pc.addCols(""+cdo.getColValue("num_ssocial"),0,1);
		pc.addCols(""+cdo.getColValue("sexo"),1,1);
		pc.addCols(""+cdo.getColValue("fecha"),1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_mes1")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_mes2")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_mes3")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_prom")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("salario_base")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("prima")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("indemnizacion")),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		
		totalPrima   += Double.parseDouble(cdo.getColValue("prima"));
		totalInden   += Double.parseDouble(cdo.getColValue("indemnizacion"));
		totalSalario += Double.parseDouble(cdo.getColValue("total"));
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(9, 1);
		pc.addBorderCols("",0,15);
		pc.addCols(" T O T A L E S:==============>> ",0,11);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totalPrima),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totalInden),2,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(totalSalario),2,1);
		pc.addCols("",0,1);
	}
	

  pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>