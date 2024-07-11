<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
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
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();

CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdop = new CommonDataObject();
Properties prop = new Properties();

String lqs = "";
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String seccion = request.getParameter("seccion");
String docTitle = "";
String imgDoc ="";
String desc = request.getParameter("desc");

if (appendFilter == null) appendFilter = "";

cdop = SQLMgr.getPacData(pacId, noAdmision);

prop = SQLMgr.getDataProperties("select evaluacion from tbl_sal_nutricion_parenteral where id="+id+" ");
	
	if (prop == null)
	{ 
		prop = new Properties();
		/*prop.setProperty("id","0");
		prop.setProperty("fecha",""+cDateTime.substring(0,10));
		prop.setProperty("hora_inicio","");
		prop.setProperty("usuario",""+UserDet.getName());*/
	}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if ( desc == null ) desc = "";
	
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
	String title = desc;
	String subtitle = "";
	String xtraSubtitle = ""+docTitle;
	
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
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }

	Vector dHeader = new Vector();
			dHeader.addElement(".22");
			dHeader.addElement(".10");// 51 
			dHeader.addElement(".10");
			dHeader.addElement(".05");
			
			dHeader.addElement(".26");
			dHeader.addElement(".10");
			dHeader.addElement(".06");//49
			dHeader.addElement(".05");
			

	/*Vector dHeader1 = new Vector();
			dHeader1.addElement(".99");
			
	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	Vector infoCol2 = new Vector();
		infoCol2.addElement(".18");
		infoCol2.addElement(".05");
		infoCol2.addElement(".18");
		infoCol2.addElement(".05");
		infoCol2.addElement(".47");
		infoCol2.addElement(".05");
		
	Vector infoCol3 = new Vector();
		infoCol3.addElement(".03");*/
	
	
	
	iconChecked  = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
	iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
					
	
	pc.setNoColumn(1);
	
	//radioChecked table
	pc.createTable("radioChecked",false,2,600);
	pc.addImageCols(iconChecked,10,1);

	//radioUnchecked table
	//(String tableName, boolean splitRowOnEndPage, int showBorder, float margin, float tableWidth)
	pc.createTable("radioUnchecked",false,2,600);
	pc.addImageCols(iconUnchecked,10,1);
	
	
	
	
	pc.setNoColumn(1);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		
	//table body
		
		//radioChecked table
		/*pc.createTable("radioChecked",false,0,588);
		pc.addImageCols(iconChecked,imgSize,1);
	
		//radioUnchecked table
		pc.createTable("radioUnchecked",false,0,588);
		pc.addImageCols(iconUnchecked,imgSize,1);
	*/
		pc.setFont(fontSize, 1);
		String groupBy  = "";
		pc.addBorderCols(prop.getProperty("fecha"),0,4);
		pc.addBorderCols(prop.getProperty("hora"),0,4);
		pc.addBorderCols("",0,dHeader.size());
		
		pc.setFont(fontSize,1,Color.white);
		pc.addBorderCols("Índice de Masa Corporal (IMC)",0,6,Color.gray);
		pc.addBorderCols("",0,1,Color.gray);
		pc.addBorderCols("",0,1,Color.gray);
		pc.addBorderCols("Descripción/Criterio",0,6,Color.gray);
		pc.addBorderCols("SI",0,1,Color.gray);
		pc.addBorderCols("NO",0,1,Color.gray);

					
				/*
				if(cdoz.getColValue("documento") != null && !cdoz.getColValue("documento").trim().equals(""))
				imgDoc =ResourceBundle.getBundle("path").getString("expedientedocs")+cdoz.getColValue("documento");
				else imgDoc = imgDocDefault;
				
				//pc.useTable("main");
				pc.setVAlignment(0);
				pc.setNoColumnFixWidth(dHeader1);
				pc.createTable("imgIcon",true,0,0.0f,584f);
					pc.setFont(9,1);
					//pc.addCols(" ",1,dHeader1.size());
					pc.addImageCols(imgDoc,200,1);
					//pc.addCols(" ",1,dHeader1.size());
				//pc.useTable("imgIcon");
				pc.useTable("main");
				pc.addTableToCols("imgIcon",1,dHeader.size(),210,null,null,0.0f,0.0f,0.0f,0.0f);
				*/
					
					 				
					pc.setFont(fontSize, 0);
		
							
							pc.addBorderCols("¿Adultos: Menos de 20.5 o mayor de 30? ",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar1").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							pc.addTableToCols(((prop.getProperty("aplicar1").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							
						
							pc.addBorderCols("¿Adulto Mayor (Mayor de 70 años): menos de 22 o mayor de 30?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar2").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							pc.addTableToCols(((prop.getProperty("aplicar2").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
												
							
							pc.addBorderCols("¿Embarazada: menor de 20 o mayor de 30?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar3").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							pc.addTableToCols(((prop.getProperty("aplicar3").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							
							
							pc.addBorderCols("¿El paciente ha perdido en los ultimos 3 meses?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar4").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar4").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							
							
							pc.addBorderCols("¿El paciente ha reducido la ingesta de alimentos en ultimas semanas?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar5").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar5").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							
							
							pc.addBorderCols("¿ENFERMEDAD GRAVE?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar6").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar6").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);	
							
							pc.setFont(fontSize, 1);
							pc.addBorderCols("Tamizaje Nutricional en Pediatría",0,6);
		                    pc.addBorderCols("",0);
		                    pc.addBorderCols("",0);		
													
							pc.setFont(fontSize, 0);		
		                   
							pc.addBorderCols("¿El paciente ha reducido la ingesta de alimentos en la última semana?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar7").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar7").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);	
							
						
							pc.addBorderCols("¿El paciente tiene vomito o diarrea?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar8").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar8").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);	
							
						
							pc.addBorderCols("¿El Paciente tiene síndrome de down ó parálisis cerebral infantil?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar9").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar9").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);	
							
						
							pc.addBorderCols("¿ENFERMEDAD GRAVE?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar10").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar10").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);	

	
		pc.addCols(" ",0,dHeader.size());

	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>