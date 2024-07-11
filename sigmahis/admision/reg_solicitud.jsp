<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.CdsSolicitud"%>
<%@ page import="issi.admision.CdsSolicitudDetalle"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
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
ArrayList al = new ArrayList();
CdsSolicitud cs = new CdsSolicitud();
StringBuilder sbSql = new StringBuilder();
String key = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String codigo = request.getParameter("codigo");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String onlySol = request.getParameter("onlySol") == null?"":request.getParameter("onlySol");
String modalize = request.getParameter("modalize") == null?"":request.getParameter("modalize");
boolean isOnlySol = onlySol.equalsIgnoreCase("Y");
boolean viewMode = false;
int procLastLineNo = 0;
String title = "Solicitud de Servicio Ambulatorio de Laboratorio";
String usaPerfilCpt = "N";
try {usaPerfilCpt =java.util.ResourceBundle.getBundle("issi").getString("usaPerfilCpt");}catch(Exception e){ usaPerfilCpt = "N";}
if (mode == null) mode = "add";
if (fp == null) fp = "cds_solicitud_rayx_lab_ped";
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
String showIntLabSeq = "N";
String intLabSeq = "-";
String imprimirCargo = java.util.ResourceBundle.getBundle("issi").getString("imprimirCargo");
if(imprimirCargo==null || imprimirCargo.equals("")) imprimirCargo = "N";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iProce.clear();
		vProce.clear();
		if (codigo == null) codigo = "0";
		if (pacId == null) pacId = "";
		if (noAdmision == null) noAdmision = "";
		cs.setCodigo(codigo);
		cs.setPacId(pacId);
		cs.setAdmiSecuencia(noAdmision);
		cs.setFechaCargo(cDateTime);
		cs.setGeneraArchivo("S");
		
		sbSql.append("select nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'GENERA_ARCHIVO_LAB_RX'),'N') as GENERA_ARCHIVO_LAB_RX");
		if (fp.equalsIgnoreCase("cds_solicitud_ima")) {
		
			cs.setFechaSolicitud(cDateTime);
			title = "Solicitud de Servicio Ambulatoria de Imagenología";

			sbSql.append(", nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'CDS_RIS'),'-') as cdsDefault");
		
		} else {
		
			if (isOnlySol) {

				cs.setFechaSolicitud(cDateTime);
				cs.setEstado("S");

			}
			if (fp.equalsIgnoreCase("cds_solicitud_lab_ext")) {
		
				//cs.setCodCentroServicio("114");
				//cs.setCentroServicioDesc(SQLMgr.getData("select codigo, descripcion from tbl_cds_centro_servicio where codigo="+cs.getCodCentroServicio()).getColValue("descripcion"));
				title = "Solicitud de Servicio Ambulatoria de Lab. Externo";
		
			}

			sbSql.append(", nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'INT_LAB_SHOW_SEQ'),'N') as showIntLabSeq");
			sbSql.append(", nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'INT_LAB_SEQ_NO'),'-') as intLabSeq");
			sbSql.append(", nvl(get_sec_comp_param(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",'CDS_LIS'),'-') as cdsDefault");

		}
		sbSql.append(" from dual");
		
		CommonDataObject cd = new CommonDataObject();
		cd = SQLMgr.getData(sbSql.toString());
		if (cd == null) {
		
			cs.setGeneraArchivo("N");
			
		} else {
		
			if (cd.getColValue("GENERA_ARCHIVO_LAB_RX") == null || cd.getColValue("GENERA_ARCHIVO_LAB_RX").trim().equals("")) cs.setGeneraArchivo("N");
			else cs.setGeneraArchivo(cd.getColValue("GENERA_ARCHIVO_LAB_RX"));
			if (cd.getColValue("showIntLabSeq") != null && !cd.getColValue("showIntLabSeq").trim().equals("")) showIntLabSeq = cd.getColValue("showIntLabSeq");
			if (cd.getColValue("intLabSeq") != null && !cd.getColValue("intLabSeq").trim().equals("")) intLabSeq = cd.getColValue("intLabSeq");
			if (cd.getColValue("cdsDefault") != null && !cd.getColValue("cdsDefault").trim().equals("") && !cd.getColValue("cdsDefault").equals("-")) cs.setCodCentroServicio(cd.getColValue("cdsDefault"));
			
		}
	}
	else if (mode.equalsIgnoreCase("view"))
	{
		if (codigo == null || codigo.trim().equals("") || codigo.trim().equals("0")) throw new Exception("La Solicitud no es válida. Por favor intente nuevamente!");
		viewMode = true;

		sbSql.append("select a.codigo, a.admi_secuencia as admiSecuencia, a.admi_pac_codigo as admiPacCodigo, a.admi_pac_fec_nac as admiPacFecNac, nvl(nvl(b.reg_medico,a.med_codigo_resp),' ') as medCodigoResp, a.cod_centro_servicio as codCentroServicio, a.tipo_solicitud as tipoSolicitud, a.origen, a.usuario_creac as usuarioCreac, usuario_mod as usuarioMod, nvl(a.nombre_cta_mensual,' ') as nombreCtaMensual, nvl(a.identificacion_cta_mensual,' ') as identificacionCtaMensual, nvl(to_char(a.fecha_cargo,'dd/mm/yyyy'),' ') as fechaCargo, nvl(a.cupon,' ') as cupon, decode(a.cod_origen,null,' ',''||a.cod_origen) as codOrigen, nvl(a.estado,' ') as estado, nvl(a.pase,' ') as pase, nvl(to_char(a.fecha_solicitud,'dd/mm/yyyy'),' ') as fechaSolicitud, nvl(a.pase_k,' ') as paseK, nvl(a.prioridad,' ') as prioridad, a.pac_id, nvl(a.nombre_medico_externo, ' ') nombreMedExterno from tbl_cds_solicitud a, tbl_adm_medico b, tbl_cds_centro_servicio c where a.med_codigo_resp=b.codigo(+) and a.cod_centro_servicio=c.codigo");
		System.out.println("SQL:\n"+sbSql);
		cs = (CdsSolicitud) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),CdsSolicitud.class);

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function doSubmit(){if(validDate()){setBAction('form0','Guardar');window.frames['itemFrame'].doSubmit();}}
function validDate(){var pacId=document.paciente.pacienteId.value.trim();var noAdmision=document.paciente.admSecuencia.value.trim();var fechaCargo=document.form0.fechaCargo.value.trim();	var valid=getDBData('<%=request.getContextPath()%>','is_valid_trx_date_for_adm('+pacId+','+noAdmision+',\''+fechaCargo+'\')','dual','');
//-1=Not Valid, 0=Adm Not Found, 1=Valid
if(valid==-1){CBMSG.warning('La fecha del cargo está fuera del rango de la fecha de ingreso o egreso...VERIFIQUE!');return false;}else if(valid==0){CBMSG.warning('La Admisión no es válida!');}return true;}
function checkCupon(){if(!window.frames['itemFrame'].allowChanges())document.form0.cupon.checked=!document.form0.cupon.checked;}
function chkCds(){
var xCds =document.form0.codCentroServicio.value;
	if (xCds != ""){if(document.form0.profile)document.form0.profile.value = "";window.frames['itemFrame'].location = '../admision/reg_solicitud_det.jsp?mode=<%=mode%>&fp=<%=fp%>&codigo=<%=codigo%>&procLastLineNo=<%=procLastLineNo%>&modalize=<%=modalize%>&profileCPT=&selectedVal='; }
/*if(!window.frames['itemFrame'].allowChanges()){ document.form0.codCentroServicio.value = document.form0.cod_cds.value;}*/}
function showMedicList(){
  var url = '../common/search_medico.jsp?fp=<%=fp%>&modalize=<%=modalize%>';
<%if(modalize.equalsIgnoreCase("Y")){%>
  parent.showPopWin(url, winWidth*.95, winHeight*.85, null, null, '');
<%} else {%>
  abrir_ventana1(url);
<%}%>
}
function setCds(){var cds = document.form0.codCentroServicio.value;if(cds!=''){<%if(fp.equalsIgnoreCase("cds_solicitud_ima")){%>var x=getDBData('<%=request.getContextPath()%>','reporta_a, tipo_cds, flag_cds','tbl_cds_centro_servicio','codigo='+cds);var arr_cursor = new Array();if(x!=''){arr_cursor = splitCols(x);document.form0.centroServicioReportaA.value = arr_cursor[0];document.form0.centroServicioTipoCds.value = arr_cursor[1];document.form0.flagCds.value = arr_cursor[2];}<%}%>}document.form0.cod_cds.value = document.form0.codCentroServicio.value;}
function setMedExt(val){if(val.trim()==''){document.form0.medCodigoResp.value='';if(document.form0.reg_medico)document.form0.reg_medico.value='';document.form0.medicoNombre.value='';}else{document.form0.reg_medico.value="";document.form0.medCodigoResp.value=-1;document.form0.medicoNombre.value=val;}}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();setCds();document.form0.medCodigoResp.value=document.paciente.medico.value;if(document.form0.reg_medico)document.form0.reg_medico.value=document.paciente.reg_medico.value;document.form0.medicoNombre.value=document.paciente.nombreMedico.value;}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,200);}
var lastProfile="";
function ctrlProfile(obj){
   var profile = document.getElementById("profile").value;
   var selectedVal = "";
   //CBMSG.warning(profile+'  lastProfile='+lastProfile)
   if (profile != '') {
   		//document.form0.codCentroServicio.value = "";
   		selectedVal = obj.options[obj.selectedIndex].text;
		if(lastProfile!='' && lastProfile!=profile){
		window.frames['itemFrame'].location = '../admision/reg_solicitud_det.jsp?mode=<%=mode%>&fp=<%=fp%>&codigo=<%=codigo%>&modalize=<%=modalize%>&procLastLineNo=<%=procLastLineNo%>&profileCPT='+profile+'&profileChanged=true&selectedVal='+selectedVal;
		}else window.frames['itemFrame'].location = '../admision/reg_solicitud_det.jsp?mode=<%=mode%>&fp=<%=fp%>&codigo=<%=codigo%>&modalize=<%=modalize%>&procLastLineNo=<%=procLastLineNo%>&profileCPT='+profile+'&selectedVal='+selectedVal;

   }
   lastProfile=profile;
}

