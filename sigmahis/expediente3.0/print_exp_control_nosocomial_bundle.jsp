<%//@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
<%@ include file="../common/pdf_header.jsp"%>
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
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String tubo = request.getParameter("tubo");
String medida = request.getParameter("medida");
String id = request.getParameter("id");
String codigoBundle = request.getParameter("codigo_bundle");

CommonDataObject cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (id == null) id = "0";
if (codigoBundle == null) codigoBundle = "0";

ArrayList alP = SQLMgr.getDataList(" select p.codigo, p.pregunta, p.activar_obs, p.totalizador, d.puntuacion, d.observacion, p.supervisor, decode(b.tipo,'M',b.usuario_creacion) usuario_creacion_m, b.codigo as codigo_bunble from tbl_sal_tubos_medidas tm, tbl_sal_tubo_medida_preguntas p, tbl_sal_noso_bundle_det d, tbl_sal_noso_bundle b where p.codigo_tub_med = tm.codigo and tm.codigo_tubo = "+tubo+" and tm.codigo_medida = "+medida+" and p.estado = 'A' and p.codigo = d.cod_preguntas(+) and d.cod_bunble = b.codigo(+) and b.codigo_control(+) = "+id+" and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and d.cod_bunble(+) = "+codigoBundle+" and d.pac_id = b.pac_id(+) and d.admision = b.admision(+) and b.codigo_control(+) = d.codigo_control order by p.orden");

StringBuffer sbSql = new StringBuffer();

sbSql.append("select tm.codigo codigo_tubo_medida, m.codigo as tubo, m.nombre desc_medida, m.codigo as medida, t.nombre desc_tubo, tm.tipo, a.fecha_insercion, a.fecha_retiro, a.usuario_creacion, a.fecha_creacion, a.fecha_modificacion, a.usuario_modificacion, a.insertador, a.area, a.total, a.codigo as cod_bunble, nvl((select e.primer_nombre||' '||e.primer_apellido from tbl_pla_empleado e where to_char(e.emp_id) = a.insertador),'josue') insertador_desc, nvl(a.area,(select codigo from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);
sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
sbSql.append(compania);
sbSql.append(" ))) area, nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.area ),(select descripcion from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);
sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
sbSql.append(compania);
sbSql.append(" ))) area_desc from tbl_sal_tubos_medidas tm, tbl_sal_tubos t, tbl_sal_medidas m,(select a.codigo, a.pac_id, a.admision, b.codigo_tubo_medida, b.tipo, to_char(a.fecha_insercion, 'dd/mm/yyyy hh12:mi:ss am') fecha_insercion, to_char(a.fecha_retiro, 'dd/mm/yyyy hh12:mi:ss am') fecha_retiro, b.usuario_creacion, b.usuario_modificacion, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, a.insertador, a.area as a_area, b.total, b.codigo as cod_bunble, nvl((select e.primer_nombre||' '||e.primer_apellido from tbl_pla_empleado e where to_char(e.emp_id) = a.insertador),'"+userName+"') insertador_desc, nvl(a.area,(select codigo from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);
sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
sbSql.append(compania);
sbSql.append(" ))) area, nvl((select descripcion from tbl_cds_centro_servicio where codigo = a.area ),(select descripcion from tbl_cds_centro_servicio where codigo = (select unidad_admin from tbl_sal_habitacion where codigo = ( select habitacion from tbl_adm_cama_admision where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);
sbSql.append(" and fecha_final is null and rownum = 1 ) and compania = ");
sbSql.append(compania);
sbSql.append(" ))) area_desc from tbl_sal_noso_bundle_ctrl a, tbl_sal_noso_bundle b where a.pac_id = b.pac_id and a.admision = b.admision and a.codigo = b.codigo_control) a where tm.codigo_tubo = ");
sbSql.append(tubo);
sbSql.append(" and tm.codigo_medida = ");
sbSql.append(medida);
sbSql.append(" and tm.codigo_tubo = t.codigo and tm.codigo_medida = m.codigo and tm.codigo = a.codigo_tubo_medida(+) and a.pac_id(+) = ");
sbSql.append(pacId);
sbSql.append(" and a.admision(+) = ");
sbSql.append(noAdmision);
sbSql.append(" and a.codigo(+) = ");
sbSql.append(id);

CommonDataObject cdoI = SQLMgr.getData(sbSql.toString());

if (cdoI == null) cdoI = new CommonDataObject();

String fecha = cDateTime;
String year=fecha.substring(6, 10);
String mon=fecha.substring(3, 5);
String month = null;
String day=fecha.substring(0, 2);
String cTime = fecha.substring(11, 22);
String cDate = fecha.substring(0,11);
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

float width = 72 * 8.5f;//612 
float height = 72 * 14f;//792
boolean isLandscape = false;
float leftRightMargin = 35.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = desc;
String xtraSubtitle = "";

boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 5;
float cHeight = 90.0f;

CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
}
if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
}

PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");

if(pc == null){
    pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    isUnifiedExp = true;
}

Vector tblMain = new Vector();
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());

pc.setFont(11,1);
pc.addCols("Creado el: "+cdoI.getColValue("fecha_creacion"," "), 0,5);
pc.addCols("Creado por: "+cdoI.getColValue("usuario_creacion"," "), 0,5);
pc.addCols("Modificado el: "+cdoI.getColValue("fecha_modificacion"," "), 0,5);
pc.addCols("Modificado por: "+cdoI.getColValue("usuario_modificacion"," "), 0,5);

pc.addCols(" ",0,tblMain.size());

pc.addBorderCols("Tipo Catéter/Tubo:  "+cdoI.getColValue("desc_tubo"," "), 0,5);
pc.addBorderCols("Medida: "+cdoI.getColValue("desc_medida"," "), 0,5);
pc.addBorderCols("Fecha inserción: "+cdoI.getColValue("fecha_insercion"," "), 0,5);
pc.addBorderCols("Insertador: "+cdoI.getColValue("insertador_desc"," "), 0,5);
pc.addBorderCols("Area: "+cdoI.getColValue("area_desc"," "),0,tblMain.size());

if (!cdoI.getColValue("fecha_retiro"," ").trim().equals("")) {
    pc.addBorderCols("Fecha Retiro: "+cdoI.getColValue("fecha_retiro"," "),0,tblMain.size());
}

pc.addCols(" ",0,tblMain.size());

pc.addBorderCols("Cuestionario a validar",0,5,Color.gray);
pc.addBorderCols("Puntuación (1/0)",1,2,Color.gray);
pc.addBorderCols("Observación",0,3,Color.gray);

pc.setFont(11,0);

for (int p = 0; p < alP.size(); p++) {
    CommonDataObject cdo = (CommonDataObject)alP.get(p);
    
    pc.addBorderCols(cdo.getColValue("pregunta"), 0,5);
    
    if(cdo.getColValue("totalizador","N").equalsIgnoreCase("N") || cdo.getColValue("supervisor","N").equalsIgnoreCase("S")){
        if(cdo.getColValue("supervisor","N").equalsIgnoreCase("S")){
            pc.addBorderCols(cdo.getColValue("puntuacion"), 1,2);
        } else {
            pc.addBorderCols(cdo.getColValue("puntuacion"), 1,2);
        }
    } else {
        pc.addBorderCols(cdoI.getColValue("total"), 1,2,Color.gray);
    }
    
    if(cdo.getColValue("activar_obs","N").equalsIgnoreCase("S")){
        pc.addBorderCols(cdo.getColValue("observacion"), 0,3);
    } else {
        pc.addBorderCols(" ", 0,3);
    }
}




pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>