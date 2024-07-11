<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"	%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="OCDet" scope="session" class="issi.compras.OrdenCompra" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String appendFilter1 = "";
String appendFilter2 = "";
String userName = UserDet.getUserName();

String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String filterProveedor = request.getParameter("filterProveedor");
String art_familia = request.getParameter("art_familia");
String art_clase = request.getParameter("art_clase");
String cod_articulo = request.getParameter("cod_articulo");
String descripcion = request.getParameter("descripcion");
String almacen = request.getParameter("almacen");
String proveedor = request.getParameter("proveedor");
String proveedor_desc = request.getParameter("proveedor_desc");

/*if(request.getParameter("art_familia")!=null) art_familia = request.getParameter("art_familia");
if(request.getParameter("art_clase")!=null) art_clase = request.getParameter("art_clase");
if(request.getParameter("cod_articulo")!=null) cod_articulo = request.getParameter("cod_articulo");
if(request.getParameter("descripcion")!=null) descripcion = request.getParameter("descripcion");
if(request.getParameter("almacen")!=null) almacen = request.getParameter("almacen");
if(request.getParameter("proveedor")!=null) proveedor = request.getParameter("proveedor");
if(request.getParameter("proveedor_desc")!=null) proveedor_desc = request.getParameter("proveedor_desc");*/

String compania = (String) session.getAttribute("_companyId");

    if (!art_familia.equals("")) appendFilter += " and i.art_familia = "+art_familia;
	if (!art_clase.equals("")) appendFilter += " and i.art_clase = "+art_clase;
	if (!cod_articulo.equals("")) appendFilter += " and i.cod_articulo = "+cod_articulo;
	if (!descripcion.equals("")) appendFilter += " and a.descripcion like '%"+descripcion.toUpperCase()+"%'";
	if (!almacen.equals("")) appendFilter += " and i.codigo_almacen = "+almacen;
	if (!proveedor.equals("")) appendFilter += " and ap.cod_provedor = "+proveedor;

sql = "select all 'CS' art_origen, to_char(r.requi_anio) requi_anio, to_char(r.requi_numero) requi_numero, dr.cod_familia cod_flia, dr.cod_clase, a.cod_subclase, dr.cod_articulo, a.descripcion articulo, a.cod_medida, dr.cantidad cantidad, a.itbm, dr.precio_cotizado, dr.especificacion, nvl(getCantArtTramite(r.compania, r.codigo_almacen, a.cod_articulo), 0) cant_tramite, p.nombre_proveedor, p.cod_provedor, ap.precio_articulo, i.disponible cantidad_disponible, al.descripcion almacen_desc from tbl_inv_detalle_req dr, tbl_inv_arti_prov ap, tbl_inv_articulo a, tbl_inv_requisicion r, tbl_com_proveedor p, tbl_inv_inventario i, tbl_inv_almacen al where r.activa = 'S' AND r.estado_requi = 'A' and dr.compania = ap.compania and dr.cod_familia  = ap.art_familia and dr.cod_clase = ap.art_clase and dr.cod_articulo = ap.cod_articulo and ap.compania = a.compania and ap.art_familia = a.cod_flia and ap.art_clase = a.cod_clase and ap.cod_articulo = a.cod_articulo and ap.cod_articulo = a.cod_articulo AND dr.compania = r.compania AND dr.requi_numero = r.requi_numero AND dr.requi_anio = r.requi_anio AND estado_renglon  = 'P'" + appendFilter+" and ap.cod_provedor = p.cod_provedor and ap.tipo_proveedor = 1 and not exists (select 1 from tbl_com_comp_formales z where r.requi_anio = z.requi_anio and r.requi_numero = z.requi_numero) and dr.compania = i.compania and dr.cod_articulo = i.cod_articulo and i.compania = al.compania and i.codigo_almacen = al.codigo_almacen union select 'PR' art_origen, '' requi_anio, '' requi_numero, i.art_familia, i.art_clase, a.cod_subclase, i.cod_articulo, a.descripcion, a.cod_medida, 0 cantidad, a.itbm, 0.precio_cotizado, ' ' especificacion, nvl(getCantArtTramite(i.compania, i.codigo_almacen, i.cod_articulo), 0) cant_tramite, p.nombre_proveedor, p.cod_provedor, ap.precio_articulo, i.disponible cantidad_disponible, al.descripcion almacen_desc from tbl_inv_inventario i, tbl_inv_articulo a,tbl_inv_arti_prov ap, tbl_com_proveedor p, tbl_inv_almacen al where i.compania = "+compania+" and i.cod_articulo = a.cod_articulo and (ap.compania = a.compania and ap.cod_articulo = a.cod_articulo) and i.disponible  < i.pto_reorden  "+appendFilter+" and ap.cod_provedor = p.cod_provedor and ap.tipo_proveedor = 1 and i.compania = al.compania and i.codigo_almacen = al.codigo_almacen";

