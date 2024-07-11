<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
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

ArrayList al = new ArrayList();


StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlSI = new StringBuffer();
String userName = UserDet.getUserName();
String nombre = request.getParameter("nombre");
String codigo = request.getParameter("codigo");
String tipo = request.getParameter("tipo");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
if(fecha_ini == null) fecha_ini = "";
if(fecha_fin == null) fecha_fin = "";
if(codigo == null) codigo = "";
if(nombre == null) nombre = "";
CommonDataObject cdoTot = new CommonDataObject();

  sbSql.append(" select x.tipo,x.cod_honorario,x.nombre, x.saldo_inicial, x.facturado,x.ajustado,x.cobrado,x.pagado, x.pagado_cont, x.auxiliar, x.ajuste_pago, x.facturado+x.ajustado - x.cobrado por_cobrar,x.saldo_inicial + x.cobrado-x.pagado+x.ajuste_pago por_pagar, (nvl(x.saldo_inicial,0)+nvl(x.facturado, 0)+ nvl(x.ajustado,0) -nvl(x.pagado,0)-nvl(x.pagado_cont,0)+nvl(x.ajuste_pago,0) + nvl(x.auxiliar, 0) /*+ nvl(x.ajuste_cxp, 0)*/) saldo_final , nvl(x.ajuste_cxp, 0) ajuste_cxp from(select 'M' tipo, m.codigo cod_honorario,m.primer_nombre ||decode(m.segundo_nombre,null,'', ' '||m.segundo_nombre)|| ' '||m.primer_apellido||decode(m.segundo_apellido,null,'', ' '||m.segundo_apellido)||decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada) nombre,nvl(getsaldoinicialHon2(");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(",'");
  sbSql.append(fecha_ini);
  sbSql.append("',m.codigo,'M'),0)saldo_inicial,nvl(( select sum(nvl(d.monto,0)) monto from tbl_fac_factura f, tbl_fac_detalle_factura d where f.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.med_empresa is null) and  d.medico = m.codigo and f.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <>'A' ),0)facturado,nvl(( select sum (decode (ad.lado_mov, 'D', ad.monto,'C',-1*monto)) from vw_con_adjustment_gral ad,tbl_fac_tipo_ajuste ta,tbl_fac_factura f where (ad.medico = m.codigo and ad.tipo = 'H' and ad.tipo_doc='F') and ta.group_type not in ('D','F') and ta.compania = ad.compania and ta.codigo = ad.tipo_ajuste and ad.fecha_aprob_idx >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and ad.fecha_aprob_idx <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <> 'A' and f.compania = ad.compania and f.codigo  = ad.factura and ad.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append("),0) ajustado,nvl((select sum (nvl (a.monto, 0)) cobrado from tbl_cja_distribuir_pago a, tbl_cja_detalle_pago p, tbl_cja_transaccion_pago t where a.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" /*and t.rec_status <> 'I'*/ and a.med_codigo = m.codigo and a.tipo='H' and p.cod_rem is null and p.tran_anio = t.anio and p.compania = t.compania and p.codigo_transaccion = t.codigo and a.secuencia_pago = p.secuencia_pago and a.codigo_transaccion = p.codigo_transaccion and a.tran_anio = p.tran_anio and a.compania = p.compania and a.fac_codigo = p.fac_codigo and trunc(a.fecha_creacion) >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and trunc(a.fecha_creacion) <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') ),0) cobrado, nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago=1 and op.cod_medico is not null and c.estado_cheque <> 'A' and op.estado = 'A' and op.generado='H' and c.f_emision >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and op.num_id_beneficiario = m.codigo and op.cod_medico is not null), 0) as pagado,nvl((select sum(nvl(h.monto_ajuste,0))-sum(nvl(h.retencion,0)) ajuste_pago from tbl_cxp_hon_det h where h.cod_medico=m.codigo and h.tipo in ('M','H') and h.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and h.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and h.data_refer is null /*and h.codigo_paciente = 0*/ ), 0) ajuste_pago, nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op /*,tbl_cxp_orden_de_pago_fact b*/ where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago=1 and op.cod_medico is not null and c.estado_cheque <> 'A' and op.generado='M'  and c.f_emision >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and op.num_id_beneficiario = m.codigo and op.cod_medico is not null  /*and op.cod_compania = b.cod_compania and op.anio = b.anio and op.num_orden_pago = b.num_orden_pago*/ ), 0) pagado_cont, nvl((select nvl(sum(decode(z.lado, 'CR', z.monto,'DB',-z.monto)),0) from tbl_con_registros_auxiliar z where z.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and z.fecha_doc >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and z.fecha_doc <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') ");
  sbSql.append(" and z.estado = 'A' and z.ref_id = m.codigo and (subref_type = to_number(get_sec_comp_param(z.compania, 'TIPO_CLIENTE_MEDICO'))) /*and z.reg_sistema='S' */ and z.ref_type = 2 and exists (select null from tbl_con_encab_comprob a where a.consecutivo = z.trans_id and a.ea_ano = z.trans_anio and a.compania =z.compania and a.status = 'AP' and a.estado = 'A')), 0) auxiliar, nvl((select sum(decode(cxp.cod_tipo_ajuste, 1, -1 * nvl(cxp.monto, 0), nvl(cxp.monto, 0))) from tbl_cxp_ajuste_saldo_enc cxp where cxp.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and destino_ajuste = 'H' and cxp.fecha  >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and cxp.fecha  <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and cxp.ref_id = m.codigo and cxp.estado ='R'), 0) ajuste_cxp from tbl_adm_medico m union all select 'E' tipo, to_char(e.codigo)cod_honorario,e.nombre, nvl(getsaldoinicialHon2(");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(",'");
  sbSql.append(fecha_ini);
  sbSql.append("',e.codigo,'E'),0)saldo_inicial, nvl(( select sum(nvl(d.monto,0)) monto from tbl_fac_factura f, tbl_fac_detalle_factura d where f.compania =");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.med_empresa = e.codigo) and  d.medico is null and f.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <>'A' ),0)facturado,nvl(( select sum (decode (ad.lado_mov, 'D', ad.monto,'C',-1*monto)) from vw_con_adjustment_gral ad,tbl_fac_tipo_ajuste ta,tbl_fac_factura f where (ad.empresa = e.codigo and ad.tipo = 'E' and ad.tipo_doc='F') and ta.group_type not in ('D','F') and ta.compania = ad.compania and ta.codigo = ad.tipo_ajuste and ad.fecha_aprob_idx >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy')and ad.fecha_aprob_idx <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <> 'A' and f.compania = ad.compania and f.codigo = ad.factura and ad.compania =");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append("),0)ajustado,nvl((select sum (nvl (a.monto, 0)) cobrado from tbl_cja_distribuir_pago a, tbl_cja_detalle_pago p, tbl_cja_transaccion_pago t where a.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" /*and t.rec_status <> 'I'*/ and a.empre_codigo = to_char(e.codigo) and p.cod_rem is null and a.tipo='E' and p.tran_anio = t.anio and p.compania = t.compania and p.codigo_transaccion = t.codigo and a.secuencia_pago = p.secuencia_pago and a.codigo_transaccion = p.codigo_transaccion and a.tran_anio = p.tran_anio and a.compania = p.compania and a.fac_codigo = p.fac_codigo and trunc(a.fecha_creacion) >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and trunc(a.fecha_creacion) <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy')),0) cobrado,nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago=1 and op.cod_empresa is not null and c.estado_cheque <> 'A' and op.generado='H' and c.f_emision >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("','dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("','dd/mm/yyyy') and op.num_id_beneficiario = to_char(e.codigo)), 0) as pagado, nvl((select sum(nvl(h.monto_ajuste,0))-sum(nvl(h.retencion,0)) ajuste_pago from tbl_cxp_hon_det h where  h.cod_medico=to_char(e.codigo) and h.tipo='E' and h.fecha >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and h.fecha <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and h.data_refer is null /*and h.codigo_paciente = 0*/), 0) ajuste_pago, nvl(( select sum(c.monto_girado) pagado from tbl_con_cheque c,tbl_cxp_orden_de_pago op /*,tbl_cxp_orden_de_pago_fact b*/ where op.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));  
  sbSql.append(" and op.anio = c.anio and op.num_orden_pago = c.num_orden_pago and op.cod_compania = c.cod_compania_odp and op.cod_tipo_orden_pago=3 and op.tipo_orden = 'E' and op.cod_empresa is not null and c.estado_cheque <> 'A' and op.generado='M' and c.f_emision >= to_date('");
  sbSql.append(fecha_ini);
  sbSql.append("','dd/mm/yyyy') and c.f_emision <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("','dd/mm/yyyy') and op.num_id_beneficiario = to_char(e.codigo)  /*and op.cod_compania = b.cod_compania and op.anio = b.anio and op.num_orden_pago = b.num_orden_pago*/), 0) pagado_cont, nvl((select nvl(sum(decode(z.lado, 'CR', z.monto,'DB',-z.monto)),0) from tbl_con_registros_auxiliar z where z.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));
  sbSql.append(" and z.fecha_doc >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and z.fecha_doc <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') ");  
  sbSql.append(" and z.estado = 'A' and z.ref_id = to_char(e.codigo) and (subref_type = to_number(get_sec_comp_param(z.compania, 'TIPO_CLIENTE_SOC_MED'))) /*and z.reg_sistema='S' */ and z.ref_type = 2 and exists (select null from tbl_con_encab_comprob a where a.consecutivo = z.trans_id and a.ea_ano = z.trans_anio and a.compania =z.compania and a.status = 'AP' and a.estado = 'A')), 0) auxiliar, nvl((select sum(decode(cxp.cod_tipo_ajuste, 1, -1 * nvl(cxp.monto, 0), nvl(cxp.monto, 0))) from tbl_cxp_ajuste_saldo_enc cxp where cxp.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));
  sbSql.append(" and destino_ajuste = 'E' and cxp.fecha  >= to_date('"); 
  sbSql.append(fecha_ini);
  sbSql.append("', 'dd/mm/yyyy') and cxp.fecha  <= to_date('");
  sbSql.append(fecha_fin);
  sbSql.append("', 'dd/mm/yyyy') and cxp.ref_id = to_char(e.codigo) and cxp.estado ='R'), 0) ajuste_cxp from tbl_adm_empresa e  where e.tipo_empresa=1 ) x where (nvl(x.facturado,0)+nvl(x.ajustado,0)<> 0 or nvl(x.cobrado,0) > 0 or nvl(x.pagado,0) >0 OR NVL (x.pagado_cont, 0) > 0 /*or nvl(x.ajuste_cxp,0) >0*/ or nvl(x.saldo_inicial,0) <>0)"); 
 if(!tipo.trim().equals("")){
		sbSql.append(" and x.tipo='");
		sbSql.append(tipo);
		sbSql.append("' ");
	}

 if(!codigo.trim().equals("")){
		sbSql.append(" and x.cod_honorario like '%");
		sbSql.append(codigo);
		sbSql.append("%'");
	}
	if(!nombre.trim().equals("")){
		sbSql.append(" and x.nombre like '%");
		sbSql.append(nombre);
		sbSql.append("%'");
	}
	sbSql.append(" order by 3");
		al = SQLMgr.getDataList(sbSql.toString());
		
		
		
		
		//cdoTot = SQLMgr.getData("select  nvl(sum(saldo_inicial), 0) saldo_inicial,nvl(sum(facturado),0)debito,nvl(sum(ajustado),0) ajuste,nvl(sum(cobrado), 0)+nvl(sum(ajuste_pago), 0) pago_distribuido, nvl(sum(pagado), 0) monto_odp,  nvl(sum(por_cobrar), 0) por_cobrar,  nvl(sum(por_pagar), 0) por_pagar,nvl(sum(saldo_final), 0) saldo_final,nvl(sum(ajuste_pago),0)ajuste_pago from ("+sbSql.toString()+")");
   


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ESTADO DE CUENTA - HONORARIOS MEDICOS RESUMIDO";
	String subtitle = "";
	String xtraSubtitle = "Fecha de Referencia entre " + fecha_ini + " - " + fecha_fin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".05");
		infoCol.addElement(".26");
		infoCol.addElement(".06");
		infoCol.addElement(".06");
		infoCol.addElement(".06");
		infoCol.addElement(".06");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		//infoCol.addElement(".06");
		infoCol.addElement(".07");
		infoCol.addElement(".07");
		infoCol.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

		//second row
		pc.setVAlignment(0);
		pc.addBorderCols("Codigo",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Nombre",0,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Saldo Inicial",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Facturado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Ajustado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Cobrado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Ret/Ajuste",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Pagado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Pagado Cont",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Auxiliar",1,1,0.5f,0.5f,0.0f,0.0f);
		//pc.addBorderCols("Ajuste CxP",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Por Cobrar",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Por Pagar",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Saldo Final",1,1,0.5f,0.5f,0.0f,0.0f);

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	

	//table body
	String groupBy = "";
	
	pc.setVAlignment(0);

	
	double saldo = 0.00, saldo_por_pagar = 0.00, saldo_inicial = 0.00, saldo_final = 0.00;
	double totSi=0.00,totFact=0.00,totAj=0.00,totCobrado=0.00,totAjs=0.00,totPagado=0.00,totPagadoCon=0.00,totAux=0.00,totCxc = 0.00,totCxp=0.00,totSf = 0.00,ajuste_cxp = 0.00;
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setFont(6, 0);
		pc.addCols(cdo.getColValue("cod_honorario"),1,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("facturado")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajustado")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("cobrado")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_pago")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagado")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagado_cont")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("auxiliar")),2,1);
		//pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_cxp")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("por_cobrar")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("por_pagar")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_final")),2,1);
		
		
		totSi += Double.parseDouble(cdo.getColValue("saldo_inicial"));
		totFact += Double.parseDouble(cdo.getColValue("facturado"));
		totAj += Double.parseDouble(cdo.getColValue("ajustado"));
		totCobrado += Double.parseDouble(cdo.getColValue("cobrado"));
		totAjs += Double.parseDouble(cdo.getColValue("ajuste_pago"));
		totPagado += Double.parseDouble(cdo.getColValue("pagado"));
		totPagadoCon += Double.parseDouble(cdo.getColValue("pagado_cont"));
		totAux += Double.parseDouble(cdo.getColValue("auxiliar"));
		totCxc += Double.parseDouble(cdo.getColValue("por_cobrar"));
		totCxp += Double.parseDouble(cdo.getColValue("por_pagar"));
		totSf += Double.parseDouble(cdo.getColValue("saldo_final"));
		ajuste_cxp += Double.parseDouble(cdo.getColValue("ajuste_cxp"));

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	
	    pc.addCols("TOTAL",2,2);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totSi),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totFact),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totAj),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totCobrado),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totAjs),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totPagado),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totPagadoCon),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totAux),2,1,0.0f,0.5f,0.0f,0.0f);
		//pc.addBorderCols(CmnMgr.getFormattedDecimal(ajuste_cxp),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totCxc),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totCxp),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totSf),2,1,0.0f,0.5f,0.0f,0.0f);
	
	pc.setFont(7, 0);
	pc.addBorderCols("",0,infoCol.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>