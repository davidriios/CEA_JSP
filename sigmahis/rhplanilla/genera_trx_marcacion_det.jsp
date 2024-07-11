<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%
/////----------------
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
VacMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String change = request.getParameter("change");
String key = "";
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String periodo = request.getParameter("periodo");
String cierre = request.getParameter("cierre");
String secuencia = request.getParameter("secuencia");
String grupo = request.getParameter("unidad");
String fechaInicio = request.getParameter("inicio");
String empId = request.getParameter("empId");
String entradaDia = request.getParameter("entradaDia");
String salidaDia = request.getParameter("salidaDia");
String fechaFinal = request.getParameter("final");
String desdeTrx = request.getParameter("desde");
String hastaTrx = request.getParameter("hasta");
String lote = request.getParameter("lote");
String fecha = request.getParameter("fecha");

boolean viewMode = false;
int lineNo = 0;
//System.out.println("grp="+grupo);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(grupo==null) grupo="";
if(fechaInicio==null) fechaInicio="";
if(secuencia==null) secuencia="";
if(lote==null) lote="";
if(fechaFinal==null) fechaFinal="";
if(entradaDia==null) entradaDia="";
if(salidaDia==null) salidaDia="";
if(empId==null) empId="";
if(fecha==null) fecha="";
if(grupo==null) grupo="0";
if(mode.equals("view")) viewMode = true;


 if (request.getParameter("desde") != null)
   {
  appendFilter += " and trunc(a.fecha) >= to_date('"+desdeTrx+"', 'dd/mm/yyyy')";

	 }

if (request.getParameter("hasta") != null)
   {
       appendFilter += " and trunc(a.fecha) <= to_date('"+hastaTrx+"', 'dd/mm/yyyy')";
	 }


//if (request.getParameter("unidad") != null)
if(grupo != null)
   {
   appendFilter += " and to_char(a.ue_codigo) = '"+grupo+"'";
	 }



