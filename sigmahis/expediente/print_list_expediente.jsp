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
String sql = "";
String careDate = request.getParameter("careDate");
String appendFilter = request.getParameter("appendFilter");
String corteFilter = request.getParameter("corteFilter");
String userName = UserDet.getUserName();
String nRecs = request.getParameter("nRecs");
if (nRecs == null) nRecs = "1000";
String aseguradora = request.getParameter("aseguradora");
String medico = request.getParameter("medico");
String categoria = request.getParameter("categoria");
String fp = request.getParameter("fp");

if (!UserDet.getUserProfile().contains("0") && CmnMgr.getCount("select count(*) from tbl_sec_profiles a, tbl_sec_module b where a.profile_id in ("+CmnMgr.vector2numSqlInClause(UserDet.getUserProfile())+") and a.module_id=b.id and a.module_id=11")==0) throw new Exception("Usted no tiene el Perfil para accesar al Expediente. Por favor consulte con su administrador!");
if (!UserDet.getUserProfile().contains("0") && !UserDet.getRefType().equalsIgnoreCase("A") && fp.equalsIgnoreCase("aseguradora")) throw new Exception("Usted no es un usuario de tipo Aseguradora. Por favor consulte con su administrador!");

if (aseguradora == null) aseguradora = (UserDet.getRefType().equalsIgnoreCase("A"))?UserDet.getRefCode():"";
if (medico == null) medico = (UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"";
if (categoria == null) categoria = "";
if (fp == null) fp = "";
if (careDate == null) careDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (appendFilter == null) appendFilter = "";
if (corteFilter == null) corteFilter = "";

StringBuffer sbSql = new StringBuffer();
/* * * * *   C O L U M N S   * * * * */
sbSql.append("select distinct to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia, to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am') as fechaIngreso, a.medico, a.pac_id as pacId, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as cedulaPasaporte, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente, a.am_pm as amPm, decode(y.adm_root,null,a.estado,y.estado) as estado, to_date(to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') as inDate, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),null) as edad, decode(a.tipo_admision,13,1/*inyectable*/,0) as displayIcon, a.categoria, d.estado as estadoAtencion, d.hora_proceso as horaProcesoAtencion, d.hora_finalizado as horaFinalizadoAtencion, coalesce(d.cama,decode(a.categoria,1,'SIN ASIGNAR',' ')) as cama, lpad(d.cds,3,'0') as cds");
//medico
sbSql.append(", (select decode(c.sexo,'F','DRA. ','M','DR. ')||c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) from tbl_adm_medico c where c.codigo=a.medico) as nombreMedico");
//aseguradora
if (fp.equalsIgnoreCase("aseguradora")) {
	sbSql.append(", (select join(cursor(select nvl(h.nombre,' ') from tbl_adm_beneficios_x_admision g, tbl_adm_empresa h where nvl(g.estado,'A') = 'A' and g.pac_id = a.pac_id and g.admision = a.secuencia and g.empresa = h.codigo order by g.prioridad),'~') from dual) as empresa_nombre");
} else {
	sbSql.append(", nvl((select (select nombre from tbl_adm_empresa where codigo = g.empresa) from tbl_adm_beneficios_x_admision g where nvl(estado,'A') = 'A' and pac_id = a.pac_id and admision = a.secuencia and prioridad = 1 and rownum = 1),' ') as empresa_nombre");
}

//categoria signos vitales del dia ingreso (del día que ingreso) o fecha antencion (del dia de hoy)
sbSql.append(", decode((select categoria from tbl_sal_signo_paciente z where pac_id = a.pac_id and secuencia = a.secuencia and tipo_persona = 'T' and status = 'A' and hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and tipo_persona = 'T' and status = 'A'");
//if (!careDate.trim().equals("")){ sbSql.append(" and fecha = to_date('"); sbSql.append(careDate); sbSql.append("','dd/mm/yyyy')"); }
//else sbSql.append(" and fecha = trunc(a.fecha_ingreso)");
sbSql.append(")),1,'I',2,'II',3,'III',(select nombre_corto from tbl_adm_categoria_admision where codigo = a.categoria)) as categoriaSigno");
sbSql.append(", nvl((select categoria from tbl_sal_signo_paciente z where pac_id = a.pac_id and secuencia = a.secuencia and tipo_persona = 'T' and status = 'A' and hora = (select max(hora) from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and tipo_persona = 'T' and status = 'A'");
//if (!careDate.trim().equals("")){ sbSql.append(" and fecha = to_date('"); sbSql.append(careDate); sbSql.append("','dd/mm/yyyy')"); }
//else sbSql.append(" and fecha = trunc(a.fecha_ingreso)");
sbSql.append(")),0) as cat_triage");

//notas enfermeria
sbSql.append(", (select decode(nvl(sum(decode(z.estado,'P',1,0)),0),0,decode(nvl(sum(decode(z.estado,'F',1,0)),0),0,0/*blank*/,1/*check*/),-1/*flag_red*/) from tbl_sal_notas_enfermeria z, tbl_sal_resultado_nota y where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id=y.pac_id and z.secuencia=y.secuencia and z.fecha=y.fecha_nota and z.hora=y.hora and y.estado='A') as neIcon");
//admisiones cortes
sbSql.append(", nvl(y.secuencia,a.secuencia) as secuenciaCorte");
//ordenes medicas (total y ejecutadas)
sbSql.append(", (select nvl(sum(decode(z.ejecutado,'S',1,0)),0)||'/'||count(*) as executed from tbl_sal_detalle_orden_med z, tbl_adm_admision y where y.pac_id=z.pac_id and y.secuencia=z.secuencia and y.pac_id=a.pac_id and y.adm_root=a.secuencia and z.omitir_orden='N' and z.estado_orden='A') as nOrdenMedExec,to_char(b.f_nac,'dd/mm/yyyy') as f_nac");

/* * * * *   T A B L E S   * * * * */
sbSql.append(" from tbl_adm_admision a, vw_adm_paciente b, tbl_adm_atencion_cu d");
//admisiones cortes
sbSql.append(", (select pac_id, secuencia, adm_root, estado, categoria, fecha_ingreso, fecha_egreso from tbl_adm_admision where (pac_id, secuencia) in (select pac_id, max(secuencia) from tbl_adm_admision where corte_cta is not null");
sbSql.append(" and compania=");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(corteFilter);
sbSql.append(" group by pac_id, adm_root)) y");

/* * * * *   F I L T E R S   * * * * */
sbSql.append(" where a.compania=");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter);
sbSql.append(" and a.pac_id=b.pac_id and a.pac_id=d.pac_id and a.secuencia=d.secuencia");
if (fp.equalsIgnoreCase("aseguradora")) {

	sbSql.append(" and exists (select null from tbl_adm_beneficios_x_admision where nvl(estado,'A') = 'A' and pac_id = a.pac_id and admision = a.secuencia");
	if (!aseguradora.trim().equals("")) {
		sbSql.append(" and empresa = ");
		sbSql.append(aseguradora);
	}
	sbSql.append(")");
	if (!categoria.trim().equals("")) {
		sbSql.append(" and a.categoria = ");
		sbSql.append(categoria);
	}

} else if (fp.equalsIgnoreCase("medico")) {

		sbSql.append(" and (");
			sbSql.append("a.medico = '");
			sbSql.append(medico);
			sbSql.append("' or a.medico_cabecera = '");
			sbSql.append(medico);
			sbSql.append("'");
			//P R O G R E S O   C L I N I C O
			sbSql.append(" or exists (select null from tbl_sal_progreso_clinico where pac_id = a.pac_id and admision = a.secuencia and medico = '");
			sbSql.append(medico);
			sbSql.append("')");
			//I N T E R C O N S U L T A S
			sbSql.append(" or exists (select null from tbl_sal_interconsultor where pac_id = a.pac_id and secuencia = a.secuencia and medico = '");
			sbSql.append(medico);
			sbSql.append("')");
			sbSql.append(" or exists (select null from tbl_sal_interconsultor_espec where pac_id = a.pac_id and secuencia = a.secuencia and medico = '");
			sbSql.append(medico);
			sbSql.append("')");
			//A N E S T E S I O L O G O
			sbSql.append(" or exists (select null from tbl_sal_eval_preanestesica where pac_id = a.pac_id and admision = a.secuencia and cod_anestesiologo = '");
			sbSql.append(medico);
			sbSql.append("')");
		sbSql.append(")");

}
//admisiones cortes
sbSql.append(" and a.pac_id=y.pac_id(+) and a.secuencia=y.adm_root(+)");

