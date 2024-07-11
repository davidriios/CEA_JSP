<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); 

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String compania = (String) session.getAttribute("_companyId");
String lng = request.getParameter("lng");
String consentTitle = request.getParameter("consentTitle");
String consentName = request.getParameter("consentName");
String nombreCompania = _comp.getNombre();
String sql = "";
if (consentTitle == null) consentTitle = "";
if (consentName == null) consentName = "";
if (consentTitle.trim().equals("")) consentTitle = consentName;
if (lng == null) lng = "";

CommonDataObject cdo = new CommonDataObject();

cdo = SQLMgr.getData("SELECT  COALESCE( DECODE(P.pasaporte,NULL,'',P.pasaporte||'-'||P.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||'-'||P.D_CEDULA)) cedula, P.nombre_paciente AS nombrePaciente, c.habitacion, to_char(p.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento FROM vw_ADM_PACIENTE P, TBL_ADM_CAMA_ADMISION c WHERE P.PAC_ID = "+pacId+" AND C.ADMISION(+) = "+noAdmision+"  AND C.PAC_ID(+) = P.PAC_ID and c.fecha_final is null");

if ( cdo == null ) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";

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
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612 
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 30.0f; //9.0f
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONSENTIMIENTO";
	String subTitle = "DEBERES Y DERECHOS";
	String xtraSubtitle = "";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 90.0f;
		                            
   // PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector tblImg = new Vector();
	tblImg.addElement(".20");
	tblImg.addElement(".50");
	tblImg.addElement(".30");
	
	Vector dHeader = new Vector();
	dHeader.addElement(".05");
	dHeader.addElement(".65");
	dHeader.addElement(".30"); 
	
	Vector dCenterFooter = new Vector();
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("tblImg",false,0,0.0f,553f);
     pc.setVAlignment(1);
	   pc.addBorderCols("DO NOT USE ABBREVIATIONS\n(Law Nº 68 of November 20, 2003)",1,1);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
	   pc.setVAlignment(1);
     pc.addBorderCols("Pegar Label Aquí",1,1);
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
	
	pc.addCols(" ",1,dHeader.size());
    
    int fontsize = 11;
	
	// titulo
    pc.setFont(fontsize,1);
	pc.addCols(consentTitle,1,dHeader.size());

	pc.addCols(" ",1,dHeader.size());
    
    pc.setFont(fontsize,1);

	pc.addCols(lng.equalsIgnoreCase("es")?"Nombre Completo: "+cdo.getColValue("nombrePaciente"," "):"Complete Name: "+cdo.getColValue("nombrePaciente"," "),4,dHeader.size());
	pc.addCols(lng.equalsIgnoreCase("es")?"Fecha Nacimiento: "+cdo.getColValue("fecha_nacimiento"," "):"Date of Birth: "+cdo.getColValue("fecha_nacimiento"," "),4,dHeader.size());
    
    pc.addCols(" ", 0,dHeader.size());
    
	pc.addCols(lng.equalsIgnoreCase("en")?"I hereby authorize: ----------------------------------------------------------------------------------------------------------Anesthesia Physician(s)":"Autorizoa:----------------------------------------------------------------------------------------------------------Médico(s)Especialista(s)enAnestesia",4,dHeader.size());
    pc.addCols(lng.equalsIgnoreCase("en")?"For (ANESTHESIA TECHNIQUE): ------------------------------------------------------------------------------------------------------":"Para:       (TÉCNICA        DE      ANESTESIA)--------------------------------------------------------------------------------------",4,dHeader.size());
    
    pc.setVAlignment(0);
        
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("1.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"The physician has explained to me the risks of this procedure, advised me regarding other alternative treatments and has informed me of the possible outcomes and consequences if my condition is not treated. I also understand the anesthesia service is necessary, so the physician can perform the surgery or procedure.":"El médico me ha explicado los riesgos de este procedimiento, me ha aconsejado en cuanto a otros tratamientos alternos y me ha informado acerca de los posibles resultados y de las consecuencias si mi condición no es tratada. También entiendo que el servicio de anestesia es necesario para que el médico pueda realizar dicha operación o procedimiento.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("2.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I have been explained that each type of anesthesia involves some risks and there are no guarantees regarding the outcome of my treatment or procedure. Although rare, there may be serious and unexpected complications; these include the remote possibility of infection, bleeding, side effects, cloths, loss of sensation, loss of limb function, paralysis,stroke, brain damage, heart attack or death.\n\nI understand those risks apply to any form of anesthesia and that any other additional or specific risk related with the proposed anesthesia has been explained to me.\n\n----------------------------------------------------------------------------------------------------------------------------------------------\n\n----------------------------------------------------------------------------------------------------------------------------------------------\nIn addition, I understand that many factors determine the type of anesthesia to be used, including my physical condition, type of procedure performed by the surgeon, his/her preference, as well as mine.\n\nI have been explained that sometimes, a specific type of anesthesia that involves the use of local anesthetics, with or without sedatives, may not have a good result; therefore, another type of anesthesia may be administered, including general anesthesia.":"Se me ha explicado que todo tipo de anestesia conlleva algunos riesgos y no hay garantías en cuanto al resultado de mi tratamiento o procedimient o. Aunque raras, pueden haber graves e inesperadas complicaciones y éstas incluyen la remota posibilidad de : infección, sangramiento, reacciones secundarias, coágulos, pérdida de sensibilidad, pérdida funcional de un miembro, parálisis, embolia, daño cerebral, ataque cardiaco o muerte.\n\nEntiendo que dichos riesgos corresponden a toda forma de anestesia y que cualquier otro riesgo adicional o específico relacionado con la anestesia propuesta me los han explicado. Además, entiendo que hay muchos factores que determinar el tipo de anestesia a ser usada, incluyendo mi condición física el tipo procedimiento que el cirujano realice, su preferencia, así como también la mía.\n\nMe han explicado que cierto tipo de anestesia que involucra el uso de anestésicos locales, con o sin sedativos, puede que no tenga bueno resultados y por lo tanto otro tipo de anestésico deberá ser administrado incluyendo la anestesia general.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("3.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"Regardless of the type of anesthesia administered, I understand there are a number of common and predictable risks and consequences. I have been informed that some, but not all common and predictable risks and consequences are: sore throat and hoarseness, nausea and vomiting, pains.\n\n----------------------------------------------------------------------------------------------------------------------------------------------":"Entiendo que a pesar del tipo  de anestesia  que se ad ministre, hay un número de riesgos comunes predecibles  y consecuen  cias. Me han informado que algunos, pero no todos los riesgos comunes predecibles  y sus consecuencias  son: dolor  de garganta  y voz, náuseas y vómitos, dolores",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("4.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"Also, I understand the use of medical instruments in the mouth to keep the airways open during the administration of the anesthesia may unavoidably cause damage to the teeth, including fracture or loss of teeth, dental bridges, dentures, crowns and fillings, laceration of the lips and gums.":"Además , comprendo que el uso de instrumentos médicos en la boca para mantener abiertas las vías respiratorias durante la administración de la anestesia, puede que inevitablemente cause daño a los dientes, incluyendo fractura o pérdida de los dientes, puentes, prótesis dentales, coronas y amalgamas, laceración de los labios y de las encías.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("5.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I understand the medications I currently take may cause complications with the anesthesia or surgery. I understand that for my own benefit, I need to inform my physicians of any medication I take now, including but not limited to aspirin, cold medications, phencyclidine, marihuana, cocaine, vitamins, minerals and herbal supplements.":"Entiendo que los medicamentos que estoy tomando actualmente pueden ocasionar complicaciones con la anestesia o cirugía. Comprendo que es para mí beneficio, informar a mis médicos de cualquier medicamento que yo esté tomando actualmente, incluyendo, pero no limitándose a la aspirina, medicamentos para resfriado, Fenciclidina, marihuana, cocaína, vitaminas, minerales y suplementos herbáceos.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("6.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I have heard the explanation of the physician regarding the type(s) of anesthesia that can be administered, its benefits and common and predictable risks, as well as the alternatives. Now I accept his/her recommendation, with the exception of:" : "He escuchado la explicación del doctor acerca del (de los) tipo (s) de anestesia que se me pueden administrar sus beneficios y riesgos y riesgos comunes predecibles y consecuencias, así como también las alternativas y ahora acepto su recomendación con la excepción de:\n\n----------------------------------------------------------------------------------------(documente alergias o niega alergias)",4,dHeader.size() - 1);
	
	if (lng.equalsIgnoreCase("en")) {
	  pc.addCols(" ",4, 1);
    pc.addCols("\n\n----------------------------------------------------------------------------------------------------------------------------------------------\n(document any allergies or if you deny any)", 1,dHeader.size()-1);
	}
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("7.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I understand that during the course of the procedure, surgery or treatment, the use of invasive devices for observation may be necessary. The risks/benefits related with this type of monitoring have been explained in detail and understood by me.":"Entiendo que durante el transcurso de mi operación, procedimiento, o tratamiento puede ser necesario el uso de equipos de observación invasivos. Los riesgos/beneficios asociados con este tipo de monitoreo me los han explicado en detalle y los entiendo.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("8.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I understand certain conditions may arise during the administration of the anesthesia that require the change or extension of this consent. Therefore, I authorize the changes or extensions to this consent the anesthesiologist considers necessary according to the circumstances.":"Entiendo que ciertas condiciones pueden surgir durante la administración de la anestesia, que requieran la modificación o extensión de este consentimiento por lo tant o, autorizo las modificaciones o extensiones a este consentimiento que el profesional estimen necesarios según las circunstan cias.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("9.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("en")?"I hereby give my consent and authorize blood transfusion / administration or its components/products and medications during the surgery and hospitalization, when considered appropriate by my attending physicians. I understand there are no guarantees regarding blood transfusions, its components – products or medications.":"Por medio dela presente doy mi consentimiento y autorizo la transfusión o administración de sangre o sus componentes/productos y medicamentos durante esta cirugía y hospitalización, cuando los médicos que me atienden lo estimen necesario. Entiendo que no hay garantías en cuanto a dicha transfusión de sangre, sus componentes -productos o medicamentos.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("10.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I understand I must not eat or drink anything, not even water, after twelve (12) midnight of the day before surgery, unless allowed by the physician.":"Comprendo que no debo comer ni beber absolutamente nada, ni siquiera agua, después de las doce (12) de la media noche del día anterior a la cirugía a menos que me lo permita el médico.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("11.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("en")?"I understand and agree that the anesthesiologist and the assistant doctors are not employees of "+nombreCompania+".":"Admito y convengo que el anestesiólogo y los médicos adjuntos no son empleados del "+nombreCompania+" y que el Hospital no controla las formas o métodos en que estas intervenciones son realizadas",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("12.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I have had the opportunity to make all the questions related with the anesthesia and these have been completely answered to my satisfaction.":"He tenido la oportunidad de hacer todas las preguntas pertinentes a la anestesia y éstas han sido contestadas completamente y sati sfact oriamente .",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("13.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("en")?"I understand the content of this document; I agree with the provisions and give my consent for the administration of anesthesia during the procedure, surgery or treatment I’m about to undergo. I also acknowledge the practice of anesthesia, medicine and surgery is not an exact science and no one has made any guarantees regarding the administration of the anesthesia or its results.":"Entiendo el contenido de este documento, estoy de acuerdo con sus disposiciones y doy mi consentimiento para la administración de anestesia durante el procedimiento, operación o tratamiento al que me voy a someter. También reconozco que la práctica de anestesia, medicina y cirugía no es una ciencia exacta y que ninguna persona me ha hecho promesas o garantías en cuanto a la administración de anestesia o sus resultados.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("14.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("en")?"I have been completely informed and give my consent for the use of conscious sedation. The way in which it is used may cause loss of protective reflexes.":"He sido informado completamente y consiento el uso de la sedación consciente. La forma en que esta es usada puede ocasionar la pérdida de reflejos protectores.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("15.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("en")?"I have read the previous paragraphs and these have been explained to my full satisfaction.":"He leído los párrafos anteriores y éstos han sido explicados satisfactoriamente.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    
	pc.setNoColumnFixWidth(dCenterFooter);
	pc.createTable("dCenterFooter",false,0,0.0f,553f);
	   
	   pc.addBorderCols(lng.equalsIgnoreCase("es")?"Firma del Paciente":"Patient's signature",0,3,0.0f,0.1f,0.0f,0.0f);
	   pc.addCols("",0,3);
	   pc.addBorderCols(lng.equalsIgnoreCase("es")?"Firma de su representante o guardián legal":"Signature of Patient's Representative or Legal Guardian",0,4,0.0f,0.1f,0.0f,0.0f);
	   
	   pc.addCols(" ",1,dCenterFooter.size());
	   pc.addCols(" ",1,dCenterFooter.size());
       
       pc.addBorderCols(lng.equalsIgnoreCase("es")?"Testigo (solo de la firma)":"Witness (only of signature)",0,3,0.0f,0.1f,0.0f,0.0f);
	   pc.addCols("",0,7);
       
       pc.addCols(" ",1,dCenterFooter.size());
	   pc.addCols(" ",1,dCenterFooter.size());
       
       pc.addBorderCols(lng.equalsIgnoreCase("es")?"Firma del médico":"Physician's signature",0,3,0.0f,0.1f,0.0f,0.0f);
	   pc.addCols("",0,3);
	   pc.addCols(lng.equalsIgnoreCase("es")?"Fecha/Hora: ":" Date/Time: ",0,4);
	   
	   
	
	pc.useTable("main");
	pc.addTableToCols("dCenterFooter",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
    
    
    
    
pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
%>