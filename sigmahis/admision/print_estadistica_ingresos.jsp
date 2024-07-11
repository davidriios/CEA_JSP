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
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String compania = (String) session.getAttribute("_companyId");
String fechaIni = request.getParameter("fechaini");
String fechaFin = request.getParameter("fechafin");
String categoria = request.getParameter("categoria");

if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (categoria == null) categoria = "";

sbSql.append("select nvl(get_sec_comp_param("+compania+",'CDS_NEO'),'-') as cdsNeo, nvl(get_sec_comp_param("+compania+",'ADM_EXCLU_EST_ADM'),'-') as excl_status from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p == null) {
	p = new CommonDataObject();
	p.addColValue("cdsNeo","-");
	p.addColValue("excl_status","-");
}
if (p.getColValue("cdsNeo").equals("-")) throw new Exception("El parámetro CDS_NEO no está definido!");
if (!p.getColValue("excl_status").trim().equals("") && !p.getColValue("excl_status").equals("-")) {
	sbFilter.append(" and aa.estado not in (select column_value from table(select split('");
	sbFilter.append(p.getColValue("excl_status"));
	sbFilter.append("',',') from dual))");
}

if (!fechaIni.equals("") && !fechaFin.equals("")){
	sbFilter.append(" and trunc(aa.fecha_ingreso) between to_date('");
	sbFilter.append(fechaIni);
	sbFilter.append("','dd/mm/yyyy') and to_date('");
	sbFilter.append(fechaFin);
	sbFilter.append("','dd/mm/yyyy')");
}
if (!categoria.equals("")) { sbFilter.append(" and aa.categoria = "); sbFilter.append(categoria); }

sbSql = new StringBuffer();
sbSql.append("select sum(nvl(trunc(aa.fecha_egreso),trunc(sysdate)) - trunc(aa.fecha_ingreso)) as dias_hospital, sum(decode(p.sexo,'M',nvl(trunc(aa.fecha_egreso),trunc(sysdate)) - trunc(aa.fecha_ingreso),0)) as dias_hospital_m, sum(decode(p.sexo,'F',nvl(trunc(aa.fecha_egreso),trunc(sysdate)) - trunc(aa.fecha_ingreso),0)) as dias_hospital_f, count(*) as total, sum(case when aa.centro_servicio <> ");
sbSql.append(p.getColValue("cdsNeo"));
sbSql.append(" and p.sexo = 'M' then 1 else 0 end) as total_m, sum(case when aa.centro_servicio <> ");
sbSql.append(p.getColValue("cdsNeo"));
sbSql.append(" and p.sexo = 'F' then 1 else 0 end) as total_f, sum(decode(aa.centro_servicio,");
sbSql.append(p.getColValue("cdsNeo"));
sbSql.append(",1,0)) as total_n, sum(case when aa.centro_servicio = ");
sbSql.append(p.getColValue("cdsNeo"));
sbSql.append(" and p.sexo = 'M' then 1 else 0 end) as total_nm, sum(case when aa.centro_servicio = ");
sbSql.append(p.getColValue("cdsNeo"));
sbSql.append(" and p.sexo = 'F' then 1 else 0 end) as total_nf from tbl_adm_admision aa, tbl_adm_paciente p where aa.pac_id = p.pac_id and aa.corte_cta is null and aa.fecha_ingreso is not null");
sbSql.append(sbFilter);
cdo = SQLMgr.getData(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String title = "ADMISION";
	String subtitle = "RESUMEN DE INGRESO DE PACIENTES";
	String xtraSubtitle = "";

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	int totalPactes = 0;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".05"); //
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".15"); //
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".05"); //

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

	pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
	
	pc.addCols(" ",0,dHeader.size());

	// dias hospital
	pc.addCols(" ",0,1);
	pc.setFont(9, 1, Color.WHITE);
	pc.addBorderCols("DIAS HOSPITAL",1,2, Color.GRAY);
	pc.addBorderCols("HOMBRES",1,2, Color.GRAY);
	pc.addBorderCols("MUJERES",1,2, Color.GRAY);
	pc.setFont(9, 1);
	pc.addCols(" ",0,1);
	pc.addCols(" ",0,1);
	pc.addBorderCols(cdo.getColValue("dias_hospital"),1,2);
	pc.addBorderCols(cdo.getColValue("dias_hospital_m"),1,2);
	pc.addBorderCols(cdo.getColValue("dias_hospital_f"),1,2);
	pc.addCols(" ",0,1);

	pc.addCols(" ",0,dHeader.size());

	// titulos
	pc.setFont(9, 1, Color.WHITE);
	pc.addCols(" ",0,1);
	pc.addBorderCols("HOSPITALIZADOS",1,1, Color.GRAY);
	pc.addBorderCols("HOMBRES",1,1, Color.GRAY);
	pc.addBorderCols("MUJERES",1,1, Color.GRAY);
	pc.addBorderCols("NEONATOS",1,1, Color.GRAY);
	pc.addBorderCols("NIÑOS",1,1, Color.GRAY);
	pc.addBorderCols("NIÑAS",1,1, Color.GRAY);
	pc.addCols(" ",0,1);

	// valores
	pc.addCols(" ",0,1);
	pc.setFont(9, 1);

	pc.addBorderCols(cdo.getColValue("total"),1,1);
	pc.addBorderCols(cdo.getColValue("total_m"),1,1);
	pc.addBorderCols(cdo.getColValue("total_f"),1,1);
	pc.addBorderCols(cdo.getColValue("total_n"),1,1);
	pc.addBorderCols(cdo.getColValue("total_nm"),1,1);
	pc.addBorderCols(cdo.getColValue("total_nf"),1,1);
	pc.addCols(" ",0,1);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>