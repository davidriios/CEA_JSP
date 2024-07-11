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
<jsp:useBean id="htDesc" scope="page" class="java.util.Hashtable" />
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
String usar_fecha_fact = request.getParameter("usar_fecha_fact");
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
if (usar_fecha_fact == null) usar_fecha_fact = "N";

StringBuffer appendFilter1 = new StringBuffer();
//--------------Parámetros--------------------//
if (!fechaini.equals("") && usar_fecha_fact.equals("N"))
   {
   	if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and trunc(fdt.fecha_cargo) >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy')");
   	} else {
			appendFilter1.append(" and fdt.fecha_creacion >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy')");
		}
   }
if (!fechafin.equals("") && usar_fecha_fact.equals("N"))
   {
		if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and trunc(fdt.fecha_cargo) <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy')");
   	} else {
			appendFilter1.append(" and fdt.fecha_creacion <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy')");
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
sbSql.append(" select all c.codigo centro_servicio, c.descripcion as centroServicio, p.nombre_paciente as nombrePaciente, ft.pac_id||' - '||ft.admi_secuencia as codigoPaciente, fdt.usuario_creacion, to_char(fdt.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, to_char(fdt.fecha_cargo,'dd/mm/yyyy') as fechaCargo, fdt.tipo_cargo as tipoCargo, fdt.descripcion as descCargo, decode(ca.adm_type, 'I', 'HOSPITALIZADO', 'NO HOSPITALIZADO') adm_type, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)) cantTransaccion, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.monto, 0)) montoCargo, sum(nvl(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad),0)*nvl(fdt.recargo, 0)) montoRecargo,0 montoCosto from tbl_fac_transaccion ft,  tbl_fac_detalle_transaccion fdt, vw_adm_paciente p, tbl_adm_admision aa, tbl_cds_centro_servicio c, tbl_adm_categoria_admision ca where exists (select null from tbl_fac_factura f where f.estatus != 'A' and f.compania = ft.compania and f.admi_secuencia = ft.admi_secuencia and f.pac_id = ft.pac_id");
if(!fechaini.equals("") && usar_fecha_fact.equals("S")){
		sbSql.append(" and trunc(f.fecha) >= to_date('");
		sbSql.append(fechaini);
		sbSql.append("', 'dd/mm/yyyy')");
}
if(!fechafin.equals("") && usar_fecha_fact.equals("S")){
	sbSql.append(" and trunc(f.fecha) <= to_date('");
	sbSql.append(fechafin);
	sbSql.append("', 'dd/mm/yyyy')");
}
sbSql.append(") and fdt.fac_codigo=ft.codigo and fdt.fac_secuencia=ft.admi_secuencia  and fdt.fac_fecha_nacimiento=ft.admi_fecha_nacimiento  and fdt.fac_codigo_paciente=ft.admi_codigo_paciente  and fdt.compania=ft.compania  and fdt.tipo_transaccion=ft.tipo_transaccion  and aa.fecha_nacimiento = ft.admi_fecha_nacimiento  and aa.codigo_paciente = ft.admi_codigo_paciente  and aa.secuencia = ft.admi_secuencia and aa.categoria = ca.codigo  and ft.admi_codigo_paciente = p.codigo  and ft.admi_fecha_nacimiento = p.fecha_nacimiento");
if(cdsDet.trim().equals("S"))sbSql.append(" and fdt.centro_servicio = c.codigo ");
else sbSql.append(" and ft.centro_servicio = c.codigo ");
sbSql.append(appendFilter1.toString());
sbSql.append("   group by c.codigo, c.descripcion, p.nombre_paciente,ft.pac_id||' - '||ft.admi_secuencia, fdt.usuario_creacion, fdt.fecha_creacion, fdt.fecha_cargo, fdt.tipo_cargo,  fdt.descripcion, decode(ca.adm_type, 'I', 'HOSPITALIZADO', 'NO HOSPITALIZADO') order by decode(ca.adm_type, 'I', 'HOSPITALIZADO', 'NO HOSPITALIZADO'), c.descripcion,p.nombre_paciente, ft.pac_id||' - '||ft.admi_secuencia, fdt.fecha_creacion ");

al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();

sbSql.append("select f.codigo, f.admi_secuencia, f.pac_id, df.centro_servicio, (select e.nombre from tbl_adm_empresa e where e.codigo = f.cod_empresa) aseguradora, sum(nvl(df.descuento, 0)+nvl(df.descuento2, 0)) descuento from tbl_fac_factura f, tbl_fac_detalle_factura df where f.codigo = df.fac_codigo and f.compania = df.compania and f.facturar_a in ('P', 'E') and f.estatus != 'A' and nvl(df.descuento, 0)+nvl(df.descuento2, 0) > 0 and exists (select null from tbl_fac_detalle_transaccion fdt where f.compania = fdt.compania and f.admi_secuencia = fdt.fac_secuencia and f.pac_id = fdt.pac_id");
if (!fechaini.equals(""))
   {
   	if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and trunc(fdt.fecha_cargo) >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy')");
   	} else {
			appendFilter1.append(" and trunc(fdt.fecha_creacion) >= to_date('");
			appendFilter1.append(fechaini);
			appendFilter1.append("', 'dd/mm/yyyy')");
		}
   }
