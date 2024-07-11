</%@ page errorPage="../error.jsp"%>
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
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%

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
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String grupo = request.getParameter("grupo");
String area = request.getParameter("area");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String inicio = request.getParameter("inicio");
String fin = request.getParameter("fin");
String nombre = request.getParameter("nombre");
String cedula = request.getParameter("cedula");
String numEmpleado = request.getParameter("numEmpleado");

boolean viewMode = false;
int lineNo = 0;
System.out.println("mes="+mes);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{

	sql = "select  ca.periodo, to_char(ca.trans_desde,'dd/mm/yyyy') as trans_desde, to_char(ca.trans_hasta,'dd/mm/yyyy') as trans_hasta, to_char(ca.fecha_cierre,'dd/mm/yyyy') as fechaCierre, to_char(ca.fecha_final,'dd/mm/yyyy') as fechaFinal, to_char(ca.fecha_inicial,'dd/mm/yyyy') as fechaInicial, to_char(ca.fecha_inicial,'FMMONTH','NLS_DATE_LANGUAGE = SPANISH') as mes, decode(mod(ca.periodo,2),'0','2da','1ra')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') quincena, to_char(ca.fecha_cierre + 1,'dd/mm/yyyy') fechaEntrega, to_char(ca.fecha_inicial,'yyyy') anio, ce.estado, ce.cedula1 cedula, ce.nombre_empleado nombre, ce.num_empleado, ce.emp_id,  d.descripcion estadoDesc, k.ausApro, k.ausPend, k.empIdAus, l.incApro, l.incPend, l.empIdInc, m.tarApro, m.tarPend, m.empIdTar, n.perApro, n.perPend, n.empIdPer, sum(nvl(k.ausApro,0) + nvl(l.incApro,0) + nvl(m.tarApro,0) + nvl(n.perApro,0))  aprobados, sum(nvl(k.ausPend,0) + nvl(l.incPend,0) + nvl(m.tarPend,0) + nvl(n.perPend,0))  pendientes from tbl_pla_ct_empleado e, vw_pla_empleado ce, tbl_pla_estado_emp d, tbl_pla_calendario ca, (select sum( decode(s.aprobado,'S',1,0)) ausApro, sum( decode(s.aprobado,'S',0,1)) ausPend, e.emp_id empIdAus from tbl_pla_at_det_empfecha s, tbl_pla_ct_empleado e where (trunc(s.fecha) >= to_date('"+inicio+"','dd/mm/yyyy') and trunc(s.fecha) <= to_date('"+fin+"','dd/mm/yyyy') and to_char(s.ue_codigo) = '"+grupo+"') and (s.aprobado <> 'A') and (s.emp_id = e.emp_id and s.compania = e.compania and s.ue_codigo = e.grupo)  group by e.emp_id) k, (select  sum( decode(s.aprobado,'S',1,0)) incApro, sum( decode(s.aprobado,'S',0,1)) incPend, e.emp_id empIdInc from tbl_pla_incapacidad s, tbl_pla_ct_empleado e where (trunc(s.fecha) >= to_date('"+inicio+"','dd/mm/yyyy') and trunc(s.fecha) <= to_date('"+fin+"','dd/mm/yyyy') and to_char(s.ue_codigo) = '"+grupo+"')  and (s.aprobado <> 'A') and (s.emp_id = e.emp_id and s.compania = e.compania and s.ue_codigo = e.grupo) group by e.emp_id) l , (select  sum( decode(s.aprobacion,'S',1,0)) tarApro, sum( decode(s.aprobacion,'S',0,1)) tarPend, e.emp_id empIdTar from tbl_pla_inasistencia_emp s, tbl_pla_ct_empleado e where ((trunc(s.fecha) >= to_date('"+inicio+"','dd/mm/yyyy') and trunc(s.fecha) <= to_date('"+fin+"','dd/mm/yyyy')) or (   trunc(s.fecha_dev) >= to_date('"+inicio+"','dd/mm/yyyy') and trunc(s.fecha_dev) <= to_date('"+fin+"','dd/mm/yyyy'))) and  to_char(s.ue_codigo) = '"+grupo+"' and (s.aprobacion <>'A') and (s.emp_id = e.emp_id and s.compania = e.compania and s.ue_codigo = e.grupo) group by e.emp_id) m, (select sum( decode(s.aprobado,'S',1,0)) perApro, sum( decode(s.aprobado,'S',0,1)) perPend, e.emp_id empIdPer from tbl_pla_permiso s, tbl_pla_ct_empleado e where ((trunc(fecha) >= to_date('"+inicio+"','dd/mm/yyyy') and trunc(fecha) <= to_date('"+fin+"','dd/mm/yyyy')) or (trunc(fecha_fin) >= to_date('"+inicio+"','dd/mm/yyyy') and trunc(fecha_fin) <= to_date('"+fin+"','dd/mm/yyyy'))) and to_char(s.ue_codigo) = '"+grupo+"' and (s.aprobado <> 'A') and (s.emp_id = e.emp_id and s.compania = e.compania and s.ue_codigo = e.grupo) group by e.emp_id) n where ce.compania  = "+(String) session.getAttribute("_companyId") +" and ca.tipopla = 1 and ce.estado not in (3,13) and trunc(ca.trans_desde) = to_date('"+inicio+"','dd/mm/yyyy') and trunc(ca.trans_hasta) = to_date('"+fin+"','dd/mm/yyyy') and ce.emp_id = e.emp_id(+) and ce.estado = d.codigo and ce.compania = e.compania and to_date(to_char(nvl(e.fecha_ingreso_grupo,to_date('"+inicio+"','dd/mm/yyyy')),'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fin+"','dd/mm/yyyy') and (e.fecha_egreso_grupo is null or trunc(e.fecha_egreso_grupo) > to_date('"+inicio+"','dd/mm/yyyy')) and  e.grupo = '"+grupo+"' and e.ubicacion_fisica = nvl('"+area+"', e.ubicacion_fisica)  and e.emp_id = k.empIdAus(+)  and e.emp_id = l.empIdInc(+) and e.emp_id = m.empIdTar(+) and e.emp_id = n.empIdPer(+) and (nvl(k.ausApro,0)+nvl(l.incApro,0)+nvl(m.tarApro,0)+nvl(n.perApro,0)+nvl(k.ausPend,0)+nvl(l.incPend,0)+nvl(m.tarPend,0)+nvl(n.perPend,0)) > 0 group by ca.periodo, to_char(ca.trans_desde,'dd/mm/yyyy'), to_char(ca.trans_hasta,'dd/mm/yyyy'), to_char(ca.fecha_cierre,'dd/mm/yyyy'), to_char(ca.fecha_final,'dd/mm/yyyy') , to_char(ca.fecha_inicial,'dd/mm/yyyy') , to_char(ca.fecha_inicial,'FMMONTH','NLS_DATE_LANGUAGE = SPANISH'), decode(mod(ca.periodo,2),'0','2da','1ra')||' '|| to_char(to_date(ca.fecha_inicial,'dd/mm/yyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') , to_char(ca.fecha_cierre + 1,'dd/mm/yyyy') , to_char(ca.fecha_inicial,'yyyy'), ce.estado, ce.cedula1 , ce.nombre_empleado, ce.num_empleado, ce.emp_id,  d.descripcion , k.ausApro, k.ausPend, k.empIdAus, l.incApro, l.incPend, l.empIdInc, m.tarApro, m.tarPend, m.empIdTar, n.perApro, n.perPend, n.empIdPer order by 30 desc,29 desc";
		System.out.println("SQL TPR=\n"+sql);
		alTPR = SQLMgr.getDataList(sql);
		emp.clear();
		empKey.clear();
		for(int i=0;i<alTPR.size();i++){
			CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				emp.put(key, cdo);
				empKey.put(cdo.getColValue("emp_id"), key);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
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

function chkNumEmpleado(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true && eval('document.form.num_empleado'+i).value==''){
			alert('Esta acción de ingreso no le ha registrado el número de empleado, esta es una información de vital importancia por lo que no podrá actualizar la acción!!!');
			x++;
			break;
		}
	}
	if(x==0) return true;
	else return false;
}


