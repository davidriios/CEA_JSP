<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String tipo_doc = request.getParameter("tipo_doc");
String lib_cheque = request.getParameter("lib_cheque");

if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(tipo_doc==null) tipo_doc="";
if(lib_cheque==null) lib_cheque="";


if (appendFilter == null) appendFilter = "";
if(!fechaini.equals("") && !fechafin.equals("")) appendFilter += " and trunc(fecha_documento) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')";
if(!lib_cheque.equals("")) appendFilter += " and a.libro_cheque = '"+lib_cheque+"' ";

	sql = "select nvl(sum((case when a.lado in ('DB')  then a.monto when a.lado in ('CR') then a.monto * (-1) end)), 0)+nvl((select monto from tbl_con_movim_bancario where tipo_movimiento <= -1 and compania = " + (String) session.getAttribute("_companyId") + " and banco = "+cod_banco +" and cuenta_banco = '"+cuenta_banco+"' and estado_trans='C'), 0) saldo_inicial, b.nombre, c.descripcion from vw_con_mov_banco a, tbl_con_banco b, tbl_con_cuenta_bancaria c where  b.compania = c.compania and b.cod_banco = c.cod_banco and a.cuenta_banco = c.cuenta_banco and a.compania = b.compania and a.cod_banco = b.cod_banco and a.compania = " + (String) session.getAttribute("_companyId") + " and a.cod_banco = '"+cod_banco +"' "+(!fechaini.equals("")?" and a.cuenta_banco = '"+cuenta_banco+"' and trunc(a.fecha_documento) < to_date('"+fechaini+"','dd/mm/yyyy')":"")+" group by b.nombre, c.descripcion";

	cdoSI = SQLMgr.getData(sql);

	if(cdoSI== null) {
	cdoSI = new CommonDataObject();
	sql = "select monto saldo_inicial, (select nombre from tbl_con_banco where compania = a.compania and cod_banco = a.banco) as nombre, (select descripcion from tbl_con_cuenta_bancaria where compania = a.compania and cod_banco = a.banco and cuenta_banco = a.cuenta_banco) as descripcion from tbl_con_movim_bancario a where tipo_movimiento <= -1 and compania = " + (String) session.getAttribute("_companyId") + " and banco = "+cod_banco +" and cuenta_banco = '"+cuenta_banco+"' and estado_trans='C'";

	cdoSI = SQLMgr.getData(sql);
	}
	if(cdoSI== null) {
	cdoSI = new CommonDataObject();
	cdoSI.addColValue("saldo_inicial","0");
	cdoSI.addColValue("nombre","");
	cdoSI.addColValue("descripcion","");

	}

	System.out.println("SQL Inicial=\n"+sql);

	sql = "select a.tipo_doc, a.compania, a.cod_banco, a.anio, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha, a.numero_documento, a.observacion, a.descripcion descripcion_mov, a.monto, decode(a.lado, 'DB', a.monto, 0) debito, decode(a.lado, 'CR', a.monto, 0) credito,a.tipo_doc_desc, a.estado, pref_doc, a.cuenta_banco from vw_con_mov_banco a where a.compania = " + (String) session.getAttribute("_companyId") + " and a.cuenta_banco = '"+cuenta_banco+"' and a.cod_banco = '"+cod_banco +"'  "+appendFilter+(!tipo_doc.equals("")?" and a.tipo_doc = '"+tipo_doc+"'":"")+" order by trunc(a.fecha_documento),  lpad(a.numero_documento,30) /*a.fecha_documento, a.tipo_doc*/";
		al = SQLMgr.getDataList(sql);

		cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sql+")");
	if(cdoT== null) {
	cdoT = new CommonDataObject();
	cdoT.addColValue("debito","0");
	cdoT.addColValue("credito","0");
	}


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
	String title = "BANCOS";
	String subtitle = "MOVIMIENTO BANCARIO";
	String xtraSubtitle = " DESDE "+fechaini+"  HASTA   "+fechafin;;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
			dHeader.addElement(".08");
			dHeader.addElement(".18");
			dHeader.addElement(".07");
			dHeader.addElement(".18");
			dHeader.addElement(".19");
			dHeader.addElement(".08");
			dHeader.addElement(".07");
			dHeader.addElement(".07");
			dHeader.addElement(".08");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);
			pc.addBorderCols("Tipo Doc.",1);
			pc.addBorderCols("DESCRIPCION",0);
			pc.addBorderCols("No. DOC",0);
			pc.addBorderCols("BENEFICIARIO",0);
			pc.addBorderCols("OBSERVACION",0);
			pc.addBorderCols("FECHA",1);
			pc.addBorderCols("DEBITO",0);
			pc.addBorderCols("CREDITO",0);
			pc.addBorderCols("SALDO",1);

			pc.addCols("",1,dHeader.size());

			pc.addCols("BANCO: ",1,1);
			pc.addCols(cdoSI.getColValue("nombre"),0,3);
			pc.addCols("CUENTA BANCARIA: ",1,2);
			pc.addCols(cdoSI.getColValue("descripcion"),0,3);

			pc.addCols("",1,dHeader.size());

			pc.addCols("SALDO INICIAL",2, 6);
			pc.addCols("",2, 2);
			pc.addCols(CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial")),2,1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);
	String groupBy = "";
	double saldo = 0.00;

	if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		saldo += Double.parseDouble(cdo.getColValue("debito"));
		saldo -= Double.parseDouble(cdo.getColValue("credito"));

			pc.addCols(cdo.getColValue("tipo_doc"),1,1);
			pc.addCols(cdo.getColValue("tipo_doc_desc"),0,1);
			pc.addCols(cdo.getColValue("numero_documento"),1,1);
			pc.addCols(cdo.getColValue("descripcion_mov"),0,1);
			pc.addCols(cdo.getColValue("observacion"),0,1);
			pc.addCols(cdo.getColValue("fecha"),1,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("debito")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("credito")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	
	
	pc.addCols(" Total",2,6);
	pc.addCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("debito")),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(cdoT.getColValue("credito")),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(saldo),2,1);

	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
