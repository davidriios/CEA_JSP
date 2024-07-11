<%@ page errorPage="../error.jsp"%>
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
String grupo = request.getParameter("grupo");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String grupoDesc = request.getParameter("grupoDesc");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
if (request.getParameter("desde") != null) appendFilter += " and trunc(d.fecha) BETWEEN to_date('"+desde+"','dd/mm/yyyy') and to_date('"+hasta+"','dd/mm/yyyy')";

if (request.getParameter("grupo") != null) appendFilter += " and t.grupo = "+grupo;


	sql= "select t.provincia as provincia, t.sigla as sigla, t.tomo as tomo, t.asiento as asiento, a.nombre_empleado as nombre, t.num_empleado as numEmpleado, a.emp_id as empId, t.grupo as grupo, t.ubicacion_fisica as ubicFisisca, g.descripcion as nombreGrupo, ag.nombre as nombreArea, to_char(d.fecha,'dd/mm/yyyy') as fecha, mf.descripcion as descripcion, d.motivo as comentarios, to_char(d.hora_salida,'HH12:MI AM') as ini, to_char(d.hora_entrada,'HH12:MI AM') fin, d.tiempo_horas as tiempoHoras, nvl(d.tiempo_minutos,0) as tiempoMinutos, d.mfalta, decode(d.estado,'DS','DESCONTAR','ND','NO DESCONTAR','DV','DEVOLVER','PE','PENDIENTE') estado, d.no_referencia, d.motivo from tbl_pla_ct_empleado t, vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ct_grupo g, tbl_pla_ct_area_x_grupo ag, tbl_pla_incapacidad d, tbl_pla_motivo_falta mf where a.ubic_seccion = b.codigo and a.compania = b.compania and a.emp_id = t.emp_id and a.compania = t.compania and d.emp_id = t.emp_id and d.compania = t.compania and mf.codigo= d.mfalta and g.codigo=t.grupo and g.compania=t.compania and ag.grupo=g.codigo and ag.compania = t.compania and ag.codigo=t.ubicacion_fisica and d.ue_codigo = t.grupo and t.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by g.descripcion, a.emp_id, d.fecha, d.mfalta";

 al = SQLMgr.getDataList(sql);

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
	String subtitle = "INFORME DE INCAPACIDADES";
	String xtraSubtitle = (!desde.trim().equalsIgnoreCase("")?"DEL : "+desde:"")+(!hasta.trim().equalsIgnoreCase("")?"  HASTA : "+hasta:"");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);



	Vector dDetalle = new Vector();
		dDetalle.addElement(".08");
		dDetalle.addElement(".08");
		dDetalle.addElement(".08");
		dDetalle.addElement(".08");
		dDetalle.addElement(".08");
		dDetalle.addElement(".35");
		dDetalle.addElement(".35");

 pc.setNoColumnFixWidth(dDetalle);

	//table header
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dDetalle.size());

		//second row

		//pc.setFont(8, 1);
		//pc.addCols("Grupo : ["+grupo+"] "+grupoDesc, 0,dDetalle.size());

		pc.setFont(7, 1);
		pc.addBorderCols("Fecha", 1);
		pc.addBorderCols("Desde", 1);
		pc.addBorderCols("Hasta", 1);
		pc.addBorderCols("Horas", 1);
		pc.addBorderCols("Minutos", 1);
		pc.addBorderCols("Motivo ", 1);
		pc.addBorderCols("Comentarios", 1);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	int no = 0;
	String  tipo = "";
	String  sub = "";
	int totHoras = 0, totMin = 0;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
    	if (!tipo.equalsIgnoreCase(cdo.getColValue("empId")))
		{
			if(i!=0)
			{
				pc.setFont(7, 0);
				pc.addCols(" ",0,dDetalle.size());
				pc.addCols(" --- TIEMPO TOTAL TOMADO --->",2,3);
				pc.addCols(""+totHoras,1,1);
				pc.addCols(""+totMin,1,1);
				pc.addCols("",0,2);
				totHoras=0;
				totMin = 0;
			}

			pc.setFont(7, 4);
			pc.addCols(" ",0,dDetalle.size());
			pc.addCols(" "+cdo.getColValue("empId")+" - "+cdo.getColValue("nombre"),0,dDetalle.size());
			sub ="";
		}


		pc.setNoColumnFixWidth(dDetalle);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo.getColValue("Fecha"), 0,1);
		pc.addCols(" "+cdo.getColValue("Ini"), 1,1);
		pc.addCols(" "+cdo.getColValue("Fin"), 1,1);
		pc.addCols(" "+cdo.getColValue("TiempoHoras"), 1,1);
		pc.addCols(" "+cdo.getColValue("TiempoMinutos"), 1,1);
		pc.addCols(" "+cdo.getColValue("descripcion"), 0,1);
		pc.addCols(" "+cdo.getColValue("comentarios"), 0,1);
		tipo=cdo.getColValue("empId");
		totHoras 	+= Integer.parseInt(cdo.getColValue("TiempoHoras"));
		totMin 		+= Integer.parseInt(cdo.getColValue("TiempoMinutos"));

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}

	if (al.size() == 0) pc.addCols("No existen registros",1,dDetalle.size());
	else
	{
		pc.setFont(7, 0);
		pc.addCols(" ",0,dDetalle.size());
		pc.addCols(" --- TIEMPO TOTAL TOMADO --->",2,3);
		pc.addCols(""+totHoras,1,1);
		pc.addCols(""+totMin,1,1);
		pc.addCols("",0,2);
	}	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>