<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
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

CommonDataObject cdoPacData  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String cDate = cDateTime.substring(0,11);
String company = (String) session.getAttribute("_companyId");

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String nombrePaciente = request.getParameter("nombre_paciente");
String cedula = request.getParameter("cedula");
String fechaDesde = request.getParameter("fdesde");
String fechaHasta = request.getParameter("fhasta");

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (nombrePaciente == null) nombrePaciente = "";
if (cedula == null) cedula = "";
if (fechaDesde == null) fechaDesde = cDate;
if (fechaHasta == null) fechaHasta = cDate;

Hashtable iAislamientos = new Hashtable();
iAislamientos.put("0", "ORIENTACIÓN AL PACIENTE Y FAMILIAR");
iAislamientos.put("1", "PACIENTE CON AISLAMIENTO DE CONTACTO");
iAislamientos.put("2", "COORDINACIÓN CON LA ENFERMERA DE NOSOCOMIAL");
iAislamientos.put("3", "PACIENTE CON AISLAMIENTO DE GOTAS");
iAislamientos.put("4", "COLOCACIÓN DEL EQUIPO DE PROTECCIÓN");
iAislamientos.put("5", "PACIENTE CON AISLAMIENTO RESPIRATORIO (GOTITAS)");
iAislamientos.put("6", "OTROS");
 
StringBuffer sb = new StringBuffer();

sb.append("select p.pac_id, a.secuencia as admision, p.nombre_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, p.id_paciente as cedula, to_char(a.fecha_ingreso,'dd/mm/yyyy') fecha_ingreso, to_char(c.fecha_creacion, 'dd/mm/yyyy') fecha_aislamiento");

sb.append(", (select cc.descripcion||'            (CAMA: '||(select aa.cama from tbl_adm_atencion_cu aa where aa.pac_id = a.pac_id and aa.secuencia = a.secuencia )||')' from tbl_cds_centro_servicio cc where codigo = (select aa.cds from tbl_adm_atencion_cu aa where aa.pac_id = a.pac_id and aa.secuencia = a.secuencia ) )  centroserviciodesc");

sb.append(" from vw_adm_paciente p, tbl_adm_admision a, tbl_sal_cuestionarios c where p.pac_id = a.pac_id and a.pac_id = c.pac_id and a.secuencia = c.admision and c.tipo_cuestionario = 'C1' and trunc(c.fecha_creacion) between to_date('");
sb.append(fechaDesde);
sb.append("', 'dd/mm/yyyy') and to_date('");
sb.append(fechaHasta);
sb.append("', 'dd/mm/yyyy') ");

if (!nombrePaciente.trim().equals("")) {
    sb.append(" and p.nombre_paciente like '%");
    sb.append(nombrePaciente);
    sb.append("%'");
}

if (!cedula.trim().equals("")) {
    sb.append(" and p.id_paciente = '");
    sb.append(cedula);
    sb.append("'");
}

if (!pacId.trim().equals("")) {
    sb.append(" and c.pac_id = ");
    sb.append(pacId);
    
    if (!noAdmision.trim().equals("")) {
        sb.append(" and c.admision = ");
        sb.append(noAdmision);
    }
}

sb.append(" order by c.fecha_creacion");

al = SQLMgr.getDataList(sb.toString());

String fecha = cDateTime;
String year=fecha.substring(6, 10);
String mon=fecha.substring(3, 5);
String month = null;
String day=fecha.substring(0, 2);
String cTime = fecha.substring(11, 22);
String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

float width = 82 * 8.5f;//612
float height = 72 * 11f;//792
boolean isLandscape = false;
float leftRightMargin = 9.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = "PACIENTES AISLADOS";
String xtraSubtitle = "DESDE: "+fechaDesde+"   HASTA: "+fechaHasta;

boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 5;
float cHeight = 90.0f;

CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+company+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
}
if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
}

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

Vector dHeader = new Vector();
dHeader.addElement("15");
dHeader.addElement("45");
dHeader.addElement("10");
dHeader.addElement("15");
dHeader.addElement("15");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();

pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());

pc.setFont(9,1);

pc.addBorderCols("PID", 1,1);
pc.addBorderCols("NOMBRE", 0,1);
pc.addBorderCols("F.NAC.", 1,1);
pc.addBorderCols("F.INGRESO", 1,1);
pc.addBorderCols("F.AISLAMIENTO", 1,1);
pc.addCols("", 0, dHeader.size());

pc.setTableHeader(3);

for (int i = 0; i < al.size(); i++){
    CommonDataObject cdo = (CommonDataObject) al.get(i);
    
    String tipoAislamientos = "";
    Properties prop = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+cdo.getColValue("pac_id")+" and admision="+cdo.getColValue("admision"));
    if (prop == null) prop = new Properties();
    
    for (int a = 0; a < 8; a++) {
        if (prop.getProperty("aislamiento_det"+a) != null && !"".equals(prop.getProperty("aislamiento_det"+a)) ) tipoAislamientos += ( iAislamientos.get(prop.getProperty("aislamiento_det"+a)) + "\n");
    }
    
    if (prop.getProperty("observacion27") != null && !"".equals(prop.getProperty("observacion27"))) tipoAislamientos = tipoAislamientos+"\n"+prop.getProperty("observacion27");
    
    if (!tipoAislamientos.trim().equals("")){
        pc.setFont(9, 0);
        
        pc.addCols(cdo.getColValue("pac_id"," ")+"-"+cdo.getColValue("admision"," "),1,1);
        pc.addCols(cdo.getColValue("nombre_paciente"," "),0,1);
        pc.addCols(cdo.getColValue("fecha_nacimiento"," "),1,1);
        pc.addCols(cdo.getColValue("fecha_ingreso"," "),1,1);
        pc.addCols(cdo.getColValue("fecha_aislamiento"," "),1,1);
        
        pc.setFont(9, 1);
        
        pc.addBorderCols("Ubicación: "+cdo.getColValue("centroServicioDesc"," "), 0, dHeader.size(),Color.lightGray);
        
        pc.addBorderCols(tipoAislamientos, 0, dHeader.size());
        pc.addCols(" ", 0, dHeader.size());
    }
    
} // for i    


pc.addTable();
pc.close();
response.sendRedirect(redirectFile);
%>