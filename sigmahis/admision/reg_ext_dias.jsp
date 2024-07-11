<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Extension"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr" />
<jsp:useBean id="ExtDet" scope="session" class="issi.admision.Extension" />

<br>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
//Extension ExtDet = new Extension();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String pacienteId = request.getParameter("pacienteId");
String admisionNo = request.getParameter("admisionNo");
String change = request.getParameter("change");
String codigo = request.getParameter("codigo");

String fg = request.getParameter("fg");
if(fg==null) fg = "extension_dias";
String fp = request.getParameter("fp");
if(fp==null) fp = "extension_dias";
if(codigo==null) codigo = "0";

String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
boolean viewMode = false;

if (mode == null) mode = "add";
if (mode.equals("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET")){
  
    
  if (mode.equalsIgnoreCase("add")){
    if(change==null){
      if (request.getParameter("pacienteId")==null || request.getParameter("pacienteId").trim().equals("")) pacienteId = "0";
      if (request.getParameter("admisionNo")==null || request.getParameter("admisionNo").trim().equals("")) admisionNo = "0";
      ExtDet = new Extension();
      session.setAttribute("ExtDet",ExtDet);
	  if(codigo.trim().equals("0"))
	  codigo = ""+CmnMgr.getCount("select nvl(max(codigo),0) from tbl_sal_extension where pac_id="+pacienteId+" and secuencia="+admisionNo+" ");
	  
      ExtDet.setPacId(pacienteId);
      ExtDet.setSecuencia(admisionNo);
      ExtDet.setCodigo(codigo);
	  
	  
    }
  } 
  if(!codigo.trim().equals("00") && !codigo.trim().equals("0"))
  {
  
    if (pacienteId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
    if (admisionNo == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");


    sql = "select codigo, cod_paciente codPaciente, to_char(fec_nacimiento,'dd/mm/yyyy') fecNacimiento, secuencia, to_char(fecha_solicitud,'dd/mm/yyyy') fechaSolicitud, dias_solicitados diasSolicitados, motivo, estado_extension extadoExtension, aseguradora, pac_id pacId, nvl(to_char(fecha_aprobacion, 'dd/mm/yyyy'), ' ') fechaAprobacion, nvl(to_char(dias_aprobados), '') diasAprobados, nvl(to_char(emp_provincia), ' ') empProvincia, nvl(emp_sigla,' ') empSigla, nvl(to_char(emp_tomo), ' ') empTomo, nvl(to_char(emp_asiento), ' ') empAsiento, nvl(to_char(emp_compania), ' ') empCompania, nvl(num_aprobacion, ' ') numAprobacion, nvl(observacion, ' ') observacion, nvl(identificacion, ' ') identificacion, nvl(to_char(fecha_creacion,'dd/mm/yyyy'), ' ') fechaCreacion, nvl(usuario_creacion, ' ') usuarioCreacion, nvl(to_char(fecha_modificacion,'dd/mm/yyyy'), ' ') fechaModificacion, nvl(usuario_modificacion, ' ') usuario_modificacion from tbl_sal_extension where pac_id = " + pacienteId + " and secuencia = "+admisionNo+" and codigo = " + codigo;
    System.out.println("SQL:\n"+sql);
    ExtDet = (Extension) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Extension.class);
	if (!viewMode) mode ="edit";

  }
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Extensión - '+document.title;

function removeItem(fName,k){
  var rem = eval('document.'+fName+'.rem'+k).value;
  eval('document.'+fName+'.remove'+k).value = rem;
  setBAction(fName,rem);
}

function setBAction(fName,actionValue){
  document.form0.baction.value = actionValue;
  doSubmit();
}

function doAction()
{
  if('<%=mode%>'=='view')
	{
		var empresa = '';
		if(document.form0.empresa0) empresa = document.form0.empresa0.value;
		var facturar_a = getDBData('<%=request.getContextPath()%>','facturar_a','tbl_fac_factura','pac_id=<%=pacienteId%> and admi_secuencia=<%=admisionNo%>','');
    if(facturar_a != null) abrir_ventana1('../facturacion/print_factura.jsp?noSecuencia=<%=admisionNo%>&pacId=<%=pacienteId%>&empresa='+empresa);
  }
}

function doSubmit(){

  document.form0.nombrePaciente.value     = document.paciente.nombrePaciente.value;
  document.form0.fechaNacimiento.value    = document.paciente.fechaNacimiento.value;
  document.form0.codigoPaciente.value     = document.paciente.codigoPaciente.value;
  document.form0.pacienteId.value         = document.paciente.pacienteId.value;
  document.form0.categoria.value          = document.paciente.categoria.value;
  document.form0.admSecuencia.value       = document.paciente.admSecuencia.value;
  document.form0.estado.value             = document.paciente.estado.value;
  document.form0.empresa.value            = document.paciente.empresa.value;
  document.form0.clasificacion.value      = document.paciente.clasificacion.value;


  if (!pacienteValidation() || !form0Validation()){
		pacienteBlockButtons(false);
		form0BlockButtons(false);
    //return false;
  } else if(document.form0.aseguradora.value == ''){
		CBMSG.warning('Es necesario la Aseguradora!');
		pacienteBlockButtons(false);
		form0BlockButtons(false);
  } else if(document.form0.fecha_solicitud.value == ''){
		CBMSG.warning('Introduzca Fecha de Solicitud!');
		pacienteBlockButtons(false);
		form0BlockButtons(false);
	} else{
    //return true;
    if(document.form0.baction.value != 'Guardar'){
			pacienteBlockButtons(false);
			form0BlockButtons(false);
		}
    document.form0.submit();
  }
  
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="DIAS ESTIMADOS Y EXTENSION DE DIAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
  <td class="TableBorder">
    <table align="center" width="100%" cellpadding="5" cellspacing="0">
    <tr>
      <td>
        <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextRow02">
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
            <table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">&nbsp;Generales del Paciente y Admisi&oacute;n</td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
            </tr>
            </table>
          </td>
        </tr>
        <tr id="panel0">
          <td>
            <jsp:include page="../common/paciente.jsp" flush="true">
              <jsp:param name="pacienteId" value="<%=pacienteId%>"></jsp:param>
              <jsp:param name="fp" value="<%=fp%>"></jsp:param>
              <jsp:param name="tr" value="<%=fg%>"></jsp:param>
              <jsp:param name="mode" value="<%=mode%>"></jsp:param>
              <jsp:param name="admisionNo" value="<%=ExtDet.getSecuencia()%>"></jsp:param>
            </jsp:include>
          </td>
        </tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>

<%=fb.hidden("nombrePaciente","")%>
<%=fb.hidden("fechaNacimiento","")%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("categoria","")%>
<%=fb.hidden("admSecuencia",admisionNo)%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("empresa","")%>
<%=fb.hidden("clasificacion","")%>
        <tr>
          <td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
            <table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">Generales de la Solicitud de Extensi&oacute;n de d&iacute;as</td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
            </tr>
            </table>
          </td>
        </tr>
        <tr id="panel1">
          <td>
            <table width="100%" cellpadding="1" cellspacing="1">
            <tr class="TextRow01">
            	<td align="right">
              	C&iacute;a. de Seguros
              </td>
              <td colspan="4">
              	<%
								sql = "select a.codigo, a.nombre descripcion from tbl_adm_empresa a, tbl_adm_beneficios_x_admision b where a.tipo_empresa = 2 and a.codigo = b.empresa and b.pac_id = "+pacienteId+" and b.admision = " + admisionNo;
								%>
								<%=fb.select(ConMgr.getConnection(),sql,"aseguradora",ExtDet.getAseguradora())%>
                </td>
            </tr>
            <tr class="TextRow01">
            	<td align="right">Solicitud No.</td>
              <td><%=fb.intBox("codigo",ExtDet.getCodigo(), false, false, true, 10, "", "", "")%></td>
            	<td align="right">Fecha Solicitud</td>
              <td width="20%">
                <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="nameOfTBox1" value="fecha_solicitud" />
                  <jsp:param name="valueOfTBox1" value="<%=fecha%>" />
                </jsp:include>
              </td>
              <td>
	              <%=fb.radio("identificacion","P", (ExtDet.getIdentificacion().equals("P")?true:false), false, viewMode, "", "", "")%>Pre-Autorizacin
              </td>
            </tr>
            <tr class="TextRow01">
            	<td align="right">D&iacute;as Solicitados</td>
              <td><%=fb.intBox("dias_solicitados",ExtDet.getDiasSolicitados(), true, false, false, 10, "", "", "")%></td>
            	<td align="right">Estado documento</td>
              <td width="20%"><%=fb.select("estado_extension","T=TRAMITE,P=PENDIENTE,A=APROBADO,D=NO APROBADO",ExtDet.getEstadoExtension())%>
              </td>
              <td>
	              <%=fb.radio("identificacion","E", (ExtDet.getIdentificacion().equals("E")?true:false), false, viewMode, "", "", "")%>Extensi&oacute;n
              </td>
            </tr>
            <tr class="TextRow01">
              <td align="right">Motivo</td>
              <td colspan="4"><%=fb.textarea("motivo",ExtDet.getMotivo(),true,false,false,50,4, 2000)%></td>
            </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
            <table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">Respuesta de la C&iacute;a. de Seguro</td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
            </tr>
            </table>
          </td>
        </tr>
        <tr id="panel2">
          <td>
            <table width="100%" cellpadding="1" cellspacing="1">
            <tr class="TextRow01">
            	<td align="right">Fecha Aprobaci&oacute;n</td>
              <td width="20%">
                <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />
                  <jsp:param name="nameOfTBox1" value="fecha_aprobacion" />
                  <jsp:param name="valueOfTBox1" value="<%=ExtDet.getFechaAprobacion()%>" />
                </jsp:include>
              </td>
            	<td align="right">D&iacute;as Aprobados</td>
              <td><%=fb.intBox("dias_aprobados",ExtDet.getDiasAprobados(), false, false, false, 10, "", "", "")%></td>
              <td>No. Aprobaci&oacute;n</td>
              <td><%=fb.intBox("num_aprobacion",ExtDet.getNumAprobacion(), false, false, false, 10, "", "", "")%></td>
            </tr>
            <tr class="TextRow01">
              <td align="right">Observaci&oacute;n</td>
              <td colspan="5"><%=fb.textarea("observacion",ExtDet.getObservacion(),false,false,false,50,4, 2000)%></td>
            </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
            <table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">Usuario Creaci&oacute;n/Modificaci&oacute;n</td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
            </tr>
            </table>
          </td>
        </tr>
        <tr id="panel3">
          <td class="TextRow01">
            <table width="100%" cellpadding="1" cellspacing="1">
              <tr class="TextRow01">
                <td align="right">Usuario Creaci&oacute;n:</td>
                <td><%=(ExtDet.getUsuarioCreacion().equals(""))?session.getAttribute("_userName"):ExtDet.getUsuarioCreacion()%>&nbsp;&nbsp;&nbsp;<%=(ExtDet.getFechaCreacion().equals(""))?fecha:ExtDet.getFechaCreacion()%></td>
                <td align="right">Usuario Modificaci&oacute;n:</td>
                <td><%=session.getAttribute("_userName")%>&nbsp;&nbsp;&nbsp;<%=fecha%></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr class="TextRow02">
          <td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro 
						<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar 
            <%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

        </table>
      </td>
    </tr>
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

  ExtDet.setCodPaciente(request.getParameter("codigoPaciente"));
  ExtDet.setFecNacimiento(request.getParameter("fechaNacimiento"));
  ExtDet.setSecuencia(request.getParameter("admSecuencia"));
  ExtDet.setFechaSolicitud(request.getParameter("fecha_solicitud"));
  ExtDet.setDiasSolicitados(request.getParameter("dias_solicitados"));
  ExtDet.setMotivo(request.getParameter("motivo"));
  ExtDet.setEstadoExtension(request.getParameter("estado_extension"));
  ExtDet.setAseguradora(request.getParameter("aseguradora"));
  ExtDet.setPacId(request.getParameter("pacienteId"));
  ExtDet.setUsuarioCreacion((String) session.getAttribute("_userName"));
	
  if(request.getParameter("fecha_aprobacion")!=null && !request.getParameter("fecha_aprobacion").equals("null") && !request.getParameter("fecha_aprobacion").equals("")) ExtDet.setFechaAprobacion(request.getParameter("fecha_aprobacion"));
  
	if(request.getParameter("dias_aprobados")!=null && !request.getParameter("dias_aprobados").equals("null") && !request.getParameter("dias_aprobados").equals("")) ExtDet.setDiasAprobados(request.getParameter("dias_aprobados"));
  
	if(request.getParameter("emp_provincia")!=null && !request.getParameter("emp_provincia").equals("null") && !request.getParameter("emp_provincia").equals("")) ExtDet.setEmpProvincia(request.getParameter("emp_provincia"));
  
	if(request.getParameter("emp_sigla")!=null && !request.getParameter("emp_sigla").equals("null") && !request.getParameter("emp_sigla").equals("")) ExtDet.setEmpSigla(request.getParameter("emp_sigla"));
  
	if(request.getParameter("emp_tomo")!=null && !request.getParameter("emp_tomo").equals("null") && !request.getParameter("emp_tomo").equals("")) ExtDet.setEmpTomo(request.getParameter("emp_tomo"));
  
	if(request.getParameter("emp_asiento")!=null && !request.getParameter("emp_asiento").equals("null") && !request.getParameter("emp_asiento").equals("")) ExtDet.setEmpAsiento(request.getParameter("emp_asiento"));
	
	if(request.getParameter("emp_compania")!=null && !request.getParameter("emp_compania").equals("null") && !request.getParameter("emp_compania").equals("")) ExtDet.setEmpCompania(request.getParameter("emp_compania"));
	
	if(request.getParameter("num_aprobacion")!=null && !request.getParameter("num_aprobacion").equals("null") && !request.getParameter("num_aprobacion").equals("")) ExtDet.setNumAprobacion(request.getParameter("num_aprobacion"));
	
	if(request.getParameter("observacion")!=null && !request.getParameter("observacion").equals("null") && !request.getParameter("observacion").equals("")) ExtDet.setObservacion(request.getParameter("observacion"));
	
	if(request.getParameter("identificacion")!=null && !request.getParameter("identificacion").equals("null") && !request.getParameter("identificacion").equals("")) ExtDet.setIdentificacion(request.getParameter("identificacion"));

  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
//	String codigo = "0";
  if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
  {
	  if(mode.trim().equals("add"))
	  {
		codigo = AdmMgr.addExtension(ExtDet);
		session.removeAttribute("ExtDet");
	  }
	  else 
	  {
		AdmMgr.updateExtension(ExtDet);
		session.removeAttribute("ExtDet");
	  }
  }
	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (AdmMgr.getErrCode().equals("1")){
%>
  alert('<%=AdmMgr.getErrMsg()%>');
<%
	if (saveOption.equalsIgnoreCase("N")){
%>
  setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("O")){
%>
  setTimeout('viewMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}
} else throw new Exception(AdmMgr.getErrMsg());
%>
}

function addMode(){
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=<%=fg%>&mode=add&pacienteId=<%=pacienteId%>&admisionNo=<%=ExtDet.getSecuencia()%>&change=1';
}

function viewMode(){
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&fg=<%=fg%>&mode=view&pacienteId=<%=pacienteId%>&admisionNo=<%=ExtDet.getSecuencia()%>&change=1&codigo=<%=codigo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>