<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.cxp.OrdenPago"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="htCK" scope="page" class="java.util.Hashtable"/>
<jsp:useBean id="iAnexo" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
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
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String file = "-";
float pWidth = 8.5f;
float pHeight = 11.0f;
boolean showCompanyInfo = false;
CommonDataObject p = SQLMgr.getData("select nvl(get_sec_comp_param(-1,'CXP_VOUCHER_FILE'),'-') as voucher_file, nvl(get_sec_comp_param(-1,'CXP_VOUCHER_WSIZE'),'-') as voucher_width, nvl(get_sec_comp_param(-1,'CXP_VOUCHER_HSIZE'),'-') as voucher_height, nvl(get_sec_comp_param(-1,'CXP_VOUCHER_SHOW_COMP_INFO'),'-') as show_company_info from dual");
if (p != null) {

	if (!p.getColValue("voucher_file").equals("-")) {

		StringBuffer sbUrl = new StringBuffer();
		sbUrl.append(request.getContextPath());
		sbUrl.append(p.getColValue("voucher_file"));
		if (request.getQueryString() != null) {

			sbUrl.append("?");
			sbUrl.append(request.getQueryString());

		}
		response.sendRedirect(sbUrl.toString());
	}
	if (!p.getColValue("voucher_width").equals("-")) pWidth = Float.parseFloat(p.getColValue("voucher_width"));
	if (!p.getColValue("voucher_height").equals("-")) pHeight = Float.parseFloat(p.getColValue("voucher_height"));
	showCompanyInfo = (p.getColValue("show_company_info").equalsIgnoreCase("Y") || p.getColValue("show_company_info").equalsIgnoreCase("S"));

}

String num_ck = request.getParameter("num_ck");
String cod_compania = request.getParameter("cod_compania");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String id_lote = request.getParameter("id_lote");
String tipo_pago = request.getParameter("tipo_pago");
String tipo_pago_desc = "";

if (num_ck == null) num_ck = "";
if (cod_compania == null) cod_compania = (String) session.getAttribute("_companyId");
if (cod_banco == null) cod_banco = "";
if (cuenta_banco == null) cuenta_banco = "";
if (id_lote == null) id_lote = "";
if (tipo_pago == null) tipo_pago = "";
if (tipo_pago.equals("1")) tipo_pago_desc = "CHEQUE";
else if (tipo_pago.equals("2")) tipo_pago_desc = "ACH";
else if (tipo_pago.equals("3")) tipo_pago_desc = "TRANSFERENCIA";

if (!num_ck.trim().equals("")) { sbFilter.append(" and ck.num_cheque = '"); sbFilter.append(num_ck); sbFilter.append("'"); }
if (!cod_compania.trim().equals("")) { sbFilter.append(" and ck.cod_compania = "); sbFilter.append(cod_compania); }
if (!cod_banco.trim().equals("")) { sbFilter.append(" and ck.cod_banco = '"); sbFilter.append(cod_banco); sbFilter.append("'"); }
if (!cuenta_banco.trim().equals("")) { sbFilter.append(" and ck.cuenta_banco = '"); sbFilter.append(cuenta_banco); sbFilter.append("'"); }
if (!id_lote.trim().equals("")) { sbFilter.append(" and id_lote = "); sbFilter.append(id_lote); }

