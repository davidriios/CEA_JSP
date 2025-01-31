<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>

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

int iconSize = 18;
StringBuffer sbSql = new StringBuffer();
String cds = request.getParameter("cds");
String hab = request.getParameter("hab");
String fecha = request.getParameter("fecha");
String fg = request.getParameter("fg");
String cTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String citasAmb = request.getParameter("citasAmb");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String tipoCita = request.getParameter("tipoCita");
String nombreMedico = request.getParameter("nombreMedico");
String codMedico = request.getParameter("medico"); 
String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String dCedula = request.getParameter("d_cedula");
String pasaporte = request.getParameter("pasaporte");
String tipoPaciente = request.getParameter("tipo_paciente");
String fechaNacimiento = request.getParameter("fechaNacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");
String sexo = request.getParameter("sexo");
String fp = request.getParameter("fp");

if (cds == null) cds = "";
if (hab == null) hab = "";
if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if (fg == null) fg = "";
if (fp == null) fp = "";

boolean allowBackdate = false;
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'CDC_CITA_BACKDATE'),'N') as backdate from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p.getColValue("backdate").equalsIgnoreCase("Y") || p.getColValue("backdate").equalsIgnoreCase("S")) allowBackdate = true;

CommonDataObject cdoP = SQLMgr.getData("select  cita_interval, to_number(to_char(cita_open_at,'hh24mi')) cita_open_at, to_number(to_char(cita_close_at,'hh24mi')) cita_close_at, to_char(cita_open_at,'hh24:mi') as s_open_at from tbl_cds_centro_servicio where codigo = "+(cds.equals("")?"-100":cds));

if (cdoP==null) cdoP = new CommonDataObject();

int tiempoCupo = cdoP.getColValue("CITA_INTERVAL")==null||cdoP.getColValue("CITA_INTERVAL").equals("")?30:Integer.parseInt(cdoP.getColValue("CITA_INTERVAL")); // in minute
int openAt = cdoP.getColValue("CITA_OPEN_AT")==null||cdoP.getColValue("CITA_OPEN_AT").equals("")?700:Integer.parseInt(cdoP.getColValue("CITA_OPEN_AT"));
int closeAt = (cdoP.getColValue("CITA_CLOSE_AT")==null||cdoP.getColValue("CITA_CLOSE_AT").equals(""))?1400:Integer.parseInt(cdoP.getColValue("CITA_CLOSE_AT"));
String sOpenAt = cdoP.getColValue("s_open_at")==null?"07:00":cdoP.getColValue("s_open_at");

int hourFraction = 2;

int sTime = (7 * hourFraction);//min=0 and max<eTime => 12:00 am
int eTime = (22 * hourFraction);//min>sTime and max=24 => 12:00 am next day
ArrayList al = new ArrayList();
sbSql = new StringBuffer();
if (hab.trim().equals("")) sbSql.append("select to_char(a.hora,'hh12:mi am') as hora, 0 as codigo, to_char(sysdate,'dd/mm/yyyy') as fecha_registro, ' ' as nombre_paciente, ' ' as telefono, ' ' as observacion from ");
else sbSql.append("select to_char(a.hora,'hh12:mi am') as hora, b.hora_cita,nvl(b.codigo,0) as codigo, to_char(nvl(b.fecha_registro,sysdate),'dd/mm/yyyy') as fecha_registro, nvl(b.nombre_paciente,' ') as nombre_paciente, nvl(b.telefono,' ') as telefono, nvl(b.observacion,' ') as observacion, decode(c.cod_solicitud, null, 'N', 'S') sol_creada,b.xtra1,b.estado_cita ,hora_est, min_est, ( SELECT tooltips_paciente(nvl(b.codigo, 0), TO_CHAR(NVL(b.fecha_registro,sysdate), 'dd/mm/yyyy'))  FROM dual ) AS info from");

sbSql.append("( select aaa.hora from( select (to_date('");
sbSql.append(fecha);
sbSql.append(" ");
sbSql.append(sOpenAt);
sbSql.append("' , 'dd/mm/yyyy hh24:mi') )+(rownum-1)*(");
sbSql.append(tiempoCupo);
sbSql.append("/24/60) as hora from dual connect by level <= ceil(24 * (60/");
sbSql.append(tiempoCupo);
sbSql.append(")) ) aaa where to_number(to_char(aaa.hora,'hh24mi')) between "); 
sbSql.append(openAt); 
sbSql.append(" and ");
sbSql.append(closeAt+tiempoCupo); 
sbSql.append(" order by 1 )a");

