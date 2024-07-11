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
<jsp:useBean id="iCama" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCama" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iDiag" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDiag" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iBen" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vBen" scope="session" class="java.util.Vector"/>
<jsp:useBean id="iResp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vResp" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vCamaNew" scope="session" class="java.util.Vector"/>

<%
/**
==================================================================================
ADM3309
ADM3310_CON_SUP
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Admision adm = new Admision();
Admision resp = new Admision();
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
String fecha="",fechaIngreso="";
int camaLastLineNo = 0;
int diagLastLineNo = 0;
int docLastLineNo = 0;
int benLastLineNo = 0;
int respLastLineNo = 0;
int prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String estadoOptions = "A=ACTIVA,P=PRE-ADMISION,E=EN ESPERA";//,S=ESPECIAL se quita estado, soliciado el Mon, Aug 20, 2012 9:28 am por catherine.
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

CommonDataObject hasRisk = new CommonDataObject();

if (request.getParameter("camaLastLineNo") != null) camaLastLineNo = Integer.parseInt(request.getParameter("camaLastLineNo"));
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
if (request.getParameter("respLastLineNo") != null) respLastLineNo = Integer.parseInt(request.getParameter("respLastLineNo"));

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

	boolean isRead = false;
	if (!editEstado.trim().equals("S") && mode.equals("edit")) isRead = true;
	boolean statusOnlyDisplay = false;
	if ((isRead || viewMode) && !fg.equalsIgnoreCase("con_sup")) {
		statusOnlyDisplay = true;
		estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA,I=INACTIVA,C=CANCELADA,N=ANULADA";
	}

	/*Info. Importante=observAdm*/
	String[] mandatoryFields = {};
	if (!cdoE.getColValue("mandatoryFields").equals("-")) mandatoryFields = cdoE.getColValue("mandatoryFields").toLowerCase().replaceAll(" ","").split(",");

	if (mode.equalsIgnoreCase("add"))
	{
		iCama.clear();
		vCama.clear();
		iDiag.clear();
		vDiag.clear();
		iDoc.clear();
		vDoc.clear();
		iBen.clear();
		vBen.clear();
		iResp.clear();
		vResp.clear();
		vCamaNew.clear();
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
		sbSql.append("select to_char((select fecha_nacimiento from vw_adm_paciente where pac_id=a.pac_id),'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2, a.dias_hospitalizados as diasHospitalizados, nvl(a.no_cuenta,'') as noCuenta, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, a.condicion_paciente as condicionPaciente, observ_adm as observAdm, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, coalesce(a.provincia,(select provincia from tbl_adm_paciente where pac_id=a.pac_id)) as provincia, nvl(coalesce(a.sigla,(select sigla from tbl_adm_paciente where pac_id=a.pac_id)),' ') as sigla, coalesce(a.tomo,(select tomo from tbl_adm_paciente where pac_id=a.pac_id)) as tomo, coalesce(a.asiento,(select asiento from tbl_adm_paciente where pac_id=a.pac_id)) as asiento, coalesce(a.d_cedula,(select d_cedula from tbl_adm_paciente where pac_id=a.pac_id)) as dCedula, (select pasaporte from tbl_adm_paciente where pac_id=a.pac_id) as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad, (select replace(nombre_paciente,'''','') as nombre_paciente from vw_adm_paciente where pac_id=a.pac_id) as nombrePaciente, (select sexo from vw_adm_paciente where pac_id=a.pac_id) as sexo, (select descripcion from tbl_adm_categoria_admision where codigo=a.categoria) as categoriaDesc, (select descripcion from tbl_adm_tipo_admision_cia where categoria=a.categoria and codigo=a.tipo_admision and compania=a.compania) as tipoAdmisionDesc, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombreMedico, (select nvl(z.descripcion,'NO TIENE') from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=a.medico and x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) as especialidad, coalesce((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico_cabecera),' ') as nombreMedicoCabecera, (select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio) as centroServicioDesc,a.mes_cta_bolsa mesCtaBolsa, a.oc as oc, a.observ_ayuda as observAyuda, (select apartado_postal from vw_adm_paciente where pac_id=a.pac_id) as apartadoPostal,to_char((select f_nac from vw_adm_paciente where pac_id=a.pac_id),'dd/mm/yyyy') as fechaNacimientoAnt, (select x.empresa from  tbl_adm_tipo_paciente x, vw_adm_paciente p where x.vip= p.vip and p.pac_id=a.pac_id )as aseguradora,(select vip from vw_adm_paciente p where p.pac_id=a.pac_id )as key,nvl((select count(*) from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.secuencia and estado='A' ),0) as codigoPacienteAdj /* para la cantidad de beneficios activos*/, nvl((select (select cod_reg from tbl_adm_clasif_x_plan_conv where empresa = z.empresa and convenio = z.convenio and plan = z.plan and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi and paquete = 'S') from tbl_adm_beneficios_x_admision z where pac_id = a.pac_id and admision = a.secuencia and prioridad = 1 and nvl(estado,'A') = 'A'  and rownum =1),-1) as secuenciaAdj /*BENEFICIO CON PAQUETE*/ ,(select nvl(reg_medico,codigo) as reg_medico from tbl_adm_medico where codigo = a.medico_cabecera ) as other2,(select nvl(reg_medico,codigo) as reg_medico from tbl_adm_medico where codigo = a.medico ) as other1, to_char(a.fnac_madre,'dd/mm/yyyy') as fNacMadre,a.cpac_madre as cPacMadre,a.admi_madre as admiMadre ,a.pac_id_madre as pacIdMadre,a.unidad_orgni as unidadOrgni,a.compania_uorg as companiaUorg  from tbl_adm_admision a where a.pac_id=");
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
			iCama.clear();
			vCama.clear();
			iDiag.clear();
			vDiag.clear();
			iDoc.clear();
			vDoc.clear();
			iBen.clear();
			vBen.clear();
			iResp.clear();
			vResp.clear();
			vCamaNew.clear();
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
<%@ include file="../common/tab.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<script>
document.title = 'Admisión - '+document.title;

function showPacienteList()
{
	abrir_ventana1('../common/search_paciente.jsp?fp=admision');
}

function showMedicoList(opt,k)
{
	if (opt.toLowerCase() == 'especialidad') abrir_ventana1('../common/search_medico.jsp?fp=admision_medico_esp&fg=admision');
	else if (opt.toLowerCase() == 'cabecera') abrir_ventana1('../common/search_medico.jsp?fp=admision_medico_cab&fg=admision');
}

function showTipoAdmisionList(tipo)
{
	var fg = typeof tipo != "undefined" ? 'special':'';
	var categoria= document.form0.categoria.value;
	abrir_ventana1('../common/search_tipo_admision.jsp?fp=admision&pac_id=<%=pacId%>&admision=<%=noAdmision%>&fg='+fg+'&catCode='+categoria);
}

function clearMedico(opt)
{
	if (opt.toLowerCase() == 'cabecera')
	{
		document.form0.medicoCabecera.value = '';
		document.form0.medicoCabecera_reg.value = '';
		document.form0.nombreMedicoCabecera.value = '';
	}
	else if (opt.toLowerCase() == 'responsable')
	{
		document.form5.medico.value = '';
		document.form5.reg_medico.value = '';
		document.form5.nombreMedico.value = '';
	}
}

function setPacTypeImg(){
	var img='blank.gif';
	var pacType='';
	if(document.form0.key.value=='D'){img='distinguido.gif';pacType='DISTINGUIDO';}
	else if(document.form0.key.value=='S'){img='vip.gif';pacType='V.I.P.';}
	else if(document.form0.key.value=='M'){img='medico.gif';pacType='MEDICO DEL STAFF';}
	else if(document.form0.key.value=='J'){img='junta_directiva.gif';pacType='JUNTA DIRECTIVA';}
	if(pacType.trim()!='')CBMSG.warning('<%=UserDet.getName()%>:\nRecuerda, este es un cliente '+pacType+', gracias!!');
	document.getElementById('pacTypeImg').src='../images/'+img;
}
function doAction()
{
	<% if (fp.trim().equalsIgnoreCase("hdadmision")){%>
		maximizeWin();
		if (parent.opener){
				//parent.opener.close();
			parent.window.opener.close();
			}
	<%}else{%>
		<% /*if(!preventPopup.equalsIgnoreCase("Y")){*/ if(mode.equals("edit")){%>
			setTimeout(function(){loadXtraInfo()},1000);
						showSolBtn();
		<%}else{%> loadXtraInfo(); <%}/*}*/%>
	<%}%>

	<%if(mode.equals("add") && (pacId == null || pacId.equals(""))){%>
	showPacienteList();
	<%}%>
	setPacTypeImg();
	if(document.form0.estado)validateStatus();
<%
	for (int i=1; i<=iResp.size(); i++)
	{
%>
	showHide('51.<%=i%>');
	showHide('51.<%=i%>.0');//ingresos
	showHide('51.<%=i%>.1');//generales
	showHide('51.<%=i%>.2');//observación
<%
	}
%>
}

function showSolBtn(){
	var f = getDBData('<%=request.getContextPath()%>','interfaz','tbl_cds_centro_servicio','codigo = <%=adm.getCentroServicio()%>','');
	if (f){
		 f = f.toLowerCase();
		 var o = $("#sol-"+f);
		 var urlTo = o.data('urlto');
		 o.show();
		 o.click(function(){abrir_ventana(urlTo)});
	}
}

function isFirstPriority(k)
{
	if(eval('document.form4.convenioSolEmp'+k).checked&&eval('document.form4.prioridad'+k).value!=1 && eval('document.form4.status'+k).value!="D")
	{
		eval('document.form4.convenioSolEmp'+k).checked=false;
		CBMSG.warning('Sólo se permite seleccionar cuando es prioridad 1!');
		return false;
	}
}

function hasBeneficioEmpleado()
{
	/*
	var benSize=parseInt(document.form4.benSize.value,10);
	for(i=1;i<=benSize;i++)
	{
		if(eval('document.form4.empresa'+i).value=='81')return true;
	}
	*/
	return false;
}

function pendingBalanceConfirmation(tab)
{
	var proceed = true;
	eval('document.form'+tab+'.proceedPendingBalance').value = 'Y';
	/*var pacId = document.form0.pacId.value;
	var noAdmision = document.form0.noAdmision.value;
	var retVal = '';
	var facturadoA = 'P';
	if (noAdmision != 0 && hasBeneficioEmpleado()) facturadoA = 'E';
	if(pacId !=''){
	retVal = getDBData('<%=request.getContextPath()%>','trim(to_char(nvl(sum(nvl(a.grang_total,0)+ nvl(y.ajustes,0)-nvl(b.pagos,0)),0),\'99999990.00\')),count(a.codigo)','tbl_fac_factura a,(select sum(dp.monto) pagos,dp.compania,dp.fac_codigo from tbl_cja_detalle_pago dp where exists ( select 1 from tbl_cja_transaccion_pago where compania =dp.compania and anio =dp.tran_anio and codigo = dp.codigo_transaccion and rec_status<> \'I\' )group by dp.compania,dp.fac_codigo)b,(select nvl(sum(decode(z.lado_mov,\'D\',z.monto,\'C\',-z.monto)),0)ajustes,z.compania,z.factura from vw_con_adjustment_gral z where z.tipo_doc =\'F\' group by z.compania,z.factura ) y ','a.codigo=b.fac_codigo(+)  and a.compania =b.compania(+) and a.pac_id='+pacId+' and a.estatus <> \'A\' and a.facturar_a=\''+facturadoA+'\'  and a.codigo=y.factura(+) and a.compania =y.compania(+)','');
	var deuda = parseFloat(retVal.substring(0,retVal.indexOf('|')));
	var nFactura = retVal.substring(retVal.indexOf('|')+1);

	if (deuda > 0)
	{
		proceed = confirm('El Paciente tiene '+nFactura+' facturas con monto pendientes que ascienden a '+deuda.toFixed(2)+'\n'+'El paciente tiene deuda pendiente con la Clínica, ¿Desea continuar con la admisión bajo su responsabilidad?');
		if (proceed) eval('document.form'+tab+'.proceedPendingBalance').value = 'Y';
		else eval('document.form'+tab+'.proceedPendingBalance').value = 'N';
	}
	else eval('document.form'+tab+'.proceedPendingBalance').value = '';
	}*/
	return proceed;
}
function checkTipoCta()
{
	var pacId = document.form0.pacId.value;
	var admision = document.form0.noAdmision.value;
	var tipoCta = document.form0.tipoCta.value;
	var tipoCtaOld = document.form0.tipoCtaOld.value;
	var msg = '';
	if(tipoCta!=tipoCtaOld){if(parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_beneficios_x_admision','pac_id='+pacId+' and admision='+admision+' and estado=\'A\'',''),10)>0)msg='El paciente ya tiene Beneficios ACTIVOS asignados!';}
		if(msg!='')
	{
		CBMSG.warning(msg);
		document.form0.tipoCta.value=document.form0.tipoCtaOld.value;
		//return true;
	}

}
function hasActiveAdmision()
{
	var pacId = document.form0.pacId.value;
	var categoria = document.form0.categoria.value;
	var centroServicio = document.form0.centroServicio.value;
	var admision = document.form0.noAdmision.value;
	var tipoCta = document.form0.tipoCta.value;
	var tipoCtaOld = document.form0.tipoCtaOld.value;
	var estadoDsp = document.form0.estadoDsp.value;
	var msg = '';
	if(pacId !=''){

		if (estadoDsp=='N') {

			if(categoria==1){
				if(parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision','pac_id='+pacId+' and categoria='+categoria+' and estado=\'A\' and secuencia <>'+admision,''),10)><%=(mode.equalsIgnoreCase("add"))?"0":"0"%>)msg='El paciente ya tiene una admisión ACTIVA!';
			}else{
				if(categoria !='' && centroServicio !=''){
					if(parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision','pac_id='+pacId+' and categoria='+categoria+' and estado=\'A\' and centro_servicio='+centroServicio+' and secuencia <>'+admision,''),10)><%=(mode.equalsIgnoreCase("add"))?"0":"0"%>)msg='El paciente ya tiene una admisión de esta área ACTIVA!';
				}else msg='Seleccione categoria y tipo de admisión!';
			}

			if(tipoCta!=tipoCtaOld && msg==''){if(parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_beneficios_x_admision','pac_id='+pacId+' and admision='+admision+' and estado=\'A\'',''),10)>0)msg='El paciente ya tiene Beneficios ACTIVOS asignados!';}

			if(msg=='')return false;
			else{
				CBMSG.warning(msg);
				return true;
			}

		}

	}
}

