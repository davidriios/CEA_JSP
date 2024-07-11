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
		REPORTE:		INV00131.RDF
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time="";
String userName = UserDet.getUserName();
String almacen = request.getParameter("almacen");
String estado = request.getParameter("estado");
String compania = (String) session.getAttribute("_companyId");
String anio = request.getParameter("anio");

String noAjuste = request.getParameter("noAjuste");
String numero_ajuste1 = request.getParameter("numero_ajuste1");
String numero_ajuste2 = request.getParameter("numero_ajuste2");

String codigo_ajuste = request.getParameter("codigo_ajuste");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String titulo = request.getParameter("titulo");
String consignacion = request.getParameter("consignacion");
String fg = request.getParameter("fg");
String depto = request.getParameter("depto");

if(fg== null) fg = "AJA";
if(almacen== null) almacen = "";
if(estado== null) estado = "";
if(anio== null) anio = "";
if(noAjuste== null) noAjuste = "";
if(numero_ajuste1== null) numero_ajuste1 = "";
if(numero_ajuste2== null) numero_ajuste2 = "";
if(codigo_ajuste== null) codigo_ajuste = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(titulo== null) titulo = " AJUSTES AL INVENTARIO "+((fg.trim().equals("AP"))?" (APROBADOS) ":"");
if(depto== null) depto = " INVENTARIO ";

if (appendFilter == null) appendFilter = "";
if (consignacion == null) consignacion = "";

if(!almacen.trim().equals(""))        appendFilter  = " and aj.codigo_almacen = "+almacen;
if(!anio.trim().equals(""))           appendFilter += " and aj.anio_ajuste = "+anio;
if(!noAjuste.trim().equals("")) appendFilter += " and aj.numero_ajuste  = "+noAjuste ;

if(!numero_ajuste1.trim().equals("")) appendFilter += " and aj.numero_ajuste >= "+numero_ajuste1 ;
if(!numero_ajuste2.trim().equals("")) appendFilter += " and aj.numero_ajuste <= "+numero_ajuste2 ;
if(!codigo_ajuste.trim().equals(""))  appendFilter += " and aj.codigo_ajuste = "+codigo_ajuste;
if(!estado.trim().equals(""))         appendFilter += " and aj.estado = '"+estado+"'";
if(!fDate.trim().equals("")) appendFilter += " and to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+fDate+"','dd/mm/yyyy') ";
if(!tDate.trim().equals("")) appendFilter += " and to_date(to_char(aj.fecha_ajuste,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+tDate+"','dd/mm/yyyy') ";

if(!consignacion.trim().equals(""))  appendFilter += " and a.consignacion_sino =  '"+consignacion+"'";
if(!fg.trim().equals("AJ"))  appendFilter += " and da.check_aprov = 'S' and aj.estado='A'";



sql = "select to_char(aj.fecha_mod,'dd/mm/yyyy') fecha, al.codigo_almacen, al.descripcion desc_almacen, fa.cod_flia, fa.nombre desc_flia, da.cod_familia||'-'||da.cod_clase||'-'||da.cod_articulo as cod_articulo , a.descripcion desc_articulo, aj.anio_ajuste||'-'||aj.numero_ajuste codigo, da.cantidad_ajuste cantidad, da.precio costo, (nvl(da.cantidad_ajuste,0) * nvl(da.precio,0)) costo_total, aj.observacion explicacion,aj.centro_servicio centro,  nvl(cds.descripcion,'** no tiene area de servicios asignada **') desc_centro, a.cod_barra,decode(aj.estado,'T','TRAM.','R','RECH.','A',decode(da.check_aprov,'S','APROB.','RECH.')) as desc_aprob, aj.cod_ref,(select descripcion||' ( '||decode(ta.sign_tipo_ajuste,'+','DEBITO','CREDITO')||' ) ' from tbl_inv_tipo_ajustes ta where ta.codigo_ajuste=aj.codigo_ajuste  ) as descAjuste ,aj.codigo_ajuste from tbl_inv_detalle_ajustes da , tbl_inv_ajustes aj, tbl_inv_almacen al, tbl_inv_familia_articulo fa , tbl_inv_articulo a,tbl_cds_centro_servicio cds  where (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and (aj.codigo_almacen = al.codigo_almacen and aj.compania = al.compania) and (da.cod_articulo = a.cod_articulo and da.compania = a.compania) and (da.compania= fa.compania and da.cod_familia = fa.cod_flia)  and  aj.centro_servicio = cds.codigo(+)  and aj.compania = "+compania+appendFilter+"  order by aj.codigo_ajuste,al.codigo_almacen asc, al.descripcion asc, fa.cod_flia asc, fa.nombre asc";

