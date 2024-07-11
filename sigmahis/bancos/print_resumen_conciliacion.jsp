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
ArrayList alCr = new ArrayList();
ArrayList alDb = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoDb = new CommonDataObject();
CommonDataObject cdoCr = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String banco = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");
String nombre = request.getParameter("nombre");
String fp = request.getParameter("fp");
String compania =  (String) session.getAttribute("_companyId");

String anio = request.getParameter("anio");
String mes = request.getParameter("mes");

CommonDataObject cdoP = SQLMgr.getData("select get_sec_comp_param("+compania+",'CT_CONCIL_REP') as ctrlConcilRep from dual");
if (cdoP==null) cdoP = new CommonDataObject();
String ctrlConcilRep = cdoP.getColValue("ctrlConcilRep","N");

if (appendFilter == null) appendFilter = "";
if (fp == null) fp = "";

sql= "SELECT a.*, '01'||' Al '||to_char (last_day(to_date('"+mes+"/"+anio+"','mm/yyyy')),'DD')||' de '||lower(to_char(to_date('"+mes+"','mm'),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))||' del '||"+anio+" fecha, to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')-1),'dd') || ' de ' || lower(to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')-1),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))||' del '||to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')-1),'yyyy') fecha_anterior, to_char (last_day(to_date('"+mes+"/"+anio+"','mm/yyyy')),'DD')||' de '||lower(to_char(to_date('"+mes+"','mm'),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))||' del '||"+anio+" fecha_hasta from (select tipo_movimiento tipo, decode(tipo_movimiento, 'CR', 'Nota de Credito', 'DB', 'Nota de Debito', descripcion) nombre_movimiento, sum(monto) monto from tbl_con_temp_detalle_conci where cod_banco = '"+banco+"' and compania = "+(String) session.getAttribute("_companyId")+" and anio = "+anio+" and mes = "+mes+" and cuenta = '"+cuenta+"' group by tipo_movimiento, decode(tipo_movimiento, 'CR', 'Nota de Credito', 'DB', 'Nota de Debito', descripcion)) a";
al = SQLMgr.getDataList(sql);

sql ="select codigo, tipo_movimiento tipo,  descripcion nombre_movimiento, sum(monto) monto from tbl_con_temp_detalle_conci where cod_banco = '"+banco+"' and compania ="+session.getAttribute("_companyId")+" and anio ="+anio+" and mes =to_number('"+mes+"') and cuenta = '"+cuenta+"' and tipo_movimiento = 'DB' group by codigo, tipo_movimiento,  descripcion  having sum(monto) <> 0 order by codigo";
alDb = SQLMgr.getDataList(sql);

