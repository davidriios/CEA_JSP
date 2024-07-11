<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
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
OrdPagoMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String key = "";
StringBuffer sbSql =new StringBuffer();
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String id_beneficiario = request.getParameter("id_beneficiario");
String change = request.getParameter("change");
String tipo = request.getParameter("tipo");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String agrupa_hon = request.getParameter("agrupa_hon");
String fechaDesde = request.getParameter("fechaDesde");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(fecha == null) fecha =cDateTime;
if(fechaDesde == null) fechaDesde = "";
if(id_beneficiario==null) id_beneficiario = "";


if(fg==null) fg = "";
if(fp==null) fp = "";
if(tipo==null) tipo = "";
if(agrupa_hon==null) agrupa_hon = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	if(agrupa_hon.equals("")){
		CommonDataObject cd = new CommonDataObject();
		cd = SQLMgr.getData("select get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'LIQ_RECL_AGRUPAR_HON') agrupa_hon from dual");
		agrupa_hon = cd.getColValue("agrupa_hon");
	}

	sbSql.append("select a.compania, (case tipo when 'M' then (select primer_nombre || decode (segundo_nombre, null, '', ' ' || segundo_nombre) || decode (primer_apellido, null, '', ' ' || primer_apellido) || decode (segundo_apellido, null, '', ' ' || segundo_apellido) || decode (sexo, 'F', decode (apellido_de_casada, null, '', ' DE ' || apellido_de_casada)) from tbl_adm_medico m where m.codigo = a.id_beneficiario) when 'S' then (select nombre from tbl_adm_empresa m where m.codigo = a.id_beneficiario) when 'E' then (select nombre from tbl_pm_centros_atencion m where to_char(m.id) = a.id_beneficiario) when 'B' then (select nombre_paciente from vw_pm_cliente m where to_char(m.codigo) = a.id_beneficiario) end) nombre_beneficiario, case tipo when 'M' then (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.id_beneficiario ) else a.id_beneficiario end as cod_benef, a.id_beneficiario, a.tipo, a.tipo_filtro, nvl(a.genera_odp, 'S') genera_odp, sum(a.monto) monto, sum(nvl (b.pagado, 0)) pagos, sum(a.monto - nvl (b.pagado, 0)) saldo from (select a.compania, a.codigo, a.fecha, a.no_aprob, decode (a.tipo, 0, (case when b.medico is not null then b.medico else to_char (b.empresa) end), 1, to_char (a.empresa), 2, to_char (a.admi_codigo_paciente)) id_beneficiario, decode (a.tipo, 0, (case when b.medico is not null then 'M' else 'S' end), 1, 'E', 2, 'B') tipo, decode(a.tipo, 0, decode(get_sec_comp_param(a.compania, 'LIQ_RECL_AGRUPAR_HON'), 'Y', 'H',(case when b.medico is not null then 'M' else 'S' end)), 1, 'E', 2, 'B') tipo_filtro, a.num_solicitud, a.num_factura, a.admi_codigo_paciente, /*sum (decode (b.tipo_transaccion, 'F', b.cantidad, -b.cantidad) * b.monto)*/ a.total monto, a.poliza, decode (a.tipo, 0, (case when b.medico is not null then (select genera_odp from tbl_adm_medico where codigo = b.medico) else (select genera_odp from tbl_adm_empresa where codigo = b.empresa) end), 1, (select genera_odp from tbl_pm_centros_atencion where id = a.empresa), 2, 'S') genera_odp from tbl_pm_liquidacion_reclamo a, tbl_pm_det_liq_reclamo b where a.no_odp is null and a.anio_odp is null and a.compania = ");	
	sbSql.append(session.getAttribute("_companyId"));
	
	if(!fecha.trim().equals("")){sbSql.append(" and trunc(a.fecha) <= to_date('");sbSql.append(fecha);sbSql.append("', 'dd/mm/yyyy')");}
	if(!fechaDesde.trim().equals("")){sbSql.append(" and trunc(a.fecha) >= to_date('");sbSql.append(fechaDesde);sbSql.append("', 'dd/mm/yyyy')");}
	
	sbSql.append(" and a.compania = b.compania and a.codigo = b.secuencia and a.status = 'A' group by a.compania, a.codigo, a.fecha, a.no_aprob, a.num_solicitud, a.num_factura, a.admi_codigo_paciente, a.poliza, a.tipo, b.medico, b.empresa, a.empresa, a.total) a, (  select op.compania, op.num_id_beneficiario, b.numero_factura, sum (nvl (b.monto, 0)) pagado from tbl_con_cheque c, tbl_cxp_orden_de_pago op, tbl_cxp_orden_de_pago_fact b where op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and c.estado_cheque <> 'A' and op.cod_tipo_orden_pago = 4 and op.cod_compania = b.cod_compania and op.anio = b.anio and op.num_orden_pago = b.num_orden_pago and b.tipo_docto = 'FAC' group by op.compania, op.num_id_beneficiario, b.numero_factura) b where a.compania = b.compania(+) and a.id_beneficiario = b.num_id_beneficiario(+) and a.no_aprob = b.numero_factura(+)");
	if(!tipo.trim().equals("")){sbSql.append(" and a.tipo_filtro = '");sbSql.append(tipo);sbSql.append("'");}
	if(!id_beneficiario.trim().equals("")){sbSql.append(" and a.id_beneficiario = '");sbSql.append(id_beneficiario);sbSql.append("'");}
	sbSql.append(" and getSaldoReclamo(a.compania, a.codigo, a.no_aprob, '");
	if(!fechaDesde.trim().equals("")) sbSql.append(fechaDesde);
	else sbSql.append("ALL");
	sbSql.append("', '");
	sbSql.append(fecha);
	sbSql.append("', a.tipo_filtro) > 0");	
	sbSql.append(" group by a.compania, a.tipo, a.tipo_filtro, a.id_beneficiario, nvl(a.genera_odp, 'S') /*having sum(a.monto - nvl (b.pagado, 0)) > 0*/");	
	
	
	if(request.getParameter("fechaDesde")!=null){
	al = SQLMgr.getDataList(sbSql.toString());}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();if(document.orden_pago.rb){setEncValues(getRadioButtonValue(document.orden_pago.rb))}}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
