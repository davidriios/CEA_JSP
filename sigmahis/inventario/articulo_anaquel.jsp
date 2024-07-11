<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");
String fg = request.getParameter("fg");
if (id == null) id = "";
if (fg == null) fg = "";

if (request.getMethod().equalsIgnoreCase("GET")) {
	if (!id.trim().equals("")) {
		sbSql.append("select z.codigo_almacen, nvl(''||z.codigo_anaquel,'-') as codigo_anaquel, z.pto_reorden");
		sbSql.append(", (select descripcion from tbl_inv_almacen where compania = z.compania and codigo_almacen = z.codigo_almacen) as almacen");
		sbSql.append(", nvl((select descripcion from tbl_inv_anaqueles_x_almacen where compania = z.compania and codigo_almacen = z.codigo_almacen and codigo = z.codigo_anaquel),'SIN DEFINIR') as anaquel");
		sbSql.append(" from tbl_inv_inventario z where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and cod_articulo = ");
		sbSql.append(id);
		al = SQLMgr.getDataList(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){}
function doSubmit(value){
	document.form0.baction.value = value;
	if (!form0Validation()) return false;
	else document.form0.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
<table width="100%" cellpadding="1" cellspacing="1">
<tr class="TextHeader" align="center">
	<td width="35%">Almac&eacute;n</td>
	<td width="35%">Anaquel</td>
	<td width="30%">Pto.Reorden</td>
</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";

	sbSql = new StringBuffer();
	sbSql.append("select codigo, codigo||' - '||descripcion, cod_anaquel from tbl_inv_anaqueles_x_almacen where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and codigo_almacen = ");
	sbSql.append(cdo.getColValue("codigo_almacen"));
	sbSql.append(" order by 1");
%>
<%=fb.hidden("codigo_almacen"+i,cdo.getColValue("codigo_almacen"))%>
<tr class="<%=color%>">
	<td><%=cdo.getColValue("codigo_almacen")%> - <%=cdo.getColValue("almacen")%></td>
	<td align="center"><%=fb.select(ConMgr.getConnection(),sbSql.toString(),"codigo_anaquel"+i,cdo.getColValue("codigo_anaquel"),false,false,false,0,null,"width: 75%;",null,null," ")%></td>
	<td><%=fb.intBox("pto_reorden"+i,cdo.getColValue("pto_reorden"),false,false,false,10,"","","")%></td>
</tr>
<% } %>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	int keySize = Integer.parseInt(request.getParameter("size"));
	al = new ArrayList();
	for (int i=0; i<keySize; i++) {
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_inv_inventario");
		cdo.setWhereClause("compania = "+session.getAttribute("_companyId")+" and cod_articulo = "+id+" and codigo_almacen = "+request.getParameter("codigo_almacen"+i));
		cdo.addColValue("codigo_anaquel",request.getParameter("codigo_anaquel"+i));
		cdo.addColValue("pto_reorden",request.getParameter("pto_reorden"+i));
		try {
			al.add(cdo);
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}

	System.out.println("baction="+request.getParameter("baction"));
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&id="+id);
	if (request.getParameter("baction").equalsIgnoreCase("Guardar")) {
		SQLMgr.updateList(al,false);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&id=<%=id%>';
<% } else throw new Exception(SQLMgr.getErrMsg()); %>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
