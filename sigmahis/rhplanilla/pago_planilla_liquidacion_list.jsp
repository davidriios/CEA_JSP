
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
ArrayList alExtra = new ArrayList();
ArrayList alDesc = new ArrayList();
ArrayList alLiq = new ArrayList();

int rowCount = 0;
String sql = "";
String newsql = "";
String appendFilter = "";
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String anio = request.getParameter("anio");
String id = request.getParameter("id");
StringBuffer sbSql = new StringBuffer();
String estado = request.getParameter("estado");
if (estado == null )estado="";
String cuenta = request.getParameter("cuenta");
String banco = request.getParameter("banco");

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
   
	if (request.getParameter("cheque") != null && !request.getParameter("cheque").trim().equals(""))
	{
		appendFilter += " and d.num_cheque like '%"+request.getParameter("cheque").toUpperCase()+"%' ";
    	cheque     = request.getParameter("cheque");  // utilizada para mantener el Cód. del Tipo de Empleado
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

	sbSql.append("select b.nombre AS nombre,e.nombre_empleado AS nomEmpleado,e.cedula1 AS cedula, e.tipo_renta||' '||e.num_dependiente  AS clave, e.rata_hora AS rata, nvl(d.salario,0) AS salbruto, nvl(d.gasto_rep,0)gastoRep, nvl(d.prima_antiguedad,0) AS prima, nvl(d.indemnizacion,0) AS indemnizacion, nvl(d.preaviso,0) AS preaviso, nvl(d.bonificacion,0) AS bonificacion, nvl(nvl(d.salario,0) + nvl(d.extra,0) + nvl(d.prima_antiguedad,0) + nvl(d.preaviso,0) + nvl(d.bonificacion,0) + nvl(d.gasto_rep,0) + nvl(d.indemnizacion,0) + nvl(d.xiii_mes,0) + nvl(d.vacacion,0) - nvl(d.otros_egr,0),0)  AS salbrutoTop, nvl(d.vacacion,0) AS vacacion, nvl(d.xiii_mes,0) AS decimo, nvl(d.extra,0) AS extra, nvl(d.seg_social,0) AS social, nvl(d.seg_educativo,0) AS educativo, nvl(d.imp_renta,0) AS renta,  nvl(d.ausencia,0) AS ausencia, nvl(d.tardanza,0) AS tardanza, nvl(d.otras_ded,0) AS otrasDed, nvl(d.total_ded,0) AS totDed,nvl(d.otros_ing_fijos,0) AS ingFijos, nvl(d.otros_ing,0) AS otrosIng, nvl(d.otros_egr,0) AS otrosEgr, nvl(d.sal_neto,0) AS salarioNeto, nvl(d.seg_social_gasto,0) AS ssGrep,  nvl(d.imp_renta_gasto,0) imp_renta_gasto, nvl(d.prima_produccion,0) AS primaProd, d.unidad_organi, TO_CHAR(a.fecha_pago,'dd/mm/yyyy') AS fechaPago, LTRIM(b.nombre,18)||' del '||to_char(a.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(a.fecha_final,'dd/mm/yyyy') AS descripcion, d.cod_planilla AS codPlanilla, d.num_cheque AS cheque, d.num_planilla AS numPlanilla, d.anio, e.emp_id AS empId, e.num_empleado AS numEmpleado, NVL(e.ubic_depto,e.ubic_seccion) AS ubicDepto, NVL(f.descripcion,'Por designar ') AS descDepto, e.ubic_seccion AS unidad,nvl(d.seg_social,0)+nvl(d.seg_educativo,0)+nvl(d.imp_renta,0)+nvl(d.otras_ded,0)+nvl(d.total_ded,0)+nvl(d.seg_social_gasto,0) + nvl(d.imp_renta_gasto,0) totalDeducciones from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_sec_compania c, tbl_pla_pago_liquidacion d, vw_pla_empleado e, tbl_sec_unidad_ejec f where a.cod_compania = c.codigo and a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and d.emp_id = e.emp_id and a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = ");
sbSql.append(anio);
sbSql.append(" and d.num_planilla = ");
sbSql.append(num);
sbSql.append(" and d.cod_planilla = ");
sbSql.append(cod);
sbSql.append(" and a.num_planilla = d.num_planilla and a.cod_compania=");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.cod_compania = d.cod_compania and a.cod_compania = f.compania and e.ubic_seccion = f.codigo order by e.ubic_seccion, e.num_empleado");
al = SQLMgr.getDataList(sbSql.toString());

	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");



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
	abrir_ventana1('../rhplanilla/pago_planilla_liquidacion.jsp?empId='+empId+'&cod='+cod+'&anio='+anio+'&num='+num+'&id='+id);
}
function printList(cod,anio,num)
{
 if (cod==8)
 {
   abrir_ventana1('../rhplanilla/print_det_pagoliq_empleado.jsp?cod='+cod+'&anio='+anio+'&num='+num);
 }
}
function printTal(cod,anio,num)
{
if ((cod == 1) || (cod == 3))
{
   abrir_ventana1('../rhplanilla/print_list_comp_pago_emp.jsp?cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
else  abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function printChk(cod,anio,num,cuenta,banco)
{
var referencia = cod+'-'+num+'-'+anio;
abrir_ventana1('../cxp/print_cheque.jsp?fp=cheque&referencia='+referencia+'&fg=solo&cuenta_banco='+cuenta+'&cod_banco='+banco); 
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - PAGO DE PLANILLA DE LIQUIDACIONES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp; </td>
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
				<%=fb.hidden("estado",estado)%>
							
				<td width="33%">
					# Cheque
					<%=fb.intBox("cheque",cheque,false,false,false,10)%>
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
 <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		   </table>
		</td>
	</tr>
  <tr>
    <td align="right"><a href="javascript:printList('<%=cod%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Lista ]</a>
	<%=fb.button("cheques","Cheques",true,((estado.trim().equals("B"))?true:false),null,null,"onClick=\"javascript:printChk("+cod+","+anio+","+num+",'"+cuenta+"','"+banco+"');\"")%></td>
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
				<%=fb.hidden("estado",estado)%>
				<td width="6%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="39%">Total Registro(s) <%=rowCount%></td>
				<td width="25%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("estado",estado)%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%> </td>
		<td  width="10%" align="right">&nbsp; </td>
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
			<td width="10%" align="center">Ingresos</td>
			<td width="10%" align="center">Gasto de Rep.</td>
			<td width="11%" align="center">Deducciones</td>
			<td width="10%" align="center">Salario Neto</td>
			<td width="7%" align="center">Acci&oacute;n</td>
		</tr>
<%
String nombrePla = "";
	double 	totGralIng = 0.00, totGralGr = 0.00;
	double 	totGralDesc = 0.00, totGralNeto = 0.00;
	double 	totalBruto = 0.00, totalGasto = 0.00,totalOtrasDed = 0.00,totalDed = 0.00,totalNeto = 0.00,OtrasDed = 0.00,ded = 0.00;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	

	totalBruto  +=Double.parseDouble(cdo.getColValue("salbrutoTop"));
	totalGasto  +=Double.parseDouble(cdo.getColValue("gastoRep"));
	totalDed   +=Double.parseDouble(cdo.getColValue("totalDeducciones"));
	totalNeto  +=Double.parseDouble(cdo.getColValue("salarioNeto"));
		
		
		 if (!nombrePla.equalsIgnoreCase(cdo.getColValue("descripcion")))
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
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("salbrutoTop"))%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("gastoRep"))%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("totalDeducciones"))%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("salarioNeto"))%></td>
			<td align="center"><img src="../images/dwn.gif" onClick="javascript:showPopWin('../rhplanilla/pago_planilla_liquidacion.jsp?empId=<%=cdo.getColValue("empId")%>&cod=<%=cdo.getColValue("codPlanilla")%>&num=<%=cdo.getColValue("numPlanilla")%>&anio=<%=cdo.getColValue("anio")%>&id=<%=i%>',winWidth*.95,_contentHeight*.85,null,null,'')" style="cursor:pointer">
			
			</td>
		</tr>
<%


	nombrePla = cdo.getColValue("descripcion");
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
			<td width="10%" align="center">Ingresos</td>
			<td width="10%" align="center">Gasto de Rep.</td>
			<td width="11%" align="center">Deducciones</td>
			<td width="10%" align="center">Salario Neto</td>
			<td width="7%" align="center"></td>
		</tr>
<%

	String color = "TextRow02";
				%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td width="20%" align="left">&nbsp;</td>

			<td width="32%">&nbsp;</td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(totalBruto)%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(totalGasto)%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(totalDed)%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(totalNeto)%></td>
			<td align="center">&nbsp;</td>
		</tr>
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
				<%=fb.hidden("estado",estado)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="35%">Total Registro(s) <%=rowCount%></td>
				<td width="25%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
			<%=fb.hidden("estado",estado)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<td  width="10%" align="right">&nbsp; </td>
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

