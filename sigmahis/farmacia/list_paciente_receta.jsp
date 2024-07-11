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
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

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

	String categoria = request.getParameter("categoria");
	String status = request.getParameter("status");
	String cedulaPasaporte = request.getParameter("cedulaPasaporte");
	String dob = request.getParameter("dob");
	String codigo = request.getParameter("codigo");
	String noAdmision = request.getParameter("noAdmision");
	String paciente = request.getParameter("paciente");
	String pacId = request.getParameter("pacId");
	String fDate = request.getParameter("fDate");
	String tDate = request.getParameter("tDate");
	if (categoria == null) categoria = "";
	if (status == null) status = "AE";
	if (cedulaPasaporte == null) cedulaPasaporte = "";
	if (dob == null) dob = "";
	if (codigo == null) codigo = "";
	if (noAdmision == null) noAdmision = "";
	if (paciente == null) paciente = "";
	if (pacId == null) pacId = "";
	if (fDate == null) fDate = cDate;
	if (tDate == null) tDate = cDate;

	if (!categoria.trim().equals("")) { sbFilter.append(" and a.categoria = "); sbFilter.append(categoria); }
	
	/*if (status.trim().equals("AE")) { sbFilter.append(" and a.estado in ('A','E')"); }
	else if(status.trim().equals("")) { sbFilter.append(" and a.estado in ('A','E','I')"); }
	else { sbFilter.append(" and a.estado = '"); sbFilter.append(status); sbFilter.append("'"); }*/
	
	if (!cedulaPasaporte.trim().equals("")) { sbFilter.append(" and upper(b.id_paciente) like '%"); sbFilter.append(cedulaPasaporte.toUpperCase()); sbFilter.append("%'"); }
	if (!dob.trim().equals("")) { sbFilter.append(" and b.f_nac = to_date('"); sbFilter.append(dob); sbFilter.append("','dd/mm/yyyy')"); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and a.codigo_paciente = "); sbFilter.append(codigo); }
	if (!noAdmision.trim().equals("")) { sbFilter.append(" and a.secuencia = "); sbFilter.append(noAdmision); }
	if (!paciente.trim().equals("")) { sbFilter.append(" and upper(b.nombre_paciente) like '%"); sbFilter.append(paciente.toUpperCase()); sbFilter.append("%'"); }
	if (!pacId.trim().equals("")) { sbFilter.append(" and a.pac_id = "); sbFilter.append(pacId); }
	
	sbFilter.append(" and exists (select null from tbl_sal_salida_medicamento where pac_id = a.pac_id and admision = a.secuencia and nvl(invalido,'N') = 'N'");
	
	if (!fDate.trim().equals("") && !tDate.trim().equals("")) {
		sbFilter.append(" and trunc(coalesce(fecha_creacion,a.fecha_ingreso,a.fecha_creacion)) between to_date('");
		sbFilter.append(fDate);
		sbFilter.append("','dd/mm/yyyy') and to_date('");
		sbFilter.append(tDate);
		sbFilter.append("','dd/mm/yyyy')");
	}
	sbFilter.append(")");
	
	if (status.equals("1")) sbFilter.append(" and exists (select null from tbl_sal_salida_medicamento where pac_id = a.pac_id and admision = a.secuencia and nvl(despachado,'N') = 'N')"); // Pendiente
	
	else if (status.equals("2")) sbFilter.append(" and exists (select null from tbl_sal_salida_medicamento m where m.pac_id = a.pac_id and m.admision = a.secuencia and nvl(m.despachado,'N') = 'Y' and m.cantidad > nvl((SELECT SUM(CANTIDAD) FROM TBL_SAL_MED_RECETAS_DESPACH WHERE PAC_ID = m.pac_id AND ADMISION = m.admision AND SECUENCIA_MED = m.secuencia AND NO_RECETA = m.no_receta),0)  )"); // Por despachar
	
	else if (status.equals("3")) sbFilter.append(" and exists (select null from tbl_sal_salida_medicamento m where m.pac_id = a.pac_id and m.admision = a.secuencia and nvl(m.despachado,'N') = 'Y' and m.cantidad = (SELECT SUM(CANTIDAD) FROM TBL_SAL_MED_RECETAS_DESPACH WHERE PAC_ID = m.pac_id AND ADMISION = m.admision AND SECUENCIA_MED = m.secuencia AND NO_RECETA = m.no_receta)  )"); // Despachado

	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'EXP_MOSTRAR_ALERGIA_ANT'),'S') as showAllergyAnt from dual");
	issi.admin.CommonDataObject p = SQLMgr.getData(sbSql.toString());

	//if (request.getParameter("categoria") != null) {

		sbSql = new StringBuffer();
		sbSql.append("select coalesce((select max(fecha_creacion) from tbl_sal_salida_medicamento where pac_id = a.pac_id and admision = a.secuencia and nvl(invalido,'N') = 'N'),a.fecha_ingreso,a.fecha_creacion) as sort_date, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.compania, a.pac_id as pacId, a.secuencia as noAdmision, nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy'),' ') as fechaIngreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, a.categoria, a.centro_servicio as centroServicio, a.medico, case when (select count(*) as nRecs from tbl_sec_alert z where z.pac_id = a.pac_id and z.admision = a.secuencia and status = 'A' and z.alert_type in(7,14,15) and exists (select null from tbl_sec_alert_type where id = z.alert_type)) > 0 then 'S' when nvl(a.condicion_paciente,'N') = 'S' then 'S' else 'N' end as condicionPaciente, a.adm_root as admRoot, b.id_paciente as pasaporte, b.vip, decode(b.pasaporte,null,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento,b.pasaporte) as cedulaPamd, to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimientoAnt, b.nombre_paciente/*replace(replace(b.nombre_paciente,upper(a.name_match),a.name_match),upper(a.lastname_match),a.lastname_match)*/ as nombrePaciente, case when a.name_match is not null or a.lastname_match is not null then 1 else 0 end as parentesco, (select nombre_corto from tbl_adm_categoria_admision where codigo = a.categoria) as categoriaDesc, (select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) as centroServicioDesc, (select cds from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.adm_root and rownum = 1) as area/*es el cds para expediente*/, nvl((select estado from tbl_adm_atencion_cu where (pac_id = a.pac_id and secuencia = a.secuencia) and rownum = 1),'X') as status, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),null) as key, (select fn_sal_om_salida(a.pac_id,a.secuencia,'ANE') from dual) as salida, nvl((select fn_sal_alergias(a.pac_id,a.secuencia,'D','");
		sbSql.append(p.getColValue("showAllergyAnt","S"));
		sbSql.append("','N') from dual),' ') as observacion, to_char(coalesce((select max(fecha_creacion) from tbl_sal_salida_medicamento where pac_id = a.pac_id and admision = a.secuencia and nvl(invalido,'N') = 'N'),a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fechaAtencion");
		sbSql.append(" from tbl_adm_admision a, vw_adm_paciente b");
		sbSql.append(" where a.pac_id = b.pac_id /*and a.compania =*/ ");
		//sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 1 desc, 19/*nombre*/, 6/*admision*/");
		System.out.println("................."+sbSql.toString());
		al = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal,Admision.class);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+") ");

	//}

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
document.title = 'Farmacia - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();document.getElementById("pacBarcode").focus();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function printList(p){
 if (p=='PDF') abrir_ventana('../admision/print_list_admision.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');
 else if (p=='XLS'){
	 abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admision/print_list_admision.rptdesign&filter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&pCtrlHeader=true');
 }
}
function showPrescription(pacId,adm){abrir_ventana('../expediente/exp_gen_recetas.jsp?fp=farmacia&pacId='+pacId+'&noAdmision='+adm);}
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
			window.location.href = "<%=request.getContextPath()+request.getServletPath()%>?cds=&&bac__code__charge=Y&pacId="+pacId+"&noAdmision="+noAdmision+"&status="+$("#status").val();
		}
	});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FARMACIA - RECETAS DE PACIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<tr class="TextFilter">
			<td>
				<cellbytelabel id="2">Categor&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","categoria",categoria,false,false,0,"Text10",null,null,null,"T")%>
				<cellbytelabel id="3">Estado</cellbytelabel>
				<%//=fb.select("status","AE=ACTIVA Y EN ESPERA,A=ACTIVA,E=ESPERA,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.select("status","1=PENDIENTE,2=POR DESPACHAR,3=DESPACHADO,4=DESAPROBADO",status,false,false,0,"Text10",null,null,null,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				<cellbytelabel id="4">C&eacute;dula / Pasaporte</cellbytelabel>
				<%=fb.textBox("cedulaPasaporte","",false,false,false,20,"Text10",null,null)%>
				<cellbytelabel id="5">Fecha Nac.</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="dob"/>
				<jsp:param name="valueOfTBox1" value="<%=dob%>"/>
				<jsp:param name="fieldClass" value="Text10"/>
				<jsp:param name="buttonClass" value="Text10"/>
				</jsp:include>
				<cellbytelabel id="7">Admisi&oacute;n</cellbytelabel>
				<%=fb.intBox("noAdmision","",false,false,false,5,"Text10",null,"")%>
				<cellbytelabel id="8">Paciente</cellbytelabel>
				<%=fb.intBox("pacId","",false,false,false,15,"Text10",null,null)%>
				<%=fb.textBox("paciente",paciente,false,false,false,40,"Text10",null,null)%>
				<cellbytelabel id="11">Barcode</cellbytelabel>
				<%=fb.textBox("pacBarcode","",false,false,false,20,"Text10",null,null)%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td>
				<cellbytelabel id="9">Fecha Creac. Receta</cellbytelabel>
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
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
		</tr>
