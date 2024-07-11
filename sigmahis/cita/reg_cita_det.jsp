<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Cita"%>
<%@ page import="issi.admision.CitaProcedimiento"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CitasMgr" scope="page" class="issi.admision.CitaMgr" />
<jsp:useBean id="iProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProc" scope="session" class="java.util.Vector" />
<%
/**
===============================================================================
FP            FORMA         MENU                                          NOMBRE EN FORMA
              CDC100100     CITAS\TRANSACCIONES\CRONOGRAMA DE QUIROFANOS  SALON DE OPERACIONES PROGRAMA QUIRURGICO
imagenologia  cdc100200_v2  CITAS\TRANSACCIONES\PROG. CITAS IMAG. V2
Cuando se edita llama a la forma CDC100010
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CitasMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alTipo = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cdc_tipo_cirugia order by 1",CommonDataObject.class);
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String change = request.getParameter("change");
String type = request.getParameter("type");
String citasSopAdm = request.getParameter("citasSopAdm");
String citasAmb = request.getParameter("citasAmb");
int procLastLineNo = 0;

if (mode == null) mode = "add";
boolean viewMode = false;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (fp == null) fp = "";
if (citasSopAdm == null) citasSopAdm = "";
if (citasAmb == null) citasAmb = "";
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
<%
if (type != null && type.equals("1"))
{
	if(fp.equals("imagenologia")){
%>
	abrir_ventana1('../common/check_procedimiento.jsp?fp=citas<%=fp%>&mode=<%=mode%>&procLastLineNo=<%=procLastLineNo%>&cds='+parent.document.form0.habCds.value+'&citasAmb=<%=citasAmb%>');
<%
	} else {
%>
	abrir_ventana1('../common/check_procedimiento.jsp?fp=citas<%=fp%>&mode=<%=mode%>&procLastLineNo=<%=procLastLineNo%>&cds='+parent.document.form0.cds.value+'&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>');
<%
	}
}
%>
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function doSubmit()
{
	document.form1.baction.value=parent.document.form0.baction.value;
	document.form1.saveOption.value=parent.document.form0.saveOption.value;
	if(parent.form0Validation())
		if(form1Validation())
		{
			document.form1.cds.value=parent.document.form0.cds.value;
			document.form1.habCds.value=parent.document.form0.habCds.value;
			document.form1.fechaCita.value=parent.document.form0.fechaCita.value;
			//document.form1.medico.value=parent.document.form0.medico.value;
			if(parent.document.form0.persona_reserva)document.form1.persona_reserva.value=parent.document.form0.persona_reserva.value;
			document.form1.forma_reserva.value=parent.document.form0.forma_reserva.value;
			document.form1.cita_cirugia.value=parent.document.form0.cita_cirugia.value;
			
			if(parent.document.form0.pacId)document.form1.pacId.value=parent.document.form0.pacId.value;
            <%if((citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")){%>
			if(parent.document.form0.noAdmision)document.form1.noAdmision.value=parent.document.form0.noAdmision.value;
            <%}%>
            
			document.form1.nombre_paciente.value=parent.document.form0.nombre_paciente.value;
			
			if(parent.document.form0.medico)document.form1.medico.value=parent.document.form0.medico.value;
			document.form1.nombre_medico.value=parent.document.form0.nombre_medico.value;
			
			if(parent.document.form0.provincia)document.form1.provincia.value=parent.document.form0.provincia.value;
			if(parent.document.form0.sigla)document.form1.sigla.value=parent.document.form0.sigla.value;
			if(parent.document.form0.tomo)document.form1.tomo.value=parent.document.form0.tomo.value;
			if(parent.document.form0.asiento)document.form1.asiento.value=parent.document.form0.asiento.value;
			if(parent.document.form0.d_cedula)document.form1.d_cedula.value=parent.document.form0.d_cedula.value;
			if(parent.document.form0.fec_nacimiento)if(parent.document.form0.fec_nacimiento.value!='')document.form1.fec_nacimiento.value=parent.document.form0.fec_nacimiento.value;else document.form1.fec_nacimiento.value=parent.document.form0.f_nac.value;
			
			
			
			if(parent.document.form0.cod_paciente)document.form1.cod_paciente.value=parent.document.form0.cod_paciente.value;
			if(parent.document.form0.pasaporte)document.form1.pasaporte.value=parent.document.form0.pasaporte.value;
			document.form1.hora_cita.value=parent.document.form0.hora_cita.value;
			document.form1.empresa.value=parent.document.form0.empresa.value;
			if(parent.document.form0.persona_q_llamo)document.form1.persona_q_llamo.value=parent.document.form0.persona_q_llamo.value;
			document.form1.observacion.value=parent.document.form0.observacion.value;
			if(parent.document.form0.habitacion)document.form1.habitacion.value=parent.document.form0.habitacion.value;
			//document.form1.cuarto.value=parent.document.form0.cuarto.value;
			if(parent.document.form0.cod_tipo)document.form1.cod_tipo.value=parent.document.form0.cod_tipo.value;
			if(parent.document.form0.segunda_opinion_aprobada)document.form1.segunda_opinion_aprobada.value=parent.document.form0.segunda_opinion_aprobada.value;
			if(parent.document.form0.anestesia)document.form1.anestesia.value=parent.document.form0.anestesia.value;
			if(parent.document.form0.anestesiologo)document.form1.anestesiologo.value=parent.document.form0.anestesiologo.value;
			if(parent.document.form0.hosp_amb)document.form1.hosp_amb.value=parent.document.form0.hosp_amb.value;
			if(parent.document.form0.probable_hospitalizacion && parent.document.form0.probable_hospitalizacion.checked) document.form1.probable_hospitalizacion.value='S';
			else document.form1.probable_hospitalizacion.value = 'N';
			if(parent.document.form0.sociedad && parent.document.form0.sociedad.checked) document.form1.sociedad.value='S';
			else document.form1.sociedad.value = 'N';
			document.form1.hora_est.value=parent.document.form0.hora_est.value;
			document.form1.min_est.value=parent.document.form0.min_est.value;
			if(parent.document.form0.telefono)document.form1.telefono.value=parent.document.form0.telefono.value;
			if(parent.document.form0.tipo_paciente)document.form1.tipo_paciente.value=parent.document.form0.tipo_paciente.value;
			if(parent.document.form0.nombre_medico_externo) document.form1.nombre_medico_externo.value = parent.document.form0.nombre_medico_externo.value;
			document.form1.submit();
		}
		else parent.form0BlockButtons(false);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cds","")%>
<%=fb.hidden("habCds","")%>
<%=fb.hidden("fechaCita","")%>
<%=fb.hidden("size",""+iProc.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("medico","")%>
<%=fb.hidden("persona_reserva","")%>
<%=fb.hidden("forma_reserva","")%>
<%=fb.hidden("cita_cirugia","")%>
<%=fb.hidden("pacId","")%>
<%=fb.hidden("nombre_paciente","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("d_cedula","")%>
<%=fb.hidden("fec_nacimiento","")%>
<%=fb.hidden("cod_paciente","")%>
<%=fb.hidden("pasaporte","")%>
<%=fb.hidden("hora_cita","")%>
<%=fb.hidden("empresa","")%>
<%=fb.hidden("persona_q_llamo","")%>
<%=fb.hidden("observacion","")%>
<%=fb.hidden("habitacion","")%>
<%=fb.hidden("cuarto","")%>
<%=fb.hidden("cod_tipo","")%>
<%=fb.hidden("segunda_opinion_aprobada","")%>
<%=fb.hidden("anestesia","")%>
<%=fb.hidden("anestesiologo","")%>
<%=fb.hidden("hosp_amb","")%>
<%=fb.hidden("probable_hospitalizacion","")%>
<%=fb.hidden("hora_est","")%>
<%=fb.hidden("min_est","")%>
<%=fb.hidden("telefono","")%>
<%=fb.hidden("tipo_paciente","")%>
<%=fb.hidden("nombre_medico","")%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("nombre_medico_externo","")%>
<%=fb.hidden("citasSopAdm",citasSopAdm)%>
<%=fb.hidden("citasAmb",citasAmb)%>
<%=fb.hidden("sociedad","")%>
<%if((citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")){%>
<%=fb.hidden("noAdmision","")%>
<%}%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td width="27%" rowspan="2"><cellbytelabel>Especialidad</cellbytelabel></td>
	<td width="70%" colspan="3"><cellbytelabel>Procedimiento</cellbytelabel></td>
	<td width="3%" rowspan="2"><%=fb.submit("addCargos","+",true,viewMode,"Text10","","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value);\"","Agregar Procedimiento")%></td>
</tr>
<tr class="TextHeader" align="center">
	<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
	<td width="45%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="10%"><cellbytelabel>Prioridad</cellbytelabel></td>
</tr>
<%
if (iProc.size() > 0) al = CmnMgr.reverseRecords(iProc);
for (int i=1; i<=iProc.size(); i++)
{
	key = al.get(i - 1).toString();
	CitaProcedimiento ad = (CitaProcedimiento) iProc.get(key);
	String color = "TextRow02";
	if (i%2 == 0) color = "TextRow01";
	String display = "";
	if (ad.getStatus() != null && ad.getStatus().equalsIgnoreCase("D")) display = " style=\"display:none\"";
%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,ad.getStatus())%>
<%=fb.hidden("key"+i,ad.getKey())%>
<%=fb.hidden("codigo"+i,ad.getCodigo())%>
<%=fb.hidden("procedimiento"+i,ad.getProcedimiento())%>
<%=fb.hidden("procedimiento_desc"+i,ad.getProcedimientoDesc())%>
<tr class="<%=color%>" align="center"<%=display%>>
	<td><%=fb.select("tipo_c"+i,alTipo,ad.getTipoC(),false,viewMode,0,"Text10","","",null,fp.equalsIgnoreCase("imagenologia")?" ":"")%></td>
	<td><%=ad.getProcedimiento()%></td>
	<td align="left"><%=ad.getProcedimientoDesc()%></td>
	<td align="left"><%=fb.intBox("prioridad"+i,ad.getPrioridad(),true,false,viewMode,2,2)%></td>
	<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Procedimiento")%></td>
</tr>
<%
}
%>
</table>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&"+vProc.size()+"==0){top.CBMSG.warning('Por favor agregue por lo menos un procedimiento!');error++}");%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	Cita cita = new Cita();
	cita.setFechaCita(request.getParameter("fechaCita"));
	cita.setHoraCita(request.getParameter("hora_cita"));
	cita.setHoraLlamada("sysdate");
	cita.setCodTipo(request.getParameter("cod_tipo"));
	cita.setCentroServicio(request.getParameter("cds"));
	if((citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")){
      cita.setEstadoCita("E");
      cita.setXtra1("ASOCIAR");
    }
    else cita.setEstadoCita("R");
	cita.setPersonaReserva(request.getParameter("persona_reserva"));//q
	cita.setFormaReserva(request.getParameter("forma_reserva"));
	if (fp.equalsIgnoreCase("imagenologia")) cita.setAnestesia("N");//i
	else cita.setAnestesia(request.getParameter("anestesia"));//q
	cita.setObservacion(request.getParameter("observacion"));
	cita.setHabitacion(request.getParameter("habitacion"));
	cita.setCompaniaHab((String) session.getAttribute("_companyId"));//q=1
	cita.setEmpresa(request.getParameter("empresa"));
	cita.setUsuarioCreacion((String) session.getAttribute("_userName"));
	cita.setFechaCreacion("sysdate");
	cita.setUsuarioModif((String) session.getAttribute("_userName"));
	cita.setFechaModif("sysdate");
	cita.setHoraEst(request.getParameter("hora_est"));
	cita.setMinEst(request.getParameter("min_est"));
	cita.setNombrePaciente(request.getParameter("nombre_paciente"));
	cita.setCitaCirugia(request.getParameter("cita_cirugia"));
	cita.setHospAmb(request.getParameter("hosp_amb"));//q
	cita.setCompania((String) session.getAttribute("_companyId"));
	cita.setCodMedico(request.getParameter("medico"));//q
	cita.setMedicoNombre(request.getParameter("nombre_medico"));//q

	cita.setCuarto(request.getParameter("cuarto"));
	cita.setSegundaOpinionAprobada(request.getParameter("segunda_opinion_aprobada"));//q
	cita.setFecNacimiento(request.getParameter("fec_nacimiento"));
	cita.setCodPaciente(request.getParameter("cod_paciente"));
	cita.setPacId(request.getParameter("pacId"));
    
    //cita.setPacId("AAAAAA"+request.getParameter("noAdmision"));
    
    if ((citasSopAdm.equals("Y") || citasSopAdm.equals("S"))||citasAmb.equals("S")) {
      cita.setAdmision(request.getParameter("noAdmision"));
    }
    
	cita.setProvincia(request.getParameter("provincia"));//q
	cita.setSigla(request.getParameter("sigla"));//q
	cita.setTomo(request.getParameter("tomo"));//q
	cita.setAsiento(request.getParameter("asiento"));//q
	cita.setDCedula(request.getParameter("d_cedula"));//q
	cita.setPasaporte(request.getParameter("pasaporte"));//q
	cita.setPersonaQLlamo(request.getParameter("persona_q_llamo"));//q
	cita.setProbableHospitalizacion(request.getParameter("probable_hospitalizacion"));//q
	cita.setTipoPaciente(request.getParameter("tipo_paciente"));//i
	cita.setTelefono(request.getParameter("telefono"));//i
	cita.setXtra2(request.getParameter("sociedad"));
	cita.setAnestesiologo(request.getParameter("anestesiologo"));
	if(request.getParameter("nombre_medico_externo")!=null && !request.getParameter("nombre_medico_externo").equals("")) cita.setNombreMedExterno(request.getParameter("nombre_medico_externo"));

	String itemRemoved = "";
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=1; i<=size; i++)
	{
		CitaProcedimiento det = new CitaProcedimiento();

		det.setStatus(request.getParameter("status"+i));
		det.setKey(request.getParameter("key"+i));
		det.setTipoC(request.getParameter("tipo_c"+i));
		det.setCodigo(request.getParameter("codigo"+i));
		det.setProcedimiento(request.getParameter("procedimiento"+i));
		det.setProcedimientoDesc(request.getParameter("procedimiento_desc"+i));
		det.setUsuarioCreacion((String) session.getAttribute("_userName"));
		det.setFechaCreacion("sysdate");
		det.setUsuarioModif((String) session.getAttribute("_userName"));
		det.setFechaModif("sysdate");
		det.setPrioridad(request.getParameter("prioridad"+i));
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = det.getKey();
			det.setStatus("D");
			vProc.remove(det.getProcedimiento());
		}

		try
		{
			iProc.put(det.getKey(),det);
			cita.addCitaProcedimiento(det);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&change=1&type=2&procLastLineNo="+procLastLineNo+"&citasSopAdm="+citasSopAdm+"&citasAmb="+citasAmb);
		return;
	}

	if (baction != null && baction.equals("+"))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&change=1&type=1&procLastLineNo="+procLastLineNo+"&citasSopAdm="+citasSopAdm+"&citasAmb="+citasAmb);
		return;
	}
	else if (baction != null && baction.equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fp="+fp+"&citasSopAdm="+citasSopAdm+"&citasAmb="+citasAmb);
		CitasMgr.add(cita);
		ConMgr.clearAppCtx(null);
        
        iProc.clear();
        vProc.clear();
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%if (CitasMgr.getErrCode().equals("1")){%>
	parent.document.form0.errCode.value = <%=CitasMgr.getErrCode()%>;
	parent.document.form0.errMsg.value = '<%=CitasMgr.getErrMsg()%>';
	parent.document.form0.submit();
<%} else throw new Exception(CitasMgr.getErrException());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>