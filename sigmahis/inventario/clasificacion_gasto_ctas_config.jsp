
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
=========================================================================

=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900015") || SecMgr.checkAccess(session.getId(),"900016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String compId = request.getParameter("compId");
String fliaId = request.getParameter("fliaId");
String unidadId = request.getParameter("unidadId");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (request.getMethod().equalsIgnoreCase("GET"))
{   
     
   if (compId == null) throw new Exception("La Compañia no es válida. Por favor intente nuevamente!");
   if (fliaId == null) throw new Exception("La Familia no es válida. Por favor intente nuevamente!");
   if (unidadId == null) throw new Exception("La Unidad no es válida. Por favor intente nuevamente!");
		
   sql = "SELECT a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as cuenta, c.nombre as flia, d.descripcion as unidad FROM tbl_inv_unidad_costos a, tbl_con_catalogo_gral b, tbl_inv_familia_articulo c, tbl_sec_unidad_ejec d WHERE a.cta1=b.cta1(+) and a.cta2=b.cta2(+) and a.cta3=b.cta3(+) and a.cta4=b.cta4(+) and a.cta5=b.cta5(+) and a.cta6=b.cta6(+) and a.cia=b.compania(+) and a.familia=c.cod_flia and a.cia=c.compania and a.unid_adm=d.codigo and a.cia=d.compania and  a.familia="+fliaId+" and a.cia="+compId+" and a.unid_adm="+unidadId;
   cdo = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Clasificación Gasto x Unid. Adm. y Flia. de Artículo - "+document.title;

function addCuenta()
{
  abrir_ventana2('../contabilidad/ctabancaria_catalogo_list.jsp?id=17');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - CLASIFICACIÓN DE GASTOS X UNID. ADM. y FLIA. ARTÍCULO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("compId",compId)%>
			<%=fb.hidden("unidadId",unidadId)%>
			<%=fb.hidden("fliaId",fliaId)%>
						
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2"><%=unidadId%> - <%=cdo.getColValue("unidad")%> - <%=fliaId%> - <%=cdo.getColValue("flia")%>&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="15%">Cuenta Bancaria</td>
				<td width="85%"><%=fb.textBox("cta1",cdo.getColValue("cta1"),true,false,true,3)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),true,false,true,3)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),true,false,true,3)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),true,false,true,3)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),true,false,true,3)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),true,false,true,3)%><%=fb.textBox("cuenta",cdo.getColValue("cuenta"),true,false,true,52)%><%=fb.button("btncta","...",true,false,null,null,"onClick=\"javascript:addCuenta()\"")%></td>				
			</tr>									
			<tr class="TextRow01">
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
  compId = request.getParameter("compId");
  fliaId = request.getParameter("fliaId");
  unidadId = request.getParameter("unidadId");
  
  cdo = new CommonDataObject();
    
  cdo.setTableName("tbl_inv_unidad_costos");   
  cdo.addColValue("cta1",request.getParameter("cta1"));
  cdo.addColValue("cta2",request.getParameter("cta2"));
  cdo.addColValue("cta3",request.getParameter("cta3"));
  cdo.addColValue("cta4",request.getParameter("cta4"));
  cdo.addColValue("cta5",request.getParameter("cta5"));
  cdo.addColValue("cta6",request.getParameter("cta6"));
  
  cdo.setWhereClause("familia="+fliaId+" and unid_adm="+unidadId+" and cia="+compId);
  SQLMgr.update(cdo);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/clasificacion_gasto_config.jsp?compId="+compId+"&fliaId="+fliaId+"&unidadId="+unidadId+"&change=1&act=1"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/clasificacion_gasto_config.jsp?compId="+compId+"&fliaId="+fliaId+"&unidadId="+unidadId+"&change=1&act=1")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/inventario/clasificacion_gasto_config.jsp?compId=<%=compId%>&fliaId=<%=fliaId%>&unidadId=<%=unidadId%>&change=1&act=1';
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
