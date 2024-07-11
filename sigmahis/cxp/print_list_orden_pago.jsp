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
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String numFactura = request.getParameter("numFactura");
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
if(numFactura == null) numFactura = "";
if(fg == null) fg = "";
if(appendFilter == null) appendFilter = "";
//"select a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fecha, a.estado, decode(a.estado, 'P', 'Pendiente', 'A', 'Aprobado', 'N=Anulado') estado_desc, a.nom_beneficiario, a.num_id_beneficiario, a.cod_tipo_orden_pago, a.monto, a.tipo_orden, b.descripcion cod_tipo_orden_pago_desc from tbl_cxp_orden_de_pago a, tbl_cxp_tipo_orden_pago b where a.compania = "+(String) session.getAttribute("_companyId")+" and a.cod_tipo_orden_pago = b.cod_tipo_orden_pago "+appendFilter+" order by a.cod_tipo_orden_pago, a.nom_beneficiario";

    if (!numFactura.equals("")){if(!fg.trim().equals("CXPHON")) appendFilter += " and b.num_factura = '"+numFactura+"'";}

   sql.append("select a.cod_compania, a.anio, a.num_orden_pago, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fecha, a.estado, decode(a.estado,'P','PENDIENTE','A', 'APROBADO','R','RECHAZADO','N','ANULADO',a.estado) as estado_desc, a.nom_beneficiario, decode(a.cod_medico, null,a.num_id_beneficiario,(select nvl(reg_medico,codigo) from tbl_adm_medico where codigo =a.cod_medico)) as num_id_beneficiario, a.cod_tipo_orden_pago, a.monto, a.tipo_orden,(select descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago = a.cod_tipo_orden_pago)cod_tipo_orden_pago_desc  from tbl_cxp_orden_de_pago a");
   if(!numFactura.equals("")&&!fg.trim().equals("CXPHON")){sql.append(",tbl_cxp_detalle_orden_pago b ");}

   sql.append(" where a.compania=");
   sql.append(session.getAttribute("_companyId"));
   sql.append(appendFilter);
   if(!numFactura.equals("")&&!fg.trim().equals("CXPHON")){sql.append(" and a.cod_compania =b.cod_compania and a.anio = b.anio and a.num_orden_pago =b.num_orden_pago");}
   if(fg.trim().equals("CXPHON")){sql.append(" and exists ( select 1 from tbl_cxp_orden_de_pago_fact fac where fac.tipo_docto = 'FAC' and fac.cod_compania =a.cod_compania and fac.anio =a.anio and fac.num_orden_pago =a.num_orden_pago and fac.numero_factura = '");
   sql.append(numFactura);
    sql.append("' )");}
   sql.append(" order by a.cod_tipo_orden_pago,a.fecha_solicitud desc");

al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12miam")+".pdf";

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
	String title = "ORDENES DE PAGO";
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
		pc.addBorderCols("No. Orden",1,1,cHeight * 2,Color.lightGray);
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

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_tipo_orden_pago"))){ // groupBy
			if (i != 0){
				pc.setFont(7, 1);
				pc.addCols("TOTAL X TIPO: ",2,4,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
				pc.addCols("",0,1,cHeight);
				pc.addCols(" ",0,dHeader.size(),cHeight);
				totUnidad   = 0.00;
			}
			pc.addCols(" [ "+cdo.getColValue("cod_tipo_orden_pago") + " ] " + cdo.getColValue("cod_tipo_orden_pago_DESC"),0,dHeader.size(),cHeight);
		}// groupBy

		pc.setFont(7, 0);

		pc.addCols(" "+cdo.getColValue("num_orden_pago"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fecha"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("num_id_beneficiario"),2,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nom_beneficiario"),0,1,cHeight);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);
		pc.addCols(" "+cdo.getColValue("estado_desc"),1,1,cHeight);

		totUnidad += Double.parseDouble(cdo.getColValue("monto"));

		groupBy = cdo.getColValue("cod_tipo_orden_pago");

	}//for i

	if (al.size() == 0){
		pc.addCols("No existen registros",1,dHeader.size());
	}	else {
			pc.setFont(7, 1);
				pc.addCols("TOTAL X TIPO: ",2,4,cHeight);
				pc.addCols(CmnMgr.getFormattedDecimal(totUnidad),2,1,cHeight);
				pc.addCols("",0,1,cHeight);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>

