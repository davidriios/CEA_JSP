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
<jsp:useBean id="iBen" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vBen" scope="session" class="java.util.Vector"/>

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
String fecha="",fechaIngreso="";
int camaLastLineNo = 0;
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
String loadInfo = request.getParameter("loadInfo");
if (loadInfo == null) loadInfo = "N";

String getOneOfTheLastBen = request.getParameter("getOneOfTheLastBen")==null?"":request.getParameter("getOneOfTheLastBen");

String fromNewView = request.getParameter("from_new_view");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
String admKey = request.getParameter("adm_key");
String aseguradora = request.getParameter("aseguradora");
String tipoCta = request.getParameter("tipo_cta");

if (fromNewView == null) fromNewView = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";
if (admKey == null) admKey = "";
if (aseguradora == null) aseguradora = "";
if (tipoCta == null) tipoCta = "";

String catAdm = request.getParameter("cat_adm");
if (catAdm == null) catAdm = "";

if (request.getMethod().equalsIgnoreCase("GET") && loadInfo.equals("S"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		iBen.clear();
		vBen.clear();
		if (pacId == null || pacId.trim().equals("")) pacId = "0";
		noAdmision = "0";
		adm.setPacId(pacId);
		adm.setNoAdmision(noAdmision);
		adm.setFechaIngreso(cDateTime.substring(0,10));
		adm.setAmPm(cDateTime.substring(11));
		adm.setFechaPreadmision("");
		adm.setEstado("A");
		adm.setTipoCta("P");

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

		if (change == null)
		{
			iBen.clear();
			vBen.clear();

			if (!getOneOfTheLastBen.trim().equals("") ){
				 sbSql = new StringBuffer();
				 sbSql.append("select distinct a.secuencia as sec, 0 secuencia, a.empresa, a.convenio, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc, a.poliza, a.certificado, a.prioridad, a.convenio_sol_emp as convenioSolEmp, a.num_aprobacion as numAprobacion,(case when to_char(a.empresa) in (select column_value from table(select split((select get_sec_comp_param(-1,'COD_EMP_AXA') from dual),',') from dual))  then 'Y' else 'N' end ) tipo, nvl(d.use_employ,'N') as numEmpleado from tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where a.pac_id=");
				 sbSql.append(pacId);

				 sbSql.append(" and a.admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=");
				 sbSql.append(pacId);

				 sbSql.append(") and a.estado='A' and a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and b.estado='A' and c.empresa=d.codigo and c.estatus='A' and a.tipo_plan=e.tipo_plan and a.tipo_poliza=e.poliza and a.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo and a.prioridad = 1 order by a.prioridad, a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi");
			 }
			 else{
			sbSql = new StringBuffer();
			sbSql.append("select a.secuencia, a.poliza, nvl(a.certificado,' ') as certificado, nvl(a.convenio_solicitud,'C') as convenioSolicitud, nvl(a.convenio_sol_emp,'N') as convenioSolEmp, a.prioridad, decode(a.plan,null,' ',a.plan) as plan, decode(a.convenio,null,' ',a.convenio) as convenio, a.empresa, decode(a.categoria_admi,null,' ',a.categoria_admi) as categoriaAdmi, decode(a.tipo_admi,null,' ',a.tipo_admi) as tipoAdmi, decode(a.clasif_admi,null,' ',a.clasif_admi) as clasifAdmi, decode(a.tipo_poliza,null,' ',a.tipo_poliza) as tipoPoliza, decode(a.tipo_plan,null,' ',a.tipo_plan) as tipoPlan, to_char(nvl(a.fecha_ini,sysdate),'dd/mm/yyyy') as fechaIni, decode(a.categoria_admi,2,to_char(nvl(a.fecha_fin,sysdate),'dd/mm/yyyy'),' ') as fechaFin, nvl(a.usuario_creacion,' ') as usuarioCreacion, nvl(a.usuario_modificacion,' ') as usuarioModificacion, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaModificacion, nvl(a.estado,' ') as estado, decode(a.num_aprobacion,null,' ',a.num_aprobacion) as numAprobacion, (select tipo_poliza from tbl_adm_plan_convenio where empresa=a.empresa and convenio=a.convenio and secuencia=a.plan) as tipoPoliza, (select tipo_plan from tbl_adm_plan_convenio where empresa=a.empresa and convenio=a.convenio and secuencia=a.plan) as tipoPlan, (select nombre from tbl_adm_plan_convenio where empresa=a.empresa and convenio=a.convenio and secuencia=a.plan) as nombrePlan, (select y.nombre from tbl_adm_plan_convenio z, tbl_adm_convenio y where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.empresa=y.empresa and z.convenio=y.secuencia) as nombreConvenio, (select x.nombre from tbl_adm_plan_convenio z, tbl_adm_convenio y, tbl_adm_empresa x where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.empresa=y.empresa and z.convenio=y.secuencia and y.empresa=x.codigo) as nombreEmpresa, (select y.nombre from tbl_adm_plan_convenio z, tbl_adm_tipo_plan y where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.tipo_plan=y.tipo_plan and z.tipo_poliza=y.poliza) as nombreTipoPlan, (select y.nombre from tbl_adm_plan_convenio z, tbl_adm_tipo_poliza y where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.tipo_poliza=y.codigo) as nombreTipoPoliza, (select descripcion from tbl_adm_clasif_x_tipo_adm where categoria=a.categoria_admi and tipo=a.tipo_admi and codigo=a.clasif_admi) as clasifAdmiDesc, (select y.descripcion from tbl_adm_clasif_x_tipo_adm z, tbl_adm_tipo_admision_cia y where z.categoria=a.categoria_admi and z.tipo=a.tipo_admi and z.codigo=a.clasif_admi and z.categoria=y.categoria and z.tipo=y.codigo) as tipoAdmiDesc, (select x.descripcion from tbl_adm_clasif_x_tipo_adm z, tbl_adm_tipo_admision_cia y, tbl_adm_categoria_admision x where z.categoria=a.categoria_admi and z.tipo=a.tipo_admi and z.codigo=a.clasif_admi and z.categoria=y.categoria and z.tipo=y.codigo and y.categoria=x.codigo) as categoriaAdmiDesc, nvl(a.pac_asume_cargos,'N') as pacAsumeCargos, nvl(a.clinica_asume_cargos,'N') as clinicaAsumeCargos, (case when to_char(a.empresa) in (select column_value from table(select split((select get_sec_comp_param(-1,'COD_EMP_AXA') from dual),',') from dual))  then 'Y' else 'N' end ) as tipo, nvl((select x.use_employ from tbl_adm_plan_convenio z, tbl_adm_convenio y, tbl_adm_empresa x where z.empresa=a.empresa and z.convenio=a.convenio and z.secuencia=a.plan and z.empresa=y.empresa and z.convenio=y.secuencia and y.empresa=x.codigo),'N') as numEmpleado from tbl_adm_beneficios_x_admision a where nvl(a.estado,'A')='A' and a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" order by 1, 6, 9, 8, 7, 10, 11, 12");
			}
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),Admision.class);

			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iBen.put(key, obj);
					vBen.addElement(obj.getEmpresa()+"-"+obj.getConvenio()+"-"+obj.getPlan()+"-"+obj.getCategoriaAdmi()+"-"+obj.getTipoAdmi()+"-"+obj.getClasifAdmi());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
				//if(!getOneOfTheLastBen.trim().equals("")) break;
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script>
document.title = 'Admisión - '+document.title;

function showEmpleadoList(opt,k){
	if (opt.toLowerCase() == 'beneficio') abrir_ventana1('../common/search_empleado.jsp?fp=admision_empleado_ben&index='+k);
}

function showBeneficioSol(i)
{
	var empresa=eval('document.form4.empresa'+i).value;
	if(eval('document.form4.secuencia'+i).value==''||eval('document.form4.secuencia'+i).value=='0') {
			CBMSG.warning('Guarde los cambios antes de realizar la solicitud de Beneficio!');
			return false;
		}
	else
	{
		if(eval('document.form4.prioridad'+i).value=='1')
		{
			if(hasDBData('<%=request.getContextPath()%>','tbl_adm_solicitud_beneficio','empresa='+empresa+' and estatus=\'A\' and admision=<%=noAdmision%> and pac_id=<%=pacId%>',''))
			{
				if(confirm("Ya existe una Solicitud de Beneficios para esta Compañía de Seguros. Se consultará la Solicitud para que realice los cambios que desee."))abrir_ventana1('../admision/solicitud_beneficio.jsp?pac_id=<%=pacId%>&admision=<%=noAdmision%>');
			}
			else
			{
				var fecha=replaceAll(parent.form0.fechaNacimiento.value,"/","-");
				var fIngreso=parent.form0.fechaIngreso.value.replace("/","-");
				var codPac=parseInt(eval('parent.document.form0.codigoPaciente').value);
				if(eval('document.form4.poliza'+i).value==''&&eval('document.form4.status'+i).value!='D'&&eval('document.form4.estado'+i).value!='I') {
									CBMSG.warning('Introduca su póliza');
									return false;
								}
				else
				{
					var poliza=eval('document.form4.poliza'+i).value;
					var certificado=eval('document.form4.certificado'+i).value;
					var plan=eval('document.form4.plan'+i).value;
					var clasif_admi=eval('document.form4.clasifAdmi'+i).value;
					var tipo_admi=eval('document.form4.tipoAdmi'+i).value;
					var categoria_admi=eval('document.form4.categoriaAdmi'+i).value;
					var convenio=eval('document.form4.convenio'+i).value;
					var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','c.sol_benef_pac, c.sol_benef_emp', 'tbl_adm_beneficios_x_admision a, tbl_adm_categoria_admision b, tbl_adm_clasif_x_plan_conv c, tbl_adm_tipo_admision_cia d, tbl_adm_clasif_x_tipo_adm e where a.plan=c.plan and a.convenio=c.convenio and a.empresa=c.empresa and a.clasif_admi=c.clasif_admi and a.tipo_admi=c.tipo_admi and a.categoria_admi=c.categoria_admi and d.categoria=b.codigo and c.clasif_admi=e.codigo and c.tipo_admi=e.tipo and c.categoria_admi=e.categoria and e.tipo=d.codigo and e.categoria=d.categoria and c.plan='+plan+' and c.clasif_admi='+clasif_admi+' and c.tipo_admi='+tipo_admi+' and c.empresa='+empresa+' and c.categoria_admi='+categoria_admi+' and c.convenio='+convenio+' and a.pac_id=<%=pacId%> and a.admision=<%=noAdmision%> and a.estado=\'A\' and a.prioridad=1',''));
					for(i=0;i<r.length;i++)
					{
						var c=r[i];
						if(c[0] && c[0]=='S'&& c[1] && c[1]=='S'){
														CBMSG.warning('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para calcular el copago del paciente y el pago de la aseguradora, presione el botón SOLICITUD.');
														return false;
												}
						else if(c[0] && c[0]=='S'&& c[1] && c[1]=='N') {
													CBMSG.warning('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el copago del paciente, presione el botón SOLICITUD.');
													return false;
												}
						else if(c[0] && c[0]=='N' && c[1] && c[1] =='S') {
													CBMSG.warning('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el monto que asume la Aseguradora, presione el botón SOLICITUD.');
													return false;
												}
					}
					if(executeDB('<%=request.getContextPath()%>','call adm_crea_solicitud_beneficio(\''+fecha+'\','+codPac+',<%=noAdmision%>,'+empresa+',\''+fIngreso+'\',\''+poliza+'\',\''+certificado+'\',<%=pacId%>)','tbl_adm_solicitud_beneficio,tbl_adm_detalle_solicitud'))
					{
						CBMSG.warning('La solicitud se ha generado Satisfactoriamente', {
												cb:function(r){
														if (r == 'Ok') abrir_ventana1('../admision/solicitud_beneficio.jsp?pac_id=<%=pacId%>&admision=<%=noAdmision%>');
												}
												});
					}
					else CBMSG.warning('No se ha generado la solicitud');
				}
			}
		}else CBMSG.warning('Solicitudes solo para Beneficios con prioridad 1');
	}
}
function isValidPriority(){if(isDuplicatedBeneficioPrioridad())return false;chkDobleCobertura();return true;}
function chkDobleCobertura(){
	var benSize=parseInt(document.form4.benSize.value,10);
	var nValid=0;
	var idx=-1;
	for(i=1;i<=benSize;i++){
		if(eval('document.form4.status'+i).value!='D'&&eval('document.form4.estado'+i).value!='I'){
			nValid++;
			if(eval('document.form4.prioridad'+i).value==1)idx=i;
		}
	}
	if(idx!=-1&&nValid>1){
		var chk=$("input[name^=convenioSolEmp][type='checkbox']");chk.attr('checked',false);
		eval('document.form4.convenioSolEmp'+idx).checked=true;
	}
	else  eval('document.form4.convenioSolEmp'+idx).checked=false;
}
function isDuplicatedBeneficioPrioridad()
{
	var benSize=parseInt(document.form4.benSize.value,10);
	for(i=1;i<=benSize-1;i++)
	{
		for(j=i+1;j<=benSize;j++)
		{

			if(eval('document.form4.prioridad'+i).value==eval('document.form4.prioridad'+j).value&&eval('document.form4.status'+i).value!="D"&&eval('document.form4.status'+j).value!="D"&&eval('document.form4.estado'+i).value!="I"&&eval('document.form4.estado'+j).value!="I")
			{
				CBMSG.warning('No se permiten beneficios con la misma prioridad!');
				eval('document.form4.prioridad'+j).value='';
				return true;
			}
		}
		isFirstPriority(i);
	}
	if(benSize>1)isFirstPriority(benSize);
	return false;
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
function chkBeneficioSol(){
	var size = document.form4.benSize.value;
	var action = document.form4.baction.value;

	for(i=1;i<=size;i++){
		var empresa = eval('document.form4.empresa'+i).value;

		if(eval('document.form4.prioridad'+i).value=="1" && action == 'Guardar'){
			var estatus='A';
			if(!hasDBData('<%=request.getContextPath()%>','tbl_adm_solicitud_beneficio','empresa='+empresa+' and  estatus=\'A\' and admision=<%=noAdmision%> and pac_id=<%=pacId%>','')){
			//} else {//abrir_ventana2('../admision/solicitud_beneficio.jsp?pac_id=<%=pacId%>&admision=<%=noAdmision%>');
				var fecha= '<%=fecha%>';
				var fIngreso='<%=fechaIngreso%>';
				var codPac = parseInt(eval('document.form4.codigoPaciente').value);
				if(eval('document.form4.poliza'+i).value=="" && eval('document.form4.status'+i).value!="D" )
				{	CBMSG.warning('Introduzca su poliza'); return false;}
				else {
					var poliza = eval('document.form4.poliza'+i).value;
					var certificado = eval('document.form4.certificado'+i).value;
					var plan = eval('document.form4.plan'+i).value;
					var clasif_admi = eval('document.form4.clasifAdmi'+i).value;
					var tipo_admi = eval('document.form4.tipoAdmi'+i).value;
					var categoria_admi = eval('document.form4.categoriaAdmi'+i).value;
					var convenio = eval('document.form4.convenio'+i).value;

					var cod = getDBData('<%=request.getContextPath()%>','c.sol_benef_pac, c.sol_benef_emp','tbl_adm_beneficios_x_admision a, tbl_adm_categoria_admision b, tbl_adm_clasif_x_plan_conv c, tbl_adm_tipo_admision_cia d, tbl_adm_clasif_x_tipo_adm e', 'a.plan = c.plan and a.convenio = c.convenio and a.empresa = c.empresa and a.clasif_admi = c.clasif_admi and a.tipo_admi = c.tipo_admi and a.categoria_admi = c.categoria_admi and d.categoria = b.codigo and c.clasif_admi = e.codigo and c.tipo_admi = e.tipo and c.categoria_admi = e.categoria and e.tipo = d.codigo and e.categoria = d.categoria and c.plan = '+plan+' and c.clasif_admi = '+clasif_admi+' and c.tipo_admi = '+tipo_admi+' and c.empresa = '+empresa+' and c.categoria_admi = '+categoria_admi+' and c.convenio = '+convenio+' and a.pac_id = <%=pacId%> and a.admision = <%=noAdmision%> and a.estado = \'A\' and a.prioridad = 1','');
					if(cod.substr(0,1)=="S" && cod.substr(2,1)=="N"){
							CBMSG.warning('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el copago del paciente.\nDebe hacer esto una vez sea guardado el Beneficio!.');
														return false;
					}
					if(cod.substr(0,1)=="N" && cod.substr(2,1)=="S"){
							CBMSG.warning('De acuerdo al plan, se requiere generar la Solicitud de Beneficios para que pueda calcular el monto que asume la Aseguradora.\nDebe hacer esto una vez sea guardado el Beneficio!.');
														return false;
					}
				}
			}
		}
	}
	return false;
}

function showBeneficioList()
{
	var oldBenefits='N';//used to display previous admision benefits if 'Y'

	var vip = '';
	<%if(!fromNewView.trim().equals("")){%>
	var aseg = "<%=aseguradora%>";
	var tipoCta = "<%=tipoCta%>";
	if(tipoCta == 'P') vip = "<%=admKey%>";
	<%} else {%>
	var aseg = parent.document.form0.aseguradora.value;
	var tipoCta = parent.document.form0.tipoCta.value;
	if(tipoCta=='P') vip = parent.document.form0.key.value;
	<%}%>
	abrir_ventana1('../common/check_convenio_plan.jsp?fp=admision_new&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&tr=<%=fp%>&getOneOfTheLastBen=<%=getOneOfTheLastBen%>&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&tipo_cta=<%=tipoCta%>&adm_key=<%=admKey%>&aseguradora=<%=aseguradora%><%=(catAdm.equalsIgnoreCase("OPD"))?"&admCat=4&cat_adm=OPD":""%>&vip='+vip);
}

function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function doAction(){
newHeight();
xHeight=objHeight('_tblMain');
// resizeFrame();
chkDobleCobertura();
<% if (request.getParameter("type") != null && request.getParameter("type").equals("1")) { %>showBeneficioList();<% } %>
}

function doSubmit(){
	<%if(!fromNewView.equals("")){%>
			document.form4.fechaNacimiento.value = "<%=fechaNacimiento%>";
			document.form4.codigoPaciente.value = "<%=codigoPaciente%>";
	<%} else {%>
		document.form4.fechaNacimiento.value = parent.document.form0.fechaNacimiento.value;
		document.form4.codigoPaciente.value = parent.document.form0.codigoPaciente.value;
	<%}%>
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

function confirmBenefitStatus(k)
{
	var status=eval('document.form4.estado'+k).value;
	if(status=='I'&&!confirm('¿Está seguro que desea INACTIVAR el beneficio?'))eval('document.form4.estado'+k).value='A';
}

function addBenefAnterior(k)
{
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision','pac_id=<%=pacId%> and admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=<%=pacId%>) and estado=\'A\'',''))
	{
		var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','distinct a.empresa, a.convenio, a.plan, a.categoria_admi as categoriaAdmi, a.tipo_admi as tipoAdmi, a.clasif_admi as clasifAdmi, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc, a.poliza, a.certificado, a.prioridad, a.convenio_sol_emp as convenioSolEmp, a.num_aprobacion as numAprobacion','tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i','a.pac_id=<%=pacId%> and a.admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=<%=pacId%>) and a.estado=\'A\' and a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and b.estado=\'A\' and c.empresa=d.codigo and c.estatus=\'A\' and a.tipo_plan=e.tipo_plan and a.tipo_poliza=e.poliza and a.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo order by a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi'));
		for(i=0;i<r.length;i++)
		{
			var c=r[i];
			eval('document.form4.empresa'+k).value=c[0].trim();
			document.getElementById('_lblEmpresa'+k).innerHTML=c[0].trim();
			eval('document.form4.convenio'+k).value=c[1].trim();
			eval('document.form4.plan'+k).value=c[2].trim();
			document.getElementById('_lblPlan'+k).innerHTML=c[2].trim();
			eval('document.form4.categoriaAdmi'+k).value=c[3].trim();
			document.getElementById('_lblCategoriaAdmi'+k).innerHTML=c[3].trim();
			eval('document.form4.tipoAdmi'+k).value=c[4].trim();
			document.getElementById('_lblTipoAdmi'+k).innerHTML=c[4].trim();
			eval('document.form4.clasifAdmi'+k).value=c[5].trim();
			document.getElementById('_lblClasifAdmi'+k).innerHTML=c[5].trim();
			eval('document.form4.tipoPoliza'+k).value=c[6].trim();
			document.getElementById('_lblTipoPoliza'+k).innerHTML=c[6].trim();
			eval('document.form4.tipoPlan'+k).value=c[7].trim();
			document.getElementById('_lblTipoPlan'+k).innerHTML=c[7].trim();
			eval('document.form4.nombrePlan'+k).value=c[8].trim();
			document.getElementById('_lblNombrePlan'+k).innerHTML=c[8].trim();
			eval('document.form4.nombreConvenio'+k).value=c[9].trim();
			eval('document.form4.nombreEmpresa'+k).value=c[10].trim();
			document.getElementById('_lblNombreEmpresa'+k).innerHTML=c[10].trim();
			eval('document.form4.nombreTipoPlan'+k).value=c[11].trim();
			document.getElementById('_lblNombreTipoPlan'+k).innerHTML=c[11].trim();
			eval('document.form4.nombreTipoPoliza'+k).value=c[12].trim();
			document.getElementById('_lblNombreTipoPoliza'+k).innerHTML=c[12].trim();
			eval('document.form4.clasifAdmiDesc'+k).value=c[13].trim();
			document.getElementById('_lblClasifAdmiDesc'+k).innerHTML=c[13].trim();
			eval('document.form4.tipoAdmiDesc'+k).value=c[14].trim();
			document.getElementById('_lblTipoAdmiDesc'+k).innerHTML=c[14].trim();
			eval('document.form4.categoriaAdmiDesc'+k).value=c[15].trim();
			document.getElementById('_lblCategoriaAdmiDesc'+k).innerHTML=c[15].trim();
			eval('document.form4.poliza'+k).value=c[16].trim();
			eval('document.form4.certificado'+k).value=c[17].trim();
			eval('document.form4.status'+k).value=c[18].trim();
			document.form4.baction.value="add";
			document.form4.submit();
			break;
		}
	}	else CBMSG.warning('No Hay beneficios activos!');
}
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<table align="center" width="100%" cellpadding="0" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
	<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

	<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("tab","1")%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("fechaNacimiento","")%>
	<%=fb.hidden("codigoPaciente","")%>
	<%=fb.hidden("pacId",pacId)%>
	<%=fb.hidden("noAdmision",noAdmision)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("benSize",""+iBen.size())%>
	<%fb.appendJsValidation("if(isAdmisionInactive())error++;");%>
	<%fb.appendJsValidation("if(chkBeneficioSol())error++;");%>
	<%=fb.hidden("proceedPendingBalance","")%>
	<%=fb.hidden("getOneOfTheLastBen",getOneOfTheLastBen)%>
	<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
	<%=fb.hidden("tipo_cta",tipoCta)%>
	<%=fb.hidden("adm_key",admKey)%>
	<%=fb.hidden("aseguradora",aseguradora)%>
	<%=fb.hidden("cat_adm",catAdm)%>
		<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="5%"><cellbytelabel id="12">No.</cellbytelabel></td>
				<td width="36%"><cellbytelabel id="44">Aseguradora</cellbytelabel></td>
				<td width="24%"><cellbytelabel id="45">P&oacute;liza</cellbytelabel></td>
				<td width="15%"><cellbytelabel id="46">Certificado</cellbytelabel></td>
				<td width="7%"><cellbytelabel id="40">Prioridad</cellbytelabel></td>
				<td width="10%"><cellbytelabel id="13">Estado</cellbytelabel></td>
				<td width="3%"><%=fb.submit("addBeneficio","+",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Beneficios")%></td>
			</tr>
			<%
			String jsValidation = "";
			al = CmnMgr.reverseRecords(iBen);
			for (int i=1; i<=iBen.size(); i++)
			{
				key = al.get(i - 1).toString();
				Admision obj = (Admision) iBen.get(key);
				String color = "TextRow01";
				if (i % 2 == 0) color = "TextRow02";
				fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'&&(document."+fb.getFormName()+".poliza"+i+".value==''||document."+fb.getFormName()+".prioridad"+i+".value==''))error++;");
				String displayBen = "";
				if (obj.getStatus() != null && obj.getStatus().equalsIgnoreCase("D")){ displayBen = " style=\"display:none\""; }
				else if (obj.getEstado() != null && !obj.getEstado().equalsIgnoreCase("I")) prioridad++;

			%>
			<%=fb.hidden("key"+i,obj.getKey())%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("secuencia"+i,obj.getSecuencia())%>
			<%=fb.hidden("convenioSolicitud"+i,obj.getConvenioSolicitud())%>
			<%=fb.hidden("plan"+i,obj.getPlan())%>
			<%=fb.hidden("convenio"+i,obj.getConvenio())%>
			<%=fb.hidden("empresa"+i,obj.getEmpresa())%>
			<%=fb.hidden("categoriaAdmi"+i,obj.getCategoriaAdmi())%>
			<%=fb.hidden("tipoAdmi"+i,obj.getTipoAdmi())%>
			<%=fb.hidden("clasifAdmi"+i,obj.getClasifAdmi())%>
			<%=fb.hidden("tipoPoliza"+i,obj.getTipoPoliza())%>
			<%=fb.hidden("tipoPlan"+i,obj.getTipoPlan())%>
			<%=fb.hidden("nombrePlan"+i,obj.getNombrePlan())%>
			<%=fb.hidden("nombreConvenio"+i,obj.getNombreConvenio())%>
			<%=fb.hidden("nombreEmpresa"+i,obj.getNombreEmpresa())%>
			<%=fb.hidden("nombreTipoPlan"+i,obj.getNombreTipoPlan())%>
			<%=fb.hidden("nombreTipoPoliza"+i,obj.getNombreTipoPoliza())%>
			<%=fb.hidden("clasifAdmiDesc"+i,obj.getClasifAdmiDesc())%>
			<%=fb.hidden("tipoAdmiDesc"+i,obj.getTipoAdmiDesc())%>
			<%=fb.hidden("categoriaAdmiDesc"+i,obj.getCategoriaAdmiDesc())%>
			<%=fb.hidden("status"+i,obj.getStatus())%>
			<tr class="<%=color%>"<%=displayBen%>>
				<td><%=obj.getSecuencia()%></td>
				<td>[<label id="_lblEmpresa<%=i%>"><%=obj.getEmpresa()+"-"+obj.getSecuencia()%></label>] <label id="_lblNombreEmpresa<%=i%>"><%=obj.getNombreEmpresa()%></label></td>
				<td align="center">
					<%=fb.textBox("poliza"+i,obj.getPoliza(),(!obj.getStatus().trim().equals("D")),false,((viewMode && !fg.equalsIgnoreCase("con_sup")) || obj.getNumEmpleado().equalsIgnoreCase("Y")),30,30,"Text10",null,null)%>
					<%=fb.button("btnEmpleado","...",true,((viewMode && !fg.equalsIgnoreCase("con_sup")) || !obj.getNumEmpleado().equalsIgnoreCase("Y")),"Text10",null,"onClick=\"javascript:showEmpleadoList('beneficio',"+i+")\"")%>
				</td>
				<td align="center"><%=fb.textBox("certificado"+i,obj.getCertificado(),false,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),20,20,"Text10",null,null)%></td>
				<td align="center"><%=fb.intBox("prioridad"+i,(obj.getPrioridad() != null && !obj.getPrioridad().trim().equals("")&&(obj.getSecuencia() != null && !obj.getSecuencia().equals("0")))?obj.getPrioridad():""+prioridad,(!obj.getStatus().trim().equals("D")),false,(viewMode && !fg.equalsIgnoreCase("con_sup")),2,2,"Text10",null,"onBlur=\"javascript:isValidPriority()\"")%></td>
				<td align="center"><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",obj.getEstado(),false,(viewMode && !fg.equalsIgnoreCase("con_sup")),0,"Text10",null,"onChange=\"javascript:confirmBenefitStatus("+i+")\"")%></td>
				<td rowspan="2" align="center"><%=(obj.getSecuencia() != null && obj.getSecuencia().equals("0"))?fb.submit("rem"+i,"X",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Beneficio"):""%></td>
			</tr>
			<tr class="<%=color%>"<%=displayBen%>>
				<td colspan="6">
					<table width="100%" cellpadding="1" cellspacing="0">
					<tr class="<%=color%>">
						<td width="10%" align="right"><cellbytelabel id="47">Tipo P&oacute;liza</cellbytelabel>:</td>
						<td width="20%">[<label id="_lblTipoPoliza<%=i%>"><%=obj.getTipoPoliza()%></label>] <label id="_lblNombreTipoPoliza<%=i%>"><%=obj.getNombreTipoPoliza()%></label></td>
						<td width="10%" align="right"><cellbytelabel id="48">Tipo Plan</cellbytelabel>:</td>
						<td width="25%">[<label id="_lblTipoPlan<%=i%>"><%=obj.getTipoPlan()%></label>] <label id="_lblNombreTipoPlan<%=i%>"><%=obj.getNombreTipoPlan()%></label></td>
						<td width="10%" align="right"><cellbytelabel id="49">Plan Asig.</cellbytelabel>:</td>
						<td width="25%">[<label id="_lblPlan<%=i%>"><%=obj.getPlan()%></label>] <label id="_lblNombrePlan<%=i%>"><%=obj.getNombrePlan()%></label></td>
					</tr>
					<tr class="<%=color%>">
						<td align="right"><cellbytelabel id="50">Cat. Adm.</cellbytelabel>:</td>
						<td>[<label id="_lblCategoriaAdmi<%=i%>"><%=obj.getCategoriaAdmi()%></label>] <label id="_lblCategoriaAdmiDesc<%=i%>"><%=obj.getCategoriaAdmiDesc()%></label></td>
						<td align="right"><cellbytelabel id="51">Tipo Adm.</cellbytelabel>:</td>
						<td>[<label id="_lblTipoAdmi<%=i%>"><%=obj.getTipoAdmi()%></label>] <label id="_lblTipoAdmiDesc<%=i%>"><%=obj.getTipoAdmiDesc()%></label></td>
						<td align="right"><cellbytelabel id="52">Clasificaci&oacute;n</cellbytelabel>:</td>
						<td>[<label id="_lblClasifAdmi<%=i%>"><%=obj.getClasifAdmi()%></label>] <label id="_lblClasifAdmiDesc<%=i%>"><%=obj.getClasifAdmiDesc()%></label></td>
					</tr>
					<tr class="<%=color%>">
					<%
					if (fg.equalsIgnoreCase("con_sup2"))
					{
					%>
					<td colspan="4" rowspan="3">
						<table width="100%" cellpadding="1" cellspacing="1" class="TableBorder">
						<tr align="center">
							<td class="TextHeader Text10" colspan="2"><cellbytelabel id="53">I M P O R T A N T E</cellbytelabel> :</td>
						</tr>
						<tr>
							<td class="TextHeader Text10" width="35%" align="right"><cellbytelabel id="54">Asignaci&oacute;n de Rangos de Fecha a los Planes</cellbytelabel>:</td>
							<td width="65%">
								<cellbytelabel id="55">Fecha</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="format" value="dd/mm/yyyy"/>
								<jsp:param name="nameOfTBox1" value="<%="fechaIni"+i%>"/>
								<jsp:param name="valueOfTBox1" value="<%=obj.getFechaIni()%>"/>
								<jsp:param name="nameOfTBox2" value="<%="fechaFin"+i%>"/>
								<jsp:param name="valueOfTBox2" value="<%=obj.getFechaFin()%>"/>
								<jsp:param name="readonly" value="<%=(viewMode && !fg.equalsIgnoreCase("con_sup"))?"y":"n"%>"/>
								<jsp:param name="fieldClass" value="Text10"/>
								<jsp:param name="buttonClass" value="Text10"/>
								</jsp:include>
							</td>
						</tr>
						<tr>
							<td class="TextHeader Text10" align="right"><cellbytelabel id="56">Para uso del Depto. de Cobros</cellbytelabel>:</td>
							<td>
								<%=fb.checkbox("pacAsumeCargos"+i,"S",(obj.getPacAsumeCargos() != null && obj.getPacAsumeCargos().equalsIgnoreCase("S")),(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"")%>
								<cellbytelabel id="57">Cargar D&iacute;as fuera de Cob. a PACIENT</cellbytelabel>E<br>
								<%=fb.checkbox("clinicaAsumeCargos"+i,"S",(obj.getClinicaAsumeCargos() != null && obj.getClinicaAsumeCargos().equalsIgnoreCase("S")),(viewMode && !fg.equalsIgnoreCase("con_sup")),null,null,"")%>
								<cellbytelabel id="58">Cargar D&iacute;as fuera de Cob. a CLINICA</cellbytelabel>
							</td>
						</tr>
						</table>
					</td>
					<%
					}
					else
					{
					%>
						<%=fb.hidden("fechaIni"+i,obj.getFechaIni())%>
						<%=fb.hidden("fechaFin"+i,obj.getFechaFin())%>
						<%=fb.hidden("pacAsumeCargos"+i,obj.getPacAsumeCargos())%>
						<%=fb.hidden("clinicaAsumeCargos"+i,obj.getClinicaAsumeCargos())%>
					<%
					}
					%>
					<td align="center" colspan="2">
						<%if(getOneOfTheLastBen.trim().equals("")){%>
							<cellbytelabel id="59">Doble Cobertura?</cellbytelabel>
							<%=fb.checkbox("convenioSolEmp"+i,"S",(obj.getConvenioSolEmp() != null && obj.getConvenioSolEmp().equalsIgnoreCase("S")),((viewMode && !fg.equalsIgnoreCase("con_sup"))),null,null,"onClick=\"javascript:isFirstPriority("+i+")\"")%>
						<%}%>
					</td>
					<%
					if (fg.equalsIgnoreCase("con_sup2"))
					{
					%>
					</tr>
					<tr class="<%=color%>">
					<%
					}
					%>
									<td align="center" colspan="2">
										<%//if(obj.getTipo()!=null && obj.getTipo().equalsIgnoreCase("Y")){%>
										No. Aprob.<!-- AXA-->
										<%=fb.textBox("numAprobacion"+i,obj.getNumAprobacion(),true,false,(viewMode && !fg.equalsIgnoreCase("con_sup")),20,100)%>
										<%//}%>
									</td>
<%
if (fg.equalsIgnoreCase("con_sup2"))
{
%>
								</tr>
								<tr class="<%=color%>">
<%
}
%>
									<td align="center" colspan="2">
										<%//=(obj.getSecuencia() != null && !obj.getSecuencia().trim().equals("") && !obj.getSecuencia().equals("0"))?fb.button("solBeneficio"+i,"Benef. adm. ant",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),"Text10",null,"onClick=\"javascript:addBenefAnterior('"+i+"',this.value)\"","Aplicar Beneficios adm. anterior"):""%>
										<%=(obj.getSecuencia() != null && !obj.getSecuencia().trim().equals("") && !obj.getSecuencia().equals("0"))?fb.button("solBeneficio"+i,"Solicitud De Benef.",true,(viewMode && !fg.equalsIgnoreCase("con_sup")),"Text10",null,"onClick=\"javascript:showBeneficioSol('"+i+"',this.value)\"","Solicitar Beneficios"):""%>
									</td>
								</tr>
								</table>
							</td>
						</tr>
<%
}
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='Guardar'&&!isValidPriority())error++;");
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
			<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value);doSubmit();\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
		</td>
	</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</div>
