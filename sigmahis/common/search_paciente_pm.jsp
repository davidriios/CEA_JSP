<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htPac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPac" scope="session" class="java.util.Vector" />
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

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String index = request.getParameter("index");
String pac_id = request.getParameter("pac_id");
String context = request.getParameter("context")==null?"":request.getParameter("context");
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (index == null) index = "";
String usaPlanMedico = java.util.ResourceBundle.getBundle("issi").getString("usaPlanMedico");
if(usaPlanMedico==null) usaPlanMedico="N";

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

	String status = request.getParameter("status");
	String estado = request.getParameter("estado");
	String dob = request.getParameter("dob");
	String codigo = request.getParameter("codigo");
	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	String pacId = request.getParameter("pacId");
	String nombre = request.getParameter("nombre");
	String apellido = request.getParameter("apellido");
	String contrato = request.getParameter("contrato");
	String secuencia = request.getParameter("secuencia");
	if (status == null) status = "A";
	if (fp.equals("liq_recl")) status = "";
	if (estado == null) estado = "A";
	if (dob == null) dob = "";
	if (codigo == null) codigo = "";
	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (pacId == null) pacId = "";
	if (nombre == null) nombre = "";
	if (apellido == null) apellido = "";
	if (pac_id == null) pac_id = "";
	if (contrato == null) contrato = "";
	if (secuencia == null) secuencia = "";
	if(!fp.equals("merge")){ if (!status.trim().equals("")) { sbFilter.append(" and estatus='"); sbFilter.append(status); sbFilter.append("'"); }} else sbFilter.append(" and estatus='I'");
	if (!dob.trim().equals("")) { sbFilter.append(" and fecha_nacimiento=to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and codigo like '"); sbFilter.append(codigo); sbFilter.append("%'"); }
	if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and pac_id="); sbFilter.append(pacId); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(nombre_paciente) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	//if (!apellido.trim().equals("")) { sbFilter.append(" and upper(decode(primer_apellido,null,'',primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))) like '%"); sbFilter.append(apellido.toUpperCase()); sbFilter.append("%'"); }
    
