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
REPORTE: TRAMIZAJE NUTRICIONAL 
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
CommonDataObject cdo, cdoPacData, cdoTitle = new CommonDataObject();
Properties prop = new Properties();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String id = request.getParameter("id");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

String docTitle = "";
String imgDoc ="";
if ( desc == null ) desc = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
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
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
    
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".06");
			dHeader.addElement(".22");
			dHeader.addElement(".10");// 51 
			dHeader.addElement(".10");
			dHeader.addElement(".05");
			
			dHeader.addElement(".26");
			dHeader.addElement(".10");
			dHeader.addElement(".06");//49
			dHeader.addElement(".05");
			

	Vector dHeader1 = new Vector();
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
		infoCol3.addElement(".03");
	
	
	
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
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();			
		pc.addInnerTableToCols(dHeader.size());


			pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
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
		
		pc.addCols("Fecha: "+prop.getProperty("fecha"),0,2);
		pc.addCols("Hora: "+prop.getProperty("hora"),0,2);
		pc.addCols("",0,5);
		pc.addCols("  ",0,dHeader.size());

		pc.addBorderCols("TABLA 1",0,dHeader.size());
		
		pc.addBorderCols("No.",1);
		pc.addBorderCols("DESCRIPCIÓN",0,6);
		pc.addBorderCols("SI",1);
		pc.addBorderCols("NO",1);

					
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
		
							pc.addBorderCols("1.",0,1);
							pc.addBorderCols("¿IMC < 20.5? ",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar1").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar1").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							
							pc.addBorderCols("2.",0,1);
							pc.addBorderCols("¿PERDIDA DE PESO EN LOS ULTIMOS 3 MESES?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar2").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar2").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
												
							pc.addBorderCols("3.",0,1);
							pc.addBorderCols("¿DISMINUCIÓN EN LA INGESTA EN LA ÚLTIMA SEMANA?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar3").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar3").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							
							pc.addBorderCols("4.",0,1);
							pc.addBorderCols("¿ENFERMEDAD GRAVE?",0,6);
							pc.addTableToCols(((prop.getProperty("aplicar4").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
								
							pc.addTableToCols(((prop.getProperty("aplicar4").equalsIgnoreCase("N"))?"radioChecked":"radioUnchecked"),0,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
		
				
				
				
				
				pc.addCols(" ",0,dHeader.size());
				
				pc.addBorderCols("TABLA 2",0,dHeader.size());
				
				pc.addBorderCols("ESTADO NUTRICIONAL",1,5);
				pc.addBorderCols("SEVERIDAD ENFERMEDAD",1,4);
						
						
						
							pc.addBorderCols("Descripción",1,2);
							pc.addBorderCols("Categoria",1,1);
							pc.addBorderCols("Puntos",1,1);
							pc.addBorderCols("Sí",1,1);
							pc.addBorderCols("Descripción",1,1);
							pc.addBorderCols("Categoria",1,1);
							pc.addBorderCols("Puntos",1,1);
							pc.addBorderCols("Sí",1,1);
							
							//pc.addBorderCols("Estado Nutricional Normal",2);
							
			
			 pc.addBorderCols("Estado Nutricional Normal",0,2);
			 pc.addBorderCols("Ausente",0,1);
			 pc.addBorderCols("0",1,1);
			 pc.addTableToCols(((prop.getProperty("check1").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
			 pc.addBorderCols("Requerimientos Nutricionales Normales",0,1);
			 pc.addBorderCols("Ausente",0,1);
			 pc.addBorderCols("0",1,1);
			 pc.addTableToCols(((prop.getProperty("ckPuntos1").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
			  
			 pc.addBorderCols("Pérdida de peso > 5 % en 3 meses ó ingesta 50-75 % requerimientos en la ultima semana",0,2);
			 pc.addBorderCols("Leve",0,1);
			 pc.addBorderCols("1",1,1);
			 pc.addTableToCols(((prop.getProperty("check2").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
			 pc.addBorderCols("Fractura cadera, pacientes crónicos(cirrosis,EPOC, hemodialisis, DM,Oncológicos)",0,1);
			 pc.addBorderCols("Leve",0,1);
			 pc.addBorderCols("1",1,1);
			 pc.addTableToCols(((prop.getProperty("ckPuntos2").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),3,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
			 
			 pc.addBorderCols("Pérdida de peso > 5 % en 2 meses ó IMC 18.5 - 20.5 + deterioro estado general ó ingesta 25-60 % requerimientos en la última semana",0,2);
			 pc.addBorderCols("Moderado",0,1);
			 pc.addBorderCols("2",1,1);
			 pc.addTableToCols(((prop.getProperty("check3").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
			 pc.addBorderCols("Cirugía mayor abdominal,Ictus,Neumonía grave,Neoplasias hemotológicas",0,1);
			 pc.addBorderCols("Moderado",0,1);
			 pc.addBorderCols("2",1,1);
			 pc.addTableToCols(((prop.getProperty("ckPuntos3").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
							
			 pc.addBorderCols("Pérdida de peso > 5 % en 1 meses(>15 % en 3 meses) ó IMC 18.5 + deterioro estado general ó ingesta 0-25 % requerimientos en la última semana",0,2);
			 pc.addBorderCols("Severo",0,1);
			 pc.addBorderCols("3",1,1);
			 pc.addTableToCols(((prop.getProperty("check4").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,1,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
			
			 pc.addBorderCols("TCE,TMO, Pacientes críticos (UCI)",0,1);
			 pc.addBorderCols("Severo",0,1);
			 pc.addBorderCols("3",1,1);
			 pc.addTableToCols(((prop.getProperty("ckPuntos4").equalsIgnoreCase("S"))?"radioChecked":"radioUnchecked"),1,0,10,Color.white,Color.black,0.5f, 0.5f, 0.5f, 0.5f);
			
			 pc.addBorderCols("Total:   ",2,3);
			 pc.addBorderCols(" "+prop.getProperty("total1")+"     ",1,1);
			 pc.addBorderCols(" ",1,1);
			 pc.addBorderCols("Total:   ",2,2);
			 pc.addBorderCols(" "+prop.getProperty("total1")+"     ",1,1);
			 pc.addBorderCols(" ",1,1);
			 
			 pc.addCols("Si la suma total es >= 3 requiere iniciar un plan de Terapia Nutricional con:",0,dHeader.size());
			 pc.addCols("1. Suplementación oral + Dieta usual",0,dHeader.size());
			 pc.addCols("2. Nutrición Enteral por sonda nasoenteral",0,dHeader.size());
			 pc.addCols("3. Nutrición Parenteral Total o Periférica",0,dHeader.size());
			
			
			

			 

	
		pc.addCols(" ",0,dHeader.size());

	//if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.useTable("main");
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>