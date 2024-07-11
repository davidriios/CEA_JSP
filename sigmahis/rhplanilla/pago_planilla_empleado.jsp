<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alExtra = new ArrayList();
ArrayList alDesc = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String empId = request.getParameter("empId");
String cod = request.getParameter("cod");
String num = request.getParameter("num");
String anio = request.getParameter("anio");
String id = request.getParameter("id");


if (empId == null || cod == null) throw new Exception("El empleado no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{


	sql = "select to_char(nvl(a.sal_bruto,0),'999,999,990.00') as salBruto, to_char(nvl(a.sal_neto,0),'999,999,990.00') as salNeto, to_char(nvl(a.sal_ausencia,0),'999,999,990.00') as salAus, to_char(nvl(a.extra,0),'99999990.00') extra, to_char(nvl(a.seg_social,0),'999,990.00') as segSoc, to_char(nvl(a.seg_educativo,0),'999,990.00') as segEdu, to_char(nvl(a.imp_renta,0),'999,990.00') as impRen, to_char(nvl(a.fondo_com,0),'999,990.00') as fonCom, to_char(nvl(a.tardanza,0)*-1,'999,990.00') tardanza, to_char(nvl(a.ausencia,0)*-1,'999,990.00') ausencia, to_char(nvl(a.otras_ded,0),'999999990.00') as deduc, to_char(nvl(a.total_ded,0) /*+ nvl(a.otros_egr,0)*/,'999,999,990.00') as totDed, to_char(nvl(a.dev_multa,0),'999,990.00') as devMul, to_char(nvl(a.comision,0),'999,990.00'), to_char(nvl(a.gasto_rep,0),'99,999,990.00') as gasRep, to_char(nvl(a.ayuda_mortuoria,0),'999,990.00') as aMor, to_char(nvl(a.otros_ing,0),'999,999,990.00') as otroIng, nvl(to_char(nvl(a.extra,0),'999,999,990.00'),0) as extra, to_char(a.otros_egr,'999,999,990.00') as otroEg, to_char(a.alto_riesgo,'999,990.00') as altRiesgo, to_char(a.bonificacion,'999,990.00'), to_char(nvl(a.prima_produccion,0),'999,999,990.00') as prima, to_char(nvl(a.aguinaldo_gasto,0),'999,990.00') as aguiGas, to_char(nvl(a.imp_renta_gasto,0),'999,990.00') as impGasto, a.cheque_pago as cheque, to_char(nvl(a.seg_social_gasto,0),'999,990.00') as ssGasto, a.cod_planilla codigo, to_char(to_number(nvl(a.sal_ausencia,0.00))+to_number(nvl(a.gasto_rep,0.00))+to_number(nvl(a.alto_riesgo,0.00))+to_number(nvl(a.prima_produccion,0.00))+to_number(nvl(a.extra,0.00))+to_number(nvl(a.bonificacion,0.00))  + to_number(nvl(a.comision,0.00)) + to_number(nvl(a.otros_ing,0.00)) - nvl(a.otros_egr,0),'999,999,990.00') as ingTot, to_char(a.salario_especie,'999,999,990.00') as salEsp, to_char(nvl(a.seg_social_especie,0),'999,990.00') as ssEsp, periodo_xiiimes as decimo, a.num_empleado as numEmpleado, to_char(a.num_cheque,'00000000000') as numCheque, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(c.fecha_inicial,'dd/mm/yyyy') as fechaInicial, to_char(c.fecha_final,'dd/mm/yyyy') as fechaFinal, c.estado, b.nombre_empleado as nomEmpleado, to_char(nvl(a.salario_base,0),'999,999,990.00') as salarioBase, to_char(nvl(a.salario_base,0)/2,'999,999,990.00') as salario, to_char(nvl(a.rata_hora,0),'999,990.00000') as rataHora, b.tipo_renta||'-'||to_char(b.num_dependiente,'990') as tipoRenta,ltrim(d.nombre,18)||' del '||to_char(c.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(c.fecha_final,'dd/mm/yyyy') as descripcion, to_char(decode(a.salario_base,0,b.salario_base,nvl(a.sal_ausencia,0)+nvl(a.ausencia,0)+nvl(a.tardanza,0)),'999,999,990.00') salario_quinc,d.fg from tbl_pla_pago_empleado a, vw_pla_empleado b, tbl_pla_planilla_encabezado c, tbl_pla_planilla d where a.cod_compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = b.emp_id and a.cod_compania = b.compania and a.cod_compania = c.cod_compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and a.anio = c.anio and a.emp_id="+empId+" and a.num_planilla="+num+" and a.cod_planilla="+cod+" and a.anio = "+anio;
	al = SQLMgr.getDataList(sql);
sql = "select  -1 orden, sum(a.cantidad) cantidad, to_char(-sum(nvl(a.monto,0)),'999999990.00') monto, a.tipo_trx as the_codigo, a.emp_id, substr(t.descripcion,1,24) descripcion from tbl_pla_transac_emp a,tbl_pla_tipo_transaccion t  where a.compania = t.compania and a.tipo_trx = t.codigo and a.compania =  "+(String) session.getAttribute("_companyId")+" and a.anio_pago ="+anio+" and a.quincena_pago = "+num+" and a.cod_planilla_pago = "+cod+" and a.emp_id="+empId+" and a.vobo_estado = 'S' and a.accion = 'DE' group by a.emp_id, a.tipo_trx, t.descripcion ";
  sql += " union all  ";

	sql+= "select 1 orden, sum(nvl(a.cantidad,0)) cantidad,to_char(sum(decode(a.accion,'DS',nvl(a.monto,0)*-1,nvl(a.monto,0))),'9999999990.00') monto, a.motivo_falta the_codigo, a.emp_id, t.descripcion from tbl_pla_aus_y_tard a , tbl_pla_motivo_falta t where a.compania =   "+(String) session.getAttribute("_companyId")+" and a.anio_des ="+anio+ " and a.quincena_des = "+num+" and a.cod_planilla_des = "+cod+" and a.emp_id="+empId+" and a.motivo_falta = t.codigo and a.vobo_estado = 'S' group by a.emp_id, a.motivo_falta,t.descripcion ";
  sql += " union ";
	sql += "select  2 orden, sum(nvl(a.cantidad_aprob,0)) cantidad, to_char(sum(nvl(a.monto,0)),'999999990.00') monto, a.the_codigo, a.emp_id, t.descripcion from tbl_pla_t_extraordinario a,tbl_pla_t_horas_ext t  where a.compania =  "+(String) session.getAttribute("_companyId")+" and a.anio_pag ="+anio+ " and a.quincena_pag = "+num+" and a.cod_planilla_pag = "+cod+" and a.emp_id="+empId+" and a.the_codigo = t.codigo and the_codigo not in ('24','27','28') and a.vobo_estado = 'S' group by a.emp_id, a.the_codigo,t.descripcion ";
	sql += " union ";
	sql += "select  3 orden, sum(nvl(a.cantidad,0)) cantidad, to_char(sum(nvl(a.monto,0)),'999999990.00') monto, a.tipo_trx, a.emp_id, t.descripcion from tbl_pla_transac_emp a,tbl_pla_tipo_transaccion t  where a.compania = t.compania and a.tipo_trx = t.codigo and a.compania =  "+(String) session.getAttribute("_companyId")+" and a.anio_pago ="+anio+" and a.quincena_pago = "+num+" and a.cod_planilla_pago = "+cod+" and a.emp_id="+empId+" and a.vobo_estado = 'S' and a.accion = 'PA' group by a.tipo_trx,a.emp_id, t.descripcion order by 1 ,4 asc";

	alExtra = SQLMgr.getDataList(sql);
sql = "select 1 orden, 1 cantidad, to_char(sum(abs(nvl(a.seg_educativo,0))),'9999990.00') monto, 1 as cod_acreedor, a.emp_id, 'Seguro Educativo'  descripcion ,-1 as num_descuento from  tbl_pla_pago_empleado a where a.anio = "+anio+" and  a.cod_planilla  = "+cod+" and a.num_planilla = "+num+" and a.cod_compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = "+empId+"  group by a.emp_id ";
sql += " union  ";
sql += "select  2 orden, 1 cantidad, to_char(abs(nvl(a.monto,0)),'9999990.00') monto, a.cod_acreedor, a.emp_id, substr(ac.nombre,1,24) descripcion,ds.num_descuento from  tbl_pla_acreedor ac, tbl_pla_descuento_aplicado a, tbl_pla_descuento ds where a.anio = "+anio+" and  a.cod_planilla  = "+cod+" and a.num_planilla = "+num+" and a.cod_compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = ds.emp_id and a.emp_id="+empId+" and ac.cod_acreedor = a.cod_acreedor and ac.compania = a.cod_compania and a.num_descuento = ds.num_descuento and a.cod_compania = ds.cod_compania order by 1 asc";

//sql += " union ";
	//sql += "select  3 orden, sum(nvl(a.cantidad,0)) cantidad, to_char(sum(nvl(a.monto,0)),'999999990.00') monto, a.tipo_trx, a.emp_id, t.descripcion from tbl_pla_transac_emp a,tbl_pla_tipo_transaccion t  where a.compania = t.compania and a.tipo_trx = t.codigo and a.compania =  "+(String) session.getAttribute("_companyId")+" and a.anio_pago ="+anio+" and a.quincena_pago = "+num+" and a.cod_planilla_pago = "+cod+" and a.emp_id="+empId+" and a.vobo_estado = 'S' and a.accion = 'DE' group by a.emp_id, a.tipo_trx, t.descripcion order by 1 ,4 asc ";
  alDesc = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Pago a Empleados - '+document.title;


function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}


