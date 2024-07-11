<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
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
CommonDataObject cdo   = new CommonDataObject();

StringBuffer sql  = new StringBuffer();
String appendFilter 	 = request.getParameter("appendFilter");
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String userName 			 = UserDet.getUserName();  /*quitar el comentario * */
String compania 			 = (String) session.getAttribute("_companyId");
String categoria       = request.getParameter("categoria");
String centroServicio  = request.getParameter("area");
String aseguradora  	 = request.getParameter("aseguradora");
String tipoServicio  	 = request.getParameter("tipoServicio");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String ts				       = request.getParameter("ts");
String fg				       = request.getParameter("fg");
String consignacion				       = request.getParameter("consignacion");
String tipoFecha				       = request.getParameter("tipoFecha");
String comprob = request.getParameter("comprob");
String afectaConta = request.getParameter("afectaConta");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String descAseg = request.getParameter("pDescAseg");


String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}
String codFlia = request.getParameter("codFlia");
String wh = request.getParameter("wh");
String aseg = request.getParameter("pAseguradora");
if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (tipoServicio == null) tipoServicio = "";
if (aseguradora == null) aseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (ts == null) ts = "";
if (consignacion == null) consignacion = "";
if (tipoFecha == null) tipoFecha = "";
if (comprob == null) comprob = "";
if (afectaConta == null) afectaConta = "";
if (codFlia == null)     codFlia       = "";
if (wh == null)     wh       = "";
if (pacId == null)pacId= "";
if (admision == null)admision= "";
if (aseg == null)aseg= "";
if (descAseg == null)descAseg= "";

String appendFilter1 = "";
//--------------Parámetros--------------------//
//
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos---------------------------------//
sql.append("select fdt.tipo_cargo , fdt.codigo_almacen ,sum(round (decode(fdt.tipo_transaccion,'C',(fdt.cantidad * decode(nvl(fdt.costo_art,0),0,inv.precio,fdt.costo_art)),'D',-1*(fdt.cantidad*decode(nvl(fdt.costo_art,0),0,inv.precio,fdt.costo_art))),2)) monto_costo,nvl((select getMapingCta('CARGDEVCOST',fdt.compania,fdt.centro_servicio,fdt.tipo_cargo,'-','-',fdt.adm_type)  from dual),'S/C') as cuenta,a.descripcion ,fdt.art_familia||'-'||fdt.art_clase||'-'||fdt.inv_articulo codArticulo,(select descripcion from tbl_inv_almacen where codigo_almacen = fdt.codigo_almacen and compania=fdt.compania ) descAlmacen,(select nombre from tbl_inv_familia_articulo where compania = fdt.compania and cod_flia =fdt.art_familia )descFamilia,fdt.art_familia familia from (select dt.tipo_cargo , dt.inv_almacen codigo_almacen , dt.tipo_transaccion,dt.cantidad,dt.costo_art,dt.estatus_cargo,dt.art_familia,dt.art_clase ,dt.inv_articulo,dt.compania,");
if(cdsDet.trim().equals("S"))sql.append("dt.");
else sql.append("ft.");
sql.append("centro_servicio,dt.comprobante,dt.fecha_creacion,ft.adm_type from tbl_fac_detalle_transaccion dt, tbl_fac_transaccion ft  where  (dt.tipo_transaccion= ft.tipo_transaccion and  dt.compania   = ft.compania and  dt.pac_id = ft.pac_id and  dt.fac_secuencia = ft.admi_secuencia and  dt.fac_codigo = ft.codigo)");
if (!fechaini.equals(""))
{
	if(tipoFecha.trim().equals("C"))sql.append(" and trunc(dt.fecha_cargo) >= to_date('");
	else sql.append(" and dt.fecha_creacion  >= to_date('");
	sql.append(fechaini);
	sql.append("', 'dd/mm/yyyy')");
}
if (!fechafin.equals(""))
{
	if(tipoFecha.trim().equals("C"))sql.append(" and trunc(dt.fecha_cargo) <= to_date('");
	else sql.append(" and dt.fecha_creacion <= to_date('");
	sql.append(fechafin);
	sql.append("', 'dd/mm/yyyy')");
}
if(!afectaConta.trim().equals("")){sql.append(" and dt.afecta_conta = '");sql.append(afectaConta);sql.append("'");}

if (!aseg.equals("")){ 
	sql.append("and exists (select 'x' from tbl_adm_beneficios_x_admision aba where aba.prioridad = 1 and nvl (aba.estado, 'A') = 'A'");
	sql.append(" and aba.pac_id = dt.pac_id and aba.admision = dt.fac_secuencia  and rownum = 1 and aba.empresa = ");
	sql.append(aseg);
	sql.append(" ) ");
}

if (!pacId.equals(""))
{
sql.append(" and dt.pac_id =");
sql.append(pacId); 
}
if (!admision.equals(""))
{
sql.append(" and dt.fac_secuencia =");
sql.append(admision); 
}

if (!ts.equals(""))
{
sql.append(" and dt.tipo_cargo = '");
sql.append(ts);
sql.append("'");
}
if (!centroServicio.equals(""))
{
if(cdsDet.trim().equals("S"))sql.append(" and dt.centro_servicio = ");
else sql.append(" and ft.centro_servicio = ");
sql.append(centroServicio);
}
if(!wh.trim().equals("")){sql.append(" and dt.inv_almacen = ");sql.append(wh);}
if(!codFlia.trim().equals("")){sql.append(" and dt.art_familia  = ");sql.append(codFlia);}

