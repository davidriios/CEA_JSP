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
CommonDataObject cdoPer = new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList alPer = new ArrayList();
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
String periodo = request.getParameter("periodo");
String fecha = request.getParameter("fecha");
String empId = request.getParameter("empId");
String ubicacion = request.getParameter("ubicacion");
String numEmpleado = request.getParameter("numEmpleado");
String nombre = request.getParameter("nombre");
String aprobado = request.getParameter("aprobado");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fechaHasta = request.getParameter("fechaHasta");
String incompletos  = request.getParameter("incompletos");
String id_lote = request.getParameter("id_lote");
String iDate = "";
String fDate = "";
String entradaDia = "";
String salidaDia = "";
boolean viewMode = false;
if (grupo == null) grupo = "";
if (area == null) area = "";
if (cesante == null) cesante = "";
if (anio == null) anio = "";
if (mes == null) mes = "";
if (quincena == null) quincena = "1";
if (fecha == null) fecha = "";
if (empId == null) empId = "";
if (id_lote == null) id_lote = "";
if (ubicacion == null) ubicacion = "";
if (numEmpleado == null) numEmpleado = "";
if (nombre == null) nombre = "";
if (aprobado == null) aprobado = "";
if (fechaHasta == null) fechaHasta = "";
if (incompletos == null) incompletos = "";

if (incompletos.trim().equals("X")) viewMode = true;

StringBuffer sbSqlGrupo = new StringBuffer();
sbSqlGrupo.append("select codigo, codigo||' - '||descripcion from tbl_pla_ct_grupo where compania = ");
sbSqlGrupo.append(session.getAttribute("_companyId"));
if (!UserDet.getUserProfile().contains("0")) {
	sbSqlGrupo.append(" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '");
	sbSqlGrupo.append(session.getAttribute("_userName"));
	sbSqlGrupo.append("')");
	
}else{sbSqlGrupo.append(" union all select -1, 'TODOS LOS REGISTROS' from dual ");}
sbSqlGrupo.append(" order by 2");




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
	if(!grupo.trim().equals("")&&!grupo.trim().equals("-1")){sbSqlArea.append(" and grupo = ");
	sbSqlArea.append(grupo);}
	cdo = SQLMgr.getData(sbSqlArea.toString());
	if (cdo != null) {
	if (area != "") area = cdo.getColValue("value_col");
	else area = "";
	}
}
 
