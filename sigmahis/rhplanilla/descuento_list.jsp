
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
-- lista de descuentos
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
int rowCount = 0;
String sql = "";
String desc = request.getParameter("desc");
String porc = request.getParameter("porc");
String estado = request.getParameter("estado");
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
  String cedula="",name="",code="",noEmpleado="";
  String cuenta="";
  if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
  {
	appendFilter += " and upper(e.cedula1) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
    cedula = request.getParameter("cedula");
  }
  
  if (request.getParameter("cuenta") != null && !request.getParameter("cuenta").trim().equals(""))
  {
	appendFilter += " and upper(a.num_cuenta) like '%"+request.getParameter("cuenta").toUpperCase()+"%'";
    cuenta = request.getParameter("cuenta");
  }
  
  if(request.getParameter("name") != null && !request.getParameter("name").trim().equals(""))
  {
    appendFilter += " and upper(e.nombre_empleado) like '%"+request.getParameter("name").toUpperCase()+"%'";
    name = request.getParameter("name");
  }
  if(request.getParameter("code")!=null && !request.getParameter("code").trim().equals(""))
  {
  	appendFilter += " and upper(e.emp_id) like '%"+request.getParameter("code").toUpperCase()+"%'";
    code = request.getParameter("code");
  }
  if(request.getParameter("noEmpleado")!=null && !request.getParameter("noEmpleado").trim().equals(""))
  {
  	appendFilter += " and upper(e.num_empleado) like '%"+request.getParameter("noEmpleado").toUpperCase()+"%'";
    noEmpleado = request.getParameter("noEmpleado");
  }
  if(request.getParameter("estado")!=null && !request.getParameter("estado").trim().equals(""))
  {
	  	appendFilter += " and upper(a.estado) like '%"+request.getParameter("estado").toUpperCase()+"%'";
  }

  sql="select e.cedula1 as cedula, e.num_empleado,to_char(e.provincia,'09') as provincia, e.sigla, to_char(e.tomo,'0999') as tomo, to_char(e.asiento,'009999') as asiento, e.nombre_empleado as name, r.nombre as nombre_acreedor, e.emp_id empId,e.unidad_organi, u.descripcion as unidad, to_char(nvl(a.descuento_mensual,0),'999,999,990.00') mensual, e.salario_base salario, to_char(((nvl(a.descuento_mensual,0)) / decode(nvl(e.salario_base,e.rata_hora*e.horas_base),0,1,nvl(e.salario_base,e.rata_hora*e.horas_base)))*100,'990.00') porcentaje, a.estado, decode(a.estado,'D','DESCONTAR','N','NO DESCONTAR','P','PENDIENTE','E','ELIMINAR',a.estado) estadoDesc, a.num_descuento, a.num_cuenta cuenta, to_char(a.fecha_inicial,'dd/mm/yyyy') fecha  from vw_pla_empleado e, tbl_sec_unidad_ejec u, tbl_pla_descuento a, tbl_pla_acreedor r where r.cod_acreedor = a.cod_acreedor and r.compania=a.cod_compania and nvl(e.ubic_seccion,e.seccion) = u.codigo and e.emp_id=a.emp_id(+) and e.compania = a.cod_compania(+) and e.compania=u.compania and e.compania="+(String) session.getAttribute("_companyId")+appendFilter+"   order by e.nombre_empleado, a.num_descuento";

  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("select count(*) FROM ("+sql+")");

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

function add()
{
abrir_ventana('../rhplanilla/descuento_config.jsp?mode=add');
}

function edit(mode,empId,desc,porc)
{
abrir_ventana('../rhplanilla/descuento_config.jsp?mode='+mode+'&empId='+empId+'&id='+desc+'&porc='+porc);
}

