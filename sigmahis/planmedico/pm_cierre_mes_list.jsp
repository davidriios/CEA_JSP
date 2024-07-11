<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String fecha_ini = "", fecha_fin = "";
String afiliados = "", estado="", cuota_mensual="", cm_oper="";
String tipoPlan = request.getParameter("tipoPlan");
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

	
if(request.getMethod().equalsIgnoreCase("GET"))
{
	String cuota = "";
	sbSql = new StringBuffer();
	sbSql.append("select get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CALC_CUOTA_PLAN_MED') cuota, get_sec_comp_param(-1, 'COD_PARENTESCO_HIJO') COD_PARENTESCO_HIJO from dual");
	CommonDataObject _cdP = SQLMgr.getData(sbSql.toString());

	if(_cdP==null) cuota = "SF";
	else {
		cuota = _cdP.getColValue("cuota");
	}	

int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if(request.getParameter("fecha_ini")!=null) fecha_ini = request.getParameter("fecha_ini");
	if(request.getParameter("fecha_fin")!=null) fecha_fin = request.getParameter("fecha_fin");
	if(request.getParameter("afiliados")!=null) afiliados = request.getParameter("afiliados");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(request.getParameter("cuota_mensual")!=null) cuota_mensual = request.getParameter("cuota_mensual");
	if(request.getParameter("cm_oper")!=null) cm_oper = request.getParameter("cm_oper");
	if (tipoPlan == null) tipoPlan = "";

	sbSql = new StringBuffer();

	sbSql.append("select id, id_cliente, (select    b.primer_nombre || decode (b.segundo_nombre, null, ' ', ' ' || b.segundo_nombre) || ' ' || b.primer_apellido || decode (b.segundo_apellido, null, '', ' ' || b.segundo_apellido) || decode (b.sexo, 'F', decode (b.apellido_de_casada, null, '', ' ' || b.apellido_de_casada)) from tbl_pm_cliente b where b.codigo = a.id_cliente) responsable, (select decode (tipo_id_paciente, 'P', pasaporte, provincia || '-' || sigla || '-' || tomo || '-' || asiento) || '-' || d_cedula from tbl_pm_cliente b where b.codigo = a.id_cliente) ident_responsable, to_char (fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, decode (a.afiliados, 1, 'PLAN FAMILIAR', 2, 'PLAN TERCERA EDAD', a.afiliados) afiliados_desc, (select count (*) cont_benef from tbl_pm_sol_contrato_det d where d.id_solicitud = a.id and d.estado = 'A') cont_benef, decode (estado,  'P', 'Pendiente',  'A', 'Aprobado',  'I', 'Inactivo', 'F', 'Finalizado') estado_desc, (select count (*) from (select distinct id_sol_contrato, anio, mes from tbl_pm_factura f where f.id_regtran is not null and monto_apl_regtran = monto) where id_sol_contrato = a.id) meses_pagados, /*(select anio || '-' || mes from (  select a.id_sol_contrato, a.anio, max (b.mes) mes from (select distinct id_sol_contrato, anio, mes from tbl_pm_factura where id_regtran is not null and monto_apl_regtran = monto) b, (  select id_sol_contrato, max (anio) anio from tbl_pm_factura f where f.id_regtran is not null and monto_apl_regtran = monto group by id_sol_contrato) a where a.id_sol_contrato = b.id_sol_contrato and a.anio = b.anio group by a.id_sol_contrato, a.anio) x where x.id_sol_contrato = a.id)*/ getPagadoHasta(a.id) mes_ultimo_pago, nvl(b.saldo_inicial, 0) saldo_inicial, nvl(b.debito, 0) debito, nvl(b.credito, 0) credito, nvl (b.ajuste_anula_pago, 0) ajuste_anula_pago, nvl(b.ajuste_nota_credito, 0) ajuste_nota_credito, (nvl (b.saldo_inicial, 0) + nvl (b.debito, 0) - nvl (b.credito, 0) + nvl(b.ajuste_anula_pago, 0) + nvl(b.ajuste_nota_credito, 0)) saldo_final, to_char(a.fecha_fin_plan, 'dd/mm/yyyy') fecha_fin_plan, nvl(b.impuesto, 0) impuesto, nvl(b.descuento, 0) descuento from tbl_pm_solicitud_contrato a, (select b.*, (case when b.saldo_inicial != 0 or b.debito != 0 or b.credito != 0 or ajuste_anula_pago != 0 or ajuste_nota_credito != 0 then 'S' else 'N' end) tiene_movimiento from (select id_sol_contrato, sum (nvl(debito_si, 0) - nvl(credito_si, 0)) saldo_inicial, sum (nvl(debito, 0)) debito, sum (nvl(credito, 0)) credito, sum(nvl(ajuste_anula_pago, 0)) ajuste_anula_pago, sum(nvl(ajuste_nota_credito, 0)) ajuste_nota_credito, sum(nvl(impuesto, 0)) impuesto, sum(nvl(descuento, 0)) descuento from (select id_sol_contrato, sum((case when fecha < to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') then monto else 0 end)) debito_si, 0 credito_si, sum ((case when fecha between to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') then monto else 0 end)) debito, 0 credito, 0  ajuste_anula_pago, 0 ajuste_nota_credito, sum((case when fecha between to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') then impuesto else 0 end)) impuesto, sum((case when fecha between to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') then descuento else 0 end)) descuento from tbl_pm_factura where estado = 'A' and fecha <= to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') and compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" group by id_sol_contrato, 0, 0, 0, 0 union all select id_contrato, 0 debito_si, sum ((case when TRUNC(a.fecha_creacion) < to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') then monto_app else 0 end)) credito_si, 0 debito, sum ((case when TRUNC(a.fecha_creacion) between to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') then monto_app else 0 end)) credito, 0 ajuste_anula_pago, 0 ajuste_nota_credito, 0 impuesto, 0 descuento from tbl_pm_regtran a, tbl_pm_regtran_det b where a.id = b.id and (a.estado = 'A' or (a.estado = 'I' and a.fecha_anulacion is not null)) and trunc (a.fecha_creacion) <= to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" group by id_contrato, 0, 0, 0, 0, 0, 0");
		sbSql.append(" union all ");
		sbSql.append("select id_solicitud, sum ( (case when trunc (a.fecha_creacion) < to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') then (nvl (debito, 0)) else 0 end)) debito_si, sum ( (case when trunc (a.fecha_creacion) < to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') then (nvl (credito, 0)) else 0 end)) creito_si, sum ( (case when trunc (a.fecha_creacion) between to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') and a.tipo_aju = 5 then (nvl (debito, 0) - nvl (credito, 0)) else 0 end)) debito, 0 credito, sum ( (case when trunc (a.fecha_creacion) between to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') and a.tipo_aju = 2 then (nvl (debito, 0) - nvl (credito, 0)) else 0 end)) ajuste_anula_pago, sum ( (case when trunc (a.fecha_creacion) between to_date ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') and to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') and a.tipo_aju in (1, 3) then (nvl (debito, 0) - nvl (credito, 0)) else 0 end)) ajuste_nota_credito, 0 impuesto, 0 descuento from tbl_pm_ajuste a, tbl_pm_ajuste_det b where a.compania = b.compania and a.id = b.id and a.estado = 'A' and b.estado = 'A' and a.tipo_ben = 1 and a.tipo_aju in (1, 2, 3) and trunc (a.fecha_creacion) <= to_date ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" group by id_solicitud, 0, 0, 0, 0");
		sbSql.append(") GROUP BY id_sol_contrato) b) b where a.id = b.id_sol_contrato(+)");
		if(!estado.equals("")){
			if(estado.equals("A")){
				sbSql.append(" and (a.estado = '");
				sbSql.append(estado);
				sbSql.append("' and a.fecha_ini_plan <= to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') or (a.estado = 'A' and a.fecha_ini_plan > to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') and nvl(b.tiene_movimiento, 'N') = 'S'))");
			} else if(estado.equals("F")){
				sbSql.append(" and (a.estado = '");
				sbSql.append(estado);
				sbSql.append("' and a.fecha_fin_plan <= to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') or (a.estado = 'F' and a.fecha_fin_plan >  to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') and nvl(b.tiene_movimiento, 'N') = 'S'))");
			} else {
				sbSql.append(" and a.estado = '");
				sbSql.append(estado);
				sbSql.append("'");
			}
		} else {
				sbSql.append(" and ((a.estado = 'A' and a.fecha_ini_plan <= to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') or (a.estado = 'A' and a.fecha_ini_plan > to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') and nvl(b.tiene_movimiento, 'N') = 'S')) or (a.estado = 'F' and a.fecha_fin_plan <= to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') or (a.estado = 'F' and a.fecha_fin_plan >  to_date('");
				sbSql.append(fecha_fin);
				sbSql.append("','dd/mm/yyyy') and nvl(b.tiene_movimiento, 'N') = 'S')) or a.estado = 'P')");
		}
		
		/*sbSql.append(" and (a.fecha_ini_plan between TO_DATE ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') AND TO_DATE ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') or (a.fecha_ini_plan not between TO_DATE ('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy') AND TO_DATE ('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy') and (nvl(b.saldo_inicial, 0) != 0 or nvl(b.debito, 0) != 0 or nvl(b.credito, 0) != 0 or nvl(b.ajuste_anula_pago, 0) != 0 or nvl(b.ajuste_nota_credito, 0) != 0)))");*/
		if(!afiliados.equals("")){
			sbSql.append(" and a.afiliados = ");
			sbSql.append(afiliados);
		}
		if (!tipoPlan.trim().equals("")) { sbSql.append(" and a.tipo_plan = '"); sbSql.append(tipoPlan); sbSql.append("'"); }

	sbSql.append(" order by id DESC nulls last ");
	if(!fecha_ini.equals("") && !fecha_fin.equals("")){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
	}
	
	CommonDataObject cdoT = SQLMgr.getData("select sum(saldo_inicial) saldo_inicial, sum(debito) debito, sum(credito) credito, sum(saldo_final) saldo_final, sum(cont_benef) cont_benef, sum(ajuste_anula_pago) ajuste_anula_pago, sum(ajuste_nota_credito) ajuste_nota_credito, sum(impuesto) impuesto, sum(descuento) descuento from ("+sbSql.toString()+")");

	if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";

  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);

  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;

  if(rowCount==0) pVal=0;
  else pVal=preVal;

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Plan Medicico - Mantenimiento - Cuentionario Salud - '+document.title;