<%fb.appendJsValidation("if((document.search00.fDate.value!='' && !isValidateDate(document.search00.fDate.value))||(document.search00.tDate.value!='' && !isValidateDate(document.search00.tDate.value))||(document.search00.dob.value!='' && !isValidateDate(document.search00.dob.value))){CBMSG.warning('Formato de fecha inválida!');error++;}");%>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
<tr>
	<td align="right"><!--<authtype type='0'><a href="javascript:printList('PDF')" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>&nbsp;</authtype>-->&nbsp;</td>
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
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("paciente",paciente)%>

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
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("paciente",paciente)%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
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
			<td width="5%"><cellbytelabel>Cat.</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fecha Nac.</cellbytelabel></td>
			<td width="3%"><cellbytelabel>Edad</cellbytelabel></td>
			<td width="4%"><cellbytelabel>Pac. Id</cellbytelabel></td>
			<td width="4%"><cellbytelabel>Adm.</cellbytelabel></td>
			<td width="10%"><cellbytelabe>C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="32%"><cellbytelabel>Paciente</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fecha Ingreso</cellbytelabel></td>
			<td width="6%"><cellbytelabel>Fecha Egreso</cellbytelabel></td>
			<td width="7%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="6%"><cellbytelabel>F. Creac. Receta</cellbytelabel></td>
			<td width="5%">&nbsp;</td>
		</tr>
