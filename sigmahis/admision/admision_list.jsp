<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
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

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
int iconHeight = 44;
int iconWidth = 44;
String cds = request.getParameter("cds");
String categoria = request.getParameter("categoria");
String status = request.getParameter("status");
String dateType = request.getParameter("dateType");
String fDate = request.getParameter("fDate");
String fTime = request.getParameter("fTime");
String tDate = request.getParameter("tDate");
String tTime = request.getParameter("tTime");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
StringBuffer sbFilter2 = new StringBuffer();
String cFullDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = cFullDate.substring(0,10);
String  escolta= "S", citasSopAdm = "",citasAmb = "",usaPlanMedico="";
try {escolta =java.util.ResourceBundle.getBundle("issi").getString("escolta");}catch(Exception e){ escolta = "N";}
String consetimiento="";
try {consetimiento =java.util.ResourceBundle.getBundle("issi").getString("consetimiento");}catch(Exception e){ consetimiento = "1";}
try {citasSopAdm = java.util.ResourceBundle.getBundle("issi").getString("citasSopAdm");}catch(Exception e){ citasSopAdm = "N";}
try {citasAmb = java.util.ResourceBundle.getBundle("issi").getString("citasAmb");}catch(Exception e){ citasAmb = "N";}
try {usaPlanMedico =java.util.ResourceBundle.getBundle("planmedico").getString("usaPlanMedico");}catch(Exception e){ usaPlanMedico = "N";}

if (cds == null) {

	if (SecMgr.getParValue(UserDet,"cds") != null && !SecMgr.getParValue(UserDet,"cds").trim().equals("")) cds = SecMgr.getParValue(UserDet,"cds");
	else cds = "";

}
if (cds.trim().equalsIgnoreCase("")) {

	if (!UserDet.getUserProfile().contains("0")) {
		sbFilter2.append(" and a.centro_servicio in (");
		if (session.getAttribute("_cds") != null) sbFilter2.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
		else sbFilter2.append("-1");
		sbFilter2.append(")");
	}

} else {

	sbFilter.append(" and a.centro_servicio = ");
	sbFilter.append(cds);

}

if (categoria == null) categoria = "";
if (!categoria.trim().equals("")) { sbFilter.append(" and a.categoria = "); sbFilter.append(categoria); }

if (status == null) status = "A";
if(status.trim().equals("AE")){sbFilter2.append(" and a.estado in ('A','E')");}
else if(!status.trim().equals("")) {sbFilter2.append(" and a.estado = '"); sbFilter2.append(status); sbFilter2.append("'"); }

