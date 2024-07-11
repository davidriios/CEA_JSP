<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ExaMgr" scope="page" class="issi.expediente.ExamenesLabMgr" />
<jsp:useBean id="vCodSol" scope="session" class="java.util.Vector" />

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
ExaMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String area = request.getParameter("area");
String solicitado_por = request.getParameter("solicitado_por");
String incluir_admision = request.getParameter("incluir_admision");
boolean cdsExpanded = (request.getParameter("cdsExpanded") != null && (request.getParameter("cdsExpanded").equalsIgnoreCase("S") || request.getParameter("cdsExpanded").equalsIgnoreCase("Y")));
String cdsReq = request.getParameter("cdsReq");

String estado = request.getParameter("estado");
String cdsCol = "cod_centro_servicio";//solicitado a
if (cdsReq != null && cdsReq.equalsIgnoreCase("X")) cdsCol = "cod_sala";//solicitado por
if(incluir_admision==null) incluir_admision="N";
System.out.println("incluir_admision.............."+incluir_admision);
StringBuffer sbSql = new StringBuffer();
sbSql.append("select (select descripcion from tbl_cds_centro_servicio where codigo = x.");
sbSql.append(cdsCol);
sbSql.append(") as cds_desc, x.* from (");

	sbSql.append("select decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.nombre_paciente, (to_number(to_char(sysdate,'YYYY')) - to_number(to_char(b.f_nac,'YYYY'))) as edad, decode(i.tipo_admision,1,nvl(j.abreviatura,j.descripcion)) as dsp_admitido, a.cod_procedimiento, decode(c.observacion,null,c.descripcion,c.observacion) as nombre_procedimiento, coalesce(getPrecio(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",7,a.cod_procedimiento,nvl((select empresa from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.csxp_admi_secuencia and nvl(estado,'A') = 'A' and prioridad = 1 and rownum = 1),0),e.cod_centro_servicio,i.categoria),c.precio,0) as precio, f.primer_nombre||' '||f.segundo_nombre||' '||f.primer_apellido||' '||f.segundo_apellido as nombre_medico, f.codigo as medico_codigo, nvl(g.cama,' ') as cama, a.estado, nvl(a.comentario,' ') as comentario, nvl(a.observacion, ' ') as observacion, a.prioridad, a.usuario_creac as usuario_creacion, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud, a.codigo, a.csxp_admi_secuencia as admision, a.cod_solicitud, to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, b.codigo as cod_paciente, b.pac_id, e.cod_centro_servicio, a.cod_sala, i.categoria, i.embarazada, get_admCorte(b.pac_id,i.adm_root) as admCorte, i.adm_root as admRoot");

	sbSql.append(" , floor(sysdate - a.fecha_creac)|| 'D '|| MOD(FLOOR ((sysdate - a.fecha_creac) * 24), 24)|| 'H '|| MOD (FLOOR ((sysdate - a.fecha_creac) * 24 * 60), 60)|| 'M' time_diff ");

		sbSql.append(" , case when a.interfaz='BDS' then (  select  decode( om.causa,'Y','  --> TRANSFUNDIR HOY(2-3 HR)','Z','  --> CRUZAR/RESERVAR PRN  ','X',' - TRANSFUNDIR URGENTE(1HR - 1:30MIN)  ','W','  --> PROCEDIMIENTO PROGRAMADO ','R','  --> RESERVAR ') ||' '||decode(unidad_dosis,null,'',' UNIDAD DOSIS:'||nvl(unidad_dosis,cantidad))||decode(motivo,null,'',' Motivo:'||(select descrip_motivo from  tbl_sal_motivo_sol_proc where codigo=motivo))||decode(observacion_enf,NULL,'',' '||observacion_enf)||decode(vol_pediatrico,null,'',' Vol. Pediatrico: '||vol_pediatrico)||decode(frecuencia,null,'',' FREC: '||frecuencia) as observacion     from tbl_sal_detalle_orden_med om where om.pac_id= a.pac_id and om.secuencia=a.csxp_admi_secuencia and om.interfaz='BDS' and om.orden_med = a.orden_med and  om.procedimiento=a.cod_procedimiento and rownum=1  ) else ' ' end as causa ");
	sbSql.append(" from tbl_cds_detalle_solicitud a, vw_adm_paciente b, tbl_cds_procedimiento c, /*tbl_cds_tipo_dieta d, */tbl_cds_solicitud e, tbl_adm_medico f, tbl_adm_atencion_cu g, tbl_adm_admision i, tbl_cds_centro_servicio j/*,tbl_cds_procedimiento_x_cds k*/");
	sbSql.append(" where (a.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz IN ('BDS', 'LIS')))  and a.estudio_dev = 'N' and a.estudio_realizado = 'N'");
	if (estado != null && !estado.trim().equals("")) { sbSql.append(" and a.estado ='"); sbSql.append(estado);sbSql.append("'"); }else sbSql.append(" and a.estado ='S' ");
	if (area != null && !area.trim().equals("")) { sbSql.append(" and a.cod_centro_servicio = "); sbSql.append(area); }
	if (solicitado_por != null && !solicitado_por.trim().equals("")) { sbSql.append(" and a.cod_sala = "); sbSql.append(solicitado_por); }
	if(incluir_admision.equals("Y")) sbSql.append(" and a.expediente = 'N'");
	if (fecha != null && !fecha.trim().equals("")) {
		if(incluir_admision.equals("Y")) sbSql.append(" and trunc(a.fecha_creac) >= to_date('");
		else sbSql.append(" and trunc(a.fecha_solicitud) >= to_date('");
		sbSql.append(fecha);
		sbSql.append("','dd/mm/yyyy')");
	}
	if (fechaHasta != null && !fechaHasta.trim().equals("")) {
		if(incluir_admision.equals("Y")) sbSql.append(" and trunc(a.fecha_creac) <= to_date('");
		else sbSql.append(" and trunc(a.fecha_solicitud) <= to_date('");
		sbSql.append(fechaHasta);
		sbSql.append("','dd/mm/yyyy')");
	}

	sbSql.append(" and a.pac_id = b.pac_id and a.cod_procedimiento = c.codigo(+) and a.cod_solicitud = e.codigo and a.csxp_admi_secuencia = e.admi_secuencia and a.pac_id = e.pac_id and e.med_codigo_resp = f.codigo and e.admi_secuencia = g.secuencia(+) and e.pac_id = g.pac_id(+) and a.csxp_admi_secuencia = i.secuencia and a.pac_id = i.pac_id and i.centro_servicio = j.codigo ");

