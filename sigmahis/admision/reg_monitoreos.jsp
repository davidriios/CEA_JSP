<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Monitoreos"%>
<%@ page import="issi.admision.DetalleMonitoreo"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="monit" scope="session" class="issi.admision.Monitoreos" />
<jsp:useBean id="iMonitoreos" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="MnMgr" scope="page" class="issi.admision.MonitoreosMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="cdo2" scope="page" class="issi.admin.CommonDataObject" />
<%
/**
==========================================================================================
Admision:
adm2010.fmb Registro de Monitoreos
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
MnMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String sql = "", key = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

String anio = request.getParameter("anio");
if(anio == null) anio=fecha.substring(6, 10);
String mes = fecha.substring(3, 5);
System.out.println(" mes =========== "+mes);
String fg = request.getParameter("fg");

int lineNo = 0;
boolean viewMode = false;
if (fg == null) fg = "RQ";
if (mode == null) mode = "add";
if(mode.trim().equals("view")) viewMode = true;


/*
===================================================================================

===================================================================================
*/
if (request.getParameter("lineNo") != null) lineNo = Integer.parseInt(request.getParameter("lineNo"));


if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change==null){
		monit = new Monitoreos();
		session.setAttribute("monit",monit);
		iMonitoreos.clear();
		//rqArtKey.clear();
		//monit.setAnio(anio);
		//monit.setCodigoAlmacen("2");
		//monit.setReqType(tr);
		monit.setFechaRegistro(fecha);
	}
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El codigo del monitoreo no es válido. Por favor intente nuevamente!");

		if (change==null){



			sql = "select  a.primer_nombre primerNombre, a.segundo_nombre segundoNombre, a.primer_apellido primerApellido, a.segundo_apellido segundoApellido, a.apellido_de_casada apellidoDeCasada, to_char(nvl(a.provincia,'0'))provincia, nvl(a.sigla,'')sigla, to_char(nvl(a.tomo,''))tomo, to_char(nvl(a.asiento,''))asiento, a.d_cedula dCedula, a.pasaporte,a.codigo , to_char(a.fecha_nacimiento,'dd/mm/yyyy') fechaNacimiento , to_char(a.fecha_registro,'dd/mm/yyyy') fechaRegistro,nvl(trunc(months_between(sysdate,a.fecha_nacimiento)/12),0) as edad, nvl(to_char(a.f_p_p,'dd/mm/yyyy'),' ') fPP, a.g gesta, a.p para, a.a aborto, a.c cesarea, a.medico, a.residencia_direccion residenciaDireccion, a.residencia_comunidad residenciaComunidad, a.residencia_corregimiento residenciaCorregimiento, a.residencia_distrito residenciaDistrito, a.residencia_provincia residenciaProvincia, a.residencia_pais residenciaPais, a.telefono, a.persona_de_urgencia personaUrgencia, a.direccion_de_urgencia direccionUrgencia, a.telefono_urgencia telefonoUrgencia, a.identificacion_conyugue identificacionConyugue, a.nombre_conyugue nombreConyugue, a.lugar_trabajo_conyugue lugarTrabajoConyugue, a.telefono_trabajo_conyugue telefonoTrabajoConyugue, a.conyugue_nacionalidad conyugueNacionalidad, a.tipo_sangre tipoSangre, a.rh,a.estatus, a.edad, a.mes,a.usuario_adiciona usuarioAdiciona ,a.usuario_modifica  usuarioModifica , to_char(a.fecha_adiciona,'dd/mm/yyyy hh12:mi:ss am') fechaAdiciona,to_char(a.fecha_modifica,'dd/mm/yyyy hh12:mi:ss am') fechaModifica,m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre)||' '||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada)) as nombreMedico  from tbl_adm_monitoreo a,tbl_adm_medico m where a.codigo ="+id+" and a.medico = m.codigo(+)";
			System.out.println("sql....="+sql);
			monit = (Monitoreos) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Monitoreos.class);


			sql = "select  codigo, secuencia, p_diastolica pDiastolica,p_sistolica pSistolica, semana_gesta semanaGesta, usuario_adiciona usuarioAdiciona, to_date(fecha_adiciona,'dd/mm/yyyy hh12:mi:ss am') fechaAdiciona, usuario_modifica usuarioModifica,to_char(fecha_registro,'dd/mm/yyyy hh12:mi:ss am') fechaRegistro, mes, num_monit numMonit ,'A' Status from tbl_adm_detalle_monitoreo where codigo ="+id;

			System.out.println("sqlDetails....="+sql);

			monit.setDetalleMonitoreo(sbb.getBeanList(ConMgr.getConnection(), sql, DetalleMonitoreo.class));
			for(int i=0;i<monit.getDetalleMonitoreo().size();i++){
				DetalleMonitoreo dm = (DetalleMonitoreo) monit.getDetalleMonitoreo().get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				System.out.println("key en el query === "+key);
				try {
					iMonitoreos.put(key, dm);
				}	catch (Exception e)	{
					System.err.println(e.getMessage());
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Admision - '+document.title;

function doAction()
{
}
function checkProvincia(obj)
{
	var sigla=document.form0.sigla.value;
	var tomo=document.form0.tomo.value;
	var asiento=document.form0.asiento.value;
	//var dCedula=document.form0.d_cedula.value;
	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_monitoreo',' provincia=\''+obj.value+'\' and sigla=\''+sigla+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' ','<%=monit.getProvincia().trim()%>'))
	{
			 document.form0.provincia.value = '';
			 return true;
	} else return false;
}

