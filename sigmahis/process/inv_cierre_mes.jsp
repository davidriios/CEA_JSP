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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String almacen = request.getParameter("almacen");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (anio == null || mes == null) throw new Exception("Año/Mes no existen!. Por favor intente nuevamente!");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACION - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("almacen",almacen)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("mes",mes)%>
				<tr class="TextHeader" align="center">
					<td colspan="2">Cierre Mensual de Inventario.</td>
				</tr>
				<%
				String mes_desc = "";
				if(mes.equals("01")) mes_desc = "ENERO";
				else if(mes.equals("02")) mes_desc = "FEBRERO";
				else if(mes.equals("03")) mes_desc = "MARZO";
				else if(mes.equals("04")) mes_desc = "ABRIL";
				else if(mes.equals("05")) mes_desc = "MAYO";
				else if(mes.equals("06")) mes_desc = "JUNIO";
				else if(mes.equals("07")) mes_desc = "JULIO";
				else if(mes.equals("08")) mes_desc = "AGOSTO";
				else if(mes.equals("09")) mes_desc = "SEPTIEMBRE";
				else if(mes.equals("10")) mes_desc = "OCTUBRE";
				else if(mes.equals("11")) mes_desc = "NOVIEMBRE";
				else if(mes.equals("12")) mes_desc = "DICIEMBRE";
				%>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro de cerrar el mes <%=mes_desc%> del <%=anio%>?</font></cellbytelabel></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="2">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
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
  String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	int anioPrev = Integer.parseInt(request.getParameter("anio"));
	int mesPrev = Integer.parseInt(request.getParameter("mes"));
	if(mesPrev==1){
		anioPrev = anioPrev - 1;
		mesPrev = 12;
	} else mesPrev = mesPrev - 1;
  sql.append("call sp_inv_cierre_mes(");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(", ");
	if(almacen==null || almacen.equals(""))sql.append("null");
	else sql.append(almacen);
	sql.append(", ");
	sql.append(anio);
	sql.append(", ");
	sql.append(mes);
	sql.append(", '");
	sql.append((String) session.getAttribute("_userName"));
	sql.append("', ");
	sql.append(anioPrev);
	sql.append(", ");
	sql.append(mesPrev);
	sql.append(")");
  
	SQLMgr.execute(sql.toString());
  
%>
<html>
<head>
<script language="javascript" src="../js/global.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.hidePopWin(false);
	parent.window.location.reload(true);
<%
	
} else throw new Exception(SQLMgr.getErrException());
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