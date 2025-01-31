<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.Empleado"%>
<%@ page import="issi.rhplanilla.Vacaciones"%>
<%@ page import="issi.rhplanilla.TemporalVac"%>
<%@ page import="issi.rhplanilla.DistDiasVac"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="EmplMgr" scope="page" class="issi.rhplanilla.VacacionesMgr" />
<jsp:useBean id="del" scope="page" class="issi.rhplanilla.Empleado" />
<jsp:useBean id="DI" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
EmplMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
DistDiasVac ddv = new DistDiasVac();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String empId = request.getParameter("emp_id");
String paccion = request.getParameter("paccion");
String anio = request.getParameter("anio");
String periodo = request.getParameter("periodo");
String fechaIni = request.getParameter("fechaIni");
String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String anioSol = request.getParameter("anioSol");
String codigoSol = request.getParameter("codigoSol");

StringBuffer sbSql = new StringBuffer();
String id ="";
boolean viewMode = false;
if (mode == null) mode = "add";
if (fg == null) fg = "";
if (paccion == null) paccion = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	//if (mode.equalsIgnoreCase("add") && change == null) DI.clear();
	DI.clear();
	if(fg.equals("CALACUM")){

		sbSql = new StringBuffer();

		sbSql.append("call sp_rh_calcular_acumulado(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",");
		sbSql.append(empId);
		sbSql.append(",");
		sbSql.append(provincia);
		sbSql.append(",'");
		sbSql.append(sigla);
		sbSql.append("',");
		sbSql.append(tomo);
		sbSql.append(",");
		sbSql.append(asiento);
		sbSql.append(",'");
		sbSql.append(fechaIni);
		/*sbSql.append("',");
		sbSql.append(anioSol);
		sbSql.append(",");
		sbSql.append(codigoSol);*/
		sbSql.append("')");
		SQLMgr.execute(sbSql.toString());
		if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());
	}


	sql = "select to_char(fecha_inicio, 'dd/mm/yyyy') fechaInicio, anio, secuencia, periodo, b.descripcion mes, decode(b.quincena1, a.periodo, 'PRIMERA', 'SEGUNDA') quincena, provincia, sigla, tomo, asiento, cod_compania codCompania, sal_bruto salBruto, gasto_rep gastoRep, salario_especie salarioEspecie, emp_id empId from tbl_pla_temporal_vac a, tbl_pla_vac_parametro b where (a.periodo = b.quincena1 or a.periodo = b.quincena2) and cod_compania = "+(String) session.getAttribute("_companyId")+" and emp_id = " + empId+" and trunc(a.fecha_inicio)= to_date('"+fechaIni+"','dd/mm/yyyy') order by anio desc,secuencia asc";
	//+" and a.codigo_sol = "+codigoSol+" and anio_sol ="+anioSol;
				System.out.println("sql det...\n"+sql);
				//del.getTemporalVacas().add(sbb.getBeanList(ConMgr.getConnection(), sql, TermoralVac.class));
				al = sbb.getBeanList(ConMgr.getConnection(), sql, TemporalVac.class);

				key = "";
				int ln = 0;
				for (int i=0; i<al.size(); i++){
					TemporalVac tv = (TemporalVac) al.get(i);
					try {
						ln++;
						if (ln < 10) key = "00"+ln;
						else if (ln < 100) key = "0"+ln;
						else key = ""+ln;

						DI.put(key, tv);
						del.getTemporalVacs().add(tv);
					} catch(Exception e) {
						System.out.println("Unable to add item...");
					}
				}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){calc();newHeight();}
