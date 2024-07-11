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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String status = request.getParameter("status");
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String apellido = request.getParameter("apellido");
String identificacion = request.getParameter("identificacion");
String empresa = request.getParameter("empresa");
String empresaNombre = request.getParameter("empresaNombre");

if (status == null) status = "";
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (apellido == null) apellido = "";
if (identificacion == null) identificacion = "";
if (empresa == null) empresa = "";
if (empresaNombre == null) empresaNombre = "";
if (!status.equals("")) { sbFilter.append(" and a.estado='"); sbFilter.append(status); sbFilter.append("'"); }
if (!codigo.equals("")) { sbFilter.append(" and upper(nvl(a.reg_medico,a.codigo)) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
if (!nombre.equals("")) { sbFilter.append(" and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!apellido.equals("")) { sbFilter.append(" and upper(a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
if (!identificacion.equals("")) { sbFilter.append(" and upper(a.identificacion) like '%"); sbFilter.append(identificacion.toUpperCase()); sbFilter.append("%'"); }
if (!empresa.equals("")) { sbFilter.append(" and upper(a.cod_empresa) like '%"); sbFilter.append(empresa.toUpperCase()); sbFilter.append("%'"); }
if (!empresaNombre.equals("")) { sbFilter.append(" and upper(e.nombre) like '%"); sbFilter.append(empresaNombre.toUpperCase()); sbFilter.append("%'"); }

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

	sbSql.append("select a.codigo,nvl(a.reg_medico,a.codigo) as reg_medico ,a.identificacion, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) as nombre, a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) as apellido, a.sexo, decode(a.nacionalidad, null, ' ', a.nacionalidad) as nacionalidad, a.estado_civil as estadoCivil, decode(a.fecha_de_nacimiento, null, ' ', to_char(a.fecha_de_nacimiento, 'dd/mm/yyyy')) as fechaDeNacimiento, a.religion, nvl(a.digito_verificador, ' ') as digitoVerificador, nvl(a.direccion, ' ') as direccion, decode(a.comunidad, null, ' ', a.comunidad) as comunidad, decode(a.corregimiento, null, ' ', a.corregimiento) as corregimiento, decode(a.distrito, null, ' ', a.distrito) as distrito, decode(a.provincia, null, ' ', a.provincia) as provincia, decode(a.pais, null, ' ', a.pais) as pais, nvl(a.telefono, ' ') as telefono, nvl(a.zona_postal, ' ') as zonaPostal, nvl(a.apartado_postal, ' ') as apartadoPostal, nvl(a.bepper, ' ') as bepper, nvl(a.celular, ' ') as celular, nvl(a.lugar_de_trabajo, ' ') as lugarDeTrabajo, nvl(a.telefono_trabajo, ' ') as telefonoTrabajo, nvl(a.extension, ' ') as extension, a.estado, nvl(a.e_mail, ' ') as eMail, nvl(a.fax, ' ') as fax, nvl(a.observaciones, ' ') as observaciones, decode(a.cod_empresa, null, ' ', '['||a.cod_empresa||']') as codEmpresa, nvl(a.beneficiario, ' ') as beneficiario, nvl(a.pagar_ben, ' ') as pagarBen, nvl(a.liquidable, ' ') as liquidable, nvl(a.retencion, ' ') as retencion, nvl(a.cuenta_bancaria, ' ') as cuentaBancaria, nvl(a.ruta_transito, ' ') as rutaTransito, nvl(a.tipo_cuenta, ' ') as tipoCuenta, decode(a.tipo_persona, null, ' ', a.tipo_persona) as tipoPersona, nvl(b.nacionalidad, 'NA') as nacionalidadDesc, nvl(c.descripcion, 'NA') as religionDesc, nvl(d.nombre_comunidad, ' ') as comunidadNombre, nvl(d.nombre_corregimiento, ' ') as corregimientoNombre, nvl(d.nombre_distrito, ' ') as distritoNombre, nvl(d.nombre_provincia, ' ') as provincianombre, nvl(d.nombre_pais, ' ') as paisnombre, nvl(e.nombre,' ') as empresaNombre, nvl(f.nombre_banco,' ') as rutaTransitoNombre from tbl_adm_medico a, tbl_sec_pais b, tbl_adm_religion c, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito, decode(codigo_corregimiento,0,null,codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, tbl_adm_empresa e, tbl_adm_ruta_transito f where a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and a.pais = d.codigo_pais(+) and a.provincia = d.codigo_provincia(+) and a.distrito = d.codigo_distrito(+) and a.corregimiento = d.codigo_corregimiento(+) and a.comunidad = d.codigo_comunidad(+) and a.cod_empresa=e.codigo(+) and a.ruta_transito=f.ruta(+)");
	sbSql.append(sbFilter);
	sbSql.append(" order by 4,3");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	
	rowCount = CmnMgr.getCount("select count(*) from tbl_adm_medico a, tbl_sec_pais b, tbl_adm_religion c, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito, decode(codigo_corregimiento,0,null,codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, tbl_adm_empresa e, tbl_adm_ruta_transito f where a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and a.pais = d.codigo_pais(+) and a.provincia = d.codigo_provincia(+) and a.distrito = d.codigo_distrito(+) and a.corregimiento = d.codigo_corregimiento(+) and a.comunidad = d.codigo_comunidad(+) and a.cod_empresa=e.codigo(+) and a.ruta_transito=f.ruta(+)"+sbFilter.toString());

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
document.title = ' Médico - '+document.title;

function add()
{
	abrir_ventana('../admision/medico_config.jsp');
}

function edit(id)
{
	abrir_ventana('../admision/medico_config.jsp?mode=edit&id='+id);
}

function printList(type){
  if(!type)abrir_ventana('../admision/print_list_medico.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');
  else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/rpt_list_medico.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&pCtrlHeader=false');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICA - ADMISION - MANTENIMIENTOS - MEDICO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;
		<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevos M&eacute;dicos ]</a></authtype>
	</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td width="12%">
				<cellbytelabel id="1">Registro M&eacute;dico</cellbytelabel><br>
				<%=fb.textBox("codigo","",false,false,false,15,"Text10",null,null)%>
			</td>
			<td width="18%">
				<cellbytelabel id="2">Nombre</cellbytelabel><br>
				<%=fb.textBox("nombre","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="18%">
				<cellbytelabel id="3">Apellido</cellbytelabel><br>
				<%=fb.textBox("apellido","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="13%">
				<cellbytelabel id="4">Identificaci&oacute;n</cellbytelabel><br>
				<%=fb.textBox("identificacion","",false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="25%">
				<cellbytelabel id="5">Empresa del Cheque</cellbytelabel><br>
				<%=fb.intBox("empresa","",false,false,false,5,"Text10",null,null)%>
				<%=fb.textBox("empresaNombre","",false,false,false,30,"Text10",null,null)%>
			</td>
			<td width="14%">
				<cellbytelabel id="6">Estado</cellbytelabel><br>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>&nbsp;|&nbsp;<a href="javascript:printList(1)" class="Link00">[ <cellbytelabel>Imprimir Lista (Excel)</cellbytelabel> ]</a></authtype></td>
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
<%=fb.hidden("status",status)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("empresaNombre",empresaNombre)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="8">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="9">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="10">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("status",status)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("empresaNombre",empresaNombre)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="12%"><cellbytelabel id="1">Registro M&eacute;dico</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
			<td width="18%"><cellbytelabel id="3">Apellido</cellbytelabel></td>
			<td width="13%"><cellbytelabel id="4">Identificaci&oacute;n</cellbytelabel></td>
			<td width="25%"><cellbytelabel id="5">Empresa del Cheque</cellbytelabel></td>
			<td width="8%"><cellbytelabel id="6">Estado</cellbytelabel></td>
			<td width="6%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("reg_medico")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("apellido")%></td>
			<td><%=cdo.getColValue("identificacion")%></td>
			<td><%=cdo.getColValue("codEmpresa")%> <%=cdo.getColValue("empresaNombre")%></td>
			<td align="center"><%=(cdo.getColValue("estado").equalsIgnoreCase("A"))?"Activo":"Inactivo"%></td>
			<td align="center"><authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="11">Editar</cellbytelabel></a></authtype></td>
		</tr>
<%
}
%>
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
<%=fb.hidden("status",status)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("empresaNombre",empresaNombre)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="8">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="9">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="10">hasta</cellbytelabel> <%=nVal%></
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
<%=fb.hidden("status",status)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("empresaNombre",empresaNombre)%>
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
<%
}
%>