sbSql.append(") x where exists (select null from tbl_adm_admision where pac_id = x.pac_id and secuencia = admCorte and estado in ('A','E')) order by 1, x.pac_id, x.admision, x.cod_solicitud, x.codigo");
System.out.println("---------> List SQL..."+sbSql.toString());
al = SQLMgr.getDataList(sbSql.toString());
vCodSol.clear();

StringBuffer sbSqlGroup = new StringBuffer();
sbSqlGroup.append("select z.");
sbSqlGroup.append(cdsCol);
sbSqlGroup.append(" as cds, count(*) as n_recs from (");
sbSqlGroup.append(sbSql);
sbSqlGroup.append(") z group by z.");
sbSqlGroup.append(cdsCol);
System.out.println("---------> Group SQL..."+sbSqlGroup.toString());
ArrayList alCds = SQLMgr.getDataList(sbSqlGroup.toString());
Hashtable htCds = new Hashtable();
for (int i = 0; i < alCds.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) alCds.get(i);
	try {
		htCds.put(cdo.getColValue("cds"),cdo.getColValue("n_recs"));
	} catch(Exception ex) {
		System.out.println("Error al registrar conteo de centros!");
	}
}

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	//timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','reloadPage()');
	//timer(60,true,'timerMsgTop','Refrescando en sss seg.','reloadPage()',true,'_timer');
	timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','reloadPage()');
	 //     sec,displayTimer,displayTimerInIds,displayTimerMsg,afterTimeout,displayTimerInTitle,objName
	parent.document.form1.gSol.value=<%=al.size()%>;
	document.form1.regChecked.value="";
	parent.checkPendingOM();
	soundAlert({delay:5000,nPlay:12});//60 / 5 = 12 (plays 12 times with 5 seconds delays between them)
}
function reloadPage()
{
	var fecha = parent.document.form1.fecha.value;
	var fechaHasta = parent.document.form1.fechaHasta.value;
	var area = parent.document.form1.area.value;
	var solicitado_por = parent.document.form1.solicitado_por.value;
	var estado = parent.document.form1.estado.value;
	var incluir_admision = parent.document.form1.incluir_admision.checked?'Y':'N';
	/*var _sysdate = '<%//=CmnMgr.getCurrentDate("dd/mm/yyyy")%>';
	if(_sysdate!=parent.document.form1.fecha.value) parent.window.location= '../expediente/reg_sol_lab.jsp?fecha='+_sysdate+'&area='+area+'&solicitado_por='+solicitado_por+"&cdsExpanded=<%=cdsExpanded?"Y":"N"%>";
	else */window.location= '../expediente/reg_sol_lab_item.jsp?fecha='+fecha+'&fechaHasta='+fechaHasta+'&area='+area+'&estado='+estado+'&solicitado_por='+solicitado_por+"&cdsExpanded=<%=cdsExpanded?"Y":"N"%>&cdsReq=<%=cdsReq%>&incluir_admision="+incluir_admision;
}
function doSubmit(){
	var action = parent.document.form1.baction.value;
	var regChecked = document.form1.regChecked.value;
	var comentario = parent.document.form1.observacion.value;
	var x = 0;
	var comentario_cancela = "";
	var size = <%=al.size()%>;
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.fecha.value = parent.document.form1.fecha.value;
	document.form1.fechaHasta.value = parent.document.form1.fechaHasta.value;
	document.form1.area.value = parent.document.form1.area.value;
	document.form1.estado.value = parent.document.form1.estado.value;
	document.form1.solicitado_por.value = parent.document.form1.solicitado_por.value;
	if(action=='Generar Cargo'){
		if(regChecked==''){
			alert('Seleccione Procedimiento!');
			//form1BlockButtons(false);
			x++;
		} /*else if(comentario==''){
			alert('Agregue Comentario!');
			parent.document.form1.comentario.focus();
			x++;
		}*/
	} else if(action=='Cancelar Estudio'){
		if(regChecked==''){
			alert('Seleccione Procedimiento a Cancelar!');
			x++;
		}	else {
			for(i=0;i<size;i++){
				var pac=eval('document.form1.pac_id'+i).value;
				var req=eval('document.form1.cod_solicitud'+i).value;
				var code=eval('document.form1.codigo'+i).value;
				if(regChecked==eval('document.form1.regCancelado'+i).value&&eval('document.form1.chk'+pac+'_'+req+'_'+code).checked){
				var cpt = eval('document.form1.cod_procedimiento'+i).value;
				comentario_cancela = (prompt("Introduzca Comentario para Cancelar! CPT = "+cpt, "Comentario Cancelar"))
				eval('document.form1.comentario_cancela'+i).value = comentario_cancela;
				if(comentario_cancela =='' || comentario_cancela == null){
					alert('Debe introducir un comentario para poder cancelar! CPT = '+cpt);
					x++;
				}
				}
			}
		}
	} else if(action=='Detalle de Cargos'){
		x++;
		printCargos();
	} else if(action=='Solicitar Estudio'){
		x++;
		abrir_ventana2('../expediente/reg_img_lab.jsp?fp=sol_lab_estudio&fg=sol_lab_estudio');
	}
	if(x==0){
		document.form1.submit();
		return true;
	} else {parent.form1BlockButtons(false);
		return false;
	}
}

