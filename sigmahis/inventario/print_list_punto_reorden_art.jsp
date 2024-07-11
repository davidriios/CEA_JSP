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
===============         REPORTE CHSF :  INV0034.RDF     ==========================
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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String consignacion = request.getParameter("consignacion");
String almacen = request.getParameter("almacen");
String banco = request.getParameter("banco");
String comparacion = request.getParameter("comparacion");
String comparacionLimite = request.getParameter("comparacion_limite");
String excluirZero = request.getParameter("excluir_zero");
String comparacionText = request.getParameter("comparacion_text");
String fDocDesde = request.getParameter("f_doc_desde");
String fDocHasta = request.getParameter("f_doc_hasta");

if(consignacion== null) consignacion = "N";
if(almacen== null) almacen = "";
if (appendFilter == null) appendFilter = "";
if(banco== null) banco = "";
if(comparacion== null) comparacion = "";
if(comparacionLimite== null) comparacionLimite = "";
if(excluirZero== null) excluirZero = "";
if(comparacionText== null) comparacionText = "";
if(fDocDesde== null) fDocDesde = "";
if(fDocHasta== null) fDocHasta = "";


    sbSql.append("select a.* from (select a.cod_flia cod_familia, a.cod_clase cod_clase ,i.cod_articulo, nvl(a.descripcion,' ') desArticulo, a.cod_flia||'-'||a.cod_clase||'-'||i.cod_articulo as articulo,al.descripcion descAlmacen,i.codigo_almacen, nvl(i.disponible,0) disponible, nvl(i.pto_reorden,0)pto_reorden, nvl(i.pto_max_existencia,0)pto_max_existencia, nvl(i.ultimo_precio,0) ultimo_precio, a.cod_medida as med_art, to_char(i.ultima_compra,'dd/mm/yyyy')ultimo_compra, nvl(i.precio,0)precio, nvl(i.codigo_anaquel,0) codigo_anaquel, nvl(i.descuento,0)descuento, nvl(i.porcentaje,0)porcentaje, nvl(i.costo_por_almacen,0)costo_x_almacen, (select  c.descripcion from tbl_inv_clase_articulo c where c.compania =a.compania and c.cod_flia=a.cod_flia and c.cod_clase=a.cod_clase ) as descClase, nvl(i.saldo_activo,0)saldo_activo, nvl(i.reservado,0)reservado, nvl(i.transito,0)transito, nvl(i.disp_ant_pamd,0)disp_ant_pamd, nvl(i.rebajado,' ')rebajado, (select max(rmf.fecha_documento)  from tbl_com_proveedor prf, tbl_inv_inventario tif,tbl_inv_recepcion_material rmf, tbl_inv_detalle_recepcion drf where drf.compania = rmf.compania and drf.numero_documento = rmf.numero_documento and drf.anio_recepcion = rmf.anio_recepcion and drf.cod_articulo = tif.cod_articulo and rmf.cod_proveedor = prf.cod_provedor and tif.compania = i.compania and tif.codigo_almacen = i.codigo_almacen and tif.cod_articulo = i.cod_articulo) as fecha,(select max(pr.nombre_proveedor)  from tbl_com_proveedor pr, tbl_inv_inventario ti,tbl_inv_recepcion_material rm, tbl_inv_detalle_recepcion dr where dr.compania = rm.compania and dr.numero_documento = rm.numero_documento and dr.anio_recepcion = rm.anio_recepcion and dr.cod_articulo = ti.cod_articulo and rm.cod_proveedor = pr.cod_provedor and ti.compania = i.compania and ti.codigo_almacen = i.codigo_almacen and ti.cod_articulo = i.cod_articulo and rm.fecha_documento = (select max(rmf.fecha_documento)  from tbl_com_proveedor prf, tbl_inv_inventario tif,tbl_inv_recepcion_material rmf, tbl_inv_detalle_recepcion drf where drf.compania = rmf.compania and drf.numero_documento = rmf.numero_documento and drf.anio_recepcion = rmf.anio_recepcion and drf.cod_articulo = tif.cod_articulo and rmf.cod_proveedor = prf.cod_provedor and tif.compania = i.compania and tif.codigo_almacen = i.codigo_almacen and tif.cod_articulo = i.cod_articulo)) as nombre, nvl(getcantarttramite(i.compania, i.codigo_almacen, i.cod_articulo), 0) cant_tramite from tbl_inv_inventario i,tbl_inv_articulo a,tbl_inv_almacen al where i.cod_articulo = a.cod_articulo and i.compania = a.compania and i.COMPANIA = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and i.codigo_almacen = al.codigo_almacen and i.compania = al.compania /*and i.disponible < i.pto_reorden*/ ");
	sbSql.append(appendFilter);
	if(!consignacion.trim().equals("")){sbSql.append(" and a.consignacion_sino ='"); sbSql.append(consignacion);sbSql.append("'");}
	if(!almacen.trim().equals("")){sbSql.append(" and al.codigo_almacen="); sbSql.append(almacen);} 
	if(banco.trim().equals("S")){sbSql.append(" and exists (select 1 from  tbl_inv_articulo_bm bm where bm.compania =a.compania and bm.cod_articulo =a.cod_articulo)  ");} 
    
    if (comparacion.equals("1")){
       sbSql.append(" and i.pto_reorden = i.disponible ");
    }else  if (comparacion.equals("2")){
       sbSql.append(" and i.pto_reorden < i.disponible ");
       if (!comparacionLimite.trim().equals("")) {
          sbSql.append(" and i.disponible < ");
          sbSql.append(comparacionLimite);
       }
    }else  if (comparacion.equals("3")){
       sbSql.append(" and i.pto_reorden > i.disponible ");
       if (!comparacionLimite.trim().equals("")) {
          sbSql.append(" and i.disponible > ");
          sbSql.append(comparacionLimite);
       }
    }
    
    if (excluirZero.equalsIgnoreCase("true")){
       sbSql.append(" and i.pto_reorden > 0 and i.pto_max_existencia > 0");
    }
    
	sbSql.append(" )a ");
	
	if (!fDocDesde.equals("") && !fDocHasta.equals("")) {
    sbSql.append(" where trunc(a.fecha) between to_date('");
    sbSql.append(fDocDesde);
    sbSql.append("', 'dd/mm/yyyy') and to_date('");
    sbSql.append(fDocHasta);
    sbSql.append("', 'dd/mm/yyyy')");
	}
	
	
	sbSql.append(" order by a.codigo_almacen, a.cod_familia, a.cod_clase, a.cod_articulo asc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	float leftRightMargin = 0f;
	float topMargin = 0f;
	float bottomMargin = 0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "PUNTO DE REORDEN";
	String xtraSubtitle = "AL "+cDateTime.substring(0,10);
    
    if (!comparacion.equals("")){
      xtraSubtitle += "\n"+comparacionText.toUpperCase();
      if (!comparacionLimite.equals("")) xtraSubtitle += " (RANGO: "+comparacionLimite+")";
    }
    if (excluirZero.equals("true")){
      xtraSubtitle += "\nEXCLUYIENDO LOS ITEMS SIN MÍNIMO O MÁXIMO";
    }
    
    if (!fDocDesde.equals("") && !fDocHasta.equals("")) {
      xtraSubtitle += "\nFecha doc desde: "+fDocDesde+"      hasta: "+fDocHasta;
    }
    
    System.out.println(":::::::::::::::::::::::::::::::::::::::::: "+comparacion);
    
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	    dHeader.addElement(".10");
		dHeader.addElement(".28");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".28");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(8, 1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("DESCRIPCION",1);
		pc.addBorderCols("UNIDAD",1);
		pc.addBorderCols("DISP.",1);
		pc.addBorderCols("MINIMO",1);
		pc.addBorderCols("TRAMITE",1);
		pc.addBorderCols("PROVEEDOR",1);
		pc.setTableHeader(2);

	String groupBy = "";
	int lCounter = 0;
	int pCounter = 1;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("descAlmacen")))
		{
			if (i != 0)
			{
					pc.setFont(8, 1,Color.blue);
					pc.addCols("",0,dHeader.size());
			}
				pc.setFont(8, 1,Color.blue);
				pc.addCols("[ DEPOSITO : "+cdo.getColValue("codigo_almacen")+" ] "+cdo.getColValue("descAlmacen"),0,dHeader.size());
		}

		pc.setFont(8, 0);
			pc.addCols(""+cdo.getColValue("articulo"),1,1);
			pc.addCols(""+cdo.getColValue("desArticulo"),0,1);
			pc.addCols(""+cdo.getColValue("med_art"),1,1);
			pc.addCols(""+cdo.getColValue("disponible"),1,1);
			pc.addCols(""+cdo.getColValue("pto_reorden"),1,1);
			pc.addCols(""+cdo.getColValue("cant_tramite"),1,1);
			pc.addCols(""+cdo.getColValue("nombre"),0,1);
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("descAlmacen");
	}//for i

	if (al.size() == 0)pc.addCols("No existen registros",1,dHeader.size());
	else
	{
			pc.setFont(8, 1,Color.blue);
			pc.addCols("",0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>