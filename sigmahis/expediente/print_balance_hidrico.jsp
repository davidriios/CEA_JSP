<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fechaEval = request.getParameter("fecha");
String desc = request.getParameter("desc");
String horario = request.getParameter("horario");
String from = request.getParameter("from");
String to = request.getParameter("to");
String fp = request.getParameter("fp");

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (fechaEval == null) fechaEval = "";
if (desc == null) desc = "";
if (horario == null) horario = "";
if (from == null) from = "";
if (to == null) to = "";
if (fp == null) fp = "";

if (pacId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
CommonDataObject cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

CommonDataObject cdoDateTime = SQLMgr.getData("select to_char(sysdate,'hh24') as hora_actual, to_char(sysdate + (6 / 24),'dd/mm/yyyy hh12:mi:ss am') as fecha_hora_actual, to_char(sysdate + (6 / 24) - 1,'dd/mm/yyyy hh12:mi:ss am') as fecha_hora_menos_24 from dual");

StringBuffer sbSubtitle = new StringBuffer();
if (horario.equalsIgnoreCase("todos")) {

	sbSubtitle.append("TODOS");
	if (!from.trim().equals("") && !to.trim().equals("")) {

		sbSubtitle = new StringBuffer();
		sbSubtitle.append("DEL ");
		sbSubtitle.append(from);
		sbSubtitle.append(" AL ");
		sbSubtitle.append(to);

		sbFilter.append(" and trunc(a.fecha) between to_date('");
		sbFilter.append(from);
		sbFilter.append("','dd/mm/yyyy') and to_date('");
		sbFilter.append(to);
		sbFilter.append("','dd/mm/yyyy')");

	}

} else if (horario.equalsIgnoreCase("_24h")) {

	sbSubtitle.append("ULTIMAS 24 HORAS (");
	sbSubtitle.append(cdoDateTime.getColValue("fecha_hora_menos_24"));
	sbSubtitle.append(" - ");
	sbSubtitle.append(cdoDateTime.getColValue("fecha_hora_actual"));
	sbSubtitle.append(")");

	sbFilter.append(" and to_date(to_char(a.fecha,'dd/mm/yyyy')||' '||to_char(a.hora,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') between to_date('");
	sbFilter.append(cdoDateTime.getColValue("fecha_hora_menos_24"));
	sbFilter.append("','dd/mm/yyyy hh12:mi:ss am') and to_date('");
	sbFilter.append(cdoDateTime.getColValue("fecha_hora_actual"));
	sbFilter.append("','dd/mm/yyyy hh12:mi:ss am')");

} else if (horario.equalsIgnoreCase("turnoActual")) {

	sbSubtitle.append("TURNO ACTUAL (");

	sbFilter.append(" and trunc(a.fecha) = trunc(sysdate)");
	int hh24 = Integer.parseInt(cdoDateTime.getColValue("hora_actual"));
	if (hh24 >= 7 && hh24 < 15) {
		sbSubtitle.append("7am - 3pm");
		sbFilter.append(" and a.hora between to_date('07:00:00','hh24:mi:ss') and to_date('14:59:59','hh24:mi:ss')");
	} else if (hh24 >= 15 && hh24 < 23) {
		sbSubtitle.append("3pm - 11pm");
		sbFilter.append(" and a.hora between to_date('15:00:00','hh24:mi:ss') and to_date('22:59:59','hh24:mi:ss')");
	} else if (hh24 >= 23 && hh24 < 7) {
		sbSubtitle.append("11pm - 7am");
		sbFilter.append(" and a.hora between to_date('23:00:00','hh24:mi:ss') and to_date('06:59:59','hh24:mi:ss')");
	}

	sbSubtitle.append(")");

} else if (!fechaEval.trim().equals("")) {

	sbSubtitle.append("EVALUACION DEL ");
	sbSubtitle.append(fechaEval);

	sbFilter.append(" and trunc(a.fecha) = to_date('");
	sbFilter.append(fechaEval);
	sbFilter.append("','dd/mm/yyyy')");
}

sbSql.append("SELECT to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi am') as hora, a.via_administracion, b.descripcion, a.fluido, sum(nvl(a.cantidad,0)) as cantidad, b.tipo_liquido, bb.usuario_creacion||'/'||bb.usuario_modificacion usuario FROM tbl_sal_detalle_balance a, tbl_sal_via_admin b, tbl_sal_balance_hidrico bb WHERE a.via_administracion = b.codigo AND b.tipo_liquido IN ('E','I','M') AND a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" AND a.adm_secuencia = ");
sbSql.append(noAdmision);
sbSql.append(sbFilter);

if (fp.trim().equalsIgnoreCase("exp_kardex")) {
    sbSql.append(" and bb.codigo = (select max(codigo) from tbl_sal_balance_hidrico where pac_id = bb.pac_id and secuencia = bb.secuencia)");
}

sbSql.append(" and bb.fecha = a.fecha and bb.codigo = a.cod_balance and bb.secuencia = a.adm_secuencia and bb.pac_id = a.pac_id  ");
sbSql.append(" group by to_char(a.fecha,'dd/mm/yyyy'), to_char(a.hora,'hh12:mi am'), a.via_administracion, b.descripcion, a.fluido, b.tipo_liquido, bb.usuario_creacion||'/'||bb.usuario_modificacion order by 7 desc, to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') desc, to_date(to_char(a.hora,'hh12:mi am'),'hh12:mi am')");
al = SQLMgr.getDataList(sbSql);

//if (request.getMethod().equalsIgnoreCase("GET")) {

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
	String subtitle = desc;
	String xtraSubtitle = sbSubtitle.toString();
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
    
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
		dHeader.addElement(".07");
		dHeader.addElement(".06");
		
		dHeader.addElement(".15");
		
		dHeader.addElement(".18");
		dHeader.addElement(".31");
		dHeader.addElement(".13");
		dHeader.addElement(".10");
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		// el Encabezado del PDF tiene estos 9 parametros definidos el inicio en JspUseBeans
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(1);//create de table header (n rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 1);
	pc.addBorderCols("FECHA",1);   // Se crean las Columnas del vector detalle en este caso son 6
	pc.addBorderCols("HORA",1);
	pc.addBorderCols("USUARIO",1);
	pc.addBorderCols("VIA ADMINISTRACION",1);
	pc.addBorderCols("DESCRIPCION",1);
	pc.addBorderCols("FLUIDO",1);
	pc.addBorderCols("CANTIDAD",1);

	pc.setFont(8, 0);
	pc.addBorderCols("Liquidos Administrados",0,dHeader.size(),0.0f,0.10f,0.0f,0.0f);

	pc.setFont(7, 1);

	String tipoLiqui = "";  //Tipo Liquidos
	double totalAdminis = 0;
	double totalElimini = 0;
	double totalBalance = 0;

	for (int i=0; i<al.size(); i++) {

		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (cdo.getColValue("tipo_Liquido").equalsIgnoreCase("I")) totalAdminis += Double.parseDouble(cdo.getColValue("Cantidad"));
		else totalElimini += Double.parseDouble(cdo.getColValue("Cantidad"));

		if ( (!tipoLiqui.equals(cdo.getColValue("Tipo_Liquido")) && i != 0) || (cdo.getColValue("Tipo_Liquido").equalsIgnoreCase("E") && i == 0) ) {

			pc.setFont(8, 0);
			pc.addCols("Total Administrados",2,6);
			pc.addCols(CmnMgr.getFormattedDecimal(totalAdminis),2,1);

			pc.addBorderCols("Liquidos Eliminados",0,dHeader.size(),0.0f,0.10f,0.0f,0.0f);

		}

		pc.setFont(7, 0);
		pc.addBorderCols(cdo.getColValue("fecha"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("hora"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("usuario"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("via_administracion"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("Descripcion"),0,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(cdo.getColValue("Fluido"),1,1,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("Cantidad")),2,1,0.0f,0.0f,0.0f,0.0f);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		tipoLiqui = cdo.getColValue("tipo_Liquido");

	}

	totalBalance = totalAdminis - totalElimini ;

	if (al.size() != 0) {

		if (tipoLiqui.equalsIgnoreCase("I")) {

			pc.setFont(8, 0);
			pc.addCols("Total Administrados",2,6);
			pc.addCols(""+totalAdminis,1,1);

		}

		pc.setFont(8, 0);
		pc.addCols("Total Eliminados",2,6);
		pc.addCols(CmnMgr.getFormattedDecimal(totalElimini),2,1);
		pc.addCols("B A L A N C E",2,6);
		pc.addCols(CmnMgr.getFormattedDecimal(totalBalance),2,1);

	}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}

//}//GET
%>