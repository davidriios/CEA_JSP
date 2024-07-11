<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alapgar, alEscala = new ArrayList();
ArrayList alCordon = new ArrayList();
CommonDataObject cdo, cdoPacData, cdoGetTot = new CommonDataObject();

boolean viewMode = false;
String sql = "", sqlTitle="", sqlGetTot="", sqlEscala="";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
float eTotal1 = 0.0f, eTotal5 = 0.0f;
String userName = UserDet.getUserName();
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
//if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String cod_apgar= request.getParameter("cod_apgar");
String cDate="";
String cTime="";
String rouspan="";
int eTotal=0;
int aTotal=0;
boolean checkDefault = false;
if (tab == null) tab = "0";

String codigoHdr = request.getParameter("codigo_hdr_cordon");
if (codigoHdr == null) codigoHdr = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

sql = "select fecha_nacimiento, codigo_paciente, secuencia, rn_apgar7, rn_calor as calor, rn_secado as secado, rn_asp_nasofar as aspNaso, rn_asp_gast as aspGast, rn_man_esp_rean as reAnimacion, rn_rean_card as cardiaca, rn_metabol as metabolica, rn_estim_ext as estimulacion, rn_estim_ext_otras as otras, rn_talla as talla, rn_peso as peso, rn_edad_gest_ex_fis as edad, rn_dif_resp as difResp, rn_cp_ictericia as piel, rn_cp_palidez as palidez, rn_cp_cianosis as cianosis, rn_malforma as malForm, rn_neuro as neuro, rn_abdomen as abdomen, rn_orino as orino, rn_exp_meco as meconio, rn_cardio as cardio, pac_id, nvl(to_char(dn_fecha_nacimiento,'dd/mm/yyyy'),' ') as dnFechaNac, nvl(to_char(dn_hora_nacimiento,'hh12:mi:ss am'),' ') as dnHoraNac, nvl(dn_sexo,' ') as dnSexo, decode(perm_ano,'S','SI','N','NO') perm_ano, decode(perm_coanas,'S','SI','N','NO') perm_coanas, decode(perm_esofago,'S','SI','N','NO') perm_esofago, decode(lesiones,'S','SI','N','NO') lesiones, lesiones_obs, tiempo_de_vida, pc, decode(eval_riesgo,'S','SIN RIESGO','C','CON RIESGO') eval_riesgo, lugar_permanencia_neo from tbl_sal_serv_neonatologia where pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);
	
	if (cdo == null) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	float leftRightMargin = 18.0f;
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
	float cHeight = 11.0f;
    
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
  dHeader.addElement(".17");
  dHeader.addElement(".17");
  dHeader.addElement(".17");
  dHeader.addElement(".17");
  dHeader.addElement(".17");
  dHeader.addElement(".17");
			

	//table header
	pc.setNoColumnFixWidth(dHeader);
	
	pc.createTable();
		//first row
		// el Encabezado del PDF tiene estos 9 parametros definidos el inicio en JspUseBeans
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	pc.setTableHeader(1);
	
