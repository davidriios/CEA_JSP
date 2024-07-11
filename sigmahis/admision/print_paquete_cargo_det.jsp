<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String comboId = request.getParameter("comboId");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String compania = (String)session.getAttribute("_companyId");
String empresa = request.getParameter("empresa");
String cds = request.getParameter("cds");
String categoria = request.getParameter("categoria");

if (comboId == null) comboId = "";
if (empresa == null) empresa = "0";
if (cds == null) cds = "0";
if (categoria == null) categoria = "0";

StringBuffer sb = new StringBuffer();

sb.append("select id combo_id, nombre combo_name, observacion combo_observacion from tbl_cds_combo_cargo where id = ");
sb.append(comboId);

CommonDataObject cCdo = SQLMgr.getData(sb.toString());
if (cCdo == null)  cCdo = new CommonDataObject();


sb = new StringBuffer();
sb.append("select xx.*");
sb.append(", coalesce(getprecio(");
sb.append(compania);

sb.append(",(select clasif_cargo from tbl_cds_tipo_servicio where codigo = xx.tipo_servicio), xx.cargo_code,");
sb.append(empresa);
sb.append(",");
sb.append(cds);
sb.append(",");
sb.append(categoria);
sb.append("),xx.monto_tmp,0) as monto ");

sb.append(" from(select distinct nvl(d.tipo_servicio, decode(d.tipo_cargo,'P','07',' ')  ) tipo_servicio, (select ts.descripcion from tbl_cds_tipo_servicio ts where ts.codigo = nvl(d.tipo_servicio, decode(d.tipo_cargo,'P','07',' ')) and ts.compania = ");
sb.append(compania);
sb.append(") as tipo_serv_desc , decode(d.tipo_cargo,'I',nvl(a.cod_flia,0)||'-'||nvl(a.cod_clase,0)||'-'||nvl(a.cod_articulo,0),'P',d.cod_cargo) as cargo_code, d.tipo_cargo, d.cantidad, d.descripcion, d.cod_cargo as trabajo, decode(d.tipo_cargo,'U', (select u.precio_venta from tbl_sal_uso u where u.codigo = d.cod_cargo and u.compania = c.compania ),'P', (select p.precio from tbl_cds_procedimiento p where p.codigo = d.cod_cargo),'I', (select precio_venta from tbl_inv_articulo where cod_articulo = d.cod_cargo and compania = c.compania ) ) as monto_tmp, decode(d.tipo_cargo,'P',d.cod_cargo) as procedimiento, 0 as otros_cargos, 0 as cds_producto, ' ' as habitacion, 0 as servicio_hab , 0 as inv_almacen , decode(d.tipo_cargo,'I',a.cod_flia,0) as art_familia , decode(d.tipo_cargo,'I',a.cod_clase,0) as art_clase , decode(d.tipo_cargo,'I',a.cod_articulo,0) as inv_articulo , trim(a.cod_barra) as codBarra, decode(d.tipo_cargo,'U',d.cod_cargo) as cod_uso , 0 as costo_art, 'N' as incremento, decode(d.tipo_cargo,'I','S','N') as inventario , 0 as cantidad_disponible , 0 as centro_costo, decode(d.tipo_cargo,'I',a.other3,'N') as afecta_inv, null as cama, decode(d.tipo_cargo,'I','INSUMOS','P','PROCEDIMIENTOS','U','USOS') as tipo_cargo_desc from tbl_cds_combo_cargo c, tbl_cds_combo_cargo_det d, tbl_inv_articulo a where c.id = d.id and d.cod_cargo = to_char(a.cod_articulo(+)) and c.compania = ");
sb.append(compania);
sb.append(" and c.id = ");
sb.append(comboId);

if (!cds.trim().equals("") && !cds.trim().equals("0")){
	sb.append(" and exists (select tipo_servicio from tbl_cds_servicios_x_centros where centro_servicio = ");
	sb.append(cds);
	sb.append(" and tipo_servicio = nvl(d.tipo_servicio, decode(d.tipo_cargo,'P','07',' ')  ) and visible_centro = 'S') ");
}
sb.append(" order by d.tipo_cargo,d.descripcion )xx ");

if (!comboId.trim().equals("") && !comboId.trim().equals("0")){
al = SQLMgr.getDataList(sb.toString());
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String title = "ADMISION";
	String subtitle = "PAQUETE DE CARGOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	String gGroup = "";
	int totPack = 0;
	double montoTot = 0.0;

	Vector tblHder = new Vector();
	tblHder.addElement(".20");
	tblHder.addElement(".60");
	tblHder.addElement(".20");

	Vector tblDet = new Vector();
	tblDet.addElement("10");
	tblDet.addElement("43");
	tblDet.addElement("23");
	tblDet.addElement("7");
	tblDet.addElement("10");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath,displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(tblHder);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, tblHder.size());


	//Header
	pc.setFont(8, 1,Color.white);
	pc.addCols("PAQUETE",0,tblHder.size(),Color.lightGray);

	pc.setFont(8, 1);
	pc.addCols(cCdo.getColValue("combo_id"),0,1);
	pc.addCols(cCdo.getColValue("combo_name"),0,2);

	if (cCdo.getColValue("combo_observacion") != null && !cCdo.getColValue("combo_observacion").equals("") ){
		pc.setFont(8,0);
		pc.addCols(cCdo.getColValue("combo_observacion"),0,tblHder.size());
	}

	pc.addCols(" ",1,tblDet.size());
	pc.setFont(8, 1,Color.white);
	pc.addCols("DETALLE",0,tblHder.size(),Color.lightGray);

	pc.setTableHeader(3);

	pc.setNoColumnFixWidth(tblDet);
	pc.createTable("det");

	pc.setFont(8, 1);
	pc.addBorderCols("Código",1,1);
	pc.addBorderCols("Descripción",0,1);
	pc.addBorderCols("T.Servicio",0,1);
	pc.addBorderCols("Cant.",1,1);
	pc.addBorderCols("Precio",2,1);
	pc.setVAlignment(0);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject)al.get(i);

		if(!gGroup.equals(cdo.getColValue("tipo_cargo"))){
			pc.setFont(9, 1);
			pc.addCols(cdo.getColValue("tipo_cargo_desc"),0,tblDet.size());
		}

		totPack += Integer.parseInt(cdo.getColValue("cantidad"));
		montoTot += Double.parseDouble(cdo.getColValue("cantidad")) * Double.parseDouble(cdo.getColValue("monto"));

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("trabajo"),1,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("tipo_serv_desc"),0,1);
		pc.addCols(cdo.getColValue("cantidad"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);

		gGroup = cdo.getColValue("tipo_cargo");
	}

	if (al.size() == 0)
	{
		pc.addCols("No existen registros",1,tblDet.size());
	}
	else
	{
		pc.setFont(8, 1);
		pc.addCols("Totales",2,3);
		pc.addCols(""+totPack,1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(montoTot),2,1);
	}


	pc.useTable("main");
	pc.addTableToCols("det",0,tblHder.size(),0f);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>