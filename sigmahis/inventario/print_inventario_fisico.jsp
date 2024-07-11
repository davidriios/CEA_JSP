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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
String id = request.getParameter("id");

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

if(!consigna.trim().equals("")){sbFilter.append(" and a.consignacion_sino = '");sbFilter.append(consigna);sbFilter.append("'");}
if(!almacen.trim().equals("")){sbFilter.append(" and al.codigo_almacen =");sbFilter.append(almacen);}

if(!anaquelx.trim().equals("")){sbFilter.append(" and aa.codigo >= ");sbFilter.append(anaquelx);}
if(!anaquely.trim().equals("")){sbFilter.append(" and aa.codigo <= ");sbFilter.append(anaquely);}
if(!anio.trim().equals("")){sbFilter.append(" and df.cf1_anio =");sbFilter.append(anio);}
if(!consecutivo.trim().equals("")){sbFilter.append(" and df.cf1_consecutivo =");sbFilter.append(consecutivo);}
if(soloDif.trim().equals("S")){sbFilter.append(" and df.cantidad_contada - df.cantidad_sistema <> 0 ");}


	   // sbSql.append("select i.codigo_almacen cod_almacen,aa.codigo cod_anaquel,al.descripcion desc_almacen, cf.consecutivo||'-'||cf.anio consecutivo, 'ANAQUEL # '||aa.descripcion desc_anaquel, a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo cod_articulos, a.descripcion desc_articulo, a.cod_barra, df.cantidad_sistema, df.cantidad_contada, df.cantidad_contada - df.cantidad_sistema dif_cantidad, (df.cantidad_contada* nvl(i.precio,0)) - (df.cantidad_sistema* nvl(i.precio,0)) diferencia from tbl_inv_articulo a, tbl_inv_conteo_fisico cf, tbl_inv_detalle_fisico df, tbl_inv_inventario i, tbl_inv_almacen al, tbl_inv_anaqueles_x_almacen aa where cf.estatus != 'N'");
	   
	   String _filter = " and al.codigo_almacen = cf.almacen and al.compania = cf.compania and aa.codigo_almacen = cf.almacen and aa.compania = cf.compania and aa.codigo=cf.codigo_anaquel ";
				
		if (anaquely.equals("-99")) _filter = " and al.codigo_almacen = cf.almacen and al.compania = cf.compania and aa.codigo_almacen(+) = cf.almacen and aa.compania(+) = cf.compania and aa.codigo(+)=cf.codigo_anaquel ";
	   
	   CommonDataObject cdoH = (CommonDataObject)SQLMgr.getData("select cf.almacen, cf.anio, cf.codigo_anaquel codigoAnaquel, cf.consecutivo, to_char(cf.fecha_conteo,'dd/mm/yyyy')fechaConteo, cf.observaciones, nvl(cf.asiento_sino,'N')asientoSino, decode(cf.estatus,'P','PENDIENTE (POR ACTUALIZAR)','A','ACTIVO (ULTIMO CONTEO ACTUALIZADO)','I','INACTIVO (INV.ANTERIORES YA ACTUALIZADOS)','N','ANULADO (ANULAR INVENTARIO FISICO)','C','NUEVA LISTA') estatus, cf.estatus estatus_hd, al.descripcion descAlmacen ,aa.descripcion descAnaquel from tbl_inv_conteo_fisico cf,tbl_inv_almacen al,tbl_inv_anaqueles_x_almacen aa where cf.compania= "+(String) session.getAttribute("_companyId")+_filter+" and cf.consecutivo = "+consecutivo+" and cf.anio = "+anio+" and cf.almacen = "+almacen+" and codigo_anaquel = "+anaquely);
	   if (cdoH==null) cdoH = new CommonDataObject();
	    
		sbSql.append("select  df.cf1_anio  cf1Anio, df.almacen cod_almacen, df.anaquel cod_anaquel,df.cf1_consecutivo||'-'||df.cf1_anio consecutivo, df.cod_familia codFamilia, df.cod_clase codClase, a.cod_flia ||'-'||a.cod_clase ||'-'|| a.cod_articulo cod_articulos, df.cod_familia ||'-'|| df.cod_clase ||'-'|| df.cod_articulo codigo ,nvl(df.cantidad_sistema,0) cantidad_sistema, nvl(df.cantidad_contada,0) cantidad_contada, nvl(df.observaciones,' ') observaciones, nvl(df.cantidad_sistema,0) disponible,nvl(df.precio,0)precio,a.descripcion desc_articulo,a.cod_medida as codMedida, to_char(nvl(df.cantidad_sistema,0)* nvl(df.precio,0),'999999990.00') valExistencia, a.cod_barra ,nvl(df.cantidad_contada,0) - nvl(df.cantidad_sistema,0) as dif_cantidad, (df.cantidad_contada* nvl(i.precio,0)) - (df.cantidad_sistema* nvl(i.precio,0)) diferencia, nvl(df.precio,0) * nvl(df.cantidad_contada,0) as monto_fisico from tbl_inv_detalle_fisico df,tbl_inv_inventario i, tbl_inv_articulo a where df.cf1_anio = "+anio+" and df.cf1_consecutivo= "+consecutivo+"  and df.cod_articulo =i.cod_articulo and a.cod_articulo =df.cod_articulo and a.compania = i.compania and i.compania =  "+(String) session.getAttribute("_companyId")+" and i.codigo_almacen = df.almacen and df.almacen ="+almacen+" order by a.descripcion" );

