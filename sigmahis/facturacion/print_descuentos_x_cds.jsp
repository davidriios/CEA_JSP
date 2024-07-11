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
String cds = request.getParameter("cds");
String jubilado = request.getParameter("jubilado");
String factA_a = request.getParameter("facturar_a");
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
if (cds == null) cds = "";
if (jubilado == null) jubilado = "";
if (factA_a == null) factA_a = "";



sbSql = new StringBuffer();
sbSql.append("select b.centro_servicio cds, (select descripcion from tbl_cds_centro_servicio where codigo = b.centro_servicio) centro_servicio_desc,sum(round(nvl(b.descuento,0),2)+round(nvl(b.descuento2,0),2)) monto, to_char(a.fecha,'dd/mm/yyyy') fecha,a.fecha fecha2,b.compania,nvl((select acc.cta1||'-'||acc.cta2||'-'||acc.cta3||'-'||acc.cta4||'-'||acc.cta5||'-'||acc.cta6 from tbl_con_accdef acc where acc.acctype_id =decode('");
sbSql.append(jubilado);
sbSql.append("','S',6,5)  and acc.ref_table= '-' and acc.ref_pk= '-' and acc.cds  = b.centro_servicio and acc.service_type ='-' and acc.compania =b.compania and acc.status  ='A' and acc.adm_type in('T',a.adm_type)),'S/C')cuenta from tbl_fac_factura a,tbl_fac_detalle_factura b where a.compania=");
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
}

sbSql.append(" and  a.codigo = b.fac_codigo  and a.compania = b. compania  ");
if (!status.trim().equals("N"))
{
	if(!status.trim().equals("")){
	if(status.trim().equals("N"))
		sbSql.append(" and a.estatus <> 'A'");
	else
	{
		sbSql.append(" and a.estatus ='");
		sbSql.append(status);
		sbSql.append("'");
	}}
}



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
if (jubilado.trim().equals("S"))
{
sbSql.append(" and a.cod_empresa=-1");
}
else{
if (empresa.trim().equals("")) sbSql.append(" and nvl(a.cod_empresa,-3) <> -1");}
if (!cds.trim().equals(""))
{
sbSql.append(" and b.centro_servicio=");
sbSql.append(cds);
}

sbSql.append(" group by  b.centro_servicio, to_char(a.fecha,'dd/mm/yyyy'),a.fecha,b.compania,a.adm_type having sum(round(nvl(b.descuento,0),2)+round(nvl(b.descuento2,0),2)) <> 0");
if (factA_a.trim().equals("O"))
{
if(status.trim().equals("A"))//Facturas Anuladas
{

sbSql.append(" union all ");
sbSql.append(" select a.centro_servicio cds, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) centro_servicio_desc,sum(round(nvl(b.total_desc,0),2)) monto, to_char(a.sys_date,'dd/mm/yyyy') fecha,trunc(a.sys_date) fecha2,a.company_id compania,nvl((select acc.cta1||'-'||acc.cta2||'-'||acc.cta3||'-'||acc.cta4||'-'||acc.cta5||'-'||acc.cta6 from tbl_con_accdef acc where acc.acctype_id =decode('','S',6,5)  and acc.ref_table= '-' and acc.ref_pk= '-' and acc.cds  = a.centro_servicio and acc.service_type ='-' and acc.compania =a.company_id and acc.status  ='A' and acc.adm_type in('T')),'S/C')cuenta from tbl_fac_trx a,tbl_fac_trxitems b where a.company_id=");
sbSql.append(session.getAttribute("_companyId"));
 

sbSql.append(" and a.doc_type = 'NCR' ");
	if (!fechaIni.trim().equals(""))
	{
	sbSql.append(" and trunc(a.sys_date) >= to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");
	}
	if (!fechaFin.trim().equals(""))
	{
	sbSql.append(" and trunc(a.sys_date) <= to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy')");
	}

sbSql.append(" and  a.doc_id = b.doc_id group by  a.centro_servicio, to_char(a.sys_date,'dd/mm/yyyy'),trunc(a.sys_date) ,a.company_id having sum(round(nvl(b.total_desc,0),2)) <> 0 ");
}
}

sbSql.append(" order by 5 ");



al = SQLMgr.getDataList(sbSql.toString());

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
	String title = (fg.trim().equals("CONTA"))?"MAYOR GENERAL":"FACTURACION";
	String subtitle = "DESCUENTOS POR CENTROS DE SERVICIOS "+(((jubilado.trim().equals("S")))?" (JUBILADOS) ":"")+"  ";
	if(status.trim().equals("A"))subtitle +=" FACTURAS ANULADAS";
	else if(status.trim().equals("N"))subtitle +=" TODOS LOS ESTADOS"; 

 
	String xtraSubtitle = "DEL "+fechaIni+"  AL "+fechaFin ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(),	leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel,	pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
					dHeader.addElement(".40");
					dHeader.addElement(".15");
					dHeader.addElement(".20");
					dHeader.addElement(".10");
					dHeader.addElement(".15");




	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin,topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX,pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);
		pc.addBorderCols("Centro De Servicio",0,2);
		pc.addBorderCols("Cuenta",2,1);
		pc.addBorderCols("Fecha",2,1);
		pc.addBorderCols("Monto",2,1);
	pc.setTableHeader(2);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto =0.0,totalCds =0.0,totalTa =0.0,total=0.0,totalCdsRecargo=0.0,totalRecargo=0.0;
	int totalCantidad = 0, totalCantidadCds =0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);


			monto  = Double.parseDouble(cdo.getColValue("monto"));
			total  += Double.parseDouble(cdo.getColValue("monto"));


			pc.addCols(cdo.getColValue("centro_servicio_desc")+" [ "+cdo.getColValue("cds")+" ]",0,2);
			pc.addCols(""+cdo.getColValue("cuenta"),2,1);
			pc.addCols(""+cdo.getColValue("fecha"),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto),2,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}



	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{

						pc.addBorderCols("TOTAL",2,4,0.5f,0.0f,0.0f,0.0f);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal(total),2,1,0.5f,0.0f,0.0f,0.0f);//


	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>


