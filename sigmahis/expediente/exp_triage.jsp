<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
String from = request.getParameter("from");
StringBuffer sbSql = new StringBuffer();

if(desc == null) desc = "";
if(fc == null) fc = "";
if(from == null) from = "";

String categoria= request.getParameter("categoria");

if(fechaNacimiento == null) fechaNacimiento = "";
if(codigoPaciente == null) codigoPaciente = "";
if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (fg == null){ fg = "TSV"; subTitulo ="TRIAGE/SIGNOS VITALES";}
else subTitulo ="SIGNOS VITALES";

if (fp == null) fp = "edit";

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String hora1="";
int size = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//System.out.println("mode == "+mode);

boolean onlyOneTriage = false;
int totTriage = 0;
int totSignos = 0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_TRAER_TRIAGE'),'N') as traer_triage, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_TEMP_INDICADOR'),'36.5,37.5') as temps, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_SOLO_UN_TRIAGE'),'-') as solo_un_triage, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_TOMADOR_TRIAGE'),'-') as tomador_triage, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_SV_SO'),'-') as sv_so, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_SV_PULSO'),'-') as sv_pulso, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_SV_FREC_RESP'),'-') as sv_frec_resp, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_SV_TEMP'),'-') as sv_temp, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'SAL_SV_PA'),'-') as sv_pa ");
	sbSql.append(" from dual");
	
	
	
	
	CommonDataObject cdoParam = (CommonDataObject) SQLMgr.getData(sbSql.toString());
	if (cdoParam == null) cdoParam = new CommonDataObject();


