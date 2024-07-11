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
Reporte
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
CommonDataObject cdo1, cdoPacData = new CommonDataObject();

String sql = "", sqlTitle="";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaControl = request.getParameter("fechaControl");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String fp = request.getParameter("fp");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (desc == null) desc = "";
if (fp == null) fp = "";
if (fechaControl== null) fechaControl = fecha.substring(0,10);

if (!fechaControl.trim().equals(""))appendFilter +=" and to_date(to_char(b.fecha_inf(+),'dd/mm/yyyy'),'dd/mm/yyyy') =  to_date('"+fechaControl+"','dd/mm/yyyy') ";

sql = "select ap.primer_nombre||' '||ap.segundo_nombre||' '||decode(ap.apellido_de_casada,null,ap.primer_apellido||' '||ap.segundo_apellido,ap.apellido_de_casada) as nombre_paciente, decode(ap.pasaporte,null,ap.provincia||'-'||ap.sigla||'-'||ap.tomo||'-'||ap.asiento||'-'||ap.d_cedula,ap.pasaporte) as identificacion, to_char(aa.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(aa.fecha_egreso,'dd/mm/yyyy') as fecha_egreso, nvl(aa.medico,' ') as medico, ap.codigo as codigo_paciente, aa.secuencia as admision, m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico, aca.habitacion||decode(aca.habitacion,null,'','/'||aca.cama) as cama from tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null ";
cdo1 = SQLMgr.getData(sql);

	sql="SELECT a.codigo as codigoInfeccion, a.descripcion as descripcion, b.codigo as codigo, b.infec_pac as infecPac, to_char(b.fecha_inf,'dd/mm/yyyy') as fechaInf, to_char(b.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(b.fecha_cambio,'dd/mm/yyyy') as fechaCambio, to_char(b.fecha_retiro,'dd/mm/yyyy') as fechaRetiro, b.observacion as observacion, to_char(b.fecha_cultivo,'dd/mm/yyyy') as fechaCultivo, b.total_dias as totalDias,  (select c.usuario_creacion||'/'||c.usuario_modificacion from TBL_SAL_INFECCION_PACIENTE c where b.secuencia = c.secuencia and b.fec_nacimiento = c.fec_nacimiento and b.cod_paciente = c.cod_paciente and b.fecha_inf = c.fecha_registro ) usuario FROM TBL_SAL_INFECCION a, TBL_SAL_DETALLE_INFECCION b where 1 = 1 ";
    
    if (fp.trim().equalsIgnoreCase("kardex")) sql += " and a.codigo=b.codigo and b.pac_id = "+pacId+" and b.secuencia = "+noAdmision;
    else sql += " and a.codigo=b.codigo(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+appendFilter;
    
    sql+=" ORDER BY a.codigo ASC";
	
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COMITE DE EPIDEMIOLOGIA";
	String subtitle = desc;
	String xtraSubtitle = "CONTROL DE PROCEDIMIENTOS INVASIVOS PARA PREVENCION DE INFECCIONES NOSOCOMIALES";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
		dHeader.addElement(".25");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".25");
		
		dHeader.addElement(".10");
        
        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
    }


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, permission, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();
		pc.addInnerTableToCols(dHeader.size());

		pc.setFont(7, 1);
		pc.addBorderCols("PROCEDIMIENTO",0);
		pc.addBorderCols("FECHA DE INICIO",1);
		pc.addBorderCols("FECHA DE CAMBIO",1);
		pc.addBorderCols("FECHA DE CULTIVO",1);
		pc.addBorderCols("FECHA DE RETIRO",1);
		pc.addBorderCols("TOTAL DE DIAS",1);
		pc.addBorderCols("OBSERVACION",0);
		pc.addBorderCols("USUARIO",1);

	pc.setTableHeader(3);//create de table header (3 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.addBorderCols(""+cdo.getColValue("descripcion"),0,1,0.5f,0.0f,0.5f,0.0f,cHeight);
		pc.addBorderCols(""+cdo.getColValue("fechaIni"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("fechaCambio"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("fechaCultivo"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("fechaRetiro"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("totalDias"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("observacion"),0,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+(!cdo.getColValue("usuario").equals("/")?cdo.getColValue("usuario"):""),1,1,0.5f,0.0f,0.5f,0.5f);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>