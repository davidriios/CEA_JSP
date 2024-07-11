
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
ArrayList newal = new ArrayList();
int rowCount = 0;
String sql = "";
String newsql = "";
String appendFilter = "";
String appendFilter2 = "";

String id = request.getParameter("id");
String fecha = request.getParameter("fecha");
String mes = request.getParameter("mes");
String anio = request.getParameter("anio");
String fp = request.getParameter("fp");

if(request.getParameter("fp") == null)
	{
	appendFilter2 = " and a.tipo_aumento = 1 and to_date(to_char(a.fecha_aumento,'dd/mm/yyyy'),'dd/mm/yyyy') = '"+fecha+"' ";
  }
	if(fp.equalsIgnoreCase("sobresueldo"))
	{
	appendFilter2 = " and a.tipo_aumento = 5 and to_date(to_char(a.fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = '"+fecha+"' ";
	}
  if(fp.equalsIgnoreCase("actualiza"))
	{
	appendFilter2 = " and a.tipo_aumento = 5 and (a.actualizado = 'N' or a.actualizado is null) and a.anio = '"+anio+"' and ((a.mes = '"+mes+"' and to_date(to_char(a.fecha_aumento,'dd/mm/yyyy'),'dd/mm/yyyy') <= '"+fecha+"') or (a.mes < '"+mes+"' and to_date(to_char(a.fecha_aumento,'dd/mm/yyyy'),'dd/mm/yyyy') <= '"+fecha+"')) ";
	}


