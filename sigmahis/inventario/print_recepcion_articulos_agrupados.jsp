<%@ page errorPage="../error.jsp"%>
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
ArrayList alDev = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String sql = "",desc ="";
String appendFilter = request.getParameter("appendFilter");
String appendFilter1 = "", appendFilter2 = "", filter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String almacen = request.getParameter("almacen");
String fp = request.getParameter("fp");
String compania = request.getParameter("compania");//(String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String proveedor = request.getParameter("proveedor");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");

if(almacen== null) almacen = "";
if(proveedor== null) proveedor = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";

if (appendFilter == null) appendFilter = "";
if (appendFilter1 == null) appendFilter1 = "";
if (appendFilter2 == null) appendFilter2 = "";

if(!fDate.trim().equals("")&&!tDate.trim().equals("")) 
appendFilter += " and to_date(to_char(a.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and  to_date('"+tDate+"','dd/mm/yyyy') ";
appendFilter1 += " and to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and  to_date('"+tDate+"','dd/mm/yyyy') ";
appendFilter2 += " and to_date(to_char(a.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and  to_date('"+tDate+"','dd/mm/yyyy') ";

if(fp.trim().equals("FC") || fp.trim().equals("FCN")) //fc_new 
{
desc = " (CREDITO)";
appendFilter +=" and a.fre_documento in ('OC','FC','FR') ";// factura credito
}

if(!almacen.trim().equals("") )  
{
filter +=" and a.codigo_almacen = "+almacen;
}


sql = "select type, nvl(total,0) total, cod_almacen,  desc_almacen,  tipoRec from ( select 'A' type, SUM(a.MONTO_TOTAL) total, a.codigo_almacen cod_almacen,  al.descripcion desc_almacen, dr.descripcion tipoRec  from tbl_inv_recepcion_material a, tbl_inv_almacen al,  TBL_INV_DOCUMENTO_RECEPCION dr where a.compania = "+compania+appendFilter+filter+ " and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen) and  a.estado = 'R' and a.FRE_DOCUMENTO = dr.DOCUMENTO  group by 1,a.codigo_almacen,al.descripcion, dr.descripcion";
sql += " union ";

// devoluciones///
sql +=" select 'B', SUM(a.MONTO)*-1  monto_dev, a.codigo_almacen alm_dev, al.descripcion almacen_dev, 'NOTAS DE CREDITO' tipoRec from tbl_inv_devolucion_prov a, tbl_inv_almacen al where a.compania = "+compania+appendFilter1+filter+ " and a.anulado_sino = 'N'  and ( a.tipo_dev = 'N'  or a.tipo_dev is null)  and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen)   group by 1,a.codigo_almacen, al.descripcion, 5 ";

sql += " union ";
///  ajustes ////
sql += " select 'C', SUM(a.TOTAL) monto_nd, a.codigo_almacen alm_nd, al.descripcion almacen_aj,'NOTAS DE DEBITO' tipoRec from tbl_inv_ajustes a, tbl_inv_almacen al where a.compania = "+compania+appendFilter2+filter+ " and a.codigo_ajuste=3 and (a.compania = al.compania and a.codigo_almacen = al.codigo_almacen)  group by 1, a.codigo_almacen, al.descripcion, 5    ) order by 1,3,5";


al = SQLMgr.getDataList(sql);


