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
<!-- Reporte: "Consumo de Paciente x Grupo Aseguradora"        -->
<!-- Reporte: ADM_3086                                         -->
<!-- Clínica Hospital San Fernando                             -->
<!-- Fecha:  20/08/2010                                         -->

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
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String fg				       = request.getParameter("fg");

if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (aseguradora == null) aseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (fg == null) fg = "ADM";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "", appendFilter2 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and ft.compania = "+compania;
  }
if (!centroServicio.equals(""))
   {
    appendFilter1 += " and ft.centro_servicio = "+centroServicio;
	}
if (!fechaini.equals(""))
   {
		if (fg.equals("ADM"))   appendFilter1 += " and aa.fecha_ingreso >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
		if (fg.equals("CAR"))   appendFilter1 += " and fdt.fecha_creacion >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
		if (fg.equals("ADM"))   appendFilter1 += " and aa.fecha_ingreso <= to_date('"+fechafin+"', 'dd/mm/yyyy')";
		if (fg.equals("CAR"))   appendFilter1 += " and fdt.fecha_creacion <= to_date('"+fechafin+"', 'dd/mm/yyyy')";
   }
if (!categoria.equals(""))
   {
   appendFilter1 += " and aa.categoria = "+categoria;
   }
if (!aseguradora.equals(""))
    {
	 appendFilter1 += " and aba.empresa = "+aseguradora;
	}
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Ingresos de Pacientes---------------------------------//
if (fg.equals("ADM")) sql = " select /*+ INDEX_JOIN(AA) */ em.nombre dspEmpresa,  cds.descripcion centroServicio, to_number(to_char(aa.fecha_ingreso, 'YYYY')) anioIngreso, cat.descripcion dspCategoria, nvl(sum(decode(fdt.tipo_transaccion, 'D', fdt.cantidad * -1, fdt.cantidad) * fdt.monto), 0) cargo, nvl(sum(decode(fdt.tipo_transaccion, 'D', fdt.cantidad * -1, fdt.cantidad) * fdt.recargo), 0) recargo from tbl_fac_detalle_transaccion fdt, tbl_fac_transaccion ft, tbl_adm_admision aa, tbl_adm_beneficios_x_admision aba, tbl_adm_medico me, tbl_adm_empresa em, tbl_cds_centro_servicio cds,  tbl_adm_categoria_admision cat  where aa.medico = me.codigo and aa.aseguradora = em.codigo  and aa.categoria = cat.codigo  and ft.centro_servicio = cds.codigo   and ft.compania = fdt.compania   and ft.codigo = fdt.fac_codigo  and ft.admi_secuencia = fdt.fac_secuencia  and ft.admi_fecha_nacimiento = fdt.fac_fecha_nacimiento  and ft.admi_codigo_paciente = fdt.fac_codigo_paciente  and ft.tipo_transaccion = fdt.tipo_transaccion   and ft.admi_fecha_nacimiento = aa.fecha_nacimiento   and ft.admi_codigo_paciente = aa.codigo_paciente   and ft.admi_secuencia = aa.secuencia  and aa.fecha_nacimiento = aba.fecha_nacimiento  and aa.codigo_paciente = aba.paciente  and aa.secuencia = aba.admision  and nvl(aba.estado, 'A') = 'A'  and aba.prioridad = 1  and aa.estado in ('A', 'E', 'I')  "+appendFilter1+"  group by em.nombre, cds.descripcion, to_number(to_char(aa.fecha_ingreso, 'YYYY')), cat.descripcion   order by em.nombre, cds.descripcion, to_number(to_char(aa.fecha_ingreso, 'YYYY')), cat.descripcion ";
if (fg.equals("CAR")) sql = " select /*+ INDEX_JOIN(AA) */ em.nombre dspEmpresa,  cds.descripcion centroServicio, to_number(to_char(fdt.fecha_creacion, 'YYYY')) anioIngreso, cat.descripcion dspCategoria, nvl(sum(decode(fdt.tipo_transaccion, 'D', fdt.cantidad * -1, fdt.cantidad) * fdt.monto), 0) cargo, nvl(sum(decode(fdt.tipo_transaccion, 'D', fdt.cantidad * -1, fdt.cantidad) * fdt.recargo), 0) recargo from tbl_fac_detalle_transaccion fdt, tbl_fac_transaccion ft, tbl_adm_admision aa, tbl_adm_beneficios_x_admision aba, tbl_adm_medico me, tbl_adm_empresa em, tbl_cds_centro_servicio cds,  tbl_adm_categoria_admision cat  where aa.medico = me.codigo and aa.aseguradora = em.codigo  and aa.categoria = cat.codigo  and ft.centro_servicio = cds.codigo   and ft.compania = fdt.compania   and ft.codigo = fdt.fac_codigo  and ft.admi_secuencia = fdt.fac_secuencia  and ft.admi_fecha_nacimiento = fdt.fac_fecha_nacimiento  and ft.admi_codigo_paciente = fdt.fac_codigo_paciente  and ft.tipo_transaccion = fdt.tipo_transaccion   and ft.admi_fecha_nacimiento = aa.fecha_nacimiento   and ft.admi_codigo_paciente = aa.codigo_paciente   and ft.admi_secuencia = aa.secuencia  and aa.fecha_nacimiento = aba.fecha_nacimiento  and aa.codigo_paciente = aba.paciente  and aa.secuencia = aba.admision  and nvl(aba.estado, 'A') = 'A'  and aba.prioridad = 1  and aa.estado in ('A', 'E', 'I')  "+appendFilter1+"  group by em.nombre, cds.descripcion, to_number(to_char(fdt.fecha_creacion, 'YYYY')), cat.descripcion   order by em.nombre, cds.descripcion, to_number(to_char(fdt.fecha_creacion, 'YYYY')), cat.descripcion ";


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
	String subtitle = "CONSUMO ANUAL POR ASEGURADORA Y CENTRO";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".20");

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

	pc.addBorderCols("Aseguradora",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Centro Servicio",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Categoria Adm.",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Consumo",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Recargo",1,1,cHeight,Color.lightGray);


	String groupByAseg		= "";		// para agrupar por grupo aseg.
	String groupByCentro	= "";		// para agrupar por centro
	String groupByCat			= "";		// para agrupar por categoria de la admision
	double asegConsumo = 0,  centConsumo = 0, catConsumo = 0, finalConsumo = 0;				// para el monto consumido
	double asegRecargo = 0,  centRecargo = 0, catRecargo = 0, finalRecargo = 0;				// para el monto consumido
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
						pc.addCols("Consumo Total del Centro . . . . . ",2,3);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centConsumo),1,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centRecargo),1,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);

						// consumo de la aseguradora
						pc.addCols("Consumo Total de la Aseguradora . . . . . ",2,3);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",asegConsumo),1,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",asegRecargo),1,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols(cdo.getColValue("dspEmpresa"),0,dHeader.size());
					centConsumo = 0;
					centRecargo = 0;
					asegConsumo = 0;
					asegRecargo = 0;
					groupByCat	  = "";
					groupByCentro = "";
					groupByAseg		= "";
		}

		// Agrupar por Centro de cargo
		if (!groupByCentro.trim().equalsIgnoreCase(cdo.getColValue("centroServicio")))
		{
					pc.setFont(8, 1,Color.black);
					if (i != 0 && !groupByCentro.trim().equalsIgnoreCase(""))  // imprime total de pacte
					{
						pc.addCols("Consumo Total del Centro . . . . . ",2,3);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centConsumo),1,1);
						pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centRecargo),1,1);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols(" ",1,1);
					pc.addCols(cdo.getColValue("centroServicio"),0,4);
					centConsumo = 0;
					centRecargo = 0;
					groupByCat	  = "";
					groupByCentro = "";
		}

		// Agrupar por categoria admision
		if (!groupByCat.trim().equalsIgnoreCase(cdo.getColValue("dspCategoria")))
		{
					pc.setFont(8, 1,Color.black);
					pc.addCols(" ",1,2);
					pc.addCols(cdo.getColValue("dspCategoria"),0,3);
					groupByCat	  = "";
		}

		pc.setFont(8, 0);
		pc.addCols(" ",1,2);
		pc.addCols("Año  "+cdo.getColValue("anioIngreso"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("cargo"))),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("recargo"))),1,1);

		asegConsumo	+= Double.parseDouble(cdo.getColValue("cargo"));
		asegRecargo	+= Double.parseDouble(cdo.getColValue("recargo"));

		centConsumo	+= Double.parseDouble(cdo.getColValue("cargo"));
		centRecargo	+= Double.parseDouble(cdo.getColValue("recargo"));

		finalConsumo	+= Double.parseDouble(cdo.getColValue("cargo"));
		finalRecargo	+= Double.parseDouble(cdo.getColValue("recargo"));

		groupByCentro = cdo.getColValue("centroServicio");
		groupByCat 		= cdo.getColValue("dspCategoria");
		groupByAseg 	= cdo.getColValue("dspEmpresa");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{

			pc.setFont(8, 1,Color.black);
			// consumo del centro
			pc.addCols("Consumo Total del Centro . . . . . ",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centConsumo),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",centRecargo),1,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// consumo de la aseguradora
			pc.addCols("Consumo Total de la Aseguradora . . . . . ",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",asegConsumo),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",asegRecargo),1,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);

			// consumo final
			pc.addCols("Consumo Total  . . . . . ",2,3);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalConsumo),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",finalRecargo),1,1);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
