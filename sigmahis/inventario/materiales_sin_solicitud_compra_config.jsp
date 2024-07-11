
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

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
	cdo.addColValue("fechafact","");
	}
	else
	{
		
		sql = "";
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script> 
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Materiales sin Orden de Compra - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Materiales sin Orden de Compra - Edición - "+document.title;
<%}%>
</script>
<script language="javascript">
function almacenes()
{
abrir_ventana1('../inventario/list_almacen.jsp');
}

function documentoss()
{
abrir_ventana1('../inventario/list_documento.jsp?fp=sinsolicitud');
}

function proveedores()
{
abrir_ventana1('../inventario/list_proveedor.jsp');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MATERIALES SIN SOLICITUD DE COMPRA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2" align="left">&nbsp;Recepci&oacute;n</td>
			</tr>	
			<tr>
				<td colspan="2">
					<table width="100%" cellpadding="0" cellspacing="1">
						<tr class="TextRow01">
							<td width="20%">&nbsp;Recepci&oacute;n No.</td>
							<td width="28%">
							<%=fb.intBox("numero",cdo.getColValue("numero"),false,false,false,10)%>
							<%=fb.intBox("numero",cdo.getColValue("numero"),false,false,false,10)%>
							</td>	
							<td width="10%" align="right">Fecha&nbsp;</td>	
							<td width="15%"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								</jsp:include>
							</td>
							<td width="12%" align="right">Estado&nbsp;</td>
							<td width="15%"><%=fb.select("estado","R=Recibido",cdo.getColValue("estado"))%></td>
						</tr>
					</table>
				</td>
			</tr>									
			<tr class="TextRow01">
				<td width="20%">&nbsp;Documento Recepci&oacute;n</td>
				<td width="80%"><%=fb.intBox("codigos",cdo.getColValue("codigos"),false,false,true,10)%>
					<%=fb.textBox("otro",cdo.getColValue("otro"),false,false,false,53)%>
					<%=fb.button("btndocumento","...",true,false,null,null,"onClick=\"javascript:documentoss();\"")%>
				</td>								
			</tr>
			<tr class="TextHeader">
				<td colspan="2">&nbsp;Recibido Por</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Almac&eacute;n</td>
				<td><%=fb.intBox("codigo",cdo.getColValue("codigo"),false,false,true,10)%>
					<%=fb.textBox("almacen",cdo.getColValue("almacen"),false,false,false,53)%>
					<%=fb.button("btnalmacen","...",true,false,null,null,"onClick=\"javascript:almacenes();\"")%>
				</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2">Entregado Por</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Proveerdor</td>
				<td><%=fb.intBox("codig",cdo.getColValue("codig"), false,false,true,10)%>
					<%=fb.textBox("proveedor",cdo.getColValue("proveedor"),false,false,false,53)%>
					<%=fb.button("btnproveedor","...",true,false,null,null,"onClick=\"javascript:proveedores();\"")%>
				</td>								
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Factura No.</td>
				<td><%=fb.intBox("factura",cdo.getColValue("factura"), false,false,false,10)%></td>
			</tr>		
			<tr class="TextRow01">
				<td>&nbsp;Fecha de Factura</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fechafact" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechafact")%>" />
								</jsp:include>
				</td>
			</tr>	
			<tr class="TextRow01">
				<td>&nbsp;Observaciones</td>
				<td><%=fb.textarea("observaciones",cdo.getColValue("observaciones"),false,false,false,52,3)%>
			</tr>			
			<tr>
				<td colspan="2">						  
					<iframe name="detalle" frameborder="0"  width="100%" height="176" src="../inventario/detalle_sin_solicitud_compra.jsp" id="detalle" scrolling="no"  ></iframe>
				</td>
			</tr>			
			<tr class="TextRow02">
				<td colspan="2" align="right"> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/materiales_sin_solicitud_compra_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/materiales_sin_solicitud_compra_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/materiales_sin_solicitud_compra_list.jsp';
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
