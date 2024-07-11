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
/**    REPORTE  :  INV0074.RDF
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
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

ArrayList al = new ArrayList();
ArrayList alAl = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String almacen = request.getParameter("almacen");
String companiaDev = request.getParameter("companiDev");
String almacenDev = request.getParameter("almacenDev");
String compania = (String) session.getAttribute("_companyId");

String appendFilter2 = "";
if (fechaini == null ) fechaini="";
if (fechafin == null ) fechafin = "";
if (companiaDev == null) companiaDev = "";
if (almacenDev == null) almacenDev = "";
if (appendFilter == null) appendFilter = "";
if (almacen == null ) almacen="";

if(!fechaini.trim().equals(""))
{
 appendFilter   += " and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fechaini+"','dd/mm/yyyy') ";
 appendFilter2  += " and to_date(to_char(b.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fechaini+"','dd/mm/yyyy') ";

}
if(!fechafin.trim().equals(""))
{
 appendFilter   += " and to_date(to_char(a.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechafin+"','dd/mm/yyyy') ";
 appendFilter2  += " and to_date(to_char(b.fecha_devolucion,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechafin+"','dd/mm/yyyy') ";

}
if(!almacen.trim().equals("")) appendFilter += " and a.codigo_almacen = "+almacen;
if(!almacenDev.trim().equals(""))appendFilter2 += " and b.codigo_almacen = "+almacenDev;


sql = "select e.nombre as activo, d.descripcion as clasificacion, count(*) as nActivo, sum(b.cantidad*b.precio) as total from tbl_inv_entrega_material a, tbl_inv_detalle_entrega b, tbl_inv_articulo c, tbl_inv_clase_articulo d, tbl_inv_familia_articulo e where d.cod_flia in (select param_value from tbl_sec_comp_param where param_name ='FLIA_ACTIVO' and compania in(-1,"+compania+"))  "+appendFilter+" and a.compania = "+compania+"  and ((b.compania = a.compania and b.no_entrega = a.no_entrega and b.anio = a.anio) and (b.cod_familia = c.cod_flia) and (b.cod_clase = d.cod_clase) and   (b.cod_articulo = c.cod_articulo) and (c.compania = d.compania and c.cod_flia = d.cod_flia and c.cod_clase = d.cod_clase) and  (d.compania = e.compania and d.cod_flia = e.cod_flia)) group by e.nombre, d.descripcion order by d.descripcion";
al = SQLMgr.getDataList(sql);


	sql = "select a.descripcion as almacen, f.nombre as familia, c.cod_familia||'-'||c.cod_clase||'-'||c.cod_articulo as cod_art, d.descripcion as desc_art, e.descripcion as clasificacion, sum(c.cantidad * c.precio) as total, sum(c.cantidad) as cantidad from tbl_inv_devolucion b, tbl_inv_detalle_devolucion c, tbl_inv_articulo d, tbl_inv_almacen a, tbl_inv_clase_articulo e, tbl_inv_familia_articulo f where e.cod_flia in (select param_value from tbl_sec_comp_param where param_name ='FLIA_ACTIVO' and compania in (-1,"+compania+"))   "+appendFilter2+" and b.compania ="+compania+" and (c.compania= b.compania and c.num_devolucion = b.num_devolucion and c.anio_devolucion = b.anio_devolucion) and (c.cod_articulo = d.cod_articulo and c.cod_clase = d.cod_clase and c.cod_familia = d.cod_flia) and (b.compania_dev = a.compania and b.codigo_almacen = a.codigo_almacen) and (d.compania = e.compania and d.cod_flia = e.cod_flia and d.cod_clase = e.cod_clase) and (e.compania = f.compania and e.cod_flia = f.cod_flia)  group by a.descripcion,f.nombre , c.cod_familia||'-'||c.cod_clase||'-'||c.cod_articulo, d.descripcion, e.descripcion order by  a.descripcion, c.cod_familia||'-'||c.cod_clase||'-'||c.cod_articulo, d.descripcion, e.descripcion " ;

	alAl = SQLMgr.getDataList(sql);

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
	String title = "INFORME DE GASTOS DE ACTIVOS POR DEPARTAMENTO";
	String subtitle = "";
		if(!fechaini.trim().equals("") && !fechafin.trim().equals("")) subtitle = "DEL "+fechaini.substring(0,10)+" AL "+fechafin.substring(0,10);
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

	
	pc.setTableHeader(1);//create de table header

	//table body
	String groupBy = "";
	String groupBy2 = "";
	double totalActivo =0.00, devWh =0.00;
	double cant = 0.00;
	double total = 0.00;
	double totalFinal = 0.00;
	double dev = 0.00;
	double totdev = 0;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (i == 0)
			{
					pc.setFont(8, 1,Color.blue);
					pc.addCols(" [ "+cdo.getColValue("activo")+" ] ",0,dHeader.size());

					pc.addCols("",0,1);
					pc.addCols("CLASIFICACION",0,2);
					pc.addCols("TOTAL",2,1);
					pc.addCols("",0,1);
			}
			
			pc.setFont(contentFontSize,0);
			
			pc.addCols("",1,1);
			pc.addCols(""+cdo.getColValue("clasificacion"),0,2);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
			pc.addCols("",1,1);
		
			
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("codUnidad");
		totalActivo  += Double.parseDouble(cdo.getColValue("total"));
		total        += Double.parseDouble(cdo.getColValue("total"));

}

if (al.size() == 0)	pc.addCols("No existen registros",1,dHeader.size());
	else
  {


			pc.setFont(8, 1,Color.blue);
			pc.addCols("Total: "+CmnMgr.getFormattedDecimal(totalActivo),2,4);
			pc.addCols(" ",0,1);

			pc.setFont(8, 1,Color.red);
			pc.addCols("Gran Total: "+CmnMgr.getFormattedDecimal(totalActivo),2,4);
			pc.addCols(" ",0,1);
		
		  pc.addCols(" ",0,dHeader.size());
		
			
			for (int k=0; k<alAl.size(); k++)
			{
				CommonDataObject cdo = (CommonDataObject) alAl.get(k);
					if (!groupBy2.equalsIgnoreCase(cdo.getColValue("almacen")))
					{
							if (k != 0)
							{
								pc.setFont(8, 1,Color.blue);
								pc.addCols("Total:  ***************** "+CmnMgr.getFormattedDecimal(""+devWh),1,5);
								devWh = 0.00;
							}
							
							pc.setFont(8, 1,Color.blue);
							pc.addCols("[ DEVOLUCION ]      "+cdo.getColValue("almacen"),0,dHeader.size());
							
							pc.addCols("CLASIFICACION",0,1);
							pc.addCols("CODIGO",0,1);
							pc.addCols("DESC ART",0,1);
							pc.addCols("CANTIDAD",0,1);
							pc.addCols("PRECIO",2,1);
					}
					
							pc.setFont(8, 0);
							pc.addCols(""+cdo.getColValue("clasificacion"),0,1);
							pc.addCols(""+cdo.getColValue("cod_art"),0,1);
							pc.addCols(""+cdo.getColValue("desc_art"),0,1);
							pc.addCols(""+cdo.getColValue("cantidad"),0,1);
							pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);

							totdev    += Double.parseDouble(cdo.getColValue("total"));
							devWh     += Double.parseDouble(cdo.getColValue("total"));
							groupBy2 = cdo.getColValue("almacen");
							
			} //endfor k
			
			if (alAl.size() != 0)
			{
					pc.setFont(8, 1,Color.blue);
					pc.addCols("Total: "+CmnMgr.getFormattedDecimal(""+devWh),2,5);
		
					pc.setFont(8, 1,Color.blue);
					pc.addCols("Gran Total: "+CmnMgr.getFormattedDecimal(""+totdev),2,4);
					pc.addCols("",0,1);
	
					totalFinal = total - totdev;
				
					pc.setFont(8, 1,Color.red);
					pc.addCols("TOTAL  POR:"+CmnMgr.getFormattedDecimal(""+totalFinal),2,4);
					pc.addCols("",0,1);
			}
		}
		
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>