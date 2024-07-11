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
String afiliados = "", estado="", cuota_mensual="", cm_oper="";
String contrato = "", nombre = "", identificacion = "", id_motivo = "";
String fp=request.getParameter("fp");
String fg=request.getParameter("fg");
if(fp==null)fp="";
if(fg==null)fg="";
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

  if(request.getParameter("fecha_ini_plan_f")!=null) fecha_ini_plan_f = request.getParameter("fecha_ini_plan_f");
	if(request.getParameter("fecha_ini_plan_t")!=null) fecha_ini_plan_t = request.getParameter("fecha_ini_plan_t");
	if(request.getParameter("afiliados")!=null) afiliados = request.getParameter("afiliados");
	if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(request.getParameter("cuota_mensual")!=null) cuota_mensual = request.getParameter("cuota_mensual");
	if(request.getParameter("cm_oper")!=null) cm_oper = request.getParameter("cm_oper");
	if(request.getParameter("contrato")!=null) contrato = request.getParameter("contrato");
	if(request.getParameter("nombre")!=null) nombre = request.getParameter("nombre");
	if(request.getParameter("identificacion")!=null) identificacion = request.getParameter("identificacion");
	if(request.getParameter("id_motivo")!=null) id_motivo = request.getParameter("id_motivo");

	sbSql.append("select estado, id, id_cliente, cobertura_mi, cobertura_cy, cobertura_hi, cobertura_ot, afiliados, forma_pago, to_char(fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, cuota_mensual, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, usuario_creacion, usuario_modificacion, observacion, decode(estado, 'P', 'Pendiente', 'A', 'Aprobado', 'I', 'Inactivo') estado_desc, (select b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre) ||' '|| b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) from tbl_pm_cliente b where b.codigo = a.id_cliente) responsable, (select descripcion from tbl_pm_afiliado c where id = a.afiliados) afiliados_desc, (select decode (tipo_id_paciente, 'P', pasaporte, provincia || '-' || sigla || '-' || tomo || '-' || asiento) || '-' || d_cedula from tbl_pm_cliente b where b.codigo = a.id_cliente) ident_responsable, nvl((select count(*) from tbl_pm_adenda ad where ad.id_solicitud = a.id and ad.estado = 'P'), 0) adendas_pendientes, (select sum(getcuotaplan (a.id, d.id_cliente)) from tbl_pm_sol_contrato_det d where d.id_solicitud = a.id and d.estado = 'A') cuota_segun_edad, nvl(num_pagos, 0) num_pagos from tbl_pm_solicitud_contrato a where id is not null");
	if(fp.equals("ajustes") && fg.equals("cxc") && estado.equals("")){
		sbSql.append(" and estado = 'A' ");
	}
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
	if(!afiliados.equals("")){
		sbSql.append(" and afiliados = ");
		sbSql.append(afiliados);
	}
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}
	if(!cuota_mensual.equals("")){
		sbSql.append(" and cuota_mensual ");
		sbSql.append(cm_oper);
		sbSql.append(cuota_mensual);
	}
	if(fp.equals("cuota_extra")){
		sbSql.append(" and estado = 'A'");
	}	
	
	if(!contrato.equals("")){
		sbSql.append(" and a.id = ");
		sbSql.append(contrato);
	}
	
	if(!nombre.equals("")){
		sbSql.append(" and exists (select null from vw_pm_cliente c where c.codigo = a.id_cliente and c.nombre_paciente like '%");
		sbSql.append(nombre.toUpperCase());
		sbSql.append("%')");
	}

	if(!identificacion.equals("")){
		sbSql.append(" and exists (select null from vw_pm_cliente c where c.codigo = a.id_cliente and c.id_paciente like '%");
		sbSql.append(identificacion);
		sbSql.append("%')");
	}
	sbSql.append(" order by id nulls last ");
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

