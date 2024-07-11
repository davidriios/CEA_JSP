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
String fecha_ini_plan_f = "", fecha_ini_plan_t = "", fecha_fin_plan_f = "", fecha_fin_plan_t = "";
String afiliados = "", estado="", cuota_mensual="", cm_oper="", id="", nombreCliente="", tipoPlan = "", en_transicion = "";
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

  if(request.getParameter("fecha_ini_plan_f")!=null) fecha_ini_plan_f = request.getParameter("fecha_ini_plan_f");
	if(request.getParameter("fecha_ini_plan_t")!=null) fecha_ini_plan_t = request.getParameter("fecha_ini_plan_t");
	if(request.getParameter("fecha_fin_plan_f")!=null) fecha_fin_plan_f = request.getParameter("fecha_fin_plan_f");
	if(request.getParameter("fecha_fin_plan_t")!=null) fecha_fin_plan_t = request.getParameter("fecha_fin_plan_t");
	if(request.getParameter("afiliados")!=null) afiliados = request.getParameter("afiliados");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(request.getParameter("cuota_mensual")!=null) cuota_mensual = request.getParameter("cuota_mensual");
	if(request.getParameter("cm_oper")!=null) cm_oper = request.getParameter("cm_oper");
	if(request.getParameter("id")!=null) id = request.getParameter("id");
	if(request.getParameter("nombre_cliente")!=null) nombreCliente = request.getParameter("nombre_cliente");
	if(request.getParameter("tipo_plan")!=null) tipoPlan = request.getParameter("tipo_plan");
	if(request.getParameter("en_transicion")!=null) en_transicion = request.getParameter("en_transicion");

	sbSql = new StringBuffer();

	sbSql.append("select estado, id, id_cliente, cobertura_mi, cobertura_cy, cobertura_hi, cobertura_ot, afiliados, forma_pago, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, cuota_mensual, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, observacion, decode(estado, 'P', 'Pendiente', 'A', 'Aprobado', 'I', 'Inactivo', 'F', 'Finalizado') estado_desc, (select b.nombre_paciente from vw_pm_cliente b where b.codigo = a.id_cliente) responsable, ");
	if(cuota.equals("SF")) sbSql.append("(select descripcion from tbl_pm_afiliado c where id = a.afiliados)");
	else if(cuota.equals("SFE")) sbSql.append("decode (a.afiliados, 1, 'PLAN FAMILIAR', 2, 'PLAN TERCERA EDAD', a.afiliados)");
	
	sbSql.append("	afiliados_desc, (select decode (tipo_id_paciente, 'P', pasaporte, provincia || '-' || sigla || '-' || tomo || '-' || asiento) || '-' || d_cedula from tbl_pm_cliente b where b.codigo = a.id_cliente) ident_responsable, (select count(*) cont_benef from tbl_pm_sol_contrato_det d where d.id_solicitud = a.id) cont_benef, to_char(fecha_fin_plan, 'dd/mm/yyyy') fecha_fin_plan, a.usuario_fin_plan, nvl(a.num_pagos, 0) num_pagos, (case when estado = 'F' then observacion_fin_plan else '' end) motivo_fin_plan, (case when estado = 'F' then nvl(trunc(months_between(sysdate, fecha_fin_plan)/12),0) || ' Años ' || nvl(mod(trunc(months_between(sysdate, fecha_fin_plan)),12),0) || ' Meses ' || trunc(sysdate-add_months(fecha_fin_plan,(nvl(trunc(months_between(sysdate,fecha_fin_plan)/12),0)*12+nvl(mod(trunc(months_between(sysdate,fecha_fin_plan)),12),0)))) || ' Dias ' else '' end) tiempo_finalizado from tbl_pm_solicitud_contrato a where 1=1 ");
	if(!fecha_ini_plan_f.equals("")){
		sbSql.append(" and fecha_ini_plan >= to_date('");
		sbSql.append(fecha_ini_plan_f);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_ini_plan_t.equals("")){
		sbSql.append(" and fecha_ini_plan <= to_date('");
		sbSql.append(fecha_ini_plan_t);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_fin_plan_f.equals("")){
		sbSql.append(" and fecha_fin_plan >= to_date('");
		sbSql.append(fecha_fin_plan_f);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_fin_plan_t.equals("")){
		sbSql.append(" and fecha_fin_plan <= to_date('");
		sbSql.append(fecha_fin_plan_t);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!afiliados.equals("")){
		sbSql.append(" and afiliados = ");
		sbSql.append(afiliados);
	}
	if(!id.equals("")){
		sbSql.append(" and id = ");
		sbSql.append(id);
	}
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!en_transicion.equals("")){
		sbSql.append(" and en_transicion = '");
		sbSql.append(en_transicion);
		sbSql.append("'");
	}
	if(!cuota_mensual.equals("")){
		sbSql.append(" and cuota_mensual ");
		sbSql.append(cm_oper);
		sbSql.append(cuota_mensual);
	}
    
    if(!tipoPlan.equals("")){
		sbSql.append(" and a.tipo_plan = '");
		sbSql.append(tipoPlan);
		sbSql.append("'");
	}
    
    String sql = sbSql.toString();
    
    if (!nombreCliente.trim().equals("")) {
      sql = "select aa.* from("+sbSql.toString()+") aa where upper(aa.responsable) like upper('%"+nombreCliente+"%') order by aa.id DESC nulls last ";
      System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::. 1");
    } else {
        sql += " order by id DESC nulls last ";
        System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::. 0");
    }
     
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

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
		else {
			var ind = document.getElementById("curIndex").value;
			var estado = document.getElementById("estado"+ind).value;
			if(estado=='F') CBMSG.warning('No puede editar un contrato Finalizado!');
			else abrir_ventana('../planmedico/reg_solicitud.jsp?mode=edit&id='+getCurVal());
		}
   }
   else if(option=='view'){
    if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else abrir_ventana('../planmedico/reg_solicitud.jsp?mode=view&id='+getCurVal());
   }
   else if(option=='print'){
      if (getCurVal() != ""){
        var ind = document.getElementById("curIndex").value;
        var clientId = document.getElementById("clientId"+ind).value;
         abrir_ventana('../planmedico/print_pm_sol_plan.jsp?fg=responsable&id='+getCurVal()+'&clientId='+clientId);
      }else{
			 var fIniDesde = document.search01.fecha_ini_plan_f.value||'ALL';
			 var fIniHasta = document.search01.fecha_ini_plan_t.value||'ALL';
			 var fFinDesde = document.search01.fecha_fin_plan_f.value||'ALL';
			 var fFinHasta = document.search01.fecha_fin_plan_t.value||'ALL';
			 var codigo = document.search01.id.value||'ALL';
			 var plan = document.search01.afiliados.value||'ALL';
			 var estado = document.search01.estado.value||'ALL';
			 var nombre_cliente = document.search01.nombre_cliente.value||'ALL';
			 var cm_oper = document.search01.cm_oper.value||'ALL';
			 var cuota_monto = document.search01.cuota_mensual.value||'0';
			 var tipoPlan = document.search01.tipo_plan.value||'ALL';
			 
				abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_solicitud_list.rptdesign&fIniDesdeParam='+fIniDesde+'&fIniHastaParam='+fIniHasta+'&fFinDesdeParam='+fFinDesde+'&fFinHastaParam='+fFinHasta+'&contratoParam='+codigo+'&planParam='+plan+'&estadoParam='+estado+'&clienteParam='+nombre_cliente+'&cuotaOperParam='+cm_oper+'&cuotaMontoParam='+cuota_monto+'&tipoPlan='+tipoPlan);
        //abrir_ventana('../planmedico/print_pm_sol_plan_list.jsp?fechaIniPlanFrom=<%=fecha_ini_plan_f%>&fechaIniPlanTo=<%=fecha_ini_plan_t%>&afiliados=<%=afiliados%>&estado=<%=estado%>&cuotaMensual=<%=cuota_mensual%>&cmOper=<%=cm_oper%>');
      }
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
			 else if(estado=='F') CBMSG.warning('No puede aprobar un contrato ya Finalizado!');
			 else if(cont_benef==0) CBMSG.warning('La Solicitud no tiene Beneficiarios!');
			 else if(!chkExcluisiones(getCurVal())) CBMSG.warning('Debe registrar las Exclusiones!');
			 else if(!chkFormaPago(getCurVal())) CBMSG.warning('Debe registrar la Forma de Pago!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=1&docId='+getCurVal()+'&extDesc='+name_responsable+' '+ident_responsable+'&fecha='+fecha_ini_plan,winWidth*.95,_contentHeight*.75,null,null,'');
		}
	 } else if(option=='inactivate'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
			 var estado = document.getElementById("estado"+ind).value;
			 if(estado=='I') CBMSG.warning('La Solicitud ya está inactiva!');
			 else if(estado=='F') CBMSG.warning('No puede inactivar un contrato ya Finalizado!');
			 else if(estado=='A') CBMSG.warning('La Solicitud está aprobada y no se puede inactivar!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=2&docId='+getCurVal()+'&extDesc='+name_responsable+' '+ident_responsable,winWidth*.95,_contentHeight*.75,null,null,'');
	}
	 } else if(option=='close'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
			 var estado = document.getElementById("estado"+ind).value;
			 if(estado!='A') CBMSG.warning('Solo las solicitudes aprobadas pueden ser cerradas!');
			 else if(estado=='A') showPopWin('../process/pm_cerrar_solicitud.jsp?code='+getCurVal(),winWidth*.95,_contentHeight*.75,null,null,'');
	}
	} else if(option=='print_contract'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
         var i = document.getElementById("curIndex").value;
         var idClie = document.getElementById("clientId"+i).value;
         var tipoPlan = document.getElementById("tipo_plan"+i).value;
         var noContrato = document.getElementById("no_contrato"+i).value;
         if (tipoPlan == '1') abrir_ventana("../planmedico/print_contrato_familiar.jsp?cod_ben="+idClie+"&no_contrato="+noContrato+"&no_secuencia=0");
         else abrir_ventana("../planmedico/print_contrato_tercera_edad.jsp?cod_ben="+idClie+"&no_contrato="+noContrato+"&no_secuencia=0");
        }
	} else if(option=='edit_pagos'){
      if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
         var i = document.getElementById("curIndex").value;
         var num_pagos = document.getElementById("num_pagos"+i).value;
         var noContrato = document.getElementById("no_contrato"+i).value;
         showPopWin("../process/pm_upd_num_pagos.jsp?no_contrato="+noContrato+"&num_pagos="+num_pagos,winWidth*.45,_contentHeight*.45,null,null,'');
        }
   } else if(option=='cancel_close'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
       var fecha_fin_plan = document.getElementById("fecha_fin_plan"+ind).value;
			 var estado = document.getElementById("estado"+ind).value;
			 
			 if(estado=='F' || (estado == 'A' && fecha_fin_plan != '')) showPopWin('../process/pm_cerrar_solicitud.jsp?code='+getCurVal()+'&mode=cancel',winWidth*.95,_contentHeight*.75,null,null,'');
			 else CBMSG.warning('Solo las solicitudes Finalizadas o Aprobadas con Fecha de Finalizacion pueden ser Canceladas!');
	}
}}
function chkFormaPago(id){
  var r = getDBData('<%=request.getContextPath()%>','count(*)', 'tbl_pm_cta_tarjeta','estado = \'A\' and id_solicitud='+id,'')||0;
  if(r==0) return false;
	else return true;
}
function chkExcluisiones(id){
	var count = parseInt(getDBData('<%=request.getContextPath()%>','count(*)', 'tbl_pm_sol_contrato_det','estado != \'I\' and diagnostico is null and medicamento is null and id_solicitud = '+id,''));
	if(count==null || count=='') count=0;
	if (count>0 || id==0){
		return false;
	} return true;
}

