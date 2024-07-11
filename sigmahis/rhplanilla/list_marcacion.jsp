<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="IXml" scope="page" class="issi.admin.XMLCreator"/>
<%
/**
==================================================================================
sct0095_correc  marcacion mensual de empleados activos: permite editar y consultar
sct0095_ces     marcación mensual de empleados activos y cesantes: solo para consultar
sct0095_dia     marcación diaria de empleados activos: solo para consultar

mensual: Año, Mes, Quincena
diario: Fecha
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
IXml.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbField = new StringBuffer();
StringBuffer sbTable = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbOrder = new StringBuffer();
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String cesante = request.getParameter("cesante");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String fecha = request.getParameter("fecha");
String empId = request.getParameter("empId");
String ubicacion = request.getParameter("ubicacion");
String numEmpleado = request.getParameter("numEmpleado");
String nombre = request.getParameter("nombre");
String aprobado = request.getParameter("aprobado");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String iDate = "";
String fDate = "";

if (grupo == null) grupo = "";
if (area == null) area = "";
if (cesante == null) cesante = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (quincena == null) quincena = "1";
if (fecha == null) fecha = "";
if (empId == null) empId = "";
if (ubicacion == null) ubicacion = "";
if (numEmpleado == null) numEmpleado = "";
if (nombre == null) nombre = "";
if (aprobado == null) aprobado = "";

StringBuffer sbSqlGrupo = new StringBuffer();
sbSqlGrupo.append("select codigo, codigo||' - '||descripcion from tbl_pla_ct_grupo where compania = ");
sbSqlGrupo.append(session.getAttribute("_companyId"));
if (!UserDet.getUserProfile().contains("0")) {
	sbSqlGrupo.append(" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '");
	sbSqlGrupo.append(session.getAttribute("_userName"));
	sbSqlGrupo.append("')");
}
sbSqlGrupo.append(" order by descripcion");
if (grupo.trim().equals("")) {
	cdo = SQLMgr.getData(sbSqlGrupo.toString());
	if (cdo != null) grupo = cdo.getColValue("codigo");
}
StringBuffer sbSqlArea = new StringBuffer();
sbSqlArea.append("select codigo as value_col, codigo||' - '||nombre as label_col, compania||'-'||grupo as key_col from tbl_pla_ct_area_x_grupo where estado = 1");
IXml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+"/areaXGrupo.xml",sbSqlArea.toString(),false);
if (area.trim().equals("")) {
	sbSqlArea.append(" and compania = ");
	sbSqlArea.append(session.getAttribute("_companyId"));
	sbSqlArea.append(" and grupo = ");
	sbSqlArea.append(grupo);
	cdo = SQLMgr.getData(sbSqlArea.toString());
	if (cdo != null) {
	if (area != "") area = cdo.getColValue("value_col");
	else area = "";
	}
}
if (fecha.trim().equals("")) {
	if (anio.trim().equals("")) anio = cDate.substring(6,10);
	if (mes.trim().equals("")) mes = cDate.substring(3,5);
	if (quincena.equals("1")) {
		iDate = "to_date('01/"+mes+"/"+anio+"','dd/mm/yyyy')";
		fDate = "to_date('15/"+mes+"/"+anio+"','dd/mm/yyyy')";
	} else if (quincena.equals("2")) {
		iDate = "to_date('16/"+mes+"/"+anio+"','dd/mm/yyyy')";
		fDate = "last_day("+iDate+")";
	} else {
		iDate = "to_date('01/"+mes+"/"+anio+"','dd/mm/yyyy')";
		fDate = "last_day("+iDate+")";
	}
} else {
	anio = "";
	mes = "";
	quincena = "";
	iDate = "to_date('"+fecha+"','dd/mm/yyyy')";
	fDate = "to_date('"+fecha+"','dd/mm/yyyy')";
}

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	/* tbl_pla_ct_empleado */
	sbField.append(", z.*");
	sbTable.append(", (select emp_id, provincia, sigla, tomo, asiento, num_empleado,ubicacion_fisica,(select a.nombre from tbl_pla_ct_area_x_grupo a where a.codigo=tbl_pla_ct_empleado.ubicacion_fisica and a.grupo=tbl_pla_ct_empleado.grupo ) as descripcionArea ");
	sbTable.append(" from tbl_pla_ct_empleado where grupo = ");
	sbTable.append(grupo);


