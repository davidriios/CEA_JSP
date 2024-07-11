<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="OMMgr" scope="page" class="issi.expediente.OrdenMedicaMgr" />
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
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbParam = new StringBuffer();
String pacId = request.getParameter("pacId");
String secuencia = request.getParameter("secuencia");
String id = request.getParameter("id");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String desc =request.getParameter("desc");
String tipoOrden = request.getParameter("tipoOrden");
String idOrden = request.getParameter("idOrden");
String nombre = request.getParameter("nombre");
String cedula = request.getParameter("cedula");
String cama = request.getParameter("cama");
String edad = request.getParameter("edad");
String sexo = request.getParameter("sexo");
String estado = request.getParameter("estado");
String orderset = request.getParameter("orderset");

String expVersion = "1";
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }


if (tipoOrden == null ) tipoOrden = "";
if (idOrden == null ) idOrden = "";
if (nombre == null) nombre = "";
if (cedula == null) cedula = "";
if (cama == null) cama = "";
if (edad == null) edad = "";
if (sexo == null) sexo = "";
if (estado == null) estado = "PP";
if (orderset == null) orderset = "";

if ( !tipoOrden.equals("") ) {
	sbFilter.append(" and a.tipo_orden = ").append(tipoOrden);
	sbParam.append("&tipoOrden = ").append(tipoOrden);
}
if ( !idOrden.equals("") ) {
	sbFilter.append(" and a.orden_med in ( ").append(idOrden).append(" )");
	sbParam.append("&idOrden = ").append(idOrden);
}
if ( !estado.equals("") ) {
	if (estado.equalsIgnoreCase("PP")) sbFilter.append(" and ((a.omitir_orden = 'N' and a.estado_orden = 'A') or (a.ejecutado = 'N' and a.estado_orden = 'S'))");
	else sbFilter.append(" and a.estado_orden = '").append(estado).append("'");
	sbParam.append("&estado = ").append(estado);
}

