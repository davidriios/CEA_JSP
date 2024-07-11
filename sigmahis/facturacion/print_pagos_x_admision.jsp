<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
ArrayList alTS = new ArrayList();
ArrayList alTST = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String noSecuencia = request.getParameter("noSecuencia");
String pacId = request.getParameter("pacId");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");

if (appendFilter == null) appendFilter = "";

sbSql.append("select p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',''||p.primer_apellido)||decode(p.segundo_apellido,null,' ',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',''||p.apellido_de_casada)) as nombre, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, nvl(to_char(p.f_nac,'dd/mm/yyyy'),' ') as f_nac, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), ' ') as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as desc_categoria, c.descripcion as area_desc, a.medico, t.descripcion as dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado, p.pac_id, p.residencia_direccion, nvl(a.dias_hospitalizados, 0) as dias_hospitalizado, d.primer_nombre||' '||d.segundo_nombre||' '||d.primer_apellido||' '||d.segundo_apellido||' '||d.apellido_de_casada as nombre_medico, getFactura(a.secuencia, a.pac_id) as no_factura, getAseguradora(a.secuencia, a.pac_id, a.aseguradora) as aseguradora, getNumPoliza(a.secuencia, a.pac_id, a.aseguradora, e.prioridad) as num_poliza, nvl(e.num_aprobacion, 0) as num_aprobacion, getDiagnostico(a.secuencia, a.pac_id) as diagnostico from tbl_adm_paciente p, tbl_adm_admision a, tbl_cds_centro_servicio c, tbl_adm_tipo_admision_cia t, tbl_adm_medico d, (select pac_id, admision, min(prioridad) as prioridad, decode(min(prioridad),1, min(num_aprobacion),0) as num_aprobacion from tbl_adm_beneficios_x_admision group by pac_id, admision) e where a.pac_id=p.pac_id and a.compania=");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and c.codigo=a.centro_servicio and t.categoria=a.categoria and t.codigo=a.tipo_admision and a.medico=d.codigo and a.secuencia=e.admision(+) and a.pac_id=e.pac_id(+) and a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.secuencia=");
sbSql.append(noSecuencia);
CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select c.anio, c.codigo, a.secuencia_pago secuenciapago, admi_secuencia admisecuencia, b.codigo recibo, to_char(c.fecha, 'dd/mm/yyyy') fechapago, decode(c.tipo_cliente, 'P', 'Paciente', 'E', 'Empresa', 'Otros') tipocliente, decode(a.pago_por, 'C', 'Pre-Factura', 'F', 'Factura', 'D', 'Depósito', 'R', 'Remanente') pagopor, decode(a.tipo_transaccion, 1, 'Cancela', 2, 'Abono', 3, 'Co-Pago', 4, 'Depósito') tipotransaccion, c.descripcion, a.fac_codigo faccodigo, nvl(sum(a.monto),0) subtotal,c.fecha from tbl_cja_detalle_pago a, tbl_cja_recibos b, tbl_cja_transaccion_pago c where (a.compania = c.compania and a.tran_anio = c.anio and a.codigo_transaccion = c.codigo) and (c.anio = b.ctp_anio and c.compania = b.compania and c.codigo = ctp_codigo) and c.tipo_cliente in ('P', 'O') and c.pac_id=");
sbSql.append(pacId);
sbSql.append(" and a.admi_secuencia=");
sbSql.append(noSecuencia);
sbSql.append(" and a.compania=");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and c.rec_status <> 'I' group by c.anio, c.codigo, a.secuencia_pago, admi_secuencia, b.codigo, to_char(c.fecha, 'dd/mm/yyyy'), decode(c.tipo_cliente, 'P', 'Paciente', 'E', 'Empresa', 'Otros') , decode(a.pago_por, 'C', 'Pre-Factura', 'F', 'Factura', 'D', 'Depósito', 'R', 'Remanente') , decode(a.tipo_transaccion, 1, 'Cancela', 2, 'Abono', 3, 'Co-Pago', 4, 'Depósito'), c.descripcion, a.fac_codigo,c.fecha ");

sbSql.append(" order by c.fecha ");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+
	"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "DETALLE DE PAGOS A ADMISION";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".04");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".13");
		dHeader.addElement(".10");
		dHeader.addElement(".06");
		dHeader.addElement(".07");
		dHeader.addElement(".09");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("Nombre:",0,2,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("nombre"),0,5,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Cod. Paciente:",0,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(cdoHeader.getColValue("pac_id")+"-"+(cdoHeader.getColValue("admision")),0,4,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("Cédula:",0,2);
		pc.addCols(cdoHeader.getColValue("cedula"),0,5);
		pc.addCols("Factura No.:",0,1);
		pc.addCols(cdoHeader.getColValue("no_factura"),0,4);

		pc.addCols("Pasaporte:",0,2);

		pc.addCols(cdoHeader.getColValue("pasaporte"),0,5);
		pc.addCols("Categoría:",0,1);
		pc.addCols(cdoHeader.getColValue("desc_categoria"),0,4);

		pc.addCols("Dirección Residencial:",0,2);
		pc.addCols(cdoHeader.getColValue("residencia_direccion"),0,5);
		pc.addCols("Aseguradora:",0,1);
		pc.addCols(cdoHeader.getColValue("aseguradora"),0,4);

		pc.addCols("Fecha Ingreso:",0,2);
		pc.addCols(cdoHeader.getColValue("fecha_ingreso"),0,5);
		pc.addCols("Poliza #.:",0,1);
		pc.addCols(cdoHeader.getColValue("num_poliza"),0,4);

		pc.addCols("Fecha Egreso:",0,2);
		pc.addCols(cdoHeader.getColValue("fecha_egreso"),0,5);
		pc.addCols("Num. Aprob.:",0,1);
		pc.addCols(cdoHeader.getColValue("num_aprobacion"),0,4);

		pc.addCols("Días Hospitalizados:",0,2);
		pc.addCols(cdoHeader.getColValue("dias_hospitalizado"),0,5);
		pc.addCols("ICD9:",0,1);
		pc.addCols(cdoHeader.getColValue("diagnostico"),0,4);

		pc.addCols("Médico:",0,2);
		pc.addCols(cdoHeader.getColValue("nombre_medico"),0,5);
		pc.addCols("Area Admite:",0,1);
		pc.addCols(cdoHeader.getColValue("area_desc"),0,4);

		pc.addBorderCols("Recibo",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Tipo Clte",1,3);
		pc.addBorderCols("Pago por",1);
		pc.addBorderCols("Tipo Transac",1);
		pc.addBorderCols("Factura",1);
		pc.addBorderCols("Descripción",1,3);
		//pc.addBorderCols("Cant.",1);
		pc.addBorderCols("Monto",2);
		//pc.addBorderCols("Total",1);
	 pc.setTableHeader(10);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	double cdsTotal = 0.00;
	double total = 0.00;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("recibo"),1,1);
		pc.addCols(cdo.getColValue("fechapago"),1,1);
		pc.addCols(cdo.getColValue("tipocliente"),1,3);
		pc.addCols(cdo.getColValue("pagopor"),1,1);
		pc.addCols(cdo.getColValue("tipotransaccion"),1,1);
		pc.addCols(cdo.getColValue("faccodigo"),1,1);
		pc.addCols(cdo.getColValue("descripcion"),0,3);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("subtotal")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		total += Double.parseDouble(cdo.getColValue("subtotal"));
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(groupFontSize,1,Color.blue);
		pc.addBorderCols("TOTAL ",2,11,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(total),2,1,0.0f,0.5f,0.0f,0.0f);

	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