al = SQLMgr.getDataList(sbSql.toString());

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
		
	boolean isLandscape = true;
	if (cdoH.getColValue("estatus_hd")!=null && ( cdoH.getColValue("estatus_hd").equalsIgnoreCase("P") || cdoH.getColValue("estatus_hd").equalsIgnoreCase("C")  ) ){isLandscape = false;}
	
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "CONTEO FISICO "+((!estado.trim().equals("A"))?"":" (DIFERENCIA ENTRE INVENTARIO FISICO VS. SISTEMA)");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".07");
		dHeader.addElement(".12");
		dHeader.addElement(".25");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".10");
		
		dHeader.addElement(".06");
		
		dHeader.addElement(".13");
		dHeader.addElement(".13");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		//second row
		
		pc.setFont(fontSize,1);
		pc.addCols("Inventario No: "+cdoH.getColValue("anio")+" - "+cdoH.getColValue("consecutivo"),0,2);
		pc.addCols("Estatus del registro: "+cdoH.getColValue("estatus"),0,6);
		pc.addCols("Fecha: "+cdoH.getColValue("fechaConteo"),0,1);
		pc.addCols("Anaquel: "+cdoH.getColValue("descAnaquel"),0,6);
		pc.addCols("Almacén: ["+cdoH.getColValue("almacen")+"] "+cdoH.getColValue("descAlmacen"),0,3);
		pc.addCols("",0,dHeader.size());
		

		pc.setFont(fontSize,1);
		
		if (cdoH.getColValue("estatus_hd")!=null && ( cdoH.getColValue("estatus_hd").equalsIgnoreCase("P") || cdoH.getColValue("estatus_hd").equalsIgnoreCase("C")  ) ){
		    pc.addBorderCols("Código",0,2);
		    pc.addBorderCols("Código de Barra",0,1);
		    pc.addBorderCols("Articulo "+cdoH.getColValue("estatus_hd"),0,5);
			pc.addBorderCols("Conteo",2,1);
		}else{
		   pc.addBorderCols("Código",0,1);
		   pc.addBorderCols("Código de Barra",0,1);
		   pc.addBorderCols("Articulo "+cdoH.getColValue("estatus_hd"),0,1);
		   pc.addBorderCols("Sistema",2,1);
		   pc.addBorderCols("Conteo",2,1);
		   pc.addBorderCols("Dif. Unidades",2,1);
		   pc.addBorderCols("CostoP.",2,1);
		   pc.addBorderCols("Monto Fis.",2,1);
		   pc.addBorderCols("Dif. Monto",2,1);
		}

		pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	//table body
	String groupBy="",groupBy2="";
	double total = 0.00,sub_total = 0.00, totalFisico = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) al.get(i);

		if(i==0)
		{
			pc.setFont(fontSize, 0,Color.blue);
			//pc.addCols(" [ "+cdo1.getColValue("cod_almacen")+" ] "+cdo1.getColValue("desc_almacen"),0,dHeader.size());
		}

		if (!groupBy2.equalsIgnoreCase(cdo1.getColValue("consecutivo")))
	    {
			//pc.setFont(8, 0,Color.red);
			//pc.addCols("Conteo No: "+cdo1.getColValue("consecutivo"),0,dHeader.size());
		}
		if (!groupBy.equalsIgnoreCase(cdo1.getColValue("cod_almacen")+"-"+cdo1.getColValue("cod_anaquel")))
	    {
			//pc.setFont(8, 0,Color.blue);
			//pc.addCols(" [ "+cdo1.getColValue("cod_anaquel")+" ] "+cdo1.getColValue("desc_anaquel"),0,dHeader.size());
		}

		if(!cdo1.getColValue("dif_cantidad").trim().equals("0"))pc.setFont(fontSize-1,0,Color.red);
		else pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
	
		if (cdoH.getColValue("estatus_hd")!=null && ( cdoH.getColValue("estatus_hd").equalsIgnoreCase("P") || cdoH.getColValue("estatus_hd").equalsIgnoreCase("C")  ) ){
		   pc.addCols(" "+cdo1.getColValue("cod_articulos"), 0,2);
		   pc.addCols(" "+cdo1.getColValue("cod_barra"), 0,1);
		   pc.addCols(" "+cdo1.getColValue("desc_articulo"), 0,5);
		   pc.addCols(" "+cdo1.getColValue("cantidad_contada"), 2,1);
		}else{
		   pc.addCols(" "+cdo1.getColValue("cod_articulos"), 0,1);
		   pc.addCols(" "+cdo1.getColValue("cod_barra"), 0,1);
		   pc.addCols(" "+cdo1.getColValue("desc_articulo"), 0,1);
		   pc.addCols(" "+cdo1.getColValue("cantidad_sistema"), 2,1);
		   pc.addCols(" "+cdo1.getColValue("cantidad_contada"), 2,1);
		   pc.addCols(" "+cdo1.getColValue("dif_cantidad"), 2,1);
		
		   pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("precio")), 2,1);
		
		   pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo1.getColValue("monto_fisico")), 2,1);
		   pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,##0.0000",cdo1.getColValue("diferencia")), 2,1);
		}

		total +=  Double.parseDouble(cdo1.getColValue("diferencia"));
		totalFisico +=  Double.parseDouble(cdo1.getColValue("monto_fisico"));
		groupBy = cdo1.getColValue("cod_almacen")+"-"+cdo1.getColValue("cod_anaquel");
		groupBy2 = cdo1.getColValue("consecutivo");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{
	     if (cdoH.getColValue("estatus_hd")!=null && ( cdoH.getColValue("estatus_hd").equalsIgnoreCase("P") || cdoH.getColValue("estatus_hd").equalsIgnoreCase("C")  ) ){}
		 else{
		    pc.setFont(8, 1,Color.blue);
			pc.addCols("Total: ",2,7);
			pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",totalFisico),2,1);
			pc.addCols("$"+CmnMgr.getFormattedDecimal("###,###,##0.00",total),2,1);
		 }
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>