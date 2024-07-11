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
600015	AGREGAR TIPO DE DESCUENTO
600016	MODIFICAR TIPO DE DESCUENTO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"600015") || SecMgr.checkAccess(session.getId(),"600016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");

System.out.println("metod-----------------"+request.getMethod().equalsIgnoreCase("GET"));
if (request.getMethod().equalsIgnoreCase("GET"))
{

if (mode == null) mode = "add";

	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";		
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Descuento no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.codigo, a.cia_seguro, a.descripcion, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, b.descripcion as cuenta, valor, tipo_valor as tipo FROM tbl_fac_tipo_descuento a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1(+) and a.cta2=b.cta2(+) and a.cta3=b.cta3(+) and a.cta4=b.cta4(+) and a.cta5=b.cta5(+) and a.cta6=b.cta6(+) and a.compania=b.compania(+) and a.codigo="+id+" and a.compania="+(String) session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Tipo de Descuento Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Tipo de Descuento Edición - "+document.title;
<%}%>

function addCuenta()
{
  abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=9');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
				<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
				<td width="50%"><%=id%></td>
				<td width="15%"><cellbytelabel>Tipo Valor</cellbytelabel></td>
				<td width="20%"><%=fb.select("tipo","P=Porcentaje,M=Monetario",cdo.getColValue("tipo"))%></td>								
			</tr>							
			<tr class="TextRow01">
			    <td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,68)%></td>
				<td><cellbytelabel>Monto</cellbytelabel></td>
				<td><%=fb.decBox("valor",cdo.getColValue("valor"),true,false,false,11)%></td>												
			</tr>
			<tr class="TextRow01">
 			    <td><cellbytelabel>Cuenta Financiera</cellbytelabel></td>
				<td><%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,2)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,2)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,2)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,2)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,2)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,2)%><%=fb.textBox("cuenta",cdo.getColValue("cuenta"),false,false,true,25)%><%=fb.button("btncuenta","...",true,false,null,null,"onClick=\"javascript:addCuenta()\"")%></td>
				<td><cellbytelabel>Compa&ntilde;ia Seguro</cellbytelabel>?</td>
				<td><%=fb.checkbox("cia_seguro","S",(cdo.getColValue("cia_seguro") != null && cdo.getColValue("cia_seguro").trim().equalsIgnoreCase("S")),false)%></td>				
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
  cdo.setTableName("tbl_fac_tipo_descuento");
  cdo.addColValue("descripcion",request.getParameter("descripcion")); 
  if (request.getParameter("cta1") != null)
  cdo.addColValue("cta1",request.getParameter("cta1"));
  if (request.getParameter("cta2") != null)
  cdo.addColValue("cta2",request.getParameter("cta2"));
  if (request.getParameter("cta3") != null)
  cdo.addColValue("cta3",request.getParameter("cta3"));
  if (request.getParameter("cta4") != null)
  cdo.addColValue("cta4",request.getParameter("cta4"));
  if (request.getParameter("cta5") != null)
  cdo.addColValue("cta5",request.getParameter("cta5"));
  if (request.getParameter("cta6") != null)
  cdo.addColValue("cta6",request.getParameter("cta6"));  
  if (request.getParameter("valor") != null)
  cdo.addColValue("valor",""+request.getParameter("valor"));
  cdo.addColValue("tipo_valor",request.getParameter("tipo"));  
  if (request.getParameter("cia_seguro") == null) cdo.addColValue("cia_seguro","N");
  else cdo.addColValue("cia_seguro",request.getParameter("cia_seguro"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	 
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  if (mode.equalsIgnoreCase("add"))
  {  
    cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	 
    cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
 	cdo.setAutoIncCol("codigo");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("codigo="+request.getParameter("id")+" and compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/tipodescuento_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/tipodescuento_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/tipodescuento_list.jsp';
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