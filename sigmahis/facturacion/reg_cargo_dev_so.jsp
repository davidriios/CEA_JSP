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
<jsp:useBean id="fTranCarg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCargKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranComp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranCompKey" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="fTranDComp" scope="session" class="java.util.Hashtable" />
<%
/**
======================================================================================================================================================
FORMA							MENU																																																										NOMBRE EN FORMA
CDC100120					INVENTARIO\TRANSACCIONES\REQUISICION\MAT. PACIENTES - CONSULTA DE PRORAMAS QUIRURGICOS\SOLICITUD INSUMOS QUIRURGICOS		SOLICITUD PREVIA DE MAT. Y MED. PARA PACIENTES EN SALON DE OPERACIONES.
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
CommonDataObject cdoCount = new CommonDataObject();

String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
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
String almacenSOP = ResourceBundle.getBundle("issi").getString("almacenSOP");
String maletinAnestGen = ResourceBundle.getBundle("issi").getString("maletinAnestGen");

String cds = "";
int lineNo = 0;
if (tab == null) tab = "0";
if (mode == null) mode = "add";

	CommonDataObject codCds = SQLMgr.getData("select codigo from tbl_cds_centro_servicio where flag_cds = 'SOP'");
	if(codCds!=null && !codCds.getColValue("codigo").equals("")){cds = codCds.getColValue("codigo");} else throw new Exception("El Centro de Servicio para Salon de Operación no está difinido. Por favor intente nuevamente!");

			if (codCita == null) throw new Exception("El Código de Cita no es válido. Por favor intente nuevamente!");
			if (fechaCita == null) throw new Exception("La Fecha de Cita no es válida. Por favor intente nuevamente!");
			if (tipoSolicitud == null) throw new Exception("El tipo de Solicitud no es válido. Por favor intente nuevamente!");
			if (almacenSOP == null) throw new Exception("El Almacen para Salon de Operaciones no está difinido. Por favor intente nuevamente!");
			CdcSol = new CdcSolicitud();
			session.setAttribute("CdcSol",CdcSol);
			if(tipoSolicitud.equals("Q")) label = "QUIRURGICOS";
			else if(tipoSolicitud.equals("A")) label = "ANESTESIA";
			//Query de citas
			sql = "select c.nombre_paciente nombre_paciente, c.codigo, c.fecha_registro, to_char (c.hora_cita, 'HH12:MI AM') hora_cita, c.hora_est, c.min_est, c.persona_reserva, to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'HH12:MI AM') hora_final, to_date(to_char(c.fecha_cita, 'DD-MM-YYYY'), 'DD-MM-YYYY') fecha_inicio, to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)), 'DD-MM-YYYY'), 'DD-MM-YYYY') fecha_final, to_date(to_char (c.fecha_cita, 'DD-MM-YYYY') || ' ' || to_char(c.hora_cita, 'HH24:MI'), 'DD-MM-YYYY HH24:MI') fecha_hora_inicio, nvl(get_nombremedico(c.compania,'COD_FUNC_CIRUJANO',to_char(c.fecha_registro,'dd/mm/yyyy')||(to_char(c.codigo))),'') as cirujano ,nvl(get_nombremedico(c.compania,'COD_FUNC_ANEST',to_char( c.fecha_registro,'dd/mm/yyyy')||(to_char(c.codigo))),'')||nvl(get_nombremedico(c.compania,'COD_FUNC_ANEST_SOC',to_char( c.fecha_registro,'dd/mm/yyyy')||(to_char(c.codigo))),'') as anestesiologo, c.habitacion, c.centro_servicio from tbl_cdc_cita c where to_date(to_char(c.fecha_registro, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy') and c.codigo = "+codCita+" and c.compania = " + (String) session.getAttribute("_companyId");

			cdoCita = SQLMgr.getData(sql);

			CdcSol.setCitaCodigo(codCita);
			CdcSol.setCitaFechaReg(fechaCita);
			CdcSol.setCodigoAlmacen(almacenSOP);
			if(cdoCita.getColValue("centro_servicio")!=null && !cdoCita.getColValue("centro_servicio").equals("")) CdcSol.setCentroServicio(cdoCita.getColValue("centro_servicio"));
			else CdcSol.setCentroServicio(cds);
			CdcSol.setTipoSolicitud(tipoSolicitud);
			
				// query de procedimientos por cita
	sql = "select a.codigo, nvl(b.observacion, b.descripcion) desc_procedimiento from tbl_cdc_cita_procedimiento a, tbl_cds_procedimiento b where a.procedimiento = b.codigo and a.cod_cita = "+codCita+" and to_date(to_char(a.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy')";
	alProc = SQLMgr.getDataList(sql);
if (request.getMethod().equalsIgnoreCase("GET"))
{
	
		fTranCarg.clear();
		fTranCargKey.clear();
		fTranComp.clear();
		fTranCompKey.clear();
		
	if(change==null){
	if (mode.equalsIgnoreCase("add"))//||mode.equalsIgnoreCase("edit"))
	{
			CdcSol.setCitaCodigo(codCita);
			CdcSol.setCitaFechaReg(fechaCita);
			CdcSol.setCodigoAlmacen(almacenSOP);
			if(CdcSol.getCentroServicio() == null || CdcSol.getCentroServicio().trim().equals(""))CdcSol.setCentroServicio(cds);
			CdcSol.setTipoSolicitud(tipoSolicitud);

				if (alProc.size() == 0)
				{
					sql = "select min(secuencia) as secuencia, count(*) as nRecs from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy') and estado = 'P' and codigo_almacen = 3 and centro_servicio = 11 and tipo_solicitud = '"+tipoSolicitud+"'";
					cdoX = SQLMgr.getData(sql);
					if (cdoX.getColValue("nRecs").equals("0"))
					{
						sql = "select decode(estado,'T','TRAMITE','E','ENTREGADO','A','APROBADO') as estado from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy') and estado in ('T','E','A') and codigo_almacen = 3 and centro_servicio = 11 and tipo_solicitud = '"+tipoSolicitud+"' and rownum = 1";
						cdoX = SQLMgr.getData(sql);
						if (cdoX != null && cdoX.getColValue("estado") != null) estado = cdoX.getColValue("estado");
					}
					else if (cdoX.getColValue("nRecs").equals("1"))
					{
						sql = "select a.art_familia, a.art_clase, a.cod_articulo as articulo, nvl(a.precio,0) as precio, a.cantidad, nvl(a.paquete,'N') as paquete, nvl(a.cantidad_paquete,0) as cantidad_paquete, (select descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as descripcion, (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as cod_medida from tbl_cdc_solicitud_det a where a.cita_codigo = "+codCita+" and a.cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy') and a.secuencia = "+cdoX.getColValue("secuencia")+"  order by 8";
						al = SQLMgr.getDataList(sql);
					}
				}//alProc size = 0
				else
				{
				
				sql = "select count(*) cont from tbl_cds_insumo_x_proc c, tbl_inv_inventario i, tbl_inv_articulo a where c.compania = " + (String) session.getAttribute("_companyId") + " and c.articulo = i.cod_articulo and c.compania = i.compania and a.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and i.codigo_almacen = "+almacenSOP+" and c.cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = " + codCita + " and to_date(to_char(fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and nvl(prioridad,codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") + ",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100))";
		cdoCount = SQLMgr.getData(sql);
		
		if(cdoCount != null && Integer.parseInt(cdoCount.getColValue("cont")) > 0){
			if(CdcSol.getTipoSolicitud().equals("A")){
				sql="select y.art_familia, y.art_clase,y.articulo,y.cantidad, y.paquete,y.cantidad_paquete, y.descripcion,y.cod_medida,y.config,y.wh,i.precio from(select a.cod_flia art_familia, a.cod_clase art_clase, x.cod_articulo articulo,nvl(x.cantidad, 0) as cantidad, 'N' paquete, 0 cantidad_paquete, a.descripcion, a.cod_medida,'S' as config ,x.compania,nvl(get_sop_wh(x.compania,a.cod_flia,a.cod_clase,"+almacenSOP+" ),"+almacenSOP+") as wh from (select compania,c.cod_articulo,max(cantidad) as cantidad from tbl_cds_maletin_insumo c where c.compania = " + (String) session.getAttribute("_companyId") + " and exists ( SELECT null FROM TBL_CDC_CITA_PROCEDIMIENTO a, TBL_CDS_PROCEDIMIENTO b WHERE b.codigo = a.procedimiento AND b.tipo_maletin_anestesia IS NOT NULL AND a.cod_cita = " + codCita + " AND TO_DATE (TO_CHAR (a.fecha_cita, 'dd/mm/yyyy'),'dd/mm/yyyy') = TO_DATE ('" + fechaCita + "', 'dd/mm/yyyy') and b.tipo_maletin_anestesia = c.cod_maletin and nvl(a.prioridad,a.codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") +"  ,'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100)) group by compania, c.cod_articulo) x, tbl_inv_articulo a where x.compania = " + (String) session.getAttribute("_companyId") + " and  x.cod_articulo = a.cod_articulo and x.compania = a.compania ) y , tbl_inv_inventario i where y.articulo = i.cod_articulo and y.compania = i.compania and i.codigo_almacen=y.wh order by y.descripcion,art_familia, art_clase,articulo ";
								
				//sql = "select c.cod_familia art_familia, c.cod_clase art_clase, c.cod_articulo articulo, i.precio, nvl(c.cantidad, 0) cantidad, 'N' paquete, 0 cantidad_paquete, a.descripcion, a.cod_medida,'S' as config from tbl_cds_maletin_insumo c, tbl_inv_inventario i, tbl_inv_articulo a where c.compania = " + (String) session.getAttribute("_companyId") + " and  c.cod_articulo = i.cod_articulo and c.compania = i.compania and i.codigo_almacen = "+almacenSOP+" /* and c.cod_maletin = (case when getMaletin(" + codCita + ", '" + fechaCita + "') = -1 then "+maletinAnestGen+" else getMaletin(" + codCita + ", '" + fechaCita + "')end) */ 	and exists ( SELECT null FROM TBL_CDC_CITA_PROCEDIMIENTO a, TBL_CDS_PROCEDIMIENTO b WHERE b.codigo = a.procedimiento AND b.tipo_maletin_anestesia IS NOT NULL AND a.cod_cita = " + codCita + " AND TO_DATE (TO_CHAR (a.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = TO_DATE ('" + fechaCita + "', 'dd/mm/yyyy') and b.tipo_maletin_anestesia = c.cod_maletin and nvl(a.prioridad,a.codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") + ",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100) ) and a.cod_articulo = i.cod_articulo and a.compania = i.compania order by a.descripcion, c.cod_familia, c.cod_clase, c.cod_articulo";
			} else if(CdcSol.getTipoSolicitud().equals("Q")){
				sql = "select a.*, b.descripcion, b.cod_medida, nvl(c.paquete, 'N') paquete, nvl(c.cantidad_paquete, 0) cantidad_paquete,'S' as config from (select i.compania, c.art_familia, c.art_clase, c.articulo, i.precio, max(nvl(cantidad, 0)) cantidad from tbl_cds_insumo_x_proc c, tbl_inv_inventario i, tbl_inv_articulo a where c.compania = " + (String) session.getAttribute("_companyId") + " and c.articulo = i.cod_articulo and c.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and i.codigo_almacen = "+almacenSOP+" and c.cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = " + codCita + " and to_date(to_char(fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and nvl(prioridad,codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") + ",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100) ) group by i.compania,c.art_familia, c.art_clase, c.articulo, i.precio order by c.art_familia, c.art_clase, c.articulo) a, tbl_inv_articulo b, (select paquete, art_familia, art_clase, articulo, max(nvl(cantidad, 0)) cantidad_paquete from tbl_cds_insumo_x_proc where compania = " + (String) session.getAttribute("_companyId") + " and paquete = 'S' and cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = " + codCita + " and to_date(to_char(fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and nvl(prioridad,codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") + ",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100)) group by paquete, art_familia, art_clase, articulo) c where a.compania = b.compania and a.articulo = b.cod_articulo and a.articulo =  c.articulo(+) order by b.descripcion, a.art_familia, a.art_clase, a.articulo ";
			}
			change = "1";
			System.out.println("sql detail:\n"+sql);
			al = SQLMgr.getDataList(sql);
			}//count
		}//alProc size > 0
			for(int i=0; i<al.size(); i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				CdcSolicitudDet det = new CdcSolicitudDet();
				det.setArtFamilia(cdo.getColValue("art_familia"));
				det.setArtClase(cdo.getColValue("art_clase"));
				det.setCodArticulo(cdo.getColValue("articulo"));
				det.setDescripcion(cdo.getColValue("descripcion"));
				det.setPrecio(cdo.getColValue("precio"));
				det.setCantidad(cdo.getColValue("cantidad"));
				det.setPaquete(cdo.getColValue("paquete"));
				det.setCantidadPaquete(cdo.getColValue("cantidad_paquete"));
				det.setUnidad(cdo.getColValue("cod_medida"));
				det.setConfiguradoCpt(cdo.getColValue("config"));

				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					fTranCarg.put(key, det);
					fTranCargKey.put(CdcSol.getTipoSolicitud()+"_"+det.getCodArticulo(), key);
					//CdcSol.getCdcSolail().add(det);
					//System.out.println("adding item "+key+" _ "+det.getTipoCargo()+"_"+det.getTrabajo());
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}//for i
	} //mode = add
	else if (!mode.equalsIgnoreCase("add"))
	{
			// determinar secuencia de solicitud de insumos (ya registrada) para la cita
			sql = "select s.secuencia as secuencia, count(*) as nRecs  from tbl_cdc_solicitud_enc s, (select max(secuencia) maxSec from tbl_cdc_solicitud_enc   where cita_codigo ="+codCita+"  and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy')    and tipo_solicitud = '"+tipoSolicitud+"') x1  where s.cita_codigo ="+codCita+" and s.cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy')   and s.estado = 'P' and s.tipo_solicitud = '"+tipoSolicitud+"'  and s.secuencia = x1.maxSec  group by s.secuencia ";
			cdoX = SQLMgr.getData(sql);
			//l = "select a.codigo, nvl(b.observacion, b.descripcion) desc_procedimiento from tbl_cdc_cita_procedimiento a, tbl_cds_procedimiento b where a.procedimiento = b.codigo and a.cod_cita = "+codCita+" and to_date(to_char(a.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy')";
			//Proc = SQLMgr.getDataList(sql);
			//if (alProc.size() == 0
			// determinar si la cantida de solicitudes existentes es != 0 => indica que existe solicitud => buscar datos de la solicitud
			if (!cdoX.getColValue("nRecs").equals("0"))
			{
				//sql = "select min(secuencia) as secuencia, count(*) as nRecs from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy') and estado = 'P' and codigo_almacen = 3 and centro_servicio = 11 and tipo_solicitud = '"+tipoSolicitud+"'";
				//sql = "select s.secuencia as secuencia, count(*) as nRecs  from tbl_cdc_solicitud_enc s, (select max(secuencia) maxSec from tbl_cdc_solicitud_enc   where cita_codigo = 52  and to_date(to_char(cita_fecha_reg, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('"+fechaCita+"', 'dd/mm/yyyy')    and tipo_solicitud = '"+tipoSolicitud+"') x1  where s.cita_codigo ="+codCita+" and s.cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy')   and s.estado = 'P'  /* and s.codigo_almacen = 3  and s.centro_servicio = 11*/  and s.tipo_solicitud = '"+tipoSolicitud+"'  and s.secuencia = x1.maxSec  group by s.secuencia ";
				//cdoX = SQLMgr.getData(sql);
/*				if (cdoX.getColValue("nRecs").equals("0"))
				{
					sql = "select decode(estado,'T','TRAMITE','E','ENTREGADO','A','APROBADO') as estado from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy') and estado in ('T','E','A') and codigo_almacen = 3 and centro_servicio = 11 and tipo_solicitud = '"+tipoSolicitud+"' and rownum = 1 ";
					cdoX = SQLMgr.getData(sql);
					if (cdoX != null && cdoX.getColValue("estado") != null) estado = cdoX.getColValue("estado");
				}
				else*/ if (!cdoX.getColValue("nRecs").equals("0"))
				{
					sql = "select a.art_familia, a.art_clase, a.cod_articulo as articulo, nvl(a.precio,0) as precio, a.cantidad, nvl(a.paquete,'N') as paquete, nvl(a.cantidad_paquete,0) as cantidad_paquete, (select descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as descripcion, (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as cod_medida from tbl_cdc_solicitud_det a where a.cita_codigo = "+codCita+" and a.cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy') and a.secuencia = "+cdoX.getColValue("secuencia");
					al = SQLMgr.getDataList(sql);

					sql = "select decode(estado,'T','TRAMITE','E','ENTREGADO','A','APROBADO') as estado, secuencia as secuencia,  cita_codigo as citaCodigo, to_char(cita_fecha_reg,'dd/mm/yyyy') as citaFecha, tipo_solicitud as tipoSolicitud, centro_servicio as centroServicio, codigo_almacen as codigoAlmacen from tbl_cdc_solicitud_enc where cita_codigo = "+codCita+" and cita_fecha_reg = to_date('"+fechaCita+"','dd/mm/yyyy')  and tipo_solicitud = '"+tipoSolicitud+"' /*and rownum = 1*/ and secuencia = "+cdoX.getColValue("secuencia") ;
					cdoX = SQLMgr.getData(sql);
					if (cdoX != null && cdoX.getColValue("estado") != null) estado = cdoX.getColValue("estado");

					if (cdoX !=null)
					{
							CdcSol.setCitaCodigo(cdoX.getColValue("citaCodigo"));
							CdcSol.setCitaFechaReg(cdoX.getColValue("citaFecha"));
							CdcSol.setCodigoAlmacen(cdoX.getColValue("codigoAlmacen"));
							CdcSol.setCentroServicio(cdoX.getColValue("centroServicio"));
							CdcSol.setTipoSolicitud(cdoX.getColValue("tipoSolicitud"));
							CdcSol.setSecuencia(cdoX.getColValue("secuencia"));
					}

				}
			}//alProc size = 0
			else
			{
				sql = "select count(*) cont from tbl_cds_insumo_x_proc c, tbl_inv_inventario i, tbl_inv_articulo a where c.compania = " + (String) session.getAttribute("_companyId") + " and c.articulo = i.cod_articulo and c.compania = i.compania and a.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and i.codigo_almacen = "+almacenSOP+" and c.cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = " + codCita + " and to_date(to_char(fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and nvl(prioridad,codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") + ",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100))";
				cdoCount = SQLMgr.getData(sql);
				if (cdoCount != null && Integer.parseInt(cdoCount.getColValue("cont")) > 0)
				{
					if (CdcSol.getTipoSolicitud().equalsIgnoreCase("A"))
					{
						sql = "select c.cod_familia art_familia, c.cod_clase art_clase, c.cod_articulo articulo, i.precio, nvl(c.cantidad, 0) cantidad, 'N' paquete, 0 cantidad_paquete, a.descripcion, a.cod_medida,'S' as config  from tbl_cds_maletin_insumo c, tbl_inv_inventario i, (select decode(sign(count(tipo_maletin_anestesia)-1), 1, 2, 1) maletin from (select distinct b.tipo_maletin_anestesia from tbl_cdc_cita_procedimiento a, tbl_cds_procedimiento b where b.codigo = a.procedimiento and b.tipo_maletin_anestesia is not null and a.cod_cita = " + codCita + " and to_date(to_char(a.fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy')) ) m, tbl_inv_articulo a where c.compania = " + (String) session.getAttribute("_companyId") + " and c.cod_articulo = i.cod_articulo and c.compania = i.compania and i.codigo_almacen = "+almacenSOP+" and c.cod_maletin = nvl(m.maletin, 1)  and a.cod_articulo = i.cod_articulo and a.compania = i.compania order by a.descripcion, c.cod_familia, c.cod_clase, c.cod_articulo";
						al = SQLMgr.getDataList(sql);
					}
					else if (CdcSol.getTipoSolicitud().equalsIgnoreCase("Q"))
					{
						sql = "select a.*, b.descripcion, b.cod_medida, nvl(c.paquete, 'N') paquete, nvl(c.cantidad_paquete, 0) cantidad_paquete,'S' as config  from (select i.compania, c.art_familia, c.art_clase, c.articulo, i.precio, max(nvl(cantidad, 0)) cantidad from tbl_cds_insumo_x_proc c, tbl_inv_inventario i, tbl_inv_articulo a where c.compania = " + (String) session.getAttribute("_companyId") + " and c.articulo = i.cod_articulo and c.compania = i.compania and a.cod_articulo = i.cod_articulo and a.estado = 'A' and i.codigo_almacen = "+almacenSOP+" and c.cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = " + codCita + " and to_date(to_char(fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and nvl(prioridad,codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") + ",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100) ) group by i.compania,c.art_familia, c.art_clase, c.articulo, i.precio order by c.art_familia, c.art_clase, c.articulo) a, tbl_inv_articulo b, (select paquete, art_familia, art_clase, articulo, max(nvl(cantidad, 0)) cantidad_paquete from tbl_cds_insumo_x_proc where compania = " + (String) session.getAttribute("_companyId") + " and paquete = 'S' and cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = " + codCita + " and to_date(to_char(fecha_cita, 'dd/mm/yyyy'), 'dd/mm/yyyy') = to_date('" + fechaCita + "', 'dd/mm/yyyy') and nvl(prioridad,codigo) <= nvl(get_sec_comp_param(" + (String) session.getAttribute("_companyId") + ",'CDC_PRIORIDAD_CPT_SOL_INSUMOS'),100) ) group by paquete, art_familia, art_clase, articulo) c where a.compania = b.compania and  a.articulo = b.cod_articulo and a.articulo =  c.articulo(+) order by b.descripcion, a.art_familia, a.art_clase, a.articulo ";
						al = SQLMgr.getDataList(sql);
					}
				}//count
			}//alProc size > 0

			for(int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				CdcSolicitudDet det = new CdcSolicitudDet();
				det.setArtFamilia(cdo.getColValue("art_familia"));
				det.setArtClase(cdo.getColValue("art_clase"));
				det.setCodArticulo(cdo.getColValue("articulo"));
				det.setDescripcion(cdo.getColValue("descripcion"));
				det.setPrecio(cdo.getColValue("precio"));
				det.setCantidad(cdo.getColValue("cantidad"));
				det.setPaquete(cdo.getColValue("paquete"));
				det.setCantidadPaquete(cdo.getColValue("cantidad_paquete"));
				det.setUnidad(cdo.getColValue("cod_medida"));				
				det.setConfiguradoCpt(cdo.getColValue("config"));

				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try
				{
					fTranCarg.put(key, det);
					fTranCargKey.put(CdcSol.getTipoSolicitud()+"_"+det.getCodArticulo(), key);
				}
				catch (Exception e)
				{
					System.out.println("Unable to addget item "+key);
				}
			}//for i
	} // mode !=add
	}//change = null

	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Facturación - '+document.title;

