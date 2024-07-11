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

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("codigo","0");
		cdo.addColValue("comision","0");
	}
	else
	{
		if (code == null) throw new Exception("El Número de Trajeta no es válida. Por favor intente nuevamente!");

		
		 sql = "SELECT codigo, depositar, estado, observacion, descripcion, nvl(comision,'0') comision,nvl(itbms,0) as itbms,nvl(calculo_comision,'A') AS calculo_comision FROM tbl_cja_tipo_tarjeta where codigo = "+code;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Tipos de Tarjetas Edición - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISIÓN - MANTENIMIENTO" />
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">		

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
				
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="12%">C&oacute;digo</td>
					<td width="88%"><%=cdo.getColValue("codigo")%></td>				
				</tr>							
				<tr class="TextRow01">
					<td>Descripci&oacute;n</td>
					<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,45)%></td>
				</tr>
                <tr class="TextRow01">
					<td>Depositar</td>
					<td><%=fb.select("depositar","S=SI,N=NO",cdo.getColValue("depositar"),"")%></td>
				</tr>	
				<%=fb.hidden("comision",cdo.getColValue("comision"))%>
                <!--<tr class="TextRow01">
					<td>Comisión</td>
					<td><%=fb.decBox("comision",CmnMgr.getFormattedDecimal(cdo.getColValue("comision")),false,false,false,10,null,null,"")%></td>
				</tr>-->
				<tr class="TextRow01">
					<td>Impuesto Comisión</td>
					<td><%=fb.decBox("itbms",cdo.getColValue("itbms"),false,false,false,10,10.2,null,null,"")%></td>
				</tr>		
                <tr class="TextRow01">
					<td>Observación</td>
					<td><%=fb.textBox("observacion",cdo.getColValue("observacion"),false,false,false,45)%></td>
				</tr>	
				 <tr class="TextRow01">
					<td>Calculo de Comision</td>
					<td><%=fb.select("calculo_comision","T=POR TRANSACCION,A=AGRUPADA",cdo.getColValue("calculo_comision"),"")%></td>
				</tr>		
				<tr class="TextRow01">
					<td>Estado</td>
					<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),"")%></td>
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
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_cja_tipo_tarjeta");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  cdo.addColValue("depositar",request.getParameter("depositar"));
    cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("comision",request.getParameter("comision")); 
  cdo.addColValue("observacion",request.getParameter("observacion")); 
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("itbms",request.getParameter("itbms"));  
  cdo.addColValue("calculo_comision",request.getParameter("calculo_comision"));   

  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
   	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	
	cdo.setAutoIncCol("codigo");

	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("codigo"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/tipo_tarjeta_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/tipo_tarjeta_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/tipo_tarjeta_list.jsp';
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