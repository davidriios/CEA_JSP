<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
FP		REPORTE
CSE		INV0060.RDF
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

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String compania = request.getParameter("compania");
String almacen = request.getParameter("almacen");
String anaquelx = request.getParameter("anaquelx");
String anaquely = request.getParameter("anaquely");
String consignacion = request.getParameter("consignacion");
String status = request.getParameter("status")==null?"":request.getParameter("status");
String titulo ="" ;
String subTitulo ="";
//String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

if(appendFilter== null)appendFilter="";
if(fp== null)fp="CE";
if(anaquelx== null)anaquelx = "";
if(anaquely== null)anaquely = "";
if(consignacion== null)consignacion = "";
if(!almacen.trim().equals(""))         appendFilter  = " and al.codigo_almacen = "+almacen;
if(!anaquelx.trim().equals(""))        appendFilter  += " and aa.codigo >="+anaquelx;
if(!anaquely.trim().equals(""))        appendFilter  += " and aa.codigo <="+anaquely;
if(!consignacion.trim().equals(""))    appendFilter  += " and aa.consignacion ='"+consignacion+"'";
if(!status.trim().equals("")) appendFilter  += " and a.estado ='"+status+"'";

sql = "select al.codigo_almacen cod_almacen, al.descripcion desc_almacen, aa.codigo cod_anaquel, 'ANAQUEL : ('||aa.codigo||') '||aa.descripcion  desc_anaquel, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo cod_articulos, a.cod_barra, a.descripcion desc_articulo, i.disponible existencia, i.precio costo,NVL(i.precio,0) * NVL(i.disponible,0) total, nvl(a.cod_medida,' ') cod_medida from tbl_inv_almacen al, tbl_inv_anaqueles_x_almacen aa, tbl_inv_articulo a, tbl_inv_inventario i where (aa.compania = al.compania and aa.codigo_almacen = al.codigo_almacen) and (i.compania = al.compania and i.codigo_almacen = al.codigo_almacen) and (i.codigo_anaquel = aa.codigo and i.codigo_almacen = aa.codigo_almacen and i.compania = aa.compania) and (i.compania = a.compania and i.cod_articulo = a.cod_articulo) and a.estado = 'A' and i.compania = "+compania+appendFilter+" order by al.descripcion,aa.codigo,a.descripcion,i.cod_articulo";

al = SQLMgr.getDataList(sql);

sql=" select  'AL' type,  i.codigo_almacen , 0 anaquel ,al.descripcion descripcion, sum(NVL(i.precio,0) * NVL(i.disponible,0)) total from tbl_inv_almacen al, tbl_inv_anaqueles_x_almacen aa, tbl_inv_articulo a, tbl_inv_inventario i where (aa.compania = al.compania and aa.codigo_almacen = al.codigo_almacen) and (i.compania =  al.compania and i.codigo_almacen = al.codigo_almacen) and (i.codigo_anaquel = aa.codigo and i.codigo_almacen = aa.codigo_almacen and  i.compania = aa.compania) and (i.compania = a.compania and i.cod_articulo =   a.cod_articulo) and a.estado = 'A' and i.compania = "+compania+appendFilter;
 sql += " group by  'AL', i.codigo_almacen , al.descripcion ,0 union ";

sql += " select  'AN' type, i.codigo_almacen ,  aa.codigo cod_anaquel, 'ANAQUEL : ('||aa.codigo||') '||aa.descripcion  desc_anaquel, sum(NVL(i.precio,0) * NVL(i.disponible,0)) total from tbl_inv_almacen al, tbl_inv_anaqueles_x_almacen aa, tbl_inv_articulo a, tbl_inv_inventario i where (aa.compania = al.compania and aa.codigo_almacen = al.codigo_almacen) and (i.compania =  al.compania and i.codigo_almacen = al.codigo_almacen) and (i.codigo_anaquel = aa.codigo and i.codigo_almacen = aa.codigo_almacen and   i.compania = aa.compania) and (i.compania = a.compania and i.cod_articulo =   a.cod_articulo) and a.estado = 'A' and i.compania ="+compania+appendFilter+" group by 'AN' , aa.codigo , 'ANAQUEL : '||aa.descripcion, i.codigo_almacen    order by 1  " ;


//alTotal = SQLMgr.getDataList(sql);



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
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "";
	if(fp.trim().equals("CSE")) subtitle = "ARTICULOS CON Y SIN EXISTENCIA POR ANAQUEL";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 15.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
				 dHeader.addElement(".10");
				 dHeader.addElement(".15");
				 dHeader.addElement(".45");
				 dHeader.addElement(".10");
				 dHeader.addElement(".10");
				 dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		/*
		pc.setFont(8, 1);
		pc.addBorderCols("Código",0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Cod. Barra",0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Articulo",0,1, 0.5f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("U. de Medida",1,1, 0.5f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("Cantidad",1,1, 0.5f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("Conteo",1,1, 0.5f, 0.0f, 0.0f, 0.0f);
*/
		pc.setTableHeader(1);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	String groupBy="",subGroupBy="";
	for (int i=0; i<al.size(); i++)
	{
		
				CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!groupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")))
			{

				if (i != 0)
				{
						pc.addCols(" ",0,dHeader.size());
				}


				pc.setFont(8, 1,Color.blue);
					pc.addBorderCols("A L M A C E N : "+cdo.getColValue("desc_almacen"),0,dHeader.size(),cHeight);//0.5f,0.0f,0.0f,0.0f,cHeight);


			}
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_anaquel")))
			{
					pc.setFont(8, 1,Color.red);
					pc.addCols(""+cdo.getColValue("desc_anaquel"),0,dHeader.size(),cHeight);
						
					pc.setFont(8, 1);
						pc.addBorderCols("Código",0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
						pc.addBorderCols("Cod. Barra",0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
						pc.addBorderCols("Articulo",0,1, 0.5f, 0.0f, 0.0f, 0.0f);
						pc.addBorderCols("U. de Medida",1,1, 0.5f, 0.0f, 0.0f, 0.0f);
						pc.addBorderCols("Cantidad",1,1, 0.5f, 0.0f, 0.0f, 0.0f);
						pc.addBorderCols("Conteo",1,1, 0.5f, 0.0f, 0.0f, 0.0f);



			}

		pc.setFont(8, 0);
		
		
		pc.setVAlignment(1);
		pc.addBorderCols(" "+cdo.getColValue("cod_articulos"), 0,1, 0.5f, 0.0f, 0.0f, 0.0f,28.0f);
		pc.addBorderCols(" "+cdo.getColValue("cod_barra"), 0,1, 0.5f, 0.0f, 0.0f, 0.0f,28.0f);
		pc.addBorderCols(" "+cdo.getColValue("desc_articulo"), 0,1, 0.5f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(" "+cdo.getColValue("cod_medida"), 1,1, 0.5f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(" "+cdo.getColValue("existencia"), 1,1, 0.5f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(" ", 0,1, 0.5f, 0.0f, 0.0f, 0.0f);
		pc.resetVAlignment();

		groupBy = cdo.getColValue("cod_almacen");
		subGroupBy = cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("cod_anaquel");


	
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>