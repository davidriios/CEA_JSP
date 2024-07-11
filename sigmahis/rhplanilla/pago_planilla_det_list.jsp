
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
/**
==================================================================================
800013	VER LISTA DE TIPO DE EMPLEADO
800014	IMPRIMIR LISTA DE TIPO DE EMPLEADO
800015	AGREGAR TIPO DE EMPLEADO
800016	MODIFICAR TIPO DE EMPLEADO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800013") || SecMgr.checkAccess(session.getId(),"800014") || SecMgr.checkAccess(session.getId(),"800015") || SecMgr.checkAccess(session.getId(),"800016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String anio = request.getParameter("anio");
String id = request.getParameter("id");

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
	
	String cheque = "";        // variables para mantener el valor de los campos filtrados en la consulta
	String nombre = "";
	String depto  = "";
   
	if (request.getParameter("cheque") != null)
	{
	appendFilter += " and d.num_cheque like '%"+request.getParameter("cheque").toUpperCase()+"%' ";
    searchOn = "d.num_cheque";
    searchVal = request.getParameter("cheque");
    searchType = "1";
    searchDisp = "Cheque";
		cheque     = request.getParameter("cheque");  // utilizada para mantener el Cód. del Tipo de Empleado
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
	else if (request.getParameter("depto") != null)
	{
	appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("depto").toUpperCase()+"%'";
    searchOn = "f.descripcion";
    searchVal = request.getParameter("depto");
    searchType = "1";
    searchDisp = "Departamento";
	depto  = request.getParameter("depto");   // utilizada para mantener la cantidad de Horas Extras Permitidas
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

	sql = "select b.nombre as nombre, (e.primer_nombre||' '||e.primer_apellido) as nomEmpleado, to_char(d.sal_ausencia,'999,990.00') as bruto, to_char(d.gasto_rep,'999,990.00') as gastoRep, to_char(d.total_ded,'999,990.00') as descuento, to_char(d.sal_neto,'999,990.00') as neto, to_char(a.fecha_pago,'dd-mm-yyyy') as fechaPago, ltrim(b.nombre,18)||' del '||a.fecha_inicial||' al '||a.fecha_final as descripcion, d.cod_planilla as codPlanilla, d.num_cheque as cheque, d.num_planilla as numPlanilla, e.emp_id as empId, d.anio, nvl(e.ubic_depto,ubic_seccion) as ubicDepto, nvl(f.descripcion,'Por designar ') as descDepto from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo"+appendFilter+" order by e.ubic_depto, d.num_cheque";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo"+appendFilter);
	
	
	newsql = "Select to_char(sum(d.sal_ausencia),'999,999,990.00') as sbruto, to_char(sum(d.gasto_rep),'999,999,990.00') as sgasto, to_char(sum(d.total_ded),'999,999,990.00') as sdes, to_char(sum(d.sal_neto),'999,999,990.00') as sneto from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_empleado d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo"+appendFilter;
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

function add()
{
	abrir_ventana1('../rhplanilla/calculo_planilla.jsp');
}

function edit(empId,cod,anio,num,id)
{
	abrir_ventana1('../rhplanilla/pago_planilla_empleado.jsp?empId='+empId+'&cod='+cod+'&anio='+anio+'&num='+num+'&id='+id);
}

function printList(cod,anio,num)
//if (request.getParameter("num") != null)

{
   abrir_ventana1('../rhplanilla/print_det_pagoempleado.jsp?cod='+cod+'&anio='+anio+'&num='+num);
 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - PAGO DE PLANILLA "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800015"))
{
%>
			<a href="javascript:add()" class="Link00">[ Registrar Nueva Planilla ]</a>
<%
}
%>
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
					<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
							
				<td width="33%">
					# Cheque
					<%=fb.intBox("cheque",cheque,false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search12",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
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
				
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
				<td width="33%">
					Departamento
					<%=fb.textBox("depto",depto,false,false,false,10)%>
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
	<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("num",num)%>
<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800014"))
{
%>
			<a href="javascript:printList('<%=cod%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Lista ]</a>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
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
			
			<td width="6%"># Chk.</td>
			<td width="26%" align="left">Descripci&oacute;n</td>
			<td width="20%" align="left">Departamento</td>
			<td width="10%" align="center">Salarios</td>
			<td width="10%" align="center">Gasto de Rep.</td>
			<td width="11%" align="center">Deducciones</td>
			<td width="10%" align="center">Salario Neto</td>
			<td width="7%" align="center">Acci&oacute;n</td>
		</tr>
<%
String nombrePla = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
		 if (!nombrePla.equalsIgnoreCase(cdo.getColValue("nombre")))
				 {
				%>
				  
					 <tr align="left" bgcolor="#FFFFFF" class="linksblacklight">
                      <td colspan="8" class="TitulosdeTablas"> [<%=cdo.getColValue("codPlanilla")%>] - [<%=cdo.getColValue("numPlanilla")%>] - <%=cdo.getColValue("descripcion")%></td>
                   </tr>
				<%
				   }
				%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td align="left"><%=cdo.getColValue("cheque")%></td>
			<td><%=cdo.getColValue("nomEmpleado")%></td>
			<td><%=cdo.getColValue("descDepto")%></td>
			<td align="center"><%=cdo.getColValue("bruto")%></td>
			<td align="center"><%=cdo.getColValue("gastoRep")%></td>
			<td align="center"><%=cdo.getColValue("descuento")%></td>
			<td align="center"><%=cdo.getColValue("neto")%></td>
			<td align="center"> Ver&nbsp;<%
if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800016"))
{
%>
			  <img src="../images/dwn.gif" onClick="javascript:diFrame('list','9','rs<%=i%>','800','300','0','0','1','DIVExpandRowsScroll',true,'0','../rhplanilla/pago_planilla_empleado.jsp?empId=<%=cdo.getColValue("empId")%>&cod=<%=cdo.getColValue("codPlanilla")%>&num=<%=cdo.getColValue("numPlanilla")%>&anio=<%=cdo.getColValue("anio")%>&id=<%=i%>',false)" style="cursor:pointer">
		
            <% 
}
%>			</td>
		</tr>
<%
	nombrePla = cdo.getColValue("nombre");
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
			
			<td colspan="2" align="center">TOTALES POR PLANILLA</td>
			<td width="10%" align="center">Salarios</td>
			<td width="10%" align="center">Gasto de Rep.</td>
			<td width="11%" align="center">Deducciones</td>
			<td width="10%" align="center">Salario Neto</td>
			<td width="7%" align="center"></td>
		</tr>
<%

for (int i=0; i<newal.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) newal.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
				%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td width="20%" align="left">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td align="center"><%=cdo.getColValue("sbruto")%></td>
			<td align="center"><%=cdo.getColValue("sgasto")%></td>
			<td align="center"><%=cdo.getColValue("sdes")%></td>
			<td align="center"><%=cdo.getColValue("sneto")%></td>
			<td align="center">&nbsp;</td>
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
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
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
			<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
				<%=fb.hidden("cheque",cheque)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
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
