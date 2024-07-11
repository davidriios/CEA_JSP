
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
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100027") || SecMgr.checkAccess(session.getId(),"100028") || SecMgr.checkAccess(session.getId(),"100029") || SecMgr.checkAccess(session.getId(),"100030"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String status = request.getParameter("status");
String fg = request.getParameter("fg");
if(fg == null) fg = "";
if (status == null) status = "";
if (!status.equals("")) appendFilter = " and a.estado='"+status+"'";

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

  if (request.getParameter("cedula") != null)
	{
		appendFilter += " and upper(primer_nombre||' '||primer_apellido as nombre, provincia||'-'||sigla||'-'||tomo||'-'||asiento||'-'||compania) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
		searchOn = "primer_nombre||' '||primer_apellido as nombre, provincia||'-'||sigla||'-'||tomo||'-'||asiento||'-'||compania";
		searchVal = request.getParameter("nombre");
		searchType = "1";
		searchDisp = "Nombre";
	}
	else if (request.getParameter("nombre") != null)
    {
		appendFilter += " and upper(b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,'',' '||b.apellido_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";

		searchOn = "b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,'',' '||b.apellido_casada))";
		searchVal = request.getParameter("nombre");
		searchType = "1";
		searchDisp = "Nombre";
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
	
	sql = "SELECT a.codigo, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,'',' '||b.apellido_casada)) as nombre, a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento||'-'||a.compania as cedula, b.cargo, decode(a.puntaje_total,null,' ',puntaje_total) as puntajeTotal, to_char(a.periodo_evdesde,'dd-mm-yyyy') as evDesde, to_char(a.periodo_evhasta,'dd-mm-yyyy') as evHasta, b.emp_id as empId FROM tbl_pla_evaluacion a, tbl_pla_empleado b WHERE a.provincia=b.provincia(+) and a.sigla=b.sigla(+) and a.tomo=b.tomo(+) and a.asiento=b.asiento(+)  "+appendFilter+" and a.emp_id=b.emp_id(+) and a.compania=b.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+appendFilter;
	al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_evaluacion a, tbl_pla_empleado b WHERE a.provincia=b.provincia(+) and a.sigla=b.sigla(+) and a.tomo=b.tomo(+) and a.asiento=b.asiento(+)and a.emp_id=b.emp_id(+) and a.compania=b.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+appendFilter);

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
document.title = 'Evaluación del Empleado - '+document.title;

function add()
{
    abrir_ventana('../rhplanilla/evaluacion_empleado_config.jsp?fg=<%=fg%>');
}
function edit(id,prov,sigla,tomo,asiento,empId)
{
	abrir_ventana('../rhplanilla/evaluacion_empleado_config.jsp?mode=edit&id='+id+'&prov='+prov+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento+'&emp_id='+empId);
}

function printList()
{
	abrir_ventana('../rhplanilla/print_list_evaluacion_empleado.jsp');
}

function getMain(formx)
{
	formx.status.value = document.search00.status.value;
	return true;
}

function printEval(empId,evDesde,evHasta)
{
//	abrir_ventana('../rhplanilla/print_evalua_empleado.jsp?id='+id+'&prov='+prov+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento);
	abrir_ventana('../rhplanilla/print_eval.jsp?empId='+empId+'&evDesde='+evDesde+'&evHasta='+evHasta);

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RHPLANILLA - MANTENIMIENTOS - EVALUACION DEL EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">
	<%
	//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
	//{
	%>
<authtype type='3'>  <a href="javascript:add()" class="Link00">[ Registrar Nueva Evaluaci&oacute;n de Empleado ]</a></authtype>
	<%
	//}
	%>
		</td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextFilter">
		
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("status","").replaceAll(" id=\"status\"","")%>
        <%=fb.hidden("fg", fg)%>
				<td width="50%">C&oacute;digo
					<%=fb.textBox("codigo","",false,false,false,15)%>
			  	<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
				<%
				fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("status","").replaceAll(" id=\"status\"","")%>
        <%=fb.hidden("fg", fg)%>
				<td width="50%">Nombre
					<%=fb.textBox("nombre","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;
		<%
		//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100028"))
		//{
		%>
		<authtype type='0'>	 <a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
        <%=fb.hidden("fg", fg)%>
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
        <%=fb.hidden("fg", fg)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
	<tr class="TextHeader" align="center">
		<td width="15%">C&eacute;dula</td>
		<td width="40%">Nombre</td>
		<td width="10%">Cargo</td>
		<td width="15%">Puntaje Total</td>
		<td width="10%">&nbsp;</td>
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
		<td><%=cdo.getColValue("cedula")%></td>
		<td><%=cdo.getColValue("nombre")%></td>
		<td><%=cdo.getColValue("cargo")%></td>
		<td><%=cdo.getColValue("puntajeTotal")%></td>
		<td align="center">
	<%
	//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100030"))
	//{
	%>
	<authtype type='0'>	<a href="javascript:edit(<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("provincia")%>,'<%=cdo.getColValue("sigla")%>',<%=cdo.getColValue("tomo")%>,<%=cdo.getColValue("asiento")%>,<%=cdo.getColValue("empId")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
	<%
	//}
	%>
	</td>
	<td align="center">
	<authtype type='50'><a href="javascript:printEval(<%=cdo.getColValue("empId")%>,'<%=cdo.getColValue("evDesde")%>','<%=cdo.getColValue("evHasta")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Imprimir</a></authtype>
	</td>
	</tr>
	<%
	}
	%>				
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
        <%=fb.hidden("fg", fg)%>
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
        <%=fb.hidden("fg", fg)%>
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
