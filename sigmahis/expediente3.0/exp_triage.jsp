<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="SPMgr" scope="page" class="issi.expediente.SignoPacienteMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
SPMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
SignoPaciente sp = new SignoPaciente();
ArrayList al, alh = new ArrayList();

boolean viewMode = false;
String sql = "", sqlTitle="";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp= request.getParameter("fp");
String tipoPersona= request.getParameter("tipoPersona");
String subTitulo ="",appendFilter = "";
String desc = request.getParameter("desc");
String fc = request.getParameter("fc");
String from = request.getParameter("from");
String index = request.getParameter("index");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
StringBuffer sbSql = new StringBuffer();

if(fechaNacimiento == null) fechaNacimiento = "";
if(codigoPaciente == null) codigoPaciente = "";
if(desc == null) desc = "";
if(fc == null) fc = "";
if(from == null) from = "";
if(index == null) index = "";

String categoria= request.getParameter("categoria");
String fechaHoraEval = request.getParameter("fecha_hora_eval");

if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (fg == null){ fg = "TSV"; subTitulo ="TRIAGE/SIGNOS VITALES";}
else subTitulo ="SIGNOS VITALES";

if (fp == null) fp = "edit";
if (fechaHoraEval == null) fechaHoraEval = "";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String hora1="";
int size = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

CommonDataObject cdoDolor = new CommonDataObject();
int caDolor = 0, mm5Dolor = 0, anDolor = 0;
boolean showUltSigno = false;

