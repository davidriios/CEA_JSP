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

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sql = new StringBuffer();
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fg = request.getParameter("fg");
String mesDesc =  request.getParameter("mesDesc");
String desc = "";
String fechaDesde = "";
String fechaHasta = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (anio == null || mes == null) throw new Exception("Año/Mes no existen!. Por favor intente nuevamente!");
		if(fg.trim().equals("MM"))desc=" ACTUALIZAR MOVIMIENTO MENSUAL";
		else if(fg.trim().equals("SI"))desc="ACTUALIZAR SALDO INICIAL ";
		else if(fg.trim().equals("CC"))desc=" CREAR CUENTAS ";
		else if(fg.trim().equals("AUD")){desc=" GENERAR AUDITORIA ";fechaDesde="01/"+mes+"/"+anio; sql.append("select to_char(LAST_DAY(TO_DATE('");
		sql.append(fechaDesde);
		sql.append("','DD/MM/YYYY')),'DD/MM/YYYY') as fecha_hasta from dual ");cdo = SQLMgr.getData(sql.toString());fechaHasta=cdo.getColValue("fecha_hasta");}
		
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
	<jsp:param name="title" value="MAYOR GENERAL - PROCESOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>			
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("mes",mes)%>
			<%=fb.hidden("mesDesc",mesDesc)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fechaDesde",fechaDesde)%>
			<%=fb.hidden("fechaHasta",fechaHasta)%>
				<tr class="TextHeader" align="center">
					<td colspan="2"> <%=desc%></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2" align="center"><cellbytelabe><font class="RedTextBold">Est&aacute; seguro <%=desc%> para el AÑO: <%=anio%>&nbsp; MES: <%=mesDesc%> </font></cellbytelabel></td>
				</tr>
                 
				<tr class="TextRow02">
					<td align="center" colspan="2">
						<%=fb.submit("save","Ejecutar",true,false)%>
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

</body>
</html>
<%
}//GET
else
{
 
fechaDesde = request.getParameter("fechaDesde");
fechaHasta = request.getParameter("fechaHasta");

  sql.append("call ");
  if(fg.trim().equals("MM"))sql.append(" utl_con_upd_cta_mes ");
  else if(fg.trim().equals("SI"))sql.append(" utl_con_upd_cta_mes_monto_i ");
  else if(fg.trim().equals("CC"))sql.append(" utl_con_add_cta_mov_mensual ");
  else if(fg.trim().equals("AUD"))sql.append(" sp_con_aud_generar_reg_user ");
  
  sql.append("(");
  sql.append((String) session.getAttribute("_companyId"));
  
  if(!fg.trim().equals("AUD")){  
  sql.append(",'");
  sql.append((String) session.getAttribute("_userName"));
  sql.append("',");
  sql.append(anio);
  sql.append(",");
  sql.append(mes);
  sql.append(",");
  sql.append("null )"); }
  else {
  sql.append(",'");
  sql.append(fechaDesde);
  sql.append("','");
  sql.append(fechaHasta);
  sql.append("','"); 
  sql.append((String) session.getAttribute("_userName"));
  sql.append("')");
  }
	SQLMgr.execute(sql.toString());
  
%>
<html>
<head>
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