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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String id = (String)session.getAttribute("_sel")==null?"":(String)session.getAttribute("_sel");

if (id.trim().equals("")) throw new Exception("No podemos encontrar los consentimientos identificados por "+id); 

String sql = "select id, path, upper(nombre) as consent_name, upper(titulo) as consent_title from tbl_param_consentimientos where estado <> 'I' and id in ("+id+") and path is not null order by display_order nulls last";



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
	//pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	session.setAttribute("printConsentUnico",pc);

ArrayList al = new ArrayList();
al = SQLMgr.getDataList(sql);

for(int i=0;i<al.size();i++) { 
  CommonDataObject cdo = (CommonDataObject)al.get(i); 
  System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PRINTING: << "+cdo.getColValue("consent_name")+" >> IDENTIFIED BY: "+cdo.getColValue("path"));
  try{
%>
	<jsp:include page="<%=cdo.getColValue("path")%>">
		<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
		<jsp:param name="noAdmision" value="<%=noAdmision%>"></jsp:param>
		<jsp:param name="idConsent" value="<%=cdo.getColValue("id")%>"></jsp:param>
		<jsp:param name="consentTitle" value="<%=cdo.getColValue("consent_title")%>"></jsp:param>
		<jsp:param name="consentName" value="<%=cdo.getColValue("consent_name")%>"></jsp:param>
	</jsp:include>
<% pc.addNewPage(); %>
<%
}catch(Exception e){ 
 System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FALLBACK CAUSED BY: "+e);
%>
	<jsp:include page="../admision/fallback_pdf.jsp">
		<jsp:param name="fbd" value="<%=cdo.getColValue("consent_name")+", "+cdo.getColValue("path")%>"></jsp:param>
	</jsp:include>
<% pc.addNewPage(); %>
<%}}%>
<%
	pc.close();
    session.removeAttribute("printConsentUnico");
	session.removeAttribute("_sel");
	response.sendRedirect(redirectFile);
%>