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
Reporte cja71010.rdf
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
StringBuffer sbFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String compania = request.getParameter("compania");
String fecha_ini = request.getParameter("fechaini");
String fecha_fin = request.getParameter("fechafin");
String descCaja = request.getParameter("descCaja");

if (appendFilter == null) appendFilter = "";
if(turno==null) turno = "";
if(caja==null) caja = "";
if(compania==null) compania = "";
if(fecha_ini==null) fecha_ini = "";
if(fecha_fin==null) fecha_fin = "";

sbSql.append("select ctp.caja, ctp.turno, r.codigo as recibo, ctp.codigo_paciente, ctp.codigo_empresa empresa, to_char(ctp.fecha_creacion,'dd/mm/yyyy') as fecha, decode(ctp.tipo_cliente,'P','PACIENTE','E','EMPRESA','O','OTROS') as tipo_cliente, ctp.pago_total as monto_pagado, ctp.usuario_creacion as usuario, c.descripcion as nombre_caja, ctp.nombre||decode(ctp.nombre,ctp.nombre_adicional,null,' / '||ctp.nombre_adicional)||decode(ctp.rec_status,'I',' (RECIBO ANULADO)') as nombre, ctp.pac_id, dp.admi_secuencia as admision, getformapagomonto(ctp.compania,ctp.anio,ctp.codigo) as forma_pago_monto, dp.fac_codigo, nvl((select grang_total from tbl_fac_factura where compania = dp.compania and codigo = dp.fac_codigo),0) as monto_factura, nvl(dp.monto,0) as monto_aplicado, nvl(getsaldofactura(ctp.compania,ctp.anio,r.codigo,dp.fac_codigo),0) as saldo, nvl((select pac_id||' - '||admi_secuencia from tbl_fac_factura where compania = dp.compania and codigo = dp.fac_codigo),' ') as noCuenta, ctp.rec_status from tbl_cja_cajas c, tbl_cja_transaccion_pago ctp, tbl_cja_recibos r, tbl_cja_detalle_pago dp where c.compania = ");
sbSql.append(compania);
if(!caja.trim().equals(""))
{
	sbFilter.append(" and ctp.caja=");sbFilter.append(caja);
}
if(!fecha_ini.trim().equals(""))
{
	sbFilter.append(" and ctp.fecha >=to_date('");
	sbFilter.append(fecha_ini);
	sbFilter.append("','dd/mm/yyyy')");
}
if(!fecha_fin.trim().equals(""))
{
	sbFilter.append(" and ctp.fecha <=to_date('");
	sbFilter.append(fecha_fin);
	sbFilter.append("','dd/mm/yyyy')");
}
if(!turno.trim().equals(""))
{
	sbFilter.append(" and ctp.turno=");sbFilter.append(turno);
}
sbSql.append(sbFilter);
sbSql.append(" and dp.monto <> 0 and ctp.compania = c.compania and ctp.caja = c.codigo and r.ctp_anio = ctp.anio and r.compania = ctp.compania and r.ctp_codigo = ctp.codigo and ctp.compania = dp.compania and ctp.anio = dp.tran_anio and ctp.codigo = dp.codigo_transaccion order by ctp.caja, ctp.turno, r.codigo, ctp.pac_id, dp.admi_secuencia");

