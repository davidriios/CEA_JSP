<%//@ page errorPage="../error.jsp"%>
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

String pacId = request.getParameter("pacId");
String admision = request.getParameter("noSecuencia");
boolean isCurrTrx = (request.getParameter("printOF") != null && request.getParameter("printOF").equalsIgnoreCase("S"));
String tipoTransaccion = request.getParameter("tipoTransaccion");
String codigo = request.getParameter("codigo");

if (pacId == null) pacId = "";
if (admision == null) admision = "";
if (pacId.trim().equals("") || admision.trim().equals("")) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tipoTransaccion == null) tipoTransaccion = "";
if (codigo == null) codigo = "";

float pHeight = 5.5f;
CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'COD_TIPO_SERV_HON'),'-') as tserv_hon, nvl(get_sec_comp_param(-1,'FAC_SHORT_CARGODEV_PAPER_HSIZE'),'5.5') as paper_height from dual");
if (p != null && p.getColValue("paper_height") != null && !p.getColValue("paper_height").equals("-")) pHeight = Float.parseFloat(p.getColValue("paper_height"));
if (p != null && p.getColValue("tserv_hon").equals("-")) throw new Exception("El parámetro de Tipo de Servicio Honorario (COD_TIPO_SERV_HON) no está definido!");

sbSql = new StringBuffer();
sbSql.append("select z.pac_id, z.secuencia as admision, to_char(z.fecha_ingreso,'dd/mm/yyyy') as fecha, (select nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) as nombre_paciente, to_char((select f_nac from vw_adm_paciente where pac_id = z.pac_id),'dd/mm/yyyy') as fecha_nac, (select id_paciente from vw_adm_paciente where pac_id = z.pac_id) as identificacion, (select descripcion from tbl_adm_categoria_admision where codigo = z.categoria) as categoria, nvl((select (select nombre from tbl_adm_empresa where codigo = a.empresa) from tbl_adm_beneficios_x_admision a where pac_id = z.pac_id and admision = z.secuencia and estado = 'A' and rownum = 1),' ') as nombre_aseguradora, nvl((select poliza from tbl_adm_beneficios_x_admision a where pac_id = z.pac_id and admision = z.secuencia and estado = 'A' and rownum = 1),' ') as poliza, nvl((select certificado from tbl_adm_beneficios_x_admision a where pac_id = z.pac_id and admision = z.secuencia and estado = 'A' and rownum = 1),' ') as certificado, (select sum(decode(tipo_transaccion,'D',-cantidad,cantidad) * (monto + nvl(recargo,0))) from tbl_fac_detalle_transaccion where pac_id = z.pac_id and fac_secuencia = z.secuencia and compania = z.compania");
if (isCurrTrx && !tipoTransaccion.trim().equals("") && !codigo.trim().equals("")) {

	sbSql.append(" and fac_codigo =");
	sbSql.append(codigo);
	sbSql.append(" and tipo_transaccion = '");
	sbSql.append(tipoTransaccion);
	sbSql.append("'");

}
sbSql.append(") as monto_total, 0 as monto_descuento from tbl_adm_admision z where pac_id = ");
sbSql.append(pacId);
sbSql.append(" and z.secuencia = ");
sbSql.append(admision);
sbSql.append(" and z.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
CommonDataObject cdoH = SQLMgr.getData(sbSql.toString());
cdoH.addColValue("subtotal",cdoH.getColValue("monto_total"));

sbSql = new StringBuffer();
if (request.getParameter("net") == null) {

	sbSql.append("select b.fecha_cargo, decode(b.tipo_transaccion,'D',1,0) as cargoDevOrder, a.seq_trx, b.secuencia");
	sbSql.append(", case when (b.tipo_transaccion = 'H' or (b.tipo_transaccion = 'D' and b.tipo_cargo = '");
	sbSql.append(p.getColValue("tserv_hon"));
	sbSql.append("')) then decode(a.empre_codigo,null,a.med_codigo,a.empre_codigo)");
	sbSql.append(" else coalesce(b.procedimiento,b.habitacion,''||b.cds_producto,''||b.cod_uso,''||b.otros_cargos,''||b.cod_paq_x_cds,decode(b.art_familia||b.art_clase||b.inv_articulo,null,'',b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo),' ') end as codigo");
	sbSql.append(", to_char(b.fecha_cargo,'dd/mm/yyyy')||' '||case when (b.tipo_transaccion = 'H' or (b.tipo_transaccion = 'D' and b.tipo_cargo = '");
	sbSql.append(p.getColValue("tserv_hon"));
	sbSql.append("')) then decode(a.empre_codigo,null,(select primer_apellido||' '||segundo_apellido||' '||apellido_de_casada||', '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.med_codigo),(select nombre from tbl_adm_empresa where codigo = a.empre_codigo))");
	sbSql.append(" else nvl(b.descripcion,' ') end as descripcion");
	sbSql.append(", decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad) as cantidad, (b.monto + nvl(b.recargo,0)) as monto, decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad) * (b.monto + nvl(b.recargo,0)) as monto_total");
	sbSql.append(" from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.admi_secuencia = ");
	sbSql.append(admision);
	sbSql.append(" and a.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if (isCurrTrx && !tipoTransaccion.trim().equals("") && !codigo.trim().equals("")) {

		sbSql.append(" and a.codigo =");
		sbSql.append(codigo);
		sbSql.append(" and a.tipo_transaccion = '");
		sbSql.append(tipoTransaccion);
		sbSql.append("'");

	}
	sbSql.append(" and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.compania = b.compania and a.tipo_transaccion = b.tipo_transaccion and a.codigo = b.fac_codigo");
	sbSql.append(" order by 1, 2, 3, 4");

} else {

	sbSql.append("select codigo, descripcion, sum(cantidad) as cantidad, (monto) as monto, sum(monto_total) as monto_total from (");
		sbSql.append("select b.fecha_cargo");
		sbSql.append(", case when (b.tipo_transaccion = 'H' or (b.tipo_transaccion = 'D' and b.tipo_cargo = '");
		sbSql.append(p.getColValue("tserv_hon"));
		sbSql.append("')) then decode(a.empre_codigo,null,a.med_codigo,a.empre_codigo)");
		sbSql.append(" else coalesce(b.procedimiento,b.habitacion,''||b.cds_producto,''||b.cod_uso,''||b.otros_cargos,''||b.cod_paq_x_cds,decode(b.art_familia||b.art_clase||b.inv_articulo,null,'',b.art_familia||'-'||b.art_clase||'-'||b.inv_articulo),' ') end as codigo");
		sbSql.append(", case when (b.tipo_transaccion = 'H' or (b.tipo_transaccion = 'D' and b.tipo_cargo = '");
		sbSql.append(p.getColValue("tserv_hon"));
		sbSql.append("')) then decode(a.empre_codigo,null,(select primer_apellido||' '||segundo_apellido||' '||apellido_de_casada||', '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.med_codigo),(select nombre from tbl_adm_empresa where codigo = a.empre_codigo))");
		sbSql.append(" else nvl(b.descripcion,' ') end as descripcion");
		sbSql.append(", (decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad)) as cantidad, (b.monto + nvl(b.recargo,0)) as monto, (decode(b.tipo_transaccion,'D',-b.cantidad,b.cantidad) * (b.monto + nvl(b.recargo,0))) as monto_total");
		sbSql.append(" from tbl_fac_transaccion a, tbl_fac_detalle_transaccion b where a.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and a.admi_secuencia = ");
		sbSql.append(admision);
		sbSql.append(" and a.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		if (isCurrTrx && !tipoTransaccion.trim().equals("") && !codigo.trim().equals("")) {

			sbSql.append(" and a.codigo =");
			sbSql.append(codigo);
			sbSql.append(" and a.tipo_transaccion = '");
			sbSql.append(tipoTransaccion);
			sbSql.append("'");

		}
		sbSql.append(" and a.pac_id = b.pac_id and a.admi_secuencia = b.fac_secuencia and a.compania = b.compania and a.tipo_transaccion = b.tipo_transaccion and a.codigo = b.fac_codigo");
	sbSql.append(") group by codigo, descripcion, monto having sum(cantidad) <> 0");
	sbSql.append(" order by 1");

}
alDet = SQLMgr.getDataList(sbSql.toString());

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

	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+pacId+"_"+admision+".pdf";
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	String title = "DETALLE DE CARGOS";
	String subtitle = "";
	String xtraSubtitle = "";
	if (request.getParameter("net") != null) title = "DETALLE DE CARGOS NETO";

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, false, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


/* * * * * * * * * * * * * * *   E N C A B E Z A D O   * * * * * * * * * * * * * * */
	pc.setNoColumnFixWidth(vHeader);
	pc.createTable("header");
		pc.setFont(headerFontSize,0);
		pc.addCols(preprinted?"":"NOMBRE:",0,1);
		pc.addCols(cdoH.getColValue("nombre_paciente"),0,1);
		pc.addCols(preprinted?"":"F. NAC:",0,1);
		pc.addCols(cdoH.getColValue("fecha_nac"),0,1);
		pc.addCols(preprinted?"":"FECHA:",0,1);
		pc.addCols(cdoH.getColValue("fecha"),0,1);

		pc.addCols(preprinted?"":"ASEGURADORA:",0,1);
		pc.addCols(cdoH.getColValue("nombre_aseguradora"),0,1);
		pc.addCols(preprinted?"":"POLIZA:",0,1);
		pc.addCols(cdoH.getColValue("poliza"),0,1);
		pc.addCols(preprinted?"":"CERT.:",0,1);
		pc.addCols(cdoH.getColValue("certificado"),0,1);

		pc.addCols(preprinted?"":"CATEGORIA:",0,1);
		pc.addCols(cdoH.getColValue("categoria"),0,1);
		pc.addCols(preprinted?"":"CUENTA:",0,1);
		pc.addCols(cdoH.getColValue("pac_id")+"-"+cdoH.getColValue("admision"),0,1);
		pc.addCols(preprinted?"":"ID:",0,1);
		pc.addCols(cdoH.getColValue("identificacion"),0,1);



/* * * * * * * * * * * * * * *   T O T A L E S   * * * * * * * * * * * * * * */
	pc.setNoColumnFixWidth(vDetail);
	pc.createTable("total");
		pc.setFont(headerFontSize,0);
		pc.addCols(" ",1,3,trHeight);
		pc.addBorderCols(preprinted?"":"SUB-TOTAL",2,2,border,border,border,border);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoH.getColValue("subtotal")),2,1,border,border,border,0.0f);
		pc.addBorderCols(" ",1,1,border,border,0.0f,border);

		pc.addCols(" ",1,3,trHeight * 2);
		pc.addBorderCols(preprinted?"":"DESCUENTO",2,2,border,border,border,border);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoH.getColValue("monto_descuento")),2,1,border,border,border,0.0f);
		pc.addBorderCols(" ",1,1,border,border,0.0f,border);

		pc.addCols(" ",1,3,trHeight);
		pc.addBorderCols(" ",2,2,border,border,border,border);
		pc.addBorderCols(" ",2,1,border,border,border,0.0f);
		pc.addBorderCols(" ",1,1,border,border,0.0f,border);

		pc.addCols(" ",1,3,trHeight);
		pc.addBorderCols(preprinted?"":"TOTAL",2,2,border,border,border,border);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoH.getColValue("monto_total")),2,1,border,border,border,0.0f);
		pc.addBorderCols(" ",1,1,border,border,0.0f,border);
	totalHeight = pc.getTableHeight();