</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=title%>"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td align="right">&nbsp;<% if (!showIntLabSeq.equalsIgnoreCase("N")) { %><label class="RedTextBold">Secuencia Actual de Interface #<%=intLabSeq%> (SOLO INFORMATIVO)</label><% } %></td>
		</tr>
		<tr>
			<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%"><cellbytelabel id="1">Datos del Paciente</cellbytelabel></td>
					<td width="5%" align="right">
            [<font face="Courier New, Courier, mono"><label id="plus0">+</label><label id="minus0"  style="display:none">-</label></font>]&nbsp;
           </td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel0" style="display:none">
			<td>
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
					<jsp:param name="mode" value="<%=mode%>"></jsp:param>
					<jsp:param name="fp" value="<%=fp%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<% if (isOnlySol) fb.appendJsValidation("if(document.form0.medCodigoResp.value==''){CBMSG.warning('Debe seleccionar un Médico para proceder con la Solicitud!');error++;}"); %>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("cod_cds","")%>
<%=fb.hidden("flagCds","")%>
<%=fb.hidden("solicitud","")%>
<%=fb.hidden("cargo","")%>
<%=fb.hidden("onlySol",onlySol)%>
<%=fb.hidden("modalize",modalize)%>
		<tr>
			<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%"><cellbytelabel id="2">Solicitud</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel1">
			<td>
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextRow01">
					<td width="10%" align="right"><cellbytelabel id="3">Fecha</cellbytelabel></td>
					<td width="60%">
					<%String setValidDate = "javascript:validDate();newHeight();";%>
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="fechaCargo"/>
						<jsp:param name="valueOfTBox1" value="<%=cs.getFechaCargo()%>"/>
						<jsp:param name="fieldClass" value="FormDataObjectRequired"/>
						<jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
						<jsp:param name="jsEvent" value="<%=setValidDate%>" />
						</jsp:include>
					</td>
					<td width="10%" align="right"><cellbytelabel id="4">No. Solicitud</cellbytelabel></td>
					<td width="20%"><%=fb.intBox("codigo",cs.getCodigo(),true,false,true,5)%></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel id="5">Origen</cellbytelabel></td>
					<td>
					<%
					String tipo = "";
					sbSql = new StringBuilder();
					sbSql.append("select codigo, codigo ||' - ' || descripcion from tbl_cds_centro_servicio where estado = 'A'");
					if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped")) {

						tipo = "L";
						/*if (isOnlySol) sbSql.append(" and interfaz in ('LIS')");
						else */sbSql.append(" and flag_cds in ('LAB')");

						if (!UserDet.getUserProfile().contains("0")) {

							if (session.getAttribute("_cds") != null) {

								sbSql.append(" and codigo in (");
								sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
								sbSql.append(")");

							} else sbSql.append(" and codigo in (-1)");

						}

					}	else if (fp.equalsIgnoreCase("cds_solicitud_ima")) {

						tipo = "I";
						sbSql.append(" and interfaz in ('RIS')");

					}	else if (fp.equalsIgnoreCase("cds_solicitud_lab_ext")) {

						tipo = "L";
						sbSql.append(" and flag_cds in ('LAB')");

					}
					%>
						<%=fb.select(ConMgr.getConnection(), sbSql.toString(), "codCentroServicio", cs.getCodCentroServicio(),false,false,0,"","","onChange=\"javascript:return chkCds();\"")%>

						<%//=fb.textBox("codCentroServicio",cs.getCodCentroServicio(),true,false,true,5)%>
						<%//=fb.textBox("centroServicioDesc",cs.getCentroServicioDesc(),false,false,true,40)%>
						<%=(fp.equalsIgnoreCase("cds_solicitud_ima"))?fb.textBox("centroServicioReportaA",cs.getCentroServicioReportaA(),false,false,true,5):""%>
						<%=(fp.equalsIgnoreCase("cds_solicitud_ima"))?fb.hidden("centroServicioTipoCds",cs.getCentroServicioTipoCds()):""%>
						<%//=fb.button("btnCds","...",true,(viewMode || fp.equalsIgnoreCase("cds_solicitud_lab_ext")),null,null,"onClick=\"javascript:showCdsList()\"")%>
						<%if (usaPerfilCpt.trim().equals("S")){%>	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Perfil CPT
				<%=fb.select(ConMgr.getConnection(),"select id, nombre from tbl_cdc_cpt_profile where estado = 'A' and tipo = '"+tipo+"' ","profile","",false,false,0,"text10","","onChange=\"javascript:ctrlProfile(this);\"", "","S")%>
					<%}%>
					</td>
