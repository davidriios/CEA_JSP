
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="vacHash" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();

String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String compania = request.getParameter("compania"); 
String tipo = "";
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fecha = cDateTime.substring(0,10);
String anio = cDateTime.substring(6,10);
int rowCount = 0;

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");	

int recsPerPage =100;
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
if (request.getMethod().equalsIgnoreCase("GET"))
{


 sql = "SELECT distinct e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null, e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada, e.primer_apellido)), e.primer_apellido) nombre_empleado, e.provincia, e.sigla, e.tomo, e.asiento, e.num_empleado, decode(e.estado,'2','RETORNA','SALE') estatus, to_char(dv.fecha_inicio,'dd/mm/yyyy') fecha_inicial, to_char(dv.fecha_final,'dd/mm/yyyy') fecha_final, e.estado, e.emp_id FROM tbl_pla_empleado e, tbl_pla_vacacion v, tbl_pla_det_vacacion dv WHERE  v.emp_id = e.emp_id and dv.emp_id = v.emp_id and dv.cod_compania = v.cod_compania and v.cod_compania = e.compania and e.compania="+(String) session.getAttribute("_companyId")+" and ((trunc(dv.fecha_final) >= to_date('"+fecha+"','dd/mm/yyyy') and trunc(dv.fecha_inicio) <= to_date('"+fecha+"','dd/mm/yyyy')) or (trunc(dv.fecha_final) < to_date('"+fecha+"','dd/mm/yyyy'))) and e.estado not in (3,13) order by 7 "+appendFilter;
 
al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
 
  rowCount = CmnMgr.getCount("SELECT count(distinct(e.emp_id)) FROM tbl_pla_empleado e, tbl_pla_vacacion v, tbl_pla_det_vacacion dv WHERE  v.emp_id = e.emp_id and dv.emp_id = v.emp_id and dv.cod_compania = v.cod_compania and v.cod_compania = e.compania and e.compania="+(String) session.getAttribute("_companyId")+" and ((trunc(dv.fecha_final) >= to_date('"+fecha+"','dd/mm/yyyy') and trunc(dv.fecha_inicio) <= to_date('"+fecha+"','dd/mm/yyyy')) or (trunc(dv.fecha_final) < to_date('"+fecha+"','dd/mm/yyyy'))) and e.estado not in (3,13) "+appendFilter);
//and dv.fecha_final < '"+fecha+"'
// and v.anio = '"+anio+"'

  
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
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Recursos Humanos- '+document.title;
function doAction()
{
}

function  printList()
{
abrir_ventana('../rhplanilla/print_list_vacaciones.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function  printList1(xtraParam){
    if(!xtraParam) abrir_ventana('../rhplanilla/print_list_vacaciones_new.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
    else abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_list_vacaciones_new.rptdesign&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&pCtrlHeader=true&fecha=<%=fecha%>');
}


function rutProceso()
{

var msg = '';
//var anio='';
//var estado = '';
var anio = eval('document.form0.anio').value ;
var emp = eval('document.form0.empId').value ;
var estado = eval('document.form0.estatus').value ;

if(anio == "")
msg = ' Año '; 
if(msg == '')
{
   if(confirm('Desea Actualizar el Estado de Vacaciones'))
	{
 	    if(executeDB('<%=request.getContextPath()%>','call SP_PLA_ESTADO_EMPLEADO(<%=compania%>)','tbl_pla_empleado'))
		{
		alert('Estatus Cambiado!');
		window.location = '../rhplanilla/param_actualiza_vacaciones.jsp';
		}
	}
 }
else alert('Seleccione '+msg);

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="ACTUALIZAR ESTADO DE VACACIONES"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="1" cellspacing="0">   
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form01",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<tr class="TextFilter">
				<td align="center"> Este proceso actualiza el estado de los empleados, para los siguientes casos:</td>
			</tr>
	
			<tr class="TextFilter">
				<td> 1) Empleados que están de vacaciones.</td>
	    	</tr>
			
			<tr class="TextFilter">
				<td> 2) Empleados que han cumplido el periodo de sus vacaciones.</td>
			</tr>
		
			<tr class="TextFilter">
			<td align="right"><%=fb.button("buscar","Generar Proceso",false,viewMode,"","","onClick=\"javascript:rutProceso()\"")%></td>
			</tr>
	
	
	</table>
</td>
</tr>

<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800058"))
{
%>
	<authtype type='0'>	<a href="javascript:printList1()" class="Link00">[ Imprimir Auditoria ]</a></authtype>
	<authtype type='0'>	<a href="javascript:printList1(1)" class="Link00">[ Imprimir Auditoria (Excel) ]</a></authtype>
	<authtype type='0'>	<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
<%
}
%>
		</td>
	</tr>
</table>

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="75%" cellpadding="1" cellspacing="0">
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


<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	        			
			<table align="center" width="100%" cellpadding="0" cellspacing="1" >
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("anio",anio)%> 
			<tbody id="list">
							
				<%
				String descripcion = "RETORNA";
				String estatus = "";
				String empId = "";
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
					empId = cdo.getColValue("emp_id");
					estatus = cdo.getColValue("estado");
				if (descripcion=="RETORNA" && preVal==1)
			{
			%>	
			<tr class="TextHeader" align="left">
			<td colspan="4"> Empleados que están de Vacaciones </td>
			</tr>
			
			<tr class="TextHeader" align="center">
				    <td width="10%">No. Empleado</td>
					<td width="60%">Nombre del Empleado</td>
					<td width="15%">Inicio</td>
					<td width="15%">Final</td>	
			</tr>
				 <%
			}	
					
					
					 if (!descripcion.equalsIgnoreCase(cdo.getColValue("estatus")))
					 {
					  %>
					 
					<tr class="TextHeader" align="left">
					<td colspan="4"> Empleados que han Cumplido su Periodo de Vacaciones </td>
					</tr>
					<tr class="TextHeader" align="center">
				    <td width="10%">No. Empleado</td>
					<td width="60%">Nombre del Empleado</td>
					<td width="15%">Inicio</td>
					<td width="15%">Final</td>	
			</tr>
					
				<%
				}
				%>	
				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">	
					<%=fb.hidden("empId",empId)%> 
					<%=fb.hidden("estatus",estatus)%> 
					<td><%=cdo.getColValue("num_empleado")%></td>
					<td> [ <%=cdo.getColValue("estado")%> ] <%=cdo.getColValue("nombre_empleado")%></td>
					<td><%=cdo.getColValue("fecha_inicial")%></td>
				    <td><%=cdo.getColValue("fecha_final")%></td>			   				  
				   
				</tr>
				<%descripcion = cdo.getColValue("estatus");
				} 
				%>
				
				</tbody>
				<%=fb.formEnd(true)%>							
			</table>
	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	
		</td>
	</tr>
	
</table>

<table align="center" width="75%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
}//GET
%>

