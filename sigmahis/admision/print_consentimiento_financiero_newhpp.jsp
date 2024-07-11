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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String lng = request.getParameter("lng");

String compania = (String) session.getAttribute("_companyId");

if (lng == null) lng = "es";

//--------------Query para obtener datos del Paciente ----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula from vw_adm_paciente Where pac_id="+pacId;

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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

	float width = 72* 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 50.0f;//30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = " ADMISIÓN";
	String subTitle = "CONSENTIMIENTO FINANCIERO";
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	
	//------------------------------------------------------------------------------------

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}


    Vector dHeader = new Vector();
		dHeader.addElement("6");
		dHeader.addElement("40");
		dHeader.addElement("45");
		dHeader.addElement("26");

		Vector tblImg = new Vector();
        tblImg.addElement(".20");
        tblImg.addElement(".50");
        tblImg.addElement(".30");
        
        int fontsize = 12;
        
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

		pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		pc.setFont(fontsize, 1);

		pc.addCols(title, 1, dHeader.size(),15.2f);
		pc.addCols(subTitle, 1, dHeader.size());
		pc.addCols("", 1, dHeader.size(), 10.2f);

		pc.setFont(fontsize, 0);
        pc.setVAlignment(0);
        
        pc.addCols("1.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Los suscritos a saber: "+cdo.getColValue("nombrePaciente","____________________________________")+" con cédula de identidad personal o pasaporte No. "+cdo.getColValue("cedula","___________________________")+" he (hemos) venido al Hospital Punta Pacífica voluntariamente para que se me realice los exámenes, tratamientos, procedimientos y/o cirugías que prescribe mi médico.  Aceptamos igualmente seguir las Normas para pacientes que rigen en esta institución. ":"The undersigned: "+cdo.getColValue("nombrePaciente","____________________________________")+" with personal identification number or Passport No. "+cdo.getColValue("cedula","___________________________")+" has (have) come voluntarily to Punta Pacifica Hospital to get tests, treatments, procedures and/or surgeries prescribed by my physician. We also accept to follow the patients Regulations that rule in this institution.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());

		pc.addCols("2.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"El Hospital Punta Pacífica cuenta con un programa de médicos hospitalistas idóneos y debidamente acreditados disponibles 24/7  que velan por la atención y cuidado integral de los pacientes hospitalizados; garantizando en todo momento una atención segura y de calidad en coordinación con su médico tratante.":"Punta Pacifica Hospital has a program with certified and duly accredited hospitalist physicians, available 24/7 to look after the complete care of hospitalized patients, guaranteeing a safe and quality care in coordination with the treating physicians.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());

		pc.addCols("3.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Reconocemos que el hecho de ser admitidos en cualquier forma en el Hospital Punta Pacífica o en cualquiera de sus entidades afiliadas, para recibir tratamiento, procedimientos médicos o quirúrgicos, generarán gastos que se reflejarán y se nos comunicarán en un estado de cuenta, el cual desde este momento nos comprometemos a cubrir en su totalidad.":"We acknowledge the fact that being admitted in any way to Hospital Punta Pacifica or any of its affiliated entities, to receive treatment, medical or surgical procedures will generate expenses to be reflected and communicated to us in a billing statement, which we commit to cover in full as of this moment.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());

		pc.addCols("4.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Nos comprometemos a que en caso de utilizar un seguro de  hospitalización, cualquier suma que este seguro no cubra, será pagada en su totalidad por nosotros una vez nos sea notificada, por parte del Hospital Punta Pacífica o por la Compañía de Seguros, la suma adeudada.":"We commit ourselves that in case of using health insurance, any amount not covered by the insurance company will be paid in total by us, once the amount due is notified to us by Punta Pacifica Hospital or the Insurance Company.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());

		pc.addCols("5.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Nos comprometemos a hacer todos los abonos al estado de cuenta que nos solicite el Hospital Punta Pacífica, durante la estadía de EL PACIENTE en sus instalaciones.":"We commit ourselves to make all the deposits to the billing statement requested by Punta Pacifica Hospital during THE PATIENT’S stay in your facilities.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());

		pc.addCols("6.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Reconocemos que hemos sido informados por el personal del Hospital Punta Pacífica, sobre los costos de las habitaciones, por lo que nos comprometemos a cancelarla en su totalidad o en caso de contar con póliza de salud, la diferencia que el seguro deje de cubrir.":"We acknowledge we have been informed by Punta Pacifica Hospital staff about the room costs; therefore we commit ourselves to pay the room in full or the difference the insurance company doesn’t cover, in case of having health insurance.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());

        pc.addCols("7.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Reconocemos que al expedirse el estado de cuenta puede que el mismo no incluya la totalidad de los cargos y honorarios médicos generados a la fecha de corte, ya sea porque los mismos no hayan sido procesados o presentado por los médicos  o proveedores, por lo que nos comprometemos a pagar toda suma que se exceda del estado de cuenta.":"We acknowledge the moment the billing statement is issued, it may not include the total charges and medical fees generated by the cut-off date, either because they were not processed or presented by the physicians or suppliers. We commit ourselves to pay any exceeded amount from the billing statement.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("8.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"En caso de no estar en capacidad para cubrir los gastos ocasionados durante la hospitalización, expresamente autorizamos al Hospital Punta Pacífica a trasladar al PACIENTE  a  una institución pública de salud, siempre que las mínimas condiciones médicas lo permitan, es decir que la condición del paciente se encuentre estabilizada  y fuera de peligro de muerte.":"In case of not having the capacity to cover the expenses generated during the hospitalization, we expressly authorize Punta Pacifica Hospital to transfer the PATIENT to a public health institution, as long as the minimum medical conditions allow to do so; meaning the patient is stable and out of any life-threatening danger.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("9.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"De requerir traslado a otra institución por cualquier motivo, cancelaremos el saldo del estado de cuenta antes del traslado.":"In case of requiring transfer to another institution for any reason, we will cancel the balance of the billing statement before the transfer.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("10.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Autorizamos expresamente y de manera irrevocable al Hospital Punta Pacífica, para que, de conformidad con lo dispuesto en el artículo 24 y demás disposiciones aplicables de la ley 24 del 22 de mayo del 2002, consulte, suministre, o intercambie información con los bancos, agencias de información o agentes económicos de la localidad o del exterior, relacionada con mi historial de crédito y relaciones con acreedores.":"We expressly and irrevocably authorize Punta Pacifica Hospital, in conformity with what’s stated in article 24 and other dispositions applicable to Law 24 from May 22nd, 2002 to consult, provide or exchange information with banks, local or foreign information or financial agents, regarding my credit history and relationship with my creditors.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("11.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Asimismo, HOSPITAL  PUNTA PACFICA, S.A.,  también queda facultado, de conformidad con lo estipulado en el numeral 4 del artículo 23 de la ley 24  del 22 de mayo del 2002, para recopilar y / o transmitir cualesquiera datos sobre mi historial de crédito y relaciones con mis acreedores a cualesquiera agencias de información de datos, bancos o agentes económicos de la localidad o del exterior, así como para que solicite u obtenga información y documentos relacionados con mi persona, ya sea de oficinas o funcionarios gubernamentales, personas  o empresas privadas, tanto nacionales como extranjeras. Esta autorización tendrá vigencia para que HOSPITAL PUNTA PACIFICA S.A., ejerza tantas veces como sea necesario, durante todo el tiempo que mantenga cualquier tipo de relación bancaria.":"PUNTA PACIFICA HOSPITAL is under the authority as well, in conformity with what’s stated in paragraph 4 from article 23 of Law 24 from May 22nd, 2002 to gather and/or communicate any information about my credit history and relationships with my creditors to information agents, local or foreign banks or financial agents, as well as requesting or obtaining information and documents related to me, from office or government representatives, national or foreign private workers or businesses. This authorization will be valid so that PUNTA PACIFICA HOSPITAL, S.A. can practice it as many times as necessary during the entire time a bank relationship is maintained.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("12.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Reconocemos que el Hospital Punta Pacífica,  sus representantes, funcionarios o agentes no serán responsables por errores en los datos existentes en nuestro historial de crédito, ni por posibles daños y perjuicios que lo contenido en el mismo pueda ocasionar.":"We acknowledge Punta Pacifica Hospital, its representatives, workers or agents will not be responsible for errors in the existing data from our credit history, nor for any possible damages and harm the content may cause.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("13.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Autorizamos al Hospital Punta Pacífica a suministrar a la Compañía de Seguros correspondientes, toda la información médica u otra información relacionada a mi Historial Médico requerido, para el análisis de cualquier reclamación para el pago de los servicios brindados.  Esta autorización se extiende a la autorización para reproducir fotocopia  a petición de la Compañía de Seguros correspondientes.":"We authorize Punta Pacifica Hospital to provide all the medical information or any other related with my Medical History to the corresponding Insurance Company, for the analysis of any claim related with the payment of the services offered. This authorization is extended to the request from the corresponding Insurance Company to reproduce photocopies.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("14.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Reconocemos que he sido informado  por parte de un funcionario del Hospital Punta Pacífica que no debo ingresar con objetos de valor y que el Hospital posee Cajas de Seguridad a disposición de sus pacientes.":"We acknowledge we have been informed by Punta Pacifica Hospital’s staff member that I shouldn’t be admitted with valuable objects and that the Hospital has Safety Boxes available for the patients.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("15.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"En caso de rehusar el uso de las cajas de seguridad, eximimos  de toda responsabilidad al Hospital Punta Pacíficas,  por la pérdida de  los objetos  que haya ingresado  durante mi estancia en el Hospital.":"In case of refusing to use the safety boxes, we exempt Punta Pacifica Hospital of any responsibility for the loss of objects brought in during my Hospital stay.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("16.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"El Hospital Punta Pacífica, afiliado a John Hopkins Medicine International, le ofrece una dieta balanceada de acuerdo a su estado de salud, por lo cual no se hace responsable por las consecuencias médicas, de salud o económicas que puedan producirse por el  ingreso y consumo de alimentos diferentes a su dieta, ya que esto puede ocasionar retraso en su tratamiento médico e intoxicaciones entre otros problemas y complicaciones.":"Punta Pacifica Hospital, affiliated to Johns Hopkins Medicine International, will offer a balanced diet according to your state of health, not being responsible for the medical, health or financial consequences that may happen due to the admission and consumption of any foods different from your diet, given this may cause delays in your medical treatment and food poisonings, among other problems and complications.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("17.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"El Hospital Punta Pacífica está  en disposición de ofrecer el servicio de Comida Kosher, preparada por el  Centro Cultural Hebreo de Panamá, tomando en cuenta las normas de terapia nutricional brindadas por  Departamento de Nutrición del Hospital Punta Pacífica.":"Punta Pacifica Hospital is willing to offer the Kosher Food service, prepared by the Hebrew Cultural Center of Panama, taking in account the nutritional therapy regulations offered by Punta Pacifica Hospital’s Nutrition Department.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("18.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Aceptamos que este servicio NO está considerado dentro del costo de la habitación, por lo que representa un cargo adicional.":"We accept this service is NOT considered within the cost of the room, representing an additional cost.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("19.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Estamos en pleno conocimiento de que para garantizar la seguridad,  el seguimiento  farmacológico y la calidad de los medicamentos dispensados a los pacientes que ingresan al Hospital Punta Pacífica, no se permite a los mismos que ingresen con sus propios medicamentos.":"We have full knowledge that in order to guarantee safety, pharmacological follow-up and quality of the medications given to patients admitted to Punta Pacifica Hospital, they will not be allowed to come in with their own medications.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("20.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"La única excepción a esta notificación será  de algún paciente que ingrese de manera urgente y está recibiendo algún medicamento indispensable y que a juicio de su médico tratante no pueda suspender su tratamiento y que el mismo no esté disponible en el país, o en el inventario de la Farmacia  en ese momento; únicamente entonces será aceptado, por la Dirección Médica y el Médico Tratante, el cual será entregado a la Farmacia Hospitalaria quien tramitará la entrega del mismo luego de su acondicionamiento, facturando sólo el manejo y trámite del mismo. ":"The only exception to this notice will apply to any patient urgently admitted and receiving any vital medication that under the judgment of the treating physician, the treatment can’t be suspended, or the medication is not available in the country or not among the Pharmacy’s inventory. Only then it will be accepted by the Medical Management and Treating Physician, which will be given to the Hospital Pharmacy, who will process the delivery after its packaging, only billing the processing and management of the medication. ", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        
        pc.addCols("21.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Este procedimiento sólo aplicará  y tendrá validez solamente hasta que la Farmacia Hospitalaria logre obtener el (los) medicamento (s) en mención.":"This procedure will only apply and will be valid only until the Hospital Pharmacy obtains the medication(s) mentioned.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("22.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"La responsabilidad por el(los) resultado(s) del tratamiento terapéutico de los medicamentos en estas condiciones, será exclusivamente del médico tratante.":"The responsibility for the result(s) of the medication therapeutic treatment under these conditions will be exclusively of the treating physician.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("23.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Aceptamos que los medicamentos generados de la  atención del paciente se facturarán  en la cuenta, una vez se dé inicio al cumplimiento de las órdenes médicas.":"We accept the medications generated from the patient’s care will be charged in the bill, once the compliance of the medical orders has begun.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("24.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Estamos en pleno conocimiento de que los honorarios médicos son independientes al funcionamiento interno, políticas y costos de las facilidades del Hospital Punta Pacífica, por lo que es necesario que conversemos con cada uno de los médicos encargados del caso, referente al tema del costo de sus servicios, previo a la realización del procedimiento y / o cirugía.":"We have full knowledge that the medical fees are independent from the internal functioning, policies and costs of Punta Pacifica Hospital facilities; therefore it’s necessary to speak to each one of the physicians in charge of the case, regarding the cost of their services, previous to making the procedure and/or surgery.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("25.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Aceptamos que hemos sido informados por parte de un funcionario del Hospital Punta Pacífica, acerca de los Honorarios Médicos, en cuanto a la necesidad de orientación tocante a los mismos.":"We accept we have been informed by a staff member from Punta Pacifica Hospital about the Medical Fees, regarding the need for orientation about those fees.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("26.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Reconocemos que las  pacientes que se admitan por Maternidad, realizarán un abono  de $50.00 adicional al costo del Paquete de Maternidad, o del pago establecido por su Aseguradora.":"We acknowledge patients admitted to the Maternity Ward will make a $50.00 deposit, in addition to the cost of the Maternity Package, or payment established by their Insurance Company.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("27.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Este abono será cargado a la cuenta de no seguir el procedimiento para la decoración de la puerta de la habitación, de cumplir con el protocolo, se le reembolsará a su salida, de acuerdo a la forma de pago en que hizo efectivo el depósito de admisión.":"This deposit will be charged in the bill when not following the procedure for decorating the door of the room. If complying with the protocol, it will be reimbursed at discharge, according to the payment method the admission’s deposit was made.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("28.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Aceptamos que las decoraciones deben ser pegadas al papel o cocidas a la tela directamente.":"We accept all decorations must be stuck to the paper or stitched directly to the cloth.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("29.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Estamos en pleno conocimiento de que no son permitidas las decoraciones que conlleven el uso de goma, cintas adhesivas, tornillos, clips, tachuelas u otros materiales que se utilicen de manera directa a la puerta de la habitación.":"We are in full knowledge that decorations requiring glue, adhesive tapes, screws, clips, tacks or other materials used directly in the door of the room are not allowed.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("30.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Igualmente nos comprometemos al momento del egreso, a revisar el equipaje, garantizando de esta forma no dejar ninguna pertenencia (prendas, ni objetos de valor).":"We commit ourselves to checking the luggage at the moment of discharge, making sure in this way no belongings are left behind (jewelry, valuable objects).", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("31.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"En base a lo anterior, exoneramos de forma irrevocable  al Hospital Punta Pacífica, por cualquier valor que sea objeto de reclamo, después de haber firmado el formulario de Comprobante para la Revisión de la Habitaciones a la Salida.":"Based on the above mentioned, we irrevocably exempt Punta Pacifica Hospital for the claim of any valuable object after signing the Receipt form for the Checking of the Rooms at Discharge.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("32.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Aceptamos que El Hospital Punta Pacífica pone a nuestra disposición dentro de la habitación un Control Remoto para la TV, el cual será cargado a la cuenta por un valor de $ 25.00.":"We accept Punta Pacifica Hospital puts a TV Remote Control at our disposition inside the room, which will be billed for a value of $__25.00___.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("33.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Tengo pleno conocimiento de que al egresar del Hospital y devolver el Control Remoto en la Estación de Enfermería, se reversará de la cuenta este monto. ":"I have full knowledge that at the moment of being discharged from the Hospital and returning the Remote Control in the Nursing Station, this charge will be reversed from the bill. ", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("34.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Como medida necesaria para el cumplimiento de la ley 13 del 2008, está prohibido fumar en todas las instalaciones del Hospital que incluyen más no se limitan a todas las habitaciones, salones de espera, pasillos, elevadores, puentes de accesos, áreas comunes interiores y exteriores y estacionamientos del complejo hospitalario. El Hospital tampoco ofrece servicio de acompañamiento y/o escolta para que el paciente pueda fumar fuera del área mencionada. El Hospital reportará su falta a las autoridades correspondientes, sin perjuicio de reservarse el derecho a hacer un cargo adicional por concepto de lavandería y tintorería de cortinas, colchas, cobertores, etc. de por lo menos $500.00.":"As a necessary measure to comply with Law 13 of 2008, it’s forbidden to smoke in all the Hospital facilities that include, but are not limited to all the rooms, waiting areas, halls, elevators, access points, internal and external common areas and hospital parking lots. The Hospital doesn’t offer either the escort service and/or escort, so the patient can smoke outside the areas mentioned. The Hospital will notify any misconduct to the corresponding authorities, without prejudice to make an additional charge of at least $500.00 for laundry and dry cleaning of curtains, blankets, comforters, etc.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
        
        pc.addCols("35.", 0, 1);
		pc.addCols(lng.equalsIgnoreCase("es")?"Por este medio reconocemos que hemos recibido el documento de los Derechos y Responsabilidades del Paciente.":"By this mean we acknowledge we have received the document about Patient’s Rights and Responsibilities.", 3, 3);
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols(lng.equalsIgnoreCase("es")?"Por este  medio declaramos que hemos entendido cabalmente el contenido de este documento, por lo tanto estamos en pleno conocimiento de todas las directrices y condiciones que se esbozan en el mismo.":"By this mean we declare we have completely understood the content of this document; therefore we are in full knowledge of all the guidelines and conditions outlined in it.", 1, dHeader.size());
        
		pc.setVAlignment(2);
        
        pc.addCols("\n", 1, dHeader.size());
		pc.addCols(lng.equalsIgnoreCase("es")?"Aceptamos todos los términos y condiciones que constan en el presente documento:\n\n":"We accept all the terms and conditions stated in the current document:\n\n", 0, dHeader.size());
		pc.addCols(lng.equalsIgnoreCase("es")?"Nombre Completo del Paciente":"Complete Name of the Patient", 0, 2, 15.2f);
		pc.addBorderCols(cdo.getColValue("nombrePaciente"), 0, 2, 0.5f, 0.0f, 0.0f, 0.0f,15.2f);


		pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Paciente":"Patient’s Signature", 0, 2, 15.2f);
		pc.addBorderCols("", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte":"Personal I.D. or passport ", 0, 2, 15.2f);
		pc.addBorderCols(cdo.getColValue("cedula"), 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addBorderCols(lng.equalsIgnoreCase("es")?"Nombre Completo de la Persona Responsable (entiéndase como persona responsable los esposos, padre, madre o tutor)\n\n":"Complete Name of the Person in Charge (understood as the person in charge, husband, wife, father, mother or tutor)\n\n", 0, dHeader.size(), 0.0f, 0.0f, 0.0f, 0.0f, 40.2f);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma de la persona responsable":"Signature of Person in Charge", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte":"Personal I.D. or Passport", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(" ", 1, dHeader.size(),10.2f);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma de ruego (se hará únicamente cuando la persona no pueda firmar y le pida a alguien que lo haga por ella)":"Signature at his/her request (will only be done when the person can’t sign and asks somebody to do so on his/her behalf)",0, dHeader.size());


        pc.addCols(lng.equalsIgnoreCase("es")?"Nombre completo del Firmante":"Complete Name of the Person Signing", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma":"Signature", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte":"Personal I.D. or Passport", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);


		//Testigo 1
		pc.addCols(lng.equalsIgnoreCase("es")?"Nombre completo del Testigo 1":"", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Testigo 1":"Complete Name of Witness 1", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 20.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte":"Personal I.D. or Passport", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		//pc.flushTableBody(true);
		//pc.addNewPage();

		//Testigo 2
		pc.addCols(lng.equalsIgnoreCase("es")?"Nombre completo del Testigo 2":"Complete Name of Witness 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Testigo 2":"Signature of Witness 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte":"Personal I.D. or Passport", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		//Huella digital
		pc.addCols(lng.equalsIgnoreCase("es")?"Huella digital del paciente":"Fingerprint of the Patient", 0, dHeader.size(), 40.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.5f, 0.5f, 0.5f,60.2f);
		pc.addCols(" ", 0, 2);

		pc.addCols(lng.equalsIgnoreCase("es")?"En este caso de paciente inconsciente o incapaz de tomar decisiones al momento de admisión firmarán dos testigos el presente documento (Si viene acompañado uno de los testigos debe ser el acompañante)\n\n":"In case of an unconscious patient or unable to make decisions at the moment of admission, two witnesses will sign the current document (if accompanied, one of the witnesses must be the companion)\n\n", 0, dHeader.size(), 30.2f);

	   	//Testigo 1
		pc.addCols(lng.equalsIgnoreCase("es")?"Nombre completo del Testigo 1":"Complete Name of Witness 1", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Testigo 1":"Signature of Witness 1", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte":"Personal I.D. or Passport", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

	   	pc.addCols(" ", 0, dHeader.size(),20.0f);

	   //Testigo 2
	   	pc.addCols(lng.equalsIgnoreCase("es")?"Nombre completo del Testigo 2":"Complete Name of Witness 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Testigo 2":"Signature of Witness 2", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte":"Personal I.D. or Passport", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);
        
        pc.addCols("\n", 1, dHeader.size());
        pc.addCols("\n", 1, dHeader.size());
    
        pc.setFont(fontsize,1);
		//Para el uso del hospital
		pc.addCols(lng.equalsIgnoreCase("es")?"Para el HOSPITAL "+_comp.getNombre()+"\n\n":"For PUNTA PACIFICA HOSPITAL\n\n", 0, dHeader.size(), 30.2f);
        
        pc.setFont(fontsize, 0);
		pc.addCols(lng.equalsIgnoreCase("es")?"Nombre completo del Funcionario":"Complete Name of Staff Member", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Funcionario":"Signature of Staff Member", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula del Funcionario":"Personal I.D. of Staff Member", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"\n\n\nFiador Solidario: \n\n\nPor este medio me comprometo irrevocablemente ante el Hospital "+_comp.getNombre()+" a quien éste designe, a pagar solidariamente la obligación contraída mediante este documento en el caso que no sea pagada por el Paciente o el Responsable del Paciente.":"\n\nJoint Guarantor: \n\nBy this mean I irrevocably become committed before Punta Pacifica Hospital or any other designated by it, to jointly pay the obligation acquired through this document, in the case it is not paid by the Patient of Person in Charge.", 0, dHeader.size());

		pc.addCols(lng.equalsIgnoreCase("es")?"Nombre completo":"Complete Name ", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 2, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		//pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Fiador Solidario":"Signature of Joint Guarantor", 0, 2, 15.2f);
		pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Cédula o Pasaporte del Fiador":"Personal I.D. or Passport of Guarantor", 0, 2, 15.2f);
		pc.addBorderCols(" \n\n\n\n\n\n", 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 15.2f);
		pc.addCols(" ", 0, 1);

		pc.addCols(lng.equalsIgnoreCase("es")?"Fecha: ":"Date: ", 0, 2);
		pc.addBorderCols(cDateTime, 0, 1, 0.5f, 0.0f, 0.0f, 0.0f, 30.2f);
		pc.addCols(" ", 0, 1, 15.2f);

	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>
