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
String code=request.getParameter("code");
String anio=request.getParameter("anio");
String compId=request.getParameter("compId");

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		code = "0";
	}
	else
	{
		if (code == null) throw new Exception("El Código no es válido. Por favor intente nuevamente!");
		if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
		if (compId == null) throw new Exception("La Compañia no es válida. Por favor intente nuevamente!");

sql = "SELECT b.nombre as cia, a.recibo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.nombre, DECODE(a.impreso,'S','Si') as impreso, DECODE(a.anulada,'S','Si') as anulada, a.pac_id as pacienteCode, c.primer_nombre||' '||c.primer_apellido as paciente, a.codigo_empresa as empresaCode, d.nombre as empresa, a.descripcion, a.caja as cajaCode, e.descripcion as caja, a.pago_total FROM tbl_cja_transaccion_pago a, tbl_sec_compania b, tbl_adm_paciente c, tbl_adm_empresa d, tbl_cja_cajas e WHERE a.compania=b.codigo and a.pac_id=c.pac_id(+) and a.codigo_empresa=d.codigo(+) and a.caja=e.codigo and a.compania=e.compania and a.rec_status <> 'I' and a.compania="+(String) session.getAttribute("_companyId")+" and a.compania="+compId+" and a.anio="+anio+" and a.codigo="+code;
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
document.title="Cajeros - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Cajaros - Edición - "+document.title;
<%}%>
function checkCode(obj)
{

if(hasDBData('<%=request.getContextPath()%>','(select * from tbl_cja_recibos where compania=\'<%=compId%>\')','codigo=\''+obj.value+'\'',''))
{
alert('El Número de Recibo que desea reeemplazar YA EXISTE!!');
obj.select();
document.form1.reemplazo.value = '';
return false;
}
return true;
}


</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACIÓN - MANTENIMIENTO - CAJEROS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("code",code)%>
			
			<tr>	
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>			
			<tr class="TextRow01" >
				<td width="15%"><cellbytelabel>Recibo</cellbytelabel></td>
				<td width="35%"><%=fb.textBox("recibo",cdo.getColValue("recibo"),false,false,true,15)%></td>
				<td width="15%"><cellbytelabel>Reemplazar por</cellbytelabel></td>
				<td width="35%"><%=fb.textBox("reemplazo",cdo.getColValue("reemplazo"),true,false,false,15,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>					
			</tr>							
			<tr class="TextRow01" >
				<td><cellbytelabel>No. Transacci&oacute;n</cellbytelabel></td>
				<td><%=code%></td>
				<td><cellbytelabel>Fecha</cellbytelabel></td>
				<td><%=cdo.getColValue("fecha")%></td>
			</tr>
			<tr class="TextRow01" >					
				<td><cellbytelabel>Nombre del Recibo</cellbytelabel></td>
				<td><%=fb.textBox("nombre",cdo.getColValue("nombre"),false,false,true,45)%></td>
				<td><cellbytelabel>A&ntilde;o</cellbytelabel></td>
				<td><%=fb.textBox("anio",anio,false,false,true,45)%></td>
			</tr>
			<tr class="TextRow01" >					
				<td><cellbytelabel>Impreso</cellbytelabel></td>
				<td><%=fb.textBox("impreso",cdo.getColValue("impreso"),false,false,true,45)%></td>
				<td><cellbytelabel>Anulado</cellbytelabel></td>
				<td><%=fb.textBox("impreso",cdo.getColValue("anulada"),false,false,true,45)%></td>
			</tr>
			<tr class="TextRow01" >					
				<td><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,true,45)%></td>	
				<td><cellbytelabel>Pago Total</cellbytelabel></td>
				<td><%=fb.decBox("pagoTotal",cdo.getColValue("pago_total"),false,false,true,45)%></td>				
			</tr>
			<tr class="TextRow01" >
				<td><cellbytelabel>Compa&ntilde;ia</cellbytelabel></td>
				<td><%=fb.textBox("ciaCode",compId,false,false,true,5)%><%=fb.textBox("cia",cdo.getColValue("cia"),false,false,true,35)%></td>	
				<td><cellbytelabel>Empresa</cellbytelabel></td>
				<td><%=fb.textBox("empresaCode",cdo.getColValue("empresaCode"),false,false,true,5)%><%=fb.textBox("empresa",cdo.getColValue("empresa"),false,false,true,35)%></td>									
			</tr>			
			<tr class="TextRow01" >
				<td><cellbytelabel>Caja</cellbytelabel></td>
				<td><%=fb.textBox("cajaCode",cdo.getColValue("cajaCode"),false,false,true,5)%><%=fb.textBox("caja",cdo.getColValue("caja"),false,false,true,35)%></td>					
				<td><cellbytelabel>Paciente</cellbytelabel></td>
				<td><%=fb.textBox("pacienteCode",cdo.getColValue("pacienteCode"),false,false,true,5)%><%=fb.textBox("paciente",cdo.getColValue("paciente"),false,false,true,35)%></td>					
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

  cdo.setTableName("tbl_cja_transaccion_pago");
  cdo.addColValue("recibo",request.getParameter("reemplazo"));  
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion","sysdate");
  cdo.setWhereClause("codigo="+request.getParameter("code")+" and anio="+request.getParameter("anio")+" and compania="+(String) session.getAttribute("_companyId"));
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/correccion_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/correccion_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/caja/correccion_list.jsp';
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