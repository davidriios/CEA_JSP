<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.TratamientoMgr"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ordenDet" scope="page" class="issi.expediente.DetalleOrdenMed" />
<jsp:useBean id="orden" scope="page" class="issi.expediente.OrdenMedica" />
<jsp:useBean id="tratMgr" scope="page" class="issi.expediente.TratamientoMgr" />
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
tratMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String codigo = request.getParameter("codigo");
String desc = request.getParameter("desc");
String from = request.getParameter("from");
String medico = request.getParameter("medico");
String noOrden = request.getParameter("orden");
String fechaCreacion = request.getParameter("fecha_creacion");

String fg = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (desc == null) desc = "";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (codigo == null) codigo = "0";
if (from == null) from = "";
if (medico == null) medico = "";
if (noOrden == null) noOrden = "0";
if (fechaCreacion == null) fechaCreacion = "";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDateTimeHour = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");

if (request.getMethod().equalsIgnoreCase("GET"))
{

al2 = SQLMgr.getDataList("select distinct aa.fecha_creac, aa.fc, aa.usuario_creac, aa.code, aa.orden from (select fecha_creac,  to_char(fecha_creac, 'dd/mm/yyyy hh12:mi am') fc, usuario_creac, ( select join(cursor(select codigo from tbl_sal_tratamiento_paciente where pac_id = "+pacId+" and secuencia = "+noAdmision+" and fecha_creac = a.fecha_creac  ) , ', ' ) from dual ) code, ( select join(cursor(select orden from tbl_sal_tratamiento_paciente where pac_id = "+pacId+" and secuencia = "+noAdmision+" and fecha_creac = a.fecha_creac  ) , ', ' ) from dual ) orden from TBL_SAL_TRATAMIENTO_PACIENTE a where PAC_ID = "+pacId+" and secuencia = "+noAdmision+" ) aa order by fecha_creac desc ");

sql = "SELECT b.codigo, decode(b.codigo, null, 'A', 'U') estado, a.codigo AS cod_tratamiento, a.descripcion descripcion, nvl(b.seleccionar,' ') AS seleccionar, nvl(b.observacion,' ') as observacion, b.usuario_creac as usuario_creacion, to_char(b.fecha_creac,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, b.usuario_modif as usuario_modificacion, to_char(b.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, to_char(b.fecha_fin,'dd/mm/yyyy hh12:mi:ss am') as fecha_fin from tbl_sal_tratamiento_paciente b, TBL_SAL_TRATAMIENTO a where a.CODIGO=b.cod_tratamiento(+) AND b.PAC_ID(+)="+pacId+" and b.secuencia(+)="+noAdmision+" and b.codigo(+) in("+codigo+") "+(noOrden.trim().equals("")?"":"  and b.orden(+) in("+noOrden+") ")+"";
if (!viewMode) sql += " and a.estado = 'A'";

sql += " order by b.codigo nulls last, a.codigo ";

	al = SQLMgr.getDataList(sql);

	if (al.size() == 0) if (!viewMode) modeSec = "add";
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Tratamientos - '+document.title;
function doAction(){newHeight();document.form0.medico.value = <%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%>;setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function isChecked(k){
var $c = $("#seleccionar"+k);
var $t =  $("#observacion"+k);
if ($c.is(":checked")) $t.removeClass('FormDataObjectDisabled').prop('readOnly',  false);
else $t.val("").addClass('FormDataObjectDisabled').prop('readOnly',  true);

return true;
var ejecutado = 0;var existe = 0;<%if((UserDet.getRefType().trim().equalsIgnoreCase("M"))|| UserDet.getUserProfile().contains("0")||UserDet.getXtra5().trim().equalsIgnoreCase("S")){%>var code  = eval('document.form0.cod_tratamiento'+k).value;var desc  = eval('document.form0.descripcion'+k).value;eval('document.form0.observacion'+k).disabled = !eval('document.form0.seleccionar'+k).checked;if (eval('document.form0.seleccionar'+k).checked == false && eval('document.form0.observacion'+k).value != ''){alert('No se puede desactivar el Tratamiento, debe eliminar el texto en el campo observación...,VERIFIQUE');eval('document.form0.seleccionar'+k).checked=true;eval('document.form0.observacion'+k).disabled = false;}if (eval('document.form0.seleccionar'+k).checked == true)/*Verifica si ya existe el tratamiento.*/{existe = getDBData('<%=request.getContextPath()%>',' count(*) existe','tbl_sal_detalle_orden_med','pac_id = <%=pacId%> and secuencia  = <%=noAdmision%> and  to_date(to_char(fecha_orden ,\'dd/mm/yyyy\'),\'dd/mm/yyyy\') = to_date(\'<%=cDateTime.substring(0,10)%>\',\'dd/mm/yyyy\') and cod_tratamiento = '+code+' ','');if(existe >0){if(confirm('Existe una orden médica de este tipo. ¿Desea generar una NUEVA ORDEN?  '+desc)){
eval('document.form0.generaOrden'+k).value = 'S';}else eval('document.form0.generaOrden'+k).value = 'N';eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';}else{eval('document.form0.generaOrden'+k).value = 'S';eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';}}if (eval('document.form0.seleccionar'+k).checked == false)/*Verifica si ha ejecutado la orden.*/{ejecutado = getDBData('<%=request.getContextPath()%>',' count(*) ejecutado','tbl_sal_detalle_orden_med','pac_id = <%=pacId%> and secuencia  = <%=noAdmision%> and  to_date(to_char(fecha_orden ,\'dd/mm/yyyy\'),\'dd/mm/yyyy\') = to_date(\'<%=cDateTime.substring(0,10)%>\',\'dd/mm/yyyy\') and cod_tratamiento = '+code+' and ejecutado = \'S\'','');if(parseInt(ejecutado) > 0 /*|| eval('document.form0.generaOrden'+k).value == 'S'*/){alert('No se puede omitir el tratamiento.  La enfermera a marcado la orden como ejecutada...,VERIFIQUE!');eval('document.form0.seleccionar'+k).checked=true;eval('document.form0.observacion'+k).disabled = false;}else{eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';eval('document.form0.generaOrden'+k).value = 'N';}}<%}else{%>eval('document.form0.observacion'+k).disabled = !eval('document.form0.seleccionar'+k).checked;if (eval('document.form0.seleccionar'+k).checked)eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';else eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';<%}%>}
function chkOrden(){var size = document.form0.size.value;var ejecutado = 0;for(k=0;k<size;k++){var code  = eval('document.form0.cod_tratamiento'+k).value;var desc  = eval('document.form0.descripcion'+k).value;if (eval('document.form0.seleccionar'+k).checked){ejecutado = getDBData('<%=request.getContextPath()%>',' count(*) ejecutado','tbl_sal_detalle_orden_med','pac_id = <%=pacId%> and secuencia  = <%=noAdmision%> and  to_date(to_char(fecha_orden ,\'dd/mm/yyyy\'),\'dd/mm/yyyy\') = to_date(\'<%=cDateTime.substring(0,10)%>\',\'dd/mm/yyyy\') and cod_tratamiento = '+code+' ','');if(ejecutado >0){if(confirm('Existe una orden médica de este tipo. ¿Desea generar una NUEVA ORDEN?')){eval('document.form0.generaOrden'+k).value = 'S';}else eval('document.form0.generaOrden'+k).value = 'N';}else{eval('document.form0.generaOrden'+k).value = 'S';eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';}}}}
function verTratamientos(){abrir_ventana1('../expediente/exp_list_tratamiento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>');}
function imprimir(){abrir_ventana('../expediente/print_exp_seccion_20.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&codigo=<%=codigo%>&desc=<%=desc%>&orden=<%=noOrden%>&fecha_creacion=<%=fechaCreacion%>');}

function add() {
 window.location = '../expediente/exp_tratamientos.jsp?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&codigo=0';
}

function setOrden(fc, codigo, orden) {
 window.location = '../expediente/exp_tratamientos.jsp?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>&codigo='+codigo+'&fecha_creacion='+fc+'&orden='+orden;
}
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">

<tr class="TextRow01">
		<td>
				<div id="main" width="100%" class="exp h100">
						<div id="detalle" width="98%" class="child">

						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextRow02">
									<td colspan="3">&nbsp;<cellbytelabel id="1">Listado de Ordenes</cellbytelabel></td>
									<td align="right" colspan="3">
										 <a href="javascript:imprimir()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a><a href="javascript:verTratamientos()" class="Link00">[ <cellbytelabel id="2">Consultar Tratamientos</cellbytelabel> ]</a>

										 <%if((UserDet.getRefType().trim().equalsIgnoreCase("M"))|| UserDet.getUserProfile().contains("0")||UserDet.getXtra5().trim().equalsIgnoreCase("S")){%>
											 <a href="javascript:add()" class="Link00">[ <cellbytelabel id="2">Agregar Tratamientos</cellbytelabel> ]</a>
										 <%}%>
									</td>
							</tr>

							<tr class="TextHeader">
								<td  width="5%">&nbsp;</td>
								<td  width="15%"><cellbytelabel id="5">C&oacute;digo</cellbytelabel></td>
								<td  width="25%"><cellbytelabel id="6">Fecha Creaci&oacute;n</cellbytelabel></td>
								<td  width="25%"><cellbytelabel id="6">Usuario Creaci&oacute;n</cellbytelabel></td>
								<td  width="25%"><cellbytelabel id="7">Orden</cellbytelabel></td>
								<td  width="5%">&nbsp;</td>
							</tr>
							<% for (int i=0; i<al2.size(); i++) {
								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";

								CommonDataObject cdo2 = (CommonDataObject) al2.get(i);
							%>
							<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setOrden('<%=cdo2.getColValue("fc")%>', '<%=cdo2.getColValue("code")%>', '<%=cdo2.getColValue("orden")%>')" style="text-decoration:none; cursor:pointer">
								<td> </td>
								<td><%=cdo2.getColValue("code")%></td>
								<td><%=cdo2.getColValue("fc")%></td>
								<td><%=cdo2.getColValue("usuario_creac")%></td>
								<td><%=cdo2.getColValue("orden")%></td>
								<td> </td>
							</tr>
							<%}%>
					</table>
			 </div>
		</div>
	</td>
</tr>

	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("modeSec",modeSec)%>
				<%=fb.hidden("seccion",seccion)%>
				<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				<%=fb.hidden("dob","")%>
				<%=fb.hidden("codPac","")%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("size",""+al.size())%>
				<%=fb.hidden("fecha",cDateTime.substring(0,10))%>
				<%=fb.hidden("hora",cDateTime.substring(11))%>
				<%=fb.hidden("medico",medico)%>
				<%=fb.hidden("from",from)%>
				<%=fb.hidden("orden",noOrden)%>
				<%=fb.hidden("fecha_creacion",fechaCreacion)%>
				<%=fb.hidden("formaSolicitud","")%>
				<tr>
					<td colspan="4">
						<table width="100%" border="0" cellpadding="1" cellspacing="1">

							<tr class="TextRow01">
								<td colspan="4"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>
									&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
									<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>
									&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,50,"","","")%>
									<%=fb.button("btnMed","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"","Médico")%>
								</td>
							</tr>
							<tr align="center" class="TextHeader">
								<td width="30%"><cellbytelabel id="3">Diagn&oacute;sticos/ Tratamientos</cellbytelabel></td>
								<td width="3%"><cellbytelabel id="4">S&iacute;</cellbytelabel></td>
								<td width="50%"><cellbytelabel id="5">Observaci&oacute;n</cellbytelabel></td>
								<td width="17%"><cellbytelabel id="6">Hasta</cellbytelabel></td>
							</tr>
<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>						<%=fb.hidden("usuario_creac"+i,cdo.getColValue("USUARIO_CREAC"))%>
						<%=fb.hidden("fecha_creac"+i,cdo.getColValue("FECHA_CREAC"))%>
						<%=fb.hidden("cod_tratamiento"+i,cdo.getColValue("cod_tratamiento"))%>
						<%=fb.hidden("generaOrden"+i,"S")%>
						<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
						<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
						<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>

							<tr class="<%=color%>">
								<td><%=cdo.getColValue("descripcion")%></td>
								<td align="center"><%=fb.checkbox("seleccionar"+i,"S",(cdo.getColValue("seleccionar").equalsIgnoreCase("S")),viewMode,null,null,"onClick=\"javascript:isChecked("+i+")\"")%></td>
								<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode||cdo.getColValue("observacion"," ").trim().equals(""),40,2,2000,null,"",null)%></td>
								<td>
										<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
										<jsp:param name="nameOfTBox1" value="<%="fechaFin"+i%>" />
										<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_fin"," ")%>" />
										<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
										</jsp:include>
								</td>
							</tr>
<%
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
				<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="9">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>
		<%  //fb.appendJsValidation("\n\tif (chkOrden()) error++;\n"); %>
				<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	int size= Integer.parseInt(request.getParameter("size"));
	al.clear();

	orden.setPacId(request.getParameter("pacId"));
	orden.setCodPaciente(request.getParameter("codPac"));
	orden.setFecNacimiento(request.getParameter("dob"));
	orden.setSecuencia(request.getParameter("noAdmision"));
	orden.setFecha(cDateTime.substring(0,10));
	orden.setMedico(request.getParameter("medico"));
	orden.setUsuarioCreacion((String) session.getAttribute("_userName"));
	orden.setFechaCreacion(cDateTime);
	orden.setUsuarioModif((String) session.getAttribute("_userName"));
	orden.setFormaSolicitud(request.getParameter("formaSolicitud"));
	//orden.setFechaCreacion(cDateTime);

	for (int i=0; i<size; i++)
	{
		if (request.getParameter("seleccionar"+i) != null && request.getParameter("seleccionar"+i).equalsIgnoreCase("S"))
		{
			cdo = new CommonDataObject();
			DetalleOrdenMed det = new DetalleOrdenMed();


			det.setGeneraOrden(request.getParameter("generaOrden"+i));

			/*cdo.setTableName("tbl_sal_tratamiento_paciente");
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
			det.addColValue("cod_paciente",request.getParameter("codPac"));
			cdo.addColValue("secuencia",request.getParameter("noAdmision"));
			cdo.addColValue("fec_nacimiento",request.getParameter("dob"));
			cdo.addColValue("pac_id",request.getParameter("pacId"));
			*/
			det.setCodTratamiento(request.getParameter("cod_tratamiento"+i));
			det.setObservacion(request.getParameter("observacion"+i));
			det.setDescripcion(request.getParameter("descripcion"+i));
			det.setCheck((request.getParameter("seleccionar"+i)==null)?"N":"S");
			if(request.getParameter("usuario_creac"+i) !=null && !request.getParameter("usuario_creac"+i).trim().equals(""))
			det.setUsuarioCreacion(request.getParameter("usuario_creac"+i));
			else det.setUsuarioCreacion((String) session.getAttribute("_userName"));

			if(request.getParameter("fecha_creac"+i) !=null && !request.getParameter("fecha_creac"+i).trim().equals(""))
			det.setFechaCreacion(request.getParameter("fecha_creac"+i));
			else det.setFechaCreacion(cDateTime);
			det.setUsuarioModificacion((String) session.getAttribute("_userName"));
			det.setFechaModificacion(cDateTime);

			det.setTipoOrden("4");
			det.setFechaFin(request.getParameter("fechaFin"+i));
						det.setEstado(request.getParameter("estado"+i));
						det.setCodigo(request.getParameter("codigo"+i));

			//cdo.addColValue("cod_tratamiento",request.getParameter("cod_tratamiento"+i));
			//cdo.addColValue("seleccionar",(request.getParameter("seleccionar"+i)==null)?"N":"S");
			//cdo.addColValue("observacion",request.getParameter("observacion"+i));

			 try {
					orden.getDetalleOrdenMed().add(det);


					} catch (Exception e) {
					//System.out.println("Unable to addget item ");
					}

			al.add(cdo);
		}
	}

	/*if (al.size() == 0)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_tratamiento_paciente");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
		al.add(cdo);

	}*/
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	//SQLMgr.insertList(al);
	tratMgr.addDetalle(orden);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (tratMgr.getErrCode().equals("1"))
{
%>
	alert('<%=tratMgr.getErrMsg()%>');
<%
if((UserDet.getRefType().trim().equalsIgnoreCase("M"))|| UserDet.getUserProfile().contains("0")||UserDet.getXtra5().trim().equalsIgnoreCase("S"))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
	<%if(from.trim().equals("")){%>
		parent.window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
		<%}%>
<%
	}
	else
	{
%>
	<%if(from.trim().equals("")){%>
		parent.window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
		<%}%>
<%
	}
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
} else throw new Exception(tratMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&from=<%=from%>&medico=<%=medico%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
