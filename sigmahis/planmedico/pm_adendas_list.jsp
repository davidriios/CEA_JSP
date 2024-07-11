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
String fecha_ini_plan_f = "", fecha_ini_plan_t = "";
String afiliados = "", estado="P", cuota_mensual="", cm_oper="", id_motivo = "";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

String contrato = "", nombre = "", identificacion = "";
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
	if(request.getParameter("afiliados")!=null) afiliados = request.getParameter("afiliados");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(request.getParameter("cuota_mensual")!=null) cuota_mensual = request.getParameter("cuota_mensual");
	if(request.getParameter("cm_oper")!=null) cm_oper = request.getParameter("cm_oper");
	if(request.getParameter("contrato")!=null) contrato = request.getParameter("contrato");
	if(request.getParameter("nombre")!=null) nombre = request.getParameter("nombre");
	if(request.getParameter("id_motivo")!=null) id_motivo = request.getParameter("id_motivo");


	sbSql = new StringBuffer();
	sbSql.append("select b.estado, b.id, b.id_cliente, b.afiliados, to_char(b.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, b.cuota_mensual, to_char(b.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(b.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, b.usuario_creacion, b.usuario_modificacion, b.observacion, decode(b.estado, 'P', 'Pendiente', 'A', 'Aprobado', 'I', 'Inactivo', 'R', 'Ejecutado') estado_desc, (select p.primer_nombre||decode(p.segundo_nombre,null,' ',' '||p.segundo_nombre) ||' '|| p.primer_apellido||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) from tbl_pm_cliente p where p.codigo = b.id_cliente) responsable, ");
	if(cuota.equals("SF")) sbSql.append("(select descripcion from tbl_pm_afiliado c where id = a.afiliados)");
	else if(cuota.equals("SFE")) sbSql.append("decode (a.afiliados, 1, 'PLAN FAMILIAR', 2, 'PLAN TERCERA EDAD', a.afiliados)");
	
	sbSql.append(" afiliados_desc, (select decode (tipo_id_paciente, 'P', pasaporte, provincia || '-' || sigla || '-' || tomo || '-' || asiento) || '-' || d_cedula from tbl_pm_cliente cc where cc.codigo = b.id_cliente) ident_responsable, a.id id_solicitud, to_char(b.fecha_inicio, 'dd/mm/yyyy') fecha_inicio, b.afiliados tipo_plan from tbl_pm_solicitud_contrato a, tbl_pm_adenda b where a.id = b.id_solicitud ");
	if(!fecha_ini_plan_f.equals("")){
		sbSql.append(" and b.fecha_ini_plan >= to_date('");
		sbSql.append(fecha_ini_plan_f);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_ini_plan_t.equals("")){
		sbSql.append(" and b.fecha_ini_plan <= to_date('");
		sbSql.append(fecha_ini_plan_t);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!afiliados.equals("")){
		sbSql.append(" and b.afiliados = ");
		sbSql.append(afiliados);
	}
	if(!estado.equals("")){
		sbSql.append(" and b.estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!cuota_mensual.equals("")){
		sbSql.append(" and b.cuota_mensual ");
		sbSql.append(cm_oper);
		sbSql.append(cuota_mensual);
	}
	if(!contrato.equals("")){
		sbSql.append(" and a.id = ");
		sbSql.append(contrato);
	}	
	if(!id_motivo.equals("")){
		sbSql.append(" and b.id_motivo = ");
		sbSql.append(id_motivo);
	}
	
	if(!nombre.equals("")){
		sbSql.append(" and exists (select null from vw_pm_cliente c where c.codigo = a.id_cliente and c.nombre_paciente like '%");
		sbSql.append(nombre.toUpperCase());
		sbSql.append("%')");
	}
	sbSql.append(" order by b.fecha_creacion desc ");
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
   if (typeof option == "undefined") abrir_ventana('../planmedico/reg_solicitud.jsp?fp=adenda');
   else if(option=='view'){
		 var ind = document.getElementById("curIndex").value;
		 var estado = document.getElementById("estado"+ind).value;
    if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else 
		 abrir_ventana('../planmedico/reg_solicitud.jsp?fp=adenda&mode=view&id='+getCurVal());
	   
   }else if(option=='edit'){
		 var ind = document.getElementById("curIndex").value;
		 var estado = document.getElementById("estado"+ind).value;
    if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else 
		 if(estado=='P') abrir_ventana('../planmedico/reg_solicitud.jsp?fp=adenda&mode=edit&id='+getCurVal());
	   else alert('Solo se pueden editar Adendas Pendientes!');
   }
   else if(option=='print'){
      if (getCurVal() != ""){
        var ind = document.getElementById("curIndex").value;
        var clientId = document.getElementById("clientId"+ind).value;
         abrir_ventana('../planmedico/print_pm_sol_plan.jsp?fp=adenda&fg=responsable&id='+getCurVal()+'&clientId='+clientId);
      }else{
        abrir_ventana('../planmedico/print_pm_sol_plan_list.jsp?fechaIniPlanFrom=<%=fecha_ini_plan_f%>&fechaIniPlanTo=<%=fecha_ini_plan_t%>&afiliados=<%=afiliados%>&estado=<%=estado%>&cuotaMensual=<%=cuota_mensual%>&cmOper=<%=cm_oper%>');
      }
   } else if(option=='approve'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
       var estado = document.getElementById("estado"+ind).value;
			 if(estado=='I') alert('La adenda está inactiva y no se puede aprobar!');
			 else if(estado=='R') alert('La adenda ya está aprobada!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=3&docId='+getCurVal()+'&extDesc='+name_responsable+' '+ident_responsable,winWidth*.95,_contentHeight*.75,null,null,'');
		}
	 } else if(option=='inactivate'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
       var ident_responsable = document.getElementById("ident_responsable"+ind).value;
       var name_responsable = document.getElementById("name_responsable"+ind).value;
			 var estado = document.getElementById("estado"+ind).value;
			 if(estado=='I') alert('La adenda ya está inactiva!');
			 else if(estado=='A') alert('La adenda está aprobada y no se puede inactivar!');
			else showPopWin('../common/run_process.jsp?fp=solicitud_pm&docType=APP_PM&actType=4&docId='+getCurVal()+'&extDesc='+name_responsable+' '+ident_responsable,winWidth*.95,_contentHeight*.45,null,null,'');
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
  var opt = {"edit":"Editar","print":"Imprimir","approve":"Aprobar","inactivate":"Inactivar","view":"Ver"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
	  if (getCurVal()!=""){
		obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
		obj.title = opt[type]+" "+ctx+" #"+getCurVal();
	  }
	}else{
	  document.getElementById("printImg").alt = "Imprimir Lista Solicitud";
	  document.getElementById("editImg").alt = "Seleccione un Solicitud a Editar";
	  document.getElementById("appImg").alt = "Aprobar Solicitud";
	  document.getElementById("inacImg").alt = "Inactivar Solicitud";
	  document.getElementById("printImg").title = "Imprimir Lista Solicitud";
	  document.getElementById("editImg").title = "Seleccione una Solicitud a Editar";
	  document.getElementById("appImg").title = "Aprobar Solicitud";
	  document.getElementById("inacImg").title = "Inactivar Solicitud";
	  document.getElementById("viewImg").title = "Ver Solicitud";
	  document.getElementById("print_contractImg").title = "Imprimir Contrato";
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
			<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nueva Solicitud" title="Registrar Nueva Solicitud" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Solicitud')" width="32px" height="32px" id="editImg"/>
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
			<authtype type='7'>
			<img src="../images/search.gif" onClick="javascript:manageSurvey('view')" onMouseOver="javascript:changeAltTitleAttr(this,'view','Solicitud')" id="viewImg" height="30" width="30"/>
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
			<td colspan="2">&nbsp;<cellbytelabel id="2">Fecha Inicia Plan</cellbytelabel>&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_ini_plan_f" />
			<jsp:param name="valueOfTBox1" value="<%=fecha_ini_plan_f%>" />
			<jsp:param name="nameOfTBox2" value="fecha_ini_plan_t" />
			<jsp:param name="valueOfTBox2" value="<%=fecha_ini_plan_t%>" />
			</jsp:include>
			&nbsp;<cellbytelabel>Cuota Mensual</cellbytelabel>&nbsp;
			<select id="cm_oper" name="cm_oper" size="0" class="Text12">
				<option value = ">" <%=(cm_oper.equals(">")?"selected":"")%>>&gt;</option>
				<option value = ">=" <%=(cm_oper.equals(">=")?"selected":"")%>>&gt;=</option>
				<option value = "=" <%=(cm_oper.equals("=")?"selected":"")%>>=</option>
				<option value = "<=" <%=(cm_oper.equals("<=")?"selected":"")%>>&lt;=</option>
				<option value = "<" <%=(cm_oper.equals("<")?"selected":"")%>>&lt;</option>
			</select>
			<%=fb.decBox("cuota_mensual", cuota_mensual, false, false, false, 12, 12.2, "text12", "", "", "", false, "", "")%>
			&nbsp;<cellbytelabel>Afiliados</cellbytelabel>&nbsp;
			<%if(cuota.equals("SF")){%>
			<%=fb.select("afiliados","1=1 - 2 Afiliados,2=3 - 4 Afiliados, 3 = 5 y mas Afiliados",afiliados,"T")%>
			<%} else if(cuota.equals("SFE")){%>
			<%=fb.select("afiliados","1=PLAN FAMILIAR,2=PLAN TERCERA EDAD", afiliados, "T")%>
			<%}%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Activo,I=Inactivo,P=Pendiente,R=Ejecutado",estado,"T")%>
			<br>
			Contrato:
			<%=fb.textBox("contrato",contrato,false,false,false,10,10)%>
			Nombre:
			<%=fb.textBox("nombre",nombre,false,false,false,40,100)%>
			Motivo:
			<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_pm_motivo_adenda where estado='A' order by 2 asc","id_motivo",id_motivo,false,false,0,"Text10",null,"onChange='javascript:changePlan(this.value);'",null,"S")%>
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
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("id_motivo",id_motivo)%>
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
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("id_motivo",id_motivo)%>
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
		<td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="10%">&nbsp;<cellbytelabel>No. Contrato</cellbytelabel></td>
		<td width="20%">&nbsp;<cellbytelabel>Responsable</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Plan</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Cuota Mensual</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Usuario Crea</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Fecha Inicio</cellbytelabel></td>
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
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("id_solicitud")%></td>
					<td><%=cdo.getColValue("responsable")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("afiliados_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("cuota_mensual")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_inicio")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id")+","+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("clientId"+i,cdo.getColValue("id_cliente"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("ident_responsable"+i,cdo.getColValue("ident_responsable"))%>
				<%=fb.hidden("name_responsable"+i,cdo.getColValue("responsable"))%>
				<%=fb.hidden("tipo_plan"+i,cdo.getColValue("tipo_plan"))%>
				<%=fb.hidden("id_solicitud"+i,cdo.getColValue("id_solicitud"))%>
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
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("id_motivo",id_motivo)%>
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
				<%=fb.hidden("afiliados",afiliados)%>
				<%=fb.hidden("cuota_mensual",cuota_mensual)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("id_motivo",id_motivo)%>
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