<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.DetalleBilletes"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iPago" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iBill" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="TPMgr" scope="page" class="issi.caja.TransaccionPagoMgr"/>
<%
/**
================================================================================
tipoCliente: P=PACIENTE, E=EMPRESA, O=OTROS, A=ALQUILER
fg: D=DISTRIBUIR
fg: AJ=AJUSTE AUTOMATICO
fg: ARC = aplicar recibos desde cobros
fg: CSR = consulta de recibos
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
TPMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alRefType = new ArrayList();
ArrayList alCaja = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
int lastLineNo = 0;
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String fp = request.getParameter("fp");
String refId = request.getParameter("refId");
String tipo_clte_pm = request.getParameter("tipo_clte_pm");
String cjaTipoRec = java.util.ResourceBundle.getBundle("issi").getString("cjaTipoRec");
if (cjaTipoRec == null || cjaTipoRec.trim().equals("")) cjaTipoRec = "M";
int iconHeight = 20;
int iconWidth = 20;
String msg ="";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (fg == null) fg = "";
if (fp == null) fp = "";
if (codigo == null) codigo = "0";
if (compania == null) compania = (String) session.getAttribute("_companyId");
if (anio == null) anio = cDateTime.substring(6,10);
if (refId == null) refId = "";
if (tipo_clte_pm == null) tipo_clte_pm = "";
if (tipoCliente == null) throw new Exception("El Tipo de Cliente no est� definido. Por favor consulte con su Administrador!");
else if (tipoCliente.equalsIgnoreCase("A")) sbFilter.append(" and instr(refer,'O',1) > 0 and refer_to = 'ALQ'");
else
{
	sbFilter.append(" and instr(refer,'");
	sbFilter.append(tipoCliente);
	sbFilter.append("',1) > 0");
	if (tipoCliente.equalsIgnoreCase("O")) {
		if (!viewMode)sbFilter.append(" and activo_inactivo = 'A'");
		if(fp.equals("PM")){ sbFilter.append(" and to_char(codigo) = (select get_sec_comp_param(");
		sbFilter.append((String) session.getAttribute("_companyId"));
		sbFilter.append(", 'TIPO_CLTE_PLAN_MEDICO') from dual)");
		} else {
			sbFilter.append(" and to_char(codigo) != nvl((select get_sec_comp_param(");
			sbFilter.append((String) session.getAttribute("_companyId"));
			sbFilter.append(", 'TIPO_CLTE_PLAN_MEDICO') from dual), '-')");
		}
	}
}

String usaPlanMedico = "N";
try { usaPlanMedico = java.util.ResourceBundle.getBundle("planmedico").getString("usaPlanMedico"); } catch (Exception ex) { }

if (request.getMethod().equalsIgnoreCase("GET"))
{System.out.println("sbFilter======================================================= ="+sbFilter);

	if (tipoCliente.trim().equals("E") || tipoCliente.trim().equals("P")) {
		alRefType = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = "+compania+sbFilter+" order by 2",CommonDataObject.class);
	    if (alRefType.size() == 0) throw new Exception("El Tipo de Referencia no estA definido. Por favor consulte con su Administrador!");
    
	}else{

	alRefType = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = "+compania+" order by 2",CommonDataObject.class);
	if (alRefType.size() == 0) throw new Exception("El Tipo de Referencia no estA definido. Por favor consulte con su Administrador!");
    }
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CJA_TP_AJ_REC'),'1') as ta_recibo, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CJA_TP_AJ_DEV_TARJETA'),'59') as ta_tarjeta,nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CJA_TURNO_X_USUARIO'),'S') as validaTurno,nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CJA_PROC_AJUSTE_AUT'),'1') as cja_proc_aj, to_char(sysdate+1, 'dd/mm/yyyy') sys_date, get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'TIPO_CLTE_PLAN_MEDICO') tipo_clte_pm from dual");
	CommonDataObject cdoTA = (CommonDataObject) SQLMgr.getData(sbSql.toString());
	String taRecibo = cdoTA.getColValue("ta_recibo");
	String taTarjeta = cdoTA.getColValue("ta_tarjeta");
	String cja_proc_aj = cdoTA.getColValue("cja_proc_aj");
	String sys_date = cdoTA.getColValue("sys_date");
	tipo_clte_pm = cdoTA.getColValue("tipo_clte_pm");

	//if(!fp.trim().equals("CSR") && !fp.trim().equals("ARC"))// aplicar recibos desde cobros --> ARC y consulta de recibos -- CSR
	//{

	sbSql =  new StringBuffer();
	sbSql.append("select trim(to_char(z.codigo,'009')) as optValueColumn, z.codigo||' - '||z.descripcion as optLabelColumn, trim(to_char(z.no_recibo + 1,'00000009')) as optTitleColumn from tbl_cja_cajas z where z.compania = ");
	sbSql.append(compania);
	if (viewMode || !fg.trim().equals("")) {}
	else if (UserDet.getUserProfile().contains("0")) sbSql.append(" and z.estado = 'A'");
	else {
		sbSql.append(" and z.codigo in (");
		sbSql.append((String) session.getAttribute("_codCaja"));//cajas matriculadas en el IP de la PC que el usuario est� conectado
		sbSql.append(") and z.ip = '");
		sbSql.append(request.getRemoteAddr());//muestre solo las que tengan registrado el IP
		sbSql.append("' and z.estado = 'A'");
		sbSql.append(" and exists (select null from tbl_cja_cajas_x_cajero y where compania_caja = z.compania and cod_caja = z.codigo and exists (select null from tbl_cja_cajera where usuario = '");
		sbSql.append(session.getAttribute("_userName"));
		sbSql.append("' and estado = 'A' and cod_cajera = y.cod_cajero))");// and tipo in ('S','A')
	}
	sbSql.append(" order by z.descripcion");
	System.out.println("S Q L   CAJA =\n"+sbSql);
	alCaja = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	if (alCaja.size() == 0) throw new Exception("Este equipo no est� definido como una Caja. Por favor consulte con su Administrador!");

	//}

	iBill.clear();
	if (codigo.trim().equals("0"))
	{
		cdo.addColValue("codigo",codigo);
		cdo.addColValue("compania",compania);
		cdo.addColValue("anio",anio);
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("refType",(alRefType.size() == 1)?((CommonDataObject) alRefType.get(0)).getOptValueColumn():"");
		cdo.addColValue("tipoCliente",tipoCliente);
		cdo.addColValue("tipoTrans","CR");
		cdo.addColValue("detallado",(tipoCliente.equalsIgnoreCase("P"))?"S":"N");
		if(cjaTipoRec.trim().equals("M")){
		cdo.addColValue("recNo","");
		cdo.addColValue("recibo","");}
		else{ cdo.addColValue("recNo","0");
		cdo.addColValue("recibo","0");}
		cdo.addColValue("aplicado","0");
		cdo.addColValue("ajustado","0");
		cdo.addColValue("porAplicar","0");

		if (!refId.trim().equals("")) {

			CommonDataObject clt = SQLMgr.getData(sbSql.toString());
			sbSql = new StringBuffer();
			if (tipoCliente.equalsIgnoreCase("P")) {

				sbSql.append("select pac_id as ref_id, nombre_paciente as nombre, to_char(fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, codigo, estatus as status, apartado_postal cod_referencia from vw_adm_paciente where pac_id = ");
				sbSql.append(refId);
				clt = SQLMgr.getData(sbSql.toString());
				if (clt == null) clt = new CommonDataObject();
				if (clt != null && !clt.getColValue("status").equalsIgnoreCase("A")) throw new Exception("No se permite realizar Recibo a Pacientes inactivos!");

				cdo.addColValue("pacId",clt.getColValue("ref_id"));
				cdo.addColValue("fechaNacimiento",clt.getColValue("fecha_nacimiento"));
				cdo.addColValue("codigoPaciente",clt.getColValue("codigo"));
				cdo.addColValue("cod_referencia",clt.getColValue("cod_referencia"));

			} else if (tipoCliente.equalsIgnoreCase("E")) {

				sbSql.append("select codigo as ref_id, nombre, estado as status from tbl_adm_empresa where codigo = ");
				sbSql.append(refId);
				clt = SQLMgr.getData(sbSql.toString());
				if (clt == null) clt = new CommonDataObject();
				if (clt != null && !clt.getColValue("status").equalsIgnoreCase("A")) throw new Exception("No se permite realizar Recibo a Empresas inactivas!");

				cdo.addColValue("codigoEmpresa",clt.getColValue("ref_id"));

			}
			cdo.addColValue("refId",clt.getColValue("ref_id"));
			cdo.addColValue("nombre",clt.getColValue("nombre"));
			cdo.addColValue("nombreAdicional",clt.getColValue("nombre"));

		}
	}
	else
	{
		sbSql = new StringBuffer();
		sbSql.append("select a.pago_total as pagoTotal, a.descripcion, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.tipo_cliente as tipoCliente, a.codigo, a.anio, a.recibo, a.xtra1,  trim(to_char(a.caja,'009'))caja, nvl(a.nombre,' ') as nombre, (select pp.apartado_postal from tbl_adm_paciente pp where pp.pac_id =a.pac_id and rownum =1) cod_referencia, a.pac_id as pacId, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente,  a.nombre_adicional as nombreAdicional, a.codigo_empresa as codigoEmpresa, a.turno, a.ref_type as refType, a.ref_id as refId, a.tipo_trans as tipoTrans, a.detallado, a.hna_capitation as hnaCapitation, a.adelanto, a.tipo_cliente_otros as tipoClienteOtros, a.empresa_otros as empresaOtros, a.medico_otros as medicoOtros, a.provincia_emp as provinciaEmp, a.sigla_emp as siglaEmp, a.tomo_emp as tomoEmp, a.asiento_emp as asientoEmp, a.compania_emp as companiaEmp, a.emp_id as empId, a.particular_otros as particularOtros, nvl(a.cliente_alq,'N') as clienteAlq, a.num_contrato as numContrato, nvl(a.tmp_desc_alquiler,0) as tmpDescAlquiler");
		sbSql.append(", (select nvl(sum(monto),0) from tbl_cja_detalle_pago where compania = a.compania and tran_anio = a.anio and codigo_transaccion = a.codigo) as aplicado");
		sbSql.append(", (select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) ajuste from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D')) as ajustado");
		sbSql.append(", 0 as porAplicar, a.rec_status, a.comentario_anula,nvl(a.tipo_rec,'M')tipoRec,to_char(a.fecha_anulacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_anulacion,a.usuario_anulacion from tbl_cja_transaccion_pago a where a.codigo = ");
		sbSql.append(codigo);
		sbSql.append(" and a.compania = ");
		sbSql.append(compania);
		sbSql.append(" and a.anio = ");
		sbSql.append(anio);
		cdo = SQLMgr.getData(sbSql.toString());
		double total = Double.parseDouble(cdo.getColValue("pagoTotal"));
		double aplicado = Double.parseDouble(cdo.getColValue("aplicado"));
		double ajustado = Double.parseDouble(cdo.getColValue("ajustado"));
		double porAplicar = Math.round((total - aplicado + ajustado) * 100);

		if (cdo.getColValue("rec_status")!= null && !cdo.getColValue("rec_status").trim().equals("")&& cdo.getColValue("rec_status").trim().equals("I"))viewMode=true;

		if (fg.equalsIgnoreCase("A") && porAplicar <= 0){ mode = "view";viewMode=true;msg="El Recibo # ["+cdo.getColValue("recibo")+"] no tiene monto para aplicar!"; /*if(!fp.trim().equals("CSR") && !fp.trim().equals("ARC")){*//*throw new Exception("El Recibo #"+cdo.getColValue("recibo")+" no tiene monto para aplicar!");*/}//else{ mode = "view";viewMode=true; }}

		double tmp = Math.round((total - aplicado + ajustado) * 100);
		porAplicar = tmp / 100;
		cdo.addColValue("porAplicar",""+porAplicar);

		sbSql = new StringBuffer();
		sbSql.append("select denominacion, serie from tbl_cja_billetes where cia = ");
		sbSql.append(compania);
		sbSql.append(" and num_transac = ");
		sbSql.append(codigo);
		System.out.println("S Q L =\n"+sbSql);
		al = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),DetalleBilletes.class);
		lastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			if (i < 10) key = "00"+i;
			else if (i < 100) key = "0"+i;
			else key = ""+i;
			iBill.put(key,al.get(i - 1));
		}
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Registro de Pagos - "+document.title;
function checkCode(obj){if(obj.value!=''){if(hasDBData('<%=request.getContextPath()%>','tbl_cja_transaccion_pago','recibo = \''+obj.value+'\' and compania = <%=compania%>')){CBMSG.warning('El N�mero de Recibo ya existe!');obj.value='';return false;}}return true;}
function doAction(){<% if(mode.equalsIgnoreCase("add")) { %>showWarning();setCajaDetail();<% }else{%>
<% if (fg.equalsIgnoreCase("A")) {if(!msg.trim().equals("")){%>
 CBMSG.warning('<%=msg%>');<%}}%>
<%}%>}
function setTurno(caja){if(caja==undefined||caja==null||caja.trim()=='')caja=document.form0.caja.value;var turno=getDBData('<%=request.getContextPath()%>','a.cod_turno','tbl_cja_turnos_x_cajas a, tbl_cja_cajas b','a.compania = b.compania and a.cod_caja = b.codigo and a.compania = <%=compania%> and a.cod_caja = '+caja+' and a.estatus = \'A\'<%=(UserDet.getUserProfile().contains("0"))?"":" and b.ip = \\\'"+request.getRemoteAddr()+"\\\'"%> <%=(cdoTA.getColValue("validaTurno").trim().equals("S"))?" and a.cod_turno in (select codigo from tbl_cja_turnos where cja_cajera_cod_cajera in (select cod_cajera from tbl_cja_cajera where usuario = \\\'"+(String) session.getAttribute("_userName")+"\\\'))":""%>');if(turno==undefined||turno==null||turno.trim()==''){document.form0.turno.value='';CBMSG.warning('Usted o la Caja seleccionada no tiene un turno definido!');form0BlockButtons(true);window.frames['detalle'].formDetalleBlockButtons(true);return false;}else{document.form0.turno.value=turno;form0BlockButtons(false);window.frames['detalle'].formDetalleBlockButtons(false);}return true;}
function setCajaDetail(){var caja=document.form0.caja.value;setTurno(caja);}
function getClient(){var referTo=getSelectedOptionTitle(document.form0.refType,document.form0.refType.value);if('<%=tipoCliente%>'=='A'||isValidRefType()){abrir_ventana('../common/search_cliente.jsp?fp=recibos&fg=<%=fg%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>&referTo='+referTo+"&fecha=<%=cdo.getColValue("fecha")%>");}}
function clearClient(){if(isValidRefType()||document.form0.refType.value==''){setFormFieldsBlank('form0','refId,nombre,nombreAdicional,pacId,fechaNacimiento,codigoPaciente,codigoEmpresa');}}
function isValidRefType(){if(window.frames['detalle'].document.formDetalle.keySize&&window.frames['detalle'].document.formDetalle.keySize.value=='0'){if(document.form0.refType.value==''){CBMSG.warning('Por favor seleccione el Tipo de Referencia!');return false;}return true;}else{CBMSG.warning('S�lo se permite cambiar el Tipo Referencia o Cliente cuando no tiene detalles!');return false;}}
function printRec(){var tipoRec = document.form0.tipoRec.value;if(tipoRec=='A')abrir_ventana1('../caja/print_recibo_pago.jsp?fp=recibos&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>');else abrir_ventana1('../caja/print_recibo_pago.jsp?fp=recibos&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>');}
function printRecAuto(){
var tipoRec = document.form0.tipoRec.value;
var printed = getDBData('<%=request.getContextPath()%>',"nvl(rec_impreso,'N')",'tbl_cja_transaccion_pago',"codigo = <%=codigo%> and compania = <%=compania%> and anio = <%=anio%>");

if (printed == "N"){
	CBMSG.alert("Se�or usuario, una vez cierre este documento las pr�ximas impresiones saldr�n como COPIA.",{cb:function(r){
		 if (r=="Ok") __printRecibo(tipoRec);
	}});
}else __printRecibo(tipoRec,"P")
	function __printRecibo(tipo,status){
		if(tipo=='A')abrir_ventana1('../caja/print_recibo_pagoAuto.jsp?fp=recibos&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>&showColor='+(status||""));else abrir_ventana1('../caja/print_recibo_pagoAuto.jsp?fp=recibos&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>&showColor='+(status||""));
	}
}

