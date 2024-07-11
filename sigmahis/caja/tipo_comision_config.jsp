<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"500003") || SecMgr.checkAccess(session.getId(),"500004"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String sec = request.getParameter("sec");
String desc = request.getParameter("desc");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("secuencia","0");
		cdo.addColValue("tipo_tarjeta",code);
		cdo.addColValue("rango_inicial","0");
		cdo.addColValue("rango_final","0");
	}
	else
	{
		if (code == null) throw new Exception("El Número de Trajeta no es válida. Por favor intente nuevamente!");

		
		 sql = "SELECT secuencia, tipo_tarjeta, comision, tipo_valor, rango_inicial, rango_final FROM tbl_cja_comision_tarjetas where tipo_tarjeta = "+code+" and secuencia = "+sec;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Tipos de Comisiones por Tarjetas Edición - '+document.title;
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

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("secuencia",cdo.getColValue("secuencia"))%>
            <%=fb.hidden("tipo_tarjeta",cdo.getColValue("tipo_tarjeta"))%>
            <%=fb.hidden("code",code)%>
            <%=fb.hidden("desc",desc)%>
				
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="12%">Secuencia</td>
					<td width="88%"><%=cdo.getColValue("secuencia")%></td>				
				</tr>							
				<tr class="TextRow01">
					<td>Tipo de Tarjeta</td>
					<td><%=cdo.getColValue("tipo_tarjeta")%> &nbsp;<%=desc%> </td>
				</tr>
                 <tr class="TextRow01">
					<td>Comisión</td>
					<td><%=fb.decBox("comision",cdo.getColValue("comision"),false,false,false,10,null,null,"")%></td>
				</tr>
                <tr class="TextRow01">
					<td>Tipo de Valor</td>
					<td><%=fb.select("tipo_valor","P=PORCENTAJE,M=MONETARIO",cdo.getColValue("tipo_valor"),"S")%></td>
				</tr>	
                <tr class="TextRow01">
					<td>Rango Inicial</td>
					<td><%=fb.decBox("rango_inicial",cdo.getColValue("rango_inicial"),false,false,false,15,null,null,"")%></td>
				</tr>
                 <tr class="TextRow01">
					<td>Rango Final</td>
					<td><%=fb.decBox("rango_final",cdo.getColValue("rango_final"),false,false,false,15,null,null,"")%></td>
				</tr>					
                <tr class="TextRow02">
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

code = request.getParameter("code");
desc = request.getParameter("desc");

  cdo = new CommonDataObject();

  cdo.setTableName("tbl_cja_comision_tarjetas");
  cdo.addColValue("tipo_tarjeta",request.getParameter("tipo_tarjeta")); 
  cdo.addColValue("tipo_valor",request.getParameter("tipo_valor")); 
  cdo.addColValue("comision",request.getParameter("comision")); 
  cdo.addColValue("rango_inicial",request.getParameter("rango_inicial")); 
  cdo.addColValue("rango_final",request.getParameter("rango_final")); 
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  
  

  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
   	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	
	cdo.setAutoIncCol("secuencia");
    cdo.setAutoIncWhereClause("tipo_tarjeta="+request.getParameter("tipo_tarjeta"));
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("secuencia="+request.getParameter("secuencia")+" and tipo_tarjeta="+request.getParameter("tipo_tarjeta"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/tipo_comision_list.jsp?mode=edit&codigo="+code+"&desc="+desc))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/tipo_comision_list.jsp?mode=edit&codigo="+code+"&desc="+desc)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/tipo_comision_list.jsp?mode=edit&codigo=<%=code%>&desc=<%=IBIZEscapeChars.forURL(desc)%>';
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