if (dateType == null) dateType = "";
/*
if (dob == null) dob = cDate;
if (fDate == null || tDate == null) {
	fDate = cDate;
	tDate = cDate;
}*/

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	String dob = request.getParameter("dob");
	String codigo = request.getParameter("codigo");
	String noAdmision = request.getParameter("noAdmision");
	String paciente = request.getParameter("paciente");
	String fg = request.getParameter("fg");
	String pacId = request.getParameter("pacId");
	String aseguradora = request.getParameter("aseguradora");
	String aseguradoraDesc = request.getParameter("aseguradoraDesc");
	String dobleCob =  request.getParameter("dobleCob");
	String _preventPopup = request.getParameter("preventPopup")==null?"":request.getParameter("preventPopup");
	String onlySol = request.getParameter("onlySol") == null?"":request.getParameter("onlySol");
	boolean isOnlySol = onlySol.equalsIgnoreCase("Y");
	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (dob == null) dob = "";
	if (codigo == null) codigo = "";
	if (noAdmision == null) noAdmision = "";
	if (paciente == null) paciente = "";
	if (fDate == null) fDate = "";
	if (tDate == null) tDate = "";
		if (fTime == null) fTime = "";
	if (tTime == null) tTime = "";
	if (fg == null) fg = "";
	if (pacId == null) pacId = "";
	if (aseguradora == null) aseguradora = "";
	if (aseguradoraDesc == null) aseguradoraDesc = "";
		if (dobleCob == null) dobleCob = "";

	if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(b.id_paciente) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }
	if (!dob.trim().equals("")) { sbFilter.append(" and b.f_nac = to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and a.codigo_paciente = "); sbFilter.append(codigo); }
	if (!noAdmision.trim().equals("")) { sbFilter.append(" and a.secuencia = "); sbFilter.append(noAdmision); }
	if (!paciente.trim().equals("")) { sbFilter.append(" and upper(b.nombre_paciente) like '%"); sbFilter.append(paciente.toUpperCase()); sbFilter.append("%'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and a.pac_id = "); sbFilter.append(pacId); }
	if (!fDate.trim().equals("") && !tDate.trim().equals("")) {
		//sbFilter.append(" and a.fecha_ingreso = to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')");
		String field = "nvl(a.fecha_ingreso,a.fecha_creacion)";
		String label = "Ingreso";
				String amPmField = "a.am_pm";

		if (dateType.equalsIgnoreCase("E")) {
			field = "a.fecha_egreso";
			label = "Egreso";
						amPmField = "a.am_pm2";
		}

				if (!fTime.equals("") && !tTime.equals("")){

						sbFilter.append(" and to_date( to_char(");
						sbFilter.append(field);
						sbFilter.append(",'dd/mm/yyyy')||' '||to_char(");
						sbFilter.append(amPmField);
						sbFilter.append(",'hh12:mi am'),'dd/mm/yyyy hh12:mi am') between to_date('");
						sbFilter.append(fDate);
						sbFilter.append(" ");
						sbFilter.append(fTime);
						sbFilter.append("','dd/mm/yyyy hh12:mi am') and to_date('");
						sbFilter.append(tDate);
						sbFilter.append(" ");
						sbFilter.append(tTime);
						sbFilter.append("','dd/mm/yyyy hh12:mi am')");

				}else{

						sbFilter.append(" and trunc(");
						sbFilter.append(field);
						sbFilter.append(") between to_date('");
						sbFilter.append(fDate);
						sbFilter.append("','dd/mm/yyyy') and to_date('");
						sbFilter.append(tDate);
						sbFilter.append("','dd/mm/yyyy')");

				}
	}
	if (!aseguradora.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_beneficios_x_admision where nvl(estado,'A') = 'A' and prioridad = 1 and pac_id = a.pac_id and admision = a.secuencia and empresa = "); sbFilter.append(aseguradora); sbFilter.append(")"); }
	if (!aseguradoraDesc.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_beneficios_x_admision z where nvl(z.estado,'A') = 'A' and z.prioridad = 1 and z.pac_id = a.pac_id and z.admision = a.secuencia and exists (select null from tbl_adm_empresa where codigo = z.empresa and upper(nombre) like '%"); sbFilter.append(aseguradoraDesc.toUpperCase()); sbFilter.append("%'))"); }
	if (!dobleCob.trim().equals("")) { sbFilter.append(" and exists (select 1 from tbl_adm_beneficios_x_admision  be where (be.pac_id = a.pac_id and be.admision= a.secuencia) and be.convenio_sol_emp ='S' and be.estado = 'A' and be.prioridad = 1) ");}


	issi.admin.SQLMgr SQLMgr = new issi.admin.SQLMgr();
	SQLMgr.setConnection(ConMgr);
	sbSql = new StringBuffer();
	sbSql.append("select get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CDS_EGY') as cds_egy, get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'ADM_USAR_HORA') as adm_usar_hora, get_sec_comp_param(-1,'CONSENTIMIENTO') as consentimiento, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_MOSTRAR_ALERGIA_ANT'),'S') as showAllergyAnt from dual");
	issi.admin.CommonDataObject cdoEGY = SQLMgr.getData(sbSql.toString());
	if (cdoEGY==null) cdoEGY = new issi.admin.CommonDataObject();
	String cdsEGY = cdoEGY.getColValue("cds_egy","");
	if(!cdoEGY.getColValue("consentimiento").equals("")) consetimiento = cdoEGY.getColValue("consentimiento");
	boolean admUsarHora = ((cdoEGY.getColValue("adm_usar_hora","N")).equalsIgnoreCase("Y") || (cdoEGY.getColValue("adm_usar_hora","N")).equalsIgnoreCase("S"));
	boolean preventPopup =  _preventPopup.equalsIgnoreCase("Y");


	if (sbFilter.length() > 0) {

	sbFilter.append(sbFilter2);

		sbSql = new StringBuffer();
		//sbSql.append("select nvl(a.fecha_ingreso,a.fecha_creacion) as sort_date, to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, /*to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy')*/nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.tipo_admision as tipoAdmision, b.id_paciente as pasaporte, b.vip, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento,b.pasaporte) as cedulaPamd, a.compania, a.pac_id as pacId, b.nombre_paciente as nombrePaciente, (select nombre_corto from tbl_adm_categoria_admision where codigo = a.categoria) as categoriaDesc, a.centro_servicio as centroServicio, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as centroServicioDesc, (select cds from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1) as area/*es el cds para expediente*/, nvl((select cama from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1),' ') as cama, nvl((select estado from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.secuencia and rownum = 1),'X') as status, a.medico, a.conta_cred as contaCred, b.edad as key,a.adm_root as admRoot,get_sec_comp_param(a.compania,'VER_CAMA_EST_ADM') revisadoAdmision, a.observ_ayuda as observAyuda ");


		//sbSql.append(", (select case when count(*) > 0 then 'Y' else 'N' end from tbl_adm_beneficios_x_admision  be where be.pac_id = a.pac_id and be.admision= a.secuencia and be.convenio_sol_emp ='S' and be.estado = 'A' and be.prioridad = 1) as convenioSolEmp, nvl(to_char(a.am_pm,'hh12:mi am'),' ') as amPm, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2,to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimientoAnt ");



sbSql.append("select nvl(a.fecha_ingreso,a.fecha_creacion) as sort_date, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision,/*to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy')*/nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.tipo_admision as tipoAdmision,b.id_paciente as pasaporte, b.vip, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento,b.pasaporte) as cedulaPamd,a.compania, a.pac_id as pacId, b.nombre_paciente/*replace(replace(b.nombre_paciente,upper(a.name_match),a.name_match),upper(a.lastname_match),a.lastname_match)*/ as nombrePaciente, case when a.name_match is not null or a.lastname_match is not null then 1 else 0 end as parentesco,(select (select nombre_corto from tbl_adm_categoria_admision where codigo = a.categoria) from dual) as categoriaDesc,(select (select descripcion from tbl_adm_tipo_admision_cia where categoria = a.categoria and codigo = a.tipo_admision and compania = a.compania) from dual) as tipoAdmisionDesc, a.centro_servicio as centroServicio, (select (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) from dual) as centroServicioDesc, (select cds from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.adm_root and rownum = 1) as area/*es el cds para expediente*/, nvl((select (select cama from tbl_adm_atencion_cu where (pac_id = a.pac_id and secuencia = a.adm_root) and rownum = 1) from dual),' ') as cama,nvl((select (select estado from tbl_adm_atencion_cu where (pac_id = a.pac_id and secuencia = a.secuencia) and rownum = 1) from dual),'X') as status,a.medico, a.conta_cred as contaCred, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),null) as key,a.adm_root as admRoot,(select get_sec_comp_param(a.compania,'VER_CAMA_EST_ADM') from dual ) revisadoAdmision, a.observ_ayuda as observAyuda, a.motivo_Anulacion motivoAnulacion, a.usuario_anulacion usuarioAnulacion, to_char(a.fecha_anulacion,'dd/mm/yyyy hh12:mi:ss am') fechaAnulacion");

		sbSql.append(",(select (select case when count(*) > 0 then 'Y' else 'N' end from tbl_adm_beneficios_x_admision be where (be.pac_id = a.pac_id and be.admision= a.secuencia) and be.convenio_sol_emp ='S' and be.estado = 'A' and be.prioridad = 1) from dual )as convenioSolEmp, nvl(to_char(a.am_pm,'hh12:mi am'),' ') as amPm, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2,(select (select case when count(*) > 0 then '' else 'S' end from tbl_adm_cama_admision where (pac_id=a.pac_id and admision=a.secuencia) and fecha_final is null) from dual) as fechaFinal,to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimientoAnt, nvl((select chkContratoPM(a.pac_id) chkContrato from dual), 'N') extension");

		sbSql.append(", case when (select count(*) as nRecs from tbl_sec_alert z where z.pac_id = a.pac_id and z.admision = a.secuencia and status = 'A' and z.alert_type in(7,14,15) and exists (select null from tbl_sec_alert_type where id = z.alert_type)) > 0 then 'S' when nvl(a.condicion_paciente,'N') = 'S' then 'S' else 'N' end as condicionPaciente, (select fn_sal_om_salida(a.pac_id,a.secuencia,'ANE') from dual) as salida, nvl((select fn_sal_alergias(a.pac_id,a.secuencia,'D','");
		sbSql.append(cdoEGY.getColValue("showAllergyAnt","S"));
		sbSql.append("','N') from dual),' ') as observacion");

		sbSql.append(" from tbl_adm_admision a, vw_adm_paciente b");
		sbSql.append(" where a.pac_id = b.pac_id and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 1 desc, 15 asc, 4");
		System.out.println("................."+sbSql.toString());
		al = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal,Admision.class);
		//rowCount = CmnMgr.getCount("select count(*) from tbl_adm_admision a, vw_adm_paciente b where a.pac_id = b.pac_id and a.compania = "+session.getAttribute("_companyId")+sbFilter);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+") ");
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
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script>
document.title = 'Admisión - '+document.title;
function printList(p){
 if (p=='PDF') abrir_ventana('../admision/print_list_admision.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&dobleCob=<%=dobleCob%>&fp=<%=admUsarHora?"CUSTOM":""%>');
 else if (p=='XLS'){
	 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/print_list_admision.rptdesign&filter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&pCtrlHeader=true&dobleCob=<%=dobleCob%>&fp=<%=admUsarHora?"CUSTOM":""%>');
 }
}
function setIndex(k){document.result.index.value=k;getPatientDetails(k);}
function openwin(pageURL, title,w,h) {
	var left = (screen.width/2)-(w/2);
	var top = (screen.height/2)-(h/2);
	var targetWin = window.open (pageURL, title, 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=yes, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
}
function goOption(option)
{
	var fDate = eval('document.search00.fDate').value;
	var tDate = eval('document.search00.tDate').value;
	var sala = eval('document.search00.cds').value;
	if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else if(option==0)abrir_ventana('../admision/admision_config_new.jsp?citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%><%=preventPopup?"&preventPopup=Y":""%>');
	else if (option==43) {
		var i = document.result.index.value;
		if (i) {
			var pacId = document.getElementById("pacId"+i).value;
			var noAdmision = document.getElementById("noAdmision"+i).value;
			var cds = document.getElementById("cds"+i).value;

			abrir_ventana('../admision/admision_config_new_view.jsp?mode=edit<%=preventPopup?"&preventPopup=Y":"&preventPopup=Y"%>&pacId='+pacId+'&noAdmision='+noAdmision+'&cds='+cds+'&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>&cat_adm=OPD');
		}
		else abrir_ventana('../admision/admision_config_new_view.jsp?mode=add<%=preventPopup?"&preventPopup=Y":"&preventPopup=Y"%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>&cat_adm=OPD');
	}
	else if(option==27)captureFP();
	else if(option==29){abrir_ventana('../admision/print_historial_ubicacion_pac.jsp?fg=ADM&fp=CS&cds='+sala+'&fechaInicio='+fDate+'&fechaFin='+tDate);}
		else if(option==36)abrir_ventana('../facturacion/reg_cargo_dev_new.jsp?fg=PAC&fPage=general_page&bac__code=Y');
		else if(option==35){		abrir_ventana('../planmedico/pm_clientes_list.jsp?fp=admision&tipo=B');		}
	else
	{
		var k=document.result.index.value;
		if(k=='')CBMSG.warning('Por favor seleccione una admisión antes de ejecutar una acción!');
		else
		{
			var msg='';
			var pacId=eval('document.result.pacId'+k).value;
			var noAdmision=eval('document.result.noAdmision'+k).value;
			var dob=eval('document.result.dob'+k).value;
			var dobAnt=eval('document.result.fechaNacimientoAnt'+k).value;
			var codPac=eval('document.result.codPac'+k).value;
			var categoria=eval('document.result.categoria'+k).value;
			var estado=eval('document.result.estado'+k).value;
			var cds=eval('document.result.cds'+k).value;
			var cdsAdm=eval('document.result.centroServicio'+k).value;
			var statusAdm=eval('document.result.statusAdm'+k).value;
			var estadoAtencion=eval('document.result.estadoAtencion'+k).value;
			var fg ='<%=fg%>';
			var cama=eval('document.result.cama'+k).value;
			var cdsAdmDesc=eval('document.result.cdsAdmDesc'+k).value;
			var admRoot = eval('document.result.admRoot'+k).value;
			var dobleCob = eval('document.result.dobleCob'+k).value;
			var contratoPM = eval('document.result.chkContrato'+k).value;
			var categoriaDesc=eval('document.result.categoriaDesc'+k).value;

/*
A=ACTIVO
P=PRE ADMISIONES
S=ESPECIAL
E=ESPERA
I=INACTIVO
C=CANCELADA
N=ANULADA
T=TEMPORAL
H=?
*/
			if((estado=='I' || estado == 'N')&&(option==1||option==3/*||option==5*/||option==6||option==7||option==8||option==10||option==11||option==12||option==13||option==33||option==34||option==39||option==40))CBMSG.warning('No se puede ejecutar la acción para una admisión con estado:'+statusAdm+'!');
			else if((estado == 'P')&&(option==5||option==6||option==7||option==8||option==10||option==11||option==12||option==13||option==15||option==33||option==39))CBMSG.warning('No se puede ejecutar la acción para una admisión con estado:'+statusAdm+'!');
			else if(option==1)abrir_ventana('../admision/admision_config_new.jsp?mode=edit<%=preventPopup?"&preventPopup=Y":""%>&pacId='+pacId+'&noAdmision='+noAdmision+'&cds='+cds+'&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>');
			else if(option==2){
							if (cdsAdm == "<%=cdsEGY%>")
							abrir_ventana('../admision/print_admision.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision+'&fp=CUSTOM');
							else abrir_ventana('../admision/print_admision.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision);
			}
			else if(option==3)
			{
				if(hasDBData('<%=request.getContextPath()%>','tbl_adm_admision','secuencia='+noAdmision+' and pac_id='+pacId+' and estado=\'N\'',''))CBMSG.warning('\n- La Admisión ya está anulada!');
				else
				{
					if(hasDBData('<%=request.getContextPath()%>','tbl_fac_factura','admi_secuencia='+noAdmision+' and pac_id='+pacId+'and compania =<%=(String) session.getAttribute("_companyId")%> and estatus in (\'P\',\'C\') and facturar_a in (\'P\',\'E\')',''))
					{
							var facturas=  getDBData('<%=request.getContextPath()%>','join(cursor(select CODIGO||\' de \'||DECODE(FACTURAR_A,\'E\',\'Empresa\',\'P\',\'Paciente\') FACTURAR_A from tbl_fac_factura where admi_secuencia= '+noAdmision+' and pac_id= '+pacId+' and estatus in (\'P\',\'C\') and facturar_a in (\'P\',\'E\')),\'; \') recibos ','dual','','')
						msg+='\n- La Admisión tiene facturas relacionadas: ['+facturas+'] ';
					}

					if(parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(decode(b.tipo_transaccion,\'C\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) + nvl(sum(decode(b.tipo_transaccion,\'H\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) - nvl(sum(decode(b.tipo_transaccion,\'D\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0)','tbl_fac_transaccion a, tbl_fac_detalle_transaccion b','a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.compania=b.compania and a.tipo_transaccion=b.tipo_transaccion and a.codigo=b.fac_codigo and a.admi_secuencia='+noAdmision+' and a.pac_id='+pacId,''))>0)msg+='\n- La admisión tiene cargos registrados. Debe devolver los cargos para que la admisión quede en cero';


					var recibos =  getDBData('<%=request.getContextPath()%>','join(cursor(select a.recibo  from tbl_cja_transaccion_pago a,tbl_cja_detalle_pago b where a.compania = b.compania and a.anio = b.tran_anio and a.codigo = b.codigo_transaccion  and a.pac_id = '+pacId+' and b.admi_secuencia = '+noAdmision+' and a.rec_status <> \'I\' having sum(b.monto) <> 0 group by a.recibo ),\'; \') recibos ','dual','','')
					if(recibos !='')msg+='\n- Recuerde aplicar el recibo No. [ '+recibos+' ] a la admisión correcta...!';
				var expediente =  getDBData('<%=request.getContextPath()%>',' (select sum(cantidad) from (select count(*) cantidad from tbl_sal_detalle_orden_med o where o.estado_orden = \'A\' and o.pac_id = '+pacId+'  and  o.secuencia  in (  select secuencia from tbl_adm_admision z  where z.pac_id   = '+pacId+'  and   z.adm_root = (select s.adm_root  from tbl_adm_admision s  where s.pac_id  = '+pacId+' and s.secuencia = '+noAdmision+') )   union   select count(*) cantidad  from tbl_sal_resultado_nota o where o.estado = \'A\' and o.pac_id = '+pacId+'  and  o.secuencia  in (  select secuencia from tbl_adm_admision z where z.pac_id   = '+pacId+'  and   z.adm_root = (select s.adm_root from tbl_adm_admision s where s.pac_id =  '+pacId+'   and s.secuencia = '+noAdmision+') ) ) ) expediente ','dual','','')

					//if(parseFloat(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_cama_admision','pac_id='+pacId+' and admision='+noAdmision+' and fecha_final is null',''))>0)msg+='\n- La admisión tiene Cama Asignada. Debe Eliminar la cama o darle Salida.';

					if(msg.length>0)CBMSG.error('La Admisión no se ha podido anular por las siguientes razones:'+msg);
					else{
						CBMSG.confirm('¿Está seguro que desea Anular La Admisión No. '+noAdmision+' del Paciente No. '+codPac+' con Fecha de Nacimiento '+dobAnt+' ??',{btnTxt:'Si,No',cb:function(r){
							if (r=="Si") showPopWin('../common/run_process.jsp?fp=ADM&actType=7&docType=ADM&pacId='+pacId+'&docId='+pacId+'&docNo='+noAdmision+'&noAdmision='+noAdmision+'&compania=<%=session.getAttribute("_companyId")%>&fecha=<%=cFullDate%>',winWidth*.75,winHeight*.65,null,null,'');
						}});
					}
				}//not anulated admision
			}//option 3
			else if(option==4){abrir_ventana('../expediente/expediente_config.jsp?mode=view&fp=admision&pacId='+pacId+'&noAdmision='+noAdmision+'&cds='+cds);}
			else if(option==5)
			{
				if(!hasDBData('<%=request.getContextPath()%>','tbl_adm_beneficios_x_admision',' admision='+noAdmision+' and pac_id='+pacId,''))CBMSG.warning('El paciente no tiene beneficios asignados!');
				else
				{
					if(eval('document.result.estado'+k).value=='A' || eval('document.result.estado'+k).value=='E')
					abrir_ventana('../admision/solicitud_beneficio_new.jsp?pac_id='+pacId+'&admision='+noAdmision+'&categoria='+categoria+'&categoriaDesc='+categoriaDesc);
					//abrir_ventana('../admision/solicitud_beneficio_new.jsp?pac_id='+pacId+'&admision='+noAdmision);
					else{ CBMSG.warning('Solo para pacientes activos y en Espera, se mostraran los datos para consulta..');
					 abrir_ventana('../admision/solicitud_beneficio_new.jsp?mode=view&pac_id='+pacId+'&admision='+noAdmision+'&categoria='+categoria+'&categoriaDesc='+categoriaDesc);
					 }
				}
			}//option 5
			else if(option==6)abrir_ventana('../facturacion/reg_cargo_dev.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&fg=HON&fPage=general_page');
			else if(option==7)abrir_ventana('../facturacion/reg_cargo_dev_new.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&fg=PAC&fPage=general_page');
			else if(option==8)abrir_ventana('../facturacion/reg_analisis_fact.jsp?mode=add&fg=AFA&noAdmision='+noAdmision+'&pacienteId='+pacId);
			else if(option==9)
			{
				if(hasDBData('<%=request.getContextPath()%>','tbl_fac_detalle_transaccion','pac_id='+pacId+' and fac_secuencia='+noAdmision,'')){
					 if (dobleCob=="Y"){
							 showPopWin('../common/xtra_params.jsp?fp=CARGO_DOBLE_COB&fg=DEV&pacId='+pacId+'&noAdmision='+noAdmision, winWidth*.45,winHeight*.45,null,null,'');
					 }else abrir_ventana('../facturacion/print_cargo_dev.jsp?citasSopAdm=<%=citasSopAdm%>&noSecuencia='+noAdmision+'&pacId='+pacId);
				}
				else CBMSG.warning('La admisión no tiene cargos registrados!');
			}
			else if(option==10){
				if(categoria==1){
					if(estado == 'A' || estado == 'S' || estado == 'E'){
						abrir_ventana('../inventario/reg_sol_mat_pacientes.jsp?tr=PAC_S&mode=add&admision='+noAdmision+'&pac_id='+pacId+'&fg=&fPage=general_page');
					} else CBMSG.warning('El estado de la admision no está dentro de los permitidos para hacer una requisición.');
				} else CBMSG.warning('La categoría de la admision no está dentro de los permitidos para hacer una requisición.');
			}
			else if(option==11)
			{
				if (estado=='I'||estado=='N')CBMSG.warning('No se permite realizar solicitudes para admisiones inactivas o anuladas!');
				else
				//if(cdsAdm=='10'||cdsAdm=='115'||cdsAdm=='116'||cdsAdm=='894'||cdsAdm=='885'||cdsAdm=='117')
					abrir_ventana('../admision/reg_solicitud.jsp?<%=isOnlySol?"onlySol=Y&":""%>fp=cds_solicitud_rayx_lab_ped&pacId='+pacId+'&noAdmision='+noAdmision);
				//else CBMSG.warning('El Centro de Servicio de la Admisión no es válida para la opción seleccionada!');
			}
			else if(option==12)
			{
				if (estado=='I'||estado=='N')CBMSG.warning('No se permite realizar solicitudes para admisiones inactivas o anuladas!');
				else abrir_ventana('../admision/reg_solicitud.jsp?fp=cds_solicitud_lab_ext&pacId='+pacId+'&noAdmision='+noAdmision);
			}
			else if(option==13)
			{
				if (estado=='I'||estado=='N')CBMSG.warning('No se permite realizar solicitudes para admisiones inactivas o anuladas!');
				else abrir_ventana('../admision/reg_solicitud.jsp?fp=cds_solicitud_ima&pacId='+pacId+'&noAdmision='+noAdmision);
			}
			else if(option==14)view(pacId,noAdmision);
			else if(option==15)printBarcode(pacId,noAdmision,cdsAdm);
			else if(option==16)
			{
				if (estado=='I')
				{
					if(hasDBData('<%=request.getContextPath()%>','tbl_fac_factura','admi_secuencia='+noAdmision+' and pac_id='+pacId+'and compania =<%=(String) session.getAttribute("_companyId")%> and estatus in (\'P\') and facturar_a in (\'P\',\'E\')',''))
					{
						//sp_adm_actualizar_estado
						if(confirm('¿Está seguro que desea Cambiar el Estado de la Admisión A Espera ??'))
						{
							showPopWin('../common/run_process.jsp?fp=ADM&actType=60&docType=ADM&pacId='+pacId+'&docId='+pacId+'&docNo='+noAdmision+'&noAdmision='+noAdmision+'&compania=<%=session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');
						}else CBMSG.warning('Proceso Cancelado');
					}else{
					if(hasDBData('<%=request.getContextPath()%>','tbl_fac_factura','admi_secuencia='+noAdmision+' and pac_id='+pacId+'and compania =<%=(String) session.getAttribute("_companyId")%> and estatus in (\'C\',\'A\') and facturar_a in (\'P\',\'E\')',''))
					{
						var fCanceladas = getDBData('<%=request.getContextPath()%>','join(cursor(select CODIGO||\' de \'||DECODE(FACTURAR_A,\'E\',\'Empresa\',\'P\',\'Paciente\') FACTURAR_A from tbl_fac_factura where admi_secuencia= '+noAdmision+' and pac_id= '+pacId+' and estatus in (\'C\') and facturar_a in (\'P\',\'E\')),\'; \') facturas ','dual','','')
						var fAnuladas = getDBData('<%=request.getContextPath()%>','join(cursor(select CODIGO||\' de \'||DECODE(FACTURAR_A,\'E\',\'Empresa\',\'P\',\'Paciente\') FACTURAR_A from tbl_fac_factura where admi_secuencia= '+noAdmision+' and pac_id= '+pacId+' and estatus in (\'A\') and facturar_a in (\'P\',\'E\')),\'; \') facturas ','dual','','')

						if(fCanceladas !='')	msg+='\n- La Admisión tiene las Siguientes facturas: Canceladas['+fCanceladas+'] ';
						if(fAnuladas !='')		msg+='\n-  Anuladas['+fAnuladas+'] ';
						if(msg!='')CBMSG.warning(msg);
					}else CBMSG.warning('La admision no tiene Factura consulte con su Administrador de Sistema.');
					}

				}else CBMSG.warning('La Admisión tiene estatus de  '+statusAdm);
			}//16
			else if(option==19){abrir_ventana('../admision/admision_config.jsp?fg=con_sup2&fp=<%=fg%>&mode=edit&pacId='+pacId+'&noAdmision='+noAdmision);}
			else if(option==20)
			{
				if (estado=='E')
				{

				if(hasDBData('<%=request.getContextPath()%>','tbl_adm_categoria_admision',' codigo in ( select column_value  from table( select split((select get_sec_comp_param(<%=(String) session.getAttribute("_companyId")%>,\'CAT_ADM_TRANF\') from dual),\',\') from dual  )) and codigo='+categoria,''))
				{
					if(hasDBData('<%=request.getContextPath()%>','tbl_cja_transaccion_pago ctp,tbl_cja_detalle_pago cdp, tbl_cja_distribuir_pago cdtp','ctp.compania= cdp.compania and ctp.anio = cdp.tran_anio and ctp.codigo = cdp.codigo_transaccion and cdtp.secuencia = cdp.secuencia_pago and cdtp.compania = cdp.compania and cdtp.codigo_transaccion = cdp.codigo_transaccion and cdtp.tran_anio = cdp.tran_anio and ctp.rec_status <> \'I\' and ctp.pac_id = '+pacId+' and cdp.admi_secuencia = '+noAdmision,''))
					{
						CBMSG.warning('Esta admisión no se puede corregir puesto que ya tiene pagos distribuidos...,VERIFIQUE!');
					}else
					{
						var pasaporte= eval('document.result.cedulaPasaporte'+k).value;
					//abrir_ventana('../facturacion/param_transferir_cargos.jsp?fp=<%=fg%>&pacIdMadre='+pacId+'&noAdmisionMadre='+noAdmision+'&pacId='+pacId+'&noAdmision='+noAdmision+'&cedulaPasaporte='+pasaporte+'&fNacMadre='+dob+'&codPacMadre='+codPac);
					showPopWin('../facturacion/param_transferir_cargos.jsp?fp=<%=fg%>&pacIdMadre='+pacId+'&noAdmisionMadre='+noAdmision+'&pacId='+pacId+'&noAdmision='+noAdmision+'&cedulaPasaporte='+pasaporte+'&fNacMadre='+dob+'&codPacMadre='+codPac+'&admRoot='+admRoot,winWidth*.75,winHeight*.40,null,null,'');
					}
					}else CBMSG.warning('Categoria invalida para este Proceso!!');
				}else CBMSG.warning('Solo para Admisiones en Espera');
			}
			else  if(option==21){}//21
			else  if(option==22){abrir_ventana('../admision/editar_fecha_ingreso_egreso.jsp?id='+pacId+'&admision='+noAdmision);}
			else if(option==23)
			{
				if(hasDBData('<%=request.getContextPath()%>','tbl_fac_detalle_transaccion','pac_id='+pacId+' and fac_secuencia='+noAdmision,'')){
					 if (dobleCob=="Y"){
							 showPopWin('../common/xtra_params.jsp?fp=CARGO_DOBLE_COB&fg=DEV_NETO&pacId='+pacId+'&noAdmision='+noAdmision, winWidth*.45,winHeight*.45,null,null,'');
					 }
					 else abrir_ventana('../facturacion/print_cargo_dev_neto.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
				}
				else CBMSG.warning('La admisión no tiene cargos registrados!');
			}
			else if(option==24){abrir_ventana('../admision/frame_doc_admision.jsp?pacId='+pacId+'&noAdmision='+noAdmision+'&mode=edit&tipo=R');}//24
			else if(option==25){abrir_ventana('../expediente/exp_obser_admin.jsp?noAdmision='+noAdmision+'&pacId='+pacId+'&dob='+dob+'&codPac='+codPac+'&fp=admision&tipo=A');}
			else if(option==26){abrir_ventana('../admision/print_historial_ubicacion_pac.jsp?noAdmision='+noAdmision+'&pacId='+pacId);}
			else if(option==28){abrir_ventana('../admision/consulta_general.jsp?mode=view&pacId='+pacId+'&noAdmision='+noAdmision);}
			else if(option==30){abrir_ventana('../escolta/reg_sol_escolta.jsp?mode=add&pacId='+pacId+'&noAdmision='+noAdmision+'&fromCDS='+cdsAdm+'&fromBed='+cama+'&cdsAdmDesc='+cdsAdmDesc+'&admCategory='+categoria);}
			else if(option==31)
			{
			 if(!hasDBData('<%=request.getContextPath()%>','tbl_fac_factura','admi_secuencia='+noAdmision+' and pac_id='+pacId+' and compania =<%=(String) session.getAttribute("_companyId")%> and estatus not in (\'A\') and facturar_a in (\'P\',\'E\')',''))
				{
				 if(estado =='P' || estado=='A' || estado=='E')
				 {
					var _actionDesc = "";
				//if ( estado=="E" || estado=="P" ) _actionDesc = "Activo";
				document.result.admType.value='';
				if(hasActiveAdmision(pacId,noAdmision,estado,categoria,cdsAdm))
				{
				 if(validStatus(pacId,noAdmision,estado, categoria))
				 {
					var admType = document.result.admType.value;
					if(confirm('¿Está seguro que desea Actualizar La Admisión No. '+noAdmision+' del Paciente No. '+codPac+' con Fecha de Nacimiento '+dobAnt+'  '+_actionDesc+' ??'))
					{
						showPopWin('../common/run_process.jsp?fp=ADM&actType=61&docType=ADM&pacId='+pacId+'&docId='+pacId+'&docNo='+noAdmision+'&noAdmision='+noAdmision+'&compania=<%=session.getAttribute("_companyId")%>&estado='+estado+'&admType='+admType,winWidth*.75,winHeight*.65,null,null,'');
					}//Confirm
				 }//validStatus
				}//hasActiveAdmision
				}//estado
				else CBMSG.warning('Solo para Admisiones en estado: PRE-ADMISION, EN ESPERA O ACTIVAS ');
			 }else CBMSG.warning('La Admision se encuentra Facturada.. ');
			}
			else if(option==32)
			{
					if (estado=='N'||estado=='I')
					{
						if(!hasDBData('<%=request.getContextPath()%>','tbl_fac_factura','admi_secuencia='+noAdmision+' and pac_id='+pacId+'and compania =<%=(String) session.getAttribute("_companyId")%> and estatus <> \'A\' and facturar_a in (\'P\',\'E\')',''))
						{
							//sp_adm_actualizar_estado
							if(confirm('¿Está seguro que desea Cambiar el Estado de la Admisión A Espera ??'))
							{
								showPopWin('../common/run_process.jsp?fp=ADM&actType=62&docType=ADM&pacId='+pacId+'&docId='+pacId+'&docNo='+noAdmision+'&noAdmision='+noAdmision+'&compania=<%=session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');
							}else CBMSG.warning('Proceso Cancelado');
						}else{CBMSG.warning('La admision tiene Facturas consulte con su Administrador de Sistema.');}
					}else CBMSG.warning('La Admisión tiene estatus de  '+statusAdm+' No es Permitida esta Acción');
			}
			else if (option==33){showPopWin('../facturacion/reg_cargo_dev_combo.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&fg=PAC&fPage=general_page',winWidth*.85,winHeight*.75,null,null,'');}
			else if(option==34){
			var cat = getDBData('<%=request.getContextPath()%>','getCheckCatAdm(<%=(String) session.getAttribute("_companyId")%>,'+categoria+')','dual','','');
			if(parseInt(cat)>0)abrir_ventana('../admision/admision_config_new.jsp?mode=edit&fg=UPDCAT&pacId='+pacId+'&noAdmision='+noAdmision+'&cds='+cds);
			else CBMSG.warning('La Categoria de la Admisión seleccionada no permite dicha Accion!. ');
			}
			else if(option==37){abrir_ventana('../admision/print_label_unico.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision);}
			else if(option==38){abrir_ventana('../admision/reg_cargos_automaticos.jsp?mode=add&pacId='+pacId+'&noAdmision='+noAdmision+'&admRoot='+admRoot+'&cds='+cds);}
			else if(option==39){abrir_ventana('../facturacion/reg_cargo_cotizacion.jsp?fp=COT&mode=add&pacId='+pacId+'&noAdmision='+noAdmision+'&admRoot='+admRoot+'&cds='+cds);}
			else if(option==40){abrir_ventana('../facturacion/reg_cargo_cotizacion.jsp?fp=PAQ&mode=add&pacId='+pacId+'&noAdmision='+noAdmision+'&admRoot='+admRoot+'&cds='+cds);}
			else if(option==41){showPopWin('../process/fac_cargos_paq.jsp?compania=<%=session.getAttribute("_companyId")%>&pacId='+pacId+'&admision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');}
			else if(option==42) {
				if(hasDBData('<%=request.getContextPath()%>','tbl_fac_detalle_transaccion','pac_id='+pacId+' and fac_secuencia='+noAdmision,'')){
					 abrir_ventana('../facturacion/print_cargo_dev_neto2.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
				} else CBMSG.warning('La admisión no tiene cargos registrados!');
			}
			else if(option==44){abrir_ventana('../admision/print_label_unico.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision+'&nobarcode');}
		}//admision selected
	}//valid option
}


function  hasActiveAdmision(pacId,admision,estado,categoria,cds)
{
	var msg = '';
	var sqlWhere='';
	if(pacId !='')
	{
		if(estado =='P'||estado=='E')
		{
			if(categoria!=1)sqlWhere = ' and centro_servicio='+cds;
			if(parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision','pac_id='+pacId+' and categoria='+categoria+' and estado=\'A\' and secuencia <>'+admision+sqlWhere,''),10)>0)msg='El paciente ya tiene una admisión ACTIVA!';
			if(msg=='')return true;
			else
			{
				CBMSG.warning(msg);
				return false;
			}
		}else {if(estado=='A')CBMSG.warning('Para cambiar a estado Pre-admision la admision no debe tener Cargos.'); return true;}
	}else return false;
}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	var quien = "";

	if( document.result.index.value != ""){
		 var k=document.result.index.value;
		 var cdsAdm=eval('document.result.centroServicio'+k).value;

		 if(cdsAdm==17)
			 quien = "bebé";
		 else
			 quien = "adulto";
	 }
	switch(option)
	{
		case 0:msg='Crear Nueva Admisión';break;
		case 1:msg='Editar Admisión';break;
		case 2:msg='Imprimir Boleta de Admisión';break;
		case 3:msg='Anular Admisión';break;
		case 5:msg='Solicitud de Beneficio';break;
		case 6:msg='Honorario Médico';break;
		case 7:msg='Cargos / Devoluciones de Materiales';break;
		case 8:msg='Análisis y Facturación';break;
		case 9:msg='Imprimir Detalles de Cargos';break;
		case 10:msg='Requisición de Materiales para Paciente';break;
		case 11:msg='Ambulatorio Laboratorio';break;
		case 13:msg='Solicitud de Servicio Ambulatorio de Imagenología';break;
		case 14:msg='Ver Admisión';break;
		case 15:msg='Imprimir Brazalete '+quien; break;
		case 16:msg='Actualizar admision a Espera';break;
		case 19:msg='Cambio de Beneficios';break;
		case 20:msg='Transferencia de Cargos';break;
		case 22:msg='Modificar Fecha Ingreso/Egreso';break;
		case 23:msg='Imprimir Detalles de Cargos Netos';break;
		case 24:msg='Asociar imagenes escaneadas a los documentos del paciente.';break;
		case 25:msg='Observaciones Administrativas';break;
		case 26:msg='Habitaciones Asignadas a Pacientes';break;
		case 27:msg='Lector de Huellas Dactilares';break;
		case 28:msg='Consulta General de Admisiones';break;
		case 29:msg='Habitaciones Asignadas por Centro';break;
		case 30:msg='Anfitrión Escolta';break;
		case 31:msg='Cambio de Estado Admisión';break;
		case 32:msg='Actualizar Admision Inactiva/anulada a Espera';break;
		case 33:msg='Cargos / Devoluciones de Materiales - Combo';break;
		case 34:msg='Cambiar Categoria';break;
			case 35:msg='Imprimir Contrato Plan Médico';break;
			case 36:msg='Cargos / Devoluciones de Materiales - CB';break;
		case 37:msg='Imprimir Label - Individual';break;
		case 38:msg='Cargos Automaticos';break;
		case 39:msg='Cargos Cotizacion';break;
		case 40:msg='Cargos Paquetes';break;
		case 41:msg='Relacionar Cargos a Paquetes';break;
		case 42:msg='Imprimir Detalles de Cargos Netos x Art.';break;
		case 43:msg='Admisión OPD';break;
		case 44:msg='Imprimir Label - Individual Sin Código Barra';break;
		default:msg='NO DISPONIBLE';
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function mouseOut(obj,option){	var optDescObj=document.getElementById('optDesc');setoutc(obj,'ImageBorder');optDescObj.innerHTML='&nbsp;';}
function view(pacId,noAdmision){abrir_ventana('../admision/admision_config_new.jsp?mode=view&pacId='+pacId+'&noAdmision='+noAdmision+'&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>');}
function printBarcode(pacId,noAdmision,cds){abrir_ventana('../admision/print_admision_barcode.jsp?pacId='+pacId+'&noAdmision='+noAdmision+'&cds='+cds);}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=admisionSearch');}
function getPatientDetails(k)
{
	var pacId=eval('document.result.pacId'+k).value;
	var noAdmision=eval('document.result.noAdmision'+k).value;
	var cama=eval('document.result.cama'+k).value;
	var medico=eval('document.result.medico'+k).value;
	var finCama=eval('document.result.finCama'+k).value;
	var asegDesc='';
	var camaDesc=cama;//'';
	var medDesc='';
	var validarAdmEst =eval('document.result.validarAdmEst'+k).value;
	var estado=eval('document.result.estado'+k).value;
	if(validarAdmEst=='S'&&estado !='A'){camaDesc='';cama='';}
	if(validarAdmEst=='S'&& finCama !=''){camaDesc='';cama='';}

	if(pacId!=undefined&&noAdmision!=undefined)
	{
		asegDesc=getDBData('<%=request.getContextPath()%>','y.nombre||decode(z.paq,-1,\'\',\' <span class="TextInfo">< PAQUETE ></span>\')','(select empresa, nvl((select cod_reg from tbl_adm_clasif_x_plan_conv where empresa = a.empresa and convenio = a.convenio and plan = a.plan and categoria_admi = a.categoria_admi and tipo_admi = a.tipo_admi and clasif_admi = a.clasif_admi and paquete = \'S\'),-1) as paq from tbl_adm_beneficios_x_admision a where pac_id = '+pacId+' and admision = '+noAdmision+' and prioridad = 1 and nvl(estado,\'A\') = \'A\') z, tbl_adm_empresa y','z.empresa = y.codigo','');
	}

	if(medico!=undefined)medDesc=getDBData('<%=request.getContextPath()%>','\'[\'||nvl(reg_medico,codigo) ||\'] \'||decode(sexo,\'F\',\'DRA. \',\'M\',\'DR. \')||primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada))','tbl_adm_medico','codigo=\''+medico+'\'','');

	document.getElementById("asegDesc").innerHTML=asegDesc;
	if(validarAdmEst)
	if(camaDesc.trim()=='')
	{
		document.getElementById("camaId").className='TextRow2';
		document.getElementById("camaLabel").style.display='none';
		document.getElementById("camaDesc").style.display='none';
	}
	else
	{
		document.getElementById("camaId").className='TextHeader';
		document.getElementById("camaLabel").style.display='';
		document.getElementById("camaDesc").style.display='';
		document.getElementById("camaDesc").innerHTML=camaDesc;
	}
	document.getElementById("medicoDesc").innerHTML=medDesc;
}
function ListConsentimiento(pacId,noAdmision){
	//var val = '../common/sel_consentimiento.jsp?pacId='+pacId+'&noAdmision='+noAdmision;
	//window.open(val);
	<%if(consetimiento.trim().equals("0")){%>showPopWin('../common/sel_consentimiento_hpp.jsp?pacId='+pacId+'&noAdmision='+noAdmision,winWidth*.75,winHeight*.65,null,null,'');<%}else{%>showPopWin('../common/sel_consentimiento.jsp?pacId='+pacId+'&noAdmision='+noAdmision+'&consetimiento=<%=consetimiento%>',winWidth*.75,winHeight*.65,null,null,'');<%}%>
}
var xHeight=0;
function doAction(){<%if(sbFilter.length() == 0){%>
CBMSG.warning('Estimado usuario, le recomendamos utilizar los Filtros de Busquedas!!!', {
cb: function(r) {
	if (r == 'Ok') document.getElementById("pacBarcode").focus();
}
});
<%}%>
xHeight=objHeight('_tblMain');resizeFrame();document.getElementById("pacBarcode").focus();

<%if(al.size() == 1 && request.getParameter("bac__code__charge") != null){%>
if ($("#estado0").val() != "I" && $("#estado0").val() != "N") abrir_ventana('../facturacion/reg_cargo_dev_new.jsp?noAdmision=<%=noAdmision%>&pacienteId=<%=pacId%>&fg=PAC&fPage=general_page');
<%}%>
}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function captureFP(){abrir_ventana('../biometric/capture_fingerprint.jsp?fp=admision_list&type=PAC&owner=&ckSample=1');}
function validStatus(pacId,noAdmision,estado, cat)
{
	var msg ='';
	var admType = getDBData('<%=request.getContextPath()%>','a.adm_type','tbl_adm_admision a','a.pac_id = '+pacId+' and a.secuencia = '+noAdmision,'');
			document.result.admType.value=admType;
	if(estado=='P'){
		if(parseFloat(getDBData('<%=request.getContextPath()%>','nvl(sum(decode(b.tipo_transaccion,\'C\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) + nvl(sum(decode(b.tipo_transaccion,\'H\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0) - nvl(sum(decode(b.tipo_transaccion,\'D\',b.cantidad*(b.monto + nvl(b.recargo,0)))),0)','tbl_fac_transaccion a, tbl_fac_detalle_transaccion b','a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.compania=b.compania and a.tipo_transaccion=b.tipo_transaccion and a.codigo=b.fac_codigo and a.admi_secuencia='+noAdmision+' and a.pac_id='+pacId,''))>0)msg+='\n- La admisión tiene cargos registrados. Debe devolver los cargos para que la admisión quede en cero';
		if(msg.length>0){CBMSG.warning('La Admisión no se puede cambiar de estado por las siguientes razones:'+msg);
			return false;
		}
		return true;
	}else{


		if (admType == "I"){ // in patient
			/*if(estado=='A'){
			CBMSG.warning('Por favor usa el proceso normal de Salida!');
			return false;
		}*/
		return true;
		}else{
			return true;
		}

	}//else not P
}

$(function(){
	$(".observAyuda, .motivoAnul").tooltip({
	content: function () {

		var $i = $(this).data("i");
		var $type = $(this).data("type");
		var $title = $($(this).prop('title'));
		var $content;

		if($type == "1" ) $content = $("#observAyudaCont"+$i).val();
		else if($type == "2" ) $content = $("#motivoAnulCont"+$i).val();

		var $cleanContent = $($content).text();
		if (!$cleanContent) $content = "";
		return $content;
	}
	,track: true
	,position: { my: "left+15 center", at: "right center", collision: "flipfit" }
	});
});
function chkCharge(k){if(typeof goCharge=='function')goCharge(k);}
function getPB(){
	var pb = $("#pacBarcode").val(), _pb = "";
	if (pb.indexOf("-") > 0){
	try{
		_pb = pb.split("-");
		_pb = _pb[0].lpad(10,"0")+""+_pb[1].lpad(3,"0");
	}catch(e){_pb="";}
	}else if (pb.trim().length == 13) _pb = pb;
	return _pb;
}

jQuery(document).ready(function(){
			 $("#pacBarcode").keyup(function(e){
		var pacBrazalete = pacId = noAdmision = "";
		var key;
		(window.event) ? key = window.event.keyCode : key = e.which;
				var self = $(this);

		if(key == 13){
			pacBrazalete = getPB(self.val());
						pacId = parseInt(pacBrazalete.substr(0,10),10);
				noAdmision = parseInt(pacBrazalete.substr(10),10);
			if(isNaN(pacId))pacId=0;
			if(isNaN(noAdmision))noAdmision=0;
 //document.main.codigo.value=pacId;
 //document.main.noAdmision.value=noAdmision; _preventPopup,onlySol
window.location.href = "../admision/admision_list.jsp?cds=&_preventPopup=<%=_preventPopup%>&bac__code__charge=Y&onlySol=<%=onlySol%>&pacId="+pacId+"&noAdmision="+noAdmision+"&status="+$("#status").val();

		}
	});
});
</script>
<style type="text/css">
<!--
.VerdeAqua {color: #1ABC9C !important;}
-->
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION - TRANSACCIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>

		<% if (isFpEnabled) { %><authtype type='65'><a href="javascript:goOption(27);" class="hint hint--top" data-hint="Lector de Huellas Dactilares"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,27)" onMouseOut="javascript:mouseOut(this,27)" src="../images/lector_de_huellas_dactilares.png"></a></authtype><%}%>
		<authtype type='3'>
			<a href="javascript:goOption(0)" class="hint hint--top" data-hint="Crear Nueva Admisión"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/crear_nueva_admision.png"></a>
		</authtype>
	<authtype type='64'>
			<a href="javascript:goOption(43)" class="hint hint--top" data-hint="Admisión OPD"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,43)" onMouseOut="javascript:mouseOut(this,43)" src="../images/admision_opd.png"></a>
		</authtype>

		<authtype type='4'><a href="javascript:goOption(1)" class="hint hint--top" data-hint="Editar Admisión"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/editar_admision.png"></a></authtype>
		<authtype type='1'><a href="javascript:goOption(14)" class="hint hint--top" data-hint="Ver Admisión"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,14)" onMouseOut="javascript:mouseOut(this,14)"  src="../images/ver_admision.png"></a></authtype>
		<authtype type='50'><a href="javascript:goOption(15)" class="hint hint--top" data-hint="Imprimir Brazalete"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,15)" onMouseOut="javascript:mouseOut(this,15)"  src="../images/imprimir_brazalete.png"></a></authtype>
		<authtype type='2'><a href="javascript:goOption(2)" class="hint hint--top" data-hint="Imprimir Boleta de Admisión"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/imprimir_boleta_de_admision.png"></a></authtype>
		<authtype type='79'><a href="javascript:goOption(37);" class="hint hint--left" data-hint="Imprimir Label"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,37)" onMouseOut="javascript:mouseOut(this,37)" src="../images/label_pac.png"></a></authtype>
		<authtype type='81'><a href="javascript:goOption(44);" class="hint hint--left" data-hint="Imprimir Label Sin Código Barra"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,44)" onMouseOut="javascript:mouseOut(this,44)" src="../images/no-barcode.png"></a></authtype>
		<authtype type='7'><a href="javascript:goOption(3)" class="hint hint--top" data-hint="Anular Admisión"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/anular_admision.png"></a></authtype>

		<authtype type='70'>
		<%/*if(status.equals("P") || status.equals("A") || status.equals("E")){*/%><a href="javascript:goOption(31)" class="hint hint--top" data-hint="Cambiar Estado Admisión"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,31)" onMouseOut="javascript:mouseOut(this,31)" src="../images/cambio_de_estado_admision.png"></a><%//}%>
		</authtype>
		<!--<a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/open-folder.jpg"></a>-->
		<authtype type='51'><a href="javascript:goOption(5)" class="hint hint--top" data-hint="Solicitud de Beneficio"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/solicitud_de_beneficio.png"></a></authtype>
		<authtype type='52'><a href="javascript:goOption(6)" class="hint hint--top" data-hint="Honorario Médico"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/honorario_medico.png"></a></authtype>

		<authtype type='53'>
		<script>function goCharge(k){if(document.result.index.value!=k)setIndex(k);goOption(7);}</script>
		<a href="javascript:goOption(7)" class="hint hint--top" data-hint="Cargos / Devoluciones de Materiales"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/cargos_devoluciones_de_materiales.png"></a>
		<a href="javascript:goOption(36)" class="hint hint--top" data-hint="Cargos / Devoluciones de Materiales - CB"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,36)" onMouseOut="javascript:mouseOut(this,36)" src="../images/cargos_devoluciones_cb.png"></a>
		</authtype>

		<authtype type='71'><a href="javascript:goOption(33)" class="hint hint--top" data-hint="Cargos / Devoluciones de Materiales - Combo"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,33)" onMouseOut="javascript:mouseOut(this,33)" src="../images/icons/_cargo_combo.png"></a></authtype>
		<authtype type='54'><a href="javascript:goOption(8)" class="hint hint--top" data-hint="Análisis y Facturación"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/analisis_y_facturacion.png"></a></authtype>
		<authtype type='55'>
		<a href="javascript:goOption(9)" class="hint hint--left" data-hint="Imprimir Detalles de Cargos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/imprimir_detalles_de_cargo.png"></a>
		<a href="javascript:goOption(23)" class="hint hint--left" data-hint="Imprimir Detalles de Cargos Netos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,23)" onMouseOut="javascript:mouseOut(this,23)" src="../images/imprimir_detalles_de_cargo_neto.png"></a>
		</authtype>
		<authtype type='80'><a href="javascript:goOption(42)" class="hint hint--top" data-hint="Imprimir Detalles de Cargos Netos x Art."><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,42)" onMouseOut="javascript:mouseOut(this,42)" src="../images/imprimir_detalles_de_cargo_neto.png"></a>
		</authtype>
		<authtype type='56'><a href="javascript:goOption(10);" class="hint hint--left" data-hint="Requisición de Materiales para Paciente"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/requisicion_de_materiales_para_pacientes.png"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(11);" class="hint hint--left" data-hint="Ambulatorio Laboratorio"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,11)" onMouseOut="javascript:mouseOut(this,11)" src="../images/ambulatorio_laboratorio.png"></a></authtype>
		<authtype type='59'><a href="javascript:goOption(13);" class="hint hint--left" data-hint="Solicitud de Servicio Ambulatorio de Imagenología"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,13)" onMouseOut="javascript:mouseOut(this,13)" src="../images/solicitud_de_servicio_ambulatorio_de_imagenologia.png"></a></authtype>
		<authtype type='72'><a href="javascript:goOption(20);" class="hint hint--left" data-hint="Transferencia de Cargos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,20)" onMouseOut="javascript:mouseOut(this,20)" src="../images/transferencia_de_cargos.png"></a></authtype>
		<authtype type='66'><a href="javascript:goOption(22);" class="hint hint--left" data-hint="Modficar Fecha Ingreso/Egreso"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,22)" onMouseOut="javascript:mouseOut(this,22)" src="../images/modificar_fecha_ingreso_egreso.png"></a></authtype>
		<authtype type='62'><a href="javascript:goOption(24)" class="hint hint--left" data-hint="Asociar imágenes escaneadas a los documentos del paciente"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,24)" onMouseOut="javascript:mouseOut(this,24)" src="../images/asociar_imagenes_escaneadas_a_los_documentos_del_paciente.png"></a></authtype>
		<authtype type='63'><a href="javascript:goOption(25);" class="hint hint--left" data-hint="Observaciones Administrativas"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,25)" onMouseOut="javascript:mouseOut(this,25)" src="../images/observaciones_administrativas.png"></a></authtype>
		<!--<a href="javascript:goOption(19);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,19)" onMouseOut="javascript:mouseOut(this,19)" src="../images/notes_calendar.gif"></a>-->
		<authtype type='67'><a href="javascript:goOption(26);" class="hint hint--left" data-hint="Habitaciones Asignadas a Pacientes"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,26)" onMouseOut="javascript:mouseOut(this,26)" src="../images/habitaciones_asignadas_a_pacientes.png"></a></authtype>
		<authtype type='68'><a href="javascript:goOption(28);" class="hint hint--left" data-hint="Consulta General de Admisiones"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,28)" onMouseOut="javascript:mouseOut(this,28)" src="../images/consulta_general_de_admisiones.png"></a></authtype>
		<authtype type='69'><a href="javascript:goOption(29);" class="hint hint--left" data-hint="Habitaciones Asignadas por Centro"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,29)" onMouseOut="javascript:mouseOut(this,29)" src="../images/habitaciones_asignadas_por_centro.png"></a></authtype>
		<%if(escolta.trim().equals("S")){%>
		<authtype type='60'><a href="javascript:goOption(30);" class="hint hint--left" data-hint="Anfitrión Escolta"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,30)" onMouseOut="javascript:mouseOut(this,30)" src="../images/anfitrion_escolta.png"></a></authtype><%}%>
		<authtype type='58'><a href="javascript:goOption(32);" class="hint hint--left" data-hint="Actualizar Admisión Inactiva/Anulada a Espera"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,32)" onMouseOut="javascript:mouseOut(this,32)" src="../images/activar.jpg"></a></authtype>
