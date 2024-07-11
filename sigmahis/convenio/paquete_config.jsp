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
		cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
	}
	else
	{
		if (id == null) throw new Exception("El Paquete no es válido. Por favor intente nuevamente!");

sql = "";
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
document.title="Paquetes - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Paquetes - Edición - "+document.title;
<%}%>
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONVENIO - MANTENIMIENTO - PAQUETES"></jsp:param>
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
				<td>&nbsp;<cellbytelabel>Tipo</cellbytelabel></td>
				<td><%=fb.intBox("codetipo",cdo.getColValue("codetipo"),false,false,true,5)%>
					<%=fb.textBox("tipo",cdo.getColValue("tipo"),false,false,true,20)%>
					<%=fb.button("btntipo","IR",true,false,null,null,"onClick=\"javascript:tipos();\"")%>
				</td>
				<td>&nbsp;<cellbytelabel>Paquete</cellbytelabel></td>
				<td><%=fb.intBox("codepaquete",cdo.getColValue("codepaquete"),false,false,false,5)%>
					<%=fb.textBox("paquete",cdo.getColValue("paquete"),false,false,false,20)%>			
			</tr>							
			<tr class="TextRow01" >
				<td width="20%">&nbsp;<cellbytelabel>Fecha</cellbytelabel></td>
				<td width="30%"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								</jsp:include>
				</td>
				<td width="20%">&nbsp;<cellbytelabel>Estado</cellbytelabel></td>
				<td width="30%"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Precio</cellbytelabel></td>
				<td><%=fb.decBox("precio",cdo.getColValue("precio"),false,false,false,15)%></td>
				<td>&nbsp;<cellbytelabel>Procedencia</cellbytelabel></td>
				<td><%=fb.intBox("codeprocedencia",cdo.getColValue("codeprocedencia"),false,false,true,5)%>
					<%=fb.textBox("procedencia",cdo.getColValue("procedencia"),false,false,true,20)%>
					<%=fb.button("btnprocedencia","IR",true,false,null,null,"onClick=\"javascript:procedencias();\"")%>
				</td>
			</tr>
			
			<tr class="TextRow01">
				<td>&nbsp;<cellbytelabel>Almac&eacute;n</cellbytelabel></td>
				<td colspan="3"><%=fb.intBox("codealmacen",cdo.getColValue("codealmacen"),false,false,true,5)%>
					<%=fb.textBox("almacen",cdo.getColValue("almacen"),false,false,true,20)%>
					<%=fb.button("btnalmacen","IR",true,false,null,null,"onClick=\"javascript:almacenes();\"")%></td>			
			</tr>
			<tr>
				<td colspan="4">
					<table width="100%">
						<tr class="TextRow01">
							<td width="5%">&nbsp;<cellbytelabel>No</cellbytelabel>.</td>
							<td width="20%">&nbsp;<cellbytelabel>Tipo de Servicio</cellbytelabel></td>
							<td width="10%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="15%">&nbsp;D<cellbytelabel>escripci&oacute;n del Servicio</cellbytelabel></td>
							<td width="10%">&nbsp;<cellbytelabel>Cantidad</cellbytelabel></td>
							<td width="10%">&nbsp;<cellbytelabel>Precio Venta</cellbytelabel></td>
							<td width="10%">&nbsp;<cellbytelabel>Total de Venta</cellbytelabel></td>
							<td width="10%">&nbsp;P<cellbytelabel>recio Pag</cellbytelabel>.</td>
							<td width="10%">&nbsp;<cellbytelabel>Total Paq</cellbytelabel>.</td>
						</tr>
						<tr class="TextRow01">
							<td><%=fb.intBox("numero",cdo.getColValue("numero"),false,false,false,3,"Text10",null,null)%></td>
							<td><%=fb.intBox("servicio",cdo.getColValue("servicio"),false,false,false,3,"Text10",null,null)%>
							<%=fb.textBox("tipo",cdo.getColValue("tipo"),false,false,false,15,"Text10",null,null)%>
							<%=fb.button("btntipos","Ir",true,false,"Text10",null,"onClick=\"javascript:servicios();\"")%>
							</td>
							<td><%=fb.intBox("code",cdo.getColValue("code"),false,false,false,3,"Text10",null,null)%>
							<%=fb.button("btntdescripcion","Ir",true,false,"Text10",null,"onClick=\"javascript:descripcion();\"")%>
							</td>
							<td><%=fb.textBox("servicios",cdo.getColValue("servicios"),false,false,false,5,"Text10",null,null)%></td>
							<td><%=fb.intBox("cantidad",cdo.getColValue("cantidad"),false,false,false,5,"Text10",null,null)%></td>
							<td><%=fb.decBox("precio",cdo.getColValue("precio"),false,false,false,5,"Text10",null,null)%></td>
							<td><%=fb.decBox("total",cdo.getColValue("total"),false,false,false,5,"Text10",null,null)%></td>
							<td><%=fb.decBox("preciopaq",cdo.getColValue("preciopaq"),false,false,false,5,"Text10",null,null)%></td>
							<td><%=fb.intBox("totalpaq",cdo.getColValue("totalpaq"),false,false,false,5,"Text10",null,null)%></td>
						</tr>
						<tr class="TextRow01">
							<td colspan="6" align="right">&nbsp;<cellbytelabel>Total</cellbytelabel></td>
							<td><%=fb.textBox("total",cdo.getColValue("total"),false,false,false,5)%></td>
							<td>&nbsp;</td>
							<td><%=fb.textBox("totalprecio",cdo.getColValue("totalprecio"),false,false,false,5)%></td>
						</tr>
					</table>
				</td>				
			</tr>
			
			<tr class="TextRow02">
				<td colspan="4" align="right"> <%=fb.submit("save","Guardar",true,false)%>
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/convenio/paquete_config.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/convenio/paquete_config.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/convenio/paquete_config.jsp';
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