function doAction(){}
function loadSolicitud(id, qty_adendas, i){
	<%if(fp.equals("cuota_extra")){%>
	window.opener.document.form0.id_solicitud.value = eval('document.formDet.id'+id).value;
	window.opener.document.form0.id_beneficiario.value = eval('document.formDet.id_cliente'+id).value;
	window.opener.document.form0.monto_contrato.value = eval('document.formDet.cuota_mensual'+id).value;
	window.opener.document.form0.cuota_segun_edad.value = eval('document.formDet.cuota_segun_edad'+id).value;
	window.close();
	<%} else if(fp.equals("ajustes")){%>
	window.opener.document.ajuste.id_solicitud.value = eval('document.formDet.id'+i).value;
	window.opener.document.ajuste.id_referencia.value = eval('document.formDet.id_cliente'+i).value;
	window.opener.document.ajuste.referencia_desc.value = eval('document.formDet.responsable'+i).value;
	window.close();
	<%} else if(fp.equals("saldo_inicial")){%>
	window.opener.document.form1.id_contrato.value = eval('document.formDet.id'+i).value;
	window.opener.document.form1.responsable.value = eval('document.formDet.responsable'+i).value;
	window.close();
	<%} else if(fp.equals("genera_factura")){%>
	window.opener.document.form1.id_solicitud.value = eval('document.formDet.id'+i).value;
	window.opener.document.form1.num_pagos.value = eval('document.formDet.num_pagos'+i).value;
	window.close();
	<%} else {%>
	<%if(fp.equals("adenda")){%>
	var afiliados = eval('document.formDet.afiliados'+i).value;
	var id_motivo = '<%=id_motivo%>';
	/*if(afiliados==2 && id_motivo != '-1') alert('El Plan Tercera Edad no permite Adendas!');
	else */
	if(qty_adendas>0) alert('Contrato tiene Adendas pendientes!');
	else <%}%> window.opener.location = '../planmedico/reg_solicitud.jsp?mode=add&fp=adenda&id='+id+'&id_motivo='+id_motivo;
	<%}%>
	
}
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
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("id_motivo",id_motivo)%>
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
			<%=fb.select("afiliados","1=1 - 2 Afiliados,2=3 - 4 Afiliados, 3 = 5 y mas Afiliados",afiliados,"T")%>
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%if(fp.equals("ajustes") && fg.equals("cxc")){%>
			<%=fb.select("estado","A=Activo,F=Finalizado",estado,"")%>
			<%} else {%>
			<%=fb.select("estado","A=Activo,I=Inactivo,P=Pendiente",estado,"T")%>
			<%}%>
			<br>
			Contrato:
			<%=fb.textBox("contrato",contrato,false,false,false,10,10)%>
			Nombre:
			<%=fb.textBox("nombre",nombre,false,false,false,40,100)%>
			Identificacion:
			<%=fb.textBox("identificacion",identificacion,false,false,false,20,30)%>
			
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("identificacion",identificacion)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("identificacion",identificacion)%>
				<%=fb.hidden("id_motivo",id_motivo)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%
fb = new FormBean("formDet",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="50%">&nbsp;<cellbytelabel>Responsable</cellbytelabel></td>
		<td width="25%"><cellbytelabel>Plan</cellbytelabel></td>
		<td width="25%"><cellbytelabel>Cuota Mensual</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("id"+i, cdo.getColValue("id"))%>
				<%=fb.hidden("id_cliente"+i, cdo.getColValue("id_cliente"))%>
				<%=fb.hidden("afiliados"+i, cdo.getColValue("afiliados"))%>
				<%=fb.hidden("responsable"+i, cdo.getColValue("responsable"))%>
				<%=fb.hidden("cuota_mensual"+i, cdo.getColValue("cuota_mensual"))%>
				<%=fb.hidden("cuota_segun_edad"+i, cdo.getColValue("cuota_segun_edad"))%>
				<%=fb.hidden("num_pagos"+i, cdo.getColValue("num_pagos"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onDblClick="javascript:loadSolicitud(<%=(fp.equals("cuota_extra")?i:cdo.getColValue("id"))%>, <%=cdo.getColValue("adendas_pendientes")%>, <%=i%>)">
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td><%=cdo.getColValue("responsable")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("afiliados_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("cuota_mensual")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
				</tr>
				<%
				}
				%>
</table>
	</td>
</tr>
</table>
<%=fb.formEnd()%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("identificacion",identificacion)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("contrato",contrato)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("identificacion",identificacion)%>
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