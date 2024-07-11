<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
0 - SYSTEM ADMINISTRATOR 
      REPORTE   INV70304.RDF        ORDENES DE COMPRE POR PROVEEDOR
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
 
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

String compania = (String) session.getAttribute("_companyId");
String fp       = request.getParameter("fp");
String anio    = request.getParameter("anio");
String proveedor = request.getParameter("proveedor");
String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String subClase = request.getParameter("subClase");

if (anio == null)anio="";
if (proveedor == null)proveedor="";
if (familia == null)familia="";
if (clase == null)clase="";
if (articulo == null)articulo="";
if (subClase == null)subClase="";
if (appendFilter == null)appendFilter="";

	
sql.append("select b.cf_num_doc, b.cf_anio, b.cf_anio||'-'||b.cf_num_doc doc, a.explicacion,b.cf_tipo_com, b.cod_familia||'-'||b.cod_clase||'-'||b.subclase_id||'-'||b.cod_articulo art, c.descripcion, b.cantidad, nvl(b.monto_articulo,'0.00') monto_articulo, b.entregado, b.especificacion, a.usuario as usuario_creacion, to_char(a.fecha_del_sistema,'dd/mm/yyyy') fecha, a.compania, a.cod_proveedor, d.nombre_proveedor,decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','C','APROB. CONT.','F','APROB. FIN.') estado_dsp from tbl_com_comp_formales a, tbl_com_detalle_compromiso b, tbl_inv_articulo c, tbl_com_proveedor d where a.anio = b.cf_anio and a.tipo_compromiso = b.cf_tipo_com and a.num_doc = b.cf_num_doc and a.compania = b.compania and a.cod_proveedor = d.cod_provedor and b.cod_familia = c.cod_flia and b.cod_clase= c.cod_clase and b.cod_articulo= c.cod_articulo and b.compania = c.compania and a.compania =");
sql.append(compania);
sql.append(appendFilter);

if(!anio.trim().equals("")){
sql.append(" and a.anio = ");
sql.append(anio);}

if(!proveedor.trim().equals("")){
sql.append(" and a.cod_proveedor = ");
sql.append(proveedor);}

if(!familia.trim().equals("")){
sql.append(" and b.cod_familia = ");
sql.append(familia);}
if(!clase.trim().equals("")){
sql.append(" and b.cod_clase = ");
sql.append(clase);}
if(!articulo.trim().equals("")){
sql.append(" and b.cod_articulo = ");
sql.append(articulo);}
if(!subClase.trim().equals("")){
sql.append(" and b.subclase_id = ");
sql.append(subClase);}


sql.append(" order by a.cod_proveedor, b.cf_anio||'-'||b.cf_num_doc,  b.cod_familia||'-'||b.cod_clase||'-'||b.cod_articulo, c.descripcion");
al = SQLMgr.getDataList(sql.toString()); 
	

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ORDENES DE COMPRA POR PROVEEDOR";
	String subtitle = "DEL AÑO "+anio;
	String xtraSubtitle = " ";//" DEL "+fechaini+" AL "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".15");
	dHeader.addElement(".45");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
							
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.addBorderCols("Artìculo",0,1);
	pc.addBorderCols("Descripcion",0,1);						
	pc.addBorderCols("Cantidad",2,1);
	pc.addBorderCols("Valor ",2,1);
	pc.addBorderCols("Usuario",1,1);
	pc.addBorderCols("F.Creacion",1,1);		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

    pc.setFont(8, 1);
	
	
	double salBruto =0.00,gastoRep =0.00,valorVac=0.00,valorVacGrep =0.00;
	
	if (al.size() == 0) pc.addCols(" No hay registros!",1,dHeader.size());
	
	
	String groupBy = "",subGroupBy="";
	for ( int i = 0; i<al.size(); i++ ){
		CommonDataObject cdo = (CommonDataObject)al.get(i);
		
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_proveedor")))
		{
		 	pc.setFont(8,1);
			pc.addCols(" ", 0,dHeader.size());	
		    pc.addCols("Proveedor    : "+cdo.getColValue("cod_proveedor")+"     "+cdo.getColValue("nombre_proveedor"), 0,dHeader.size());	
			subGroupBy = "";
		}
		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("doc")))
		{
				pc.setFont(8, 1);
				pc.addCols("O. C.  : "+cdo.getColValue("cf_num_doc")+"    Año : "+cdo.getColValue("cf_anio")+"  Tipo Comp. : "+cdo.getColValue("cf_tipo_com")+"     Estado: "+cdo.getColValue("estado_dsp"), 0,dHeader.size());		
		}
		  pc.setFont(7, 0);
		  pc.addCols(" "+cdo.getColValue("art"),0,1);							
		  pc.addCols(" "+cdo.getColValue("descripcion"),0,1) ;
		  pc.addCols(""+cdo.getColValue("cantidad"),2,1);
		  pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_articulo")),2,1);
		  pc.addCols(""+cdo.getColValue("usuario_creacion"),1,1) ;
		  pc.addCols(""+cdo.getColValue("fecha"),1,1);
		
		subGroupBy = cdo.getColValue("doc");
		groupBy = cdo.getColValue("cod_proveedor");
	}
		
		
		 
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