sql = "SELECT nvl(observacion,' ') AS observacion, nvl(accion,' ') AS accion, nvl(categoria,' ') AS categoria, nvl(evacuacion,'N') as evacuacion, nvl(miccion,'N') as miccion, nvl(vomito,'N') as vomito, nvl(miccion_obs,' ') as miccionObs, nvl(evacuacion_obs,' ') as evacuacionObs, nvl(vomito_obs,' ') as vomitoObs, to_char(fecha,'dd/mm/yyyy') as fecha,to_char(decode(observacion,'CONNEX',fecha,fecha_registro),'dd/mm/yyyy') as fechaRegistro, to_char(decode(observacion,'CONNEX',hora,hora_registro),'dd/mm/yyyy hh12:mi:ss am') as hora,to_char(decode(observacion,'CONNEX',hora,hora_registro),'hh12:mi am') as horaRegistro, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, usuario_creacion as usuarioCreacion,dolor as dolor, escala as escala, padecimiento_actual padecimientoActual FROM tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
if (!viewMode) sql += " and status = 'A'";

	if (fp.equalsIgnoreCase("agregar")) sql +=" and to_date(decode(observacion,'CONNEX',fecha,fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";
	else if (!fg.equalsIgnoreCase("SV") && fc != null) {
		sql +=appendFilter+" and decode(observacion,'CONNEX',fecha,fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
	} else {
		sql +=" and decode(observacion,'CONNEX',fecha,fecha_creacion) = (select max(decode(observacion,'CONNEX',fecha,fecha_creacion))fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision;
		if (!viewMode) sql += " and status = 'A'";
		sql += ") ";
	}

	if (fg.equalsIgnoreCase("TSV") && (UserDet.getUserProfile().contains("0") || (!cdoParam.getColValue("tomador_triage","-").equals("-") && (cdoParam.getColValue("tomador_triage","-").contains(UserDet.getUserTypeCode()) || cdoParam.getColValue("tomador_triage","-").contains(UserDet.getRefType()))))) tipoPersona = "T";
	else if (UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().equalsIgnoreCase("AU")) tipoPersona = "A";
	else if (UserDet.getUserTypeCode().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().equalsIgnoreCase("ES")) tipoPersona = "E";
	else if (UserDet.getRefType().equalsIgnoreCase("M")) tipoPersona = "M";

	//if (tipoPersona != null && !tipoPersona.trim().equals("")) 	appendFilter += " and tipo_persona='"+tipoPersona+"'";

	sp = (SignoPaciente) sbb.getSingleRowBean(ConMgr.getConnection(), sql, SignoPaciente.class);

	String xtraH = "";
	if (tipoPersona != null && !tipoPersona.trim().equals("")) xtraH = " and sp.tipo_persona = '"+tipoPersona+"'";

	String sqlH = "select decode(tipo_persona, 'T', 'TRIAGE', '') is_triage, sp.usuario_creacion, to_char(sp.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fc , to_char(decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, to_char( decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_registro) ,'dd/mm/yyyy') as fechaRegistro, decode(sp.observacion,'CONNEX','Connex - ',' ')||to_char( decode(sp.observacion,'CONNEX',sp.fecha,sp.fecha_registro) ,'dd/mm/yyyy') as fechaRegistroDsp, to_char(decode(sp.observacion,'CONNEX',sp.hora,sp.hora_registro),'hh12:mi am') as horaRegistro, decode(sp.status,'I','INVALIDO','VALIDO') as status FROM tbl_sal_signo_paciente sp WHERE sp.pac_id="+pacId+" AND sp.secuencia="+noAdmision+" order by sp.fecha_creacion desc";

	alh = SQLMgr.getDataList(sqlH);

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

	}
	else { if(!viewMode){mode = "edit";viewMode =true;} }//if (!viewMode) mode = "view";
	sql = "select a.*, nvl(b.sigla_um,' ') as sigla_um, nvl(c.resultado,' ') as resultado from tbl_sal_signo_vital a, tbl_sal_signo_vital_um b, (select aa.* from tbl_sal_detalle_signo aa, tbl_sal_signo_paciente s where s.pac_id="+pacId+" AND s.secuencia="+noAdmision;
	if (!viewMode) sql += " and s.status = 'A'";
	sql += " and s.pac_id = aa.pac_id and s.secuencia = aa.secuencia and s.fecha = aa.fecha_signo and s.hora = aa.hora and s.tipo_persona = aa.tipo_persona";

	if(fp.trim().equals("agregar")) sql +=" and to_date(decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion),'dd/mm/yyyy hh12:mi:ss am') = to_date('"+cDateTime+"','dd/mm/yyyy hh12:mi:ss am') ";
	else {
		if(!fg.trim().equalsIgnoreCase("SV") && fc != null){
			sql +=appendFilter+" and decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
		} else {
			sql +=appendFilter+" and decode(aa.observaciones,'CONNEX',aa.fecha_signo,aa.fecha_creacion) = (select max(decode(observaciones,'CONNEX',fecha_signo,fecha_creacion))fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+" AND secuencia="+noAdmision+appendFilter+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona";
			if (!viewMode) sql += " and status = 'A'";
			sql += ")) ";
		}
	}
	sql += ") c where a.codigo=b.cod_signo(+) and b.valor_default(+)='S' and a.codigo=c.signo_vital(+) ";

	if(!modeSec.trim().equals("view")) sql += " and a.status = 'A' ";
	sql += " order by a.orden ";

	al = SQLMgr.getDataList(sql);
	hora1=sp.getHora().substring(11);

	if (fg.trim().equalsIgnoreCase("TSV") && (cdoParam.getColValue("solo_un_triage","-").equals("S")||cdoParam.getColValue("solo_un_triage","-").equals("Y"))) {
		totTriage = CmnMgr.getCount("select * from tbl_sal_signo_paciente where tipo_persona = 'T' and status = 'A' and pac_id = "+pacId+" and secuencia = "+noAdmision);
		onlyOneTriage = totTriage > 0;
	}

	totSignos = CmnMgr.getCount("select * from tbl_sal_signo_paciente where tipo_persona != 'T' and pac_id = "+pacId+" and secuencia = "+noAdmision);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<style type="text/css">
