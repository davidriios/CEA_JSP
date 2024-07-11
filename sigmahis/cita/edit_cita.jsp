<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Cita"%>
<%@ page import="issi.admision.CitaProcedimiento"%>
<%@ page import="issi.admision.CitaPersonal"%>
<%@ page import="issi.admision.CitaEquipo"%>
<%@ page import="issi.admision.ProcedDiagnostico"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="CitaMgr" scope="page" class="issi.admision.CitaMgr" />
<jsp:useBean id="iProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProc" scope="session" class="java.util.Vector" />
<jsp:useBean id="vProcDiag" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iPers" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPers" scope="session" class="java.util.Vector" />
<jsp:useBean id="iEqui" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEqui" scope="session" class="java.util.Vector" />
<jsp:useBean id="htProc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htProcKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htPersonal" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htPersonalKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htEquipo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htEquipoKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vTempDiag" scope="session" class="java.util.Vector" />
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
CitaMgr.setConnection(ConMgr);

Cita cita = new Cita();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdoParam = new CommonDataObject();
ArrayList al = new ArrayList();
ArrayList alDiag = new ArrayList();
ArrayList alTipo = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cdc_tipo_cirugia order by 1",CommonDataObject.class);
String key = "";
StringBuffer sbSql = null;
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String change = request.getParameter("change");
String type = request.getParameter("type");
String fp = request.getParameter("fp");//quirurgico => null, imagenologia => imagenologia
String fg = request.getParameter("fg");//trasladar, cancelar
String citasSopAdm = request.getParameter("citasSopAdm");
String citasAmb = request.getParameter("citasAmb");
String pacId = request.getParameter("pacId");
int procLastLineNo = 0;
int procDiagLastLineNo = 0;
int persLastLineNo = 0;
int equiLastLineNo = 0;
String procKey = request.getParameter("procKey");
if (fp == null) fp = "";
if (fg == null) fg = "";
if (citasSopAdm == null) citasSopAdm = "";
if (citasAmb == null) citasAmb = "";
if (tab == null) tab = "0";
boolean viewMode = false;
 
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view"))viewMode = true;

if (fg.equalsIgnoreCase("trasladar") || fg.equalsIgnoreCase("cancelar")) viewMode = true;
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("procDiagLastLineNo") != null) procDiagLastLineNo = Integer.parseInt(request.getParameter("procDiagLastLineNo"));
if (request.getParameter("persLastLineNo") != null) persLastLineNo = Integer.parseInt(request.getParameter("persLastLineNo"));
if (request.getParameter("equiLastLineNo") != null) equiLastLineNo = Integer.parseInt(request.getParameter("equiLastLineNo"));
if (procKey == null) procKey = "";

String tmpPers = request.getParameter("tmpPers")==null?"":request.getParameter("tmpPers");
String tmpProc = request.getParameter("tmpProc")==null?"":request.getParameter("tmpProc");