if (!hab.trim().equals(""))
{
	sbSql.append(", (select to_char(z.hora_cita,'hh:mi am') as hora_cita, z.fecha_cita, z.codigo, z.fecha_registro, z.estado_cita, z.motivo_cita, z.observacion, z.nombre_paciente, z.telefono, z.hora_cita as hora_inicial, z.hora_cita + (((nvl(z.hora_est,0) * 60) + nvl(z.min_est,0)) / (24 * 60)) as hora_final,z.xtra1,nvl(z.hora_est,0) as hora_est, nvl(z.min_est,0) as min_est from tbl_cdc_cita z where");
	if(!fg.trim().equals("CS"))sbSql.append(" z.estado_cita not in ('C','T')");
	else sbSql.append(" z.estado_cita not null ");
	sbSql.append(" and trunc(z.fecha_cita)=to_date('");
	sbSql.append(fecha);
	sbSql.append("','dd/mm/yyyy') and z.habitacion='");
	sbSql.append(hab);
	sbSql.append("') b, (select distinct cod_solicitud, cod_cita, fecha_cita from tbl_cds_detalle_solicitud) c");
	sbSql.append(" where a.hora>=b.hora_inicial(+) and a.hora<b.hora_final(+) and trunc(b.fecha_registro) = trunc(c.fecha_cita(+)) and b.codigo = c.cod_cita(+)");
}
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<style type="text/css">.pointer{cursor:pointer;}</style>
<script type="text/javascript">
function submitDate(fecha){if(fecha.trim()!=''&&isValidateDate(fecha,'dd/mm/yyyy')){document.searchLeft.fecha.value=fecha;getLocaleDate(fecha,'_searchLeftFecha');var rightFecha=addDays(fecha,1);parent.window.frames.iRight.document.searchRight.fecha.value=rightFecha;parent.window.frames.iRight.getLocaleDate(rightFecha,'_searchRightFecha');parent.document.search00.fecha.value=fecha;if(document.searchLeft.cds.value.trim()!=''&&document.searchLeft.hab.value.trim()!=''){if(searchLeftValidation()){document.searchLeft.submit();parent.window.frames.iRight.document.searchRight.submit();}}}}
function submitDay(days){var fecha=addDays(document.searchLeft.fecha.value,days);submitDate(fecha);}
function submitMonth(months){var fecha=addMonths(document.searchLeft.fecha.value,months);submitDate(fecha);}
function cita(k, sol_creada){if(eval('document.result.codigo'+k).value==0){if(window.addCita<% if (!allowBackdate) { %> && canBeCreated(k)<% } %>)addCita(k);} else {if(sol_creada=='S') viewCita(k);else if(window.editCita) editCita(k);}}
function moveCita(k){var codigo=eval('document.result.codigo'+k).value;var fechaRegistro=eval('document.result.fecha_registro'+k).value;abrir_ventana('../cita/edit_cita.jsp?fp=imagenologia&fg=trasladar&mode=edit&codCita='+codigo+'&fechaCita='+fechaRegistro);}
function cancelCita(k){var codigo=eval('document.result.codigo'+k).value;var fechaRegistro=eval('document.result.fecha_registro'+k).value;var nombrePaciente=eval('document.result.nombre_paciente'+k).value;if(confirm('�Est� seguro que desea Cancelar la cita de '+nombrePaciente+'?')){showPopWin('../common/run_process.jsp?fp=CITAS&actType=7&docType=CITAS&docId='+codigo+'&docNo='+codigo+'&fecha='+fechaRegistro+'&nombrePac='+nombrePaciente+'&compania=<%=session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.35,null,null,''); }else alert('Proceso Cancelado!!');}
function doAction(){getLocaleDate('<%=fecha%>','_searchLeftFecha');getQtyCitasAsoc();}
function setAdm(k){var codigo=eval('document.result.codigo'+k).value;var fechaRegistro=eval('document.result.fecha_registro'+k).value;abrir_ventana('../cita/edit_cita.jsp?fp=imagenologia&fg=crear_solicitud&mode=edit&codCita='+codigo+'&fechaCita='+fechaRegistro);}

function canBeCreated(i){
  var hour = $("#hora"+i).val();
  var _date = $("#fecha").val();
  var cTime = "<%=cTime%>";
  var _flag = false;
  if ( hasDBData('<%=request.getContextPath()%>',"(select case when to_date('"+_date+" "+hour+"','dd/mm/yyyy hh12:mi am') >= sysdate then '1'  else null end b from dual)",'b is not null','') ){
	_flag = true;
  }else {_flag=false;alert("Ya no se puede reservar para esa hora!");}
  return _flag;
}
function asociar(i, codigo, fecha, type){
   var btnId = $("#asociar"+i);
   var _type = (type)? "desligar" : "asociar"; 
   var estadoCita = (type)? "R" : "E";
   var pacId = "<%=pacId%>";
   var noAdmision = "<%=noAdmision%>";
   var fechaNacimiento = "<%=fechaNacimiento%>"; 
   var codMedico = "<%=codMedico%>";
   var nombreMedico = "<%=nombreMedico%>";
   var provincia = "<%=provincia%>";
   var sigla = "<%=sigla%>";
   var tomo = "<%=tomo%>";
   var asiento = "<%=asiento%>";
   var dCedula = "<%=dCedula%>";
   var pasaporte = "<%=pasaporte%>";
   var tipoPaciente = "<%=tipoPaciente%>";
   var codigoPaciente = "<%=codigoPaciente%>"; 
   var xtraMsg = " la cita #"+codigo+" con <%=sexo.equals("F")?"la":"el"%> paciente (<%=pacId%>-<%=noAdmision%>)";
   
   if (type){
      pacId = "null";
      noAdmision = "null";
      fechaNacimiento = ""; 
      codMedico = " ";
      nombreMedico = " ";
      provincia = "null";
      sigla = " ";
      tomo = "null";
      asiento = "null";
      dCedula = " ";
      pasaporte = " ";
      codigoPaciente = "null";
   }
   
   if (!btnId.hasClass("asociada")){
   
       parent.parent.CBMSG.confirm("Est�s seguro que quieres "+_type+xtraMsg+" ?", {
         cb: function(r){
           if (r=="Si") {
             btnId.addClass("asociada");
             
             if (validDateTime(i, type)){
           
                 if(executeDB('<%=request.getContextPath()%>',"update tbl_cdc_cita set pac_id = "+pacId+", admision = "+noAdmision+", fec_nacimiento=to_date('"+fechaNacimiento+"','dd/mm/yyyy'),nombre_paciente=(select nombre_paciente from vw_adm_paciente where pac_id="+pacId+"),cod_medico='"+codMedico+"', nombre_medico='"+nombreMedico+"', provincia="+provincia+", sigla='"+sigla+"', tomo="+tomo+",asiento="+asiento+",d_cedula='"+dCedula+"',pasaporte='"+pasaporte+"', tipo_paciente='"+tipoPaciente+"' ,cod_paciente = "+codigoPaciente+",usuario_modif='<%=(String) session.getAttribute("_userName")%>', fecha_modif=sysdate, estado_cita='"+estadoCita+"', xtra1='"+_type.toUpperCase()+"' where codigo = "+codigo+" and trunc(fecha_registro) = to_date('"+fecha+"','dd/mm/yyyy') ",null)) 
                   window.location.reload(true);
                 else 
                   parent.parent.CBMSG.error("No se ha podido "+_type+xtraMsg+" !");
               }
           }
         },
         btnTxt: "Si,No"
       });
       
   }
}
function validDateTime(i, type){
   
   if (type == "Y") return true;

   var cds = $("#cds").val();
   var room = $("#hab").val();
   var xDate = $("#fecha").val();
   var xTime = $("#hora_cita"+i).val();
   var hour= $("#hora_est"+i).val();
   var min= $("#min_est"+i).val();
   var codigo= $("#codigo"+i).val();
   var fechaRegistro= $("#fecha_registro"+i).val();
   var filter='';
   
   <%if (!citasAmb.equals("S")){%> 
   if(getDBData('<%=request.getContextPath()%>','case when to_date(\''+xDate+'\',\'dd/mm/yyyy\')<trunc(sysdate) then 1 else 0 end','dual','','')==1){
     parent.parent.CBMSG.error('La fecha de la cita es menor al d�a de hoy!');return false;
   }
   <%}%>

   if(cds!=null&&cds!='')
     filter='centro_servicio='+cds;
   if(filter!='') filter+=' and ';
   
   filter+='habitacion=\''+room+'\' and estado_cita not in (\'C\',\'T\') and ((hora_cita<=to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_final>to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')) or (hora_cita<to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')+(((coalesce('+hour+',hora_est,0) * 60) + coalesce('+min+',min_est,0)) / (24 * 60)) and hora_final>to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')+(((coalesce('+hour+',hora_est,0) * 60) + coalesce('+min+',min_est,0)) / (24 * 60))))';
   
   filter+=' and codigo!='+codigo+' and trunc(fecha_registro)!=to_date(\''+fechaRegistro+'\',\'dd/mm/yyyy\')';
   
   if(hasDBData('<%=request.getContextPath()%>','tbl_cdc_cita',filter,'')){parent.parent.CBMSG.error('La Programaci�n de la Cita choca con otras Citas Programadas.\nPor favor revise la programaci�n!');return false;}return true;}
   