if (request.getMethod().equalsIgnoreCase("GET"))
{ 
	sbSql = new StringBuffer();
	
sbSql.append("  select z.*,round((24*(salida-fechaHoraSegunTurno)),2) as horaExtra,nvl((select 'Y' as dianacional from tbl_pla_dia_feriado x where to_char(x.dia_libre,'dd/mm/yyyy')=z.fechaSalida),'N') isDiaNacionalSalida,nvl((select 'Y' as dianacional from tbl_pla_dia_feriado x where to_char(x.dia_libre,'dd/mm/yyyy')=z.fechaEntrada),'N') isDiaNacionalEntrada from (	select a.entrada,  a.salida , a.secuencia, a.turno,b.descripcion  as turno_dsp,b.hora_entrada, to_char(a.salida,'dd/mm/yyyy') as fechaSalida,to_char(a.salida,'hh12:mi:ss AM') as horaSalida ,to_char(a.entrada,'hh12:mi:ss AM') as horaEntrada, to_char(a.salida_com,'hh12:mi:ss AM') as salida_com ,to_char(a.entrada_com,'hh12:mi:ss AM') as entrada_com, nvl(a.programa,' ') as programa, to_char(b.hora_salida,'hh12:mi:ss AM') as turnoHoraSalida, to_date((to_char(a.salida,'dd/mm/yyyy') ||' ' || to_char(b.hora_salida,'hh12:mi:ss AM')),'dd/mm/yyyy hh12:mi:ss AM') as fechaHoraSegunTurno,	to_char(a.entrada,'dd/mm/yyyy') as fechaEntrada,decode((MOD(TO_CHAR(a.entrada, 'J'), 7) + 1),7,'Y','N') diaEntradaDomingo,to_char(a.salida,'DAY') diaSalidaDomingo, b.hora_salida,case 	when (24*(b.hora_salida-b.hora_entrada))<0 then (24*(b.hora_salida-b.hora_entrada))+24 	else (24*(b.hora_salida-b.hora_entrada)) end as horatrabajo, a.anio, lpad(a.mes,2,'0') as mes, lpad(a.dia,2,'0') as dia,substr(to_char(to_date(a.dia||'/'||a.mes||'/'||a.anio,'dd/mm/yyyy'),'DAY','NLS_DATE_LANGUAGE=SPANISH'),1,3) as dia_semana, nvl(b.turno_mixto,'N') as turno_mixto, nvl(b.tipo_turno,'D') as tipo_turno, c.rata_hora, c.emp_id ");
sbSql.append("  ,getHoraExtraMarcacion(a.secuencia,'TOTHORATRAB',nvl(b.tipo_turno,'D')) hRegular, getHoraExtraMarcacion(a.secuencia,'TOTDOMINGO',nvl(b.tipo_turno,'D')) hDomingo, getHoraExtraMarcacion(a.secuencia,'TOTLIBRENAC',nvl(b.tipo_turno,'D')) hDiaNacional, getHoraExtraMarcacion(a.secuencia,'TOTHE125',nvl(b.tipo_turno,'D')) hExtra125, getHoraExtraMarcacion(a.secuencia,'TOTHE150',nvl(b.tipo_turno,'D')) hExtra150 "); 
sbSql.append("  ,getHoraExtraMarcacion(a.secuencia,'HEDOMNOCTUR',nvl(b.tipo_turno,'D')) hExtra225  , getHoraExtraMarcacion(a.secuencia,'HORASNODESC',nvl(b.tipo_turno,'D')) hExtraND, getHoraExtraMarcacion(a.secuencia,'EXCMAS3NOCT',nvl(b.tipo_turno,'D')) hExtra263, getHoraExtraMarcacion(a.secuencia,'EXCMAS3MIXTN/D',nvl(b.tipo_turno,'D')) hExtra306 "); 
sbSql.append("  ,getHoraExtraMarcacion(a.secuencia,'EXTNACDIURNO',nvl(b.tipo_turno,'D')) hExtra313 , getHoraExtraMarcacion(a.secuencia,'EXCMAS3DOMDIURNO',nvl(b.tipo_turno,'D')) hExtra328, getHoraExtraMarcacion(a.secuencia,'EXTNACMIXTD/N',nvl(b.tipo_turno,'D')) hExtra375MD ");
sbSql.append("  ,getHoraExtraMarcacion(a.secuencia,'HEDOMDIURNO',nvl(b.tipo_turno,'D')) hExtra188,getHoraExtraMarcacion(a.secuencia,'EXCMAS3DIURNO',nvl(b.tipo_turno,'D')) hExtra219, getHoraExtraMarcacion(a.secuencia,'HEDOMMIXTD/N',nvl(b.tipo_turno,'D')) hExtra225MN, getHoraExtraMarcacion(a.secuencia,'HEDOMMIXTN/D',nvl(b.tipo_turno,'D')) hExtra263MN , getHoraExtraMarcacion(a.secuencia,'EXCMAS3MIXTD/N',nvl(b.tipo_turno,'D')) hExtra263MD, getHoraExtraMarcacion(a.secuencia,'EXTNACNOCTUR',nvl(b.tipo_turno,'D')) hExtra375, getHoraExtraMarcacion(a.secuencia,'EXCMAS3DOMMIXTD/N',nvl(b.tipo_turno,'D')) hExtra394MD, getHoraExtraMarcacion(a.secuencia,'EXCMAS3DOMNOCTUR',nvl(b.tipo_turno,'D')) hExtra394, getHoraExtraMarcacion(a.secuencia,'8HNACDOMINGO',nvl(b.tipo_turno,'D')) hExtra438 "); 
sbSql.append("  ,getHoraExtraMarcacion(a.secuencia,'EXTNACMIXTN/D',nvl(b.tipo_turno,'D')) hExtra438MN, getHoraExtraMarcacion(a.secuencia,'EXCMAS3DOMMIXTN/D',nvl(b.tipo_turno,'D')) hExtra459, getHoraExtraMarcacion(a.secuencia,'EXCMAS3NACDIURNO',nvl(b.tipo_turno,'D')) hExtra547 , getHoraExtraMarcacion(a.secuencia,'EXCMAS3NACD/N',nvl(b.tipo_turno,'D')) hExtra656, getHoraExtraMarcacion(a.secuencia,'EXCMAS3NACNOCTUR',nvl(b.tipo_turno,'D')) hExtra656N, getHoraExtraMarcacion(a.secuencia,'EXCMAS3NACN/D',nvl(b.tipo_turno,'D')) hExtra766, getHoraExtraMarcacion(a.secuencia,'TOTHE175',nvl(b.tipo_turno,'D')) hExtra175 ");
sbSql.append(" ,getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RENTDOMINGO',b.codigo) as entdom, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RSALDOMINGO',b.codigo) as saldom , getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RENTNACIONAL',b.codigo) as entnac, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HENTDOMINGO',b.codigo) as octedom,  getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'RSALNACIONAL',b.codigo) as salnac, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HSALDOMINGO',b.codigo) as octsdom, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HREGDOMINGO',b.codigo) as octrdom, getCalcHoraRegularExtra(a.entrada,a.salida,a.secuencia,to_date(to_char(a.salida,'dd/mm/yyyy')||' '||to_char(b.hora_salida,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),to_date(to_char(a.entrada,'dd/mm/yyyy')||' '||to_char(b.hora_entrada,'HH24:mi:ss'),'dd/mm/yyyy HH24:mi:ss'),'8HNACDOMINGO',b.codigo) as octndom from tbl_pla_marcacion a,tbl_pla_ct_turno b, vw_pla_empleado c where a.turno=b.codigo and a.compania=b.compania and a.salida is not null and a.compania=");
	sbSql.append(session.getAttribute("_companyId"));
		
			sbSql.append(" and a.secuencia = ");
			sbSql.append(secuencia);
		
	if (!empId.equals("")) {
		sbSql.append(" and a.emp_id = ");
		sbSql.append(empId);
	}

	sbSql.append(" and a.emp_id = c.emp_id and a.compania = c.compania ) z order by 1");
		
		System.out.println("SQL TPR=\n"+sql);
		alTPR = SQLMgr.getDataList(sbSql.toString());
		
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
		var size = <%=alTPR.size()%>;
		var x = 0;
		parent.document.form1.count.value = size;
		for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	parent.document.form1.count1.value = x;
}