sql ="select codigo, tipo_movimiento tipo,  descripcion nombre_movimiento, sum(monto) monto from tbl_con_temp_detalle_conci where cod_banco = '"+banco+"' and compania ="+session.getAttribute("_companyId")+" and anio ="+anio+" and mes =to_number('"+mes+"') and cuenta = '"+cuenta+"' and tipo_movimiento = 'CR' group by codigo, tipo_movimiento,  descripcion  having sum(monto) <> 0 order by codigo";
alCr = SQLMgr.getDataList(sql);

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
	String title = "DIRECCION DE FINANZAS";
	String subtitle = "DEPARTAMENTO DE CONTABILIDAD";
	String xtraSubtitle = "CONCILIACION BANCARIA";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 9;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	
	dHeader.addElement(".20");
	dHeader.addElement(".20");
	dHeader.addElement(".20");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	//second row
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	
	pc.setFont(7, 1);
		
		
	//table body
	pc.setVAlignment(0);
	 CommonDataObject cdo2 = new CommonDataObject();
	 CommonDataObject cdo3 = new CommonDataObject();
	 double monto = 0.00;
	 double montoDb = 0.00;
	 double montoBk = 0.00;
	 double saldoLibro = 0.00;
	 double saldoBanco = 0.00;
	 double cero = 0.00;
	
	for (int i=0; i<al.size(); i++)
	{
		cdo1 = (CommonDataObject) al.get(i);

		cdo2.addColValue(cdo1.getColValue("tipo"),cdo1.getColValue("monto"));
		cdo3.addColValue(cdo1.getColValue("tipo"),cdo1.getColValue("nombre_movimiento"));
	}
	
	pc.setFont(9, 1);
	pc.addCols("BANCO :     "+nombre,0,dHeader.size());
	pc.addCols("CUENTA:     "+cuenta,0,dHeader.size());
	pc.addCols("Fecha :     "+fecha,0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
	
	pc.setFont(9, 5);
	pc.addCols("Conciliación Bancaria del :",1,dHeader.size());
	pc.setFont(9, 1);
	pc.addCols(" "+cdo1.getColValue("fecha"),1,dHeader.size());
	
	//if(cdo.getColValue("mes").equals()"1") cdo1.addColValue("fecha_inicio")
	
		pc.setFont(9, 5);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("LIBRO  ",0,dHeader.size());
		
		pc.setFont(8, 1);
		pc.addCols("Saldo según Libro al :     "+cdo1.getColValue("fecha_anterior"),0,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("SI")),2,2);
	 	pc.addCols(" ",0,1);
		
		pc.setFont(8, 2);
		pc.addCols("Más ",0,dHeader.size());
		
		pc.setFont(8, 0);
		pc.addCols("Depósitos del mes      ",0,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("DP")),2,2);
	 	pc.addCols(" ",0,1);
		
		// desglose de las transacciones por NC
		for (int i=0; i<alDb.size(); i++)
		{
			cdoCr = (CommonDataObject) alDb.get(i);
			pc.addCols(cdoCr.getColValue("nombre_movimiento"),0,2);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoCr.getColValue("monto")),2,2);
		 	pc.addCols(" ",0,2);	
		}
		
		monto += Double.parseDouble(cdo2.getColValue("DB")) + Double.parseDouble(cdo2.getColValue("BA")) ;
		//pc.addCols(""+cdo3.getColValue("CR"),0,2);
		//pc.addCols(" "+CmnMgr.getFormattedDecimal(monto),2,1);
	 	//pc.addCols(" ",0,3);
		
		if (ctrlConcilRep.trim().equals("N")) pc.addCols("Total Notas Débito  ",2,3);
		else  pc.addCols("Total Notas Crédito  ",2,3);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("DB")),2,1,1.0f,1.0f,0.0f,0.0f);
	 	pc.addCols(" ",0,2);
		
		monto +=  Double.parseDouble(cdo2.getColValue("DP")) + Double.parseDouble(cdo2.getColValue("SI")) ;
		pc.addCols(" ",0,2);
		pc.addCols(" Sub Total  ",1,2);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(monto),2,1,1.0f,0.0f,0.0f,0.0f);
	 	pc.addCols(" ",0,1);
		
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(8, 2);
		pc.addCols("Menos ",0,dHeader.size());
		
		pc.setFont(8, 0);
		pc.addCols("Cheques Girados en el mes      ",0,4);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("CG")),2,1,1.0f,0.0f,0.0f,0.0f);
	 	pc.addCols(" ",0,1);

		// desglose de las transacciones por NC
		pc.setFont(8, 0);
		for (int i=0; i<alCr.size(); i++)
		{
			cdoDb = (CommonDataObject) alCr.get(i);
			pc.addCols(cdoDb.getColValue("nombre_movimiento"),0,2);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoDb.getColValue("monto")),2,2);
		 	pc.addCols(" ",0,2);	
		}

		//pc.addCols(""+cdo3.getColValue("DB"),0,2);
		//pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("DB")),2,1);
	 	//pc.addCols(" ",0,3);
		
		if (ctrlConcilRep.trim().equals("N")) pc.addCols("Total Notas Crédito  ",2,3);
		else  pc.addCols("Total Notas Débito  ",2,3);
		
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("CR")),2,1,1.0f,1.0f,0.0f,0.0f);
	 	pc.addCols(" ",0,2);
		
		montoDb +=  Double.parseDouble(cdo2.getColValue("CR")) + Double.parseDouble(cdo2.getColValue("CG")) + Double.parseDouble(cdo2.getColValue("LB")) ;
		pc.addCols(" ",0,2);
		pc.addCols(" Sub Total  ",1,2);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(montoDb),2,1,1.0f,0.0f,0.0f,0.0f);
	 	pc.addCols(" ",0,1);
		
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		
		saldoLibro += monto - montoDb;
		pc.setFont(8, 1);
		pc.addCols("  Saldo según Libros     ",0,4);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(saldoLibro),2,1,Color.lightGray);
		pc.addCols(" ",0,1);
		
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(9, 5);
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("BANCO  ",0,dHeader.size());
		
		pc.setFont(8, 0);
		pc.addCols("Saldo segun Banco al :     "+cdo1.getColValue("fecha_hasta"),0,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("SB")),2,2);
	 	pc.addCols(" ",0,1);
		
		pc.setFont(8, 2);
		pc.addCols("Más ",0,dHeader.size());
		
		pc.setFont(8, 0);
		pc.addCols("Depósitos en Tránsito      ",0,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("DT")),2,2);
	 	pc.addCols(" ",0,1);
		
		montoBk += Double.parseDouble(cdo2.getColValue("DT")) + Double.parseDouble(cdo2.getColValue("SB"))  ;
		
		pc.addCols(" ",0,2);
		pc.addCols(" Sub Total  ",1,2);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(montoBk),2,1,0.0f,1.0f,0.0f,0.0f);
	 	pc.addCols(" ",0,1);
		
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(8, 2);
		pc.addCols("Menos ",0,dHeader.size());
		
		pc.setFont(8, 0);
		pc.addCols("Cheques en Circulación      ",0,3);
		if (cdo2.getColValue("RC")!=null && !cdo2.getColValue("RC").equals(""))
		pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo2.getColValue("RC")),2,2);
		else pc.addCols(" "+CmnMgr.getFormattedDecimal(cero),2,2);
	 	pc.addCols(" ",0,1);
		
		if (cdo2.getColValue("RC")!=null && !cdo2.getColValue("RC").equals(""))
			saldoBanco += montoBk - Double.parseDouble(cdo2.getColValue("RC"));
		else saldoBanco += montoBk;
		pc.addCols("  Saldo igual a nuestros Libros al :     "+cdo1.getColValue("fecha_hasta"),0,6);
		
		
		pc.setFont(8, 1);
		pc.addCols("  ",0,4);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(saldoBanco),2,1,Color.lightGray);
		pc.addCols(" ",0,1);
		
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		
		pc.setFont(6, 1);
		pc.addCols(" CONFECCIONADO POR:  ",0,1);
		pc.addCols(" ",0,1);
		pc.addCols(" REVISADO POR:  ",0,1);
		pc.addCols("  ",0,3);
		
		pc.addCols(" ",0,dHeader.size());
		pc.addBorderCols(" ",0,1,0.5f, 0.0f, 0.0f, 0.0f);
		pc.addCols(" ",0,1);
		pc.addBorderCols(" ",0,1,0.5f, 0.0f, 0.0f, 0.0f);
		pc.addCols(" ",0,3);
	
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>