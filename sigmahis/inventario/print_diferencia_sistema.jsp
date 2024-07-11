<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("hh12mmssam");
String fp = request.getParameter("fp");
String almacen = request.getParameter("almacen");
String anaquelx = request.getParameter("anaquelx");
String anaquely = request.getParameter("anaquely");
String anio = request.getParameter("anio");
String consigna = request.getParameter("consigna");
String consecutivo = request.getParameter("consecutivo");
String soloDif = request.getParameter("soloDif");
String estado = request.getParameter("estado");
String estado_art = request.getParameter("estado_art");
if(appendFilter== null)appendFilter="";
if(fp== null)fp="CE";
if(anaquelx== null)anaquelx = "";
if(anaquely== null)anaquely = "";
if(consecutivo== null)consecutivo = "";
if(consigna== null)consigna = "";
if(anio== null)anio = "";
if(almacen== null)almacen = "";
if(soloDif== null)soloDif = "";
if(estado== null)estado = "";
if(estado_art== null)estado_art = "";

if(!consigna.trim().equals("")){sbFilter.append(" and a.consignacion_sino = '");sbFilter.append(consigna);sbFilter.append("'");}
if(!almacen.trim().equals("")){sbFilter.append(" and al.codigo_almacen =");sbFilter.append(almacen);}
if(!anaquelx.trim().equals("")){sbFilter.append(" and aa.codigo >= ");sbFilter.append(anaquelx);}
if(!anaquely.trim().equals("")){sbFilter.append(" and aa.codigo <= ");sbFilter.append(anaquely);}
if(!anio.trim().equals("")){sbFilter.append(" and df.cf1_anio =");sbFilter.append(anio);}
if(!consecutivo.trim().equals("")){sbFilter.append(" and df.cf1_consecutivo =");sbFilter.append(consecutivo);}
if(soloDif.trim().equals("S")){sbFilter.append(" and df.cantidad_contada - df.cantidad_sistema <> 0 ");}
if ( !estado_art.trim().equals("") &&!estado_art.trim().equals("X") ) {
	  sbFilter.append(" and a.estado = '");
	  sbFilter.append(estado_art);
	  sbFilter.append("'");
	}
if(!estado.trim().equals("")&&!estado.trim().equals("X")){sbFilter.append(" and cf.estatus='");sbFilter.append(estado);sbFilter.append("'");}
else sbFilter.append(" and cf.estatus != 'N'");

			sbSql.append("select i.codigo_almacen cod_almacen,aa.codigo cod_anaquel,al.descripcion desc_almacen, cf.consecutivo||'-'||cf.anio consecutivo, 'ANAQUEL # '||aa.descripcion desc_anaquel, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo cod_articulos, a.descripcion desc_articulo, a.estado, a.cod_barra, df.cantidad_sistema, df.cantidad_contada, df.cantidad_contada - df.cantidad_sistema dif_cantidad, (df.cantidad_contada* nvl(i.precio,0)) - (df.cantidad_sistema* nvl(i.precio,0)) diferencia from tbl_inv_articulo a, tbl_inv_conteo_fisico cf, tbl_inv_detalle_fisico df, tbl_inv_inventario i, tbl_inv_almacen al, tbl_inv_anaqueles_x_almacen aa where ");


		sbSql.append(" ((df.cod_articulo = a.cod_articulo(+)) and (df.cf1_anio = cf.anio and df.cf1_consecutivo = cf.consecutivo and df.almacen = cf.almacen) and (i.compania = a.compania and i.cod_articulo = a.cod_articulo) and (i.codigo_almacen = df.almacen) and (i.compania = al.compania and i.codigo_almacen = al.codigo_almacen) and ((i.codigo_anaquel = aa.codigo or cf.codigo_anaquel = -99) and i.codigo_almacen = aa.codigo_almacen and i.compania = aa.compania) and (aa.compania = al.compania and aa.codigo_almacen  = al.codigo_almacen)) and i.compania =");
		 sbSql.append(session.getAttribute("_companyId"));
		 sbSql.append(sbFilter);
		 sbSql.append(" order by al.codigo_almacen,cf.consecutivo||'-'||cf.anio, aa.codigo,a.descripcion asc");

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
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "DIFERENCIA ENTRE INVENTARIO FISICO VS. SISTEMA";
	String xtraSubtitle = "FISICO VS SISTEMA";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".30");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		//second row

		pc.setFont(fontSize,1);
		pc.addBorderCols("Codigo",0,1);
		pc.addBorderCols("Codigo de Barra",0,1);
		pc.addBorderCols("Articulos",0,1);
		pc.addBorderCols("Sistema",2,1);
		pc.addBorderCols("Conteo",2,1);
		pc.addBorderCols("Dif. Unidades",2,1);
		pc.addBorderCols("Dif. Monto",2,1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body
	String groupBy="",groupBy2="";
	double total = 0.00,sub_total = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

		if(i==0)
		{
			pc.setFont(fontSize, 0,Color.blue);
			pc.addCols(" [ "+cdo1.getColValue("cod_almacen")+" ] "+cdo1.getColValue("desc_almacen"),0,dHeader.size());
		}

		if (!groupBy2.equalsIgnoreCase(cdo1.getColValue("consecutivo")))
			{
			pc.setFont(8, 0,Color.red);
			pc.addCols("Conteo No: "+cdo1.getColValue("consecutivo"),0,dHeader.size());
		}
		if (!groupBy.equalsIgnoreCase(cdo1.getColValue("cod_almacen")+"-"+cdo1.getColValue("cod_anaquel")))
			{
			pc.setFont(8, 0,Color.blue);
			pc.addCols(" [ "+cdo1.getColValue("cod_anaquel")+" ] "+cdo1.getColValue("desc_anaquel"),0,dHeader.size());
		}

		if(!cdo1.getColValue("dif_cantidad").trim().equals("0"))pc.setFont(fontSize-1,0,Color.red);
		else pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo1.getColValue("cod_articulos"), 0,1);
		pc.addCols(" "+cdo1.getColValue("cod_barra"),0,1);
		pc.addCols(" "+cdo1.getColValue("desc_articulo"), 0,1);
		pc.addCols(" "+cdo1.getColValue("cantidad_sistema"), 2,1);
		pc.addCols(" "+cdo1.getColValue("cantidad_contada"), 2,1);
		pc.addCols(" "+cdo1.getColValue("dif_cantidad"), 2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo1.getColValue("diferencia")), 2,1);

		total +=  Double.parseDouble(cdo1.getColValue("diferencia"));
		groupBy = cdo1.getColValue("cod_almacen")+"-"+cdo1.getColValue("cod_anaquel");
		groupBy2 = cdo1.getColValue("consecutivo");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al == null || al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{pc.setFont(8, 1,Color.blue);
		 pc.addCols("Total: ",2,6);
		 pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",total),2,1);}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>