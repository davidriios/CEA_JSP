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
================================================================================

================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900087") || SecMgr.checkAccess(session.getId(),"900088"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id=request.getParameter("code");
String filter = " and recibe_mov='S'";

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
		if (id == null) throw new Exception("El Tipo de Movimiento no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.codigo, a.descripcion, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as cuentaDesc,  a.estado, a.lado FROM tbl_cja_rubros a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1(+) and a.cta2=b.cta2(+) and a.cta3=b.cta3(+) and a.cta4=b.cta4(+) and a.cta5=b.cta5(+) and a.cta6=b.cta6(+) and a.compania=b.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.codigo="+id;
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Tipos de Movimientos Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipos de Movimientos Edición - "+document.title;
<%}%>

function addCuenta()
{
   abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=21&filter=<%=IBIZEscapeChars.forURL(filter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td width="99%" class="TableBorder">			

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

            <table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr class="TextRow01">
					<td width="15%">C&oacute;digo</td>
					<td width="18%"><%=id%></td>
					<td width="12%">Descripci&oacute;n</td>
 			        <td width="65%"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,50)%></td>					
				</tr>						
				<tr class="TextRow01">
					<td>Cuenta Contable</td>
					<td colspan="3"><%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,3)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,3)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,3)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,3)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,3)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,3)%><%=fb.textBox("cuentaDesc",cdo.getColValue("cuentaDesc"),false,false,true,50)%><%=fb.button("btnCuenta","...",true,false,null,null,"onClick=\"javascript:addCuenta()\"")%></td>
				</tr>
				<tr class="TextRow01">
					<td>Lado</td>
					<td colspan="3"><%=fb.select("lado","CR=Crédito,DB=Débito",cdo.getColValue("lado"))%></td>
				</tr>
				<tr class="TextRow01">
					<td>Estado</td>
					<td colspan="3"><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"))%></td>
				</tr>
                <tr class="TextRow02">
			        <td colspan="4" align="right">
				    <%=fb.submit("save","Guardar",true,false)%>
				    <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
            <%=fb.formEnd(true)%>
            </table>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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

  cdo.setTableName("tbl_cja_rubros"); 
  if (request.getParameter("descripcion") != null) cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  if (request.getParameter("cta1") != null) cdo.addColValue("cta1",request.getParameter("cta1"));
  if (request.getParameter("cta2") != null) cdo.addColValue("cta2",request.getParameter("cta2"));
  if (request.getParameter("cta3") != null) cdo.addColValue("cta3",request.getParameter("cta3"));
  if (request.getParameter("cta4") != null) cdo.addColValue("cta4",request.getParameter("cta4"));
  if (request.getParameter("cta5") != null) cdo.addColValue("cta5",request.getParameter("cta5"));
  if (request.getParameter("cta6") != null) cdo.addColValue("cta6",request.getParameter("cta6"));
  cdo.addColValue("estado",request.getParameter("estado"));
  cdo.addColValue("lado",request.getParameter("lado"));

  if (mode.equalsIgnoreCase("add"))
  { 
    cdo.addColValue("user_creacion",(String) session.getAttribute("_userName"));
    cdo.addColValue("user_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
    cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
	cdo.setAutoIncCol("codigo");

	SQLMgr.insert(cdo);
  }
  else
  { 
    cdo.addColValue("user_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
    cdo.setWhereClause("codigo="+request.getParameter("id")+"and compania="+(String) session.getAttribute("_companyId"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/items_cafeteria_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/items_cafeteria_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/items_cafeteria_list.jsp';
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