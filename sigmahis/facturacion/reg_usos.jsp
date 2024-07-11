<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.CdcSolicitud"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="issi.facturacion.FactDetTransComp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CdcSolMgr" scope="page" class="issi.admision.CdcSolicitudMgr" />
<jsp:useBean id="CdcSol" scope="session" class="issi.admision.CdcSolicitud" />
<jsp:useBean id="fTranCargQ" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargQKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargA" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargAKey" scope="session" class="java.util.Hashtable" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																																										NOMBRE EN FORMA
CDC100110_I					INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - CONSULTA DE PRORAMAS QUIRURGICOS\SOLICITUD INSUMOS QUIRURGICOS		SOLICITUD PREVIA DE MAT. Y MED. PARA PACIENTES EN SALON DE OPERACIONES.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
CdcSolMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject cdoX = new CommonDataObject();
CommonDataObject cdoY = new CommonDataObject();

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdoCount = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String id = request.getParameter("id");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String estadoCita = request.getParameter("estadoCita");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String habitacion = request.getParameter("habitacion");
String secuencia = "";
boolean viewMode = false;
int lineNo = 0, contY = 0;

CdcSolicitud sol = new CdcSolicitud();

if (mode == null) mode = "add";
if(fp==null) fp="cargo_dev_so";
if(mode.equals("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{
		sql = "select secuencia from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and to_date(to_char(cita_fecha_reg,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy') and estado = 'T' and tipo_solicitud = '"+tipoSolicitud+"'";
		cdoX = SQLMgr.getData(sql);
		if(cdoX!=null && cdoX.getColValue("secuencia")!=null){
			secuencia = cdoX.getColValue("secuencia");
		}

		sql = "select count(*) contador from tbl_cdc_solicitud_trx where cita_codigo = "+codCita+" and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"','dd/mm/yyyy') and secuencia = "+secuencia+" and compania = "+(String) session.getAttribute("_companyId")+" and trx_estado = 'P'";
		System.out.println("contY=\n"+sql);
		if(!secuencia.equals("")){
			cdoY = SQLMgr.getData(sql);
			if(cdoY!=null && cdoY.getColValue("contador")!=null){
				contY = Integer.parseInt(cdoY.getColValue("contador"));
			}
		}

		sql = "select cita_codigo citaCodigo, cita_fecha_reg citaFechaReg, nvl(to_char(hora_entrada, 'HH12 am'), '') horaEntrada, nvl(to_char(hora_salida, 'HH12 am'), ' ') horaSalida, nvl(to_char(fecha_documento, 'dd/mm/yyyy'), '') fechaDocumento, centro_servicio centroServicio, decode(hora_entrada, null,null,decode(hora_salida, null, null, decode(sign(to_number(to_char(hora_entrada, 'hh24mi'))-to_number(to_char(hora_salida, 'ff24mi'))),1,getTiempo(hora_entrada, to_date(to_char(hora_entrada + 1, 'dd-mm-yyyy')||' '||to_char(hora_salida, 'hh12:mi:ss am'), 'dd-mm-yyyy hh12:mi:ss am'), 'H'),getTiempo(hora_entrada, to_date(to_char(hora_entrada, 'dd-mm-yyyy')||' '||to_char(hora_salida, 'hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am'), 'H')))) dspHora, decode(hora_entrada, null,null,decode(hora_salida, null, null, decode(sign(to_number(to_char(hora_entrada, 'hh24mi'))-to_number(to_char(hora_salida, 'ff24mi'))),1,getTiempo(hora_entrada, to_date(to_char(hora_entrada + 1, 'dd-mm-yyyy')||' '||to_char(hora_salida, 'hh12:mi:ss am'), 'dd-mm-yyyy hh12:mi:ss am'), 'M'),getTiempo(hora_entrada, to_date(to_char(hora_entrada, 'dd-mm-yyyy')||' '||to_char(hora_salida, 'hh12:mi:ss am'),'dd-mm-yyyy hh12:mi:ss am'), 'M')))) dspMin from tbl_cdc_solicitud_enc where to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and cita_codigo = " + codCita + " and compania = " + (String) session.getAttribute("_companyId") + " and estado = 'T' and tipo_solicitud = 'A'";
		System.out.println("...................................................");
		System.out.println(sql);
		System.out.println("...................................................");
		

		sol = (CdcSolicitud) sbb.getSingleRowBean(ConMgr.getConnection(), sql, CdcSolicitud.class);
		if(sol==null) sol = new CdcSolicitud();
				
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
}

function addUsos(){
	var hora_entrada   		= document.form1.hora_entrada.value;
	var hora_salida   		= document.form1.hora_salida.value;
	var v_fec_nacimiento	= document.form1.fec_nacimiento.value;
	var p_cod_paciente		= document.form1.cod_paciente.value;
	var p_admision    		= document.form1.admision.value;
	var p_centro_servicio	= document.form1.centro_servicio.value;
	var p_compania 				= '<%=session.getAttribute("_companyId")%>';
	var v_user 						= '<%=session.getAttribute("_userName")%>';
	var p_calcular_uso 		= '-1';
	var p_tipo_cirugia 		= getRadioButtonValue(document.form1.rb_tipo_cirugia);
	
  var p_codigo   				= document.form1.codCita.value;
  var v_fecha_registro	= document.form1.fechaCita.value;
  var p_rg_anestesico   = getRadioButtonValue(document.form1.rb_anestesico);
  var p_sevorane_cant   = document.form1.sevorane_cant.value;
  var p_forane_cant			= document.form1.forane_cant.value;

	var p_habitacion				= document.form1.habitacion.value;
	var dsp_hora = 0;
	var dsp_min  = 0;
	var p_uso = 'null';
	var calcular = true;
	if(document.form1.dsp_hora.value!='') dsp_hora = parseInt(document.form1.dsp_hora.value,10);
	if(document.form1.dsp_min.value!='') dsp_min = parseInt(document.form1.dsp_min.value,10);

	var chk_uso_sop				= '';
	if(document.form1.chk_uso_sop.checked) chk_uso_sop	= document.form1.chk_uso_sop.value;
	var chk_gases				= '';
	if(document.form1.chk_gases.checked){
		chk_gases	= document.form1.chk_gases.value;
		if(p_rg_anestesico == '299'){
			if(isNaN(p_sevorane_cant) || p_sevorane_cant == ''){
				CBMSG.warning('Introduzca valores numéricos!');
				document.form1.sevorane_cant.value = '';
				calcular = false;
			}
		}	else p_sevorane_cant = 'null';	
		if(p_rg_anestesico == '300'){
			if(isNaN(p_forane_cant) || p_forane_cant == ''){
				CBMSG.warning('Introduzca valores numéricos!');
				document.form1.forane_cant.value = '';
				calcular = false;
			}
		}	else p_forane_cant = 'null';	
	} else {
		p_rg_anestesico = 'null';
		p_sevorane_cant = 'null';	
		p_forane_cant = 'null';	
	}
	var chk_monitor				= '';
	if(document.form1.chk_monitor.checked) chk_monitor	= document.form1.chk_monitor.value;
	var chk_diprinfusor				= '';
	if(document.form1.chk_diprinfusor.checked) chk_diprinfusor	= document.form1.chk_diprinfusor.value;
	
	if(chk_uso_sop == '' && chk_gases == '' && chk_monitor == '' && chk_diprinfusor == '') CBMSG.warning('ATENCION: No se seleccionó ningún tipo de uso para cargar, por lo tanto se harán solamente los cargos de Materiales y medicamentos de la Solicitud!');
	else {
	
		if((p_habitacion == '1' || p_habitacion == '2' || p_habitacion == '3' || p_habitacion == '4' || p_habitacion == '5') && (dsp_hora + dsp_min) > 0){
			if(chk_gases == '1' && calcular){
				var p_tipo_cargo   = '1';
				if(executeDB('<%=request.getContextPath()%>','call sp_cdc_cargo_auto_anestesia(' + p_tipo_cargo + ', \'' + v_fec_nacimiento + '\', ' + p_cod_paciente + ', ' + p_admision + ', ' + p_codigo + ', \'' + v_fecha_registro + '\', ' + p_rg_anestesico + ', ' + p_sevorane_cant + ', ' + p_forane_cant + ', \'' + hora_entrada + '\', \'' + hora_salida + '\', ' + p_centro_servicio + ', ' +p_compania + ', \'' + v_user + '\')','tbl_fac_transaccion, tbl_inv_entrega_material, tbl_inv_detalle_entrega, tbl_inv_solicitud_pac, tbl_inv_d_sol_pac, tbl_inv_solicitud_req, tbl_inv_d_sol_req')){
					CBMSG.warning('Guardado Satisfactoriamente!');
				} else CBMSG.warning('No se ha Generado el Cargo Automático Anestesia!');
			} 
			if(chk_monitor == '2'){
				var p_tipo_cargo   = '2';
				if(executeDB('<%=request.getContextPath()%>','call sp_cdc_cargo_auto_anestesia(' + p_tipo_cargo + ', \'' + v_fec_nacimiento + '\', ' + p_cod_paciente + ', ' + p_admision + ', ' + p_codigo + ', \'' + v_fecha_registro + '\', ' + p_rg_anestesico + ', ' + p_sevorane_cant + ', ' + p_forane_cant + ', \'' + hora_entrada + '\', \'' + hora_salida + '\', ' + p_centro_servicio + ', ' +p_compania + ', \'' + v_user + '\')','tbl_fac_transaccion, tbl_inv_entrega_material, tbl_inv_detalle_entrega, tbl_inv_solicitud_pac, tbl_inv_d_sol_pac, tbl_inv_solicitud_req, tbl_inv_d_sol_req')){
					CBMSG.warning('Guardado Satisfactoriamente!');
				} else CBMSG.warning('No se ha Generado el Cargo Automático Anestesia!');
			} 
			if(chk_diprinfusor == '3'){
				var p_tipo_cargo   = '3';
				if(executeDB('<%=request.getContextPath()%>','call sp_cdc_cargo_auto_anestesia(' + p_tipo_cargo + ', \'' + v_fec_nacimiento + '\', ' + p_cod_paciente + ', ' + p_admision + ', ' + p_codigo + ', \'' + v_fecha_registro + '\', ' + p_rg_anestesico + ', ' + p_sevorane_cant + ', ' + p_forane_cant + ', \'' + hora_entrada + '\', \'' + hora_salida + '\', ' + p_centro_servicio + ', ' +p_compania + ', \'' + v_user + '\')','tbl_fac_transaccion, tbl_inv_entrega_material, tbl_inv_detalle_entrega, tbl_inv_solicitud_pac, tbl_inv_d_sol_pac, tbl_inv_solicitud_req, tbl_inv_d_sol_req')){
					CBMSG.warning('Guardado Satisfactoriamente!');
				} else CBMSG.warning('No se ha Generado el Cargo Automático Anestesia!');
			}
		}
	}
}

function addUso(){abrir_ventana2('../common/sel_uso.jsp?fp=cita_x_hab');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%//=fb.hidden("saveOption","C")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%//=fb.hidden("fPage",fPage)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("estadoCita",estadoCita)%>
<%=fb.hidden("codAlmacen","")%>
<%=fb.hidden("centroServicio","")%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("copiarInsumos","")%>
<%=fb.hidden("habitacion",habitacion)%>
<%=fb.hidden("cierre","")%>
<%=fb.hidden("cod_paciente",request.getParameter("cod_paciente"))%>
<%=fb.hidden("fec_nacimiento",request.getParameter("fec_nacimiento"))%>
<%=fb.hidden("admision",request.getParameter("admision"))%>
<%=fb.hidden("hora_entrada",request.getParameter("hora_entrada"))%>
<%=fb.hidden("hora_salida",request.getParameter("hora_salida"))%>
<%=fb.hidden("dsp_hora",sol.getDspHoras())%>
<%=fb.hidden("dsp_min",sol.getDspMin())%>
<%=fb.hidden("calcular_uso","0")%>
<%
int colspan = 12;
if(tipoSolicitud.equals("A")) colspan = 11;
%>
<%=fb.hidden("centro_servicio", sol.getCentroServicio())%>

<table width="100%" align="center">
  <tr>
    <td colspan="<%=colspan%>"><table align="center" width="100%" cellpadding="0" cellspacing="1">
      <tr>
        <td colspan="5" onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
          <tr class="TextPanel">
            <td width="95%">&nbsp;<cellbytelabel>Seleccione los tipos de usos a cargar</cellbytelabel></td>
            <td width="5%" align="right">[<font face="Courier New, Courier, mono">
              <label id="plus41" style="display:none">+</label>
              <label id="minus41">-</label>
            </font>]&nbsp;</td>
          </tr>
        </table></td>
      </tr>
      <tr id="panel41">
        <td colspan="5"><table width="100%" cellpadding="1" cellspacing="0">
          <tr class="TextHeader02">
            <td colspan="2"><%=fb.checkbox("chk_gases", "1", false, false, "Text10", "", "")%>&nbsp;M&aacute;quina de Anestesia</td>
          </tr>
          <tr class="TextRow04">
            <td><%=fb.radio("rb_anestesico","299",true,viewMode,false)%><cellbytelabel>Sevorane</cellbytelabel></td>
            <td><%=fb.intBox("sevorane_cant","", false, false, false, 2, "Text10", null, "")%></td>
          </tr>
          <tr class="TextRow06">
            <td><%=fb.radio("rb_anestesico","300",false,viewMode,false)%><cellbytelabel>Forane</cellbytelabel></td>
            <td><%=fb.intBox("forane_cant", "", false, false, false, 2, "Text10", null, "")%></td>
          </tr>
          <tr class="TextRow04">
            <td colspan="2"><%=fb.radio("rb_anestesico","3",false,viewMode,false)%><cellbytelabel>Otro</cellbytelabel></td>
          </tr>
          <tr class="TextHeader02">
            <td colspan="2"><%=fb.checkbox("chk_monitor", "2", false, false, "Text10", "", "")%>&nbsp;<cellbytelabel>Monitor</cellbytelabel></td>
          </tr>
          <tr class="TextHeader02">
            <td colspan="2"><%=fb.checkbox("chk_diprinfusor", "3", false, false, "Text10", "", "")%>&nbsp;<cellbytelabel>Diprinfusor</cellbytelabel></td>
          </tr>
          <tr class="TextHeader02">
            <td colspan="2"><%=fb.button("addTiposUsos", "Continuar", false, viewMode, "", "", "onClick=\"javascript:addUsos();\"")%></td>
          </tr>
        </table></td>
      </tr>
    </table></td>
  </tr>
  <%=fb.hidden("cont_trx",""+contY)%>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
%>
