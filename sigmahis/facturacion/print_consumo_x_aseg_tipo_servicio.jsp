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
<!-- Desarrollado por: Tirza Monteza.                          -->
<!-- Reporte: Consumo de Paciente x Aseguradora-Tipo Servicio  -->
<!-- Reporte: FAC10010                                         -->
<!-- Clínica Hospital San Fernando                             -->
<!-- Fecha:  23/08/2010                                        -->

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
String fg				       = request.getParameter("fg");

if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (tipoServicio == null) tipoServicio = "";
if (aseguradora == null) aseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and fdt.compania = "+compania;
  }
if (!centroServicio.equals(""))
   {
    appendFilter1 += " and ft.centro_servicio = "+centroServicio;
	 }
if (!fechaini.equals(""))
   {
  	appendFilter1 += " and fdt.fecha_creacion >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
		appendFilter1 += " and fdt.fecha_creacion <= to_date('"+fechafin+"', 'dd/mm/yyyy')";
   }
if (!categoria.equals(""))
   {
   	appendFilter1 += " and aa.categoria = "+categoria;
   }
if (!aseguradora.equals(""))
   {
	 	appendFilter1 += " and aba.empresa = "+aseguradora;
	 }
if (!tipoServicio.equals(""))
   {
	 	appendFilter1 += " and fdt.tipo_cargo = '"+tipoServicio+"'";
	 }

//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos---------------------------------//
sql = " select z.* from (select ae.nombre dspempresa, ct.descripcion dsptipocargo, to_char(fdt.fac_fecha_nacimiento,'dd/mm/yyyy')||'( '||fdt.fac_codigo_paciente||' - '||fdt.fac_secuencia||' )' codigoPaciente, ap.primer_nombre||' '||ap.segundo_nombre||' '||decode(ap.apellido_de_casada,null,ap.primer_apellido||' '||ap.segundo_apellido,ap.apellido_de_casada) nombrPaciente,  decode(ap.pasaporte,null,ap.provincia||'-'||ap.sigla||'-'||ap.tomo||'-'||ap.asiento||'-'||ap.d_cedula,ap.pasaporte) noId, nvl(sum(decode(fdt.tipo_transaccion,'D',fdt.cantidad*-1,fdt.cantidad)*(fdt.monto+nvl(fdt.recargo,0))),0)  totalConsumo  from tbl_fac_detalle_transaccion fdt,  tbl_fac_transaccion ft ,tbl_adm_beneficios_x_admision aba,  tbl_adm_paciente ap,  tbl_adm_admision aa,  tbl_cds_tipo_servicio ct,  tbl_adm_empresa ae  where  ap.fecha_nacimiento = aa.fecha_nacimiento  and  ap.codigo = aa.codigo_paciente   and   aa.compania = fdt.compania   and  aa.fecha_nacimiento = fdt.fac_fecha_nacimiento  and  aa.codigo_paciente = fdt.fac_codigo_paciente  and   aa.secuencia = fdt.fac_secuencia   and fdt.fac_codigo = ft.codigo  and  fdt.fac_secuencia = ft.admi_secuencia   and  fdt.fac_fecha_nacimiento = ft.admi_fecha_nacimiento  and   fdt.fac_codigo_paciente = ft.admi_codigo_paciente  and  fdt.compania = ft.compania  and  fdt.tipo_transaccion = ft.tipo_transaccion and aa.fecha_nacimiento = aba.fecha_nacimiento  and   aa.codigo_paciente = aba.paciente  and   aa.secuencia = aba.admision  and   nvl(aba.estado,'A') = 'A'   and   aba.prioridad = 1   and  aba.empresa = ae.codigo   and   fdt.tipo_cargo = ct.codigo "+appendFilter1+"  group by ae.nombre,  to_char(fdt.fac_fecha_nacimiento,'dd/mm/yyyy')||'( '||fdt.fac_codigo_paciente||' - '||fdt.fac_secuencia||' )', ct.descripcion,  ap.primer_nombre||' '||ap.segundo_nombre||' '||decode(ap.apellido_de_casada,null,ap.primer_apellido||' '||ap.segundo_apellido,ap.apellido_de_casada),  decode(ap.pasaporte,null,ap.provincia||'-'||ap.sigla||'-'||ap.tomo||'-'||ap.asiento||'-'||ap.d_cedula,ap.pasaporte)  order by ae.nombre,  ct.descripcion, ap.primer_nombre||' '||ap.segundo_nombre||' '||decode(ap.apellido_de_casada,null,ap.primer_apellido||' '||ap.segundo_apellido,ap.apellido_de_casada)) z where z.totalConsumo <> 0 ";

al = SQLMgr.getDataList(sql);

	System.out.println(" SQL > > > > > > > > >  "+sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "FACTURACION";
	String subtitle = "CONSUMO POR ASEGURADORA Y TIPO DE SERVICIO";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".25");
		dHeader.addElement(".35");
		dHeader.addElement(".25");
		dHeader.addElement(".15");

	Vector infoCol = new Vector();
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");
		infoCol.addElement(".05");

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

	pc.addBorderCols("Cóg. Pacietne",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Nombre Paciente",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Cédula/Pasaporte",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Total Consumo",1,1,cHeight,Color.lightGray);


	String groupByAseg		= "";		// para agrupar por grupo aseg.
	String groupByServ		= "";		// para agrupar por tipo servicio
	String groupByCat			= "";		// para agrupar por categoria de la admision
	double asegConsumo = 0,  servConsumo = 0, finalConsumo = 0;				// para el monto consumido
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		// Agrupar por grupo de aseguradora
		if (!groupByAseg.trim().equalsIgnoreCase(cdo.getColValue("dspEmpresa")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0)  // imprime total de pacte
					{
						// consumo del centro
						pc.addCols("Consumo Total del Servicio. . . . . ",2,3);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",servConsumo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);

						// consumo de la aseguradora
						pc.addCols("Consumo Total de la Aseguradora . . . . . ",2,3);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",asegConsumo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols(cdo.getColValue("dspEmpresa"),0,dHeader.size());
					servConsumo = 0;
					asegConsumo = 0;
					groupByServ	  = "";
					groupByAseg		= "";
		}

		// Agrupar por tipo servicio
		if (!groupByServ.trim().equalsIgnoreCase(cdo.getColValue("dsptipocargo")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0 && !groupByServ.trim().equalsIgnoreCase(""))  // imprime total de pacte
					{
						pc.addCols("Consumo Total del Servicio . . . . . ",2,3);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",servConsumo),2,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols(cdo.getColValue("dsptipocargo"),0,dHeader.size());
					servConsumo = 0;
					groupByServ	  = "";
		}


		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("codigoPaciente"),0,1);
		pc.addCols(cdo.getColValue("nombrPaciente"),0,1);
		pc.addCols(cdo.getColValue("noId"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("totalConsumo"))),2,1);

		asegConsumo		+= Double.parseDouble(cdo.getColValue("totalConsumo"));
		servConsumo		+= Double.parseDouble(cdo.getColValue("totalConsumo"));
		finalConsumo	+= Double.parseDouble(cdo.getColValue("totalConsumo"));

		groupByServ 	= cdo.getColValue("dsptipocargo");
		groupByAseg 	= cdo.getColValue("dspEmpresa");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{

			pc.setFont(8, 1,Color.black);
			// consumo del servicio
			pc.addCols("Consumo Total del Servicio . . . . . ",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",servConsumo),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// consumo de la aseguradora
			pc.addCols("Consumo Total de la Aseguradora . . . . . ",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",servConsumo),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// consumo final
			pc.addCols("Consumo Total  . . . . . ",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalConsumo),2,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
