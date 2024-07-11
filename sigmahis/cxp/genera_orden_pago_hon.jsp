<%@ page errorPage="../error.jsp"%>
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
CommonDataObject _cdo = new CommonDataObject();
String key = "";
StringBuffer sbSql =new StringBuffer();
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String documento = request.getParameter("documento");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String fechaDesde = request.getParameter("fechaDesde");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String hora = "";
String cta_cancelada = request.getParameter("cta_cancelada");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;
String v_desde = "0", v_hasta = "0", error_en_permiso = "N";
if(fecha == null) fecha =cDateTime;
if(fechaDesde == null) fechaDesde = "";
if(documento==null) documento = "";
if(cta_cancelada==null) cta_cancelada = "N";

if(fg==null) fg = "";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	
	sbSql.append("select nvl(get_sec_comp_param(-1, 'OP_HON_USA_FECHA_DESDE'), 'N') OP_HON_USA_FECHA_DESDE from dual");
	_cdo = SQLMgr.getData(sbSql.toString());
	
	sbSql = new StringBuffer();

	sbSql.append("select tipo, codigo, nombre, tipo_persona, monto, ajuste, totales, retencion, totales - nvl(retencion, 0) total, medico, (case when medico is null and empresa = 'S' then 'S' end) empresa, centro, (case when centro = 'S' then (select ruc from tbl_cds_centro_servicio where codigo = b.codigo) when empresa = 'S' and medico is null then (select ruc from tbl_adm_empresa where codigo = b.codigo) when medico = 'S' then (select identificacion from tbl_adm_medico where codigo = b.codigo) end) ruc, (case when centro = 'S' then (select dv from tbl_cds_centro_servicio where codigo = b.codigo) when empresa = 'S' and medico is null then (select digito_verificador from tbl_adm_empresa where codigo = b.codigo) when medico = 'S' then (select digito_verificador from tbl_adm_medico where codigo = b.codigo) end) dv,nvl(getSaldoHon(b.compania, '");
	sbSql.append(fecha);
	sbSql.append("', b.codigo, b.tipo),0) as saldoFinal,(case when centro = 'S' then 'N' when empresa = 'S' and medico is null then (select decode(forma_pago,2,'Y','N') from tbl_adm_empresa where codigo = b.codigo) when medico = 'S' then (select decode(forma_pago,2,'Y','N') from tbl_adm_medico where codigo = b.codigo) end) as forma_pago,decode(tipo,'H', (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = b.codigo ),b.codigo )as cod_view from (select a.*, (case when tipo in ('H') and exists (select 1 from tbl_adm_medico where codigo = a.codigo) then 'S' end) medico, (case when tipo in ('E') and exists (select 1 from tbl_adm_empresa where to_char(codigo) = a.codigo) then 'S' end) empresa, (case when tipo in ('C') and exists (select 1 from tbl_cds_centro_servicio where codigo = a.codigo) then 'S' end) centro from (select   tipo , h.cod_medico as codigo,nvl(getNombreHon(h.cod_medico,h.tipo,'','HON'),' ') as nombre, tipo_persona, sum (nvl (monto, 0)) monto, sum (nvl (monto_ajuste, 0)) ajuste, sum (nvl (monto, 0)) + sum (nvl (monto_ajuste, 0)) totales, sum (nvl (retencion, 0)) retencion, h.compania from tbl_cxp_hon_det h where compania = ");
	
	sbSql.append(session.getAttribute("_companyId"));
	if(!fecha.trim().equals("")){sbSql.append(" and trunc(h.fecha) <= to_date('");sbSql.append(fecha);sbSql.append("', 'dd/mm/yyyy')");}
	if(!fechaDesde.trim().equals("")){sbSql.append(" and trunc(h.fecha) >= to_date('");sbSql.append(fechaDesde);sbSql.append("', 'dd/mm/yyyy')");}
	if(cta_cancelada.equals("S")){
		sbSql.append("and (exists (select null from tbl_fac_factura f where f.compania = h.compania and f.codigo = h.factura AND NVL(fn_cja_saldo_fact(f.facturar_a, f.compania, f.codigo, f.grang_total), -1) = 0)  or h.factura='S/I') ");
	}
	sbSql.append(" and exists (select cod_medico, nvl(sum(nvl(monto_ajuste,0)), 0) + nvl(sum(nvl(monto,0)), 0) - nvl(sum(nvl(retencion,0)), 0) total from tbl_cxp_hon_det hh where h.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and h.cod_medico = hh.cod_medico and h.tipo = hh.tipo and h.odp_numero is null and pagar='S' group by cod_medico having " );
	sbSql.append(" nvl(sum(nvl(monto_ajuste,0)), 0) + nvl(sum(nvl(monto,0)), 0) - nvl(sum(nvl(retencion,0)), 0)/**/ > 0");
	sbSql.append(")");
 sbSql.append(" and nvl(h.pagar,'S')='S' and (decode(monto_ajuste, null, 0, codigo_paciente) = 0  or origen_aj='CXP' )and h.odp_numero is null group by h.cod_medico,h.tipo, tipo_persona, compania having sum (nvl (monto, 0)) + sum (nvl (monto_ajuste, 0)) > 0) a) b order by nombre asc");

 if(request.getParameter("fechaDesde")!=null){
	al = SQLMgr.getDataList(sbSql.toString());
	hora = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

	}

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
function doSubmit(value){
	var usa_fecha_desde = '<%=_cdo.getColValue("OP_HON_USA_FECHA_DESDE")%>';
	document.orden_pago.action.value = value;var fechaDesde = document.orden_pago.fechaDesde.value;var fecha = '';if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value; if((fechaDesde=='' && usa_fecha_desde == 'S')||fecha==''){alert('Introduzca valores en campos de Fecha (Desde - Hasta).!!');}else{if((fechaDesde!='<%=fechaDesde%>' && usa_fecha_desde == 'S') || fecha!='<%=fecha%>' ){alert('La fecha seleccionada no coincide con la fecha de Busqueda!.');}else{if(chkCeroRegisters()){document.orden_pago.submit();}}}
}
function reloadPage(){var fecha = '';if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value;var fechaDesde = document.orden_pago.fechaDesde.value;window.location = '../cxp/genera_orden_pago_hon.jsp?fecha='+fecha+'&fechaDesde='+fechaDesde+'&cta_cancelada='+document.orden_pago.cta_cancelada.value;}
function selOtros(){abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');}
function printDetHon(codigo,tipo){var fecha = '';var tipoR = document.orden_pago.tipoR.value;if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value;var fechaDesde = document.orden_pago.fechaDesde.value;abrir_ventana1('../cxp/print_cxp_honorarios.jsp?fecha='+fecha+'&fechaDesde='+fechaDesde+'&tipoR='+tipoR+'&codigo='+codigo+'&tipo='+tipo+'&cta_cancelada='+document.orden_pago.cta_cancelada.value);}
function printDetHonExcel(codigo,tipo){var fecha = '';var tipoR = document.orden_pago.tipoR.value;if(document.orden_pago.fecha.value!='') fecha = document.orden_pago.fecha.value;var fechaDesde = document.orden_pago.fechaDesde.value||'ALL';abrir_ventana1('../cellbyteWV/report_container.jsp?reportName=cxp/rpt_cxp_honorarios.rptdesign&fHastaParam='+fecha+'&fDesdeParam='+fechaDesde+'&tipoRParam='+tipoR+'&codigoParam='+codigo+'&tipoParam='+tipo+'&ctaCancelParam='+document.orden_pago.cta_cancelada.value);}
function chkRB(i){checkRadioButton(document.orden_pago.rb, i);setEncValues(i);}
function setEncValues(i){/*document.orden_pago.ruc.value = 	eval('document.orden_pago.ruc'+i).value;document.orden_pago.dv.value = 	eval('document.orden_pago.dv'+i).value;document.orden_pago.medico.checked = eval('document.orden_pago.medico'+i).value=='S';document.orden_pago.empresa.checked = eval('document.orden_pago.empresa'+i).value=='S';document.orden_pago.centro.checked = eval('document.orden_pago.centro'+i).value=='S';document.orden_pago.codigo.value = eval('document.orden_pago.codigo'+i).value;*/}
function calcT(i){var monto = eval('document.orden_pago.monto'+i).value;var ajuste =eval('document.orden_pago.ajuste'+i).value;var descuento = eval('document.orden_pago.descuento'+i).value;var porc_desc = eval('document.orden_pago.porc_desc'+i).value;var retencion = eval('document.orden_pago.retencion'+i).value;if(monto == '') monto = 0;if(ajuste == '') ajuste = 0;if(descuento == '') descuento = 0;if(porc_desc == '') porc_desc = 0;if(retencion == '') retencion = 0;if(porc_desc == 0){eval('document.orden_pago.total'+i).value = parseFloat(monto) + parseFloat(ajuste) - parseFloat(descuento) - parseFloat(retencion);} else {var valor = (parseFloat(monto) + parseFloat(ajuste) - parseFloat(descuento)) * (parseFloat(porc_desc)/100);eval('document.orden_pago.total'+i).value = (parseFloat(monto) + parseFloat(ajuste) - parseFloat(retencion) - parseFloat(descuento)) - parseFloat(valor) ;}}
function chkCeroRegisters(){var size = document.orden_pago.keySize.value;var x = 0;if(document.orden_pago.action.value!='Generar Orden') return true;else {for(i=0;i<size;i++){if(eval('document.orden_pago.generar'+i).checked){x++;break;}}if(x==0) {alert('Seleccione al menos un Médico!');return false;} else return true;}}
function setAll(){var size = document.orden_pago.keySize.value;for(i=0;i<size;i++){eval('document.orden_pago.generar'+i).checked = document.orden_pago.generar.checked;}}
/*function saveRUC_DV(){var tipo = '';if(document.orden_pago.medico.checked) tipo = 'M';if(document.orden_pago.empresa.checked) tipo = 'E';if(document.orden_pago.centro.checked) tipo = 'C';var codigo = document.orden_pago.codigo.value;var ruc = document.orden_pago.ruc.value;var dv = document.orden_pago.dv.value;showPopWin('../common/run_process.jsp?fp=HON_RUC_DV&actType=4&docType=HON_RUC_DV&compania=<%=session.getAttribute("_companyId")%>&tipo='+tipo+'&ruc='+ruc+'&dv='+dv+'&docId='+codigo,winWidth*.75,winHeight*.65,null,null,'');}*/
function chkDateHon(){if(confirm('Al cambiar de fecha se Estará actualizando la informacion mostrada en pantalla. Desea Continuar????')){reloadPage();}else{document.orden_pago.fechaDesde.value='<%=fechaDesde%>';document.orden_pago.fecha.value='<%=fecha%>';}}
function viewEC(code, tipo,codeView){abrir_ventana('../cxp/ver_mov_hon.jsp?mode=ver&beneficiarioView='+codeView+'&beneficiario='+code+'&tipo='+tipo+'&fechaini=01/<%=cDateTime.substring(3)%>&fechafin=<%=cDateTime%>');}

function boletas(tipo,codigo){
  showPopWin('../cxp/registros_trx_honorarios.jsp?fg=ORD&actType=4&docType=ORD&compania=<%=session.getAttribute("_companyId")%>&tipo='+tipo+'&codigo='+codigo+'&fecha=<%=fecha%>&fechaDesde=<%=fechaDesde%>',winWidth*.95,winHeight*.75,null,null,''); }

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
					<td colspan="6"><table align="center" width="100%" cellpadding="0" cellspacing="1">
						<%fb = new FormBean("orden_pago",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("documento",documento)%>
							<%=fb.hidden("errCode","")%>
							<%=fb.hidden("errMsg","")%>
							<%=fb.hidden("saveOption","")%>
							<%=fb.hidden("clearHT","")%>
							<%=fb.hidden("action","")%>
							<%=fb.hidden("fg",fg)%>
							<%=fb.hidden("codigo","")%>
							<%=fb.hidden("hora",""+hora)%>
							<tr class="TextPanel">
								<td colspan="3"><cellbytelabel>HONORARIOS MEDICOS</cellbytelabel></td>
								<td colspan="5" class="RedTextBold"><cellbytelabel>Cambie la "Fecha Desde" solo cuando sea necesario establecer un rango de fecha, de lo contrario se tomar&aacute;n en cuenta todas las transacciones. </cellbytelabel></td>
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
								Fact. Cancelada:
								<%=fb.select("cta_cancelada","N=No,S=Si",cta_cancelada)%>
								<%=fb.button("consultar","Consultar",true,viewMode,"","","onClick=\"javascript: reloadPage();\"")%>&nbsp;&nbsp;
								<%=fb.select("tipoR","PP=Para pagar,P=Pendiente","")%>
								<%=fb.button("imprimir","Reporte",true,viewMode,"","","onClick=\"javascript: printDetHon('','');\"")%>&nbsp;&nbsp;
								<%=fb.button("excel","Excel",true,viewMode,"","","onClick=\"javascript: printDetHonExcel('','');\"")%>&nbsp;&nbsp;
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
								<table align="center" width="100%" cellpadding="0" cellspacing="1">
							<tr class="TextHeader02" >
								<td align="center" width="3%"><%=fb.checkbox("generar","", false, false, "", "", "onClick=\"javascript:setAll();\"")%></td>
								<td align="center" width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
								<td align="center" width="30%"><cellbytelabel>Beneficiario</cellbytelabel></td>
								<td align="center" width="4%">&nbsp;</td>
								<td align="center" width="10%"><cellbytelabel>Monto</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel>Ajuste</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel>Retenci&oacute;n</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel>Total</cellbytelabel></td>
								<td align="center" width="10%"><cellbytelabel>Saldo Actual</cellbytelabel></td>
								<td align="center" width="3%">&nbsp;</td>
							</tr>
							<%
							System.out.println("al.size()="+al.size());
							for (int i=0; i<al.size(); i++){
								CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
							%>
							<%=fb.hidden("ruc"+i,OP.getColValue("ruc"))%>
							<%=fb.hidden("dv"+i,OP.getColValue("dv"))%>
							<%=fb.hidden("medico"+i,OP.getColValue("medico"))%>
							<%=fb.hidden("empresa"+i,OP.getColValue("empresa"))%>
							<%=fb.hidden("centro"+i,OP.getColValue("centro"))%>
							<%=fb.hidden("codigo"+i,OP.getColValue("codigo"))%>
							<%=fb.hidden("nombre"+i,OP.getColValue("nombre"))%>
							<%=fb.hidden("monto"+i,OP.getColValue("monto"))%>
							<%=fb.hidden("tipo_persona"+i,OP.getColValue("tipo_persona"))%>
							<%=fb.hidden("tipo"+i,OP.getColValue("tipo"))%>
							<%=fb.hidden("saldoFinal"+i,OP.getColValue("saldoFinal"))%>
							<%=fb.hidden("forma_pago"+i,OP.getColValue("forma_pago"))%>
							

							<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" title="">
								<td align="center"><%=fb.checkbox("generar"+i,""+i)%></td>
								<td align="center" onClick="javascript:chkRB(<%=i%>);"><%=OP.getColValue("cod_view")%> </td>
								<td align="left" onClick="javascript:chkRB(<%=i%>);javascript:boletas('<%=OP.getColValue("tipo")%>','<%=OP.getColValue("codigo")%>');"><%=OP.getColValue("nombre")%> </td>
								<td align="center" onClick="javascript:printDetHon('<%=OP.getColValue("codigo")%>','<%=OP.getColValue("tipo")%>');">
								<img height="<%=iconSize%>" width="<%=iconSize%>" class="ImageBorder" src="../images/printer_fancy.png"></td>
								<td align="right" onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=CmnMgr.getFormattedDecimal(OP.getColValue("monto"))%>&nbsp;&nbsp;</td>
								<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("ajuste"+i,OP.getColValue("ajuste"),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Ajuste",false,"")%></td>
								<td onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("retencion"+i,CmnMgr.getFormattedDecimal(OP.getColValue("retencion")).replace(",",""),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcT("+i+");\"","Descuento Porcentual",false,"")%></td>
								<td align="right" onClick="javascript:chkRB(<%=i%>);">&nbsp;<%=fb.decBox("total"+i,CmnMgr.getFormattedDecimal(OP.getColValue("total")).replace(",",""),true,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Descuento Porcentual",false,"")%></td>
								<td align="right">&nbsp;
								<%if(Double.parseDouble(OP.getColValue("saldoFinal"))<Double.parseDouble(OP.getColValue("totales"))){%><label  class="TextRow01" style="cursor:pointer"><label class="RedTextBold">&nbsp;&nbsp;<%}%>						
						<authtype type='50'><a href="javascript:viewEC('<%=OP.getColValue("codigo")%>','<%=OP.getColValue("tipo")%>','<%=OP.getColValue("cod_view")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel><%=CmnMgr.getFormattedDecimal(OP.getColValue("saldoFinal"))%></cellbytelabel></a></authtype>
								
					<%if(Double.parseDouble(OP.getColValue("saldoFinal"))<Double.parseDouble(OP.getColValue("totales"))){%>&nbsp;&nbsp;</label></label><%}%></td>
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
							<!--<tr class="" >
								<td colspan="8">
									<table align="center" width="100%" cellpadding="0" cellspacing="1">
										<tr class="TextRow01" >
											
											<td width="65%"><cellbytelabel>Datos del Beneficiario</cellbytelabel>:<br>
											<cellbytelabel>CEDULA o R.U.C</cellbytelabel>.&nbsp;<%=fb.textBox("ruc","",false,false,false,30,"Text12",null,"")%>&nbsp;
											<cellbytelabel>D.V</cellbytelabel>.<%=fb.textBox("dv","",false,false,false,10,"Text12",null,"")%>
											<authtype type='4'><%=fb.button("cambiar","Grabar Cambio",true,viewMode,"","","onClick=\"javascript: saveRUC_DV();\"")%></authtype>
											</td>
										</tr>
										<tr class="TextRow01" >
											<td><cellbytelabel>M&eacute;dico</cellbytelabel>&nbsp;<%=fb.checkbox("medico","", false, true)%>&nbsp;<cellbytelabel>Empresa</cellbytelabel>&nbsp;<%=fb.checkbox("empresa","", false, true)%>&nbsp;<cellbytelabel>Centro</cellbytelabel>&nbsp;<%=fb.checkbox("centro","", false, true)%></td>
										</tr>
									</table>
								</td>
							</tr>-->
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
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("anio", "to_number(to_char(sysdate,'yyyy'))");
			cdo.addColValue("fecha_solicitud", fecha_solicitud);
			cdo.addColValue("estado", "A");
			cdo.addColValue("nom_beneficiario", request.getParameter("nombre"+i));
			cdo.addColValue("cod_tipo_orden_pago", "1");
			cdo.addColValue("monto", request.getParameter("total"+i));
			cdo.addColValue("cheque_girado", "N");
			cdo.addColValue("tipo_orden", "N");
			cdo.addColValue("num_id_beneficiario", request.getParameter("codigo"+i));
			if(request.getParameter("medico"+i)!=null && request.getParameter("medico"+i).equals("S")) cdo.addColValue("cod_medico", request.getParameter("codigo"+i));
			if(request.getParameter("empresa"+i)!=null && request.getParameter("empresa"+i).equals("S")) cdo.addColValue("cod_empresa", request.getParameter("codigo"+i));
			if(request.getParameter("forma_pago"+i)!=null && !request.getParameter("forma_pago"+i).equals("")) cdo.addColValue("ach", request.getParameter("forma_pago"+i));
			
			cdo.addColValue("hacer", "S");
			cdo.addColValue("cod_hacienda", "04");
			cdo.addColValue("ruc", request.getParameter("ruc"+i));
			cdo.addColValue("dv", request.getParameter("dv"+i));
			cdo.addColValue("tipo_persona", request.getParameter("tipo_persona"+i));
			cdo.addColValue("tipo", request.getParameter("tipo"+i));
			cdo.addColValue("codigo", request.getParameter("codigo"+i));
			cdo.addColValue("nombre", request.getParameter("nombre"+i));
			if(request.getParameter("descuento"+i)!=null && !request.getParameter("descuento"+i).equals(""))cdo.addColValue("descuento", request.getParameter("descuento"+i));
			if(request.getParameter("porc_desc"+i)!=null && !request.getParameter("porc_desc"+i).equals(""))cdo.addColValue("porc_desc", request.getParameter("porc_desc"+i));
			cdo.addColValue("fecha", request.getParameter("fecha"));
			cdo.addColValue("user_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("user_aprobado", (String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_aprobado","sysdate");
			cdo.addColValue("fecha_creacion","sysdate");
			cdo.addColValue("fecha_modificacion","sysdate");
			if (request.getParameter("fechaDesde")!=null && !request.getParameter("fechaDesde").equals("")){ 
				cdo.addColValue("fechaDesde", request.getParameter("fechaDesde"));
				cdo.addColValue("fechaHora",request.getParameter("hora"));
				cdo.addColValue("observacion", "ORDEN GENERADA DESDE - "+request.getParameter("fechaDesde")+" HASTA "+request.getParameter("fecha"));
			} else cdo.addColValue("observacion", "ORDEN GENERADA HASTA "+request.getParameter("fecha"));
			
			cdo.addColValue("cta_cancelada",request.getParameter("cta_cancelada"));
			
			
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
	window.location = '<%=request.getContextPath()%>/cxp/genera_orden_pago_hon.jsp?fecha=<%=request.getParameter("fecha")%>&fechaDesde=<%=request.getParameter("fechaDesde")%>';
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