//sql="select distinct nvl(a.nivel,'S/N') nivel  , (select max(nombre) from tbl_inv_familia_articulo where nivel = a.nivel) descNivel, nvl(x.total,0)-nvl(y.nota_credito,0) + nvl(z.total_nd,0) totRes from    tbl_inv_familia_articulo a, (     select sum((nvl(precio,0)*nvl(cantidad,0))*nvl(articulo_und,0))total, nvl(fa.nivel,'S/N') nivel from tbl_inv_recepcion_material a,  tbl_inv_detalle_recepcion d, tbl_inv_familia_articulo fa where a.compania =   "+compania+appendFilter+filter+ " and a.fre_documento in ( 'OC', 'FR', 'FC' ) and a.estado = 'R' and d.anio_recepcion = a.anio_recepcion and d.numero_documento = a.numero_documento and d.compania = a.compania and (d.compania = fa.compania(+) and d.cod_familia = fa.cod_flia(+) and fa.compania =a.compania) group by nvl(fa.nivel,'S/N') )x, (  select sum((nvl(d.precio,0)* decode(d.cantidad,0,1,d.cantidad))+( decode(d.cantidad,0,1,d.cantidad) * nvl(d.art_itbm,0))) nota_credito, nvl(fa.nivel,'S/N') nivel from tbl_inv_devolucion_prov  a, tbl_inv_detalle_proveedor d, tbl_inv_familia_articulo fa where a.compania = "+compania+appendFilter1+filter+ " and a.anulado_sino = 'N' and (  a.tipo_dev = 'N' or a.tipo_dev is null) and a.compania = d.compania and a.anio = d.anio and a.num_devolucion = d.num_devolucion and d.compania = fa.compania and d.cod_familia = fa.cod_flia group by  nvl(fa.nivel,'S/N')   ) y ,( select  sum(nvl(d.precio,0)* decode(d.cantidad_ajuste,0,1,d.cantidad_ajuste)) total_nd,nvl(fa.nivel,'S/N') nivel from tbl_inv_ajustes a, tbl_inv_detalle_ajustes  d, tbl_inv_familia_articulo fa, tbl_inv_recepcion_material rm where a.compania = "+compania+" and a.codigo_ajuste = 3 and a.compania = d.compania and a.anio_ajuste = d.anio_ajuste and a.numero_ajuste = d.numero_ajuste and a.anio_doc = rm.anio_recepcion and a.numero_doc = rm.numero_documento and a.compania = rm.compania and a.codigo_ajuste = d.codigo_ajuste and d.cod_familia = fa.cod_flia and d.compania = fa.compania "+appendFilter2+filter+" group by  nvl(fa.nivel,'S/N')  )z where   compania = "+compania+" and nvl(a.nivel,'S/N') = x.nivel(+)  and nvl(a.nivel,'S/N') = y.nivel (+) and nvl(a.nivel,'S/N')  = z.nivel (+) ";

sql=" select a.* ,a.cta1||'.'||a.cta2||'.'||a.cta3||'.'||a.cta4||'.'||a.cta5||'.'||a.cta6 cta,  (select max(nombre) from tbl_inv_familia_articulo where nivel = a.nivel) descNivel from (select round(sum(x.total),2)totRes,x.nivel,x.codigo_almacen,x.cod_flia, al.cg_cta1 cta1,al.cg_cta2 cta2,x.nivel cta3,al.cg_cta4 cta4,al.cg_cta5 cta5,al.cg_cta6 cta6 from ( select sum((nvl(precio,0)*nvl(cantidad,0))*nvl(articulo_und,0))total, nvl(fa.nivel,'S/N') nivel,a.codigo_almacen,fa.cod_flia  from tbl_inv_recepcion_material a,  tbl_inv_detalle_recepcion d, tbl_inv_familia_articulo fa where a.compania =  "+compania+appendFilter+filter+ " and a.fre_documento in ('OC','FC','FR')  and a.fre_documento in ( 'OC', 'FR', 'FC' ) and a.estado = 'R' and d.anio_recepcion = a.anio_recepcion and d.numero_documento = a.numero_documento and d.compania = a.compania and (d.compania = fa.compania(+) and d.cod_familia = fa.cod_flia(+) and fa.compania =a.compania) group by nvl(fa.nivel,'S/N') ,a.codigo_almacen,fa.cod_flia union   select -sum((nvl(d.precio,0)* decode(d.cantidad,0,1,d.cantidad))+( decode(d.cantidad,0,1,d.cantidad) * nvl(d.art_itbm,0))) nota_credito, nvl(fa.nivel,'S/N') nivel,a.codigo_almacen,fa.cod_flia  from tbl_inv_devolucion_prov  a, tbl_inv_detalle_proveedor d, tbl_inv_familia_articulo fa where a.compania =  "+compania+appendFilter1+filter+ "  and a.anulado_sino = 'N' and (  a.tipo_dev = 'N' or a.tipo_dev is null) and a.compania = d.compania and a.anio= d.anio and a.num_devolucion = d.num_devolucion and d.compania = fa.compania and d.cod_familia = fa.cod_flia group by  nvl(fa.nivel,'S/N') ,a.codigo_almacen,fa.cod_flia union select  sum(nvl(d.precio,0)* decode(d.cantidad_ajuste,0,1,d.cantidad_ajuste)) total_nd,nvl(fa.nivel,'S/N') nivel,a.codigo_almacen,fa.cod_flia from tbl_inv_ajustes a, tbl_inv_detalle_ajustes  d, tbl_inv_familia_articulo fa, tbl_inv_recepcion_material rm where a.compania = "+compania+" and a.codigo_ajuste = 3 and a.compania = d.compania and a.anio_ajuste = d.anio_ajuste and a.numero_ajuste = d.numero_ajuste and a.anio_doc = rm.anio_recepcion and a.numero_doc = rm.numero_documento and a.compania = rm.compania and a.codigo_ajuste = d.codigo_ajuste and d.cod_familia = fa.cod_flia and d.compania = fa.compania  "+appendFilter2+filter+"  group by  nvl(fa.nivel,'S/N'),a.codigo_almacen,fa.cod_flia )x,tbl_inv_almacen al where x.codigo_almacen = al.codigo_almacen and al.compania = "+compania+" group by x.nivel,x.codigo_almacen,x.cod_flia ,al.cg_cta1 ,al.cg_cta2,x.nivel,al.cg_cta4 ,al.cg_cta5,al.cg_cta6 ) a  order by a.codigo_almacen,a.cod_flia";


