<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Admision adm = new Admision();
int iconHeight = 32;
int iconWidth = 32;
String key = "";
StringBuffer sbSql;
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String change = request.getParameter("change");
String getOneOfTheLastBen = request.getParameter("getOneOfTheLastBen");
String preventPopup = request.getParameter("preventPopup");
String onlySol = request.getParameter("onlySol");
String citasSopAdm = request.getParameter("citasSopAdm");
String citasAmb = request.getParameter("citasAmb");
String catAdm = request.getParameter("cat_adm");
String cdsAdm = request.getParameter("cds_adm");
String fecha="",fechaIngreso="";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String estadoOptions = "A=ACTIVA,P=PRE-ADMISION,E=EN ESPERA";
String contCredOptions = "C=CONTADO, R=CREDITO";
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (tab == null) tab = "0";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view") || fg.equalsIgnoreCase("con_sup")) { viewMode = true; estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA,I=INACTIVA,C=CANCELADA,N=ANULADA"; contCredOptions = "C=CONTADO, R=CREDITO"; }
if (fp == null) fp = "adm";
if (getOneOfTheLastBen==null) getOneOfTheLastBen = "";
if (preventPopup==null) preventPopup = "";
if (onlySol==null) onlySol = "";
if (citasSopAdm==null) citasSopAdm = "N";
if (citasAmb==null) citasAmb = "N";
String _catAdm = "";

if (catAdm==null) catAdm = "";
if (cdsAdm==null) cdsAdm = "";