function checkSigla(obj)
{
	var provincia=document.form0.provincia.value;
	var tomo=document.form0.tomo.value;
	var asiento=document.form0.asiento.value;

	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_monitoreo',' provincia=\''+provincia+'\' and sigla=\''+obj.value+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\'','<%=monit.getSigla()%>'))
	{
			 document.form0.sigla.value = '';
			 return true;
	} else return false;
}

function checkTomo(obj)
{
	var provincia=document.form0.provincia.value;
	var sigla=document.form0.sigla.value;
	var asiento=document.form0.asiento.value;
	if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_monitoreo','provincia=\''+provincia+'\' and sigla=\''+sigla+'\' and tomo=\''+obj.value+'\' and asiento=\''+asiento+'\'','<%=monit.getTomo()%>'))
	{
			 document.form0.tomo.value = '';
			 return true;
	} else return false;
}

function checkAsiento(obj)
{
	var provincia=document.form0.provincia.value;
	var sigla=document.form0.sigla.value;
	var tomo=document.form0.tomo.value;

	if( duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_monitoreo',' provincia=\''+provincia+'\' and sigla=\''+sigla+'\' and tomo=\''+tomo+'\' and asiento=\''+obj.value+'\'','<%=monit.getAsiento()%>'))
		{
			 document.form0.asiento.value = '';
			 return true;
		}
		else return false;
}

function checkPasaporte(obj)
{
	//var dCedula=document.generales.d_cedula.value;
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_adm_monitoreo','pasaporte=\''+obj.value+'\'','<%=monit.getPasaporte()%>')

}
function getMedico()
{
	abrir_ventana1('../common/search_medico.jsp?fp=monitoreos');
}

