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
String noAdmision = request.getParameter("noAdmision");
String idConsent = ((request.getParameter("idConsent")==null || request.getParameter("idConsent").trim().equals(""))?"0":request.getParameter("idConsent"));
String compania = (String) session.getAttribute("_companyId");

//--------------Patient info ----------------------------------------//
sql = " select p.nombre_paciente nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, (select decode ( extra_logo_status,null,' ','0',' ',decode(extra_logo_path,null, ' ', extra_logo_path)) from tbl_param_consentimientos where id = "+idConsent+") extra_logo, nvl(r.nombre,p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada))) as nombre_responsable, nvl(r.identificacion,decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento)) as responsable_id from vw_adm_paciente p, tbl_adm_responsable r Where p.pac_id = r.pac_id(+) and p.pac_id="+pacId+" and r.admision(+)="+noAdmision+" and r.estado(+) ='A' ";

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
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

    //Main table
	Vector tblMain = new Vector();
	tblMain.addElement("100");

	//Title table
	Vector tblTitle = new Vector();
	tblTitle.addElement(".20");
	tblTitle.addElement(".60");
	tblTitle.addElement(".20");

	//signature table
	Vector sig = new Vector();
	sig.addElement(".10");
	sig.addElement(".35");
	sig.addElement(".20"); // space
	sig.addElement(".15");
	sig.addElement(".20");

	pc.setFont(9,1);
	//Title
	pc.setNoColumnFixWidth(tblTitle);
	pc.createTable("tblTitle");
	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);
	pc.addCols(cDateTime,1,1);
	pc.addCols("NO.EXPEDIENTE: "+pacId+"-"+noAdmision,1,1);
	
	
	pc.setFont(9,0);
	//Signature
	pc.setNoColumnFixWidth(sig);
	pc.createTable("tblSig");
	
	pc.addCols("",0,sig.size(),100.0f);
	pc.addCols("FIRMA:",0,1);
	pc.addBorderCols(cdo.getColValue("nombrePaciente"),0,1,0.0f,0.5f,0.0f,0.0f);
	pc.addCols("",0,1);
	pc.addCols("CEDULA:",2,1);
	pc.addCols(cdo.getColValue("cedula"),0,1);
	
	pc.addCols(" ",0,sig.size(),14.0f);
	
	pc.addCols("-Responsable-\n\n\n\n",0,sig.size());
	pc.addCols("FIRMA:",0,1);
	pc.addBorderCols(cdo.getColValue("nombre_responsable"),0,1,0.0f,0.5f,0.0f,0.0f);
	pc.addCols("",0,1);
	pc.addCols("CEDULA:",2,1);
	pc.addCols(cdo.getColValue("responsable_id"),0,1);
	
	
	pc.addCols("",0,sig.size(),100.0f);
	
	pc.addBorderCols("FIRMA DE TESTIGO",1,2,0.0f,0.5f,0.0f,0.0f);
	pc.addCols("",0,1);
	pc.addBorderCols("CEDULA NO.",1,2,0.0f,0.5f,0.0f,0.0f);
	
	

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
	pc.addCols("AUTORIZACION PARA TRATAMIENTO EN CUARTO DE URGENCIA O CIRUGIA AMBULATORIA",0,tblMain.size());

	pc.setFont(10,0);
	pc.addCols(" ", 0, tblMain.size());
	pc.addCols("POR ESTE MEDIO AUTORIZO AL MEDICO DEL CUARTO DE URGENCIA Y A LOS OTROS MEDICOS QUE PUDIERAN SER CONSULTADOS, PARA QUE INTERVENGAN EN EL DIAGNOSTICO Y/O TRATAMIENTO DE:",4,tblMain.size());
	pc.addCols(" ", 0, tblMain.size());
	
	pc.addCols(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ", 0, tblMain.size(),14.0f);
	pc.addCols(" ", 0, tblMain.size());

	pc.addCols("O CUALQUIER OTRA CONDIION QUE SE PUDIERA PRESENTAR EN EL TRANSCURSO DE MI ATENCION E N EL HOSPITAL.\n\n\n\t\t\t\t\t\t\t\tEN CASO DE QUE SE PRESENTEN CONDICIONES QUE PUEDAN REQUERIR PROCEDIEMIENTOS ADICIONALES. LOS AUTORIZO A REALIZAR LOS QUE CONSIDEREN RECOMENDABLES. DE IGUAL MANERA DOY MI CONSENTIMIENTO QUE SE ME ADMINISTRE  ANESTESIA, EN CASO DE QUE FUERA NECESARIO. AUTORIZO EXPRESAMENTE AL (LOS) MEDICOS (S) QUE ME ATENDIO Y/O AL HOSPITAL '"+_comp.getNombre()+"' A SUMINISTRAR A SOLICITUD DE MI COMPAÑÍA ASEGURADORA. CUALQUIER INFORMACION SOBRE MI ESTADO DE SALUD Y/O TRATAMIENTO RECIBIDO.\n\n\n\t\t\t\t\t\t\t\tEN CASO DE NO TENER SEGURO DE  HOSPITALIZACION, ME COMPROMETO A CANCELAR EL SALDO TOTAL DE MI CUENTA AL TERMINAR LA ATENCION EN EL HOSPITAL.",4,tblMain.size());
	
	pc.addCols(" ", 0, tblMain.size());
	pc.addCols(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ", 1, tblMain.size());
	
	pc.addCols("POR ESTE MEDIO AUTORIZAMOS EXPRESAMENTE A EL HOSPITAL "+_comp.getNombre()+" A CONSULTAR, RECOPILAR Y/O TRANSMITIR NUESTRO HISTORIAL DE CREDITO EN CUALQUIER AGENCIA DE INFORMACION DE  DATOS Y DE REFERENCIAS CREDITICIAS.",4,tblMain.size());

	pc.useTable("main");
	pc.addTableToCols("tblSig",1,tblMain.size(),0.0f);


	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>