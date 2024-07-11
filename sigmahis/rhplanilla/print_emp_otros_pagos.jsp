<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
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
sct0047
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
CommonDataObject co = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String userName = UserDet.getUserName();
String grupo = request.getParameter("grupo");
String anio = request.getParameter("anio");
String periodo = request.getParameter("periodo");

if (grupo == null || anio == null || periodo == null) throw new Exception("El Grupo, Año o Periodo no es válido. Por favor intente nuevamente!");

sbSql = new StringBuffer();
sbSql.append("select descripcion as sub_title, 'Correspondiente a la '||decode(mod(");
sbSql.append(periodo);
sbSql.append(",2),0,'SEGUNDA','PRIMERA')||' quincena de '||to_char(to_date(round(");
sbSql.append(periodo);
sbSql.append("/2,0),'mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH')||' de '||");
sbSql.append(anio);
sbSql.append(" as xtra_sub_title from tbl_pla_ct_grupo where codigo = ");
sbSql.append(grupo);
sbSql.append(" and compania = ");
sbSql.append(session.getAttribute("_companyId"));
co = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.tipo_trx, a.sub_tipo_trx, decode(a.provincia,0,' ',10,'0',11,'B',12,'C',a.provincia)||rpad(decode(a.sigla,'00',' ','0',' ',a.sigla),2,' ')||'-'||lpad(''||a.tomo,3,'0')||'-'||lpad(''||a.asiento,6,'0') as cedula, a.num_empleado, nvl(to_char(a.fecha_inicio,'dd/mm/yyyy'),' ') as fecha_inicio, nvl(to_char(a.fecha_final,'dd/mm/yyyy'),' ') as fecha_final, nvl(a.cantidad,0) as cantidad, nvl(a.monto_unitario,0) as monto_unitario, nvl(a.monto,0) as monto, nvl(a.comentario,' ') as comentario, nvl(a.accion,' ') as accion");
sbSql.append(", (select descripcion from tbl_pla_tipo_transaccion where codigo = a.tipo_trx and compania = a.compania) as tipo_desc");
sbSql.append(", nvl((select descripcion from tbl_pla_sub_tipo_transaccion where compania = a.compania and transaccion = a.tipo_trx and sub_tipo = a.sub_tipo_trx),' ') as sub_tipo_desc");
sbSql.append(", (select primer_nombre||' '||decode(sexo,'F',decode(apellido_casada, null,primer_apellido,decode(usar_apellido_casada,'S','DE '||apellido_casada,primer_apellido)),primer_apellido) from tbl_pla_empleado where emp_id = a.emp_id) as nombre_empleado");
sbSql.append(", (select decode(z.estado,1,' ','El empleado está actualmente en estado '||(select descripcion from tbl_pla_estado_emp where codigo = z.estado)||' el pago se realizará en el periodo '||a.anio_pago||'-'||a.quincena_pago) from tbl_pla_empleado z where z.emp_id = a.emp_id) as estado_desc");
sbSql.append(" from tbl_pla_transac_emp a where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.anio_reporta = ");
sbSql.append(anio);
sbSql.append(" and a.quincena_reporta = ");
sbSql.append(periodo);
sbSql.append(" and a.grupo = ");
sbSql.append(grupo);
sbSql.append(" and a.cod_planilla_pago = 1 and a.aprobacion_estado in ('S'/*,'N'*/) order by 1,2,4");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	float height = 72 * 11f;//1008
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	int groupHeight = groupFontSize * 2;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	int encryptType = 0;
	boolean passRequired = false;
	boolean showUI = false;
	String xtraCompanyInfo = "";
	String title = "REPORTE DE OTROS PAGOS A EMPLEADOS";
	String subtitle = co.getColValue("sub_title");
	String xtraSubtitle = co.getColValue("xtra_sub_title");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, encryptType, passRequired, showUI, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".25");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".05");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".19");
		dHeader.addElement(".03");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		pc.addBorderCols("CEDULA",1,1);
		pc.addBorderCols("NO. EMPL.",1,1);
		pc.addBorderCols("NOMBRE EMPLEADO",1,1);
		pc.addBorderCols("FECHA INICIO",1,1);
		pc.addBorderCols("FECHA FINAL",1,1);
		pc.addBorderCols("CANT.",1,1);
		pc.addBorderCols("MONTO UNIT.",1,1);
		pc.addBorderCols("MONTO TOTAL",1,1);
		pc.addBorderCols("OBSERVACIONES",1,2);
	pc.setTableHeader(2);

	//table body
	String group1 = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!group1.equalsIgnoreCase(cdo.getColValue("tipo_trx")+"-"+cdo.getColValue("sub_tipo_trx")))
		{
			pc.setVAlignment(2);
			pc.setFont(headerFontSize,1,Color.blue);
			pc.addCols(cdo.getColValue("tipo_desc")+" - "+cdo.getColValue("sub_tipo_desc"),0,dHeader.size(),groupHeight,null,0.5f,0.0f,0.0f,0.0f);
		}

		pc.setVAlignment(0);
		pc.setFont(contentFontSize,0);
		pc.addCols(cdo.getColValue("cedula"),0,1);
		pc.addCols(cdo.getColValue("num_empleado"),0,1);
		pc.addCols(cdo.getColValue("nombre_empleado"),0,1);
		pc.addCols(cdo.getColValue("fecha_inicio"),1,1);
		pc.addCols(cdo.getColValue("fecha_final"),1,1);
		pc.addCols(cdo.getColValue("cantidad"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_unitario")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		pc.addCols(cdo.getColValue("comentario"),0,1);
		pc.addCols(cdo.getColValue("accion"),1,1);

		if (!cdo.getColValue("estado_desc").trim().equals(""))
		{
			pc.setFont(contentFontSize,0,Color.red);
			pc.addCols(cdo.getColValue("estado_desc"),0,dHeader.size());
		}

		group1 = cdo.getColValue("tipo_trx")+"-"+cdo.getColValue("sub_tipo_trx");

		if ((i % 50 == 0) || ((i + 1) == al.size())) { pc.flushTableBody(true); }
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>