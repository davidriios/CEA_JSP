<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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
ArrayList al2 = new ArrayList();
ArrayList codMed = new ArrayList();
String change = request.getParameter("change");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbSubFilter = new StringBuffer();
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String pacBarcode = request.getParameter("pacBarcode");
String paciente = request.getParameter("paciente");
String compania = (String) session.getAttribute("_companyId");
String estado = request.getParameter("estado");
String cds = request.getParameter("cds");
String orden = request.getParameter("orden");
String timer = request.getParameter("timer");
String setFecha =request.getParameter("setFecha");
boolean cdsExpanded = (request.getParameter("cdsExpanded") != null && (request.getParameter("cdsExpanded").equalsIgnoreCase("S") || request.getParameter("cdsExpanded").equalsIgnoreCase("Y")));
if (paciente == null) paciente = "";
if (pacBarcode == null) pacBarcode = "";
if (fechaHasta == null) fechaHasta = "";
if (cds == null) cds = "";
if (estado == null) estado = "";
if (orden == null) orden = "D";
if (timer == null) timer = "";
if (setFecha ==null)setFecha="";
if (mode == null) mode = "add";
String expVersion = "1"; 
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (fg.trim().equals("ME") || fg.trim().equals("BM")) {//SOLICITUDES DE FARMACIA 

		sbSubFilter.append(" ( (p.cds_recibido = 'N' and p.estado_orden = 'A' and p.omitir_orden = 'N'");
		if (!fecha.trim().equals("")) { sbSubFilter.append(" and trunc(p.fecha_inicio) >= to_date('"); sbSubFilter.append(fecha); sbSubFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbSubFilter.append(" and trunc(p.fecha_inicio) <= to_date('"); sbSubFilter.append(fechaHasta); sbSubFilter.append("','dd/mm/yyyy')"); }
		sbSubFilter.append(") or (p.cds_omit_recibido = 'N' and p.estado_orden = 'S' and p.omitir_orden = 'N'");
		if (!fecha.trim().equals("")) { sbSubFilter.append("  and trunc(p.fecha_suspencion) >= to_date('"); sbSubFilter.append(fecha); sbSubFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbSubFilter.append(" and trunc(p.fecha_suspencion) <= to_date('"); sbSubFilter.append(fechaHasta); sbSubFilter.append("','dd/mm/yyyy')"); }		
		sbSubFilter.append(") ) and p.tipo_orden in (2,13,14)");

		sbFilter.append(" and a.omitir_orden = 'N' and a.tipo_orden in (2,13,14)");
		if (!fecha.trim().equals("")) { sbFilter.append(" and ( (trunc(a.fecha_inicio) >= to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_inicio) <= to_date('"); sbFilter.append(fechaHasta); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fecha.trim().equals("")) { sbFilter.append(") or (a.estado_orden = 'S' and trunc(a.fecha_suspencion) >= to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fechaHasta.trim().equals("")) { sbFilter.append(" and trunc(a.fecha_suspencion) <= to_date('"); sbFilter.append(fechaHasta); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fecha.trim().equals("") || (!fechaHasta.trim().equals("") && !fecha.trim().equals(""))) sbFilter.append(") )");
	}

	if (!pacBarcode.trim().equals("")) { sbFilter.append(" and a.pac_id = "); sbFilter.append(pacBarcode.substring(0,10)); sbFilter.append(" and a.secuencia = "); sbFilter.append(pacBarcode.substring(10)); }
	if (!estado.trim().equals("") && estado.trim().equals("PP")) sbFilter.append(" and not exists (select 1 from tbl_int_orden_farmacia far where far.pac_id = a.pac_id and far.admision = a.secuencia and far.tipo_orden = a.tipo_orden and far.orden_med = a.orden_med and far.codigo = a.codigo and nvl(far.aprobado_desp,'N') = 'N' )");
	else if (!estado.trim().equals("") && !estado.trim().equals("PP") && !estado.trim().equals("R")) { sbFilter.append(" and f.estado = '"); sbFilter.append(estado); sbFilter.append("'"); }
	else if (!estado.trim().equals("")&&estado.trim().equals("R")) sbFilter.append(" and a.cds_recibido = 'S'");
	if (!cds.trim().equals("")) { sbFilter.append(" and a.centro_servicio = "); sbFilter.append(cds); }
	if (!paciente.trim().equals("")) { sbFilter.append(" and upper(b.nombre_paciente) like '%"); sbFilter.append(paciente.toUpperCase()); sbFilter.append("%'"); }
	if (fg.trim().equals("BM")) sbFilter.append(" and a.id_articulo is not null and exists (select null from tbl_inv_articulo_bm where cod_articulo = a.id_articulo and compania = z.compania and estado = 'A')");
	//if (!fg.trim().equals("BM")) { sbFilter.append(" and z.compania <> "); sbFilter.append(compania); }

	sbSql.append("select distinct (select descripcion from tbl_cds_centro_servicio where codigo = x.centro_servicio) as cds_desc, x.* from (");
		sbSql.append("select nvl((select count(*) as pendiente from tbl_sal_detalle_orden_med p where ");
		sbSql.append(sbSubFilter);
		sbSql.append("),0) as pendiente, a.cds_omit_recibido, (select v.descripcion from tbl_sal_via_admin v where  v.codigo = a.via) as descVia, a.frecuencia, a.dosis, a.observacion, decode(a.tipo_tubo,'G','GOTEO','N','BOLO') as tipo_tubo, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss AM') as fecha_inicio, decode(a.estado_orden,'S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi:ss AM'),'F',to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss AM')) as fecha_omitida, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula,b.pasaporte) as identificacion, b.nombre_paciente, (to_number(to_char(sysdate,'YYYY')) - to_number(to_char(b.fecha_nacimiento,'YYYY'))) as edad, a.secuencia as dsp_admision, (select nombre_corto from tbl_sal_desc_estado_ord where estado=a.estado_orden) as dsp_estado, to_char(a.fecha_creacion,'hh12:mi:ss AM') as hora_solicitud, nvl(a.cds_recibido,'N') as cds_recibido, a.secuencia as secuenciaCorte, a.tipo_orden, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, a.nombre, a.ejecutado, a.cod_tratamiento, a.codigo, a.orden_med noOrden, a.pac_id, a.estado_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida, nvl((select cama from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia),' ') as cama, to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(z.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, b.sexo, nvl(f.estado,'N') as despachado, a.codigo_orden_med, getaseguradora2(z.secuencia,z.pac_id,z.aseguradora) as empresa, decode(a.tipo_orden,2,'ME','NU') as tipoOrd, a.id_articulo, (select count(*) from tbl_inv_articulo_bm where cod_articulo = id_articulo and compania = z.compania and estado = 'A') as esBm, nvl(fn_far_orden_pend(a.codigo_orden_med,a.pac_id ,a.secuencia,'");
		sbSql.append(fg);
		sbSql.append("'),0) as ord_pen, get_admCorte(a.pac_id,z.adm_root) as admCorte, z.adm_root as admRoot, a.fecha_creacion, z.categoria as categoria_adm, nvl(a.dosis_desc,' ') as dosis_desc, a.cantidad as cant, a.centro_servicio, a.stat,  nvl(fn_far_orden_sal(a.pac_id,a.secuencia,'FAR'),0) as ordSalida  ");
		sbSql.append(" from vw_adm_paciente b, tbl_sal_detalle_orden_med a, tbl_adm_admision z, tbl_int_orden_farmacia f");
		sbSql.append(" where z.pac_id = a.pac_id and z.secuencia = a.secuencia and a.pac_id = b.pac_id ");
		sbSql.append(sbFilter);
		sbSql.append(" and a.pac_id = f.pac_id(+) and a.secuencia = f.admision(+) and a.tipo_orden = f.tipo_orden(+) and a.orden_med = f.orden_med(+) and a.codigo = f.codigo(+)");
	sbSql.append(") x where exists (select null from tbl_adm_admision where pac_id = x.pac_id and secuencia = admCorte"); 
	//if (estado.trim().equals("PP") || estado.trim().equals("P")) sbSql.append(" and estado in ('A','E')");
	sbSql.append(") order by 1, x.centro_servicio, x.fecha_creacion");
	if(orden.trim().equals("D")) sbSql.append(" desc");
	sbSql.append(", x.pac_id, x.codigo_orden_med");
	System.out.println("---------> List SQL...");
	al = SQLMgr.getDataList(sbSql.toString());

	StringBuffer sbSqlGroup = new StringBuffer();
	sbSqlGroup.append("select z.centro_servicio as cds, count(*) as n_recs from (");
	sbSqlGroup.append(sbSql);
	sbSqlGroup.append(") z group by z.centro_servicio");
	System.out.println("---------> Group SQL...");
	ArrayList alCds = SQLMgr.getDataList(sbSqlGroup.toString());
	Hashtable htCds = new Hashtable();
	for (int i = 0; i < alCds.size(); i++) {
		CommonDataObject gCdo = (CommonDataObject) alCds.get(i);
		try {
			htCds.put(gCdo.getColValue("cds"),gCdo.getColValue("n_recs"));
		} catch(Exception ex) {
			System.out.println("Error al registrar conteo de centros!");
		}
	}

	StringBuffer sbSql2 = new StringBuffer();
	sbSql2.append("select get_sec_comp_param(");
	sbSql2.append(compania);
	sbSql2.append(",'CDS_FAR') as cds, get_sec_comp_param(");
	sbSql2.append(compania);
	sbSql2.append(",'FAR_USA_INSUMOS') as far_usar_insumos, nvl(get_sec_comp_param(");
	sbSql2.append(compania);
	sbSql2.append(",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad from dual");
	CommonDataObject cdoInsumos = SQLMgr.getData(sbSql2.toString());
	if (cdoInsumos == null) cdoInsumos = new CommonDataObject();

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	//if(parent.adjustIFrameSize){ parent.adjustIFrameSize(window);}
	<%if(timer.trim().equals("S")){%>timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','reloadPage()');<%}%>
	var pendientes =0;
	if(eval('document.form1.pendiente0'))pendientes = document.form1.pendiente0.value;
	parent.document.form1.gSol.value=pendientes;
	parent.checkPendingOM();}

function doSubmit(){
	var action = parent.document.form1.baction.value;
	var x = 0;
	var size = <%=al.size()%>;
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.submit();
}
function isChecked(k)
{
		var tipoOrden = eval('document.form1.tipo_orden'+k).value;
		var codTratamiento = eval('document.form1.cod_tratamiento'+k).value;
		var fg ='<%=fg%>';

		if(tipoOrden == 4 && codTratamiento == 1 &&(fg=='ME'||fg=='BM'))
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
function despachar(pac_id, no_adm, noorden,idArticulo, categoria){
	var fecha = parent.document.form1.fecha.value;
	var fechaHasta  = parent.document.form1.fechaHasta.value;
	//if(tipo=='ME')
	abrir_ventana2('../farmacia/exp_orden_medicamentos_list.jsp?pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&fecha='+fecha+'&idArticulo='+idArticulo+'&fg=<%=fg%>&estado=<%=estado%>&cds=<%=cds%>&categoria_adm='+categoria+'&timer=<%=timer%>&fechaHasta='+fechaHasta);
	//else abrir_ventana2('../farmacia/exp_orden_medicamentos_list.jsp?pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&fecha='+fecha);
}
function getList(pacId,adm, codeMed){showPopWin('../farmacia/show_medi_msg.jsp?pacId='+pacId+'&noAdmision='+adm+'',winWidth*.65,winHeight*.65,null,null,'');}
function reloadPage()
{
	var fecha = parent.document.form1.fecha.value;
	var fechaHasta = parent.document.form1.fechaHasta.value;
	var paciente = parent.document.form1.paciente.value;
	var pacBarcode = parent.document.form1.pacBarcode.value;
	if(parent.document.form1.pacBarcode.value!='')pacBarcode=parent.getPB();
	var _sysdate = '<%=(setFecha.trim().equals("S"))?CmnMgr.getCurrentDate("dd/mm/yyyy"):""%>';
	
	if(_sysdate!=parent.document.form1.fecha.value) parent.window.location= '../farmacia/exp_sol_pacientes.jsp?fecha='+_sysdate+'&fg=<%=fg%>&estado=<%=estado%>&cds=<%=cds%>&orden=<%=orden%>&pacBarcode='+pacBarcode+'&paciente='+paciente+'&setFecha=<%=setFecha%>';
	else window.location= '../farmacia/exp_sol_pacientes_det2.jsp?fecha='+fecha+'&fechaHasta='+fechaHasta+'&fg=<%=fg%>&estado=<%=estado%>&cds=<%=cds%>&orden=<%=orden%>&pacBarcode='+pacBarcode+'&paciente='+paciente+'&timer=<%=timer%>&setFecha=<%=setFecha%>&cdsExpanded=<%=cdsExpanded?"Y":"N"%>';
	
	
}
function imprimirOrden(pacId,adm,noOrden)
{
	//abrir_ventana('../expediente/print_exp_seccion_97.jsp?pacId='+pacId+'&noAdmision='+adm+'&desc=O/M NUTRICION PARENTERAL&idOrden='+noOrden);
	abrir_ventana('../expediente/print_exp_seccion_5.jsp?fg=FAR&pacId='+pacId+'&noAdmision='+adm+'&noOrden='+noOrden+'&desc=O/M MEDICAMENTOS&exp=<%=expVersion%>');

}

function insumos(pacId, noAdmision, noOrden, codigoOrden){
    if(hasDBData('<%=request.getContextPath()%>','tbl_int_orden_farmacia','compania = <%=compania%> and admision='+noAdmision+' and pac_id='+pacId+' and tipo_orden = 2 and estado=\'P\' and codigo_orden_med = '+noOrden,'')){
        var cds = getDBData('<%=request.getContextPath()%>',"get_sec_comp_param(<%=compania%>,'CDS_FAR')",'dual',null,'');
        <%
          String wh = "", fliaMedFar = "";
          try {wh =java.util.ResourceBundle.getBundle("farmacia").getString("whFar");}catch(Exception e){ wh = "";}
          try {fliaMedFar =java.util.ResourceBundle.getBundle("farmacia").getString("fliaMedFar");}catch(Exception e){ fliaMedFar = "";}
        %>
        var tipoServ = getDBData('<%=request.getContextPath()%>',"tipo_servicio",'tbl_inv_familia_articulo','compania=<%=compania%> and cod_flia = <%=fliaMedFar%>','') || "";
                
        abrir_ventana('../facturacion/reg_cargo_dev_new.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&fg=PAC&fPage=int_farmacia&tipoTransaccion=C&cds='+cds+'&wh=<%=wh%>&no_orden='+noOrden+'&tipoServicio='+tipoServ+'&codigo_orden='+codigoOrden);
    }else parent.CBMSG.warning('El paciente no tiene una orden despachada!');
}

function printOrdenList(pacId, noAdmision){
  abrir_ventana2("../expediente/print_list_ordenmedica.jsp?pacId="+pacId+"&noAdmision="+noAdmision);
}
function showDespachado(pacId, noAdmision, noOrden, cat, codOrdenMed){
 abrir_ventana2("../farmacia/print_medicamentos_despachados.jsp?pacId="+pacId+"&fg=<%=fg%>&noAdmision="+noAdmision+"&noOrden="+noOrden+"&categoria_adm="+cat+"&codigo_orden_med="+codOrdenMed);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%=sbSql%>
<table width="100%" align="center">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("timer",""+timer)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("regChecked","")%>
<%=fb.hidden("solicitado_por","")%>
<%=fb.hidden("area","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("_timer","")%>
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("estado",""+estado)%>
<%=fb.hidden("setFecha",""+setFecha)%>
<%=fb.hidden("cdsExpanded",cdsExpanded?"Y":"N")%>
<tr>
	<td>
		<table width="100%">
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel>No. Paciente</cellbytelabel></td>
			<td width="28%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="10%"><cellbytelabel>C&eacute;d./Pasap</cellbytelabel>.</td>
			<td width="10%"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
			<td width="5%"><cellbytelabel>Edad</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Sexo</cellbytelabel></td>
			<td width="5%"><cellbytelabel>No. Admi</cellbytelabel>.</td>
			<td width="8%"><cellbytelabel>Fecha Ingreso</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Cama</cellbytelabel></td>
			<td width="3%">&nbsp;</td>
			<td width="3%"><cellbytelabel>Sec. Orden</cellbytelabel></td>
			<td width="8%">&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<%
String gCds = "", gPac = "";
boolean oCds = false, oPac = false;
int nOrden =0;
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdod = (CommonDataObject) al.get(i);

	String color = "",color2="";
	if (i%2 == 0) {color = "TextRow02";color2 = "TextRow01";}
	else {color = "TextRow01";color2 = "TextRow02";}
%>
<%//=fb.hidden("cod_paciente"+i,cdod.getColValue("cod_paciente"))%>
<%//=fb.hidden("fecha_nacimiento"+i,cdod.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("pac_id"+i,cdod.getColValue("pac_id"))%>
<%=fb.hidden("secuenciaCorte"+i,cdod.getColValue("secuenciaCorte"))%>
<%=fb.hidden("codigo"+i,cdod.getColValue("codigo"))%>
<%=fb.hidden("orden"+i,cdod.getColValue("noOrden"))%>
<%=fb.hidden("tipo_orden"+i,cdod.getColValue("tipo_orden"))%>
<%=fb.hidden("estado_orden"+i,cdod.getColValue("estado_orden"))%>
<%=fb.hidden("cod_tratamiento"+i,cdod.getColValue("cod_tratamiento"))%>
<%=fb.hidden("pendiente"+i,cdod.getColValue("pendiente"))%>

<% if (!gCds.equals(cdod.getColValue("centro_servicio"))) { %>
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
<tr class="TextPanel01" onClick="javascript:showHide('CDS<%=i%>')" style="text-decoration:none; cursor:pointer">
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr>
			<td width="5%" align="center" class="Text14">[<font face="Courier New, Courier, mono"><label id="plusCDS<%=i%>" style="display:<%=cdsExpanded?"none":""%>">+</label><label id="minusCDS<%=i%>" style="display:<%=cdsExpanded?"":"none"%>">-</label></font>]</td>
			<td class="Text14"><%=cdod.getColValue("cds_desc")%> [ <label><%=htCds.get(cdod.getColValue("centro_servicio"))%></label> ]</td>
		</tr>
		</table>
	</td>
</tr>
<tr id="panelCDS<%=i%>" style="display:<%=cdsExpanded?"":"none"%>" class="TextPanel01">
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<% oCds = true; } %>

<%
	if (!gPac.equals(cdod.getColValue("pac_id") + "-" + cdod.getColValue("codigo_orden_med"))) {
		String neIcon = "../images/blank.gif";
		String neIconDesc = "";
		if (!cdod.getColValue("despachado").equals("N")) neIcon = "../images/check.gif";
		else { neIcon = "../images/flag_red.gif"; nOrden ++; }
%>
<% if (oPac) { %>
				</table>
			</td>
		</tr>
<% oPac = false; } %>
		<tr>
			<td>
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel02" onClick="javascript:showHide('<%=i%>')" style="text-decoration:none; cursor:pointer">
					<td width="5%" align="center">&nbsp;<%=cdod.getColValue("pac_id")%></td>
					<td width="28%">&nbsp;<input type="button" onClick="javascript:printOrdenList(<%=cdod.getColValue("pac_id")%>, <%=cdod.getColValue("secuenciaCorte")%>)" class="CellbyteBtn" value="<%=cdod.getColValue("nombre_paciente")%>" title="Órdenes médicas por admisión"></td>
					<td width="10%" align="center"><%=cdod.getColValue("identificacion")%></td>
					<td width="10%" align="center"><%=cdod.getColValue("fecha_nacimiento")%></td>
					<td width="5%" align="center"><%=cdod.getColValue("edad")%></td>
					<td width="5%" align="center"><%=cdod.getColValue("sexo")%></td>
					<td width="5%" align="center">&nbsp;<%=cdod.getColValue("dsp_admision")%><%=(!cdod.getColValue("dsp_admision").equals(cdod.getColValue("admCorte")))?" - ["+cdod.getColValue("admCorte")+" ] ":""%></td>
					<td width="8%" align="center"><%=cdod.getColValue("fecha_ingreso")%></td>
					<td width="10%" align="center"><%=cdod.getColValue("cama")%></td>
					<td width="3%" align="center"><img src="<%=neIcon%>" alt="<%=neIconDesc%>" height="20" width="20"></td>
					<td width="3%" align="center"><%=cdod.getColValue("codigo_orden_med")%></td>
					<td width="8%" align="center"> 
					<%if (Integer.parseInt(cdod.getColValue("ordSalida")) > 0) { %>
					
					<a href="javascript:ordSalida(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("dsp_admision")%>,<%=cdod.getColValue("codigo_orden_med")%>)";class="hint hint--top"><img src="../images/salida_de_pacientes.png" class="ImageBorder" alt="<%=cdod.getColValue("ordSalida")%>" height="20" width="20" border="0"></a>
					
					<%}%>
					
					
						<% if (Integer.parseInt(cdod.getColValue("ord_pen")) > 0) { %><a href="javascript:despachar(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("dsp_admision")%>,<%=cdod.getColValue("codigo_orden_med")%>,'<%=cdod.getColValue("id_articulo")%>',<%=cdod.getColValue("categoria_adm")%>)" class="Link03"><cellbytelabel>Aprobar</cellbytelabel></a><% } %>
						<% //if (cdod.getColValue("tipoOrd").equals("NU")) { %>
						<a href="javascript:imprimirOrden(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("dsp_admision")%>,<%=cdod.getColValue("codigo_orden_med")%>)"><img src="../images/printer.gif" alt="<%=neIconDesc%>" height="20" width="20" border="0"></a>
						<!--<% if (UserDet.getUserProfile().contains("0")) { %><a href="javascript:showDespachado(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("dsp_admision")%>,<%=cdod.getColValue("noOrden")%>,<%=cdod.getColValue("categoria_adm")%>,<%=cdod.getColValue("codigo_orden_med")%>)" class="Link04Bold">Despachados</a><% } %>-->
						<% //} %> 
						<% if (estado.equals("P") && cdoInsumos.getColValue("far_usar_insumos").equals("S") && fg.equals("")) { %><a href="javascript:insumos(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("dsp_admision")%>,<%=cdod.getColValue("codigo_orden_med")%>,<%=cdod.getColValue("noOrden")%>)" class="Link03"><cellbytelabel>Insumos</cellbytelabel></a><% } %>
					</td>
				</tr>
				<tr class="TextPanel02">
					<td align="left"><cellbytelabel>Empresa</cellbytelabel>:</td>
					<td colspan="9">&nbsp;<%=cdod.getColValue("empresa")%></td>
					<td colspan="2"><label id="label<%=cdod.getColValue("pac_id")%>" style="cursor:pointer; visibility:hidden;" class="alert1" onClick="javascript:getList('<%=cdod.getColValue("pac_id")%>','<%=cdod.getColValue("secuenciaCorte")%>','<%=cdod.getColValue("cod_med")%>')"><img src="../images/alert_img.gif" alt="Alertas Medicamentos" id="blink_img<%=cdod.getColValue("pac_id")%>" name="blink_img<%=cdod.getColValue("pac_id")%>" style="background-image:none;"></label>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel<%=i%>">
			<td>
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextHeader01">
					<td width="5%"><cellbytelabel>Estado</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Hora Solicitud</cellbytelabel></td>
					<td width="53%" colspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="16%"><cellbytelabel>Fecha Inicio</cellbytelabel></td>
					<td width="16%"><cellbytelabel>Fecha Omitida</cellbytelabel></td>
				</tr>
<% oPac = true; } %>

				<tr class="<%=color%>">
					<td width="5%"><%=cdod.getColValue("dsp_estado")%></td>
					<td width="10%"><%=cdod.getColValue("hora_solicitud")%></td>
					<td width="53%" colspan="2"><% if (cdod.getColValue("id_articulo") != null && !cdod.getColValue("id_articulo").trim().equals("") && !cdod.getColValue("esBm").trim().equals("0")) { %><span class="RedTextBold"><font size="2"><%=cdod.getColValue("nombre")%></font></span><% } else { %><%=cdod.getColValue("nombre")%><% } %>
					 
					  <%if(cdod.getColValue("stat")!=null && cdod.getColValue("stat").equalsIgnoreCase("Y")){%>&nbsp;&nbsp;&nbsp;<span class="RedTextBold">STAT</span><%}%>
					</td>
					<td width="16%"><%=cdod.getColValue("fecha_inicio")%></td>
					<td width="16%"><%=cdod.getColValue("fecha_omitida")%></td>
				</tr>
				<% if (fg.trim().equals("ME") || fg.trim().equals("BM")) { %>	
				<tr class="<%=color%>">
					<td colspan="3"><cellbytelabel>Presentaci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("descVia")%>&nbsp;&nbsp;&nbsp;<cellbytelabel>Concentraci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("dosis")%> 
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Frecuencia</cellbytelabel>:&nbsp;<%=cdod.getColValue("frecuencia")%></td>
					<td colspan="<%=expVersion.equals("3")?"2":"3"%>"><% if (cdoInsumos.getColValue("addCantidad").trim().equals("S")) { %><font class="RedTextBold" size="2">Cantidad Solicitada:<%=cdod.getColValue("cant")%> </font>&nbsp;&nbsp;&nbsp;<% } %> <cellbytelabel>Observaci&oacute;n</cellbytelabel>:<%=cdod.getColValue("observacion")%></td>
					<% if (expVersion.equals("3")) { %><td>Dosis:<%=cdod.getColValue("dosis_desc")%></td><% } %>
				</tr>
				<% } %>
<%
	gPac = cdod.getColValue("pac_id")+"-"+cdod.getColValue("codigo_orden_med");
	gCds = cdod.getColValue("centro_servicio");
}//for loop
%>
<% if (al.size() > 0) { %>
				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
<% } %>

<%=fb.hidden("nOrden",""+nOrden)%>
<%=fb.hidden("size",""+al.size())%>
<tr class="TextRow02">
	<td class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel>Solicitud(es)</cellbytelabel></td>
</tr>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
		}else	dom.setCdsRecibido("N");
		dom.setEstadoOrden("C");//Para confirmar que se recibio la solicitud de las ordenes.
		dom.setPacId(request.getParameter("pac_id"+i));
		dom.setSecuencia(request.getParameter("secuenciaCorte"+i));
		dom.setTipoOrden(request.getParameter("tipo_orden"+i));
		dom.setOrdenMed(request.getParameter("orden"+i));
		dom.setCodigo(request.getParameter("codigo"+i));

		al.add(dom);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	OMMgr.saveDetails(al);
	ConMgr.clearAppCtx(null);
	
	

	//om.setCompania((String) session.getAttribute("_companyId"));
	//om.setUsuarioCreacion((String) session.getAttribute("_userName"));

	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
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