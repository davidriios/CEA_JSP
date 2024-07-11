<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
==================       COM0016.RDF       =======================================
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
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String compania =  compania = (String) session.getAttribute("_companyId");
String fg = request.getParameter("fg");

if (fg == null) fg = "";
if (appendFilter == null) appendFilter = "";

sql = "SELECT cod_provedor as codigo, nombre_proveedor as nombre, compania, decode(estado_proveedor,'ACT','ACTIVO','INA','INACTIVO') as estado, ruc, digito_verificador as digito, telefono, fax, contacto_compra as contacto, apartado_postal as apartado, email,cat_cta1||'.'||cat_cta2||'.'||cat_cta3||'.'||cat_cta4||'.'||cat_cta5||'.'||cat_cta6 cuenta,nvl((select descripcion from tbl_con_catalogo_gral cg where cg.cta1||'.'||cg.cta2||'.'||cg.cta3||'.'||cg.cta4||'.'||cg.cta5||'.'||cg.cta6 = cat_cta1||'.'||cat_cta2||'.'||cat_cta3||'.'||cat_cta4||'.'||cat_cta5||'.'||cat_cta6 and cg.compania=p.compania ),'') descCuenta,decode(nvl(p.vetado,'N'),'N','NO','S','SI')  as vetado, cuenta_bancaria FROM tbl_com_proveedor p where compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by nombre_proveedor";


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	boolean isLandscape = !fg.trim().equalsIgnoreCase("CTA");
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;

	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COMPRAS";
	String subtitle = "LISTADO DE PROVEEDORES";

	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".05");
		dHeader.addElement(".08");
		dHeader.addElement(".07");
		dHeader.addElement(".14");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".03");
		dHeader.addElement(".09");
		dHeader.addElement(".04");
        
		dHeader.addElement(".10");
		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(7, 1);
		
		pc.addBorderCols("Nombre del Proveedor.",1);
		pc.addBorderCols("Código",1);
		
		if(fg.trim().equals("CTA"))
		{
			pc.addBorderCols("Cuenta",1,2);
			pc.addBorderCols("Descripcion",1,7);
		}
		else 
		{
			pc.addBorderCols("Teléfono",1);
			pc.addBorderCols("Fax",1);
			pc.addBorderCols("Contacto",1);
			pc.addBorderCols("E-Mail",1);
			pc.addBorderCols("R.U.C",1);
			pc.addBorderCols("D.V.",1);
			pc.addBorderCols("Apartado Postal.",1);
			pc.addBorderCols("Vetado",1);
			pc.addBorderCols("Cuenta",1);
		}
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		
		pc.addBorderCols(""+cdo.getColValue("nombre"),0,1,cHeight);
		pc.addBorderCols(""+cdo.getColValue("codigo"),1,1,cHeight);
		
		if(fg.trim().equals("CTA"))
		{
			pc.addBorderCols(""+cdo.getColValue("cuenta"),0,2,cHeight);
			pc.addBorderCols(""+cdo.getColValue("descCuenta"),0,7,cHeight);
		}
		else 
		{
		    
			pc.addBorderCols(""+cdo.getColValue("telefono"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("fax"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("contacto"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("email"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("ruc"),0,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("digito"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("apartado"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("vetado"),1,1,cHeight);
			pc.addBorderCols(""+cdo.getColValue("cuenta_bancaria"," "),1,1,cHeight);
		}
	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.setFont(7, 1);
			pc.addCols("TOTAL DE PROVEEDORES: "+al.size(),0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>