function selTurno(name){
	<%
	if(!fp.equals("consulta_x_quincena")){
	%>
	abrir_ventana('../common/search_turno.jsp?fp=programa_turno_borrador&index='+name);
	<%
	}
	%>
}

function selUbicacion(name){
	var quincena = parent.document.form1.quincena.value;
	<%
	if(!fp.equals("consulta_x_quincena")){
	%>
	abrir_ventana('../common/search_area.jsp?fp=programa_turno_borrador&index='+name+'&quincena='+quincena);
	<%
	}
	%>
}


function doSubmit(action){
	document.form.baction.value 			= action;
	document.form.anio.value 				= parent.document.form1.anio.value;
	document.form.mes.value 				= parent.document.form1.mes.value;
	document.form.quincena.value 		= parent.document.form1.quincena.value;
	if(action == 'GENERAR TRANSACCIONES PARA CALCULO DE PLANILLA' ){
		formBlockButtons(true);
		if(chkSelected()) document.form.submit();
		else alert('Seleccione al menos una solicitud!');
		formBlockButtons(false);
	}
}

function chkSelected(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	if(x==0) return false;
	else return true;
}

function openSolVac(i){
	var v_compania	= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 		= eval('document.form.emp_id'+i).value;
	var codigo 		= eval('document.form.codigo'+i).value;
	//var anio 			= document.form.anio.value;
	var anio 			= eval('document.form.anioSol'+i).value;

	abrir_ventana('../rhplanilla/aprobar_rechazar_solicitud_vac.jsp?fp=aprobar_rechazar_solicitud_vac&empId='+emp_id+'&codigo='+codigo+'&anio='+anio);
}

