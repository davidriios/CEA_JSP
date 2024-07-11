<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800057") || SecMgr.checkAccess(session.getId(),"800058") || SecMgr.checkAccess(session.getId(),"800059") || SecMgr.checkAccess(session.getId(),"800060"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String newFilter = "";
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String grupo = request.getParameter("grupo");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if (grupo == null) grupo = "";
if (!grupo.equals(""))
{
	newFilter += " and c.grupo="+grupo;

}


if (request.getMethod().equalsIgnoreCase("GET"))
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

	String cedula = request.getParameter("cedula");
	String nombre = request.getParameter("nombre");
	if (cedula == null) cedula = "";
	if (nombre == null) nombre = "";
if (!cedula.trim().equals("")) appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+cedula.toUpperCase()+"%'";
	if (!nombre.trim().equals("")) appendFilter += " and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada))) like '%"+nombre.toUpperCase()+"%'";
/*
  if (request.getParameter("cedula") != null)
  {

	 if (fp.equalsIgnoreCase("cambio_turno") || fp.equalsIgnoreCase("solicitud_vaca") || fp.equalsIgnoreCase("otros_pagos"))
	{
	 	appendFilter += " and upper(a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
		searchOn = "a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento";
		searchVal = request.getParameter("cedula");
		searchType = "1";
		searchDisp = "Cédula";
	}
  }
  else if (request.getParameter("nombre") != null)
  {
    if (fp.equalsIgnoreCase("solicitud_vaca") || fp.egualsIgnoreCase("otros_pagos"))
	{
		appendFilter += " and upper(a.primer_nombre||' '||a.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		searchOn = "a.primer_nombre||' '||a.primer_apellido";
		searchVal = request.getParameter("nombre");
		searchType = "1";
		searchDisp = "Nombre";
	}

  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
		if (searchType.equals("1"))
		{
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
*/

if (fp.equalsIgnoreCase("solicitud_vac") || fp.equalsIgnoreCase("otros_pagos")|| fp.equalsIgnoreCase("cambio_turno"))
	{
	   sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento,a.emp_id, a.compania, to_char(trim(a.provincia),'00')||'-'||a.sigla||'-'||to_char(trim(a.tomo),'0000')||'-'||to_char(trim(a.asiento),'00000') as cedula,  a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada)) as nombre, a.cargo, nvl(a.num_empleado,' ') as numEmpleado, a.unidad_organi as unidadOrgani, b.descripcion as depto, nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso,  nvl(to_char(a.fecha_puestoact,'dd/mm/yyyy'),' ') as fechaPuestoact FROM tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ct_empleado c WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.unidad_organi=b.codigo "+newFilter+" and a.emp_id = c.emp_id and c.fecha_egreso_grupo is null and a.compania = b.compania"+appendFilter;

	//    sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento,a.emp_id, a.compania, to_char(trim(a.provincia),'00')||'-'||a.sigla||'-'||to_char(trim(a.tomo),'0000')||'-'||to_char(trim(a.asiento),'00000') as cedula,  a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada)) as nombre, a.cargo, nvl(a.num_empleado,' ') as numEmpleado, a.unidad_organi as unidadOrgani, b.descripcion as depto, nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso,  nvl(to_char(a.fecha_puestoact,'dd/mm/yyyy'),' ') as fechaPuestoact FROM tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ct_empleado c WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.unidad_organi=b.codigo "+newFilter+" and  c.fecha_egreso_grupo is null and a.compania = b.compania"+appendFilter;
	} else if (fp.equalsIgnoreCase("aprobar_rechazar_solicitud_vac")) {

		sql ="select a.provincia, a.sigla, a.tomo, a.asiento,a.emp_id, a.compania, to_char(trim(a.provincia),'00')||'-'||a.sigla||'-'||to_char(trim(a.tomo),'0000')||'-'||to_char(trim(a.asiento),'00000') as cedula,  a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_casada,null,'',' '||a.apellido_casada)) as nombre, a.cargo, nvl(a.num_empleado,' ') as numempleado, a.unidad_organi as unidadorgani, b.descripcion as depto, nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaingreso,  nvl(to_char(a.fecha_puestoact,'dd/mm/yyyy'),' ') as fechapuestoact, d.denominacion from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cargo d where a.compania="+(String) session.getAttribute("_companyId")+"  and a.unidad_organi=b.codigo  and a.compania = b.compania and a.compania = d.compania and a.cargo = d.codigo "+appendFilter;
	}


	al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
	//rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_ct_empleado c WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.unidad_organi=b.codigo "+newFilter+" and a.emp_id = c.emp_id and c.fecha_egreso_grupo is null and a.compania=b.compania"+appendFilter);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Empleados - '+document.title;

