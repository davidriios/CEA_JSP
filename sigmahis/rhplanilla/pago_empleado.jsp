
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
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800053") || SecMgr.checkAccess(session.getId(),"800054") || SecMgr.checkAccess(session.getId(),"800055") || SecMgr.checkAccess(session.getId(),"800056"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String desc = request.getParameter("desc");
String porc = request.getParameter("porc");
String appendFilter = "";
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

  if (request.getParameter("cedula") != null)
  {
    //appendFilter += " and upper(provincia||'-'||sigla||'-'||tomo||'-'||asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
	appendFilter += " and upper(e.provincia||'-'||e.sigla||'-'||e.tomo||'-'||e.asiento) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    searchOn = "e.provincia||'-'||e.sigla||'-'||e.tomo||'-'||e.asiento";
    searchVal = request.getParameter("cedula");
    searchType = "1";
    searchDisp = "Cédula";
  }
  else if (request.getParameter("name") != null)
  {
    appendFilter += " and upper(primer_nombre||' '||primer_apellido) like '%"+request.getParameter("name").toUpperCase()+"%'";    			
    searchOn = "primer_nombre||' '||primer_apellido";
    searchVal = request.getParameter("name");
    searchType = "1";
    searchDisp = "Nombre";
  }
  else if(request.getParameter("code")!=null)
  {
  	appendFilter += " and upper(e.EMP_ID) like '%"+request.getParameter("code").toUpperCase()+"%'";
    searchOn = "e.EMP_ID";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
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
	sql="select e.provincia||'-'||e.sigla||'-'||e.tomo||'-'||e.asiento as cedula, e.num_empleado,to_char(e.provincia,'09') as provincia, e.sigla, to_char(e.tomo,'09999') as tomo, to_char(e.asiento,'099999') as asiento, e.primer_nombre||' '||e.primer_apellido as name, e.primer_nombre as nombre, e.EMP_ID as code, e.primer_apellido as apellido, e.unidad_organi, nvl(e.salario_base ,0) as salario, nvl(e.rata_hora,0) as rata, u.descripcion as unidad, to_char(sum(nvl(b.descuento_mensual,0)),'999,999,990.00') mensual, to_char(sum((nvl(b.descuento_mensual,0)) / nvl(e.salario_base,e.rata_hora*e.horas_base))*100,'990.00') porcentaje from tbl_pla_empleado e, tbl_sec_unidad_ejec u, tbl_pla_descuento b where e.unidad_organi=u.codigo and e.provincia=b.provincia(+) and e.sigla=b.sigla(+) and e.tomo=b.tomo(+) and e.asiento=b.asiento(+) and e.compania=b.cod_compania(+) and e.compania=u.compania and e.compania="+(String) session.getAttribute("_companyId")+appendFilter+"  group by e.provincia||'-'||e.sigla||'-'||e.tomo||'-'||e.asiento , e.num_empleado ,to_char(e.provincia,'09') , e.sigla, to_char(e.tomo,'09999') , to_char(e.asiento,'099999'), e.primer_nombre||' '||e.primer_apellido, e.primer_nombre , e.emp_id , e.primer_apellido, e.unidad_organi, e.salario_base, e.rata_hora, u.descripcion order by e.primer_apellido, e.primer_nombre";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
//  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_empleado where compania="+(String) session.getAttribute("_companyId")+appendFilter);
    rowCount = CmnMgr.getCount("select count(*) FROM tbl_pla_empleado e, tbl_sec_unidad_ejec u where e.unidad_organi=u.codigo and e.compania=u.compania and e.compania="+(String) session.getAttribute("_companyId")+appendFilter);
	
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
document.title = 'Planilla - Deduciones de Empleados - '+document.title;

function empPagoDet(code, desc, porc)
{
abrir_ventana('../rhplanilla/pago_empleado_det.jsp?emp_id='+code+'&desc='+desc+'&porc='+porc);
}

function  printList()
{
abrir_ventana('../rhplanilla/print_list_descuento.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO - DESCUENTO DE EMPLEADOS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800054"))
//{
//%>
<%--		</a href="javascript:add()" class="Link00">[ Registrar Nuevo Acreedores de Empleados]</a>--%>
<%
//}
//%>
		</td>
	</tr>	
	
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="33%">&nbsp;C&oacute;digo
					<%=fb.textBox("code","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>	</td>
		<%=fb.formEnd()%>
		
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="30%">&nbsp;C&eacute;dula&nbsp;
					<%=fb.textBox("cedula","",false,false,false,30,null,null,null)%>
	  <%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>	
		
		<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="37%">&nbsp;Nombre
					<%=fb.textBox("name","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>	</td>
		<%=fb.formEnd()%>	
		
		
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800054"))
{
%>
	<authtype type='0'>	<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
<%
}
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
		<td width="5%">&nbsp;C&oacute;digo
		<td width="20%">&nbsp;C&eacute;dula</td>
		<td width="40%">&nbsp;Nombre</td>
		<td width="10%">&nbsp;Desc. Mensual</td>
		<td width="10%">&nbsp;% Endeudado</td>
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
					<td>&nbsp;<%=cdo.getColValue("code")%></td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("name")%></td>
					<td align="right">&nbsp;<%=cdo.getColValue("mensual")%></td>
					<td align="right">&nbsp;<%=cdo.getColValue("porcentaje")%></td>
					<td align="center">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800060"))
{
%>
			<authtype type='4'>		<a href="javascript:empPagoDet('<%=cdo.getColValue("code")%>','<%=cdo.getColValue("mensual")%>','<%=cdo.getColValue("porcentaje")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver detalle</a> </authtype>
<%}%>
					</td>
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
}// else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>