function changeAltTitleAttr(obj,type,ctx){
  var opt = {"view":"Ver","edit":"Editar","print":"Imprimir","approve":"Aprobar","inactivate":"Inactivar","close":"Finalizar","cancel_close":"Cancelar Finalizacion"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
	  if (getCurVal()!=""){
		obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
		obj.title = opt[type]+" "+ctx+" #"+getCurVal();
	  }
	}else{
	  document.getElementById("printImg").alt = "Imprimir Lista Solicitud";
	  document.getElementById("editImg").alt = "Seleccione un Solicitud a Editar";
	  document.getElementById("viewImg").alt = "Seleccione un Solicitud a Ver";
	  document.getElementById("appImg").alt = "Aprobar Solicitud";
	  document.getElementById("inacImg").alt = "Inactivar Solicitud";
	  document.getElementById("cerrarImg").alt = "Cerrar Solicitud";
	  document.getElementById("printImg").title = "Imprimir Lista Solicitud";
	  document.getElementById("editImg").title = "Seleccione una Solicitud a Editar";
	  document.getElementById("viewImg").title = "Seleccione una Solicitud a Ver";
	  document.getElementById("appImg").title = "Aprobar Solicitud";
	  document.getElementById("inacImg").title = "Inactivar Solicitud";
	  document.getElementById("cerrarImg").title = "Cerrar Solicitud";
	  document.getElementById("print_contractImg").title = "Imprimir Contrato";
	  document.getElementById("pay_adjust").title = "Editar Num. Pagos";
	}
}

