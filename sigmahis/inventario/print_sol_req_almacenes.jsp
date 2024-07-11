<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
ArrayList alTotal = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String codCat = request.getParameter("codCat");
String fp = request.getParameter("fp");
String almacen = request.getParameter("almacen");
String almacen_dev = request.getParameter("almacen_dev");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String anio = request.getParameter("anio");
String cod_req = request.getParameter("cod_req");
String estado = request.getParameter("estado");
String tipo = request.getParameter("tipo");
String print_individual = request.getParameter("print_individual");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

if (appendFilter == null) appendFilter = "";
sbFilter.append(appendFilter);

if(almacen== null) almacen = "";
if(estado== null) estado = "";
if(anio== null) anio = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(cod_req== null) cod_req = "";
if(almacen_dev== null) almacen_dev = "";
if(tipo== null) tipo = "";
if(print_individual== null) print_individual = "N";
if(fp== null) fp = "";

if (!almacen.trim().equals("")) { sbFilter.append(" and sr.codigo_almacen = "); sbFilter.append(almacen); }
if (!almacen_dev.trim().equals("")) { sbFilter.append(" and sr.codigo_almacen_ent = "); sbFilter.append(almacen_dev); }
if (!estado.trim().equals("")) { sbFilter.append(" and sr.estado_solicitud  = '"); sbFilter.append(estado); sbFilter.append("'"); }
if (!anio.trim().equals("")) { sbFilter.append(" and sr.anio = "); sbFilter.append(anio); }
if (!cod_req.trim().equals("")) { sbFilter.append(" and sr.solicitud_no = "); sbFilter.append(cod_req); }
if (!tipo.trim().equals("")) { sbFilter.append(" and sr.tipo_solicitud = '"); sbFilter.append(tipo); sbFilter.append("'"); }
if (!fDate.trim().equals("") && !tDate.trim().equals("")) { sbFilter.append(" and trunc(sr.fecha_documento) between to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy') and to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
if (fp.trim().equals("EA")) { sbFilter.append(" and sr.tipo_transferencia = 'A'"); }
CommonDataObject cd = new CommonDataObject();
if(print_individual.equals("S")){
sbSql.append("select sr.anio||'-'||sr.solicitud_no||'-'||sr.tipo_solicitud as codigo, nvl(sr.observacion,' ') as observacion, decode(sr.estado_solicitud,'A','APROBADO','P','PENDIENTE','N','ANULADO','R','RECHAZADO','T','TRAMITE','E','ENTREGADO',sr.estado_solicitud) as estado");
sbSql.append(", (select descripcion from tbl_inv_almacen where compania = sr.compania_sol and codigo_almacen = sr.codigo_almacen_ent) as almacen_sol");
sbSql.append(", (select descripcion from tbl_inv_almacen where compania = sr.compania and codigo_almacen = sr.codigo_almacen) as almacen_dest");
sbSql.append(", (select descripcion from tbl_sec_unidad_ejec where codigo = sr.unidad_administrativa and compania = sr.compania) as unidad_adm_desc");
sbSql.append(", sr.usuario_creacion,nvl(to_char(sr.fecha_creacion,'dd/mm/yyyy hh12:mi am'),' ') as fecha_docto");
sbSql.append(" from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds");
sbSql.append(" where sr.compania = ");
sbSql.append(compania);
sbSql.append(sbFilter);
cd = SQLMgr.getData(sbSql.toString());
}

sbSql = new StringBuffer();

sbSql.append("select sr.anio||'-'||sr.solicitud_no||'-'||sr.tipo_solicitud as codigo, ds.art_familia||'-'||ds.art_clase||'-'||ds.cod_articulo as cod_articulo, nvl(ds.cantidad,0) as pedido, nvl(ds.despachado,0) as recibido, decode(ds.estado_renglon,'R',(nvl(ds.cantidad,0) - nvl(ds.despachado,0)),0) as rechazado,decode(ds.estado_renglon,'R',0,nvl(ds.cantidad,0) - nvl(ds.despachado,0)) as pendiente, nvl(sr.observacion,' ') as observacion, decode(sr.estado_solicitud,'A','APROBADO','P','PENDIENTE','N','ANULADO','R','RECHAZADO','T','TRAMITE','E','ENTREGADO',sr.estado_solicitud) as estado");
sbSql.append(", (select descripcion from tbl_inv_almacen where compania = sr.compania_sol and codigo_almacen = sr.codigo_almacen_ent) as almacen_sol");
sbSql.append(", (select descripcion from tbl_inv_almacen where compania = sr.compania and codigo_almacen = sr.codigo_almacen) as almacen_dest");
sbSql.append(", (select descripcion from tbl_sec_unidad_ejec where codigo = sr.unidad_administrativa and compania = sr.compania) as unidad_adm_desc");
sbSql.append(", (select descripcion from tbl_inv_articulo where compania = ds.compania_sol and cod_articulo = ds.cod_articulo) as desc_articulo");
sbSql.append(", (select cod_barra from tbl_inv_articulo where compania = ds.compania_sol and cod_articulo = ds.cod_articulo) as cod_barra");
sbSql.append(", (select (select descripcion from tbl_inv_unidad_medida where cod_medida = z.cod_medida) from tbl_inv_articulo z where compania = ds.compania_sol and cod_articulo = ds.cod_articulo) as unidad_medida_desc");
sbSql.append(", (select disponible from tbl_inv_inventario where compania = ds.compania_sol and cod_articulo = ds.cod_articulo and codigo_almacen = sr.codigo_almacen_ent) as disponible, sr.usuario_creacion,nvl(to_char(sr.fecha_creacion,'dd/mm/yyyy hh12:mi am'),' ') as fecha_docto");
sbSql.append(" from tbl_inv_solicitud_req sr, tbl_inv_d_sol_req ds");
sbSql.append(" where sr.compania = ");
sbSql.append(compania);
sbSql.append(sbFilter);
sbSql.append("/* and sr.tipo_transferencia = 'A' and sr.activa = 'S' and ds.estado_renglon = 'P'*/ and (ds.compania = sr.compania and ds.solicitud_no = sr.solicitud_no and ds.tipo_solicitud = sr.tipo_solicitud and ds.req_anio = sr.anio)");
sbSql.append(" order by sr.anio, sr.solicitud_no, sr.codigo_almacen_ent, sr.codigo_almacen");
al = SQLMgr.getDataList(sbSql.toString());

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
	String title = "SOLICITUD DE TRANSFERENCIA ENTRE ALMACENES";
	String subtitle = "";
	String xtraSubtitle = " ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

Vector setDetailEnc = new Vector();
		setDetailEnc.addElement(".50");
		setDetailEnc.addElement(".50");



	Vector setDetail = new Vector();
		setDetail.addElement(".03");
		setDetail.addElement(".09");
		setDetail.addElement(".11");
		setDetail.addElement(".28");
		setDetail.addElement(".09");
		setDetail.addElement(".08");
		setDetail.addElement(".07");
		setDetail.addElement(".08");
		setDetail.addElement(".09");
		setDetail.addElement(".08");
	String groupBy = "";
	float cHeight = 12.0f;

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setDetail.size());

	//pdfHeader(pc, _comp, pCounter, nPages, " "+title, "AL "+cDateTime.substring(0,10), userName, fecha);

	if(print_individual.equals("S")){ 
		pc.setFont(8, 1,Color.blue);
		pc.addCols(" SOLICITADO POR: "+cd.getColValue("almacen_dest"),0,5,cHeight);
		pc.addCols(" ENTREGADO POR: "+cd.getColValue("almacen_sol"),0,5,cHeight);

		pc.addCols(" SOLICITUD #"+cd.getColValue("codigo"),0,5,cHeight);
		pc.addCols(" ESTADO: "+cd.getColValue("estado"),0,5,cHeight);
		
		pc.addCols(" CREADO POR: "+cd.getColValue("usuario_creacion"),0,5,cHeight);
		pc.addCols(" FECHA DOC: "+cd.getColValue("fecha_docto"),0,5,cHeight);

		pc.setFont(6, 0,Color.blue);
		pc.setVAlignment(0);
		pc.addCols("OBSERVACION: "+cd.getColValue("observacion"),0,setDetail.size(),24);
		pc.setFont(7, 1);
		pc.addBorderCols("#",0);
		pc.addBorderCols("CODIGO",0);
		pc.addBorderCols("C.BARRA",1);
		pc.addBorderCols("ARTICULO",1);
		pc.addBorderCols("UNIDAD MED.",1);
		pc.addBorderCols("EXISTENCIA",1);
		pc.addBorderCols("PEDIDO",1);
		pc.addBorderCols("RECIBIDO",1);
		pc.addBorderCols("RECHAZADO",1);
		pc.addBorderCols("PENDIENTE",1);
		pc.setTableHeader(6);//create de table header	
	} else pc.setTableHeader(1);//create de table header
	
	int cont = 1;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo")) && !print_individual.equals("S"))
		{
				if(i!=0) cont = 1; 
				pc.setFont(8, 1,Color.blue);
				pc.addCols(" SOLICITADO POR: "+cdo.getColValue("almacen_dest"),0,5,cHeight);
				pc.addCols(" ENTREGADO POR: "+cdo.getColValue("almacen_sol"),0,5,cHeight);

				pc.addCols(" SOLICITUD #"+cdo.getColValue("codigo"),0,5,cHeight);
				pc.addCols(" ESTADO: "+cdo.getColValue("estado"),0,5,cHeight);
				
				pc.addCols(" CREADO POR: "+cdo.getColValue("usuario_creacion"),0,5,cHeight);
				pc.addCols(" FECHA DOC: "+cdo.getColValue("fecha_docto"),0,5,cHeight);

				pc.setFont(6, 0,Color.blue);
				pc.setVAlignment(0);
				pc.addCols("OBSERVACION: "+cdo.getColValue("observacion"),0,setDetail.size(),24);
				pc.setFont(7, 1);
				pc.addBorderCols("#",0);
				pc.addBorderCols("CODIGO",0);
				pc.addBorderCols("C.BARRA",1);
				pc.addBorderCols("ARTICULO",1);
				pc.addBorderCols("UNIDAD MED.",1);
				pc.addBorderCols("EXISTENCIA",1);
				pc.addBorderCols("PEDIDO",1);
				pc.addBorderCols("RECIBIDO",1);
				pc.addBorderCols("RECHAZADO",1);
				pc.addBorderCols("PENDIENTE",1);
		}

			pc.setFont(7, 1);
			pc.addCols(""+cont,1,1,cHeight);
			pc.addCols(cdo.getColValue("cod_articulo"),0,1,cHeight);
			pc.addCols(cdo.getColValue("cod_barra"),0,1,cHeight);
			pc.addCols(cdo.getColValue("desc_articulo"),0,1,cHeight);
			pc.addCols(cdo.getColValue("unidad_medida_desc"),1,1,cHeight);
			pc.addCols(cdo.getColValue("disponible"),1,1,cHeight);
			pc.addCols(cdo.getColValue("pedido"),1,1,cHeight);
			pc.addCols(cdo.getColValue("recibido"),1,1,cHeight);
			pc.addCols(cdo.getColValue("rechazado"),1,1,cHeight);
			pc.addCols(cdo.getColValue("pendiente"),1,1,cHeight);

		groupBy = cdo.getColValue("codigo");
		cont ++;
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}//for i

	if (al.size() == 0) pc.addCols("No existen registros",1,setDetail.size());
	
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>