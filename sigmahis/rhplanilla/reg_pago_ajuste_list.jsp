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

SecMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql  	= "";
String empId 	= request.getParameter("empId");
String cod_planilla 		= request.getParameter("cod_planilla"); 
String num_planilla		= request.getParameter("num_planilla"); 
String anio 	= request.getParameter("anio");
String id 		= request.getParameter("id");  
String secuencia 		= request.getParameter("secuencia");  
String mode =  request.getParameter("mode"); 
boolean viewMode= false;

if (empId == null ) throw new Exception("El empleado no es válido. Por favor intente nuevamente!");
if (mode == null ) mode="add";

if (request.getMethod().equalsIgnoreCase("GET"))
{

//sql = "select distinct(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, b.num_empleado as numEmpleado, f.descripcion as descripcion, b.emp_id as empId, b.estado, c.denominacion, g.descripcion as estadodesc, to_char(e.fecha_cheque,'dd/mm/yyyy') as fecha, e.estado, e.anio, e.cod_planilla, e.num_planilla, e.secuencia as codigo, b.num_empleado as numEmpleado, nvl(b.rata_hora,'1') as rataHora, b.ubic_seccion as grupo, e.emp_id as filtro, to_char((nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0)) - (nvl(e.otros_egr,0) + nvl(e.ausencia,0) + nvl(e.tardanza,0)),'999,999,990.00') as montoBruto,  to_char((nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0)) - (nvl(e.otros_egr,0) + nvl(e.ausencia,0) + nvl(e.tardanza,0) + nvl(e.imp_renta,0)+ nvl(e.imp_renta_gasto,0) + nvl(e.total_ded,0)),'999,999,990.00') as montoNeto, to_char( nvl(e.imp_renta,0)+nvl(e.imp_renta_gasto,0) + nvl(e.total_ded,0),'999,999,990.00') as montoDesc, p.nombre as nombrePla from tbl_pla_empleado b, tbl_sec_unidad_ejec f, tbl_pla_cargo c, tbl_pla_estado_emp g, tbl_pla_pago_ajuste e, tbl_pla_planilla p where b.compania = f.compania and b.ubic_seccion = f.codigo and b.compania = c.compania and b.cargo = c.codigo and b.estado = g.codigo and b.emp_id = e.emp_id and b.compania=e.cod_compania and e.cod_planilla = p.cod_planilla and e.cod_compania = p.compania and b.compania="+(String) session.getAttribute("_companyId")+" and e.emp_id="+empId+" and secuencia="+secuencia;	
	sql = "select distinct to_char(nvl(a.sal_bruto,0),'999,999,990.00') as salBruto, to_char(a.sal_neto,'999,999,990.00') as salNeto, to_char(nvl(a.ausencia,0),'999,999,990.00') as ausencia, to_char(nvl(a.seg_social,0)-nvl(a.seg_social_gasto,0),'999,990.00') as segSoc, to_char(nvl(a.seg_educativo,0),'999,990.00') as segEdu, to_char(nvl(a.imp_renta,0),'999,990.00') as impRen, to_char(nvl(a.fondo_com,0),'999,990.00') as fonCom, to_char(nvl(a.tardanza,0),'999,990.00') tardanza, to_char(nvl(a.otras_ded,00),'999,990.00') as otrasDed, to_char(nvl(a.total_ded,0) +  nvl(a.otros_egr,0),'999,999,990.00') as totDed, to_char(nvl(a.dev_multa,0),'999,990.00') as devMul, to_char(nvl(a.comision,0),'999,990.00'), to_char(nvl(a.gasto_rep,0),'99,999,990.00') as gasRep, to_char(nvl(a.ayuda_mortuoria,0),'999,990.00') as aMor, to_char(nvl(a.otros_ing,0),'999,999,990.00') as otrosIng, to_char(nvl(a.otros_egr,0),'999,999,990.00') as otrosEgr, to_char(a.alto_riesgo,'999,990.00') as altRiesgo, to_char(nvl(a.bonificacion,0),'999,990.00')bonificacion, to_char(nvl(a.extra,0),'999,999,990.00') as extra, to_char(nvl(a.prima_produccion,0),'999,999,990.00') as prima, to_char(nvl(a.indemnizacion,0),'99,999,990.00') indemnizacion, to_char(nvl(a.vacacion,0),'999,999,990.00')vacacion,to_char(nvl(a.pago_40porc,0),'999,999,990.00')pago_40porc,to_char(nvl(a.preaviso,0),'999,999,990.00')preaviso, to_char(nvl(a.xiii_mes,0),'999,999,990.00')decimo, to_char(nvl(a.prima_antiguedad,0),'999,999,990.00') primaAntiguedad,to_char(nvl(a.incentivo,0),'999,999,990.00')incentivo, 0 as aguiGas,to_char(nvl(a.tardanza,0),'999,999,990.00')tardanza, to_char(nvl(a.imp_renta_gasto,0),'999,990.00') as impRentaGasto, '' as cheque, to_char(nvl(a.seg_social_gasto,0),'999,990.00') as ssGasto, a.cod_planilla codigoPla, to_char((nvl(a.sal_bruto,0) + nvl(a.vacacion,0) + nvl(a.pago_40porc,0) + nvl(a.extra,0) + nvl(a.gasto_rep,0) + nvl(a.otros_ing,0) + nvl(a.otros_ing_fijos,0) + nvl(a.indemnizacion,0) + nvl(a.preaviso,0) + nvl(a.xiii_mes,0) + nvl(a.prima_antiguedad,0) + nvl(a.bonificacion,0) + nvl(a.incentivo,0) + nvl(a.prima_produccion,0)) - (nvl(a.ausencia,0) + nvl(a.tardanza,0)),'999,999,990.00')ingTot, 0 as salEsp, 0 as ssEsp, a.num_empleado as numEmpleado, to_char(a.num_cheque,'0000000') as numCheque, e.descripcion seccion, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(c.fecha_inicial,'dd-mm-yyyy') as fechaInicial, decode(a.provincia,0,' ',00,' ',a.provincia)||rpad(decode(a.sigla,'00','  ','0','  ',a.sigla),2,' ')||'-'||lpad(to_char(a.tomo),5,'0')||'-'|| lpad(to_char(a.asiento),6,'0') cedula, a.secuencia as codigo, b.num_ssocial, to_char(c.fecha_final,'dd-mm-yyyy') as fechaFinal, c.estado,b.nombre_empleado as nomEmpleado,to_char(a.fecha_cheque,'dd/mm/yyyy') as fecha, a.anio, a.cod_planilla, a.num_planilla, f.denominacion cargo, to_char(b.rata_hora,'999,990.00') as rataHora, b.tipo_renta||'-'||to_char(b.num_dependiente,'990') as tipoRenta, 'PLANILLA DE AJUSTES A - ' ||ltrim(d.nombre,18)||' del '||c.fecha_inicial||' al '||c.fecha_final as descripcion, b.num_cuenta, to_char(b.salario_base/2,'999,999,990.00') salarioBase,e.codigo codUnd from tbl_pla_pago_ajuste a, vw_pla_empleado b, tbl_pla_planilla_encabezado c, tbl_pla_planilla d, tbl_pla_cargo f, tbl_sec_unidad_ejec e where a.emp_id = b.emp_id and a.cod_compania = b.compania and a.cod_compania = c.cod_compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and a.anio = c.anio and a.cod_compania = e.compania and nvl(b.seccion,b.ubic_seccion) = e.codigo and a.cod_compania = f.compania and b.cargo = f.codigo and a.emp_id="+empId+" and a.num_planilla="+num_planilla+" and a.cod_planilla="+cod_planilla+" and a.anio = "+anio+ " and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.secuencia="+secuencia+" order by e.codigo, e.descripcion";

	
al = SQLMgr.getDataList(sql);
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Registro de Ajustes - '+document.title;
function printList()
{
	//abrir_ventana('../rhplanilla/print_list_comprobante_pago2.jsp?fp=CS&fg=AJ&empId=<%=empId%>&secuencia=<%=secuencia%>&anio=<%=anio%>&cod=<%=cod_planilla%>&num=<%=num_planilla%>');
	abrir_ventana('../rhplanilla/print_list_comp_pago_emp.jsp?fp=CS&fg=AJ&empId=<%=empId%>&secuencia=<%=secuencia%>&anio=<%=anio%>&cod=<%=cod_planilla%>&num=<%=num_planilla%>');
	
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="REGISTRO DE TRANSACCIONES PARA PLANILLA DE AJUSTE"></jsp:param>
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
<%=fb.hidden("cod_planilla",cod_planilla)%>
<%=fb.hidden("num_planilla",num_planilla)%>
<%=fb.hidden("anio",anio)%>
<table width="100%" cellpadding="1" cellspacing="1">
  <tr>
    <td align="right" colspan="7"><a href="javascript:printList()" class="Link00">[ Imprimir Comprobante ]</a></td>
  </tr>
   	<%
	if (al.size() > 0)
	{
	cdo = (CommonDataObject) al.get(0);

		%>
  
  <tr class="TextHeader">
    	<td colspan="3">&nbsp;</td>
    	<td colspan="4"><%=cdo.getColValue("nomEmpleado")%></td>
  </tr>
	
  <tr align="center" class="TextHeader">
    	<td colspan="2"># Empleado &nbsp; <%=cdo.getColValue("numEmpleado")%> </td>
    	<td colspan="1" align="center">Cédula &nbsp; <%=cdo.getColValue("cedula")%></td>
    	<td colspan="2" align="center">Cargo &nbsp; <%=cdo.getColValue("cargo")%></td>
    	<td align="center" colspan="2">Rata x Hora &nbsp; <%=cdo.getColValue("rataHora")%></td>  
  </tr>
  
  <tr align="center" class="TextHeader">
    	<td colspan="7" align="center">Detalle de Ajuste </td>
  </tr>
  
  <tr class="TextHeader" align="center">
    	<td width="5%">Sec. </td>
    	<td width="8%">Fecha</td>
    	<td width="10%">Estado</td>
    	<td width="29%">Planilla</td>
    	<td width="5%">Año</td>
    	<td width="5%">Cod.Planilla</td>
     	<td width="8%">No.Planilla</td>
    	<!-- 
		<td width="10%">Monto Bruto&nbsp;</td>
    	<td width="10%">Descuentos</td>
    	<td width="10%">Monto Neto</td>-->
     	     
  </tr>
<%
}
 %>
  <%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";						
%>

 
 <tr align="center" class="<%=color%>">
    <td align="left"><%=cdo.getColValue("codigo")%></td>
    <td align="center"><%=cdo.getColValue("fecha")%></td>
    <td align="center"><%=cdo.getColValue("estado")%></td>
		<td align="left"><%=cdo.getColValue("descripcion")%></td>
		<td align="right"><%=cdo.getColValue("anio")%></td>
   	<td align="center"><%=cdo.getColValue("cod_planilla")%></td>
   	<td align="center"><%=cdo.getColValue("num_planilla")%></td>
    <!--<td align="center"><%=cdo.getColValue("montoBruto")%></td>
	<td align="center"><%=cdo.getColValue("montoDesc")%></td>
    <td align="right"><%=cdo.getColValue("montoNeto")%></td>-->
    
   
  </tr>
  
  <tr align="center">
  <td colspan="7">
  <table width="100%" cellpadding="1" cellspacing="1">
	  <tr align="center" class="TextHeader">
		<td colspan="2">****I N G R E S O S****</td>
		<td align="left">&nbsp;</td>
		<td colspan="2">****E G R E S O S****</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">SALARIO REGULAR</td>
		<td align="center"><%=cdo.getColValue("salBruto")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">IMPUESTO SOBRE LA RENTA</td>
		<td align="center"><%=cdo.getColValue("impRen")%></td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">GASTO DE REPRESENTACION</td>
		<td align="center"><%=cdo.getColValue("gasRep")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">SEGURO SOCIAL</td>
		<td align="center"><%=cdo.getColValue("segSoc")%></td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">AUSENCIA</td>
		<td align="center"><%=cdo.getColValue("ausencia")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">SEGURO EDUC.</td>
		<td align="center"><%=cdo.getColValue("segEdu")%></td>
		<td align="left">&nbsp;</td>
	  </tr>
	   <tr align="center" class="<%=color%>">
		<td align="left">TARDANZAS</td>
		<td align="center"><%=cdo.getColValue("tardanza")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">IMPUESTO SOBRE LA RENTA GASTO</td>
		<td align="center"><%=cdo.getColValue("impRentaGasto")%></td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">SOBRETIEMPO</td>
		<td align="center"><%=cdo.getColValue("extra")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">OTROS EGRESOS</td>
		<td align="center"><%=cdo.getColValue("otrosEgr")%></td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">OTROS INGRESOS</td>
		<td align="center"><%=cdo.getColValue("otrosIng")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">OTRAS DED.</td>
		<td align="center"><%=cdo.getColValue("otrasDed")%></td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">VACACIONES</td>
		<td align="center"><%=cdo.getColValue("vacacion")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">SEGURO SOCIAL GASTO REP.</td>
		<td align="center"><%=cdo.getColValue("ssGasto")%></td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">XIII MES</td>
		<td align="center"><%=cdo.getColValue("decimo")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">PRIMA DE PRODUCCIÓN</td>
		<td align="center"><%=cdo.getColValue("prima")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="center">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">BONIFICACIÓN</td>
		<td align="center"><%=cdo.getColValue("bonificacion")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">INCENTIVO</td>
		<td align="center"><%=cdo.getColValue("incentivo")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">INDEMNIZACION</td>
		<td align="center"><%=cdo.getColValue("indemnizacion")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">PREAVISO</td>
		<td align="center"><%=cdo.getColValue("preaviso")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">40% DE SALARIO</td>
		<td align="center"><%=cdo.getColValue("pago_40porc")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="left">PRIMA ANTIGUEDAD</td>
		<td align="center"><%=cdo.getColValue("primaAntiguedad")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">&nbsp;</td>
		<td align="center">&nbsp;</td>
		<td align="left">&nbsp;</td>
	  </tr>
	  
	  <tr align="center" class="TextRow02">
		<td align="left">TOTAL INGRESOS ====>></td>
		<td align="center"><%=cdo.getColValue("ingTot")%></td>
		<td align="left">&nbsp;</td>
		<td align="left">TOTAL DE EGRESOS====>></td>
		<td align="center"><%=cdo.getColValue("totDed")%></td>
		<td align="left">&nbsp;</td>
		
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="right" colspan="5">INGRESOS NETOS====>></td>
		<td><%=cdo.getColValue("salNeto")%></td>
	  </tr>
	  <tr align="center" class="<%=color%>">
		<td align="right" colspan="6">&nbsp;</td>
	  </tr>

	</table>
  </td>
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
