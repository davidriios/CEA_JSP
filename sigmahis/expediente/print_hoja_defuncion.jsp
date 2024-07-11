<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
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
REPORTE:  HOJA DE DEFUNCION
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();

CommonDataObject cdoPacData, cdo = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String code = request.getParameter("code");
String fechaProt = request.getParameter("fechaProt");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
if (desc == null) desc = "";

	// DATOS DE LA DEFUNCION.
	sql = "select numero_acta, to_char(fecha_muerte,'dd/mm/yyyy') fecha_muerte, observa_a, observa_b, observa_c, estado_patologo from tbl_sal_defuncion  where pac_id = "+pacId;
	cdo = SQLMgr.getData(sql);
	
	if ( cdo == null ) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}


	Vector dHeader = new Vector();
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(fontSize, 1);
		
    	pc.setVAlignment(0);
	
		pc.setFont(9, 1);
		pc.addBorderCols("N�mero de Acta:      "+(cdo.getColValue("numero_acta")==null?"":cdo.getColValue("numero_acta")),0,2,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Fecha de Defunci�n:     "+(cdo.getColValue("fecha_muerte")==null?"":cdo.getColValue("fecha_muerte")),1,3,0.0f,0.0f,0.0f,0.0f);
		pc.addCols(" ",0,5);
		pc.setFont(8, 0,Color.WHITE);
		pc.addBorderCols("CAUSAS DE LA DEFUNCION",0,5,cHeight,Color.BLACK);
		pc.setFont(fontSize, 0);
		pc.addBorderCols("PARTE I",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("A. Debido a (o como consecuencia de B)",0,4,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols("Enfermedad o estado patol�gico que produjo la muerta directamente",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("observa_a"),0,4,0.5f,0.5f,0.5f,0.5f);

		pc.addBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f);

		pc.addBorderCols("CAUSAS ANTECEDENTES",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("B. Debido a (o como consecuencia de C)",0,4,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols("Estados morbosos, si existiera alguno, que originaron la causa consignada arriba, mencionandose en C, la causa b�sica o fundamental.",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("observa_b"),0,4,0.5f,0.5f,0.5f,0.5f);

		pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("C. Causa b�sica o fundamental",0,4,0.5f,0.5f,0.5f,0.5f);
		pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("observa_c"),0,4,0.5f,0.5f,0.5f,0.5f);

		pc.addBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f);

		pc.addBorderCols("PARTE II",0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(" ",0,4,0.0f,0.0f,0.5f,0.5f);
		pc.addBorderCols("Otros estados patol�gicos significativos que contribuyaron a la muerte, pero, no relacionados con la enfemedad se�alada en C.",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("estado_patologo"),0,4,0.5f,0.0f,0.5f,0.5f);

	pc.addCols(" ",1,dHeader.size());



pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>