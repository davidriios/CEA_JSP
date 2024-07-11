<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iEmp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vEmp" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alGroup = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbCols = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String grupo = request.getParameter("grupo");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String periodo = request.getParameter("periodo");
String fCierre = request.getParameter("fCierre");
String fInicio = request.getParameter("fInicio");
String fFinal = request.getParameter("fFinal");
String fecha = request.getParameter("fecha");
String noPlanilla =request.getParameter("noPlanilla");
String codPlanilla =request.getParameter("codPlanilla");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (fg == null) fg = "";
if (mode == null) mode = "add";
if (grupo == null) grupo = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (quincena == null) quincena = "";
if (periodo == null) periodo = "";
if (fCierre == null) fCierre = "";
if (fInicio == null) fInicio = "";
if (fFinal == null) fFinal = "";
if (fecha == null) fecha = "";

String empId = request.getParameter("empId");
String numEmpleado = request.getParameter("numEmpleado");
String cedula = request.getParameter("cedula");
String nombre = request.getParameter("nombre");
if (empId == null) empId = "";
if (numEmpleado == null) numEmpleado = "";
if (cedula == null) cedula = "";
if (nombre == null) nombre = "";

String fingreso_ini = request.getParameter("fingreso_ini");
String fingreso_fin = request.getParameter("fingreso_fin");
String salario_ini = request.getParameter("salario_ini");
String salario_fin = request.getParameter("salario_fin");
String rata_ini = request.getParameter("rata_ini");
String rata_fin = request.getParameter("rata_fin");
String horas_ini = request.getParameter("horas_ini");
String horas_fin = request.getParameter("horas_fin");
String cargo = request.getParameter("cargo");
String unidad = request.getParameter("unidad");
String metodo = request.getParameter("metodo");
String fijo = request.getParameter("fijo");
String limite = request.getParameter("limite");
if (fingreso_ini == null) fingreso_ini = "";
if (fingreso_fin == null) fingreso_fin = "";
if (salario_ini == null) salario_ini = "";
if (salario_fin == null) salario_fin = "";
if (rata_ini == null) rata_ini = "";
if (rata_fin == null) rata_fin = "";
if (horas_ini == null) horas_ini = "";
if (horas_fin == null) horas_fin = "";
if (cargo == null) cargo = "";
if (unidad == null) unidad = "";
if (metodo == null) metodo = "1";
if (fijo == null || fijo.trim().equals("")) fijo = "0";
if (limite == null || limite.trim().equals("")) limite = "0";
if (anio == null) anio = "";
if (noPlanilla == null) noPlanilla = "";
if (codPlanilla == null) codPlanilla = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	if (!empId.trim().equals("")) { sbFilter.append(" and upper(a.emp_id) like '%"); sbFilter.append(empId.toUpperCase()); sbFilter.append("%'"); }
	if (!numEmpleado.trim().equals("")) { sbFilter.append(" and upper(a.num_empleado) like '%"); sbFilter.append(numEmpleado.toUpperCase()); sbFilter.append("%'"); }
	if (!cedula.trim().equals("")) { sbFilter.append(" and upper(a.cedula1) like '%"); sbFilter.append(cedula.toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.nombre_empleado) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }


	if (fp.equalsIgnoreCase("rrhh_otros_pagos"))
	{
		if (fFinal.trim().equals("") || fInicio.trim().equals("")) throw new Exception("La fecha Inicial y Final del Periodo son requeridos. Por favor intente nuevamente!");

		sbFilter.append(" and exists (select 'x' from tbl_pla_ct_empleado where compania = a.compania and emp_id = a.emp_id");
		if (!fg.equalsIgnoreCase("O"))
		{
			sbFilter.append(" and grupo = ");
			sbFilter.append(grupo);
		}
		sbFilter.append(" and fecha_ingreso_grupo <= to_date('");
		sbFilter.append(fFinal);
		sbFilter.append("','dd/mm/yyyy')");
		sbFilter.append(" and (fecha_egreso_grupo is null or fecha_egreso_grupo >= to_date('");
		sbFilter.append(fInicio);
		sbFilter.append("','dd/mm/yyyy')))");
	}
	else if (fp.equalsIgnoreCase("rrhh_otros_aumentos"))
	{
		sbCols.append(", (select denominacion from tbl_pla_cargo where codigo = a.cargo and compania = a.compania) as cargo_desc");
		sbCols.append(", ");
		if (metodo.equals("1")) { sbCols.append(fijo);  }
		else if (metodo.equals("2")) { sbCols.append("round((nvl(a.rata_hora,0) + "); sbCols.append(fijo); sbCols.append(") * nvl(b.cant_horas_mes,0),2) - a.salario_base"); }
		else if (metodo.equals("3")) { sbCols.append("decode("); sbCols.append(limite); sbCols.append(",0,a.salario_base,"); sbCols.append(limite); sbCols.append(") - a.salario_base"); }
		else if (metodo.equals("4")) { sbCols.append("round("); sbCols.append(limite); sbCols.append(" * nvl(b.cant_horas_mes,0),2) - a.salario_base"); }
		else sbCols.append("0");
		sbCols.append(" as aumento");

		sbTable.append(", tbl_pla_horario_trab b");
		sbFilter.append(" and a.salario_base > 0 and a.estado not in (3,13) and a.horario = b.codigo and a.compania = b.compania");

		if (!fingreso_ini.trim().equals("")) { sbFilter.append(" and a.fecha_ingreso >= to_date('"); sbFilter.append(fingreso_ini); sbFilter.append("','dd/mm/yyyy')"); }
		if (!fingreso_fin.trim().equals("")) { sbFilter.append(" and a.fecha_ingreso <= to_date('"); sbFilter.append(fingreso_fin); sbFilter.append("','dd/mm/yyyy')"); }
		if (!salario_ini.trim().equals("")) { sbFilter.append(" and a.salario_base >= "); sbFilter.append(salario_ini); }
		if (!salario_fin.trim().equals("")) { sbFilter.append(" and a.salario_base <= "); sbFilter.append(salario_fin); }
		if (!rata_ini.trim().equals("")) { sbFilter.append(" and a.rata_hora >= "); sbFilter.append(rata_ini); }
		if (!rata_fin.trim().equals("")) { sbFilter.append(" and a.rata_hora <= "); sbFilter.append(rata_fin); }
		if (!horas_ini.trim().equals("")) { sbFilter.append(" and round(nvl(b.cant_horas_mes,0),2) >= "); sbFilter.append(horas_ini); }
		if (!horas_fin.trim().equals("")) { sbFilter.append(" and round(nvl(b.cant_horas_mes,0),2) <= "); sbFilter.append(horas_fin); }
		if (!cargo.trim().equals("")) { sbFilter.append(" and a.cargo = "); sbFilter.append(cargo); }
		if (!unidad.trim().equals("")) { sbFilter.append(" and a.ubic_seccion = "); sbFilter.append(unidad); }
	}
	else if (fp.equalsIgnoreCase("planillaAjuste"))
	{
		sbCols.append(", (select denominacion from tbl_pla_cargo where codigo = a.cargo and compania = a.compania) as cargo_desc");
		sbCols.append(", a.unidad_organi unidad,( select descripcion  from tbl_sec_unidad_ejec where codigo = a.unidad_organi and compania = a.compania) as descUnidad");
	}
	if (request.getParameter("empId") != null)
	{
		sbSql = new StringBuffer();
		sbSql.append("select a.emp_id, a.nombre_empleado, a.cedula1 as cedula, a.num_empleado, a.provincia, a.sigla, a.tomo, a.asiento, a.estado, a.cargo, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, a.salario_base, nvl(to_char(a.fecha_ult_aumento,'dd/mm/yyyy'),' ') as fecha_ult_aumento");
		sbSql.append(sbCols);
		sbSql.append(" from vw_pla_empleado a");
		sbSql.append(sbTable);
		sbSql.append(" where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 2");

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from vw_pla_empleado a"+sbTable+" where a.compania = "+session.getAttribute("_companyId")+sbFilter);
	}

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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Empleado - '+document.title;
function setPeriodoPago(obj,k){if(obj.checked){var empId=eval('document.formEmpleado.emp_id'+k).value;var estado=eval('document.formEmpleado.estado'+k).value;var c=splitCols(getDBData('<%=request.getContextPath()%>','replace(fn_rrhh_periodo_pago(<%=session.getAttribute("_companyId")%>,'+empId+','+estado+',\'<%=fFinal%>\',\'ANIO.PERIODO\'),\'.\',\'|\')','dual','',''));if(c==null){eval('document.formEmpleado.anio_pago'+k).value='<%=anio%>';eval('document.formEmpleado.periodo_pago'+k).value='<%=periodo%>';}else{eval('document.formEmpleado.anio_pago'+k).value=c[0];eval('document.formEmpleado.periodo_pago'+k).value=c[1];}}}
function checkMetodo(opt,isFijo){document.search00.metodo.value=opt;if(isFijo)document.search00.limite.value='';else document.search00.fijo.value='';document.search00.fijo.readOnly=!isFijo;document.search00.limite.readOnly=isFijo;document.search00.fijo.className='Text10 FormDataObject'+((isFijo)?'Enabled':'Disabled');document.search00.limite.className='Text10 FormDataObject'+((isFijo)?'Disabled':'Enabled');}
function doAction(){<%if (fp.equalsIgnoreCase("rrhh_otros_aumentos")){%>checkMetodo(<%=metodo%>,<%=(metodo.equals("1") || metodo.equals("2"))%>);<%}%>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(fp.equalsIgnoreCase("rrhh_otros_aumentos"))%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("periodo",periodo)%>
<%=fb.hidden("fCierre",fCierre)%>
<%=fb.hidden("fInicio",fInicio)%>
<%=fb.hidden("fFinal",fFinal)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("codPlanilla",codPlanilla)%>
<%=fb.hidden("noPlanilla",noPlanilla)%>


		<%
		if (fp.equalsIgnoreCase("rrhh_otros_aumentos")) {
		//fb.appendJsValidation("if(((document.search00.metodo.value==1||document.search00.metodo.value==2)&&document.search00.fijo.value.trim()=='')||((document.search00.metodo.value==3||document.search00.metodo.value==4)&&document.search00.limite.value.trim()=='')){alert('Por favor indique el Monto del Aumento antes de realizar una búsqueda!');error++;}");
		%>
		<%=fb.hidden("metodo",metodo)%>
		<tr>
			<td colspan="2">
				<table width="100%" align="center" cellpadding="1" cellspacing="0">
				<tr class="TextHeader">
					<td colspan="8" align="center"><cellbytelabel>M E T O D O</cellbytelabel> &nbsp; <cellbytelabel>D E</cellbytelabel> &nbsp; <cellbytelabel>A U M E N T O</cellbytelabel></td>
				</tr>
				<tr class="TextHeader">
					<td width="18%" align="right"><cellbytelabel>AUMENTAR VALOR FIJO</cellbytelabel></td>
					<td width="10%"><%=fb.radio("metodoOpt","1",(metodo.trim().equals("") || metodo.equals("1")),false,false,null,null,"onClick=\"javascript:checkMetodo(1,true)\"")%> <cellbytelabel>A SALARIO</cellbytelabel></td>
					<td width="8%"><%=fb.radio("metodoOpt","2",(metodo.equals("2")),false,false,null,null,"onClick=\"javascript:checkMetodo(2,true)\"")%> <cellbytelabel>A RxH</cellbytelabel></td>
					<td width="14%"><%=fb.decBox("fijo",fijo,false,false,false,11,8.2,"Text10","","")%></td>
					<td width="18%" align="right"><cellbytelabel>AUMENTAR VALOR LIMITE</cellbytelabel></td>
					<td width="10%"><%=fb.radio("metodoOpt","3",(metodo.equals("3")),false,false,null,null,"onClick=\"javascript:checkMetodo(3,false)\"")%> <cellbytelabel>A SALARIO</cellbytelabel></td>
					<td width="8%"><%=fb.radio("metodoOpt","4",(metodo.equals("4")),false,false,null,null,"onClick=\"javascript:checkMetodo(4,false)\"")%> <cellbytelabel>A RxH</cellbytelabel></td>
					<td width="14%"><%=fb.decBox("limite",limite,false,false,false,11,8.2,"Text10","","")%></td>
				</tr>
				</table>
			</td>
		</tr>
		<% } %>
		<tr class="TextFilter">
			<td colspan="2">
				<cellbytelabel>ID Empl</cellbytelabel>.
				<%=fb.textBox("empId","",false,false,false,10,10,"Text10","","")%>
				<cellbytelabel>No. Empl</cellbytelabel>.
				<%=fb.textBox("numEmpleado","",false,false,false,15,15,"Text10","","")%>
				<cellbytelabel>C&eacute;dula</cellbytelabel>
				<%=fb.textBox("cedula","",false,false,false,15,15,"Text10","","")%>
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,40,50,"Text10","","")%>
				<%=(fp.equalsIgnoreCase("rrhh_otros_aumentos"))?"":fb.submit("go","Ir",false,false,"Text10","","")%>
			</td>
		</tr>
		<% if (fp.equalsIgnoreCase("rrhh_otros_aumentos")) { %>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel>Fecha Ingreso</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="fingreso_ini"/>
				<jsp:param name="valueOfTBox1" value="<%=fingreso_ini%>"/>
				<jsp:param name="nameOfTBox2" value="fingreso_fin"/>
				<jsp:param name="valueOfTBox2" value="<%=fingreso_fin%>"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
			</td>
			<td width="50%">
				<cellbytelabel>Salario Base Desde</cellbytelabel>
				<%=fb.decBox("salario_ini","",false,false,false,11,8.2,"Text10","","")%>
				<cellbytelabel>Hasta</cellbytelabel>
				<%=fb.decBox("salario_fin","",false,false,false,11,8.2,"Text10","","")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>Rata x Hora Desde</cellbytelabel>
				<%=fb.decBox("rata_ini","",false,false,false,6,3.2,"Text10","","")%>
				<cellbytelabel>Hasta</cellbytelabel>
				<%=fb.decBox("rata_fin","",false,false,false,6,3.2,"Text10","","")%>
			</td>
			<td>
				<cellbytelabel>Horas Trabajadas x Mes Desde</cellbytelabel>
				<%=fb.decBox("horas_ini","",false,false,false,11,8.2,"Text10","","")%>
				<cellbytelabel>Hasta</cellbytelabel>
				<%=fb.decBox("horas_fin","",false,false,false,11,8.2,"Text10","","")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				<cellbytelabel>Cargo / Posici&oacute;n</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, denominacion, codigo from tbl_pla_cargo where compania = "+session.getAttribute("_companyId")+" order by 2","cargo",cargo,false,false,0,"Text10",null,null,null,"T")%>
			</td>
			<td>
				<cellbytelabel>Unidad Adm</cellbytelabel>.
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_sec_unidad_ejec where compania = "+session.getAttribute("_companyId")+" and codigo >= 1 and codigo <= 100 order by 2","unidad",unidad,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir",false,false,"Text10","","")%>
			</td>
		</tr>
		<% } %>
