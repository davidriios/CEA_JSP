<%//@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

Properties prop = new Properties();
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
String fp = request.getParameter("fp");

if (condTitle == null) condTitle = "";
if (fp == null) fp = "";
if (code == null) code = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
prop = SQLMgr.getDataProperties("select params from tbl_sal_recup_anes_sop where codigo = "+code+" and pac_id = "+pacId+" and admision = "+noAdmision);

if (prop == null) prop = new Properties();

ArrayList alMed = SQLMgr.getDataList("select codigo, to_char(hora_registro,'dd/mm/yyyy hh12:mi:ss am') hora_registro, upper(medicamento)medicamento, 'U' action from tbl_sal_recup_anes_sop_med where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by codigo");

ArrayList alTra = SQLMgr.getDataList("select codigo, to_char(hora_registro,'dd/mm/yyyy hh12:mi:ss am') hora_registro, upper(tratamiento)tratamiento, 'U' action from tbl_sal_recup_anes_sop_tra where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by codigo");

ArrayList alNEF = SQLMgr.getDataList("select codigo, to_char(hora_registro,'dd/mm/yyyy hh12:mi:ss am') hora_registro, upper(nota)nota, 'U' action from tbl_sal_recup_anes_sop_nef where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by codigo");


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
float leftRightMargin = 5.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = !desc.equals("")?desc:"NOTAS DIARIAS DE ENFERMERIA";
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

PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
  
if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);isUnifiedExp=true;}

Vector tblMain = new Vector();
tblMain.addElement("20"); 
tblMain.addElement("20");
tblMain.addElement("20");
tblMain.addElement("20");
tblMain.addElement("20");

boolean isFragment = fp.trim().equalsIgnoreCase("exp_kardex");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

