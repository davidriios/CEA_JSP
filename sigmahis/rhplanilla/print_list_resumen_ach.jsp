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
ArrayList tot = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String userName = UserDet.getUserName();
String fechaProc = request.getParameter("fecha"); 
String anio = request.getParameter("anio");
String trimestre = request.getParameter("trimestre");
String mes = request.getParameter("mes");
String mes1 = ""; 
String mes2 = "";
String mes3 = "";
String subTitle = "";

CommonDataObject cdo2 = null;
if (fp == null) fp="";

Hashtable _mes = new Hashtable();

if (mes != null )
{
  _mes.put("01","ENERO");
  _mes.put("02","FEBRERO");
  _mes.put("03","MARZO");
  _mes.put("04","ABRIL");
  _mes.put("05","MAYO");
  _mes.put("06","JUNIO");
  _mes.put("07","JULIO");
  _mes.put("08","AGOSTO");
  _mes.put("09","SEPTIEMBRE");
  _mes.put("10","OCTUBRE");
  _mes.put("11","NOVIEMBRE");
  _mes.put("12","DICIEMBRE");
 }

if (appendFilter == null) appendFilter = "";

sql = "select TO_CHAR(a.cod_acreedor) cod_acreedor, e.cod_acreedor cod_acr, e.nombre, SUM(monto_acreedor) monto from tbl_pla_temporal_cheque a, tbl_pla_acreedor e WHERE a.cod_compania = "+(String) session.getAttribute("_companyId")+" AND e.cod_acreedor = a.cod_acreedor AND e.compania = a.cod_compania AND e.forma_pago = 2 AND e.ruta IS NOT NULL group by a.cod_acreedor, e.cod_acreedor, e.nombre having SUM(monto_acreedor) > 0 order by a.cod_acreedor";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
		
	Hashtable htUni = new Hashtable();
	
	cdo2 = (CommonDataObject) al.get(0);
	subTitle = cdo2.getColValue("quincena");
	
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
	String title = "RESUMEN DE PAGO A ACREEDORES POR ACH";
	String subtitle = "CORRESPONDIENTE AL MES DE "+_mes.get(mes)+" DE "+anio ;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".70");
		dHeader.addElement(".15");
		
		//table header
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("CODIGO",0,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("NOMBRE DEL ACREEDOR",0,1,1.5f,1.5f,0.0f,0.0f);	
		pc.addBorderCols("MONTO",2,1,1.5f,1.5f,0.0f,0.0f);	
		
		
		pc.addCols("",0,dHeader.size());
			
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
    
		//table body
		double totMonto = 0.00;
		
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
				 
		pc.setFont(8, 0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("cod_acr"),0,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		
		
		 totMonto += Double.parseDouble(cdo.getColValue("monto"));	
		 	
				
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
 	pc.setFont(8, 1);
	pc.addCols(" ",0,1);
	pc.addCols("TOTALES ==> "+" . . . "+al.size(),1,1);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totMonto),2,1,0.0f,1.0f,0.0f,0.0f);
	
	}
  	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>