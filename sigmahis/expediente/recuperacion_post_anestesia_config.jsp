<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.expediente.DetalleRecuperacionAnestesia"%>
<%@ page import="issi.expediente.RecuperacionAnestesia"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900093") || SecMgr.checkAccess(session.getId(),"900094") || SecMgr.checkAccess(session.getId(),"900095") || SecMgr.checkAccess(session.getId(),"900096") || SecMgr.checkAccess(session.getId(),"900097") || SecMgr.checkAccess(session.getId(),"900098") || SecMgr.checkAccess(session.getId(),"900099") || SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String key = "";
int lastLineNo = 0;
RecuperacionAnestesia tp = new RecuperacionAnestesia();

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		HashDet.clear();
		id = "0";
	}
	else
	{
		sql = "SELECT codigo, descripcion, orden FROM tbl_sal_recuperacion_anestesia WHERE codigo="+id+"  ";
		tp = (RecuperacionAnestesia) sbb.getSingleRowBean(ConMgr.getConnection(),sql,RecuperacionAnestesia.class);

		sql = "SELECT codigo, descripcion, escala FROM tbl_sal_detalle_recuperacion WHERE recup_anestesia="+id+" ORDER BY codigo ASC ";
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleRecuperacionAnestesia.class);

		HashDet.clear();

		for (int i = 1; i <= al.size(); i++)
		{
			DetalleRecuperacionAnestesia dra = (DetalleRecuperacionAnestesia) al.get(i-1);
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			dra.setKey(key);

			HashDet.put(dra.getKey(),dra);
			lastLineNo = i;
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Recuperación Post-Anestésica - "+document.title;

function doSubmit(baction)
{
	document.form1.baction.value = baction;
	if (form1Validation()) window.frames['itemFrame'].doSubmit();
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - RECUPERACION POST-ANESTESICA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="20%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
			<td width="80%"><%=id%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.textBox("descripcion",tp.getDescripcion(),true,viewMode,false,40)%></td>
		</tr>
        <tr class="TextRow01">
			<td><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td><%=fb.intBox("orden",tp.getOrden(),true,viewMode,false,5,2)%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2"><iframe name="itemFrame" id="itemFrame" width="100%" height="50" scrolling="no" frameborder="0" src="../expediente/recuperacion_post_anestesia_detail.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="2" align="right">
				<cellbytelabel id="3">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="4">Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="5">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="6">Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
}//GET
else
{
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
  String baction = request.getParameter("baction");
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/recuperacion_post_anestesia_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/recuperacion_post_anestesia_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/recuperacion_post_anestesia_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',900);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',900);

<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=request.getParameter("id")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>