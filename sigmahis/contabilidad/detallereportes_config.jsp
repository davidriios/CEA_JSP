<%//@ page errorPage="../error.jsp"%>
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
900039	AGREGAR DETALLE DE REPORTE
900040	MODIFICAR DETALLE DE REPORTE
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900039") || SecMgr.checkAccess(session.getId(),"900040"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String repCode=request.getParameter("repCode");
String grupoCode=request.getParameter("grupoCode");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		CommonDataObject cdoDet = SQLMgr.getData("select a.codigo as reportCode, a.descripcion as reporte, b.codigo as grupCode, b.descripcion as grupo from tbl_con_reporte a, tbl_con_grupos_rep b where a.codigo=b.cod_rep and a.compania=b.compania and a.codigo="+repCode+" and b.codigo="+grupoCode+" and a.compania="+(String) session.getAttribute("_companyId"));
		cdo.addColValue("cod_rep",cdoDet.getColValue("reportCode"));
		cdo.addColValue("reporte",cdoDet.getColValue("reporte"));
		cdo.addColValue("cod_grupo",cdoDet.getColValue("grupCode"));
		cdo.addColValue("grupo",cdoDet.getColValue("grupo"));				
	}
	else
	{
		if (id == null) throw new Exception("El Detalle de Reporte no es válido. Por favor intente nuevamente!");
		if (repCode == null) throw new Exception("El Reporte no es válido. Por favor intente nuevamente!");
		if (grupoCode == null) throw new Exception("El Grupo de Reporte no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.secuen, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as descrip, a.cia_cta, c.descripcion as reporte, d.descripcion as grupo, a.cod_rep, a.cod_grupo, a.cod_grupo_rel FROM tbl_con_detalle_rep a, tbl_con_catalogo_gral b, tbl_con_reporte c, tbl_con_grupos_rep d WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.cia_cta=b.compania and a.cod_rep=c.codigo and a.cod_grupo=d.codigo and a.cod_rep=d.cod_rep and a.compania=c.compania and a.compania=d.compania and a.secuen="+id+" and a.cod_rep="+repCode+" and a.cod_grupo="+grupoCode+" and a.compania="+(String) session.getAttribute("_companyId");
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
document.title="Detalle Reporte Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Detalle Reporte Edición - "+document.title;
<%}%>

function addCat()
{
  abrir_ventana3('ctabancaria_catalogo_list.jsp?id=6')
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
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("repCode",repCode)%>
			<%=fb.hidden("grupoCode",grupoCode)%>
		
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>			
			<tr class="TextRow01">
				<td>Reporte</td>
				<td><%=cdo.getColValue("cod_rep")%> - <%=cdo.getColValue("reporte")%></td>
			</tr>
			<tr class="TextRow01">
				<td>Grupo</td>
				<td><%=cdo.getColValue("cod_grupo")%> - <%=cdo.getColValue("grupo")%></td>
			</tr>										
			<tr class="TextRow01">
				<td>Cuenta Financiera</td>
				<td><%=fb.textBox("cta1",cdo.getColValue("cta1"),true,false,true,3)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),true,false,true,3)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),true,false,true,3)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),true,false,true,3)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),true,false,true,3)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),true,false,true,3)%><%=fb.hidden("cia_cta",cdo.getColValue("cia_cta"))%><%=fb.textBox("descripcion",cdo.getColValue("descrip"),true,false,true,40)%><%=fb.button("btncta","...",true,false,null,null,"onClick=\"javascript:window.addCat()\"")%>
				</td>
			</tr>					
			<tr class="TextRow01">
				<td>Traer saldo de Grupo de Cuenta:</td>
				<td>
				<%=fb.select(ConMgr.getConnection(),"Select codigo, descripcion From tbl_con_grupos_rep Where compania = "+(String) session.getAttribute("_companyId")+" and cod_rep = "+cdo.getColValue("cod_rep") + " and codigo <> "+cdo.getColValue("cod_grupo"),"cod_grupo_rel",cdo.getColValue("cod_grupo_rel"), false, false, 0, "text10","","","","S")%>
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
  repCode = request.getParameter("repCode");
  grupoCode = request.getParameter("grupoCode");
   
  cdo = new CommonDataObject();

  cdo.setTableName("tbl_con_detalle_rep");
  cdo.addColValue("cta1",request.getParameter("cta1"));
  cdo.addColValue("cta2",request.getParameter("cta2"));
  cdo.addColValue("cta3",request.getParameter("cta3"));
  cdo.addColValue("cta4",request.getParameter("cta4"));
  cdo.addColValue("cta5",request.getParameter("cta5"));
  cdo.addColValue("cta6",request.getParameter("cta6"));   
  cdo.addColValue("cia_cta",request.getParameter("cia_cta"));
  //if(request.getParameter("cod_grupo_rel")!=null && !request.getParameter("cod_grupo_rel").equals("")) 
  cdo.addColValue("cod_grupo_rel", request.getParameter("cod_grupo_rel"));
    
  if (mode.equalsIgnoreCase("add"))
  {
	cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("cod_rep",repCode);
	cdo.addColValue("cod_grupo",grupoCode);
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and cod_rep="+repCode+" and cod_grupo="+grupoCode);
	cdo.setAutoIncCol("secuen");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
    cdo.setWhereClause("secuen="+request.getParameter("id")+" and cod_rep="+repCode+" and cod_grupo="+grupoCode+" and compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/detallereportes_list.jsp?repCode="+repCode+"&grupoCode="+grupoCode))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/detallereportes_list.jsp?repCode="+repCode+"&grupoCode="+grupoCode)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/detallereportes_list.jsp?repCode=<%=repCode%>&grupoCode=<%=grupoCode%>';
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