function showReporte()
{
	abrir_ventana1('../admision/print_monitoreos.jsp?fp=monitoreos');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ADMISION - REGISTRO DE MONITOREOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<%
				fb = new FormBean("form0","","post");
				%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("tr",tr)%>
				<%=fb.hidden("clearHT","")%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("medico",""+monit.getMedico())%>
				<%=fb.hidden("lineNo",""+lineNo)%>
				<%fb.appendJsValidation("if(document.form0.fechaNacimiento.value==''){CBMSG.warning('Por favor ingrese la Fecha de Nacimiento!');error++;}");%>

<table id="tbl_generales" width="100%" cellpadding="0" border="0" cellspacing="0" align="center">
	<tr>
		<td>
				<tr>
					<td>
					<div id="panel0" style="visibility:visible;">
					<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">

						<tr class="TextPanel">
								<td colspan="4">&nbsp;Datos Principales</td>
						</tr>
						<tr class="TextRow01">

							<td width="17%">C&eacute;dula</td>
							<td width="33%">
							<%=fb.intBox("provincia",monit.getProvincia(),false,false,false,3,2,null,null,"onBlur=\"javascript:checkProvincia(this)\"")%>
							<%=fb.textBox("sigla",monit.getSigla(),false,false,false,3,2,null,null,"onBlur=\"javascript:checkSigla(this)\"")%>
							<%=fb.intBox("tomo",monit.getTomo(),false,false,false,5,4,null,null,"onBlur=\"javascript:checkTomo(this)\"")%>
							<%=fb.intBox("asiento",monit.getAsiento(),false,false,false,5,6,null,null,"onBlur=\"javascript:checkAsiento(this)\"")%>
							</td>
							<td>No. Paciente</td>
							<td><%=fb.intBox("codigo",id,false,false,true,20)%></td>

						</tr>
						<tr class="TextRow01">

							<td>Pasaporte</td>
							<td><%=fb.textBox("pasaporte",monit.getPasaporte(),false,false,false,42,20,null,"onBlur=\"javascript:checkPasaporte(this)\"","")%></td>               <td>Fecha De Registro</td>
							<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fechaRegistro" />
								<jsp:param name="format" value="dd/mm/yyyy"/>
								<jsp:param name="valueOfTBox1" value="<%=monit.getFechaRegistro()%>" />

								</jsp:include></td>
						</tr>
						<tr class="TextRow01">
								<td>Fecha Nacimiento</td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fechaNacimiento" />
								<jsp:param name="format" value="dd/mm/yyyy"/>
								<jsp:param name="valueOfTBox1" value="<%=monit.getFechaNacimiento()%>" />
								<jsp:param name="fieldClass" value="FormDataObjectRequired" />
								</jsp:include>
							</td>
							<td>M&eacute;dico</td>
									<td><%//=fb.textBox("medico",monit.getMedico(),true,false,true,5)%>
											<%=fb.textBox("medicoDesc",monit.getNombreMedico(),false,true,viewMode,55)%>
											<%=fb.button("med","...",true,viewMode,null,null,"onClick=\"javascript:getMedico()\"","seleccionar Medico")%></td>
						</tr>
						<tr class="TextRow01">
							<td>Primer Nombre</td>
							<td><%=fb.textBox("primerNombre",monit.getPrimerNombre(),true,false,false,35,30)%></td>
							<td>Edad</td>
									<td><%=fb.textBox("edad",monit.getEdad(),false,false,false,10,3)%></td>
						</tr>
						<tr class="TextRow01">
								<td>Segundo Nombre</td>
									<td><%=fb.textBox("segundoNombre",monit.getSegundoNombre(),false,false,false,35,30)%></td>
									<td>Tel&eacute;fono</td>
									<td><%=fb.textBox("telefono",monit.getTelefono(),false,false,false,20,13)%></td>
						</tr>
						<tr class="TextRow01">
								<td>Apellido Paterno</td>
									<td><%=fb.textBox("primerApellido",monit.getPrimerApellido(),false,false,false,35,30)%></td>
									<td>F-P-P</td>
									<td> <jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fpp" />
								<jsp:param name="format" value="dd/mm/yyyy"/>
								<jsp:param name="valueOfTBox1" value="<%=monit.getFPP()%>" />
								</jsp:include></td>

						</tr>
						<tr class="TextRow01">
							<td>Apellido Materno</td>
									<td><%=fb.textBox("segundoApellido",monit.getSegundoApellido(),false,false,false,35,30)%></td>
							<td>G</td>
									<td><%=fb.textBox("gesta",monit.getGesta(),false,false,false,10,2)%></td>
						</tr>
						<tr class="TextRow01">
							<td>Apellido de Casada</td>
									<td><%=fb.textBox("apellidoCasada",monit.getApellidoDeCasada(),false,false,false,35,30)%></td>
									<td>P</td>
									<td><%=fb.textBox("para",monit.getPara(),false,false,false,10,2)%></td>
						</tr>
						<tr class="TextRow01">

							<td>Tipo de Sangre</td>
								<td><%=fb.select(ConMgr.getConnection(),"SELECT rh, tipo_sangre FROM tbl_bds_tipo_sangre where rh='P' order by tipo_sangre","rh",monit.getRh())%><%=fb.select(ConMgr.getConnection(),"SELECT tipo_sangre, rh FROM tbl_bds_tipo_sangre WHERE tipo_sangre='O' order by rh","tipoSangre",monit.getTipoSangre())%></td>                <td>A</td>
								<td><%=fb.textBox("aborto",monit.getAborto(),false,false,false,10,2)%></td>
						</tr>
						<tr class="TextRow01">
							<td>&nbsp;</td>
									<td>&nbsp;</td>
									<td>C</td>
									<td><%=fb.textBox("cesarea",monit.getCesarea(),false,false,false,10,2)%></td>
						</tr>

					<tr class="TextRow01">
							<td>Usuario Adiciona</td>
									<td><%=fb.textBox("usuario_crea",monit.getUsuarioAdiciona(),false,false,true,20)%><%=fb.textBox("fecha_crea",monit.getFechaAdiciona(),false,false,true,20)%></td>
									<td>Usuario Modifica</td>
									<td><%=fb.textBox("usuario_mod",monit.getUsuarioModifica(),false,false,true,20)%><%=fb.textBox("fecha_mod",monit.getFechaModifica(),false,false,true,20)%></td>
						</tr>
						<!-- <tr class="TextRow01" align="center">
							<td colspan="4"> <%=fb.button("reporte","GENERAR ESTADISTICA",true,viewMode,null,null,"onClick=\"javascript:showReporte()\"","Generar Reporte")%></td>
						</tr>-->


					</table>
					</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>




							<tr>
								<td colspan="8">&nbsp;</td>
							</tr>
							<tr class="TextRow02">
								<td colspan="8" align="right">&nbsp;</td>
							</tr>
				 <tr class="TextRow02">
						<td colspan="8">
							<table align="center" width="99%" cellpadding="0" cellspacing="1">
								<tr class="TextPanel">
									<td colspan="7">Detalle del Monitoreo</td>


									<td align="center"><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
								</tr>
								<tr class="TextHeader">
									<td width="5%" align="center">&nbsp;</td>
									<td width="15%" align="center">&nbsp;</td>
									<td width="10%" align="center" colspan="2">---Presi&oacute;n---</td>

									<td width="10%" align="center">&nbsp;</td>
									<td width="10%" align="center">&nbsp;</td>
									<td width="10%" align="center">&nbsp;</td>
									<td width="3%" align="center">&nbsp;</td>

								</tr>


								<tr class="TextHeader" align="center">
									<td>No.</td>
									<td>Fecha Registro</td>
									<td align="center">Sistolica</td>

									<td align="center">Diastolica</td>
									<td align="center">Sem. Gestaci&oacute;n</td>
									<td>Mes</td>
									<td>No. Monit.</td>
									<td>&nbsp;</td>
								</tr>
							<%
							key = "";

							double entregas =0.00;
							if (iMonitoreos.size() != 0) al = CmnMgr.reverseRecords(iMonitoreos);
							for (int i=0; i<iMonitoreos.size(); i++)
							{
								key = al.get(i).toString();
								DetalleMonitoreo det = (DetalleMonitoreo) iMonitoreos.get(key);
									String displayNote="";
									if (det.getStatus() != null && det.getStatus().equalsIgnoreCase("D")) displayNote = " style=\"display:none\"";
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<%=fb.hidden("secuencia"+i,det.getSecuencia())%>
							<%=fb.hidden("codigo"+i,det.getCodigo())%>
							<%=fb.hidden("usuarioAdiciona"+i,det.getUsuarioAdiciona())%>
							<%=fb.hidden("FechaAdiciona"+i,det.getFechaAdiciona())%>

							<%=fb.hidden("estado"+i,det.getStatus())%>
							<%=fb.hidden("usuarioModifica"+i,det.getUsuarioModifica())%>
							<%=fb.hidden("FechaModifica"+i,det.getFechaModifica())%>
							<%=fb.hidden("key"+i,""+key)%>
							<%=fb.hidden("remove"+i,"")%>

							<tr class="TextRow01"<%=displayNote%>>
								<td width="5%"><%=det.getSecuencia()%></td>
								<td width="15%"><jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
										<jsp:param name="nameOfTBox1" value="<%="fechaReg"+i%>" />
										<jsp:param name="valueOfTBox1" value="<%=det.getFechaRegistro()%>" />
										</jsp:include></td>
								<td width="10%" align="center"><%=fb.textBox("pSistolica"+i,det.getPSistolica(),false,false,viewMode,10,null,null,"")%></td>
								<td width="10%" align="center"><%=fb.textBox("pDiastolica"+i,det.getPDiastolica(),false,false,viewMode,10,null,null,"")%></td>
								<td width="10%" align="center"><%=fb.textBox("semanaGesta"+i,det.getSemanaGesta(),false,false,viewMode,10,null,null,"")%></td>
								<td width="10%" align="center"><%=fb.intBox("mes"+i,(det.getMes() != null && !det.getMes().trim().equals(""))?det.getMes():"",false,false,true,5,"","","")%></td>
								<td width="10%" align="center"><%=fb.intBox("numMonit"+i,det.getNumMonit(),false,false,true,5,"","","")%></td>


								<td width="3%" align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diag.")%></td>

							</tr>
							<%
							}
							%>
							<%=fb.hidden("keySize",""+iMonitoreos.size())%>
							<tr class="TextRow02">

								<td colspan="8" align="right">

						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
								<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
								<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
								<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="6">&nbsp;</td>
				</tr>
				<%
				//fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
				%>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

	lineNo = Integer.parseInt(request.getParameter("lineNo"));
/*****Campos no Guardados *****/
/**
	persona_de_urgencia, direccion_de_urgencia, telefono_urgencia,
	 identificacion_conyugue, nombre_conyugue, lugar_trabajo_conyugue,
	 telefono_trabajo_conyugue, conyugue_nacionalidad,residencia_direccion,
	 residencia_comunidad, residencia_corregimiento, residencia_distrito,
	 residencia_provincia, residencia_pais,
 d_cedula,*/

	monit.setCodigo(request.getParameter("codigo"));
	monit.setFechaNacimiento(request.getParameter("fechaNacimiento"));
	monit.setPrimerNombre(request.getParameter("primerNombre"));
	monit.setSegundoNombre(request.getParameter("segundoNombre"));
	monit.setSegundoApellido(request.getParameter("segundoApellido"));
	monit.setPrimerApellido(request.getParameter("primerApellido"));

	monit.setApellidoDeCasada(request.getParameter("apellidoCasada"));
	monit.setProvincia(request.getParameter("provincia"));
	monit.setSigla(request.getParameter("sigla"));
	monit.setTomo(request.getParameter("tomo"));
	monit.setAsiento(request.getParameter("asiento"));
	monit.setPasaporte(request.getParameter("pasaporte"));

	monit.setFPP(request.getParameter("fpp"));

	monit.setGesta(request.getParameter("gesta"));
	monit.setPara(request.getParameter("para"));
	monit.setAborto(request.getParameter("aborto"));
	monit.setCesarea(request.getParameter("cesarea"));
	monit.setMedico(request.getParameter("medico"));

	monit.setFechaRegistro(request.getParameter("fechaRegistro"));
	monit.setTelefono(request.getParameter("telefono"));
	monit.setTipoSangre(request.getParameter("tipoSangre"));
	monit.setRh(request.getParameter("rh"));
	monit.setEstatus(request.getParameter("estatus"));
	monit.setEdad(request.getParameter("edad"));
	monit.setMes(mes);
	monit.setUsuarioAdiciona((String) session.getAttribute("_userName"));
	monit.setUsuarioModifica((String) session.getAttribute("_userName"));



	monit.getDetalleMonitoreo().clear();
	iMonitoreos.clear();


	for(int i=0;i<keySize;i++){

		DetalleMonitoreo det = new DetalleMonitoreo();

		det.setSecuencia(request.getParameter("secuencia"+i));
		det.setPDiastolica(request.getParameter("pDiastolica"+i));
		det.setPSistolica(request.getParameter("pSistolica"+i));
		det.setSemanaGesta(request.getParameter("semanaGesta"+i));
		det.setFechaRegistro(request.getParameter("fechaReg"+i));
		det.setMes(request.getParameter("mes"+i));
		det.setNumMonit(request.getParameter("numMonit"+i));

		det.setUsuarioAdiciona(request.getParameter("usuarioAdiciona"+i));
		det.setFechaAdiciona(request.getParameter("fechaAdiciona"+i));
		det.setUsuarioModifica(request.getParameter("usuarioModifica"+i));
		det.setFechaModifica(request.getParameter("fechaModifica"+i));
		det.setStatus(request.getParameter("estado"+i));


		key = request.getParameter("key"+i);

				if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				{
					itemRemoved = key;
					det.setStatus("D");
				}
			 try
				{
					iMonitoreos.put(key, det);
					monit.getDetalleMonitoreo().add(det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

		}
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&lineNo="+lineNo+"&id="+request.getParameter("id"));
			return;

		}

		if(baction.trim().equals("+"))//Agregar
		{

				DetalleMonitoreo det = new DetalleMonitoreo();
				det.setSecuencia("0");
				det.setFechaRegistro(cDateTime);
				det.setMes(""+mes);
				det.setStatus("A");
				det.setUsuarioAdiciona((String) session.getAttribute("_userName"));
				det.setUsuarioModifica((String) session.getAttribute("_userName"));

				lineNo++;
				if (lineNo < 10) key = "00" +lineNo;
				else if (lineNo < 100) key = "0" +lineNo;
				else key = "" +lineNo;

				try
				{
					iMonitoreos.put(key,det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
				response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&lineNo="+lineNo+"&id="+request.getParameter("id"));
				return;
		}

		System.out.println("action  "+baction);
		if(baction.trim().equals("Guardar"))//Agregar
		{
					if (mode.equalsIgnoreCase("add"))
					{
							MnMgr.add(monit);
							id   = MnMgr.getPkColValue("id");
						} else {
							MnMgr.update(monit);
							id   = request.getParameter("codigo");
						}
						session.removeAttribute("monit");
						session.removeAttribute("iMonitoreos");
		}


%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (MnMgr.getErrCode().equals("1"))
{
%>
	alert('<%=MnMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/monitoreo_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/monitoreo_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/monitoreo_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(MnMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>