al = SQLMgr.getDataList(sql);// where rn between "+previousVal+" and "+nextVal);

if (request.getMethod().equalsIgnoreCase("GET"))
{

	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

	if(mon.equals("01")) month = "Enero";
	else if(mon.equals("02")) month = "Febrero";
	else if(mon.equals("03")) month = "Marzo";
	else if(mon.equals("04")) month = "Abril";
	else if(mon.equals("05")) month = "Mayo";
	else if(mon.equals("06")) month = "Junio";
	else if(mon.equals("07")) month = "Julio";
	else if(mon.equals("08")) month = "Agosto";
	else if(mon.equals("09")) month = "Septiembre";
	else if(mon.equals("10")) month = "Octubre";
	else if(mon.equals("11")) month = "Noviembre";
	else month = "Diciembre";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f; //612
	float height = 72 * 11f; //792
	boolean isLandscape = false;
	float leftRightMargin = 10.0f;
	float topMargin = 13.5f;
	float bottomMargin = 13.5f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "MATERIALES";
	String subTitle = "REQUISICION";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 50;
	float cHeight = 11.0f;

	int maxLines = 40; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size() + 5;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

		Vector dHeader = new Vector();

		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	 int pCounter = 1;

      pdfHeader(pc, _comp, pCounter, nPages, ""+title, " "+subTitle, userName, fecha);

	  pc.setNoColumnFixWidth(dHeader);
	  pc.createTable();

	  pc.setVAlignment(1);

	    pc.setFont(9, 0);

        pc.addCols("",0,dHeader.size(),15f);

        if(al.size() >= 1){

		String flg = "S", codProvedor = "", solNo = "";
		int tot = 1;

		   for (int i=0; i<al.size(); i++){
	          CommonDataObject cdo = (CommonDataObject) al.get(i);

			  if(cdo.getColValue("art_origen")!=null && cdo.getColValue("art_origen").equals("PR")){
				  if(flg.equals("S")){
					  pc.setFont(9,1,Color.white);
					  pc.addCols("Artículos bajo punto de reorden",0,dHeader.size(),Color.gray);
					   //pc.addCols("",0,dHeader.size(),5f);
					  flg = "N";
				  }
			  }


			  pc.setFont(9, 1);

			  if (!cdo.getColValue("cod_provedor").equals(codProvedor)){
			       pc.addCols("Suplidor :       "+cdo.getColValue("cod_provedor")+"       "+cdo.getColValue("nombre_proveedor"),0,dHeader.size());
			      pc.addCols("",0,dHeader.size(),5f);
			  }else{
				  tot = tot + 1;
			  }


			if (!solNo.equals(cdo.getColValue("requi_numero")) && flg.equals("S")){
			    pc.setFont(9, 0);
			    pc.addBorderCols("Artículos",0,4);
			    pc.addBorderCols("Cant. Tramite",0,2);
			    pc.addBorderCols("Unidad Req.",0,2);
			    pc.addBorderCols("Cant. Disponible",0,1);
				pc.addBorderCols("Precio",0,1);
				pc.addCols("",0,dHeader.size(),5f);
			}


			 pc.setFont(7, 0);
			 pc.addCols(cdo.getColValue("cod_articulo")+"       "+cdo.getColValue("articulo"),0,4);
			 pc.addCols(cdo.getColValue("cant_tramite"),0,2);
			 pc.addCols(cdo.getColValue("cod_medida"),0,2);
			 pc.addCols(cdo.getColValue("cantidad_disponible"),0,1);
			 pc.addCols(cdo.getColValue("precio_articulo"),0,1);
			 pc.addCols("",0,dHeader.size(),5f);


			 codProvedor =  cdo.getColValue("cod_provedor");
		     solNo = cdo.getColValue("requi_numero");
			 if ((i+1) == al.size()){
			   pc.setFont(9, 1);
			   pc.addCols("                                     Total Articulos por Suplidor: "+tot,0,dHeader.size());
			  // pc.addCols(""+tot,0,7);

			}

		   } //end for
		}//end if
		else{
			pc.setFont(9,1);
			pc.addCols(".::: No hay registros! :::.",1,dHeader.size());
		}


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>
