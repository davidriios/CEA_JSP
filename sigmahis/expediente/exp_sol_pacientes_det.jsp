<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="OMMgr" scope="page" class="issi.expediente.OrdenMedicaMgr"/>
<jsp:useBean id="alOM" scope="session" class="java.util.ArrayList"/>
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

OMMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbCol = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String area = request.getParameter("area");
String cds = request.getParameter("cds");
String fieldsWhere = "";
String solicitado_por = request.getParameter("solicitado_por");
String status = "";
String estado = request.getParameter("estado");	// P=pendiente, C=confirmado, A=ambos

if (mode == null) mode = "add";
if (fp == null) fp = "";
if (estado == null||estado.trim().equals("null")) {
	estado = "P";
	status = "'N'";
} else {
	if (estado.equals("P")) status = "'N'";
	else if (estado.equals("C")) status = "'S'";
	else if (estado.equals("A")) status = "'N','S'";
}

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (fg.trim().equals("NU")) {//SOLICITUDES DE NUTRICION

		sbCol.append(", nvl((select (select sh.unidad_admin||' - '||(select descripcion from tbl_cds_centro_servicio where codigo = sh.unidad_admin) from tbl_sal_habitacion sh where sh.codigo = aca.habitacion and sh.unidad_admin in (");
		sbCol.append(cds);
		sbCol.append(")) from tbl_adm_cama_admision aca where aca.pac_id = z.pac_id and aca.admision = z.secuencia and aca.fecha_final is null and aca.hora_final is null),' ') as cds");
		sbCol.append(", replace(a.observacion,',','<br>') as observacion, nvl(a.nombre, replace(a.observacion,',','<br>')) as observacion_dietas ");
		sbCol.append(", nvl((select count(*) from tbl_sal_detalle_orden_med where pac_id = a.pac_id and secuencia = a.secuencia and cds_recibido = 'N' and estado_orden = 'A' and omitir_orden = 'N' and tipo_orden = 3),0) as pendiente");

		sbFilter.append(" and z.estado in ('A') and a.omitir_orden = 'N' and a.tipo_orden = 3 and a.estado_orden = 'A' /*and z.pac_id||'-'||z.secuencia = h.pac_adm*/");

	} else if (fg.trim().equals("IN")) {//SOLICITUDES DE INASA

		sbCol.append(", a.observacion");
		sbCol.append(", nvl((select count(*) from tbl_sal_detalle_orden_med where pac_id = a.pac_id and secuencia = a.secuencia and cds_recibido = 'N' and estado_orden = 'A' and omitir_orden = 'N' and tipo_orden = 4 and cod_tratamiento = 1),0) as pendiente");

		sbFilter.append(" and z.estado in ('A','E') and exists (select null from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and cds in (");
		sbFilter.append(cds);
		sbFilter.append(")) and ( ( trunc(a.fecha_inicio) = to_date('");
		sbFilter.append(fecha);
		sbFilter.append("','dd/mm/yyyy') and a.omitir_orden = 'N' and a.cds_recibido in (");
		sbFilter.append(status);
		sbFilter.append(") and a.tipo_orden = 4 and a.cod_tratamiento = 1 ) or ( trunc(nvl(a.fecha_suspencion,a.fecha_fin)) = to_date('");
		sbFilter.append(fecha);
		sbFilter.append("','dd/mm/yyyy') and a.omitir_orden = 'N' and a.estado_orden in ('S','F') and a.tipo_orden = 4 and a.cod_tratamiento = 1 and a.cds_omit_recibido in (");
		sbFilter.append(status);
		sbFilter.append(") ) )");

	} else {

		sbCol.append(", a.observacion");
		sbCol.append(", nvl((select count(*) from tbl_sal_detalle_orden_med where pac_id = a.pac_id and secuencia = a.secuencia),0) as pendiente");

	}

	sbSql.append("select a.cds_omit_recibido, a.frecuencia, a.dosis, decode(a.tipo_tubo,'G','GOTEO','N','BOLO') as tipo_tubo, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss AM') as fecha_inicio, /* decode(a.estado_orden,'F',decode(a.fecha_suspencion,null,to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss AM'),to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi:ss AM')))*/ decode(estado_orden,'S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi:ss AM'),'F',to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss AM')) as fecha_omitida, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.primer_nombre||' '||b.segundo_nombre||' '||decode(b.apellido_de_casada,null,b.primer_apellido||' '||b.segundo_apellido,b.apellido_de_casada) as nombre_paciente, b.edad, to_char(a.fec_nacimiento,'dd/mm/yyyy')||'/'||a.cod_paciente||'/'||a.secuencia dsp_admision,(select nombre_corto from tbl_sal_desc_estado_ord where estado=a.estado_orden) as dsp_estado, to_char(a.fecha_creacion,'hh12:mi:ss AM') as hora_solicitud, nvl(cds_recibido,'N') as cds_recibido ,a.secuencia as secuenciaCorte, a.tipo_orden, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, decode(a.tipo_orden,3,x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre),7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, a.cod_tratamiento, a.codigo, a.orden_med noOrden, a.pac_id, a.estado_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida, to_char(z.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso");
	sbSql.append(", nvl((select descripcion from tbl_sal_via_admin where codigo = a.via),' ') as descVia");
	sbSql.append(", nvl((select '['||codigo||'] '||decode(sexo,'F','DRA. ','M','DR. ')||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo = om.medico),' ') as nombre_medico");
	sbSql.append(", nvl((select nombre from tbl_adm_empresa where codigo = z.aseguradora),' ') as nombre_empresa");
	sbSql.append(", nvl((select cama from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia),' ') as cama");
	sbSql.append(sbCol);
	
	sbSql.append(", (select descripcion from tbl_cds_tipo_dieta where codigo = a.tipo_dieta and rownum = 1) dietas_desc, (select join( cursor( select descripcion from tbl_cds_subtipo_dieta where cod_tipo_dieta = a.tipo_dieta and descripcion in (select column_value from table( select split(a.observacion,',') from dual ))), '**' ) sub_dietas from dual ) sub_dietas_desc ");
	
	sbSql.append(" from vw_adm_paciente b, tbl_sal_detalle_orden_med a");
	sbSql.append(", (select b.codigo||'-'||nvl(c.codigo, b.codigo) as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo = c.cod_tipo_dieta(+)) x");
	sbSql.append(", tbl_sal_orden_salida d, tbl_adm_admision z, tbl_sal_orden_medica om");
	sbSql.append(" where z.pac_id = a.pac_id and z.secuencia = a.secuencia and a.tipo_dieta||'-'||nvl(a.cod_tipo_dieta,a.tipo_dieta) = x.codigo(+) and a.cod_salida = d.codigo(+) and a.pac_id = b.pac_id");
	sbSql.append(sbFilter);
	sbSql.append(" and a.orden_med = om.codigo and a.secuencia = om.secuencia and a.pac_id = om.pac_id");
	sbSql.append(" order by a.fecha_creacion desc");
	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','reloadPage()');
	parent.document.form1.gSol.value=<%=al.size()%>;
	<%if(!fp.equals("cons")){%>
	parent.checkPendingOM();
	<%}%>
	<%if(request.getParameter("type")!=null && request.getParameter("type").equals("1")){%>
	document.form1.baction.value = '';
	abrir_ventana('../expediente/print_label_dieta.jsp?tipoComida='+parent.document.form1.tipoComida.value);
	<%}%>

	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','a.pac_id, count(*)','tbl_sec_alert a','a.status = \'A\' and a.alert_type = 7',' group by a.pac_id'));

	if(r!=null){
		for(i=0;i<r.length;i++)
		{
			var obj=document.getElementById('label'+r[i][0]);
			if ( obj != null ){
			if(parseInt(r[i][0],10)>0){//blinkId('lbl'+r[i][0],'red','white');
				 obj.style.visibility='visible';newHeight();}
				 else obj.style.visibility='hidden';
		}//
	}//for
	}
}

