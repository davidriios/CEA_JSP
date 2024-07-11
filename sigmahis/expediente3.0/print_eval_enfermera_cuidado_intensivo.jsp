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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
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
String code = request.getParameter("code");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(code == null) code = "0";

boolean contigengia = code.trim().equals("0");

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
String subTitle = !desc.equals("")?desc:"EVALUACION DIARIA DE ENFERMERIA UCI";
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

sbSql.append("select usuario_creacion, to_char(fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fecha_creacion from tbl_sal_notas_cuidado_inten where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);
sbSql.append(" and codigo = ");
sbSql.append(code);
System.out.println("----------------------->"+sbSql);
cdo = SQLMgr.getData(sbSql.toString());

ArrayList alAreas = SQLMgr.getDataList("select a.codigo area, a.descripcion desc_area from tbl_sal_areas_cuid_intensivo a where a.estado = 'A' order by a.codigo");

Vector tblContainer = new Vector();
tblContainer.addElement("30");
tblContainer.addElement("70");

Vector tblDet = new Vector();
tblDet.addElement("2");
tblDet.addElement("24");
tblDet.addElement("2");
tblDet.addElement("42");
tblDet.addElement("30");

Vector tblCaract = new Vector();
tblCaract.addElement("4");
tblCaract.addElement("58");
tblCaract.addElement("38");

pc.setNoColumnFixWidth(tblContainer);
pc.createTable();
    
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblContainer.size());
pc.addCols("Registrado por: "+cdo.getColValue("usuario_creacion"));
pc.addCols("Fecha/Hora: "+cdo.getColValue("fecha_creacion"));
pc.setTableHeader(2);

int detTblWidth = 680;

pc.setFont(13,1);

contigengia = true; 