function doSave(){if(document.form0.refType.value==''){CBMSG.warning('Por favor seleccione el Tipo de Referencia!');return false;}if(document.form0.pagoTotal.value==0){CBMSG.warning('Recibo con Monto Incorrecto!');return false;}if(form0Validation()){
if(window.frames['detalle'].isValid()){if(window.frames['formaPago'].isValid('Guardar'))window.frames['formaPago'].document.formFP.submit();else form0BlockButtons(false);}}return true;}
function checkRefId(){if(document.form0.refId.value.trim()!='')document.form0.nombre.blur();}
function ajusteAutomatico1(){var tipo_aj=document.form0.ta_recibo.value;var porAplicar = parseFloat(document.form0.porAplicar.value);var total = parseFloat(document.form0.pagoTotal.value);var pac_id = document.form0.pacId.value;var dob = document.form0.fechaNacimiento.value;var codPac = document.form0.codigoPaciente.value;var recibo = document.form0.recibo.value;var v_user = '<%=(String) session.getAttribute("_userName")%>';var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';var anio = document.form0.anio.value;var codigo = document.form0.codigo.value;if(total >= porAplicar && porAplicar > 0){
var aj =getDBData('<%=request.getContextPath()%>','count(*)','vw_con_adjustment_gral z,tbl_fac_tipo_ajuste y ',' z.factura is null and z.tipo_doc = \'R\' and z.recibo =\''+recibo+'\' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in (\'H\',\'D\') and z.tipo_ajuste in (select column_value  from table( select split((select get_sec_comp_param(z.compania,\'CJA_TP_AJ_REC\') from dual),\',\') from dual  ))');
var v_msg ='';
if(parseInt(aj) > 0)v_msg ='.  Ya existen ajustes para este recibo. Cantidad: '+aj;
if(confirm('�Est� seguro que desea Crear ajuste Automatico'+v_msg+' ??')){if(executeDB('<%=request.getContextPath()%>','call sp_cja_ajuste_automatico(<%=compania%>,'+anio+','+codigo+','+porAplicar+','+tipo_aj+',\''+v_user+ '\',\'N\',\''+pac_id+'\',\''+codPac+'\',\''+dob+ '\',\''+recibo+'\',\'C\')','')){var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg !='')CBMSG.warning(msg);else CBMSG.warning('Proceso Ejecutado');var nAjuste = getDBData('<%=request.getContextPath()%>','max(codigo)','tbl_fac_nota_ajuste','compania=<%=compania%> and recibo=\''+recibo+'\'','');if(confirm('�Desea Imprimir El Ajuste ??')){abrir_ventana2('../facturacion/print_nota_ajuste.jsp?codigo='+nAjuste+'&compania=<%=compania%>');}if(confirm('�Se necesita Confeccionar nota de ajuste Dev. de Tarjeta??')){var nTarjeta = getDBData('<%=request.getContextPath()%>','count(fp.fp_codigo)','tbl_cja_transaccion_pago tp,tbl_cja_trans_forma_pagos fp','tp.codigo ='+codigo+' and tp.compania=<%=compania%> and tp.anio ='+anio+' and tp.rec_status <> \'I\' and tp.codigo = fp.tran_codigo and tp.compania = fp.compania and tp.anio = fp.tran_anio and fp.fp_codigo = 3','');if(nTarjeta > 0){if(confirm('�Est� seguro de que se  debe hacer ajuste Dev. de Tarjeta para este recibo??')){if(executeDB('<%=request.getContextPath()%>','call sp_cja_ajuste_automatico(<%=compania%>,'+anio+','+codigo+','+porAplicar+',<%=taTarjeta%>,\''+v_user+ '\',\'S\',\''+pac_id+'\',\''+codPac+'\',\''+dob+ '\',\''+recibo+'\',\'D\')','')){var msg2 = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg2 !='')CBMSG.warning(msg2);else  CBMSG.warning('Proceso Ejecutado');var nAjuste2 = getDBData('<%=request.getContextPath()%>','max(codigo)','tbl_fac_nota_ajuste','compania=<%=compania%> and recibo=\''+recibo+'\'','');if(confirm('�Desea Imprimir El Ajuste ??')){abrir_ventana2('../facturacion/print_nota_ajuste.jsp?codigo='+nAjuste2+'&compania=<%=compania%>');}}else{var msg2 = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg2 !='')CBMSG.warning(msg2);else CBMSG.warning('Error en  el Proceso de Creacion de Ajuste'); }}else CBMSG.warning('Proceso cancelado');}else CBMSG.warning('El Recibo no fue pagado Con tarjeta de Credito');}else CBMSG.warning('Proceso cancelado');window.location.reload(true);} else{var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg !='')CBMSG.warning(msg);else CBMSG.warning('Error en  el Proceso de Creacion de Ajuste');}}else CBMSG.warning('Proceso cancelado');} else CBMSG.warning('Recibo no tiene Saldo Para Ajustar....');}
function ajusteAutomatico(){var tipo_aj=document.form0.ta_recibo.value;var porAplicar = parseFloat(document.form0.porAplicar.value);var total = parseFloat(document.form0.pagoTotal.value);var pac_id = document.form0.pacId.value;var dob = document.form0.fechaNacimiento.value;var codPac = document.form0.codigoPaciente.value;var recibo = document.form0.recibo.value;var v_user = '<%=(String) session.getAttribute("_userName")%>';var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';var anio = document.form0.anio.value;var codigo = document.form0.codigo.value;if(total >= porAplicar && porAplicar > 0){
var aj =getDBData('<%=request.getContextPath()%>','count(*)','vw_con_adjustment_gral z,tbl_fac_tipo_ajuste y ',' z.factura is null and z.tipo_doc = \'R\' and z.recibo =\''+recibo+'\' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in (\'H\',\'D\') /*and z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,\'CJA_TP_AJ_REC\') from dual),\',\') from dual  ))*/');
var v_msg ='';
if(parseInt(aj) > 0)v_msg ='.  Ya existen ajustes para este recibo. Cantidad: '+aj+' Revise primero.!!!!';
if(confirm('�Est� seguro que desea Crear ajuste Automatico'+v_msg+' ??')){if(executeDB('<%=request.getContextPath()%>','call sp_cja_ajuste_automatico(<%=compania%>,'+anio+','+codigo+','+porAplicar+','+tipo_aj+',\''+v_user+ '\',\'N\',\''+pac_id+'\',\''+codPac+'\',\''+dob+ '\',\''+recibo+'\',\'D\')','')){var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg !='')CBMSG.warning(msg);else CBMSG.warning('Proceso Ejecutado');var nAjuste = getDBData('<%=request.getContextPath()%>','max(codigo)','tbl_fac_nota_ajuste','compania=<%=compania%> and recibo=\''+recibo+'\'','');if(confirm('�Desea Imprimir El Ajuste ??')){abrir_ventana2('../facturacion/print_nota_ajuste.jsp?codigo='+nAjuste+'&compania=<%=compania%>');}/*if(confirm('�Se necesita Confeccionar nota de ajuste Dev. de Tarjeta??')){var nTarjeta = getDBData('<%=request.getContextPath()%>','count(fp.fp_codigo)','tbl_cja_transaccion_pago tp,tbl_cja_trans_forma_pagos fp','tp.codigo ='+codigo+' and tp.compania=<%=compania%> and tp.anio ='+anio+' and tp.rec_status <> \'I\' and tp.codigo = fp.tran_codigo and tp.compania = fp.compania and tp.anio = fp.tran_anio and fp.fp_codigo = 3','');if(nTarjeta > 0){if(confirm('�Est� seguro de que se  debe hacer ajuste Dev. de Tarjeta para este recibo??')){if(executeDB('<%=request.getContextPath()%>','call sp_cja_ajuste_automatico(<%=compania%>,'+anio+','+codigo+','+porAplicar+',<%=taTarjeta%>,\''+v_user+ '\',\'S\',\''+pac_id+'\',\''+codPac+'\',\''+dob+ '\',\''+recibo+'\',\'D\')','')){var msg2 = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg2 !='')CBMSG.warning(msg2);else  CBMSG.warning('Proceso Ejecutado');var nAjuste2 = getDBData('<%=request.getContextPath()%>','max(codigo)','tbl_fac_nota_ajuste','compania=<%=compania%> and recibo=\''+recibo+'\'','');if(confirm('�Desea Imprimir El Ajuste ??')){abrir_ventana2('../facturacion/print_nota_ajuste.jsp?codigo='+nAjuste2+'&compania=<%=compania%>');}}else{var msg2 = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg2 !='')CBMSG.warning(msg2);else CBMSG.warning('Error en  el Proceso de Creacion de Ajuste'); }}else CBMSG.warning('Proceso cancelado');}else CBMSG.warning('El Recibo no fue pagado Con tarjeta de Credito');}else CBMSG.warning('Proceso cancelado');*/  closeChild=false; window.location.reload(true);} else{var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);if(msg !='')CBMSG.warning(msg);else CBMSG.warning('Error en  el Proceso de Creacion de Ajuste');}}else CBMSG.warning('Proceso cancelado');} else CBMSG.warning('Recibo no tiene Saldo Para Ajustar....');}
function liberarAplicacion(tran_anio, codigo_transaccion, secuencia_pago,factura){
showPopWin('../common/run_process.jsp?fp=aplicar_recibo&actType=51&docType=DIST&docId='+codigo_transaccion+'&docNo='+secuencia_pago+'&anio='+tran_anio+'&factura='+factura+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.20,null,null,'')
}