pc.setFont(10,1);
pc.addBorderCols("Fecha Creación: ",0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("fecha_creacion"),0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(" ",0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols("Usuario Creación: ",0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("usuario_creacion"),0,1,0.1f,0.0f,0.0f,0.0f);

pc.addBorderCols("Fecha Modificación: ",0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("fecha_modificacion"),0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(" ",0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols("Usuario Modificación: ",0,1,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(prop.getProperty("usuario_modificacion"),0,1,0.1f,0.0f,0.0f,0.0f);
pc.addCols(" ",1,tblMain.size());

pc.addCols("DATOS GENERALES",0,tblMain.size(),Color.lightGray);

pc.setFont(10,1);
pc.addBorderCols("Operación: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("desc_proc"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

String params = "";

if (prop.getProperty("anestesia0").equalsIgnoreCase("ET")) params += "[ x ] ET:    "+prop.getProperty("anestesia0_desc");
if (prop.getProperty("anestesia1").equalsIgnoreCase("BM")) params += "          [ x ] BM:    "+prop.getProperty("anestesia1_desc");
if (prop.getProperty("anestesia2").equalsIgnoreCase("REGIONAL")) params += "          [ x ] REGIONAL:    "+prop.getProperty("anestesia2_desc");
if (prop.getProperty("anestesia3").equalsIgnoreCase("SEDACION")) params += "          [ x ] SEDACION:    "+prop.getProperty("anestesia3_desc");

pc.setFont(10,1);
pc.addBorderCols("Anestesia: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(params,0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,1);
pc.addBorderCols("Anestesiólogo: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("anestesiologoNombre"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,1);
pc.addBorderCols("Enfermera de Anestesia: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("enfermera_nombre_anes"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,1);
pc.addBorderCols("Cirujano: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("cirujanoNombre"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,1);
pc.addBorderCols("Asistente: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("asistente_nombre"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,1);
pc.addBorderCols("Enfermera de recuperación: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("recup_enfer_nombre"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,1);
pc.addBorderCols("Hora Entrada: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("hora_entrada"),0,1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,1);
pc.addBorderCols("Hora Salida: ",1,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("hora_salida"),0,1,0.1f,0.1f,0.1f,0.1f);

params = "";
if (prop.getProperty("egresado_a")!=null&&prop.getProperty("egresado_a").equalsIgnoreCase("C")) params = "CASA";
else if (prop.getProperty("egresado_a")!=null&&prop.getProperty("egresado_a").equalsIgnoreCase("H")) params = "HOSPITAL";

pc.setFont(10,1);
pc.addBorderCols("Salida a: "+params,0,1,0.1f,0.1f,0.1f,0.1f);

pc.addBorderCols("Enfermera que releva: ",0,1,0.1f,0.1f,0.1f,0.1f);
pc.setFont(10,0);
pc.addBorderCols(prop.getProperty("relev_enfer_nombre"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.addCols(" ",1,tblMain.size());

pc.setFont(10,1);
pc.addCols("TEST DE RECUPERACION DE ANESTESIA - SEDACION (SCORE DEL ALDRETE)",0,tblMain.size(),Color.lightGray);
pc.setFont(10,0);

int tHe=0, tM15=0, tM30=0, tM60=0, tM90=0, tM120=0, tHs=0, totalTest = 0;
ArrayList alH = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_recuperacion_anestesia order by orden");

Vector tblDet = new Vector();
tblDet.addElement("30");
tblDet.addElement("10");
tblDet.addElement("10");
tblDet.addElement("10");
tblDet.addElement("10");
tblDet.addElement("10");
tblDet.addElement("10");
tblDet.addElement("10");

for (int h = 0; h < alH.size(); h++){
    CommonDataObject cdoH = (CommonDataObject) alH.get(h);
    pc.addBorderCols(cdoH.getColValue("descripcion"), 0,1,0.1f,0.1f,0.1f,0.1f);
    
    ArrayList alD = SQLMgr.getDataList("select a.codigo, a.descripcion, a.escala,  b.minutos, b.escala_he as escalahe, b.escala_min15 as escalamin15, b.escala_min30 as escalamin30, b.escala_min60 as escalamin60, b.escala_min90 as escalamin90, b.escala_min120 as escalamin120, b.escala_hs as escalahs, (select join( cursor(select escala||'='||escala from tbl_sal_detalle_recuperacion where recup_anestesia = a.recup_anestesia order by codigo),',') from dual) escalas, a.recup_anestesia, decode(b.cod_recup_anes,null,'I','U') action from tbl_sal_detalle_recuperacion a, (select cod_recup_anes, codigo_det_recup, cod_det_recup_anes, minutos, escala_he, escala_min15, escala_min30, escala_min60, escala_min90, escala_min120, escala_hs from tbl_sal_recup_anes_sop_test where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_recup_anes = "+code+" order by 2) b where a.codigo = b.codigo_det_recup(+) and a.recup_anestesia = b.cod_det_recup_anes(+) and a.recup_anestesia = "+cdoH.getColValue("codigo")+" order by a.codigo");
    
    String codH = cdoH.getColValue("codigo");
    
    for (int d = 0; d < alD.size(); d++) {
        CommonDataObject cdoD = (CommonDataObject) alD.get(d);
        
        tHe  += Integer.parseInt(cdoD.getColValue("escalaHe","0"));
        tM15 += Integer.parseInt(cdoD.getColValue("escalaMin15","0"));
        tM30 += Integer.parseInt(cdoD.getColValue("escalaMin30","0"));
        tM60 += Integer.parseInt(cdoD.getColValue("escalaMin60","0"));
        tM90 += Integer.parseInt(cdoD.getColValue("escalaMin90","0"));
        tM120 += Integer.parseInt(cdoD.getColValue("escalaMin120","0"));
        tHs  += Integer.parseInt(cdoD.getColValue("escalaHs","0"));
        
        if(d == 0){
            pc.setNoColumnFixWidth(tblDet);
            pc.createTable("tblDet_"+codH,true,0,0,482f);
            
            pc.setFont(10,1);
            pc.addBorderCols("",0,1,Color.lightGray);
            pc.addBorderCols("HE",1,1,Color.lightGray);
            pc.addBorderCols("15",1,1,Color.lightGray);
            pc.addBorderCols("30",1,1,Color.lightGray);
            pc.addBorderCols("60",1,1,Color.lightGray);
            pc.addBorderCols("90",1,1,Color.lightGray);
            pc.addBorderCols("120",1,1,Color.lightGray);
            pc.addBorderCols("HS",1,1,Color.lightGray);
        }
        
        pc.setFont(10,0);
        pc.addBorderCols(cdoD.getColValue("descripcion"),0,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols(cdoD.getColValue("escalaHe"),1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols(cdoD.getColValue("escalamin15"),1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols(cdoD.getColValue("escalamin30"),1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols(cdoD.getColValue("escalamin60"),1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols(cdoD.getColValue("escalamin90"),1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols(cdoD.getColValue("escalamin120"),1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols(cdoD.getColValue("escalaHs"),1,1,0.1f,0.1f,0.1f,0.1f);

        if (d+1 == alD.size()) {
            pc.addBorderCols(" ",0,tblDet.size(),0.1f,0.1f,0.1f,0.1f);
            pc.useTable("main");
            pc.addTableToCols("tblDet_"+codH,0,4);
        }
    
    } // for d
    
    if(alD.size() == 0)pc.addBorderCols(" :: "+alD.size(), 0,4,0.1f,0.1f,0.1f,0.1f);
    
} // for h

pc.setNoColumnFixWidth(tblDet);
pc.createTable("tblTotal",true,0,0,482f);
pc.setFont(10,1);
pc.addBorderCols("Total",2,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tHe,1,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tM15,1,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tM30,1,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tM60,1,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tM90,1,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tM120,1,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tHs,1,1,0.1f,0.1f,0.1f,0.1f);

pc.useTable("main");
pc.addBorderCols("",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addTableToCols("tblTotal",0,4);

pc.addCols(" ",1,tblMain.size());

pc.addCols("SIGNOS VITALES",0,tblMain.size(),Color.lightGray);

ArrayList alD = SQLMgr.getDataList("select a.codigo, a.nombre, b.escalahe, b.escalamin15, b.escalamin30, b.escalamin60, b.escalamin90, b.escalamin120, b.escalahs, decode(b.cod_recup_anes,null,'I','U') action from tbl_sal_recup_anes_sop_signos a, (select b.escala_he as escalahe, b.escala_min15 as escalamin15, b.escala_min30 as escalamin30, b.escala_min60 as escalamin60, b.escala_min90 as escalamin90, b.escala_min120 as escalamin120, b.escala_hs as escalahs, cod_recup_anes, b.cod_signos from tbl_sal_recup_anes_sop_sv b where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_recup_anes = "+code+") b where a.estado = 'A' and a.codigo = b.cod_signos(+) order by a.orden");

pc.setNoColumnFixWidth(tblDet);
pc.createTable("tblSV",true,0,0,482f);
for (int d = 0; d < alD.size(); d++) {
    CommonDataObject cdoD = (CommonDataObject) alD.get(d);
     if(d == 0){            
        pc.setFont(10,1);
        pc.addBorderCols("",0,1,Color.lightGray);
        pc.addBorderCols("HE",1,1,Color.lightGray);
        pc.addBorderCols("15",1,1,Color.lightGray);
        pc.addBorderCols("30",1,1,Color.lightGray);
        pc.addBorderCols("60",1,1,Color.lightGray);
        pc.addBorderCols("90",1,1,Color.lightGray);
        pc.addBorderCols("120",1,1,Color.lightGray);
        pc.addBorderCols("HS",1,1,Color.lightGray);
    }
    
    pc.setFont(10,0);
    pc.addBorderCols(cdoD.getColValue("nombre"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalaHe"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin15"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin30"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin60"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin90"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin120"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalaHs"),1,1,0.1f,0.1f,0.1f,0.1f);
     
}     
pc.useTable("main");
pc.addBorderCols("",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addTableToCols("tblSV",0,4);


pc.addCols(" ",1,tblMain.size());

pc.addCols("FLUJOS PARENTERALES - DRENAJES",0,tblMain.size(),Color.lightGray);

alD = SQLMgr.getDataList("select a.codigo, a.nombre, b.escalahe, b.escalamin15, b.escalamin30, b.escalamin60, b.escalamin90, b.escalamin120, b.escalahs, decode(b.cod_recup_anes,null,'I','U') action from tbl_sal_recup_anes_sop_fluidos a, (select b.escala_he as escalahe, b.escala_min15 as escalamin15, b.escala_min30 as escalamin30, b.escala_min60 as escalamin60, b.escala_min90 as escalamin90, b.escala_min120 as escalamin120, b.escala_hs as escalahs, cod_recup_anes, b.cod_fluidos from tbl_sal_recup_anes_sop_fp b where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_recup_anes = "+code+") b where a.estado = 'A' and a.codigo = b.cod_fluidos(+) order by a.orden");

pc.setNoColumnFixWidth(tblDet);
pc.createTable("tblFP",true,0,0,482f);
for (int d = 0; d < alD.size(); d++) {
    CommonDataObject cdoD = (CommonDataObject) alD.get(d);
     if(d == 0){            
        pc.setFont(10,1);
        pc.addBorderCols("",0,1,Color.lightGray);
        pc.addBorderCols("HE",1,1,Color.lightGray);
        pc.addBorderCols("15",1,1,Color.lightGray);
        pc.addBorderCols("30",1,1,Color.lightGray);
        pc.addBorderCols("60",1,1,Color.lightGray);
        pc.addBorderCols("90",1,1,Color.lightGray);
        pc.addBorderCols("120",1,1,Color.lightGray);
        pc.addBorderCols("HS",1,1,Color.lightGray);
    }
    
    pc.setFont(10,0);
    pc.addBorderCols(cdoD.getColValue("nombre"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalaHe"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin15"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin30"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin60"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin90"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalamin120"),1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdoD.getColValue("escalaHs"),1,1,0.1f,0.1f,0.1f,0.1f);
     
}     
pc.useTable("main");
pc.addBorderCols("",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addTableToCols("tblFP",0,4);

pc.setFont(10,1);
pc.addCols(" ",1,tblMain.size());
pc.addCols("MEDICAMENTOS",0,tblMain.size(),Color.lightGray);
pc.addBorderCols("HORA REGISTRO",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("MEDICAMENTO",0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,0);
for (int i = 1; i<=alMed.size();i++) {
    cdo = (CommonDataObject) alMed.get(i-1);
    pc.addBorderCols(cdo.getColValue("hora_registro"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdo.getColValue("medicamento"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);
}

pc.setFont(10,1);
pc.addCols(" ",1,tblMain.size());
pc.addCols("TRATAMIENTOS",0,tblMain.size(),Color.lightGray);
pc.addBorderCols("HORA REGISTRO",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("TRATAMIENTO",0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,0);
for (int i = 1; i<=alTra.size();i++) {
    cdo = (CommonDataObject) alTra.get(i-1);
    pc.addBorderCols(cdo.getColValue("hora_registro"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdo.getColValue("tratamiento"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);
}

pc.setFont(10,1);
pc.addCols(" ",1,tblMain.size());
pc.addCols("NOTAS DE ENFERMERA DE RECOBRO",0,tblMain.size(),Color.lightGray);
pc.addBorderCols("HORA REGISTRO",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("NOTA",0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setFont(10,0);
for (int i = 1; i<=alNEF.size();i++) {
    cdo = (CommonDataObject) alNEF.get(i-1);
    pc.addBorderCols(cdo.getColValue("hora_registro"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(cdo.getColValue("nota"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);
}

String horaEntrada = prop.getProperty("hora_entrada")!=null&&!prop.getProperty("hora_entrada").equals("")?prop.getProperty("hora_entrada"):"";
String horaSalida = prop.getProperty("hora_salida")!=null&&!prop.getProperty("hora_salida").equals("")?prop.getProperty("hora_salida"):"";

cdo = SQLMgr.getData("select (join(cursor(select lpad(' ',4)||a.nombre||': '||b.escalahs||' '||rpad(' ', length(a.nombre),' ') as escala from tbl_sal_recup_anes_sop_signos a, (select b.escala_hs as escalahs, cod_recup_anes, b.cod_signos from tbl_sal_recup_anes_sop_sv b where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_recup_anes = "+code+") b where a.estado = 'A' and a.codigo = b.cod_signos(+) order by a.orden),' ** ') ) signos_vitales, case when '"+horaEntrada+"' is not null and '"+horaSalida+"' is not null then round((to_date('"+horaSalida+"','dd/mm/yyyy hh12:mi:ss am') - to_date('"+horaEntrada+"','dd/mm/yyyy hh12:mi:ss am'))*24) else 0 end||' horas' tiempo_recup,(select total from tbl_sal_escalas where pac_id = "+pacId+" and tipo = 'DO' and admision = "+noAdmision+" and id = (select max(id) from tbl_sal_escalas where pac_id = "+pacId+" and tipo = 'DO' and admision = "+noAdmision+")) escala_dolor from dual");

if (cdo == null) cdo = new CommonDataObject();

pc.setFont(10,1);
pc.addCols(" ",1,tblMain.size());
pc.addCols("DATOS DE SALIDA",0,tblMain.size(),Color.lightGray);
pc.addBorderCols("Signos Vitales al Egreso:",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(cdo.getColValue("signos_vitales"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.addBorderCols("Tiempo Recuperación:",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(cdo.getColValue("tiempo_recup"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.addBorderCols("Escala Aldrete Egreso:",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(""+tHs,0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.addBorderCols("Escala del Dolor:",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(cdo.getColValue("escala_dolor"),0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

params = "";
if (prop.getProperty("egresado_a")!=null&&prop.getProperty("egresado_a").equalsIgnoreCase("C")) params = "CASA";
else if (prop.getProperty("egresado_a")!=null&&prop.getProperty("egresado_a").equalsIgnoreCase("H")) params = "HOSPITAL";

pc.addBorderCols("Egreso por indicación médica a:",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(params,0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.setVAlignment(1);
pc.addBorderCols("\n\nFirma de la Enfermera:",0,1,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols(" ",0,tblMain.size()-1,0.1f,0.1f,0.1f,0.1f);

pc.addTable();
if(isUnifiedExp){
    pc.close();
    response.sendRedirect(redirectFile);
}
%>