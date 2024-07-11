<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="iCaract" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iMarca" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alD = new ArrayList();
ArrayList al2 = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String cuentaCode = request.getParameter("cuentaCode");
String bancoCode = request.getParameter("bancoCode");

String compania =  (String) session.getAttribute("_companyId");
String secuencia = request.getParameter("secuencia");
String userCrea = "";
String userMod = "";
String fechaCrea = "";
String fechaMod = "";
boolean viewMode = false;
String color = "TextRow01";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss");
String tab = request.getParameter("tab");
if (mode == null)
{
	mode = "add";
}
if(!mode.equals("view")) viewMode = false;
else viewMode = true;

if (tab == null) tab = "0";
int caracLastLineNo = 0;
String key = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		 cdo.addColValue("usua_crea",(String) session.getAttribute("_userName"));
		 cdo.addColValue("fecha_crea",cDateTime.substring(0,10));
		 cdo.addColValue("fecha_entrada",cDateTime.substring(0,10));
		 cdo.addColValue("final_garantia","");
		 cdo.addColValue("valor_inicial","0");
		 cdo.addColValue("valor__mejor_acum","0");
		 cdo.addColValue("meses_depre_act","0");
		 cdo.addColValue("acum_deprem","0");
		 cdo.addColValue("valor_deprem","0");
		 cdo.addColValue("valor_depre_mejora","0");
		 cdo.addColValue("acum_deprec","0");
		 cdo.addColValue("valor_mejora_actual","0");
		 cdo.addColValue("valor_actual","0");
		 cdo.addColValue("valor_rescate","0");
		 cdo.addColValue("valor_total","0");
		 cdo.addColValue("cod_flia","");

		secuencia = "0";

	}
	else
	{
		if (secuencia == null) throw new Exception("Activo no es vlido. Por favor intente nuevamente!");


		 sql = "select a.secuencia, a.entrada_codigo, a.cuentah_activo, a.cuentah_espec, a.cuentah_detalle, a.estatus, a.tipo_activo, a.cod_provee, a.cuentah_activo||'-'||a.cuentah_espec||'-'||a.cuentah_detalle||'-'||b.descripcion listado_activo , to_char(a.fecha_de_entrada,'dd/mm/yyyy') fecha_entrada, a.observacion, a.cod_articulo, a.cod_clase, a.cod_flia, a.porcentaje, nvl(a.placa,a.placa_nueva) placaVal, a.ue_codigo, a.nivel_codigo_ubic, c.descripcion unidad_desc, decode(a.tipo_activo,'I','INMUEBLE','B','BIEN','T','TERRENO') tipo, a.npoliza, a.cond_fisica, a.placa, a.placa_nueva,  to_char(a.fecha_crea,'dd/mm/yyyy') fecha_crea, a.factura, to_char(a.final_garantia,'dd/mm/yyyy') final_garantia, a.vida_estimada, a.tipo_de_depre, a.estatus, a.valor__mejor_acum, a.valor_inicial, a.meses_depre_act, a.acum_deprem, a.valor_deprem, a.valor_depre_mejora, a.acum_deprec, a.valor_mejora_actual, a.valor_actual, a.valor_rescate, (nvl(a.valor_actual,0) + nvl(a.valor_mejora_actual,0)) valor_total, a.usua_crea, h.descripcion cuentah_desc, b.descripcion clasif_desc, a.cod_clasif as grupo_clasif, u.descripcion ubicacion_desc, t.descripcion entrada_desc, p.nombre_proveedor proveedor_desc, v.descripcion grupo_desc,(select descripcion from tbl_con_catalogo_gral cg where compania=a.compania and cg.cta1=nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia)) and cg.cta2=nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia)) and cg.cta3=nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))and cg.cta4=nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia)) and cg.cta5=nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))and cg.cta6=nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia)) )descDepre,nvl(a.gasto1,getCtaGastDepre(a.compania,'C1',a.ue_codigo,a.cod_flia))as gasto1,nvl(a.gasto2,getCtaGastDepre(a.compania,'C2',a.ue_codigo,a.cod_flia))as gasto2,nvl(a.gasto3,getCtaGastDepre(a.compania,'C3',a.ue_codigo,a.cod_flia))as gasto3,nvl(a.gasto4,getCtaGastDepre(a.compania,'C4',a.ue_codigo,a.cod_flia))as gasto4,nvl(a.gasto5,getCtaGastDepre(a.compania,'C5',a.ue_codigo,a.cod_flia))as gasto5,nvl(a.gasto6,getCtaGastDepre(a.compania,'C6',a.ue_codigo,a.cod_flia))as gasto6,to_char(a.fecha_salida,'dd/mm/yyyy') as fecha_salida from tbl_con_activos a, tbl_con_detalle_otro b, tbl_sec_unidad_ejec c, tbl_con_clasif_hacienda v, tbl_con_especificacion h, tbl_com_proveedor p, tbl_con_tipo_entrada t, tbl_con_ubic_fisica u where a.compania="+(String)session.getAttribute("_companyId")+" /*and a.cuentah_activo = b.cod_espec(+) and a.cuentah_espec = b.codigo_subesp(+) and a.cuentah_detalle = b.codigo_detalle(+) and a.compania = b.cod_compania(+)*/ and a.compania=b.cod_compania(+) and a.cuentah_detalle=b.codigo_detalle(+)  and a.compania = c.compania(+) and a.ue_codigo = c.codigo(+) and a.cod_clasif = v.cod_clasif(+) and a.cuentah_activo =h.cta_control(+) and a.cuentah_espec = h.codigo_espec(+) and a.compania = h.compania(+) and a.entrada_codigo = t.codigo_entrada(+) and a.cod_provee = p.cod_provedor(+) and a.compania = p.compania(+) and a.nivel_codigo_ubic = u.codigo_ubic(+) and a.secuencia = '"+secuencia+"' order by a.secuencia";
		 cdo = SQLMgr.getData(sql);
			if (!secuencia.equalsIgnoreCase("")&& !(secuencia == null))
			{
				sql ="select cd_ano anio, to_char(to_date(cd_mes,'mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes, to_char(valor_act_ant,'999,999,990.00') vAnterior, to_char(monto_depre,'999,999,990.00') montoDep, to_char(valor_activo_act,'999,999,990.00') vActual, to_char(depre_acum_act,'999,999,990.00') deprecAcum from tbl_con_deprec_mensual where compania ="+compania+" and activo_sec ="+secuencia+" order by cd_ano, cd_mes ";
				alD = SQLMgr.getDataList(sql);

				if(cdo != null && cdo.getColValue("grupo_clasif")!= null && !cdo.getColValue("grupo_clasif").trim().equals("") )
				{
					sql=" select ch.cod_clasif, lc.secuencia_campos, r.campo_char,lc.descripcion from tbl_con_resp_por_campos r,tbl_con_campos_por_clasif cc,tbl_con_clasif_hacienda ch,tbl_con_lista_campos  lc where r.act_sec(+) = '"+secuencia+"' and r.cod_compania(+) ="+(String)session.getAttribute("_companyId")+" and r.cod_clasif(+) = cc.chacienda and r.sec_campos(+) = cc.cod_campos and cc.chacienda = ch.cod_clasif and lc.secuencia_campos = cc.cod_campos and ch.cod_clasif = "+cdo.getColValue("grupo_clasif")+" order by lc.secuencia_campos ";
					al2 = SQLMgr.getDataList(sql);
				}
			}
	}
