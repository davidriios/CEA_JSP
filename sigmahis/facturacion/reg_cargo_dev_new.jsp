<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="issi.facturacion.FactTransaccion"%>
<%@ page import="issi.facturacion.FactDetTransaccion"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="FTransMgr" scope="page" class="issi.facturacion.FactTransaccionMgr" />
<jsp:useBean id="FTransDet" scope="session" class="issi.facturacion.FactTransaccion" />
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCompKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranDComp" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
fg = PAC  CARGOS/DEV. PACIENTES  FORMA FAC10010
fg = HON  HONORARIOS MEDICOS FORMA FAC10020
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
FTransMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
//FactTransaccion FTransDet = new FactTransaccion();
FactTransaccion resp = new FactTransaccion();
String key = "";
String sql = "";
StringBuffer sbSql = new StringBuffer();
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String tt = request.getParameter("tt");
String tipoTransaccion = request.getParameter("tipoTransaccion")==null?"":request.getParameter("tipoTransaccion");
String noOrden = (request.getParameter("no_orden")==null?"":request.getParameter("no_orden"));
String codigoOrden = (request.getParameter("codigo_orden")==null?"":request.getParameter("codigo_orden"));
String tipoServicio = (request.getParameter("tipoServicio")==null?"":request.getParameter("tipoServicio"));
String idIntFar = (request.getParameter("id_int_far")==null?"":request.getParameter("id_int_far"));
String codigo = request.getParameter("codigo");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String barCode = request.getParameter("bac__code")==null?"":request.getParameter("bac__code");
String fromNewView = request.getParameter("from_new_view")==null?"":request.getParameter("from_new_view");
if(fg==null) fg = "PAC";
String fp = request.getParameter("fp");
if(fp==null) fp = "cargo_dev";
String fPage = request.getParameter("fPage");
if(fPage==null) fPage = "";
boolean viewMode = false;
int camaLastLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String cds = request.getParameter("cds");
String wh = request.getParameter("wh");
if (cds == null) { cds = SecMgr.getParValue(UserDet,"cds"); if (cds == null) cds = ""; }
if (wh == null) wh = "";
int lineNo = 0;
if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (request.getParameter("camaLastLineNo") != null) camaLastLineNo = Integer.parseInt(request.getParameter("camaLastLineNo"));
String serv_ext = "select cds from tbl_sec_user_cds where cds in (15, 16, 17, 18, 20, 26, 67) and user_id="+UserDet.getUserId();
String codCds = "", cdsDet = "", compFar = "";
String  autoBoleta= "N";
try {autoBoleta = java.util.ResourceBundle.getBundle("issi").getString("autoBoleta");}catch(Exception e){ autoBoleta = "N";}
try {cdsDet = java.util.ResourceBundle.getBundle("issi").getString("cdsDet");}catch(Exception e){cdsDet = "N";}
try {compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");}catch(Exception e){compFar = "";}

	sbSql = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'FAC_TIPO_SERV_DEFAULT'),'-') as  tipo_serv, nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'REG_LOTE_EN_CARGOS'),'N') as  reg_lote from dual");
	CommonDataObject cdoTA = (CommonDataObject) SQLMgr.getData(sbSql.toString());
	String tipoServ = cdoTA.getColValue("tipo_serv");
	String reg_lote = cdoTA.getColValue("reg_lote");
	sbSql = new StringBuffer();
	sbSql.append("select (select nombre from tbl_adm_empresa e where e.codigo = b.empresa) aseguradora from tbl_adm_beneficios_x_admision b where pac_id = ");
	sbSql.append(pacienteId);
	sbSql.append(" and admision = ");
	sbSql.append(noAdmision);
	sbSql.append(" and prioridad = 1 and estado = 'A'");
	CommonDataObject cdoASeg = (CommonDataObject) SQLMgr.getData(sbSql.toString());
	if(cdoASeg==null) {cdoASeg = new CommonDataObject();cdoASeg.addColValue("aseguradora","N/A");}