sbSql.append(" order by to_date(to_char(a.fecha_ingreso,'dd/mm/yyyy')||' '||to_char(a.am_pm,'hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') desc");
al = SQLMgr.getDataList("select * from ("+sbSql.toString()+") where rownum<="+nRecs);

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
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".02");
		dHeader.addElement(".02");
		dHeader.addElement(".04");
		dHeader.addElement(".07");
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".11");
		dHeader.addElement(".42");
		dHeader.addElement(".04");
		dHeader.addElement(".07");
		dHeader.addElement(".08");
		dHeader.addElement(".0175");//.0325
		dHeader.addElement(".015");
		dHeader.addElement(".0175");//.0325

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("N.E.",1);
		pc.addBorderCols(" ",1);
		pc.addBorderCols("Cat.",1);
		pc.addBorderCols("Fecha Nac.",1);
		pc.addBorderCols("Cód. Pac.",1);
		pc.addBorderCols("No. Adm.",1);
		pc.addBorderCols("Cédula / Pasaporte",1);
		pc.addBorderCols("Paciente",1);
		pc.addBorderCols("Edad",1);
		pc.addBorderCols("Ord. Méd. Ejec.",1);
		pc.addBorderCols("Fecha Ingreso",1);
		pc.addBorderCols("Estado",1,3);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	int imgSize = 7;
	String imgPath = ResourceBundle.getBundle("path").getString("images");
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		String neIcon = "/blank.gif";
		if (cdo.getColValue("neIcon").equals("1")) neIcon = "/check.gif";
		else if (cdo.getColValue("neIcon").equals("-1")) neIcon = "/flag_red.gif";

		String displayIcon = "/blank.gif";
		if (cdo.getColValue("displayIcon").equals("1")) displayIcon = "/syringe.gif";

		int sep = cdo.getColValue("nOrdenMedExec").indexOf("/");
		int exe = Integer.parseInt(cdo.getColValue("nOrdenMedExec").substring(0,sep));
		int tot = Integer.parseInt(cdo.getColValue("nOrdenMedExec").substring(sep+1));

		String statusIcon = "/blank.gif";
		if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("E")) statusIcon = "/lampara_roja.gif";
		else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("T")) statusIcon = "/lampara_amarilla.gif";
		else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("P")) statusIcon = "/lampara_verde.gif";
		else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("F")) statusIcon = "/lampara_blanca.gif";
		else if (cdo.getColValue("estadoAtencion").equalsIgnoreCase("Z")) statusIcon = "/lampara_gris.png";

		pc.setFont(7, 0);
		pc.setVAlignment(0);

		pc.addCols("Aseguradora: "+cdo.getColValue("empresa_nombre"),0,7);
		pc.addCols("Médico: [ "+cdo.getColValue("medico")+" ] "+cdo.getColValue("nombreMedico"),0,1);
		pc.addCols(((!cdo.getColValue("cama").trim().equals(""))?"Cama: "+cdo.getColValue("cama"):" "),0,2);
		pc.addCols("Area: "+cdo.getColValue("cds"),1,4);

		pc.addImageCols(imgPath+neIcon,imgSize,1);
		pc.addImageCols(imgPath+displayIcon,imgSize,1);
		pc.setFont(7, 0, Color.RED);
		pc.addCols(cdo.getColValue("categoriaSigno"),1,1);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("f_nac"),1,1);
		pc.addCols(cdo.getColValue("codigoPaciente"),1,1);
		pc.addCols(cdo.getColValue("secuencia"),1,1);
		pc.addCols(cdo.getColValue("cedulaPasaporte"),0,1);
		pc.setFont(7, 0, Color.BLUE);
		pc.addCols(cdo.getColValue("nombrePaciente"),0,1);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("edad"),1,1);
		if (exe != tot) pc.setFont(7, 0, Color.RED);
		pc.addCols(((tot != 0)?exe+"/"+tot:""),1,1);
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("fechaIngreso"),1,1);
		pc.addCols(" ",1,1);
		pc.addImageCols(imgPath+statusIcon,imgSize,1);
		pc.addCols(" ",1,1);

		if ((i % 20 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>