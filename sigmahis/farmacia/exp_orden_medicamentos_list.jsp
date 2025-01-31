<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="OFarmMgr" scope="session" class="issi.farmacia.OrdenFarmMgr"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OFarmMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
CommonDataObject cdoP = new CommonDataObject();

String appendFilter = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String noOrden = request.getParameter("noOrden");
String codOrdenMed = request.getParameter("codigo_orden_med")==null?"":request.getParameter("codigo_orden_med");
String orden = request.getParameter("orden")==null?"":request.getParameter("orden");
String tipo = request.getParameter("tipo");
String mode = request.getParameter("mode");
String fecha = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String idArticulo = request.getParameter("idArticulo");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String codigo = request.getParameter("codigo");
String categoriaAdm = request.getParameter("categoria_adm");
String printOF = request.getParameter("print_of")==null?"":request.getParameter("print_of");

String validaCja = request.getParameter("validaCja");
String turno = request.getParameter("turno");
String caja = request.getParameter("caja");
String companiaRef = "";
try {companiaRef =java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");}catch(Exception e){ companiaRef = "";}
if(companiaRef == null || companiaRef.trim().equals("")) companiaRef = "";
String whFar = java.util.ResourceBundle.getBundle("farmacia").getString("whFar");
if(whFar == null || whFar.trim().equals("")) whFar = "null";
String whHosp = java.util.ResourceBundle.getBundle("farmacia").getString("whHosp");
if(whHosp == null || whHosp.trim().equals("")) whFar = "null";
String expVersion = "1";
String idFar="";
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if(mode==null) mode="despachar";
if(idArticulo==null) idArticulo="";
if(codigo==null) codigo="";
if(fg==null) fg="";
if(fp==null) fp="";
if(id==null) id="";
if(categoriaAdm==null) categoriaAdm="0";
if(fechaHasta==null) fechaHasta="";
if(fecha==null) fecha="";
if(turno==null) turno="";
if(validaCja==null) validaCja="N";
boolean viewMode = false;
if(!mode.equals("despachar")) viewMode = true;

boolean chkSeguirDesp = false;
boolean showDiagWeight = false;
CommonDataObject cdoPacXtra = new CommonDataObject();
String compania = (String) session.getAttribute("_companyId");
boolean isHospital = ((issi.admin.Compania) session.getAttribute("_comp")).getHospital().equalsIgnoreCase("S");
sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CHECK_DISP'),'S') as valida_dsp, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'CDS_FAR'),'-') as cds_far, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'FAR_CHK_SEGUIR_DESPACHANDO'),'N') as seguir_desp, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'FAR_SHOW_DIAG_WEIGHT'),'N') as show_diag_weight,nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'USA_SYS_FAR_EXTERNA'),'N') as usa_sys_far_externa,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'FAR_REG_MARBETE'),'N') as FAR_REG_MARBETE,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'FAR_SOLO_APROB'),'N') as farSoloAprob,nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'FAR_GENERAR_TRX_POS'),'N') as v_far_generar_pos  from dual");
	cdoP = SQLMgr.getData(sbSql.toString());
	if (cdoP == null) {
		cdoP = new CommonDataObject();
		cdoP.addColValue("valida_dsp","S");
		cdoP.addColValue("cds_far","-");
		cdoP.addColValue("seguir_desp","N");
		cdoP.addColValue("show_diag_weight","N");
		cdoP.addColValue("usa_sys_far_externa","N");
		cdoP.addColValue("addCantidad","N");
		cdoP.addColValue("FAR_REG_MARBETE","N");
		cdoP.addColValue("farSoloAprob","N");
		cdoP.addColValue("v_far_generar_pos","S");

	}
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (pacId == null || noAdmision == null) throw new Exception("La Admisi�n no es v�lida. Por favor intente nuevamente!");
	if (tipo == null) tipo = "";
	if (tipo.trim().equalsIgnoreCase("A")){ appendFilter += " and ( a.estado_orden='A'    or (   a.estado_orden = 'S' ";
	 if(!fecha.trim().equals(""))appendFilter += " and trunc(a.fecha_suspencion) >= to_date('"+fecha+"','dd/mm/yyyy') ";
	 if(!fechaHasta.trim().equals(""))appendFilter += "and trunc(a.fecha_suspencion) <= to_date('"+fechaHasta+"','dd/mm/yyyy')" ;
	 appendFilter +=  " )or (   a.estado_orden = 'F' ";
	 if(!fecha.trim().equals(""))appendFilter += " and trunc(a.fecha_fin) >= to_date('"+fecha+"','dd/mm/yyyy') ";
	 if(!fechaHasta.trim().equals(""))appendFilter += "and trunc(a.fecha_fin) <= to_date('"+fechaHasta+"','dd/mm/yyyy')" ;
	 appendFilter +=  " ))";
	 }
	else appendFilter += " and a.estado_orden!='A'";
	//if(!id.trim().equals(""))appendFilter += " and f.id="+id;



		chkSeguirDesp = categoriaAdm.equals("1") && ( (cdoP.getColValue("seguir_desp","N")).equalsIgnoreCase("S") || (cdoP.getColValue("seguir_desp","N")).equalsIgnoreCase("Y") );
		showDiagWeight = (cdoP.getColValue("show_diag_weight","N")).equalsIgnoreCase("S") || (cdoP.getColValue("show_diag_weight","N")).equalsIgnoreCase("Y");

	if (cdoP.getColValue("cds_far").equals("-")) throw new Exception("El par�metro de centro de farmacia (CDS_FAR) no est� definido!");


boolean excep=true;
if (fg.trim().equals("BM")){excep=false;}
else if (!fg.trim().equals("BM")){
	if (mode.equalsIgnoreCase("recibir")) {
		if (isHospital) excep = false;
	} else {
		if (compania.trim().equals(companiaRef)&&cdoP.getColValue("usa_sys_far_externa","N").trim().equals("N")){excep=true;}
		else excep=false;
	}
}

if(excep)throw new Exception("Opcion Solo Para Compa�ia Hospital!");

	if(mode.equals("despachar")){

	sbSql = new StringBuffer();
	sbSql.append("select to_char(a.fecha_orden,'dd/mm/yyyy') as fechamedica, a.nombre, a.dosis, (select descripcion from tbl_sal_via_admin where codigo=a.via) as descvia, a.frecuencia, a.observacion, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, decode(a.estado_orden,'A',' ','S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),'F',to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),'--') as hasta, decode(a.estado_orden,'S',a.obser_suspencion,'F',a.usuario_creacion,'--') usuario_omit, '['||a.usuario_creacion||'] - '||b.name  as usuario_crea, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, a.codigo, a.concentracion, a.cod_paciente, to_char(a.fec_nacimiento, 'dd/mm/yyyy') fec_nacimiento, a.secuencia admision, a.tipo_orden, orden_med, a.procedimiento, a.diagnostico, c.medico, a.prioridad, a.cod_tratamiento, a.pac_id, 0 secuencia, a.codigo_orden_med, a.centro_servicio, a.stat, decode('"+fg+"','BM',a.id_articulo,case when (select count(*) from tbl_inv_articulo_bm where cod_articulo=a.id_articulo and compania =a.comp_articulo and estado ='A') <> 0  then '' else a.id_articulo end ) as codigo_articulo,(select descripcion from tbl_inv_articulo where compania=");
	//if(fg.trim().equals("BM"))
	sbSql.append(" a.comp_articulo");
	//else sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and cod_articulo = a.id_articulo) descripcion,nvl((select precio_venta from tbl_inv_articulo where compania=");
	if(fg.trim().equals("BM"))sbSql.append(" a.comp_articulo");
	else sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and cod_articulo = a.id_articulo),0) precio_unitario,nvl((select other3 from tbl_inv_articulo where compania=");
	if(fg.trim().equals("BM"))sbSql.append(" a.comp_articulo");
	else sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and cod_articulo = a.id_articulo),'Y') afecta_inv, ");
	if (fg.trim().equals("BM")) sbSql.append("a.centro_servicio");
	else sbSql.append(cdoP.getColValue("cds_far"));
	sbSql.append(" as cds_cargo,0 id,(select nvl(precio,0) from tbl_inv_inventario where cod_articulo =a.id_articulo and compania=");
	if(fg.trim().equals("BM"))sbSql.append(" a.comp_articulo");
	else sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and codigo_almacen =");
	if(!fg.trim().equals("BM"))sbSql.append(whFar);else sbSql.append(whHosp);
	sbSql.append(") as costo,a.id_articulo,decode(a.estado_orden,'S',0,'F',0,null) as cantidad,a.estado_orden as estadoOrd,(select count(*) from tbl_inv_articulo_bm where cod_articulo=id_articulo and compania =a.comp_articulo and estado ='A') esBm,a.dosis_desc, a.wh,a.cantidad as cant from tbl_sal_detalle_orden_med a, tbl_sec_users b, tbl_sal_orden_medica c where a.pac_id=");
	sbSql.append(pacId);
	sbSql.append(" and a.secuencia=");
	sbSql.append(noAdmision);
	sbSql.append(" and a.codigo_orden_med = ");
	sbSql.append(noOrden);
	sbSql.append(" and b.user_name(+) = a.usuario_creacion and a.tipo_orden in(2,13,14) and nvl(a.omitir_orden,'N')='N'");
	sbSql.append(appendFilter);
	if(fg.trim().equals("BM")){sbSql.append(" and a.id_articulo is not null and exists (select null from tbl_inv_articulo_bm where cod_articulo=a.id_articulo and compania =a.comp_articulo and estado ='A') ");}

	sbSql.append(" and a.orden_med = c.codigo and a.secuencia = c.secuencia and a.pac_id = c.pac_id ");

	sbSql.append(" and not exists (select 1   from tbl_int_orden_farmacia f where  f.codigo_orden_med=a.codigo_orden_med  and f.codigo= a.codigo and f.pac_id = a.pac_id and f.admision=a.secuencia and f.orden_med=a.orden_med and cantidad is not null  and nvl(f.aprobado_desp,'N') = 'N' ");
	if (cdoP.getColValue("farSoloAprob").equals("S")) sbSql.append(" and nvl(f.aprobado_desp,'N') = 'N'  ");

	sbSql.append(" ) ");
	sbSql.append("  order by a.fecha_orden desc, a.codigo desc");

	} else if(mode.equals("aprobar") || mode.equals("recibir")||mode.equals("rechazar")){sbSql = new StringBuffer();


if(validaCja.trim().equals("S") && turno.trim().equals(""))throw new Exception("No ha Definido Caja O No tiene turno Creado. Por Favor Consulte con su administrador !");


	sbSql.append("select to_char(a.fecha_orden,'dd/mm/yyyy') as fechamedica, a.nombre, a.dosis, (select descripcion from tbl_sal_via_admin where codigo=a.via) as descvia, a.frecuencia, a.observacion, (select descripcion from tbl_sal_desc_estado_ord where estado=a.estado_orden) as estado_orden, decode(a.estado_orden,'A',' ','S',to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),'F',to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am'),'--') as hasta, decode(a.estado_orden,'S',a.obser_suspencion,'F',a.usuario_creacion,'--') usuario_omit, '['||a.usuario_creacion||'] - '||b.name  as usuario_crea, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, a.codigo, a.concentracion, a.cod_paciente, to_char(a.fec_nacimiento, 'dd/mm/yyyy') fec_nacimiento, a.secuencia admision, a.tipo_orden, a.orden_med, a.procedimiento, a.diagnostico, c.medico, a.prioridad, a.cod_tratamiento, a.pac_id, f.codigo_articulo, f.descripcion, f.cantidad, f.observacion observacion_desp, f.secuencia, f.precio_unitario, f.precio_subtotal, a.codigo_orden_med, a.centro_servicio, a.stat ,nvl((select other3 from tbl_inv_articulo where compania = ");
	if (fg.trim().equals("BM")) sbSql.append("a.comp_articulo");
	else sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and cod_articulo = f.codigo_articulo),'Y') afecta_inv, ");
	if (fg.trim().equals("BM")) sbSql.append("a.centro_servicio");
	else sbSql.append(cdoP.getColValue("cds_far"));
	sbSql.append(" as cds_cargo,f.id,nvl(f.costo,0)as costo,f.almacen as wh ,nvl(f.replicado,'N')replicado ,a.id_articulo,a.estado_orden as estadoOrd,a.dosis_desc,a.cantidad as cant, f.other2 from tbl_sal_detalle_orden_med a, tbl_sec_users b, tbl_sal_orden_medica c, tbl_int_orden_farmacia f where a.pac_id=");
	sbSql.append(pacId);
	sbSql.append(" and a.secuencia=");
	sbSql.append(noAdmision);
	sbSql.append(" and a.codigo_orden_med = ");
	sbSql.append(noOrden);
	sbSql.append(" and b.user_name(+) = a.usuario_creacion and a.tipo_orden  in(2,13,14) and nvl(a.omitir_orden,'N')='N'");
	sbSql.append(appendFilter);
	if(fg.trim().equals("BM")){sbSql.append(" and f.fg='BM'");}
	else {sbSql.append(" and nvl(f.fg,'x') <> 'BM'");}
	if(mode.equals("aprobar")){sbSql.append(" and f.no_cargo is null ");}
	if(mode.equals("recibir")){sbSql.append(" and f.estado in ('A') and f.no_cargo is not null and f.no_cargo_det is not null  ");}

	sbSql.append(" and a.orden_med = c.codigo and a.secuencia = c.secuencia and a.pac_id = c.pac_id and a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.other1 = 1 order by a.fecha_orden desc, a.codigo desc");
	}
	al = SQLMgr.getDataList(sbSql.toString());

		if (showDiagWeight){
			sbSql = new StringBuffer();

			sbSql.append("select (select '['||codigo||'] '||nvl(observacion,nombre) from tbl_cds_diagnostico where codigo = (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and admision = ");
			sbSql.append(noAdmision);
			sbSql.append(" and tipo = 'I' and orden_diag = 1 and rownum = 1)) diag_desc, nvl ( (select peso from ( select * from (select peso, max(fecha_nota) from tbl_sal_resultado_nota where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and secuencia = ");
			sbSql.append(noAdmision);
			sbSql.append(" and peso <> '0' group by peso order by max(fecha_nota) desc ) where rownum = 1  )) , decode (");
			sbSql.append(categoriaAdm);
			sbSql.append(" , 2, ( select resultado from (select * from (select resultado, max(fecha_signo) from tbl_sal_detalle_signo z where pac_id = ");
			sbSql.append(pacId);
			sbSql.append(" and secuencia = ");
			sbSql.append(noAdmision);
			sbSql.append(" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and signo_vital = 8 group by resultado order by max(fecha_signo) desc) where rownum = 1 )), 'N/A')) as peso from dual ");

			cdoPacXtra = SQLMgr.getData(sbSql.toString());
		}
		if (cdoPacXtra == null) cdoPacXtra = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Medicamentos Activos - '+document.title;
