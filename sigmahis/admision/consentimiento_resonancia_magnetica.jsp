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

String sql = "";
if (consentTitle == null) consentTitle = "";
if (consentName == null) consentName = "";
if (consentTitle.trim().equals("")) consentTitle = consentName;
if (lng == null) lng = "es";

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
    
	dHeader.addElement(".40"); 
	dHeader.addElement(".06"); 
	dHeader.addElement(".04"); 
    dHeader.addElement(".40");    
	dHeader.addElement(".06"); 
	dHeader.addElement(".04");
	
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
    
    int fontsize = 12;
	
	pc.setFont(fontsize,1);
	pc.addCols(consentTitle,1,dHeader.size());

	pc.addCols(" ",1,dHeader.size());
    
    pc.setFont(fontsize,1);

	pc.addCols(lng.equalsIgnoreCase("es")?"Nombre: "+cdo.getColValue("nombrePaciente"," ")+"_______ Fecha de Nacimiento: "+cdo.getColValue("fecha_nacimiento"," ")+"_______ CIP o Pasaporte: "+cdo.getColValue("cedula"," ") : "Name: "+cdo.getColValue("nombrePaciente"," ")+"_______ Date of Birth: "+cdo.getColValue("fecha_nacimiento"," ")+"_______ Personal I.D. or Passport : "+cdo.getColValue("cedula"," "),4,dHeader.size());
    
    pc.setFont(fontsize,0);
    
    pc.addCols(" ",1,dHeader.size());
    pc.addCols(lng.equalsIgnoreCase("es")?"Resonancia magnética : _____________________________________________" : "Magnetic Resonance: _____________________________________________",0,dHeader.size());
    
    pc.addCols(lng.equalsIgnoreCase("es")?"La Resonancia Magnética (RM) es un método diagnostico especializado que obtiene imágenes de alta resolución del interior del cuerpo humano utilizando un campo magnético y ondas de radio.  No utiliza radiación ionizante.\nEl equipo consta de una magneto (imán) de gran tamaño y es importante conocer  antes de iniciar un este estudio de RM si el paciente tiene algún objeto metálico en su cuerpo. El procedimiento no causa dolor." : "The Magnetic Resonance (MRI)  is a specialized diagnostic method that obtains high resolution images of the inside of the human body, using a magnetic field and radio waves. It doesn’t use ionizing radiation.\nThe equipment has a large-sized magnet and before starting an MRI study, it’s important to know if the patient has any metal object in the body. The study does not cause pain",4,dHeader.size());
    
    pc.setFont(fontsize,1);
    pc.addCols(" ",1,dHeader.size());
    pc.addCols(lng.equalsIgnoreCase("es")?"FAVOR CONTESTAR EL SIGUIENTE CUESTIONARIO":"PLEASE ANSWER THE FOLLOWING QUESTIONNAIRE",1,dHeader.size());
    pc.addCols("",1,dHeader.size());
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"HA SIDO OPERADO O TIENE USTED?":"HAVE YOU HAD SURGERY OR DO YOU HAVE",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"SI":"YES",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"NO":"NO",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"HA SIDO OPERADO O TIENE USTED?":"HAVE YOU HAD SURGERY OR DO YOU HAVE",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"SI":"YES",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"NO":"NO",1,1);
    
    pc.setFont(fontsize, 0);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Marcapaso y cables?":"Pacemakers and wires",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Implante reciente de Stent":"Recent Stent implant",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Clip de aneurisma?":"Aneurism clip",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Shunt":"Shunt",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Clip de cirugía":"Surgery clip",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Implantes de oídos":"Ear implants",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Implantes en la vista":"Eyesight implants",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"DIU (Dispositivo intrauterino)":"IUD (Intrauterine device)",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Desfibrilidor interno":"Internal defibrillator",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Coil intravascular":"Intravascular coil",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Balas o balines":"Bullets or pellets",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Válvula cardiaca":"Cardiac valve",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Estimulador y cables":"Stimulator and wires",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Prótesis artificiales":"Artificial prosthesis",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Bomba de infusión":"Infusion pump",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Amplificador auditivo":"Hearing amplifier",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Prótesis penil":"Penile prosthesis",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Toracotomía":"Thoracotomy",0,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.setFont(fontsize,1);
    pc.addBorderCols("",0,4);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"SI":"YES",1,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"NO":"NO",1,1);
    
    pc.setFont(fontsize,0);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Es  Usted es claustrofóbico?":"Are you claustrophobic?",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Ha trabajado usted  alguna vez de mecánico, soldador o trabajador de metal?":"Have you ever worked as a mechanic, welder or metal worker?",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Tiene alguna lesión facial con metal?":"Do you have any metal facial lesion?",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Se le ha removido algún metal de sus ojos?":"Have you had any metal removed from your eyes?",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Tiene tatuajes en alguna parte de su cuerpo?":"Do you have tattoos in any part of your body?",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Tiene amalgamas en sus dientes?":"Do you have amalgam fillings in your teeth?",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Esta usted embarazada?":"Are you pregnant?",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Cuando fue su último periodo menstrual? (Amerita solo para estudios pélvicos)":"When was your last menstrual cycle?    (Calls only for pelvic studies)",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Tiene algún tipo de alergia (si su respuesta es SI, especifique)\n\n":"Do you have any type of allergy (if your answer is YES, specify)\n\n",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Esta tomando algún medicamento, especifique:\n\n":"Are you taking any medication, specify:\n\n",0,4);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    
    pc.addCols(" ", 0,dHeader.size());
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Si su médico ordenó el este con medio de contraste, usted debe saber que estos sustancias capaces de resaltar determinadas estructuras anatómicas y algunas patologías.\nEl agente de contraste comúnmente utilizado en Resonancia Magnética  es el GADOLINIO y su administración usual es intravenosa.  Es un medio de contrate muy seguro y aunque se han documentado  reacciones alérgicas a este agente y algunos efectos adversos a este agente, estos son poco comunes. Su excreción es vía renal, así que es importante conocer su función renal previa al estudio. Por ende, relevo al "+_comp.getNombre()+" de toda responsabilidad por la aparición de cualquier reacción alérgica al medio de contraste. ":"If your physician ordered a study with contrast medium, you should know these substances are capable of highlighting certain anatomic structures and some pathologies.\nThe contrast agent commonly used in a Magnetic Resonance is GADOLINIUM and its usual administration is intravenously. It’s a very safe contrast medium and even though allergic reactions and some adverse effects to this agent, these are rare. Its excretion is renal, so it is important to know its renal function prior to the study.",4,dHeader.size());
    
    pc.addCols(" ", 0,dHeader.size());
    
    pc.addCols(lng.equalsIgnoreCase("es")?"Hago constar que he leído este formulario y autorizo al personal médico y técnico del "+_comp.getNombre().toUpperCase()+", para la realización del mismo.":"I certify I have read this form and authorize the physician and technical staff from "+_comp.getNombre().toUpperCase()+" to perform the test.",4,dHeader.size());

    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    
	pc.setNoColumnFixWidth(dCenterFooter);
	pc.createTable("dCenterFooter",false,0,0.0f,553f);
	   
       pc.addBorderCols(lng.equalsIgnoreCase("es")?"FIRMA":"SIGNATURE",0,3,0.0f,0.1f,0.0f,0.0f);
	   pc.addCols("",0,3);
	   pc.addCols(lng.equalsIgnoreCase("es")?"FECHA: "+cDateTime:" DATE: "+cDateTime,0,4);
	 
	pc.useTable("main");
	pc.addTableToCols("dCenterFooter",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
    
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(lng.equalsIgnoreCase("es")?"Nota: El Hospital le hace entrega de este documento en cumplimiento con la Ley 68 del 20 de noviembre del 2003, que regula los derechos y obligaciones de los pacientes en material de información y decisión libre e informada, y cumpliendo con estándares de acreditación para hospitales de Joint Commission International.":"Note: The Hospital gives this document in compliance with Law 68 of November 20th, 2003 which regulates the rights and obligations of the patients, regarding the information and informed decision-making, complying as well with the Joint Commission International accreditation standards for hospitals.", 0,dHeader.size());
    
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}
%>