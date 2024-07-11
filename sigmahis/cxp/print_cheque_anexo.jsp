<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String tableH = "tbl_con_temp_cheque", tableD = "tbl_con_temp_detalle_cheque";

if (fp == null) fp = "";
if (fp.equalsIgnoreCase("cheque"))
{
	tableH = "tbl_con_cheque";
	tableD = "tbl_con_detalle_cheque";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	int fontSize = 10;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ANEXO DE CHEQUE";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".15");
		dHeader.addElement(".40");
		dHeader.addElement(".15");
		dHeader.addElement(".15");

	for (Enumeration e = iAnexo.keys(); e.hasMoreElements();)
	{
		CommonDataObject cdo = (CommonDataObject) iAnexo.get((String) e.nextElement());
		String ckDateFormat = "ddmmyyyy";
		if (cdo.getColValue("fecha_emision").indexOf("-") >= 0) ckDateFormat = "dd-mm-yyyy";
		else if (cdo.getColValue("fecha_emision").indexOf("/") >= 0) ckDateFormat = "dd/mm/yyyy";

		//table header
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			//first row
			pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(fontSize,1);
			pc.addCols("CHEQUE:",0,1);
			pc.addCols(cdo.getColValue("num_cheque"),0,1);
			pc.addCols(cdo.getColValue("beneficiario"),0,1);
			pc.addCols("MONTO:",2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto_girado")),2,1);

			pc.addCols("FECHA:",0,1);
			pc.addCols((ckDateFormat.equals("ddmmyyyy"))?cdo.getColValue("fecha_emision").substring(0,2)+"/"+cdo.getColValue("fecha_emision").substring(2,4)+"/"+cdo.getColValue("fecha_emision").substring(4):cdo.getColValue("fecha_emision"),0,1);
			pc.addCols(" ",0,1);
			pc.addCols("VIENEN:",2,1);
			pc.addCols(cdo.getColValue("total_printed"),2,1);

			pc.addBorderCols("Descripción",1,3);
			pc.addBorderCols("Cuenta",1);
			pc.addBorderCols("Monto",1);
		pc.setTableHeader(4);

		if (cdo.getSql() != null && cdo.getSql().length() > 0) {
			al = SQLMgr.getDataList(cdo.getSql());
		//} else {
			sbSql = new StringBuffer();
			sbSql.append("SELECT a.*, ROWNUM ");
			//sbSql.append(cdo.getColValue("renglon"));
			sbSql.append(" num_renglon FROM (select SUM (dck.monto_renglon) monto_renglon, dck.cuenta1||dck.cuenta2||dck.cuenta3||dck.cuenta4 as cuenta, dck.descripcion, dck.descripcion||decode('");
		sbSql.append(cdo.getColValue("tipoOp"));
		sbSql.append("','H', (select (select ' - '||nombre_paciente from vw_adm_paciente where pac_id = z.pac_id) from tbl_fac_factura z where codigo = dck.num_factura and compania = ck.cod_compania),' ') descCuenta, dck.num_factura from ");
			sbSql.append(tableH);
			sbSql.append(" ck, ");
			sbSql.append(tableD);
			sbSql.append(" dck where /*dck.imprimir = 'N' and *//*ck.che_user = '");
			sbSql.append(userName);
			sbSql.append("' and */dck.cuenta_banco = ck.cuenta_banco and dck.cod_banco = ck.cod_banco and dck.compania = ck.cod_compania and dck.num_cheque = ck.num_cheque and ck.num_cheque = '");
			sbSql.append(cdo.getColValue("num_cheque"));
			sbSql.append("' and ck.cod_compania = ");
			sbSql.append(cdo.getColValue("cod_compania"));
			sbSql.append(" and ck.cod_banco = '");
			sbSql.append(cdo.getColValue("cod_banco"));
			sbSql.append("' and ck.cuenta_banco = '");
			sbSql.append(cdo.getColValue("cuenta_banco"));
			sbSql.append("' and ck.f_emision >= to_date('");
			sbSql.append(cdo.getColValue("fecha_emision"));
			sbSql.append("','");
			sbSql.append(ckDateFormat);
			sbSql.append("') and ck.tipo_pago != 2");
			//sbSql.append(" and dck.num_renglon > ");
			//sbSql.append(cdo.getColValue("renglon"));
			sbSql.append(" GROUP BY dck.cuenta1 || dck.cuenta2 || dck.cuenta3 || dck.cuenta4, dck.descripcion, dck.num_factura, ck.cod_compania HAVING SUM (dck.monto_renglon) > 0 order by dck.num_factura) a");
			//al = SQLMgr.getDataList(sbSql.toString());
		}
		
		Double total_anexo = 0.00;
       
		//table body
		int renglon = Integer.parseInt(cdo.getColValue("renglon"));
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdoDet = (CommonDataObject) al.get(i);
			if( Integer.parseInt(cdoDet.getColValue("num_renglon"))> renglon){

			pc.setFont(fontSize,0);
			pc.setVAlignment(0);
			pc.addCols(cdoDet.getColValue("descCuenta"),0,3);
			pc.addCols(cdoDet.getColValue("cuenta"),0,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdoDet.getColValue("monto_renglon")),2,1);
			total_anexo +=  Double.parseDouble(cdoDet.getColValue("monto_renglon"));
			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
			}
		}//i
		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else
		{
			pc.addCols("Total Anexo:",2,dHeader.size() - 1);
			pc.addCols(cdo.getColValue("anexo_amt"),2,1);
		}

		if (cdo.getColValue("show_fact") != null && cdo.getColValue("show_fact").equals("1")) {

			sbSql = new StringBuffer();
			sbSql.append("select join(cursor(select distinct num_factura from ");
			sbSql.append(tableD);
			sbSql.append(" where num_cheque = '");
			sbSql.append(cdo.getColValue("num_cheque"));
			sbSql.append("' and cod_banco = '");
			sbSql.append(cdo.getColValue("cod_banco"));
			sbSql.append("' and compania = ");
			sbSql.append(cdo.getColValue("cod_compania"));
			sbSql.append(" and cuenta_banco = '");
			sbSql.append(cdo.getColValue("cuenta_banco"));
			sbSql.append("'),', ') as factura from dual");
			CommonDataObject cdoFact = SQLMgr.getData(sbSql.toString());
			pc.addCols(" ",0,dHeader.size());
			pc.addCols("PARA CANCELAR FACTURA(S) NO. "+cdoFact.getColValue("factura"),0,dHeader.size());

		}
		pc.flushTableBody(true);
		pc.addNewPage();
	}//j
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>