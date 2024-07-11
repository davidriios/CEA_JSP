<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ExaMgr" scope="page" class="issi.expediente.ExamenesLabMgr" />
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
String area = request.getParameter("area");
String solicitado_por = request.getParameter("solicitado_por");
String expediente = request.getParameter("expediente");
String estado = request.getParameter("estado");
boolean cdsExpanded = (request.getParameter("cdsExpanded") != null && (request.getParameter("cdsExpanded").equalsIgnoreCase("S") || request.getParameter("cdsExpanded").equalsIgnoreCase("Y")));
String cdsReq = request.getParameter("cdsReq");
String fechaHasta = request.getParameter("fechaHasta");

if(expediente==null) expediente = "S";

String cdsCol = "cod_centro_servicio";//solicitado a
if (cdsReq != null && cdsReq.equalsIgnoreCase("X")) cdsCol = "cod_sala";//solicitado por

StringBuffer sbSql = new StringBuffer();
sbSql.append("select (select descripcion from tbl_cds_centro_servicio where codigo = x.");
sbSql.append(cdsCol);
sbSql.append(") as cds_desc, x.* from (");

	sbSql.append("select decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.nombre_paciente, a.cod_procedimiento, decode(a.cod_procedimiento,null,decode(a.tipo_tubo,null,decode(a.cod_tipo_dieta,null,' ','DIETA '||d.descripcion),decode(a.cod_tipo_dieta,null,decode(a.tipo_tubo,'G','DIETA POR GOTEO','N','DIETA POR BOLO'),'DIETA '||d.descripcion||' - '||decode(a.tipo_tubo,'G','POR GOTEO','N','POR BOLO'))),decode(c.observacion,null,c.descripcion,c.observacion)) as nombre_procedimiento");
	sbSql.append(", coalesce(getPrecio(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",7,a.cod_procedimiento,(select empresa from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.csxp_admi_secuencia and nvl(estado,'A') = 'A' and prioridad = 1 and rownum = 1),a.cod_centro_servicio,(select categoria from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.csxp_admi_secuencia)),c.precio,0) as precio");
	sbSql.append(", f.primer_nombre||' '||f.segundo_nombre||' '||f.primer_apellido||' '||f.segundo_apellido as nombre_medico, f.codigo as medico_codigo, nvl(g.cama,' ') as cama, a.estado, nvl(a.comentario,' ') as comentario, nvl(a.observacion,' ') as observacion, a.prioridad, a.usuario_creac as usuario_creacion, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud, a.codigo, a.csxp_admi_secuencia as admision, a.cod_solicitud, to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, b.codigo as cod_paciente, b.pac_id, a.cod_centro_servicio, a.cod_sala, get_admCorte(b.pac_id,i.adm_root) as admCorte, i.adm_root as admRoot, a.fecha_creac, a.fecha_prog, a.hora_prog");
	
	sbSql.append(" , floor(sysdate - a.fecha_creac)|| 'D '|| MOD(FLOOR ((sysdate - a.fecha_creac) * 24), 24)|| 'H '|| MOD (FLOOR ((sysdate - a.fecha_creac) * 24 * 60), 60)|| 'M' time_diff ");
	
	sbSql.append(" from tbl_cds_detalle_solicitud a, vw_adm_paciente b, tbl_cds_procedimiento c, tbl_cds_tipo_dieta d, tbl_cds_solicitud e, tbl_adm_medico f, tbl_adm_atencion_cu g,tbl_adm_admision i");
	sbSql.append(" where (a.cod_centro_servicio in (select codigo from tbl_cds_centro_servicio where interfaz = 'RIS')) and a.estudio_dev = 'N' and a.estudio_realizado = 'N' ");
	if (estado != null && !estado.trim().equals("")) { sbSql.append(" and a.estado ='"); sbSql.append(estado);sbSql.append("'"); }else sbSql.append(" and a.estado ='S' ");
	if (area != null && !area.trim().equals("")) { sbSql.append(" and a.cod_centro_servicio = "); sbSql.append(area); }
	if (solicitado_por != null && !solicitado_por.trim().equals("")) { sbSql.append(" and a.cod_sala = "); sbSql.append(solicitado_por); }
	if (fecha != null && !fecha.trim().equals("")) {sbSql.append(" and trunc(a.fecha_solicitud) >= to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy')");}
	if (fechaHasta != null && !fechaHasta.trim().equals("")) {sbSql.append(" and trunc(a.fecha_solicitud) <= to_date('");
	sbSql.append(fechaHasta);
	sbSql.append("','dd/mm/yyyy')");}
	
	
	sbSql.append("  and a.expediente = '");
	sbSql.append(expediente);
	sbSql.append("' and a.pac_id = b.pac_id and a.cod_procedimiento = c.codigo(+) and a.cod_tipo_dieta = d.codigo(+) and a.cod_solicitud = e.codigo and a.csxp_admi_secuencia = e.admi_secuencia and a.pac_id = e.pac_id and i.secuencia = e.admi_secuencia and i.pac_id = e.pac_id and e.med_codigo_resp = f.codigo(+) and e.admi_secuencia = g.secuencia(+) and e.pac_id = g.pac_id(+)");