function doSubmit(){
	var action = parent.document.form1.baction.value;
	var x = 0;
	var size = <%=al.size()%>;
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.submit();
}
function reloadPage()
{
	document.form1.baction.value = '';
	var fecha = parent.document.form1.fecha.value;
	var cds = parent.document.form1.cds.value;
	var fg = parent.document.form1.fg.value;
	var fp = parent.document.form1.fp.value;
	var estado = parent.document.form1.estado.value;
	if(cds=='') cds = parent.document.form1.xCds.value;
	window.location= '../expediente/exp_sol_pacientes_det.jsp?fecha='+fecha+'&cds='+cds+'&fg='+fg+'&fp='+fp+'&estado='+estado;//.reload(true);
}
function isChecked(k)
{
		var tipoOrden = eval('document.form1.tipo_orden'+k).value;
		var codTratamiento = eval('document.form1.cod_tratamiento'+k).value;
		var fg ='<%=fg%>';

		if(tipoOrden == 4 && codTratamiento == 1 &&fg=='ME')
		{
				eval('document.form1.chkSolicitud'+k).checked = false;
				alert('Las órdenes de inhalotarapias solo pueden ser marcadas por INASA!!!');
		}
		else if(!eval('document.form1.chkSolicitud'+k).checked)
		{
				eval('document.form1.chkSolicitud'+k).checked = true;
				alert('No es posible quitar la confirmación!!!');

		}
}


