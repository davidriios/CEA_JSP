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
==================================================================================

**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
 
String anio = request.getParameter("anio");
String doc = request.getParameter("doc");
CommonDataObject cdo2 = null;


if (appendFilter == null) appendFilter = "";

sql = "select a.ea_ano, a.consecutivo_comp as consecutivo, a.compania, decode(a.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE') as mes, a.clase_comprob, a.descripcion, nvl(a.total_cr,0) as total_cr, nvl(a.total_db,0) as total_db, nvl(a.n_doc,' ') as nDoc, to_char(a.fecha_sistema,'dd/mm/yyyy') as fechaSistema, a.status, a.usuario, b.tipo_mov, b.cta1||'-'||b.cta2||'-'||b.cta3||'-'||b.cta4||'-'||b.cta5||'-'||b.cta6 cuenta, b.concepto,decode(b.tipo_mov,'CR',nvl(b.valor,0),0) valorCr,decode(b.tipo_mov,'DB',nvl(b.valor,0),0) valorDb,  b.comentario, b.renglon from tbl_pla_pre_encab_comprob a, tbl_pla_pre_detalle_comprob b where a.status!='DE' and a.EA_ANO = b.ANO and a.COMPANIA = b.COMPANIA and a.consecutivo_comp = b.consecutivo and a.clase_comprob <> 99  and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.ea_ano = "+anio+" and a.n_doc = '"+doc+"' order by b.renglon";
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
	String title = "PLANILLA";
	String subtitle = "ASIENTO DE PLANILLA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".55");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Renglón",1);
		pc.addBorderCols("Descripción",1);
		pc.addBorderCols("Cuenta",1);
		pc.addBorderCols("Débito",2);
		pc.addBorderCols("Crédito",2);
		
				
		
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
    String pla = "";
	String totalAcr = "";
	String lado = "DB";
	double totAcr = 0.00,  totDb = 0.00, totCr = 0.00 , tot_db = 0.00, tot_cr = 0.00;
	int cont=0;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!pla.equalsIgnoreCase(cdo.getColValue("descripcion")))
		{
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols("  "+cdo.getColValue("descripcion"),0,dHeader.size());
		tot_db += Double.parseDouble(cdo.getColValue("total_db"));
		tot_cr += Double.parseDouble(cdo.getColValue("total_cr"));
		
		}
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("renglon"),1,1);
		pc.addCols(cdo.getColValue("comentario"),0,1);
		pc.addCols(cdo.getColValue("cuenta"),0,1);

		
		pc.addCols(""+(!cdo.getColValue("valorDb").trim().equals("0")?CmnMgr.getFormattedDecimal(cdo.getColValue("valorDb")):""),2,1);	
		pc.addCols(""+(!cdo.getColValue("valorCr").trim().equals("0")?CmnMgr.getFormattedDecimal(cdo.getColValue("valorCr")):""),2,1);	
		pla =  cdo.getColValue("descripcion");
		cont = cont	+ 1;

		totDb += Double.parseDouble(cdo.getColValue("valorDb"));
		totCr += Double.parseDouble(cdo.getColValue("valorCr"));

	
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
		}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	
	pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
	
	pc.setFont(7, 0);
		pc.setVAlignment(0);
		if (tot_db!=tot_cr)
			{
			
			pc.addCols(al.size()+"   Registros     "+" Descuadre *** Verificar ===>    ",2,3);
			} else {
			pc.addCols(al.size()+"   Registros     "+"     ",2,3);
			}
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+tot_db),2,1,0f,1f,0f,0f);
			pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(""+tot_cr),2,1,0f,1f,0f,0f);
			pc.addTable();
			pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>