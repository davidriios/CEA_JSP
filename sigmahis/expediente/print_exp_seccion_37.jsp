<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed" />
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

ArrayList al, al2 = new ArrayList();
CommonDataObject cdo1, cdoPacData, cdoTitle, cdoT, cdoST = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String userName = UserDet.getUserName();
String tipoOrden = request.getParameter("tipoOrden");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String idOrden = request.getParameter("idOrden");

if ( idOrden == null ) idOrden = ""; // throw new Exception("El id de la orden es inválido!");

if(idOrden.equals("0")) idOrden = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (noAdmision.equals("") || noAdmision == null) throw new Exception("El id de la admisión no es válido!");
if (pacId.equals("") || pacId == null ) throw new Exception("El id del paciente no es válido!");
//if (seccion == null) throw new Exception("La sección no es válida!");

sbSql.append("select cod_paciente, fec_nacimiento, secuencia,tipo_orden tipoOrden, orden_med ordenMed, codigo, nombre, to_char(fecha_inicio,'dd/mm/yyyy hh12:mi am')fechaInicio, nvl(to_char(fecha_fin,'dd/mm/yyyy hh12:mi am'),' ') fechaFin,  observacion, ejecutado, centro_servicio, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion,tipo_dieta tipoDieta,  cod_tipo_dieta codTipoDieta, tipo_tubo tipoTubo, fecha_orden, omitir_orden, pac_id, fecha_suspencion, obser_suspencion, (select descripcion from tbl_sal_desc_estado_ord where estado=estado_orden) as estado_orden, (select d.descripcion from TBL_CDS_TIPO_DIETA d where d.codigo = tipo_dieta) as dieta from tbl_sal_detalle_orden_med where tipo_orden = 3 and pac_id = ");
sbSql.append(pacId);
sbSql.append(" and secuencia = ");
sbSql.append(noAdmision);

if(!idOrden.equals("")){
   sbFilter.append(" and orden_med = ");
   sbFilter.append(idOrden);
   sbSql.append(sbFilter);
  // System.out.println(idOrden+" ::::::::::::::::::::::::::::::::"+sbSql.toString());
}

sbSql.append(" order by fecha_inicio desc");

al = SQLMgr.getDataList(sbSql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	
String subtitle ="", sqlTipo = "", sqlSubTipo="";	
	
if(seccion == null){
	subtitle = "LISTA DE ORDENES MEDICAS";
   //System.out.println("------------- The seccion is no there -----------------------");
}else{
   subtitle = desc;
  // System.out.println("------------- The seccion is there -----------------------");
}
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
    cdoPacData.addColValue("is_landscape",""+isLandscape);
	}
	
PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}

	Vector dHeader = new Vector();
		dHeader.addElement("12");
		dHeader.addElement("12");
		dHeader.addElement("10");
		dHeader.addElement("22");
		dHeader.addElement("30");
		dHeader.addElement("14");
    	

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		
		pc.setFont(7, 1);
		pc.addBorderCols("Desde",1,1);
		pc.addBorderCols("Hasta",1,1);
		pc.addBorderCols("Usuario",1,1);
		pc.addBorderCols("Dieta",1,1);		
		pc.addBorderCols("Descripción",1,1);
		pc.addBorderCols("Tubo",1,1);
		
		pc.setTableHeader(2);
		
		pc.addCols("",1,dHeader.size(),3f);
		
	if ( al.size() < 1){
	    pc.addCols("No se ha encontrado registros!",1,dHeader.size());
	}else{
	
	pc.setVAlignment(0);
	
	String tubo = "";
	
	for (int i=0; i<al.size(); i++)
	{
	
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("fechaInicio"),1,1);
		pc.addCols(cdo.getColValue("fechaFin"),1,1);
		pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
		pc.addCols(cdo.getColValue("dieta"),0,1); 
		pc.addCols(cdo.getColValue("observacion").replace(",",", "),0,1);
		
		if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("G") ) tubo = "GOTEO";
		else if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("N") ) tubo = "BOLO";
		else if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("M") ) tubo = "NASOGÁSTRICO";
		else if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("O") ) tubo = "OROGÁSTRICA";
		else if ( cdo.getColValue("tipoTubo").equalsIgnoreCase("J") ) tubo = "GASTROSTOMÍA";
		else tubo = "";
				
		pc.addCols(tubo,1,1);
		
		pc.addBorderCols("",1,dHeader.size(),0.1f,0.0f,0.0f,0.0f);
		pc.addCols("",1,dHeader.size(),3f);
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	} //for
	
		pc.setFont(7, 0);
		pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.0f,0.0f,0.0f,75.0f);

		pc.addBorderCols("Preparado Por",1,3,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols("Autorizado Por",1,2,0.0f,0.5f,0.0f,0.0f);
	
	
	}//else
	

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>