<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
ArrayList alTS = new ArrayList();
ArrayList alTST = new ArrayList();
CommonDataObject cdoHeader = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String admision = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String empresa = request.getParameter("aseguradora");
String categoria = request.getParameter("categoria");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String admType = request.getParameter("admType");
String facturar_a = request.getParameter("facturar_a");
String status = request.getParameter("status");
String fg = request.getParameter("fg");
String jubilado = request.getParameter("jubilado");
String rep_type = request.getParameter("rep_type");
String anuladasPosterior = request.getParameter("anuladasPosterior");

String admTypeDesc="";
if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (empresa == null) empresa = "";
if (categoria == null) categoria = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (admType == null) admType = "";
if (facturar_a == null) facturar_a = "";
if (facturar_a.trim().equals("PE"))facturar_a ="'P','E'";
else if (!facturar_a.trim().equals(""))facturar_a = "'"+facturar_a+"'";
if (appendFilter == null) appendFilter = "";
if (status == null) status = "";
if (fg == null) fg = "";
if (jubilado == null) jubilado = "";
if (rep_type == null) rep_type = "";
if (anuladasPosterior == null) anuladasPosterior = "";
if(admType.trim().equals(""))admTypeDesc=" - TODAS LAS CATEGORIAS";
else if(admType.trim().equals("O"))admTypeDesc=" - CATEGORIAS  OP";
else if(admType.trim().equals("I"))admTypeDesc=" - CATEGORIAS  IP";


sbSql = new StringBuffer();

if (rep_type.trim().equals("R"))sbSql.append(" select nombreCliente, sum(monto_descuento) monto_descuento, sum(gran_total) gran_total, sum(subtotal) subtotal from (");
sbSql.append("select a.codigo, a.pac_id||'-'||a.admi_secuencia noCuenta,a.usuario_creacion ,  a.numero_factura, decode(a.facturar_a,'E','EMPRESA','P','PACIENTE','0','OTROS') facturarDesc, a.facturar_a ,a.pac_id,a.admi_secuencia,decode(a.facturar_a ,'P',p.nombre_paciente,'E',c.nombre,'') nombreCliente,round(nvl(a.subtotal,0),2) as subtotal,sum(round(nvl(b.descuento,0),2)+round(nvl(b.descuento2,0),2)) monto_descuento, round(nvl(a.monto_paciente,0),2) as monto_paciente, round(nvl(a.monto_total,0),2) as monto_total, round(nvl(a.grang_total,0),2) as gran_total, to_char(a.fecha,'dd/mm/yyyy') fecha, nvl(c.nombre,'') nombreEmpresa,a.fecha fecha2  from tbl_fac_factura a,tbl_fac_detalle_factura b ,vw_adm_paciente p, tbl_adm_empresa c,tbl_adm_admision d ,tbl_adm_categoria_admision e where a.compania=");
sbSql.append(session.getAttribute("_companyId"));

if (!facturar_a.trim().equals(""))
{
sbSql.append(" and a.facturar_a in(");
sbSql.append(facturar_a);
sbSql.append(") ");
}

if(status.trim().equals("A"))//Facturas Anuladas
{
	if (!fechaIni.trim().equals(""))
	{
	sbSql.append(" and a.fecha_anulacion >= to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");
	}
	if (!fechaFin.trim().equals(""))
	{
	sbSql.append(" and a.fecha_anulacion <= to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy')");
	}
}
else
{
	if (!fechaIni.trim().equals(""))
	{
	sbSql.append(" and a.fecha >= to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");
	}
	if (!fechaFin.trim().equals(""))
	{
	sbSql.append(" and a.fecha <= to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy')");
	}
	if(anuladasPosterior.trim().equals("S"))
	{
		sbSql.append(" and a.fecha_anulacion > to_date('");
		sbSql.append(fechaFin);
		sbSql.append("','dd/mm/yyyy') and a.estatus = 'A' ");
	}
	
}

sbSql.append(" and  a.codigo = b.fac_codigo  and a.compania = b. compania  ");
if (!status.trim().equals(""))
{
	if(status.trim().equals("N"))
		sbSql.append(" and a.estatus <> 'A'");
	else
	{
		sbSql.append(" and a.estatus ='");
		sbSql.append(status);
		sbSql.append("'");
	}
}

sbSql.append(" and  a.pac_id = p.pac_id(+) and a.pac_id = d.pac_id and a.admi_secuencia = d.secuencia and a.cod_empresa = c.codigo(+)  and d.categoria = e.codigo");



if (!pacId.trim().equals(""))
{
	sbSql.append(" and a.pac_id=");
	sbSql.append(pacId);
}