al = SQLMgr.getDataList(sbSql.toString());
sbSql = new StringBuffer();
sbSql.append("select   ctp.caja, ctp.turno, fp.descripcion, tc.cajero, sum(tfp.monto) monto from tbl_cja_cajas c, tbl_cja_transaccion_pago ctp, tbl_cja_trans_forma_pagos tfp, tbl_cja_forma_pago fp, (select a.codigo turno, b.cod_cajera||' - '||b.nombre cajero,a.compania from tbl_cja_cajera b, tbl_cja_turnos a where a.cja_cajera_cod_cajera = b.cod_cajera and a.compania = b.compania) tc where c.compania=");
sbSql.append(compania);
sbSql.append(sbFilter);
sbSql.append(" and ctp.compania = c.compania and ctp.caja = c.codigo and ctp.codigo = tfp.tran_codigo and ctp.compania = tfp.compania and ctp.anio = tfp.tran_anio and tfp.fp_codigo = fp.codigo and ctp.turno = tc.turno and ctp.compania = tc.compania and ctp.rec_status <> 'I' group by ctp.caja, ctp.turno, fp.descripcion, tc.cajero order by ctp.caja, ctp.turno, fp.descripcion");
al2 = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String time = CmnMgr.getCurrentDate("ddmmyyyyhh12missam");
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+time+".pdf";

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
	String title = "RECIBOS PAGADOS POR CAJA - DETALLADO";
	String subtitle = "Desde:   "+fecha_ini + " Hasta: "+fecha_fin;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


				Vector dHeader=new Vector();
          dHeader.addElement(".15");
          dHeader.addElement(".30");
          dHeader.addElement(".10");
          dHeader.addElement(".15");
          dHeader.addElement(".10");
          dHeader.addElement(".10");
          dHeader.addElement(".10");



	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setNoColumnFixWidth(dHeader);
		pc.addBorderCols("Recibo No / Pac. Id",0,1);
		pc.addBorderCols("Nombre",0,3);
		pc.addBorderCols("Fecha Pago",1,1);
		pc.addBorderCols("Monto Pagado",1,1);
		pc.addBorderCols("Usuario Creacion",1,1);

	pc.setTableHeader(2);



	//table body
	pc.setVAlignment(0);
	String groupBy = "";
	String groupBy2 = "";
	Double monto_fact =0.0, monto_total = 0.00, montoAplicado = 0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("pac_id") + "-" + cdo.getColValue("recibo")))
			{
				if(i!=0)
				{
					pc.addCols("Total Aplicado: ", 2, 5);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(montoAplicado), 2, 1,0.0f,0.5f,0.0f,0.0f);
					pc.addCols(" ", 0,1);
					monto_fact = 0.00;
					montoAplicado= 0.00;
				}
			}
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("caja")+"-"+cdo.getColValue("turno"))){
				pc.setFont(7, 1);
				pc.addBorderCols("CAJA:   "+cdo.getColValue("caja")+"   "+cdo.getColValue("nombre_caja"),0,5,0.5f,0.5f,0.0f,0.0f);
				pc.addBorderCols("TURNO:  "+cdo.getColValue("turno"),0,2,0.5f,0.5f,0.0f,0.0f);
			}
			if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("pac_id") + "-" + cdo.getColValue("recibo")))
			{
				if(cdo.getColValue("rec_status").trim().equals("I"))pc.setFont(7, 0,Color.red);else pc.setFont(7, 0);
				pc.addBorderCols(" "+cdo.getColValue("recibo")+" / "+cdo.getColValue("pac_id"), 0,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(" "+cdo.getColValue("nombre"), 0,3,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(" "+cdo.getColValue("fecha"), 1,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_pagado")), 2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(" "+cdo.getColValue("usuario"), 1,1,0.0f,0.5f,0.0f,0.0f);
				pc.setFont(7, 0);
				pc.addCols("Forma de Pago: "+cdo.getColValue("forma_pago_monto"), 0, dHeader.size());
				pc.setFont(7, 1);
				pc.addCols(" ", 0,1);
				pc.addCols(" ", 0,2);
				pc.addBorderCols("No. Cuenta", 1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Factura", 1,1,0.5f,0.0f,0.0f,0.0f);
				//pc.addBorderCols("Monto Fact.", 1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols("Monto Aplicado", 2,1,0.5f,0.0f,0.0f,0.0f);
				//pc.addBorderCols("Saldo Fact.", 2,1,0.5f,0.0f,0.0f,0.0f);
				pc.addCols(" ", 0,1);
			}
			pc.setFont(7, 0);
			pc.addCols(" ", 0,3);

			pc.addCols(" "+cdo.getColValue("noCuenta"), 1,1);
			pc.addCols(" "+cdo.getColValue("fac_codigo"), 1,1);
			//pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_factura")), 2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_aplicado")), 2,1);
			pc.addCols(" ",2,1);
			//pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")), 2,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

			groupBy = cdo.getColValue("caja")+"-"+cdo.getColValue("turno");
			groupBy2 = cdo.getColValue("pac_id") + "-" + cdo.getColValue("recibo");
			monto_fact += Double.parseDouble(cdo.getColValue("monto_factura"));
			monto_total = Double.parseDouble(cdo.getColValue("monto_pagado"));
			montoAplicado += Double.parseDouble(cdo.getColValue("monto_aplicado"));
	}


	monto_total = 0.00;
	pc.setFont(fontSize, 0);
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
		pc.addCols("Total Aplicado: ", 2, 5);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal(montoAplicado), 2, 1,0.0f,0.5f,0.0f,0.0f);
		pc.addCols("", 0, 1);
		monto_fact = 0.00;
		pc.addBorderCols("TOTAL RESUMIDO",1,dHeader.size(),0.5f,0.5f,0.0f,0.0f);
		String group = "";
		for (int i=0; i<al2.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al2.get(i);
			if(!group.equals(cdo.getColValue("cajero")+"-"+cdo.getColValue("turno"))){
				pc.addBorderCols(cdo.getColValue("turno")+" / "+cdo.getColValue("cajero"),0,7,0.0f,0.5f,0.0f,0.0f);
			}
			pc.addCols(cdo.getColValue("descripcion"),0,2);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
			pc.addCols("",1,4);
			monto_total += Double.parseDouble(cdo.getColValue("monto"));
			group = cdo.getColValue("cajero")+"-"+cdo.getColValue("turno");
		}
		pc.addBorderCols("",0,2,0.0f,0.0f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(monto_total),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("",1,4,0.0f,0.0f,0.0f,0.0f);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>