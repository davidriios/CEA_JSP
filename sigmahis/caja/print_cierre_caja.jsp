<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ include file="../common/pdf_header.jsp"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
CommonDataObject cdoD = new CommonDataObject();
CommonDataObject cdoC = new CommonDataObject();
String id = request.getParameter("id");
String fpOtros = "Otros";
try {fpOtros = java.util.ResourceBundle.getBundle("issi").getString("fpOtros"); } catch(Exception e){ fpOtros = "Otros";}

boolean viewInfo = true;
if (!UserDet.getUserProfile().contains("0")) {

	sbSql = new StringBuffer();
	sbSql.append("select nvl(tipo,'C') as tipo from tbl_cja_cajera where usuario = '");
	sbSql.append(UserDet.getUserName());
	sbSql.append("' and compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	cdo = SQLMgr.getData(sbSql.toString());

	String showTo = "A";
	try { showTo = java.util.ResourceBundle.getBundle("issi").getString("system.shift"); } catch(Exception e) { System.out.println("* * * Parameter [system.shift] is not defined! * * *"); }
	if (cdo == null) throw new Exception("Solo para personal de caja!");
	else if (!showTo.equalsIgnoreCase("A") && !cdo.getColValue("tipo").equalsIgnoreCase(showTo)) viewInfo = false;

}

String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
if (appendFilter == null) appendFilter = "";

sbSql = new StringBuffer();
sbSql.append("select a.codigo, a.monto_cierre, to_char(a.fecha,'dd/mm/yyyy')||' '||to_char(a.hora_inicio,'hh12:mi:ss am') as hora_inicio, to_char(a.hora_final,'dd/mm/yyyy hh12:mi:ss am') as hora_final, a.monto_inicial, a.cja_cajera_cod_cajera as cod_cajera, b.nombre as cajero_nombre, nvl(c.nombre,' ') as supervisor_abre_nombre, d.cod_caja from tbl_cja_turnos a, tbl_cja_cajera b, tbl_cja_cajera c, tbl_cja_turnos_x_cajas d where a.cja_cajera_cod_cajera = b.cod_cajera and a.compania = b.compania and a.cod_supervisor_abre = c.cod_cajera(+) and a.compania = c.compania(+) and a.codigo = d.cod_turno and a.compania = d.compania and a.codigo = ");
sbSql.append(id);
sbSql.append(" and a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
cdo = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
		sbSql.append("select fn_cja_total_cajero(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",");
		sbSql.append(id);
		sbSql.append(",'S') as pago_total from dual");
		cdoT = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select c.codigo, initcap(c.descripcion) as fp_label, nvl(b.monto,0) as monto from tbl_cja_forma_pago c, (select a.fp_codigo, nvl(a.monto,0)-nvl(b.monto,0) monto from (select b.fp_codigo, sum(b.monto) as monto from tbl_cja_transaccion_pago a, tbl_cja_trans_forma_pagos b where b.compania = a.compania and b.tran_anio = a.anio and b.tran_codigo = a.codigo and a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.status = 'B' and a.turno = ");
		sbSql.append(id);
		sbSql.append(" and ((a.rec_status = 'A') or (a.rec_status = 'I' and a.turno = ");
		sbSql.append(id);
		sbSql.append(" and a.turno <> a.turno_anulacion)) and to_char(a.codigo) != get_sec_comp_param(a.compania, 'FORMA_PAGO_CREDITO')");
		sbSql.append(" group by b.fp_codigo) a, (select f.company_id, fp.fp_codigo, sum (fp.monto) as monto from tbl_fac_trx f, tbl_fac_trx_forma_pagos fp where fp.compania = f.company_id and f.doc_id = fp.doc_id and f.doc_type = 'NCR' and f.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and f.turno = ");
		sbSql.append(id);
		sbSql.append(" group by f.company_id, fp.fp_codigo) b where a.fp_codigo = b.fp_codigo(+)) b where c.codigo = b.fp_codigo(+)");
		sbSql.append(" union all select -3,  'Recibos Anulados', nvl(sum(nvl(pago_total,0)),0) as monto from tbl_cja_transaccion_pago   where compania = ");
		sbSql.append((String) session.getAttribute("_companyId")); 
   		sbSql.append("and turno_anulacion = ");
		sbSql.append(id);
		sbSql.append("  and rec_status = 'I'  and turno <> turno_anulacion  and nvl(afectar_saldo,'x')='S' ");
al = SQLMgr.getDataList(sbSql.toString());
String labelVale = "Total Vales";
for(int i = 0; i< al.size(); i++){
	CommonDataObject cdx = (CommonDataObject) al.get(i);
	cdoD.addColValue(cdx.getColValue("codigo"), cdx.getColValue("monto"));
	//cdoD.addColValue("label"+cdx.getColValue("codigo"), cdx.getColValue("fp_label"));
	if (cdx.getColValue("codigo").equals("9")) labelVale = cdx.getColValue("fp_label");
}

sbSql = new StringBuffer();
sbSql.append("select nvl(total_cash,0) as efectivo, nvl(total_cheque,0) as cheque, nvl(total_accdeposit,0) as deposito, nvl(total_creditcard,0) as tarjeta_credito, nvl(total_debitcard,0) as tarjeta_debito, final_total, nvl(otros,0) as otros, hundreds, tot_hundreds, fiftys, tot_fiftys, twentys, tot_twentys, tens, tot_tens, fives, tot_fives, ones, tot_ones, fifty_coins, tot_50coins, twentyfive_coins, tot_25coins, ten_coins, tot_10coins, five_coins, tot_5coins, one_coins, tot_1coins, nvl(total_vales,0) as total_vales from tbl_cja_sesdetails where session_id = ");
sbSql.append(id);
sbSql.append(" and company_id = ");
sbSql.append(session.getAttribute("_companyId"));
cdoC = SQLMgr.getData(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	boolean isLandscape = true;
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
	String title = "CIERRE DE CAJA";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	Vector dFooter = new Vector();
		dFooter.addElement(".10");
		dFooter.addElement(".20");
		dFooter.addElement(".10");
		dFooter.addElement(".20");
		dFooter.addElement(".10");
		dFooter.addElement(".20");
		dFooter.addElement(".10");

	footer.setNoColumnFixWidth(dFooter);
	footer.createTable();
		footer.setFont(10,0);
		footer.addCols(" ",0,dFooter.size());

		footer.addCols("",0,1);
		footer.addBorderCols("Cajero",1,1,0.0f,0.1f,0.0f,0.0f);
		footer.addCols("",0,1);
		footer.addBorderCols("Supervisor",1,1,0.0f,0.1f,0.0f,0.0f);
		footer.addCols("",0,1);
		footer.addBorderCols("Contabilidad",1,1,0.0f,0.1f,0.0f,0.0f);
		footer.addCols("",0,1);

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".20");
		dHeader.addElement(".15");
		dHeader.addElement(".20");
		dHeader.addElement(".15");

	Vector cDetail = new Vector();
		cDetail.addElement(".10");
		cDetail.addElement(".10");
		cDetail.addElement(".10");
		cDetail.addElement(".15");
		cDetail.addElement(".10");
		cDetail.addElement(".10");
		cDetail.addElement(".10");
		cDetail.addElement(".15");
		cDetail.addElement(".10");

	int nCol = 4;
	Vector dDetail = new Vector();
	if (viewInfo) {

		nCol = 2;
		dDetail.addElement("107");
		dDetail.addElement("107");

	} else {

		dDetail.addElement("214");
		dDetail.addElement("214");

	}

	float tSize = ((isLandscape?height:width) - (leftRightMargin * 2)) * .35f * (viewInfo?1:2);
	pc.setNoColumnFixWidth(dDetail);
	pc.createTable("cajero",false,0,((isLandscape?height:width) - tSize));
		pc.addBorderCols("DETALLE DEL CAJERO",1,dDetail.size(),0.1f,0.1f,0.0f,0.0f);

		pc.addCols("Efectivo:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("efectivo")),2,1);

		pc.addCols("Cheque:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("cheque")),2,1);

		pc.addCols("Ach/Transferencia/Depósito:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("deposito")),2,1);

		pc.addCols("Tarjeta Crédito:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tarjeta_credito")),2,1);

		pc.addCols("Tarjeta Débito:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tarjeta_debito")),2,1);

		pc.addCols(fpOtros+":",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("otros")),2,1);

		pc.addCols(labelVale+":",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("total_vales")),2,1);
		
		pc.addCols(" ",2,1);
		pc.addCols(" ",2,1);

		pc.addBorderCols("Total del Cajero:",2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("final_total")),2,1,0.0f,0.1f,0.0f,0.0f);

	double total4 = 0.00, total5 = 0.00, totaltt = 0.00;
	//total4=Double.parseDouble(cdoD.getColValue("4"));
	//total5= Double.parseDouble(cdoD.getColValue("5"));
	if (cdoD.getColValue("4") != null && !cdoD.getColValue("4").trim().equals("")) total4 = Double.parseDouble(cdoD.getColValue("4"));
	if (cdoD.getColValue("5") != null && !cdoD.getColValue("5").trim().equals("")) total5 = Double.parseDouble(cdoD.getColValue("5"));

	totaltt = (total4 + total5);

	pc.setNoColumnFixWidth(dDetail);
	pc.createTable("sistema",false,0,((isLandscape?height:width) - tSize));
		pc.addBorderCols("DETALLE DEL SISTEMA",1,dDetail.size(),0.1f,0.1f,0.0f,0.0f);

		pc.addCols("Efectivo:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("1")),2,1);

		pc.addCols("Cheque:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("2")),2,1);

		pc.addCols("Ach/Transferencia/Depósito:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totaltt),2,1);

		pc.addCols("Tarjeta Crédito:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("3")),2,1);

		pc.addCols("Tarjeta Débito:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("6")),2,1);
		//pc.addCols(" ",2,1);
		//pc.addCols(" ",2,1);
		
		pc.addCols("Reemplazo:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("0")),2,1);
		//pc.addCols(" ",2,1);
		//pc.addCols(" ",2,1);
		
		pc.addCols(labelVale+":",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("9")),2,1);
		
		pc.addCols("Anulaciones:",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoD.getColValue("-3")),2,1);
		//pc.addCols(" ",2,1);
		//pc.addCols(" ",2,1);

		pc.addBorderCols("Total del Cajero:",2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("pago_total")),2,1,0.0f,0.1f,0.0f,0.0f);


	tSize = ((isLandscape?height:width) - (leftRightMargin * 2)) * .7f;
	pc.setNoColumnFixWidth(cDetail);
	pc.createTable("efectivo",false,0,((isLandscape?height:width) - tSize));
		pc.addBorderCols(". : DETALLES DEL EFECTIVO : .",1,cDetail.size(),0.1f,0.1f,0.0f,0.0f);

		pc.addCols("",0,1);
		pc.addCols("100 X ",2,1);
		pc.addCols(cdoC.getColValue("hundreds")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_hundreds")),2,1);
		pc.addCols("",0,1);
		pc.addCols("0.50 X ",2,1);
		pc.addCols(cdoC.getColValue("fifty_coins")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_50coins")),2,1);
		pc.addCols("",0,1);

		pc.addCols("",0,1);
		pc.addCols("50 X ",2,1);
		pc.addCols(cdoC.getColValue("fiftys")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_fiftys")),2,1);
		pc.addCols("",0,1);
		pc.addCols("0.25 X ",2,1);
		pc.addCols(cdoC.getColValue("twentyfive_coins")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_25coins")),2,1);
		pc.addCols("",0,1);

		pc.addCols("",0,1);
		pc.addCols("20 X ",2,1);
		pc.addCols(cdoC.getColValue("twentys")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_twentys")),2,1);
		pc.addCols("",0,1);
		pc.addCols("0.10 X ",2,1);
		pc.addCols(cdoC.getColValue("ten_coins")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_10coins")),2,1);
		pc.addCols("",0,1);

		pc.addCols("",0,1);
		pc.addCols("10 X ",2,1);
		pc.addCols(cdoC.getColValue("tens")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_tens")),2,1);
		pc.addCols("",0,1);
		pc.addCols("0.05 X ",2,1);
		pc.addCols(cdoC.getColValue("five_coins")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_5coins")),2,1);
		pc.addCols("",0,1);

		pc.addCols("",0,1);
		pc.addCols("5 X ",2,1);
		pc.addCols(cdoC.getColValue("fives")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_fives")),2,1);
		pc.addCols("",0,1);
		pc.addCols("0.01 X ",2,1);
		pc.addCols(cdoC.getColValue("one_coins")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_1coins")),2,1);
		pc.addCols("",0,1);

		pc.addCols("",0,1);
		pc.addCols("1 X ",2,1);
		pc.addCols(cdoC.getColValue("ones")+" = ",2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdoC.getColValue("tot_ones")),2,1);
		pc.addCols("",0,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",2,1);
		pc.addCols("",0,1);


	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);//create de table header


	pc.setFont(headerFontSize,1);
	pc.addBorderCols("",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("Turno:",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols(cdo.getColValue("codigo"),0,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("Fecha Inicial:",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols(cdo.getColValue("hora_inicio"),0,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("",2,1, 0.0f, 0.0f, 0.0f, 0.0f);

	pc.addBorderCols("",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("Fecha Final:",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols(cdo.getColValue("hora_final"),0,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("Cajero:",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols(cdo.getColValue("cajero_nombre"),0,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("",2,1, 0.0f, 0.0f, 0.0f, 0.0f);

	pc.addBorderCols("",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("Supervisor:",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols(cdo.getColValue("supervisor_abre_nombre"),0,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("Efectivo Inicial:",2,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_inicial")),0,1, 0.0f, 0.0f, 0.0f, 0.0f);
	pc.addBorderCols("",2,1, 0.0f, 0.0f, 0.0f, 0.0f);

	pc.addCols("",2,1);
	pc.addTableToCols("cajero",1,nCol);
	if (viewInfo) pc.addTableToCols("sistema",1,nCol);
	pc.addCols("",0,1);

	if (viewInfo) {

		double tot_cajero = 0.00;
		double tot_sys = 0.00;

		if (cdoC.getColValue("final_total") != null && !cdoC.getColValue("final_total").trim().equals("")) tot_cajero = Double.parseDouble(cdoC.getColValue("final_total"));
		if (cdoT.getColValue("pago_total") != null && !cdoT.getColValue("pago_total").trim().equals("")) tot_sys = Double.parseDouble(cdoT.getColValue("pago_total"));

		if (tot_cajero != tot_sys) {
			if ((tot_cajero < tot_sys)) pc.setFont(8, 1,Color.red);
			pc.addBorderCols(((tot_cajero<tot_sys)?"FALTANTE:":"SOBRANTE: ")+CmnMgr.getFormattedDecimal((tot_cajero-tot_sys)),1,6, 0.0f, 0.0f, 0.0f, 0.0f);
		}

	}

	pc.addCols(" ",2,dHeader.size());

	pc.addCols("",2,1);
	pc.addTableToCols("efectivo",1,nCol * ((viewInfo)?2:1));
	pc.addCols("",0,1);

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>