function changeProcedimiento(i){
	var cs = parent.document.form1.area.value
	var estado = eval('document.form1.estado'+i).value;
	var comentario_modifica = "";
	if(estado == 'S'){
		comentario_modifica = (prompt("Introduzca Comentario para Modificar!", "Comentario Modifica"))
		eval('document.form1.comentario_modifica'+i).value = comentario_modifica;
		if(comentario_modifica =='' || comentario_modifica == null){
			alert('Debe introducir un comentario para poder modificar!');
		} else abrir_ventana('../common/sel_procedimiento.jsp?fp=imagen&fg=imagen&cs='+cs+'&index='+i);
	}
}

function setValues(i){
	var comentario = eval('document.form1.comentario'+i).value;
	var causa = eval('document.form1.causa'+i).value;
	var regChecked = document.form1.regChecked.value;
	var usuario = eval('document.form1.usuario_creacion'+i).value;
	var fecha = eval('document.form1.fecha_solicitud'+i).value;
	if(eval('document.form1.chkProc'+i).checked==true){
		if(eval('document.form1.chkProc'+regChecked)&&regChecked!=eval('document.form1.regCancelado'+i).value) eval('document.form1.chkProc'+regChecked).checked=false;
		parent.document.form1.comentario.value = comentario+' - - -> '+causa;
		parent.document.form1.usuario_creacion.value = usuario;
		parent.document.form1.fecha_solicitud.value = fecha;
		parent.document.form1.regChecked.value = i;
		parent.document.form1.pacId.value = eval('document.form1.pac_id'+i).value;
		parent.document.form1.admision.value = eval('document.form1.admision'+i).value;
		parent.document.form1.admCorte.value = eval('document.form1.admCorte'+i).value;
		parent.document.form1.codigo.value = eval('document.form1.codigo'+i).value;
		parent.document.form1.cod_solicitud.value = eval('document.form1.cod_solicitud'+i).value;
		document.form1.regChecked.value = i;
	} else {
		parent.document.form1.comentario.value = "";
		document.form1.regChecked.value = '';
		parent.document.form1.regChecked.value = '';
		parent.document.form1.pacId.value = '';
		parent.document.form1.admision.value = '';
		parent.document.form1.codigo.value ='';
		parent.document.form1.cod_solicitud.value ='';

	}
}

