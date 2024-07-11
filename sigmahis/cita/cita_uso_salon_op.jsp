<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Cita"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CitasMgr" scope="page" class="issi.admision.CitaMgr" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CitasMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
Cita cita = new Cita();

String curDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = (String)session.getAttribute("_userName");
String curCompanyId = (String)session.getAttribute("_companyId");

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String cds = request.getParameter("cds")==null?"":request.getParameter("cds");
String cdsTo = request.getParameter("cdsTo");
String habitacion = request.getParameter("habitacion");
String habCds = request.getParameter("habCds");
String codigo = request.getParameter("codigo");
String fechaCita = request.getParameter("fechaCita")==null?curDate.substring(0,10):request.getParameter("fechaCita");
String codCita = request.getParameter("codCita")==null?"":request.getParameter("codCita");
String horaCita = request.getParameter("horaCita");
String change = request.getParameter("change");
String nombrePaciente = request.getParameter("nombrePaciente")==null?"":request.getParameter("nombrePaciente");
String pacId = request.getParameter("pacId")==null?"0":request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision")==null?"0":request.getParameter("noAdmision");
String tipoCita = request.getParameter("tipoCita")==null?"0":request.getParameter("tipoCita");
String fromLector = request.getParameter("fromLector")==null?"":request.getParameter("fromLector");
String logId = request.getParameter("logId")==null?"":request.getParameter("logId");
String pacBrazalete = request.getParameter("pacBrazalete")==null?"":request.getParameter("pacBrazalete");
String action = request.getParameter("action")==null?"":request.getParameter("action");
String qx =  request.getParameter("qx");
String fecha = request.getParameter("fecha")==null?curDate.substring(0,10):request.getParameter("fecha");

StringBuffer sb = new StringBuffer();

boolean viewMode = false;

if (qx == null) qx = "";
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (fp == null) fp = "";
if (habCds == null) habCds = "";
if (codigo == null) codigo = "0";
if (horaCita == null) horaCita = "";
if (cdsTo == null) cdsTo = "";
String appendFilter = "";

if (!pacId.trim().equals("") && !pacId.trim().equals("0")){
	appendFilter += " and c.pac_id = "+pacId;
}
if (!noAdmision.trim().equals("") && !noAdmision.trim().equals("0")){
	appendFilter += " and c.admision = "+noAdmision;
}
if (!codCita.trim().equals("")){
	appendFilter += " and c.codigo = "+codCita;
}

CommonDataObject hCdo = new CommonDataObject();
CommonDataObject cdoLogL = new CommonDataObject();
CommonDataObject cdoLogR = new CommonDataObject();

hCdo = SQLMgr.getData(" select get_sec_comp_param("+curCompanyId+",'CDC_CDS_IN') as cdsSOP, get_sec_comp_param("+curCompanyId+",'CDC_CDS_OUT') as cdsREC, get_sec_comp_param("+curCompanyId+",'CDC_CDS_AN') as cdsAN from dual");

sb.append("select get_sec_comp_param(");
sb.append(curCompanyId);
sb.append(",'CDC_CDS_IN') as cds_in,(select min(l.log_id) from tbl_cdc_io_log l where l.fecha_registro = c.fecha_registro and l.cod_cita = c.codigo and l.pac_id =c.pac_id and l.log_id_ref is null) as log_id, coalesce(sh.etiqueta,sh.descripcion) as quirofano, c.habitacion as nCol, c.habitacion as chkQ, sh.compania compania, sh.codigo habitacion, c.nombre_paciente, c.codigo, c.cod_tipo, to_char(c.fecha_registro,'dd/mm/yyyy') as fecha_registro,to_char(c.fecha_cita,'dd/mm/yyyy') as fechaCita, to_char(c.hora_cita,'HH12:MI AM') as hora_inicio, c.hora_est as tiempo_hora, c.min_est as tiempo_min, nvl(c.observacion,'NO DEFINIDO') as observacion, substr(c.persona_reserva,0,15)||'.' persona_reserva, to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'HH12:MI AM') as hora_final, to_date(to_char(c.fecha_cita,'DD-MM-YYYY'),'DD-MM-YYYY') as fecha_inicio, to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'DD-MM-YYYY'),'DD-MM-YYYY') as fecha_final, to_date(to_char(c.fecha_cita,'DD-MM-YYYY')||' '||to_char(c.hora_cita,'HH24:MI'),'DD-MM-YYYY HH24:MI') as fecha_hora_inicio,NVL (c.observacion, nvl((select (select SUBSTR (nvl(observacion, descripcion), 1, 20) from tbl_cds_procedimiento where codigo = z.procedimiento)  FROM tbl_cdc_cita_procedimiento z WHERE z.cod_cita = c.codigo  and z.fecha_cita = c.fecha_registro  AND codigo = (SELECT min(codigo) FROM tbl_cdc_cita_procedimiento  WHERE  cod_cita = c.codigo  AND fecha_cita = c.fecha_registro)), 'NO DEFINIDO'))desc_procedimiento,nvl((select (select 'Dr. '||substr(primer_nombre,1,1)||'. '||primer_apellido from tbl_adm_medico where codigo=z.medico) from tbl_cdc_personal_cita z where z.cod_cita=c.codigo and z.fecha_cita=c.fecha_registro and z.funcion in (select column_value  from table( select split((select get_sec_comp_param(c.compania,'COD_FUNC_CIRUJANO') from dual),',') from dual  ))  and rownum =1),' ') as nombre_medico,c.pac_id,c.admision,nvl(sh.centro_servicio,sh.unidad_admin) as cds ,to_char(c.fec_nacimiento,'dd/mm/yyyy')dob,c.cod_paciente codPac ");

sb.append(",an.log_id_an, an.fecha_in_an, an.fecha_out_an, an.cds_entra_an, an.cargado_an, an.diff_an, an.admision_an, sop.log_id_sop, sop.fecha_in_sop,  sop.fecha_out_sop, sop.cds_entra_sop, sop.cargado_sop,sop.diff_sop, sop.admision_sop ,rec.log_id_rec, rec.fecha_in_rec,  rec.fecha_out_rec, rec.cds_entra_rec, rec.cargado_rec, rec.diff_rec, rec.admision_rec ");

