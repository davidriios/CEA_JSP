<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="NEEUMgr" scope="page" class="issi.expediente.NotaEvaluacionEnfermeraUrgenciaMgr" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NEEUMgr.setConnection(ConMgr);

Properties prop = new Properties();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

cdoUsr.addColValue("usuario",userName);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
if(desc == null) desc = "";

prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'");

//System.out.println(":::::::::::::::::::::::theBra!n = "+fg);

 String fecha = cDateTime;
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612 
	float height = 72 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = desc;
	String xtraSubtitle = "";
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 5;
	float cHeight = 90.0f;
	
	CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
      
	if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement("10"); 
		dHeader.addElement("10");
		dHeader.addElement("2");
		dHeader.addElement("18");
		dHeader.addElement("2");
		dHeader.addElement("18");
		dHeader.addElement("2");
		dHeader.addElement("18");
		dHeader.addElement("2");
		dHeader.addElement("18");
		
		Vector tblGPCA = new Vector();
		tblGPCA.addElement("8"); //g
		tblGPCA.addElement("17");
		tblGPCA.addElement("8"); //p
		tblGPCA.addElement("17");
		tblGPCA.addElement("8"); //c
		tblGPCA.addElement("17");
		tblGPCA.addElement("8"); //a
		tblGPCA.addElement("17");
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if(prop == null){
		   pc.addCols(".:: No Se Ha Encontrado Registros! ::.",1,dHeader.size());
		}else{
				
			pc.setFont(9,1,Color.white);
			pc.addCols("Evaluación del aspecto físico y sus características",0,dHeader.size(),15f,Color.gray);
			pc.addCols(" ",1,dHeader.size(),15f);
			
			pc.setFont(9,0);
			
			pc.addBorderCols("Fecha: ",0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("fecha"),0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,1,0.1f,0.0f,0.0f,0.0f);
		    pc.addBorderCols("Hora: ",2,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("hora"),0,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,4,0.1f,0.0f,0.0f,0.0f);
			
			pc.addCols(" ",1,dHeader.size(),7f);
			
			pc.setFont(9,1,Color.gray);
			pc.addCols("Neurologico: ",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("neurologico0").equalsIgnoreCase("a"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
            pc.addCols("Alerta",0,1);
			
			pc.addImageCols( (prop.getProperty("neurologico1").equalsIgnoreCase("l"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Letárgico",0,1);
			
			
			pc.addImageCols( (prop.getProperty("neurologico2").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Confuso",0,1);
			
			pc.addImageCols( (prop.getProperty("neurologico3").equalsIgnoreCase("i"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Inconsciente",0,1);
			//eol

			pc.addCols("",0,2);
			pc.addImageCols( (prop.getProperty("neurologico4").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Desorientado",0,1,10f);

			pc.addImageCols( (prop.getProperty("neurologico5").equalsIgnoreCase("co"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Convulsiones",0,1,10f);

			pc.addImageCols( (prop.getProperty("neurologico6").equalsIgnoreCase("p"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Parálisis",0,1,10f);

			pc.addImageCols( (prop.getProperty("neurologico7").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Otros",0,1);

			
			if (prop.getProperty("neurologico7").equalsIgnoreCase("o")){
			  pc.addCols("Comentarios: ",2,2);
			  pc.addCols(prop.getProperty("otros1"),0,8);
			}  
          
		  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);

			   
			pc.setFont(9,1,Color.gray);
			pc.addCols("Cardiovascular: ",0,2);
			
			pc.setFont(9,0);

			pc.addImageCols( (prop.getProperty("cardiovascular0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Normal",0,1,10f);

			pc.addImageCols( (prop.getProperty("cardiovascular1").equalsIgnoreCase("t"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Tarquicadia",0,1,10f);

			pc.addImageCols( (prop.getProperty("cardiovascular2").equalsIgnoreCase("b"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Bradicardia",0,1,10f);

			pc.addImageCols( (prop.getProperty("cardiovascular3").equalsIgnoreCase("p"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Palpitación",0,1,10f);
			
			//eol
			pc.addCols("",0,2);
		    pc.addImageCols( (prop.getProperty("cardiovascular4").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Dolor en el Pecho",0,1,15f);
			
			pc.addImageCols( (prop.getProperty("cardiovascular5").equalsIgnoreCase("m"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Marcapaso",0,1,10f);

			pc.addImageCols( (prop.getProperty("cardiovascular6").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Otros",0,1);
			pc.addCols("",0,2);
			
			if (prop.getProperty("cardiovascular6").equalsIgnoreCase("o")){
			  pc.addCols("Comentarios: ",2,2);
			  pc.addCols(prop.getProperty("otros2"),0,8);
			}  
          
		  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);

			 pc.setFont(9,1,Color.gray);  
			 pc.addCols("Estado Respiratorio: ",0,2);
			 
             pc.setFont(9,0); 
			 pc.addImageCols( (prop.getProperty("respiracion0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Normal",0,1);

			 pc.addImageCols( (prop.getProperty("respiracion1").equalsIgnoreCase("t"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Tos",0,1);

			 pc.addImageCols( (prop.getProperty("respiracion2").equalsIgnoreCase("a"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Aleteo Nasal",0,1);

			 pc.addImageCols( (prop.getProperty("respiracion3").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Disnea",0,1);
			 //eol
			 
			 pc.addCols("",0,2);	
			 pc.addImageCols( (prop.getProperty("respiracion4").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Apnea",0,1);

			 pc.addImageCols( (prop.getProperty("respiracion5").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Otros",0,1);
			 pc.addCols("",0,4);
			 
			 if (prop.getProperty("respiracion5").equalsIgnoreCase("o")){
			  pc.addCols("Comentarios: ",2,2);
			  pc.addCols(prop.getProperty("otros3"),0,8);
			} 
			
			pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			
			
			    pc.setFont(9,1,Color.gray);
				pc.addCols("G.E.T Gastro-intestinal: ",0,2);
				
				pc.setFont(9,0);
				
				pc.addImageCols( (prop.getProperty("get0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Náusea",0,1);
				
				pc.addImageCols( (prop.getProperty("get1").equalsIgnoreCase("v"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Vómito",0,1);
				
				pc.addImageCols( (prop.getProperty("get2").equalsIgnoreCase("u"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Úlceras",0,1);
				
				pc.addImageCols( (prop.getProperty("get3").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Dolor abdominal",0,1);
				
				//eol
				pc.addCols(" ",0,2);
				pc.addImageCols( (prop.getProperty("get4").equalsIgnoreCase("no"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Normal",0,1);
				
				pc.addImageCols( (prop.getProperty("get5").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Otros",0,1);
				pc.addCols(" ",0,4);
				
				if (prop.getProperty("get5").equalsIgnoreCase("o")){
				  pc.addCols("Comentarios: ",2,2);
				  pc.addCols(prop.getProperty("otros4"),0,8);
			    } 
				
				pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			
			
			pc.setFont(9,1,Color.gray);
				pc.addCols("Musculo-esqueletico: ",0,2);
				
				pc.setFont(9,0);
				
				pc.addImageCols( (prop.getProperty("esquel0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Normal",0,1);
				
				pc.addImageCols( (prop.getProperty("esquel1").equalsIgnoreCase("g"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Golpe",0,1);
				
				pc.addImageCols( (prop.getProperty("esquel2").equalsIgnoreCase("t"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Trauma",0,1);
				
				pc.addImageCols( (prop.getProperty("esquel3").equalsIgnoreCase("a"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Adorcimiento en extremidades",0,1);
			
			 //eol
			 
			 pc.addCols("",0,2);
			 pc.addImageCols( (prop.getProperty("esquel4").equalsIgnoreCase("e"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Edemas en extremidades",0,1,15f);
			
			 pc.addImageCols( (prop.getProperty("esquel5").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Otros",0,1);
			 pc.addCols("",0,4);
			 
			 if (prop.getProperty("esquel5").equalsIgnoreCase("o")){
			  pc.addCols("Comentarios: ",2,2);
			  pc.addCols(prop.getProperty("otros5"),0,8);
			} 
			
			pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			
			
			pc.setFont(9,1,Color.gray);
			   
			 pc.addCols("Tegumentos (Piel): ",0,2);  
			 
			 pc.setFont(9,0);

			 pc.addImageCols( (prop.getProperty("piel0").equalsIgnoreCase("p"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Pálido",0,1);

			 pc.addImageCols( (prop.getProperty("piel1").equalsIgnoreCase("m"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Moteado",0,1);
			
			 pc.addImageCols( (prop.getProperty("piel2").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Cianosis",0,1);

			 pc.addImageCols( (prop.getProperty("piel3").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Diaforesis",0,1);
			 //eol

			 pc.addCols("",0,2);
			 pc.addImageCols( (prop.getProperty("piel4").equalsIgnoreCase("h"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Herida",0,1);

			 pc.addImageCols( (prop.getProperty("piel5").equalsIgnoreCase("he"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Hematoma",0,1);
			 
			 pc.addImageCols( (prop.getProperty("piel6").equalsIgnoreCase("i"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
		     pc.addCols("Ictericia",0,1);
			  
			pc.addImageCols( (prop.getProperty("piel7").equalsIgnoreCase("u"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Ulceras",0,1);
			//eol
			
			 pc.addCols("",0,2);
			 pc.addImageCols( (prop.getProperty("piel8").equalsIgnoreCase("q"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Quemaduras",0,1);

			 pc.addImageCols( (prop.getProperty("piel9").equalsIgnoreCase("er"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Eritema",0,1);
			 
			 pc.addImageCols( (prop.getProperty("piel10").equalsIgnoreCase("ex"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
		     pc.addCols("Exantema",0,1);
			  
			pc.addImageCols( (prop.getProperty("piel11").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Normal",0,1);
		  
		  //eol
			  
		pc.addCols("",0,2);  
		pc.addImageCols( (prop.getProperty("piel12").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
		pc.addCols("Otros",0,1);
		pc.addCols("",0,6);	 
			 
			 
	   if (prop.getProperty("piel12").equalsIgnoreCase("o")){
	      pc.addCols("Comentarios: ",2,2);
	      pc.addCols(prop.getProperty("otros6"),0,8);
	    }
			
			pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			
			
			 pc.setFont(9,1,Color.gray);
			 pc.addCols("Psicológico: ",0,2);
			
			 pc.setFont(9,0); 
			  
			  pc.addImageCols( (prop.getProperty("psico0").equalsIgnoreCase("a"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Ansioso",0,1,10f);

			  pc.addImageCols( (prop.getProperty("psico1").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Deprimido",0,1,10f);
			  
			  pc.addImageCols( (prop.getProperty("psico2").equalsIgnoreCase("h"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Hostil",0,1,10f);
			  
			  pc.addImageCols( (prop.getProperty("psico3").equalsIgnoreCase("ag"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Agresivo",0,1,10f);
			 
			 //eol
			 
			 pc.addCols(" ",0,2);
			  pc.addImageCols( (prop.getProperty("psico4").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Normal",0,1,10f);

			  pc.addImageCols( (prop.getProperty("psico5").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Otros",0,1,10f);
			 pc.addCols("",0,4);
			 
			 //eol
			 
			 if (prop.getProperty("psico5").equalsIgnoreCase("o")){
				  pc.addCols("Comentarios: ",2,2);
				  pc.addCols(prop.getProperty("otros7"),0,8);
			    }
			
			 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			
			
			pc.setFont(9,1,Color.gray);
			pc.addCols("Alergia: ",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("No Alergia",0,1);
			
			pc.addImageCols( (prop.getProperty("alergia1").equalsIgnoreCase("a")&&!prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Alimentos",0,1);
			
			pc.addImageCols( (prop.getProperty("alergia2").equalsIgnoreCase("ai")&&!prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Aines",0,1);
			
			pc.addImageCols( (prop.getProperty("alergia3").equalsIgnoreCase("at")&&!prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Antibióticos",0,1);
			//eol
			
			pc.addCols("",0,2);
			pc.addImageCols( (prop.getProperty("alergia4").equalsIgnoreCase("m")&&!prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Medicamentos",0,1);
			
			pc.addImageCols( (prop.getProperty("alergia5").equalsIgnoreCase("y")&&!prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("YODO",0,1);
			
			pc.addImageCols( (prop.getProperty("alergia6").equalsIgnoreCase("s")&&!prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Sulfa",0,1);
			
			pc.addImageCols( (prop.getProperty("alergia7").equalsIgnoreCase("o")&&!prop.getProperty("alergia0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Otros",0,1);
			//eol
	
			if( prop.getProperty("alergia7").equalsIgnoreCase("o")&&!prop.getProperty("alergia0").equalsIgnoreCase("n")){
			pc.addCols("Comentarios: ",2,2);
			pc.addCols(prop.getProperty("otros8"),0,8);
			}
			
			 
			pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f); 
			
			
			pc.setFont(9,1,Color.gray);
			pc.addCols("Antecedentes Patologicos Personales: ",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("antpat0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Sin Antecedentes Patologicos",0,1);
			
			pc.addImageCols( (prop.getProperty("antpat1").equalsIgnoreCase("h"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Hipertensión Arterial",0,1);
			
			pc.addImageCols( (prop.getProperty("antpat2").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Diabetes",0,1);
			
			pc.addImageCols( (prop.getProperty("antpat3").equalsIgnoreCase("pr"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Problemas Renales",0,1);
			//eol
			
			pc.addCols("",0,2);
		    pc.addImageCols( (prop.getProperty("antpat4").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Otros",0,1);
			pc.addCols("",0,6);
			//eol
			
			if( prop.getProperty("antpat4").equalsIgnoreCase("o")){
			pc.addCols("Comentarios: ",2,2);
			pc.addCols(prop.getProperty("otros9"),0,8);
			}
			
			//pc.setFont(9,1,Color.gray);
			pc.addCols("Medicamentos Actuales: ",2,2);
			pc.addCols((prop.getProperty("medUsado")!=null?prop.getProperty("medUsado"):""),0,8);
			
			pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f); 
			
			pc.setFont(9,1,Color.gray);
			pc.addCols("Nutricional: ",0,2);
	
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("nutricional0").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Come bien",0,1);

			pc.addImageCols( (prop.getProperty("nutricional1").equalsIgnoreCase("t"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Tubo nasogastrico",0,1);

			 pc.addImageCols( (prop.getProperty("nutricional2").equalsIgnoreCase("g"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Gastrostomía",0,1);

			 pc.addImageCols( (prop.getProperty("nutricional3").equalsIgnoreCase("ca"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Caquexico",0,1);
			  //eol
			  
			  pc.addCols(" ",0,2);
			  pc.addImageCols( (prop.getProperty("nutricional4").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Otros",0,1);
			 
			 pc.addCols(" ",0,6);
			 
			 if( prop.getProperty("nutricional4").equalsIgnoreCase("o")){
					pc.addCols("Comentarios: ",2,2);
					pc.addCols(prop.getProperty("otros10"),0,8);
			}
			 
			 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			 
			 
			 pc.setFont(9,1,Color.gray);
			pc.addCols("Genito-Urinario: ",0,2); 
			 
			pc.setFont(9,0); 
			pc.addImageCols( (prop.getProperty("genito0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Normal",0,1); 
			
			pc.addImageCols( (prop.getProperty("genito1").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Disuria",0,1); 
			
			pc.addImageCols( (prop.getProperty("genito2").equalsIgnoreCase("ol"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Oliguria",0,1); 
			
			pc.addImageCols( (prop.getProperty("genito3").equalsIgnoreCase("p"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Poliuria",0,1);
			//eol
			
			pc.addCols("",0,2); 
			pc.setFont(9,0); 
			pc.addImageCols( (prop.getProperty("genito4").equalsIgnoreCase("h"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Hematuria",0,1); 
			
			pc.addImageCols( (prop.getProperty("genito5").equalsIgnoreCase("i"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Incontinencia",0,1); 
			
			pc.addImageCols( (prop.getProperty("genito6").equalsIgnoreCase("ru"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Retención Urinaria",0,1); 
			
			pc.addImageCols( (prop.getProperty("genito7").equalsIgnoreCase("do"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Dolor",0,1); //eol
			
			pc.addCols("",0,2); 
			pc.addImageCols( (prop.getProperty("genito8").equalsIgnoreCase("ar"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Ardor",0,1); 
			
			pc.addImageCols( (prop.getProperty("genito9").equalsIgnoreCase("ar"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Otros",0,5); 
			
			if( prop.getProperty("genito9").equalsIgnoreCase("o")){
					pc.addCols("Comentarios: ",2,2);
					pc.addCols(prop.getProperty("otros12"),0,8);
			}
			
			pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			
			 pc.setFont(9,1,Color.gray);
			pc.addCols("Patrón de Eliminación: ",0,2); 
			 
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("patron0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Normal",0,1);
			
			pc.addImageCols( (prop.getProperty("patron1").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Constipado",0,1);
			
			pc.addImageCols( (prop.getProperty("patron2").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Diarrea",0,1);
			
			pc.addImageCols( (prop.getProperty("patron3").equalsIgnoreCase("m"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Meleno",0,1);
			
			//eol
			
			pc.addCols(" ",0,2);
			pc.addImageCols( (prop.getProperty("patron4").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Otros",0,1);
			pc.addCols("",0,6);
			
			if( prop.getProperty("patron4").equalsIgnoreCase("o")){
					pc.addCols("Comentarios: ",2,2);
					pc.addCols(prop.getProperty("otros11"),0,8);
			}
			
			pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
				
				pc.setFont(9,1,Color.gray);
				pc.addCols("Inmunizaciones:",0,2);
				
				pc.setFont(9,0);
				pc.addImageCols( (prop.getProperty("inmuni").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Completo",0,1);
				
				pc.addImageCols( (prop.getProperty("inmuni").equalsIgnoreCase("i"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("Incompleto",0,1);
				
				pc.addCols("",0,4);
				
				pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
				
					pc.setFont(9,1,Color.white);
				pc.addCols("Historial Transfusional",0,dHeader.size(),15f,Color.gray);
					pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),5f);
				
				pc.setFont(9,1,Color.gray);
				pc.addCols("Transfusiones de Componentes Sanguineos: ",0,2);
				
				pc.setFont(9,0);
				pc.addImageCols( (prop.getProperty("transf").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("SI",0,1);
				
				pc.addImageCols( (prop.getProperty("transf").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("NO",0,1);
				pc.addCols("",0,4);
				
					pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),10f);
					

				
				pc.setFont(9,1,Color.gray);
				pc.addCols("Reacción adversa: ",0,2);
				
				pc.setFont(9,0);
				
				pc.addImageCols( (prop.getProperty("reac").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("SI",0,1);
			
				pc.addImageCols( (prop.getProperty("reac").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("NO",0,1);
				
				pc.addCols("",0,4);	
				
				pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
			
			 pc.setFont(9,1,Color.white);
			 pc.addCols("Historia Obstetrica: ",0,4,15f,Color.gray);
			
			 pc.addCols("Esta Embarazada?: ",0,6,15f,Color.gray);
			  pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),5f);
			  
			pc.setFont(9,0);
			 pc.addCols("",0,4);
			 pc.addImageCols( (prop.getProperty("historiaobs").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("historiaobs").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("NO",0,1);
			pc.addCols("",0,2);
			
			 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),5f);
						
			 	pc.setFont(9,1,Color.gray);
				pc.addCols("FUM:",2,2);
				pc.setFont(9,0);
				pc.addCols(prop.getProperty("fum"),0,3);
				
				pc.setFont(9,1,Color.gray);
				pc.addCols(" ",0,1);
				
				   
		/* tabla gpca */   
	    pc.setNoColumnFixWidth(tblGPCA);
		pc.createTable("gpcea",false,0,0.0f,150f);
		pc.addCols("G");
		pc.addBorderCols(prop.getProperty("g"),1,1,0.1f,0.0f, 0.0f,0.0f);
		pc.addCols("P",1,1);
		pc.addBorderCols(prop.getProperty("p"),1,1,0.1f,0.0f, 0.0f,0.0f);
		pc.addCols("C",0,1);
		pc.addBorderCols(prop.getProperty("c"),1,1,0.1f,0.0f, 0.0f,0.0f);
		pc.addCols("A",0,1);
		pc.addBorderCols(prop.getProperty("a"),1,1,0.1f,0.0f, 0.0f,0.0f);
		
		pc.useTable("main");
		pc.addTableToCols("gpcea",0,4,0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.setFont(9,0);
			   
				
				 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),5f);
	
				pc.setFont(9,1,Color.gray);
				pc.addCols("FUP:",2,2);
				pc.setFont(9,0);
				pc.addCols(prop.getProperty("fup"),0,8);
				
				 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),5f);
			
				pc.setFont(9,1,Color.gray);
				pc.addCols("Control Prenatal:",2,2);
				pc.setFont(9,0);
				pc.addImageCols( (prop.getProperty("ctrl").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			    pc.addCols("SI",0,1);
				
				pc.addImageCols( (prop.getProperty("ctrl").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("NO",0,1);
				pc.addCols("",0,4);
				
				 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),5f);
				
				pc.setFont(9,1,Color.gray);
				pc.addCols("Ginecologo:",2,2);
				pc.setFont(9,0);
				pc.addCols(prop.getProperty("gin"),0,8);
			 
			 	pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
				

			 
			/*pc.setFont(9,1,Color.gray);
			pc.addCols("Historial de Salud: ",0,2);

			pc.setFont(9,0);
			
			 pc.addImageCols( (prop.getProperty("historial").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			 pc.addCols("Sin Historial",0,1);
			 
			  pc.addImageCols( (prop.getProperty("historial").equalsIgnoreCase("h"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Hipertensión Arterial",0,1);
			  
			  pc.addImageCols( (prop.getProperty("historial").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Diabetes",0,1);
			  
			  pc.addImageCols( (prop.getProperty("historial").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Problemas Cardíacos",0,1);
			  //eol
			  
			  pc.addCols("",0,2);
			  pc.addImageCols( (prop.getProperty("historial").equalsIgnoreCase("o"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			  pc.addCols("Otros",0,1);
			  pc.addCols("",0,6);
			  
			  if (prop.getProperty("historial").equalsIgnoreCase("o")){
			  pc.addCols("Comentarios: ",2,2);
			  pc.addCols(prop.getProperty("otros5"),0,8);
			 }
			 
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);*/
			
			
			
			 
			pc.setFont(9,1,Color.gray);
			pc.addCols("Area designada: ",0,2); 
			 
			pc.setFont(9,0); 
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("ca"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Consultorio Adulto",0,1); 
			
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("cp"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Consultorio Pediatria",0,1); 
			
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("oa"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Observación Adulto",0,1); 
			
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("op"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Observación Pediatria",0,1);
			//eol
			
			pc.addCols("",0,2);
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Curaciones",0,1);
			
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("or"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Ortopedia",0,1);  
			
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("g"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Ginecología",0,1);  
			
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("r"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Reanimación",0,1);
			//eol
			
			pc.addCols("",0,2);
			pc.addImageCols( (prop.getProperty("area").equalsIgnoreCase("rs"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Respiratoria",0,1);  
			pc.addCols("",0,6);
			 
			 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f); 
			 
				
				
				pc.setFont(9,1,Color.gray);
				pc.addCols("Esta usted lactando actualmente?",0,4);
				
				pc.setFont(9,0);
				pc.addImageCols( (prop.getProperty("lactancia").equalsIgnoreCase("N"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("NO",0,1);
				
				pc.addImageCols( (prop.getProperty("lactancia").equalsIgnoreCase("S"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
				pc.addCols("SI",0,1);
				pc.addCols("",0,2);
				
				 pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
				 
				pc.setFont(9,1,Color.gray);
				pc.addCols("Historia Actual:",0,2);
				pc.setFont(9,0);
				pc.addCols((prop.getProperty("historiaActual")==null?"":prop.getProperty("historiaActual")),0,8);
			
				
			
				
			
			
			
			   
		
		}//else
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>