function validateStatus()
{
	var pacId = document.form0.pacId.value;
	var msg ='';
	if(document.form0.estado.value=='P')
	{
		<%if(mode.equals("edit")){%>

		if(parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(decode(b.tipo_transaccion,\'C\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) + nvl(sum(decode(b.tipo_transaccion,\'H\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) - nvl(sum(decode(b.tipo_transaccion,\'D\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0)','tbl_fac_transaccion a, tbl_fac_detalle_transaccion b','a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.compania=b.compania and a.tipo_transaccion=b.tipo_transaccion and a.codigo=b.fac_codigo and a.admi_secuencia=<%=noAdmision%> and a.pac_id=<%=pacId%>',''))>0)msg+='\n- La admisión tiene cargos registrados. Debe devolver los cargos para que la admisión quede en cero';
		if(msg.length>0){CBMSG.warning('La Admisión no se puede cambiar de estado por las siguientes razones:'+msg);
		document.form0.estado.value='<%=adm.getEstado()%>';

		}/*else{document.form0.fechaPreadmision.value='<%=cDateTime%>';
		document.form0.fechaPreadmision.className='FormDataObjectRequired';
		document.form0.resetfechaPreadmision.disabled=false;}*/
		<%}else{%>
		//document.form0.fechaIngreso.value='';
		//document.form0.amPm.value='';
		//document.form0.fechaPreadmision.value='<%=cDateTime%>';
		document.form0.fechaPreadmision.className='FormDataObjectRequired';
		document.form0.resetfechaPreadmision.disabled=false;
<%}
//if (fg.equalsIgnoreCase("con_sup"))
//{
%>
		document.form0.fechaIngreso.readOnly=true;
		document.form0.fechaIngreso.className='FormDataObjectDisabled';
		document.form0.resetfechaIngreso.disabled=true;
		document.form0.amPm.readOnly=true;
		document.form0.amPm.className='FormDataObjectDisabled';
		document.form0.resetamPm.disabled=true;
		document.form0.fechaPreadmision.readOnly=false;

<%
//}
%>
	}
	else
	{
		<%if(mode.equals("add")){%>
		document.form0.fechaIngreso.value='<%=cDateTime.substring(0,10)%>';
		document.form0.amPm.value='<%=cDateTime.substring(11)%>';
		<%}%>
		document.form0.fechaPreadmision.value='';
<%
//if (fg.equalsIgnoreCase("con_sup"))
//{
%>
		//document.form0.fechaIngreso.readOnly=false;
		document.form0.fechaIngreso.className='FormDataObjectRequired';
		document.form0.resetfechaIngreso.disabled=false;
		document.form0.amPm.readOnly=false;
		document.form0.amPm.className='FormDataObjectRequired';
		document.form0.resetamPm.disabled=false;
		document.form0.fechaPreadmision.readOnly=true;
		document.form0.fechaPreadmision.className='FormDataObjectDisabled';
		document.form0.resetfechaPreadmision.disabled=true;
<%
//}
%>
	<%if(mode.equals("edit")){%>
	<%if(adm.getCategoria().equals("1")){%>
	if(document.form0.estado.value=='E'){
		CBMSG.warning('El proceso correcto para que una admision HOSPITALIZADA cambie a ESPERA es darle salida al paciente!');
		document.form0.estado.value='<%=adm.getEstado()%>';
	}
	<%}%>

	if(document.form0.estadoOld.value=='E' && document.form0.estado.value=='P')
	{
		CBMSG.warning('No puede cambiar la admision de espera a Pre-admision !');
		document.form0.estado.value='<%=adm.getEstado()%>';
	}
	<%}%>

	}
}

