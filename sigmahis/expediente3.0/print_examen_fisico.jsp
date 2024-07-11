<%@ page errorPage="../error.jsp"%>
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

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData = new CommonDataObject();
String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String userId   = UserDet.getUserId();
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String compania = (String) session.getAttribute("_companyId");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);
cdoUsr.addColValue("usuario",userName);

sql = "select * from (select a.orden, c.sec_orden, a.codigo as codArea, 0 as codCarac, a.descripcion as areaDesc, nvl(b.normal,' ') as status, nvl(b.observaciones,' ') as areaObservacion from tbl_sal_examen_areas_corp a,(select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c  where a.codigo=b.cod_area(+) and a.codigo = c.cod_area  and c.centro_servicio ="+cds+" and a.usado_por in('T','M') union select a.orden, c.sec_orden, a.cod_area_corp, a.codigo, a.descripcion, nvl(b.seleccionar,' '), nvl(b.observacion,' ') from tbl_sal_caract_areas_corp a, (select seleccionar, cod_area_corp, observacion, cod_caract_corp from tbl_sal_prueba_fisica where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c where a.cod_area_corp=b.cod_area_corp(+) and a.codigo=b.cod_caract_corp(+) and a.cod_area_corp = c.cod_area and c.centro_servicio ="+cds+" and a.codigo in (select distinct cod_caract from tbl_sal_caract_area_corp_x_cds where cod_area=a.cod_area_corp and centro_servicio="+cds+") and a.usado_por in('T','M') ) order by 2,3,4";

al = SQLMgr.getDataList(sql);

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String year=fecha.substring(6, 10);
String mon=fecha.substring(3, 5);
String month = null;
String day=fecha.substring(0, 2);
	
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
float leftRightMargin = 30.0f;
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

String noEvaluado="", normal="", anormal="", si="", no="", area="";
    
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
if(pc==null){
    pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
    isUnifiedExp=true;
}

String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";

Vector dHeader = new Vector();
dHeader.addElement("25"); //area
dHeader.addElement("8"); //NE 10
dHeader.addElement("8");//normal 10 
dHeader.addElement("10"); //anomral 10
dHeader.addElement("30"); //caracteristica
dHeader.addElement("5"); //si 
dHeader.addElement("5"); //no
dHeader.addElement("35"); //observacion

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

pc.addCols("",0,dHeader.size(), 10.2f);
pc.setFont(8, 1);

pc.addCols("",0,8);
pc.addBorderCols("Area",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("N/E",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Normal",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Anormal",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Característica",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("SI",1,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("NO",1,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Observación",1,1, 0.8f, 0.8f, 0.8f, 0.8f);
		
pc.setTableHeader(4);

if(al.size() < 1){
    pc.addCols("No encontramos resultados", 1, dHeader.size());
}else{

    for(int i = 0; i<al.size(); i++){
    
        cdo = (CommonDataObject) al.get(i);

        if(cdo.getColValue("status").equals("")){
            noEvaluado = "x";
            normal = "";
            anormal = "";
            si= "";
            no= "";
        }
            
        if(cdo.getColValue("status").trim().equalsIgnoreCase("N")){
            noEvaluado = "";
            normal = "x";
            anormal = "";
            si= "";
            no= "";
        }
        
        if(cdo.getColValue("status").trim().equalsIgnoreCase("A")){
            noEvaluado = "";
            normal = "";
            anormal = "x";
            si= "";
            no= "";
        }
        pc.setFont(7, 0);

        if(cdo.getColValue("codCarac").equals("0")) {
            pc.addBorderCols(cdo.getColValue("areaDesc"),0,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(noEvaluado,1,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(normal,1,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(anormal,1,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);	
            pc.addBorderCols(""+cdo.getColValue("areaObservacion"),0,1,0.5f,0.0f,0.0f,0.0f);
        }
        
        if (area.equals(cdo.getColValue("codArea"))){
            
            ArrayList alSubDet = SQLMgr.getDataList("select a.codigo, a.descripcion, d.seleccionar sub_status, d.observacion from tbl_sal_sub_carat_areas_corp a, tbl_sal_prueba_fisica_det d where d.cod_area_corp(+) = a.cod_area_corp and d.cod_sub_caract(+) = a.codigo and d.cod_caract_corp(+) = a.cod_caract and d.pac_id(+) = "+pacId+" and d.admision(+) = "+noAdmision+" and a.cod_area_corp = "+cdo.getColValue("codArea")+" and a.cod_caract = "+cdo.getColValue("codCarac")+" order by a.orden ");
                
            if(cdo.getColValue("status").trim().equalsIgnoreCase("S") ){
                si = "x";
                no = "";
            }else{
                si= "";
                no = "x";
            }
            
            pc.setFont(8, 1);
            pc.addCols(" ",0,1);
            pc.addCols("",0,1);
            pc.addCols("",0,1);
            pc.addCols("",0,1);
            pc.addBorderCols(cdo.getColValue("areaDesc"),0,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(si,1,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(no,1,1,0.5f,0.0f,0.0f,0.0f);
            pc.addBorderCols(cdo.getColValue("areaObservacion"),0,1,0.5f,0.0f,0.0f,0.0f);
            
            for (int d = 0; d < alSubDet.size(); d++){
                CommonDataObject cdoD = (CommonDataObject) alSubDet.get(d);
                pc.setFont(7,0);
                pc.addCols(" ",0,4);
                pc.addBorderCols("       "+cdoD.getColValue("descripcion"),0,1);
                pc.addBorderCols(cdoD.getColValue("sub_status")!=null&&cdoD.getColValue("sub_status").trim().equalsIgnoreCase("S")?"x":"",1,1);
                pc.addBorderCols(cdoD.getColValue("sub_status")!=null&&cdoD.getColValue("sub_status").trim().equalsIgnoreCase("N")?"x":"",1,1);
                pc.addBorderCols("       "+cdoD.getColValue("observacion"),0,1);
                
            }
            
            
            
            
            
            
        }
         
        area = cdo.getColValue("codArea");
    }//end for

}//else

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);
}
%>
