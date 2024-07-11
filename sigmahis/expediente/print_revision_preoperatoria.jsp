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
Reporte sal10080
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
CommonDataObject cdo1,cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaRev = request.getParameter("fecha");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String mode = request.getParameter("mode");
if (mode == null) mode = "add";
if (appendFilter == null) appendFilter = "";
if (fechaRev== null) fechaRev = "";

if (!fechaRev.trim().equals(""))appendFilter +=" and to_date(to_char(b.fecha_revision(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') =  to_date('"+fechaRev+"','dd/mm/yyyy hh12:mi am') "; 

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

mode = "edit";

if(!mode.trim().equals("add")){sql = "select  nvl(rp.observacion,' ') observacion, rp.cirugia as cirugia, rp.medico_cirujano as cirujano, to_char(fecha,'dd/mm/yyyy') as fecha, to_char(fecha,'hh12:mi am') as hora  from tbl_sal_revision_preoperatoria rp, tbl_adm_medico m where rp.pac_id="+pacId+" and rp.secuencia="+noAdmision+" and rp.medico_cirujano=m.codigo(+) --and to_date(to_char(rp.fecha(+),'dd/mm/yyyy hh12:mi am'),'dd/mm/yyyy hh12:mi am') =  to_date('"+fechaRev+"','dd/mm/yyyy hh12:mi am')  ";
cdo1 = SQLMgr.getData(sql);}
else {cdo1 = new CommonDataObject();cdo1.addColValue("observacion","");}

if(cdo1 == null) cdo1 = new CommonDataObject();

sql="select a.codigo as pregunta, a.descripcion as descripcion, nvl(b.respuesta,'N') as respuesta, to_char(b.fecha_revision,'dd/mm/yyyy') as fecharevision, b.observacion as observacion from tbl_sal_pregunta a, tbl_sal_respuesta b where a.codigo=b.pregunta(+) and a.estado in ('A') and b.pac_id(+)= "+pacId+" /*3689*/ and b.secuencia(+)= "+noAdmision+appendFilter+"  order by a.codigo asc ";

al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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
	String title = "DEPARTAMENTO DE ENFERMERIA";	
	String subtitle = "HOJA DE PREPARACIÓN DE PACIENTE PARA PROCEDIMIENTO";
	String xtraSubtitle = "QUIRÚRGICO / INVASIVO";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	Vector dHeader = new Vector();
		dHeader.addElement(".54");
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".38");
		
	
	footer.setNoColumnFixWidth(dHeader);
	footer.createTable();
		footer.setFont(3, 0);
		footer.addCols(" ",0,dHeader.size());
		footer.setFont(9, 0);
		footer.addBorderCols("OBSERVACION: "+cdo1.getColValue("observacion"),0,dHeader.size());
		footer.addBorderCols("FIRME DEL EVALUADOR: ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
        
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
		
	if(pc==null){pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());
	isUnifiedExp=true;}
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp,cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		
			pc.setFont(8, 1);
			pc.addCols("Cirugía: "+cdo1.getColValue("cirugia"),0,2);
			pc.addCols("Doctor/Cirujano: "+cdo1.getColValue("cirujano"),0,2);
			
			pc.addCols("Fecha de Revisión: "+cdo1.getColValue("fecha"),0,2);
			pc.addCols("Hora de Revisión: "+cdo1.getColValue("hora"),0,2);
		/*	
			pc.setFont(3, 0);
			pc.addInnerTableCols(" ",0,infoCol.size());
			pc.addInnerTableBorderCols(" ",0,infoCol.size(),0.0f,0.10f,0.0f,0.0f);
			pc.resetVAlignment();
		pc.addInnerTableToCols(dHeader.size());
	*/
		/*pc.setFont(7, 1);
		pc.addBorderCols("FACTORES",0);
		pc.addBorderCols("SI",1);
		pc.addBorderCols("NO",1);
		pc.addBorderCols("OBSERVACION",0);*/
	

	//table body
	//OBJETIVOS:
	//1. Presentar al paciente en el mejor estado posible, físico y psicosocial, para su operación.
	//2. Brindar al paciente, seguridad y confianza, para reducir al mínimo las complicaciones y molestias post-operatorias.
	//3. Revisar algunos factores que intervienen en la atención adecuada de pacientes, antes de la cirugía.
	/*pc.setFont(9, 1);
	pc.addCols("OBJETIVOS:",0,dHeader.size());
	pc.addCols("1. Presentar al paciente en el mejor estado posible, físico y psicosocial, para su operación.",0,dHeader.size());
	pc.addCols("2. Brindar al paciente, seguridad y confianza, para reducir al mínimo las complicaciones y molestias post-operatorias.",0,dHeader.size());
	pc.addCols("3. Revisar algunos factores que intervienen en la atención adecuada de pacientes, antes de la cirugía.",0,dHeader.size());
	*/
    pc.addCols(" ",0,dHeader.size());
		
	pc.setFont(8, 1);
		pc.addBorderCols("FACTORES",0);
		pc.addBorderCols("SI",1);
		pc.addBorderCols("NO",1);
		pc.addBorderCols("OBSERVACION",0);
	pc.setVAlignment(0);
	pc.setTableHeader(5);//create de table header (3 rows) and add header to the table
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(8, 1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		
		/*if (cdo.getColValue("respuesta").trim().equalsIgnoreCase("S")) pc.setFont(7, 0, Color.Black);
		else pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("descEstado"),1,1,0.5f,0.0f,0.0f,0.0f,cHeight);
		pc.setFont(7, 0);*/
		
		if (cdo.getColValue("respuesta").trim().equalsIgnoreCase("S"))
		pc.addBorderCols("S",1,1,Color.BLACK);
		else pc.addBorderCols(" ",1,1);
		
		if (cdo.getColValue("respuesta").trim().equalsIgnoreCase("N"))
		pc.addBorderCols(" ",1,1,Color.BLACK);
		else pc.addBorderCols(" ",1,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}

	
//}//GET
%>