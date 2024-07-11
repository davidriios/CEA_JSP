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
REPORTE:  ENVIO DE VACACIONES A PLANILLA / sct0031
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

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String compania 	  = (String) session.getAttribute("_companyId");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String fechaIni	= "", fechaFin = "";

if (appendFilter == null) appendFilter = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (quincena == null) quincena = "";

if (!compania.equals("")) appendFilter += " and s.compania = "+compania;

if (!request.getParameter("anio").equals("") && !request.getParameter("mes").equals(""))
	{
	  appendFilter += " and trunc(s.enviar_planilla_fecha) >=  (case when '"+quincena+"' = '2' then to_date('15/"+mes+"/"+anio+"','dd/mm/yyyy') else to_date('01/"+mes+"/"+anio+"','dd/mm/yyyy') end) and trunc(s.enviar_planilla_fecha) <=  (case when '"+quincena+"' = '1' then to_date('15/"+mes+"/"+anio+"','dd/mm/yyyy') else last_day(to_date('01/"+mes+"/"+anio+"','dd/mm/yyyy')) end) " ;
	}


// query
sql = "select all e.nombre_empleado, (select u.descripcion from  tbl_sec_unidad_ejec u where codigo= e.ubic_depto and u.compania = e.compania)dsp_unidad, e.cedula1 cedula,  s.num_empleado numempleado, to_char(s.periodof_inicio,'dd/mm/yyyy') periodoinicio, to_char(s.periodof_final,'dd/mm/yyyy') periodofinal, nvl(s.dias_dinero,0) diasdinero, nvl(s.dias_tiempo,0) diastiempo, nvl(s.observacion,' ') observacion, s.estado estado, to_char(s.fecha_aprobacion,'dd/mm/yyyy')||'  -  '||s.usuario_aprob autorizacion, nvl(s.per_actual_vac,' ') peractvac, nvl(s.per_ultima_vac,' ')perultvac, nvl(s.fecha_ult_vac,' ') fechaultvac from tbl_pla_sol_vacacion s, vw_pla_empleado e where s.compania = e.compania and s.emp_id = e.emp_id and s.enviar_planilla_estado = 'S' and s.estado not in ('RE','AN') "+ appendFilter+" order by e.ubic_depto ";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String title = "RECURSOS HUMANOS";
	String subtitle = "SOLICITUDES DE VACACIONES APROBADAS POR RECURSOS HUMANOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".06");
			dHeader.addElement(".24");
			dHeader.addElement(".06");
			dHeader.addElement(".06");
			dHeader.addElement(".09");
			dHeader.addElement(".09");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".20");

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

		//table header
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setTableHeader(1);//create de table header (2 rows) and add header to the table
	//table body

		// titulos
		pc.setFont(7, 1);
		pc.addBorderCols("No.",1,1);
		pc.addBorderCols("Nombre Empleado.",1,1);
		pc.addBorderCols("Días Tiempo",1,1);
		pc.addBorderCols("Días Dinero",1,1);
		pc.addBorderCols("Fecha Inicio",1,1);
		pc.addBorderCols("Fecha Final",1,1);
		pc.addBorderCols("Periodo Ult. Vac.",1,1);
		pc.addBorderCols("Periodo Vac.Actual",1,1);
		pc.addBorderCols("Usuario / Fecha Aprob.",1,1);

		String groupBy  = "";
		for (int a=0; a<al.size(); a++)
		{
			CommonDataObject cdo0 = (CommonDataObject) al.get(a);
			// Agrupar por Depto
			if (!groupBy.trim().equalsIgnoreCase(cdo0.getColValue("dsp_unidad")))
			{
				pc.addCols(" ",0,dHeader.size());
				pc.setFont(8, 1);
				pc.addCols("Departamento :"+cdo0.getColValue("dsp_unidad"),0,dHeader.size());
			}
			// detalle
			pc.setFont(7, 0);
			pc.addCols(cdo0.getColValue("numEmpleado"),1,1);
			pc.addCols(cdo0.getColValue("nombre_empleado"),0,1);
			pc.addCols(cdo0.getColValue("diasTiempo"),1,1);
			pc.addCols(cdo0.getColValue("diasDinero"),1,1);
			pc.addCols(cdo0.getColValue("periodoInicio"),1,1);
			pc.addCols(cdo0.getColValue("periodoFinal"),1,1);
			pc.addCols(cdo0.getColValue("perUltVac"),1,1);
			pc.addCols(cdo0.getColValue("perActVac"),1,1);
			pc.addCols(cdo0.getColValue("autorizacion"),0,1);
			if (cdo0.getColValue("observacion") != "")  pc.addCols("Observacion: "+cdo0.getColValue("observacion"),0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
			groupBy = cdo0.getColValue("dsp_unidad");
	 }// fin del for a

	 if (al.size() == 0)
			pc.addCols("NO HAY REGISTROS",0,dHeader.size(),cHeight);
	 else
		{
			pc.addCols("TOTAL DE SOLICITUDES APROBADAS  . . . . . "+al.size(),0,dHeader.size(),cHeight*2);
			pc.addCols(" ",0,dHeader.size(),cHeight);
		}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>