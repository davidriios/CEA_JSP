<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String sala = request.getParameter("sala");

String compania = (String) session.getAttribute("_companyId");

sql = "select a.documento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.beneficiario, a.unidad_adm1, to_char(a.monto,'999,999,999.00') monto, a.estado1, decode(a.estado1, 'P', 'Pendiente', 'A', 'Aprobada', 'T', 'Autorizada', 'R', 'Procesada', 'N', 'Anulada', 'X', 'Rechazada') estado1_desc, b.descripcion unidad_descripcion, c.nombre beneficiario_descripcion from tbl_cxp_orden_unidad a, tbl_sec_unidad_ejec b, tbl_con_pagos_otros c where a.estado1 in('P','X','A') and (a.estado_final is null or estado_final='N') and a.compania = b.compania and a.unidad_adm1 = b.codigo and a.compania = c.compania and a.beneficiario = c.codigo and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by a.unidad_adm1, c.nombre, a.fecha desc";
cdo = SQLMgr.getData(sql);

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "SOLICITUDES DE ORDEN DE PAGO";
	String subtitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".50");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	String groupBy = "", groupBy2 = "", groupBy3 = "";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("DOCUMENTO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("BENEFICIARIO",1,2,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MONTO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("ESTADO",1,1,cHeight * 2,Color.lightGray);
	pc.setTableHeader(2);

	double totUnidad = 0.00;
	int pxc = 0;
	int pxcat = 0;
	int pcant = 0;
	String pacId = "", admision = "";
	for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);
		
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad_adm1"))){ // groupBy
			if (i != 0){
				pc.setFont(7, 1);
				pc.addCols("TOTAL X UNIDAD: ",2,4,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
				pc.addCols("",0,1,cHeight);
				pc.addCols(" ",0,dHeader.size(),cHeight);
				totUnidad   = 0.00;
			}
			pc.addCols(" [ "+cdo.getColValue("unidad_adm1") + " ] " + cdo.getColValue("unidad_descripcion"),0,dHeader.size(),cHeight);
		}// groupBy
		
		pc.setFont(7, 0);
		
		pc.addCols(" "+cdo.getColValue("documento"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fecha"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("beneficiario"),2,1,cHeight);
		pc.addCols(" "+cdo.getColValue("beneficiario_descripcion"),0,1,cHeight);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addCols(" "+cdo.getColValue("estado1_desc"),1,1,cHeight);

		totUnidad += Double.parseDouble(cdo.getColValue("monto"));
		
		groupBy = cdo.getColValue("unidad_adm1");

	}//for i

	if (al.size() == 0){
		pc.addCols("No existen registros",1,dHeader.size());
	}	else {
			pc.setFont(7, 1);
				pc.addCols("TOTAL X UNIDAD: ",2,4,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
				pc.addCols("",0,1,cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