String calor = "", sexo="", secado="", aspNaso="", aspGastro="", reanim="", cardio="",metabol="", estimul="",otras="", difResp="",colPiel="", palidez="", cianosis="", malformaciones="", neurologico="",abdo="", orino="",xpulso="",cardiov=""  ;
				
     
    pc.addCols("",1,dHeader.size(),15.2f);
    pc.setFont(8,1,Color.white);
    pc.addBorderCols("EXAMEN FISICO INMEDIATO",0,dHeader.size(), Color.gray);
    
    pc.setFont(8,1);
	
    pc.addBorderCols("Tiempo de Vida",1,1);
    pc.addBorderCols("Peso (GM)",1,1);
    pc.addBorderCols("Talla (CM)",1,1);
    pc.addBorderCols("PC (CM)",1,1);
    pc.addBorderCols("Edad Gest. por Examen Físico",1,1);
    pc.addBorderCols("Dificultad Respiratoria",1,1);
    
    pc.setFont(8,0);
    pc.addCols(cdo.getColValue("tiempo_de_vida"),1,1);
    pc.addCols(cdo.getColValue("peso"),1,1);
    pc.addCols(cdo.getColValue("talla"),1,1);
    pc.addCols(cdo.getColValue("pc"),1,1);
    pc.addCols("Semanas: "+cdo.getColValue("edad"),1,1);
    pc.addCols(cdo.getColValue("difResp"),1,1);
	
	
	if(cdo.getColValue("piel")!=null && cdo.getColValue("piel").equals("S")){
		colPiel="Si"; 
	}else{
		colPiel="No"; 
	}
	
	if(cdo.getColValue("palidez")!=null && cdo.getColValue("palidez").equals("S")){
	   palidez="Si"; 
	}else{
		palidez="No";
	}
	
	if(cdo.getColValue("cianosis")!= null && cdo.getColValue("cianosis").equals("S")){
	   cianosis="Si";
	}else{
		cianosis="No";
	}
	
	if(cdo.getColValue("malform")!=null && cdo.getColValue("malform").equals("S")){
	   malformaciones="Si";
	}else{
	  malformaciones="No";
	}
	
	if(cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("N")){
	   neurologico="Normal";
	}
	if(cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("D")){
			neurologico="Deprimido";
	}
	else{
	   neurologico="Excitado";
	}
	
	pc.addCols("",1,dHeader.size(),15.2f);
	pc.addBorderCols("Color de la Piel Ictericia: "+colPiel+"                                   Palidez: "+palidez+ "                                   Cianosis: "+cianosis+ "                                   Malformaciones: "+malformaciones+"                                   Neurologico: "+neurologico,0,dHeader.size());


   pc.addCols("",1,dHeader.size(),15.2f);

   pc.addBorderCols("Abdomen",1,1);
   pc.addBorderCols("Orinó",1,1);
   pc.addBorderCols("Expulso Meconio",1,1);
   pc.addBorderCols("Cardiovascular",1,1);

   if(cdo.getColValue("abdomen")!=null && cdo.getColValue("abdomen").equals("N")){
	   abdo="Normal";
   }else{
	   abdo="Anormal";
   }

   if(cdo.getColValue("mecomio")!=null && cdo.getColValue("mecomio").equals("S")){
	  xpulso= "Si"; 
   }else{
	  xpulso= "No"; 
   }
   
    if(cdo.getColValue("orino")!=null && cdo.getColValue("orino").equals("S")){
	  orino= "Si"; 
   }else{
	  orino= "No"; 
   }
   
   if(cdo.getColValue("cardio")!=null && cdo.getColValue("cardio").equals("S")){
	 cardiov= "Normal";  
   }else{
	 cardiov= "Anormal"; 
   }		
					
 pc.addCols(abdo,1,1);
 pc.addCols(orino,1,1);
 pc.addCols(xpulso,1,1);
 pc.addCols(cardiov,1,1);
 
 pc.addCols("Lesiones:   "+cdo.getColValue("lesiones"," "),0,1);
 pc.addCols(cdo.getColValue("lesiones_obs"," "),0,3);
 
 
 
pc.addCols(" ",1,dHeader.size());
pc.setFont(9,1);
pc.addCols("EXAMEN FISICO AL NACER",0,dHeader.size(),Color.lightGray);
    
pc.setFont(9,0);
pc.addCols("Permeabilidad de las coanas:   "+cdo.getColValue("perm_coanas"," "),0,dHeader.size());
pc.addCols("Permeabilidad del esofago:   "+cdo.getColValue("perm_esofago"," "),0,dHeader.size());
pc.addCols("Permeabilidad del ano:   "+cdo.getColValue("perm_ano"," "),0,dHeader.size());
pc.addCols("Evaluación de riesgo:   "+cdo.getColValue("eval_riesgo"," "),0,dHeader.size());
pc.addCols("Lugar de Permanencia del Neonato:   "+cdo.getColValue("lugar_permanencia_neo"," "),0,dHeader.size());
 
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
	