function getQtyCitasAsoc(){
  <%if(!pacId.equals("") && !noAdmision.equals("")){%>
  var qty =  getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_cita',"pac_id = <%=pacId%> and admision = <%=noAdmision%> and estado_cita not in ('C','T')",'');
  parent.parent.document.getElementById("amb_qty_citas_asociadas").innerHTML = qty;
  <%}%>
}
</script>
<authtype type='3'><script language="javascript">function addCita(k){var codigo=eval('document.result.codigo'+k).value;var horaCita=eval('document.result.hora'+k).value;if(document.searchLeft.cds.value=='')alert('Por favor seleccionar el Centro de Servicio!');else if(document.searchLeft.hab.value=='')alert('Por favor seleccionar la Area de Cita!');else{var cds=document.searchLeft.cds.value;var hab=document.searchLeft.hab.value;var habCds=getSelectedOptionTitle(parent.document.search00.hab);if(habCds!=undefined&&habCds!=null&&habCds.trim()!=''){
var url =  '../cita/reg_cita.jsp?fp=imagenologia&mode=add&cds='+cds+'&habitacion='+hab+'&fechaCita=<%=fecha%>&habCds='+habCds+'&horaCita='+horaCita;
          if ("<%=citasAmb%>" == "S") url = url + "&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&citasAmb=<%=citasAmb%>&nombreMedico=<%=nombreMedico%>&medico=<%=codMedico%>&forma_reserva=P&provincia=<%=provincia%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&d_cedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipo_paciente=<%=tipoPaciente%>&f_nac=<%=fechaNacimiento%>&fechaNacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>";
          abrir_ventana(url);
}
}}</script></authtype>
<authtype type='4'><script language="javascript">function editCita(k){var codigo=eval('document.result.codigo'+k).value;var fechaRegistro=eval('document.result.fecha_registro'+k).value;abrir_ventana('../cita/edit_cita.jsp?fp=imagenologia&mode=edit&codCita='+codigo+'&fechaCita='+fechaRegistro);}</script></authtype>
<script language="javascript">function viewCita(k){var codigo=eval('document.result.codigo'+k).value;var fechaRegistro=eval('document.result.fecha_registro'+k).value;abrir_ventana('../cita/edit_cita.jsp?fp=imagenologia&mode=view&codCita='+codigo+'&fechaCita='+fechaRegistro);}</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="1" cellspacing="1" border="0">
<%fb = new FormBean("searchLeft",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("hab",hab)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("nombreMedico",nombreMedico)%>
<%=fb.hidden("medico",codMedico)%> 
<%=fb.hidden("provincia",provincia)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("d_cedula",dCedula)%>
<%=fb.hidden("pasaporte",pasaporte)%>
<%=fb.hidden("tipo_paciente",tipoPaciente)%>
<%=fb.hidden("fechaNacimiento",fechaNacimiento)%>
<%=fb.hidden("codigo_paciente",codigoPaciente)%>
<%=fb.hidden("sexo",sexo)%>
<%=fb.hidden("citasAmb",citasAmb)%>


<tr align="center" class="TextHeader">
	<td colspan="4">
		<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr class="TextHeader">
			<td width="25%" align="right">
				<%=fb.button("subMonth","<<",true,false,"Text10",null,"onClick=\"javascript:submitMonth(-1)\"")%>
				<%=fb.button("subDay","<",true,false,"Text10",null,"onClick=\"javascript:submitDay(-1)\"")%>
			</td>
			<td width="50%" align="center">
				<%//=fb.textBox("fecha",fecha,false,false,true,10,"Text10",null,null)%>
				<%=fb.hidden("fecha",fecha)%>
				<label id="_searchLeftFecha"></label>
			</td>
			<td width="25%">
				<%=fb.button("addDay",">",true,false,"Text10",null,"onClick=\"javascript:submitDay(1)\"")%>
				<%=fb.button("addMonth",">>",true,false,"Text10",null,"onClick=\"javascript:submitMonth(1)\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>
<%fb = new FormBean("result",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<tr align="center" class="TextHeader">
	<td width="12%"><cellbytelabel>Hora</cellbytelabel></td>
	<td width="50%"><cellbytelabel>Paciente</cellbytelabel></td>
	<td width="25%"><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
	<td width="13%"><cellbytelabel>Acciones</cellbytelabel></td>
</tr>
<%
String codigo = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("fecha_registro"+i,cdo.getColValue("fecha_registro"))%>
<%=fb.hidden("hora"+i,cdo.getColValue("hora"))%>
<%=fb.hidden("nombre_paciente"+i,cdo.getColValue("nombre_paciente"))%>
<%=fb.hidden("hora_est"+i,cdo.getColValue("hora_est"))%>
<%=fb.hidden("min_est"+i,cdo.getColValue("min_est"))%>
<%=fb.hidden("hora_cita"+i,cdo.getColValue("hora_cita"))%>
<%=fb.hidden("Info"+i,cdo.getColValue("Info"))%>

<style>
.tooltip {
  position: relative;
  display: inline-block;
  border-bottom: 1px none black;
  cursor:pointer;
  
}

.tooltip .tooltiptext {
  visibility: hidden;
  opacity: 0;
  transition: opacity .5s;
  width: 280px;
  background: rgb(175,175,175);
  background: linear-gradient(77deg, rgba(175,175,175,1) 0%, rgba(123,125,130,1) 0%);
  color: #fff;
  text-align: left;
  padding: 0px 7px;
  border-radius: 6px;
  position: absolute;
  z-index: 1;
  font-size:10px;
  white-space: pre-line;
}

.tooltip:hover .tooltiptext {
  visibility: visible;
  opacity: 1;
}
.tooltip .tooltiptext::after {
  position: absolute;
  top: 50%;
  left: 100%; 
}

</style>

 
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" height="<%=iconSize+6%>">
	<td class="TableBottomBorderLightGray GreenText pointer" valign="top" align="center" onDblClick="javascript:cita(<%=i%>, '<%=cdo.getColValue("sol_creada")%>')"><%=cdo.getColValue("hora")%></td>
	<td class="tooltip" class="TableBottomBorderLightGray pointer" onDblClick="javascript:cita(<%=i%>, '<%=cdo.getColValue("sol_creada")%>')"><%=(!cdo.getColValue("codigo").equals("0") && cdo.getColValue("nombre_paciente") != null && !cdo.getColValue("nombre_paciente").trim().equals(""))?cdo.getColValue("nombre_paciente"):"&nbsp;"%><span class = "tooltiptext" class="TableBottomBorderLightGray pointer"><%=cdo.getColValue("info")%></span></td>
	<td class="TableBottomBorderLightGray"><%=(!cdo.getColValue("codigo").equals("0") && cdo.getColValue("telefono") != null && !cdo.getColValue("telefono").trim().equals(""))?cdo.getColValue("telefono"):"&nbsp;"%></td>
	<td class="TableBottomBorderLightGray" valign="top" align="center">&nbsp;
<%if(!fg.trim().equals("CS")){
if(!cdo.getColValue("codigo").equals("0") && !codigo.equals(cdo.getColValue("codigo")) && cdo.getColValue("sol_creada").equals("N"))
{
%>
		<authtype type='52'><img src="../images/actualizar.gif" width="<%=iconSize%>" height="<%=iconSize%>" onClick="javascript:moveCita(<%=i%>);"style="cursor:pointer" alt="Trasladar" title="Trasladar"></authtype>
		<authtype type='53'><img src="../images/cancel.gif" width="<%=iconSize%>" height="<%=iconSize%>" onClick="javascript:cancelCita(<%=i%>);"style="cursor:pointer" alt="Cancelar" title="Cancelar"></authtype>
		<authtype type='54'><img src="../images/lock.gif" width="<%=iconSize%>" height="<%=iconSize%>" onClick="javascript:setAdm(<%=i%>);"style="cursor:pointer" alt="Crear Solicitud" title="Crear Solicitud"></authtype>
		<%if(citasAmb.equalsIgnoreCase("S")){%>
        <%if(cdo.getColValue("estado_cita") != null && cdo.getColValue("estado_cita").equals("R")){%>
        <authtype type='56'><a href="javascript:asociar('<%=i%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha_registro")%>');" class="BottonTrasl" title="Asociar" id="asociar<%="_"+i%>"><cellbytelabel>+Adm</cellbytelabel></a></authtype>
        <%}else if (cdo.getColValue("xtra1") != null && cdo.getColValue("xtra1").equalsIgnoreCase("ASOCIAR") && cdo.getColValue("estado_cita").equals("E")){%>
          <authtype type='57'><a href="javascript:asociar('<%=i%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha_registro")%>', 'Y');" class="BottonTrasl" title="Desligar" id="asociar<%="_"+i%>"><cellbytelabel>-Adm</cellbytelabel></a></authtype>
        <%}%>
        <%}%>
		<%
}}
else
{
%>
		&nbsp;
<%
}
%>
	</td>
</tr>
<%
	codigo = cdo.getColValue("codigo");
}
%>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}
%>