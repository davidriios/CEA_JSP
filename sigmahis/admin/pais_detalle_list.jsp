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
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String[] lvlColor = {"TextRow01","TextRow02","TextRow03","TextRow04","TextRow05"};
String[] lvlType = {"Pais","Provincia","Distrito","Corregimiento","Comunidad"};
String paisCode = request.getParameter("paisCode");
if (paisCode == null) throw new Exception("El Pais no es válido. Por favor intente nuevamente!");
appendFilter = " where codigo_pais="+paisCode+" and nivel>0";
String xLvl = "-1";
String xName = "";

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

	if (request.getParameter("seleccion") != null && request.getParameter("textbox") != null)
	{
/*
		if (request.getParameter("seleccion") == "1")
	{
		appendFilter += " and upper(nombre_provincia) like '%"+request.getParameter("textbox").toUpperCase()+"%'";
		searchOn = "nombre_provincia";
		searchVal = request.getParameter("textbox");
		searchType = "1";
		searchDisp = "Provincia";
	}

	else if (request.getParameter("seleccion") == "2")
		{
			appendFilter += " and upper(nombre_distrito) like '%"+request.getParameter("textbox").toUpperCase()+"%'";
			searchOn = "nombre_distrito";
			searchVal = request.getParameter("textbox");
			searchType = "1";
			searchDisp = "Distrito";
		}
	else if (request.getParameter("seleccion") == "3")
	{
		appendFilter += " and upper(nombre_corregimiento) like '%"+request.getParameter("textbox").toUpperCase()+"%'";
		searchOn = "nombre_corregimiento";
		searchVal = request.getParameter("textbox");
		searchType = "1";
		searchDisp = "Corregimiento";
	}
	else if (request.getParameter("seleccion") == "4")
	{
		appendFilter += " and upper(nombre_comunidad) like '%"+request.getParameter("textbox").toUpperCase()+"%'";
		searchOn = "nombre_comunidad";
		searchVal = request.getParameter("comunidad");
		searchType = "1";
		searchDisp = "Comunidad";
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
	{
	 if (searchType.equals("1"))
	 {
		 appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
	 }
	}
	else
	{
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
	}
*/
	if (!request.getParameter("seleccion").equals("-1")) appendFilter += " and nivel="+request.getParameter("seleccion");
	appendFilter += " and upper(nivel_nombre) like '%"+request.getParameter("textbox").toUpperCase()+"%'";

	xLvl = request.getParameter("seleccion");
	xName = request.getParameter("textbox");
 }

	sql = "SELECT CODIGO_PAIS, NOMBRE_PAIS, CODIGO_PROVINCIA, NOMBRE_PROVINCIA, CODIGO_DISTRITO, NOMBRE_DISTRITO, CODIGO_CORREGIMIENTO, NOMBRE_CORREGIMIENTO, CODIGO_COMUNIDAD, NOMBRE_COMUNIDAD, nivel, nivel_codigo, nivel_nombre FROM vw_sec_regional_location"+appendFilter+" order by decode(nombre_pais,'NA',' '||nombre_pais,nombre_pais), decode(nombre_provincia,'NA',' '||nombre_provincia,nombre_provincia), decode(nombre_distrito,'NA',' '||nombre_distrito,nombre_distrito), decode(nombre_corregimiento,'NA',' '||nombre_corregimiento,nombre_corregimiento), decode(nombre_comunidad,'NA',' '||nombre_comunidad,nombre_comunidad)";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from vw_sec_regional_location"+appendFilter);

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
document.title = 'Provincia - '+document.title;

function add(lvl,pais, provCode,provNomb, distCode,distNomb, corrCode,corrNomb, comuName,comuCode)
{
//abrir_ventana1('pais_detalle_config.jsp?mode=add&lvl='+lvl+'&paisCode=<%=paisCode%>&provCode='+provCode+'&distCode='+distCode+'&corrCode='+corrCode+'&comuCode='+comuCode);

abrir_ventana1('pais_detalle_config.jsp?mode=add&lvl='+lvl+'&paisCode=<%=paisCode%>&pais='+pais+'&provCode='+provCode+'&provNomb='+provNomb+'&distCode='+distCode+'&distNomb='+distNomb+'&corrCode='+corrCode+'&corrNomb='+corrNomb+'&comuName='+comuName+'&comuCode='+comuCode);
}

function edit(lvl, lvlName, pais,provCode,provNomb, distCode,distNomb, corrCode,corrNomb, comuName,comuCode)
{
	abrir_ventana1('pais_detalle_config.jsp?mode=edit&lvl='+lvl+'&lvlName='+lvlName+'&paisCode=<%=paisCode%>&pais='+pais+'&provCode='+provCode+'&provNomb='+provNomb+'&distCode='+distCode+'&distNomb='+distNomb+'&corrCode='+corrCode+'&corrNomb='+corrNomb+'&comuName='+comuName+'&comuCode='+comuCode);
}