function setEmpleado(k)
{
<%
	if (fp.equalsIgnoreCase("admision_empleado_ben"))
	{
%>
	window.opener.document.form4.poliza<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
	window.opener.document.form4.certificado<%=index%>.value = eval('document.empleado.cedula'+k).value;
<%
	}
		if (fp.equalsIgnoreCase("cambio_turno"))
	{
%>
	//window.opener.document.formCambio.codPert<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
	//window.opener.document.formCambio.pertDesc<%=index%>.value = eval('document.empleado.nombre'+k).value;
	 window.opener.document.formCambio.codPert.value = eval('document.empleado.numEmpleado'+k).value;
	  window.opener.document.formCambio.pertDesc.value = eval('document.empleado.nombre'+k).value;
<%
	}
		if (fp.equalsIgnoreCase("solicitud_vac"))
	{
%>
	  window.opener.document.formVacacion.codPert.value = eval('document.empleado.numEmpleado'+k).value;
	  window.opener.document.formVacacion.pertDesc.value = eval('document.empleado.nombre'+k).value;
	  window.opener.document.formVacacion.r_provincia.value = eval('document.empleado.provincia'+k).value;
	  window.opener.document.formVacacion.r_sigla.value = eval('document.empleado.sigla'+k).value;
	  window.opener.document.formVacacion.r_tomo.value = eval('document.empleado.tomo'+k).value;
	  window.opener.document.formVacacion.r_asiento.value = eval('document.empleado.asiento'+k).value;
		window.opener.setReemplazoValues();
	//  window.opener.document.formVacacion.cargoDesc.value = eval('document.empleado.cargo'+k).value;
<%
	}
			if (fp.equalsIgnoreCase("otros_pagos"))
	{
%>
	  window.opener.document.formOtros.codPert.value = eval('document.empleado.numEmpleado'+k).value;
	  window.opener.document.formOtros.pertDesc.value = eval('document.empleado.nombre'+k).value;
	//  window.opener.document.formVacacion.cargoDesc.value = eval('document.empleado.cargo'+k).value;
<%
	}

	else if (fp.equalsIgnoreCase("admision_empleado_resp"))
	{
%>

	//	window.opener.document.form5.tipoIdentificacion<%=index%>.value = 'C';
		window.opener.document.form5.lugarNac<%=index%>.value = '';

		window.opener.document.form5.sexo<%=index%>.value = '';
		window.opener.document.form5.empresa<%=index%>.value = '';
		window.opener.document.form5.medico<%=index%>.value = '';
		window.opener.document.form5.parentesco<%=index%>.value = '';
		window.opener.document.form5.lugarNac<%=index%>.value = '';
		window.opener.document.form5.nacionalidad<%=index%>.value = '';
		window.opener.document.form5.nacionalidadDesc<%=index%>.value = '';
		window.opener.document.form5.tipoIdentificacion<%=index%>.value = 'C';

		window.opener.document.form5.nombre<%=index%>.value = eval('document.empleado.nombre'+k).value;
		window.opener.document.form5.identificacion<%=index%>.value = eval('document.empleado.cedula'+k).value;
		window.opener.document.form5.sexo<%=index%>.value = eval('document.empleado.sexo'+k).value;
		window.opener.document.form5.seguroSocial<%=index%>.value = eval('document.empleado.numSsocial'+k).value;
		window.opener.document.form5.numEmpleado<%=index%>.value = eval('document.empleado.numEmpleado'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("evaluacion_empleado"))
	{
%>
	  window.opener.document.form0.nombre.value = eval('document.empleado.nombre'+k).value;
		window.opener.document.form0.provincia.value = eval('document.empleado.provincia'+k).value;
		window.opener.document.form0.sigla.value = eval('document.empleado.sigla'+k).value;
		window.opener.document.form0.tomo.value = eval('document.empleado.tomo'+k).value;
		window.opener.document.form0.asiento.value = eval('document.empleado.asiento'+k).value;
		window.opener.document.form0.emp_id.value = eval('document.empleado.emp_id'+k).value;
		window.opener.document.form0.numEmpleado.value = eval('document.empleado.numEmpleado'+k).value;
		window.opener.document.form0.cargo.value = eval('document.empleado.cargo'+k).value;
		window.opener.document.form0.unidadAdm.value = eval('document.empleado.unidadOrgani'+k).value;
		window.opener.document.form0.depto.value = eval('document.empleado.depto'+k).value;
		window.opener.document.form0.fechaIngreso.value = eval('document.empleado.fechaIngreso'+k).value;
		window.opener.document.form0.fechaPuestoact.value = eval('document.empleado.fechaPuestoact'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("aprobar_rechazar_solicitud_vac"))
	{
%>
	  window.opener.document.form1.r_dsp_nombre.value = eval('document.empleado.nombre'+k).value;
		window.opener.document.form1.r_provincia.value = eval('document.empleado.provincia'+k).value;
		window.opener.document.form1.r_sigla.value = eval('document.empleado.sigla'+k).value;
		window.opener.document.form1.r_tomo.value = eval('document.empleado.tomo'+k).value;
		window.opener.document.form1.r_asiento.value = eval('document.empleado.asiento'+k).value;
		window.opener.document.form1.r_emp_id.value = eval('document.empleado.emp_id'+k).value;
		window.opener.document.form1.r_num_empleado.value = eval('document.empleado.numEmpleado'+k).value;
		window.opener.document.form1.r_cargo.value = eval('document.empleado.cargo'+k).value;
		window.opener.document.form1.r_cargo_desc.value = eval('document.empleado.cargo_dsp'+k).value;

<%
  }
	else if (fp.equalsIgnoreCase("evaluador"))
	{
%>
        window.opener.document.form0.evaluadorDesc.value = eval('document.empleado.nombre'+k).value;
		window.opener.document.form0.provinciaEval.value = eval('document.empleado.provincia'+k).value;
		window.opener.document.form0.siglaEval.value = eval('document.empleado.sigla'+k).value;
		window.opener.document.form0.tomoEval.value = eval('document.empleado.tomo'+k).value;
		window.opener.document.form0.asientoEval.value = eval('document.empleado.asiento'+k).value;
<%
  }else if (fp.equalsIgnoreCase("DM"))
	{
%>
    window.opener.document.devolucion.empNombre.value = eval('document.empleado.nombre'+k).value;
		window.opener.document.devolucion.empProvincia.value = eval('document.empleado.provincia'+k).value;
		window.opener.document.devolucion.empSigla.value = eval('document.empleado.sigla'+k).value;
		window.opener.document.devolucion.empTomo.value = eval('document.empleado.tomo'+k).value;
		window.opener.document.devolucion.empAsiento.value = eval('document.empleado.asiento'+k).value;
		window.opener.document.devolucion.emp_id.value = eval('document.empleado.emp_id'+k).value;
<%
  }
%>
		window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<td width="50%">
					C&eacute;dula
					<%=fb.textBox("cedula","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>

<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("grupo",grupo)%>
					<td width="50%">
					Nombre
					<%=fb.textBox("nombre","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>

				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
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

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
				<tr class="TextHeader" align="center">
					<td width="20%">No. Empleado</td>
					<td width="30%">C&eacute;dula</td>
					<td width="50%">Nombre</td>
				</tr>
<%
fb = new FormBean("empleado",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("numEmpleado"+i,cdo.getColValue("numEmpleado"))%>
				<%=fb.hidden("numSsocial"+i,cdo.getColValue("numSsocial"))%>
				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
				<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
				<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
				<%=fb.hidden("cargo"+i,cdo.getColValue("cargo"))%>
				<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
				<%=fb.hidden("unidadOrgani"+i,cdo.getColValue("unidadOrgani"))%>
				<%=fb.hidden("depto"+i,cdo.getColValue("depto"))%>
				<%=fb.hidden("fechaIngreso"+i,cdo.getColValue("fechaIngreso"))%>
				<%=fb.hidden("fechaPuestoact"+i,cdo.getColValue("fechaPuestoact"))%>
				<%if (fp.equalsIgnoreCase("aprobar_rechazar_solicitud_vac"))  {%>
					<%=fb.hidden("cargo_dsp"+i,cdo.getColValue("denominacion"))%>
				<% }%>


				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEmpleado(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("numEmpleado")%></td>
					<td><%=cdo.getColValue("cedula")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
				</tr>
<%
}
%>
<%=fb.formEnd()%>
</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
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
