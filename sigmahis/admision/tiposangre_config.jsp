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
500051	AGREGAR TIPO DE SANGRE
500052	MODIFICAR TIPO DE SANGRE
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500051") || SecMgr.checkAccess(session.getId(),"500052"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String rhCode = request.getParameter("rhCode");
String tipoCode = request.getParameter("tipoCode");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("tipo_sangre","");
		cdo.addColValue("rh","");
	}
	else
	{
		if (rhCode == null) throw new Exception("El RH Sangre no es válido. Por favor intente nuevamente!");
		if (tipoCode == null) throw new Exception("El Tipo de Sangre no es válido. Por favor intente nuevamente!");
        
		sql = "SELECT rh, tipo_sangre, pago, pago_otro FROM tbl_bds_tipo_sangre WHERE rh='"+rhCode+"' and tipo_sangre='"+tipoCode+"'";
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title="Tipo Sangre Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title="Tipo Sangre Edición - "+document.title;
<%}%>

function checkTipo(obj)
{   
	var rh = document.form1.rh.value;
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_bds_tipo_sangre','tipo_sangre=\''+obj.value+'\' and rh=\''+rh+'\'','<%=cdo.getColValue("tipo_sangre")%>');
}

function checkRh(obj)
{   
	var tipo = document.form1.tipo.value;
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_bds_tipo_sangre','tipo_sangre=\''+tipo+'\' and rh=\''+obj.value+'\'','<%=cdo.getColValue("rh")%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNICA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>			
<%fb.appendJsValidation("if(checkTipo(document.form1.tipo)||checkRh(document.form1.rh))error++;");%>

			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td width="13%">Tipo Sangre</td>				
				<td width="37%"><%=fb.select("tipo","O=O,A=A,B=B,AB=AB,A1=A1",tipoCode,false,false,0,null,null,"onChange=\"javascript:checkTipo(this)\"")%></td>  				
				<td width="10%">Pago</td>
				<td width="40%"><%=fb.decBox("pago",cdo.getColValue("pago"),true,false,false,45)%></td>
			</tr>
			<tr class="TextRow02">
				<td>RH</td>
				<td><%=fb.select("rh","P=Positivo,N=Negativo",rhCode,false,false,0,null,null,"onChange=\"javascript:checkRh(this)\"")%></td>
				<td>Otro Pago</td>
				<td><%=fb.decBox("pago_otro",cdo.getColValue("pago_otro"),true,false,false,45)%></td>				
			</tr>						
			<tr class="TextRow01">
				<td colspan="4" align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
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
    
  cdo.setTableName("tbl_bds_tipo_sangre");  
  cdo.addColValue("rh",request.getParameter("rh"));
  cdo.addColValue("tipo_sangre",request.getParameter("tipo"));
  cdo.addColValue("pago",""+request.getParameter("pago"));
  cdo.addColValue("pago_otro",""+request.getParameter("pago_otro"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
  if (mode.equalsIgnoreCase("add"))
  {  
    SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("rh='"+request.getParameter("rh")+"' and tipo_sangre='"+request.getParameter("tipo")+"'");

		SQLMgr.update(cdo);
  }
	ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/tiposangre_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/tiposangre_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/tiposangre_list.jsp';
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