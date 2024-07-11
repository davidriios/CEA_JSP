
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
200017	VER LISTA DE TIPOS DE DEPOSITOS BANCARIOS
200019	AGREGAR TIPO DE DEPOSITOS BANCARIOS
200020	MODIFICAR TIPO DE DEPOSITOS BANCARIOS

<!-- Desarrollado por: José A. Acevedo C.     -->
<!-- Pantalla: "MANTENIMIENTO - REGISTRO TIPO DE DEPOSITOS BANCARIOS"  -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 14/09/2011                        -->
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200019") || SecMgr.checkAccess(session.getId(),"200020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
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
		if (id == null) throw new Exception("El Tipo Ajuste no es válido. Por favor intente nuevamente!");

		sql = "select td.codigo code, td.descripcion as descripcion, mov_banco movBanco, td.estado estado, td.observacion observacion from tbl_con_tipo_deposito td where td.codigo ="+id;
		
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
document.title="Tipo Depósito - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipo Depósito - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="TIPO DEPÓSITO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">Tipo Depósito</td>
				</tr>	
				<tr class="TextRow01">
					<td width="17%">C&oacute;digo</td>
					<td width="83%"><%=id%></td>  				
				</tr>	
										
				<tr class="TextRow01">
					<td>Descripción</td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45,100)%></td>
				</tr>
				
				<tr class="TextRow01">
				 <td>Afecta el Saldo</td>
				 <td><%=fb.select("movBanco","S=SI,N=NO",cdo.getColValue("movBanco"))%></td>
				</tr>	
				
				<tr class="TextRow01">
				  <td>Estado</td>
				  <td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%> </td>
				</tr>
				
				<tr class="TextRow01">
				<td>Observación</td>
				 <td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,35,4,300)%></td>
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

  cdo.setTableName("tbl_con_tipo_deposito");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("mov_banco",request.getParameter("movBanco"));
  cdo.addColValue("observacion",request.getParameter("observacion"));
  cdo.addColValue("usuario_modif",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modif","sysdate");
  
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion","sysdate"); 
  
	cdo.setAutoIncCol("codigo");
	SQLMgr.insert(cdo);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/tipo_deposito_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/tipo_deposito_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/bancos/tipo_deposito_list.jsp';
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
