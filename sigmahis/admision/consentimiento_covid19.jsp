<%//@ page errorPage="../error.jsp"%>
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
String lng = request.getParameter("lng");
if (lng == null) lng = "es";

StringBuffer sbSql = new StringBuffer();
sbSql.append("select to_char(fecha_ingreso,'dd/mm/yyyy') as fingreso, '('||to_char(fecha_ingreso,'dd/mm/yyyy')||' - '||to_char(fecha_ingreso + 13,'dd/mm/yyyy')||')' as cuarentena");
sbSql.append(", (select p.nombre_paciente from vw_adm_paciente p where p.pac_id = z.pac_id) as nombre_paciente");
sbSql.append(", (select p.id_paciente_f3 from vw_adm_paciente p where p.pac_id = z.pac_id) as id_paciente");
sbSql.append(", nvl((select p.residencia_direccion from vw_adm_paciente p where p.pac_id = z.pac_id),'* NO DEFINIDO *') as direccion");
sbSql.append(", nvl((select (select nacionalidad from tbl_sec_pais where codigo = p.nacionalidad) from vw_adm_paciente p where p.pac_id = z.pac_id),'* NO DEFINIDO *') as nacion");
sbSql.append(" from tbl_adm_admision z where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);
CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
if (cdo == null) cdo = new CommonDataObject();

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year = fecha.substring(6,10);
String mon = fecha.substring(3,5);
String month = null;
String day = fecha.substring(0,2);
String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
String folderName = servletPath.substring(1,servletPath.indexOf("/",1));

if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

float width = 72 * 8.5f;//612
float height = 72 * 11f;//792
boolean isLandscape = false;
float leftRightMargin = 72.0f; //9.0f
float topMargin = 72f;
float bottomMargin = 72f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = _comp.getNombre();
String subTitle = "CONSENTIMIENTO INFORMADO ANTE EL RIESGO DEL BROTE DEL NUEVO CORONAVIRUS (COVID-19)";
String xtraSubtitle = "";

boolean displayPageNo = false;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontsize = 11;
float cHeight = fontsize + 4f;

PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printConsentUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

Vector dHeader = new Vector();
dHeader.addElement(".05");
dHeader.addElement(".025");
dHeader.addElement(".075");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".05");
dHeader.addElement(".05");
dHeader.addElement(".10");
dHeader.addElement(".10");
dHeader.addElement(".075");
dHeader.addElement(".025");
dHeader.addElement(".05");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
	boolean ok = (pc.getTableWidth() == 468f);//margins 72
	if (!ok) {//to keep settings with same margins, except bottom (only works for one page file)
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable("content",true,0,0f,468f);
		pc.addCols("",1,dHeader.size(),52f);
	}
	pc.setFont(fontsize + 3,1);
	pc.addCols(title,1,dHeader.size());

	pc.addCols(" ",1,dHeader.size(),cHeight * 2);

	pc.setFont(fontsize,1);
	pc.addCols(subTitle,1,dHeader.size());

	pc.setFont(fontsize,0);
	//for (int i=0; i<dHeader.size(); i++) pc.addBorderCols(" ",0,1);

	pc.addCols(" ",0,dHeader.size(),cHeight * 2);
	pc.addCols("YO, ",0,1);
	pc.addBorderCols(cdo.getColValue("nombre_paciente"),1,7,0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" portador de la cédula o pasaporte",2,6);

	pc.addCols("N° ",0,1);
	pc.addBorderCols(cdo.getColValue("id_paciente"),1,5,0.5f,0.0f,0.0f,0.0f);
	pc.addCols(" de Nacionalidad ",0,3);
	pc.addBorderCols(cdo.getColValue("nacion"),1,5,0.5f,0.0f,0.0f,0.0f);

	pc.addCols("con domicilio ",0,3);
	pc.addBorderCols(cdo.getColValue("direccion"),0,11,0.5f,0.0f,0.0f,0.0f);


	pc.addCols(" ",0,dHeader.size());
	pc.addCols("Después de haber recibido intrucciones verbales o escritas, claras y comprensibles sobre los riesgos del Coronavirus (CoVID19), manifiesto libremente mi compromiso en acatar todas las intrucciones dadas por el personal del Ministerio de Salud que comprenden:",4,dHeader.size());

	pc.addCols(" ",4,dHeader.size());
	pc.addCols("1. ",2,1);
	pc.addCols("Permanecer en mi domicilio durante la cuarentena domiciliaria siguiendo las recomendaciones dadas por el Ministerio de Salud. "+cdo.getColValue("cuarentena"),4,dHeader.size() - 1);

	pc.addCols("2. ",2,1);
	pc.addCols("Reportar inmediatamente al 169 en caso de presentar dificultad respiratoria u otros síntomas de alarma.",4,dHeader.size() - 1);

	pc.addCols("3. ",2,1);
	pc.addCols("Seguir las recomendaciones dadas por el Ministerio de Salud de distanciamiento social, uso de mascarillas y lavado contínuo de manos. ",4,dHeader.size() - 1);

	pc.addCols(" ",0,dHeader.size(),cHeight * 2);
	pc.addCols("Comprendo que el incumplimiento de ese compromiso conlleva a sanciones administrativas y penales.",4,dHeader.size());

	pc.setFont(fontsize,1);
	pc.addCols(" ",0,dHeader.size(),cHeight * 3);
	pc.addCols("Atentamente",0,dHeader.size());

	pc.setFont(fontsize,0);
	pc.addCols(" ",0,dHeader.size(),cHeight * 3);
	pc.addBorderCols("Firma del paciente",0,4,0.0f,0.5f,0.0f,0.0f);
	pc.addCols(" ",0,dHeader.size() - 4);

	pc.addCols(" ",0,dHeader.size(),cHeight * 3);
	pc.addBorderCols("Firma del Médico",0,4,0.0f,0.5f,0.0f,0.0f);
	pc.addCols(" ",0,dHeader.size() - 4);

	if (!ok) {
		pc.useTable("main");
		pc.addCols(" ",0,2);
		pc.addTableToCols("content",1,dHeader.size() - 4);
		pc.addCols(" ",0,2);
	}

pc.addTable();
if(isUnifiedExp){pc.close();
response.sendRedirect(redirectFile);}
%>