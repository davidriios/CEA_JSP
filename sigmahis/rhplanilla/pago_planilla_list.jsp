
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
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String newsql = "";
String appendFilter = "";
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String anio = request.getParameter("anio");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String estado = request.getParameter("estado");
String banco = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");


if(fg == null)fg="";
if (estado == null )estado="";
if (banco == null )banco="";
if (cuenta == null )cuenta="";
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
	
	String cheque = "",nombre = "",depto  = "",noEmpleado="",empId="";
	if (request.getParameter("cheque") != null && !request.getParameter("cheque").trim().equals(""))
	{
		appendFilter += " and a.num_cheque like '%"+request.getParameter("cheque").toUpperCase()+"%' ";
		cheque     = request.getParameter("cheque");  // utilizada para mantener el Cód. del Tipo de Empleado
	}
	if (request.getParameter("nombre") != null&& !request.getParameter("nombre").trim().equals(""))
	{
		appendFilter += " and upper(e.nombre_empleado) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre    = request.getParameter("nombre");  // utilizada para mantener la descripción del Tipo de Empleado
	}
	if (request.getParameter("depto") != null && !request.getParameter("depto").trim().equals(""))
	{
		appendFilter += " and upper(f.descripcion) like '%"+request.getParameter("depto").toUpperCase()+"%'";
		depto  = request.getParameter("depto");   // utilizada para mantener la cantidad de Horas Extras Permitidas
	}
	if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
	{
		appendFilter += " and e.emp_id  like '%"+request.getParameter("empId")+"%'";
		empId  = request.getParameter("empId");  
	}
	if (request.getParameter("noEmpleado") != null && !request.getParameter("noEmpleado").trim().equals(""))
	{
		appendFilter += " and upper(e.num_empleado) like '%"+request.getParameter("noEmpleado").toUpperCase()+"%'";
		noEmpleado  = request.getParameter("noEmpleado");   // utilizada para mantener la cantidad de Horas Extras Permitidas
	}

	sbSql.append("select d.nombre as nombre, e.nombre_empleado as nomEmpleado, decode(a.cod_planilla,'6',nvl(a.sal_bruto,0),'5', nvl(a.bonificacion,0), nvl(a.sal_bruto,0)) as bruto, nvl(a.prima_produccion,0) as prima,nvl(a.bonificacion,0) as bonificacion, nvl(a.gasto_rep,0) as gastoRep, nvl(a.total_ded,0) as descuento, nvl(a.sal_neto,0) as neto, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, ltrim(d.nombre,18)||' del '||to_char(c.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(c.fecha_final,'dd/mm/yyyy') as descripcion, a.cod_planilla as codPlanilla, a.num_cheque as cheque, a.num_planilla as numPlanilla, e.emp_id as empId, a.anio, nvl(e.ubic_depto,ubic_seccion) as ubicDepto, nvl(f.descripcion,'Por designar ') as descDepto, /* (select min(to_number(num_cheque)) from tbl_pla_pago_empleado x where x.cod_compania= c.cod_compania and x.cod_planilla = c.cod_planilla and x.num_planilla = a.num_planilla and x.anio=a.anio )*/ c.cheque_inicial as minNumCheque,(select x.cod_banco from tbl_pla_parametros x where x.cod_compania = c.cod_compania ) as cod_banco,(select  x.cuenta_bancaria from tbl_pla_parametros x where x.cod_compania = c.cod_compania ) as cuenta_bancaria from tbl_pla_pago_empleado a, vw_pla_empleado e, tbl_pla_planilla_encabezado c, tbl_pla_planilla d, tbl_sec_unidad_ejec f where a.emp_id = e.emp_id and a.cod_compania = e.compania and a.cod_compania = c.cod_compania and a.anio = c.anio and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and e.compania = f.compania and e.ubic_depto = f.codigo and c.cod_compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and a.anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.cod_planilla = ");
	sbSql.append(cod);
	sbSql.append(" and a.num_planilla = ");
	sbSql.append(num);
	sbSql.append(appendFilter);
	sbSql.append(" order by e.ubic_depto, a.num_cheque");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql+")");

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
{
if ((cod==1) || (cod==2))
 {
   abrir_ventana1('../rhplanilla/print_det_pagoempleado.jsp?cod='+cod+'&anio='+anio+'&num='+num);
 }
 if (cod==3)
 {
   abrir_ventana1('../rhplanilla/print_det_pagovac_empleado.jsp?cod='+cod+'&anio='+anio+'&num='+num);
 }
  if (cod==8)
 {
   abrir_ventana1('../rhplanilla/print_det_pagoliq_empleado.jsp?cod='+cod+'&anio='+anio+'&num='+num);
 }
  if (cod==6)
 {
   abrir_ventana1('../rhplanilla/print_det_pagoempleado.jsp?cod='+cod+'&anio='+anio+'&num='+num);
 }
}

