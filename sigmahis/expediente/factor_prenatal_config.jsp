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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Factor Prenatal no es válido. Por favor intente nuevamente!");

	sql = "select codigo, descripcion, orden, es_default from tbl_sal_factor_prenatal where codigo="+id;
		cdo = SQLMgr.getData(sql);
	}



%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Factor Prenatal- Agregar- "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Factor Prenatal - Edición - "+document.title;
<%}%>
//function setBAction(fName,actionValue)
//{
//	document.forms[fName].baction.value = actionValue;
//}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - FACTOR PRENATAL"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%//=fb.hidden("baction","")%>
			<tr>	
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="15%">&nbsp;<cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
				<td width="85%">&nbsp;<%=id%></td>
			
			</tr>							
			<tr class="TextRow01" >
				<td>&nbsp;<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,60,99)%>
                
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Orden:
                    <%=fb.intBox("orden",cdo.getColValue("orden"),false,false,false,5,2)%>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Por defecto:
                    <%=fb.select("es_default","N=NO,S=SI",cdo.getColValue("es_default"),"")%>
                </td>
			</tr>
			<%--<tr class="TextRow01">
					<td colspan="2">
					<jsp:include page="../common/bitacora.jsp" flush="true">
					<jsp:param name="audTable" value="tbl_sal_factor_prenatal"></jsp:param>
					<jsp:param name="audFilter" value="<%//="codigo="+id%>"></jsp:param>
					</jsp:include>
					</td>
				</tr>--%>
				<tr class="TextRow02">
					<td align="right" colspan="2">
						<cellbytelabel id="3">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="4">Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel id="5">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="6">Cerrar</cellbytelabel> 
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
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	
  cdo = new CommonDataObject();
  cdo.setTableName("tbl_sal_factor_prenatal");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  cdo.addColValue("orden",request.getParameter("orden"));
  cdo.addColValue("es_default",request.getParameter("es_default"));
 
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.setAutoIncCol("codigo");
    cdo.addPkColValue("codigo","");

	SQLMgr.insert(cdo);
	id = SQLMgr.getPkColValue("codigo");
  }
  else
  {
   cdo.setWhereClause("codigo="+request.getParameter("id"));
	

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/factor_prenatal_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/factor_prenatal_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/factor_prenatal_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>