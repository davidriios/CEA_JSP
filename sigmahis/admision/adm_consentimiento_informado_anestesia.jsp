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
String noAdmision = request.getParameter("noAdmision");

String compania = (String) session.getAttribute("_companyId");

//--------------Query para obtener datos del Paciente ----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(sysdate,'Day dd \"de\" Month \"de\" yyyy','nls_date_language=spanish') as lat_date ,(select primer_nombre ||' '||primer_apellido from tbl_adm_medico where codigo = a.medico) as nombremedico, pa.nacionalidad, p.residencia_direccion, to_char(sysdate,'month','nls_date_language=spanish') as mes, p.edad from vw_adm_paciente p, tbl_adm_admision a, tbl_sec_pais pa Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and pa.codigo(+) = p.nacionalidad and a.secuencia = "+noAdmision;

cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
String title = " CONSENTIMIENTO INFORMADO";
String subTitle = "ANESTESIA";
String xtraSubtitle = "";

boolean displayPageNo = false;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 12;
float cHeight = 90.0f;
	
PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printConsentUnico");
if(pc == null){ 
  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
  isUnifiedExp = true;
}

Vector tblImg = new Vector();
tblImg.addElement("1");
pc.setNoColumnFixWidth(tblImg);
pc.createTable();

pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
pc.addTable();

Vector dHeader = new Vector();
dHeader.addElement("0.08");
dHeader.addElement("0.23");
dHeader.addElement("0.12");
dHeader.addElement("0.10");
dHeader.addElement("0.07");
dHeader.addElement("0.05");
dHeader.addElement("0.10");
dHeader.addElement("0.05");
dHeader.addElement("0.10");
dHeader.addElement("0.10");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();

pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
pc.setTableHeader(1);

pc.setFont(10, 1);
pc.addCols(title, 1, dHeader.size());
pc.addCols(subTitle, 1, dHeader.size());
pc.addCols(xtraSubtitle, 1, dHeader.size());
pc.addCols("", 1, dHeader.size());

pc.setVAlignment(1);

pc.setFont(9, 0);
pc.addCols("Panam�, Rep�blica de Panam� a los d�as "+day+" del mes de "+cdo.getColValue("mes"," ")+" del "+year+". Quien suscribe, "+cdo.getColValue("nombrePaciente"," ")+", portador(a) de la cedula de identidad personal numero "+cdo.getColValue("cedula"," ")+" de "+cdo.getColValue("edad"," ")+" a�os de edad, reconozco que me ha sido INFORMADO por el anestesi�logo _______________________________________ de forma amplia, precisa, clara y sencilla de los riesgos y beneficios de someterme al procedimiento anest�sico.",3, dHeader.size());
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("Estoy consciente de que en cualquier momento pueden presentarse complicaciones y cambios hemodin�micos inherentes a los anest�sicos y medicamentos utilizados, como respuesta de mi organismo ante los mismos, y de los cuales, desconoc�a previamente.",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("Se me inform� de la posibilidad de presentar respuestas al�rgicas, reacciones adversas � efectos indeseables a los anest�sicos, medicamentos y soluciones utilizados durante mi intervenci�n quir�rgica, mismos que a su vez pueden acarrear complicaciones en mi organismo, requerir tratamientos m�dicos complementarios.",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("Acepto haber comprendido las explicaciones por parte del m�dico, han sido aclaradas todas mis dudas y estoy satisfecho (a) con la informaci�n recibida.",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("Comprendiendo el alcance de los riesgos y beneficios, firmo este consentimiento por mi libre voluntad en presencia de mis testigos. y/o familiares sin haber estado sujeto (a) a ning�n tipo de presi�n o coacci�n para hacerlo, por lo anterior es mi decisi�n AUTORIZAR al especialista de someterme al procedimiento anest�sico.",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("Declaro: que he le�do / comprendido la informaci�n precedente, que he sido informado por el m�dico de los riegos del procedimiento, que se me ha explicado las posibles alternativas y que s� que, en cualquier momento, puedo revocar mi consentimiento sin dar explicaci�n alguna.",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("Estoy satisfecho con la informaci�n recibida, he podido formular toda clase de preguntas que he cre�do conveniente y me han aclarado todas las dudas planteadas.",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("En caso de pacientes inconsciente o incapaz de tomar decisiones al momento de su admisi�n, un representante firmar� el presente documento.",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("",1, dHeader.size());
pc.addCols("Firma del paciente o quien Representa:___________________________________________________",3, dHeader.size());
pc.addCols("",1, dHeader.size());

pc.addCols("",1, dHeader.size());
pc.addCols("C�dula:", 0, 1);
pc.addBorderCols(" ",0, 1,0.5f,0.0f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size()-2, 10.2f);
pc.addCols("",1, dHeader.size());

pc.addCols("Tel�fono:", 0, 1);
pc.addBorderCols(" ",0, 1,0.5f,0.0f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size()-2, 10.2f);
pc.addCols("",1, dHeader.size());

pc.addCols("Direcci�n:", 0, 1);
pc.addBorderCols(" ",0, 1,0.5f,0.0f,0.0f,0.0f);
pc.addCols("", 1, dHeader.size()-2, 10.2f);
pc.addCols("",1, dHeader.size());

pc.addCols("", 1, dHeader.size(), 10.2f);
pc.addCols("", 1, dHeader.size(), 10.2f);

pc.addCols("Anestesi�logo:_____________________________", 0, 3);
pc.addCols("", 1, dHeader.size()-3, 10.2f);
pc.addCols("",1, dHeader.size());

pc.addCols("Firma y Sello:_____________________________", 0, 3);
pc.addCols("", 1, dHeader.size()-3, 10.2f);

pc.addTable();
if(isUnifiedExp){
  pc.close();
  response.sendRedirect(redirectFile);
}  
%>