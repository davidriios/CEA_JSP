
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.rhplanilla.Empleado"%>
<%@ page import="issi.rhplanilla.Vacaciones"%>
<%@ page import="issi.rhplanilla.TemporalVac"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.CommonDataObject" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="VacMgr" scope="page" class="issi.rhplanilla.VacacionesMgr" />
<jsp:useBean id="del" scope="page" class="issi.rhplanilla.Empleado" />
<jsp:useBean id="DI" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
VacMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String empId = request.getParameter("empId");
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");

if(fp==null) fp="";
if(empId==null) empId = "";
if(anio==null) anio = "";
if(codigo==null) codigo = "";
boolean viewMode = false;


if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
 // if (mode.equalsIgnoreCase("add"))
 // {
    if (change == null)
    {
      del = new Empleado();
      DI.clear();
			if(!empId.equals("")){
				sql = "SELECT d.fechaCreacion, d.estado, d.contratar_reemplazo contratarReemplazo, d.rCargo, d.rCargoDesc, e.tipo_puesto, a.cargo, a.compania, a.emp_id empId, a.provincia, a.sigla, a.tomo, a.asiento, nvl(a.primer_nombre, ' ') primernombre, nvl(a.segundo_nombre, ' ') segundonombre, decode(a.sexo, 'F', decode(a.apellido_casada, null, a.primer_apellido, decode(a.usar_apellido_casada, 'S', 'DE ' || a.apellido_casada, a.primer_apellido)), a.primer_apellido) primerapellido, to_char(a.fecha_ingreso, 'dd/mm/yyyy') fechaIngreso, a.unidad_organi unidadorgani, nvl(a.num_empleado, ' ') numempleado, e.denominacion cargoDesc, nvl(to_char(a.gasto_rep), ' ') gastorep, a.salario_base salariobase, nvl(to_char(a.rata_hora), ' ') ratahora, b.descripcion as unidadorganidesc, decode(nvl(a.salario_base, 0), 0, a.rata_hora, a.salario_base) salarioMes, nvl(d.periodof_inicio, ' ') fechaini, /*nvl(case nvl(d.val1,0) when 1 then (case when nvl(d.tipo_vacacion, ' ') in ('AB','DP') then (case nvl(d.count_det_vacacion,0) when 1 then null else to_char(to_date(d.periodof_inicio,'dd/mm/yyyy')+d.dias_tiempo-1,'dd/mm/yyyy') end) else d.periodof_inicio end) else d.periodof_inicio end, ' ')*/ d.periodof_final fechafin, nvl(to_char(d.dias_tiempo), ' ') tiemposol, nvl(to_char(d.dias_dinero), ' ') tiemposoldinero, nvl(d.observacion, ' ') comentario, nvl(to_char(d.acumulado_salario), ' ') acumulado, nvl(to_char(d.acumulado_gasto_rep), ' ') acumulado_gr, nvl(d.tipo_vacacion, ' ') tipovacacion, nvl(to_char(d.remp_id), ' ') rempid, nvl(to_char(d.r_provincia), ' ') rprovincia, nvl(d.r_sigla, ' ') rsigla, nvl(to_char(d.r_tomo), ' ') rtomo, nvl(to_char(d.r_asiento), ' ') rasiento, nvl(d.r_num_empleado, ' ') rnumempleado, nvl(d.bonif_por_reemplazo, ' ') bonifporreemplazo, nvl(to_char(d.diferencia_por_reemplazo), ' ') diferenciaxreemplazo, nvl(d.r_dsp_nombre, ' ') rdspnombre, d.fechaUltVac, d.perActualVac, d.perUltimaVac FROM tbl_pla_empleado a, tbl_sec_unidad_ejec b, (select a.emp_id, remp_id, to_char(a.periodof_inicio, 'dd/mm/yyyy') periodof_inicio, to_char(a.periodof_final, 'dd/mm/yyyy') periodof_final, a.dias_tiempo, a.dias_dinero, a.observacion, a.acumulado_salario, a.acumulado_gasto_rep, /*decode(a.tipo, 'TI', 'DP', 'DI', 'VR', 'AB')*/ a.tipo tipo_vacacion, a.r_provincia, a.r_sigla, a.r_tomo, a.r_asiento, a.r_num_empleado, a.bonif_por_reemplazo, a.diferencia_por_reemplazo, (c.primer_nombre||' '||decode(c.sexo,'F', decode(c.apellido_casada, null, c.primer_apellido, decode(c.usar_apellido_casada, 'S', 'DE' || c.apellido_casada, c.primer_apellido)), c.primer_apellido)) r_dsp_nombre, (case when a.periodof_inicio is not null and a.periodof_final is not null and a.dias_tiempo is not null and a.dias_dinero is not null then 1 else 0 end) val1, nvl((select count(*) from tbl_pla_det_vacacion x where x.emp_id = b.emp_id and x.cod_compania = "+(String) session.getAttribute("_companyId")+" and x.fecha_final > to_date(a.periodof_inicio, 'dd/mm/yyyy')), 0) count_det_vacacion, a.estado, a.contratar_reemplazo, a.cargo_reemplazo rCargo, d.denominacion rCargoDesc, to_char(a.fecha_solicitud, 'dd/mm/yyyy') fechaCreacion, nvl(a.fecha_ult_vac,' ') fechaUltVac, a.per_actual_vac perActualVac, a.per_ultima_vac perUltimaVac from tbl_pla_sol_vacacion a, tbl_pla_empleado b, tbl_pla_empleado c, tbl_pla_cargo d where a.compania = "+(String) session.getAttribute("_companyId")+" and a.emp_id = "+empId + " and a.anio = "+anio+" and a.codigo = "+codigo+" and a.estado = 'AP' and a.compania = b.compania and a.emp_id = b.emp_id and a.remp_id = c.emp_id(+) and a.cargo_reemplazo = d.codigo(+) and a.compania = d.compania(+)) d, tbl_pla_cargo e WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.unidad_organi = b.codigo and a.compania = b.compania and a.emp_id = d.emp_id and a.cargo = e.codigo and a.compania = e.compania";
				System.out.println("sql...\n"+sql);
				del = (Empleado) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Empleado.class);
			}
    }
  // }
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title="Aprobar/Rechazar Solicitud de Vacaciones - "+document.title;