function chkEstadoAdm(){<%if(mode.trim().equals("edit")){%>if(hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','secuencia=<%=noAdmision%> and pac_id=<%=pacId%> and estado=\'E\'','')){CBMSG.warning('La admisión está En Espera. No puede asignarle cama!');return false;}else return true;<%}else{%>return true;<%}%>}
function hasMotherAdmision()
{
	var categoria = document.form0.categoria.value;
	var estado = document.form0.estado.value;
	var tipoAdmision = document.form0.tipoAdmision.value;
	var nRec = -1;

	var ct_tp_adm = getDBData('<%=request.getContextPath()%>','param_value','tbl_sec_comp_param','param_name=\'CT_TP_ADM\' and compania in (-1,<%=(String) session.getAttribute("_companyId")%>)','');
	var cat =ct_tp_adm.substr(0,1);//1|4|5
	var mat =ct_tp_adm.substr(4,1);
	var neo =ct_tp_adm.substr(2,1);

	if (estado == 'A' && categoria == cat && tipoAdmision == neo)
	{
		var provincia = document.form0.provincia.value.trim();
		var sigla = document.form0.sigla.value.trim();
		var tomo = document.form0.tomo.value.trim();
		var asiento = document.form0.asiento.value.trim();
		var pasaporte = document.form0.pasaporte.value.trim();


		if (provincia != '' && sigla != '' && tomo != '' && asiento != '')
		{
			 if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento)){CBMSG.warning('Valores invalidos en numero de cedula! Revise..')}else{
		 nRec = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision a, tbl_adm_paciente b','a.estado=\'A\' and a.categoria='+cat+' and a.tipo_admision='+mat+' and a.pac_id=b.pac_id and b.provincia='+provincia+' and b.sigla=\''+sigla+'\' and b.tomo='+tomo+' and b.asiento='+asiento,''),10);}}
		else if (pasaporte != ''){ nRec = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision a, tbl_adm_paciente b','a.estado=\'A\' and a.categoria='+cat+' and a.tipo_admision='+mat+' and a.pac_id=b.pac_id and b.pasaporte=\''+pasaporte+'\'',''),10);}
		if (nRec == 0)
		{
			CBMSG.warning('No se ha podido establecer enlace entre la admisión del Neonato y la Madre.  Es probable que el número de identificación (Cédula/Pasaporte) del Neonato no es igual al de la madre!');
			return false;
		}
		else if (nRec == 1) return true;
		else if (nRec > 1)
		{
			CBMSG.warning('Más de una admisión de la madre coincide con la identificación (Cédula/Pasaporte) del Neonato!');
			return false;
		}
	}
	return true;
}

function hasEmployeeDebt()
{
	var tipoCta=document.form0.tipoCta.value;
	var responsabilidad=document.form0.responsabilidad.value;

	if(tipoCta=='E'&&(responsabilidad=='P'||responsabilidad=='O'))
	{
		var provincia=document.form0.provincia.value;
		var sigla=document.form0.sigla.value;
		var tomo=document.form0.tomo.value;
		var asiento=document.form0.asiento.value;
		if(provincia.trim()==''||sigla.trim()==''||tomo.trim()==''||asiento.trim()=='')
		{
			CBMSG.warning('La Cédula no es válida!');
			return false;
		}
		else
		{
			var c=splitCols(getDBData('<%=request.getContextPath()%>','primer_nombre||\' \'||decode(sexo,\'F\',decode(apellido_casada,null,primer_apellido,decode(usar_apellido_casada,\'S\',\'DE \'||apellido_casada,primer_apellido)),primer_apellido), num_empleado, get_porc_endeudamiento(emp_id)','tbl_pla_empleado','provincia='+provincia+' and sigla=\''+sigla+'\' and tomo='+tomo+' and asiento='+asiento+' and estado!=3',''));
			if(c==null)
			{
				CBMSG.warning('ATENCION: La Cédula indicada no corresponde a ningún empleado válido, si se trata del dependiente\n de un empleado por favor indicar en la sección de Beneficios el empleado del cual depende!');
				return false;
			}
			else
			{
				var empName=c[0];
				var empNo=c[1];
				var empPerc=parseFloat(c[2]);
				//CBMSG.warning('Empleado #'+empNo+', '+empName+' '+empPerc);
				var porcPermitido=getDBData('<%=request.getContextPath()%>','decode(porc_endeudamiento,0,50,porc_endeudamiento)','tbl_pla_parametros','cod_compania=<%=session.getAttribute("_companyId")%> and estado=\'A\'','');
				if(porcPermitido.trim()=='')porcPermitido=50;
				else porcPermitido=parseFloat(porcPermitido);
				if(empPerc>porcPermitido)
				{
					CBMSG.warning('ATENCION USUARIO: El empleado no es sujeto de crédito por no tener capacidad de descuento.Debe pagar al contado la totalidad de la factura. Consultar a su SUPERVISOR!');
					return false;
				}
			}
		}
	}
	return true;
}

function isAdmisionInactive()
{
	<%if(!fp.trim().equals("fact")){%>
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','secuencia=<%=noAdmision%> and pac_id=<%=pacId%> and estado=\'I\'',''))
	{
		CBMSG.warning('La admisión está INACTIVA!');
		return true;
	}
	else return false;
	<%}%>
}


function printAdm(){abrir_ventana1('../admision/print_admision.jsp?mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');}
function printBarcode(){abrir_ventana('../admision/print_admision_barcode.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>');}
function getMedicDetail(code,type){<%if(!preventPopup.equalsIgnoreCase("Y")){%>var name='',esp='',id='',reg='';if(code!=undefined&&code!=null&&code!=''&&type!=undefined&&type!=null&&type!=''){var c=splitCols(getDBData('<%=request.getContextPath()%>','a.primer_nombre||decode(a.segundo_nombre,null,\'\',\' \'||a.segundo_nombre)||\' \'||a.primer_apellido||decode(a.segundo_apellido,null,\'\',\' \'||a.segundo_apellido)||decode(a.sexo,\'F\',decode(a.apellido_de_casada,null,\'\',\' \'||a.apellido_de_casada)) as nombre, nvl((select y.descripcion from tbl_adm_medico_especialidad z,tbl_adm_especialidad_medica y where z.medico=a.codigo and z.secuencia=1 and z.especialidad=y.codigo),\'NO TIENE\') as especialidad, a.codigo','tbl_adm_medico a',"a.estado = 'A' and nvl(a.reg_medico,a.codigo) = '"+code+"'",''));if(c!=null){name=c[0];esp=c[1];id=c[2];reg=c[3];}else{CBMSG.warning('El médico no existe o está inactivo.');if(type=='adm'){document.form0.reg_medico.value='';document.form0.medico.value='';document.form0.nombreMedico.value='';}else if(type=='cab'){document.form0.medicoCabecera_reg.value='';document.form0.medicoCabecera.value='';document.form0.nombreMedicoCabecera.value='';}}}if(type=='adm'){document.form0.medico.value=id;document.form0.reg_medico.value=reg;document.form0.nombreMedico.value=name;document.form0.especialidad.value=esp;}else if(type=='cab'){document.form0.medicoCabecera.value=id;document.form0.medicoCabecera_reg.value=reg;document.form0.nombreMedicoCabecera.value=name;}<%}%>}

function viewScan(){
	abrir_ventana("../admision/asociar_escaneados_a_doc_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>");
}
function notAValidDate(){
	 var preAdmDate = document.getElementById("fechaPreadmision").value;
	 if (preAdmDate!="") {
			 if(getDBData("<%=request.getContextPath()%>","count(*)","dual"," to_date('"+preAdmDate+"','dd/mm/yyyy hh12:mi AM') >= to_date(to_char(sysdate,'dd/mm/yyyy hh12:mi AM'),'dd/mm/yyyy hh12:mi AM')","") > 0)
		 return false;
		 else {
				CBMSG.warning("Por favor verifique que la fecha/hora de la pre admisión no sea una fecha anterior a la de hoy [ Fecha y Hora del sistema ] !");
			return true;
		 }
	 }
	 return false;
}

function tabFunctions(tab){
	var iFrameName = '', iFrameLocation = '';
	if(tab==1 && document.form0.camaShow.value=='N'){
		iFrameName='camaFrame';
		iFrameLocation = '../admision/admision_config_cama.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&loadInfo=S';
		document.form0.camaShow.value='S';
	} else if(tab==2 && document.form0.diagShow.value=='N'){
		iFrameName='diagFrame';
		iFrameLocation = '../admision/admision_config_diag.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&loadInfo=S';
		document.form0.diagShow.value='S';
	} else if(tab==3 && document.form0.doctShow.value=='N'){
		iFrameName='docFrame';
		iFrameLocation = '../admision/frame_doc_admision.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&expStatus=&loadInfo=S&hidePacHeader=1';
		document.form0.doctShow.value='S';
	} else if(tab==4 && document.form0.beneShow.value=='N'){
		iFrameName='benefFrame';
		iFrameLocation = '../admision/admision_config_benef.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&loadInfo=S&getOneOfTheLastBen=<%=getOneOfTheLastBen%>';
		document.form0.beneShow.value='S';
	} else if(tab==5 && document.form0.respShow.value=='N'){
		iFrameName='respFrame';
		iFrameLocation = '../admision/admision_config_resp.jsp?fp=admision_new&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&loadInfo=S';
		document.form0.respShow.value='S';
	}
		<%if(citasSopAdm.equals("S") || citasSopAdm.equals("Y")){%>
			else if (tab==6){
				iFrameName='citaFrame';
		iFrameLocation = '../cita/quirofano_list.jsp?citasSopAdm=<%=citasSopAdm%>&loadInfo=N&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=adm.getNombreMedico()%>&medico=<%=adm.getMedico()%>&forma_reserva=P&provincia=<%=adm.getProvincia()%>&sigla=<%=adm.getSigla()%>&tomo=<%=adm.getTomo()%>&asiento=<%=adm.getAsiento()%>&d_cedula=<%=adm.getDCedula()%>&pasaporte=<%=adm.getPasaporte()==null?"":adm.getPasaporte()%>&tipo_paciente=<%=_catAdm%>&f_nac=<%=adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()%>&sexo=<%=adm.getSexo()%>';
		}
		<%}%>
	<%if(citasAmb.equals("S")){%>
			else if (tab==7){
				iFrameName='citaAmbFrame';
		iFrameLocation = '../cita/cita_list.jsp?citasAmb=S&loadInfo=N&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=adm.getNombreMedico()%>&medico=<%=adm.getMedico()%>&forma_reserva=P&provincia=<%=adm.getProvincia()%>&sigla=<%=adm.getSigla()%>&tomo=<%=adm.getTomo()%>&asiento=<%=adm.getAsiento()%>&d_cedula=<%=adm.getDCedula()%>&pasaporte=<%=adm.getPasaporte()==null?"":adm.getPasaporte()%>&tipo_paciente=<%=_catAdm%>&fechaNacimiento=<%=adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()%>&sexo=<%=adm.getSexo()%>';
		}
		<%}%>
	if(iFrameLocation!='')window.frames[iFrameName].location=iFrameLocation;
}

