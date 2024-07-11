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

ArrayList al= new ArrayList();
String sql="";
String mode=request.getParameter("mode");
String unidadId=request.getParameter("unidadId");
String ctag1=request.getParameter("cta1");
String ctag2=request.getParameter("cta2");
String ctag3=request.getParameter("cta3");
String ctag4=request.getParameter("cta4");
String ctag5=request.getParameter("cta5");
String ctag6=request.getParameter("cta6");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		unidadId = "0";
	}
	else
	{
		if (unidadId == null) throw new Exception("La Unidad no es válida. Por favor intente nuevamente!");

		sql = "SELECT a.unidad_adm, b.descripcion as unidad, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, c.descripcion as cuenta FROM tbl_con_pres_cuenta_x_unidad a, tbl_sec_unidad_ejec b, tbl_con_catalogo_gral c WHERE a.unidad_adm=b.codigo and a.cta1=c.cta1 and a.cta2=c.cta2 and a.cta3=c.cta3 and a.cta4=c.cta4 and a.cta5=c.cta5 and a.cta6=c.cta6 and a.cta1="+ctag1+" and a.cta2="+ctag2+" and a.cta3="+ctag3+" and a.cta4="+ctag4+" and a.cta5="+ctag5+" and a.cta6="+ctag6+" and a.unidad_adm="+unidadId+" and a.compania="+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Acceso a Cuentas x Unidad Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Acceso a Cuentas x Unidad Edición - "+document.title;
<%}%>

function addunidad()
{
		abrir_ventana1('area_unidadesadm_list.jsp?id=4');
}
function addcuenta()
{
		abrir_ventana1('unidadxarea_catalogo_list.jsp');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PRESUPUESTO - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("unidadId",unidadId)%>
			<%=fb.hidden("ctag1",ctag1)%>
			<%=fb.hidden("ctag2",ctag2)%>
			<%=fb.hidden("ctag3",ctag3)%>
			<%=fb.hidden("ctag4",ctag4)%>
			<%=fb.hidden("ctag5",ctag5)%>
			<%=fb.hidden("ctag6",ctag6)%>

			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2"><cellbytelabel>Acceso de Cuenta por Unidad</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Unidad Administrativa</cellbytelabel></td>
				<td><%=fb.textBox("unidadCode",cdo.getColValue("unidad_adm"),true,false,true,13)%><%=fb.textBox("unidad",cdo.getColValue("unidad"),true,false,true,65)%><%=fb.button("btnadm","...",true,false,null,null,"onClick=\"javascript:addunidad()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel>Cuentas Contables</cellbytelabel></td>
				<td><%=fb.textBox("cta1",cdo.getColValue("cta1"),true,false,true,3)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),true,false,true,3)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),true,false,true,3)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),true,false,true,3)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),true,false,true,3)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),true,false,true,3)%><%=fb.textBox("cuenta",cdo.getColValue("cuenta"),true,false,true,30)%><%=fb.button("btncta","...",true,false,null,null,"onClick=\"javascript:addcuenta()\"")%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
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

	cdo.setTableName("tbl_con_pres_cuenta_x_unidad");
	cdo.addColValue("unidad_adm",request.getParameter("unidadCode"));
	cdo.addColValue("cta1",request.getParameter("cta1"));
	cdo.addColValue("cta2",request.getParameter("cta2"));
	cdo.addColValue("cta3",request.getParameter("cta3"));
	cdo.addColValue("cta4",request.getParameter("cta4"));
	cdo.addColValue("cta5",request.getParameter("cta5"));
	cdo.addColValue("cta6",request.getParameter("cta6"));

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
	SQLMgr.insert(cdo);
	}
	else
	{
		cdo.setWhereClause("unidad_adm="+request.getParameter("unidadId")+" and cta1="+request.getParameter("ctag1")+" and cta2="+request.getParameter("ctag2")+" and cta3="+request.getParameter("ctag3")+" and cta4="+request.getParameter("ctag4")+" and cta5="+request.getParameter("ctag5")+" and cta6="+request.getParameter("ctag6")+" and compania="+(String) session.getAttribute("_companyId"));
	SQLMgr.update(cdo);
	}
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/acceso_x_unidad_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/acceso_x_unidad_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/presupuesto/acceso_x_unidad_list.jsp';
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