<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.CdcSolicitud"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CdcSolMgr" scope="page" class="issi.admision.CdcSolicitudMgr" />
<jsp:useBean id="recArt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="recArtKey" scope="session" class="java.util.Hashtable"/>
<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
SAL310004						INVENTARIO (CUARTO DE URGENCIA)\TRANSACCIONES\INVENTARIO (CU/EXPEDIENTE).		CUARTO DE URGENCIAS-ADULTO.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CdcSolMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String codAlmacen = request.getParameter("codAlmacen");
String fecha = request.getParameter("fecha");
String pac_id = request.getParameter("pac_id");
String codigo = request.getParameter("codigo");
String anio = request.getParameter("anio");
String adm_secuencia = request.getParameter("adm_secuencia");
String codigo_barra = request.getParameter("codigo_barra");
String msg = request.getParameter("msg");
if(msg==null)msg = "";
boolean viewMode = false;
int lineNo = 0, contY = 0;

if (mode == null) mode = "add";
if(mode.equals("view")) viewMode = true;
if(fp==null) fp="";
if(type==null) type="";
if(codAlmacen==null) codAlmacen="";
if(fecha==null) fecha="";

String appendFilter = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(change==null){
	recArt.clear();
	recArtKey.clear();
}	
	if(type.equals("SP") && change == null){
	
		
		sql = "select a.anio, a.solicitud_no codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.paciente cod_paciente, a.adm_secuencia, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, c.art_familia, c.art_clase, c.cod_articulo, d.descripcion art_desc, e.disponible, c.cantidad, nvl(c.despachado, 0) despachado, a.centro_servicio, a.pac_id, 'C' tipo,nvl(d.other3,'Y')afecta_inv from tbl_inv_solicitud_pac a, tbl_inv_d_sol_pac c, tbl_inv_articulo d, tbl_inv_inventario e where a.estado = 'P' and a.codigo_almacen = " + codAlmacen + " and to_date(to_char(a.fecha_documento, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fecha+"', 'dd/mm/yyyy') and a.anio = "+anio+" and a.solicitud_no = "+ codigo+" and a.anio = " + anio + " and a.compania = c.compania and a.anio = c.anio and a.solicitud_no = c.solicitud_no and c.compania = d.compania and c.art_familia = d.cod_flia and c.art_clase = d.cod_clase and c.cod_articulo = d.cod_articulo and c.compania = e.compania and e.codigo_almacen = " + codAlmacen +" and c.art_familia = e.art_familia and c.art_clase = e.art_clase and c.cod_articulo = e.cod_articulo";	
	} 
	else if(type.equals("CU")){
		sql = "select a.anio, a.secuencia codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.codigo_paciente cod_paciente, a.adm_secuencia, to_char(a.fecha, 'dd/mm/yyyy') fecha_documento, to_char(c.fecha_uso, 'dd/mm/yyyy') fecha_uso, c.cod_uso, d.descripcion uso_desc, c.cantidad_uso, nvl(c.devolver, 0) devolver, to_char(nvl(c.precio,0),'99999999990.00')precio, to_char((c.cantidad_uso*c.precio),'99999999990.00') tot_monto, a.centro_servicio, a.pac_id, a.tipo, c.secuencia_uso, 'N' afecta_inv from tbl_sal_cargos_usos a, tbl_sal_cargos_det_usos c, tbl_sal_uso d where a.estado = 'P' and a.codigo_almacen = " + codAlmacen + " and a.tipo in ('C', 'D') and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fecha +"', 'dd/mm/yyyy') and a.compania = c.compania and a.anio = c.anio and a.secuencia = c.secuencia_uso and c.compania = d.compania and c.cod_uso = d.codigo and a.secuencia = " + codigo+ " and a.anio = " + anio;
	} /*else if(type.equals("DP")){
		sql = "select a.anio, a.num_devolucion codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.paciente cod_paciente, a.adm_secuencia, to_char(a.fecha, 'dd/mm/yyyy') fecha_documento, c.cod_familia art_familia, c.cod_clase art_clase, c.cod_articulo, d.descripcion art_desc, to_char(nvl(c.precio,0),'99999999990.00')precio, c.cantidad, to_char((c.cantidad*c.precio),'99999999990.00') tot_monto, a.sala_cod centro_servicio, a.pac_id, 'D' tipo,nvl(d.other3,'Y')afecta_inv from tbl_inv_devolucion_pac a, tbl_inv_detalle_paciente c, tbl_inv_articulo d where a.estado = 'T' and codigo_almacen in ("+codAlmacen+") and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fecha+"', 'dd/mm/yyyy') and a.compania = c.compania and a.anio = c.anio_devolucion and a.num_devolucion = c.num_devolucion and c.compania = d.compania and c.cod_familia = d.cod_flia and c.cod_clase = d.cod_clase and c.cod_articulo = d.cod_articulo and nvl(c.cantidad,0) >0 and a.num_devolucion = " + codigo + " and a.anio = " + anio;
	}*/
		
		//change = "1";
		System.out.println("sql detail:\n"+sql);
		al = SQLMgr.getDataList(sql);
		key = "";
		int line = 0;
		for(int i=0;i<al.size();i++){
				CommonDataObject oc = (CommonDataObject) al.get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					recArt.put(key, oc);
					recArtKey.put(oc.getColValue("cod_articulo"), key);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		
		sql = "select b.primer_nombre||' '||b.segundo_nombre||' '||decode(b.apellido_de_casada, null, primer_apellido||' '||b.segundo_apellido, b.apellido_de_casada) nombre_paciente, decode(b.pasaporte, null, b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento||'-'||b.d_cedula, b.pasaporte) identificacion,(select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name = 'CHECK_DISP') as valida_dsp from tbl_adm_paciente b where b.pac_id = " + pac_id;
		CommonDataObject cdoPac = SQLMgr.getData(sql);
		if(cdoPac ==null){cdoPac =new CommonDataObject();cdoPac.addColValue("valida_dsp","S");}
		if((/*type.equals("SP") ||*/ type.equals("DP")) && change == null) {
			al.clear();
			recArt.clear();
			recArtKey.clear();
		}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	<%if(fp!=null && fp.equals("CB") && (type.equals("SP") || type.equals("CU")) && change!=null){%>
	for (i=0; i<<%=recArt.size()%>; i++){
	chkValue(i);
	}
	totales();
	<%}%>
	<%if(fp!=null && fp.equals("CB")){%><%if(!msg.equals("")){%>alert('<%=msg%>');<%}%>document.form0.codigo_barra.focus();<%}%>
}