<%if(!viewMode){%>
.nourgente:hover{background-color: #008000;}
.critico:hover{background-color: #F00;}
.urgente:hover{background-color: #ff0;}
.nourgente:hover,.critico:hover,.urgente:hover{color:#000;}
<%}%>
</style>
<script language="javascript">
document.title = 'Triage/Signos Vitales - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();setTimeout('checkLoaded()',100);}
function viewList(){abrir_ventana1('../expediente/triage_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&seccion=<%=seccion%>');}
function add(){window.location = '../expediente/exp_triage.jsp?modeSec=add&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=agregar&desc=<%=desc%>&seccion=<%=seccion%>&from=<%=from%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>';}
function setTriageDetail(){
	var size=parseInt(document.form0.size.value,10);
	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','nvl(a.observacion,\' \') as observacion, nvl(a.accion,\' \') as accion, b.signo_vital, b.resultado','tbl_sal_signo_paciente a, tbl_sal_detalle_signo b','a.pac_id=<%=pacId%> and a.secuencia=<%=noAdmision%> and a.tipo_persona=\'T\' and a.status = \'A\' and a.pac_id=b.pac_id and a.secuencia=b.secuencia and a.tipo_persona=b.tipo_persona and a.fecha_creacion=b.fecha_creacion and a.fecha_creacion = (select max(fecha_creacion) from tbl_sal_signo_paciente where tipo_persona=\'T\' and status = \'A\' and pac_id=<%=pacId%> and secuencia=<%=noAdmision%>)'));
	if(r!=null&&r.length>0){
		for(i=0;i<r.length;i++){
			var c=r[i];
			for(j=0;j<size;j++){
				if(eval('document.form0.codigo'+j).value==c[2].trim()){eval('document.form0.valor'+j).value=c[3].trim();break;}
			}
		}
	}else alert('No hay datos de Signos Vitales en Triage!');
}
function checkLoaded(){if(parent.window.opener.loaded)window.focus();else setTimeout('checkLoaded()',100);}
function checkPersona(){var persona =	document.form0.tipoPersona.value;if(persona !=null && persona !='')return true;	else{ alert('Usted no tiene asignado Tipo de Persona para Registrar en está Secci&oacute;n !!');return false; }}
function setEscala(val){if(val=='S'){document.form0.escala.className = 'FormDataObjectEnabled';	eval('document.form0.escala').disabled = false;} else {document.form0.escala.className = 'FormDataObjectDisabled';eval('document.form0.escala').disabled = true;}}
function setDefault(){}
function setTriage1(h){
	var fecha = eval('document.form0.fechaR'+h).value ;var hora = eval('document.form0.horaR'+h).value ;var fc = eval('document.form0.fc'+h).value ;
	var isTriage = document.getElementById("is_triage"+h).value;
	window.location = '../expediente/exp_triage.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc='+fc+'&fg=<%=fg%>&desc=<%=desc%>&from=<%=from%>&is_triage='+isTriage;
}
function printExp(){abrir_ventana("../expediente/print_triage.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fc=<%=fc%>&fg=<%=fg%>&desc=<%=desc%>&seccion=<%=seccion%>&tipoPersona=<%=tipoPersona%>");}
function checkDate(){var hoy = '<%=CmnMgr.getCurrentDate("dd/mm/yyyy")%>';var newHoy =  new Date(hoy.substr(6),parseInt(hoy.substr(3,2),10)-1,hoy.substr(0,2));var choosenDate = document.getElementById("fechaRegistro").value;var choosenHour = document.getElementById("horaRegistro").value;var newchoosenDate  = new Date(choosenDate.substr(6),parseInt(choosenDate.substr(3,2),10)-1,choosenDate.substr(0,2));var flag = false;if (newchoosenDate>newHoy){alert("La fecha no debe ser mas grande que la de hoy!");flag = false;}else{flag = true;}if ( !compareTime() ){alert("La hora no debe ser mas grande que la actual!");flag = false;}else{flag = true;}if ( flag ) return true;else return false;}
function compareTime(){var choosenHour = document.getElementById("horaRegistro").value;var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','count(*)','dual','to_date(\''+choosenHour+'\',\'hh12:mi:ss am\') > to_date(to_char(sysdate,\'hh12:mi:ss am\'),\'hh12:mi:ss am\')',''));	if ( r > 0 ){ return false;	}else{return true;}}

$(document).ready(function(r){
	var fg = "<%=fg%>";
	$("#save").click(function(c){
	if(fg != "SV" && !$('[name="categoria"]').is(":checked")) {
		parent.CBMSG.error("Por favor seleccione una categoría!");
		return false;
	}
 });

 setTriageOnTheFly();
});

function setTriageOnTheFly() {
<%if(!viewMode){%>
	var size = <%=alh.size()%>;
	for (h = 1; h <= size; h++) {
		var isTriage = $("#is_triage"+h).val();

		if (isTriage) {
			setTriage1(h);
			return;
		}
	}
<%}%>
}

function validPA() {
	var pa = $.trim($(".presion_arterial").val())
	if (pa) {
		var parts = pa.split("/");
        if (parts.length != 2) {
			alert("El formato de la presión arterial debe ser: sistólica/diastólica");
			return false;
		}
		
		if (isNaN(parts[0]) || isNaN(parts[1]) ) {
			alert("La presión sistólica y diastólica deben ser numéricas");
			return false;
		}
	}
	
	/*if(/^[0-9\/]*$/.test(pa) == false) {
		alert("El formato de la presión arterial debe ser: sistólica/diastólica");
		return  false;
	}
	if (pa && (pa.length < 6 || pa.indexOf("/") != 3 )) {
		alert("El formato de la presión arterial debe ser: sistólica/diastólica");
		return false;
	}*/
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">


			<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>

<%if(from.equals("")){%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%}else{%>
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

<% if (!fg.trim().equalsIgnoreCase("SV")){ %>

<tr>
				 <td style="text-decoration:none;" colspan="4">
					 <div id="listado" width="100%" class="exp h100">
					 <div id="detListado" class="child">
						<table width="100%" cellpadding="1" cellspacing="0">
					 <tr class="TextRow02">
						<td>&nbsp;<cellbytelabel>Listado de Triage</cellbytelabel></td>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
										 <td align="right">
										 <%if(!fp.trim().equals("agregar")){%><a class="Link00" href="javascript:printExp()">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a><%}%></td>
					 </tr>
					 <tr class="TextHeader" align="center">
						<td><cellbytelabel>Fecha</cellbytelabel></td>
						<td><cellbytelabel>Hora</cellbytelabel></td>
						<td><cellbytelabel>Usuario</cellbytelabel></td>
						<td><cellbytelabel>Estado</cellbytelabel></td>
						<td><cellbytelabel></cellbytelabel></td>
					 </tr>
<%
for (int h = 1; h<=alh.size(); h++){
	CommonDataObject cdoh = (CommonDataObject) alh.get(h-1);
			String color = "TextRow02";
	 if (h % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("fechaR"+h,cdoh.getColValue("fechaRegistro"))%>
		<%=fb.hidden("horaR"+h,cdoh.getColValue("horaRegistro"))%>
				<%=fb.hidden("fc"+h, cdoh.getColValue("fecha_creacion"))%>
				<%=fb.hidden("is_triage"+h, cdoh.getColValue("is_triage"))%>
		 <!--//-->
										<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " align="center" onClick="setTriage1('<%=h%>')">
							 <td><%=cdoh.getColValue("fechaRegistroDsp")%></td>
							 <td><%=cdoh.getColValue("horaRegistro")%></td>
							 <td><%=cdoh.getColValue("usuario_creacion")%></td>
							 <td><%=cdoh.getColValue("status")%></td>
							 <td><%=cdoh.getColValue("is_triage")%></td>
										 </tr>
<%
} //end for historial
%>                  </table>
					</div>
					</div>
				 </td>
			 </tr>
<%}%>

				<tr class="TextRow01">
					<td colspan="4" align="right">
						<%if(fg.equalsIgnoreCase("SV")){%>
							<%=fb.button("addTriage","Agregar",true,(mode.trim().equals("view"))?true:false,null,null,"onClick=\"javascript:add()\"")%>
						<%} else {%>
							<%=fb.button("addTriage","Agregar",true,viewMode ? true: onlyOneTriage,null,null,"onClick=\"javascript:add()\"")%>
						<%}%>

						<%if(fg.equalsIgnoreCase("SV")){%>
						<%=fb.button("listTriage","Ver S.Vitales",true, (totSignos > 0 ? false : true), null,null,"onClick=\"javascript:viewList()\"")%>
						<%} else {%>
								<%=fb.button("listTriage","Ver S.Vitales",true, alh.size() > 0 && totSignos > 0 ? false : true,null,null,"onClick=\"javascript:viewList()\"")%>
						<%}%>

						<% if (fg.trim().equals("SV")){ %>
						<% if (cdoParam.getColValue("traer_triage").trim().equals("S")){ %>
						<%=fb.button("setTriage","Traer Triage",true,(!viewMode ? (totTriage>0?true:false) : viewMode ),null,null,"onClick=\"javascript:setTriageDetail()\"")%>	<%}%>

						<%=fb.button("btnHelp","Ayuda",true,false,null,null,"onClick=parent.showHelp()")%>
						<%}%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="35%">
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="clearOption" value="true"/>
									<jsp:param name="nameOfTBox1" value="fechaRegistro"/>
									<jsp:param name="valueOfTBox1" value="<%=sp.getFechaRegistro()%>"/>
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
																		<jsp:param name="onChange" value="javascript:checkDate();"/>
																		<jsp:param name="jsEvent" value="javascript:checkDate();"/>
									</jsp:include>

					<%//=fb.textBox("fecha",sp.getFecha(),false,false,true,10)%></td>
					<td width="15%" align="right"><cellbytelabel>Hora</cellbytelabel></td>
					<td width="35%">
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="hh12:mi:ss am"/>
									<jsp:param name="nameOfTBox1" value="horaRegistro"/>
									<jsp:param name="valueOfTBox1" value="<%=sp.getHoraRegistro()%>"/>
									<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
									</jsp:include>
				<%//=fb.textBox("hora",hora1,false,false,true,11)%></td>
				</tr>
				<%if(!fg.trim().equals("SV")){%>

<tr id="panel1">

				<%}else{%>
				<%=fb.hidden("categoria",sp.getCategoria())%>

				<tr class="TextRow01">
					 <td width="15%" align="right"><cellbytelabel>Evacuaci&oacute;n</cellbytelabel>:&nbsp;</td>
					 <td width="35%" colspan="4"><%=fb.checkbox("evacuacion","S",sp.getEvacuacion().trim().equals("S"),viewMode,null,null,"")%>
													 &nbsp;&nbsp;Observaci&oacute;n:&nbsp;<%=fb.textarea("evacuacionObs", sp.getEvacuacionObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td>
				</tr>

				<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>Micci&oacute;n</cellbytelabel>:</td>
					 <td width="35%" colspan="4"><%=fb.checkbox("miccion","S",sp.getMiccion().trim().equals("S"),viewMode,null,null,"")%>
													 &nbsp;&nbsp;Observaci&oacute;n:&nbsp;<%=fb.textarea("miccionObs", sp.getMiccionObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td></td>
				 </tr>

				<tr class="TextRow01">
					<td width="15%" align="right"><cellbytelabel>V&oacute;mito</cellbytelabel>:</td>
				 <td width="35%" colspan="4"><%=fb.checkbox("vomito","S",sp.getVomito().trim().equals("S"),viewMode,null,null,"")%>
&nbsp;&nbsp;Observación:&nbsp;<%=fb.textarea("vomitoObs", sp.getVomitoObs(), false, false, viewMode, 0, 1, "", "width:75%", "")%></td></td>
				 </tr>

				<%}%>
					<tr class="TextRow01">
						<td width="15%" align="right"><cellbytelabel>Dolor</cellbytelabel>:</td>
						<td width="35%" colspan="3"><%=fb.select("dolor","S=Si,N=No",sp.getDolor(),false,viewMode,0,null,null,"onChange=\"javascript:setEscala(this.value)\"")%>
						&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.intBox("escala",sp.getEscala(),false,false,viewMode,5,2)%>&nbsp;&nbsp;</td>
				 </tr>

				 <tr class="TextRow01">
						<td width="15%" align="right"><cellbytelabel>Padecimiento Actual</cellbytelabel>:</td>
						<td width="35%" colspan="3">
							<%=fb.textarea("padecimiento_actual",sp.getPadecimientoActual(),false,false,viewMode,0,2,2000,null,"width:80%",null)%>
						</td>
				 </tr>
				 <%--<tr class="TextRow01">
					<td width="15%" align="right">Comida:</td>
					 <td width="35%" colspan="4"><%//=fb.select("comida","D=Desayuno,A=Almuerzo,M=Merienda,C=Cena",sp.getVomito(),false,viewMode,0,null,null,null)%>
&nbsp;&nbsp;Comio&nbsp;<%//=fb.select("comio","S=Si,N=No",sp.getVomito(),false,viewMode,0,null,null,null)%>&nbsp;&nbsp;&nbsp;&nbsp;Cantidad&nbsp;<%//=fb.select("Cantidad","0=Nada,1=1/4,2=1/2,3=1/3,4=Todo",sp.getVomito(),false,viewMode,0,null,null,null)%>&nbsp;&nbsp;</td></td>
				 </tr>
				<tr class="TextRow01">
					<td align="right">Observaci&oacute;n</td>
					<td><%//=fb.textarea("observacion", sp.getObservacion(), false, false, viewMode, 0, 5, "", "width:100%", "")%></td>
					<td align="right">Acci&oacute;n</td>
					<td><%//=fb.textarea("accion", sp.getAccion(), false, false, viewMode, 0, 5, "", "width:100%", "")%></td>
				</tr>--%>
				<tr>
					<td colspan="4">
						<table width="100%" border="0" cellpadding="1" cellspacing="1">
							<tr align="center" class="TextHeader">
								<td width="35%"><cellbytelabel>Factores</cellbytelabel></td>
								<td width="13%"><cellbytelabel>Valor</cellbytelabel></td>
								<td width="2%">&nbsp;</td>
								<td width="35%">
									<%//=(al.size() > 1)?"Factores":"&nbsp;"%>
									<%if(al.size() > 1){%><cellbytelabel>Factores</cellbytelabel><%}else{%>&nbsp;<%}%>
								</td>
								<td width="13%">
									<%//=(al.size() > 1)?"Valor":"&nbsp;"%>
									<%if(al.size() > 1){%><cellbytelabel>Valores</cellbytelabel><%}else{%>&nbsp;<%}%>
								</td>
								<td width="2%">&nbsp;</td>
							</tr>
							
							<%if(mode.equalsIgnoreCase("add")){%>
							<tr>
								<td colspan="6" class="RedText">
									<b>
									Los campos que se grafican deben ser num&eacute;ricos. Es decir sin caracteres especiales como %. Presi&oacute;n arterial s&iacute; permite el slash (/)
									</b>
								</td>
							</tr>
							<%}%>
<%
int lc = 0;
int ic = 0;
size = al.size();
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (lc % 2 == 0) color = "TextRow01";

	if (ic == 0)
	{
%>
							<tr class="<%=color%>">
<%
	}
	ic++;
%>
								<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
								<td><%=cdo.getColValue("descripcion")%></td>
								<td align="center">
								<%	
									String di = "\""+i+"\"";
									String bgColor = "#fff", title="";
									String bgColorSo = "#fff", titleSo="";
									double res = 0.0, min = 0.0, max = 0.0, resSo = 0.0;
									String[] temps = (cdoParam.getColValue("temps"," ").trim()).split(",");
									boolean showIndicator = false;
									boolean showIndicatorSo = false;

									if (temps.length > 0) {
										try {
										min = Double.parseDouble(temps[0].trim());
										max = Double.parseDouble(temps[1].trim());
										} catch(Exception eee) {}
									}

									if (min > 0.0 && max > 0.0) showIndicator = true;

								%>

								<%if(showIndicator && cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_temp"))){
									 try { res = Double.parseDouble(cdo.getColValue("resultado")); } catch(Exception ex) {}
								%>
									<span style="width:15px;height:15px; display:<%=res>0.0?"inline-block":"none"%>;">&nbsp;</span>
								<%}%>
								
								<%if(cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals( cdoParam.getColValue("sv_so") )){
									 try { resSo = Double.parseDouble(cdo.getColValue("resultado")); } catch(Exception ex) {}
									 showIndicatorSo = resSo > 0;
							       if (showIndicatorSo) { 		 
								%>
									<span style="width:15px;height:15px; display:<%=resSo>0.0?"inline-block":"none"%>;">&nbsp;</span>
								<%}}%>
								
								<%if(cdo.getColValue("codigo")!=null && (
								
								cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_temp")) || cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_pulso")) || cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_frec_resp")) || cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_so"))
								
								) ){%>
									<%=fb.decBox("valor"+i, cdo.getColValue("resultado"), false, false, viewMode, 6,4.2,"slider",null,null,null,false, " data-index="+di)%>
								<%} else {%>
									<%=fb.textBox("valor"+i, cdo.getColValue("resultado"), false, false, viewMode, 6,10,"slider"+(cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_pa")) ? " presion_arterial" : ""),null,null,null,false, " data-index="+di)%>
								<%}%>

								
								<%if(cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_temp"))){
								if (showIndicator) {
									if ( res < min ) {bgColor = "#1DCBEA"; title="Hipotermia";}
									else if ( res >= min && res <= max ) {bgColor = "#00f"; title="Normal";}
									else if ( res > max ) {bgColor = "#f00"; title="Hipertermia ";}
								%>
									<span style="width:15px;height:15px;background:<%=bgColor%>; display:<%=res>0.0?"inline-block":"none"%>; cursor:pointer" class="hint hint--right" data-hint="<%=title%>">&nbsp;</span>
								<%}}
								
								if(showIndicatorSo && cdo.getColValue("codigo")!=null && cdo.getColValue("codigo").equals(cdoParam.getColValue("sv_so"))){
									if ( resSo < 86.0 ) {bgColorSo = "#F00"; titleSo="Hipoxia severa";}
									else if ( resSo >= 86.0 && resSo <= 90.0 ) {bgColorSo = "#FA8072"; titleSo="Hipoxia moderada";}
									else if ( resSo >= 91.0 && resSo <= 94.0 ) {bgColorSo = "#ff0"; titleSo="Hipoxia leve ";}
									else if ( resSo >= 95.0 && resSo <= 99.0 ) {bgColorSo = "#008000"; titleSo="Normal ";}
								%>
								<span style="width:15px;height:15px;background:<%=bgColorSo%>; display:<%=resSo>0.0?"inline-block":"none"%>; cursor:pointer" class="hint hint--left" data-hint="<%=titleSo%>">&nbsp;</span>
								<%}%>
								</td>
								<td><%=cdo.getColValue("sigla_um")%></td>
<%
	if (ic == 2 || (i + 1) == size)
	{
		if (ic != 2 && (i + 1) == size)
		{
%>
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


<%if(!fg.trim().equals("SV") && ( modeSec.equalsIgnoreCase("add") || ( request.getParameter("is_triage")!=null && !"".equals(request.getParameter("is_triage")) ) )){%>
<tr>
<td colspan="5" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer" >
<table width="100%" cellpadding="1" cellspacing="0">
<tr class="TextPanel">
<td width="33%" align="left" class="critico"<%=sp.getCategoria().equals("1")?" style='background-color: #f00;'":""%>>
<font face="Courier New, Courier, mono">
<label id="plus1" style="display:none"></label><label id="minus1"></label></font>&nbsp;
<!--<cellbytelabel>[ II ] URGENTE</cellbytelabel>-->

	<input type="radio" name="categoria" id="critico"  value="1"<%=viewMode&&sp.getCategoria().equals("1")?" checked":""%> <%=viewMode?"disabled":""%> />
	<label for="critico" style="cursor:pointer"><cellbytelabel>[ I ] CRITICO</cellbytelabel></label>
</td>

<td align="left" width="33%"  class="urgente"<%=sp.getCategoria().equals("2")?" style='background-color: #ff0;'":""%>>
	<input type="radio" name="categoria" id="urgente" value="2"<%=viewMode&&sp.getCategoria().equals("2")?" checked":""%> <%=viewMode?"disabled":""%> />
	<label for="urgente"  style="cursor:pointer"><cellbytelabel>[ II ] URGENTE</cellbytelabel></label>
</td>

<td align="left" width="34%" class="nourgente"<%=viewMode&&sp.getCategoria().equals("3")?" style='background-color: #008000;'":""%>>
	<input type="radio" name="categoria" id="nourgente" value="3"<%=viewMode&&sp.getCategoria().equals("3")?" checked='checked'":""%> <%=viewMode?"disabled":""%> />
	<label for="nourgente" style="cursor:pointer"><cellbytelabel>[ III ] NO URGENTE</cellbytelabel></label>
</td>

</tr>
</table>
</td>
</tr>

		<td colspan="4">
			<table width="100%" cellpadding="1" cellspacing="1" style="text-transform:lowercase;">


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


				<tr class="TextRow02">
					<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",from.trim().equals(""),viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",!from.trim().equals(""),viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,!viewMode?onlyOneTriage:viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>

					 <% if ( fg.equalsIgnoreCase("SV") ){
					fb.appendJsValidation("if(!checkDate()){error++;}");
					fb.appendJsValidation("if(!validPA()){error++;}");
				 }
			 %>

<%=fb.formEnd(true)%>
			</table>


		</td>
	</tr>
</table>
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
	spa.setPadecimientoActual(request.getParameter("padecimiento_actual"));

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

		spa.setDolor(request.getParameter("dolor"));
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
	<%if(from.equals("")){%>
		parent.doRedirect(0);
		<%}else{%>
		window.close();
		<%}%>
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