function hist(mode,empId,desc,porc)
{
abrir_ventana('../rhplanilla/descuento_historial.jsp?mode='+mode+'&empId='+empId+'&id='+desc);
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
		<td colspan="4" align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Descuento ]</a></authtype></td>
	</tr>

	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

	<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
	<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
	
	
		  <tr class="TextFilter">
			<td width="15%">&nbsp;Emp. ID
				<%=fb.textBox("code","",false,false,false,8,null,null,null)%>
			</td>
			<td width="15%">&nbsp;C&eacute;dula&nbsp;
				<%=fb.textBox("cedula","",false,false,false,15,null,null,null)%>
			</td>
			<td width="45%">&nbsp;Nombre
				<%=fb.textBox("name","",false,false,false,20,null,null,null)%>
				Num. Empleado<%=fb.textBox("noEmpleado","",false,false,false,8,null,null,null)%>
			</td>
			<td width="25%">&nbsp;Estado
				<%=fb.select("estado","D=Descontar,N=No Decsontar,P=Pendiente,E=Eliminar",estado,"T")%>
				<%=fb.submit("go","Ir")%>
			</td>
		  </tr>	
	      <tr class="TextFilter">
		    <td colspan="4">&nbsp;No. Cuenta
			<%=fb.textBox("cuenta","",false,false,false,20,null,null,null)%> 
			</td>			
		  </tr>
	  
		
	<%=fb.formEnd()%>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><authtype type='0'>	<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("noEmpleado",noEmpleado)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cuenta",cuenta)%>
				

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
					<%=fb.hidden("code",code)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("name",name)%>
					<%=fb.hidden("noEmpleado",noEmpleado)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cuenta",cuenta)%>
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
	    <td width="%">&nbsp;</td>
		<td width="30%">&nbsp;Nombre del Acreedor</td>
		<td width="10%">&nbsp;No. Descuento
		<td width="10%">&nbsp;Fecha Inicio</td>
		<td width="10%">&nbsp;Estado</td>
		<td width="12%">&nbsp;Descto Mensual</td>
		<td width="10%">&nbsp;Porcentaje Desc.</td>
		<td width="6%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
	</tr>
<%	
String descEmpleado = "";
for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		String color = "TextRow02";
		if (i % 2 == 0) color = "TextRow01";
		
		 if (!descEmpleado.equalsIgnoreCase(cdo.getColValue("name")))
			 {
				%>
				   <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
 	          <td colspan="9" class="TextHeader01"> <%=cdo.getColValue("name")%> (<%=cdo.getColValue("empId")%>)    [ Cedula: &nbsp;<%=cdo.getColValue("cedula")%>, #Emp.:&nbsp;<%=cdo.getColValue("num_empleado")%> ]    -    <%=cdo.getColValue("unidad")%> </td>
           </tr>
		  <%} %>
		<%=fb.hidden("emp_id"+i,cdo.getColValue("empId"))%>
		<%=fb.hidden("num_descuento"+i,cdo.getColValue("num_descuento"))%>
		
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("nombre_acreedor")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("num_descuento")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha")%></td>
					<td>&nbsp;<%=cdo.getColValue("estadoDesc")%></td>
					<td align="right">&nbsp;<%=cdo.getColValue("mensual")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("porcentaje")%> % </td>
					<td align="right"><authtype type='1'><a href="javascript:edit('view',<%=cdo.getColValue("empId")%>,'<%=cdo.getColValue("num_descuento")%>','<%=cdo.getColValue("porcentaje")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">ver</a> </authtype></td>
					<td align="center">
						<authtype type='4'><a href="javascript:edit('edit',<%=cdo.getColValue("empId")%>,'<%=cdo.getColValue("num_descuento")%>','<%=cdo.getColValue("porcentaje")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a> </authtype>
					</td>
				</tr>
				
				<%
				descEmpleado = cdo.getColValue("name");
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
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("noEmpleado",noEmpleado)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("cuenta",cuenta)%>
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
					<%=fb.hidden("code",code)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("name",name)%>
					<%=fb.hidden("noEmpleado",noEmpleado)%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("cuenta",cuenta)%>
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
