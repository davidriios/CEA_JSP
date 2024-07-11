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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo   = new CommonDataObject();

String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
String tipoFecha = request.getParameter("tipoFecha");
String fp				       = request.getParameter("fp");
String consignacion				       = request.getParameter("consignacion");
String comprob = request.getParameter("comprob");
String afectaConta = request.getParameter("afectaConta");
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}

StringBuffer sbSql = new StringBuffer();
if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (tipoServicio == null) tipoServicio = "";
if (aseguradora == null) aseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (ts == null) ts = "";
if (fg == null) fg = "";
if (tipoFecha == null) tipoFecha = "";
if (fp == null) fp = "";
if (consignacion == null) consignacion = "";
if (comprob == null) comprob = "";
if (afectaConta == null) afectaConta = "";

StringBuffer appendFilter1 = new StringBuffer();
//--------------Parámetros--------------------//
if (!fechaini.equals(""))
   {
   	if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and fdt.fecha_cargo >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy hh12:mi am')");
   	} else {
			appendFilter1.append(" and to_date(to_char(fdt.fecha_hora_creacion,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy hh12:mi am')");
		}
   }
if (!fechafin.equals(""))
   {
		if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and fdt.fecha_cargo <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy hh12:mi am')");
   	} else {
			appendFilter1.append(" and to_date(to_char(fdt.fecha_hora_creacion,'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy hh12:mi am')");
		}
   }
if (!centroServicio.equals(""))
   {
    if(cdsDet.trim().equals("S")){
			appendFilter1.append(" and fdt.centro_servicio = ");
			appendFilter1.append(centroServicio); 
		} else {
			appendFilter1.append(" and ft.centro_servicio = ");
			appendFilter1.append(centroServicio);
		}
	 }
if (!compania.equals(""))
  {
   appendFilter1.append(" and fdt.compania = ");
	 appendFilter1.append(compania);
  }
if (!categoria.equals(""))
   {
   	appendFilter1.append(" and aa.categoria = ");
		appendFilter1.append(categoria);
   }
if (!ts.equals(""))
   {
   	appendFilter1.append(" and fdt.tipo_cargo = '");
		appendFilter1.append(ts);
		appendFilter1.append("'");
   }
if(!consignacion.equals(""))
{
appendFilter1.append(" and ar.consignacion_sino ='");
appendFilter1.append(consignacion);
appendFilter1.append("'"); 
}
if(!comprob.equals(""))
{
appendFilter1.append(" and nvl(fdt.comprobante,'N') ='");
appendFilter1.append(comprob);
appendFilter1.append("'"); 
}
 
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos---------------------------------//
sbSql.append(" select all c.descripcion as centroServicio, fdt.tipo_cargo as tipoCargo, fdt.descripcion as descCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)) cantTransaccion, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.monto, 0)) montoCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.recargo, 0)) montoRecargo,0 montoCosto from tbl_fac_transaccion ft,  tbl_fac_detalle_transaccion fdt, vw_adm_paciente p, tbl_adm_admision aa, tbl_cds_centro_servicio c where fdt.fac_codigo=ft.codigo and fdt.fac_secuencia=ft.admi_secuencia  and fdt.pac_id=ft.pac_id  and fdt.compania=ft.compania  and fdt.tipo_transaccion=ft.tipo_transaccion  and aa.pac_id = ft.pac_id and aa.secuencia = ft.admi_secuencia  and ft.pac_id = p.pac_id ");
if(cdsDet.trim().equals("S"))sbSql.append(" and fdt.centro_servicio = c.codigo ");
else sbSql.append(" and ft.centro_servicio = c.codigo ");
sbSql.append(appendFilter1.toString());
sbSql.append(" group by c.descripcion, fdt.tipo_cargo,  fdt.descripcion order by c.descripcion");



al = SQLMgr.getDataList(sbSql.toString());

	 
sbSql.append(" group by f.codigo, f.admi_secuencia, f.pac_id, df.centro_servicio");	 
if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam")+".pdf";

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
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
	String subtitle = "";
	if(fg.trim().equals("COSTO"))title = "COSTO EN CONSUMO DE PACIENTES ";
	else title = "CONSUMO - DETALLE DE CARGOS Y DEV. A PACIENTES";
	
	if(fg.trim().equals("COSTO"))
		if(fp.trim().equals("COSTOPAC"))title += " POR CENTRO";
		else if(fp.trim().equals("COSTOINV"))title += " POR ALMACEN";
	
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".70");
		dHeader.addElement(".15");

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

	pc.addBorderCols("T.Cargo",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Descripción del Cargo",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Cantidad",1,1,cHeight,Color.lightGray);

	String groupByCentro	= "";		// para agrupar por centro servicio.
	int		 centroCant 		= 0, 	finalCant 		= 0;
	
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		// Agrupar por grupo de aseguradora
		if (!groupByCentro.trim().equalsIgnoreCase(cdo.getColValue("centroServicio")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0)  // imprime total de pacte
					{
						// consumo de la aseguradora
						pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,2);
						pc.addCols(String.valueOf(centroCant),1,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols(cdo.getColValue("centroServicio"),0,dHeader.size());
					centroCant 		= 0;
					groupByCentro 	= "";
		}

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("tipoCargo"),0,1);
		pc.addCols(cdo.getColValue("descCargo"),0,1);
		pc.addCols(cdo.getColValue("cantTransaccion"),1,1);
		
		centroCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		finalCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		groupByCentro	= cdo.getColValue("centroServicio");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{

			pc.setFont(8, 1,Color.black);
			// consumo del centro
			pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,2);
			pc.addCols(String.valueOf(centroCant),1,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// consumo final
			pc.addCols("T O T A L E S   F I N A L E S . . . . . ",2,2);
			pc.addCols(String.valueOf(finalCant),1,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
