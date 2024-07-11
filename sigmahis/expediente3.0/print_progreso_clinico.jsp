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
ArrayList alIC = new ArrayList();
ArrayList alICDet = new ArrayList();
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

if (code == null) code = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

//PROGRESO CLINICO.
sbSql.append("select a.progreso_id, a.pac_id, a.admision,to_char(a.fecha,'dd/mm/yyyy') fecha,to_char(a.fecha,'hh12:mi am') hora, a.medico, a.observacion, am.primer_nombre||decode(am.segundo_nombre,'','',' '||am.segundo_nombre)||' '||am.primer_apellido|| decode(am.segundo_apellido, null,'',' '||am.segundo_apellido)||decode(am.sexo,'f', decode(am.apellido_de_casada,'','',' '||am.apellido_de_casada)) as nombre_medico, a.otros, decode(a.status,'A', 'ACTIVO', 'I', 'INVALIDA') as status_dsp, get_idoneidad(a.usuario_creacion,1) usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') fecha_creacion, decode(fecha_modificacion, null, ' ', '      El: '||to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi am')||' / '||usuario_modificacion ) modified from tbl_sal_progreso_clinico a,tbl_adm_medico am where a.pac_id = ");
sbSql.append(pacId);
sbSql.append(" and a.admision=");
sbSql.append(noAdmision);

if (!code.trim().equals("0")) {
	sbSql.append(" and a.progreso_id = ");
	sbSql.append(code);
} else {
	sbSql.append(" and a.status = 'A'");
}
sbSql.append(" and a.medico=am.codigo order by a.fecha desc");
al = SQLMgr.getDataList(sbSql.toString());

