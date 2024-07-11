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
/*
==================================================================================
500037	VER LISTA DE DIAGNÓSTICO
500039	AGREGAR  DIAGNÓSTICO
500040	MODIFICAR DIAGNÓSTICO
==================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500039") || SecMgr.checkAccess(session.getId(),"500040"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("code","");
	}
	else
	{
	
	if (id == null) throw new Exception("El Diagnóstico no es válido. Por favor intente nuevamente!");

		sql ="select a.codigo as code, a.categoria , c.descripcion as descripcioncat , a.nombre_eng,a.nombre_esp, a.observacion, a.estatus, a.usuario_creacion, a.usuario_modificacion, a.fecha_creacion, a.fecha_modificacion from tbl_cds_diagnostico_enf a,  tbl_cds_cat_diagenfermera c where  a.id='"+id+"' and c.codigo=a.categoria";
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
document.title="Diagnóstico - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Diagnóstico - Edición - "+document.title;
<%}%>

function verCategoria()
{
	abrir_ventana1('../admision/enfcategoriadiagnostico_list.jsp?fp=diag');
}

function enfermedad()
{
	abrir_ventana1('../admision/enfermedad_list.jsp');
}

function checkCode(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_cds_diagnostico_enf','codigo=\''+obj.value+'\'','<%=cdo.getColValue("code")%>');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DIAGNÓSTICO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%fb.appendJsValidation("if(checkCode(document.form1.code))error++;");%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;<cellbytelabel id="1">Diagn&oacute;stico</cellbytelabel></td>
				</tr>	
				<tr class="TextRow01">
					<td width="25%">&nbsp;<cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
					<td width="75%"><%=fb.textBox("code",cdo.getColValue("code"),true,false,false,15,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>				
				</tr>		
				
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Categor&iacute;a</cellbytelabel></td>
					<td><%=fb.intBox("categoria",cdo.getColValue("categoria"),true,false,true,10)%>
					<%=fb.button("btncategoria","...",true,false,null,null,"onClick=\"javascript:verCategoria()\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td width="25%">&nbsp;<cellbytelabel id="4">Descripci&oacute;n Categor&iacute</cellbytelabel>;a</td>
				<td><%=fb.textBox("namecat",cdo.getColValue("descripcioncat"),false,false,true,60)%></td>			
				</tr>						
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="5">Nombre Ingl&eacute;s</cellbytelabel></td>
					<td><%=fb.textBox("nombre_eng",cdo.getColValue("nombre_eng"),true,false,false,60)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="6">Nombre Espa&ntilde;ol</cellbytelabel></td>
					<td><%=fb.textBox("nombre_esp",cdo.getColValue("nombre_esp"),true,false,false,60)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="7">Observaciones</cellbytelabel></td>
					<td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,46,4)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="8">Estatus</cellbytelabel></td>
					<td><%=fb.select("estatus","A=Activo,I=Inactivo",cdo.getColValue("estatus"))%></td>
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
  String enfermedades = "";
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_cds_diagnostico_enf");   
  cdo.addColValue("codigo",request.getParameter("code"));
  cdo.addColValue("categoria",request.getParameter("categoria")); 
  cdo.addColValue("nombre_eng",request.getParameter("nombre_eng")); 
  cdo.addColValue("nombre_esp",request.getParameter("nombre_esp")); 
  cdo.addColValue("observacion",request.getParameter("observacion")); 
  cdo.addColValue("estatus",request.getParameter("estatus"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {
       cdo.setAutoIncCol("id");
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
  	    cdo.addColValue("fecha_creacion","sysdate");
		SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("id='"+request.getParameter("id")+"'");
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

	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/enfdiagnostico_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/enfdiagnostico_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/enfdiagnostico_list.jsp';
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