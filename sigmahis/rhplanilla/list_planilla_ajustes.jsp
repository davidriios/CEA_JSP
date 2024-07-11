<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

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
String estado = "", cargo="", ubic_seccion="", cedula="", nombre="",descripcion="", rath ="", emp="";
String id = request.getParameter("id");

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
    String codigo    = "",descrip   = "",anio = "",noPlanilla="";
	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
	{
		appendFilter += " and upper(a.cod_planilla) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		codigo     = request.getParameter("codigo");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
			appendFilter += " and a.anio="+request.getParameter("anio");
			anio  = request.getParameter("anio");
	}
	if (request.getParameter("noPlanilla") != null && !request.getParameter("noPlanilla").trim().equals(""))
	{
			appendFilter += " and a.num_planilla="+request.getParameter("noPlanilla");
			noPlanilla  = request.getParameter("noPlanilla");
	}

   sql="select distinct a.num_planilla,a.cod_planilla,a.anio, 'Ajuste a Planilla '||(select  nombre from tbl_pla_planilla where cod_planilla=a.cod_planilla and compania = a.cod_compania)||' '||a.anio||' - '||a.num_planilla descPlanilla, a.estado, case when a.estado ='PE' and nvl(a.actualizar,'N') ='N' and a.vobo_estado ='N'  then 'S' else 'N' end as status from tbl_pla_pago_ajuste a where a.cod_compania="+(String) session.getAttribute("_companyId")+appendFilter+"  order by  a.anio desc, a.num_planilla desc ";

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
document.title = 'Planilla - Registro de Transacciones de Ajuste - '+document.title;

function addNew(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_pagoajuste_list.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}

function add()
{
abrir_ventana('../rhplanilla/reg_pagoajuste_config.jsp?mode=add');
}
function regAjuste(mode,anio, codPlanilla, noPlanilla)
{
abrir_ventana('../rhplanilla/reg_pagoajuste_config.jsp?mode='+mode+'&anio='+anio+'&codPlanilla='+codPlanilla+'&noPlanilla='+noPlanilla);
}

function  printList()
{
  abrir_ventana('../rhplanilla/print_list_pagoajuste.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - CALCULO DE PLANILLA - REGISTRO DE TRANSACCIONES DE AJUSTE "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
<tr> <td align="right" colspan="3"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Ajustes a Planilla ]</a></authtype></td></tr>
			<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td width="25%">
						<cellbytelabel>Año</cellbytelabel> <%=fb.textBox("anio",anio,false,false,false,10)%>

			</td>
			<td width="25%">
					<cellbytelabel>C&oacute;digo de Planilla</cellbytelabel>
					<%=fb.intBox("codigo",codigo,false,false,false,10)%>
			</td>
			<td width="25%">
				<cellbytelabel>No. Planilla</cellbytelabel>
				<%=fb.textBox("noPlanilla",noPlanilla,false,false,false,20)%>
				<%=fb.submit("go","Ir")%>
			</td>

	  	</tr>
		<%=fb.formEnd()%>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("noPlanilla",noPlanilla)%>
				<%=fb.hidden("anio",anio)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s) </cellbytelabel><%=rowCount%></td>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("noPlanilla",noPlanilla)%>
					<%=fb.hidden("anio",anio)%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable">
		<tbody id="list">
  <tr class="TextHeader" align="center">
		<td width="20%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
		<td width="38%"><cellbytelabel>Planilla</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
	</tr>
                <%
				descripcion = "";
				emp ="";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";%>
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("anio")%></td>
					<td>&nbsp;<%=cdo.getColValue("descPlanilla")%></td>
					<td align="center"><authtype type='1'>	<a href="javascript:regAjuste('view',<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("cod_planilla")%>,<%=cdo.getColValue("num_planilla")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>ver</cellbytelabel></a> </authtype>
					</td>
					<td align="center"><%if(cdo.getColValue("status") != null && cdo.getColValue("status").trim().equals("S")){%><authtype type='4'>	<a href="javascript:regAjuste('edit',<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("cod_planilla")%>,<%=cdo.getColValue("num_planilla")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a> </authtype><%}%>
										</td>
				</tr>
                            <%
}
%>
	 </tbody>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("noPlanilla",noPlanilla)%>
				<%=fb.hidden("anio",anio)%>
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
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("noPlanilla",noPlanilla)%>
					<%=fb.hidden("anio",anio)%>
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