function doAction(){}
function selArticle(i){var wh='';if(eval('document.form1.codigoAlmacen'+i))wh=eval('document.form1.codigoAlmacen'+i).value;abrir_ventana2('../inventario/sel_articles_farmacia.jsp?fp=medicamentos&index='+i+'&idArticulo=<%=idArticulo%>&fg=<%=fg%>&usa_sys_far_externa=<%=cdoP.getColValue("usa_sys_far_externa","N")%>&wh='+wh);}
function chkCant(){var afecta_inv ='';var size = <%=al.size()%>;var cant = 0;var err = 0;var art = '';var desArt='';
var cantCk=0;

for(i=0;i<size;i++){

cant = eval('document.form1.cantidad'+i).value;
art = eval('document.form1.codigo_articulo'+i).value;
afecta_inv = eval('document.form1.afecta_inv'+i).value;
desArt = eval('document.form1.descripcion'+i).value;

if(cant!=0 && art == ''){alert('Seleccione art�culo!');err++;break;}
if(cant<0){alert('Cantidad Invalida');err++;break;}

if(eval('document.form1.chk'+i).checked ==true)
{

if(cant==''){alert('Introduzca Cantidad!');err++;break;}
if(cant==0 && (eval('document.form1.observacion'+i).value).trim()==''){alert('Introduzca Observacion');err++;break;}
if(err==0)cantCk ++;
}
var wh='';
<%if(fg.trim().equals("BM")){%>
wh =eval('document.form1.codigoAlmacen'+i).value;
if(wh.trim()==''){alert('Almacen Invalido');err++;break;}
<%}else{%>
wh ='<%=whFar%>';
<%}%>

if(cant!=0 && art != '' && eval('document.form1.chk'+i).checked ==true){
//alert('cant ='+cant+' art ='+art+' i= '+i );
<%if((mode.equals("aprobar")||mode.equals("despachar"))){%>
	<%if(cdoP.getColValue("valida_dsp").trim().equals("S")){%>
		if(afecta_inv=='Y'){
		var disponible = getInvDisponible('<%=request.getContextPath()%>', <%=(!fg.trim().equals("BM"))?(String) session.getAttribute("_companyId"):companiaRef%>,wh,null,null,art);
		if(isNaN(disponible)) disponible = 0;
		if(disponible==0){
			CBMSG.warning('No hay Existencia del articulo = '+art+' - '+desArt +'!');
			err++;break;
		} else if(cant>disponible){
			CBMSG.warning('Cantidad NO disponible en Inventario - articulo = '+art+' - '+desArt +'!');
			eval('document.form1.cantidad'+i).value = '';
			err++;break;
		}}
		<%}}%>
}
if(cant!=0 && art == ''){alert('Seleccione art�culo!');err++;break;}
}

if(err==0){if(cantCk!=0)return true;else{alert('No hay registros seleccionados'); return false;}}else return false;
}