function showMarcacionDist(factor) {
  parent.showPopWin('../rhplanilla/marcacion_dist.jsp?secuencia=<%=secuencia%>&lote=<%=lote%>&fecha=<%=fecha%>&empId=<%=empId%>&factor='+factor,winWidth*.50,_contentHeight*.65,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("empId",empId)%>
<%=fb.hidden("quincena",quincena)%>
<%=fb.hidden("lote",lote)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("fecha",fecha)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
				
          <td align="center" width="5%">Reg.</td>
          <td align="center" width="5%">Dom.</td>
          <td align="center" width="5%">Nal.</td>
          <td align="center" width="5%">Lib.</td>
		  
	  <td align="center" width="5%">REDom</td>
          <td align="center" width="5%">RSDom</td>
          <td align="center" width="5%">RENac</td>
          <td align="center" width="5%">RSNac</td>
		  
	  <td align="center" width="5%">8HREG</td>
          <td align="center" width="5%">8HRENTDom</td>
	  <td align="center" width="5%">8HRSALDom</td>
          <td align="center" width="5%">8HRENac</td>
		  
			  
          <td align="center" width="5%">Corte Diurno</td>
          <td align="center" width="5%">Corte Nocturno</td>
	  <td align="center" width="5%">Corte Mixto</td>
          
               <td align="center" width="5%">Recargo D</td>
          <td align="center" width="5%">Recargo N</td>
	  <td align="center" width="5%">Recargo M</td>   
         <td align="center" width="5%">Recargo D/N</td>
	  <td align="center" width="5%">Recargo N/N</td> 
        </tr>
		

		
        <%
			StringBuffer sbEvt = new StringBuffer(); 
  for (int i=0; i<alTPR.size(); i++) { cdoDM = (CommonDataObject) alTPR.get(i); String evt = sbEvt.toString(); evt = evt.replaceAll("IDX",""+i); %>
		<%		
          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <%//=fb.hidden("emp_id"+i, cdo.getColValue("emp_id"))%>
        <%//=fb.hidden("ue_codigo"+i, cdo.getColValue("ue_codigo"))%>

        <%//=fb.hidden("anioPago"+i, anio)%>
        <%//=fb.hidden("dsp_cedula"+i, cdo.getColValue("dsp_cedula"))%>
        <%//=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%//=fb.hidden("nombre_empleado"+i, cdo.getColValue("nombre_empleado"))%>

        <%//=fb.hidden("unidad_organi"+i, cdo.getColValue("unidad_organi"))%>
        <%//=fb.hidden("fecha_ingreso"+i, cdo.getColValue("fecha_ingreso"))%>
		<%//=fb.hidden("estado"+i, cdo.getColValue("estado"))%>
		<%//=fb.hidden("inicio"+i, fechaInicio)%>
		<%//=fb.hidden("final"+i, fechaFinal)%>
		<%//=fb.hidden("desdeTrx"+i, desdeTrx)%>
		<%//=fb.hidden("hastaTrx"+i, hastaTrx)%>
		<%//=fb.hidden("grupo"+i, grupo)%>
		<%//=fb.hidden("quincenaPago"+i, periodo)%>

        <tr class="<%=color%>" align="center">
   	 	  <td align="center"><%=cdoDM.getColValue("hRegular")%></td>
        <td align="center"><%=cdoDM.getColValue("hDomingo")%></td>
        <td align="center"><%=cdoDM.getColValue("hDiaNacional")%></td>
        <td align="center"><%=cdoDM.getColValue("hDomingo")%></td>
		  
        <td align="center" onclick="showMarcacionDist('RENTDOMINGO')"><%=cdoDM.getColValue("entdom")%></td>
        <td align="center" onclick="showMarcacionDist('RSALDOMINGO')"><%=cdoDM.getColValue("saldom")%></td>
        <td align="center" onclick="showMarcacionDist('RENTNACIONAL')"><%=cdoDM.getColValue("entnac")%></td>
        <td align="center" onclick="showMarcacionDist('RSALNACIONAL')"><%=cdoDM.getColValue("salnac")%></td>
		  
        <td align="center" onclick="showMarcacionDist('8HREGDOMINGO')"><%=cdoDM.getColValue("octrdom")%></td>
        <td align="center" onclick="showMarcacionDist('8HENTDOMINGO')"><%=cdoDM.getColValue("octedom")%></td>
        <td align="center" onclick="showMarcacionDist('8HSALDOMINGO')"><%=cdoDM.getColValue("octsdom")%></td>
        <td align="center" onclick="showMarcacionDist('8HNACDOMINGO')"><%=cdoDM.getColValue("octndom")%></td>
		  
        <td align="center" onclick="showMarcacionDist('TOTHE125')"><%=cdoDM.getColValue("hExtra125")%></td>
        <td align="center" onclick="showMarcacionDist('TOTHE150')"><%=cdoDM.getColValue("hExtra150")%></td>
        <td align="center" onclick="showMarcacionDist('TOTHE175')"><%=cdoDM.getColValue("hExtra175")%></td>
		
				<%if(!cdoDM.getColValue("hExtra219").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3DIURNO')"><%=cdoDM.getColValue("hExtra219")%></td>
				<%}else if(!cdoDM.getColValue("hExtra313").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXTNACDIURNO')"><%=cdoDM.getColValue("hExtra313")%></td>
				<%}else if(!cdoDM.getColValue("hExtra547").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3NACDIURNO')"><%=cdoDM.getColValue("hExtra547")%></td>
				<%}else if(!cdoDM.getColValue("hExtra188").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('HEDOMDIURNO')"><%=cdoDM.getColValue("hExtra188")%></td>
				<%}else if(!cdoDM.getColValue("hExtra328").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3DOMDIURNO')"><%=cdoDM.getColValue("hExtra328")%></td>
				<%}%>
		
			<%if(!cdoDM.getColValue("hExtra263").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3NOCT')"><%=cdoDM.getColValue("hExtra263")%></td>
				<%}else if(!cdoDM.getColValue("hExtra375MD").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXTNACMIXTD/N')"><%=cdoDM.getColValue("hExtra375MD")%></td>
				<%}else if(!cdoDM.getColValue("hExtra656N").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3NACNOCTUR')"><%=cdoDM.getColValue("hExtra656N")%></td>
				<%}else if(!cdoDM.getColValue("hExtra225").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('HEDOMNOCTUR')"><%=cdoDM.getColValue("hExtra225")%></td>
				<%}else if(!cdoDM.getColValue("hExtra394").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3DOMNOCTUR')"><%=cdoDM.getColValue("hExtra394")%></td>
				<%}%>
		
			<%if(!cdoDM.getColValue("hExtra263MD").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3MIXTD/N')"><%=cdoDM.getColValue("hExtra263MD")%></td>
				<%}else if(!cdoDM.getColValue("hExtra375").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXTNACNOCTUR')"><%=cdoDM.getColValue("hExtra375")%></td>
				<%}else if(!cdoDM.getColValue("hExtra656").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3NACD/N')"><%=cdoDM.getColValue("hExtra656")%></td>
				<%}else if(!cdoDM.getColValue("hExtra225MN").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('HEDOMMIXTD/N')"><%=cdoDM.getColValue("hExtra225MN")%></td>
				<%}else if(!cdoDM.getColValue("hExtra394MD").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3DOMMIXTD/N')"><%=cdoDM.getColValue("hExtra394MD")%></td>
				<%}%>
		 
             <%if(!cdoDM.getColValue("hExtra306").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3MIXTN/D')"><%=cdoDM.getColValue("hExtra306")%></td>
				<%}else if(!cdoDM.getColValue("hExtra438").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('8HNACDOMINGO')"><%=cdoDM.getColValue("hExtra438")%></td>
				<%}else if(!cdoDM.getColValue("hExtra766").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3NACN/D')"><%=cdoDM.getColValue("hExtra766")%></td>
				<%}else if(!cdoDM.getColValue("hExtra263MN").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('HEDOMMIXTN/D')"><%=cdoDM.getColValue("hExtra263MN")%></td>
				<%}else if(!cdoDM.getColValue("hExtra459").trim().equals("0")){%>
				<td align="center" onclick="showMarcacionDist('EXCMAS3DOMMIXTN/D')"><%=cdoDM.getColValue("hExtra459")%></td>
				<%}%>
	   
        <td align="center" onclick="showMarcacionDist('HORASNODESC')"><%=cdoDM.getColValue("hExtraND")%></td>
	
	     <% } %>
       
        </tr>
      
        <tr class="TextHeader02" align="center">
          <td align="left" colspan="20">Total:&nbsp;<font class="WhiteTextBold"><%=alTPR.size()%></font></td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	emp.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("chk"+i)!=null){
			//cdo.addColValue("anio", request.getParameter("anio"));
			//cdo.addColValue("inicio", request.getParameter("inicio"+i));
			//cdo.addColValue("final", request.getParameter("final"+i));
			cdo.addColValue("inicio", request.getParameter("desdeTrx"+i));
			cdo.addColValue("final", request.getParameter("hastaTrx"+i));
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
  			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("unidad_organi", request.getParameter("grupo"+i));
			//cdo.addColValue("anioPago", request.getParameter("anioPago"+i));
			//cdo.addColValue("quincenaPago", request.getParameter("quincenaPago"+i));
			cdo.addColValue("anioPago", request.getParameter("anioAc"+i));
			cdo.addColValue("quincenaPago", request.getParameter("periodoAc"+i));
			cdo.addColValue("estado", request.getParameter("estado"+i));
			cdo.addColValue("usuario", (String) session.getAttribute("_userName"));
			alTPR.add(cdo);
		}
	}

	if (request.getParameter("baction").equalsIgnoreCase("GENERAR TRANSACCIONES PARA CALCULO DE PLANILLA")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	  	VacMgr.generaAusTard(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script>
function closeWindow(){
<%
if (VacMgr.getErrCode().equals("1")){
%>
	alert('<%=VacMgr.getErrMsg()%>');
	parent.window.setValues();
<%
} else throw new Exception(VacMgr.getErrMsg());
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