function removeItem(fName,k){
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue){
	document.forms[fName].baction.value = actionValue;
	if(actionValue=='Guardar'){
		chkInsumos();
		
		if(document.form0.chkSentSolAlm.checked){
		   if( ! confirm ("Está usted seguro(a) de enviar la solicitud al almacén?") ) {
		     document.form0.chkSentSolAlm.checked = false; 
		   }
		}
		window.frames['itemFrame'].doSubmit();
	}
}


function doAction(estado){
	if(estado!='') CBMSG.warning('Existe una solicitud de materiales para este paciente en estado '+estado+'');
}

function chkInsumos(){
	var tipoSolicitud = document.form0.tipoSolicitud.value;
	var copiarInsumos = "N";
	if(tipoSolicitud=='Q'){
		var cont=getDBData('<%=request.getContextPath()%>','count(*)','tbl_cds_insumo_x_proc','compania=<%=(String) session.getAttribute("_companyId")%> and cod_proced in (select procedimiento from tbl_cdc_cita_procedimiento where cod_cita = <%=codCita%> and to_date(to_char(fecha_cita, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\'<%=fechaCita%>\', \'dd/mm/yyyy\')  )','');

		if(cont=='' || cont =='0'){
			if(confirm('El (Los) Procedimiento(s) de esta cita no tienen insumos detallados en su mantenimiento, desea copiarle los insumos de esta solicitud?')){
				copiarInsumos = "S";
			}
		}
	}
	document.form0.copiarInsumos.value = copiarInsumos;
}