boolean allowBackdate = false;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("edit") || mode.equalsIgnoreCase("view"))
	{
		if (codCita == null || fechaCita == null) throw new Exception("La Cita no es v�lida. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'CDC_CITA_BACKDATE'),'N') as backdate,nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'CDC_CITA_EDIT_FECHA'),'N') as editFecha,nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'ADM_TAB_INACTIVO_CITAS'),'1') as tabCitaInactivo,case when '0' in ( select column_value  from table(select split((select param_value from tbl_sec_comp_param where compania =");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and param_name='ADM_TAB_INACTIVO_CITAS'),',') from dual )) then 'S' else 'N' end as tabView0,case when '1' in ( select column_value  from table(select split((select param_value from tbl_sec_comp_param where compania =");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and param_name='ADM_TAB_INACTIVO_CITAS'),',') from dual )) then 'S' else 'N' end as tabView1,case when '2' in ( select column_value  from table(select split((select param_value from tbl_sec_comp_param where compania =");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and param_name='ADM_TAB_INACTIVO_CITAS'),',') from dual )) then 'S' else 'N' end as tabView2,case when '3' in ( select column_value  from table(select split((select param_value from tbl_sec_comp_param where compania =");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and param_name='ADM_TAB_INACTIVO_CITAS'),',') from dual )) then 'S' else 'N' end as tabView3  from dual");
		  cdoParam = SQLMgr.getData(sbSql.toString());
		  if((citasSopAdm.trim().equals("S")||citasSopAdm.trim().equals("Y"))||(citasAmb.trim().equals("S"))) cdoParam.getColValue("tabView3","");
		  else {cdoParam.addColValue("tabView0","N");cdoParam.addColValue("tabView1","N");cdoParam.addColValue("tabView2","N");cdoParam.addColValue("tabView3","N");}
		  
		  
		if (cdoParam.getColValue("backdate").equalsIgnoreCase("Y") || cdoParam.getColValue("backdate").equalsIgnoreCase("S")) allowBackdate = true; 
		sbSql = new StringBuffer();
		sbSql.append("select a.codigo, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, nvl(to_char(a.fec_nacimiento,'dd/mm/yyyy'),' ') as fecNacimiento, a.cod_paciente as codPaciente, cod_medico codMedico, nvl(nombre_medico,(select  aa.primer_apellido||decode(aa.segundo_apellido,null,'',' '||aa.segundo_apellido)||' '||decode(aa.sexo,'F',decode(aa.apellido_de_casada,null,'',' '||aa.apellido_de_casada)) from tbl_adm_medico aa where aa.codigo= a.cod_medico)) as medicoNombre, to_char(a.fecha_cita,'dd/mm/yyyy') as fechaCita, to_char(a.hora_cita,'hh12:mi AM') as horaCita, nvl(to_char(a.hora_llamada,'hh12:mi AM'),' ') as horaLlamada, a.centro_servicio as centroServicio, a.cod_tipo as codTipo, a.estado_cita as estadoCita, nvl((select decode(estado,null,' ','A','ACTIVA','P','PRE-ADMISION','E','EN ESPERA',estado) from tbl_adm_admision where pac_id=a.pac_id and secuencia=a.admision),' ') as estadoAdmision, nvl(a.persona_reserva,' ') as personaReserva, nvl(a.forma_reserva,' ') as formaReserva, nvl(a.motivo_cita,' ') as motivoCita, nvl(a.anestesia,' ') as anestesia, nvl(a.observacion,' ') as observacion, nvl(a.habitacion,' ') as habitacion, nvl(to_char(a.compania_hab),' ') as companiaHab");
		//sbSql.append(", nvl(to_char(a.empresa),' ') as empresa, nvl((select nombre from tbl_adm_empresa where codigo=a.empresa),' ') as empresaNombre");
		sbSql.append(", nvl(to_char(decode(a.admision,null,a.empresa,(select empresa from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admision and nvl(estado,'A') = 'A' and prioridad = 1 and rownum = 1))),' ') as empresa, nvl((select nombre from tbl_adm_empresa where codigo = decode(a.admision,null,a.empresa,(select empresa from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admision and nvl(estado,'A') = 'A' and prioridad = 1 and rownum = 1))),' ') as empresaNombre");
		sbSql.append(", to_char(a.fecha_creacion,'dd/mm/yyyy') as fechaCreacion, a.usuario_creacion as usuarioCreacion, a.fecha_modif as fechaModif, a.usuario_modif as usuarioModif, nvl(to_char(a.hora_est),' ') as horaEst, nvl(to_char(a.min_est),' ') as minEst, decode(a.pac_id,null,nvl(a.nombre_paciente,''),(select nombre_paciente from vw_adm_paciente where pac_id = a.pac_id)) as nombrePaciente, nvl(a.cita_cirugia,' ') as citaCirugia, nvl(a.hosp_amb,' ') as hospAmb, nvl(a.destino_pat,' ') as destinoPat, a.compania, nvl(to_char(a.provincia),' ') as provincia, nvl(a.sigla,' ') as sigla, nvl(to_char(a.tomo),' ') as tomo, nvl(to_char(a.asiento),' ') as asiento, nvl(a.d_cedula,' ') as dCedula, nvl(to_char(a.pac_id),'') as pacId, nvl(probable_hospitalizacion,' ') as probableHospitalizacion, nvl(persona_q_llamo,' ') as personaQLlamo, nvl(tipo_paciente,'OUT') as tipoPaciente, nvl(telefono,' ') as telefono, nvl(cuarto,' ') as cuarto, nvl(forma_reserva,'T') as formaReserva, a.nombre_medico_externo nombreMedExterno,a.admision,case when a.provincia is null then a.pasaporte else '' end as pasaporte, nvl(a.motivo_cancelacion,' ') as motivoCancelacion, nvl(a.traslado_motivo,' ') as trasladoMotivo, nvl(a.usuario_traslado,' ') as usuarioTraslado, nvl(a.usuario_cancelacion,' ') as usuarioCancelacion, nvl((select apartado_postal from tbl_adm_paciente where pac_id = a.pac_id and rownum=1),' ') as codigoReferencia, nvl(to_char(nvl((select f_nac from vw_adm_paciente where pac_id = a.pac_id),a.fec_nacimiento),'dd/mm/yyyy'),' ') as fechaT,nvl(to_char(a.hora_fin_cirugia,'hh12:mi AM'),' ') as horaFinCirugia,nvl(to_char(a.hora_cirugia,'hh12:mi AM'),' ') as  horaCirugia,nvl((select to_char(l.fecha_in,'dd/mm/yyyy hh12:mi:ss am') as fecha_in_sop from tbl_cdc_io_log l where l.log_id_ref is not null and l.cds = get_sec_comp_param(a.compania,'CDC_CDS_IN') and  l.cod_cita=a.codigo and l.pac_id=a.pac_id  and l.fecha_registro=a.fecha_registro ),' ') horaEntSop,nvl((select to_char(l.fecha_out,'dd/mm/yyyy hh12:mi:ss am') as fecha_out_sop from tbl_cdc_io_log l where l.log_id_ref is not null and l.cds = get_sec_comp_param(a.compania,'CDC_CDS_IN')and  l.cod_cita=a.codigo and l.pac_id=a.pac_id  and l.fecha_registro=a.fecha_registro ),' ') as horaSalSop from tbl_cdc_cita a where a.codigo = ");
		
		sbSql.append(codCita); 
		sbSql.append(" and trunc(a.fecha_registro)=to_date('");
		sbSql.append(fechaCita);
		sbSql.append("','dd/mm/yyyy')");
		System.out.println("sql Cita=\n"+sbSql.toString());
		cita = (Cita) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Cita.class);
		String appendFilter = "";

		if (change == null)
		{
			iProc.clear();
			vProc.clear();
			vProcDiag.clear();
			iPers.clear();
			vPers.clear();
			iEqui.clear();
			vEqui.clear();
			vTempDiag.clear();

			sbSql = new StringBuffer();
			sbSql.append("select a.codigo, a.cod_cita as codCita, to_char(a.fecha_cita,'dd/mm/yyyy') as fechaCita, a.procedimiento, (select nvl(observacion,descripcion) from tbl_cds_procedimiento where codigo=a.procedimiento) as procedimientoDesc, nvl(a.observacion,' ') as observacion, a.tipo_c as tipoC, nvl(a.usuario_creacion,' ') as usuarioCreacion, to_char(nvl(a.fecha_creacion,sysdate),'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, nvl(a.usuario_modif,' ') as usuarioModif, to_char(nvl(a.fecha_modif,sysdate),'dd/mm/yyyy hh24:mi:ss') as fechaModif, 'U' as status,a.prioridad from tbl_cdc_cita_procedimiento a where a.cod_cita=");
			sbSql.append(codCita);
			sbSql.append(" and trunc(a.fecha_cita)=to_date('");
			sbSql.append(fechaCita);
			sbSql.append("','dd/mm/yyyy') order by 1");
			System.out.println("SQL PROCEDIMIENTOS:\n"+sbSql.toString());
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CitaProcedimiento.class);
			procLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CitaProcedimiento obj = (CitaProcedimiento) al.get(i-1);
				obj.setKey(""+i,3);

				//Vector vTempDiag = null;
				//vTempDiag = null;
				if (fp.equalsIgnoreCase("imagenologia")) obj.setProcedDiagnostico(null);
				else
				{
					sbSql = new StringBuffer();
					sbSql.append("select a.codigo, a.cod_procedimiento as codProcedimiento, a.cod_cita as codCita, to_char(a.fecha_cita,'dd/mm/yyyy') as fechaCita, a.diagnostico, a.observacion, (select nvl(observacion,nombre) from tbl_cds_diagnostico where codigo=a.diagnostico) as diagnosticoDesc, 'U' as status from tbl_cdc_cita_proc_diag a where a.cod_cita=");
					sbSql.append(codCita);
					sbSql.append(" and trunc(a.fecha_cita)=to_date('");
					sbSql.append(fechaCita);
					sbSql.append("','dd/mm/yyyy') and a.cod_procedimiento=");
					sbSql.append(obj.getCodigo());
					sbSql.append(" order by 1");
					//System.out.println("progDiagnostico="+sbSql.toString());
					alDiag = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),ProcedDiagnostico.class);
					//vTempDiag = new Vector();
					for (int j=1; j<=alDiag.size(); j++)
					{
						ProcedDiagnostico det = (ProcedDiagnostico) alDiag.get(j-1);
						det.setKey(""+j,3);

						try
						{
							obj.addProcedDiagnostico(det);
							vTempDiag.addElement(det.getDiagnostico());
							System.out.println(":::::::::::::::::::::::::::::::: ADDING INNER.....");
						}
						catch(Exception e)
						{
							System.out.println(e.getMessage());
						}
					}//for diag
					obj.setDiagLastLineNo(alDiag.size());
				}
				try
				{
					iProc.put(obj.getKey(),obj);
					vProc.addElement(obj.getProcedimiento());
					if (!fp.equalsIgnoreCase("imagenologia")) vProcDiag.put(obj.getKey(),vTempDiag);
					
					System.out.println(":::::::::::::::::::::::::::::::: ADDING.....");
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}


			sbSql = new StringBuffer();
			if (tmpPers.trim().equals("")){
			sbSql.append("select a.codigo, a.cod_cita as codCita, to_char(a.fecha_cita,'dd/mm/yyyy') as fechaCita, a.funcion, (select descripcion from tbl_cds_funcion where codigo=a.funcion) as funcionDesc, a.medico, decode((select tipo_personal from tbl_cds_funcion where codigo=a.funcion),'M',(select primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada))||', '||primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre) from tbl_adm_medico where codigo=a.medico),'E',(select primer_nombre||' '||decode(sexo,'F',decode(apellido_casada,null,primer_apellido,decode(usar_apellido_casada,'S','DE '||apellido_casada,primer_apellido)),primer_apellido) from tbl_pla_empleado where emp_id=a.emp_id),'S',(select nombre from tbl_adm_empresa where codigo=medico),' ') as nombre, nvl(a.observacion,' ') as observacion, 'U' as status, (select tipo_personal from tbl_cds_funcion where codigo=a.funcion) as tipoPersonal, decode(a.emp_compania,null,' ',''||a.emp_compania) as empCompania, decode(a.emp_provincia,null,' ',''||a.emp_provincia) as empProvincia, nvl(a.emp_sigla,' ') as empSigla, decode(a.emp_tomo,null,' ',''||a.emp_tomo) as empTomo, decode(a.emp_asiento,null,' ',''||a.emp_asiento) as empAsiento, decode(a.emp_id,null,' ',''||a.emp_id) as empId,nvl(a.sociedad,'N') as sociedad from tbl_cdc_personal_cita a where a.cod_cita=");
			sbSql.append(codCita);
			sbSql.append(" and trunc(a.fecha_cita)=to_date('");
			sbSql.append(fechaCita);
			sbSql.append("','dd/mm/yyyy') order by 1");
			}
			else{
				sbSql.append("with tt as ( ");
				sbSql.append(" select '0' codigo, ");
				sbSql.append(codCita);
				sbSql.append(" as codCita, '");
				sbSql.append(fechaCita);
				sbSql.append("' fechaCita, t.cod_funcion as funcion, (select descripcion from tbl_cds_funcion where codigo=t.cod_funcion) as funcionDesc, '' medico, '' as nombre, '' as observacion, 'U' as status, (select tipo_personal from tbl_cds_funcion where codigo=t.cod_funcion) as tipoPersonal , '' as empCompania,'' as empProvincia, '' as empSigla, '' as empTomo, '' as empAsiento, '' as empId, cantidad from tbl_cds_personal_x_proc t where t.cod_procedimiento in( ");
				sbSql.append(tmpProc);
				sbSql.append(") )  ");
				sbSql.append(" select tt.* from tt connect by level <= tt.cantidad ");
				sbSql.append(" start with tt.cantidad = (select cantidad from tt where rownum = 1) order by 4 ");
			}

			System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::SQL PERSONAL:\n"+sbSql.toString());
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CitaPersonal.class);
			persLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CitaPersonal obj = (CitaPersonal) al.get(i-1);
				obj.setKey(""+i,3);

				try
				{
					iPers.put(obj.getKey(),obj);
					vPers.addElement(obj.getMedico());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}


			sbSql = new StringBuffer();
			sbSql.append("select a.cod_cita as codCita, to_char(a.fecha_cita,'dd/mm/yyyy') as fechaCita, a.uso_codigo as usoCodigo, a.compania, nvl(a.cantidad,0) as cantidad, nvl(a.observacion,' ') as observacion, nvl((select descripcion from tbl_sal_uso where compania=a.compania and codigo=a.uso_codigo),' ') as usoDesc, 'U' as status from tbl_cdc_equipo_cita a where a.cod_cita=");
			sbSql.append(codCita);
			sbSql.append(" and trunc(a.fecha_cita)=to_date('");
			sbSql.append(fechaCita);
			sbSql.append("', 'dd/mm/yyyy') order by 7,3");
			//System.out.println("SQL EQUIPO:\n"+sbSql.toString());
			al  = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CitaEquipo.class);
			equiLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CitaEquipo obj = (CitaEquipo) al.get(i-1);
				obj.setKey(""+i,3);

				try
				{
					iEqui.put(obj.getKey(),obj);
					vEqui.addElement(obj.getUsoCodigo());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Editar Cita - '+document.title;
function showPacienteList(i)
{
	
	if(i==1)abrir_ventana1('../common/search_paciente.jsp?fp=edita_cita');
	else if(i==2){var pacId= document.form0.pacId.value; abrir_ventana1('../common/sel_paciente.jsp?fp=edit_cita&cod_paciente='+pacId);}
	
}

function doAction()
{CalculateAge();
<% if (type != null && type.equals("1")) { %>
	abrir_ventana1('../common/check_procedimiento.jsp?fp=citas<%=fp%>&mode=<%=mode%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&tab=<%=tab%>&procLastLineNo=<%=procLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&equiLastLineNo=<%=equiLastLineNo%>&cds=<%=cita.getCentroServicio()%>&citasSopAdm=<%=citasSopAdm%>&citasAmb=<%=citasAmb%>');
<% } else if (type != null && type.equals("2")) { %>
	abrir_ventana1('../common/check_diagnostico.jsp?fp=citas<%=fp%>&mode=<%=mode%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&tab=<%=tab%>&procLastLineNo=<%=procLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&equiLastLineNo=<%=equiLastLineNo%>&procKey=<%=procKey%>');
<% } else if (type != null && type.equals("3")) { %>
	abrir_ventana1('../common/check_medico.jsp?fp=citas<%=fp%>&mode=<%=mode%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&tab=<%=tab%>&procLastLineNo=<%=procLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&equiLastLineNo=<%=equiLastLineNo%>');
<% } else if (type != null && type.equals("4")) { %>
	abrir_ventana1('../common/check_uso.jsp?fp=citas<%=fp%>&mode=<%=mode%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&tab=<%=tab%>&procLastLineNo=<%=procLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&equiLastLineNo=<%=equiLastLineNo%>');
<% } %>
}
function setProcKey(k){document.form1.procKey.value=eval('document.form1.key'+k).value;}
function checkPacId(){CalculateAge();if(document.form0.pacId.value!=''){document.form0.btnPaciente.focus();top.CBMSG.warning('No se puede cambiar los datos del paciente ya que el paciente est� registrado en el sistema!');return false;}return true;}
function validDateTime(){var cds=document.form0.cds.value;var room=document.form0.habitacion.value;if(eval('document.form0.habitacion_t'))room=document.form0.habitacion_t.value;var xDate=document.form0.fecha_cita.value;if(eval('document.form0.fecha_cita_t'))xDate=document.form0.fecha_cita_t.value;var xTime=document.form0.hora_cita.value;if(eval('document.form0.hora_cita_t'))xTime=document.form0.hora_cita_t.value;var hour=document.form0.hora_est.value;var min=document.form0.min_est.value;<% if (!allowBackdate) { %>
if(getDBData('<%=request.getContextPath()%>','case when to_date(\''+xDate+'\',\'dd/mm/yyyy\')<trunc(sysdate) then 1 else 0 end','dual','','')==1){top.CBMSG.warning('La nueva fecha es menor al d�a de hoy!');return false;}<% } %>  var filter='';if(cds!=null&&cds!='')filter='centro_servicio='+cds;if(filter!='')filter+=' and ';filter+='habitacion=\''+room+'\' and estado_cita not in (\'C\',\'T\') and (hora_cita = to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') or hora_final = to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) or ( hora_cita > to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_cita < to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) ) or ( hora_final > to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_final < to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) ) or ( hora_cita < to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_final > to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') + (('+hour+' + ('+min+' / 60)) / 24) ))';
filter+=' and not exists (select null from tbl_cdc_cita where codigo = <%=cita.getCodigo()%> and trunc(fecha_registro) = to_date(\'<%=cita.getFechaRegistro()%>\',\'dd/mm/yyyy\') and codigo = z.codigo and fecha_registro = z.fecha_registro)';
<% if (fg.equalsIgnoreCase("trasladar")) { %>
if(room==document.form0.habitacion.value&&xDate==document.form0.fecha_cita.value&&xTime==document.form0.hora_cita.value){	top.CBMSG.warning('Por favor indicar los datos de traslado!\nNota: Debe cambiar por lo menos un dato (Habitaci�n, Fecha o Hora)');return false;}
<% } %>
if(hasDBData('<%=request.getContextPath()%>','tbl_cdc_cita z',filter,'')){top.CBMSG.warning('La Programaci�n de la Cita choca con otras Citas Programadas.\nPor favor revise la programaci�n!');return false;}return true;}
function validLastTime(){var hour=parseInt(document.form0.hora_est.value,10);var min=parseInt(document.form0.min_est.value,10);if(hour+min<=0){top.CBMSG.warning('Verifique el Tiempo Total Approximado!');return false;}hour+=parseInt(min/60,10);min=min%60;document.form0.hora_est.value=hour;document.form0.min_est.value=min;return true;}
function getPersonal(k){if(getSelectedOptionTitle(eval('document.form2.funcion'+k))=='M'){abrir_ventana1('../common/search_medico.jsp?fp=citas_personal&index='+k);}else if(getSelectedOptionTitle(eval('document.form2.funcion'+k))=='S'){abrir_ventana1('../common/search_empresa.jsp?fp=citas_personal&index='+k);}else{var funcion=eval('document.form2.funcion'+k).value;abrir_ventana1('../common/search_empleado.jsp?fp=citas<%=fp%>&index='+k+'&funcion='+funcion);}}
function checkPersonal(k){if(getSelectedOptionTitle(eval('document.form2.funcion'+k))!=eval('document.form2.tipoPersonal'+k).value){eval('document.form2.medico'+k).value='';eval('document.form2.sociedad'+k).value='';eval('document.form2.empCompania'+k).value='';eval('document.form2.empProvincia'+k).value='';eval('document.form2.empSigla'+k).value='';eval('document.form2.empTomo'+k).value='';eval('document.form2.empAsiento'+k).value='';eval('document.form2.empId'+k).value='';eval('document.form2.tipoPersonal'+k).value='';eval('document.form2.nombre'+k).value='';}}
function validAdmision(){
	if(document.form0.admision.value==''){
		top.CBMSG.warning('Seleccione Admisi�n');
		return false;
	} else return true;
}