<authtype type='73'><a href="javascript:goOption(34);" class="hint hint--left" data-hint="Cambiar categoria"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,34)" onMouseOut="javascript:mouseOut(this,34)" src="../images/refresh.png"></a></authtype>
<%if(usaPlanMedico.equals("S")){%><authtype type='74'><a href="javascript:goOption(35);" class="hint hint--left" data-hint="Inprimir Formulario de Atenci&oacute;n Plan M&eacute;dico"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,35)" onMouseOut="javascript:mouseOut(this,35)" src="../images/plan_med.png"></a></authtype><%}%>
<authtype type='75'><a href="javascript:goOption(38);" class="hint hint--left" data-hint="Cargos automaticos"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,38)" onMouseOut="javascript:mouseOut(this,38)" src="../images/ajuste_devolucion.png"></a></authtype>
<authtype type='76'><a href="javascript:goOption(39);" class="hint hint--left" data-hint="Cargos Cotizacion"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,39)" onMouseOut="javascript:mouseOut(this,39)" src="../images/payment_adjust.gif"></a></authtype>
<authtype type='77'><a href="javascript:goOption(40)" class="hint hint--left" data-hint="Cargos / Devoluciones - Paquetes"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,40)" onMouseOut="javascript:mouseOut(this,40)" src="../images/cargos_paquetes.png"></a></authtype>
<authtype type='78'><a href="javascript:goOption(41)" class="hint hint--left" data-hint="Relacionar Cargos a Paquetes"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,41)" onMouseOut="javascript:mouseOut(this,41)" src="../images/req_icon.png"></a></authtype>
	 </td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("preventPopup",_preventPopup)%>
