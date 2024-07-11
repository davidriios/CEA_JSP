
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
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList sec = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
int iconHeight = 20;
int iconWidth = 20;

if(request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descripcion = request.getParameter("descripcion");
  }
  if (request.getParameter("cargo") != null && !request.getParameter("cargo").trim().equals(""))
  {
    appendFilter += " and upper(c.denominacion) like '"+request.getParameter("cargo").toUpperCase()+"%'";
	cargo = request.getParameter("cargo");
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
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(d.codigo) like '"+request.getParameter("codigo").toUpperCase()+"%'";
	empId = request.getParameter("empId");
  }
  

	sql = "select a.cedula1 cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.nombre_empleado as nombre,a.unidad_organi as seccion, b.descripcion as descripcion, a.emp_id empId, c.denominacion as cargo,d.codigo,a.num_empleado,d.estado,to_char(d.fecha_inicio,'dd/mm/yyyy') as fechaDesde, to_char(d.fecha_final,'dd/mm/yyyy') as fechaHasta,nvl(d.cant_quincenas,0) as quincenaSal,decode(d.estado,'A','ACTUALIZADA','P','PENDIENTE','R','RECHAZADA')descEstado, decode(d.motivo_falta,35,'INCAPACIDAD',13,'ENFERMEDAD',37,'LICENCIA POR GRAVIDEZ',40,'LICENCIA CON SUELDO',38,'LICENCIA SIN SUELDO',39,'RIESGO PROFESIONAL') descTipo from vw_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_cc_licencia d, tbl_pla_cargo c where a.compania = b.compania and /*a.ubic_depto*/ a.unidad_organi= b.codigo and a.compania = c.compania and a.cargo=c.codigo  and a.emp_id = d.emp_id and a.compania = d.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.nombre_empleado ";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
document.title = 'Recursos Humanos - Licencia, Incapacidades - '+document.title;
function add(){abrir_ventana('../rhplanilla/licencia_config.jsp?mode=add');}
function edit(k)
{
var codigo =  eval('document.form0.codigo'+k).value;
var empId  = eval('document.form0.empId'+k).value;
abrir_ventana1('../rhplanilla/licencia_config.jsp?mode=edit&empId='+empId+'&codigo='+codigo);}
function view(k)
{
var codigo =  eval('document.form0.codigo'+k).value;
var empId  = eval('document.form0.empId'+k).value;
abrir_ventana1('../rhplanilla/licencia_config.jsp?mode=view&empId='+empId+'&codigo='+codigo);
}
function  printList(){abrir_ventana('../rhplanilla/print_list_licencias.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
function distribuir(k,mode)
{
var quincenaSal =  eval('document.form0.quincenaSal'+k).value;
var fechaDesde =  eval('document.form0.fechaDesde'+k).value;
var fechaHasta =  eval('document.form0.fechaHasta'+k).value;
var codigo =  eval('document.form0.codigo'+k).value;
var empId  = eval('document.form0.empId'+k).value;

abrir_ventana('../rhplanilla/distribuir_licencia.jsp?mode='+mode+'&empId='+empId+'&codigo='+codigo+'&quincenas='+quincenaSal+'&fechaDesde='+fechaDesde+'&fechaHasta='+fechaHasta);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - LICENCIAS / INCAPACIDADES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
        <td align="right" colspan="6"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Licencia ]</a></authtype></td>
    </tr>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td width="15%">&nbsp;Nombre del Empleado:</td>
			<td width="22%"><%=fb.textBox("nombre","",false,false,false,25,null,null,null)%></td>
			<td width="12%">&nbsp;C&eacute;dula:</td>
			<td width="13%"><%=fb.textBox("cedula","",false,false,false,15,null,null,null)%></td>
			<td width="13%">Cargo del Empleado:</td>
			<td width="25%"><%=fb.textBox("cargo","",false,false,false,25,null,null,null)%></td>
		</tr>
		<tr class="TextFilter">
			<td>&nbsp;Id Empleado</td>
			<td><%=fb.textBox("empId","",false,false,false,15,null,null,null)%></td>
			<td>&nbsp;Num Empleado</td>
			<td><%=fb.textBox("numEmpleado","",false,false,false,15,null,null,null)%></td>
			<td>&nbsp;Departamento:</td>
			<td><%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%><%=fb.submit("go","Ir")%></td>
		</tr>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
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
				<%=fb.hidden("cargo",cargo)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("descripcion",descripcion)%>
				
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("cargo",cargo)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<%=fb.hidden("descripcion",descripcion)%>
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
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");	%>
<%=fb.formStart()%>

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="expe">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;C&eacute;dula</td>
		<td width="8%">No. Empleado</td>
		<td width="8%">Id. Empleado</td>
		<td width="20%">&nbsp;Nombre</td>
		<td width="20%">Cargo</td>
		<td width="6%">&nbsp;Desde</td>
		<td width="6%">&nbsp;Hasta</td>
		<td width="2%">&nbsp;Tipo</td>
		<td width="5%">&nbsp;Estado</td>
		<td width="3%">&nbsp;</td>
		<td width="3%">&nbsp;</td>
		<td width="3%">&nbsp;</td>
	</tr>
     <%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				
				<%=fb.hidden("empId"+i,cdo.getColValue("empId"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("fechaDesde"+i,cdo.getColValue("fechaDesde"))%>
				<%=fb.hidden("fechaHasta"+i,cdo.getColValue("fechaHasta"))%>
				<%=fb.hidden("quincenaSal"+i,cdo.getColValue("quincenaSal"))%>
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("num_empleado")%></td>
					<td>&nbsp;<%=cdo.getColValue("empId")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td>&nbsp;<%=cdo.getColValue("cargo")%></td>
					<td>&nbsp;<%=cdo.getColValue("fechaDesde")%></td>
					<td>&nbsp;<%=cdo.getColValue("fechaHasta")%></td>
					<td>&nbsp;<%=cdo.getColValue("descTipo")%></td>
					<td>&nbsp;<%=cdo.getColValue("descEstado")%></td>
					<td align="center"><authtype type='1'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/search.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:view(<%=i%>)">
					</authtype></td>

					  <td align="center"><%if(cdo.getColValue("estado").trim().equals("P")){%><authtype type='4'>
					  <img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/notes.jpg" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:edit(<%=i%>)">
					 </authtype><%}%> </td>
					  <td align="center"><authtype type='6'>
					  <%if(!cdo.getColValue("estado").trim().equals("P")){%>
					  <img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/distribute.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:distribuir(<%=i%>,'view')">
					  <%}else{%>
					   <img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/distribute.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir')" onClick="javascript:distribuir(<%=i%>,'edit')">
					  <%}%>
					  </authtype> </td>
				</tr>
				
				<%
				}
				%>

</table>
<%=fb.formEnd()%>
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
				<%=fb.hidden("cargo",cargo)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("descripcion",descripcion)%>
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
					<%=fb.hidden("cargo",cargo)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<%=fb.hidden("descripcion",descripcion)%>
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
