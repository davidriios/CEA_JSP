<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

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

	String unidadCode = "";  // variables para mantener el valor de los campos filtrados en la consulta
	String unidadDesc = "";
	String cuenta     = "";

	if (request.getParameter("unidadCode") != null && !request.getParameter("unidadCode").trim().equals("") )
	{
		appendFilter += " and upper(a.unidad_adm) like '%"+request.getParameter("unidadCode").toUpperCase()+"%'";
	unidadCode  = request.getParameter("unidadCode");
	}
	if (request.getParameter("unidadDesc") != null && !request.getParameter("unidadDesc").trim().equals(""))
	{
		appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("unidadDesc").toUpperCase()+"%'";
	unidadDesc = request.getParameter("unidadDesc");
	}
	if (request.getParameter("cuenta") != null && !request.getParameter("cuenta").trim().equals(""))
	{
		appendFilter += " and upper(c.descripcion) like '%"+request.getParameter("cuenta").toUpperCase()+"%'";
	cuenta = request.getParameter("cuenta");
	}


	sql = "SELECT a.unidad_adm, b.descripcion as unidad, a.cta1||' - '||a.cta2||' - '||a.cta3||' - '||a.cta4||' - '||a.cta5||' - '||a.cta6 as cta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, c.descripcion as cuenta FROM tbl_con_pres_cuenta_x_unidad a, tbl_sec_unidad_ejec b, tbl_con_catalogo_gral c WHERE a.unidad_adm=b.codigo and a.compania=b.compania and a.cta1=c.cta1 and a.cta2=c.cta2 and a.cta3=c.cta3 and a.cta4=c.cta4 and a.cta5=c.cta5 and a.cta6=c.cta6 and a.compania=c.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by b.descripcion, c.descripcion";
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
document.title = 'Acceso a Cuentas x Unidad - '+document.title;

function add()
{
	abrir_ventana('../presupuesto/acceso_x_unidad_config.jsp');
}

function edit(unidadId,cta1,cta2,cta3,cta4,cta5,cta6)
{
	abrir_ventana('../presupuesto/acceso_x_unidad_config.jsp?mode=edit&unidadId='+unidadId+'&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6);
}

function printList()
{
	abrir_ventana('../presupuesto/print_list_acceso_x_unidad.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
		<tr>
				<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Acceso</cellbytelabel> ]</a></authtype></td>
		</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="1">
					<tr class="TextFilter">
										<%
						fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
						<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
						<td width="22%"><cellbytelabel>Unidad</cellbytelabel>
						<%=fb.textBox("unidadCode",unidadCode,false,false,false,15,null,null,null)%>

					</td>
											<td width="38%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("unidadDesc",unidadDesc,false,false,false,36,null,null,null)%>

					</td>
											<td width="40%"><cellbytelabel>Desc. Cuenta</cellbytelabel>
						<%=fb.textBox("cuenta",cuenta,false,false,false,37,null,null,null)%>
					<%=fb.submit("go","Ir")%>
					</td>
						<%=fb.formEnd()%>
					</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
		<tr>
				<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
		</tr>
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
				<%=fb.hidden("unidadCode",""+unidadCode)%>
				<%=fb.hidden("unidadDesc",""+unidadDesc)%>
				<%=fb.hidden("cuenta",""+cuenta)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("unidadCode",""+unidadCode)%>
					<%=fb.hidden("unidadDesc",""+unidadDesc)%>
					<%=fb.hidden("cuenta",""+cuenta)%>
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
				<tr class="TextHeader">
					<td width="5%">&nbsp;</td>
					<td width="12%"><cellbytelabel>Unidad Admin</cellbytelabel>.</td>
					<td width="23%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Cuenta Contable</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("unidad_adm")%></td>
					<td><%=cdo.getColValue("unidad")%></td>
					<td><%=cdo.getColValue("cta")%></td>
					<td><%=cdo.getColValue("cuenta")%></td>
					<td align="center"><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("unidad_adm")%>,<%=cdo.getColValue("cta1")%>,<%=cdo.getColValue("cta2")%>,<%=cdo.getColValue("cta3")%>,<%=cdo.getColValue("cta4")%>,<%=cdo.getColValue("cta5")%>,<%=cdo.getColValue("cta6")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
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
				<%=fb.hidden("unidadCode",""+unidadCode)%>
				<%=fb.hidden("unidadDesc",""+unidadDesc)%>
				<%=fb.hidden("cuenta",""+cuenta)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("unidadCode",""+unidadCode)%>
					<%=fb.hidden("unidadDesc",""+unidadDesc)%>
					<%=fb.hidden("cuenta",""+cuenta)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>