for (int a = 0; a < alAreas.size(); a++) {
    CommonDataObject cdoA = (CommonDataObject) alAreas.get(a);
   
   if (a > 0 && (a%6)==0 ) {
        //pc.flushTableBody(true);
        //pc.addNewPage();
    }
    pc.addBorderCols(cdoA.getColValue("desc_area"),0,1);
    
    ArrayList alGrupos = SQLMgr.getDataList("select g.codigo cod_grupo, g.descripcion as desc_grupo, g.cod_area from tbl_sal_areas_cuid_inten_grupo g where g.cod_area = "+cdoA.getColValue("area")+" order by g.codigo");
    
    for (int g = 0; g<alGrupos.size(); g++) {
       CommonDataObject cdoG = (CommonDataObject) alGrupos.get(g);
       
       ArrayList alCaract = SQLMgr.getDataList("select c.codigo cod_caract, c.cod_area, c.descripcion desc_caract, c.cod_area_grupo, decode(det.observacion,null,'N','S') marcado, c.mostrar_observ, det.observacion from tbl_sal_caract_areas_cuid_int c,(select cid.cod_nota, cid.codigo_caract, cid.cod_area, ci.condicion, nvl(cid.obsercacion,'N/A') as observacion from tbl_sal_notas_cuidado_inten ci, tbl_sal_notas_cuidad_inten_det cid where ci.pac_id = "+pacId+" and ci.admision = "+noAdmision+" and ci.codigo = cid.cod_nota and ci.pac_id = cid.pac_id and ci.admision = cid.admision) det where c.cod_area = "+cdoA.getColValue("area")+" and c.cod_area_grupo = "+cdoG.getColValue("cod_grupo")+(contigengia?" and det.codigo_caract(+) = c.codigo and det.cod_area(+) = c.cod_area and det.cod_nota(+) = "+code:" and det.codigo_caract = c.codigo and det.cod_area = c.cod_area and det.cod_nota = "+code)+" order by c.cod_area, c.codigo ");

       if (g == 0) {
          pc.setNoColumnFixWidth(tblDet);
          pc.createTable("tblGrupo",false,15, 0.0f, (float)detTblWidth);
       }
       
       pc.setVAlignment(1);
       pc.addBorderCols(cdoG.getColValue("desc_grupo"),0, 2);
       
       //pc.addBorderCols("CARACTS",0, 3);
       
       for (int c = 0; c < alCaract.size(); c++) {
            CommonDataObject cdoC = (CommonDataObject) alCaract.get(c);
            String observacion = cdoC.getColValue("observacion") != null && !cdoC.getColValue("observacion").trim().equals("") ? cdoC.getColValue("observacion") : "";
            
            if ( c == 0) {
                pc.setNoColumnFixWidth(tblCaract);
                pc.createTable("tblCaract",false,15, 0.0f, 504f);
            }
			if(cdoC.getColValue("marcado")!=null && cdoC.getColValue("marcado").equalsIgnoreCase("S")){
				pc.addImageCols( (cdoC.getColValue("marcado")!=null && cdoC.getColValue("marcado").equalsIgnoreCase("S"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,1);
                pc.addBorderCols(cdoC.getColValue("desc_caract"),0,1);
				
				if(cdoC.getColValue("mostrar_observ")!=null && cdoC.getColValue("mostrar_observ").equalsIgnoreCase("S")){
					pc.addBorderCols(observacion,0, 1);
				} else pc.addBorderCols(" ",0, 1, 30f);
			}
            
            if ( (c+1) == alCaract.size() ) {
              pc.useTable("tblGrupo");
              pc.addTableToCols("tblCaract",0,3,0);
            }
       }
       
       if ( (g+1) == alGrupos.size() ) {
          pc.useTable("main");
          pc.addTableToCols("tblGrupo",0,1,0);
       }
       
    } // grupo
    
    if (alGrupos.size() == 0) {
        
        ArrayList alCaract = SQLMgr.getDataList("select c.codigo cod_caract, c.cod_area, c.descripcion desc_caract, c.cod_area_grupo, decode(det.observacion,null,'N','S') marcado, c.mostrar_observ, det.observacion from tbl_sal_caract_areas_cuid_int c,(select cid.cod_nota, cid.codigo_caract, cid.cod_area, ci.condicion, nvl(cid.obsercacion,'N/A') as observacion from tbl_sal_notas_cuidado_inten ci, tbl_sal_notas_cuidad_inten_det cid where ci.pac_id = "+pacId+" and ci.admision = "+noAdmision+" and ci.codigo = cid.cod_nota and ci.pac_id = cid.pac_id and ci.admision = cid.admision) det where c.cod_area_grupo is null and c.cod_area = "+cdoA.getColValue("area")+(contigengia?" and det.codigo_caract(+) = c.codigo and det.cod_area(+) = c.cod_area and det.cod_nota(+) = "+code:" and det.codigo_caract = c.codigo and det.cod_area = c.cod_area and det.cod_nota = "+code)+" order by c.cod_area, c.codigo");
        
        pc.setVAlignment(1);
        
        for (int c = 0; c < alCaract.size(); c++) {
            CommonDataObject cdoC = (CommonDataObject) alCaract.get(c);
            
            if ( c == 0) {
                pc.setNoColumnFixWidth(tblDet);
                pc.createTable("tblCaractNoGrupo",false,15, 0.0f, (float)detTblWidth);
            }
            pc.setFont(11,0);
			if(cdoC.getColValue("marcado")!=null && cdoC.getColValue("marcado").equalsIgnoreCase("S")) {
				pc.addImageCols( (cdoC.getColValue("marcado")!=null && cdoC.getColValue("marcado").equalsIgnoreCase("S"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                //pc.addBorderCols(" ",0,1);
				pc.addBorderCols(" "+cdoC.getColValue("desc_caract"),0,2);
				
				if(cdoC.getColValue("mostrar_observ")!=null && cdoC.getColValue("mostrar_observ").equalsIgnoreCase("S") ){
					pc.addBorderCols(cdoC.getColValue("observacion"),0,2);               
				} else pc.addBorderCols(" ",0,2, 30f);
			}
            
            if ( (c+1) == alCaract.size() ) {
              pc.useTable("main");
              pc.addTableToCols("tblCaractNoGrupo",0,1,0);
            }
       }
    } // no grupo

    
    
    
}








pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>