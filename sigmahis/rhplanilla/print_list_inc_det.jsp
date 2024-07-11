<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="cdoT" scope="page" class="issi.admin.CommonDataObject" />
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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
		String nombreGrupo = "";
		String id   = request.getParameter("empId");
		String fechaInc = request.getParameter("fecha");
		String desde = request.getParameter("desde");
    String hasta = request.getParameter("hasta");
    String grupo = request.getParameter("grupo");
	String xDesde = request.getParameter("desde");

	  String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
		String userName = UserDet.getUserName();
    ArrayList alIncap = new ArrayList();
    ArrayList totIncap = new ArrayList();
		ArrayList list   = new ArrayList();


if (appendFilter == null) appendFilter = "";

if (request.getParameter("desde") != null) appendFilter += " and trunc(i.fecha) BETWEEN to_date('"+desde+"','dd/mm/yyyy') and to_date('"+hasta+"','dd/mm/yyyy')";
if (request.getParameter("empId") != null) appendFilter += " and e.emp_id = "+id;
if (request.getParameter("grupo") != null) appendFilter += " and ce.grupo = "+grupo;
if (request.getParameter("fecha") == null) fechaInc = CmnMgr.getCurrentDate("dd/mm/yyyy");

			sql = "select ce.emp_id as empId, ce.provincia as provincia, ce.sigla as sigla, ce.tomo as tomo, ce.asiento as asiento, e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) as nombre, ce.num_empleado as numEmpleado, ce.grupo as grupo, ce.ubicacion_fisica as ubicFisisca, cg.descripcion as nombreGrupo,ag.nombre as nombreArea, to_char(i.fecha,'dd/mm/yyyy') as fecha, mf.descripcion as descripcion, i.motivo as comentarios, to_char(i.hora_salida,'HH12:MI AM') as ini, to_char(i.hora_entrada,'HH12:MI AM') fin, nvl(i.tiempo_horas,0) as tiempoHoras, nvl(i.tiempo_minutos,0) as tiempoMinutos , (nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60) totHoras, trunc((nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60)/ h.cant_horas,0) tiempoDias, nvl(h.cant_horas,0) cant_horas from tbl_pla_ct_empleado ce, tbl_pla_empleado e, tbl_pla_ct_grupo cg, tbl_pla_ct_area_x_grupo ag, tbl_pla_incapacidad i, tbl_pla_motivo_falta mf, tbl_pla_horario_trab h where e.emp_id = ce.emp_id and h.CODIGO = E.HORARIO AND  h.COMPANIA = E.COMPANIA and e.compania=ce.compania and i.emp_id = ce.emp_id and i.compania=ce.compania and i.num_empleado=ce.num_empleado and mf.codigo= i.mfalta and cg.codigo=ce.grupo and cg.compania=ce.compania and ag.grupo=cg.codigo and ag.compania = ce.compania and ag.codigo=ce.ubicacion_fisica and i.ue_codigo = ce.grupo and ce.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by 1, 12";

	alIncap = SQLMgr.getDataList(sql);

 	sql = "select e.emp_id as totempId, ce.grupo as totgrupo, cg.descripcion as totNombreGrupo,  e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) as totNombre, max(to_char(i.fecha,'dd/mm/yyyy')) maxFecha, min(to_char(i.fecha,'dd/mm/yyyy')) minFecha, sum(nvl(i.tiempo_horas,0)) as tottiempoHoras, sum(nvl(i.tiempo_minutos,0)) as tottiempoMinutos , sum(nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60) totHoras, sum(trunc((nvl(i.tiempo_horas,0) + nvl(i.tiempo_minutos,0)/60)/ h.cant_horas,0)) tottiempoDias, sum(nvl(h.cant_horas,0)) totcant_horas from tbl_pla_ct_empleado ce, tbl_pla_empleado e, tbl_pla_ct_grupo cg, tbl_pla_ct_area_x_grupo ag, tbl_pla_incapacidad i, tbl_pla_motivo_falta mf, tbl_pla_horario_trab h where e.emp_id = ce.emp_id and h.CODIGO = E.HORARIO AND  h.COMPANIA = E.COMPANIA and e.compania=ce.compania and i.emp_id = ce.emp_id and i.compania=ce.compania and i.num_empleado=ce.num_empleado and mf.codigo= i.mfalta and cg.codigo=ce.grupo and cg.compania=ce.compania and ag.grupo=cg.codigo and ag.compania = ce.compania and ag.codigo=ce.ubicacion_fisica and i.ue_codigo = ce.grupo and ce.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" group by e.emp_id, ce.grupo, cg.descripcion, e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido)  order by 1";

	cdoT = SQLMgr.getData(sql);
 	desde = cdoT.getColValue("minFecha");
	hasta = cdoT.getColValue("maxFecha");


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String subtitle = " INFORME DE INCAPACIDADES";
	String xtraSubtitle = "DEL "+xDesde+ " al "+hasta ;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".10");
			dHeader.addElement(".15");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".30");
			dHeader.addElement(".25");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row


	//pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
			String nameGroup= "", nameEmp="" , emp="", totNombreGrupo= "", totNombre= "" ;
			int no = 0;
			int no2 = 0;
			int totHoras = 0, totMin = 0;
			int tiempoDias = 0;
			Double tiempoMin = 0.00;
			int mtos = 0;

	   	totNombreGrupo = cdoT.getColValue("totNombreGrupo");
	   		totNombre = cdoT.getColValue("totNombre");

		pc.addCols("",0,dHeader.size());
		pc.setFont(8, 1);
		pc.setVAlignment(0);
		pc.addCols(""+totNombre,0,dHeader.size());
		pc.addCols(""+totNombreGrupo,0,dHeader.size());

		pc.setFont(8, 1);
		pc.setVAlignment(0);
		pc.addBorderCols("Fecha", 1);
		pc.addBorderCols("Turno Asignado", 1);
		pc.addBorderCols("Horas", 1);
		pc.addBorderCols("Minutos", 1);
		pc.addBorderCols("Motivo", 1);
		pc.addBorderCols("Grupo", 1);

		pc.addCols(" ",0,dHeader.size());


	//table body
	for (int i=0; i<alIncap.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alIncap.get(i);
   		no2 += 1;
   		nameGroup = cdo.getColValue("nombreGrupo");
   		nameEmp = cdo.getColValue("nombre");
   		pc.setFont(8, 0);
   		pc.addCols(" "+cdo.getColValue("Fecha"), 0,1);
			pc.addCols(" "+cdo.getColValue("Ini")+ " / "+cdo.getColValue("Fin") , 1,1);
			pc.addCols(" "+cdo.getColValue("TiempoHoras"), 1,1);
			pc.addCols(" "+cdo.getColValue("TiempoMinutos"), 1,1);
			pc.addCols(" "+cdo.getColValue("Descripcion"), 0,1);
			pc.addCols(" "+cdo.getColValue("nombreGrupo"), 0,1);

   		emp = cdo.getColValue("numEmpleado");
			totHoras 	+= Integer.parseInt(cdo.getColValue("TiempoHoras"));
			totMin 		+= Integer.parseInt(cdo.getColValue("TiempoMinutos"));

			tiempoDias 	+= Integer.parseInt(cdo.getColValue("tiempoDias"));
			tiempoMin		+=  Double.parseDouble(cdo.getColValue("totHoras")) - ( Double.parseDouble(cdo.getColValue("totHoras")) /  Double.parseDouble(cdo.getColValue("cant_horas")) *  Double.parseDouble(cdo.getColValue("cant_horas")));
			mtos += tiempoMin;


	if ((i % 50 == 0) || ((i + 1) == alIncap.size())) pc.flushTableBody(true);
		}

	if (alIncap.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{

	pc.setFont(8, 1);
	pc.addCols("",0,dHeader.size());
	pc.addCols(" TIEMPO TOTAL TOMADO ---->    ", 2, 2);
	pc.addCols(" "+totHoras, 1, 1);
	pc.addCols(" "+totMin  , 1, 1);
	pc.addCols(" TIEMPO TOTAL TOMADO ---->    ", 2, 1);
	pc.addCols("  "+tiempoDias+ " día(s) con  "+mtos + " hora(s)" , 1, 1);

	pc.setFont(8, 1);
	pc.addCols("",0,dHeader.size());
	pc.addCols("",0,dHeader.size());
	pc.addCols("",0,dHeader.size());
	pc.addCols(" ", 0, 1);
	pc.addBorderCols(""+nameEmp,1,4,cHeight*2,Color.lightGray);
	pc.addCols("  ", 1, 1);

	pc.addCols(" ", 0, 1);
	pc.addBorderCols("GRUPO",1,3,cHeight*2,Color.lightGray);
	pc.addBorderCols("      HRS  /  MIN      DIAS  /  HRS  ",1,1,cHeight*2,Color.lightGray);
	pc.addCols("  ", 1, 1);

	pc.addCols(" ", 0, 1);
	pc.addBorderCols(" "+nameGroup,1,3,0.5f,0.5f,0.5f,0.0f,0.0f);
	pc.addBorderCols(" "+totHoras+"       "+totMin+"                "+tiempoDias+"      " +mtos+"       ",1,1,0.5f,0.5f,0.5f,0.5f,0.0f);
	pc.addCols("  ", 1, 1);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>