<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String condTitle = request.getParameter("cond_title");
String condicion = request.getParameter("condicion");
String diags = request.getParameter("diags");
String code = request.getParameter("code");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(condTitle == null) condTitle = "";
if(condicion == null) condicion = "";
if(code == null || code.trim().equals("")) code = "0";
if(diags == null) diags = "";

if (!code.equals("0") && condicion.trim().equals("")) throw new Exception("No pudimos encontrar el plan!");

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
float leftRightMargin = 10.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = !desc.equals("")?desc:"PLAN DE CUIDADO";
String xtraSubtitle = !condTitle.trim().equalsIgnoreCase("") ? condTitle : "";

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

Vector tblContainer = new Vector();
tblContainer.addElement("19");
tblContainer.addElement("19");
tblContainer.addElement("19");
tblContainer.addElement("19");
tblContainer.addElement("12");
tblContainer.addElement("12");

Vector tblMot = new Vector();
tblMot.addElement("6");
tblMot.addElement("94");

Vector tblMet = new Vector();
tblMet.addElement("6");
tblMet.addElement("94");

Vector tblNec = new Vector();
tblNec.addElement("6");
tblNec.addElement("94");

Vector tblInt = new Vector();
tblInt.addElement("6");
tblInt.addElement("94");

Vector tblReev = new Vector();
tblReev.addElement("6");
tblReev.addElement("94");
//

pc.setNoColumnFixWidth(tblContainer);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblContainer.size());
pc.setTableHeader(1);

double detTblWidth = 187.72;//198


