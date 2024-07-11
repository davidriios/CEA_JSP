<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr"	scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr"	scope="session" class="issi.admin.SecurityMgr"	/>
<jsp:useBean id="UserDet"	scope="session" class="issi.admin.UserDetail"	/>
<jsp:useBean id="CmnMgr"	scope="page"	class="issi.admin.CommonMgr"	/>
<jsp:useBean id="SQLMgr"	scope="page"	class="issi.admin.SQLMgr"		/>
<jsp:useBean id="fb"		scope="page"	class="issi.admin.FormBean"		/>
<%
/**
======================================================================================================================================================
FORMA							MENU																																										NOMBRE EN FORMA
CDC100100					CITAS\TRANSACCIONES\CRONOGRAMA DE QUIROFANOS																						SALON DE OPERACIONES PROGRAMA QUIRURGICO
Cuando se edita llama a la forma CDC100010
CDC100100_CONV5		INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - CONSULTA DE PRORAMAS QUIRURGICOS	SOP- CONSULTA DE PROGRAMA QUIRURGICO
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

String fechaCita = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String tipoCita = request.getParameter("tipoCita");
String citasSopAdm = request.getParameter("citasSopAdm");
String nombreMedico = request.getParameter("nombreMedico");
String codMedico = request.getParameter("medico"); 
String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String dCedula = request.getParameter("d_cedula");
String pasaporte = request.getParameter("pasaporte");
String tipoPaciente = request.getParameter("tipo_paciente");
String fechaNacimiento = request.getParameter("f_nac");
String codigoPaciente = request.getParameter("codigo_paciente");
String sexo = request.getParameter("sexo");

int contTrx = CmnMgr.getCount("select count(*) cont from tbl_cdc_solicitud_trx where trx_estado='P'");
int iconHeight = 40;
int iconWidth = 40;
if (fg == null) fg = "SO";
if (tipoCita == null) tipoCita = "SOP";
if (fp == null) fp = "";
if (citasSopAdm == null) citasSopAdm = "";
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (sexo == null) sexo = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function goOption(option)
{
	var fechaCita = document.frmSearch.fecha.value;
	var fechaReg = document.frmSearch.fechaRegistro.value;
	var codCita = document.frmSearch.codCita.value;
	var cds = document.frmSearch.cds.value;
	var habitacion = document.frmSearch.habitacion.value;
	var pacId = document.frmSearch.pacId.value;
	var noAdmision = document.frmSearch.noAdmision.value;
	var codPac = document.frmSearch.codPac.value;
	var dob = document.frmSearch.dob.value;
	var tipoSolicitud = 'Q';
	var existe = 'N';
	
	if(fechaCita == '' && option==3){fechaCita =document.frmSearch.fecha.value;}
	if((fechaCita == '' || codCita == '') && option!=3 && option !=6) alert('Por favor seleccione una Cita!');
	else if(option==3){
		if(habitacion=='')alert('Seleccione Habitación');
		else {
          var url = '../cita/reg_cita.jsp?mode=add&cds='+cds+'&habitacion='+habitacion+'&fechaCita='+fechaCita+'&tipoCita=<%=tipoCita%>';
          if ("<%=citasSopAdm%>" == "Y" || "<%=citasSopAdm%>" == "S") url = url + "&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&citasSopAdm=<%=citasSopAdm%>&nombreMedico=<%=nombreMedico%>&medico=<%=codMedico%>&forma_reserva=P&provincia=<%=provincia%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&d_cedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipo_paciente=<%=tipoPaciente%>&f_nac=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>";
          abrir_ventana(url);
        }
	} else {
		if(option==undefined)alert('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
		else if(option==0 || option == 2){
			 tipoSolicitud = 'Q';
			var tab = 0;
			if(option == 2){
				tipoSolicitud = 'A';
				tab=1;
			}
			var estado=getDBData('<%=request.getContextPath()%>','(select z.estado from (select s.estado  from tbl_cdc_solicitud_enc s,  (select max(secuencia) maxSec from tbl_cdc_solicitud_enc   where cita_codigo = '+codCita+'  and to_date(to_char(cita_fecha_reg, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaReg+'\', \'dd/mm/yyyy\')    and tipo_solicitud = \''+tipoSolicitud+'\') x1  where s.cita_codigo = '+codCita+' and to_date(to_char(s.cita_fecha_reg, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaReg+'\', \'dd/mm/yyyy\')  and s.tipo_solicitud = \''+tipoSolicitud+'\'  and s.secuencia = x1.maxSec) z)  estado ','dual','','');
			if(estado!='') existe = 'S';
			if(existe=='N') abrir_ventana('../facturacion/reg_cargo_dev_so.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaReg+'&tipoSolicitud='+tipoSolicitud);
			//else if (existe=='S' && estado =='P')
			else if (existe=='S' && estado =='P') abrir_ventana('../facturacion/reg_cargo_dev_so.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaReg+'&tipoSolicitud='+tipoSolicitud+'&mode=edit');
			else {
				if(estado=='E') alert('La solicitud QUIRURGICA ya fue CERRADA!!!');
				else if(estado=='A') alert('La solicitud QUIRURGICA fue ANULADA!!!');
				else if(estado=='T'){
					abrir_ventana('../facturacion/reg_cargo_dev_so_2.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaReg+'&tipoSolicitud='+tipoSolicitud+'&estadoCita='+estado+'&tab='+tab);
				}
			}
		} 
		else if(option==1)
		{
			if(noAdmision=='') alert('La Cita no tiene Admision asignada!');
			else {
						if(noAdmision=='' || pacId=='') alert('Error al intentar detectar si la cita ya tiene ADMISION!');
						else abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
				 }
		}
		else if(option==4 || option == 5){
			 tipoSolicitud = 'Q';
			if(option==5) tipoSolicitud = 'A';
			abrir_ventana('../facturacion/print_sol_prev_mat_vacia.jsp?fechaRegistro='+fechaReg+'&codCita='+codCita+'&tipoSolicitud='+tipoSolicitud);
		} else if(option==6){
			var fechaCita = document.frmSearch.fecha.value;
			var hideQuirSinCita = $("#hideQuirSinCita").is(":checked")?"S":"N";
			//abrir_ventana('../inventario/print_cdc_programa.jsp?fecha='+fechaCita);
			abrir_ventana('../cita/print_citas_quirofano.jsp?fechaCita='+fechaCita+'&hideQuirSinCita='+hideQuirSinCita);
		}else if(option==7){
			var usos=getDBData('<%=request.getContextPath()%>','count(secuencia)','tbl_sal_cargos_usos','compania=<%=session.getAttribute("_companyId")%> and cod_cita = '+codCita+' and trunc(fecha_cita) = to_date(\''+fechaReg+'\', \'dd/mm/yyyy\') and estado = \'A\' and tipo = \'C\' and sop = \'S\'','');
			if(/*estado=='T' &&*/ usos =='0'){if(noAdmision!=''){abrir_ventana('../facturacion/reg_cargo_dev_det_su.jsp?fg=SOP&fp=USOS&codCita='+codCita+'&fechaCita='+fechaReg+'&pacId='+pacId+'&noAdmision='+noAdmision+'&cds='+cds);}else alert('La cita seleccionada no tiene admision !!');}else alert('La cita seleccionada ya tiene los USOS registrados!!');
		}else if(option==8){if(noAdmision!=''){abrir_ventana('../expediente/print_exp_seccion_28.jsp?fg=USOS&fp=SOP&pacId='+pacId+'&noAdmision='+noAdmision+'&fechaCita='+fechaCita+'&codCita='+codCita);}else alert('La cita seleccionada no tiene admision !!');}
		else if(option==9||option==10){
			if(option==10) tipoSolicitud = 'A';
		abrir_ventana('../facturacion/print_sol_prev_mat.jsp?fechaRegistro='+fechaReg+'&codCita='+codCita+'&cod_paciente='+codPac+'&fec_nacimiento='+dob+'&admision='+noAdmision+'&pacId='+pacId+'&tipoSolicitud='+tipoSolicitud);}
		
	}
}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Solicitud Insumos Quirurgicos';break;
		case 1:msg='Imprimir Detalles de Cargos';break;
		case 2:msg='Solicitud Insumos Anestesia';break;
		case 3:msg='Agregar Cita';break;
		case 4:msg='Imprimir Hoja de Materiales Adicionales Quirúrgica';break;
		case 5:msg='Imprimir Hoja de Materiales Adicionales Anestesia';break;
		case 6:msg='Imprimir Programa Quirúrgico';break;
		case 7:msg='Solicitud de Usos';break;
		case 8:msg='Imprimir Usos';break;
		case 9:msg='Reporte Solic. Previa Mat., Medic. Quirurgico';break;
		case 10:msg='Reporte Solic. Previa Mat., Medic. Anestesia';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}
