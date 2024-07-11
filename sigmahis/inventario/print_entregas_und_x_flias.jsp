<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
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
		REPORTE:		INV0041.RDF
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilterEnt = new StringBuffer();
StringBuffer sbFilterDev = new StringBuffer();
String userName = UserDet.getUserName();
String titulo = request.getParameter("titulo");
String compania_sol = request.getParameter("compania_sol");
String compania2 = request.getParameter("compania2");
String unidad = request.getParameter("unidad");
String almacen = request.getParameter("almacen");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String verActivo = request.getParameter("verActivo");

if (titulo == null) titulo = " ";
if (almacen == null) almacen = "";
if (fDate == null) fDate = "";
if (tDate == null) tDate = "";
if (verActivo == null) verActivo = "S";

if (compania_sol != null && !compania_sol.trim().equals("")) {
	sbFilterEnt.append(" and a.compania_sol = ").append(compania_sol);
	sbFilterDev.append(" and dev.compania = ").append(compania_sol);
}
if (compania2 != null && !compania2.trim().equals("")) {
	sbFilterEnt.append(" and a.compania = ").append(compania2);
	sbFilterDev.append(" and dev.compania_dev = ").append(compania2);
}
if (unidad != null && !unidad.trim().equals("")) {
	sbFilterEnt.append(" and a.unidad_administrativa = ").append(unidad);
	sbFilterDev.append(" and dev.unidad_administrativa = ").append(unidad);
}
if (fDate != null && !fDate.trim().equals("")) {
	sbFilterEnt.append(" and trunc(a.fecha_entrega) >= to_date('").append(fDate).append("','dd/mm/yyyy')");
	sbFilterDev.append(" and trunc(dev.fecha_devolucion) >= to_date('").append(fDate).append("','dd/mm/yyyy')");
}
if (tDate != null && !tDate.trim().equals("")) {
	sbFilterEnt.append(" and trunc(a.fecha_entrega) <= to_date('").append(tDate).append("','dd/mm/yyyy')");
	sbFilterDev.append(" and trunc(dev.fecha_devolucion) <= to_date('").append(tDate).append("','dd/mm/yyyy')");
}
if (almacen != null && !almacen.trim().equals("")) {
	sbFilterEnt.append(" and i.codigo_almacen = ").append(almacen);
	sbFilterDev.append(" and dev.codigo_almacen = ").append(almacen);
}
if (verActivo != null && verActivo.equalsIgnoreCase("S")) {
	sbFilterEnt.append(" and b.cod_familia not in ( select column_value from table(select split(nvl(get_sec_comp_param(b.compania,'FLIA_ACTIVO'),'-999'),',') from dual) )");
	sbFilterDev.append(" and de.cod_familia not in ( select column_value from table(select split(nvl(get_sec_comp_param(dev.compania,'FLIA_ACTIVO'),'-999'),',') from dual) )");
}

/* entregas de unidades administrativas */
sbSql.append("select a.unidad_administrativa as unidad, b.cod_articulo as codigo_articulo, nvl(b.precio,0) as costos, b.compania")
	.append(", sum(nvl(b.cantidad,0)) as entregado, sum(nvl(b.cantidad,0)) - sum(nvl(b.cantidad,0)) as devuelto, sum(nvl(b.precio,0) * nvl(b.cantidad,0)) as cargo")
	.append(", (select descripcion from tbl_sec_unidad_ejec where compania = a.compania_sol and codigo = a.unidad_administrativa) as desc_unidad")
	.append(", (select (select nombre from tbl_inv_familia_articulo where compania = z.compania and cod_flia = z.cod_flia) from tbl_inv_articulo z where compania = b.compania and cod_articulo = b.cod_articulo) as desc_familia")
	.append(", (select cod_flia from tbl_inv_articulo where compania = b.compania and cod_articulo = b.cod_articulo) as familia")
	.append(", (select cod_clase from tbl_inv_articulo where compania = b.compania and cod_articulo = b.cod_articulo) as clase")
	.append(", (select descripcion from tbl_inv_articulo where compania = b.compania and cod_articulo = b.cod_articulo) as desc_articulo")
	.append(" from tbl_inv_entrega_material a, tbl_inv_detalle_entrega b, tbl_inv_inventario i")
	.append(" where a.req_anio is not null")
	.append(" and (b.compania = a.compania and b.no_entrega = a.no_entrega and b.anio = a.anio)")
	.append(" and (i.codigo_almacen = a.codigo_almacen and i.cod_articulo = b.cod_articulo and i.compania = b.compania)")
	.append(" and exists (select null from tbl_sec_unidad_ejec where compania = a.compania_sol and codigo = a.unidad_administrativa)")
	.append(sbFilterEnt)
	.append(" group by a.unidad_administrativa, b.cod_articulo, nvl(b.precio,0), b.compania, a.compania_sol");
