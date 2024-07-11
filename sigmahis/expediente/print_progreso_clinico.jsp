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
REPORTE:  PROGRESO CLINICO
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

CommonDataObject cdoPacData = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String desc = request.getParameter("desc");
String code = request.getParameter("code");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (code == null || "".equals(code)) code = "0";

//PROGRESO CLINICO
sbSql.append("select 'P' as type, a.progreso_id as id, a.fecha as sort_by, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha,'hh12:mi am') as hora, a.medico, ' ' as especialidad, a.observacion");
sbSql.append(", (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.medico) as reg_medico");
sbSql.append(", (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombre_medico");
sbSql.append(", ' ' as especialidad_desc from tbl_sal_progreso_clinico a where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admision = ");
sbSql.append(noAdmision);
sbSql.append(" and a.status = 'A'");

if (!code.equals("0")) {
	sbSql.append(" and a.progreso_id = ");
	sbSql.append(code);
}

//INTERCONSULTA
sbSql.append(" union all select 'I' as type, a.codigo as id, to_date(to_char(a.fecha,'dd/mm/yyyy') || to_char(a.hora,'hh12:mi am'),'dd/mm/yyyyhh12:mi am') as sort_by, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi am') as hora, a.medico, nvl(a.cod_especialidad,' ') as especialidad, (select join(cursor(select rownum||'. '||nvl(observacion,' ') from tbl_sal_diagnostico_inter_esp where pac_id = a.pac_id and secuencia = a.secuencia and cod_interconsulta = a.codigo order by codigo),chr(13)) from dual) as observacion");
sbSql.append(", (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.medico) as reg_medico");
sbSql.append(", (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombre_medico");
sbSql.append(", (select descripcion from tbl_adm_especialidad_medica where codigo = a.cod_especialidad) as especialidad_desc");
sbSql.append(" from tbl_sal_interconsultor_espec a where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.secuencia = ");
sbSql.append(noAdmision);

if (!code.equals("0")) {
	sbSql.append(" and a.codigo = ");
	sbSql.append(code);
}

sbSql.append(" and exists (select null from tbl_sal_diagnostico_inter_esp where pac_id = a.pac_id and secuencia = a.secuencia)");
sbSql.append(" order by sort_by desc, id desc");
al = SQLMgr.getDataList(sbSql.toString());

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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
		cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector dHeader = new Vector();
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".10");


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(fontSize, 1,Color.gray);
	pc.addBorderCols("PROGRESO CLINICO",0,dHeader.size());

	pc.setVAlignment(0);
	String groupBy = "";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("fecha")+"-"+cdo.getColValue("medico")))
			{ // groupBy
					if (i != 0)
				 {
						pc.addCols(" ",0,dHeader.size(),cHeight);
						pc.addCols(" ",0,dHeader.size(),cHeight);
				 }
					pc.setFont(fontSize, 1);
					pc.addBorderCols(((cdo.getColValue("type").equalsIgnoreCase("I"))?"Interconsultor: [ "+cdo.getColValue("especialidad_desc")+" ] ":"Médico: ")+cdo.getColValue("nombre_medico"),0,3);
					pc.addBorderCols("Fecha: "+cdo.getColValue("fecha"),1,2);
			}
					pc.setFont(fontSize, 3);
					pc.addCols("HORA: ",1,1);
					pc.setFont(fontSize, 1);
					pc.addCols("OBSERVACION DEL MEDICO",0,4);

					pc.setFont(fontSize, 3);
					pc.addBorderCols(cdo.getColValue("hora"),1,1,0.5f,0.0f,0.0f,0.0f);
					pc.setFont(fontSize, 0);
					pc.addBorderCols(cdo.getColValue("observacion"),0,5,0.5f,0.0f,0.0f,0.0f);

		groupBy = cdo.getColValue("fecha")+"-"+cdo.getColValue("medico");
	}
	pc.addCols(" ",1,dHeader.size());
if ( al.size() == 0 ){
		pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>