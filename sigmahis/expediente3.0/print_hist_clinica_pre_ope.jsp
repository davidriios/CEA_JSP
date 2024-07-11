<%@ page errorPage="../error.jsp" %>
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

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData = new CommonDataObject();
String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
String codigo = request.getParameter("codigo");

if (fg == null) fg = "";
boolean isFragment = fg.trim().equalsIgnoreCase("exp_kardex")||fg.trim().equalsIgnoreCase("handover");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

cdoUsr.addColValue("usuario",userName);

cdo = SQLMgr.getData("select to_char(fecha_eval, 'dd/mm/yyyy') fecha_eval, to_char(hora_eval, 'hh12:mi:ss am') hora_eval, cod_diag, cod_proc, (select nvl(observacion,nombre) from tbl_cds_diagnostico where codigo = cod_diag and rownum  = 1) desc_diag, (select nvl(observacion,descripcion) from tbl_cds_procedimiento where codigo = cod_proc and rownum  = 1 ) desc_proc, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, usuario_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fm, usuario_modificacion from tbl_sal_hist_clinica_pre_ope where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+codigo); 

ArrayList alA = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = "+codigo+" and tipo = 'A' order by a.orden");
    
ArrayList alB = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = "+codigo+" and tipo = 'B' order by a.orden");

ArrayList alC = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = "+codigo+" and tipo = 'C' and estado = 'A' order by a.orden, a.observacion");

if(desc == null) desc = "";
String customFirstTitle = request.getParameter("custom_first_title");
if (customFirstTitle == null) customFirstTitle = "";

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

float width = 82 * 8.5f;//612 
float height = 62 * 14f;//792
boolean isLandscape = false;
float leftRightMargin = 15.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = customFirstTitle;
String xtraSubtitle = desc; //"DEL "+fechaini+" AL "+fechafin;

boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 12;
float cHeight = 90.0f;

String si,no ;
    
CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
}
if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
}
	
PdfCreator pc = null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";

Vector dHeader = new Vector();
dHeader.addElement(".46");
dHeader.addElement(".04");
dHeader.addElement(".04");
dHeader.addElement(".46");

pc.setNoColumnFixWidth(dHeader);
pc.createTable();
		