sb.append(" ,decode( (select count(*) from tbl_cdc_io_log io where IO.PAC_ID = C.PAC_ID and IO.ADMISION = C.ADMISION and IO.FECHA_CITA = C.FECHA_CITA  and io.estado = 'CAN'),0,'N','Y' ) as canceled ,sh.orden,case when sh.codigo in (( select column_value  from table( select split((select get_sec_comp_param(c.compania,'SOP_CICLO_COMPL') from dual),',') from dual  ))) then 'N' else 'S' end  as soloPreparacion,nvl(dif_an_sop,0) as dif_an_sop,nvl(dif_cdc_sop,0) as dif_cdc_sop, ");
if(!qx.trim().equals(""))
{
	sb.append(" case when '");
	sb.append(qx);
	sb.append("' <> sh.codigo and exists (	select null from tbl_sal_habitacion hh where compania =c.compania and quirofano = 2 and nvl(centro_servicio,unidad_admin) in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO')) and hh.codigo ='");
	sb.append(qx);
	sb.append("' ) then 'S' else 'N' end   ");
}
else sb.append(" 'N' ");

sb.append(" as actualizarCita ,(select count(*) from tbl_adm_admision_nota_admin  where pac_id= c.pac_id and admision =c.admision and tipo='S' ) as motivo,c.centro_servicio ");
sb.append(" from tbl_sal_habitacion sh, tbl_cdc_cita c ");

sb.append(" ,(select l.log_id as log_id_an , to_char(l.fecha_in,'dd/mm/yyyy hh12:mi:ss am') as fecha_in_an, to_char(l.fecha_out,'dd/mm/yyyy hh12:mi:ss am') as fecha_out_an, (select descripcion from tbl_cds_centro_Servicio where codigo = l.cds) as cds_entra_an, decode(l.cargado,'S','CARGADO','NO CARGADO') as cargado_an, l.cod_cita as cod_cita_an, l.pac_id as pac_id_an, l.admision as admision_an, l.fecha_registro as fecha_cita_an ,mod( trunc( (l.fecha_out- l.fecha_in ) * 24 ), 24) ||':'||mod( trunc( ( l.fecha_out- l.fecha_in) * 1440 ), 60 ) as diff_an, nvl(trunc( ( (select fecha_in from tbl_cdc_io_log  x where cds = get_sec_comp_param(l.compania,'CDC_CDS_IN') and x.cod_cita = l.cod_cita and x.pac_id =l.pac_id and x.admision =l.admision and x.fecha_registro =l.fecha_registro )- l.fecha_out) * 1440 ),0) dif_an_sop from tbl_cdc_io_log l where l.log_id_ref is null and l.cds = get_sec_comp_param(");
sb.append(curCompanyId);
sb.append(",'CDC_CDS_AN') ) an ");

sb.append(",(select l.log_id as log_id_sop , to_char(l.fecha_in,'dd/mm/yyyy hh12:mi:ss am') as fecha_in_sop, to_char(l.fecha_out,'dd/mm/yyyy hh12:mi:ss am') as fecha_out_sop, (select descripcion from tbl_cds_centro_Servicio where codigo = l.cds) as cds_entra_sop, decode(l.cargado,'S','CARGADO','NO CARGADO') as cargado_sop, l.cod_cita as cod_cita_sop, l.pac_id as pac_id_sop, l.admision as admision_sop, l.fecha_registro as fecha_cita_sop ,mod( trunc( (l.fecha_out- l.fecha_in ) * 24 ), 24) ||':'||mod( trunc( ( l.fecha_out- l.fecha_in) * 1440 ), 60 ) as diff_sop,nvl(trunc( ( (l.fecha_in)- (select hora_cita from tbl_cdc_cita  x where x.codigo = l.cod_cita and x.fecha_registro =l.fecha_registro )) * 1440 ),0) dif_cdc_sop from tbl_cdc_io_log l where l.log_id_ref is not null and l.cds = get_sec_comp_param(");
sb.append(curCompanyId);
sb.append(",'CDC_CDS_IN')) sop ");

sb.append(", (select l.log_id as log_id_rec, to_char(l.fecha_out,'dd/mm/yyyy hh12:mi:ss am') as fecha_out_rec, to_char(l.fecha_in,'dd/mm/yyyy hh12:mi:ss am') as fecha_in_rec, (select descripcion from tbl_cds_centro_Servicio where codigo = l.cds) as cds_entra_rec ,decode(l.cargado,'S','CARGADO','NO CARGADO') as cargado_rec, l.cod_cita as cod_cita_rec, l.pac_id as pac_id_rec, l.admision as admision_rec, l.fecha_registro as fecha_cita_rec, mod( trunc( (l.fecha_out- l.fecha_in ) * 24 ), 24) ||':'||mod( trunc( ( l.fecha_out- l.fecha_in) * 1440 ), 60 ) as diff_rec from tbl_cdc_io_log l where l.log_id_ref is not null and l.cds = get_sec_comp_param(");
sb.append(curCompanyId);
sb.append(",'CDC_CDS_OUT')) rec ");


sb.append(" where sh.compania=");
sb.append(curCompanyId);
sb.append(" and c.habitacion in (select codigo from tbl_sal_habitacion where unidad_admin in (select codigo from tbl_cds_centro_servicio where tipo_cita='SOP') ) ");
sb.append(" and sh.codigo=c.habitacion /*AND sh.quirofano = 2*/ and c.estado_cita not in ('C','T') and (to_date(to_char(c.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('");
sb.append(fecha);
sb.append("','dd/mm/yyyy') or to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('");
sb.append(fecha);
sb.append("','dd/mm/yyyy')) ");
sb.append(appendFilter);
sb.append("  and c.cod_tipo not in ( select column_value  from table( select split((select get_sec_comp_param(c.compania,'TP_CITA_PROC') from dual),',') from dual  )) and c.codigo = sop.cod_cita_sop(+) and c.pac_id = sop.pac_id_sop(+) and c.fecha_registro = sop.fecha_cita_sop(+) and c.codigo = rec.cod_cita_rec(+) and c.pac_id = rec.pac_id_rec(+) and c.fecha_registro = rec.fecha_cita_rec(+) and c.codigo = an.cod_cita_an(+)  and c.pac_id = an.pac_id_an(+)   and c.fecha_registro = an.fecha_cita_an(+)  order by sh.orden,3,20 ");

session.setAttribute(UserDet.getUserName()+"_qry",sb.toString());