alDev = SQLMgr.getDataList(sql);

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
	String title = "RESUMEN DE RECEPCION AGRUPADAS POR TIPO";
	String subtitle = "DEL "+fDate+ " AL "+tDate;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".45");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
	
	

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		
	pc.setTableHeader();//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double total = 0.00;
	double res = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")))
		{
			
				pc.setFont(groupFontSize,1);
				pc.addCols("",1,dHeader.size());
				
				pc.setFont(groupFontSize, 1,Color.blue);
					pc.addCols("",0,1);
				pc.addCols("  "+cdo.getColValue("cod_almacen")+"    "+cdo.getColValue("desc_almacen"),0,3);
				pc.addCols("",1,1);
				pc.addCols("Tipo",0,1);
				pc.addCols("Total",2,1);
				pc.addCols("",2,1);
			
		}

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		
			pc.addCols("",1,1);
			pc.addCols(""+cdo.getColValue("tipoRec"),0,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("total")),2,1);
			pc.addCols("",2,1);
			
			
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("cod_almacen");
		total += Double.parseDouble(cdo.getColValue("total"));

}


	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(groupFontSize,1);
		
	
		if(fp.trim().equals("FC") )	
		{
			pc.addCols("",1,dHeader.size());
			
			pc.addCols("  T O T A L:  ",2,2);
			pc.addCols("  "+CmnMgr.getFormattedDecimal(total),2,1);
			pc.addCols("",2,1);

			pc.setFont(groupFontSize, 1,Color.red);
			pc.addCols("",0,dHeader.size());
		

				pc.setFont(groupFontSize, 1,Color.blue);
				pc.addBorderCols(" Resumen por Nivel Contable",1,dHeader.size());
				
				
				pc.addCols("Tipo",1,1);
				pc.addCols("Descripcion",0,1);
				pc.addCols("Cuenta",0,1);
				pc.addCols("Total",2,1);
				
		
		
			for (int k=0; k<alDev.size(); k++)
	    {
		
						CommonDataObject cdo = (CommonDataObject) alDev.get(k);
					
						res += Double.parseDouble(cdo.getColValue("totRes"))  ;
						
						pc.setFont(groupFontSize, 0,Color.red);
						
						
						pc.addBorderCols(""+cdo.getColValue("nivel"),1,1);
						pc.addBorderCols(""+cdo.getColValue("descNivel"),0,1);
						pc.addBorderCols(""+cdo.getColValue("cta"),0,1);
						pc.addBorderCols(""+CmnMgr.getFormattedDecimal("###,###,##0.00",cdo.getColValue("totRes")),2,1);
			} //end for k
		pc.setFont(groupFontSize, 0,Color.blue);
		pc.addBorderCols("TOTAL  POR:"+CmnMgr.getFormattedDecimal("###,###,##0.00",res),2,dHeader.size());
		}
		
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>