</div>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
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


		int size = 0;
		if (request.getParameter("benSize") != null) size = Integer.parseInt(request.getParameter("benSize"));
		String itemRemoved = "";

		adm.setProceedPendingBalance(request.getParameter("proceedPendingBalance"));
		if(mode.equals("edit")) adm.setProceedPendingBalance("Y");
		adm.getBeneficios().clear();
		for (int i=1; i<=size; i++)
		{
			Admision obj = new Admision();

			obj.setEmpresa(request.getParameter("empresa"+i));
			obj.setConvenio(request.getParameter("convenio"+i));
			obj.setPlan(request.getParameter("plan"+i));
			obj.setCategoriaAdmi(request.getParameter("categoriaAdmi"+i));
			obj.setTipoAdmi(request.getParameter("tipoAdmi"+i));
			obj.setClasifAdmi(request.getParameter("clasifAdmi"+i));
			obj.setTipoPoliza(request.getParameter("tipoPoliza"+i));
			obj.setTipoPlan(request.getParameter("tipoPlan"+i));
			obj.setNombrePlan(request.getParameter("nombrePlan"+i));
			obj.setNombreConvenio(request.getParameter("nombreConvenio"+i));
			obj.setNombreEmpresa(request.getParameter("nombreEmpresa"+i));
			obj.setNombreTipoPlan(request.getParameter("nombreTipoPlan"+i));
			obj.setNombreTipoPoliza(request.getParameter("nombreTipoPoliza"+i));
			obj.setClasifAdmiDesc(request.getParameter("clasifAdmiDesc"+i));
			obj.setTipoAdmiDesc(request.getParameter("tipoAdmiDesc"+i));
			obj.setCategoriaAdmiDesc(request.getParameter("categoriaAdmiDesc"+i));
			obj.setSecuencia(request.getParameter("secuencia"+i));
			obj.setConvenioSolicitud(request.getParameter("convenioSolicitud"+i));
			obj.setPoliza(request.getParameter("poliza"+i));
			obj.setCertificado(request.getParameter("certificado"+i));
			obj.setPrioridad(request.getParameter("prioridad"+i));
			obj.setEstado(request.getParameter("estado"+i));
			if (request.getParameter("convenioSolEmp"+i) != null && request.getParameter("convenioSolEmp"+i).equalsIgnoreCase("S")) obj.setConvenioSolEmp("S");
			else obj.setConvenioSolEmp("N");
			if(request.getParameter("numAprobacion"+i)!=null) obj.setNumAprobacion(request.getParameter("numAprobacion"+i));
			obj.setUsuarioCreacion((String) session.getAttribute("_userName"));
			obj.setUsuarioModifica((String) session.getAttribute("_userName"));
			obj.setKey(request.getParameter("key"+i));
			obj.setStatus("A");

			obj.setFechaIni(request.getParameter("fechaIni"+i));
			obj.setFechaFin(request.getParameter("fechaFin"+i));
			if (request.getParameter("pacAsumeCargos"+i) != null && request.getParameter("pacAsumeCargos"+i).equalsIgnoreCase("S")) obj.setPacAsumeCargos(request.getParameter("pacAsumeCargos"+i));
			else obj.setPacAsumeCargos("N");
			if (request.getParameter("clinicaAsumeCargos"+i) != null && request.getParameter("clinicaAsumeCargos"+i).equalsIgnoreCase("S")) obj.setClinicaAsumeCargos(request.getParameter("clinicaAsumeCargos"+i));
			else obj.setClinicaAsumeCargos("N");
			if (request.getParameter("tipo"+i) != null && !request.getParameter("tipo"+i).equalsIgnoreCase("")) obj.setTipo(request.getParameter("tipo"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = obj.getKey();
				obj.setStatus("D");
			}
			else obj.setStatus(request.getParameter("status"+i));

			try
			{
				iBen.put(obj.getKey(),obj);
				adm.addBeneficio(obj);
				System.out.println("key..."+obj.getKey());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for

		if (!itemRemoved.equals(""))
		{
			Admision obj = (Admision) iBen.get(itemRemoved);
			vBen.remove(obj.getEmpresa()+"-"+obj.getConvenio()+"-"+obj.getPlan()+"-"+obj.getCategoriaAdmi()+"-"+obj.getTipoAdmi()+"-"+obj.getClasifAdmi());
			//iBen.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fp="+fp+"&loadInfo=S&getOneOfTheLastBen="+getOneOfTheLastBen+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente+"&tipo_cta="+tipoCta+"&aseguradora"+aseguradora+"&adm_key="+admKey+"&cat_adm="+catAdm);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&fp="+fp+"&loadInfo=S&getOneOfTheLastBen="+getOneOfTheLastBen+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente+"&tipo_cta="+tipoCta+"&aseguradora"+aseguradora+"&adm_key="+admKey+"&cat_adm="+catAdm);
			return;
		}
		if (baction != null && baction.equals("add"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&fp="+fp+"&loadInfo=S&getOneOfTheLastBen="+getOneOfTheLastBen+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente+"&tipo_cta="+tipoCta+"&aseguradora"+aseguradora+"&adm_key="+admKey+"&cat_adm="+catAdm);
			return;
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::: POSTING ::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
		AdmMgr.saveBeneficio(adm);
		ConMgr.clearAppCtx(null);
		errCode = AdmMgr.getErrCode();
		errMsg = AdmMgr.getErrMsg();



%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
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
	if (parent.window) parent.window.close();
	else window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S&getOneOfTheLastBen=&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&tipo_cta=<%=tipoCta%>&adm_key=<%=admKey%>&aseguradora=<%=aseguradora%>&cat_adm=<%=catAdm%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&loadInfo=S&getOneOfTheLastBen=&from_new_view=<%=fromNewView%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&tipo_cta=<%=tipoCta%>&adm_key=<%=admKey%>&aseguradora=<%=aseguradora%>&cat_adm=<%=catAdm%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>