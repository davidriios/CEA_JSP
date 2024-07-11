<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
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
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("codigo","0");
	}
	else
	{
		if (id == null) throw new Exception("El número de la Categoría no es válido. Por favor intente nuevamente!");

		sql=" select codigo, nombre, estado,orden from tbl_inv_cat_eq_comodatos where compania = "+(String) session.getAttribute("_companyId")+" and codigo = "+id; 
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Categoría Equipos a comodato - "+document.title;
</script>
<script language="javascript">

function _doSubmit(){
  var nombre = document.getElementById("nombre").value;
  var _canProceed = true;
  if (!nombre){
	 alert("Por favor llena el campo de Nombre!");
     _canProceed = false; 
  }
  if (_canProceed) document.getElementById("form1").submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ACTIVOS FIJOS - REGISTRO CAREGORIA DE EQUIPOS COMODATO"></jsp:param>
</jsp:include>

<table width="99%" cellpadding="0" cellspacing="0" border="0" align="center">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

			<!-- =============================   F O R M   S T A R T   H E R E   ============================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<tr class="TextRow02">
				<td colspan="5">&nbsp;</td>
			</tr>
				<tr class="TextHeader">
					<td colspan="5" align="left">&nbsp;Categor&iacute;a Equipos Comodato</td>
				</tr>	
				<tr class="TextRow01">
					<td width="10%">&nbsp;No Categor&iacute;a</td>
					<td width="10%" align="center"><%=cdo.getColValue("codigo")%></td>				
					<td width="10%" align="center">&nbsp;Nombre</td>
					<td width="50%"><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,80,60)%></td>
					<td width="20%"><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%></td>
				</tr>	
				<tr class="TextRow01">
					<td colspan="2">&nbsp;Orden</td>
					<td colspan="3"><%=fb.intBox("orden",cdo.getColValue("orden"),true,false,false,2,5)%></td>
				</tr>	
						
				<tr class="TextRow02">
					<td colspan="5" align="right">
					<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:_doSubmit()\"")%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				</tr>	
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				 <%=fb.formEnd(true)%>
				<!-- =========================   F O R M   E N D   H E R E   ========================= -->
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
    cdo = new CommonDataObject();
	cdo.setTableName("tbl_inv_cat_eq_comodatos");
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo.addColValue("nombre",request.getParameter("nombre"));
	cdo.addColValue("estado",request.getParameter("estado")); 
	cdo.addColValue("orden",request.getParameter("orden")); 
	
	if (mode.equalsIgnoreCase("add")){
		cdo.setAutoIncCol("codigo");
		cdo.setAutoIncWhereClause("compania = "+(String) session.getAttribute("_companyId"));
		SQLMgr.insert(cdo);
    }else{
       cdo.setWhereClause("compania = "+(String) session.getAttribute("_companyId")+" and codigo = "+request.getParameter("id"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_cat_equipo_comodato.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/list_cat_equipo_comodato.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/list_cat_equipo_comodato.jsp';
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