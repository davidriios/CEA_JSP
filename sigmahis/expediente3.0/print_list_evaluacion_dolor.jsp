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
String fg = request.getParameter("fg");

String customFirstTitle = request.getParameter("custom_first_title");
if (customFirstTitle == null) customFirstTitle = "";
if (fg == null) fg = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(exp == null) exp = "";

StringBuffer sbSql = new StringBuffer();

if (!fg.equalsIgnoreCase("BR") && !fg.equalsIgnoreCase("SG") ) {
    sbSql.append("select to_char(fecha,'dd/mm/yyyy') as fecha_dsp, to_char(hora,'hh12:mi:ss am') as hora, total, localizacion");
    if (fg.equalsIgnoreCase("AN") || fg.equalsIgnoreCase("MM5") || fg.equalsIgnoreCase("CA")) {
      sbSql.append(", join(cursor(select descripcion from tbl_sal_dolor d where estado = 'A' and tipo = z.tipo and exists ((select * from table(split(z.dolor,'|')) where column_value = d.codigo))),', ') as dolor");
      sbSql.append(", join(cursor(select descripcion from tbl_sal_intervencion_dolor d where estado = 'A' and tipo = 'ME' and exists ((select * from table(split(z.intervencion,'|')) where column_value = d.codigo))),', ') as intervencion");
    } else sbSql.append(", dolor, intervencion");
    sbSql.append(", usuario, usuario_mod, to_char(fecha_mod,'hh12:mi:ss am') as horaI, tipo from tbl_sal_escalas z where pac_id = ");
    sbSql.append(pacId);
    sbSql.append(" and admision = ");
    sbSql.append(noAdmision);
    sbSql.append(" and tipo = '");
    sbSql.append(fg);
    sbSql.append("'  order by z.fecha desc, z.hora desc");
	} else {
	  sbSql.append("select to_char(fecha,'dd/mm/yyyy') as fecha_dsp, to_char(hora,'hh12:mi:ss am') as hora, total, '' localizacion, '' dolor, '' intervencion, usuario_creacion as usuario, usuario_modificacion as usuario_mod, to_char(fecha_modificacion,'hh12:mi:ss am') as horaI, tipo from tbl_sal_escala_norton where pac_id = ");
	  sbSql.append(pacId);
    sbSql.append(" and secuencia = ");
    sbSql.append(noAdmision);
    sbSql.append(" and tipo = '");
    sbSql.append(fg);
    sbSql.append("'  order by fecha desc, hora desc");
	}
	al = SQLMgr.getDataList(sbSql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String subtitle = customFirstTitle;
	String xtraSubtitle = desc; //"DEL "+fechaini+" AL "+fechafin;
	
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
		dHeader.addElement("10"); 
		dHeader.addElement("10"); 
		dHeader.addElement("10"); 
		
		dHeader.addElement("10"); 
		dHeader.addElement("20"); 
		
		dHeader.addElement("10"); 
		dHeader.addElement("30"); 
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setTableHeader(1);
		
		pc.setFont(8, 1);
		pc.addBorderCols("Fecha", 1, 1);
		pc.addBorderCols("Hora", 1, 1);
		pc.addBorderCols("Total", 1, 1);
		
		pc.addBorderCols("Localización", 0, 1);
		pc.addBorderCols("Descripción", 0, 1);
		
		pc.addBorderCols("Usuario", 1, 1);
		pc.addBorderCols("Intervención", 0, 1);
		
		pc.setFont(8, 0);
		
		for (int i = 0; i < al.size(); i++) {
		  cdo = (CommonDataObject) al.get(i);
		  
		  pc.addCols(cdo.getColValue("fecha_dsp"), 1, 1);
      pc.addCols(cdo.getColValue("hora"), 1, 1);
      pc.addCols(cdo.getColValue("total"), 1, 1);
      
      pc.addCols(cdo.getColValue("localizacion"), 0, 1);
      pc.addCols(cdo.getColValue("dolor"), 0, 1);
      
      pc.addCols(cdo.getColValue("usuario_mod"), 1, 1);
      pc.addCols(cdo.getColValue("intervencion"), 0, 1);
		}
		
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>