function loadXtraInfo(){
	 var pacId = $("#pacId").val();
	 var _status = $("#ajaxStatus").val();
	 var noAdmision = $("#form0 #noAdmision").val();
	 var catAdm = $("#form0 #categoria").val();
	 var cds = $("#form0 #centroServicio").val();
	 var facturadoA = 'P';
	 var loaded = "0";
	 var $cont,inff=adma=rie=0;

	 if (noAdmision != 0 && hasBeneficioEmpleado()) facturadoA = 'E';
	 if (pacId && pacId != "0"){
				if(_status=="OK")loaded = "1";

				$.ajax({
					url: '../common/set_extra_info.jsp?fp=admision&pacId='+pacId+'&status='+loaded+'&facturadoA='+facturadoA+'&mode=<%=mode%>&noAdmision=<%=noAdmision%>&catAdm='+catAdm+'&cds='+cds+'&compania=<%=(String)session.getAttribute("_companyId")%>',
					cache: false,
					dataType: "html"
				}).done(function(data){
						 $("#container").show(0);
						 $("#indicator").show(0);
						 $('#pacInfoWrapper').html("");

						$("#ajaxStatus").val("OK");
						$("#saldoPendiente").hide(0);
						$("#admActivas").hide(0);
						$("#admActivas").hide(0);

						setTimeout(function(){
								$("#indicator").hide(0);
							$cont = $('#pacInfoWrapper').css("text-align","left").html(data);
							$("#iHide").show(0);

							inff = $cont.find("#inff").length;
							inffVal = $cont.find("#inff").val() | 0;
							adma = $cont.find("#adma").length;
							rie  = $cont.find("#rie").length;
							showHideInfo(inff, adma,rie);

							$("#accordion").accordion({
								icons:false,
								heightStyle: "content"
							});
														if (inffVal) $cont.find("#inff-hder").click();
														else $cont.find("#adm-hder").click();
						},2000);

				}).fail(function(jqXHR, textStatus, errorThrown){
									$("#container").show(0);
					$('#pacInfoWrapper').html("Error tratando de obtener informaciones extras del paciente.<br>Causa: <strong>" + errorThrown + "</strong>");
				});
	}

}
var showHideInfo = function(inff, adma,rie){
	$("#saldoPendiente").hide(0);
	$("#admActivas").hide(0);
	$("#admActivas").hide(0);
	if (inff>0) $("#saldoPendiente").show(0);
	if (adma>0) $("#admActivas").show(0);
	if (rie>0) $("#pacCondicion").show(0);
}
$(document).ready(function(){

	serveStaticTooltip({toolTipContainer:"#container",track:true,ajaxContent:"ADM_CONF"});

	$("#container").on("dblclick",function(){
		 $(this).hide(0);
	 $("#iShow").show(0);
		 $("#iHide").hide(0);
	});
	$("#iHide").on("click",function(){
		 $("#container").hide(0);
		 $("#iShow").show(0);
		 $("#iHide").hide(0);
	});
	$("#iShow").on("click",function(){
		 $("#container").show(0);
	 $("#iHide").show(0);
	 $("#iShow").hide(0);
	});

	var $tooltips = $("#observAyuda").tooltip({
		content: function () {
			 return $(this).prop('title');
		}
	});


	<%if(preventPopup.equalsIgnoreCase("Y")){%>
			allowWriting({
				inputs: "#pacId, #nombrePaciente, #reg_medico, #nombreMedico, #centroServicio, #centroServicioDesc, #categoria, #categoriaDesc, #tipoAdmision, #pasaporte, #f_nac, #medicoCabecera_reg,#nombreMedicoCabecera",
				listener: "keydown",
				keycode: 9,
				keyboard: true,
				iframe: "#preventPopupFrame",
				cusFunctions : {
						pacId: {
							fn: [loadXtraInfo],
							params: [[]]
						}
				},
				xtraParams: {
					tipoAdmision: 'cds=centroServicio&catCode=categoria&codigo=tipoAdmision'
				},
				searchParams: {
					 pacId: "pacId", nombrePaciente: "nombre" , reg_medico:"codigo", nombreMedico: "nombre", centroServicio: "cds", centroServicioDesc: "cds_desc", categoria: "catCode", categoriaDesc: "descripcion", tipoAdmision:"codigo", pasaporte:"cedulaPasaporte", f_nac: "dob", medicoCabecera_reg:"codigo", nombreMedicoCabecera: "nombre",
				},
				toBeCleaned: {
					 nombrePaciente: ['pacId','provincia','sigla','tomo','asiento', 'f_nac', 'codigoPaciente'],
					 nombreMedico: ['reg_medico', 'medico', 'especialidad'],
					 centroServicioDesc: ['centroServicio', 'categoria', 'categoriaDesc', 'tipoAdmision', 'tipoAdmisionDesc']
				},
				baseUrls: {
						pacId: "../common/search_paciente.jsp?fp=admision&status=A",
						pasaporte: "../common/search_paciente.jsp?fp=admision&status=A",
						f_nac: "../common/search_paciente.jsp?fp=admision&status=A",
						nombrePaciente: "../common/search_paciente.jsp?fp=admision&status=A",
						reg_medico: "../common/search_medico.jsp?fp=admision_medico_esp&fg=admision",
						nombreMedico: "../common/search_medico.jsp?fp=admision_medico_esp&fg=admision",
						centroServicio: "../common/search_tipo_admision.jsp?fp=admision&pac_id="+$("#pacId").val()+"&admision="+$("#pacId").val(),centroServicioDesc: "../common/search_tipo_admision.jsp?fp=admision&pac_id="+$("#pacId").val()+"&admision="+$("#pacId").val(),
						categoria: "../common/search_tipo_admision.jsp?fp=admision&pac_id="+$("#pacId").val()+"&admision="+$("#pacId").val(),
						categoriaDesc: "../common/search_tipo_admision.jsp?fp=admision&pac_id="+$("#pacId").val()+"&admision="+$("#pacId").val(),
						tipoAdmision: "../common/search_tipo_admision.jsp?fp=admision&pac_id="+$("#pacId").val()+"&admision="+$("#pacId").val(),
						medicoCabecera_reg: "../common/search_medico.jsp?fp=admision_medico_cab&fg=admision",
						nombreMedicoCabecera: "../common/search_medico.jsp?fp=admision_medico_cab&fg=admision",
				}
			});
	<%}%>

	$('iframe').iFrameResize({
		log: false
	});

});

function addBenefAnterior(){
	window.location = "../admision/admision_config_new.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&tab=4&getOneOfTheLastBen=1";
	document.form0.respShow.value='N';
}