<%=fb.hidden("onlySol",onlySol)%>
			<td colspan="3">
			<%sbSql = new StringBuffer();
			if(!UserDet.getUserProfile().contains("0"))
			{
				sbSql.append(" and codigo in (");
					if(session.getAttribute("_cds")!=null)
						sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
					else sbSql.append("-1");
				sbSql.append(")");
			}
			System.out.println("::::::::::::::::::::::::::::: "+sbSql.toString());
			%>
				<cellbytelabel id="1">&Aacute;rea</cellbytelabel>
				<%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_cds_centro_servicio where estado='A' "+sbSql.toString()+" order by 2 asc","cds",cds,false,false,0,"Text10",null,null,null,"T")%>
				<%
					//xmlRdr.setXmlPath("D:/Projects/cellbytedemo/build/web/xml"); //Si queren cambiar la ruta raiz del xml
					//xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId")); //regresa todo el xml
					//xmlRdr.read(xr.xmlPath+"/cds_all.xml",(String) session.getAttribute("_companyId"),false,"0,77,76"); //true: excluye los valores separados por coma; false: imprime solamente los valores separados por coma
				%>
				<%
				try{
				if(sbSql.toString().trim().equals("")){%>
					<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId")),cds,false,false,0,"Text10",null,null,null,"T")%>
				<%}else{%>
					<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId"),false,CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))),cds,false,false,0,"Text10",null,null,null,"T")%>
				<%}
				}catch(Exception e){throw new Exception("No pudimos cargar el archivo XML. Por favor entra en Administración > Centro de Servicio y edita cualquiera para crear el archivo y vuelve a probar!");}
				%>
				<cellbytelabel id="2">Categor&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","categoria",categoria,false,false,0,"Text10",null,null,null,"T")%>
				<cellbytelabel id="3">Estado</cellbytelabel>
				<%=fb.select("status","AE=ACTIVA Y EN ESPERA,A=ACTIVA,P=PREADMISION,S=ESPECIAL,E=ESPERA,I=INACTIVO,N=ANULADA",status,false,false,0,"Text10",null,null,null,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="38%">
				<cellbytelabel id="4">C&eacute;dula / Pasaporte</cellbytelabel>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="23%">
				<cellbytelabel id="5">Fecha Nac.</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="dob"/>
				<jsp:param name="valueOfTBox1" value="<%=dob%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				<!--<cellbytelabel id="6">C&oacute;d. Pac.</cellbytelabel>
					<%//=fb.intBox("codigo","",false,false,false,5,"Text10",null,null)%>--></td>

<td width="39%"><cellbytelabel id="7">No. Adm.</cellbytelabel>
<%=fb.intBox("noAdmision","",false,false,false,5,null,null,"")%> </td>
	</tr>
		<tr class="TextFilter"  >
			<td  colspan="2">
				<cellbytelabel id="8">Paciente</cellbytelabel>
				<%=fb.intBox("pacId","",false,false,false,15,"Text10",null,null)%>
				<%=fb.textBox("paciente",paciente,false,false,false,40,"Text10",null,null)%>
			</td>
			<td>
				<cellbytelabel id="9">Fecha</cellbytelabel>
				<%=fb.select("dateType","I=Ingreso,E=Egreso",dateType)%>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="fDate"/>
				<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
				<jsp:param name="nameOfTBox2" value="tDate"/>
				<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
								<jsp:param name="clearOption" value="true"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextFilter">
			<td colspan="2">
				<cellbytelabel id="10">Aseguradora</cellbytelabel>
				<%=fb.intBox("aseguradora",aseguradora,false,false,false,10,"Text10",null,null)%>
				<%=fb.textBox("aseguradoraDesc",aseguradoraDesc,false,false,false,40,"Text10",null,null)%>
				<%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
				&nbsp;&nbsp;Doble cobertura:<%=fb.checkbox("dobleCob","S",(dobleCob.equalsIgnoreCase("S")),false,null,null,"","CUENTAS DOBLE COBERTURA")%>
				<cellbytelabel id="11">Barcode</cellbytelabel>
				<%=fb.textBox("pacBarcode","",false,false,false,20,"Text10",null,null)%>
								</td>
								<td>
								<%if(admUsarHora){%>
								<cellbytelabel id="9">Hora</cellbytelabel>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2"/>
				<jsp:param name="nameOfTBox1" value="fTime"/>
				<jsp:param name="valueOfTBox1" value="<%=fTime%>"/>
				<jsp:param name="nameOfTBox2" value="tTime"/>
				<jsp:param name="valueOfTBox2" value="<%=tTime%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				<jsp:param name="format" value="hh12:mi am"/>
				<jsp:param name="hintText" value="01:00 am"/>
				<jsp:param name="clearOption" value="true"/>
				</jsp:include>
								<%}%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
					<%fb.appendJsValidation("if((document.search00.fDate.value!='' && !isValidateDate(document.search00.fDate.value))||(document.search00.tDate.value!='' && !isValidateDate(document.search00.tDate.value))||(document.search00.dob.value!='' && !isValidateDate(document.search00.dob.value))){CBMSG.warning('Formato de fecha inválida!');error++;}");%>
<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;
		<authtype type='0'><a href="javascript:printList('PDF')" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>&nbsp;<a href="javascript:printList('XLS')" class="Link00">[ <cellbytelabel>Imprimir Lista (Excel)</cellbytelabel> ]</a></authtype>
	</td>
</tr>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dobleCob",dobleCob)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("fTime",fTime)%>
<%=fb.hidden("tTime",tTime)%>
<%=fb.hidden("preventPopup",_preventPopup)%>
<%=fb.hidden("onlySol",onlySol)%>

			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="12">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="13">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="14">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dobleCob",dobleCob)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("fTime",fTime)%>
<%=fb.hidden("tTime",tTime)%>
<%=fb.hidden("preventPopup",_preventPopup)%>
<%=fb.hidden("onlySol",onlySol)%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder" align="center">
		<table width="100%" border="0" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td width="13%" class="TextHeader"><cellbytelabel id="10">Aseguradora</cellbytelabel></td>
			<td width="25%"><label id="asegDesc"></label><%//=cdo.getColValue("empresa_nombre")%></td>
			<td width="7%" id="camaId"><label id="camaLabel" style="display:none"><cellbytelabel id="15">Cama</cellbytelabel></label></td>
			<td width="10%"><label id="camaDesc" style="display:none"></label><%//=cdo.getColValue("cama")%></td>
			<td width="8%" class="TextHeader"><cellbytelabel id="16">M&eacute;dico</cellbytelabel><%//=medicDisplay%></td>
		 <td width="37%"><label id="medicoDesc"></label><!--[ <%//=cdo.getColValue("medico")%> ] <%//=cdo.getColValue("nombreMedico")%>--></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="0" cellspacing="1" height="25">
		<tr class="TextHeader" align="center">
			<td width="2%">S</td>
			<td width="2%">A</td>
			<td width="2%">C</td>
			<td width="14%"><cellbytelabel id="1">&Aacute;rea</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="17">Cat.</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="5">Fecha Nac.</cellbytelabel></td>
			<td width="3%"><cellbytelabel id="18">Edad</cellbytelabel></td>
			<td width="4%"><cellbytelabel id="6">Pac. Id</cellbytelabel></td>
			<td width="4%"><cellbytelabel id="7">No. Adm.</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="4">C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="8">Paciente</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="19">Fecha Ingreso</cellbytelabel></td>
			<td width="6%"><cellbytelabel id="20">Fecha Egreso</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td width="7%"><cellbytelabel id="21">Consentimiento</cellbytelabel></td>
			<td width="2%">&nbsp;</td>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%=fb.hidden("admType","")%>
<%=fb.hidden("preventPopup",_preventPopup)%>
<%=fb.hidden("onlySol",onlySol)%>
<%
String estado = "";
for (int i=0; i<al.size(); i++)
{
	Admision adm = (Admision) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (adm.getParentesco().equals("1")) color += " VerdeAqua";
	estado = adm.getEstado();
	if (adm.getEstado().equalsIgnoreCase("A")) estado = "ACTIVO";
	else if (adm.getEstado().equalsIgnoreCase("P")) estado = "PREADMISION";
	else if (adm.getEstado().equalsIgnoreCase("S")) estado = "ESPECIAL";
	else if (adm.getEstado().equalsIgnoreCase("E")) estado = "ESPERA";
	else if (adm.getEstado().equalsIgnoreCase("I")) estado = "INACTIVO";
	else if (adm.getEstado().equalsIgnoreCase("N")) estado = "ANULADA";

%>
		<%=fb.hidden("estado"+i,adm.getEstado())%>
		<%=fb.hidden("pacId"+i,adm.getPacId())%>
		<%=fb.hidden("noAdmision"+i,adm.getNoAdmision())%>
		<%=fb.hidden("dob"+i,adm.getFechaNacimiento())%>
		<%=fb.hidden("fechaNacimientoAnt"+i,adm.getFechaNacimientoAnt())%>
		<%=fb.hidden("codPac"+i,adm.getCodigoPaciente())%>
		<%=fb.hidden("categoria"+i,adm.getCategoria())%>
		<%=fb.hidden("cds"+i,adm.getArea())%>
		<%=fb.hidden("centroServicio"+i,adm.getCentroServicio())%>
		<%=fb.hidden("medico"+i,adm.getMedico())%>
		<%=fb.hidden("cama"+i,adm.getCama())%>
		<%=fb.hidden("statusAdm"+i,estado)%>
		<%=fb.hidden("cedulaPasaporte"+i,adm.getCedulaPamd())%>
		<%=fb.hidden("cdsAdmDesc"+i,adm.getCentroServicioDesc())%>
		<%=fb.hidden("pasaporte"+i,adm.getPasaporte())%>
		<%=fb.hidden("estadoAtencion"+i,adm.getStatus())%>
		<%=fb.hidden("admRoot"+i,adm.getAdmRoot())%>
		<%=fb.hidden("validarAdmEst"+i,adm.getRevisadoAdmision())%>
		<%=fb.hidden("dobleCob"+i,adm.getConvenioSolEmp())%>
		<%=fb.hidden("finCama"+i,adm.getFechaFinal())%>
		<%=fb.hidden("chkContrato"+i,adm.getExtension())%>
		<%=fb.hidden("categoriaDesc"+i,adm.getCategoriaDesc())%>
		<%=fb.hidden("observAyudaCont"+i,"<label class='observAyudaCont' style='font-size:11px'>"+(adm.getObservAyuda()==null?"":adm.getObservAyuda())+"</label>")%>
		<%=fb.hidden("motivoAnulCont"+i,"<label class='motivoAnulCont' style='font-size:11px'><strong>"+(adm.getUsuarioAnulacion()==null?"":adm.getUsuarioAnulacion())+"</strong><strong>"+(adm.getFechaAnulacion()==null?"":", "+adm.getFechaAnulacion())+"</strong><br/>"+(adm.getMotivoAnulacion()==null?"":adm.getMotivoAnulacion())+"</label>")%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><% if (!adm.getSalida().equals("0")) { %><span class="span-circled span-circled-20 span-circled-green" data-content="" title="OM SALIDA X EJECUTAR"></span><% } else { %>&nbsp;<% } %></td>
			<td align="center"><% if (adm.getObservacion().trim().equals("")) { %>&nbsp;<% } else { %><span class="span-circled span-circled-20 span-circled-red" data-content="" title="<%=adm.getObservacion()%>"></span><% } %></td>
			<td align="center"><% if (adm.getCondicionPaciente().equalsIgnoreCase("S")) { %><span class="span-circled span-circled-20 span-circled-yellow" data-content="" title="RIESGO DE CAIDA"></span><% } else { %>&nbsp;<% } %></td>
			<td>[<%=adm.getCentroServicio()%>] <%=adm.getCentroServicioDesc()%></td>
			<td align="center" class="hint hint--top" data-hint="<%=adm.getTipoAdmisionDesc()%>"><%=adm.getCategoriaDesc()%></td>
			<td align="center"><%=adm.getFechaNacimientoAnt()%></td>
			<td align="center"><%=adm.getKey()%></td>
			<td align="center"><%=adm.getPacId()%></td>
			<td align="center"><%=adm.getNoAdmision()%></td>
			<td><%=adm.getPasaporte()%></td>
			<td onMouseOver="javascript:displayElementValue('lblPacId<%=i%>',' [<%=adm.getPacId()%>]');" onMouseOut="javascript:displayElementValue('lblPacId<%=i%>','');">
				<a href="javascript:chkCharge(<%=i%>)" class="Link02Bold<%=(adm.getParentesco().equals("1"))?" VerdeAqua":""%>" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">
				<%
				String idF = adm.getVIP();
				String cssClass = "", title = "";
				if (idF.trim().equals("S")) {cssClass = " vip-vip"; title="VIP";}
				else if (idF.trim().equals("D")) {cssClass = " vip-dis"; title="DISTINGUIDO";}
				else if (idF.trim().equals("J")) {cssClass = " vip-jd"; title="JUNTA DIRECTIVA";}
				else if (idF.trim().equals("M")) {cssClass = " vip-med"; title="STAFF MEDICO";}
				else if (idF.trim().equals("A")) {cssClass = " vip-acc"; title="ACCIONISTA";}
				else if (idF.trim().equals("E")) {cssClass = " vip-emp"; title="EMPLEADO";}
				if (idF != null && !idF.trim().equals("N")){
				%>
					<span title="<%=title%>" class="vip<%=cssClass%>"><%=adm.getNombrePaciente()%><label id="lblPacId<%=i%>"></label></span>
				<%}else{%>
					 <%=adm.getNombrePaciente()%><label id="lblPacId<%=i%>"></label>
				<%}%>
				</a>
			</td>
			<td align="center"><%=adm.getFechaIngreso()%><%=(admUsarHora?" "+adm.getAmPm():"")%></td>
			<td align="center"><%=adm.getFechaEgreso()%><%=(admUsarHora?" "+adm.getAmPm2():"")%></td>
			<td align="center">
			 <span class="observAyuda" title="" data-i="<%=i%>" data-type="2"><%=estado%></span>
			</td>
			<td align="center"><a href="javascript:ListConsentimiento(<%=adm.getPacId()%>,<%=adm.getNoAdmision()%>)" class="Link02Bold<%=(adm.getParentesco().equals("1"))?" VerdeAqua":""%>" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="21">Consentimiento</cellbytelabel></a></td>
			<td align="center"><%=fb.radio("check","",false,false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>
</div>
</div>


<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dobleCob",dobleCob)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("preventPopup",_preventPopup)%>
<%=fb.hidden("onlySol",onlySol)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="12">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="13">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="14">hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("aseguradora",aseguradora)%>
<%=fb.hidden("aseguradoraDesc",aseguradoraDesc)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("dobleCob",dobleCob)%>
<%=fb.hidden("paciente",paciente)%>
<%=fb.hidden("fTime",fTime)%>
<%=fb.hidden("tTime",tTime)%>
<%=fb.hidden("preventPopup",_preventPopup)%>
<%=fb.hidden("onlySol",onlySol)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="Text10">
		<span class="span-circled span-circled-20 span-circled-green" data-content="S"></span>OM SALIDA X EJECUTAR
		<span class="span-circled span-circled-20 span-circled-red" data-content="A"></span>ALERGICO
		<span class="span-circled span-circled-20 span-circled-yellow" data-content="C"></span>RIESGO DE CAIDA
		<span title="VIP" class="vip vip-vip">VIP</span>
		<span title="DISTINGUIDO" class="vip vip-dis">DISTINGUIDO</span>
		<span title="JUNTA DIRECTIVA" class="vip vip-jd">JUNTA DIRECTIVA</span>
		<span title="STAFF MEDICO" class="vip vip-med">STAFF MEDICO</span>
		<span title="ACCIONISTA" class="vip vip-acc">ACCIONISTA</span>
		<span title="EMPLEADO" class="vip vip-emp">EMPLEADO</span>
	</td>
</tr>
</table>

<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
