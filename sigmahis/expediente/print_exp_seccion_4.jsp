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

CommonDataObject cdo, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = (request.getParameter("desc")==null?"":request.getParameter("desc"));

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

sql="select d.usuario_creacion as creacion, d.usuario_modificacion as modificacion, tipo_asa, plan, a.codigo, a.cod_paciente, to_char (a.fec_nacimiento, 'dd/mm/yyyy') as fec_nacimiento, a.edad, a.complicacion, a.observacion, a.tipo_registro, a.diagnostico, a.procedimiento, a.tipo_anestesia as tipoanestesia, to_char (a.fecha, 'dd/mm/yyyy') as fecha, a.pac_id, decode (a.tipo_registro, 'H', a.diagnostico, 'C', a.diagnostico /*a.procedimiento*/) codregistro, decode (a.tipo_registro, 'C', decode (d.observacion, null, d.nombre, d.observacion) /*decode (b.observacion, null, b.descripcion, b.observacion)*/, 'H', decode (d.observacion, null, d.nombre, d.observacion)) as descregistro, c.descripcion as tipoanestesia from tbl_sal_cirugia_paciente a, tbl_cds_procedimiento b, tbl_sal_tipo_anestesia c, tbl_cds_diagnostico d where a.procedimiento = b.codigo(+) and a.tipo_anestesia = c.codigo(+) and pac_id = "+pacId+" and a.diagnostico = d.codigo(+) order by fecha asc";

//cdo = SQLMgr.getData(sql);
al = SQLMgr.getDataList(sql);

if ( desc.equals("") ) desc = "ANTECEDENTE HOSPITALIZACION Y CIRUGIAS";

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
    cdoPacData.addColValue("is_landscape",""+isLandscape);}
	
	//------------------------------------------------------------------------------------
	
	PdfCreator pc=null;
    boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
      
	if ( pc==null ){
		 pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
		 isUnifiedExp=true;
	}

		Vector dHeader = new Vector();
		dHeader.addElement("10"); 
		dHeader.addElement("30");
		dHeader.addElement("15");
		dHeader.addElement("8");
		dHeader.addElement("15");
		dHeader.addElement("30");
		dHeader.addElement("30");
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		pc.addCols("",0,dHeader.size(), 10.2f);
		pc.setFont(7,1,Color.WHITE);
		pc.addCols("Tipo Registro: H = Hospitalizado, C=Cirugia",0,dHeader.size(), Color.GREEN);
		pc.addCols("",0,dHeader.size(), 10.2f);
		
		pc.setFont(7,0);
		pc.addBorderCols("Tipo",1,1);
		pc.addBorderCols("Diagnóstico",1,1);
		pc.addBorderCols("Tipo Anestesia",1,1);
		pc.addBorderCols("Edad",1,1);
		pc.addBorderCols("Fecha",1,1);
		pc.addBorderCols("Observación",1,1);
		pc.addBorderCols("Complicación",1,1);
		
		if(al.size()<1){
			pc.addCols("No hay registros",1, dHeader.size());
		}else{
		
		for(int i = 0; i<al.size(); i++){
		
		cdo = (CommonDataObject) al.get(i);
		
		pc.addCols(cdo.getColValue("tipo_registro"),1,1);
		pc.addCols(cdo.getColValue("descregistro"),0,1);
		pc.addCols(cdo.getColValue("tipoanestesia"),0,1);
		pc.addCols(cdo.getColValue("edad"),1,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		pc.addCols(cdo.getColValue("complicacion"),0,1);
		
		
		pc.addBorderCols("",1,dHeader.size(),0.0f,0.5f,0.0f,0.0f,5.2f);
		} //for

	}//else

    pc.addTable();
	if(isUnifiedExp){
	   pc.close();
	   response.sendRedirect(redirectFile);
    }
//}GET
%>