/* * * * * * * * * * * * * * *   D E T A L L E S   * * * * * * * * * * * * * * */
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
			pc.addBorderCols("DESCRIPCION",1,1);
			pc.addBorderCols("CANT.",1,1);
			pc.addBorderCols("PRECIO",1,1);
			pc.addBorderCols("MONTO",1,2);

		}

	pc.setTableHeader(th);
	headerHeight = pc.getTableHeight();

	detailHeight = height - (topMargin + bottomMargin + headerHeight + totalHeight);
	availHeight = detailHeight;

	for (int j=0; j<alDet.size(); j++) {

		CommonDataObject det = (CommonDataObject) alDet.get(j);

		pc.setNoColumnFixWidth(vDetail);
		pc.createTable("tmp");
			pc.setFont(contentFontSize,0);
			pc.addBorderCols("",0,1,0.0f,0.0f,border,0.0f);
			pc.addBorderCols(det.getColValue("codigo"),0,1,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(det.getColValue("descripcion"),0,1,0.0f,0.0f,border,0.0f);
			pc.addBorderCols(det.getColValue("cantidad"),2,1,0.0f,0.0f,border,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(det.getColValue("monto")),2,1,0.0f,0.0f,border,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(det.getColValue("monto_total")),2,1,0.0f,0.0f,border,0.0f);
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
		pc.addBorderCols((alDet.size() == 0)?"No existen registros":"",0,1,0.0f,0.0f,border,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,border,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,border,0.0f);
		pc.addBorderCols("",2,1,0.0f,0.0f,border,0.0f);
		pc.addBorderCols("",0,1,0.0f,0.0f,0.0f,border);

	}

	pc.addTableToCols("total",0,vDetail.size(),0.0f,null,null,0.0f,border,0.0f,0.0f);
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}
%>