if (request.getMethod().equalsIgnoreCase("GET"))
{
		sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_TRAER_TRIAGE'),'N') as traer_triage");

	sbSql.append(",nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_TRAER_ULT_SIGNO'),'N') as traer_ult_signo ");

		if(from.trim().equalsIgnoreCase("resureccion") || from.trim().equalsIgnoreCase("val_sulfato")){
				sbSql.append(",nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'SAL_REANIMACION_CARDIO_FR'),'-9') as fr");

				sbSql.append(",nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'SAL_REANIMACION_CARDIO_FC'),'-9') as fc");

				sbSql.append(",nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'SAL_REANIMACION_CARDIO_PA_S'),'-9') as pas");

				sbSql.append(",nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'SAL_REANIMACION_CARDIO_PA_D'),'-9') as pad");

				sbSql.append(",nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'SAL_REANIMACION_CARDIO_SPO2'),'-9') as spo2");

				sbSql.append(",nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'SAL_REANIMACION_CARDIO_T'),'-9') as temp");

				sbSql.append(",nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'SAL_REANIMACION_CARDIO_FCF'),'-9') as fcf");
		}

		sbSql.append(" from dual ");
	CommonDataObject cdoParam = (CommonDataObject) SQLMgr.getData(sbSql.toString());

		if (cdoParam == null) cdoParam = new CommonDataObject();

		showUltSigno = cdoParam.getColValue("traer_ult_signo","N").equalsIgnoreCase("Y") || cdoParam.getColValue("traer_ult_signo","N").equalsIgnoreCase("S");

		sbSql = new StringBuffer();
		sbSql.append("select nvl((select total total_mm5 from tbl_sal_escalas where id = (select max(id) from tbl_sal_escalas where pac_id = ");
		sbSql.append(pacId);
		sbSql.append("and admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and tipo ='MM5' ) and pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and tipo ='MM5' ), 0) total_mm5, nvl((select total total_mm5 from tbl_sal_escalas where id = (select max(id) from tbl_sal_escalas where pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and tipo ='AN' ) and pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and tipo ='AN' ),0) total_an, nvl((select total total_mm5 from tbl_sal_escalas where id = (select max(id) from tbl_sal_escalas where pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and tipo ='CA' ) and pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and tipo ='CA' ),0) total_ca from dual ");

		cdoDolor = SQLMgr.getData(sbSql.toString());

		if (cdoDolor == null){
		 cdoDolor = new CommonDataObject();
		 cdoDolor.addColValue("total_an", "0");
		 cdoDolor.addColValue("total_ca", "0");
		 cdoDolor.addColValue("total_mm5", "0");
		}

		caDolor = Integer.parseInt(cdoDolor.getColValue("total_ca"));
		anDolor = Integer.parseInt(cdoDolor.getColValue("total_an"));
		mm5Dolor = Integer.parseInt(cdoDolor.getColValue("total_mm5"));

sql = "SELECT nvl(observacion,' ') AS observacion, nvl(accion,' ') AS accion, nvl(categoria,' ') AS categoria, nvl(evacuacion,'N') as evacuacion, nvl(miccion,'N') as miccion, nvl(vomito,'N') as vomito, nvl(miccion_obs,' ') as miccionObs, nvl(evacuacion_obs,' ') as evacuacionObs, nvl(vomito_obs,' ') as vomitoObs, to_char(fecha,'dd/mm/yyyy') as fecha,to_char(decode(observacion,'CONNEX',fecha,fecha_registro),'dd/mm/yyyy') as fechaRegistro, to_char(decode(observacion,'CONNEX',hora,hora_registro),'dd/mm/yyyy hh12:mi:ss am') as hora,to_char(decode(observacion,'CONNEX',hora,hora_registro),'hh12:mi am') as horaRegistro, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, usuario_creacion as usuarioCreacion,dolor as dolor, escala as escala, nvl(preocupacion,'N') preocupacion, nvl(preocupacion_obs,' ') preocupacionObs, nivel_conciencia nivelConciencia, dificultad_resp dificultadResp, loquios, proteinuria, liq_amnio liqAmnio FROM tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
if (!viewMode) sql += " and status = 'A'";

	if (fp.equalsIgnoreCase("agregar")) sql +=" and to_date(decode(observacion,'CONNEX',fecha,fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";
	else if (!fg.equalsIgnoreCase("SV") && fc != null && !fc.trim().equals("")) {
		sql +=appendFilter+" and decode(observacion,'CONNEX',fecha,fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
	} else {
				if (from.equalsIgnoreCase("val_sulfato")) {
						sql += " and fecha_registro = (select max(fecha_registro)fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
						if (!viewMode) sql += " and status = 'A'";
						sql += " and to_date('"+fechaHoraEval.substring(0,10)+"','dd/mm/yyyy') >= fecha_registro and to_date('"+fechaHoraEval.substring(11)+"','hh12:mi:ss am') >= hora_registro) and hora_registro = (select max(hora_registro)fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
						if (!viewMode) sql += " and status = 'A'";
						sql += " and to_date('"+fechaHoraEval.substring(0,10)+"','dd/mm/yyyy') >= fecha_registro and to_date('"+fechaHoraEval.substring(11)+"','hh12:mi:ss am') >= hora_registro)";
				} else {
						sql +=" and decode(observacion,'CONNEX',fecha,fecha_creacion) = (select max(decode(observacion,'CONNEX',fecha,fecha_creacion))fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
						if (!viewMode) sql += " and status = 'A'";
						sql += ") ";
				}

				if (from.equalsIgnoreCase("val_sulfato")) {
						if (!fechaHoraEval.trim().equals("")) {
								sql += " and to_date('"+fechaHoraEval.substring(0,10)+"','dd/mm/yyyy') >= fecha_registro and to_date('"+fechaHoraEval.substring(11)+"','hh12:mi:ss am') >= hora_registro ";
						}
				}
		}

	System.out.println("UserDet.getRefType() = "+UserDet.getRefType()+" UserDet.getUserTypeCode() = "+UserDet.getUserTypeCode());
	if (fg.equalsIgnoreCase("TSV") && (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().equalsIgnoreCase("AU") || UserDet.getUserTypeCode().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().equalsIgnoreCase("ES"))) tipoPersona = "T";
	else if (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().equalsIgnoreCase("AU")) tipoPersona = "A";
	else if (UserDet.getUserTypeCode().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().equalsIgnoreCase("ES")) tipoPersona = "E";
	else if (UserDet.getRefType().equalsIgnoreCase("M")) tipoPersona = "M";

	if (tipoPersona != null && !tipoPersona.trim().equals("")) 	appendFilter += " and aa.tipo_persona='"+tipoPersona+"'";
System.out.println("....ssss"+sql);
	sp = (SignoPaciente) sbb.getSingleRowBean(ConMgr.getConnection(), sql, SignoPaciente.class);

	String xtraH = "";
	if (tipoPersona != null && !tipoPersona.trim().equals("")) xtraH = " and sp.tipo_persona = '"+tipoPersona+"'";

	if (!fg.trim().equalsIgnoreCase("SV")){
		String sqlH = "select sp.usuario_creacion, to_char(sp.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc , to_char(decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char( decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_registro) ,'dd/mm/yyyy') as fechaRegistro, decode(sp.observacion,'CONNEX','Connex - ',' ')||to_char( decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_registro) ,'dd/mm/yyyy') as fechaRegistroDsp, to_char(decode(sp.observacion,'CONNEX',sp.hora,sp.hora_registro),'hh12:mi am') as horaRegistro, decode(sp.status,'I','INVALIDO','VALIDO') as status FROM tbl_sal_signo_paciente sp WHERE sp.pac_id="+pacId+" AND sp.secuencia="+noAdmision+" order by sp.fecha_creacion desc";

		alh = SQLMgr.getDataList(sqlH);
	}

		System.out.println(".................................. SP = "+sp);

	if(sp==null){
				sp = new SignoPaciente();
				sp.setFecha(cDateTime.substring(0,10));
				sp.setFechaRegistro(cDateTime.substring(0,10));
				sp.setHora(cDateTime);
				sp.setCategoria("3");
				sp.setHoraRegistro(CmnMgr.getCurrentDate("hh12:mi:ss am"));
				sp.setFechaCreacion(cDateTime);
				sp.setFechaModif(cDateTime);
				sp.setUsuarioCreacion((String) session.getAttribute("_userName"));
				sp.setUsuarioModif((String) session.getAttribute("_userName"));
				if (!viewMode) mode = "add";

				sp.setPreocupacion("");
				sp.setPreocupacionObs("");
				sp.setNivelConciencia("");
				sp.setDificultadResp("");
				sp.setLoquios("");
				sp.setProteinuria("");
				sp.setLiqAmnio("");
		sp.setEscala("0");
	}
	else { if(!viewMode){mode = "edit";viewMode =true;} }//if (!viewMode) mode = "view";
	sql = "select a.*, nvl(b.sigla_um,' ') as sigla_um, nvl(c.resultado,' ') as resultado from tbl_sal_signo_vital a, tbl_sal_signo_vital_um b, (select aa.* from tbl_sal_detalle_signo aa, tbl_sal_signo_paciente s where s.pac_id="+pacId+" AND s.secuencia="+noAdmision;
	if (!viewMode) sql += " and s.status = 'A'";
	sql += " and s.pac_id = aa.pac_id and s.secuencia = aa.secuencia and s.fecha = aa.fecha_signo and s.hora = aa.hora and s.tipo_persona = aa.tipo_persona ";

	if(fp.trim().equals("agregar")) sql +=" and to_date(decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";
	else {
	 if(!fg.trim().equalsIgnoreCase("SV") && fc != null && !fc.trim().equals("")){
				sql +=appendFilter+" and decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
	 }else{
				sql +=appendFilter;

				if (!from.equalsIgnoreCase("val_sulfato")) {
						sql += " and decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion) = (select max(decode(observaciones,'CONNEX',fecha_signo,fecha_creacion))fechaMax from  tbl_sal_detalle_signo z WHERE exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and pac_id="+pacId+" AND secuencia="+noAdmision;
						if (!viewMode) sql += " and status = 'A'";
						if (tipoPersona != null && !tipoPersona.trim().equals("")) sql += " and tipo_persona = '"+tipoPersona+"'";
						sql += ")) ";
				}

				if (from.equalsIgnoreCase("val_sulfato")) {
						if (!fechaHoraEval.trim().equals("")) {
								sql += " and s.fecha_registro = (select max(fecha_registro)fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
								if (!viewMode) sql += " and status = 'A'";
								sql += " and to_date('"+fechaHoraEval.substring(0,10)+"','dd/mm/yyyy') >= fecha_registro and to_date('"+fechaHoraEval.substring(11)+"','hh12:mi:ss am') >= hora_registro) and s.hora_registro = (select max(hora_registro)fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
								if (!viewMode) sql += " and status = 'A'";
								sql += " and to_date('"+fechaHoraEval.substring(0,10)+"','dd/mm/yyyy') >= fecha_registro and to_date('"+fechaHoraEval.substring(11)+"','hh12:mi:ss am') >= hora_registro) ";
						}
				}
		}
	}
	sql += ") c where a.codigo=b.cod_signo(+) and b.valor_default(+)='S' and a.codigo=c.signo_vital(+)";

	if (!viewMode || from.equalsIgnoreCase("plan_salida")) sql += " and a.status = 'A' ";

	sql += " order by a.orden";
	System.out.println("-------------->SQL TRIAGE="+sql);

	al = SQLMgr.getDataList(sql);
	if (sp.getHora() != null && !sp.getHora().trim().equals("")) hora1=sp.getHora().substring(11);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<style type="text/css">
.nourgente:hover{background-color: #008000;}
.critico:hover{background-color: #F00;}
.urgente:hover{background-color: #ff0;}
.nourgente:hover,.critico:hover,.urgente:hover{color:#000;}
</style>
<script>
document.title = 'Triage/Signos Vitales - '+document.title;
var newHeight = true;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){setTimeout('checkLoaded()',100);}
function viewList(){abrir_ventana1('../expediente/triage_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&seccion=<%=seccion%>&exp=3');}
function add(opt){window.location = '../expediente3.0/exp_triage.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=agregar&desc=<%=desc%>&seccion=<%=seccion%>&from=<%=from%>&index=<%=index%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&cds=<%=request.getParameter("cds")%>&defaultAction=<%=request.getParameter("defaultAction")%>&docId=<%=request.getParameter("docId")%>&estado=<%=request.getParameter("estado")%>&sexo=<%=request.getParameter("sexo")%>&exp=<%=request.getParameter("exp")%>&_viewMode=<%=request.getParameter("_viewMode")%>'+(opt && opt == 1 ? "&hide_ult_signo=Y" : "");}
function setTriageDetail(){
	var size=parseInt(document.form0.size.value,10);
	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','nvl(a.observacion,\' \') as observacion, nvl(a.accion,\' \') as accion, b.signo_vital, b.resultado','tbl_sal_signo_paciente a, tbl_sal_detalle_signo b','a.pac_id=<%=pacId%> and a.secuencia=<%=noAdmision%> and a.tipo_persona=\'T\' and a.status = \'A\' and a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.tipo_persona=b.tipo_persona and a.fecha_creacion=b.fecha_creacion and a.fecha_creacion = (select max(fecha_creacion) from tbl_sal_signo_paciente where tipo_persona=\'T\' and status = \'A\' and pac_id=<%=pacId%> and secuencia=<%=noAdmision%>)'));
	if(r!=null&&r.length>0){
		for(i=0;i<r.length;i++){
			var c=r[i];
			for(j=0;j<size;j++){
				if(eval('document.form0.codigo'+j).value==c[2].trim()){
					eval('document.form0.valor'+j).value=c[3].trim();break;
				}
			}
		}
	}else alert('No hay datos de Signos Vitales en Triage!');
}
function checkLoaded(){if(parent.window.opener && parent.window.opener.loaded)window.focus();else setTimeout('checkLoaded()',100);}
function checkPersona(){var persona =	document.form0.tipoPersona.value;if(persona !=null && persona !='')return true;	else{ alert('Usted no tiene asignado Tipo de Persona para Registrar en está Secci&oacute;n !!');return false; }}
function setValEscala(val){document.form0.escala.value=val;}
function setEscala(val){if(val!=='X'){document.form0.escala.className = 'FormDataObjectEnabled';	eval('document.form0.escala').disabled = false;
var edad =  parent.document.paciente.edad.value;
var edadMes =  parent.document.paciente.edad_mes.value;
var edadDias =  parent.document.paciente.edad_dias.value;
var url = '';
if(parseInt(edad) ==0 && parseInt(edadMes) ==0 )
{
 url = '../expediente3.0/exp_escala_norton.jsp?fg=SG&fp=SV&desc=<%=desc%>&pacId=<%=pacId%>&seccion=119&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=request.getParameter("cds")%>&defaultAction=<%=request.getParameter("defaultAction")%>&docId=<%=request.getParameter("docId")%>&estado=<%=request.getParameter("estado")%>&sexo=<%=request.getParameter("sexo")%>&exp=<%=request.getParameter("exp")%>&_viewMode=<%=request.getParameter("_viewMode")%>&showIntervention=Y';
}
else if(parseInt(edad) < 5 )
{
url='../expediente3.0/exp_escalas_dolor.jsp?fg=MM5&fp=SV&desc=<%=desc%>&pacId=<%=pacId%>&seccion=119&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=request.getParameter("cds")%>&defaultAction=<%=request.getParameter("defaultAction")%>&docId=<%=request.getParameter("docId")%>&estado=<%=request.getParameter("estado")%>&sexo=<%=request.getParameter("sexo")%>&exp=<%=request.getParameter("exp")%>&_viewMode=<%=request.getParameter("_viewMode")%>&showIntervention=Y';
}
else if(parseInt(edad) >= 5 && parseInt(edad) <= 8 )
{
url='../expediente3.0/exp_escalas_dolor.jsp?fg=WB&fp=SV&desc=<%=desc%>&pacId=<%=pacId%>&seccion=119&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=request.getParameter("cds")%>&defaultAction=<%=request.getParameter("defaultAction")%>&docId=<%=request.getParameter("docId")%>&estado=<%=request.getParameter("estado")%>&sexo=<%=request.getParameter("sexo")%>&exp=<%=request.getParameter("exp")%>&_viewMode=<%=request.getParameter("_viewMode")%>&showIntervention=Y';
}
else if(parseInt(edad) > 8 )
{
url='../expediente3.0/exp_escalas_dolor.jsp?fg=AN&fp=SV&desc=<%=desc%>&pacId=<%=pacId%>&seccion=119&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=request.getParameter("cds")%>&defaultAction=<%=request.getParameter("defaultAction")%>&docId=<%=request.getParameter("docId")%>&estado=<%=request.getParameter("estado")%>&sexo=<%=request.getParameter("sexo")%>&exp=<%=request.getParameter("exp")%>&_viewMode=<%=request.getParameter("_viewMode")%>&showIntervention=Y';
}
showPopWin(url,winWidth*.95,winHeight*.75,null,null,'');
} else {document.form0.escala.value='0';document.form0.escala.className = 'FormDataObjectDisabled';eval('document.form0.escala').disabled = true;}}
function setDefault(){}
function setTriage1(h){var fecha = eval('document.form0.fechaR'+h).value ;var hora = eval('document.form0.horaR'+h).value ;var fc = eval('document.form0.fc'+h).value ;window.location = '../expediente3.0/exp_triage.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc='+fc+'&fg=<%=fg%>&desc=<%=desc%>&from=<%=from%>&index=<%=index%>';}
function printExp(){abrir_ventana("../expediente/print_triage.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc=<%=fc%>&fg=<%=fg%>&desc=<%=desc%>&seccion=<%=seccion%>&tipoPersona=<%=tipoPersona%>");}
function checkDate(){
		var hoy = '<%=cDateTime.substring(0,10)%>';
		var choosenDate = document.getElementById("fechaRegistro").value;
		var choosenHour = document.getElementById("horaRegistro").value;
		var flag = false;
		if (choosenDate != hoy)  return true;

		if ( !compareTime() ){
				parent.CBMSG.error("La hora no debe ser mas grande que la actual!");
				flag = false;
		}else{
				flag = true;
		}
		if ( flag ) return true;
		else return false;
}
function compareTime(){var choosenHour = document.getElementById("horaRegistro").value;var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','dual','to_date(\''+choosenHour+'\',\'hh12:mi:ss am\') > to_date(to_char(sysdate,\'hh12:mi:ss am\'),\'hh12:mi:ss am\')',''));	if ( r > 0 ){ return false;	}else{return true;}}

$(document).ready(function(r){
	var fg = "<%=fg%>";
	$("#save").click(function(c){
	if(fg != "SV" && !$('[name="categoria"]').is(":checked")) {
		parent.CBMSG.error("Por favor seleccione una categoría!");
		return false;
	}
 });

 <%if(request.getParameter("set_sv") != null && request.getParameter("set_sv").equals("1") ){%>
	 <%if(from.trim().equalsIgnoreCase("resureccion")){%>
				$("#fr_<%=index%>", window.opener.document).val($("#fr").val());
				$("#fc_<%=index%>", window.opener.document).val($("#fc").val());
				$("#pa_<%=index%>", window.opener.document).val($("#pa_s").val()+"/"+$("#pa_d").val());
				$("#spo2_<%=index%>", window.opener.document).val($("#spo2").val());
		 <%}%>
	 window.close();
 <%}%>

 <%if (from.trim().equalsIgnoreCase("val_sulfato")){%>
				$("#f_r", window.opener.document).val($("#fr").val());
				$("#f_c", window.opener.document).val($("#fc").val());
				$("#p_a", window.opener.document).val($("#pa_s").val()+"/"+$("#pa_d").val());
				$("#temp", window.opener.document).val($("#temp").val());
				$("#f_c_f", window.opener.document).val($("#fcf").val());
				window.close();
	 <%}%>

	 <%if(!showUltSigno && al.size() > 0 && request.getParameter("hide_ult_signo")==null){%>
			add(1);
	 <%}%>

});

function printRptExp(){
	var fecha = $("#rpt_fecha").val();
	if (fecha){
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=expediente/rpt_signos_vitales.rptdesign&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipoPersona=<%=tipoPersona%>&pCtrlHeader=true&pFecha='+fecha+'&fp=<%=from.equalsIgnoreCase("plan_salida")?"plan_salida":"other"%>');
	}
}

function canSubmit() {
	var proceed = true;
	if (!$('#fechaRegistro').val() || !$("#horaRegistro").val()) {
		proceed = false;
		parent.CBMSG.error('Por favor llenar la fecha y la hora de registro!');
	} 
	else if ($("#dolor").val() == 'X'){
		proceed = false;
		parent.CBMSG.error('Por favor indique si tiene dolor o no');
	}
	else if ($("#dolor").val() == 'S' && !$.trim($("#escala").val())){
		proceed = false;
		parent.CBMSG.error('Por favor indique el dolor entre 0 a 10!');
	}
	return proceed;
}

function showChart() {
		abrir_ventana1('../expediente3.0/chart_signos_vitales.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
}
function showMeasurement(opt) {
	if (opt==0)abrir_ventana1('../expediente/list_measurement_pac.jsp?pacId=<%=pacId%>&admision=<%=noAdmision%>');
	else if (opt==1)abrir_ventana1('../expediente/list_measurement_pac_interval.jsp?pacId=<%=pacId%>&admision=<%=noAdmision%>');
}
</script>
</head>
<body class="<%=!fg.trim().equalsIgnoreCase("SV")?"body-forminside":"body-form"%>" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<div class="headerform2">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%if(from.equals("")){%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%} else {%>
	<%=fb.hidden("dob", fechaNacimiento)%>
	<%=fb.hidden("fecha_nacimiento", fechaNacimiento)%>
	<%=fb.hidden("codPac", codigoPaciente)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
<%}%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("usuario_creac",sp.getUsuarioCreacion())%>
<%=fb.hidden("fecha_creac",sp.getFechaCreacion())%>
<%=fb.hidden("hora1",sp.getHora())%>
<%=fb.hidden("fecha",sp.getFecha())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipoPersona",""+tipoPersona)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("cI","")%>
<%=fb.hidden("from", from)%>
<%=fb.hidden("index", index)%>

<table cellspacing="0" class="table pull-right table-striped table-custom-2">
		<tr>
				<td class="controls form-inline">
						<button type="button" name="addTriage" id="addTriage" class="btn btn-inverse btn-sm" onClick="javascript:add()"<%=mode.trim().equals("view")?" disabled":""%>>
								<i class="fa fa-plus fa-lg"></i> <cellbytelabel id="2">Agregar</cellbytelabel>
						</button>

						<button type="button" name="listTriage" id="listTriage" class="btn btn-inverse btn-sm" onClick="javascript:viewList()">
								<i class="fa fa-eye fa-lg"></i> <cellbytelabel id="2">Ver S.Vitales</cellbytelabel>
						</button>

						<% if (fg.trim().equals("SV")){ %>
								<% if (cdoParam.getColValue("traer_triage","N").trim().equals("S")){ %>
										<button type="button" name="setTriage" id="setTriage" class="btn btn-inverse btn-sm" onClick="javascript:setTriageDetail()">
												<i class="fa fa-download fa-lg"></i> <cellbytelabel id="2">Traer S.Vitales</cellbytelabel>
										</button>
								<%}%>
								<button type="button" name="btnHelp" id="btnHelp" class="btn btn-inverse btn-sm" onClick="parent.showHelp()">
										<i class="fa fa-question fa-lg"></i> <cellbytelabel id="2">Ayuda</cellbytelabel>
								</button>

								<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1"/>
										<jsp:param name="clearOption" value="true"/>
										<jsp:param name="nameOfTBox1" value="rpt_fecha"/>
										<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>"/>
								</jsp:include>

								<%=fb.button("rpt_imprimir","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:printRptExp()\"")%>
								<%=fb.button("mediciones","Resultado Mediciones",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showMeasurement(0)\"")%>
								<%=fb.button("medicionesInt","Mediciones x Intervalo",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:showMeasurement(1)\"")%>



						<%} else { %>
							<%if(!fp.trim().equals("agregar")){%>
								<%=fb.button("imprimir","Imprimir",false,false,null,null,"onClick=\"javascript:printExp()\"")%>
							<%}%>
						<%}%>



						<button type="button" class="btn btn-inverse btn-sm" onClick="showChart()">
										<i class="fa fa-chart fa-lg"></i> <cellbytelabel id="2">Gr&aacute;fica</cellbytelabel>
								</button>

				</td>
		</tr>
</table>

<% if (!fg.trim().equalsIgnoreCase("SV")){ %>
		<table cellspacing="0" class="table pull-right table-striped table-custom-2">
				<tr class="bg-headtabla">
					 <th>Listado de Triage</th>
				</tr>
		</table>

		<div class="table-wrapper">
				<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<thead>
						<tr class="bg-headtabla2">
								<td><cellbytelabel>Fecha</cellbytelabel></td>
								<td><cellbytelabel>Hora</cellbytelabel></td>
								<td><cellbytelabel>Usuario</cellbytelabel></td>
								<td><cellbytelabel>Estado</cellbytelabel></td>
						</tr>
				</thead>
				<tbody>
				<% for (int h = 1; h<=alh.size(); h++){
						CommonDataObject cdoh = (CommonDataObject) alh.get(h-1);%>
						<%=fb.hidden("fechaR"+h,cdoh.getColValue("fechaRegistro"))%>
						<%=fb.hidden("horaR"+h,cdoh.getColValue("horaRegistro"))%>
			<%=fb.hidden("fc"+h, cdoh.getColValue("fecha_creacion"))%>
						<tr class="pointer" onClick="setTriage1('<%=h%>')">
								<td><%=cdoh.getColValue("fechaRegistroDsp")%></td>
								<td><%=cdoh.getColValue("horaRegistro")%></td>
								<td><%=cdoh.getColValue("usuario_creacion")%></td>
								<td><%=cdoh.getColValue("status")%></td>
						</tr>
				<%} //end for historial%>
				</tbody>
				</table>
		</div>
<%}%>
</div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
	<tr>
		<td width="15%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
		<td width="35%" class="controls form-inline">
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="clearOption" value="true"/>
						<jsp:param name="nameOfTBox1" value="fechaRegistro"/>
						<jsp:param name="valueOfTBox1" value="<%=sp.getFechaRegistro()%>"/>
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						<jsp:param name="onChange" value="javascript:checkDate();"/>
						<jsp:param name="jsEvent" value="javascript:checkDate();"/>
						</jsp:include>
				<td width="15%" align="right"><cellbytelabel>Hora</cellbytelabel></td>
				<td width="35%" class="controls form-inline">
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="hh12:mi:ss am"/>
						<jsp:param name="nameOfTBox1" value="horaRegistro"/>
						<jsp:param name="valueOfTBox1" value="<%=sp.getHoraRegistro()%>"/>
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						</jsp:include>
				</td>
	</tr>

		<tr>
				<td colspan="4">
						<table width="100%" class="table table-small-font table-bordered table-striped">
								<tr align="center" class="bg-headtabla">
										<td width="10%"><cellbytelabel>Factores</cellbytelabel></td>
										<td width="35%"><cellbytelabel>Valor</cellbytelabel></td>
										<td width="5%">&nbsp;</td>
										<td width="35%">
												<%if(al.size() > 1){%><cellbytelabel>Factores</cellbytelabel><%}else{%>&nbsp;<%}%>
										</td>
										<td width="10%">
												<%if(al.size() > 1){%><cellbytelabel>Valores</cellbytelabel><%}else{%>&nbsp;<%}%>
										</td>
										<td width="5%">&nbsp;</td>
								</tr>
								<%
								int lc = 0;
								int ic = 0;
								size = al.size();
								for (int i=0; i<al.size(); i++){
										CommonDataObject cdo = (CommonDataObject) al.get(i);
										if (ic == 0){%>
												<tr>
										<%} ic++; %>

										<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
										<td><%=cdo.getColValue("descripcion")%></td>
										<td align="center" class="controls form-inline">
										<%String di = "\""+i+"\"";
											String bgColor = "#fff", title="";
											String resultado = "0.0";
											double res = 0.0;
										%>

										<%if(false && cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals("1")){
											 resultado = (cdo.getColValue("resultado")==null || cdo.getColValue("resultado").trim().equals(""))?"0.0":cdo.getColValue("resultado");
											 try { res = Double.parseDouble(resultado); } catch (Exception e) { res = 0.0; }
										%>
												<span style="width:15px;height:15px; display:<%=res>0.0?"inline-block":"none"%>;">&nbsp;</span>
										<%}%>

										<%if(from.trim().equalsIgnoreCase("resureccion") || from.trim().equalsIgnoreCase("val_sulfato")){%>
											<%if(cdo != null && cdo.getColValue("codigo","-8").equals(cdoParam.getColValue("fr","-9"))){%>
												<%=fb.hidden("fr",cdo.getColValue("resultado"))%>
											<%}%>
											<%if(cdo != null && cdo.getColValue("codigo","-8").equals(cdoParam.getColValue("fc","-9"))){%>
												<%=fb.hidden("fc",cdo.getColValue("resultado"))%>
											<%}%>
											<%if(cdo != null && cdo.getColValue("codigo","-8").equals(cdoParam.getColValue("pas","-9"))){%>
												<%=fb.hidden("pa_s",cdo.getColValue("resultado"))%>
											<%}%>
											<%if(cdo != null && cdo.getColValue("codigo","-8").equals(cdoParam.getColValue("pad","-9"))){%>
												<%=fb.hidden("pa_d",cdo.getColValue("resultado"))%>
											<%}%>
											<%if(cdo != null && cdo.getColValue("codigo","-8").equals(cdoParam.getColValue("spo2","-9"))){%>
												<%=fb.hidden("spo2",cdo.getColValue("resultado"))%>
											<%}%>
											<%if(cdo != null && cdo.getColValue("codigo","-8").equals(cdoParam.getColValue("temp","-9"))){%>
												<%=fb.hidden("temp",cdo.getColValue("resultado"))%>
											<%}%>
											<%if(cdo != null && cdo.getColValue("codigo","-8").equals(cdoParam.getColValue("fcf","-9"))){%>
												<%=fb.hidden("fcf",cdo.getColValue("resultado"))%>
											<%}%>
										<%}%>

										<%=fb.textBox("valor"+i, cdo.getColValue("resultado"), false, false, viewMode, 6,10,"form-control form-inline",null,null,null,false, " data-index="+di)%>
					<%if(false && cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals("1")){
												if ( res < 36.5 ) {bgColor = "#1DCBEA"; title="Hipotermia";}
												else if ( res >= 36.5 && res <= 37.5 ) {bgColor = "#00f"; title="Normal";}
												else if ( res > 37.5 ) {bgColor = "#f00"; title="Hipertermia ";}%>
														<span style="width:15px;height:15px;background:<%=bgColor%>; display:<%=res>0.0?"inline-block":"none"%>; cursor:pointer" class="hint hint--right" data-hint="<%=title%>">&nbsp;</span>
										<%}%>
					</td>
					<td><%=cdo.getColValue("sigla_um")%></td>
										<%if (ic == 2 || (i + 1) == size){
												if (ic != 2 && (i + 1) == size){%>
														<td>&nbsp;</td>
														<td>&nbsp;</td>
														<td>&nbsp;</td>
												<%
												}
												ic = 0;
												lc++;
												%>
										</tr>
<%
	}
}
fb.appendJsValidation("\n\tif (!checkPersona()) error++;\n");
%>
						</table>
					</td>
				</tr>

<%if(!fg.trim().equals("SV")){%>
				<tr id="panel1">
		<%}else{%>
				<%=fb.hidden("categoria",sp.getCategoria())%>
				<tr>
						<td width="15%" align="right"><cellbytelabel>Evacuaci&oacute;n</cellbytelabel>:&nbsp;</td>
						<td width="35%" colspan="4" class="controls form-inline">
								<%=fb.checkbox("evacuacion","S",sp.getEvacuacion().trim().equals("S"),viewMode,"",null,"")%>
								&nbsp;&nbsp;Observaci&oacute;n:&nbsp;<%=fb.textarea("evacuacionObs", sp.getEvacuacionObs(), false, false, viewMode, 0, 1, "form-control input-sm", "width:75%", "")%>
						</td>
				</tr>
				<tr>
			<td width="15%" align="right"><cellbytelabel>Micci&oacute;n</cellbytelabel>:</td>
				<td width="35%" colspan="4" class="controls form-inline">
								<%=fb.checkbox("miccion","S",sp.getMiccion().trim().equals("S"),viewMode,null,null,"")%>
				&nbsp;&nbsp;Observaci&oacute;n:&nbsp;<%=fb.textarea("miccionObs", sp.getMiccionObs(), false, false, viewMode, 0, 1, "form-control input-sm", "width:75%", "")%>
						</td>
		</tr>
				<tr>
						<td width="15%" align="right"><cellbytelabel>V&oacute;mito</cellbytelabel>:</td>
			<td width="35%" colspan="4" class="controls form-inline">
								<%=fb.checkbox("vomito","S",sp.getVomito().trim().equals("S"),viewMode,null,null,"")%>
								&nbsp;&nbsp;Observación:&nbsp;<%=fb.textarea("vomitoObs", sp.getVomitoObs(), false, false, viewMode, 0, 1, "form-control input-sm", "width:75%", "")%>
						</td>
		</tr>
				<tr>
						<td width="15%" align="right"><cellbytelabel>Existe preocupaci&oacute;n (doctor, enfermera, familiares) </cellbytelabel>:</td>
			<td width="35%" colspan="4" class="controls form-inline">
								<%=fb.checkbox("preocupacion","S",(sp.getPreocupacion() != null && sp.getPreocupacion().equalsIgnoreCase("S")),viewMode,null,null,"")%>
								&nbsp;&nbsp;Observación:&nbsp;<%=fb.textarea("preocupacionObs", sp.getPreocupacionObs(), false, false, viewMode, 0, 1, "form-control input-sm", "width:75%", "")%>
						</td>
		</tr>

	<%}%>

		<tr>
				<td width="15%" align="right"><cellbytelabel>Dolor</cellbytelabel>:</td>
		<td width="35%" colspan="3" class="controls form-inline">
						<%
						 boolean forceReadOnly = false;
						 if (anDolor > 0 || caDolor > 0 || mm5Dolor > 2) {
							 //sp.setDolor("S");
							 forceReadOnly = true;
						 } else {
								// sp.setDolor("N");
						 }

						 /*if (anDolor > 0) {sp.setEscala(""+anDolor);forceReadOnly = true;}
						 else if (caDolor > 0) {sp.setEscala(""+caDolor);forceReadOnly = true;}
						 else if (mm5Dolor > 2) {sp.setEscala(""+mm5Dolor);forceReadOnly = true;}*/
						%>
						<%//=fb.select("dolor","N=No,S=Si",sp.getDolor(),false,forceReadOnly||viewMode,0,null,null,"onChange=\"javascript:setEscala(this.value)\"")%>&nbsp;&nbsp;&nbsp;&nbsp;
						<%//=fb.intBox("escala",sp.getEscala(),false,false,forceReadOnly||viewMode,5,2,"form-control input-sm", null, null)%>&nbsp;&nbsp;

						<%=fb.select("dolor","X=Seleccione,N=No,S=Si",sp.getDolor(),false,viewMode,0,null,null,"onChange=\"javascript:setEscala(this.value)\"")%>&nbsp;&nbsp;&nbsp;&nbsp;
						<%=fb.intBox("escala",sp.getEscala(),false,false,true,5,2,"form-control input-sm", null, null)%>&nbsp;&nbsp;
				</td>
		</tr>

		<%if(fg.trim().equalsIgnoreCase("SV")){%>
				<tr>
						<td width="15%" align="right"><cellbytelabel>Nivel de conciencia</cellbytelabel>:</td>
			<td width="35%" colspan="4" class="controls form-inline">
								<label class="pointer"><%=fb.radio("nivel_conciencia","0",(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("0") ),viewMode,false,null,null,"")%>&nbsp;Normal</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("nivel_conciencia","1",(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("1") ),viewMode,false,null,null,"")%>&nbsp;Disminuido</label>
						</td>
		</tr>

				<tr>
						<td width="15%" align="right"><cellbytelabel>Dificultad respiratoria</cellbytelabel>:</td>
			<td width="35%" colspan="4" class="controls form-inline">
								<label class="pointer"><%=fb.radio("dificultad_resp","1",(sp.getDificultadResp() != null && sp.getDificultadResp().equals("1") ),viewMode,false,null,null,"")%>&nbsp;Severa/Moderada</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("dificultad_resp","0",(sp.getDificultadResp() != null && sp.getDificultadResp().equals("0") ),viewMode,false,null,null,"")%>&nbsp;Leve/Ninguna</label>
						</td>
		</tr>

				<tr>
						<td width="15%" align="right"><cellbytelabel>Loquios</cellbytelabel>:</td>
			<td width="35%" colspan="4" class="controls form-inline">
								<label class="pointer"><%=fb.radio("loquios","0",(sp.getLoquios() != null && sp.getLoquios().equals("0") ),viewMode,false,null,null,"")%>&nbsp;Normal</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("loquios","3",(sp.getLoquios() != null && sp.getLoquios().equals("3") ),viewMode,false,null,null,"")%>&nbsp;Aumentado / Falta</label>
						</td>
		</tr>
				<!--
				<tr>
						<td width="15%" align="right"><cellbytelabel>Proteinuria</cellbytelabel>:</td>
			<td width="35%" colspan="4" class="controls form-inline">
								<%//=fb.textBox("proteinuria", sp.getProteinuria(), false, false, viewMode, 4,2,"form-control form-inline input-sm",null,null,null,false, "")%>
						</td>
		</tr>
				-->

				<tr>
						<td width="15%" align="right"><cellbytelabel>L&iacute;quido amni&oacute;tico</cellbytelabel>:</td>
			<td width="35%" colspan="4" class="controls form-inline">
								<label class="pointer"><%=fb.radio("liq_amnio","0",(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("0") ),viewMode,false,null,null,"")%>&nbsp;Claro / Rosa</label>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<label class="pointer"><%=fb.radio("liq_amnio","3",(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("3") ),viewMode,false,null,null,"")%>&nbsp;Verde</label>
						</td>
		</tr>
		<%}%>


<%if(!fg.trim().equals("SV")){%>
<tr>
		<td colspan="5" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer" >
				<table class="table table-small-font table-bordered table-striped">
						<tr class="bg-headtabla">
								<td width="33%" align="left" class="critico">
										<font face="Courier New, Courier, mono">
										<label id="plus1" style="display:none"></label><label id="minus1"></label></font>&nbsp;
										<input type="radio" name="categoria" id="critico"  value="1"<%=sp.getCategoria().equals("1")?" checked":""%> <%=viewMode?"disabled":""%> />
										<label for="critico" style="cursor:pointer"><cellbytelabel>[ I ] CRITICO</cellbytelabel></label>
								</td>

								<td align="left" width="33%"  class="urgente">
										<input type="radio" name="categoria" id="urgente" value="2"<%=sp.getCategoria().equals("2")?" checked":""%> <%=viewMode?"disabled":""%> /> <label for="urgente"  style="cursor:pointer"><cellbytelabel>[ II ] URGENTE</cellbytelabel></label>
								</td>
								<td align="left" width="34%" class="nourgente">
										<input type="radio" name="categoria" id="nourgente" value="3"<%=sp.getCategoria().equals("3")?" checked='checked'":""%> <%=viewMode?"disabled":""%> />
										<label for="nourgente" style="cursor:pointer"><cellbytelabel>[ III ] NO URGENTE</cellbytelabel></label>
								</td>
						</tr>
				</table>
		</td>
</tr>
		<td colspan="4">
			<table class="table table-small-font table-bordered table-striped"style="text-transform:lowercase;">
			<tr id="panel1" align="left" class="TextHeader">
					<td width="33%"><cellbytelabel>CR&Iacute;TICO-RESUCITACI&Oacute;N</cellbytelabel></td><td width="33%"><cellbytelabel>URGENTE</cellbytelabel></td><td width="34%"><cellbytelabel>NO URGENTE</cellbytelabel></td>
			</tr>
			<tr  align="left" class="TextRow02">
					<td >PARO</td><td ><cellbytelabel>TIEMPO DE ATENCION FACULATIVO</td><td >TRAUMATISMO MENOR</cellbytelabel></td>
			</tr>
			<tr  align="left" class="TextRow01">
					<td ><cellbytelabel>TRAUMA MAYOR</cellbytelabel></td><td ><cellbytelabel>TRAUMA CRANEAL</td><td >DOLOR DE GARGANTE,SIN SINTOMAS RESPIRATORIOS</cellbytelabel></td>
			</tr>
			<tr  align="left" class="TextRow02">
					 <td ><cellbytelabelESTADO DE SHOCK</cellbytelabel></td><td ><cellbytelabelTRAUMA SEVERO</cellbytelabel></td><td ><cellbytelabelDIARREA</cellbytelabel></td>
			</tr>
			<tr  align="left" class="TextRow02">
					<td> <cellbytelabel>ASMA EN PREPARO</cellbytelabel></td><td ><cellbytelabelESTADO MENTAL ALTERADO</cellbytelabel></td><td ><cellbytelabel>ALTERACIONES MENSTRUALES</cellbytelabel></td>
			</tr>
			<tr  align="left" class="TextRow01">
				 <td ><cellbytelabel>INSUFICIENCIA RESPIRATORIA GRAVE</cellbytelabel></td><td ><cellbytelabel>REACCION ALERGICA SEVERA</cellbytelabel></td><td ><cellbytelabel>SINTOMAS</cellbytelabel> MENORES</td>
			</tr>
			<tr class="TextRow02">
				 <td><cellbytelabel>TIEMPO DE ATENCION INMEDIATO</cellbytelabel></td><td><cellbytelabel>DOLOR TORAXICO VISCERAL,NO TRAUMATICO</cellbytelabel></td><td>&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				 <td>&nbsp;</td><td><cellbytelabel>SOBREDOSIS</cellbytelabel></td><td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				 <td>&nbsp;</td><td><cellbytelabel>AVC CON DEFICIT MAYOR</cellbytelabel> </td><td>&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				 <td>&nbsp;</td><td><cellbytelabel>TRAUMATISMO CRANEAL,ALERTA VOMITOS</cellbytelabel> </td><td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				 <td>&nbsp;</td><td><cellbytelabel>TRAUMATISMO MODERADO</cellbytelabel> </td><td>&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				 <td>&nbsp;</td><td><cellbytelabel>PROBLEMA DE DIALISIS</cellbytelabel> </td><td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				 <td>&nbsp;</td><td><cellbytelabel>SIGNO DE INFECCION</cellbytelabel></td><td>&nbsp;</td>
			</tr>
			</table>
		</td>
	</tr>

			<%}%>
					 <% if ( fg.equalsIgnoreCase("SV") ){
												fb.appendJsValidation("if(!checkDate()){error++;}");
										}%>
			</table>
<div class="footerform">
										<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
												<tr>
														<td>
														<%=fb.hidden("saveOption","O")%>
														<%if(from.equals("")){%>
																<%=fb.hidden("saveOption","C")%>
														<%}%>
														<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm|fa fa-floppy-o fa-lg",null,"")%>
														<button type="button" class="btn btn-inverse btn-sm" onClick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
												</tr>
										</table>
								</div>
<%=fb.formEnd(true)%>


	</div>
</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	SignoPaciente spa = new SignoPaciente();

	spa.setCodPaciente(request.getParameter("codPac"));
	spa.setSecuencia(request.getParameter("noAdmision"));
	spa.setFecNacimiento(request.getParameter("dob"));
	spa.setPacId(request.getParameter("pacId"));
	spa.setFecha(request.getParameter("fecha"));
	spa.setFechaRegistro(request.getParameter("fechaRegistro"));
	spa.setTipoSigno("PO");
	spa.setPersonal("E");
	spa.setUsuarioCreacion(request.getParameter("usuario_creac"));
	spa.setUsuarioModif((String) session.getAttribute("_userName"));
	spa.setFechaCreacion(request.getParameter("fecha_creac"));
	spa.setFechaModif(cDateTime);
	spa.setCategoria(request.getParameter("categoria"));
	spa.setEvacuacion(request.getParameter("evacuacion"));
	spa.setMiccion(request.getParameter("miccion"));
	spa.setVomito(request.getParameter("vomito"));
	spa.setVomitoObs(request.getParameter("vomitoObs"));
	spa.setMiccionObs(request.getParameter("miccionObs"));
	spa.setEvacuacionObs(request.getParameter("evacuacionObs"));
	spa.setHora(request.getParameter("hora1"));
	spa.setHoraRegistro(request.getParameter("horaRegistro"));

		if(request.getParameter("preocupacion") != null) spa.setPreocupacion(request.getParameter("preocupacion"));
	spa.setPreocupacionObs(request.getParameter("preocupacionObs"));
		if(request.getParameter("nivel_conciencia") != null) spa.setNivelConciencia(request.getParameter("nivel_conciencia"));
		if(request.getParameter("dificultad_resp") != null) spa.setDificultadResp(request.getParameter("dificultad_resp"));
		if(request.getParameter("loquios") != null) spa.setLoquios(request.getParameter("loquios"));
		spa.setProteinuria(request.getParameter("proteinuria"));
		if(request.getParameter("liq_amnio") != null) spa.setLiqAmnio(request.getParameter("liq_amnio"));

	if(request.getParameter("tipoPersona") == null || request.getParameter("tipoPersona").trim().equals("") || request.getParameter("tipoPersona").trim().equals("null")) {
	spa.setTipoPersona("T");
	}
	else
	{
	spa.setTipoPersona(request.getParameter("tipoPersona"));
	}


//	else throw new Exception("Usted no tiene asignado Tipo de Persona para Registrar en está Secci&oacute;n !!");

	//spa.setObservacion(request.getParameter("observacion"));
	spa.setAccion(request.getParameter("accion"));

		if(request.getParameter("dolor").equalsIgnoreCase("X")) spa.setDolor("N");
		else spa.setDolor(request.getParameter("dolor"));
		
		spa.setEscala(request.getParameter("escala"));

	size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		DetalleSignoPaciente spc = new DetalleSignoPaciente();

		spc.setResultado(request.getParameter("valor"+i));
		spc.setCodPaciente(request.getParameter("codPac"));
		spc.setFechaNacimiento(request.getParameter("dob"));
		spc.setSignoVital(request.getParameter("codigo"+i));
		spc.setSecuencia(request.getParameter("noAdmision"));
		spc.setPacId(request.getParameter("pacId"));

		//tipoPersona hace referencia a TBL_SAL_SIGNO_PACIENTE

		//if(!spa.getTipoPersona().trim().equals("null") || !spa.getTipoPersona().trim().equals("")) { // tipoPersona = A, pero con esa condición, se estan
		//pasando T a tbl_sal_detalle_signo T <> A, parent key not found.....

		if(!spa.getTipoPersona().trim().equals("null") || !spa.getTipoPersona().trim().equals("")) {
		spc.setTipoPersona(spa.getTipoPersona());
		 }
		else{
		spc.setTipoPersona("T");
		}

		spc.setHora(request.getParameter("hora1"));
		spc.setFechaSigno(request.getParameter("fecha"));
		spc.setUsuarioCreacion(request.getParameter("usuario_creac"));
		spc.setFechaCreacion(request.getParameter("fecha_creac"));
		spc.setUsuarioModificacion((String) session.getAttribute("_userName"));

		spc.setTipoSigno("PO");
		spc.setCodigo("1");
		if(!spc.getResultado().trim().equals("")){
			spa.addDetalleSignoPaciente(spc);
		}
	}


	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		SPMgr.add(spa);
		//id = TescMgr.getPkColValue("codigo");
	}
	else if (mode.equalsIgnoreCase("edit"))
	{
		SPMgr.update(spa);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>

<script language="javascript">
function closeWindow()
{
<%
if (SPMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SPMgr.getErrMsg()%>');
<%
	if (mode.equalsIgnoreCase("add") && (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU")))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
	<%if(from.equals("")){%>
		parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
		<%}%>
<%
	}
	else
	{
%>
	<%if(from.equals("")){%>
		parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
		 <%}%>
<%
	}
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SPMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&from=<%=from%>&index=<%=index%><%=from.equalsIgnoreCase("resureccion")?"&set_sv=1&codigo_paciente="+fechaNacimiento+"&codigo_paciente="+codigoPaciente:""%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
