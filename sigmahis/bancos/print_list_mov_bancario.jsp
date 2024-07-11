<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
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
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
if (appendFilter == null) appendFilter = "";

sql = "SELECT a.consecutivo_ag, a.tipo_movimiento as tipoCode, b.descripcion as tipo, a.cuenta_banco as cuentaCode, c.descripcion as cuenta, a.banco as bancoCode, d.nombre as banco, to_char(a.f_movimiento,'dd/mm/yyyy')as fecha, a.consecutivo_ag as consecutivo, decode(estado_dep,'DT','EN TRANSITO','DN','DEPOSITADO') as estado_dep, decode(estado_trans,'T','TRAMITADA','C','CONCILIADA','A','ANULADA') as estado,a.monto FROM tbl_con_movim_bancario a, tbl_con_tipo_movimiento b, tbl_con_cuenta_bancaria c, tbl_con_banco d where a.tipo_movimiento=b.cod_transac and a.cuenta_banco=c.cuenta_banco and a.banco=c.cod_banco and a.compania=c.compania and a.compania = d.compania and a.banco=d.cod_banco and a.compania="+ (String) session.getAttribute("_companyId")+appendFilter + " order by c.descripcion, d.nombre";

al = SQLMgr.getDataList(sql);

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
	String title = "CONTABILIDAD";
	String subtitle = "MOVIMIENTOS BANCARIOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		
			dHeader.addElement(".17");
			dHeader.addElement(".30");
			dHeader.addElement(".15");
			dHeader.addElement(".08");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		
		pc.addBorderCols("BANCO",0);
		pc.addBorderCols("CUENTA",0);
		pc.addBorderCols("TIPO",0);
		pc.addBorderCols("FECHA",0);
		pc.addBorderCols("ESTADO",0);
		pc.addBorderCols("ESTADO DEP.",0);
		pc.addBorderCols("MONTO",0);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	for (int i=0; i<al.size(); i++)
	{
		 cdo = (CommonDataObject) al.get(i);

		pc.addCols(" "+cdo.getColValue("banco"),0,1);
		pc.addCols(" "+cdo.getColValue("cuenta"),0,1);
		pc.addCols(" "+cdo.getColValue("tipo"),0,1);
		pc.addCols(" "+cdo.getColValue("fecha"),0,1);
		pc.addCols(" "+cdo.getColValue("estado"),0,1);
		pc.addCols(" "+cdo.getColValue("estado_dep"),0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		
		

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>