<%=fb.formEnd(fp.equalsIgnoreCase("rrhh_otros_aumentos"))%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("formEmpleado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextVal",""+(nxtVal))%>
<%=fb.hidden("previousVal",""+(preVal))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("periodo",periodo)%>
<%=fb.hidden("fCierre",fCierre)%>
<%=fb.hidden("fInicio",fInicio)%>
<%=fb.hidden("fFinal",fFinal)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("metodo",metodo)%>
<%=fb.hidden("fijo",fijo)%>
<%=fb.hidden("limite",limite)%>
<%=fb.hidden("fingreso_ini",fingreso_ini)%>
<%=fb.hidden("fingreso_fin",fingreso_fin)%>
<%=fb.hidden("salario_ini",salario_ini)%>
<%=fb.hidden("salario_fin",salario_fin)%>
<%=fb.hidden("rata_ini",rata_ini)%>
<%=fb.hidden("rata_fin",rata_fin)%>
<%=fb.hidden("horas_ini",horas_ini)%>
<%=fb.hidden("horas_fin",horas_fin)%>
<%=fb.hidden("cargo",cargo)%>
<%=fb.hidden("unidad",unidad)%>
<%=fb.hidden("codPlanilla",codPlanilla)%>
<%=fb.hidden("noPlanilla",noPlanilla)%>