function doAction(){changeAltTitleAttr();}

function manageSurvey(option){
   if (typeof option == "undefined") abrir_ventana('../planmedico/reg_solicitud.jsp');
   else if(option=='edit'){
    if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else abrir_ventana('../planmedico/reg_solicitud.jsp?mode=edit&id='+getCurVal());
   }
   else if(option=='view'){
    if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else abrir_ventana('../planmedico/ver_mov_cierre_mes.jsp?mode=view&id_contrato='+getCurVal()+'&fechaini=<%=fecha_ini%>&fechafin=<%=fecha_fin%>');
   }
   else if(option=='print'){
		 var fDesde = document.search01.fecha_ini.value;
		 var fHasta = document.search01.fecha_fin.value;
		 var afiliados = document.search01.afiliados.value||'ALL';
		 var tipoPlan = document.search01.tipoPlan.value||'ALL';
		 var estado = document.search01.estado.value;
         abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_cierre_mes.rptdesign&fDesdeParam='+fDesde+'&fHastaParam='+fHasta+'&planParam='+afiliados+'&estadoParam='+estado+'&tipoPlan='+tipoPlan);
      /*if (getCurVal() != ""){
        var ind = document.getElementById("curIndex").value;
        var clientId = document.getElementById("clientId"+ind).value;
      }else{
        abrir_ventana('../planmedico/print_pm_sol_plan_list.jsp?fechaIniPlanFrom=<%=fecha_ini%>&fechaIniPlanTo=<%=fecha_fin%>&afiliados=<%=afiliados%>&estado=<%=estado%>&cuotaMensual=<%=cuota_mensual%>&cmOper=<%=cm_oper%>');
      }*/
   } else if(option=='approve'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
       var fecha_ini_plan = document.getElementById("fecha_ini_plan"+ind).value;
			var estado = document.getElementById("estado"+ind).value;
			 var cont_benef = document.getElementById("cont_benef"+ind).value;
			 if(estado=='I') CBMSG.warning('La Solicitud está inactiva y no se puede aprobar!');
			 else if(estado=='A') CBMSG.warning('La Solicitud ya está aprobada!');
			 else if(cont_benef==0) CBMSG.warning('La Solicitud no tiene Beneficiarios!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=1&docId='+getCurVal()+'&extDesc='+name_responsable+' '+ident_responsable+'&fecha='+fecha_ini_plan,winWidth*.95,_contentHeight*.55,null,null,'');
		}
	 } else if(option=='inactivate'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
			 var estado = document.getElementById("estado"+ind).value;
			 if(estado=='I') CBMSG.warning('La Solicitud ya está inactiva!');
			 else if(estado=='A') CBMSG.warning('La Solicitud está aprobada y no se puede inactivar!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=2&docId='+getCurVal()+'&extDesc='+name_responsable+' '+ident_responsable,winWidth*.95,_contentHeight*.75,null,null,'');
	}
	}
}