al = SQLMgr.getDataList(sql);
sql="select x.* from (select 0 cod_flia,aj.codigo_almacen,  count(*), sum(NVL(da.precio,0) * NVL(da.cantidad_ajuste,0)) total,al.descripcion desc_almacen from tbl_inv_detalle_ajustes da , tbl_inv_ajustes aj, tbl_inv_almacen al, tbl_inv_familia_articulo fa , tbl_inv_articulo a where (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and (aj.codigo_almacen = al.codigo_almacen and aj.compania = al.compania) and ( da.cod_articulo = a.cod_articulo and da.compania = a.compania) and (da.compania= fa.compania and da.cod_familia = fa.cod_flia)  and aj.compania = "+compania+appendFilter+"  group by aj.codigo_almacen,al.descripcion ";

sql +=" union ";

sql += "select fa.cod_flia ,aj.codigo_almacen,count(*),sum(NVL(da.precio,0) * NVL(da.cantidad_ajuste,0)) total,fa.nombre   from tbl_inv_detalle_ajustes da , tbl_inv_ajustes aj, tbl_inv_almacen al, tbl_inv_familia_articulo fa , tbl_inv_articulo a where (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and (aj.codigo_almacen = al.codigo_almacen and aj.compania = al.compania) and (da.cod_articulo = a.cod_articulo and da.compania = a.compania) and (da.compania= fa.compania and da.cod_familia = fa.cod_flia) and aj.compania = "+compania+appendFilter+"  group by fa.cod_flia,aj.codigo_almacen ,fa.nombre  )x order by 2 asc,1 asc";

if(!fg.trim().equals("AJ")) alTotal = SQLMgr.getDataList(sql);