<%if(preventPopup.equalsIgnoreCase("Y")){%>
function _react(c){
	var o = {1:"#f_nac", 2:"#f_nac1"};
	allowWriting({
		inputs: o[c],
		iframe: "#preventPopupFrame",
		searchParams: {f_nac: "dob", f_nac1: "dob"},
		baseUrls: {f_nac: "../common/search_paciente.jsp?fp=admision&status=A",f_nac1: "../common/search_paciente.jsp?fp=admision&status=A",}
	});
}
<%}%>
function editPac(id){abrir_ventana('../admision/paciente_config.jsp?mode=edit&fp=admision&fg=upd&context=&pacId=<%=pacId%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		 <table width="99%" cellpadding="0" cellspacing="0">
			 <tr>
			<td width="50%"><label id="optDesc" class="TextInfo"><%=(adm.getSecuenciaAdj().equals("-1"))?"&nbsp;":"BENEFICIO CON PAQUETE ("+adm.getSecuenciaAdj()+")"%></label></td>
			<td  align="right" width="50%">
			<label id="optDesc" class="TextInfo Text10">&nbsp;</label>
		&nbsp;
		<% if (mode.equalsIgnoreCase("edit")) { %><authtype type='82'><a href="javascript:editPac(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" onMouseOver="javascript:displayElementValue('optDesc','Editar Paciente')" onMouseOut="javascript:displayElementValue('optDesc','')" src="../images/patient_config.gif"></a></authtype><% } %>
		<%if (!mode.equalsIgnoreCase("add")) {%>
				<authtype type='57'><img  id="sol-lis" data-urlto="../admision/reg_solicitud.jsp?fp=cds_solicitud_rayx_lab_ped&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>" height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/ambulatorio_laboratorio.png" style="text-decoration:none; cursor:pointer; display:none;" onMouseOver="javascript:displayElementValue('optDesc','Solicitud de Servicio Ambulatorio de Laboratorio')" onMouseOut="javascript:displayElementValue('optDesc','')">
				</authtype>
				<authtype type='59'><img id="sol-ris" data-urlto="../admision/reg_solicitud.jsp?fp=cds_solicitud_ima&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>" height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/solicitud_de_servicio_ambulatorio_de_imagenologia.png" style="text-decoration:none; cursor:pointer;  display:none;" onMouseOver="javascript:displayElementValue('optDesc','Solicitud de Servicio Ambulatorio de Imagenología')" onMouseOut="javascript:displayElementValue('optDesc','')">
				</authtype>

		<authtype type='50'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/barcode.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Brazalete')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:printBarcode()"></authtype>
		<authtype type='2'><img height="<%=iconHeight%>" width="<%=iconWidth%>" src="../images/printer.gif" style="text-decoration:none; cursor:pointer" onMouseOver="javascript:displayElementValue('optDesc','Imprimir Boleta de Admisión')" onMouseOut="javascript:displayElementValue('optDesc','')" onClick="javascript:printAdm()"></authtype>
				<%}else{%>
		&nbsp;
		<%}%>
			</td>
			 </tr>
		 </table>
	</td>
</tr>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td width="80%" style="vertical-align:top">

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<%if(preventPopup.equalsIgnoreCase("Y")){%>
<iframe id="preventPopupFrame" name="preventPopupFrame" frameborder="0" width="99%" height="200" src="" scroll="no" style="display:none;"></iframe>
<%}%>

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%=fb.hidden("inabilitar_ben","")%>
<%fb.appendJsValidation("if(isAdmisionInactive())error++;");%>
<%fb.appendJsValidation("if(!hasMotherAdmision())error++;");%>
<%fb.appendJsValidation("if(hasActiveAdmision())error++;");%>
<%if(mode.equalsIgnoreCase("add"))fb.appendJsValidation("if(!pendingBalanceConfirmation(0))error++;");%>
<%=fb.hidden("proceedPendingBalance","")%>
<%fb.appendJsValidation("hasEmployeeDebt();");%>
<%fb.appendJsValidation("if(notAValidDate()==true)error++;");%>
<%fb.appendJsValidation("if(document.form0.estado.value=='P'&&document.form0.fechaPreadmision.value.trim()=='')CBMSG.warning('Por favor introduzca la fecha/hora de la preadmisión!');else if(document.form0.fechaIngreso.value.trim()==''||document.form0.amPm.value.trim()=='')CBMSG.warning('Por favor introduzca la fecha/hora de ingreso!');");%>
<%fb.appendJsValidation("if(document.form0.estado.value=='P' && (document.form0.categoria.value==2 /*|| document.form0.categoria.value==4*/)){CBMSG.warning('No puede crear Pre-Admisión para Emergencia/Consulta Externa!'); error++;}");%>
<%=fb.hidden("camaShow","N")%>
<%=fb.hidden("diagShow","N")%>
<%=fb.hidden("doctShow","N")%>
<%=fb.hidden("beneShow","N")%>
<%=fb.hidden("respShow","N")%>
<%=fb.hidden("estadoOld",""+adm.getEstado())%>
<%=fb.hidden("preventPopup",preventPopup)%>
<%=fb.hidden("onlySol",onlySol)%>
<%=fb.hidden("citasSopAdm",citasSopAdm)%>
<%=fb.hidden("citasAmb",citasAmb)%>
<%=fb.hidden("aseguradora",adm.getAseguradora())%>
<%=fb.hidden("fNacMadre",adm.getFNacMadre())%>
<%=fb.hidden("cPacMadre",adm.getCPacMadre())%>
<%=fb.hidden("admiMadre",adm.getAdmiMadre())%>
<%=fb.hidden("pacIdMadre",adm.getPacIdMadre())%>
<%=fb.hidden("unidadOrgni",adm.getUnidadOrgni())%>
<%=fb.hidden("companiaUorg",adm.getCompaniaUorg())%>
<%=fb.hidden("orgPagina",request.getHeader("Referer"))%>
				<tr class="TextRow02">
					<td align="right">
					<span class="showHideXtraInfo iShow" title="Esconder" id="iHide">&nbsp;
					</span>
					<span class="showHideXtraInfo iHide" title="Mostar" id="iShow">&nbsp;</span>
					&nbsp;
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
					<%if(mode.equals("edit")){%>
					<span id="lbenUp" style="display:block"><%=fb.button("solBeneficio","Asignar Beneficios adm. anterior",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),"Text10",null,"onClick=addBenefAnterior()","Asignar Beneficios adm. anterior")%></span>
					<%}%>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="2">Nombre</cellbytelabel></td>
							<td >
								<%=fb.hidden("key",adm.getKey())%>
								<%=fb.intBox("pacId",adm.getPacId(),true,false,(mode.equalsIgnoreCase("add")&&preventPopup.equals("Y")?false:true),7)%>
								<%=fb.textBox("nombrePaciente",adm.getNombrePaciente(),true,false,(mode.equalsIgnoreCase("add")&&preventPopup.equals("Y")?false:true),40)%>
								<%=fb.button("btnPaciente","...",true,(!mode.equalsIgnoreCase("add")),null,null,"onClick=\"javascript:showPacienteList()\"")%>
								<img id='pacTypeImg' src='../images/blank.gif' height="8" width="20">							</td>
							<td width="14%" align="right">O/C</td>
							<td width="35%"><%=fb.textBox("oc",adm.getOc(),false,false,false,18,15)%></td>
						</tr>
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="3">C&eacute;dula</cellbytelabel></td>
							<td width="36%">
								<%=fb.intBox("provincia",adm.getProvincia(),false,false,true,2)%>
								<%=fb.textBox("sigla",adm.getSigla(),false,false,true,2)%>
								<%=fb.intBox("tomo",adm.getTomo(),false,false,true,4)%>
								<%=fb.intBox("asiento",adm.getAsiento(),false,false,true,5)%>
								<%=fb.hidden("dCedula",adm.getDCedula())%>
								<%=fb.select("dCedulaDisplay","D,R,H1,H2,H3,H4,H5",adm.getDCedula(),false,true,0)%>
							</td>
							<td width="14%" align="right"><cellbytelabel id="4">Pasaporte</cellbytelabel></td>
							<td width="35%"><%=fb.textBox("pasaporte",adm.getPasaporte(),false,false, (preventPopup.equals("Y")?false:true),20)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td>

								<%if(mode.equalsIgnoreCase("add")&&preventPopup.equals("Y")){%>
																	 <jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="dd/mm/yyyy"/>
									<jsp:param name="nameOfTBox1" value="f_nac"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getFechaNacimientoAnt()%>"/>
									<jsp:param name="clearOption" value="true"/>
									<jsp:param name="jsEvent" value="_react(1)"/>
									 </jsp:include>
																<%}else{%>
																	 <%=fb.textBox("f_nac",adm.getFechaNacimientoAnt(),false,false,true,10)%>
																<%}%>

								<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
								<%=fb.intBox("codigoPaciente",adm.getCodigoPaciente(),false,false,true,3)%>
								&nbsp;&nbsp;C&oacute;d. Ref.:<%=fb.textBox("cod_referencia",adm.getApartadoPostal(),false,false,true,15)%>
							</td>
							<td align="right"><cellbytelabel id="6">Responsable de la Cta.</cellbytelabel></td>
							<td><%=fb.select("responsabilidad","P=PACIENTE,O=OTRA PERSONA,E=EMPRESA",adm.getResponsabilidad(),false,viewMode,0,null,null,null)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="7">M&eacute;dico</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.hidden("medico",adm.getMedico())%>
								<%//=fb.textBox("reg_medico",adm.getOther1(),true,false,viewMode,15,null,null,"onBlur=\"javascript:getMedicDetail(this.value,'adm')\"")%>
								<%=fb.textBox("reg_medico",adm.getOther1(),true,false,(mode.equalsIgnoreCase("add")&&preventPopup.equals("Y")?false:true),15,null,null,"")%>
								<%=fb.textBox("nombreMedico",adm.getNombreMedico(),true,false,(preventPopup.equals("Y")?false:true),50)%>
								<%=fb.button("btnMedico","...",false,viewMode,null,null,"onClick=\"javascript:showMedicoList('especialidad')\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="9">Especialidad</cellbytelabel></td>
							<td colspan="3"><%=fb.textBox("especialidad",adm.getEspecialidad(),false,false,true,50)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="10">M&eacute;dico Cabecera</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.hidden("medicoCabecera",adm.getMedicoCabecera())%>
								<%//=fb.textBox("medicoCabecera_reg",adm.getOther2(),false,false,viewMode,15,null,null,"onBlur=\"javascript:getMedicDetail(this.value,'cab')\"")%>
								<%=fb.textBox("medicoCabecera_reg",adm.getOther2(),false,false,(mode.equalsIgnoreCase("add")&&preventPopup.equals("Y")?false:true),15,null,null,"")%>
								<%=fb.textBox("nombreMedicoCabecera",adm.getNombreMedicoCabecera(),false,false,(preventPopup.equals("Y")?false:true),50,null,null,null)%>
								<%=fb.button("btnMedicoCabecera","...",false,viewMode,null,null,"onClick=\"javascript:showMedicoList('cabecera')\"")%>
							</td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="12">No.</cellbytelabel></td>
							<td><%=adm.getNoAdmision()%></td>
							<td align="right"><cellbytelabel id="13">Estado</cellbytelabel></td>
							<td>
								<%=fb.hidden("estadoDsp",statusOnlyDisplay?"S":"N")%>
								<%=fb.select("estado",estadoOptions,adm.getEstado(),false,((isRead ||viewMode) && !fg.equalsIgnoreCase("con_sup")),0,null,null,"onChange=\"javascript:validateStatus()\"")%>

								<%String _title = "";
								if (adm.getObservAyuda()!=null) _title="<label style='font-size:11px'>"+adm.getObservAyuda()+"</span>";
								if (!_title.equals("")){%>
									<span class="miniinfoBtn" id="observAyuda" title="<%=_title%>">i</span>
								<%}%>
								Mes
								<%=fb.select("mesCtaBolsa","ENE=ENERO,FEB=FEBRERO,MAR=MARZO,ABR=ABRIL,MAY=MAYO,JUN=JUNIO,JUL=JULIO,AGO=AGOSTO,SEP=SEPTIEMBRE,OCT=OCTUBRE,NOV=NOVIEMBRE,DIC=DICIEMBRE",adm.getMesCtaBolsa(),false,true,0,null,null,null,"","S")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="14">Area</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("centroServicio",adm.getCentroServicio(),true,false,(preventPopup.equals("Y")?false:true),5)%>
								<%=fb.textBox("centroServicioDesc",adm.getCentroServicioDesc(),true,false,(preventPopup.equals("Y")?false:true),50)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="15">Categor&iacute;a</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("categoria",adm.getCategoria(),true,false,(preventPopup.equals("Y")?false:true),5)%>
								<%=fb.textBox("categoriaDesc",adm.getCategoriaDesc(),true,false,(preventPopup.equals("Y")?false:true),50)%>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=(fg.equalsIgnoreCase("UPDCAT"))?fb.button("btnTipoAdmisionSP","Cambiar",false,viewMode,null,null,"onClick=\"javascript:showTipoAdmisionList(1)\""):""%> <!--<authtype type="51"></authtype>-->
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="16">Tipo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("tipoAdmision",adm.getTipoAdmision(),true,false,(preventPopup.equals("Y")?false:true),5)%>
								<%=fb.textBox("tipoAdmisionDesc",adm.getTipoAdmisionDesc(),true,false,true,50)%>
								<%=fb.button("btnTipoAdmision","...",false,viewMode,null,null,"onClick=\"javascript:showTipoAdmisionList()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="17">Fecha y Hora de Ingreso</cellbytelabel></td>
							<td>
							<%System.out.println("adm.getFechaIngreso()="+adm.getFechaIngreso());%>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="dd/mm/yyyy"/>
									<jsp:param name="nameOfTBox1" value="fechaIngreso"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getFechaIngreso()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="hh12:mi am"/>
									<jsp:param name="nameOfTBox1" value="amPm"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getAmPm()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
							</td>
							<td align="right"><cellbytelabel id="18">Fecha Preadmisi&oacute;n</cellbytelabel></td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="format" value="dd/mm/yyyy hh12:mi am"/>
								<jsp:param name="nameOfTBox1" value="fechaPreadmision"/>
								<jsp:param name="valueOfTBox1" value="<%=adm.getFechaPreadmision()%>"/>
								<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="19">D&iacute;as Estimados</cellbytelabel></td>
							<td><%=fb.intBox("diasEstimados",adm.getDiasEstimados(),false,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),3)%></td>
							<td align="right"><cellbytelabel id="20">Contado / Cr&eacute;dito</cellbytelabel></td>
							<td><%=fb.select("contaCred",contCredOptions,"C=CONTADO"/*adm.getContaCred()*/,false,viewMode,0)%>&nbsp;</td>
						</tr>
<%
if (viewMode || fg.equalsIgnoreCase("con_sup2"))
{
%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="21">Fecha y Hora de Egreso</cellbytelabel></td>
							<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="dd/mm/yyyy"/>
									<jsp:param name="nameOfTBox1" value="fechaEgreso"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getFechaEgreso()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="hh12:mi am"/>
									<jsp:param name="nameOfTBox1" value="amPm2"/>
									<jsp:param name="valueOfTBox1" value="<%=adm.getAmPm2()%>"/>
									<jsp:param name="readonly" value="<%=(fg.equalsIgnoreCase("con_sup2"))?"n":"y"%>"/>
								</jsp:include>
							</td>
							<td align="right">
								<cellbytelabel id="22">Dias Hosp.</cellbytelabel>
								<%=fb.intBox("diasHospitalizados",adm.getDiasHospitalizados(),false,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),3)%>
							</td>
							<td>
								<cellbytelabel id="23">No. Cta. Appx</cellbytelabel>
								<%=fb.textBox("noCuenta",adm.getNoCuenta(),false,false,viewMode,20,15)%>
							</td>
						</tr>
<%}
if(mode.equals("edit") && !fg.equalsIgnoreCase("con_sup")){%>
<%=fb.hidden("fechaEgreso",adm.getFechaEgreso())%>
<%}%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="24">Tipo de Paciente (Descuento)</cellbytelabel></td>
							<td><%//=fb.select("tipoCta","J=JUBILADO,E=EMPLEADO,M=MEDICO,P=PARTICULAR,A=ASEGURADO",adm.getTipoCta(),false,(viewMode && !fg.equalsIgnoreCase("con_sup")),0,null,null,null)%>
							<% String tipoCta = "P=PARTICULAR,A=ASEGURADO";
							if(mode.equals("view"))
							{
								tipoCta = "J=JUBILADO,E=EMPLEADO,M=MEDICO,P=PARTICULAR,A=ASEGURADO";
							}

							%>
							<%=fb.hidden("tipoCtaOld",adm.getTipoCta())%>

							<%=fb.select("tipoCta",tipoCta,adm.getTipoCta(),true,false,(!adm.getCodigoPacienteAdj().trim().equals("0")||(viewMode && !fg.equalsIgnoreCase("con_sup"))),0,null,null,"onChange=\"javascript:checkTipoCta()\"","PARA CAMBIAR DEBE INACTIVAR LOS BENEFICIOS ASIGNADOS - ["+adm.getCodigoPacienteAdj()+"] ","S")%></td>
							<td align="right"><cellbytelabel id="25">Hospitalizaci&oacute;n Directa</cellbytelabel></td>
							<td><%=fb.select("hospDirecta","N=NO,S=SI",adm.getHospDirecta(),false,viewMode,0)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4">&nbsp;<cellbytelabel id="1">Condici&oacute;n del paciente</cellbytelabel></td>
						</tr>

						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Riesgo de Ca&iacute;da</cellbytelabel></td>
							<td>
							<%
							String selVal = adm.getCondicionPaciente();
							boolean _readOnly = false;
							if (hasRisk.getColValue("has_risk") != null && hasRisk.getColValue("has_risk").equals("Y")){
								 selVal = "S"; _readOnly = true;
							}else if (hasRisk.getColValue("has_risk") != null && hasRisk.getColValue("has_risk").equals("N")){
								selVal = "N"; _readOnly = true;
							}else if (hasRisk.getColValue("has_risk") != null && hasRisk.getColValue("has_risk").equals("NOT_FOUND")){
								_readOnly = false;
							}
							%>
							<%=fb.select("condPaciente","N=NO,S=SI",selVal,false,_readOnly,0,"S")%>
							<span id="container-1" title="">
							<span class="miniinfoBtn">i</span>
							</span>
							</td>
							<td align="right"><cellbytelabel id="25">Info. Importante</cellbytelabel></td>
							<td>
							<%=fb.textarea("observAdm",adm.getObservAdm(),java.util.Arrays.asList(mandatoryFields).contains("observadm"),false,viewMode,40,2,1000)%>
							</td>
						</tr>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),false)%><cellbytelabel id="27">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,(viewMode /*&& !fg.equalsIgnoreCase("con_sup")*/),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>



