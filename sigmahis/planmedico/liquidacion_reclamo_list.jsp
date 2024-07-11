<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
<%

SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String compania = (String)session.getAttribute("_companyId");
String userName = (String)session.getAttribute("_userName");
String status = request.getParameter("status");
String codigo = request.getParameter("codigo");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String descripcion = request.getParameter("descripcion");
String cds = request.getParameter("cds");
String tipoTrx = request.getParameter("tipoTrx");
String noAprob = request.getParameter("no_aprob");
String noPoliza = request.getParameter("no_poliza");
String tipo = request.getParameter("tipo");
String cat_reclamo = request.getParameter("cat_reclamo");

StringBuffer sbSql = new StringBuffer();
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

if (codigo == null) codigo = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (descripcion == null) descripcion = "";
if (cds == null) cds = "";
if (tipoTrx == null) tipoTrx = "";
if (noAprob == null) noAprob = "";
if (noPoliza == null) noPoliza = "";
if (status == null) status = "P";
if (tipo == null) tipo = "";
if (cat_reclamo == null) cat_reclamo = "";

if(request.getMethod().equalsIgnoreCase("GET"))
{
		int recsPerPage = 100;
		String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
		if (request.getParameter("searchQuery") != null)
		{
				nextVal = request.getParameter("nextVal");
				previousVal = request.getParameter("previousVal");
				if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
				if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
				if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
				if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
				if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
				 if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
		}

	sbSql = new StringBuffer();
		sbSql.append("select l.codigo, l.no_aprob, nvl(l.descripcion,'N/A') as observacion, l.total, l.nombre_cliente, l.cedula_cliente, l.tipo_transaccion, case when l.tipo = 1 then e.nombre when l.tipo = 0 then case when (select medico from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = 1 and empresa is null and honorario_por = 'M' and rownum = 1 ) is not null then (select 'Dr(a). '||primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = (select medico from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = ");
		sbSql.append(compania);
		sbSql.append(" and empresa is null and honorario_por = 'M' and rownum = 1 )) when (select empresa from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = 1 and medico is null and honorario_por = 'E' and rownum = 1 ) is not null then (select nombre from tbl_adm_empresa where codigo = (select empresa from tbl_pm_det_liq_reclamo where l.codigo = secuencia and compania = 1 and medico is null and honorario_por = 'E' and rownum = 1 )) end when l.tipo = 2 then l.nombre_cliente  end as empresa, l.poliza, case when l.no_odp is not null then 'D' else l.status end status, decode(case when l.no_odp is not null then l.status else l.status end, 'A', 'Aprobado', 'P', 'Pendiente', 'N', 'Anulado', 'R','Rechazado', 'D', 'Pagado') estado_desc, to_char(l.fecha_creacion,'dd/mm/yyyy') fc, nvl(l.from_cargos, 'N') from_cargos, decode(l.tipo,0,'Honorario',1,'Empresa',2,'Beneficiario',' ') tipo, l.usuario_creacion, nvl(l.cat_reclamo, 'NA') cat_reclamo, to_char(l.fecha_reclamo, 'dd/mm/yyyy') fecha_reclamo from tbl_pm_liquidacion_reclamo l, tbl_pm_centros_atencion e where l.empresa = e.id ");

		if (!codigo.trim().equals("")) {
			sbSql.append(" and l.codigo = ");
			sbSql.append(codigo);
		}

		if (!cds.trim().equals("")) {
			sbSql.append(" and l.centro_servicio = ");
			sbSql.append(cds);
		}

		if (!descripcion.trim().equals("")) {
			sbSql.append(" and l.nombre_cliente like '%");
			sbSql.append(descripcion);
			sbSql.append("%'");
		}

		if (!tipoTrx.trim().equals("")) {
			sbSql.append(" and l.tipo_transaccion = '");
			sbSql.append(tipoTrx);
			sbSql.append("'");
		}

		 if (!noAprob.trim().equals("")) {
			sbSql.append(" and l.no_aprob = '");
			sbSql.append(noAprob);
			sbSql.append("'");
		}

		if (!noPoliza.trim().equals("")) {
			sbSql.append(" and l.poliza = '");
			sbSql.append(noPoliza);
			sbSql.append("'");
		}
		if (!cat_reclamo.trim().equals("")) {
			sbSql.append(" and l.cat_reclamo = '");
			sbSql.append(cat_reclamo);
			sbSql.append("'");
		}

		if (!status.trim().equals("")) {
			sbSql.append(" and l.status = '");
			sbSql.append(status);
			sbSql.append("'");
		}

		if (!tipo.trim().equals("")) {
			sbSql.append(" and l.tipo = ");
			sbSql.append(tipo);
		}

		if (!fechaIni.trim().equals("") && !fechaFin.trim().equals("")) {
			sbSql.append(" and trunc(l.fecha) between to_date('");
			sbSql.append(fechaIni);
			sbSql.append("','dd/mm/yyyy') and to_date('");
			sbSql.append(fechaFin);
			sbSql.append("','dd/mm/yyyy')");
		}

		sbSql.append(" order by 1 desc");

	if (request.getParameter("beginSearch") != null ){
				al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
				rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
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
<script>
document.title = 'Plan Medicico - Liquidación de Reclamo - '+document.title;

function doAction(){}
/*
$(document).ready(function(){
	//new
	$("#new").click(function(c){
		abrir_ventana('../planmedico/reg_liquidacion_reclamo.jsp');
	});

	//printing
	$("#print").click(function(p){
		abrir_ventana('../planmedico/print_liquidacion_reclamo_list.jsp?codigo=<%=codigo%>&fechaIni=<%=fechaIni%>&fechaFin=<%=fechaFin%>&descripcion=<%=descripcion%>&cds=<%=cds%>&tipoTrx=<%=tipoTrx%>&no_aprob=<%=noAprob%>&no_poliza=<%=noPoliza%>');
	});

	//viewing
	$(".view").click(function(c){
		var code = $(this).data("codigo");
		var tipoTrx = $(this).data("tipotrx");
		var mode = $(this).data("mode");
		abrir_ventana('../planmedico/reg_liquidacion_reclamo.jsp?mode='+mode+'&codigo='+code+'&tipoTransaccion='+tipoTrx);
	});

});*/

function manage(option,tipo){
	 var i = document.getElementById("curIndex").value;

	 if (option == 'add'){ if(tipo=='CE') abrir_ventana('../planmedico/reg_liquidacion_reclamo.jsp?cat_reclamo=CE&categoria=3');
	 else  abrir_ventana('../planmedico/reg_liquidacion_reclamo.jsp?cat_reclamo=HO');}
	 else if(option=='edit'){

		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			abrir_ventana('../planmedico/reg_liquidacion_reclamo.jsp?mode=edit&codigo='+getCurVal()+'&tipoTransaccion='+getTipoTran()+'&from_cargos='+$("#from_cargos"+i).val()+'&cat_reclamo='+getCatReclamo());
		}
	 }
	 else if(option=='view'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			abrir_ventana('../planmedico/reg_liquidacion_reclamo.jsp?mode=view&codigo='+getCurVal()+'&tipoTransaccion='+getTipoTran()+'&from_cargos='+$("#from_cargos"+i).val()+'&cat_reclamo='+getCatReclamo());
		}
	 }
	 else if(option=='print'){
				var fDesde = document.search01.fechaIni.value||'ALL';
				var fHasta = document.search01.fechaFin.value||'ALL';
				var tipo = document.search01.tipo.value||'ALL';
				var codigo = document.search01.codigo.value||'ALL';
				var cds = document.search01.cds.value||'ALL';
				var tipoTrx = document.search01.tipoTrx.value||'ALL';
				var no_aprob = document.search01.no_aprob.value||'ALL';
				var no_poliza = document.search01.no_poliza.value||'ALL';
				var descripcion = document.search01.descripcion.value||'ALL';
				var estado = document.search01.status.value;
				 if(estado=='P') abrir_ventana('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_liq_reclamo_pendiente.rptdesign&fDesdeParam='+fDesde+'&fHastaParam='+fHasta+'&tipoBenParam='+tipo+'&codigo='+codigo+'&cds='+cds+'&tipoTrx='+tipoTrx+'&noAprob='+no_aprob+'&noPoliza='+no_poliza+'&descripcion='+descripcion);
				 else CBMSG.warning('Impresion solo para Liquidaciones Pendientes!');
			/*if (getCurVal() != ""){
				abrir_ventana('../planmedico/print_liquidacion_reclamo.jsp?codigo='+getCurVal());
			}else{
			}*/
	 }
	 else if (option=='approve'){

			 var codes = $(".checkVal:checked").map(function() {
				 return this.value;
			 }).get();

			 if(codes.length){
					 codes = codes.join(",");
					 showPopWin('../common/run_process.jsp?fp=LIQ_RECL&actType=1&docType=LIQ_RECL&docId='+codes+'&docDesc='+codes,winWidth*.60,winHeight*.50,null,null,'');
			 }
			 else CBMSG.warning('Por favor asegúrese de haber seleccionado al menos una liquidación!');
		} else if (option=='print_form'){

			 if (getCurVal() != ""){
			abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_form_liq_reclamo.rptdesign&idParam="+getCurVal()+'&pCtrlHeader=true');
			}


		}

}
function changeAltTitleAttr(obj,type,ctx){
	var opt = {"view":"Ver","edit":"Editar","print":"Imprimir","approve":"Aprobar","print_form":"Imprimir Formulario"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
		if (getCurVal()!=""){
		obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
		obj.title = opt[type]+" "+ctx+" #"+getCurVal();
		}
	}else{
		document.getElementById("printImg").alt = "Imprimir Lista Reclamo";
		document.getElementById("editImg").alt = "Seleccione un Reclamo a Editar";
		document.getElementById("viewImg").alt = "Seleccione un Reclamo a Ver";
		document.getElementById("printFormImg").alt = "Seleccione un Reclamo a Imprimir";
		document.getElementById("printImg").title = "Imprimir Lista Reclamo";
		document.getElementById("editImg").title = "Seleccione un Reclamo a Editar";
		document.getElementById("viewImg").title = "Seleccione un Reclamo a Ver";
		document.getElementById("printFormImg").title = "Seleccione un Reclamo a Imprimir";
	}
}
function getCurVal(){return document.getElementById("curVal").value;}
function getTipoTran(){return document.getElementById("tipoTran").value;}
function getCatReclamo(){return document.getElementById("catReclamo").value;}
function setId(curVal,curIndex,tipoTran,catReclamo){document.getElementById("curVal").value = curVal;
document.getElementById("curIndex").value = curIndex;document.getElementById("tipoTran").value = tipoTran;document.getElementById("catReclamo").value = catReclamo;}

