<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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

ArrayList alRefType = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
StringBuffer sbSql = new StringBuffer();

String compania = request.getParameter("compania");
String codigo = request.getParameter("codigo");
String cds = request.getParameter("cds");
String categoria = request.getParameter("categoria");
String tipoServ = request.getParameter("tipoServ");
String estado = request.getParameter("estado");
String nombre = request.getParameter("nombre");
String precioVenta = request.getParameter("precioVenta");
String accion = request.getParameter("accion");
String roundTo = request.getParameter("roundTo");
String basis = request.getParameter("basis");
String porcentaje = request.getParameter("porcentaje");
String fg = request.getParameter("fg");

String  actDesc = "ACTUALIZAR PRECIO POR LOTE";

if (categoria == null) categoria = "";
if (tipoServ == null) tipoServ = "";
if (cds == null) cds = "";
if (nombre == null) nombre = "";
if (estado == null) estado = ""; 
if (precioVenta == null) precioVenta = "";
if (codigo == null) codigo = "";
if (fg == null) fg = "";

if (porcentaje == null) porcentaje = "0"; 
if (roundTo == null) roundTo = "";
if (basis == null) basis = "PV";

  
if(fg.trim().equals("PROC")) actDesc +=" PROCEDIMIENTOS ";
else if(fg.trim().equals("USOS")) actDesc +=" USOS ";
else if(fg.trim().equals("HAB"))actDesc +=" CAMAS ";
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'ADMIN - '+document.title;
function doAction(){}
 </script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ACTUALIZAR PRECIO POR LOTE"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("tipoServ",tipoServ)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("precioVenta",precioVenta)%>
<%=fb.hidden("accion",accion)%>
<%=fb.hidden("roundTo",roundTo)%>
<%=fb.hidden("basis",basis)%>
<%=fb.hidden("porcentaje",porcentaje)%>
<%=fb.hidden("fg",fg)%>


		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel><%=actDesc%></cellbytelabel></td>
		</tr>
		 
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.submit("save","Guardar",true,false,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",false,false,null,"","onClick=\"javascript:parent.hidePopWin(false)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {

	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	String rParam = null;//parámetro que devuelve el procedimiento almacenado
	sbSql = new StringBuffer();
	sbSql.append("call sp_fac_upd_pricexlote(?,?,?,?,?,?,?,?,?,?,?,?,?)");
	param.setSql(sbSql.toString());
	param.addInStringStmtParam(1,compania);
	param.addInStringStmtParam(2,codigo);
	param.addInStringStmtParam(3,cds);
	param.addInStringStmtParam(4,categoria);
	param.addInStringStmtParam(5,tipoServ);
	param.addInStringStmtParam(6,estado);
	param.addInStringStmtParam(7,nombre);
	param.addInNumberStmtParam(8,porcentaje);
	param.addInNumberStmtParam(9,accion);
	param.addInNumberStmtParam(10,roundTo);
	param.addInStringStmtParam(11,basis);
	param.addInNumberStmtParam(12,precioVenta);
	param.addInStringStmtParam(13,fg);   
	 

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"compania="+compania+"&codigo="+codigo+"&cds="+cds+"&categoria="+categoria+"&tipoServ="+tipoServ+"&estado="+estado+"&nombre="+nombre+"&precioVenta="+precioVenta+"&accion="+accion+"&roundTo="+roundTo+"&basis="+basis+"&porcentaje="+porcentaje+"&fg="+fg);
	param = SQLMgr.executeCallable(param);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% } else throw new Exception(SQLMgr.getErrException()); %>
parent.window.location.reload(true);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>