String showHeader = request.getParameter("showHeader");
if (showHeader == null) showHeader = "Y";
if (showHeader.equals("Y")){
    pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
} else {
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(customFirstTitle.trim().equals("")?desc:customFirstTitle,1,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
}
pc.setFont(10, 1);

pc.setVAlignment(0);

if (cdo == null) cdo = new CommonDataObject();

pc.addCols("Creado el: "+cdo.getColValue("fc"," "), 0,2);
pc.addCols("Creado por: "+cdo.getColValue("usuario_creacion"," "), 0,2);
pc.addCols("Modificado el: "+cdo.getColValue("fm"," "), 0,2);
pc.addCols("Modificado por: "+cdo.getColValue("usuario_modificacion"," "), 0,2);

pc.addCols(" ", 0, dHeader.size());

pc.setFont(10, 0);
pc.addBorderCols("Diagnóstico:     "+cdo.getColValue("desc_diag"," "), 0, dHeader.size(),0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("Procedimiento:     "+cdo.getColValue("desc_proc"," "), 0, dHeader.size(),0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("Fecha de evaluación preoperatoria:     "+cdo.getColValue("fecha_eval"," "), 0, 2,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("Hora de evaluación preoperatoria:     "+cdo.getColValue("hora_eval"," "), 0, 2,0.1f,0.1f,0.1f,0.1f);

pc.addCols(" ", 0, dHeader.size());

for (int a = 0; a < alA.size(); a++) {
    CommonDataObject cdoA = (CommonDataObject) alA.get(a);
    
    if (a == 0) {
        pc.setFont(10,1);
        pc.addCols(cdoA.getColValue("titulo"), 1, dHeader.size(), Color.lightGray);
        
        pc.addBorderCols("METs",0,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("SI",1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("NO",1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("DESCRIPCION DE LA ACTIVIDAD REALIZADA",0,1,0.1f,0.1f,0.1f,0.1f);
    }
    pc.setFont(10,0);
    
    String valorSi = cdoA.getColValue("valor")!=null&&cdoA.getColValue("valor").equalsIgnoreCase("S") ? " [ x ]":"";
    String valorNo = cdoA.getColValue("valor")!=null&&cdoA.getColValue("valor").equalsIgnoreCase("N") ? " [ x ]":"";
    
    pc.addBorderCols(cdoA.getColValue("descripcion"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(valorSi,1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(valorNo,1,1,0.1f,0.1f,0.1f,0.1f);
    
    pc.setFont(8,3);
    pc.addBorderCols(cdoA.getColValue("observacion"),0,1,0.1f,0.1f,0.1f,0.1f);
}

Vector tblB = new Vector();
tblB.addElement(".84");
tblB.addElement(".08");
tblB.addElement(".08");

Vector tblC = new Vector();
tblC.addElement(".84");
tblC.addElement(".08");
tblC.addElement(".08");

pc.addCols(" ", 0, dHeader.size());

pc.setNoColumnFixWidth(tblB);
pc.createTable("tblB", false,15, 0.0f, 335f);

for (int b = 0; b < alB.size(); b++) {
    CommonDataObject cdoB = (CommonDataObject) alB.get(b);
    
    if (b == 0) {
        pc.setFont(10,1);
        
        pc.addBorderCols(cdoB.getColValue("titulo"," ").replaceAll("<br>","\n"),0,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("SI",1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("NO",1,1,0.1f,0.1f,0.1f,0.1f);
    }
    
    pc.setFont(10,0);
    
    String valorSi = cdoB.getColValue("valor")!=null&&cdoB.getColValue("valor").equalsIgnoreCase("S") ? " [ x ]":"";
    String valorNo = cdoB.getColValue("valor")!=null&&cdoB.getColValue("valor").equalsIgnoreCase("N") ? " [ x ]":"";
    
    pc.addBorderCols(cdoB.getColValue("descripcion"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(valorSi,1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(valorNo,1,1,0.1f,0.1f,0.1f,0.1f);
    
    if(b+1 == alB.size()){
        pc.addBorderCols("Total",1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("",1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("",1,1,0.1f,0.1f,0.1f,0.1f);
    }
}

pc.setNoColumnFixWidth(tblC);
pc.createTable("tblC", false,15, 0.0f,335f);
String groupC = "";

for (int c = 0; c < alC.size(); c++) {
    CommonDataObject cdoC = (CommonDataObject) alC.get(c);
    
    if (c == 0) {
        pc.setFont(10,1);
        
        pc.addBorderCols(cdoC.getColValue("titulo"),0,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("SI",1,1,0.1f,0.1f,0.1f,0.1f);
        pc.addBorderCols("NO",1,1,0.1f,0.1f,0.1f,0.1f);
    }
    
    if (!groupC.equalsIgnoreCase(cdoC.getColValue("observacion"))) {
        pc.setFont(10,1);
        pc.addCols(cdoC.getColValue("observacion"),0,3,Color.lightGray);
    }
    
    pc.setFont(10,0);
    
    String valorSi = cdoC.getColValue("valor")!=null&&cdoC.getColValue("valor").equalsIgnoreCase("S") ? " [ x ]":"";
    String valorNo = cdoC.getColValue("valor")!=null&&cdoC.getColValue("valor").equalsIgnoreCase("N") ? " [ x ]":"";
    
    pc.addBorderCols(cdoC.getColValue("descripcion"),0,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(valorSi,1,1,0.1f,0.1f,0.1f,0.1f);
    pc.addBorderCols(valorNo,1,1,0.1f,0.1f,0.1f,0.1f);
    
    groupC = cdoC.getColValue("observacion");
}

pc.useTable("main");
pc.addTableToCols("tblB",0,2);
pc.addTableToCols("tblC",0,2);

pc.addCols(" ", 0, dHeader.size());
pc.setFont(10,1);
pc.addCols("PRUEBAS DE LABORATORIO Y GABINETE", 1, dHeader.size(),Color.lightGray);

al = SQLMgr.getDataList("select codigo, laboratorio, resultado, to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, nec_cruce, cant_cruce, consulta_esp, observ_esp from tbl_sal_hist_cli_lab where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo_eval = "+codigo+" order by codigo");

Vector tblLab = new Vector();
tblLab.addElement(".40");
tblLab.addElement(".40");
tblLab.addElement(".20");

pc.addCols(" ", 0, dHeader.size());

pc.setNoColumnFixWidth(tblLab);
pc.createTable("tblLab");

String gCodigo = "";
for (int i = 0; i < al.size(); i++) {
    cdo = (CommonDataObject) al.get(i);
    
    if (!gCodigo.equals(cdo.getColValue("codigo"))) {
        if (i > 0) {
           pc.addBorderCols(" ",0,tblLab.size(), 0.0f, 0.0f, 0.1f, 0.1f); 
           pc.addBorderCols(" ",0,tblLab.size(), 0.0f, 0.0f, 0.1f, 0.1f); 
        }
        
        pc.setFont(10,1);
        pc.addBorderCols("# "+cdo.getColValue("codigo"),0,tblLab.size(), 0.1f, 0.1f, 0.1f, 0.1f);
        pc.addBorderCols("PRUEBAS",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
        pc.addBorderCols("RESULTADO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
        pc.addBorderCols("FECHA",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    }
    
    pc.setFont(10,0);
    pc.addBorderCols(cdo.getColValue("laboratorio"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("resultado"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    pc.addBorderCols(cdo.getColValue("fecha"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
    
    gCodigo = cdo.getColValue("codigo");
}

pc.useTable("main");
pc.addTableToCols("tblLab",0,dHeader.size());

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
