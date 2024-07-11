<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htextra" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htause" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htdesc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htajus" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExtra" scope="session" class="java.util.Vector" />
<jsp:useBean id="vAuse" scope="session" class="java.util.Vector" />
<jsp:useBean id="vDesc" scope="session" class="java.util.Vector" />
<jsp:useBean id="htajusRe" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList au = new ArrayList();
ArrayList de = new ArrayList();
ArrayList aj = new ArrayList();
String key = "";
StringBuffer sql = new StringBuffer();
String appendFilter = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String anio = request.getParameter("anio");
String planilla = request.getParameter("planilla");
String periodo = request.getParameter("periodo");
String seccion = request.getParameter("seccion");
String empId = request.getParameter("empId");
String tipoTrx = request.getParameter("tipoTrx");
String tipoId = request.getParameter("tipo");
String recargo = request.getParameter("recargo");
String fecha="",fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anioC = cDateTime.substring(6,10);
String mes = cDateTime.substring(3,5);
String dia = cDateTime.substring(0,2);
int per = 0;
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;
int extraLastLineNo = 0;
int auseLastLineNo = 0;
int descLastLineNo = 0;
int ajusLastLineNo = 0;

boolean viewMode = false;
if (tab == null) tab = "0";
int day = Integer.parseInt(dia);
int mont = Integer.parseInt(mes);

if(day >16) per = mont*2;else per =  mont*2-1;

if (anio == null) anio = anioC;
if (periodo == null) periodo = ""+per;
if (planilla == null) planilla = "1";
if (seccion == null) seccion = "";
if (tipoTrx == null) tipoTrx = "";
if (empId == null) empId = "";
if (tipoId == null) tipoId = "";
if (recargo == null) recargo = "";
if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (!seccion.equals(""))appendFilter += " and e.ubic_seccion =  "+seccion;
if (!empId.equals(""))appendFilter += " and e.emp_id = "+empId;

