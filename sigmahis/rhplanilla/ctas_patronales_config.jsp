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
800043	AGREGAR CUENTAS PATRONALES
800044	MODIFICAR CUENTAS PATRONALES
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800043") || SecMgr.checkAccess(session.getId(),"800044"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String cuent1=request.getParameter("cuent1");
String cuent2=request.getParameter("cuent2");
String cuent3=request.getParameter("cuent3");
String cuent4=request.getParameter("cuent4");
String cuent5=request.getParameter("cuent5");
String cuent6=request.getParameter("cuent6");
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	}
	else
	{
	sql = "select a.cta1, a.cta2 , a.cta3 , a.cta4 , a.cta5 , a.cta6 , a.lado, a.cod_concepto as codeconcepto, a.fecha_mod, a.usuario_mod, a.cod_compania, b.cta1 as cts1, b.cta2 as cts2, b.cta3 as cts3, b.cta4 as cts4, b.cta5 as cts5, b.cta6 as cts6, b.descripcion , b.compania, c.cod_concepto as codigo, c.descripcion as nameconcepto, c.cod_compania from tbl_pla_cuenta_patronal a, tbl_con_catalogo_gral b, tbl_pla_cuenta_concepto c  where a.cod_compania=b.compania and a.cod_compania=c.cod_compania and  a.cta1=b.cta1 and  a.cta2=b.cta2 and  a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.cod_concepto=c.cod_concepto and a.cta1="+cuent1+" and a.cta2="+cuent2+" and a.cta3="+cuent3+" and a.cta4="+cuent4+" and a.cta5="+cuent5+" and a.cta6="+cuent6+" and a.cod_compania="+(String) session.getAttribute("_companyId");
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
document.title="Cuenta Patronal - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cuenta Patronal - Edición - "+document.title;
<%}%>

function add()
{
abrir_ventana1('../common/search_catalogo_gral.jsp?fp=ctasPatronales');
}

function conceptos()
{
abrir_ventana1('../rhplanilla/list_conceptos.jsp?fp=ctasPatronales');
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTA PATRONAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ======================   F O R M   S T A R T   H E R E   ===================== -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("cuent1",cuent1)%>
			<%=fb.hidden("cuent2",cuent2)%>
			<%=fb.hidden("cuent3",cuent3)%>
			<%=fb.hidden("cuent4",cuent4)%>
			<%=fb.hidden("cuent5",cuent5)%>
			<%=fb.hidden("cuent6",cuent6)%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>	
			<tr class="TextHeader">
				<td colspan="2">&nbsp;Cuentas del Patrono</td>				
			</tr>		
			<tr class="TextRow01">
			<%if(mode.equals("add")){%>
				<td width="20%">&nbsp;N&uacute;mero de Cuenta</td>
				<td width="80%">&nbsp;<%=fb.textBox("cta1",cdo.getColValue("cta1"),true,false,true,1)%>
				<%=fb.textBox("cta2",cdo.getColValue("cta2"),true,false,true,2)%>
				<%=fb.textBox("cta3",cdo.getColValue("cta3"),true,false,true,2)%>
				<%=fb.textBox("cta4",cdo.getColValue("cta4"),true,false,true,2)%>
				<%=fb.textBox("cta5",cdo.getColValue("cta5"),true,false,true,2)%>
				<%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,2)%>
				<%=fb.textBox("descripcion", cdo.getColValue("descripcion"),false,false,true,40)%>
				<%=fb.button("btncuentas","...",true,false,null,null,"onClick=\"javascript:add();\"")%>
				</td>	
			<%}else if(mode.equals("edit")){%>	
				<td width="20%">&nbsp;N&uacute;mero de Cuenta</td>
				<td width="80%">&nbsp;<%=fb.textBox("cta1",cdo.getColValue("cta1"),true,false,true,1)%>
				<%=fb.textBox("cta2",cdo.getColValue("cta2"),true,false,true,2)%>
				<%=fb.textBox("cta3",cdo.getColValue("cta3"),true,false,true,2)%>
				<%=fb.textBox("cta4",cdo.getColValue("cta4"),true,false,true,2)%>
				<%=fb.textBox("cta5",cdo.getColValue("cta5"),true,false,true,2)%>
				<%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,2)%>
				<%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,true,40)%>
				</td>
			<%}%>		
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Lado</td>
				<td><%=fb.select("lado","DB=DEBITO, CR=CREDITO",cdo.getColValue("lado"))%></td>				
			</tr>			
			<tr class="TextRow01">
				<td>&nbsp;Concepto</td>
				<td><%=fb.intBox("codeconcepto",cdo.getColValue("codeconcepto"),true,false,true,10)%>
					<%=fb.textBox("nameconcepto",cdo.getColValue("nameconcepto"),false,false,true,71)%>
					<%=fb.button("btnconcepto","...",true,false,null,null,"onClick=\"javascript:conceptos();\"")%>
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
} // GET 
else
{

  cdo = new CommonDataObject();
  cdo.setTableName("tbl_pla_cuenta_patronal");
  cdo.addColValue("cta1", request.getParameter("cta1")); 
  cdo.addColValue("cta2", request.getParameter("cta2"));
  cdo.addColValue("cta3", request.getParameter("cta3"));
  cdo.addColValue("cta4", request.getParameter("cta4"));
  cdo.addColValue("cta5", request.getParameter("cta5"));
  cdo.addColValue("cta6", request.getParameter("cta6"));
  cdo.addColValue("lado", request.getParameter("lado"));
  cdo.addColValue("cod_concepto", request.getParameter("codeconcepto"));  
  cdo.addColValue("fecha_mod", CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));   
  
  if (mode.equalsIgnoreCase("add"))
  {
  cdo.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	SQLMgr.insert(cdo);
  }
  else
  {
  // try
  // {
   cdo.setWhereClause("cta1="+request.getParameter("cuent1")+" and cta2="+request.getParameter("cuent2")+" and cta3="+request.getParameter("cuent3")+" and cta4="+request.getParameter("cuent4")+" and cta5="+request.getParameter("cuent5")+" and cta6="+request.getParameter("cuent6")+" and cod_compania="+(String) session.getAttribute("_companyId")); 
  //  }
  //  catch 
  //  {
  
  //  }
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/ctas_patronales_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/ctas_patronales_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/ctas_patronales_list.jsp';
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