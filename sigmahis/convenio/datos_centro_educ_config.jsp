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
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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

String sql="";
String mode=request.getParameter("mode");

String id=request.getParameter("id");


if (mode == null||mode.trim().equals("")) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("secuencia","0");
	}
	else
	{
		if (id == null) throw new Exception("El Centro Educativo no es válido. Por favor intente nuevamente!");

		sql = "select a.empresa, a.secuencia, a.nombre as name, a.poliza, a.monto_limite as monto, b.codigo, b.nombre as descripcion from tbl_adm_centros_educativos a, tbl_adm_empresa b where a.empresa=b.codigo and a.secuencia="+id;
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Centro Educativo - "+document.title;
function agregar(){abrir_ventana1('../common/search_empresa.jsp?fp=centro_educ');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CENTRO EDUCATIVO"></jsp:param>
</jsp:include>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="99%" class="TableBorder">
<!--*************************************************************************************************************-->
<!--STYLE UP-->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;<cellbytelabel>Datos de la Empresa</cellbytelabel></td>
				</tr>
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("secuencia",cdo.getColValue("secuencia"))%>
				<tr class="TextRow01">
					<td width="17%">&nbsp;<cellbytelabel>Empresa</cellbytelabel></td>
					<td width="83%">&nbsp;<%=fb.textBox("empresa",cdo.getColValue("empresa"),true,false,mode.equals("edit"),15)%>
					<%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,mode.equals("edit"),45)%>
		<%=fb.button("enviar","...",true,false,null,null,"onClick=\"javascript:agregar();\"")%></td>
				</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;<cellbytelabel>Datos del Centro Educativo</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td>&nbsp;<cellbytelabel>C&oacute;digo </cellbytelabel></td>
					<td>&nbsp;<%=cdo.getColValue("secuencia")%></td>
				</tr>
				<tr class="TextRow01">
					<td>&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("name",cdo.getColValue("name"),true,false,false,45)%></td>
				</tr>
				<tr class="TextRow01">
					<td>&nbsp;<cellbytelabel>No. P&oacute;liza</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("poliza",cdo.getColValue("poliza"),true,false,false,45)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel>Monto L&iacute;mite</cellbytelabel></td>
					<td>&nbsp;<%=fb.decBox("monto",cdo.getColValue("monto"),true,false,false,15)%></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
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

	cdo.setTableName("tbl_adm_centros_educativos");
	cdo.addColValue("nombre",request.getParameter("name"));
	cdo.addColValue("empresa",request.getParameter("empresa"));
	cdo.addColValue("poliza",request.getParameter("poliza"));
	cdo.addColValue("monto_limite",request.getParameter("monto"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode);

	if (mode != null && mode.trim().equals("add")) {

		cdo.setAutoIncCol("secuencia");
		SQLMgr.insert(cdo);

	} else {

		cdo.setWhereClause("secuencia="+request.getParameter("secuencia")+" and empresa = "+request.getParameter("empresa"));
		SQLMgr.update(cdo);

	}

	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/convenio/datos_centro_educ_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/convenio/datos_centro_educ_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/convenio/datos_centro_educ_list.jsp';
<%
	}
%>
	//window.opener.location.reload(true);
	window.close();
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