function printList()
{
	abrir_ventana1('print_list_pais_detalle.jsp?paisCode=<%=paisCode%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PROVINCIA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
		<tr>
				<td align="right">
				<%
			//if (SecMgr.checkAccess(session.getId(),"0"))
			//{
				%>
				
				
			<a href="javascript:add(1,<%=paisCode%>, '0', '0', '0', '0', '0')" class="Link00">[ <cellbytelabel>Registrar Nueva Provincia</cellbytelabel> ]</a>
				<%
			//}
			%>
			</td>
		</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextFilter">
										<%
						fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
						<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
						<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
						<td width="100%">&nbsp;
					<%=fb.select("seleccion","-1=TODOS,1=PROVINCIA,2=DISTRITO,3=CORREGIMIENTO,4=COMUNIDAD",xLvl)%>&nbsp;&nbsp;
					<%=fb.textBox("textbox","",false,false,false,45)%>
					<%=fb.hidden("paisCode",paisCode)%>
					<%=fb.submit("go","Ir")%>
					</td>
						<%=fb.formEnd()%>
					</tr>
			</table>
		</td>
	</tr>
		<tr>
				<td align="right">
		<%
			//if (SecMgr.checkAccess(session.getId(),"0"))
			//{
		%>
			<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
				<%
					//}
				%>
		</td>
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
				<%=fb.hidden("paisCode",paisCode)%>
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
					<%=fb.hidden("paisCode",paisCode)%>
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
					<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

				<tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="20%"><cellbytelabel>Provincia</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Distrito</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Corregimiento</cellbytelabel></td>
					<td width="20%"><cellbytelabel>Comunidad</cellbytelabel></td>
					<td width="7%">&nbsp;</td>
					<td width="8%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 int lvl = Integer.parseInt(cdo.getColValue("nivel"));
				 String color = lvlColor[lvl];
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=(!xLvl.equals("-1") || !xName.equals("") || lvl == 1)?cdo.getColValue("nombre_provincia"):""%></td>
					<td><%=(!xLvl.equals("-1") || !xName.equals("") || lvl == 2)?cdo.getColValue("nombre_distrito"):""%></td>
					<td><%=(!xLvl.equals("-1") || !xName.equals("") || lvl == 3)?cdo.getColValue("nombre_corregimiento"):""%></td>
					<td><%=(!xLvl.equals("-1") || !xName.equals("") || lvl == 4)?cdo.getColValue("nombre_comunidad"):""%></td>
					<td align="center">
					<a href="javascript:edit(<%=lvl%>,'<%=cdo.getColValue("nivel_nombre")%>','<%=cdo.getColValue("nombre_pais")%>',<%=cdo.getColValue("codigo_provincia")%>,'<%=cdo.getColValue("nombre_provincia")%>',<%=cdo.getColValue("codigo_distrito")%>,'<%=cdo.getColValue("nombre_distrito")%>',<%=cdo.getColValue("codigo_corregimiento")%>,'<%=cdo.getColValue("nombre_corregimiento")%>','<%=cdo.getColValue("nombre_comunidad")%>',<%=cdo.getColValue("codigo_comunidad")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Modificar</a></td>
					<td align="center">
					<%
					if (lvl != 4)
					{
					%>
					<!--<a href="javascript:add(<%//=(lvl + 1)%>,<%//=cdo.getColValue("codigo_provincia")%>,<%//=cdo.getColValue("codigo_distrito")%>,<%//=cdo.getColValue("codigo_corregimiento")%>,<%//=cdo.getColValue("codigo_comunidad")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Agregar <%//=lvlType[lvl + 1]%></a>-->
					
					<a href="javascript:add(<%=(lvl + 1)%>,'<%=cdo.getColValue("nombre_pais")%>',<%=cdo.getColValue("codigo_provincia")%>,'<%=cdo.getColValue("nombre_provincia")%>',<%=cdo.getColValue("codigo_distrito")%>,'<%=cdo.getColValue("nombre_distrito")%>',<%=cdo.getColValue("codigo_corregimiento")%>,'<%=cdo.getColValue("nombre_corregimiento")%>','<%=cdo.getColValue("nombre_comunidad")%>',<%=cdo.getColValue("codigo_comunidad")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Agregar <%=lvlType[lvl + 1]%></a>
					
					<%
					}
					%>
					</td>
				</tr>
				<%
				}
				%>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
					</table>
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
				<%=fb.hidden("paisCode",paisCode)%>
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
					<%=fb.hidden("paisCode",paisCode)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>