function changeAltTitleAttr(obj,type,ctx){
  var opt = {"view":"Ver","edit":"Editar","print":"Imprimir","approve":"Aprobar","inactivate":"Inactivar"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
	  if (getCurVal()!=""){
		obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
		obj.title = opt[type]+" "+ctx+" #"+getCurVal();
	  }
	}else{
	  //document.getElementById("printImg").alt = "Imprimir Lista Solicitud";
	  //document.getElementById("editImg").alt = "Seleccione un Solicitud a Editar";
	  document.getElementById("viewImg").alt = "Seleccione un Contrato a Ver";
	  //document.getElementById("appImg").alt = "Aprobar Solicitud";
	  //document.getElementById("inacImg").alt = "Inactivar Solicitud";
	  document.getElementById("printImg").title = "Imprimir Lista";
	  //document.getElementById("editImg").title = "Seleccione una Solicitud a Editar";
	  document.getElementById("viewImg").title = "Seleccione un Contrato a Ver";
	  //document.getElementById("appImg").title = "Aprobar Solicitud";
	  //document.getElementById("inacImg").title = "Inactivar Solicitud";
	}
}

function getCurVal(){return document.getElementById("curVal").value;}
function setId(curVal,curIndex){document.getElementById("curVal").value = curVal;
document.getElementById("curIndex").value = curIndex;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:changeAltTitleAttr()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr><%//="[2] IMPRIMIR       [3] REGISTRAR       [4] EDITAR"  %>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='1'>
			<img src="../images/ver.png" onClick="javascript:manageSurvey('view')" onMouseOver="javascript:changeAltTitleAttr(this,'view','Contrato')" width="32px" height="32px" id="viewImg"/>
			</authtype>&nbsp;
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manageSurvey('print')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Cierre Mes')" id="printImg"/>
			</authtype>
			<!--<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nueva Solicitud" title="Registrar Nueva Solicitud" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Solicitud')" width="32px" height="32px" id="editImg"/>
			</authtype>&nbsp;
			<authtype type='6'>
			<img src="../images/check.gif" onClick="javascript:manageSurvey('approve')" onMouseOver="javascript:changeAltTitleAttr(this,'approve','Solicitud')" id="appImg" height="30" width="30"/>
			</authtype>
			<authtype type='7'>
			<img src="../images/cancel.gif" onClick="javascript:manageSurvey('inactivate')" onMouseOver="javascript:changeAltTitleAttr(this,'inactivate','Solicitud')" id="inacImg" height="30" width="30"/>
			</authtype>
		</td>
	</tr>-->
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">&nbsp;<cellbytelabel id="2">Fecha</cellbytelabel>&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_ini" />
			<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
			<jsp:param name="nameOfTBox2" value="fecha_fin" />
			<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
			</jsp:include>
			&nbsp;<cellbytelabel>Afiliados</cellbytelabel>&nbsp;
			<%if(cuota.equals("SF")){%>
			<%=fb.select("afiliados","1=1 - 2 Afiliados,2=3 - 4 Afiliados, 3 = 5 y mas Afiliados",afiliados,"T")%>
			<%} else if(cuota.equals("SFE")){%>
			<%=fb.select("afiliados","1=PLAN FAMILIAR,2=PLAN TERCERA EDAD", afiliados, "T")%>
      <%}%>
			<cellbytelabel>Tipo Plan</cellbytelabel>
      <%=fb.select("tipoPlan","I=INTERNO,O=ACERTA",tipoPlan,"T")%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,F=Finalizado,P=Pendiente",estado,"T")%>
			<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<!--<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
		</td>
	</tr>-->
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="6%">&nbsp;<cellbytelabel>Contrato</cellbytelabel></td>
		<td width="15%">&nbsp;<cellbytelabel>Responsable</cellbytelabel></td>
		<td width="7%"><cellbytelabel>Fecha Ini.</cellbytelabel></td>
		<td width="7%"><cellbytelabel>Clase Contrato</cellbytelabel></td>
		<td width="4%"><cellbytelabel>Num. Ben.</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Meses Pagos.</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Pagado Hasta</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Fecha Cierre</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Saldo Ini.</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Facturas</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Pagos</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Aju. AP</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Aju. NC</cellbytelabel></td>
		<td width="6%"><cellbytelabel>ITBM</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Desc.</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Saldo Final</cellbytelabel></td>
		<td width="2%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curVal","")%>
	<%=fb.hidden("curIndex","")%>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td><%=cdo.getColValue("responsable")%></td>
					<td><%=cdo.getColValue("fecha_ini_plan")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("afiliados_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("cont_benef")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("meses_pagados")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("mes_ultimo_pago")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_fin_plan")%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_anula_pago"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_nota_credito"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("impuesto"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_final"))%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id")+","+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("clientId"+i,cdo.getColValue("id_cliente"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("ident_responsable"+i,cdo.getColValue("ident_responsable"))%>
				<%=fb.hidden("name_responsable"+i,cdo.getColValue("responsable"))%>
				<%=fb.hidden("fecha_ini_plan"+i,cdo.getColValue("fecha_ini_plan"))%>
				<%=fb.hidden("cont_benef"+i,cdo.getColValue("cont_benef"))%>
				<%
				}
				%>
				<%if(al.size()>0){%>
				<tr class="TextHeader">
					<td align="right" colspan="4">Total</td>
					<td align="center">&nbsp;<%=cdoT.getColValue("cont_benef")%></td>
					<td align="right" colspan="4">&nbsp;</td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("saldo_inicial"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("debito"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("credito"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("ajuste_anula_pago"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("ajuste_nota_credito"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("impuesto"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("descuento"))%></td>
					<td align="center">&nbsp;<%=CmnMgr.getFormattedDecimal(cdoT.getColValue("saldo_final"))%></td>
					<td align="center">&nbsp;</td>
				</tr>				
				<%}%>
<%=fb.formEnd(true)%>
</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>