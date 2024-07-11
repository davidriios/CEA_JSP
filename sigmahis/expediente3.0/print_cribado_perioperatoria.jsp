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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

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

cdo = SQLMgr.getData("select to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, to_char(a.fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fm, observacion, a.usuario_creacion, a.usuario_modificacion from tbl_sal_cribado_periope a where a.codigo = "+codigo+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision); 

sql = "select a.codigo, a.pregunta, b.observacion, b.aplicar, b.aplicar_secundario, a.pregunta_secundaria, a.pregunta_secundaria_cuando from tbl_sal_preguntas_cribado a, tbl_sal_cribado_periope_det b where a.estado = 'A' and a.codigo = b.tipo_pregunta and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_plan = "+codigo;

if (isFragment) {
} else {
}
sql += " order by a.orden ";

al = SQLMgr.getDataList(sql);
if(desc == null) desc = "";

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
String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

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
//dHeader.addElement(".60"); // pregunta
dHeader.addElement(".92"); // pregunta
dHeader.addElement(".04"); // SI
dHeader.addElement(".04"); // NO
//dHeader.addElement(".32"); // Observación

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
    pc.addCols(desc,1,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
}

pc.setFont(9, 1);

pc.setVAlignment(0);

if (cdo == null) cdo = new CommonDataObject();

pc.addCols("Creado el: "+cdo.getColValue("fc"," ")+"                                Creado por:  "+cdo.getColValue("usuario_creacion"," "), 0,dHeader.size());
pc.addCols("Modificado el: "+cdo.getColValue("fm")+"                                Modificado por:  "+cdo.getColValue("usuario_modificacion"," "), 0,dHeader.size());

pc.addCols(" ", 0, dHeader.size());

pc.addBorderCols("ASPECTOS A EVALUAR",0 ,1,Color.lightGray);
pc.addBorderCols("SI",1 ,1,Color.lightGray);
pc.addBorderCols("NO",1 ,1,Color.lightGray);
//pc.addBorderCols("OBSERVACIÓN",0 ,1,Color.lightGray);

pc.setTableHeader(3);

for(int i = 0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    
    pc.setFont(8, 0);
    
    if(cdo.getColValue("aplicar"," ").trim().equalsIgnoreCase("S")){
        si = "x";
        no = "";
    }
    else if(cdo.getColValue("aplicar"," ").trim().equalsIgnoreCase("N")){
        si = "";
        no = "x";
    }
    else{
       no = "";
       si = "";
    }
    
    if(!cdo.getColValue("pregunta_secundaria", " ").trim().equals("")){
      pc.addBorderCols(cdo.getColValue("pregunta"),0,1, 0f, 0.5f, 0.5f, 0.5f);
    } else pc.addBorderCols(cdo.getColValue("pregunta"),0,1);
    pc.addBorderCols(si,1,1);
    pc.addBorderCols(no,1,1);
    //pc.addBorderCols(cdo.getColValue("observacion"),0,1);
    
    if(!cdo.getColValue("pregunta_secundaria", " ").trim().equals("")){
      pc.addBorderCols("      "+cdo.getColValue("pregunta_secundaria", " "),0,1, 0f, 0f, 0.5f, 0.5f);
      
      if(cdo.getColValue("aplicar_secundario"," ").trim().equalsIgnoreCase("S")){
          pc.addBorderCols("x",1,1);
          pc.addBorderCols("",1,1);
      } else if(cdo.getColValue("aplicar_secundario"," ").trim().equalsIgnoreCase("N")){
          pc.addBorderCols("",1,1);
          pc.addBorderCols("x",1,1);
      } else {
        pc.addBorderCols("",1,1);
        pc.addBorderCols("",1,1);
      }
    }

}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
