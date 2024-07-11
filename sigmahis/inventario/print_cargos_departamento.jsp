<%//@ page errorPage="../error.jsp"%>
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
/**    REPORTE  :  INV0052.RDF
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
ArrayList alAl = new ArrayList();
ArrayList alTotal = new ArrayList();
ArrayList alTotAl = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String almacen = request.getParameter("almacen");
String companiaDev = request.getParameter("companiaDev");
String compania = request.getParameter("compania");
String almacenDev = request.getParameter("almacenDev");
String unidad = request.getParameter("unidad");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

if (fechaini == null) fechaini="";// fechaini="01/01/1901";
if (fechafin == null) fechafin="";// fechafin = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (companiaDev == null) companiaDev = "";
if (almacenDev == null) almacenDev = "";
if (appendFilter == null) appendFilter = "";
if (unidad == null) unidad = "";
String appendFilter1 = "", appendFilter2 = "";
if(!companiaDev.equals("")){
	appendFilter1 += " and a.compania = "+companiaDev;
	appendFilter2 += " and a.compania_dev = "+companiaDev;
}
if(!compania.equals("")){
	appendFilter1 += " and a.compania_sol = "+compania;
	appendFilter2 += " and a.compania = "+compania;
}
if(!almacenDev.equals("")){
	appendFilter1 += " and a.codigo_almacen = "+almacenDev;
	appendFilter2 += " and a.codigo_almacen = "+almacenDev;
}
if(!fechaini.equals("")){
	appendFilter1 += " and to_date(to_char(a.fecha_entrega, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
	appendFilter2 += " and to_date(to_char(a.fecha_devolucion, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
}
if(!fechafin.equals("")){
	appendFilter1 += " and to_date(to_char(a.fecha_entrega, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')";
	appendFilter2 += " and to_date(to_char(a.fecha_devolucion, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')";
}
if(!unidad.equals("")){
	appendFilter1 += " and a.unidad_administrativa = "+unidad;
	appendFilter2 += " and a.unidad_administrativa = "+unidad;
}

//sql = "select c.compania, c.codigo as codUnidad, c.descripcion as descUnidad, b.cod_familia as codFamilia ,d.nombre as descFamilia, sum(b.cantidad *b.precio) entrada from tbl_inv_detalle_entrega b, tbl_inv_entrega_material a, tbl_sec_unidad_ejec c, tbl_inv_familia_articulo d  where   a.unidad_administrativa is not null and a.codigo_almacen = nvl('"+almacenDev+"',a.codigo_almacen) and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') >= nvl(to_date('"+fechaini+"','dd/mm/yyyy'), to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') <= nvl(to_date('"+fechafin+"','dd/mm/yyyy'), to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and c.codigo = nvl('"+unidad+"',c.codigo) and d.cod_flia not in (7,34) and a.req_anio is not null and (b.compania = a.compania and  b.no_entrega = a.no_entrega and b.anio = a.anio) and a.compania = nvl('"+companiaDev+"',a.compania) and a.compania_sol = nvl('"+compania+"',a.compania_sol) and (a.compania_sol = c.compania and a.unidad_administrativa = c.codigo) and (d.cod_flia  = b.cod_familia and d.compania = b.compania) group by c.compania, c.descripcion, c.codigo, b.cod_familia,d.nombre";
//sql +=" union ";
//sql +="select c.compania as comDev ,c.codigo as codUnidad, c.descripcion as descUnidad, b.cod_familia as codFamilia, d.nombre as descFamilia,(sum(nvl(b.cantidad,0) * nvl(b.precio,0)) *-1) entrada from tbl_inv_devolucion a, tbl_inv_detalle_devolucion b, tbl_sec_unidad_ejec c, tbl_inv_familia_articulo d where to_date(to_char(a.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') >= nvl(to_date('"+fechaini+"','dd/mm/yyyy'), to_date(to_char(a.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and to_date(to_char(a.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') <= nvl(to_date('"+fechafin+"','dd/mm/yyyy'), to_date(to_char(a.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and c.descripcion =  nvl('"+unidad+"', c.descripcion) and a.codigo_almacen = nvl('"+almacen+"', a.codigo_almacen) and a.compania = nvl("+companiaDev+",a.compania) and a.compania_dev = nvl("+compania+",a.compania_dev) and d.cod_flia not in (7,34) and (b.compania = a.compania and  b.num_devolucion = a.num_devolucion and b.anio_devolucion = a.anio_devolucion) and (c.compania = a.compania and c.codigo = a.unidad_administrativa) and (d.cod_flia = b.cod_familia and d.compania = a.compania_dev) group by c.compania,c.descripcion,c.codigo,b.cod_familia,d.nombre";

sql = "select d.codigo codUnidad, d.descripcion descUnidad, c.nivel, c.cod_flia codFamilia, c.nombre descFamilia, sum(nvl(b.cantidad, 0) * nvl(b.precio, 0)) entrega, 0 devolucion from tbl_inv_entrega_material a, tbl_inv_detalle_entrega b, tbl_inv_familia_articulo c, tbl_sec_unidad_ejec d where a.unidad_administrativa is not null and c.cod_flia not in(select param_value from tbl_sec_comp_param where compania in(-1,a.compania) and param_name ='FLIA_ACTIVO') and a.req_anio is not null and (b.compania = a.compania and b.no_entrega = a.no_entrega and b.anio = a.anio) and (b.cod_familia = c.cod_flia and c.compania = a.compania) and (a.compania_sol = d.compania and a.unidad_administrativa = d.codigo)"+appendFilter1+" group by d.codigo, d.descripcion, c.nivel, c.cod_flia, c.nombre,a.compania union all select d.codigo cod_unidad, d.descripcion desc_unidad, c.nivel, c.cod_flia codFamilia,c.nombre descFamilia, 0 entrega, (sum(b.cantidad * b.precio) * -1) devolucion from tbl_inv_devolucion a, tbl_inv_detalle_devolucion b, tbl_inv_familia_articulo c, tbl_sec_unidad_ejec d where c.cod_flia not in(select param_value from tbl_sec_comp_param where compania in(-1,a.compania) and param_name ='FLIA_ACTIVO') and (b.compania = a.compania and b.num_devolucion = a.num_devolucion and b.anio_devolucion = a.anio_devolucion) and (b.cod_familia = c.cod_flia and c.compania = a.compania_dev) and (a.compania = d.compania and a.unidad_administrativa = d.codigo)"+appendFilter2+" group by d.codigo, d.descripcion, c.nivel, c.cod_flia, c.nombre,a.compania";

String sqlDet = "select codUnidad, descUnidad, nivel, codFamilia, descFamilia, sum(entrega+devolucion) total from ("+sql+") group by codUnidad, descUnidad, nivel, codFamilia, descFamilia order by descUnidad, descFamilia";
al = SQLMgr.getDataList(sqlDet);

 //sql ="select distinct c.codigo as codUnidad, c.descripcion as descUnidad, sum(b.cantidad *b.precio) inEntrada,nvl((select (sum(nvl(f.cantidad,0) * nvl(f.precio,0)) *-1) inEntradaDev from tbl_inv_devolucion e, tbl_inv_detalle_devolucion f, tbl_sec_unidad_ejec g, tbl_inv_familia_articulo h where to_date(to_char(e.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') >= nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(e.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and to_date(to_char(e.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') <= nvl(to_date('"+fechafin+"','dd/mm/yyyy'),to_date(to_char(e.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and g.descripcion = nvl('"+unidad+"', g.descripcion) and e.codigo_almacen = nvl('"+almacen+"', e.codigo_almacen) and e.compania = nvl("+companiaDev+",e.compania) and e.compania_dev = nvl("+compania+",e.compania_dev) and h.cod_flia not in (7,34) and (f.compania = e.compania and f.num_devolucion = e.num_devolucion) and f.anio_devolucion = e.anio_devolucion and g.CODIGO = nvl(c.codigo,g.codigo) and g.descripcion = nvl(c.descripcion,g.descripcion) and (g.compania = e.compania and g.codigo = e.unidad_administrativa) and (h.cod_flia = f.cod_familia and h.compania = e.compania_dev)  group by g.codigo, g.descripcion),0) as dev from tbl_inv_detalle_entrega b, tbl_inv_entrega_material a, tbl_sec_unidad_ejec c, tbl_inv_familia_articulo d where a.unidad_administrativa is not null and a.codigo_almacen = nvl('"+almacenDev+"',a.codigo_almacen) and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') >= nvl(to_date('"+fechaini+"','dd/mm/yyyy'),to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') <= nvl(to_date('"+fechafin+"','dd/mm/yyyy'), to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy')) and c.codigo = nvl('"+unidad+"', c.codigo) and d.cod_flia not in (7,34) and a.req_anio is not null and (b.compania = a.compania and b.no_entrega = a.no_entrega and b.anio = a.anio) and a.compania = nvl('"+companiaDev+"',a.compania) and a.compania_sol = nvl('"+compania+"',a.compania_sol) and (a.compania_sol = c.compania and a.unidad_administrativa = c.codigo) and (d.cod_flia  = b.cod_familia and d.compania = b.compania) group by c.descripcion,c.codigo";
String sqlTotUnidad = "select codUnidad, sum(entrega+devolucion) total from ("+sql+") group by codUnidad";

alTotal = SQLMgr.getDataList(sqlTotUnidad);


//sql = "select distinct nvl(i.nivel,'S/N') as nivel, decode(i.nivel,'040','OXIGENO','041','MATERIALES','042','MEDICAMENTOS','043','COMESTIBLE','044','ANESTESIA','045','OTROS','','SIN NIVEL') as descNivel, nvl((select sum(nvl(b.cantidad,0)*nvl(b.precio,0)) from detalle_entrega b, entrega_material a,familia_articulo c where a.unidad_administrativa is not null and a.unidad_administrativa = NVL('"+unidad+"', a.unidad_administrativa) and a.compania = 1 and a.compania_sol = 1  and c.cod_flia not in (7,34) and nvl(c.nivel,'S/N') = nvl(i.nivel,'S/N')  and a.req_anio is not null and (b.compania = a.compania and b.no_entrega = a.no_entrega and b.anio = a.anio) and (b.cod_familia = c.cod_flia and c.compania = a.compania)),0)  + nvl((select (sum(e.cantidad*e.precio) *-1) from devolucion d, detalle_devolucion e ,familia_articulo f where to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') >= nvl(to_date('"+fechaini+"','dd/mm/yyyy'), to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')  <= nvl(to_date('"+fechafin+"','dd/mm/yyyy'), to_date(to_char(d.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy')) and d.codigo_almacen = nvl('"+almacenDev+"', d.codigo_almacen) and nvl(f.nivel,'S/N') = nvl(i.nivel,'S/N') and d.compania = nvl('"+companiaDev+"', d.compania) and d.compania_dev = nvl('"+compania+"', d.compania_dev) and d.unidad_administrativa = NVL('"+unidad+"', d.unidad_administrativa) and f.cod_flia not in (7,34) and (e.compania = d.compania and e.num_devolucion = d.num_devolucion and e.anio_devolucion = d.anio_devolucion) and(e.cod_familia = f.cod_flia and f.compania = d.compania_dev )),0) as entDev from  familia_articulo i where i.compania =  nvl('"+companiaDev+"',i.compania)";
String sqlNiveles = "select x.nivel,  (select max(nombre) from tbl_inv_familia_articulo where nivel = x.nivel) as descNivel, sum(x.entrega+x.devolucion) total from ("+sql+") x group by x.nivel";
alAl = SQLMgr.getDataList(sqlNiveles);

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
	boolean isLandscape = false;
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
	String title = "INFORME DE GASTOS POR DEPARTAMENTOS";
	String subtitle = "DEL "+fechaini.substring(0,8)+" AL "+fechafin.substring(0,8);
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".30");
		dHeader.addElement(".10");



	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addCols("",0,1);
		pc.addCols("CODIGO",0,1);
		pc.addCols("DESCRIPCION",0,1);
		pc.addCols("MONTO",2,1);
		pc.addCols("",0,1);
	pc.setTableHeader(2);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double total = 0.00,totalUnd=0.00;
	double res = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codUnidad")))
		{
			if (i != 0)
			{
					pc.setFont(8, 1,Color.blue);
					pc.addCols("SubTotal por Depto.: "+CmnMgr.getFormattedDecimal(totalUnd),2,4);
					pc.addCols("",0,1);
					totalUnd = 0.00;

			}
				pc.setFont(8, 1,Color.blue);
				pc.addBorderCols("[ "+cdo.getColValue("codUnidad")+" ] ",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(" "+cdo.getColValue("descUnidad"),1,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(" ",0,2,0.5f,0.0f,0.0f,0.0f);
		}
			pc.setFont(contentFontSize,0);

			pc.addCols(" ",1,1);
			pc.addCols(""+cdo.getColValue("codFamilia"),0,1);
			pc.addCols(""+cdo.getColValue("descFamilia"),0,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
			pc.addCols(" ",1,1);





		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("codUnidad");
		total += Double.parseDouble(cdo.getColValue("total"));
		totalUnd += Double.parseDouble(cdo.getColValue("total"));

}

if (al.size() == 0)	pc.addCols("No existen registros",1,dHeader.size());
	else
  {


			pc.setFont(8, 1,Color.blue);
			pc.addCols("SubTotal por Depto.: "+totalUnd,2,dHeader.size()-1);
			pc.addCols(" ",0,1);

			pc.setFont(8, 1,Color.red);
			pc.addCols("TOTAL:"+CmnMgr.getFormattedDecimal(total),2,4);
			pc.addCols(" ",0,1);

		  pc.addCols(" ",0,dHeader.size());

				pc.setFont(8, 1,Color.blue);
				pc.addCols(" ",1,1);
				pc.addBorderCols(" Resumen por nivel contable",1,3);
				pc.addCols(" ",1,1);

				total = 0.00;

			for (int k=0; k<alAl.size(); k++)
			{
				CommonDataObject cdo = (CommonDataObject) alAl.get(k);

					pc.setFont(8, 0);
					pc.addCols(" ",1,1);
					pc.addCols(""+cdo.getColValue("nivel"),0,1);
					pc.addCols(""+cdo.getColValue("descNivel"),0,1);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
					pc.addCols(" ",2,1);
					total += Double.parseDouble(cdo.getColValue("total"));
			} //endfor k

				pc.setFont(8, 1,Color.red);
				pc.addCols("Gran Total:"+CmnMgr.getFormattedDecimal(total),2,4);
				pc.addCols(" ",0,1);
		}

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>