$(document).ready(function(){
	$("#checkValAll").click(function(c){
		if ($(this).is(":checked")) $(".checkVal").prop("checked",true);
		else $(".checkVal").prop("checked",false);
	});

	// Anular, Rechazar
	$(".reject, .vo-id").click(function(e){
		 e.stopPropagation();

		 var $that = $(this);
		 var i = $that.data("ii");
		 var _status = $that.data("_status");
		 var recId = $("#codigo"+i).val();
		 var _action = {"R":"Rechazar", "N":"Anular"};
		 var noReclamo = $("#no_reclamo"+i).val();

		 var canBeVoided = true; // viene de
		 var tot = 0;
		 if (_status == "N"){
			 tot = hasDBData('<%=request.getContextPath()%>',"tbl_cxp_orden_de_pago a, tbl_cxp_detalle_orden_pago b"," a.estado != \'N\' and a.compania = b.cod_compania and a.anio = b.anio and a.num_orden_pago = b.num_orden_pago and b.cod_compania = <%=compania%> and b.num_factura = '"+noReclamo+"' ",'','') || 0;
			 if (tot > 0) {
				 CBMSG.error("Lo sentimos, pero ya no se puede ANULAR ese reclamo!");
				 return false;
			 }

		 }

		CBMSG.confirm("Estas segur@ de querer "+_action[_status]+" el reclamo # "+recId+"?", {btnTxt:"Si,No", cb:function(r){
				if (r == "Si") {
					var _exe = executeDB('<%=request.getContextPath()%>', "update tbl_pm_liquidacion_reclamo set status = '"+_status+"', fecha_modificacion = sysdate, usuario_modificacion = '<%=userName%>' where compania = <%=compania%> and codigo = "+recId, '','');
					if (_exe) window.location.reload();
					else CBMSG.error("No se ha podido "+_action[_status]+" el reclamo # "+recId);
				}
		 }});
	});

});

