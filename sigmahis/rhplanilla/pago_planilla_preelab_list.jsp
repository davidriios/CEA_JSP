
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
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String anio = request.getParameter("anio");
String id = request.getParameter("id");
String num_empleado = "";     
String nombre = "";
String depto  = "";

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
	
   
	if (request.getParameter("num_empleado") != null && !request.getParameter("num_empleado").trim().equals(""))
	{
	appendFilter += " and e.num_empleado like '%"+request.getParameter("num_empleado").toUpperCase()+"%' ";
       num_empleado     = request.getParameter("num_empleado");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
	{
	appendFilter += " and upper(e.primer_nombre||' '||e.primer_apellido) like '%"+request.getParameter("nombre").toUpperCase()+"%'"; 
		nombre    = request.getParameter("nombre");  // utilizada para mantener la descripción del Tipo de Empleado
	}
	if (request.getParameter("depto") != null && !request.getParameter("depto").trim().equals(""))
	{
	appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("depto").toUpperCase()+"%'"; 
	depto  = request.getParameter("depto");   // utilizada para mantener la cantidad de Horas Extras Permitidas
	}
	 
 /*and d.emp_id = e.emp_id */
	sql = " select b.nombre as nombre, (e.primer_nombre||' '||e.primer_apellido) as nomEmpleado, to_char(d.sal_bruto,'999,990.00') as bruto, to_char(d.imp_renta,'999,990.00') as impRenta, to_char(d.fondo_com,'999,990.00') as fondoCom, to_char(d.decimo,'999,990.00') as decimo, to_char(d.otros_ingresos,'999,990.00') as otrosIng, d.observacion, d.consecutivo, d.departamento, d.excepciones, d.ajuste, b.nombre||' de ' || decode(a.mes, '1', 'ENERO','2', 'FEBRERO','3', 'MARZO','4', 'ABRIL','5', 'MAYO','6', 'JUNIO', '7', 'JULIO', '8','AGOSTO', '9','SEPTIEMBRE','10','OCTUBRE','11','NOVIEMBRE','12','DICIEMBRE') as descripcion, d.cod_reporte as codReporte, d.mes, e.emp_id as empId, d.anio, nvl(e.ubic_depto,ubic_seccion) as ubicDepto, nvl(f.descripcion,'Por designar ') as descDepto, decode(a.mes, '1', 'ENERO','2', 'FEBRERO','3', 'MARZO','4', 'ABRIL','5', 'MAYO', '6', 'JUNIO', '7','JULIO', '8','AGOSTO', '9','SEPTIEMBRE', '10','OCTUBRE','11','NOVIEMBRE','12','DICIEMBRE') as mesDesc,  e.num_empleado,nvl(e.pasaporte, (e.provincia||'-'||e.sigla||'-'||e.tomo||'-'||e.asiento)) as cedula  from tbl_pla_reporte_encabezado a, tbl_pla_reporte b, tbl_sec_compania c, tbl_pla_retenciones d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_reporte = b.cod_reporte and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_reporte = d.cod_reporte and d.anio = "+anio+" and d.mes = "+num+" and d.cod_reporte = "+cod+" and a.mes = d.mes and a.cod_compania="+(String) session.getAttribute("_companyId")+ appendFilter + " and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo order by e.provincia, e.sigla, e.tomo, e.asiento";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_pla_reporte_encabezado a, tbl_pla_reporte b, tbl_sec_compania c, tbl_pla_retenciones d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_reporte = b.cod_reporte and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_reporte = d.cod_reporte and d.anio = "+anio+" and d.mes = "+num+" and d.cod_reporte = "+cod+" and a.mes = d.mes and a.cod_compania="+(String) session.getAttribute("_companyId")+ appendFilter + " and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo");
	
	
	newsql = "Select to_char(sum(d.sal_bruto),'999,999,990.00') as sbruto, to_char(sum(d.imp_renta),'999,999,990.00') as srenta, to_char(sum(d.fondo_com),'999,999,990.00') as sfondo, to_char(sum(d.decimo),'999,999,990.00') as sdecimo, to_char(sum(d.otros_ingresos),'999,999,990.00') as sotros from tbl_pla_reporte_encabezado a, tbl_pla_reporte b, tbl_sec_compania c, tbl_pla_retenciones d, tbl_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_reporte = b.cod_reporte and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_reporte = d.cod_reporte and d.anio = "+anio+" and d.mes = "+num+" and d.cod_reporte = "+cod+" and a.mes = d.mes and a.cod_compania="+(String) session.getAttribute("_companyId")+ appendFilter + " and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_depto = f.codigo";
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
function add(){abrir_ventana1('../rhplanilla/calculo_planilla.jsp');}
function edit(empId,cod,anio,num,id){abrir_ventana1('../rhplanilla/pago_planilla_empleado.jsp?empId='+empId+'&cod='+cod+'&anio='+anio+'&num='+num+'&id='+id);}
function printList(cod,anio,num){abrir_ventana1('../rhplanilla/print_det_preelaborada.jsp?cod='+cod+'&anio='+anio+'&num='+num);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - REPORTE DE PLANILLA PREELABORADA "></jsp:param>
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
		
<%fb = new FormBean("search11",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("cod",cod)%>
				<%=fb.hidden("num",num)%>
						   
				<td width="33%">
					# Empleado
					<%=fb.intBox("num_empleado",num_empleado,false,false,false,10)%> 
				</td> 
				<td width="34%">
					Nombre 
					<%=fb.textBox("nombre",nombre,false,false,false,20)%> 
				</td> 
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
    <td align="right"> <a href="javascript:printList('<%=cod%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Lista ]</a></td>
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
				<%=fb.hidden("num_empleado",num_empleado)%>
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
				<%=fb.hidden("num_empleado",num_empleado)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
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
				<%=fb.hidden("num_empleado",num_empleado)%>
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
				<%=fb.hidden("num_empleado",num_empleado)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
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
			
			<td width="4%"># Sec.</td>
			<td width="6%" align="left">#Emp.</td>
			<td width="22%" align="left">Nombre Empleado</td>
			<td width="13%" align="center">Cédula/Pass</td>
			<td width="10%" align="center">Excepciones</td>
			<td width="5%" align="center">Ajuste</td>
			<td width="8%" align="center">Sal. Bruto</td>
			<td width="8%" align="center">Imp/Renta</td>
			<td width="8%" align="center">Fondo Comp.</td>
			<td width="8%" align="center">Décimo</td>
			<td width="8%" align="center">Otros Ing.</td>
			
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
                      <td colspan="10" class="TitulosdeTablas"> [<%=cdo.getColValue("codReporte")%>] - [<%=cdo.getColValue("mesDesc")%>] - <%=cdo.getColValue("descripcion")%></td>
                   </tr>
				<%
				   }
				%>
		<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td align="left"><%=i+1%></td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td><%=cdo.getColValue("nomEmpleado")%></td>
			<td><%=cdo.getColValue("cedula")%></td>
			<td align="center"><%=cdo.getColValue("excepciones")%></td>
			<td align="center"><%=cdo.getColValue("ajuste")%></td>
			<td align="right"><%=cdo.getColValue("bruto")%></td>
			<td align="right"><%=cdo.getColValue("impRenta")%></td>
			<td align="right"><%=cdo.getColValue("fondoCom")%></td>
			<td align="right"><%=cdo.getColValue("decimo")%></td>
			<td align="right"><%=cdo.getColValue("otrosIng")%></td>
		
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
		<td width="4%" align="center">&nbsp;</td>
			<td width="51%" align="center">TOTALES POR PLANILLA PREELABORADA</td>
			<td width="5%" align="center">&nbsp;</td>
			<td width="8%" align="center">Sal. Bruto</td>
			<td width="8%" align="center">Imp/Renta</td>
			<td width="8%" align="center">Fondo Comp.</td>
			<td width="8%" align="center">Décimo</td>
			<td width="8%" align="center">Otros Ing.</td>
			
			
		
		</tr>
<%

for (int i=0; i<newal.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) newal.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
				%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
		
			<td colspan="3">&nbsp;</td>
			<td align="right"><%=cdo.getColValue("sbruto")%></td>
			<td align="right"><%=cdo.getColValue("srenta")%></td>
			<td align="right"><%=cdo.getColValue("sfondo")%></td>
			<td align="right"><%=cdo.getColValue("sdecimo")%></td>
			<td align="right"><%=cdo.getColValue("sotros")%></td>
			
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
				<%=fb.hidden("num_empleado",num_empleado)%>
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
				<%=fb.hidden("num_empleado",num_empleado)%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("depto",depto)%>
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
				<%=fb.hidden("num_empleado",num_empleado)%>
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
			<%=fb.hidden("num_empleado",num_empleado)%>
			<%=fb.hidden("nombre",nombre)%>
			<%=fb.hidden("depto",depto)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<td  width="10%" align="right"> <%=fb.button("cancel","Cerrar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				<%=fb.formEnd()%>
			</tr>
			
			
		</table>
	</td>
</tr>
</table>
</body>
</html>

<%
}//POST
%>
