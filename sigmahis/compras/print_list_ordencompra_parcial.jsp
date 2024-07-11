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
if (appendFilter == null) appendFilter = "";

sbSql.append("SELECT a.anio, a.tipo_compromiso, a.num_doc, a.compania, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','C','APROB. CONT.','F','APROB. FIN.') desc_status, to_char(a.monto_total,'99,999,999,990.00') as monto_total, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor, a.numero_factura, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc,a.usuario from tbl_com_comp_formales a,tbl_com_proveedor b,tbl_inv_almacen c  where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and a.compania = c.compania  and a.tipo_compromiso = 3 and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(appendFilter);

sbSql.append("order by a.cod_proveedor,a.anio desc , a.fecha_documento desc,a.num_doc desc");


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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COMPRAS";
	String subtitle = "ORDENES DE COMPRAS";
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
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".25");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		//second row
		pc.setFont(fontSize,1);
		pc.addBorderCols("Año",1);
		pc.addBorderCols("No. Solicitud",1);
		pc.addBorderCols("Fecha Documento",1);
		pc.addBorderCols("Fecha Vencimiento",1);
		pc.addBorderCols("Tipo de Pago",0);
		pc.addBorderCols("Almacén",0);
		pc.addBorderCols("No. de Factura",1);
		pc.addBorderCols("Estado",0);
		pc.addBorderCols("Monto",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

    String groupBy ="";
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("nombre_proveedor")))
		{ 
			pc.setFont(fontSize,1);
			pc.addCols("Proveedor: ",1,2);
			pc.addCols(" "+cdo.getColValue("nombre_proveedor"),0,7);
		}
		pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		
		pc.addCols(""+cdo.getColValue("anio"),1,1);
		pc.addCols(" "+cdo.getColValue("num_doc"),0,1);
		pc.addCols(" "+cdo.getColValue("fecha_documento"),1,1) ;
		pc.addCols(" "+cdo.getColValue("fechaVence"),1,1) ;
		pc.addCols(" "+cdo.getColValue("tipo_pago"),0,1) ;
		pc.addCols(" "+cdo.getColValue("almacen_desc"),0,1);
		pc.addCols(" "+cdo.getColValue("numero_factura"),1,1);
		pc.addCols(" "+cdo.getColValue("desc_status"),0,1) ;
		pc.addCols(" "+cdo.getColValue("monto_total"),2,1) ;
						
		groupBy=cdo.getColValue("nombre_proveedor");									

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+"  Registros en total",0,9);
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>