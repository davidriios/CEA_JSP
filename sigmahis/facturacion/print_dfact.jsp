<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
<%
/*
=========================================================================
=========================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alFac = new ArrayList();
ArrayList alDet = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
//all account invoice
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
//given invoice
String factura = request.getParameter("factura");
String compania = request.getParameter("compania");

String fp = request.getParameter("fp");
String empresa = "";

if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (factura == null) factura = "";
if (compania == null) compania = "";

if (fp == null) fp = "";

float pHeight = 5.5f;
CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'FAC_PROFORMA_PAPER_HSIZE'),'5.5') as proforma_height from dual");
if (p != null && p.getColValue("proforma_height") != null && !p.getColValue("proforma_height").equals("-")) pHeight = Float.parseFloat(p.getColValue("proforma_height"));

sbSql = new StringBuffer();
sbSql.append("select a.codigo, a.compania, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.pac_id, a.admi_secuencia, a.cod_empresa, a.facturar_a, a.lista, (select nombre_paciente2 from vw_adm_paciente where pac_id = a.pac_id) as nombre_paciente, (select edad from vw_adm_paciente where pac_id = a.pac_id) as edad, (select to_char(f_nac,'dd/mm/yyyy') as fecha_nac from vw_adm_paciente where pac_id = a.pac_id) as fecha_nac, (select id_paciente from vw_adm_paciente where pac_id = a.pac_id) as identificacion, (select nombre from tbl_adm_empresa where codigo = a.cod_empresa) as nombre_aseguradora, (select (select primer_nombre||' '||segundo_nombre||' '||decode(apellido_de_casada,null,primer_apellido||' '||segundo_apellido,apellido_de_casada) from tbl_adm_medico where codigo = z.medico) from tbl_adm_admision z where pac_id = a.pac_id and secuencia = a.admi_secuencia) as nombre_medico, (select (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) from tbl_adm_admision z where pac_id = a.pac_id and secuencia = a.admi_secuencia) as categoria, (select poliza from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admi_secuencia and prioridad = 1 and estado = 'A') as poliza, (select certificado from tbl_adm_beneficios_x_admision where pac_id = a.pac_id and admision = a.admi_secuencia and prioridad = 1 and estado = 'A') as certificado, a.estatus, nvl(a.total_honorarios,0) as total_honorarios, nvl(decode(a.facturar_a,'P',get_adm_doblecobertura_msg(a.pac_id,a.admi_secuencia)),' ') as doble_msg, nvl((select nombre from tbl_adm_responsable where pac_id = a.pac_id and admision = a.admi_secuencia and estado = 'A'),' ') as responsable, get_sec_comp_param(a.compania,'CDS_PAQ_PER') as cds_paq_per, nvl(a.num_aprobacion_axa,' ') num_aprobacion_axa from tbl_fac_factura a where ");
if (!pacId.trim().equals("") && !admision.trim().equals("")) {

	sbSql.append("a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admi_secuencia = ");
	sbSql.append(admision);
	sbSql.append(" and estatus != 'A'");

} else if (!factura.trim().equals("") && !compania.trim().equals("")) {

	sbSql.append("a.codigo = '");
	sbSql.append(factura);
	sbSql.append("' and a.compania = ");
	sbSql.append(compania);

} else throw new Exception("La Admisión o la Factura no es válida. Por favor intente nuevamente!");

alFac = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {

	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String servletPath = request.getServletPath();

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
	String statusPath = ResourceBundle.getBundle("path").getString("images")+"/anulado.png";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	float width = 72 * 8.5f;//612
	float height = 72 * pHeight;//792
	boolean isLandscape = false;
	float leftRightMargin = 20.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int headerFontSize = 8;
	int contentFontSize = 8;
	int footerFontSize = 7;
	boolean preprinted = request.getParameter("preprinted") != null;
	float border = preprinted?0.0f:0.5f;
	float trHeight = 0f;//total's row height
	if (preprinted) {
		leftRightMargin = 0.0f;
		topMargin = 24.0f;
		bottomMargin = 36.0f;
		trHeight = 14.0f;
	}

	float headerHeight = 0.0f;//encabezado pdf
	float detailHeight = 0.0f;//segmento detalles
	float totalHeight = 0.0f;//segmento totales
	float availHeight = 0.0f;//disponible acumulado
	float tmpHeight = 0.0f;//detalle

	Vector vHeader = new Vector();
		vHeader.addElement("72");
		vHeader.addElement("225");
		vHeader.addElement("43");
		vHeader.addElement("120");
		vHeader.addElement("36");
		vHeader.addElement("80");
	Vector vDetail = new Vector();
		vDetail.addElement("18");
		vDetail.addElement("63");
		vDetail.addElement("297");
		vDetail.addElement("45");
		vDetail.addElement("81");
		vDetail.addElement("81");
		vDetail.addElement("27");

	String codFactPac = "";
	double hon_paciente = 0.00;
	double totalFactura = 0.00;
	for (int i=0; i<alFac.size(); i++) {

		CommonDataObject fac = (CommonDataObject) alFac.get(i);
		if (fac.getColValue("facturar_a").equalsIgnoreCase("P")) {
			codFactPac = fac.getColValue("codigo");
			if(pacId==null || pacId.equals("")) pacId = fac.getColValue("pac_id");
		} else if (fac.getColValue("facturar_a").equalsIgnoreCase("E")) {
			empresa = fac.getColValue("cod_empresa");
		}

		String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+fac.getColValue("codigo")+"_"+fac.getColValue("compania")+"_"+pacId+"_"+admision+".pdf";
		String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
		String title = "DETALLES PROFORMA NO. "+fac.getColValue("facturar_a") + " - " + fac.getColValue("codigo");
		String subtitle = "";
		String xtraSubtitle = "";

		PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, (fac.getColValue("estatus").equals("A")?true:false), statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


/* * * * * * * * * * * * * * *   E N C A B E Z A D O   F A C T U R A   * * * * * * * * * * * * * * */
		pc.setNoColumnFixWidth(vHeader);
		pc.createTable("header");
			pc.setFont(headerFontSize,0);
			pc.addCols(preprinted?"":"NOMBRE:",0,1);
			pc.addCols(fac.getColValue("nombre_paciente"),0,1);
			pc.addCols(preprinted?"":"F. NAC:",0,1);
			pc.addCols(fac.getColValue("fecha_nac"),0,1);
			pc.addCols(preprinted?"":"FECHA:",0,1);
			pc.addCols(fac.getColValue("fecha"),0,1);

			pc.addCols(preprinted?"":"ASEGURADORA:",0,1);
			pc.addCols(fac.getColValue("nombre_aseguradora"),0,1);
			pc.addCols(preprinted?"":"POLIZA:",0,1);
			pc.addCols(fac.getColValue("poliza"),0,1);
			pc.addCols(preprinted?"":"CERT.:",0,1);
			pc.addCols(fac.getColValue("certificado"),0,1);

			pc.addCols(preprinted?"":"CATEGORIA:",0,1);
			pc.addCols(fac.getColValue("categoria"),0,1);
			pc.addCols(preprinted?"":"CUENTA:",0,1);
			pc.addCols(fac.getColValue("pac_id")+"-"+fac.getColValue("admi_secuencia"),0,1);
			pc.addCols(preprinted?"":"ID:",0,1);
			pc.addCols(fac.getColValue("identificacion"),0,1);



