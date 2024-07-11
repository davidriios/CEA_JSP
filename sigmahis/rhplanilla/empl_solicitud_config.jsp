<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="inc" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql   ="";
String grupo =request.getParameter("grupo");
String empId =request.getParameter("empId");
String res   =request.getParameter("res");
String anio  =request.getParameter("anio");
String fg    =request.getParameter("fg");
String mode  =request.getParameter("mode");
String fp  =request.getParameter("fp");
if(fg==null) fg="PE";
if (fp==null) fp = "";
if (mode == null) mode = "edit"; 
boolean viewMode = false;
if (mode.equalsIgnoreCase("view")) viewMode = true;

String dateRec = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (request.getMethod().equalsIgnoreCase("GET"))
{
 	if (res == null) throw new Exception("El Código de Grupo no es válido. Por favor intente nuevamente!");
	if (empId == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");

 	sql = "select to_char(a.periodof_inicio,'dd/mm/yyyy') periodof_inicio, to_char(a.periodof_final,'dd/mm/yyyy') periodof_final, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_resuelto, a.anio , a.dias_tiempo, a.dias_dinero , a.tipo, a.codigo, a.estado, a.observacion, a.motivo_rechazo, a.contratar_reemplazo contratar, a.emp_id, a.cargo_empleado, e.tipo_emple tipo_puesto, f.denominacion cargoRem, a.remp_id, a.r_num_empleado codPert, a.cargo_reemplazo, a.diferencia_por_reemplazo, a.bonif_por_reemplazo, e.nombre_empleado pertDesc, a.per_actual_vac, a.per_ultima_vac, a.fecha_ult_vac, c.primer_nombre||' '||c.primer_apellido as nombre,  a.provincia||'-'||a.sigla||'-'||a.tomo||' '||a.asiento cedula, c.num_empleado numEmp, decode(a.estado,'AP','APROBADA','PE','PENDIENTE','RE','RECHAZADA') as estadoDesc from tbl_pla_sol_vacacion a,  tbl_pla_empleado c, vw_pla_empleado e , tbl_pla_cargo f where a.compania = "+(String) session.getAttribute("_companyId")+" and  a.emp_id = c.emp_id and a.compania = c.compania and a.compania = e.compania(+) and a.remp_id = e.emp_id(+) and e.compania = f.compania(+) and e.cargo = f.codigo(+) and a.anio = "+anio+" and  a.emp_id = "+empId+" and  a.codigo = "+res;
	inc = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
function doSubmit()
{
  if((document.formSolicitud.fechai.value=='') || (document.formSolicitud.fechaf.value==''))
 	  {
 	  alert('No hay fecha registrada para esta solicitud..  Revisar...');
	  } else {
  document.formSolicitud.submit();
  }
}

function chkReemplazo(){
	if(document.formSolicitud.contratar.checked){
	document.formSolicitud.codPert.value='';
	document.formSolicitud.pertDesc.value='';
	document.formSolicitud.cargoRem.value='';
	document.formSolicitud.btnpert.disabled=true;
	} else {
		document.formSolicitud.btnpert.disabled=false;
	}
}

function addPert()
{

  abrir_ventana1("../common/search_empleado_otros.jsp?fp=sol_vacacion&grupo=<%=grupo%>");
}

function setTipoBonificacion(){
	var tipo_puesto = document.formSolicitud.tipo_puesto.value;
	var cargo_emp = document.formSolicitud.cargo_empleado.value;
	var cargo_reemp = document.formSolicitud.cargo_reemplazo.value;
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var bonif_por_reemplazo = document.formSolicitud.bonif_por_reemplazo.value;
	var diferencia_por_reemplazo = '';
	if (tipo_puesto == ''){
		alert('EL CODIGO DE CARGO DEL EMPLEADO NO TIENE ASIGNADO UN TIPO DE PUESTO (CONFIANZA O SINDICATO) , ESTO ES REQUERIDO PARA VALIDAR SI EL REEMPLAZO PUEDE RECIBIR BONIFICACION, REVISE MANTENIMIENTO DE CARGOS, NO CALCULARA BONIF.');
		bonif_por_reemplazo = 'D';
		diferencia_por_reemplazo = 0;
	}
	if(tipo_puesto == 2){                                                    		/* SINDICALIZADOS*/
		if(bonif_por_reemplazo == 'A') diferencia_por_reemplazo = 100;					/*     JEFE      */
		else if(bonif_por_reemplazo == 'B') diferencia_por_reemplazo = 75;			/*   SUPERVISOR  */
		else if(bonif_por_reemplazo == 'C'){
			if(executeDB('<%=request.getContextPath()%>','call sp_rh_calcula_reemplazo(<%=(String) session.getAttribute("_companyId")%>, \'' + cargo_emp + '\', \'' + cargo_reemp + '\')')){
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
				var arr_cursor = new Array();
				if(msg!=''){
					arr_cursor = splitCols(msg);
					diferencia_por_reemplazo	= arr_cursor[0];
					bonif_por_reemplazo				= arr_cursor[1];
				}
			} else {
				var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
							alert('USUARIO ESTE REEMPLAZO NO RECIBE BONIFICACION YA QUE SU SALARIO BASE ES MAYOR AL DE LA PERSONA QUE ESTA REEMPLAZANDO');
				bonif_por_reemplazo = 'D';
				diferencia_por_reemplazo = 0;
			}
		} else if(bonif_por_reemplazo == 'D') diferencia_por_reemplazo = 0;		/*    NO APLICA  */
	} else if (tipo_puesto == 1){
		alert('ESTE EMPLEADO ES CONSIDERADO COMO PERSONAL DE CONFIANZA, NO RECIBE BONIFICACION');
		bonif_por_reemplazo = 'D';
		diferencia_por_reemplazo = 0;
	}
	document.formSolicitud.diferencia_por_reemplazo.value	= diferencia_por_reemplazo;
	document.formSolicitud.bonif_por_reemplazo.value	= bonif_por_reemplazo;
}

function setValues(value){
	if(value=='RE'){
		document.formSolicitud.motivo_rechazo.readOnly=false;
		} else {
		document.formSolicitud.motivo_rechazo.value = "";
		document.formSolicitud.motivo_rechazo.readOnly=true;
		}
}

function setReemplazoValues(){
	var numId = eval('document.formSolicitud.codPert').value
	var empl = getDBData('<%=request.getContextPath()%>','a.codigo, a.denominacion, a.tipo_puesto','tbl_pla_cargo a, tbl_pla_empleado b','a.compania = b.compania and a.codigo = b.cargo and to_char(b.num_empleado) = '+numId+'','');
	var arr_cursor = new Array();
	if(empl!=''){
		arr_cursor = splitCols(empl);
		if(arr_cursor[0]!=' ') document.formSolicitud.cargo_reemplazo.value				= arr_cursor[0];
		if(arr_cursor[1]!=' ') document.formSolicitud.cargoRem.value			= arr_cursor[1];
		if(arr_cursor[2]!='') document.formSolicitud.tipo_puesto.value	= arr_cursor[2];
		else {
			alert('EL CODIGO DE CARGO DEL EMPLEADO NO TIENE ASIGNADO UN TIPO DE PUESTO (CONFIANZA O SINDICATO) , ESTO ES REQUERIDO PARA VALIDAR SI EL REEMPLAZO PUEDE RECIBIR BONIFICACION, REVISE MANTENIMIENTO DE CARGOS');

		}
	}
}


</script>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECURSO HUMANOS - PROCESO - VACACIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	    <td class="TableBorder">
	    <table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- =================   F O R M   S T A R T   H E R E   =================== -->
		<%fb = new FormBean("formSolicitud",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("empId",empId)%>
		<%=fb.hidden("grupo",grupo)%>
		<%=fb.hidden("r_provincia","")%>
		<%=fb.hidden("r_sigla","")%>
		<%=fb.hidden("r_tomo","")%>
		<%=fb.hidden("r_asiento","")%>
		<%=fb.hidden("tipo_puesto","")%>
		<%=fb.hidden("numEmpleado","")%>
		<%=fb.hidden("cargo_empleado",inc.getColValue("cargo_empleado"))%>
		<%=fb.hidden("cargo_reemplazo",inc.getColValue("cargo_reemplazo"))%>
		<%=fb.hidden("tipo_puesto",inc.getColValue("tipo_puesto"))%>

	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
	</tr>

	<tr class="TextHeader" align="center">
		<td colspan="1">Solicitud de Vacaciones de:</td>
		<td colspan="2"><%=inc.getColValue("nombre")%> &nbsp; #.Empl : <%=inc.getColValue("numEmp")%></td>
		<td colspan="1">Cédula: <%=inc.getColValue("cedula")%></td>
	</tr>

	<tr class="TextRow01">
		<td width="12%"> Año </td>
		<td width="38%"><%=fb.intBox("anio",inc.getColValue("anio"),false,false,true,4,4)%></td>
		<td width="12%"> Código </td>
		<td width="38%"><%=fb.textBox("codigo",inc.getColValue("codigo"),false,false,true,10,"Text12",null,null)%>  Fecha del Resuelto <%=fb.textBox("fecha_resuelto",inc.getColValue("fecha_resuelto"),false,false,true,10,"Text12",null,null)%></td>
	</tr>

	<tr class="TextRow02">
		<td>Fecha Inicial</td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="fieldClass" value="FormDataObjectRequired"/>
			<jsp:param name="nameOfTBox1" value="fechai"/>
			<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("periodof_inicio")==null)?"":inc.getColValue("periodof_inicio")%>" />
			</jsp:include>
		</td>

		<td>Tiempo</td>
		<td><%=fb.intBox("dias_tiempo",inc.getColValue("dias_tiempo"),false,false,false,5,5)%>&nbsp; Dinero <%=fb.intBox("dias_dinero",inc.getColValue("dias_dinero"),false,false,false,5,5)%></td>
	</tr>

	<tr class="TextRow02">
		<td>Fecha Final</td>
		<td><jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="fieldClass" value="FormDataObjectRequired"/>
			<jsp:param name="nameOfTBox1" value="fechaf"/>
			<jsp:param name="valueOfTBox1" value="<%=(inc.getColValue("periodof_final")==null)?"":inc.getColValue("periodof_final")%>" />
			</jsp:include>
		</td>
		
		
		<%  if (!mode.equalsIgnoreCase("view")&&!fg.equalsIgnoreCase("ap"))
		{
		%>
			<td> Estado </td>
			<td>	<%=fb.select("estado","PE= Solicitadas Pendiente",inc.getColValue("estado"))%></td>
		<% } else { %>
			<td> Estado</td>
			<td>	
			<%=fb.select("estado","PE= Solicitadas Pendiente, AP= Aprobadas, RE= Rechazadas, AN= Anulada, PR= Pagada",inc.getColValue("estado"), false, false, 0, "text10", "", "onChange=\"javascript:setValues(this.value)\"", "", "S")%>
			</td>
		<% } %>
		
	
	</tr>

	<% if(fp.equals("")){%>
	<tr class="TextRow02">
		<td>Periodo Actual de Vacacion</td>
		<td><%=fb.textBox("per_actual_vac",inc.getColValue("per_actual_vac"),false,false,false,10,"Text12",null,null)%>
		&nbsp;&nbsp;Periodo Ultima Vacacion &nbsp;
		<%=fb.textBox("per_ultima_vac",inc.getColValue("per_ultima_vac"),false,false,false,10,"Text12",null,null)%>
		</td>
		<td>Fecha Ultima Vacacion</td>
		<td><%=fb.textBox("fecha_ult_vac",inc.getColValue("fecha_ult_vac"),false,false,false,60,"Text12",null,null)%></td>    
	</tr>
	<%}%>

	<tr class="TextRow02">
          <td>Reemplazo</td>
          <td>Contratar Reemplazo ? <%=fb.checkbox("contratar","S",(inc.getColValue("contratar")!=null && inc.getColValue("contratar").equalsIgnoreCase("S")),false, "text10", "", "onClick=\"javascript:chkReemplazo()\"")%></td>
          <td>Reemplazo </td>
           <td><%=fb.intBox("codPert",inc.getColValue("codPert"),false,false,true,5,15,"Text10",null,null)%><%=fb.textBox("pertDesc",inc.getColValue("pertDesc"),false,false,true,30,30,"Text10",null,null)%><%=fb.button("btnpert","...",true,false,null,null,"onClick=\"javascript:addPert()\"")%></td>
        </tr>
        <tr class="TextRow02">
          <td>Cargo que Desempeña</td>
          <td><%=fb.textBox("cargoRem",inc.getColValue("cargoRem"),false,false,true,40)%></td>
          <td>Tipo de Bonificaci&oacute;n &nbsp;&nbsp;</td>
          <td>
		<%=fb.select("bonif_por_reemplazo","D=No Recibe,A=Jefe,B=Supervisor,C=Categoria",inc.getColValue("bonif_por_reemplazo"),false,false,0,"Text10",null,"onChange=\"javascript:setTipoBonificacion()\"")%>&nbsp;&nbsp;
		<%=fb.textBox("diferencia_por_reemplazo",inc.getColValue("diferencia_por_reemplazo"),false,false,true,10)%>
          </td>
        </tr>


	


	<tr class="TextRow02" >
	 <td>Motivo del Rechazo</td>
	          <td><%=fb.textarea("motivo_rechazo",inc.getColValue("motivo_rechazo"),false,false,true,50,3)%></td>
	          <td>Observaciones</td>
	          <td><%=fb.textarea("observacion",inc.getColValue("observacion"),false,false,false,50,3)%></td>
	          
        </tr>
      

	<tr class="TextRow02">
		<td align="right" colspan="4">
		<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(0,this.value)\"")%><%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
		
	</tr>

	<tr>
	    <td colspan="4">&nbsp;</td>
	</tr>
        <%=fb.formEnd(true)%>
        <!-- ======================   F O R M   E N D   H E R E   ==================== -->
        </table>
	  </td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
   
   String codigo = "";
   String fecha = "";
   empId = request.getParameter("empId");
   anio = request.getParameter("anio");
   res = request.getParameter("codigo");
   fecha = request.getParameter("fecha_resuelto");

   CommonDataObject cdo = new CommonDataObject();
   cdo.setTableName("tbl_pla_sol_vacacion");
   cdo.addColValue("fecha_solicitud",request.getParameter("fecha_resuelto"));
   	cdo.addColValue("periodof_inicio",request.getParameter("fechai"));
   	cdo.addColValue("periodof_final",request.getParameter("fechaf"));
   	cdo.addColValue("dias_tiempo",request.getParameter("dias_tiempo"));
   	cdo.addColValue("dias_dinero",request.getParameter("dias_dinero"));
   	cdo.addColValue("estado",request.getParameter("estado"));
	//	cdo.addColValue("fecha_modificacion",request.getParameter("dateRec"));
  	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));

  	cdo.addColValue("per_actual_vac",request.getParameter("per_actual_vac"));
   	cdo.addColValue("per_ultima_vac",request.getParameter("per_ultima_vac"));
   	cdo.addColValue("fecha_ult_vac",request.getParameter("fecha_ult_vac"));

	// cdo.addColValue("contratar_reemplazo","N");
	cdo.addColValue("contratar_reemplazo",request.getParameter("contratar_reemplazo"));
	
	cdo.addColValue("observacion",request.getParameter("observacion"));
	cdo.addColValue("r_num_empleado",request.getParameter("codPert"));
	cdo.addColValue("cargo_empleado",request.getParameter("cargo_empleado"));
	cdo.addColValue("cargo_reemplazo",request.getParameter("cargo_reemplazo"));
	cdo.addColValue("bonif_por_reemplazo",request.getParameter("bonif_por_reemplazo"));
	
	if(request.getParameter("diferencia_por_reemplazo")!=null && !request.getParameter("diferencia_por_reemplazo").equals("")) cdo.addColValue("diferencia_por_reemplazo",request.getParameter("diferencia_por_reemplazo"));
	if(request.getParameter("r_provincia")!=null && !request.getParameter("r_provincia").equals("")) cdo.addColValue("r_provincia",request.getParameter("r_provincia"));
	if(request.getParameter("r_sigla")!=null && !request.getParameter("r_sigla").equals("")) cdo.addColValue("r_sigla",request.getParameter("r_sigla"));
	if(request.getParameter("r_tomo")!=null && !request.getParameter("r_tomo").equals("")) cdo.addColValue("r_tomo",request.getParameter("r_tomo"));
	if(request.getParameter("r_asiento")!=null && !request.getParameter("r_asiento").equals("")) cdo.addColValue("r_asiento",request.getParameter("r_asiento"));
	
	
	
	
	
  if (request.getParameter("estado").equalsIgnoreCase("AP"))
  	{
	cdo.addColValue("fecha_aprobacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_aprob",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	}
	
  if (request.getParameter("estado").equalsIgnoreCase("RE"))
  	{
	cdo.addColValue("fecha_aprobacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("usuario_aprob",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	cdo.addColValue("observacion",request.getParameter("observacion"));
	cdo.addColValue("motivo_rechazo",request.getParameter("motivo_rechazo"));
        }

   cdo.setWhereClause(" emp_id="+empId+" and codigo ="+res+" and to_date(to_char(fecha_solicitud, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fecha+"', 'dd/mm/yyyy') and anio="+anio+" and compania="+(String) session.getAttribute("_companyId"));
   SQLMgr.update(cdo);


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

	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empl_solicitud_list.jsp?grupo=<%=grupo%>&empId=<%=empId%>';

	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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