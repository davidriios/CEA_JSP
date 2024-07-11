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
	//if (SecMgr.checkLogin(session.getId()) == 1) {
	//	if (SecMgr.checkAccess(session.getId(),"0") == 1) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList almedic = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String code = (request.getParameter("code") == null?"":request.getParameter("code"));
String medName = (request.getParameter("medName") == null?"":request.getParameter("medName"));
String tipoMedFilter = (request.getParameter("tipoMedFilter") == null?"":request.getParameter("tipoMedFilter"));
String status = (request.getParameter("status") == null?"":request.getParameter("status"));

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
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

  if ( !code.equals(""))
  {
    appendFilter += " and codigo = "+code+"";
    searchOn = "codigo";
    searchVal = code;
    searchType = "1";
    searchDisp = "Código";
  }

  if (!medName.trim().equals(""))
  {
    appendFilter += " and upper(medicamento) like '%"+medName.toUpperCase()+"%'";
    searchOn = "medicamento";
    searchVal = medName;
    searchType = "1";
    searchDisp = "Medicamento";
  }
  
  if (!tipoMedFilter.trim().equals("") && !tipoMedFilter.trim().equals("T") )
  { 
    appendFilter += " and antibio_ctrl = '"+tipoMedFilter+"'";
    searchOn = "antibio_ctrl";
    searchVal = tipoMedFilter;
    searchType = "1";
    searchDisp = "Tipo";
  }
  if (!status.trim().equals("") && !status.trim().equals("T"))
  { 
    appendFilter += " and status = '"+status+"'";
    searchOn = "status";
    searchVal = status;
    searchType = "1";
    searchDisp = "Estado";
  }

  if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
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
	sql="select codigo as code, medicamento, accion, interaccion, compania, mensaje, antibio_ctrl, status from TBL_SAL_MEDICAMENTOS  where compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by codigo";
	almedic = SQLMgr.getDataList(sql);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM TBL_SAL_MEDICAMENTOS  WHERE compania="+(String) session.getAttribute("_companyId")+appendFilter);

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
document.title = 'Centro de Servicio - '+document.title;

/****************** TODO: Mantenimiento ***********************/

function add(){
  abrir_ventana("../expediente/reg_medicamento.jsp");
}

function edit(code){
    abrir_ventana("../expediente/reg_medicamento.jsp?mode=edit&code="+code);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">

<%--<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>--%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTACION - MEDICAMENTOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
			<authtype type='3'><a class="Link00" href="javascript:add();">[ Registrar Medicamento ]</a></authtype>
		</td>
  </tr>

	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
				<%=fb.formStart()%>
				<td width="5%">&nbsp;C&oacute;digo </td>
				<td width="20%">&nbsp;
							<%=fb.textBox("code",code,false,false,false,30,null,null,"onFocus=\"this.select()\"")%>
				<td width="5%">&nbsp;Medicamento</td>
				<td width="20%">&nbsp;
							<%=fb.textBox("medName",medName,false,false,false,30,null,null,"onFocus=\"this.select()\"")%>
				</td>
				<td width="5%" align="right">Tipo</td>
				<td width="20%">&nbsp;
				   <%=fb.select("tipoMedFilter","T=Todos,S=Antibi&oacute;tico Restringido,N=No Restringido",tipoMedFilter)%>
				   
				   </td>	
				<td width="5%">&nbsp;Estado</td>
				<td width="35%">&nbsp;
							<%=fb.select("status","T=Todos,A=Activo,I=Inactivo",status)%>
							&nbsp;&nbsp;&nbsp;&nbsp;
				   <%=fb.submit("go","Ir")%>
				</td>				   
				<%=fb.formEnd()%>
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());%>
					<%=fb.formStart()%>
						<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
						<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
						<%=fb.hidden("searchOn",searchOn)%>
						<%=fb.hidden("searchVal",searchVal)%>
						<%=fb.hidden("searchValFromDate",searchValFromDate)%>
						<%=fb.hidden("searchValToDate",searchValToDate)%>
						<%=fb.hidden("searchType",searchType)%>
						<%=fb.hidden("searchDisp",searchDisp)%>
						<%=fb.hidden("searchQuery","sQ")%>
						<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
						<td width="40%">Total Registro(s) <%=rowCount%></td>
						<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());%>
					<%=fb.formStart()%>
						<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
						<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
						<%=fb.hidden("searchOn",searchOn)%>
						<%=fb.hidden("searchVal",searchVal)%>
						<%=fb.hidden("searchValFromDate",searchValFromDate)%>
						<%=fb.hidden("searchValToDate",searchValToDate)%>
						<%=fb.hidden("searchType",searchType)%>
						<%=fb.hidden("searchDisp",searchDisp)%>
						<%=fb.hidden("searchQuery","sQ")%>
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
		<td>C&oacute;digo</td>
		<td>Medicamento</td>
	    <td>Acci&oacute;n</td>
		<td>Interacci&oacute;n</td>
		<td>Mensaje</td>
		<td>&nbsp;</td>
	</tr>
	<%
				for (int i=0; i<almedic.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) almedic.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("code")%></td>
					<td><%=cdo.getColValue("medicamento")%></td>
					<td><%=cdo.getColValue("accion")%></td>
					<td><%=cdo.getColValue("interaccion")%></td>
					<td><%=cdo.getColValue("mensaje")%></td>
					<td><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("code")%>)" class="Link00">Editar</a></authtype></td>
				<%=fb.hidden("tipoMed",cdo.getColValue("antibio_ctrl"))%>
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
				fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
				<tr>
					<td colspan="4" align="right"> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
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