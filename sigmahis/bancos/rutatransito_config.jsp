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
=================================================================================
=================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

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
    code = "0";
		cdo.addColValue("ruta","");
  }
  else
  {
    if (code == null) throw new Exception("La Ruta no es válida. Por favor intente nuevamente!");
     
    sql = "SELECT ruta, nombre_banco as nombre, observacion FROM tbl_adm_ruta_transito WHERE ruta='"+code+"'";
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
document.title=" Ruta Tránsito Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title="Ruta Tránsito Edición - "+document.title;
<%}%>

function checkCode(obj)
{
  return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_ruta_transito','ruta=\''+obj.value+'\'','<%=cdo.getColValue("ruta")%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CLÍNCA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
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
<%fb.appendJsValidation("if(checkCode(document.form1.ruta))error++;");%>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr class="TextRow02">
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr class="TextRow01">
        <td width="12%">Ruta</td>
        <td width="88%"><%=fb.textBox("ruta",cdo.getColValue("ruta"),true,false,mode.equals("edit"),15,9,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>        
      </tr>             
      <tr class="TextRow01">
        <td>Nombre Banco</td>
        <td><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,false,45,100)%></td>
      </tr>
      <tr class="TextRow01">
        <td>Observaci&oacute;n</td>
        <td><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,35,4,100)%></td>
      </tr>           
      <tr>
		  <td colspan="2">
			  <jsp:include page="../common/bitacora.jsp" flush="true">
			  <jsp:param name="audTable" value="tbl_adm_ruta_transito"></jsp:param>
			  <jsp:param name="audFilter" value="<%="ruta='"+code+"'"%>"></jsp:param>
			  </jsp:include>
		  </td>
	  </tr>					
	  <tr class="TextRow02">
		  <td align="right" colspan="2">
			  Opciones de Guardar: 
			  <%=fb.radio("saveOption","N")%>Crear Otro 
			  <%=fb.radio("saveOption","O")%>Mantener Abierto 
			  <%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
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
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close  
  code = request.getParameter("code");
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_adm_ruta_transito"); 
  cdo.addColValue("ruta",request.getParameter("ruta"));
  cdo.addColValue("nombre_banco",request.getParameter("nombre"));
  cdo.addColValue("observacion",request.getParameter("observacion"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion","sysdate"); 
  
  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {    
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");
		//cdo.addPkColValue("ruta","");
	
    SQLMgr.insert(cdo);
		code = request.getParameter("ruta");   
  }
  else
  {
    cdo.setWhereClause("ruta='"+request.getParameter("code")+"'");	
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/rutatransito_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/rutatransito_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/bancos/rutatransito_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>