/*CommonDataObject cdoCds = (CommonDataObject) SQLMgr.getData(serv_ext);
if(cdoCds!=null && !cdoCds.getColValue("cds").equals("")) codCds = cdoCds.getColValue("cds");
*/
if (request.getMethod().equalsIgnoreCase("GET"))
{
	XMLCreator xml = new XMLCreator(ConMgr);

if(!UserDet.getUserProfile().contains("0")){
	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"almacen_x_cds_"+UserDet.getUserId()+".xml","select a.almacen as value_col, a.almacen||' - '||(select descripcion from tbl_inv_almacen where codigo_almacen=a.almacen and compania=a.compania) as label_col, a.compania||'-'||a.cds as key_col from tbl_sec_cds_almacen a,tbl_sec_user_almacen b where a.almacen=b.almacen and a.compania =b.compania  and b.ref_type='CDS' and b.user_id="+UserDet.getUserId()+" order by a.compania,a.cds,b.user_id,a.almacen");}
	else{xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"almacen_x_cds_"+UserDet.getUserId()+".xml","select a.almacen as value_col, a.almacen||' - '||(select descripcion from tbl_inv_almacen where codigo_almacen=a.almacen and compania=a.compania) as label_col, a.compania||'-'||a.cds as key_col from tbl_sec_cds_almacen a order by a.compania, a.cds, a.almacen");}

	if (mode.equalsIgnoreCase("add"))
	{
		fTranCarg.clear();
		fTranCargKey.clear();
		fTranComp.clear();
		fTranCompKey.clear();
		if(change==null){
			pacienteId = "0";
			noAdmision = "0";
			if(request.getParameter("pacienteId")!=null) pacienteId = request.getParameter("pacienteId");
			if(request.getParameter("noAdmision")!=null) noAdmision = request.getParameter("noAdmision");
			FTransDet = new FactTransaccion();
			session.setAttribute("FTransDet",FTransDet);
			if(FTransDet.getCentroServicio().equals("")) FTransDet.setCentroServicio(cds);
			FTransDet.setPacienteId(pacienteId);
			FTransDet.setAdmiSecuencia(noAdmision);
			FTransDet.setCodigo("0");
			FTransDet.setFechaCreacion(cDateTime);
			FTransDet.setFechaModificacion(mTime);
			//FTransDet.setGeneraArchivo("N");
			FTransDet.setAdmFechaIngreso(cDateTime.substring(0,10));
			if(fg.equals("HON")){
				FTransDet.setCentroServicio("0");
				FTransDet.setCentroServicioDesc("Honorarios");
				FTransDet.setTipoCds("I");
				FTransDet.setPagarSociedad("N");
			} else {
				String cdsWh = (String) session.getAttribute("CDS_ALMACEN");//utilizado para valor inicial
				if (cdsWh != null) {
					String[] tmp = cdsWh.split("-");
					if (cdsWh != null && !cdsWh.trim().equals("") && tmp.length == 2) {
						FTransDet.setCentroServicio(tmp[0]);
						cds = tmp[0];
						wh = tmp[1];
					}
				}
			}
		}
		//FTransDet.setAmPm(cDateTime.substring(11));
		//FTransDet.setFechaPreadmision(cDateTime);
	}
	else if (mode.equalsIgnoreCase("view"))
	{

		if (pacienteId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");
		viewMode = true;
				fTranCarg.clear();
				fTranCargKey.clear();
				//FTransDet.getFTransDetail().clear;

		sql = "SELECT a.codigo, a.admi_secuencia admiSecuencia, to_char(a.admi_fecha_nacimiento, 'dd/mm/yyyy') admiFechaNacimiento, a.admi_codigo_paciente admiCodigoPaciente, a.descripcion, to_char(a.fecha,'dd/mm/yyyy') fecha, to_char(a.fecha_creacion, 'dd/mm/yyyy') fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') fechaModificacion, a.tipo_transaccion tipoTransaccion, a.num_solicitud numSolicitud, a.num_factura numFactura, a.no_documento noDocumento, a.medico_cirugia medicoCirugia, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) as nombreMedicoCirugia, a.centro_servicio centroServicio, d.descripcion centroServicioDesc, d.tipo_cds tipoCds, d.reporta_a reportaA, nvl(d.incremento,0) incremento, nvl(d.tipo_incremento, ' ') tipoIncremento, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente, decode(a.tipo_transaccion,'C','Cargo','D','Devolucion') desc_tipo_transaccion, a.pac_id pacienteId, nvl(a.empre_codigo, 0) empreCodigo, nvl(e.nombre, ' ') empreNombre,nvl(a.diferencia_honorario,'N') diferenciaHonorario,nvl(a.pagar_sociedad,'N') pagarSociedad,nvl(c.reg_medico,c.codigo) as medCodigo FROM tbl_fac_transaccion a, tbl_adm_paciente b, tbl_adm_medico c, tbl_cds_centro_servicio d, tbl_adm_empresa e where a.pac_id = b.pac_id and a.medico_cirugia = c.codigo(+) and a.centro_servicio = d.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id = "+pacienteId+" and a.admi_secuencia = "+noAdmision+" and a.tipo_transaccion = '"+tt+"' and a.codigo = "+codigo+" and a.empre_codigo = e.codigo(+)";
		System.out.println("SQL:\n"+sql);
		FTransDet = (FactTransaccion) sbb.getSingleRowBean(ConMgr.getConnection(),sql,FactTransaccion.class);

		String cs = FTransDet.getCentroServicio();
		String v_empresa = FTransDet.getEmpreCodigo();
	sql = "select distinct * from( select c.tipo_servicio, c.descripcion tipo_serv_desc,  a.*, nvl(a.monto,0) precio1, nvl(a.monto,0) precio2, nvl(d.cant_cargo, 0) cant_cargo, nvl(d.cant_devolucion, 0) cant_devolucion, decode('"+tt+"','C',nvl(d.cant_cargo, 0),'D',nvl(d.cant_devolucion, 0),'H',1,0) cantidad from (select b.descripcion, decode(b.procedimiento, null, decode(b.habitacion, null, decode(b.cds_producto, null, decode(b.cod_uso, null, decode(b.otros_cargos, null, decode(b.cod_paq_x_cds, null, ' ', b.cod_paq_x_cds), b.otros_cargos), b.cod_uso), b.cds_producto), b.habitacion), b.procedimiento) trabajo, b.monto, nvl(b.habitacion, ' ') habitacion, nvl(h.codigo, 0) servicio_hab, nvl(b.cds_producto, 0) cds_producto, nvl(b.cod_uso, 0) cod_uso, nvl(b.centro_costo, 0) centro_costo, nvl(b.costo_art, 0) costo_art, nvl(b.procedimiento, ' ') procedimiento, nvl(b.otros_cargos, 0) otros_cargos, b.tipo_cargo, b.cod_paq_x_cds, b.tipo_transaccion, b.recargo, to_char(b.fecha_cargo,'dd/mm/yyyy') as fecha_cargo, nvl(b.cod_prod_far, ' ') cod_prod_far, nvl(b.pedido_far, 0) pedido_far, b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo akey from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b, tbl_sal_tipo_habitacion h where a.codigo = "+codigo+" and a.centro_servicio = "+cs+" and a.tipo_transaccion = '"+tt+"' and a.pac_id = "+pacienteId+" and a.admi_secuencia = "+noAdmision+" and a.compania = "+(String) session.getAttribute("_companyId")+" and b.art_familia is null and b.art_clase is null and b.inv_articulo is null and a.compania = b.compania and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.codigo = b.fac_codigo and a.tipo_transaccion = b.tipo_transaccion and b.servicio_hab = h.codigo(+) group by b.descripcion, decode(b.procedimiento, null, decode(b.habitacion, null, decode(b.cds_producto, null, decode(b.cod_uso, null, decode(b.otros_cargos, null, decode(b.cod_paq_x_cds, null, ' ', b.cod_paq_x_cds), b.otros_cargos), b.cod_uso), b.cds_producto), b.habitacion), b.procedimiento), b.monto, b.habitacion, h.codigo, b.cds_producto, b.cod_uso, b.centro_costo, b.costo_art, b.procedimiento, b.otros_cargos, b.tipo_cargo, b.cod_paq_x_cds, b.tipo_transaccion, b.recargo, b.fecha_cargo, b.cod_prod_far, b.pedido_far, b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo) a,(select a.descripcion, b.tipo_servicio from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo = b.tipo_servicio and b.centro_servicio = "+cs+") c, (select b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo akey, sum(decode(b.tipo_transaccion,'C',nvl(b.cantidad,0))) cant_cargo, sum(decode(b.tipo_transaccion,'D',nvl(b.cantidad,0))) cant_devolucion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b, tbl_sal_tipo_habitacion h where  a.centro_servicio = "+cs+" and a.tipo_transaccion = '"+tt+"' and a.pac_id = "+ pacienteId +" and a.admi_secuencia = "+noAdmision+" and a.codigo = "+codigo+" and a.compania = "+(String) session.getAttribute("_companyId")+" and b.art_familia is null and b.art_clase is null and b.inv_articulo is null and a.compania = b.compania and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.codigo = b.fac_codigo and a.tipo_transaccion = b.tipo_transaccion and b.servicio_hab = h.codigo(+) group by  b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo ) d where a.tipo_cargo = c.tipo_servicio and a.akey = d.akey(+) )";


if(tt != null && tt.trim().equals("D"))
	sql = "select distinct * from( select c.tipo_servicio, c.descripcion tipo_serv_desc,  a.*, nvl(a.monto,0) precio1, nvl(a.monto,0) precio2, nvl(d.cant_cargo, 0) cant_cargo, nvl(d.cant_devolucion, 0) cant_devolucion, decode('"+tt+"','C',nvl(d.cant_cargo, 0),'D',nvl(d.cant_devolucion, 0),'H',1,0) cantidad from (select b.descripcion, decode(b.procedimiento, null, decode(b.habitacion, null, decode(b.cds_producto, null, decode(b.cod_uso, null, decode(b.otros_cargos, null, decode(b.cod_paq_x_cds, null, ' ', b.cod_paq_x_cds), b.otros_cargos), b.cod_uso), b.cds_producto), b.habitacion), b.procedimiento) trabajo, b.monto, nvl(b.habitacion, ' ') habitacion, nvl(h.codigo, 0) servicio_hab, nvl(b.cds_producto, 0) cds_producto, nvl(b.cod_uso, 0) cod_uso, nvl(b.centro_costo, 0) centro_costo, nvl(b.costo_art, 0) costo_art, nvl(b.procedimiento, ' ') procedimiento, nvl(b.otros_cargos, 0) otros_cargos, b.tipo_cargo, b.cod_paq_x_cds, b.tipo_transaccion,b.fac_codigo, b.secuencia, b.recargo, to_char(b.fecha_cargo,'dd/mm/yyyy') as fecha_cargo, nvl(b.cod_prod_far, ' ') cod_prod_far, nvl(b.pedido_far, 0) pedido_far, b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo akey from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b, tbl_sal_tipo_habitacion h where a.codigo = "+codigo+" and a.centro_servicio = "+cs+" and a.tipo_transaccion = '"+tt+"' and a.pac_id = "+pacienteId+" and a.admi_secuencia = "+noAdmision+" and a.compania = "+(String) session.getAttribute("_companyId")+" and b.art_familia is null and b.art_clase is null and b.inv_articulo is null and a.compania = b.compania and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.codigo = b.fac_codigo and a.tipo_transaccion = b.tipo_transaccion and b.servicio_hab = h.codigo(+) group by b.descripcion, decode(b.procedimiento, null, decode(b.habitacion, null, decode(b.cds_producto, null, decode(b.cod_uso, null, decode(b.otros_cargos, null, decode(b.cod_paq_x_cds, null, ' ', b.cod_paq_x_cds), b.otros_cargos), b.cod_uso), b.cds_producto), b.habitacion), b.procedimiento), b.monto, b.habitacion, h.codigo, b.cds_producto, b.cod_uso, b.centro_costo, b.costo_art, b.procedimiento, b.otros_cargos, b.tipo_cargo, b.cod_paq_x_cds, b.tipo_transaccion, b.fac_codigo, b.secuencia,b.recargo, b.fecha_cargo, b.cod_prod_far, b.pedido_far, b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo) a,(select a.descripcion, b.tipo_servicio from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo = b.tipo_servicio and b.centro_servicio = "+cs+") c, (select b.fac_codigo , b.secuencia , b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo akey, sum(decode(b.tipo_transaccion,'C',nvl(b.cantidad,0))) cant_cargo, sum(decode(b.tipo_transaccion,'D',nvl(b.cantidad,0))) cant_devolucion from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b, tbl_sal_tipo_habitacion h where  a.centro_servicio = "+cs+" and a.tipo_transaccion = '"+tt+"' and a.pac_id = "+ pacienteId +" and a.admi_secuencia = "+noAdmision+" and a.codigo = "+codigo+" and a.compania = "+(String) session.getAttribute("_companyId")+" and b.art_familia is null and b.art_clase is null and b.inv_articulo is null and a.compania = b.compania and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.codigo = b.fac_codigo and a.tipo_transaccion = b.tipo_transaccion and b.servicio_hab = h.codigo(+) group by  b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo, b.fac_codigo, b.secuencia ) d where a.tipo_cargo = c.tipo_servicio and a.akey = d.akey(+) and a.fac_codigo = d.fac_codigo and a.secuencia = d.secuencia)";


//sql=" select distinct c.tipo_servicio, c.descripcion tipo_serv_desc,  a.*, nvl(a.monto,0) precio1, nvl(a.monto,0) precio2, nvl(a.cantidad_cargo, 0)  cantidad from ( select sum(decode(b.tipo_transaccion,'D',nvl(b.cantidad,0))) cantidad_cargo , b.descripcion, decode(b.procedimiento, null, decode(b.habitacion, null, decode(b.cds_producto, null, decode(b.cod_uso, null, decode(b.otros_cargos, null, decode(b.cod_paq_x_cds, null, ' ', b.cod_paq_x_cds), b.otros_cargos), b.cod_uso), b.cds_producto), b.habitacion), b.procedimiento) trabajo, b.monto, nvl(b.habitacion, ' ') habitacion, nvl(h.codigo, 0) servicio_hab, nvl(b.cds_producto, 0) cds_producto, nvl(b.cod_uso, 0) cod_uso, nvl(b.centro_costo,0) centro_costo, nvl(b.costo_art, 0) costo_art, nvl(b.procedimiento, ' ') procedimiento, nvl(b.otros_cargos, 0) otros_cargos, b.tipo_cargo, b.cod_paq_x_cds, b.tipo_transaccion, b.fac_codigo, b.secuencia, b.recargo, to_char(b.fecha_cargo,'dd/mm/yyyy') as fecha_cargo, nvl(b.cod_prod_far, ' ') cod_prod_far, nvl(b.pedido_far, 0) pedido_far, b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo akey from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b, tbl_sal_tipo_habitacion h where a.codigo = "+codigo+" and a.centro_servicio = "+cs+" and a.tipo_transaccion = '"+tt+"' and a.pac_id = "+pacienteId+"  and a.admi_secuencia = "+noAdmision+" and a.compania = "+(String) session.getAttribute("_companyId")+" and b.art_familia is null and b.art_clase is null and b.inv_articulo is null and a.compania = b.compania and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.codigo = b.fac_codigo and a.tipo_transaccion = b.tipo_transaccion and b.servicio_hab = h.codigo(+) group by b.descripcion, decode(b.procedimiento, null, decode(b.habitacion, null, decode(b.cds_producto, null, decode(b.cod_uso, null, decode(b.otros_cargos, null, decode(b.cod_paq_x_cds, null, ' ', b.cod_paq_x_cds), b.otros_cargos), b.cod_uso), b.cds_producto), b.habitacion), b.procedimiento), b.monto, b.habitacion, h.codigo, b.cds_producto, b.cod_uso, b.centro_costo, b.costo_art,b.procedimiento, b.otros_cargos, b.tipo_cargo, b.cod_paq_x_cds, b.tipo_transaccion, b.fac_codigo, b.secuencia, b.recargo, b.fecha_cargo, b.cod_prod_far, b.pedido_far, b.cod_uso||'_'||b.procedimiento||'_'||b.otros_cargos||'_'||b.habitacion||'_'||b.cds_producto||'_'||a.centro_servicio||'_'||b.tipo_cargo ) a,(select a.descripcion, b.tipo_servicio from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo = b.tipo_servicio and b.centro_servicio = "+cs+") c where  a.tipo_cargo = c.tipo_servicio ";
		al = SQLMgr.getDataList(sql);

		for(int i=0; i<al.size(); i++){
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			FactDetTransaccion det = new FactDetTransaccion();

			det.setTipoCargo(cdo.getColValue("tipo_servicio"));
			det.setTipoCargoDesc(cdo.getColValue("tipo_serv_desc"));
			det.setTrabajoDesc(cdo.getColValue("descripcion"));
			det.setTrabajo(cdo.getColValue("trabajo"));
			det.setHabitacion(cdo.getColValue("habitacion"));
			det.setServicioHab(cdo.getColValue("servicio_hab"));
			det.setCdsProducto(cdo.getColValue("cds_producto"));
			det.setCodUso(cdo.getColValue("cod_uso"));
			det.setCentroCosto(cdo.getColValue("centro_costo"));
			det.setCostoArt(cdo.getColValue("costo_art"));
			det.setProcedimiento(cdo.getColValue("procedimiento"));
			det.setOtrosCargos(cdo.getColValue("otros_cargos"));

			det.setMonto(cdo.getColValue("monto"));
			det.setCantidad(cdo.getColValue("cantidad"));
			det.setCodPaqXCds(cdo.getColValue("cod_paq_x_cds"));
			det.setTipoTransaccion(cdo.getColValue("tipo_transaccion"));
			det.setFacCodigo(cdo.getColValue("fac_codigo"));
			det.setSecuencia(cdo.getColValue("secuencia"));
			det.setRecargo(cdo.getColValue("recargo"));
			det.setFechaCargo(cdo.getColValue("fecha_cargo"));

			det.setCantCargo(cdo.getColValue("cant_cargo"));
			det.setCantDevolucion(cdo.getColValue("cant_devolucion"));
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;

			try {
				fTranCarg.put(key, det);
				fTranCargKey.put(det.getTipoCargo()+"_"+det.getTrabajo(), key);
				FTransDet.getFTransDetail().add(det);
				//System.out.println("adding item "+key+" _ "+det.getTipoCargo()+"_"+det.getTrabajo());
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		}

	}

 sbSql = new StringBuffer();
sbSql.append(" select ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio ");
else sbSql.append(" a.centro_servicio ");
sbSql.append(" from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
sbSql.append(pacienteId);
sbSql.append(" and a.admi_secuencia = ");
sbSql.append(noAdmision);

if (fg.trim().equals("FAR") || fPage.equalsIgnoreCase("int_farmacia")){sbSql.append(" and a.compania_ref = ");sbSql.append(compFar);}

sbSql.append(" and a.codigo=b.fac_codigo and a.pac_id=b.pac_id and a.admi_secuencia=b.fac_secuencia and a.tipo_transaccion=b.tipo_transaccion  having sum(decode(b.tipo_transaccion,'D',-1*b.cantidad*(b.monto+nvl(b.recargo,0)),b.cantidad*(b.monto+nvl(b.recargo,0)))) > 0 group by ");
if(cdsDet.trim().equals("S"))sbSql.append(" b.centro_servicio ");
else sbSql.append(" a.centro_servicio ");

String cdsQry = "select codigo, descripcion, '''TCDS'':'''||tipo_cds||''' , ''RTPTO'':'''||reporta_a||''' , ''INC'':'''||nvl(incremento,0)||''' , ''TINC'':'''||nvl(tipo_incremento, ' ')||'''' xtra_data from tbl_cds_centro_servicio a where compania_unorg = "+session.getAttribute("_companyId")+" and estado = 'A' and codigo not in ( select column_value  from table( select split((select param_value from tbl_sec_comp_param where compania in(-1,"+(String) session.getAttribute("_companyId")+") and param_name='CDS_HON'),',') from dual  ))   ";

if (tipoTransaccion!=null && tipoTransaccion.trim().equals("D") /*&& CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")") > 0*/ ){
	 cdsQry += " /**/ and codigo in (select * from("+sbSql.toString()+") ) ";
}

if(!UserDet.getUserProfile().contains("0"))
if(session.getAttribute("_cds") != null) cdsQry += " and codigo in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds"))+")";
else  cdsQry += " and codigo in(-1)";
cdsQry += " order by descripcion";

if (noAdmision.equals("0")||pacienteId.equals("0")) viewMode = true;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/time_base.jsp"%>

<style type="text/css">
iframe { display:block; }
</style>
<script language="javascript">
document.title = 'Facturación - '+document.title;

function removeItem(fName,k){
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue){
	document.forms[fName].baction.value = actionValue;
	window.frames['itemFrame'].doSubmit();
}
function searchMedicoList(){
var fg='<%=fg%>';var info=getPacienteInfo();
	<%if(fg != null && fg.trim().equals("HON")){%>
	document.form0.pagar_sociedad.checked=false;
	document.form0.empreCodigo.value='';
	document.form0.empreDesc.value='';
	if(document.form0.tipoTransaccion.value=='D'){fg='DEVHON';if(!info.isValid)return false;}
	<%}%>
	abrir_ventana1('../common/search_medico.jsp?fp=cargo_dev&fg='+fg+'&pacId='+info.pacId+'&noAdmision='+info.admision);
}
function selEmpresa(){
var fg='<%=fg%>';var info=getPacienteInfo();
<% if (fg.equalsIgnoreCase("HON")) { %>
if(document.form0.tipoTransaccion.value=='D'){fg='DEVHON';if(!info.isValid)return false;}
<% } %>
	if(document.form0.pagar_sociedad.checked)abrir_ventana1('../common/search_empresa.jsp?fp=cargo_dev&fg='+fg+'&pacId='+info.pacId+'&noAdmision='+info.admision);
	else CBMSG.warning('Debe Seleccionar Sociedad');
}
function doShow(){//newHeight();
<%
if(cds!=null && !cds.equals("")){
%>
setRightPaneSrc();
<%
}
%>
}
function selCServicio(){
	var fg = document.form0.fg.value;
	var cs = document.form0.centroServicio.value;
	abrir_ventana1('../common/sel_centro_servicio.jsp?fp=cargo_dev&mode=<%=mode%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&fg='+fg+"&cs="+cs);
}
function selProveedor(){
	var fg = document.form0.fg.value;
	var cs = document.form0.centroServicio.value;
	abrir_ventana1('../common/sel_proveedor.jsp?fp=cargo_dev&mode=<%=mode%>&pacienteId=<%=pacienteId%>&noAdmision=<%=noAdmision%>&fg='+fg+"&cs="+cs);
}
function chkDocNo(obj){var centro_serv= document.form0.centroServicio.value;var tipo_transaccion=document.form0.tipoTransaccion.value;if(centro_serv=='') alert('Seleccione Centro de Servicio');else{if(obj.value!=''){if(hasDBData('<%=request.getContextPath()%>','tbl_fac_transaccion','no_documento=\''+obj.value+'\' and compania=<%=(String) session.getAttribute("_companyId")%> and tipo_transaccion=\''+tipo_transaccion+'\' and centro_servicio='+centro_serv,'')){CBMSG.warning('El número de documento para este tipo de transaccion YA EXISTE!');obj.value = '';obj.focus();}}}}
function clearMedEmpresa(){

	if(document.form0.pagar_sociedad.checked==true){
		document.form0.medico.value='';
		document.form0.reg_medico.value='';
		document.form0.nombreMedico.value='';
		document.form0.btnEmpresa.disabled=false;
	} else {
		document.form0.empreCodigo.value='';
		document.form0.empreDesc.value='';
	}
}

function useMedTrat(){
	if(document.form0.chkUseMedico.checked) {
		document.form0.medico.value=document.paciente.medico.value;
		document.form0.nombreMedico.value=document.paciente.nombreMedico.value;
		document.form0.reg_medico.value=document.paciente.reg_medico.value;

	} else {
		document.form0.medico.value='';
		if(document.form0.reg_medico)document.form0.reg_medico.value='';
		document.form0.nombreMedico.value='';
	}
}
function clearDetail(opt)
{
	var size = window.frames['itemFrame'].document.form1.size.value;
	var tipo_transaccion	= document.form0.tipoTransaccion.value;
	var fPage = "<%=fPage%>", xtraP = "", intFarm = false;
	if(fPage =="int_farmacia"){
		xtraP = "&no_orden=<%=noOrden%>&tipoServicio=<%=tipoServicio%>&codigo_orden=<%=codigoOrden%>";
		intFarm = true;
	}
	if(parseInt(size)>0){
		xtraP += '&cds='+document.form0.centroServicio.value+'&wh='+document.form0.almacen.value;

		/*if(confirm('Al cambiar el tipo de transaccion se borraran los registros agregados. \n Desea continuar????')){
			 window.location = '../facturacion/reg_cargo_dev_new.jsp?noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&from_new_view=<%=fromNewView%>&fg=PAC&fPage=<%=fPage%>&tipoTransaccion='+tipo_transaccion+xtraP;
		}else{
			$("#doNothing").val("y");
			$("#centroServicio").val("<%=cds%>");
			$("#tipoTransaccion").val("<%=tipoTransaccion%>");
			if(tipo_transaccion=='D'){<%if(fg.equals("HON")){%>document.form0.tipoTransaccion.value='H';<%}else{%>document.form0.tipoTransaccion.value='C';<%}%>}else{document.form0.tipoTransaccion.value=tipo_transaccion;}
		}*/

		CBMSG.confirm('Al cambiar el tipo de transaccion se borraran los registros agregados. \n Desea continuar????',{
			cb: function(r){
				if (r=='Si'){
					 window.location = '../facturacion/reg_cargo_dev_new.jsp?noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&from_new_view=<%=fromNewView%>&fg=PAC&fPage=<%=fPage%>&bac__code=<%=barCode%>&tipoTransaccion='+tipo_transaccion+xtraP;
				}else{
					 $("#doNothing").val("y");
					 $("#centroServicio").val("<%=cds%>");
					 $("#tipoTransaccion").val("<%=tipoTransaccion%>");
					 if(tipo_transaccion=='D'){<%if(fg.equals("HON")){%>document.form0.tipoTransaccion.value='H';<%}else{%>document.form0.tipoTransaccion.value='C';<%}%>}else{document.form0.tipoTransaccion.value=tipo_transaccion;}
				}
			},
			btnTxt: "Si,No"
		});

	}else if(opt=='tt'){
		window.location = '../facturacion/reg_cargo_dev_new.jsp?noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&from_new_view=<%=fromNewView%>&fg=PAC&fPage=<%=fPage%>&bac__code=<%=barCode%>&tipoTransaccion='+tipo_transaccion+'&cds='+document.form0.centroServicio.value+'&wh='+document.form0.almacen.value+xtraP;
	}else{
		setRightPaneSrc();
	}
}

function setRightPaneSrc(){

	<%if(pacienteId.equals("0")||noAdmision.equals("0")){%>
		return;
	<%}%>
	<%if(fPage.equalsIgnoreCase("int_farmacia")){%>
		 $("#centroServicio").val(<%=cds%>);
	<%}%>

	var mode = "<%=mode%>";
	var cdsObj = $("#centroServicio");
	var xtraData = eval("({"+cdsObj.find("option:selected").attr("title")+"})");
	if ( mode == "add"){
		$("#tipoCds").val(xtraData.TCDS);
		$("#reportaA").val(xtraData.RTPTO);
		$("#incremento").val(xtraData.INC);
		$("#tipoInc").val(xtraData.TINC);
	}

	var cs = $("#centroServicio").val();
	var tipoCds = $("#tipoCds").val();
	var reportaA = $("#reportaA").val();
	var empresa = parent.document.paciente.empresa.value;
	var clasif = parent.document.paciente.clasificacion.value
	var edad = parent.document.paciente.edad.value;
	var cat = parent.document.paciente.categoria.value;
	var fechaNac	= parent.document.paciente.fechaNacimiento.value;
	var admSec = parent.document.paciente.admSecuencia.value;
	var codPac = parent.document.paciente.codigoPaciente.value;
	var pacId = parent.document.paciente.pacienteId.value;
	var inc = $("#incremento").val();
	var tipoTrans	= document.form0.tipoTransaccion.value;
	var tipoInc = $("#tipoInc").val();
	var codProv="";
	var size = window.frames['itemFrame'].document.form1.size.value;
	var doNothing = $("#doNothing").val();

	$("#prevCds").val(cs);

	<%if(fg.equals("PAC")){%>
		codProv = parent.document.form0 ? parent.document.form0.seCodProveedor.value : '';
	<%}%>

	var almacen = $("#almacen").val();console.log('--> cds='+cs+' almacen='+almacen);
	var codHonorario = '';
	if(document.form0.pagar_sociedad){if(document.form0.pagar_sociedad.checked==true){codHonorario = document.form0.empreCodigo.value;}else codHonorario = document.form0.medico.value;}

	if(tipoTrans != '' && tipoTrans=='D' && pacId =='' ){
	CBMSG.warning('Seleccione paciente..'); return false;
	}

	showHideServWrapper();

	var newTipoServ = "";
	<%if(!fPage.equalsIgnoreCase("int_farmacia")){%>
	if(tipoTrans=='C' && '<%=tipoServ%>'!='-')newTipoServ = "&tipoServicio=<%=tipoServ%>";
	<%}else{%>
		 newTipoServ = "&tipoServicio=<%=tipoServicio%>&id_int_far=<%=idIntFar%>";
	<%}%>
	var __paramStr = '?mode=<%=mode%>&fg=<%=fg%>&bac__code=<%=barCode%><%=fPage.equalsIgnoreCase("int_farmacia")?"&fPage=int_farmacia&no_orden="+noOrden+"&codigo_orden="+codigoOrden:""%>&fp=cargo_dev_pac&cs='+cs+'&tipo_cds='+tipoCds+'&reporta_a='+reportaA+'&v_empresa='+empresa+'&edad='+edad+'&clasificacion='+clasif+'&incremento='+inc+'&tipoInc='+tipoInc+'&tipoTransaccion='+tipoTrans+'&cat='+cat+'&admiSecuencia='+admSec+'&fechaNac='+fechaNac+'&codPaciente='+codPac+'&codProv='+codProv+'&pacId='+pacId+'&almacen='+almacen+newTipoServ+'&codHonorario='+codHonorario;

		$("#paramStr").val(__paramStr);

		if(doNothing == "")$("#servXCDS").attr('src','../common/sel_servicios_x_centro_new.jsp'+__paramStr);

	function showHideServWrapper(){
		 $("#servWrapper").show(0);
	}

}

function doSumitCargos(){
	 var totSel = $("#totSel").val() || "0";
	 $("#servXCDS").contents().find('input[name="curCargosUrl"]').val($("#parentCurCargosUrl").val())
	 if( parseInt(totSel) > 0 )$("#servXCDS").contents().find('#detail').submit();
}

function reloadCargosAfterDeleting(){
	var parentCurCargosUrl = $('#parentCurCargosUrl').val();
	if (parentCurCargosUrl.indexOf("after_deleting") == -1) parentCurCargosUrl += '&after_deleting=Y';
	$("#servXCDS").attr('src', parentCurCargosUrl);
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();doShow();resetFrameHeight(document.getElementById('servXCDS'),xHeight,150,200);
$('#pacBrazalete').focus();
}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,150,200);}

