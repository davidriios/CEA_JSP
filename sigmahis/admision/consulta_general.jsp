<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.facturacion.FactTransaccion"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<%@ page import="issi.caja.TransaccionPago"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr"/>
<jsp:useBean id="iBen" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iAju" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iPagPte" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iPagEmp" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iAdm" scope="session" class="java.util.Hashtable"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList alCargo = new ArrayList();
ArrayList alHon = new ArrayList();
ArrayList alDev = new ArrayList();
Admision adm = new Admision();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String change = request.getParameter("change");
String fecha="",fechaIngreso="";
int benLastLineNo = 0, prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
double total = 0.00;
int iconHeight = 48;
int iconWidth = 48;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
CommonDataObject cdoTot = new CommonDataObject();
String  cdsDet= "N";
try {cdsDet =java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){ cdsDet = "N";}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("view"))
	{
		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		iAdm.clear();

		sql = "select to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi:ss am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, nvl(e.reg_medico,a.medico) as medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi:ss am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, a.corte_cta corteCta, decode(a.provincia,null,' ',a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',a.tomo) as tomo, decode(a.asiento,null,' ',a.asiento) as asiento, nvl(a.d_cedula,' ') as dCedula, nvl(a.pasaporte,' ') as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad,b.nombre_paciente as nombrePaciente, c.descripcion as categoriaDesc, d.descripcion as tipoAdmisionDesc, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' '||e.apellido_de_casada)) as nombreMedico, e.especialidad, decode(f.primer_nombre,null,' ',f.primer_nombre||decode(f.segundo_nombre,null,'',' '||f.segundo_nombre)||' '||f.primer_apellido||decode(f.segundo_apellido,null,'',' '||f.segundo_apellido)||decode(f.sexo,'F',decode(f.apellido_de_casada,null,'',' '||f.apellido_de_casada))) as nombreMedicoCabecera, g.descripcion as centroServicioDesc, h.nombre_abreviado nombreEmpresa,to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimientoAnt from tbl_adm_admision a, vw_adm_paciente b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d, (select nvl(x.reg_medico,x.codigo) as reg_medico,x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl(z.descripcion,'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) e, tbl_adm_medico f, tbl_cds_centro_servicio g, (select a.admision, a.pac_id, b.nombre_abreviado from tbl_adm_beneficios_x_admision a, tbl_adm_empresa b where a.empresa = b.codigo and b.estado = 'A') h where a.pac_id=b.pac_id and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and a.medico=e.codigo and a.medico_cabecera=f.codigo(+) and a.centro_servicio = g.codigo and a.secuencia = h.admision(+) and a.pac_id = h.pac_id(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id="+pacId+" and a.secuencia="+noAdmision;
		System.out.println("SQL:\n"+sql);
		adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Admision.class);
		fecha = ""+adm.getFechaNacimiento().substring(0,2)+"-"+adm.getFechaNacimiento().substring(3,5)+"-"+adm.getFechaNacimiento().substring(6,10)+"";
		fechaIngreso = ""+adm.getFechaIngreso().substring(0,2)+"-"+adm.getFechaIngreso().substring(3,5)+"-"+adm.getFechaIngreso().substring(6,10)+"";

		sql = "select decode(a.estado, 'A', 'Activa', 'E', 'Espera', 'S', 'Especial', 'C', 'Cancelada', 'I', 'Inactiva', 'N', 'Anulada', 'T', 'Temporal', 'P', 'Pre-Admision') estado, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi:ss am') as amPm, nvl(decode(a.tipo_cta, 'J', 'Jubilado', 'P', 'Particular', 'M', 'Medico', 'E', 'Empleado', 'A', 'Asegurado'),' ') as tipoCta, decode(a.conta_cred, 'C', 'CO', 'R', 'CR') as contaCred, nvl(to_char(a.corte_cta), ' ') corteCta, decode(a.provincia,null,' ',a.provincia) as provincia, nvl(a.sigla,' ') as sigla, decode(a.tomo,null,' ',a.tomo) as tomo, decode(a.asiento,null,' ',a.asiento) as asiento, nvl(a.d_cedula,' ') as dCedula, nvl(a.pasaporte,' ') as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad, h.nombre_abreviado nombreEmpresa, i.codigo numFactura, i.facturar_a tipoFactura, i.facturado_por formName, decode(i.estatus, 'A', 'Anulada', 'P', 'Activa', 'C', 'Cancelada') status, nvl((select to_char(fecha_envio,'dd/mm/yyyy') from tbl_fac_lista_envio z where enviado = 'S' and estado = 'A' and exists (select null from tbl_fac_lista_envio_det where compania = i.compania and factura = i.codigo and id = z.id and estado ='A' )),' ') as fechaAtencion from tbl_adm_admision a, (select a.admision, a.pac_id, b.nombre_abreviado from tbl_adm_beneficios_x_admision a, tbl_adm_empresa b where a.empresa = b.codigo and a.estado = 'A' and a.prioridad = 1) h, tbl_fac_factura i where a.secuencia = h.admision(+) and a.pac_id = h.pac_id(+) and a.secuencia = i.admi_secuencia and a.pac_id = i.pac_id and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id="+pacId+" and a.secuencia="+noAdmision+" order by i.estatus desc";
		System.out.println("SQL facturas\n"+sql);
		ArrayList alAdm = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);
		System.out.println("alAdm size="+alAdm.size());
		for (int i=1; i<=alAdm.size(); i++)
		{
			Admision obj = (Admision) alAdm.get(i-1);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			obj.setKey(key);

			try
			{
				iAdm.put(key, obj);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		//sql = "select getnumfactura("+pacId+", "+noAdmision+", 'N') codigo from dual";
		//CommonDataObject cdo2 = SQLMgr.getData(sql);
		sql = "select getnumfactura("+pacId+", "+noAdmision+", 'S') codigo from dual";
		CommonDataObject cdo3 = SQLMgr.getData(sql);
		
		sql = "select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'TP_CLIENTE_PAC'),-1)tp_cli_pac, a.*, decode(sign(total_facturado),0,0,(total_facturado - (cargos))) ganancia_perdida, ((cargos - descuento +nvl(a.honorarios, 0)+ debito + remanente)-(pagos_pte  + pagos_emp + credito + decode(sign(total_facturado),0,0,(total_facturado - (cargos))))) -nvl(a.pagos_pend,0) saldo from (select decode(nvl(i.total_factura, 0), 0, nvl(a.cargos, 0)+nvl(a.honorarios, 0), i.total_factura)- nvl(a.honorarios, 0) cargos, nvl(a.honorarios, 0) honorarios, nvl(b.pagos_pte, 0) pagos_pte,nvl(c.pagos_emp, 0) pagos_emp, nvl(d.debito, 0) debito, nvl(d.credito, 0) credito, nvl(e.descuento, 0) +nvl(get_desc_cds_fac("+pacId+","+noAdmision+","+ (String) session.getAttribute("_companyId") + ",'',''),0) as descuento, nvl(f.monto_clinica, 0) monto_clinica, nvl(g.remanente, 0) remanente, nvl(h.total_facturado, 0) total_facturado,nvl(bb.pagos_pend,0) as pagos_pend from (select nvl(sum(decode(tipo_transaccion, 'C', cantidad * (nvl(monto, 0) + nvl(recargo, 0)))), 0) - nvl(sum(decode(tipo_transaccion, 'D', decode(centro_servicio, 0, 0 ,cantidad* (nvl (monto, 0) + nvl (recargo, 0))))), 0) cargos, sum(decode(tipo_transaccion, 'H', cantidad * monto, 'D', decode(centro_servicio, 0, cantidad * monto * -1))) honorarios from tbl_fac_detalle_transaccion where compania = " + (String) session.getAttribute("_companyId") + " and pac_id = " + pacId + " and fac_secuencia = " + noAdmision + " and tipo_transaccion in ('C', 'H', 'D')) a, (select nvl(sum(b.monto), 0) pagos_pte from tbl_cja_transaccion_pago a, tbl_cja_detalle_pago b where a.codigo = b. codigo_transaccion and a.compania = b.compania and a.anio = b.tran_anio   and a.tipo_cliente in ('P', 'O') and a.compania = " + (String) session.getAttribute("_companyId") + "   and a.rec_status <> 'I' and exists (select null from tbl_fac_factura where pac_id=" + pacId + " and admi_secuencia=" + noAdmision + "  and estatus <> 'A' and facturar_a='P' and codigo =b.fac_codigo and compania =b.compania)) b, (select sum(pagos_pend) as pagos_pend from ( select /*nvl(sum(a.pago_total), 0) -*/ nvl(sum((select sum(b.monto) from tbl_cja_detalle_pago b where a.codigo = b.codigo_transaccion and a.compania = b.compania and a.anio = b.tran_anio and b.admi_secuencia = " + noAdmision + " and fac_codigo is null )), 0) /*+ (select nvl(sum(case when z.tipo_ajuste not in (select column_value  from table( select split((select get_sec_comp_param(z.compania,'CJA_TP_AJ_REC') from dual),',') from dual  )) then decode(z.lado_mov,'D',-z.monto,'C',z.monto) else 0 end ),0) as ajuste from vw_con_adjustment_gral z, tbl_fac_tipo_ajuste y where z.recibo = a.recibo and z.compania = a.compania and z.factura is null and z.tipo_doc = 'R' and z.tipo_ajuste = y.codigo and z.compania = y.compania and y.group_type in ('H','D'))*/ pagos_pend from tbl_cja_transaccion_pago a where a.pac_id = " + pacId + " and a.tipo_cliente in ('P', 'O') and a.compania = " + (String) session.getAttribute("_companyId") + " and a.rec_status <> 'I' and exists (select null from tbl_cja_detalle_pago b where a.codigo = b.codigo_transaccion and a.compania = b.compania and a.anio = b.tran_anio and b.admi_secuencia = " + noAdmision + " and nvl(monto,0) <> 0)  /*and not  exists (select 1 from tbl_cja_detalle_pago b where a.codigo = b.codigo_transaccion and a.compania = b.compania and a.anio = b.tran_anio and b.admi_secuencia <> " + noAdmision + "  and nvl(monto,0) <> 0 and fac_codigo is not null)*/  group by a.compania,a.recibo) ) bb, (select sum(monto) pagos_emp from tbl_cja_detalle_pago where fac_codigo in (select f.codigo from tbl_fac_factura f  where f.admi_secuencia = "+noAdmision+"/**admision**/  and f.pac_id = "+pacId+"/**pacID**/ and f.facturar_a = 'E'  and f.estatus <> 'A') and ((codigo_transaccion, compania, tran_anio) in (select codigo, compania, anio from tbl_cja_transaccion_pago where tipo_cliente in ('E') and compania = " + (String) session.getAttribute("_companyId") + "  and rec_status <>  'I')) and compania = " + (String) session.getAttribute("_companyId") + ") c, (select sum(decode (lado_mov, 'D', monto)) debito, sum(decode (lado_mov, 'C', monto)) credito from vw_con_adjustment_gral where factura in (select codigo from tbl_fac_factura where admi_secuencia = " + noAdmision + " and pac_id = " + pacId + " and compania = " + (String) session.getAttribute("_companyId") + " and estatus not in ('A'))) d, (select sum(nvl (b.descuento, 0)) descuento from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.codigo = b.fac_codigo and a.admi_secuencia ="+noAdmision+" and a.pac_id =  " + pacId + " and a.estatus <> 'A' ) e, (select sum(decode ('" + adm.getEstado() + "', 'N', 0, monto_clinica)) monto_clinica from tbl_fac_estado_cargos where admi_secuencia = " + noAdmision + " and pac_id = " + pacId + ") f, (select sum (decode (tipo, '2', monto_total, '7', -monto_total)) remanente from tbl_fac_remanente where numero_factura in (" + cdo3.getColValue("codigo") + ")) g, (select nvl((select sum(decode (b.tipo_cobertura, 'CO', nvl (b.monto, 0), 0)) + sum (decode (b.tipo_cobertura, 'P', nvl (b.monto, 0), 0)) + sum (decode (b.tipo_cobertura, 'CO', 0, 'P', 0, (nvl (b.monto, 0) + nvl (b.descuento, 0)))) total_facturado from tbl_fac_detalle_factura b, tbl_fac_factura a where (a.admi_secuencia = " + noAdmision + " and a.pac_id = " + pacId + " and a.compania = " + (String) session.getAttribute("_companyId") + ") and (b.compania = a.compania and b.fac_codigo = a.codigo and a.estatus <> 'A' and (b.tipo_cobertura in ('P', 'CO') or b.tipo_cobertura is null)) having sum(decode (b.tipo_cobertura, 'P', nvl (b.monto, 0), 0)) > 0), 0) total_facturado from dual) h, (/*select nvl((select sum(decode(df.tipo_cobertura, 'CO', 0, 'P', 0, df.monto + nvl(df.descuento, 0) + nvl(df.descuento2, 0))) total_factura from tbl_fac_factura f, tbl_fac_detalle_factura df where f.compania = df.compania and f.codigo = df.fac_codigo and f.estatus != 'A' and f.pac_id = " + pacId + " and f.admi_secuencia = " + noAdmision + " and df.tipo not in ('H', 'E')), 0) total_factura from dual  */ select sum(grang_total)+sum(nvl(monto_descuento,0)+nvl(monto_descuento2,0)+nvl(monto_descuento_hon,0)) +nvl(get_desc_cds_fac("+pacId+","+noAdmision+","+ (String) session.getAttribute("_companyId") + ",'',''),0) total_factura from tbl_fac_factura where pac_id = " + pacId + " and admi_secuencia = " + noAdmision + "  and estatus != 'A' ) i) a";
		cdoTot = SQLMgr.getData(sql);

		if (change == null)
		{
			iBen.clear();
			iAju.clear();
			iPagPte.clear();
			iPagEmp.clear();

			sql = "select a.secuencia, a.poliza, nvl(a.certificado,' ') as certificado, nvl(a.convenio_solicitud,'C') as convenioSolicitud, nvl(a.convenio_sol_emp,'N') as convenioSolEmp, prioridad, decode(a.plan,null,' ',a.plan) as plan, decode(a.convenio,null,' ',a.convenio) as convenio, a.empresa, decode(a.categoria_admi,null,' ',a.categoria_admi) as categoriaAdmi, decode(a.tipo_admi,null,' ',a.tipo_admi) as tipoAdmi, decode(a.clasif_admi,null,' ',a.clasif_admi) as clasifAdmi, decode(a.tipo_poliza,null,' ',a.tipo_poliza) as tipoPoliza, decode(a.tipo_plan,null,' ',a.tipo_plan) as tipoPlan, to_char(nvl(a.fecha_ini,sysdate),'dd/mm/yyyy hh24:mi:ss') as fechaIni, nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaFin, nvl(a.usuario_creacion,' ') as usuarioCreacion, nvl(a.usuario_modificacion,' ') as usuarioModificacion, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaModificacion, nvl(a.estado,' ') as estado, decode(a.num_aprobacion,null,' ',a.num_aprobacion) as numAprobacion, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc from tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where nvl(a.estado,'A')='A' and a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and c.empresa=d.codigo and b.tipo_plan=e.tipo_plan and b.tipo_poliza=e.poliza and b.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by a.secuencia, a.prioridad, a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi";
			System.out.println("\nBENEFICIOS\n");
			System.out.println("SQL:\n"+sql);
			al  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);

			benLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				Admision obj = (Admision) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				obj.setKey(key);

				try
				{
					iBen.put(key, obj);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			sql = "select all a.admi_secuencia as facSecuencia, a.codigo as facCodigo, "+((cdsDet.trim().equals("S"))?"c.":"a.")+"centro_servicio as centroservicio, b.descripcion sts, nvl(a.no_documento, ' ') as motivoTardio, a.tipo_transaccion tipotransaccion,c.secuencia, nvl(to_char(c.fecha_cargo, 'dd/mm/yyyy'), ' ') fechacargo, nvl(to_char(c.fecha_creacion, 'dd/mm/yyyy'), ' ') fechacreacion, nvl(c.usuario_modificacion, ' ') usuariomodificacion, c.tipo_cargo tipocargo, c.descripcion, c.cantidad, (nvl(c.monto,0) + nvl(c.recargo,0)) as monto, (nvl(c.monto,0) + nvl(c.recargo,0)) * c.cantidad as montototal from tbl_fac_transaccion a,  tbl_fac_detalle_transaccion c, tbl_cds_centro_servicio b where a.tipo_transaccion = 'C' and "+((cdsDet.trim().equals("S"))?"c.":"a.")+"centro_servicio = b.codigo and a.admi_secuencia = " + noAdmision + " and a.pac_id = " + pacId+" and a.compania = "+ (String) session.getAttribute("_companyId")+" and a.codigo = c.fac_codigo and a.pac_id = c.pac_id and a.admi_secuencia = c.fac_secuencia and a.tipo_transaccion = c.tipo_transaccion order by "+((cdsDet.trim().equals("S"))?"c.":"a.")+"centro_servicio,a.codigo";

			System.out.println("\nCARGOS\n");
			System.out.println("SQL:\n"+sql);
			alCargo  = sbb.getBeanList(ConMgr.getConnection(),sql,FactDetTransaccion.class);
			 

			sql = "select all a.admi_secuencia facSecuencia, a.codigo as facCodigo, a.tipo_transaccion tipotransaccion, nvl(a.no_documento, ' ') as motivoTardio, coalesce(nvl(b.reg_medico,a.med_codigo), to_char(a.empre_codigo)) as sts, nvl(coalesce(c.nombre, b.primer_nombre||' '||b.segundo_nombre||' '||b.primer_apellido||' '||b.segundo_apellido),'') as trabajoDesc,d.secuencia, nvl(to_char(d.fecha_cargo, 'dd/mm/yyyy'), ' ') fechacargo, nvl(to_char(d.fecha_creacion, 'dd/mm/yyyy'), ' ') fechacreacion, nvl(d.usuario_modificacion, ' ') usuariomodificacion, decode(d.honorario_por, 'M', 'Médico', 'P', 'Procedimiento Especial', 'O', 'Otros') honorariopor, d.descripcion, d.cantidad, d.monto, (nvl(d.monto,0) + nvl(d.recargo,0)) * d.cantidad as montototal from tbl_fac_transaccion a, tbl_adm_medico b, tbl_adm_empresa c,tbl_fac_detalle_transaccion d where a.tipo_transaccion = 'H' and a.med_codigo = b.codigo(+) and a.empre_codigo = c.codigo(+) and a.admi_secuencia = " + noAdmision + " and a.pac_id = " + pacId+" and a.compania = "+ (String) session.getAttribute("_companyId")+" and a.codigo = d.fac_codigo and a.pac_id = d.pac_id and a.admi_secuencia = d.fac_secuencia and a.tipo_transaccion = d.tipo_transaccion order by a.codigo ";

			System.out.println("\nHONORARIOS\n");
			System.out.println("SQL:\n"+sql);
			alHon  = sbb.getBeanList(ConMgr.getConnection(),sql,FactDetTransaccion.class);

			sql = "select all a.admi_secuencia facSecuencia, a.codigo facCodigo, a.num_solicitud, "+((cdsDet.trim().equals("S"))?"c.":"a.")+"centro_servicio centroservicio, b.descripcion centroserviciodesc, nvl(a.no_documento, ' ') nodocumento, a.tipo_transaccion tipotransaccion, c.secuencia, nvl(to_char(c.fecha_cargo, 'dd/mm/yyyy'), ' ') fechacargo, nvl(to_char(c.fecha_creacion, 'dd/mm/yyyy'), ' ') fechacreacion, nvl(c.usuario_modificacion, ' ') usuariomodificacion, c.tipo_cargo tipocargo, c.descripcion, c.cantidad, (nvl(c.monto,0) + nvl(c.recargo,0)) as monto, (nvl(c.monto,0) + nvl(c.recargo,0)) * c.cantidad montototal from tbl_fac_transaccion a,tbl_fac_detalle_transaccion c, tbl_cds_centro_servicio b where a.tipo_transaccion = 'D' and "+((cdsDet.trim().equals("S"))?"c.":"a.")+"centro_servicio = b.codigo and a.admi_secuencia = " + noAdmision + " and a.pac_id = " + pacId+" and a.compania = "+ (String) session.getAttribute("_companyId")+" and a.codigo = c.fac_codigo and a.pac_id = c.pac_id and a.admi_secuencia = c.fac_secuencia and a.tipo_transaccion = c.tipo_transaccion order by "+((cdsDet.trim().equals("S"))?"c.":"a.")+"centro_servicio";

			System.out.println("\nDEVOLUCIONES\n");
			System.out.println("SQL:\n"+sql);
			alDev  = sbb.getBeanList(ConMgr.getConnection(),sql,FactDetTransaccion.class);

			sql = "select to_char(a.fecha, 'dd/mm/yyyy') fecha, nvl(to_char(a.referencia), ' ') referencia, nvl(a.factura, ' ') factura, nvl(a.recibo, ' ') recibo, nvl(c.descripcion, ' ') centro,a.descripcion, nvl(decode(a.lado_mov, 'C', a.monto), 0) credito, nvl(decode(a.lado_mov, 'D', a.monto), 0) debito from vw_con_adjustment_gral a, tbl_cds_centro_servicio c where  a.centro = c.codigo(+)  and a.factura in (select codigo from tbl_fac_factura where pac_id =" + pacId+" and admi_secuencia ="+noAdmision+" and estatus <> 'A' and compania ="+(String) session.getAttribute("_companyId")+") and a.compania = "+ (String) session.getAttribute("_companyId");

			System.out.println("\nAJUSTES\n");
			System.out.println("SQL:\n"+sql);
			al  = SQLMgr.getDataList(sql);

			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);
				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;

				try
				{
					iAju.put(key, cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
 

			sql = "select c.anio, c.codigo, a.secuencia_pago secuenciapago, admi_secuencia admisecuencia, c.recibo, to_char(c.fecha, 'dd/mm/yyyy') fechapago, decode(c.tipo_cliente, 'P', 'Paciente', 'E', 'Empresa', 'Otros') tipocliente, decode(a.pago_por, 'C', 'Pre-Factura', 'F', 'Factura', 'D', 'Depósito', 'R', 'Remanente') pagopor, decode(a.tipo_transaccion, 1, 'Cancela', 2, 'Abono', 3, 'Co-Pago', 4, 'Depósito') tipotransaccion, c.descripcion, a.fac_codigo faccodigo, a.monto subtotal from tbl_cja_detalle_pago a,tbl_cja_transaccion_pago c where (a.compania = c.compania and a.tran_anio = c.anio and a.codigo_transaccion = c.codigo) and c.tipo_cliente in ('P', 'O') and c.rec_status <> 'I' and a.compania = "+(String) session.getAttribute("_companyId")+" and (exists (select null from tbl_fac_factura where pac_id=" + pacId + " and admi_secuencia=" + noAdmision + "  and estatus <> 'A' and facturar_a='P' and codigo =a.fac_codigo and compania =a.compania) or (c.pac_id =" + pacId + " and a.admi_secuencia=" + noAdmision + " and a.fac_codigo is null ))  order by c.recibo, a.secuencia_pago ";

			System.out.println("\nPAGOS PACIENTE\n");
			System.out.println("SQL:\n"+sql);
			al  = sbb.getBeanList(ConMgr.getConnection(),sql,TransaccionPago.class);
			String recibo="";
			for (int i=1; i<=al.size(); i++)
			{
				TransaccionPago ft = (TransaccionPago) al.get(i-1);
				if(!recibo.trim().equals(ft.getRecibo()))
				{
				sql = "select b.descripcion forma_pago, b.descripcion tipo_tarjeta, nvl(a.num_cheque,a.no_referencia) as num_cheque, a.descripcion_banco, a.monto from tbl_cja_trans_forma_pagos a, tbl_cja_forma_pago b, tbl_cja_tipo_tarjeta c where a.fp_codigo = b.codigo and a.tipo_tarjeta = c.codigo(+) and tran_anio = " + ft.getAnio() + " and tran_codigo = " + ft.getCodigo() + " and compania = " + (String) session.getAttribute("_companyId");
				//System.out.println("cargos detail = \n"+sql);
				
				ft.setDetalleTransFormaPagos(SQLMgr.getDataList(sql));}
				recibo = ft.getRecibo();

				sql = "select to_char(a.fecha,'dd/mm/yyyy') fecha, decode(a.distribucion, 'A', 'Automatica', 'Manual') distribucion, coalesce(a.med_codigo, to_char(a.empre_codigo), to_char(a.centro_servicio)) codigo, coalesce(b.descripcion, c.nombre, d.primer_apellido||' '||d.segundo_apellido||' '||d.apellido_de_casada||' '||d.primer_nombre||' '||d.segundo_nombre) descripcion, nvl(monto,0) as monto from tbl_cja_distribuir_pago a, tbl_cds_centro_servicio b, tbl_adm_empresa c, tbl_adm_medico d where a.centro_servicio = b.codigo(+) and a.empre_codigo = c.codigo(+) and a.med_codigo = d.codigo(+) and a.compania = " + (String) session.getAttribute("_companyId") + " and a.tran_anio = " + ft.getAnio() + " and a.codigo_transaccion = " + ft.getCodigo() + " and a.secuencia_pago = " + ft.getSecuenciaPago();
				System.out.println("DISTRIBUCION\n");
				ft.setDetalleDistribuirPago(SQLMgr.getDataList(sql));
				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;

				try
				{
					iPagPte.put(key, ft);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

			//if(cdo3 != null && !cdo3.getColValue("codigo").equals("")){

				sql = "select c.anio, c.codigo, a.secuencia_pago secuenciapago, admi_secuencia admisecuencia, c.recibo, to_char(c.fecha, 'dd/mm/yyyy') fechapago, decode(c.tipo_cliente, 'P', 'Paciente', 'E', 'Empresa', 'Otros') tipocliente, decode(a.pago_por, 'C', 'Pre-Factura', 'F', 'Factura', 'D', 'Depósito', 'R', 'Remanente') pagopor, decode(a.tipo_transaccion, 1, 'Cancela', 2, 'Abono', 3, 'Co-Pago', 4, 'Depósito') tipotransaccion, c.descripcion, a.fac_codigo faccodigo, a.monto subtotal from tbl_cja_detalle_pago a,tbl_cja_transaccion_pago c where (a.compania = c.compania and a.tran_anio = c.anio and a.codigo_transaccion = c.codigo) and c.rec_status <> 'I' and c.tipo_cliente in ('E') and a.compania = "+(String) session.getAttribute("_companyId") + " and exists (select 1 from tbl_fac_factura f where estatus != 'A' and a.fac_codigo = f.codigo and f.admi_secuencia = a.admi_secuencia and a.admi_secuencia = " + noAdmision +" and f.pac_id = "+pacId+") order by c.recibo, a.secuencia_pago ";


				System.out.println("\nPAGOS EMPRESA\n");
				al  = sbb.getBeanList(ConMgr.getConnection(),sql,TransaccionPago.class);
				recibo ="";
				for (int i=1; i<=al.size(); i++)
				{
					TransaccionPago fte = (TransaccionPago) al.get(i-1);
				if(!recibo.trim().equals(fte.getRecibo()))
				{
				sql = "select b.descripcion forma_pago, b.descripcion tipo_tarjeta, nvl(a.num_cheque,a.no_referencia) as num_cheque, a.descripcion_banco, a.monto from tbl_cja_trans_forma_pagos a, tbl_cja_forma_pago b, tbl_cja_tipo_tarjeta c where a.fp_codigo = b.codigo and a.tipo_tarjeta = c.codigo(+) and tran_anio = " + fte.getAnio() + " and tran_codigo = " + fte.getCodigo() + " and compania = " + (String) session.getAttribute("_companyId");
				//System.out.println("cargos detail = \n"+sql);
				fte.setDetalleTransFormaPagos(SQLMgr.getDataList(sql));
				}
				recibo = fte.getRecibo();

				sql = "select to_char(a.fecha,'dd/mm/yyyy') fecha, decode(a.distribucion, 'A', 'Automatica', 'Manual') distribucion, coalesce(a.med_codigo, to_char(a.empre_codigo), to_char(a.centro_servicio)) codigo, coalesce(b.descripcion, c.nombre, d.primer_apellido||' '||d.segundo_apellido||' '||d.apellido_de_casada||' '||d.primer_nombre||' '||d.segundo_nombre) descripcion, monto from tbl_cja_distribuir_pago a, tbl_cds_centro_servicio b, tbl_adm_empresa c, tbl_adm_medico d where a.centro_servicio = b.codigo(+) and a.empre_codigo = c.codigo(+) and a.med_codigo = d.codigo(+) and a.compania = " + (String) session.getAttribute("_companyId") + " and a.tran_anio = " + fte.getAnio() + " and a.codigo_transaccion = " + fte.getCodigo() + " and a.secuencia_pago = " + fte.getSecuenciaPago();
				System.out.println("DISTRIBUCION\n");
				fte.setDetalleDistribuirPago(SQLMgr.getDataList(sql));
					if (i < 10) key = "00" + i;
					else if (i < 100) key = "0" + i;
					else key = "" + i;

					try
					{
						iPagEmp.put(key, fte);
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
			//}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function showPacienteList(){abrir_ventana1('../common/sel_paciente.jsp?fp=consulta_general');}
function doAction(){newHeight();} 
function goOption(option)
{
	if(option==undefined)CBMSG.warning('La opción no está definida todavía.\nPor favor consulte con su Administrador!');
	else
	{
		var msg='';
		var pacId=document.form0.pacId.value;
		var noAdmision=document.form0.noAdmision.value;
		var codPac=document.form0.codigoPaciente.value;
		var categoria=document.form0.categoria.value;
		var estado=document.form0.estado.value;
		if (pacId == '' || noAdmision == '') CBMSG.warning('Seleccione Paciente y Admisión!');
		else {
			if(option==0) abrir_ventana('../admision/print_admision.jsp?mode=edit&pacId='+pacId+'&noAdmision='+noAdmision);
			else if(option==1){
				if(hasDBData('<%=request.getContextPath()%>','tbl_fac_detalle_transaccion','pac_id='+pacId+' and fac_secuencia='+noAdmision,'')) abrir_ventana('../facturacion/print_cargo_dev.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
				else CBMSG.warning('La admisión no tiene cargos registrados!');
			}
			//else if(option==2)abrir_ventana('../facturacion/reg_cargo_dev.jsp?noAdmision='+noAdmision+'&pacienteId='+pacId+'&fg=HON&fPage=general_page');
			else if(option==3) abrir_ventana1('../facturacion/print_cargo_dev_resumen2.jsp?noSecuencia='+noAdmision+'&pacId='+pacId+'&tf=');
			else if(option==4){
				var i = document.form8.index.value;
				if(i=='') CBMSG.warning('Seleccione Factura!');
				else printFact(i);
			}
			else if(option==5){
				var i = document.form8.index.value;
				if(i=='') CBMSG.warning('Seleccione Factura!');
				else printECDPF(i);
			}
			else if(option==6) abrir_ventana('../facturacion/reg_analisis_fact.jsp?mode=add&fg=AFA&noAdmision='+noAdmision+'&pacienteId='+pacId);
			else if(option==7) printRFP();
			else if(option==8) abrir_ventana('../facturacion/print_pagos_x_admision.jsp?noSecuencia='+noAdmision+'&pacId='+pacId);
			else if(option==9) abrir_ventana1('../facturacion/print_cargo_dev_resumen2.jsp?noSecuencia='+noAdmision+'&pacId='+pacId+'&tf=');
			else if(option==10) abrir_ventana1('../facturacion/reg_facturacion_manual.jsp?noAdmision='+noAdmision+'&pacId='+pacId+'&mode=view');
		}
	}//admision selected
}

function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 0:msg='Imprimir Boleta de Admisión';break;
		case 1:msg='Imprimir Detalles de Cargos';break;
		//case 2:msg='Imprimir Detalle de Cuenta';break;
		case 3:msg='Imprimir Análisis';break;
		case 4:msg='Imprimir Factura';break;
		case 5:msg='Detallado por Factura';break;
		case 6:msg='Admisión Facturada';break;
		case 7:msg='Resumen de Facturas';break;
		case 8:msg='Pagos Por Admision';break;
		case 9:msg='Imprimir Análisis';break;
		case 10:msg='Ver Análisis';break;
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

function setIndex(k)
{
	document.form8.index.value=k;
	checkOne('form8','check',<%=iAdm.size()%>,eval('document.form8.check'+k),1);
}

function printFact(i){
	var pac_id = document.form8.pacId.value;
	var admision = document.form8.noAdmision.value;
	var formName = eval('document.form8.formName'+i).value;
	var facturadoA = eval('document.form8.facturadoA'+i).value;
	var factId = eval('document.form8.factId'+i).value;

	var rName = '';

	if(formName=='FAC40011' && facturadoA == 'P') rName = 'FAC10086';
	else if(formName=='FAC40011' && facturadoA == 'E') rName = 'FAC10087';
	else if((formName=='FACPROTOTIPO' || formName=='FAC90063') && facturadoA == 'P') rName = 'FAC70551';
	else if((formName=='FACPROTOTIPO' || formName=='FAC90063') && facturadoA == 'E') rName = 'FAC70561';

	if(formName=='FAC40010') abrir_ventana1('../facturacion/print_factura.jsp?noSecuencia='+admision+'&pacId='+pac_id+'&facturar_a='+facturadoA+'&factId='+factId);
	else if(formName=='FAC40011' || formName=='FAC40012' || formName=='FACPROTOTIPO' || formName=='FAC90063') abrir_ventana1('../facturacion/print_factura_others.jsp?noSecuencia='+admision+'&pacId='+pac_id+'&facturar_a='+facturadoA+'&reportName='+rName+'&factId='+factId);
	else abrir_ventana1('../facturacion/print_factura.jsp?factura='+factId+'&compania=<%=session.getAttribute("_companyId")%>');
}

function printECDPF(i){
	var pac_id = document.form8.pacId.value;
	var factId = eval('document.form8.factId'+i).value;
	abrir_ventana1('../facturacion/print_estado_cargo_det.jsp?pacId='+pac_id+'&factId='+factId);
}

<!-- W I N D O W S -->
//Windows Size and Position
var _winWidth=screen.availWidth*0.35;
var _winHeight=screen.availHeight*0.35;
var _winPosX=(screen.availWidth-_winWidth)/2;
var _winPosY=(screen.availHeight-_winHeight)/2;
var _popUpOptions='toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+_winWidth+',height='+_winHeight+',top='+_winPosY+',left='+_winPosX;
function printRFP()
{
	var pacId = '<%=pacId%>';
	var val = '../common/sel_periodo.jsp?fg=PAC&pac_id='+pacId+'&refId='+pacId+'&refType=<%=cdoTot.getColValue("tp_cli_pac")%>&referTo=PAC';
	if(pacId!='')	window.open(val,'datesWindow',_popUpOptions);
	else CBMSG.warning('Seleccione Paciente/Admisión!');
}

function refreshAdmision(noAdmision)
{
	//setFrameSrc('iExpHistory','../expediente/expediente_history.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision='+noAdmision);
	if(noAdmision.trim()!='')
	window.location='../admision/consulta_general.jsp?mode=view&pacId=<%=pacId%>&noAdmision='+noAdmision;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr class="TextRow02">
	<td>&nbsp;</td>
</tr>
<tr class="TextRow02">
	<td>&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
			<tr>
				<td align="right">
					<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
					<a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/printer.gif"></a>
					<a href="javascript:goOption(1)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/print-shopping-cart.gif"></a>
					<!--<a href="javascript:goOption(2)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/doctor-money.jpg"></a>-->
					<a href="javascript:goOption(3)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,3)" onMouseOut="javascript:mouseOut(this,3)" src="../images/print_analysis.gif"></a>
					<a href="javascript:goOption(4)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,4)" onMouseOut="javascript:mouseOut(this,4)" src="../images/print_bill.gif"></a>
					<a href="javascript:goOption(5)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,5)" onMouseOut="javascript:mouseOut(this,5)" src="../images/print_bill_details.gif"></a>
					<!--<a href="javascript:goOption(6);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,6)" onMouseOut="javascript:mouseOut(this,6)" src="../images/pills-3.jpg"></a>-->
					<a href="javascript:goOption(7);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,7)" onMouseOut="javascript:mouseOut(this,7)" src="../images/print_bills.gif"></a>
					<a href="javascript:goOption(8);"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,8)" onMouseOut="javascript:mouseOut(this,8)" src="../images/payment.jpg"></a>
						<authtype type='66'>
					<a href="javascript:goOption(10)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,10)" onMouseOut="javascript:mouseOut(this,10)" src="../images/search.gif"></a></authtype>
				</td>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("form_0",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
		<tr class="TextHeader">
			<td colspan="11" align="center">
				<cellbytelabel id="1">Admisiones Anteriores (Fecha Ing. - No. Adm. - Categor&iacute;a - Tipo Adm. - CDS)</cellbytelabel>:<br>
				<%=fb.select(ConMgr.getConnection(),"select a.secuencia, to_char(a.fecha_ingreso,'dd/mm/yyyy')||' - '||a.secuencia||' - '||b.descripcion||' - '||c.descripcion||' - '||d.descripcion from tbl_adm_admision a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_cia c, tbl_cds_centro_servicio d where a.pac_id="+pacId+" and a.secuencia!="+noAdmision+" and a.categoria=b.codigo and a.categoria=c.categoria and a.tipo_admision=c.codigo and a.centro_servicio=d.codigo order by a.secuencia desc","oldAdm","",false,false,0,"Text10",null,"onChange=\"javascript:refreshAdmision(this.value)\"","Lista de Admisiones Anteriores","S")%>
				<%=fb.button("go","Ver",false,false,"Text10",null,"onClick=\"javascript:refreshAdmision(document."+fb.getFormName()+".oldAdm.value)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<%fb = new FormBean("form00",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="2">Paciente/Admisi&oacute;n</cellbytelabel></td>
			<td colspan="10">
				<%=fb.textBox("nombrePaciente",adm.getNombrePaciente(),false,false,false,50)%>
				<%=fb.textBox("noAdmision",adm.getNoAdmision(),false,false,false,10)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.button("btnPaciente","...",true,false,null,null,"onClick=\"javascript:showPacienteList()\"")%>
			</td>
		</tr>
		<tr class="TextPanel">
			<td width="9%" align="center"><cellbytelabel id="3">Cargos Netos</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="4">Honorarios</cellbytelabel></td>
			<!--<td width="9%" align="center">Devoluciones</td>-->
			<td width="9%" align="center"><cellbytelabel id="5">Descuento</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="6">D&eacute;bitos</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="7">Cr&eacute;ditos</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="8">Pagos Pac</cellbytelabel>.</td>
			<td width="9%" align="center"><cellbytelabel id="9">Pagos Pend. Aplic. A Fact.</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="10">Pagos Emp.</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="11">Rem. Aseg.</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="12">Ganancia/P&eacute;rdida</cellbytelabel></td>
			<td width="9%" align="center"><cellbytelabel id="13">SALDO</cellbytelabel></td>
		</tr>
		<tr>
			<td align="right"><%=(cdoTot.getColValue("cargos")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("cargos")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("honorarios")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("honorarios")):"0.00"%>&nbsp;</td>
			<!--<td align="right"><%=(cdoTot.getColValue("devoluciones")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("devoluciones")):"0.00"%>&nbsp;</td>-->
			<td align="right"><%=(cdoTot.getColValue("descuento")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("descuento")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("debito")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("debito")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("credito")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("credito")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("pagos_pte")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("pagos_pte")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("pagos_pend")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("pagos_pend")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("pagos_emp")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("pagos_emp")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("remanente")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("remanente")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("ganancia_perdida")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("ganancia_perdida")):"0.00"%>&nbsp;</td>
			<td align="right"><%=(cdoTot.getColValue("saldo")!=null)?CmnMgr.getFormattedDecimal(cdoTot.getColValue("saldo")):"0.00"%>&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd(true)%>

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
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="14">Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="15">Nombre</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("nombrePaciente",adm.getNombrePaciente(),false,false,false,50)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="16">C&eacute;dula</cellbytelabel></td>
							<td width="35%">
								<%=fb.intBox("provincia",adm.getProvincia(),false,false,false,2)%>
								<%=fb.textBox("sigla",adm.getSigla(),false,false,false,2)%>
								<%=fb.intBox("tomo",adm.getTomo(),false,false,false,4)%>
								<%=fb.intBox("asiento",adm.getAsiento(),false,false,false,5)%>
								<%=fb.select("dCedula","D,R,H1,H2,H3,H4,H5",adm.getDCedula())%>
							</td>
							<td width="15%" align="right"><cellbytelabel id="17">Pasaporte</cellbytelabel></td>
							<td width="35%"><%=fb.textBox("pasaporte",adm.getPasaporte(),false,false,false,20)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="18">Fecha de Nacimiento</cellbytelabel></td>
							<td>
								<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
								<%=fb.textBox("fechaNac",adm.getFechaNacimientoAnt(),false,false,false,10)%>
								<%//=fb.textBox("fechaNacimiento",adm.getFechaNacimiento(),false,false,false,10)%>
								<%=fb.intBox("codigoPaciente",adm.getCodigoPaciente(),false,false,false,3)%>
							</td>
							<td align="right"><cellbytelabel id="19">Responsable de la Cta.</cellbytelabel></td>
							<td><%=fb.select("responsabilidad","P=PACIENTE,O=OTRA EMPRESA,E=EMPRESA",adm.getResponsabilidad())%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="20">M&eacute;dico</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="21">C&oacute;digo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("medico",adm.getMedico(),false,false,false,15)%>
								<%=fb.textBox("nombreMedico",adm.getNombreMedico(),false,false,false,50)%>
								<!--<%=fb.button("btnMedico","...",false,false,null,null,"onClick=\"javascript:showMedicoList('especialidad')\"")%>-->
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="22">Especialidad</cellbytelabel></td>
							<td colspan="3"><%=fb.textBox("especialidad",adm.getEspecialidad(),false,false,false,50)%></td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="23">M&eacute;dico Cabecera</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="21">C&oacute;digo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("medicoCabecera",adm.getMedicoCabecera(),false,false,true,15,null,null,"onDblClick=\"javascript:clearMedico('cabecera')\"")%>
								<%=fb.textBox("nombreMedicoCabecera",adm.getNombreMedicoCabecera(),false,false,true,50,null,null,"onDblClick=\"javascript:clearMedico('cabecera')\"")%>
								<!--<%=fb.button("btnMedicoCabecera","...",false,false,null,null,"onClick=\"javascript:showMedicoList('cabecera')\"")%>-->
							</td>
						</tr>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="24">Admisi&oacute;n</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="25">No.</cellbytelabel></td>
							<td><%=adm.getNoAdmision()%></td>
							<td align="right"><cellbytelabel id="26">Estado</cellbytelabel></td>
							<td><%=fb.select("estado","A=ACTIVA,P=PRE ADMISIONES,S=ESPECIAL,E=ESPERA,I=INACTIVO,N=ANULADA",adm.getEstado(),false,false,0,null,null,"onChange=\"javascript:validatePreAdmision()\"")%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right">&<cellbytelabel id="27">Aacute;rea</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("centroServicio",adm.getCentroServicio(),false,false,false,5)%>
								<%=fb.textBox("centroServicioDesc",adm.getCentroServicioDesc(),false,false,false,50)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="27">Categor&iacute;a</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("categoria",adm.getCategoria(),false,false,false,4)%>
								<%=fb.textBox("categoriaDesc",adm.getCategoriaDesc(),false,false,false,50)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="28">Tipo</cellbytelabel></td>
							<td colspan="3">
								<%=fb.intBox("tipoAdmision",adm.getTipoAdmision(),false,false,false,2)%>
								<%=fb.textBox("tipoAdmisionDesc",adm.getTipoAdmisionDesc(),false,false,false,50)%>
								<!--<%=fb.button("btnTipoAdmision","...",false,false,null,null,"onClick=\"javascript:showTipoAdmisionList()\"")%>-->
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="29">Fecha y Hora de Ingreso</cellbytelabel></td>
							<td>
								<%=fb.textBox("fechaIngreso",adm.getFechaIngreso(),false,false,false,10)%>
								<%=fb.textBox("amPm",adm.getAmPm(),false,false,true,8)%>
							</td>
							<td align="right"><cellbytelabel id="30">Fecha Preadmisi&oacute;n</cellbytelabel></td>
							<td><%=fb.textBox("fechaPreadmision",adm.getFechaPreadmision(),false,false,false,20)%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="31">D&iacute;as Estimados</cellbytelabel></td>
							<td><%=fb.intBox("diasEstimados",adm.getDiasEstimados(),false,false,false,3)%></td>
							<td align="right"><cellbytelabel id="31">Contado / Cr&eacute;dito</cellbytelabel></td>
							<td><%=fb.select("contaCred","R=CREDITO",adm.getContaCred())%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="32">Tipo de Paciente (Descuento)</cellbytelabel></td>
							<td><%=fb.select("tipoCta","J=JUBILADO,E=EMPLEADO,M=MEDICO,P=PARTICULAR,A=ASEGURADO",adm.getTipoCta())%></td>
							<td align="right"><cellbytelabel id="33">Hospitalizaci&oacute;n Directa</cellbytelabel></td>
							<td><%=fb.select("hospDirecta","N=NO,S=SI",adm.getHospDirecta())%></td>
						</tr>
						</table>
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
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="34">Beneficios Asignados</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel id="25">No.</cellbytelabel></td>
							<td width="36%"><cellbytelabel id="35">Aseguradora</cellbytelabel></td>
							<td width="24%"><cellbytelabel id="36">P&oacute;liza</cellbytelabel></td>
							<td width="15%"><cellbytelabel id="37">Certificado</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="38">Prioridad</cellbytelabel></td>
							<td width="10%"><cellbytelabel id="26">Estado</cellbytelabel></td>
							<td width="3%">&nbsp;</td>
						</tr>
<%
String jsValidation = "";
al = CmnMgr.reverseRecords(iBen);
for (int i=1; i<=iBen.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iBen.get(key);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";

%>
						<tr class="<%=color%>">
							<td><%=obj.getSecuencia()%></td>
							<td>
								[<%=obj.getEmpresa()%>]
								<%=obj.getNombreEmpresa()%>
							</td>
							<td align="center">
								<%=fb.textBox("poliza"+i,obj.getPoliza(),true,false,true,30,30)%>
							</td>
							<td align="center"><%=fb.textBox("certificado"+i,obj.getCertificado(),false,true,false,20,20)%></td>
							<td align="center"><%=fb.intBox("prioridad"+i,(obj.getPrioridad() != null && !obj.getPrioridad().trim().equals("")&&(obj.getSecuencia() != null && !obj.getSecuencia().equals("0")))?obj.getPrioridad():""+prioridad,(!obj.getStatus().trim().equals("D")),true,false,2,2,null,null,"onBlur=\"javascript:isDuplicatedBeneficioPrioridad()\"")%></td>
							<td align="center"><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",obj.getEstado(),false,true,0,null,null,"")%></td>
							<td rowspan="2" align="center"><%=(obj.getSecuencia() != null && obj.getSecuencia().equals("0"))?fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Beneficio"):""%></td>
						</tr>
						<tr class="<%=color%>">
							<td colspan="6">
								<table width="100%" cellpadding="1" cellspacing="0">
									<tr class="<%=color%>">
										<td width="13%" align="right">Tipo de P&oacute;liza:</td>
										<td width="20%">
											[<%=obj.getTipoPoliza()%>]
											<%=obj.getNombreTipoPoliza()%>
										</td>
										<td width="13%" align="right">Tipo de Plan:</td>
										<td width="20%">
											[<%=obj.getTipoPlan()%>]
											<%=obj.getNombreTipoPlan()%>
										</td>
										<td width="12%" align="right">Plan Asignado:</td>
										<td width="22%">
											[<%=obj.getPlan()%>]
											<%=obj.getNombrePlan()%>
										</td>
									</tr>
									<tr class="<%=color%>">
										<td align="right">Categor&iacute;a Admisi&oacute;n:</td>
										<td>
											[<%=obj.getCategoriaAdmi()%>]
											<%=obj.getCategoriaAdmiDesc()%>
										</td>
										<td align="right">Tipo Admisi&oacute;n:</td>
										<td>
											[<%=obj.getTipoAdmi()%>]
											<%=obj.getTipoAdmiDesc()%>
										</td>
										<td align="right">Clasificaci&oacute;n:</td>
										<td>
											[<%=obj.getClasifAdmi()%>]
											<%=obj.getClasifAdmiDesc()%>
										</td>
									</tr>
									<tr class="<%=color%>">
										<td align="right">Doble Cobertura?</td>
										<td><%=fb.checkbox("convenioSolEmp"+i,"S",(obj.getConvenioSolEmp() != null && obj.getConvenioSolEmp().equalsIgnoreCase("S")),false,null,null,"onClick=\"javascript:isFirstPriority("+i+")\"")%></td>
										<td align="right">No. Aprobaci&oacute;n AXA</td>
										<td><%=fb.intBox("numAprobacion"+i,obj.getNumAprobacion(),false,false,false,10,10)%></td>
										<td align="right">&nbsp;</td>
										<td>&nbsp;</td>
									</tr>
								</table>
							</td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB4 DIV END HERE-->
</div>

<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(21)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						   <tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="39">Cargos</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21" style="display:none">+</label><label id="minus21">-</label></font>]&nbsp;</td>
						  </tr>
						</table>
					</td>
				</tr>
				<tr id="panel21">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						  <tr class="TextHeader" align="center">
							<td width="15%" align="center"><cellbytelabel id="39">Adm.</cellbytelabel></td>
							<td width="15%" align="center"><cellbytelabel id="40">Tr No.</cellbytelabel></td>
							<td width="55%" colspan="2" align="center">Area de Servicio</td>
							<td width="15%" align="center"><cellbytelabel id="41">No. Doc.</cellbytelabel></td>
							<td width="5%" align="center">&nbsp;&nbsp;</td>
						  </tr>
<%
String facCodigo="";
for (int i=1; i<=alCargo.size(); i++)
{
	FactDetTransaccion obj = (FactDetTransaccion) alCargo.get(i-1);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";

%>
					<%if(!obj.getFacCodigo().trim().equals(facCodigo)){%>
					<%if(i!=1){%>
					       	    <tr class="TextRow05">
									<td align="right" colspan="8">Total:</td>
									<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
								</tr>
						    </table>
					     </td>
					</tr>
					<%
					total=0;
					}%> 
						<tr class="<%=color%>" onClick="javascript:showHide(21<%=i%>)" style="text-decoration:none; cursor:pointer">
							<td align="center"><%=obj.getFacSecuencia()%></td>
							<td align="center"><%=obj.getFacCodigo()%></td>
							<td align="center"><%=obj.getCentroServicio()%></td>
							<td align="left"><%=obj.getSts()%></td>
							<td align="center"><%=obj.getMotivoTardio()%></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus21<%=i%>" style="display:none">+</label><label id="minus21<%=i%>">-</label></font>]&nbsp;</td>
						</tr>
						
						<tr class="<%=color%>" id="panel21<%=i%>">
							<td colspan="6">
								<table width="100%" cellpadding="1" cellspacing="0">
								
									<tr class="TextHeader02">
										<td width="8%" align="center"><cellbytelabel id="25">No.</cellbytelabel></td>
										<td width="8%" align="center"><cellbytelabel id="42">Fecha Cargo</cellbytelabel></td>
										<td width="8%" align="center"><cellbytelabel id="43">Creado el</cellbytelabel></td>
										<td width="10%" align="center"><cellbytelabel id="44">Modif. por</cellbytelabel></td>
										<td width="10%" align="center"><cellbytelabel id="45">Serv.</cellbytelabel></td>
										<td width="30%"><cellbytelabel id="46">Descripci&oacute;n del Cargo</cellbytelabel></td>
										<td width="8%" align="right"><cellbytelabel id="47">Cantidad</cellbytelabel></td>
										<td width="8%" align="right"><cellbytelabel id="48">P / U</cellbytelabel>.</td>
										<td width="10%" align="right"><cellbytelabel id="49">Sub-Total</cellbytelabel></td>
									</tr>
									
			<%} %>
									<% 
									 	facCodigo=obj.getFacCodigo();
										total += Double.parseDouble(obj.getMontoTotal());
										String color2 = "TextRow03";
										if (i % 2 == 0) color2 = "TextRow04";
										%>
									<tr class="<%=color2%>">
										<td width="8%" align="center"><%=obj.getSecuencia()%></td>
										<td width="8%" align="center"><%=obj.getFechaCargo()%></td>
										<td width="8%" align="center"><%=obj.getFechaCreacion()%></td>
										<td width="10%" align="center"><%=obj.getUsuarioModificacion()%></td>
										<td width="10%" align="center"><%=obj.getTipoCargo()%></td>
										<td width="30%"><%=obj.getDescripcion()%></td>
										<td width="8%" align="right"><%=obj.getCantidad()%></td>
										<td width="8%" align="right"><%=CmnMgr.getFormattedDecimal(obj.getMonto())%></td>
										<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(obj.getMontoTotal())%></td>
									</tr>
<%
}
if(alCargo.size()!=0){
%>
									<tr class="TextRow05">
										<td align="right" colspan="8">Total:</td>
										<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
									</tr>
								</table>
							</td>
						</tr>
						<%}%>						  
						  
						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="4">Honorarios</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel31">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%" align="center"><cellbytelabel id="50">Admi.</cellbytelabel></td>
							<td width="15%" align="center"><cellbytelabel id="51">Documento</cellbytelabel></td>
							<td width="15%" align="center"><cellbytelabel id="21">C&oacute;digo</cellbytelabel></td>
							<td width="55%" align="center"><cellbytelabel id="15">Nombre</cellbytelabel></td>
							<td width="5%" align="center">&nbsp;&nbsp;</td>
						</tr>
<% total=0.0;  facCodigo="";
for (int i=1; i<=alHon.size(); i++)
{ 
	FactDetTransaccion obj = (FactDetTransaccion) alHon.get(i-1);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";
 
%>
					<%if(!obj.getFacCodigo().trim().equals(facCodigo)){%>
					<%if(i!=1){%>
								<tr class="TextRow05">
									<td align="right" colspan="6">Total:</td>
									<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
								</tr>
						    </table>
					     </td>
					</tr>					
					<%
					total=0;
					 facCodigo=obj.getFacCodigo();
					}%> 
						<tr class="<%=color%>" onClick="javascript:showHide(31<%=i%>)" style="text-decoration:none; cursor:pointer">
							<td align="center"><%=obj.getFacSecuencia()%></td>
							<td align="center"><%=obj.getMotivoTardio()%></td>
							<td align="center"><%=obj.getSts()%></td>
							<td align="left"><%=obj.getTrabajoDesc()%></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31<%=i%>" style="display:none">+</label><label id="minus31<%=i%>">-</label></font>]&nbsp;</td>
						</tr>
						<tr class="<%=color%>" id="panel31<%=i%>">
							<td colspan="5">
								<table width="100%" cellpadding="1" cellspacing="0">
									<tr class="TextHeader02">
										<td width="8%" align="center"><cellbytelabel id="42">Fecha Cargo</cellbytelabel></td>
										<td width="8%" align="center"><cellbytelabel id="43">Creado el</cellbytelabel></td>
										<td width="18%" align="center"><cellbytelabel id="44">Modif. por</cellbytelabel></td>
										<td width="40%" align="center"><cellbytelabel id="52">Honorario Por</cellbytelabel></td>
										<td width="8%" align="right"><cellbytelabel id="47">Cantidad</cellbytelabel></td>
										<td width="8%" align="right"><cellbytelabel id="53">Monto</cellbytelabel></td>
										<td width="10%" align="right"><cellbytelabel id="49">Sub-Total</cellbytelabel></td>
									</tr>
				<%}%>
									<%
									 
										total += Double.parseDouble(obj.getMontoTotal());
										String color2 = "TextRow03";
										if (i % 2 == 0) color2 = "TextRow04";
										%>
									<tr class="<%=color2%>">
										<td width="8%" align="center"><%=obj.getFechaCargo()%></td>
										<td width="8%" align="center"><%=obj.getFechaCreacion()%></td>
										<td width="18%" align="center"><%=obj.getUsuarioModificacion()%></td>
										<td width="40%" align="center"><%=obj.getHonorarioPor()%></td>
										<td width="8%" align="right"><%=obj.getCantidad()%></td>
										<td width="8%" align="right"><%=CmnMgr.getFormattedDecimal(obj.getMonto())%></td>
										<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(obj.getMontoTotal())%></td>
									</tr>
<%
}
if(alHon.size()!=0){
%>
						<tr class="TextRow05">
							<td align="right" colspan="6">Total:</td>
							<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
						</tr>
						
</table>
							</td>
						</tr>
<%}%>

						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
				</table>
<!-- TAB3 DIV END HERE-->
</div>						

<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("mode",mode)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Devoluciones</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel41">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="15%" align="center"><cellbytelabel id="39">Adm.</cellbytelabel></td>
							<td width="15%" align="center"><cellbytelabel id="40">Tr No.</cellbytelabel></td>
							<td width="55%" colspan="2" align="center">Area de Servicio</td>
							<td width="15%" align="center"><cellbytelabel id="41">No. Doc.</cellbytelabel></td>
							<td width="5%" align="center">&nbsp;&nbsp;</td>
						</tr>
<% total=0.0;facCodigo="";
for (int i=1; i<=alDev.size(); i++)
{
	FactDetTransaccion obj = (FactDetTransaccion) alDev.get(i-1);
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";
 
%>
					<%if(!obj.getFacCodigo().trim().equals(facCodigo)){%>
					<%if(i!=1){%>
					       	    <tr class="TextRow05">
									<td align="right" colspan="7">Total:</td>
									<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
								</tr>
						    </table>
					     </td>
					</tr>
					<%
					total=0;
					}%> 
						<tr class="<%=color%>" onClick="javascript:showHide(41<%=i%>)" style="text-decoration:none; cursor:pointer">
							<td align="center"><%=obj.getFacSecuencia()%></td>
							<td align="center"><%=obj.getFacCodigo()%></td>
							<td align="center"><%=obj.getCentroServicio()%></td>
							<td align="left"><%=obj.getSts()%></td>
							<td align="center"><%=obj.getMotivoTardio()%></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41<%=i%>" style="display:none">+</label><label id="minus41<%=i%>">-</label></font>]&nbsp;</td>
						</tr>
			
						<tr class="<%=color%>" id="panel41<%=i%>">
							<td colspan="6">
								<table width="100%" cellpadding="1" cellspacing="0">
									<tr class="TextHeader02">
										<td width="8%" align="center"><cellbytelabel id="25">No.</cellbytelabel></td>
										<td width="8%" align="center"><cellbytelabel id="42">Fecha Cargo</cellbytelabel></td>
										<td width="8%" align="center"><cellbytelabel id="43">Creado el</cellbytelabel></td>
										<td width="10%" align="center"><cellbytelabel id="45">Serv.</cellbytelabel></td>
										<td width="30%"><cellbytelabel id="46">Descripci&oacute;n del Cargo</cellbytelabel></td>
										<td width="8%" align="right"><cellbytelabel id="47">Cantidad</cellbytelabel></td>
										<td width="8%" align="right"><cellbytelabel id="53">Monto</cellbytelabel></td>
										<td width="10%" align="right"><cellbytelabel id="49">Sub-Total</cellbytelabel></td>
									</tr>
			<%}%>				   
			<%
									    facCodigo=obj.getFacCodigo();
									    total += Double.parseDouble(obj.getMontoTotal()); 
										String color2 = "TextRow03";
										if (i % 2 == 0) color2 = "TextRow04";
										%>
									<tr class="<%=color2%>">
										<td width="8%" align="center"><%=obj.getSecuencia()%></td>
										<td width="8%" align="center"><%=obj.getFechaCargo()%></td>
										<td width="8%" align="center"><%=obj.getFechaCreacion()%></td>
										<td width="10%" align="center"><%=obj.getTipoCargo()%></td>
										<td width="30%"><%=obj.getDescripcion()%></td>
										<td width="8%" align="right"><%=obj.getCantidad()%></td>
										<td width="8%" align="right"><%=CmnMgr.getFormattedDecimal(obj.getMonto())%></td>
										<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(obj.getMontoTotal())%></td>
									</tr>
<%
}
if(alDev.size()!=0){
%>
									<tr class="TextRow05">
										<td align="right" colspan="7">Total:</td>
										<td width="10%" align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
									</tr>
								</table>
							</td>
						</tr>
<%}%>
						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB4 DIV END HERE-->
</div>
<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("mode",mode)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(41)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="54">Ajustes</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus41" style="display:none">+</label><label id="minus41">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel41">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="10%" align="center"><cellbytelabel id="55">Fecha</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="56">Referencia</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="57">Factura</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="58">Recibo</cellbytelabel></td>
							<td width="15%" align="center"><cellbytelabel id="59">Centro de Servicio</cellbytelabel></td>
							<td width="25%" align="center"><cellbytelabel id="60">Descripci&oacute;n</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="61">D&eacute;bito</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="62">Cr&eacute;dito</cellbytelabel></td>
						</tr>
<%
double totDebit = 0.00, totCredit = 0.00;
al = CmnMgr.reverseRecords(iAju);
for (int i=1; i<=iAju.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject obj = (CommonDataObject) iAju.get(key);
	totDebit += Double.parseDouble(obj.getColValue("debito"));
	totCredit += Double.parseDouble(obj.getColValue("credito"));
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";

%>
						<tr class="<%=color%>"  style="text-decoration:none; cursor:pointer">
							<td align="center"><%=obj.getColValue("fecha")%></td>
							<td align="center"><%=obj.getColValue("referencia")%></td>
							<td align="center"><%=obj.getColValue("factura")%></td>
							<td align="left"><%=obj.getColValue("recibo")%></td>
							<td align="center"><%=obj.getColValue("centro")%></td>
							<td align="center"><%=obj.getColValue("descripcion")%></td>
							<td align="center"><%=CmnMgr.getFormattedDecimal(obj.getColValue("debito"))%></td>
							<td align="center"><%=CmnMgr.getFormattedDecimal(obj.getColValue("credito"))%></td>
						</tr>
<%
}
%>
						<tr class="TextRow05">
							<td align="right" colspan="6"><cellbytelabel id="63">Totales</cellbytelabel></td>
							<td align="center"><%=CmnMgr.getFormattedDecimal(totDebit)%></td>
							<td align="center"><%=CmnMgr.getFormattedDecimal(totCredit)%></td>
						</tr>
						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>
<!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","6")%>
<%=fb.hidden("mode",mode)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="64">Pagos Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="8%" align="center"><cellbytelabel id="50">Admi.</cellbytelabel></td>
							<td width="8%" align="center"><cellbytelabel id="58">Recibo</cellbytelabel></td>
							<td width="8%" align="center"><cellbytelabel id="65">Fecha Pago</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="66">Tipo Clte.</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="67">Pago por</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="68">Tipo Transacci&oacute;n</cellbytelabel></td>
							<td width="25%" align="center"><cellbytelabel id="60">Descripci&oacute;n</cellbytelabel></td>
							<td width="8%" align="center"><cellbytelabel id="57">Factura</cellbytelabel></td>
							<td width="8%" align="center"><cellbytelabel id="69">Subtotal</cellbytelabel></td>
							<td width="5%" align="center">&nbsp;&nbsp;</td>
						</tr>
<%
al = CmnMgr.reverseRecords(iPagPte);
for (int i=1; i<=iPagPte.size(); i++)
{
	key = al.get(i - 1).toString();
	TransaccionPago obj = (TransaccionPago) iPagPte.get(key);
	String color = "TextRow03";
	//if (i % 2 == 0) color = "TextRow02";

%>
						<tr class="<%=color%>" onClick="javascript:showHide(61<%=i%>)" style="text-decoration:none; cursor:pointer">
							<td align="center"><%=obj.getAdmiSecuencia()%></td>
							<td align="center"><%=obj.getRecibo()%></td>
							<td align="center"><%=obj.getFechaPago()%></td>
							<td align="left"><%=obj.getTipoCliente()%></td>
							<td align="center"><%=obj.getPagoPor()%></td>
							<td align="center"><%=obj.getTipoTransaccion()%></td>
							<td align="center"><%=obj.getDescripcion()%></td>
							<td align="center"><%=obj.getFacCodigo()%></td>
							<td align="center"><%=CmnMgr.getFormattedDecimal(obj.getSubtotal())%></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus61<%=i%>" style="display:none">+</label><label id="minus61<%=i%>">-</label></font>]&nbsp;</td>
						</tr>
						<tr class="<%=color%>" id="panel61<%=i%>">
							<td colspan="10">
							
								<table width="100%" cellpadding="1" cellspacing="0">
								<%if(obj.getDetalleTransFormaPagos().size()>0){%>
									<tr class="TextHeader02">
										<td width="15%" align="center"><cellbytelabel id="70">Forma</cellbytelabel></td>
										<td width="15%" align="center"><cellbytelabel id="71">Tarjeta</cellbytelabel></td>
										<td width="10%" align="center"><cellbytelabel id="72"># Cheque/Refer.</cellbytelabel></td>
										<td width="50%"><cellbytelabel id="73">Banco</cellbytelabel></td>
										<td width="10%" align="right"><cellbytelabel id="53">Monto</cellbytelabel></td>
									</tr>
									<%
									for (int j=0; j<obj.getDetalleTransFormaPagos().size(); j++)
									{
										CommonDataObject det = (CommonDataObject) obj.getDetalleTransFormaPagos().get(j);
										String color2 = "TextRow03";
										if (j % 2 == 0) color2 = "TextRow04";
										%>
									<tr class="<%=color2%>">
										<td align="left"><%=det.getColValue("forma_pago")%></td>
										<td align="left"><%=det.getColValue("tipo_tarjeta")%></td>
										<td align="center"><%=det.getColValue("num_cheque")%></td>
										<td align="left"><%=det.getColValue("descripcion_banco")%></td>
										<td align="right" ><%=CmnMgr.getFormattedDecimal(det.getColValue("monto"))%></td>
									</tr>
									<%
									}}
									%>


									<tr class="TextHeader02">
										<td width="15%" align="center"><cellbytelabel id="55">Fecha</cellbytelabel></td>
										<td width="15%" align="center"><cellbytelabel id="74">Modo Dist.</cellbytelabel></td>
										<td width="10%" align="center"><cellbytelabel id="21">C&oacute;digo</cellbytelabel></td>
										<td width="50%"><cellbytelabel id="75">Distribuido a</cellbytelabel></td>
										<td width="10%" align="right"><cellbytelabel id="76">Monto Distribuido</cellbytelabel></td>
									</tr>
									<%
									total = 0.00;
									for (int j=0; j<obj.getDetalleDistribuirPago().size(); j++)
									{
										CommonDataObject det = (CommonDataObject) obj.getDetalleDistribuirPago().get(j);
										total += Double.parseDouble(det.getColValue("monto"));
										String color2 = "TextRow03";
										if (j % 2 == 0) color2 = "TextRow04";
										%>
									<tr class="<%=color2%>">
										<td align="left"><%=det.getColValue("fecha")%></td>
										<td align="left"><%=det.getColValue("distribucion")%></td>
										<td align="center"><%=det.getColValue("codigo")%></td>
										<td align="left"><%=det.getColValue("descripcion")%></td>
										<td align="right"><%=CmnMgr.getFormattedDecimal(det.getColValue("monto"))%></td>
									</tr>
									<%
									}
									%>
									<tr class="TextRow05">
										<td align="right" colspan="4"><cellbytelabel id="77">Total Distribuido</cellbytelabel></td>
										<td align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
									</tr>
								</table>
							</td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>
<!-- TAB7 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form7",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","7")%>
<%=fb.hidden("mode",mode)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(71)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Pagos Empresa</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus71" style="display:none">+</label><label id="minus71">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel71">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="8%" align="center"><cellbytelabel id="50">Admi.</cellbytelabel></td>
							<td width="8%" align="center"><cellbytelabel id="58">Recibo</cellbytelabel></td>
							<td width="8%" align="center"><cellbytelabel id="65">Fecha Pago</cellbytelabel></td>
							<td width="10%" align="center">Descripci&oacute;n del Pago</td>
							<td width="10%" align="center"><cellbytelabel id="67">Pago por</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="57">Factura</cellbytelabel></td>
							<td width="25%" colspan="2" align="center">Pago por Admisi&oacute;n</td>
						</tr>
<%
total = 0.00;
al = CmnMgr.reverseRecords(iPagEmp);
for (int i=1; i<=iPagEmp.size(); i++)
{
	key = al.get(i - 1).toString();
	TransaccionPago obj = (TransaccionPago) iPagEmp.get(key);
	total += Double.parseDouble(obj.getSubtotal());
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";

%>
						<tr class="<%=color%>" onClick="javascript:showHide(71<%=i%>)" style="text-decoration:none; cursor:pointer">
							<td align="center"><%=obj.getAdmiSecuencia()%></td>
							<td align="center"><%=obj.getRecibo()%></td>
							<td align="center"><%=obj.getFechaPago()%></td>
							<td align="center"><%=obj.getDescripcion()%></td>
							<td align="center"><%=obj.getPagoPor()%></td>
							<td align="center"><%=obj.getFacCodigo()%></td>
							<td align="center"><%=CmnMgr.getFormattedDecimal(obj.getSubtotal())%></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus71<%=i%>" style="display:none">+</label><label id="minus71<%=i%>">-</label></font>]&nbsp;</td>
						</tr>
						<tr class="<%=color%>" id="panel71<%=i%>">
							<td colspan="8">
								<table width="100%" cellpadding="1" cellspacing="0">
								<%if(obj.getDetalleTransFormaPagos().size()>0){%>
									<tr class="TextHeader02">
										<td width="15%" align="center"><cellbytelabel id="70">Forma</cellbytelabel></td>
										<td width="15%" align="center"><cellbytelabel id="71">Tarjeta</cellbytelabel></td>
										<td width="10%" align="center"><cellbytelabel id="72"># Cheque/Refer.</cellbytelabel></td>
										<td width="50%"><cellbytelabel id="73">Banco</cellbytelabel></td>
										<td width="10%" align="right"><cellbytelabel id="53">Monto</cellbytelabel></td>
									</tr>
									<%
									for (int j=0; j<obj.getDetalleTransFormaPagos().size(); j++)
									{
										CommonDataObject det = (CommonDataObject) obj.getDetalleTransFormaPagos().get(j);
										String color2 = "TextRow03";
										if (j % 2 == 0) color2 = "TextRow04";
										%>
									<tr class="<%=color2%>">
										<td align="left"><%=det.getColValue("forma_pago")%></td>
										<td align="left"><%=det.getColValue("tipo_tarjeta")%></td>
										<td align="center"><%=det.getColValue("num_cheque")%></td>
										<td align="left"><%=det.getColValue("descripcion_banco")%></td>
										<td align="right" ><%=CmnMgr.getFormattedDecimal(det.getColValue("monto"))%></td>
									</tr>
									<%
									}}
									%>


									<tr class="TextHeader02">
										<td width="15%" align="center"><cellbytelabel id="55">Fecha</cellbytelabel></td>
										<td width="15%" align="center"><cellbytelabel id="74">Modo Dist.</cellbytelabel></td>
										<td width="10%" align="center"><cellbytelabel id="21">C&oacute;digo</cellbytelabel></td>
										<td width="50%" align="center"><cellbytelabel id="75">Distribuido a</cellbytelabel></td>
										<td width="10%" align="right"><cellbytelabel id="76">Monto Distribuido</cellbytelabel></td>
									</tr>
									<%
									total = 0.00;
									for (int j=0; j<obj.getDetalleDistribuirPago().size(); j++)
									{
										CommonDataObject det = (CommonDataObject) obj.getDetalleDistribuirPago().get(j);
										total += Double.parseDouble(det.getColValue("monto"));
										String color2 = "TextRow03";
										if (j % 2 == 0) color2 = "TextRow04";
										%>
									<tr class="<%=color2%>">
										<td align="left"><%=det.getColValue("fecha")%></td>
										<td align="left"><%=det.getColValue("distribucion")%></td>
										<td align="center"><%=det.getColValue("codigo")%></td>
										<td align="left"><%=det.getColValue("descripcion")%></td>
										<td align="right"><%=CmnMgr.getFormattedDecimal(det.getColValue("monto"))%></td>
									</tr>
									<%
									}
									%>
									<tr class="TextRow05">
										<td align="right" colspan="4"><cellbytelabel id="77">Total Distribuido</cellbytelabel></td>
										<td align="right"><%=CmnMgr.getFormattedDecimal(total)%></td>
									</tr>
								</table>
							</td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>
<!-- TAB8 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form8",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","8")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("index","")%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(81)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="78">Facturas</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus81" style="display:none">+</label><label id="minus81">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel81">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="11%" align="center"><cellbytelabel id="79">Tipo Paciente</cellbytelabel></td>
							<td width="7%" align="center"><cellbytelabel id="80">CO / CR</cellbytelabel></td>
							<td width="12%" align="center"><cellbytelabel id="81">Corte</cellbytelabel></td>
							<td width="11%" align="center"><cellbytelabel id="26">Estado</cellbytelabel></td>
							<td width="11%" align="center"><cellbytelabel id="82">Estado Fact.</cellbytelabel></td>
							<td width="15%" align="center"><cellbytelabel id="83">Aseg</cellbytelabel>.</td>
							<td width="10%" align="center"><cellbytelabel>Fecha Envio</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="84">N&uacute;mero</cellbytelabel></td>
							<td width="10%" align="center"><cellbytelabel id="85">Facturado A</cellbytelabel></td>
							<td width="3%" align="center">&nbsp;</td>
						</tr>
<%
total = 0.00;
al = CmnMgr.reverseRecords(iAdm);
System.out.println("alAdm.size()="+al.size());
for (int i=1; i<=iAdm.size(); i++)
{
	key = al.get(i - 1).toString();
	Admision obj = (Admision) iAdm.get(key);
	//total += Double.parseDouble(obj.getSubtotal());
	String color = "TextRow01";
	if (i % 2 == 0) color = "TextRow02";
	String factA = "";
	if(obj.getTipoFactura().equals("E")) factA = "Empresa";
	else if(obj.getTipoFactura().equals("P")) factA = "Paciente";
%>
						<%=fb.hidden("formName"+i,obj.getFormName())%>
						<%=fb.hidden("facturadoA"+i,obj.getTipoFactura())%>
						<%=fb.hidden("factId"+i,obj.getNumFactura())%>
						<%//=fb.hidden(""+i,obj.get())%>
						<tr class="<%=color%>">
							<td align="center"><%=obj.getTipoCta()%></td>
							<td align="center"><%=obj.getContaCred()%></td>
							<td align="center"><%=obj.getCorteCta()%></td>
							<td align="center"><%=obj.getEstado()%></td>
							<td align="center"><%=obj.getStatus()%></td>
							<td align="center"><%=obj.getEmpresa()%></td>
							<td align="center"><%=obj.getFechaAtencion()%></td>
							<td align="center"><%=obj.getNumFactura()%></td>
							<td align="center"><%=factA%></td>
							<td align="center"><%=fb.checkbox("check"+i,"",false,false,null,null,"onClick=\"javascript:setIndex("+i+")\"")%></td>
						</tr>
<%
}
%>
						</table>
					</td>
				</tr>

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Admisión','Beneficios','Cargos','Honorarios','Devoluciones','Ajustes','Pagos Paciente','Pagos Empresa','Facturas'";
if (!mode.equalsIgnoreCase("add"))
{
}
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
%>