if (area != "" )
	{
	sbTable.append(" and ubicacion_fisica = ");
	sbTable.append(area);
	}

	sbTable.append(" and compania = ");
	sbTable.append(session.getAttribute("_companyId"));
	if (cesante.trim().equals("")) {
		sbTable.append(" and fecha_ingreso_grupo <= ");
		sbTable.append(fDate);
		sbTable.append(" and (fecha_egreso_grupo is null or fecha_egreso_grupo >= ");
		sbTable.append(iDate);
		sbTable.append(")");
	} else if (cesante.trim().equals("X")) {
		sbTable.append(" and (fecha_egreso_grupo is null or fecha_egreso_grupo > ");
		sbTable.append(fDate);
		sbTable.append(")");
	}
	sbTable.append(") z");

	/* tbl_pla_empleado */
	sbField.append(", y.nombre_empleado as nombre, y.cedula1 as cedula ");
	sbTable.append(", vw_pla_empleado y");
	sbFilter.append(" and z.emp_id = y.emp_id");
				/*
				no incluir los jefes
				'GERENTE%'
				 AND   C.DENOMINACION NOT LIKE 'DIRECTOR%'
				 AND   C.DENOMINACION NOT LIKE 'SUB-DIRECTOR%'
				 AND   C.DENOMINACION NOT LIKE 'SUB-JEFE%'
				 AND   C.DENOMINACION NOT LIKE 'VICE-PRESID%'
				 AND   C.DENOMINACION NOT LIKE 'JEFE DE%'
		 AND   C.DENOMINACION NOT LIKE 'CONTRAL%'
				*/
	sbOrder.append(", 7");

	if (fecha.trim().equals("")) {
		sbField.append(", (select count(*) from tbl_pla_marcacion where emp_id = z.emp_id");
		if (iDate.equals(fDate)) {
			sbField.append(" and to_date(dia||'/'||mes||'/'||anio,'dd/mm/yyyy') = ");
			sbField.append(iDate);
		} else {
			sbField.append(" and to_date(dia||'/'||mes||'/'||anio,'dd/mm/yyyy') between ");
			sbField.append(iDate);
			sbField.append(" and ");
			sbField.append(fDate);
		}
		sbField.append(") as nDial");
	} else {
		/*tbl_pla_marcacion*/
		sbField.append(", x.anio, lpad(x.mes,2,'0') as mes, lpad(x.dia,2,'0') as dia, nvl(to_char(x.entrada,'hh12:mi am'),' ') as entrada, nvl(to_char(x.salida_com,'hh12:mi am'),' ') as salida_com, nvl(to_char(x.entrada_com,'hh12:mi am'),' ') as entrada_com, nvl(to_char(x.salida,'hh12:mi am'),' ') as salida, nvl(x.programa,' ') as programa, nvl(x.turno,' ') as turno, substr(to_char(to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy'),'DAY','NLS_DATE_LANGUAGE=SPANISH'),1,3) as dia_semana, decode(x.turno,null,'CODIGO NO DEFINIDO',case when x.programa = 'S' then (select descripcion from tbl_pla_ct_turno where codigo = x.turno and compania = x.compania) else (select 'DE '||to_char(hora_entrada,'HH12:MI AM')||decode(hora_salida_almuerzo,null,'','  A  '||to_char(hora_salida_almuerzo,'HH12:MI AM'))||decode(hora_entrada_almuerzo,null,'','  Y  DE  '||to_char(hora_entrada_almuerzo,'HH12:MI AM'))||'  A  '||to_char(hora_salida,'HH12:MI AM') from tbl_pla_horario_trab where codigo = x.turno and compania = x.compania) end) as turno_dsp");
		sbTable.append(", tbl_pla_marcacion x");
		sbFilter.append(" and z.emp_id = x.emp_id");
		if (iDate.equals(fDate)) {
			sbFilter.append(" and to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy') = ");
			sbFilter.append(iDate);
		} else {
			sbFilter.append(" and to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy') between ");
			sbFilter.append(iDate);
			sbFilter.append(" and ");
			sbFilter.append(fDate);
		}
		sbOrder.append(", x.anio desc, x.mes desc, x.dia");
	}

	if (!empId.trim().equals("")) { sbFilter.append(" and z.empId = "); sbFilter.append(empId); }
	if (!numEmpleado.trim().equals("")) { sbFilter.append(" and z.num_empleado like '"); sbFilter.append(numEmpleado); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(y.primer_nombre||' '||y.primer_apellido||' '||case when y.sexo = 'F' and y.apellido_casada is not null then y.apellido_casada else y.segundo_apellido end) like '"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }

	if (sbTable.length() > 1) {
		sbSql.append("select");
		if (sbOrder.length() > 1) sbSql.append(sbField.substring(1));
		else sbSql.append(" *");
		sbSql.append(" from");
		sbSql.append(sbTable.substring(1));
		if (sbFilter.length() > 4) { sbSql.append(" where"); sbSql.append(sbFilter.substring(4)); }
		if (sbOrder.length() > 1) { sbSql.append(" order by"); sbSql.append(sbOrder.substring(1)); }
	}
	if (sbSql.length() > 0) {
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		sbSql = new StringBuffer();
		sbSql.append("select count(*) from");
		sbSql.append(sbTable.substring(1));
		if (sbFilter.length() > 4) { sbSql.append(" where"); sbSql.append(sbFilter.substring(4)); }
		rowCount = CmnMgr.getCount(sbSql.toString());
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
document.title = 'Marcación - '+document.title;
function viewDial(empId,fecha){showPopWin('../rhplanilla/marcacion.jsp?empId='+empId+'&fecha='+fecha,winWidth*.65,_contentHeight*.85,null,null,'');}
function printDailyReport(){abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_asistencia_diaria.rptdesign&pGrupo=<%=grupo%>&pArea=<%=area%>&pFecha=<%=fecha%>');}
function printReport(empId,ubicacion){
  empId = empId || 'ALL';
  ubicacion = ubicacion || $("#area").val() || 'ALL';

  var xParam='&pEmpId='+empId;
  if(empId==undefined||empId==null)xParam='';
  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_asistencia.rptdesign&pGrupo=<%=grupo%>&pArea='+ubicacion+'&pInicial=<%=issi.admin.IBIZEscapeChars.forURL(iDate)%>&pFinal=<%=issi.admin.IBIZEscapeChars.forURL(fDate)%>'+xParam);
}
function view(empId,ubicacion){abrir_ventana('../rhplanilla/reg_marcacion.jsp?mode=view&grupo=<%=grupo%>&area='+ubicacion+'&iDate=<%=issi.admin.IBIZEscapeChars.forURL(iDate)%>&fDate=<%=issi.admin.IBIZEscapeChars.forURL(fDate)%>&empId='+empId);}
function edit(empId,ubicacion){abrir_ventana('../rhplanilla/reg_marcacion.jsp?mode=edit&grupo=<%=grupo%>&area='+ubicacion+'&iDate=<%=issi.admin.IBIZEscapeChars.forURL(iDate)%>&fDate=<%=issi.admin.IBIZEscapeChars.forURL(fDate)%>&empId='+empId);}
function printSchedule(numEmpleado,anio,mes){if(anio==undefined||anio==null||anio.trim()=='')anio='<%=anio%>';if(mes==undefined||mes==null||mes.trim()=='')mes='<%=mes%>';abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/programa_turno.rptdesign&cpGrupo=<%=grupo%>&cpArea=<%=area%>&pAnio='+anio+'&pMonthId='+mes+'&pNumEmpleado='+numEmpleado+'&pAprobado=S');}
function printChrono(empId,ubicacion){abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_asistencia_trx.rptdesign&pGrupo=<%=grupo%>&pArea='+ubicacion+'&pFecha=<%=(fecha.trim().equals(""))?"01/"+mes+"/"+anio:fecha%>&pEmpId='+empId);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO - GRUPOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
		<tr class="TextFilter">
			<td>
				Grupo<%=fb.select(ConMgr.getConnection(),sbSqlGrupo.toString(),"grupo",grupo,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/areaXGrupo.xml','area','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','')\"")%>
				Ubic./Area Trab.<%=fb.select("area","","",false,false,0,"Text10","","")%>
				<script language="javascript">
				loadXML('../xml/areaXGrupo.xml','area','<%=area%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")+"-"+grupo%>','KEY_COL','T');


				</script>
				<label for="cesante">Incluir Cesantes</label><%=fb.checkbox("cesante","X",(cesante.equalsIgnoreCase("X")),false,null,null,null)%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				A&ntilde;o<%=fb.textBox("anio",anio,false,false,false,2,"Text10","","")%>
				Mes<%=fb.select(ConMgr.getConnection(),"select lpad(level,2,'0') as id, to_char(to_date(lpad(level,2,'0'),'mm'),'MONTH','NLS_DATE_LANGUAGE=SPANISH') as description, lpad(level,2,'0') as title from dual connect by level <= 12","mes",mes,false,false,0,"Text10",null,null,null,"T")%>
				Quincena<%=fb.select("quincena","1=I,2=II",quincena,false,false,0,"Text10",null,null,null,"T")%>
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=fecha%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				#Empl.<%=fb.textBox("numEmpleado",numEmpleado,false,false,false,5,10,"Text10","","")%>

				Nombre<%=fb.textBox("nombre",nombre,false,false,false,20,30,"Text10","","")%>
				<%=fb.submit("go","Ir",false,false,"Text10","","")%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;<% if (!fecha.trim().equals("")) { %><a href="javascript:printDailyReport()" class="Link00">[ Reporte de Asistencia Diaria ]</a> <% } %><a href="javascript:printReport()" class="Link00">[ Reporte de Asistencia ]</a></td>
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
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<% if (fecha.trim().equals("")) { %>
		<tr class="TextHeader" align="center">
			<td width="7%">Empl. ID</td>
			<td width="25%">Área/Ubic.</td>
			<td width="10%">C&eacute;dula</td>
			<td width="25%">Nombre</td>
			<td width="10%"># Empl.</td>
			<td width="15%">&nbsp;</td>
		</tr>
<%
/* M E N S U A L */
for (int i=0; i<al.size(); i++) {
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("emp_id")%></td>
				<td align="center"><%=cdo.getColValue("ubicacion_fisica")%>/ <%=cdo.getColValue("descripcionArea")%></td>
			<td width="10%"><%=cdo.getColValue("cedula")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=cdo.getColValue("num_empleado")%></td>
			<td align="center"><% if (cdo.getColValue("nDial").equals("0")) { %><img src="../images/blank.gif" height="<%=iconHeight + 2%>" border="0" width="100%" alt="No tiene marcaciones!"><% } else { %>
				<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr align="center">
					<td width="20%"><authttype type='2'><a href="javascript:printReport(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>)"><img src="../images/printer.gif" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Reporte de Asistencia"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='1'><a href="javascript:view(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>)"><img src="../images/clock.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Ver Marcaciones"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='4'><a href="javascript:edit(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>)"><img src="../images/clock-edit.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Corregir Marcaciones"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='50'><a href="javascript:printSchedule('<%=cdo.getColValue("num_empleado")%>')"><img src="../images/clock-calendar.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Reporte de Prog. Turno"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='51'><a href="javascript:printChrono(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>)"><img src="../images/clock-chrono.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Reporte de Asistencia Completo"></a></authtype>&nbsp;</td>
				</tr>
				</table>
			<% } %></td>
		</tr>
<% } %>
<% } else { %>
		<tr class="TextHeader" align="center">
			<td width="3%">&nbsp;</td>
			<td width="5%">#Empl.</td>
			<td width="24%">Nombre</td>
			<td width="6%">Entrada</td>
			<td width="6%">Salida</td>
			<td width="6%">Entrada</td>
			<td width="6%">Salida</td>
			<td width="5%">Prog. Turno</td>
			<td width="24%">Horario Programado o Asignado</td>
			<td width="15%">&nbsp;</td>
		</tr>
<%
/* D I A R I O */
for (int i=0; i<al.size(); i++) {
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><a href="javascript:viewDial(<%=cdo.getColValue("emp_id")%>,'<%=cdo.getColValue("dia")%>/<%=cdo.getColValue("mes")%>/<%=cdo.getColValue("anio")%>')"><img src="../images/clock-link.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Reloj de Marcaci&oacute;n"></a></td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td align="left"><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("entrada")%></td>
			<td><%=cdo.getColValue("salida_com")%></td>
			<td><%=cdo.getColValue("entrada_com")%></td>
			<td><%=cdo.getColValue("salida")%></td>
			<td><%=cdo.getColValue("turno")%></td>
			<td align="left"><%=cdo.getColValue("turno_dsp")%></td>
			<td align="center">
				<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr align="center">
					<td width="20%"><authttype type='2'><a href="javascript:printReport(<%=cdo.getColValue("emp_id")%>)"><img src="../images/printer.gif" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Reporte de Asistencia"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='1'><a href="javascript:view(<%=cdo.getColValue("emp_id")%>)"><img src="../images/clock.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Ver Marcaciones"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='4'><a href="javascript:edit(<%=cdo.getColValue("emp_id")%>)"><img src="../images/clock-edit.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Corregir Marcaciones"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='50'><a href="javascript:printSchedule('<%=cdo.getColValue("num_empleado")%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("mes")%>')"><img src="../images/clock-calendar.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Reporte de Prog. Turno"></a></authtype>&nbsp;</td>
					<td width="20%"><authttype type='51'><a href="javascript:printChrono(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>)"><img src="../images/clock-chrono.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Reporte de Asistencia Completo"></a></authtype>&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
<% } %>
<% } %>
		</table>
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
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<% } %>