<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.CdsSolicitud"%>
<%@ page import="issi.admision.CdsSolicitudDetalle"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="CSolMgr" scope="page" class="issi.admision.CdsSolicitudMgr"/>
<jsp:useBean id="iProce" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vProce" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================
cds400019_copia	- cds_solicitud_rayx_lab_ped	- Solicitud de Servicio Ambulatoria de Rayos X y Lab. Pediatrico
cds400016_copia	- cds_solicitud_lab_ext				- Solicitud de Servicio Ambulatoria de Lab. Externo
cds400015				- cds_solicitud_ima						- Solicitud de Servicio Ambulatoria de Imagenologia
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CSolMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alCds = new ArrayList();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String codigo = request.getParameter("codigo");
String change = request.getParameter("change");
String profileCPT = request.getParameter("profileCPT");
String profileChanged = request.getParameter("profileChanged") == null ? "" : request.getParameter("profileChanged");
String modalize = request.getParameter("modalize") == null ? "" : request.getParameter("modalize");
boolean viewMode = false;
int procLastLineNo = 0;

if (mode == null) mode = "add";
if (profileCPT == null) profileCPT = "";

if(mode.equals("view")) viewMode = true;
if (fp == null) fp = "cds_solicitud_rayx_lab_ped";
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
procLastLineNo=iProce.size();

if (request.getMethod().equalsIgnoreCase("GET"))
{
// where codigo in (14,15)
	alCds = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, lpad(codigo,3,'0')||' - '||descripcion as optLabelColumn from tbl_cds_centro_servicio  order by 1", CommonDataObject.class);

	if((change == null ||change.trim().equals("")) && profileChanged.equals("")){vProce.clear();iProce.clear();}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	//newHeight();
<%
	if (request.getParameter("type") != null)
	{
%>
	showProcedimientoList();
<%
	}
%>
parent.document.form0.nRecs.value=document.form0.validItems.value;
parent.document.form0.total.value=parseFloat(document.form0.total.value).toFixed(2);
}

function showProcedimientoList()
{
	var cds=parent.document.form0.codCentroServicio.value;
	var clasificacion=(parent.document.paciente.empresa.value.trim()=='')?'':parent.document.paciente.clasificacion.value;
	var empresa=parent.document.paciente.empresa.value;
	var pac_id=parent.document.paciente.pacienteId.value;
	var admision=parent.document.paciente.admSecuencia.value;
	var profileCPT='';
	if(parent.document.form0.profile)profileCPT=parent.document.form0.profile.value;
	var cat=parent.document.paciente.categoria.value;
	if(parent.document.paciente.pacienteId.value.trim()=='')top.CBMSG.warning('Por favor seleccione una Admisión!');
<%
if (fp.equalsIgnoreCase("cds_solicitud_ima"))
{
%>
	var cdsReportaA=parent.document.form0.centroServicioReportaA.value;
	var cdsTipo=parent.document.form0.centroServicioTipoCds.value;
	if(cds.trim()==''&&profileCPT=='')top.CBMSG.warning('Por favor seleccione el Origen de la Solicitud!');
	else abrir_ventana1('../common/check_procedimiento.jsp?fp=<%=fp%>&mode=<%=mode%>&modalize=<%=modalize%>&codigo=<%=codigo%>&procLastLineNo=<%=procLastLineNo%>&cds='+cds+'&clasificacion='+clasificacion+'&cdsReportaA='+cdsReportaA+'&cdsTipo='+cdsTipo+'&tipoSolicitud=<%=(request.getParameter("type") != null && request.getParameter("type").trim().equalsIgnoreCase("Proc"))?"P":"Q"%>&empresa='+empresa+'&pac_id='+pac_id+'&admision='+admision+'&profileCPT='+profileCPT+'&categoriaAdm='+cat);
<%
}
else
{
%>
	var cambioPrecio=parent.document.paciente.cambioPrecio.value;
	var descuento=parent.document.paciente.descuento.value;
	var cupon=(parent.document.form0.cupon.checked)?'S':'N';
	if(cds.trim()==''&&profileCPT=='')top.CBMSG.warning('Por favor seleccione el Origen de la Solicitud!');
	else abrir_ventana1('../common/check_procedimiento.jsp?fp=<%=fp%>&mode=<%=mode%>&modalize=<%=modalize%>&codigo=<%=codigo%>&procLastLineNo=<%=procLastLineNo%>&cds='+cds+'&clasificacion='+clasificacion+'&cambioPrecio='+cambioPrecio+'&descuento='+descuento+'&cupon='+cupon+'&empresa='+empresa+'&pac_id='+pac_id+'&admision='+admision+'&profileCPT='+profileCPT+'&categoriaAdm='+cat);
<%
}
%>
}

