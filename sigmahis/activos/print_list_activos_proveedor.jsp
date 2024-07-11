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
/* REPORTE DE ACTIVOS    ACT001.RDF*/
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
String anio = request.getParameter("anio");
String mes  = request.getParameter("mes");
String desde = request.getParameter("desde");
String hasta  = request.getParameter("hasta");
String proveedor  = request.getParameter("proveedor");
String cuenta  = request.getParameter("cuenta");
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String unidad  = request.getParameter("unidad");
String activo = request.getParameter("activo");
String estatus = request.getParameter("estatus");
String fechaFinal = request.getParameter("fechaFinal");

if (appendFilter == null) appendFilter = "";
if(desde == null) desde = "";
if(hasta == null) hasta = "";
if(proveedor == null) proveedor = "";
if(cuenta == null) cuenta = "";
if(unidad == null) unidad = "";
if(activo == null) activo = "";
if(estatus == null) estatus = "";
if(fechaFinal == null) fechaFinal = "";

if (!proveedor.equals(""))
{
 appendFilter += " and a.cod_provee = '"+proveedor+"'";
}
if (!cuenta.equals(""))
{
 appendFilter += " and a.cod_provee = '"+proveedor+"'";
}
if (!desde.equals(""))
{
 appendFilter += " and a.fecha_de_entrada >= to_date('"+desde+"','dd/mm/yyyy')";
}
if (!hasta.equals(""))
{
 appendFilter += " and a.fecha_de_entrada <= to_date('"+hasta+"','dd/mm/yyyy')";
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



sql = "select p.cod_provedor, p.nombre_proveedor, a.secuencia, d.descripcion desc_activo, a.valor_actual, nvl(a.orden__compra,0) as orden__compra, decode(a.estatus,'ACTI','Activo','RETIR','Retirado') estatus, ue.descripcion ejecutora, uf.descripcion fisica from tbl_com_proveedor p, tbl_con_detalle d, tbl_sec_unidad_ejec ue, tbl_con_ubic_fisica uf, tbl_con_activos a where a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.cod_compania = a.compania and ue.compania = a.compania and p.compania = a.compania and p.cod_provedor = a.cod_provee and  d.cod_espec = a.cuentah_activo and d.codigo_subesp = a.cuentah_espec and d.codigo_detalle = a.cuentah_detalle and ue.codigo = a.ue_codigo and uf.codigo_ubic(+) = a.nivel_codigo_ubic order by a.orden__compra, a.cod_provee,  a.secuencia";
al = SQLMgr.getDataList(sql);


sqlT = "select sum(a.valor_actual) totales from tbl_com_proveedor p, tbl_con_detalle d, tbl_sec_unidad_ejec ue, tbl_con_ubic_fisica uf, tbl_con_activos a where a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.cod_compania = a.compania and ue.compania = a.compania and p.compania = a.compania and p.cod_provedor = a.cod_provee and  d.cod_espec = a.cuentah_activo and d.codigo_subesp = a.cuentah_espec and d.codigo_detalle = a.cuentah_detalle and ue.codigo = a.ue_codigo and uf.codigo_ubic(+) = a.nivel_codigo_ubic";

	double monto_total = 0.00, monto_total_prov =0.00, monto_total_oc =0.00;


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
	String subtitle = "LISTADO DE ACTIVOS POR ORDEN DE COMPRA / PROVEEDOR";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);



	Vector dDetalle = new Vector();
		dDetalle.addElement(".08");
		dDetalle.addElement(".32");
		dDetalle.addElement(".10");
		dDetalle.addElement(".10");
		dDetalle.addElement(".25");
		dDetalle.addElement(".15");

 pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		pc.setFont(7, 1);

		pc.addBorderCols("CODIGO",1,1);
		pc.addBorderCols("DESCRIPCION DEL ACTIVO",1,1);
		pc.addBorderCols("VALOR ACTUAL",1,1);
		pc.addBorderCols("ESTADO",1,1);
		pc.addBorderCols("DEPARTAMENTO",1,1);
		pc.addBorderCols("UBICACION FISICA",2,1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//second row
	pc.setFont(8, 1);
	int no = 0;
	String prov = "";
	String orden = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(!orden.trim().equals(cdo.getColValue("orden__compra")))
		{
			 if(i!=0)
			 {
					pc.addCols("Total por Orden de Compra . . . . . . .",2,2);
					pc.addCols(""+CmnMgr.getFormattedDecimal(monto_total_oc),2,1);
					pc.addCols("",0,3);
					pc.addCols("",0,dDetalle.size());
				 monto_total_oc = 0.00;
			 }

			pc.setFont(7, 1);
			pc.addCols("O/Compra : ",1,1);
			pc.addCols(" "+cdo.getColValue("orden__compra"),0,5);
		}

		if(!prov.trim().equals(cdo.getColValue("cod_provedor")))
		{
			 if(i!=0)
			 {
					pc.addCols("Total por Proveedor . . . . . . . .",2,2);
					pc.addCols(""+CmnMgr.getFormattedDecimal(monto_total_prov),2,1);
					pc.addCols("",0,3);
					pc.addCols("",0,dDetalle.size());
				 monto_total_prov = 0.00;
			 }
			pc.setFont(7, 1);
			pc.addCols("Proveedor : ",0,1);
			pc.addCols(" [ "+cdo.getColValue("cod_provedor")+" ] "+cdo.getColValue("nombre_proveedor"),0,5);
		}

		pc.setFont(7, 0);
		pc.setVAlignment(0);

		 pc.setNoColumnFixWidth(dDetalle);
			pc.addCols(" "+cdo.getColValue("secuencia"),0,1);
			pc.addCols(" "+cdo.getColValue("desc_activo"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("valor_actual")),2,1);
			pc.addCols(" "+cdo.getColValue("estatus"),1,1);
			pc.addCols(" "+cdo.getColValue("ejecutora"),0,1);
			pc.addCols(" "+cdo.getColValue("fisica"),0,1);

		prov  = cdo.getColValue("cod_provedor");
		orden = cdo.getColValue("orden__compra");
		monto_total       += Double.parseDouble(cdo.getColValue("valor_actual"));
		monto_total_prov  += Double.parseDouble(cdo.getColValue("valor_actual"));
		monto_total_oc  += Double.parseDouble(cdo.getColValue("valor_actual"));
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{

		pc.addCols("Total por Proveedor . . . . . . . .",2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_total_prov),2,1);
		pc.addCols("",0,3);
		pc.addCols("",0,dDetalle.size());

		pc.addCols("Total por Orden de Compra . . . . . . .",2,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(monto_total_oc),2,1);
		pc.addCols("",0,3);

		CommonDataObject cdo1 = SQLMgr.getData(sqlT);
		pc.addCols(" Totales del Reporte: "+CmnMgr.getFormattedDecimal(monto_total),0,6);


	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>