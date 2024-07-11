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
sb_r1005
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alGroup = new ArrayList();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String userName = UserDet.getUserName();
String fDate = request.getParameter("fDate");
String fc1 = request.getParameter("fc1");
String fc2 = request.getParameter("fc2");
String bf = request.getParameter("bf");
String pf1 = request.getParameter("pf1");
String pf2 = request.getParameter("pf2");
String pf3 = request.getParameter("pf3");
String pf4 = request.getParameter("pf4");
String pf5 = request.getParameter("pf5");

if (fDate == null) CmnMgr.getCurrentDate("dd/mm/yyyy");
if (fc1 == null || fc1.trim().equals("")) fc1 = "0";
if (fc2 == null || fc2.trim().equals("")) fc2 = "0";
if (bf == null || bf.trim().equals("")) bf = "0";
if (pf1 == null || pf1.trim().equals("")) pf1 = "0";
if (pf2 == null || pf2.trim().equals("")) pf2 = "0";
if (pf3 == null || pf3.trim().equals("")) pf3 = "0";
if (pf4 == null || pf4.trim().equals("")) pf4 = "0";
if (pf5 == null || pf5.trim().equals("")) pf5 = "0";

sbSql.append("select distinct z.codigo, z.descripcion from tbl_con_grupos_rep z, tbl_con_detalle_rep y, tbl_con_cuenta_bancaria x where z.cod_rep = 115 and x.estado_cuenta <> 'CER' and z.codigo = y.cod_grupo and z.cod_rep = y.cod_rep and z.compania = y.compania and y.cia_cta = x.compania and  y.cta1 = x.cg_1_cta1 and y.cta2 = x.cg_1_cta2 and y.cta3 = x.cg_1_cta3 and y.cta4 = x.cg_1_cta4 and y.cta5 = x.cg_1_cta5 and y.cta6 = x.cg_1_cta6 order by 2");
alGroup = SQLMgr.getDataList(sbSql.toString());


sbSql = new StringBuffer();
sbSql.append("select y.*, (select nombre from tbl_sec_compania where codigo = y.cia_cta) as cia_cta_nombre");
for (int g=0; g<alGroup.size(); g++)
{
	CommonDataObject group = (CommonDataObject) alGroup.get(g);
	if (g == 0) sbSql.append(", y.grupo");
	else sbSql.append(" + y.grupo");
	sbSql.append(group.getColValue("codigo"));
}
sbSql.append(" as total from (");

sbSql.append("select z.cia_cta");
for (int g=0; g<alGroup.size(); g++)
{
	CommonDataObject group = (CommonDataObject) alGroup.get(g);
	sbSql.append(", sum(decode(z.cod_grupo,");
	sbSql.append(group.getColValue("codigo"));
	sbSql.append(",fn_con_saldo_bancario(z.cia_cta,z.cta1||z.cta2||z.cta3||z.cta4,'");
	sbSql.append(fDate);
	sbSql.append("'),0)) as grupo");
	sbSql.append(group.getColValue("codigo"));
}
sbSql.append(" from (");

sbSql.append("select distinct b.cod_grupo, b.cia_cta, b.cta1, b.cta2, b.cta3, b.cta4 from tbl_con_cuenta_bancaria a, tbl_con_detalle_rep b where a.estado_cuenta <> 'CER' and b.cod_rep = 115 and a.compania = b.cia_cta and a.cg_1_cta1 = b.cta1 and a.cg_1_cta2 = b.cta2 and a.cg_1_cta3 = b.cta3 and a.cg_1_cta4 = b.cta4 and a.cg_1_cta5 = b.cta5 and a.cg_1_cta6 = b.cta6");

sbSql.append(") z group by z.cia_cta");

