<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
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
CommonDataObject cdo   = new CommonDataObject();

String sql 						 = "";
String appendFilter 	 = request.getParameter("appendFilter");
String cDateTime 			 = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName 			 = UserDet.getUserName();
String sala 					 = request.getParameter("sala");
String compania 			 = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String tipoAdmision    = request.getParameter("tipoAdmision");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String estado          = request.getParameter("status");
String poliza          = request.getParameter("poliza");

if (categoria == null)     categoria       = "";
if (tipoAdmision == null)  tipoAdmision    = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";
if (sala == null) sala = "";
if (poliza == null) poliza = "";

String appendFilter1 = "", appendFilter2 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
	{
	 appendFilter1 += " and AA.compania = "+compania;
	}
if (!centroServicio.equals(""))
	 {
		appendFilter1 += " and AA.centro_servicio = "+centroServicio;
	}
if (!fechaini.equals(""))
	 {
		appendFilter1 += " and AA.fecha_ingreso >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
	 }
if (!fechafin.equals(""))
	 {
	 appendFilter1 += " and AA.fecha_ingreso <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;
	 }
if (!categoria.equals(""))
	 {
	 appendFilter1 += " and AA.categoria = "+categoria;
	 }
if (!tipoAdmision.equals(""))
	 {
		appendFilter1 += " and AA.tipo_admision = "+tipoAdmision;
	 }
if (!codAseguradora.equals(""))
		{
	 appendFilter1 += " and ABA.empresa = "+codAseguradora;
	}
if (!poliza.equals(""))
		{
	 appendFilter1 += " and ABA.poliza = '"+poliza+"'";
	}
	if (!estado.equals(""))
		{
	 appendFilter1 += " and AA.estado = '"+estado+"'";
	}
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Ingresos de Pacientes---------------------------------//
sql = "  select all ae.nombre desc_empresa, pac.nombre_paciente as  paciente,pac.sexo, pac.edad as anios, /*aca.habitacion||'/'||*/aca.cama as habitacion,pac.pac_id ||' - '||aa.secuencia as adm,nvl((select nvl(diag.observacion, diag.nombre) from  tbl_adm_diagnostico_x_admision ada,  tbl_cds_diagnostico diag where ada.pac_id = aa.pac_id and ada.admision= aa.secuencia and ada.orden_diag= 1 and ada.tipo= 'I' and ada.diagnostico = diag.codigo and rownum=1),' ') as diagnostico,   cds.descripcion desc_cds, aa.fecha_ingreso fi, to_char (aa.fecha_ingreso, 'dd/mm/yyyy') fecha_ingreso,to_char (aa.fecha_egreso, 'dd/mm/yyyy') fecha_egreso, med.primer_nombre||' '|| med.primer_apellido||' '|| med.apellido_de_casada   medico,aa.estado,  pac.telefono, aba.poliza from tbl_adm_admision aa, tbl_cds_centro_servicio cds,  vw_adm_paciente pac,  tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae,  tbl_adm_medico med,( select  aca1.pac_id, aca1.admision, aca1.cama, aca1.habitacion from tbl_adm_cama_admision aca1, (select acax.pac_id, acax.admision, max(acax.fecha_creacion) fcrea  from tbl_adm_cama_admision acax  group by  acax.pac_id, acax.admision) aca0  where aca1.pac_id = aca0.pac_id  and aca1.admision = aca0.admision and aca1.fecha_creacion = aca0.fcrea) aca where     aa.centro_servicio = cds.codigo and aa.pac_id = pac.pac_id  and med.codigo = aa.medico  and aa.pac_id = aca.pac_id(+) and aa.secuencia = aca.admision(+) and aba.pac_id = aa.pac_id and aba.admision = aa.secuencia and aba.prioridad = 1  and aa.pac_id = aba.pac_id(+)  and aa.secuencia = aba.admision(+)  and nvl(aba.estado, 'A') = 'A' and aa.estado in ('A', 'E', 'I')  and aa.corte_cta is null and ae.codigo = aba.empresa "+appendFilter1+ " order by 1, 9, 10, 3, 12 ";

al = SQLMgr.getDataList(sql);

	System.out.println(" --------------------->>>> "+sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
		String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	float height = 72 * 14f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "INGRESOS DE PACIENTES POR COMPAÑIA ASEGURADORA";
	String xtraSubtitle = "DEL  "+fechaini+"  AL  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".16");
		dHeader.addElement(".02");
		dHeader.addElement(".02");
		dHeader.addElement(".04");
		dHeader.addElement(".07");
		dHeader.addElement(".09");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".13");
		dHeader.addElement(".02");
		dHeader.addElement(".05");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);

	//footerHeight = footer.getTableHeight();

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setFont(6, 1);
	pc.setTableHeader(2);

	pc.addBorderCols("Nombre Paciente",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Sexo",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Edad",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Habit.",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Póliza",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Admisión",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Diagnóstico",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Area",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("F.Ingr.",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("F.Egr.",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Médico",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Est.",1,1,cHeight*2,Color.lightGray);
	pc.addBorderCols("Teléfono",1,1,cHeight*2,Color.lightGray);


	String groupByAseg	 = "";		// para agrupar por aseguradora
	int aCounter = 0;				// para la cantidad de pacientes por aseguradora
	int	tCounter = 0;				// para la cantidad total de pacientes
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		// Agrupar por Centro de admision
		if (!groupByAseg.trim().equalsIgnoreCase(cdo.getColValue("desc_empresa")))
		{
					pc.setFont(9, 1,Color.black);
					if (i != 0)  // imprime total de pactes por aseg
					{
						pc.addCols(String.valueOf(aCounter)+"  Pacientes de "+groupByAseg,0,dHeader.size(),cHeight*2);
						pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
						pc.addCols(" ",0,dHeader.size(),cHeight);
					}
					pc.addCols("Aseguradora :"+cdo.getColValue("desc_empresa"),0,dHeader.size());
					aCounter = 0;
		}

		pc.setFont(7, 0);

		pc.addCols(cdo.getColValue("paciente"),0,1);
		pc.addCols(cdo.getColValue("sexo"),1,1);
		pc.addCols(cdo.getColValue("anios"),1,1);
		pc.addCols(cdo.getColValue("habitacion"),0,1);
		pc.addCols(cdo.getColValue("poliza"),0,1);
		pc.addCols(cdo.getColValue("adm"),0,1);
		pc.addCols(cdo.getColValue("DIAGNOSTICO"),0,1);
		pc.addCols(cdo.getColValue("desc_cds"),0,1);
		pc.addCols(cdo.getColValue("FECHA_INGRESO"),1,1);
		pc.addCols(cdo.getColValue("FECHA_EGRESO"),1,1);
		pc.addCols(cdo.getColValue("medico"),0,1);
		pc.addCols(cdo.getColValue("estado"),1,1);
		pc.addCols(cdo.getColValue("TELEFONO"),1,1);


		aCounter++;
		tCounter++;

		groupByAseg = cdo.getColValue("desc_empresa");

	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.setFont(9, 1,Color.black);
			pc.addCols(String.valueOf(aCounter)+"  Pacientes de "+groupByAseg,0,dHeader.size(),cHeight*2);
			pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ",0,dHeader.size(),cHeight);

		//Totales Finales
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.addCols(" TOTAL FINAL DE PACIENTES:   "+String.valueOf(tCounter),0,dHeader.size(),cHeight*2,Color.lightGray);
			pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