ArrayList alC = SQLMgr.getDataList(sb.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
	XMLCreator xml = new XMLCreator(ConMgr);
	
	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"motivo_cambio_cita"+UserDet.getUserId()+".xml","select id as value_col, descripcion as label_col, id as key_col from tbl_cdc_motivo_cambio_cita where tipo ='C' and estado = 'A' and centro_servicio = 11");
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
var allowAll = true;
document.title = 'Citas - '+document.title;
function reloadPage(){window.location.reload(true);}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();timer(60,true,'','sss seg. para refrescar','reloadPage()',true,'_timer');checkNotas();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
function checkNotas()
{  

	var cont = 	parseInt("<%=alC.size()%>");
	
	for (i=0;i<parseInt(cont);i++)
	{
		if($("#motDemora"+i).val() =='S' &&  $("#motivo"+i).val()=="0" ) 
		{
			 notasAdmin(i);
			 break;
		}
	}
}
/**
* IN_AN:   Entra a PREPARACION (ANESTESIA)
* OUT_AN:  Sale de PREPARACION y Entra a SALON OPERACION 
* OUT_OR:  Sale del SALON DE OPERACION y Entra a RECOBROS
* OUT_REC: SALE DE RECOBROS
*/
function doSave(){ 
 var pb = $("#pacBrazalete").val();
 doProcess(pb);
}
function doSubmit(ind){
   var cds = "<%=cds.equals("")?"get_sec_comp_param("+curCompanyId+",'CDC_CDS_IN')":cds%>";
   var cdsAN = $("#cdsAN").val();
   var cdsSOP = $("#cdsSOP").val();
   var cdsREC = $("#cdsREC").val();
   var cdsFilter = " /*UP*/ and cds = "+cds;
   var cdsTo = "<%=cdsTo.equals("")?"-1":cdsTo%>";
   var codCita = $("#codCita"+ind).val();
   var oCitas = $("#soloPreparacion"+ind).val();
   var fechaCita = $("#fechaCita"+ind).val();
   var fecha = $("#fecha").val();
   var noAdmision = $("#noAdmision"+ind).val();
   var canceled = $("#canceled"+ind).val();
   var cFilter = "pac_id = <%=pacId%> and admision = <%=noAdmision%> and cod_cita = "+codCita+" and fecha_cita = to_date('"+fechaCita+"','dd/mm/yyyy') ";
   var hab = $("#habitacion"+ind).val();
   var qx = $("#qx").val();
   
   var sopFilter = " fecha_cita = to_date('"+fechaCita+"','dd/mm/yyyy') and quirofano='"+hab+"'";
   if (canceled=="Y"){CBMSG.error("La cita ["+codCita+"] ya fue cancelada!");}
   else if (noAdmision != ""){
   
       
	   
	   //Lazy Loading...
	   function inAN(){return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+' and fecha_in is not null /* IN AN*/ and cds = '+cdsAN,'');}
	   
	   function outAN(){return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+' and cds = '+cdsAN+' and fecha_in is not null and fecha_out is not null and log_id_ref is null /* OUT AN*/  and estado = \'OUT_AN\' ','');}
   
       function inOR(){return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+' and fecha_in is not null /* IN OR*/ and cds = '+cdsSOP,'');}
	   
	   
	   function outOR(){return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+' and fecha_in is not null and fecha_out is not null and log_id_ref is not null and /*BOTTOM*/  /* OUT SOP */  cds = '+cdsSOP,'');}
      
       function inRec(){return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+' and fecha_in is not null and  /*BOTTOM IN RECOBROS */ cds = '+cdsREC,'');}
	   
       function outRec(){return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+' and fecha_in is not null and fecha_out is not null and log_id_ref is not null and estado = \'OUT_REC\' and /*BOTTOM OUT REC */  cds = '+cdsREC,'');}
      
	  function checkUsoSop(){return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+sopFilter+' and fecha_in is not null and fecha_out is null and log_id_ref is not null and /*BOTTOM VERIFICA SOP */ cds = '+cdsSOP,'');}
	  
       $("#curLocation").val(window.location.href);
       $("#ind").val(ind);
	   if (inAN()==0){
		 $("#action").val("IN_AN");
		 debug("IN_AN");
		 $("#form0").submit();
	   }else if (outAN()==0){ 
		 $("#action").val("OUT_AN");
		 debug("OUT_AN");
		 if(oCitas!='' && oCitas=='S'){CBMSG.alert('Paciente de Otras Citas, no requiere control de entrada a salón');}
		 $("#form0").submit();
	   }
	   else if (inOR()==0){ 
		 $("#action").val("IN_OR");
		 debug("IN_OR");
		 if(oCitas!='' && oCitas=='S'){CBMSG.alert('Paciente de Otras Citas, no requiere control de entrada a salón');
		 //$("#form0").submit();
		 }else
		 {
		 	var actualizarCita =  $("#actualizarCita"+ind).val();
			//alert('actualizarCita=='+actualizarCita+' qx= <%=qx%>');
			if(actualizarCita=="S"){$("#action").val("UPD_QX");$("#form0").submit();}
			else{
			if(checkUsoSop()==0){$("#form0").submit();}
			else CBMSG.alert('El salon de operaciones mantiene citas sin finalizar.!!');}
		 }
	   }
	   else if (outOR()==0){if(oCitas!='' && oCitas=='S'){CBMSG.alert('Paciente de Otras Citas, no requiere control de entrada a salón',{cb:function(r){if(r=='Ok'){window.location.href = "../cita/cita_uso_salon_op.jsp?fecha="+fecha+"&fechaCita="+fecha+"&qx="+qx;}}});}
	   else{
		 $("#action").val("OUT_OR");
		 $("#actionCargo").val("GEN_CARGO_OR");
		 debug("OUT_OR");
		 $("#form0").submit();}
	   }
	   else if (inRec()==0){
	     $("#action").val("IN_REC");
		 debug("IN_REC");
		 $("#form0").submit();
	   }
	   else if (outRec()==0){
		 $("#action").val("OUT_REC");
		 $("#actionCargo").val("GEN_CARGO_REC");
		 debug("OUT_REC")
		 $("#form0").submit();
	   }
	   else{
		 if($("#action").val()==""){
		   CBMSG.alert("El proceso ha sido finalizado para el paciente ["+$("#pacName"+ind).val()+"]!",{cb:function(r){if(r=='Ok'){window.location.href = "../cita/cita_uso_salon_op.jsp?fecha="+fecha+"&fechaCita="+fecha+"&qx="+qx;}}});
		 }
		}
	}else{CBMSG.error("La cita no tiene asignada una ADMISION por lo que no puede ejecutarse el proceso!!!");}
}