function doSubmit()
{
	document.form0.baction.value = parent.document.form0.baction.value;
	document.form0.saveOption.value = parent.document.form0.saveOption.value;

	document.form0.pacId.value = parent.document.paciente.pacienteId.value;
	document.form0.noAdmision.value = parent.document.paciente.admSecuencia.value;
	document.form0.admiPacFecNac.value = parent.document.paciente.fechaNacimiento.value;
	document.form0.admiPacCodigo.value = parent.document.paciente.codigoPaciente.value;
	document.form0.primerNombre.value = parent.document.paciente.primerNombre.value;
	document.form0.segundoNombre.value = parent.document.paciente.segundoNombre.value;
	document.form0.primerApellido.value = parent.document.paciente.primerApellido.value;
	document.form0.segundoApellido.value = parent.document.paciente.segundoApellido.value;
	document.form0.apellidoDeCasada.value = parent.document.paciente.apellidoDeCasada.value;
	document.form0.sexo.value = parent.document.paciente.sexo.value;
	document.form0.embarazada.value = parent.document.paciente.embarazada.value;
	document.form0.provincia.value = parent.document.paciente.provincia.value;
	document.form0.sigla.value = parent.document.paciente.sigla.value;
	document.form0.tomo.value = parent.document.paciente.tomo.value;
	document.form0.asiento.value = parent.document.paciente.asiento.value;
	document.form0.dCedula.value = parent.document.paciente.dCedula.value;
	document.form0.pasaporte.value = parent.document.paciente.pasaporte.value;
	document.form0.admCds.value = parent.document.paciente.cdsAtencion.value;
	document.form0.admMedico.value = parent.document.paciente.medico.value;
	document.form0.admMedicoNombres.value = parent.document.paciente.medicoNombres.value;
	document.form0.admMedicoApellidos.value = parent.document.paciente.medicoApellidos.value;
	document.form0.residenciaDireccion.value = parent.document.paciente.residenciaDireccion.value;
	document.form0.telefono.value = parent.document.paciente.telefono.value;
	document.form0.cedulaPasaporte.value = parent.document.paciente.cedulaPasaporte.value;
	document.form0.admCategoria.value = parent.document.paciente.categoria.value;
	document.form0.sala.value = parent.document.paciente.cdsAtencion.value;
	document.form0.cama.value = parent.document.paciente.cama.value;
	document.form0.aseguradora.value = parent.document.paciente.empresa.value;

	document.form0.fechaCargo.value = parent.document.form0.fechaCargo.value;
	document.form0.codCentroServicio.value = parent.document.form0.codCentroServicio.value;
	//document.form0.centroServicioDesc.value = parent.document.form0.centroServicioDesc.value;
	document.form0.cupon.value = parent.document.form0.cupon.value;
	document.form0.medCodigoResp.value = parent.document.form0.medCodigoResp.value;

	if(parent.document.form0.generaArchivo.checked) document.form0.generaArchivo.value = 'S';
	else document.form0.generaArchivo.value = 'N';
	//document.form0.generaArchivo.value = parent.document.form0.generaArchivo.value;
	document.form0.estado.value = parent.document.form0.estado.value;
	document.form0.fechaSolicitud.value = parent.document.form0.fechaSolicitud.value;
	document.form0.nombreCtaMensual.value = parent.document.form0.nombreCtaMensual.value;
	document.form0.identificacionCtaMensual.value = parent.document.form0.identificacionCtaMensual.value;
	if(parent.document.form0.nombre_medico_externo) document.form0.nombre_medico_externo.value = parent.document.form0.nombre_medico_externo.value;
	if(parent.document.form0.profile)document.form0.profileCPT.value = parent.document.form0.profile.value;
	document.form0.onlySol.value=parent.document.form0.onlySol.value;
	document.form0.modalize.value=parent.document.form0.modalize.value;
	if(!parent.pacienteValidation()||!parent.form0Validation())
	{
		//return false;
	}
	else
	{
		//return true;
		if(document.form0.baction.value!='Guardar')parent.form0BlockButtons(false);
		else
		{
			if(parseInt(document.form0.validItems.value,10)==0)
			{
				top.CBMSG.warning('Por favor agregue por lo menos un procedimiento/estudio antes de guardar!');
				parent.form0BlockButtons(false);
			}
			else if(!validateDetail())parent.form0BlockButtons(false);

//			else if(!validaFechas(-1))
//			{
//				top.CBMSG.warning('La fecha del cargo está fuera del rango de la fecha de egreso o egreso... VERIFIQUE');
//				parent.form0BlockButtons(false);
//			}
			else document.form0.submit();
		}
	}
}

