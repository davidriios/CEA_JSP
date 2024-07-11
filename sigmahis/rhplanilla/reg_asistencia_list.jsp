<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
==================================================================================
**/
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
String cod 		= request.getParameter("cod");
String num 		= request.getParameter("num");
String anio 	= request.getParameter("anio");
String id 		= request.getParameter("id");

if (empId == null ) throw new Exception("El empleado no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{

sql = "select a.provincia, a.sigla, a.tomo, a.asiento, decode(a.tipo_trx,'1','Ausencia','2','Tardanza') descTipo, a.tipo_trx, a.secuencia, a.motivo_falta, to_char(a.fecha,'dd/mm/yyyy') as fecha,  to_char(a.hora_entrada,'hh:mi') hEntrada,  to_char(a.fecha_salida,'dd/mm/yyyy') as fecha_salida, to_char(a.hora_salida,'hh:mi') hSalida, a.comentario, a.accion, anio_des, a.mes_des, a.quincena_des, a.cod_planilla_des, anio_dev, a.mes_dev, a.quincena_dev, a.cod_planilla_dev, decode(a.estado_des,'PE','Pendiente','PA','Pagado','AN','Anulado','DS','Descontado') as estado_des,  decode(a.estado_dev,'PE','Pendiente','PA','Pagado','AN','Anulado','DV','Devuelto') as estado_dev, to_char(a.fecha_des,'dd/mm/yyyy') as fecha_des, a.tiempo, to_char(a.monto,'999,999,990.00') monto, to_char(a.fecha_dev,'dd/mm/yyyy') as fecha_dev, a.cantidad, a.vobo_estado, a.vobo_usuario, to_char(a.vobo_fecha,'dd/mm/yyyy') as voboFecha,  b.primer_nombre||' '||decode(b.sexo,'F',decode(b.apellido_casada, null,b.primer_apellido,decode(b.usar_apellido_casada,'S','DE '||b.apellido_casada, b.primer_apellido)), b.primer_apellido) as nomEmpleado , b.num_empleado as numEmpleado, b.provincia||'-'||decode(b.sigla,'0','')||b.tomo||' '||b.asiento as cedula,  to_char(b.rata_hora,'999,990.00') as rataHora, b.unidad_organi, c.descripcion as unidadName, d.descripcion as tipoextDesc, substr(p.nombre,10,10) as descripcion,  b.salario_base, b.rata_hora as rataHora,  b.emp_id, f.denominacion  from tbl_pla_aus_y_tard a, tbl_pla_empleado b,  tbl_sec_unidad_ejec c, tbl_pla_motivo_falta d , tbl_pla_cargo f, tbl_pla_planilla p where a.provincia=b.provincia and a.sigla=b.sigla and a.tomo=b.tomo and a.asiento=b.asiento and a.compania=b.compania(+) and  b.unidad_organi=c.codigo(+) and a.compania = c.compania and  a.motivo_falta = d.codigo and b.cargo = f.codigo and a.cod_planilla_des = p.cod_planilla(+) and a.compania = p.compania(+) and b.compania=f.compania  and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId+" order by a.fecha desc, a.secuencia desc";

al = SQLMgr.getDataList(sql);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Registro de Asistencia - '+document.title;

function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE ASISTENCIA"></jsp:param>
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
		<%
	if (al.size() > 0)
	{
	cdo = (CommonDataObject) al.get(0);

		%>

	<tr align="center" class="TextHeader">
			<td colspan="3">&nbsp;</td>
			<td colspan="6" align="center"><%=cdo.getColValue("nomEmpleado")%></td>
			<td colspan="3">&nbsp;</td>
	</tr>

	<tr align="center" class="TextHeader">
			<td colspan="3"># Empleado &nbsp; <%=cdo.getColValue("numEmpleado")%> </td>
			<td colspan="3" align="center">Cédula &nbsp; <%=cdo.getColValue("cedula")%></td>
			<td colspan="4" align="center">Cargo &nbsp; <%=cdo.getColValue("denominacion")%></td>
			<td colspan="2" align="center">Rata x Hora &nbsp; <%=cdo.getColValue("rataHora")%></td>
	</tr>

	<tr align="center" class="TextHeader">
			<td colspan="9" align="center">Detalle de Asistencia </td>
			<td colspan="3" align="center">Detalle de Monto</td>
	</tr>

	<tr class="TextHeader" align="center">
			<td width="5%">Sec. </td>
			<td width="8%">Fecha</td>
			<td width="5%">Cod.</td>
			<td width="10%">Tipo</td>
			<td width="18%">Motivo</td>
			<td width="10%">Estado&nbsp;</td>
			<td width="5%">Cantidad&nbsp;</td>
			<td width="10%">Monto&nbsp;</td>
			<td width="8%">Forma de Pago</td>
			<td width="5%">Año&nbsp;</td>
			<td width="5%">Periodo&nbsp;</td>
			<td width="11%">Planilla&nbsp;</td>
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
		<td align="left"><%=cdo.getColValue("secuencia")%></td>
		<td align="center"><%=cdo.getColValue("fecha")%></td>
		<td align="center"><%=cdo.getColValue("tipo_trx")%></td>
		 <td align="left"><%=cdo.getColValue("descTipo")%></td>
		<td align="center"><%=cdo.getColValue("tipoextDesc")%></td>

		<td align="center"><%=cdo.getColValue("estado_des")%></td>
		<td align="center"><%=cdo.getColValue("cantidad")%></td>
		<td align="right"><%=cdo.getColValue("monto")%></td>
		<td align="right"><%=cdo.getColValue("accion")%></td>
		<td align="center"><%=cdo.getColValue("anio_des")%></td>
		<td align="center"><%=cdo.getColValue("quincena_des")%></td>
		<td align="left"><%=cdo.getColValue("descripcion")%></td>
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
