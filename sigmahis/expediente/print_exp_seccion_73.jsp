<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
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
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
REPORTE:  NUTRICIONAL RISK SCREENING 
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
Properties prop = new Properties();

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdop = new CommonDataObject();

String sql = "";
String appendFilter = "";
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
String key = "";
String seccion = request.getParameter("seccion");
String imgDoc ="";

if ( id == null ) id = "0";
if ( fg == null ) fg = "NDNO";

appendFilter = (!id.equals("0")?" and id = "+id:"");

cdop = SQLMgr.getPacData(pacId, noAdmision);

al = SQLMgr.getDataPropertiesList("select nota from tbl_sal_notas_diarias_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'"+appendFilter+" order by id desc ");

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
	int iconImgSize = 9;
	int imgSize = 10;
	String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
	String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
	String iconImg = ResourceBundle.getBundle("path").getString("images")+"/blackball.gif";
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

			
			Vector dHeader = new Vector();
			dHeader.addElement(".15");
			dHeader.addElement(".10");
			dHeader.addElement(".02"); 
			dHeader.addElement(".10");
			dHeader.addElement(".02");
			dHeader.addElement(".10");
			dHeader.addElement(".02");
			
			dHeader.addElement(".10");
			dHeader.addElement(".02");
			dHeader.addElement(".10");
			dHeader.addElement(".02");
			
			dHeader.addElement(".10");
			dHeader.addElement(".15");
			
			Vector extra = new Vector();
			extra.addElement(".10");
			extra.addElement(".02");
	
	iconChecked  = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
	iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
					
	
	pc.setNoColumn(1);
	
	//radioChecked table
	pc.createTable("radioChecked",false,0,600);
	pc.addImageCols(iconChecked,10,1);

	//radioUnchecked table
	//(String tableName, boolean splitRowOnEndPage, int showBorder, float margin, float tableWidth)
	pc.createTable("radioUnchecked",false,0,600);
	pc.addImageCols(iconUnchecked,10,1);
	
	
	pc.setNoColumn(1);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(8,1);
	
	if ( al.size() == 0 ) pc.addCols("No hemos encontrado registros!");
	else{
	for ( int i = 0; i<al.size(); i++ ){
		prop = (Properties)al.get(i);
		pc.setFont(fontSize, 1);				
		pc.addCols("Fecha: "+prop.getProperty("fecha"),1,6);
		pc.addCols("Hora: "+prop.getProperty("hora"),0,7);
		
		pc.setVAlignment(1);
		
		pc.setFont(fontSize,1);
		pc.addCols("Se Recibe R. Nac.:",2,1);
		pc.setFont(fontSize,0);
		pc.addCols("Bacineteh",2,1);
		pc.addTableToCols(((prop.getProperty("llegada").equalsIgnoreCase("BA"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Fotografia",2,1);	
		pc.addTableToCols(((prop.getProperty("llegada").equalsIgnoreCase("FO"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("O2",2,1);
		pc.addTableToCols(((prop.getProperty("llegada").equalsIgnoreCase("O2"))?"radioChecked":"radioUnchecked"),1,1,10);							
	    pc.addCols("Incubadora",2,4);
		
		pc.setNoColumnFixWidth(extra);
		pc.createTable("extra",false,0,0.0f,100f);
		  pc.addCols("Abierto",2,1);
		  pc.addTableToCols(((prop.getProperty("llegada2").equalsIgnoreCase("ABI"))?"radioChecked":"radioUnchecked"),1,1,10);
		  pc.addCols("Cerrado",2,1);
		  pc.addTableToCols(((prop.getProperty("llegada2").equalsIgnoreCase("CER"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.useTable("main");
		pc.addTableToCols("extra",0,2,0,null,null,0.0f,0.0f,0.0f,0.0f);
		
		pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
		pc.setFont(fontSize,1);
		pc.addCols("Respiracion:",2,1);
		pc.setFont(fontSize,0);
		pc.addCols("Normal",2,1);
		pc.addTableToCols(((prop.getProperty("respiracion").equalsIgnoreCase("NOR"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Frecuencia",2,1);	
	    pc.addTableToCols(((prop.getProperty("respiracion").equalsIgnoreCase("FRE"))?"radioChecked":"radioUnchecked"),1,1,10);							
		pc.addCols("Quejido",2,1);							
	    pc.addTableToCols(((prop.getProperty("respiracion").equalsIgnoreCase("QUE"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Tiraje",2,1);	
		pc.addTableToCols(((prop.getProperty("respiracion").equalsIgnoreCase("TIR"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Aleteo",2,1);
		pc.addTableToCols(((prop.getProperty("respiracion").equalsIgnoreCase("ALE"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("",0,2);
		
		pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
		pc.setFont(fontSize,1);
		pc.addCols("Llanto:",2,1);
		pc.setFont(fontSize,0);
		pc.addCols("Fuerte",2,1);
		pc.addTableToCols(((prop.getProperty("llanto").equalsIgnoreCase("FU"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Débil",2,1);	
		pc.addTableToCols(((prop.getProperty("llanto").equalsIgnoreCase("DE"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("",0,8);	
		
		pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
		pc.setFont(fontSize,1);
		pc.addCols("Sist. Nervioso:",2,1);
		pc.setFont(fontSize,0);
	    pc.addCols("Activo",2,1);
	    pc.addTableToCols(((prop.getProperty("actividad").equalsIgnoreCase("AC"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Hipoactivo",2,1);	
		pc.addTableToCols(((prop.getProperty("actividad").equalsIgnoreCase("HI"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Hipotónico",2,1);	
		pc.addTableToCols(((prop.getProperty("actividad").equalsIgnoreCase("HIP"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Temblores",2,1);	
	    pc.addTableToCols(((prop.getProperty("actividad").equalsIgnoreCase("TEM"))?"radioChecked":"radioUnchecked"),1,1,10);	
		pc.addCols("Convulsiones",2,1);	
		pc.addTableToCols(((prop.getProperty("actividad").equalsIgnoreCase("CON"))?"radioChecked":"radioUnchecked"),1,1,10);
	    pc.addCols("",0,2);	
		
		pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
		pc.setFont(fontSize,1);
		pc.addCols("Piel:",2,1);
		pc.setFont(fontSize,0);
		pc.addCols("Rosada",2,1);
		pc.addTableToCols(((prop.getProperty("piel").equalsIgnoreCase("AC"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Pálida",2,1);	
		pc.addTableToCols(((prop.getProperty("piel").equalsIgnoreCase("PAL"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.addCols("Cianosis",2,1);	
		pc.addTableToCols(((prop.getProperty("piel").equalsIgnoreCase("CIA"))?"radioChecked":"radioUnchecked"),1,1,10);	
		pc.addCols("Ictericia",2,4);
		
		pc.setNoColumnFixWidth(extra);
		pc.createTable("extra2",false,0,0.0f,100f);
		  pc.addCols("Leve",2,1);
		  pc.addTableToCols(((prop.getProperty("piel2").equalsIgnoreCase("LE"))?"radioChecked":"radioUnchecked"),1,1,10);	
		  pc.addCols("Moderada",2,1);
		  pc.addTableToCols(((prop.getProperty("piel2").equalsIgnoreCase("MO"))?"radioChecked":"radioUnchecked"),1,1,10);
		  pc.addCols("Severa",2,1);
		  pc.addTableToCols(((prop.getProperty("piel2").equalsIgnoreCase("SE"))?"radioChecked":"radioUnchecked"),1,1,10);	
		pc.useTable("main");
		pc.addTableToCols("extra2",0,2,0,null,null,0.0f,0.0f,0.0f,0.0f);
		
		pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
	   pc.setFont(fontSize,1);
	   pc.addCols("Temperatura:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Normotermico",2,1);
	   pc.addTableToCols(((prop.getProperty("temperatura").equalsIgnoreCase("NO"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Hipotermico",2,1);	
	   pc.addTableToCols(((prop.getProperty("temperatura").equalsIgnoreCase("HI"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
	   
	   pc.setFont(fontSize,1);
	   pc.addCols("Succión:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Buena",2,1);
	   pc.addTableToCols(((prop.getProperty("succion").equalsIgnoreCase("B"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Malo",2,1);	
	   pc.addTableToCols(((prop.getProperty("succion").equalsIgnoreCase("M"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);	
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
	   pc.setFont(fontSize,1);
	   pc.addCols("Higiene:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("General",2,1);
	   pc.addTableToCols(((prop.getProperty("bano").equalsIgnoreCase("G"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Parcial",2,1);	
	   pc.addTableToCols(((prop.getProperty("bano").equalsIgnoreCase("P"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);	
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
							
	   pc.setFont(fontSize,1);
	   pc.addCols("Profilaxis:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Si",2,1);
	   pc.addTableToCols(((prop.getProperty("profilaxis").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("No",2,1);	
	   pc.addTableToCols(((prop.getProperty("profilaxis").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);	
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
	   pc.setFont(fontSize,1);	
	   pc.addCols("Ombligo:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Normal",2,1);
	   pc.addTableToCols(((prop.getProperty("Ombligo").equalsIgnoreCase("NOR"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Secreción",2,1);	
	   pc.addTableToCols(((prop.getProperty("Ombligo").equalsIgnoreCase("SEC"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Enrojecimiento",2,1);	
	   pc.addTableToCols(((prop.getProperty("Ombligo").equalsIgnoreCase("ENR"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Hemorragia",2,1);	
	   pc.addTableToCols(((prop.getProperty("Ombligo").equalsIgnoreCase("HEM"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,4);	
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
	
	   pc.setFont(fontSize,1);
	   pc.addCols("Orino:",2,1);	
	   pc.setFont(fontSize,0);
	   pc.addCols("Si",2,1);
	   pc.addTableToCols(((prop.getProperty("orino").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("No",2,1);	
	   pc.addTableToCols(((prop.getProperty("orino").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
	
	   pc.setFont(fontSize,1);
	   pc.addCols("Heces:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Si",2,1);
	   pc.addTableToCols(((prop.getProperty("heces").equalsIgnoreCase("SI"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("No",2,1);	
	   pc.addTableToCols(((prop.getProperty("heces").equalsIgnoreCase("NO"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);	
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
	   pc.setFont(fontSize,1);
	   pc.addCols("Vomito:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Si",2,1);
	   pc.addTableToCols(((prop.getProperty("vomito").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("No",2,1);	
	   pc.addTableToCols(((prop.getProperty("vomito").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
	   
	   pc.setFont(fontSize,1);
	   pc.addCols("Meconio",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Si",2,1);
	   pc.addTableToCols(((prop.getProperty("meconio").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("No",2,1);	
	   pc.addTableToCols(((prop.getProperty("meconio").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);

       pc.setFont(fontSize,1);
	   pc.addCols("Abdomen:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Normal",2,1);
	   pc.addTableToCols(((prop.getProperty("abdomen").equalsIgnoreCase("NOR"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Distindido",2,1);	
	   pc.addTableToCols(((prop.getProperty("abdomen").equalsIgnoreCase("DIS"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,8);
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
			
	   pc.setFont(fontSize,1);
	   pc.addCols("Relacion Madre-Hijo:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Aceptación",2,1);
	   pc.addTableToCols(((prop.getProperty("apego").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Inseguridad",2,1);	
	   pc.addTableToCols(((prop.getProperty("apego").equalsIgnoreCase("INS"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Rechazo",2,1);	
	   pc.addTableToCols(((prop.getProperty("apego").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("",0,6);
	   
	   pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);

	   pc.setFont(fontSize,1);
	   pc.addCols("Alimentación:",2,1);
	   pc.setFont(fontSize,0);
	   pc.addCols("Pecho exclusivo",2,1);
	   pc.addTableToCols(((prop.getProperty("alimentacion").equalsIgnoreCase("PE"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Fórmula",2,1);	
	   pc.addTableToCols(((prop.getProperty("alimentacion").equalsIgnoreCase("FO"))?"radioChecked":"radioUnchecked"),1,1,10);
	   pc.addCols("Sonda",2,1);	
	   pc.addTableToCols(((prop.getProperty("alimentacion").equalsIgnoreCase("SON"))?"radioChecked":"radioUnchecked"),1,1,10);	
	   pc.addCols("Aceptación",2,4);
							
		pc.setNoColumnFixWidth(extra);
		pc.createTable("extra2",false,0,0.0f,100f);					
			 pc.addCols("Buena",2,1);	
			 pc.addTableToCols(((prop.getProperty("alimentacionPor").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10);	
		     pc.addCols("Rechazo",2,1);	
			 pc.addTableToCols(((prop.getProperty("alimentacionPor").equalsIgnoreCase("EP"))?"radioChecked":"radioUnchecked"),1,1,10);	
			 pc.addCols("Regurgitación",2,1);	
		     pc.addTableToCols(((prop.getProperty("alimentacionPor").equalsIgnoreCase("OT"))?"radioChecked":"radioUnchecked"),1,1,10);	
		     pc.addCols("Vomito",2,1);	
			 pc.addTableToCols(((prop.getProperty("alimentacionPor").equalsIgnoreCase("VOM"))?"radioChecked":"radioUnchecked"),1,1,10);
		pc.useTable("main");
		pc.addTableToCols("extra2",0,2,0,null,null,0.0f,0.0f,0.0f,0.0f);	
		
		pc.addCols("- - - - - - - - - - - - - - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size(),15f);
		
		pc.setFont(fontSize,1);
	    pc.addCols("Circuncición",2,1);
		pc.setFont(fontSize,0);
		pc.addCols("Si",2,1);
		pc.addTableToCols(((prop.getProperty("circunscision").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10);
	    pc.addCols("No",2,1);	
	    pc.addTableToCols(((prop.getProperty("circunscision").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10);
	    pc.addCols("",0,8);	
		
		pc.addCols(" ",0,dHeader.size());

	    pc.setFont(fontSize,1);
		pc.addCols("Destrostix:",2,1);
		pc.setFont(fontSize,0);
		pc.addCols(" "+prop.getProperty("dextroxtis"),0,10);
		pc.addCols(" ",2,2);
		
		pc.flushTableBody(true);
		pc.addNewPage();
		
    }//for i
}
	pc.useTable("main");

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>