if (!fp.equalsIgnoreCase("admFP") || (fp.equalsIgnoreCase("admFP") && request.getParameter("status") != null)) {
	sbSql.append("select pac_id, to_char(fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, codigo, id_paciente as cedulaPasaporte, nombre_paciente as nombrePaciente, sexo, estatus, pasaporte, provincia, sigla, tomo, asiento, d_cedula, vip, edad||' a '||edad_mes||' m '||edad_dias || ' d' edad, residencia_direccion, nvl((select distinct 'S' from tbl_pm_solicitud_contrato sc where estado = 'F' and exists (select null from tbl_pm_sol_contrato_det scd where sc.id = scd.id_solicitud and scd.id_cliente = a.codigo)),'N') cont_finalizaado, ");
	if(fp.equals("hist_reclamo")){sbSql.append("cd.id_solicitud contrato");}
	else sbSql.append("(select id_solicitud from tbl_pm_sol_contrato_det d where d.id_cliente = a.codigo and d.estado = 'A' and rownum=1) contrato ");
    
    if (fp.equalsIgnoreCase("liq_recl") || fp.equalsIgnoreCase("rpt_elegibles")){
       sbSql.append(" , s.id as poliza ");
	}
	 sbSql.append(" from vw_pm_cliente a");
    if (fp.equalsIgnoreCase("liq_recl") || fp.equalsIgnoreCase("rpt_elegibles") || fp.equalsIgnoreCase("admision") ){
       sbSql.append(" , tbl_pm_solicitud_contrato s, tbl_pm_sol_contrato_det cd ");
    }
     if (fp.equalsIgnoreCase("liq_recl") || fp.equalsIgnoreCase("rpt_elegibles") || fp.equalsIgnoreCase("admision")){
	   sbSql.append(" where s.id is not null ");
       
			 sbSql.append(" and tipo_clte = 'C' and cd.id_solicitud = s.id and (cd.estado = 'A' or (cd.estado = 'I' and to_date(to_char(fecha_finaliza, 'mm/yyyy'), 'mm/yyyy') = to_date(to_char(sysdate, 'mm/yyyy'), 'mm/yyyy')))");
			 if(fp.equalsIgnoreCase("admision") || fp.equalsIgnoreCase("hist_reclamo")) sbSql.append(" and cd.id_cliente = a.codigo");
			 else sbSql.append(" and s.id_cliente = a.codigo");
       if (!contrato.trim().equals("")) {
         sbSql.append(" and s.id = ");
         sbSql.append(contrato);
       }
			 
    }else sbSql.append(" where pac_id is null ");
	
	sbSql.append(sbFilter);
	sbSql.append(" order by pac_id desc");
    
    if (fp.equals("liq_recl") || fp.equals("rpt_elegibles") || fp.equals("hist_comision")|| fp.equalsIgnoreCase("hist_reclamo")) {
      sbSql = new StringBuffer();
      sbFilter = new StringBuffer();
      
      if(!fp.equals("merge")){ if (!status.trim().equals("")) { sbFilter.append(" and a.estado='"); sbFilter.append(status); sbFilter.append("'"); }} else sbFilter.append(" and a.estado ='I'");
      if (!dob.trim().equals("")) { sbFilter.append(" and b.fecha_nacimiento =to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
	  if (!codigo.trim().equals("")) { sbFilter.append(" and b.codigo like '"); sbFilter.append(codigo); sbFilter.append("%'"); }
	if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(coalesce(pasaporte,provincia||'-'||sigla||'-'||tomo||'-'||asiento)||'-'||d_cedula) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and pac_id="); sbFilter.append(pacId); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre) ||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada))) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
    
    if (!contrato.trim().equals("")) {
         sbFilter.append(" and a.id_solicitud = ");
         sbFilter.append(contrato);
       } 
       
       if (!secuencia.trim().equals("")) {
         sbFilter.append(" and a.secuencia = ");
         sbFilter.append(secuencia);
       }
	
 			 if(!estado.equals("")){
				 sbFilter.append(" and ss.estado = '");
				 sbFilter.append(estado);
				 sbFilter.append("'");
			 }
       
     
      sbSql.append("select pac_id, a.id_solicitud, b.codigo, a.id, a.id_cliente, a.parentesco, a.estado estatus, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.observacion, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as cedulapasaporte, a.estado, decode(ss.estado, 'A', 'ACTIVO', 'F', 'FINALIZADO', ss.estado) estado_desc, b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre) ||' '||b.primer_apellido||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada))  as nombrePaciente, b.sexo, get_age(coalesce(b.f_nac, b.fecha_nacimiento), sysdate, 'd') edad, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.costo_mensual, a.id_solicitud poliza, b.residencia_direccion, a.secuencia no_contrato , to_char(ss.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan, ss.id contrato ");

       sbSql.append(" from tbl_pm_sol_contrato_det a, tbl_pm_cliente b, tbl_pm_solicitud_contrato ss where a.id_cliente = b.codigo");
			 if(fp.equals("liq_recl")){
				 sbSql.append(" and exists (select id_solicitud, id_cliente, max(id) from tbl_pm_sol_contrato_det cd where cd.id_solicitud = a.id_solicitud and cd.id_cliente = a.id_cliente group by id_solicitud, id_cliente having max(id) = a.id)");
			 }else if(fp.equals("hist_reclamo")) sbSql.append(" and a.estado in ('A','I')");
			 else sbSql.append(" and a.estado = 'A'");
			 sbSql.append(" and b.tipo_clte = 'C' and  a.id_solicitud = ss.id ");
      sbSql.append(sbFilter);
    }

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
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
    
    String jsContext = "window.opener.";
    if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Paciente - '+document.title;
function add(){<% if (fp.equalsIgnoreCase("admFP") && request.getParameter("status") == null) { %>if(confirm('No ha verificado si el paciente existe. ¿Desea continuar?'))<% } %>abrir_ventana2('../admision/paciente_config.jsp?fp=<%=fp%>');}
function edit(pacId){abrir_ventana2('../admision/paciente_config.jsp?fp=<%=fp%>&mode=edit&pacId='+pacId);}
function setPacTypeImg(){
	var img='blank.gif';
	var pacType='';
	if(document.form0.key.value=='D'){img='distinguido.gif';pacType='DISTINGUIDO';}
	else if(document.form0.key.value=='S'){img='vip.gif';pacType='V.I.P.';}
	else if(document.form0.key.value=='M'){img='medico.gif';pacType='MEDICO DEL STAFF';}
	else if(document.form0.key.value=='J'){img='junta.gif';pacType='JUNTA DIRECTIVA';}
	if(pacType.trim()!='')alert('<%=UserDet.getName()%>:\nRecuerda, este es un cliente '+pacType+', gracias!!');
	document.getElementById('pacTypeImg').src='../images/'+img;
}
function savePaciente(k)
{
	var docId = eval('document.result.codigo'+k).value;
	var fecha = eval('document.result.fechaNacimiento'+k).value;
	var id_paciente = eval('document.result.cedulaPasaporte'+k).value;
	var existe = getDBData('<%=request.getContextPath()%>','\'S\'','vw_adm_paciente','id_paciente=\''+id_paciente+'\'')||'N';
	if (eval('document.result.estatus'+k).value.toUpperCase() == 'I' && '<%=fp%>' != 'liq_recl')
	{
		alert('No está permitido seleccionar pacientes inactivos!!');
		return false;
	} else if(existe=='S') {alert('Ya existe un paciente registrado con este número de cédula!');return false;}
	else
	{
<% if (fp.equalsIgnoreCase("admision")) { %>
		showPopWin('../common/run_process.jsp?fp=admision&actType=1&docType=PAC_PM&docNo=X&docId='+docId+'&fecha='+fecha+'&index='+k,winWidth*.75,winHeight*.65,null,null,'');
<% }%>

	}
}
function setPaciente(id, k)
{
	if (eval('document.result.estatus'+k).value.toUpperCase() == 'I' && ('<%=fp%>' != 'liq_recl' && '<%=fp%>' != 'hist_reclamo'))
	{
		alert('No está permitido seleccionar pacientes inactivos!!');
		return false;
	}
	else
	{
<% if (fp.equalsIgnoreCase("admision")) { %>
		window.opener.document.form0.pacId.value = id;
		window.opener.window.focus();
		if (window.opener.pendingBalanceConfirmation(0))
		{
			window.opener.document.form0.codigoPaciente.value = eval('document.result.codigo'+k).value;
			window.opener.document.form0.provincia.value = eval('document.result.provincia'+k).value;
			window.opener.document.form0.sigla.value = eval('document.result.sigla'+k).value;
			window.opener.document.form0.tomo.value = eval('document.result.tomo'+k).value;
			window.opener.document.form0.asiento.value = eval('document.result.asiento'+k).value;
			window.opener.document.form0.dCedula.value = eval('document.result.dCedula'+k).value;
			window.opener.document.form0.dCedulaDisplay.value = eval('document.result.dCedula'+k).value;
			window.opener.document.form0.pasaporte.value = eval('document.result.pasaporte'+k).value;
			window.opener.document.form0.nombrePaciente.value = eval('document.result.nombrePaciente'+k).value;
			window.opener.document.form0.fechaNacimiento.value = eval('document.result.fechaNacimiento'+k).value;
			window.opener.document.form0.key.value=eval('document.result.vip'+k).value;
		}
		else
		{
			window.opener.document.form0.pacId.value = '';
			window.opener.document.form0.codigoPaciente.value = '';
			window.opener.document.form0.provincia.value = '';
			window.opener.document.form0.sigla.value = '';
			window.opener.document.form0.tomo.value = '';
			window.opener.document.form0.asiento.value = '';
			window.opener.document.form0.dCedula.value = '';
			window.opener.document.form0.pasaporte.value = '';
			window.opener.document.form0.nombrePaciente.value = '';
			window.opener.document.form0.fechaNacimiento.value = '';
			window.opener.document.form0.key.value='';
		}
		window.opener.setPacTypeImg();
<% }else if(fp.equalsIgnoreCase("liq_recl")){%>
        if(window.opener.document.form0.codigo_paciente)window.opener.document.form0.codigo_paciente.value = eval('document.result.codigo'+k).value;
        if(window.opener.document.form0.sexo)window.opener.document.form0.sexo.value = eval('document.result.sexo'+k).value;
        if(window.opener.document.form0.edad)window.opener.document.form0.edad.value = eval('document.result.edad'+k).value;
        if(window.opener.document.form0.direccion_residencial)window.opener.document.form0.direccion_residencial.value = eval('document.result.residencia_direccion'+k).value;
        if(window.opener.document.form0.poliza) {
          var value = eval('document.result.poliza'+k).value;
          $("#poliza", window.opener.document)
             .append($("<option></option>")
             .val(value)
             .prop('selected', true)
             .text("Contrato #"+value))
             .change();
        //window.opener.document.form0.poliza.value = eval('document.result.poliza'+k).value;
        }
		if(window.opener.document.form0.cedulaPasaporte)window.opener.document.form0.cedulaPasaporte.value = eval('document.result.cedulaPasaporte'+k).value;
		if(window.opener.document.form0.nombreCliente)window.opener.document.form0.nombreCliente.value = eval('document.result.nombrePaciente'+k).value;
		if(window.opener.document.form0.fecha_nacimiento)window.opener.document.form0.fecha_nacimiento.value = eval('document.result.fechaNacimiento'+k).value;
		if(window.opener.document.form0.pacId)window.opener.document.form0.pacId.value = eval('document.result.pacId'+k).value;
		if(window.opener.document.form0.no_contrato)window.opener.document.form0.no_contrato.value = eval('document.result.no_contrato'+k).value;
		if(window.opener.document.form0.fecha_egreso)window.opener.document.form0.fecha_egreso.value = eval('document.result.fecha_ini_plan'+k).value;
		if(window.opener.document.form0.fecha_ini_plan)window.opener.document.form0.fecha_ini_plan.value = eval('document.result.fecha_ini_plan'+k).value;
    <% } else if (fp.equalsIgnoreCase("rpt_elegibles")) {%>
      if(<%=jsContext%>document.search00.contrato)<%=jsContext%>document.search00.contrato.value = eval('document.result.rpt_no_contrato'+k).value;
      if(<%=jsContext%>document.search00.nombre_ben)<%=jsContext%>document.search00.nombre_ben.value = eval('document.result.nombrePaciente'+k).value;
    <%} else if (fp.equalsIgnoreCase("hist_comision")) {%>
      if(<%=jsContext%>document.form0.contrato)<%=jsContext%>document.form0.contrato.value = eval('document.result.rpt_no_contrato'+k).value;
      if(<%=jsContext%>document.form0.responsable)<%=jsContext%>document.form0.responsable.value = eval('document.result.nombrePaciente'+k).value;
      if(<%=jsContext%>document.form0.id_responsable)<%=jsContext%>document.form0.id_responsable.value = eval('document.result.codigo'+k).value;
    <%} else if (fp.equalsIgnoreCase("hist_reclamo")) {%>
      if(<%=jsContext%>document.form0.contrato)<%=jsContext%>document.form0.contrato.value = eval('document.result.rpt_no_contrato'+k).value;
      if(<%=jsContext%>document.form0.responsable)<%=jsContext%>document.form0.responsable.value = eval('document.result.nombrePaciente'+k).value;
      if(<%=jsContext%>document.form0.id_responsable)<%=jsContext%>document.form0.id_responsable.value = eval('document.result.codigo'+k).value;
    <%}%>

	}
	<%if(context.equalsIgnoreCase("preventPopupFrame")){%>
           <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
		<%}else{%>
        window.close();
        <%}%>
}
function unload(){<%=(fp.equalsIgnoreCase("admision"))?"closeChild=false;":""%>}
function saveFP(pacId){if(parent.reloadOwner)parent.reloadOwner(pacId);}
function doAction(){
<% if (fp.equalsIgnoreCase("admFP") && request.getParameter("status") == null) { %>alert('Por favor verifique si el paciente existe antes de registrar uno nuevo!');<% } %>
<% if(context.equalsIgnoreCase("preventPopupFrame") && al.size()==1){%> setPaciente('0',0);
<%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}%>
}
function selPacPM(){window.location='../common/search_paciente.jsp?fp=admision';}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<% if (!fp.equalsIgnoreCase("admFP")) { %>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PACIENTE"></jsp:param>
</jsp:include>
<% } %>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%if(!fp.equalsIgnoreCase("liq_recl") && !fp.equalsIgnoreCase("rpt_elegibles")){%>
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Paciente</cellbytelabel> ]</a></authtype></td>
</tr>
<%}%>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("pac_id",pac_id)%>

		<tr class="TextFilter">
			<td>
				<cellbytelabel>Estado</cellbytelabel>
				<%if(fp.trim().equals("admision")){%>
				<%//=fb.select("status","A=ACTIVO",status,false,false,0,"Text10",null,null,null,"")%>
				<%=fb.hidden("status",status)%>
				<%}else{%>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%}%>

				<cellbytelabel>Fecha Nac</cellbytelabel>.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="dob" />
				<jsp:param name="valueOfTBox1" value="<%=dob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
		
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,5,"Text10",null,null)%>
			
				<cellbytelabel>C&eacute;dula / Pasaporte</cellbytelabel>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,10,"Text10",null,null)%>
			
				<cellbytelabel>Pac. Id</cellbytelabel>
				<%=fb.intBox("pacId","",false,false,false,3,"Text10",null,null)%>
            
			</td>
            

		</tr>		
		<tr class="TextFilter">
			<td>
				
            <%if(fp.equals("liq_recl") || fp.equals("rpt_elegibles") || fp.equals("hist_comision")){%>
				<cellbytelabel>Contrato</cellbytelabel>
				<%=fb.intBox("contrato","",false,false,false,3,"Text10",null,null)%>
                <cellbytelabel>Secuencia</cellbytelabel>
				<%=fb.intBox("secuencia","",false,false,false,3,"Text10",null,null)%>
            <%}%>
            <%if(fp.equals("admision")){%>
				<cellbytelabel>Contrato</cellbytelabel>
				<%=fb.intBox("contrato","",false,false,false,3,"Text10",null,null)%>
						<%}%>
				<cellbytelabel>Nombre Paciente</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,30,"Text10",null,null)%>
				Estado Contrato
				<%=fb.select("estado","A=ACTIVO,F=FINALIZADO",estado,false,false,0,"Text10",null,null,null,"")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
				<%if(usaPlanMedico.equals("S") && fp.equals("admision")){%><%=fb.button("pacPM","Pacientes",true,false,null,null,"onClick=\"javascript:selPacPM()\"")%><%}%>
			</td>
            

		</tr>
		<%fb.appendJsValidation("if((document.search00.dob.value!='' && !isValidateDate(document.search00.dob.value))){alert('Formato de fecha inválida!');error++;}");%>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("estado",estado)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("estado",estado)%>
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
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
		<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list" exclude="7">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
			<td width="6%"><cellbytelabel><%=fp.equals("liq_recl") || fp.equals("rpt_elegibles") ?"Contrato":"C&oacute;digo"%></cellbytelabel></td>
			<td width="12%"><cellbytelabel>C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Pac. Id</cellbytelabel></td>
			<td width="37%"><cellbytelabel>Nombre del Paciente</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Sexo</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado Cont.</cellbytelabel></td>
			<%if(fp.equals("admision")||fp.equals("hist_comision")||fp.equals("hist_reclamo")){%>
			<td width="10%"><cellbytelabel>Contrato</cellbytelabel></td>
			<%}%>
			<td width="5%">&nbsp;</td>
			<%if(!fp.equals("merge")){%><td width="5%">&nbsp;</td><%}%>
		</tr>
		<% if (fp.equalsIgnoreCase("admFP") && request.getParameter("status") == null) { %>
		<tr class="TextRow01" align="center">
			<td colspan="8" class="UpperCaseText SpacingText RedText">Verifique si el paciente existe antes de registrar uno nuevo!</td>
		</tr>
		<% } %>
