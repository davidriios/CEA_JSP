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
		if (id == null) throw new Exception("El Motivo de Faltas no es válido. Por favor intente nuevamente!");

sql = "select codigo, descripcion, permisible, signos, tiempo_permitido, cant_falta, sumar_enf, tiempo_des, pldescontar, plsumar, descontar from tbl_pla_motivo_falta where codigo="+id;
		cdo = SQLMgr.getData(sql);
	}



%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Motivos de Faltas - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Motivos de Faltas - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSO HUMANOS - MANTENIMIENTO - MOTIVOS DE FALTAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	  <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%> <%=fb.hidden("id",id)%>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr class="TextRow01" >
          <td width="20%">&nbsp;C&oacute;digo</td>
          <td colspan="3">&nbsp;<%=id%></td>
        </tr>
        <tr class="TextRow01">
          <td width="20%">&nbsp;Descripci&oacute;n</td>
          <td width=30><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,40,50)%></td>
          <td  width="20">&nbsp;Abreviatura</td>
          <td width="30"><%=fb.textBox("signos",cdo.getColValue("signos"),true,false,false,5,5)%></td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;Permisible</td>
          <td><%=fb.checkbox("permisible","S",(cdo.getColValue("permisible")!=null && cdo.getColValue("permisible").equalsIgnoreCase("S")),false)%></td>
          <td>&nbsp;Cantidad de Falta</td>
          <td><%=fb.intBox("cantidad",cdo.getColValue("cant_falta"),false,false,false,10,2)%></td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;Sumar a Incapacidad</td>
          <td><%=fb.checkbox("incapacidad","S",(cdo.getColValue("sumar_enf")!=null && cdo.getColValue("sumar_enf").equalsIgnoreCase("S")),false)%></td>
          <td>&nbsp;Tiempo Permitido</td>
          <td><%=fb.intBox("tiempo",cdo.getColValue("tiempo_permitido"),false,false,false,10,3)%></td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;Descontar</td>
          <td><%=fb.select("descontar","S=Si,N=No",cdo.getColValue("descontar"))%></td>
          <td>&nbsp;Tiempo a Descontar</td>
          <td><%=fb.decBox("tdescontar",cdo.getColValue("tiempo_des"),false,false,false,10,2.2)%> </td>
				</tr>
        <tr class="TextRow01">
          <td>&nbsp;Descontar de</td>
          <td><%=fb.select("desconta","OD=OTRAS DEDUCCIONES,SR=SALARIO REGULAR,NA=No Aplica",cdo.getColValue("pldescontar"))%></td>
          <td>&nbsp;Sumar a</td>
          <td><%=fb.select("sumar","OE=OTRAS EXTRAS,DM=DEVOLUCION MULTAS,NA=No Aplica",cdo.getColValue("plsumar"))%></td>
        </tr>
        <tr class="TextRow02">
          <td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false)%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
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
  cdo.setTableName("tbl_pla_motivo_falta");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  cdo.addColValue("signos",request.getParameter("signos"));
  if(request.getParameter("permisible")==null) cdo.addColValue("permisible","N");
  else cdo.addColValue("permisible",request.getParameter("permisible"));
  cdo.addColValue("cant_falta",request.getParameter("cantidad"));
  if(request.getParameter("incapacidad")==null) cdo.addColValue("sumar_enf","N");
  else cdo.addColValue("sumar_enf",request.getParameter("incapacidad")); 
  cdo.addColValue("tiempo_permitido",request.getParameter("tiempo")); 
  cdo.addColValue("descontar",request.getParameter("descontar")); 
  cdo.addColValue("tiempo_des",request.getParameter("tdescontar")); 
  //if(request.gerParameter("pldescontar")=="NA") cdo.addColValue("desconta","");
   cdo.addColValue("pldescontar",request.getParameter("desconta"));
  if(request.getParameter("plsumar")=="NA") cdo.addColValue("sumar","");
  else cdo.addColValue("plsumar",request.getParameter("sumar")); 
  
  if (mode.equalsIgnoreCase("add"))
  {

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/motivofalta_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/motivofalta_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/motivofalta_list.jsp';
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