function sentSolToAlmacen(){
	var tipoSolicitud = document.form0.tipoSolicitud.value;
	var y = 0;
	if(document.form0.chkSentSolAlm.checked){
		var cursor=getDBData('<%=request.getContextPath()%>','nvl(sol_quirurgica, 0) sol_quirurgica, nvl(sol_anestesia, 0) sol_anestesia','tbl_cdc_cita','codigo = <%=codCita%> and to_date(to_char(fecha_registro, \'dd/mm/yyyy\'), \'dd/mm/yyyy\') = to_date(\'<%=fechaCita%>\', \'dd/mm/yyyy\')','');
		var arr_cursor = new Array();

		arr_cursor = splitRowsCols(cursor);

		for(i=0;i<arr_cursor.length;i++){
			var x = arr_cursor[i];
			if((tipoSolicitud=='Q' && x[0]!=0) || tipoSolicitud=='A' && x[1]!=0) y++;
		}
		if(y>0){
			CBMSG.warning('Ya existe una solicitud en TRAMITE, no es posible hacer el envío de otra solicitud a Inventario!!!');
			document.form0.chkSentSolAlm.checked = false;
		}
	}
}

function splitRows(str){
	var row=null;
	if(str.indexOf('~')>=0) row=str.split('~');
	return row;
}