if (!admision.trim().equals(""))
{
sbSql.append(" and a.admi_secuencia=");
sbSql.append(admision);
}
if (!empresa.trim().equals(""))
{
sbSql.append(" and a.cod_empresa=");
sbSql.append(empresa);
}
if (!categoria.trim().equals(""))
{
sbSql.append(" and d.categoria=");
sbSql.append(categoria);
}
if (!admType.trim().equals(""))
{
sbSql.append(" and e.adm_type ='");
sbSql.append(admType);
sbSql.append("'");

}
if (jubilado.trim().equals("S"))
{
	sbSql.append(" and a.cod_empresa=-1");
}

sbSql.append(" group by  a.codigo, a.pac_id||a.admi_secuencia ,a.usuario_creacion ,  a.numero_factura, decode(a.facturar_a,'E','EMPRESA','P','PACIENTE','0','OTROS') , a.facturar_a ,a.pac_id,a.admi_secuencia,decode(a.facturar_a ,'P',p.nombre_paciente,'E',c.nombre,'') ,round(nvl(a.subtotal,0),2),round(nvl(a.monto_paciente,0),2),round(nvl(a.monto_total,0),2),round(nvl(a.grang_total,0),2),to_char(a.fecha,'dd/mm/yyyy'),nvl(c.nombre,''),a.fecha  ");


sbSql.append(" order by a.fecha ");

if (rep_type.trim().equals("R"))sbSql.append(") group by nombreCliente");



al = SQLMgr.getDataList(sbSql.toString());
cdoHeader = SQLMgr.getData("select sum(subtotal)subtotal,sum(monto_descuento)monto_descuento,sum(gran_total)gran_total from ("+sbSql.toString()+")");


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
	String title = "INGRESOS POR FACTURAS"+(((jubilado.trim().equals("S")))?" (JUBILADOS) ":"")+admTypeDesc;
	String subtitle = "DEL "+fechaIni+"  AL "+fechaFin;
	String xtraSubtitle = ""+(status.trim().equals("A")?"FACTURAS ANULADAS":"")+" "+(anuladasPosterior.trim().equals("S")?"FACTURAS ANULADAS DESPUES DEL "+fechaFin:"");
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		if (rep_type.trim().equals("R")){
		dHeader.addElement(".70");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		} else {	
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".20");//30
		dHeader.addElement(".20");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		}
		//dHeader.addElement(".09");
		//dHeader.addElement(".09");
		//dHeader.addElement(".09");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		if (rep_type.trim().equals("R")){
			pc.addBorderCols("Nombre",1);
			pc.addBorderCols("Descuentos",1);
			pc.addBorderCols("Total",1,1);
		} else {	
		pc.addBorderCols("No. Cuenta",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Usuario",1);
		pc.addBorderCols("Factura",1);
		pc.addBorderCols("Fact. A",1,1);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Aseguradora",1);

		//pc.addBorderCols("Sub Total",1);
		pc.addBorderCols("Descuentos",1);
		//pc.addBorderCols("Monto Pac.",1);
		//pc.addBorderCols("Honorarios",1);
		pc.addBorderCols("Total",1,1);
		}
	 pc.setTableHeader(2);//create de table header
	//print_ingresos_facturas.jsp

	//table body
	String groupBy = "";
	String groupTitle = "";
	double cdsTotal = 0.00;
	double total = 0.00;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		if (rep_type.trim().equals("R")){
			pc.addCols(cdo.getColValue("nombreCliente"),0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_descuento")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("gran_total")),2,1);
		} else {
		pc.addCols(cdo.getColValue("noCuenta"),1,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
		pc.addCols(cdo.getColValue("numero_factura"),0,1);
		pc.addCols(cdo.getColValue("facturarDesc"),1,1);
		pc.addCols(cdo.getColValue("nombreCliente"),0,1);
		pc.addCols((cdo.getColValue("facturar_a").trim().equals("P"))?cdo.getColValue("nombreEmpresa"):"",0,1);

		//pc.addCols(cdo.getColValue("subtotal"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_descuento")),2,1);
		//pc.addCols(cdo.getColValue("totalPaciente"),2,1);
		//pc.addCols(cdo.getColValue("honorarios"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("gran_total")),2,1);
		}

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		total += Double.parseDouble(cdo.getColValue("gran_total"));

	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(groupFontSize,1,Color.blue);

		pc.addBorderCols("TOTAL ",2,(rep_type.trim().equals("R")?1:7),0.0f,0.5f,0.0f,0.0f);

		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("monto_descuento")),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHeader.getColValue("gran_total")),2,1,0.0f,0.5f,0.0f,0.0f);
		//pc.addCols(cdoHeader.getColValue("subtotal"),1,1);
		//pc.addCols(cdoHeader.getColValue("monto_descuento"),1,1);
		//pc.addCols(cdoHeader.getColValue("totalPaciente"),1,1);
		//pc.addCols(cdoHeader.getColValue("honorarios"),1,1);
		//pc.addCols(cdoHeader.getColValue("gran_total"),0,1);

	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>