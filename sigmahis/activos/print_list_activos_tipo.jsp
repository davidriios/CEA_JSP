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
REPORTE DE ACTIVOS POR CUENTA CONTABLES   ACT604.RDF

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

String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String desde = request.getParameter("desde");
String hasta  = request.getParameter("hasta");
String unidad  = request.getParameter("unidad");
String proveedor  = request.getParameter("proveedor");
String activo = request.getParameter("activo");
String estatus = request.getParameter("estatus");
String clasificacion = request.getParameter("clasificacion");
String fechaFinal = request.getParameter("fechaFinal");


if (appendFilter == null) appendFilter = "";
if(desde == null) desde = "";
if(hasta == null) hasta = "";
if(unidad == null) unidad = "";
if(proveedor == null) proveedor = "";
if(activo == null) activo = "";
if(estatus == null) estatus = "";
if(clasificacion == null) clasificacion = "";
if(fechaFinal == null) fechaFinal = "";

if (!clasificacion.equals(""))
{
 appendFilter += " and a.cuentah_detalle = "+clasificacion;
}
if (!desde.equals(""))
{
 appendFilter += " and a.fecha_de_entrada >= to_date('"+desde+"','dd/mm/yyyy')";
}
if (!hasta.equals(""))
{
 appendFilter += " and a.fecha_de_entrada <= to_date('"+hasta+"','dd/mm/yyyy')";
}
if (!proveedor.equals(""))
{
 appendFilter += " and a.cod_provee = '"+proveedor+"'";
}
if (!unidad.equalsIgnoreCase(""))
{
 appendFilter += " and a.ue_codigo = "+unidad;
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


//sql = "select a.secuencia, a.observacion, u.descripcion ubic_fisica, a.valor_actual + nvl(a.valor_mejora_actual,0) valor, a.ue_codigo, ue.descripcion unidad, d.descripcion cuenta, a.cuentah_activo cod_espec, a.cuentah_espec cod_subesp, d.codigo_detalle, a.valor_inicial, a.valor_deprem, to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_de_entrada, to_char(a.final_garantia,'dd/mm/yyyy') final_garantia, a.cuentah_activo||'  '||a.cuentah_espec||'  '||d.codigo_detalle cod_espec from tbl_con_activos a, tbl_con_ubic_fisica u, tbl_con_detalle_otro d, tbl_sec_unidad_ejec ue where u.codigo_ubic(+) = a.nivel_codigo_ubic and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.cod_compania = a.compania and ue.compania = a.compania and ue.codigo = a.ue_codigo and d.codigo_detalle = a.cuentah_detalle order by a.fecha_de_entrada, a.secuencia";
sql ="select a.secuencia, a.entrada_codigo, a.cuentah_activo, a.cuentah_espec, b.descripcion detalleOtros, a.estatus, decode(a.estatus,'ACTI','ACTIVO','RETIR','INACTIVO') estatusDsp, a.tipo_activo, a.cod_provee, /*a.cuentah_activo||'-'||a.cuentah_espec||'-'||*/a.cuentah_detalle||'-'||b.descripcion listado_activo , to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada, to_char(a.final_garantia,'dd/mm/yyyy') final_garantia, a.observacion, a.cod_articulo, a.cod_clase, a.cod_flia, a.porcentaje, nvl(a.placa,a.placa_nueva) placa, c.descripcion unidad_ejec, decode(a.tipo_activo,'I','INMUEBLE','B','BIEN','T','TERRENO') tipo, a.valor_deprem , a.acum_deprec, a.acum_deprem, a.valor_actual, a.valor_inicial, a.vida_estimada from tbl_con_activos a, tbl_con_detalle_otro b, tbl_sec_unidad_ejec c where a.compania="+(String)session.getAttribute("_companyId")+appendFilter+" and a.compania = b.cod_compania(+) and a.cuentah_detalle = b.codigo_detalle(+) and a.compania = c.compania(+) and a.ue_codigo = c.codigo(+) order by  b.descripcion, c.descripcion, a.fecha_de_entrada , to_number(a.secuencia)";

al = SQLMgr.getDataList(sql);

  double monto_total = 0.00,monto_total_ini =0.00,monto_total_dep=0.00;
	double total_act   = 0.00,total_ini =0.00,total_dep=0.00;
	double total_cta_act   = 0.00,total_cta_ini =0.00,total_cta_dep=0.00;
	double total_ue_act   = 0.00,total_ue_ini =0.00,total_ue_dep=0.00;


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
	String subtitle = "ACTIVOS POR CLASIFICACION";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dDetalle = new Vector();
		dDetalle.addElement(".10");
		dDetalle.addElement(".40");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");


 pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row
		pc.setFont(7, 1);

		pc.addBorderCols("CODIGO",1,1);
		pc.addBorderCols("DESCRIPCION",1,1);
		pc.addBorderCols("FECHA ENTRADA",1,1);
		pc.addBorderCols("VALOR INICIAL",1,1);
		pc.addBorderCols("DEPREC. MENSUAL",1,1);
		pc.addBorderCols("FINAL GARANTIA",1,1);
		pc.addBorderCols("VALOR ACTUAL",1,1);
		pc.setTableHeader(2);

	   int no = 0;
		 String cta = "";
		 String esp = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(!cta.trim().equals(cdo.getColValue("listado_activo")))
		{
			pc.setFont(7, 1);

		 if(i!=0)
		 {
				// total x depto
				pc.addCols(" Total por Departamento . . . ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_ini),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_dep),2,1);
				pc.addCols("  ",0,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_act),2,1);
				pc.addCols("",1,dDetalle.size());
			  	total_ue_act  =0.00;
				total_ue_ini 	=0.00;
				total_ue_dep	=0.00;
				esp = "";

				// total x tipo
				pc.addCols(" Total por Tipo . . . ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_cta_ini),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_cta_dep),2,1);
				pc.addCols("  ",0,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_cta_act),2,1);
				pc.addCols("",1,dDetalle.size());
			  	total_cta_act  =0.00;
				total_cta_ini 	=0.00;
				total_cta_dep	=0.00;

		 }

			pc.addCols("",1,dDetalle.size());
			pc.addCols("Clasificación : "+cdo.getColValue("listado_activo"),0,7);
		}

		if(!esp.trim().equals(cdo.getColValue("unidad_ejec")))
		{
			pc.setFont(7, 1);

		 if(i!=0 && !esp.trim().equals(""))
		 {
				pc.addCols(" Total por Departamento . . . ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_ini),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_dep),2,1);
				pc.addCols("  ",0,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_act),2,1);
				pc.addCols("",1,dDetalle.size());
			  	total_ue_act  =0.00;
				total_ue_ini 	=0.00;
				total_ue_dep	=0.00;
		 }

			pc.addCols("",1,dDetalle.size());
			pc.addCols("Departamento : "+cdo.getColValue("unidad_ejec"),0,7);
		  	total_ue_act  =0.00;
			total_ue_ini 	=0.00;
			total_ue_dep	=0.00;
		}

		pc.setFont(7, 0);
		pc.setVAlignment(0);

		 pc.setNoColumnFixWidth(dDetalle);
			pc.addCols(" "+cdo.getColValue("secuencia"),2,1);
			pc.addCols(" "+cdo.getColValue("observacion"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha_entrada"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_inicial")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_deprem")),2,1);
		  pc.addCols(" "+cdo.getColValue("final_garantia"),1,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_actual")),2,1);


		cta  = cdo.getColValue("listado_activo");
		esp  = cdo.getColValue("unidad_ejec");
		total_act  += Double.parseDouble(cdo.getColValue("valor_actual"));
		total_ini  += Double.parseDouble(cdo.getColValue("valor_inicial"));
		total_dep  += Double.parseDouble(cdo.getColValue("valor_deprem"));

		total_cta_act += Double.parseDouble(cdo.getColValue("valor_actual"));
		total_cta_ini += Double.parseDouble(cdo.getColValue("valor_inicial"));
		total_cta_dep += Double.parseDouble(cdo.getColValue("valor_deprem"));

		total_ue_act += Double.parseDouble(cdo.getColValue("valor_actual"));
		total_ue_ini += Double.parseDouble(cdo.getColValue("valor_inicial"));
		total_ue_dep += Double.parseDouble(cdo.getColValue("valor_deprem"));

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{

				pc.setFont(7,1);

				pc.addCols(" Total por Departamento . . . ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_ini),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_dep),2,1);
				pc.addCols("  ",0,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ue_act),2,1);
				pc.addCols("",1,dDetalle.size());

				pc.addCols(" Total por Tipo . . . ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_cta_ini),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_cta_dep),2,1);
				pc.addCols("  ",0,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_cta_act),2,1);
				pc.addCols("",1,dDetalle.size());

				pc.addCols("",1,dDetalle.size());
				pc.addCols(" TOTAL FINAL . . . ",2,3);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_ini),2,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_dep),2,1);
				pc.addCols("  ",0,1);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(total_act),2,1);
				pc.addCols("",1,dDetalle.size());

		//pc.addCols("Total de Activos . . . . . . . . "+CmnMgr.getFormattedDecimal(total_ini),2,7);


	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>