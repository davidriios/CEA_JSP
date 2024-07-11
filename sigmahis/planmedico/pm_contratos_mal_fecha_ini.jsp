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

int iconHeight = 32;
int iconWidth = 32;
	
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
	
	sbSql.append("	afiliados_desc, (select decode (tipo_id_paciente, 'P', pasaporte, provincia || '-' || sigla || '-' || tomo || '-' || asiento) || '-' || d_cedula from tbl_pm_cliente b where b.codigo = a.id_cliente) ident_responsable, (select count(*) cont_benef from tbl_pm_sol_contrato_det d where d.id_solicitud = a.id) cont_benef, to_char(fecha_fin_plan, 'dd/mm/yyyy') fecha_fin_plan, a.usuario_fin_plan, nvl(a.num_pagos, 0) num_pagos, to_char((select min(fecha) from tbl_pm_factura ff where ff.id_sol_contrato = a.id and ff.estado = 'A' and nvl(ff.observacion, 'NA') != 'S/I'), 'dd/mm/yyyy') primera_factura, NVL((select count(*) from tbl_pm_solicitud_contrato sc where sc.id_cliente = a.id_cliente and sc.estado in('A','F')), 0) num_cont_resp from tbl_pm_solicitud_contrato a where exists (select null from tbl_pm_factura f where f.id_sol_contrato = a.id and f.fecha < a.fecha_ini_plan and f.estado = 'A' and nvl(a.observacion, 'NA') != 'S/I')");
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

function doAction(){}

function printEC(){
  if (getCurClientId() != "") {
		var k=document.form00.index.value;
		var clientName=clientId=eval('document.form00.clientName'+k).value;
		var num_cont_resp=clientId=eval('document.form00.num_cont_resp'+k).value;
		var contratos=clientId=eval('document.form00.no_contrato'+k).value;
		if(num_cont_resp>0) abrir_ventana('../planmedico/print_estado_cuenta.jsp?clientId='+getCurClientId()+'&clientName='+clientName+'&contrato='+contratos);
		else alert('El estado de cuenta es solo para clientes Responsables de Contratos!.');
	}	
  
}
function printExcel(){
  if (getCurClientId() != "") {
		var k=document.form00.index.value;
		var clientName=clientId=eval('document.form00.clientName'+k).value;
		var num_cont_resp=clientId=eval('document.form00.num_cont_resp'+k).value;
		var contratos=clientId=eval('document.form00.no_contrato'+k).value;
		if(num_cont_resp>0) abrir_ventana('../planmedico/rpt_print_estado_cuenta.jsp?codigo='+getCurClientId()+'&clientName='+clientName+'&contrato='+contratos);
		else alert('El estado de cuenta es solo para clientes Responsables de Contratos!.');
	}	
  
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Crear Nuevo Cliente';break;
		case 1:msg='Editar Cliente'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 2:msg='Imprimir Listado'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 3:msg='Ver Cliente'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 4:msg='Imprimir Estado de Cuenta'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 5:msg='Asignar PAC_ID' +(getCurClientId()!=""?" #"+getCurClientId():"");break;
		case 6:msg='Imprimir Estado de Cuenta Excel'+(getCurClientId()!=""?" #"+getCurClientId():"");break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}

function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}
function getCurClientId(){return document.getElementById("cClientId").value;}
function setIndex(k){document.form00.index.value=k;checkOne('form00','check',<%=al.size()%>,eval('document.form00.check'+k),0);
document.getElementById("cClientId").value=eval('document.form00.clientId'+k).value;}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='50'><a href="javascript:printEC()"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/imprimir_analisis.png"  onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" ></a></authtype>
		<authtype type='53'><a href="javascript:printExcel()"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/imprimir_analisis.png"  onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" ></a></authtype>
	</td>
</tr>
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
		<td width="6%"><cellbytelabel>Primera Factura</cellbytelabel></td>
		<td width="6%"><cellbytelabel>Fecha Fin</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Usuario Crea</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Usuario Fin</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%=fb.hidden("cClientId","")%>
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
					<td align="center">&nbsp;<%=cdo.getColValue("afiliados_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("cuota_mensual")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_ini_plan")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("primera_factura")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_fin_plan")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_fin_plan")%></td>
					<td align="center">
					  <%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%>
					</td>
				</tr>
				<%=fb.hidden("no_contrato"+i,cdo.getColValue("id"))%>
				<%=fb.hidden("clientId"+i,cdo.getColValue("id_cliente"))%>
				<%=fb.hidden("tipo_plan"+i,cdo.getColValue("afiliados"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("ident_responsable"+i,cdo.getColValue("ident_responsable"))%>
				<%=fb.hidden("name_responsable"+i,cdo.getColValue("responsable"))%>
				<%=fb.hidden("fecha_ini_plan"+i,cdo.getColValue("fecha_ini_plan"))%>
				<%=fb.hidden("primera_factura"+i,cdo.getColValue("primera_factura"))%>
				<%=fb.hidden("fecha_fin_plan"+i,cdo.getColValue("fecha_fin_plan"))%>
				<%=fb.hidden("cont_benef"+i,cdo.getColValue("cont_benef"))%>
				<%=fb.hidden("num_pagos"+i,cdo.getColValue("num_pagos"))%>
				<%=fb.hidden("clientName"+i,cdo.getColValue("nombre")+" "+cdo.getColValue("apellido"))%>
		<%=fb.hidden("num_cont_resp"+i,cdo.getColValue("num_cont_resp"))%>
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