<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
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


SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo=new CommonDataObject();
ArrayList al = new ArrayList();

String sql = "", userId = (request.getParameter("user_id")==null?"0":request.getParameter("user_id"));

sql = "select u.user_id, u.user_name, upper(u.name) name,i.codigo, i.idoneidad, i.folio, i.registro, i.observacion from tbl_Sec_users u , tbl_pla_idoneidad i where u.user_id = i.emp_id and i.tipo = 'U' and i.emp_id = "+userId+" order by i.codigo";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::"+timeStamp);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMINISTRACION";
	String subtitle = "IDONEIDADES POR USUARIO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement(".50"); //Idoneidad
	setDetail.addElement(".10"); //Registro
	setDetail.addElement(".10"); //Folio
	setDetail.addElement(".30"); //Observacion

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, UserDet.getUserName(), fecha, setDetail.size());
	
	if (al.size() > 0) {
    pc.setFont(10, 1, Color.black);
    cdo = (CommonDataObject)al.get(0);
    pc.addCols("["+userId+"] " + cdo.getColValue("name") + " ("+cdo.getColValue("user_name") + ")", 0, setDetail.size(),Color.lightGray);
  }

	//second row
	pc.setFont(10, 1);
	pc.addBorderCols("IDONEIDAD",0,1);
	pc.addBorderCols("REGISTRO",0,1);
	pc.addBorderCols("FOLIO",1,1);
	pc.addBorderCols("OBSERVACION",0,1);

	pc.setFont(8, 0);
	for (int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);
		pc.addCols(cdo.getColValue("idoneidad"),0,1);
		pc.addCols(cdo.getColValue("registro"),1,1);
		pc.addCols(cdo.getColValue("folio"),1,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>