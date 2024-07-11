<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData = new CommonDataObject();

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String sql = "";
String mode = request.getParameter("mode");
String appendFilter = request.getParameter("appendFilter");
String appendFilter0 = request.getParameter("appendFilter0");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaReporte = request.getParameter("fecha");
String fg = request.getParameter("fg");
String seccion = request.getParameter("seccion");
String id = request.getParameter("id");
String desc = request.getParameter("desc");
cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (id == null) id = "0";
if (fg == null) fg = "TVP";
if (desc == null) desc = "";

String showRiesgo = "SIN PRECAUCION";
try{showRiesgo=java.util.ResourceBundle.getBundle("issi").getString("showRiesgo");}catch(Exception e){}		
if (showRiesgo.equals("Y")) showRiesgo = "SIN RIESGO";

CommonDataObject cdoC = new CommonDataObject();
String compania = (String) session.getAttribute("_companyId");
int total = Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
String _color = "", colorClass = "", level = "";
Color low = Color.white;
Color medium = Color.white;
Color high = Color.white;
java.util.Hashtable iCol = new java.util.Hashtable();
String intCode = request.getParameter("int_code");
String intDesc = request.getParameter("int_desc");
String intObserv = request.getParameter("int_observ");

if (intCode == null) intCode = "0";
if (intDesc == null) intDesc = "N/A";
if (intObserv == null) intObserv = "N/A";

CommonDataObject cdoD = SQLMgr.getData("select usuario_mod, usuario, to_char(fecha, 'dd/mm/yyyy') as fecha, to_char(hora, 'hh12:mi am') as hora, to_char(fecha_mod, 'dd/mm/yyyy hh12:mi am') as fecha_mod from tbl_sal_escalas where tipo = '"+fg+"' and pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+id);
if (cdoD == null) cdoD = new CommonDataObject();

if (fg.trim().equals("DO")) cdoC = SQLMgr.getData("select get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS_DO') as color from dual");
else if (fg.trim().equals("MM5")) cdoC = SQLMgr.getData("select '1-3:GREEN:BAJO,3-4:YELLOW:MEDIO,4-5:RED:ALTO' as color from dual");
else if (fg.trim().equals("BR")) cdoC = SQLMgr.getData("select '18-100:GREEN:BAJO,16-18:YELLOW:MEDIO,0-15:RED:ALTO' as color from dual");
else if (fg.trim().equals("CA")) cdoC = SQLMgr.getData("select '0-3:GREEN:BAJO,4-6:YELLOW:MEDIO,7-10:RED:ALTO' as color from dual");
else if (fg.trim().equals("MAC")) cdoC = SQLMgr.getData("select '0-2:GREEN:BAJO,3-100:RED:ALTO' as color from dual");
else if (fg.trim().equals("TVP")) cdoC = SQLMgr.getData("select '0-1:GREEN:BAJO,2-3:YELLOW:MEDIO,4-5:RED:ALTO,5-100:RED:EXTREMADO' as color from dual");
else cdoC = SQLMgr.getData("select get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS') as color from dual");

if (cdoC==null) cdoC = new CommonDataObject();
_color = cdoC.getColValue("color","");
colorClass = "";
level = "";

try{
String[] c1 = _color.split(","); //0-3:green
for (int a=0;a<c1.length;a++){
  String[] c2 = c1[a].split(":"); //0-3,green,bajo
  String[] c3 = c2[0].split("-"); //0,3
  int from = Integer.parseInt(c3[0]);
  int to = Integer.parseInt(c3[1]);
  if (total >= from && total <= to){
    colorClass=c2[1].toLowerCase();
    level =c2[2].toLowerCase(); 
    break;
  }
}
String[] c2 = _color.split(",");
}catch(Exception e){System.out.println("::::::::::::::::::::::::::::: Error al buscar los colores de la cabecera de la intervención");e.printStackTrace();}

iCol.put("green",Color.green);
iCol.put("yellow",Color.yellow);
iCol.put("red",Color.red);
iCol.put("extreme",Color.red);

if (level.equalsIgnoreCase("bajo")) low = (Color)iCol.get(colorClass.trim());
else if (level.equalsIgnoreCase("medio")) medium = (Color)iCol.get(colorClass.trim());
else if (level.equalsIgnoreCase("alto")) high = (Color)iCol.get(colorClass.trim());
else if (level.equalsIgnoreCase("extremado")) high = (Color)iCol.get(colorClass.trim());

String fecha = cDateTime;
String year = fecha.substring(6, 10);
String month = fecha.substring(3, 5);
String day = fecha.substring(0, 2);

String servletPath = request.getServletPath();
String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

if (month.equals("01")) month = "january";
else if (month.equals("02")) month = "february";
else if (month.equals("03")) month = "march";
else if (month.equals("04")) month = "april";
else if (month.equals("05")) month = "may";
else if (month.equals("06")) month = "june";
else if (month.equals("07")) month = "july";
else if (month.equals("08")) month = "august";
else if (month.equals("09")) month = "september";
else if (month.equals("10")) month = "october";
else if (month.equals("11")) month = "november";
else month = "december";

String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
String statusPath = "";
String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

float width = 72 * 8.5f;//612
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
String subtitle = !desc.equals("") ? desc : "ESCALA TVP Y TEV";
String xtraSubtitle = "";
boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 8;
float cHeight = 12.0f;

CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
if (paramCdo == null) {
paramCdo = new CommonDataObject();
paramCdo.addColValue("is_landscape","N");
}
if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
cdoPacData.addColValue("is_landscape",""+isLandscape);}

