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
<jsp:useBean id="NIEMgr" scope="page" class="issi.expediente.NotaIngresoEnfermeriaMgr" />
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

Properties prop = new Properties();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NIEMgr.setConnection(ConMgr);

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

	prop = SQLMgr.getDataProperties("select nota from tbl_sal_nota_ingreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = '"+fg+"'");

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
		dHeader.addElement("13");
		dHeader.addElement("13");
		dHeader.addElement("13");
		dHeader.addElement("13");
		dHeader.addElement("13");
		dHeader.addElement("35");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if(prop == null){
			pc.addCols("No se ha encontrado registros!",1, dHeader.size());
		}else{

			pc.setFont(10,1,Color.white);
		    pc.addCols("INGRESO",0,dHeader.size(), Color.gray);

			pc.setFont(8,0);
			pc.addBorderCols("FECHA:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("fecha"),0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("HORA:",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("hora"),0,1,0.5f,0.0f,0.0f,0.0f);
		    pc.addCols("",0,1);
			pc.addCols("",0,dHeader.size(),5f);


			if(!fg.trim().equals("NINO")){

			pc.addBorderCols("ADMITIDO POR:",0,2,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("admitido").equalsIgnoreCase("A")){
				pc.addBorderCols("Admision",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else
			if(prop.getProperty("admitido").equalsIgnoreCase("U")){
			    pc.addBorderCols("Urgencia",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else
			if(prop.getProperty("admitido").equalsIgnoreCase("S")){
			    pc.addBorderCols("SOP",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else
			if(prop.getProperty("admitido").equalsIgnoreCase("O")){
			    pc.addBorderCols("Otro",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else{pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);}


			if(prop.getProperty("llegada").equalsIgnoreCase("C")){
				pc.addBorderCols("LLEGA EN:",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Camilla",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("llegada").equalsIgnoreCase("CA")){
				pc.addBorderCols("LLEGA EN:",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Caminando",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("llegada").equalsIgnoreCase("S")){
				pc.addBorderCols("LLEGA EN:",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Silla Ruedas",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("llegada").equalsIgnoreCase("EB")){
				pc.addBorderCols("LLEGA EN:",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("En Brazo",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}

			pc.addBorderCols("ACOMPANADO POR:",0,2,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("acompaniante").equalsIgnoreCase("F")){
				pc.addBorderCols("Familiar",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else
			if(prop.getProperty("acompaniante").equalsIgnoreCase("C")){
				pc.addBorderCols("Camillero",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else
			if(prop.getProperty("acompaniante").equalsIgnoreCase("E")){
				pc.addBorderCols("Personal Enf.",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else
			if(prop.getProperty("acompaniante").equalsIgnoreCase("M")){
				pc.addBorderCols("Meedico",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else
			if(prop.getProperty("acompaniante").equalsIgnoreCase("S")){
				pc.addBorderCols("Solo",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}else{pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f); pc.addCols("",0,dHeader.size(),5f);}

			if(prop.getProperty("religion").equalsIgnoreCase("CA")){
				pc.addBorderCols("RELIGION:",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("Caatolica:",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("religion").equalsIgnoreCase("EV")){
				pc.addBorderCols("RELIGION:",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("Evangeelica:",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("religion").equalsIgnoreCase("CR")){
				pc.addBorderCols("RELIGION:",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("Cristina:",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("religion").equalsIgnoreCase("OT")){
				pc.addBorderCols("RELIGION:",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("Otras:",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}

			}//end if fg is not NINO

			if(fg.trim().equals("NINO")){

			pc.addBorderCols("DIAGNOSTICO:",0,1,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("diagnostico").equalsIgnoreCase("RNT_AEG")){
				pc.addBorderCols("RNT-AEG",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}
			if(prop.getProperty("diagnostico").equalsIgnoreCase("RNT_PEG")){
				pc.addBorderCols("RNT-PEG",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}
		    if(prop.getProperty("diagnostico").equalsIgnoreCase("RNT_GEG")){
				pc.addBorderCols("RNT-GEG",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}
		    if(prop.getProperty("diagnostico").equalsIgnoreCase("RNprT_AEG")){
				pc.addBorderCols("RNprT-AEG",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}
			 if(prop.getProperty("diagnostico").equalsIgnoreCase("OT")){
				pc.addBorderCols("OTROS",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}
		    pc.addCols("",0,dHeader.size(),5f);

			pc.addBorderCols("LLEGA EN:",0,1,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("llegada").equalsIgnoreCase("IN")){
				pc.addBorderCols("Incubadora",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}else{
				pc.addBorderCols("Otro",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Incubadora",0,4,0.5f,0.0f,0.0f,0.0f);
			}
			pc.addCols("",0,dHeader.size(),5f);

			pc.addBorderCols("ACOMPANADO POR:",0,2,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("acompañante").equalsIgnoreCase("EO")){
				pc.addBorderCols("Enf. Obste.",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			}else{
				pc.addBorderCols("Pediatra",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
			}
			pc.addCols("",0,dHeader.size(),5f);

			}//end if fg = NINO

			pc.addCols("SIGNOS VITALES: ",0,2);
			pc.addCols("PRESION ARTERIAL: "+prop.getProperty("presion")+"                            PULSO: "+prop.getProperty("pulso")+"                            RESPIRACION: "+prop.getProperty("respiracion")+"                       TEMPERATURA: "+prop.getProperty("temperatura"),0,4);

			pc.addCols("",0,2);

			String dolor = "";

			if(prop.getProperty("dolor").equalsIgnoreCase("S")){dolor = "SI";}else{dolor = "NO";}

			pc.addBorderCols("PESO: "+prop.getProperty("peso")+"                                                       TALLA: "+prop.getProperty("talla")+"                               DOLOR: "+dolor,0,4,0.5f,0.0f,0.0f,0.0f);

			pc.addCols("",0,dHeader.size(),5f);



			if(!fg.trim().equals("NINO")){
			pc.addBorderCols("MEDICO",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("cod_medico"),0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("nombre_medico"),0,4,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

			pc.addBorderCols("DIAGNOSTICO",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("codDiag"),0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("descDiag"),0,4,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

			pc.addBorderCols("OBSERVACION (DX DE ENFERMERIA):",0,2,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("obserEnf"),0,4,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);
			} //end if not NINO medico

			if(fg.trim().equals("NIEN")){
				pc.setFont(10,1, Color.white);

				pc.addCols("EVALUACION: CONDICION ESPECIAL",0,dHeader.size(),Color.gray);

				pc.setFont(8,0);

				//if(prop.getProperty("aplicar1").equalsIgnoreCase("S")){
					pc.addBorderCols("PROTESIS DENTAL ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion1"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else
				//if(prop.getProperty("aplicar2").equalsIgnoreCase("S")){
					pc.addBorderCols("PROTESIS CORPORAL ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion2"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else
				//if(prop.getProperty("aplicar3").equalsIgnoreCase("S")){
					pc.addBorderCols("INVIDENTE ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion3"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else
				//if(prop.getProperty("aplicar4").equalsIgnoreCase("S")){
					pc.addBorderCols("HIPOACUSIA ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion4"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else
				//if(prop.getProperty("aplicar5").equalsIgnoreCase("S")){
					pc.addBorderCols("MUDO ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion5"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else
				//if(prop.getProperty("aplicar6").equalsIgnoreCase("S")){
					pc.addBorderCols("MULETA ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion6"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else
				//if(prop.getProperty("aplicar7").equalsIgnoreCase("S")){
					pc.addBorderCols("BASTON ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion7"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else
				//if(prop.getProperty("aplicar8").equalsIgnoreCase("S")){
					pc.addBorderCols("VALORES PERSONALES ",0,3,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("observacion8"),0,3,0.5f,0.0f,0.0f,0.0f);
				//}else{
				//}
				pc.addCols(" ",0,dHeader.size(),15f);


			}//end if fg = NIEN

			if(fg.trim().equals("NIPA")){

				pc.setFont(10,1,Color.white);
				pc.addCols("HISTORIA OBSTETRICA",0,dHeader.size(), Color.gray);

				pc.setFont(8,0);
				pc.addBorderCols("GESTA",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("gesta"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("PARA",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("para"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);

				pc.addBorderCols("ABORTO",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("aborto"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("CESAREA",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("cesarea"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);

				pc.addBorderCols("F.U.M",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("fum"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("F.P.P",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("fpp"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);

				pc.setFont(10,1,Color.white);
				pc.addCols("MANIOBRA DE LEOPOLD",0,dHeader.size(), Color.gray);

				pc.setFont(8,0);
				pc.addBorderCols("PRESENTACION:",0,1,0.5f,0.0f,0.0f,0.0f);
				if(prop.getProperty("presentacion").equalsIgnoreCase("CE")){
				    pc.addBorderCols("CEFALICO",0,1,0.5f,0.0f,0.0f,0.0f);
				}else
				if(prop.getProperty("presentacion").equalsIgnoreCase("SA")){
				    pc.addBorderCols("SACRO",0,1,0.5f,0.0f,0.0f,0.0f);
				}else
				if(prop.getProperty("presentacion").equalsIgnoreCase("PO")){
				    pc.addBorderCols("PODALICO",0,1,0.5f,0.0f,0.0f,0.0f);
				}else{pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);}

				pc.addBorderCols("SITUACION:",0,1,0.5f,0.0f,0.0f,0.0f);
				if(prop.getProperty("situacion").equalsIgnoreCase("TR")){
				    pc.addBorderCols("TRANSVERSO",0,1,0.5f,0.0f,0.0f,0.0f);
				}else
				if(prop.getProperty("situacion").equalsIgnoreCase("LO")){
				    pc.addBorderCols("LONGITUDINAL",0,1,0.5f,0.0f,0.0f,0.0f);
				}else{pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);}

			    pc.addBorderCols("DORSO:",0,1,0.5f,0.0f,0.0f,0.0f);
				if(prop.getProperty("dorso").equalsIgnoreCase("DE")){
				    pc.addBorderCols("DERECHO",0,1,0.5f,0.0f,0.0f,0.0f);
				}else
				if(prop.getProperty("dorso").equalsIgnoreCase("IZ")){
				    pc.addBorderCols("IZQUIERDO",0,1,0.5f,0.0f,0.0f,0.0f);
				}else{pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);}

				pc.addCols("",0,dHeader.size(),5f);

				pc.addBorderCols("ACTIVIDAD UTERINA:",0,2,0.5f,0.0f,0.0f,0.0f);
				if(prop.getProperty("actividad").equalsIgnoreCase("RE")){
					pc.addBorderCols("REGULAR",0,1,0.5f,0.0f,0.0f,0.0f);
				}
				if(prop.getProperty("actividad").equalsIgnoreCase("IR")){
				   pc.addBorderCols("IRREGULAR",0,1,0.5f,0.0f,0.0f,0.0f);
				}
				pc.addBorderCols("CANT-FREC-DURAC:",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);

				pc.addBorderCols("MEMBRANAS:",0,1,0.5f,0.0f,0.0f,0.0f);
				if(prop.getProperty("membranas").equalsIgnoreCase("I")){
					pc.addBorderCols("INTEGRAS",0,5,0.5f,0.0f,0.0f,0.0f);
				}else
				if(prop.getProperty("membranas").equalsIgnoreCase("R")){
					pc.addBorderCols("ROTAS",0,5,0.5f,0.0f,0.0f,0.0f);
				}else{
					pc.addBorderCols("",0,5,0.5f,0.0f,0.0f,0.0f);
				}
				pc.addCols("",0,dHeader.size(),5f);

				pc.addBorderCols("LIQUIDO AMNIOTICO :",0,2,0.5f,0.0f,0.0f,0.0f);
				if(prop.getProperty("liquido").equalsIgnoreCase("CL")){
				   pc.addBorderCols("CLARO",0,4,0.5f,0.0f,0.0f,0.0f);
				}else if(prop.getProperty("liquido").equalsIgnoreCase("FL")){
					pc.addBorderCols("MECONIAL FLUIDO",0,4,0.5f,0.0f,0.0f,0.0f);
				}else if(prop.getProperty("liquido").equalsIgnoreCase("ES")){
					pc.addBorderCols("MECONIAL ESPESO",0,4,0.5f,0.0f,0.0f,0.0f);
				}else if(prop.getProperty("liquido").equalsIgnoreCase("SA")){
					pc.addBorderCols("SANGUINOLENTO",0,4,0.5f,0.0f,0.0f,0.0f);
				}else{
					pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
				}
				pc.addCols("",0,dHeader.size(),5f);

				pc.addBorderCols("F.C.F",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("fcf"),0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);

				pc.setFont(10,1,Color.white);
				pc.addCols("TACTO VAGINAL",0,dHeader.size(),Color.gray);

				pc.setFont(8,0);

				pc.addBorderCols("DILATACION(cms)",1,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("ALTURA(plano)",1,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("PRESENTACION",1,2,0.5f,0.0f,0.0f,0.0f);

				for(int tv = 1; tv <=4; tv ++){
					pc.addBorderCols(prop.getProperty("dilatacion"+tv),1,2,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("altura"+tv),1,2,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols(prop.getProperty("presentacion"+tv),1,2,0.5f,0.0f,0.0f,0.0f);
				}
				pc.addCols("",0,dHeader.size(),5f);

				pc.addBorderCols("EDEMA:",0,1,0.5f,0.0f,0.0f,0.0f);

				if(prop.getProperty("edema").equalsIgnoreCase("N")){
					pc.addBorderCols("NO",0,1,0.5f,0.0f,0.0f,0.0f);
					pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
				}else if(prop.getProperty("edema").equalsIgnoreCase("S")){
					       pc.addBorderCols("SI:",0,1,0.5f,0.0f,0.0f,0.0f);

						   if(prop.getProperty("edema2").equalsIgnoreCase("LE")){
							   pc.addBorderCols("LEVE",0,4,0.5f,0.0f,0.0f,0.0f);
						   }else if(prop.getProperty("edema2").equalsIgnoreCase("MO")){
							          pc.addBorderCols("MODERADO",0,4,0.5f,0.0f,0.0f,0.0f);
						   }else if(prop.getProperty("edema2").equalsIgnoreCase("SE")){
							   pc.addBorderCols("SEVERO",0,4,0.5f,0.0f,0.0f,0.0f);
						   }else{
							   pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
						   }
				}else{
					pc.addBorderCols("",0,5,0.5f,0.0f,0.0f,0.0f);
				}
				pc.addCols("",0,dHeader.size(),5f);

			}//end if fg = NIPA

			pc.addBorderCols("HISTORIA ACTUAL: ",0,2,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("histActual"),0,4,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

			if(fg.trim().equals("NIPE")){
				pc.addBorderCols("PLAN DE CUIDADO INICIAL: ",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("plan_incial"),0,4,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}

			if(fg.trim().equals("NINO")){
			pc.setFont(10,1,Color.white);
			pc.addCols("CONDICION GENERAL: ",0,dHeader.size(),Color.gray);

			pc.setFont(8,0);
			pc.addBorderCols("APAGAR min 1: ",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("apgar1"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("APAGAR min 5: ",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("apgar5"),1,1,0.5f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

			pc.addBorderCols("LLANTO: ",0,1,0.5f,0.0f,0.0f,0.0f);
			if(prop.getProperty("llanto").equalsIgnoreCase("F")){
				pc.addBorderCols("Fuerte",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(" ",0,4,0.5f,0.0f,0.0f,0.0f);
			}else{
				pc.addBorderCols("Débil",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(": ",0,4,0.5f,0.0f,0.0f,0.0f);
			}
			pc.addCols("",0,dHeader.size(),5f);

			pc.addBorderCols("PIEL: ",0,1,0.5f,0.0f,0.0f,0.0f);

			if(prop.getProperty("piel").equalsIgnoreCase("A")){
				pc.addBorderCols("Acrocianosis",0,2,0.5f,0.0f,0.0f,0.0f);
			}

			if(prop.getProperty("piel2").equalsIgnoreCase("MS")){
				   pc.addBorderCols("Miembros S.",0,2,0.5f,0.0f,0.0f,0.0f);
			}

			if(prop.getProperty("piel2").equalsIgnoreCase("MI")){
				   pc.addBorderCols("Miembros I.",0,2,0.5f,0.0f,0.0f,0.0f);
			}

			if(prop.getProperty("piel2").equalsIgnoreCase("AM")){
				   pc.addBorderCols("Ambos.",0,2,0.5f,0.0f,0.0f,0.0f);
			}
			pc.addBorderCols("",0,2,0.5f,0.0f,0.0f,0.0f);
			pc.addCols("",0,dHeader.size(),5f);

			if(prop.getProperty("malformacion").equalsIgnoreCase("N")){
				pc.addBorderCols("MALFORMACIONES CONGENITAS",0,3,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("NO",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("malformacion").equalsIgnoreCase("S")){
				pc.addBorderCols("MALFORMACIONES CONGENITAS",0,3,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("SI",0,1,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("CUALES?",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(prop.getProperty("obserMalformacion"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}

			if(prop.getProperty("profilaxis").equalsIgnoreCase("N")){
				pc.addBorderCols("PROFILAXIS",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("NO",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
			}

			if(prop.getProperty("profilaxis").equalsIgnoreCase("S")){
				pc.addBorderCols("PROFILAXIS",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("SI",0,1,0.5f,0.0f,0.0f,0.0f);

				if(prop.getProperty("profilaxis2").equalsIgnoreCase("EU")){
					pc.addBorderCols("Eritromicina Unguento Oft",0,4,0.5f,0.0f,0.0f,0.0f);
					pc.addCols("",0,dHeader.size(),5f);
				}else
				if(prop.getProperty("profilaxis2").equalsIgnoreCase("OT")){
					   pc.addBorderCols("Otros",0,4,0.5f,0.0f,0.0f,0.0f);
					   pc.addCols("",0,dHeader.size(),5f);
				}
				else{
				 	pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
					pc.addCols("",0,dHeader.size(),5f);
				}

			}

			if(prop.getProperty("queda_en").equalsIgnoreCase("IC")){
				pc.addBorderCols("QUEDA EN",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Incub. Cerrada",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("queda_en").equalsIgnoreCase("IA")){
				pc.addBorderCols("QUEDA EN",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Incub. Abierta",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("",0,4,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}

			if(prop.getProperty("o2").equalsIgnoreCase("2L")){
				pc.addBorderCols("RECIBIENDO O2: ",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("2 LTS",0,4,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("o2").equalsIgnoreCase("CL")){
				pc.addBorderCols("RECIBIENDO O2: ",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("4 LTS",0,4,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("o2").equalsIgnoreCase("SL")){
				pc.addBorderCols("RECIBIENDO O2: ",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("6 LTS",0,4,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}
			if(prop.getProperty("o2").equalsIgnoreCase("OL")){
				pc.addBorderCols("RECIBIENDO O2: ",0,2,0.5f,0.0f,0.0f,0.0f);
			    pc.addBorderCols("8 LTS",0,4,0.5f,0.0f,0.0f,0.0f);
				pc.addCols("",0,dHeader.size(),5f);
			}

			if(prop.getProperty("permeabilidad").equalsIgnoreCase("S")){
				pc.addBorderCols("PERMEABILIDAD ANAL: ",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("SI ",0,4,0.5f,0.0f,0.0f,0.0f);
                pc.addCols("",0,dHeader.size(),5f);
			}
		    if(prop.getProperty("permeabilidad").equalsIgnoreCase("N")){
				pc.addBorderCols("PERMEABILIDAD ANAL: ",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("NO ",0,4,0.5f,0.0f,0.0f,0.0f);
                pc.addCols("",0,dHeader.size(),5f);
			}

			if(prop.getProperty("permeabilidadCo").equalsIgnoreCase("S")){
				pc.addBorderCols("PERMEABILIDAD COANAS: ",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("SI ",0,4,0.5f,0.0f,0.0f,0.0f);
                pc.addCols("",0,dHeader.size(),5f);
			}
		    if(prop.getProperty("permeabilidadCo").equalsIgnoreCase("N")){
				pc.addBorderCols("PERMEABILIDAD COANAS: ",0,2,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("NO ",0,4,0.5f,0.0f,0.0f,0.0f);
                pc.addCols("",0,dHeader.size(),5f);
			}

			}//end NINO


		} //end else

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>