if (code.trim().equals("0")) {
	//interconsulta
	sbSql = new StringBuffer();
	sbSql.append("select a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.medico, nvl(a.cod_especialidad,' ') as especialidad, a.observacion, a.comentario, get_idoneidad(a.usuario_creacion,1) usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, get_idoneidad(a.usuario_modificacion,1) usuario_modificacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, to_char(a.hora,'hh12:mi:ss am') as hora");
	sbSql.append(", (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = a.medico) as nombre_medico");
	sbSql.append(", (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.medico) as reg_medico");
	sbSql.append(", (select descripcion from tbl_adm_especialidad_medica where codigo = a.cod_especialidad) as especialidad_desc");
	sbSql.append(" from tbl_sal_interconsultor_espec a where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" and exists (select null from tbl_sal_diagnostico_inter_esp where pac_id = a.pac_id and secuencia = a.secuencia) order by a.fecha_creacion desc");
	alIC = SQLMgr.getDataList(sbSql.toString());
}

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

	Vector dIC = new Vector();//72 * 8.5 - (2 * 9) = 594
		dIC.addElement("35.64");
		dIC.addElement("207.9");
		dIC.addElement("148.5");
		dIC.addElement("100.98");
		dIC.addElement("100.98");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(fontSize, 1);
	pc.addCols("PROGRESO CLINICO",0,dHeader.size(),Color.lightGray);
	pc.addCols("",0,dHeader.size());

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
					pc.addCols("Por: "+cdo.getColValue("usuario_creacion"," "),0,1,cHeight);
					pc.addCols("El: "+cdo.getColValue("fecha_creacion"," "),0,1,cHeight);
					pc.addCols("Estado: "+cdo.getColValue("status_dsp"," ")+"              "+cdo.getColValue("modified"," "),0,3,cHeight);

					pc.addBorderCols("Médico: "+cdo.getColValue("nombre_medico"," "),0,3);
					pc.addBorderCols("Fecha: "+cdo.getColValue("fecha"," "),1,2);
			}
					pc.setFont(fontSize, 1);
					pc.addCols("OBSERVACION DEL MEDICO",0,3);
					pc.setFont(fontSize, 3);
					pc.addCols(cdo.getColValue("hora"),1,2);

										pc.addCols(" ",0,dHeader.size(),cHeight);
					pc.setFont(fontSize, 0);
					pc.addBorderCols("     "+cdo.getColValue("observacion", " "),0,5,0.5f,0.0f,0.0f,0.0f);



										pc.addCols(" ",1,dHeader.size());
										pc.setFont(fontSize, 1);
										pc.addCols("PLAN DE CUIDADO MÉDICO (SOAP)",0,dHeader.size(),Color.lightGray);

										ArrayList alSOAP = SQLMgr.getDataList("select h.codigo, h.descripcion, d.soap_id, d.seleccionar from tbl_sal_progreso_clinico_soap h, tbl_sal_progreso_clinico_det d where h.codigo = d.soap_id(+) and h.status = 'A' and d.pac_id(+) = "+pacId+" and admision(+) = "+noAdmision+" and d.progreso_id(+) = "+cdo.getColValue("progreso_id","0")+" order by h.orden");

										Vector tblSOAP = new Vector();
										tblSOAP.addElement("76");
										tblSOAP.addElement("9");
										tblSOAP.addElement("3");
										tblSOAP.addElement("9");
										tblSOAP.addElement("3");

										pc.setNoColumnFixWidth(tblSOAP);
										pc.createTable("tblSOAP",false);

										pc.setFont(fontSize, 0);
										for (int d = 0; d < alSOAP.size(); d++){
											 CommonDataObject cdoD = (CommonDataObject) alSOAP.get(d);
											 pc.addBorderCols(cdoD.getColValue("descripcion"),0,1);
											 pc.addBorderCols("SI",1,1);
											 pc.addImageCols( (cdoD.getColValue("seleccionar")!=null && cdoD.getColValue("seleccionar").equalsIgnoreCase("S"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);

											 pc.addBorderCols("NO",1,1);
											 pc.addImageCols( (cdoD.getColValue("seleccionar")!=null && cdoD.getColValue("seleccionar").equalsIgnoreCase("N"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",0,1);
										}

										pc.useTable("main");
										pc.addTableToCols("tblSOAP",0,dHeader.size(),0);


										pc.addCols(" ",1,dHeader.size());
										pc.setFont(fontSize, 1);
										pc.addCols("OTROS PLANES DE CUIDADO",0,dHeader.size(),Color.lightGray);

										pc.setFont(fontSize, 0);
										pc.addCols(cdo.getColValue("otros"),0,dHeader.size());

		groupBy = cdo.getColValue("fecha")+"-"+cdo.getColValue("medico");
	}

	if (alIC.size() > 0) {

		pc.useTable("main");
		pc.addCols(" ",1,dHeader.size());
		pc.setFont(fontSize, 1);
		pc.addCols("INTERCONSULTAS",0,dHeader.size(),Color.lightGray);
		pc.addCols("",0,dHeader.size());

		pc.setNoColumnFixWidth(dIC);
		pc.createTable("interconsulta",false,0,(2 * leftRightMargin));
			pc.setFont(fontSize,1,Color.white);
			pc.addBorderCols("#",1,1,Color.gray);
			pc.addBorderCols("Médico",1,1,Color.gray);
			pc.addBorderCols("Especialidad",1,1,Color.gray);
			pc.addBorderCols("Registrado Por",1,1,Color.gray);
			pc.addBorderCols("Modificado Por",1,1,Color.gray);

		for (int i = 0; i < alIC.size(); i++) {
			CommonDataObject cdoIC = (CommonDataObject) alIC.get(i);
			pc.setFont(fontSize,0);
			pc.addCols(cdoIC.getColValue("codigo"),0,1);
			pc.addCols("[" + cdoIC.getColValue("reg_medico") + "] " + cdoIC.getColValue("nombre_medico"),0,1);
			pc.addCols(cdoIC.getColValue("especialidad_desc"),0,1);
			pc.addCols(cdoIC.getColValue("usuario_creacion") + " " + cdoIC.getColValue("fecha_creacion"),2,1);
			pc.addCols(cdoIC.getColValue("usuario_modificacion") + " " + cdoIC.getColValue("fecha_modificacion"),2,1);

			sbSql = new StringBuffer();
			sbSql.append("select cod_interconsulta, diagnostico, nvl(observacion,' ') as observacion, codigo from tbl_sal_diagnostico_inter_esp where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and secuencia = ");
			sbSql.append(noAdmision);
			sbSql.append(" and cod_interconsulta = ");
			sbSql.append(cdoIC.getColValue("codigo"));
			sbSql.append(" order by codigo");
			alICDet = SQLMgr.getDataList(sbSql.toString());
			pc.setNoColumn(1);
			pc.createTable("notas",false,0,(2 * leftRightMargin) - 35.64f);
			for (int j = 0; j < alICDet.size(); j++) {
				CommonDataObject cdo = (CommonDataObject) alICDet.get(j);
				pc.addCols((1+j)+". "+cdo.getColValue("observacion"),0,1);
			}
			if (i < alIC.size() - 1) pc.addCols(" ",0,1,5f);

			pc.useTable("interconsulta");
			pc.setFont(fontSize,1);
			pc.addCols("NOTAS:",0,1);
			pc.setFont(fontSize,0);
			pc.addTableToCols("notas",0,dIC.size() - 1);
		}

		pc.useTable("main");
		pc.addTableToCols("interconsulta",0,dHeader.size());

	}

		if ( al.size() == 0 && alIC.size() == 0){
				pc.addCols("No hemos encontrado datos!",1,dHeader.size());
		}
pc.useTable("main");
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>