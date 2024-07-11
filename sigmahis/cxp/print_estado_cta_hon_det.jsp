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

CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
CommonDataObject cdoH = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlSI = new StringBuffer();
String userName = UserDet.getUserName();
String beneficiario = request.getParameter("beneficiario");
String tipo = request.getParameter("tipo");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";
if(tipo == null) tipo = "";

	sbSql.append("select decode('");
	sbSql.append(tipo);
	sbSql.append("', 'E', (select nombre from tbl_adm_empresa e where to_char(e.codigo) = '");
	sbSql.append(beneficiario);
	sbSql.append("'), (select m.primer_nombre || decode(m.segundo_nombre, null, '', ' ' || m.segundo_nombre) || ' ' || m.primer_apellido || decode(m.segundo_apellido, null, '', ' ' || m.segundo_apellido) || decode(m.sexo, 'F', decode(m.apellido_de_casada, null, '', ' ' || m.apellido_de_casada)) from tbl_adm_medico m where m.codigo = '");
	sbSql.append(beneficiario);
	sbSql.append("')) nombre_beneficiario from dual");

	cdoH = SQLMgr.getData(sbSql.toString());

	
	sbSql = new StringBuffer();
	sbSql.append(" select z.tipo,z.tipo_doc,nvl(z.codigo_cs,' ') codigo_cs, sum(nvl(z.monto,0)) monto, (nvl(z.debit,0)- nvl(z.credit,0)) ajuste, nvl(z.pagos,0) pagos_distribuidos, sum(nvl(z.descuento,0)) descuentos, sum(nvl(z.monto,0)+nvl(z.debit,0)- nvl(z.pagos,0)- nvl(z.credit,0)) saldo,z.codigo,(select nombre_paciente from vw_adm_paciente where pac_id=z.pac_id)|| ' - ' || z.pac_id || ' - ' || z.admi_secuencia || ' - No. Orden '|| nvl(getBoletasHon(z.pac_id, z.admi_secuencia,nvl(z.codigo_cs,' ')),' - ')||decode((nvl(z.debit,0)- nvl(z.credit,0)),0,'',', Ajustes: ')||nvl(getAjustes(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",z.codigo,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("',nvl(z.codigo_cs,' '),'T' ),'') nombre_referencia,nvl(getAjustes(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(",z.codigo,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("',nvl(z.codigo_cs,' '),'T' ),'') codAjustes,nvl(getPagosFactHon(z.compania,z.codigo_cs,decode(z.tipo,'M','H',z.tipo),z.codigo ,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("','TD'),0) as monto_odp,nvl((select sum(nvl(h.monto_ajuste,0))-sum(nvl(h.retencion,0)) ajuste_pago from tbl_cxp_hon_det h where h.cod_medico=z.codigo_cs and h.tipo=decode(z.tipo,'M','H',z.tipo) and h.fecha >= to_date('");
  sbSql.append(fechaini);
  sbSql.append("', 'dd/mm/yyyy') and h.fecha <= to_date('");
  sbSql.append(fechafin);
  sbSql.append("', 'dd/mm/yyyy')), 0) ajuste_pago,to_char(z.fecha, 'dd/mm/yyyy') fecha_docto,z.fecha from ( select f.tipo,f.tipo_doc,getcoddetecf (f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) codigo_cs, getdescdetecf (f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,f.compania) descripcion_cs, f.monto, nvl(getDebitHon(f.compania,f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("'),0)debit,nvl(getpagosHon(f.codigo,f.medico,f.med_empresa,f.compania,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("'), 0)pagos,getcreditHon(f.compania,f.codigo,f.tipo_doc,f.centro_servicio,f.facturar_a,f.medico,f.med_empresa,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("') credit,f.descuento, f.saldo,f.codigo,f.fecha,f.pac_id,f.admi_secuencia,f.compania from ( select decode(d.med_empresa,null,'M','E')tipo,f.pac_id, f.codigo, f.fecha, f.admi_fecha_nacimiento, f.admi_codigo_paciente, f.admi_secuencia, f.cod_empresa, f.usuario_creacion, d.tipo tipo_doc, d.med_empresa, d.medico, d.centro_servicio, sum(nvl(d.monto,0)) monto, sum (nvl (d.monto, 0)) saldo, sum (nvl (d.descuento, 0) + nvl (d.descuento2, 0)) descuento, f.facturar_a, f.estatus, f.compania, f.cuenta_i from tbl_fac_factura f, tbl_fac_detalle_factura d, tbl_cds_centro_servicio cds where f.compania = ");
  sbSql.append((String) session.getAttribute("_companyId"));
  
  sbSql.append(" and (d.compania = f.compania and d.fac_codigo = f.codigo) and (d.tipo_cobertura <> 'CI' or d.tipo_cobertura is null) and (d.centro_servicio = cds.codigo(+)) and (d.med_empresa is not null or d.medico is not null) and f.fecha >= to_date('");
  sbSql.append(fechaini);
  sbSql.append("', 'dd/mm/yyyy') and f.fecha <= to_date('");
  sbSql.append(fechafin);
  sbSql.append("', 'dd/mm/yyyy') and f.estatus <> 'A' group by f.pac_id,f.codigo,f.fecha,f.admi_fecha_nacimiento,f.admi_codigo_paciente,f.admi_secuencia,f.cod_empresa,f.usuario_creacion,d.tipo, d.med_empresa,d.medico,d.centro_servicio,f.facturar_a,f.estatus,f.compania,f.cuenta_i having sum(nvl(d.monto,0)) <> 0 order by d.centro_servicio asc ) f union all select decode(a.cod_empresa,null,'M','E')tipo, a.tipo_doc,coalesce (a.cod_medico, to_char (a.cod_empresa), ' ') codigo_cs, coalesce (b.nombre_medico, c.nombre_empresa, ' ') descripcion_cs, 0 monto, a.debit,nvl(a.pagos,0) pagos,a.credit, 0 descuentos, (a.debit - nvl (a.pagos,0) - a.credit) saldo,a.codigo,a.fecha,a.pac_id,a.admi_secuencia,a.compania from (select distinct f.codigo, nvl (n.centro, 0) centro_servicio, nvl(sum (decode (n.lado_mov, 'D', n.monto)),0) debit, nvl(sum (decode (n.lado_mov, 'C', n.monto)),0) credit, n.empresa cod_empresa, n.medico cod_medico,n.tipo tipo_doc,nvl(getpagosHon(f.codigo, n.medico, n.empresa,n.compania,'");
	sbSql.append(fechaini);
	sbSql.append("','");
	sbSql.append(fechafin);
	sbSql.append("'), 0)pagos,f.fecha fecha,f.pac_id,f.admi_secuencia,n.compania from tbl_fac_factura f, vw_con_adjustment_gral n where f.compania = n.compania and f.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and f.codigo = n.factura and n.monto <> 0 and f.estatus <> 'A' and (n.centro = 0) and ((n.medico not in (select distinct nvl (b.medico, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.codigo = b.fac_codigo and a.codigo =f.codigo and a.estatus <> 'A' and nvl (b.centro_servicio, 0) = 0 and (b.medico is not null or b.med_empresa is not null))) or (n.empresa not in (select distinct nvl (b.med_empresa, 0) from tbl_fac_factura a, tbl_fac_detalle_factura b where a.compania = b.compania and a.compania =");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and a.codigo = b.fac_codigo and a.codigo =f.codigo and nvl (b.centro_servicio, 0) = 0 and a.estatus <> 'A' and (b.medico is not null or b.med_empresa is not null)))) group by f.codigo, n.centro, n.empresa, n.medico,n.tipo,n.compania,f.fecha,f.pac_id,f.admi_secuencia) a,(select codigo, primer_nombre || ' '|| segundo_nombre|| ' '|| primer_apellido|| ' '|| segundo_apellido|| ' '|| apellido_de_casada nombre_medico from tbl_adm_medico) b, (select codigo, nombre nombre_empresa from tbl_adm_empresa) c where a.cod_medico = b.codigo(+) and a.cod_empresa = c.codigo(+) and a.fecha >= to_date('");
	  sbSql.append(fechaini);
	  sbSql.append("','dd/mm/yyyy') and a.fecha <= to_date('");
	  sbSql.append(fechafin);
	  sbSql.append("','dd/mm/yyyy')) z where  z.codigo_cs ='");
	  sbSql.append(beneficiario);
	  sbSql.append("' group by z.tipo,z.tipo_doc,nvl(z.codigo_cs,' '),z.codigo_cs,z.codigo,z.pac_id,z.admi_secuencia,to_char(z.fecha, 'dd/mm/yyyy'),z.fecha,z.compania,nvl(z.debit,0)- nvl(z.credit,0), nvl(z.pagos,0) order by z.fecha,z.codigo");
	  al = SQLMgr.getDataList(sbSql.toString());

	
	cdoT = SQLMgr.getData("select nvl(sum(monto), 0) debito,nvl(sum(ajuste), 0) ajuste,0 credito, nvl(sum(pagos_distribuidos), 0) pagos_distribuidos, nvl(sum(monto_odp), 0) monto_odp,nvl(sum(ajuste_pago),0) ajuste_pago from ("+sbSql.toString()+")");

	sbSqlSI.append("select getsaldoinicialHon2(");
	sbSqlSI.append((String) session.getAttribute("_companyId"));
	sbSqlSI.append(", '");
	sbSqlSI.append(fechaini);
	sbSqlSI.append("', '");
	sbSqlSI.append(beneficiario);
	sbSqlSI.append("', '");
	sbSqlSI.append(tipo);
	sbSqlSI.append("') saldo_inicial from dual");
	cdoSI = SQLMgr.getData(sbSqlSI.toString());


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
	String title = "ESTADO DE CUENTA DETALLADO";
	String subtitle = beneficiario + " - " + cdoH.getColValue("nombre_beneficiario");
	String xtraSubtitle = "Fecha de Referencia entre " + fechaini + " - " + fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".30");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".08");
		infoCol.addElement(".08");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());
		
		//second row
		double saldo = 0.00, saldo_por_pagar = 0.00, saldo_inicial = 0.00, saldo_final = 0.00;
		if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo_inicial = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
		pc.addCols("Saldo Inicial",2,7);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial")),2,3,0.5f,0.0f,0.0f,0.0f);
	
		
		pc.addBorderCols("Descripcion",0,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Factura",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Fecha",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Facturado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Ajustado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Cobrado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Ret/ajuste",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Pagado",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Por Cobrar",1,1,0.5f,0.5f,0.0f,0.0f);
		pc.addBorderCols("Por Pagar",1,1,0.5f,0.5f,0.0f,0.0f);
		
		

	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	String groupBy = "";
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		saldo = Double.parseDouble(cdo.getColValue("monto"))+Double.parseDouble(cdo.getColValue("ajuste")) - Double.parseDouble(cdo.getColValue("pagos_distribuidos"));
		saldo_por_pagar += Double.parseDouble(cdo.getColValue("pagos_distribuidos")) - Double.parseDouble(cdo.getColValue("monto_odp"))+Double.parseDouble(cdo.getColValue("ajuste_pago"));
		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("nombre_referencia"),0,1);
		pc.addCols(cdo.getColValue("codigo"),0,1);
		pc.addCols(cdo.getColValue("fecha_docto"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("pagos_distribuidos")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste_pago")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_odp")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(saldo_por_pagar),2,1);
		//pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_final")),2,1);

		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
		saldo = Double.parseDouble(cdoT.getColValue("debito"))+Double.parseDouble(cdoT.getColValue("ajuste"))-Double.parseDouble(cdoT.getColValue("pagos_distribuidos"));
		saldo_por_pagar = Double.parseDouble(cdoT.getColValue("pagos_distribuidos"))-Double.parseDouble(cdoT.getColValue("monto_odp"))+Double.parseDouble(cdoT.getColValue("ajuste_pago"));
		saldo_final = saldo_inicial + saldo_por_pagar;
		pc.setFont(7, 0,Color.blue);
		pc.addCols("TOTAL",2,3);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("debito")),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("ajuste")),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("pagos_distribuidos")),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("ajuste_pago")),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("monto_odp")),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(saldo_final),2,1,0.0f,0.5f,0.0f,0.0f);
	
	pc.setFont(7, 0);
	pc.addBorderCols("",0,infoCol.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>