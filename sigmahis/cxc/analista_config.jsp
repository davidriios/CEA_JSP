<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
cxc90061
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
boolean viewMode = false;
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String tipo = request.getParameter("tipo");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (id == null) id = "";
if (tipo == null) tipo = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		tipo = "";
	}
	else
	{
		if (id.trim().equals("") || tipo.trim().equals("")) throw new Exception("El Analista / Cobrador no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.codigo, a.tipo_cobrador, decode(a.provincia,null,' ',''||a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',''||a.tomo) as tomo, decode(a.asiento,null,' ',''||a.asiento) as asiento, decode(a.codigo_empresa,null,' ',''||a.codigo_empresa) as codigo_empresa, nvl(a.encargado_empresa,' ') as encargado_empresa, decode(a.compania,null,' ',''||a.compania) as compania, nvl(a.nombre_cobrador,' ') as nombre_cobrador, decode(a.emp_id,null,' ',''||a.emp_id) as emp_id, decode(a.tipo_cobrador,'E','EMPLEADO','M','EMPRESA',a.tipo_cobrador) as tipo, decode(a.tipo_cobrador,'E',a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento,'M',''||a.codigo_empresa,' ') as codigo_cobrador, a.estado estado from tbl_cxc_cobrador a where a.codigo = ");
		sbSql.append(id);
		sbSql.append(" and a.tipo_cobrador = '");
		sbSql.append(tipo);
		sbSql.append("' and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		cdo = SQLMgr.getData(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Mantenimiento de Analista / Cobrador - "+document.title;
function checkTipo(tipo){displayEncargado(false);document.form0.codigo_cobrador.value='';document.form0.nombre_cobrador.value='';if(tipo=='E'){document.form0.codigo_empresa.value='';document.form0.encargado_empresa.value='';}else if(tipo=='M'){document.form0.provincia.value='';document.form0.sigla.value='';document.form0.tomo.value='';document.form0.asiento.value='';document.form0.emp_id.value='';displayEncargado(true);}}
function displayEncargado(trueFalse){document.getElementById('encargado').style.display=(trueFalse)?'':'none';document.form0.encargado_empresa.style.display=(trueFalse)?'':'none';}
function searchCobrador(){var tipo=document.form0.tipo_cobrador.value;if(tipo=='E')abrir_ventana1('../common/search_empleado.jsp?fp=cobrador');else if(tipo=='M')abrir_ventana1('../common/search_empresa.jsp?fp=cobrador');else alert('Por favor seleccione el Tipo de Cobrador!');}
function doAction(){displayEncargado(document.form0.tipo_cobrador.value=='M');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - MANTENIMIENTO - ANALISTA / COBRADOR"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),fb.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01" >
			<td width="10%">C&oacute;digo</td>
			<td width="50%"><%=id%></td>
			<td width="10%">Tipo </td>
			<td width="30%"><%=fb.select("tipo_cobrador","E=EMPLEADO,M=EMPRESA",cdo.getColValue("tipo_cobrador"),false,false,0,null,null,"onChange=\"javascript:checkTipo(this.value);\"",null,"S")%></td>

		<tr class="TextRow01" >
			<td>Cobrador</td>
			<td>
				<%=fb.hidden("provincia",cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla",cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo",cdo.getColValue("tomo"))%>
				<%=fb.hidden("asiento",cdo.getColValue("asiento"))%>
				<%=fb.hidden("codigo_empresa",cdo.getColValue("codigo_empresa"))%>
				<%=fb.hidden("emp_id",cdo.getColValue("emp_id"))%>
				<%=fb.textBox("codigo_cobrador",cdo.getColValue("codigo_cobrador"),true,false,true,16)%>
				<%=fb.textBox("nombre_cobrador",cdo.getColValue("nombre_cobrador"),true,false,true,50)%>
				<%=fb.button("btnCobrador","...",true,viewMode,null,null,"onClick=\"javascript:searchCobrador()\"")%>
			</td>
			<td><label id="encargado">Encargado</label></td>
			<td><%=fb.textBox("encargado_empresa",cdo.getColValue("encargado_empresa"),false,false,viewMode,40,null,null,null)%></td>
		</tr>

		<tr class="TextRow01">
		   <td>Estado</td>
		   <td>
       <%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,false,0,"Text10",null,null,null,"")%>
        </td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
		</tr>

		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	cdo = new CommonDataObject();
	cdo.setTableName("tbl_cxc_cobrador");
	cdo.addColValue("tipo_cobrador",request.getParameter("tipo_cobrador"));
	cdo.addColValue("provincia",request.getParameter("provincia"));
	cdo.addColValue("sigla",request.getParameter("sigla"));
	cdo.addColValue("tomo",request.getParameter("tomo"));
	cdo.addColValue("asiento",request.getParameter("asiento"));
	cdo.addColValue("codigo_empresa",request.getParameter("codigo_empresa"));
	cdo.addColValue("encargado_empresa",request.getParameter("encargado_empresa"));
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("nombre_cobrador",request.getParameter("nombre_cobrador"));
	cdo.addColValue("emp_id",request.getParameter("emp_id"));
	cdo.addColValue("estado",request.getParameter("estado"));
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.setAutoIncCol("codigo");
		//cdo.setAutoIncWhereClause("compania = "+session.getAttribute("_companyId"));
		SQLMgr.insert(cdo);
	}
	else
	{
		cdo.setWhereClause("codigo = "+request.getParameter("id"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/analista_list.jsp")) { %>
	window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/analista_list.jsp")%>';
<% } else { %>
	window.opener.location='<%=request.getContextPath()%>/cxc/analista_list.jsp';
<% } %>
	window.close();
<% } else throw new Exception(SQLMgr.getErrException()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>