%>
<html>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
function getListadoActivo(){abrir_ventana('../common/search_especificacion.jsp?fp=activo');}
function getListadoDetalle(){abrir_ventana('../activos/sel_detalle_cuenta.jsp?fg=activo');}
function getListadoGrupo(){abrir_ventana('../activos/list_clasificacion.jsp?fp=activo&id=1');}
function getListadoUnidad(){abrir_ventana('../common/search_depto.jsp?fp=activo'); }
function getListadoUbicacion(){abrir_ventana('../common/search_depto.jsp?fp=fisica'); }
function getListadoEntrada(){abrir_ventana('../common/search_depto.jsp?fp=entrada'); }
function getListadoProveedor(){abrir_ventana('../common/search_proveedor.jsp?fp=activo'); }
function getDepreciacion()
{
	var inicial = document.form0.valor_inicial.value;
	var vidaEst = document.form0.vida_estimada.value;
	var valor_actual = document.form0.valor_actual.value;
	var tipo_de_depre = document.form0.tipo_de_depre.value;
	var porcentaje = "";
	var deprec = "0";
	var rescate ="0";

	if(vidaEst==0 || vidaEst == null) alert('Vida Estimada sin registro...Verifique...');
	if(tipo_de_depre =='LINEAR'){
	porcentaje = 100 / vidaEst;
	deprec = (((inicial * porcentaje) / 100) /12);
	rescate = (inicial * 0.01);
	document.form0.valor_deprem.value = deprec.toFixed(2);
	document.form0.porcentaje.value = porcentaje.toFixed(2);
	document.form0.valor_rescate.value = rescate.toFixed(2);
	document.form0.valor_actual.value = inicial;}
	else{
	document.form0.valor_deprem.value = deprec;
	document.form0.porcentaje.value = porcentaje;
	document.form0.valor_rescate.value = rescate;
	document.form0.valor_actual.value = inicial;}

	getMejora();
}

function getDepreAcum()
{
	var inicial = parseFloat(document.form0.valor_inicial.value);
	var meses = document.form0.meses_depre_act.value;
	var vidaEst = document.form0.vida_estimada.value * 12;
	var deprem = document.form0.valor_deprem.value;
	var rescate = document.form0.valor_rescate.value;
	var deprec = "";
	var valor = "";

	if (rescate==0) rescate ="1";

	if(vidaEst==0 || meses == null) alert('Vida Estimada / Meses Depreciados sin registro...Verifique...');

	if(meses > vidaEst) alert('Los meses son mayores a la vida estimada, VERIFIQUE!');
	else {

		deprec = (meses * deprem);
		document.form0.acum_deprec.value = deprec.toFixed(2);
		if((inicial - deprec) < rescate ) {
			document.form0.valor_actual.value = rescate;
			document.form0.valor_total.value = rescate;
		} else {
			valor = (inicial - deprec);
			document.form0.valor_actual.value = valor.toFixed(2);
		}

		if (meses==null) document.form0.meses_depre_act.value=0;
	}
}

