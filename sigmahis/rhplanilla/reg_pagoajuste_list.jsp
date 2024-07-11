
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
String fg = request.getParameter("fg");
String estado = request.getParameter("estado");
if (estado == null )estado="";
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
	String anio="",codPlanilla="",noPlanilla="",cedula="",nombre="",empId="",noEmpleado="",anioAj="",codPlanillaAj="",noPlanillaAj="";
   if (request.getParameter("cedula") != null && !request.getParameter("cedula").trim().equals(""))
   {
    appendFilter += " and upper(nvl(b.pasaporte,b.cedula1)) like '%"+request.getParameter("cedula").toUpperCase()+"%'";
	cedula=request.getParameter("cedula");
   }
   if (request.getParameter("nombre") != null && !request.getParameter("cedula").trim().equals(""))
   {
    appendFilter += " and upper(b.nombre_empleado) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
	nombre=request.getParameter("nombre");
   }
   if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
   {
    appendFilter += " and a.anio ="+request.getParameter("anio");
	anio=request.getParameter("anio");
   }
   if (request.getParameter("codPlanilla") != null && !request.getParameter("codPlanilla").trim().equals(""))
   {
    appendFilter += " and a.cod_planilla="+request.getParameter("codPlanilla");
	codPlanilla=request.getParameter("codPlanilla");
   }
   if (request.getParameter("noPlanilla") != null && !request.getParameter("noPlanilla").trim().equals(""))
   {
    appendFilter += " and a.num_planilla ="+request.getParameter("noPlanilla");
	noPlanilla=request.getParameter("noPlanilla");
   }
   if (request.getParameter("noEmpleado") != null && !request.getParameter("noEmpleado").trim().equals(""))
   {
    appendFilter += " and upper(a.num_empleado) like '%"+request.getParameter("noEmpleado").toUpperCase()+"%'";
	noEmpleado=request.getParameter("noEmpleado");
   }
   if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
   {
    appendFilter += " and upper(a.emp_id) like '%"+request.getParameter("empId").toUpperCase()+"%'";
	empId=request.getParameter("empId");
   }
   if (request.getParameter("anioAj") != null && !request.getParameter("anioAj").trim().equals(""))
   {
    appendFilter += " and a.anio_pla_aj ="+request.getParameter("anioAj");
	anioAj=request.getParameter("anioAj");
   }
   if (request.getParameter("codPlanillaAj") != null && !request.getParameter("codPlanillaAj").trim().equals(""))
   {
    appendFilter += " and a.cod_pla_aj="+request.getParameter("codPlanillaAj");
	codPlanillaAj=request.getParameter("codPlanillaAj");
   }
   if (request.getParameter("noPlanillaAj") != null && !request.getParameter("noPlanillaAj").trim().equals(""))
   {
    appendFilter += " and a.num_pla_aj ="+request.getParameter("noPlanillaAj");
	noPlanillaAj=request.getParameter("noPlanillaAj");
   }
 
	sql="select all nvl(b.pasaporte,b.cedula1) as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.nombre_empleado as nombre ,b.ubic_seccion as seccion, f.descripcion as descripcion, b.emp_id as empId, b.estado, c.denominacion, g.descripcion as estadodesc, b.num_empleado as numEmpleado, nvl(a.rata_hora,b.rata_hora) as rata, b.ubic_seccion as grupo, a.emp_id as filtro,a.secuencia,a.num_planilla,a.cod_planilla,a.anio,decode(a.estado,'PE','PENDIENTE','AC','ACTUALIZADO','AP','APROBADO') descEstado from vw_pla_empleado b, tbl_sec_unidad_ejec f, tbl_pla_cargo c, tbl_pla_estado_emp g, tbl_pla_pago_ajuste a where b.compania = f.compania and b.ubic_seccion = f.codigo and b.compania = c.compania and b.cargo = c.codigo and b.estado = g.codigo and b.emp_id = a.emp_id and b.compania=a.cod_compania and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" and a.estado <> 'PE' order by a.anio desc ,a.cod_planilla,a.num_planilla desc,a.secuencia, b.nombre_empleado";
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

function add(prov, sig, tom, asi, empId, numEmp, rath, grupo)
{
abrir_ventana('../rhplanilla/reg_pagoajuste_config.jsp?mode=add&prov='+prov+'&sig='+sig+'&tom='+tom+'&asi='+asi+'&grp='+grupo+'&num='+numEmp+'&rath='+rath+"&emp_id="+empId);
}