function checkDespachar(k)
{<%if(mode.trim().equals("despachar")){%>
if(eval('document.form1.chk'+k).checked ==true)
{
 eval('document.form1.cantidad'+k).className = "FormDataObjectRequired";

}else {/*eval('document.form1.cantidad'+k).className = "FormDataObjectEnabled";*/eval('document.form1.cantidad'+k).className = "FormDataObjectDesabled";}
<%}%>
}
function checkCantidad(k)
{
var cantidad = eval('document.form1.cantidad'+k).value
if(cantidad!=''){eval('document.form1.chk'+k).checked =true;}else{eval('document.form1.chk'+k).checked =false; eval('document.form1.observacion'+k).className = "FormDataObjectDesabled";}

<%if(mode.trim().equals("despachar")){%>
if(eval('document.form1.chk'+k).checked ==true)
{
if(cantidad=='0'){
eval('document.form1.observacion'+k).className = "FormDataObjectRequired";
}else eval('document.form1.observacion'+k).className = "FormDataObjectDesabled";
}
<%}else{%>
if(cantidad=='0'){
eval('document.form1.observacion'+k).readOnly=false;
eval('document.form1.observacion'+k).className = "FormDataObjectRequired";
}else eval('document.form1.observacion'+k).className = "FormDataObjectDesabled";
<%}%>
}
function rechazarOrden(k){
if(eval('document.form1.rechazar'+k).checked ==true)
{
eval('document.form1.cantidad'+k).value =0;
eval('document.form1.observacion'+k).readOnly=false;
eval('document.form1.observacion'+k).className = "FormDataObjectRequired";
//eval('document.form1.cantidad'+k).readOnly=false;
//eval('document.form1.cantidad'+k).className = "FormDataObjectRequired";
}
else
{

eval('document.form1.observacion'+k).value=eval('document.form1.observacionOld'+k).value;
eval('document.form1.observacion'+k).readOnly=true;
eval('document.form1.observacion'+k).className = "FormDataObjectEnabled";
//eval('document.form1.cantidad'+k).readOnly=true;
eval('document.form1.cantidad'+k).value = eval('document.form1.cantidadOld'+k).value;
//eval('document.form1.cantidad'+k).className = "FormDataObjectDesabled";

}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="MEDICAMENTOS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table width="100%" cellpadding="0" cellspacing="0" class="TableBorderLightGray">
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRowWhite">
			<td colspan="4" width="100%">
			<jsp:include page="../common/ialert.jsp" flush="true">
			<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="fp" value="expediente"></jsp:param>
			<jsp:param name="displayArea" value="expediente"></jsp:param>
			<jsp:param name="admision" value="<%=noAdmision%>"></jsp:param>
			</jsp:include>
			</td>
		</tr>
		</table>
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");
String colspan = "10";
if(mode.equals("despachar")) colspan = "10";
if(expVersion.equals("3"))colspan = "11";
%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("size", ""+al.size())%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fecha",fecha)%>
<%=fb.hidden("idArticulo",idArticulo)%>
<%=fb.hidden("categoria_adm",categoriaAdm)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("noOrden",noOrden)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("print_of",printOF)%>
<%=fb.hidden("orden",orden)%>
<%=fb.hidden("codigo_orden_med",codOrdenMed)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("fechaHasta",fechaHasta)%>
<%=fb.hidden("far_reg_marbete",cdoP.getColValue("FAR_REG_MARBETE"))%>
<%=fb.hidden("caja",caja)%>
<%=fb.hidden("turno",turno)%>
<%=fb.hidden("validaCja",validaCja)%>
<%=fb.hidden("farSoloAprob",cdoP.getColValue("farSoloAprob"))%>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
				<%if(showDiagWeight){%>
		<tr class="TextHeader02">
			<td colspan="<%=colspan%>">Diagn&oacute;stico:&nbsp;&nbsp;<%=cdoPacXtra.getColValue("diag_desc","N/A")%></td>
		</tr>
				<tr class="TextHeader02">
			<td colspan="<%=colspan%>">Peso:&nbsp;&nbsp;<%=cdoPacXtra.getColValue("peso","N/A")%></td>
		</tr>
				<%}%>

				<tr class="TextHeader">
			<td colspan="<%=colspan%>" align="center"><cellbytelabel id="1">Listado de Medicamentos Ordenados</cellbytelabel> - <%=(tipo.trim().equalsIgnoreCase("A"))?"ACTIVOS":"OMITIDOS"%> &nbsp;-&nbsp;<cellbytelabel id="12">ORDEN No</cellbytelabel>.<%=noOrden%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel id="2">Fecha</cellbytelabel></td>
			<td width="15%"><cellbytelabel id="3">Medicamento</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="4">Concentraci&oacute;n</cellbytelabel></td>
			<!--<td width="8%"><cellbytelabel id="5">Dosis</cellbytelabel></td>-->
			<td width="8%"><cellbytelabel id="6">V&iacute;a</cellbytelabel></td>
			<td width="17%"><cellbytelabel id="7">Frecuencia</cellbytelabel></td>
			<td width="<%=expVersion.equals("3")?"13%":"18%"%>"><cellbytelabel id="8">Observaci&oacute;n</cellbytelabel></td>
			<%if(expVersion.equals("3")){%><td width="5%">Dosis</td><%}%>
			<td width="10%"><%=(tipo.trim().equalsIgnoreCase("A"))?"Ordenado":"Omitido"%> <cellbytelabel id="11">por</cellbytelabel></td>
			<td width="9%"><cellbytelabel id="10">Fec.-Hora</cellbytelabel></td>
			<%
			if(mode.equals("aprobar") || mode.equals("recibir")||mode.equals("rechazar")||mode.equals("despachar")){
			%>
			<td width="2%">&nbsp;</td>
			<%
			}
			%>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
	<%=fb.hidden("nombre"+i, cdo.getColValue("nombre"))%>
	<%=fb.hidden("frecuencia"+i, cdo.getColValue("frecuencia"))%>
	<%=fb.hidden("codigo"+i, cdo.getColValue("codigo"))%>
	<%=fb.hidden("codigo_orden_med"+i, cdo.getColValue("codigo_orden_med"))%>
	<%=fb.hidden("secuencia"+i, cdo.getColValue("secuencia"))%>
	<%=fb.hidden("concentracion"+i, cdo.getColValue("concentracion"))%>
	<%=fb.hidden("pac_id"+i, cdo.getColValue("pac_id"))%>
	<%=fb.hidden("cod_paciente"+i, cdo.getColValue("cod_paciente"))%>
	<%=fb.hidden("fec_nacimiento"+i, cdo.getColValue("fec_nacimiento"))%>
	<%=fb.hidden("admision"+i, cdo.getColValue("admision"))%>
	<%=fb.hidden("tipo_orden"+i, cdo.getColValue("tipo_orden"))%>
	<%=fb.hidden("orden_med"+i, cdo.getColValue("orden_med"))%>
	<%=fb.hidden("procedimiento"+i, cdo.getColValue("procedimiento"))%>
	<%=fb.hidden("diagnostico"+i, cdo.getColValue("diagnostico"))%>
	<%=fb.hidden("medico"+i, cdo.getColValue("medico"))%>
	<%=fb.hidden("prioridad"+i, cdo.getColValue("prioridad"))%>
	<%=fb.hidden("cod_tratamiento"+i, cdo.getColValue("cod_tratamiento"))%>
	<%=fb.hidden("precio_unitario"+i, cdo.getColValue("precio_unitario"))%>
	<%=fb.hidden("precio_subtotal"+i, cdo.getColValue("precio_subtotal"))%>
	<%=fb.hidden("centro_servicio"+i, cdo.getColValue("centro_servicio"))%>
	<%=fb.hidden("afecta_inv"+i, cdo.getColValue("afecta_inv"))%>
	<%=fb.hidden("cds_cargo"+i, cdo.getColValue("cds_cargo"))%>
	<%//=fb.hidden("wh"+i, cdo.getColValue("wh"))%>
	<%=fb.hidden("id"+i, cdo.getColValue("id"))%>
	<%=fb.hidden("costo"+i, cdo.getColValue("costo"))%>
	<%=fb.hidden("cantidadOld"+i, cdo.getColValue("cantidad"))%>
	<%=fb.hidden("observacionOld"+i, cdo.getColValue("observacion_desp"))%>
	<%=fb.hidden("other2"+i, cdo.getColValue("other2"))%>

		<tr class="<%=color%>">
			<td align="center"><%=cdo.getColValue("fechamedica")%>-<%=cdo.getColValue("orden_med") %></td>
			<td>
			<%if(mode.equals("despachar")){%>
			 <%if(cdo.getColValue("id_articulo")!=null && !cdo.getColValue("id_articulo").trim().equals("")&& !cdo.getColValue("esBm").trim().equals("0")){%>
			<cellbytelabel id="11"><font size="2" color="#FF0000"><%=cdo.getColValue("nombre")%></font>
			<%}else{%><%=cdo.getColValue("nombre")%><%}%>
			<%}else{%>
						<%=cdo.getColValue("nombre")%>
			<%}%>
			</td>
			<td align="center"><%=cdo.getColValue("concentracion")%></td>
			<!--<td width="8%" align="center"><%//=cdo.getColValue("dosis")%></td>-->
			<td align="center"><%=cdo.getColValue("descVia")%></td>
			<td align="center"><%=cdo.getColValue("frecuencia")%></td>
			<td><%=cdo.getColValue("observacion")%></td>
			<%if(expVersion.equals("3")){%><td><%=cdo.getColValue("dosis_desc")%></td><%}%>
			<td align="center"><%=cdo.getColValue("usuario_crea")%></td>
			<td align="center"><%=cdo.getColValue("fecha_creacion")%></td>
					<%if(mode.equals("aprobar") || mode.equals("recibir")||mode.equals("rechazar")||mode.equals("despachar")){%>
			<td  align="center" rowspan="2"><%=fb.checkbox("chk"+i,""+i,(mode.equals("despachar"))?false:true,false,"text10",null,"onClick=\"javascript:checkDespachar("+i+")\"",(mode.trim().equals("aprobar"))?"AL SELECCIONAR, ESTAR� DESPACHANDO Y GENERANDO CARGO AL PACIENTE":"")%></td>
			<%
			}
			%>
		</tr>
		<tr class="<%=color%>">
			<td colspan="3"><%if(mode.equals("aprobar")){%><authtype type='52'>Rechazar<%=fb.checkbox("rechazar"+i,""+i,false,false,"text10",null,"onClick=\"javascript:rechazarOrden("+i+")\"","RECHAZAR APROBACION DE ARTICULO")%> </authtype><%}%> <cellbytelabel id="12">

			Cantidad</cellbytelabel>:&nbsp;<%=fb.intBox("cantidad"+i,cdo.getColValue("cantidad"),false,false,((mode.equals("despachar")||(mode.equals("aprobar") && cdo.getColValue("replicado").trim().equals("S")))?false:true),10,"text10",null,"onChange=\"javascript:checkCantidad("+i+")\"")%><%if(mode.equals("despachar")||mode.equals("aprobar")){%><%if((mode.equals("despachar")||(mode.equals("aprobar") && cdo.getColValue("replicado").trim().equals("S")))){%><font class="RedTextBold" size="2">Ingrese CERO (0) para Rechazar</font><br><%}}%>
			<% if (fg.equalsIgnoreCase("BM")) { %><br>
			<cellbytelabel id="3">Almacen</cellbytelabel>:<%=fb.select(ConMgr.getConnection(),"SELECT distinct a.almacen, b.descripcion||' - '||a.almacen, a.almacen FROM tbl_sec_cds_almacen a,tbl_inv_almacen b where a.almacen=b.codigo_almacen and b.compania="+(String) session.getAttribute("_companyId")+" and a.cds = "+cdo.getColValue("centro_servicio")+" and is_bm = 'Y' ORDER  BY 1","codigoAlmacen"+i,cdo.getColValue("wh"),false,(viewMode),0,"Text10",null,"onChange=\"javascript:setFormFieldsBlank(this.form.name,'codigo_articulo"+i+",descripcion"+i+"');\"")%>
			<% } else { %><%=fb.hidden("codigoAlmacen"+i,whFar)%><% } %>
			<%if(mode.equals("aprobar")||(mode.equals("despachar")&&cdoP.getColValue("farSoloAprob").trim().equals("S"))){%><font class="RedText" size="2">Seguir Despachando: ??</font><%=fb.checkbox("seguir_despachando"+i,""+i,chkSeguirDesp,false,"text10",null,"","")%><%}%></td>
			<td colspan="3">
			<%if(cdoP.getColValue("addCantidad").trim().equals("S")){%><font class="RedTextBold" size="2">Cantidad solicitada: <%=cdo.getColValue("cant")%></font> <br><%}%>
			<cellbytelabel id="13">Art&iacute;culo</cellbytelabel>:&nbsp;
			<%=fb.intBox("codigo_articulo"+i,cdo.getColValue("codigo_articulo"),false,false,true,8,"text10",null,"")%>
			<%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,true,45,"text10",null,"")%>
			<%=fb.button("buscar","...",false,((mode.equals("despachar")||cdo.getColValue("replicado").trim().equals("S"))?false:true),"","","onClick=\"javascript:selArticle("+i+")\"")%>

						<%if((mode.equals("aprobar") || mode.equals("despachar") || mode.equals("recibir")) && cdo.getColValue("stat")!=null && cdo.getColValue("stat").equalsIgnoreCase("Y")){%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="RedTextBold">STAT</span><%}%>

			</td>
			<td colspan="<%=((mode.equals("aprobar")||mode.equals("recibir")||mode.equals("rechazar"))?"3":"3")%>"><cellbytelabel id="14">Observaci&oacute;n</cellbytelabel>:&nbsp;<br>
			<%=fb.textarea("observacion"+i,cdo.getColValue("observacion_desp"),(cdo.getColValue("estadoOrd").trim().equals("S") || cdo.getColValue("estadoOrd").trim().equals("F") )?true:false,false,(((!mode.equals("aprobar")||cdo.getColValue("replicado").trim().equals("S")))?false:true),30,2,"text10",null,"")%></td>
	</tr>