function chkAll(){
	var size = document.form0.size.value;
	if(document.form0.chkTodos.checked==true){
		for(i=0;i<size;i++){
		<%if(type.equals("SP")){%>
			eval('document.form0.despachado'+i).value = eval('document.form0.cantidad'+i).value;
			chkValue(i);
		<%} else if(type.equals("CU")){%>
		eval('document.form0.chkUsos'+i).checked = true;
		<%}%>
		}
		<%if(type.equals("SP")){%>
		totales();
		<%}%>
	} else {
		for(i=0;i<size;i++){
			<%if(type.equals("SP")){%>
			eval('document.form0.despachado'+i).value = '';
			<%} else if(type.equals("CU")){%>
			eval('document.form0.chkUsos'+i).checked = false;
			<%}%>
		}
	}
}
function chkValue(i){
	var cantidad = eval('document.form0.cantidad'+i).value;
	var despachado = eval('document.form0.despachado'+i).value;
	var art_familia = eval('document.form0.art_familia'+i).value;
	var art_clase = eval('document.form0.art_clase'+i).value;
	var cod_articulo = eval('document.form0.cod_articulo'+i).value;
	var afecta_inv = eval('document.form0.afecta_inv'+i).value;
	var x = 0;
	cantidad = parseInt(cantidad);
	despachado = parseInt(despachado);
	if(isNaN(cantidad)){
		alert('Introduzca valores Numéricos!');
		eval('document.form0.cantidad'+i).value = '';
		x++;
	}

	if(isNaN(despachado)){
		alert('Introduzca valores Numéricos!');
		eval('document.form0.despachado'+i).value = '';
		x++;
	}
	if(despachado >= 0 && despachado <= cantidad){
		<%if(cdoPac.getColValue("valida_dsp").trim().equals("S")){%>
		if(afecta_inv=='Y'){
		var disponible = getInvDisponible('<%=request.getContextPath()%>', <%=(String) session.getAttribute("_companyId")%>, <%=codAlmacen%>, art_familia, art_clase, cod_articulo);
		if(isNaN(disponible)) disponible = 0;
		if(disponible==0){
			alert('No hay Existencia!');
			x++;
		} else if(despachado>disponible){
			alert('Cantidad NO disponible en Inventario!');
			eval('document.form0.despachado'+i).value = '';
			x++;
		}}
	  <%}%>/*end valida_dsp*/
	} else {
		alert('Cantidad no permitida!');
		eval('document.form0.despachado'+i).value = '0';
		x++;
	}
	if(x==0) return true;
	else return false;
}

function totales(){
	var size = document.form0.size.value;
	var total = 0;
	for(i=0;i<size;i++){
		if(eval('document.form0.despachado'+i).value!='') total += parseInt(eval('document.form0.despachado'+i).value, 10);
	}
	document.form0.despachado.value = total;
}
function entregar(baction){
	if (!form0Validation())
	{
		
		form0BlockButtons(false);
		return false;
	}else form0BlockButtons(true);
	document.form0.baction.value = baction;
	var p_pac_id   				= document.form0.pac_id.value;
	var p_admision    		= document.form0.adm_secuencia.value;
	var estado=getDBData('<%=request.getContextPath()%>','estado','tbl_adm_admision','pac_id = ' + p_pac_id + ' and secuencia = ' + p_admision + ' and estado = \'I\'','');
	if(estado!=''){
		alert('La admision está Inactiva!');
		form0BlockButtons(false);
	}	else{ 
	var size = document.form0.size.value;
	var x = 0
	for(i=0;i<size;i++){
		if(eval('document.form0.despachado'+i).value!='' && eval('document.form0.despachado'+i).value!='0'){x++;break}
	}
	if(x!=0)document.form0.submit();
	else{ alert('No Hay valores seleccionados');form0BlockButtons(false); }}
}

function crear_trx(baction){
	form0BlockButtons(true);
	var p_pac_id   					= document.form0.pac_id.value;
	var p_admision    		= document.form0.adm_secuencia.value;
	document.form0.baction.value = baction;
	var estado=getDBData('<%=request.getContextPath()%>','estado','tbl_adm_admision','pac_id = ' + p_pac_id + ' and secuencia = ' + p_admision + ' and estado = \'I\'','');
	if(estado!=''){
		alert('La admision está Inactiva!');
		form0BlockButtons(false);
	} else {
		document.form0.submit();
	}
}

