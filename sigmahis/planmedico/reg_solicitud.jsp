<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.planmedico.Solicitud"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="SOL" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SolMgr" scope="page" class="issi.planmedico.SolicitudMgr" />
<jsp:useBean id="Sol" scope="session" class="issi.planmedico.Solicitud" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htClt" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCltD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vClt" scope="session" class="java.util.Vector" />

<%
/**
==========================================================================================
FORMA SOL_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SolMgr.setConnection(ConMgr);
String tipo_cliente = java.util.ResourceBundle.getBundle("planmedico").getString("tipo_cliente");
if(tipo_cliente==null) throw new Exception("El Tipo de Cliente par PLAN MEDICO no ha sido definido!");
ArrayList al = new ArrayList();
ArrayList alAM = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String key = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String id_motivo = request.getParameter("id_motivo");
String anio = request.getParameter("anio");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;
String tab = request.getParameter("tab");
if (tab == null) tab = "0";
String tabFunctions = "'1=tabFunctions(1)'";
String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(anio == null) anio = CmnMgr.getCurrentDate("yyyy");
if(fg==null) fg = "";
if(id_motivo==null) id_motivo = "";
if(fp==null) fp = "plan_medico";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	SOL = new CommonDataObject();
	Sol = new Solicitud();
	sbSql = new StringBuffer();
	sbSql.append("select id, monto from tbl_pm_afiliado");
	alAM = SQLMgr.getDataList(sbSql.toString());
	String cuota = "";
	String parentescoHijo = "";
	String edadMaxHijo = "0";
	String primaPlanMedico = "";
	sbSql = new StringBuffer();
	sbSql.append("select get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CALC_CUOTA_PLAN_MED') cuota,get_sec_comp_param(-1, 'PORC_IMP_FACT_PLAN_MEDICO') PORC_IMP_FACT_PLAN_MEDICO, get_sec_comp_param(-1, 'COD_PARENTESCO_HIJO') COD_PARENTESCO_HIJO, nvl(get_sec_comp_param(-1, 'EDAD_MAX_PARENTESCO_HIJO'), 0) EDAD_MAX_HIJO from dual");
	CommonDataObject _cdP = SQLMgr.getData(sbSql.toString());

	if(_cdP==null) cuota = "SF";
	else {
		cuota = _cdP.getColValue("cuota");
		parentescoHijo = _cdP.getColValue("COD_PARENTESCO_HIJO");
		edadMaxHijo = _cdP.getColValue("EDAD_MAX_HIJO");
		primaPlanMedico = _cdP.getColValue("PORC_IMP_FACT_PLAN_MEDICO");
	}	

	sbSql = new StringBuffer();
	sbSql.append("select id, monto, cant_min, cant_max, parentesco from tbl_pm_afiliado where estado = 'A'");
	ArrayList alA = SQLMgr.getDataList(sbSql.toString());

	if (mode.equalsIgnoreCase("add")){

		id = "0";
		SOL.addColValue("fecha_ini_plan", "");
		SOL.addColValue("id", id);
		SOL.addColValue("estado", "P");
		SOL.addColValue("id_cliente", "0");
		SOL.addColValue("tipo_cliente", tipo_cliente);
		htClt.clear();
		vClt.clear();
		session.removeAttribute("Sol");
		System.out.println("..............................id="+id);
		if(fp.equals("adenda") && request.getParameter("id")!=null && !request.getParameter("id").equals("")){
			id = request.getParameter("id");
			/*
			encabezado
			*/
			sbSql = new StringBuffer();
			sbSql.append("select ");
			if(mode.equals("add")) sbSql.append("'P' as estado");
			else sbSql.append("a.estado ");
			sbSql.append(", a.id, a.id_cliente, a.cobertura_mi, a.cobertura_cy, a.cobertura_hi, a.cobertura_ot, ");
			if(id_motivo.equals("-1")) sbSql.append("decode(a.afiliados, 1, 2, 1)");
			else sbSql.append(" a.afiliados ");
			sbSql.append(" afiliados, a.forma_pago, to_char(a.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, a.cuota_mensual, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.observacion, lpad(id, 10, '0') id_pad, (select descripcion || ' [ B/ ' || to_char(monto, '999,999.99') || ']' from tbl_pm_afiliado where id = ");
			if(id_motivo.equals("-1")) sbSql.append("decode(a.afiliados, 1, 2, 1)");
			else sbSql.append(" a.afiliados ");
			sbSql.append(" and rownum =1 ) afiliados_desc, a.tipo_cliente, a.id_corredor, (select nombre from tbl_pm_corredor where id = a.id_corredor) nombre_corredor, tipo_plan from tbl_pm_solicitud_contrato a where a.id = ");
			sbSql.append(id);
			
			System.out.println("query...................."+sbSql.toString());
			SOL = SQLMgr.getData(sbSql.toString());
			if(id_motivo.equals("-1")) SOL.addColValue("id_motivo", "-1");
			else if(id_motivo.equals("0")) SOL.addColValue("id_motivo", "0");
			else if(id_motivo.equals("1")) SOL.addColValue("id_motivo", "1");
			else if(!id_motivo.equals("")) SOL.addColValue("id_motivo", id_motivo);
			

			sbSql = new StringBuffer();
			sbSql.append("select a.id_solicitud, a.id, a.id_cliente, a.parentesco, ");
			/*if(id_motivo.equals("-1")) sbSql.append("'I'");
			else 
			*/
			sbSql.append("a.estado");
			sbSql.append(" estado, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.observacion, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as identificacion, b.nombre_paciente as client_name, b.sexo, nvl (trunc (months_between (sysdate,coalesce (f_nac, fecha_nacimiento)-nvl((select to_number(get_sec_comp_param(-1, 'PARAM_DIAS_EDAD')) from dual), 0))/ 12),0) as edad, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.costo_mensual");
			sbSql.append(", nvl(a.medicamento, '') medicamento, nvl(a.diagnostico, '') diagnostico, a.no_contrato, to_char(a.fecha_inicio, 'dd/mm/yyyy') fecha_inicio");
			sbSql.append(", nvl(a.limite_anual, 0) limite_anual from tbl_pm_sol_contrato_det a, vw_pm_cliente b where a.id_cliente = b.codigo and a.estado != 'I' and a.id_solicitud = ");
			sbSql.append(id);
			al = SQLMgr.getDataList(sbSql.toString());
			sbSql = new StringBuffer();
			sbSql.append("select id, monto from tbl_pm_afiliado");
			alAM = SQLMgr.getDataList(sbSql.toString());
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				cdoDet.setKey(i);
				try {
					htClt.put(cdoDet.getKey(),cdoDet);
					String ctas = cdoDet.getColValue("id_cliente");
					vClt.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	} else {
		if (id == null) throw new Exception("Número de Solicitud no es válido. Por favor intente nuevamente!");

		if (change==null){

		htClt.clear();
		vClt.clear();
			/*
			encabezado
			*/
			sbSql = new StringBuffer();
			sbSql.append("select a.estado, a.id, a.id id_solicitud, a.id_cliente, a.cobertura_mi, a.cobertura_cy, a.cobertura_hi, a.cobertura_ot, a.afiliados, a.forma_pago, to_char(a.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, a.cuota_mensual, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.observacion, lpad(id, 10, '0') id_pad, (select descripcion || ' [ B/ ' || to_char(monto, '999,999.99') || ']' from tbl_pm_afiliado where id = a.afiliados ");
			sbSql.append(" and rownum =1 ) afiliados_desc, a.tipo_cliente, a.id_corredor, (select nombre from tbl_pm_corredor where id = a.id_corredor) nombre_corredor, a.tipo_plan, nvl(a.en_transicion, 'N') en_transicion from tbl_pm_solicitud_contrato a where a.id = ");
			sbSql.append(id);
			if(fp.equals("adenda")){
				sbSql = new StringBuffer();
				sbSql.append("select b.estado, b.id, a.id id_solicitud, a.id_cliente, a.cobertura_mi, a.cobertura_cy, a.cobertura_hi, a.cobertura_ot, b.afiliados, a.forma_pago, to_char(b.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, b.cuota_mensual, to_char(b.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(b.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, b.usuario_creacion, b.usuario_modificacion, b.observacion, lpad(a.id, 10, '0') id_pad, (select descripcion || ' [ B/ ' || to_char(monto, '999,999.99') || ']' from tbl_pm_afiliado where id = b.afiliados and rownum = 1) afiliados_desc, b.tipo_cliente, coalesce(b.id_corredor, a.id_corredor) id_corredor, coalesce(b.tipo_plan, a.tipo_plan) tipo_plan, (select nombre from tbl_pm_corredor where id = coalesce(b.id_corredor, a.id_corredor)) nombre_corredor, b.id_motivo from tbl_pm_solicitud_contrato a, tbl_pm_adenda b where a.id = b.id_solicitud and b.id = ");
				sbSql.append(id);
			}
			SOL = SQLMgr.getData(sbSql.toString());
			String table = "tbl_pm_sol_contrato_det";
			if(fp.equals("adenda")) table = "tbl_pm_adenda_det";
			sbSql = new StringBuffer();
			sbSql.append("select a.id_solicitud, a.id, a.id_cliente, a.parentesco, a.estado, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.observacion, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as identificacion, nombre_paciente as client_name, b.sexo, nvl (trunc (months_between (sysdate,coalesce (f_nac, fecha_nacimiento)-nvl((select to_number(get_sec_comp_param(-1, 'PARAM_DIAS_EDAD')) from dual), 0))/ 12),0) as edad, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.costo_mensual");
			if(fp.equals("adenda")) sbSql.append(", to_char(coalesce(a.fecha_inicio, a.fecha_creacion), 'dd/mm/yyyy') fecha_inicio");
			else sbSql.append(", to_char(a.fecha_inicio, 'dd/mm/yyyy') fecha_inicio");
			//if(!fp.equals("adenda")) 
			sbSql.append(", nvl(a.medicamento, '') medicamento, nvl(a.diagnostico, '') diagnostico, no_contrato, nvl(limite_anual, 0) limite_anual");
			
			sbSql.append(" from ");
			sbSql.append(table);
			sbSql.append(" a, vw_pm_cliente b where a.id_cliente = b.codigo and a.id_solicitud = ");
			sbSql.append(id);
			if(!fp.equals("adenda")) sbSql.append(" and a.estado != 'I'");
			System.out.println("sbSql="+sbSql.toString());
			al = SQLMgr.getDataList(sbSql.toString());
			sbSql = new StringBuffer();
			sbSql.append("select id, monto from tbl_pm_afiliado");
			alAM = SQLMgr.getDataList(sbSql.toString());
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				cdoDet.setKey(i);
				try {
					htClt.put(cdoDet.getKey(),cdoDet);
					htCltD.put(cdoDet.getKey(),cdoDet);
					String ctas = cdoDet.getColValue("id_cliente");
					vClt.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	session.setAttribute("SOL",SOL);
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Plan Médico - Solicitud'+document.title;

function doAction(){
}

function doSubmit(valor){
	window.frames['itemFrame'].doSubmit(valor);
}

function addCliente(){
	var cuota = document.solicitud.cuota.value;
	var en_transicion = document.solicitud.en_transicion.value;
	var afiliados = '';
	if(document.solicitud.afiliados) afiliados = document.solicitud.afiliados.value;
	abrir_ventana('../planmedico/pm_sel_cliente.jsp?fp=plan_medico&fg=responsable&cuota='+cuota+'&afiliados='+afiliados+'&en_transicion='+en_transicion);
}

function addSolicitud(){
	var id_motivo = document.solicitud.id_motivo.value;
	abrir_ventana('../planmedico/pm_sel_solicitud.jsp?fp=adenda&id_motivo='+id_motivo);
}

function calcCuotaMensual(){
	window.frames['itemFrame'].calc();
}

function inactivar(){
	var estado = document.solicitud.estado.value;
	<%if(mode.equals("edit")){%>
	if(estado=='I') document.solicitud.save.disabled=false;
	else document.solicitud.save.disabled=true;
	<%}%>
}

function addResponsable(){
	var change = document.solicitud.cobertura_mi.checked?'2':'3';
	var nombre_cliente = window.frames['clteFrame'].document.getElementById('nombre_cliente').value;
	var identificacion = window.frames['clteFrame'].document.getElementById('identificacion').value;
	var id_cliente = window.frames['clteFrame'].document.getElementById('id_cliente').value;
	var fecha_nacimiento = window.frames['clteFrame'].document.getElementById('fecha_nacimiento').value;
	var edad = window.frames['clteFrame'].document.getElementById('edad').value;
	var sexo = window.frames['clteFrame'].document.getElementById('sexo').value;
	var en_transicion = document.getElementById('en_transicion').value;
	var afiliados = '';
	if(document.solicitud.afiliados) afiliados = document.solicitud.afiliados.value;
	var contrato = getDBData('<%=request.getContextPath()%>','nvl(c.id, 0)', 'tbl_pm_sol_contrato_det d, tbl_pm_solicitud_contrato c', 'c.id = d.id_solicitud and d.id_cliente = '+id_cliente+' and c.estado in (\'A\',\'P\') and d.estado != \'I\' and rownum = 1')||0;
	if(nombre_cliente!='') {
		if(contrato!='0' && en_transicion != 'S'){ alert('El beneficiario ya esta en el contrato '+contrato);}
		else if(afiliados==1 && parseInt(edad) >= 60 && en_transicion != 'S') alert('La edad supera el limite para el PLAN FAMILIAR!');
		else if(afiliados==2 && parseInt(edad) < 60 && en_transicion != 'S') alert('La edad no corresponde al PLAN TERCERA EDAD!');
		else window.frames['itemFrame'].location='../planmedico/reg_solicitud_det.jsp?change='+change+'&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&id=<%=id%>&clientId='+id_cliente+'&client_name='+nombre_cliente+'&identificacion='+identificacion+'&fecha_nacimiento='+fecha_nacimiento+'&edad='+edad+'&sexo='+sexo;
		}
}

function addCorredor(){
abrir_ventana('../planmedico/pm_sel_corredor.jsp');
}

function tabFunctions(tab){
	var iFrameName = '';
	if(tab==1) iFrameName='iFrameTarjeta';
	window.frames[iFrameName].doAction();
}
function showInfo(tab, id, mode){
	var iFrameName = '', page = '';
	if(tab==1){
		iFrameName='iFrameTarjeta';
		page = '../planmedico/reg_tarjetas_cta.jsp?id_solicitud=<%=id%>&id='+id+'&mode='+mode+'&tab='+tab;
	}
	window.frames[iFrameName].location=page;
}

function changePlan(valor){
	var id = '<%=id%>';
	if(valor==-1 && id != '0')window.location = '../planmedico/reg_solicitud.jsp?fp=adenda&mode=<%=mode%>&id=<%=id%>&id_motivo='+valor;
}
function chkPlan(){
	var size = window.frames['itemFrame'].document.getElementById('keySize').value;
	var edad = window.frames['clteFrame'].document.getElementById('edad').value||0;
	document.getElementById('_afiliados').value = document.getElementById('afiliados').value;
	<%if(cuota.equals("SFE")){%>
	if(document.getElementById('afiliados').value==1 && edad >= 60){
		alert('La edad supera el limite para el PLAN FAMILIAR! Primero seleccione al plan y luego al Representante!')
		window.location = '../planmedico/reg_solicitud.jsp';
	} else if(document.getElementById('afiliados').value==2 && edad < 60 && edad >0){
		alert('La edad no corresponde al PLAN TERCERA EDAD! Primero seleccione al plan y luego al Representante!')
		window.location = '../planmedico/reg_solicitud.jsp';
	}
	<%}%>
	if(size>0) 
		if(confirm('Al cambiar de Tipo Plan se eliminaran los Beneficiarios! Desea Continuar?')){
			window.frames['itemFrame'].location='../planmedico/reg_solicitud_det.jsp?mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&id=<%=id%>';
		} else document.getElementById('afiliados').value = document.getElementById('_afiliados').value;
	else document.getElementById('_afiliados').value = document.getElementById('afiliados').value;
}

function chkFecha(){
	var fecha = document.getElementById('fecha_ini_plan').value;
	var x = getDBData('<%=request.getContextPath()%>','\'S\'','dual',' to_date(\''+fecha+'\', \'dd/mm/yyyy\') >= to_date(\'01/\'||to_char(sysdate, \'mm/yyyy\'), \'dd/mm/yyyy\')','')||'N';
	if(x=='N'){
		alert('La fecha debe ser igual o superior al del mes corriente!');
		document.getElementById('fecha_ini_plan').value='';
		return false;
	} else return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
		<div id="dhtmlgoodies_tabView1">
		<!--GENERALES TAB0-->
		<div class="dhtmlgoodies_aTab">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<table align="center" width="99%" cellpadding="0" cellspacing="1">
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("solicitud",request.getContextPath()+request.getServletPath(),"post");
						%>
              <%=fb.formStart(true)%>
							<%=fb.hidden("tab","0")%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
              <%=fb.hidden("fg",fg)%>
              <%=fb.hidden("fp",fp)%>
              <%=fb.hidden("id",id)%>
              <%=fb.hidden("tipo_cliente",SOL.getColValue("tipo_cliente"))%>
							<%=fb.hidden("cuota",cuota)%>
							<%=fb.hidden("parentescoHijo",parentescoHijo)%>
							<%=fb.hidden("edadMaxHijo",edadMaxHijo)%>
							<%=fb.hidden("planSize",""+alA.size())%>
							<%
							for(int i=0;i<alA.size();i++){
							CommonDataObject _cd = (CommonDataObject) alA.get(i);
							%>
							<%=fb.hidden("id"+i,_cd.getColValue("id"))%>
							<%=fb.hidden("monto"+i,_cd.getColValue("monto"))%>
							<%=fb.hidden("cant_min"+i,_cd.getColValue("cant_min"))%>
							<%=fb.hidden("cant_max"+i,_cd.getColValue("cant_max"))%>
							<%=fb.hidden("parentesco"+i,_cd.getColValue("parentesco"))%>
							<%
							}
							%>
							<%if(!fp.equals("adenda")){%>
              <tr>
                <td colspan="6">
								<font class="RedTextBold">Para Registrar Forma de Pago primero debe guardar la Solicitud!.</font>
								</td>
							</tr>	
							<%}%>
							<%if(fp.equals("adenda")){%>
              <tr>
                <td colspan="6">
								<font class="RedTextBold">Para cambiar el Tipo de Plan primero debe seleccionar el Motivo!.</font>
								</td>
							</tr>	
							<%}%>
              <tr class="TextPanel">
                <td colspan="5"><cellbytelabel>
								<%if(fp.equals("adenda")){%>
								FORMULARIO DE ADENDA
								<%} else {%>
								FORMULARIO DEL SOLICITANTE
								<%}%>
								</cellbytelabel>&nbsp;&nbsp;
								<%if(cuota.equals("SF")){%>
								<%=fb.decBox("cant_ben", "", false, false, true, 5, 12.2, "text12", "", "", "", false, "", "")%>
								<%=fb.textBox("plan_desc",SOL.getColValue("afiliados_desc"),false,false,true,30,30)%>
								<%=fb.hidden("afiliados",SOL.getColValue("afiliados"))%>
								<%} else {%>
								<%=fb.hidden("cant_ben","")%>
								<%=fb.hidden("plan_desc",SOL.getColValue("afiliados_desc"))%>
								<%=fb.hidden("_afiliados",SOL.getColValue("afiliados"))%>
								<%if(fp.equals("adenda")){%>
								<%=fb.textBox("plan_desc",(SOL.getColValue("afiliados")!=null && SOL.getColValue("afiliados").equals("1")?"PLAN FAMILIAR":"PLAN TERCERA EDAD"),false,false,true,30,30)%>	
								<%=fb.hidden("afiliados",SOL.getColValue("afiliados"))%>
								&nbsp;
								<%=fb.button("btnsolicitud","Contrato",true,viewMode,null,null,"onClick=\"javascript:addSolicitud()\"")%>
								Motivo Adenda:
								<%if(id_motivo.equals("-1")){%>
								<%=fb.hidden("id_motivo","-1")%>
								<%=fb.textBox("motivo_desc","CAMBIO DE TIPO DE PLAN",false,false,true,30,30)%>	
								<%} else {%>
								<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_pm_motivo_adenda where estado='A' order by 2 asc","id_motivo",SOL.getColValue("id_motivo"),false,false,0,"Text10 FormDataObjectRequired",null,"onChange='javascript:changePlan(this.value);'",null,"S")%>
								<%}%>
								<%} else {%>
								<%=fb.select("afiliados","1=PLAN FAMILIAR,2=PLAN TERCERA EDAD", SOL.getColValue("afiliados"), false, false,0,"text12",null,"onChange=\"javascript:chkPlan();\"")%>
								<%}%>
								<%if(fp.equals("adenda")){%>
								
								<%} else {%>
								<%=fb.button("btncliente","Responsable",true,viewMode,null,null,"onClick=\"javascript:addCliente()\"")%>
								<%}%>
								
								<%}%>
								</td>
								<td align="center"><%=(!mode.equals("add")?"Contrato No. "+SOL.getColValue("id_pad"):"")%></td>
              </tr>
              <tr>
                <td colspan="6"><iframe name="clteFrame" id="clteFrame" frameborder="0" align="center" width="100%" height="250" scrolling="no" src="../planmedico/cliente.jsp?change=<%=change%>&mode=<%=mode%>&id_cliente=<%=SOL.getColValue("id_cliente")%>"></iframe></td>
              </tr>
							<tr class="TextRow02">
								<td colspan="6">
                                Tipo Plan:
                                <%=fb.select("tipo_plan","I=Interno,O=Acerta", SOL.getColValue("tipo_plan"), true, false, false,0,"text12",null,"", "", "S")%>
                                <br>
Corredor:
								<%=fb.textBox("id_corredor",SOL.getColValue("id_corredor"),true,false,false,5,100,"Text10","","")%>
								<%=fb.textBox("nombre_corredor",SOL.getColValue("nombre_corredor"),true,false,false,45,100,"Text10","","")%>
								<%if(fp.equals("adenda")){%><authtype type='50'><%}%>
								<%=fb.button("btnCorredor","...",true,viewMode,null,null,"onClick=\"javascript:addCorredor()\"")%>
								<%if(fp.equals("adenda")){%></authtype><%}%>
								<%//=fb.select(ConMgr.getConnection(),"SELECT id, nombre descripcion from tbl_pm_corredor where estado = 'A'","id_corredor",SOL.getColValue("id_corredor"),false,false,0,"", "", "", "", "S")%>
								<%//if(fp.equals("adenda")){%>
								&nbsp;&nbsp;&nbsp;Observaci&oacute;n<%=fb.textarea("observacion",SOL.getColValue("observacion"),false,false,false,100,2, 2000)%>
								<%//}%>
								</td>
              </tr>
							<tr class="TextRow01">
                <td colspan="2">Estoy solicitando la cobertura de salud para:</td>
								<td>M&iacute;:<%=fb.checkbox("cobertura_mi","S",(SOL.getColValue("cobertura_mi")!=null && SOL.getColValue("cobertura_mi").equalsIgnoreCase("S")),viewMode, "", "", "onClick='javascript:addResponsable();'")%></td>
								<%if(cuota.equals("SF")){%>
								<td>C&oacute;nyugue:<%=fb.checkbox("cobertura_cy","S",(SOL.getColValue("cobertura_cy")!=null && SOL.getColValue("cobertura_cy").equalsIgnoreCase("S")),viewMode)%></td>
								<td>Hijo(s):<%=fb.checkbox("cobertura_hi","S",(SOL.getColValue("cobertura_hi")!=null && SOL.getColValue("cobertura_hi").equalsIgnoreCase("S")),viewMode)%></td>
								<td>Otros:<%=fb.checkbox("cobertura_ot","S",(SOL.getColValue("cobertura_ot")!=null && SOL.getColValue("cobertura_ot").equalsIgnoreCase("S")),viewMode)%></td>
								<%} else {%>
								<%=fb.hidden("cobertura_cy","")%>
								<%=fb.hidden("cobertura_hi","")%>
								<%=fb.hidden("cobertura_ot","")%>
								<td colspan="3">&nbsp;</td>
								<%}%>
              </tr>
							<tr class="TextPanel">
								<td colspan="6">INFORMACION DE PAGO</td>
              </tr>
							<%
							for(int i=0;i<alAM.size();i++){
								CommonDataObject cd = (CommonDataObject) alAM.get(i);
							%>
							<%=fb.hidden("plan_monto_"+cd.getColValue("id"), cd.getColValue("monto"))%>
							<%}%>
							<tr class="TextRow01">
 								<td>
								<%//=fb.select(ConMgr.getConnection(),"SELECT id, descripcion || ' [ B/ ' || to_char(monto, '999,999.99') || ']' descripcion from tbl_pm_afiliado where estado = 'A'","afiliados",SOL.getColValue("afiliados"),false,(SOL.getColValue("estado").equals("A")),0,"", "", "onChange=\"javascript:calcCuotaMensual();\"", "", "S")%>
							 </td>	
               <td align="right"><%if(cuota.equals("SF")){%>Forma de Pago:<%}%></td>
			   <%
			   String formas_pago = "1=Tarjeta de Credito, 2=ACH, 3=Pago Anual (CHK o Efectivo), 4=Descuento de Salario";
			   if(cuota.equals("SFE")) formas_pago = "1=Tarjeta de Credito, 2=ACH, 3=Efectivo o Cheque, 4=Descuento de Salario";
			   %>
								<td><%if(cuota.equals("SF")){%><%=fb.select("forma_pago",formas_pago, SOL.getColValue("forma_pago"), true, false, false,0,"text12",null,"", "", "S")%><%} else {%><%=fb.hidden("forma_pago","0")%><%}%></td>
								<td align="right">Cuota Mensual:<%=fb.decBox("cuota_mensual", SOL.getColValue("cuota_mensual"), false, false, true, 12, 12.2, "text12", "", "", "", false, "", "")%>&nbsp;+ prima de <%=primaPlanMedico%> %</td>
								<td align="right">Fecha Inicio Plan</td>
								<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha_ini_plan" />
								<jsp:param name="valueOfTBox1" value="<%=SOL.getColValue("fecha_ini_plan")%>" />
								<jsp:param name="fieldClass" value="FormDataObjectRequired" />
								<jsp:param name="jsEvent" value="chkFecha();" />
								<jsp:param name="onChange" value="chkFecha();" />
								</jsp:include>
								</td>
              </tr>
              <tr>
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="99" scrolling="no" src="../planmedico/reg_solicitud_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&id=<%=id%>&id_motivo=<%=id_motivo%>"></iframe></td>
              </tr>
							<tr>
                <td colspan="6"><iframe name="cuestionarioFrame" id="cuestionarioFrame" frameborder="0" align="center" width="100%" height="99" scrolling="no" src="../planmedico/ver_cuestionario_cliente.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&id_cliente=<%=SOL.getColValue("id_cliente")%>"></iframe></td>
              </tr>
							<tr class="TextRow01">
								<td colspan="6" align="right"><cellbytelabel>Estado:</cellbytelabel>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<%=fb.select("_estado", (SOL.getColValue("estado").equals("A")?"A=Aprobado":(SOL.getColValue("estado").equals("I")?"I=Inactivo":"P=Pendiente")),SOL.getColValue("estado"), false, false, 0, null, null, "")%>
								<%=fb.hidden("estado","P")%>
								<%=fb.hidden("estadoDB",SOL.getColValue("estado"))%>
								<%if(!fp.equals("adenda") && (mode.equals("add") || mode.equals("view"))){%>
								&nbsp;&nbsp;
								En Transici&oacute;n?
								<%=fb.select("en_transicion", "N=No,S=Si",SOL.getColValue("en_transicion"), false, false, 0, null, null, "")%>
								<%} else {%>
								<%=fb.hidden("en_transicion", SOL.getColValue("en_transicion"))%>
								<%}%>
								</td>	
							</tr>
							<tr class="TextRow02">
								<td colspan="6" align="right">
								<cellbytelabel>Opciones de Guardar</cellbytelabel>:
								<%System.out.println("estado................"+(!fp.equals("adenda") && SOL.getColValue("estado").equals("A")));%>
								<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
								<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
								<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
								<%=fb.button("save","Guardar",true,((fp.equals("adenda") && SOL.getColValue("estado").equals("A") && mode.equals("edit")) || (!fp.equals("adenda") && SOL.getColValue("estado").equals("A") && mode.equals("edit")) || SOL.getColValue("estado").equals("I") || mode.equals("view")),"","","onClick=\"javascript:doSubmit(this.value);\"")%>

								<%if(!fp.equals("adenda")){%>
								<%=fb.button("saveandapro","Guardar y Aprobar",true,((fp.equals("adenda") && SOL.getColValue("estado").equals("A") && mode.equals("edit")) || (!fp.equals("adenda") && SOL.getColValue("estado").equals("A") && mode.equals("edit")) || SOL.getColValue("estado").equals("I") || mode.equals("view")),"","","onClick=\"javascript:doSubmit(this.value);\"")%>
								<%}%>

								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
								</td>
							</tr>
							<!--
							-->
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table>
				</div>
				<!-- TAB0 DIV END HERE [SOLICITUD]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","1")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("fp",fp)%>
					<tr class="TextPanel">
						<td colspan="3">TARJETA/CUENTA</td>
						<td align="right">
						</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameTarjeta" id="iFrameTarjeta" frameborder="0" align="center" width="100%" height="350" scrolling="yes" src="../planmedico/reg_tarjetas_cta.jsp?id_solicitud=<%=id%>&mode=<%=mode%>&tab=1&id_cliente=<%=SOL.getColValue("id_cliente")%>"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				<!-- TAB0 DIV END HERE [EXCLUISIONES]-->
				<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","2")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("saveOption","")%>
				<%=fb.hidden("errMsg","")%>
				<%=fb.hidden("errCode","")%>
				<%=fb.hidden("fp",fp)%>
					<tr class="TextPanel">
						<td colspan="3">Excluiones</td>
						<td align="right">
						</td>
					</tr>
					<tr class="TextRow01">
						<td colspan="4">
						<iframe name="iFrameTarjeta" id="iFrameTarjeta" frameborder="0" align="center" width="100%" height="350" scrolling="yes" src="../planmedico/reg_diagnostico_medicamento.jsp?id_solicitud=<%=id%>&mode=<%=mode%>&tab=2&id_cliente=<%=SOL.getColValue("id_cliente")%>"></iframe>
						</td>
					</tr>
				<%=fb.formEnd(true)%>
				</table>
				</div>
				</div>
<script type="text/javascript">
<%
String tabInactivo="";
String tabLabel = "'Contrato'";
if (!mode.equalsIgnoreCase("add") && !fp.equals("adenda")) {
  tabLabel += ",'Forma Pago'";
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),[]);
</script>
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
	System.out.println("saveOption............................="+saveOption);
	id = request.getParameter("id");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function unload(){closeChild=false;}
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	<%if(fp.equals("adenda")){%>
	window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_adendas_list.jsp';
	<%} else {%>
	window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_solicitud_list.jsp';
	<%}%>
<%
session.removeAttribute("Sol");
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
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&fp=<%=fp%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