if (request.getMethod().equalsIgnoreCase("GET"))
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
	
	
	String num_empleado = "";        // variables para mantener el valor de los campos filtrados en la consulta
	String nombre = "";
	String cargo  = "";
   
	if (request.getParameter("num_empleado") != null)
	{
	appendFilter += " and e.num_empleado like '%"+request.getParameter("num_empleado").toUpperCase()+"%' ";
    searchOn = "e.num_empleado";
    searchVal = request.getParameter("num_empleado");
    searchType = "1";
    searchDisp = "Empleado";
		num_empleado     = request.getParameter("num_empleado");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	else if (request.getParameter("nombre") != null)
	{
	appendFilter += " and upper(e.primer_nombre||' '||e.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    searchOn = "(e.primer_nombre||' '||e.primer_apellido)";
    searchVal = request.getParameter("nombre");
    searchType = "1";
    searchDisp = "Nombre";
		nombre    = request.getParameter("nombre");  // utilizada para mantener la descripción del Tipo de Empleado
	}
	else if (request.getParameter("cargo") != null)
	{
	appendFilter += " and upper(c.denominacion) like '%"+request.getParameter("cargo").toUpperCase()+"%'";
    searchOn = "c.denominacion";
    searchVal = request.getParameter("cargo");
    searchType = "1";
    searchDisp = "Cargo";
	cargo  = request.getParameter("cargo");   // utilizada para mantener la cantidad de Horas Extras Permitidas
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
    else if (searchType.equals("2"))
    {
			appendFilter += " and "+searchOn+"="+searchVal;
    }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	
	
	
	
 /*and d.emp_id = e.emp_id */
	sql = "select to_char(a.fecha_aumento,'dd/mm/yyyy') fecha,to_char(a.fecha_anterior,'dd/mm/yyyy') fechaAnt, to_char(a.sueldo_anterior,'99,999,990.00') sueldo_anterior,  to_char(a.aumento,'99,990.00') aumento, a.comentarios, to_char(a.rata_x_hora,'99,990.00') rata_x_hora, e.provincia,e.sigla,e.tomo,e.asiento, e.primer_nombre||' '||e.primer_apellido as nomEmpleado, e.num_empleado, c.denominacion cargoDesc, a.anio||' - '||a.mes pago, e.provincia||'-'||e.sigla||'-'||e.tomo||'-'||e.asiento as cedula, e.rata_hora rataEmp,  to_char(a.fecha,'dd/mm/yyyy') fechaN, to_char(e.fecha_ingreso,'dd/mm/yyyy') fechaIngreso, f.descripcion aumDesc, a.tipo_aumento, to_char(nvl(a.sueldo_anterior,0) + nvl(a.aumento,0),'99,999,990.00') nuevoSalario,to_char((nvl(a.sueldo_anterior,0) + nvl(a.aumento,0)) / nvl(a.rata_x_hora,1),'99,999,990.00') nuevaRata, to_char(sysdate,'dd/mm/yyyy') fechaHoy from tbl_pla_aumento_cc a, tbl_pla_cargo c, tbl_pla_empleado e, tbl_pla_tipo_aumento f where a.compania = e.compania and  a.emp_id = e.emp_id and  e.cargo = c.codigo and  e.compania = c.compania and  a.tipo_aumento	= f.codigo and  a.compania = f.compania and   a.actualizado = 'N' and a.compania= "+(String) session.getAttribute("_companyId")+ appendFilter +  appendFilter2+ " order by e.num_empleado";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_pla_aumento_cc a, tbl_pla_cargo c, tbl_pla_empleado e, tbl_pla_tipo_aumento f where a.compania = e.compania and  a.emp_id 			= e.emp_id and  e.cargo = c.codigo and  e.compania = c.compania and  a.tipo_aumento	= f.codigo and  a.compania = f.compania and a.compania= "+(String) session.getAttribute("_companyId")+ appendFilter+ appendFilter2+ " and a.actualizado = 'N' ");
	
	
	newsql = "Select to_char(sum(a.aumento),'999,999,990.00') as totAum from tbl_pla_aumento_cc a, tbl_pla_cargo c, tbl_pla_empleado e, tbl_pla_tipo_aumento f where a.compania = e.compania and  a.emp_id 			= e.emp_id and  e.cargo = c.codigo and  e.compania = c.compania and  a.tipo_aumento	= f.codigo and  a.compania = f.compania and a.compania= "+(String) session.getAttribute("_companyId")+ appendFilter + appendFilter2+ " and a.actualizado = 'N' ";
	
   newal = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+newsql+") a) where rn between "+previousVal+" and "+nextVal);
   
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
	document.title = 'Planilla - '+document.title;


function printList(fecha)
//if (request.getParameter("num") != null)

{
  abrir_ventana1('../rhplanilla/param_reportes_aumentos.jsp?fp=sob&fecha='+fecha);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - CONSULTA DE AUMENTOS GENERADOS "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">

		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
		
<%
fb = new FormBean("search11",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fecha",fecha)%>
			
							
				<td width="33%">
					# Empleado
					<%=fb.intBox("num_empleado",num_empleado,false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search12",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				
				<%=fb.hidden("fecha",fecha)%>
				<td width="34%">
					Nombre 
					<%=fb.textBox("nombre",nombre,false,false,false,20)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
<%
fb = new FormBean("search13",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				
				<%=fb.hidden("fecha",fecha)%>
				<td width="33%">
					Cargo
					<%=fb.textBox("cargo",cargo,false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
					
				<%=fb.hidden("fecha",fecha)%>
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800014"))
{
%>
			<a href="javascript:printList('<%=fecha%>')" class="Link00">[ Imprimir Lista ]</a>
<%
}
%>
			&nbsp;
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
				<%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<td width="6%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="39%">Total Registro(s) <%=rowCount%></td>
				<td width="35%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			  <%=fb.hidden("fecha",fecha)%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%> </td>
		<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ===========   R E S U L T S   S T A R T   H E R E   ============== -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tbody id="list">
		<tr class="TextHeader">
			
			<td width="03%">Sec.</td>
			<td width="06%" align="left">#Emp.</td>
			<td width="18%" align="left">Nombre Empleado</td>
			<td width="12%" align="center">Cédula</td>
			<td width="18%" align="center">Cargo</td>
			<td width="09%" align="center">Fecha Aumento</td>
			<td width="07%" align="center">Sueldo actual</td>
			<td width="06%" align="center">Monto</td>
			<td width="06%" align="center">Nuevo Salario</td>
			<td width="06%" align="center">Año/Mes</td>
			<td width="10%" align="center">Comentarios</td>
			
		</tr>
<%
String nFecha = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
		
		 if (!nFecha.equalsIgnoreCase(cdo.getColValue("fechaN")))
				 {
				%>
				  
				<tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
        	<td colspan="10" class="TitulosdeTablas"> [<%=cdo.getColValue("tipo_aumento")%>] - [<%=cdo.getColValue("aumDesc")%>] - Generado con fecha de : <%=cdo.getColValue("fechaN")%></td>
        </tr>
				<%
				}
				%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td align="left"><%=i+1%></td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td><%=cdo.getColValue("nomEmpleado")%></td>
			<td><%=cdo.getColValue("cedula")%></td>
			<td align="left"><%=cdo.getColValue("cargoDesc")%></td>
			<td align="center"><%=cdo.getColValue("fecha")%></td>
			<td align="right"><%=cdo.getColValue("sueldo_anterior")%></td>
			<td align="right"><%=cdo.getColValue("aumento")%></td>
			<td align="right"><%=cdo.getColValue("nuevoSalario")%></td>
			<td align="center"><%=cdo.getColValue("pago")%></td>
			<td align="left"><%=cdo.getColValue("comentarios")%></td>
		
		</tr>
<%

 nFecha = cdo.getColValue("fechaN");
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
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader">
			<td colspan="6" align="center">TOTAL DE EMPLEADOS</td>
			<td colspan="6" align="center">TOTAL DE AUMENTOS</td>
		</tr>
<%

for (int i=0; i<newal.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) newal.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
				%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td colspan="6" align="center"><%=al.size()%></td>
			<td colspan="6" align="center"><%=cdo.getColValue("totAum")%></td>
		</tr>
<%
}
%>
          <%@ page import="java.util.Hashtable" %>		
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
				<%=fb.hidden("fecha",fecha)%>
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
				<td width="35%">Total Registro(s) <%=rowCount%></td>
				<td width="35%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fecha",fecha)%>
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
			<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
			
			
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>

<%
}//POST
%>