/* * * * * * * * * * * * * * *   T O T A L E S   * * * * * * * * * * * * * * */

		sbSql = new StringBuffer();
		sbSql.append("select nvl(subtotal,0) + nvl(total_honorarios,0) as subtotal, nvl(monto_descuento,0) as monto_descuento, nvl(monto_paciente,0) as monto_paciente, nvl(monto_total,0) + nvl(total_honorarios,0) as monto_total, nvl(grang_total,0) as gran_total, getCopago(compania,codigo) as copago, getGastosNoCubiertos(compania,codigo) as gastos_no_cubiertos");
		sbSql.append(", nvl((select nvl(grang_total,0) + nvl(monto_descuento2,0) + case when trunc(fecha) >= to_date('13/06/2012','dd/mm/yyyy') then nvl(monto_descuento,0) - nvl(total_honorarios,0) - nvl(getCopagoDet(compania,f.codigo,null,null,pac_id,admi_secuencia,'FTOT'),0) else nvl(-monto_descuento,0) end - nvl((select sum(monto) from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.codigo and imprimir_sino = 'S' and centro_servicio = ");
		sbSql.append(fac.getColValue("cds_paq_per"));
		sbSql.append("),0) from tbl_fac_factura z where facturar_a = 'P' and estatus <> 'A' and admi_secuencia = f.admi_secuencia and pac_id = f.pac_id and compania = f.compania),0) as totalPaciente, nvl((select sum(decode(tipo,'COP',monto,0)) as monto_copago from tbl_fac_estado_cargos_det where pac_id = f.pac_id and admi_secuencia = f.admi_secuencia and monto > 0),0) as montoCopago, nvl((select aplica_copago from tbl_adm_beneficios_acum where pac_id = f.pac_id AND admision = f.admi_secuencia and rownum = 1),'E') as aplica_copago from tbl_fac_factura f where codigo = '");
		sbSql.append(fac.getColValue("codigo"));
		sbSql.append("' and compania = ");
		sbSql.append(fac.getColValue("compania"));
		CommonDataObject facTotal = SQLMgr.getData(sbSql.toString());

		pc.setNoColumnFixWidth(vDetail);
		pc.createTable("total");
			pc.setFont(headerFontSize,0);
			pc.addCols(" ",1,3,trHeight);
			pc.addBorderCols(preprinted?"":"SUB-TOTAL",2,2,border,border,border,border);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("subtotal")),2,1,border,border,border,0.0f);
			pc.addBorderCols(" ",1,1,border,border,0.0f,border);

			pc.addCols(" ",1,3,trHeight * 2);
			pc.addBorderCols(preprinted?"":"DESCUENTO",2,2,border,border,border,border);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("monto_descuento")),2,1,border,border,border,0.0f);
			pc.addBorderCols(" ",1,1,border,border,0.0f,border);

			if (fac.getColValue("facturar_a").equalsIgnoreCase("E")) {
			
				double mPac = new Double(facTotal.getColValue("totalPaciente")).doubleValue();
				if (facTotal.getColValue("aplica_copago").equalsIgnoreCase("A")) mPac -= new Double(facTotal.getColValue("montoCopago")).doubleValue();

				pc.addCols(" ",1,3,trHeight);
				pc.addBorderCols("MONTO PACIENTE",2,2,border,border,border,border);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(mPac),2,1,border,border,border,0.0f);
				pc.addBorderCols(" ",1,1,border,border,0.0f,border);

			} else if (preprinted) pc.addCols(" ",2,vDetail.size(),trHeight);

			pc.addCols(" ",1,3,trHeight);
			pc.addBorderCols(preprinted?"":"TOTAL FACTURA",2,2,border,border,border,border);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(facTotal.getColValue("monto_total")),2,1,border,border,border,0.0f);
			pc.addBorderCols(" ",1,1,border,border,0.0f,border);
		totalHeight = pc.getTableHeight();



