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

String sql = "";
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
if(fg == null ) fg = "NEEN";


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
	String title = "EXPEDIENTE";;
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
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("50");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if(prop == null){
			pc.addCols("No se ha encontrado registros!",1,dHeader.size());
		}else{

		pc.setFont(7,1);
		pc.addCols("Creado por: "+prop.getProperty("usuario_creacion")+"     "+prop.getProperty("fecha_creacion"),0,5);
		pc.addCols("Modificado por: "+prop.getProperty("usuario_modificacion")+"     "+prop.getProperty("fecha_modificacion"),0,1);

		pc.setFont(10,1, Color.white);
		pc.addCols("EGRESO",0,dHeader.size(),Color.gray);
		pc.addCols("",1,dHeader.size(),5f);

		pc.setFont(8,0);
		pc.addBorderCols("FECHA:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(prop.getProperty("fecha"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("HORA:",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols(prop.getProperty("hora"),0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("",1,dHeader.size(),5f);

		pc.addBorderCols("SALIDA:",0,1,0.5f,0.0f,0.0f,0.0f);
		if(prop.getProperty("salida").equalsIgnoreCase("AU")){
			pc.addBorderCols("Autorizada",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
		}else{
			pc.addBorderCols("Voluntaria",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("Autorizada",0,1,0.5f,0.0f,0.0f,0.0f);
		}
		pc.addCols("",1,dHeader.size(),5f);

		pc.addBorderCols("RELEVO DE RESPONSABILIDAD:",0,3,0.5f,0.0f,0.0f,0.0f);
		if(prop.getProperty("relevo").equalsIgnoreCase("S")){
			pc.addBorderCols("SI",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,2,0.5f,0.0f,0.0f,0.0f);
		}else{
			pc.addBorderCols("NO",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,2,0.5f,0.0f,0.0f,0.0f);
		}
		pc.addCols("",1,dHeader.size(),5f);

		pc.addBorderCols("SIGNOS VITALES:",0,2,0.5f,0.0f,0.0f,0.0f);
		pc.addBorderCols("P/A:          "+prop.getProperty("presion")+"          P:          "+prop.getProperty("pulso")+"          R:          "+prop.getProperty("respiracion")+"          T:          "+prop.getProperty("temperatura"),0,4,0.5f,0.0f,0.0f,0.0f);
		pc.addCols("",1,dHeader.size(),5f);

		String c1= "", c2 = "";

		pc.addBorderCols("ESTADO DE CONSCIENCIA:",0,3,0.5f,0.0f,0.0f,0.0f);
		c1 = prop.getProperty("consciente1");
		if(prop.getProperty("estado").equalsIgnoreCase("C")){
		    pc.addBorderCols("Consciente:",0,1,0.5f,0.0f,0.0f,0.0f);
		}else if(prop.getProperty("estado").equalsIgnoreCase("O")){
			pc.addBorderCols("Orientado:",0,1,0.5f,0.0f,0.0f,0.0f);
		}
		pc.addBorderCols(c1,0,2,0.5f,0.0f,0.0f,0.0f);

		pc.addCols("",1,dHeader.size(),5f);

		pc.setFont(10,1,Color.white);
		pc.addCols("INTERVENCION DE LA ENFERMERIA",0,dHeader.size(),Color.gray);
		pc.addBorderCols("",1,dHeader.size(),3f);
		pc.addBorderCols("CONDICION",0,4,Color.gray);
		pc.addBorderCols("EVALUADO",0,1,Color.gray);
		pc.addBorderCols("OBSERVACION",0,1,Color.gray);

		pc.setFont(8,0);

		//if(prop.getProperty("aplicar1").equalsIgnoreCase("S")){
		   pc.addBorderCols("EDUCACION AL PACIENTE Y AL FAMILIAR",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar1").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion1"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar2").equalsIgnoreCase("S")){
		   pc.addBorderCols("CUMPLIMENTO DE ORDENES MEDICAS",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar2").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion2"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar3").equalsIgnoreCase("S")){
		   pc.addBorderCols("RECETA DE MEDICAMENTOS",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar3").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion3"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar4").equalsIgnoreCase("S")){
		   pc.addBorderCols("ADMINISTRACION DE MEDICINAS",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar4").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion4"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar5").equalsIgnoreCase("S")){
		   pc.addBorderCols("ALIMENTACION POR S.N.E",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar5").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion5"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar6").equalsIgnoreCase("S")){
		   pc.addBorderCols("ALIMENTACION POR GASTROSTOMIA",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar6").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion6"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar7").equalsIgnoreCase("S")){
		   pc.addBorderCols("CAMBIO DE BOLSA DE COLOSTOMIA",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar7").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion7"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar8").equalsIgnoreCase("S")){
		   pc.addBorderCols("CAMBIO DE BOLSA DE ILEOSTOMIA",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar8").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion8"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar9").equalsIgnoreCase("S")){
		   pc.addBorderCols("USO DE SONDA DE FOLEY",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar9").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion9"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar10").equalsIgnoreCase("S")){
		   pc.addBorderCols("RETIRO DE CARACTER VENOSO CENTRAL",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar10").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion10"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar11").equalsIgnoreCase("S")){
		   pc.addBorderCols("RETIRO DE SELLO DE HEPARINA",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar11").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion11"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar12").equalsIgnoreCase("S")){
		   pc.addBorderCols("HACER DEVOLICIONES DE MAT. Y MED.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar12").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion12"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar13").equalsIgnoreCase("S")){
		   pc.addBorderCols("ORIENTACION A CITAS MEDICAS.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar13").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion13"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar14").equalsIgnoreCase("S")){
		   pc.addBorderCols("RETIRO DE MARQUILLA.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar14").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion14"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar15").equalsIgnoreCase("S")){
		   pc.addBorderCols("SALE EN SILLA DE RUEDAS.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar15").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion15"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar16").equalsIgnoreCase("S")){
		   pc.addBorderCols("SALE EN AMBULANCIA.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar16").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion16"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar17").equalsIgnoreCase("S")){
		   pc.addBorderCols("SALE SOLO.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar17").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion17"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar18").equalsIgnoreCase("S")){
		   pc.addBorderCols("ACOMPANADO POR FAMILIAR.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar18").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion18"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar19").equalsIgnoreCase("S")){
		   pc.addBorderCols("ACOMPANADO DE PERSONAL DE HOGAR.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar19").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion19"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar20").equalsIgnoreCase("S")){
		   pc.addBorderCols("ACOMPANADO POR MENSAJERO.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar20").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion20"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar21").equalsIgnoreCase("S")){
		   pc.addBorderCols("ENTREGA DE VALORES.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar21").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion21"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}

		//if(prop.getProperty("aplicar22").equalsIgnoreCase("S")){
		   pc.addBorderCols("OTROS DATOS.",0,4,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols((prop.getProperty("aplicar22").equalsIgnoreCase("S"))?"SI":"NO",1,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addBorderCols(prop.getProperty("observacion22"),0,1,0.5f,0.0f,0.0f,0.0f);
		   pc.addCols("",1,dHeader.size(),5f);
		//}



		}//end else

		pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>