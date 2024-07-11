<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>

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
ArrayList al2 = new ArrayList();
StringBuffer sbSql = new StringBuffer();

String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noSecuencia = request.getParameter("noSecuencia");
String factId = request.getParameter("factId");
String compId = (String) session.getAttribute("_companyId");
String query = "";
String facturarA = request.getParameter("facturarA");
String refId = request.getParameter("refId");
String referTo = request.getParameter("referTo");
String refType = request.getParameter("refType");
if(refId==null)refId="";
if(referTo==null)referTo="";
if(facturarA==null)facturarA="";
if(refType==null)refType="";

//if(!facturarA.trim().equals("O")){
sbSql = new StringBuffer();

	sbSql.append("select a.codigo as numero_factura,decode(a.estatus,'A','ANULADA','P','ACTIVA','C','CANCELADA') as estado_factura, p.nombre_paciente /*decode(a.facturar_a,'P',p.nombre_paciente, getNombreCliente(a.compania,a.cliente_otros,a.cod_otro_cliente)) as nombre_paciente*/ ,to_char(coalesce(p.f_nac,p.fecha_nacimiento),'dd/mm/yyyy') f_nac, a.admi_secuencia, a.admi_codigo_paciente as codigo_paciente, p.residencia_direccion,'casa: '||p.telefono||'/trab. '||p.telefono_trabajo_urgencia telefonos,a.cod_empresa, (select nombre from tbl_adm_empresa where codigo = a.cod_empresa and rownum = 1) as nombre_aseguradora,decode(a.facturar_a,'P','PACIENTE','E','ASEGURADORA','OTROS') as facturar_a,getResponsable(a.pac_id,a.admi_secuencia) as responsable, getCategoria(a.admi_secuencia,a.pac_id) as categoria , (select decode(conta_cred,'R','(CRED)','C','(CONT)') from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia and rownum = 1) as adm_desc_estatus,  (select to_char(fecha_ingreso,'dd/mon/yyyy') from tbl_adm_admision where pac_id = a.pac_id and secuencia = a.admi_secuencia and rownum = 1) as fecha_ingreso,a.pac_id,a.facturar_a fact_a,nvl(get_adm_doblecobertura_msg(a.pac_id,a.admi_secuencia),' ') as doble_msg,decode(a.facturar_a,'P',a.pac_id,a.cod_otro_cliente) as id,nvl((select to_char(fecha_envio,'dd/mm/yyyy') from tbl_fac_lista_envio z where enviado = 'S' and estado = 'A' and rownum = 1 and exists (select null from tbl_fac_lista_envio_det where compania = a.compania and factura = a.codigo and id = z.id and estado = 'A')),' ') fechaEnvio,a.estatus ,(select refer_to from tbl_fac_tipo_cliente tc where tc.codigo=a.cliente_otros and tc.compania=a.compania ) as referTo from tbl_fac_factura a,vw_adm_paciente p where a.pac_id = p.pac_id(+) and a.compania =");
	sbSql.append(compId);
	sbSql.append(" and a.codigo = '");
	sbSql.append(factId);
	sbSql.append("'");

CommonDataObject cdoHeader = SQLMgr.getData(sbSql.toString());
/*}
else
{*/
if(facturarA.trim().equals("O")|| cdoHeader.getColValue("fact_a").trim().equals("O") ){
referTo=cdoHeader.getColValue("referTo");

	CommonDataObject cdoQry = new CommonDataObject();
cdoQry = SQLMgr.getData("select query  from tbl_gen_query where id = 0 and refer_to = '"+referTo+"'");
System.out.println("query......=\n"+cdoQry.getColValue("query"));

sbSql = new StringBuffer();
sbSql.append("select a.compania, a.codigo, a.refer_to, a.nombre, to_char(a.fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, a.ruc, a.dv, decode(a.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = a.codigo), a.codigo) num_empleado ");
if(referTo.trim().equals("PAC"))sbSql.append(",direccion,telefono,responsable ");
sbSql.append(" from (");
	sbSql.append(cdoQry.getColValue("query").replace("@@compania", (String) session.getAttribute("_companyId")));
sbSql.append(") a where nvl(compania,1) = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.codigo = '");
sbSql.append(cdoHeader.getColValue("id"));
sbSql.append("' order by nombre ");
CommonDataObject cdoHeader2 = SQLMgr.getData(sbSql.toString());
	if(cdoHeader2 !=null)
	{
		cdoHeader.addColValue("nombre_paciente",cdoHeader2.getColValue("nombre"));
		cdoHeader.addColValue("id",cdoHeader2.getColValue("codigo"));
	}
}