function checkAll(){

		var e = window.document.form1.getElementsByTagName("input");

		for(c = 0; c<e.length;c++){
			 if ( e[c].type == 'checkbox' && e[c].value != "all" ){
			 if ( document.getElementById("chkAll").checked == true )
				 e[c].checked = true;
			 else
				 e[c].checked = false;
		 }
		}
}

function printLabels(value)
{
	document.form1.tipoComida.value = parent.document.form1.tipoComida.value;
	document.form1.baction.value = value;
	var size = document.form1.contOrden.value;
	var cont = 0;
	for(i=0;i<size;i++){
		if( $("#chk"+i).is(":checked")) cont++;
	}
	if(cont==0) alert('Seleccione al menos una orden!');
	else document.form1.submit();
}
function getList(pacId,adm, codeMed){showPopWin('../expediente/show_medi_msg.jsp?codMed='+codeMed+'&pacId='+pacId+'&noAdmision='+adm+'',winWidth*.65,winHeight*.65,null,null,'');}

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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("regChecked","")%>
<%=fb.hidden("solicitado_por",solicitado_por)%>
<%=fb.hidden("area","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("tipoComida","")%>
<table width="100%" align="center">
	<tr>
		<td colspan="8"><table width="100%">
				<tr class="TextHeader" align="center" height="20">
					<td width="5%"><cellbytelabel>Cama</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
					<td width="23%"><cellbytelabel>Nombre del Paciente</cellbytelabel></td>
					<td width="13%"><cellbytelabel>C&eacute;d./Pasap</cellbytelabel>.</td>
					<td width="8%"><cellbytelabel>Fecha Ingreso</cellbytelabel></td>
					<td width="18%"><cellbytelabel>M&eacute;d. Tratante</cellbytelabel></td>
					<td width="18%"><cellbytelabel>Aseguradora</cellbytelabel></td>
					<td width="5%" colspan="2">
			<%if(fp.equalsIgnoreCase("cons")){%>
					<%=fb.checkbox("chkAll","all",false, false,null,null,"onclick=\"javascript:checkAll()\"")%>
			<%}%>
			</td>
				</tr>
			</table></td>
	</tr>
	<%
String paciente = "", cdsDesc = "";
int nOrden =0;
int contOrden = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdod = (CommonDataObject) al.get(i);

	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
	<%=fb.hidden("pac_id"+i,cdod.getColValue("pac_id"))%>
	<%=fb.hidden("secuenciaCorte"+i,cdod.getColValue("secuenciaCorte"))%>
	<%=fb.hidden("codigo"+i,cdod.getColValue("codigo"))%>
	<%=fb.hidden("orden"+i,cdod.getColValue("noOrden"))%>
	<%=fb.hidden("tipo_orden"+i,cdod.getColValue("tipo_orden"))%>
	<%=fb.hidden("estado_orden"+i,cdod.getColValue("estado_orden"))%>
	<%=fb.hidden("cod_tratamiento"+i,cdod.getColValue("cod_tratamiento"))%>
	<%
	if(!paciente.equals(cdod.getColValue("nombre_paciente"))){
		String neIcon = "../images/blank.gif";
		String neIconDesc = "";
		if (cdod.getColValue("pendiente").equals("0"))
		{
			neIcon = "../images/check.gif";
		}
		else
		{
			neIcon = "../images/flag_red.gif";
			nOrden ++;
		}
%>
	<%=fb.hidden("pac_id_"+contOrden,cdod.getColValue("pac_id"))%>
	<%=fb.hidden("secuenciaCorte_"+contOrden,cdod.getColValue("secuenciaCorte"))%>
	<%=fb.hidden("orden_"+contOrden,cdod.getColValue("noOrden"))%>
	<tr>
		<td colspan="8"><table width="100%" cellpadding="1" cellspacing="0">
				<%if(cdod.getColValue("cds") != null){
				if ( !cdsDesc.equals(cdod.getColValue("cds")) ){
		%>
				<tr class="TextRow03">
					<td colspan="10"align="left" height="20"><cellbytelabel>Centro de Servicio</cellbytelabel>:&nbsp;&nbsp;<%=(cdod.getColValue("cds")==null?"":cdod.getColValue("cds"))%></td>
				</tr>
				<%}}%>
				<tr class="TextPanel02">
					<td width="5%" align="center"><%=cdod.getColValue("cama")%></td>
					<td width="10%">&nbsp;<%=cdod.getColValue("dsp_admision")%></td>
					<td width="21%">&nbsp;<%=cdod.getColValue("nombre_paciente")%></td>
					<td width="12%" align="center"><%=cdod.getColValue("identificacion")%></td>
					<td width="8%" align="center"><%=cdod.getColValue("fecha_ingreso")%></td>
					<td width="17%" align="center"><%=cdod.getColValue("nombre_medico")%></td>
					<td width="17%" align="center"><%=cdod.getColValue("nombre_empresa")%></td>

			<!--  blinking image -->
		<td width="5%"><label id="label<%=cdod.getColValue("pac_id")%>" style="cursor:pointer; visibility:hidden;" class="alert1" onClick="javascript:getList('<%=cdod.getColValue("pac_id")%>','<%=cdod.getColValue("secuenciaCorte")%>','<%=cdod.getColValue("cod_med")%>')"><img src="../images/alert_img.gif" alt="Alertas Medicamentos" id="blink_img<%=cdod.getColValue("pac_id")%>" name="blink_img<%=cdod.getColValue("pac_id")%>" style="background-image:none;"></label>

			</td>
			 <!--  blinking image / -->
					<td width="5%" align="center">
					<%if(!fp.equals("cons")){%>
					<img src="<%=neIcon%>" alt="<%=neIconDesc%>" height="20" width="20">
					<%} else {%>
					<%=fb.checkbox("chk"+contOrden,""+contOrden,false, false,null,null,"")%>

		 <%}%>
					</td>
				</tr>
			</table></td>
	</tr>
	<tr id="panel<%=i%>">
		<td colspan="8"><table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextHeader01">
					<td width="5%">Estado</td>
					<td width="10%">Hora Solicitud</td>
					<td width="50%" colspan="2">
						<%if(fg.trim().equals("NU")){%>
						Tipo Dieta - Sub Dieta
						<%}else{%>
						<cellbytelabel>Descripci&oacute;n</cellbytelabel>
						<%}%></td>
					<td width="16%"><cellbytelabel>Fecha Inicio</cellbytelabel></td>
					<td width="16%"><cellbytelabel>Fecha Omitida</cellbytelabel></td>
					<td width="3%"><%if(!fp.equals("cons")){%><cellbytelabel>Confi</cellbytelabel>.<%}%></td>
				</tr>
	<%
			contOrden++;
		}
	%>
				<tr class="<%=color%>">
					<td><%=cdod.getColValue("dsp_estado")%></td>
					<td><%=cdod.getColValue("hora_solicitud")%></td>
					<td colspan="2">
            <%if(fg.trim().equals("NU")){%>
            <%=cdod.getColValue("dietas_desc")%> - <%=cdod.getColValue("sub_dietas_desc")%>
            <%} else {%>
              <%=cdod.getColValue("nombre")%>
					  <%}%>
					</td>
					<td><%=cdod.getColValue("fecha_inicio")%></td>
					<td><%=cdod.getColValue("fecha_omitida")%></td>
					<td rowspan="2"><%if(!fp.equals("cons")){%><%=fb.checkbox("chkSolicitud"+i,"S",(cdod.getColValue("cds_recibido").equalsIgnoreCase("S")||cdod.getColValue("cds_omit_recibido").equalsIgnoreCase("S")), false,null,null,"onClick=\"javascript:isChecked("+i+")\"")%><%}%>
					</td>
				</tr>
				<%if(fg.trim().equals("NU")){%>
				<tr class="<%=color%>">
					<td colspan="2"><cellbytelabel>Tipo Tubo</cellbytelabel>:&nbsp;<%=cdod.getColValue("tipo_tubo")%></td>
					<td colspan="4"><b><cellbytelabel>Observaci&oacute;n</cellbytelabel>:</b>&nbsp;<%=cdod.getColValue("observacion_dietas")%></td>
				</tr>
				<%}%>
				<%if(fg.trim().equals("ME")){%>
				<tr class="<%=color%>">
					<td colspan="3"><cellbytelabel>Presentaci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("descVia")%>&nbsp;&nbsp;&nbsp;<cellbytelabel>Concentraci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("dosis")%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Frecuencia</cellbytelabel>:&nbsp;<%=cdod.getColValue("frecuencia")%></td>
					<td colspan="3"><cellbytelabel>Observaci&oacute;n</cellbytelabel>:<%=cdod.getColValue("observacion")%></td>
				</tr>
				<%}%>
				<%if(fg.trim().equals("IN")){%>
				<tr class="<%=color%>">
					<td colspan="3"></td>
					<td></td>
					<td></td>
					<td></td>
				</tr>
				<%}%>
				<%
	paciente = cdod.getColValue("nombre_paciente");
	if(!paciente.equals(cdod.getColValue("nombre_paciente")) && i>0){
%>
			</table></td>
	</tr>
	<%
	}
	cdsDesc = cdod.getColValue("cds");
}
%>

	<%=fb.hidden("nOrden",""+nOrden)%>
	<%=fb.hidden("size",""+al.size())%>
	<%=fb.hidden("contOrden",""+contOrden)%>
	<tr class="TextRow02">
		<td colspan="9" class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel>Solicitud(es)</cellbytelabel></td>
	</tr>
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

	int size = Integer.parseInt(request.getParameter("size"));
	if(!fp.equals("cons")){
		for (int i=0; i<size; i++)
		{
			DetalleOrdenMed dom = new DetalleOrdenMed();

			if(request.getParameter("chkSolicitud"+i) != null && !request.getParameter("chkSolicitud"+i).trim().equals(""))
			{
				if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&& request.getParameter("estado_orden"+i).trim().equals("A"))
			{
						dom.setCdsRecibido(request.getParameter("chkSolicitud"+i));
						dom.setCdsRecibidoUser((String) session.getAttribute("_userName"));
			}
			else if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&& request.getParameter("estado_orden"+i).trim().equals("S"))
			{
				dom.setCdsOmitRecibido(request.getParameter("chkSolicitud"+i));
				dom.setCdsOmitRecibidoUser((String) session.getAttribute("_userName"));
			}
			//dom.setCdsRecibido(request.getParameter("chkSolicitud"+i));
			}else	dom.setCdsRecibido("N");
			dom.setEstadoOrden("C");//Para confirmar que se recibio la solicitud de las ordenes.
			dom.setPacId(request.getParameter("pac_id"+i));
			dom.setSecuencia(request.getParameter("secuenciaCorte"+i));
			dom.setTipoOrden(request.getParameter("tipo_orden"+i));
			dom.setOrdenMed(request.getParameter("orden"+i));
			dom.setCodigo(request.getParameter("codigo"+i));
			al.add(dom);
		}
	} else {
		size = Integer.parseInt(request.getParameter("contOrden"));
		alOM.clear();
		for (int i=0; i<size; i++)
		{
			CommonDataObject dom = new CommonDataObject();

			if(request.getParameter("chk"+i) != null)
			{
			dom.addColValue("pac_id", request.getParameter("pac_id_"+i));
			dom.addColValue("admision", request.getParameter("secuenciaCorte_"+i));
			dom.addColValue("no_orden", request.getParameter("orden_"+i));
			alOM.add(dom);
			}
		}
		System.out.println("baction...............................................="+request.getParameter("baction"));
		response.sendRedirect("../expediente/exp_sol_pacientes_det.jsp?"+(request.getParameter("baction")!=null && request.getParameter("baction").equals("Label de Comida")?"type=1&":"")+"solicitado_por="+solicitado_por+"&cds="+cds+"&fg="+fg+"&fp="+fp+"&tipoComida="+request.getParameter("tipoComida"));
		return;
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	OMMgr.saveDetails(al);
	ConMgr.clearAppCtx(null);



	//om.setCompania((String) session.getAttribute("_companyId"));
	//om.setUsuarioCreacion((String) session.getAttribute("_userName"));


%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (OMMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=OMMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=OMMgr.getErrMsg()%>';
	parent.document.form1.submit();
<%} else throw new Exception(OMMgr.getErrException());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