if (request.getMethod().equalsIgnoreCase("GET"))
{
   if (mode.equalsIgnoreCase("view"))
	{
		if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
		if (periodo == null) throw new Exception("El Periodo no es válido. Por favor intente nuevamente!");
	    if (planilla == null) throw new Exception("El Código de Planilla no es válido. Por favor intente nuevamente!");
	htextra.clear();
	htause.clear();
	htajus.clear();
	htdesc.clear();
	htajusRe.clear();

	sql.append("select e.num_empleado as numero, e.primer_nombre||' '||decode(e.sexo, 'F', decode(e.apellido_casada, null,e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)),e.primer_apellido) nombre, s.compania, s.provincia, s.sigla, s.tomo, s.asiento, s.codigo, to_char(s.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, s.anio_pag, s.quincena_pag, s.cod_planilla_pag, s.estado_pag, s.cantidad_aprob as cantidad, to_char(s.monto,'999,999,990.00') as monto, s.vobo_estado, s.the_codigo, t.descripcion, e.emp_id as empId, e.provincia, e.sigla, e.tomo, e.asiento  from tbl_pla_empleado e, tbl_pla_t_extraordinario s, tbl_pla_t_horas_ext t where s.anio_pag = "+anio+" and s.quincena_pag = ");
	sql.append(periodo);
	sql.append(" and s.cod_planilla_pag = ");
	sql.append(planilla);
	sql.append(" and s.estado_pag = 'PE' and e.estado <> 3   and not exists  (select null from tbl_pla_planilla_encabezado where cod_compania = s.compania and anio = s.anio_pag and cod_planilla = s.cod_planilla_pag and num_planilla = s.quincena_pag)  and e.compania=");
	sql.append((String) session.getAttribute("_companyId"));

	if (!tipoTrx.equals("")){
	sql.append(" and to_char(s.the_codigo) = ");
	sql.append(tipoTrx);}

	if (!tipoId.equals("")){sql.append(" and (nvl(s.comentario,'.') like '%");
	sql.append(tipoId);
	sql.append("%'  and a.accion =");
	sql.append(tipoId);}
	if (!recargo.equals("")){
	sql.append(" and (NVL(s.comentario,'.') LIKE decode(NVL(");
	sql.append(recargo);
	sql.append(",'N'),'S','* PAGO DE RECARGO POR PROGRAMA DE TURNOS','%'))");}
	sql.append(appendFilter);
	sql.append(" and s.vobo_estado = 'N'  and s.compania=e.compania and s.emp_id = e.emp_id and s.the_codigo=t.codigo order by e.num_empleado");

	al=SQLMgr.getDataList(sql.toString());
	extraLastLineNo=al.size();

		for(int i=1; i<=al.size(); i++)
		{
			CommonDataObject cdo1 = (CommonDataObject) al.get(i-1);

			if(i<10)  key = "00"+i;
			else if(i<100)key = "0"+i;
			else key= ""+i;
			cdo1.addColValue("key",key);
			try
			{
				htextra.put(key,cdo1);
				vExtra.addElement(cdo1.getColValue("codigo"));
			}//End Try
			catch (Exception e)
			{
			System.err.println(e.getMessage());
			}//End Catch
		}//End for


  	sql = new StringBuffer();
	sql.append("select a.compania, a.provincia,a.sigla, a.tomo, a.asiento, e.num_empleado as numero, e.primer_nombre||' '|| decode(e.sexo, 'F' , decode(e.apellido_casada, null, e.primer_apellido, decode(e.usar_apellido_casada,'S','DE '|| e.apellido_casada, e.primer_apellido)), e.primer_apellido) nombre, a.tipo_trx, a.fecha, a.secuencia, a.vobo_estado, a.cantidad, a.tiempo, a.accion, decode(a.accion,'DS','DESCONTAR','DV','DEVOLVER','ND','NO DESCONTAR') accionDesc, a.motivo_falta, a.anio_des, a.quincena_des,	a.cod_planilla_des, to_char(a.monto,'999,999,990.00') as monto, e.emp_id as empId, e.primer_nombre, f.descripcion, a.estado_des, to_char(a.fecha,'dd/mm/yyyy') as fecha from tbl_pla_aus_y_tard a, tbl_pla_empleado e, tbl_pla_motivo_falta f where a.anio_des = ");
	sql.append(anio);
	sql.append(" and a.quincena_des = ");
	sql.append(periodo);
	sql.append(" and a.cod_planilla_des = ");
	sql.append(planilla);
	sql.append(" and a.estado_des = 'PE' and e.estado <> 3 and e.compania=");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append( appendFilter);
	sql.append(" and not exists  (select null from tbl_pla_planilla_encabezado where cod_compania = a.compania and anio = a.anio_des and cod_planilla = a.cod_planilla_des and num_planilla = a.quincena_des)  and a.accion in ('DS','DV','ND') and a.compania=e.compania and a.emp_id=e.emp_id and a.estado_des = 'PE' and a.vobo_estado = 'N' and (f.codigo=a.motivo_falta)  order by e.num_empleado");
		au=SQLMgr.getDataList(sql.toString());
		auseLastLineNo= au.size();
		for(int i=1; i<=au.size(); i++)
		{
		CommonDataObject cdo1 = (CommonDataObject) au.get(i-1);
		if(i<10)  key = "00"+i;
		else if(i<100)key = "0"+i;
		else  key= ""+i;
		cdo1.addColValue("key",key);
		try {
		htause.put(key,cdo1);
		vAuse.addElement(cdo1.getColValue("secuencia"));
		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}		}//End for
		sql = new StringBuffer();
		sql.append("select a.compania, a.provincia,a.sigla, a.tomo, a.asiento, e.num_empleado as numero, e.emp_id as empId, e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada, null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '|| e.apellido_casada,e.primer_apellido)),e.primer_apellido) nombre, t.descripcion, a.codigo, a.tipo_trx, to_char(a.monto,'999,999,990.00') as monto, a.cantidad, a.anio_pago, a.quincena_pago, a.cod_planilla_pago, a.estado_pago, a.accion, a.vobo_estado, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.accion,'PA','PAGAR','DE','DESCONTAR') as accionDesc from tbl_pla_empleado e, tbl_pla_tipo_transaccion t, tbl_pla_transac_emp a where a.anio_pago = ");
	sql.append(anio);
	sql.append(" and a.quincena_pago = ");
	sql.append(periodo);
	sql.append(" and a.cod_planilla_pago = ");
	sql.append(planilla);
	sql.append(" and a.estado_pago <> 'PA' and a.vobo_estado = 'N' and ((a.accion = 'PA' and a.aprobacion_estado = 'S') or (a.accion = 'DE')) and e.estado <> 3 and a.compania=e.compania and a.emp_id=e.emp_id and e.compania=");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(appendFilter);
	sql.append("  and not exists  (select null from tbl_pla_planilla_encabezado where cod_compania = a.compania and anio = a.anio_pago and cod_planilla = a.cod_planilla_pago and num_planilla = a.quincena_pago) and t.codigo = a.tipo_trx and t.compania = a.compania order by e.num_empleado");
		de=SQLMgr.getDataList(sql.toString());
		descLastLineNo= de.size();
		for(int i=1; i<=de.size(); i++)
		{
		CommonDataObject cdo2 = (CommonDataObject) de.get(i-1);
		if(i<10)  key = "00"+i;
		else if(i<100)key = "0"+i;
		else  key= ""+i;
		cdo2.addColValue("key",key);
		try {
		htdesc.put(key,cdo2);
		vDesc.addElement(cdo2.getColValue("codigo"));
		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}//End Catch
		}//End for
	sql = new StringBuffer();
	sql.append("select distinct(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, b.num_empleado as numEmpleado,  b.emp_id as empId, e.anio, e.vobo_estado, e.cod_planilla, substr(p.nombre,10,5)||'-'||e.anio||'-'||e.num_planilla as codigoPla, e.num_planilla, e.num_cheque as cheque, w.imprimir, w.paseConta, e.cheque_impreso as impreso, decode(e.estado, 'PE' , 'PENDIENTE' , 'AC' , 'ACTUALIZADO' ,'AP','APROBADO') as estado, to_char(e.fecha_cheque,'dd/mm/yyyy') as fecha, e.secuencia as codigo, b.num_empleado as numEmpleado, nvl(b.rata_hora,'1') as rataHora, b.ubic_seccion as grupo, e.emp_id as filtro, to_char(nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0) - (nvl(e.otros_egr,0) + nvl(e.ausencia,0) + nvl(e.tardanza,0)),'999,999,990.00') as montoBruto,  to_char(nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0) - (nvl(e.otros_egr,0) + nvl(e.ausencia,0) + nvl(e.tardanza,0) + nvl(e.seg_social,0) + nvl(e.seg_educativo,0) + nvl(e.imp_renta,0) + nvl(e.total_ded,0)),'999,999,990.00') as montoNeto, to_char(nvl(e.seg_social,0) + nvl(e.seg_educativo,0) + nvl(e.imp_renta,0) + nvl(e.total_ded,0),'999,999,990.00') as montoDesc, p.nombre as nombrePla from tbl_pla_empleado b, tbl_pla_pago_ajuste e, tbl_pla_planilla p , (select 'S' as imprimir, 'SI' as paseConta, c.num_cheque from tbl_pla_parametros b, tbl_con_cheque c where b.cod_compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and c.cod_compania = b.cod_compania and c.cod_banco = b.cod_banco and c.cuenta_banco = b.cuenta_bancaria ) w where b.emp_id = e.emp_id and b.compania=e.cod_compania and e.cod_planilla = p.cod_planilla and e.cod_compania = p.compania and e.anio  = ");
	sql.append(anio);
	sql.append(" and e.num_planilla = ");
	sql.append(periodo);
	sql.append(" and e.cod_planilla = ");
	sql.append(planilla);
	sql.append(" and e.estado = 'PE' and e.vobo_estado = 'N' and b.compania=");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(appendFilter);
	sql.append(" and e.num_cheque = w.num_cheque(+) order by b.emp_id");

		aj=SQLMgr.getDataList(sql.toString());
		ajusLastLineNo= aj.size();
		for(int i=1; i<=aj.size(); i++)
		{
		CommonDataObject cdo3 = (CommonDataObject) aj.get(i-1);
		if(i<10)  key = "00"+i;
		else if(i<100)key = "0"+i;
		else  key= ""+i;
		cdo3.addColValue("key",key);
		try {htajus.put(key,cdo3);

		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}//End Catch
		}//End for
		sql = new StringBuffer();
	sql.append("select distinct(b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento) as cedula, b.provincia, b.sigla, b.tomo, b.asiento, b.compania,  b.primer_nombre||' '||b.primer_apellido  as nombre ,b.primer_nombre, b.primer_apellido, b.ubic_seccion as seccion, b.num_empleado as numEmpleado,  b.emp_id as empId, e.anio, e.vobo_estado, e.cod_planilla, substr(p.nombre,10,5)||'-'||e.anio||'-'||e.num_planilla as codigoPla, e.num_planilla, e.num_cheque as cheque, w.imprimir, w.paseConta, e.cheque_impreso as impreso, decode(e.estado, 'PE' , 'PENDIENTE' , 'AC' , 'ACTUALIZADO' ,'AP','APROBADO') as estado, to_char(e.fecha_cheque,'dd/mm/yyyy') as fecha, e.secuencia as codigo, b.num_empleado as numEmpleado, nvl(b.rata_hora,'1') as rataHora, b.ubic_seccion as grupo, e.emp_id as filtro, to_char(nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0) - (nvl(e.otros_egr,0) + nvl(e.ausencia,0) + nvl(e.tardanza,0)),'999,999,990.00') as montoBruto,  to_char(nvl(e.sal_bruto,0) + nvl(e.vacacion,0) + nvl(e.pago_40porc,0) + nvl(e.extra,0) + nvl(e.gasto_rep,0) + nvl(e.otros_ing,0) + nvl(e.otros_ing_fijos,0) + nvl(e.indemnizacion,0) + nvl(e.preaviso,0) + nvl(e.xiii_mes,0) + nvl(e.prima_antiguedad,0) + nvl(e.bonificacion,0) + nvl(e.incentivo,0) + nvl(e.prima_produccion,0) - (nvl(e.otros_egr,0) + nvl(e.ausencia,0) + nvl(e.tardanza,0) + nvl(e.seg_social,0) + nvl(e.seg_educativo,0) + nvl(e.imp_renta,0) + nvl(e.total_ded,0)),'999,999,990.00') as montoNeto, to_char(nvl(e.seg_social,0) + nvl(e.seg_educativo,0) + nvl(e.imp_renta,0) + nvl(e.total_ded,0),'999,999,990.00') as montoDesc, p.nombre as nombrePla from tbl_pla_empleado b, tbl_pla_pago_ajuste e, tbl_pla_planilla p , (select 'S' as imprimir, 'SI' as paseConta, c.num_cheque from tbl_pla_parametros b, tbl_con_cheque c where b.cod_compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(" and c.cod_compania = b.cod_compania and c.cod_banco = b.cod_banco and c.cuenta_banco = b.cuenta_bancaria ) w where b.emp_id = e.emp_id and b.compania=e.cod_compania and e.cod_planilla = p.cod_planilla and e.cod_compania = p.compania and e.anio  = ");
	sql.append(anio);
	sql.append(" and e.num_planilla = ");
	sql.append(periodo);
	sql.append(" and e.cod_planilla = ");
	sql.append(planilla);
	sql.append(" and e.estado = 'PE' and e.vobo_estado = 'S' and e.actualizar = 'N'  and b.compania=");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(appendFilter);
	sql.append(" and e.num_cheque = w.num_cheque(+) order by b.emp_id");

		aj=SQLMgr.getDataList(sql.toString());
		ajusLastLineNo= aj.size();
		for(int i=1; i<=aj.size(); i++)
		{
		CommonDataObject cdo3 = (CommonDataObject) aj.get(i-1);
		if(i<10)  key = "00"+i;
		else if(i<100)key = "0"+i;
		else  key= ""+i;
		cdo3.addColValue("key",key);
		try {htajusRe.put(key,cdo3);

		}//End Try
		catch (Exception e)
		{
		System.err.println(e.getMessage());
		}//End Catch
		}//End for
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;
function doAction(){verCheck();verCheckRe();}
function verCheck()
{
var size = eval('document.form3.ajusSize').value;
var tb = eval('document.form3.tab').value;
var totalCheck = 0;
	if((tb==3)&&(size>0))
	{
		for (i=0;i<parseInt(size);i++)
		{
			if (eval('document.form3.check'+i).checked)
			totalCheck += 1;
		}
		document.getElementById("cont").value=totalCheck;
	}
}
function verCheckRe()
{
var size = eval('document.form4.ajusSizeRe').value;
var tb = eval('document.form4.tab').value;
var totalCheck = 0;
	if((tb==4)&&(size>0))
	{
		for (i=0;i<parseInt(size);i++)
		{
			if (eval('document.form4.check'+i).checked)
			totalCheck += 1;
		}
		document.getElementById("contRe").value=totalCheck;
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
			<tr class="TextRow02">
			  <td>&nbsp;</td>
			</tr>
			<tr class="TextRow02">
			  <td>&nbsp;</td>
			</tr>
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
			<tr>
				<td>

<!-- MAIN DIV START HERE -->

		<div id="dhtmlgoodies_tabView1">

        <div class="dhtmlgoodies_aTab">

        <table width="100%" cellpadding="0" cellspacing="1">

    <!-- ==========   F O R M   S T A R T   H E R E   ========== -->
	<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("tab","0")%>
	<%=fb.hidden("periodo",periodo)%>
	<%=fb.hidden("seccion",seccion)%>
	<%=fb.hidden("anio",anio)%>
	<%=fb.hidden("planilla",planilla)%>
	<%=fb.hidden("recargo",recargo)%>
	<%=fb.hidden("empId",empId)%>
	<%=fb.hidden("tipoTrx",tipoTrx)%>
	<%=fb.hidden("tipo",tipoId)%>
	<%=fb.hidden("extraSize",""+htextra.size())%>
	<%=fb.hidden("auseSize",""+htause.size())%>
	<%=fb.hidden("descSize",""+htdesc.size())%>
	<%=fb.hidden("ajusSize",""+htajus.size())%>
	<%=fb.hidden("ajusSizeRe",""+htajusRe.size())%>
	<%=fb.hidden("baction","")%>
			  <tr class="TextRow02">
					<td>&nbsp;</td>
			  </tr>

	          <tr>
                   <td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
					<table width="100%" cellpadding="1" cellspacing="0">
        			<tr class="TextPanel">
                          <td width="85%">&nbsp;</td>
                          <td width="5%" align="right"><%//=fb.submit("filtro","Filtrar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						  <td align="right" width="10%">&nbsp;</td>

					</tr>
                  	</table>
		 			</td>
      		  </tr>

      <tr id="panel10">
              <td>
			     <table width="100%" cellpadding="1" cellspacing="1">
				       <tr class="TextHeader" align="center">
                          <td width="10%"><cellbytelabel>No</cellbytelabel>.</td>
                          <td width="25%"><cellbytelabel>Nombre del Colaborador</cellbytelabel></td>
                          <td width="40%"><cellbytelabel>Tipo de Hora</cellbytelabel></td>
                          <td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
                          <td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
                          <td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+htextra.size()+",this,0)\"","Seleccionar todas !")%></td>
                   		</tr>
             	 <%   String js = "";
				 	  String id="0";

				 			if(htextra.size()>0)
							al=CmnMgr.reverseRecords(htextra);
							for(int i=0; i<htextra.size(); i++)
							{
							key = al.get(i).toString();
							CommonDataObject cdo = (CommonDataObject) htextra.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
				%>

					<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
					<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
					<%=fb.hidden("empId"+i,cdo.getColValue("empId"))%>
					<%=fb.hidden("the_codigo"+i,cdo.getColValue("the_codigo"))%>
					<%=fb.hidden("fecha_inicio"+i,cdo.getColValue("fecha_inicio"))%>

				<tr id="rs<%=i%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					   <td><%=cdo.getColValue("numero")%></td>
						<td><%=cdo.getColValue("nombre")%></td>
						<td align="left"><%=cdo.getColValue("descripcion")%></td>
						<td align="right"><%=cdo.getColValue("cantidad")%></td>
						<td align="right"><%=cdo.getColValue("monto")%></td>
						<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"")%></td>
        		</tr>
				<%
				}
				%>
		   	  </table>
		 </td>
      </tr>

	 <tr class="TextRow02">
          <td align="right">
            <cellbytelabel>Opciones de Guardar</cellbytelabel>:
            <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
            <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
            <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
     </tr>

	     <%=fb.formEnd(true)%>

      </table>
      </div>

<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ========================   F O R M   S T A R T   H E R E   ======================== -->
<!-- ========================   tab(1) aus_tar   ======================== -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>

			<%=fb.formStart(true)%>
			<%=fb.hidden("tab","1")%>
			<%=fb.hidden("mode",mode)%>
 			<%=fb.hidden("periodo",periodo)%>
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("planilla",planilla)%>
			<%=fb.hidden("seccion",seccion)%>
			<%=fb.hidden("extraSize",""+htextra.size())%>
			<%=fb.hidden("auseSize",""+htause.size())%>
			<%=fb.hidden("descSize",""+htause.size())%>
			<%=fb.hidden("ajusSize",""+htajus.size())%>
			<%=fb.hidden("ajusSizeRe",""+htajusRe.size())%>
			<%=fb.hidden("recargo",recargo)%>
			<%=fb.hidden("empId",empId)%>
			<%=fb.hidden("tipoTrx",tipoTrx)%>
			<%=fb.hidden("tipo",tipoId)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="90%">&nbsp;</td>
							<td width="5%" align="right">&nbsp;</td>
							<td width="5%">&nbsp;</td>



							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>No</cellbytelabel>.</td>
							<td width="20%"><cellbytelabel>Nombre del Colaborador</cellbytelabel></td>
							<td width="30%"><cellbytelabel>Tipo de Transacci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Acci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Cant.Reg</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Cant.Aprob</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
							<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+au.size()+",this,0)\"","Seleccionar todas Aus/Tard. !")%></td>
						</tr>

				 <%   String js1 = "";
							al=CmnMgr.reverseRecords(htause);
							for(int i=0; i<htause.size(); i++)
							{
							key = al.get(i).toString();
							CommonDataObject cdo1 = (CommonDataObject) htause.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
				%>

				<%=fb.hidden("key"+i,cdo1.getColValue("key"))%>
				<%=fb.hidden("codigoAu"+i,cdo1.getColValue("secuencia"))%>
				<%=fb.hidden("descripcionAu"+i,cdo1.getColValue("descripcion"))%>
				<%=fb.hidden("empIdAu"+i,cdo1.getColValue("empId"))%>
				<%=fb.hidden("fechaAu"+i,cdo1.getColValue("fecha"))%>
				<%=fb.hidden("remove"+i,"")%>

				<tr class="TextRow01">
					<td><%=cdo1.getColValue("numero")%></td>
					<td><%=cdo1.getColValue("nombre")%></td>
					<td align="left"><%=cdo1.getColValue("descripcion")%></td>
					<td align="left"><%=cdo1.getColValue("accionDesc")%></td>
					<td align="right"><%=cdo1.getColValue("tiempo")%></td>
					<td align="right"><%=cdo1.getColValue("cantidad")%></td>
					<td align="right"><%=cdo1.getColValue("monto")%></td>
					<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"")%></td>
				</tr>
				<%
				}
				%>
						</table>
					</td>
				</tr>

		<tr class="TextRow02">
          <td align="right">
            <cellbytelabel>Opciones de Guardar</cellbytelabel>:
            <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
            <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
            <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>