<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveT","Agregar",true,false)%>
				<%=fb.submit("continueT","Agregar y Continuar",true,false)%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<% if (fp.equalsIgnoreCase("rrhh_otros_aumentos")) { %>
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>ID Empl</cellbytelabel>.</td>
			<td width="9%"><cellbytelabel>No. Empl</cellbytelabel>.</td>
			<td width="15%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
			<td width="32%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Sueldo al</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Sueldo Actual</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Aumento</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Nuevo Sueldo</cellbytelabel></td>
			<td width="3%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todos los empleados listados!")%></td>
		</tr>
<% } else { %>
		<tr class="TextHeader" align="center">
			<td width="15%"><cellbytelabel>ID Empleado</cellbytelabel></td>
			<td width="15%"><cellbytelabel>No. Empleado</cellbytelabel></td>
			<td width="17%"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
			<td width="50%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="3%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todos los empleados listados!")%></td>
		</tr>
<% } %>
<% if (al.size() == 0) { %>
		<tr>
			<td colspan="9" class="TextRow01" align="center"><font color="#FF0000">
			<% if (request.getParameter("empId") == null) { %>
			<cellbytelabel>I N T R O D U Z C A &nbsp; P A R A M E T R O S &nbsp; P A R A &nbsp; B U S Q U E D A</cellbytelabel>
			<% } else { %>
			<cellbytelabel>R E G I S T R O ( S ) &nbsp; N O &nbsp; E N C O N T R A D O ( S )</cellbytelabel>
			<% } %>
			</font></td>
		</tr>
<% } %>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	boolean isChecked = ((fp.equalsIgnoreCase("rrhh_reporte_memo") || fp.equalsIgnoreCase("rrhh_otros_aumentos")|| fp.equalsIgnoreCase("planillaAjuste")) && vEmp.contains(cdo.getColValue("emp_id")));
	boolean isDisabled = ((fp.equalsIgnoreCase("rrhh_reporte_memo") || fp.equalsIgnoreCase("rrhh_otros_aumentos")|| fp.equalsIgnoreCase("planillaAjuste")) && vEmp.contains(cdo.getColValue("emp_id")));
	String onCheck = "";
	if (fp.equalsIgnoreCase("rrhh_otros_pagos")) onCheck = "onClick=\"javascript:setPeriodoPago(this,"+i+");\"";
	double nuevoSal = 0.00;
	if (fp.equalsIgnoreCase("rrhh_otros_aumentos")) nuevoSal = Double.parseDouble(cdo.getColValue("salario_base")) + Double.parseDouble(cdo.getColValue("aumento"));