sql.append(" and dt.compania = ");
sql.append(compania);
sql.append(" and dt.tipo_transaccion in ('C','D') )fdt, tbl_inv_articulo a, tbl_cds_centro_servicio cds, tbl_inv_inventario inv where (fdt.inv_articulo  = a.cod_articulo and  fdt.compania= a.compania) and ( inv.cod_articulo  = a.cod_articulo and  inv.compania= a.compania and inv.codigo_almacen= fdt.codigo_almacen )  and  fdt.centro_servicio = cds.codigo ");


if(!consignacion.trim().equals(""))
{
sql.append(" and a.consignacion_sino ='");
sql.append(consignacion);
sql.append("'"); 
}
if(!comprob.trim().equals(""))
{
sql.append(" and nvl(fdt.comprobante,'N') ='");
sql.append(comprob);
sql.append("'"); 
}

sql.append(" having sum(round (decode(fdt.tipo_transaccion,'C',(fdt.cantidad*decode(nvl(fdt.costo_art,0),0,inv.precio,fdt.costo_art)) ,'D',-1*(fdt.cantidad*decode(nvl(fdt.costo_art,0),0,inv.precio,fdt.costo_art))),2)) <>0 group by fdt.adm_type,fdt.tipo_cargo,fdt.codigo_almacen,a.descripcion ,fdt.art_familia, fdt.art_familia||'-'||fdt.art_clase||'-'||fdt.inv_articulo,a.compania,fdt.centro_servicio,fdt.compania order by fdt.codigo_almacen,fdt.art_familia,a.descripcion,4 asc ");

al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+time+".pdf";

  if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

  String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
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
	String title = "FACTURACION";
	String subtitle = "COSTOS DE CONSUMO  DE PACIENTES - INVENTARIO";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin+"    -     "+descAseg;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".25");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(7, 1);
	pc.setTableHeader(2);

	pc.addBorderCols("ALMACEN",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("FAMILIA",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("T.CARGO",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("CODIGO",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("NOMBRE",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("COSTO",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("CUENTA",1,1,cHeight,Color.lightGray);

	String groupByWh	= "";		// para agrupar por almacen.
	String groupByFlia	= "";		// para agrupar por Familia
	double centroCargo 		= 0,  pacteCargo 		= 0, 	finalCargo 		= 0,fliaCosto=0,whCosto=0;	// para el monto de cargos
	double total  	= 0,  pacteRecargo 	= 0, 	finalRecargo 	= 0;	// para el monto de recargos
	int		 centroCant 		= 0, 	pacteCant 		= 0, 	finalCant 		= 0;
	for (int i=0; i<al.size(); i++)
	{
    	cdo = (CommonDataObject) al.get(i);
		
		if (!groupByWh.trim().equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
		{
			pc.setFont(8, 1,Color.black);
			if(i!=0){
			pc.addCols("TOTAL POR FAMILIA. . . . . ",2,5);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCosto),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			
			pc.addCols("TOTAL POR ALMACEN. . . . . ",2,5);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",whCosto),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			groupByFlia ="";}
			
			pc.addCols(" "+cdo.getColValue("descAlmacen"),0,dHeader.size());
			whCosto =0;
			fliaCosto =0;
			
		}
		if (!groupByFlia.trim().equalsIgnoreCase(cdo.getColValue("familia")))
		{
			pc.setFont(8, 1,Color.black);
			if(i!=0 && !groupByFlia.trim().equals("")){
			pc.addCols("TOTAL POR FAMILIA. . . . . ",2,5);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCosto),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			
			}
			pc.addCols(" ",0,1);
			pc.addCols(" "+cdo.getColValue("descFamilia"),0,dHeader.size()-1);
			groupByFlia ="";
			fliaCosto =0;
		}
		
						
		pc.setFont(7, 0);
		//pc.addCols(cdo.getColValue("descAlmacen"),0,1);
		pc.addCols(" ",0,2);
		pc.addCols(cdo.getColValue("tipo_cargo"),0,1);
		pc.addCols(cdo.getColValue("codArticulo"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("monto_costo"))),2,1);
		pc.addCols(""+cdo.getColValue("cuenta"),0,1);

		total 		+= Double.parseDouble(cdo.getColValue("monto_costo"));
		fliaCosto 	+= Double.parseDouble(cdo.getColValue("monto_costo"));
		whCosto 	+= Double.parseDouble(cdo.getColValue("monto_costo"));
		
		groupByFlia = cdo.getColValue("familia");
		groupByWh = cdo.getColValue("codigo_almacen");
		
	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.setFont(8, 1,Color.black);
			pc.addCols("TOTAL POR FAMILIA. . . . . ",2,5);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",fliaCosto),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.addCols("TOTAL POR ALMACEN. . . . . ",2,5);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",whCosto),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			
			pc.setFont(8, 1,Color.black);
			// total de cargos por paciente
			pc.addCols("TOTAL  FINAL . . . . . ",2,5);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",total),2,1);
			pc.addCols(" ",0,1);

	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