sbSql.append(") y order by 1");
al = SQLMgr.getDataList(sbSql.toString());

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
	float height = 72 * 14f;//1008
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COMPAÑIAS SUBSIDIARIAS";
	String subtitle = "INFORME DE CAJA Y BANCOS (EN BALBOAS)";
	String xtraSubtitle = "FECHA: "+fDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector vDeposit = new Vector();
		vDeposit.add(".4");
		vDeposit.add(".1");
		vDeposit.add(".1");
		vDeposit.add(".1");
		vDeposit.add(".1");
		vDeposit.add(".1");
		vDeposit.add(".1");

	//table header
	pc.setNoColumnFixWidth(vDeposit);
	pc.createTable("deposit");
		pc.setFont(fontSize,1);
		pc.addBorderCols("DEPOSITO A PLAZO FIJO",1,1);
		pc.addBorderCols("PROGRESO, S.A.",1,1);
		pc.addBorderCols("BANISTMO ASS.",1,1);
		pc.addBorderCols("BCO. GENERAL",1,1);
		pc.addBorderCols("TOWERBANK",1,1);
		pc.addBorderCols("",1,1);
		pc.addBorderCols("",1,1);

		pc.setFont(fontSize,0);
		pc.addCols("Fondo de Censantía CSF",0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(fc1),2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);

		pc.addCols("Fondo de Censantía BRF",0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(fc2),2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);

		pc.addCols("Bonos Corporativos y Otros",0,1);
		pc.addCols("",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(bf),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(pf1),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(pf2),2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);

		pc.addCols("Inversiones con Terceros",0,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(pf5),2,1);
		pc.addCols("",2,1);

		pc.addCols("Banistmo - Bethania",0,1);
		pc.addCols("",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(pf3),2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);

		pc.addCols("Banistmo - Paitilla",0,1);
		pc.addCols("",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(pf4),2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);

		double t1 = Double.parseDouble(fc1) + Double.parseDouble(fc2);
		double t2 = Double.parseDouble(bf) + Double.parseDouble(pf3) + Double.parseDouble(pf4);
		double t3 = Double.parseDouble(pf1);
		double t4 = Double.parseDouble(pf2);
		double t5 = Double.parseDouble(pf5);
		pc.setFont(fontSize,1);
		pc.addBorderCols("",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(t1),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(t2),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(t3),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(t4),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(t5),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("",2,1,0.0f,0.5f,0.0f,0.0f);


	double tmp = Math.round(7000 / (alGroup.size() + 1));
	double xCol = tmp / 10000;
	Vector vHeader = new Vector();
		vHeader.addElement(".30");//compania
		for (int g=0; g<(alGroup.size() + 1); g++) { vHeader.addElement(""+xCol); }

	//table header
	pc.setNoColumnFixWidth(vHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, vHeader.size());

		//second row
		pc.setFont(fontSize,1);
		pc.addBorderCols("CUENTAS CORRIENTES",1,1);
		pc.addBorderCols("TOTAL",1,1);
		for (int g=0; g<alGroup.size(); g++) { CommonDataObject group = (CommonDataObject) alGroup.get(g); pc.addBorderCols(group.getColValue("descripcion"),1,1); }
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(fontSize,0);
	double total = 0.00;
	double[] sTotal = new double[alGroup.size()];
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);

		pc.addCols(cdo.getColValue("cia_cta_nombre"),0,1);
		double saldo = Double.parseDouble(cdo.getColValue("total"));
		pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);
		total += saldo;

		for (int g=0; g<alGroup.size(); g++)
		{
			CommonDataObject group = (CommonDataObject) alGroup.get(g);
			saldo = Double.parseDouble(cdo.getColValue("grupo"+group.getColValue("codigo")));
			sTotal[g] += saldo;
			pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);
		}

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}

	if (al.size() > 0)
	{
		pc.setFont(fontSize,1);
		pc.addBorderCols(" ",2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(total),2,1,0.0f,0.5f,0.0f,0.0f);
		for (int g=0; g<alGroup.size(); g++) { pc.addBorderCols(CmnMgr.getFormattedDecimal(sTotal[g]),2,1,0.0f,0.5f,0.0f,0.0f); }
		pc.flushTableBody(true);
		pc.deleteRows(1,2);
		pc.setTableHeader(0);

		pc.addNewPage();
		pc.addTableToCols("deposit",1,vHeader.size());
	}
	else pc.addCols("No hay registros",1,vHeader.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>