function imprimeLista(){
	abrir_ventana('../planmedico/print_liquidacion_reclamo_list.jsp?codigo=<%=codigo%>&fechaIni=<%=fechaIni%>&fechaFin=<%=fechaFin%>&descripcion=<%=descripcion%>&cds=<%=cds%>&tipoTrx=<%=tipoTrx%>&no_aprob=<%=noAprob%>&no_poliza=<%=noPoliza%>&estado=<%=status%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value=""></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr><%//="[2] IMPRIMIR       [3] REGISTRAR       [4] EDITAR"  %>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='3'>
			<img src="../images/add_survey_c.png" alt="Nuevo Reclamo Consulta Externa" title="Nuevo Reclamo Consulta Externa" onClick="javascript:manage('add','CE')" width="32px" height="32px"/>&nbsp;
			<img src="../images/add_survey_h.png" alt="Nuevo Reclamo Hospitalizacion" title="Nuevo Reclamo Hospitalizacion" onClick="javascript:manage('add','HO')" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manage('edit')" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Reclamo')" width="32px" height="32px" id="editImg"/>
			</authtype>&nbsp;
			<authtype type='1'>
			<img src="../images/ver.png" onClick="javascript:manage('view')" onMouseOver="javascript:changeAltTitleAttr(this,'view','Reclamo')" width="32px" height="32px" id="viewImg"/>
			</authtype>&nbsp;
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manage('print')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Reclamo')" id="printImg"/>
			</authtype>

						<authtype type='6'>
			<img src="../images/check_mark.png" onClick="javascript:manage('approve')" onMouseOver="javascript:changeAltTitleAttr(this,'approve','Reclamos')" id="approveImg" width="32px" height="32px"/>
			</authtype>

			<!--<authtype type='50'>
			<img src="../images/imprimir_analisis.png" onClick="javascript:manage('print_form')" onMouseOver="javascript:changeAltTitleAttr(this,'print_form','Atencion')" id="approveImg" width="32px" height="32px"/>
			</authtype>-->

		</td>
	</tr>
<%=fb.formEnd(true)%>
<tr><td>
<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow02"><td>&nbsp;</td></tr>
	<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("beginSearch","")%>
			<td colspan="2">
						<cellbytelabel id="2">C&oacute;digo</cellbytelabel>
						<%=fb.textBox("codigo",codigo,false,false,false,8,10,null,null,"")%>
						&nbsp;<cellbytelabel id="2">Fecha</cellbytelabel>&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fechaIni" />
			<jsp:param name="valueOfTBox1" value="<%=fechaIni%>" />
			<jsp:param name="nameOfTBox2" value="fechaFin" />
			<jsp:param name="valueOfTBox2" value="<%=fechaFin%>" />
			<jsp:param name="clearOption" value="true" />
			</jsp:include>
						&nbsp;&nbsp;<cellbytelabel>Centro Servicio</cellbytelabel>
						<%sbSql = new StringBuffer();
			if(!UserDet.getUserProfile().contains("0"))
			{
				sbSql.append(" and codigo in (");
					if(session.getAttribute("_cds")!=null)
						sbSql.append(CmnMgr.vector2numSqlInClause((java.util.Vector) session.getAttribute("_cds")));
					else sbSql.append("-1");
				sbSql.append(")");
			}
			%>
						<%
				try{
				if(sbSql.toString().trim().equals("")){%>
					<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId")),cds,false,false,0,"Text10","width:100px",null,null,"T")%>
				<%}else{%>
					<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId"),false,CmnMgr.vector2numSqlInClause((java.util.Vector) session.getAttribute("_cds"))),cds,false,false,0,"Text10","width:100px",null,null,"T")%>
				<%}
				}catch(Exception e){throw new Exception("No pudimos cargar el archivo XML. Por favor entra en Administración > Centro de Servicio y edita cualquiera para crear el archivo y vuelve a probar!");}
				%>
						&nbsp;&nbsp;
						<cellbytelabel>Tipo Trx.</cellbytelabel>
						<%=fb.select("tipoTrx","F=Factura,N=Nota de Crédito",tipoTrx,false,false,0,null,null,null,null,"T")%>
						&nbsp;&nbsp;
						<cellbytelabel id="2">Nombre Cliente</cellbytelabel>
						<%=fb.textBox("descripcion",descripcion,false,false,false,30,500,null,null,"")%>

						</td>
						</tr>
						<tr class="TextFilter">
						<td colspan="2"><cellbytelabel>No. Reclamo</cellbytelabel>
						<%=fb.textBox("no_aprob",noAprob,false,false,false,20,500,null,null,"")%>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<cellbytelabel>P&oacute;liza</cellbytelabel>
						<%=fb.textBox("no_poliza",noPoliza,false,false,false,20,500,null,null,"")%>
						&nbsp;&nbsp;
						<cellbytelabel>Estado</cellbytelabel>
						<%=fb.select("status","P=Pendiente,A=Aprobada,N=Anulada,R=Rechazada,D=Pagado",status,false,false,0,null,null,null,null,"T")%>
						&nbsp;&nbsp;
						Tipo Liquidación:<%=fb.select("tipo","0=Honorario,1=Empresa,2=Beneficiario",tipo, false, false, 0,"","","",null,"T")%>
						Tipo Reclamo:<%=fb.select("cat_reclamo","HO=Hospitalizacion,CE=Consulta Externa",cat_reclamo, false, false, 0,"","","",null,"T")%>
						&nbsp;&nbsp;
			<%=fb.submit("go","Ir")%>
						</td>
						</tr>

		<%=fb.formEnd()%>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:imprimeLista()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
		</td>
	</tr>
</table>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
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
				<%=fb.hidden("estado","")%>
								<%=fb.hidden("beginSearch","")%>
								<%=fb.hidden("fechaIni",fechaIni)%>
								<%=fb.hidden("fechaFin",fechaFin)%>
								<%=fb.hidden("codigo",codigo)%>
								<%=fb.hidden("descripcion",descripcion)%>
								<%=fb.hidden("cds",cds)%>
								<%=fb.hidden("tipoTrx",tipoTrx)%>
								<%=fb.hidden("noAprob",noAprob)%>
								<%=fb.hidden("noPoliza",noPoliza)%>
								<%=fb.hidden("status",status)%>
								<%=fb.hidden("tipo",tipo)%>
								<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
										<%=fb.hidden("estado","")%>
										<%=fb.hidden("beginSearch","")%>
								<%=fb.hidden("fechaIni",fechaIni)%>
								<%=fb.hidden("fechaFin",fechaFin)%>
								<%=fb.hidden("codigo",codigo)%>
								<%=fb.hidden("descripcion",descripcion)%>
								<%=fb.hidden("cds",cds)%>
								<%=fb.hidden("tipoTrx",tipoTrx)%>
								<%=fb.hidden("noAprob",noAprob)%>
								<%=fb.hidden("noPoliza",noPoliza)%>
								<%=fb.hidden("status",status)%>
								<%=fb.hidden("tipo",tipo)%>
								<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curVal","")%>
	<%=fb.hidden("curIndex","")%>
	<%=fb.hidden("tipoTran","")%>
	<%=fb.hidden("catReclamo","")%>
	<tr class="TextHeader">
		<td width="4%" align="center">&nbsp;<cellbytelabel>P&oacute;liza</cellbytelabel></td>
		<td width="6%" align="center">&nbsp;<cellbytelabel>Fecha</cellbytelabel></td>
		<td width="6%">&nbsp;<cellbytelabel>No. Recl.</cellbytelabel></td>
		<td width="7%">&nbsp;<cellbytelabel>Tipo Liq.</cellbytelabel></td>
		<td width="15%"><cellbytelabel>A favor de</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Nombre Cliente</cellbytelabel></td>
		<td width="8%" align="center"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
		<td width="5%" align="center"><cellbytelabel>Trx</cellbytelabel></td>
		<td width="6%" align="right"><cellbytelabel>Monto</cellbytelabel></td>
		<td width="8%" align="right"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="8%" align="center"><cellbytelabel>Usuario Crea</cellbytelabel></td>
		<td width="8%" align="center"><cellbytelabel>Fecha Reclamo</cellbytelabel></td>
		<td width="5%" align="center">-</td>
		<td width="5%">&nbsp;</td>
		<td width="5%"><input type="checkbox" name="checkValAll" id="checkValAll" class="checkValAll"></td>
	</tr>

<%
				String grp = "";
								double monto = 0.0;

								for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
								 %>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("poliza")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fc")%></td>
					<td><%=cdo.getColValue("no_aprob")%></td>
					<td><%=cdo.getColValue("tipo")%></td>
					<td>&nbsp;<%=cdo.getColValue("empresa")%></td>
					<td>&nbsp;<%=cdo.getColValue("nombre_cliente")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("cedula_cliente")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("tipo_transaccion")%></td>
					<td align="right">&nbsp;<%=cdo.getColValue("total")%></td>
					<td align="right">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("usuario_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_reclamo")%></td>

										<td align="center" class="Link00Bold">
											 <%if(cdo.getColValue("status")!=null&&cdo.getColValue("status").equals("P")){%>
											 <authtype type='5'>
											 <span class="reject" data-ii="<%=i%>" data-_status="R">Rechazar</span>
											 </authtype>
											 <%} if(cdo.getColValue("status")!=null&&cdo.getColValue("status").equals("A")){%>
												<authtype type='7'>
												<span data-ii="<%=i%>" class="vo-id"  data-_status="N">Anular</span>
												</authtype>
											 <%}%>
										</td>
					<td align="center">
						<!--<a href="#" class="Link00Bold view" data-codigo="<%=cdo.getColValue("codigo")%>" data-tipotrx="<%=cdo.getColValue("tipo_transaccion")%>" data-mode="<%=(cdo.getColValue("status")!=null&&cdo.getColValue("status").equals("A")?"view":"edit")%>"><%=(cdo.getColValue("status")!=null&&cdo.getColValue("status").equals("A")?"Ver":"Edit")%></a>-->

						<%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("codigo")+","+i+", '"+cdo.getColValue("tipo_transaccion")+"', '"+cdo.getColValue("cat_reclamo")+"')\"")%>
					</td>
										<td align="center">
												<%if (cdo.getColValue("status")!=null&&cdo.getColValue("status").equals("P")){%>
													<input type="checkbox" value="<%=cdo.getColValue("codigo")%>" name="checkVal<%=i%>" id="checkVal<%=i%>" class="checkVal" data-i="<%=i%>" data-codes="<%=cdo.getColValue("codigo")%>">
												<%}%>
					</td>
				</tr>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("tipo_transaccion"+i,cdo.getColValue("tipo_transaccion"))%>
				<%=fb.hidden("from_cargos"+i,cdo.getColValue("from_cargos"))%>
				<%=fb.hidden("no_reclamo"+i,cdo.getColValue("no_aprob"))%>
				<%=fb.hidden("cat_reclamo"+i,cdo.getColValue("cat_reclamo"))%>
								<%}%>