if (pacId == null || secuencia == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {
	sbSql.append("select a.secuencia as secuenciaCorte, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fechaSolicitud, decode(a.interfaz,'BDS','BANCO DE SANGRE',t.descripcion) as tipoOrden, decode(a.tipo_orden,3,'DIETA - '||x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre), 1, a.nombre||  decode( a.prioridad,'H','  --> HOY  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'U',' - HOY URGENTE  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'M','  --> MAÑANA '||to_char(a.fecha_orden,'dd-mm-yyyy'),'O','  --> '||to_char(a.fecha_orden,'dd-mm-yyyy'),'P','PRN')||' '||(case when interfaz ='BDS' then decode( a.causa,'Y','  --> TRANSFUNDIR HOY(2-3 HR)','Z','  --> CRUZAR/RESERVAR PRN  ','X',' - TRANSFUNDIR URGENTE(1HR - 1:30MIN)  ','W','  --> PROCEDIMIENTO PROGRAMADO ','R','  --> RESERVAR ') else '' END),  7,d.descripcion||' - '||a.observacion,a.nombre)||case when a.interfaz='BDS' then decode(a.cantidad,null,'',' CANTIDAD:'||a.cantidad)||decode(a.unidad_dosis,null,'',' UNIDAD DOSIS:'||a.unidad_dosis)||decode(a.motivo,null,'',' MOTIVO:'||(select descrip_motivo from  tbl_sal_motivo_sol_proc where codigo=motivo))||decode(a.observacion_enf,NULL,'',' OBSER. ADIC: '||a.observacion_enf)||decode(a.vol_pediatrico,null,'',' VOL. PEDIATRICO: '||a.vol_pediatrico) else ' ' end as nombre, a.ejecutado, tipo_orden, a.codigo, a.orden_med, a.estado_orden, a.omitir_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),' ') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida, a.frecuencia, (select descripcion from tbl_sal_via_admin where codigo=a.via) descVia,a.dosis_desc, (select descripcion from tbl_cds_ordenmedica_varios where codigo = a.tipo_ordenvarios) tipo_orden_varios,(select descripcion from tbl_cds_om_varios_subtipo where codigo = a.subtipo_ordenvarios and cod_tipo_ordenvarios = a.tipo_ordenvarios) sub_tipo_ordenvarios")

		.append(", nvl((select '<b>ACCION:</b> '|| m.accion||'<br><b>INTERACCION:</b>'||m.interaccion from tbl_sal_medicamentos m where m.compania = ")
		.append(session.getAttribute("_companyId"))
		.append(" and m.status = 'A' and antibio_ctrl = 'S' and m.medicamento = substr(a.nombre,0,instr(a.nombre,'/') - 2 ) and a.tipo_orden = 2 and rownum = 1)")
		.append("||case when (a.tipo_orden = 3 and nvl(a.nombre,a.observacion) is not null) or (a.tipo_orden <> 3 and a.observacion is not null) then '<br><b>Observación:</b><br>'||decode(a.tipo_orden,3,nvl(a.nombre,a.observacion),a.observacion) end")
		.append("||(select '<br><b>Despachado:</b>'||f.descripcion from tbl_int_orden_farmacia f where a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.other1 = 1 and f.estado in('A','R') and rownum = 1),' ') as control")

		.append(", case when a.omitir_fecha is not null then '--> ANULADO EL '||to_char(a.omitir_fecha,'dd/mm/yyyy hh12:mi am') when a.fecha_suspencion is not null then '--> OMITIDO EL '||to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') else ' ' end as omitidoSuspendido, decode(a.stat,'Y','STAT','C','AHORA', 'R','RUTINA','') stat")
		.append(", (select descripcion from tbl_cds_tipo_dieta where codigo = a.tipo_dieta and rownum = 1) dietas_desc, (select join( cursor( select descripcion from tbl_cds_subtipo_dieta where cod_tipo_dieta = a.tipo_dieta and descripcion in (select column_value from table( select split(a.observacion,',') from dual ))), '**' ) sub_dietas from dual ) sub_dietas_desc ")
		.append(", decode(a.tipo_orden,1,(select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio)||' / ', ' ') as cdsDesc, a.usuario_creacion as usuario, (select (select '['||codigo||'] '||decode(sexo,'F','DRA. ','M','DR. ')||primer_nombre||decode(segundo_nombre,null,' ',segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,' ', segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,' ',apellido_de_casada)) from tbl_adm_medico where codigo= x.medico) from tbl_sal_orden_medica x where x.pac_id = a.pac_id and x.secuencia = a.secuencia and x.codigo = a.orden_med) as medico, a.forma_solicitud, case when a.forma_solicitud = 'T' and nvl(a.validada,'N') = 'N' then 'N' else 'S' end as validada from tbl_sal_detalle_orden_med a, tbl_sal_tipo_orden_med t, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo = c.cod_tipo_dieta union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, tbl_sal_orden_salida d, tbl_adm_admision z where z.pac_id = a.pac_id and z.secuencia = a.secuencia and z.pac_id = ")
		.append(pacId)
		.append(" and z.adm_root = ")
		.append(secuencia)
		.append(" and a.tipo_orden = t.codigo(+) and a.tipo_dieta||'-'||a.cod_tipo_dieta = x.codigo(+) and a.cod_salida=d.codigo(+) ")
		.append(sbFilter);

	sbSql.append(" order by a.fecha_creacion desc ");

	/*and (to_date(to_char(a.fecha_orden,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') or (to_date(to_char(a.fecha_fin,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')))**/

	al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Listado de Ordenes Médicas - '+document.title;

function executeOrder(k)
{
<%
if (!(UserDet.getUserTypeCode().trim().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("ES")))
{
%>
		eval('document.form0.cancel_disp'+k).disabled=eval('document.form0.execute_disp'+k).checked;
<%
}
%>
	var nExecute=parseInt(document.form0.nExecute.value,10);
	if(eval('document.form0.execute_disp'+k).checked)
	{
		nExecute++;
		eval('document.form0.execute'+k).value='S';
	}
	else
	{
		nExecute--;
		eval('document.form0.execute'+k).value='N';
	}
	document.form0.nExecute.value=nExecute;
}

function cancelOrder(k)
{
	var codigo=eval('document.form0.codigo'+k).value;
	var orden_med=eval('document.form0.orden_med'+k).value;
	var tipo_orden=eval('document.form0.tipo_orden'+k).value;
	var secuenciaCorte=eval('document.form0.secuenciaCorte'+k).value;

		if(eval('document.form0.cancel_disp'+k).checked&&hasDBData('<%=request.getContextPath()%>','tbl_sal_detalle_orden_med','pac_id=<%=pacId%> and secuencia='+secuenciaCorte+' and tipo_orden='+tipo_orden+' and orden_med='+orden_med+' and codigo='+codigo+' and ejecutado=\'S\'',''))
		{
			alert('Esta orden ya fue EJECUTADA por la enfermera,  NO PUEDE SER OMITIDA!');
			eval('document.form0.cancel_disp'+k).checked=false;
			eval('document.form0.cancel_disp'+k).disabled=true;
			eval('document.form0.cancel'+k).value='N';
			eval('document.form0.execute_disp'+k).checked=true;
			eval('document.form0.execute'+k).value='S';
			eval('document.form0.ejecutado'+k).value='S';
		}
<%
if (!(UserDet.getRefType().trim().equalsIgnoreCase("M")||UserDet.getXtra5().trim().equalsIgnoreCase("S")))
{
%>

		eval('document.form0.execute_disp'+k).disabled=eval('document.form0.cancel_disp'+k).checked;

<%
}
%>
		var nCancelOrder=parseInt(document.form0.nCancelOrder.value,10);
		if(eval('document.form0.cancel_disp'+k).checked)
		{
			nCancelOrder++;
			eval('document.form0.cancel'+k).value='S';
		}
		else
		{
			nCancelOrder--;
			eval('document.form0.cancel'+k).value='N';
		}
		document.form0.nCancelOrder.value=nCancelOrder;
}

function printList(isAll){
	if (isAll) abrir_ventana('../expediente/print_list_ordenmedica.jsp?pacId=<%=pacId%>&noAdmision=<%=secuencia%>&all=y');
	else abrir_ventana('../expediente/print_list_ordenmedica.jsp?pacId=<%=pacId%>&noAdmision=<%=secuencia%><%=sbParam%>');
}

var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();loaded=true;}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}

