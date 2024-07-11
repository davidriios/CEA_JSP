<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Properties"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>
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

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData = new CommonDataObject();

String sql = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = (request.getParameter("desc")==null?"":request.getParameter("desc"));
String fg = request.getParameter("fg");
String id = request.getParameter("id");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

Properties prop = new Properties();

if (fg==null) fg = "PUSP";
if (id==null)id="0";
if ((pacId==null || pacId.equals("")) || (noAdmision==null || noAdmision.equals(""))) throw new Exception("No podemos identificar el paciente, por favor contacte un administrador!");

prop = SQLMgr.getDataProperties("SELECT evaluacion FROM tbl_sal_nutricion_parenteral WHERE pac_id = "+pacId+" AND admision = "+noAdmision+" AND tipo = '"+fg+"' and id = "+id);
if (prop == null)
{
	prop = new Properties();
}
al = SQLMgr.getDataPropertiesList("SELECT evaluacion FROM tbl_sal_nutricion_parenteral WHERE pac_id="+pacId+" AND admision ="+noAdmision+" AND tipo = '"+fg+"' and id = "+id);

Hashtable iTitle = new Hashtable();
iTitle.put("1","Estudios por Imagenes");
iTitle.put("2","Examenes de Laboratorio");
iTitle.put("3","Historia Clínica");
iTitle.put("4","Antibiótico Profilaxis");
iTitle.put("5","Alergias");
iTitle.put("6","Consentimiento Quirúrgico firmado por el médico y paciente");
iTitle.put("7","Consentimiento de Anestesia firmado por el médico y paciente");
iTitle.put("8","Consentimiento de Hemoderivados firmado");
iTitle.put("9","Presentación del Personal Quirúrgico");
iTitle.put("10","Marcación del Sitio Quirúrgico por el Médico con sus iniciales");
iTitle.put("11","Confirmación de Equipos especiales y/o Implantes por la Enfermera de Quiráfano");

Hashtable iFooter = new Hashtable();
iFooter.put("1","Cirujano y Asistentes");
iFooter.put("2","Anestesiologo y asistente");
iFooter.put("3","Instrumentista/circulador,otros");

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

float width = 82 * 8.5f;//612
float height = 62 * 14f;//792
boolean isLandscape = false;
float leftRightMargin = 30.0f;
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
int fontSize = 12;
float cHeight = 90.0f;

CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

Vector tblMain = new Vector();
tblMain.addElement("0.05");
tblMain.addElement("0.40");
tblMain.addElement("0.05");
tblMain.addElement("0.05");
tblMain.addElement("0.05");
tblMain.addElement("0.40");

Vector tblFooter = new Vector();
tblFooter.addElement("0.05");
tblFooter.addElement("0.60");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");
tblFooter.addElement("0.05");

Vector tblDet = new Vector();
tblDet.addElement("0.05");
tblDet.addElement("0.05");
tblDet.addElement("0.05");
tblDet.addElement("0.05");
tblDet.addElement("0.05");
tblDet.addElement("0.05");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();

pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

pc.setFont(8, 1);

pc.addCols("Fecha: "+prop.getProperty("fecha"),0 ,2);
pc.addCols("Usuario: "+prop.getProperty("usuario"),0 ,4);

pc.addCols("**  NN = No es Necesario",0 ,tblMain.size(),15.2f);
pc.addCols("",0 ,tblMain.size());

pc.addBorderCols("No.",0 ,1,15.2f);
pc.addBorderCols("Descripcion",0 ,1,15.2f);
pc.addBorderCols("SI",1 ,1,15.2f);
pc.addBorderCols("NO",1 ,1,15.5f);
pc.addBorderCols("NN",1 ,1,15.5f);
pc.addBorderCols("Observacion",0 ,1,15.2f);

