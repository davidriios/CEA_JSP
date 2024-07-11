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
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String grupo = request.getParameter("grupo");
String unidad = request.getParameter("unidad");
String empId = request.getParameter("empId");
String codigo = request.getParameter("codigo");

if (appendFilter == null) appendFilter = "";
if (empId == null) empId = "";
if (codigo == null) codigo = "";

	sql.append("select a.cedula1 cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.nombre_empleado as nombre,a.unidad_organi as seccion, b.descripcion as descripcion, a.emp_id empId, c.denominacion as cargo,d.codigo,a.num_empleado,d.estado,to_char(d.fecha_inicio,'dd/mm/yyyy') as fechaDesde, to_char(d.fecha_final,'dd/mm/yyyy') as fechaHasta,nvl(d.cant_quincenas,0) as quincenaSal,decode(d.estado,'A','APROBADA','P','PENDIENTE','R','RECHAZADA')descEstado,d.cant_meses meses, d.cant_dias dias, nvl(d.cant_dias_pagar,0) dias_pagar, d.comentario,to_char(d.fecha_retorno,'dd/mm/yyyy') fechaRetorno, decode(d.motivo_falta,35,'INCAPACIDAD',13,'ENFERMEDAD',37,'LICENCIA POR GRAVIDEZ',40,'LICENCIA CON SUELDO',38,'LICENCIA SIN SUELDO',39,'RIESGO PROFESIONAL') descTipo from vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cc_licencia d, tbl_pla_cargo c where a.compania = b.compania and a.unidad_organi= b.codigo and a.compania = c.compania and a.cargo=c.codigo  and a.emp_id = d.emp_id and a.compania = d.compania and a.compania=");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(appendFilter.toString());
	sql.append(" order by a.nombre_empleado ");
if(!empId.trim().equals("")){sql.append(" and d.emp_id =");sql.append(empId);}
if(!codigo.trim().equals("")){sql.append(" and d.codigo =");sql.append(codigo);}

 al = SQLMgr.getDataList(sql.toString());

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
	String title = "RECUERSOS HUMANOS";
	String subtitle = " LICENCIAS - INCAPACIDADES - RIESGOS PROFESIONALES";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".07");
		dHeader.addElement(".14");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".06");
		dHeader.addElement(".15");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(6, 1);
		pc.addBorderCols("Cedula ",0);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Estado",1);
		pc.addBorderCols("Tipo",1);
		pc.addBorderCols("Fecha Desde",1);
		pc.addBorderCols("Fecha Hasta",1);
		pc.addBorderCols("Fecha Retorno ",1);
		pc.addBorderCols("Meses ",1);
		pc.addBorderCols("Quinc.",1);
		pc.addBorderCols("Dias ",1);
		pc.addBorderCols("Dias a Pagar",1);
		pc.addBorderCols("Observacion",1);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String  tipo = "";
			String  sub = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			
		pc.setFont(6, 0);
		pc.setVAlignment(0);

		pc.addCols(" "+cdo.getColValue("cedula"),0,1);
		pc.addCols(" "+cdo.getColValue("nombre"),0,1);
		pc.addCols(" "+cdo.getColValue("descEstado"),0,1);
		pc.addCols(" "+cdo.getColValue("descTipo"),0,1);
		pc.addCols(" "+cdo.getColValue("fechaDesde"),1,1);
		pc.addCols(" "+cdo.getColValue("fechaHasta"),1,1);
		pc.addCols(" "+cdo.getColValue("fechaRetorno"),1,1);
		pc.addCols(" "+cdo.getColValue("meses"),1,1);
		pc.addCols(" "+cdo.getColValue("quincenaSal"),1,1);
		pc.addCols(" "+cdo.getColValue("dias"),1,1);
		pc.addCols(" "+cdo.getColValue("dias_pagar"),1,1);
		pc.addCols(" "+cdo.getColValue("comentario"),0,1);



	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>