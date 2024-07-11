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
/*
REPORTE DE ACTIVOS MOVIMIENTO   ACT005.RDF

*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDet = new ArrayList();
String sql = "";
String sqlT = "";
String sqlU = "";

String desde = request.getParameter("desde");
String hasta  = request.getParameter("hasta");
String tipo  = request.getParameter("tipo");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if(desde == null) desde = "";
if(hasta == null) hasta = "";
if(tipo == null) tipo = "";

if (!desde.equals(""))
{
 appendFilter += " and sa.fecha_sal >= '"+desde+"'";
}
if (!hasta.equals(""))
{
 appendFilter += " and sa.fecha_sal <= '"+hasta+"'";
}

if (!tipo.equals(""))
{
 appendFilter += " and sa.tiposal = '"+tipo+"'";
}
sql = "select to_char(sa.fecha_sal,'dd/mm/yyyy') fecha, sa.num_doc_sal num_doc, sa.sec_activo secuencia, d.descripcion desc_activo, ue.descripcion salida, sa.beneficiario, sa.resolucion_hacienda, nvl(sa.valor_actual,0) + nvl(sa.valor_mejora,0) valor, nvl(a.valor_actual,0) actual, decode(sa.tiposal,1,'Donación',2,'Venta',3,'Venta',4,'Descarte') tipo from tbl_con_detalle_otro d, tbl_sec_unidad_ejec ue, tbl_con_salida_activos sa, tbl_con_activos a where d.codigo_detalle = sa.cta3_detalle and ue.compania = d.cod_compania and a.secuencia(+) = sa.sec_activo and a.compania(+) = d.cod_compania and ue.codigo(+) = sa.unid_sal and d.cod_compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by sa.fecha_sal, sa.num_doc_sal";

al = SQLMgr.getDataList(sql);


double monto_total = 0.00,monto_total_ini =0.00,monto_total_dep=0.00;	
double total_act   = 0.00,total_ini =0.00,total_dep=0.00;
double total_cta_act   = 0.00,total_cta_ini =0.00,total_cta_dep=0.00;
	

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
	String subtitle = "ADMINISTRACION DE BIENES PATRIMONIALES";
	String xtraSubtitle = "INFORME DE SALIDA DE ACTIVOS";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dDetalle = new Vector();
		dDetalle.addElement(".12");
		dDetalle.addElement(".13");
		dDetalle.addElement(".12");
		dDetalle.addElement(".13");
		dDetalle.addElement(".10");
		dDetalle.addElement(".20");
		dDetalle.addElement(".20");
		
 pc.setNoColumnFixWidth(dDetalle);
		
	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row
		pc.setFont(6, 1);
		pc.addCols("  Salida de Activos del :    "+desde+"  al  "+hasta,1,dDetalle.size());
		
		pc.setFont(6, 1);
	    int no = 0;
		 String cod = "";
		 String esp = "";
	
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		pc.setNoColumnFixWidth(dDetalle); 
			
		pc.addCols("Fecha Salida.",1,1);
		pc.addCols("No. Docum.",1,1);
		pc.addCols("Secuencia ",1,1);	
		pc.addCols("Activo ",1,1);
		pc.addCols("Unidad Salida ",1,1);	
		pc.addCols("Beneficiario ",1,1);
		pc.addCols("Valor Actual al momento de la salida ",1,1);
		pc.addCols("Valor Actual ",1,1);
		pc.addCols("Tipo de Salida",1,1);
		
		pc.setFont(6, 0);
		pc.setVAlignment(0);
		
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);
			pc.addCols(" "+cdo.getColValue("num_doc"),0,1);
			pc.addCols(" "+cdo.getColValue("secuencia"),0,1);
			pc.addCols(" "+cdo.getColValue("desc_activo"),0,1);
			pc.addCols(" "+cdo.getColValue("salida"),0,1);
			pc.addCols(" "+cdo.getColValue("beneficiario"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("actual")),2,1);
			pc.addCols(" "+cdo.getColValue("tipo"),0,1);
			
		total_act  += Double.parseDouble(cdo.getColValue("valor"));	
		
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
	pc.setFont(6, 0);
	pc.setVAlignment(0);
		
		pc.addCols("Total por Valor Actual ",2,6);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_act),2,1);
		pc.addCols(" ",0,2);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>