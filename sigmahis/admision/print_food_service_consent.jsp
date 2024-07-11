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
<%@ include file="../common/pdf_header_consentimiento.jsp"%>

<%
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
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

String compania = (String) session.getAttribute("_companyId");

sql = " select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) nombrePaciente, coalesce(pasaporte,provincia || '-' || sigla || '-' || tomo || '-' || asiento) cedula from tbl_adm_paciente where pac_id  ="+pacId;

cdo = SQLMgr.getData(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

	float width = 62 * 8.5f;//612 
	float height = 62 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 30.0f; //9.0f
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String subTitle = "The Entrante and Intake of Food to Hospital "+_comp.getNombre();
	String title = "ADMISION";
	String xtraSubtitle = "";//"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	                         
	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}
		
	Vector tblImg = new Vector();
	tblImg.addElement("1");
	pc.setNoColumnFixWidth(tblImg);
	pc.createTable();
	
	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
	pc.addTable();

	Vector dHeader = new Vector();
	dHeader.addElement(".05");
	dHeader.addElement(".25"); 
	dHeader.addElement(".25"); 
	dHeader.addElement(".10");
	dHeader.addElement(".17");
	dHeader.addElement(".17");
		
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(2);

	pc.setFont(11, 1);
	pc.addCols(title, 1, dHeader.size(),20.2f);
	pc.addCols(subTitle, 1, dHeader.size());
	
	pc.setFont(11, 0);
	
	pc.addCols(" ", 3, dHeader.size());

	pc.addCols("The Hospital "+_comp.getNombre()+" offers you a balanced diet according to your level of health. Therefore the Hospital is not accountable for the entrance and intake of foods different to your diet because it can result in a delay of your medical treatment or even food poisoning.\n\n\n\n\n\n\n", 3, dHeader.size());
	
	pc.addCols("I ", 0, 1);
	pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
	pc.addCols("with ID", 0, 1);
	pc.addBorderCols(cdo.getColValue("cedula"), 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
	pc.addCols("hereby", 1, 1, 20.2f);
	
	pc.addCols("confirm that I read and have understood this document and in case of any doubts, I should ask my attending physician.", 0, dHeader.size(), 20.2f);
	
	pc.addCols(" ", 1, dHeader.size(), 25.2f);
	
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
	pc.addBorderCols(" ", 1, 2, 0.0f, 0.0f, 0.0f, 0.0f, 20.2f);
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
	
	pc.addCols("Patient’s Signature  ", 1, 2);
	pc.addBorderCols(" ", 1, 2, 0.0f, 0.0f, 0.0f, 0.0f, 20.2f);
	pc.addCols("Admission’s Officer Signature", 1, 2);
	
	pc.addCols("", 1, dHeader.size(), 25.2f);
	
	pc.addBorderCols(" ", 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
	pc.addBorderCols(" ", 1, 2, 0.0f, 0.0f, 0.0f, 0.0f, 20.2f);
	pc.addBorderCols(cDateTime, 1, 2, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);

	pc.addCols("Room Number", 1, 2);
	pc.addCols(" ", 1, 2);
	pc.addCols("Date", 1, 2);
		
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}
%>