function doSubmit(action){
	document.form.baction.value 			= action;
	if(action == 'Aplicar Accion de Ingreso' && chkNumEmpleado()){
		formBlockButtons(true);
		if(chkSelected()){
			if(confirm('Confirma que Desea Aplicar la Acción de Ingreso?')) document.form.submit();
		} else alert('Seleccione al menos una solicitud!');
		formBlockButtons(false);
	} else if(action == 'Anular Accion de Ingreso'){
		formBlockButtons(true);
		if(chkSelected()) document.form.submit();
		else alert('Seleccione al menos una solicitud!');
		formBlockButtons(false);
	}  else if(action == 'Aprobacion'){
		formBlockButtons(true);
		if(chkSelected()) document.form.submit();
		else alert('Seleccione al menos un Empleado!');
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

function editIncEmp(i){
	var v_compania		= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 				= eval('document.form.emp_id'+i).value;
	var desde 				= eval('document.form.fechaDesde'+i).value;
	var hasta 				= eval('document.form.fechaHasta'+i).value;
	var grupo 				= document.form.grupo.value;
	var area					= document.form.area.value;
	abrir_ventana('../rhplanilla/empl_incapacidad_list.jsp?empId='+emp_id+'&grupo='+grupo+'&desde='+desde+'&hasta='+hasta);
}

function openExpEmp(i){
	var consecutivo = eval('document.form.sol_empleo_codigo'+i).value;
	var anio 				= eval('document.form.sol_empleo_anio'+i).value;
	var emp_id 		= eval('document.form.emp_id'+i).value;
	abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?fp=rrhh&fg=ingreso&empId='+emp_id+'&consecutivo='+consecutivo+'&anio='+anio);
}

function editTarEmp(i){
	var v_compania		= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 				= eval('document.form.emp_id'+i).value;
	var desde 				= eval('document.form.fechaDesde'+i).value;
	var hasta 				= eval('document.form.fechaHasta'+i).value;
	var grupo 				= document.form.grupo.value;
	var area					= document.form.area.value;
	abrir_ventana('../rhplanilla/empl_tardanza_list.jsp?empId='+emp_id+'&grupo='+grupo+'&area='+area+'&desde='+desde+'&hasta='+hasta);
}

function editPerEmp(i){
	var v_compania		= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 				= eval('document.form.emp_id'+i).value;
	var desde 				= eval('document.form.fechaDesde'+i).value;
	var hasta 				= eval('document.form.fechaHasta'+i).value;
	var grupo 				= document.form.grupo.value;
	var area					= document.form.area.value;
	abrir_ventana('../rhplanilla/empl_permiso_list.jsp?empId='+emp_id+'&grupo='+grupo+'&desde='+desde+'&hasta='+hasta);
}

function editAusEmp(i){
	var v_compania		= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 				= eval('document.form.emp_id'+i).value;
	var desde 				= eval('document.form.fechaDesde'+i).value;
	var hasta 				= eval('document.form.fechaHasta'+i).value;
	var grupo 				= document.form.grupo.value;
	var area					= document.form.area.value;
	abrir_ventana('../rhplanilla/empl_ausencia_list.jsp?empId='+emp_id+'&grupo='+grupo+'&desde='+desde+'&hasta='+hasta);
}

function activar(i){
	var num_empleado	= eval('document.form.num_empleado'+i).value;
	var ced_provincia	= eval('document.form.ced_provincia'+i).value;
	var ced_sigla 		= eval('document.form.ced_sigla'+i).value;
	var ced_tomo 			= eval('document.form.ced_tomo'+i).value;
	var ced_asiento 	= eval('document.form.ced_asiento'+i).value;
	var emp_id 				= eval('document.form.emp_id'+i).value;
	var ct_emp_id 					= eval('document.form.ct_emp_id'+i).value;
	var emp_estado		= eval('document.form.emp_estado'+i).value;
	{alert('Pendiente por hacer')}
}

function movimiento(){alert('Pendiente por hacer')}
function traslado(){alert('Pendiente por hacer')}

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
<%=fb.hidden("grupo",grupo)%>
<%=fb.hidden("area",area)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="4%">&nbsp;</td>
          <td align="center" width="11%">C&eacute;dula</td>
          <td align="center" width="7%">No. Empl.</td>
          <td align="center" width="23%">Nombre Empleado</td>
          <td align="center" width="15%">Estado</td>
          <td align="center" width="9%">Aus.</td>
          <td align="center" width="9%">Incap.</td>
          <td align="center" width="9%">Tard.</td>
					<td align="center" width="9%">Perm.</td>
				  <td align="center" width="4%">Sel.</td>
        </tr>
        <%
				if (emp.size() > 0) alTPR = CmnMgr.reverseRecords(emp);
				for (int i=0; i<emp.size(); i++){
					key = alTPR.get(i).toString();
          CommonDataObject cdo = (CommonDataObject) emp.get(key);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
        %>
        <%=fb.hidden("emp_id"+i, cdo.getColValue("emp_id"))%>
        <%=fb.hidden("tipo_accion"+i, cdo.getColValue("tipo_accion"))%>
        <%=fb.hidden("sub_t_accion"+i, cdo.getColValue("sub_t_accion"))%>
        <%=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%=fb.hidden("ced_provincia"+i, cdo.getColValue("ced_provincia"))%>
        <%=fb.hidden("ced_sigla"+i, cdo.getColValue("ced_sigla"))%>
        <%=fb.hidden("ced_tomo"+i, cdo.getColValue("ced_tomo"))%>
        <%=fb.hidden("ced_asiento"+i, cdo.getColValue("ced_asiento"))%>
        <%=fb.hidden("fecha_doc"+i, cdo.getColValue("fecha_doc"))%>
        <%=fb.hidden("codigo_estructura"+i, cdo.getColValue("codigo_estructura"))%>
        <%=fb.hidden("sol_empleo_anio"+i, cdo.getColValue("sol_empleo_anio"))%>
        <%=fb.hidden("sol_empleo_codigo"+i, cdo.getColValue("sol_empleo_codigo"))%>
        <%=fb.hidden("ct_emp_id"+i, cdo.getColValue("ct_emp_id"))%>
        <%=fb.hidden("emp_estado"+i, cdo.getColValue("emp_estado"))%>
				<%=fb.hidden("anio"+i, cdo.getColValue("anio"))%>
        <%=fb.hidden("periodo"+i, cdo.getColValue("periodo"))%>
        <%=fb.hidden("quincena"+i, cdo.getColValue("quincena"))%>
				 <%=fb.hidden("fechaInicial"+i, cdo.getColValue("fechaInicial"))%>
        <%=fb.hidden("fechaFinal"+i, cdo.getColValue("fechaFinal"))%>
        <%=fb.hidden("fechaDesde"+i, cdo.getColValue("trans_desde"))%>
        <%=fb.hidden("fechaHasta"+i, cdo.getColValue("trans_hasta"))%>
        <%=fb.hidden("fechaEntrega"+i, cdo.getColValue("fechaEntrega"))%>

				<%=fb.hidden("cedula"+i, cdo.getColValue("cedula"))%>
        <%=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%=fb.hidden("nombre"+i, cdo.getColValue("nombre"))%>
        <tr class="<%=color%>" align="center">
          <td align="center">
           <% if(cdo.getColValue("aprobados").equals("0") && cdo.getColValue("pendientes").equals("0")){
           %>
          <img src="../images/lampara_blanca.gif" alt="Sin Notificaciones ">
            <% } else if( !cdo.getColValue("pendientes").equals("0") || cdo.getColValue("aprobados").equals("0")) { %>
				  <img src="../images/lampara_roja.gif" alt="Notificaciones Pendientes">
				 <% } else if( !cdo.getColValue("aprobados").equals("0") || cdo.getColValue("pendientes").equals("0")) { %>
				  <img src="../images/lampara_verde.gif" alt="Notificaciones Aprobadas">

				 <% } else { %>
				   <img src="../images/lampara_roja.gif" alt="Notificaciones Pendientes">
				 <% }  %>
				 </td>
          <td align="left"><%=cdo.getColValue("cedula")%></td>
          <td align="left"><%=cdo.getColValue("num_empleado")%></td>
          <td align="left"><%=cdo.getColValue("nombre")%></td>
          <td align="center"><%=cdo.getColValue("estadoDesc")%></td>
        <td align="center"><a href="javascript:editAusEmp(<%=i%>)"><img src="../images/open-folder.jpg" border="0" height="16" width="16" title="Ver Detalle de Ausencias"></a></td>
				 <td align="center"><a href="javascript:editIncEmp(<%=i%>)"><img src="../images/open-folder.jpg" border="0" height="16" width="16" title="Ver Detalle de Incapacidades"></a></td>
					 <td align="center"><a href="javascript:editTarEmp(<%=i%>)"><img src="../images/open-folder.jpg" border="0" height="16" width="16" title="Ver Detalle de Tardanzas"></a></td>
          <td align="center"><a href="javascript:editPerEmp(<%=i%>)"><img src="../images/open-folder.jpg" border="0" height="16" width="16" title="Ver Detalle de Permisos"></a></td>
            <td align="center"><%=fb.checkbox("chk"+i,""+i, false, false, "text10", "", "")%></td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="left" colspan="10">Total de Empleados:&nbsp;<font class="WhiteTextBold"><%=alTPR.size()%></font></td>
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

			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("grupo", request.getParameter("grupo"));
			cdo.addColValue("fecha_doc", request.getParameter("fecha_doc"+i));
			cdo.addColValue("fecha_inicial", request.getParameter("fechaInicial"+i));
			cdo.addColValue("fecha_final", request.getParameter("fechaFinal"+i));
			cdo.addColValue("inicio", request.getParameter("fechaDesde"+i));
			cdo.addColValue("final", request.getParameter("fechaHasta"+i));
			cdo.addColValue("anioPago", request.getParameter("anio"+i));
			cdo.addColValue("quincenaPago", request.getParameter("periodo"+i));
			cdo.addColValue("usuario", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			alTPR.add(cdo);
		}
	}

	if (request.getParameter("baction").equalsIgnoreCase("Aprobacion")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 		VacMgr.aprobarNotificacion(alTPR);
		ConMgr.clearAppCtx(null);
	} else if (request.getParameter("baction").equalsIgnoreCase("Anular")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	//	VacMgr.anularNotificacion(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
parent.document.form1.errCode.value='<%=VacMgr.getErrCode()%>';
parent.document.form1.errMsg.value='<%=VacMgr.getErrMsg()%>';
parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>