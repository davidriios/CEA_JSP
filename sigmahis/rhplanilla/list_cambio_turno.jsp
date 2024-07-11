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

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fg = request.getParameter("fg");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fecha = request.getParameter("fecha");
String empId = request.getParameter("empId");
String numEmpleado = request.getParameter("numEmpleado");
String nombre = request.getParameter("nombre");
String motivo = request.getParameter("motivo");
String aprobado = request.getParameter("aprobado");

if (fg == null) fg = "";
if (grupo == null) grupo = "";
if (area == null) area = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (fecha == null) fecha = "";
if (empId == null) empId = "";
if (numEmpleado == null) numEmpleado = "";
if (nombre == null) nombre = "";
if (motivo == null) motivo = "";
if (aprobado == null) aprobado = "";

StringBuffer sbSqlGrupo = new StringBuffer();
sbSqlGrupo.append("select codigo, codigo||' - '||descripcion from tbl_pla_ct_grupo where compania = ");
sbSqlGrupo.append(session.getAttribute("_companyId"));
if (!UserDet.getUserProfile().contains("0")) {
	sbSqlGrupo.append(" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '");
	sbSqlGrupo.append(session.getAttribute("_userName"));
	sbSqlGrupo.append("')");
}
sbSqlGrupo.append(" order by descripcion");
if (grupo.trim().equals("")) {
	cdo = SQLMgr.getData(sbSqlGrupo.toString());
	if (cdo != null) grupo = cdo.getColValue("codigo");
}

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (!anio.trim().equals("")) { sbFilter.append(" and a.anio = "); sbFilter.append(anio); }
	if (!mes.trim().equals("")) { sbFilter.append(" and a.mes = "); sbFilter.append(mes); }
	if (!fecha.trim().equals("")) { sbFilter.append(" and a.fecha_solicitud = to_date('"); sbFilter.append(fecha); sbFilter.append("','dd/mm/yyyy')"); }
	if (!empId.trim().equals("")) { sbFilter.append(" and a.empId = "); sbFilter.append(empId); }
	if (!numEmpleado.trim().equals("")) { sbFilter.append(" and a.num_empleado like '"); sbFilter.append(numEmpleado); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(b.primer_nombre||' '||b.primer_apellido) like '"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	if (!motivo.trim().equals("")) { sbFilter.append(" and a.motivo_cambio = "); sbFilter.append(motivo); }
	if (!aprobado.trim().equals("")) { sbFilter.append(" and a.aprobado = '"); sbFilter.append(aprobado); sbFilter.append("'"); }

	sbSql.append("select a.codigo, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud, a.mes, a.anio, a.grupo, decode(a.emp_id,null,' ',''||a.emp_id) as emp_id, decode(a.provincia,null,' ',''||a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',''||a.tomo) as tomo, decode(a.asiento,null,' ',''||a.asiento) as asiento, nvl(a.num_empleado,' ') as num_empleado, a.motivo_cambio, nvl(a.observaciones,' ') as observaciones, (select descripcion from tbl_pla_ct_grupo where compania = a.compania and codigo = a.grupo) as grupo_desc, nvl(b.primer_nombre||' '||b.primer_apellido,' ') as nombre_empleado, (select descripcion from tbl_pla_ct_motivo_cambio where codigo = a.motivo_cambio and compania = a.compania) as motivo_desc, to_char(to_date(lpad(a.mes,2,'0'),'mm'),'MONTH','NLS_DATE_LANGUAGE=SPANISH') as mes_desc, nvl(a.aprobado,'N') as aprobado, decode(a.aprobado,'S','APROBADO','A','ANULADO','PENDIENTE') as status from tbl_pla_ct_enc_cambio_programa a, tbl_pla_empleado b where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.grupo = ");
	sbSql.append(grupo);
	sbSql.append(" and a.emp_id = b.emp_id(+)");
	sbSql.append(sbFilter);
	sbSql.append(" order by a.fecha_solicitud desc, a.codigo desc");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_pla_ct_enc_cambio_programa a, tbl_pla_empleado b where a.compania = "+session.getAttribute("_companyId")+" and a.grupo = "+grupo+" and a.emp_id = b.emp_id(+)"+sbFilter);

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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Cambio de Turno - '+document.title;
function add(){abrir_ventana('../rhplanilla/reg_cambio_turno.jsp?fg=<%=fg%>&grupo=<%=grupo%>&area=<%=area%>');}
function edit(anio,mes,codigo){abrir_ventana('../rhplanilla/reg_cambio_turno.jsp?fg=<%=fg%>&mode=edit&grupo=<%=grupo%>&area=<%=area%>&anio='+anio+'&mes='+mes+'&codigo='+codigo);}
function approve(anio,mes,codigo){abrir_ventana('../rhplanilla/reg_cambio_turno.jsp?fg=<%=fg%>&mode=approve&grupo=<%=grupo%>&area=<%=area%>&anio='+anio+'&mes='+mes+'&codigo='+codigo);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<% if (!fg.equalsIgnoreCase("asistencia")) { %>
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO - GRUPOS"></jsp:param>
</jsp:include>
<% } %>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr>
	<td align="right"><authtype type='3'>[<a href="javascript:add()" class="Link00">Registrar Nuevo Cambio de Turno</a>]</authtype>&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("empId",empId)%>
		<tr class="TextFilter">
			<td>
				<% if (fg.equalsIgnoreCase("asistencia")) { %><%=fb.hidden("grupo",grupo)%><% } else { %>Grupo<%=fb.select(ConMgr.getConnection(),sbSqlGrupo.toString(),"grupo",grupo,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/areaXGrupo.xml','area','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','')\"")%><% } %>
				A&ntilde;o<%=fb.textBox("anio",anio,false,false,false,2,"Text10","","")%>
				Mes<%=fb.select(ConMgr.getConnection(),"select level as id, to_char(to_date(lpad(level,2,'0'),'mm'),'MONTH','NLS_DATE_LANGUAGE=SPANISH') as description, level as title from dual connect by level <= 12","mes",mes,false,false,0,"Text10",null,null,null,"T")%>
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=fecha%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				#Empl.<%=fb.textBox("numEmpleado",numEmpleado,false,false,false,5,10,"Text10","","")%>
				Nombre<%=fb.textBox("nombre",nombre,false,false,false,20,30,"Text10","","")%>
				<%=fb.submit("go","Ir",false,false,"Text10","","")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				<% if (fg.equalsIgnoreCase("asistencia")) { %><%=fb.hidden("area",area)%><% } else { %>Ubic./Area Trab.<%=fb.select("area","","",false,false,0,"Text10","","")%>
				<script language="javascript">
				loadXML('../xml/areaXGrupo.xml','area','<%=area%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")+"-"+grupo%>','KEY_COL','0');
				</script><% } %>
				Motivo<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_ct_motivo_cambio where compania = "+session.getAttribute("_companyId"),"motivo",motivo,false,false,0,"Text10",null,null,null,"T")%>
				Estado<%=fb.select("aprobado","A=ANULADO,N=PENDIENTE,S=APROBADO",aprobado,false,false,0,"Text10",null,null,null,"T")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("motivo",motivo)%>
<%=fb.hidden("aprobado",aprobado)%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("motivo",motivo)%>
<%=fb.hidden("aprobado",aprobado)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="4%">A&ntilde;o</td>
			<td width="9%">Mes</td>
			<td width="8%">Fecha</td>
			<td width="6%">C&oacute;digo</td>
			<td width="6%">#Empl.</td>
			<td width="24%">Solicitado por</td>
			<td width="29%">Motivo</td>
			<td width="8%">Estado</td>
			<td width="6%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><%=cdo.getColValue("anio")%></td>
			<td align="left"><%=cdo.getColValue("mes_desc")%></td>
			<td><%=cdo.getColValue("fecha_solicitud")%></td>
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td align="left"><%=cdo.getColValue("nombre_empleado")%></td>
			<td align="left"><%=cdo.getColValue("motivo_desc")%></td>
			<td><%=cdo.getColValue("status")%></td>
			<td align="center"><% if (cdo.getColValue("aprobado").equalsIgnoreCase("N")) { %><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("mes")%>,<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype><authtype type='4'> / </authtype><authtype type='6'><a href="javascript:approve(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("mes")%>,<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Aprobar</a></authtype><% } else { %><authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("mes")%>,<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype><% } %>&nbsp;</td>
		</tr>
<% } %>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("motivo",motivo)%>
<%=fb.hidden("aprobado",aprobado)%>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("motivo",motivo)%>
<%=fb.hidden("aprobado",aprobado)%>
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