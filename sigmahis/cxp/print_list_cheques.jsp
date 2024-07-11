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

String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String nombre_cuenta = request.getParameter("nombre_cuenta");
String num_cheque = request.getParameter("num_cheque");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");

String compania = (String) session.getAttribute("_companyId");

sql = "select a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.beneficiario, a.monto_girado, to_char(a.f_emision, 'dd/mm/yyyy') f_emision, a.estado_cheque, decode(a.estado_cheque, 'G', 'Girado','A','Anulado','P','') estado_desc, a.anio, a.num_orden_pago, b.nombre nombre_banco, c.descripcion nombre_cuenta from tbl_con_cheque a, tbl_con_banco b, tbl_con_cuenta_bancaria c where a.compania = b.compania and a.cod_banco = b.cod_banco and a.cod_compania = c.compania and a.cuenta_banco = c.cuenta_banco /*and a.estado_cheque = 'G'*/ and a.cod_compania = " + (String) session.getAttribute("_companyId")+appendFilter+" order by a.num_cheque";

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
	String title = "LISTADO DE CHEQUES";
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
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	String groupBy = "", groupBy2 = "", groupBy3 = "";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("No. Cheque",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CUENTA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("BANCARIA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("BENEFICIARIO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA EMISION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("ESTADO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MONTO",1,1,cHeight * 2,Color.lightGray);
	pc.setTableHeader(2);

	double totUnidad = 0.00;
	int pxc = 0;
	int pxcat = 0;
	int pcant = 0;
	String pacId = "", admision = "";
	for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);
		
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_banco"))){ // groupBy
			if (i != 0){
				pc.setFont(7, 1);
				pc.addCols("TOTAL X BANCO: ",2,6,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
				
				pc.addCols(" ",0,dHeader.size(),cHeight);
				totUnidad   = 0.00;
			}
			pc.addCols(" [ "+cdo.getColValue("cod_banco") + " ] " + cdo.getColValue("nombre_banco"),0,dHeader.size(),cHeight);
		}// groupBy
		
		pc.setFont(7, 0);
		
		pc.addCols(" "+cdo.getColValue("num_cheque"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("cuenta_banco"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nombre_cuenta"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("beneficiario"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("f_emision"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("estado_desc"),1,1,cHeight);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_girado")),2,1,cHeight);

		totUnidad += Double.parseDouble(cdo.getColValue("monto_girado"));
		
		groupBy = cdo.getColValue("cod_banco");

	}//for i

	if (al.size() == 0){
		pc.addCols("No existen registros",1,dHeader.size());
	}	else {
			pc.setFont(7, 1);
				pc.addCols("TOTAL X BANCO: ",2,6,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
			
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

