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
String userName = UserDet.getUserName();

String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anioEntrega = request.getParameter("anioEntrega");
String anioReq = request.getParameter("anioReq");
String noReq = request.getParameter("noReq");
String noEntrega = request.getParameter("noEntrega");
String articulo = request.getParameter("articulo");

String titulo = request.getParameter("titulo");
String descDepto = request.getParameter("descDepto");
String fg = request.getParameter("fg");

if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(depto== null) depto = "";
if(anioEntrega== null) anioEntrega = "";
if(anioReq== null) anioReq = "";
if(noReq== null) noReq = "";
if(noEntrega== null) noEntrega = "";
if(articulo== null) articulo = "";
if(titulo== null) titulo = "";
if(descDepto== null) descDepto = "";

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if(!almacen.trim().equals(""))         appendFilter  = " and em.codigo_almacen = "+almacen;
if(!depto.trim().equals(""))           appendFilter  += " and sr.codigo_almacen = "+depto;

sql="select em.codigo_almacen cod_almacen, al.descripcion desc_almacen, em.anio||' '||lpad(em.no_entrega, 6, '0') no_entrega, (de.cod_familia||'-'||de.cod_clase||'-'||de.cod_articulo ) cod_articulo, a.descripcion desc_articulo, de.cantidad entregado, nvl(de.precio,0)*nvl(de.cantidad,0) monto, nvl(observaciones,' ') observacion, em.req_anio||em.req_tipo_solicitud||em.req_solicitud_no no_requisicion, sr.codigo_almacen cod_almacen_sol, al1.descripcion desc_almacen_sol, nvl(i.disponible,0) disponible,nvl(em.observaciones,'') observaciones, a.cod_medida, um.descripcion unidad_medida_desc, nvl(de.costo, 0) costo from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_almacen al, tbl_inv_solicitud_req sr, tbl_inv_almacen al1, tbl_inv_inventario i, tbl_inv_articulo a, tbl_inv_unidad_medida um where em.compania = "+session.getAttribute("_companyId")+" and (em.codigo_almacen = nvl ('"+almacen+"',  em.codigo_almacen) and sr.tipo_transferencia = 'A' and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date(nvl('"+fDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and to_date(nvl('"+tDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and de.anio = nvl ( '"+anioEntrega+"',em.anio) and de.no_entrega = nvl ('"+noEntrega+"', em.no_entrega) ) and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = a.cod_flia and de.cod_clase = a.cod_clase and de.cod_articulo = a.cod_articulo and de.compania = a.compania) and (i.codigo_almacen = em.codigo_almacen and i.cod_articulo = de.cod_articulo and i.art_familia = de.cod_familia and i.art_clase = de.cod_clase and i.compania = de.compania) and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio and (em.compania = al.compania and em.codigo_almacen = al.codigo_almacen) and (sr.compania_sol = al.compania and sr.codigo_almacen_ent = al.codigo_almacen) and (sr.codigo_almacen = al1.codigo_almacen) and (sr.compania = al1.compania) and a.cod_medida = um.cod_medida "+appendFilter+"  order by em.codigo_almacen asc,em.anio||' '||lpad(em.no_entrega, 6, '0')  asc ";

al = SQLMgr.getDataList(sql);
StringBuffer sbSql = new StringBuffer();
sbSql.append("select sum(monto) monto, sum(entregado) cantidad, count(distinct no_requisicion) cant_requisicion from (");
sbSql.append(sql);
sbSql.append(")");

CommonDataObject cdoT = SQLMgr.getData(sbSql);
sql="select count(*)*3 nLine, sum(monto) monto,cod_almacen from ( select em.codigo_almacen cod_almacen, al.descripcion almacenes, em.anio||' '||lpad(em.no_entrega, 6, '0') no_entrega , sum(nvl(de.precio,0)*nvl(de.cantidad,0)) monto from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_almacen al, tbl_inv_solicitud_req sr, tbl_inv_almacen al1, tbl_inv_inventario i, tbl_inv_articulo a where (em.codigo_almacen = nvl ('"+almacen+"',  em.codigo_almacen) and sr.tipo_transferencia = 'A' and to_date(to_char(em.fecha_entrega,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date(nvl('"+fDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and to_date(nvl('"+tDate+"',to_char(em.fecha_entrega,'dd/mm/yyyy')),'dd/mm/yyyy') and de.anio = nvl ( '"+anioEntrega+"',em.anio) and de.no_entrega = nvl ('"+noEntrega+"', em.no_entrega) ) and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_familia = a.cod_flia and de.cod_clase = a.cod_clase and de.cod_articulo = a.cod_articulo and de.compania = a.compania) and (i.codigo_almacen = em.codigo_almacen and i.cod_articulo = de.cod_articulo and i.art_familia = de.cod_familia and i.art_clase = de.cod_clase and i.compania = de.compania) and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio and (em.compania = al.compania and em.codigo_almacen = al.codigo_almacen) and (sr.compania_sol = al.compania and sr.codigo_almacen_ent = al.codigo_almacen) and (sr.codigo_almacen = al1.codigo_almacen) and (sr.compania = al1.compania) "+appendFilter+" group by em.codigo_almacen, al.descripcion, em.anio||' '||lpad(em.no_entrega, 6, '0')  ) group by cod_almacen ";

