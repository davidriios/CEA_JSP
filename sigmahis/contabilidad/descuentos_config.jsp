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
900083	AGREGAR RECARGO X MOROSIDAD
900084	MODIFICAR RECARGO X MOROSIDAD
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900083") || SecMgr.checkAccess(session.getId(),"900084"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
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
	}
	else
	{
		if (id == null) throw new Exception("El Recargo x Morosidad no es válido. Por favor intente nuevamente!");

		sql = "SELECT secuencia, dia_desde as desde, dia_hasta as hasta, monto_desc as monto, tipo_desc as tipo, pago_x_adelanto as adelanto FROM tbl_cxc_pronto_pago_alq WHERE secuencia="+id+" and compania="+(String) session.getAttribute("_companyId");
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
document.title="Descuento x Pago Pronto Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Descuento x Pago Pronto Edición - "+document.title;

function checkDia(obj)
{
   if (obj.value>31)
   {
      alert('Rango Permitido 01 Hasta 31');
	  obj.focus();
   }
   return;
}
<%}%>
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
		
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>			
			<tr class="TextRow01">
				<td width="15%">Secuencia</td>
				<td width="35%"><%=id%></td>
				<td width="15%">Tipo Valor</td>
				<td width="35%"><%=fb.select("tipo","P=Porcentaje,M=Monetario",cdo.getColValue("tipo"))%></td>								
			</tr>							
			<tr class="TextRow01">
				<td>D&iacute;a Desde(01-31)</td>
				<td><%=fb.intBox("desde",cdo.getColValue("desde"),false,false,false,40,null,null,"onBlur=\"javascript:checkDia(this)\"")%></td>
				<td>Monto</td>
				<td><%=fb.decBox("monto",cdo.getColValue("monto"),false,false,false,40)%></td>				
			</tr>
			<tr class="TextRow01">
 			    <td>D&iacute;a Hasta(01-31)</td>
				<td><%=fb.intBox("hasta",cdo.getColValue("hasta"),false,false,false,40,null,null,"onBlur=\"javascript:checkDia(this)\"")%></td>
				<td>Pago x Adelanto</td>
				<td><%=fb.checkbox("adelanto","S",(cdo.getColValue("adelanto") != null && cdo.getColValue("adelanto").trim().equalsIgnoreCase("S")),false)%></td>				
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
   
  cdo.setTableName("tbl_cxc_pronto_pago_alq");
  cdo.addColValue("dia_desde",request.getParameter("desde")); 
  cdo.addColValue("dia_hasta",request.getParameter("hasta"));  
  cdo.addColValue("monto_desc",""+request.getParameter("monto"));
  cdo.addColValue("tipo_desc",request.getParameter("tipo"));
  if (request.getParameter("adelanto") == null) cdo.addColValue("pago_x_adelanto","N");
  else cdo.addColValue("pago_x_adelanto",request.getParameter("adelanto"));
    
  if (mode.equalsIgnoreCase("add"))
  {  
    cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	 
    cdo.addColValue("usuario_creacion",UserDet.getUserEmpId()); 
    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
    cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
 	cdo.setAutoIncCol("secuencia");
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	 
    cdo.addColValue("usuario_modificacion",UserDet.getUserEmpId());
    cdo.setWhereClause("secuencia="+request.getParameter("id")+" and compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/contabilidad/descuentos_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/contabilidad/descuentos_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/contabilidad/descuentos_list.jsp';
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