function getPB(){
	var pb = $("#pacBrazalete").val(), _pb = "";
	if (pb.indexOf("-") > 0){
	try{
		_pb = pb.split("-");
		_pb = _pb[0].lpad(10,"0")+""+_pb[1].lpad(3,"0");
	}catch(e){_pb="";}
	}else if (pb.trim().length == 13) _pb = pb;
	return _pb;
}
function addDevOption(){if(!$('#tipoTransaccion option[value=D]').length)$("#tipoTransaccion").append("<option value='D'>DEVOLUCION</option>");
<%if(request.getParameter("tipoTransaccion")!=null){%>
	document.form0.tipoTransaccion.value='<%=tipoTransaccion%>';
<%}%>
}

jQuery(document).ready(function(){
	 var content = "<div class='Text10Bold'><ol>";
	 content += "<li>Seleccione un CDS para ver los cargos</li>";
	 content += "<li>Efectuar una búsqueda, cliqueando en IR</li>";
	 content += "<li>Puede ir seleccionando uno a uno o indique una cantidad, y después cliquea en Agregar Cargos o [+]Cargos</li>";
	 content += "<li>O puede double-cliquear un cargo para agregarlo</li>";
	 content += "</ol></div>";
	 serveStaticTooltip({toolTipContainer:"#info",content:'"content-1":"'+content+'"',track:true});

		$("#pacBrazalete").keyup(function(e){
		var pacBrazalete = pacId = noAdmision = "";
		var key;
		(window.event) ? key = window.event.keyCode : key = e.which;
				var self = $(this);

		if(key == 13){
			pacBrazalete = getPB(self.val());
						pacId = parseInt(pacBrazalete.substr(0,10),10);
				noAdmision = parseInt(pacBrazalete.substr(10),10);
			window.location = "../facturacion/reg_cargo_dev_new.jsp?noAdmision="+noAdmision+"&pacienteId="+pacId+"&fg=PAC&fPage=general_page&bac__code=Y&from_new_view=<%=fromNewView%>";
		}
	});
});