<%=fb.formEnd(true)%>

<!-- ===================  F O R M   E N D   H E R E   ================ -->
	</table>

<!-- TAB1 DIV END HERE-->
</div>

<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="0" cellspacing="1">

			<!-- ================  F O R M   S T A R T   H E R E   =========== -->
			<!-- ================         tab(2)  descuentos       =========== -->

		<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","2")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("planilla",planilla)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("extraSize",""+htextra.size())%>
				<%=fb.hidden("auseSize",""+htause.size())%>
				<%=fb.hidden("descSize",""+htdesc.size())%>
				<%=fb.hidden("ajusSize",""+htajus.size())%>
				<%=fb.hidden("ajusSizeRe",""+htajusRe.size())%>
				<%=fb.hidden("recargo",recargo)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("tipoTrx",tipoTrx)%>
				<%=fb.hidden("tipo",tipoId)%>
	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>

	<tr>
		<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="90%">&nbsp;</td>
					<td width="5%" align="right"><%//=fb.submit("filtro","Filtrar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
					<td width="5%"></td>
				</tr>
			</table>
		</td>
	</tr>

	<tr id="panel30">
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="5%"><cellbytelabel>No</cellbytelabel>.</td>
					<td width="20%"><cellbytelabel>Nombre del Colaborador</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
					<td width="30%"><cellbytelabel>Tipo de Transacci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Acci&oacute;n</cellbytelabel></td>
					<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+htdesc.size()+",this,0)\"","Seleccionar todos los Desc. !")%></td>
				</tr>
 				 <%
							al=CmnMgr.reverseRecords(htdesc);
							for(int i=0; i<htdesc.size(); i++)
							{
							key = al.get(i).toString();
							CommonDataObject cdo2 = (CommonDataObject) htdesc.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
				%>

				<%=fb.hidden("key"+i,cdo2.getColValue("key"))%>
				<%=fb.hidden("codigoDe"+i,cdo2.getColValue("codigo"))%>
				<%=fb.hidden("descripcionDe"+i,cdo2.getColValue("descripcion"))%>
				<%=fb.hidden("empIdDe"+i,cdo2.getColValue("empId"))%>
				<%=fb.hidden("fechaDe"+i,cdo2.getColValue("fecha"))%>
				<%=fb.hidden("remove"+i,"")%>

				<tr class="TextRow01">
					<td><%=cdo2.getColValue("numero")%></td>
					<td><%=cdo2.getColValue("nombre")%></td>
					<td align="left"><%=cdo2.getColValue("fecha")%></td>
					<td align="left"><%=cdo2.getColValue("descripcion")%></td>
					<td align="center"><%=cdo2.getColValue("cantidad")%></td>
					<td align="right"><%=cdo2.getColValue("monto")%></td>
					<td align="left"><%=cdo2.getColValue("accionDesc")%></td>
					<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"")%></td>
				</tr>
				<%
				}
				%>
			</table>
		</td>
	</tr>


	<tr class="TextRow02">
          <td align="right">
            <cellbytelabel>Opciones de Guardar</cellbytelabel>:
            <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
            <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
            <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