<%
//if (adm.getCategoria().equals("1")){
%>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%fb.appendJsValidation("if(document.form1.baction.value=='Guardar'&&!useOtherPrice())error++;");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='X'&&!chkDateCama())error++;");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&!chkEstadoAdm())error++;");%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimientoAnt()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="33">Habitaci&oacute;n</cellbytelabel></td>
				</tr>
				<tr>
					<td>
						<iframe id="camaFrame" name="camaFrame" frameborder="0" width="99%" height="100%" src="../admision/admision_config_cama.jsp?fp=admision_new&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>" scroll="no"></iframe>
					</td>
				</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
<!-- TAB1 DIV END HERE-->
</div>
<%
//}
%>
<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimientoAnt()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel id="39">Diagn&oacute;sticos</cellbytelabel></td>
				</tr>
				<tr>
					<td>
						<iframe id="diagFrame" name="diagFrame" frameborder="0" width="99%" height="100%" src="../admision/admision_config_diag.jsp?fp=admision_new&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>" scroll="no"></iframe>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>


<%
//if (!adm.getCategoria().equals("3") && !adm.getCategoria().equals("4")){
%>
<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimientoAnt()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr class="TextPanel">
					<td width="75%">&nbsp;<cellbytelabel id="41">Documentos</cellbytelabel></td>
				</tr>
				<tr>
					<td>
						<iframe id="docFrame" name="docFrame" frameborder="0" width="100%" height="100%" src="../admision/frame_doc_admision.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&expStatus=&hidePacHeader=1" scroll="no"></iframe>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>

