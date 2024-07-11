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

CommonDataObject cdoPacData  = new CommonDataObject();
CommonDataObject cdo  = new CommonDataObject();
StringBuffer sql = new StringBuffer();
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String appendFilter = request.getParameter("appendFilter");
String fg = request.getParameter("fg");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "N";
if (desc == null) desc = "";


	sql.append("SELECT a.cod_paciente, a.secuencia, to_char(a.fec_nacimiento,'dd/mm/yyyy') as fec_nacimiento, a.pac_id, nvl(decode(a.hospitalizar,'S','SI','N','NO'),' ') as hospitalizar, nvl(a.transf,' ') as transf, nvl(to_char(a.hora_transf,'hh12:mi am'),' ') as hora_transf, nvl(nvl(a.icd10,a.cod_diag_sal),' ') as cod_diag_sal, nvl(to_char(a.hora_salida,'hh12:mi am'),' ') as hora_salida, nvl(a.cond,' ') as cond, decode(a.hora_incap,null,' ',''||a.hora_incap) as hora_incap, nvl(to_char(a.horai_incap,'hh12:mi am'),' ') as horai_incap, nvl(to_char(a.horaf_incap,'hh12:mi am'),' ') as horaf_incap, decode(a.dia_incap,null,' ',''||a.dia_incap) as dia_incap, nvl(to_char(a.diai_incap,'dd/mm/yyyy'),' ') as diai_incap, nvl(to_char(a.diaf_incap,'dd/mm/yyyy'),' ') as diaf_incap, nvl(a.instruccion_med,' ') as instruccion, nvl(a.cod_medico,' ') as cod_medico, nvl(a.cod_medico_turno,' ') as cod_medico_turno, nvl(a.cod_especialidad_ce,' ') as cod_especialidad_ce, nvl(a.especialista_p,' ') as especialista_p, nvl(a.estado,' ') as estado, nvl(a.observacion,' ') as observacion, decode(a.cod_diag_sal,null,' ',(SELECT coalesce(observacion,nombre) FROM tbl_cds_diagnostico WHERE codigo=a.cod_diag_sal)) as nombre_diagnostico, decode(a.cod_medico,null,' ',(SELECT primer_nombre||decode(segundo_nombre,null,' ','  '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ','  '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.cod_medico)) as medico_ref, decode(a.cod_medico_turno,null,' ',(SELECT primer_nombre||decode(segundo_nombre,null,' ',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',' '||apellido_de_casada)) as nombre FROM tbl_adm_medico WHERE codigo=a.cod_medico_turno)) as medico_turn, decode(a.cod_especialidad_ce,null,' ',(SELECT descripcion FROM tbl_adm_especialidad_medica WHERE codigo=a.cod_especialidad_ce)) AS especialidad_nom,to_char(a.finaliza_fecha,'dd/mm/yyyy')finaliza_fecha,nvl(decode(a.hora_incap,null,decode(a.dia_incap,null,null,a.dia_incap||' DIA(S) DESDE '||to_char(a.diai_incap,'DD/MM/YYYY')||' HASTA '||to_char(a.diaf_incap,'DD/MM/YYYY')),a.hora_incap||' HORA(S) DESDE '||to_char(a.horai_incap,'HH12:MI AM')||' HASTA '||to_char(a.horaf_incap,'HH12:MI AM')), ' ') v_incapacidad ,(select primer_nombre||' '||segundo_nombre||' '||decode(apellido_de_casada,null,primer_apellido||' '||segundo_apellido,apellido_de_casada) from tbl_adm_medico where codigo = a.cod_medico)v_consulta_externa,decode(a.cond,null,'','M','MEJOR' ,'I','IGUAL','S','PEOR','F','FALLECIO') as condicion,to_char(a.finaliza_fecha,'dd/mm/yyyy hh12:mi:ss am')finaliza_fecha,a.finaliza_usuario, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion FROM tbl_sal_adm_salida_datos a WHERE pac_id=");
	sql.append(pacId);
	sql.append(" and secuencia=");
	sql.append(noAdmision);
	cdo = SQLMgr.getData(sql.toString());

	if(cdo==null){cdo = new CommonDataObject();

		cdo.addColValue("hospitalizar","NO");
		cdo.addColValue("cond","");
		cdo.addColValue("hora_transf","");
		cdo.addColValue("horaf_incap","");
		cdo.addColValue("diai_incap","");
		cdo.addColValue("horai_incap","");
		cdo.addColValue("diaf_incap","");
		cdo.addColValue("hora_salida","");

		cdo.addColValue("transf","");
		cdo.addColValue("especialista_p","");
		cdo.addColValue("cod_diag_sal","");
		cdo.addColValue("nombre_diagnostico","");
		cdo.addColValue("observacion","");
		cdo.addColValue("finaliza_fecha","");
		cdo.addColValue("v_incapacidad","");
		cdo.addColValue("v_consulta_externa","");
		cdo.addColValue("instruccion","");
		cdo.addColValue("finaliza_fecha","");
		cdo.addColValue("finaliza_usuario","");

	}
	
	if (request.getParameter("cod_diag_sal_tmp") != null && !"".equals(request.getParameter("cod_diag_sal_tmp")) ) {
    cdo.addColValue("cod_diag_sal", request.getParameter("cod_diag_sal_tmp"));
		cdo.addColValue("nombre_diagnostico", request.getParameter("nombre_diag_sal_tmp"));
	}

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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = ""+desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
    
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
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".50");




	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setTableHeader(1);//create de table header (2 rows) and add header to the table

	//table body
		pc.setFont(9, 0);
		pc.setVAlignment(0);

		pc.setFont(fontSize,1);
		pc.addCols("Creado por: "+cdo.getColValue("usuario_creacion")+"   -   "+cdo.getColValue("fecha_creacion"), 0,5);
		pc.addCols("Modificado por: "+cdo.getColValue("usuario_modificacion")+"   -   "+cdo.getColValue("fecha_modificacion"), 0,1);

		pc.addCols("",0,dHeader.size());
		pc.setFont(fontSize,0);
		pc.addBorderCols("ESPECIALISTA PEDIDO X (FAMILIAR O PTE.): "+cdo.getColValue("especialista_p"), 0,dHeader.size());
		pc.addBorderCols("HOSPITALIZACION: "+cdo.getColValue("hospitalizar"), 0,dHeader.size());
		pc.addBorderCols("TRANSFERIDO A: ",0,2);
		pc.addBorderCols(""+cdo.getColValue("transf"),0,3);
		pc.addBorderCols("HORA: "+cdo.getColValue("hora_transf"),0,1);

		pc.addBorderCols("DX DE SALIDA: "+cdo.getColValue("cod_diag_sal")+" - "+cdo.getColValue("nombre_diagnostico"), 0,dHeader.size());
		pc.addBorderCols("OBSERVACIONES "+cdo.getColValue("observacion"),0,dHeader.size());

		pc.addBorderCols("FECHA SALIDA:",0,2);
		pc.addBorderCols(""+cdo.getColValue("finaliza_fecha")+" "+cdo.getColValue("hora_salida"), 0,2);
		pc.addBorderCols("CONDICION: "+cdo.getColValue("condicion"),0,2);

		if(cdo.getColValue("hora_incap")!=null && !cdo.getColValue("hora_incap").trim().equals(""))
		 pc.addBorderCols("CONSTANCIA POR: "+cdo.getColValue("v_incapacidad"), 0,dHeader.size());
		else pc.addBorderCols("INCAPACIDAD POR: "+cdo.getColValue("v_incapacidad"), 0,dHeader.size());

		pc.addBorderCols("  ",0,dHeader.size());


		pc.addBorderCols("REFERIDO A CONSULTA EXTERNA AL DR.: "+cdo.getColValue("v_consulta_externa"), 0,dHeader.size());

		pc.addBorderCols("INSTRUCCIONES AL PACIENTE (MEDICAMENTOS): "+cdo.getColValue("instruccion"), 0,dHeader.size());
		pc.addBorderCols("  ",0,dHeader.size());

		pc.addBorderCols(" USUARIO QUE FINALIZA ATENCION: "+cdo.getColValue("finaliza_usuario"), 0,3);
 		pc.addBorderCols(" FECHA QUE FINALIZA ATENCION: "+cdo.getColValue("finaliza_fecha"), 0,3);


	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}//GET
%>