function recibir(){
	form0BlockButtons(true);
	var p_fec_nacimiento	= document.form0.fecha_nacimiento.value;
	var p_paciente				= document.form0.cod_paciente.value;
	var p_pac_id   					= document.form0.pac_id.value;
	var p_admision    		= document.form0.adm_secuencia.value;
	var p_anio   					= document.form0.anio.value;
	var p_no_doc   				= document.form0.codigo.value;
	var p_fecha_doc   		= document.form0.fecha_documento.value;
	var p_centro_servicio	= document.form0.centro_servicio.value;
	var p_cod_almacen			= '<%=codAlmacen%>';
	var p_tipo_trx				= document.form0.tipo.value;
	var p_bloque					= document.form0.bloque.value;
	var p_form_name				= 'SAL310004';

	var estado=getDBData('<%=request.getContextPath()%>','estado','tbl_adm_admision','pac_id = ' + p_pac_id + ' and secuencia = ' + p_admision + ' and estado = \'I\'','');
	if(estado!=''){
		alert('La admision está Inactiva!');
	} else {
		if(/*p_tipo == 'D' &&*/ confirm('¿Está seguro que desea generar la Devolución?')){
			if(executeDB('<%=request.getContextPath()%>','call sp_sal_crear_trx(<%=(String) session.getAttribute("_companyId")%>,\''+p_fec_nacimiento+'\','+p_paciente+','+p_pac_id+','+p_admision+','+p_anio+','+p_no_doc+',\''+p_fecha_doc+'\','+p_centro_servicio+','+p_cod_almacen+',\''+p_tipo_trx+'\',\''+p_bloque+'\',\'<%=(String) session.getAttribute("_userName")%>\',\''+p_form_name+'\',\'\')','tbl_fac_transaccion, tbl_fac_detalle_transaccion')){
				alert('Guardado Satisfactoriamente!');
				window.location = '../inventario/detalle_insumos_usos.jsp?type=<%=type%>&fecha=<%=fecha%>&codAlmacen=<%=codAlmacen%>&pac_id=<%=pac_id%>&codigo=<%=codigo%>&anio=<%=anio%>&adm_secuencia=<%=adm_secuencia%>';
			} else alert('No se Guardó la informacion!');
		}
	}
	form0BlockButtons(false);
}

function printDetCargos<%=type%>(){
	var p_pac_id   					= document.form0.pac_id.value;
	var p_admision    		= document.form0.adm_secuencia.value;
	abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+p_admision+'&pacId='+p_pac_id);
}
$(document).on("keypress", ":input:not(textarea), #codigo_barra", function(event) {
    //console.log(this.value);
	if(this.name=='codigo_barra' && event.keyCode==13) {setVal(this.value); return true;}
		else return event.keyCode != 13;
});