function allowChanges()
{
	if(parseInt(document.form0.validItems.value,10)>0)
	{
		top.CBMSG.warning('No se puede cambiar el Centro de Servicio o el uso de Cupón de Descuentos mientras hayan estudios (CPT)!!');
		return false;
	}
	return true;
}
function validateDetail()
{
	var respuesta='N';
	var pacId=document.form0.pacId.value;
	var noAdmision=document.form0.noAdmision.value;
	var categoria = parent.document.paciente.categoria.value;
	var estado =getDBData('<%=request.getContextPath()%>','estado','tbl_adm_admision','pac_id='+pacId+' and secuencia='+noAdmision+' ','');
	var descEstado='';
	if(estado =='I')descEstado=' INACTIVA ';
	else if(estado =='N')descEstado=' ANULADA ';
	if(estado !='I' && estado !='N'){
	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','empresa','tbl_adm_beneficios_x_admision','pac_id='+pacId+' and admision='+noAdmision+' and prioridad=1 and nvl(estado,\'A\')=\'A\'',''));
	if(categoria == 4 || categoria == 3) return true;else{if(r==null){top.CBMSG.warning('La Admisión no tiene beneficio asignado!');return false;}
		else if(r.length>1){top.CBMSG.warning('Se ha detectado que la admisión tiene más de un beneficio con prioridad uno(1), corrija las prioridades...VERIFIQUE!');return false;} else return true;}}else{top.CBMSG.warning('La Admision se encuentra en estado:'+descEstado+' No puede Realizar Cargos !!!');return false;}}