StringBuffer sbSqlPer = new StringBuffer();
	sbSqlPer.append("select periodo as optValueColumn, periodo as optLabelColumn from tbl_pla_calendario where tipopla = 1 ");
	sbSqlPer.append(" and trans_desde >= to_date('");
	sbSqlPer.append(fecha);
	sbSqlPer.append("','dd/mm/yyyy') ");
	sbSqlPer.append(" and (trans_hasta <= to_date('");
	sbSqlPer.append(fechaHasta);
	sbSqlPer.append("','dd/mm/yyyy'))");
	cdoPer = SQLMgr.getData(sbSqlPer.toString());
	if (cdoPer != null) {
	if (periodo != "") periodo = cdoPer.getColValue("optValueColumn");
	else periodo = "";
	}
		
	//alPer = sbb.getBeanList(ConMgr.getConnection(),sbSqlPer.toString(),CommonDataObject.class);


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
	sbField.append(", z.ubicacion_fisica,z.descripcionArea ");
	sbTable.append(", (select distinct zz.emp_id,ubicacion_fisica,(select a.nombre from tbl_pla_ct_area_x_grupo a where a.codigo=zz.ubicacion_fisica and a.grupo=zz.grupo ) as descripcionArea ");
	sbTable.append(" from tbl_pla_ct_empleado zz where ");
	sbTable.append(" zz.compania = ");
	sbTable.append(session.getAttribute("_companyId"));
	 
 	if (grupo != "" && !grupo.trim().equals("-1"))
	{
		sbTable.append(" and zz.grupo = ");
		sbTable.append(grupo);
	}
	if (area != "" )
	{
		sbTable.append(" and zz.ubicacion_fisica = ");
		sbTable.append(area);
	}

	
	if (cesante.trim().equals("")){
	if (!fechaHasta.equals("")) {
		sbTable.append(" and fecha_ingreso_grupo <= to_date('");
		sbTable.append(fechaHasta);
		sbTable.append("','dd/mm/yyyy') ");
		}
		if (!fecha.equals("")) {
		sbTable.append(" and (fecha_egreso_grupo is null or fecha_egreso_grupo >= to_date('");
		sbTable.append(fecha);
		sbTable.append("','dd/mm/yyyy'))");
		}
		
	} else if (cesante.trim().equals("X")) {
		if (!fecha.equals("")) {
		sbTable.append(" and (fecha_egreso_grupo is null or fecha_egreso_grupo > to_date('");
		sbTable.append(fecha);
		sbTable.append("','dd/mm/yyyy'))");
		}
	}
	sbTable.append(") z ");

	/* tbl_pla_empleado */
	sbField.append(",y.emp_id,y.provincia,y.sigla,y.tomo,y.asiento,y.num_empleado,y.nombre_empleado as nombre, y.cedula1 as cedula ");
	sbTable.append(", vw_pla_empleado y");
	sbFilter.append(" and z.emp_id = y.emp_id");
				 
	sbOrder.append(", 9");

	 
		sbField.append(", (select count(*) from tbl_pla_marcacion xx where emp_id = z.emp_id ");
		sbField.append(" and to_date(xx.dia||'/'||xx.mes||'/'||xx.anio,'dd/mm/yyyy') = to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy')");
		 
		sbField.append(") as nDial");
	 
		/*tbl_pla_marcacion*/
		sbField.append(", x.anio, lpad(x.mes,2,'0') as mes, lpad(x.dia,2,'0') as dia, nvl(to_char(x.entrada,'hh12:mi am'),' ') as entrada, nvl(to_char(x.salida_com,'hh12:mi am'),' ') as salida_com, nvl(to_char(x.entrada,'dd/mm/yyyy'),' ') as entradaDia, nvl(to_char(x.salida,'dd/mm/yyyy'),' ') as salidaDia, nvl(to_char(x.entrada_com,'hh12:mi am'),' ') as entrada_com, nvl(to_char(x.salida,'hh12:mi am'),' ') as salida, nvl(x.programa,' ') as programa, nvl(x.turno,' ') as turno, substr(to_char(to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy'),'DAY','NLS_DATE_LANGUAGE=SPANISH'),1,3) as dia_semana, decode(x.turno,null,'CODIGO NO DEFINIDO',case when x.programa = 'S' then (select descripcion from tbl_pla_ct_turno where codigo = x.turno and compania = x.compania) else (select 'DE '||to_char(hora_entrada,'HH12:MI AM')||decode(hora_salida_almuerzo,null,'','  A  '||to_char(hora_salida_almuerzo,'HH12:MI AM'))||decode(hora_entrada_almuerzo,null,'','  Y  DE  '||to_char(hora_entrada_almuerzo,'HH12:MI AM'))||'  A  '||to_char(hora_salida,'HH12:MI AM') from tbl_pla_horario_trab where codigo = x.turno and compania = x.compania) end) as turno_dsp,to_char(to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy'),'dd/mm/yyyy') as fecha, x.id_lote, x.secuencia");
		sbField.append(", case when ( (x.entrada is null or x.salida is null) or x.editado ='S' ) then 'S' else 'N' end as editable");
		sbTable.append(", tbl_pla_marcacion x");
		sbFilter.append(" and z.emp_id = x.emp_id");
		sbFilter.append(" and x.compania = ");
		sbFilter.append(session.getAttribute("_companyId"));
		sbFilter.append(" and x.id_lote = "); 
		sbFilter.append(id_lote);
		if (!fecha.equals("")) {
			sbFilter.append(" and to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy') >= ");
			sbFilter.append(" to_date('");
			sbFilter.append(fecha);
			sbFilter.append("','dd/mm/yyyy')");
		} 
		if (!fechaHasta.equals("")) {
			sbFilter.append(" and to_date(x.dia||'/'||x.mes||'/'||x.anio,'dd/mm/yyyy') <= ");
			sbFilter.append(" to_date('");
			sbFilter.append(fechaHasta);
			sbFilter.append("','dd/mm/yyyy')");
		}
		if (incompletos.trim().equals("X")){
			sbFilter.append(" and (( x.entrada is null or x.salida is null ) or x.editado ='S')");
		} else  {
		      sbFilter.append(" and (( x.entrada is not null and x.salida is not null ) or x.editado ='S')");
		}
		sbOrder.append(", x.anio desc, x.mes desc, x.dia");
	 
	 
	if(!anio.trim().equals("")){sbFilter.append(" and x.anio = "); sbFilter.append(anio); }
	if(!mes.trim().equals("")){sbFilter.append(" and x.mes = "); sbFilter.append(mes); }
	if (!empId.trim().equals("")) { sbFilter.append(" and z.empId = "); sbFilter.append(empId); }
	if (!numEmpleado.trim().equals("")) { sbFilter.append(" and y.num_empleado like '"); sbFilter.append(numEmpleado); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(y.nombre_empleado) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }

	if (sbTable.length() > 1) {
		sbSql.append("select ");
		if (sbOrder.length() > 1) sbSql.append(sbField.substring(1));
		else sbSql.append(" *");
		sbSql.append(" from");
		sbSql.append(sbTable.substring(1));
		if (sbFilter.length() > 4) { sbSql.append(" where"); sbSql.append(sbFilter.substring(4)); }
		if (sbOrder.length() > 1) { sbSql.append(" order by"); sbSql.append(sbOrder.substring(1)); }
	}
	if (sbSql.length() > 0) {
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
		 
		rowCount = CmnMgr.getCount("select count(*) from("+sbSql.toString()+")");
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
function view(empId,ubicacion,lote){showPopWin('../rhplanilla/reg_marcacion_nv.jsp?mode=view&grupo=<%=grupo%>&area='+ubicacion+'&lote='+lote+'&iDate=<%=fecha%>&fDate=<%=fechaHasta%>&empId='+empId,winWidth*.95,winHeight*.65,null,null,'');}
function edit(empId,ubicacion,secuencia,fecha,incompl){showPopWin('../rhplanilla/reg_marcacion_nv.jsp?mode=edit&fg=NV&grupo=<%=grupo%>&area='+ubicacion+'&secuencia='+secuencia+'&iDate=<%=fecha%>&fDate=<%=fechaHasta%>&empId='+empId+'&fecha='+fecha+'&incompletos='+incompl,winWidth*.95,winHeight*.65,null,null,'');}
function editAll(empId,ubicacion,lote,fecha,incompl){showPopWin('../rhplanilla/reg_marcacion_nv.jsp?mode=edit&fg=NV&grupo=<%=grupo%>&area='+ubicacion+'&lote='+lote+'&iDate=<%=fecha%>&fDate=<%=fechaHasta%>&empId='+empId+'&fecha='+fecha+'&incompletos='+incompl,winWidth*.95,winHeight*.65,null,null,'');}
function calcHExt(empId,ubicacion,secuencia,fecha,entrada,salida,entradaDia,salidaDia,incompl){showPopWin('../rhplanilla/reg_marcacion_detalle_nv.jsp?mode=edit&fg=NV&grupo=<%=grupo%>&id_lote=<%=id_lote%>&area='+ubicacion+'&iDate='+entrada+'&fDate='+salida+'&entradaDia='+entradaDia+'&salidaDia='+salidaDia+'&empId='+empId+'&secuencia='+secuencia+'&fecha='+fecha+'&incompletos='+incompl,winWidth*.95,winHeight*.65,null,null,'');}
function printSchedule(numEmpleado,anio,mes){if(anio==undefined||anio==null||anio.trim()=='')anio='<%=anio%>';if(mes==undefined||mes==null||mes.trim()=='')mes='<%=mes%>';abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/programa_turno.rptdesign&cpGrupo=<%=grupo%>&cpArea=<%=area%>&pAnio='+anio+'&pMonthId='+mes+'&pNumEmpleado='+numEmpleado+'&pAprobado=S');}
function printChrono(empId,ubicacion){abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_asistencia_trx.rptdesign&pGrupo=<%=grupo%>&pArea='+ubicacion+'&pFecha=<%=(fecha.trim().equals(""))?"01/"+mes+"/"+anio:fecha%>&pEmpId='+empId);}
function ejecutar()
{
var msg='';
var grupo = document.search00.grupo.value;
var area = document.search00.area.value;
var anio = document.search00.anio.value;
var mes = document.search00.mes.value;
var fecha = document.search00.fecha.value;
var fechaHasta = document.search00.fechaHsearch00asta.value;
var numEmpleado = document.search00.numEmpleado.value;
var nombre = document.search00.nombre.value;
if(fecha == "" || fechaHasta == "")msg = 'Introduzca Rango de Fecha';
if(msg==''){CBMSG.confirm(' \nDesea Actualizar los Registros de Marcacion Incompletos!!',{'cb':function(r){
   if(r=='Si'){showPopWin('../process/pla_upd_marcacion.jsp?fp=UPDMARC&actType=50&docType=UPDMARC&grupo='+grupo+'&area='+area+'&anio='+anio+'&mes='+mes+'&fecha='+fecha+'&fechaHasta='+fechaHasta+'&numEmpleado='+numEmpleado+'&nombre='+nombre+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.95,winHeight*.65,null,null,'');}}});
}else CBMSG.alert(""+msg);
} 

function distribuir() {
  var msg = '';
  var grupo = document.search00.grupo.value;
  var lote = document.search00.id_lote.value;
  var fechaDesde = document.search00.fecha.value;
  var fechaHasta = document.search00.fechaHasta.value;
    
  // if (lote) abrir_ventana('../rhplanilla/proc_generacion_sobretiempo_marc.jsp?fp=DIST&grupo='+grupo+'&lote='+grupo);
  
  if (lote) showPopWin('../rhplanilla/proc_generacion_sobretiempo_marc.jsp?fp=DIST&grupo='+grupo+'&lote='+lote+'&fecha_desde='+fechaDesde+'&fecha_hasta='+fechaHasta,winWidth*.75,winHeight*.65,null,null,'');
}

function printDist() {
  var msg = '';
  var grupo = document.search00.grupo.value;
  var lote = document.search00.id_lote.value;
  var anio = document.search00.anio.value;
  // var lote = document.search00.id_lote.value;
  var fechaDesde = document.search00.fecha.value;
  var fechaHasta = document.search00.fechaHasta.value;
    
  //if (lote) abrir_ventana('../rhplanilla/print_marcacion_distribucion.jsp?appendFilter=');
  if (lote) abrir_ventana('../rhplanilla/reg_detalle_marcaciones.jsp?fp=DIST&seccion='+grupo+'&lote='+lote+'&anio='+anio+'&fecha_desde='+fechaDesde+'&fecha_hasta='+fechaHasta,winWidth*.75,winHeight*.65,null,null,'');
}



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
<%=fb.hidden("id_lote",id_lote)%>
		<tr class="TextFilter">
			<td>
				Grupo<%=fb.select(ConMgr.getConnection(),sbSqlGrupo.toString(),"grupo",grupo,false,false,0,"Text10",null,"onChange=\"javascript:loadXML('../xml/areaXGrupo.xml','area','','VALUE_COL','LABEL_COL','"+(String) session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','')\"")%>
				Ubic./Area Trab.<%=fb.select("area","","",false,false,0,"Text10","","")%>
				<script language="javascript">
				loadXML('../xml/areaXGrupo.xml','area','<%=area%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")+"-"+grupo%>','KEY_COL','T');
				</script> 
				<label for="cesante">Registros Incompletos:</label><%=fb.checkbox("incompletos","X",(incompletos.equalsIgnoreCase("X")),false,null,null,null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<authtype type='55'>
				<%=fb.button("view"," GENERAR MARCACIONES / DISTRIBUCION ",false,viewMode,"Text10","","onClick=\"javascript:distribuir();\"")%>
				</authtype>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<authtype type='56'>
				<%=fb.button("imprimir","IMPRIMIR DISTRIBUCION",false,viewMode,"Text10","","onClick=\"javascript:printDist();\"")%></authtype>
			</td>
		</tr>
		<tr class="TextFilter">  
			<td>
				A&ntilde;o<%=fb.textBox("anio",anio,false,false,false,2,"Text10","","")%>
				Mes<%=fb.select(ConMgr.getConnection(),"select lpad(level,2,'0') as id, to_char(to_date(lpad(level,2,'0'),'mm'),'MONTH','NLS_DATE_LANGUAGE=SPANISH') as description, lpad(level,2,'0') as title from dual connect by level <= 12","mes",mes,false,false,0,"Text10",null,null,null,"T")%>
				Periodo	<%=fb.select("periodo",alPer,periodo,false,false,0,"Text10",null,null,null,"S")%>-->
				Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=fecha%>"/>
				<jsp:param name="nameOfTBox2" value="fechaHasta"/>
				<jsp:param name="valueOfTBox2" value="<%=fechaHasta%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				#Empl.<%=fb.textBox("numEmpleado",numEmpleado,false,false,false,5,10,"Text10","","")%>

				Nombre<%=fb.textBox("nombre",nombre,false,false,false,20,30,"Text10","","")%>
				<%=fb.submit("go","Ir",false,false,"Text10","","")%>
					&nbsp;&nbsp;<authtype type='54'><%=fb.button("ir","ACTUALIZAR MARCACIONES INCOMPLETAS SEGUN TURNO..",false,false,"Text10","","onClick=\"javascript:ejecutar();\"")%></authtype>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;<!--<a href="javascript:printDailyReport()" class="Link00">[ Reporte de Asistencia Diaria ]</a> <a href="javascript:printReport()" class="Link00">[ Reporte de Asistencia ]</a>--></td>
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
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("entradaDia",entradaDia)%>
<%=fb.hidden("salidaDia",salidaDia)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("incompletos",incompletos)%>
<%=fb.hidden("id_lote",id_lote)%>
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
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("entradaDia",entradaDia)%>
<%=fb.hidden("salidaDia",salidaDia)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("incompletos",incompletos)%>
<%=fb.hidden("id_lote",id_lote)%>
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
 
		<tr class="TextHeader" align="center">
			<td width="3%">&nbsp;</td>
			<td width="5%">#Empl.</td>
			<td width="15%">Nombre</td>
			<td width="6%">Fecha</td>
			<td width="5%">Entrada</td>
			<td width="5%">Salida</td>
			<td width="6%">Entrada</td>
			<td width="6%">Salida</td>
			<td width="5%">Prog. Turno</td>
			<td width="22%">Horario Programado o Asignado</td>
			<td width="7%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
			<td width="7%">&nbsp;</td>
		</tr>
<%
/* D I A R I O */
for (int i=0; i<al.size(); i++) {
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td>&nbsp;</td>
			<td><%=cdo.getColValue("num_empleado")%></td>
			<td align="left"><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("fecha")%></td>
			<td><%=cdo.getColValue("entrada")%></td>
			<td><%=cdo.getColValue("salida_com")%></td>
			<td><%=cdo.getColValue("entrada_com")%></td>
			<td><%=cdo.getColValue("salida")%></td>
			<td><%=cdo.getColValue("turno")%></td>
			<td align="left"><%=cdo.getColValue("turno_dsp")%></td>
			<td align="center"><%if(cdo.getColValue("editable").trim().equals("S")){%>
			
			<authttype type='50'><a href="javascript:editAll(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>,<%=cdo.getColValue("id_lote")%>,'','X')"><img src="../images/clock-chrono.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Corregir Marcaciones" ></a></authtype>
			
			<% } else{ %> 
			<authttype type='52'><a href="javascript:view(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>,<%=cdo.getColValue("id_lote")%>)"><img src="../images/search.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Ver Marcaciones" ></a></authtype>
			<%}%>&nbsp;</td>
			<td>
			<authttype type='51'><a href="javascript:edit(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>,<%=cdo.getColValue("secuencia")%>,'<%=cdo.getColValue("fecha")%>','X')"><img src="../images/clock-edit.png" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Corregir Marcaciones" ></a></authtype>&nbsp;</td>
			<td> <%if(!cdo.getColValue("entrada").trim().equals("")&&!cdo.getColValue("salida").trim().equals("")){%>
			<authttype type='53'><a href="javascript:calcHExt(<%=cdo.getColValue("emp_id")%>,<%=cdo.getColValue("ubicacion_fisica")%>,<%=cdo.getColValue("secuencia")%>,'<%=cdo.getColValue("fecha")%>','<%=cdo.getColValue("entrada")%>','<%=cdo.getColValue("salida")%>','<%=cdo.getColValue("entradaDia")%>','<%=cdo.getColValue("salidaDia")%>','X')"><img src="../images/payment_adjust.gif" height="<%=iconHeight%>" border="0" width="<%=iconWidth%>" alt="Detalle Marcaciones" ></a></authtype>&nbsp;</td>		
		<% } else{ %> 
		<%}%>&nbsp;</td>
		
		</tr>
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
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("entradaDia",entradaDia)%>
<%=fb.hidden("salidaDia",salidaDia)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("incompletos",incompletos)%>
<%=fb.hidden("id_lote",id_lote)%>
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
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("entradaDia",entradaDia)%>
<%=fb.hidden("salidaDia",salidaDia)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("ubicacion",ubicacion)%>
<%=fb.hidden("numEmpleado",numEmpleado)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("incompletos",incompletos)%>
<%=fb.hidden("id_lote",id_lote)%>
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