<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel40">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimientoAnt()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="TableBorder">
						<jsp:include page="../common/data_link_info.jsp" flush="true">
							<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
							<jsp:param name="admision" value="<%=noAdmision%>"></jsp:param>
							<jsp:param name="type" value="benef"></jsp:param>
						</jsp:include>
					</td>
				</tr>
				<tr>
					<td>
						<table width="100%">
							<tr class="TextPanel">
								<td width="80%">&nbsp;<cellbytelabel>Beneficios Asignados</cellbytelabel></td>
								<td width="15%" align="right">
								 <span id="lbenUp" style="display:block"><%=fb.button("solBeneficio","Asignar Beneficios adm. anterior",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),"Text10",null,"onClick=addBenefAnterior()","Asignar Beneficios adm. anterior")%></span>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<iframe id="benefFrame" name="benefFrame" frameborder="0" width="99%" height="100%" src="../admision/admision_config_benef.jsp?fp=admision_new&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&fg=<%=fg%>" scroll="no"></iframe>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB4 DIV END HERE-->
</div>
<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel50">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimientoAnt()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr class="TextPanel">
					<td>&nbsp;<cellbytelabel id="60">Responsables</cellbytelabel></td>
				</tr>
				<tr>
					<td>
						<iframe id="respFrame" name="respFrame" frameborder="0" width="99%" height="100%" src="../admision/admision_config_resp.jsp?fp=admision_new&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&fg=<%=fg%>" scroll="no"></iframe>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>

<%--

