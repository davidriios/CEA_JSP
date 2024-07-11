<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.awt.Color"%>
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

CommonDataObject cdo=new CommonDataObject();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String familyCode = (request.getParameter("familyCode")==null?"":request.getParameter("familyCode"));
String companyCode = (request.getParameter("companyCode")==null?"":request.getParameter("companyCode"));
String itemCode = (request.getParameter("itemCode")==null?"":request.getParameter("itemCode"));
String cCompany = _comp.getCodigo();

String itemDesc = (request.getParameter("itemDesc")==null?"":request.getParameter("itemDesc"));
String itemFamilyDesc = (request.getParameter("itemFamilyDesc")==null?"":request.getParameter("itemFamilyDesc"));
String itemClaseDesc = (request.getParameter("itemClaseDesc")==null?"":request.getParameter("itemClaseDesc"));
String fg = request.getParameter("fg");
if ( fg==null)fg="ART";

String sql = "select to_char(p.fecha_creacion,'dd/mm/yyyy') fc, p.action, decode(p.action,1,'INCR.','DECR.') as action_desc, p.usuario_creacion, decode(p.action,1,'+','-')||p.porcentaje porcentaje, p.precio precio_actual, ((p.precio*100) / (decode(p.action,1, 100+p.porcentaje, 100-p.porcentaje )))   precio_anterior from tbl_inv_pricexlote p where p.cod_articulo = "+itemCode+" and p.compania = "+companyCode+" and p.compania = "+cCompany+" order by p.fecha_creacion desc";

//al = SQLMgr.getDataList(sql);
sbSql.append("select to_char(p.fecha_creacion,'dd/mm/yyyy') as fc, p.action, decode(p.action,1,'INCR.','DECR.')");

if(fg.trim().equals("ART"))sbSql.append(" ||decode(p.tipo_precio,'PCR',' PRECIO CREDITO',' PRECIO CONTADO') ");

sbSql.append(" as action_desc, p.usuario_creacion, decode(p.action,1,'+','-')||p.porcentaje as porcentaje, p.precio as precio_actual, /*((p.precio * 100) / (100 + decode(p.action,1,p.porcentaje,-p.porcentaje)))*/nvl(p.precio_ant,0) as precio_anterior  ");

if(fg.trim().equals("ART"))sbSql.append(",decode(tipo_inc,'PV','PRECIO VENTA','CP','COSTO PROMEDIO','RECEP','P. ULTIMA COMPRA') as tipo_desc ");
else sbSql.append(", ' ' as tipo_desc ");

if(fg.trim().equals("ART")) sbSql.append(" from tbl_inv_pricexlote p where p.cod_articulo = ");
else sbSql.append(" from tbl_fac_pricexlote p where p.codigo = ");
sbSql.append(itemCode);
if(!fg.trim().equals("ART")){sbSql.append(" and p.tipo = '");sbSql.append(fg);sbSql.append("'");}

sbSql.append(" and p.compania = ");
sbSql.append(companyCode); 
sbSql.append(" order by p.fecha_creacion desc");
al = SQLMgr.getDataList(sbSql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+timeStamp+" "+(3.19+(3.19*(Double.parseDouble("5")))/100));
	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+Math.round((3.3495*100))/100.00d);
	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+CmnMgr.getFormattedDecimal("3.3495"));

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = (fg.trim().equals("ART"))?"INVENTARIO":"ADMINISTRACION";
	String subtitle = "HISTORIAL DE CAMBIO PRECIO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".08");  //Fecha
	setDetail.addElement(".17"); //Accion
	setDetail.addElement(".12"); //Tipo inc
	setDetail.addElement(".15"); //Porcentaje
	setDetail.addElement(".18"); //Usuario
	setDetail.addElement(".15"); //Precio Anterior
	setDetail.addElement(".15"); //Precio Actual

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

	pc.setFont(8, 1);
	pc.addCols("["+itemFamilyDesc+"] "+itemClaseDesc,0,setDetail.size(),Color.lightGray);
	pc.addCols("["+itemCode+"] "+itemDesc,0,setDetail.size(),Color.lightGray);
	pc.addCols("",0,setDetail.size());

	pc.addBorderCols("FECHA",1,1);
	pc.addBorderCols("ACCION",1,1);
	pc.addBorderCols("SEGUN TIPO",1,1);
	pc.addBorderCols("PORCENTAJE",1,1);
	pc.addBorderCols("USUARIO",0,1);
	pc.addBorderCols("PRECIO ANTERIOR",2,1);
	pc.addBorderCols("PRECIO ACTUAL",2,1);

	pc.addCols("",0,setDetail.size());

	pc.setTableHeader(6);

	pc.setFont(7, 0);
	if ( al.size() < 1 ) pc.addCols("No hemos encontrado ningún registro!",1,setDetail.size());
	else
	for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);

		pc.addCols(cdo.getColValue("fc"),1,1);
		pc.addCols(cdo.getColValue("action_desc"),1,1);
		pc.addCols(cdo.getColValue("tipo_desc"),1,1);
		pc.addCols(cdo.getColValue("porcentaje"),1,1);
		pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("precio_anterior")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("precio_actual")),2,1);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>