<%fb = new FormBean("result",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%=fb.hidden("admType","")%>
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
		<%=fb.hidden("cedulaPasaporte"+i,adm.getCedulaPamd())%>
		<%=fb.hidden("cdsAdmDesc"+i,adm.getCentroServicioDesc())%>
		<%=fb.hidden("pasaporte"+i,adm.getPasaporte())%>
		<%=fb.hidden("estadoAtencion"+i,adm.getStatus())%>
		<%=fb.hidden("admRoot"+i,adm.getAdmRoot())%>
		<%=fb.hidden("categoriaDesc"+i,adm.getCategoriaDesc())%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><% if (!adm.getSalida().equals("0")) { %><span class="span-circled span-circled-20 span-circled-green" data-content="" title="OM SALIDA X EJECUTAR"></span><% } else { %>&nbsp;<% } %></td>
			<td align="center"><% if (adm.getObservacion().trim().equals("")) { %>&nbsp;<% } else { %><span class="span-circled span-circled-20 span-circled-red" data-content="" title="<%=adm.getObservacion()%>"></span><% } %></td>
			<td align="center"><% if (adm.getCondicionPaciente().equalsIgnoreCase("S")) { %><span class="span-circled span-circled-20 span-circled-yellow" data-content="" title="RIESGO DE CAIDA"></span><% } else { %>&nbsp;<% } %></td>
			<td align="center"><%=adm.getCategoriaDesc()%></td>
			<td align="center"><%=adm.getFechaNacimientoAnt()%></td>
			<td align="center"><%=adm.getKey()%></td>
			<td align="center"><%=adm.getPacId()%></td>
			<td align="center"><%=adm.getNoAdmision()%></td>
			<td><%=adm.getPasaporte()%></td>
			<td>
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
					<span title="<%=title%>" class="vip<%=cssClass%>"><%=adm.getNombrePaciente()%></span>
				<%}else{%>
					 <%=adm.getNombrePaciente()%>
				<%}%>
			</td>
			<td align="center"><%=adm.getFechaIngreso()%></td>
			<td align="center"><%=adm.getFechaEgreso()%></td>
			<td align="center"><%=estado%></td>
			<td align="center"><%=adm.getFechaAtencion()%></td>
			<td align="center"><a onClick="javascript:showPrescription(<%=adm.getPacId()%>,<%=adm.getNoAdmision()%>)" style="cursor:pointer"><img src="../images/px.png" title="Recetas" border="0" style="position:relative;margin-bottom:-10px;margin-top:-10px;margin-left:-10px;margin-right:-10px"></a></td>
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
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("paciente",paciente)%>
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
<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fDate",""+fDate).replaceAll(" id=\"fDate\"","")%>
<%=fb.hidden("tDate",""+tDate).replaceAll(" id=\"tDate\"","")%>
<%=fb.hidden("dob",""+dob).replaceAll(" id=\"dob\"","")%>
<%=fb.hidden("codigo",codigo).replaceAll(" id=\"codigo\"","")%>
<%=fb.hidden("noAdmision",""+noAdmision).replaceAll(" id=\"noAdmision\"","")%>
<%=fb.hidden("cedulaPasaporte",""+cedulaPasaporte).replaceAll(" id=\"cedulaPasaporte\"","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("paciente",paciente)%>
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
