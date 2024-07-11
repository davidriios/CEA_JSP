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
String monto = "";
String fecha_inicio = "", estado="", id_solicitud="", responsable = "", id = "", tipo_cuota = "";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

if(request.getMethod().equalsIgnoreCase("GET"))
{
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

	if(request.getParameter("monto")!=null) monto = request.getParameter("monto");
	if(request.getParameter("fecha_inicio")!=null) fecha_inicio = request.getParameter("fecha_inicio");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(request.getParameter("id_solicitud")!=null) id_solicitud = request.getParameter("id_solicitud");
	if(request.getParameter("responsable")!=null) responsable = request.getParameter("responsable");
	if(request.getParameter("id")!=null) id = request.getParameter("id");
	if(request.getParameter("tipo_cuota")!=null) tipo_cuota = request.getParameter("tipo_cuota");
	sbSql.append("select id, id_solicitud, id_beneficiario, monto, to_char(fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_modificacion, to_char(fecha_aprobacion, 'dd/mm/yyyy') fecha_aprobacion, usuario_aprobacion, estado, observacion, decode(estado, 'P', 'Pendiente', 'A', 'Aprobado', 'I', 'Inactivo', 'F', 'Ejecutada') estado_desc, (select nombre_paciente from vw_pm_cliente c where exists (select null from tbl_pm_solicitud_contrato sc where sc.id_cliente = c.codigo and sc.id = e.id_solicitud)) responsable, decode(nvl(e.tipo_cuota, 'N'), 'N', 'Normal', 'Penalizacion') tipo_cuota, nvl(porcentaje, 0) porcentaje, to_char(fecha_finaliza, 'dd/mm/yyyy') fecha_finaliza, (select afiliados from tbl_pm_solicitud_contrato sc where sc.id = e.id_solicitud) tipo_plan from tbl_pm_cuota_extra e where 1=1 ");
	if(!monto.equals("")){
		sbSql.append(" and monto = ");
		sbSql.append(monto);
	}
	if(!fecha_inicio.equals("")){
		sbSql.append(" and fecha_inicio = to_date('");
		sbSql.append(fecha_inicio.trim());
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}		
	if(!tipo_cuota.equals("")){
		sbSql.append(" and tipo_cuota = '");
		sbSql.append(tipo_cuota);
		sbSql.append("'");
	}	
	if(!id_solicitud.equals("")){
		sbSql.append(" and id_solicitud = ");
		sbSql.append(id_solicitud);
	}
	if(!id.equals("")){
		sbSql.append(" and id = ");
		sbSql.append(id);
	}
	if(!responsable.equals("")){
		sbSql.append(" and exists (select null from tbl_pm_solicitud_contrato sc where sc.id = e.id_solicitud and exists (select null from vw_pm_cliente pc where pc.codigo = sc.id_cliente and pc.nombre_paciente like '%");
		sbSql.append(responsable);
		sbSql.append("%'))");
	}	
	sbSql.append(" order by id desc nulls last ");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");

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
	if (typeof option == "undefined") abrir_ventana('../planmedico/pm_cuota_extra_config.jsp');
	else if(option=='edit'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			var estado = document.getElementById("estado"+ind).value;
			if(estado=='P')	 abrir_ventana('../planmedico/pm_cuota_extra_config.jsp?mode=edit&id='+getCurVal());
			else alert('Solo se pueden editar Cuotas Extraordinarias Pendientes!');
		}
	} else if(option=='approve'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			//var ident_responsable = document.getElementById("ident_responsable"+ind).value;
			//var name_responsable = document.getElementById("name_responsable"+ind).value;
			var fecha_ini_plan = document.getElementById("fecha_inicio"+ind).value;
			var estado = document.getElementById("estado"+ind).value;
			if(estado=='I') alert('La Cuota está inactiva y no se puede aprobar!');
			else if(estado=='A') alert('La Cuota ya está aprobada!');
			else if(estado=='F') alert('La Cuota ya está ejecutada!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=5&docId='+getCurVal()+'&fecha='+fecha_ini_plan,winWidth*.95,_contentHeight*.55,null,null,'');
		}
	} else if(option=='inactivate'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			//var ident_responsable = document.getElementById("ident_responsable"+ind).value;
			//var name_responsable = document.getElementById("name_responsable"+ind).value;
			var estado = document.getElementById("estado"+ind).value;
			if(estado=='I') alert('La Solicitud ya está inactiva!');
			else if(estado=='A') alert('La Solicitud está aprobada y no se puede inactivar!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=6&docId='+getCurVal(),winWidth*.95,_contentHeight*.75,null,null,'');
		}
	}else if(option=='finalize'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			 var estado = document.getElementById("estado"+ind).value;
			 if(estado!='F') alert('Solo las Cuotas Ejecutadas se pueden Finalizar!');
			else if(estado == 'F') showPopWin('../process/pm_run_inactiva_cuota_extra.jsp?fp=solicitud_pm&id_cuota='+getCurVal(),winWidth*.95,_contentHeight*.75,null,null,'');
	}
	} else if(option=='print_contract'){
		if (getCurVal() == "") CBMSG.warning("Por favor seleccione uno para poder seguir!");
		else {
         var i = document.getElementById("curIndex").value;
         var idClie = document.getElementById("clientId"+i).value;
         var tipoPlan = document.getElementById("tipo_plan"+i).value;
         var noContrato = document.getElementById("id_solicitud"+i).value;
         if (tipoPlan == '1') abrir_ventana("../planmedico/print_contrato_familiar.jsp?cod_ben="+idClie+"&no_contrato="+noContrato+"&no_secuencia=0&fp=ce&id_cuota="+getCurVal());
         else abrir_ventana("../planmedico/print_contrato_tercera_edad.jsp?cod_ben="+idClie+"&no_contrato="+noContrato+"&no_secuencia=0&fp=ce&id_cuota="+getCurVal());
        }
	}
}

