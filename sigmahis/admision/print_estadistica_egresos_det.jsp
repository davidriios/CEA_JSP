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
CommonDataObject cdo5 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

String compania = (String) session.getAttribute("_companyId");

String fechaEgrini        = request.getParameter("fechaEgrini");
String fechaEgrfin        = request.getParameter("fechaEgrfin");

if (fechaEgrini == null) fechaEgrini = "";
if (fechaEgrfin == null) fechaEgrfin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "",  appendFilter2 = "";

if (!fechaEgrini.equals("") && !fechaEgrfin.equals("")){
   appendFilter1 += " and trunc(p.fecha_fallecido) between to_date('"+fechaEgrini+"', 'dd/mm/yyyy') and to_date('"+fechaEgrfin+"', 'dd/mm/yyyy')";
   appendFilter2 += " and trunc(a.fecha_egreso) between to_date('"+fechaEgrini+"', 'dd/mm/yyyy') and to_date('"+fechaEgrfin+"', 'dd/mm/yyyy')";
}

sql = "select count(decode(p.sexo,'M',sexo)) tot_m, count(decode(p.sexo,'F',sexo)) tot_f, count(*) as tot from tbl_adm_paciente p where p.fallecido = 'S' "+appendFilter1;

cdo = SQLMgr.getData(sql);

sql = "select sum(dias_hospital) tot, nvl(sum(decode(sexo,'M',dias_hospital)),0) as tot_m, nvl(sum(decode(sexo,'F',dias_hospital)),0) as tot_f from (select p.sexo, nvl (trunc(a.fecha_egreso),trunc(sysdate)) - trunc(a.fecha_ingreso) dias_hospital from tbl_adm_paciente p, tbl_adm_admision a where a.pac_id = p.pac_id "+appendFilter2+" and p.fallecido = 'S'  and a.corte_cta is null )";
cdo5 = SQLMgr.getData(sql);

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
	String subtitle = "RESUMEN DE EGRESO DE PACIENTES - DEFUNCIONES";
	String xtraSubtitle = "[ "+fechaEgrini+" al "+fechaEgrfin+" ]";

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
	pc.setVAlignment(1);

	// RENLGON1
	// titulos
	pc.setFont(9, 1, Color.WHITE);
	pc.addCols(" ",0,1);
	pc.addBorderCols("TOTAL DEFUNCIONES",1,1, Color.GRAY);
	pc.addCols(" ",1,1);
	pc.addBorderCols("HOMBRES",1,1, Color.GRAY);
	pc.addCols(" ",1,1);
	pc.addBorderCols("MUJERES",1,1, Color.GRAY);
	pc.addCols(" ",0,2);
	// valores
	pc.setFont(9, 1);
	pc.addCols(" ",0,1);
	pc.addBorderCols(cdo.getColValue("tot"),1,1);
	pc.addCols(" ",1,1);
	pc.addBorderCols(cdo.getColValue("tot_m"),1,1);
	pc.addCols(" ",1,1);
	pc.addBorderCols(cdo.getColValue("tot_f"),1,1);
	pc.addCols(" ",0,2);

	pc.addCols(" ",0,dHeader.size());

	pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	pc.addCols(" ",0,dHeader.size());
	
	pc.setVAlignment(1);

	// RENGLON 2
	// titulos
	pc.setFont(9, 1, Color.WHITE);
	pc.addCols(" ",0,1);
	pc.addBorderCols("TOTAL DIAS ESTADIA",1,1, Color.GRAY);
	pc.addCols(" ",0,1);
	pc.addBorderCols("HOMBRES",1,1, Color.GRAY);
	pc.addCols(" ",1,1);
	pc.addBorderCols("MUJERES",1,1, Color.GRAY);
	pc.addCols(" ",0,2);
	// valores
	
	pc.setFont(9, 1);
	pc.addCols(" ",0,1);
	pc.addBorderCols(cdo5.getColValue("tot"),1,1);
	pc.addCols(" ",1,1);
	pc.addBorderCols(cdo5.getColValue("tot_m"),1,1);
	pc.addCols(" ",1,1);
	pc.addBorderCols(cdo5.getColValue("tot_f"),1,1);
	pc.addCols(" ",0,2);


	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
