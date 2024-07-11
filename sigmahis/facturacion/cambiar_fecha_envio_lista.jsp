<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
String sql = "", key = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
boolean viewMode = false;
String aseguradora = request.getParameter("aseguradora");
String categoria = request.getParameter("categoria");
String numero_lista = request.getParameter("numero_lista");
String fecha = request.getParameter("fecha");
String usuario = request.getParameter("usuario");
String facturado_a = request.getParameter("facturado_a");
String fechaEnvio = request.getParameter("fechaEnvio");

if(fg==null) fg = "";
if(fp==null) fp = "";
if (mode == null) mode = "add";
if (facturado_a == null) facturado_a = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
if(aseguradora==null) throw new Exception("No existe aseguradora!");
else if(categoria==null) throw new Exception("No existe categoria!");
else if(numero_lista==null) throw new Exception("No existe numero de lista!");
%>
<html>
<head>
<link rel="icon" href="<%=request.getContextPath()%>/images/<%=java.util.ResourceBundle.getBundle("issi").getString("icon")%>" type="image/x-icon">
<link rel="shortcut icon" href="<%=request.getContextPath()%>/images/<%=java.util.ResourceBundle.getBundle("issi").getString("icon")%>" type="image/x-icon">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/styles.css" type="text/css">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cambio de Fecha de envio '+document.title;

function doAction(){
}

function doSubmit(accion){
	if(accion=='N') {
		parent.hidePopWin(false);
	} else{
		if (document.cambio_fecha.fecha_envio_new.value==''){
		 CBMSG.warning('Introduzca fecha!');
		} else {
			document.cambio_fecha.submit();
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CAMBIAR FECHA RECIBIDO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			  <%fb = new FormBean("cambio_fecha",request.getContextPath()+request.getServletPath(),"post");%>
              <%=fb.formStart(true)%> 
			  <%=fb.hidden("mode",mode)%> 
			  <%=fb.hidden("errCode","")%> 
			  <%=fb.hidden("errMsg","")%> 
              <%=fb.hidden("saveOption","")%> 
			  <%=fb.hidden("clearHT","")%> 
			  <%=fb.hidden("action","")%> 
              <%=fb.hidden("fg",fg)%> 
              <%=fb.hidden("aseguradora",aseguradora)%> 
              <%=fb.hidden("categoria",categoria)%> 
              <%=fb.hidden("numero_lista",numero_lista)%> 
              <%=fb.hidden("usuario",usuario)%> 
			  <%=fb.hidden("facturado_a",facturado_a)%>
			  <%=fb.hidden("fechaEnvio",fechaEnvio)%> 
			  
              <tr class="TextRow01">
                <td align="center" colspan="4">&nbsp;</td>
              </tr>
              <tr class="TextHeader02">
                <td align="center" colspan="4"><cellbytelabel>Cambio de Fecha</cellbytelabel></td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><font class="RedTextBold">
                <cellbytelabel>Fecha de Envio</cellbytelabel>:</font>
                </td>
                <td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha_envio_new" />
								<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
								<jsp:param name="fieldClass" value="text10" />
								<jsp:param name="buttonClass" value="text10" />
								</jsp:include>
                </td>
				<td align="right"><font class="RedTextBold">
                <cellbytelabel>Fecha de Recibido</cellbytelabel>:</font>
                </td>
                <td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha_recibido" />
								<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
								<jsp:param name="fieldClass" value="text10" />
								<jsp:param name="buttonClass" value="text10" />
								</jsp:include>
                </td>
				
              </tr>
              <tr class="TextHeader02">
                <td align="center" colspan="4">
                <%=fb.button("save","Guardar",false, viewMode,"","","onClick=\"javascript:doSubmit('S')\"")%>
                <%=fb.button("cancel","Cancelar",false, viewMode,"","","onClick=\"javascript:doSubmit('N');\"")%>
                </td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
		StringBuffer sbSql = new StringBuffer();
		sbSql.append("call sp_fac_envios_aseg(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(", ");
		sbSql.append(request.getParameter("categoria"));
		sbSql.append(", ");
		sbSql.append(request.getParameter("aseguradora"));
		sbSql.append(", ");
		sbSql.append(request.getParameter("numero_lista"));
		sbSql.append(", '");
		sbSql.append(request.getParameter("usuario"));
		sbSql.append("', '");
		sbSql.append(request.getParameter("facturado_a"));
		sbSql.append("', '");
		sbSql.append(request.getParameter("fecha_envio_new"));
		sbSql.append("', '");		
		sbSql.append(request.getParameter("fecha_recibido"));
		sbSql.append("', '");		
		sbSql.append(request.getParameter("fechaEnvio"));
		sbSql.append("', '");	
		sbSql.append((String) session.getAttribute("_userName"));
		sbSql.append("')");
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.execute(sbSql.toString());
		ConMgr.clearAppCtx(null);
												
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.hidePopWin(false);
	parent.reloadPage();
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
}
%>
