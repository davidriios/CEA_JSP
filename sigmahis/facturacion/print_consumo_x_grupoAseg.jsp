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
String tipoAdmision    = request.getParameter("tipoAdmision");
String centroServicio  = request.getParameter("area");
String grupoAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (categoria == null)     categoria       = "";
if (tipoAdmision == null)  tipoAdmision    = "";
if (centroServicio == null) centroServicio = "";
if (grupoAseguradora == null) grupoAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "", appendFilter2 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and a.compania = "+compania;
  }
if (!centroServicio.equals(""))
   {
    appendFilter1 += " and a.centro_servicio = "+centroServicio;
	}
if (!fechaini.equals(""))
   {
    appendFilter1 += " and trunc(a.fecha_ingreso) >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }
if (!fechafin.equals(""))
   {
   appendFilter1 += " and trunc(a.fecha_ingreso) <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
   }
if (!categoria.equals(""))
   {
   appendFilter1 += " and a.categoria = "+categoria;
   }
if (!tipoAdmision.equals(""))
   {
    appendFilter1 += " and a.tipo_admision = "+tipoAdmision;
   }
if (!grupoAseguradora.equals(""))
    {
	 appendFilter1 += " and decode(b.empresa, 94,'MEDICO', 99,'MEDICO FAMILIAR', 95,'JUBILADO', 96,'PARTICULAR', 81,'EMPLEADO', 98,'PRIMEROS AUXILIOS', 'ASEGURADORA') = '"+grupoAseguradora+"' ";
	}
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Ingresos de Pacientes---------------------------------//
sql = " select z.* from (select decode(b.empresa, 94,'MEDICO', 99,'MEDICO FAMILIAR', -1,'JUBILADO', 96,'PARTICULAR', 81,'EMPLEADO', 98,'PRIMEROS AUXILIOS', 'ASEGURADORA') descAseg, c.descripcion descCat, s.descripcion descCds, to_char(a.fecha_ingreso,'DD/MM/YYYY') ingreso, p.primer_nombre||' '||decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada) nombrePaciente, a.pac_id||'-'||a.secuencia admisionId, e.nombre as nombreAseg, nvl((select sum(decode(d.tipo_transaccion,'D', d.cantidad*-1,d.cantidad)* (nvl(d.monto,0) + nvl(d.recargo,0))) total from tbl_fac_transaccion t, tbl_fac_detalle_transaccion d  where t.admi_secuencia = a.secuencia  and t.pac_id  = a.pac_id and d.tipo_transaccion = t.tipo_transaccion  and d.compania = t.compania  and  d.fac_secuencia = t.admi_secuencia  and d.fac_codigo = t.codigo ),0) totalConsumo  from  tbl_adm_admision a, tbl_adm_paciente p,  tbl_adm_beneficios_x_admision b,  tbl_adm_categoria_admision c,  tbl_cds_centro_servicio s,  tbl_adm_empresa e  where a.centro_servicio = s.codigo  and a.categoria = c.codigo  and p.pac_id = a.pac_id  and a.pac_id = b.pac_id and a.secuencia = b.admision  and b.empresa  = e.codigo and nvl(b.estado,'A') = 'A' and b.prioridad = 1 and a.estado <> 'A' "+appendFilter1+") z where z.totalConsumo <> 0  order by 1,2,3,5";

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
	String subtitle = "CONSUMO DE PACIENTE POR GRUPO DE ASEGURADORA";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".30");
		dHeader.addElement(".15");
		dHeader.addElement(".35");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

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

	pc.addBorderCols("Paciente",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("ID Paciente",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Aseguradora",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Ingreso",1,1,cHeight,Color.lightGray);
	pc.addBorderCols("Consumo",1,1,cHeight,Color.lightGray);


	String groupByGrupo			 = "";		// para agrupar por grupo aseg.
	String groupByCatCentro	 = "";		// para agrupar por categoria admision
	int gCounter 					= 0;				// para la cantidad de pacientes por area
	int	tCounter 					= 0;				// para la cantidad total de pacientes
	double gTotal 				= 0;				// para el monto consumido x el pacientes por area
	double tTotal 				= 0;				// para el monto consumido x el pacientes	total
	for (int i=0; i<al.size(); i++)
	{
    cdo = (CommonDataObject) al.get(i);
		// Agrupar por grupo de aseguradora
		if (!groupByGrupo.trim().equalsIgnoreCase(cdo.getColValue("descAseg")))
		{
					pc.setFont(9, 1,Color.black);
					if (i != 0)  // imprime total de pacte
					{
						pc.addCols("TOTAL DE CUENTAS . . . . . "+String.valueOf(gCounter),0,2);
						pc.addCols("MONTO TOTAL . . . . . "+CmnMgr.getFormattedDecimal("###,##0.00",gTotal),2,3);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				  }

					pc.addCols("Grupo :"+cdo.getColValue("descAseg"),0,dHeader.size(),cHeight*2);
					gCounter = 0;
					gTotal	 = 0;
					groupByCatCentro = "";
					groupByGrupo= "";
		}

		// Agrupar por Categoria-Centro de admision
		if (!groupByCatCentro.trim().equalsIgnoreCase(cdo.getColValue("descCat")+"-"+cdo.getColValue("descCds")))
		{
					pc.addCols(" ",0,dHeader.size(),cHeight);
					pc.setFont(9, 1,Color.black);
					pc.addCols("Categoría: ",0,1);
					pc.addCols(cdo.getColValue("descCat"),0,4);
					pc.addCols("Area de Atención: ",0,1);
					pc.addCols(cdo.getColValue("descCds"),0,4);
		}

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("nombrePaciente"),0,1);
		pc.addCols(cdo.getColValue("admisionId"),0,1);
		pc.addCols(cdo.getColValue("nombreAseg"),0,1);
		pc.addCols(cdo.getColValue("ingreso"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal("###,##0.00",Double.parseDouble(cdo.getColValue("totalConsumo"))),2,2);

		gCounter++;
		tCounter++;

		gTotal	+= Double.parseDouble(cdo.getColValue("totalConsumo"));
		tTotal  += Double.parseDouble(cdo.getColValue("totalConsumo"));

		groupByCatCentro = cdo.getColValue("descCat")+"-"+cdo.getColValue("descCds");
		groupByGrupo		 = cdo.getColValue("descAseg");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.setFont(9, 1,Color.black);
			pc.addCols("TOTAL DE CUENTAS . . . . . "+String.valueOf(gCounter),0,2);
			pc.addCols("MONTO TOTAL . . . . . "+CmnMgr.getFormattedDecimal("###,##0.00",gTotal),2,3);
			pc.addCols(" ",0,dHeader.size(),cHeight);

	    //Totales Finales
			pc.addCols("TOTAL DE CUENTAS . . . . . "+String.valueOf(tCounter),0,2);
			pc.addCols("MONTO TOTAL . . . . . "+CmnMgr.getFormattedDecimal("###,##0.00",tTotal),2,3);
			pc.addCols(" ",0,dHeader.size(),cHeight);

	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