<%if(modalize.equalsIgnoreCase("Y")){%>
function abrir_ventana1(url){
  parent.parent.showPopWin(url, winWidth*.95, winHeight*.85, null, null, '');
}
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>

<%=fb.hidden("size",""+iProce.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>

<%=fb.hidden("pacId","")%>
<%=fb.hidden("noAdmision","")%>
<%=fb.hidden("admiPacFecNac","")%>
<%=fb.hidden("admiPacCodigo","")%>
<%=fb.hidden("primerNombre","")%>
<%=fb.hidden("segundoNombre","")%>
<%=fb.hidden("primerApellido","")%>
<%=fb.hidden("segundoApellido","")%>
<%=fb.hidden("apellidoDeCasada","")%>
<%=fb.hidden("sexo","")%>
<%=fb.hidden("embarazada","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("dCedula","")%>
<%=fb.hidden("pasaporte","")%>
<%=fb.hidden("admCds","")%>
<%=fb.hidden("admMedico","")%>
<%=fb.hidden("admMedicoNombres","")%>
<%=fb.hidden("admMedicoApellidos","")%>
<%=fb.hidden("residenciaDireccion","")%>
<%=fb.hidden("telefono","")%>
<%=fb.hidden("cedulaPasaporte","")%>
<%=fb.hidden("admCategoria","")%>

<%=fb.hidden("fechaCargo","")%>
<%=fb.hidden("codCentroServicio","")%>
<%=fb.hidden("centroServicioDesc","")%>
<%=fb.hidden("cupon","")%>
<%=fb.hidden("medCodigoResp","")%>
<%=fb.hidden("generaArchivo","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("fechaSolicitud","")%>
<%=fb.hidden("nombreCtaMensual","")%>
<%=fb.hidden("identificacionCtaMensual","")%>
<%=fb.hidden("nombre_medico_externo","")%>
<%=fb.hidden("profileCPT",profileCPT)%>
<%=fb.hidden("sala","")%>
<%=fb.hidden("cama","")%>
<%=fb.hidden("aseguradora","")%>
<%=fb.hidden("onlySol","")%>
<%=fb.hidden("modalize", modalize)%>

<%//fb.appendJsValidation("if(document.form0.baction.value=='addProc'&&parent.document.form0.codCentroServicio.value==''){top.CBMSG.warning('Por favor seleccione el Origen de la Solicitud!');parent.showCdsList();error++;}");%>
<table width="100%" align="center">
<!--<tr class="TextRow04 Text12Bold" align="center">
<td colspan="8">Total de CPT's Seleccionados = <%=vProce.size()%></td>
</tr>-->
<tr class="TextHeader" align="center">
	<td width="3%"><cellbytelabel id="1">Nº</cellbytelabel></td>
<%
if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped"))
{
%>
	<td width="13%"><cellbytelabel id="2">&Aacute;rea del CPT</cellbytelabel></td>
	<td width="7%"><cellbytelabel id="3">CPT</cellbytelabel></td>
	<td width="25%"><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
	<td width="6%"><cellbytelabel id="5">Precio</cellbytelabel></td>
	<td width="6%"><cellbytelabel id="6">Recargo</cellbytelabel></td>
	<td width="37%"><cellbytelabel id="7">Observaci&oacute;n</cellbytelabel></td>
	<td width="3%"><%=fb.submit("addProc","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Estudio")%></td>
<%
}
else if (fp.equalsIgnoreCase("cds_solicitud_lab_ext"))
{
%>
	<td width="10%"><cellbytelabel id="3">CPT</cellbytelabel></td>
	<td width="64%"><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="5">Precio</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="6">Recargo</cellbytelabel></td>
	<td width="3%"><%=fb.submit("addProc","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Estudio")%></td>
<%
}
else if (fp.equalsIgnoreCase("cds_solicitud_ima"))
{
%>
	<td width="10%">&Aacute;rea del CPT</td>
	<td width="5%">Tipo Solicitud</td>
	<td width="10%">CPT / Paquete </td>
	<td width="25%"><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="5">Precio</cellbytelabel></td>
	<td width="10%"><cellbytelabel id="6">Recargo</cellbytelabel></td>
	<td width="32%"><cellbytelabel id="7">Observaci&oacute;n</cellbytelabel></td>
	<td width="8%">
		<%//=fb.submit("addPaq","Paq",true,viewMode,"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Paquete")%>
		<%=fb.submit("addProc","Proc",true,viewMode,"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Estudio")%>
	</td>
<%
}
%>
</tr>
<%
if (iProce.size() > 0) al = CmnMgr.reverseRecords(iProce);
int validItems = 0;
double total = 0;
for (int i=1; i<=iProce.size(); i++)
{
	key = al.get(i - 1).toString();
	CdsSolicitudDetalle csd = (CdsSolicitudDetalle) iProce.get(key);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	String setValidDate = "javascript:setValidDate("+i+");newHeight();";
	String displayCPT = "";
	if (csd.getStatus() != null && csd.getStatus().equalsIgnoreCase("D")) displayCPT = " style=\"display:none\"";
	else {
		validItems++;
		total += Double.parseDouble(csd.getPrecio()) + Double.parseDouble(csd.getRecargo());
	}
%>
<%=fb.hidden("key"+i,csd.getKey())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("status"+i,csd.getStatus())%>
<%=fb.hidden("codigo"+i,csd.getCodigo())%>
<%=fb.hidden("tipoSolicit"+i,csd.getTipoSolicit())%>
<%=fb.hidden("codPaq"+i,csd.getCodPaq())%>
<%=fb.hidden("codProcedimiento"+i,csd.getCodProcedimiento())%>
<%=fb.hidden("procedimientoDesc"+i,csd.getProcedimientoDesc())%>
<%=fb.hidden("precio"+i,csd.getPrecio())%>
<%=fb.hidden("oferta"+i,csd.getOferta())%>
<%=fb.hidden("recargo"+i,csd.getRecargo())%>
<%=fb.hidden("cdsProducto"+i,csd.getCdsProducto())%>
<%=fb.hidden("codCentroServicio"+i,csd.getCodCentroServicio())%>
<tr class="<%=color%>" align="center"<%=displayCPT%>>
	<td><%=csd.getCodigo()%></td>
<%
if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped")||fp.equalsIgnoreCase("cds_solicitud_ima"))
{
%>
	<td><%=fb.select("codCentroServicioDisplay"+i,alCds,csd.getCodCentroServicio(),false,true,0,"Text10",null,null,null,"")%></td>
<%
}
 if (fp.equalsIgnoreCase("cds_solicitud_ima"))
{
%>
	<td><%=(csd.getTipoSolicit().trim().equalsIgnoreCase("Q"))?"PAQ":"PROC"%></td>
<%
}
%>
	<td><%=(csd.getTipoSolicit().trim().equalsIgnoreCase("Q"))?csd.getCodPaq():csd.getCodProcedimiento()%></td>
	<td align="left"><%=csd.getProcedimientoDesc()%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(csd.getPrecio())%>&nbsp;</td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(csd.getRecargo())%>&nbsp;</td>
<%
if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_ima"))
{
%>
	<td><%=fb.textarea("comentario"+i,csd.getComentario(),false,false,false,40,2,2000)%></td>
<%
}
%>
	<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Estudio")%></td>
</tr>
	<%
}
%>
</table>
<%=fb.hidden("validItems",""+validItems)%>
<%=fb.hidden("total",""+total)%>
<%//fb.appendJsValidation("\n\tif (!validaFechas(-1))\n\t{\n\t\t\n\t\terror++;\n\t}\n");%>
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

	CdsSolicitud cs = new CdsSolicitud();
	cs.setOnlySol(request.getParameter("onlySol"));
	cs.setFp(request.getParameter("fp"));
	cs.setIp(request.getRemoteHost());
	//admision
	cs.setPacId(request.getParameter("pacId"));
	cs.setAdmiSecuencia(request.getParameter("noAdmision"));
	cs.setAdmiPacFecNac(request.getParameter("admiPacFecNac"));
	cs.setAdmiPacCodigo(request.getParameter("admiPacCodigo"));
	cs.setPrimerNombre(request.getParameter("primerNombre"));
	cs.setSegundoNombre(request.getParameter("segundoNombre"));
	cs.setPrimerApellido(request.getParameter("primerApellido"));
	cs.setSegundoApellido(request.getParameter("segundoApellido"));
	cs.setApellidoDeCasada(request.getParameter("apellidoDeCasada"));
	cs.setSexo(request.getParameter("sexo"));
	cs.setEmbarazada(request.getParameter("embarazada"));
	cs.setProvincia(request.getParameter("provincia"));
	cs.setSigla(request.getParameter("sigla"));
	cs.setTomo(request.getParameter("tomo"));
	cs.setAsiento(request.getParameter("asiento"));
	cs.setDCedula(request.getParameter("dCedula"));
	cs.setPasaporte(request.getParameter("pasaporte"));
	cs.setAdmCds(request.getParameter("admCds"));
	cs.setAdmMedico(request.getParameter("admMedico"));
	cs.setAdmMedicoNombres(request.getParameter("admMedicoNombres"));
	cs.setAdmMedicoApellidos(request.getParameter("admMedicoApellidos"));
	cs.setResidenciaDireccion(request.getParameter("residenciaDireccion"));
	cs.setTelefono(request.getParameter("telefono"));
	cs.setCedulaPasaporte(request.getParameter("cedulaPasaporte"));
	cs.setAdmCategoria(request.getParameter("admCategoria"));
	//solicitud
	cs.setCodigo(codigo);
	cs.setFechaCargo(request.getParameter("fechaCargo"));
	cs.setCodCentroServicio(request.getParameter("codCentroServicio"));
	cs.setCentroServicioDesc(request.getParameter("centroServicioDesc"));
	cs.setCupon(request.getParameter("cupon"));
	cs.setMedCodigoResp(request.getParameter("medCodigoResp"));
	cs.setMedicoNombre(request.getParameter("medicoNombre"));
	if(request.getParameter("medCodigoResp") != null && !request.getParameter("medCodigoResp").trim().equals(""))
	cs.setMedicoCirugia(request.getParameter("medCodigoResp"));
	else if(request.getParameter("admMedico") != null && !request.getParameter("admMedico").trim().equals(""))
	cs.setMedicoCirugia(request.getParameter("admMedico"));
	/*if (fp.equalsIgnoreCase("cds_solicitud_ima")) cs.setGeneraArchivo("S");
	else*/ cs.setGeneraArchivo(request.getParameter("generaArchivo"));
	cs.setEstado(request.getParameter("estado"));
	cs.setFechaSolicitud(request.getParameter("fechaSolicitud"));
	cs.setNombreCtaMensual(request.getParameter("nombreCtaMensual"));
	cs.setIdentificacionCtaMensual(request.getParameter("identificacionCtaMensual"));
	cs.setUsuarioCreac(UserDet.getUserName());
	cs.setUsuarioMod(UserDet.getUserName());
	cs.setFacturaEmpresa(request.getParameter("aseguradora"));

	if (fp.trim().equalsIgnoreCase("cds_solicitud_rayx_lab_ped")) cs.setTipoSolicitud("E");
	else cs.setTipoSolicitud("I");
	cs.setOrigen("C");
	//transaccion
	cs.setCompania((String) session.getAttribute("_companyId"));
	if (fp.equalsIgnoreCase("cds_solicitud_ima")) cs.setFecha(cs.getFechaSolicitud());
	else cs.setFecha(cs.getFechaCargo());
	cs.setTipoTransaccion("C");
	if(request.getParameter("nombre_medico_externo")!=null && !request.getParameter("nombre_medico_externo").equals("")) cs.setNombreMedExterno(request.getParameter("nombre_medico_externo"));
	if(request.getParameter("profileCPT")!=null && !request.getParameter("profileCPT").equals("")) cs.setPerfilCpt(request.getParameter("profileCPT"));

	int size = 0;
	if (request.getParameter("size") != null) size = Integer.parseInt(request.getParameter("size"));
	String itemRemoved = "";

	cs.getDetalle().clear();
	for (int i=1; i<=size; i++)
	{
		CdsSolicitudDetalle csd = new CdsSolicitudDetalle();

		//cds_detalle_solicitud
		csd.setKey(request.getParameter("key"+i));
		csd.setCodigo(request.getParameter("codigo"+i));
		//if (fp.equalsIgnoreCase("cds_solicitud_ima") || fp.equalsIgnoreCase("cds_solicitud_lab_ext")) csd.setCodCentroServicio(cs.getCodCentroServicio());else
		csd.setCodCentroServicio(request.getParameter("codCentroServicio"+i));
		//csd.setCentroServicioDesc(request.getParameter("centroServicioDesc"+i));
		csd.setCodPaq(request.getParameter("codPaq"+i));
		csd.setCodProcedimiento(request.getParameter("codProcedimiento"+i));
		csd.setProcedimientoDesc(request.getParameter("procedimientoDesc"+i));
		csd.setPrecio(request.getParameter("precio"+i));
		csd.setComentario(request.getParameter("comentario"+i));
		csd.setOferta(request.getParameter("oferta"+i));
		csd.setRecargo(request.getParameter("recargo"+i));
		csd.setCdsProducto(request.getParameter("cdsProducto"+i));
		csd.setTipoSolicit(request.getParameter("tipoSolicit"+i));
		if (cs.getOnlySol().equalsIgnoreCase("Y")) csd.setEstado("S");//cargo debe ser generado en pantalla de solicitudes
		else csd.setEstado("T");//cargado
		if (fp.equalsIgnoreCase("cds_solicitud_ima") || cs.getOnlySol().equalsIgnoreCase("Y")) csd.setFechaSolicitud(cs.getFechaSolicitud());
		//fac_detalle_transaccion
		csd.setTipoCargo("07");
		csd.setCantidad("1");
		csd.setEstatus("S");
		csd.setNoCubierto("N");
		csd.setDescripcion(csd.getProcedimientoDesc());
		csd.setUsuarioCreac(UserDet.getUserName());
		csd.setUsuarioMod(UserDet.getUserName());
		/*if (fp.equalsIgnoreCase("cds_solicitud_ima")) csd.setFechaCargo(cs.getFechaSolicitud());
		else*/ csd.setFechaCargo(cs.getFechaCargo());

		csd.setHabitacion(request.getParameter("cama"));
		csd.setCodSala(request.getParameter("sala"));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = csd.getKey();
			csd.setStatus("D");//D=Delete action in CdsSolicitudMgr
			vProce.remove(csd.getTipoSolicit()+(csd.getTipoSolicit().equalsIgnoreCase("Q")?csd.getCodPaq():csd.getCodProcedimiento()));
		}
		else csd.setStatus(request.getParameter("status"+i));

		try
		{
			iProce.put(csd.getKey(),csd);
			cs.addDetalle(csd);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}

	if (!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&fp="+fp+"&codigo="+codigo+"&procLastLineNo="+procLastLineNo+"&profileCPT="+profileCPT);
		return;
	}

	if (baction != null && (baction.equals("+") || baction.equalsIgnoreCase("Proc") || baction.equalsIgnoreCase("Paq")))
	{
		if (baction.equals("+")) response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&fp="+fp+"&codigo="+codigo+"&procLastLineNo="+procLastLineNo+"&profileCPT="+profileCPT+"&modalize="+modalize);
		else response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type="+baction+"&mode="+mode+"&fp="+fp+"&codigo="+codigo+"&procLastLineNo="+procLastLineNo+"&profileCPT="+profileCPT+"&modalize="+modalize);
		return;
	}

	String solicitud = "";
	String cargo = "";
	if (baction != null && baction.trim().equalsIgnoreCase("Guardar"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		CSolMgr.addSolicitud(cs);
		solicitud = CSolMgr.getPkColValue("codigo");
		if (!cs.getOnlySol().equalsIgnoreCase("Y")) cargo = CSolMgr.getPkColValue("facCodigo");
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (CSolMgr.getErrCode().equals("1")){%>
		parent.document.form0.errCode.value = <%=CSolMgr.getErrCode()%>;
		parent.document.form0.errMsg.value = '<%=CSolMgr.getErrMsg()%>';
		parent.document.form0.solicitud.value = '<%=solicitud%>';
		parent.document.form0.cargo.value = '<%=cargo%>';
		parent.document.form0.submit();
	<%} else {%>
		parent.form0BlockButtons(false);
	<%throw new Exception(CSolMgr.getErrMsg()); }%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>