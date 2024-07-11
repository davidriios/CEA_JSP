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
==================================================================================
300003	AGREGAR TIPO DE PROVEEDOR
300004	MODIFICAR TIPO DE PROVEEDOR
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"300003") || SecMgr.checkAccess(session.getId(),"300004"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	   code = "";
	}
	else
	{
		if (code == null) throw new Exception("El Tipo de Proveedor no es válido. Por favor intente nuevamente!");
		 
		sql = "SELECT tipo_proveedor as codigo, descripcion, nivel,afecta_mor FROM tbl_com_tipo_proveedor WHERE tipo_proveedor='"+code+"'";
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Tipo Proveedor Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title=" Tipo Proveedor Edición - "+document.title;
<%}%>
function checkCode(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_com_tipo_proveedor','tipo_proveedor=\''+obj.value+'\'','<%=code%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>			
<%fb.appendJsValidation("if(checkCode(document.form1.codigo))error++;");%>

			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<!--public String textBox(String objName, String objValue, boolean isRequired, boolean isDisabled, boolean isReadonly, int size, int maxLength, String className, String style, String event)-->
				<td width="85%"><%=fb.textBox("codigo", code, true, false, false, 4, 2, "", "","onBlur=\"javascript:checkCode(this)\"")%></td>				
			</tr>							
			<tr class="TextRow01">
				<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
			</tr>
			<!--<tr class="TextRow01">
				<td> Proveedor (Nivel) </td>
				<td><%//=fb.select("nivel","P=Primaria,S=Secundaria",cdo.getColValue("nivel"))%></td>
			
			</tr>					-->	
			<tr class="TextRow02">
				<td> Afecta Morosidad cxp </td>
				<td><%=fb.select("afecta_mor","S=SI,N=NO",cdo.getColValue("afecta_mor"))%></td>			
			</tr>						
			<tr class="TextRow01">
				<td colspan="2" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
			<tr>
				<td colspan="2">&nbsp;</td>
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

  cdo.setTableName("tbl_com_tipo_proveedor"); 
  cdo.addColValue("tipo_proveedor",request.getParameter("codigo"));
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
//  cdo.addColValue("nivel",request.getParameter("nivel"));
 cdo.addColValue("nivel","P");
 cdo.addColValue("afecta_mor",request.getParameter("afecta_mor"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {	
		SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("tipo_proveedor='"+request.getParameter("code")+"'");
		SQLMgr.update(cdo);
  }
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/compras/tipoproveedor_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/compras/tipoproveedor_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/compras/tipoproveedor_list.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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