CommonDataObject hasRisk = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'ADM_EDIT_ESTADO'),'N') as editEstado, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'ADM_CUSTOM_MANDATORY_FIELDS'),'-') as mandatoryFields from dual");
	CommonDataObject cdoE = (CommonDataObject) SQLMgr.getData(sbSql.toString());
	String editEstado = cdoE.getColValue("editEstado");
	if(editEstado == null)editEstado="";

	/*Info. Importante=observAdm*/
	String[] mandatoryFields = {};
	if (!cdoE.getColValue("mandatoryFields").equals("-")) mandatoryFields = cdoE.getColValue("mandatoryFields").toLowerCase().replaceAll(" ","").split(",");

	if (mode.equalsIgnoreCase("add"))
	{
		if (pacId == null || pacId.trim().equals("")) pacId = "0";
		else
		{
			sbSql = new StringBuffer();
			sbSql.append("select to_char(fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, codigo as codigoPaciente, decode(provincia,null,' ',provincia) as provincia, nvl(sigla,' ') as sigla, decode(tomo,null,' ',tomo) as tomo, decode(asiento,null,' ',asiento) as asiento, nvl(d_cedula,' ') as dCedula, nvl(pasaporte,' ') as pasaporte, replace(nombre_paciente,'''','') as nombrePaciente, vip as key, apartado_postal as apartadoPostal,to_char(f_nac,'dd/mm/yyyy') as fechaNacimientoAnt , (select empresa from  tbl_adm_tipo_paciente x where x.vip= a.vip )as aseguradora from vw_adm_paciente a where pac_id = ");
			sbSql.append(pacId);
			Admision pac = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			adm.setFechaNacimiento(pac.getFechaNacimiento());
			adm.setCodigoPaciente(pac.getCodigoPaciente());
			adm.setProvincia(pac.getProvincia());
			adm.setSigla(pac.getSigla());
			adm.setTomo(pac.getTomo());
			adm.setAsiento(pac.getAsiento());
			adm.setDCedula(pac.getDCedula());
			adm.setPasaporte(pac.getPasaporte());
			adm.setNombrePaciente(pac.getNombrePaciente());
			adm.setKey(pac.getKey());
			adm.setPaseK("0");
			adm.setFechaNacimientoAnt(pac.getFechaNacimientoAnt());
			adm.setApartadoPostal(pac.getApartadoPostal());
		}
		noAdmision = "0";
		if(preventPopup.equalsIgnoreCase("Y"))adm.setPacId("");
				else adm.setPacId(pacId);
		adm.setNoAdmision(noAdmision);
		adm.setFechaIngreso(cDateTime.substring(0,10));
		adm.setAmPm(cDateTime.substring(11));
		adm.setFechaPreadmision("");
		adm.setEstado("A");
		adm.setTipoCta("S");
		adm.setCodigoPacienteAdj("0");
		adm.setSecuenciaAdj("-1");

		int nRec = 0;
		StringBuffer sbFilter = new StringBuffer();
		if (!UserDet.getUserProfile().contains("0")) { sbFilter.append(" and d.codigo in (select cod_cds from tbl_cds_usuario_x_cds where usuario='"); sbFilter.append(session.getAttribute("_userName")); sbFilter.append("' and crea_admision='S')"); }
		nRec = CmnMgr.getCount("select count(*) from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+"");
		if (nRec == 1)
		{
			CommonDataObject cdo = SQLMgr.getData("select a.categoria, a.codigo as tipoAdmision, a.descripcion as tipoAdmisionDesc, b.descripcion as categoriaDesc, d.codigo as centroServicio, d.descripcion as centroServicioDesc from tbl_adm_tipo_admision_cia a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_x_cds c, tbl_cds_centro_servicio d where a.categoria=b.codigo and a.categoria=c.cod_categoria and a.codigo=c.cod_tipo and c.cod_centro=d.codigo and d.estado='A' and a.compania="+((String) session.getAttribute("_companyId"))+sbFilter.toString()+" order by d.descripcion, b.descripcion, a.descripcion");
			adm.setCategoria(cdo.getColValue("categoria"));
			adm.setCategoriaDesc(cdo.getColValue("categoriaDesc"));
			adm.setTipoAdmision(cdo.getColValue("tipoAdmision"));
			adm.setTipoAdmisionDesc(cdo.getColValue("tipoAdmisionDesc"));
			adm.setCentroServicio(cdo.getColValue("centroServicio"));
			adm.setCentroServicioDesc(cdo.getColValue("centroServicioDesc"));
		}
	}
	else
	{
		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select to_char((select fecha_nacimiento from vw_adm_paciente where pac_id=a.pac_id),'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2, a.dias_hospitalizados as diasHospitalizados, nvl(a.no_cuenta,'') as noCuenta, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, a.condicion_paciente as condicionPaciente, observ_adm as observAdm, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, coalesce(a.provincia,(select provincia from tbl_adm_paciente where pac_id=a.pac_id)) as provincia, nvl(coalesce(a.sigla,(select sigla from tbl_adm_paciente where pac_id=a.pac_id)),' ') as sigla, coalesce(a.tomo,(select tomo from tbl_adm_paciente where pac_id=a.pac_id)) as tomo, coalesce(a.asiento,(select asiento from tbl_adm_paciente where pac_id=a.pac_id)) as asiento, coalesce(a.d_cedula,(select d_cedula from tbl_adm_paciente where pac_id=a.pac_id)) as dCedula, (select pasaporte from tbl_adm_paciente where pac_id=a.pac_id) as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad, (select replace(nombre_paciente,'''','') as nombre_paciente from vw_adm_paciente where pac_id=a.pac_id) as nombrePaciente, (select sexo from vw_adm_paciente where pac_id=a.pac_id) as sexo, (select descripcion from tbl_adm_categoria_admision where codigo=a.categoria) as categoriaDesc, (select descripcion from tbl_adm_tipo_admision_cia where categoria=a.categoria and codigo=a.tipo_admision and compania=a.compania) as tipoAdmisionDesc, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombreMedico, (select nvl(z.descripcion,'NO TIENE') from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=a.medico and x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) as especialidad, coalesce((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico_cabecera),' ') as nombreMedicoCabecera, (select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio) as centroServicioDesc,a.mes_cta_bolsa mesCtaBolsa, a.oc as oc, a.observ_ayuda as observAyuda, (select apartado_postal from vw_adm_paciente where pac_id=a.pac_id) as apartadoPostal,to_char((select f_nac from vw_adm_paciente where pac_id=a.pac_id),'dd/mm/yyyy') as fechaNacimientoAnt, (select x.empresa from  tbl_adm_tipo_paciente x, vw_adm_paciente p where x.vip= p.vip and p.pac_id=a.pac_id )as aseguradora,(select vip from vw_adm_paciente p where p.pac_id=a.pac_id )as key,nvl((select count(*) from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and estado='A' ),0) as codigoPacienteAdj /* para la cantidad de beneficios activos*/, nvl((select (select cod_reg from tbl_adm_clasif_x_plan_conv where empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi and paquete = 'S') from tbl_adm_beneficios_x_admision z where pac_id = a.pac_id and admision = a.secuencia and prioridad = 1 and nvl(estado,'A') = 'A'  and rownum =1),-1) as secuenciaAdj /*BENEFICIO CON PAQUETE*/ ,(select nvl(reg_medico,codigo) as reg_medico from tbl_adm_medico where codigo = a.medico_cabecera ) as other2,(select nvl(reg_medico,codigo) as reg_medico from tbl_adm_medico where codigo = a.medico ) as other1 from tbl_adm_admision a where a.pac_id=");
		sbSql.append(pacId);
		sbSql.append(" and a.secuencia=");
		sbSql.append(noAdmision);
		sbSql.append(" and a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
		adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);
		fecha = ""+adm.getFechaNacimiento().substring(0,2)+"-"+adm.getFechaNacimiento().substring(3,5)+"-"+adm.getFechaNacimiento().substring(6,10)+"";
		fechaIngreso = ""+adm.getFechaIngreso().substring(0,2)+"-"+adm.getFechaIngreso().substring(3,5)+"-"+adm.getFechaIngreso().substring(6,10)+"";

				if (adm.getCategoria()!=null){
					if (adm.getCategoria().equals("1")) _catAdm = "IN";
					else if (adm.getCategoria().equals("2")) _catAdm = "UR";
					else if (adm.getCategoria().equals("3")) _catAdm = "AM";
					else if (adm.getCategoria().equals("4")) _catAdm = "OUT";
				}

		if (change == null)
		{
		}

		 hasRisk = SQLMgr.getData("select nvl((select case when total >= 25 then 'Y' else 'N' end from tbl_sal_escalas  where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'MO' and rownum = 1),'NOT_FOUND') as has_risk from dual");
	}

	ArrayList alDoc = SQLMgr.getDataList("select a.id, a.description, decode(a.display_area,'P','PACIENTE','X','EXPEDIENTE','A','ADMISION','H','RECURSOS HUMANOS','C','CONTABILIDAD','O','GERENCIA DE OPERACIONES','G','GERENCIA GENERAL',a.display_area) as display_area, decode((select doc_type from tbl_adm_admision_doc where pac_id="+pacId+" and admision="+noAdmision+" and doc_type=a.id),null,'N','Y') as checked from tbl_sec_doc_type a where a.status='A' and a.display_area in ('A','X') order by 3, 2");

	if (hasRisk == null ) hasRisk = new CommonDataObject();

		// TODO: REMOVE
		// citasSopAdm = "N";
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<script>
document.title = 'Admisión - '+document.title;

function doAction(){}

$(function() {
	$('iframe').iFrameResize({
		log: false
	});

	var menu = $( "#menu" ).menu();

	menu.find("#m-generales").addClass("ui-state-focus");

	$("ul#menu a").click(function(e){
		var self = $(this);
		var url = self.data('url');
		var type = self.data('type');
		var cmenu = self.data('cmenu');
		var $items = $(".ui-menu-item");
		var mode = "<%=mode%>";
		var $icontent = $("#i-content");

		if (type == 'generales') {
			$items.removeClass("ui-state-focus");
			menu.find(cmenu).addClass("ui-state-focus");

			$icontent.attr('src', url);
		} else {
			 if (mode != "add") {
					$items.removeClass("ui-state-focus");
					menu.find(cmenu).addClass("ui-state-focus");

					$icontent.attr('src', url);
			 }

		}

		e.preventDefault();
	});

	$(".has-link").click(function(e){
		var self = $(this);
		$(".has-link").addClass("ImageBorder");
		self.removeClass("ImageBorder")
		var $icontent = $("#i-content");
		var url = self.data('urlto');
		if(url) {
			 $icontent.attr('src', url);
		}
	});

// striping iframe title
$("#i-content").on('load', function(iframe) {
	var $icontent = $(this);
	$icontent.contents().find("#_tblCommonTitle").hide()
});

}); //jquery

function printAdm(){abrir_ventana1('../admision/print_admision.jsp?mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function printBarcode(){abrir_ventana('../admision/print_admision_barcode.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>');}
function printLabel(){abrir_ventana('../admision/print_label_unico.jsp?mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function addNewAdmision(){document.location='../admision/admision_config_new_view.jsp?mode=add&preventPopup=Y&citasSopAdm=&citasAmb=&cat_adm=OPD';}
function printCargoNeto(){
    if(hasDBData('<%=request.getContextPath()%>','tbl_fac_detalle_transaccion','pac_id=<%=pacId%> and fac_secuencia=<%=noAdmision%>','')){
       abrir_ventana('../facturacion/print_cargo_dev_neto.jsp?noSecuencia=<%=noAdmision%>&pacId=<%=pacId%>');
    }else CBMSG.warning('La admisión no tiene cargos registrados!');
  }
</script>
<style>
.ui-menu { width: 98%; }
</style>
</head>

<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION"></jsp:param>
</jsp:include>

<%if(!mode.equalsIgnoreCase("add")){%>
	<div style="display:none">
	<jsp:include page="../common/paciente.jsp" flush="true">
			<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
			<jsp:param name="fp" value="<%=fp%>"></jsp:param>
			<jsp:param name="tr" value="<%=fg%>"></jsp:param>
			<jsp:param name="mode" value="<%=mode%>"></jsp:param>
		</jsp:include>
	</div>
<%}%>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
			<table align="center" width="100%" cellpadding="5" cellspacing="0">

				<%if(!mode.equalsIgnoreCase("add")){%>
				<tr>
					<td class="TableBottomBorder TableRightBorder">
						<b>[<%=pacId%>-<%=noAdmision%>] <%=adm.getNombrePaciente()%></b>
					</td>
					<td class="TableBottomBorder" align="right">
							<authtype type='3'>
			<a href="javascript:addNewAdmision()" class="ImageBorder has-link" data-hint="Crear Nueva Admisión"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/crear_nueva_admision.png"></a>
				</authtype>
							<authtype type='57'>
								 <a class="hint hint--left" data-hint="Solicitud de Servicio Ambulatorio de Laboratorio" href="#">
										<img class="ImageBorder has-link" data-urlto="../admision/reg_solicitud.jsp?fp=cds_solicitud_rayx_lab_ped&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&modalize=Y" height="32" width="32" src="../images/ambulatorio_laboratorio.png">
								 </a>
							</authtype>

							<authtype type='59'>
								 <a class="hint hint--left" data-hint="Solicitud de Servicio Ambulatorio de Imagenología" href="#">
										<img class="ImageBorder has-link" data-urlto="../admision/reg_solicitud.jsp?fp=cds_solicitud_ima&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&modalize=Y" height="32" width="32" src="../images/solicitud_de_servicio_ambulatorio_de_imagenologia.png">
								 </a>
							</authtype>

							<authtype type="52">
								<a href="#" class="hint hint--left" data-hint="Honorario Médico">
									<img height="32" width="32" class="ImageBorder has-link" data-urlto="../facturacion/reg_cargo_dev.jsp?noAdmision=<%=noAdmision%>&pacienteId=<%=pacId%>&fg=HON&fPage=general_page" src="../images/honorario_medico.png" alt="Honorario Médico">
								</a>
							</authtype>

							<authtype type="53">
								<a href="#" class="hint hint--left" data-hint="Cargos / Devoluciones de Materiales">
									<img height="32" width="32" class="ImageBorder has-link" data-urlto="../facturacion/reg_cargo_dev_new.jsp?noAdmision=<%=noAdmision%>&pacienteId=<%=pacId%>&fg=PAC&fPage=general_page" src="../images/cargos_devoluciones_de_materiales.png" alt="Cargos / Devoluciones de Materiales">
								</a>
							</authtype>

							<authtype type="54">
								<a href="#" class="hint hint--left" data-hint="Análisis y Facturación">
									<img height="32" width="32" class="ImageBorder has-link" data-urlto="../facturacion/list_analisis_fact.jsp?mode=add&fg=AFA&secuencia=<%=noAdmision%>&codigo=<%=pacId%>&from_new_view=Y&nombre=&fPage=general_page" src="../images/analisis_y_facturacion.png" alt="Análisis y Facturación">
								</a>
							</authtype>

							<authtype type="50">
									<a href="javascript:printBarcode()" class="hint hint--left" data-hint="Imprimir Brazalete">
										<img height="32" width="32" class="ImageBorder" src="../images/imprimir_brazalete.png" alt="Imprimir Brazalete adulto">
									</a>
							 </authtype>
							 <authtype type='79'><a href="javascript:printLabel();" class="hint hint--left" data-hint="Imprimir Label"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/label_pac.png"></a></authtype>

							 <authtype type="2">
									<a href="javascript:printAdm()" class="hint hint--left" data-hint="Imprimir Boleta de Admisión">
										<img height="32" width="32" class="ImageBorder" src="../images/imprimir_boleta_de_admision.png" alt="Imprimir Boleta de Admisión">
									</a>
							 </authtype>
               
               <authtype type='62'>
                  <a href="#" class="hint hint--left" data-hint="Asociar imágenes escaneadas a los documentos del paciente">
                    <img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder has-link" data-urlto="../admision/frame_doc_admision.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=edit&tipo=R" src="../images/asociar_imagenes_escaneadas_a_los_documentos_del_paciente.png"></a>
               </authtype>
				
				 <authtype type='55'>
              <a href="javascript:printCargoNeto()" class="hint hint--left" data-hint="Imprimir Detalles de Cargos Netos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/imprimir_detalles_de_cargo_neto.png"></a>
         </authtype>
         
				 <authtype type='63'>
            <a href="#" class="hint hint--left" data-hint="Observaciones Administrativas">
                <img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder has-link" data-urlto="../expediente/exp_obser_admin.jsp?noAdmision=<%=noAdmision%>&pacId=<%=pacId%>&dob=<%=adm.getFechaNacimiento()%>&codPac=<%=adm.getCodigoPaciente()%>&fp=admision&tipo=A&cat_adm=OPD" src="../images/observaciones_administrativas.png">
            </a>
          </authtype>
          
					</td>
				</tr>
				<%}%>

					<tr>
						<td width="20%" style="vertical-align:top" class="TableRightBorder">

							<ul id="menu">
								<li id="m-generales">
									<a href="#" data-url="../admision/admision_config_generales.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=<%=mode%>&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&preventPopup=<%=preventPopup%>&onlySol=<%=onlySol%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasSopAdm%>&from_new_view=Y&cat_adm=<%=catAdm%>&cds_adm=<%=cdsAdm%>" data-type="generales" data-cmenu="#m-generales">Generales</a>
								</li>

								<%if(!catAdm.trim().equalsIgnoreCase("OPD")){%>
								<li id="m-cama">
									<a href="#" data-url="../admision/admision_config_cama.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&loadInfo=S&fecha_nacimiento=<%=adm.getFechaNacimiento()==null?"":adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()==null?"":adm.getCodigoPaciente()%>&from_new_view=Y" data-cmenu="#m-cama">Camas</a>
								</li>
								<%}%>

								<li id="m-diag">
									<a href="#" data-url="../admision/admision_config_diag.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&loadInfo=S&fecha_nacimiento=<%=adm.getFechaNacimiento()==null?"":adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()==null?"":adm.getCodigoPaciente()%>&from_new_view=Y&cat_adm=<%=catAdm%>&cds_adm=<%=cdsAdm%>" data-cmenu="#m-diag">Diagn&oacute;stico</a>
								</li>
								<li id="m-docs">
									<a href="#" data-url="../admision/frame_doc_admision.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&expStatus=&hidePacHeader=1&loadInfo=S&fecha_nacimiento=<%=adm.getFechaNacimiento()==null?"":adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()==null?"":adm.getCodigoPaciente()%>&from_new_view=Y&cat_adm=<%=catAdm%>&cds_adm=<%=cdsAdm%>" data-cmenu="#m-docs">Documentos</a>
								</li>
								<li id="m-beneficios">
									<a href="#" data-url="../admision/admision_config_benef.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&getOneOfTheLastBen=<%=getOneOfTheLastBen%>&loadInfo=S&fecha_nacimiento=<%=adm.getFechaNacimiento()==null?"":adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()==null?"":adm.getCodigoPaciente()%>&from_new_view=Y&aseguradora=<%=adm.getAseguradora()==null?"":adm.getAseguradora()%>&tipo_cta=<%=adm.getTipoCta()==null?"":adm.getTipoCta()%>&adm_key=<%=adm.getKey()%>&cat_adm=<%=catAdm%>&cds_adm=<%=cdsAdm%>" data-cmenu="#m-beneficios">Beneficios</a>
								</li>
								<li id="m-resp">
									<a href="#" data-url="../admision/admision_config_resp.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&loadInfo=S&fecha_nacimiento=<%=adm.getFechaNacimiento()==null?"":adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()==null?"":adm.getCodigoPaciente()%>&from_new_view=Y&cat_adm=<%=catAdm%>&cds_adm=<%=cdsAdm%>" data-cmenu="#m-resp">Responsables</a>
								 </li>
							</ul>
						</td>

						<td width="80%" style="vertical-align:top">
							<iframe id="i-content" name="i-content" frameborder="0" width="99%" height="580px" src="../admision/admision_config_generales.jsp?fg=<%=fg%>&fp=<%=fp%>&mode=<%=mode%>&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&preventPopup=<%=preventPopup%>&onlySol=<%=onlySol%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasSopAdm%>&loadInfo=S&fecha_nacimiento=<%=adm.getFechaNacimiento()==null?"":adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()==null?"":adm.getCodigoPaciente()%>&from_new_view=Y&cat_adm=<%=catAdm%>&cds_adm=<%=cdsAdm%>" scroll="no"></iframe>
						</td>

			</table>
	</td>
</tr>
</table><!-- main table -->



</body>
</html>
<%
}//GET
%>