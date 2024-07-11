<%//@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String code = request.getParameter("code");
String condTitle = request.getParameter("cond_title");
String fechaCreacion = request.getParameter("fecha_creacion");
String usuarioCreacion = request.getParameter("usuario_creacion");

if (fg == null) fg = "SAD";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(code == null) code = "0";
if(fechaCreacion == null) fechaCreacion = "";
if(usuarioCreacion == null) usuarioCreacion = "";

sql = "select codigo as cod_ronda, to_char(fecha_creacion,'dd/mm/yy hh12:mi:ss am') fecha, usuario_creacion, interconsultor, cirugia, responsable, to_char(fecha_cirugia,'dd/mm/yyyy') fecha_cirugia, dias_post_cirugia from tbl_sal_rondas where pac_id="+pacId+" and admision="+noAdmision+" and trunc(fecha_creacion) = to_date('"+fechaCreacion+"','dd/mm/yyyy')";

if(!code.equals("0")) sql += " and codigo = "+code;
cdo = SQLMgr.getData(sql);

if (cdo == null) cdo = new CommonDataObject();

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
boolean isLandscape = true;
float leftRightMargin = 20.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = !desc.equals("")?desc:"RONDAS MULTIDISCIPLINARIAS";
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

Vector tblMain = new Vector();
tblMain.addElement("25");
tblMain.addElement("25");
tblMain.addElement("25");
tblMain.addElement("25");

Vector tblDet = new Vector();
tblDet.addElement("9");
tblDet.addElement("13");
tblDet.addElement("13");
tblDet.addElement("13");
tblDet.addElement("13");
tblDet.addElement("13");
tblDet.addElement("13");
tblDet.addElement("13");

PdfCreator pc = null;
boolean isUnifiedExp = false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");

PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
footer.setNoColumnFixWidth(tblMain);
footer.createTable();
footer.setFont(9, 0);
footer.addBorderCols(" ",0,tblMain.size(),0.0f,0.0f,0.0f,0.0f);
footer.addCols("Responsible de la ronda: "+cdo.getColValue("responsable"," "),0,2);
footer.addCols("Firma: ______________________________________",0,2);
footer.addBorderCols(" ",0,tblMain.size(),0.0f,0.0f,0.0f,0.0f);
  
if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());isUnifiedExp=true;}

pc.setNoColumnFixWidth(tblMain);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);
ArrayList al = new ArrayList();
String codRonda = cdo.getColValue("cod_ronda","0");

al = SQLMgr.getDataList("select to_char(d.fecha,'dd/mm/yy hh12:mi am') fecha_det, medico, nutricion, farmacia, terapia_fisica, terapia_respiratorio, otros, enfermera, interconsultor from tbl_sal_rondas_det d, tbl_sal_rondas a where a.codigo = d.cod_ronda and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by d.fecha desc");

pc.setNoColumnFixWidth(tblDet);
pc.createTable("det", false);

pc.setFont(9,1);
pc.addBorderCols("Fecha/Hora",1,1,Color.lightGray);
pc.addBorderCols("M.Hostitalista",1,1,Color.lightGray);
pc.addBorderCols("Enfermería",1,1,Color.lightGray);
pc.addBorderCols("Nutrición",1,1,Color.lightGray);
pc.addBorderCols("Farmacia",1,1,Color.lightGray);
pc.addBorderCols("T.Física",1,1,Color.lightGray);
pc.addBorderCols("T.Respiratoria",1,1,Color.lightGray);
pc.addBorderCols("Otros",1,1,Color.lightGray);

for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    
    pc.setFont(9, 0);
    pc.addBorderCols(cdo.getColValue("fecha_det"),1,1);
    pc.addBorderCols(cdo.getColValue("medico"),1,1);
    pc.addBorderCols(cdo.getColValue("enfermera"),1,1);
    pc.addBorderCols(cdo.getColValue("nutricion"),1,1);
    pc.addBorderCols(cdo.getColValue("farmacia"),1,1);
    pc.addBorderCols(cdo.getColValue("terapia_fisica"),1,1);
    pc.addBorderCols(cdo.getColValue("terapia_respiratorio"),1,1);
    pc.addBorderCols(cdo.getColValue("otros"),1,1);
    
    if (!cdo.getColValue("interconsultor"," ").trim().equals("")){
        pc.addBorderCols("             Interconsultor:   "+cdo.getColValue("interconsultor"),0,tblDet.size());
    }
}

