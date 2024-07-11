<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.StringTokenizer" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String creatorId = UserDet.getUserEmpId();

String mode=request.getParameter("mode");
String change=request.getParameter("change");
String type=request.getParameter("type");
String compId=(String) session.getAttribute("_companyId");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String title = "";

String dgi_id = request.getParameter("dgi_id");
String docId = "", docNo = "", trxId = "", ruc = "";

Exception up = new Exception("El ID de la DGI es inválido. Contacte su administrador!");
if (dgi_id==null || "".equals(dgi_id)) throw up;

try{
StringTokenizer st = new StringTokenizer(dgi_id,"|");
docId = st.nextToken();
docNo = st.nextToken();
trxId=st.nextToken();
ruc=st.nextToken();
}catch(Exception e){System.out.println("Error while processing the DGI ID. Caused by: "+e.toString());e.printStackTrace();}

CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();

if(mode==null) mode="add";
if(fg==null) fg="";
if (change == null) change = "0";
if (type == null) type = "0";

String key = "";

if(request.getMethod().equalsIgnoreCase("GET")){

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
null;
}



function doSubmit(valor){
	parent.hidePopWin(false);
}


</script>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
    <jsp:param name="title" value=""></jsp:param>
</jsp:include>
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("dgi_id", cdo.getColValue("dgi_id"))%>
<%=fb.hidden("change", change)%>
<%=fb.hidden("baction", "")%>
<%=fb.hidden("fg", fg)%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextRow06">
				<td colspan="4" align="center"><iframe name="itemFramePrint" id="itemFramePrint" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../common/run_process.jsp?fp=int_farmacia&actType=2&docType=DGI&docId=<%=docId%>&docNo=<%=docNo%>&tipo=FACP&ruc=<%=ruc%>" style="height:300px" scrolling="yes"> </iframe></td>
			</tr>
			<tr class="TextRow06">
				<td colspan="4" align="center"><iframe name="itemFrameMarb" id="itemFrameMarb" frameborder="0" align="center" width="100%" height="73px" scrolling="yes" src="../pos/reg_marbete.jsp?mode=add&fp=int_farmacia&doc_id=<%=trxId%>" style="height:500px" scrolling="yes"> </iframe></td>
			</tr>
			
			<tr class="TextRow02">
				<td colspan="4" align="right">
				<%//=fb.button("save","Aceptar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
}
%>
