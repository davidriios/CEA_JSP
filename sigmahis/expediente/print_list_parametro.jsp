<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
Reporte
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
ArrayList alDet = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoDet = new CommonDataObject();

String sql = "", sqlDet = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (appendFilter == null) appendFilter = "";

sql = "select a.id, a.descripcion, a.tipo, a.orden, decode(a.status,'A','ACTIVO','INACTIVO') as status, (select description from tbl_sal_tipo_parametro where code=a.tipo) as tipoDesc from tbl_sal_parametro a"+appendFilter+" order by a.tipo, a.descripcion";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "PARAMETROS";
	String subtitle = "";
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".70");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESCRIPCION",1);
		pc.addBorderCols("ORDEN",1);
		pc.addBorderCols("ESTADO",1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);

	
	String tipo = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		sqlDet = "select id, param_id, descripcion, orden, decode(status,'A','ACTIVO','I','INACTIVO') as status, evaluable, comentable from tbl_sal_parametro_det where param_id="+cdo.getColValue("id");
	
	   alDet = SQLMgr.getDataList(sqlDet);

		if (!tipo.equals(cdo.getColValue("tipo"))){ 
	     	pc.setFont(8,1,Color.white);
	     	pc.addBorderCols("["+cdo.getColValue("tipo")+"] "+cdo.getColValue("tipoDesc"),0,dHeader.size(),Color.magenta);
		}
   
		pc.setFont(8, 0);
		pc.addCols(""+cdo.getColValue("id"),2,1);
		pc.addCols(""+cdo.getColValue("descripcion"),0,1);
		pc.addCols(""+cdo.getColValue("orden"),2,1);
		pc.addCols(""+cdo.getColValue("status"),1,1);
		pc.addBorderCols("",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		
	if(cdo.getColValue("tipo").equalsIgnoreCase("ETO") || cdo.getColValue("tipo").equalsIgnoreCase("ETF"))
	{	
		for ( int d = 0; d < alDet.size(); d++ ){
		cdoDet = (CommonDataObject) alDet.get(d);
		
		pc.setFont(8,1,Color.gray);
		pc.addCols(""+cdoDet.getColValue("id"),2,1);
		pc.addCols("       "+cdoDet.getColValue("descripcion"),0,1);
		pc.addCols(""+cdoDet.getColValue("orden"),2,1);
		pc.addCols(""+cdoDet.getColValue("status"),1,1);
		
		}//for paraametro detalle
		pc.addCols("",0,dHeader.size(),8f);
	}	
		
		

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		tipo = cdo.getColValue("tipo");
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>