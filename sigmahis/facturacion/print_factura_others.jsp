<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="issi.facturacion.TipoServicio"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cServ" scope="page" class="java.util.Hashtable"/>
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	UserDet=SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);

	CmnMgr.setConnection(ConMgr);
	SQLMgr.setConnection(ConMgr);

	UserDet = SecMgr.getUserDetails(session.getId());
String userName = UserDet.getUserName();

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh:mi:ss am");
	String mon = fecha.substring(3, 5);
	String year = fecha.substring(6, 10);
	String date = fecha.substring(0, 10);
	String time = fecha.substring(11);
	String month = "";
	String tf = "";
	if (mon.equals("01")) month = "january";
	else if (mon.equals("02")) month = "february";
	else if (mon.equals("03")) month = "march";
	else if (mon.equals("04")) month = "april";
	else if (mon.equals("05")) month = "may";
	else if (mon.equals("06")) month = "june";
	else if (mon.equals("07")) month = "july";
	else if (mon.equals("08")) month = "august";
	else if (mon.equals("09")) month = "september";
	else if (mon.equals("10")) month = "october";
	else if (mon.equals("11")) month = "november";
	else if (mon.equals("12")) month = "december";

	String query = "";
	SQL2BeanBuilder sbb = new SQL2BeanBuilder();
	ArrayList al = new ArrayList();
	ArrayList al2 = new ArrayList();
	ArrayList al3 = new ArrayList();
	ArrayList al4 = new ArrayList();

	int nDetail = 0;
	int nHeader = 0;
	String noSecuencia = request.getParameter("noSecuencia");
	String pacId = request.getParameter("pacId");
	String compId = (String) session.getAttribute("_companyId");
	String factId = request.getParameter("factId");
	String empresa = request.getParameter("empresa");
	String facturar_a = request.getParameter("facturar_a");
	String reportName = request.getParameter("reportName");
	String sql = "", sql2 = "", sql3 = "";
	String faFilter = "";
	if(facturar_a != null) faFilter = " and facturar_a = '"+facturar_a+"'";
	if(reportName==null) reportName = "";
	if(factId!=null) faFilter += " and a.codigo = '"+factId+"'";
	System.out.println("reportName="+reportName);

	query="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1, nvl(fax, ' ') compFax1, digito_verificador other1, nvl(substr(replace(logo,'\\','/'),instr(replace(logo,'\\','/'),'/',-1)+1,length(replace(logo,'\\','/'))-instr(replace(logo,'\\','/'),'/',-1)),'NA') compLogo from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");
	System.out.println("company query = \n"+query);
	Company com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),query,Company.class);
	String logo = "lgc.jpg";
	if(!com.getCompLogo().equals("NA")) logo = com.getCompLogo();

	CommonDataObject cdoHeader = new CommonDataObject();
	CommonDataObject cdoTotal = new CommonDataObject();

	query = "select a.codigo, decode(b.admision,null,decode(a.facturar_a, 'P',0,'E',2),1) facturar_a, nvl(cod_empresa, '0') cod_empresa from tbl_fac_factura a, (select pac_id, admision from tbl_adm_beneficios_x_admision where prioridad=1 and convenio_sol_emp = 'S' and pac_id = "+pacId+" and admision = "+ noSecuencia +") b where /*a.estatus != 'A' and*/ a.pac_id ="+pacId+" and a.admi_secuencia = "+noSecuencia+" and a.pac_id = b.pac_id(+) and a.admi_secuencia = b.admision(+)"+faFilter;

	System.out.println("query Factura="+query);
	al3 = SQLMgr.getDataList(query);

	int z = -1;
	for(int k=0;k<al3.size();k++){
		CommonDataObject cdoFactura = (CommonDataObject) al3.get(k);
		z = Integer.parseInt(cdoFactura.getColValue("facturar_a"));
		factId = cdoFactura.getColValue("codigo");
		if(al3.size()>1 && cdoFactura.getColValue("facturar_a").equals("E")) tf = "E";
		query = "select to_char(decode(p.f_nac,null,p.fecha_nacimiento,p.f_nac),'dd/mm/yyyy') f_nac, a.fecha_nacimiento||'('||a.codigo_paciente||')('||a.secuencia||')' codigo_paciente, decode(p.pasaporte,null,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento,p.pasaporte) identificacion, p.primer_nombre||' '||p.segundo_nombre||' '||decode(p.apellido_de_casada,null,p.primer_apellido||' '||p.segundo_apellido,p.apellido_de_casada) nombre_paciente, m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) nombre_medico, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as categoria, f.admi_secuencia, f.codigo numero_factura, e.nombre nombre_aseguradora, to_char(f.fecha,'dd/mm/yyyy') fecha_factura, f.cod_empresa, f.facturar_a, f.compania, nvl(f.tipo_cobertura, ' ') doble_cobertura, decode(f.estatus,'A','ANULADA', f.estatus) estado_factura, f.lista, getNumPoliza(f.admi_secuencia, f.pac_id, f.cod_empresa, nvl(b.prioridad, 0)) numero_poliza, getNoCertificado(f.admi_secuencia, f.pac_id, f.codigo_beneficio) certificado from tbl_fac_factura f, tbl_adm_empresa e, tbl_adm_paciente p, tbl_adm_admision a, tbl_adm_medico m, (select pac_id, admision, min(prioridad) prioridad, decode(min(prioridad),1, min(num_aprobacion),0) num_aprobacion from tbl_adm_beneficios_x_admision group by pac_id, admision) b where f.compania = "+compId+" and f.codigo = '"+factId+"' and f.cod_empresa = e.codigo and f.admi_secuencia = a.secuencia and f.pac_id = a.pac_id and a.pac_id = p.pac_id and a.medico = m.codigo and a.secuencia = b.admision(+) and a.pac_id = b.pac_id(+)";

		cdoHeader = SQLMgr.getData(query);
		if(z==0){
			/*  FAC10086  */

			if(reportName.equals("FAC10086")){
				sql = " select 'CO' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto,0)+(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'CO' group by 'CO', 2, -1, f.descripcion";
				sql += " union select 'CO' tc, 3 nivel, f.centro_servicio cs, c.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'CO' and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'CO', 3, f.centro_servicio, c.descripcion";
				sql += " union select 'P' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto, 0) + nvl(f.descuento, 0) + nvl(f.monto_paciente, 0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'P' group by 'P', 2, -1, f.descripcion";

				sql += " union select 'P' tc, 3 nivel, f.centro_servicio cs, c.descripcion, sum (nvl (f.monto, 0) + nvl (f.descuento, 0) + nvl (f.monto_paciente, 0) ) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'P' and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'P', 3, f.centro_servicio, c.descripcion";
				sql += " union select 'I' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' and (f.tipo_cobertura not in ('CO','P') or f.tipo_cobertura is null) group by 'I', 1, f.centro_servicio, f.descripcion";
				sql += " union select 'T_E' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0)+nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds in ('T','E') and (f.tipo_cobertura not in ('P','CO') or f.tipo_cobertura is null) group by 'T_E', 1, f.centro_servicio, f.descripcion";
			} else if(reportName.equals("FAC70551")){
				sql = " select 'CO' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto,0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'CO' group by 'CO', 2, -1, f.descripcion";
				sql += " union select 'I' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'I', 1, f.centro_servicio, f.descripcion";
				sql += " union select 'T_E' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0)+nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'T' group by 'T_E', 1, f.centro_servicio, f.descripcion";
			}

			sql2 = "select coalesce(f.medico, to_char(f.med_empresa)) cod_soc_med, f.centro_servicio, f.descripcion, 0 monto_bruto, 0 monto_neto, sum(nvl(f.monto,0)) monto_pac from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio = 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' /*and (f.tipo_cobertura not in ('CO', 'Q') or f.tipo_cobertura is null)*/ group by f.centro_servicio, f.descripcion, coalesce(f.medico, to_char(f.med_empresa))";

			sql3 = "select nvl(f.subtotal, 0) subtotal, nvl(f.monto_descuento, 0) monto_descuento, nvl(f.monto_paciente, 0) monto_paciente, nvl(f.monto_total, 0) monto_total, nvl(f.grang_total,0) gran_total from tbl_fac_factura f where f.codigo = '"+factId+"' and f.compania = "+compId+"";

		} else if(z==1){
			if(empresa==null) empresa = cdoFactura.getColValue("cod_empresa");
			/*    FAC10084    */
			//  C11
			sql = " select 'Q' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto,0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'Q' group by 'Q', 2, -1, f.descripcion";
			//C8
			sql += " union select 'P' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto, 0) + nvl(f.descuento, 0) + nvl(f.monto_paciente, 0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'P' and f.imprimir_sino = 'S' and f.descripcion <> 'MEDICAMENTOS' group by 'P', 2, -1, f.descripcion";
			//C10
			sql += " union select 'P' tc, 3 nivel, f.centro_servicio cs, c.descripcion, sum (nvl (f.monto, 0) + nvl (f.descuento, 0) + nvl (f.monto_paciente, 0) ) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'P' and f.centro_servicio = c.codigo and f.imprimir_sino = 'S' group by 'P', 3, f.centro_servicio, c.descripcion";
			//C9
			sql += " union select 'PE' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'PE' and f.imprimir_sino = 'S' group by 'PE', 2, -1, f.descripcion";
			//C7
			sql += " union select 'MEDICAMENTOS' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.descripcion like '%MEDICAMENTOS%' and (f.tipo_cobertura not in ('PH') or f.tipo_cobertura is null) and f.imprimir_sino = 'S' group by 'MEDICAMENTOS', 1, f.centro_servicio, f.descripcion";
			//C3
			sql += " union select 'I' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.descuento2,0) + nvl(decode("+empresa+",236,null,f.monto_paciente),0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' and (f.tipo_cobertura not in ('P','PE','CO') or f.tipo_cobertura is null) and f.descripcion not like '%MEDICAMENTOS%' and f.imprimir_sino = 'S' group by 'I', 1, f.centro_servicio, f.descripcion";
			//C4
			sql += " union select 'T_E' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.descuento2,0) + nvl(decode("+empresa+",236,null,f.monto_paciente),0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds in ('T','E') and (f.tipo_cobertura not in ('P','PE','CO') or f.tipo_cobertura is null) and f.descripcion not like '%MEDICAMENTOS%' and f.imprimir_sino = 'S' group by 'T_E', 1, f.centro_servicio, f.descripcion";

			sql2 = "select coalesce(f.medico, to_char(f.med_empresa)) cod_soc_med, f.centro_servicio, f.descripcion, sum (nvl (f.monto, 0) + nvl (f.descuento, 0) + nvl (f.descuento2, 0) + nvl (decode ("+empresa+", 236, null, f.monto_paciente), 0)) monto_bruto, sum (nvl (f.monto, 0)) monto_neto, sum (nvl (f.monto_paciente, 0)) monto_pac, sum (nvl (f.monto, 0)) monto_neto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio = 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' and (f.tipo_cobertura not in ('P', 'PE') or f.tipo_cobertura is null) and f.descripcion not like '%MEDICAMENTOS%' and f.imprimir_sino = 'S' group by f.centro_servicio, f.descripcion, coalesce(f.medico, to_char(f.med_empresa))";

			sql3 = "select nvl(f.subtotal, 0) subtotal, nvl (f.monto_descuento, 0) monto_descuento, nvl(f.monto_paciente, 0) monto_paciente, nvl(f.monto_total, 0) monto_total, nvl(f.grang_total,0) gran_total, getCopago(f.compania, f.codigo) copago, getGastosNoCubiertos(f.compania, f.codigo) gastos_no_cubiertos from tbl_fac_factura f where f.codigo = '"+factId+"' and f.compania = "+compId+"";

		} else if(z==2){
			/*  FAC10087  */
			if(reportName.equals("FAC10087")){
				sql = " select 'CO' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'CO' group by 'CO', 2, -1, f.descripcion";

				sql += " union select 'CO' tc, 3 nivel, f.centro_servicio cs, c.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'CO' and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'CO', 3, f.centro_servicio, c.descripcion";

				sql += " union select 'P' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto, 0) + nvl(f.monto_paciente, 0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'P' group by 'P', 2, -1, f.descripcion";

				sql += " union select 'P' tc, 3 nivel, f.centro_servicio cs, c.descripcion, sum (nvl (f.monto, 0) + nvl (f.descuento, 0) + nvl (f.monto_paciente, 0) ) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'P' and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'P', 3, f.centro_servicio, c.descripcion";

				sql += " union select 'I' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' and (f.tipo_cobertura != 'P' or f.tipo_cobertura is null) group by 'I', 1, f.centro_servicio, f.descripcion";

				sql += " union select 'T_E' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0)+nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds in ('T','E') and (f.tipo_cobertura != 'P' or f.tipo_cobertura is null) group by 'T_E', 1, f.centro_servicio, f.descripcion";

				sql2 = "select coalesce(f.medico, to_char(f.med_empresa)) cod_soc_med, f.centro_servicio, f.descripcion, sum(nvl(f.monto, 0) + nvl(getDedMasPorc('"+factId+"', f.medico, f.med_empresa),0)) monto_bruto, sum(nvl(getDedMasPorc('"+factId+"', f.medico, f.med_empresa),0)) monto_pac, sum(nvl(f.monto,0)) monto_neto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio = 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' and f.imprimir_sino = 'S' group by f.centro_servicio, f.descripcion, coalesce(f.medico, to_char(f.med_empresa))";

				sql3 = "select nvl(f.subtotal, 0) subtotal, nvl(f.monto_descuento, 0) monto_descuento, nvl(f.monto_paciente, 0) monto_paciente, nvl(f.monto_total, 0) monto_total, nvl(f.grang_total,0) gran_total from tbl_fac_factura f where f.codigo = '"+factId+"' and f.compania = "+compId+"";

			} else if(reportName.equals("FAC70561")){

				//sql += " select 'CO' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto,0)+(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" /*and f.centro_servicio <> 0*/ and f.tipo_cobertura = 'CO' group by 'CO', 2, -1, f.descripcion";

				//sql += " union select 'CO' tc, 3 nivel, f.centro_servicio cs, c.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'CO' and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'CO', 3, f.centro_servicio, c.descripcion";

				sql = " select 'P' tc, 2 nivel, -1 cs, f.descripcion, sum(nvl(f.monto, 0) + nvl(f.monto_paciente, 0)) monto from tbl_fac_detalle_factura f where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.tipo_cobertura = 'P' group by 'P', 2, -1, f.descripcion";

				//sql += " union select 'P' tc, 3 nivel, f.centro_servicio cs, c.descripcion, sum (nvl (f.monto, 0) + nvl (f.descuento, 0) + nvl (f.monto_paciente, 0) ) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.tipo_cobertura = 'P' and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'P', 3, f.centro_servicio, c.descripcion";

				sql += " union select 'I' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by 'I', 1, f.centro_servicio, f.descripcion";

				sql += " union select 'T_E' tc, 1 nivel, f.centro_servicio cs, f.descripcion, sum(nvl(f.monto,0)+nvl(f.descuento,0)+nvl(f.monto_paciente,0)) monto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio <> 0 and f.centro_servicio = c.codigo and c.tipo_cds in ('T','E') group by 'T_E', 1, f.centro_servicio, f.descripcion";

				sql2 = "select coalesce(f.medico, to_char(f.med_empresa)) cod_soc_med, f.centro_servicio, f.descripcion, sum(nvl(f.monto, 0) + nvl(f.descuento,0) + nvl(f.monto_paciente,0)) monto_bruto, sum(nvl(f.monto_paciente,0)) monto_pac, sum(nvl(f.monto,0)) monto_neto from tbl_fac_detalle_factura f, tbl_cds_centro_servicio c where f.fac_codigo = '"+factId+"' and f.compania = "+compId+" and f.centro_servicio = 0 and f.centro_servicio = c.codigo and c.tipo_cds = 'I' group by f.centro_servicio, f.descripcion, coalesce(f.medico, to_char(f.med_empresa))";

				sql3 = "select nvl(f.subtotal, 0) subtotal, nvl(f.monto_descuento, 0) monto_descuento, nvl(f.monto_paciente, 0) monto_paciente, nvl(f.monto_total, 0) monto_total, nvl(f.grang_total,0) gran_total from tbl_fac_factura f where f.codigo = '"+factId+"' and f.compania = "+compId+"";
			}

		}
		al = SQLMgr.getDataList(sql);
		al2 = SQLMgr.getDataList(sql2);
		cdoTotal = SQLMgr.getData(sql3);

		int maxLines = 40; //max lines per page
		int nLines = al.size()+al2.size(); //number of lines
		int extraLines = 0;
		int nPages = 0; //number of pages

		//calculating number of page

		extraLines = nLines % maxLines;
		if (extraLines == 0) nPages = nLines / maxLines;
		else nPages = (nLines / maxLines) + 1;
		System.out.println("nLines= "+nLines);
		System.out.println("nPages= "+nPages);
		System.out.println("nPages= "+nPages);
		if(request.getMethod().equalsIgnoreCase("GET")) {

			String logoPath = java.util.ResourceBundle.getBundle("path").getString("images")+"/"+logo;
			String statusPath = "";
			boolean logoMark = false;
			boolean statusMark = false;

			String folderName = "facturacion";
			String fileNamePrefix = "FACTURA_"+compId+"_"+pacId+"_"+noSecuencia+"_"+k;
			String fileNameSuffix = "";
			String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
			String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
			String fileName=fileNamePrefix+"_"+year+"-"+month;
			String docTitle = "Detalle de Cargos";
			fileName = fileName+fileNameSuffix+".pdf";
			String create = CmnMgr.createFolder(directory, folderName, year, month);



			if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
			else {

				String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
				fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;

				int headerFooterFont = 4;

				StringBuffer sbFooter = new StringBuffer();
				sbFooter.append("");

				float leftRightMargin = 30.0f;
				float topMargin = 40.0f;
				float bottomMargin = 40.0f;

				issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);
	%>
	<%

				Vector setVal=new Vector();

				int lCounter = 0;
				int pCounter = 0;
				//***************//
				//***************//GENERAL HEADER BEGIN HERE
				//*****************************************//
				Vector setHeader0=new Vector();
				setHeader0.addElement(".75");
				setHeader0.addElement(".25");

				Vector setValDetailHeader=new Vector();
				setValDetailHeader.addElement(".15");
				setValDetailHeader.addElement(".70");
				setValDetailHeader.addElement(".15");

				Vector setHeader2=new Vector();
				setHeader2.addElement(".50");
				setHeader2.addElement(".10");
				setHeader2.addElement(".20");
				setHeader2.addElement(".20");

				Vector setHeaderPaciente=new Vector();
				setHeaderPaciente.addElement(".18");
				setHeaderPaciente.addElement(".34");
				setHeaderPaciente.addElement(".13");
				setHeaderPaciente.addElement(".15");
				setHeaderPaciente.addElement(".20");

				Vector setInnerVal = new Vector();
				setInnerVal.addElement("130");

				Vector setTotals = new Vector();
				setTotals.addElement("0.10");
				setTotals.addElement("0.14");
				setTotals.addElement("0.10");
				setTotals.addElement("0.09");
				setTotals.addElement("0.12");
				setTotals.addElement("0.09");
				setTotals.addElement("0.21");
				setTotals.addElement("0.15");

				int x = 0;
				int posI=0, posF=0, posIni=0, posFin=0;
				String cond = "1", lext = "";

				for (int j=1; j<=nPages; j++){
					int rows = 0;
					pc.setNoColumnFixWidth(setHeader0);

					pc.createTable();
						pc.setFont(12, 1);
						pc.addImageCols(""+logoPath,30.0f,0);
						pc.setVAlignment(2);

						pc.setNoInnerColumnFixWidth(setInnerVal);
						pc.createInnerTable();
							pc.setFont(7, 0);
							pc.addInnerTableCols("APARTADO "+com.getCompPAddress(), 2, 1);
							pc.addInnerTableCols("PANAMA, REP. DE PANAMA", 2, 1);
							pc.addInnerTableCols("TELEFONO "+com.getCompTel1(), 2, 1);
							pc.addInnerTableCols("FAX "+com.getCompFax1(), 2, 1);
						pc.addInnerTableToCols();

						pc.resetVAlignment();
					pc.addTable();

					pc.setNoColumnFixWidth(setHeader2);

					pc.createTable();
						pc.setFont(7, 0);
						pc.addBorderCols(com.getCompLegalName()+" "+com.getCompRUCNo()+" "+com.getOther1(), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
						pc.setFont(8, 0);
						pc.addBorderCols("CIA.: "+compId, 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
						pc.setFont(14, 1);
						pc.addBorderCols("Factura No.:", 0, 1, 0.5f, 0.5f, 0.5f, 0.0f);
						pc.addBorderCols(factId, 0, 1, 0.5f, 0.5f, 0.5f, 0.5f);
					pc.addTable();

					pc.createTable();
						pc.addCols("", 0,4);
					pc.addTable();

					pc.createTable();
						pc.addCols("", 0,4);
					pc.addTable();

					pc.createTable();
						pc.addCols("", 0,4);
					pc.addTable();

					pc.setNoColumnFixWidth(setHeaderPaciente);
					pc.setFont(7, 0);
					System.out.println("Z="+z);
					System.out.println("reportName="+reportName);
					String label = "";
					if(z==0){
						if(reportName.equalsIgnoreCase("FAC10086")){

							pc.createTable();
								pc.setFont(8, 1);
								pc.addBorderCols("NOMBRE:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("nombre_paciente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addBorderCols("CODIGO PAC:" , 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("codigo_paciente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addBorderCols("FECHA NAC:"+cdoHeader.getColValue("f_nac"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("ASEGURADORA:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_aseguradora"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("POLIZA:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("numero_poliza"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("IDENTIFICACION:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("identificacion"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("CERT:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("certificado"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("MEDICO:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_medico"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("FECHA:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("fecha_factura"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("LISTA DE ENVIO:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("lista"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("CATEGORIA:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("categoria"), 0, 1);
								pc.addCols(cdoHeader.getColValue("estado_factura"), 0, 1);
							pc.addTable();

						} else if(reportName.equalsIgnoreCase("FAC70551")){

							pc.createTable();
								pc.setFont(8, 1);
								pc.addBorderCols("Cliente:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("nombre_aseguradora"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addBorderCols("Cód. Pac:" , 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("codigo_paciente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addBorderCols("", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Identificación:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("identificacion"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("Fec. Nac.:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("f_nac"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Aseguradora:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_aseguradora"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("Póliza:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("numero_poliza"), 0, 1);
								pc.setFont(8, 1);
								pc.addBorderCols("Cert.: "+cdoHeader.getColValue("certificado"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Médico:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_medico"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("Fecha:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("fecha_factura"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Lista:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("lista"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("Categoría:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("categoria"), 0, 1);
								pc.addCols(cdoHeader.getColValue("estado_factura"), 0, 1);
							pc.addTable();
						}
					} else if(z==2){
						if(reportName.equalsIgnoreCase("FAC10087")){

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("ASEGURADORA:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_aseguradora"), 0, 1);
								pc.setFont(8, 1);
								pc.addBorderCols("CODIGO PAC.:" , 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("codigo_paciente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addCols("Fec. Nac.:"+cdoHeader.getColValue("f_nac"), 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addBorderCols("NOMBRE:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("nombre_paciente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addCols("Póliza:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("numero_poliza"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("IDENTIFICACION:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("identificacion"), 0, 1);
								pc.setFont(8, 1);
								pc.addBorderCols("CERT.: ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("certificado"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("MEDICO:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_medico"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("FECHA:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("fecha_factura"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("LISTA DE ENVIO:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("lista"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("CATEGORIA:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("categoria"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

						} else if(reportName.equalsIgnoreCase("FAC70561")){

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Aseguradora:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_aseguradora"), 0, 1);
								pc.setFont(8, 1);
								pc.addBorderCols("Cód. Pac:" , 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("codigo_paciente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addBorderCols("", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addBorderCols("Paciente:", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 0);
								pc.addBorderCols(cdoHeader.getColValue("nombre_paciente"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.setFont(8, 1);
								pc.addCols("Fec. Nac.:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("f_nac"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Identificación:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("identificacion"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("Póliza:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("numero_poliza"), 0, 1);
								pc.setFont(8, 1);
								pc.addBorderCols("Cert.: "+cdoHeader.getColValue("certificado"), 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Médico:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("nombre_medico"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("Fecha:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("fecha_factura"), 0, 1);
								pc.addCols("", 0, 1);
							pc.addTable();

							pc.createTable();
								pc.setFont(8, 1);
								pc.addCols("Lista:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("lista"), 0, 1);
								pc.setFont(8, 1);
								pc.addCols("Categoría:", 0, 1);
								pc.setFont(8, 0);
								pc.addCols(cdoHeader.getColValue("categoria"), 0, 1);
								pc.addCols(cdoHeader.getColValue("estado_factura"), 0, 1);
							pc.addTable();
						}
					}
					/*
					pc.setFont(7, 0);
					pc.createTable();
						pc.addCols("Por: "+userName, 0, 2);
						pc.addCols("Página: "+1+" de "+nPages, 2, 2);
					pc.addTable();
					*/

					pc.setNoColumnFixWidth(setValDetailHeader);

					pc.setFont(8, 1);
					pc.createTable();
						pc.addBorderCols("CODIGO", 1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
						pc.addBorderCols("D   E   S   C   R   I   P   C   I   O   N", 1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
						pc.addBorderCols("MONTO", 1, 1, 0.5f, 0.5f, 0.0f, 0.5f);
					pc.addTable();

					if (al.size() > 0 || al2.size() > 0){

						x=0;
						if (cond.equalsIgnoreCase("1")){
							posI = (maxLines * j) - maxLines;
							posF = maxLines * j;
						} else if (cond.equalsIgnoreCase("2")){
							posI = posIni;
							posF = posFin;
						}
%><%

						for (int i=posI; i<posF; i++){
							if (al.size() > 0){
								CommonDataObject cdo = (CommonDataObject) al.get(i);
								rows++;
								pc.setFont(8, 0);
								pc.createTable();
									pc.addBorderCols((cdo.getColValue("nivel").equals("1"))?cdo.getColValue("cs"):"", 1, 1, 0.0f, 0.0f, 0.5f, 0.5f);
									if(cdo.getColValue("nivel").equals("3")) pc.setFont(7, 0);
									pc.addBorderCols((cdo.getColValue("nivel").equals("3"))?"   "+cdo.getColValue("cs")+"-"+cdo.getColValue("descripcion"):cdo.getColValue("descripcion"), 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
									pc.setFont(8, 0);
									pc.addBorderCols((!cdo.getColValue("nivel").equals("3"))?CmnMgr.getFormattedDecimal(cdo.getColValue("monto")):"", 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
								pc.addTable();

								x=x+1;

								if(x==maxLines){
									cond="2";
									posIni=i+1;
									posFin=i+maxLines+1;
									lext = "1";
									break;
								}
							}

							if (((i + 1) == al.size()) || (al.size() == 0 && al2.size() >0)){
								for(int n=rows;n<25;n++){
									pc.setFont(8, 0);
									pc.createTable();
										pc.addBorderCols(" ", 1, 1, 0.0f, 0.0f, 0.5f, 0.5f);
										pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
										pc.addBorderCols(" ", 2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
									pc.addTable();
								}

								pc.setNoColumnFixWidth(setTotals);
								pc.setFont(8, 0);
								pc.createTable();
									pc.addBorderCols((z==0 || z==2)?"Copago del paciente:":"", 0, 2, 0.0f, 0.5f, 0.0f, 0.0f);
									pc.addBorderCols((z==0 || z==2)?""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("copago")):"", 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
									pc.addBorderCols("", 0, 3, 0.0f, 0.5f, 0.0f, 0.0f);
									pc.setFont(8, 1);
									pc.addBorderCols("SUBTOTAL", 0, 1, 0.5f, 0.5f, 0.5f, 0.5f);
									pc.setFont(8, 0);
									pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("subtotal")), 2, 1, 0.5f, 0.5f, 0.0f, 0.5f);
								pc.addTable();
								pc.createTable();
									pc.addBorderCols((z==0 || z==2)?"Gastos No Cubiertos o No Elegible:":"", 0, 2, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols((z==0 || z==2)?""+CmnMgr.getFormattedDecimal(cdoTotal.getColValue("gastos_no_cubiertos")):"", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols("", 2, 3, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.setFont(8, 1);
									pc.addBorderCols("DESCUENTO", 0, 1, 0.5f, 0.0f, 0.5f, 0.5f);
									pc.setFont(8, 0);
									pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_descuento")), 2, 1, 0.5f, 0.0f, 0.0f, 0.5f);
								pc.addTable();

								if(z==0 || z==2){
									pc.createTable();
										pc.addBorderCols("", 1, 6, 0.0f, 0.0f, 0.0f, 0.0f);
										pc.setFont(8, 1);
										pc.addBorderCols("MONTO PACIENTE", 0, 1, 0.5f, 0.0f, 0.5f, 0.5f);
										pc.setFont(8, 0);
										pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_paciente")), 2, 1, 0.5f, 0.0f, 0.0f, 0.5f);
									pc.addTable();
								}

								pc.createTable();
									pc.setFont(10, 1);
									pc.addBorderCols("HONORARIOS", 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.setFont(6, 0);
									pc.addBorderCols((z==0 || z==2)?"CARGO":"Cargo", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols((z==0 || z==2)?"PACIENTE DED. +%":"Descuento", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols((z==0 || z==2)?"SALDO/CIA":"Saldo", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.setFont(8, 1);
									pc.addBorderCols("TOTAL FACTURA", 0, 1, 0.5f, 0.0f, 0.5f, 0.5f);
									pc.setFont(8, 0);
									pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("monto_total")), 2, 1, 0.5f, 0.0f, 0.0f, 0.5f);
								pc.addTable();

								double tBruto = 0.00, tPacDesc = 0.00, tNeto = 0.00;
								for(int m=0;m<al2.size();m++){
									CommonDataObject cdoHon = (CommonDataObject) al2.get(m);
									pc.setFont(7, 0);
									pc.createTable();
										pc.addBorderCols(cdoHon.getColValue("cod_soc_med"), 1, 1, 0.0f, 0.0f, 0.0f, 0.0f, 12.0f);
										pc.addBorderCols(cdoHon.getColValue("descripcion"), 0, 2, 0.0f, 0.0f, 0.0f, 0.0f, 12.0f);
										pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHon.getColValue("monto_bruto")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f, 12.0f);
										pc.addBorderCols(CmnMgr.getFormattedDecimal((z==0)?cdoHon.getColValue("monto_pac"):cdoHon.getColValue("monto_desc")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f, 12.0f);
										pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoHon.getColValue("monto_neto")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f, 12.0f);
										pc.addBorderCols("", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f, 12.0f);
										pc.addBorderCols("", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f, 12.0f);
									pc.addTable();
									tBruto    += Double.parseDouble(cdoHon.getColValue("monto_bruto"));
									tPacDesc  += Double.parseDouble((z==0)?cdoHon.getColValue("monto_pac"):cdoHon.getColValue("monto_desc"));
									tNeto     += Double.parseDouble(cdoHon.getColValue("monto_neto"));
								}
								pc.setFont(8, 1);
								pc.createTable();
									pc.addBorderCols("TOTALES", 0, 3, 0.5f, 0.5f, 0.5f, 0.5f);
									pc.setFont(8, 0);
									pc.addBorderCols(CmnMgr.getFormattedDecimal(tBruto), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols(CmnMgr.getFormattedDecimal(tPacDesc), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols(CmnMgr.getFormattedDecimal(tNeto), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.setFont(8, 1);
									pc.addBorderCols("TOTAL FACTURA+HON.", 0, 1, 0.5f, 0.5f, 0.5f, 0.5f);
									pc.setFont(8, 0);
									pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("gran_total")), 2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
								pc.addTable();

								pc.createTable();
									pc.addBorderCols("", 0, 8, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.addTable();
								for(int n=0;n<12;n++){
									pc.setFont(8, 0);
									pc.createTable();
										pc.addBorderCols(" ", 2, 8, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addTable();
								}
								pc.createTable();
									pc.addBorderCols((String) session.getAttribute("_userName"), 0, 2, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols(fecha, 0, 6, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.addTable();
								pc.setFont(7, 0);
								pc.createTable();
									pc.addBorderCols("FACTURA POR COMPUTADORA AUTORIZADA SEGUN RES No. 201-1213 del 18 de mayo de 2004", 0, 8, 0.0f, 0.0f, 0.0f, 0.0f);
									pc.addBorderCols("Timbres que corresponden al presente documento son pagados por declaracion según Ley 61 del 27 de Dic. de 2002", 0, 8, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.addTable();

								break;
							}
						}// for
					}//if (al.size() > 0)

					if (j != nPages ){
					System.out.println("new page.................................");
					pc.addNewPage();
					}
				} //j

			 if(nPages>0)pc.close();
				//System.err.println(redirectFile);
				//response.sendRedirect(redirectFile);
			}
		}//get
	} // z
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow(z){
	for(i=0;i<z;i++){
		var val = '../pdfdocs/facturacion/<%=year%>/<%=month%>/FACTURA_<%=compId%>_<%=pacId%>_<%=noSecuencia%>_'+i+'_<%=year%>-<%=month%>.pdf';
		window.open(val,'ventana_'+i,popUpOptions);
	}
	window.close();
}
</script>
</head>
<body onLoad="closeWindow(<%=al3.size()%>)">
</body>
</html>
