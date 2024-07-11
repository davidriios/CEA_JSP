<%// @ page errorPage="../error.jsp" %>
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
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

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
String fp = request.getParameter("fp");
String codigo = request.getParameter("codigo");

if (fg == null) fg = "";
if (fp == null) fp = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
prop = SQLMgr.getDataProperties("select hist from TBL_SAL_HIST_CLI_NEONATAL where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo);
if (prop == null) prop = new Properties();

cdo = SQLMgr.getData("select usuario_creacion, usuario_modificacion, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi am') fecha_modificacion from TBL_SAL_HIST_CLI_NEONATAL where pac_id="+pacId+" and admision="+noAdmision+" and codigo = "+codigo);

if (cdo == null) cdo = new CommonDataObject();

prop.setProperty("fecha_creacion", cdo.getColValue("fecha_creacion"));
prop.setProperty("usuario_creacion", cdo.getColValue("usuario_creacion"));
prop.setProperty("usuario_modificacion", cdo.getColValue("usuario_modificacion"));
prop.setProperty("fecha_modificacion", cdo.getColValue("fecha_modificacion"));

  String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	float leftRightMargin = 15.0f;
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
    dHeader.addElement("25"); 
    dHeader.addElement("25"); 
    dHeader.addElement("25"); 
    dHeader.addElement("25"); 

    if (prop == null) prop = new Properties();
		
    pc.setNoColumnFixWidth(dHeader);
    pc.createTable();
        
    pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
    pc.setTableHeader(3);
        
    pc.setFont(10,0);
      
    pc.addBorderCols("Fecha creación:",0,1,0.1f,0.0f,0.0f,0.0f);
    pc.addBorderCols(prop.getProperty("fecha_creacion"),0,1,0.1f,0.0f,0.0f,0.0f);
    pc.addBorderCols("Usuario creación:",1,1,0.1f,0.0f,0.0f,0.0f);
    pc.addBorderCols(prop.getProperty("usuario_creacion"),0,1,0.1f,0.0f,0.0f,0.0f);
    
    /*
      if (prop.getProperty("fecha_modificacion") != null && !prop.getProperty("fecha_modificacion").equals("")) {
        pc.addBorderCols("Fecha modif.:",0,1,0.1f,0.0f,0.0f,0.0f);
        pc.addBorderCols(prop.getProperty("fecha_modificacion"),0,1,0.1f,0.0f,0.0f,0.0f);
        pc.addBorderCols("Usuario modif.:",1,1,0.1f,0.0f,0.0f,0.0f);
        pc.addBorderCols(prop.getProperty("usuario_modificacion"),0,1,0.1f,0.0f,0.0f,0.0f);
      }
    */
    
    pc.addCols(" ",1,dHeader.size());
    
    Vector tblDM = new Vector();
    tblDM.addElement("10"); 
    tblDM.addElement("10"); 
    tblDM.addElement("20"); 
    tblDM.addElement("10");
    tblDM.addElement("30"); 
    tblDM.addElement("20");
    
    pc.setNoColumnFixWidth(tblDM);
    pc.createTable("tblDM");

    pc.setFont(11,1, Color.white);
    pc.addCols("DATOS MATERNOS", 1, tblDM.size(), Color.gray);
    
    // 1
    pc.setFont(10,1);
    pc.addBorderCols("F.U.M",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("GRAVA",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("PARA",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("ABORTOS",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("NO. de CONTROLES PRENATALES",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("SENSIBILIZACIÓN",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setVAlignment(1);
    pc.setFont(10,0);
    pc.addBorderCols(prop.getProperty("data1"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data2"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("Vaginal: "+prop.getProperty("data3")+"     Cesárea: "+prop.getProperty("data4"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data5"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data6"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    String sensibilizacion = "";
    
    if (prop.getProperty("data7")!= null && prop.getProperty("data7").equalsIgnoreCase("S")) sensibilizacion = "Rh:      SI";
    else if (prop.getProperty("data7")!= null && prop.getProperty("data7").equalsIgnoreCase("N")) sensibilizacion = "Rh:      NO";
    
    if (prop.getProperty("data8")!= null && prop.getProperty("data8").equalsIgnoreCase("S")) sensibilizacion += "\nABO:   SI";
    else if (prop.getProperty("data8")!= null && prop.getProperty("data8").equalsIgnoreCase("N")) sensibilizacion += "\nABO:   NO";
    
    pc.addBorderCols(sensibilizacion,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    // 2
    pc.setVAlignment(0);
    pc.setFont(10,1);
    pc.addBorderCols("SEROLOGÍA - LUES",1, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("RUPTURAS DE MEMBRANAS (Horas)",1, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("EDAD GEST. (Sem.)",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("PATOLOGÍA",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(10,0);
    if (prop.getProperty("data9")!= null && prop.getProperty("data9").equalsIgnoreCase("S")) pc.addBorderCols("Positivo",1, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data9")!= null && prop.getProperty("data9").equalsIgnoreCase("N")) pc.addBorderCols("Negativo",1, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",1, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.addBorderCols(prop.getProperty("data10"),1, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data11"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    String patologia = "";
    if (prop.getProperty("data12")!= null && prop.getProperty("data12").equalsIgnoreCase("S")) {
      patologia = "SI\n"+prop.getProperty("observacion12");
    }
    else if (prop.getProperty("data12")!= null && prop.getProperty("data12").equalsIgnoreCase("N")) patologia = "NO";
    
    pc.addBorderCols(patologia ,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    // 3
    pc.setVAlignment(0);
    pc.setFont(10,1);
    pc.addBorderCols("PATOLOGÍA EN HIJOS ANTERIORES",0, tblDM.size(), 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(10,0);
    
    if (prop.getProperty("data13")!= null && prop.getProperty("data13").equalsIgnoreCase("S")) {
      pc.addBorderCols("SI\n"+prop.getProperty("observacion13"),0, tblDM.size());
    }
    else if (prop.getProperty("data13")!= null && prop.getProperty("data13").equalsIgnoreCase("N")) pc.addBorderCols("NO",0, tblDM.size(), 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, tblDM.size(), 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(10,1);
    pc.addBorderCols("ANOMALÍAS CONGENITAS EN HIJOS ANTERIORES",0, tblDM.size(), 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(10,0);
    
    if (prop.getProperty("data72")!= null && prop.getProperty("data72").equalsIgnoreCase("S")) {
      pc.addBorderCols("SI\n"+prop.getProperty("observacion18"),0, tblDM.size(), 0.1f, 0.1f, 0.1f, 0.1f);
    }
    else if (prop.getProperty("data72")!= null && prop.getProperty("data72").equalsIgnoreCase("N")) pc.addBorderCols("NO",0, tblDM.size(), 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, tblDM.size(), 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(11,1, Color.white);
    pc.setVAlignment(1);
    pc.addCols(" ",1, tblDM.size());
    pc.addCols("DATOS DEL PARTO (Anotar cualquier ampliación en Observaciones precedida por el Número del ITEM)",1, tblDM.size(), Color.gray);
    pc.setVAlignment(0);
    
    Vector tblDP = new Vector();
    tblDP.addElement("20");
    tblDP.addElement("20");
    tblDP.addElement("20");
    tblDP.addElement("15");
    tblDP.addElement("25");
    
    pc.setNoColumnFixWidth(tblDP);
    pc.createTable("tblDP");
    
    pc.setFont(9,1);
    pc.addBorderCols("1. COMIENZO DE PARTO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("2. FORMA TERMINACIÓN",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("3. HORAS DE LABOR",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("4. PRESENTACIÓN",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("5. TIPO LÍQUIDO AMNIÓTICO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,0);
    
    if (prop.getProperty("data14")!= null && prop.getProperty("data14").equalsIgnoreCase("E")) pc.addBorderCols("Espontaneo",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data14")!= null && prop.getProperty("data14").equalsIgnoreCase("I")) pc.addBorderCols("Inducido",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);

    pc.addBorderCols(prop.getProperty("data15"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data16"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data17"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    if (prop.getProperty("data18")!= null && prop.getProperty("data18").equalsIgnoreCase("C")) pc.addBorderCols("Claro",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data18")!= null && prop.getProperty("data18").equalsIgnoreCase("S")) pc.addBorderCols("Sanguinolento",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data18")!= null && prop.getProperty("data18").equalsIgnoreCase("M")) pc.addBorderCols("Mecomial",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data18")!= null && prop.getProperty("data18").equalsIgnoreCase("OT")) pc.addBorderCols("Otros",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addBorderCols("MOTIVOS DE LA CESAREA",0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("7. SIGNOS DE SUFRIMIENTO FETAL",0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    
    String sufrimientoFetal = "";
    
    pc.setFont(9,0);
    pc.addBorderCols(prop.getProperty("observacion14"),0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    if (prop.getProperty("data22")!= null && prop.getProperty("data22").equalsIgnoreCase("S")) sufrimientoFetal = "SI";
    else if (prop.getProperty("data22")!= null && prop.getProperty("data22").equalsIgnoreCase("N"))  sufrimientoFetal = "NO";
    else if (prop.getProperty("data22")!= null && prop.getProperty("data22").equalsIgnoreCase("I"))  sufrimientoFetal = "IGNORADO";
    
    sufrimientoFetal += "\n\nMONITOREO:   ";
    if (prop.getProperty("data23")!= null && prop.getProperty("data23").equalsIgnoreCase("S")) sufrimientoFetal += "SI";
    else if (prop.getProperty("data23")!= null && prop.getProperty("data23").equalsIgnoreCase("N")) sufrimientoFetal += "NO";
    
    pc.addBorderCols(sufrimientoFetal,0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
 
    pc.setFont(9,1);
    pc.addBorderCols("6. DROGAS",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("NOMBRE",0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("TIEMPO ANTEPARTO - DOSIS",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    String data = "";
    
    pc.setFont(9,0);
    if (prop.getProperty("data24")!= null && prop.getProperty("data24").equalsIgnoreCase("S")) pc.addBorderCols("SI",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data24")!= null && prop.getProperty("data24").equalsIgnoreCase("N")) pc.addBorderCols("NO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.addBorderCols(prop.getProperty("data25"),0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data26"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addBorderCols("8. ANALISIS DE LA SANGRE DEL CORDÓN",0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("",0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("9. ECOGRAFÍA",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9, 0);
    
    if (prop.getProperty("data27")!= null && prop.getProperty("data27").equalsIgnoreCase("S")) {
      pc.addBorderCols("SI\n"+prop.getProperty("observacion15"),0, 4, 0.1f, 0.1f, 0.1f, 0.1f);
    }
    else if (prop.getProperty("data27")!= null && prop.getProperty("data27").equalsIgnoreCase("N")) pc.addBorderCols("NO",0, 4, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 4, 0.1f, 0.1f, 0.1f, 0.1f);
    
    if (prop.getProperty("data28")!= null && prop.getProperty("data28").equalsIgnoreCase("S")) pc.addBorderCols("Anormal",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data28")!= null && prop.getProperty("data28").equalsIgnoreCase("N")) pc.addBorderCols("Normal",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    CommonDataObject cdoBB = SQLMgr.getData("select to_char(fecha_nacimiento, 'dd | mm | yyyy')||'   '||to_char(hora_nacimiento, 'hh12:mi am') fn from tbl_adm_neonato where pac_id = "+pacId);
    if (cdoBB == null) cdoBB = new CommonDataObject();
    pc.setFont(9,1);
    pc.addBorderCols("FECHA DE NACIMIENTO (RECIEN NACIDO)",0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(cdoBB.getColValue("fn", " "),0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addBorderCols("10. RECIEN NACIDO ATENDIDO POR",0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("11. RECIEN NACIDO ATENDIDO EN",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("12. NACIMIENTO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("13. CORDON",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9, 0);
    
    data = "";
    if (prop.getProperty("data29")!=null && prop.getProperty("data29").equals("1")) data += "[ X ] Neonatología";
    if (prop.getProperty("data30")!=null && prop.getProperty("data30").equals("2")) data += "\n[ X ] Médico general";
    if (prop.getProperty("data31")!=null && prop.getProperty("data31").equals("3")) data += "\n[ X ] Pediatra";
    if (prop.getProperty("data32")!=null && prop.getProperty("data32").equals("4")) data += "\n[ X ] Enfemera obstetra";
    if (prop.getProperty("data33")!=null && prop.getProperty("data33").equals("5")) data += "\n[ X ] Médico obstetra";
    if (prop.getProperty("data34")!=null && prop.getProperty("data34").equals("0")) data += "\n[ X ] Otros:   "+prop.getProperty("observacion16");
        
    pc.addBorderCols(data,0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "";
    if (prop.getProperty("data35")!=null && prop.getProperty("data35").equals("1")) data += "[ X ] Cuarto de Labor";
    if (prop.getProperty("data36")!=null && prop.getProperty("data36").equals("2")) data += "\n[ X ] Sala de parto";
    if (prop.getProperty("data37")!=null && prop.getProperty("data37").equals("3")) data += "\n[ X ] Pabellón Quirúrgico";
    if (prop.getProperty("data39")!=null && prop.getProperty("data39").equals("5")) data += "\n[ X ] Ambiente No Quirúrgico";
    if (prop.getProperty("data38")!=null && prop.getProperty("data38").equals("4")) data += "\n[ X ] Fuera de la Institución";
    
    pc.addBorderCols(data,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "";
    if (prop.getProperty("data40")!=null && prop.getProperty("data40").equalsIgnoreCase("S")) data += "SIMPLE";
    else if (prop.getProperty("data40")!=null && prop.getProperty("data40").equals("N")) data += "MULTIPLE";
    
    if (prop.getProperty("data41") != null && !"".equals(prop.getProperty("data41"))) {
      data += "\n\nNo. de Orden: "+prop.getProperty("data41");
    }
    
    pc.addBorderCols(data,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "";
    if (prop.getProperty("data42")!=null && prop.getProperty("data42").equalsIgnoreCase("S")) data += "Anomalías:  SI\n";
    else if (prop.getProperty("data42")!=null && prop.getProperty("data42").equalsIgnoreCase("N")) data += "Anomalías:  NO\n";
    
    if (prop.getProperty("data43")!=null && prop.getProperty("data43").equalsIgnoreCase("S")) data += "Pinzamiento:  Menos 1 min\n";
    else if (prop.getProperty("data43")!=null && prop.getProperty("data43").equalsIgnoreCase("N")) data += "Pinzamiento:  [x]\n";
    
    if (prop.getProperty("data44")!=null && prop.getProperty("data44").equalsIgnoreCase("S")) data += "Pinzamiento:  Más 1 min\n";
    else if (prop.getProperty("data44")!=null && prop.getProperty("data44").equalsIgnoreCase("N")) data += "Pinzamiento:  [x]\n";
    
    if (prop.getProperty("data45")!=null && prop.getProperty("data45").equalsIgnoreCase("S")) data += "Circula: SI\n";
    else if (prop.getProperty("data45")!=null && prop.getProperty("data45").equalsIgnoreCase("N")) data += "Circula:  NO\n";
    
    if (prop.getProperty("data46")!=null && prop.getProperty("data46").equalsIgnoreCase("S")) data += "Prolapso: SI\n";
    else if (prop.getProperty("data46")!=null && prop.getProperty("data46").equalsIgnoreCase("N")) data += "Prolapso:  NO\n";
    
    if (prop.getProperty("data47")!=null && prop.getProperty("data47").equalsIgnoreCase("S")) data += "Nudos: SI\n";
    else if (prop.getProperty("data47")!=null && prop.getProperty("data47").equalsIgnoreCase("N")) data += "Nudos:  NO\n";
    
    pc.addBorderCols(data,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
   
    pc.useTable("tblDM");
    pc.addTableToCols("tblDP",0,tblDM.size());
    
    
    pc.useTable("main");
    pc.addTableToCols("tblDM",0,dHeader.size());
    
    Vector tbl15 = new Vector();
    tbl15.addElement("20");
    tbl15.addElement("20");
    tbl15.addElement("20");
    tbl15.addElement("20");
    tbl15.addElement("10");
    tbl15.addElement("10");
    
    pc.setNoColumnFixWidth(tbl15);
    pc.createTable("tbl15");
    
    pc.setFont(9,1);
    pc.addBorderCols("14. PUNTUACION DEL APGAR",0, 4, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("MINUTOS 1",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("MINUTOS 2",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,0);
    
    pc.addBorderCols("Frecuencia cardiaca",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("0 Ausente",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("1 Menor de 100",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("2 Menor de 100",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data48"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data49"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.addBorderCols("Esfuerzo Respiratorio",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);	
    pc.addBorderCols("0 Ausente	1",0, 1, 0.1f, 0.1f, 0.1f, 0.1f); 
    pc.addBorderCols("Irregular, llanto débil	2",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("Regular, llanto fuerte",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data50"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data51"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.addBorderCols("Tono Muscular",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("0 Flácido",0, 1, 0.1f, 0.1f, 0.1f, 0.1f)	;
    pc.addBorderCols("1 Ligera Flexión de Extremidades",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("2 Extremidades Flexionadas",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data52"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data53"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.addBorderCols("Reacción a Estímulo",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("0 No Respuesta",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("1 Gesticulaciones	2",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("Buena Respuesta",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data54"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data55"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.addBorderCols("Color",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("0 Azul o Pálido",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("1 Extremidades Cianóticas",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("2 Rosado",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data56"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data57"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.addBorderCols("si está deprimido al 5to minuto, anotar el tiempo en que se logra Apgar 7: "+prop.getProperty("data58"), 0, 4, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data59"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(prop.getProperty("data60"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addBorderCols("15. MANIOBRAS DE RUTINA",0, 6, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    
    if (prop.getProperty("data61")!= null && prop.getProperty("data61").equalsIgnoreCase("S")) pc.addBorderCols("CALOR:  SI",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data61")!= null && prop.getProperty("data61").equalsIgnoreCase("N")) pc.addBorderCols("CALOR:  NO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    if (prop.getProperty("data62")!= null && prop.getProperty("data62").equalsIgnoreCase("S")) pc.addBorderCols("SECADO:  SI",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data62")!= null && prop.getProperty("data62").equalsIgnoreCase("N")) pc.addBorderCols("SECADO:  NO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    if (prop.getProperty("data63")!= null && prop.getProperty("data63").equalsIgnoreCase("S")) pc.addBorderCols("ASPIRACION NASOFARÍNGEA:  SI",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data63")!= null && prop.getProperty("data63").equalsIgnoreCase("N")) pc.addBorderCols("ASPIRACION NASOFARÍNGEA:  NO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    if (prop.getProperty("data64")!= null && prop.getProperty("data64").equalsIgnoreCase("S")) pc.addBorderCols("ASPIRACION GASTRICA:  SI",0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    else if (prop.getProperty("data64")!= null && prop.getProperty("data64").equalsIgnoreCase("N")) pc.addBorderCols("ASPIRACION GASTRICA:  NO",0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    else pc.addBorderCols(" ",0, 3, 0.1f, 0.1f, 0.1f, 0.1f);
    
    
    pc.setFont(9,1);
    pc.addBorderCols("16. MANIOBRAS ESPECIALES DE REANIMACION",0, 6, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    
    data = "REANIMACION\n";
    if (prop.getProperty("data65")!=null && prop.getProperty("data65").equals("1")) data += "No se hizo";
    else if (prop.getProperty("data65")!=null && prop.getProperty("data65").equals("2")) data += "Máscara Presión Positiva";
    else if (prop.getProperty("data65")!=null && prop.getProperty("data65").equals("3")) data += "Máscara Simple";
    else if (prop.getProperty("data65")!=null && prop.getProperty("data65").equals("4")) data += "Intubación";
    pc.addBorderCols(data,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "CARDIACA\n";
    if (prop.getProperty("data66")!=null && prop.getProperty("data66").equals("1")) data += "No se hizo";
    else if (prop.getProperty("data66")!=null && prop.getProperty("data66").equals("2")) data += "Masaje externo";
    else if (prop.getProperty("data66")!=null && prop.getProperty("data66").equals("3")) data += "Drogas";
    pc.addBorderCols(data,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "METABOLICA\n";
    if (prop.getProperty("data67")!=null && prop.getProperty("data67").equals("1")) data += "No se hizo";
    else if (prop.getProperty("data67")!=null && prop.getProperty("data67").equals("2")) data += "Alcalinizantes";
    else if (prop.getProperty("data67")!=null && prop.getProperty("data67").equals("3")) data += "Otros";
    pc.addBorderCols(data,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "ESTIMACION EXTERNA\n";
    if (prop.getProperty("data68")!=null && prop.getProperty("data68").equalsIgnoreCase("S")) data += "SI";
    else if (prop.getProperty("data68")!=null && prop.getProperty("data68").equalsIgnoreCase("N")) data += "NO";
    pc.addBorderCols(data,0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "OTRAS\n";
    if (prop.getProperty("data69")!=null && prop.getProperty("data69").equalsIgnoreCase("S")) data += "SI";
    else if (prop.getProperty("data69")!=null && prop.getProperty("data69").equalsIgnoreCase("N")) data += "NO";
    pc.addBorderCols(data,0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    
    
    pc.setFont(9,1);
    pc.addBorderCols("17. PROFILAXIS OFTALMICA",0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("18. PLACENTA",0, 4, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    
    data = "";
    if (prop.getProperty("data70")!=null && prop.getProperty("data70").equalsIgnoreCase("S")) data += "SI";
    else if (prop.getProperty("data70")!=null && prop.getProperty("data70").equalsIgnoreCase("N")) data += "NO";
    pc.addBorderCols(data,0, 2, 0.1f, 0.1f, 0.1f, 0.1f);
    
    data = "";
    if (prop.getProperty("data71")!=null && prop.getProperty("data71").equalsIgnoreCase("N")) data += "NORMAL";
    else if (prop.getProperty("data71")!=null && prop.getProperty("data71").equalsIgnoreCase("A")) data += "ANORMAL:      "+prop.getProperty("observacion17");
    pc.addBorderCols(data,0, 4, 0.1f, 0.1f, 0.1f, 0.1f);
    
    
    pc.useTable("main");
    pc.addTableToCols("tbl15",0,dHeader.size());    
    
    Vector tbl19 = new Vector();
    tbl19.addElement("17");
    tbl19.addElement("17");
    tbl19.addElement("17");
    tbl19.addElement("17");
    tbl19.addElement("17");
    tbl19.addElement("17");

    pc.setNoColumnFixWidth(tbl19);
    pc.createTable("tbl19");
    
    pc.setFont(11,1, Color.white);
    pc.setVAlignment(1);
    pc.addCols("EXAMEN FISICO INMEDIATO",1, tbl19.size(), Color.gray);
    pc.setVAlignment(0);
    
    sql = "select fecha_nacimiento, codigo_paciente, secuencia, rn_apgar7, rn_calor as calor, rn_secado as secado, rn_asp_nasofar as aspNaso, rn_asp_gast as aspGast, rn_man_esp_rean as reAnimacion, rn_rean_card as cardiaca, rn_metabol as metabolica, rn_estim_ext as estimulacion, rn_estim_ext_otras as otras, rn_talla as talla, rn_peso as peso, rn_edad_gest_ex_fis as edad, decode(rn_dif_resp,'S','SI','N','NO') as difResp, decode(rn_cp_ictericia,'S','SI','N','NO') as piel,  decode(rn_cp_palidez,'S','SI','N','NO') palidez, decode(rn_cp_cianosis,'S','SI','N','NO') as cianosis, decode(rn_malforma,'S','SI','N','NO') as malForm, decode(rn_neuro,'N','NORMAL','D','DEPRIMIDO', 'E', 'EXCITADO') as neuro, decode(rn_abdomen,'N','NORMAL','A','ANORMAL') as abdomen, decode(rn_orino,'S','SI','N','NO') as orino, decode(rn_exp_meco,'S','SI','N','NO') as meconio, decode(rn_cardio,'S','NORMAL','N','ANORMAL') as cardio, pac_id, nvl(to_char(dn_fecha_nacimiento,'dd/mm/yyyy'),' ') as dnFechaNac, nvl(to_char(dn_hora_nacimiento,'hh12:mi:ss am'),' ') as dnHoraNac, nvl(dn_sexo,' ') as dnSexo, decode(perm_ano,'S','SI','N','NO') perm_ano, decode(perm_coanas,'S','SI','N','NO') perm_coanas, decode(perm_esofago,'S','SI','N','NO') perm_esofago, decode(lesiones,'S','SI','N','NO') lesiones, lesiones_obs, tiempo_de_vida, pc, decode(eval_riesgo,'S','SIN RIESGO','C','CON RIESGO') eval_riesgo, decode(lugar_permanencia_neo, '1', 'Junto a la Madre', '2', 'Sala Neonatología', '3', 'Unidad de Observación', '4', 'Unidad de Cuidado Intensivos', '5', 'Aislamiento', '6', 'Transferido') lugar_permanencia_neo from tbl_sal_serv_neonatologia where pac_id="+pacId+" and secuencia="+noAdmision;
    cdo = SQLMgr.getData(sql);
    if (cdo == null) cdo = new CommonDataObject();
    
    String lugarPermanenciaNeo = cdo.getColValue("lugar_permanencia_neo");
    String permCoanas = cdo.getColValue("perm_coanas");
    String permEsofago = cdo.getColValue("perm_esofago");
    String permAno = cdo.getColValue("perm_ano");
    String evalRiesgo = cdo.getColValue("eval_riesgo");
    
    pc.setFont(9,1);
    
    // b t l r
    
    pc.addBorderCols("19. TIEMPO DE VIDA",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("20. PESO (GM)",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("TALLA (CM)",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("PC (CM)",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("21. EDAD GEST. POR EXAMEN FÍSICO",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("22. DIFICULTAD RESPIRATORIA",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("tiempo_de_vida"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("peso"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("talla"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("pc"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols("Semanas: "+cdo.getColValue("edad", " "),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("difResp"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addBorderCols("23. COLOR DE LA PIEL ICTERICIA",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("PALIDEZ",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("CIANOSIS",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("24. MALFORMACIONES",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("25. NEUROLOGICO",1,2, 0.0f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("piel"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("palidez"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("cianosis"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("malForm"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("neuro"),1,2, 0.1f, 0.0f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addBorderCols("26. LESIONES",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("Especificar",0,5, 0.0f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("lesiones"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("lesiones_obs"),0,5, 0.1f, 0.0f, 0.1f, 0.1f);
    
    
    pc.setFont(9,1);
    pc.addBorderCols("27. ABDOMEN",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("28. ORINO",1,1, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("29. EXPULSO MECONIO",1,2, 0.0f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("30. CARDIOVASCULAR",1,2, 0.0f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,0);
    pc.addBorderCols(cdo.getColValue("abdomen"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("orino"),1,1, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("meconio"),1,2, 0.1f, 0.0f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("cardio"),1,2, 0.1f, 0.0f, 0.1f, 0.1f);
    
    
    pc.setFont(11,1, Color.white);
    pc.setVAlignment(1);
    pc.addCols("DIAGNOSTICOS",1, tbl19.size(), Color.gray);
    pc.setVAlignment(0);
    
    ArrayList al = SQLMgr.getDataList("select 'INGRESO' tipo, a.diagnostico, coalesce(b.observacion,b.nombre) as diagnosticoDesc, a.orden_diag from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision = "+noAdmision+" and a.pac_id = "+pacId+" and tipo = 'I' union all select 'SALIDA' tipo, a.diagnostico, coalesce(b.observacion,b.nombre) as diagnosticoDesc, a.orden_diag from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision = "+noAdmision+" and a.pac_id = "+pacId+" and tipo = 'S' order by 1, 3");
    
    //b t l r
    pc.setFont(9,1);
    pc.addBorderCols("CODIGO",0,1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols("DESCRIPCION",0,5, 0.1f, 0.1f, 0.1f, 0.1f);
    
    String group = ""; 
    
    for(int i = 0; i < al.size(); i++) {
      cdo = (CommonDataObject) al.get(i);
      
      if (!group.equalsIgnoreCase(cdo.getColValue("tipo"))) {
        pc.setFont(9,1);
        pc.addBorderCols(cdo.getColValue("tipo"),0,6, 0.1f, 0.0f, 0.1f, 0.1f);
      }
      
      pc.setFont(9,0);
      pc.addBorderCols(cdo.getColValue("diagnostico"),0,1, 0.1f, 0.0f, 0.1f, 0.1f);
      pc.addBorderCols(cdo.getColValue("diagnosticoDesc"),0,5, 0.1f, 0.0f, 0.1f, 0.1f);
      
      group = cdo.getColValue("tipo");
    }
    
    pc.setFont(9,1);
    pc.addCols("",1, tbl19.size());
    pc.addBorderCols("Lugar de Permanencia",0,2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    pc.addBorderCols(lugarPermanenciaNeo,0,4, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addCols("",1, tbl19.size());
    pc.addBorderCols("Permeabilidad de las coanas",0,2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    pc.addBorderCols(permCoanas,0,4, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addCols("",1, tbl19.size());
    pc.addBorderCols("Permeabilidad del esófago",0,2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    pc.addBorderCols(permEsofago,0,4, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addCols("",1, tbl19.size());
    pc.addBorderCols("Permeabilidad del ano",0,2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    pc.addBorderCols(permAno,0,4, 0.1f, 0.1f, 0.1f, 0.1f);
    
    pc.setFont(9,1);
    pc.addCols("",1, tbl19.size());
    pc.addBorderCols("Evaluación de riesgo",0,2, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.setFont(9,0);
    pc.addBorderCols(evalRiesgo,0,4, 0.1f, 0.1f, 0.1f, 0.1f);
        
    pc.setFont(11,1, Color.white);
    pc.setVAlignment(1);
    pc.addCols("",1, tbl19.size());
    pc.addCols("OBSERVACION",0, tbl19.size(), Color.gray);
    pc.setVAlignment(0);
    
    pc.setFont(9,0);
    pc.addCols(prop.getProperty("observacionx"),0,tbl19.size());
    pc.addCols("",0,tbl19.size());

    pc.addCols(" ",0,tbl19.size());
    pc.addCols(" ",0,tbl19.size());
    pc.addCols(" ",0,tbl19.size());
    
    pc.addBorderCols(UserDet.getRefCode() + " - " + UserDet.getName(), 0, 3, 0.0f, 0.1f, 0.0f, 0.0f);
    pc.addCols("",0,3);
    
    
    
    
    
    pc.useTable("main");
    pc.addTableToCols("tbl19",0,dHeader.size()); 
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
%>