<%fb = new FormBean("result","","post","");%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
	<%
	if(fp.equals("merge")){
	%>
      <tr>
        <td align="right" colspan="9"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%></td>
      </tr>
	<%}%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if(cdo.getColValue("cont_finalizaado"," ").equals("S")) color = "TextRow09";
	String evt;
	if (fp.equalsIgnoreCase("admFP")) evt = " ";
	else if (fp.equalsIgnoreCase("liq_recl") || fp.equals("rpt_elegibles") || fp.equals("hist_comision") || fp.equals("hist_reclamo")) evt = " onClick=\"javascript:setPaciente('0',"+i+")\" style=\"text-decoration:none; cursor:pointer\"";
	else evt = " onClick=\"javascript:savePaciente("+i+")\" style=\"text-decoration:none; cursor:pointer\"";
%>
		<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
		<%=fb.hidden("fechaNacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("pasaporte"+i,cdo.getColValue("pasaporte"))%>
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
		<%=fb.hidden("dCedula"+i,cdo.getColValue("d_cedula"))%>
		<%=fb.hidden("pacId"+i,cdo.getColValue("pac_id"))%>
		<%=fb.hidden("nombrePaciente"+i,cdo.getColValue("nombrePaciente"))%>
		<%=fb.hidden("vip"+i,cdo.getColValue("vip"))%>
		<%=fb.hidden("cedulaPasaporte"+i,cdo.getColValue("cedulaPasaporte"))%>
		<%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
		<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
		<%=fb.hidden("residencia_direccion"+i,cdo.getColValue("residencia_direccion"))%>
		<%=fb.hidden("poliza"+i,cdo.getColValue("poliza"))%>
		<%=fb.hidden("no_contrato"+i,cdo.getColValue("no_contrato"))%>
		<%if(fp.equals("hist_reclamo") || fp.equals("hist_comision")){%>
		<%=fb.hidden("rpt_no_contrato"+i, cdo.getColValue("poliza"))%>
		<%} else {%>
		<%=fb.hidden("rpt_no_contrato"+i, cdo.getColValue("poliza")+"-"+cdo.getColValue("no_contrato"," "))%>
		<%}%>
		<%=fb.hidden("fecha_ini_plan"+i,cdo.getColValue("fecha_ini_plan"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td <%=evt%> align="center"><%=cdo.getColValue("fecha_nacimiento")%></td>
			<td <%=evt%> align="center"><%=fp.equals("liq_recl")|| fp.equals("rpt_elegibles")?cdo.getColValue("poliza")+" - "+cdo.getColValue("no_contrato"," "):cdo.getColValue("codigo")%></td>
			<td <%=evt%>><%=cdo.getColValue("cedulaPasaporte")%></td>
			<td <%=evt%> align="center"><%=cdo.getColValue("pac_id")%></td>
			<td <%=evt%>><%=cdo.getColValue("nombrePaciente")%></td>
			<td <%=evt%> align="center"><%=(cdo.getColValue("sexo").equalsIgnoreCase("F"))?"FEMENINO":"MASCULINO"%></td>
			<td <%=evt%> align="center"><%=cdo.getColValue("estado_desc")%></td>
			<%if(fp.equals("admision")||fp.equals("hist_comision")||fp.equals("hist_reclamo")){%>
			<td <%=evt%>><%=cdo.getColValue("contrato")%></td>
			<%}%>
			<td align="center">
			<%if(fp.equals("merge")){%>
			<%if (vPac.contains(cdo.getColValue("pac_id"))){%>
			  <cellbytelabel>elegido</cellbytelabel>
			  <%} else {%>
			  <%=fb.checkbox("chk"+i,""+i,false, false, "", "", "")%>
			  <%}%>
			</td>
			<%}else{%>
			<td align="center"><% if (isFpEnabled && fp.equalsIgnoreCase("admFP")) { %><% if (cdo.getColValue("fpSession").equals("0")) { %><img width="16" height="16" src="../images/blank.gif"><% } else if (cdo.getColValue("fpOwner").equals("0")) { %><a href="javascript:saveFP('<%=cdo.getColValue("pac_id")%>');"><img width="16" height="16" src="../images/fingerprint-gray.png"></a><% } else { %><a href="javascript:saveFP('<%=cdo.getColValue("pac_id")%>');"><img width="16" height="16" src="../images/fingerprint-green.png"></a><% } %><% } %><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("pac_id")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
			<%}%>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
		</table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("estado",estado)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("cedulaPasaporte",cedulaPasaporte)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("contrato",contrato)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("estado",estado)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
else
{
	System.out.println("=====================POST=====================");
	String artDel = "", key = "";;	
	int keySize = Integer.parseInt(request.getParameter("keySize")), lineNo = htPac.size();
	for(int i=0;i<keySize;i++){
		if(request.getParameter("chk"+i)!=null){
			CommonDataObject cdo = new CommonDataObject(); 
			cdo.addColValue("pac_id",request.getParameter("pacId"+i));
			cdo.addColValue("nombre_paciente",request.getParameter("nombrePaciente"+i));
			cdo.addColValue("sexo",request.getParameter("sexo"+i));
			cdo.addColValue("edad",request.getParameter("edad"+i));
			cdo.addColValue("fecha_nacimiento",request.getParameter("fechaNacimiento"+i));
			cdo.addColValue("id_paciente",request.getParameter("cedulaPasaporte"+i));
			cdo.addColValue("is_saved","N");
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
	
			try {
				htPac.put(key, cdo);
				vPac.add(cdo.getColValue("pac_id"));
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
			
		}
	}
	
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/search_paciente.jsp?change=1&type=1&fp="+fp+"&pac_id="+pac_id);
		return;
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("merge")){%>
	window.opener.location = '<%=request.getContextPath()+"/admision/merge_paciente_det.jsp?change=1&fp="+fp%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
	
}//POST
%>