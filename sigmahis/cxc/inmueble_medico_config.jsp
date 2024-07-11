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
cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("inicio","");
		cdo.addColValue("fin","");
		
	}
	else
	{
		if (id == null) throw new Exception("El Contrato de Alquiler no es válido. Por favor intente nuevamente!");

sql = "";
		cdo = SQLMgr.getData(sql);
	}



%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/time_base.jsp" %>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Contrato de Alquiler - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Contrato de Alquiler - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - MANTENIMIENTO - CONTRATO DE ALQUILER"></jsp:param>
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
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="18%">&nbsp;<cellbytelabel>Inmueble M&eacute;dico</cellbytelabel></td>
				<td width="32%"><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,false,15)%></td>
				<td width="20%">&nbsp;<cellbytelabel>Inmuebles</cellbytelabel></td>
				<td width="30%"><%=fb.intBox("tipos",cdo.getColValue("tipos"),false,false,false,5)%>
					<%=fb.textBox("inmuebles",cdo.getColValue("inmuebles"),false,false,false,20)%>	
					<%=fb.button("btntipos",".:.",true,false,null,null,"onClick=\"javascript:agregar();\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Fecha de Contrato</cellbytelabel></td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fecha" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
					</jsp:include>
				</td>
				<td>&nbsp;<cellbytelabel>Inicio</cellbytelabel></td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="inicio" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("inicio")%>" />
					</jsp:include></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Final</cellbytelabel></td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="fin" />
					<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fin")%>" />
					</jsp:include></td>
				<td>&nbsp;<cellbytelabel>Otorgado A</cellbytelabel></td>
				<td><%=fb.select("otorgado","M=MÉDICO,E=EMPRESA",cdo.getColValue("otorgado"))%>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Empresa</cellbytelabel></td>
				<td><%=fb.intBox("code",cdo.getColValue("code"),false,false,false,5)%>
					<%=fb.textBox("name",cdo.getColValue("name"),false,false,false,20)%>
					<%=fb.button("btnempresa",".:.",true,false,null,null,"onClick=\"javascript:agregar();\"")%>
				</td>
				<td>&nbsp;<cellbytelabel>M&eacute;dico</cellbytelabel></td>
				<td><%=fb.intBox("code",cdo.getColValue("code"),false,false,false,5)%>
					<%=fb.textBox("medico",cdo.getColValue("medico"),false,false,false,20)%>
					<%=fb.button("btnmedico",".:.",true,false,null,null,"onClick=\"javascript:agregar();\"")%>
				</td>		
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Contacto</cellbytelabel></td>
				<td><%=fb.textBox("contacto",cdo.getColValue("contacto"),false,false,false,15)%></td>
				<td>&nbsp;Monto Mensual</td>
				<td><%=fb.decBox("mensual",cdo.getColValue("mensual"),false,false,false,15)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>H&aacute;bito</cellbytelabel></td>
				<td><%=fb.intBox("codehabito",cdo.getColValue("codehabito"),false,false,false,15)%>
					<%=fb.textBox("habito",cdo.getColValue("habito"),false,false,false,15)%>
					<%=fb.button("btnhabito",".:.",true,false,null,null,"onClick=\"javascript:agrego();\"")%>
				<td>&nbsp;<cellbytelabel>Estado</cellbytelabel></td>
				<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
			</tr>
			<tr class="TextRow01">	
				<td>&nbsp;<cellbytelabel>Hora Entrada</cellbytelabel></td>
				<td><jsp:include page="../common/time.jsp" flush="true">
						<jsp:param name="noOfTimeTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="entrada" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("entrada")==null)?"":cdo.getColValue("entrada")%>" />
					</jsp:include>
				</td>	
				<td>&nbsp;<cellbytelabel>Hora Salida</cellbytelabel></td>
				<td><jsp:include page="../common/time.jsp" flush="true">
						<jsp:param name="noOfTimeTBox" value="1" />
						<jsp:param name="nameOfTBox1" value="salidas" />
						<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("salidas")==null)?"":cdo.getColValue("salidas")%>" />
					</jsp:include>
				</td>
			</tr>
			
			<tr>
				<td colspan="4">
					<table width="100%">
						<tr class="TextRow01">
							<td width="25%">&nbsp;<cellbytelabel>Comentarios de la Empresa</cellbytelabel></td>
							<td width="75%"><%=fb.textarea("comentario",cdo.getColValue("comentario"),false,false,false,30,2)%> </td>
						</tr>
					</table>
				</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="4">&nbsp;</td>
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

  
  if (mode.equalsIgnoreCase("add"))
  {

 

	SQLMgr.insert(cdo);
  }
  else
  {
   

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/inmueble_medico_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/inmueble_medico_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/cxc/inmueble_medico_list.jsp';
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