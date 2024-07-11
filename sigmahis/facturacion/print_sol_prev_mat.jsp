<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%//@ include file="../common/pdf_header.jsp"%>
<%
/**
======================================================================================
		FG             	REPORTE                DESCRIPCION
										CDC400260_A						 Solicitud Previa de Materiales Medicamentos
======================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String desc ="";
String appendFilter = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");
String codCita = request.getParameter("codCita");
String fechaRegistro = request.getParameter("fechaRegistro");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("admision");

if (pacId == null || pacId.trim().equals("")) pacId = "0";
if (noAdmision == null) noAdmision = "0";

CommonDataObject cdoHeader = new CommonDataObject();
//CommonDataObject cdo = new CommonDataObject();

sbSql.append("select to_char(p.f_nac,'dd/mm/yyyy')fecha_nacimiento, c.codigo, c.nombre_paciente, to_char(c.fecha_cita,'dd/mm/yyyy') fecha_cita, to_char(c.hora_cita,'hh12:mi am') hora_cita, c.habitacion, nvl(c.observacion, (select join(cursor( select nvl(b.observacion, b.descripcion) from tbl_cdc_cita_procedimiento a,tbl_cds_procedimiento b where b.codigo=a.procedimiento and trunc(a.fecha_cita) = c.fecha_registro  and a.cod_cita=c.codigo),'; ') proced from dual)) observacion, c.empresa, c.fec_nacimiento, c.cod_paciente, c.admision, getAseguradora2(c.pac_id, c.admision, c.empresa) aseguradora,  nvl(getfullNombreMedico((select get_sec_comp_param(-1,'COD_FUNC_CIRUJANO') FROM DUAL) , to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') nombre_medico, nvl(getfullNombreMedico((select get_sec_comp_param(-1,'COD_FUNC_ANEST') from dual) , to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') anestesiologo, nvl(getcirculadorfullname((select get_sec_comp_param(-1,'COD_FUNC_INTRUMEN') from dual) , to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') instrumentista, nvl(getcirculadorfullname((select get_sec_comp_param(-1,'COD_FUNC_CIRC') from dual) , to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ') circulador, c.pac_id||' - '||c.admision cuenta,p.sexo,p.edad|| ' A ' || p.edad_mes|| ' M ' || p.edad_dias || ' D ' as edad,se.horaSalidaSa,se.horaEntradaSa,x.horaSalidaAn,x.horaEntradaAn,nvl(getfullNombreMedico(10, to_char(c.fecha_registro,'dd/mm/yyyy')||c.codigo), ' ')asistente from tbl_cdc_cita c,vw_adm_paciente p,( select  nvl(to_char(hora_entrada, 'HH12:mi am'),' ') horaEntradaSa, nvl(to_char(hora_salida, 'HH12:mi am'),' ') horaSalidaSa,cita_fecha_reg fecha_registro,cita_codigo codigo from tbl_cdc_solicitud_enc where cita_codigo = ");
sbSql.append(codCita);
sbSql.append(" and trunc(cita_fecha_reg) = to_date('");
sbSql.append(fechaRegistro);
sbSql.append("', 'dd/mm/yyyy') and (tipo_solicitud = 'Q')");
if (!tipoSolicitud.equals("A")) sbSql.append(" and estado in ('T', 'E')");
sbSql.append(" and rownum = 1 )se,(select  nvl(to_char(hora_entrada, 'HH12:mi am'),' ') horaEntradaAn, nvl(to_char(hora_salida, 'HH12:mi am'),' ') horaSalidaAn,cita_fecha_reg fecha_registro,cita_codigo codigo from tbl_cdc_solicitud_enc where cita_codigo = ");
sbSql.append(codCita);
sbSql.append(" and trunc(cita_fecha_reg) = to_date('");
sbSql.append(fechaRegistro);
sbSql.append("', 'dd/mm/yyyy') and (tipo_solicitud = 'A') and estado in ('T', 'E') and rownum = 1 )x where c.codigo = ");
sbSql.append(codCita);
sbSql.append(" and trunc(c.fecha_registro) = to_date('");
sbSql.append(fechaRegistro);
sbSql.append("', 'dd/mm/yyyy') and c.pac_id = p.pac_id(+) and trunc(c.fecha_registro) = se.fecha_registro(+) and c.codigo=se.codigo(+) and trunc(c.fecha_registro) = x.fecha_registro(+) and c.codigo=x.codigo(+) ");

cdoHeader = SQLMgr.getData(sbSql.toString());
if (cdoHeader == null) cdoHeader = new CommonDataObject();

sbSql = new StringBuffer();
sbSql.append("select 'SOLICITUD' as tipo, a.descripcion desc_articulo, sd.art_familia || '-' || sd.art_clase || '-' || sd.cod_articulo cod_articulo, decode(sd.cantidad, null, ' ', 0, ' ', sd.cantidad) solicitud, decode(sd.entrega, null, ' ', 0, ' ', sd.entrega) entrega, decode(sd.adicion, null, ' ', 0, ' ', sd.adicion) adicion, decode(sd.devolucion, null, ' ', 0, ' ', sd.devolucion) devolucion, decode((nvl(sd.entrega, 0) + nvl(sd.adicion, 0) - nvl(sd.devolucion, 0)), 0, ' ', (nvl(sd.entrega, 0) + nvl(sd.adicion, 0) - nvl(sd.devolucion, 0))) utilizado from tbl_cdc_solicitud_det sd, tbl_cdc_solicitud_enc se, tbl_inv_articulo a where ((a.compania = sd.compania) and a.cod_articulo = sd.cod_articulo and (se.cita_codigo = sd.cita_codigo) and (se.cita_fecha_reg = sd.cita_fecha_reg) and (se.secuencia = sd.secuencia) and (sd.cita_codigo = ");
sbSql.append(codCita);
sbSql.append(") and trunc(sd.cita_fecha_reg) = to_date('");
sbSql.append(fechaRegistro);
sbSql.append("', 'dd-mm-yyyy')) and (se.tipo_solicitud = '");
sbSql.append(tipoSolicitud);
sbSql.append("')");
if (!tipoSolicitud.equals("A")) sbSql.append(" and se.estado in ('T', 'E')");

if (tipoSolicitud.equals("A")){
	sbSql.append(" union all select distinct 'SOLICITUD PREVIA MALETIN', e.descripcion,  a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo as codigos, to_char(a.cantidad), null, null, null, null from tbl_cds_maletin_insumo a, tbl_inv_articulo e where   e.compania =a.compania and a.cod_articulo=e.cod_articulo and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.cod_maletin in (select tipo_maletin_anestesia from tbl_cds_procedimiento where codigo in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = ");
	sbSql.append(codCita);
	sbSql.append(" and trunc(fecha_cita) = to_date('");
	sbSql.append(fechaRegistro);
	sbSql.append("', 'dd/mm/yyyy')) ) order by 1,2 ");
} else {
  sbSql.append(" union all SELECT 'PROCEDIMIENTOS', b.descripcion, a.art_familia||'-'||a.art_clase||'-'||a.articulo, to_char(a.cantidad), null, null, null, null FROM tbl_cds_insumo_x_proc a, tbl_inv_articulo b WHERE a.articulo=b.cod_articulo and a.compania=b.compania and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.cod_proced in(select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = ");
	sbSql.append(codCita);
	sbSql.append(" and trunc(fecha_cita) = to_date('");
	sbSql.append(fechaRegistro);
	sbSql.append("', 'dd/mm/yyyy') ) order by 2");
}
al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
if (tipoSolicitud.equals("A")){
	sbSql.append(" select distinct 'PROCEDIMIENTOS' as tipo, to_char(a.cod_uso) cod_uso, b.descripcion, '-' as cantidad from tbl_cds_maletin_activo a, tbl_sal_uso b where (a.cod_uso = b.codigo and a.compania = b.compania) and exists (select null from tbl_cdc_cita_procedimiento z, tbl_cds_procedimiento y where z.procedimiento = y.codigo and z.cod_cita = ");
	sbSql.append(codCita);
	sbSql.append(" and trunc(z.fecha_cita) = to_date('");
	sbSql.append(fechaRegistro);
	sbSql.append("', 'dd/mm/yyyy') and y.tipo_maletin_anestesia = a.cod_maletin)");
} else {
	sbSql.append(" select distinct 'PROCEDIMIENTOS' as tipo, to_char(a.cod_uso) cod_uso, b.descripcion, to_char(a.cantidad) from tbl_cds_activo_x_proc a, tbl_sal_uso b where (a.cod_uso = b.codigo and a.cod_compania = b.compania) and exists (select 'x' from tbl_cdc_cita_procedimiento where cod_cita = ");
	sbSql.append(codCita);
	sbSql.append(" and procedimiento = a.procedimiento and trunc(fecha_cita) = to_date('");
	sbSql.append(fechaRegistro);
	sbSql.append("', 'dd/mm/yyyy'))");
}
sbSql.append(" union all select 'CARGOS', to_char(dcu.cod_uso), su.descripcion, to_char(dcu.cantidad_uso) as cantidad from tbl_sal_cargos_usos cu, tbl_sal_cargos_det_usos dcu, tbl_sal_uso su where cu.compania = ");
sbSql.append(compania);
sbSql.append(" and cu.pac_id = ");
sbSql.append(pacId);
if (!noAdmision.trim().equals("")) { sbSql.append(" and cu.adm_secuencia = "); sbSql.append(noAdmision); }
sbSql.append(" and (su.codigo = dcu.cod_uso and su.compania = dcu.compania) and dcu.compania = cu.compania and dcu.anio = cu.anio and dcu.secuencia_uso = cu.secuencia and dcu.estado_renglon = 'A' and cu.estado = 'A' and cu.tipo = 'C' and cu.sop ='S' and trunc(cu.fecha_cita) = to_date('");
sbSql.append(fechaRegistro);
sbSql.append("','dd/mm/yyyy') order by 1, 3");
ArrayList alUsos = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int maxLines = 27; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill

	int nItems = al.size();
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines) + (tipoSolicitud.equals("Q") && alUsos.size()>0?1:0);
	else nPages += (nItems / maxLines) + 1 + (tipoSolicitud.equals("Q") && alUsos.size()>0?1:0);
	if (nPages == 0) nPages = 1;
	System.out.println("nPages="+nPages);
	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "facturacion";//print_articulos_consignacion.jsp
	String fileNamePrefix = "print_sol_prev_mat";
	String fileNameSuffix = "";
	String fecha = cDateTime;
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

	String day=fecha.substring(0, 2);
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setHeader = new Vector();
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");
		setHeader.addElement(".16");

	Vector setDetail = new Vector();
		setDetail.addElement(".10");
		setDetail.addElement(".58");
		setDetail.addElement(".06");
		setDetail.addElement(".06");
		setDetail.addElement(".07");
		setDetail.addElement(".07");
		setDetail.addElement(".07");

	String wh = "", groupBy = "",subGroupBy = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 16.0f;

	//pdfHeader(pc, _comp, pCounter, nPages, depto,titulo, userName, fecha);

	pc.setNoColumnFixWidth(setHeader);
	pc.createTable();
		pc.setFont(6, 0);
		pc.addBorderCols("Usuario: "+userName,0,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(fecha,1,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Página: "+pCounter+" de "+nPages,2,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
	pc.addTable();
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("SOLICITUD PREVIA",1,6, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("FECHA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("fecha_cita"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("HORA:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("hora_cita"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("QUIROFANO:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("habitacion"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("PACIENTE:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("nombre_paciente"),0,3, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(7, 0);
		pc.addBorderCols("Cita #:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("codigo"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("SEXO: ",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("sexo"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("EDAD:  ",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("edad"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("CUENTA #:  ",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("cuenta"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("FECHA NAC: ",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(cdoHeader.getColValue("fecha_nacimiento"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		
		pc.addBorderCols("ASEGURADORA: ",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("aseguradora"),0,3, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("CIRUGIA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 0);
		pc.addBorderCols(cdoHeader.getColValue("observacion"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("CIRUJANO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("nombre_medico"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("ASISTENTE:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("asistente"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		if(tipoSolicitud.equals("A")){
		pc.setFont(7, 0);
		pc.addBorderCols("PRE-OPERATORIO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("POST-OPERATORIO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 0);
		pc.addBorderCols("ANESTESIOLOGO:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("anestesiologo"),0,3, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(7, 0);
		pc.addBorderCols("TIPO ANESTESIA:",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		} else if(tipoSolicitud.equals("Q")){
		pc.setFont(7, 0);
		pc.addBorderCols("INTRUMENTISTA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("instrumentista"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(7, 0);
		pc.addBorderCols("CIRCULADOR:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.setFont(8, 1);
		pc.addBorderCols(cdoHeader.getColValue("circulador"),0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		}
		
		//if(tipoSolicitud.equals("a")){
		pc.setFont(7, 0);
		pc.addBorderCols("ANESTESIA:",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,5, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Hora de Entrada (ANEST.):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(" "+cdoHeader.getColValue("horaEntradaAn"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Hora de Salida (ANEST.):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("horaSalidaAn"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		//}

		pc.setFont(7, 0);
		pc.addBorderCols("Hora de Entrada (SALON):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("horaEntradaSa"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("Hora de Salida (SALON):",2,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols(""+cdoHeader.getColValue("horaSalidaSa"),0,1, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addBorderCols("",0,1, 0.0f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.copyTable("Header");
		pc.addCopiedTable("Header");
	
	pc.createTable();
		pc.setFont(8, 1);
		pc.addBorderCols((tipoSolicitud.equals("A")?"ANESTESIA":"QUIRURGICO"),1,6, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
	pc.addTable();
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Cód. Artículo",1);
		pc.addBorderCols("Materiales y Medicamentos",1);
		pc.addBorderCols("Solic.",1);
		pc.addBorderCols("Entr.",1);
		pc.addBorderCols("Adic.",1);
		pc.addBorderCols("Devol.",1);
		pc.addBorderCols("Total",1);
	pc.addTable();
	
	String gTypeIns = "";

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.createTable();
		
		    //if (tipoSolicitud.equals("A")){
			   if (!gTypeIns.equals(cdo.getColValue("tipo"))){
			     pc.setFont(8, 1);
				   pc.addBorderCols(cdo.getColValue("tipo"),0,setDetail.size(), 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			   }
			//}
		
			pc.setFont(8, 0);
			pc.addBorderCols(cdo.getColValue("cod_articulo"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("desc_articulo"),0,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("solicitud"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("entrega"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("adicion"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("devolucion"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addBorderCols(cdo.getColValue("utilizado"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
		pc.addTable();
		lCounter++;
		
		gTypeIns = cdo.getColValue("tipo");

		if(((i+1)==al.size()||al.size()==0) && (tipoSolicitud.equals("Q") || tipoSolicitud.equals("A"))){
			int countLine = lCounter;
			for(int j=countLine; j<maxLines; j++){
				pc.createTable();
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",0,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addTable();
			}
		}
		
		if (lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();

			//pdfHeader(pc, _comp, pCounter, nPages, depto, titulo, userName, fecha);
			pc.setNoColumnFixWidth(setHeader);
			pc.createTable();
				pc.setFont(6, 0);
				pc.addBorderCols("Usuario: "+userName,0,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(fecha,1,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols("Página: "+pCounter+" de "+nPages,2,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addTable();
			pc.setFont(7, 1);
			pc.addCopiedTable("Header");

			pc.createTable();
				pc.setFont(8, 1);
				pc.addBorderCols((tipoSolicitud.equals("A")?"ANESTESIA":"QUIRURGICO"),1,6, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addTable();
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.setFont(7, 1);
				pc.addBorderCols("Cód. Artículo",1);
				pc.addBorderCols("Materiales y Medicamentos",1);
				pc.addBorderCols("Solic.",1);
				pc.addBorderCols("Entr.",1);
				pc.addBorderCols("Adic.",1);
				pc.addBorderCols("Devol.",1);
				pc.addBorderCols("Total",1);
			pc.addTable();

		}
	}//for i
		if(al.size()==0  && (tipoSolicitud.equals("Q"))){
			int countLine = lCounter;
			for(int j=countLine; j<maxLines; j++){
				pc.createTable();
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",0,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addTable();
			}
		}
	if(!tipoSolicitud.equals("")){
		pCounter++;
		pc.addNewPage();
		pc.setNoColumnFixWidth(setHeader);
		pc.createTable();
			pc.setFont(6, 0);
			pc.addBorderCols("Usuario: "+userName,0,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addBorderCols(fecha,1,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
			pc.addBorderCols("Página: "+pCounter+" de "+nPages,2,2, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);
		pc.addTable();
		pc.setFont(7, 1);
		pc.addCopiedTable("Header");

		pc.setNoColumnFixWidth(setDetail);
		pc.createTable();
		pc.setFont(8, 1);
		pc.addBorderCols("USOS",1,7, 0.5f, 0.0f, 0.0f, 0.0f,cHeight);

		pc.setFont(7, 1);
		pc.addBorderCols("Cód. Uso",1);
		pc.addBorderCols("Descripción",1);
		pc.addBorderCols("Solic.",1);
		pc.addBorderCols("Entr.",1);
		pc.addBorderCols("Adic.",1);
		pc.addBorderCols("Devol.",1);
		pc.addBorderCols("Total",1);
		
		String gType = "";
		
		pc.addTable();
		for (int i=0; i<alUsos.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) alUsos.get(i);
			pc.createTable();
				
				if (!gType.equals(cdo.getColValue("tipo"))){
				   pc.setFont(8, 1);
				   pc.addBorderCols(cdo.getColValue("tipo"),0,setDetail.size(), 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				}
				pc.setFont(8, 0);
				pc.addBorderCols(cdo.getColValue("cod_uso"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addBorderCols(cdo.getColValue("descripcion"),0,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addBorderCols(cdo.getColValue("cantidad"),1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			
			pc.addTable();
			gType = cdo.getColValue("tipo");
		}
	}
	if (al.size() == 0)
	{
			int countLine = lCounter;
			for(int j=countLine; j<maxLines; j++){
				pc.createTable();
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",0,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
					pc.addBorderCols(" ",1,1, 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
				pc.addTable();
			}
	}

	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>