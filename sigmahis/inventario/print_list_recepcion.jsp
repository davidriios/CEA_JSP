<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==========================================================================================
 COC - CON ORDEN DE COMPRA
 SOC - SIN ORDEN DE COMPRA
 CNE - CONSIGNACION NOTA DE ENTREGA
 CFP - CONSIGNACION FACTURA DE PROVEEDOR
 --  - CONSULTA DE FACTURAS POR ORDEN DE COMPRA
 --  - CONSULTA DE RECEPCION DE MATERIAL
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String estado = request.getParameter("estado");
String subTitle ="";
if(fp == null)fp="ROC";
if(estado == null)estado="";


if(fp.trim().equals("COC"))subTitle = " RECEPCION DE MATERIALES CON ORDEN DE COMPRA";
else if(fp.trim().equals("SOC"))subTitle = " RECEPCION DE MATERIALES SIN ORDEN DE COMPRA";
else if(fp.trim().equals("CNE"))subTitle = " RECEPCION DE MATERIALES (CONSIGNACION) NOTA DE ENTREGA";
else if(fp.trim().equals("CFP"))subTitle = " RECEPCION DE MATERIALES (CONSIGNACION) FACTURA DE PROVEEDOR";
else  subTitle = " RECEPCION DE MATERIALES ";

if (appendFilter == null) appendFilter = "";

sql= "SELECT (case when a.fre_documento in ('FC','OC') and a.tipo_factura = 'I' and a.cf_anio is not null then 1 when a.fre_documento in ('FC','FR') and a.tipo_factura = 'I' and a.cf_anio is null then 2 when a.tipo_factura = 'S' then 3 when a.fre_documento in ('NE', 'FG')  and a.tipo_factura ='I' then 4 end) tipo, a.anio_recepcion, a.numero_documento, a.estado, decode(a.estado,'A','ANULADO','R','RECIBIDO') desc_estado, nvl(to_char(a.fecha_documento,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) fecha_documento, a.cod_proveedor, a.codigo_almacen, b.nombre_proveedor, c.descripcion almacen_desc, a.numero_factura, to_char(a.fecha_sistema,'dd/mm/yyyy') fecha_sistema, nvl(a.monto_total,0) monto_fac, nvl(a.itbm, 0) itbm, "+(estado.equals("A") && (fp==null || fp.equals(""))?" 'Y'":"(case when a.fre_documento = 'NE' or a.estado = 'A' then 'N' else 'Y' end)")+" acumular FROM tbl_inv_recepcion_material a, tbl_com_proveedor b, tbl_inv_almacen c , tbl_com_comp_formales e where a.cod_proveedor = b.cod_provedor and a.codigo_almacen = c.codigo_almacen(+) and a.compania = c.compania(+) and a.cf_anio=e.anio(+) and a.cf_tipo_com=e.tipo_compromiso(+) and a.cf_num_doc=e.num_doc(+) and a.compania=e.compania(+) and a.compania = "+session.getAttribute("_companyId") + appendFilter+" order by 1, a.fecha_creacion desc";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = ""+subTitle;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
		//float cHeight = 12.0f;


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".03");
		dHeader.addElement(".07");
		dHeader.addElement(".06");
		dHeader.addElement(".08");
		dHeader.addElement(".20");
		dHeader.addElement(".14");
		dHeader.addElement(".10"); // Monto Factura
		dHeader.addElement(".19");
		dHeader.addElement(".07");
		dHeader.addElement(".06");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	//second row
	pc.setFont(7, 1);
	pc.addBorderCols("Año",1);
	pc.addBorderCols("No.Recep",1);
	pc.addBorderCols("Fecha Doc.",1);
	pc.addBorderCols("Fecha Creac.",1);
	pc.addBorderCols("Proveedor",0);
	pc.addBorderCols("Factura",1);
	pc.addBorderCols("Monto Fac.",2,1);
	pc.addBorderCols("Almacén",0);
	pc.addBorderCols("Estado",0);
	pc.addBorderCols("ITBM",1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String wh = "", groupBy = "",subGroupBy = "";
	double totMontoFac = 0.0, subTotal = 0.00, totItbm = 0.0, subTotalItbm = 0.00;

	String tipo = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setVAlignment(0);
		if(!groupBy.equals(cdo.getColValue("tipo"))){
			if(i!=0){
				pc.setFont(8, 1);
				pc.addCols("Total Monto Facturado "+tipo+":",2,6);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotal),2,1);
				pc.addCols("",0,2);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotalItbm),2,1);
				subTotal=0.00;
				subTotalItbm=0.00;
			}
			if(cdo.getColValue("tipo").equals("1")) tipo = "RECEPCION CON ORDEN DE COMPRA";
			else if(cdo.getColValue("tipo").equals("2")) tipo = "RECEPCION SIN ORDEN DE COMPRA";
			else if(cdo.getColValue("tipo").equals("3")) tipo = "FACTURAS DE SERVICIO";
			else if(cdo.getColValue("tipo").equals("4")) tipo = "FACTURAS A CONSIGNACION";
			pc.setFont(8, 1);
			pc.addBorderCols(tipo,0,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
		}
		pc.setFont(7, 0);
		pc.addCols(" "+cdo.getColValue("anio_recepcion"),0,1);
		pc.addCols(" "+cdo.getColValue("numero_documento"),0,1);
		pc.addCols(" "+cdo.getColValue("fecha_documento"),0,1);
		pc.addCols(" "+cdo.getColValue("fecha_sistema"),0,1);
		pc.addCols(" "+cdo.getColValue("cod_proveedor")+ " " + cdo.getColValue("nombre_proveedor"),0,1);
		pc.addCols(" "+cdo.getColValue("numero_factura"),0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_fac")),2,1);
		pc.addCols(" "+cdo.getColValue("codigo_almacen")+ " " + cdo.getColValue("almacen_desc"),0,1);
		pc.addCols(" "+cdo.getColValue("desc_estado"),0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("itbm")),2,1);

		groupBy=cdo.getColValue("tipo");
		if(cdo.getColValue("acumular").equals("Y")){
		totMontoFac+= Double.parseDouble(cdo.getColValue("monto_fac"));
		subTotal+= Double.parseDouble(cdo.getColValue("monto_fac"));
		totItbm+= Double.parseDouble(cdo.getColValue("itbm"));
		subTotalItbm+= Double.parseDouble(cdo.getColValue("itbm"));
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if(al.size()>0){
		pc.setFont(8, 1);
		pc.addCols("Total Monto Facturado "+tipo+":",2,6);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotal),2,1);
		pc.addCols("",0,2);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(subTotalItbm),2,1);
		subTotal=0.00;
	}

	pc.setFont(8, 1);
	pc.addCols("Total Monto Facturado:",2,6);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(totMontoFac),2,1);
	pc.addCols("",0,2);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(totItbm),2,1);

	pc.setFont(7, 0);

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>