<%
if (!fp.equalsIgnoreCase("cds_solicitud_ima"))
{
%>
					<td align="right"><cellbytelabel id="6">Otros Descuentos</cellbytelabel></td>
					<td>
						<%=fb.checkbox("cupon","S",(cs.getCupon().equalsIgnoreCase("S")),viewMode,null,null,"onClick='javascript:checkCupon()'")%>
						<cellbytelabel id="7">Cup&oacute;n de Descuento</cellbytelabel>
					</td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel id="8">M&eacute;dico</cellbytelabel></td>
					<td>
						<%=fb.hidden("medCodigoResp",cs.getMedCodigoResp())%>
						<%=fb.textBox("reg_medico",cs.getMedCodigoResp(),false,false,true,10)%>
						<%=fb.textBox("medicoNombre",cs.getMedicoNombre(),false,false,true,50)%>
						<%=fb.button("btnMedico","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"")%>
					</td>
					<td align="right"><cellbytelabel id="9">Archivo</cellbytelabel></td>
					<td><%=fb.checkbox("generaArchivo","S",(cs.getGeneraArchivo().equals("S")),viewMode)%></td>
				</tr>
				<%=fb.hidden("estado",cs.getEstado())%>
				<%=fb.hidden("fechaSolicitud",cs.getFechaSolicitud())%>
<%
}
else
{
%>
					<td align="right">&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				<%=fb.hidden("cupon",cs.getCupon())%>
				<%=fb.hidden("medCodigoResp",cs.getMedCodigoResp())%>
				<%=fb.hidden("medicoNombre",cs.getMedicoNombre())%>
				<%//=fb.hidden("generaArchivo",cs.getGeneraArchivo())%>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel id="9">Fecha Solicitud</cellbytelabel></td>
					<td><%=fb.textBox("fechaSolicitud",cs.getFechaSolicitud(),false,false,true,10)%></td>
					<td align="right"><cellbytelabel id="10">Estado</cellbytelabel></td>
					<td><%=fb.select("estado","S=SOLICITADO",cs.getEstado(),false,viewMode,0,null,null,null)%></td>
				</tr>
				
				<tr class="TextRow01">
					<td align="right">&nbsp;</td>
					<td>&nbsp;</td>
					<td align="right"><cellbytelabel id="9">Archivo</cellbytelabel></td>
					<td><%=fb.checkbox("generaArchivo","S",(cs.getGeneraArchivo().equals("S")),viewMode)%></td>
				</tr>
<%
}
%>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel id="11">M&eacute;dico Externo</cellbytelabel></td>
					<td>
						<%=fb.textBox("nombre_medico_externo",cs.getNombreMedExterno(),false,false,false,50,"","","onChange=\"javascript:setMedExt(this.value);\"")%>
					</td>
					<td align="right">&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				<tr class="TextPanel">
					<td colspan="4"><cellbytelabel id="12">Datos de los Pacientes de Cuentas Bolsas</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td align="right"><cellbytelabel id="13">Nombre</cellbytelabel></td>
					<td><%=fb.textBox("nombreCtaMensual",cs.getNombreCtaMensual(),false,false,viewMode,50)%></td>
					<td align="right"><cellbytelabel id="14">C&eacute;dula</cellbytelabel></td>
					<td><%=fb.textBox("identificacionCtaMensual",cs.getIdentificacionCtaMensual(),false,false,viewMode,20)%></td>
				</tr>
				<tr>
					<td colspan="4">
						<iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../admision/reg_solicitud_det.jsp?mode=<%=mode%>&fp=<%=fp%>&codigo=<%=codigo%>&procLastLineNo=<%=procLastLineNo%>&modalize=<%=modalize%>"></iframe>
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td align="center">
				<table width="100%" align="center">
				<tr class="TextRow04 Text12Bold">
					<td width="70%"># CPT A SOLICITAR <%=fb.intBox("nRecs","",false,false,true,20)%></td>
					<td width="30%" align="right">TOTAL <%=fb.decBox("total","",false,false,true,20)%></td>
				</tr>
				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td align="right">
				<% if (mode.equalsIgnoreCase("add") && !isOnlySol) { %><%=fb.checkbox("printCargos","S",((imprimirCargo.trim().equals("S"))?true:false),false)%><cellbytelabel>Imprimir Cargos al Guardar</cellbytelabel>&nbsp;&nbsp;|&nbsp;&nbsp;<% } %>
				<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="16">Crear Otro</cellbytelabel>
				<!--<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto -->
				<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel id="17">Cerrar</cellbytelabel>
				<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit()\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
		
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
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
	<% if (!isOnlySol) { %>printCargos();<% }else{%>printOnTheFly();<%}%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fp=<%=fp%>&modalize=<%=modalize%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%><%=isOnlySol?"&onlySol=Y":""%>';
}

function viewMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&fp=<%=fp%>&modalize=<%=modalize%>&codigo=<%=codigo%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%><%=isOnlySol?"&onlySol=Y":""%>';
}
function printCargos(){
<% if (request.getParameter("printCargos") != null && request.getParameter("printCargos").equalsIgnoreCase("S")) { %>
	win=window.open('../facturacion/print_cargo_dev.jsp?noSecuencia=<%=noAdmision%>&pacId=<%=pacId%>&codigo=<%=request.getParameter("cargo")%>&printOF=S&tipoTransaccion=C');
	win.moveTo(0,0);win.resizeTo(screen.availWidth,screen.availHeight);
	return win;
<% } %>
}
function printOnTheFly(){
	<%if ( isOnlySol ){%>
		win = window.open('../expediente/print_hoja_trabajo_lab.jsp?fg=LAB&interfaz=LIS&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codSolicitud=<%=request.getParameter("solicitud")%>&printingOnTheFly=Y');
		win.moveTo(0,0);win.resizeTo(screen.availWidth,screen.availHeight);
		return win;
	<%}%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>