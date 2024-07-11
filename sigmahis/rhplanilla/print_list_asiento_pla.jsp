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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String anio = request.getParameter("anio");
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String doc = request.getParameter("anio")+"-"+request.getParameter("cod")+"-"+request.getParameter("num");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

	sql = "select a.ea_ano, a.consecutivo, a.compania, decode(a.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE') as mes, a.clase_comprob, a.descripcion, to_char(a.total_cr,'99,999,999,990.00') total_cr, to_char(a.total_db,'99,999,999,990.00') total_db, nvl(a.n_doc,' ') as nDoc, to_char(a.fecha_sistema,'dd/mm/yyyy') as fechaSistema, a.status, a.usuario, b.tipo_mov, b.cta1||'-'||b.cta2||'-'||b.cta3||'-'||b.cta4||'-'||b.cta5||'-'||b.cta6 cuenta, b.concepto, to_char(b.valor,'99,999,999,990.00') valor, b.comentario, b.renglon from tbl_pla_pre_encab_comprob a, tbl_pla_pre_detalle_comprob b where a.status!='DE' and a.EA_ANO = b.ANO and a.COMPANIA = b.COMPANIA and a.CONSECUTIVO = b.consecutivo and a.clase_comprob <> 99  and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.ea_ano = "+anio+" and a.n_doc = '"+doc+"' order by b.renglon";
 al = SQLMgr.getDataList(sql);

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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = " ASIENTO DE PLANILLA  ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05");
		dHeader.addElement(".45");
		dHeader.addElement(".20");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Sec. ",0);	
		pc.addBorderCols("Descripción",0);
	  pc.addBorderCols("Número de Cuenta ",1);	
		pc.addBorderCols("Débito",1);
		pc.addBorderCols("Crédito",1);
	
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		 String nombrePla = "";
	   String lado = "DB";
		 String tot_db="";
     String tot_cr="";
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
    	
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		if (!nombrePla.equalsIgnoreCase(cdo.getColValue("descripcion")))
		{
		pc.addCols(" "+cdo.getColValue("descripcion"),0,5);
		}
			pc.addCols(" "+cdo.getColValue("renglon"),0,1);
			pc.addCols(" "+cdo.getColValue("comentario"),0,1);
			pc.addCols(" "+cdo.getColValue("cuenta"), 0,1);
			
		if (!lado.equalsIgnoreCase(cdo.getColValue("tipo_mov")))
		 	{
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("valor"),2,1);
			} else { 
			pc.addCols(" "+cdo.getColValue("valor"),2,1);
			pc.addCols(" ",0,1);
		 	} 	
			
	  			
		nombrePla=cdo.getColValue("descripcion");
		tot_db=cdo.getColValue("total_db");
		tot_cr=cdo.getColValue("total_cr");
			
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,3);
	pc.addCols(" TOTAL DEBITO ",2,1);
	pc.addCols(" TOTAL CREDITO ",2,1);
	pc.addCols(" ",2,3);
	pc.addCols(" "+tot_db,2,1);
	pc.addCols(" "+tot_cr,2,1);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>