%>
		<%=fb.hidden("emp_id"+i,cdo.getColValue("emp_id"))%>
		<%=fb.hidden("nombre_empleado"+i,cdo.getColValue("nombre_empleado"))%>
		<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
		<%=fb.hidden("num_empleado"+i,cdo.getColValue("num_empleado"))%>
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("anio_pago"+i,cdo.getColValue("anio_pago"))%>
		<%=fb.hidden("periodo_pago"+i,cdo.getColValue("periodo_pago"))%>

		<%=fb.hidden("cargo"+i,cdo.getColValue("cargo"))%>
		<%=fb.hidden("fecha_ingreso"+i,cdo.getColValue("fecha_ingreso"))%>
		<%=fb.hidden("salario_base"+i,cdo.getColValue("salario_base"))%>
		<%=fb.hidden("fecha_ult_aumento"+i,cdo.getColValue("fecha_ult_aumento"))%>
		<%=fb.hidden("cargo_desc"+i,cdo.getColValue("cargo_desc"))%>

		<%=fb.hidden("aumento"+i,cdo.getColValue("aumento"))%>
		<%=fb.hidden("nuevo_salario"+i,""+nuevoSal)%>
		<%=fb.hidden("descUnidad"+i,cdo.getColValue("descUnidad"))%>
		<%=fb.hidden("unidad"+i,cdo.getColValue("unidad"))%>
		

	<% if (fp.equalsIgnoreCase("rrhh_otros_aumentos")) { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("emp_id")%></td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td><%=cdo.getColValue("cedula")%></td>
			<td><%=cdo.getColValue("nombre_empleado")%></td>
			<td align="center"><%=cdo.getColValue("fecha_ult_aumento")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("salario_base"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("aumento"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(nuevoSal)%></td>
			<td align="center"><%=(isChecked)?"Elegido":fb.checkbox("check"+i,cdo.getColValue("emp_id"),isChecked,isDisabled,null,null,onCheck)%></td>
		</tr>
	<% } else { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("emp_id")%></td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td><%=cdo.getColValue("cedula")%></td>
			<td><%=cdo.getColValue("nombre_empleado")%></td>
			<td align="center"><%=(isChecked)?"Elegido":fb.checkbox("check"+i,cdo.getColValue("emp_id"),isChecked,isDisabled,null,null,onCheck)%></td>
		</tr>
	<% } %>
<% } %>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("saveB","Agregar",true,false)%>
				<%=fb.submit("continueB","Agregar y Continuar",true,false)%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		System.out.println(" check  "+i+" === "+request.getParameter("check"+i));
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setKey(iEmp.size() + 1);
			cdo.setAction("I");
			cdo.addColValue("codigo","0");
			cdo.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
			cdo.addColValue("emp_id",request.getParameter("emp_id"+i));
			cdo.addColValue("nombre_empleado",request.getParameter("nombre_empleado"+i));
			cdo.addColValue("cedula",request.getParameter("cedula"+i));
			cdo.addColValue("num_empleado",request.getParameter("num_empleado"+i));
			cdo.addColValue("provincia",request.getParameter("provincia"+i));
			cdo.addColValue("sigla",request.getParameter("sigla"+i));
			cdo.addColValue("tomo",request.getParameter("tomo"+i));
			cdo.addColValue("asiento",request.getParameter("asiento"+i));
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("grupo",grupo);
			cdo.addColValue("tipo_trx","");
			cdo.addColValue("sub_tipo_trx","");
			cdo.addColValue("anio_pago",request.getParameter("anio_pago"+i));
			cdo.addColValue("periodo_pago",request.getParameter("periodo_pago"+i));

			cdo.setKey(iEmp.size() + 1);
			cdo.setAction("I");
			cdo.addColValue("secuencia","0");
			cdo.addColValue("tipo_aumento","4");
			cdo.addColValue("tipo_aumento_desc","OTROS");
			cdo.addColValue("cargo",request.getParameter("cargo"+i));
			cdo.addColValue("fecha_ingreso",request.getParameter("fecha_ingreso"+i));
			cdo.addColValue("sueldo_anterior",request.getParameter("salario_base"+i));
			cdo.addColValue("fecha_anterior",request.getParameter("fecha_ult_aumento"+i));
			cdo.addColValue("cargo_desc",request.getParameter("cargo_desc"+i));
			cdo.addColValue("aumento",request.getParameter("aumento"+i));
			cdo.addColValue("nuevo_salario",request.getParameter("nuevo_salario"+i));
			cdo.addColValue("usuario_creacion","");
			cdo.addColValue("fecha_creacion","");
			cdo.addColValue("usuario_modificacion","");
			cdo.addColValue("fecha_modificacion","");
			System.out.println("salario_base  "+request.getParameter("descUnidad"+i));
			cdo.addColValue("salario",request.getParameter("salario_base"+i));
			cdo.addColValue("descUnidad",request.getParameter("descUnidad"+i));
			cdo.addColValue("unidad",request.getParameter("unidad"+i));
			cdo.addColValue("fPago","2"); 
			cdo.addColValue("descuentos","0"); 
			

			try
			{
				iEmp.put(cdo.getKey(),cdo);
				vEmp.add(cdo.getColValue("emp_id"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&grupo="+grupo+"&anio="+anio+"&mes="+mes+"&quincena="+quincena+"&periodo="+periodo+"&fCierre="+fCierre+"&fInicio="+fInicio+"&fFinal="+fFinal+"&fecha="+fecha+"&empId="+empId+"&numEmpleado="+numEmpleado+"&cedula="+cedula+"&nombre="+nombre+"&metodo="+metodo+"&fijo="+fijo+"&limite="+limite+"&fingreso_ini="+fingreso_ini+"&fingreso_fin="+fingreso_fin+"&salario_ini="+salario_ini+"&salario_fin="+salario_fin+"&rata_ini="+rata_ini+"&rata_fin="+rata_fin+"&horas_ini="+horas_ini+"&horas_fin="+horas_fin+"&cargo="+cargo+"&unidad="+unidad+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codPlanilla="+request.getParameter("codPlanilla")+"&noPlanilla="+request.getParameter("noPlanilla"));
		return;
	}
	else if (request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&grupo="+grupo+"&anio="+anio+"&mes="+mes+"&quincena="+quincena+"&periodo="+periodo+"&fCierre="+fCierre+"&fInicio="+fInicio+"&fFinal="+fFinal+"&fecha="+fecha+"&empId="+empId+"&numEmpleado="+numEmpleado+"&cedula="+cedula+"&nombre="+nombre+"&metodo="+metodo+"&fijo="+fijo+"&limite="+limite+"&fingreso_ini="+fingreso_ini+"&fingreso_fin="+fingreso_fin+"&salario_ini="+salario_ini+"&salario_fin="+salario_fin+"&rata_ini="+rata_ini+"&rata_fin="+rata_fin+"&horas_ini="+horas_ini+"&horas_fin="+horas_fin+"&cargo="+cargo+"&unidad="+unidad+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codPlanilla="+request.getParameter("codPlanilla")+"&noPlanilla="+request.getParameter("noPlanilla"));
		return;
	}
	else if (request.getParameter("continueT") != null || request.getParameter("continueB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&fg="+fg+"&mode="+mode+"&grupo="+grupo+"&anio="+anio+"&mes="+mes+"&quincena="+quincena+"&periodo="+periodo+"&fCierre="+fCierre+"&fInicio="+fInicio+"&fFinal="+fFinal+"&fecha="+fecha+"&empId="+empId+"&numEmpleado="+numEmpleado+"&cedula="+cedula+"&nombre="+nombre+"&metodo="+metodo+"&fijo="+fijo+"&limite="+limite+"&fingreso_ini="+fingreso_ini+"&fingreso_fin="+fingreso_fin+"&salario_ini="+salario_ini+"&salario_fin="+salario_fin+"&rata_ini="+rata_ini+"&rata_fin="+rata_fin+"&horas_ini="+horas_ini+"&horas_fin="+horas_fin+"&cargo="+cargo+"&unidad="+unidad+"&nextVal="+request.getParameter("nextVal")+"&previousVal="+request.getParameter("previousVal")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&codPlanilla="+request.getParameter("codPlanilla")+"&noPlanilla="+request.getParameter("noPlanilla"));
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<% if (fp.equalsIgnoreCase("rrhh_otros_pagos")) { %>
window.opener.location='../rhplanilla/reg_emp_otros_pagos_det.jsp?fg=<%=fg%>&mode=<%=mode%>&grupo=<%=grupo%>&anio=<%=anio%>&mes=<%=mes%>&quincena=<%=quincena%>&periodo=<%=periodo%>&fCierre=<%=fCierre%>&fInicio=<%=fInicio%>&fFinal=<%=fFinal%>&change=1';
<% } else if (fp.equalsIgnoreCase("rrhh_reporte_memo")) { %>
window.opener.location='../rhplanilla/param_reportes_rrhh_memo_emp.jsp?change=1';
<% } else if (fp.equalsIgnoreCase("rrhh_otros_aumentos")) { %>
window.opener.location='../rhplanilla/list_aumentos_otros.jsp?fg=<%=fg%>&fecha=<%=fecha%>&change=1';
<% } else if (fp.equalsIgnoreCase("planillaAjuste")) { %>
window.opener.location='../rhplanilla/reg_pagoajuste_config.jsp?anio=<%=anio%>&codPlanilla=<%=codPlanilla%>&noPlanilla=<%=noPlanilla%>&change=1&fg=<%=fg%>&mode=<%=mode%>';
<% } %>

window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>