function solTrx(){var fechaCita = document.frmSearch.fechaCita.value;abrir_ventana1('../facturacion/cdc_trx_pendientes.jsp?fp=quirofano&fg=<%=fg%>&fechaCita='+fechaCita);}
function setFrameService(){var fecha=document.frmSearch.fecha.value;submitDate(fecha);}
function doAction(){getLocaleDate('<%=fechaCita%>','_searchFecha'); getQtyCitasAsoc();}
function submitDate(fecha){if(fecha.trim()!=''&&isValidateDate(fecha,'dd/mm/yyyy')){document.frmSearch.fecha.value=fecha;document.frmSearch.fechaCita.value=fecha;getLocaleDate(fecha,'_searchFecha');window.frames.iRooms.window.location='../cita/quirofano_rooms.jsp?fechaCita='+fecha+'&fg=<%=fg%>&citasSopAdm=<%=citasSopAdm%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=nombreMedico%>&codMedico=<%=codMedico%>&provincia=<%=provincia%>&sigla=<%=sigla%>&asiento=<%=asiento%>&dCedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipoPaciente=<%=tipoPaciente%>&fechaNacimiento=<%=fechaNacimiento%>&codigoPaciente=<%=codigoPaciente%>&tomo=<%=tomo%>&sexo=<%=sexo%>';}}
function submitDay(days){var fecha=addDays(document.frmSearch.fecha.value,days);submitDate(fecha);}
function submitMonth(months){var fecha=addMonths(document.frmSearch.fecha.value,months);submitDate(fecha);}