sbSql.append("select id, nvl(cod_condicion,' ') as cod_condicion, nvl(cod_diag,' ') as cod_diag, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fc, to_char(fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') as freeval, to_char(fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') as fresol, usuario_creacion, usuario_modificacion from tbl_sal_plan_cuidado where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);
if (!code.equals("0")) {
	sbSql.append(" and id = ");
	sbSql.append(code);
}
sbSql.append(" order by id");
ArrayList al = SQLMgr.getDataList(sbSql.toString());
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdoH = (CommonDataObject) al.get(i);
	if (code.equals("0")) {
		condicion = cdoH.getColValue("cod_condicion");
		diags = cdoH.getColValue("cod_diag");
	}

	sbSql = new StringBuffer();
	sbSql.append("select d.codigo, d.codigo_condicion, d.descripcion, c.descripcion as plann, (select observ_otro from tbl_sal_plan_cuidado_det where cod_plan = ");
	sbSql.append(cdoH.getColValue("id"));
	sbSql.append(" and pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and cod_diag = d.codigo and rownum = 1) as observ_otro, (select observ_reeval from tbl_sal_plan_cuidado_det where cod_plan = ");
	sbSql.append(cdoH.getColValue("id"));
	sbSql.append(" and pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and cod_diag = d.codigo and rownum = 1) as observ_reeval, (select observ_resol from tbl_sal_plan_cuidado_det where cod_plan = ");
	sbSql.append(cdoH.getColValue("id"));
	sbSql.append(" and pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and cod_diag = d.codigo and rownum = 1) as observ_resol from tbl_sal_soapier_diagnosticos d, tbl_sal_soapier_condicion c where d.estado = 'A' and c.codigo = d.codigo_condicion and d.codigo_condicion");
	if (condicion.trim().equals("")) sbSql.append(" is null");
	else {
		sbSql.append(" in (");
		sbSql.append(condicion);
		sbSql.append(")");
	}
	sbSql.append(" and d.codigo");
	if (diags.trim().equals("")) sbSql.append(" is null");
	else {
		sbSql.append(" in (");
		sbSql.append(diags);
		sbSql.append(")");
	}
	sbSql.append(" order by 1");
	ArrayList alDiags = SQLMgr.getDataList(sbSql.toString());


//CommonDataObject cdoH = SQLMgr.getData("select to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc, to_char(fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') freeval,to_char(fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fresol, usuario_creacion, usuario_modificacion from tbl_sal_plan_cuidado where pac_id = "+pacId+" and admision = "+noAdmision+" and id = "+code);

//ArrayList alDiags = SQLMgr.getDataList("select d.codigo, d.codigo_condicion, d.descripcion, c.descripcion as plann, (select observ_otro from tbl_sal_plan_cuidado_det where cod_plan = "+code+" and pac_id = "+pacId+" and admision = "+noAdmision+" and cod_diag = d.codigo and rownum = 1) as observ_otro, (select observ_reeval from tbl_sal_plan_cuidado_det where cod_plan = "+code+" and pac_id = "+pacId+" and admision = "+noAdmision+" and cod_diag = d.codigo and rownum = 1) as observ_reeval from tbl_sal_soapier_diagnosticos d, tbl_sal_soapier_condicion c where d.estado = 'A' and c.codigo = d.codigo_condicion and d.codigo_condicion in("+condicion+") and d.codigo in("+diags+") order by 1");

pc.setFont(13,1);
pc.addCols("Fecha: "+cdoH.getColValue("fc"),0,2);
pc.addCols("Usuario: "+cdoH.getColValue("usuario_creacion"),0,tblContainer.size() - 3);
pc.addCols("#"+cdoH.getColValue("id"),2,1);
pc.addCols("Fecha Reevaluación: "+cdoH.getColValue("freeval"),0,2);
pc.addCols("Por: "+cdoH.getColValue("usuario_modificacion"),0,tblContainer.size() - 2);
pc.addCols("Fecha Resolución: "+cdoH.getColValue("fresol"),0,2);
pc.addCols("Por: "+cdoH.getColValue("usuario_modificacion"),0,tblContainer.size() - 2);
pc.addCols(" ",0,tblContainer.size());

String reeval = "", resol = "";

for (int d = 0; d < alDiags.size(); d++) {

  CommonDataObject cdoDiag = (CommonDataObject) alDiags.get(d);
  if (d > 0) {
    pc.flushTableBody(true);
    //pc.addNewPage();
  }
    
	pc.setFont(13,1);
	pc.addCols(cdoDiag.getColValue("descripcion")+" ("+cdoDiag.getColValue("plann")+") ",0,tblContainer.size(), Color.lightGray);
  
  pc.setFont(12,1);
  pc.addBorderCols("MOTIVOS / CAUSAS",1,1);
  pc.addBorderCols("META MEDIBLE",1,1);
  pc.addBorderCols("NECESIDADES ALTERADAS",1,1);
  pc.addBorderCols("INTERVENCIONES",1,1);
  pc.addBorderCols("REEVALUACIÓN",1,2);
  
  ArrayList alMot = SQLMgr.getDataList("select a.codigo, a.descripcion, a.status, a.codigo_condicion, a.cod_diag, a.tipo, b.observ_otro, b.observ_reeval, b.observ_resol, to_char(c.fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') fecha_reeval, to_char(c.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_resol , (select join( cursor ( select distinct cod_param from tbl_sal_plan_cuidado_det aa where aa.cod_diag = b.cod_diag and aa.tipo = b.tipo and pac_id = b.pac_id and admision = b.admision and cod_plan = b.cod_plan  )  , ',') from dual) as tmp_diag from tbl_sal_soapier_cond_detalle a, tbl_sal_plan_cuidado_det b, tbl_sal_plan_cuidado c where c.id = b.cod_plan and b.pac_id = c.pac_id and b.admision = c.admision and a.codigo_condicion in ("+condicion+") and a.tipo = 'MOT' and a.cod_diag in("+cdoDiag.getColValue("codigo")+") and a.status = 'A' and b.tipo = a.tipo and b.cod_diag = a.cod_diag and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.cod_param and b.cod_plan = "+cdoH.getColValue("id"));
  
  ArrayList alMet = SQLMgr.getDataList("select a.codigo, a.descripcion, a.status, a.codigo_condicion, a.cod_diag, a.tipo, b.observ_otro, b.observ_reeval, b.observ_resol, to_char(c.fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') fecha_reeval, to_char(c.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_resol , (select join( cursor ( select distinct cod_param from tbl_sal_plan_cuidado_det aa where aa.cod_diag = b.cod_diag and aa.tipo = b.tipo and pac_id = b.pac_id and admision = b.admision and cod_plan = b.cod_plan  )  , ',') from dual) as tmp_diag from tbl_sal_soapier_cond_detalle a, tbl_sal_plan_cuidado_det b, tbl_sal_plan_cuidado c where c.id = b.cod_plan and b.pac_id = c.pac_id and b.admision = c.admision and a.codigo_condicion in ("+condicion+") and a.tipo = 'MET' and a.cod_diag in("+cdoDiag.getColValue("codigo")+") and a.status = 'A' and b.tipo = a.tipo and b.cod_diag = a.cod_diag and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.cod_param and b.cod_plan = "+cdoH.getColValue("id"));
  
  ArrayList alNec = SQLMgr.getDataList("select a.codigo, a.descripcion, a.status, a.codigo_condicion, a.cod_diag, a.tipo, b.observ_otro, b.observ_reeval, b.observ_resol, to_char(c.fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') fecha_reeval, to_char(c.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_resol , (select join( cursor ( select distinct cod_param from tbl_sal_plan_cuidado_det aa where aa.cod_diag = b.cod_diag and aa.tipo = b.tipo and pac_id = b.pac_id and admision = b.admision and cod_plan = b.cod_plan  )  , ',') from dual) as tmp_diag from tbl_sal_soapier_cond_detalle a, tbl_sal_plan_cuidado_det b, tbl_sal_plan_cuidado c where c.id = b.cod_plan and b.pac_id = c.pac_id and b.admision = c.admision and a.codigo_condicion in ("+condicion+") and a.tipo = 'NEC' and a.cod_diag in("+cdoDiag.getColValue("codigo")+") and a.status = 'A' and b.tipo = a.tipo and b.cod_diag = a.cod_diag and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.cod_param and b.cod_plan = "+cdoH.getColValue("id"));
  
  ArrayList alInt = SQLMgr.getDataList("select a.codigo, a.descripcion, a.status, a.codigo_condicion, a.cod_diag, a.tipo, b.observ_otro, b.observ_reeval, b.observ_resol, to_char(c.fecha_reevaluacion,'dd/mm/yyyy hh12:mi:ss am') fecha_reeval, to_char(c.fecha_resolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_resol , (select join( cursor ( select distinct cod_param from tbl_sal_plan_cuidado_det aa where aa.cod_diag = b.cod_diag and aa.tipo = b.tipo and pac_id = b.pac_id and admision = b.admision and cod_plan = b.cod_plan  )  , ',') from dual) as tmp_diag from tbl_sal_soapier_cond_detalle a, tbl_sal_plan_cuidado_det b, tbl_sal_plan_cuidado c where c.id = b.cod_plan and b.pac_id = c.pac_id and b.admision = c.admision and a.codigo_condicion in ("+condicion+") and a.tipo = 'INT' and a.cod_diag in("+cdoDiag.getColValue("codigo")+") and a.status = 'A' and b.tipo = a.tipo and b.cod_diag = a.cod_diag and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.cod_param and b.cod_plan = "+cdoH.getColValue("id"));
  
  //Motivos
  for (int m = 0; m<alMot.size(); m++) {
    CommonDataObject cdoMot = (CommonDataObject) alMot.get(m);
    if (m == 0) {
      pc.setNoColumnFixWidth(tblMot);
      pc.createTable("tblMot",false,15, 0.0f, (float)detTblWidth);
    }
    pc.setFont(11,0);
    pc.addImageCols(ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png",10,0);
    pc.addCols(cdoMot.getColValue("descripcion"),0,1);
    
    if ( (m+1) == alMot.size() ) {
    
        pc.addImageCols( (!cdoMot.getColValue("observ_otro"," ").trim().equals(""))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Otros",0,1);
        
        pc.addCols(cdoMot.getColValue("observ_otro"),0,tblMot.size(), 20f);
        
        pc.useTable("main");
        //String tableName, int hAlign, int colSpan, float height, Color backgroundColor
		pc.addTableToCols("tblMot",0,1,0);
        pc.setFont(12,1);
    }
  } // motivos
  
  if (alMot.size() == 0) {
    pc.addBorderCols(" ",0,1, 50f);
  }
  
  //Metas
  for (int m = 0; m<alMet.size(); m++) {
    CommonDataObject cdoMet = (CommonDataObject) alMet.get(m);
    if (m == 0) {
      pc.setNoColumnFixWidth(tblMet);
      //String tableName, boolean splitRowOnEndPage, int showBorder, float margin
      pc.createTable("tblMet",false,15, 0.0f, (float)detTblWidth);
    }
    
    pc.setFont(11,0);
    pc.addImageCols(ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png",10,0);
    pc.addCols(cdoMet.getColValue("descripcion"),0,1);
    
    if ( (m+1) == alMet.size() ) {
    
        pc.addImageCols( (!cdoMet.getColValue("observ_otro"," ").trim().equals(""))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Otros",0,1);
        
        pc.addCols(cdoMet.getColValue("observ_otro"," "),0,tblMet.size(), 20f);
        
        pc.useTable("main");
		pc.addTableToCols("tblMet",0,1,0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
    }
  } // Metas
  
  if (alMet.size() == 0) {
    pc.addBorderCols(" ",0,1, 50f);
  }
  
  
  //Necesidades
  for (int m = 0; m<alNec.size(); m++) {
    CommonDataObject cdoNec = (CommonDataObject) alNec.get(m);
    if (m == 0) {
      pc.setNoColumnFixWidth(tblNec);
      //String tableName, boolean splitRowOnEndPage, int showBorder, float margin
      pc.createTable("tblNec",false,15, 0.0f, (float)detTblWidth);
    }
    
    pc.setFont(11,0);
    pc.addImageCols(ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png",10,0);
    pc.addCols(cdoNec.getColValue("descripcion"),0,1);
    
    if ( (m+1) == alNec.size() ) {
    
        pc.addImageCols( (!cdoNec.getColValue("observ_otro"," ").trim().equals(""))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Otros",0,1);
        
        pc.addCols(cdoNec.getColValue("observ_otro"," "),0,tblNec.size(), 20f);
        
        pc.useTable("main");
		pc.addTableToCols("tblNec",0,1,0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
    }
  } // Necesidades
  if (alNec.size() == 0) {
    pc.addBorderCols(" ",0,1, 50f);
  }
  
  ArrayList alOI = SQLMgr.getDataList("select b.codigo, a.descripcion from tbl_sal_otras_interv_params a, tbl_sal_otras_interv b where a.codigo = b.cod_param and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_plan = "+cdoH.getColValue("id")+" and cod_diag = "+cdoDiag.getColValue("codigo")+" order by b.codigo");
  
  //Intervenciones
  for (int m = 0; m<alInt.size(); m++) {
    CommonDataObject cdoInt = (CommonDataObject) alInt.get(m);
    if (m == 0) {
      pc.setNoColumnFixWidth(tblInt);
      //String tableName, boolean splitRowOnEndPage, int showBorder, float margin
      pc.createTable("tblInt",false,15, 0.0f, (float)detTblWidth);
    }
    
    pc.setFont(11,0);
    pc.addImageCols(ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png",10,0);
    pc.addCols(cdoInt.getColValue("descripcion"),0,1);
    
    if ( (m+1) == alInt.size() ) {
    
        pc.addImageCols( (!cdoInt.getColValue("observ_otro"," ").trim().equals(""))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
        pc.addCols("Otros",0,1);
        
        pc.addCols(cdoInt.getColValue("observ_otro"," "),0,tblInt.size(), 20f);
        
        if (alOI.size() > 0) {
            for (int o = 0; o < alOI.size(); o++) {
                CommonDataObject cdoO = (CommonDataObject) alOI.get(o);
                if (o == 0) {
                    pc.setFont(11,1);
                    pc.addBorderCols("OTRAS INTERVENCIONES",1,tblInt.size());
                }
                pc.setFont(11,0);
                pc.addBorderCols(cdoO.getColValue("descripcion"),0,tblInt.size());
            }
        }
        
        pc.useTable("main");
		pc.addTableToCols("tblInt",0,1,0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
    }
  } // Intervenciones
  if (alInt.size() == 0) {
    pc.addBorderCols(" ",0,1, 50f);
  }
  
  ArrayList alR = SQLMgr.getDataList("select codigo, reevaluacion from tbl_sal_otras_reeval where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_diag = "+cdoDiag.getColValue("codigo")+" and cod_plan = "+cdoH.getColValue("id"));
  
  pc.addBorderCols(cdoDiag.getColValue("observ_reeval"," ") ,0,2);
  //pc.addBorderCols(cdoDiag.getColValue("observ_resol",">>"),0,1);
  
  if (alR.size() > 0) {
    for (int r = 0; r < alR.size(); r++){
        CommonDataObject cdoR = (CommonDataObject) alR.get(r);
        if (r == 0) {
            pc.setFont(11,1);
            pc.addCols("", 0, 4);
            pc.addBorderCols("OTRAS REEVALUACIONES", 0, 2);
        }
        pc.setFont(11,0);
        pc.addCols("", 0, 4);
        pc.addBorderCols(cdoR.getColValue("reevaluacion"), 0, 2);
    }
  }

}
pc.flushTableBody(true);
pc.addNewPage();

}

if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>