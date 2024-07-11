<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
CommonDataObject cdo = null;
String sql = "";
String id = request.getParameter("id");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.GET);

if (id == null) throw new Exception("El Perfil no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select profile_name, profile_desc, profile_status, module_id from tbl_sec_profiles where profile_id="+id;
	cdo = SQLMgr.getData(sql);

	//sql = "select substr(lpad(a.entitlement_code,8,'0'),0,2) as module_id, lpad(a.entitlement_code,8,'0') as entitlement_code, a.entitlement_desc, c.name as module_name from tbl_sec_entitlements a, tbl_sec_profile_entitlements b, tbl_sec_module c where a.entitlement_code=b.entitlement_code and substr(lpad(a.entitlement_code,8,'0'),0,2)=lpad(c.id,2,'0') and b.profile_id="+id+" order by substr(lpad(a.entitlement_code,8),0,2), a.entitlement_code";
	sql = "select substr(lpad(z.entitlement_code,8,'0'),0,2) as module_id, lpad(z.entitlement_code,8,'0') as entitlement_code, z.entitlement_desc, y.name as module_name, nvl(v.name||decode(v.qs,null,nvl(x.qs,''),'?'||v.qs||decode(x.qs,null,'','&'||x.qs)),' ') as url from tbl_sec_entitlements z, tbl_sec_module y, tbl_sec_page_entitlement x, tbl_sec_pages v, tbl_sec_profile_entitlements u where substr(lpad(z.entitlement_code,8,'0'),0,2)=lpad(y.id,2,'0') and z.entitlement_code!=0 and z.entitlement_code=x.entitlement_code(+) and x.page_id=v.id(+) and z.entitlement_code=u.entitlement_code and u.profile_id="+id+" order by 5, 1, 2";
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Derechos de Accesos - '+document.title;
function printList(){abrir_ventana("../cellbyteWV/report_container.jsp?reportName=admin/rpt_access_rights.rptdesign&pProfileId=<%=id%>&pProfileName=<%=IBIZEscapeChars.forURL(cdo.getColValue("profile_name"))%>&pCtrlHeader=true");}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PERFIL - DERECHOS DE ACCESOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr class="TextHeader">
	<td colspan="2" align="center">PERFIL: <%=cdo.getColValue("profile_name")%></td>
</tr>
<tr>
	<td colspan="2" align="right">&nbsp;<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></td>
</tr>
</table>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%=fb.formStart(true)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("size",""+al.size())%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="3"><cellbytelabel>Derecho de Acceso</cellbytelabel></td>
			<td width="31%"><cellbytelabel>URL</cellbytelabel></td>
		</tr>
<%
String moduleName = "";
if (al.size()== 0)
{
%>
		<tr>
			<td colspan="4" align="center" class="TextRow01"><cellbytelabel>NO TIENE DATOS DE ACCESO DISPONIBLES</cellbytelabel> !!</td>
		</tr>
<%
}
String style = "";
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);

	style = "";
	if (cdo.getColValue("entitlement_code").trim().endsWith("00")) style=" style=\"font-weight:bold;\"";

	if (!moduleName.equalsIgnoreCase(cdo.getColValue("module_name")))
	{
%>
		<tr class="TextHeader">
			<td colspan="4"><%=cdo.getColValue("module_name")%></td>
		</tr>
<%
	}
%>
		<tr class="TextRow01">
			<td width="4%" align="right">&nbsp;</td>
			<td width="9%" align="center"><label<%=style%>>[<%=cdo.getColValue("entitlement_code")%>]</label></td>
			<td width="56%"><label<%=style%>><%=cdo.getColValue("entitlement_desc")%></label></td>
			<td>
				<%//=(cdo.getColValue("url").trim().equals(""))?"* DERECHO DE ACCESO SIN ASIGNAR PAGINA *":(cdo.getColValue("entitlement_code").trim().endsWith("00"))?cdo.getColValue("url"):""%>
				<%if(cdo.getColValue("url").trim().equals("")){%> <cellbytelabel>* DERECHO DE ACCESO SIN ASIGNAR PAGINA *</cellbytelabel>
				<%}else{%>
				  <%if(cdo.getColValue("entitlement_code").trim().endsWith("00")){%>
				     <%=cdo.getColValue("url")%>
				  <%}%>
				<%}%>	  
			</td>
		</tr>
<%
	moduleName = cdo.getColValue("module_name");
}
%>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
%>