function chkDate(){
	var x = getDBData('<%=request.getContextPath()%>', 'get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>, \'EDIT_FECHA_RECIBO\')','dual','');
	if(x!='S'){
		CBMSG.warning('No puede modificar la fecha de recibo!');
		document.form0.fecha.value = '<%=cdo.getColValue("fecha")%>';
	}
}
function showWarning(){var msg=getDBData('<%=request.getContextPath()%>','get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,\'CJA_PRINT_REC_WARN\')','dual','');if(msg==undefined||msg==null||msg.trim()==''){}else{displayElementValue('cja_print_rec_warn',msg);}}
function openCashdrawer(){showPopWin('../common/execute_fiscal_cmds.jsp?f_command=0',winWidth*.55,winHeight*.30,null,null,'');}
function getSaldoClte(){
<% if (!tipoCliente.equalsIgnoreCase("E") && usaPlanMedico.equalsIgnoreCase("S")) { %>
	var ref_type = document.form0.refType.value;
	var ref_id = document.form0.refId.value;
	var fecha = '<%=sys_date%>';
	var saldo = getDBData('<%=request.getContextPath()%>','trim(to_char(getsaldoinicialec(<%=(String) session.getAttribute("_companyId")%>, '+ref_type+',  \''+ref_id+'\',  \''+fecha+'\'), \'999999999.99\'))', 'dual');
	document.form0.saldo_clte.value = saldo;
<% } %>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javacript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - PAGOS"/>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("recNo",cdo.getColValue("recNo"))%>
<%=fb.hidden("tipoTrans",cdo.getColValue("tipoTrans"))%>
<%=fb.hidden("detallado",cdo.getColValue("detallado"))%>
<%=fb.hidden("doDistribution","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipoRec",cdo.getColValue("tipoRec"))%>
<%=fb.hidden("remplazo","")%>
<%=fb.hidden("distAut","")%>

		<tr class="TextRow02">
			<td colspan="8" align="right">
				&nbsp;<label id='optDesc'></label>
				<% if (mode.equalsIgnoreCase("add")) { %>
				&nbsp;Caj&oacute;n: <authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/icons/_cashregister48.png" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','ABRIR!!')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:openCashdrawer()"></authtype>
				<% } else { %>
				&nbsp;Ticket de Caja: <authtype type='2'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/print_bills.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','IMPRIMIR!!')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:printRecAuto()"></authtype>
				&nbsp;Recibo: <authtype type='2'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','IMPRIMIR!!')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:printRec()"></authtype>
				<% } %>
			</td>
		</tr>
		<tr class="TextRow01">
			<td width="8%">Caja</td>
			<td width="42%" colspan="3"><%=fb.select("caja",alCaja,cdo.getColValue("caja"),false,(viewMode || !fg.trim().equals("")),0,"Text10",null,"onChange=\"javascript:setCajaDetail();\"",null,viewMode?" ":null)%></td>
			<td width="8%">Recibo</td>
			<td width="17%"><%=fb.textBox("recibo",cdo.getColValue("recibo"),true,false,(cjaTipoRec.trim().equals("A"))?true:false,20,12,"Text10",null,(cjaTipoRec.trim().equals("A"))?"":"onBlur=\"javascript:checkCode(this)\"")%></td>
			<td width="8%">C&oacute;digo</td>
			<td width="17%"><%=fb.intBox("codigo",codigo,false,false,true,15,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Tipo Referencia</td>
			<td colspan="3">
			<% if ((viewMode || !fg.trim().equals(""))) { %>
				<%=fb.hidden("refType",cdo.getColValue("refType"))%>
				<%=fb.select("refTypeDisplay",alRefType,cdo.getColValue("refType"),false,(viewMode || !fg.trim().equals("")),0,"Text10",null,null,null,"S")%>
			<% } else { %>
				<%=fb.select("refType",alRefType,cdo.getColValue("refType"),false,(viewMode || !fg.trim().equals("")),0,"Text10",null,"onChange=\"javascript:clearClient();\" onFocus=\"javascript:if(this.value!=''){if(!isValidRefType())this.blur();}\"",null,(alRefType.size()>1)?"S":"")%>
			<% } %>
			</td>
			<td>Fecha</td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
				<jsp:param name="jsEvent" value="chkDate();" />
				<jsp:param name="onChange" value="chkDate();" />
			</jsp:include>
			<%//=fb.textBox("fecha",cdo.getColValue("fecha"),false,false,true,15,"Text10",null,null)%>
			</td>
			<td>Turno</td>
			<td><%=fb.intBox("turno",cdo.getColValue("turno"),false,false,true,15,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Cliente</td>
			<td colspan="3">
				<%=fb.hidden("pacId",cdo.getColValue("pacId"))%>
				<%=fb.hidden("fechaNacimiento",cdo.getColValue("fechaNacimiento"))%>
				<%=fb.hidden("codigoPaciente",cdo.getColValue("codigoPaciente"))%>

				<%=fb.hidden("codigoEmpresa",cdo.getColValue("codigoEmpresa"))%>

				<%=fb.hidden("tipoClienteOtros",cdo.getColValue("tipoClienteOtros"))%>
				<%=fb.hidden("empresaOtros",cdo.getColValue("empresaOtros"))%>
				<%=fb.hidden("medicoOtros",cdo.getColValue("medicoOtros"))%>
				<%=fb.hidden("provinciaEmp",cdo.getColValue("provinciaEmp"))%>
				<%=fb.hidden("siglaEmp",cdo.getColValue("siglaEmp"))%>
				<%=fb.hidden("tomoEmp",cdo.getColValue("tomoEmp"))%>
				<%=fb.hidden("asientoEmp",cdo.getColValue("asientoEmp"))%>
				<%=fb.hidden("companiaEmp",cdo.getColValue("companiaEmp"))%>
				<%=fb.hidden("empId",cdo.getColValue("empId"))%>
				<%=fb.hidden("particularOtros",cdo.getColValue("particularOtros"))%>
				<%=fb.hidden("clienteAlq",cdo.getColValue("clienteAlq"))%>
				<%=fb.hidden("numContrato",cdo.getColValue("numContrato"))%>

				<%=fb.textBox("refId",cdo.getColValue("refId"),(tipoCliente.equalsIgnoreCase("P") || tipoCliente.equalsIgnoreCase("E")),false,true,10,"Text10","",(tipoCliente.equalsIgnoreCase("P") || tipoCliente.equalsIgnoreCase("E"))?"":"onDblClick=\"javascript:clearClient();\"")%>
				<%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,true,tipoCliente.equalsIgnoreCase("P")?40:55,"Text10","","")%>

				<%=fb.button("btnCliente","...",true,(viewMode || !fg.trim().equals("")),"Text10",null,"onClick=\"javascript:getClient()\"")%>

				<%if(tipoCliente.equalsIgnoreCase("P")){%>
					 &nbsp;&nbsp;&nbsp;<strong>C&oacute;d. Ref.:&nbsp;</strong><%=fb.textBox("codReferencia",cdo.getColValue("cod_referencia"),false,false,true,20,"Text10","","")%>
				<%}%>

			</td>
			<td>Nombre Adicional</td>
			<td colspan="2"><%=fb.textBox("nombreAdicional",cdo.getColValue("nombreAdicional"),false,false,(viewMode || !fg.trim().equals("")),50,200,"Text10",null,null)%></td>
			<td class="Text12Bold"><% if (!tipoCliente.equalsIgnoreCase("E") && usaPlanMedico.equalsIgnoreCase("S")) { %>Saldo Clte.:
			<%//=fb.decBox("saldo_clte","",false,false,true,15,12.2,"Text10","","")%>
			<%=fb.textBox("saldo_clte","",false,false,true,20,100,"Text10",null,null)%><% } %>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>Concepto</td>
			<td colspan="3"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,(viewMode || !fg.trim().equals("")),50,100,"Text10",null,null)%></td>
			<td>Rec.Manual#</td>
			<td><%=fb.intBox("xtra1",cdo.getColValue("xtra1"),false,false,(viewMode || !fg.trim().equals("")),20,20,"Text10",null,null)%></td>
<% if (tipoCliente.equalsIgnoreCase("A")) { %>
			<td colspan="2">&nbsp;</td>
<% } else { %>
			<td colspan="2">
				<!--<%=fb.checkbox("hnaCapitation","S",(cdo.getColValue("hnaCapitation") != null && cdo.getColValue("hnaCapitation").equalsIgnoreCase("S")),(viewMode || !fg.trim().equals("")),null,null,"")%><label for="hnaCapitation">Capitation</label>-->
				<%=fb.checkbox("adelanto","S",(cdo.getColValue("adelanto") != null && cdo.getColValue("adelanto").equalsIgnoreCase("S")),(viewMode || !fg.trim().equals("")||!tipoCliente.equalsIgnoreCase("O")),null,null,"")%><label for="adelanto">Devolucion de pagos por Adelanto? </label>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>Cantidad</td>
			<td width="17%"><%=fb.decBox("pagoTotal",cdo.getColValue("pagoTotal"),true,true,false,15,10.2,"Text10","","")%></td>
			<td width="8%">Aplicado</td>
			<td width="17%">
				<%=fb.hidden("aplicado",cdo.getColValue("aplicado"))%>
				<%=fb.decBox("aplicadoDisplay",cdo.getColValue("aplicado"),false,false,true,15,12.2,"Text10","","")%>
			</td>
			<td>Ajustado</td>
			<td><%=fb.decBox("ajustado",cdo.getColValue("ajustado"),false,false,true,15,10.2,"Text10","","")%></td>
			<td>Por Aplicar</td>
			<td><%=fb.decBox("porAplicar",cdo.getColValue("porAplicar"),false,false,true,15,12.2,"Text10","","")%></td>
<% } %>
		</tr>
<% if (tipoCliente.equalsIgnoreCase("A")){%>
	<tr class="TextRow01">
			<td>Cantidad</td>
			<td colspan="3"><%=fb.decBox("pagoTotal",cdo.getColValue("pagoTotal"),false,false,true,15,10.2,"Text10","","")%></td>
			<td colspan="2" align="right">Desc. Pronto Pago</td>
			<td colspan="2"><%=fb.decBox("tmpDescAlquiler",cdo.getColValue("tmpDescAlquiler"),false,false,true,15,12.2,"Text10","","")%></td>
	</tr>
<%}%>

<% if (cdo.getColValue("rec_status") != null && cdo.getColValue("rec_status").equalsIgnoreCase("I")) { %>
		<tr class="TextRow01">
			<td>Raz&oacute;n de Anulaci&oacute;n</td>
			<td colspan="5"><%=fb.textarea("comments",cdo.getColValue("comentario_anula"),false,false,true,80,5,null,"","")%></td>
			<td colspan="2">Fecha Anulacion: <%=cdo.getColValue("fecha_anulacion")%><br>Usuario Anulacion: <%=cdo.getColValue("usuario_anulacion")%>
			</td>
		</tr>
<% } %>
<% if (tipoCliente.equalsIgnoreCase("P") && mode.trim().equals("view") && fg.trim().equals("AJ")) { %>
		<tr class="TextRow01">
			<td></td>
			<td colspan="6" align="right">
				Tipo de Ajuste
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion ||' - ' || codigo as descripcion from tbl_fac_tipo_ajuste where compania = "+(String) session.getAttribute("_companyId")+" and codigo <> '"+taTarjeta+"'  and codigo "+(((cja_proc_aj.trim().equals("1")))?" not ":" ")+" in (select column_value  from table( select split((select get_sec_comp_param(compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) and estatus = 'A' and tipo_doc = 'R' and group_type in ('H','D') order by descripcion","ta_recibo",taRecibo,true,false,false,0,null,null,"")%>
				&nbsp;
				<%=((cja_proc_aj.trim().equals("1"))?fb.button("nota","Ajuste Automatico",false,((fg.equalsIgnoreCase("AJ") && Double.parseDouble(cdo.getColValue("porAplicar")) == 0.00)),null,null,"onClick=\"javascript:ajusteAutomatico()\""):fb.button("nota","Ajuste Automatico",false,((fg.equalsIgnoreCase("AJ") && Double.parseDouble(cdo.getColValue("porAplicar")) == 0.00)),null,null,"onClick=\"javascript:ajusteAutomatico1()\""))%>
			</td>
			<td>&nbsp;</td>
		</tr>
		<%}%>
		<tr class="TextRow02">
			<td colspan="8"><iframe name="formaPago" id="formaPago" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../caja/reg_recibo_formapago.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&compania=<%=compania%>&anio=<%=anio%>&codigo=<%=codigo%>"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8"><iframe name="detalle" id="detalle" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../caja/reg_recibo_det.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=<%=mode%>&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>"></iframe></td>
		</tr>

		<tr  class="TextRow02">
			<td colspan="8">&nbsp;</td>
		</tr>

		<tr class="TextRow02">
			<td colspan="8" align="right">
				<label id='cja_print_rec_warn' class="RedTextBold"></label>
				<%=fb.button("save","Guardar",true,(viewMode || fg.trim().equals("D")),null,null,"onClick=\"javascript:doSave();\"","Guardar")%>
				<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
	String doDistribution = request.getParameter("doDistribution");
	String distAut = request.getParameter("distAut");
	if (mode.equalsIgnoreCase("add")) fg = "D";
	else if (fg.equalsIgnoreCase("A"))
	{
		if (doDistribution.equalsIgnoreCase("S")) fg = "D";
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<% if (errCode.equals("1")) { %>
	alert('<%=errMsg%>');

	<%if (mode.equalsIgnoreCase("add")&&!tipoCliente.trim().equals("O")&&distAut.trim().equals("N")){%> /*alert('Recuerde distribuir el pago del recibo.')*/<%}%>
<% if (mode.equalsIgnoreCase("add") || mode.equalsIgnoreCase("edit")) {
		if(fp.equalsIgnoreCase("factura")){%>
		window.location='../caja/reg_recibo.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>';
	<%} else {%>
	window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tipoCliente=<%=tipoCliente%>&codigo=<%=codigo%>&compania=<%=compania%>&anio=<%=anio%>';
	<%}

	if(fp.equalsIgnoreCase("factura")){} else {%>
	<%if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/list_recibo.jsp"))
			{%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/list_recibo.jsp")%>';
	<%
			}else{
	%>
	window.opener.location='<%=request.getContextPath()%>/caja/list_recibo.jsp?tipoCliente=<%=tipoCliente%>&fp=<%=fp%>';
	<%
			}
			}%>


<% } else { %>
	window.close();
<% } %>
<% } else throw new Exception(errMsg); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>