function changeAltTitleAttr(obj,type,ctx){
  var opt = {"edit":"Editar","print":"Imprimir","inactivate":"Inactivar","approve":"Aprobar","finalize":"Finalizar"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
		if (getCurVal()!=""){
			obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
			obj.title = opt[type]+" "+ctx+" #"+getCurVal();
		}
	}else{
		if(document.getElementById("printImg"))document.getElementById("printImg").alt = "Imprimir Lista Cuotas";
		document.getElementById("editImg").alt = "Seleccione una Cuota a Editar";
		document.getElementById("appImg").alt = "Aprobar Cuota";
		document.getElementById("inacImg").alt = "Inactivar Cuota";

		if(document.getElementById("printImg"))document.getElementById("printImg").title = "Imprimir Lista Cuotas";
		document.getElementById("editImg").title = "Seleccione una Cuota a Editar";
		document.getElementById("appImg").title = "Aprobar Cuota";
		document.getElementById("inacImg").title = "Inactivar Cuota";
	  document.getElementById("cerrarImg").title = "Finalizar Cuota";
	  document.getElementById("print_contractImg").title = "Imprimir Contrato";
	}
}

function getCurVal(){return document.getElementById("curVal").value;}
function setId(curVal,curIndex){document.getElementById("curVal").value = curVal;
document.getElementById("curIndex").value = curIndex;}

