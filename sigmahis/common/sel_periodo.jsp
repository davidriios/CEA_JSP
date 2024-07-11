<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String date = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String pac_id = request.getParameter("pac_id");
String compania = request.getParameter("compania");
String referTo = request.getParameter("referTo");
String refType = request.getParameter("refType");
String refId = request.getParameter("refId");

if(fp==null) fp = "";
if(fg==null) fg = "";
if(referTo==null) referTo = "";
if(refType==null) refType = "";
if(refId==null) refId = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Common - '+document.title;

function setValues(){
	var fDate = document.dates.fDate.value;
	var tDate = document.dates.tDate.value;
	var pac_id = document.dates.pac_id.value;
	var referTo = document.dates.referTo.value;
	var refId = document.dates.refId.value;
	var refType = document.dates.refType.value;
	var adm = document.dates.adm.value;
<%/*if(fg.trim().equals("PAC")){%>
	window.opener.abrir_ventana('../facturacion/print_estado_cargo_res.jsp?referTo='+referTo+'&pacId='+pac_id+'&refId='+refId+'&refType='+refType+'&fDate='+fDate+'&tDate='+tDate);
	<%}else{*/%>
		window.opener.abrir_ventana('../facturacion/print_estado_cuenta.jsp?fg=<%=fg%>&referTo='+referTo+'&pacId='+pac_id+'&refId='+refId+'&refType='+refType+'&fDate='+fDate+'&tDate='+tDate+'&adm='+adm);
	<%//}%>
	window.close();
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr><td>&nbsp;</td></tr>
<tr><td>&nbsp;</td></tr>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
		<table align="center" width="90%" cellpadding="1" cellspacing="0">
			<%
      fb = new FormBean("dates","","post","");
      %>
	  <%=fb.formStart()%>
      <%=fb.hidden("pac_id",pac_id)%>
	  <%=fb.hidden("referTo",referTo)%>
	  <%=fb.hidden("refType",refType)%>
	  <%=fb.hidden("refId",refId)%>
	  
			<tr class="TextPager">
				<td>&nbsp;</td>
			</tr>
			<tr class="TextPager">
				<td><cellbytelabel>Seleccione Periodo</cellbytelabel></td>
			</tr>
			<tr class="TextPager">
				<td>&nbsp;</td>
			</tr>
			<tr class="TextPager">
				<td>
        <jsp:include page="../common/calendar.jsp" flush="true">
        <jsp:param name="noOfDateTBox" value="2" />
        <jsp:param name="nameOfTBox1" value="fDate" />
        <jsp:param name="valueOfTBox1" value="<%=date%>" />
        <jsp:param name="nameOfTBox2" value="tDate" />
        <jsp:param name="valueOfTBox2" value="<%=date%>" />
        </jsp:include>
        </td>
			</tr>
			<tr class="TextPager">
				<td>&nbsp;No Admision:<%=fb.intBox("adm","",false,false,false,5,null,null,"")%>  </td>
			</tr>
			<tr class="TextPager">
				<td align="center">
				<%=fb.button("btn","Aceptar",true,false,null,"Text10","onClick=\"javascript:setValues()\"")%>
				<%=fb.button("btnClose","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
        </td>
			</tr>
			<tr class="TextPager">
				<td>&nbsp;</td>
			</tr>
		<%=fb.formEnd()%>
		</table>
	</td>
</tr>
<tr><td>&nbsp;</td></tr>
</table>
</body>
</html>
<%
}
%>
