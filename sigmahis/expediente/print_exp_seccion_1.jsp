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
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String exp = request.getParameter("exp");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if(desc == null) desc = "";
if(exp == null) exp = "";

sql = "select to_char(FECHA,'dd/mm/yyyy') as FECHA, to_char(HORA, 'hh12:mi:ss am') as HORA, OBSERVACION, DOLENCIA_PRINCIPAL, MOTIVO_HOSPITALIZACION, ALERGICO_A, to_char(HORA,'hh12:mi:ss am') AS HORA, usuario_creacion, usuario_modificacion from TBL_SAL_PADECIMIENTO_ADMISION where pac_id="+pacId+" and secuencia="+noAdmision;

cdo = SQLMgr.getData(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String subtitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
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
	
	//------------------------------------------------------------------------------------
      pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement("30"); 
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("30");
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setTableHeader(1);
		
		if ( cdo == null ) cdo = new CommonDataObject();

		pc.setFont(8, 1);
		pc.addCols("Fecha: "+(cdo.getColValue("FECHA")==null?"":cdo.getColValue("FECHA")), 0, 1,15.2f);
		pc.addCols("Hora: "+(cdo.getColValue("HORA")==null?"":cdo.getColValue("HORA")), 0, 1,15.2f);
		pc.addCols("Usuario: "+cdo.getColValue("usuario_creacion")+"/"+cdo.getColValue("usuario_modificacion"),1,2, 20.2f);
		
		pc.addCols("",0,dHeader.size(), 10.2f);
		
		pc.setFont(8, 1,Color.white);
		pc.addCols("Motivo de la consulta", 0, dHeader.size(),Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("DOLENCIA_PRINCIPAL"), 0, dHeader.size());
		
		pc.addCols("",0,dHeader.size(), 20.2f);
		
		pc.setFont(8, 1,Color.white);
		pc.addCols("Historia de la Enfermedad Actual (inicio, síntomas, asistencia médica, hospitalización)", 0, dHeader.size(),Color.gray);
		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("observacion"), 0, dHeader.size());
		
        if (exp.equals("")){
			pc.addCols("",0,dHeader.size(), 20.2f);
			
			pc.setFont(8, 1,Color.white);
			pc.addCols("Motivo de la Hospitalización", 0, dHeader.size(),Color.gray);
			pc.setFont(8, 0);
			pc.addBorderCols(cdo.getColValue("MOTIVO_HOSPITALIZACION"), 0, dHeader.size());
        
			if (!cdo.getColValue("ALERGICO_A"," ").trim().equals("")) {
				
				pc.addCols("",0,dHeader.size(), 20.2f);
				
				pc.setFont(8, 1,Color.white);
				pc.addCols("Alérgico a", 0, dHeader.size(),Color.gray);
				pc.setFont(8, 0);
				pc.addBorderCols(cdo.getColValue("ALERGICO_A"), 0, dHeader.size());
			}
        }
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>