if (!fechafin.equals(""))
   {
		if(tipoFecha.trim().equals("C")){
			appendFilter1.append(" and trunc(fdt.fecha_cargo) <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy')");
   	} else {
			appendFilter1.append(" and trunc(fdt.fecha_creacion) <= to_date('");
			appendFilter1.append(fechafin);
			appendFilter1.append("', 'dd/mm/yyyy')");
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
	 
sbSql.append(") group by f.codigo, f.admi_secuencia, f.pac_id, df.centro_servicio, f.cod_empresa");	 

ArrayList alDesc = SQLMgr.getDataList(sbSql.toString());
for(int i=0;i<alDesc.size();i++){
	CommonDataObject cd = (CommonDataObject) alDesc.get(i);
	htDesc.put(cd.getColValue("pac_id")+" - "+cd.getColValue("admi_secuencia")+" - "+cd.getColValue("centro_servicio"), cd);
}

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
	title = "CONSUMO - DETALLE DE CARGOS Y DEV. A PACIENTES";
	

	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".08");
		dHeader.addElement(".05");
		dHeader.addElement(".45");
		dHeader.addElement(".06");
		dHeader.addElement(".12");
		dHeader.addElement(".12");
		
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

	pc.addBorderCols("F.Creación",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("F.Cargo",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Usuario",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("T.Cargo",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Descripción del Cargo",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Cantidad",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Monto Cargo",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Monto Recargo",1,1,cHeight,Color.lightGray);
	String groupByCentro	= "";		// para agrupar por centro servicio.
	String groupByPacte		= "";		// para agrupar por paciente
	String groupByFlia 		= "";		// para agrupar por Familia	
	double centroCargo 		= 0,pacteCargo= 0,finalCargo= 0;	// para el monto de cargos
	double centroRecargo 	= 0,  pacteRecargo 	= 0, 	finalRecargo 	= 0;	// para el monto de recargos
	double pacteCosto=0,centroCosto=0,finalCosto=0;//Para costo de articulos...
	int		 centroCant 		= 0, 	pacteCant 		= 0, 	finalCant 		= 0,fliaCant=0;
	double fliaCargo = 0,fliaRecargo = 0,fliaCosto= 0;
	double descuento = 0.00;
	String key = "", adm_type = "";
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		/*if (!adm_type.trim().equalsIgnoreCase(cdo.getColValue("adm_type"))){
			pc.setFont(8, 1,Color.blue);
			pc.addBorderCols(cdo.getColValue("adm_type"),1,dHeader.size(),cHeight);
		}*/
		// Agrupar por grupo de aseguradora
		if (!groupByCentro.trim().equalsIgnoreCase(cdo.getColValue("centroServicio")))
		{
					
					if (i != 0)  // imprime total de pacte
					{
						if(htDesc.containsKey(key)){
							CommonDataObject _cd = (CommonDataObject) htDesc.get(key);
							pc.setFont(8, 1,Color.red);
							pc.addCols("Factura: "+_cd.getColValue("codigo"),0,2);
							pc.addCols("["+ _cd.getColValue("aseguradora") + "]",0,3);
							pc.addCols("Desc.:",2,1);
							pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",_cd.getColValue("descuento")),2,1);
							pc.addCols("",2,1);
							descuento = Double.parseDouble(_cd.getColValue("descuento"));
							pacteCargo -= descuento;
							
						}
						
						pc.setFont(8, 1,Color.black);

						// total de cargos por paciente
						pc.addCols("TOTAL POR PACIENTE. . . . . ",2,5);
						pc.addCols(String.valueOf(pacteCant),1,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCargo),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteRecargo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
						
						
						// consumo de la aseguradora
						pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,5);
						pc.addCols(String.valueOf(centroCant),1,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroCargo),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroRecargo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }
					
					pc.setFont(8, 1,Color.black);

					pc.addCols(cdo.getColValue("centroServicio"),0,dHeader.size());
					centroCargo 	= 0;
					centroRecargo   = 0;
					centroCant 		= 0;
					centroCosto	    = 0;
					// para acumular totales del paciente
					pacteCargo 		= 0;
					pacteRecargo 	= 0;
					pacteCant 		= 0;
					pacteCosto      = 0;
					// para acumular totales del Familia
					fliaCargo 		= 0;
					fliaRecargo 	= 0;
					fliaCant 		= 0;
					fliaCosto       = 0;				
					
					groupByCentro 	= "";
					groupByPacte	= "";
					groupByFlia     = "";
		}
		
		// Agrupar Paciente
		if (!groupByPacte.trim().equalsIgnoreCase(cdo.getColValue("nombrePaciente")+" - "+cdo.getColValue("codigoPaciente")))
		{
					
					if (i != 0 && !groupByPacte.trim().equalsIgnoreCase(""))  // imprime total de pacte
					{
						if(htDesc.containsKey(key)){
							CommonDataObject _cd = (CommonDataObject) htDesc.get(key);
							pc.setFont(8, 1,Color.red);
							pc.addCols("Factura: "+_cd.getColValue("codigo"),0,2);
							pc.addCols("["+ _cd.getColValue("aseguradora") + "]",0,3);
							pc.addCols("Desc.:",2,1);
							pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",_cd.getColValue("descuento")),2,1);
							pc.addCols("",2,1);
							descuento = Double.parseDouble(_cd.getColValue("descuento"));
							pacteCargo -= descuento;
						}
					pc.setFont(8, 1,Color.black);
						// total de cargos por paciente
						pc.addCols("TOTAL POR PACIENTE. . . . . ",2,5);
						pc.addCols(String.valueOf(pacteCant),1,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCargo),2,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteRecargo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
						
				  }

					pc.addCols(cdo.getColValue("nombrePaciente"),0,5);
					pc.addCols("Admision: "+cdo.getColValue("codigoPaciente"),0,3);
					// para acumular totales del paciente
					pacteCargo 		= 0;
					pacteRecargo 	= 0;
					pacteCant 		= 0;
					pacteCosto 		= 0;
					groupByPacte		= "";
		}

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("fechaCreacion"),0,1);
		pc.addCols(cdo.getColValue("fechaCargo"),0,1);
		pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
		pc.addCols(cdo.getColValue("tipoCargo"),0,1);
		pc.addCols(cdo.getColValue("descCargo"),0,1);
		pc.addCols(cdo.getColValue("cantTransaccion"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("montoCargo"))),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("montoRecargo"))),2,1);
		
		pacteCargo 		+= Double.parseDouble(cdo.getColValue("montoCargo")) - descuento;
		finalCargo 		+= Double.parseDouble(cdo.getColValue("montoCargo")) - descuento;
		centroCargo 	+= Double.parseDouble(cdo.getColValue("montoCargo")) - descuento;
		
		pacteRecargo 	+= Double.parseDouble(cdo.getColValue("montoRecargo"));
		centroRecargo   += Double.parseDouble(cdo.getColValue("montoRecargo"));
		finalRecargo 	+= Double.parseDouble(cdo.getColValue("montoRecargo"));
		
		pacteCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		centroCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		finalCant 		+= Integer.parseInt(cdo.getColValue("cantTransaccion"));
		
		groupByCentro	= cdo.getColValue("centroServicio");
		groupByPacte 	= cdo.getColValue("nombrePaciente")+" - "+cdo.getColValue("codigoPaciente");
		groupByFlia     = cdo.getColValue("descFlia")+"-"+cdo.getColValue("centroServicio");
		
		key = cdo.getColValue("codigopaciente")+" - "+cdo.getColValue("centro_servicio");
		adm_type = cdo.getColValue("adm_type");
		descuento = 0.00;

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{

			pc.setFont(8, 1,Color.black);
			// total de cargos por paciente
			pc.addCols("TOTAL POR PACIENTE. . . . . ",2,5);
			pc.addCols(String.valueOf(pacteCant),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteCargo),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",pacteRecargo),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			
			// consumo del centro
			pc.addCols("TOTAL POR "+groupByCentro+" . . . . . ",2,5);
			pc.addCols(String.valueOf(centroCant),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroCargo),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centroRecargo),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// consumo final
			pc.addCols("T O T A L E S   F I N A L E S . . . . . ",2,5);
			pc.addCols(String.valueOf(finalCant),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalCargo),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalRecargo),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
