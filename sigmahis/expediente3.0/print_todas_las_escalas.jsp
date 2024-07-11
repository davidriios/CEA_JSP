<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

if (fg == null) fg = "";
if (fg.trim().equals("")) throw new Exception("El tipo de escala es inválido!"); 

String sql = "";
boolean fromExp3 = true;

// glasgow
if (fg.equalsIgnoreCase("A") || fg.equalsIgnoreCase("N")) {
  sql = "select to_char(eg.fecha,'dd/mm/yyyy') as fecha, to_char(eg.hora,'hh12:mi:ss am') as hora, '../expediente/print_escala_glasgow.jsp' path from tbl_sal_escala_coma eg where pac_id  = "+pacId+" and secuencia = "+noAdmision+" and tipo = '"+fg+"'";
  fromExp3 = false;
} else {
  sql = "select to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora , total ,id, case when '"+fg+"' in ('WB', 'MO', 'CR', 'NI', 'AN', 'DO', 'CA', 'FOUR', 'MAC', 'MM5', 'RAM') then '../expediente3.0/print_exp_seccion_80.jsp' end path from tbl_sal_escalas  where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo ='"+fg+"'";
}

  String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = "";
	if (fromExp3) fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
	else {
      servletPath = servletPath.replaceAll("3.0",  "");
      fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
   }

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

	float width = 72* 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 30.0f;
	float topMargin = 20.0f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = " ADMISION";
	String subTitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;
	String pageNoLabel = null;
	String pageNoPoxX = null;
	String pageNoPosY = null;
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	session.setAttribute("printExpedienteUnico", pc);

  ArrayList al = new ArrayList();
  al = SQLMgr.getDataList(sql);

for(int i=0;i<al.size();i++) { 
  CommonDataObject cdo = (CommonDataObject)al.get(i); 
  try{
     System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> INCLUDING: "+cdo.getColValue("path"));
%>
	<jsp:include page="<%=cdo.getColValue("path")%>">
		<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
		<jsp:param name="noAdmision" value="<%=noAdmision%>"></jsp:param>
		<jsp:param name="id" value="<%=cdo.getColValue("id")%>"></jsp:param>
		<jsp:param name="seccion" value="<%=seccion%>"></jsp:param>
		<jsp:param name="desc" value="<%=desc%>"></jsp:param>
		<jsp:param name="fechaEscala" value="<%=cdo.getColValue("fecha", " ")%>"></jsp:param>
		<jsp:param name="horaEscala" value="<%=cdo.getColValue("hora", " ")%>"></jsp:param>
	</jsp:include>
<% pc.addNewPage(); %>
<%
}catch(Exception e){ 
 System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FALLBACK CAUSED BY: "+e);
%>
	<jsp:include page="../admision/fallback_pdf.jsp">
		<jsp:param name="fbd" value="<%=cdo.getColValue("path")%>"></jsp:param>
	</jsp:include>
<% pc.addNewPage(); %>
<%}}%>
<%
  
  session.removeAttribute("printExpedienteUnico");
	pc.close();
	response.sendRedirect(redirectFile);
%>