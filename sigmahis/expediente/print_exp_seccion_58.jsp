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
/**
==================================================================================
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

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoPacData = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String id = request.getParameter("id");

if ( id == null || id.equals("")) id = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

cdoUsr.addColValue("usuario",userName);

if(desc == null) desc = "";

//sql = "select pac_id, to_char(fecha_ayuda,'dd/mm/yyyy') fechaAyuda,nvl(observ_ayuda,' ') observacion, usuario_creacion, usuario_modifica, fecha_creacion, fecha_modifica  from tbl_adm_admision where pac_id = "+pacId+" and secuencia =  "+noAdmision;

if(!id.trim().equals("0")){
		sql = "select a.id, a.DESCRIPCION observacion, a.USUARIO_CREACION, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi am') FECHA_CREACION, a.USUARIO_MODIFICACION, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi am') FECHA_MODIFICACION, a.compania from   tbl_sal_atencion_espiritual a where a.pac_id = "+pacId+" and admision = "+noAdmision+" and a.compania = "+compania+" and a.id = "+id+" order by a.FECHA_CREACION desc";
}else{
		sql = "select a.id, a.DESCRIPCION observacion, a.USUARIO_CREACION, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi am') FECHA_CREACION, a.USUARIO_MODIFICACION, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi am') FECHA_MODIFICACION, a.compania from   tbl_sal_atencion_espiritual a where a.pac_id = "+pacId+" and admision = "+noAdmision+" and a.compania = "+compania+" order by a.FECHA_CREACION desc";
}

al = SQLMgr.getDataList(sql);

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

	float width = 72 * 8.5f;//612
	float height = 72 * 14f;//792
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
	String subTitle = desc;
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
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");
		dHeader.addElement("20");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(8,1,Color.white);
		pc.addBorderCols("F. Registro", 1,1,Color.lightGray);
		pc.addBorderCols("Usuario", 1,1,Color.lightGray);
		pc.addBorderCols("F. Modificación", 1,1,Color.lightGray);
		pc.addBorderCols("Usuario", 1,1,Color.lightGray);
		pc.addBorderCols(" ", 1,1,Color.lightGray);

		pc.setTableHeader(2);

		String groupByFechaId = "";

		if ( al.size() == 0 ){
			pc.addCols(".:: No hay Datos ::.",1,dHeader.size());
		}else{

			for ( int a = 0; a<al.size(); a++ ){
				cdo1 = (CommonDataObject)al.get(a);

				pc.setFont(8,1);
				pc.addCols(cdo1.getColValue("fecha_creacion"), 0,1);
				pc.addCols(cdo1.getColValue("usuario_creacion"), 1,1);
				pc.addCols(cdo1.getColValue("fecha_modificacion"), 1,1);
				pc.addCols(cdo1.getColValue("usuario_modificacion"), 1,1);
				pc.addCols("", 1,1);

				pc.setFont(8,0);
				pc.addBorderCols("Observación",0,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
				pc.addCols(cdo1.getColValue("observacion"),0,dHeader.size());

				if ( (a+1) < al.size() ){
					pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",0,dHeader.size(),15f);
				}

			} // for a
		}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>