<%
}	fb.appendJsValidation("if(!chkCant())error++;");

%>
	<tr class="TextRow02">
			<td colspan="<%=colspan%>" align="right">
				<%//=fb.submit("save","Guardar",true,false,null,null,"")%>
				<%if(mode.equals("aprobar")&&cdoP.getColValue("addCantidad").trim().equals("S")){%><font class="RedText" size="2">Despachado Por::</font><%=fb.textBox("usuario","",true,false,false,25,"text10",null,"")%> <%}%>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("close","Cerrar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>

<tr class="TextPanel pointer" onClick="javascript:showHide(1)">
	<td>[<font face="Courier New, Courier, mono"><label id="plus1">+</label><label id="minus1" style="display:none">-</label></font>]&nbsp;Insumos/Servicios<span id="_insumos" style="display:none;"></span></td>
</tr>
<tr id="panel1" style="display:none">
	<td>
	<jsp:include page="../farmacia/far_insumos.jsp" flush="true">
		<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
		<jsp:param name="noAdmision" value="<%=noAdmision%>"></jsp:param>
		<jsp:param name="noOrden" value="<%=noOrden%>"></jsp:param>
		<jsp:param name="codigo_orden_med" value="<%=codOrdenMed%>"></jsp:param>
		<jsp:param name="id" value="<%=id%>"></jsp:param>
		<jsp:param name="mode" value="<%=mode%>"></jsp:param>
 </jsp:include>

	</td>
</tr>

</table>
</body>
</html>
<%
}//GET
else
{

	int size = Integer.parseInt(request.getParameter("size"));
	al.clear();
	String other2 = "";
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
		if(i==0)other2 = request.getParameter("other2"+i);
		cdo.addColValue("id", request.getParameter("id"+i));
		cdo.addColValue("pac_id", request.getParameter("pac_id"+i));
		cdo.addColValue("cod_paciente", request.getParameter("cod_paciente"+i));
		cdo.addColValue("fec_nacimiento", request.getParameter("fec_nacimiento"+i));
		cdo.addColValue("admision", request.getParameter("admision"+i));
		cdo.addColValue("tipo_orden", request.getParameter("tipo_orden"+i));
		cdo.addColValue("orden_med", request.getParameter("orden_med"+i));
		cdo.addColValue("codigo", request.getParameter("codigo"+i));
		cdo.addColValue("nombre", request.getParameter("nombre"+i));
		cdo.addColValue("medico", request.getParameter("medico"+i));
		cdo.addColValue("cds_cargo", request.getParameter("cds_cargo"+i));
		cdo.addColValue("cds", request.getParameter("centro_servicio"+i));
		cdo.addColValue("fp", request.getParameter("fp"));
		if(request.getParameter("usuario")!= null)cdo.addColValue("usuarioDespacha", request.getParameter("usuario"));

		cdo.addColValue("costo", request.getParameter("costo"+i));

		cdo.addColValue("codigo_orden_med", request.getParameter("codigo_orden_med"+i));
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));

		cdo.addColValue("wh_hosp",whHosp);

		if(!fg.trim().equals("BM"))cdo.addColValue("compania_ref",companiaRef);
		else cdo.addColValue("compania_ref", (String) session.getAttribute("_companyId"));
		cdo.addColValue("fg",fg);

			System.out.println(" farSoloAprob === "+request.getParameter("farSoloAprob"));

		if (request.getParameter("codigoAlmacen"+i) != null && !request.getParameter("codigoAlmacen"+i).trim().equals(""))cdo.addColValue("wh_far",request.getParameter("codigoAlmacen"+i));
		else cdo.addColValue("wh_far",whFar);


		cdo.addColValue("mode",mode);
		if(request.getParameter("fp")==null||request.getParameter("fp").trim().equals(""))cdo.addColValue("fp","");
		else cdo.addColValue("fp",request.getParameter("fp"));
		if(mode.equals("despachar")||mode.equals("aprobar")){

			if(request.getParameter("codigo_articulo"+i)!=null && !request.getParameter("codigo_articulo"+i).equals("")) cdo.addColValue("codigo_articulo", request.getParameter("codigo_articulo"+i));
			if(request.getParameter("codigo_ndc"+i)!=null && !request.getParameter("codigo_ndc"+i).equals("")) cdo.addColValue("codigo_ndc", request.getParameter("cod_ndc"+i));
			if(request.getParameter("codigo_referencia"+i)!=null && !request.getParameter("codigo_referencia"+i).equals("")) cdo.addColValue("codigo_referencia", request.getParameter("codigo_referencia"+i));
			if(request.getParameter("descripcion"+i)!=null && !request.getParameter("descripcion"+i).equals("")) cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
			cdo.addColValue("cantidad", request.getParameter("cantidad"+i));
			if(request.getParameter("precio_unitario"+i)!=null && !request.getParameter("precio_unitario"+i).equals("")) cdo.addColValue("precio_unitario", request.getParameter("precio_unitario"+i));
			if(request.getParameter("precio_subtotal"+i)!=null && !request.getParameter("precio_subtotal"+i).equals("")) cdo.addColValue("precio_subtotal", ""+(Double.parseDouble(request.getParameter("precio_unitario"+i)) * Double.parseDouble(request.getParameter("cantidad"+i))));
			}

		if(mode.equals("despachar")){
			if(request.getParameter("diagnostico"+i)!=null && !request.getParameter("diagnostico"+i).equals("")) cdo.addColValue("diagnostico", request.getParameter("diagnostico"+i));
			if(request.getParameter("cod_tratamiento"+i)!=null && !request.getParameter("cod_tratamiento"+i).equals("")) cdo.addColValue("cod_tratamiento", request.getParameter("cod_tratamiento"+i));
			if(request.getParameter("cod_cpt"+i)!=null && !request.getParameter("cod_cpt"+i).equals("")) cdo.addColValue("cod_cpt", request.getParameter("cod_cpt"+i));
			if(request.getParameter("prioridad"+i)!=null && !request.getParameter("prioridad"+i).equals("")) cdo.addColValue("prioridad", request.getParameter("prioridad"+i));
			if(request.getParameter("concentracion"+i)!=null && !request.getParameter("concentracion"+i).equals("")) cdo.addColValue("concentracion", request.getParameter("concentracion"+i));
			if(request.getParameter("frecuencia"+i)!=null && !request.getParameter("frecuencia"+i).equals("")) cdo.addColValue("frecuencia", request.getParameter("frecuencia"+i));
			if(request.getParameter("cod_medida"+i)!=null && !request.getParameter("cod_medida"+i).equals("")) cdo.addColValue("cod_medida", request.getParameter("cod_medida"+i));

			if(request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).trim().equals("")&& request.getParameter("cantidad"+i).trim().equals("0")){
			cdo.addColValue("estado", "D");cdo.addColValue("other1","0"); }
			else {cdo.addColValue("estado", "P");cdo.addColValue("other1","1");  }
			if(request.getParameter("observacion"+i)!=null && !request.getParameter("observacion"+i).equals("")) cdo.addColValue("observacion", request.getParameter("observacion"+i));
			if(request.getParameter("farSoloAprob")!= null&&request.getParameter("farSoloAprob").trim().equals("S")) {cdo.addColValue("other1","-1");
			if(request.getParameter("seguir_despachando"+i)!=null){cdo.addColValue("seguir_despachando","S");}
			}

		} else if(mode.equals("aprobar")){
			if(request.getParameter("observacion"+i)!=null && !request.getParameter("observacion"+i).equals("")) cdo.addColValue("observacion_ap", request.getParameter("observacion"+i));
			if(request.getParameter("seguir_despachando"+i)!=null){cdo.addColValue("seguir_despachando","S");}
			else cdo.addColValue("seguir_despachando","N");
			cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			if(request.getParameter("chk"+i)!=null){ cdo.addColValue("estado", "A");cdo.addColValue("gen_cargo", "S");idFar += ""+(((idFar.length()>0))?"~":"")+request.getParameter("id"+i);}
			else{ cdo.addColValue("estado", "P");cdo.addColValue("gen_cargo", "N");}

			if((request.getParameter("cantidad"+i)!=null && !request.getParameter("cantidad"+i).trim().equals("")&& request.getParameter("cantidad"+i).trim().equals("0"))||request.getParameter("rechazar"+i)!=null){
			cdo.addColValue("estado", "D");
			cdo.addColValue("other1", "0");cdo.addColValue("gen_cargo", "N");}
			else{ cdo.addColValue("other1", "1");}

			if (validaCja.equalsIgnoreCase("S") && caja != null && !caja.trim().equals("")) {
				if (caja.contains(",")) cdo.addColValue("other4",caja.substring(0,caja.indexOf(",")));//if multiple then select the first one
				else cdo.addColValue("other4",caja);
			} else cdo.addColValue("other4","0");
			if(request.getParameter("turno")!=null && !request.getParameter("turno").equals("")) cdo.addColValue("other5", request.getParameter("turno"));
			else cdo.addColValue("other5","0");


			if(fg.trim().equals("ME"))if(((String)session.getAttribute("_companyId")).trim().equals(companiaRef))cdo.addColValue("fg","FAR");
		} else if(mode.equals("rechazar")){
			cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			if(request.getParameter("chk"+i)!=null)cdo.addColValue("estado", "I");
			else cdo.addColValue("estado", "P");
		}else if(mode.equals("recibir")){
			cdo.addColValue("secuencia", request.getParameter("secuencia"+i));
			cdo.addColValue("cds_recibido_user", (String) session.getAttribute("_userName"));
			cdo.addColValue("cds_recibido_cantidad", request.getParameter("cantidad"+i));
			cdo.addColValue("cds_observacion", request.getParameter("observacion"+i));
			if(request.getParameter("chk"+i)!=null){
				cdo.addColValue("estado", "R");
				cdo.addColValue("cds_recibido", "S");
			} else {
				cdo.addColValue("estado", "A");
				cdo.addColValue("cds_recibido", "N");
			}
		}

		if(mode.equals("despachar")){if(request.getParameter("chk"+i)!=null)al.add(cdo);}
		else if(mode.equals("aprobar")){if(request.getParameter("chk"+i)!=null)al.add(cdo);}
		else al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"session company id = "+session.getAttribute("_companyId")+" FG="+fg+" mode="+mode+" fp="+fp);
	if(mode.equals("despachar")){
		OFarmMgr.add(al);
	} else if(mode.equals("aprobar")||mode.equals("rechazar")){
		OFarmMgr.aprobar(al);
	} else if(mode.equals("recibir")){
		OFarmMgr.recibir(al);
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%
	if (OFarmMgr.getErrCode().equals("1")){
	%>
	alert('<%=OFarmMgr.getErrMsg()%>');
	<%if(mode.equals("aprobar") && request.getParameter("fp")!=null && request.getParameter("fp").trim().equals("FACT")&&cdoP.getColValue("v_far_generar_pos").trim().equals("S")){%>
	if(window.opener.parent.document.form1.facturar) window.opener.parent.document.form1.facturar.value='S';
	if(window.opener.parent.document.form1.dgi_id) window.opener.parent.document.form1.dgi_id.value='<%=OFarmMgr.getPkColValue("dgi_id")%>';
	if(window.opener) window.opener.parent.doSubmit();
	<%}%>

		printOF();
	<%if(mode.equals("aprobar") && request.getParameter("fp")!=null && request.getParameter("fp").trim().equals("FACT")&&cdoP.getColValue("v_far_generar_pos").trim().equals("N")){%>	regMarbete(); <%}%>

	window.close();
<%} else throw new Exception(OFarmMgr.getErrException());%>
}