function suspenderOrder(k,fg)
{
		var observ='';
		var nSuspOrder=parseInt(document.form0.nSuspOrder.value,10);
		if(nSuspOrder<0)nSuspOrder=0;
		if(eval('document.form0.suspenderOrden'+k).checked)
		{
			nSuspOrder++;
			eval('document.form0.suspender'+k).value='S';
			if(fg=='1')eval('document.form0.fechaSuspencion'+k).value='<%=cDateTime%>';
			//observ = prompt('Observacion Medica', '');
			if(observ!=null)eval('document.form0.observacion'+k).value=observ;
		}
		else
		{
			nSuspOrder--;
			eval('document.form0.suspender'+k).value='N';
			eval('document.form0.fechaSuspencion'+k).value='';
		}
		document.form0.nSuspOrder.value=nSuspOrder;
}

$(function(){
	$(".control-launcher").tooltip({
	content: function () {
		var $i = $(this).data("i");
		var $title = $($(this).prop('title'));
		var $content = $("#controlCont"+$i).val();
		var $cleanContent = $($content).text();
		if (!$cleanContent) $content = "";
		return $content;
	}
	});
	$(".phone-launcher").tooltip({
	content: function () {return "<label style='font-size:11px'>"+$(this).prop('title')+"</label>";}
	});
});
jQuery(document).ready(function(){doAction();});
</script>
<%if(orderset.equalsIgnoreCase("Y")){%>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="LISTADO DE ORDENES MEDICAS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table width="100%" cellpadding="1" cellspacing="1" id="_tblMain">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nExecute","0")%>
<%=fb.hidden("nCancelOrder","0")%>
<%=fb.hidden("nSuspOrder","0")%>

<%=fb.hidden("desc",desc)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("cama",cama)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("orderset",orderset)%>
<tr class="TextHeader">
		<td colspan="3">
				<b>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<%=pacId+"-"+secuencia%>]
				&nbsp;&nbsp;<%=nombre%>
				&nbsp;&nbsp;/&nbsp;<%=sexo%>
				&nbsp;/&nbsp;<%=cedula%>
				&nbsp;/&nbsp;<%=edad%> A&Ntilde;OS&nbsp;/&nbsp;
				<%=cama%>
				</b>
		</td>
