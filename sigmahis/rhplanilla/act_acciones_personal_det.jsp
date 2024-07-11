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
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AccionesEmpleadoMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="emp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="empKey" scope="session" class="java.util.Hashtable" />

<%

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

boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select p.compania, p.tipo_accion, p.sub_t_accion, to_char(p.fecha_doc, 'dd/mm/yyyy') fecha_doc, p.primer_nombre, p.primer_apellido, p.ced_provincia, p.ced_sigla, p.ced_tomo, p.ced_asiento, p.salario, p.cargo, p.cargo_insti_dest, p.ubic_rhdepto_dest, p.ubic_rhseccion_dest, p.emp_id, p.num_empleado, p.usuario_creacion, to_char(p.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, p.usuario_modificacion, p.fecha_modificacion, p.resultado_ppru, p.segundo_nombre, p.segundo_apellido, p.unidad_adm, to_char(p.fecha_efectiva, 'dd/mm/yyyy') fecha_efectiva, p.codigo_estructura, nvl(p.gasto_rep,0) gasto_rep, p.estado, p.origen_datos, p.sol_empleo_anio, p.sol_empleo_codigo, to_char(p.ced_provincia)||'-'|| p.ced_sigla||'-'|| to_char(p.ced_tomo,'09999')||'-'||to_char(p.ced_asiento,'099999') cedula, p.primer_nombre||' '||p.segundo_nombre||' '||p.primer_apellido||' '||p.segundo_apellido||' '||p.apellido_casada as nombre, nvl((select descripcion from tbl_pla_ap_sub_tipo where tipo_accion = p.tipo_accion and codigo = p.sub_t_accion), ' ') desc_sub_tipo_accion, /* coalesce(ce.emp_id, -1) ct_emp_id, */ coalesce(e.estado, -1) emp_estado, nvl(p.salario_dest,0) salario_dest, nvl(p.gasto_rep_dest,0) gasto_rep_dest, nvl(p.horario_dest,e.horario) horario_dest from tbl_pla_ap_accion_per p, /* tbl_pla_ct_empleado ce, */ tbl_pla_empleado e where p.compania  = "+(String) session.getAttribute("_companyId") +" and p.tipo_accion = "+type+" and p.estado = 'E' and /* p.emp_id = ce.emp_id(+) and */ p.emp_id = e.emp_id(+)";
		System.out.println("SQL =\n"+sql);
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

function chkSelected(){
	var size = <%=alTPR.size()%>;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	if(x==0) return false;
	else return true;
}


function doSubmit(action){
	document.form.baction.value 			= action;
	if(action == 'Aplicar Accion de Ingreso' && chkNumEmpleado()){
		formBlockButtons(true);
		if(chkSelected()){
			if(confirm('Confirma que Desea Aplicar la Acción de Ingreso?')) document.form.submit();
		} else alert('Seleccione al menos una solicitud!');
		formBlockButtons(false);
	} else if(action == 'Aplicar Acciones Seleccionadas'){
		formBlockButtons(true);
		if(chkSelected()) document.form.submit();
		else alert('Seleccione al menos un Empleado!');
		formBlockButtons(false);
	}
}



function openSolVac(i){
	var v_compania	= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 		= eval('document.form.emp_id'+i).value;
	var codigo 		= eval('document.form.codigo'+i).value;
	//var anio 			= document.form.anio.value;
	var anio 			= eval('document.form.anioSol'+i).value;

	abrir_ventana('../rhplanilla/aprobar_rechazar_solicitud_vac.jsp?fp=aprobar_rechazar_solicitud_vac&empId='+emp_id+'&codigo='+codigo+'&anio='+anio);
}

function openExpEmp(i){
	var consecutivo = eval('document.form.sol_empleo_codigo'+i).value;
	var anio 				= eval('document.form.sol_empleo_anio'+i).value;
	var emp_id 		= eval('document.form.emp_id'+i).value;
	abrir_ventana('../rhplanilla/expediente_empleado_config.jsp?fp=rrhh&fg=ingreso&empId='+emp_id+'&consecutivo='+consecutivo+'&anio='+anio);
}

function editSolEmp(i){
	var v_compania		= <%=(String) session.getAttribute("_companyId")%>;
	var emp_id 				= eval('document.form.emp_id'+i).value;
	var tipo_accion 	= eval('document.form.tipo_accion'+i).value;
	var sub_t_accion 	= eval('document.form.sub_t_accion'+i).value;
	var fecha_doc 		= eval('document.form.fecha_doc'+i).value;
	var ced_provincia	= eval('document.form.ced_provincia'+i).value;
	var ced_sigla 		= eval('document.form.ced_sigla'+i).value;
	var ced_tomo 			= eval('document.form.ced_tomo'+i).value;
	var ced_asiento 	= eval('document.form.ced_asiento'+i).value;
	var tab 					= "";
	if (tipo_accion=='1') tab=4;
	if (tipo_accion=='2' && sub_t_accion=='1') tab=1;
	if (tipo_accion=='2' && sub_t_accion=='5') tab=2;
	if (tipo_accion=='3') tab=3;

	abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?tab='+tab+'&mode=edit&fp=ingreso&emp_id='+emp_id+'&tipo_accion='+tipo_accion+'&sub_tipo_accion='+sub_t_accion+'&fecha_doc='+fecha_doc+'&prov='+ced_provincia+'&sigla='+ced_sigla+'&tomo='+ced_tomo+'&asiento='+ced_asiento);
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
	if(num_empleado != '' && ced_provincia != '' && ced_sigla != '' && ced_tomo != '' && ced_asiento != ''){
		if(emp_estado=='3') alert('El empleado esta Cesante!');
		else {
			if(ct_emp_id=='-1') abrir_ventana('../rhplanilla/emp_config.jsp?tab=4&fp=ingreso&id='+emp_id+'&mode=add');
			else abrir_ventana('../rhplanilla/emp_config.jsp?tab=4&mode=edit&fp=ingreso&id='+emp_id+'&mode=edit');
		}
	}
}

function Ver(empId,fp,tipo,subaccion,fecha,fechaEfectiva,i)
{
	var fp='';

	if(tipo==1)
	{
		var prov = eval('document.form.ced_provincia'+i).value;
		var sigla = eval('document.form.ced_sigla'+i).value;
		var tomo = eval('document.form.ced_tomo'+i).value;
		var asiento = eval('document.form.ced_asiento'+i).value;
		abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp=ingreso&tipo_accion='+tipo+'&mode=view&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab=4&fecha_doc='+fecha+'&prov='+prov+'&sigla='+sigla+'&tomo='+tomo+'&asiento='+asiento);
		fp='ingreso';

	} else if(tipo==2){
			fp='e';
			abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp='+fp+'&tipo_accion='+tipo+'&mode=view&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab=0&fecha_doc='+fecha);
	} else if(tipo==3)	{
			fp='e';
			abrir_ventana('../rhplanilla/acciones_movilidad_config.jsp?fp='+fp+'&tipo_accion='+tipo+'&mode=view&emp_id='+empId+'&sub_tipo_accion='+subaccion+'&tab=3&fecha_doc='+fecha);
	}
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
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="left" width="4%">&nbsp;</td>
          <td align="left" width="16%">C&eacute;dula</td>
          <td align="left" width="8%">No. Empl.</td>
          <td align="left" width="33%">Nombre Empleado</td>
          <td align="left" width="25%">Tipo de Acción (Sub-Tipo)</td>
          <td align="center" width="12%">Fecha Efectiva</td>
          <td align="center" width="4%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','chk',"+emp.size()+",this)\"","Seleccionar todos registros listados!")%></td>
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
				<%=fb.hidden("fecha_efectiva"+i, cdo.getColValue("fecha_efectiva"))%>
        <%=fb.hidden("codigo_estructura"+i, cdo.getColValue("codigo_estructura"))%>
        <%=fb.hidden("sol_empleo_anio"+i, cdo.getColValue("sol_empleo_anio"))%>
        <%=fb.hidden("sol_empleo_codigo"+i, cdo.getColValue("sol_empleo_codigo"))%>
        <%=fb.hidden("ct_emp_id"+i, cdo.getColValue("ct_emp_id"))%>
        <%=fb.hidden("cargo"+i, cdo.getColValue("cargo"))%>
        <%=fb.hidden("cargo_insti_dest"+i, cdo.getColValue("cargo_insti_dest"))%>
        <%=fb.hidden("ubic_rhdepto_dest"+i, cdo.getColValue("ubic_rhdepto_dest"))%>
        <%=fb.hidden("ubic_rhseccion_dest"+i, cdo.getColValue("ubic_rhseccion_dest"))%>
        <%=fb.hidden("emp_estado"+i, cdo.getColValue("emp_estado"))%>
				<%=fb.hidden("salario_dest"+i, cdo.getColValue("salario_dest"))%>
        <%=fb.hidden("gasto_rep_dest"+i, cdo.getColValue("gasto_rep_dest"))%>
        <%=fb.hidden("horario_dest"+i, cdo.getColValue("horario_dest"))%>
        <tr class="<%=color%>" align="center">
          <td align="center">&nbsp;<authtype type='1'><a href="javascript:Ver('<%=cdo.getColValue("emp_id")%>','<%=cdo.getColValue("tipo_accion")%>','<%=cdo.getColValue("tipo_accion")%>','<%=cdo.getColValue("sub_t_accion")%>','<%=cdo.getColValue("fecha_doc")%>','<%=cdo.getColValue("fecha_efectiva")%>',<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype></td>
          <td align="left"><%=cdo.getColValue("cedula")%></td>
          <td align="left"><%=cdo.getColValue("num_empleado")%></td>
          <td align="left"><%=cdo.getColValue("nombre")%></td>
          <td align="left">[ <%=cdo.getColValue("sub_t_accion")%> ] &nbsp; <%=cdo.getColValue("desc_sub_tipo_accion")%></td>
          <td align="center"><%=cdo.getColValue("fecha_efectiva")%></td>
          <td align="center"><%=fb.checkbox("chk"+i,""+i, false, false, "text10", "", "")%></td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="left" colspan="11">Total Acciones:&nbsp;<font class="WhiteTextBold"><%=alTPR.size()%></font></td>
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
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("num_empleado", request.getParameter("num_empleado"+i));
			cdo.addColValue("ced_provincia", request.getParameter("ced_provincia"+i));
			cdo.addColValue("ced_sigla", request.getParameter("ced_sigla"+i));
			cdo.addColValue("ced_tomo", request.getParameter("ced_tomo"+i));
			cdo.addColValue("ced_asiento", request.getParameter("ced_asiento"+i));
			cdo.addColValue("tipo_accion", request.getParameter("tipo_accion"+i));
			cdo.addColValue("sub_t_accion", request.getParameter("sub_t_accion"+i));
			cdo.addColValue("fecha_doc", request.getParameter("fecha_doc"+i));
			cdo.addColValue("fecha_efectiva", request.getParameter("fecha_efectiva"+i));
			cdo.addColValue("salario_dest", request.getParameter("salario_dest"+i));
			cdo.addColValue("gasto_rep_dest", request.getParameter("gasto_rep_dest"+i));
			cdo.addColValue("horario_dest", request.getParameter("horario_dest"+i));

			cdo.addColValue("cargo", request.getParameter("cargo_insti_dest"+i));
			cdo.addColValue("ubic_rhdepto_dest", request.getParameter("ubic_rhdepto_dest"+i));
			cdo.addColValue("ubic_rhseccion_dest", request.getParameter("ubic_rhseccion_dest"+i));

			cdo.addColValue("codigo_estructura", request.getParameter("codigo_estructura"+i));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		  if (request.getParameter("baction").equalsIgnoreCase("Aplicar Acciones Seleccionadas")) cdo.addColValue("accion", "actualizar");
			alTPR.add(cdo);
		}
	}

	if (request.getParameter("baction").equalsIgnoreCase("Aplicar Acciones Seleccionadas")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AEmpMgr.aplica_actualizaAccion(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
parent.document.form1.errCode.value='<%=AEmpMgr.getErrCode()%>';
parent.document.form1.errMsg.value='<%=AEmpMgr.getErrMsg()%>';
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