sbSql.append(") x where exists (select null from tbl_adm_admision where pac_id = x.pac_id and secuencia = admCorte and estado in ('A','E')) order by 1, x.fecha_creac desc, x.fecha_prog, x.hora_prog");
System.out.println("---------> List SQL...");
al = SQLMgr.getDataList(sbSql.toString());

StringBuffer sbSqlGroup = new StringBuffer();
sbSqlGroup.append("select z.");
sbSqlGroup.append(cdsCol);
sbSqlGroup.append(" as cds, count(*) as n_recs from (");
sbSqlGroup.append(sbSql);
sbSqlGroup.append(") z group by z.");
sbSqlGroup.append(cdsCol);
System.out.println("---------> Group SQL...");
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
	//if (mode.equalsIgnoreCase("add") && change == null) ajuArt.clear();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
console.log("<%=sbSql.toString()%>");
function doAction()
{
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','reloadPage()');
	
	parent.document.form1.gSol.value=<%=al.size()%>;
	//document.form1.regChecked.value="";
	parent.checkPendingOM();
	
}
function reloadPage()
{
	var fecha = parent.document.form1.fecha.value;
	var area = parent.document.form1.area.value;
	var solicitado_por = parent.document.form1.solicitado_por.value;
	var expediente = parent.document.form1.expediente.value;
	var estado = parent.document.form1.estado.value;
	var fechaHasta = parent.document.form1.fechaHasta.value;
	if(parent.document.incluir_admision && parent.document.incluir_admision.checked) expediente='N';
	

	window.location= '../expediente/reg_sol_imag_item.jsp?fecha='+fecha+'&fechaHasta='+fechaHasta+'&area='+area+'&solicitado_por='+solicitado_por+"&expediente="+expediente+"&estado="+estado+"&cdsExpanded=<%=cdsExpanded?"Y":"N"%>&cdsReq=<%=cdsReq%>";
}

function calc()
{
	var iCounter = 0;
	var action = document.form1.baction.value;
	var regChecked = document.form1.regChecked.value;

	/*if(eval('document.form1.chkProc'+regChecked).checked==true){
		if(eval('document.form1.estado'+regChecked).)
	}
	*/
	if(action=="Guardar"){
		if (iCounter > 0) return true;
		else return false;
	} else return true;
}

