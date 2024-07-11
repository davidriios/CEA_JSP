<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
================================================================================
cxc90063--- Asignacion de cuenta a cobrador
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
boolean viewMode = false;
String mode = request.getParameter("mode");
String docType = request.getParameter("docType");
String id = request.getParameter("id");
String anio = request.getParameter("anio");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (docType == null) docType = "";
if (id == null) id = "";
if (anio == null) anio = "";
if (!docType.equalsIgnoreCase("R") && !docType.equalsIgnoreCase("F")) throw new Exception("El Tipo de Documento no es válido. Por favor intente nuevamente!");
else if (docType.equalsIgnoreCase("R") && (id.trim().equals("") || anio.trim().equals(""))) throw new Exception("El Remanente no es válido. Por favor intente nuevamente!");
else if (docType.equalsIgnoreCase("F") && id.trim().equals("")) throw new Exception("La Factura no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	if (docType.equalsIgnoreCase("F"))
	{
		sbSql.append("select to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.anio,null,' ',''||a.anio) as cobrador, decode(a.tipo_cobro,null,' ',''||a.tipo_cobro) as tipo_cobro, nvl(to_char(a.fecha_asignacion,'dd/mm/yyyy hh12:mi:ss am'),' ') as fecha_asignacion, nvl((select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id),' ') as paciente, nvl((select nombre_cobrador from tbl_cxc_cobrador where codigo = a.cobrador),' ') as nombre_cobrador,a.cobrador, nvl((select descripcion from tbl_cxc_tipo_analista where tipo = a.tipo_cobro),' ') as cobro from tbl_fac_factura a where a.codigo = '");
		sbSql.append(id);
		sbSql.append("' and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
	}
	cdo = SQLMgr.getData(sbSql.toString());
	//if (!cdo.getColValue("fecha_asignacion").trim().equals("")) viewMode = true;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Asignación de Cobradores - "+document.title;
function getCobrador(){abrir_ventana1('../common/search_analista_x_tipo.jsp?fp=asignacion');}

function getCheckValueCobrador(){ //por CJLEE-1 de agosto 2014-esta funcion devuelve el estado del checkbutton
return eval('document.form0.checkCobrador').checked;
}


</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - ASIGNACION DE COBRADORES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),fb.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("docType",docType)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",anio)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader" >
			<td colspan="2">Asignaci&oacute;n de Cobradores a: <%=(docType.equalsIgnoreCase("F"))?"FACTURA":"NOTA DEBITO"%></td>
			<td colspan="2">Fecha Asignaci&oacute;n: <%=cdo.getColValue("fecha_asignacion")%></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%">No. Documento</td>
			<td width="40%"><label class="RedTextBold"><%=id%></label></td>
			<td width="10%">Fecha</td>
			<td width="35%"><%=cdo.getColValue("fecha")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Paciente</td>
			<td><%=cdo.getColValue("paciente")%></td>
			<td><%=(docType.equalsIgnoreCase("F"))?"&nbsp;":"No. Factura"%></td>
			<td><%=(docType.equalsIgnoreCase("F"))?"&nbsp;":cdo.getColValue("numero_factura")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Cobrador Asignado</td>
			<td>
				<%=fb.intBox("cobrador",cdo.getColValue("cobrador"),true,false,true,5)%>
				<%=fb.textBox("nombre_cobrador",cdo.getColValue("nombre_cobrador"),false,true,false,40)%>
				<%=fb.button("btnCobrador","...",true,viewMode,null,null,"onClick=\"javascript:getCobrador();\"")%>
				Sin Cobrador<%=fb.checkbox("checkCobrador","S",false,viewMode,null,null,"onClick=\"javascript:getCheckValueCobrador()\"","Sin Cobrador")%>
			</td>
			<td>Tipo Cobro</td>
			<td>
				<%=fb.intBox("tipo_cobro",cdo.getColValue("tipo_cobro"),true,false,true,2)%>
				<%=fb.textBox("cobro",cdo.getColValue("cobro"),false,true,false,40)%>
			</td>
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
		if(request.getParameter("checkCobrador")==null)
		{
		cdo.setTableName("tbl_fac_factura");
		cdo.setWhereClause("codigo = '"+id+"' and compania = "+session.getAttribute("_companyId"));
		System.out.println("COBRADOR ========="+request.getParameter("cobrador")+"       tipo_cobro==="+request.getParameter("tipo_cobro"));
		cdo.addColValue("cobrador",request.getParameter("cobrador"));
		System.out.println("COBRADOR cdo ========="+cdo.getColValue("cobrador"));
		cdo.addColValue("tipo_cobro",request.getParameter("tipo_cobro"));
		cdo.addColValue("fecha_asignacion","sysdate");
		}
		else
		{
		cdo.setTableName("tbl_fac_factura");
		cdo.setWhereClause("codigo = '"+id+"' and compania = "+session.getAttribute("_companyId"));
		cdo.addColValue("cobrador","");
		cdo.addColValue("tipo_cobro","");
		cdo.addColValue("fecha_asignacion","");
		
		}
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	SQLMgr.update(cdo);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
	<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/asignacion_cobrador_list.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/asignacion_cobrador_list.jsp")%>';
	<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/cxc/asignacion_cobrador_list.jsp';
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