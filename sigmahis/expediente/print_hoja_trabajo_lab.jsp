<%@ page errorPage="../error.jsp"%>
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
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
StringBuffer sql = new StringBuffer();
CommonDataObject cdo1,cdoPacData = new CommonDataObject();

String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codSolicitud = request.getParameter("codSolicitud");
String codSolicitudDet = request.getParameter("codSolicitudDet");
String area = request.getParameter("area");
String fg = request.getParameter("fg");
String fechaSol = request.getParameter("fecha");
String seqTrx = request.getParameter("seqTrx");
String printingOnTheFly = request.getParameter("printingOnTheFly") == null ? "" : request.getParameter("printingOnTheFly");
String sql2="";
if (appendFilter == null) appendFilter = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (codSolicitud == null) codSolicitud = "";
if (area == null) area = "";
if (fg == null) fg = "";
if (codSolicitudDet == null) codSolicitudDet = "";
if (fechaSol == null) fechaSol = "";
if (seqTrx == null) seqTrx = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

 sql.append("select  a.admi_pac_codigo codigo_paciente,a.admi_secuencia admision,a.med_codigo_resp medico_res,a.cod_centro_servicio sol_centro,b.cod_centro_servicio det_centro,b.cod_procedimiento ,decode (c.observacion, null, c.descripcion, c.observacion)desc_procedimiento,c.precio,e.primer_nombre || ' ' || e.segundo_nombre || ' '|| decode (e.apellido_de_casada,null, e.primer_apellido || ' ' || e.segundo_apellido,		e.apellido_de_casada)nombre_paciente, decode(e.pasaporte,null,e.provincia|| '-'|| e.sigla|| '-'|| e.tomo|| '-'|| e.asiento,e.pasaporte) identificacion_paciente,e.residencia_direccion sol_direccion,e.sexo, decode(b.estado,'A','CANCELADO POR '||b.usuario_cancela||decode(b.comentario_cancela,null,'',' - '||b.comentario_cancela),nvl(b.comentario,' ')) comentario,decode(b.estado,'S','PENDIENTE','T','TRAMITE','F','APROBADO','A','ANULADO','')as estado,decode(b.prioridad,'H','HOY','M','MAÑANA','U','URGENTE','O','OTROS',b.prioridad)||' - '|| to_char(b.fecha_solicitud,'dd/mm/yyyy') as prioridad,d.codigo||' - '||d.descripcion descCds from tbl_cds_solicitud a, tbl_cds_detalle_solicitud b,tbl_cds_procedimiento c,tbl_cds_centro_servicio d,vw_adm_paciente e where   (    a.pac_id = b.pac_id and a.admi_secuencia = b.csxp_admi_secuencia) and a.pac_id = e.pac_id and a.codigo = b.cod_solicitud and b.cod_procedimiento = c.codigo and a.cod_centro_servicio = d.codigo");

 if(!pacId.trim().equals(""))
 {
	sql.append(" and a.pac_id =");
	sql.append(pacId);
 }
 if(!noAdmision.trim().equals(""))
 {
	sql.append(" and a.admi_secuencia =");
	sql.append(noAdmision);
 }
 if(!codSolicitud.trim().equals(""))
 {
	sql.append(" and a.codigo in (select column_value  from table( select split('");
	sql.append(codSolicitud);
	sql.append("',',') from dual ))");
 }
 if(!codSolicitudDet.trim().equals(""))
 {
	sql.append(" and b.codigo =");
	sql.append(codSolicitudDet);
 }
 if(!area.trim().equals(""))
 {
	sql.append(" and a.cod_centro_servicio =");
	sql.append(area);
 }
 if(fg.trim().equals("Area"))
 {
	sql.append(" and b.estudio_realizado = 'N' and b.estado = 'S' ");
 }
 if(!fechaSol.trim().equals(""))
 {
	sql.append(" and trunc(b.fecha_solicitud)=to_date('");
	sql.append(fechaSol);
	sql.append("','dd/mm/yyyy')");
 }
	if (!seqTrx.trim().equals("")) {
		sql.append(" and b.estado = 'T' and b.seq_trx_cargo = "+seqTrx);
	}

 sql.append(" order by b.cod_centro_servicio,b.cod_solicitud,b.codigo asc  ");

 al = SQLMgr.getDataList(sql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	float footerHeight = 0.00F;
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = "SOLICITUDES DE "+((fg.trim().equals("LAB"))?"LABORATORIO":" IMAGENOLOGÍA");
	String xtraSubtitle = !printingOnTheFly.equals("") ? "PENDIENTE" : "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 25.0f;

		CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
		if (paramCdo == null) {
			paramCdo = new CommonDataObject();
			paramCdo.addColValue("is_landscape","N");
		}
		if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
				cdoPacData.addColValue("is_landscape",""+isLandscape);
				contentFontSize = 8;
		}

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".30");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);


	footer.setNoColumnFixWidth(dHeader);
		footer.createTable();
		footer.setFont(8, 0);
		footer.addCols("Elaborado Por:__________________________________________________________________ ",0,dHeader.size());
		footer.addCols(" ",0,dHeader.size(),cHeight);


	//footer.addTable();*

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData,xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addCols(((fg.trim().equals("Area"))?"Datos Generales del Paciente":"EXAMENES SOLICITADOS")+((!seqTrx.trim().equals(""))?(" - TRX #"+seqTrx):""),1,dHeader.size());
		pc.addBorderCols("CPT",0,1);
		pc.addBorderCols("DESCRIPCION",0,1);
		pc.addBorderCols("SUB DEPARTAMENTO",0,1);
		pc.addBorderCols("PRIORIDAD",0,1);
		pc.addBorderCols("NOTA",0,1);
		//pc.addBorderCols(""+((fg.trim().equals("LAB"))?"OBSERVACION":"SOSPECHA"),0,1);
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table


	//table body
	String groupBy ="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize, 0);

		pc.addCols(cdo.getColValue("cod_procedimiento"),0,1);
		pc.addCols(cdo.getColValue("desc_procedimiento"),0,1);
		pc.addCols(cdo.getColValue("descCds"),0,1);
		pc.addCols(cdo.getColValue("prioridad"),0,1);
		pc.addCols(cdo.getColValue("comentario"),0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("nombre_paciente");

	}
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());

	if (al.size() == 0){ if(!fg.trim().equals("Area"))pc.addCols("No existen registros",1,dHeader.size());}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>