<%=fb.formEnd(true)%>

</table>
	</td>
</tr>
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
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
				<%=fb.hidden("estado","")%>
								<%=fb.hidden("beginSearch","")%>
								<%=fb.hidden("fechaIni",fechaIni)%>
								<%=fb.hidden("fechaFin",fechaFin)%>
								<%=fb.hidden("codigo",codigo)%>
								<%=fb.hidden("descripcion",descripcion)%>
								<%=fb.hidden("cds",cds)%>
								<%=fb.hidden("tipoTrx",tipoTrx)%>
								<%=fb.hidden("noAprob",noAprob)%>
								<%=fb.hidden("noPoliza",noPoliza)%>
								<%=fb.hidden("status",status)%>
								<%=fb.hidden("tipo",tipo)%>
								<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
										<%=fb.hidden("estado","")%>
										<%=fb.hidden("beginSearch","")%>
										<%=fb.hidden("fechaIni",fechaIni)%>
										<%=fb.hidden("fechaFin",fechaFin)%>
										<%=fb.hidden("codigo",codigo)%>
										<%=fb.hidden("descripcion",descripcion)%>
										<%=fb.hidden("cds",cds)%>
										<%=fb.hidden("tipoTrx",tipoTrx)%>
										<%=fb.hidden("noAprob",noAprob)%>
								<%=fb.hidden("noPoliza",noPoliza)%>
								<%=fb.hidden("status",status)%>
								<%=fb.hidden("tipo",tipo)%>
								<%=fb.hidden("cat_reclamo",cat_reclamo)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>	</td>
	</tr>
</table>
</body>
</html>
<%
}
%>