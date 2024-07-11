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
cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("facturacion","");
		cdo.addColValue("admision","");
	}
	else
	{
		if (id == null) throw new Exception("El Consulta de Morosidad Por Cliente no es válido. Por favor intente nuevamente!");

		//sql = "";
		cdo = SQLMgr.getData(sql);
	}
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Consulta de Morosidad Por Cliente - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Consulta de Morosidad Por Cliente - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - CONSULTA DE MOROSIDAD POR CLIENTE"></jsp:param>
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
				<td width="18%">&nbsp;<cellbytelabel>Primer Apellido</cellbytelabel></td>
				<td width="32%"><%=fb.intBox("apellido",cdo.getColValue("apellido"),false,false,true,30)%>
				<%=fb.button("btntipos",".:.",true,false,null,null,"onClick=\"javascript:agregar();\"")%>
				</td>
				<td width="18%">&nbsp;<cellbytelabel>Primer Nombre</cellbytelabel></td>
				<td width="32%"><%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,true,30)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>C&eacute;dula</cellbytelabel></td>
				<td><%=fb.intBox("provincia",cdo.getColValue("provincia"),false,false,true,3)%><%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,true,3)%><%=fb.intBox("tomo",cdo.getColValue("tomo"),false,false,true,3)%>
					<%=fb.intBox("asiento",cdo.getColValue("asiento"),false,false,true,3)%>	
					</td>
				<td>&nbsp;<cellbytelabel>Paciente</cellbytelabel></td>
				<td><%=fb.textBox("paciente",cdo.getColValue("paciente"),false,false,true,30)%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Fecha de Nacimiento</cellbytelabel></td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
							</jsp:include>
							</td></td>
				<td>&nbsp;<cellbytelabel>Pasaporte</cellbytelabel></td>
				<td><%=fb.textBox("pasaporte",cdo.getColValue("pasaporte"),false,false,true,30)%></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">&nbsp;<cellbytelabel>Detalle de la Morosidad del Paciente</cellbytelabel></td>
			</tr>
			<tr>
				<td colspan="4">
					<table width="100%">
						<tr class="TextRow01">
							<td width="13%" align="center">&nbsp;<cellbytelabel>Fecha de Facturaci&oacute;n</cellbytelabel></td>
							<td width="7%" align="center">&nbsp;<cellbytelabel>N&uacute;mero de Factura</cellbytelabel></td>
							<td width="13%" align="center">&nbsp;<cellbytelabel>Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="8%" align="center">&nbsp;<cellbytelabel>Saldo del Mes Anterior</cellbytelabel></td>
							<td width="6%" align="center">&nbsp;<cellbytelabel>Montos D&eacute;bitos del Mes</cellbytelabel></td>
							<td width="6%" align="center">&nbsp;<cellbytelabel>Montos Cr&eacute;dito del Mes</cellbytelabel></td>
							<td width="6%" align="center">&nbsp;<cellbytelabel>Saldo Actual</cellbytelabel></td>
							<td width="7%" align="center">&nbsp;<cellbytelabel>Saldo Corriente</cellbytelabel></td>
							<td width="7%" align="center">&nbsp;<cellbytelabel>Saldo a 30 D&iacute;as</cellbytelabel></td>
							<td width="7%" align="center">&nbsp;<cellbytelabel>Saldo a 60 D&iacute;as</cellbytelabel></td>
							<td width="6%" align="center">&nbsp;<cellbytelabel>Saldo a 90 D&iacute;as</cellbytelabel></td>
							<td width="7%" align="center">&nbsp;<cellbytelabel>Saldo a 120 D&iacute;as</cellbytelabel></td>
							<td width="7%" align="center">&nbsp;<cellbytelabel>Saldo a 150 D&iacute;as</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="facturacion" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("facturacion")%>" />
							</jsp:include>
							</td>
							<td><%=fb.intBox("numfact",cdo.getColValue("numfact"),false,false,false,5,"Text10",null,null)%></td>
							<td><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="admision" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("admision")%>" />
							</jsp:include>
							</td>
							<td><%=fb.decBox("saldoant",cdo.getColValue("saldoant"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("montosdb",cdo.getColValue("montosdb"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("montocr",cdo.getColValue("montocr"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("saldoA",cdo.getColValue("saldoA"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("saldoC",cdo.getColValue("saldoC"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("saldo30",cdo.getColValue("saldo30"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("saldo60",cdo.getColValue("saldo60"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("saldo90",cdo.getColValue("saldo90"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("saldo120",cdo.getColValue("saldo120"),false,false,false,5,"Text10",null,null)%>
							</td>
							<td><%=fb.decBox("saldo150",cdo.getColValue("saldo150"),false,false,false,5,"Text10",null,null)%>
							</td>
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxc/inmueble_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxc/inmueble_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/cxc/inmueble_list.jsp';
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