sbSql.append("select to_char(ck.f_emision,'dd/mm/yyyy') as fecha_emision, to_char(ck.f_emision,'dd') as dia, '**'||upper(nvl(ck.beneficiario2,ck.beneficiario))||'**' as beneficiario, upper(ck.beneficiario) as beneficiarioDet, ck.num_cheque, ck.cuenta_banco, ck.cod_banco, ck.cod_compania, '**'||trim(to_char(ck.monto_girado,'999,999,999.99'))||'**' as monto_girado_formatted, ck.monto_girado, ck.che_user, '**'||upper(ck.monto_palabras)||'**' palabra/*, upper(ck.beneficiario2) as beneficiario2*/, b.nombre, to_char(ck.f_emision,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') as mes, to_char(ck.f_emision,'yyyy') as anio, to_char(sysdate,'dd/mm/yyyy') as current_date, nvl(c.num_id_beneficiario,' ') as cod_beneficiario, (case when ck.ruc is null then ' ' else 'RUC. /'||ck.ruc||'/'||ck.dv end) as ruc, cb.cg_1_cta1||cb.cg_1_cta2||cb.cg_1_cta3||cb.cg_1_cta4||cb.cg_1_cta5||cb.cg_1_cta6 as cuentaBanco, ct.descripcion as descBanco, getckfacturas(ck.num_cheque,ck.cod_banco,ck.cuenta_banco,ck.cod_compania) as factura, nvl(ck.observacion,' ') as observacion from tbl_con_cheque ck, tbl_con_banco b, tbl_con_cuenta_bancaria cb, tbl_cxp_orden_de_pago c, tbl_con_catalogo_gral ct where /*ck.che_user = '");
sbSql.append(userName);
sbSql.append("' and /*Se activa filtro el mismo es util cuando varios usuarios generan cheques.*/ck.cuenta_banco = cb.cuenta_banco and ck.cod_compania = cb.compania and ck.cod_banco = cb.cod_banco and cb.compania = b.compania and cb.cod_banco = b.cod_banco and c.anio = ck.anio and c.num_orden_pago = ck.num_orden_pago and c.cod_compania = ck.cod_compania and ck.tipo_pago = ");
sbSql.append(tipo_pago);
sbSql.append(sbFilter);
sbSql.append(" and cb.compania = ct.compania and cb.cg_1_cta1 = ct.cta1 and cb.cg_1_cta2 = ct.cta2 and cb.cg_1_cta3 = ct.cta3 and cb.cg_1_cta4 = ct.cta4 and cb.cg_1_cta5 = ct.cta5 and cb.cg_1_cta6 = ct.cta6 order by ck.num_cheque");
al = SQLMgr.getDataList(sbSql.toString());

iAnexo.clear();
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdoDet = (CommonDataObject) al.get(i);
	cdoDet.setKey(i + 1);

	OrdenPago OP = new OrdenPago();
	OP.setCdo(cdoDet);

	sbSql = new StringBuffer();
	sbSql.append("select a.*, rownum as num_renglon from (select /*dck.num_renglon,*/ sum(dck.monto_renglon) as monto_renglon, dck.cuenta1||dck.cuenta2||dck.cuenta3||dck.cuenta4 as cuenta, dck.descripcion, nvl(dck.descripcion,ct.descripcion)||(select (select ' - '||nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) from tbl_fac_factura z where codigo = dck.num_factura and compania = ck.cod_compania and ck.tipo_orden = 1) as descCuenta, dck.num_factura from tbl_con_cheque ck, tbl_con_detalle_cheque dck, tbl_con_banco b, tbl_con_cuenta_bancaria cb, tbl_con_catalogo_gral ct where /*dck.imprimir = 'N' and ck.che_user = '");
	sbSql.append(userName);
	sbSql.append("' and*/ dck.cuenta_banco = ck.cuenta_banco and dck.cod_banco = ck.cod_banco and dck.compania = ck.cod_compania and dck.num_cheque = ck.num_cheque and ck.cuenta_banco = cb.cuenta_banco and ck.cod_compania = cb.compania and ck.cod_banco = cb.cod_banco and cb.compania = b.compania and cb.cod_banco = b.cod_banco and dck.compania = ct.compania and dck.cuenta1 = ct.cta1 and dck.cuenta2 = ct.cta2 and dck.cuenta3 = ct.cta3 and dck.cuenta4 = ct.cta4 and dck.cuenta5 = ct.cta5 and dck.cuenta6 = ct.cta6 and ck.num_cheque = '");
	sbSql.append(cdoDet.getColValue("num_cheque"));
	sbSql.append("' and trunc(ck.f_emision) >= to_date('");
	sbSql.append(cdoDet.getColValue("fecha_emision"));
	sbSql.append("', 'dd/mm/yyyy') and ck.cod_banco = '");
	sbSql.append(cdoDet.getColValue("cod_banco"));
	sbSql.append("' and ck.cuenta_banco = '");
	sbSql.append(cdoDet.getColValue("cuenta_banco"));
	sbSql.append("' and ck.tipo_pago = ");
	sbSql.append(tipo_pago);
	sbSql.append(" group by dck.cuenta1, dck.cuenta2, dck.cuenta3, dck.cuenta4, dck.descripcion, nvl(dck.descripcion,ct.descripcion), ck.cod_compania, ck.tipo_orden, dck.num_factura having sum(dck.monto_renglon) > 0 order by ck.num_cheque/*, dck.num_renglon*/) a");
	OP.setAlDet(SQLMgr.getDataList(sbSql.toString()));
	OP.getCdo().setSql(sbSql.toString());

	try {
		htCK.put(cdoDet.getKey(),OP);
	} catch (Exception e) {
		System.out.println("Unable to addget item "+cdoDet.getKey());
	}
}

