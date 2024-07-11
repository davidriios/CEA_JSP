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
StringBuffer sql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String allRoles = request.getParameter("all_roles") == null ? "" : request.getParameter("all_roles");

if (appendFilter == null) appendFilter = "";

sql.append("select * from (select a.user_id, a.user_name, a.user_status, decode(a.user_type,null,' ',a.user_type) as user_type, a.name, a.ref_code, (case when (select ref_type from tbl_sec_user_type where id=a.user_type)='E' then (select num_empleado from tbl_pla_empleado where to_char(emp_id)=a.ref_code) else a.ref_code end) as ref_code_display, a.default_profile, a.department, (select name from tbl_sec_users where user_id=a.user_report_to) as report_to, nvl((select code||' - '||description from tbl_sec_user_type where id=a.user_type),' ') as user_type_desc ");

if (allRoles.equalsIgnoreCase("Y")){
  sql.append(" , (select join(cursor( select p.profile_name from tbl_sec_profiles p, tbl_sec_user_profile up where p.profile_id = up.profile_id and up.user_id = a.user_id order by 1),', ') from dual) as profile_name ");
}else{
  sql.append(" , (select profile_name from tbl_sec_profiles where profile_id=a.default_profile) as profile_name ");
}

sql.append(", nvl((select name from tbl_sec_department where id=a.department),' ') as department_name, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_crea, a.fecha_creacion from tbl_sec_users a where a.default_profile!=0) x where default_profile!=0"+appendFilter+" order by 15 ");
al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "ADMINISTRACION";
	String subtitle = "USUARIOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".08");
		dHeader.addElement(".15");
		dHeader.addElement(".18");
		dHeader.addElement(".07");
		dHeader.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Tipo Usuario",1);
		pc.addBorderCols("Usuario",1);
		pc.addBorderCols("Nombre",1);
		pc.addBorderCols("Referencia",1);
		pc.addBorderCols("Departamento",1);
		pc.addBorderCols("Perfil Designado",1);
		pc.addBorderCols("Estado",1);
		pc.addBorderCols("Fecha Crea.",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(" "+cdo.getColValue("user_type_desc"),0,1);
		pc.addCols(" "+cdo.getColValue("user_name"),0,1);
		pc.addCols(" "+cdo.getColValue("name"),0,1);
		pc.addCols(" "+cdo.getColValue("ref_code_display"),0,1);
		pc.addCols(" "+cdo.getColValue("department_name"),0,1);
		pc.addCols(" "+cdo.getColValue("profile_name"),0,1);
		pc.addCols(" "+((cdo.getColValue("user_status").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"),1,1);
		pc.addCols(" "+cdo.getColValue("fecha_crea"),0,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>