function calc()
{
	var iCounter = 0;
	var size = parseInt(document.form1.keySize.value);
	var salario=0.00, gasto_rep = 0.00, s_especie = 0.00;
	var t_salario=0.00, t_gasto_rep = 0.00, t_s_especie = 0.00;

		for(i=0;i<size;i++){
			salario = eval('document.form1.sal_bruto'+i).value;
			gasto_rep = eval('document.form1.gasto_rep'+i).value;
			s_especie = eval('document.form1.salario_especie'+i).value;
			if(!isNaN(salario) && salario!='') t_salario += parseFloat(salario);
			if(!isNaN(gasto_rep) && gasto_rep!='') t_gasto_rep += parseFloat(gasto_rep);
			if(!isNaN(s_especie) && s_especie!='') t_s_especie += parseFloat(s_especie);
		}
		parent.document.form1.acumulado.value = t_salario.toFixed(2);
		parent.document.form1.acumulado_gr.value = t_gasto_rep.toFixed(2);
		parent.document.form1.acumulado_sespecie.value = t_s_especie.toFixed(2);

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
		alert('Introduzca valores num�ricos1');

		eval('document.form1.sal_bruto'+i).value = '';
	}
	if(!isNaN(gasto_rep) && gasto_rep!='') calc();
	else if(gasto_rep != '' && isNaN(gasto_rep)){
		alert('Introduzca valores num�ricos2');
		eval('document.form1.gasto_rep'+i).value = '';
	}
	if(!isNaN(s_especie) && s_especie!='') calc();
	else if(s_especie != '' && isNaN(s_especie)){
		alert('Introduzca valores num�ricos3');
		eval('document.form1.salario_especie'+i).value = '';
	}

}