</tr>
<tr class="TextFilter">
	<td colspan="3">
		<cellbytelabel>Tipo Orden</cellbytelabel>
		<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sal_tipo_orden_med order by descripcion","tipoOrden",tipoOrden,false,false,0,"Text10",null,null,null,"T")%>
		<cellbytelabel>Estado</cellbytelabel>
		<%=fb.select(ConMgr.getConnection(),"select estado, descripcion from tbl_sal_desc_estado_ord union all select 'PP', '- ACTIVA / OMITIDA X CONFIRMAR -' from dual order by 2","estado",estado,false,false,0,"Text10",null,null,null,"T")%>
		<%=fb.submit("go","Ir")%>
	</td>
</tr>
<%=fb.formEnd(true)%>

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nExecute","0")%>
<%=fb.hidden("nCancelOrder","0")%>
<%=fb.hidden("nSuspOrder","0")%>

<%=fb.hidden("desc",desc)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("edad",edad)%>
<%=fb.hidden("cama",cama)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("orderset",orderset)%>



<%fb.appendJsValidation("if(parseInt(document.form0.nSuspOrder.value,10)>0&&!confirm('¿Está seguro que desea Suspender las ordenes medicas?'))error++;");%>
<%fb.appendJsValidation("if(parseInt(document.form0.nExecute.value,10)==0&&parseInt(document.form0.nCancelOrder.value,10)==0&&parseInt(document.form0.nSuspOrder.value,10)==0)error++;");%>
<%fb.appendJsValidation("if(parseInt(document.form0.nCancelOrder.value,10)>0&&!confirm('¿Está seguro que desea omitir las ordenes medicas?'))error++;");%>

<tr>
	<td width="20%">&nbsp;</td>
	<td width="60%" align="center"><cellbytelabel id="1">Total Registro(s)</cellbytelabel> <%=al.size()%>&nbsp;&nbsp;&nbsp;&nbsp;<label class="RedTextBold">Las órdenes donde el médico que solicita se muestren en color rojo, son órdenes telefónicas pendientes por Validar. </label></td>
	<td width="20%" align="right">
		&nbsp;
		<% if ( idOrden.equals("")){ %>
		<authtype type='50'><%=fb.button("print","Imprimir",true,false,"Text10",null,"onClick=\"javascript:printList()\"")%></authtype>
		<authtype type='51'><%=fb.button("print","Imprimir Todo",true,false,"Text10",null,"onClick=\"javascript:printList(1)\"")%></authtype>
		<% } %>
		<%=fb.submit("save","Guardar",true,!(UserDet.getUserProfile().contains("0") || UserDet.getRefType().trim().equalsIgnoreCase("M") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("ES")),"Text10",null,null)%>
	</td>
</tr>
<tr>
	<td colspan="3">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr align="center" class="TextHeader">
			<td width="12%"><cellbytelabel id="2">Fecha de Solicitud</cellbytelabel></td>
			<td width="13%"><cellbytelabel id="3">Tipo Orden</cellbytelabel></td>
			<td width="33%"><cellbytelabel id="4">Descripci&oacute;n de la Orden</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="4">U. Creacion</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="4">M. Solicita</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="5">Ejecutada</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="6">Anular</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="7">Omitir/Suspender</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	boolean valid2process = (cdo.getColValue("omitir_orden").equalsIgnoreCase("N") && cdo.getColValue("estado_orden").equalsIgnoreCase("A")) || (cdo.getColValue("ejecutado").equalsIgnoreCase("N") && cdo.getColValue("estado_orden").equalsIgnoreCase("S"));