$(document).ready(function(){
    document.form0.qx.select();
    var tot = parseInt("<%=alC.size()%>");
	var pacId = "<%=pacId%>";
    var fromLector = "<%=fromLector%>";
    var action = "<%=action%>";
	if (action=="cancel") _doCancel(0);	
    else if (fromLector == "1" && pacId != "" && pacId != "0" && tot == 1){
	  doSubmit(0);
    }
	
	$("#pacBrazalete").click(function(){$(this).select();});
	
    document.getElementById( "form0").onsubmit = function() {
      return false;
    };

	$("#pacBrazalete").keyup(function(e){
		var pacBrazalete = pacId = noAdmision = "";
		var fecha = $("#fecha").val();
		var key;
		(window.event) ? key = window.event.keyCode : key = e.which;
		
		if(key == 13){
			pacBrazalete = $(this).val();
			if (pacBrazalete != ""){
			  try{
			   doProcess(pacBrazalete);  
			  }catch(e){debug("Error caused by: "+e.message)}
			}
		}
	});
    
    $("#qx").keydown(function(e){
        if (e.keyCode == 13) {
            $("#pacBrazalete").focus();
        }
    });
    
});

function getPB(){
  var pb = $("#pacBrazalete").val(), _pb = "";
  if (pb.indexOf("-") > 0){
	try{
	  _pb = pb.split("-");
	  _pb = _pb[0].lpad(10,"0")+""+_pb[1].lpad(3,"0");
	}catch(e){debug("ERROR getPB CAUSED BY: "+e.message);_pb="";}
  }else if (pb.trim().length == 13) _pb = pb;
  return _pb;
}

function doProcess(pb){
   var fecha = $("#fecha").val();
   var qx = $("#qx").val();
   var pacId = noAdmision = "";
   var _pb = getPB(pb);
   if (_pb != ""){
	$("#pacBrazalete").val(_pb);
	var selInd = $("#selInd"+parseInt(_pb.substr(0,10),10)).val();
	if(!$("#noAdmision"+selInd).val()){CBMSG.error("La cita no tiene asignada una ADMISION por lo que no puede ejecutarse el proceso!");}
	else{
		pacId = parseInt(_pb.substr(0,10),10);
		noAdmision = parseInt(_pb.substr(10),10);
		window.location.href = "../cita/cita_uso_salon_op.jsp?fromLector=1&pacId="+pacId+"&noAdmision="+noAdmision+"&fecha="+fecha+"&fechaCita="+fecha+"&pacBrazalete="+_pb+"&qx="+qx;
	}
   }else{CBMSG.error("Por favor escanee un brazalete o ingrese el ID del paciente en este formato: pacId-Adm");}
}

