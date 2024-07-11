<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
StringBuffer sbSql = new StringBuffer();
String tipoCliente = request.getParameter("tipoCliente");
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("hh12mmssam");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");

if (appendFilter == null) appendFilter = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";

sbSql.append("select to_char(f.fecha,'dd/mm/yyyy') fecha,f.pac_id,f.admi_secuencia admision,f.pac_id||' - '||f.admi_secuencia cuenta, f.codigo,decode(f.facturar_a,'P',(select nombre_paciente from vw_adm_paciente where pac_id =f.pac_id),'E',(select nombre from tbl_adm_empresa where codigo=f.cod_empresa)) nombre,nvl(f.grang_total,0)grang_total,nvl((select  nvl(sum (decode (b.lado_mov, 'D', b.monto, 'C', -b.monto)),0) ajuste from vw_con_adjustment_gral b where  b.factura = f.codigo and b.compania=f.compania),0)+nvl((select nvl(sum(decode(z.doc_type, 'NDB', z.net_amount,'NCR',-z.net_amount)),0)v_monto_ndnc_pos from tbl_fac_trx z where z.company_id = f.compania and exists (select null from tbl_fac_trx x where x.other3 =f.codigo and x.doc_type='FAC' and x.doc_id =z.reference_id and x.company_id=z.company_id) and z.doc_type in ('NDB', 'NCR') and z.status = 'O' ),0) as  ajuste ,nvl(fn_cja_saldo_fact(f.facturar_a,f.compania,f.codigo,f.grang_total),0) saldo  ,nvl((select nvl(sum(z.monto),0) from tbl_cja_detalle_pago z, tbl_cja_transaccion_pago y  where z.fac_codigo = f.codigo and z.compania = f.compania     and z.codigo_transaccion = y.codigo and z.compania = y.compania and z.tran_anio = y.anio and y.rec_status = 'A' ),0) aplicado, nvl((select sum(dist.monto) from tbl_cja_distribuir_pago dist, tbl_cja_transaccion_pago y where dist.fac_codigo=f.codigo and dist.compania=f.compania and dist.codigo_transaccion = y.codigo and dist.compania = y.compania and dist.tran_anio = y.anio and y.rec_status = 'A'),0) distribucion  ,nvl(( select join(cursor( select recibo from tbl_cja_detalle_pago z, tbl_cja_transaccion_pago y where z.fac_codigo = f.codigo and z.compania = f.compania and z.codigo_transaccion = y.codigo and z.compania = y.compania and z.tran_anio = y.anio and y.rec_status = 'A' ),';') from dual),' ')recibos from tbl_fac_factura f where f.compania =");
	sbSql.append((String) session.getAttribute("_companyId"));

	if(!fechaini.trim().equals("")){sbSql.append(" and fecha >= to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	if(!fechafin.trim().equals("")){sbSql.append(" and fecha <= to_date('");
	sbSql.append(fechafin);
	sbSql.append("','dd/mm/yyyy')");}
	sbSql.append(" and fn_cja_saldo_fact(f.facturar_a,f.compania,f.codigo,f.grang_total) < 0  order by f.codigo  ");
	al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+time+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CAJA";
	String subtitle = "FACTURAS CON MONTO APLICADO MAYOR AL SALDO";
	String xtraSubtitle = "DEL "+fechaini+"  AL  "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".09");
		dHeader.addElement(".24");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".07");
		dHeader.addElement(".15");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(fontSize,1);
		pc.addBorderCols("Factura",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("Cliente",1);
		pc.addBorderCols("Cuenta",1);
		pc.addBorderCols("Monto",1);
		pc.addBorderCols("Ajuste",1);
		pc.addBorderCols("Total",1);
		pc.addBorderCols("Aplicado",1);
		pc.addBorderCols("Distribuido",1);
		pc.addBorderCols("Recibos",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	double total=0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(fontSize-1,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("codigo"),2,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(cdo.getColValue("cuenta"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("grang_total")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ajuste")),2,1);
		total= Double.parseDouble(cdo.getColValue("grang_total"))+Double.parseDouble(cdo.getColValue("ajuste"));
		pc.addCols(CmnMgr.getFormattedDecimal(total),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("aplicado")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("distribucion")),2,1);
		pc.addCols(""+cdo.getColValue("recibos"),0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>