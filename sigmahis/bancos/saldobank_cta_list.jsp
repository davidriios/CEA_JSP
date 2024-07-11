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
/** Check whether the user is logged in or not what access rights he has----------------------------
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900017") || SecMgr.checkAccess(session.getId(),"900018") || SecMgr.checkAccess(session.getId(),"900019") || SecMgr.checkAccess(session.getId(),"900020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String filter = request.getParameter("filter");
String fp = request.getParameter("fp");

 filter="";
if (fp==null) fp="";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}
	String cuentaCode="",descripcion="",banco="";
	if (request.getParameter("cuentaCode") != null && !request.getParameter("cuentaCode").trim().equals(""))
	{
	appendFilter += " and upper(a.cuenta_banco) like '%"+request.getParameter("cuentaCode").toUpperCase()+"%'";
		cuentaCode = request.getParameter("cuentaCode");
	}
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion = request.getParameter("descripcion");
	}
	if (request.getParameter("banco") != null && !request.getParameter("banco").trim().equals(""))
	{
		appendFilter += " and upper(b.nombre) like '%"+request.getParameter("banco").toUpperCase()+"%'";
		banco = request.getParameter("banco");
	}
    if(fp.trim().equals("deposito"))appendFilter += " and a.rec_dep_caja ='S'  ";

	sql = "SELECT a.cuenta_banco as cuentaCode, a.cod_banco as bancoCode, a.descripcion as ctaBanco, a.descripcion as cuenta, b.nombre as banco FROM tbl_con_cuenta_bancaria a, tbl_con_banco b WHERE a.compania = b.compania and a.cod_banco = b.cod_banco and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+filter+" and a.estado_cuenta ='ACT' order by ctaBanco";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Cuenta Bancaria - '+document.title;

function returnValue(cuentaCode,bancoCode,ctaBanco,cuenta,banco,id)
{
	switch(id)
	{
		case 1:
		window.opener.document.form1.cuentaCode.value = cuentaCode;
		window.opener.document.form1.bancoCode.value = bancoCode;
		window.opener.document.form1.ctaBanco.value = ctaBanco;
		window.close();
	break;

	case 2:
		window.opener.document.form1.cuentaCode.value = cuentaCode;
		window.opener.document.form1.bancoCode.value = bancoCode;
		window.opener.document.form1.cuenta.value = cuenta;
		window.opener.document.form1.banco.value = banco;
		window.close();
	break;
	case 3:
		window.opener.document.form1.cuentaCode.value = cuentaCode;
		window.opener.document.form1.bancoCode.value = bancoCode;
		window.opener.document.form1.cuenta.value = cuenta;
		window.opener.document.form1.banco.value = banco;
		window.opener.document.form0.banco.value = bancoCode;
		window.opener.document.form0.name_banco.value=banco;
		window.opener.document.form0.cuenta.value =cuentaCode;
		window.opener.document.form0.name_cuenta.value=cuenta;

		window.close();
	break;
	case 4:
		window.opener.document.form0.banco.value = bancoCode;
		window.opener.document.form0.name_banco.value=banco;
		window.opener.document.form0.cuenta.value = cuentaCode;
		window.opener.document.form0.name_cuenta.value=cuenta;
		window.close();
	break;
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BANCOS - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
					<tr class="TextFilter">
										<%
						fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
						<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
						<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("id",""+id)%>
					<%=fb.hidden("fp",""+fp)%>

						<td width="30%">C&oacute;d. Cuenta
					<%=fb.textBox("cuentaCode","",false,false,false,25)%>
					</td>
						<td width="35%">Descripci&oacute;n
					<%=fb.textBox("descripcion","",false,false,false,35)%>
					</td>
						<td width="35%">Banco
					<%=fb.textBox("banco","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
						<%=fb.formEnd()%>
					</tr>

			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
		<tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("id",""+id)%>
				<%=fb.hidden("cuentaCode",""+cuentaCode)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("banco",""+banco)%>
				<%=fb.hidden("fp",""+fp)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("id",""+id)%>
					<%=fb.hidden("cuentaCode",""+cuentaCode)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("banco",""+banco)%>
					<%=fb.hidden("fp",""+fp)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="25%">Cuenta del Banco</td>
					<td width="40%">Descripci&oacute;n</td>
					<td width="30%">Banco</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue('<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("ctaBanco")%>','<%=cdo.getColValue("cuenta")%>','<%=cdo.getColValue("banco")%>',<%=id%>)">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("cuentaCode")%></td>
					<td><%=cdo.getColValue("ctaBanco")%></td>
					<td><%=cdo.getColValue("bancoCode")%> - <%=cdo.getColValue("banco")%></td>
				</tr>
				<%
				}
				%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("id",""+id)%>
				<%=fb.hidden("cuentaCode",""+cuentaCode)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<%=fb.hidden("banco",""+banco)%>
				<%=fb.hidden("fp",""+fp)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("id",""+id)%>
					<%=fb.hidden("cuentaCode",""+cuentaCode)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
					<%=fb.hidden("banco",""+banco)%>
					<%=fb.hidden("fp",""+fp)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

 </body>
</html>
<%
}
%>