if (cdoHeader == null) cdoHeader = new CommonDataObject();


sbSql = new StringBuffer();

sbSql.append("select nvl(z.codigo_cs, ' ') codigo_cs, nvl(z.descripcion_cs, ' ') descripcion_cs, nvl(z.monto,0) monto, nvl(z.debit,0) debit, nvl(z.pagos,0) pagos, nvl(z.credit,0) credit, nvl(z.descuento,0) descuentos, nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.pagos,0)- nvl(z.credit,0)-nvl(z.descuento,0) saldo from ( select getcoddetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) codigo_cs, getdescdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) descripcion_cs, f.monto,  getdebitdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) debit,  getpagosdetecf (f.pac_id,f.compania,f.admi_secuencia,f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.cod_empresa) pagos, getcreditdetecf (f.codigo,f.tipo,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) credit, f.descuento, f.saldo from ( select f.pac_id, f.codigo, f.fecha, f.admi_fecha_nacimiento, f.admi_codigo_paciente, f.admi_secuencia, f.cod_empresa, f.usuario_creacion,decode(d.tipo,'O','C',d.tipo)as tipo, d.med_empresa, d.medico, d.centro_servicio, sum(nvl(d.monto, 0) + nvl(d.descuento, 0)+ nvl (d.descuento2, 0) /* -- se comenta por que en consulta general y factura este monto sale diferente . Se agrego filtro por fecha para tomar los que son mayores a junio*/ /* - nvl((select sum(nvl(df.monto,0)) from tbl_fac_factura ff, tbl_fac_detalle_factura df where ff.codigo = df.fac_codigo and ff.compania = df.compania and ff.pac_id = f.pac_id and ff.admi_secuencia = f.admi_secuencia and ff.facturar_a = 'P' and ff.estatus = 'P' and f.codigo != ff.codigo and substr(df.descripcion, 10, length(df.descripcion)-9) = cds.descripcion and df.tipo_cobertura = 'CO' and trunc(ff.fecha) >= to_date('01/10/2011','dd/mm/yyyy')), 0) */ -decode(nvl(d.monto,0) + nvl(d.descuento,0) + nvl(d.descuento2,0),0,0,decode(f.nueva_formula,'S',0,decode(f.tipo_cobertura,'S',0,nvl(getCopagoDet(f.compania,f.codigo,nvl(to_char(d.med_empresa),d.medico),cds.descripcion,f.pac_id,f.admi_secuencia,null ),0))))) monto, sum (nvl (d.monto, 0)) saldo, sum (nvl (d.descuento, 0) + nvl (d.descuento2, 0)) descuento, f.facturar_a, f.estatus, f.compania, f.cuenta_i from tbl_fac_factura f, tbl_fac_detalle_factura d, tbl_cds_centro_servicio cds where f.codigo = '");
sbSql.append(factId);
sbSql.append("' and f.compania = ");
sbSql.append(compId);
sbSql.append(" and d.imprimir_sino='S' and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.centro_servicio = cds.codigo(+)) group by f.pac_id,f.codigo,f.fecha,f.admi_fecha_nacimiento,f.admi_codigo_paciente,f.admi_secuencia,f.cod_empresa,f.usuario_creacion,d.tipo, d.med_empresa,d.medico,d.centro_servicio,f.facturar_a,f.estatus,f.compania,f.cuenta_i order by d.centro_servicio asc ) f  ");

