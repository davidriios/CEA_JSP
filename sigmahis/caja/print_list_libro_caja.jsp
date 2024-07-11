<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>

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

String desc ="";
String appendFilter = request.getParameter("appendFilter");
String appendFilter1 = "", appendFilter2 = "", filter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
StringBuffer sql = new StringBuffer();
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String compania = (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");
String fechaFin = request.getParameter("toDate");
String fechaIni = request.getParameter("xDate");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fechaFin == null) fechaFin = "";
if (fechaIni == null) fechaIni = "";


		sql.append("select  r.cta1||'-'||r.cta2||'-'||r.cta3||'-'||r.cta4||'-'||r.cta5||'-'||r.cta6  cuenta, r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6,r.lado,sum(nvl(r.totales_new,nvl(r.totales,0))) monto,c.descripcion from tbl_con_replibros r,      tbl_con_catalogo_gral c where r.compania = ");
		sql.append((String) session.getAttribute("_companyId"));
			
	if(!fechaIni.trim().equals(""))
	{
		sql.append(" and trunc(r.fecha) >= to_date('");
		sql.append(fechaIni);
		sql.append("','dd/mm/yyyy')");
	}
	if(!fechaFin.trim().equals(""))
	{
		sql.append(" and trunc(r.fecha) <= to_date('");
		sql.append(fechaFin);
		sql.append("','dd/mm/yyyy')");
	}

		
	sql.append(" and c.compania = r.compania and c.cta1 = r.cta1 and c.cta2 = r.cta2 and c.cta3 = r.cta3 and c.cta4 = r.cta4 and c.cta5 = r.cta5 and c.cta6 = r.cta6 group by r.lado,r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6,r.tipo,c.descripcion order by r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6");

al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTABILIDAD";
	String subtitle = "LIBRO DE CAJA";
	String xtraSubtitle = ""+((!fechaIni.trim().equals("")&&!fechaFin.trim().equals(""))?" DEL  "+fechaIni+"  AL  "+fechaFin:" ");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".55");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		
	

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("No. Cuenta",1);
		pc.addBorderCols("Descripci�n",0);
		pc.addBorderCols("D�bito",1);
		pc.addBorderCols("Cr�dito",1);
	pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double totalDb = 0.00,totalCr = 0.00;
	double res = 0.00;
	double debit = 0.00;
	double credit = 0.00;
	double tDebit = 0.00;
	double tCredit = 0.00;


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		
		if(cdo.getColValue("lado").trim().equals("DB"))
		debit = Double.parseDouble(cdo.getColValue("monto"));
		else 
		credit = Double.parseDouble(cdo.getColValue("monto"));
		
					
				pc.addCols(""+cdo.getColValue("cuenta"), 1,1);
				pc.addCols(""+cdo.getColValue("descripcion"), 0,1);
				pc.addCols(""+((debit ==0)?"":CmnMgr.getFormattedDecimal(debit)), 2,1);
				pc.addCols(""+((credit ==0)?"":CmnMgr.getFormattedDecimal(credit)), 2,1);
				
				
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		tDebit += debit;
		tCredit += credit;
		debit =0;
		credit =0;
				
}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			
			pc.addCols(" ", 1,dHeader.size());
			pc.setFont(8, 0,Color.blue);
			
			pc.addCols("Total", 2,2);
			pc.addCols(""+CmnMgr.getFormattedDecimal(tDebit), 2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(tCredit), 2,1);
			/*pc.addCols(" ", 1,dHeader.size());
			pc.addCols("Total Ajuste a  Factura", 1,4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb- totalCr),0,4);*/
	}	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>