function doSubmit(){
	var action = parent.document.form1.baction.value;
	var regChecked = document.form1.regChecked.value
	var comentario = parent.document.form1.observacion.value;
	var x = 0;
	var comentario_cancela = "";
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.fecha.value = parent.document.form1.fecha.value;
	document.form1.fechaHasta.value = parent.document.form1.fechaHasta.value;
	document.form1.area.value = parent.document.form1.area.value;
	document.form1.solicitado_por.value = parent.document.form1.solicitado_por.value;
	document.form1.estado.value = parent.document.form1.estado.value;
	if(action=='Generar Cargo'){
		if(regChecked==''){
			alert('Seleccione Procedimiento!');
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
			comentario_cancela = (prompt("Introduzca Comentario para Cancelar!", "Comentario Cancelar"))
			eval('document.form1.comentario_cancela'+regChecked).value = comentario_cancela;
			if(comentario_cancela =='' || comentario_cancela == null){
				alert('Debe introducir un comentario para poder cancelar!');
				x++;
			}
		}
	} else if(action=='Detalle de Cargos'){
		x++;
		printCargos();
	} else if(action=='Solicitar Estudio'){
		x++;
		abrir_ventana2('../expediente/reg_img_lab.jsp');
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
	var regChecked = document.form1.regChecked.value;
	var usuario = eval('document.form1.usuario_creacion'+i).value;
	var fecha = eval('document.form1.fecha_solicitud'+i).value;
	if(eval('document.form1.chkProc'+i).checked==true){
		if(regChecked!="") eval('document.form1.chkProc'+regChecked).checked=false;
		parent.document.form1.comentario.value = comentario;
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
	if(regChecked == '') alert('Seleccione Procedimiento!');
	else {
		pac_id = eval('document.form1.pac_id'+regChecked).value;
		admi_secuencia = eval('document.form1.admision'+regChecked).value;
		abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+admi_secuencia+'&pacId='+pac_id);
	}
}

var sent=false;
function sendHL7(codigo,cod_solicitud,pac_id,admision)
{
	alert(codigo+'/'+cod_solicitud+'/'+pac_id+'/'+admision+' enviado a Interfase HL7!');
	sent = true;
}

function viewHL7Result(codigo,cod_solicitud,pac_id,admision)
{
	if(sent)alert('La Interface HL7 aun no ha procesado la solicitud '+codigo+'/'+cod_solicitud+'/'+pac_id+'/'+admision);
	else alert('No se ha enviado la solicitud '+codigo+'/'+cod_solicitud+'/'+pac_id+'/'+admision+' todavia!');
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
<%=fb.hidden("fechaHasta","")%>
<%=fb.hidden("cdsSel","")%>
<%
String imagesPath = java.util.ResourceBundle.getBundle("path").getString("images");
%>
<table width="100%" align="center">
<!--
<tr class="TextHeader" align="center">
	<td colspan="9" align="right"><%=fb.submit("addSolicitud","Agregar Solicitud",false,false,"", "", "onClick=\"javascript: return(doSubmit());\"")%></td>
</tr>
-->
<tr class="TextHeader" align="center">
	<td colspan="11"><label id="timerMsgTop"></label></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="%"><cellbytelabel id="1">C&eacute;d./Pasap</cellbytelabel>.</td>
	<td width="%"><cellbytelabel id="2">Nombre del Paciente</cellbytelabel></td>
	<td width="%">Adm.</td>
	<td width="%">Espera(hh:mm)</td>
	<td width="%"><cellbytelabel id="3">CPT Code</cellbytelabel></td>
	<td width="%"><cellbytelabel id="4">Descripci&oacute;n del Estudio</cellbytelabel></td>
	<td width="%"><cellbytelabel id="5">Estado</cellbytelabel></td>
	<td width="%"><cellbytelabel id="6">Prior</cellbytelabel></td>
	<td width="%"><cellbytelabel id="7">Cama</cellbytelabel></td>
	<td width="%"><cellbytelabel id="8">M&eacute;dico Solicitante</cellbytelabel></td>
	<td width="%">&nbsp;</td>
</tr>
<%
String cds = "";
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
<%=fb.hidden("admCorte"+i,cdod.getColValue("admCorte"))%>

<% if (!cds.equals(cdod.getColValue(cdsCol))) { %>
<% if (i > 0) { %>
		</table>
	</td>
</tr>
<% } %>
<tr>
	<td colspan="11">
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
	<td colspan="11">
		<table width="100%" cellpadding="1" cellspacing="0">
<% } %>

		<tr class="<%=color%>" align="center">
			<td class="Text10"><%=cdod.getColValue("identificacion")%></td>
			<td class="Text10" align="left"><%=cdod.getColValue("nombre_paciente")%></td>
			<td>&nbsp;<%=cdod.getColValue("admision")%>&nbsp;[<%=cdod.getColValue("admCorte")%>]<!--<a href="javascript:sendHL7(<%=cdod.getColValue("codigo")%>,<%=cdod.getColValue("cod_solicitud")%>,<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("admision")%>);">send</a>--></td>
			<td>&nbsp;<!--<a href="javascript:viewHL7Result(<%=cdod.getColValue("codigo")%>,<%=cdod.getColValue("cod_solicitud")%>,<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("admision")%>);">view</a>--></td>
			<td>
				<span style="color:red; font-weigth:bold">(<%=cdod.getColValue("time_diff")%>)</span>
				<%=fb.textBox("cod_procedimiento"+i,cdod.getColValue("cod_procedimiento"), true, false, true, 8, "", "font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px", "")%>
			</td>
			<td>
			<%=fb.textBox("nombre_procedimiento"+i,cdod.getColValue("nombre_procedimiento"), true, false, true, 35, "", "font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px", "")%>
			<%=fb.button("procedimientos"+i,"...", false, false, "", "font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px", "onClick=\"javascript:changeProcedimiento("+i+")\"")%>
			</td>
			<td><%=fb.select("n_estado"+i,"S=P","",false,false,0,"","font-weigth:normal; font-family: Verdana, Arial, Helvetica, sans-serif; font-size:9px",null)%></td>
			<td><img src="<%="../images/"+(cdod.getColValue("prioridad").equals("U")?"lampara_roja.gif":"lampara_blanca.gif")%>"></td>
			<td class="Text10"><%=cdod.getColValue("cama")%></td>
			<td class="Text10" align="left"><%=cdod.getColValue("nombre_medico")%></td>
			<td>
			<%=fb.checkbox("chkProc"+i,""+i,false, false, "", "", "onClick=\"javascript:setValues("+i+");\"")%>
			</td>
		</tr>
<%
	cds = cdod.getColValue(cdsCol);
}
%>
<% if (al.size() > 0) { %>
		</table>
	</td>
</tr>
<% } %>
<%=fb.hidden("keySize",""+al.size())%>
<tr class="TextRow02"><td colspan="11" class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel id="9">Procedimientos Solicitados</cellbytelabel></td></tr>
</table>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
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
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	DetalleOrdenMed dom = new DetalleOrdenMed();
	for (int i=0; i<keySize; i++){
		if(request.getParameter("chkProc"+i)!=null){
			dom.setCentroServicio(request.getParameter("cod_centro_servicio"+i));
			dom.setCodPaciente(request.getParameter("cod_paciente"+i));
			dom.setFecNacimiento(request.getParameter("fecha_nacimiento"+i));
			dom.setPacId(request.getParameter("pac_id"+i));
			dom.setNoAdmision(request.getParameter("admision"+i));
			dom.setCodigo(request.getParameter("codigo"+i));
			dom.setCodSolicitud(request.getParameter("cod_solicitud"+i));
			dom.setProcedimiento(request.getParameter("cod_procedimiento"+i));
			dom.setNombreProcedimiento(request.getParameter("nombre_procedimiento"+i));
			dom.setEstado(request.getParameter("n_estado"+i));
			dom.setPrecio(request.getParameter("precio"+i));
			dom.setComentarioCancela(request.getParameter("comentario_cancela"+i));
			dom.setComentarioModifica(request.getParameter("comentario_modifica"+i));
			dom.setCompania((String) session.getAttribute("_companyId"));
		}
	}

	/*
	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../expediente/reg_sol_imag_item.jsp?mode="+mode+ "&change=1&type=2");
		return;
	}
	*/

	dom.setCompania((String) session.getAttribute("_companyId"));
	dom.setUsuarioCreacion((String) session.getAttribute("_userName"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (request.getParameter("baction").equalsIgnoreCase("Generar Cargo")){
		ExaMgr.addImgSolicitud(dom);
	} else if (request.getParameter("baction").equalsIgnoreCase("Cancelar Estudio")){
		ExaMgr.cancelImgSolicitud(dom);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{	 <%if (ExaMgr.getErrCode().equals("1")){%>  
	parent.document.form1.errCode.value = '<%=ExaMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=ExaMgr.getErrMsg()%>';
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