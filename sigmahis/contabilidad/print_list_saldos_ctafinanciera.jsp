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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTS = new ArrayList();
ArrayList alDev = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String desc ="";
String appendFilter = request.getParameter("appendFilter");
String appendFilter1 = "", appendFilter2 = "", filter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
StringBuffer sql = new StringBuffer();
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String compania = request.getParameter("compania");
String fg = request.getParameter("fg");

if (appendFilter == null) appendFilter = "";


sql.append(" SELECT a.ano, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 as cta,  b.descripcion as cuenta, decode(a.status_cta,'CR','Crédito','DB','Débito') as estado, nvl(a.saldo_actual,0)saldo_actual,b.lado_movim lado_mov, nvl(a.saldo_inicial,0)saldo_inicial from tbl_con_plan_cuentas a, tbl_con_catalogo_gral b  WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.compania=b.compania and a.compania=");
sql.append((String) session.getAttribute("_companyId"));
if (!appendFilter.trim().equals(""))
sql.append(appendFilter);
sql.append(" order by a.ano, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6 ");

//print_ingresos_notas_ajustes.jsp

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
	String subtitle = "MANTENIMIENTO SALDOS DE CUENTAS FINANCIERAS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		dHeader.addElement(".35");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("Año",1);
		pc.addBorderCols("Cuenta",0);
		pc.addBorderCols("Descripción",0);
		pc.addBorderCols("Estatus Cta.",0);
		pc.addBorderCols("Saldo Actual",0);
		
		pc.addBorderCols("Saldo I. Débito",1);
		pc.addBorderCols("Saldo I. Crédito",1);
	pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double totalDb = 0.00,totalCr = 0.00,totalSa=0.00;
	double res = 0.00;
	
	String descripcion = "";
	String v_codigo = "";
	String v_monto = "";
	String v_descripcion = "";
	String v_factura = "";

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

					
					pc.addCols(" "+cdo1.getColValue("ano"),1,1);
					pc.addCols(" "+cdo1.getColValue("cta"),0,1);
					pc.addCols(" "+cdo1.getColValue("cuenta"),0,1) ;
					pc.addCols(" "+cdo1.getColValue("estado"),0,1) ;
					pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_actual")),2,1);
					
					
					if(cdo1.getColValue("lado_mov").trim().equals("DB"))
					{
							pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_inicial")),2,1);
							pc.addCols(" ",2,1);
							totalDb += Double.parseDouble(cdo1.getColValue("saldo_inicial"));
					}
					else
					{
							pc.addCols(" ",2,1);
							pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_inicial")),2,1);
							totalCr += Double.parseDouble(cdo1.getColValue("saldo_inicial"));
					}
					totalSa += Double.parseDouble(cdo1.getColValue("saldo_actual"));
		
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
				
}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			
			pc.addCols(" ", 1,dHeader.size());
			pc.setFont(8, 0,Color.blue);
			pc.addCols("Total ", 2,4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalSa), 2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb), 2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalCr), 2,1);
			
			pc.addCols(" ", 1,dHeader.size());
			pc.addCols("Balance Saldo Inicial ", 2,5);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb- totalCr),2,2);
	}	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>