function showMedicoList(fg){abrir_ventana1('../common/search_medico.jsp?fp=citas&fg='+fg);}
function clearMedico(){document.form0.medico.value='';document.form0.nombre_medico.value='';}
function clearPaciente(){document.form0.pacId.value='';document.form0.nombrePaciente.value='';}
function selEmpresa(){abrir_ventana1('../common/search_empresa.jsp?fp=citas');}


$(function(){
  $("input[name='save']").click(function(c){
	
	  var size = document.form1.procSize.value;
	  var sizePers = document.form2.persSize.value;
	  var anestesia = $("#anestesia").val();
	  var anestesiologo = $("#anestesiologo").val();
	  var procedimientos = ["'0'"];
	  var funciones = [0];
	  var medicos = [0];
	  if (anestesia=="S"){
		  for (p=1; p<=size; p++){
			var procedimiento = eval('document.form1.procedimiento'+p).value;
			if(procedimiento) procedimientos.push("'"+procedimiento+"'");
		  }	
		  for (f=1; f<=sizePers; f++){
			var funcion = eval('document.form2.funcion'+f).value;
			var medico = eval('document.form2.medico'+f).value;
			if(funcion) funciones.push(funcion);
			if(medico)  medicos.push("'"+medico+"'");
		  }

		  if(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cds_funcion f',"f.codigo in ("+funciones+") and f.descripcion like '%ANESTESI%'",'') < 1 ) top.CBMSG.warning("Usted escogi� anestesia, porfavor recuerda suplir un anaestesiologo por lo menos!"); 
		  if(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cds_procedimiento',"codigo in("+procedimientos+") and tipo_maletin_anestesia is not null",'') < 1 ) top.CBMSG.warning("Cita o cupo marcado para usar anestesia, verificar CPT: no tiene configurado malet�n de anestesia!");
	  }
  });
  
  
  $("#tabTabdhtmlgoodies_tabView1_2").click(function(){
     var sizeProc = document.form1.procSize.value;
     var totPers = <%=iPers.size()%>
	 var procedimientos = [];
	 for (p=1; p<=sizeProc; p++){
		var procedimiento = eval('document.form1.procedimiento'+p).value;
		if(procedimiento) procedimientos.push("'"+procedimiento+"'");
	 }	
	
	 //if (!totPers && procedimientos.length ){
	 if (!totPers && procedimientos.length ){
	    window.location = "../cita/edit_cita.jsp?fp=&tab=2&mode=edit&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&procLastLineNo=<%=procLastLineNo%>&persLastLineNo=<%=persLastLineNo%>&equiLastLineNo=<%=equiLastLineNo%>&tmpPers=Y&tmpProc="+procedimientos+"&citasAmb=<%=citasAmb%>&citasSopAdm=<%=citasSopAdm%>";
	 }
	
	
	 //iProc
  });
  
  
  
});
function setCds(sObj){var cds=getSelectedOptionTitle(sObj,'<%=cita.getCentroServicio()%>');document.form0.cds.value=cds;}
function CalculateAge() {
	var fecha = document.form0.f_nac.value;
	if(fecha!='')
	{
		if(isValidateDate(document.form0.f_nac.value))
		{
			var sql = 'nvl(trunc(months_between(sysdate, to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0) || \' A&ntilde;os \' || nvl(mod(trunc(months_between(sysdate, to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0) || \' Meses \' || trunc(sysdate-add_months(to_date(\''+fecha+'\', \'dd/mm/yyyy\'),(nvl(trunc(months_between(sysdate,to_date(\''+fecha+'\', \'dd/mm/yyyy\'))/12),0)*12+nvl(mod(trunc(months_between(sysdate,to_date(\''+fecha+'\', \'dd/mm/yyyy\'))),12),0)))) || \' Dias \'';
			var data = splitRowsCols(getDBData('<%=request.getContextPath()%>',sql,'dual','',''));
			document.getElementById('lbl_edad').innerHTML = data;
		}else CBMSG.warning('Valor Invalido en Fecha Nacimiento!!');
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ADMISION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
      <tr>
        <td><!-- MAIN DIV START HERE -->
            <div id="dhtmlgoodies_tabView1">
              <!-- TAB0 DIV START HERE-->
              <div class="dhtmlgoodies_aTab">
                <table align="center" width="100%" cellpadding="0" cellspacing="1">
                  <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%> 
	<%=fb.hidden("tab","0")%> 
	<%=fb.hidden("mode",mode)%> 
	<%=fb.hidden("codCita",codCita)%>
	<%=fb.hidden("fechaCita",fechaCita)%> 
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
	<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
	<%=fb.hidden("equiLastLineNo",""+equiLastLineNo)%>
	<%=fb.hidden("procSize",""+iProc.size())%>
	<%=fb.hidden("persSize",""+iPers.size())%>
	<%=fb.hidden("equiSize",""+iEqui.size())%>
	<%=fb.hidden("cds",cita.getCentroServicio())%>
	<%=fb.hidden("citasSopAdm",citasSopAdm)%>
	<%=fb.hidden("citasAmb",citasAmb)%>
	
	
				  
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr >
                    <td  style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextPanel">
                          <td width="25%">&nbsp;<cellbytelabel>Datos del Paciente</cellbytelabel></td>
                          <td width="75%" align="right"></td>
                       					
                      </table>
                    </td>
                  </tr>
                  <tr >
                    <td><table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01" >
                            <td align="right"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
                            <td align="left"><%=fb.textBox("medico",cita.getCodMedico(),false,false,true,5,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>	
							<%=fb.textBox("nombre_medico",cita.getMedicoNombre(),false,false,true,40,"Text10","","onDblClick=\"javascript:clearMedico();\"")%>
							<%=fb.button("btnMedico","...",true,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:showMedicoList('dr_reserva')\"")%></td>
                            <td colspan="2" align="right"><cellbytelabel>M&eacute;dico Referencia</cellbytelabel>:</td>
                            <td colspan="4"><%=fb.textBox("nombre_medico_externo",cita.getNombreMedExterno(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),40,"Text10","","onDblClick=\"javascript:clearMedico();\"")%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td width="10%" align="right"><cellbytelabel>Paciente</cellbytelabel>:</td>
                          <td width="40%">
						   <%=fb.textBox("pacId",cita.getPacId(),false,false,true,5,"Text10",null,"")%>
						   <%=fb.textBox("nombrePaciente",cita.getNombrePaciente(),true,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),40,"Text10","","onFocus=\"javascript:checkPacId()\"")%> 
						   <%=fb.button("btnPaciente","...",true,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||(cdoParam.getColValue("tabView0").equalsIgnoreCase("S"))),"Text10",null,"onClick=\"javascript:showPacienteList(1)\"")%> </td>
                          
                          <td width="6%" colspan="2">&nbsp;</td>
                          <td width="7%" align="right"><cellbytelabel>Admisi&oacute;n</cellbytelabel></td>
                          <td width="6%"><%=fb.textBox("admision",cita.getAdmision(),false,false,true,3,"Text10","","")%></td>
                          <td width="10%" align="right"><cellbytelabel>Estado Adm</cellbytelabel>.</td>
                          <td width="14%"><%=fb.textBox("estado_admision",cita.getEstadoAdmision(),false,false,true,10,"Text10","","")%><%=fb.button("btnPacienteAdd","...",true,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:showPacienteList(2)\"","BUSCAR ADMISION")%> </td>
                        </tr>
                        <tr class="TextRow01">
                          <td align="right"><cellbytelabel>C&eacute;dula<br>Pasaporte</cellbytelabel></td>
                          <td>
						  <%=fb.intBox("provincia",cita.getProvincia(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")||(cdoParam.getColValue("tabView0").equalsIgnoreCase("S"))),2,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.textBox("sigla",cita.getSigla(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")||(cdoParam.getColValue("tabView0").equalsIgnoreCase("S"))),2,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.intBox("tomo",cita.getTomo(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")||(cdoParam.getColValue("tabView0").equalsIgnoreCase("S"))),4,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.intBox("asiento",cita.getAsiento(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")||(cdoParam.getColValue("tabView0").equalsIgnoreCase("S"))),5,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
								<%=fb.select("d_cedula","D=D,R=R,H1=H1,H2=H2,H3=H3,H4=H4,H5=H5",cita.getDCedula(),false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")||(cdoParam.getColValue("tabView0").equalsIgnoreCase("S"))),0,"Text10","","onFocus=\"javascript:checkPacId()\"")%>
						 <br> <%=fb.textBox("pasaporte",cita.getPasaporte(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")||(cita.getPacId() != null)||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),20,"Text10","","")%>
						  <%//=fb.textBox("pasaporte",cita.getPasaporte(),false,false,(viewMode||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S")),15,"Text10","","")%>
						  <%//=fb.textBox("provincia",cita.getProvincia(),false,false,viewMode,2,"Text10","","onFocus=\"javascript:checkPacId()\"")%> <%//=fb.textBox("sigla",cita.getSigla(),false,false,viewMode,2,"Text10","","onFocus=\"javascript:checkPacId()\"")%> <%//=fb.textBox("tomo",cita.getTomo(),false,false,viewMode,4,"Text10","","onFocus=\"javascript:checkPacId()\"")%> <%//=fb.textBox("asiento",cita.getAsiento(),false,false,viewMode,5,"Text10","","onFocus=\"javascript:checkPacId()\"")%> 
						  <%//=fb.select("d_cedula_view","D=D,R=R,H1=H1,H2=H2,H3=H3,H4=H4,H5=H5",cita.getDCedula(),false,true,0,"Text10","","onFocus=\"javascript:checkPacId()\"")%> 
						  &nbsp;&nbsp;<strong>C&oacute;d. Ref.:&nbsp;<span id="cod_ref"><%=cita.getCodigoReferencia()%></span></strong>
						  
						  </td>
                          <td colspan="2" align="right"><cellbytelabel>Fecha Nac</cellbytelabel>.</td>
                          <td colspan="2">
						    <%=fb.hidden("fec_nacimiento",cita.getFecNacimiento())%>
							 
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="clearOption" value="true" />
									<jsp:param name="nameOfTBox1" value="f_nac" />
									<jsp:param name="valueOfTBox1" value="<%=cita.getFechaT()%>" />
									<jsp:param name="format" value="dd/mm/yyyy" />
									<jsp:param name="fieldClass" value="Text10" />
									<jsp:param name="buttonClass" value="Text10" />
									<jsp:param name="readonly" value="<%=(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")||(cita.getPacId() != null))?"y":"n"%>" />
									<jsp:param name="appendOnClickEvt" value="if(!checkPacId())return false;" />
									<jsp:param name="appendOnFocus" value="checkPacId();" />
								</jsp:include>  <br>
								<cellbytelabel id="5">Edad:</cellbytelabel>
								<label id="lbl_edad">&nbsp;</label>
							
							</td>
                          <td align="right"><cellbytelabel>Tipo Atenci&oacute;n</cellbytelabel></td>
                          <td ><%=fb.select("hosp_amb","H=HOSPITALIZADA,A=AMBULATORIA",cita.getHospAmb(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td align="right"><cellbytelabel>Compa&ntilde;&iacute;a Seguro</cellbytelabel></td>
                          <td colspan="3"><%=fb.textBox("empresa",cita.getEmpresa(),false,false,true,10,"Text10","","")%> <%=fb.textBox("empresa_desc",cita.getEmpresaNombre(),false,false,true,50,"Text10","","")%> <%=fb.button("btnEmpresa","...",true,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")||(cita.getAdmision() != null && !cita.getAdmision().trim().equals(""))),"Text10",null,"onClick=\"javascript:selEmpresa()\"")%> </td>
                          <%
if (fp.equalsIgnoreCase("imagenologia"))
{
%>
                          <td colspan="4">&nbsp;</td>
                        </tr>
                        <%=fb.hidden("habitacion",cita.getHabitacion())%>
                        <tr class="TextRow01">
                          <td align="right"><cellbytelabel>Tipo Paciente</cellbytelabel></td>
                          <td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cdc_tipo_paciente where status = 'A'","tipo_paciente",cita.getTipoPaciente(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
                          <td align="center" colspan="3"> <cellbytelabel>Sala/Cuarto</cellbytelabel> <%=fb.textBox("cuarto",cita.getCuarto(),false,viewMode,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),12,15,"Text10","","")%> </td>
                          <td align="center" colspan="3"> <cellbytelabel>Tel&eacute;fono</cellbytelabel> <%=fb.textBox("telefono",cita.getTelefono(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),15,"Text10","","")%> </td>
                        </tr>
                    </table></td>
                  </tr>
                  <%
}//fp=imagenologia
else
{
%>
                  <td colspan="4"><label class="RedText"><cellbytelabel>Probable Hospitalizaci&oacute;n</cellbytelabel>?</label>
                    <%=fb.checkbox("probable_hospitalizacion","S",(cita.getProbableHospitalizacion().equalsIgnoreCase("S")),true,"","","")%> </td>
                  </tr>
                </table>
              </div>
            </div></td>
      </tr>
      <tr>
        <td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">&nbsp;<cellbytelabel>Datos de la Cirug&iacute;a</cellbytelabel></td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                <label id="plus1" style="display:none">+</label>
                <label id="minus1">-</label>
              </font>]&nbsp;</td>
            </tr>
        </table></td>
      </tr>
      <tr id="panel1">
        <td><table width="100%" cellpadding="1" cellspacing="1">
            <tr class="TextRow01">
              <td width="10%" align="right"><cellbytelabel>Clasificaci&oacute;n</cellbytelabel></td>
              <td width="40%"><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_cdc_tipo_cita","cod_tipo",cita.getCodTipo(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
              <td width="13%" align="right"><cellbytelabel>Tipo de Cita</cellbytelabel></td>
              <td width="13%"><%=fb.select("cita_cirugia","E=ELECTIVA,U=URGENCIA",cita.getCitaCirugia(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
              <td width="10%" align="right"><cellbytelabel>Anestesia</cellbytelabel>?</td>
              <td width="14%"><%=fb.select("anestesia","S=SI,N=NO",cita.getAnestesia(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
            </tr>
            <tr class="TextRow01">
              <td align="right"><cellbytelabel>Quir&oacute;fano</cellbytelabel></td>
              <%
			   sbSql = new StringBuffer();		
				sbSql.append(" select codigo, descripcion, nvl(centro_servicio,unidad_admin) as cds from tbl_sal_habitacion a where quirofano=2 and compania=");
				sbSql.append(session.getAttribute("_companyId"));
				if(!UserDet.getUserProfile().contains("0"))
				{
					sbSql.append(" and exists ( select null from tbl_sec_user_quirofano x where x.habitacion = a. codigo and x.compania=a.compania and x.user_id=");
						 
					sbSql.append(UserDet.getUserId());
					sbSql.append(")");
				} 
			  %>
			  <td><%=fb.select(ConMgr.getConnection(),sbSql.toString(),"habitacion",cita.getHabitacion(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","onChange=\"javascript:setCds(this)\"")%></td>
              <td align="center" colspan="4"> <cellbytelabel>Tiempo Estimado</cellbytelabel> <%=fb.textBox("hora_est",cita.getHoraEst(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),2,2)%>Hrs. <%=fb.textBox("min_est",cita.getMinEst(),false,false,viewMode,2,2)%>Min. </td>
            </tr>
        </table></td>
      </tr>
      <%
}//fp!=imagenologia
%>
      <tr>
        <td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">&nbsp;<cellbytelabel>Datos de la Cita</cellbytelabel></td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                <label id="plus2" style="display:none">+</label>
                <label id="minus2">-</label>
              </font>]&nbsp;</td>
            </tr>
        </table></td>
      </tr>
      <tr id="panel2">
        <td><table width="100%" cellpadding="1" cellspacing="1">
            <%
if (fp.equalsIgnoreCase("imagenologia"))
{
%>
            <tr class="TextRow01">
              <td width="12%" align="right"><cellbytelabel>Tipo de Cita</cellbytelabel></td>
              <td width="28"><%=fb.select("cita_cirugia","E=ELECTIVA,U=URGENCIA",cita.getCitaCirugia(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
              <td width="12%" align="right"><cellbytelabel>Forma Reservaci&oacute;n</cellbytelabel></td>
              <td width="20%"><%=fb.select("forma_reserva","T=TELEFONICA,P=PERSONALMENTE,E=E-MAIL",cita.getFormaReserva(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
              <td width="10%" align="right"><cellbytelabel>Estado Cita</cellbytelabel></td>
              <td width="18%"><%=fb.select("estado_cita","R=RESERVADA,C=CANCELADA,E=REALIZADA,T=TRANSFERIDA",cita.getEstadoCita(),false,true,0,"Text10","","")%></td>
            </tr>
            <tr class="TextRow01">
              <td align="right"><cellbytelabel>Fecha/Hora Cita</cellbytelabel></td>
              <td><jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />    
                <jsp:param name="nameOfTBox1" value="fecha_cita" />    
                <jsp:param name="valueOfTBox1" value="<%=cita.getFechaCita()%>" />    
                <jsp:param name="format" value="dd/mm/yyyy" />    
                <jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />    
                <jsp:param name="buttonClass" value="Text10" />    
                <jsp:param name="readonly" value="y" />    
                </jsp:include>
                  <jsp:include page="../common/calendar.jsp" flush="true">
                  <jsp:param name="noOfDateTBox" value="1" />      
                  <jsp:param name="nameOfTBox1" value="hora_cita" />      
                  <jsp:param name="valueOfTBox1" value="<%=cita.getHoraCita()%>" />      
                  <jsp:param name="format" value="hh12:mi am" />      
                  <jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />      
                  <jsp:param name="buttonClass" value="Text10" />      
                  <jsp:param name="readonly" value="y" />                        </jsp:include>              </td>
              <td align="center" colspan="4"> <cellbytelabel>Duraci&oacute;n de la Cita</cellbytelabel> <%=fb.textBox("hora_est",cita.getHoraEst(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),2,2)%>Hrs. <%=fb.textBox("min_est",cita.getMinEst(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),2,2)%>Min. </td>
            </tr>
            <tr class="TextRow01">
              <td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
              <td colspan="5"><%=fb.textarea("observacion",cita.getObservacion(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),80,2,2000)%></td>
            </tr>
        </table></td>
      </tr>
      <%
	if (fg.equalsIgnoreCase("trasladar")||(viewMode && !fg.equalsIgnoreCase("cancelar")))
	{
%>
      <%=fb.hidden("habitacion_t",cita.getHabitacion())%>
      <tr>
        <td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">&nbsp;<cellbytelabel>Informaci&oacute;n del Traslado</cellbytelabel></td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                <label id="plus3" style="display:none">+</label>
                <label id="minus3">-</label>
              </font>]&nbsp;</td>
            </tr>
        </table></td>
      </tr>
      <tr id="panel3">
        <td><table width="100%" cellpadding="1" cellspacing="1">
            <tr class="TextRow01">
              <td width="7%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
              <td width="43%"><jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />    
                <jsp:param name="nameOfTBox1" value="fecha_cita_t" />    
                <jsp:param name="valueOfTBox1" value="<%=cita.getFechaCita()%>" />    
                <jsp:param name="format" value="dd/mm/yyyy" />    
                <jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />    
                <jsp:param name="buttonClass" value="Text10" />    
                </jsp:include></td>
              <td width="7%" align="right"><cellbytelabel>Hora</cellbytelabel></td>
              <td width="43%"><jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />    
                <jsp:param name="nameOfTBox1" value="hora_cita_t" />    
                <jsp:param name="valueOfTBox1" value="<%=cita.getHoraCita()%>" />    
                <jsp:param name="format" value="hh12:mi am" />    
                <jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />    
                <jsp:param name="buttonClass" value="Text10" />    
                </jsp:include></td>
            </tr>
			<tr class="TextRow01">
							<td align="right"><cellbytelabel>Motivo del Traslado</cellbytelabel></td>
							<td colspan="3"><%=fb.textarea("motivo_t",cita.getTrasladoMotivo(),(fg.equalsIgnoreCase("trasladar")),false,false,80,2,2000)%>Usuario Traslado:<%=cita.getUsuarioTraslado()%></td>
						</tr>
        </table></td>
      </tr>
      <%
	}//fg=trasladar
	//if (fg.equalsIgnoreCase("cancelar")||viewMode)
	if (fg.equalsIgnoreCase("cancelar"))
	{
%>
      <tr>
        <td onClick="javascript:showHide(5)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
            <tr class="TextPanel">
              <td width="95%">&nbsp;<cellbytelabel>Motivo de Cancelaci&oacute;n</cellbytelabel></td>
              <td width="5%" align="right">[<font face="Courier New, Courier, mono">
                <label id="plus5" style="display:none">+</label>
                <label id="minus5">-</label>
              </font>]&nbsp;</td>
            </tr>
        </table></td>
      </tr>
      <tr id="panel5">
       <td><!--<table width="100%" cellpadding="1" cellspacing="1">
            <tr class="TextRow01">
              <td width="5%" align="right"><cellbytelabel>Motivo</cellbytelabel></td>
              <td width="95%"><%=fb.textarea("motivo_c",cita.getMotivoCancelacion(),(fg.equalsIgnoreCase("cancelar")),false,false,80,2,2000)%>Usuario Cancela:<%=cita.getUsuarioCancelacion()%></td> 
            </tr>
        </table> --></td>
      </tr>
      <%
	}
%>
      <%
}//fp=imagenologia
else
{
%>
      <tr class="TextRow01">
        <td width="12%" align="right"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
        <td width="28"><%=fb.intBox("codigo",cita.getCodigo(),true,false,true,4,"Text10","","")%></td>
        <td width="12%" align="right"><cellbytelabel>Fecha Registro</cellbytelabel></td>
        <td width="20%"><%=fb.textBox("fecha_registro",cita.getFechaRegistro(),true,false,true,10,"Text10","","")%></td>
        <td width="10%" align="right"><cellbytelabel>Hora Llamada</cellbytelabel></td>
        <td width="18%"><jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />    
          <jsp:param name="clearOption" value="true" />    
          <jsp:param name="nameOfTBox1" value="hora_llamada" />    
          <jsp:param name="valueOfTBox1" value="<%=cita.getHoraLlamada()%>" />    
          <jsp:param name="format" value="hh12:mi am" />    
          <jsp:param name="fieldClass" value="Text10" />    
          <jsp:param name="buttonClass" value="Text10" />    
          <jsp:param name="readonly" value="<%=((viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")) ||(citasSopAdm.equals("Y")||citasSopAdm.equals("S"))||citasAmb.equals("S"))?"y":"n"%>" />    
          </jsp:include>        </td>
      </tr>
      <tr class="TextRow01">
        <td align="right"><cellbytelabel> Fecha/Hora Cita</cellbytelabel></td>
        <td><jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="1" />    
          <jsp:param name="nameOfTBox1" value="fecha_cita" />    
          <jsp:param name="valueOfTBox1" value="<%=cita.getFechaCita()%>" />    
          <jsp:param name="format" value="dd/mm/yyyy" />    
          <jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />    
          <jsp:param name="buttonClass" value="Text10" />    
          <jsp:param name="readonly" value="<%=(cdoParam.getColValue("editFecha").equalsIgnoreCase("Y")?"n":"y")%>" />    
          </jsp:include>
            <jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />      
            <jsp:param name="nameOfTBox1" value="hora_cita" />      
            <jsp:param name="valueOfTBox1" value="<%=cita.getHoraCita()%>" />      
            <jsp:param name="format" value="hh12:mi am" />      
            <jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />      
            <jsp:param name="buttonClass" value="Text10" />      
            <jsp:param name="readonly" value="<%=(cdoParam.getColValue("editFecha").equalsIgnoreCase("Y")?"n":"y")%>" />                  </jsp:include>        </td>
        <td align="right"><cellbytelabel>Motivo Cita</cellbytelabel></td>
        <td><%=fb.textBox("motivo_cita",cita.getMotivoCita(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),30,"Text10","","")%></td>
        <td align="right"><cellbytelabel>Estado Cita</cellbytelabel></td>
        <td><%=fb.select("estado_cita","R=RESERVADA,C=CANCELADA,E=REALIZADA,T=TRANSFERIDA,X=CONFLICTO",cita.getEstadoCita(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%></td>
      </tr>
	  
	  
	  <tr class="TextRow01">
        <td align="right"><cellbytelabel>Hora Entrada SOP</cellbytelabel></td>
        <td><jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />      
            <jsp:param name="nameOfTBox1" value="hora_in_sop" />      
            <jsp:param name="valueOfTBox1" value="<%=cita.getHoraEntSop()%>" />      
            <jsp:param name="format" value="hh12:mi am" />      
            <jsp:param name="fieldClass" value="Text10" />      
            <jsp:param name="buttonClass" value="Text10" />      
            <jsp:param name="readonly" value="Y"/></jsp:include></td>
        <td align="right">Hora Inicio Cirugia</td>
        <td>&nbsp; <jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />      
            <jsp:param name="nameOfTBox1" value="hora_cirugia" />      
            <jsp:param name="valueOfTBox1" value="<%=cita.getHoraCirugia()%>" />      
            <jsp:param name="format" value="hh12:mi am" />      
            <jsp:param name="fieldClass" value="Text10" />      
            <jsp:param name="buttonClass" value="Text10" />      
            <jsp:param name="readonly" value="n"/></jsp:include>   </td>
        <td align="right">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  <tr class="TextRow01">
        <td align="right"><cellbytelabel>Hora Salida SOP</cellbytelabel></td>
        <td><jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />      
            <jsp:param name="nameOfTBox1" value="hora_fin_sop" />      
            <jsp:param name="valueOfTBox1" value="<%=cita.getHoraSalSop()%>" />      
            <jsp:param name="format" value="hh12:mi am" />      
            <jsp:param name="fieldClass" value="Text10" />      
            <jsp:param name="buttonClass" value="Text10" />      
            <jsp:param name="readonly" value="Y"/></jsp:include>
                   </td>
        <td align="right"><cellbytelabel>Hora Salida Cirugia</cellbytelabel></td>
        <td>&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
            <jsp:param name="noOfDateTBox" value="1" />      
            <jsp:param name="nameOfTBox1" value="hora_fin_cirugia" />      
            <jsp:param name="valueOfTBox1" value="<%=cita.getHoraFinCirugia()%>" />      
            <jsp:param name="format" value="hh12:mi am" />      
            <jsp:param name="fieldClass" value="Text10" />      
            <jsp:param name="buttonClass" value="Text10" />      
            <jsp:param name="readonly" value="n"/></jsp:include> </td>
        <td align="right">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
	  
	  
      <tr class="TextRow01">
        <td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
        <td colspan="5"><%=fb.textarea("observacion",cita.getObservacion(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),80,2,2000)%></td>
      </tr>
    </table></td>
  </tr>
				<tr>
					<td onClick="javascript:showHide(4)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Reservaci&oacute;n de la Cita</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus4" style="display:none">+</label><label id="minus4">-</label></font>]&nbsp;</td>
						</tr>
						</table>					</td>
				</tr>
				<tr id="panel4">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>Forma de Reservaci&oacute;n</cellbytelabel></td>
							<td width="16%"><%=fb.select("forma_reserva","T=TELEFONICA,P=PERSONALMENTE,E=E-MAIL",cita.getFormaReserva(),false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),0,"Text10","","")%> </td>
							<td width="10%" align="right"><cellbytelabel>Reservada por</cellbytelabel></td>
							<td width="27%"><%=fb.textBox("persona_reserva",cita.getPersonaReserva(),true,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),40,"Text10","","")%> </td>
							<td width="10%" align="right"><cellbytelabel>Persona que llam&oacute;</cellbytelabel></td>
							<td width="27%"><%=fb.textBox("persona_q_llamo",cita.getPersonaQLlamo(),false,false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),40,"Text10","","")%></td>
						</tr>
						</table></td>
				</tr>
<%
	if (fg.equalsIgnoreCase("trasladar")||((viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")) && !fg.equalsIgnoreCase("cancelar")))
	{
%>
				<tr>
					<td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Informaci&oacute;n del Traslado</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
						</tr>
						</table>					</td>
				</tr>
				<tr id="panel3">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Quir&oacute;fano</cellbytelabel></td>
							<td colspan="3"><%=fb.select(ConMgr.getConnection(),"select codigo, nvl(descripcion,' ') as descripcion from tbl_sal_habitacion where quirofano=2 and compania="+(String) session.getAttribute("_companyId"),"habitacion_t",cita.getHabitacion(),false,false,0,"Text10","","")%></td>
						</tr>
						<tr class="TextRow01">
							<td width="7%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
							<td width="43%">
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fecha_cita_t" />
									<jsp:param name="valueOfTBox1" value="<%=cita.getFechaCita()%>" />
									<jsp:param name="format" value="dd/mm/yyyy" />
									<jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />
									<jsp:param name="buttonClass" value="Text10" />
								</jsp:include>							</td>
							<td width="7%" align="right"><cellbytelabel>Hora</cellbytelabel></td>
							<td width="43%">
								<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="hora_cita_t" />
									<jsp:param name="valueOfTBox1" value="<%=cita.getHoraCita()%>" />
									<jsp:param name="format" value="hh12:mi am" />
									<jsp:param name="fieldClass" value="Text10 FormDataObjectRequired" />
									<jsp:param name="buttonClass" value="Text10" />
								</jsp:include>							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Motivo del Traslado</cellbytelabel></td>
							<td colspan="3"><%=fb.textarea("motivo_t",cita.getTrasladoMotivo(),(fg.equalsIgnoreCase("trasladar")),false,false,80,2,2000)%>Usuario Traslado:<%=cita.getUsuarioTraslado()%></td>
						</tr>
						</table>					</td>
				</tr>
<%
	}//fg=trasladar
	//if (fg.equalsIgnoreCase("cancelar")||viewMode)
	if (fg.equalsIgnoreCase("cancelar"))
	{
%>
				<tr>
					<td onClick="javascript:showHide(5)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Motivo de Cancelaci&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus5" style="display:none">+</label><label id="minus5">-</label></font>]&nbsp;</td>
						</tr>
						</table>					</td>
				</tr>
				<tr id="panel5">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="5%" align="right"><cellbytelabel>Motivo</cellbytelabel></td>
							<td width="95%"><%=fb.textarea("motivo_c",cita.getMotivoCancelacion(),(fg.equalsIgnoreCase("cancelar")),false,false,80,2,2000)%>Usuario Cancela:<%=cita.getUsuarioCancelacion()%></td>
						</tr>
						</table>					</td>
				</tr>
<%
	}
	else
	{
%>
				<!--
        <tr>
					<td onClick="javascript:showHide(6)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Datos de Patolog&iacute;a</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus6" style="display:none">+</label><label id="minus6">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel6">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="10%" align="right"><cellbytelabel>Enviar Datos</cellbytelabel>?</td>
							<td width="15%"><%//=fb.select("patalogia","S=SI,N=NO",cita.getPatalogia(),false,viewMode,0,"Text10","","",null,"S")%></td>
							<td width="10%" align="right"><cellbytelabel>Destino</cellbytelabel></td>
							<td width="65%"><%//=fb.textBox("destino_pat",cita.getDestinoPat(),false,false,viewMode,100,"Text10","","")%></td>
						</tr>
						</table>
					</td>
				</tr>
        -->
        <%=fb.hidden("patalogia","N")%>
        <%=fb.hidden("destino_pat","")%>
<%
	}//fg!=trasladar
}//fp!=imagenologia
%>
				
<%
if (fg.equalsIgnoreCase("trasladar") || fg.equalsIgnoreCase("cancelar") || fg.equalsIgnoreCase("crear_solicitud"))
{
%>
				<tr class="TextRow02">
					<td align="right" colspan="4">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro-->
						<!--<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto-->
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>					</td>
				</tr>
<%
}//fg=trasladar||cancelar
else
{
%>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),false)%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,(viewMode||cdoParam.getColValue("tabView0").equalsIgnoreCase("S")),false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,(viewMode||cdoParam.getColValue("tabView0").trim().equals("S")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>					</td>
				</tr>
<%
}//fg!=trasladar
%>
<%if(fg.equalsIgnoreCase("crear_solicitud")){%>
<%fb.appendJsValidation("if(!validAdmision())error++;");%>
<%} else {%>
<%fb.appendJsValidation("if(!validDateTime())error++;else if(!validLastTime())error++;");%>
<%}%>
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
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("equiLastLineNo",""+equiLastLineNo)%>
<%=fb.hidden("procSize",""+iProc.size())%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("equiSize",""+iEqui.size())%>
<%=fb.hidden("procKey","")%>
<%=fb.hidden("citasSopAdm",""+citasSopAdm)%>
<%=fb.hidden("citasAmb",""+citasAmb)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Detalle de Procedimientos a ejecutar</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="4%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
							<td width="25%"><cellbytelabel>Tipo Cirug&iacute;a</cellbytelabel></td>
							<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="57%"><cellbytelabel>Procedimiento</cellbytelabel></td>
							<td width="4%"><%=(htProc.size() < 5)?fb.submit("addProcedimiento","+",true,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"','addProcedimiento')\"","Agregar Procedimiento"):""%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iProc);
for (int i=1; i<=iProc.size(); i++)
{
	key = al.get(i - 1).toString();
	CitaProcedimiento obj = (CitaProcedimiento) iProc.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow01";//"TextRow02";
	else color = "TextRow01";
	String display = "";
	if (obj.getStatus() != null && obj.getStatus().equalsIgnoreCase("D")) display = " style=\"display:none\"";
%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("status"+i,obj.getStatus())%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("usuario_creacion"+i,obj.getUsuarioCreacion())%>
						<%=fb.hidden("fecha_creacion"+i,obj.getFechaCreacion())%>
						<%=fb.hidden("usuario_modif"+i,obj.getUsuarioModif())%>
						<%=fb.hidden("fecha_modif"+i,obj.getFechaModif())%>
						<%=fb.hidden("codigo"+i,obj.getCodigo())%>
						<%=fb.hidden("procedimiento"+i,obj.getProcedimiento())%>
						<%=fb.hidden("procedimiento_desc"+i,obj.getProcedimientoDesc())%>
						<tr class="<%=color%>"<%=display%>>
							<td align="center"><%=obj.getCodigo()%></td>
							<td align="center"><%=fb.select("tipo_c"+i,alTipo,obj.getTipoC(),false,viewMode,0,"Text10","","",null,fp.equalsIgnoreCase("imagenologia")?" ":"")%></td>
							<td align="center"><%=obj.getProcedimiento()%></td>
							<td><%=obj.getProcedimientoDesc()%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Procedimiento")%></td>
						</tr>
<%
	if (fp.equalsIgnoreCase("imagenologia"))
	{
%>
						<tr class="<%=color%>"<%=display%>>
							<td>&nbsp;</td>
							<td colspan="3">
								<cellbytelabel>Observaciones</cellbytelabel>
								<%=fb.textarea("observacion"+i,obj.getObservacion(),false,false,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),80,2,2000)%>
							</td>
							<td>&nbsp;</td>
						</tr>
<%
	}//fp=imagenologia
	else
	{
%>
						<tr class="<%=color%>"<%=display%>>
							<td>&nbsp;</td>
							<td colspan="3">
								<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="TextHeader02" align="center">
									<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
									<td width="10%"><cellbytelabel>ICD9</cellbytelabel></td>
									<td width="81%"><cellbytelabel>Diagn&oacute;stico</cellbytelabel></td>
									<td width="4%"><%=fb.submit("addDiagnostico"+i,"+",true,viewMode,"Text10",null,"onClick=\"javascript:setProcKey("+i+");setBAction('"+fb.getFormName()+"','addDiagnostico')\"","Agregar Diagn�stico")%></td>
								</tr>
								<%=fb.hidden("diagSize"+i,""+obj.getProcedDiagnostico().size())%>
								<%=fb.hidden("diagLastLineNo"+i,""+obj.getDiagLastLineNo())%>
<%
		for (int j=1; j<=obj.getProcedDiagnostico().size(); j++)
		{
			ProcedDiagnostico det = obj.getProcedDiagnostico(j-1);
			String color2 = "";
			if (j%2 == 0) color2 = "TextRow03";//"TextRow04";
			else color2 = "TextRow03";
			String displayDiag = "";
			if (det.getStatus() != null && det.getStatus().equalsIgnoreCase("D")) displayDiag = " style=\"display:none\"";
%>
								<%=fb.hidden("remove"+i+"_"+j,"")%>
								<%=fb.hidden("status"+i+"_"+j,det.getStatus())%>
								<%=fb.hidden("key"+i+"_"+j,det.getKey())%>
								<%=fb.hidden("codigo"+i+"_"+j,det.getCodigo())%>
								<%=fb.hidden("usuario_creacion"+i+"_"+j,det.getUsuarioCreacion())%>
								<%=fb.hidden("fecha_creacion"+i+"_"+j,det.getFechaCreacion())%>
								<%=fb.hidden("usuario_modif"+i+"_"+j,det.getUsuarioModif())%>
								<%=fb.hidden("fecha_modif"+i+"_"+j,det.getFechaModif())%>
								<%=fb.hidden("diagnostico"+i+"_"+j,det.getDiagnostico())%>
								<%=fb.hidden("diagnostico_desc"+i+"_"+j,det.getDiagnosticoDesc())%>
								<tr class="<%=color2%>"<%=displayDiag%>>
									<td align="center"><%=det.getCodigo()%></td>
									<td align="center"><%=det.getDiagnostico()%></td>
									<td align="left"><%=det.getDiagnosticoDesc()%></td>
									<td align="center"><%=fb.submit("rem"+i+"_"+j,"x",true,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"','"+i+"_"+j+"')\"","Eliminar Diagn�stico")%></td>
								</tr>
<%
		}//for diag
%>
								</table>
							</td>
							<td>&nbsp;</td>
						</tr>
<%
	}//fp!=imagenologia
}//for proc
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,(viewMode||cdoParam.getColValue("tabView1").equalsIgnoreCase("S")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
	<!-- TAB1 DIV END HERE-->
	</div>
	<!-- TAB2 DIV START HERE-->
	<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("equiLastLineNo",""+equiLastLineNo)%>
<%=fb.hidden("procSize",""+iProc.size())%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("equiSize",""+iEqui.size())%>
<%=fb.hidden("citasSopAdm",""+citasSopAdm)%>
<%=fb.hidden("citasAmb",""+citasAmb)%>
<%fb.appendJsValidation("if(document.form2.baction.value!='Guardar')return true;");%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Detalle del Personal que participa</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;d</cellbytelabel>.</td>
							<td width="26%"><cellbytelabel>Funci&oacute;n</cellbytelabel></td>
							<td width="35%"><cellbytelabel>Personal</cellbytelabel></td>
							<td width="30%"><cellbytelabel>Personal Ext</cellbytelabel>.</td>
							<td width="4%"><%=(htPersonal.size() < 2)?fb.submit("addPersonal","+",true,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Personal"):""%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iPers);
for (int i=1; i<=iPers.size(); i++)
{
	key = al.get(i - 1).toString();
	CitaPersonal obj = (CitaPersonal) iPers.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow01";//"TextRow02";
	else color = "TextRow01";
	String display = "";
	if (obj.getStatus() != null && obj.getStatus().equalsIgnoreCase("D")) display = " style=\"display:none\"";
%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("status"+i,obj.getStatus())%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("usuario_creacion"+i,obj.getUsuarioCreacion())%>
						<%=fb.hidden("fecha_creacion"+i,obj.getFechaCreacion())%>
						<%=fb.hidden("usuario_modif"+i,obj.getUsuarioModif())%>
						<%=fb.hidden("fecha_modif"+i,obj.getFechaModif())%>
						<%=fb.hidden("codigo"+i,obj.getCodigo())%>
					
						<%=fb.hidden("empCompania"+i,obj.getEmpCompania())%>
						<%=fb.hidden("empProvincia"+i,obj.getEmpProvincia())%>
						<%=fb.hidden("empSigla"+i,obj.getEmpSigla())%>
						<%=fb.hidden("empTomo"+i,obj.getEmpTomo())%>
						<%=fb.hidden("empAsiento"+i,obj.getEmpAsiento())%>
						<%=fb.hidden("empId"+i,obj.getEmpId())%>
						<%=fb.hidden("tipoPersonal"+i,obj.getTipoPersonal())%>
						<%=fb.hidden("sociedad"+i,obj.getSociedad())%>
						
						<%//=fb.hidden("nombre"+i,obj.getNombre())%>
						<tr class="<%=color%>"<%=display%> align="center">
							<td><%=obj.getCodigo()%></td>
							<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' ['||tipo_personal||']', tipo_personal from tbl_cds_funcion order by 2","funcion"+i,obj.getFuncion(),false,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),0,"Text10","","onChange=\"javascript:checkPersonal("+i+")\"")%></td>
							<td>
								<%=fb.hidden("medico"+i,obj.getMedico())%>
								<%=fb.textBox("nombre"+i,obj.getNombre(),true,false,true,50,"Text10","","")%>
								<%=fb.button("listPersonal"+i,"...",true,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),null,null,"onClick=\"javascript:getPersonal("+i+")\"")%>
							</td>
							<td align="left"><%=fb.textarea("observacion"+i,obj.getObservacion(),false,false,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),30,2,2000,"","","")%></td>
							<td><%=fb.submit("rem"+i,"x",true,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Personal")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,(viewMode||cdoParam.getColValue("tabView2").equalsIgnoreCase("S")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
	<!-- TAB2 DIV END HERE-->
	</div>
	<!-- TAB3 DIV START HERE-->
	<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("persLastLineNo",""+persLastLineNo)%>
<%=fb.hidden("equiLastLineNo",""+equiLastLineNo)%>
<%=fb.hidden("procSize",""+iProc.size())%>
<%=fb.hidden("persSize",""+iPers.size())%>
<%=fb.hidden("equiSize",""+iEqui.size())%>
<%=fb.hidden("citasSopAdm",""+citasSopAdm)%>
<%=fb.hidden("citasAmb",""+citasAmb)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Detalle del Equipo a Utilizar</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="7%"><cellbytelabel>Equipo</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&iacute;a</cellbytelabel>.</td>
							<td width="35%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="8%"><cellbytelabel>Cantidad</cellbytelabel></td>
							<td width="41%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
							<td width="4%"><%=fb.submit("addEquipo","+",false,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Equipos")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iEqui);
for (int i=1; i<=iEqui.size(); i++)
{
	key = al.get(i - 1).toString();
	CitaEquipo obj = (CitaEquipo) iEqui.get(key);
	String color = "";
	if (i%2 == 0) color = "TextRow01";//"TextRow02";
	else color = "TextRow01";
	String display = "";
	if (obj.getStatus() != null && obj.getStatus().equalsIgnoreCase("D")) display = " style=\"display:none\"";
	if (obj.getCantidad()==null) obj.setCantidad("1");
%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("status"+i,obj.getStatus())%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("usuario_creacion"+i,obj.getUsuarioCreacion())%>
						<%=fb.hidden("fecha_creacion"+i,obj.getFechaCreacion())%>
						<%=fb.hidden("usuario_modif"+i,obj.getUsuarioModif())%>
						<%=fb.hidden("fecha_modif"+i,obj.getFechaModif())%>
						<%=fb.hidden("uso_codigo"+i,obj.getUsoCodigo())%>
						<%=fb.hidden("compania"+i,obj.getCompania())%>
						<%=fb.hidden("uso_desc"+i,obj.getUsoDesc())%>
						<tr class="<%=color%>"<%=display%>>
							<td align="center"><%=obj.getUsoCodigo()%></td>
							<td align="center"><%=obj.getCompania()%></td>
							<td><%=obj.getUsoDesc()%></td>
							<td align="center"><%=fb.intBox("cantidad"+i,obj.getCantidad(),true,false,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),3,3,"Text10","","")%></td>
							<td><%=fb.textarea("observacion"+i,obj.getObservacion(),false,false,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),40,2,2000,"","","")%></td>
							<td align="center"><%=fb.submit("rem"+i,"x",true,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),"Text10",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Equipo")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,(viewMode||cdoParam.getColValue("tabView3").equalsIgnoreCase("S")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
	<!-- TAB3 DIV END HERE-->
	</div>
<!-- MAIN DIV END HERE -->
</div>
<script type="text/javascript">
<%
String menuTabs;


if (fg.equalsIgnoreCase("trasladar")) menuTabs = "'Trasladar Cita'";
else if (fg.equalsIgnoreCase("cancelar")) menuTabs = "'Cancelar Cita'";
else menuTabs = "'Cita'";
menuTabs += ",'Procedimiento','Personal','Equipo'";
if (fg.equalsIgnoreCase("crear_solicitud")) menuTabs = "'Cita'";
String tabInactivo =""; 
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=menuTabs%>),<%=tab%>,'100%','','','','',[<%=tabInactivo%>]);
</script>
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
}
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	fp = request.getParameter("fp");
	String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
	int size = 0;
	int lineNo = 0;
	String itemRemoved = "";

	cita.setCodigo(codCita);
	cita.setFechaRegistro(fechaCita);
	
	System.out.println("::::::::::::::::::::::::::::::::::::::::::: tab ="+tab+" fp ="+fp);

	if (tab.equals("0")) //CITA
	{
		if (fg.equalsIgnoreCase("trasladar"))
		{
			cita.setTrasladoCodigo("0");//generated by trigger
			cita.setTrasladoFechaRegistro("");//set in manager
			cita.setFechaT(request.getParameter("fecha_cita_t"));
			cita.setHoraT(request.getParameter("hora_cita_t"));
			cita.setUsuarioTraslado((String) session.getAttribute("_userName"));
			cita.setHabitacionT(request.getParameter("habitacion_t"));
			cita.setTrasladoMotivo(request.getParameter("motivo_t"));
			cita.setCompania((String) session.getAttribute("_companyId"));
		}
		else if (fg.equalsIgnoreCase("cancelar"))
		{
			cita.setEstadoCita("C");
			cita.setUsuarioCancelacion((String) session.getAttribute("_userName"));
			cita.setFechaCancelacion("sysdate");
			cita.setMotivoCancelacion(request.getParameter("motivo_c"));
		}
		else
		{
			cita.setPacId(request.getParameter("pacId"));
			cita.setNombrePaciente(request.getParameter("nombrePaciente"));
			cita.setCodPaciente(request.getParameter("cod_paciente"));
			cita.setAdmision(request.getParameter("admision"));
			if((request.getParameter("pacId").trim().equals(""))&&(request.getParameter("f_nac")!=null && !request.getParameter("f_nac").trim().equals("")))cita.setFecNacimiento(request.getParameter("f_nac"));
			 else cita.setFecNacimiento(request.getParameter("fec_nacimiento"));
			 
			cita.setProvincia(request.getParameter("provincia"));
			cita.setSigla(request.getParameter("sigla"));
			cita.setTomo(request.getParameter("tomo"));
			cita.setAsiento(request.getParameter("asiento"));
			cita.setDCedula(request.getParameter("d_cedula"));
			cita.setEstadoAdmision(request.getParameter("estado_admision"));
			cita.setHospAmb(request.getParameter("hosp_amb"));
			cita.setEmpresa(request.getParameter("empresa"));
			cita.setProbableHospitalizacion(request.getParameter("probable_hospitalizacion"));
			cita.setTelefono(request.getParameter("telefono"));
			cita.setTipoPaciente(request.getParameter("tipo_paciente"));
			cita.setCuarto(request.getParameter("cuarto"));
			cita.setCodTipo(request.getParameter("cod_tipo"));
			cita.setCitaCirugia(request.getParameter("cita_cirugia"));
			cita.setAnestesia(request.getParameter("anestesia"));
			cita.setHabitacion(request.getParameter("habitacion"));
			cita.setHoraEst(request.getParameter("hora_est"));
			cita.setMinEst(request.getParameter("min_est"));
			cita.setHoraLlamada(request.getParameter("hora_llamada"));
			cita.setFechaCita(request.getParameter("fecha_cita"));
			cita.setHoraCita(request.getParameter("hora_cita"));
			cita.setMotivoCita(request.getParameter("motivo_cita"));
			cita.setEstadoCita(request.getParameter("estado_cita"));
			cita.setObservacion(request.getParameter("observacion"));
			cita.setFormaReserva(request.getParameter("forma_reserva"));
			cita.setPersonaReserva(request.getParameter("persona_reserva"));
			cita.setPersonaQLlamo(request.getParameter("persona_q_llamo"));

			cita.setPatalogia(request.getParameter("patalogia"));
			cita.setDestinoPat(request.getParameter("destino_pat"));
			
			cita.setHoraFinCirugia(request.getParameter("hora_fin_cirugia"));
			cita.setHoraCirugia(request.getParameter("hora_cirugia"));

			cita.setCompania((String) session.getAttribute("_companyId"));
			cita.setUsuarioModif((String) session.getAttribute("_userName"));
			cita.setCodMedico(request.getParameter("medico"));
			cita.setMedicoNombre(request.getParameter("nombre_medico"));
			cita.setNombreMedExterno(request.getParameter("nombre_medico_externo"));
			cita.setFechaModif(cDate);
			cita.setPasaporte(request.getParameter("pasaporte"));
		}

		if (baction != null && baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (fg.equalsIgnoreCase("trasladar"))
			{
				CitaMgr.moveCita(cita);
				codCita = CitaMgr.getPkColValue("codigo");
				fechaCita = CitaMgr.getPkColValue("fecha_registro");
			} else {
				if(fg.equalsIgnoreCase("crear_solicitud")) cita.setCrearSolicitud("S");
				CitaMgr.updateCita(cita);
			}
			ConMgr.clearAppCtx(null);
		}
	}//cita & traslado
	else if (tab.equals("1")) //PROCEDIMIENTOS
	{
		if (request.getParameter("procSize") != null) size = Integer.parseInt(request.getParameter("procSize"));
		if (request.getParameter("procLastLineNo") != null) lineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
		for (int i=1; i<=size; i++)
		{
			CitaProcedimiento obj = new CitaProcedimiento();

			obj.setStatus(request.getParameter("status"+i));
			obj.setKey(request.getParameter("key"+i));
			obj.setCodigo(request.getParameter("codigo"+i));
			obj.setProcedimiento(request.getParameter("procedimiento"+i));
			obj.setProcedimientoDesc(request.getParameter("procedimiento_desc"+i));
			obj.setTipoC(request.getParameter("tipo_c"+i));
			obj.setObservacion(request.getParameter("observacion"+i));

			if (obj.getCodigo().equals("0"))
			{
				obj.setUsuarioCreacion((String) session.getAttribute("_userName"));
				obj.setFechaCreacion("sysdate");
			}
			obj.setUsuarioModif((String) session.getAttribute("_userName"));
			obj.setFechaModif("sysdate");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = obj.getKey();
				obj.setStatus("D");
				vProc.remove(obj.getProcedimiento());
			}

			//Vector vTempDiag = null;
			//vTempDiag = null;
			
			
			//else
			if (fp.equalsIgnoreCase("imagenologia")) obj.setProcedDiagnostico(null);
			else {
				if (request.getParameter("diagSize"+i) != null);// obj.setProcedDiagnostico(null);
				{
					obj.setDiagLastLineNo(Integer.parseInt(request.getParameter("diagLastLineNo"+i)));
					int diagSize = Integer.parseInt(request.getParameter("diagSize"+i));
					vTempDiag = (Vector) vProcDiag.get(obj.getKey());
					al.clear();
					for (int j=1; j<=diagSize; j++)
					{
						ProcedDiagnostico det = new ProcedDiagnostico();

						det.setStatus(request.getParameter("status"+i+"_"+j));
						det.setKey(request.getParameter("key"+i+"_"+j));
						det.setCodigo(request.getParameter("codigo"+i+"_"+j));
						det.setDiagnostico(request.getParameter("diagnostico"+i+"_"+j));
						det.setDiagnosticoDesc(request.getParameter("diagnostico_desc"+i+"_"+j));

						if (det.getCodigo().equals("0"))
						{
							det.setUsuarioCreacion((String) session.getAttribute("_userName"));
							det.setFechaCreacion("sysdate");
						}
						det.setUsuarioModif((String) session.getAttribute("_userName"));
						det.setFechaModif("sysdate");
						if (request.getParameter("remove"+i+"_"+j) != null && !request.getParameter("remove"+i+"_"+j).equals(""))
						{
							itemRemoved = det.getKey();
							det.setStatus("D");
							vTempDiag.remove(det.getDiagnostico());
						}
						obj.addProcedDiagnostico(det);
						al.add(det);
						//obj.setProcedDiagnostico(al);				
					}//for diag
				}//diag
			}
			try
			{
				iProc.put(obj.getKey(),obj);
				cita.addCitaProcedimiento(obj);
				if (!fp.equalsIgnoreCase("imagenologia")) vProcDiag.put(obj.getKey(),vTempDiag);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for proc

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab="+tab+"&mode="+mode+"&codCita="+codCita+"&fechaCita="+fechaCita+"&procLastLineNo="+procLastLineNo+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&citasAmb="+citasAmb+"&citasSopAdm="+citasSopAdm);
			return;
		}

		if (baction != null && baction.equalsIgnoreCase("addProcedimiento"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&type=1&tab="+tab+"&mode="+mode+"&codCita="+codCita+"&fechaCita="+fechaCita+"&procLastLineNo="+procLastLineNo+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&citasAmb="+citasAmb+"&citasSopAdm="+citasSopAdm);
			return;
		}
		else if (baction != null && baction.equalsIgnoreCase("addDiagnostico"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&type=2&tab="+tab+"&mode="+mode+"&codCita="+codCita+"&fechaCita="+fechaCita+"&procLastLineNo="+procLastLineNo+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&procKey="+procKey+"&citasAmb="+citasAmb+"&citasSopAdm="+citasSopAdm);
			return;
		}
		else if (baction != null && baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			CitaMgr.saveProcedimientos(cita);
			System.out.println("SAVING><::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::******>><< "+al.size());
			//ConMgr.clearAppCtx(null);
		}
	}//procedimientos & diagnosticos
	else if (tab.equals("2")) //PERSONAL
	{
		if (request.getParameter("persSize") != null) size = Integer.parseInt(request.getParameter("persSize"));
		if (request.getParameter("persLastLineNo") != null) lineNo = Integer.parseInt(request.getParameter("persLastLineNo"));
		for (int i=1; i<=size; i++)
		{
			CitaPersonal obj = new CitaPersonal();

			obj.setStatus(request.getParameter("status"+i));
			obj.setKey(request.getParameter("key"+i));
			obj.setCodigo(request.getParameter("codigo"+i));
			obj.setFuncion(request.getParameter("funcion"+i));
			obj.setMedico(request.getParameter("medico"+i));
			obj.setEmpCompania(request.getParameter("empCompania"+i));
			obj.setEmpProvincia(request.getParameter("empProvincia"+i));
			obj.setEmpSigla(request.getParameter("empSigla"+i));
			obj.setEmpTomo(request.getParameter("empTomo"+i));
			obj.setEmpAsiento(request.getParameter("empAsiento"+i));
			obj.setEmpId(request.getParameter("emp"+i));
			obj.setTipoPersonal(request.getParameter("emp"+i));
			obj.setNombre(request.getParameter("nombre"+i));
			obj.setObservacion(request.getParameter("observacion"+i));
			obj.setSociedad(request.getParameter("sociedad"+i));

			if (obj.getCodigo().equals("0"))
			{
				obj.setUsuarioCreacion((String) session.getAttribute("_userName"));
				obj.setFechaCreacion("sysdate");
			}
			obj.setUsuarioModif((String) session.getAttribute("_userName"));
			obj.setFechaModif("sysdate");

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = obj.getKey();
				obj.setStatus("D");
				obj.setNombre(".");
				vPers.remove(obj.getMedico());
			}
			try
			{
				iPers.put(obj.getKey(),obj);
				cita.addCitaPersonal(obj);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for pers

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab="+tab+"&mode="+mode+"&codCita="+codCita+"&fechaCita="+fechaCita+"&procLastLineNo="+procLastLineNo+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&citasAmb="+citasAmb+"&citasSopAdm="+citasSopAdm);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			CitaPersonal det = new CitaPersonal();

			det.setStatus("N");//new record
			det.setCodigo("0");
			persLastLineNo++;
			det.setKey(""+persLastLineNo,3);

			try
			{
				iPers.put(det.getKey(),det);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab="+tab+"&mode="+mode+"&codCita="+codCita+"&fechaCita="+fechaCita+"&procLastLineNo="+procLastLineNo+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&citasAmb="+citasAmb+"&citasSopAdm="+citasSopAdm);
			return;
		}
		else if (baction != null && baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			CitaMgr.savePersonal(cita);
			ConMgr.clearAppCtx(null);
		}
	}//personal
	else if (tab.equals("3")) //EQUIPOS
	{
		
		if (request.getParameter("equiSize") != null) size = Integer.parseInt(request.getParameter("equiSize"));
		if (request.getParameter("equiLastLineNo") != null) lineNo = Integer.parseInt(request.getParameter("equiLastLineNo"));
		System.out.println("SIZE :::::::::::::::::::::::::::::::::_________________ "+size);
		for (int i=1; i<=size; i++)
		{
			CitaEquipo obj = new CitaEquipo();

			obj.setStatus(request.getParameter("status"+i));
			obj.setKey(request.getParameter("key"+i));
			obj.setUsoCodigo(request.getParameter("uso_codigo"+i));
			obj.setCompania(request.getParameter("compania"+i));
			obj.setUsoDesc(request.getParameter("uso_desc"+i));
			obj.setCantidad(request.getParameter("cantidad"+i));
			obj.setObservacion(request.getParameter("observacion"+i));

			if (obj.getStatus().equalsIgnoreCase("N"))
			{
				obj.setUsuarioCreacion((String) session.getAttribute("_userName"));
				obj.setFechaCreacion("sysdate");
			}
			obj.setUsuarioModif((String) session.getAttribute("_userName"));
			obj.setFechaModif("sysdate");
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = obj.getKey();
				obj.setStatus("D");
				vEqui.remove(obj.getUsoCodigo());
			}

			try
			{
				iEqui.put(obj.getKey(),obj);
				cita.addCitaEquipo(obj);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for equi

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&tab="+tab+"&mode="+mode+"&codCita="+codCita+"&fechaCita="+fechaCita+"&procLastLineNo="+procLastLineNo+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&citasAmb="+citasAmb+"&citasSopAdm="+citasSopAdm);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&change=1&type=4&tab="+tab+"&mode="+mode+"&codCita="+codCita+"&fechaCita="+fechaCita+"&procLastLineNo="+procLastLineNo+"&persLastLineNo="+persLastLineNo+"&equiLastLineNo="+equiLastLineNo+"&citasAmb="+citasAmb+"&citasSopAdm="+citasSopAdm);
			return;
		}
		else if (baction != null && baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			CitaMgr.saveEquipo(cita);
			ConMgr.clearAppCtx(null);
		}
	}//equipos
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (CitaMgr.getErrCode().equals("1"))
{
%>
	alert('<%=CitaMgr.getErrMsg()%>');
<%
	
		if (fp.equalsIgnoreCase("imagenologia") && fg.equalsIgnoreCase("trasladar"))
		{
%>
	window.opener.submitDate('<%=cita.getFechaT()%>');
<%
		}
		else
		{
%>
	window.opener.location.reload(true);
<%
		}

	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('editMode()',500);
<%
	} else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}
} else throw new Exception(CitaMgr.getErrException());
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&citasAmb=<%=citasAmb%>&citasSopAdm=<%=citasSopAdm%>';
}

function editMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&mode=edit&tab=<%=tab%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>&citasAmb=<%=citasAmb%>&citasSopAdm=<%=citasSopAdm%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
