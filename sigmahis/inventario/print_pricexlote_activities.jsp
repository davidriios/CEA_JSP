<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
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

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year = fecha.substring(6, 10);
String month = fecha.substring(3, 5);
String day = fecha.substring(0, 2);

String appendFilter = "";

String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String estado = request.getParameter("estado");
String consignacion = request.getParameter("consignacion");
String venta = request.getParameter("venta");
String action = request.getParameter("action");
String itemCode = request.getParameter("itemCode");
String fechaini = ((request.getParameter("fechaini") == null || request.getParameter("fechaini").trim().equals(""))?fecha.substring(0,10):request.getParameter("fechaini"));
String fechafin = ((request.getParameter("fechafin") == null || request.getParameter("fechafin").trim().equals(""))?fecha.substring(0,10):request.getParameter("fechafin"));
String fg = request.getParameter("fg");
String actDesc = request.getParameter("actDesc");

if (actDesc == null) actDesc = "ARTICULOS";
if (fg == null) fg = "ART";
if (fechafin != null && fechaini != null) {
	sbFilter.append(" and trunc(aa.fecha_creacion) between to_date('"); sbFilter.append(fechaini); sbFilter.append("','dd/mm/yyyy') and to_date('"); sbFilter.append(fechafin); sbFilter.append("','dd/mm/yyyy')");
}

if (itemCode == null) itemCode = "";
if (familyCode == null) {
	familyCode = "";
	classCode = "";
}
if (!familyCode.trim().equals("")) {
	sbFilter.append(" and aa.cod_flia = "); sbFilter.append(familyCode);

	if (classCode == null) classCode = "";
	if (!classCode.trim().equals("")) { sbFilter.append(" and aa.cod_clase = "); sbFilter.append(classCode); }
}
if (estado == null) estado = "";
if (!estado.trim().equals("")) { sbFilter.append(" and upper(aa.estado) = '"); sbFilter.append(estado); sbFilter.append("'"); }
if (consignacion == null) consignacion = "";
if (!consignacion.trim().equals("")) { sbFilter.append(" and upper(aa.consignacion_sino) = '"); sbFilter.append(consignacion); sbFilter.append("'"); }
if (venta == null) venta = "";
if (!venta.trim().equals("")) { sbFilter.append(" and upper(aa.venta_sino) = '"); sbFilter.append(venta); sbFilter.append("'"); }
if (!itemCode.trim().equals("")) {if(fg.trim().equals("ART")){sbFilter.append(" and aa.cod_articulo = "); sbFilter.append(itemCode);}
else {sbFilter.append(" and aa.codigo = '"); sbFilter.append(itemCode); sbFilter.append("'");}}

if(!fg.trim().equals("ART")){sbFilter.append(" and aa.tipo='");sbFilter.append(fg);sbFilter.append("' ");}

