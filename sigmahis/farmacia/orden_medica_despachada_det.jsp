<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.OrdenMedica"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="OMMgr" scope="page" class="issi.expediente.OrdenMedicaMgr" />

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

OMMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alCaja = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
String change = request.getParameter("change");
String key = "";
String sql = "", fgSolX = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String fecha = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String area = request.getParameter("area");
String cds = request.getParameter("cds");
String fieldsWhere = "";
String appendFilter ="";
String pacBarcode = request.getParameter("pacBarcode");
String paciente = request.getParameter("paciente");
String compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");
String compReplica = java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");
String compania=(String)session.getAttribute("_companyId");
String fp = request.getParameter("fp");
String estado = request.getParameter("estado");
String orden = request.getParameter("orden");
String timer = request.getParameter("timer");
String expVersion = "1";
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (estado == null) estado = "";
if (orden == null) orden = "D";
if (cds == null) cds = "";
if(compFar == null || compFar.trim().equals("")) compFar = "";

if (paciente == null) paciente = "";
if (pacBarcode == null) pacBarcode = "";

if (mode == null) mode = "add";
if (fechaHasta == null) fechaHasta = "";
if (fp == null) fp = "";
if (timer == null) timer = "S";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(fg.trim().equals("ME")||fg.trim().equals("BM"))//SOLICITUDES DE FARMACIA
{
		fieldsWhere ="  ((	a.cds_recibido = 'N' and a.estado_orden = 'A' and a.omitir_orden = 'N'";
		if (!fecha.trim().equals("")) { fieldsWhere +=" and trunc(a.fecha_inicio) >= to_date('"+fecha+"','dd/mm/yyyy')";}
		if(!fechaHasta.trim().equals("")){fieldsWhere += " and trunc(a.fecha_inicio) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}

		fieldsWhere += " ) or (	a.cds_omit_recibido = 'N' and a.estado_orden = 'S' and a.omitir_orden = 'N'";
		if (!fecha.trim().equals("")) { fieldsWhere += " and trunc(a.fecha_suspencion) >= to_date('"+fecha+"','dd/mm/yyyy')";}
		if(!fechaHasta.trim().equals("")){fieldsWhere += " and trunc(a.fecha_suspencion) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}
		fieldsWhere += " )  ) and a.tipo_orden in(2,13,14) ";


	appendFilter += "  /*and z.estado in ('A','E')*/ and a.omitir_orden = 'N' and a.tipo_orden in(2,13,14)";

	if (!fecha.trim().equals("")) {appendFilter += " and (( trunc(a.fecha_inicio) >= to_date('"+fecha+"','dd/mm/yyyy')";}
	if(!fechaHasta.trim().equals("")){appendFilter += " and trunc(a.fecha_inicio) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}

	if (!fecha.trim().equals("")) {  appendFilter += " ) or ( a.estado_orden = 'S' and trunc(a.fecha_suspencion) >= to_date('"+fecha+"','dd/mm/yyyy')";}
	if(!fechaHasta.trim().equals("")){appendFilter += " and trunc(a.fecha_suspencion) <= to_date('"+fechaHasta+"','dd/mm/yyyy')";}
	if (!fecha.trim().equals("") || (!fechaHasta.trim().equals("") && !fecha.trim().equals("")))appendFilter += " ))	";

}
	if (!pacBarcode.trim().equals("")) appendFilter += " and a.pac_id="+pacBarcode.substring(0,10)+" and a.secuencia="+pacBarcode.substring(10);
	if (!paciente.trim().equals("")) appendFilter += " and upper(b.nombre_paciente) like '%"+paciente.toUpperCase()+"%'";
	if(fg.trim().equals("BM")) appendFilter += " and a.id_articulo is not null  and f.estado in ('P','A')";
	//if(!fg.trim().equals("BM")&&!fp.trim().equals("COF")) appendFilter += " and z.compania <> "+compania;
	if(!fp.trim().equals("COF")&&!fg.trim().equals("BM")) appendFilter += " and f.estado in ('P')";
	else if(!fg.trim().equals("BM")) appendFilter += " and f.estado in ('A')";
	if (!cds.trim().equals("")) appendFilter += " and a.centro_servicio="+cds;

sql = "select  (select descripcion from tbl_cds_centro_servicio where codigo = x.centro_servicio) as cds_desc,x.* from (select nvl(p.pendiente,0) pendiente, a.cds_omit_recibido, (select descripcion from tbl_sal_via_admin where codigo=a.via) descVia, a.frecuencia, a.dosis, f.observacion, decode(a.tipo_tubo, 'G', 'GOTEO', 'N', 'BOLO') tipo_tubo, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss AM') fecha_inicio, decode(estado_orden, 'S', to_char(a.fecha_suspencion, 'dd/mm/yyyy hh12:mi:ss AM'),'F',to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss AM')) fecha_omitida, to_char(f.fecha_creacion,'dd/mm/yyyy hh12:mi:ss AM') fecha_despacho,   b.id_paciente as identificacion, b.primer_nombre||' '||b.segundo_nombre||' '||decode(b.apellido_de_casada,null,b.primer_apellido||' '||b.segundo_apellido,b.apellido_de_casada) as nombre_paciente, (to_number(to_char(sysdate,'YYYY')) - to_number(to_char(b.fecha_nacimiento, 'YYYY'))) as edad, a.secuencia dsp_admision,(select nombre_corto from tbl_sal_desc_estado_ord where estado=a.estado_orden) as dsp_estado, to_char(a.fecha_creacion,'hh12:mi:ss AM') hora_solicitud,nvl(a.cds_recibido,'N') cds_recibido ,a.secuencia as secuenciaCorte,a.tipo_orden, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaSolicitud, a.nombre, a.ejecutado, a.cod_tratamiento, a.codigo, a.orden_med noOrden,a.pac_id, a.estado_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida,(select cama from tbl_adm_atencion_cu where pac_id=a.pac_id and secuencia = a.secuencia) cama, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') as fecha_nacimiento, to_char(z.fecha_ingreso, 'dd/mm/yyyy') as fecha_ingreso, b.sexo, f.codigo_articulo, f.descripcion, f.cantidad, f.estado estado_desp, a.codigo_orden_med ,f.id,f.seguir_despachando,nvl(f.replicado,'N')replicado,get_admCorte(a.pac_id,z.adm_root) as admCorte,z.adm_root as admRoot ,a.fecha_creacion, z.categoria as categoria_adm, f.other1 despachado,a.dosis_desc,a.cantidad as cant, a.centro_servicio,a.stat,nvl(fn_far_orden_sal(a.pac_id,a.secuencia,'FAR'),0) as ordSalida from vw_adm_paciente b,tbl_sal_detalle_orden_med a,tbl_adm_admision z,(select count(*) pendiente,a.pac_id,a.secuencia from tbl_sal_detalle_orden_med a where "+fieldsWhere+" group by a.pac_id,a.secuencia) p, tbl_int_orden_farmacia f where z.pac_id=a.pac_id and z.secuencia=a.secuencia and a.pac_id = b.pac_id  and a.pac_id = p.pac_id(+) and a.secuencia = p.secuencia(+)  "+appendFilter+" and a.pac_id = f.pac_id and a.secuencia = f.admision and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.other1 = 1 and f.fg='"+fg+"'  ) x where exists (select null from tbl_adm_admision where pac_id=x.pac_id and secuencia =admCorte and  estado in ('A','E') ) order by 1, x.centro_servicio,x.fecha_creacion ";
if(orden.trim().equals("D"))sql +=" desc";
else  sql +=" asc ";
sql += ", x.pac_id, id";

al = SQLMgr.getDataList(sql);

CommonDataObject cdoInsumos = SQLMgr.getData("select get_sec_comp_param("+compania+",'CDS_FAR') cds, get_sec_comp_param("+compania+",'USA_SYS_FAR_EXTERNA') usa_sys_far_externa ,nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'SAL_ADD_CANTIDAD_OMMEDICAMENTO'),'N') as addCantidad,nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'INT_USA_CAJA_TURNO'),'N') as validaCja,nvl(get_sec_comp_param("+compania+",'FAR_ALERTA_INTERVAL'),'0.5') alerta_interval,nvl(get_sec_comp_param(-1,'FAR_OM_CDS_EXPANDED'),'Y') as cds_expanded,nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'INT_FAR_USA_TURNO'),'N') as validaTurno from dual");
if (cdoInsumos==null) cdoInsumos = new CommonDataObject();

String delay = cdoInsumos.getColValue("alerta_interval","0.5");
boolean cdsExpanded = (cdoInsumos.getColValue("cds_expanded")!= null && (cdoInsumos.getColValue("cds_expanded").equalsIgnoreCase("S") || cdoInsumos.getColValue("cds_expanded").equalsIgnoreCase("Y")));

StringBuffer sbSqlGroup = new StringBuffer();
	sbSqlGroup.append("select z.centro_servicio as cds, count(*) as n_recs from (");
	sbSqlGroup.append(sql);
	sbSqlGroup.append(") z group by z.centro_servicio");
	System.out.println("---------> Group SQL...");
	ArrayList alCds = SQLMgr.getDataList(sbSqlGroup.toString());
	Hashtable htCds = new Hashtable();
	for (int i = 0; i < alCds.size(); i++) {
		CommonDataObject gCdo = (CommonDataObject) alCds.get(i);
		try {
			htCds.put(gCdo.getColValue("cds"),gCdo.getColValue("n_recs"));
		} catch(Exception ex) {
			System.out.println("Error al registrar conteo de centros!");
		}
	}

	if(cdoInsumos.getColValue("validaCja").trim().equals("S")){
	StringBuffer sbSql =  new StringBuffer();

	sbSql.append("select trim(to_char(z.codigo,'009')) as optValueColumn, z.codigo||' - '||z.descripcion as optLabelColumn, trim(to_char(z.no_recibo + 1,'00000009')) as optTitleColumn from tbl_cja_cajas z where z.compania = ");
	sbSql.append(compania);
	if (UserDet.getUserProfile().contains("0")) sbSql.append(" and z.estado = 'A'");
	else {
		sbSql.append(" and z.codigo in (");
		sbSql.append((String) session.getAttribute("_codCaja"));//cajas matriculadas en el IP de la PC que el usuario está conectado
		sbSql.append(") and z.ip = '");
		sbSql.append(request.getRemoteAddr());//muestre solo las que tengan registrado el IP
		sbSql.append("' and z.estado = 'A'");
		sbSql.append(" and exists (select null from tbl_cja_cajas_x_cajero y where compania_caja = z.compania and cod_caja = z.codigo and exists (select null from tbl_cja_cajera where usuario = '");
		sbSql.append(session.getAttribute("_userName"));
		sbSql.append("' and estado = 'A' and cod_cajera = y.cod_cajero))");// and tipo in ('S','A')
	}
	sbSql.append(" order by z.descripcion");
	System.out.println("S Q L   CAJA =\n"+sbSql);
	alCaja = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	if (alCaja.size() == 0) throw new Exception("Este equipo no está definido como una Caja. Por favor consulte con su Administrador!");
	}


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
	//timer();
	<%if(timer.trim().equals("S")){%>timer(60,true,'timerMsgTop,timerMsgBottom','Refrescando en sss seg.','reloadPage()');<%}%>
	checkPendingOM();
}

function doSubmit(){
	var action = parent.document.form1.baction.value;
	var x = 0;
	var size = <%=al.size()%>;
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.submit();
}
function timer()
{
	var sec=180;
	setTimeout('reloadPage()',sec * 1000);
}
function reloadPage()
{
	window.location.reload(true);
}
function checkPendingOM()
{
	var nOrden =parseInt(document.form1.nOrden.value,10);
	if((nOrden)>0)
	{
		document.getElementById('ordMedMsg').style.display='';
        var delay = parseInt("<%=delay%>" * 60 * 1000,10);
		soundAlert({delay:delay});
	}
}

function isChecked(k)
{
		var tipoOrden = eval('document.form1.tipo_orden'+k).value;
		var codTratamiento = eval('document.form1.cod_tratamiento'+k).value;
		var fg ='<%=fg%>';

		if(tipoOrden == 4 && codTratamiento == 1 &&fg=='ME')
		{
				eval('document.form1.chkSolicitud'+k).checked = false;
				alert('Las órdenes de inhalotarapias solo pueden ser marcadas por INASA!!!');
		}
		else if(!eval('document.form1.chkSolicitud'+k).checked)
	  {
				eval('document.form1.chkSolicitud'+k).checked = true;
				alert('No es posible quitar la confirmación!!!');

		}
}


function setTurno(){ var turno=getDBData('<%=request.getContextPath()%>','a.cod_turno','tbl_cja_turnos_x_cajas a, tbl_cja_cajas b','a.compania = b.compania and a.cod_caja = b.codigo and a.compania = <%=compania%> and a.cod_caja in(<%=(String) session.getAttribute("_codCaja")%>)  and a.estatus = \'A\'<%=(UserDet.getUserProfile().contains("0"))?"":" and b.ip = \\\'"+request.getRemoteAddr()+"\\\'"%> <%=(cdoInsumos.getColValue("validaTurno").trim().equals("S"))?" and a.cod_turno in (select codigo from tbl_cja_turnos where cja_cajera_cod_cajera in (select cod_cajera from tbl_cja_cajera where usuario = \\\'"+(String) session.getAttribute("_userName")+"\\\'))":""%>');if(turno==undefined||turno==null||turno.trim()==''){document.form1.turno.value='';CBMSG.warning('Usted o la Caja seleccionada no tiene un turno definido!');return false;}else{document.form1.turno.value=turno;}return true;}



function edit(k,flag,fp){//pac_id, no_adm, noorden, flag,fp,id){
    var pac_id = eval('document.form1.pac_id'+k).value;
    var no_adm = eval('document.form1.secuenciaCorte'+k).value;
    var noorden = eval('document.form1.codigo_orden_med'+k).value;
    var id = eval('document.form1.id'+k).value;
    var replicado = eval('document.form1.replicado'+k).value;
    var categoria = eval('document.form1.categoria_adm'+k).value;
    var orden = eval('document.form1.orden'+k).value;
    var codigo = eval('document.form1.codigo'+k).value;
    var tipoOrden = eval('document.form1.tipo_orden'+k).value;
    var dsp ='S';
    var fecha = parent.document.form1.fecha.value;
	var validaCja ='<%=cdoInsumos.getColValue("validaCja","N")%>';
	var validaTurno ='<%=cdoInsumos.getColValue("validaTurno","N")%>';
    if(flag=='A') {

        var totIns = 1;
				<% if (!fg.equalsIgnoreCase("BM")) { %>totIns=getDBData('<%=request.getContextPath()%>','count(*)',"(select substr(fac.descripcion, instr(fac.descripcion,'-',1)+1) cod_ord from tbl_fac_detalle_transaccion d, tbl_fac_transaccion fac where d.ref_type = 'FARINSUMOS'  and d.compania = <%=compania%>  and d.fac_secuencia = "+no_adm+"  and d.compania = fac.compania and d.fac_codigo = fac.codigo and d.fac_secuencia = fac.admi_secuencia and d.fac_fecha_nacimiento = admi_fecha_nacimiento and d.fac_codigo_paciente = fac.admi_codigo_paciente and d.tipo_transaccion = fac.tipo_transaccion and d.pac_id = "+pac_id+" and fac.num_solicitud = "+id+") aa","substr(aa.cod_ord, 0, instr(aa.cod_ord,'-',1)-1) = "+noorden,'');<% } %>


		if(fp=='FACT' && (validaCja=='S'||validaTurno=='S'))
		{
			   var sizeCja = document.form1.sizeCja.value;
			  setTurno();
			 if(document.form1.turno.value!='')dsp='S';
			 else dsp='N';

		}
		var aLink = '../farmacia/exp_orden_medicamentos_list.jsp?mode=aprobar&pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&id='+id+'&replicado='+replicado+'&fecha='+fecha+'&fg=<%=fg%>&fp='+fp+'&categoria_adm='+categoria+'&codigo='+codigo+'&orden='+orden+'&tipo_orden='+tipoOrden+'&print_of=1&codigo_orden_med='+noorden+'&turno='+document.form1.turno.value+'&caja='+document.form1.caja.value+'&validaCja='+validaCja;
        
		if(dsp=='S'){
        if (totIns < 1){
             parent.CBMSG.confirm("No has agregado insumos. Quieres continuar despachando?",{
               "btnTxt":"Si,No","cb": function(r){
                 if (r == "Si") abrir_ventana2(aLink);
               }
          });
        } else abrir_ventana2(aLink);
	  }

    }
    else if(flag=='R') abrir_ventana2('../farmacia/exp_orden_medicamentos_list.jsp?mode=recibir&pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&id='+id+'&replicado='+replicado+'&fecha='+fecha+'&fg=<%=fg%>&fp=<%=fp%>&categoria_adm='+categoria+'&codigo_orden_med='+noorden);
    else if(flag=='I') abrir_ventana2('../farmacia/exp_orden_medicamentos_list.jsp?mode=rechazar&pacId='+pac_id+'&noAdmision='+no_adm+'&tipo=A&noOrden='+noorden+'&replicado='+replicado+'&id='+id+'&fecha='+fecha+'&fg=<%=fg%>&fp=<%=fp%>&categoria_adm='+categoria+'&codigo_orden_med='+noorden);
    else if(flag=='PR')imprimir(pac_id, no_adm, noorden,id);
    else if(flag=='PO')imprimirOrden(pac_id, no_adm, noorden);
}

function canProceed(k){
  var pacId = eval('document.form1.pac_id'+k).value;
  var noAdmision = eval('document.form1.secuenciaCorte'+k).value;
  var noOrden = eval('document.form1.codigo_orden_med'+k).value;
  var tipoOrden = eval('document.form1.tipo_orden'+k).value;
  var cnt =  getDBData('<%=request.getContextPath()%>','count(*)',"(select s.codigo, s.descripcion, upper(s.table_name) table_name, nvl(s.view_path||decode(instr(s.view_path,'?'),0,'?',null,'','&'),' ') as aud_det_path,( select case when count(*) > 0 then 'VALIDADA' else 'NO VALIDADA' end from tbl_far_check_logs where seccion = s.codigo and compania = <%=compania%> and tipo_orden = "+tipoOrden+" and no_orden = "+noOrden+" and pac_id = "+pacId+" and admision = "+noAdmision+") as estado, (select case when count(*) > 0 then 'REV' else 'NO_REV' end from tbl_sal_change_log where upper(sec_tabla) = upper(s.table_name) and re_validate = 'Y' and pac_id = "+pacId+" and admision = "+noAdmision+") re_validate from tbl_sal_expediente_secciones s where s.validar_farmacia = 'S') a","a.estado = 'NO VALIDADA' OR a.re_validate = 'REV'",'');

  if (cnt > 0) {
    alert("Quedan validaciones pendientes. Por favor complete todas antes de seguir!");
    return false;
  }
  return true;
}

function imprimir(pac_id, no_adm, noorden,id){
	abrir_ventana2('../farmacia/print_orden_med_despachada.jsp?pacId='+pac_id+'&noAdmision='+no_adm+'&codOrdenMed='+noorden+'&id='+id);
}

function imprimirOrden(pacId,adm,noOrden){abrir_ventana('../expediente/print_exp_seccion_5.jsp?fg=FAR&pacId='+pacId+'&noAdmision='+adm+'&noOrden='+noOrden+'&desc=O/M MEDICAMENTOS&exp=<%=expVersion%>');}

function checkValidate(k){
    var pacId = eval('document.form1.pac_id'+k).value;
	var noAdmision = eval('document.form1.secuenciaCorte'+k).value;
	var noOrden = eval('document.form1.codigo_orden_med'+k).value;
	var tipoOrden = eval('document.form1.tipo_orden'+k).value;
	var id = eval('document.form1.id'+k).value;
	parent.showPopWin('../farmacia/validar_farmacia_om.jsp?pacId='+pacId+'&noAdmision='+noAdmision+'&tipoOrden='+tipoOrden+'&noOrden='+noOrden,winWidth*.95,winHeight*.80,null,null,'');
}

function insumos(id, pacId, noAdmision, noOrden, codigoOrden){
    if(hasDBData('<%=request.getContextPath()%>','tbl_int_orden_farmacia','compania = <%=compania%> and admision='+noAdmision+' and pac_id='+pacId+' and tipo_orden = 2 and estado=\'P\' and codigo_orden_med = '+noOrden+' and id = '+id,'')){
        var cds = getDBData('<%=request.getContextPath()%>',"get_sec_comp_param(<%=compania%>,'CDS_FAR')",'dual',null,'');
        <%
          String wh = "", fliaMedFar = "";
          try {wh =java.util.ResourceBundle.getBundle("farmacia").getString("whFar");}catch(Exception e){ wh = "";}
          try {fliaMedFar =java.util.ResourceBundle.getBundle("farmacia").getString("fliaMedFar");}catch(Exception e){ fliaMedFar = "";}
        %>
        var tipoServ = getDBData('<%=request.getContextPath()%>',"tipo_servicio",'tbl_inv_familia_articulo','compania=<%=compania%> and cod_flia = <%=fliaMedFar%>','') || "";

        abrir_ventana('../facturacion/reg_cargo_dev_new.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&fg=PAC&fPage=int_farmacia&tipoTransaccion=C&cds='+cds+'&wh=<%=wh%>&no_orden='+noOrden+'&tipoServicio='+tipoServ+'&codigo_orden='+noOrden+'&id_int_far='+id);
    }else parent.CBMSG.warning('El paciente no tiene una orden despachada!');
}

function printOrdenList(pacId, noAdmision, noOrden, tipoOrden){
 var idOrd =noOrden;
 var farExterna ='<%=cdoInsumos.getColValue("usa_sys_far_externa")%>';

  if(farExterna=="Y"||farExterna=="S")idOrd='';
  abrir_ventana2("../expediente/print_list_ordenmedica.jsp?fg=FAR&pacId="+pacId+"&noAdmision="+noAdmision+"&idOrden="+idOrd+"&tipo_orden="+tipoOrden);
}

function showDespachado(pacId, noAdmision, noOrden, cat, codOrdenMed){
 abrir_ventana2("../farmacia/print_medicamentos_despachados.jsp?pacId="+pacId+"&fg=<%=fg%>&noAdmision="+noAdmision+"&noOrden="+noOrden+"&categoria_adm="+cat+"&codigo_orden_med="+codOrdenMed);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>

<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("regChecked","")%>
<%=fb.hidden("solicitado_por","")%>
<%=fb.hidden("area","")%>
<%=fb.hidden("fecha","")%>
<%=fb.hidden("timer",""+timer)%>
<%=fb.hidden("sizeCja",""+alCaja.size())%>
<%=fb.hidden("caja",""+(String) session.getAttribute("_codCaja"))%>
<%=fb.hidden("turno","")%>
<table width="100%" align="center">
	<tr>
		<td height="20">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="15%">&nbsp;</td>
				<td width="70%" align="center"><font size="3" id="ordMedMsg" style="display:none"><cellbytelabel id="1">Hay Ordenes pendientes</cellbytelabel>!</font><!--<embed id="ordMedSound" src="../media/chimes.wav" width="0" height="0" autostart="false" hidden="true" loop="true"></embed>--><script language="javascript">blinkId('ordMedMsg','red','white');</script></td>
				<td width="15%" align="right">&nbsp;</td>
			</tr>
			</table>
		</td>
	</tr>
			   <tr>
					<td>
						<table width="100%">
							<tr class="TextHeader" align="center">
								<td width="5%"><cellbytelabel id="2">No. Paciente</cellbytelabel></td>
								<td width="28%"><cellbytelabel id="3">Nombre</cellbytelabel></td>
								<td width="10%"><cellbytelabel id="4">C&eacute;d./Pasap</cellbytelabel>.</td>
								<td width="10%"><cellbytelabel id="5">Fecha Nac</cellbytelabel>.</td>
								<td width="5%"><cellbytelabel id="6">Edad</cellbytelabel></td>
								<td width="5%"><cellbytelabel id="7">Sexo</cellbytelabel></td>
								<td width="5%"><cellbytelabel id="8">No. Admi</cellbytelabel>.</td>
								<td width="8%"><cellbytelabel id="9">Fecha Ingreso</cellbytelabel></td>
								<td width="10%"><cellbytelabel id="10">Cama</cellbytelabel></td>
								<td width="3%">&nbsp;</td>
								<td width="3%"><cellbytelabel id="11">Sec. Orden</cellbytelabel></td>
								<td width="8%">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
<%
paciente = "";
String neIconDesc = "";
String gCds = "", gPac = "";
boolean oCds = false, oPac = false;
int nOrden =0;
for (int i=0; i<al.size(); i++)
{
	//key = al.get(i).toString();
	//AjusteDetails ad = (AjusteDetails) ajuArt.get(key);
	CommonDataObject cdod = (CommonDataObject) al.get(i);

	String color = "";

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%//=fb.hidden("cod_paciente"+i,cdod.getColValue("cod_paciente"))%>
<%=fb.hidden("id"+i,cdod.getColValue("id"))%>
<%=fb.hidden("pac_id"+i,cdod.getColValue("pac_id"))%>
<%=fb.hidden("secuenciaCorte"+i,cdod.getColValue("secuenciaCorte"))%>
<%=fb.hidden("codigo"+i,cdod.getColValue("codigo"))%>
<%=fb.hidden("orden"+i,cdod.getColValue("noOrden"))%>
<%=fb.hidden("tipo_orden"+i,cdod.getColValue("tipo_orden"))%>
<%=fb.hidden("estado_orden"+i,cdod.getColValue("estado_orden"))%>
<%=fb.hidden("cod_tratamiento"+i,cdod.getColValue("cod_tratamiento"))%>
<%=fb.hidden("codigo_orden_med"+i,cdod.getColValue("codigo_orden_med"))%>
<%=fb.hidden("replicado"+i,cdod.getColValue("replicado"))%>
<%=fb.hidden("admRoot"+i,cdod.getColValue("admRoot"))%>
<%=fb.hidden("admCorte"+i,cdod.getColValue("admCorte"))%>
<%=fb.hidden("categoria_adm"+i,cdod.getColValue("categoria_adm"))%>
<%=fb.hidden("despachado"+i,cdod.getColValue("despachado"))%>

<% if (!gCds.equals(cdod.getColValue("centro_servicio"))) { %>
<% if (oCds) { %>
<% if (oPac) { %>
				</table>
			</td>
		</tr>
<% oPac = false; } %>
		</table>
	</td>
</tr>
<% paciente = ""; oCds = false; } %>
<tr class="TextPanel01" onClick="javascript:showHide('CDS<%=i%>')" style="text-decoration:none; cursor:pointer">
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr>
			<td width="5%" align="center" class="Text14">[<font face="Courier New, Courier, mono"><label id="plusCDS<%=i%>" style="display:<%=cdsExpanded?"none":""%>">+</label><label id="minusCDS<%=i%>" style="display:<%=cdsExpanded?"":"none"%>">-</label></font>]</td>
			<td class="Text14"><%=cdod.getColValue("cds_desc")%> [ <label><%=htCds.get(cdod.getColValue("centro_servicio"))%></label> ]</td>
		</tr>
		</table>
	</td>
</tr>
<tr id="panelCDS<%=i%>" style="display:<%=cdsExpanded?"":"none"%>" class="TextPanel01">
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<% oCds = true; } %>

<%
	if(!paciente.equals(cdod.getColValue("nombre_paciente")+"-"+cdod.getColValue("codigo_orden_med"))){
	String neIcon = "../images/blank.gif";

	if (cdod.getColValue("pendiente").equals("0"))
	{
		neIcon = "../images/check.gif";
	}
	else
	{
		neIcon = "../images/flag_red.gif";
		nOrden ++;
	}
	%>
	<% if (oPac) { %>
				</table>
			</td>
		</tr>
<% oPac = false; } %>

<!-- grupo -->

<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPanel02">
			<td width="5%" align="center">&nbsp;<%=cdod.getColValue("pac_id")%></td>
			<td width="28%">&nbsp;<input type="button" onClick="javascript:printOrdenList(<%=cdod.getColValue("pac_id")%>, <%=cdod.getColValue("secuenciaCorte")%>, <%=cdod.getColValue("codigo_orden_med")%>, <%=cdod.getColValue("tipo_orden")%>)" class="CellbyteBtn" value="<%=cdod.getColValue("nombre_paciente")%>" title="Órdenes médicas por admisión">

            <%if(fg.equals("ME") && fp.equals("") && cdoInsumos.getColValue("usa_sys_far_externa")!=null && (cdoInsumos.getColValue("usa_sys_far_externa").equals("Y")||cdoInsumos.getColValue("usa_sys_far_externa").equals("S")) ){%>
                <a style="float:right" href="javascript:insumos(<%=cdod.getColValue("id")%>, <%=cdod.getColValue("pac_id")%>, <%=cdod.getColValue("secuenciaCorte")%>, <%=cdod.getColValue("codigo_orden_med")%>, <%=cdod.getColValue("noOrden")%>)"><font class="Link03"><cellbytelabel>insumos</cellbytelabel></font></a>
            <%}%>

            </td>
			<td width="10%" align="center"><%=cdod.getColValue("identificacion")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("fecha_nacimiento")%></td>
			<td width="5%" align="center"><%=cdod.getColValue("edad")%></td>
			<td width="5%" align="center"><%=cdod.getColValue("sexo")%></td>
			<td width="5%" align="center">&nbsp;<%=cdod.getColValue("dsp_admision")%></td>
			<td width="8%" align="center"><%=cdod.getColValue("fecha_ingreso")%></td>
			<td width="10%" align="center"><%=cdod.getColValue("cama")%>
            <%if(fg.trim().equals("ME") && !cdod.getColValue("estado_desp").equals("P")){%>
              <a href="javascript:showDespachado(<%=cdod.getColValue("pac_id")%>, <%=cdod.getColValue("secuenciaCorte")%>, <%=cdod.getColValue("noOrden")%>,<%=cdod.getColValue("categoria_adm")%>, <%=cdod.getColValue("codigo_orden_med")%>)" class="Link04Bold">Despachados</a>
            <%}%>
			 
			
				<%if (Integer.parseInt(cdod.getColValue("ordSalida")) > 0) { %>
					
					<a href="javascript:ordSalida(<%=cdod.getColValue("pac_id")%>,<%=cdod.getColValue("dsp_admision")%>,<%=cdod.getColValue("codigo_orden_med")%>)";class="hint hint--top"><img src="../images/exit-door.jpg" class="ImageBorder" alt="<%=cdod.getColValue("ordSalida")%>" height="20" width="20" border="0"></a>
					
					<%}%>	
					
            </td>
			<td width="3%" align="center"><img src="<%=neIcon%>" alt="<%=neIconDesc%>" height="20" width="20"></td>
			<td width="3%" align="center"><%=cdod.getColValue("codigo_orden_med")%></td>
	        <td width="8%" align="center"><%if(cdod.getColValue("estado_desp").equals("P")&&!fp.trim().equals("COF")){%>
			<authtype type='6'><a href="javascript:edit(<%=i%>,'A','')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><font class="Link03"><cellbytelabel id="12">DESPACHAR</cellbytelabel></font></a></authtype>
			<%if(!compReplica.trim().equals(compFar)&& !fg.trim().equals("BM")){%>
			<authtype type='52'></br><a href="javascript:edit(<%=i%>,'A','FACT')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><font class="Link05"><cellbytelabel id="12">DESPACHAR y  Facturar</cellbytelabel></font></a></authtype><%}%>

      <%} else if(cdod.getColValue("estado_desp").equals("A") && (fg.trim().equals("BM")||fp.trim().equals("COF"))){%>
			<authtype type='50'><a href="javascript:edit(<%=i%>,'R','')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><font class="Link03"><cellbytelabel id="13">Recibir</cellbytelabel></font></a></authtype>

      <authtype type='51'>
      <a href="javascript:edit(<%=i%>,'PR','')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><img src="../images/printer.gif" alt="<%=neIconDesc%>" height="20" width="20" border="0" title="Ordenes Aprobadas/despachadas"></a></authtype>
      <%}%> <a href="javascript:edit(<%=i%>,'PO','')"><img src="../images/printer.gif" alt="<%=neIconDesc%>" height="20" width="20" border="0" title="Orden medica"></a>

	  </td>
		</tr>
		</table>
	</td>
</tr>
<tr id="panel<%=i%>">
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextHeader01">
			<td width="5%"><cellbytelabel id="14">Estado</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="15">Hora Solicitud</cellbytelabel></td>
			<td width="45%" colspan="2"><cellbytelabel id="16">Descripci&oacute;n</cellbytelabel></td>
			<td width="12%"><cellbytelabel id="17">Fecha Inicio</cellbytelabel></td>
			<td width="12%"><cellbytelabel id="18">Fecha Sol.</cellbytelabel>
			<!--<a href="javascript:checkValidate(<%=i%>)" class="Link05">Validar</a>-->
			</td>
		</tr>
<% oPac = true; } %>
<tr class="<%=color%>">
			<td width="5%"><%=cdod.getColValue("dsp_estado")%></td>
			<td width="10%"><%=cdod.getColValue("hora_solicitud")%></td>
			<td width="45%" colspan="2"><%=cdod.getColValue("nombre")%>&nbsp;
      <font class="RedText">&gt;&gt;<cellbytelabel id="19">Cant. Desp.:</cellbytelabel>=<%=cdod.getColValue("cantidad")%>&nbsp;-&nbsp;<%=cdod.getColValue("codigo_articulo")%>&nbsp;<%=cdod.getColValue("descripcion")%>&lt;&lt;</font><%if(cdod.getColValue("stat")!=null && cdod.getColValue("stat").equalsIgnoreCase("Y")){%>&nbsp;&nbsp;&nbsp;<span class="RedTextBold">STAT</span><%}%>
      </td>
			<td width="12%"><%=cdod.getColValue("fecha_inicio")%></td>
			<td width="12%"><%=cdod.getColValue("fecha_despacho")%></td>
  </tr>
		<%if(fg.trim().equals("ME")){%>
		<tr class="<%=color%>">
			<td colspan="4"><cellbytelabel id="20">Presentaci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("descVia")%>&nbsp;&nbsp;&nbsp;<cellbytelabel id="21">Concentraci&oacute;n</cellbytelabel>:&nbsp;<%=cdod.getColValue("dosis")%>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel id="22">Frecuencia</cellbytelabel>:&nbsp;<%=cdod.getColValue("frecuencia")%>
			<%if(expVersion.equals("3")){%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dosis:<%=cdod.getColValue("dosis_desc")%><%}%>
			<%if(cdoInsumos.getColValue("addCantidad").trim().equals("S")){%><font class="RedTextBold" size="2">Cantidad Solicitada:<%=cdod.getColValue("cant")%> </font>&nbsp;&nbsp;&nbsp;<%}%>
			</td>
			<td colspan="2"><cellbytelabel id="23">Observaci&oacute;n</cellbytelabel>:<%=cdod.getColValue("observacion")%> <%if(cdod.getColValue("replicado").trim().equals("S")){%><font class="RedTextBold" size="2">&nbsp;&nbsp;Despach:: SI</font>&nbsp;&nbsp;&nbsp;<%}%></td>

		</tr>
		<%}%>
<%
	paciente = cdod.getColValue("nombre_paciente")+"-"+cdod.getColValue("codigo_orden_med");
	gPac = cdod.getColValue("pac_id")+"-"+cdod.getColValue("codigo_orden_med");
	gCds = cdod.getColValue("centro_servicio");
	if(!paciente.equals(cdod.getColValue("nombre_paciente")+"-"+cdod.getColValue("codigo_orden_med")) && i>0){
%>

<%}
}//for loop
%>
<% if (al.size() > 0) { %>
				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
<% } %>
<%=fb.hidden("nOrden",""+nOrden)%>
<%=fb.hidden("size",""+al.size())%>
</table>
	</td>
</tr>
<tr class="TextRow02">
	<td class="TableTopBorder"><%=al.size()%>&nbsp;<cellbytelabel id="24">Solicitud(es)</cellbytelabel></td>
</tr>
</table>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{

	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		DetalleOrdenMed dom = new DetalleOrdenMed();

		if(request.getParameter("chkSolicitud"+i) != null && !request.getParameter("chkSolicitud"+i).trim().equals(""))
		{
			if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&& request.getParameter("estado_orden"+i).trim().equals("A"))
		{
					dom.setCdsRecibido(request.getParameter("chkSolicitud"+i));
					dom.setCdsRecibidoUser((String) session.getAttribute("_userName"));
		}
		else if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&& request.getParameter("estado_orden"+i).trim().equals("S"))
		{
			dom.setCdsOmitRecibido(request.getParameter("chkSolicitud"+i));
			dom.setCdsOmitRecibidoUser((String) session.getAttribute("_userName"));
		}
		//dom.setCdsRecibido(request.getParameter("chkSolicitud"+i));
		}else	dom.setCdsRecibido("N");
		dom.setEstadoOrden("C");//Para confirmar que se recibio la solicitud de las ordenes.
		dom.setPacId(request.getParameter("pac_id"+i));
		dom.setSecuencia(request.getParameter("secuenciaCorte"+i));
		dom.setTipoOrden(request.getParameter("tipo_orden"+i));
		dom.setOrdenMed(request.getParameter("orden"+i));
		dom.setCodigo(request.getParameter("codigo"+i));


		//dom.setEjecutado(request.getParameter("execute"+i));



		/*if(request.getParameter("estado_orden"+i) != null && !request.getParameter("estado_orden"+i).trim().equals("")&&(request.getParameter("estado_orden"+i).trim().equals("S") || request.getParameter("estado_orden"+i).trim().equals("F")))
		{

		}*/


		//dom.setOmitirOrden(request.getParameter("cancel"+i));
		//dom.setUsuarioModificacion((String) session.getAttribute("_userName"));
		//dom.setOmitirUsuario((String) session.getAttribute("_userName"));

		//dom.setObserSuspencion(request.getParameter("observacion"+i));
		//dom.setEstadoOrden(request.getParameter("suspender"+i));
		//dom.setFechaFin(request.getParameter("fechaFin"+i));
		//dom.setCodSalida(request.getParameter("cod_salida"+i));
		//dom.setFechaSuspencion(request.getParameter("fechaSuspencion"+i));

		al.add(dom);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	OMMgr.saveDetails(al);
	ConMgr.clearAppCtx(null);



	//om.setCompania((String) session.getAttribute("_companyId"));
	//om.setUsuarioCreacion((String) session.getAttribute("_userName"));


%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if (OMMgr.getErrCode().equals("1")){%>
	parent.document.form1.errCode.value = '<%=OMMgr.getErrCode()%>';
	parent.document.form1.errMsg.value = '<%=OMMgr.getErrMsg()%>';
	parent.document.form1.submit();
<%} else throw new Exception(OMMgr.getErrException());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>