function getMejora()
{
var actual = parseFloat(document.form0.valor_actual.value);
var mejora = parseFloat(document.form0.valor_mejora_actual.value);
var porcentaje = "";
var deprec = "";
var valor = "";
if(actual==0) alert('Valor Actual sin registro...Verifique...');
if(mejora!=null) mejora = document.form0.valor_mejora_actual.value;
 mejora = parseFloat(document.form0.valor_mejora_actual.value);
valor = actual+mejora;
document.form0.valor_total.value = valor.toFixed(2);

}
function getFactura(){var codProv = document.form0.cod_provee.value;if(codProv !='')abrir_ventana('../inventario/sel_recepcion.jsp?fp=activos&codProveedor='+codProv);else alert('Seleccione Provedor.!');}
function calcVida()
{
 // calcular final garantia
 var vidaEstimada = eval('document.form0.vida_estimada').value;
 var fechaEntrada = eval('document.form0.fecha_entrada').value;
 if (vidaEstimada!=''&&fechaEntrada!='')
 {
	finalGarantia =  getDBData('<%=request.getContextPath()%>','fn_con_final_garantia( \''+fechaEntrada+'\', '+vidaEstimada+') finalGarantia ','dual','','')
	//alert('Final Garantia='+finalGarantia);
	if (finalGarantia!='') 	document.form0.final_garantia.value = finalGarantia;
 }

}

function doAction() {  }
function addCuenta(fp){abrir_ventana1('../common/search_catalogo_gral.jsp?fp='+fp);}
</script>
<script language="javascript">
<%if(mode.equalsIgnoreCase("add")){%>
document.title=" Activo Fijo Agregar - "+document.title;
<%}else if(mode.equalsIgnoreCase("edit")){%>
document.title="Activo Fijo Edición - "+document.title;
<%}%>
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - TRANSACCION - ACTIVO FIJO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr>
			<td>