if(fg.trim().equals("ART")){
sbSql.append("select aa.cod_flia||'-'||aa.cod_clase as familyClassGroup, aa.id, aa.cod_articulo as codigo, (select descripcion from tbl_inv_articulo where cod_articulo = aa.cod_articulo and aa.compania = compania) as descripcion, aa.precio, decode(aa.action,'1','+'||aa.porcentaje,-aa.porcentaje) as porcentaje_desc, aa.porcentaje, decode(aa.action,'1','INCREMENTO','DECREMENTO') as action, to_char(aa.fecha_creacion,'dd/mm/yyyy') as fecha, aa.usuario_creacion as usuario, nvl((select descripcion from tbl_inv_clase_articulo where compania = aa.compania and aa.cod_flia = cod_flia and cod_clase = aa.cod_clase),'N/A') as clasename, nvl((select nombre from tbl_inv_familia_articulo where cod_flia = aa.cod_flia and compania = aa.compania),'N/A') as flianame, aa.consignacion_sino, aa.venta_sino, nvl(aa.precio_ant,0) as precioAnt from tbl_inv_pricexlote aa where aa.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(sbFilter);
sbSql.append(" order by 4, aa.fecha_creacion desc");}
else 
{
sbSql.append("select '' as familyClassGroup, aa.id, aa.codigo, decode(aa.tipo,'HAB',(select descripcion from tbl_sal_tipo_habitacion where codigo = aa.codigo and aa.compania = compania),'PROC',(select coalesce(a.observacion,a.descripcion) from tbl_cds_procedimiento a where codigo=aa.codigo),'USOS',(select descripcion from tbl_sal_uso where codigo=aa.codigo and compania=aa.compania ) ) as descripcion, aa.precio, decode(aa.action,'1','+'||aa.porcentaje,-aa.porcentaje) as porcentaje_desc, aa.porcentaje, decode(aa.action,'1','INCREMENTO','DECREMENTO') as action, to_char(aa.fecha_creacion,'dd/mm/yyyy') as fecha, aa.usuario_creacion as usuario, '' as clasename, '' as flianame, '' consignacion_sino,'' venta_sino, nvl(aa.precio_ant,0) as precioAnt from tbl_fac_pricexlote aa where aa.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(sbFilter);
sbSql.append(" order by 4, aa.fecha_creacion desc"); 

}



//aa.cod_flia||''||aa.cod_clase, aa.cod_articulo, aa.fecha_creacion desc";
ArrayList al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
if(fg.trim().equals("ART")){
sbSql.append("select count(*) from (");
	sbSql.append("select distinct aa.cod_flia, aa.cod_clase, aa.cod_articulo from tbl_inv_pricexlote aa where aa.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
sbSql.append(")");}
else {  sbSql.append("select count(*) from (");
	sbSql.append("select distinct aa.codigo from tbl_fac_pricexlote aa where aa.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
sbSql.append(")");}

int nItems = CmnMgr.getCount(sbSql.toString());

String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
String title = (fg.trim().equals("ART"))?"INVENTARIO":"ADMINISTRACION";
String subtitle = "ACTIVIDADES SOBRE EL PRECIO DE VENTA DE "+actDesc;
String xtraSubtitle = "";
boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
float cHeight = 11.0f;

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

Vector tblMain = new Vector();
tblMain.addElement(".08"); //id
tblMain.addElement(".10"); //item code
tblMain.addElement(".30"); //item desc
tblMain.addElement(".10"); //fecha
tblMain.addElement(".10"); //Username
if(fg.trim().equals("ART"))tblMain.addElement(".07"); //price Ant.
else tblMain.addElement(".12"); //price Ant.

if(fg.trim().equals("ART"))tblMain.addElement(".05"); //price
else tblMain.addElement(".10"); //price

tblMain.addElement(".05"); //porcentaje
if(fg.trim().equals("ART"))tblMain.addElement(".10"); //consignacion?
tblMain.addElement(".05"); //venta?

pc.setNoColumnFixWidth(tblMain);
pc.createTable();

pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, tblMain.size());

pc.setTableHeader(2);

//CommonDataObject cdo = new CommonDataObject();
String familyClassGroup = "";

pc.addBorderCols("ID",1,1);
pc.addBorderCols("Código",1,1);
pc.addBorderCols("Descripción",0,1);
pc.addBorderCols("Fecha",1,1);
pc.addBorderCols("Usuario",0,1);
pc.addBorderCols("Precio Ant.",2,1);
pc.addBorderCols("Precio",2,1);
pc.addBorderCols("Porc.",2,1);
if(fg.trim().equals("ART"))pc.addBorderCols("Consignación?",1,1);
if(fg.trim().equals("ART"))pc.addBorderCols("Venta?",1,1);
if(!fg.trim().equals("ART"))  pc.addBorderCols(" ",1,1);


for (int i = 0; i<al.size(); i++){
	CommonDataObject cdo = (CommonDataObject)al.get(i);
    if(fg.trim().equals("ART")){
	if (!familyClassGroup.trim().equals(cdo.getColValue("familyClassGroup"))) {
			pc.setFont(7,1,Color.white);
		pc.addCols("["+cdo.getColValue("flianame")+"] "+cdo.getColValue("clasename"),0,tblMain.size(),Color.lightGray);
	}}

	pc.setFont(7,0);

	pc.addCols(cdo.getColValue("id"),1,1);
	pc.addCols(cdo.getColValue("codigo"),1,1);
	pc.addCols(cdo.getColValue("descripcion"),0,1);
	pc.addCols(cdo.getColValue("fecha"),1,1);
	pc.addCols(cdo.getColValue("usuario"),0,1);
	pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("precioAnt")),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("precio")),2,1);
	pc.addCols(cdo.getColValue("porcentaje"),2,1);
	if(fg.trim().equals("ART"))pc.addCols(cdo.getColValue("consignacion_sino"),1,1);
	if(fg.trim().equals("ART"))pc.addCols(cdo.getColValue("venta_sino"),1,1);
	if(!fg.trim().equals("ART"))pc.addCols("",1,1);
	//System.out.println("thebrain>:::::::::::::::::::::::::::::::::"+cdo.getColValue("flianame")+cdo.getColValue("clasename"));

	/*double ov = 0.0;
	double cv = Double.parseDouble(cdo.getColValue("precio"));
	double p = Double.parseDouble(cdo.getColValue("porcentaje"));

	if (cdo.getColValue("action").trim().equals("DECREMENTO")){
		p = p*-1;
		}

	ov = (cv*100)/(100+(p));*/
	//System.out.println("thebrain>:::::::::::::::::::::::::::::::::"+ov);


	familyClassGroup = cdo.getColValue("familyClassGroup");
}

if (al.size() < 1){
	pc.setFont(7,1);
	pc.addCols(" ",1,tblMain.size());
	pc.addCols("¡No encontramos datos!",1,tblMain.size());
} else {
	pc.setFont(8,1);
	pc.addCols(" ",1,tblMain.size());
	pc.addCols(nItems+" Items con Precio Actualizado!",1,tblMain.size());
}

pc.addTable();
pc.close();
response.sendRedirect(redirectFile);
%>