/* * * * * * * * * * * * * * *   D E T A L L E S   F A C T U R A   * * * * * * * * * * * * * * */

		int th = 3;
		pc.setNoColumnFixWidth(vDetail);
		pc.createTable();
			if (preprinted) {

				pc.setFont(7,0);
				pc.addCols(userName,2,vDetail.size());
				pc.setFont(7,0);
				pc.addCols(fecha,2,vDetail.size());
				pc.setFont(9,0);
				pc.addCols(title,1,vDetail.size());
				pc.addCols(" ",1,vDetail.size(),5.0f);
				th += 3;

			} else pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, vDetail.size());

			pc.addTableToCols("header",0,vDetail.size());

			pc.setFont(headerFontSize,0);
			pc.resetVAlignment();

			if (preprinted) pc.addCols(" ",1,vDetail.size(),36.0f);
			else {

				pc.addBorderCols("CODIGO",1,2);
				pc.addBorderCols("DESCRIPCION",1,3);
				pc.addBorderCols("MONTO",1,2);

			}

		pc.setTableHeader(th);
		headerHeight = pc.getTableHeight();

		detailHeight = height - (topMargin + bottomMargin + headerHeight + totalHeight);
		availHeight = detailHeight;

		sbSql = new StringBuffer();
		sbSql.append("select coalesce(procedimiento, ''||otros_cargos, ''||cds_producto, habitacion, ''||cod_uso, ''||codigo_empresa, (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo=codigo_medico), art_familia||'-'||art_clase||'-'||inv_articulo) as codigo");
		sbSql.append(", case when procedimiento is not null then (select coalesce(observacion,descripcion) from tbl_cds_procedimiento where codigo = z.procedimiento)");
		sbSql.append(" when otros_cargos is not null then (select descripcion from tbl_fac_otros_cargos where codigo = z.otros_cargos and compania = z.compania)");
		sbSql.append(" when cds_producto is not null then (select descripcion from tbl_cds_producto_x_cds a where codigo = z.cds_producto and exists (select null from tbl_fac_detalle_factura where compania = z.compania and fac_codigo = z.fac_codigo and renglon = z.renglon and nvl(centro_servicio,cds_cop) = a.cod_centro_servicio))");
		sbSql.append(" when habitacion is not null then (select (select descripcion from tbl_cds_centro_servicio where codigo = a.unidad_admin) from tbl_sal_habitacion a where codigo = z.habitacion and compania = z.compania)");
		sbSql.append(" when cod_uso is not null then (select descripcion from tbl_sal_uso where codigo = z.cod_uso and compania = z.compania)");
		sbSql.append(" when codigo_empresa is not null then (select nombre from tbl_adm_empresa where codigo = z.codigo_empresa)");
		sbSql.append(" when codigo_medico is not null then (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = z.codigo_medico)");
		sbSql.append(" when art_familia is not null and art_clase is not null and inv_articulo is not null then (select descripcion from tbl_inv_articulo where compania = z.compania and cod_flia = z.art_familia and cod_clase = z.art_clase and cod_articulo = z.inv_articulo)");
		sbSql.append(" else '-' end as descripcion");
		sbSql.append(", case when z.monto_empresa is null and z.monto_paciente is null then z.monto_copago else");
		if (fac.getColValue("facturar_a").equalsIgnoreCase("P")) sbSql.append(" (decode(nvl(z.monto_empresa,0),0,nvl(z.monto_clinica,0),0) + nvl(z.monto_paciente,0) + nvl(z.monto_descuento,0) - nvl(z.monto_copago,0))");
		else sbSql.append(" (nvl(z.monto_clinica,0) + nvl(z.monto_empresa,0) + nvl(z.monto_paciente,0) + nvl(z.monto_descuento,0)/* - nvl(z.monto_copago,0)*/)");
		sbSql.append(" end as monto");
		sbSql.append(" from tbl_fac_subdetalle_factura z where exists (select null from tbl_fac_detalle_factura where fac_codigo = '");
		sbSql.append(fac.getColValue("codigo"));
		sbSql.append("' and compania = ");
		sbSql.append(fac.getColValue("compania"));
		sbSql.append(" and fac_codigo = z.fac_codigo and compania = z.compania and renglon = z.renglon and imprimir_sino = 'S') order by z.secuencia");
		alDet = SQLMgr.getDataList(sbSql.toString());
		for (int j=0; j<alDet.size(); j++) {

			CommonDataObject det = (CommonDataObject) alDet.get(j);

			pc.setNoColumnFixWidth(vDetail);
			pc.createTable("tmp");
				pc.setFont(contentFontSize,0);
				pc.addBorderCols("",0,1,0.0f,0.0f,border,0.0f);
				pc.addBorderCols(det.getColValue("codigo"),0,1,0.0f,0.0f,0.0f,0.0f);
				pc.addBorderCols(det.getColValue("descripcion"),0,3,0.0f,0.0f,border,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(det.getColValue("monto")),2,1,0.0f,0.0f,border,0.0f);
				pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,border);
			tmpHeight = pc.getTableHeight();

			pc.useTable("main");
			if (tmpHeight > availHeight) {

				pc.addCols("",1,vDetail.size(),availHeight + totalHeight);
				pc.flushTableBody(true);
				availHeight = detailHeight;

			}
			pc.addTableToCols("tmp",0,vDetail.size());
			availHeight -= tmpHeight;

		}//alDet
		if (availHeight > 0) {

			pc.addBorderCols("",0,1,0.0f,0.0f,border,0.0f,availHeight);
			pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols((alDet.size() == 0)?"No existen registros":"",0,3,0.0f,0.0f,border,0.0f);
			pc.addBorderCols("",2,1,0.0f,0.0f,border,0.0f);
			pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,border);

		}

		pc.addTableToCols("total",0,vDetail.size(),0.0f,null,null,0.0f,border,0.0f,0.0f);
		pc.flushTableBody(true);
		pc.close();
		//response.sendRedirect(redirectFile);
	}//alFac
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<%@ include file="../common/tab.jsp"%>
</head>
<body>
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<%
StringBuffer sbTab = new StringBuffer();
for (int i=0; i<alFac.size(); i++) {
	CommonDataObject fac = (CommonDataObject) alFac.get(i);
	if (sbTab.length() > 0) sbTab.append("','");
	sbTab.append(fac.getColValue("facturar_a"));
	sbTab.append(fac.getColValue("codigo"));
%>
<!-- TAB<%=i%> DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<% /*if(!codFactPac.equals("")) { %>
<iframe name="print_fact_pac" id="print_fact_pac" frameborder="0" align="center" width="100%" height="30" scrolling="no" src="../common/reg_pago.jsp?tipoCliente=<%=fac.getColValue("facturar_a")%>"></iframe>
<% }*/ %>
<iframe name="<%=fac.getColValue("codigo")%>" id="<%=fac.getColValue("codigo")%>" frameborder="0" align="center" width="100%" height="550" scrolling="no" src="../pdfdocs/facturacion/<%=year%>/<%=month%>/<%=servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))%>_<%=fac.getColValue("codigo")%>_<%=fac.getColValue("compania")%>_<%=pacId%>_<%=admision%>.pdf"></iframe>
<!-- TAB<%=i%> DIV END HERE-->
</div>
<% } %>

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<% if (sbTab.length() > 0) { %>initTabs('dhtmlgoodies_tabView1',Array('<%=sbTab%>'),0,'100%','');<% } %>
function printFact(tipoCliente){
var refId='';
if(tipoCliente=='P')refId='<%=pacId%>';
else if(tipoCliente=='E')refId='<%=empresa%>';
abrir_ventana1('../caja/reg_recibo.jsp?tipoCliente='+tipoCliente+'&mode=add&fp=factura&pac_id=<%=pacId%>&factura=<%=codFactPac%>&refId='+refId);
}
</script>
</body>
</html>
<% } %>
