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

CommonDataObject cdoPacData  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String codigo = request.getParameter("code");
String fg = request.getParameter("fg");

StringBuffer sbSql = new StringBuffer();
cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(codigo == null) codigo = "";
if(fg == null) fg = "S";

sbSql.append("select to_char(fecha_inicio, 'dd/mm/yy') fecha_inicio, to_char(fecha_retiro, 'dd/mm/yy') fecha_retiro,tipo_aislamiento, diagnosticos, app_cirugias, cultivos_fuente, antibioticos, motivos_aislamiento, observaciones, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi am') fecha_modificacion, usuario_creacion, usuario_modificacion from tbl_sal_nota_ctrl_infecciones where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and admision = ");
sbSql.append(noAdmision);

if (!codigo.trim().equals("") && !codigo.trim().equals("0")){
    sbSql.append(" and codigo = ");
    sbSql.append(codigo);
} else {
    sbSql.append(" order by codigo desc");
}

al = SQLMgr.getDataList(sbSql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

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
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subTitle = !desc.trim().equals("") ? desc : "NOTAS CONTROL DE INFECCIONES Y EPIDEMIOLOGÍA HOSPITALARIA";
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
    cdoPacData.addColValue("is_landscape",""+isLandscape);}


	//------------------------------------------------------------------------------------

    //PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

    PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
      
	if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);isUnifiedExp=true;}

		Vector dHeader = new Vector();
		dHeader.addElement("13");
		dHeader.addElement("5");
		dHeader.addElement("5");
		dHeader.addElement("13");
		dHeader.addElement("12");
		dHeader.addElement("13");
		dHeader.addElement("13");
		dHeader.addElement("13");
		dHeader.addElement("13");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		for (int i=0; i<al.size(); i++)
		{
            CommonDataObject cdo = (CommonDataObject) al.get(i);
            
			pc.setFont(8,1);
            
            if (i > 0) {
                pc.addCols(" ", 0,dHeader.size());
            }
            
            pc.addCols("# "+(i+1), 0,dHeader.size());
            
            pc.addBorderCols("Registrada el: "+cdo.getColValue("fecha_creacion"," "), 0,4);
            pc.addBorderCols("Registrada por: "+cdo.getColValue("usuario_creacion"," "), 0,5);
            //pc.addBorderCols("Modificada el: "+cdo.getColValue("fecha_modificacion"," "), 0,4);
            //pc.addBorderCols("Modificada por: "+cdo.getColValue("usuario_modificacion"," "), 0,4);
            
            pc.addCols(" ", 0,dHeader.size());
            
            pc.addBorderCols("Tipo de aislamiento", 0, 1,Color.lightGray);
            pc.addBorderCols("F.Inicio", 1, 1,Color.lightGray);
            pc.addBorderCols("F.Retiro/Alta", 1, 1,Color.lightGray);
            pc.addBorderCols("Diagnósticos", 0, 1,Color.lightGray);
            pc.addBorderCols("APP/Cirugías", 0, 1,Color.lightGray);
            pc.addBorderCols("Cultivos/Fuente", 0, 1,Color.lightGray);
            pc.addBorderCols("Antibióticos administrados", 0, 1,Color.lightGray);
            pc.addBorderCols("Motivo de aislamiento", 0, 1,Color.lightGray);
            pc.addBorderCols("Notas/Observaciones", 0, 1,Color.lightGray);
            
            pc.setFont(8,0);
            pc.addBorderCols(cdo.getColValue("tipo_aislamiento"), 0, 1);
            pc.addBorderCols(cdo.getColValue("fecha_inicio"), 1, 1);
            pc.addBorderCols(cdo.getColValue("fecha_retiro"), 1, 1);
            pc.addBorderCols(cdo.getColValue("diagnosticos"), 0, 1);
            pc.addBorderCols(cdo.getColValue("app_cirugias"), 0, 1);
            pc.addBorderCols(cdo.getColValue("cultivos_fuente"), 0, 1);
            pc.addBorderCols(cdo.getColValue("antibioticos"), 0, 1);
            pc.addBorderCols(cdo.getColValue("motivos_aislamiento"), 0, 1);
            pc.addBorderCols(cdo.getColValue("observaciones"), 0, 1);
            
		}
        
        pc.addCols(" ", 0,dHeader.size());

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>