al = SQLMgr.getDataList("select d.diag_desc, a.cirugia, to_char(a.fecha_cirugia,'dd/mm/yyyy') fecha_cirugia from tbl_sal_rondas_diags d, tbl_sal_rondas a where a.codigo = d.cod_ronda and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by d.fecha desc");

pc.addCols(" ",0,tblDet.size());

pc.setFont(9,1);
pc.addBorderCols("Diagnósticos",1,3,Color.lightGray);
pc.addBorderCols("Cirgugía",1,4,Color.lightGray);
pc.addBorderCols("F.Cirgugía",1,1,Color.lightGray);

for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    
    pc.setFont(9, 0);
    pc.addBorderCols(cdo.getColValue("diag_desc"),1,3);
    pc.addBorderCols(cdo.getColValue("cirugia"),1,4);
    pc.addBorderCols(cdo.getColValue("fecha_cirugia"),1,1);
}

pc.setFont(9, 1);
pc.addCols("Dieta: ",0,tblDet.size());
pc.setFont(9, 0);

pc.addBorderCols("\n\n",0,tblDet.size());
pc.addBorderCols("\n\n",0,tblDet.size());
pc.addBorderCols("\n\n",0,tblDet.size());
pc.addBorderCols("\n\n",0,tblDet.size());
pc.addBorderCols("\n\n",0,tblDet.size());

pc.addCols(" ",0,tblDet.size(),Color.lightGray);

al = SQLMgr.getDataList("select d.ind_medica from tbl_sal_rondas_indicaciones d, tbl_sal_rondas a where a.codigo = d.cod_ronda and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" order by d.fecha desc");

pc.setFont(9,1);
pc.addBorderCols("Problema / Necesidad",1,1,Color.lightGray);
pc.addBorderCols("Meta diaria",1,1,Color.lightGray);
pc.addBorderCols("Indicaciones médicas especiales",1,2,Color.lightGray);
pc.addBorderCols("Observaciones",1,2,Color.lightGray);
pc.addBorderCols("F.Inicio",1,1,Color.lightGray);
pc.addBorderCols("F.Resolución",1,1,Color.lightGray);

for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    
    pc.setFont(9, 0);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(cdo.getColValue("ind_medica"),1,2);
    pc.addBorderCols(" ",1,2);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
}

for (int i = 0; i < 6; i++) {
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,2);
    pc.addBorderCols(" ",1,2);
    pc.addBorderCols(" ",1,1);
    pc.addBorderCols(" ",1,1);
}








pc.useTable("main");
pc.addTableToCols("det",0,tblMain.size(),0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);