</script>
<%if(fromNewView.equalsIgnoreCase("Y")){%>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<%}%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
								<%if (barCode.equalsIgnoreCase("Y")){%>
				<tr class="TextRow02">
					<td>
											Por favor Escanee un brazalete:&nbsp;&nbsp;&nbsp;&nbsp;
											<input type="text" name="pacBrazalete" id="pacBrazalete" maxlength="13" style="width:150px" tabindex="-1">
										</td>
				</tr>
								<%}%>
								<%if(!pacienteId.equals("0") && !noAdmision.equals("0")){%>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Datos del Paciente</cellbytelabel></td>
							<td width="5%" align="right">
								<%if(fromNewView.equalsIgnoreCase("Y")){%>
								[<font face="Courier New, Courier, mono"><label id="plus0">+</label><label id="minus0" style="display:none">-</label></font>]&nbsp;
								<%} else {%>
								[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;
								<%}%>
							</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0"<%=fromNewView.equalsIgnoreCase("Y")?" style='display:none'":""%>>
					<td>
						<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pacienteId%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
							<jsp:param name="fp" value="<%=fp%>"></jsp:param>
							<jsp:param name="tr" value="<%=fg%>"></jsp:param>
							<jsp:param name="mode" value="<%=mode%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
								<%}%>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("fPage",fPage)%>
<%=fb.hidden("printOF","")%>
<%//=fb.hidden("codigo",""+codigo)%>
<%=fb.hidden("paramStr","")%>
<%=fb.hidden("totSel","")%>
<%=fb.hidden("parentCurCargosUrl","")%>
<%=fb.hidden("prevCds","")%>
<%=fb.hidden("doNothing","")%>
<%=fb.hidden("no_orden",noOrden)%>
<%=fb.hidden("codigo_orden",codigoOrden)%>
<%=fb.hidden("id_int_far",idIntFar)%>
<%=fb.hidden("bac__code",barCode)%>
<%=fb.hidden("ref_code","")%>
<%=fb.hidden("reg_lote",reg_lote)%>
<%=fb.hidden("from_new_view",fromNewView)%>
				<tr class="TextRow01">
					<td>Aseguradora:&nbsp;<font  class="RedTextBold"><%=cdoASeg.getColValue("aseguradora")%></font></td>
				</tr>
				<tr class="RedTextBold">
					<td>El Centro de Servicio seleccionado se aplicar&aacute; a todos los cargos seleccionado!</td>
				</tr>
				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="85%">&nbsp;<cellbytelabel id="2">
							Transacci&oacute;n</cellbytelabel></td>
							<td width="10%" align="right"><%=fb.button("add","Agregar Cargos",true,false,null,null,"onClick=\"doSumitCargos()\"")%>
							</td>
							<td width="5%" align="right" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01" id="leftPane">
							<td width="9%" align="right"><cellbytelabel>No.</cellbytelabel></td>
							<td width="22%"><%=fb.intBox("codigo",FTransDet.getCodigo(),true,false,true,4)%>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Tipo</cellbytelabel>
							<%=fb.select("tipoTransaccion",(fg.equals("HON")?"H=HONORARIO":"C=CARGO"),tipoTransaccion, false, viewMode, 0,"","","onChange=\"javascript:clearDetail('tt')\"")%>
							<authtype type='50'><script>addDevOption();</script></authtype>

							</td>
							<!-- SERVICIOS X CDS CONTAINER -->
							<td id="servWrapper" width="69%" colspan="2" rowspan="6" style="display:">
								<div id="servXCDSContainer" style="overflow:hidden">
									 <iframe name="servXCDS" id="servXCDS" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src=""></iframe>
								</div>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Creado</cellbytelabel></td>
							<td><%=fb.textBox("fechaCreacion",FTransDet.getFechaCreacion(),false,false,true,8)%>
							&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Modificado</cellbytelabel>
							<%=fb.textBox("fechaModificacion",FTransDet.getFechaModificacion(),false,false,true,8)%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>No. Solicitud</cellbytelabel></td>
							<td><%=fb.textBox("numSolicitud",FTransDet.getNumSolicitud(),false,false,true,6)%>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=(fg.equals("PAC")?"No. Documento":"No. de Orden")%>
							<%=fb.textBox("noDocumento",FTransDet.getNoDocumento(),((fg.equals("HON")&&autoBoleta.trim().equals("N"))?true:false),false,((fg.equals("HON")&&autoBoleta.trim().equals("S"))||viewMode),6, "", "", "onBlur=\"javascript:chkDocNo(this);\"")%>
							</td>
						</tr>
						<%if(fg.equals("PAC")){%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>M&eacute;dico</cellbytelabel></td>
							<td>

								<%=fb.hidden("medico",FTransDet.getMedicoCirugia())%>
								<%=fb.textBox("reg_medico",FTransDet.getMedCodigo(),false,false,true,6)%>
								<%=fb.textBox("nombreMedico",FTransDet.getNombreMedicoCirugia(),false,false,true,35)%>
								<%=fb.button("btnMedico","...",true,viewMode,null,null,"onClick=\"javascript:searchMedicoList()\"")%>
								<%=fb.checkbox("chkUseMedico","",false,viewMode,"","","onClick=\"javascript:useMedTrat();\"")%><label for="chkUseMedico" style="cursor:pointer;"><cellbytelabel>Usar M&eacute;dico Tratante?</cellbytelabel></label>
				<!--Archivo--><%=fb.hidden("generaArchivo","N")%><%//=fb.checkbox("generaArchivo","",(FTransDet.getGeneraArchivo()==null || FTransDet.getGeneraArchivo().equals("") || FTransDet.getGeneraArchivo().equals("S")?true:false),viewMode)%><!--&nbsp;Button Serv. Ext.-->
							</td>
						</tr>
						<%}%>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="9">Centro de Servicio</cellbytelabel></td>
							<td>
								<%//=fb.intBox("centroServicio",FTransDet.getCentroServicio(),true,false,true,5)%>
								<%//=fb.textBox("centroServicioDesc",FTransDet.getCentroServicioDesc(),true,false,true,40)%>
								<%//=fb.textBox("tipoCds",FTransDet.getTipoCds(),true,false,true,5)%>
								<%//=fb.textBox("reportaA",FTransDet.getReportaA(),false,false,true,5)%>
								<%=fb.hidden("incremento",FTransDet.getIncremento())%>
								<%=fb.hidden("tipoInc",FTransDet.getTipoIncremento())%>
								<%//=fb.button("btnCServicio","...",true,(viewMode||(fg.equals("HON"))),null,null,"onClick=\"javascript:selCServicio()\"")%>


								<%=fb.hidden("centroServicioDesc",FTransDet.getCentroServicioDesc())%>
								<%=fb.hidden("tipoCds",FTransDet.getTipoCds())%>
								<%=fb.hidden("reportaA",FTransDet.getReportaA())%>

																<%if(!fPage.equalsIgnoreCase("int_farmacia")){%>
								<%=fb.select(ConMgr.getConnection(),cdsQry,"centroServicio",FTransDet.getCentroServicio(),false,false,0, "text10", "", "onChange=\"loadXML('../xml/almacen_x_cds_"+UserDet.getUserId()+".xml','almacen','','VALUE_COL','LABEL_COL','"+session.getAttribute("_companyId")+"-'+this.value,'KEY_COL','');setTimeout('clearDetail()',300);\"","","S")%>
																<%}else{%>
																	<%=fb.select(ConMgr.getConnection(),cdsQry,"centroServicio",FTransDet.getCentroServicio(),false,false,0, "text10", "", "onChange=\"clearDetail()\"","","S")%>
																<%}%>

								<!--<span id="info-1" title=""><span class="miniinfoBtn">i</span></span>-->
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="10">Almac&eacute;n</cellbytelabel></td>
							<td>

														<%if(fPage.equalsIgnoreCase("int_farmacia")){%>
														<%=fb.textBox("almacen",wh,false,true,false,6)%>
														<%}else{%>

															<%=fb.select("almacen","","",false,false,0,null,null,"onChange=clearDetail();")%>
							 <script>
								loadXML('../xml/almacen_x_cds_<%=UserDet.getUserId()%>.xml','almacen','<%=wh%>','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-<%=FTransDet.getCentroServicio()%>','KEY_COL','');
							</script>
														<%}%>

							</td>
						</tr>
						<%if(fg.equals("HON") || (tt!= null && tt.equals("H") && mode.equals("view"))){%>
						<tr class="TextHeader">
							<td colspan="4"><cellbytelabel id="11">Datos del M&eacute;dico</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td align="right" ><cellbytelabel id="7">M&eacute;dico</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("medico",FTransDet.getMedicoCirugia(),false,false,true,10)%>
								<%=fb.textBox("nombreMedico",FTransDet.getNombreMedicoCirugia(),false,false,true,50)%>
								<%=fb.button("btnMedico","...",true,viewMode,null,null,"onClick=\"javascript:searchMedicoList()\"")%>
							</td>

						</tr>


						<tr class="TextRow01">

							<td align="right"><cellbytelabel id="12">Sociedad</cellbytelabel>:</td>
								<td><%=fb.checkbox("pagar_sociedad",FTransDet.getPagarSociedad(),(FTransDet.getPagarSociedad().trim().equalsIgnoreCase("S")),viewMode,"","","onClick=\"javascript:clearMedEmpresa();\"")%>
								<%=fb.textBox("empreCodigo",FTransDet.getEmpreCodigo(),false,false,true,7)%>
								<%=fb.textBox("empreDesc",FTransDet.getEmpreNombre(),false,false,true,40)%>
								<%=fb.button("btnEmpresa","...",true,true,null,null,"onClick=\"javascript:selEmpresa()\"")%>
							</td>
							<td colspan="2"><%=fb.checkbox("diferencia_honorario",FTransDet.getDiferenciaHonorario(),(FTransDet.getDiferenciaHonorario().trim().equalsIgnoreCase("S")),viewMode,"","","")%><cellbytelabel id="13">Cobra diferencia no cubierta por Cia.de Seguro</cellbytelabel>
							</td>
						</tr>
						<tr class="TextRow01">
							<td><cellbytelabel id="14">Anotaciones</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textarea("descripcion",FTransDet.getDescripcion(),false,false,false,100,2, 2000)%>
							</td>
						</tr>
						<%}%>
						</table>
					</td>
				</tr>
				<%if(fg.equals("PAC") && !codCds.equals("")){%>
				<tr>
					<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="15">Datos Generales de Factura (Servicios Externos)</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel2">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="16">Proveedor</cellbytelabel></td>
							<td colspan="3">
								<%=fb.textBox("seCodProveedor",FTransDet.getSeCodProveedor(),false,false,true,10)%>
								<%=fb.textBox("seDescProveedor",FTransDet.getSeDescProveedor(),false,false,true,50)%>
								<%=fb.button("btnProveedor","...",true,viewMode,null,null,"onClick=\"javascript:selProveedor()\"")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="17">N&uacute;mero Doc.</cellbytelabel></td>
							<td>
								<%=fb.intBox("seNumeroDocumento",FTransDet.getSeNumeroDocumento(),false,false,false,5)%>
							</td>
							<td align="right"><cellbytelabel id="18">Fecha Doc.</cellbytelabel></td>
							<td>
							<%if (mode.equalsIgnoreCase("add")){%>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="seFechaDocumento" />
								<jsp:param name="valueOfTBox1" value="<%=FTransDet.getSeFechaDocumento()%>" />
								</jsp:include>
							<%}else{%>
								<%=fb.textBox("seFechaDocumento",FTransDet.getSeFechaDocumento(),false,false,true,10)%>
							<%}%>
							</td>
						</tr>
						</table>
					</td>
				</tr>
				<%}else{%>
				<%=fb.hidden("seCodProveedor",FTransDet.getSeCodProveedor())%>
				<%=fb.hidden("seDescProveedor",FTransDet.getSeDescProveedor())%>
				<%=fb.hidden("seFechaDocumento",FTransDet.getSeFechaDocumento())%>
				<%=fb.hidden("seNumeroDocumento",FTransDet.getSeNumeroDocumento())%>
				<%}%>

				<tr>
					<td>
						<iframe name="itemFrame" id="itemFrame" align="center" width="100%" height="0" scrolling="yes" frameborder="0" border="0" src="../facturacion/reg_cargo_dev_det_new.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fPage=<%=fPage%>&tipoTransaccion=<%=tipoTransaccion%>&no_orden=<%=noOrden%>&codigo_orden=<%=codigoOrden%>&bar__code=<%=barCode%>"></iframe>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="19">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel id="20">Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",false,viewMode,false)%><cellbytelabel id="21">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel id="22">Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<script>$("#pacBrazalete").focus();</script>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	String ref_code = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
		ref_code = request.getParameter("ref_code");
		codigo = FTransDet.getCodigo();
		noAdmision = FTransDet.getAdmiSecuencia();
		pacienteId = FTransDet.getPacienteId();
		tt = FTransDet.getTipoTransaccion();
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script>
function closeWindow()
{
<%
if (errCode.equals("1")){
	String LotExpirationDate = java.util.ResourceBundle.getBundle("issi").getString("LotExpirationDate");
	if(LotExpirationDate==null || LotExpirationDate.equals("")) LotExpirationDate = "N";
	if(request.getParameter("reg_lote")!=null && request.getParameter("reg_lote").equals("N")) LotExpirationDate= "N";
%>
	alert('<%=errMsg%>');
	<%
	session.removeAttribute("fTranCarg");
	session.removeAttribute("fTranCargKey");
	session.removeAttribute("FTransDet");
	session.removeAttribute("fTranComp");
	session.removeAttribute("fTranCompKey");
	session.removeAttribute("fTranDComp");

	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('viewMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
		if(!fPage.equals("general_page") && !fPage.equals("int_farmacia")){
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/list_cargo_dev.jsp?fg=<%=fg%>';
<%
		}
%>
	printCargosOF();

	<%
	if(LotExpirationDate.equals("Y")){
	%>
	regLoteFecha();
	<%}%>
	window.close();
<%
	}

} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>&fPage=<%=fPage%>&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>&no_orden=<%=noOrden%>&codigo_orden=<%=codigoOrden%>&id_int_far=<%=idIntFar%>&bac__code=<%=barCode%>&from_new_view=<%=fromNewView%>';
}

function viewMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&codigo=<%=codigo%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&pacienteId=<%=pacienteId%>&tt=<%=tt%>&no_orden=<%=noOrden%>&codigo_orden=<%=codigoOrden%>&id_int_far=<%=idIntFar%>&bac__code=<%=barCode%>&from_new_view=<%=fromNewView%>';
}
function printCargosOF(){
	<%if (request.getParameter("printOF") != null && request.getParameter("printOF").trim().equals("S") ){%>
		//a.centro_servicio  & b.fecha_cargo & b.usuario_creacion & b.cod_uso & b.tipo_cargo
		win=window.open('../facturacion/print_cargo_dev.jsp?noSecuencia=<%=noAdmision%>&pacId=<%=pacienteId%>&codigo=<%=codigo%>&printOF=S&tipoTransaccion=<%=tt%>');
		win.moveTo(0,0);win.resizeTo(screen.availWidth,screen.availHeight);
		//top.childArray[top.childArray.length]=win;
		return win;
	<%}%>

	//compania, secuencia, fac_codigo, fac_secuencia, fac_fecha_nacimiento, fac_codigo_paciente, tipo_transaccion

}
function regLoteFecha(){
		win=window.open('../inventario/reg_lote_fecha_vencimiento.jsp?ref_type=CARGO&ref_code=<%=issi.admin.IBIZEscapeChars.forURL(ref_code)%>');
		win.moveTo(0,0);win.resizeTo(screen.availWidth,screen.availHeight);
		return win;
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