function showAud(id){
	showPopWin('../planmedico/bitacora.jsp?audTable=tbl_pm_solicitud_contrato&audFilter=id&aud_value_filter='+id+'&audCollapsed=n',winWidth*.95,_contentHeight*.75,null,null,'');
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
			<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nueva Solicitud" title="Registrar Nueva Solicitud" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Solicitud')" width="32px" height="32px" id="editImg"/>
			</authtype>&nbsp;
			<authtype type='1'>
			<img src="../images/ver.png" onClick="javascript:manageSurvey('view')" onMouseOver="javascript:changeAltTitleAttr(this,'view','Solicitud')" width="32px" height="32px" id="viewImg"/>
			</authtype>&nbsp;
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manageSurvey('print')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Solicitud')" id="printImg"/>
			</authtype>
			<authtype type='6'>
			<img src="../images/check.gif" onClick="javascript:manageSurvey('approve')" onMouseOver="javascript:changeAltTitleAttr(this,'approve','Solicitud')" id="appImg" height="30" width="30"/>
			</authtype>
			<authtype type='7'>
			<img src="../images/cancel.gif" onClick="javascript:manageSurvey('inactivate')" onMouseOver="javascript:changeAltTitleAttr(this,'inactivate','Solicitud')" id="inacImg" height="30" width="30"/>
			</authtype>
			<authtype type='53'>
			<img src="../images/lockrefresh.png" onClick="javascript:manageSurvey('cancel_close')" onMouseOver="javascript:changeAltTitleAttr(this,'cancel_close','Solicitud')" id="cerrarImg" height="30" width="30"/>
			</authtype>
			<authtype type='50'>
			<img src="../images/lock_circle.png" onClick="javascript:manageSurvey('close')" onMouseOver="javascript:changeAltTitleAttr(this,'close','Solicitud')" id="cerrarImg" height="30" width="30"/>
			</authtype>
            <authtype type='51'>
			<img src="../images/print_contract.png" onClick="javascript:manageSurvey('print_contract')" onMouseOver="javascript:changeAltTitleAttr(this,'print_contract','Imprimir Contrato')" id="print_contractImg" height="30" width="30"/>
			</authtype>
            <authtype type='52'>
			<img src="../images/payment_adjust.gif" onClick="javascript:manageSurvey('edit_pagos')" onMouseOver="javascript:changeAltTitleAttr(this,'edit_pagos','Editar Num. Pagos')" id="pay_adjust" height="30" width="30"/>
			</authtype>
		</td>
	</tr>
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">&nbsp;<cellbytelabel id="2">Fecha Inicia Plan</cellbytelabel>&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_ini_plan_f" />
			<jsp:param name="valueOfTBox1" value="<%=fecha_ini_plan_f%>" />
			<jsp:param name="nameOfTBox2" value="fecha_ini_plan_t" />
			<jsp:param name="valueOfTBox2" value="<%=fecha_ini_plan_t%>" />
			</jsp:include>
			&nbsp;<cellbytelabel>Cuota</cellbytelabel>&nbsp;
			<select id="cm_oper" name="cm_oper" size="0" class="Text12">
				<option value = ">" <%=(cm_oper.equals(">")?"selected":"")%>>&gt;</option>
				<option value = ">=" <%=(cm_oper.equals(">=")?"selected":"")%>>&gt;=</option>
				<option value = "=" <%=(cm_oper.equals("=")?"selected":"")%>>=</option>
				<option value = "<=" <%=(cm_oper.equals("<=")?"selected":"")%>>&lt;=</option>
				<option value = "<" <%=(cm_oper.equals("<")?"selected":"")%>>&lt;</option>
			</select>
			<%=fb.decBox("cuota_mensual", cuota_mensual, false, false, false, 5, 12.2, "text12", "", "", "", false, "", "")%>
			&nbsp;<cellbytelabel>Afiliados</cellbytelabel>&nbsp;
			<%if(cuota.equals("SF")){%>
			<%=fb.select("afiliados","1=1 - 2 Afiliados,2=3 - 4 Afiliados, 3 = 5 y mas Afiliados",afiliados,"T")%>
			<%} else if(cuota.equals("SFE")){%>
			<%=fb.select("afiliados","1=PLAN FAMILIAR,2=PLAN TERCERA EDAD", afiliados, "T")%>
			<%}%>
			En Transici&oacute;n:
			<%=fb.select("en_transicion","S=SI,N=NO", en_transicion, "T")%>
			<br><br>
            &nbsp;<cellbytelabel>Tipo Plan</cellbytelabel>&nbsp;
			<%=fb.select("tipo_plan","I=Interno,O=Acerta",tipoPlan,"T")%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,I=Inactivo,P=Pendiente, F=Finalizado",estado,"T")%>
			No. Contrato:
			<%=fb.intBox("id",id,false,false,false,5,10,"",null,null)%>
            Cliente: <%=fb.textBox("nombre_cliente",nombreCliente,false,false,false,40,100,"",null,null)%>
			Fecha Fin:
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_fin_plan_f" />
			<jsp:param name="valueOfTBox1" value="<%=fecha_fin_plan_f%>" />
			<jsp:param name="nameOfTBox2" value="fecha_fin_plan_t" />
			<jsp:param name="valueOfTBox2" value="<%=fecha_fin_plan_t%>" />
			</jsp:include>

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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_t)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo_plan", tipoPlan)%>
				<%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("en_transicion",en_transicion)%>
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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_t)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("tipo_plan", tipoPlan)%>
                <%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("en_transicion",en_transicion)%>
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
		<td width="10%">&nbsp;<cellbytelabel>Contrato</cellbytelabel></td>
		<td width="20%">&nbsp;<cellbytelabel>Responsable</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Plan</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Cuota Mensual</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Fecha Inicio</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fecha Fin</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Usuario Crea</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Usuario Fin</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
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
					<td align="center" onClick="javscript:showAud(<%=cdo.getColValue("id")%>);">&nbsp;<%=cdo.getColValue("id")%></td>
					<td><%=cdo.getColValue("responsable")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("afiliados_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("cuota_mensual")%></td>
					<td align="center" <%if(cdo.getColValue("estado").equals("F")){%>title="<%=cdo.getColValue("motivo_fin_plan")%>"<%}%> >&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_ini_plan")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_fin_plan")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_fin_plan")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id")+","+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("no_contrato"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("clientId"+i,cdo.getColValue("id_cliente"))%>
				<%=fb.hidden("tipo_plan"+i,cdo.getColValue("afiliados"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("ident_responsable"+i,cdo.getColValue("ident_responsable"))%>
				<%=fb.hidden("name_responsable"+i,cdo.getColValue("responsable"))%>
				<%=fb.hidden("fecha_ini_plan"+i,cdo.getColValue("fecha_ini_plan"))%>
				<%=fb.hidden("fecha_fin_plan"+i,cdo.getColValue("fecha_fin_plan"))%>
				<%=fb.hidden("cont_benef"+i,cdo.getColValue("cont_benef"))%>
				<%=fb.hidden("num_pagos"+i,cdo.getColValue("num_pagos"))%>
				<%
				}
				%>
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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_t)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("tipo_plan", tipoPlan)%>
                <%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("en_transicion",en_transicion)%>
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
				<%=fb.hidden("fecha_ini_plan_f",fecha_ini_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_ini_plan_t)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_f)%>
				<%=fb.hidden("fecha_ini_plan_t",fecha_fin_plan_t)%>
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("tipo_plan", tipoPlan)%>
                <%=fb.hidden("nombre_cliente",nombreCliente)%>
				<%=fb.hidden("en_transicion",en_transicion)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>