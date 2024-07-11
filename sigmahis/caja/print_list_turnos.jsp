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

StringBuffer sbSql = new StringBuffer();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");
String fechaDesde = request.getParameter("fechaini");
String fechaHasta = request.getParameter("fechafin");
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (fechaDesde == null) fechaDesde = "";
if (fechaHasta == null) fechaHasta = "";
if (caja == null) caja = "";
if (turno == null) turno = "";

sbSql = new StringBuffer();
	sbSql.append("select a.compania, a.codigo, a.cja_cajera_cod_cajera as cajera, nvl(a.monto_inicial,0) as montoini, to_char(a.hora_inicio,'hh12:mi:ss') as horaini, to_char(a.hora_final,'hh12:mi:ss') as horafin, a.observacion, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.hora_final,null,'N','S') as cerrado, b.cod_caja, b.estatus as estado_turno, decode( b.estatus,'A','ACTIVO','I','CERRADO','T','TRAMITE') as estadoTurno");
	sbSql.append(", nvl((select 'S' from tbl_cja_sesdetails where session_id = a.codigo and company_id = a.compania),'N') as mostrar");
	sbSql.append(", c.descripcion  as caja_nombre");
	sbSql.append(", decode(c.estado,'A','ACTIVO','I','INACTIVO') as caja_estado");
	sbSql.append(", nvl(ip,' ') as ip");
	sbSql.append(", nvl((select nombre from tbl_cja_cajera where cod_cajera = a.cja_cajera_cod_cajera and compania = a.compania),' ') as cajeraname");
	sbSql.append(" from tbl_cja_turnos a, tbl_cja_turnos_x_cajas b,tbl_cja_cajas c where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.compania = b.compania and a.codigo = b.cod_turno");
	sbSql.append(" and c.compania = b.compania and c.codigo = b.cod_caja");
	sbSql.append(appendFilter);
	
	if(fg.trim().equals("REP"))
	{
		if(!fechaDesde.trim().equals(""))
		{
			sbSql.append(" and a.fecha >= to_date('");
			sbSql.append(fechaDesde);
			sbSql.append("','dd/mm/yyyy')");
		}
		if(!fechaHasta.trim().equals(""))
		{
			sbSql.append(" and a.fecha <= to_date('");
			sbSql.append(fechaHasta);
			sbSql.append("','dd/mm/yyyy')");
		}
		if(!turno.trim().equals(""))
		{
			sbSql.append(" and a.codigo=");
			sbSql.append(turno);
		}
		if(!caja.trim().equals(""))
		{
			sbSql.append(" and b.cod_caja=");
			sbSql.append(caja);
		}
		
		
	sbSql.append(" and not  exists ( select 1 from (select to_number(nvl(column_value,-1)) turnos  from table( select split((select join(cursor(select nvl(mb.turnos_cierre,'-1') from tbl_con_movim_bancario mb where turnos_cierre is not null and compania =");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" ),'|') from dual ),'|') from dual )) y where  y.turnos =a.codigo ) and not exists (select 1 from tbl_con_movim_bancario mb where turno =a.codigo and compania = a.compania ) and b.estatus in('T','I')");
	
	
	
	}
	
	sbSql.append(" order by a.codigo desc");

al = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	String title = "CAJA";
	String subtitle = (fg.trim().equals("REP"))?"TURNOS SIN REGISTROS DE DEPOSITOS ":"MANTENIMIENTO DE TURNOS";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		   dHeader.addElement(".05");
		   dHeader.addElement(".15");
		   dHeader.addElement(".06");
		   dHeader.addElement(".06");
		   dHeader.addElement(".06");
		   dHeader.addElement(".15");
		   dHeader.addElement(".07");
		   dHeader.addElement(".08");
		   dHeader.addElement(".08");
		   dHeader.addElement(".08");
		   dHeader.addElement(".16");
					
PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(7, 1);			
			pc.addBorderCols("TURNO",0,1);
			pc.addBorderCols("CAJERO",1,1);
			pc.addBorderCols("FECHA",1,1);
			pc.addBorderCols("H. INICIO",1,1);
			pc.addBorderCols("H. FINAL",1,1);
			pc.addBorderCols("CAJA",1);
			pc.addBorderCols("ESTADO CAJA",0,1);
			pc.addBorderCols("IP",2);
			pc.addBorderCols("ESTADO TURNO",0,1);
			pc.addBorderCols("MONTO INICIAL ",0,1);	
			pc.addBorderCols("OBSERVACION",0,1);
					
	 pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo1 = (CommonDataObject) al.get(i);
		
			pc.setFont(7, 0);
			pc.addCols(" "+cdo1.getColValue("codigo"),0,1);
			pc.addCols(" "+cdo1.getColValue("cajeraName"),0,1);
			pc.addCols(" "+cdo1.getColValue("fecha"),1,1);
			pc.addCols(" "+cdo1.getColValue("horaIni"),1,1);
			pc.addCols(" "+cdo1.getColValue("horaFin"),1,1);
			pc.addCols(" "+cdo1.getColValue("cod_caja")+" - "+cdo1.getColValue("caja_nombre"),0,1);
			pc.addCols(" "+cdo1.getColValue("caja_estado"),0,1);
			pc.addCols(" "+cdo1.getColValue("ip"),0,1);
			pc.addCols(" "+cdo1.getColValue("estadoTurno"),0,1);
			
			pc.addCols("$"+CmnMgr.getFormattedDecimal(cdo1.getColValue("montoIni")),2,1);
			pc.addCols(" "+cdo1.getColValue("observacion"),0,1);
			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}//End For
		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
	

