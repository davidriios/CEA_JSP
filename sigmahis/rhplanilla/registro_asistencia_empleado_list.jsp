<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

ArrayList al = new ArrayList();
int rowCount = 0;
int iconHeight = 24;
int iconWidth = 24;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
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

	String grupo = request.getParameter("grupo");
	String descripcion = request.getParameter("descripcion");
	String codigo = request.getParameter("codigo");
	String area = request.getParameter("area");
	if (grupo == null) grupo = "";
	if (descripcion == null) descripcion = "";
	if (codigo == null) codigo = "";
	if (area == null) area = "";

	if (!grupo.trim().equals("") && request.getParameter("grupo") != null) { sbFilter.append(" and upper(b.codigo) like '"); sbFilter.append(grupo.toUpperCase()); sbFilter.append("%'"); }
	if (!descripcion.trim().equals("") && request.getParameter("descripcion") != null) { sbFilter.append(" and upper(b.descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	//if (!codigo.trim().equals("") && request.getParameter("codigo") != null) { sbFilter.append(" and upper(ag.codigo) like '"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	//if (!area.trim().equals("") && request.getParameter("area") != null ) { sbFilter.append(" and upper(ag.nombre) like '%"); sbFilter.append(area.toUpperCase()); sbFilter.append("%'"); }

	/*sbSql.append("SELECT ag.codigo, ag.grupo, ag.nombre, b.descripcion as grupoDesc FROM tbl_pla_ct_area_x_grupo ag, tbl_pla_ct_grupo b WHERE ag.compania = ");*/
	//sbSql.append("SELECT '1' codigo, b.codigo grupo , b.descripcion nombre, b.descripcion as grupoDesc FROM tbl_pla_ct_grupo b WHERE b.compania = ");
	sbSql.append(" SELECT distinct ag.codigo, ag.grupo, ag.nombre, b.descripcion as grupoDesc FROM tbl_pla_ct_area_x_grupo ag, tbl_pla_ct_grupo b WHERE ag.compania =");
	sbSql.append(session.getAttribute("_companyId"));
    sbSql.append(" and  ag.compania=b.compania and ag.grupo = b.codigo ");	
	sbSql.append(" and  b.codigo is not null");
	if (!UserDet.getUserProfile().contains("0")) {
		sbSql.append(" and exists (select null from tbl_pla_ct_usuario_x_grupo where compania = b.compania and grupo = b.codigo and usuario = '");
		sbSql.append(UserDet.getUserName());
		sbSql.append("')");
	}
	//sbSql.append(" and exists (select null from tbl_pla_ct_area_x_grupo where compania=b.compania and grupo = b.codigo) ");
	sbSql.append(sbFilter);
	sbSql.append(" order by 4, 3");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql+")");

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
document.title = 'Registro de Asistencia de Empleados - '+document.title;
function opciones(codigo,grupo){abrir_ventana('registro_asistencia_empleado_config.jsp?area='+codigo+'&grupo='+grupo);}
function printList(){abrir_ventana('print_list_registro_asistencia.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function marcacion(grupo){ abrir_ventana('../rhplanilla/list_marcacion.jsp?grupo='+grupo);  }
function notificacion(grupo){ abrir_ventana('../rhplanilla/empl_notificacion.jsp?grupo='+grupo); }
function generarTrx(grupo, area)  {showPopWin('../rhplanilla/generacion_trx_asistencia.jsp?grupo='+grupo+'&area='+area,winWidth*.75,winHeight*.65,null,null,'');}
function borradorProgTurno(grupo, area)  {  abrir_ventana('../rhplanilla/reg_cambio_turno_borrador.jsp?grupo='+grupo+'&area='+area);  }
function otrosPagos(grupo, area)  {  abrir_ventana('../rhplanilla/reg_emp_otros_pagos.jsp?grupo='+grupo+'&area='+area);  }



</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RRHH - PLANILLA - PROCESO - REGISTRO ASISTENCIA DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right"><a href="javascript:add()" class="Link00"></a></td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td width="50%">
				Grupo
				<%=fb.textBox("grupo",grupo,false,false,false,5)%>
				<%=fb.textBox("descripcion",descripcion,false,false,false,35)%>
			</td>
			<td width="50%">
				
				<//%=fb.textBox("codigo",codigo,false,false,false,5)%>
				<//%=fb.textBox("area",area,false,false,false,35)%>
				<%=fb.submit("go","Ir")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("area",area)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("area",area)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable">
		<tbody id="list">
		<tr class="TextHeader" align="center">
			<td width="8%">Grupo</td>
			<td width="25%">Nombre del Grupo</td>
			<td width="25%">Area</td>
			<td width="2%">&nbsp</td>
			<td width="6%">&nbsp;</td>
			<td width="6%">&nbsp;</td>
			<td width="6%">&nbsp;</td>
			<td width="6%">&nbsp;</td>
			<td width="6%">&nbsp;</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("grupo")%></td>
			<td><%=cdo.getColValue("grupoDesc")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td>&nbsp</td>
			<td align="center"><authtype type='50'><a href="javascript:borradorProgTurno(<%=cdo.getColValue("grupo")%>,null)"><img src="../images/appointment.gif" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" title="Borrador Programa Turno" alt="Borrador Programa Turno"></authtype></a></td>
			<td align="center"><authtype type='50'><a href="javascript:marcacion(<%=cdo.getColValue("grupo")%>,<%=cdo.getColValue("codigo")%>)"><img src="../images/clock.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" title="Marcaciones" alt="Marcaciones"></a></authtype></td>
			<td align="center"><authtype type='50'><a href="javascript:generarTrx(<%=cdo.getColValue("grupo")%>,<%=cdo.getColValue("codigo")%>)"><img src="../images/payment_adjust.gif" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" title="Generar Trans." alt="Generar Trans."></a></authtype></td>
			<td align="center"><authtype type='50'><a href="javascript:notificacion(<%=cdo.getColValue("grupo")%>,<%=cdo.getColValue("codigo")%>)"><img src="../images/clock-calendar.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" title="Notificaciones" alt="Notificaciones"></a></authtype></td>
			<td align="center"><authtype type='50'><a href="javascript:otrosPagos(<%=cdo.getColValue("grupo")%>,<%=cdo.getColValue("codigo")%>)"><img src="../images/scheduled-tasks.jpg" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" title="Otros Pagos" alt="Otros Pagos"></a></authtype></td>

			<td align="center" colspan="3"><authtype type='50'><a href="javascript:opciones(<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("grupo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Opciones</a></authtype></td>
		</tr>
<% } %>
		</tbody>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("area",area)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("area",area)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>