function doSubmit(value){document.orden_pago.action.value = value;var fechaDesde = document.orden_pago.fechaDesde.value;var fecha = '';if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value; if(fecha==''){alert('Introduzca valores en campos de Fecha (Desde - Hasta).!!');}else{if(fechaDesde!='<%=fechaDesde%>' || fecha!='<%=fecha%>' ){alert('La fecha seleccionada no coincide con la fecha de Busqueda!.');}else{if(chkCeroRegisters()){document.orden_pago.submit();}}}}
function reloadPage(){var fecha = '';if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value;var fechaDesde = document.orden_pago.fechaDesde.value;var tipo = document.orden_pago.tipo.value;window.location = '../planmedico/genera_orden_pago_liq_reclamo.jsp?fecha='+fecha+'&fechaDesde='+fechaDesde+'&tipo='+tipo+'&agrupa_hon=<%=agrupa_hon%>';}
/*function selOtros(){abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');}*/
/*function printDetHon(codigo,tipo){var fecha = '';var tipoR = document.orden_pago.tipoR.value;if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value;var fechaDesde = document.orden_pago.fechaDesde.value;abrir_ventana1('../cxp/print_cxp_honorarios.jsp?fecha='+fecha+'&fechaDesde='+fechaDesde+'&tipoR='+tipoR+'&codigo='+codigo+'&tipo='+tipo);}*/
function chkRB(i){checkRadioButton(document.orden_pago.rb, i);setEncValues(i);}
function setEncValues(i){document.orden_pago.ruc.value = 	eval('document.orden_pago.ruc'+i).value;document.orden_pago.dv.value = 	eval('document.orden_pago.dv'+i).value;document.orden_pago.medico.checked = eval('document.orden_pago.medico'+i).value=='S';document.orden_pago.empresa.checked = eval('document.orden_pago.empresa'+i).value=='S';document.orden_pago.centro.checked = eval('document.orden_pago.centro'+i).value=='S';document.orden_pago.codigo.value = eval('document.orden_pago.codigo'+i).value;}
function calcT(i){
	/*var monto = eval('document.orden_pago.monto'+i).value;
	var ajuste =eval('document.orden_pago.ajuste'+i).value;
	var descuento = eval('document.orden_pago.descuento'+i).value;
	var porc_desc = eval('document.orden_pago.porc_desc'+i).value;
	var retencion = eval('document.orden_pago.retencion'+i).value;
	if(monto == '') monto = 0;
	if(ajuste == '') ajuste = 0;
	if(descuento == '') descuento = 0;
	if(porc_desc == '') porc_desc = 0;
	if(retencion == '') retencion = 0;
	if(porc_desc == 0){
		eval('document.orden_pago.total'+i).value = parseFloat(monto) + parseFloat(ajuste) - parseFloat(descuento) - parseFloat(retencion);
	} else {
		var valor = (parseFloat(monto) + parseFloat(ajuste) - parseFloat(descuento)) * (parseFloat(porc_desc)/100);eval('document.orden_pago.total'+i).value = (parseFloat(monto) + parseFloat(ajuste) - parseFloat(retencion) - parseFloat(descuento)) - parseFloat(valor) ;
	}*/
}