PdfCreator pc = null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){
    pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    isUnifiedExp = true;
}

Vector tblMain = new Vector();
tblMain.addElement("30");
tblMain.addElement("70");

Vector tblDet = new Vector();
tblDet.addElement("5");
tblDet.addElement("50");
tblDet.addElement("5");
tblDet.addElement("40");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();

pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, tblMain.size());

pc.setFont(9,1);

pc.addCols("Fecha: "+cdoD.getColValue("fecha"," ")+" "+cdoD.getColValue("hora"," "));
pc.addCols("Usuario: "+cdoD.getColValue("usuario"," "));

if (!cdoD.getColValue("fecha"," ").trim().equals("")) {
  //pc.addCols("Fecha Mod.: "+cdoD.getColValue("fecha_mod"," "));
  //pc.addCols("Usuario: "+cdoD.getColValue("usuario_mod"," "));
}
pc.addCols(" ",2,2);

pc.addBorderCols("Descripcion",1,1);
pc.addBorderCols("Escala",1,1);

al = SQLMgr.getDataList("select h.codigo, h.descripcion, h.tipo from tbl_sal_concepto_norton h where h.tipo = '"+fg+"' and h.estado = 'A' order by h.orden");

pc.setFont(8,0);
for (int i = 0; i<al.size(); i++){
    CommonDataObject cdoH = (CommonDataObject) al.get(i);
    sql = "select a.codigo,a.secuencia, a.descripcion, a.valor, b.tipo_escala, b.detalle, b.observacion from tbl_sal_det_concepto_norton a,tbl_sal_concepto_norton c,  ( select nvl(cod_escala,0) as tipo_escala, detalle, observacion  from tbl_sal_detalle_esc a where id = "+id+" and tipo = '"+fg+"' order by 1 ) b where  a.codigo = b.tipo_escala(+) and b.detalle(+) = a.secuencia and a.tipo = '"+cdoH.getColValue("tipo")+"' and a.codigo =  "+cdoH.getColValue("codigo")+" and a.estado='A' and c.codigo = a.codigo(+) and a.estado(+) = c.estado order by c.orden, a.orden ";

    pc.addBorderCols(cdoH.getColValue("descripcion"),0,1);
    
    ArrayList alP = SQLMgr.getDataList(sql);
    pc.setNoColumnFixWidth(tblDet);
    pc.createTable("tblDet_"+i,false,15, 0.0f, 415f);
    
    for (int p = 0; p < alP.size(); p++){
        CommonDataObject cdoP = (CommonDataObject) alP.get(p);
       
        if (cdoP.getColValue("secuencia").equals(cdoP.getColValue("detalle"))) pc.addCols("[ X ]",0,1);
        else pc.addCols("[    ]",0,1);
        pc.addCols(cdoP.getColValue("descripcion"),0,1);
        if (cdoP.getColValue("secuencia").equals(cdoP.getColValue("detalle")))
            pc.addCols(cdoP.getColValue("valor"),0,1);
        else pc.addCols(" ",0,1);  
        pc.addCols(cdoP.getColValue("observacion"),0,1);
    }

    pc.useTable("main");
    pc.addTableToCols("tblDet_"+i,0,1);

    if (alP.size() == 0) pc.addBorderCols(" ",1,1);
}

pc.setFont(9,1);
pc.addCols("Total: ",2,1);
pc.addCols(""+total,0,1);

if (!intCode.equals("") && !intCode.equals("0")){
    al = SQLMgr.getDataList("select id.cod_intervencion, id.codigo, id.descripcion , id.mostrar_checkbox, decode(ipd.cod_interv_det,null,'N','S') aplicado from tbl_sal_intervencion_det id, tbl_sal_intervencion_pac_det ipd where id.cod_intervencion = "+intCode+" and id.cod_intervencion = ipd.cod_intervencion and id.codigo = ipd.cod_interv_det and ipd.pac_id = "+pacId+" and ipd.admision = "+noAdmision+" and ipd.id_escala = "+id+" and ipd.cod_interv_det is not null and id.tipo = '"+fg+"' and id.tipo = ipd.tipo(+)  order by id.cod_intervencion, id.codigo ");
    
    
    pc.setFont(10,1);
    pc.setVAlignment(0);
    
    pc.addCols(" ",0,tblMain.size());
    pc.addCols("INTERVENCIONES: "+intDesc,0,tblMain.size());
    
    pc.setFont(10,0);
    for (int i = 0; i<al.size(); i++) {
      cdo = (CommonDataObject) al.get(i);
      pc.addCols(cdo.getColValue("descripcion"),0,tblMain.size());
    
    }
    pc.addCols(" ",0,tblMain.size());
    pc.addCols("Observación: "+intObserv,0,tblMain.size());
    
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
