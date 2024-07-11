
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" 		scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" 		scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" 	scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" 		scope="page" 		class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" 				scope="page" 		class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" 		scope="page" 		class="issi.admin.SQLMgr" />
<jsp:useBean id="AEmpMgr" 		scope="page" 		class="issi.rhplanilla.AccionesEmpleadoMgr" />

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
AEmpMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String emp_id = request.getParameter("emp_id");
String paccion = request.getParameter("paccion");
String fecha_egreso = request.getParameter("fecha_egreso");
String id ="";
String anio ="";
boolean viewMode = false;

if (mode == null) mode = "add";
if (fg == null) fg = "";
if (fecha_egreso == null) fecha_egreso = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
CommonDataObject cdoT = new CommonDataObject();
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if((emp_id != null && !emp_id.trim().equals(""))&&(fecha_egreso != null && !fecha_egreso.trim().equals("")&& !fecha_egreso.trim().equals("null"))){
		sql = "select to_char(a.fecha_inicio, 'dd/mm/yyyy') fecha_inicio, a.anio, a.secuencia, a.periodo, a.provincia, a.sigla, a.tomo, a.asiento, a.cod_compania, a.sal_bruto, a.gasto_rep, a.vacaciones, a.xiii_mes, a.bonificacion, a.incentivo, a.otros, a.periodos, a.prima_produccion, a.num_empleado, a.emp_id, b.descripcion mes, decode(b.quincena1, a.periodo, 'PRIMERA', 'SEGUNDA') quincena, a.paga_vac, a.paga_dec from tbl_pla_li_pagos a, tbl_pla_vac_parametro b where cod_compania = "+(String) session.getAttribute("_companyId")+" and emp_id = "+emp_id+ " and a.num_empleado = '"+request.getParameter("num_empleado")+"' and trunc(a.fecha_inicio) = to_date('"+fecha_egreso+"','dd/mm/yyyy') and (b.quincena1 = a.periodo or b.quincena2 = a.periodo) order by anio, periodo";
		al = SQLMgr.getDataList(sql);
		sql = "select sum(sal_bruto) sal_bruto, sum(gasto_rep) gasto_rep, sum(vacaciones) vacaciones, sum(xiii_mes) xiii_mes, sum(bonificacion) bonificacion, sum(incentivo) incentivo, sum(otros) otros, sum(periodos) periodos, sum(prima_produccion) prima_produccion, sum(num_empleado) num_empleado from tbl_pla_li_pagos where cod_compania = "+(String) session.getAttribute("_companyId")+" and emp_id = "+emp_id+ " and num_empleado = '"+request.getParameter("num_empleado")+"' and trunc(fecha_inicio) = to_date('"+fecha_egreso+"','dd/mm/yyyy')";
		cdoT = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{	
	//calc();
	parent.newHeight();
}


function calcTotales(a)
{
	var iCounter = 0;
	var size = parseInt(document.form1.keySize.value);
	var sal_bruto = 0.00, gasto_rep = 0.00, prima_produccion = 0.00, xiii_mes = 0.00, vacaciones = 0.00, incentivo = 0.00, bonificacion = 0.00, otros = 0.00;
	var t_sal_bruto = 0.00, t_gasto_rep = 0.00, t_prima_produccion = 0.00, t_xiii_mes = 0.00, t_vacaciones = 0.00, t_incentivo = 0.00, t_bonificacion = 0.00, t_otros = 0.00;
	for(i=0;i<size;i++){
		sal_bruto 				= eval('document.form1.sal_bruto'+i).value;
		gasto_rep 				= eval('document.form1.gasto_rep'+i).value;
		prima_produccion	= eval('document.form1.prima_produccion'+i).value;
		xiii_mes 					= eval('document.form1.xiii_mes'+i).value;
		vacaciones 				= eval('document.form1.vacaciones'+i).value;
		incentivo 				= eval('document.form1.incentivo'+i).value;
		bonificacion 			= eval('document.form1.bonificacion'+i).value;
		otros 						= eval('document.form1.otros'+i).value;
		if(!isNaN(sal_bruto) && sal_bruto!='') t_sal_bruto += parseFloat(sal_bruto);
		if(!isNaN(gasto_rep) && gasto_rep!='') t_gasto_rep += parseFloat(gasto_rep);
		if(!isNaN(prima_produccion) && prima_produccion!='') t_prima_produccion += parseFloat(prima_produccion);
		if(!isNaN(xiii_mes) && xiii_mes!='') t_xiii_mes += parseFloat(xiii_mes);
		if(!isNaN(vacaciones) && vacaciones!='') t_vacaciones += parseFloat(vacaciones);
		if(!isNaN(incentivo) && incentivo!='') t_incentivo += parseFloat(incentivo);
		if(!isNaN(bonificacion) && bonificacion!='') t_bonificacion += parseFloat(bonificacion);
		if(!isNaN(otros) && otros!='') t_otros += parseFloat(otros);
	}
	document.form1.sal_bruto.value 				= t_sal_bruto.toFixed(2);
	document.form1.gasto_rep.value 				= t_gasto_rep.toFixed(2);
	document.form1.prima_produccion.value	= t_prima_produccion.toFixed(2);
	document.form1.xiii_mes.value 				= t_xiii_mes.toFixed(2);
	document.form1.vacaciones.value 			= t_vacaciones.toFixed(2);
	document.form1.incentivo.value 				= t_incentivo.toFixed(2);
	document.form1.bonificacion.value 		= t_bonificacion.toFixed(2);
	document.form1.otros.value 						= t_otros.toFixed(2);
	if (iCounter > 0) return true;
	else return false;
}

function calcThis(i){
	var salario=0.00, gasto_rep = 0.00, s_especie = 0.00;
	salario = eval('document.form1.sal_bruto'+i).value;
	gasto_rep = eval('document.form1.gasto_rep'+i).value;
	s_especie = eval('document.form1.salario_especie'+i).value;
	if(!isNaN(salario) && salario!='') calc();
	else if(salario != '' && isNaN(salario)){
		alert('Introduzca valores numéricos1');
		eval('document.form1.sal_bruto'+i).value = '';
	}
	if(!isNaN(gasto_rep) && gasto_rep!='') calc();
	else if(gasto_rep != '' && isNaN(gasto_rep)){
		alert('Introduzca valores numéricos2');
		eval('document.form1.gasto_rep'+i).value = '';
	}
	if(!isNaN(s_especie) && s_especie!='') calc();
	else if(s_especie != '' && isNaN(s_especie)){
		alert('Introduzca valores numéricos3');
		eval('document.form1.salario_especie'+i).value = '';
	}
}

function doSubmit(value)
{
	var fg = '<%=fg%>';
	document.form1.baction.value = value;
	document.form1.emp_id.value = parent.document.form1.emp_id.value;
	document.form1.segundo_nombre.value = parent.document.form1.segundo_nombre.value;
	document.form1.segundo_apellido.value = parent.document.form1.segundo_apellido.value;
	document.form1.primer_nombre.value = parent.document.form1.primer_nombre.value;
	document.form1.primer_apellido.value = parent.document.form1.primer_apellido.value;
	document.form1.provincia.value = parent.document.form1.provincia.value;
	document.form1.sigla.value = parent.document.form1.sigla.value;
	document.form1.tomo.value = parent.document.form1.tomo.value;
	document.form1.asiento.value = parent.document.form1.asiento.value;
	document.form1.num_empleado.value = parent.document.form1.num_empleado.value;

	if (!parent.form1Validation()) return false;
  else document.form1.submit();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>

<%=fb.hidden("emp_id","")%>
<%=fb.hidden("segundo_nombre","")%>
<%=fb.hidden("segundo_apellido","")%>
<%=fb.hidden("primer_nombre","")%>
<%=fb.hidden("primer_apellido","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("num_empleado","")%>
<%=fb.hidden("fecha_egreso",""+fecha_egreso)%>


<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td>A&ntilde;o</td>
	<td>Mes</td>
	<td>Quincena</td>
	<td>Salario</td>
	<td>Gasto Rep.</td>
	<td>Prima de Producci&oacute;n</td>
	<td>XIII Mes</td>
  <td>Paga XIII</td>
	<td>Vacaci&oacute;n</td>
  <td>Paga Vac.</td>
	<td>Incentivo</td>
	<td>Bonificaci&oacute;n</td>
	<td>Otros</td>
</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("periodo"+i,cdo.getColValue("periodo"))%>
<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
<%=fb.hidden("fecha_inicio"+i,cdo.getColValue("fecha_inicio"))%>
<tr class="<%=color%>" align="center">
  <td>
	<%=cdo.getColValue("anio")%>
  </td>
  <td>
	<%=cdo.getColValue("mes")%>
  </td>
  <td>
	<%=cdo.getColValue("quincena")%>
  </td>
	<td>
	<%=fb.decBox("sal_bruto"+i,cdo.getColValue("sal_bruto"),true,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('sb')\"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("gasto_rep"+i,cdo.getColValue("gasto_rep"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('gr')\"","",false,"")%>
  </td>
  <td>
	<%=fb.decBox("prima_produccion"+i,cdo.getColValue("prima_produccion"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('pp')\"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("xiii_mes"+i,cdo.getColValue("xiii_mes"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('xm')\"","",false,"")%>
  </td>
	<td>
  <%=fb.checkbox("paga_dec"+i,cdo.getColValue("paga_dec"),(cdo.getColValue("paga_dec").equals("S")),false,"text10","","")%>
  </td>
  <td>
	<%=fb.decBox("vacaciones"+i,cdo.getColValue("vacaciones"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('v')\"","",false,"")%>
  </td>
	<td>
  <%=fb.checkbox("paga_vac"+i,cdo.getColValue("paga_vac"),(cdo.getColValue("paga_vac").equals("S")),false,"text10","","")%>
  </td>
	<td>
	<%=fb.decBox("incentivo"+i,cdo.getColValue("incentivo"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('i')\"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("bonificacion"+i,cdo.getColValue("bonificacion"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('b')\"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("otros"+i,cdo.getColValue("otros"),false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onChange=\"javascript:calcTotales('o')\"","",false,"")%>
  </td>
</tr>
<%
}
%>
<tr class="textHeader02" align="center">
  <td colspan="3">&nbsp;</td>
	<td>
	<%=fb.decBox("sal_bruto",cdoT.getColValue("sal_bruto"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("gasto_rep",cdoT.getColValue("gasto_rep"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
  <td>
	<%=fb.decBox("prima_produccion",cdoT.getColValue("prima_produccion"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("xiii_mes",cdoT.getColValue("xiii_mes"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>
  </td>
  <td>
	<%=fb.decBox("vacaciones",cdoT.getColValue("vacaciones"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>
  </td>
	<td>
	<%=fb.decBox("incentivo",cdoT.getColValue("incentivo"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("bonificacion",cdoT.getColValue("bonificacion"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
	<td>
	<%=fb.decBox("otros",cdoT.getColValue("otros"),false,false,viewMode,6, 8.2,null,null,"","",false,"")%>
  </td>
</tr>

</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{
	System.out.println("_________________________________________________________________");
	
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	al.clear();
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
		cdo.addColValue("emp_id", request.getParameter("emp_id"));
		cdo.addColValue("num_empleado", request.getParameter("num_empleado"));
		if (request.getParameter("fecha_inicio"+i) != null && !request.getParameter("fecha_inicio"+i).equals("")) cdo.addColValue("fecha_inicio", request.getParameter("fecha_inicio"+i));
		if (request.getParameter("secuencia"+i) != null && !request.getParameter("secuencia"+i).equals("")) cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
		if (request.getParameter("periodo"+i) != null && !request.getParameter("periodo"+i).equals("")) cdo.addColValue("periodo", request.getParameter("periodo"+i));
		if (request.getParameter("anio"+i) != null && !request.getParameter("anio"+i).equals("")) cdo.addColValue("anio", request.getParameter("anio"+i));
		if (request.getParameter("mes"+i) != null && !request.getParameter("mes"+i).equals("")) cdo.addColValue("mes", request.getParameter("mes"+i));
		if (request.getParameter("quincena"+i) != null && !request.getParameter("quincena"+i).equals("")) cdo.addColValue("quincena", request.getParameter("quincena"+i));
		if (request.getParameter("sal_bruto"+i) != null && !request.getParameter("sal_bruto"+i).equals("")) cdo.addColValue("sal_bruto", request.getParameter("sal_bruto"+i));
		if (request.getParameter("gasto_rep"+i) != null && !request.getParameter("gasto_rep"+i).equals("")) cdo.addColValue("gasto_rep", request.getParameter("gasto_rep"+i));
		if (request.getParameter("prima_produccion"+i) != null && !request.getParameter("prima_produccion"+i).equals("")) cdo.addColValue("prima_produccion", request.getParameter("prima_produccion"+i));
		if (request.getParameter("xiii_mes"+i) != null && !request.getParameter("xiii_mes"+i).equals("")) cdo.addColValue("xiii_mes", request.getParameter("xiii_mes"+i));
		if (request.getParameter("vacaciones"+i) != null && !request.getParameter("vacaciones"+i).equals("")) cdo.addColValue("vacaciones", request.getParameter("vacaciones"+i));
		if (request.getParameter("incentivo"+i) != null && !request.getParameter("incentivo"+i).equals("")) cdo.addColValue("incentivo", request.getParameter("incentivo"+i));
		if (request.getParameter("bonificacion"+i) != null && !request.getParameter("bonificacion"+i).equals("")) cdo.addColValue("bonificacion", request.getParameter("bonificacion"+i));
		if (request.getParameter("otros"+i) != null && !request.getParameter("otros"+i).equals("")) cdo.addColValue("otros", request.getParameter("otros"+i));
		if (request.getParameter("paga_dec"+i) != null && !request.getParameter("paga_dec"+i).equals("")) cdo.addColValue("paga_dec", "S");
		else cdo.addColValue("paga_dec", "N");
		if (request.getParameter("paga_vac"+i) != null && !request.getParameter("paga_vac"+i).equals("")) cdo.addColValue("paga_vac", "S");
		else cdo.addColValue("paga_vac", "N");
		
		try{
			al.add(cdo);
		} catch (Exception e){
			System.out.println("Unable to add item...");
		}
	}

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		AEmpMgr.updatePagos(al);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%
	if(AEmpMgr.getErrCode().equals("1")){
	%>
		alert('<%=AEmpMgr.getErrMsg()%>');
		window.location = '../rhplanilla/reg_liquidacion_det_acum.jsp?emp_id=<%=request.getParameter("emp_id")%>&fecha_egreso=<%=request.getParameter("fecha_egreso")%>&num_empleado=<%=request.getParameter("num_empleado")%>';
	<%
	} else throw new Exception(AEmpMgr.getErrMsg());
	%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