function splitCols(str){
	var col=null;
	if(str.indexOf('|')>=0) col=str.split('|');
	return col;
}

function splitRowsCols(str){
	var row=splitRows(str);
	var rowsCols=null;
	if(row!=null){
		rowsCols=new Array(row.length);
		for(i=0;i<row.length;i++){
			var col=splitCols(row[i]);
			if(col!=null)rowsCols[i]=col;
		}
	} else {
		var col=splitCols(str);
		if(col!=null){
			rowsCols=new Array();
			rowsCols[0]=col;
		}
	}
	return rowsCols;
}

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
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("mode",mode)%>
        <%=fb.hidden("errCode","")%>
        <%=fb.hidden("errMsg","")%>
        <%=fb.hidden("codCita",codCita)%>
        <%=fb.hidden("fechaCita",fechaCita)%>
        <%=fb.hidden("secuencia",CdcSol.getSecuencia())%>
        <%=fb.hidden("codAlmacen",CdcSol.getCodigoAlmacen())%>
        <%//=fb.hidden("centroServicio",CdcSol.getCentroServicio())%>
        <%=fb.hidden("tipoSolicitud",CdcSol.getTipoSolicitud())%>
        <%=fb.hidden("habitacion",cdoCita.getColValue("habitacion"))%>
				<%=fb.hidden("copiarInsumos","")%>
        <%=fb.hidden("baction","")%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("clearHT","")%>
        <%=fb.hidden("fPage",fPage)%>
				<%=fb.hidden("sentSolAlmacen","N")%>
				<%=fb.hidden("almacenSOP",almacenSOP)%>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextPanel">
								<td align="center" colspan="4"><%=cdoCita.getColValue("nombre_paciente")%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Hora Inicio</cellbytelabel>:</td>
								<td>
								<%=fb.textBox("hora_cita",cdoCita.getColValue("hora_cita"),true,false,true,10)%>
                </td>
								<td align="right"><cellbytelabel>Duraci&oacute;n Apr&oacute;x</cellbytelabel>.:</td>
								<td>
								<%=fb.textBox("hora_est",cdoCita.getColValue("hora_est"),false,false,true,5)%>
                &nbsp;hrs.
								<%=fb.textBox("min_est",cdoCita.getColValue("min_est"),false,false,true,5)%>
                &nbsp;min.
                </td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>C&iacute;a Seguro</cellbytelabel>:</td>
								<td colspan="3"><%=fb.textBox("cia_seguro_desc",cdoCita.getColValue("cia_seguro"),false,false,true,50)%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Cirujano</cellbytelabel>:</td>
								<td colspan="3"><%=fb.textBox("cirujano",cdoCita.getColValue("cirujano"),false,false,true,50)%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>Anestesi&oacute;logo</cellbytelabel>:</td>
								<td colspan="3"><%=fb.textBox("anestesiologo",cdoCita.getColValue("anestesiologo"),false,false,true,50)%></td>
							</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>AREA</cellbytelabel>:</td>
								<td colspan="3"><%=fb.select(ConMgr.getConnection(), "select codigo, descripcion from tbl_cds_centro_servicio where flag_cds = 'SOP'", "centroServicio",CdcSol.getCentroServicio(),false,viewMode,0)%></td>
							</tr> 
				 
				
				
						</table>
					</td>
				</tr>
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
				%>
						<tr class="TextRow01">
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
				<tr id="panel2">
					<td>
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../facturacion/reg_cargo_dev_det_so.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&fPage=<%=fPage%>&change=<%=change%>"></iframe>
					</td>
				</tr>
				<tr id="panel2">
					<td align="right"><%=fb.checkbox("chkSentSolAlm", "S", true, false, "", "", "onClick=\"javascript:sentSolToAlmacen()\"")%><cellbytelabel>Enviar Solicitud a Almac&eacute;n</cellbytelabel>&nbsp;&nbsp;<%//=fb.checkbox("chkCopiarInsumos", "S")%><!--<cellbytelabel>Copiar Insumos a CPT</cellbytelabel>--> </td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","O",false,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",true,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
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
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
		/*
		codigo = CdcSol.getCodigo();
		fechaCita = CdcSol.getAdmiSecuencia();
		codCita = CdcSol.getcodCita();
		*/
	}
	/*
	session.removeAttribute("fTranCarg");
	session.removeAttribute("fTranCargKey");
	session.removeAttribute("CdcSol");
	session.removeAttribute("fTranComp");
	session.removeAttribute("fTranCompKey");
	session.removeAttribute("fTranDComp");
	*/

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	<%if(request.getParameter("sentSolAlmacen")!=null && request.getParameter("sentSolAlmacen").equals("S")){%>
		var codCita = '<%=request.getParameter("codCita")%>';
		var fechaCita = '<%=request.getParameter("fechaCita")%>';
		var tipoSolicitud = '<%=request.getParameter("tipoSolicitud")%>';
		abrir_ventana1('../facturacion/print_sol_prev_mat.jsp?fechaRegistro='+fechaCita+'&codCita='+codCita+'&tipoSolicitud='+tipoSolicitud);
	<%}%>
<%
	if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('viewMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fg=<%=fg%>&fPage=<%=fPage%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>&tipoSolicitud=<%=tipoSolicitud%>';
}

function viewMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&fechaCita=<%=fechaCita%>&fg=<%=fg%>&codCita=<%=codCita%>&tipoSolicitud=<%=tipoSolicitud%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
