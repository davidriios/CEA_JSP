<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.caja.DetalleBilletes"%>
<%@ page import="java.util.ArrayList"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iBill" scope="session" class="java.util.Hashtable"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");
String key = "";
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
boolean viewMode = false;
if (fg == null) fg = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Billetes - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BILLETES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("keySize",""+iBill.size())%>
		<tr class="TextHeader" align="center">
			<td width="37%">Denominaci&oacute;n</td>
			<td width="60%">Serie</td>
			<td width="3%">
			<%=fb.submit("agregar","+",true,(viewMode || !fg.trim().equals("")),"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Elemento")%></td>
		</tr>
<%
al = CmnMgr.reverseRecords(iBill);
for (int i=1; i<=iBill.size(); i++)
{
	key = al.get(i - 1).toString();
	DetalleBilletes det = (DetalleBilletes) iBill.get(key);
%>
		<%=fb.hidden("key"+i,key)%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01" align="center">
			<td><%=fb.select("denominacion"+i,"50=50 - CINCUENTA,100=100 - CIEN",det.getDenominacion(),false,(viewMode || !fg.trim().equals("")),0,"Text10",null,"")%></td>
			<td><%=fb.textBox("serie"+i,det.getSerie(),false,false,(viewMode || !fg.trim().equals("")),50,"Text10","","")%></td>
			<td align="center"><%=fb.submit("rem"+i,"X",true,(viewMode || !fg.trim().equals("")),"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow01">
			<td colspan="3" align="right">
				<%=fb.submit("guardar","Continuar",true,(viewMode || !fg.trim().equals("")),"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Continuar")%>
				<%=fb.button("cancel","Cancelar",false,false,"Text10",null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
			</td>
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
	String baction = request.getParameter("baction");
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	String itemRemoved = "";
	iBill.clear();
	int lastLineNo = 0;
	for (int i=1; i<=keySize; i++)
	{
		DetalleBilletes det = new DetalleBilletes();
		det.setDenominacion(request.getParameter("denominacion"+i));
		det.setSerie(request.getParameter("serie"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).trim().equals("")) itemRemoved = ""+i;
		else
		{
			try
			{
				lastLineNo++;
				if (lastLineNo < 10) key = "00"+lastLineNo;
				else if (lastLineNo < 100) key = "0"+lastLineNo;
				else key = ""+lastLineNo;
				det.setKey(key);
				iBill.put(det.getKey(),det);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode"+mode+"&compania="+compania+"&anio="+anio+"&codigo="+codigo+"&change=1");
		return;
	}
	else if (baction.equals("+"))
	{
		DetalleBilletes det = new DetalleBilletes();
		key = ""+(iBill.size() + 1);
		det.setKey(key);

		try
		{
			iBill.put(key,det);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode"+mode+"&compania="+compania+"&anio="+anio+"&codigo="+codigo+"&change=1");
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){parent.hidePopWin(false);}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>