<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.facturacion.Factura"%>
<%@ page import="issi.facturacion.FacDetTran"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="FacMgr" scope="page" class="issi.facturacion.FacturaMgr"/>
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
FacMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
ArrayList al = new ArrayList();
ArrayList alTotal = new ArrayList();

String key = "";
StringBuffer sbSql = new StringBuffer();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String esJubilado = request.getParameter("esJubilado");
String cdsDet = "N";
try { cdsDet = java.util.ResourceBundle.getBundle("issi").getString("cdsDet"); } catch(Exception e) { cdsDet = "N"; }
String paquete = "S";//Default que aplique paquete
try { paquete = java.util.ResourceBundle.getBundle("issi").getString("paquete"); } catch(Exception e) { paquete = "S"; }
String deducible = "N";//Default que no muestre deducible
try { deducible = java.util.ResourceBundle.getBundle("issi").getString("deducible"); } catch(Exception e) { deducible = "N"; }

if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (esJubilado == null) esJubilado = "N";

boolean viewMode = false;
String mode = request.getParameter("mode");
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")) {

	if (pacId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	if (mode.equalsIgnoreCase("add")) {//for new analysis or not reloading previous one

		sbSql.append("call sp_fac_cargos_fac_det_tran (?,?,?,?,?)");
		param.setSql(sbSql.toString());
		param.addInNumberStmtParam(1,pacId);
		param.addInNumberStmtParam(2,noAdmision);
		param.addInStringStmtParam(3,esJubilado);
		param.addInNumberStmtParam(4,(String) session.getAttribute("_companyId"));
		param.addInStringStmtParam(5,cdsDet);

	} else if (request.getParameter("limit") != null) {//for applying limit

		sbSql.append("call sp_fac_analizar_cta_manual_lim (?,?,?,?)");
		param.setSql(sbSql.toString());
		param.addInNumberStmtParam(1,pacId);
		param.addInNumberStmtParam(2,noAdmision);
		param.addInStringStmtParam(3,esJubilado);
		param.addInNumberStmtParam(4,(String) session.getAttribute("_companyId"));

	} else if (!viewMode) {//for reloading previous analysis

		sbSql.append("call sp_fac_analizar_cta_reload_lim (?,?,?,?)");
		param.setSql(sbSql.toString());
		param.addInNumberStmtParam(1,pacId);
		param.addInNumberStmtParam(2,noAdmision);
		param.addInNumberStmtParam(3,(String) session.getAttribute("_companyId"));
		param.addInStringStmtParam(4,"");

	}

	if (sbSql.length() > 0) {

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&esJubilado="+esJubilado+"&cdsDet="+cdsDet+"&paquete="+paquete+"&limit="+request.getParameter("limit"));
		param = SQLMgr.executeCallable(param);
		ConMgr.clearAppCtx(null);
		if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());

	}

	sbSql = new StringBuffer();
	sbSql.append("select z.cod_reg as paq, z.precio_paq, (select nombre from tbl_fac_cotizacion where id = z.cod_reg) as nombre_paq from tbl_adm_clasif_x_plan_conv z where paquete = 'S' and exists (select null from tbl_adm_beneficios_x_admision where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and prioridad = 1 and estado = 'A' and empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi) and exists (select b.centro_servicio, b.tipo_cargo, a.med_codigo, a.empre_codigo/*, b.descripcion*/, b.monto, b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia || '-' || b.art_clase || '-' || b.inv_articulo, sum(decode(b.tipo_transaccion,'D',-(b.cantidad - nvl(b.difpaq_cantidad,0)),(b.cantidad - nvl(b.difpaq_cantidad,0)))) as cantidad from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admi_secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" and b.ref_type = 'PAQ' and b.ref_id = z.cod_reg and a.compania = b.compania and a.codigo = b.fac_codigo and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.tipo_transaccion = b.tipo_transaccion group by b.centro_servicio, b.tipo_cargo, a.med_codigo, a.empre_codigo/*, b.descripcion*/, b.monto, b.procedimiento, b.habitacion, b.cds_producto, b.cod_uso, b.otros_cargos, b.cod_paq_x_cds, b.art_familia || '-' || b.art_clase || '-' || b.inv_articulo having sum(decode(b.tipo_transaccion,'D',-(b.cantidad - nvl(b.difpaq_cantidad,0)),(b.cantidad - nvl(b.difpaq_cantidad,0)))) > 0)");
	CommonDataObject pCdo = SQLMgr.getData(sbSql.toString());
	if (pCdo == null) pCdo = new CommonDataObject();
	boolean hasPaq = !pCdo.getColValue("paq","-1").equals("-1");

	/*
	inserted on procedure sp_fac_analizar_init_acum0: monto_copago (tbl_adm_clasif_x_plan_conv.monto_paciente), tipo_val_copago (tbl_adm_clasif_x_plan_conv.tipo_val_pac), aplica_copago (tbl_adm_plan_convenio.aplica_co), aplica_desc (tbl_adm_plan_convenio.aplica_desc)
	updated from user selection after saving:	benef_copago
	*/
	sbSql = new StringBuffer();
	sbSql.append("select monto_copago, nvl(tipo_val_copago,'P') as tipo_val_copago, nvl(benef_copago,'P') as benef_copago, nvl(aplica_copago,'E') as aplica_copago, nvl(aplica_desc,'F') as aplica_desc, nvl(editable,'A') as editable, nvl(dsp_copago,nvl(monto_copago,0) - nvl(dsp_deducible,0) - nvl(dsp_coaseguro,0)) as dsp_copago, nvl(dsp_deducible,0) as dsp_deducible, nvl(dsp_coaseguro,0) as dsp_coaseguro from tbl_adm_beneficios_acum where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	CommonDataObject acum = SQLMgr.getData(sbSql.toString());
	if (acum == null) acum = new CommonDataObject();

	boolean editable = !acum.getColValue("editable").equalsIgnoreCase("C");
	if (!editable && session.getAttribute("__facAnalysisComment") != null && !((String) session.getAttribute("__facAnalysisComment")).trim().equals("")) {
		acum.addColValue("comentario",(String) session.getAttribute("__facAnalysisComment"));
		editable = true;
		session.removeAttribute("__facAnalysisComment");
	}

	sbSql = new StringBuffer();
	sbSql.append("select (SELECT DECODE(tipo_cds,'I',decode(a.centro_servicio,0,4,1),'E',2,3) FROM TBL_CDS_CENTRO_SERVICIO WHERE codigo = a.centro_servicio) AS cds_priority,(select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as descCentro, (select descripcion from tbl_cds_tipo_servicio where codigo = a.tipo_cargo) as descServicio, a.compania, a.secuencia, a.fac_codigo, a.fac_secuencia as noAdmision, a.pac_id as pacId, a.tipo_transaccion, a.centro_servicio, a.cantidad, a.sec_precio, a.monto, coalesce(a.med_codigo,''||a.empre_codigo,a.procedimiento,''||a.otros_cargos,''||a.cds_producto,a.habitacion,''||a.cod_uso,a.art_familia||'-'||a.art_clase||'-'||a.inv_articulo) as producto, a.descripcion, a.tipo_cargo, nvl(a.no_cubierto,'S') as noCubierto, a.monto_clinica, a.monto_paciente, a.monto_empresa, a.tipo_val_cli, a.tipo_val_pac, a.tipo_val_emp, nvl(a.aplica_monto_desc,'N') as aplica_monto_desc, nvl(a.aplica_monto_cli,'N') as aplica_monto_cli, a.monto_descuento, a.tipo_val_desc, b.n_active_benef_prior1, case when a.ref_type is null and a.ref_id is null then 'CARGOS' else a.ref_type||a.ref_id end as paq from tbl_fac_det_tran a, (select count(*) as n_active_benef_prior1 from tbl_adm_beneficios_x_admision where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and prioridad = 1 and estado = 'A') b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.fac_secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" order by a.ref_type, a.ref_id, 1 asc, a.centro_servicio, a.tipo_cargo");
	al = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select 'A' as type, 'CS'||case when a.ref_type is null and a.ref_id is null then 'CARGOS' else a.ref_type||a.ref_id end||'-'||to_char(a.centro_servicio) as key, to_char(a.centro_servicio) as codigo, sum(a.monto) as monto from tbl_fac_det_tran a where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.fac_secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" group by a.ref_type, a.ref_id, a.centro_servicio union all select 'B', 'TS'||case when a.ref_type is null and a.ref_id is null then 'CARGOS' else a.ref_type||a.ref_id end||'-'||to_char(a.centro_servicio)||'-'||a.tipo_cargo, to_char(a.centro_servicio)||'-'||a.tipo_cargo, sum(a.monto) as monto from tbl_fac_det_tran a where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.fac_secuencia = ");
	sbSql.append(noAdmision);
	sbSql.append(" group by a.ref_type, a.ref_id, a.centro_servicio, a.tipo_cargo order by 1");
	alTotal = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title='Análisis Manual - '+document.title;
function loadTotal(){setTotal();<% if(mode.equalsIgnoreCase("add")) { %><% } %>for(i=0;i<<%=al.size()%>;i++){isGnc('cs_',i);isGnc('ts_',i);isGnc('',i);}}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();loadTotal();<% if (request.getParameter("paquete") != null) { %>doLimit();<% } %>}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function checkTotal(k,value,fg)
{
var total=0;
var mCli=0;
var mPac=0;
var mEmp=0;
if(fg=='CS')
{
	if(!isNaN(eval('document.form0.val_cli'+k).value)&&eval('document.form0.val_cli'+k).value!='')
	mCli=parseFloat(eval('document.form0.val_cli'+k).value);
	if(!isNaN(eval('document.form0.val_pac'+k).value)&&eval('document.form0.val_pac'+k).value!='')
	mPac=parseFloat(eval('document.form0.val_pac'+k).value);
	if(!isNaN(eval('document.form0.val_emp'+k).value)&&eval('document.form0.val_emp'+k).value!='')
	mEmp=parseFloat(eval('document.form0.val_emp'+k).value);
	total=mClim+Pac+mEmp;
	CBMSG.warning('total=='+total);
	if(total!= 100)CBMSG.warning('Los valores introducidos no Coinciden con el 100 por ciento. Verifique!');
}
}
function setTotal()
{
<% for(int i=0; i<alTotal.size(); i++)
{
CommonDataObject cdox = (CommonDataObject) alTotal.get(i); %>
document.getElementById("<%=cdox.getColValue("key")%>").innerHTML='<%=CmnMgr.getFormattedDecimal(cdox.getColValue("monto"))%>';
document.getElementById("<%=cdox.getColValue("key")%>").className='RedTextBold';
<%}%>

}
/*
function isGnc(prefix,k)
{
	if(eval('document.form0.'+prefix+'chk'+k))
	{
		var disableObj=eval('document.form0.'+prefix+'chk'+k).checked;
		var disableSubObj=false;
		//if(eval('document.form0.'+prefix+'aplica_monto_desc'+k)){eval('document.form0.'+prefix+'aplica_monto_desc'+k).disabled=disableObj;if(!disableObj&&eval('document.form0.'+prefix+'aplica_monto_desc'+k).value=='N')disableSubObj=true;}
		//if(eval('document.form0.'+prefix+'monto_desc'+k))eval('document.form0.'+prefix+'monto_desc'+k).readOnly=disableObj||disableSubObj;
		if(eval('document.form0.'+prefix+'tipo_val_desc'+k))eval('document.form0.'+prefix+'tipo_val_desc'+k).disabled=disableObj||disableSubObj;
		if(eval('document.form0.'+prefix+'monto_pac'+k))eval('document.form0.'+prefix+'monto_pac'+k).readOnly=disableObj;
		if(eval('document.form0.'+prefix+'tipo_val_pac'+k))eval('document.form0.'+prefix+'tipo_val_pac'+k).disabled=disableObj;
		if(eval('document.form0.n_active_benef_prior1'+k)&&eval('document.form0.n_active_benef_prior1'+k).value==1)
		{
			disableSubObj=false;
			if(eval('document.form0.'+prefix+'aplica_monto_cli'+k)){eval('document.form0.'+prefix+'aplica_monto_cli'+k).disabled=disableObj;if(!disableObj&&eval('document.form0.'+prefix+'aplica_monto_desc'+k).value=='N')disableSubObj=true;}
			if(eval('document.form0.'+prefix+'monto_cli'+k))eval('document.form0.'+prefix+'monto_cli'+k).readOnly=disableObj||disableSubObj;
			if(eval('document.form0.'+prefix+'tipo_val_cli'+k))eval('document.form0.'+prefix+'tipo_val_cli'+k).disabled=disableObj||disableSubObj;
			if(eval('document.form0.'+prefix+'monto_emp'+k))eval('document.form0.'+prefix+'monto_emp'+k).readOnly=disableObj;
			if(eval('document.form0.'+prefix+'tipo_val_emp'+k))eval('document.form0.'+prefix+'tipo_val_emp'+k).disabled=disableObj;
		}
	}
}
*/
function isGnc(prefix,k)
{
<% if (viewMode||!editable) { %>return true;<% } %>
	var chkObj=eval('document.form0.'+prefix+'chk'+k);
	if(chkObj)
	{
		var disableObj=(((chkObj||{}).type==='checkbox')&&chkObj.checked)||(!((chkObj||{}).type==='checkbox')&&chkObj.value=='S');
		//if(eval('document.form0.'+prefix+'aplica_monto_desc'+k)){eval('document.form0.'+prefix+'aplica_monto_desc'+k).disabled=disableObj;isApplied(prefix,'desc',k,disableObj);}
		//if(eval('document.form0.'+prefix+'monto_desc'+k)){eval('document.form0.'+prefix+'monto_desc'+k).readOnly=disableObj;eval('document.form0.'+prefix+'monto_desc'+k).className='Text10 '+((disableObj)?'FormDataObjectDisabled':'FormDataObjectEnabled');}
		//if(eval('document.form0.'+prefix+'tipo_val_desc'+k))eval('document.form0.'+prefix+'tipo_val_desc'+k).disabled=disableObj;
		if(eval('document.form0.'+prefix+'monto_pac'+k)){if(disableObj)eval('document.form0.'+prefix+'monto_pac'+k).value='100';eval('document.form0.'+prefix+'monto_pac'+k).readOnly=disableObj;eval('document.form0.'+prefix+'monto_pac'+k).className='Text10 '+((disableObj)?'FormDataObjectDisabled':'FormDataObjectEnabled');}
		if(eval('document.form0.'+prefix+'tipo_val_pac'+k)){if(disableObj)eval('document.form0.'+prefix+'tipo_val_pac'+k).value='P';eval('document.form0.'+prefix+'tipo_val_pac'+k).disabled=disableObj;}

		if(eval('document.form0.n_active_benef_prior1'+k)&&eval('document.form0.n_active_benef_prior1'+k).value==1)
		{
			//if(eval('document.form0.'+prefix+'aplica_monto_cli'+k)){eval('document.form0.'+prefix+'aplica_monto_cli'+k).disabled=disableObj;isApplied(prefix,'cli',k,disableObj);}
			if(eval('document.form0.'+prefix+'monto_cli'+k)){if(disableObj)eval('document.form0.'+prefix+'monto_cli'+k).value='0';eval('document.form0.'+prefix+'monto_cli'+k).readOnly=disableObj;eval('document.form0.'+prefix+'monto_cli'+k).className='Text10 '+((disableObj)?'FormDataObjectDisabled':'FormDataObjectEnabled');}
			if(eval('document.form0.'+prefix+'tipo_val_cli'+k)){if(disableObj)eval('document.form0.'+prefix+'tipo_val_cli'+k).value='P';eval('document.form0.'+prefix+'tipo_val_cli'+k).disabled=disableObj;}
			if(eval('document.form0.'+prefix+'monto_emp'+k)){if(disableObj)eval('document.form0.'+prefix+'monto_emp'+k).value='0';eval('document.form0.'+prefix+'monto_emp'+k).readOnly=disableObj;eval('document.form0.'+prefix+'monto_emp'+k).className='Text10 '+((disableObj)?'FormDataObjectDisabled':'FormDataObjectEnabled');}
			if(eval('document.form0.'+prefix+'tipo_val_emp'+k)){if(disableObj)eval('document.form0.'+prefix+'tipo_val_emp'+k).value='P';eval('document.form0.'+prefix+'tipo_val_emp'+k).disabled=disableObj;}
		}
	}
}
function isApplied(prefix,suffix,k,isDisabledApplyObj)
{
	var disableObj=(isDisabledApplyObj||eval('document.form0.'+prefix+'aplica_monto_'+suffix+k).value=='N');
	if(eval('document.form0.'+prefix+'monto_'+suffix+k)){eval('document.form0.'+prefix+'monto_'+suffix+k).readOnly=disableObj;eval('document.form0.'+prefix+'monto_'+suffix+k).className='Text10 '+((disableObj)?'FormDataObjectDisabled':'FormDataObjectEnabled');}
	if(eval('document.form0.'+prefix+'tipo_val_'+suffix+k))eval('document.form0.'+prefix+'tipo_val_'+suffix+k).disabled=disableObj;
}
function printAnalysis(){abrir_ventana2('../facturacion/print_cargo_dev_resumen2.jsp?pacId=<%=pacId%>&noSecuencia=<%=noAdmision%>');abrir_ventana2('../facturacion/print_pagos_x_admision.jsp?pacId=<%=pacId%>&noSecuencia=<%=noAdmision%>');}
function printAnalysis2(){abrir_ventana2('../facturacion/print_cargo_dev_resumen2.jsp?pacId=<%=pacId%>&noSecuencia=<%=noAdmision%>');}
function setBlank(type){if(type.trim()!=''){for(i=0;i<<%=al.size()%>;i++){if(eval('document.form0.monto_'+type+i))eval('document.form0.monto_'+type+i).value='';if(eval('document.form0.tipo_val_'+type+i))eval('document.form0.tipo_val_'+type+i).value='P';}}}
function setCheck(){for(i=0;i<<%=al.size()%>;i++)if(eval('document.form0.chk'+i)){eval('document.form0.chk'+i).checked=document.form0.chk.checked;isGnc('',i);}}
function setTipoVal(prefix,k,valor)
{
	/*if(eval('document.form0.n_active_benef_prior1'+k)&&eval('document.form0.n_active_benef_prior1'+k).value==1)
	{
		if(eval('document.form0.'+prefix+'tipo_val_cli'+k))eval('document.form0.'+prefix+'tipo_val_cli'+k).value=valor;
		if(eval('document.form0.'+prefix+'tipo_val_emp'+k))eval('document.form0.'+prefix+'tipo_val_emp'+k).value=valor;
		if(eval('document.form0.'+prefix+'tipo_val_desc'+k))eval('document.form0.'+prefix+'tipo_val_desc'+k).value=valor;
		if(eval('document.form0.'+prefix+'tipo_val_pac'+k))eval('document.form0.'+prefix+'tipo_val_pac'+k).value=valor;
	}*/
}
function doLimit(forcedMode){showPopWin('../facturacion/apply_limit.jsp?mode='+((forcedMode!=undefined&&forcedMode!=null&&forcedMode!='')?forcedMode:'<%=mode%>')+'&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&esJubilado=<%=esJubilado%>',winWidth*.85,winHeight*.80,null,null,'');}
function editReason(){showPopWin('../facturacion/edit_analisis.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&esJubilado=<%=esJubilado%>',winWidth*.85,winHeight*.80,null,null,'');}
function calcCopago(){
var deducible=document.form0.dsp_deducible.value||0;
var copago=document.form0.dsp_copago.value||0;
var coaseguro=document.form0.dsp_coaseguro.value||0;
var t=parseFloat(deducible)+parseFloat(copago)+parseFloat(coaseguro);
document.form0.monto_copago.value=t;
}
</script>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="FACTURACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRow02">
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%" align="center">&nbsp;<cellbytelabel id="1">Datos del Paciente</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel0">
			<td>
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="mode" value="<%=mode%>"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("tableSize","")%>
<%=fb.hidden("editable",acum.getColValue("editable"))%>
<%=fb.hidden("comentario",acum.getColValue("comentario"))%>
		<tr>
			<td>
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextHeader">
					<td colspan="3"><cellbytelabel id="2">PARAMETROS</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td width="40%">
						<cellbytelabel id="3">Aplicar Descuentos</cellbytelabel>
						<%=fb.select("aplicaMontoDesc","N=NO APLICA,I=ANTES DE DISTRIBUIR,F=DESPUES DE DISTRIBUIR",acum.getColValue("aplica_desc"),false,viewMode||!editable,0,"Text10","","","","")%>
					</td>
					<td width="40%">
						<% if (deducible.trim().equalsIgnoreCase("s")) { %>
						Deducible
						<%=fb.decBox("dsp_deducible",acum.getColValue("dsp_deducible"),false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
						COPAGO
						<%=fb.decBox("dsp_copago",acum.getColValue("dsp_copago"),false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
						Coaseguro
						<%=fb.decBox("dsp_coaseguro",acum.getColValue("dsp_coaseguro"),false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
						<%//=fb.button("bcalc","CALC.",false,false,null,null,"onClick=\"javascript:calcCopago()\"")%>
						<%=fb.hidden("monto_copago","")%>
						<%=fb.hidden("tipo_val_copago","M")%>
						<%fb.appendJsValidation("if(calcCopago()){}");%>
						<% } else { %>
						<%=fb.decBox("monto_copago",acum.getColValue("monto_copago"),false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
						<%=fb.select("tipo_val_copago","M=COPAGO",acum.getColValue("tipo_val_copago"),false,viewMode||!editable,0,"Text10","","")%><!--P=COASEGURO,-->
						<% } %>
						<cellbytelabel id="4">Beneficiar a</cellbytelabel>
						<%=fb.select("aplica_copago","E=EMPRESA,A=AMBOS",acum.getColValue("aplica_copago"),false,viewMode||!editable,0,"Text10","","","","")%>
						<%=fb.hidden("benef_copago",acum.getColValue("benef_copago"))%>
					</td>
					<td width="20%" align="right"><authtype type='50'><% if (!editable) { %>&nbsp;<%=fb.button("btnEditar","Editar",false,false,null,null,"onClick=\"javascript:editReason()\"")%><% } %></authtype>&nbsp;<%if(paquete.trim().equals("S")){%><%=viewMode||!editable||hasPaq?fb.button("applyLimit","Ver Paquete",false,false,null,null,"onClick=\"javascript:doLimit('view')\""):fb.submit("applyLimit","Paquete",false,!editable,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%><%}%></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%"><cellbytelabel id="5">Transacciones</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel1">
			<td class="TextRow01">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<%
int[] hCol = {44,7,5,11,11,11,11};
int[] dCol = {10,24,3,7};
%>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="<%=hCol[0]%>%" rowspan="2"><cellbytelabel id="6">Centro / Tipo Servicio</cellbytelabel></td>
					<td width="<%=hCol[1]%>%" rowspan="2"><cellbytelabel id="7">Monto Total</cellbytelabel></td>
					<td width="<%=hCol[2]%>%" rowspan="2"><%=fb.checkbox("chk","S",false,viewMode||!editable,null,null,"onClick=\"setCheck();\"")%><cellbytelabel id="8">No Cub.</cellbytelabel></td>
					<td colspan="2"><cellbytelabel id="9">P A C I E N T E</cellbytelabel></td>
					<td colspan="2"><cellbytelabel id="10">E M P R E S A</cellbytelabel></td>
				</tr>
				<tr class="TextHeader" align="center">
					<td width="<%=hCol[3]%>%"><a href="javascript:setBlank('<%=(editable)?"desc":""%>')" class="Link03"><cellbytelabel id="11">Descuento</cellbytelabel></a></td>
					<td width="<%=hCol[4]%>%"><a href="javascript:setBlank('<%=(editable)?"pac":""%>')" class="Link03"><cellbytelabel id="12">Pago</cellbytelabel></a></td>
					<td width="<%=hCol[5]%>%"><a href="javascript:setBlank('<%=(editable)?"cli":""%>')" class="Link03"><cellbytelabel id="11">Descuento</cellbytelabel></a></td>
					<td width="<%=hCol[6]%>%"><a href="javascript:setBlank('<%=(editable)?"emp":""%>')" class="Link03"><cellbytelabel id="12">Pago</cellbytelabel></a></td>
				</tr>
<%
String paq = "", cds = "", ts = "", centro = "", centroTipo = "";
double total = 0;
int x = 0;
boolean oPaq = false, oCds = false, oTs = false;
for (int i=0; i<al.size(); i++) {
	cdo = (CommonDataObject) al.get(i);
	String displayDetail = "none";
%>
<%=fb.hidden("secuencia"+i,""+cdo.getColValue("secuencia"))%>
<%=fb.hidden("paq"+i,cdo.getColValue("paq"))%>
<%=fb.hidden("centro_servicio"+i,""+cdo.getColValue("centro_servicio"))%>
<%=fb.hidden("tipo_cargo"+i,""+cdo.getColValue("tipo_cargo"))%>
<%=fb.hidden("n_active_benef_prior1"+i,cdo.getColValue("n_active_benef_prior1"))%>
<% if (!paq.equals(cdo.getColValue("paq"))) { %>
<% if (oPaq) { %>
<% if (oCds) { %>
<% if (oTs) { %>
										</table>
									</td>
								</tr>
<% ts = ""; oTs = false; } %>
								</table>
							</td>
						</tr>
<% cds = ""; oCds = false; } %>
						</table>
					</td>
				</tr>
<% paq = ""; oPaq = false; } %>
				<tr class="TextHeader02">
					<td colspan="7"><%=cdo.getColValue("paq")%><% if (("PAQ"+pCdo.getColValue("paq","-1")).equals(cdo.getColValue("paq"))) { %> :: <%=pCdo.getColValue("nombre_paq")%> --> <%=CmnMgr.getFormattedDecimal(pCdo.getColValue("precio_paq"))%><% } %></td>
				</tr>
				<tr>
					<td colspan="7" class="TableBorder">
						<table width="100%" cellpadding="1" cellspacing="1">
<% oPaq = true; } %>
<% if (!cds.equals(cdo.getColValue("centro_servicio"))) { %>
<% if (oCds) { %>
<% if (oTs) { %>
										</table>
									</td>
								</tr>
<% ts = ""; oTs = false; } %>
								</table>
							</td>
						</tr>
<% cds = ""; oCds = false; } %>
						<tr class="TextRow04">
							<td width="<%=hCol[0]%>%"><%=cdo.getColValue("descCentro")%></td>
							<td width="<%=hCol[1]%>%" align="right"><label id="CS<%=cdo.getColValue("paq")%>-<%=cdo.getColValue("centro_servicio")%>" onClick="javascript:showHide('CS<%=cdo.getColValue("paq")%>-<%=cdo.getColValue("centro_servicio")%>');showHide('TS<%=cdo.getColValue("paq")%>-<%=cdo.getColValue("centro_servicio")+"-"+cdo.getColValue("tipo_cargo")%>')" style="cursor:pointer"></label></td>
							<td width="<%=hCol[2]%>%" align="center"><%=fb.checkbox("cs_chk"+i,"S",false,viewMode||!editable,null,null,"onClick=\"isGnc('cs_',"+i+");\"")%></td>
							<td width="<%=hCol[3]%>%" align="center">
								<%//=fb.select("cs_aplica_monto_desc"+i,"N=NO APLICA,I=AL INICIO,F=AL FINAL","",false,viewMode||!editable,0,"Text10","","onChange=\"javascript:isApplied('cs_','desc',"+i+",false)\"","","")%>
								<%=fb.decBox("cs_monto_desc"+i,"",false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
								<%=fb.select("cs_tipo_val_desc"+i,"P=%,M=$","",false,viewMode||!editable,0,"Text10","","onChange=\"javascript:setTipoVal('cs_',"+i+",this.value)\"")%>
							</td>
							<td width="<%=hCol[4]%>%" align="center">
								<%=fb.decBox("cs_monto_pac"+i,"",false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
								<%=fb.select("cs_tipo_val_pac"+i,"P=%,M=$","",false,viewMode||!editable,0,"Text10","","onChange=\"javascript:setTipoVal('cs_',"+i+",this.value)\"")%>
							</td>
							<td width="<%=hCol[5]%>%" align="center">
								<%//=fb.select("cs_aplica_monto_cli"+i,"N=NO APLICA,I=AL INICIO,F=AL FINAL","",false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:isApplied('cs_','cli',"+i+",false)\"","","")%>
								<%=fb.decBox("cs_monto_cli"+i,"",false,false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),7,10.2,"Text10",null,null)%>
								<%=fb.select("cs_tipo_val_cli"+i,"P=%,M=$","",false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:setTipoVal('cs_',"+i+",this.value)\"")%>
							</td>
							<td width="<%=hCol[6]%>%" align="center">
								<%=fb.decBox("cs_monto_emp"+i,"",false,false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),7,10.2,"Text10",null,null)%>
								<%=fb.select("cs_tipo_val_emp"+i,"P=%,M=$","",false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:setTipoVal('cs_',"+i+",this.value)\"")%>
							</td>
						</tr>
						<tr id="panelCS<%=cdo.getColValue("paq")%>-<%=cdo.getColValue("centro_servicio")%>" style="display:<%=displayDetail%>">
							<td colspan="7" class="TableBorder">
								<table width="100%" cellpadding="1" cellspacing="1">
<% oCds = true; } %>
<% if (!ts.equals(cdo.getColValue("tipo_cargo"))) { %>
<% if (oTs) { %>
										</table>
									</td>
								</tr>
<% ts = ""; oTs = false; } %>
								<tr class="TextRow02">
									<td width="<%=hCol[0]%>%"><%=cdo.getColValue("descServicio")%></td>
									<td width="<%=hCol[1]%>%" align="right"><label id="TS<%=cdo.getColValue("paq")%>-<%=cdo.getColValue("centro_servicio")+"-"+cdo.getColValue("tipo_cargo")%>" onClick="javascript:showHide('TS<%=cdo.getColValue("paq")%>-<%=cdo.getColValue("centro_servicio")+"-"+cdo.getColValue("tipo_cargo")%>')" style="cursor:pointer"></label></td>
									<td width="<%=hCol[2]%>%" align="center"><%=fb.checkbox("ts_chk"+i,"S",false,viewMode||!editable,null,null,"onClick=\"isGnc('ts_',"+i+");\"")%></td>
									<td width="<%=hCol[3]%>%" align="center">
										<%//=fb.select("ts_aplica_monto_desc"+i,"N=NO APLICA,I=AL INICIO,F=AL FINAL","",false,viewMode||!editable,0,"Text10","","onChange=\"javascript:isApplied('ts_','desc',"+i+",false)\"","","")%>
										<%=fb.decBox("ts_monto_desc"+i,"",false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
										<%=fb.select("ts_tipo_val_desc"+i,"P=%,M=$","",false,viewMode||!editable,0,"Text10","","onChange=\"javascript:setTipoVal('ts_',"+i+",this.value)\"")%>
									</td>
									<td width="<%=hCol[4]%>%" align="center">
										<%=fb.decBox("ts_monto_pac"+i,"",false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
										<%=fb.select("ts_tipo_val_pac"+i,"P=%,M=$","",false,viewMode||!editable,0,"Text10","","onChange=\"javascript:setTipoVal('ts_',"+i+",this.value)\"")%>
									</td>
									<td width="<%=hCol[5]%>%" align="center">
										<%//=fb.select("ts_aplica_monto_cli"+i,"N=NO APLICA,I=AL INICIO,F=AL FINAL","",false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:isApplied('ts_','cli',"+i+",false)\"","","")%>
										<%=fb.decBox("ts_monto_cli"+i,"",false,false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),7,10.2,"Text10",null,null)%>
										<%=fb.select("ts_tipo_val_cli"+i,"P=%,M=$","",false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:setTipoVal('ts_',"+i+",this.value)\"")%>
									</td>
									<td width="<%=hCol[6]%>%" align="center">
										<%=fb.decBox("ts_monto_emp"+i,"",false,false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),7,10.2,"Text10",null,null)%>
										<%=fb.select("ts_tipo_val_emp"+i,"P=%,M=$","",false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:setTipoVal('ts_',"+i+",this.value)\"")%>
									</td>
								</tr>
								<tr id="panelTS<%=cdo.getColValue("paq")%>-<%=cdo.getColValue("centro_servicio")+"-"+cdo.getColValue("tipo_cargo")%>" style="display:<%=displayDetail%>">
									<td colspan="7" class="TableBorder">
										<table width="100%" cellpadding="1" cellspacing="1" class="TableBorder">
										<tr class="TextHeader01" align="center">
											<td width="<%=dCol[0]%>%"><cellbytelabel id="13">C&oacute;digo</cellbytelabel></td>
											<td width="<%=dCol[1]%>%"><cellbytelabel id="13">Descripci&oacute;n</cellbytelabel></td>
											<td width="<%=dCol[2]%>%"><cellbytelabel id="14">Cant.</cellbytelabel></td>
											<td width="<%=dCol[3]%>%"><cellbytelabel id="15">Monto</cellbytelabel></td>
											<td width="<%=hCol[1]%>%"><cellbytelabel id="16">Total</cellbytelabel></td>
											<td width="<%=hCol[2]%>%"><cellbytelabel id="17">No Cub.</cellbytelabel></td>
											<td width="<%=hCol[3]%>%"><cellbytelabel id="11">Descuento</cellbytelabel></td>
											<td width="<%=hCol[4]%>%"><cellbytelabel id="12">Pago</cellbytelabel></td>
											<td width="<%=hCol[5]%>%"><cellbytelabel id="11">Descuento</cellbytelabel></td>
											<td width="<%=hCol[6]%>%"><cellbytelabel id="12">Pago</cellbytelabel></td>
										</tr>
<% oTs = true; } %>
										<tr class="TextRow01">
											<td><%=cdo.getColValue("producto")%></td>
											<td><%=cdo.getColValue("descripcion")%></td>
											<td align="right"><%=cdo.getColValue("cantidad")%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("sec_precio"))%></td>
											<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
											<td align="center"><%=fb.checkbox("chk"+i,"S",(cdo.getColValue("noCubierto").trim().equals("S")),viewMode||!editable,null,null,"onClick=\"isGnc('',"+i+");\"")%></td>
											<td align="center">
												<%//=fb.select("aplica_monto_desc"+i,"N=NO APLICA,I=AL INICIO,F=AL FINAL",cdo.getColValue("aplica_monto_desc"),false,viewMode||!editable,0,"Text10","","onChange=\"javascript:isApplied('','desc',"+i+",false)\"","","")%>
												<%=fb.decBox("monto_desc"+i,cdo.getColValue("monto_descuento"),false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
												<%=fb.select("tipo_val_desc"+i,"P=%,M=$",cdo.getColValue("tipo_val_desc"),false,viewMode||!editable,0,"Text10","","onChange=\"javascript:setTipoVal('',"+i+",this.value)\"")%>
											</td>
											<td align="center">
												<%=fb.decBox("monto_pac"+i,cdo.getColValue("monto_paciente"),false,false,viewMode||!editable,7,10.2,"Text10",null,null)%>
												<%=fb.select("tipo_val_pac"+i,"P=%,M=$",cdo.getColValue("tipo_val_pac"),false,viewMode||!editable,0,"Text10","","onChange=\"javascript:setTipoVal('',"+i+",this.value)\"")%>
											</td>
											<td align="center">
												<%//=fb.select("aplica_monto_cli"+i,"N=NO APLICA,I=AL INICIO,F=AL FINAL",cdo.getColValue("aplica_monto_cli"),false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:isApplied('','cli',"+i+",false)\"","","")%>
												<%=fb.decBox("monto_cli"+i,cdo.getColValue("monto_clinica"),false,false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),7,10.2,"Text10",null,null)%>
												<%=fb.select("tipo_val_cli"+i,"P=%,M=$",cdo.getColValue("tipo_val_cli"),false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:setTipoVal('',"+i+",this.value)\"")%>
											</td>
											<td align="center">
												<%=fb.decBox("monto_emp"+i,cdo.getColValue("monto_empresa"),false,false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),7,10.2,"Text10",null,null)%>
												<%=fb.select("tipo_val_emp"+i,"P=%,M=$",cdo.getColValue("tipo_val_emp"),false,(viewMode||!editable || !cdo.getColValue("n_active_benef_prior1").equals("1")),0,"Text10","","onChange=\"javascript:setTipoVal('',"+i+",this.value)\"")%>
											</td>
										</tr>
<%
	total += Double.parseDouble(cdo.getColValue("monto"));

	paq = cdo.getColValue("paq");
	cds = cdo.getColValue("centro_servicio");
	ts = cdo.getColValue("tipo_cargo");
}//for
%>
<% if (al.size() > 0) { %>
										</table>
									</td>
								</tr>
								</table>
							</td>
						</tr>
						</table>
					</td>
				</tr>
<% } %>

				</table>
</div>
</div>
			</td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="2" align="right"><cellbytelabel id="16">Total</cellbytelabel>: <%=CmnMgr.getFormattedDecimal(""+total)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2" align="right">
				<label id="optDesc" class="TextInfo Text10">&nbsp;</label>
				&nbsp;
				<% if (!mode.equalsIgnoreCase("add")) { %><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Análisis')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:printAnalysis()"><% } %>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="31">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="32">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");
String cds = "";
String ts = "";

Factura fac = new Factura();
fac.setPacId(request.getParameter("pacId"));
fac.setAdmiSecuencia(request.getParameter("noAdmision"));
fac.setMontoCopago(request.getParameter("monto_copago"));
fac.setTipoValCopago(request.getParameter("tipo_val_copago"));
fac.setBenefCopago(request.getParameter("benef_copago"));
fac.setAplicaCopago(request.getParameter("aplica_copago"));
fac.setAplicaDesc(request.getParameter("aplicaMontoDesc"));
fac.setComentario(request.getParameter("comentario"));
fac.setDspCopago(request.getParameter("dsp_copago"));
fac.setDspDeducible(request.getParameter("dsp_deducible"));
fac.setDspCoaseguro(request.getParameter("dsp_coaseguro"));

int size = Integer.parseInt(request.getParameter("size"));
for (int i=0; i<size; i++)
{
	//detalle
	FacDetTran fdt = new FacDetTran();

	fdt.setPacId(request.getParameter("pacId"));
	fdt.setFacSecuencia(request.getParameter("noAdmision"));
	fdt.setSecuencia(request.getParameter("secuencia"+i));
	fdt.setCentroServicio(request.getParameter("centro_servicio"+i));
	fdt.setTipoCargo(request.getParameter("tipo_cargo"+i));
	if (request.getParameter("chk"+i) != null && request.getParameter("chk"+i).equalsIgnoreCase("S")&& request.getParameter("monto_pac"+i)!=null && !request.getParameter("monto_pac"+i).trim().equals("")&&!request.getParameter("monto_pac"+i).trim().equals("0")) fdt.setNoCubierto("S");
	else fdt.setNoCubierto("N");

	//fdt.setAplicaMontoDesc(request.getParameter("aplica_monto_desc"+i));
	fdt.setAplicaMontoDesc(request.getParameter("aplicaMontoDesc"));
	fdt.setMontoDescuento(request.getParameter("monto_desc"+i));
	fdt.setTipoValDesc(request.getParameter("tipo_val_desc"+i));

	fdt.setMontoPaciente(request.getParameter("monto_pac"+i));
	fdt.setTipoValPac(request.getParameter("tipo_val_pac"+i));

	//fdt.setAplicaMontoCli(request.getParameter("aplica_monto_cli"+i));
	fdt.setAplicaMontoCli(request.getParameter("aplicaMontoDesc"));
	fdt.setMontoClinica(request.getParameter("monto_cli"+i));
	fdt.setTipoValCli(request.getParameter("tipo_val_cli"+i));

	fdt.setMontoEmpresa(request.getParameter("monto_emp"+i));
	fdt.setTipoValEmp(request.getParameter("tipo_val_emp"+i));

	fac.addFdtItem(fdt);


	//tipo x centro
	if (!ts.trim().equals(request.getParameter("centro_servicio"+i)+"-"+request.getParameter("tipo_cargo"+i)))
	{
		fdt = new FacDetTran();

		fdt.setPacId(request.getParameter("pacId"));
		fdt.setFacSecuencia(request.getParameter("noAdmision"));
		fdt.setSecuencia(request.getParameter("secuencia"+i));
		fdt.setCentroServicio(request.getParameter("centro_servicio"+i));
		fdt.setTipoCargo(request.getParameter("tipo_cargo"+i));
		if (request.getParameter("ts_chk"+i) != null && request.getParameter("ts_chk"+i).equalsIgnoreCase("S")&& request.getParameter("ts_monto_pac"+i)!=null && !request.getParameter("ts_monto_pac"+i).trim().equals("")&&!request.getParameter("ts_monto_pac"+i).trim().equals("0")) fdt.setNoCubierto("S");
		else fdt.setNoCubierto("N");

		//fdt.setAplicaMontoDesc(request.getParameter("ts_aplica_monto_desc"+i));
		fdt.setAplicaMontoDesc(request.getParameter("aplicaMontoDesc"));
		fdt.setMontoDescuento(request.getParameter("ts_monto_desc"+i));
		fdt.setTipoValDesc(request.getParameter("ts_tipo_val_desc"+i));

		fdt.setMontoPaciente(request.getParameter("ts_monto_pac"+i));
		fdt.setTipoValPac(request.getParameter("ts_tipo_val_pac"+i));

		//fdt.setAplicaMontoCli(request.getParameter("ts_aplica_monto_cli"+i));
		fdt.setAplicaMontoCli(request.getParameter("aplicaMontoDesc"));
		fdt.setMontoClinica(request.getParameter("ts_monto_cli"+i));
		fdt.setTipoValCli(request.getParameter("ts_tipo_val_cli"+i));

		fdt.setMontoEmpresa(request.getParameter("ts_monto_emp"+i));
		fdt.setTipoValEmp(request.getParameter("ts_tipo_val_emp"+i));

		fac.addFdtItemTs(fdt);
	}

	//centro
	if (!cds.trim().equals(request.getParameter("centro_servicio"+i)))
	{
		fdt = new FacDetTran();

		fdt.setPacId(request.getParameter("pacId"));
		fdt.setFacSecuencia(request.getParameter("noAdmision"));
		fdt.setSecuencia(request.getParameter("secuencia"+i));
		fdt.setCentroServicio(request.getParameter("centro_servicio"+i));
		fdt.setTipoCargo(request.getParameter("tipo_cargo"+i));
		if (request.getParameter("cs_chk"+i) != null && request.getParameter("cs_chk"+i).equalsIgnoreCase("S") && request.getParameter("cs_monto_pac"+i)!=null && !request.getParameter("cs_monto_pac"+i).trim().equals("")&&!request.getParameter("cs_monto_pac"+i).trim().equals("0")) fdt.setNoCubierto("S");
		else fdt.setNoCubierto("N");

		//fdt.setAplicaMontoDesc(request.getParameter("cs_aplica_monto_desc"+i));
		fdt.setAplicaMontoDesc(request.getParameter("aplicaMontoDesc"));
		fdt.setMontoDescuento(request.getParameter("cs_monto_desc"+i));
		fdt.setTipoValDesc(request.getParameter("cs_tipo_val_desc"+i));

		fdt.setMontoPaciente(request.getParameter("cs_monto_pac"+i));
		fdt.setTipoValPac(request.getParameter("cs_tipo_val_pac"+i));

		//fdt.setAplicaMontoCli(request.getParameter("cs_aplica_monto_cli"+i));
		fdt.setAplicaMontoCli(request.getParameter("aplicaMontoDesc"));
		fdt.setMontoClinica(request.getParameter("cs_monto_cli"+i));
		fdt.setTipoValCli(request.getParameter("cs_tipo_val_cli"+i));

		fdt.setMontoEmpresa(request.getParameter("cs_monto_emp"+i));
		fdt.setTipoValEmp(request.getParameter("cs_tipo_val_emp"+i));

		fac.addFdtItemCs(fdt);
	}

	cds = request.getParameter("centro_servicio"+i);
	ts = request.getParameter("centro_servicio"+i)+"-"+request.getParameter("tipo_cargo"+i);
}

if (baction.equalsIgnoreCase("guardar") || baction.equalsIgnoreCase("paquete")) {
	if (baction.equalsIgnoreCase("paquete")) saveOption = "O";
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	FacMgr.factManual(fac);
	ConMgr.clearAppCtx(null);
}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (FacMgr.getErrCode().equals("1")) { %>
<% if (baction.equalsIgnoreCase("guardar")) { %>alert('<%=FacMgr.getErrMsg()%>');<% } %>
<% if (saveOption.equalsIgnoreCase("N")) { %>
setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
setTimeout('viewMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
window.close();
<% } %>
<% } else throw new Exception(FacMgr.getErrException()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=add&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>';}
function viewMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%><%=(baction.equalsIgnoreCase("paquete"))?"&paquete":""%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
