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
/**
==================================================================================
Reporte
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
CommonDataObject cdo1 = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter"); 
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
if (appendFilter == null) appendFilter = "";  
 
	sbSql.append("select tipo, tipo_desc, anio_docto, no_docto, compania, fecha_docto, to_char(fecha_sistema, 'dd/mm/yyyy hh12:mi am') fecha_sistema, fecha_sistema fecha_trx, codigo_almacen, cod_familia, cod_clase, cod_articulo, qty, precio, descripcion, tipo_mov, tipo_docto, cod_extra, pac_id, admision, saldo_inicial, cod_barra, cod_proveedor, fecha_lf, qty_lf, no_lote, to_char(fecha_vence, 'dd/mm/yyyy') fecha_vence, no_serie, dias_vigente,(select codigo_anaquel||' - '||nvl((select descripcion from tbl_inv_anaqueles_x_almacen where compania=a.compania and codigo_almacen=a.codigo_almacen and codigo=i.codigo_anaquel ),'SIN ANAQUEL ') from tbl_inv_inventario i where cod_articulo =a.cod_articulo and codigo_almacen=a.codigo_almacen and compania =a.compania   ) as anaquel,(select descripcion from tbl_inv_almacen where compania=a.compania and codigo_almacen=a.codigo_almacen) wh ,(select nombre from tbl_inv_familia_articulo where compania = a.compania and cod_flia=a.cod_familia) descFamilia from vw_inv_trx_lote_item_x a where a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(appendFilter.toString());
		sbSql.append(" order by a.codigo_almacen,30,cod_familia,cod_articulo, fecha_trx desc");

	al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "TRAZABILIDAD DE ARTICULOS ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector setDetail = new Vector();
		setDetail.addElement(".09");
		setDetail.addElement(".26");
		setDetail.addElement(".10");
		setDetail.addElement(".09");
		setDetail.addElement(".11");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".09");
		setDetail.addElement(".08");
		
		
		

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath,displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

		//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, setDetail.size());

		pc.setFont(7, 1);
		pc.addBorderCols("Codigo",1);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Tipo Transacción",1);
		pc.addBorderCols("Año/Código",1);
		pc.addBorderCols("Fecha Trx.",1);
		pc.addBorderCols("Fecha Vence",1);
		pc.addBorderCols("No. Lote",1);
		pc.addBorderCols("Cantidad",1);
		pc.addBorderCols("Días Vigente",1);
		 
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0); 
	String familyClass = "",wh="",anaquelWh="";
 	for (int i=0; i<al.size(); i++)
	{
		 CommonDataObject cdo = (CommonDataObject) al.get(i);
		 
		pc.setFont(8, 1);
		
		if(!wh.trim().equals(cdo.getColValue("codigo_almacen"))){ 
		if(i!=0)pc.addCols(" ",0,setDetail.size()); 
		pc.addCols(cdo.getColValue("wh"),0,setDetail.size()); 
		
		}
		
		if(!anaquelWh.trim().equals(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("anaquel")))
		pc.addCols("        "+cdo.getColValue("anaquel"),0,setDetail.size()); 
		
		if(!familyClass.trim().equals(cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("anaquel")+"-"+cdo.getColValue("cod_familia"))) 
		pc.addCols("                "+cdo.getColValue("descFamilia"),0,setDetail.size());  
		
		pc.setFont(7, 0); 
			
		pc.addCols(cdo.getColValue("cod_articulo"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("tipo_desc"),1,1);
		pc.addCols(""+cdo.getColValue("anio_docto")+" - "+cdo.getColValue("no_docto"),1,1);
		pc.addCols(cdo.getColValue("fecha_sistema"),1,1);
		pc.addCols(cdo.getColValue("fecha_vence"),1,1);
		pc.addCols(cdo.getColValue("no_lote"),0,1);
		pc.addCols(cdo.getColValue("qty_lf"),0,1); 
		pc.addCols(cdo.getColValue("dias_vigente"),0,1); 
		 
		wh =cdo.getColValue("codigo_almacen");
		anaquelWh = cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("anaquel");
		familyClass = cdo.getColValue("codigo_almacen")+"-"+cdo.getColValue("anaquel")+"-"+cdo.getColValue("cod_familia");
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,setDetail.size());
	}
	 
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>