function printTal(cod,anio,num,email)
{
 if ((cod == 1) || (cod == 3)|| (cod == 2)|| (cod == 6))
 {
		if(email==0)abrir_ventana1('../rhplanilla/print_list_comp_pago_emp.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
		else abrir_ventana1('../process/pla_gen_comprob_pago_email.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
 }/* else  if (cod==6)
 {
 abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
 }*/
else  abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');

/*if (cod == 1 ||cod == 2||cod == 3||cod == 6)
{
   abrir_ventana1('../rhplanilla/print_list_comprobante_pago2.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
else  abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');*/
}
function printTal2(cod,anio,num)
{
 abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');

/* if(cod=='2'){
 abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
 }
if (cod == 1 ||cod == 2||cod == 3||cod == 6)
{
   abrir_ventana1('../rhplanilla/print_list_comprobante_pago2.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
else  abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
*/
}
function printTal3(cod,anio,num)
{
 abrir_ventana1('../rhplanilla/print_list_comprobante_pago2.jsp?fg=<%=fg%>&cod='+cod+'&anio='+anio+'&num='+num+'&appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
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
	<jsp:param name="title" value="PLANILLA - PAGO DE PLANILLA "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
			&nbsp;<!--<a href="javascript:add()" class="Link00">[ Registrar Nueva Planilla ]</a>-->
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
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("banco",banco)%>
				<%=fb.hidden("cuenta",cuenta)%>
				<td width="20%">
					# Cheque&nbsp;<%=fb.intBox("cheque",cheque,false,false,false,10)%>
				</td>
				<td width="20%">
					Nombre&nbsp;<%=fb.textBox("nombre",nombre,false,false,false,20)%>
				</td>
				<td width="60%">
					Departamento
					<%=fb.textBox("depto",depto,false,false,false,10)%>
					Emp. Id: &nbsp;<%=fb.intBox("empId","",false,false,false,10)%>
					No Empleado: &nbsp;<%=fb.textBox("noEmpleado","",false,false,false,10)%>  
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
	<%=(estado.equalsIgnoreCase("D"))?fb.button("etalonarios","Talonarios Electrónicos",true,false,null,null,"onClick=\"javascript:printTal("+cod+","+anio+","+num+",1);\""):""%>
	<%=fb.button("talonarios","Talonarios",true,false,null,null,"onClick=\"javascript:printTal("+cod+","+anio+","+num+",0);\"")%>
	<%=fb.button("cheques","Cheques",true,((estado.trim().equals("B"))?true:false),null,null,"onClick=\"javascript:printChk("+cod+","+anio+","+num+",'"+cuenta+"','"+banco+"');\"")%>
	<%//=fb.button("talonarios2","Talonarios Dec",true,false,null,null,"onClick=\"javascript:printTal2("+cod+","+anio+","+num+");\"")%>
	<%//=fb.button("talonarios3","Talonarios Pago2",true,false,null,null,"onClick=\"javascript:printTal3("+cod+","+anio+","+num+");\"")%>
	<%if(cod.trim().equals("2")){%><%//=fb.button("talonarios2","Talonarios Prueba",true,false,null,null,"onClick=\"javascript:printTal2("+cod+","+anio+","+num+");\"")%><%}%>
	
	&nbsp;	<a href="javascript:printList('<%=cod%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Lista ]</a>
		</td>
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
				<%=fb.hidden("empId",""+empId)%>
				<%=fb.hidden("noEmpleado",""+noEmpleado)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("banco",banco)%>
				<%=fb.hidden("cuenta",cuenta)%>
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
				<%=fb.hidden("empId",""+empId)%>
				<%=fb.hidden("noEmpleado",""+noEmpleado)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("banco",banco)%>
				<%=fb.hidden("cuenta",cuenta)%>
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
			<td width="10%" align="center">Salarios</td>
			<td width="10%" align="center">Gasto de Rep.</td>
			<td width="11%" align="center">Deducciones</td>
			<td width="10%" align="center">Salario Neto</td>
			<td width="7%" align="center">Acci&oacute;n</td>
		</tr>
<%
String nombrePla = "";
double salarios=0.00,gastoRep=0.00,descuento=0.00,neto=0.00;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
 	salarios  += Double.parseDouble(cdo.getColValue("bruto"));
	 gastoRep  += Double.parseDouble(cdo.getColValue("gastoRep"));
	 descuento += Double.parseDouble(cdo.getColValue("descuento"));
	 neto	   += Double.parseDouble(cdo.getColValue("neto")) ;
	
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
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("bruto"))%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("gastoRep"))%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento"))%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("neto"))%></td>
			<td align="center"><img src="../images/dwn.gif" onClick="javascript:showPopWin('../rhplanilla/pago_planilla_empleado.jsp?empId=<%=cdo.getColValue("empId")%>&cod=<%=cdo.getColValue("codPlanilla")%>&num=<%=cdo.getColValue("numPlanilla")%>&anio=<%=cdo.getColValue("anio")%>&id=<%=i%>&fg=<%=fg%>',winWidth*.95,_contentHeight*.85,null,null,'')" style="cursor:pointer"></td>
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
		<tr class="TextRow02" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'TextRow01')">
			<td width="20%" align="left">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(salarios)%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(gastoRep)%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
			<td align="center"><%=CmnMgr.getFormattedDecimal(neto)%></td>
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
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("empId",""+empId)%>
				<%=fb.hidden("noEmpleado",""+noEmpleado)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("banco",banco)%>
				<%=fb.hidden("cuenta",cuenta)%>
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
			<%=fb.hidden("empId",""+empId)%>
			<%=fb.hidden("noEmpleado",""+noEmpleado)%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("estado",estado)%>
			<%=fb.hidden("banco",banco)%>
			<%=fb.hidden("cuenta",cuenta)%>
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
</body>
</html>
<%
}//POST
%>