function printList(){
	var monto = document.search01.monto.value||'ALL';
	var estado = document.search01.estado.value||'ALL';
	var fecha_inicio = document.search01.fecha_inicio.value||'ALL';
	var responsable = document.search01.responsable.value||'ALL';
	var id_solicitud = document.search01.id_solicitud.value||'ALL';
	var id = document.search01.id.value||'ALL';
	var tipo_cuota = document.search01.tipo_cuota.value||'ALL';
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_list_cuota_extra.rptdesign&montoParam='+monto+'&estadoParam='+estado+'&fechaParam='+fecha_inicio+'&responsableParam='+responsable+'&contratoParam='+id_solicitud+'&idCuotaParam='+id+'&tipoCuotaParam='+tipo_cuota);
}
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
			<img src="../images/add_survey.png" alt="Registrar Nueva Cuota" title="Registrar Nueva Cuota" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" width="32px" height="32px" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Empresa')" id="editImg"/>
			</authtype>&nbsp;
			<!--<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manageSurvey('print')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Empresa')" id="printImg"/>
			</authtype>-->
			<authtype type='6'>
			<img src="../images/check.gif" onClick="javascript:manageSurvey('approve')" onMouseOver="javascript:changeAltTitleAttr(this,'approve','Cuota')" id="appImg" height="30" width="30"/>
			</authtype>
			
			<authtype type='7'>
			<img src="../images/cancel.gif" onClick="javascript:manageSurvey('inactivate')" onMouseOver="javascript:changeAltTitleAttr(this,'inactivate','Cuota')" id="inacImg" height="30" width="30"/>
			</authtype>
			<authtype type='50'>
			<img src="../images/lock_circle.png" onClick="javascript:manageSurvey('finalize')" onMouseOver="javascript:changeAltTitleAttr(this,'close','CUota')" id="cerrarImg" height="30" width="30"/>
			</authtype>			
            <authtype type='51'>
			<img src="../images/print_contract.png" onClick="javascript:manageSurvey('print_contract')" onMouseOver="javascript:changeAltTitleAttr(this,'print_contract','Imprimir Contrato')" id="print_contractImg" height="30" width="30"/>
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
		<td colspan="2">&nbsp;<cellbytelabel id="2">Monto:</cellbytelabel>&nbsp;
			<%=fb.decBox("monto",monto,false,false,false,20,10.2)%>
			&nbsp;<cellbytelabel>Estado:</cellbytelabel>&nbsp;
			<%=fb.select("estado","P=Pendiente,A=Aprobado,I=Inactivo, F=Ejecutada",estado,"T")%>
			&nbsp;<cellbytelabel>Fecha Inicio:</cellbytelabel>&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1"/>
			<jsp:param name="nameOfTBox1" value="fecha_inicio"/>
			<jsp:param name="valueOfTBox1" value="<%=fecha_inicio%>"/>
			<jsp:param name="fieldClass" value="Text10"/>
			<jsp:param name="buttonClass" value="Text10"/>
			<jsp:param name="clearOption" value="true"/>
			</jsp:include>
			Contrato:
			<%=fb.textBox("id_solicitud",id_solicitud,false,false,false,10,"Text10",null,null)%>
			Responsable:
			<%=fb.textBox("responsable",responsable,false,false,false,10,"Text10",null,null)%>
			No. Cuota Extra.:
			<%=fb.textBox("id",id,false,false,false,10,"Text10",null,null)%>
			Tipo Cuota:
			<%=fb.select("tipo_cuota","P=Penalizacion,N=Normal",tipo_cuota,"T")%>
			<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
		</td>
	</tr>
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
				<%=fb.hidden("monto",monto)%>
				<%=fb.hidden("fecha_inicio",fecha_inicio)%>
				<%=fb.hidden("id_solicitud",id_solicitud)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("responsable",responsable)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("tipo_cuota",tipo_cuota)%>
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
				<%=fb.hidden("monto",monto)%>
				<%=fb.hidden("fecha_inicio",fecha_inicio)%>
				<%=fb.hidden("id_solicitud",id_solicitud)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("responsable",responsable)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("tipo_cuota",tipo_cuota)%>
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
		<td width="8%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="8%">&nbsp;<cellbytelabel>Id. Solicitud</cellbytelabel></td>
		<td width="16%">&nbsp;<cellbytelabel>Responsable</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Fecha Inicio</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Monto</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Usuario Crea</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Fecha Crea</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Tipo</cellbytelabel></td>
		<td width="5%"><cellbytelabel>%</cellbytelabel></td>
		<td width="8%"><cellbytelabel>Fecha Fin.</cellbytelabel></td>
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
				<%=fb.hidden("fecha_inicio"+i,cdo.getColValue("fecha_inicio"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("tipo_plan"+i,cdo.getColValue("tipo_plan"))%>
				<%=fb.hidden("clientId"+i,cdo.getColValue("id_beneficiario"))%>
				<%=fb.hidden("id_solicitud"+i,cdo.getColValue("id_solicitud"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td align = "center"><%=cdo.getColValue("id_solicitud")%></td>
					<td><%=cdo.getColValue("responsable")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_inicio")%></td>
					<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("tipo_cuota")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("porcentaje")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_finaliza")%></td>
					<td align="center">
						<%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id")+","+i+")\"")%>
					</td>
				</tr>
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
				<%=fb.hidden("monto",monto)%>
				<%=fb.hidden("fecha_inicio",fecha_inicio)%>
				<%=fb.hidden("id_solicitud",id_solicitud)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("responsable",responsable)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("tipo_cuota",tipo_cuota)%>
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
				<%=fb.hidden("monto",monto)%>
				<%=fb.hidden("fecha_inicio",fecha_inicio)%>
				<%=fb.hidden("id_solicitud",id_solicitud)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("responsable",responsable)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("tipo_cuota",tipo_cuota)%>
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