if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+System.currentTimeMillis()+".pdf";

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
	String title = ""+depto;
	String subtitle =""+titulo;
	String xtraSubtitle = ""+((!fDate.trim().equals("")&&!tDate.trim().equals(""))?" DEL  "+fDate+"  AL  "+tDate:" ");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".07");
		dHeader.addElement(".10");        
        dHeader.addElement(".10");
        dHeader.addElement(".13");
		dHeader.addElement(".28");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.addBorderCols("FECHA",1);
		pc.addBorderCols("CODIGO",1);
        pc.addBorderCols("#Ref.",1);
		pc.addBorderCols("COD. BARRA",1);
		pc.addBorderCols("DESC. ARTICULO",1);
		pc.addBorderCols("# AJUSTE",1);
		pc.addBorderCols("AJUSTE U.",1);
		pc.addBorderCols("COSTO",1);
		pc.addBorderCols("TOTAL",1);
		pc.setTableHeader(2);//create de table header

	String groupBy = "",subGroupBy = "",observ ="";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
	double total = 0.00,totalFliaWh = 0.00,totalWh = 0.00;
	boolean tipoAj=true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia")+"-"+cdo.getColValue("codigo_ajuste")))
			{
				if (i != 0)
				{
					pc.setFont(7, 1);
					pc.addCols("Sub Total:  "+CmnMgr.getFormattedDecimal(totalFliaWh),2,dHeader.size());
					totalFliaWh=0.00;
				}
			}
			
			if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("codigo_ajuste")) )
			{
				if (i != 0)
				{
						pc.setFont(7, 1,Color.blue);
						pc.addCols("Total por almacen:  "+CmnMgr.getFormattedDecimal(totalWh),2,dHeader.size());
						pc.addCols("  ",0,dHeader.size());
						totalWh = 0.00;
				}
				
				
				pc.setFont(7, 1,Color.blue);
				pc.addBorderCols("T I P O  A J U S T E : "+cdo.getColValue("descAjuste"),0,dHeader.size());
				
				pc.setFont(7, 1,Color.blue);
				pc.addBorderCols("A L M A C E N : "+cdo.getColValue("codigo_almacen")+"        "+cdo.getColValue("desc_almacen"),0,dHeader.size());
 				if(fg.trim().equals("AJ")) //reporte inv00131.rdf ajustes aprobados al inventario.
				{
					    pc.setFont(7, 1,Color.blue);
 						pc.addBorderCols("A R E A : "+cdo.getColValue("desc_centro"),0,dHeader.size(),cHeight);//0.5f,0.0f,0.0f,0.0f,cHeight);
 				}
			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia")+"-"+cdo.getColValue("codigo_ajuste")))
			{
					pc.setFont(7, 1,Color.red);
					pc.addBorderCols("F A M I L I A : "+cdo.getColValue("cod_flia")+"        "+cdo.getColValue("desc_flia"),0,dHeader.size());
			}




		pc.setFont(7, 0);
			pc.addCols(""+cdo.getColValue("fecha"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("cod_articulo"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("cod_ref"),1,1,cHeight);
			pc.addCols(""+cdo.getColValue("cod_barra"),1,1,cHeight);
			pc.addCols(""+((fg.trim().equals("AJ"))?cdo.getColValue("desc_aprob")+" - ":"")+cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("codigo"),0,1,cHeight);
			pc.addCols(""+cdo.getColValue("cantidad"),1,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo.getColValue("costo")),2,1,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("costo_total")),2,1,cHeight);

		groupBy     = cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("codigo_ajuste");
		subGroupBy  = cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia")+"-"+cdo.getColValue("codigo_ajuste");
		observ      = cdo.getColValue("explicacion");
		
		total       += Double.parseDouble(cdo.getColValue("costo_total"));
		totalWh     += Double.parseDouble(cdo.getColValue("costo_total"));
		totalFliaWh += Double.parseDouble(cdo.getColValue("costo_total"));
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}//for i

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			pc.setFont(7, 1);
			pc.addCols("Sub Total:  "+CmnMgr.getFormattedDecimal(totalFliaWh),2,dHeader.size());
		if(fg.trim().equals("AJ"))
		{
				pc.setFont(7, 1);
				pc.addCols("Observacion: "+observ,0,dHeader.size());
		}
			pc.setFont(7, 1,Color.blue);
			pc.addCols("Total por almacen:  "+CmnMgr.getFormattedDecimal(totalWh),2,dHeader.size());

			pc.setFont(7, 1,Color.blue);
			pc.addCols("Gran Total : "+CmnMgr.getFormattedDecimal(total),2,dHeader.size());
		
		if(!fg.trim().equals("AJ")) //reporte inv00131.rdf ajustes aprobados al inventario.
		{
 			pc.flushTableBody(true);
			//pc.addNewPage();
			pc.addCols("  ",2,dHeader.size());
			pc.addCols("  ",2,dHeader.size());
			pc.setFont(7, 1);
			pc.addCols("TOTALES POR ALMACEN Y TIPO DE AJUSTE",1,dHeader.size());
 
		groupBy="";
		subGroupBy="";
		
		total = 0.00;
		totalWh = 0.00;
		totalFliaWh =0.00;
			for (int i=0; i<alTotal.size(); i++)
			{
			CommonDataObject cdo = (CommonDataObject) alTotal.get(i);

			if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
			{
				if (i != 0)
				{
						pc.setFont(7, 1,Color.blue);
						pc.addCols("",0,1,cHeight);//0.5f,0.0f,0.0f,0.0f,cHeight);
						pc.addCols("TOTAL X ALMACEN:  ",0,2);
						pc.addCols(""+CmnMgr.getFormattedDecimal(totalWh),2,3);
						pc.addCols(" ",0,1);//0.5f,0.0f,0.0f,0.0f,cHeight);
 						pc.setFont(7, 1);
						pc.addCols("  ",0,dHeader.size());
						totalWh =0.00;
						
 				}
				
			}

		if(cdo.getColValue("cod_flia").trim().equals("0"))
		{
					pc.setFont(7, 1,Color.blue);
 					pc.addCols("A L M A C E N : "+cdo.getColValue("codigo_almacen")+"    --    "+cdo.getColValue("desc_almacen"),0,dHeader.size());
 		}
		else if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia")))
		{
					pc.setFont(7, 1);
					pc.addCols(" ",0,1);//0.5f,0.0f,0.0f,0.0f,cHeight);
					pc.addCols(""+cdo.getColValue("desc_almacen"),0,2);//0.5f,0.0f,0.0f,0.0f,cHeight);
					pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,3);
					pc.addCols(" ",0,3);//0.5f,0.0f,0.0f,0.0f,cHeight);
					
					totalWh      += Double.parseDouble(cdo.getColValue("total"));
					total        += Double.parseDouble(cdo.getColValue("total"));
					//totalFliaWh  += Double.parseDouble(cdo.getColValue("total"));
		}
				

		groupBy = cdo.getColValue("codigo_almacen");
		subGroupBy = cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("cod_flia");
		}//for i
		if (alTotal.size() != 0)
		{
						
						pc.setFont(7, 1,Color.blue);
						pc.addCols("",0,1,cHeight);//0.5f,0.0f,0.0f,0.0f,cHeight);
						pc.addCols("TOTAL X ALMACEN :  ",0,2);
						pc.addCols(""+CmnMgr.getFormattedDecimal(totalWh),2,3);
						pc.addCols(" ",0,1);//0.5f,0.0f,0.0f,0.0f,cHeight);
 						pc.setFont(7, 1);
						pc.addCols("  ",0,dHeader.size());
						totalWh =0.00;
						
						pc.setFont(7, 1,Color.blue);
						pc.addCols("",0,1,cHeight);//0.5f,0.0f,0.0f,0.0f,cHeight);
						pc.addCols("GRAN TOTAL:  ",0,2);
						pc.addCols(""+CmnMgr.getFormattedDecimal(total),2,3,cHeight);
						pc.addCols("",0,3,cHeight);//0.5f,0.0f,0.0f,0.0f,cHeight);
			}
		  }//if fg != AJ
		}
	
pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>