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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		
	}
	else
	{
		if (id == null) throw new Exception("El dia feriado no es valido. Por favor intente nuevamente!");

		sql = "select to_char(fecha,'dd/mm/yyyy')as fecha, to_char(dia_libre,'dd/mm/yyyy')as dia_libre, descripcion from tbl_pla_dia_feriado  where to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+id+"','dd/mm/yyyy')";
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
document.title="Dias Feriados - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Dias Feriados - Edición - "+document.title;
<%}%>
function chkNullValues(){

	var x = 0;
	var msg='';
	if(document.form1.fecha.value ==''){
		msg += ', fecha';
		x++;
	}if(document.form1.dia_libre.value==''){
		msg += ', dia libre';
		x++;
	} 
	if(msg!='')alert('Seleccione valor en'+msg+'!');
	if(x>0)	return false;
	else return true;
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="DIAS LIBRES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("baction","")%>
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>		
			<tr class="TextRow01">
				<td width="20%">&nbsp;Fecha</td>
				<td width="80%"><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="fecha"/>										
										<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("fecha")==null)?CmnMgr.getCurrentDate("dd/mm/yyyy"):cdo.getColValue("fecha")%>" />										
										</jsp:include>				</td>
			</tr>
			<tr class="TextRow01">
				<td>&nbsp;Dia Libre </td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="nameOfTBox1" value="dia_libre"/>
										<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("dia_libre")==null)?CmnMgr.getCurrentDate("dd/mm/yyyy"):cdo.getColValue("dia_libre")%>" />
										</jsp:include>				</td>
			</tr>
			<tr class="TextRow01">
			<td >&nbsp;Descripci&oacute;n</td>
			<td><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,50,100)%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"><%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%	fb.appendJsValidation("\n\tif (!chkNullValues()) error++;\n");%>
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
 
  cdo.setTableName("tbl_pla_dia_feriado");
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
  cdo.addColValue("fecha",request.getParameter("fecha")); 
  cdo.addColValue("dia_libre",request.getParameter("dia_libre"));
  cdo.addColValue("descripcion",request.getParameter("descripcion"));
   
  if (mode.equalsIgnoreCase("add"))
  {
	
	SQLMgr.insert(cdo);
  }
  else
  {
    cdo.setWhereClause("fecha=to_date('"+id+"','dd/mm/yyyy') and compania="+(String) session.getAttribute("_companyId"));

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/dias_libres_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/dias_libres_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/dias_libres_list.jsp';
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