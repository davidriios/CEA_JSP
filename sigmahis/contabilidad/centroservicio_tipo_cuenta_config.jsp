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
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200019") || SecMgr.checkAccess(session.getId(),"200020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();	
String sql = "";
String mode = request.getParameter("mode");
String tipoServCode = request.getParameter("tipoServCode");
String centroServCode = request.getParameter("centroServCode");
String filter = " and recibe_mov='S'";

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		tipoServCode = "0";
		centroServCode = "0";		
	}
	else
	{
		if (tipoServCode == null) throw new Exception("El Tipo de Servicio no es válido. Por favor intente nuevamente!");
		if (centroServCode == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");

		sql = "SELECT b.descripcion as tipoServ, c.descripcion as centroServ, a.cg_cta1, a.cg_cta2, a.cg_cta3, a.cg_cta4, a.cg_cta5, a.cg_cta6, a.cg_compania, d.descripcion as cuentaIngre, a.cos_cta1, a.cos_cta2, a.cos_cta3, a.cos_cta4, a.cos_cta5, a.cos_cta6, e.descripcion as cuentaCost FROM tbl_cds_ts_x_centro a, tbl_cds_tipo_servicio b, tbl_cds_centro_servicio c, tbl_con_catalogo_gral d, tbl_con_catalogo_gral e WHERE a.tipo_servicio=b.codigo and a.centro_servicio=c.codigo and a.cg_cta1=d.cta1(+) and a.cg_cta2=d.cta2(+) and a.cg_cta3=d.cta3(+) and a.cg_cta4=d.cta4(+) and a.cg_cta5=d.cta5(+) and a.cg_cta6=d.cta6(+) and a.cg_compania=d.compania(+) and a.cos_cta1=e.cta1(+) and a.cos_cta2=e.cta2(+) and a.cos_cta3=e.cta3(+) and a.cos_cta4=e.cta4(+) and a.cos_cta5=e.cta5(+) and a.cos_cta6=e.cta6(+) and a.cg_compania=e.compania(+) and a.tipo_servicio="+tipoServCode+" and a.centro_servicio="+centroServCode;
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
document.title="Centro de Servicio x Tipo y Cuenta Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Centro de Servicio x Tipo y Cuenta Edición - "+document.title;
<%}%>

function addCentro()
{
   abrir_ventana1('../admision/habitacion_centroservicio_list.jsp?id=4');
}
function addTipo()
{
   abrir_ventana1('../admision/habitacion_tiposervicio_list.jsp?id=3');
}
function addCtaIngreso()
{
   abrir_ventana1('ctabancaria_catalogo_list.jsp?id=11&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}
function addCtaCosto()
{
   abrir_ventana1('ctabancaria_catalogo_list.jsp?id=12&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
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
			<tr class="TextRow01">
				<td width="20%">Centro de Servicio</td>
				<td width="80%"><%=fb.intBox("centroServCode",centroServCode,true,false,true,11)%><%=fb.textBox("centroServ",cdo.getColValue("centroServ"),false,false,true,70)%><%=fb.button("btncentro","...",true,mode.equals("edit"),null,null,"onClick=\"javascript:addCentro()\"")%></td>				
			</tr>							
			<tr class="TextRow01">
				<td>Tipo de Servicio</td>
				<td><%=fb.intBox("tipoServCode",tipoServCode,true,false,true,11)%><%=fb.textBox("tipoServ",cdo.getColValue("tipoServ"),false,false,true,70)%><%=fb.button("btntipo","...",true,mode.equals("edit"),null,null,"onClick=\"javascript:addTipo()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>Cuenta de Ingreso</td>
				<td><%=fb.textBox("cg_cta1",cdo.getColValue("cg_cta1"),false,false,true,3)%><%=fb.textBox("cg_cta2",cdo.getColValue("cg_cta2"),false,false,true,3)%><%=fb.textBox("cg_cta3",cdo.getColValue("cg_cta3"),false,false,true,3)%><%=fb.textBox("cg_cta4",cdo.getColValue("cg_cta4"),false,false,true,3)%><%=fb.textBox("cg_cta5",cdo.getColValue("cg_cta5"),false,false,true,3)%><%=fb.textBox("cg_cta6",cdo.getColValue("cg_cta6"),false,false,true,3)%><%=fb.textBox("cuentaIngre",cdo.getColValue("cuentaIngre"),false,false,true,38)%><%=fb.button("btnctaingreso","...",true,false,null,null,"onClick=\"javascript:addCtaIngreso()\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td>Cuenta de Costos/Gastos</td>
				<td><%=fb.textBox("cos_cta1",cdo.getColValue("cos_cta1"),false,false,true,3)%><%=fb.textBox("cos_cta2",cdo.getColValue("cos_cta2"),false,false,true,3)%><%=fb.textBox("cos_cta3",cdo.getColValue("cos_cta3"),false,false,true,3)%><%=fb.textBox("cos_cta4",cdo.getColValue("cos_cta4"),false,false,true,3)%><%=fb.textBox("cos_cta5",cdo.getColValue("cos_cta5"),false,false,true,3)%><%=fb.textBox("cos_cta6",cdo.getColValue("cos_cta6"),false,false,true,3)%><%=fb.textBox("cuentaCost",cdo.getColValue("cuentaCost"),false,false,true,38)%><%=fb.button("btnctacosto","...",true,false,null,null,"onClick=\"javascript:addCtaCosto()\"")%></td>
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
  tipoServCode = request.getParameter("tipoServCode");
  centroServCode = request.getParameter("centroServCode");
  
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_cds_ts_x_centro");
  if (request.getParameter("cg_cta1") != null)
  cdo.addColValue("cg_cta1",request.getParameter("cg_cta1"));
  if (request.getParameter("cg_cta2") != null)
  cdo.addColValue("cg_cta2",request.getParameter("cg_cta2"));
  if (request.getParameter("cg_cta3") != null)
  cdo.addColValue("cg_cta3",request.getParameter("cg_cta3"));
  if (request.getParameter("cg_cta4") != null)
  cdo.addColValue("cg_cta4",request.getParameter("cg_cta4"));
  if (request.getParameter("cg_cta5") != null)
  cdo.addColValue("cg_cta5",request.getParameter("cg_cta5"));
  if (request.getParameter("cg_cta6") != null)
  cdo.addColValue("cg_cta6",request.getParameter("cg_cta6"));
  if (request.getParameter("cos_cta1") != null)
  cdo.addColValue("cos_cta1",request.getParameter("cos_cta1"));
  if (request.getParameter("cos_cta2") != null)
  cdo.addColValue("cos_cta2",request.getParameter("cos_cta2"));
  if (request.getParameter("cos_cta3") != null)
  cdo.addColValue("cos_cta3",request.getParameter("cos_cta3"));
  if (request.getParameter("cos_cta4") != null)
  cdo.addColValue("cos_cta4",request.getParameter("cos_cta4"));
  if (request.getParameter("cos_cta5") != null)
  cdo.addColValue("cos_cta5",request.getParameter("cos_cta5"));
  if (request.getParameter("cos_cta6") != null)
  cdo.addColValue("cos_cta6",request.getParameter("cos_cta6"));   
  
  if (mode.equalsIgnoreCase("add"))
  {
    cdo.addColValue("cg_compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("cg_compania="+(String) session.getAttribute("_companyId"));
    cdo.addColValue("tipo_servicio",tipoServCode);
	cdo.addColValue("centro_servicio",centroServCode);
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("tipo_servicio='"+tipoServCode+"' and centro_servicio="+centroServCode+" and cg_compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/centroservicio_tipo_cuenta_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/centroservicio_tipo_cuenta_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/centroservicio_tipo_cuenta_list.jsp';
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