%>
		<%=fb.hidden("secuenciaCorte"+i,cdo.getColValue("secuenciaCorte"))%>
		<%=fb.hidden("ejecutado"+i,cdo.getColValue("ejecutado"))%>
		<%=fb.hidden("tipo_orden"+i,cdo.getColValue("tipo_orden"))%>
		<%=fb.hidden("cod_salida"+i,cdo.getColValue("cod_salida"))%>

		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("orden_med"+i,cdo.getColValue("orden_med"))%>
		<%=fb.hidden("observacion"+i,"")%>
		<%=fb.hidden("controlCont"+i,"<label class='controlCont' style='font-size:11px'>"+((cdo.getColValue("control").trim().equals(""))?"":cdo.getColValue("control"))+"</label>")%>

		<%=fb.hidden("valid2process"+i,""+valid2process)%>
		<tr class="<%=color%>">
			<td align="center"><%=cdo.getColValue("fechaSolicitud")%></td>
			<td align="center"><%=cdo.getColValue("tipoOrden")%></td>
			<td>
				<%if(cdo.getColValue("tipo_orden").trim().equals("8")){%>
								<b><%=cdo.getColValue("tipo_orden_varios")%></b>&nbsp;::&nbsp;
								<b><%=cdo.getColValue("sub_tipo_ordenvarios")%></b>&nbsp;|&nbsp;
				<%}%>
				<%if(!expVersion.equals("3") && cdo.getColValue("tipo_orden").trim().equals("3")){%>
								DIETA: <%=cdo.getColValue("dietas_desc")%> - <%=cdo.getColValue("sub_dietas_desc")%>
				<%} else {%>
									<%=cdo.getColValue("cdsDesc")%> <%=cdo.getColValue("nombre")%>
				<%}%>

				<%if(cdo.getColValue("tipo_orden").trim().equals("1")||cdo.getColValue("tipo_orden").trim().equals("2")||cdo.getColValue("tipo_orden").trim().equals("3")){%>
								<%if(!cdo.getColValue("descVia"," ").trim().equals("")){%>&nbsp;-&nbsp;<label class="TextRow07">VIA ADMIN:</label>&nbsp;<b><%=cdo.getColValue("descVia")%></b><%}if(!cdo.getColValue("frecuencia"," ").trim().equals("")){%>&nbsp;-&nbsp;<label class="TextRow07">FREC.:</label>&nbsp;<b><%=cdo.getColValue("frecuencia")%></b><label class="RedTextBold">&nbsp;<b><%=cdo.getColValue("stat")%></b></label><%}%>

					<% if (!cdo.getColValue("control").trim().equals("")) { %><img src="../images/info.png" width="24px" height="24px" class="control-launcher" title="" data-i="<%=i%>" style="vertical-align:middle"><% } %>
				<%}%>
				<%if(expVersion.equals("3") && cdo.getColValue("tipo_orden").trim().equals("2") && !cdo.getColValue("dosis_desc"," ").trim().equals("") ){%>&nbsp;&nbsp;-&nbsp;&nbsp;<label class="TextRow07">DOSIS:</label>&nbsp;<b><%=cdo.getColValue("dosis_desc")%></b><%}%>
				<%if (!cdo.getColValue("omitidoSuspendido").trim().equals("")){%>
				</br><label class="RedText"><%=cdo.getColValue("omitidoSuspendido")%></label>
				<%}%>
			</td>
			<td><%=cdo.getColValue("usuario")%> <% if (cdo.getColValue("forma_solicitud").equalsIgnoreCase("T")) { %><img src="../images/phone.png" width="24px" height="24px" class="phone-launcher" title="Usuario que recibe, transcribe, lee y confirma" style="vertical-align:middle"><% } %></td>
			<td><%if(cdo.getColValue("validada").trim().equals("N")){%><label class="RedTextBold"><%}%><%=cdo.getColValue("medico")%><%if(cdo.getColValue("validada").trim().equals("N")){%></label><%}%></td>
			<td align="center">
				<%=fb.hidden("execute"+i,cdo.getColValue("ejecutado"))%>
				<%=fb.checkbox("execute_disp"+i,"S",(cdo.getColValue("ejecutado").equalsIgnoreCase("S")),!valid2process || (!(UserDet.getUserProfile().contains("0") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("EN") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("AU") || UserDet.getUserTypeCode().trim().equalsIgnoreCase("ES") ||  UserDet.getUserTypeCode().trim().equalsIgnoreCase("MS"))),null,null,"onClick=\"javascript:executeOrder("+i+")\"")%>
			</td>
			<td align="center">
				<%=fb.hidden("cancel"+i,"N")%>
				<%=fb.checkbox("cancel_disp"+i,"X",(cdo.getColValue("omitir_orden").equalsIgnoreCase("S")),!valid2process || (cdo.getColValue("ejecutado").equalsIgnoreCase("S") || !(UserDet.getRefType().trim().equalsIgnoreCase("M") || UserDet.getUserProfile().contains("0")||UserDet.getXtra5().trim().equalsIgnoreCase("S")) || (cdo.getColValue("ejecutado").equalsIgnoreCase("N") && !cdo.getColValue("fechaSuspencion").trim().equals(""))),null,null,"onClick=\"javascript:cancelOrder("+i+")\"")%>
			</td>

			<td align="center">
				<%=fb.hidden("suspender"+i,"N")%>
				<% if (valid2process && (cdo.getColValue("ejecutado").equalsIgnoreCase("S") && (UserDet.getRefType().trim().equalsIgnoreCase("M") || UserDet.getUserProfile().contains("0")||UserDet.getXtra5().trim().equalsIgnoreCase("S")))) { %>


				<%=fb.checkbox("suspenderOrden"+i,"S",(cdo.getColValue("estado_orden").equalsIgnoreCase("S")||(cdo.getColValue("fechaSuspencion") != null &&  !cdo.getColValue("fechaSuspencion").trim().equals(""))),(cdo.getColValue("tipo_orden").trim().equals("7") && !cdo.getColValue("cod_salida").equalsIgnoreCase("1"))?true:false,null,null,"onClick=\"javascript:suspenderOrder("+i+",1)\"")%>
				<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
										<jsp:param name="nameOfTBox1" value="<%="fechaSuspencion"+i%>" />
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaSuspencion")%>" />
										<jsp:param name="jsEvent" value="<%="suspenderOrder("+i+",2)"%>"/>
										<jsp:param name="onChange" value="<%="javascript:suspenderOrder("+i+",2)"%>"/>

										<jsp:param name="readonly" value="<%=(cdo.getColValue("tipo_orden").trim().equals("7") && !cdo.getColValue("cod_salida").equalsIgnoreCase("1"))?"y":"n"%>"/>
										</jsp:include>
										<%//=fb.textarea("medicamentos","",false,false ,false,40,1,2000,null,"",null)%>
		<%}%>
			</td>
		</tr>