/*

al = SQLMgr.getDataList("select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha_det, medico, nutricion, farmacia, terapia_fisica, terapia_respiratorio, otros, enfermera  from tbl_sal_rondas_det where cod_ronda = "+codRonda+" order by fecha");

String groupBy = "";
    for (int i = 0; i<al.size(); i++) {
        CommonDataObject cdo1 = (CommonDataObject) al.get(i);
        
        if (!groupBy.equals(cdo1.getColValue("fecha_det"))){
            pc.setFont(9,1);
            pc.addCols(cdo1.getColValue("fecha_det"),0,tblMain.size());
        }
        
        pc.setFont(9,0);
        pc.addBorderCols("Médico Hospitalista: "+cdo1.getColValue("medico"),0,2);
        pc.addBorderCols("Enfermería: "+cdo1.getColValue("enfermera"),0,2);
        pc.addBorderCols("Nutrición: "+cdo1.getColValue("nutricion"),0,2);
        pc.addBorderCols("Farmacia: "+cdo1.getColValue("farmacia"),0,2);
        pc.addBorderCols("Terapia física: "+cdo1.getColValue("terapia_fisica"),0,2);
        pc.addBorderCols("Terapia respiratoria: "+cdo1.getColValue("terapia_respiratorio"),0,2);
        pc.addBorderCols("Otros: "+cdo1.getColValue("otros"),0,tblMain.size());
        
        groupBy = cdo1.getColValue("fecha_det");
    }

    pc.addCols("Interconsultor: "+cdo.getColValue("interconsultor"," "),0, tblMain.size());
    pc.addCols(" ",0, tblMain.size());
    
    pc.addCols("DIAGNOSTICOS",0,tblMain.size(),Color.lightGray);

    al = SQLMgr.getDataList("select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, diagnostico, diag_desc from tbl_sal_rondas_diags where cod_ronda = "+codRonda+" order by fecha");
    
    pc.addBorderCols("Fecha",0,1);
    pc.addBorderCols("Diagnosticos",0,tblMain.size()-1);

    for (int i = 0; i<al.size(); i++) {
        CommonDataObject cdo1 = (CommonDataObject) al.get(i);

        pc.setFont(9,0);
        pc.addBorderCols(cdo1.getColValue("fecha"),0,1);
        pc.addBorderCols(cdo1.getColValue("diag_desc"),0,tblMain.size()-1);
    }
    
    pc.addCols(" ",0, tblMain.size());
    pc.addCols("Cirgugía: "+cdo.getColValue("cirugia"," "),0, tblMain.size());
    pc.addCols("Fecha Cirgugía: "+cdo.getColValue("fecha_cirugia"," "),0, 2);
    pc.addCols("Dias Post cirugía: "+cdo.getColValue("dias_post_cirugia"," "),0, 2);
    pc.addCols(" ",0, tblMain.size());
    
    pc.addCols("Interconsultor: "+cdo.getColValue("interconsultor"," "),0, tblMain.size());
    pc.addCols(" ",0, tblMain.size());
    
    pc.addCols("TRATAMIENTOS",0,tblMain.size(),Color.lightGray);

    al = SQLMgr.getDataList("select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, tratamiento from tbl_sal_rondas_tratamientos where cod_ronda = "+codRonda+" order by fecha");
    
    pc.addBorderCols("Fecha",0,1);
    pc.addBorderCols("Tratamiento",0,tblMain.size()-1);

    for (int i = 0; i<al.size(); i++) {
        CommonDataObject cdo1 = (CommonDataObject) al.get(i);

        pc.setFont(9,0);
        pc.addBorderCols(cdo1.getColValue("fecha"),0,1);
        pc.addBorderCols(cdo1.getColValue("tratamiento"),0,tblMain.size()-1);
    }

    //Indicaciones
    
    al = SQLMgr.getDataList("select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, plan_cuidado, ind_medica, ind_farmacia, ind_nutricion, estudios_pendientes, consultas_pendientes from tbl_sal_rondas_indicaciones where cod_ronda = "+codRonda+" order by fecha");
    
    groupBy = "";
    
    pc.addCols(" ",0, tblMain.size());
    pc.addCols("INDICACIONES",0,tblMain.size(),Color.lightGray);
    for (int i = 0; i<al.size(); i++) {
        CommonDataObject cdo1 = (CommonDataObject) al.get(i);
        
        if (!groupBy.equals(cdo1.getColValue("fecha"))){
            pc.setFont(9,1);
            pc.addCols("",0,tblMain.size());
            pc.addCols(cdo1.getColValue("fecha"),0,tblMain.size());
        }
        
        pc.setFont(9,0);
        pc.addBorderCols("Plan Cuidado:",0,1);
        pc.addBorderCols(cdo1.getColValue("plan_cuidado"),0,tblMain.size()-1);
        
        pc.addBorderCols("Indicaciones médicas especiales:",0,1);
        pc.addBorderCols(cdo1.getColValue("ind_medica"),0,tblMain.size()-1);
        
        pc.addBorderCols("Farmacia:",0,1);
        pc.addBorderCols(cdo1.getColValue("ind_farmacia"),0,tblMain.size()-1);
        
        pc.addBorderCols("Nutrición:",0,1);
        pc.addBorderCols(cdo1.getColValue("ind_nutricion"),0,tblMain.size()-1);
        
        pc.addBorderCols("Estudios Pendientes:",0,1);
        pc.addBorderCols(cdo1.getColValue("estudios_pendientes"),0,tblMain.size()-1);
        
        pc.addBorderCols("Consultas Pendientes:",0,1);
        pc.addBorderCols(cdo1.getColValue("consultas_pendientes"),0,tblMain.size()-1);
        
        
        groupBy = cdo1.getColValue("fecha");
    }

    
    */
    
    
    
    
    
    
    
    
    


pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>