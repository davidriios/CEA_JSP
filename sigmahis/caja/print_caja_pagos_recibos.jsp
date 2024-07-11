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
F L A G   D E S C R I P C I O N                     R E P O R T E
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al 		= new ArrayList();
ArrayList alAN		= new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlAn = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String compania = request.getParameter("compania");
String fecha_ini = request.getParameter("fecha_ini");
String descCaja = request.getParameter("descCaja");
String descCajera = request.getParameter("descCajera");

if (appendFilter == null) appendFilter = "";
if (caja == null) caja = "";
if (turno == null) turno = "";


// activos
sbSql.append("select distinct b.codigo recibo,to_date('"+fecha_ini+"','dd/mm/yyyy') as fecha,a.pago_total pagos,a.compania ctpcompania,a.anio ctpanio,a.codigo ctpcodigo,nvl(a.nombre,'**S/N**') nombre,a.turno,a.caja,(select cja.descripcion from tbl_cja_cajas cja where cja.codigo=a.caja and cja.compania =a.compania) descCaja from tbl_cja_transaccion_pago a, tbl_cja_recibos b where a.codigo =b.ctp_codigo and a.anio = b.ctp_anio and a.compania = b.compania and b.compania =  ");
sbSql.append(compania);
sbSql.append(" and ((a.rec_status = 'A') or (a.rec_status='I' and a.turno<>a.turno_anulacion))");
if(!turno.trim().equals("")){sbSql.append(" and a.turno = ");
sbSql.append(turno);}
if(!caja.trim().equals("")){sbSql.append(" and a.caja =");
sbSql.append(caja);}
sbSql.append(" order by a.caja,a.turno,a.recibo");
al = SQLMgr.getDataList(sbSql.toString());

// anulados
sbSqlAn.append("select distinct b.codigo recibo,to_date('"+fecha_ini+"','dd/mm/yyyy') as fecha,a.pago_total pagos,a.compania ctpcompania,a.anio ctpanio,a.codigo ctpcodigo,nvl(b.nombre,'**S/N**') nombre,a.turno_anulacion as turno,a.caja ,(select cja.descripcion from tbl_cja_cajas cja where cja.codigo=a.caja and cja.compania =a.compania) descCaja from tbl_cja_transaccion_pago a, tbl_cja_recibos b where a.codigo =b.ctp_codigo and a.anio = b.ctp_anio and a.compania = b.compania and b.compania =  ");
sbSqlAn.append(compania);
sbSqlAn.append(" and a.rec_status='I' ");
if(!turno.trim().equals("")){sbSqlAn.append(" and a.turno_anulacion=");
sbSqlAn.append(turno);}
if(!caja.trim().equals("")){sbSqlAn.append(" and a.caja =");
sbSqlAn.append(caja);}
sbSql.append(" order by a.caja,a.turno_anulacion,a.recibo");

alAN = SQLMgr.getDataList(sbSqlAn.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

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

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	int groupFontSize = 9;
	int contentFontSize = 8;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PAGOS RECIBOS EN CAJA";
	String subtitle ="CAJERO:  "+descCajera;

	String xtraSubtitle = "TURNO:   "+turno;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		
		if(turno.trim().equals("")){
		dHeader.addElement(".15");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".35");
		}else {dHeader.addElement(".20");dHeader.addElement(".60");}
		dHeader.addElement(".20");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.addBorderCols("Recibo",1);
	
	if(turno.trim().equals("")){ 
		pc.addBorderCols("Caja",1);
		pc.addBorderCols("Turno",1);
		} 
		pc.addBorderCols("Nombre",1);
	pc.addBorderCols("Pago",1);
  pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double monto_total = 0.00;
	pc.setFont(groupFontSize,1);
	pc.addCols("RECIBOS ACTIVOS",0,dHeader.size());
	for (int i=0; i<al.size(); i++)
	{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			pc.setFont(contentFontSize, 0);
			pc.addCols(" "+cdo.getColValue("recibo"), 0,1);
			//pc.addCols(" "+cdo1.getColValue("fecha"), 1,1);
			if(turno.trim().equals("")){ 
		pc.addCols(" "+cdo.getColValue("descCaja"), 0,1);
		pc.addCols(" "+cdo.getColValue("turno"), 0,1);
		} 
			pc.addCols(" "+cdo.getColValue("Nombre"), 0,1);
	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("pagos")), 2,1);
			monto_total +=  Double.parseDouble(cdo.getColValue("pagos"));
	}
	pc.setFont(groupFontSize, 1);
	if (al.size() == 0) pc.addCols("No hay recibos en este turno",0,dHeader.size());
	else{
		if(turno.trim().equals(""))pc.addCols("Total",2,4);
		else pc.addCols("Total",2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_total),2,1);
	}

	pc.addCols("",0,dHeader.size());
	pc.setFont(groupFontSize,1);
	pc.addCols("RECIBOS ANULADOS",0,dHeader.size());

	//*********************************************************
	//table body
	groupBy = "";
	groupTitle = "";
	monto_total = 0.00;
	for (int i=0; i<alAN.size(); i++)
	{
			CommonDataObject cdo = (CommonDataObject) alAN.get(i);
			pc.setFont(contentFontSize, 0);
			pc.addCols(" "+cdo.getColValue("recibo"), 0,1);
			//pc.addCols(" "+cdo1.getColValue("fecha"), 1,1);
			pc.addCols(" "+cdo.getColValue("Nombre"), 0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("pagos")), 2,1);
			monto_total +=  Double.parseDouble(cdo.getColValue("pagos"));
	}
	pc.setFont(groupFontSize, 1);
	if (alAN.size() == 0) pc.addCols("No hay recibos anulados en este turno",0,dHeader.size());
	else{
		pc.addCols("Total",2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_total),2,1);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>