function getQtyCitasAsoc(){
  <%if(!pacId.equals("") && !noAdmision.equals("")){%>
  var qty =  getDBData('<%=request.getContextPath()%>','count(*)','tbl_cdc_cita',"pac_id = <%=pacId%> and admision = <%=noAdmision%> and estado_cita not in ('C','T')",'');
  parent.document.getElementById("qty_citas_asociadas").innerHTML = qty;
  <%}%>
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%if(!citasSopAdm.trim().equals("S")&&!citasSopAdm.trim().equals("Y")){%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="QUIROFANO - LISTA"></jsp:param>
</jsp:include>
<%}%>
<table align="center" width="99%" cellpadding="1" cellspacing="0" border="0">
<%fb = new FormBean("frmSearch",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("citasSopAdm",citasSopAdm)%>
<%=fb.hidden("fechaRegistro","")%>
<%=fb.hidden("codCita","")%>
<%=fb.hidden("habitacion","")%>
<%=fb.hidden("cds","")%>
<%=fb.hidden("tipoCita",tipoCita)%>
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
<%=fb.hidden("f_nac",fechaNacimiento)%>
<%=fb.hidden("codigo_paciente",codigoPaciente)%>
<%=fb.hidden("sexo",sexo)%>

<tr>
	<td align="right" colspan="2">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<%if(fg.equalsIgnoreCase("inv")) {%>
				<authtype type='62'><a href="javascript:goOption(7)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/drug-basket.jpg"></a></authtype>
		<authtype type='63'><a href="javascript:goOption(8)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/printer.gif"></a></authtype>
		<authtype type='57'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/surgical.gif"></a></authtype>
		<authtype type='58'><a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/print-shopping-cart.gif"></a></authtype>
		<authtype type='59'><a href="javascript:goOption(2);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/anestesia.gif"></a></authtype>
		<authtype type='60'><a href="javascript:goOption(4);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/print_surgical.gif"></a></authtype>
		<authtype type='61'><a href="javascript:goOption(5);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/print_anestesia.gif"></a></authtype>
		<%} else if(fg.equalsIgnoreCase("SO")) {%>
		<authtype type='50'>
		<a href="javascript:goOption(3);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/appointment.gif"></a>
		</authtype>
		<%}%>
		<authtype type='56'><a href="javascript:goOption(6);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/print_surgical_appointment.gif"></a></authtype>
		<authtype type='64'><a href="javascript:goOption(9);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,9)" onMouseOut="javascript:mouseOut(this,9)" src="../images/print_surgical.gif"></a></authtype>
		<authtype type='65'><a href="javascript:goOption(10);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/print_anestesia.gif"></a></authtype>
		
	</td>
</tr>
<tr>
	<td width="50%"><cellbytelabel>Fecha</cellbytelabel>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="fecha" />
		<jsp:param name="valueOfTBox1" value="<%=fechaCita%>" />
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="buttonClass" value="Text10" />
		<jsp:param name="onChange" value="javascript:setFrameService()" />
		<jsp:param name="jsEvent" value="javascript:setFrameService()" />
		</jsp:include>
		&nbsp;&nbsp;&nbsp;<%=fb.checkbox("hideQuirSinCita", "")%>Ocultar Quir&oacute;fanos sin cita en impresi&oacute;n Programa Quir&uacute;rgico!
	</td>
	<td width="50%" align="right">
		<% if (!fg.equalsIgnoreCase("SO")) { %>
		<authtype type='62'><a href="javascript:solTrx()" class="Link05 UpperCaseText SpacingText"><%=(contTrx>0?""+contTrx+" solicitud(es) pendientes(s)!!!":"")%></a></authtype>
		<% } %>
	</td>
</tr>
<tr align="center" class="TextHeader">
	<td colspan="2">
		<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr class="TextHeader">
			<td width="25%" align="right">
				<%=fb.button("subMonth","<<",true,false,"Text10",null,"onClick=\"javascript:submitMonth(-1)\"")%>
				<%=fb.button("subDay","<",true,false,"Text10",null,"onClick=\"javascript:submitDay(-1)\"")%>
			</td>
			<td width="50%" align="center">
				<%=fb.hidden("fechaCita",fechaCita)%>
				<label id="_searchFecha"></label>
			</td>
			<td width="25%">
				<%=fb.button("addDay",">",true,false,"Text10",null,"onClick=\"javascript:submitDay(1)\"")%>
				<%=fb.button("addMonth",">>",true,false,"Text10",null,"onClick=\"javascript:submitMonth(1)\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
<tr>
	<td colspan="2"><iframe name="iRooms" id="iRooms" src="../cita/quirofano_rooms.jsp?fechaCita=<%=fechaCita%>&fg=<%=fg%>&fp=<%=fp%>&tipoCita=<%=tipoCita%>&citasSopAdm=<%=citasSopAdm%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&nombreMedico=<%=nombreMedico%>&codMedico=<%=codMedico%>&provincia=<%=provincia%>&sigla=<%=sigla%>&asiento=<%=asiento%>&dCedula=<%=dCedula%>&pasaporte=<%=pasaporte%>&tipoPaciente=<%=tipoPaciente%>&fechaNacimiento=<%=fechaNacimiento%>&codigoPaciente=<%=codigoPaciente%>&tomo=<%=tomo%>&sexo=<%=sexo%>" width="100%" height="375" scrolling="auto"></iframe></td>
</tr>
</table>
</body>
</html>
<%
}
%>