/* devoluciones de unidades administrativas */
sbSql.append(" union all select dev.unidad_administrativa, de.cod_articulo as articulo_cod, nvl(de.precio,0) as costos, dev.compania")
	.append(", sum(nvl(de.cantidad,0)) - sum(nvl(de.cantidad,0)) as entregado, sum(nvl(-de.cantidad,0)) as devuelto, sum(nvl(-de.cantidad,0) * nvl(de.precio,0)) as devolucion")
	.append(", (select descripcion from tbl_sec_unidad_ejec where compania = dev.compania and codigo = dev.unidad_administrativa) as desc_unidad")
	.append(", (select (select nombre from tbl_inv_familia_articulo where compania = z.compania and cod_flia = z.cod_flia) from tbl_inv_articulo z where compania = dev.compania_dev and cod_articulo = de.cod_articulo) as desc_familia")
	.append(", (select cod_flia from tbl_inv_articulo where compania = dev.compania_dev and cod_articulo = de.cod_articulo) as familia")
	.append(", (select cod_clase from tbl_inv_articulo where compania = dev.compania_dev and cod_articulo = de.cod_articulo) as clase")
	.append(", (select descripcion from tbl_inv_articulo where compania = dev.compania_dev and cod_articulo = de.cod_articulo) as desc_articulo")
	.append(" from tbl_inv_devolucion dev, tbl_inv_detalle_devolucion de")
	.append(" where (de.compania = dev.compania and de.num_devolucion = dev.num_devolucion and de.anio_devolucion = dev.anio_devolucion)")
	.append(" and exists (select null from tbl_sec_unidad_ejec where compania = dev.compania and codigo = dev.unidad_administrativa)")
	.append(sbFilterDev)
	.append(" group by dev.unidad_administrativa, de.cod_articulo, nvl(de.precio,0), dev.compania, dev.compania_dev order by 8,1,9,12");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {

/*----------------------------------------------------------------------------------------------------------*/
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String title = "ENTREGAS A UNIDADES ADMINISTRATIVAS ";
	StringBuffer sbSubtitle = new StringBuffer();
	sbSubtitle.append("DESDE   ").append(fDate).append("   HASTA   ").append(tDate);
	String xtraSubtitle = titulo;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
		//float cHeight = 12.0f;


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".46");
		dHeader.addElement(".11");
		dHeader.addElement(".11");
		dHeader.addElement(".11");
		dHeader.addElement(".11");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, sbSubtitle.toString(), xtraSubtitle, userName, fecha, dHeader.size());
	//second row
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESC. ARTICULO",1);
		pc.addBorderCols("ENTREGADO",1);
		pc.addBorderCols("DEVUELTO",1);
		pc.addBorderCols("COSTO",1);
		pc.addBorderCols("MONTO",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body
	String groupBy = "",subGroupBy = "",und = "",observ ="";
	double totalFlia = 0.00, totalUnd = 0.00,total = 0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("familia")))
		{
			 if (i != 0)
			 {
				pc.setFont(7, 1,Color.blue);
				pc.addCols("Sub total x Familia: ",2,4);
				pc.addCols(" "+CmnMgr.getFormattedDecimal(totalFlia),2,2);

				totalFlia = 0.00;

				pc.setFont(7, 1,Color.blue);
				pc.addCols(" ",0,dHeader.size());

			}
		}
		if (!und.equalsIgnoreCase(cdo.getColValue("unidad")))
		{
			 if (i != 0)
			 {
				pc.setFont(7, 1,Color.blue);
					pc.addCols("Sub total x Unidad: ",2,4);
					pc.addCols(""+CmnMgr.getFormattedDecimal(totalUnd),2,2);
				totalUnd = 0.00;
			}
			pc.setFont(7, 1,Color.blue);
			pc.addCols(" "+cdo.getColValue("unidad")+"  -  "+cdo.getColValue("desc_unidad"),0,dHeader.size());
		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("familia")))
		{
			pc.setFont(7, 1,Color.red);
			pc.addCols(" "+cdo.getColValue("familia")+"  -  "+cdo.getColValue("desc_familia"),0,dHeader.size());
		}

		pc.setFont(7, 0);
			pc.addCols(cdo.getColValue("familia")+"-"+cdo.getColValue("clase")+"-"+cdo.getColValue("codigo_articulo"),1,1);
			pc.addCols(""+cdo.getColValue("desc_articulo"),0,1);
			pc.addCols(""+cdo.getColValue("entregado"),1,1);
			if( Double.parseDouble(cdo.getColValue("devuelto")) < 0) pc.setFont(7, 0,Color.red);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("devuelto")),1,1);
			pc.setFont(7, 0);
			pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###.####",cdo.getColValue("costos")),1,1);
			if( Double.parseDouble(cdo.getColValue("cargo")) < 0) pc.setFont(7, 0,Color.red);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("cargo")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		und = cdo.getColValue("unidad");
		groupBy  = cdo.getColValue("unidad")+"-"+cdo.getColValue("familia");

		totalFlia += Double.parseDouble(cdo.getColValue("cargo"));
		totalUnd  += Double.parseDouble(cdo.getColValue("cargo"));
		total     += Double.parseDouble(cdo.getColValue("cargo"));


	}//for i

	if (al.size() == 0)
	 {
		 pc.addCols("No existen registros",1,dHeader.size());
		}else{

		pc.setFont(7, 1,Color.blue);
			pc.addCols("Sub total x Familia: ",2,4);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalFlia),2,2);

		pc.setFont(7, 1,Color.blue);
			pc.addCols("Sub total x Unidad: ",2,4);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totalUnd),2,2);

		pc.setFont(7, 1,Color.blue);
			pc.addCols("Total: ",2,4);
			pc.addCols(" $ "+CmnMgr.getFormattedDecimal(total),2,2);
		}

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);

}//get
%>