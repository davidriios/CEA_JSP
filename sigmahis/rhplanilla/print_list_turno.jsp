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
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

	sql= "select codigo as codigo, compania as compania, substr(descripcion,0,25) as descripcion, to_char(hora_entrada_desde,'hh:mi am') as horaEntDesde, to_char(hora_entrada,'hh:mi am') as horaEnt, to_char(hora_entrada_hasta,'hh:mi am') as horaEntHasta, nvl(to_char(hora_rec_entrada,'hh:mi am'),'   ') as horaEntAlm, nvl(to_char(hora_rec_salida,'hh:mi am'),'    ') as horaSalAlm, to_char(hora_salida_desde,'hh:mi am') as horaSalDesde, to_char(hora_salida,'hh:mi am') as horaSal, to_char(hora_salida_hasta,'hh:mi am') as horaSalHasta, horas_diarias as cantHoras, nvl(maxper_horas_extras,'0') as maxPerHorasExtras, decode(verificar_comida,'S','SI','N','NO') as verificarComida, horas_com as horasComida, minutos_com as minutosComida, tipo_extra as tipoExtra, cant_min_extra as cantMinExtra from tbl_pla_ct_turno where compania="+(String) session.getAttribute("_companyId")+""+appendFilter+" order by codigo";

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
	String title = "RECUERSOS HUMANOS";
	String subtitle = "REPORTE DE TURNOS ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Código ",0);
		pc.addBorderCols("Descripción",0);
		pc.addBorderCols("Entrada",1);
		pc.addBorderCols("Almuerzo   Entrada ",1);
		pc.addBorderCols("Almuerzo   Salida",1);
		pc.addBorderCols("Salida",1);
		pc.addBorderCols("Máximo de Horas",1);
		pc.addBorderCols("Salida",1);
		pc.addBorderCols("Verifica    Comida",1);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("horaEnt"),1,1);
			pc.addCols(" "+cdo.getColValue("horaEntAlm"),1,1);
			pc.addCols(" "+cdo.getColValue("horaSalAlm"),1,1);
			pc.addCols(" "+cdo.getColValue("horaSal"),1,1);
			pc.addCols(" "+cdo.getColValue("cantHoras"),1,1);
			pc.addCols(" "+cdo.getColValue("maxPerHorasExtras"),1,1);
			pc.addCols(" "+cdo.getColValue("verificarComida"),1,1);

	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>