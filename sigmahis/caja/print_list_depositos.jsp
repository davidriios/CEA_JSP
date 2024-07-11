<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
StringBuffer sbSql = new StringBuffer();
String tipoCliente = request.getParameter("tipoCliente");
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("hh12mmssam");
String fp = request.getParameter("fp");

if (fp == null) fp = "";
if (appendFilter == null) appendFilter = "";
if (fp.trim().equals("CONTA"))appendFilter += " and dep_conta='S'";
else appendFilter += " and a.caja is not null ";
  
		sbSql.append("SELECT a.CONSECUTIVO_AG as codigo, a.BANCO, a.COMPANIA, a.CUENTA_BANCO as cuenta, to_char(a.F_MOVIMIENTO,'dd/mm/yyyy')as fecha, a.TIPO_MOVIMIENTO,a.MONTO, a.LADO, a.ESTADO_TRANS, a.OBSERVACION,a.caja ,a.descripcion||' - '||a.OBSERVACION as descripcion,nvl((select ca.descripcion from tbl_cja_cajas ca where ca.codigo=a.caja and  ca.compania=a.compania),'DEPOSITADO POR CONTABILIDAD') as nombrecaja, ban.nombre as nombrebanco from tbl_con_movim_bancario a,tbl_con_tipo_movimiento b,tbl_con_banco ban where a.tipo_movimiento=1 and a.tipo_movimiento = b.cod_transac  and a.estado_trans = 'T' and a.estado_dep = 'DT' and a.compania = ban.compania and a.banco=ban.cod_banco and a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(appendFilter);
		sbSql.append("order by a.f_movimiento desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+time+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CAJA";
	String subtitle = "REGISTROS DE DEPOSITOS"+((fp.trim().equals("CONTA"))?" POR TURNOS":"");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".25");
		dHeader.addElement(".20");
		dHeader.addElement(".08");
		dHeader.addElement(".33");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row

		pc.setFont(fontSize,1);
		pc.addBorderCols("Código",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Banco",0);
		pc.addBorderCols("Caja",0);
		pc.addBorderCols("Monto",1);
		pc.addBorderCols("Observación",0);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	double totalPag = 0.0;
	double aplicadoPag = 0.0;
	double ajustadoPag = 0.0;
	double porAplicarPag = 0.0;

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo1.getColValue("codigo"), 1,1);
		pc.addCols(" "+cdo1.getColValue("fecha"), 1,1);
		pc.addCols(" "+cdo1.getColValue("nombrebanco"),0,1);
		pc.addCols(" "+cdo1.getColValue("nombrecaja"), 0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("monto")), 2,1);
		pc.addCols(" "+cdo1.getColValue("observacion"), 0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>