<%
}
%>
		</table>
</div>
</div>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		DetalleOrdenMed dom = new DetalleOrdenMed();

		dom.setPacId(pacId);
		dom.setSecuencia(request.getParameter("secuenciaCorte"+i));
		dom.setTipoOrden(request.getParameter("tipo_orden"+i));
		dom.setOrdenMed(request.getParameter("orden_med"+i));
		dom.setCodigo(request.getParameter("codigo"+i));
		dom.setEjecutado(request.getParameter("execute"+i));
		dom.setEjecutadoUsuario((String) session.getAttribute("_userName"));
		dom.setOmitirOrden(request.getParameter("cancel"+i));
		dom.setUsuarioModificacion((String) session.getAttribute("_userName"));
		dom.setOmitirUsuario((String) session.getAttribute("_userName"));

		dom.setObserSuspencion(request.getParameter("observacion"+i));
		dom.setEstadoOrden(request.getParameter("suspender"+i));
		//dom.setFechaFin(request.getParameter("fechaFin"+i));
		dom.setCodSalida(request.getParameter("cod_salida"+i));
		dom.setFechaSuspencion(request.getParameter("fechaSuspencion"+i));
		dom.setComentarioCancela("SE CANCELA POR ANULACION DE ORDEN MEDICA");

		if (request.getParameter("valid2process"+i) != null && request.getParameter("valid2process"+i).equalsIgnoreCase("true")) al.add(dom);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	OMMgr.saveDetails(al);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (OMMgr.getErrCode().equals("1"))
{
%>
	alert('<%=OMMgr.getErrMsg()%>');
	parent.reloadPage();
<%
} else throw new Exception(OMMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>