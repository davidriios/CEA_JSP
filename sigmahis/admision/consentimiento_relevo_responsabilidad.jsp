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

cdo = SQLMgr.getData("SELECT  COALESCE( DECODE(P.pasaporte,NULL,'',P.pasaporte||'-'||P.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||'-'||P.D_CEDULA)) cedula, c.habitacion, to_char(p.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, primer_nombre, decode (segundo_nombre, null, '', ' ' || segundo_nombre)|| decode (primer_apellido, null, '', ' ' || primer_apellido)|| decode (segundo_apellido, null, '', ' ' || segundo_apellido)|| decode (sexo, 'F', decode (apellido_de_casada,  null, '', ' DE ' || apellido_de_casada)) apellidos, sexo FROM vw_ADM_PACIENTE P, TBL_ADM_CAMA_ADMISION c WHERE P.PAC_ID = "+pacId+" AND C.ADMISION(+) = "+noAdmision+"  AND C.PAC_ID(+) = P.PAC_ID and c.fecha_final is null");

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
    
	dHeader.addElement(".15");
	dHeader.addElement(".15");
	dHeader.addElement(".14");
	dHeader.addElement(".14");
    dHeader.addElement(".14");
	dHeader.addElement(".14");
	dHeader.addElement(".14");
	
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
    
    int fontsize = 10;
	
	pc.setFont(fontsize,1);
	pc.addCols(consentTitle,1,dHeader.size());

	pc.addCols(" ",1,dHeader.size());
    
    pc.setFont(fontsize,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"1) DATOS DEL PACIENTE":"1) PATIENT’S INFORMATION", 0,dHeader.size());
    
    pc.setFont(fontsize,0);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"NOMBRE\n"+cdo.getColValue("primer_nombre"," "):"NAME\n"+cdo.getColValue("primer_nombre"," "), 0,3);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"APELLIDOS\n"+cdo.getColValue("apellidos"," "):"LAST NAMES\n"+cdo.getColValue("apellidos"," "), 0,4);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"FECHA DE NACIMIENTO\n"+cdo.getColValue("fecha_nacimiento"," "):"DATE OF BIRTH\n"+cdo.getColValue("fecha_nacimiento"," "), 0,2);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"CÉDULA/PASAPORTE\n"+cdo.getColValue("cedula"," "):"PERSONAL I.D./PASSPORT\n"+cdo.getColValue("cedula"," "), 0,3);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"SEXO\n"+cdo.getColValue("sexo"," "):"GENDER\n"+cdo.getColValue("sexo"," "), 0,2);

    pc.addCols(" ", 0,dHeader.size());
    
    pc.setFont(fontsize,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"2) DATOS DEL SOLICITANTE (Completar cuando el solicitante no sea el propio paciente)":"2) INFORMATION OF PERSON MAKING THE REQUEST (Complete when the person making the request is not the patient)", 0,dHeader.size());
    pc.setFont(fontsize,0);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"NOMBRE Y APELLIDOS\n\n\n":"NAME AND LAST NAMES\n\n\n", 0,5);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"CÉDULA/PASAPORTE\n\n\n":"PERSONAL I.D./PASSPORT\n\n\n", 0,2);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"VINCULACIÓN ENTRE SOLICITANTE Y PACIENTE\n[ ] ESPOSO(A)                    [ ] HIJO                      [ ] REPRESENTANTE LEGAL":"LINK BETWEEN PERSON MAKING THE REQUEST AND PATIENT\n[ ] HUSBAND/WIFE                   [ ] SON/DAUGHTER                      [ ] LEGAL REPRESENTATIVE", 0,dHeader.size());
    
    pc.addCols(" ", 0,dHeader.size());
    
    pc.setFont(fontsize,1);
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"3) RELEVO DE RESPONSABILIDAD":"3) RELEASE OF LIABILITY", 0,dHeader.size());
    pc.setFont(fontsize,0);
    
    pc.addBorderCols(lng.equalsIgnoreCase("es")?"Este acuerdo libera de toda responsabilidad civil, financiera y de cualquier tipo al "+_comp.getNombre()+" y así cómo al Dr. __________________________________________ y personal del hospital por  las lesiones que pueden darse al ___________________________________________________________________  debido a que la condición clínica de gravedad e inestabilidad de la paciente y su propio diagnóstico conlleva  a que sea la única alternativa de tratamiento posible.\n\nReconozco que se me ha informado con claridad de los riesgos que implica ___________________________________________________________________________, por lo tanto asumo las consecuencias de las mismas.  También acepto que el personal médico y el personal del hospital han me han explicado todo lo concerniente a esta situación y que esta decisión la  he tomado voluntariamente y estoy de acuerdo con la descripción de los hechos.\n\nSituación (describa brevemente)\n\n____________________________________________________________________________":"This agreement releases "+_comp.getNombre()+" of any civil, financial or other type of liability as well as Dr. __________________________________________ and hospital staff for the injuries that may happen during ___________________________________________________________________ given the serious and unstable condition of the patient and his/her own diagnosis leads to this being the only alternative to any possible treatment.\n\nI acknowledge I have been clearly informed of the risks involved; ___________________________________________________________________________, therefore, I assume their consequences. I also accept the physician and hospital staff have explained to me everything related to this situation and I have taken this decision voluntarily, in agreement with the description of the facts.\n\nSituation (describe briefly)_____________________________________________________________________________", 0,dHeader.size());
  
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    pc.addCols(" ", 0,dHeader.size());
    
    pc.addCols(lng.equalsIgnoreCase("es")?"Firma del Paciente _________________________________CIP_________________ Fecha: __________ o \n\nFirma del Familiar responsable___________________CIP ___________      Fecha: __________\n\nFirma Médico _______________________________CIP: _________________ Fecha: ________ \n\nFirma del Testigo ____________________________ CIP: ________________Fecha: __________ \n\n(Firmará en ausencia de la firma del médico)":"Signature of the Patient:___________________________I.D._________________ Date: __________ OR \n\nSignature of Family Member in charge_________________________I.D.___________Date: __________\n\nSignature of Physician__________________I.D.: _________________Date: ________ \n\nSignature of Witness________________________________ I.D.________________Date:__________\n\n(Will sign in absence of physician)", 0,dHeader.size());
    
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}
%>