sbSql.append(" union all ");


 sbSql.append(" select to_char(a.centro) codigo_cs,decode(a.tipo,'C',(select descripcion from tbl_cds_centro_servicio where codigo=a.centro),'P','COPAGO','M','PERDIEM') descripcion_cs,0 monto, a.debit, nvl (a.pagos, 0) pagos, a.credit, 0 descuento, (a.debit - nvl (a.pagos, 0) - a.credit) saldo from (select   f.codigo, n.centro, nvl(sum (nvl (decode (n.lado_mov, 'D', n.monto), 0)),0) debit, nvl(sum (nvl (decode (n.lado_mov, 'C', n.monto), 0)),0) credit,n.tipo ,getPagosCNF(f.codigo,n.centro,f.compania,n.tipo) pagos    from tbl_fac_factura f, vw_con_adjustment_gral n where  f.compania = n.compania and f.compania =");
sbSql.append(compId);
sbSql.append(" and f.codigo = n.factura and f.codigo = '");
sbSql.append(factId);
sbSql.append("'  and n.monto <> 0 ");
if(!facturarA.trim().equals("O"))sbSql.append(" and nvl(n.centro,-1) <> 0");

sbSql.append(" and nvl(n.centro,-1) not in (select distinct nvl (b.centro_servicio,-1) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania = ");
sbSql.append(compId);
sbSql.append(" and a.codigo = b.fac_codigo and a.codigo ='");
sbSql.append(factId);
sbSql.append("' and b.imprimir_sino='S' ");
if(!facturarA.trim().equals("O"))sbSql.append(" and nvl(b.centro_servicio,-1) <> 0");

sbSql.append(" )");

sbSql.append(" group by f.codigo, n.centro,n.tipo,f.compania ");
if(facturarA.trim().equals("O")){
sbSql.append(" union all select t.other3 factura, ft.centro_servicio,sum(decode (ft.doc_type, 'NDB', ft.net_amount,0)) ajuste_debito, sum(decode(ft.doc_type, 'NCR',ft.net_amount,0)) ajuste_credito,'C' as tipo,0 pagos from tbl_fac_trx ft,tbl_fac_trx t where  ft.doc_type in ('NDB', 'NCR') and ft.status = 'O' and ft.reference_id = t.doc_id and ft.company_id = ");
sbSql.append(compId);
sbSql.append(" and t.other3 ='");
sbSql.append(factId);
sbSql.append("' and t.doc_type = 'FAC' and nvl(ft.centro_servicio,-1) not in (select distinct nvl (b.centro_servicio,-1)from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania = ");
sbSql.append(compId);
sbSql.append(" and a.codigo = b.fac_codigo and a.codigo ='");
sbSql.append(factId);
sbSql.append("' and b.imprimir_sino='S') group by t.other3,ft.centro_servicio,ft.doc_type");
}
sbSql.append(" ) a ");


