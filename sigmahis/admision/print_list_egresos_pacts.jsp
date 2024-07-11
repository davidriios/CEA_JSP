<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.CommonDataObject"%>
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
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String tipoAdmision    = request.getParameter("tipoAdmision");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (categoria == null)     categoria       = "";
if (tipoAdmision == null)  tipoAdmision    = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "", appendFilter2 = "";
int cantHombres = 0, cantMujeres = 0, cantMenorEdad = 0;
//--------------Parámetros--------------------//
if (!compania.equals(""))
	{
	 appendFilter2 += " and a.compania = "+compania;
	}
if (!categoria.equals(""))
	 {
	 appendFilter2 += " and a.categoria = "+categoria ;
	 }
if (!tipoAdmision.equals(""))
	 {
	appendFilter2 += " and a.tipo_admision = "+tipoAdmision;
	 }
if (!centroServicio.equals(""))
	 {
	appendFilter2 += " and a.centro_servicio = "+centroServicio;
	}
if (!codAseguradora.equals(""))
		{
	 appendFilter2 += " and aba.empresa = "+codAseguradora;
	}
if (!fechaini.equals(""))
	 {
	appendFilter2 += " and to_date(to_char(a.fecha_egreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
	 }
if (!fechafin.equals(""))
	 {
	 appendFilter2 += " and to_date(to_char(a.fecha_egreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy') ";
	 }

//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Egresos de Pacientes--------------------------------//
sql =
 " SELECT ALL 2 princip, "
+" p.pac_id, p.nombre_paciente as nombrePaciente, "
+" id_paciente as cedula,p.edad as edadPac, "
+" a.codigo_paciente as cod_pac, a.secuencia as noAdmision, "
+" to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, a.categoria as categoria, "
+" to_char(a.dias_hospitalizados) as diasHospitalizados, a.tipo_admision as tipoAdmision, "
+" to_char(a.fecha_egreso,'dd/mm/yyyy') as fechaEgreso, "
+" a.centro_servicio as centroServicio, cds.descripcion as descripcion_centro, "
+" decode((select adm_type from tbl_adm_categoria_admision where codigo = a.categoria),'I',get_adm_cargo_hab(a.pac_id, a.secuencia),(select descripcion from tbl_adm_categoria_admision where codigo = a.categoria)) as habitacion, "
+" decode(a.tipo_cta,'P','PARTICULAR','A','ASEGURADO','M','MEDICO','E','EMPLEADO','J','JUBILADO') tipoCuenta, ae.codigo as codAseguradora, ae.nombre as descAseguradora, "
+" decode(p.vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') as vip, "
+" decode(p.telefono||p.telefono_urgencia,null,' ',nvl(p.telefono,' ')||' / '||nvl(p.telefono_urgencia,' ')) as telefonos, "
+" p.direccion_de_urgencia as direccionUrgencia, p.sexo "
+" from tbl_adm_admision a, vw_adm_paciente p, tbl_cds_centro_servicio cds, "
+" tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae "
+" where "
+" a.pac_id = p.pac_id and "
+" a.centro_servicio = cds.codigo and "
+" (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and "
+" aba.prioridad(+) = 1 and nvl(aba.estado(+),'A') = 'A' and "
+" aba.empresa = ae.codigo(+)) and a.estado not in('N') "+appendFilter2
+" order by a.fecha_ingreso asc, a.tipo_cta, ae.nombre ";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "ADMISION"; 
	String subtitle = "INFORME DE EGRESOS DE PACIENTES DEL DIA "+fechaini+" AL "+fechafin;
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".16"); //
		dHeader.addElement(".08");
		dHeader.addElement(".06");
		dHeader.addElement(".12"); //
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".06");
		dHeader.addElement(".14");
		dHeader.addElement(".08");
		dHeader.addElement(".14");

/*-------------Creando el "Pie de Página" del Informe------------*/
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
footer.addCols("[ VIP/D/N ] "+"  Esta Columna indica el programa de Fidelización al que pertenece el Paciente. ",0,dHeader.size());
footer.addCols("                   VIP   = Paciente pertenece al programa de clientes VIP.",0,dHeader.size());
footer.addCols("                   DIST  = Paciente pertenece al programa de clientes DISTINGUIDOS.",0,dHeader.size());
footer.addCols("                   MED   = Paciente pertenece al grupo de MEDICOS del STAFF.",0,dHeader.size());
footer.addCols("                   JDIR  = Paciente pertenece al grupo de los miembros de la JUNTA DIRECTIVA o es familiar de alguno de los miembros.",0,dHeader.size());
footer.addCols("                   N     = Paciente es un cliente NORMAL.",0,dHeader.size());
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
		//footerHeight = footer.getTableHeight();
/*-----------------------------------------------------------------*/


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());


	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,Color.lightGray);
		pc.addBorderCols("PID",1,1,Color.lightGray);
		pc.addBorderCols("ADMISION",1,1,Color.lightGray);
		pc.addBorderCols("SALA",1,1,Color.lightGray);
		pc.addBorderCols("F. INGRESO",1,1,Color.lightGray);
		pc.addBorderCols("F. EGRESO",1,1,Color.lightGray);
		pc.addBorderCols("DIAS HOSP.",1,1,Color.lightGray);
		pc.addBorderCols("TIPO CUENTA",1,1,Color.lightGray); //
		pc.addBorderCols("TELEFONOS",1,1,Color.lightGray);
		pc.addBorderCols("DIRECCION RESIDENCIAL",1,1,Color.lightGray);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

int menor = 0;
int fSex = 0;
int mSex = 0;

	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("nombrePaciente"),0,1);
		pc.addCols(cdo.getColValue("pac_id"),1,1);
		pc.addCols(cdo.getColValue("noAdmision"),1,1);
		pc.addCols(cdo.getColValue("habitacion"),0,1);
		pc.addCols(cdo.getColValue("fechaIngreso"),1,1);
		pc.addCols(cdo.getColValue("fechaEgreso"),1,1);
		pc.addCols(cdo.getColValue("diasHospitalizados"),1,1);
		pc.addCols(cdo.getColValue("descAseguradora"),0,1);
		pc.addCols(cdo.getColValue("telefonos"),1,1);
		pc.addCols(cdo.getColValue("direccionUrgencia"),0,1);

			/*-------------Cant. de Pacientes Menores de Edad------------*/
		if (Integer.parseInt(cdo.getColValue("edadPac")) < 18)
			 {
				cantMenorEdad = 1;
			 menor++;
			 }else{
				 cantMenorEdad = 0;
				 }
                 
       if (cdo.getColValue("sexo").equalsIgnoreCase("M")) mSex++;
	   else fSex++;
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(" TOTAL DE PACIENTES:   "+ al.size(),0,dHeader.size(),Color.lightGray);
			pc.addCols(" TOTAL DE HOMBRES:     "+ mSex,0,dHeader.size(),Color.lightGray);
			pc.addCols(" TOTAL DE MUJERES:      "+ fSex,0,dHeader.size(),Color.lightGray);
			pc.addCols(" ",0,dHeader.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>