//alTotal = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{

/*--------------------------------------------------------------------------------------------*/
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
	String title = "INVENTARIO";
	String subtitle =  " "+descDepto;
	String xtraSubtitle = ""+titulo+"    DESDE    "+fDate+"    HASTA    "+tDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
    //float cHeight = 12.0f;


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		if(fg.equals("EA")){
			dHeader.addElement(".10");
			dHeader.addElement(".50");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
		} else {
			dHeader.addElement(".10");
			dHeader.addElement(".60");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
		}

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	//second row
	//pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String groupBy = "",subGroupBy = "",observ ="";
/*--------------------------------------------------------------------------------------------*/

	int nLine = 0;
	double total = 0.00,totalWh =0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")))
		{
			if (i != 0)
			{
			  if  (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_entrega")))
				{
				  pc.setFont(7, 1);
				//pc.addCols("Total x Familia  ",2,2);
				//pc.addCols(" "+CmnMgr.getFormattedDecimal((String) htFamily.get(subGroupBy)),2,2);
				}

			  pc.setFont(9, 1,Color.blue);
			  pc.addCols("Sub Total: $ ",2,3);
			  pc.addCols(" "+CmnMgr.getFormattedDecimal(totalWh),2,(fg.equals("EA")?3:2));
			  totalWh=0.00;
			  pc.flushTableBody(true);
			  pc.deleteRows(-2);

			  //agrega el almacen al encabezado en memoria
				pc.setFont(9, 1,Color.blue);
			    pc.addCols(" "+cdo.getColValue("desc_almacen"),1,dHeader.size());

				//agrega la familia al encabezado en memoria
				pc.setFont(9, 1,Color.red);
				pc.addCols(" "+cdo.getColValue("cod_almacen_sol"),1,1);
				pc.addCols(" "+cdo.getColValue("desc_almacen_sol"),0,(fg.equals("EA")?5:4));

				pc.setFont(9, 1,Color.blue);
				pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);
				pc.addCols("Entrega No :",2,1);
				pc.addCols(""+cdo.getColValue("no_entrega"),0,(fg.equals("EA")?3:2));

			}
			    pc.setFont(7, 1);
				pc.addBorderCols("CÓDIGO",1);
				pc.addBorderCols("DESC. ARTÍCULO",0);
				pc.addBorderCols("UNIDAD MED.",1);
				pc.addBorderCols("SOLICITADO",1);
				pc.addBorderCols("MONTO",1);
				if(fg.equals("EA")){
				pc.addBorderCols("COSTO",1);
				}
				
				pc.setTableHeader(4);

				pc.setFont(9, 1,Color.blue);
			    pc.addCols(" "+cdo.getColValue("desc_almacen"),1,dHeader.size());

				pc.setFont(9, 1,Color.red);
				pc.addCols(" "+cdo.getColValue("cod_almacen_sol"),1,1);
				pc.addCols(" "+cdo.getColValue("desc_almacen_sol"),0,(fg.equals("EA")?5:4));

			 if  (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_entrega")))
				{
					pc.setFont(9, 1,Color.blue);
					pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);
					pc.addCols("Entrega No :",2,1);
					pc.addCols(""+cdo.getColValue("no_entrega"),0,(fg.equals("EA")?3:2));
					pc.addCols("OBSERVACIONES  #   : "+cdo.getColValue("observaciones"),0,dHeader.size());
				}

			}else if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_entrega")))
			 {
			   pc.flushTableBody(true);
			   pc.deleteRows(-1);

				pc.setFont(9, 1,Color.blue);
				pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);
				pc.addCols("Entrega No :",2,1);
				pc.addCols(""+cdo.getColValue("no_entrega"),0,(fg.equals("EA")?3:2));

				pc.setFont(9, 1,Color.red);
				pc.addCols(" "+cdo.getColValue("cod_almacen_sol"),1,1);
				pc.addCols(" "+cdo.getColValue("desc_almacen_sol"),0,(fg.equals("EA")?5:4));

				pc.setFont(9, 1,Color.blue);
				pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);
				pc.addCols("Entrega No :",2,1);
				pc.addCols(""+cdo.getColValue("no_entrega"),0,(fg.equals("EA")?3:2));

				pc.addCols("OBSERVACIONES  #   : "+cdo.getColValue("observaciones"),0,dHeader.size());

				pc.setFont(7, 1);
				pc.addBorderCols("CÓDIGO",1);
				pc.addBorderCols("DESC. ARTÍCULO",0);
				pc.addBorderCols("UNIDAD MED.",1);
				pc.addBorderCols("SOLICITADO",1);
				pc.addBorderCols("MONTO",1);
				if(fg.equals("EA")){
					pc.addBorderCols("COSTO",1);
				}
			  }

		pc.setVAlignment(0);
		pc.setFont(9, 0);
		pc.addCols(""+cdo.getColValue("cod_articulo"),0,1);
		pc.addCols(""+cdo.getColValue("desc_articulo"),0,1);
		pc.addCols(""+cdo.getColValue("unidad_medida_desc"),1,1);
		pc.addCols(""+cdo.getColValue("entregado"),1,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		if(fg.equals("EA")){
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("costo")),2,1);
		}
		totalWh += Double.parseDouble(cdo.getColValue("monto"));
		total   += Double.parseDouble(cdo.getColValue("monto"));
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		groupBy    = cdo.getColValue("cod_almacen");
		subGroupBy = cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("no_entrega");
	}//for i

	if (al.size() == 0)
	 {
	   pc.addCols("No existen registros",1,dHeader.size());
	  }else{
		pc.setFont(7, 1,Color.blue);
		pc.addCols("Sub Total: $ ",2,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totalWh),2,2);
		if(fg.equals("EA")) pc.addCols(" ",2,1);
		pc.addCols("T O T A L: $ ",2,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(""+total),2,2);
		if(fg.equals("EA")) pc.addCols(" ",2,1);

		pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
		pc.setFont(8, 1,Color.blue);
		pc.addCols("Total Requisiciones",2,dHeader.size()-1);
		pc.addCols(""+cdoT.getColValue("cant_requisicion"),2,1);
		pc.addCols("Total Articulos",2,dHeader.size()-1);
		pc.addCols(""+cdoT.getColValue("cantidad"),2,1);
		pc.addCols("Total Monto",2,dHeader.size()-1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("monto")),2,1);
		
		
	  }

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);

}//get
%>
