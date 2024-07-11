<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.CdcSolicitud"%>
<%@ page import="issi.admision.CdcSolicitudDet"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CdcSol" scope="session" class="issi.admision.CdcSolicitud" />
<jsp:useBean id="CdcSolMgr" scope="page" class="issi.admision.CdcSolicitudMgr" />
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
//CdcSolMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alProc = new ArrayList();
CommonDataObject cdoCita = new CommonDataObject();
CommonDataObject cdoX = new CommonDataObject();

String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String estadoCita = request.getParameter("estadoCita");
String tipoSolicitud = request.getParameter("tipoSolicitud");
String codigo = request.getParameter("codigo");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
if(fg==null) fg = "zzz";
String fp = request.getParameter("fp");
if(fp==null) fp = "cargo_dev_so";
String fPage = request.getParameter("fPage");
if(fPage==null) fPage = "";
boolean viewMode = false;
String estado = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String label = "";
String tabFunctions = "'0=tabFunctions(0)', '1=tabFunctions(1)'";
int lineNo = 0;
if (tab == null) tab = "0";
if (mode == null) mode = "add";
System.out.println("___________________________________tipoSolicitud _______________________"+request.getParameter("tipoSolicitud"));
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")||mode.equalsIgnoreCase("view"))
	{
		/*
		fTranCargQ.clear();
		fTranCargQKey.clear();
		fTranCargA.clear();
		fTranCargAKey.clear();
		*/
		if(change==null){
			if (codCita == null) throw new Exception("El Código de Cita no es válido. Por favor intente nuevamente!");
			if (fechaCita == null) throw new Exception("La Fecha de Cita no es válida. Por favor intente nuevamente!");
			if (tipoSolicitud == null) throw new Exception("El tipo de Solicitud no es válido. Por favor intente nuevamente!");
			CdcSol = new CdcSolicitud();
			session.setAttribute("CdcSol",CdcSol);
			if(tipoSolicitud.equals("Q")) label = "QUIRURGICOS";
			else if(tipoSolicitud.equals("A")) label = "ANESTESIA";

			sql = "select b.nombre_paciente,c.codigo, c.fecha_registro, to_char (c.hora_cita, 'HH12:MI AM') hora_cita, c.hora_est, c.min_est, c.persona_reserva, to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'HH12:MI AM') hora_final, to_date(to_char(c.fecha_cita, 'DD-MM-YYYY'), 'DD-MM-YYYY') fecha_inicio, to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'DD-MM-YYYY'), 'DD-MM-YYYY') fecha_final, to_date(to_char (c.fecha_cita, 'DD-MM-YYYY') || ' ' || to_char(c.hora_cita, 'HH24:MI'), 'DD-MM-YYYY HH24:MI') fecha_hora_inicio, c.habitacion, to_char(c.fec_nacimiento, 'dd/mm/yyyy') fec_nacimiento, c.cod_paciente, c.admision, nvl(c.observacion, ' ') observacion, c.estado_cita, decode(nvl(h.quirofano, 1), 2, 'S', 'N') es_quirofano,c.cod_tipo,b.pac_id,c.centro_servicio  as centroServicio, nvl(get_nombremedico(c.compania,'COD_FUNC_CIRUJANO',to_char(c.fecha_registro,'dd/mm/yyyy')||(to_char(c.codigo))),'') as cirujano ,nvl(get_nombremedico(c.compania,'COD_FUNC_ANEST',to_char( c.fecha_registro,'dd/mm/yyyy')||(to_char(c.codigo))),'')||nvl(get_nombremedico(c.compania,'COD_FUNC_ANEST_SOC',to_char( c.fecha_registro,'dd/mm/yyyy')||(to_char(c.codigo))),'') as anestesiologo from tbl_cdc_cita c,tbl_sal_habitacion h, vw_adm_paciente b where to_date(to_char(c.fecha_registro, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy') and c.codigo = "+codCita+" and c.compania = " + (String) session.getAttribute("_companyId") + " and c.habitacion = h.codigo(+) and c.pac_id = b.pac_id(+)";
			System.out.println("SQL:\n"+sql);
			
			cdoCita = SQLMgr.getData(sql);
			
			CdcSol.setCitaCodigo(codCita);
			CdcSol.setCitaFechaReg(fechaCita);
			CdcSol.setCodigoAlmacen(ResourceBundle.getBundle("issi").getString("almacenSOP"));

			CdcSol.setCentroServicio(cdoCita.getColValue("centroServicio"));
			CdcSol.setTipoSolicitud(tipoSolicitud);
			if(estadoCita==null || estadoCita.equals("")) estadoCita = cdoCita.getColValue("estado_cita");
			
		}
		
		String cs = CdcSol.getCentroServicio();
		String v_empresa = "";//CdcSol.getEmpreCodigo();
		sql = "select a.codigo, nvl(b.observacion, b.descripcion) desc_procedimiento from tbl_cdc_cita_procedimiento a, tbl_cds_procedimiento b where a.procedimiento = b.codigo and a.cod_cita = "+codCita+" and to_date(to_char(a.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy')";
		
		System.out.println("sql procedimientos:\n"+sql);
		alProc = SQLMgr.getDataList(sql);
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Facturación - '+document.title;

function setBAction(fName,actionValue){
	document.forms[fName].baction.value = actionValue;
	if(actionValue=='Guardar'){
		chkInsumos();
		window.frames['itemFrame'].doSubmit();
	}
}
function tabFunctions(tab){
	var iFrameName = '';
	if(tab==0) iFrameName='itemFrame0';
	else if(tab==1) iFrameName='itemFrame1'; 
	if(window.frames[iFrameName].doAction)window.frames[iFrameName].doAction();
}
function doAction(estado){
	if(estado!='') CBMSG.warning('Existe una solicitud de materiales para este paciente en estado '+estado+'');
}
function chkInsumos(){
	var tipoSolicitud = document.form0.tipoSolicitud.value;
	var copiarInsumos = "N";
	if(tipoSolicitud=='Q'){
		var cont=getDBData('<%=request.getContextPath()%>','count(*)','tbl_cds_insumo_proc','compania=<%=(String) session.getAttribute("_companyId")%> and cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = <%=codCita%> and to_date(to_char(fecha_cita, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\'<%=fechaCita%>\', \'dd/mm/yyyy\'))','');

		if(cont=='' || cont =='0'){
			if(confirm('El (Los) Procedimiento(s) de esta cita no tienen insumos detallados en su mantenimiento, desea copiarle los insumos de esta solicitud?')){
				copiarInsumos = "S";
			}
		}
	}
	document.form0.copiarInsumos.value = copiarInsumos;
}
function showPacienteList(){abrir_ventana1('../common/sel_paciente.jsp?fp=cargo_dev_so');}
$(document).ready(function(){
  lazyLoadingIF();
});
function validarWh(obj){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction('<%=estado%>')">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<%fb = new FormBean("form_1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("mode",mode)%>
        <%=fb.hidden("errCode","")%>
        <%=fb.hidden("errMsg","")%>
        <%=fb.hidden("codCita",codCita)%>
        <%=fb.hidden("fechaCita",fechaCita)%>
        <%=fb.hidden("estadoCita",estadoCita)%>
        <%=fb.hidden("secuencia",CdcSol.getSecuencia())%>
        <%//=fb.hidden("codAlmacen",CdcSol.getCodigoAlmacen())%>
        <%=fb.hidden("centroServicio",CdcSol.getCentroServicio())%>
        <%=fb.hidden("tipoSolicitud",CdcSol.getTipoSolicitud())%>
        <%=fb.hidden("habitacion",cdoCita.getColValue("habitacion"))%>
		<%=fb.hidden("cod_tipo",cdoCita.getColValue("cod_tipo"))%>
		<%=fb.hidden("copiarInsumos","")%>
        <%=fb.hidden("baction","")%>
        <%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
        <%=fb.hidden("clearHT","")%>
        <%=fb.hidden("fPage",fPage)%>
        <%=fb.hidden("cierre","")%>
        <%=fb.hidden("es_quirofano",cdoCita.getColValue("es_quirofano"))%>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextPanel">
								<td align="center" colspan="4"><font color="#FFFF00" size="+2"><%=cdoCita.getColValue("nombre_paciente")%>&nbsp;<%=fb.button("btnPaciente","...",true,true,null,null,"onClick=\"javascript:showPacienteList()\"")%></font></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Hora Inicio</cellbytelabel>:</td>
								<td><%=fb.textBox("hora_cita",cdoCita.getColValue("hora_cita"),true,false,true,10)%></td>
								<td align="right"><cellbytelabel>Duraci&oacute;n Apr&oacute;x</cellbytelabel>.:</td>
								<td><%=fb.textBox("hora_est",cdoCita.getColValue("hora_est"),true,false,true,5)%>&nbsp;hrs.
								<%=fb.textBox("min_est",cdoCita.getColValue("min_est"),true,false,true,5)%>&nbsp;min.
                </td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Cirujano</cellbytelabel>:</td>
								<td><%=cdoCita.getColValue("cirujano")%><%//=fb.textBox("cirujano",cdoCita.getColValue("cirujano"),false,false,true,50)%></td>
								<td align="right"><cellbytelabel>Anestesi&oacute;logo</cellbytelabel>:</td>
								<td><%=cdoCita.getColValue("anestesiologo")%><%//=fb.textBox("anestesiologo",cdoCita.getColValue("anestesiologo"),false,false,true,50)%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel>:</td>
								<td colspan="3"><%=cdoCita.getColValue("observacion")%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right">&nbsp;<cellbytelabel>Fecha Nac</cellbytelabel>.:</td>
								<td align="left"><%=fb.textBox("fec_nacimiento",cdoCita.getColValue("fec_nacimiento"),false,false,true,12)%></td>
								<td align="left"><cellbytelabel>ID</cellbytelabel>:<%=fb.textBox("pac_id",cdoCita.getColValue("pac_id"),false,false,true,12)%>&nbsp;&nbsp; Paciente #.:&nbsp;<%=fb.textBox("cod_paciente",cdoCita.getColValue("cod_paciente"),false,false,true,12)%></td>
								<td align="left"><cellbytelabel>Admisi&oacute;n</cellbytelabel>:&nbsp;<%=fb.textBox("admision",cdoCita.getColValue("admision"),false,false,true,12)%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right">&nbsp;<cellbytelabel>Almacen</cellbytelabel>.:</td>
								<td align="left"><%=fb.select(ConMgr.getConnection(),"SELECT distinct b.codigo_almacen as almacen, b.descripcion||' - '||b.codigo_almacen, b.codigo_almacen FROM tbl_inv_almacen b where b.compania="+(String) session.getAttribute("_companyId")+" /* and exists(select null from	tbl_sec_user_almacen x where x.almacen=b.codigo_almacen and x.compania =b.compania  and x.ref_type='CDS' and x.user_id="+UserDet.getUserId()+" ) */ and b.codigo_almacen in(select column_value  from table( select split((select get_sec_comp_param(b.compania,decode('"+tipoSolicitud+"','Q','WH_SOLICITUD_QUIR','WH_SOLICITUD_AN')) from dual ),',') from dual  )) ORDER  BY 1","codAlmacen",CdcSol.getCodigoAlmacen(),false,false,0,"Text10",null,"onFocus=\"javascript:validarWh(this)\"")%></td>
								<td align="left"></td>
								<td align="left"></td>
							</tr>
						</table>
					</td>
				</tr>
			<%=fb.formEnd(true)%>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Detalle de los Procedimientos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
        <%
				for(int i=0; i<alProc.size(); i++){
					CommonDataObject cdoProc = (CommonDataObject) alProc.get(i);
					String color = "";
					
					if (i%2 == 0) color = "TextRow02";
					else color = "TextRow01";
				%>
						<tr class="<%=color%>">
							<td><%=cdoProc.getColValue("desc_procedimiento")%></td>
						</tr>
        <%	
				}
				%>
						</table>
					</td>
				</tr>
        <tr class="TextRow01"><td>&nbsp;</td></tr>
				<tr>
					<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Detalle de Insumos</cellbytelabel>&nbsp;<%=label%></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
        
        <tr>
          <td class="TableBorder">
            <table align="center" width="100%" cellpadding="5" cellspacing="0">
            <tr>
              <td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("estadoCita",estadoCita)%>
<%=fb.hidden("secuencia",CdcSol.getSecuencia())%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("cierre","")%>
<%=fb.hidden("cerrado","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>QUIRURGICO</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel3">
					<td>
						<iframe name="itemFrame0" id="itemFrame0" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src="../facturacion/reg_cargo_dev_det_so_2.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fPage=<%=fPage%>&change=<%=change%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>&tipoSolicitud=Q&habitacion=<%=cdoCita.getColValue("habitacion")%>&estadoCita=<%=estadoCita%>&tab=0"></iframe>
					</td>	
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
 <div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("estadoCita",estadoCita)%>
<%=fb.hidden("secuencia",CdcSol.getSecuencia())%>
<%=fb.hidden("tipoSolicitud",tipoSolicitud)%>
<%=fb.hidden("habitacion",cdoCita.getColValue("habitacion"))%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("cierre","")%>
<%=fb.hidden("cerrado","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(4)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>ANESTESIA</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus4" style="display:none">+</label><label id="minus4">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel4">
					<td>
						<!--<iframe name="itemFrame1" id="itemFrame1" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src=""></iframe>-->
						<iframe name="itemFrame1" id="itemFrame1" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src="../facturacion/reg_cargo_dev_det_so_2.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fPage=<%=fPage%>&change=<%=change%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>&tipoSolicitud=A&habitacion=<%=cdoCita.getColValue("habitacion")%>&estadoCita=<%=estadoCita%>&tab=1"></iframe>
					</td>	
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Quirúrgicos','Anestesia'";
%> 
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,Array(<%=tabFunctions%>),[]);
</script>

              </td>
            </tr>
            </table>
          </td>
        </tr>
<%//=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Guardar") || request.getParameter("baction").equalsIgnoreCase("cerrar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}
	session.removeAttribute("CdcSol");
	
%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(cierre, cerrado)
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>'; 	
	var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
	if(cierre=='S'){
		if(cerrado=='S'){
			if(msg!='') alert(msg);
			else alert('La solicitud se ha cerrado Satisfactoriamente!');
			/*
			if(confirm('Desea registrar Usos?')){
				window.location = '../facturacion/reg_usos.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fPage=<%=fPage%>&change=<%=change%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>&tipoSolicitud=A&estadoCita=<%=estadoCita%>&habitacion=<%=request.getParameter("habitacion")%>';
			}
			*/
		}	else {
			if(msg!='') alert(msg);
			else alert('No se ha cerrado la Solicitud!');
		}
	}
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>	
	window.close();
<%
	}
//} else if(request.getParameter("cierre")!=null && request.getParameter("cierre").equalsIgnoreCase("cerrar")){
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&fg=<%=fg%>&fPage=<%=fPage%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>&tipoSolicitud=<%=tipoSolicitud%>&tab=<%=request.getParameter("tab")%>&fp=<%=fp%>';
}

function viewMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&codigo=<%=codigo%>&fechaCita=<%=fechaCita%>&fg=<%=fg%>&codCita=<%=codCita%>&tipoSolicitud=<%=tipoSolicitud%>&fp=<%=fp%>';
}

</script>
</head>
<body onLoad="closeWindow('<%=request.getParameter("cierre")%>','<%=request.getParameter("cerrado")%>')">
</body>
</html>
<%
}//POST
%>
