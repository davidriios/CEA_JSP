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

String desc ="";
String appendFilter = request.getParameter("appendFilter");
String appendFilter1 = "", appendFilter2 = "", filter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
StringBuffer sql = new StringBuffer();
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String compania = (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");
String fechaFin = request.getParameter("toDate");
String fechaIni = request.getParameter("xDate");
String comprob = request.getParameter("comprob");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fechaFin == null) fechaFin = "";
if (fechaIni == null) fechaIni = "";
if (comprob == null) comprob = "";

		sql.append(" select/*a.monto_total, a.itbm,*/ a.cod_proveedor, lpad(a.cod_concepto, 2, '0') cod_concepto,b.nombre_proveedor desc_proveedor,nvl(sum(nvl(c.monto,0)),0)monto, c.cg_1_cta1 cta1, c.cg_1_cta2 cta2, c.cg_1_cta3 cta3, c.cg_1_cta4 cta4, c.cg_1_cta5 cta5, c.cg_1_cta6 cta6,/* c.descripcion,*/ d.descripcion descripcion_cuenta ,(select descripcion from tbl_con_conceptos where codigo=a.cod_concepto)conceptoDes,c.cg_1_cta1||'-'||c.cg_1_cta2||'-'||c.cg_1_cta3||'-'||c.cg_1_cta4||'-'||c.cg_1_cta5||'-'||c.cg_1_cta6 cuenta,a.numero_factura,to_char(odp.fecha,'dd/mm/yyyy') fecha,odp.num_cheque from tbl_inv_recepcion_material a, tbl_com_proveedor b,tbl_adm_detalle_factura c, tbl_con_catalogo_gral d,(select distinct  ch.f_emision fecha,ch.num_cheque,det.num_factura,op.cod_provedor cod_proveedor  from tbl_con_cheque ch,tbl_cxp_orden_de_pago op,tbl_cxp_detalle_orden_pago det  where  estado_cheque <> 'A' and  ch.anio =op.anio and ch.num_orden_pago=op.num_orden_pago and ch.cod_compania_odp = op.cod_compania and det.cod_compania = op.cod_compania  and det.num_orden_pago = op.num_orden_pago  and det.anio = op.anio and det.num_factura is not null) odp  where a.cod_proveedor = b.cod_provedor and a.compania =");
				sql.append((String) session.getAttribute("_companyId"));
	if(!fechaIni.trim().equals(""))
	{
		sql.append(" and trunc(a.fecha_documento) >= to_date('");
		sql.append(fechaIni);
		sql.append("','dd/mm/yyyy')");
	}
	if(!fechaFin.trim().equals(""))
	{
		sql.append(" and trunc(a.fecha_documento) <= to_date('");
		sql.append(fechaFin);
		sql.append("','dd/mm/yyyy')");
	}
	
	if(comprob.trim().equals("N") || comprob.trim().equals("S"))
	{
		sql.append(" and nvl(a.comprobante,'N') = '");
		sql.append(comprob);
		sql.append("'");
	}

		
	sql.append(" and c.compania = a.compania and c.numero_documento = a.numero_documento and c.anio_recepcion = a.anio_recepcion and c.compania = d.compania and c.cg_1_cta1 = d.cta1 and c.cg_1_cta2 = d.cta2 and c.cg_1_cta3 = d.cta3 and c.cg_1_cta4 = d.cta4 and c.cg_1_cta5 = d.cta5 and c.cg_1_cta6 = d.cta6 and a.cod_proveedor =odp.cod_proveedor (+)  and a.numero_factura = odp.num_factura(+) group by a.cod_proveedor, lpad(a.cod_concepto, 2, '0'),b.nombre_proveedor ,c.cg_1_cta1, c.cg_1_cta2, c.cg_1_cta3, c.cg_1_cta4, c.cg_1_cta5, c.cg_1_cta6,d.descripcion,a.cod_concepto,c.cg_1_cta1||'-'||c.cg_1_cta2||'-'||c.cg_1_cta3||'-'||c.cg_1_cta4||'-'||c.cg_1_cta5||'-'||c.cg_1_cta6,a.numero_factura,to_char(odp.fecha,'dd/mm/yyyy'),odp.num_cheque  order by  a.cod_proveedor, c.cg_1_cta1,c.cg_1_cta2,c.cg_1_cta3,c.cg_1_cta4,c.cg_1_cta5,c.cg_1_cta6 ");

al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTABILIDAD";
	String subtitle = "COMPROBANTE DE GASTOS POR SERVICIOS ADMINISTRATIVOS";
	String xtraSubtitle = ""+((!fechaIni.trim().equals("")&&!fechaFin.trim().equals(""))?" DEL  "+fechaIni+"  AL  "+fechaFin:" ");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".19");
	

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("Proveedor",0);
		pc.addBorderCols("No. Factura",1);
		pc.addBorderCols("No. Cheque",1);
		pc.addBorderCols("Fecha Cheque",1);
		pc.addBorderCols("No. Cuenta",1);
		pc.addBorderCols("Descripción",0);
		pc.addBorderCols("Monto",1);
		pc.addBorderCols("Concepto",1);
	pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double totalDb = 0.00,totalCr = 0.00;
	double res = 0.00;
	double debit = 0.00;
	double credit = 0.00;
	double tDebit = 0.00;
	double tCredit = 0.00,total= 0.00;


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		
		/*if(cdo.getColValue("lado").trim().equals("DB"))
		debit = Double.parseDouble(cdo.getColValue("monto"));
		else 
		credit = Double.parseDouble(cdo.getColValue("monto"));
		*/
				if(!groupBy.trim().equals(cdo.getColValue("cod_proveedor")))	
				pc.addCols(""+cdo.getColValue("desc_proveedor"), 0,1);
				else pc.addCols(" ",0,1);
				
				pc.addCols(""+cdo.getColValue("numero_factura"), 0,1);
				pc.addCols(""+cdo.getColValue("num_cheque"), 0,1);
				pc.addCols(""+cdo.getColValue("fecha"), 0,1);
				pc.addCols(""+cdo.getColValue("cuenta"), 0,1);
				pc.addCols(""+cdo.getColValue("descripcion_cuenta"), 0,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")), 2,1);
				pc.addCols(""+cdo.getColValue("conceptoDes"), 0,1);
				//pc.addCols(""+((credit ==0)?"":CmnMgr.getFormattedDecimal(credit)), 2,1);
				
				
		total += Double.parseDouble(cdo.getColValue("monto"));
		groupBy = cdo.getColValue("cod_proveedor"); 
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
				
}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			
			pc.addCols(" ", 1,dHeader.size());
			pc.setFont(8, 0,Color.blue);
			
			pc.addCols("Total:", 2,3);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(total), 2,4);
			pc.addCols(" ", 0,1);
			//pc.addCols(""+CmnMgr.getFormattedDecimal(tCredit), 2,1);
			/*pc.addCols(" ", 1,dHeader.size());
			pc.addCols("Total Ajuste a  Factura", 1,4);
			pc.addCols(""+CmnMgr.getFormattedDecimal(totalDb- totalCr),0,4);*/
	}	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>