<%=fb.formEnd(true)%>

<!-- ==================  F O R M   E N D   H E R E  ============== -->
</table>

<!-- TAB2 DIV END HERE-->
</div>


<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================   F O R M   S T A R T   H E R E  ============== -->
<!-- ================		tab(3)  autoriza ajustes   ============== -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","3")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("planilla",planilla)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("extraSize",""+htextra.size())%>
				<%=fb.hidden("auseSize",""+htause.size())%>
				<%=fb.hidden("descSize",""+htdesc.size())%>
				<%=fb.hidden("ajusSize",""+htajus.size())%>
				<%=fb.hidden("ajusSizeRe",""+htajusRe.size())%>
				<%=fb.hidden("recargo",recargo)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("tipoTrx",tipoTrx)%>
				<%=fb.hidden("tipo",tipoId)%>

	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>

	<tr>
		<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer" >
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel" onClick="javascript:verCheck()">
					<td width="90%">&nbsp;</td>
					<td width="5%" align="right"><%//=fb.submit("filtro","Filtrar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
					<td width="5%"></td>
				</tr>
			</table>
		</td>
	</tr>

	<tr id="panel40">
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
				<tr class="TextHeader" align="center">
					<td width="07%"><cellbytelabel>No</cellbytelabel>.</td>
					<td width="10%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Nombre del Colaborador</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Monto Bruto</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Imprimir</cellbytelabel>?</td>
					<td width="10%"><cellbytelabel>Pase a Contab</cellbytelabel>.</td>
					<td width="10%"><cellbytelabel>No. Cheque</cellbytelabel></td>
					<td width="13%"><cellbytelabel>Planilla a Ajustar</cellbytelabel></td>
					<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+htajus.size()+",this,0)\"","Seleccionar todos los Ajustes. !")%></td>
				</tr>
 				 <%
							al=CmnMgr.reverseRecords(htajus);
							for(int i=0; i<htajus.size(); i++)
							{
							key = al.get(i).toString();
							CommonDataObject cdo3 = (CommonDataObject) htajus.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
				%>

				<%=fb.hidden("key"+i,cdo3.getColValue("key"))%>
				<%=fb.hidden("empIdAj"+i,cdo3.getColValue("empId"))%>
				<%=fb.hidden("fechaAj"+i,cdo3.getColValue("fecha"))%>
				<%=fb.hidden("secuencia"+i,cdo3.getColValue("codigo"))%>
				<%=fb.hidden("chequeCreado"+i,cdo3.getColValue("imprimir"))%>
				<%=fb.hidden("remove"+i,"")%>

				<tr class="TextRow01">
					<td><%=cdo3.getColValue("numEmpleado")%></td>
					<td><%=cdo3.getColValue("cedula")%></td>
					<td><%=cdo3.getColValue("nombre")%></td>
					<td align="right"><%=cdo3.getColValue("montoBruto")%></td>
					<td align="center"><%=cdo3.getColValue("impreso")%></td>
					<td align="center"><%=cdo3.getColValue("paseConta")%></td>
					<td align="right"><%=cdo3.getColValue("cheque")%></td>
					<td align="left"><%=cdo3.getColValue("codigoPla")%></td>
					<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"onClick=\"javascript:verCheck()\"")%></td>

				</tr>
				<%
				}
				%>
			</table>
		</td>
	</tr>

	<tr class="TextRow01">
      <td align="right"><cellbytelabel>Total de Ajustes Pendientes por Autorizar</cellbytelabel> : <%=fb.textBox("cant",""+htajus.size(),false,false,true,4)%> &nbsp;&nbsp;<cellbytelabel>Total de Ajustes Seleccionados para Autorizar</cellbytelabel> : <%=fb.textBox("cont","",false,false,true,4)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
	  <% fb.appendJsValidation("if(error>0)doAction();"); %>

	<tr class="TextRow02">
          <td align="right">
            <cellbytelabel>Opciones de Guardar</cellbytelabel>:
            <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
            <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
            <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
