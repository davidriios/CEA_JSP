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
REPORTE: SIGNOS VITALES
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

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";

sql = "select decode(a.tipo_persona,'A','auxiliar','M','médico','E','enfermera','T','triage','---') as tipoPersona, nvl(a.observacion,' ') as observacion, nvl(a.accion,' ') as accion, decode(a.categoria,'1','I','2','II','3','III',categoria) as categoria, decode(evacuacion,'S','[ X ]','[__]') as evacuacion, decode(miccion,'S','[ X ]','[__]') as miccion, decode(vomito,'S','[ X ]','[__]') as vomito, nvl(evacuacion_obs,' ') as evacuacionObs, nvl(miccion_obs,' ') as miccionObs, nvl(vomito_obs,' ') as vomitoObs, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, to_char(a.hora_registro,'hh12:mi:ss am') as horaRegistro,   a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion,   to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif ,   d.signo_vital as signoVital,  nvl(d.resultado,' ') resultado, b.descripcion as signoDesc, nvl(c.sigla_um,' ') as signoUnit  from tbl_sal_signo_paciente a ,   tbl_sal_detalle_signo d, tbl_sal_signo_vital b, tbl_sal_signo_vital_um c  where a.pac_id= "+pacId+" and a.secuencia= "+noAdmision+" and a.status = 'A'  and  d.pac_id = a.pac_id   and  d.secuencia = a.secuencia   and  d.fecha_signo = a.fecha   and  d.hora = a.hora   and  d.tipo_persona = a.tipo_persona    and d.signo_vital=b.codigo and d.signo_vital=c.cod_signo(+) and c.valor_default(+)='S'  order by a.fecha, a.hora";
al = SQLMgr.getDataList(sql);

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
	String subtitle = "SIGNOS VITALES";
	String xtraSubtitle = "";
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
		cdoPacData.addColValue("is_landscape",""+isLandscape);}

PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".40");
		dHeader.addElement(".20");
		dHeader.addElement(".20");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


	String groupBy = "";
	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("fecha")+" "+cdo.getColValue("hora")) )
			{ // groupBy
					if (i != 0)
				 {
						pc.addCols(" ",0,dHeader.size(),cHeight);
				 }

					pc.setFont(8, 1);
					pc.addBorderCols("Fecha: "+cdo.getColValue("fecha"),0,2);
					pc.addBorderCols("Hora: "+cdo.getColValue("hora"),0,2);
					pc.addBorderCols("Evacuación:",2,1);
					pc.addBorderCols(cdo.getColValue("evacuacion")+" - Observación:  "+cdo.getColValue("evacuacionObs"),0,3);
					pc.addBorderCols("Micción:",2,1);
					pc.addBorderCols(cdo.getColValue("miccion")+" - Observación:  "+cdo.getColValue("miccionObs"),0,3);
					pc.addBorderCols("Vómito:",2,1);
					pc.addBorderCols(cdo.getColValue("vomito")+" - Observación:  "+cdo.getColValue("vomitoObs"),0,3);
					pc.addBorderCols("Observación",0,2);
					pc.addBorderCols("Acción",0,2);

					pc.setFont(8, 0);
					pc.addBorderCols(" "+cdo.getColValue("observacion"),0,2);
					pc.addBorderCols(" "+cdo.getColValue("accion"),0,2);

					pc.setFont(7, 1);
					pc.addBorderCols("REGISTRADO POR",1);
					pc.addBorderCols("SIGNO",1);
					pc.addBorderCols("VALOR",1);
					pc.addBorderCols("UNIDAD",1);

			}

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("tipoPersona")+" - "+cdo.getColValue("usuarioCreacion"),1,0);
		pc.addCols(cdo.getColValue("signoDesc"),0,0);
		pc.addCols(cdo.getColValue("resultado"),1,0);
		pc.addCols(cdo.getColValue("signoUnit"),1,0);

		groupBy = cdo.getColValue("fecha")+" "+cdo.getColValue("hora");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.setFont(8, 1);
	pc.addBorderCols("",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

	if ( al.size() == 0 ){
		pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>