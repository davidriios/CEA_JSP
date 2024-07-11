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
<!-- Desarrollado por: José A. Acevedo C.         -->
<!-- Reporte: "Listado de Pacientes Activos al Día"  -->
<!-- Reporte: ADM3040                             -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 04/03/2010                            -->

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
String sala = request.getParameter("sala");
String noAdmision = request.getParameter("noAdmision");

String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";
//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and a.compania = "+compania;
  }
//-----------------------------------------------------------------------------------------------//
//--------------Query para obtener Listado de Pacientes Activos al Día--------------------------//
sql ="select p.sexo,decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre as nombrePaciente,  (to_char(a.fecha_nacimiento,'dd-mm-yyyy')||' ('||a.codigo_paciente||' - '||a.secuencia||')') as codigoPaciente,  coalesce(p.pasaporte,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento)||'-'||p.d_cedula as cedula,  to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as cod_pac, a.secuencia as noAdmision,a.pac_id, getfingreso_pactivos(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id,cama.cama) as fechaIngreso,  decode(cama.cama,null,'POR ASIGNAR',cama.cama) camaPaciente, cama.habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fIngreso,  decode(a.tipo_cta,'P','PARTICULAR','A','ASEGURADO','M','MEDICO','E','EMPLEADO','J','JUBILADO') tipoCuenta,  a.categoria as categoria, decode(a.categoria,1,'HOSP',2,'AMB.',3,'ESP.',4,'GER.') as descripcion_cat,  ae.codigo as codAseguradora, aba.poliza as noPoliza,  decode(ae.nombre,null,decode(a.tipo_cta,'P','PARTICULAR','A','ASEGURADO','M','MEDICO','E','EMPLEADO','J','JUBILADO'),ae.nombre) descAseguradora,  decode(p.vip,'S','VIP','D','DIST','M','MED','J','JDIR','N') as vip, am.primer_nombre||decode(am.segundo_nombre,'','',' '||am.segundo_nombre)||' '||am.primer_apellido|| decode(am.segundo_apellido, null,'',' '||am.segundo_apellido)||decode(am.sexo,'f', decode(am.apellido_de_casada,'','',' '||am.apellido_de_casada)) as nombre_medico,(select cds.descripcion from tbl_cds_centro_servicio cds,tbl_adm_atencion_cu cu where cds.codigo=cu.cds and CU.PAC_ID=a.pac_id and cu.secuencia=a.adm_root) as sala from tbl_adm_medico am, tbl_adm_admision a, tbl_adm_paciente p,  tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae,tbl_adm_cama_admision cama  where a.medico = am.codigo and (a.fecha_nacimiento = p.fecha_nacimiento and a.codigo_paciente = p.codigo) and  a.estado = 'A' and a.categoria in (1,2,3,4,5) and  (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and aba.prioridad(+) = 1 and  nvl(aba.estado(+),'A') = 'A' and aba.empresa = ae.codigo(+)) and  (a.pac_id = cama.pac_id(+) and a.secuencia = cama.admision(+) and cama.fecha_final(+) is null) "+appendFilter1+" order by decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre ";

cdo = SQLMgr.getData(sql);
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
	String subtitle = "LISTADO DE PACIENTES ACTIVOS AL DÍA  "+fecha;
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".07"); //
		dHeader.addElement(".13");
		dHeader.addElement(".16");
		dHeader.addElement(".07");
		dHeader.addElement(".11");
		dHeader.addElement(".08");
		dHeader.addElement(".11");
		dHeader.addElement(".20");
		dHeader.addElement(".12");
		dHeader.addElement(".19");
		dHeader.addElement(".09");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
	footer.setFont(6, 0);
	footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
/*footer.addCols("[ VIP/D/N ] "+"  Esta Columna indica el programa de Fidelización al que pertenece el Paciente. ",0,dHeader.size());
footer.addCols("                   VIP   = Paciente pertenece al programa de clientes VIP.",0,dHeader.size());
footer.addCols("                   DIST  = Paciente pertenece al programa de clientes DISTINGUIDOS.",0,dHeader.size());
footer.addCols("                   MED   = Paciente pertenece al grupo de MEDICOS del STAFF.",0,dHeader.size());
footer.addCols("                   JDIR  = Paciente pertenece al grupo de los miembros de la JUNTA DIRECTIVA o es familiar de alguno de los miembros.",0,dHeader.size());
footer.addCols("                   N     = Paciente es un cliente NORMAL.",0,dHeader.size());
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
		//footerHeight = footer.getTableHeight();*/

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		pc.addBorderCols("PID",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("IDENTIFICACION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("SEXO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("AREA O ESTACION",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CUARTO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CAMA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE DEL DOCTOR",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("F. INGRESO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("ASEGURADORA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("POLIZA",1,1,cHeight * 2,Color.lightGray);
	pc.setTableHeader(2);

	for (int i=0; i<al.size(); i++)
	{
      cdo = (CommonDataObject) al.get(i);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("pac_id")+"-"+(cdo.getColValue("noAdmision")),0,1);
		pc.addCols(" "+cdo.getColValue("cedula"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nombrePaciente"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("sexo"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("sala"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("habitacion"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("camaPaciente"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("nombre_medico"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);
		pc.addCols(" "+cdo.getColValue("descAseguradora"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("noPoliza"),0,1,cHeight);
	}//for i

	if (al.size() == 0)
	{
			pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{//Totales Finales
		  pc.setFont(8, 1,Color.black);
		  pc.addCols(" ",0,dHeader.size(),cHeight);
		  pc.addCols(" TOTAL DE PACIENTES ACTIVOS:   "+ al.size(),0,dHeader.size(),Color.lightGray);
		  pc.addCols(" ",0,dHeader.size(),cHeight);
	 }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