function printOF(){
	<%if(!printOF.trim().equals("")){%>
	 var win=window.open('../farmacia/print_medicamentos_despachados.jsp?noAdmision=<%=noAdmision%>&pacId=<%=pacId%>&noOrden=<%=orden%>&categoria_adm=<%=categoriaAdm%>&codigo=<%=codigo%>&print_of=1&codigo_orden_med=<%=codOrdenMed%>&id=&fg=<%=fg%>&mode=<%=mode%>&idFar=<%=idFar%>');
	 win.moveTo(0,0);
	 win.resizeTo(screen.availWidth,screen.availHeight);
	 return win;
	 <%}%>
}
function regMarbete(){
	<%if(request.getParameter("far_reg_marbete") != null && request.getParameter("far_reg_marbete").trim().equals("S") && mode.equals("aprobar")){// && (request.getParameter("fp")==null || (request.getParameter("fp")!=null && !request.getParameter("fp").trim().equals("FACT")))%>
	 var win=window.open('../pos/reg_marbete.jsp?fg=despachar&fp=FAR&admision=<%=noAdmision%>&pac_id=<%=pacId%>&doc_id=<%=other2%>');
	 win.moveTo(0,0);
	 win.resizeTo(screen.availWidth,screen.availHeight);
	 return win;
	 <%}%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>