if(!facturarA.trim().equals("O")){
sbSql.append(" union all ");

sbSql.append(" select coalesce ((select nvl(reg_medico,codigo) from tbl_adm_medico where codigo=a.cod_medico), to_char (a.cod_empresa), ' ') codigo_cs, coalesce (b.nombre_medico, c.nombre_empresa, ' ') descripcion_cs, 0 monto, a.debit, nvl (getpagospdetecf (a.codigo, a.cod_medico, a.cod_empresa,");
	sbSql.append(compId);
	sbSql.append("), 0) pagos, a.credit, 0 descuentos, (a.debit - nvl (getpagospdetecf (a.codigo, a.cod_medico, a.cod_empresa,");
	sbSql.append(compId);
	sbSql.append("), 0) - a.credit) saldo from (select distinct f.codigo, nvl (n.centro, 0) centro_servicio, nvl(sum (decode (n.lado_mov, 'D', n.monto)),0) debit, nvl(sum (decode (n.lado_mov, 'C', n.monto)),0) credit, n.empresa cod_empresa, n.medico cod_medico from tbl_fac_factura f, vw_con_adjustment_gral n where f.compania = n.compania and f.compania = ");
sbSql.append(compId);
sbSql.append(" and f.codigo = n.factura and f.codigo = '");
sbSql.append(factId);
sbSql.append("' and n.monto <> 0 and (n.centro = 0) and ((n.medico not in (select distinct nvl (b.medico, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
sbSql.append(compId);
sbSql.append(" and a.codigo = b.fac_codigo and a.codigo = '");
sbSql.append(factId);


sbSql.append("' and nvl (b.centro_servicio, 0) = 0 and (b.medico is not null or b.med_empresa is not null))) or (n.empresa not in (select distinct nvl (b.med_empresa, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
sbSql.append(compId);
sbSql.append(" and a.codigo = b.fac_codigo and a.codigo = '");
sbSql.append(factId);
sbSql.append("' and nvl (b.centro_servicio, 0) = 0 and (b.medico is not null or b.med_empresa is not null)))) group by f.codigo, n.centro, n.empresa, n.medico) a,    (select codigo, primer_nombre || ' '|| segundo_nombre|| ' '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada nombre_medico from tbl_adm_medico) b, (select codigo, nombre nombre_empresa from tbl_adm_empresa) c where a.cod_medico = b.codigo(+) and a.cod_empresa = c.codigo(+) ");
}
sbSql.append(" ) z order by lpad(z.codigo_cs,5,'0') ");
al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select nvl(getpagopac (a.codigo,a.pac_id,a.admi_secuencia,a.facturar_a,a.compania), 0) pagos_paciente, decode(a.facturar_a,'O',0,nvl(getpagoempresa(a.compania, a.codigo), 0)) pagos_empresa, decode(a.facturar_a,'O',0,nvl(getnodistribuido(a.compania, a.codigo,a.pac_id,a.admi_secuencia,a.facturar_a), 0)) pago_no_distribuido from (select distinct f.compania, f.codigo, f.pac_id, f.admi_secuencia, f.facturar_a from tbl_fac_factura f, tbl_fac_detalle_factura d where f.compania = ");
sbSql.append(compId);
sbSql.append(" and f.codigo = '");
sbSql.append(factId);
sbSql.append("' and f.compania = d.compania and f.codigo = d.fac_codigo and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null)) a ");

	CommonDataObject cdoTotal = SQLMgr.getData(sbSql.toString());


	sbSql = new StringBuffer();

	sbSql.append("select to_char(fecha_pago,'dd/mm/yyyy') fecha_pago, recibo, cod_fac, nvl(pago_x_adm,0)pago_x_adm, nvl(pago_total,0) pago_total, secuencia_pago, monto_distribuido from vw_cja_consulta_pagos where cod_fac(+) = '");
	sbSql.append(factId);
	sbSql.append("' and compania = ");
  sbSql.append(compId);
  sbSql.append("group by fecha_pago, recibo, secuencia_pago, cod_fac, nvl(pago_total,0), nvl(pago_x_adm,0), monto_distribuido ");
  if(!facturarA.trim().equals("O")){
  sbSql.append(" union select to_char(fecha_pago,'dd/mm/yyyy') fecha_pago, recibo, cod_fac, nvl(pago_x_adm,0)pago_x_adm, nvl(pago_total,0)pago_total, secuencia_pago, monto_distribuido from vw_cja_consulta_pagos_e where cod_fac = '");
	sbSql.append(factId);
	sbSql.append("' and compania = ");
	sbSql.append(compId);
	sbSql.append(" group by fecha_pago, recibo, secuencia_pago, cod_fac, nvl(pago_total,0), nvl(pago_x_adm,0), monto_distribuido");
}
		al2 = SQLMgr.getDataList(sbSql.toString());

		//query = "select nvl(sum(pago_total),0) pago_total, nvl(sum(pago_x_adm),0) pago_x_adm from ("+sbSql.toString()+")";

		//CommonDataObject cdoTotalR = SQLMgr.getData(query);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ESTADO DE CUENTA DETALLADO POR FACTURA";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);



	Vector dHeader=new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(headerFontSize,1);

				pc.addCols("Factura:", 0, 1);
				pc.addCols(cdoHeader.getColValue("numero_factura"), 0,3);
				pc.addCols("Estatus de la Factura:", 0,1);
				pc.addCols(cdoHeader.getColValue("estado_factura"), 0, 3);

				if(cdoHeader.getColValue("fact_a") != null && !cdoHeader.getColValue("fact_a").trim().equals("O")){
				pc.addCols("Paciente:", 0, 1);
				pc.addCols(cdoHeader.getColValue("nombre_paciente"), 0,3);
				pc.addCols("No. Admon:", 0,1);
				pc.addCols(cdoHeader.getColValue("admi_secuencia"), 0, 3);

				pc.addCols("Fecha Nac.:", 0, 1);
				pc.addCols(cdoHeader.getColValue("f_nac")+" "+" "+" "+"Paciente: "+cdoHeader.getColValue("pac_id"), 0,3);
				pc.addCols("Fecha Ingreso:", 0, 1);
				pc.addCols(cdoHeader.getColValue("fecha_ingreso"), 0, 3);

				pc.addCols("Dirección:", 0, 1);
				pc.addCols(cdoHeader.getColValue("residencia_direccion"), 0, 3);
				pc.addCols("Telefonos:", 0, 1);
				pc.addCols(cdoHeader.getColValue("telefonos"), 0, 3);

				pc.addCols("Empresa:", 0, 1);
				pc.addCols(cdoHeader.getColValue("cod_empresa") + "  " + cdoHeader.getColValue("nombre_aseguradora"), 0,3);
				pc.addCols("Factura Generada A:", 0,1);
				pc.addCols(cdoHeader.getColValue("facturar_a"), 0,3);

				pc.addCols("Responsable:", 0, 1);
				pc.addCols(cdoHeader.getColValue("responsable"), 0,3);
				pc.addCols("Télefono:", 0,1);
				pc.addCols(cdoHeader.getColValue(""), 0,3);

				pc.addCols("Categoría:", 0, 1);
				pc.addCols(cdoHeader.getColValue("categoria"), 0,3);
				pc.addCols("Fecha Envio:", 0, 1);
				pc.addCols(cdoHeader.getColValue("fechaEnvio"), 0,3);

				pc.setFont(headerFontSize,1,Color.blue);
				pc.addCols(cdoHeader.getColValue("doble_msg"),1,dHeader.size());

				}else
				{
					pc.addCols("Cliente:", 0, 1);
					pc.addCols(cdoHeader.getColValue("nombre_paciente"), 0,3);
					pc.addCols("ID:", 0,1);
					pc.addCols(cdoHeader.getColValue("id"), 0, 3);

				}
				pc.setFont(headerFontSize,1);
				pc.addBorderCols("Descripción del Cargo", 1, 2);
				pc.addBorderCols("Monto", 1, 1);
				pc.addBorderCols("Débitos", 1, 1);
				pc.addBorderCols("Mto Dist. en Sist.", 1, 1);
				pc.addBorderCols("Créditos", 1, 1);
				pc.addBorderCols("Desc.", 1, 1);
				pc.addBorderCols("Saldo De Dist.", 1, 1);

	//pc.setTableHeader(2);//create de table header

	//table body
	double pago_x_adm = 0.00;
	double pago_total = 0.00;

	double monto = 0.00;
	double debit = 0.00;
	double pagos = 0.00;
	double credit = 0.00;
	double descuentos = 0.00;
	double saldo = 0.00;
	boolean delPacDet = true;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(contentFontSize,0);
		//pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cargo")),2,1);
		if (i == 0)if(cdoHeader.getColValue("fact_a") != null && !cdoHeader.getColValue("fact_a").trim().equals("O")) pc.setTableHeader(5);
		else pc.setTableHeader(4);

		pc.addCols(cdo.getColValue("codigo_cs"), 2, 1);
		pc.addCols(cdo.getColValue("descripcion_cs"), 0, 1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")), 2, 1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("debit")), 2, 1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagos")), 2, 1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("credit")), 2, 1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("descuentos")), 2, 1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2, 1);

		monto += Double.parseDouble(cdo.getColValue("monto"));
		debit += Double.parseDouble(cdo.getColValue("debit"));
		pagos += Double.parseDouble(cdo.getColValue("pagos"));
		descuentos += Double.parseDouble(cdo.getColValue("descuentos"));
		credit += Double.parseDouble(cdo.getColValue("credit"));
		saldo += Double.parseDouble(cdo.getColValue("saldo"));

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.addCols("", 0, dHeader.size());

		pc.addBorderCols("TOTALES", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(monto), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(debit), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(pagos), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(credit), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(descuentos), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
	}

	pc.addCols("", 0, dHeader.size());







		pc.addBorderCols("TOTAL APLICADO POR SISTEMA A FACTURA PACIENTE/CLIENTE:", 2, 3, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("pagos_paciente")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("PENDIENTE POR DISTRIBUIR:", 2, 3, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("pago_no_distribuido")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

		pc.addBorderCols("TOTAL APLICADO POR SISTEMA A FACTURA EMPRESA:", 2, 3, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoTotal.getColValue("pagos_empresa")), 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("", 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);

	pc.addCols(" ", 0, dHeader.size());
	pc.addCols(" ", 0, dHeader.size());


		pc.addBorderCols("Fecha del Recibo", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols("No. de Rec. que pagó esta fáctura", 1, 1, 0.5f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols("Gran Total Pagado por Recibo", 2, 2, 0.5f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols("Mto. Distrib. a ésta Factura/Admisión", 2, 3, 0.5f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols("", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);

	for(int l=0;l<al2.size();l++)
	{
		  CommonDataObject cdoR = (CommonDataObject) al2.get(l);

			pc.addBorderCols(cdoR.getColValue("fecha_pago"), 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(cdoR.getColValue("recibo"), 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoR.getColValue("pago_x_adm")), 2, 2, 0.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoR.getColValue("monto_distribuido")), 2, 3, 0.0f, 0.0f, 0.0f, 0.0f);
			pc.addBorderCols("", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);

			pago_x_adm  += Double.parseDouble(cdoR.getColValue("monto_distribuido"));
			pago_total  += Double.parseDouble(cdoR.getColValue("pago_x_adm"));

	}

		pc.addBorderCols("TOTALES", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("--------------->", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(pago_total), 2, 2, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(pago_x_adm), 2, 3, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols("", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);

		pc.addCols(" ", 0, dHeader.size());
		pc.setFont(contentFontSize,1,Color.red);
		pc.addBorderCols("SALDO ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		pc.addBorderCols("--------------->", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);
		if(!cdoHeader.getColValue("estatus").trim().equals("A") ){
		if(cdoHeader.getColValue("fact_a")!=null&&cdoHeader.getColValue("fact_a").trim().equals("E"))
		pc.addBorderCols(CmnMgr.getFormattedDecimal(monto+(debit-credit)-descuentos-Double.parseDouble(cdoTotal.getColValue("pagos_empresa"))), 2, 2, 0.0f, 0.5f, 0.0f, 0.0f);
		else pc.addBorderCols(CmnMgr.getFormattedDecimal(monto+(debit-credit)-descuentos-Double.parseDouble(cdoTotal.getColValue("pagos_paciente"))), 2, 2, 0.0f, 0.5f, 0.0f, 0.0f);
		}	else  pc.addBorderCols("0.00", 2, 2, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols("", 2, 3, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addBorderCols("", 1, 1, 0.0f, 0.0f, 0.0f, 0.0f);








	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>