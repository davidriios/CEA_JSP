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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
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
	tblFP.addElement("10");
	tblFP.addElement("70");
	
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

	pc.addCols(" ", 0, tblMain.size());

	pc.setFont(10,0);
	pc.addCols("\n1.",0,1);
	pc.addCols("Reconocemos que el hecho de ser admitido en el \""+nombreCompania+"\" en adelante \""+nombreCompaniaCorto+"\", para recibir tratamiento, procedimientos médicos o quirúrgicos generará una cuenta la cual desde este momento nos comprometeremos a cubrir en su totalidad.", 4, 1);

	pc.addCols("\n2.",0,1);
	pc.addCols("\nNo comprometeremos a que en caso de utilizar un seguro mediante poliza de salud o accidentes para ser atendido en un centro hospitalario, cualquier suma de este seguro no cubra, así sea la totalidad o la cantidad insoluta de la cuenta, será pagada por nosotros una vez nos sea notificada por parte de \""+nombreCompaniaCorto+"\" o por la compañía. de seguros.", 4, 1);

	pc.addCols("\n3.",0,1);
	pc.addCols("\nNos comprometeremos a hacer los abonos de la cuenta que nos solicite \""+nombreCompaniaCorto+"\", durante la estadía de \"EL PACIENTE\" en sus instalaciones.", 4, 1);

	pc.addCols("\n4.",0,1);
	pc.addCols("\nRecocemos, que al expedirse el estado de cuenta puede que el mismo no incluya la totalidad de los cargos y/o honorarios médicos generados a la fecha, ya sea porque los mismos no han sido procesados o presentados por los médicos o proveedores.", 4, 1);

	pc.addCols("\n5.",0,1);
	pc.addCols("\nEn caso de no estar en capacidad para cubrir los gastos ocasionados durante la hospitalización autorizamos a \""+nombreCompaniaCorto+"\" a trasladar al PACIENTE a una institución pública de salud.", 4, 1);

	pc.addCols("\n6.",0,1);
	pc.addCols("\nDe requerir traslado a otra institución por cualquier motivo cancelaremos el saldo de la cuenta antes del traslado.", 4, 1);

	pc.addCols("\n7.",0,1);
	pc.addCols("\nPor este medio autorizamos expresamente y de manera irrevocable al \""+nombreCompaniaCorto+"\", sus representantes, funcionarios, agentes a solicitar información e investigar nuestro historial de crédito en cualquier agencia de información de datos y de referencias crediticias, en cualquier momento y cuantas veces lo requiera sin solicitarnos autorización cada vez que los haga.", 4, 1);

	pc.addCols("\n8.",0,1);
	pc.addCols("\nAutorizamos a \""+nombreCompaniaCorto+"\" a proporcionar nuestro historial de crédito a cualquier agente económico según su criterio.", 4, 1);

	pc.addCols("\n9.",0,1);
	pc.addCols("\nReconocemos que \""+nombreCompaniaCorto+"\", su representantes, funcionarios no serán responsables por errores en los datos existentes en nuestro historial de crédito ni por posibles daños y perjuicios que lo contenido en el mismo pueda ocasionar.", 4, 1);

	pc.addCols("Aceptamos todos los términos y condiciones que constan en el presente documento:", 4, tblMain.size());

	pc.addCols("\n",0,1);
	pc.addCols("\nNombre Completo del Paciente: "+nombrePaciente , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nFirma del Paciente:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nCédula del Paciente: "+cedulaPaciente , 4, 1);


	pc.addCols("\nFirma de la Persona Responsable (entiéndase como persona responsable los esposos, padre, madre, tutor)" , 4, tblMain.size());

	pc.addCols("\n",0,1);
	pc.addCols("\nNombre Completo de la Persona Responsable:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nCédula de la Persona Responsable:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.flushTableBody(true);
	pc.addNewPage();


	pc.addCols("\nFirma a ruego (se hará únicamente cuando la persona responsable no puede firma y le pida a alguien que lo haga por ella):" , 4, tblMain.size());

	pc.addCols("",0,1);
	pc.addCols("\nNombre Completo del Firmante:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nFirma:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nCédula:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols(" ",0,tblMain.size());

	pc.useTable("main");
	pc.addTableToCols("tblFP",1,tblMain.size(),0.0f);

	pc.addCols("\nEn caso de paciente inconsciente o incapaz de tomar decisiones al momento de su admisión, dos testigos firmarán el presente documento\n(Si viene acompañado, uno de los testigos debe ser el acompañante).",4,tblMain.size());


	pc.addCols("",0,1);
	pc.addCols("\nFirma  del Testigo 1:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nCédula del Testigo 1:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols(" ",0,tblMain.size());

	pc.addCols("",0,1);
	pc.addCols("\nFirma  del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("",0,1);
	pc.addCols("\nCédula del Testigo 2:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);



	pc.setFont(9,0);
	pc.addCols("\n\n",0,1);
	pc.addCols("\nPor "+nombreCompania+"_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nNombre Completo del oficial:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("\n",0,1);
	pc.addCols("\nFirma  del oficial:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nCédula del oficial:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols(" \n\n",0,tblMain.size());
	pc.addCols("  ",0,1);
	pc.addCols("\nFiador Solidario:\n\nPor este medio me compromedo ante el "+nombreCompania+",a pagar solidariamente la obligación contraída mediante este documento en el caso que no sea oagada por el PACIENTE o el Responsable del Paciente:" , 4, 1);

	pc.addCols("\n",0,1);
	pc.addCols("\nNombre Completo:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols("\n",0,1);
	pc.addCols("\nFirma  del Fiador Solidario:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);
	pc.addCols("\n",0,1);
	pc.addCols("\nCédula del Fiador Solidario:_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _" , 4, 1);

	pc.addCols(" \n\n",0,tblMain.size());
	pc.addCols(" ",0,1);
	pc.addCols("Fecha: Panamá,___________de__________________________________de 20______",0, tblMain.size());

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>
