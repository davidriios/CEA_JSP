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
	   pc.addCols(" ",0,1);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
	   pc.setVAlignment(1);
       pc.addBorderCols("Pegar Label Aquí",1,1);
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
	
	pc.addCols(" ",1,dHeader.size());
    
    int fontsize = 11;
	
	pc.setFont(fontsize,1);
	pc.addCols(consentTitle,1,dHeader.size());

	pc.addCols(" ",1,dHeader.size());
    
    pc.setFont(fontsize,1);

	pc.addCols(lng.equalsIgnoreCase("es")?"Nombre Completo: "+cdo.getColValue("nombrePaciente"," "):"Complete Name: "+cdo.getColValue("nombrePaciente"," "),4,dHeader.size());
	pc.addCols(lng.equalsIgnoreCase("es")?"Fecha Nacimiento: "+cdo.getColValue("fecha_nacimiento"," "):"Date of Birth: "+cdo.getColValue("fecha_nacimiento"," "),4,dHeader.size());
    
	pc.addCols(" ",1,dHeader.size());
	
	pc.setFont(fontsize,1);
	pc.addCols(lng.equalsIgnoreCase("es")?"Mi (s) médico (s) me han informado que él (los) procedimiento (s) que planifica (n) hacerme es (son) el (los) siguientes, cirugía o tratamiento propuesto a realizar":"My physician(s) has (have) informed me the procedure(s) he/she plans on doing is (are) the following; surgery or treatment to be performed:",4,dHeader.size());
	
    pc.addBorderCols(" ",0,dHeader.size(),1f,0.0f,0.0f,0.0f);
    pc.addBorderCols(" ",0,dHeader.size(),1f,0.0f,0.0f,0.0f);
    pc.addBorderCols(" ",0,dHeader.size(),1f,0.0f,0.0f,0.0f);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?""+nombreCompania+" y todas sus afiliadas considera que usted tiene derecho a ser informado (a) y tomar decisiones con respecto a los tratamientos y procedimientos médicos y/o quirúrgicos que se le efectúen. Usted debe ser parte de la decisión de este proceso. Su (s) médicos debe (n) proveerle la información sobre el tratamiento médico quirúrgico propuesto basado en su condición.":""+nombreCompania+" and all its affiliates consider you have the right to be informed and make decisions regarding the treatments and medical and/or surgical procedures to be performed. You must be involved in the decision about this process. Your physician(s) must provide you with the information about the medical/surgical treatment proposed based on your condition.",4,dHeader.size());
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?"La información siguiente contiene un texto estándar de consentimiento informado para procedimientos médicos y quirúrgicos, utilizado tanto para procedimientos menores como en los más complicados y serios. No ha sido elaborado por asustarlo o alarmarlo, es un esfuerzo para que usted sea RAZONABLEMENTE INFORMADO (A) y explicarle que TODOS los procedimientos  conllevan riesgos. Por ejemplo, en muchas operaciones solo presentan la posibilidad remota de necesitar transfusiones sanguíneas, sin embargo las mismas son  mencionadas en este texto.":"The following information contains a standard text of informed consent for medical and surgical procedures, used for minor procedures, as well as for the more complicated and serious ones. lt hasn't been created to alarm or scare you; it's an effort to keep you FAIRLY INFORMED and explain that ALL procedures involve risks.",4,dHeader.size());
	
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"Si usted no comprende algo PREGUNTE a su(s) médico (s).":"lf  you're not  clear about something, please  ASK your physician(s).",4,dHeader.size()); 
    
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols("", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"Si usted tiene dudas o preguntas no contestadas NO FIRME ESTE DOCUMENTO.":"lf you have unanswered questions or doubts, DON'T SIGN THIS DOCUMENT.",4,dHeader.size());
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"CONSENTIMIENTO INFORMADO":"INFORMED CONSENT",4,dHeader.size()); 
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("1.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?"Reconozco durante el curso de mi operación, cuidados post operatorio, tratamiento médico, anestesia, analgesia u otro procedimiento, existen condiciones imprevistas así como riesgos y complicaciones asociadas que pueden necesitar procedimiento diferentes o adicionales a los que hayan sido descritos en el presente documento. Por esta razón autorizo a mi(s) medico(s) y a sus asistentes, a realizar dicho procedimiento quirúrgico y cualquier otro procedimiento que sea necesario en el buen ejercicio y juicio profesional de los mismos. La autorización que doy se extiende al tratamiento de todas las condiciones que requieran tratamiento inmediato y/o complicaciones asociadas y que surjan como inconvenientes potenciales y/o riesgos durante o después del procedimiento o cirugía.\n\nHe sido informado (a) que existen riesgos significativos tales como reacciones alérgicas, coágulos en las venas y pulmones, pérdida de sangre, infecciones, paro cardiaco, que pueden llevarme a la muerte, incapacidad parcial o permanente y que suscitarse deben ser atendidos.":"I acknowledge that during the course of my surgical procedure, post-op care, medical treatment, anesthesia, pain management or other procedure, there are unexpected conditions, as well as related risks and complications that may require different or additional procedures than the ones mentioned in the current document . For this reason, I authorize my physician(s) and his/her assistants to perform that surgical procedure or any other procedure necessary as part of their good practice and professional judgment. The authorization I'm giving extends to the treatment of all conditions  that may require  immediate  treatment  and/or  related  complications  that may arise as potential inconveniences and/or risks during or after the procedure or surgery.\n\nI have been informed there are important risks such as allergic reactions, clots in the veins and lungs, blood loss, infections, cardiac arrest, that can lead to death, partial or permanent disability that must be taken care of.",4,dHeader.size() - 1);
        
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("2.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?"Reconozco que en los casos en donde son necesarias incisiones y/o suturas pueden ocurrir infecciones, dolor en la herida, formación de hernias (debilidad o abombamiento) y que esta complicaciones pueden requerir tratamientos o procedimiento futuros ":"I acknowledge that in the cases where incisions  and/or  sutures  are required, infections,  pain in  the  wound, hernia formation (weakness or bulging) may occur and that these complications can require treatments or future procedures.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("3.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"Reconozco en la lista de riesgos y complicaciones de este documento pueden no estar incluidos todos los riesgos posibles o conocidos de la cirugía o procedimiento que se me planifica realizar, pero que la misma expone las complicaciones más comunes o severas. Reconozco que en futuro pueden emerger complicaciones no mencionadas en este documento.":"I acknowledge the list of risks and complications mentioned in this document may not include all the possible and known risks of the surgery or procedure to be performed, but it states the most common and severe complications.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("4.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"Reconozco que mi (s)  médico (s) me ha (n) me ha señalado los beneficios razonables esperados, pero no me ha (n) dado garantía ni seguridad del resultado que pueda obtenerse la cirugía o procedimiento ni en la cura de mi condición.":"I  acknowledge  my physician(s)  has (have)  mentioned  the  reasonable  and expected  benefits, but hasn't given me any guarantee or safety in the result that may be achieved from the surgery, procedure or cure for my condition.",4,dHeader.size() - 1);
     
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("5.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?"Doy el consentimiento para el uso de transfusiones sanguíneas y productos sanguíneos que sean necesarios a criterio de mi(s) médico(s). Reconozco  los riesgos inherentes a las transfusiones de sangre y tengo el conocimiento que el "+nombreCompania+", practica todas las pruebas de laboratorio necesarias y disponibles actualmente para evitar enfermedades transmisibles como lo son la hepatitis y el VIH pero igualmente se me ha informado de la existencia de un riesgo de contraer estas enfermedades debido a la posibilidad de que las mismas se encuentren en periodo de incubación o ventana al momento de hacer las pruebas al donante y por lo tanto no puedan detectarse en ninguna prueba de laboratorio.":"I give my consent for the use of blood transfusions and blood products that may be necessary under my physician(s) criteria. I'm aware of the risks included related with blood transfusions and have the knowledge that "+nombreCompania+" practices all the laboratory tests necessary and currently available to avoid any transmissible disease such as Hepatitis and HIV, but I have been informed as well of the risk of contracting these diseases due to the possibility of them being in the incubation period or window at the moment the tests are performed in the donar, therefore not being detectable by any lab test.",4,dHeader.size() - 1);
     
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("6.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?"Autorizo mi (s) médico (s) para que según los procedimientos usuales dispongan de los tejidos o parte de los mismos que sean removidos quirúrgicamente por ejemplo para estudios histopatología.":"I authorize my physician(s) to dispose the tissues or part of them that may be surgicaliy removed for histopathological studies, for example, according to  the usual procedures  .",4,dHeader.size() - 1);
     
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("7.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"ENTIENDO QUE CUALQUIER ASPECTO DE ESTE DOCUMENTO QUE YO NO ENTIENDA ME DEBE SER EXPLICADO CON MAYORES DETALLES POR MI(S) MÉDICO(S) O A SUS ASOCIADOS.":"I UNDERSTAND ANY ASPECT OF THIS DOCUMENT I MAY NOT UNDERSTAND MUST BE EXPLAINED TO ME WITH FURTHER DETAILS BY MY PHYSICIAN(S) OR ASSOCIATES.",4,dHeader.size() - 1); 
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("8.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"Certifico que mi(s) médico(s) me ha(n) oportunidad de hacer preguntas y me ha (n) informado del carácter y naturaleza de los procedimientos médicos quirúrgicos propuestos, de los beneficios que obtendría de los mismos, incluyendo las consecuencias de la ausencia de tratamiento. Me han informado de las posibles complicaciones, riesgos conocidos y de las formas alternas de tratamientos.":"I certify my physician(s) has (have) given me the opportunity to make questions and has (have) informed me of the character and nature of the medical/surgical procedures proposed, benefits obtained from them, including the consequences of not receiving a treatment. I have been informed of the possible complications, known risks and alternative treatments.",4,dHeader.size() - 1); 
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("9.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?"Las siguientes son las excepciones referentes al tratamiento (s), y /o examen (s) y/o intervención (s) quirúrgica (s) y/o procedimiento (s) y/o suministros de medicamento (s) y/o transfusiones, y/o suministro de anestesia que lleguen a considerarse en algún momento (Describa las alergias o niega alergias del paciente):\n\n":"The following are exceptions regarding the treatment(s) and/or test(s) and/or surgical intervention(s) and/or procedure(s) and/or medication supplies and/or transfusions and/or anesthesia that may be considered at one point (Describe or deny patient's allergies):\n\n",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("10.",4, 1);
    
    pc.setFont(fontsize, 0);
	pc.addCols(lng.equalsIgnoreCase("es")?"Estoy consciente que el médico (s) tratante (s) no (son) empleado (s) del "+nombreCompania+" y por consiguiente exoneramos al "+nombreCompania+" de cualquier responsabilidad o negligencia de (los) medico (s) lo que incluye y no se limita no accionar contra el "+nombreCompania+" por tales circunstancias.":"I'm aware the treating physician(s) is (are) not an employee(s) at "+nombreCompania+"; therefore, I exonerate "+nombreCompania+" of any responsibility or negligence from the physician(s), which includes, but is not limited to not acting against "+nombreCompania+" due to those circumstances.",4,dHeader.size() - 1);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.setFont(fontsize, 1);
	pc.addCols("11.",4, 1);
    
    pc.setFont(fontsize, 1);
	pc.addCols(lng.equalsIgnoreCase("es")?"CERTIFICO QUE TENGO LA SUFICIENTE INFORMACION PARA DAR ESTE CONSENTIMIENTO Y QUE MI(S) MEDICO (S) ME HA(N) PREGUNTADO SI QUIERO UNA INFORMACION MAS DETALLADA, PERO ESTOY SATISFECHO (A) CON LAS EXPLICACIONES QUE ME HA(N) DADO Y NO NECESITO MAS INFORMACIÓN.":"I CERTIFY I HAVE ENOUGH INFORMATION TO GIVE MY CONSENT AND THAT MY PHYSICIAN(S) HAS (HAVE) ASKED ME IF I WISH FOR A MORE DETAILED INFORMATION, BUT I'M SATISFIED WITH THE EXPLANATIONS GIVEN TO ME AND DON'T REQUIRE  MORE INFORMATION.",4,dHeader.size() - 1);

    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    
	pc.setNoColumnFixWidth(dCenterFooter);
	pc.createTable("dCenterFooter",false,0,0.0f,553f);
	   
	   pc.addBorderCols(lng.equalsIgnoreCase("es")?"Firma del Paciente":"Patient's signature",0,3,0.0f,0.1f,0.0f,0.0f);
	   pc.addCols("",0,3);
	   pc.addBorderCols(lng.equalsIgnoreCase("es")?"Firma de su representante o guardián legal":"Signature of legal guardian or representative",0,4,0.0f,0.1f,0.0f,0.0f);
	   
	   pc.addCols(" ",1,dCenterFooter.size());
	   pc.addCols(" ",1,dCenterFooter.size());
       
       pc.addBorderCols(lng.equalsIgnoreCase("es")?"Testigo (solo de la firma)":"Witness (only of signature)",0,3,0.0f,0.1f,0.0f,0.0f);
	   pc.addCols("",0,7);
       
       pc.addCols(" ",1,dCenterFooter.size());
	   pc.addCols(" ",1,dCenterFooter.size());
       
       pc.addBorderCols(lng.equalsIgnoreCase("es")?"Firma del médico":"Physician's signature",0,3,0.0f,0.1f,0.0f,0.0f);
	   pc.addCols("",0,3);
	   pc.addCols(lng.equalsIgnoreCase("es")?"Fecha: "+cDateTime:" Date: "+cDateTime,0,4);
	   
	   
	
	pc.useTable("main");
	pc.addTableToCols("dCenterFooter",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
    
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}
%>