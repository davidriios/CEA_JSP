<%@ page errorPage="../error.jsp"%>
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
/**
==================================================================================
REPORTE:  PROGRESO CLINICO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String desc = request.getParameter("desc");
String code = request.getParameter("code");

if (code == null) code = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

	//COMENTARIOS
	
	sql =  "select a.comentario_id, to_char(a.fecha,'dd/mm/yyyy') fecha,to_char(a.fecha,'hh12:mi am') hora, a.comentario, usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') fecha_creacion, usuario_modificacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi am') fecha_modificacion, decode(estado,'I', 'INVALIDADO', 'VALIDO') estado, necesita_resp from tbl_sal_comentarios a where a.pac_id = "+pacId+" and a.admision = "+noAdmision;
    
    if (!code.trim().equals("") && !code.equals("0")) {
        sql += " and a.comentario_id = "+code;
    }
    sql += " order by a.fecha desc";
	al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 10;
	float cHeight = 12.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector dHeader = new Vector();
    dHeader.addElement(".25");
    dHeader.addElement(".25");
    dHeader.addElement(".25");
    dHeader.addElement(".25");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(fontSize, 1);
	pc.addCols("COMENTARIOS",0,dHeader.size(),Color.lightGray);
  pc.addCols(" ",0,dHeader.size());
	pc.setVAlignment(0);

	for (int i=0; i<al.size(); i++){
      CommonDataObject cdo = (CommonDataObject) al.get(i);
      
      pc.setFont(fontSize, 1);
      pc.addBorderCols("Fecha", 1, 1);
      pc.addBorderCols("Hora", 1, 1);
      pc.addBorderCols(" ", 1, 1);
      pc.addBorderCols("Estado", 1, 1);
      
      pc.setFont(fontSize, 0);
      pc.addBorderCols(cdo.getColValue("fecha"),1,1);
      pc.addBorderCols(cdo.getColValue("hora"),1,1);
      pc.addBorderCols("", 1,1);
      
      if (cdo.getColValue("estado").equalsIgnoreCase("VALIDO")) {
        pc.setFont(fontSize, 1,Color.green);
      } else {
        pc.setFont(fontSize, 1,Color.red);
      }
      pc.addBorderCols(cdo.getColValue("Estado"),1,1);
      
      pc.setFont(fontSize, 0);
      pc.addBorderCols(cdo.getColValue("comentario"),0,4);
      
      if (!cdo.getColValue("necesita_resp", " ").trim().equals("")) {
          ArrayList alR = SQLMgr.getDataList("select codigo, comentario_id, respuesta, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion from TBL_SAL_COMENTARIO_REP where comentario_id = " + cdo.getColValue("comentario_id")+" order by fecha_creacion desc");
          
          if (alR.size() > 0) {
            pc.setFont(fontSize, 1);
            pc.addBorderCols("Respuesta",0,4);
            pc.setFont(fontSize, 0);
        
            for (int r = 0; r < alR.size(); r++) {
              CommonDataObject cdoR = (CommonDataObject) alR.get(r);
              
              pc.addBorderCols("["+cdoR.getColValue("usuario_creacion", " ") + " - "+ cdoR.getColValue("fecha_creacion", " ") + "]     " +  cdoR.getColValue("respuesta", " "), 0,4);
            }//for
          }
      }
      
      pc.setFont(8, 3);
      pc.addBorderCols("Creado por: "+cdo.getColValue("usuario_creacion"),0,2);
      pc.addBorderCols("Creado el: "+cdo.getColValue("fecha_creacion"),0,2);
      
      if (!cdo.getColValue("usuario_modificacion"," ").trim().equals("")) {
          pc.addBorderCols("Modificado por: "+cdo.getColValue("usuario_modificacion"),0,2);
          pc.addBorderCols("Modificado el: "+cdo.getColValue("fecha_modificacion"),0,2);
      }
      
      pc.addCols(" ",0,dHeader.size());
      pc.addCols(" ",0,dHeader.size());
	}
	

  if ( al.size() == 0 ){
      pc.addCols("No hemos encontrado datos!",1,dHeader.size());
  }

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>