function printCargos (pacId,noAdmision)
{
abrir_ventana('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
}
function setFrameService(){
var d = $("#fecha").val();
var qx = $("#qx").val();
window.location.href = "../cita/cita_uso_salon_op.jsp?fecha="+d+"&fechaCita="+d+"&qx="+qx;}


function doCancel(){
  var _pb = $("#pacBrazalete").val();
  var qx = $("#qx").val();
  var pb = getPB(pb);
  var fecha = $("#fecha").val();
  if(pb!=""){
    pacId = parseInt(pb.substr(0,10),10);
	noAdmision = parseInt(pb.substr(10),10);
	window.location.href = "../cita/cita_uso_salon_op.jsp?action=cancel&pacId="+pacId+"&noAdmision="+noAdmision+"&fecha="+fecha+"&fechaCita="+fecha+"&pacBrazalete="+pb+"&qx="+qx; 
  }else {
    CBMSG.alert('Por favor escanee un brazalete o ingrese el ID del paciente en este formato: pacId-Adm');
  }
}
function _doCancel(ind){
  var totC = parseInt("<%=alC.size()%>",10);
  var codCita = $("#codCita"+ind).val();
  var fechaCita = $("#fechaCita"+ind).val();
  var cFilter = "";
  var pb = $("#pacBrazalete").val();
  var canceled = $("#canceled"+ind).val();
  
  var _inputs = [ 
     {header: "Observación 1", type: "textarea", name: "observacion", ml:200}, 
     {header: "Motivo", type: "select", name: "motivo", xml: "../xml/motivo_cambio_cita18.xml" } 
  ];
  
  $("#ind").val(ind);
  
   if(getPB(pb)!=""){

    cFilter = "lpad(pac_id,10,'0')||lpad(admision,3,'0') = '"+getPB()+"' and cod_cita = "+codCita+" and fecha_cita = to_date('"+fechaCita+"','dd/mm/yyyy') ";
	
	if (canceled=="Y"){CBMSG.error("La cita ["+codCita+"] ya fue cancelada!");}
	else if(!$("#noAdmision"+ind).val()){CBMSG.error("La cita no tiene asignada una ADMISION por lo que no puede ejecutarse el proceso!!");}
	else if (totC != 1) CBMSG.alert('Por favor escanee un brazalete o ingrea el ID del paciente en este formato: pacId-Adm o escoge una de las citas');
  
	else if (getCan() >= 1){
	   CBMSG.error("Ya no se puede cancelar la cita!");
	}else {
	   CBMSG.confirm("¿Está usted seguro(a) de querer cancelar la cita?",
			{ btnTxt:'Si,No', 
			   cb:function(r){
				 if (r=='Si') {
				    $("#action").val("CAN");
				    $("#cancelType").val(getCan("t")>=1?"U":"I");
					document.getElementById( "form0").onsubmit = function() {return true;};
					
					CBMSG.prompt("",{ inputs:_inputs, cb:function(r,v){  $(v).each( function(i,o) { if(o.name=="observacion" && o.value.trim()!=""){ $("#observacion").val(o.value);  $("#form0").submit();}else{CBMSG.alert("Por favor indique una observación");}  debug(o.name+" - - - "+o.value);    } )     }  }  );
				 }
			   } 
	   });
	}
  }else {
    CBMSG.alert('Por favor escanee un brazalete o ingrea el ID del paciente en este formato: pacId-Adm');
  }
  
  function getCan(type){
     if(typeof type == "undefined")return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+' and estado in (\'OUT_OR\',\'OUT_REC\') ','');
	 else return getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_io_log',''+cFilter+'','');
  }
}
function notasAdmin(k)
{ 
   var codCita = $("#codCita"+k).val();
   var oCitas = $("#soloPreparacion"+k).val();
   var fechaCita = $("#fechaCita"+k).val();
   var noAdmision = $("#noAdmision"+k).val();
   var pacId = $("#pacId"+k).val();
   var dob = $("#dob"+k).val();
   var codPac = $("#codPac"+k).val();
showPopWin('../expediente/exp_obser_admin.jsp?noAdmision='+noAdmision+'&pacId='+pacId+'&dob='+dob+'&codPac='+codPac+'&codCita='+codCita+'&fechaCita='+fechaCita+'&fp=citas&tipo=S',winWidth*.95,winHeight*.75,null,null,'');
}
function corregirHora(fg,fechaIn,fechaOut,k)
{ 
   var codCita = $("#codCita"+k).val(); 
   var fechaReg = $("#fecha_registro"+k).val();
   var noAdmision = $("#noAdmision"+k).val();
   var pacId = $("#pacId"+k).val();  
   
showPopWin('../process/cdc_upd_fechas.jsp?noAdmision='+noAdmision+'&pacId='+pacId+'&codCita='+codCita+'&fechaReg='+fechaReg+'&fechaIn='+fechaIn+'&fechaOut='+fechaOut+'&fp=citas&tipo='+fg,winWidth*.95,winHeight*.75,null,null,'');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CITA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">		
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("ind","")%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("action","")%>
		<%=fb.hidden("actionCargo","")%>
		<%=fb.hidden("curLocation","")%>
     	<%=fb.hidden("cdsSOP",hCdo.getColValue("cdsSOP"))%>
     	<%=fb.hidden("cdsREC",hCdo.getColValue("cdsREC"))%>
     	<%=fb.hidden("cdsAN",hCdo.getColValue("cdsAN"))%>
		<%=fb.hidden("_timer","")%>
		<%=fb.hidden("cancelType","")%>
		<%=fb.hidden("observacion","")%>
	<tr>
		<td>
	<div id="_cMain" class="Container">
		<div id="_cContent" class="ContainerContent">
		   <table width="100%" cellpadding="1" cellspacing="1">
			   <tr class="TextRow01">
				<td width="16.67%">&nbsp;</td>
				<td width="16.67%">&nbsp;</td>
				<td width="16.67%">&nbsp;</td>
				<td width="16.67%">&nbsp;</td>
				<td width="16.67%">&nbsp;</td>
				<td width="16.67%">&nbsp;</td>
			   </tr>
			   <tr class="TextPanel" align="left">
				 <td colspan="6">
				
				  Por favor Escanee un Quirofano: <%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion,nvl(centro_servicio,unidad_admin) as cds from tbl_sal_habitacion h where compania ="+curCompanyId+" and quirofano = 2 and nvl(centro_servicio,unidad_admin) in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO'))    order by codigo","qx",qx,false,false,0,"Text10","","","","S")%>
				 
                 <%=fb.textBox("qx",qx,false,false,false,15,13,null,null,"",null,false,"")%>
				 
				 
				 Fecha
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha" />
				<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="onChange" value="javascript:setFrameService();" />
				<jsp:param name="jsEvent" value="javascript:setFrameService();" />
				</jsp:include>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				 Por favor Escanee un brazalete:&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.textBox("pacBrazalete",pacBrazalete,false,false,false,15,13,null,null,"",null,false,"tabindex=-1")%>
				 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				 <%=fb.button("btnRef","MANUAL",true,viewMode,"Text10", null,"onClick=doSave()" )%>
				 &nbsp;&nbsp;&nbsp;&nbsp;
				 <%=fb.button("btnCancel","CANCELAR",true,viewMode,"Text10", null,"onClick=doCancel()" )%>
				 </td>
			   </tr>

			    <% 
			   String grpQuirofano = "";
			   CommonDataObject cdoC = new CommonDataObject();
			   for (int c = 0; c<alC.size(); c++){
			     String color = "TextRow03";
				 if (c%2==0) color = "TextRow04";
				 cdoC = (CommonDataObject)alC.get(c);
				 String recPacDetShow = "style='display:none;'";
				 if (cdoC.getColValue("fecha_in_rec") != null && !cdoC.getColValue("fecha_in_rec").trim().equals("")) recPacDetShow = "";
			   %>
			   
			    <%=fb.hidden("cds"+c,cdoC.getColValue("cds_in"))%>
				<%=fb.hidden("cdsTo"+c,cdsTo)%>
				<%=fb.hidden("fechaCita"+c,cdoC.getColValue("fechaCita"))%>
				<%=fb.hidden("fecha_registro"+c,cdoC.getColValue("fecha_registro"))%>
				<%=fb.hidden("codCita"+c,cdoC.getColValue("codigo"))%>
				<%=fb.hidden("tipoCita"+c,cdoC.getColValue("cod_tipo"))%>
				<%=fb.hidden("pacId"+c,cdoC.getColValue("pac_id"))%>
				<%=fb.hidden("selInd"+cdoC.getColValue("pac_id"),""+c)%>
				<%=fb.hidden("pacName"+c,cdoC.getColValue("nombre_paciente"))%>
				<%=fb.hidden("noAdmision"+c,cdoC.getColValue("admision"))%>
				<%=fb.hidden("logIdRef"+c,cdoC.getColValue("log_id"))%>
				<%=fb.hidden("diffRec"+c,cdoC.getColValue("diff_rec"))%>
				<%=fb.hidden("diffSop"+c,cdoC.getColValue("diff_sop"))%>
				<%=fb.hidden("canceled"+c,cdoC.getColValue("canceled"))%>
				<%=fb.hidden("soloPreparacion"+c,cdoC.getColValue("soloPreparacion"))%>	
				<%=fb.hidden("habitacion"+c,cdoC.getColValue("habitacion"))%>
				<%=fb.hidden("dob"+c,cdoC.getColValue("dob"))%>
				<%=fb.hidden("codPac"+c,cdoC.getColValue("codPac"))%>				
				<%=fb.hidden("actualizarCita"+c,cdoC.getColValue("actualizarCita"))%>
				<%
				  if (!grpQuirofano.equals(cdoC.getColValue("quirofano"))){
				%>
				<tr align="left" class="TextHeader02">
					<td colspan="6"><%=cdoC.getColValue("quirofano")%></td>
				</tr>
				
				<!--<tr align="center" class="TextHeader03 Text10Bold">
					<td colspan="6">[<%=cdoC.getColValue("cds_entra_an").equals("")?"SALON DE PREPARACION":cdoC.getColValue("cds_entra_an")%>]&nbsp;
					Entra:&nbsp;<%=cdoC.getColValue("fecha_in_an")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					Sale:&nbsp;<%=cdoC.getColValue("fecha_out_an")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					Dif:&nbsp;<%=cdoC.getColValue("diff_an")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					</td>
				</tr>-->
				<tr class="TextHeader">
				    <td colspan="2"><%=cdoC.getColValue("cds_entra_an").equals("")?"SALON DE PREPARACION":cdoC.getColValue("cds_entra_an")%></td>
					<td colspan="2">SAL&Oacute;N DE OPERACI&Oacute;N</td>
				    <td colspan="2">RECOBROS</td>
			    </tr>
				<!--<tr class="TextHeader" align="center">
					<td colspan="2">PACIENTE</td>
				    <td colspan="2">AREA</td>
				    <td>ENTRADA</td>
					<td>SALIDA</td>
			    </tr>-->
				<%}%>
				<tr>
					<td colspan="2">Paciente:&nbsp;<%=cdoC.getColValue("nombre_paciente")%>
					<%=cdoC.getColValue("pac_id")%>-<%=cdoC.getColValue("admision")%>
					</td>
					<td colspan="3">M&eacute;dico:&nbsp;<%=cdoC.getColValue("nombre_medico")%></td>
					<td align="right">Cita No.:&nbsp;<%=cdoC.getColValue("codigo")%></td>				
				</tr>
				<tr>
					<td colspan="3">Hora Inicio:&nbsp;<%=cdoC.getColValue("hora_inicio")%></td>
					<td colspan="3">Hora Final:<%=cdoC.getColValue("hora_final")%><span style="float:right; color:red;font-weight:bold;"><%=cdoC.getColValue("canceled")!=null&&cdoC.getColValue("canceled").equals("Y")?"CANCELADA":""%></span> 
				</tr>
				
				<tr align="left" class="<%=color%>">
					<!--PREPARACION-->
					<td colspan="2">
					  <table width="100%" cellpadding="1" cellspacing="1">
						<tr>
							<td colspan="4">
								<table width="100%">
									<tr>
										<td width="10%">F.Entrada:</td>
										<td width="30%"><%=cdoC.getColValue("fecha_in_an")%></td>
										<td width="10%">F.Salida:</td>
										<td width="30%"><%=cdoC.getColValue("fecha_out_an")%></td>
										<td width="20%">Dif.:<%=cdoC.getColValue("diff_an")%>
										 <%if(cdoC.getColValue("fecha_out_an")!=null && !cdoC.getColValue("fecha_out_an").equals("")){%> <authtype type='50'><span title="Corregir Fecha" class="errorFecha" onClick="javascript:corregirHora('AN','<%=cdoC.getColValue("fecha_in_an")%>','<%=cdoC.getColValue("fecha_out_an")%>',<%=c%>)"></span></authtype>
										 <%}%>
										</td>
									</tr>
								</table>
							</td>
					  	</tr>
					  </table>
					</td>
					<td colspan="2">
					  <table width="100%" cellpadding="1" cellspacing="1">
						<tr>
							<td colspan="4">
								<table width="100%">
									<tr>
										<td width="10%">F.Entrada:</td>
										<td width="30%"><%=cdoC.getColValue("fecha_in_sop")%> 
										<%if(cdoC.getColValue("dif_cdc_sop")!=null && !cdoC.getColValue("dif_cdc_sop").trim().equals("0")&& Double.parseDouble(cdoC.getColValue("dif_cdc_sop")) > 30 ){%> 
										<span  title="Motivo de Atraso" class="obserAdmin" onClick="javascript:notasAdmin(<%=c%>)"></span>
										<%=fb.hidden("motDemora"+c,"S")%>
										<%=fb.hidden("motivo"+c,cdoC.getColValue("motivo"))%>
										 
										 <%}else{%>
										 
										 <%=fb.hidden("motDemora"+c,"N")%>
										 <%=fb.hidden("motivo"+c,"0")%>
										 <%}%>
										 
										 
										 </td>
										<td width="10%">F.Salida:</td>
										<td width="30%"><%=cdoC.getColValue("fecha_out_sop")%></td>
										<td width="20%">Dif.:<%=cdoC.getColValue("diff_sop")%><%if(cdoC.getColValue("cargado_sop")!=null && cdoC.getColValue("cargado_sop").equals("CARGADO")){%> <span title="Cobrado" class="cargado" onClick="javascript:printCargos(<%=cdoC.getColValue("pac_id")%>,<%=cdoC.getColValue("admision_sop")%>)"></span>
										 <%}%>
										 <%if(cdoC.getColValue("fecha_out_sop")!=null && !cdoC.getColValue("fecha_out_sop").equals("")){%> <authtype type='50'><span title="Corregir Registros" class="errorFecha" onClick="javascript:corregirHora('OR','<%=cdoC.getColValue("fecha_in_sop")%>','<%=cdoC.getColValue("fecha_out_sop")%>',<%=c%>)"></span></authtype>
										 <%}%>
										 
										 </td>
									</tr>
								</table>
							</td>
					  	</tr>
					  </table>
					</td>
					
					<!-- RECOBROS -->
					<td colspan="2">
					  <table width="100%" cellpadding="1" cellspacing="1">
						<tr>
							<td colspan="4">
								<table width="100%">
									<tr>
										<td width="10%"><span <%=recPacDetShow%>>F.Entrada:</span></td>
										<td width="30%"><span <%=recPacDetShow%>><%=cdoC.getColValue("fecha_in_rec")%></span></td>
										<td width="10%"><span <%=recPacDetShow%>>F.Salida:</span></td>
										<td width="30%"><span <%=recPacDetShow%>><%=cdoC.getColValue("fecha_out_rec")%></span></td>
										<td width="20%"><span <%=recPacDetShow%>>Dif.:<%=cdoC.getColValue("diff_rec")%></span>
										<%if(cdoC.getColValue("cargado_rec")!=null && cdoC.getColValue("cargado_rec").equals("CARGADO")){%> 
										<span title="Cobrado" class="cargado" onClick="javascript:printCargos(<%=cdoC.getColValue("pac_id")%>,<%=cdoC.getColValue("admision_sop")%>)"></span>
										<%}%>
										 <%if(cdoC.getColValue("fecha_out_rec")!=null && !cdoC.getColValue("fecha_out_rec").equals("")){%> <authtype type='50'><span title="Corregir Registros" class="errorFecha" onClick="javascript:corregirHora('REC','<%=cdoC.getColValue("fecha_in_rec")%>','<%=cdoC.getColValue("fecha_out_rec")%>',<%=c%>)"></span></authtype>
										 <%}%>
										</td>
									</tr>
								</table>
							</td>
							
					  	</tr>
					  </table>
					</td>
					
				</tr>
				
				
				<%
				grpQuirofano = cdoC.getColValue("quirofano");
				}
				%>
				
				<tr>
					<td colspan="6"><%//=sb.toString()%></td>
				</tr>
		   </table>
		   </div>
		  </div>
		</td>
	</tr>
<%=fb.formEnd(true)%>
</table>
	
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	String dbAction = "",fechaReg ="";
	boolean insAnestesia = false, updAnestesia = false, insQuirofano = false, updQuirofano = false, insRecobro = false, updRecobro = false, insCancel = false, updCancel = false;
	String ind = request.getParameter("ind")==null?"00":request.getParameter("ind");
	String cancelType = request.getParameter("cancelType")==null?"":request.getParameter("cancelType");
	
	pacId = request.getParameter("pacId"+ind);
	noAdmision = request.getParameter("noAdmision"+ind);
	codCita = request.getParameter("codCita"+ind);
	cds = request.getParameter("cds"+ind);
	cdsTo = request.getParameter("cdsTo");
	fechaCita = request.getParameter("fechaCita"+ind);
	fechaReg = request.getParameter("fecha_registro"+ind);
	fecha = request.getParameter("fecha");
	nombrePaciente = request.getParameter("nombrePaciente"+ind);
	tipoCita = request.getParameter("tipoCita"+ind);
		
	CommonDataObject cdo = new CommonDataObject();
	CommonDataObject cdoU = new CommonDataObject();
	
	if (request.getParameter("action").equals("IN_AN")){
	   insAnestesia = true;
	}else if (request.getParameter("action").equals("OUT_AN")){
	   updAnestesia = true; 
	}
	else if (request.getParameter("action").equals("IN_OR")){
	   if(request.getParameter("soloPreparacion"+ind)!= null && !request.getParameter("soloPreparacion"+ind).trim().equals("")&& !request.getParameter("soloPreparacion"+ind).trim().equals("S"))insQuirofano = true;
	   else insQuirofano = false;
	}
	else if (request.getParameter("action").equals("OUT_OR")){	 
	  updQuirofano = true; //insRecobro = true;
	}else if(request.getParameter("action").equals("IN_REC")){
	   insRecobro = true;
	}
	else if (request.getParameter("action").equals("OUT_REC")){

	  updRecobro = true; 
	  insRecobro = false;
	  insQuirofano = false;
	  updQuirofano = false;
	  insAnestesia = false;
	  updAnestesia = false;
	}
	else if (request.getParameter("action").equals("CAN")){
	  insCancel = cancelType.trim().equals("I");
	  updCancel = cancelType.trim().equals("U");
	  updRecobro = false; 
	  insRecobro = false;
	  insQuirofano = false;
	  updQuirofano = false;
	  insAnestesia = false;
	  updAnestesia = false;
	}
			
	if (insAnestesia || insQuirofano || insRecobro || insCancel){
		cdo.setTableName("tbl_cdc_io_log");
        cdo.addSeqColValue("LOG_ID","SEQ_CDC_IO_LOG_ID");
		cdo.addColValue("PAC_ID",request.getParameter("pacId"+ind));
		cdo.addColValue("ADMISION",request.getParameter("noAdmision"+ind));
		cdo.addColValue("COD_CITA",request.getParameter("codCita"+ind));
		cdo.addColValue("FECHA_CITA",request.getParameter("fechaCita"+ind));
		cdo.addColValue("FECHA_REGISTRO",request.getParameter("fecha_registro"+ind));
		cdo.addColValue("TIPO_CITA",request.getParameter("tipoCita"+ind));
		cdo.addColValue("quirofano",request.getParameter("habitacion"+ind));
		cdo.addColValue("COMPANIA",curCompanyId);
	
	    cdo.addColValue("FECHA_IN",curDate);
	    cdo.addColValue("FECHA_CREACION",curDate);
	    cdo.addColValue("USUARIO_CREACION",userName);
	    cdo.addColValue("USUARIO_MODIFICACION",userName);
	    cdo.addColValue("FECHA_MODIFICACION",curDate);
		
		if (insCancel) {
		  cdo.addColValue("OBSERVACION",request.getParameter("observacion"));
		  cdo.addColValue("ESTADO",request.getParameter("action"));
		  cdo.addColValue("CDS","-1");
		}
	}
		
	if (insAnestesia){
	  cdo.addColValue("CDS",request.getParameter("cdsAN"));
	  cdo.addColValue("ESTADO","IN_AN");
	}
	if (insQuirofano){
	  cdo.addColValue("CDS",request.getParameter("cdsSOP"));
	 if(request.getParameter("logIdRef"+ind)!=null && !request.getParameter("logIdRef"+ind).trim().equals(""))cdo.addColValue("LOG_ID_REF",request.getParameter("logIdRef"+ind));
	  else cdo.addColValue("LOG_ID_REF","(select max(l.log_id) from tbl_cdc_io_log l where l.fecha_registro = to_date('"+request.getParameter("fecha_registro"+ind)+"','dd/mm/yyyy') and l.cod_cita = "+request.getParameter("codCita"+ind)+" and l.pac_id ="+request.getParameter("pacId"+ind)+" and l.admision = "+request.getParameter("noAdmision"+ind)+" and  ESTADO ='OUT_AN' ) ");
	  cdo.addColValue("ESTADO","IN_OR");
	}
	if (insRecobro){
	  cdo.addColValue("CDS",request.getParameter("cdsREC"));
	  cdo.addColValue("LOG_ID_REF",request.getParameter("logIdRef"+ind));
	  if(request.getParameter("logIdRef"+ind)!=null && !request.getParameter("logIdRef"+ind).trim().equals(""))cdo.addColValue("LOG_ID_REF",request.getParameter("logIdRef"+ind));
	  else cdo.addColValue("LOG_ID_REF","(select max(l.log_id) from tbl_cdc_io_log l where l.fecha_registro = to_date('"+request.getParameter("fecha_registro"+ind)+"','dd/mm/yyyy') and l.cod_cita = "+request.getParameter("codCita"+ind)+" and l.pac_id ="+request.getParameter("pacId"+ind)+" and l.admision = "+request.getParameter("noAdmision"+ind)+" and  ESTADO ='OUT_OR' ) ");
	  cdo.addColValue("ESTADO","IN_REC");
	}
	
	if (updAnestesia || updQuirofano || updRecobro || updCancel){
	   cdoU.setTableName("tbl_cdc_io_log");
	   cdoU.addColValue("USUARIO_MODIFICACION",userName);
	   cdoU.addColValue("FECHA_MODIFICACION",curDate);
	   cdoU.addColValue("ESTADO",request.getParameter("action"));
	   
	   if (updCancel){
	      cdoU.addColValue("OBSERVACION",request.getParameter("observacion"));
		  cdoU.setWhereClause(" pac_id = "+request.getParameter("pacId"+ind)+" and admision = "+request.getParameter("noAdmision"+ind)+" and fecha_registro = to_date('"+request.getParameter("fecha_registro"+ind)+"','dd/mm/yyyy') and cod_cita = "+request.getParameter("codCita"+ind)+" and estado NOT IN('OUT_REC','OUT_OR') ");
	   }
	   else cdoU.addColValue("FECHA_OUT",curDate);
	}
	
	if (updAnestesia){
	  cdoU.addColValue("CARGADO","I");
	  cdoU.addColValue("ESTADO","OUT_AN");
	  cdoU.setWhereClause(" pac_id = "+request.getParameter("pacId"+ind)+" and admision = "+request.getParameter("noAdmision"+ind)+" and fecha_registro = to_date('"+request.getParameter("fecha_registro"+ind)+"','dd/mm/yyyy') and cod_cita = "+request.getParameter("codCita"+ind)+" and fecha_in is not null and fecha_out is null and log_id_ref is null and estado in('IN_AN','OUT_AN') and cds = "+request.getParameter("cdsAN"));
	}
	
	if (updQuirofano){
	  cdoU.addColValue("CARGADO","S");
	  cdoU.addColValue("ESTADO","OUT_OR");
	  cdoU.setWhereClause(" pac_id = "+request.getParameter("pacId"+ind)+" and admision = "+request.getParameter("noAdmision"+ind)+" and fecha_registro = to_date('"+request.getParameter("fecha_registro"+ind)+"','dd/mm/yyyy') and cod_cita = "+request.getParameter("codCita"+ind)+" and fecha_in is not null and fecha_out is null and log_id_ref is not null and estado in('IN_OR','OUT_OR') and cds = get_sec_comp_param("+curCompanyId+",'CDC_CDS_IN')");
	}
	if (updRecobro){
	  cdoU.addColValue("CARGADO","S");
	  cdoU.addColValue("ESTADO","OUT_REC");
	  cdoU.setWhereClause(" pac_id = "+request.getParameter("pacId"+ind)+" and admision = "+request.getParameter("noAdmision"+ind)+" and fecha_registro = to_date('"+request.getParameter("fecha_registro"+ind)+"','dd/mm/yyyy') and cod_cita = "+request.getParameter("codCita"+ind)+" and fecha_in is not null and fecha_out is null and log_id_ref is not null and estado in ('IN_REC','OUT_REC') and cds = get_sec_comp_param("+curCompanyId+",'CDC_CDS_OUT')");
	}
		
	if (insAnestesia || insQuirofano || insRecobro || insCancel){  
	   SQLMgr.insert(cdo);
	}
	if (updAnestesia || updQuirofano || updRecobro || updCancel){
	  SQLMgr.update(cdoU);
	}
	
	if (insCancel || updCancel){
	  // update tbl_cdc_cita set estado = 'C'
	}
	if (request.getParameter("action").equals("UPD_QX")){
			CommonDataObject param = new CommonDataObject();
			param.setSql("call sp_cdc_upd_citas(?,?,?,?,?,?)");
			param.addInStringStmtParam(1,codCita);
			param.addInStringStmtParam(2,fechaReg);
			param.addInStringStmtParam(3,curCompanyId);
			param.addInStringStmtParam(4,(String) session.getAttribute("_userName"));
			param.addInStringStmtParam(5,(request.getParameter("action").equals("UPD_QX"))?"UPD":"INS");
			param.addInStringStmtParam(6,qx);
			param = SQLMgr.executeCallable(param,false,true); 
			System.out.println(":::::::::::::::::::::::::::::::: ACTUALIZANDO       = "+request.getParameter("action")+" qx=="+qx);			
		}
	
	
	if( (updQuirofano || updRecobro) && SQLMgr.getErrCode().equals("1") ){
	    if (request.getParameter("actionCargo").equals("GEN_CARGO_OR")||request.getParameter("actionCargo").equals("GEN_CARGO_REC")){
			CommonDataObject param = new CommonDataObject();
			param.setSql("call sp_cdc_cerrar_sol_trx_new(?,?,?,?,?,?)");
			param.addInStringStmtParam(1,codCita);
			param.addInStringStmtParam(2,fechaReg);
			param.addInStringStmtParam(3,curCompanyId);
			param.addInStringStmtParam(4,(String) session.getAttribute("_userName"));
			param.addInStringStmtParam(5,(request.getParameter("actionCargo").equals("GEN_CARGO_REC"))?"REC":"SOP");
			param.addInStringStmtParam(6,cdoU.getColValue("estado"));
			param = SQLMgr.executeCallable(param,false,true); 
			System.out.println(":::::::::::::::::::::::::::::::: CARGANDO       = "+request.getParameter("actionCargo")+" ESTADO=="+cdoU.getColValue("estado"));			
		}
	}	
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	//alert('<%=SQLMgr.getErrMsg()%>');
	window.location = "../cita/cita_uso_salon_op.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&codCita=<%=codCita%>&cds=<%=cds%>&fecha=<%=fecha%>&fechaCita=<%=fechaCita%>&nombrePaciente=<%=nombrePaciente%>&tipoCita=<%=tipoCita%>&cdsTo=<%=cdsTo%>";
<%
} else throw new Exception(errMsg);
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