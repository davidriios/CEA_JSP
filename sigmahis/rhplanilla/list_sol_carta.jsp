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
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList sec = new ArrayList();
int iconHeight = 40;
int iconWidth = 40;
int rowCount = 0;
String sql = "";
String appendFilter = "";
String codigo = request.getParameter("codigo");
String estado = request.getParameter("estado");
String fp = request.getParameter("fp");
if(fp == null || fp == "") fp ="";
if (codigo == null) codigo = "";
if (estado == null) estado = "";


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

  String unidad = "",descripcion="",cedula="",nombre="",cargo="",numEmpleado ="",empId="";
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
  {
    appendFilter += " and upper(a.cedula1) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
	cedula = request.getParameter("cedula");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(a.nombre_empleado) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
	nombre = request.getParameter("nombre");
  }
  if (request.getParameter("numEmpleado") != null && !request.getParameter("numEmpleado").trim().equals(""))
  {
    appendFilter += " and upper(a.num_empleado) like '%"+request.getParameter("numEmpleado").toUpperCase()+"%'";
	numEmpleado  = request.getParameter("numEmpleado");
  }
  if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
  {
    appendFilter += " and upper(a.emp_id) like '"+request.getParameter("empId").toUpperCase()+"%'";
	empId = request.getParameter("empId");
  }

	sql="select a.cedula1 as cedula,a.nombre_empleado  as nombre, a.emp_id as empId,a.num_empleado as numEmpleado, to_char(d.fecha_solicitud,'dd/mm/yyyy') as  fechaSolicitud,d.id, d.estado,d.impreso ,decode(d.impreso,'S','SI','N','NO')impresoDesc from vw_pla_empleado a,tbl_pla_sol_carta d where a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.emp_id = d.emp_id order by a.emp_id, d.id";

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
document.title = 'Planilla - Expedientes de Empleados - '+document.title;
function  printList(){abrir_ventana('../rhplanilla/print_list_sol_carta.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function add(){abrir_ventana('../rhplanilla/reg_carta_licencia.jsp');}
function edit(id,mode){abrir_ventana('../rhplanilla/reg_carta_licencia.jsp?mode='+mode+'&id='+id);}
function deleteCarta(id){showPopWin('../common/run_process.jsp?fp=carta&actType=50&docType=CARTA&docId='+id+'&docNo='+id,winWidth*.75,winHeight*.65,null,null,'');}
function printCarta(id){abrir_ventana('../rhplanilla/print_carta_licencia_css.jsp?id='+id);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - CARTAS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right" colspan="6"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nueva Sol. Carta ]</a></authtype></td>
</tr>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
		<tr class="TextFilter">
			<td width="30%">Nombre del Empleado:&nbsp;&nbsp;<%=fb.textBox("nombre","",false,false,false,25,null,null,null)%></td>
			<td width="30%">C&eacute;dula:&nbsp;&nbsp;<%=fb.textBox("cedula","",false,false,false,13,null,null,null)%></td>
			<td width="40%">&nbsp;Num Empleado:&nbsp;&nbsp;<%=fb.textBox("numEmpleado","",false,false,false,13,null,null,null)%>&nbsp;&nbsp;ID:&nbsp;&nbsp;<%=fb.textBox("empId","",false,false,false,13,null,null,null)%>
			<%=fb.submit("go","Ir")%></td>
		</tr>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("empId",empId)%>

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
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("empId",empId)%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;C&eacute;dula</td>
		<td width="25%">&nbsp;Nombre</td>
		<td width="10%">&nbsp;Num. Empleado</td>
		<td width="10%">&nbsp;F.Solicitud</td>
		<td width="5%">Impreso</td>
 		<td width="4%">&nbsp;</td>
		<td width="4%">&nbsp;</td>
		<td width="4%">&nbsp;</td>
		<td width="4%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>
	<%=fb.hidden("fp",fp)%>
  <%String descripcionArea = "";
		for (int i=0; i<al.size(); i++)
		{
			 CommonDataObject cdo = (CommonDataObject) al.get(i);
			 String color = "TextRow02";
			 if (i % 2 == 0) color = "TextRow01";
		%>
					<%=fb.hidden("empId"+i,cdo.getColValue("empId"))%>
					<%=fb.hidden("id"+i,cdo.getColValue("id"))%>

					<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("numEmpleado")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fechaSolicitud")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("impresoDesc")%></td>
					<td align="center"><authtype type='1'><a href="javascript:edit(<%=cdo.getColValue("id")%>,'view')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype></td>
					<td align="center">
					<authtype type='2'><a href="javascript:printCarta(<%=cdo.getColValue("id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a></authtype></td>
					<td align="center"><%if(!cdo.getColValue("impreso").trim().equals("S")){%><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("id")%>,'edit')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype><%}%></td>
					<td align="center"><%if(!cdo.getColValue("impreso").trim().equals("S")){%><authtype type='50'><a href="javascript:deleteCarta(<%=cdo.getColValue("id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Eliminar</a></authtype><%}%></td>
				</tr>
      <%}%>
<%=fb.formEnd()%>

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
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("empId",empId)%>
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
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("empId",empId)%>
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