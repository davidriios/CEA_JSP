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
/**
==================================================================================
400009	VER LISTA DE TIPOS DE PLANES DE POLIZAS
400010	IMPRIMIR LISTA DE TIPOS DE PLANES DE POLIZAS
400011	AGREGAR TIPO DE PLAN DE POLIZA
400012	MODIFICAR TIPO DE PLAN DE POLIZA
==================================================================================
**/
SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"400009") || SecMgr.checkAccess(session.getId(),"400010") || SecMgr.checkAccess(session.getId(),"400011") || SecMgr.checkAccess(session.getId(),"400012"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p?gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String tipoPoliza= request.getParameter("tipoPoliza");

if (tipoPoliza == null)
{
	tipoPoliza = "0";
}
else if (!tipoPoliza.equals("") && !tipoPoliza.equals("0"))
{
	appendFilter = "and b.codigo="+tipoPoliza;
}

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

	String poliza  = "";   // variables para mantener el valor de los campos filtrados en la consulta
	String descrip = "";

  if (request.getParameter("poliza") != null && !request.getParameter("poliza").trim().equals(""))
  {
    appendFilter += " and upper( a.poliza) like '%"+request.getParameter("poliza").toUpperCase()+"%'";
		poliza     = request.getParameter("poliza"); // utilizada para mantener la p?liza por la cual se filtr?
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(a.nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descrip    = request.getParameter("descripcion"); // utilizada para mantener la descripci?n de la p?liza que se filtr?
  }

	sql="select a.tipo_plan as tipo, b.codigo poliza, a.nombre ,a.comentario, b.codigo, b.nombre as descripcion from tbl_adm_tipo_plan a, tbl_adm_tipo_poliza b where a.poliza(+)= b.codigo "+appendFilter+" order by b.codigo, a.tipo_plan";
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
document.title = 'Convenio - Tipo Plan por Poliza - '+document.title;

function add()
{
abrir_ventana('../convenio/tipo_plan_config.jsp');
}

function edit(id)
{
abrir_ventana('../convenio/tipo_plan_config.jsp?mode=edit&id='+id);
}

function plan(id)
{
abrir_ventana('../convenio/tipo_plan_x_poliza.jsp?id='+id);
}

function  printList()
{
abrir_ventana('print_list_tipoplan.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONVENIOS - MANTENIMIENTO - TIPO PLAN POR POLIZA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="2" align="right">
		<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Tipo Poliza]</a></authtype>
		</td>
	</tr>
	<tr class="TextFilter">
		<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td colspan="2">&nbsp;
		Tipo de Poliza
		<%=fb.select(ConMgr.getConnection(),"select codigo, nombre from tbl_adm_tipo_poliza order by nombre","tipoPoliza",tipoPoliza,"T")%>
		</td>
	</tr>

	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<td width="50%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("poliza",poliza,false,false,false,30,null,null,null)%>
		</td>
		<td width="50%">&nbsp;<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("descripcion",descrip,false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>
		</td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("tipoPoliza","").replaceAll(" id=\"tipoPoliza\"","")%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("descripcion",descrip)%>
				<%=fb.hidden("poliza",poliza)%>
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
					<%=fb.hidden("tipoPoliza","").replaceAll(" id=\"tipoPoliza\"","")%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("descripcion",descrip)%>
					<%=fb.hidden("poliza",poliza)%>
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
		<td width="15%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="60%">&nbsp;<cellbytelabel>Nombre</cellbytelabel></td>
		<td width="15%">&nbsp;</td>
		<td width="10%">&nbsp;</td>
	</tr>
<%
				String plan ="";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%if(!plan.equalsIgnoreCase(cdo.getColValue("descripcion")))
				{
				%>
				<tr class="TextHeader01">
					<td colspan="2">&nbsp;[<%=cdo.getColValue("poliza")%>]&nbsp;&nbsp;<%=cdo.getColValue("descripcion")%></td>
					<td align="center"><authtype type='4'><a href="javascript:plan(<%=cdo.getColValue("codigo")%>)" class="Link03Bold" onMouseOver="setoverc(this,'Link04Bold')" onMouseOut="setoutc(this,'Link03Bold')"><cellbytelabel>Agregar Plan X Poliza</cellbytelabel></a></authtype>
					</td>
					<td align="center">

					<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="Link03Bold" onMouseOver="setoverc(this,'Link04Bold')" onMouseOut="setoutc(this,'Link03Bold')"><cellbytelabel>Editar Poliza</cellbytelabel></a></authtype>
					</td>
				</tr>
				<%
				}
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=cdo.getColValue("tipo")%>&nbsp;&nbsp;</td>
					<td colspan="3">&nbsp;<%=cdo.getColValue("nombre")%></td>
				</tr>
				<%
				plan=cdo.getColValue("descripcion");
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
				<%=fb.hidden("tipoPoliza","").replaceAll(" id=\"tipoPoliza\"","")%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("descripcion",descrip)%>
				<%=fb.hidden("poliza",poliza)%>
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
					<%=fb.hidden("tipoPoliza","").replaceAll(" id=\"tipoPoliza\"","")%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("descripcion",descrip)%>
					<%=fb.hidden("poliza",poliza)%>
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
//} else throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p?gina.");
}
%>