<!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","6")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("camaSize",""+iCama.size())%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagSize",""+iDiag.size())%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benSize",""+iBen.size())%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respSize",""+iResp.size())%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%=fb.hidden("docTypeSize",""+alDoc.size())%>
				<tr class="TextRow02">
					<td>&nbsp;josue</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimientoAnt()%></td>
							<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(61)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="41">Documentos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61" style="display:none">+</label><label id="minus61">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel61">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="75%"><cellbytelabel id="97">Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><%=fb.checkbox("check","",false,viewMode,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','checked',"+alDoc.size()+",this)\"","Seleccionar todas los documentos listados!")%></td>
						</tr>
<%
String groupBy = "";
for (int i=0; i<alDoc.size(); i++)
{
	CommonDataObject obj = (CommonDataObject) alDoc.get(i);
	if (!groupBy.equalsIgnoreCase(obj.getColValue("display_area")))
	{
%>
						<tr class="TextHeader01">
							<td colspan="3"><%=obj.getColValue("display_area")%></td>
						</tr>
<%
	}
%>
						<%=fb.hidden("id"+i,obj.getColValue("id"))%>
						<%=fb.hidden("description"+i,obj.getColValue("description"))%>
						<%=fb.hidden("display_area"+i,obj.getColValue("display_area"))%>
						<tr class="TextRow01">
							<td><%=obj.getColValue("id")%></td>
							<td><%=obj.getColValue("description")%></td>
							<td align="center"><%=fb.checkbox("checked"+i,"Y",obj.getColValue("checked").equalsIgnoreCase("Y"),viewMode)%></td>
						</tr>
<%
	groupBy = obj.getColValue("display_area");
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>
--%>

<%if ((citasSopAdm.equalsIgnoreCase("S") || citasSopAdm.equalsIgnoreCase("Y"))) {%>
<!-- TAB6 DIV STARTS HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr>
<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPanel">
				<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
				<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
		</tr>
		</table>
</td>
</tr>
<tr id="panel70">
<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow01">
				<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
				<td width="35%"><%=adm.getFechaIngreso()%></td>
				<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
				<td width="35%"><%=adm.getNoAdmision()%></td>
		</tr>
		<tr class="TextRow01">
				<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
				<td><%=adm.getFechaNacimientoAnt()%></td>
				<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
				<td><%=adm.getCodigoPaciente()%></td>
		</tr>
		<tr class="TextRow01">
				<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
				<%if(citasSopAdm.equalsIgnoreCase("S") || citasSopAdm.equalsIgnoreCase("Y") ){%>
					<td>[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
					<td align="right" class="RedTextBold">Citas asociadas</td>
					<td class="RedTextBold"><span id="qty_citas_asociadas">0</span></td>
				<%}else{%>
					<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
				<%}%>
		</tr>
		</table>
</td>
</tr></table>
 <iframe id="citaFrame" name="citaFrame" frameborder="0" width="99%" height="550px" src="../cita/quirofano_list.jsp?citasSopAdm=<%=mode.equals("add")?"N":citasSopAdm%>&loadInfo=N&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=adm.getNombreMedico()%>&medico=<%=adm.getMedico()%>&nombrePaciente=<%=adm.getNombrePaciente()%>&forma_reserva=P&provincia=<%=adm.getProvincia()%>&sigla=<%=adm.getSigla()%>&tomo=<%=adm.getTomo()%>&asiento=<%=adm.getAsiento()%>&d_cedula=<%=adm.getDCedula()%>&pasaporte=<%=adm.getPasaporte()==null?"":adm.getPasaporte()%>&tipo_paciente=<%=_catAdm%>&f_nac=<%=adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()%>&sexo=<%=adm.getSexo()%>" scroll="yes"></iframe>
</div>
<!-- TAB6 DIV ENDS HERE-->
<%}%>
<%if (citasAmb.equalsIgnoreCase("S")) {%>
<!-- TAB7 DIV STARTS HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr>
<td onClick="javascript:showHide(80)" style="text-decoration:none; cursor:pointer">
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPanel">
				<td width="95%">&nbsp;<cellbytelabel id="11">Admisi&oacute;n</cellbytelabel></td>
				<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus80" style="display:none">+</label><label id="minus80">-</label></font>]&nbsp;</td>
		</tr>
		</table>
</td>
</tr>
<tr id="panel80">
<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow01">
				<td width="15%" align="right"><cellbytelabel id="30">Fecha de Admisi&oacute;n</cellbytelabel></td>
				<td width="35%"><%=adm.getFechaIngreso()%></td>
				<td width="15%" align="right"><cellbytelabel id="31">No. Admisi&oacute;n</cellbytelabel></td>
				<td width="35%"><%=adm.getNoAdmision()%></td>
		</tr>
		<tr class="TextRow01">
				<td align="right"><cellbytelabel id="5">Fecha de Nacimiento</cellbytelabel></td>
				<td><%=adm.getFechaNacimientoAnt()%></td>
				<td align="right"><cellbytelabel id="32">No. Paciente</cellbytelabel></td>
				<td><%=adm.getCodigoPaciente()%></td>
		</tr>
		<tr class="TextRow01">
				<td align="right"><cellbytelabel id="1">Paciente</cellbytelabel></td>
				<%if(citasAmb.equalsIgnoreCase("S")){%>
					<td>[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
					<td align="right" class="RedTextBold">Citas asociadas</td>
					<td class="RedTextBold"><span id="amb_qty_citas_asociadas">0</span></td>
				<%}else{%>
					<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
				<%}%>
		</tr>
		</table>
</td>
</tr></table>
 <iframe id="citaAmbFrame" name="citaAmbFrame" frameborder="0" width="99%" height="550px" src="../cita/cita_list.jsp?citasSopAdm=<%=mode.equals("add")?"N":"Y"%>&loadInfo=N&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=adm.getNombreMedico()%>&medico=<%=adm.getMedico()%>&nombrePaciente=<%=adm.getNombrePaciente()%>&forma_reserva=P&provincia=<%=adm.getProvincia()%>&sigla=<%=adm.getSigla()%>&tomo=<%=adm.getTomo()%>&asiento=<%=adm.getAsiento()%>&d_cedula=<%=adm.getDCedula()%>&pasaporte=<%=adm.getPasaporte()==null?"":adm.getPasaporte()%>&tipo_paciente=<%=_catAdm%>&fechaNacimiento=<%=adm.getFechaNacimiento()%>&codigo_paciente=<%=adm.getCodigoPaciente()%>&sexo=<%=adm.getSexo()%>" scroll="yes"></iframe>
</div>
<!-- TAB6 DIV ENDS HERE-->
<%}%>


<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabFunctions = "";
String tabLabel = "'Admisión','Camas','Diagnóstico','Documentos','Beneficios','Responsable'";

String tabInactivo ="";
if (mode.equalsIgnoreCase("add"))tabInactivo ="1,2,3,4,5";
else if (!adm.getCategoria().equals("1"))tabInactivo="1";
//else if (adm.getCategoria().equals("4"))tabInactivo="1,3";
 tabFunctions = "'0=tabFunctions(0)', '1=tabFunctions(1)', '2=tabFunctions(2)', '3=tabFunctions(3)', '4=tabFunctions(4)', '5=tabFunctions(5)'";

if(mode.equalsIgnoreCase("edit") && (citasSopAdm.equalsIgnoreCase("S") || citasSopAdm.equalsIgnoreCase("Y"))){tabLabel += ",'Citas Sala de Operación'"; tabFunctions += ",'6=tabFunctions(6)'";}
if(mode.equalsIgnoreCase("edit") && citasAmb.equalsIgnoreCase("S")){tabLabel += ",'Citas Ambulatorias'"; tabFunctions += ",'7=tabFunctions(7)'";}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','','','',Array(<%=tabFunctions%>),[<%=tabInactivo%>]);
</script>

			</td>
			<td width="20%" class="TableLeftBorder" style="vertical-align:top; padding-top:21px; display:none; cursor:pointer;" id="container">
			<div id="indicator" style="text-align:center;">
				<img src="../images/loading-bar2.gif" alt="Loading" />
			</div>
				<div id="pacInfoWrapper" style="text-align:center; height:500px; overflow-y:scroll;">
				</div>
			</td>
		</tr>
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
	String errCode = "";
	String errMsg = "";

	adm = new Admision();
	adm.setPacId(request.getParameter("pacId"));
	adm.setNoAdmision(request.getParameter("noAdmision"));
	adm.setFechaNacimiento(request.getParameter("fechaNacimiento"));
	adm.setCodigoPaciente(request.getParameter("codigoPaciente"));
	adm.setCompania((String) session.getAttribute("_companyId"));
	adm.setUsuarioModifica((String) session.getAttribute("_userName"));
	if (tab.equals("0")) //ADMISION
	{
		adm.setNombrePaciente(request.getParameter("nombrePaciente"));
		adm.setProvincia(request.getParameter("provincia").trim());
		adm.setSigla(request.getParameter("sigla").trim());
		adm.setTomo(request.getParameter("tomo").trim());
		adm.setAsiento(request.getParameter("asiento").trim());
		adm.setDCedula(request.getParameter("dCedula"));
		adm.setPasaporte(request.getParameter("pasaporte").trim());
		adm.setResponsabilidad(request.getParameter("responsabilidad"));
		adm.setMedico(request.getParameter("medico"));
		adm.setNombreMedico(request.getParameter("nombreMedico"));
		adm.setEspecialidad(request.getParameter("especialidad"));
		adm.setMedicoCabecera(request.getParameter("medicoCabecera"));
		adm.setNombreMedicoCabecera(request.getParameter("nombreMedicoCabecera"));
		if (request.getParameter("estadoDsp") != null && request.getParameter("estadoDsp").equalsIgnoreCase("N")) adm.setEstado(request.getParameter("estado"));
		else adm.setEstado("");
		adm.setCategoria(request.getParameter("categoria"));
		adm.setCategoriaDesc(request.getParameter("categoriaDesc"));
		adm.setCentroServicio(request.getParameter("centroServicio"));
		adm.setCentroServicioDesc(request.getParameter("centroServicioDesc"));
		adm.setTipoAdmision(request.getParameter("tipoAdmision"));
		adm.setTipoAdmisionDesc(request.getParameter("tipoAdmisionDesc"));
		adm.setDiasEstimados(request.getParameter("diasEstimados"));
		adm.setContaCred(request.getParameter("contaCred"));
		adm.setTipoCta(request.getParameter("tipoCta"));
		adm.setHospDirecta(request.getParameter("hospDirecta"));
		adm.setMesCtaBolsa(request.getParameter("mesCtaBolsa"));
		adm.setOc(request.getParameter("oc"));
		adm.setObservAdm(request.getParameter("observAdm"));
		adm.setCondicionPaciente(request.getParameter("condPaciente"));


		//Asigna fecha de egreso para admisiones ambulatorias, EXCLUYE HEMODIALISIS
		if (((adm.getCategoria().equals("2") && !adm.getTipoAdmision().equals("6")) || adm.getCategoria().equals("4")) && mode.equals("add")) adm.setFechaEgreso(CmnMgr.getCurrentDate("dd/mm/yyyy"));
		if(mode.equalsIgnoreCase("edit") && request.getParameter("fechaEgreso")!=null && !request.getParameter("fechaEgreso").equals("")) adm.setFechaEgreso(request.getParameter("fechaEgreso"));

		if (((adm.getCategoria().equals("2") && !adm.getTipoAdmision().equals("6")) || adm.getCategoria().equals("4")) && mode.equals("edit") && adm.getEstado().equals("A")){}
		else if (mode.equals("edit") && adm.getEstado().equals("A")) adm.setFechaEgreso("");

		adm.setFechaPreadmision(request.getParameter("fechaPreadmision"));// --> sysdate (DD-MM-YYYY HH12:MI AM)

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&fp="+fp+"&mode="+mode+"&Ref="+request.getParameter("orgPagina"));


		if (mode.equalsIgnoreCase("add"))
		{
			adm.setUsuarioCreacion((String) session.getAttribute("_userName"));

			//default values from ADM3309
			adm.setFechaIngreso(request.getParameter("fechaIngreso"));// --> sysdate (DD-MM-YYYY)
			adm.setAmPm(request.getParameter("amPm"));// --> sysdate (HH12:MI AM)
			adm.setAdmitidoPor("M");
			adm.setUnidadOrgni("1");
			adm.setProceedPendingBalance("Y");

			AdmMgr.add(adm);
			noAdmision = AdmMgr.getPkColValue("noAdmision");
		}
		else if (mode.equalsIgnoreCase("edit"))
		{

			if(request.getParameter("fNacMadre")!=null && !request.getParameter("fNacMadre").equals("")) adm.setFNacMadre(request.getParameter("fNacMadre"));
			if(request.getParameter("cPacMadre")!=null && !request.getParameter("cPacMadre").equals("")) adm.setCPacMadre(request.getParameter("cPacMadre"));
			if(request.getParameter("admiMadre")!=null && !request.getParameter("admiMadre").equals("")) adm.setAdmiMadre(request.getParameter("admiMadre"));
			if(request.getParameter("pacIdMadre")!=null && !request.getParameter("pacIdMadre").equals("")) adm.setPacIdMadre(request.getParameter("pacIdMadre"));
			if(request.getParameter("unidadOrgni")!=null && !request.getParameter("unidadOrgni").equals("")) adm.setUnidadOrgni(request.getParameter("unidadOrgni"));
			if(request.getParameter("companiaUorg")!=null && !request.getParameter("companiaUorg").equals("")) adm.setCompaniaUorg(request.getParameter("companiaUorg"));

			if (fg.equalsIgnoreCase("con_sup"))
			{
				adm.setFechaIngreso(request.getParameter("fechaIngreso"));// --> sysdate (DD-MM-YYYY)
				adm.setAmPm(request.getParameter("amPm"));// --> sysdate (HH12:MI AM)
				adm.setFechaEgreso(request.getParameter("fechaEgreso"));
				adm.setAmPm2(request.getParameter("amPm2"));
				adm.setDiasHospitalizados(request.getParameter("diasHospitalizados"));
				AdmMgr.updateX(adm);
			}
			else {
						 if (request.getParameter("inabilitar_ben")!=null && request.getParameter("inabilitar_ben").equalsIgnoreCase("Y")) adm.setInabilitarBen("Y");
						 AdmMgr.update(adm);
						}
		}
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();
	}
	else if (tab.equals("6")) //DOCUMENTOS
	{
		int size = 0;
		if (request.getParameter("docTypeSize") != null) size = Integer.parseInt(request.getParameter("docTypeSize"));

		al = new ArrayList();
		for (int i=0; i<size; i++)
		{
			CommonDataObject obj = new CommonDataObject();

			obj.setTableName("tbl_adm_admision_doc");
			obj.setWhereClause("pac_id="+pacId+" and admision="+noAdmision);
			obj.addColValue("pac_id",pacId);
			obj.addColValue("admision",noAdmision);
			obj.addColValue("doc_type",request.getParameter("id"+i));
			if (request.getParameter("checked"+i) != null && request.getParameter("checked"+i).equalsIgnoreCase("Y")) al.add(obj);
		}

		if (al.size() == 0)
		{
			CommonDataObject obj = new CommonDataObject();

			obj.setTableName("tbl_adm_admision_doc");
			obj.setWhereClause("pac_id="+pacId+" and admision="+noAdmision);
			al.add(obj);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();
	}
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script>

function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (tab.equals("0"))
	{
		if (mode.equalsIgnoreCase("add"))
		{
%>
			var msg=getMsg('<%=request.getContextPath()%>','<%=ConMgr.getClientIdentifier()%>');
			if(msg!='')alert(msg);
	<%if (preventPopup.equals("")){%>alert("Recuerde llenar la información en las pestañas adicionales!");<%}else{%>
			 window.opener.location = '<%=request.getContextPath()%>/admision/admision_list.jsp?tx=TR&preventPopup=<%=preventPopup%>&onlySol=<%=onlySol%>';
		<%}%>
<%
		}
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/admision_list.jsp"))
		{
		if(!fp.trim().equals("hdadmision")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/admision_list.jsp")%>';
<%
		}else{%>
		<%}

		}
		else
		{
		if(fp.trim().equals("hdadmision")){
%>

	//window.location = '<%=request.getContextPath()%>/admision/admision_list.jsp';
<%}else{%>
window.opener.location = '<%=request.getContextPath()%>/admision/admision_list.jsp?preventPopup=<%=preventPopup%>&onlySol=<%=onlySol%>';
<%

		}}
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
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&preventPopup=<%=preventPopup%>&onlySol=<%=onlySol%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