function doSubmit()
{
	var fg = '<%=fg%>';
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.emp_id.value = parent.document.form1.empId.value;
	document.form1.segundo_nombre.value = parent.document.form1.segundo_nombre.value;
	document.form1.segundo_apellido.value = parent.document.form1.segundo_apellido.value;
	document.form1.primer_nombre.value = parent.document.form1.primer_nombre.value;
	document.form1.primer_apellido.value = parent.document.form1.primer_apellido.value;
	document.form1.provincia.value = parent.document.form1.provincia.value;
	document.form1.sigla.value = parent.document.form1.sigla.value;
	document.form1.tomo.value = parent.document.form1.tomo.value;
	document.form1.asiento.value = parent.document.form1.asiento.value;
	document.form1.num_empleado.value = parent.document.form1.num_empleado.value;
	document.form1.salario_mes.value = parent.document.form1.salario_mes.value;
	document.form1.gasto_rep.value = parent.document.form1.gasto_rep.value;
	document.form1.unidad_organi.value = parent.document.form1.unidad_organi.value;
	document.form1.unidad_organi_desc.value = parent.document.form1.unidad_organi_desc.value;
	document.form1.accion.value = parent.document.form1.accion.value;
	document.form1.accion_desc.value = parent.document.form1.accion_desc.value;
	document.form1.dias_d.value = parent.document.form1.dias_d.value;
	document.form1.dias_dinero.value = parent.document.form1.dias_dinero.value;
	document.form1.tipo_vacacion.value = parent.document.form1.tipo_vacacion.value;
	document.form1.horas_mes.value = parent.document.form1.horas_mes.value;
	document.form1.r_dsp_nombre.value = parent.document.form1.r_dsp_nombre.value;
	document.form1.tiempo_sol.value = parent.document.form1.tiempo_sol.value;
	document.form1.cantidad_horas.value = parent.document.form1.cantidad_horas.value;
	document.form1.r_emp_id.value = parent.document.form1.r_emp_id.value;
	document.form1.r_num_empleado.value = parent.document.form1.r_num_empleado.value;
	document.form1.r_provincia.value = parent.document.form1.r_provincia.value;
	document.form1.r_sigla.value = parent.document.form1.r_sigla.value;
	document.form1.r_tomo.value = parent.document.form1.r_tomo.value;
	document.form1.r_asiento.value = parent.document.form1.r_asiento.value;
	document.form1.tiempo_sol_dinero.value = parent.document.form1.tiempo_sol_dinero.value;
	document.form1.acumulado.value = parent.document.form1.acumulado.value;
	document.form1.bonif_por_reemplazo.value = parent.document.form1.bonif_por_reemplazo.value;
	document.form1.diferencia_x_reemplazo.value = parent.document.form1.diferencia_x_reemplazo.value;
	document.form1.fecha_ini.value = parent.document.form1.fecha_ini.value;
	document.form1.acumulado_gr.value = parent.document.form1.acumulado_gr.value;
	document.form1.r_total_periodos.value = parent.document.form1.r_total_periodos.value;
	document.form1.r_monto_periodo.value = parent.document.form1.r_monto_periodo.value;
	document.form1.fecha_fin.value = parent.document.form1.fecha_fin.value;
	document.form1.acumulado_sespecie.value = parent.document.form1.acumulado_sespecie.value;
	document.form1.comentario.value = parent.document.form1.comentario.value;
	document.form1.anio.value = parent.document.form1.anio.value;
	document.form1.periodo.value = parent.document.form1.periodo.value;
	document.form1.forma_pago.value = parent.document.form1.forma_pago.value;

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
<%//=fb.hidden("size",""+DI.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("paccion",paccion)%>
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
<%=fb.hidden("salario_mes","")%>
<%=fb.hidden("gasto_rep","")%>
<%=fb.hidden("unidad_organi","")%>
<%=fb.hidden("unidad_organi_desc","")%>
<%=fb.hidden("accion","")%>
<%=fb.hidden("accion_desc","")%>
<%=fb.hidden("dias_d","")%>
<%=fb.hidden("dias_dinero","")%>
<%=fb.hidden("tipo_vacacion","")%>
<%=fb.hidden("horas_mes","")%>
<%=fb.hidden("r_dsp_nombre","")%>
<%=fb.hidden("tiempo_sol","")%>
<%=fb.hidden("cantidad_horas","")%>
<%=fb.hidden("r_emp_id","")%>
<%=fb.hidden("r_num_empleado","")%>
<%=fb.hidden("r_provincia","")%>
<%=fb.hidden("r_sigla","")%>
<%=fb.hidden("r_tomo","")%>
<%=fb.hidden("r_asiento","")%>
<%=fb.hidden("tiempo_sol_dinero","")%>
<%=fb.hidden("acumulado","")%>
<%=fb.hidden("bonif_por_reemplazo","")%>
<%=fb.hidden("diferencia_x_reemplazo","")%>
<%=fb.hidden("fecha_ini","")%>
<%=fb.hidden("acumulado_gr","")%>
<%=fb.hidden("r_total_periodos","")%>
<%=fb.hidden("r_monto_periodo","")%>
<%=fb.hidden("fecha_fin","")%>
<%=fb.hidden("acumulado_sespecie","")%>
<%=fb.hidden("comentario","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("periodo","")%>
<%=fb.hidden("forma_pago","")%>
<%=fb.hidden("fechaIni",""+fechaIni)%>

<table width="100%" align="center">

<tr class="TextHeader" align="center">
	<td>Secuencia</td>
	<td>A&ntilde;o</td>
	<td>Periodo</td>
	<td></td>
	<td></td>
	<td>Salaraio + P. prod. + S. Especie</td>
	<td>Gasto de Rep.</td>
	<td>Sal. Especie</td>
</tr>
<%
if (DI.size() > 0) al = CmnMgr.reverseRecords(DI);
for (int i=0; i<DI.size(); i++)
{
	key = al.get(i).toString();
	TemporalVac tv = (TemporalVac) DI.get(key);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("secuencia"+i,""+tv.getSecuencia())%>
<%=fb.hidden("anio"+i,""+tv.getAnio())%>
<%=fb.hidden("periodo"+i,""+tv.getPeriodo())%>
<%=fb.hidden("mes"+i,""+tv.getMes())%>
<%=fb.hidden("quincena"+i,""+tv.getQuincena())%>
<tr class="<%=color%>" align="center">
	<td><%=fb.textBox("secuenciaView"+i,tv.getSecuencia(),false,false,true,3)%></td>
	<td><%=fb.textBox("anioView"+i,tv.getAnio(),false,false,true,5)%></td>
	<td><%=fb.textBox("periodoView"+i,tv.getPeriodo(),false,false,true,3)%></td>
	<td><%=fb.textBox("mesView"+i,tv.getMes(),false,false,true,15)%></td>
	<td><%=fb.textBox("quincenaView"+i,tv.getQuincena(),false,false,true,15)%></td>
	<td>
	<%=fb.decBox("sal_bruto"+i,tv.getSalBruto()/*(tv.getSalBruto()!=null && !tv.getSalBruto().equals("")?CmnMgr.getFormattedDecimal(tv.getSalBruto()):"")*/,false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onBlur=\"javascript:calcThis("+i+")\"","Cantidad",false," tabindex=\""+i+"\"")%>
  </td>
	<td>
	<%=fb.decBox("gasto_rep"+i,tv.getGastoRep()/*(tv.getGastoRep()!=null && !tv.getGastoRep().equals("")?CmnMgr.getFormattedDecimal(tv.getGastoRep()):"")*/,false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onBlur=\"javascript:calcThis("+i+")\"","Cantidad",false," tabindex=\""+i+"\"")%>
  </td>
	<td>
	<%=fb.decBox("salario_especie"+i,tv.getSalarioEspecie()/*(tv.getSalarioEspecie()!=null && !tv.getSalarioEspecie().equals("")?CmnMgr.getFormattedDecimal(tv.getSalarioEspecie()):"")*/,false,false,viewMode,6, 8.2,null,null,"onFocus=\"this.select();\" onBlur=\"javascript:calcThis("+i+")\"","Cantidad",false," tabindex=\""+i+"\"")%>
  </td>
</tr>
<%}%>
<%=fb.hidden("keySize",""+DI.size())%>
</table>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
<%//fb.appendJsValidation("\n\tif (!verAct())\n\t{\n\t\talert('Por favor introducir detalles de Activo!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "", close = "true";

	del = new Empleado();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	if (request.getParameter("emp_id") != null && !request.getParameter("emp_id").equals("") && !request.getParameter("emp_id").equals("NA")) del.setEmpId(request.getParameter("emp_id"));

	if (request.getParameter("segundo_nombre") != null && !request.getParameter("segundo_nombre").equals("") && !request.getParameter("segundo_nombre").equals("NA")) del.setSegundoNombre(request.getParameter("segundo_nombre"));

	if (request.getParameter("segundo_apellido") != null && !request.getParameter("segundo_apellido").equals("") && !request.getParameter("segundo_apellido").equals("NA")) del.setSegundoApellido(request.getParameter("segundo_apellido"));

	if (request.getParameter("primer_nombre") != null && !request.getParameter("primer_nombre").equals("") && !request.getParameter("primer_nombre").equals("NA")) del.setPrimerNombre(request.getParameter("primer_nombre"));

	if (request.getParameter("primer_apellido") != null && !request.getParameter("primer_apellido").equals("") && !request.getParameter("primer_apellido").equals("NA")) del.setPrimerApellido(request.getParameter("primer_apellido"));

	if (request.getParameter("provincia") != null && !request.getParameter("provincia").equals("") && !request.getParameter("provincia").equals("NA")) del.setProvincia(request.getParameter("provincia"));

	if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("") && !request.getParameter("sigla").equals("NA")) del.setSigla(request.getParameter("sigla"));

	if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("") && !request.getParameter("tomo").equals("NA")) del.setTomo(request.getParameter("tomo"));

	if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("") && !request.getParameter("asiento").equals("NA")) del.setAsiento(request.getParameter("asiento"));

	if (request.getParameter("num_empleado") != null && !request.getParameter("num_empleado").equals("") && !request.getParameter("num_empleado").equals("NA")) del.setNumEmpleado(request.getParameter("num_empleado"));

	if (request.getParameter("salario_mes") != null && !request.getParameter("salario_mes").equals("") && !request.getParameter("salario_mes").equals("NA")) del.setSalarioMes(request.getParameter("salario_mes").replaceAll(",",""));

	if (request.getParameter("gasto_rep") != null && !request.getParameter("gasto_rep").equals("") && !request.getParameter("gasto_rep").equals("NA")) del.setGastoRep(request.getParameter("gasto_rep"));

	if (request.getParameter("unidad_organi") != null && !request.getParameter("unidad_organi").equals("") && !request.getParameter("unidad_organi").equals("NA")) del.setUnidadOrgani(request.getParameter("unidad_organi"));

	if (request.getParameter("unidad_organi_desc") != null && !request.getParameter("unidad_organi_desc").equals("") && !request.getParameter("unidad_organi_desc").equals("NA")) del.setUnidadOrganiDesc(request.getParameter("unidad_organi_desc"));

	if (request.getParameter("accion") != null && !request.getParameter("accion").equals("") && !request.getParameter("accion").equals("NA")) del.setAccion(request.getParameter("accion"));

	if (request.getParameter("dias_d") != null && !request.getParameter("dias_d").equals("") && !request.getParameter("dias_d").equals("NA")) del.setDiasD(request.getParameter("dias_d"));

	if (request.getParameter("dias_dinero") != null && !request.getParameter("dias_dinero").equals("") && !request.getParameter("dias_dinero").equals("NA")) del.setDiasDinero(request.getParameter("dias_dinero"));

	if (request.getParameter("tipo_vacacion") != null && !request.getParameter("tipo_vacacion").equals("") && !request.getParameter("tipo_vacacion").equals("NA")) del.setTipoVacacion(request.getParameter("tipo_vacacion"));

	if (request.getParameter("horas_mes") != null && !request.getParameter("horas_mes").equals("") && !request.getParameter("horas_mes").equals("NA")) del.setHorasMes(request.getParameter("horas_mes"));

	if (request.getParameter("r_dsp_nombre") != null && !request.getParameter("r_dsp_nombre").equals("") && !request.getParameter("r_dsp_nombre").equals("NA")) del.setRDspNombre(request.getParameter("r_dsp_nombre"));

	if (request.getParameter("tiempo_sol") != null && !request.getParameter("tiempo_sol").equals("") && !request.getParameter("tiempo_sol").equals("NA")) del.setTiempoSol(request.getParameter("tiempo_sol"));

	if (request.getParameter("cantidad_horas") != null && !request.getParameter("cantidad_horas").equals("") && !request.getParameter("cantidad_horas").equals("NA")) del.setCantidadHoras(request.getParameter("cantidad_horas"));

	if (request.getParameter("r_emp_id") != null && !request.getParameter("r_emp_id").trim().equals("") && !request.getParameter("r_emp_id").trim().equals("NA")) del.setREmpId(request.getParameter("r_emp_id"));
	else del.setREmpId("null");

	if (request.getParameter("r_num_empleado") != null && !request.getParameter("r_num_empleado").trim().equals("") && !request.getParameter("r_num_empleado").trim().equals("NA")) del.setRNumEmpleado(request.getParameter("r_num_empleado"));
	else del.setRNumEmpleado("null");

	if (request.getParameter("r_provincia") != null && !request.getParameter("r_provincia").trim().equals("") && !request.getParameter("r_provincia").trim().equals("NA")) del.setRProvincia(request.getParameter("r_provincia"));
	else del.setRProvincia("null");

	if (request.getParameter("r_sigla") != null && !request.getParameter("r_sigla").trim().equals("") && !request.getParameter("r_sigla").trim().equals("NA")) del.setRSigla(request.getParameter("r_sigla"));

	if (request.getParameter("r_tomo") != null && !request.getParameter("r_tomo").trim().equals("") && !request.getParameter("r_tomo").trim().equals("NA")) del.setRTomo(request.getParameter("r_tomo"));
	else del.setRTomo("null");

	if (request.getParameter("r_asiento") != null && !request.getParameter("r_asiento").trim().equals("") && !request.getParameter("r_asiento").trim().equals("NA")) del.setRAsiento(request.getParameter("r_asiento"));
	else del.setRAsiento("null");

	if (request.getParameter("tiempo_sol_dinero") != null && !request.getParameter("tiempo_sol_dinero").equals("") && !request.getParameter("tiempo_sol_dinero").equals("NA")) del.setTiempoSolDinero(request.getParameter("tiempo_sol_dinero"));

	if (request.getParameter("acumulado") != null && !request.getParameter("acumulado").equals("") && !request.getParameter("acumulado").equals("NA")) del.setAcumulado(request.getParameter("acumulado"));

	if (request.getParameter("bonif_por_reemplazo") != null && !request.getParameter("bonif_por_reemplazo").equals("") && !request.getParameter("bonif_por_reemplazo").equals("NA")) del.setBonifPorReemplazo(request.getParameter("bonif_por_reemplazo"));

	if (request.getParameter("diferencia_x_reemplazo") != null && !request.getParameter("diferencia_x_reemplazo").equals("") && !request.getParameter("diferencia_x_reemplazo").equals("NA")) del.setDiferenciaXReemplazo(request.getParameter("diferencia_x_reemplazo"));
	else del.setDiferenciaXReemplazo("null");

	if (request.getParameter("fecha_ini") != null && !request.getParameter("fecha_ini").equals("") && !request.getParameter("fecha_ini").equals("NA")) del.setFechaIni(request.getParameter("fecha_ini"));

	if (request.getParameter("acumulado_gr") != null && !request.getParameter("acumulado_gr").equals("") && !request.getParameter("acumulado_gr").equals("NA")) del.setAcumuladoGr(request.getParameter("acumulado_gr"));

	if (request.getParameter("r_total_periodos") != null && !request.getParameter("r_total_periodos").equals("") && !request.getParameter("r_total_periodos").equals("NA")) del.setRTotalPeriodos(request.getParameter("r_total_periodos"));
	else del.setRTotalPeriodos("null");

	if (request.getParameter("r_monto_periodo") != null && !request.getParameter("r_monto_periodo").equals("") && !request.getParameter("r_monto_periodo").equals("NA")) del.setRMontoXPeriodo(request.getParameter("r_monto_periodo"));
	else del.setRMontoXPeriodo("null");

	if (request.getParameter("fecha_fin") != null && !request.getParameter("fecha_fin").equals("") && !request.getParameter("fecha_fin").equals("NA")) del.setFechaFin(request.getParameter("fecha_fin"));

	if (request.getParameter("acumulado_sespecie") != null && !request.getParameter("acumulado_sespecie").equals("") && !request.getParameter("acumulado_sespecie").equals("NA")) del.setAcumuladoSEspecie(request.getParameter("acumulado_sespecie"));

	if (request.getParameter("comentario") != null && !request.getParameter("comentario").equals("") && !request.getParameter("comentario").equals("NA")) del.setComentario(request.getParameter("comentario"));

	if (request.getParameter("anio") != null && !request.getParameter("anio").equals("") && !request.getParameter("anio").equals("NA")) del.setAnio(request.getParameter("anio"));

	if (request.getParameter("periodo") != null && !request.getParameter("periodo").equals("") && !request.getParameter("periodo").equals("NA")) del.setPeriodo(request.getParameter("periodo"));

	if (request.getParameter("forma_pago") != null && !request.getParameter("forma_pago").equals("") && !request.getParameter("forma_pago").equals("NA")) del.setFormaPago(request.getParameter("forma_pago"));

	//int size = Integer.parseInt(request.getParameter("size"));
	int ln = 0;
	del.getTemporalVacs().clear();
	del.getDistDiasVacs().clear();
	DI.clear();
	for (int i=0; i<keySize; i++){

			TemporalVac di = new TemporalVac();
			if (request.getParameter("secuencia"+i) != null && !request.getParameter("secuencia"+i).equals("")) di.setSecuencia(request.getParameter("secuencia"+i));
			if (request.getParameter("anio"+i) != null && !request.getParameter("anio"+i).equals("")) di.setAnio(request.getParameter("anio"+i));
			if (request.getParameter("periodo"+i) != null && !request.getParameter("periodo"+i).equals("")) di.setPeriodo(request.getParameter("periodo"+i));
			if (request.getParameter("mes"+i) != null && !request.getParameter("mes"+i).equals("")) di.setMes(request.getParameter("mes"+i));
			if (request.getParameter("quincena"+i) != null && !request.getParameter("quincena"+i).equals("")) di.setQuincena(request.getParameter("quincena"+i));
			if (request.getParameter("sal_bruto"+i) != null && !request.getParameter("sal_bruto"+i).equals("")) di.setSalBruto(request.getParameter("sal_bruto"+i));
			if (request.getParameter("gasto_rep"+i) != null && !request.getParameter("gasto_rep"+i).equals("")) di.setGastoRep(request.getParameter("gasto_rep"+i));
			if (request.getParameter("salario_especie"+i) != null && !request.getParameter("salario_especie"+i).equals("")) di.setSalarioEspecie(request.getParameter("salario_especie"+i));

			try{
				ln++;
				if (ln < 10) key = "00"+ln;
				else if (ln < 100) key = "0"+ln;
				else key = ""+ln;

				DI.put(key,di);
				del.getTemporalVacs().add(di);
				//System.out.println("Adding item...");
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
	}

	if(!dl.equals("") || clearHT.equals("S")){
		response.sendRedirect("../inventario/reg_delivery_item.jsp?mode="+mode+ "&change=1&type=2&fg="+fg);
		return;
	}

	System.out.println("del.getDistDiasVacs().size()="+del.getDistDiasVacs().size());
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	 if (request.getParameter("baction").equalsIgnoreCase("Guardar") && (paccion.equals("RV") || paccion.equals("RI"))){
		del.setCompania((String) session.getAttribute("_companyId"));
		del.setUsuarioCreacion((String) session.getAttribute("_userName"));
		del.setUsuarioModificacion((String) session.getAttribute("_userName"));
		EmplMgr.approve(del);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(cerrar)
{
	<%if(EmplMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = <%=EmplMgr.getErrCode()%>;
	parent.document.form1.errMsg.value = '<%=EmplMgr.getErrMsg()%>';
	parent.document.form1.submit();

  <%} else throw new Exception(EmplMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow('<%=close%>')">
</body>
</html>
<%
}//POST
%>
