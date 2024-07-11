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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String idConsent = ((request.getParameter("idConsent")==null || request.getParameter("idConsent").trim().equals(""))?"0":request.getParameter("idConsent"));
String compania = (String) session.getAttribute("_companyId");

//--------------Patient info ----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(tipo_id_paciente, 'P',pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula, (select decode ( extra_logo_status,null,' ','0',' ',decode(extra_logo_path,null, ' ', extra_logo_path)) from tbl_param_consentimientos where id = "+idConsent+") extra_logo from vw_adm_paciente Where pac_id="+pacId;

cdo = SQLMgr.getData(sql);

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
	float height = 72 * 11f;//792
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
	tblMain.addElement("100");

	//Title table
	Vector tblTitle = new Vector();
	tblTitle.addElement(".20");
	tblTitle.addElement(".40");
	tblTitle.addElement(".30");

	//agreement table
	Vector tblAgreement = new Vector();
	tblAgreement.addElement(".13");
	tblAgreement.addElement(".03");
	tblAgreement.addElement(".15");
	tblAgreement.addElement(".03");
	tblAgreement.addElement(".10");
	tblAgreement.addElement(".03");
	tblAgreement.addElement(".53");

	//Title
	pc.setNoColumnFixWidth(tblTitle);
	pc.createTable("tblTitle");
	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);
	pc.addCols("MINISTERIO DE SALUD\nPROGRAMA NACIONAL DE SANGRE\nCONSENTIMIENTO INFORMADO PARA\nRECIBIR TRANFUSIONES DE SANGRE\nY/O COMPONENTES DE LA SANGRE",1,1);
	//pc.addImageCols(fotosFolder+"/"+((cdo.getColValue("extra_logo") != null && !cdo.getColValue("extra_logo").trim().equals(""))?cdo.getColValue("extra_logo"):"blank.gif"),30.0f,1);
    pc.setVAlignment(1);
    pc.addBorderCols("Pegar Label Aquí",1,1);
	//---- end table title

	System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::: "+fotosFolder+"/"+cdo.getColValue("extra_logo") );

	//----------------------------agreement table
    pc.setNoColumnFixWidth(tblAgreement);
    pc.createTable("agreementTable");

    pc.setFont(11,0);
    pc.addCols("SI consiento",4,1);
    pc.addBorderCols(" ",4,1,0.1f,0.1f,0.1f,0.1f);
    pc.addCols(" NO consiento",4,1);
    pc.addBorderCols(" ",4,1,0.1f,0.1f,0.1f,0.1f);
    pc.addCols(" que se me transfunda el o los siguientes componentes de la sangre:",4,3);

    pc.addCols(" ",0,tblAgreement.size());

    pc.addBorderCols(" ",0,2,0.1f,0.0f,0.0f,0.0f);
    pc.addCols("Unidad(es) de",0,2);
    pc.addCols(" ",0,1);
    pc.addBorderCols("",0,1,0.0f,0.1f,0.1f,0.1f);
    pc.addCols("    Glóbulos Rojos Empacados (GRE)",0,1);

    pc.addBorderCols(" ",0,2,0.1f,0.0f,0.0f,0.0f);
    pc.addCols("Unidad(es) de",0,2);
    pc.addCols(" ",0,1);
    pc.addBorderCols("",0,1,0.0f,0.1f,0.1f,0.1f);
    pc.addCols("    Concentrado de Plaquetas (CP)",0,1);

    pc.addBorderCols(" ",0,2,0.1f,0.0f,0.0f,0.0f);
    pc.addCols("Unidad(es) de",0,2);
    pc.addCols(" ",0,1);
    pc.addBorderCols("",0,1,0.0f,0.1f,0.1f,0.1f);
    pc.addCols("    Aféresis de Plaquetas",0,1);

    pc.addBorderCols(" ",0,2,0.1f,0.0f,0.0f,0.0f);
    pc.addCols("Unidad(es) de",0,2);
    pc.addCols(" ",0,1);
    pc.addBorderCols("",0,1,0.0f,0.1f,0.1f,0.1f);
    pc.addCols("    Plasma Fresco Congelado (PFC)",0,1);

    pc.addBorderCols(" ",0,2,0.1f,0.0f,0.0f,0.0f);
    pc.addCols("Unidad(es) de",0,2);
    pc.addCols(" ",0,1);
    pc.addBorderCols("",0,1,0.0f,0.1f,0.1f,0.1f);
    pc.addCols("    Aféresis de Plasma",0,1);

    pc.addBorderCols(" ",0,2,0.1f,0.0f,0.0f,0.0f);
    pc.addCols("Unidad(es) de",0,2);
    pc.addCols(" ",0,1);
    pc.addBorderCols("",0,1,0.0f,0.1f,0.1f,0.1f);
    pc.addCols("    Crioprecipitado",0,1);

    pc.addBorderCols(" ",0,2,0.1f,0.0f,0.0f,0.0f);
    pc.addCols("Unidad(es) de",0,2);
    pc.addCols(" ",0,1);
    pc.addBorderCols("",0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addCols("    Aféresis de Células Madre",0,1);

    pc.setFont(12,1);
    pc.addCols(" \nFIRMAS",0,tblAgreement.size());

    pc.setFont(11,0);
    pc.addCols("Yo he leído este documento y su contenido se me ha explicado. Yo he comprendido el propósito de la transfusión de sangre y/o componentes de la sangre. Libremente otorgo mi consentimiento.",4,tblAgreement.size());

    //------------------ end table agreementle

    //table signature

    Vector tblSig = new Vector();
    tblSig.addElement(".06");
    tblSig.addElement(".1");
    tblSig.addElement(".19");
    tblSig.addElement(".03"); //space

    tblSig.addElement(".15");
    tblSig.addElement(".03"); //space

    tblSig.addElement(".26");
    tblSig.addElement(".03"); //space

    tblSig.addElement(".15");

    pc.setNoColumnFixWidth(tblSig);
	pc.createTable("tblSig");

	pc.addCols(" ",0,tblSig.size());

    pc.addCols(cdo.getColValue("nombrePaciente"),1,3);
    pc.addCols(" ",0,1); //space

    pc.addCols(cdo.getColValue("cedula"),1,1);
    pc.addCols(" ",0,1); //space

    pc.addCols(" ",0,2);
    pc.addCols(""+day+"/"+mon+"/"+year,1,1);


	pc.addBorderCols("Nombre del paciente",1,3,0.0f,0.2f,0.0f,0.0f);
	pc.addCols(" ",0,1); //space

	pc.addBorderCols("Cédula",1,1,0.0f,0.2f,0.0f,0.0f);
	pc.addCols(" ",0,1); //space

	pc.addBorderCols("Firma del paciente o\nsu representante\nlegal",1,1,0.0f,0.2f,0.0f,0.0f);
	pc.addCols(" ",0,1); //space

	pc.addBorderCols("Fecha",1,1,0.0f,0.2f,0.0f,0.0f);

	pc.addCols(" ",0,tblSig.size());
	pc.setFont(11,1);
	pc.addCols("Observaciones:",0,2);
	pc.addBorderCols(" ",0,7,0.2f,0.0f,0.0f,0.0f);

	pc.addBorderCols(" \n",0,tblSig.size(),0.2f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" \n",0,tblSig.size(),0.2f,0.0f,0.0f,0.0f);



	pc.addCols(" ",0,tblSig.size());
	pc.setFont(11,1);
	pc.addCols("Nota:",0,1);
	pc.setFont(11,0);

	pc.addCols("Es obligatorio que este consentimiento sea llenado por el paciente o su representante legal y el médico tratante; es válido solamente para el evento transfusional expresamente consentido en él. En caso de extra urgencia en los cuales la condición del paciente no le permita consentir y no se encuentre presente su representante legal, deberá anotarse la situación en la casilla de observaciones y ser firmada por el médico tratante y un testigo quienes asumen la responsabilidad ante la urgencia de la transfusión. Debe enviarse la copia de este consentimiento al banco de sangre en conjunto con la copia del formulario de cruce al finalizar la transfusión. Si el paciente es menor de edad, o incapaz de firmar o consentir, y los padres (representantes o guardián), no pueden ser localizados, favor llenar los siguiente:",4,8);

	    // b t r l
	pc.addCols(" ", 0,tblSig.size());
	pc.addBorderCols("1.- Nombre de uno o ambos padres (si son conocidos)\n ",0,tblSig.size(),0.2f,0.0f,0.0f,0.0f);
	pc.addBorderCols("2.- Nombre del representante legal (si existe)\n ",0,tblSig.size(),0.2f,0.0f,0.0f,0.0f);
	pc.addBorderCols("3.- Fecha en que se efectuará el procedimiento\n ",0,tblSig.size(),0.2f,0.0f,0.0f,0.0f);

    //----------------------------end table signature

	//Main Table
	pc.setNoColumnFixWidth(tblMain);
	pc.createTable();

	pc.setTableHeader(2);

	//displaying tblTitle
	//String tableName, int hAlign, int colSpan, float height
	pc.useTable("main");
	pc.addTableToCols("tblTitle",1,tblMain.size(),0.0f);

	pc.setFont(12,1);
	pc.addCols(" ", 0, tblMain.size());
	pc.addCols("INTRODUCION",0,tblMain.size());

	pc.setFont(11,0);
	pc.addCols("El personal médico, es el autorizado para explicar el siguiente consentimiento. El paciente tiene derecho a conocer toda la información sobre su propia salud, la cual será verídica, comprensible y adecuada a la necesidades y requerimientos del paciente, para ayudarle a tomar decisiones de una manera autónoma, considerando el nivel intelectual, emocional y cultural.",4,tblMain.size());

	pc.addCols(" \nUste será interrogado si aprueba o desaprueba la transfusión de productos de la sangre humana.Confirme si se le ha explicado el procedimiento de la transfusión, y si usted ha entendido cabalmente los beneficios y los riesgos potenciales involucrados en el uso de las transfusiones de sangre y de sus componentes. Si usted tiene dudas o preguntas no contestadas a satisfacción, NO FIRME ESTE CONSENTIMIENTO.",4,tblMain.size());

	pc.setFont(12,1);
	pc.addCols(" ", 0, tblMain.size());
	pc.addCols("¿QUE ES UN CONSENTIMIENTO INFORMADO?",0,tblMain.size());

	pc.setFont(11,0);
	pc.addCols("El consentimiento informado es un documento escrito producto del proceso verbal de diálogo en el seno de la relación médico paciente. Es un proceso interpersonal médico paciente en donde discuten personalmente entre ellos. El médico explica el proceso de la transfusión, el paciente confirma que ha comprendido claramente los beneficios y riesgos potenciales involucrados en el uso de la transfusión de sangre y sus componentes.", 4, tblMain.size());

	pc.addCols(" \nSugiere la necesidad de que el médico informa al paciente competente de los riesgos y beneficios de los procedimientos, diagnósticos y terapéuticos, que estime conveniente según cada paciente. De esta manera el paciente logra un consentimiento suficiente, que le permite hacer una evaluación razonable para poder tomar una decisión libremente.", 4, tblMain.size());

	pc.addCols(" \nEn Panamá, el fundamento legal es la Ley 68 del 20 de noviembre de 2003 \"Que regula los derechos y obligaciones de los pacientes en materia de información y decisión libre e informada\".", 4, tblMain.size());

	pc.setFont(12,1);
	pc.addCols(" \nEN QUE CONSISTE UNA TRANSFUSION SANGUINEA",0,tblMain.size());

	pc.setFont(11,0);
	pc.addCols("La transfusión consiste en la administración de sangre humana alguno de sus componentes como plasma o plaquetas, a los pacientes que lo precisen. Se administra a través de una vena del paciente. Constituye un acto del ejercicio de la medicina.", 4, tblMain.size());

	pc.setFont(12,1);
	pc.addCols(" \nDECLARACION DE CONSENTIMIENTO INFORMADO",0,tblMain.size());

	pc.setFont(11,0);
	pc.addCols("Manifiesto que se me ha orientado en cuanto a los riesgos que implica cada evento transfusional y se me ha explicado el por qué en este caso el beneficio de recibir la transfusión sobrepasa los riesgos inherentes a la misma. Además que he sido informado que la sangre es un producto biológico y que no existe absoluta garantía de que no se den eventos adversos; los cuales pueden ir desde efectos secundarios inmediatos, como reacciones alérgicas, fiebre, hasta complicaciones severas durante el acto transfusional. Además, que existe el riesgo de la transfusión de enfermedades infecciosas como Virus de Inmunodeficiencia Adquirida HIV (SIDA), Hepatitis B, Hepatitis C, Sífilis, Chagas y HTLV-1 a pesar de todos los procedimientos y pruebas a los cuales son sometidas todas y cada una de las unidades de sangre y de sus componentes por el Banco de Sangre. Se me ha explicado la existencia del periódo de ventana del  Virus Inmunodeficiencia Adquiridad HIV (SIDA), Hepatitis B, Hepatitis C, y HTLV-1; período durante el cual no posible la detección de estos agentes en las unidades de sangre y sus componentes, aún a través de las pruebas de laboratorio en que se emplean en la actualidad.", 4, tblMain.size());

	pc.addCols(" \nDeclaro que he leído y he comprendido completamente este CONSENTIMIENTO INFORMADO, que he recibido aclaración a mis dudas y me siento conforme por lo que ante la siguiente decisión:", 4, tblMain.size());

	pc.flushTableBody(true);

	pc.addNewPage();

	//displaying agreementTable
	pc.useTable("main");
	pc.addTableToCols("agreementTable",1,tblMain.size(),0.0f);

	//displaying table signature
	pc.useTable("main");
	pc.addTableToCols("tblSig",1,tblMain.size(),0.0f);


	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>