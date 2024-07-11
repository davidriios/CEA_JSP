<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.CommonDataObject"%>
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

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

sql = "select a.tipo_plan as tipo, a.poliza, a.nombre ,a.comentario, b.codigo, b.nombre as descripcion from tbl_adm_tipo_plan a, tbl_adm_tipo_poliza b where a.poliza(+)= b.codigo "+appendFilter+" order by a.poliza, a.tipo_plan";
al = SQLMgr.getDataList(sql);

//System.out.println("\n\n ddddddddddddddddddsql="+sql+"\n\n");

if(request.getMethod().equalsIgnoreCase("GET")) {


	String fecha =cDateTime;
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
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONVENIO";
	String subtitle = "TIPO PLAN POR POLIZA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setHeader2=new Vector();
		setHeader2.addElement(".25");
		setHeader2.addElement(".75");

	pc.setNoColumnFixWidth(setHeader2);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setHeader2.size());

	String tipoPoliza = "";

	pc.setFont(7, 1);
	pc.addCols(" ", 0,setHeader2.size());

	pc.addBorderCols("Cód. Plan",0);
	pc.addBorderCols("Descripción",0);

	pc.setTableHeader(3);

	if (al.size() == 0) {
		pc.setFont(10,1);
		pc.addCols("No pudimos encontrar ningún Plan por Póliza",1,setHeader2.size());
	}
	else{

		for (int i=0; i<al.size(); i++){
			CommonDataObject cdo1 = (CommonDataObject) al.get(i);

			if (!tipoPoliza.equalsIgnoreCase("["+cdo1.getColValue("descripcion")+"]")){

				pc.setFont(8,1,Color.white);
				pc.addCols("Póliza: [ "+cdo1.getColValue("descripcion")+" ]",0,setHeader2.size(),Color.lightGray);
			}

			pc.setFont(7, 0);
			pc.addCols(" "+cdo1.getColValue("tipo"),0,1);
			pc.addCols(" "+cdo1.getColValue("nombre"),0,1);

			tipoPoliza="["+cdo1.getColValue("descripcion")+"]";

		}//End For

		pc.setFont(10,1);
		pc.addCols(al.size()+" Registro"+(al.size()>1?"s":"")+" en total",0,setHeader2.size());

	}//else

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
} //get
%>