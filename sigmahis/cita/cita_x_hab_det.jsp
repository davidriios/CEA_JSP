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
==========================================================================================================================
FORMA				MENU																														NOMBRE EN FORMA
CDC100100		CITAS\TRANSACCIONES\CRONOGRAMA DE QUIROFANOS										SALON DE OPERACIONES PROGRAMA QUIRURGICO
==========================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

int nCol = 8;
String colWidth = "100%";
int i=0, j=0;
String sql = "";
String fechaCita = request.getParameter("fechaCita");
String habitacion = request.getParameter("habitacion");
String fg = "SO";
if(request.getParameter("fg")!=null) fg = request.getParameter("fg");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function materiales(i,tipoSolicitud,tab){
	//var fechaCita = document.form0.fechaCita.value;
	var codCita = eval('document.form0.codCita'+i).value;
	var habitacion = document.form0.habitacion.value;
	var sol_quirurgica = eval('document.form0.sol_quirurgica'+i).value;
	var sol_anestesia = eval('document.form0.sol_anestesia'+i).value;
	var fechaCita = eval('document.form0.fecha_registro'+i).value;
	var existe = 'N';
	var form1_name = '', form2_name = '', labelTSol = '';
	if(sol_quirurgica != '' || sol_anestesia != ''){
		
		if(tipoSolicitud == 'Q') labelTSol = 'QUIRURGICA';
		else if(tipoSolicitud == 'A') labelTSol = 'ANESTESIA';
		form1_name = '../facturacion/reg_cargo_dev_so_2.jsp';
		form2_name = '../facturacion/reg_cargo_dev_so.jsp'; //cdc100120=../facturacion/reg_cargo_dev_so.jsp
		
		var estado=getDBData('<%=request.getContextPath()%>','(select z.estado from (select s.estado  from tbl_cdc_solicitud_enc s,  (select max(secuencia) maxSec from tbl_cdc_solicitud_enc   where cita_codigo = '+codCita+'  and to_date(to_char(cita_fecha_reg, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaCita+'\', \'dd/mm/yyyy\')    and tipo_solicitud = \''+tipoSolicitud+'\') x1  where s.cita_codigo = '+codCita+' and to_date(to_char(s.cita_fecha_reg, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\''+fechaCita+'\', \'dd/mm/yyyy\')  and s.tipo_solicitud = \''+tipoSolicitud+'\'  and s.secuencia = x1.maxSec) z)  estado ','dual','','');
			if(estado!='') existe = 'S';
			if(existe=='N') abrir_ventana('../facturacion/reg_cargo_dev_so.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaCita+'&tipoSolicitud='+tipoSolicitud);
			else if (existe=='S' && estado =='P') abrir_ventana('../facturacion/reg_cargo_dev_so.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaCita+'&tipoSolicitud='+tipoSolicitud+'&mode=edit');
			else {
				if(estado=='E') alert('La solicitud '+labelTSol+' ya fue CERRADA!!!');
				else if(estado=='A') alert('La solicitud '+labelTSol+' fue ANULADA!!!');
				else if(estado=='T'){
					abrir_ventana('../facturacion/reg_cargo_dev_so_2.jsp?fg=zzz&codCita='+codCita+'&fechaCita='+fechaCita+'&tipoSolicitud='+tipoSolicitud+'&estadoCita='+estado+'&tab='+tab);
				}
			}
		}else alert('A la cita seleccionada no se le tiene solicitudes enviadas a inventario!');
}

function printProgQuirurgico(){var fechaCita = document.form0.fechaCita.value;abrir_ventana('../cita/print_citas_quirofano.jsp?fechaCita='+fechaCita);}
function printSolPrevMat(x, tipoSolicitud){
	var codCita = eval('document.form0.codCita'+x).value;
	var fechaCita = eval('document.form0.fecha_registro'+x).value;
	var cod_paciente = eval('document.form0.cod_paciente'+x).value;
	var fec_nacimiento = eval('document.form0.fec_nacimiento'+x).value;
	var admision = eval('document.form0.admision'+x).value;
	abrir_ventana('../facturacion/print_sol_prev_mat.jsp?fechaRegistro='+fechaCita+'&codCita='+codCita+'&cod_paciente='+cod_paciente+'&fec_nacimiento='+fec_nacimiento+'&admision='+admision+'&tipoSolicitud='+tipoSolicitud);
}
function printCargos(pac_id, secuencia){if(pac_id != '' && secuencia != '') abrir_ventana1('../facturacion/print_cargo_dev.jsp?noSecuencia='+secuencia+'&pacId='+pac_id);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("habitacion", habitacion)%>
<%=fb.hidden("fechaCita", fechaCita)%>
<table align="center" width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
<%
ArrayList alQ = new ArrayList();

sql = "select sh.compania compania, sh.codigo habitacion, c.nombre_paciente nombre_paciente, c.codigo, to_char(c.fecha_registro, 'dd/mm/yyyy') fecha_registro, to_char(c.hora_cita, 'HH12:MI AM') hora_inicio, c.hora_est tiempo_hora, c.min_est tiempo_min, nvl(c.observacion, 'NO DEFINIDO') observacion, c.persona_reserva, to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'HH12:MI AM') hora_final, to_date(to_char(c.fecha_cita, 'DD-MM-YYYY'), 'DD-MM-YYYY') fecha_inicio, to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'DD-MM-YYYY'), 'DD-MM-YYYY') fecha_final, to_date(to_char(c.fecha_cita, 'DD-MM-YYYY') || ' ' || to_char (c.hora_cita, 'HH24:MI'), 'DD-MM-YYYY HH24:MI') fecha_hora_inicio, nvl(substr(p.desc_procedimiento,1, instr(desc_procedimiento,'_')-1),'NO DEFINIDO') procedimiento, decode(c.observacion, null, nvl(substr(p.desc_procedimiento,instr(desc_procedimiento,'_')+1),'NO DEFINIDO'), c.observacion) desc_procedimiento, nvl(m.nombre_medico, '') nombre_medico, c.admision, c.cod_paciente, to_char(c.fec_nacimiento, 'dd/mm/yyyy') fec_nacimiento, c.sol_quirurgica, c.sol_anestesia, c.estado_cita, c.pac_id, c.admision from tbl_sal_habitacion sh, tbl_cdc_cita c, (select y.cod_cita, to_date(to_char(y.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_cita, min(y.procedimiento||'_'||substr(nvl(z.observacion, z.descripcion), 1, 20)) desc_procedimiento from tbl_cdc_tipo_cirugia x, tbl_cdc_cita_procedimiento y, tbl_cds_procedimiento z where x.codigo = y.codigo and z.codigo = y.procedimiento group by y.cod_cita, y.fecha_cita) p, (select y.cod_cita, to_date(to_char(y.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') fecha_cita, min('Dr.'||substr(x.primer_nombre, 1, 1)||'. '||x.primer_apellido) nombre_medico from tbl_adm_medico x, tbl_cdc_personal_cita y where y.medico = x.codigo and y.funcion = 1 group by y.cod_cita, y.fecha_cita) m where sh.compania = "+(String) session.getAttribute("_companyId")+" and sh.codigo = c.habitacion and sh.quirofano = 2 /*and sh.unidad_admin = 24 and c.centro_servicio = 24*/ and c.habitacion = '"+habitacion+"' and c.estado_cita not in ('C', 'T') and (to_date(to_char(c.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy') or to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy')) and c.codigo = p.cod_cita(+) and to_date(to_char(c.fecha_registro, 'dd/mm/yyyy'), 'dd/mm/yyyy') = p.fecha_cita(+) and c.codigo = m.cod_cita(+) and to_date(to_char(c.fecha_registro, 'dd/mm/yyyy'), 'dd/mm/yyyy') = m.fecha_cita(+) order by sh.codigo, to_date(to_char (c.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy'), to_char(c.hora_cita, 'HH24:MI'), to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'dd/mm/yyyy'), 'dd/mm/yyyy'), to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'HH24:MI')";

alQ = SQLMgr.getDataList(sql);
%>
    <td width="<%=colWidth%>" valign="top"><table align="center" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-bottom:1.5pt solid #CCCCCC; border-right:1.5pt solid #CCCCCC;border-left:1.5pt solid #CCCCCC;">
    		<tr class="TextHeader">
        	<td rowspan="2" align="center">&nbsp;</td>
        	<td rowspan="2" align="center"><cellbytelabel>Hora Inicio</cellbytelabel></td>
          <td rowspan="2" align="center"><cellbytelabel>Nombre del Paciente</cellbytelabel></td>
          <td rowspan="2" align="center"><cellbytelabel>Procedimiento</cellbytelabel></td>
          <td rowspan="2" align="center"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
          <td colspan="3" align="center"><cellbytelabel>Cod. Admisi&oacute;n</cellbytelabel></td>
          <td rowspan="2" align="center"><cellbytelabel>Materiales</cellbytelabel></td>
          <td rowspan="2" align="center">&nbsp;</td>
          <td rowspan="2" align="center">&nbsp;</td>
          <td rowspan="2" align="center">&nbsp;</td>
        </tr>
    		<tr class="TextHeader">
        	<td><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
          <td><cellbytelabel>Cod. Pac</cellbytelabel>.</td>
          <td><cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
        </tr>
        
        <%
        for(i=0;i<alQ.size();i++){
					CommonDataObject cdo = (CommonDataObject) alQ.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
        %>
        <%=fb.hidden("codCita"+i,cdo.getColValue("codigo"))%>
        <%=fb.hidden("sol_quirurgica"+i,cdo.getColValue("sol_quirurgica"))%>
        <%=fb.hidden("sol_anestesia"+i,cdo.getColValue("sol_anestesia"))%>
        <%=fb.hidden("fecha_registro"+i,cdo.getColValue("fecha_registro"))%>
        <%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
        <%=fb.hidden("cod_paciente"+i,cdo.getColValue("cod_paciente"))%>
        <%=fb.hidden("fec_nacimiento"+i,cdo.getColValue("fec_nacimiento"))%>
        <tr class="<%=color%>">
        	<td align="center">
					<%if(cdo.getColValue("estado_cita").equals("R")){%>
          <img src="../images/lampara_amarilla.gif" alt="Reservada">
          <%} else {%>
          <img src="../images/lampara_verde.gif" alt="Realizada">
          <%}%>
          </td>
          <td align="center">&nbsp;<%=cdo.getColValue("hora_inicio")%></td>
          <td>&nbsp;<%=cdo.getColValue("nombre_paciente")%></td>
          <td>&nbsp;<%=cdo.getColValue("desc_procedimiento")%></td>
          <td>&nbsp;<%=cdo.getColValue("nombre_medico")%></td>
          <td>&nbsp;<%=cdo.getColValue("fec_nacimiento")%></td>
          <td>&nbsp;<%=cdo.getColValue("cod_paciente")%></td>
          <td>&nbsp;<%=cdo.getColValue("admision")%></td>
          <td align="center">
		  <authtype type='50'><a href="javascript:materiales('<%=i%>','Q',0);" title="Insumos Quirurgicos"><img src="../images/surgical.gif" height="17" width="16" border="0"></a></authtype>&nbsp;&nbsp;&nbsp;
		  <authtype type='51'><a href="javascript:materiales('<%=i%>','A',1);" title="Insumos Anestesia"><img src="../images/anestesia.gif" height="17" width="16" border="0"></a></authtype>
		  </td>
          <td align="center"><authtype type='52'><a href="javascript:printSolPrevMat('<%=i%>','Q');" title="Reporte Solic. Previa Mat., Medic. Quirurgico"><img src="../images/print_surgical.gif" height="17" width="16" border="0"></a></authtype></td>
          <td align="center"><authtype type='53'><a href="javascript:printSolPrevMat('<%=i%>','A');" title="Reporte Solic. Previa Mat., Medic. Anestesia"><img src="../images/print_anestesia.gif" height="17" width="16" border="0"></a></authtype></td>
          <td align="center"><authtype type='54'><a href="javascript:printCargos('<%=cdo.getColValue("pac_id")%>','<%=cdo.getColValue("admision")%>');" title="Reporte de Cargos y Devoluciones"><img src="../images/print-shopping-cart.gif" height="17" width="16" border="0"></a></authtype></td>
        </tr>
    <%
}
%>
      </table></td>
  </tr>
</table>
<%=fb.formEnd(true)%>
</body>
</html>
<%
}
%>