function doAction(){newHeight();
}

function doSubmit(baction)
{
	 if((document.form1.fecha_ini.value=='') || (document.form1.fecha_fin.value==''))
		  {
		  alert('No hay fecha registrada para esta solicitud..  Revisar...');
	  } else {


	document.form1.baction.value=baction;
	document.form1.submit();
	}
}


function selEmpleado(){
	abrir_ventana1('../common/search_empleado.jsp?fp=reg_vacaciones');
}

function addPert()
{
	var emp_id = document.form1.emp_id.value;
  abrir_ventana1("../common/search_empleado_otros.jsp?fp=aprobar_rechazar_solicitud_vac&emp_id="+emp_id);
}


function setFinalDate(){
	var f_ini = document.form1.fecha_ini.value;
	var dias = document.form1.tiempo_sol.value;
	var empId = document.form1.emp_id.value;
	var dif = dias - 1;
	var x = getDBData('<%=request.getContextPath()%>','1','tbl_pla_sol_vacacion','emp_id='+empId+' and to_date(to_char(periodof_inicio, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') >= to_date(\''+f_ini+'\',\'dd/mm/yyyy\') and dias_tiempo > 0 and estado in (\'PR\', \'AP\', \'PA\') and compania = <%=(String) session.getAttribute("_companyId")%>','');
	if(x=='1') alert('La persona ya tiene registrada vacaciones para esta fecha inicial! ...Se modificará la fecha Final...');
	var f_fin = getDBData('<%=request.getContextPath()%>','to_char(to_date (\''+f_ini+'\', \'dd/mm/yyyy\') + '+dif+', \'dd/mm/yyyy\')','dual','','');
	document.form1.fecha_fin.value = f_fin ;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="VACACIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
      <table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%
			fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
			%>
      <%=fb.formStart(true)%>
      <%=fb.hidden("mode",mode)%>
      <%=fb.hidden("baction","")%>
      <%=fb.hidden("errCode","")%>
      <%=fb.hidden("errMsg","")%>
      <%=fb.hidden("fg",fg)%>
      <%=fb.hidden("fp",fp)%>
      <%=fb.hidden("anio",anio)%>
      <%=fb.hidden("codigo",codigo)%>
      <%=fb.hidden("empId",empId)%>
      <%=fb.hidden("clearHT","")%>
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
      <tr class="TextRow02">
        <td colspan="4">&nbsp;</td>
      </tr>
        <tr class="TextPanel">
          <td colspan="4">Datos del Empleado</td>
        </tr>
        <tr class="TextRow01">
          <td>Empleado</td>
          <td colspan="3">
          <%=fb.hidden("emp_id",del.getEmpId())%>
          <%=fb.hidden("cargo",del.getCargo())%>
          <%=fb.hidden("segundo_nombre",del.getSegundoNombre())%>
          <%=fb.hidden("segundo_apellido",del.getSegundoApellido())%>
          <%=fb.textBox("primer_nombre",del.getPrimerNombre(),false,false,true,30)%>
          <%=fb.textBox("primer_apellido",del.getPrimerApellido(),false,false,true,30)%>
					<%=fb.textBox("provincia",del.getProvincia(),false,false,true,2)%>-
          <%=fb.textBox("sigla",del.getSigla(),false,false,true,3)%>-
          <%=fb.textBox("tomo",del.getTomo(),false,false,true,5)%>-
          <%=fb.textBox("asiento",del.getAsiento(),false,false,true,6)%>
          <%//=fb.button("buscar","...",false,false,"","","onClick=\"javascript:selEmpleado()\"")%>
          </td>
        </tr>
        <tr class="TextRow01" >
          <td>No. Empleado</td>
          <td><%=fb.textBox("num_empleado",del.getNumEmpleado(),false,false,true,5)%></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr class="TextRow01" >
          <td>Unidad Admin.:</td>
          <td colspan="3">
					<%=fb.textBox("unidad_organi",del.getUnidadOrgani(),false,false,true,5)%>
          <%=fb.textBox("unidad_organi_desc",del.getUnidadOrganiDesc(),false,false,true,50)%>
          </td>
        </tr>
        <tr class="TextRow01">
          <td>Cargo que desempeña:</td>
          <td>
					<%=fb.textBox("cargo_desc", del.getCargoDesc(),false,false,true,50)%>
					<%//=fb.select("anio","RV=REGISTRAR VACACIONES",del.getanio())%></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr class="TextPanel">
          <td colspan="4">&nbsp;</td>
        </tr>
        <tr>
        <td colspan="4"><table width="100%">
        <tr>
          <td colspan="2" align="center" class="TextHeader02">DETALLE DE LA SOLICITUD DE VACACIONES</td>
          <td colspan="2" align="center" class="TextHeader02">USO EXCLUSIVO DE PERSONAL</td>
          <td colspan="2" align="center" class="TextHeader02">DATOS DE REEMPLAZO</td>
        </tr>
        <tr class="TextRow01">
          <td>Fecha Solicitud:</td>
          <td><%=fb.textBox("fecha_solicitud",del.getFechaCreacion(),false,false,true,10)%></td>
          <td>Fecha Ingreso:</td>
          <td><%=fb.textBox("fecha_ingreso",del.getFechaIngreso(),false,false,true,10)%></td>
          <td>Contratar Reemplazo?<%=fb.checkbox("contratar_reemplazo",del.getContratarReemplazo(), (del.getContratarReemplazo()!=null && del.getContratarReemplazo().equals("S")? true:false), viewMode)%></td>
          <td>&nbsp;</td>
        </tr>
        <tr class="TextRow01">
          <td>Estado:</td>
          <%  if (mode.equalsIgnoreCase("add"))
  { %>
          <td><%=fb.select("estado","AP=APROBADA,RE=RECHAZADA",del.getEstado(), false, false, 0, "text10", "", "")%></td>
          <% } else { %>

          <td><%=fb.select("estado","AP=APROBADA",del.getEstado(), false, false, 0, "text10", "", "")%></td>
          <% } %>
          <td>Fecha Ult. Vac.:</td>

          <td colspan="2"><%=fb.textBox("fecha_ult_vac",del.getFechaUltVac(),false,false,viewMode,30)%></td>
          <td>Reemplazo :<%=fb.textBox("r_dsp_nombre",del.getRDspNombre(),false,false,true,35)%><%=fb.button("btnpert","...",true,false,null,null,"onClick=\"javascript:addPert()\"")%></td>
        </tr>
        <tr class="TextRow01">
          <td>Motivo:</td>
          <td><%=fb.textarea("motivo_rechazo",del.getMotivoRechazo(),false,false,viewMode,30,2,"text10","","")%></td>
          <td>Peri&oacute;do Actual:</td>
          <td><%=fb.textBox("per_actual_vac",del.getPerActualVac(),false,false,viewMode,10)%>
          </td>
          <td>&nbsp;</td>
          <td>
					<%=fb.hidden("r_emp_id",del.getREmpId())%>
					<%=fb.textBox("r_num_empleado",del.getRNumEmpleado(),false,false,true,5)%>
          <%=fb.textBox("r_provincia",del.getRProvincia(),false,false,true,5)%>
          <%=fb.textBox("r_sigla",del.getRSigla(),false,false,true,5)%>
          <%=fb.textBox("r_tomo",del.getRTomo(),false,false,true,5)%>
	  <%=fb.textBox("r_asiento",del.getRAsiento(),false,false,true,6)%>
          </td>
        </tr>
        <tr class="TextRow01">
          <td colspan="2" align="center" class="TextHeader02">FORMA DE PAGO/TIEMPO SOL.</td>
          <td>Peri&oacute;do Ult. Vac.:</td>
          <td><%=fb.textBox("per_ultima_vac",del.getPerUltimaVac(),false,false,viewMode,10)%>
          </td>
          <td>Cargo Desempe&ntilde;a:</td>
          <td>
					<%=fb.textBox("r_cargo",del.getRCargo(),false,false,true,6)%>
					<%=fb.textBox("r_cargo_desc",del.getRCargoDesc(),false,false,true,30)%>
          </td>
        </tr>
        <tr class="TextRow01">
          <td>&nbsp;D&iacute;as Solicitados</td>
          <td><%=fb.textBox("tiempo_sol",del.getTiempoSol(),false,false,false,5)%>Tiempo</td>
          <td></td>
          <td></td>
          <td>Tipo y Monto de la Bonific.</td>
          <td>
          <%=fb.select("bonif_por_reemplazo","A=Jefe,B=Supervisor,C=Categoria,D=No Recibe",del.getBonifPorReemplazo(), false, false, 0, "text10", "", "")%>
          $
          <%=fb.decBox("diferencia_x_reemplazo",(del.getDiferenciaXReemplazo()!=null && !del.getDiferenciaXReemplazo().equals("") && !del.getDiferenciaXReemplazo().equals(" ")?CmnMgr.getFormattedDecimal(del.getDiferenciaXReemplazo()):""),false,false,true,7, 8.2,null,null,"","",false,"")%>
					<%=fb.hidden("r_total_periodos",del.getRTotalPeriodos())%>
          <%=fb.hidden("r_monto_periodo",del.getRMontoXPeriodo())%>
          </td>
        </tr>
        <tr class="TextRow01">
          <td></td>
          <td><%=fb.textBox("tiempo_sol_dinero",del.getTiempoSolDinero(),false,false,false,5)%>Dinero</td>
          <td></td>
          <td></td>
          <td colspan="2" rowspan="4">Comentario:<br>&nbsp;<%=fb.textarea("comentario",del.getComentario(),false,false,viewMode,60,2,"","","")%></td>
        </tr>
        <tr class="TextRow01">
          <td>Fecha inicio:</td>
          <td>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="nameOfTBox1" value="fecha_ini" />
          <jsp:param name="valueOfTBox1" value="<%=del.getFechaIni()%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="onChange" value="setFinalDate();" />
          <jsp:param name="jsEvent" value="setFinalDate()"/>
          </jsp:include>
          </td>
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="TextRow01">
          <td>Fecha final:</td>
          <td>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />
          <jsp:param name="nameOfTBox1" value="fecha_fin" />
          <jsp:param name="valueOfTBox1" value="<%=del.getFechaFin()%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
          <jsp:param name="clearOption" value="true" />
          </jsp:include>
          </td>
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr class="TextRow01">
          <td>Forma de Pago</td>
          <td><%=fb.select("tipo_vacacion","TI=TIEMPO,DI=DINERO,TD=TIEMPO Y DINERO",del.getTipoVacacion(), false, false, 0, "text10", "", "")%></td>
          <td colspan="2">&nbsp;</td>
        </tr>
        </table></td></tr>
        <tr class="TextRow02">
          <td colspan="4" align="right">
            <%=fb.button("save","Guardar",false,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
        <tr>
          <td colspan="4">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
  //String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String errCode = "";
  String errMsg = "";
	cdo = new CommonDataObject();
	cdo.addColValue("anio", request.getParameter("anio"));
	cdo.addColValue("codigo", request.getParameter("codigo"));
	cdo.addColValue("emp_id", request.getParameter("emp_id"));
	cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
	if(request.getParameter("motivo_rechazo")!=null && !request.getParameter("motivo_rechazo").equals("")) cdo.addColValue("motivo_rechazo", request.getParameter("motivo_rechazo"));
	if(request.getParameter("fecha_ini")!=null && !request.getParameter("fecha_ini").equals("")) cdo.addColValue("periodof_inicio", request.getParameter("fecha_ini"));
	if(request.getParameter("fecha_fin")!=null && !request.getParameter("fecha_fin").equals("")) cdo.addColValue("periodof_final", request.getParameter("fecha_fin"));
	if(request.getParameter("tiempo_sol")!=null && !request.getParameter("tiempo_sol").equals("")) cdo.addColValue("dias_tiempo", request.getParameter("tiempo_sol"));
	if(request.getParameter("tiempo_sol_dinero")!=null && !request.getParameter("tiempo_sol_dinero").equals("")) cdo.addColValue("dias_dinero", request.getParameter("tiempo_sol_dinero"));
	if(request.getParameter("estado")!=null && !request.getParameter("estado").equals("")) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("fecha_ult_vac")!=null && !request.getParameter("fecha_ult_vac").equals("")) cdo.addColValue("fecha_ult_vac", request.getParameter("fecha_ult_vac"));
	if(request.getParameter("per_actual_vac")!=null && !request.getParameter("per_actual_vac").equals("")) cdo.addColValue("per_actual_vac", request.getParameter("per_actual_vac"));
	if(request.getParameter("per_ultima_vac")!=null && !request.getParameter("per_ultima_vac").equals("")) cdo.addColValue("per_ultima_vac", request.getParameter("per_ultima_vac"));
	if(request.getParameter("comentario")!=null && !request.getParameter("comentario").equals("")) cdo.addColValue("observacion", request.getParameter("comentario"));
	if(request.getParameter("contratar_reemplazo")!=null) cdo.addColValue("contratar_reemplazo", "S");
	else cdo.addColValue("contratar_reemplazo","N");
	if(request.getParameter("r_emp_id")!=null && !request.getParameter("r_emp_id").equals("")) cdo.addColValue("remp_id", request.getParameter("r_emp_id"));
	if(request.getParameter("r_num_empleado")!=null && !request.getParameter("r_num_empleado").equals("")) cdo.addColValue("r_num_empleado", request.getParameter("r_num_empleado"));
	if(request.getParameter("r_provincia")!=null && !request.getParameter("r_provincia").equals("")) cdo.addColValue("r_provincia", request.getParameter("r_provincia"));
	if(request.getParameter("r_sigla")!=null && !request.getParameter("r_sigla").equals("")) cdo.addColValue("r_sigla", request.getParameter("r_sigla"));
	if(request.getParameter("r_tomo")!=null && !request.getParameter("r_tomo").equals("")) cdo.addColValue("r_tomo", request.getParameter("r_tomo"));
	if(request.getParameter("r_asiento")!=null && !request.getParameter("r_asiento").equals("")) cdo.addColValue("r_asiento", request.getParameter("r_asiento"));
	if(request.getParameter("bonif_por_reemplazo")!=null && !request.getParameter("bonif_por_reemplazo").equals("")) cdo.addColValue("bonif_por_reemplazo", request.getParameter("bonif_por_reemplazo"));
	if(request.getParameter("diferencia_x_reemplazo")!=null && !request.getParameter("diferencia_x_reemplazo").equals("")) cdo.addColValue("diferencia_por_reemplazo", request.getParameter("diferencia_x_reemplazo"));
	if(request.getParameter("r_cargo")!=null && !request.getParameter("r_cargo").equals("")) cdo.addColValue("cargo_reemplazo", request.getParameter("r_cargo"));
	if(request.getParameter("tipo_vacacion")!=null && !request.getParameter("tipo_vacacion").equals("")) cdo.addColValue("tipo", request.getParameter("tipo_vacacion"));

		System.out.println("/* - - - - - - - - - - - - - - - - - - - - - - tipo = "+request.getParameter("tipo_vacacion"));

  if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
  {
		VacMgr.updateSolicitudVac(cdo);
  }
  session.removeAttribute("DI");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{
<%
if (VacMgr.getErrCode().equals("1")){
%>
	alert('<%=VacMgr.getErrMsg()%>');
<%
	//if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/list_delivery.jsp?fg="+fg+"&fp="+fg)){
%>
	 //window.opener.parent.location = '<%//=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/sol_vacaciones_aprob.jsp")%>';
	//window.close();
<%
	//} else {
%>
	  //window.opener.parent.location = '<%//=request.getContextPath()%>/rhplanilla/sol_vacaciones_aprob.jsp';
	  window.opener.location.reload(true);
	  setTimeout('editMode()',500);
		//window.close();
<%
	//}
} else throw new Exception(VacMgr.getErrMsg());
%>

}
function editMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&mode=<%=mode%>&empId=<%=empId%>&codigo=<%=codigo%>&anio=<%=anio%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