function  printList()
{
  abrir_ventana('../rhplanilla/print_list_pagoajuste.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function view(empId,secuencia,anio,codPlanilla,noPlanilla){abrir_ventana('../rhplanilla/reg_pagoajuste_config.jsp?mode=view&emp_id='+empId+'&secuencia='+secuencia+'&anio='+anio+'&codPlanilla='+codPlanilla+'&noPlanilla='+noPlanilla+'&fg=CS');}
function printTal(cod,anio,num)
{
  abrir_ventana1('../rhplanilla/print_list_comp_pago_emp.jsp?fp=CS&fg=<%=fg%>&codAj='+cod+'&anioAj='+anio+'&numAj='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function printChk(cod,anio,num)
{
var referencia = cod+'-'+num+'-'+anio;
abrir_ventana1('../cxp/print_cheque.jsp?fp=cheque&referencia='+referencia+'&fg=solo'); 
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
	<tr><td align="right" colspan="8"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Ajustes a Planilla ]</a></authtype></td></tr>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>	
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("noPlanillaAj",noPlanillaAj)%>
			<%=fb.hidden("codPlanillaAj",codPlanillaAj)%>
			<%=fb.hidden("anioAj",anioAj)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("estado",estado)%>
		<tr class="TextFilter">
			<td>Año</td>
			<td><%=fb.intBox("anio","",false,false,false,10,null,null,null)%></td>
			<td>Cod. Planilla</td>
			<td><%=fb.intBox("codPlanilla","",false,false,false,10,null,null,null)%></td>
			<td>No. Planilla</td>
			<td colspan="3"><%=fb.intBox("noPlanilla","",false,false,false,10,null,null,null)%></td>
 		 </tr>
	
  <tr class="TextFilter">
			<td width="10%">Cédula</td>
			<td width="15%"><%=fb.textBox("cedula","",false,false,false,15,null,null,null)%></td>
			<td width="15%">Nombre del Empleado </td>   
			<td width="15%"><%=fb.textBox("nombre","",false,false,false,20,null,null,null)%></td>
    		<td width="10%">ID Empleado</td>
			<td width="15%"><%=fb.textBox("empId","",false,false,false,10,null,null,null)%></td>
			<td width="10%">No. de Empleado</td>
			<td width="15%"><%=fb.textBox("noEmpleado","",false,false,false,10,null,null,null)%>
					<%=fb.submit("go","Ir")%></td>	
      </td>
	  </tr>
		<%=fb.formEnd()%>  
  
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
		
	<tr>
		<td align="right"><%if(!codPlanillaAj.trim().equals("")&&!anioAj.trim().equals("")&&!noPlanillaAj.trim().equals("")){%><%=fb.button("talonarios","Talonarios",true,false,null,null,"onClick=\"javascript:printTal("+codPlanillaAj+","+anioAj+","+noPlanillaAj+");\"")%><%}%><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
		<%=fb.button("cheques","Cheques",true,((estado.trim().equals("B"))?true:false),null,null,"onClick=\"javascript:printChk("+codPlanillaAj+","+anioAj+","+noPlanillaAj+");\"")%>
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
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("noPlanilla",noPlanilla)%>
				<%=fb.hidden("codPlanilla",codPlanilla)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("noEmpleado",noEmpleado)%>
				<%=fb.hidden("noPlanillaAj",noPlanillaAj)%>
				<%=fb.hidden("codPlanillaAj",codPlanillaAj)%>
				<%=fb.hidden("anioAj",anioAj)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("estado",estado)%>
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
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("noPlanilla",noPlanilla)%>
					<%=fb.hidden("codPlanilla",codPlanilla)%>
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("noEmpleado",noEmpleado)%>
					<%=fb.hidden("noPlanillaAj",noPlanillaAj)%>
					<%=fb.hidden("codPlanillaAj",codPlanillaAj)%>
					<%=fb.hidden("anioAj",anioAj)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("estado",estado)%>
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
		<td width="10%">&nbsp;C&eacute;dula/Pas. </td>
		<td width="20%">&nbsp;Nombre</td>
		<td width="10%">&nbsp;Num. Empleado</td>
		<td width="5%">Año</td>
		<td width="5%">Cod. Planilla</td>
		<td width="10%">No. Planilla</td>
		<td width="10%">Estado</td>
		<td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
	</tr>
                <%
				
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				
				  %>
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td>&nbsp;<%=cdo.getColValue("cedula")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("numEmpleado")%></td>
					<td align="center"><%=cdo.getColValue("anio")%></td>
					<td align="center"><%=cdo.getColValue("cod_planilla")%></td>
					<td align="center"><%=cdo.getColValue("num_planilla")%></td>
					<td align="center"><%=cdo.getColValue("descEstado")%></td>
					<td align="center">
						 <img src="../images/dwn.gif" onClick="javascript:showPopWin('../rhplanilla/reg_pago_ajuste_list.jsp?empId=<%=cdo.getColValue("empId")%>&secuencia=<%=cdo.getColValue("secuencia")%>&num_planilla=<%=cdo.getColValue("num_planilla")%>&cod_planilla=<%=cdo.getColValue("cod_planilla")%>&anio=<%=cdo.getColValue("anio")%>&id=<%=i%>',winWidth*.95,_contentHeight*.75,null,null,'')" style="cursor:pointer">
						 
						  </td>
				
		   <td align="center">
				<authtype type='1'>	<a href="javascript:view(<%=cdo.getColValue("empId")%>,<%=cdo.getColValue("secuencia")%>,<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("cod_planilla")%>,<%=cdo.getColValue("num_planilla")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">ver</a> </authtype>
					</td>
					
				</tr>
<%}%>							
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
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("cedula",cedula)%>
				<%=fb.hidden("noPlanilla",noPlanilla)%>
				<%=fb.hidden("codPlanilla",codPlanilla)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("noEmpleado",noEmpleado)%>
				<%=fb.hidden("noPlanillaAj",noPlanillaAj)%>
				<%=fb.hidden("codPlanillaAj",codPlanillaAj)%>
				<%=fb.hidden("anioAj",anioAj)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("estado",estado)%>
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
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("cedula",cedula)%>
					<%=fb.hidden("noPlanilla",noPlanilla)%>
					<%=fb.hidden("codPlanilla",codPlanilla)%>
					<%=fb.hidden("anio",anio)%>
					<%=fb.hidden("noEmpleado",noEmpleado)%>
					<%=fb.hidden("noPlanillaAj",noPlanillaAj)%>
					<%=fb.hidden("codPlanillaAj",codPlanillaAj)%>
					<%=fb.hidden("anioAj",anioAj)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("estado",estado)%>
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
	