<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table id="tbl_generales" width="99%" cellpadding="0" border="0" cellspacing="1" align="center">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("userCrea",userCrea)%>
<%=fb.hidden("userMod",userMod)%>
<%=fb.hidden("fechaMod",fechaMod)%>
<%=fb.hidden("usua_crea",cdo.getColValue("usua_crea"))%>
<%=fb.hidden("cargo_uso","N")%>
<%=fb.hidden("cod_articulo",cdo.getColValue("cod_articulo"))%>
<%=fb.hidden("cod_clase",cdo.getColValue("cod_clase"))%>
<%=fb.hidden("porcentaje",cdo.getColValue("porcentaje"))%>
<%=fb.hidden("cod_clasif",cdo.getColValue("grupo_clasif"))%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("caracSize",""+iCaract.size())%>
<%=fb.hidden("caracLastLineNo",""+caracLastLineNo)%>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse; border-top:1.0pt solid #d0deea; border-bottom:1.0pt solid #d0deea; border-left:1.0pt solid #d0deea; border-right:1.0pt solid #d0deea;">
				<tr>
					<td id="TPrincipal" align="left" width="100%" onClick="javascript:showHide(0)" onMouseover="bcolor('#5c7188','TPrincipal');" onMouseout="bcolor('#8f9ba9','TPrincipal');">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="97%" >&nbsp;Activos</td>
								<td width="3%" align="right">&nbsp;[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
		<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1" border=1 bordercolor="#d0deea" style="border-collapse:collapse;">
							<tr class="<%=color%>">
								<td width="15%">Fecha de Creaci&oacute;n :</td>
								<td width="30%"> <%=fb.textBox("fecha_crea",cdo.getColValue("fecha_crea"),true,false,true,15)%></td>
								<td width="20%" align="center"> Secuencia : &nbsp; <%=fb.textBox("secuencia",secuencia,true,false,true,10)%></td>
								<td width="35%" align="center"> Fecha de Entrada : &nbsp;
					<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fecha_entrada" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_entrada")%>" />
									</jsp:include> </td>
							</tr>
							<tr class="<%=color%>">
								<td>Grupo Cta de Activo</td>
								<td colspan="3"><%=fb.textBox("cuentah_activo",cdo.getColValue("cuentah_activo"),true,false,true,7)%>
												<%=fb.textBox("cuentah_espec",cdo.getColValue("cuentah_espec"),true,false,true,7)%>
								<%=fb.textBox("cuentah_desc",cdo.getColValue("cuentah_desc"),true,false,true,55)%>
												<%=fb.button("btnAct","...",false,false,null,null,"onClick=\"javascript:getListadoActivo()\"")%>&nbsp;&nbsp;&nbsp;*Grupo por cuenta contable</td>
							</tr>
							<tr class="<%=color%>">
								<td>Grupo</td>
								<td colspan="3"><%=fb.textBox("grupo_clasif",cdo.getColValue("grupo_clasif"),true,false,true,7)%>
								<%=fb.textBox("grupo_desc",cdo.getColValue("grupo_desc"),true,false,true,67)%>
								<%=fb.button("btnGrupo","...",false,false,null,null,"onClick=\"javascript:getListadoGrupo()\"")%>&nbsp;&nbsp;&nbsp;**para detallar características</td>
						</tr>
							<tr class="<%=color%>">
								<td>Clasificaci&oacute;n</td>
								<td colspan="3"><%=fb.textBox("cuentah_detalle",cdo.getColValue("cuentah_detalle"),true,false,true,7)%>
								<%=fb.textBox("clasif_desc",cdo.getColValue("clasif_desc"),true,false,true,67)%>
								<%=fb.button("btnClasif","...",false,false,null,null,"onClick=\"javascript:getListadoDetalle()\"")%></td>
						</tr>

				<tr class="<%=color%>">
								<td>Familia</td>
								<td colspan="3"><%=fb.select(ConMgr.getConnection(),"select to_char(cod_flia) as cod_flia,nombre||' - '||cod_flia descripcion from tbl_inv_familia_articulo where compania = "+(String)session.getAttribute("_companyId")+"  and cod_flia in(select column_value as familia from table( select split((select get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'FLIA_ACTIVO') from dual ),',') from dual  ) ) union select ' ', 'SELECCIONE' from dual order by 2 asc","cod_flia",cdo.getColValue("cod_flia"),true,false,((!cdo.getColValue("cod_flia").trim().equals(""))?true:false),0,"","","","","","","","")%>

								</td>
						</tr>
							<tr class="TextHeader02">
								<td colspan="4">Ubicación del Activo</td>
				</tr>
				<tr class="<%=color%>">
					<td> Unidad Administrativa : </td>
					<td colspan="2">
						<%=fb.textBox("ue_codigo",cdo.getColValue("ue_codigo"),true,false,true,7)%>
						<%=fb.textBox("unidad_desc",cdo.getColValue("unidad_desc"),true,false,true,55)%>
						<%=fb.button("btnunidad","...",false,false,null,null,"onClick=\"javascript:getListadoUnidad()\"")%></td>
								 <td> # Placa:&nbsp;<%=fb.textBox("placa",cdo.getColValue("placa"),true,false,false,10,10)%></td>
							</tr>
				<tr class="<%=color%>">
					<td> Ubicaci&oacute;n F&iacute;sica : </td>
				<td colspan="2">
								<%=fb.textBox("nivel_codigo_ubic",cdo.getColValue("nivel_codigo_ubic"),false,false,true,7)%>
								<%=fb.textBox("ubicacion_desc",cdo.getColValue("ubicacion_desc"),false,false,true,55)%>
								<%=fb.button("btnubicacion","...",false,false,null,null,"onClick=\"javascript:getListadoUbicacion()\"")%></td>
								<td> <!--# Placa Nueva:&nbsp;<%//=fb.textBox("placa_nueva",cdo.getColValue("placa_nueva"),false,false,true,10,10)%>--></td>
							</tr>
				<tr class="<%=color%>">
				<td> Cuenta de Gasto : </td>
				<td colspan="3">
								<%=fb.textBox("gasto1",cdo.getColValue("gasto1"),true,false,true,3)%>
							<%=fb.textBox("gasto2",cdo.getColValue("gasto2"),true,false,true,3)%>
							<%=fb.textBox("gasto3",cdo.getColValue("gasto3"),true,false,true,3)%>
							<%=fb.textBox("gasto4",cdo.getColValue("gasto4"),true,false,true,3)%>
							<%=fb.textBox("gasto5",cdo.getColValue("gasto5"),true,false,true,3)%>
							<%=fb.textBox("gasto6",cdo.getColValue("gasto6"),true,false,true,3)%>
							<%=fb.textBox("descDepre",cdo.getColValue("descDepre"),false,false,true,80)%>
							<%=fb.button("btngasto","...",true,false,null,null,"onClick=\"javascript:addCuenta('gastoDepreAct');\"")%>
				</td>
				</tr>
				<tr class="TextHeader02">
								<td colspan="4">Datos del Activo</td>
				</tr>
				<tr class="<%=color%>">
				<td> Tipo de Activo : </td>
								<td><%=fb.select("tipo_activo","B=BIEN,I=INMUEBLE,T=TERRENO",cdo.getColValue("tipo_activo"))%></td>
								<td align="right">Tipo de Entrada : &nbsp;</td>
								<td><%=fb.textBox("entrada_codigo",cdo.getColValue("entrada_codigo"),true,false,true,7)%>
								<%=fb.textBox("entrada_desc",cdo.getColValue("entrada_desc"),false,false,true,25)%>
								<%=fb.button("btnentrada","...",false,false,null,null,"onClick=\"javascript:getListadoEntrada()\"")%></td>
							</tr>
					<tr class="<%=color%>">
				<td> Proveedor : </td>
								<td colspan="3"><%=fb.textBox("cod_provee",cdo.getColValue("cod_provee"),false,false,true,7)%>
								<%=fb.textBox("proveedor_desc",cdo.getColValue("proveedor_desc"),false,false,true,45)%>
								<%=fb.button("btnproveedor","...",false,false,null,null,"onClick=\"javascript:getListadoProveedor()\"")%></td>
							</tr>
							<tr class="<%=color%>">
				<td> Factura No. : </td>
								<td><%=fb.textBox("factura",cdo.getColValue("factura"),false,viewMode,false,15)%>
				<%=fb.button("btnFactura","...",false,false,null,null,"onClick=\"javascript:getFactura()\"")%></td>
							 <td align="right"> No. de O/C: &nbsp; </td>
				 <td> <%=fb.textBox("orden__compra",cdo.getColValue("orden__compra"),false,viewMode,false,15)%></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="95%">Generales del Activo</td>
				<td width="5%" align="right">&nbsp;[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
					</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							 <tr class="<%=color%>">
								 <td colspan="4">Nombre: &nbsp;<%=fb.textBox("observacion",cdo.getColValue("observacion"),true,false,false,100,200,"","","")%></td>
							 </tr>
				 <tr class="<%=color%>">
								 <td width="25%">No. P&oacute;liza : &nbsp;<%=fb.decBox("npoliza",cdo.getColValue("npoliza"),false, false, false, 10)%></td>
								 <td width="25%" align="center">Condic. F&iacute;sica : &nbsp; <%=fb.select("cond_fisica","NUE=NUEVO,REG=REGULAR,SEG=SEGUNDA",cdo.getColValue("cond_fisica"),false,false,0,null,null,null,null,"S")%></td>
				 <td width="20%" align="right">Estado Activo : &nbsp;</td>
								 <td width="30%">
								 <% String std ="";
								 
								 if(viewMode){std=",RETIR=INACTIVO";}%>
								 <%=fb.select("estatus","ACTI=ACTIVO"+std,cdo.getColValue("estatus"))%>&nbsp;&nbsp;&nbsp;&nbsp;Fecha Salida:<%=fb.decBox("fecha_salida",cdo.getColValue("fecha_salida"),false, false, true, 30, 10,null,null,"")%></td>
							 </tr>
							 <tr class="<%=color%>">
								 <td>Tipo de Deprec.: <%//=fb.select("tipo_de_depre","LINEAR=LINEA RECTA/*,SUMDIG=SUMA DE DIGITOS,VALORDEC=VALOR DECRECIENTE*/",cdo.getColValue("tipo_de_depre"))%>

				 <%=fb.select("tipo_de_depre","LINEAR=LINEA RECTA,SUMDIG=SUMA DE DIGITOS,VALORDEC=VALOR DECRECIENTE",cdo.getColValue("tipo_de_depre"),false,false,false,0,"","","onChange=\"javascript:getDepreciacion()\"")%></td>
								 <td align="center">Vida Estimada : &nbsp;<%=fb.decBox("vida_estimada",cdo.getColValue("vida_estimada"),false, false, false, 5, 5,null,null,"onChange=\"javascript:calcVida()\"")%></td>
								 <td align="right">Fin de Garantía: &nbsp;</td>
				 <td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="final_garantia" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("final_garantia")%>" />
									</jsp:include></td>
							 </tr>

							 <tr class="TextHeader02">
								 <td colspan="4">Valores del Activo</td>
							 </tr>
							 <tr class="<%=color%>">
								 <td>Valor Inicial del Activo:</td>
								 <td><%=fb.decBox("valor_inicial",cdo.getColValue("valor_inicial"),true,false,false,15,12.2,null,null,"onChange=\"javascript:getDepreciacion()\"")%> </td>
				 <td>Mejoras Acumulada : &nbsp;</td>
								 <td><%=fb.decBox("valor__mejor_acum",cdo.getColValue("valor__mejor_acum"),false, false, false,15,12.2,null,null,"","",false,"")%></td>
							 </tr>
				 <tr class="<%=color%>">
								 <td>Meses Depreciados: &nbsp;</td>
								 <td><%=fb.intBox("meses_depre_act",cdo.getColValue("meses_depre_act"),false, false,false,5,5,null,null,"onChange=\"javascript:getDepreAcum()\"")%></td>
								 <td>Deprec. Acum Mejoras: &nbsp;</td>
								 <td><%=fb.decBox("acum_deprem",cdo.getColValue("acum_deprem"),false, false, false,15,12.2,null,null,"","",false,"")%></td>
							 </tr>
				 <tr class="<%=color%>">
								 <td>Depreciación Mensual: </td>
								 <td><%=fb.decBox("valor_deprem",cdo.getColValue("valor_deprem"),false,false, true,15,12.2,null,null,"","",false,"")%></td>
								 <td>Deprec. Mensual de las Mejoras: &nbsp;</td>
								 <td><%=fb.decBox("valor_depre_mejora",cdo.getColValue("valor_depre_mejora"),false, false, false,15,12.2,null,null,"","",false,"")%></td>
							 </tr>
				 <tr class="<%=color%>">
								 <td>Depreciación Acumulada: </td>
								 <td><%=fb.decBox("acum_deprec",cdo.getColValue("acum_deprec"),false,false, true,15,12.2,null,null,"","",false,"")%></td>
								 <td>Valor Actual de las Mejoras: &nbsp;</td>
								 <td><%=fb.decBox("valor_mejora_actual",cdo.getColValue("valor_mejora_actual"),false,false,false,15,12.2,null,null,"onChange=\"javascript:getMejora()\"")%></td>
				 </tr>
							 <tr class="<%=color%>">
								 <td>Valor Actual del Activo: </td>
								 <td><%=fb.decBox("valor_actual",cdo.getColValue("valor_actual"),true,false, true,15,12.2,null,null,"","",false,"")%></td>
								 <td align="center">VALOR TOTAL: &nbsp;</td>
								 <td>&nbsp;</td>
				 </tr>
				 <tr class="<%=color%>">
								 <td>Valor Rescate: </td>
								 <td><%=fb.decBox("valor_rescate",cdo.getColValue("valor_rescate"),true,false, false,15,12.2,null,null,"","",false,"")%></td>
								 <td align="center"><%=fb.decBox("valor_total",cdo.getColValue("valor_total"),false, false,true,15,12.2,null,null,"","",false,"")%></td>
								 <td>&nbsp;</td>
				</tr>
			</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr class="TextRow02">
			<td align="right">
		Opciones de Guardar:
		<%=fb.radio("saveOption","N")%>Crear Otro
		<%=fb.radio("saveOption","O")%>Mantener Abierto
		<%=fb.radio("saveOption","C",true,false,false)%>Cerrar
		<%=fb.submit("save","Guardar",true,viewMode)%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
	<tr>
			<td>&nbsp;</td>
	</tr>
<%=fb.formEnd(true)%>
</table>
</div>

<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("caracSize",""+iCaract.size())%>
<%=fb.hidden("caracLastLineNo",""+caracLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Activo</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td>
								<%=cdo.getColValue("observacion")%> 
								<%=fb.textBox("cuentah_activo",cdo.getColValue("cuentah_activo"),false,false,true,7)%>
												<%=fb.textBox("cuentah_espec",cdo.getColValue("cuentah_espec"),false,false,true,7)%>
								<%=fb.textBox("cuentah_desc",cdo.getColValue("cuentah_desc"),false,false,true,55)%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Depreciacion</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="40%">Descripci&oacute;n</td>
							<td width="60%">Observaci&oacute;n</td>
						</tr>
						</table>
					</td>
				</tr>

	<tr>
		<td>

			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
				<td onClick="javascript:showHide(12)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr class="TextPanel">
								<td width="95%">Depreciaci&oacute;n del Activo</td>
								<td width="5%" align="right">&nbsp;[<font face="Courier New, Courier, mono"><label id="plus12" style="display:none">+</label><label id="minus12">-</label></font>]&nbsp;</td>
					</tr>
						</table>
					</td>
				</tr>
				<tr id="panel12">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="TextHeader02">
									<td width="10%" align="center">Año</td>
									<td width="10%" align="center">Mes</td>
									<td width="20%" align="center">Valor Anterior</td>
									<td width="20%" align="center">Depreciaci&oacute;n</td>
									<td width="20%" align="center">Valor Actual</td>
									<td width="20%" align="center">Depreciaci&oacute;n Acumulada</td>
							 </tr>
				<%for (int i=0; i<alD.size(); i++)
				{
					 CommonDataObject cdoD = (CommonDataObject) alD.get(i);
					 String colorD = "TextRow02";
					 if (i % 2 == 0) colorD = "TextRow01";	%>
							 <tr class="<%=colorD%>">
									<td width="10%" align="center"><%=cdoD.getColValue("anio")%></td>
									<td width="10%" align="left"><%=cdoD.getColValue("mes")%></td>
									<td width="20%" align="center"><%=cdoD.getColValue("vAnterior")%></td>
									<td width="20%" align="center"><%=cdoD.getColValue("montoDep")%></td>
									<td width="20%" align="center"><%=cdoD.getColValue("vActual")%></td>
									<td width="20%" align="center"><%=cdoD.getColValue("deprecAcum")%></td>
							 </tr>
							 <% }%>

						</table>
					</td>
				</tr>
		</table>
		</td>
				</tr>
		<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>

<!-- TAB1 DIV END HERE-->
</div>
<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

	<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("caracSize",""+al2.size())%>
<%=fb.hidden("caracLastLineNo",""+caracLastLineNo)%>
<%=fb.hidden("cod_clasif",cdo.getColValue("grupo_clasif"))%>


				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Activo</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td><%=cdo.getColValue("observacion")%>
								<%=fb.textBox("cuentah_activo",cdo.getColValue("cuentah_activo"),false,false,true,7)%>
												<%=fb.textBox("cuentah_espec",cdo.getColValue("cuentah_espec"),false,false,true,7)%>
								<%=fb.textBox("cuentah_desc",cdo.getColValue("cuentah_desc"),false,false,true,55)%></td>
						</tr>
						<tr class="TextRow01">
							<td>
								<%=fb.textBox("grupo_clasif",cdo.getColValue("grupo_clasif"),false,false,true,7)%>
								<%=fb.textBox("grupo_desc",cdo.getColValue("grupo_desc"),false,false,true,55)%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Caracteristicas A Clasificar</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="40%">Descripci&oacute;n</td>
							<td width="60%">Observaci&oacute;n</td>
						</tr>
<%
for (int i=1; i<=al2.size(); i++)
{
	key = al2.get(i - 1).toString();
	CommonDataObject cdo2 = (CommonDataObject) al2.get(i - 1);
%>
						<%=fb.hidden("cod_clasif"+i,cdo2.getColValue("cod_clasif"))%>
						<%=fb.hidden("sec_campos"+i,cdo2.getColValue("secuencia_campos"))%>
						<tr class="TextRow01">
							<td><%=cdo2.getColValue("descripcion")%></td>
							<td align="center"><%=fb.textBox("campo_char"+i,cdo2.getColValue("campo_char"),false,false,false,50)%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td colspan="2" align="right">
						Opciones de Guardar:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

	</table>

<!-- TAB2 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Generales','Depreciacion','Caracteristicas'";
String tabInactivo ="";

//S=Si el centro de servicio maneja admisiones
if(cdo != null && cdo.getColValue("grupo_clasif")!= null && !cdo.getColValue("grupo_clasif").trim().equals("") )
tabInactivo += "";
else tabInactivo += "2";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','','','','',[<%=tabInactivo%>]);
</script>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</td>
			</tr>
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
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	secuencia = request.getParameter("secuencia");
if (tab.equals("0")) //Generales
{
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_con_activos");
	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("secuencia",request.getParameter("secuencia"));
	cdo.addColValue("fecha_de_entrada",request.getParameter("fecha_entrada"));
	cdo.addColValue("estatus",request.getParameter("estatus"));
	cdo.addColValue("tipo_activo",request.getParameter("tipo_activo"));
	cdo.addColValue("tipo_de_depre",request.getParameter("tipo_de_depre"));
	cdo.addColValue("valor_deprem",request.getParameter("valor_deprem"));
	cdo.addColValue("valor_inicial",request.getParameter("valor_inicial"));
	cdo.addColValue("valor_rescate",request.getParameter("valor_rescate"));
	cdo.addColValue("valor_actual",request.getParameter("valor_actual"));
	cdo.addColValue("usua_crea",request.getParameter("usua_crea"));
	cdo.addColValue("fecha_crea",request.getParameter("fecha_crea"));
	cdo.addColValue("cargo_uso",request.getParameter("cargo_uso"));
	if (request.getParameter("ue_codigo") != null && !request.getParameter("ue_codigo").trim().equals("")) cdo.addColValue("ue_codigo",request.getParameter("ue_codigo"));
	if (request.getParameter("entrada_codigo") != null && !request.getParameter("entrada_codigo").trim().equals("")) cdo.addColValue("entrada_codigo",request.getParameter("entrada_codigo"));
	if (request.getParameter("cuentah_activo") != null && !request.getParameter("cuentah_activo").trim().equals("")) cdo.addColValue("cuentah_activo",request.getParameter("cuentah_activo"));
	if (request.getParameter("cuentah_espec") != null && !request.getParameter("cuentah_espec").trim().equals("")) cdo.addColValue("cuentah_espec",request.getParameter("cuentah_espec"));
	if (request.getParameter("cuentah_detalle") != null && !request.getParameter("cuentah_detalle").trim().equals("")) cdo.addColValue("cuentah_detalle",request.getParameter("cuentah_detalle"));
	if (request.getParameter("nivel_codigo_ubic") != null && !request.getParameter("nivel_codigo_ubic").trim().equals("")) cdo.addColValue("nivel_codigo_ubic",request.getParameter("nivel_codigo_ubic"));
	if (request.getParameter("orden__compra") != null && !request.getParameter("orden__compra").trim().equals("")) cdo.addColValue("orden__compra",request.getParameter("orden__compra"));
	if (request.getParameter("acum_deprec") != null && !request.getParameter("acum_deprec").trim().equals("")) cdo.addColValue("acum_deprec",request.getParameter("acum_deprec"));
	if (request.getParameter("factura") != null && !request.getParameter("factura").trim().equals("")) cdo.addColValue("factura",request.getParameter("factura"));
	if (request.getParameter("valor__mejor_acum") != null && !request.getParameter("valor__mejor_acum").trim().equals("")) cdo.addColValue("valor__mejor_acum",request.getParameter("valor__mejor_acum"));
	if (request.getParameter("valor_mejora_actual") != null && !request.getParameter("valor_mejora_actual").trim().equals("")) cdo.addColValue("valor_mejora_actual",request.getParameter("valor_mejora_actual"));
	if (request.getParameter("valor_depre_mejora") != null && !request.getParameter("valor_depre_mejora").trim().equals("")) cdo.addColValue("valor_depre_mejora",request.getParameter("valor_depre_mejora"));
	if (request.getParameter("acum_deprem") != null && !request.getParameter("acum_deprem").trim().equals("")) cdo.addColValue("acum_deprem",request.getParameter("acum_deprem"));
	if (request.getParameter("meses_depre_act") != null && !request.getParameter("meses_depre_act").trim().equals("")) cdo.addColValue("meses_depre_act",request.getParameter("meses_depre_act"));
	if (request.getParameter("cod_provee") != null && !request.getParameter("cod_provee").trim().equals("")) cdo.addColValue("cod_provee",request.getParameter("cod_provee"));
	if (request.getParameter("observacion") != null && !request.getParameter("observacion").trim().equals("")) cdo.addColValue("observacion",request.getParameter("observacion"));
	if (request.getParameter("vida_estimada") != null && !request.getParameter("vida_estimada").trim().equals("")) cdo.addColValue("vida_estimada",request.getParameter("vida_estimada"));
	if (request.getParameter("final_garantia") != null && !request.getParameter("final_garantia").trim().equals("")) cdo.addColValue("final_garantia",request.getParameter("final_garantia"));
	if (request.getParameter("cond_fisica") != null && !request.getParameter("cond_fisica").trim().equals("")) cdo.addColValue("cond_fisica",request.getParameter("cond_fisica"));
	//if (request.getParameter("cod_clasif") != null && !request.getParameter("cod_clasif").trim().equals("")) cdo.addColValue("cod_clasif",request.getParameter("cod_clasif"));
	if (request.getParameter("grupo_clasif") != null && !request.getParameter("grupo_clasif").trim().equals("")) cdo.addColValue("cod_clasif",request.getParameter("grupo_clasif"));
	if (request.getParameter("npoliza") != null && !request.getParameter("npoliza").trim().equals("")) cdo.addColValue("npoliza",request.getParameter("npoliza"));
	//if (!request.getParameter("precio_venta").trim().equals("")) cdo.addColValue("precio_venta",request.getParameter("precio_venta"));
	//if (!request.getParameter("tipo_servicio").trim().equals("")) cdo.addColValue("tipo_servicio",request.getParameter("tipo_servicio"));
 // if (!request.getParameter("tipo_precio").trim().equals("")) cdo.addColValue("tipo_precio",request.getParameter("tipo_precio"));
	if (request.getParameter("cod_articulo") != null && !request.getParameter("cod_articulo").trim().equals("")) cdo.addColValue("cod_articulo",request.getParameter("cod_articulo"));
	if (request.getParameter("cod_clase") != null && !request.getParameter("cod_clase").trim().equals("")) cdo.addColValue("cod_clase",request.getParameter("cod_clase"));
	if (request.getParameter("cod_flia") != null && !request.getParameter("cod_flia").trim().equals("")) cdo.addColValue("cod_flia",request.getParameter("cod_flia"));
	if (request.getParameter("porcentaje") != null && !request.getParameter("porcentaje").trim().equals("")) cdo.addColValue("porcentaje",request.getParameter("porcentaje"));
	if (request.getParameter("placa") != null && !request.getParameter("placa").trim().equals("")) cdo.addColValue("placa",request.getParameter("placa"));
	//if (!request.getParameter("bandera").trim().equals("")) cdo.addColValue("bandera",request.getParameter("bandera"));
	if (request.getParameter("placa_nueva") != null && !request.getParameter("placa_nueva").trim().equals("")) cdo.addColValue("placa_nueva",request.getParameter("placa_nueva"));
	if (request.getParameter("gasto1") != null && !request.getParameter("gasto1").trim().equals("")) cdo.addColValue("gasto1",request.getParameter("gasto1"));
	if (request.getParameter("gasto2") != null && !request.getParameter("gasto2").trim().equals("")) cdo.addColValue("gasto2",request.getParameter("gasto2"));
	if (request.getParameter("gasto3") != null && !request.getParameter("gasto3").trim().equals("")) cdo.addColValue("gasto3",request.getParameter("gasto3"));
	if (request.getParameter("gasto4") != null && !request.getParameter("gasto4").trim().equals("")) cdo.addColValue("gasto4",request.getParameter("gasto4"));
	if (request.getParameter("gasto5") != null && !request.getParameter("gasto5").trim().equals("")) cdo.addColValue("gasto5",request.getParameter("gasto5"));
	if (request.getParameter("gasto6") != null && !request.getParameter("gasto6").trim().equals("")) cdo.addColValue("gasto6",request.getParameter("gasto6"));

	cdo.addColValue("usua_mod",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_mod",cDateTime);

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		 //cdo.addColValue("usua_crea",request.getParameter("userCrea"));
		 //cdo.addColValue("fecha_crea",request.getParameter("fechaCrea"));
		 cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		 cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId"));
		 cdo.setAutoIncCol("secuencia");

		 cdo.addPkColValue("secuencia","");

		 SQLMgr.insert(cdo);
		 secuencia = SQLMgr.getPkColValue("secuencia");
	}
	else
	{
		 cdo.setWhereClause("secuencia='"+request.getParameter("secuencia")+"' and compania="+(String) session.getAttribute("_companyId"));

		 SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
	}
	else if (tab.equals("2")) //Generales
	{
		int size = 0;
		if (request.getParameter("caracSize") != null) size = Integer.parseInt(request.getParameter("caracSize"));
		String itemRemoved = "";
		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo2 = new CommonDataObject();


			if(request.getParameter("campo_char"+i) != null &&  !request.getParameter("campo_char"+i).trim().equals(""))
			{
				cdo2.setTableName("tbl_con_resp_por_campos");
				cdo2.setWhereClause("act_sec='"+secuencia+"' and cod_compania="+(String) session.getAttribute("_companyId")+" and cod_clasif ="+request.getParameter("cod_clasif"));
				cdo2.addColValue("cod_clasif",request.getParameter("cod_clasif"));
				cdo2.addColValue("sec_campos",request.getParameter("sec_campos"+i));
				cdo2.addColValue("cod_compania",(String) session.getAttribute("_companyId"));
				cdo2.addColValue("act_sec",secuencia);
				cdo2.addColValue("campo_char",request.getParameter("campo_char"+i));
				al.add(cdo2);
			}

		}
		if (al.size() == 0)
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setTableName("tbl_con_resp_por_campos");
			cdo2.setWhereClause("act_sec='"+secuencia+"' and cod_compania="+(String) session.getAttribute("_companyId")+" and cod_clasif ="+request.getParameter("grupo_clasif"));

			al.add(cdo2);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/activos/list_activos_fijos.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/activos/list_activos_fijos.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/activos/list_activos_fijos.jsp';
<%
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&secuencia=<%=secuencia%>&tab=<%=tab%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>