function setVal(valor){
	var completeText = valor; 
      var newValue;
			var bar_code;
			var fecha;// = getGS1BarcodeData(bar_code, '17');
			var no_serie;// = getGS1BarcodeData(bar_code, '10');
			if (completeText){
				document.form0.cod_barra_gs1.value = completeText;
        bar_code = getGS1BarcodeData('<%=request.getContextPath()%>',completeText, '01')
        fecha = getGS1BarcodeData('<%=request.getContextPath()%>',completeText, '17')
        no_serie = getGS1BarcodeData('<%=request.getContextPath()%>',completeText, '10')
        
				if(fecha!=''){
				var anio = fecha.substr(0, 2);
				var mes = fecha.substr(2, 2);
				var dia = fecha.substr(4, 2);
				fecha=dia+'/'+mes+'/'+20+''+anio;
				}
				document.form0.codigo_barra.value = bar_code;
				document.form0.fecha_vence.value = fecha;
				document.form0.no_serie.value = no_serie;
				setBAction('form0', 'addArtCB');
				$('<input>',{type:'submit',style:'display:none',name:'addArtCB',value:'addArtCB'}).appendTo(document.form0).click().remove();
				//alert(document.form0.baction.value);
				//document.form0.submit();
      }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("size",""+recArt.size())%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("codAlmacen",codAlmacen)%> 
<%=fb.hidden("fecha",fecha)%> 
<%=fb.hidden("type",type)%> 
<%=fb.hidden("pac_id", pac_id)%>
<%=fb.hidden("adm_secuencia", adm_secuencia)%>
<%=fb.hidden("codigo", codigo)%>
<%=fb.hidden("anio", anio)%>

<%=fb.hidden("fecha_vence","")%>
<%=fb.hidden("cod_barra_gs1","")%>
<%=fb.hidden("no_serie","")%>
<%=fb.hidden("fp","CB")%>
<%
int colspan = 7;
%> 
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="1">
        <tr class="TextHeader01">
          <td colspan="3"><%=cdoPac.getColValue("nombre_paciente")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ID#:&nbsp;<%=cdoPac.getColValue("identificacion")%></td>
          <td colspan="2">C&oacute;digo Barra:	<%=fb.textBox("codigo_barra","",false,false,false,30,100,"Text10 allow-enter",null,"","Código de barra",false,"tabindex=-1")%></td>
          <td colspan="<%=(type.equals("CU")?"3":"2")%>">
					<%if(type.equals("SP") || type.equals("CU")){%>
					<%=fb.checkbox("chkTodos", "N", false, false, "Text10", "", "onClick=\"javascript:chkAll()\"")%><%=(type.equals("SP")?"Entregar Todo":"Cargar/Devolver Todo")%>
          <%}%>
          </td>
        </tr>
    	<%
			if(type.equals("SP")){
			%>
        <tr class="TextHeader02">
          <td width="%" align="center">Familia</td>
          <td width="%" align="center">Clase</td>
          <td width="%" align="center">Art&iacute;culo</td>
          <td width="%" align="center">Descripci&oacute;n del Art&iacute;culo</td>
          <td width="%" align="center">Disponible</td>
          <td width="%" align="center">Cantidad</td>
          <td width="%" align="center">Entregado</td>
        </tr>
      <%
			} else if(type.equals("CU")){
			%>
        <tr class="TextHeader02">
          <td width="%" align="center">Fecha</td>
          <td width="%" align="center">Cod. Uso</td>
          <td width="%" align="center">Descripci&oacute;n</td>
          <td width="%" align="center">Cantidad</td>
          <td width="%" align="center">Cant. a Devol.</td>
          <td width="%" align="center">Precio</td>
          <td width="%" align="center">Monto Total</td>
          <td width="%" align="center">&nbsp;</td>
        </tr>
      <%
			} else if(type.equals("DP")){
			%>
        <tr class="TextHeader02">
          <td width="%" align="center">Familia</td>
          <td width="%" align="center">Clase</td>
          <td width="%" align="center">Art&iacute;culo</td>
          <td width="%" align="center">Descripci&oacute;n del Art&iacute;culo</td>
          <td width="%" align="center">Precio</td>
          <td width="%" align="center">Cantidad</td>
          <td width="%" align="center">Monto Total</td>
        </tr>
      <%
			}
			%>
      
        <%
double cantidad = 0.00;
double tot_monto = 0.00;
key = "";
if (recArt.size() != 0) al = CmnMgr.reverseRecords(recArt);
for (int i=0; i<recArt.size(); i++) {
	key = al.get(i).toString();
	CommonDataObject ad = (CommonDataObject) recArt.get(key);

	String color = "";
	
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	boolean readonly = true;
	if(i==0){
%>
<%=fb.hidden("anio", ad.getColValue("anio"))%>
<%=fb.hidden("codigo", ad.getColValue("codigo"))%>
<%=fb.hidden("fecha_nacimiento", ad.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("cod_paciente", ad.getColValue("cod_paciente"))%>
<%=fb.hidden("fecha_documento", ad.getColValue("fecha_documento"))%>
<%=fb.hidden("centro_servicio", ad.getColValue("centro_servicio"))%>
<%=fb.hidden("tipo", ad.getColValue("tipo"))%>
<%=fb.hidden("bloque", "D"+type)%>
	<%}%>
<%=fb.hidden("anio"+i, ad.getColValue("anio"))%>
<%=fb.hidden("codigo"+i, ad.getColValue("codigo"))%>
<%=fb.hidden("fecha_nacimiento"+i, ad.getColValue("fecha_nacimiento"))%>
<%=fb.hidden("cod_paciente"+i, ad.getColValue("cod_paciente"))%>
<%=fb.hidden("adm_secuencia"+i, ad.getColValue("adm_secuencia"))%>
<%=fb.hidden("fecha_documento"+i, ad.getColValue("fecha_documento"))%>
<%=fb.hidden("centro_servicio"+i, ad.getColValue("centro_servicio"))%>
<%=fb.hidden("tipo"+i, ad.getColValue("tipo"))%>
<%=fb.hidden("art_familia"+i, ad.getColValue("art_familia"))%>
<%=fb.hidden("art_clase"+i, ad.getColValue("art_clase"))%>
<%=fb.hidden("cod_articulo"+i, ad.getColValue("cod_articulo"))%>
<%=fb.hidden("art_desc"+i, ad.getColValue("art_desc"))%>
<%=fb.hidden("fecha_uso"+i, ad.getColValue("fecha_uso"))%>
<%=fb.hidden("cod_uso"+i, ad.getColValue("cod_uso"))%>
<%=fb.hidden("uso_desc"+i, ad.getColValue("uso_desc"))%>
<%=fb.hidden("secuencia_uso"+i, ad.getColValue("secuencia_uso"))%>
<%=fb.hidden("afecta_inv"+i, ad.getColValue("afecta_inv"))%>
<%=fb.hidden("no_serie"+i,ad.getColValue("no_serie"))%>
<%=fb.hidden("fecha_vence"+i,ad.getColValue("fecha_vence"))%>
<%=fb.hidden("cod_barra_gs1"+i,ad.getColValue("cod_barra_gs1"))%>
<%
%>
				<%
				if(type.equals("SP")){
				%>
        <tr class="<%=color%>" align="center">
          <td><%=ad.getColValue("art_familia")%></td>
          <td><%=ad.getColValue("art_clase")%></td>
          <td><%=ad.getColValue("cod_articulo")%></td>
          <td align="left"><%=ad.getColValue("art_desc")%></td>
          <td><%=fb.intBox("disponible"+i, ad.getColValue("disponible"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("cantidad"+i, ad.getColValue("cantidad"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("despachado"+i, ad.getColValue("despachado"), false, false, false, 8, "Text10", null, "onChange=\"javascript:if(chkValue("+i+")){ totales();}\"")%></td>
        </tr>
				<%
				if(ad.getColValue("despachado")!=null && !ad.getColValue("despachado").equals("")) cantidad += Double.parseDouble(ad.getColValue("despachado"));
				} else if(type.equals("CU")){
				%>
        <tr class="<%=color%>" align="center">
          <td><%=ad.getColValue("fecha_uso")%></td>
          <td><%=ad.getColValue("cod_uso")%></td>
          <td align="left"><%=ad.getColValue("uso_desc")%></td>
          <td><%=fb.intBox("cantidad_uso"+i, ad.getColValue("cantidad_uso"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("devolver"+i, ad.getColValue("devolver"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.decBox("precio"+i, ad.getColValue("precio"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.decBox("tot_monto"+i, ad.getColValue("tot_monto"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.checkbox("chkUsos"+i,""+i,false, false, "", "", "")%></td>
        </tr>
				<%
				if(ad.getColValue("tot_monto")!=null && !ad.getColValue("tot_monto").equals("")) tot_monto += Double.parseDouble(ad.getColValue("tot_monto"));
				} else if(type.equals("DP")){
				%>
        <tr class="<%=color%>" align="center">
          <td><%=ad.getColValue("art_familia")%></td>
          <td><%=ad.getColValue("art_clase")%></td>
          <td><%=ad.getColValue("cod_articulo")%></td>
          <td align="left"><%=ad.getColValue("art_desc")%></td>
          <td><%=fb.decBox("precio"+i, ad.getColValue("precio"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.intBox("cantidad"+i, ad.getColValue("cantidad"), false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.decBox("tot_monto"+i, ad.getColValue("tot_monto"), false, false, true, 8, "Text10", null, "")%></td>
        </tr>
        <%
				if(ad.getColValue("cantidad")!=null && !ad.getColValue("cantidad").equals("")) cantidad += Double.parseDouble(ad.getColValue("cantidad"));
				if(ad.getColValue("tot_monto")!=null && !ad.getColValue("tot_monto").equals("")) tot_monto += Double.parseDouble(ad.getColValue("tot_monto"));
				}
}
%>
				<%
				if(type.equals("SP")){
				%>
        <tr class="textHeader01" align="center">
          <td colspan="6">&nbsp;</td>
          <td><%=fb.decBox("despachado", ""+cantidad, false, false, true, 8, "Text10", null, "")%></td>
        </tr>
				<%
				} else if(type.equals("CU")){
				%>
        <tr class="textHeader01" align="center">
          <td colspan="6">&nbsp;</td>
          <td><%=fb.decBox("tot_monto", ""+tot_monto, false, false, true, 8, "Text10", null, "")%></td>
          <td>&nbsp;</td>
        </tr>
				<%
				} else if(type.equals("DP")){
				%>
        <tr class="textHeader01" align="center">
          <td colspan="5">&nbsp;</td>
          <td><%=fb.intBox("cantidad", ""+cantidad, false, false, true, 8, "Text10", null, "")%></td>
          <td><%=fb.decBox("tot_monto", ""+tot_monto, false, false, true, 8, "Text10", null, "")%></td>
        </tr>
        <%
				}
				%>
        <%=fb.hidden("keySize",""+recArt.size())%>
        <tr>
          <td colspan="11" align="right">
          <%if(al.size()==0) viewMode = true;%>
          <%if(type.equals("SP")){%>
					<%=fb.button("entrega_insumos","Entrega de Insumos",true,viewMode,null,null,"onClick=\"javascript:entregar(this.value)\"")%>
					<%} else if(type.equals("CU")){%>
					<%=fb.button("cargar_devolver","Cargar o Devolver",true,viewMode,null,null,"onClick=\"javascript:crear_trx(this.value)\"")%>
          <%=fb.button("detalle_cargos","Detalle de Cargos",true,false,null,null,"onClick=\"javascript:printDetCargos"+type+"()\"")%>
					<%} else if(type.equals("DP")){%>
					<%=fb.button("recibir_insumos","Recibir Insumos",true,viewMode,null,null,"onClick=\"javascript:recibir()\"")%>
          <%=fb.button("informe_cargos","Informe de Cargos y Dev.",true,false,null,null,"onClick=\"javascript:printDetCargos"+type+"()\"")%>
					<%}%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
        <tr class="TextRow02">
          <td colspan="11" align="right"> </td>
        </tr>
      </table>
</table>
</td>
</tr>
</table>
</td>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
else
{
	String dl = "", refer_no = "";
	//Ajuste CdcSol = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	String artDel = "";

	int size = Integer.parseInt(request.getParameter("size"));

	lineNo = 0;
	ArrayList detail = new ArrayList();
	String _key = "", okey = "";
	CdcSolicitud cdcDet = new CdcSolicitud();
	cdcDet.setCompania((String) session.getAttribute("_companyId"));	
	cdcDet.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
	cdcDet.setCodigoPaciente(request.getParameter("cod_paciente"));
	cdcDet.setAdmision(request.getParameter("adm_secuencia"));
	cdcDet.setAnio(request.getParameter("anio"));
	cdcDet.setNoDocumento(request.getParameter("codigo"));
	cdcDet.setFechaDocumento(request.getParameter("fecha_documento"));
	cdcDet.setCentroServicio(request.getParameter("centro_servicio"));
	cdcDet.setCodigoAlmacen(request.getParameter("codAlmacen"));
	cdcDet.setTipoTransaccion(request.getParameter("tipo"));
	if(type.equals("SP")) cdcDet.setFlag("DSP");
	else if(type.equals("CU")) cdcDet.setFlag("DCU");
	cdcDet.setUsuarioCreacion((String) session.getAttribute("_userName"));
	cdcDet.setFormName("SAL310004");
	cdcDet.setPacId(request.getParameter("pac_id"));
	cdcDet.setFg("N");//Para identificar los usos desde expediente de los de salon(Citas) 

	for (int i=0; i<keySize; i++){
		CdcSolicitudDet det = new CdcSolicitudDet();
		CommonDataObject _cd = new CommonDataObject();
		det.setCitaCodigo(request.getParameter("cita_codigo"+i));
		det.setCitaFechaReg(request.getParameter("cita_fecha_reg"+i));
		det.setSecuencia(request.getParameter("secuencia"+i));
		det.setCompania((String) session.getAttribute("_companyId"));
		det.setAfectaInv(request.getParameter("afecta_inv"+i));
		
		if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) det.setArtFamilia(request.getParameter("art_familia"+i));

		if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals("")) det.setArtClase(request.getParameter("art_clase"+i));

		if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals("")) det.setCodArticulo(request.getParameter("cod_articulo"+i));

		if(request.getParameter("despachado"+i)!=null && !request.getParameter("despachado"+i).equals("null") && !request.getParameter("despachado"+i).trim().equals("")) det.setDespachado(request.getParameter("despachado"+i));
		else det.setDespachado("0");
		if(request.getParameter("cod_uso"+i)!=null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).equals("")) det.setCodUso(request.getParameter("cod_uso"+i));
		if(request.getParameter("fecha_uso"+i)!=null && !request.getParameter("fecha_uso"+i).equals("null") && !request.getParameter("fecha_uso"+i).equals("")) det.setFechaUso(request.getParameter("fecha_uso"+i));
		
		if(request.getParameter("no_serie"+i)!=null && !request.getParameter("no_serie"+i).equals("")) det.setNoSerie(request.getParameter("no_serie"+i));
		if(request.getParameter("fecha_vence"+i)!=null && !request.getParameter("fecha_vence"+i).equals("")) det.setFechaVence(request.getParameter("fecha_vence"+i));
		if(request.getParameter("cod_barra_gs1"+i)!=null && !request.getParameter("cod_barra_gs1"+i).equals("")) det.setCodBarGs1(request.getParameter("cod_barra_gs1"+i));

		if(type.equals("SP") && !det.getDespachado().trim().equals("0")&& !det.getDespachado().trim().equals("")) cdcDet.getCdcSolicitudDetail().add(det);
		else if(type.equals("CU")){
			if(request.getParameter("chkUsos"+i)!=null){
				det.setSecuenciaUso(request.getParameter("secuencia_uso"+i));
				cdcDet.getCdcSolicitudDetail().add(det);
			}
		}
		_cd.addColValue("cita_codigo",request.getParameter("cita_codigo"+i));
		_cd.addColValue("cita_fecha_reg",request.getParameter("cita_fecha_reg"+i));
		_cd.addColValue("secuencia",request.getParameter("secuencia"+i));
		_cd.addColValue("afecta_inv",request.getParameter("afecta_inv"+i));
		_cd.addColValue("art_desc",request.getParameter("art_desc"+i));
		_cd.addColValue("disponible",request.getParameter("disponible"+i));
		_cd.addColValue("cantidad",request.getParameter("cantidad"+i));
		
		_cd.addColValue("anio",request.getParameter("anio"+i));
		_cd.addColValue("codigo",request.getParameter("codigo"+i));
		_cd.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"+i));
		_cd.addColValue("cod_paciente",request.getParameter("cod_paciente"+i));
		_cd.addColValue("fecha_documento",request.getParameter("fecha_documento"+i));
		_cd.addColValue("centro_servicio",request.getParameter("centro_servicio"+i));
		_cd.addColValue("tipo",request.getParameter("tipo"+i));
		
		if(request.getParameter("art_familia"+i)!=null && !request.getParameter("art_familia"+i).equals("null") && !request.getParameter("art_familia"+i).equals("")) _cd.addColValue("art_familia",request.getParameter("art_familia"+i));
		if(request.getParameter("art_clase"+i)!=null && !request.getParameter("art_clase"+i).equals("null") && !request.getParameter("art_clase"+i).equals(""))_cd.addColValue("art_clase",request.getParameter("art_clase"+i));
		if(request.getParameter("cod_articulo"+i)!=null && !request.getParameter("cod_articulo"+i).equals("null") && !request.getParameter("cod_articulo"+i).equals(""))_cd.addColValue("cod_articulo",request.getParameter("cod_articulo"+i));
		if(request.getParameter("despachado"+i)!=null && !request.getParameter("despachado"+i).equals("null") && !request.getParameter("despachado"+i).equals(""))_cd.addColValue("despachado",request.getParameter("despachado"+i));
		else _cd.addColValue("despachado", "0");
		if(request.getParameter("cod_uso"+i)!=null && !request.getParameter("cod_uso"+i).equals("null") && !request.getParameter("cod_uso"+i).equals(""))_cd.addColValue("cod_uso",request.getParameter("cod_uso"+i));
		if(request.getParameter("fecha_uso"+i)!=null && !request.getParameter("fecha_uso"+i).equals("null") && !request.getParameter("fecha_uso"+i).equals(""))_cd.addColValue("fecha_uso",request.getParameter("fecha_uso"+i));

		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		if(request.getParameter("del"+i)==null){
			try {
				recArt.put(key, _cd);
				recArtKey.put(_cd.getColValue("cod_articulo"), key);
				//RecDet.getRecepDetails().add(det);
				System.out.println("adding...= "+key);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		} else {
			artDel = _cd.getColValue("cod_articulo");
		}
	}
	
	/*===============================================================================================================================*/
	/*       C       O       D       I       G       O               D       E               B       A       R       R       A       */
	/*===============================================================================================================================*/
	StringBuffer sbSql = new StringBuffer();
	System.out.println("fp  .............................................................................="+fp);
	System.out.println("codigo_barra  .............................................................................="+codigo_barra);
	System.out.println("baction  .............................................................................="+request.getParameter("baction"));
	if(fp!=null && fp.equals("CB") && !request.getParameter("baction").equalsIgnoreCase("ENTREGA DE INSUMOS") && !request.getParameter("baction").equalsIgnoreCase("CARGAR O DEVOLVER")){
		sbSql = new StringBuffer();
		
		if(type.equals("SP")){
		sbSql.append("select a.anio, a.solicitud_no codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.paciente cod_paciente, a.adm_secuencia, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, c.art_familia, c.art_clase, c.cod_articulo, d.descripcion art_desc, e.disponible, c.cantidad, c.despachado, a.centro_servicio, a.pac_id, 'C' tipo,nvl(d.other3,'Y')afecta_inv from tbl_inv_solicitud_pac a, tbl_inv_d_sol_pac c, tbl_inv_articulo d, tbl_inv_inventario e where a.estado = 'P' and a.codigo_almacen = ");
		sbSql.append(codAlmacen);
		sbSql.append(" and to_date(to_char(a.fecha_documento, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('");
		sbSql.append(fecha);
		sbSql.append("', 'dd/mm/yyyy') and a.anio = ");
		sbSql.append(anio);
		sbSql.append(" and a.solicitud_no = ");
		sbSql.append(codigo);
		sbSql.append(" and a.anio = ");
		sbSql.append(anio);
		sbSql.append(" and a.compania = c.compania and a.anio = c.anio and a.solicitud_no = c.solicitud_no and c.compania = d.compania and c.art_familia = d.cod_flia and c.art_clase = d.cod_clase and c.cod_articulo = d.cod_articulo and c.compania = e.compania and e.codigo_almacen = ");
		sbSql.append(codAlmacen);
		sbSql.append(" and c.art_familia = e.art_familia and c.art_clase = e.art_clase and c.cod_articulo = e.cod_articulo");	
	} else if(type.equals("CU")){
		sbSql.append("select a.anio, a.secuencia codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.codigo_paciente cod_paciente, a.adm_secuencia, to_char(a.fecha, 'dd/mm/yyyy') fecha_documento, to_char(c.fecha_uso, 'dd/mm/yyyy') fecha_uso, c.cod_uso, d.descripcion uso_desc, c.cantidad_uso, nvl(c.devolver, 0) devolver, to_char(nvl(c.precio,0),'99999999990.00')precio, to_char((c.cantidad_uso*c.precio),'99999999990.00') tot_monto, a.centro_servicio, a.pac_id, a.tipo, c.secuencia_uso, 'N' afecta_inv from tbl_sal_cargos_usos a, tbl_sal_cargos_det_usos c, tbl_sal_uso d where a.estado = 'P' and a.codigo_almacen = ");
		sbSql.append(codAlmacen);
		sbSql.append(" and a.tipo in ('C', 'D') and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('");
		sbSql.append(fecha);
		sbSql.append("', 'dd/mm/yyyy') and a.compania = c.compania and a.anio = c.anio and a.secuencia = c.secuencia_uso and c.compania = d.compania and c.cod_uso = d.codigo and a.secuencia = ");
		sbSql.append(codigo);
		sbSql.append(" and a.anio = ");
		sbSql.append(anio);
	} else if(type.equals("DP")){
		sbSql.append("select a.anio, a.num_devolucion codigo, to_char(a.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.paciente cod_paciente, a.adm_secuencia, to_char(a.fecha, 'dd/mm/yyyy') fecha_documento, c.cod_familia art_familia, c.cod_clase art_clase, c.cod_articulo, d.descripcion art_desc, to_char(nvl(c.precio,0),'99999999990.00')precio, c.cantidad, to_char((c.cantidad*c.precio),'99999999990.00') tot_monto, a.sala_cod centro_servicio, a.pac_id, 'D' tipo,nvl(d.other3,'Y')afecta_inv from tbl_inv_devolucion_pac a, tbl_inv_detalle_paciente c, tbl_inv_articulo d where a.estado = 'T' and codigo_almacen in (");
		sbSql.append(codAlmacen);
		sbSql.append(") and to_date(to_char(a.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('");
		sbSql.append(fecha);
		sbSql.append("', 'dd/mm/yyyy') and a.compania = c.compania and a.anio = c.anio_devolucion and a.num_devolucion = c.num_devolucion and c.compania = d.compania and c.cod_familia = d.cod_flia and c.cod_clase = d.cod_clase and c.cod_articulo = d.cod_articulo and nvl(c.cantidad,0) >0 and a.num_devolucion = ");
		sbSql.append(codigo);
		sbSql.append(" and a.anio = ");
		sbSql.append(anio);
	}
		
		if(codigo_barra!=null && !codigo_barra.equals("")){
			sbSql.append(" and d.cod_barra = '");
			sbSql.append(codigo_barra);
			sbSql.append("'");
		}

		CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
		CommonDataObject _cdo = new CommonDataObject();
		String msg2 = "";
		if(cdo!=null){
		//recArt.clear();
		//recArtKey.clear();
			lineNo=recArtKey.size();
			cdo.addColValue("despachado", "1");

			cdo.addColValue("no_serie", request.getParameter("no_serie"));
			cdo.addColValue("fecha_vence", request.getParameter("fecha_vence"));
			cdo.addColValue("cod_barra_gs1", request.getParameter("cod_barra_gs1"));
			
			System.out.println("cod_barra_gs1...................="+request.getParameter("cod_barra_gs1"));

			key = "";
			okey = "";
			String artKey = cdo.getColValue("cod_articulo");
			if(recArtKey.containsKey(artKey)) okey = (String) recArtKey.get(artKey);
			if (recArt.containsKey(okey)){
				_cdo = (CommonDataObject) recArt.get(okey);
				_cdo.addColValue("despachado", ""+(Integer.parseInt(_cdo.getColValue("despachado"))+1));
				System.out.println("okey="+okey+", despachado= "+_cdo.getColValue("despachado"));
				cdo = _cdo;
			}
			//if(!det.getCantidadRecibida().equals(det.getCantOC())){
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				if(!okey.equals("")) key = okey;

				try {
					recArt.put(key, cdo);
					recArtKey.put(cdo.getColValue("cod_articulo"), key);
					//RecDet.getRecepDetails().add(cdo);
					System.out.println("adding2...= "+key);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			//}
			System.out.println("recArt="+recArt.size());
			//RecDet.setRecepDetails(new ArrayList (recArt.values()));
			} else cdo = new CommonDataObject();
			msg = "";
			System.out.println("itemCode="+cdo.getColValue("cod_articulo"));
			if(cdo.getColValue("cod_articulo")==null || cdo.getColValue("cod_articulo").equals("0")) msg = "El articulo escaneado "+codigo_barra+" no existe en la Solicitud!";
			else if(!msg2.equals("")) msg = msg2;
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&fecha="+fecha+"&change=1&type="+type+"&codAlmacen="+codAlmacen+"&fp="+fp+"&pac_id="+pac_id+"&codigo="+codigo+"&anio="+anio+"&adm_secuencia="+adm_secuencia+"&msg="+msg+"&fg="+fg);
			return;
		}
	/*===================================================================================================*/
	/*===================================================================================================*/

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("entrega de insumos")){
		CdcSolMgr.updateSolPac(cdcDet);
		refer_no = CdcSolMgr.getPkColValue("refer_no");
	} else if (request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("cargar o devolver")){
		CdcSolMgr.updateUsos(cdcDet);
		refer_no = CdcSolMgr.getPkColValue("refer_no");
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
<%
if (CdcSolMgr.getErrCode().equals("1")){
		String LotExpirationDate = java.util.ResourceBundle.getBundle("issi").getString("LotExpirationDate");
		if(LotExpirationDate==null || LotExpirationDate.equals("")) LotExpirationDate = "N";

%>
	alert('<%=CdcSolMgr.getErrMsg()%>');
	<%if(type.equals("SP")){%>
	printSol();
	<%} else if (type.equals("CU")){%>
	printUso();
	<%}
	if(type.equals("SP")){
	if(LotExpirationDate.equals("Y")){
	%>
	regLoteFecha();
	//window.location = '../inventario/reg_lote_fecha_vencimiento.jsp?ref_type=delivery&ref_code=<%=refer_no%>';
	<%
	}	
		%>
	
	//window.location = '../inventario/print_solicitud_pac.jsp?id=<%=codigo%>&anio=<%=anio%>';
	<%} else if(type.equals("CU")){%>
	window.location = '../inventario/detalle_insumos_usos.jsp?type=<%=type%>&fecha=<%=fecha%>&codAlmacen=<%=codAlmacen%>&pac_id=<%=pac_id%>&codigo=<%=codigo%>&anio=<%=anio%>&adm_secuencia=<%=adm_secuencia%>';
	<%}%>
<%
} else throw new Exception(CdcSolMgr.getErrMsg());
%>
}

function regLoteFecha(){
		win=window.open('../inventario/reg_lote_fecha_vencimiento.jsp?ref_type=delivery&ref_code=<%=issi.admin.IBIZEscapeChars.forURL(refer_no)%>');
		win.moveTo(0,0);win.resizeTo(screen.availWidth,screen.availHeight);
		return win;
}
function printSol(){
	win=window.open('../inventario/print_solicitud_pac.jsp?id=<%=codigo%>&anio=<%=anio%>');
		win.moveTo(0,0);win.resizeTo(screen.availWidth,screen.availHeight);
		return win;
}
function printUso(){
	win=window.open('../inventario/print_solicitud_pac_uso.jsp?id=<%=issi.admin.IBIZEscapeChars.forURL(refer_no)%>&anio=<%=anio%>&codigo=<%=codigo%>&pac_id=<%=pac_id%>&adm_secuencia=<%=adm_secuencia%>');
		win.moveTo(0,0);win.resizeTo(screen.availWidth,screen.availHeight);
		return win;
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
