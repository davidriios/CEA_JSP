<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String lista = request.getParameter("lista");
String factura = request.getParameter("factura");
String anio = request.getParameter("anio");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String tipo_ajuste = request.getParameter("tipo_ajuste");
String factura_desc = "";
String estado = "";
if (mode == null) mode = "app";
if (factura == null) factura = "";
if (fg == null) fg = "";
if (fp == null) fp = "";
if(mode.equals("app")){
	estado = "A";
	mode = "Aprobar";
} else if(mode.equals("ina")){
	mode = "Inactivar";
	estado = "I";
}
if(request.getParameter("estado")!=null && !request.getParameter("estado").equals("")) estado = request.getParameter("estado");

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (lista == null) throw new Exception("El Numero de lista no es válido. Por favor intente nuevamente!");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("lista",lista)%>
			<%=fb.hidden("estado",estado)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("factura",factura)%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("tipo_ajuste",tipo_ajuste)%>
				<tr class="TextHeader" align="center">
					<td colspan="2">INACTIVAR FACTURA DE LA LISTA</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de <%=mode%> la factura <%=factura%> de la lista No. <%=lista%> del <%=anio%>?</font></cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="2">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  lista = request.getParameter("lista");
	sql.append("call sp_cxc_anula_fac_aju_inc(");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(", ");
	sql.append(lista);
	sql.append(", ");
	sql.append(anio);
	sql.append(", '");
	sql.append(factura);
	sql.append("', '");
	sql.append((String) session.getAttribute("_userName"));
	sql.append("', '");
	sql.append(estado);
	sql.append("')");
  
	SQLMgr.execute(sql.toString());
  
%>
<html>
<head>
<script language="javascript" src="../js/global.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.hidePopWin(false);
	<%if(fp.equals("edit_lista_inc")){%>
	parent.window.location = '../cxc/list_fact_incob_x_saldo.jsp?mode=edit&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>&fg=<%=fg%>';
	<%} else if(fp.equals("app_lista_inc")){%>
	parent.window.location = '../cxc/list_rebajar_incobrables.jsp?mode=edit&anio=<%=anio%>&lista=<%=lista%>&tipo_ajuste=<%=tipo_ajuste%>&fg=<%=fg%>';
	<%}%>
	
<%
	
} else throw new Exception(SQLMgr.getErrException());
%>
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>