
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
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
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
  String cedula ="",nombre="",noEmpleado="",empId="";
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
  {
    appendFilter += " and upper(a.cedula1) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    cedula = request.getParameter("cedula");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(b.nombre_empleado) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");
  }
  if (request.getParameter("noEmpleado") != null && !request.getParameter("noEmpleado").trim().equals(""))
  {
    appendFilter += " and upper(b.num_empleado) like '%"+request.getParameter("noEmpleado").toUpperCase()+"%'";
    noEmpleado = request.getParameter("noEmpleado");
  }
  if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
  {
	appendFilter += " and b.emp_id  like '%"+request.getParameter("empId")+"%'";
	empId  = request.getParameter("empId");  
  }
	
	sql="select a.emp_id, a.num_empleado, decode(a.provincia, 0, ' ', 00, '', 10, '0', 11, 'B', 12, 'C', a.provincia)||rpad(decode(a.sigla,'00', '  ', '0', '  ', a.sigla), 2, ' ')||'-'||lpad(to_char(a.tomo), 3, '0')||'-'||lpad(to_char(a.asiento), 5, '0') cedula, c.descripcion estadoEmp, a.dias_tiempo, a.dias_dinero, to_char(a.periodof_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(a.periodof_final, 'dd/mm/yyyy') fecha_fin, decode(a.tipo, 'TI', 'TIEMPO', 'DI', 'DINERO', 'TD', 'TIEMPO Y DINERO') tipo_desc, a.tipo, b.primer_nombre||' '||decode(b.sexo, 'F', decode(b.apellido_casada, null, b.primer_apellido, decode(b.usar_apellido_casada, 'S', 'DE '||b.apellido_casada, b.primer_apellido)), b.primer_apellido) nombre, a.codigo, a.anio,a.anio_pago,a.periodo_pago,nvl(a.estado,'')estado,nvl((select count(*) from tbl_pla_dist_dias_vac where cod_compania = a.compania and emp_id = a.emp_id and anio_pago = anio_pago and quincena_pago = periodo_pago and status  <> 'AN' ),0)distribucion from tbl_pla_sol_vacacion a, vw_pla_empleado b, tbl_pla_estado_emp c/*, tbl_pla_vacacion d*/ where a.estado in('AP','AC') and a.enviar_planilla_estado = 'S' and a.compania = "+(String) session.getAttribute("_companyId")+ " and a.compania = b.compania and a.emp_id = b.emp_id and b.estado = c.codigo /*and a.emp_id = d.emp_id and a.anio = d.anio and d.estado = 4*/ " + appendFilter;
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+") "); 

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
document.title = 'Recursos Humanos - Becarios - '+document.title;
function add(){abrir_ventana('../rhplanilla/reg_vacaciones.jsp?mode=add');}
function registrar(emp_id){	var accion = '';accion = 'RV';abrir_ventana('../rhplanilla/reg_vacaciones.jsp?empId='+emp_id+'&accion='+accion);}
function ver(emp_id,codigo,anio){abrir_ventana('../rhplanilla/reg_vacaciones.jsp?empId='+emp_id+'&accion=RV&mode=view&codigo='+codigo+'&anioSol='+anio);}
function reloadPage(){window.location='../rhplanilla/list_vacaciones.jsp';}
function verificar(emp_id, fecha_inicio){var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_dist_dias_vac','emp_id = '+ emp_id +' and to_date(to_char(fecha_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha_inicio+'\', \'dd/mm/yyyy\') and cod_compania = <%=(String) session.getAttribute("_companyId")%> and anio_pago is null and quincena_pago is null and status =\'PR\'','');if(x=='')return true;else {alert('La distribución de esta solicitud ya fue realizada, por favor eliminarla desde la pantalla correspondiente!');return false;}}
function verifica(emp_id, fecha_inicio, tipo)
{if(tipo == 'TI'){var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_dist_dias_vac','emp_id = '+ emp_id +' and to_date(to_char(fecha_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fecha_inicio+'\', \'dd/mm/yyyy\')  and status =\'PR\' and cod_compania = <%=(String) session.getAttribute("_companyId")%>','');if(x!='') return true;else {alert('Esta solicitud no ha sido procesada/distribuída aún!');return false;}}else {alert('Esta opción sólo está disponible para las solicitudes en TIEMPO!');return false;}}
function aprobarDistribucion(empId,anio,periodo){showPopWin('../common/run_process.jsp?fp=SOLVAC&actType=51&docType=SOLVAC&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&periodo='+periodo+'&empId='+empId,winWidth*.75,winHeight*.65,null,null,'');}
function accionesVac(empId,anio,codigo,fg,actType,periodoPago){showPopWin('../common/run_process.jsp?fp=SOLVAC&actType='+actType+'&docType=SOLVAC&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&codigo='+codigo+'&empId='+empId+'&fg='+fg+'&periodo='+periodoPago,winWidth*.75,winHeight*.65,null,null,'');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - VACACIONES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right"></td>
	</tr>

	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="60%">Emp. Id: &nbsp;<%=fb.intBox("empId","",false,false,false,10)%>
					No Empleado: &nbsp;<%=fb.textBox("noEmpleado","",false,false,false,10)%>  	
		
		&nbsp;Cédula&nbsp;	<%=fb.textBox("cedula","",false,false,false,30,null,null,null)%></td>
		
		<td width="40%">&nbsp;Nombre<%=fb.textBox("nombre","",false,false,false,30,null,null,null)%><%=fb.submit("go","Ir")%>	</td>
		<%=fb.formEnd(true)%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"></td>
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
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("noEmpleado",noEmpleado)%>
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
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("noEmpleado",noEmpleado)%>
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
    <td width="4%">Num. Empl.</td>
		<td width="8%">C&eacute;dula</td>
		<td width="21%">Nombre</td>
		<td width="8%">Estado</td>
		<td width="3%">TI</td>
		<td width="3%">DI</td>
		<td width="7%">Fecha Inicio</td>
		<td width="7%">Fecha Final</td>
		<td width="8%">Forma</td>
		<td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
	</tr>
				<%
				String descripcion = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 %>
				 <%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("num_empleado")%></td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estadoEmp")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("dias_tiempo")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("dias_dinero")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_inicio")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_fin")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("tipo_desc")%></td>
					<td align="center"><%if(cdo.getColValue("estado")!= null && cdo.getColValue("estado").trim().equals("AP")){
					if((cdo.getColValue("distribucion")== null || cdo.getColValue("distribucion").trim().equals("0"))){%>
          <authtype type='3'>	<a href="javascript:registrar('<%=cdo.getColValue("emp_id")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Registrar</a></authtype><%}else{%> <authtype type='4'><a href="javascript:registrar('<%=cdo.getColValue("emp_id")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype><%}}else{%><authtype type='1'>	<a href="javascript:ver('<%=cdo.getColValue("emp_id")%>',<%=cdo.getColValue("codigo")%>,<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype> <!----><%}%></td>					
          <td align="center"><%if(cdo.getColValue("estado")!= null && cdo.getColValue("estado").trim().equals("AP")){%>
          <authtype type='5'><a href="javascript:if(verificar('<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("fecha_inicio")%>'))accionesVac('<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("codigo")%>','RE','5','<%=cdo.getColValue("periodo_pago")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Rechazar</a></authtype><%}%></td>
          <td align="center"><%if(cdo.getColValue("estado")!= null && (cdo.getColValue("estado").trim().equals("AP"))){%>
          <authtype type='7'><a href="javascript:accionesVac('<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("codigo")%>','AN','7','<%=cdo.getColValue("periodo_pago")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">anular</a></authtype><%}%></td>
		  <td align="center">
		  <% if((cdo.getColValue("estado")!= null && cdo.getColValue("estado").trim().equals("AC"))||(cdo.getColValue("distribucion")!= null && !cdo.getColValue("distribucion").trim().equals("0"))){%>
		  <authtype type='52'><a href="javascript:accionesVac(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("anio_pago")%>,<%=cdo.getColValue("codigo")%>,'AND',52,<%=cdo.getColValue("periodo_pago")%>)">Anular Dist.</a></authtype><%}%></td>
          <td align="center"><%if(cdo.getColValue("estado")!= null && cdo.getColValue("estado").trim().equals("AP") && cdo.getColValue("tipo").trim().equals("TI")){%>
          <authtype type='50'><a href="javascript:if(verifica(<%=cdo.getColValue("emp_id")%>, '<%=cdo.getColValue("fecha_inicio")%>', '<%=cdo.getColValue("tipo")%>'))accionesVac(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("codigo")%>,'PR',50,'')" style="cursor:pointer">Procesar</a></authtype><%}%></td>
		  <td align="center">
		  
		  <%if(cdo.getColValue("anio_pago") != null && !cdo.getColValue("anio_pago").trim().equals("") && (cdo.getColValue("estado")!= null && cdo.getColValue("estado").trim().equals("AP"))&&(cdo.getColValue("distribucion")!= null && !cdo.getColValue("distribucion").trim().equals("0")) ){%><authtype type='51'>	<a href="javascript:aprobarDistribucion('<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("anio_pago")%>','<%=cdo.getColValue("periodo_pago")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Aprobar Dist.</a></authtype><%}%></td>
				</tr>
				<%}%>

</table>

<!-- =================   R E S U L T S   E N D   H E R E   ====================== -->

	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("noEmpleado",noEmpleado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("noEmpleado",noEmpleado)%>
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
	