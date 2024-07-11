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
String userName = UserDet.getUserName();
String desde = request.getParameter("desde");
String hasta  = request.getParameter("hasta");
String unidad  = request.getParameter("unidad");
String proveedor  = request.getParameter("proveedor");
String activo = request.getParameter("activo");
String estatus = request.getParameter("estatus");
String fechaFinal = request.getParameter("fechaFinal");
String orden = request.getParameter("orden");



if (appendFilter == null) appendFilter = "";
if(desde == null) desde = "";
if(hasta == null) hasta = "";
if(unidad == null) unidad = "";
if(proveedor == null) proveedor = "";
if(activo == null) activo = "";
if(estatus == null) estatus = "";
if(fechaFinal == null) fechaFinal = "";
if(orden == null) orden = "1";

if (!desde.equalsIgnoreCase(""))
{
 appendFilter += " and trunc(a.fecha_de_entrada) >= to_date('"+desde+"','dd/mm/yyyy')";
}

if (!hasta.equalsIgnoreCase(""))
{
 appendFilter += " and trunc(a.fecha_de_entrada) <= to_date('"+hasta+"','dd/mm/yyyy')";
}

if (!unidad.equalsIgnoreCase(""))
{
 appendFilter += " and a.ue_codigo = "+unidad;
}

if (!proveedor.equalsIgnoreCase(""))
{
 appendFilter += " and a.cod_provee = "+proveedor;
}

if (!activo.equalsIgnoreCase(""))
{
 appendFilter += " and a.secuencia = '"+activo+"'";
}

if (!estatus.equalsIgnoreCase(""))
{
 appendFilter += " and a.estatus = '"+estatus+"'";
}

if (!fechaFinal.equalsIgnoreCase(""))
{
 appendFilter += "  and trunc(a.final_garantia) > to_date('"+fechaFinal+"','dd/mm/yyyy')";
}

sql="select a.secuencia, a.entrada_codigo, a.cuentah_activo, a.cuentah_espec, b.descripcion detalleOtros, a.estatus, decode(a.estatus,'ACTI','ACTIVO','RETIR','INACTIVO') estatusDsp, a.tipo_activo, a.cod_provee, a.cuentah_activo||'-'||a.cuentah_espec||'-'||a.cuentah_detalle||'-'||b.descripcion listado_activo , to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada, a.observacion, a.cod_articulo, a.cod_clase, a.cod_flia, a.porcentaje, nvl(a.placa,a.placa_nueva) placa, c.descripcion unidad_ejec, decode(a.tipo_activo,'I','INMUEBLE','B','BIEN','T','TERRENO') tipo, nvl(a.valor_deprem,0) valor_deprem , nvl(a.acum_deprec,0) acum_deprec, nvl(a.acum_deprem,0) acum_deprem, nvl(a.valor_actual,0) valor_actual, nvl(a.valor_inicial,0) valor_inicial, a.vida_estimada,a.cuentah_activo||'---'||d.descripcion as cuentaEspecificacion from tbl_con_activos a, tbl_con_detalle_otro b, tbl_sec_unidad_ejec c,tbl_con_especificacion d where a.compania="+(String)session.getAttribute("_companyId")+appendFilter+" and a.compania = b.cod_compania(+) and a.cuentah_detalle = b.codigo_detalle(+) and a.compania = c.compania(+) and a.ue_codigo = c.codigo(+) and a.cuentah_Activo=d.cta_control(+)  and a.cuentah_espec=d.codigo_espec order by ";
if(orden.trim().equals("1"))sql+=" a.fecha_de_entrada , to_number(a.secuencia)";
else if(orden.trim().equals("3"))sql +=" a.fecha_de_entrada desc, to_number(a.secuencia) desc";
else sql+=" a.observacion asc ";



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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTABILIDAD";
	String subtitle = "LISTADO DE LAS GENERALES POR ACTIVO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	Vector dDetalle = new Vector();
		
		dDetalle.addElement(".05");
		dDetalle.addElement(".05");
		dDetalle.addElement(".16");
		dDetalle.addElement(".18");
		dDetalle.addElement(".15");
		dDetalle.addElement(".07");
		dDetalle.addElement(".05");
		dDetalle.addElement(".08");
		dDetalle.addElement(".07");
		dDetalle.addElement(".07");
		dDetalle.addElement(".07");
 	pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row
		pc.setFont(6, 1);

		
		pc.addBorderCols("CODIGO",1,1);
		pc.addBorderCols("PLACA",1,1);
		pc.addBorderCols("DESCRIPCION DEL ACTIVO",1,1);
		pc.addBorderCols("CUENTA ACTIVO",1,1);
		pc.addBorderCols("CLASIFICACION",1,1);
		pc.addBorderCols("FECHA ENTRADA",1,1);
		pc.addBorderCols("VIDA ESTIMADA",1,1);
		pc.addBorderCols("VALOR INICIAL",2,1);
		pc.addBorderCols("DEPREC. MENSUAL",2,1);
		pc.addBorderCols("DEPREC. ACUM.",2,1);
		pc.addBorderCols("VALOR ACTUAL",2,1);

		pc.setFont(6, 1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	double total_act = 0.00,total_ini=0.00, total_dep=0.00, total_acum=0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(6, 0);
		pc.setVAlignment(0);
		
		pc.setNoColumnFixWidth(dDetalle);
		pc.addCols(" "+cdo.getColValue("secuencia"),0,1);
		pc.addCols(" "+cdo.getColValue("placa"),0,1);
		pc.addCols(" "+cdo.getColValue("observacion"),0,1);
		pc.addCols(" "+cdo.getColValue("cuentaEspecificacion"),0,1);
		pc.addCols(" "+cdo.getColValue("detalleOtros"),0,1);
		pc.addCols(" "+cdo.getColValue("fecha_entrada"),0,1);
		
		pc.addCols(" "+cdo.getColValue("vida_estimada"),1,1);
		//pc.addCols(" "+cdo.getColValue("nombre"),0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_inicial")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_deprem")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("acum_deprec")),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_actual")),2,1);

		total_act  += Double.parseDouble(cdo.getColValue("valor_actual"));
		total_ini  += Double.parseDouble(cdo.getColValue("valor_inicial"));
		total_dep  += Double.parseDouble(cdo.getColValue("valor_deprem"));
		total_acum += Double.parseDouble(cdo.getColValue("acum_deprec"));

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else 
	{
		pc.addCols(" TOTALES . . . . .  ",2,7);
		//pc.addCols(" "+cdo.getColValue("nombre"),0,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ini),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_dep),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_acum),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(total_act),2,1);		
	
		pc.addCols(al.size()+" Activos Registrados en total",0,dDetalle.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>