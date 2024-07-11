<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String idConsent = ((request.getParameter("idConsent")==null || request.getParameter("idConsent").trim().equals(""))?"0":request.getParameter("idConsent"));
String compania = (String) session.getAttribute("_companyId");

//--------------Patient info ----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula, (select decode ( extra_logo_status,null,' ','0',' ',decode(extra_logo_path,null, ' ', extra_logo_path)) from tbl_param_consentimientos where id = "+idConsent+") extra_logo from vw_adm_paciente Where pac_id="+pacId;

cdo = SQLMgr.getData(sql);

String nombrePaciente = cdo.getColValue("nombrePaciente");
String cedulaPaciente = cdo.getColValue("cedula");
String nombreCompania = _comp.getNombre();
String nombreCompaniaCorto = _comp.getNombreCorto();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
	String fotosFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72* 8.5f;//612
	float height = 72 * 14f;//1008
	boolean isLandscape = false;
	float leftRightMargin = 30.0f;
	float topMargin = 20.0f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = " ADMISION";
	String subTitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

    //Main table
	Vector tblMain = new Vector();
	tblMain.addElement("0.05");
	tblMain.addElement("0.95");

	//Title table
	Vector tblTitle = new Vector();
	tblTitle.addElement(".20");
	tblTitle.addElement(".60");
	tblTitle.addElement(".20");

	//Finger Print Table
	Vector tblFP = new Vector();
	tblFP.addElement("20");
	tblFP.addElement("08");
	tblFP.addElement("62");
	
	pc.setFont(9,1);
	
	//Title
	pc.setNoColumnFixWidth(tblTitle);
	pc.createTable("tblTitle");
	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);
	pc.setVAlignment(1);
	pc.addCols(nombreCompania+"\nCONSENTIMIENTO INFORMADO",1,1);
	pc.addImageCols(fotosFolder+"/"+((cdo.getColValue("extra_logo") != null && !cdo.getColValue("extra_logo").trim().equals(""))?cdo.getColValue("extra_logo"):"blank.gif"),30.0f,1);
	pc.resetVAlignment();
	//---- end table title

	pc.setFont(9,0);
	//Finger Print
	pc.setNoColumnFixWidth(tblFP);
	pc.createTable("tblFP");
	pc.setFont(9,0);
	pc.addCols("Huella digital del Paciente",0,1);
	pc.addBorderCols(" ",1,1,0.5f,0.5f,0.5f,0.5f,45f);
	pc.addCols(" ",0,1);

	pc.resetFont();
	//------- end table fingerprint


	//Main Table
	pc.setNoColumnFixWidth(tblMain);
	pc.createTable();

	pc.setTableHeader(2);

	//displaying tblTitle
	//String tableName, int hAlign, int colSpan, float height
	pc.useTable("main");
	pc.addTableToCols("tblTitle",1,tblMain.size(),0.0f);

	pc.setFont(10,1);
	pc.addCols("", 0, tblMain.size());
	pc.addCols("\t\t\t\tGENERALIDADES:",0,tblMain.size());

	pc.setFont(9,0);
	pc.addCols("\t\t\t\t"+nombreCompania+", considera que \"usted\" tiene derecho a ser informado(a) y tener potesdad de tomar decisiones con respecto a los tratamientos y procedimeintos m�dicos y/o quir�rgicos de se efect�en en su persona. Usted debe ser parte de la decisi�n de este proceso. Por tanto consideramos que su(s) m�dico(s) debe(n) proveerle la informaci�n y consejos necesarios, basados en los hechos de su caso particular.",4, tblMain.size());

	pc.addCols("\n\t\t\t\tEste documento ha sido elaborado para confirmar su aceptaci�n al procedimiento m�dico y/o quir�rgico recomendado por su(s) m�dico(s).",4,tblMain.size());

	pc.addCols("\n\t\t\t\tLa informaci�n siguiente contiene un texto est�ndar de consentimiento para procedimientos m�dicos y quir�rgicos. Es utilizado tanto en procedimientos menores como en los m�s complicados y serios. No ha sido elaborado para asustarlo(a) o alarmarlo(a), es un esfuerzo para que usted est� MEJOR INFORMADO(A) y explicarle que TODOS LOS PROCEDIMIENTOS conllevan riesgos. Por ejemplo, muchas operaciones s�lo presentan la posibilidad remota de necesitar transfusiones sangu�neas, sin embargo las mismas son mencionados en este texto. La intenci�n de este algo PREGUNTE a su(s) m�dico(s). Si usted tiene dudas o preguntas no contestadas a satisfacci�n, NO FIRME ESTE CONSENTIMIENTO.",4,tblMain.size());

	pc.setFont(10,1);
	pc.addCols(" ", 0, tblMain.size());
	pc.addCols("CONSENTIMIENTO PARA PROCEDIMIENTOS MEDICOS Y QUIRURGICOS",0,tblMain.size());

	pc.setFont(9,0);
	pc.addCols("\n1.",0,1);
	pc.addCols("\nReconozco que durante el curso de mi operaci�n, cuidado post-operatorio, tratamiento m�dico, anestesia, analgesia u otro procedimiento existen condiciones imprevistas que pueden necesitar procedimientos diferentes o adicionales a los que hayan sido descritos en el presente documento, \"po esta raz�n autorizo a mi(s) m�dico(s) y a sus asistentes o designados a realizar dicho(s) procedimientos quir�rgicos y otro(s) procedimientos(s) que sea(n) nesecario(s) en el buen ejercicio y juicio profesional de los mismos.\" La autorizaci�n que doy ese extiende al tratamiento de todas las condiciones que requieran tratamiento inmediato y que surjan como imprevistos durante o despu�s del procedimiento o cirug�a.", 4, 1);

	pc.addCols("\n2.",0,1);
	pc.addCols("\n\"He sido informado(a) que existen riesgos significativos\" tales como reacciones al�rgicas, co�gulos en las venas y pulmones, p�rdida de sangre, infecciones y paro card�aco, que pueden llevarme a la muerte, incapacidad parcial o permanente y que de suscitarse deben ser atendidos.", 4, 1);

	pc.addCols("\n3.",0,1);
	pc.addCols("\n\"Reconozco\" que en los casos en donde son nesecarias incisiones y/o suturas pueden ocurir infecciones, dolor en las heridas o formaci�n de hernias (debilidad o abombamiento) y que estas complicaciones pueden requerir tratamientos o procedimientos futuros.", 4, 1);

	pc.addCols("\n4.",0,1);
	pc.addCols("\n\"Reconozco\" que en la lista de riesgos y complicaciones de este documento pueden no estar incluidos todos los riesgos posibles o conocidos de la cirug�a o procedimiento que se me planifican realizar, pero en las mismas expone las complicaciones m�s comunes o severas. Por lo cual reconozco que en el futuro pueden emerger complicaciones no mencionadas es este documento.", 4, 1);

	pc.setFont(9,1);
	pc.addCols("\n5.",0,1);
	pc.addCols("\nReconozco que mi(s) m�dico(s) me ha(n) se�alado los benficios razonables esperados, pero no me ha(n) dado garant�a ni seguridad del resultado que pueda obtenerse de la cirug�a o procedimiento ni en la cura de mi condici�n.", 4, 1);

	pc.setFont(9,0);

	pc.addCols("\n6.",0,1);
	pc.addCols("\n\"Doy consentimiento\" para que, si fuera necesario se me administre anestesia y/o analgesia por parte de los m�dicos que me atienden o por parte de una anestesi�logo u otra persona calificada bajo la direcci�n de mi(s) m�dico(s). Entiendo que la anestesia y/o analgesia involucren riesgos y complicaciones potenciales. Entiendo que dichas complicaciones pueden resultar del uso de la anestesia y/o analgesia incluyendo alergias, da�os serios a �rganos vitales como el cerebro, el coraz�n, los pulmones, el h�gado, los ri�ones y que en algunos casos pueden resultar sen par�lis, paro cardi�co y hasta la muerte. Otros riesgos de la anestesia general pueden ser lesiones en las cuerdas vocales, dientes y ojos. En las anestesias espinales (raqu�dea) y epidural pueden existir reacciones no deseadas talos como el dolor de cabeza y el dolor cr�nico.", 4, 1);

	pc.addCols("\n7.",0,1);
	pc.addCols("\n\"Doy consentimiento\" para el uso de transfusiones sangu�neas y productos sangu�neos que sean necesarias a criterio de mi(s) m�dico(s). Reconozco los riesgos inherentes de las transfusiones de sangre y tengo el conocimiento de que el "+nombreCompania+" practica todas las pruebas de laboratorio necesarias y disponibles actualmente para evitar enfermedades transmisibles como lomson la Hepatitis y el SIDA, pero igualmente se me ha informado de la existensia de un riesgo de contraer estas enfermedades debido a la posibilidad de que las mismas se encuentren en periodo de incubaci�n al momento de hacer la prueba al donante y por lo tanto no pueden detectarse en ninguna prueba de laboratorio." , 4, 1);

	pc.addCols("\n8.",0,1);
	pc.addCols("\n\"Autorizo a\" "+nombreCompania+" o mi(s) m�dico(s), para que seg�n los procedimientos usuales dispongan de los tejidos o partes de los mismos que me sean removidos quir�rgicamente." , 4, 1);


   	pc.setFont(9,1);
	pc.addCols("\n9.",0,1);
	pc.addCols("\nENTIENDO QUE CUALQUIER ASPECTO DE ESTE DOCUMENTO QUE YO NO ENTIENDA ME DEBE SER EXPLICADO CON MAYORES DETALLES PREGUNTANDOLE A MI(S) MEDICO(S) O A SUS ASOCIADO(S)" , 4, 1);

	pc.setFont(9,0);

	pc.addCols("\n10.",0,1);
	pc.addCols("\n\"Certifico que \" mi(s) m�dico(s) me ha(n) dado la oportunidad de hacer preguntas y me ha(n) informado del car�cter y naturaleza del(los) procedimientos m�dico quir�rgicos(s) propuesto(s), de los beneficios que obtiendr�a de los mismos, incluyendo de las consecuencias de la ausencia de tratamiento. Me ha(s) informado tambi�n de las posibilidades, complicaciones, riesgos conocidos y de las formas alternas de tratamiento." , 4, 1);

	pc.addCols("\n11.",0,1);
	pc.addCols("\nLas siguientes son las excepciones referentes al tratamiento(s) y/o examen(es), y/o intervenci�n(es) quir�rgica(s), y/o procedimiento(s), y/o suministros de medicamentos, y/o transfusiones, y/o suministro de anestesia que llegen a considerarse en alg�n momento _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1,57f);
	pc.addCols("",1,1);
	pc.addCols("(Describa si \"hay\") _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _",4,1,20f);

	pc.flushTableBody(true);
	pc.addNewPage();

	pc.setVAlignment(3);

	pc.addCols("\n12.",0,1);
	pc.addCols("\nMi(s) m�dico(s) se ha(n) informado que el(los) procedimientos que planifican hacerme es (son) el (los) siguiente(s):\n_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1,57f);

	pc.resetVAlignment();

	pc.addCols("13.",0,1);
	pc.addCols("He sido informado(a) que estudiantes de medicina y enfermer�a de las Universidades de Panam� podr�an observar el desarrollo de mi caso, los procedimientos, tratamientos e intervenciones que se me realicen, siempre y cuando mi m�dico tratante lo permita.\n\nHe sido informado(a) que los estudiantes no dar�n �rdenes m�dicas, no intervendr�n en los procedimientos, tratamientos e intervenciones que se realicen durante mi estad�a en el "+nombreCompania+", ser�n meros espectadores y oyentes a fin de contribuir con su formaci�n." , 4, 1);

	pc.setFont(9,1);
	pc.addCols("\n14.",0,1);
	pc.addCols("\nCERTIFICO QUE TENGO LA SUFICIENTE INFORMACION PARA DAR CONSENTIMIENTO Y QUE MI(S) MEDICO(S) ME HA(N) PREGUNTADO SI QUIERO UNA INFORMACION MAS DETALLADA, PERO ESTOY SATISFECHO(A) CON LAS EXPLICACIONES QUE ME HA(N) DADO Y NO NECESITO MAS INFORMACION." , 4, 1);

	pc.setFont(9,0);

	pc.addCols("\n15.",0,1);
	pc.addCols("\nEstoy consciente que el (los) M�dico(s) Tratante(s) no es (son) empleado(s) del "+nombreCompania+" y por consiguiente exoneramos al "+nombreCompania+" de cualquier responsabilidad o negligencia del (los) m�dico(s)." , 4, 1);

	pc.addCols("\nDoy mi consentimiento para el (los) Procedimiento (s) M�dico(s) y/o Quir�rgico (s) descrito (s) en el punto 12 y acepto todos los t�rminos arriba citados:" , 4, tblMain.size());

	pc.addCols("\n",0,1);
	pc.addCols("\nNombre Completo del Paciente: "+nombrePaciente , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nFirma del Paciente:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nC�dula del Paciente: "+cedulaPaciente , 4, 1);


	pc.addCols("\nFirma de la Persona Responsable (enti�ndase como persona responsable los esposos, padre, madre, tutor)" , 4, tblMain.size());

	pc.addCols("",0,1);
	pc.addCols("Nombre Completo de la Persona Responsable:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("C�dula de la Persona Responsable:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("\nFirma a ruego (se har� �nicamente cuando la persona responsable no puede firma y le pida a alguien que lo haga por ella):" , 4, tblMain.size());

	pc.addCols("",0,1);
	pc.addCols("\nNombre Completo del Firmante:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nFirma:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nC�dula:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);


	pc.addCols("",0,1);
	pc.addCols("\nFirma  del Testigo 1:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nC�dula del Testigo 1:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("",0,1);
	pc.addCols("\nFirma  del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nC�dula del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols(" ",0,tblMain.size());

	pc.useTable("main");
	pc.addTableToCols("tblFP",1,tblMain.size(),0.0f);

	pc.setFont(7,0);
	pc.addCols("\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tEn caso de paciente inconsciente o incapaz de tomar decisiones al momento de su admisi�n, dos testigos firmar�n el presente documento\n(Si viene acompa�ado, uno de los testigos debe ser el acompa�ante).",4,tblMain.size());

	pc.setFont(9,0);
	pc.addCols("\n",0,1);
	pc.addCols("\nFirma  del Testigo 1:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nC�dula del Testigo 1:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("\n",0,1);
	pc.addCols("\nFirma  del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nC�dula del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);


	pc.setFont(9,0);
	pc.addCols("\n",0,1);
	pc.addCols("\nFuncionario del "+nombreCompania+"_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nNombre Completo:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("\n",0,1);
	pc.addCols("\nFirma  del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nC�dula del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("\n",0,1);
	pc.addCols("\nFecha:_____/_____/_________" , 4, 1);

	pc.setFont(7,0);
	pc.addCols("\nEl suscrito en mi condici�n de m�dico tratante del paciente declaro que; el(los) procedimiento(s) m�dico(s) y/o quir�rgico(s) descrito(s) en este documento,los posibles riesgos u complicaciones, tratamientos alternos, incluyendo la ausencia de tratamiento y los resultados anticipados, le fueron explicados por mi al paciente o su representante de que este diera su consentimiento para efectuar los mismos.",4,tblMain.size());

	pc.setFont(9,0);

	pc.addCols("\n",0,1);
	pc.addCols("\nNombre del M�dico:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _Registro #_ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("\n",0,1);
	pc.addCols("\nFecha:_____/_____/_________" , 4, 1);

	pc.addCols("\nFirma _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, tblMain.size());

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>