<%=fb.formEnd(true)%>

<!-- =================  F O R M   E N D   H E R E   =============== -->
</table>

<!-- TAB3 DIV END HERE-->
</div>
<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================   F O R M   S T A R T   H E R E  ============== -->
<!-- ================		tab(4)  rechazar ajustes   ============== -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","4")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("planilla",planilla)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("extraSize",""+htextra.size())%>
				<%=fb.hidden("auseSize",""+htause.size())%>
				<%=fb.hidden("descSize",""+htdesc.size())%>
				<%=fb.hidden("ajusSize",""+htajus.size())%>
				<%=fb.hidden("ajusSizeRe",""+htajusRe.size())%>
				<%=fb.hidden("recargo",recargo)%>
				<%=fb.hidden("empId",empId)%>
				<%=fb.hidden("tipoTrx",tipoTrx)%>
				<%=fb.hidden("tipo",tipoId)%>

	<tr class="TextRow02">
		<td>&nbsp;</td>
	</tr>

	<tr>
		<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer" >
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="90%">&nbsp;</td>
					<td width="5%" align="right"><%//=fb.submit("filtro","Filtrar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
					<td width="5%"></td>
				</tr>
			</table>
		</td>
	</tr>

	<tr id="panel50">
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
				<tr class="TextHeader" align="center">
					<td width="07%"><cellbytelabel>No</cellbytelabel>.</td>
					<td width="10%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Nombre del Colaborador</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Monto Bruto</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Imprimir</cellbytelabel>?</td>
					<td width="10%"><cellbytelabel>Pase a Contab</cellbytelabel>.</td>
					<td width="10%"><cellbytelabel>No. Cheque</cellbytelabel></td>
					<td width="13%"><cellbytelabel>Planilla a Ajustar</cellbytelabel></td>
					<td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+htajusRe.size()+",this,0)\"","Seleccionar todos los Ajustes. !")%></td>
				</tr>
 				 <%
							al=CmnMgr.reverseRecords(htajusRe);
							for(int i=0; i<htajusRe.size(); i++)
							{
							key = al.get(i).toString();
							CommonDataObject cdo3 = (CommonDataObject) htajusRe.get(key);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
				%>

				<%=fb.hidden("key"+i,cdo3.getColValue("key"))%>
				<%=fb.hidden("empIdAj"+i,cdo3.getColValue("empId"))%>
				<%=fb.hidden("fechaAj"+i,cdo3.getColValue("fecha"))%>
				<%=fb.hidden("secuencia"+i,cdo3.getColValue("codigo"))%>
				<%=fb.hidden("chequeCreado"+i,cdo3.getColValue("imprimir"))%>
				<%=fb.hidden("remove"+i,"")%>

				<tr class="TextRow01">
					<td><%=cdo3.getColValue("numEmpleado")%></td>
					<td><%=cdo3.getColValue("cedula")%></td>
					<td><%=cdo3.getColValue("nombre")%></td>
					<td align="right"><%=cdo3.getColValue("montoBruto")%></td>
					<td align="center"><%=cdo3.getColValue("impreso")%></td>
					<td align="center"><%=cdo3.getColValue("paseConta")%></td>
					<td align="right"><%=cdo3.getColValue("cheque")%></td>
					<td align="left"><%=cdo3.getColValue("codigoPla")%></td>
					<td align="center"><%=fb.checkbox("check"+i,"S",false,false,null,null,"onClick=\"javascript:verCheckRe()\"")%></td>
				</tr>
				<%
				}
				%>
			</table>
		</td>
	</tr>

	<tr class="TextRow01">
      <td align="right"><cellbytelabel>Total de Ajustes para Rechazar</cellbytelabel> : <%=fb.textBox("cant",""+htajusRe.size(),false,false,true,4)%> &nbsp;&nbsp;<cellbytelabel>Total de Ajustes Seleccionados para Rechazar</cellbytelabel> : <%=fb.textBox("contRe","",false,false,true,4)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
	  <% fb.appendJsValidation("if(error>0)doAction();"); %>

	<tr class="TextRow02">
          <td align="right">
            <cellbytelabel>Opciones de Guardar</cellbytelabel>:
            <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
            <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
            <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
