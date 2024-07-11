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
<jsp:useBean id="NEEMgr" scope="page" class="issi.expediente.NotaEgresoEnfermeriaMgr" />
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
NEEMgr.setConnection(ConMgr);

Properties prop = new Properties();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

cdoUsr.addColValue("usuario",userName);

if(desc == null) desc = "";

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'");

 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

	float width = 82 * 8.5f;//612
	float height = 62 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 35.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

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
    cdoPacData.addColValue("is_landscape",""+isLandscape);}


PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


		Vector dHeader = new Vector();
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);


		if(prop ==  null){
			pc.addCols("No se ha encontrado registros!",1,dHeader.size());
		}else{

			pc.setFont(10,1,Color.white);
			pc.addBorderCols("PARTO",0,dHeader.size(), Color.gray);

			pc.setFont(7,0);
			pc.addCols("Fecha: ",2,1);
			pc.addCols(prop.getProperty("fecha"),0,1);
			pc.addCols("Hora: ",2,1);
			pc.addCols(prop.getProperty("hora"),0,1);
			pc.addCols("",0,1);

			String pvEMLD = "", pvEM = "";

			if (prop.getProperty("parto").equalsIgnoreCase("EL")){
				pvEMLD = "X"; pvEM = "";
			}
			if (prop.getProperty("parto").equalsIgnoreCase("EM")){
				pvEMLD = ""; pvEM = "X";
			}

			pc.addCols("Parto Vaginal: ",0,1);
			pc.addCols("EMLD: ",2,1);
			pc.addCols(pvEMLD,0,1);
			pc.addCols("EM: ",0,1);
			pc.addCols(pvEM,0,1);
			pc.addCols("",0,dHeader.size(),4.2f);

			pc.setFont(8,1, Color.white);
			pc.addBorderCols("DATOS RECIEN NACIDO",0,dHeader.size(), Color.gray);
			pc.addCols("",0,dHeader.size(),4.2f);

			pc.addBorderCols("Sexo",1,1, Color.gray);
			pc.addBorderCols("Apgar",1,1, Color.gray);
			pc.addBorderCols("Peso",1,1, Color.gray);
			pc.addBorderCols("Semanas",1,1, Color.gray);
			pc.addCols("",0,1);

			pc.setFont(7,0);

			pc.addBorderCols(prop.getProperty("sexo1"),1,1);
			pc.addBorderCols(prop.getProperty("apgar1"),1,1);
			pc.addBorderCols(prop.getProperty("peso1"),1,1);
			pc.addBorderCols(prop.getProperty("semanas1"),1,1);
			pc.addCols("",2,1);

			pc.addBorderCols(prop.getProperty("sexo2"),1,1);
			pc.addBorderCols(prop.getProperty("apgar2"),1,1);
			pc.addBorderCols(prop.getProperty("peso2"),1,1);
			pc.addBorderCols(prop.getProperty("semanas2"),1,1);
			pc.addCols("",2,1);

			pc.addBorderCols(prop.getProperty("sexo3"),1,1);
			pc.addBorderCols(prop.getProperty("apgar3"),1,1);
			pc.addBorderCols(prop.getProperty("peso3"),1,1);
			pc.addBorderCols(prop.getProperty("semanas3"),1,1);
			pc.addCols("",2,1);

			pc.addBorderCols(prop.getProperty("sexo4"),1,1);
			pc.addBorderCols(prop.getProperty("apgar4"),1,1);
			pc.addBorderCols(prop.getProperty("peso4"),1,1);
			pc.addBorderCols(prop.getProperty("semanas4"),1,1);
			pc.addCols("",2,1);

			pc.addCols("",1,dHeader.size(),5.2f);
			pc.addCols("MEDICO:  "+prop.getProperty("cod_medico")+"         "+prop.getProperty("nombre_medico"),0,dHeader.size(), Color.orange);
			pc.addCols("",0,dHeader.size(),4.2f);

			String liq= "";

			if(prop.getProperty("liquido").equalsIgnoreCase("CL")){liq="Claro";}
			if(prop.getProperty("liquido").equalsIgnoreCase("SA")){liq="Sanguinolento";}
			if(prop.getProperty("liquido").equalsIgnoreCase("FL")){liq="Meconial Fluido";}
			if(prop.getProperty("liquido").equalsIgnoreCase("ES")){liq="Meconial Espeso";}

			pc.addBorderCols("LIQUIDO AMNIOTICO: "+liq,0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),4.2f);

			pc.addBorderCols("MALFORMACIONES CONGENITAS:",0,1,0.5f,0.0f,0.0f,0.0f);

			if(prop.getProperty("malformacion").equalsIgnoreCase("N")){
				 pc.addBorderCols("NO",0,1,0.5f,0.0f,0.0f,0.0f);
				 pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}else{
				 pc.addBorderCols("SI",0,1,0.5f,0.0f,0.0f,0.0f);
				 pc.setFont(8,1);
				 pc.addBorderCols("Cuales",2,1,0.5f,0.0f,0.0f,0.0f);
				 pc.setFont(7,0);
				 pc.addBorderCols(prop.getProperty("obserMalformacion"),0,3,0.5f,0.0f,0.0f,0.0f);
			}
			pc.addCols("",0,dHeader.size(),4.2f);

			String si= "", no = "";
			pc.addBorderCols("APEGO MADRE E HIJOS:",0,1,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("apego").equalsIgnoreCase("S")){si = "SI";  no = "";}else{si=""; no ="NO";}
			pc.addBorderCols(si + " "+no,0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),4.2f);

			String placenta="";
			if(prop.getProperty("placenta").equalsIgnoreCase("RE")) placenta = "RETENCION";

			if(prop.getProperty("placenta").equalsIgnoreCase("NA")) {
				 placenta = "NACE";
			    if(prop.getProperty("placenta2").equalsIgnoreCase("DU")){
					placenta += " DUNCAN";
				}
				if(prop.getProperty("placenta2").equalsIgnoreCase("SC")){
					placenta += " SCHULTZ";
				}
			}
			pc.addBorderCols("PLACENTA:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(placenta,0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),4.2f);

			String sutura="";
			if(prop.getProperty("sutura").equalsIgnoreCase("N")) sutura = "NO";

			if(prop.getProperty("sutura").equalsIgnoreCase("S")) {
				 sutura = "SI:   ";
			    if(prop.getProperty("sutura2").equalsIgnoreCase("CR")){
					sutura += " Cromico 0-0: "+prop.getProperty("suturaDesc1");
				}
				if(prop.getProperty("placenta2").equalsIgnoreCase("CA")){
					sutura += " Caprosyn 0-0: "+prop.getProperty("suturaDesc2");
				}
			}

			pc.addBorderCols("SUTURA EPISOTAMIA:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(sutura,0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),4.2f);

			String utero = "";
			if(prop.getProperty("utero").equalsIgnoreCase("R")){ utero = "Relajado";}else{utero = "Contraido";}

			pc.addBorderCols("UTERO:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(utero,0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),4.2f);

			String loq = "", qty = "";

			if(prop.getProperty("loquias").equalsIgnoreCase("RU")) loq = "Rubras";
			if(prop.getProperty("loquias").equalsIgnoreCase("AL")) loq = "Albas";
			if(prop.getProperty("loquias").equalsIgnoreCase("SE")) loq = "Serosa";

			if(prop.getProperty("cantidad").equalsIgnoreCase("AB")) qty = "Abundante";
			if(prop.getProperty("cantidad").equalsIgnoreCase("MO")) qty = "Moderada";
			if(prop.getProperty("cantidad").equalsIgnoreCase("LE")) qty = "Leve";

			pc.addBorderCols("LOQUIAS:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(loq,0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("CANTIDAD:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(qty,0,2,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),4.2f);

			pc.addBorderCols("SE TRASLADA A PUERPERIO:",0,1,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("traslada").equalsIgnoreCase("ME")){
			    pc.addBorderCols("Mediato",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			}else{
				pc.addBorderCols("Inmediato",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			}
			pc.addCols("",0,dHeader.size(),4.2f);

			pc.addBorderCols("OBSERVACIONES:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("observacion"),0,4,0.5f,0.0f,0.0f,0.0f);

		}//end else


pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>