function printCargos(){
	var regChecked = document.form1.regChecked.value;
	var pac_id = '', admi_secuencia = '';
	if(regChecked == '') alert('Debe Seleccionar Paciente [Procedimientos]..!');
	else {
		pac_id = eval('document.form1.pac_id'+regChecked).value;
		admi_secuencia = eval('document.form1.admision'+regChecked).value;
		abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+admi_secuencia+'&pacId='+pac_id);
	}
}
function checkReq(obj,idx){
	var pIdx=eval('document.form1.regCancelado'+idx).value;
	var rObj=eval('document.form1.chkProc'+pIdx);
	var pac=eval('document.form1.pac_id'+idx).value;
	var req=eval('document.form1.cod_solicitud'+idx).value;
	if(obj.checked){
		rObj.checked=true;
		setValues(pIdx);
	}else{
		var chk=$("input[name^='chk"+pac/*+'_'+req*/+"_'][type='checkbox']");
		var n=0;
		$.each(chk,function(){if($(this).is(':checked'))n++;});
		if (n==0){rObj.checked=false;
}
	}
}
function checkCds(obj,cds){
	if(obj.checked){
		parent.document.form1.cdsSel.value = cds;
	}
	else parent.document.form1.cdsSel.value = '';
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg","")%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("regChecked","")%>
<%=fb.hidden("solicitado_por","")%>
<%=fb.hidden("cdsExpanded",cdsExpanded?"Y":"N")%>
<%=fb.hidden("area","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("_timer","")%>
<%=fb.hidden("fechaHasta","")%>
<%=fb.hidden("cdsSel","")%>
<table width="100%" align="center">
<!--
<tr class="TextHeader" align="center">
	<td colspan="9" align="right"><%=fb.submit("addSolicitud","Agregar Solicitud",false,false,"", "", "onClick=\"javascript: return(doSubmit());\"")%></td>
</tr>
-->
<tr class="TextHeader" align="center">
	<td colspan="8"><label id="timerMsgTop"></label></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="18%"><cellbytelabel id="1">C&eacute;d./Pasap</cellbytelabel>.</td>
	<td width="27%"><cellbytelabel id="2">Nombre del Paciente</cellbytelabel></td>
	<td width="7%"><cellbytelabel id="2">Admisi&oacute;n</cellbytelabel></td>
	<td width="5%"><cellbytelabel id="3">Edad</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="4">Cama</cellbytelabel></td>
	<td width="20%"><cellbytelabel id="5">Admitido por</cellbytelabel></td>
	<td width="5%"><cellbytelabel id="6">Pend</cellbytelabel>.</td>
	<td width="10%" colspan="2"></td>
</tr>
<%
String paciente = "",regCodigo="";
String cds = "";
boolean oCds = false, oPac = false;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdod = (CommonDataObject) al.get(i);

	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("cod_paciente"+i,cdod.getColValue("cod_paciente"))%>
<%=fb.hidden("fecha_nacimiento"+i,cdod.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("pac_id"+i,cdod.getColValue("pac_id"))%>
<%=fb.hidden("admision"+i,cdod.getColValue("admision"))%>
<%=fb.hidden("admRoot"+i,cdod.getColValue("admRoot"))%>
<%=fb.hidden("codigo"+i,cdod.getColValue("codigo"))%>
<%=fb.hidden("precio"+i,cdod.getColValue("precio"))%>
<%=fb.hidden("cod_centro_servicio"+i,cdod.getColValue("cod_centro_servicio"))%>
<%=fb.hidden("identificacion"+i,cdod.getColValue("identificacion"))%>
<%=fb.hidden("nombre_paciente"+i,cdod.getColValue("nombre_paciente"))%>
<%=fb.hidden("cama"+i,cdod.getColValue("cama"))%>
<%=fb.hidden("nombre_medico"+i,cdod.getColValue("nombre_medico"))%>
<%=fb.hidden("estado"+i,cdod.getColValue("estado"))%>
<%=fb.hidden("comentario"+i,cdod.getColValue("comentario"))%>
<%=fb.hidden("observacion"+i,cdod.getColValue("observacion"))%>
<%=fb.hidden("prioridad"+i,cdod.getColValue("prioridad"))%>
<%=fb.hidden("usuario_creacion"+i,cdod.getColValue("usuario_creacion"))%>
<%=fb.hidden("fecha_solicitud"+i,cdod.getColValue("fecha_solicitud"))%>
<%=fb.hidden("cantidad"+i,cdod.getColValue("cantidad"))%>
<%=fb.hidden("cod_solicitud"+i,cdod.getColValue("cod_solicitud"))%>
<%=fb.hidden("comentario_cancela"+i,cdod.getColValue(""))%>
<%=fb.hidden("comentario_modifica"+i,cdod.getColValue(""))%>
<%=fb.hidden("embarazada"+i,cdod.getColValue("embarazada"))%>
<%=fb.hidden("categoria"+i,cdod.getColValue("categoria"))%>
<%=fb.hidden("medico_codigo"+i,cdod.getColValue("medico_codigo"))%>
<%=fb.hidden("solicitudPac"+i,cdod.getColValue("solicitudPac"))%>
<%=fb.hidden("admCorte"+i,cdod.getColValue("admCorte"))%>
<%=fb.hidden("causa"+i,cdod.getColValue("causa"))%>

<% if (!cds.equals(cdod.getColValue(cdsCol))) { %>
<% if (oCds) { %>
<% if (oPac) { %>
				</table>
			</td>
		</tr>
<% oPac = false; } %>
		</table>
	</td>
</tr>
<% paciente = ""; oCds = false; } %>
<tr>
	<td colspan="8">
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr onClick="javascript:showHide('CDS<%=i%>')" style="text-decoration:none; cursor:pointer">
			<td width="5%" align="center" class="TextPanel02 Text14">[<font face="Courier New, Courier, mono"><label id="plusCDS<%=i%>" style="display:<%=cdsExpanded?"none":""%>">+</label><label id="minusCDS<%=i%>" style="display:<%=cdsExpanded?"":"none"%>">-</label></font>]</td>
			<td class="TextPanel02 Text14"><%=(cdsReq != null && cdsReq.equalsIgnoreCase("X"))?"Solicitado Por: ":"Area: "%><%=cdod.getColValue("cds_desc")%> [ <label><%=htCds.get(cdod.getColValue(cdsCol))%></label> ]</td>
			<td width="5%" align="center" class="TextPanel02 Text14"> <%=fb.checkbox("chk"+cdod.getColValue("cod_sala"),"x",false,false,"","","onClick=\"javascript:checkCds(this,"+cdod.getColValue("cod_sala")+");\"")%></td>
		</tr>
		</table>
	</td>
</tr>
<tr id="panelCDS<%=i%>" style="display:<%=cdsExpanded?"":"none"%>" class="TextPanel01">
	<td colspan="8">
		<table width="100%" cellpadding="1" cellspacing="0">
<% oCds = true; } %>

<% if (!paciente.equals(cdod.getColValue("pac_id")+"-"+cdod.getColValue("admision"))) { %>
<% if (oPac) { %>
				</table>
			</td>
		</tr>
<% oPac = false; } %>
		<tr>
			<td colspan="8">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel02">
					<td width="18%" align="center"><%=cdod.getColValue("identificacion")%></td>
					<td width="27%">&nbsp;<%=cdod.getColValue("nombre_paciente")%></td>
					<td width="7%" align="center"><%=cdod.getColValue("admision")%> &nbsp;[<%=cdod.getColValue("admCorte")%>]</td>
					<td width="5%" align="center"><%=cdod.getColValue("edad")%></td>
					<td width="10%" align="center"><%=cdod.getColValue("cama")%></td>
					<td width="20%">&nbsp;<%=cdod.getColValue("dsp_admitido")%></td>
					<td width="5%" align="center"><img src="<%="../images/"+((cdod.getColValue("prioridad").equals("U")||cdod.getColValue("prioridad").equals("W"))?"lampara_roja.gif":"lampara_blanca.gif")%>"></td>
					<td width="5%" align="right" onClick="javascript:showHide(<%=i%>)" style="text-decoration:none; cursor:pointer">[<font face="Courier New, Courier, mono"><label id="plus<%=i%>" style="display:none">+</label><label id="minus<%=i%>">-</label></font>]&nbsp;</td>
					<td width="5%" align="center"><%=fb.checkbox("chkProc"+i,""+i,false, false, "", "", "onClick=\"javascript:setValues("+i+");jqCheckAll(this.form,'chk"+cdod.getColValue("pac_id")/*+"_"+cdod.getColValue("cod_solicitud")*/+"_',this,false)\"")%></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel<%=i%>">
			<td colspan="8">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextHeader01" align="center">
					<td width="8%"><cellbytelabel id="7">CPT Code </cellbytelabel></td>
					<td width="60%"><cellbytelabel id="8">Descripci&oacute;n del Estudio</cellbytelabel></td>
					<td width="8%"><cellbytelabel id="9">Espera(hh:mm)</cellbytelabel></td>
					<td width="8%"><cellbytelabel id="9">Estado</cellbytelabel></td>
					<td width="8%"><cellbytelabel id="10">Prior</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Cancelar</cellbytelabel></td>
				</tr>
		<% regCodigo = ""+i;
			oPac = true; }
		%>
		<%=fb.hidden("regCancelado"+i,""+regCodigo)%>

				<tr class="<%=color%>" align="center">
					<td><%=fb.textBox("cod_procedimiento"+i,cdod.getColValue("cod_procedimiento"), true, false, true, 10, "", "font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px", "")%></td>
					<td align="left">
						<%=fb.textBox("nombre_procedimiento"+i,cdod.getColValue("nombre_procedimiento"), true, false, true, 70, "", "font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px", "")%>
						<%//=fb.button("procedimientos"+i,"...", false, false, "", "", "onClick=\"javascript:changeProcedimiento("+i+")\"")%>
					</td>
					<td><span style="color:red; font-weigth:bold">(<%=cdod.getColValue("time_diff", " ")%>)</span></td>
					<td><%=fb.select("n_estado"+i,"S=P", "")%></td>
					<td><img src="<%="../images/"+(cdod.getColValue("prioridad").equals("U")?"lampara_roja.gif":"lampara_blanca.gif")%>"></td>
					<td><%=fb.checkbox("chk"+cdod.getColValue("pac_id")+"_"+cdod.getColValue("cod_solicitud")+"_"+cdod.getColValue("codigo"),"x",false,false,"","","onClick=\"javascript:checkReq(this,"+i+");\"")%></td>
				</tr>
<%
	paciente = cdod.getColValue("pac_id")+"-"+cdod.getColValue("admision");
	cds = cdod.getColValue(cdsCol);
}
%>
<% if (al.size() > 0) { %>
				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
<% } %>
<%=fb.hidden("keySize",""+al.size())%>
<tr class="TextRow02">
	<td colspan="8" class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel id="11">Procedimientos Solicitados</cellbytelabel></td>
</tr>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "";
	//Ajuste AjuDet = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	String codSol = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	OrdenMedica om = new OrdenMedica();
	for (int i=0; i<keySize; i++){
		if(request.getParameter("chkProc"+i)!=null){
			om.setCompania((String) session.getAttribute("_companyId"));
			om.setFecNacimiento(request.getParameter("fecha_nacimiento"+i));
			om.setCodPaciente(request.getParameter("cod_paciente"+i));
			om.setNoAdmision(request.getParameter("admision"+i));
			om.setAdmRoot(request.getParameter("admRoot"+i));
			om.setAdmCorte(request.getParameter("admCorte"+i));
			om.setTipoTransaccion("C");
			om.setDescripcion("CARGO POR SOLICITUD DE PROCEDIMIENTO");
			om.setCentroServicio(request.getParameter("cod_centro_servicio"+i));
			om.setUsuarioCreacion((String) session.getAttribute("_userName"));
			om.setPacId(request.getParameter("pac_id"+i));
			om.setEmbarazada(request.getParameter("embarazada"+i));
			om.setCategoria(request.getParameter("categoria"+i));
			om.setMedico(request.getParameter("medico_codigo"+i));
			om.setCodigo(request.getParameter("cod_solicitud"+i));
		}

		if(om.getPacId()!=null && om.getNoAdmision()!=null && om.getPacId().equals(request.getParameter("pac_id"+i)) && om.getNoAdmision().equals(request.getParameter("admision"+i))){
			DetalleOrdenMed dom = new DetalleOrdenMed();
			dom.setCentroServicio(request.getParameter("cod_centro_servicio"+i));
			dom.setProcedimiento(request.getParameter("cod_procedimiento"+i));
			dom.setNombreProcedimiento(request.getParameter("nombre_procedimiento"+i));
			dom.setPrecio(request.getParameter("precio"+i));
			dom.setCodigo(request.getParameter("codigo"+i));
			dom.setCodSolicitud(request.getParameter("cod_solicitud"+i));
			dom.setComentarioCancela(request.getParameter("comentario_cancela"+i));
			if(!vCodSol.contains(request.getParameter("cod_solicitud"+i))){
			if(codSol.trim().equals("")) codSol = codSol+request.getParameter("cod_solicitud"+i);
			else codSol = codSol+","+request.getParameter("cod_solicitud"+i);
			}
			vCodSol.add(request.getParameter("cod_solicitud"+i));


			dom.setEstado("S");
			if ((request.getParameter("baction").equalsIgnoreCase("Generar Cargo") || request.getParameter("baction").equalsIgnoreCase("Cancelar Estudio")) && request.getParameter("chk"+om.getPacId()+"_"+dom.getCodSolicitud()+"_"+dom.getCodigo()) != null) om.getDetalleOrdenMed().add(dom);
		}
	}
	/*
	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../expediente/reg_sol_imag_item.jsp?mode="+mode+ "&change=1&type=2");
		return;
	}
	*/

	om.setCompania((String) session.getAttribute("_companyId"));
	om.setUsuarioCreacion((String) session.getAttribute("_userName"));
	om.setIp(request.getRemoteHost());
	String seqTrx = "";
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (request.getParameter("baction").equalsIgnoreCase("Generar Cargo")){
		ExaMgr.addLabSolicitud(om);
		seqTrx = ExaMgr.getPkColValue("seqTrx");
	} else if (request.getParameter("baction").equalsIgnoreCase("Cancelar Estudio")){
		ExaMgr.cancelLabSolicitud(om);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (ExaMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=ExaMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=ExaMgr.getErrMsg()%>';
	parent.document.form1.cod_solicitud.value = '<%=codSol%>';
	parent.document.form1.seqTrx.value = '<%=(seqTrx==null)?"":seqTrx%>';
	parent.document.form1.submit();
	<%} else throw new Exception(ExaMgr.getErrException());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
