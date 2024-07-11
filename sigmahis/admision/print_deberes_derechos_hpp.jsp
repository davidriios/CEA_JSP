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

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
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

String sql = "";

CommonDataObject cdo = new CommonDataObject();

cdo = SQLMgr.getData("select  coalesce( decode(p.pasaporte,null,'',p.pasaporte||'-'||p.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||'-'||P.D_CEDULA)) cedula, p.nombre_paciente AS nombrePaciente from vw_adm_paciente p where P.PAC_ID = "+pacId);

if ( cdo == null ) cdo = new CommonDataObject();
if ( lng == null ) lng = "es";

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
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

    //PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    
    PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector tblImg = new Vector();
	tblImg.addElement(".20");
	tblImg.addElement(".60");
	tblImg.addElement(".20");

	Vector dHeader = new Vector();
	dHeader.addElement(".02");
	dHeader.addElement(".02");
	dHeader.addElement(".96");

	Vector dBullet = new Vector();
	dBullet.addElement(".03");
	dBullet.addElement(".01");
	dBullet.addElement(".96");

	Vector dFooter = new Vector();
	dFooter.addElement(".10");
	dFooter.addElement(".20");
	dFooter.addElement(".20");
	dFooter.addElement(".50");

	String bullet = ResourceBundle.getBundle("path").getString("images")+"/blackball.gif";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("tblImg",false,0,0.0f,553f);
	   pc.addCols(" ",0,1);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
	   pc.addCols(" ",0,1);
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.addCols(" ",0,dHeader.size());

			pc.setFont(14,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"Deberes y Derechos de los Pacientes":"Patient Rights and Responsibilities:",1,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"Deberes que contrae el Paciente con el Hospital:":"Patient Responsibilities:",0,dHeader.size());

			pc.setVAlignment(0);

			pc.addCols("1.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Colaborar en el cumplimiento de las normas e instrucciones establecidas en el Hospital, así como de informarse, conocer y respetar las normas de funcionamiento del Hospital.":"Collaborate with the compliance of all the norms and instructions established by the Hospital as well as inform him/herself, understand, and respect the regulations in the Hospital.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("2.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Tratar con el máximo respeto al personal del Hospital y respetar los derechos de los otros pacientes, familiares y visitantes.":"Treat with the highest level of respect all the Hospital staff and respect the rights of other patients, family members and visitors.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("3.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Utilizar de manera responsable las instalaciones y de colaborar con el mantenimiento de la habitabilidad del Hospital.":"Use the Hospital facilities in a responsible manner and collaborate with the maintenance of the habitability of the Hospital.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("4.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Cumplir con el tratamiento recomendado por su médico.  En caso contrario y cuando legalmente pueda rechazarlo, tiene el deber de solicitar y firmar el documento de alta voluntaria o liberación de  responsabilidad, donde se responsabiliza por la decisión tomada.  Si el paciente se niega a firmar este documento, la Dirección del Hospital, a propuesta de su médico responsable, podrá dar el Alta al Paciente.":"Comply with the treatment recommended by your physician and when legally possible reject treatment. The Patient must request and sign a document for voluntary discharge or liability waiver where the Patient is assuming full responsibility for the decision made. If the Patient does not want to sign these documents, the Medical Direction following the recommendation of the physician may discharge the Patient.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("5.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Cancelar las cuentas generadas por la atención recibida, proporcionando la información general y financiera necesaria, así como firmar todos los consentimientos presentados al momento de su admisión y durante su hospitalización para la realización de procedimientos médicos.":"Pay the bills generated by the attention received, provide general and financial information if necessary as well as sign all the consents presented to the them at the moment of admission and during their hospitalization before undergoing any medical procedures.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("6.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Suministrar información sobre su estado físico o sobre su salud de manera leal y verdadera, así como colaborar con su obtención.":"Provide complete and accurate information on your overall health and physical wellbeing as well as collaborating with its obtaining.",0,1);

			pc.addCols(" ",0,dHeader.size());

			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"Derechos del Paciente:":"Patient Rights:",0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());

			pc.setFont(11,1);
			pc.addCols("1.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a recibir una atención sanitaria integral adecuada a sus necesidades de salud, dentro de un funcionamiento eficiente de los recursos sanitarios existentes, a obtener una evaluación y manejo apropiado del dolor y a que su familiar responsable también tenga acceso a esta misma información.":"The Patient has the right to receive comprehensive health care appropriate to their health needs in an efficient functioning health care environment, obtain an appropriate evaluation and management of pain, and that their responsible family member has access to information.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("2.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"EL Paciente tiene derecho al respeto de su personalidad, dignidad, intimidad, seguridad y  privacidad personal, sin que pueda ser discriminado por razones de tipo social, económica, moral, ideológica, cultural, religiosa o racial.":"The Patient has the right to have his/her personality, dignity, intimacy, security, and personal privacy respected and not be discriminated for any social, economical, moral, ideological, cultural, religious or racial reason.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("3.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a la confidencialidad de toda la información relacionada con su proceso de atención, incluido el secreto de su estancia en el Hospital, salvo por exigencias legales que hagan imprescindible la entrega de la información contenida en el expediente a instancias judiciales.":"The Patient has the right to the confidentiality of all the information related with the attention process, including the secrecy of his stay in the Hospital, except for any legal requirements that make the delivery of this information obligatory to judicial authorities.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("4.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a recibir en un lenguaje comprensible, información completa y continuada, verbal y escrita, sobre su proceso incluyendo diagnósticos alternativos de tratamiento, sus riesgos y pronósticos.  En caso de que el paciente no quiera o no pueda manifiestamente recibir dicha información, ésta deberá proporcionarse a sus familiares o personas legalmente responsables.":"The Patient has the right to receive complete and continuous written and verbal information about his/her process including diagnosis, alternative treatments, risks and prognosis in a comprehensible language.  If the patient is clearly unwilling or unable to receive such information, it shall be given to the family members or legal guardians.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("5.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a la libre elección entre las opciones que le presente su médico responsable, siendo preciso su consentimiento previo expresado por escrito ante la realización de cualquier intervención, excepto los siguientes casos:":"The Patient has the right to freely choose among the options presented by his/her physician, being necessary, prior written consent must be expressed before carrying out any intervention, except in the following cases:",0,1);

			pc.flushTableBody(true);
			pc.addNewPage();

			pc.setVAlignment(2);

			pc.setFont(14,1);
			pc.addCols("\u2022  ",0,1);
			pc.setFont(11,0);
			pc.addCols((lng.equalsIgnoreCase("es")?"Cuando exista riesgo de lesión irreversible o fallecimiento y la urgencia no permita demoras.":"When there exists a risk of irreversible injury or death and the emergency does not allow any delays."),0,2);

			pc.setFont(14,1);
			pc.addCols("\u2022  ",0,1);
			pc.setFont(11,0);
			pc.addCols((lng.equalsIgnoreCase("es")?"Cuando la carencia de tratamiento suponga un riesgo para la salud pública.":"When the absence of treatment supposes a risk to public health."),0,2);

			pc.setFont(14,1);
			pc.addCols("\u2022  ",0,1);
			pc.setFont(11,0);
			pc.addCols((lng.equalsIgnoreCase("es")?"Cuando exista un imperativo legal.":"When there is a legal imperative."),0,2);

			pc.setFont(14,1);
					pc.setVAlignment(0);
			pc.addCols("\u2022  ",0,1);
			pc.setFont(11,0);
			pc.addCols((lng.equalsIgnoreCase("es")?"Cuando el paciente no esté capacitado para tomar decisiones, en cuyo caso, el derecho corresponderá a sus familiares o persona  legalmente responsable.  En caso de no existir o no ser localizados se le comunicará a la autoridad judicial.":"When the Patient is not in full capacity to make his/her own decisions. In this case the family members or legal guardian will have the right to choose. In case no family member o legal guardian is located the respective authorities will be notified."),0,2);

			pc.setVAlignment(0);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("6.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a negarse a recibir tratamiento, excepto en los casos señalados en el punto No. 5, debiendo para ello, solicitar y firmar el Alta Voluntaria y/o Relevo de Responsabilidad.":"The Patient has the right to refuse treatment, except in the cases specified in point No. 5, after requesting and signing the voluntary discharge and/or liability waiver.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("7.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a que se le asigne un médico cuyo nombre deberá conocer y que será su médico responsable y el interlocutor válido con el equipo asistencia.   En caso de ausencia de este facultativo, otro facultativo del equipo asumirá la responsabilidad.":"The Patient has the right to be assigned a physician whose name shall be known and that will be the responsible physician and valid liaison with the health team. In case this physician is absent another physician from the team will assume this responsibility. ",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("8.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a que quede constancia por escrito o en soporte técnico adecuado todo su proceso.  Esta información y  las pruebas realizadas constituyen la Expediente Clínico.  Al finalizar su estancia en el Hospital, el paciente o su familiar responsable, recibirán copia del Resumen de Egreso y del Plan de Salida del Paciente.  Igualmente tiene derecho al acceso a la información recibida en el expediente clínico dentro de de un tiempo razonable.":"The Patient has the right to have all his process recorded in writing or in digital format. This information and the test performed constitute the Medical Record.  At the end of the stay in the Hospital, the Patient or responsible family member will receive a copy of the Patient Discharge Summary and the Patient Discharge Plan. The Patient is also entitled to have access to the information in his/her Medical Record within a reasonable time.  ",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("9.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a decidir que no se realicen a su persona investigaciones, experimentos o ensayos clínicos, sin una información previa, sobre los métodos y fines del estudio y sin que éste haya otorgado su libre consentimiento por escrito.":"The Patient has the right to decide whether or not research, experiments, or clinical trials are performed on his/her person without prior written consent and/or explaining of the methods and purposes of the study.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("10.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a examinar y recibir explicación sobre todas las cuentas, sin importar la fuente de pago.":"The Patient has the right to examine and receive proper explanation on all his/her accounts regardless of the source of payment.  ",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("11.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho al correcto funcionamiento de los servicios asistenciales y administrativos y que la estructura del Hospital proporcione unas condiciones aceptables de habitabilidad, higiene, alimentación, seguridad y respeto a su intimidad.":"The Patient has the right to receive proper functioning of the health services and administrative structure of the Hospital that provide acceptable conditions of habitability, hygiene, food, security and respect for their privacy.",0,1);

			pc.addCols(" ",0,dHeader.size());
			pc.setFont(11,1);
			pc.addCols("12.",0,2);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El Paciente tiene derecho a formular sugerencias y reclamaciones, así como  a recibir respuesta por escrito, a través del Servicio de Atención al Paciente del Hospital.":"The Patient has the right to make suggestions and file complaints as well as to receive a written response by the Patient Care Department.",0,1);

		    pc.addCols(" ",0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());

	pc.setNoColumnFixWidth(dFooter);
			pc.createTable("footer",false,0,0.0f,550);

					pc.setFont(11,1);
					pc.addCols((lng.equalsIgnoreCase("es")?"Nombre del Paciente o Familiar Responsable:":"Patient's Full Name or Responsible Family Member:"),0,3);
					pc.setFont(11,0);
					pc.addBorderCols(""+cdo.getColValue("nombrePaciente"),0,1,0.1f,0.0f,0.0f,0.0f);
					pc.addCols("",0,dFooter.size());
					pc.setFont(11,1);
					pc.addCols((lng.equalsIgnoreCase("es")?"Firma del Paciente o Familiar Responsable:":"Patient's Signature or Responsible Family Member:"),0,3);
					pc.addBorderCols("",0,1,0.1f,0.0f,0.0f,0.0f);
					pc.addCols("",0,dFooter.size());
					pc.setFont(11,1);
					pc.addCols((lng.equalsIgnoreCase("es")?"Cédula  del Paciente o Familiar Responsable:":"Patient's Personal I.D. number or Responsible Family Member"),0,3);
					pc.setFont(11,0);
					pc.addBorderCols(""+cdo.getColValue("cedula"),0,1,0.1f,0.0f,0.0f,0.0f);
					pc.addCols("",0,dFooter.size());
					pc.setFont(11,1);
					pc.addCols((lng.equalsIgnoreCase("es")?"Fecha":"Date"),0,1);
					pc.addBorderCols("",0,1,0.1f,0.0f,0.0f,0.0f);
					pc.addCols("",0,2);

	        pc.useTable("main");
			pc.addTableToCols("footer",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);} 
//}
%>