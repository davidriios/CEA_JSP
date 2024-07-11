
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
int iconHeight = 15;
int iconWidth = 15;

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
  String cedula="",noEmpleado="",empId="",nombre="";
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
  {
    appendFilter += " and upper(p.cedula1) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    cedula = request.getParameter("cedula");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(p.nombre_empleado) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");
  }
  if (request.getParameter("noEmpleado") != null && !request.getParameter("noEmpleado").trim().equals(""))
  {
    appendFilter += " and upper(a.num_empleado) like '%"+request.getParameter("noEmpleado").toUpperCase()+"%'";
    noEmpleado = request.getParameter("noEmpleado");
  }
  if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
  {
    appendFilter += " and a.emp_id like '%"+request.getParameter("empId").toUpperCase()+"%'";
    empId = request.getParameter("empId");
  }
	sql=" select * from (select distinct to_char(a.fecha_inicio,'dd/mm/yyyy')fecha_inicio,a.emp_id,nvl(b.cod_planilla,0)cod_planilla, nvl(b.numPlanilla ,0)num_planilla,nvl(b.anio,0)anio,a.num_empleado, p.cedula1 cedula, p.unidad_organi, (select descripcion from tbl_sec_unidad_ejec where codigo =p.unidad_organi )descUnidad, p.nombre_empleado nombre,nvl(( select nvl(count(num_planilla),0) v_existe from tbl_pla_planilla_encabezado where cod_compania =b.compania and anio = b.anio  and cod_planilla = b.cod_planilla and num_planilla = b.numPlanilla),0)existe,(select descripcion from tbl_pla_estado_emp where codigo =p.estado) estadoEmp,b.motivo from  tbl_pla_li_pagos a,(select distinct l.compania,l.emp_id,l.anio_pago as anio, l.periodo_pago as numPlanilla, pl.cod_planilla, pl.num_empleado,l.fecha_egreso,l.motivo from tbl_pla_li_liquidacion l,tbl_pla_pago_liquidacion pl where l.compania ="+(String) session.getAttribute("_companyId")+" and pl.cod_compania = l.compania and pl.emp_id  = l.emp_id)b,vw_pla_empleado p  where a.cod_compania =b.compania(+) and a.emp_id = b.emp_id(+) and a.fecha_inicio = b.fecha_egreso(+) and p.emp_id = a.emp_id "+appendFilter+" )  order by emp_id asc";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Recursos Humanos - Liquidacion - '+document.title;
function eliminarLiq(empId,anio,fecha,codPlanilla,noPlanilla,noEmpleado){showPopWin('../common/run_process.jsp?fp=DELLIQ&actType=50&docType=DELLIQ&docId='+anio+'&docNo='+anio+'&compania=<%=(String) session.getAttribute("_companyId")%>&anio='+anio+'&fecha='+fecha+'&empId='+empId+'&codPlanilla='+codPlanilla+'&numPlanilla='+noPlanilla+'&noEmpleado='+noEmpleado,winWidth*.75,winHeight*.65,null,null,'');}
function edit(empId,fechaEgreso,motivo,mode){abrir_ventana('../rhplanilla/reg_liquidacion.jsp?mode='+mode+'&emp_id='+empId+'&liq_fecha_egreso='+fechaEgreso+'&fecha_egreso='+fechaEgreso+'&motivo='+motivo);}
function add(){abrir_ventana('../rhplanilla/reg_liquidacion.jsp?mode=add');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS - MANTENIMIENTO - BECARIOS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar liquidaci&oacute;n ]</a></authtype></td>
	</tr>

	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="20%">&nbsp;No. Empleado
					<%=fb.textBox("noEmpleado","",false,false,false,10,null,null,null)%></td>
		<td width="20%">&nbsp;ID
		<%=fb.textBox("empId","",false,false,false,10,null,null,null)%>
		</td>
		<td width="20%">&nbsp;Cédula&nbsp;
					<%=fb.textBox("cedula","",false,false,false,20,null,null,null)%>
		</td>
		<td width="40%">&nbsp;Nombre
					<%=fb.textBox("nombre","",false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>	</td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><!--<authtype type='0'>	<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>--></td>
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
				<%=fb.hidden("nombre",""+nombre)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("empId",""+empId)%>
				<%=fb.hidden("noEmpleado",""+noEmpleado)%>
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
					<%=fb.hidden("nombre",""+nombre)%>
					<%=fb.hidden("cedula",""+cedula)%>
					<%=fb.hidden("empId",""+empId)%>
					<%=fb.hidden("noEmpleado",""+noEmpleado)%>
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
<tbody id="list">
	<tr class="TextHeader" align="center">
    	<td width="7%">No.Emp.</td>
		<td width="10%">C&eacute;dula</td>
		<td width="25%">Nombre</td>
		<td width="10%">Estado</td>
		<td width="10%">Fecha Egreso</td>
		<td width="8%">Unidad</td>
		<td width="15%">Descripci&oacute;n</td>
		<td width="5%">Ver</td>
		<td width="5%">Editar</td>
		<td width="5%">Eliminar</td>
	</tr>
<%
				String descripcion = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 %>
				
<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">

					<td>&nbsp;<%=cdo.getColValue("num_empleado")%></td>
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td>&nbsp;<%=cdo.getColValue("estadoEmp")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_inicio")%></td>
					<td>&nbsp;<%=cdo.getColValue("unidad_organi")%></td>
					<td>&nbsp;<%=cdo.getColValue("descUnidad")%></td>
					<td align="center">
					<%if(!cdo.getColValue("num_planilla").trim().equals("0")){%>
					<authtype type='1'>
					<img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/search.gif" onClick="javascript:showPopWin('../rhplanilla/pago_planilla_liquidacion.jsp?empId=<%=cdo.getColValue("emp_id")%>&cod=<%=cdo.getColValue("cod_planilla")%>&num=<%=cdo.getColValue("num_planilla")%>&anio=<%=cdo.getColValue("anio")%>&id=<%=i%>',winWidth*.95,_contentHeight*.85,null,null,'')" style="cursor:pointer"></authtype><%}%>
					</td>
					<td align="center">
					<authtype type='4'><%if(cdo.getColValue("existe").trim().equals("0") ){%><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/notes.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Anular Factura')" onClick="javascript:edit(<%=cdo.getColValue("emp_id")%>,'<%=cdo.getColValue("fecha_inicio")%>','<%=cdo.getColValue("motivo")%>','edit')"><%}%>	 </authtype>
					</td>
					<td align="center">
					<%if(cdo.getColValue("existe").trim().equals("0")){%><authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/cancel.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Anular Factura')" onClick="javascript:eliminarLiq(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("anio")%>,'<%=cdo.getColValue("fecha_inicio")%>','<%=cdo.getColValue("cod_planilla")%>','<%=cdo.getColValue("num_planilla")%>','<%=cdo.getColValue("num_empleado")%>')">	 </authtype><%}%>					
					</td>
					
					
						

				</tr>
				<%
				}
			  %>
</tbody>
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
				<%=fb.hidden("nombre",""+nombre)%>
				<%=fb.hidden("cedula",""+cedula)%>
				<%=fb.hidden("empId",""+empId)%>
				<%=fb.hidden("noEmpleado",""+noEmpleado)%>
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
					<%=fb.hidden("nombre",""+nombre)%>
					<%=fb.hidden("cedula",""+cedula)%>
					<%=fb.hidden("empId",""+empId)%>
					<%=fb.hidden("noEmpleado",""+noEmpleado)%>
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
	