if(!id.trim().equals("0")){
String si1,si2,si3,si4,si5,si6,si7,si8,si9;
	String no1,no2,no3,no4,no5,no6,no7,no8,no9;
	if (prop.getProperty("check1").equals("S")){ si1="X";no1="";}else{si1="";no1="X";}
	if (prop.getProperty("check2").equals("S")){ si2="X";no2="";}else{si2="";no2="X";}
	if (prop.getProperty("check3").equals("S")){ si3="X";no3="";}else{si3="";no3="X";}
	if (prop.getProperty("check4").equals("S")){ si4="X";no4="";}else{si4="";no4="X";}
	if (prop.getProperty("check5").equals("S")){ si5="X";no5="";}else{si5="";no5="X";}
	if (prop.getProperty("check6").equals("S")){ si6="X";no6="";}else{si6="";no6="X";}
	if (prop.getProperty("check7").equals("S")){ si7="X";no7="";}else{si7="";no7="X";}
	if (prop.getProperty("check8").equals("S")){ si8="X";no8="";}else{si8="";no8="X";}
	if (prop.getProperty("check9").equals("S")){ si9="X";no9="";}else{si9="";no9="X";}

for (int i = 1; i<=iTitle.size(); i++){
	pc.addCols(""+i,0 ,1,15.2f);
	pc.addCols(""+iTitle.get(""+i),0 ,1,15.2f);
	pc.addCols((prop.getProperty("aplicar"+i).equals("S")?"X":""),1 ,1,15.2f);
	pc.addCols((prop.getProperty("aplicar"+i).equals("N")?"X":""),1 ,1,15.5f);
	pc.addCols((prop.getProperty("aplicar"+i).equals("NN")?"X":""),1 ,1,15.5f);
	pc.addCols(prop.getProperty("observacion"+i),0 ,1,15.2f);
}


pc.setNoColumnFixWidth(tblDet);
	pc.createTable("tblDet1",false,0,0.0f,175);
	pc.addBorderCols(si1,1 ,1,15.2f);
		pc.addBorderCols(no1,1 ,1,15.2f);
		pc.addBorderCols(si2,1 ,1,15.2f);
		pc.addBorderCols(no2,1 ,1,15.2f);
		pc.addBorderCols(si3,1 ,1,15.2f);
		pc.addBorderCols(no3,1 ,1,15.2f);

	pc.setNoColumnFixWidth(tblDet);
	pc.createTable("tblDet2",false,0,0.0f,175);
		pc.addBorderCols(si4,1 ,1,15.2f);
		pc.addBorderCols(no4,1 ,1,15.2f);
		pc.addBorderCols(si5,1 ,1,15.2f);
		pc.addBorderCols(no5,1 ,1,15.2f);
		pc.addBorderCols(si6,1 ,1,15.2f);
		pc.addBorderCols(no6,1 ,1,15.2f);

	pc.setNoColumnFixWidth(tblDet);
	pc.createTable("tblDet3",false,0,0.0f,175);
		pc.addBorderCols(si7,1 ,1,15.2f);
		pc.addBorderCols(no7,1 ,1,15.2f);
		pc.addBorderCols(si8,1 ,1,15.2f);
		pc.addBorderCols(no8,1 ,1,15.2f);
		pc.addBorderCols(si9,1 ,1,15.2f);
		pc.addBorderCols(no9,1 ,1,15.2f);


pc.setNoColumnFixWidth(tblFooter);
pc.createTable("footer",false,0,0.0f,552);

	pc.setFont(8,1,Color.white);
	pc.addCols("TABLA 2",0,tblFooter.size(),Color.blue);
	pc.setFont(8,1,Color.red);
	pc.addCols("PAUSA DE SEGURIDAD(TIME OUT)",0,tblFooter.size(),Color.blue);

	pc.setFont(8,1,Color.black);
	pc.addBorderCols("No.",0 ,1,15.2f);
	pc.addBorderCols("Descripcion",0 ,1);
	pc.addBorderCols("Paciente Correcto",1 ,2);
	pc.addBorderCols("Procedimiento",1 ,2);
	pc.addBorderCols("Sitio Correcto ",1 ,2);

	pc.addBorderCols("",0 ,2,15.2f);
	pc.addBorderCols("SI",1 ,1,15.2f);
	pc.addBorderCols("NO",1 ,1,15.2f);
	pc.addBorderCols("SI",1 ,1,15.2f);
	pc.addBorderCols("NO",1 ,1,15.2f);
	pc.addBorderCols("SI",1 ,1,15.2f);
	pc.addBorderCols("NO",1 ,1,15.2f);


	for (int f = 1; f<=iFooter.size();f++){
	    pc.addBorderCols(""+f,0 ,1,15.2f);
		pc.addBorderCols(""+iFooter.get(""+f),0 ,1,15.2f);
		pc.useTable("footer");
		pc.addTableToCols("tblDet"+f,0,6,0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
	}


pc.useTable("main");
pc.addTableToCols("footer",0,tblMain.size(),0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
}
if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",0,tblMain.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>