<%=fb.formEnd(true)%>

<!-- =================  F O R M   E N D   H E R E   =============== -->
</table>

<!-- TAB4 DIV END HERE-->
</div>
</div>
<script type="text/javascript">
<%
String tabLabel = "'Sobretiempo','Ausencias y Tardanzas','Descuentos,Ajuste y Otras Trx', 'Autorización Planilla de Ajustes','Rechazar Planilla de Ajustes'";
if (!mode.equalsIgnoreCase("add"))
{
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

			</td>
		  </tr>
		</table>
	</td>
</tr>
</table>

<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
} //GET
else
{

String saveOption 	= request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction 		= request.getParameter("baction");
int keySize			= Integer.parseInt(request.getParameter("extraSize"));
int keyAuSize		= Integer.parseInt(request.getParameter("auseSize"));
int keyDeSize		= Integer.parseInt(request.getParameter("descSize"));
int keyAjSize		= Integer.parseInt(request.getParameter("ajusSize"));
String itemRemoved 	= "";
empId 	= request.getParameter("empId");
String compania = (String) session.getAttribute("_companyId");
al.clear();

	if(tab.equals("0"))
	{
		for(int a=0; a<keySize; a++)
		{
			CommonDataObject cdo = new CommonDataObject();

			String 	codigoEx = request.getParameter("codigo"+a);
			String fechaIni = request.getParameter("fecha_inicio"+a);
			//empId = request.getParameter("empId"+a);

			cdo.setTableName("tbl_pla_t_extraordinario");
			cdo.addColValue("codigo",request.getParameter("codigo"+a));
			cdo.addColValue("the_codigo",request.getParameter("the_codigo"+a));

			if (request.getParameter("check"+a) != null && request.getParameter("check"+a).equalsIgnoreCase("S"))
			{
				cdo.addColValue("vobo_estado","S");
				cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
				cdo.addColValue("vobo_fecha",cDateTime.substring(0,10));
			}
			cdo.setWhereClause("compania="+compania+" and trunc(fecha_inicio) = to_date('"+fechaIni+"','dd/mm/yyyy') and codigo = "+codigoEx+" and emp_id="+request.getParameter("empId"+a));
			al.add(cdo);
  		}//End For
		if(al.size()==0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_t_extraordinario");
			cdo.setWhereClause("compania="+compania+"  and emp_id=-1");
			cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));

			al.add(cdo);
		}
		SQLMgr.updateList(al);
	}//End Tab
    else if(tab.equals("1"))
	{
		for(int a=0; a<keyAuSize; a++)
		{
			CommonDataObject cdo = new CommonDataObject();

			String fechaIni = request.getParameter("fechaAu"+a);
			//empId = request.getParameter("empIdAu"+a);
			cdo.setTableName("tbl_pla_aus_y_tard");
			cdo.setWhereClause("compania="+compania+" and trunc(fecha) =to_date('"+fechaIni+"','dd/mm/yyyy') and secuencia ="+request.getParameter("codigoAu"+a)+" and emp_id="+request.getParameter("empIdAu"+a));
		if (request.getParameter("check"+a) != null && request.getParameter("check"+a).equalsIgnoreCase("S"))
		{
			cdo.addColValue("vobo_estado","S");
			cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
			cdo.addColValue("vobo_fecha",cDateTime.substring(0,10));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion",cDateTime);
		}
 		al.add(cdo);
  		}//End For
		if(al.size()==0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_aus_y_tard");
			cdo.setWhereClause("compania="+compania+"  and emp_id=-1");
			cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));

			al.add(cdo);
		}
		SQLMgr.updateList(al);

	}//End Tab
	else if(tab.equals("2"))
	{
		for(int a=0; a<keyDeSize; a++)
		{
			CommonDataObject cdo = new CommonDataObject();

			String 	codigoDe = request.getParameter("codigoDe"+a);
			//empId = request.getParameter("empIdDe"+a);
			String fechaDe = request.getParameter("fechaDe"+a);

			cdo.setTableName("tbl_pla_transac_emp");
			cdo.addColValue("codigo",request.getParameter("codigoDe"+a));
			if (request.getParameter("check"+a) != null && request.getParameter("check"+a).equalsIgnoreCase("S"))
			{
				cdo.addColValue("vobo_estado","S");
				cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
				cdo.addColValue("vobo_fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
				cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			}
			cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and trunc(fecha) = to_date('"+fechaDe+"','dd/mm/yyyy') and codigo = "+codigoDe+" and emp_id="+request.getParameter("empIdDe"+a));
			al.add(cdo);
  		}//End For
		if(al.size()==0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_transac_emp");
			cdo.setWhereClause("compania="+compania+" and emp_id=-1");
			cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
			al.add(cdo);
		}
		SQLMgr.updateList(al);
	}//End Tab
    else if(tab.equals("3"))
	{
		for(int a=0; a<keyAjSize; a++)
		{
			CommonDataObject cdo = new CommonDataObject();

			String 	codigoAj = request.getParameter("secuencia"+a);
			String fechaAj = request.getParameter("fechaAj"+a);

			//empId = request.getParameter("empIdAj"+a);

			cdo.setTableName("tbl_pla_pago_ajuste");
			cdo.addColValue("secuencia",request.getParameter("secuencia"+a));
			if (request.getParameter("check"+a) != null && request.getParameter("check"+a).equalsIgnoreCase("S"))
			{
				cdo.addColValue("vobo_estado","S");
				cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
				cdo.addColValue("vobo_fecha",cDateTime);
			}
				cdo.setWhereClause("cod_compania="+compania+" and secuencia = "+codigoAj+" and emp_id="+request.getParameter("empIdAj"+a));
				al.add(cdo);
  		}//End For
		if(al.size()==0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_pago_ajuste");
			cdo.setWhereClause("cod_compania="+compania+" and emp_id=-1");
			cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
			al.add(cdo);
		}
		SQLMgr.updateList(al);

	}//End Tab
	else if(tab.equals("4"))
	{	keyAjSize = Integer.parseInt(request.getParameter("ajusSizeRe"));
		for(int a=0; a<keyAjSize; a++)
		{
			CommonDataObject cdo = new CommonDataObject();

			String 	codigoAj = request.getParameter("secuencia"+a);
			String fechaAj = request.getParameter("fechaAj"+a);

			//empId = request.getParameter("empIdAj"+a);

			cdo.setTableName("tbl_pla_pago_ajuste");
			cdo.addColValue("secuencia",request.getParameter("secuencia"+a));
			if (request.getParameter("check"+a) != null && request.getParameter("check"+a).equalsIgnoreCase("S"))
			{
				cdo.addColValue("vobo_estado","N");
				cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
				cdo.addColValue("vobo_fecha",cDateTime);
			}
				cdo.setWhereClause("cod_compania="+compania+" and secuencia = "+codigoAj+" and emp_id="+request.getParameter("empIdAj"+a));
				al.add(cdo);
  		}//End For
		if(al.size()==0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_pla_pago_ajuste");
			cdo.setWhereClause("cod_compania="+compania+" and emp_id=-1");
			cdo.addColValue("vobo_usuario",(String) session.getAttribute("_userName"));
			al.add(cdo);
		}
		SQLMgr.updateList(al);

	}//End Tab

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
  alert('<%=SQLMgr.getErrMsg()%>');
<%
  if (tab.equals("0") || tab.equals("1") || tab.equals("2") || tab.equals("3"))
  {
    if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/autoriza_detalle_trx.jsp"))
    {
%>
  //window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/autoriza_detalle_trx.jsp")%>';
<%
    }
    else
    {
%>
  //window.opener.location = '<%=request.getContextPath()%>/rhplanilla/autoriza_detalle_trx.jsp';
<%
    }
  }

 if (saveOption.equalsIgnoreCase("O"))
  {
%>
    setTimeout('editMode()',500);
<%
  }
  else if (saveOption.equalsIgnoreCase("C"))
  {
%>
  window.close();
<%
  }
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&tab=<%=tab%>&anio=<%=anio%>&planilla=<%=planilla%>&seccion=<%=seccion%>&periodo=<%=periodo%>&tipoTrx=<%=tipoTrx%>&empId=<%=empId%>';
}


</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>