function printList(empId,cod,anio,num,fg)
{
if ((cod == 1) || (cod == 2)|| (cod == 3)|| (cod == 6))
{
   abrir_ventana1('../rhplanilla/print_list_comp_pago_emp.jsp?cod='+cod+'&anio='+anio+'&num='+num+'&empId='+empId+'&fg='+fg);
}else  abrir_ventana1('../rhplanilla/print_list_comp_pago_dec.jsp?fg='+fg+'&cod='+cod+'&anio='+anio+'&num='+num+'&empId='+empId);
/*
if(cod != 2){
	abrir_ventana('../rhplanilla/print_list_comp_pago_emp.jsp?empId='+empId+'&cod='+cod+'&anio='+anio+'&num='+num+'&fg='+fg);
 } else abrir_ventana('../rhplanilla/print_list_comprobante_pago.jsp?empId='+empId+'&cod='+cod+'&anio='+anio+'&num='+num);*/
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="COMPROBANTE DE PAGO"></jsp:param>
  <jsp:param name="displayCompany" value="y"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size","")%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("cod",cod)%>
<%=fb.hidden("num",cod)%>
<%=fb.hidden("anio",anio)%>
<table width="100%" cellpadding="1" cellspacing="1">

  <!--<tr>
    <td align="right" colspan="7">&nbsp;<a href="javascript:printList('<%=empId%>','<%=cod%>','<%=anio%>','<%=num%>','')" class="Link00">[ Imprimir Comprobante ]</a></td>
  </tr>-->
  <%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

	double 	totExtra = 0.00;
	int 		contExtra = 0;
	int 		contDesc = 0;
	double 	totDesc = 0.00;
	if(i==0)		{
%>

 <tr>
    <td align="right" colspan="7">&nbsp;<a href="javascript:printList('<%=empId%>','<%=cod%>','<%=anio%>','<%=num%>','<%=cdo.getColValue("fg")%>')" class="Link00">[ <cellbytelabel>Imprimir Comprobante</cellbytelabel> ]</a></td>
  </tr><%}%>
<tr align="center" class="TextHeader">
    <td width="21%">&nbsp;</td>
    <td colspan="4" align="center"><%=cdo.getColValue("descripcion")%></td>
    <td colspan="2">&nbsp;</td>
  </tr>
<tr align="center" class="TextHeader">
    <td width="21%"><p># <cellbytelabel>Empleado</cellbytelabel> &nbsp; <%=cdo.getColValue("numEmpleado")%> </p>
      <p>&nbsp;&nbsp; <cellbytelabel>Clave de Renta</cellbytelabel>&nbsp;&nbsp;<%=cdo.getColValue("tipoRenta")%> </p></td>
    <td colspan="4" align="center"><%=cdo.getColValue("nomEmpleado")%>
		 <p><cellbytelabel>Rata x Hora</cellbytelabel> &nbsp; <%=cdo.getColValue("rataHora")%> </p></td>
    <td colspan="2"><p># <cellbytelabel>de Cheque</cellbytelabel> &nbsp;<%=cdo.getColValue("numCheque")%> </p>
      <p><cellbytelabel>Fecha Pago</cellbytelabel>&nbsp;<%=cdo.getColValue("fechaPago")%></p></td>
  </tr>

  <tr align="center" class="TextHeader">
    <td colspan="3" align="center">* * * *   <cellbytelabel>I N G R E S O S</cellbytelabel>   * * * * </td>
    <td colspan="4" align="center">* * * *    <cellbytelabel>E G R E S O S</cellbytelabel>   * * * *</td>
  </tr>

  <tr align="center" class="TextHeader">
    <td width="21%"><cellbytelabel>Salario Regular</cellbytelabel></td>
    <td width="28%" align="center"><%=cdo.getColValue("salarioBase")%></td>
    <td width="3%">&nbsp;</td>
    <td width="17%">&nbsp;</td>
    <td width="9%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
    <td width="9%">&nbsp;</td>
  </tr>


  <tr class="TextRow01">
    <td align="left"> <cellbytelabel>Sueldo Base</cellbytelabel></td>
		 <%if(cod.equalsIgnoreCase("1")){%>
    <td align="right" colspan="1"><%=cdo.getColValue("salario_quinc")%></td>
		<% } else { %>
		 <td align="right" colspan="1"><%=cdo.getColValue("salBruto")%></td>
		 <% } %>
		<td align="center">&nbsp;</td>
    <td colspan="2" align="left"><cellbytelabel>Impuesto sobre la Renta</cellbytelabel> </td>
	<td align="right"><%=cdo.getColValue("impRen")%></td>
	<td align="center">&nbsp;</td>
  </tr>
    </tr>
    <tr class="TextRow02">
    <td align="left"> <cellbytelabel>Gasto de Representaci&oacute;n</cellbytelabel></td>
    <td align="right"><%=cdo.getColValue("gasRep")%></td>
	<td align="center">&nbsp;</td>
    <td colspan="2" align="left"> <cellbytelabel>Impuesto Gastos Rep</cellbytelabel>.</td>
	<td align="right"><%=cdo.getColValue("impGasto")%></td>
	<td align="center">&nbsp;</td>
	</tr>
    <tr class="TextRow01">
    <td align="left" colspan="2"></td>
    <td align="right"></td>
    <td align="left" colspan="2"><cellbytelabel>Seguro Social</cellbytelabel></td>
	<td align="right"><%=cdo.getColValue("segSoc")%></td>
	<td align="center">&nbsp;</td>
 <%if(!cdo.getColValue("codigo").equals("2")){%>

  <% if(!(alExtra.size()==0 && alDesc.size()==0)) {%>
      <tr class="TextRow01">
    <td align="left" colspan="2">
		<table width="100%" cellpadding="1" cellspacing="1">
		<%
		int listSize=13;
		if(alExtra.size()>alDesc.size()) listSize=alExtra.size();
		else listSize=alDesc.size();
		for(int extraI=0;extraI< listSize;extraI++){
		CommonDataObject cdoExtra=null;
		color = "TextRow02";
	  if (extraI % 2 == 0) color = "TextRow01";
		if(extraI<alExtra.size()) cdoExtra=(CommonDataObject) alExtra.get(extraI);
		if(cdoExtra!=null){
		totExtra += Double.parseDouble(cdoExtra.getColValue("monto"));
		contExtra ++;
		%>
		<tr class="<%=color%>"><td><%=cdoExtra.getColValue("descripcion")%></td><td><%=cdoExtra.getColValue("cantidad")%></td><td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdoExtra.getColValue("monto"))%></td></tr>
		<%}else{ %>
		<tr class="<%=color%>"><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
		<% } } %>
		</table></td><td class="<%=color%>">&nbsp;</td>
		<td colspan="3"><table width="100%" cellpadding="1" cellspacing="1">
		<%
		for(int extraI=0;extraI< listSize;extraI++){
		CommonDataObject cdoExtra=null;
		color = "TextRow02";
	  if (extraI % 2 == 0) color = "TextRow01";
		if(extraI<alDesc.size()) cdoExtra=(CommonDataObject) alDesc.get(extraI);
		if(cdoExtra!=null){
		totDesc += Double.parseDouble(cdoExtra.getColValue("monto"));
		contDesc ++;
		%>
		<tr class="<%=color%>"><td width="70%"><%=cdoExtra.getColValue("descripcion")%></td><td align="right"><%=CmnMgr.getFormattedDecimal("999,999,990.00",cdoExtra.getColValue("monto"))%></td></tr>
		<%}else{ %>
		<tr class="<%=color%>"><td width="70%">&nbsp;</td><td>&nbsp;</td></tr>
		<% } }%>
		</table></td>
   <td class="<%=color%>">&nbsp;</td>
  </tr>
  <% } %>
   <% } %>
</tr>

    <tr class="TextRow02">
    <td align="left"> <cellbytelabel>Total de Ingresos</cellbytelabel></td>
    <td align="right"><%=cdo.getColValue("ingTot")%></td>
	<td align="center">&nbsp;</td>
    <td colspan="2" align="left"> <cellbytelabel>Total de Egresos</cellbytelabel></td>
	<td align="right"><%=cdo.getColValue("totDed")%></td>
	<td align="center">&nbsp;</td>
  </tr>

  <%
  System.out.println("Geetesh Printing total deuciones"+cdo.getColValue("totDed"));
  %>

	  <tr class="TextRow01">
    <td align="right" colspan="6"> <cellbytelabel>Salario Neto</cellbytelabel></td>
    <td align="right"><%=cdo.getColValue("salNeto")%></td>
     </tr>

 <%
}
%>

</table>
<%=fb.formEnd(true)%>

</body>
</html>
<%
}//GET
%>