function chkCeroRegisters(){
	var size = document.orden_pago.keySize.value;
	var titulo = getSelectedOptionLabel(document.orden_pago.tipo,'');
	var x = 0;if(document.orden_pago.action.value!='Generar Orden') return true;else {for(i=0;i<size;i++){if(eval('document.orden_pago.generar'+i).checked){x++;break;}}if(x==0) {alert('Seleccione al menos un(a) '+titulo+'!');return false;} else return true;}}
function setAll(){var size = document.orden_pago.keySize.value;for(i=0;i<size;i++){eval('document.orden_pago.generar'+i).checked = document.orden_pago.generar.checked;}}
/*function saveRUC_DV(){var tipo = '';if(document.orden_pago.medico.checked) tipo = 'M';if(document.orden_pago.empresa.checked) tipo = 'E';if(document.orden_pago.centro.checked) tipo = 'C';var codigo = document.orden_pago.codigo.value;var ruc = document.orden_pago.ruc.value;var dv = document.orden_pago.dv.value;showPopWin('../common/run_process.jsp?fp=HON_RUC_DV&actType=4&docType=HON_RUC_DV&compania=<%=session.getAttribute("_companyId")%>&tipo='+tipo+'&ruc='+ruc+'&dv='+dv+'&docId='+codigo,winWidth*.75,winHeight*.65,null,null,'');}*/
function chkDateHon(){if(confirm('Al cambiar de fecha se Estará actualizando la informacion mostrada en pantalla. Desea Continuar????')){reloadPage();}else{document.orden_pago.fechaDesde.value='<%=fechaDesde%>';document.orden_pago.fecha.value='<%=fecha%>';}}
/*function viewEC(code, tipo){abrir_ventana('../cxp/ver_mov_hon.jsp?mode=ver&beneficiario='+code+'&tipo='+tipo+'&fechaini=01/<%=cDateTime.substring(3)%>&fechafin=<%=cDateTime%>');}*/
function printReport(){
	var fDesde = document.orden_pago.fechaDesde.value||'ALL';
	var fHasta = document.orden_pago.fecha.value;
	var tipo = document.orden_pago.tipo.value;
	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_pm_detalle_orden_pago.rptdesign&fDesdeParam="+fDesde+"&fHastaParam="+fHasta+"&tipoBenParam="+tipo);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="HONORARIOS MEDICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0"  id="_tblMain">
	<tr>
		<td class="TableBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<tr>
					<td colspan="6" align="right"><authtype type='2'><a href="javascript:printReport()" class="btn_link">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></authtype>
					</td>
				</tr>
				<tr>
					<td colspan="6"><table align="center" width="100%" cellpadding="0" cellspacing="1">
						<%fb = new FormBean("orden_pago",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("id_beneficiario",id_beneficiario)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("saveOption","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
							<%=fb.hidden("fg",fg)%>
							<%=fb.hidden("codigo","")%>
							<%=fb.hidden("agrupa_hon",agrupa_hon)%>
							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>ORDEN PAGO AUTOMATICA</cellbytelabel></td>
							</tr>
							<tr class="TextFilter">
								<td align="left" colspan="8">Fecha: Desde
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fechaDesde" />
								<jsp:param name="valueOfTBox1" value="<%=fechaDesde%>" />
								<jsp:param name="fieldClass" value="Text10" />
								<jsp:param name="buttonClass" value="Text10" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="jsEvent" value="javascript:chkDateHon();"/>								
								<jsp:param name="onChange" value="javascript:chkDateHon();"/>
								</jsp:include> Hasta
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
								<jsp:param name="fieldClass" value="Text10" />
								<jsp:param name="buttonClass" value="Text10" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="jsEvent" value="javascript:chkDateHon();"/>
								<jsp:param name="onChange" value="javascript:chkDateHon();"/>
								</jsp:include>
								<%=fb.button("consultar","Consultar",true,viewMode,"","","onClick=\"javascript: reloadPage();\"")%>&nbsp;&nbsp;
								<%=fb.select("tipo",(agrupa_hon.equals("Y")?"H=Honorarios":"M=Medico,S=Sociedad Medica")+",E=Empresa,B=Beneficiario,",tipo,false,false,false,0,"Text10","","")%>
								<%//=fb.button("imprimir","Reporte",true,viewMode,"","","onClick=\"javascript: printDetHon('','');\"")%>&nbsp;&nbsp;
								<authtype type='6'>
								<%=fb.button("save","Generar Orden",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%></authtype>
								</td>
							</tr>
							<tr class="">
								<td colspan="8">
								<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

		<!--<div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:240">
		<div id="list_op" width="100%" style="overflow;position:absolute">-->
								<table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="TextHeader02" >
								<td align="center" width="2%"><%=fb.checkbox("generar","", false, false, "", "", "onClick=\"javascript:setAll();\"")%></td>
								<td align="center" width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
								<td align="center" width="41%"><cellbytelabel>Beneficiario</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel>Debito</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel>Credito</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel>Monto</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel> Total</cellbytelabel></td>
								<td align="center" width="2%">&nbsp;</td>
							</tr>
							<%
							System.out.println("al.size()="+al.size());
							for (int i=0; i<al.size(); i++){
								CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
							%>
							<%=fb.hidden("ruc"+i,OP.getColValue("identificacion"))%>
							<%=fb.hidden("dv"+i,OP.getColValue("dv"))%>
							<%=fb.hidden("tipo_orden"+i,OP.getColValue("tipo"))%>
							<%=fb.hidden("ref_type"+i,OP.getColValue("ref_type"))%>
							<%=fb.hidden("ref_id"+i,OP.getColValue("id_beneficiario"))%>
							<%=fb.hidden("saldo"+i,OP.getColValue("saldo"))%>
							<%=fb.hidden("nombre"+i,OP.getColValue("nombre_beneficiario"))%>
							<%=fb.hidden("genera_odp"+i,OP.getColValue("genera_odp"))%>

							<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer">
								<td align="center"><%=fb.checkbox("generar"+i,""+i)%></td>
								<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("cod_benef")%> </td>
								<td align="left" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("nombre_beneficiario")%> </td>
								<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("debit"+i,OP.getColValue("monto"),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Debito",false,"")%></td>
								<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("credit"+i,CmnMgr.getFormattedDecimal(OP.getColValue("pagos")).replace(",",""),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Credito",false,"")%></td>
								<td align="right" onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("monto"+i,CmnMgr.getFormattedDecimal(OP.getColValue("saldo")).replace(",",""),true,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Total",false,"")%></td>
								<td align="right" onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("total"+i,CmnMgr.getFormattedDecimal(OP.getColValue("saldo").replace(",","")),true,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Total",false,"")%></td>
								<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "")%></td>
							</tr>
							<%}%>
							<%=fb.hidden("keySize",""+al.size())%>
							</table>
							</div>
							</div>
							</td></tr>
							<tr class="TextHeader02">
								<td colspan="8">&nbsp;</td>
							</tr>
							<tr class="" >
								<td colspan="8">
									<table align="center" width="100%" cellpadding="0" cellspacing="1">
										<tr class="TextRow01" >											
											<td width="65%"><cellbytelabel>Datos del Beneficiario</cellbytelabel>:<br>
											<cellbytelabel>CEDULA o R.U.C</cellbytelabel>.&nbsp;<%=fb.textBox("ruc","",false,false,false,30,"Text12",null,"")%>&nbsp;
											<cellbytelabel>D.V</cellbytelabel>.<%=fb.textBox("dv","",false,false,false,10,"Text12",null,"")%>
											<authtype type='4'><%//=fb.button("cambiar","Grabar Cambio",true,viewMode,"","","onClick=\"javascript: saveRUC_DV();\"")%></authtype>
											</td>
										</tr>
										<!--
										<tr class="TextRow01" >
											<td><cellbytelabel>M&eacute;dico</cellbytelabel>&nbsp;<%=fb.checkbox("medico","", false, true)%>&nbsp;<cellbytelabel>Empresa</cellbytelabel>&nbsp;<%=fb.checkbox("empresa","", false, true)%>&nbsp;<cellbytelabel>Centro</cellbytelabel>&nbsp;<%=fb.checkbox("centro","", false, true)%></td>
										</tr>
										-->
									</table>
								</td>
							</tr>
						</table></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="6" align="right"></td>
				</tr>
				<%
				fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
				%>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));

	al = new ArrayList();
	String fecha_solicitud = CmnMgr.getCurrentDate("dd/mm/yyyy");
	for(int i=0;i<keySize;i++){
		if(request.getParameter("generar"+i)!=null){
			cdo = new CommonDataObject();
			cdo.addColValue("from_liq_reclamo", "S");
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("anio", "to_number(to_char(sysdate,'yyyy'))");
			cdo.addColValue("fecha_solicitud", fecha_solicitud);
			cdo.addColValue("estado", "P");
			cdo.addColValue("nom_beneficiario", request.getParameter("nombre"+i));
			cdo.addColValue("cod_tipo_orden_pago", "4");
			cdo.addColValue("monto", request.getParameter("total"+i).replace(",",""));
			cdo.addColValue("cheque_girado", "N");
			cdo.addColValue("tipo_orden", request.getParameter("tipo_orden"+i));
			cdo.addColValue("num_id_beneficiario", request.getParameter("ref_id"+i));
			cdo.addColValue("hacer", "S");
			cdo.addColValue("cod_hacienda", "04");
			cdo.addColValue("ruc", request.getParameter("ruc"+i));
			cdo.addColValue("dv", request.getParameter("dv"+i));
			cdo.addColValue("tipo_persona", request.getParameter("tipo_persona"+i));
			cdo.addColValue("tipo", request.getParameter("tipo"+i));
			cdo.addColValue("codigo", request.getParameter("ref_id"+i));
			cdo.addColValue("nombre", request.getParameter("nombre"+i));
			cdo.addColValue("fecha", request.getParameter("fecha"));
			cdo.addColValue("genera_odp", request.getParameter("genera_odp"+i));
			cdo.addColValue("user_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("user_aprobado", (String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_aprobado","sysdate");
			cdo.addColValue("fecha_creacion","sysdate");
			cdo.addColValue("fecha_modificacion","sysdate");
			cdo.addColValue("tipo_odp","LIQ_RECLAMO");
			if(request.getParameter("fechaDesde")!=null && !request.getParameter("fechaDesde").equals("")) cdo.addColValue("fechaDesde", request.getParameter("fechaDesde"));
			else cdo.addColValue("fechaDesde", "ALL");
			cdo.addColValue("observacion", "ORDEN GENERADA DESDE - "+request.getParameter("fechaDesde")+" HASTA "+request.getParameter("fecha"));
			
			  System.out.println(" TIPO ==== "+request.getParameter("tipo"+i)+"  -"+cdo.getColValue("tipo"));
			al.add(cdo);
		}
	}
	if (request.getParameter("action").equals("Generar Orden"))
	{
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		OrdPagoMgr.addOPHon(al);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (OrdPagoMgr.getErrCode().equals("1")){
%>
	alert('<%=OrdPagoMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()%>/planmedico/genera_orden_pago_liq_reclamo.jsp?fecha=<%=request.getParameter("fecha")%>&agrupa_hon=<%=request.getParameter("agrupa_hon")%>';
<%
} else throw new Exception(OrdPagoMgr.getErrException());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
