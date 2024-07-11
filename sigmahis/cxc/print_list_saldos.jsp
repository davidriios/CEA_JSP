<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
Reporte
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbFilterFF = new StringBuffer();

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo1 = new CommonDataObject();

String appendFilter = request.getParameter("appendFilter");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String tipo = request.getParameter("tipo");
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String estado = request.getParameter("estado");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String filtro_fecha_fact = request.getParameter("filtro_fecha_fact");
String refer_to = request.getParameter("refer_to");
String tipoOtro = request.getParameter("tipoOtro");
String usarNombre = request.getParameter("usarNombre");
String filterZeros = request.getParameter("filterZeros") == null ? "" : request.getParameter("filterZeros");

if (tipo == null) tipo = "";
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (estado == null) estado = "";
if (refer_to == null) refer_to = "";
if (tipoOtro == null) tipoOtro = "";
if (fecha_ini == null) fecha_ini = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (fecha_fin == null) fecha_fin = fecha_ini;
if (filtro_fecha_fact == null) filtro_fecha_fact = "";
if (usarNombre == null) usarNombre = "";
	if (!tipo.trim().equals("")) { sbFilter.append(" and refer_type = "); sbFilter.append(tipo);}
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(x.refer_id) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	//if (!nombre.trim().equals("")) { sbFilter.append(" and upper(x.nombre_cliente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and x.estatus = '"); sbFilter.append(estado); sbFilter.append("'"); }
	if (filtro_fecha_fact.trim().equals("Y")) {
		sbFilterFF.append(" and trunc(x.fecha_factura) <= to_date('");
		sbFilterFF.append(fecha_fin);
		sbFilterFF.append("', 'dd/mm/yyyy')");
	}
	if (refer_to.equalsIgnoreCase("CXCO")) {
			if (!tipoOtro.trim().equals("")) {
				sbFilter.append(" and exists (select null from tbl_cxc_cliente_particular where compania = x.compania and codigo = x.refer_id and tipo_cliente = ");
				sbFilter.append(tipoOtro);
				sbFilter.append(")");
			}
		}



	if (!nombre.trim().equals("")) sbSql.append("select * from (");

	sbSql.append("select refer_type as tipo,(select refer_to from tbl_fac_tipo_cliente tc where tc.compania = x.compania and tc.codigo = x.refer_type)refer_to, (select descripcion from tbl_fac_tipo_cliente tc where tc.compania = x.compania and tc.codigo = x.refer_type) refer_desc, x.refer_id as codigo");
	if (usarNombre.equalsIgnoreCase("S") || !nombre.trim().equals("")) sbSql.append(", decode(x.refer_type,(select get_sec_comp_param(x.compania,'TP_CLIENTE_PAC') from dual),(select nombre_paciente from vw_adm_paciente where pac_id = x.refer_id),(select getNombreCliente(x.compania,x.refer_type,x.refer_id) from dual)) as nombre");
	else sbSql.append(", ' ' as nombre");
	sbSql.append(" ,sum((case when trunc(x.doc_date) < to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy')");
	if (filtro_fecha_fact.trim().equals("Y")) {
		sbSql.append(" and trunc(x.fecha_factura) < to_date('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	sbSql.append(" then nvl(x.debito,0)- (nvl(x.credito,0)/*+nvl(x.aj_rec,0)*/) /*- nvl(x.pago_no_aplicado, 0)*/ else 0 end)) saldo_anterior, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(x.debito,0)- nvl(x.credito,0) else 0 end)) movimiento, sum(case when trunc(x.doc_date) <= to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(x.debito,0)-(nvl(x.credito,0)/*+nvl(x.aj_rec,0)*/) /*- nvl(x.pago_no_aplicado,0)*/ else 0 end) saldo, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then facturas else 0 end)) facturas, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(pagos,0) else 0 end)) pagos, sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then ajustes else 0 end)) ajustes,sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(aj_rec,0) else 0 end)) as aj_rec,sum((case when trunc(x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilterFF.toString());
	sbSql.append(" then nvl(pago_no_aplicado,0) else 0 end)) as por_aplicar ,(select oc.descripcion from tbl_cxc_cliente_particular p,tbl_cxc_tipo_otro_cliente oc where p.compania = x.compania and to_char(p.codigo) = x.refer_id and oc.id= p.tipo_cliente and p.compania=oc.compania) as tipo_cliente_o, sum((case when trunc (x.doc_date) between to_date('");
	sbSql.append(fecha_ini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy') then nvl (descuento, 0) else 0 end)) descuento from vw_cxc_mov_new x where x.compania = ");

	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and trunc (x.doc_date) <= to_date('");
	sbSql.append(fecha_fin);
	sbSql.append("', 'dd/mm/yyyy')");
	sbSql.append(sbFilter);
	sbSql.append("  group by x.refer_type, x.compania, x.refer_id");

	if (!nombre.trim().equals("")) { sbSql.append(") where upper(nombre) like '%"); sbSql.append(nombre.toUpperCase()); sbSql.append("%'"); }

		if (!filterZeros.equals("")){
			StringBuffer sbFZeros = new StringBuffer();
			sbFZeros.append(" select fz.* from(");
			sbFZeros.append(sbSql.toString());
			sbFZeros.append(") fz where fz.saldo != 0 ");
			sbSql = sbFZeros;
		}

	al = SQLMgr.getDataList(sbSql.toString());
	StringBuffer sbTmp = new StringBuffer(" select tipo,refer_desc , sum(nvl(saldo_anterior,0)) as saldo_anterior,sum(nvl(facturas,0)) as facturas,sum(nvl(pagos,0)) as pagos,sum(nvl(ajustes,0)) as ajustes,sum(nvl(saldo,0)) as saldo,sum(nvl(por_aplicar,0)) as por_aplicar,sum(nvl(aj_rec,0)) as aj_rec,sum(nvl(descuento,0)) as descuento from ( ");
	sbTmp.append(sbSql);
	sbTmp.append(" ) group by tipo,refer_desc ");
	al2 = SQLMgr.getDataList(sbTmp.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "CXC";
	String subtitle = "CONSULTAS DE SALDOS ";
	String xtraSubtitle = " DESDE "+fecha_ini+" HASTA "+fecha_fin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector setDetail = new Vector();
		setDetail.addElement(".18");
		setDetail.addElement(".06");
		setDetail.addElement(".25");
		setDetail.addElement(".07");
		setDetail.addElement(".07");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".07");
		setDetail.addElement(".06");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath,displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

		//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setDetail.size());

		pc.setFont(7, 1);
		pc.addBorderCols("Tipo Cliente",1);
		pc.addBorderCols("Codigo",1);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("S. Anterior",1);
		pc.addBorderCols("Facturas",1);
		pc.addBorderCols("AJ. FACT.",1);
		pc.addBorderCols("P. Aplic. Fact.",1);
		pc.addBorderCols("Por Aplicar",1);
		pc.addBorderCols("AJ. REC",1);
		pc.addBorderCols("Saldo Final",1);
		pc.addBorderCols("Desc.",1);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);

 double saldo = 0.00,saldoAnt= 0.00,facturas= 0.00,pagos= 0.00,ajustes= 0.00,saldoFin= 0.00,porAplicar=0.00,aj_rec=0.00, descuento=0.00;

	for (int i=0; i<al.size(); i++)
	{
		 CommonDataObject cdo = (CommonDataObject) al.get(i);
		 saldo = Double.parseDouble(cdo.getColValue("saldo"));
	saldoAnt += Double.parseDouble(cdo.getColValue("saldo_anterior"));
	facturas += Double.parseDouble(cdo.getColValue("facturas"));
	pagos += Double.parseDouble(cdo.getColValue("pagos"));
	ajustes += Double.parseDouble(cdo.getColValue("ajustes"));
	saldoFin += Double.parseDouble(cdo.getColValue("saldo"));
	porAplicar += Double.parseDouble(cdo.getColValue("por_aplicar"));
	aj_rec += Double.parseDouble(cdo.getColValue("aj_rec"));
	descuento += Double.parseDouble(cdo.getColValue("descuento"));

		pc.setFont(7, 0);

		pc.addCols(cdo.getColValue("refer_desc")+" - "+cdo.getColValue("tipo_cliente_o"),0,1);
		pc.addCols(cdo.getColValue("codigo"),0,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_anterior")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("facturas")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagos")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("por_aplicar")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("aj_rec")),2,1);
		if(saldo<0) pc.setFont(7,0,Color.red);
		else pc.setFont(7,0);
		pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("descuento")),2,1);
		//else pc.addCols(CmnMgr.getFormattedDecimal(saldo),1,1);
		pc.setFont(7,0);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,setDetail.size());
	}
	else
	{
			pc.addBorderCols(" ",1,setDetail.size(),0.5f,0.0f,0.0f,0.0f);
			//public void addBorderCols(String text, int hAlign, int colSpan, float bottomBorderWidth, float topBorderWidth, float leftBorderWidth, float rightBorderWidth)


			pc.addCols("TOTALES --------------------------------->",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal(saldoAnt),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(facturas),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(ajustes),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(pagos),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(porAplicar),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(aj_rec),2,1);
			if(saldoFin<0) pc.setFont(7,0,Color.red);
			else pc.setFont(7,0);
			pc.addCols(CmnMgr.getFormattedDecimal(saldoFin),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(descuento),2,1);

	}

	pc.addCols(" ",1,setDetail.size());
	pc.addCols("RESUMEN POR TIPO DE CLIENTE",1,setDetail.size());

			pc.addBorderCols("Tipo Cliente",1);
		pc.addBorderCols("Codigo",1);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("S. Anterior",1);
		pc.addBorderCols("Facturas",1);
		pc.addBorderCols("AJ. FACT.",1);
		pc.addBorderCols("P. Aplic. Fact.",1);
		pc.addBorderCols("Por Aplicar",1);
		pc.addBorderCols("AJ. REC",1);
		pc.addBorderCols("Saldo Final",1);
		pc.addBorderCols("Desc.",1);

	for (int i=0; i<al2.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al2.get(i);

		pc.setFont(7, 0);

		pc.addCols(cdo.getColValue("refer_desc"),0,3);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_anterior")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("facturas")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajustes")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagos")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("por_aplicar")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("aj_rec")),2,1);

		if(Double.parseDouble(cdo.getColValue("saldo"))<0) pc.setFont(7,0,Color.red);
		else pc.setFont(7,0);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);
		//else pc.addCols(CmnMgr.getFormattedDecimal(saldo),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("descuento")),2,1);
		pc.setFont(7,0);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>