if (request.getMethod().equalsIgnoreCase("GET")) {
	String fecha = cDateTime;
	String year = fecha.substring(6, 10);
	String mon = fecha.substring(3, 5);
	String month = null;
	String day = fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * pWidth;
	float height = 72 * pHeight;
	boolean isLandscape = false;
	float leftRightMargin = 0.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 0f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "COMPROBANTE DE PAGO [ " + tipo_pago_desc+" ]";
	String subtitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 10;
	int dFontSize = 8;
	int bold = 0;
	float cHeight = fontSize + 4.0f;
	float cdHeight = dFontSize + 4.0f;

	Vector dHeader = new Vector();
		dHeader.addElement(".03");
		dHeader.addElement(".70");
		dHeader.addElement(".24");
		dHeader.addElement(".03");

	Vector detail = new Vector();
		detail.addElement(".03");
		detail.addElement(".50");
		detail.addElement(".24");
		detail.addElement(".10");
		detail.addElement(".10");
		detail.addElement(".03");

	Vector anexo = new Vector();
		anexo.addElement(".03");
		anexo.addElement(".20");
		anexo.addElement(".20");
		anexo.addElement(".20");
		anexo.addElement(".14");
		anexo.addElement(".20");
		anexo.addElement(".03");

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,null);

	if (htCK.size() != 0) al = CmnMgr.reverseRecords(htCK);
	for (int i=0; i<htCK.size(); i++) {
		OrdenPago objOP = (OrdenPago) htCK.get(al.get(i).toString());
		CommonDataObject cdoCK = (CommonDataObject) objOP.getCdo();

		float availHeight = height - topMargin - bottomMargin - (cdHeight * 2);//anexo
		pc.setFont(fontSize,bold);
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable(true);

			if (showCompanyInfo) pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
			else pc.addCols(title,1,dHeader.size(),cHeight);

			pc.setFont(fontSize,bold);
			pc.addCols(" ",0,1);
			pc.addCols("No. Documento: "+cdoCK.getColValue("num_cheque"),0,1);
			pc.addCols(cdoCK.getColValue("dia")+" "+cdoCK.getColValue("mes")+" "+cdoCK.getColValue("anio"),2,1);
			pc.addCols(" ",0,1);

			pc.addCols(" ",0,1);
			pc.addCols(cdoCK.getColValue("beneficiario"),0,1,32.0f);
			pc.addCols(cdoCK.getColValue("monto_girado_formatted"),0,1);
			pc.addCols(" ",0,1);

			pc.addCols(" ",0,1);
			pc.addCols(cdoCK.getColValue("palabra"),0,dHeader.size() - 2);
			pc.addCols(" ",0,1);

			pc.addCols(" ",0,dHeader.size());

			availHeight -= pc.getTableHeight();


		pc.setFont(dFontSize,bold);
		pc.setNoColumnFixWidth(detail);
		pc.createTable("detFinal",true);

		if (!cdoCK.getColValue("observacion").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("Nota: "+cdoCK.getColValue("observacion"),0,detail.size() - 2);
			pc.addCols(" ",0,1);
			availHeight -= pc.getTableHeight();

		}


		pc.setNoColumnFixWidth(detail);
		pc.createTable("detailBnk",false);
			pc.addCols(" ",0,1,cdHeight);
			pc.addCols(cdoCK.getColValue("descBanco"),0,1);
			pc.addCols(cdoCK.getColValue("cuentaBanco"),2,1);
			pc.addCols(" ",0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdoCK.getColValue("monto_girado")),2,1);
			pc.addCols(" ",0,1);
			availHeight -= pc.getTableHeight();


		pc.setVAlignment(0);
		pc.setFont(dFontSize,bold);
		pc.setNoColumnFixWidth(detail);
		pc.createTable("detail",true);

			pc.addCols(" ",0,1);
			pc.addCols("BANCO: "+cdoCK.getColValue("nombre"),0,detail.size()-2);
			pc.addCols(" ",0,1);

		if (!cdoCK.getColValue("factura").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("PARA CANCELAR FACTURA(S) NO. "+cdoCK.getColValue("factura"),0,detail.size() - 2);
			pc.addCols(" ",0,1);

		}

		if (!cdoCK.getColValue("beneficiarioDet").trim().equals("")) {

			pc.addCols(" ",0,1);
			pc.addCols("PAGO A FAVOR DE: "+cdoCK.getColValue("beneficiarioDet"),0,detail.size() - 2);
			pc.addCols(" ",0,1);

		}

			pc.addCols(" ",1,detail.size());
			availHeight -= pc.getTableHeight();


		double amt = 0.00, tAmt = 0.00;
		String renglon = "";
		cdoCK.setSql(objOP.getCdo().getSql());
		for (int j=0; j<objOP.getAlDet().size(); j++) {
			cdo = (CommonDataObject) objOP.getAlDet().get(j);
			amt = Double.parseDouble(cdo.getColValue("monto_renglon"));

			pc.setNoColumnFixWidth(detail);
			pc.createTable("detailTmp",false);
				pc.addCols(" ",0,1);
				pc.addCols(cdo.getColValue("descCuenta"),0,1);
				pc.addCols(cdo.getColValue("cuenta"),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_renglon")),2,1);
				pc.addCols(" ",0,2);
			float tmpHeight = pc.getTableHeight();

			if (tmpHeight > availHeight) {

				if (j == 0) renglon = "0";
				break;

			}

			pc.useTable("detail");
			pc.addTableToCols("detailTmp",1,detail.size());
			availHeight -= tmpHeight;

			tAmt += amt;
			renglon = cdo.getColValue("num_renglon");//start anexo after this row

		}//for j

		pc.useTable("detail");
		pc.addTableToCols("detailBnk",1,detail.size());

		if (availHeight > 0) pc.addCols(" ",0,detail.size(),availHeight);


		pc.setFont(dFontSize,bold);
		pc.setNoColumnFixWidth(anexo);
		pc.createTable("anexo",true);

			pc.addCols(" ",0,1,cdHeight);
			pc.addCols(cdoCK.getColValue("current_date"),0,1);
			Double ckAmt = Double.parseDouble(cdoCK.getColValue("monto_girado"));
			if (renglon.trim().equals("") || (ckAmt - tAmt) == 0) pc.addCols(" ",0,2);
			else {

				try {
					cdoCK.addColValue("renglon",renglon);//last printed row
					cdoCK.addColValue("total_printed",CmnMgr.getFormattedDecimal(tAmt));
					cdoCK.addColValue("anexo_amt",CmnMgr.getFormattedDecimal(ckAmt - tAmt));
					iAnexo.put(cdoCK.getColValue("num_cheque"),cdoCK);
				} catch(Exception e) {
					System.out.println("Unable to add Anexo!");
				}
				pc.addCols("VER ANEXO",1,1);
				pc.addCols(CmnMgr.getFormattedDecimal(ckAmt - tAmt),1,1);

			}
			pc.addCols("TOTAL",2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdoCK.getColValue("monto_girado")),1,1);
			pc.addCols(" ",0,1);

			pc.addCols(" ",0,1,cdHeight);
			pc.addCols(userName,0,1);
			pc.addCols(cdoCK.getColValue("cod_beneficiario"),1,1);
			pc.addCols(cdoCK.getColValue("num_cheque"),1,1);
			pc.addCols(cdoCK.getColValue("ruc"),0,2);
			pc.addCols(" ",0,1);


		pc.useTable("main");
			pc.addTableToCols("detail",1,dHeader.size());
			pc.addTableToCols("anexo",1,dHeader.size());
			pc.addTableToCols("detFinal",1,dHeader.size());

		pc.addNewPage();
		pc.addTable();
	}
	pc.close();
%>
<html>
<frameset rows="0,*" frameborder="NO" border="0" framespacing="0">
	<frame src="../cxp/has_anexo.jsp?fp=cheque" name="actionFrame" scrolling="NO" noresize/>
	<frame src="<%=redirectFile%>" name="printFrame"/>
</frameset>
<noframes></noframes>
</html>
<% } %>
