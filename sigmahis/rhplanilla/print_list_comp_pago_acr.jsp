<%@ page errorPage="../error.jsp"%>
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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String empId = request.getParameter("empId");
String acrId = request.getParameter("acrId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id");  
String compania = (String) session.getAttribute("_companyId");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";

		sql = "select  'N', da.cod_acreedor as codigo, ac.nombre nombre_ac, decode(da.provincia,0,' ',00,' ',11,'B',12,'C',da.provincia)||rpad(decode(da.sigla,'00','  ','0','  ',da.sigla),2,' ')||'-'||lpad(to_char(da.tomo),5,'0')||'-'|| lpad(to_char(da.asiento),6,'0') cedula, e.primer_nombre||' '||e.primer_apellido||' '||decode(e.sexo,'F',decode(e.apellido_casada, null,e.segundo_apellido,'DE '||e.apellido_casada),'M',e.segundo_apellido) nombre_empleado, pa.da_anio,pa.da_cod_planilla, pa.da_num_planilla, p.nombre nombre_planilla, e.num_empleado, d.num_documento,d.saldo, sum(da.monto)  monto_total, decode(nvl(ac.forma_pago,1),'1','Ck.','2','ACH') as pagar from tbl_pla_planilla p, tbl_pla_empleado e, tbl_pla_acreedor ac, tbl_pla_descuento d, tbl_pla_pago_acreedor pa, tbl_pla_descuento_aplicado da where ac.cod_acreedor = da.cod_acreedor and ac.compania = da.cod_compania and p.cod_planilla = pa.da_cod_planilla and p.compania = pa.cod_compania and pa.da_anio = da.anio and pa.da_cod_planilla = da.cod_planilla and pa.da_num_planilla = da.num_planilla and pa.cod_acreedor = da.cod_acreedor and pa.cod_grupo  is null and da.cod_grupo <> 18 and    e.provincia = da.provincia and e.sigla = da.sigla and e.tomo = da.tomo and e.asiento = da.asiento and e.compania = da.cod_compania and d.provincia = da.provincia and d.sigla = da.sigla and d.tomo = da.tomo and d.asiento = da.asiento and d.cod_compania = da.cod_compania and d.num_descuento = da.num_descuento and da.cod_compania = "+(String) session.getAttribute("_companyId")+" and pa.anio = "+anio+" and pa.num_planilla = "+num+" and pa.cod_planilla ="+cod+" and pa.cod_compania = "+(String) session.getAttribute("_companyId")+" and pa.cod_acreedor = "+acrId+" group by 'N',da.cod_acreedor, ac.nombre, decode(da.provincia, 0,' ',00,' ',11,'B',12,'C',da.provincia)||rpad(decode(da.sigla,'00','  ','0','  ',da.sigla),2,' ')||'-'||lpad(to_char(da.tomo),5,'0')||'-'|| lpad(to_char(da.asiento),6,'0'), e.primer_nombre||' '||e.primer_apellido||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.segundo_apellido,'DE '||e.apellido_casada),'M',e.segundo_apellido), pa.da_anio,pa.da_cod_planilla,pa.da_num_planilla,p.nombre,e.num_empleado, d.num_documento, d.saldo, decode(nvl(ac.forma_pago,1),'1','Ck.','2','ACH')  having   sum(da.monto) <> 0"; 
 al = SQLMgr.getDataList(sql);
 
 	CommonDataObject cdTot = SQLMgr.getData("select codigo,nombre_ac,num_documento,sum(monto_total)  total from ("+sql+") group by codigo,nombre_ac,num_documento");


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";
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
	String title = "PLANILLA";
	String subtitle = "COMPROBANTE DE PAGO A ACREEDOR";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".25");
		dHeader.addElement(".10");	
		dHeader.addElement(".15");
		dHeader.addElement(".20");
		dHeader.addElement(".05");	
		dHeader.addElement(".15");
		dHeader.addElement(".10");	
	
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

 		//second row
		pc.addBorderCols("",0,1);
		pc.addBorderCols(""+cdTot.getColValue("nombre_ac"),1,4);
		pc.addBorderCols("",0,2);
		
		pc.addBorderCols("# de Acreedor  : "+cdTot.getColValue("codigo"),1,1);
		pc.addBorderCols(" Monto Pagado : "+CmnMgr.getFormattedDecimal(cdTot.getColValue("total")),1,4);													
		pc.addBorderCols("# Cheque  : "+cdTot.getColValue("num_documento"),1,2);
 
 		pc.setFont(7, 1);					
		pc.addCols("", 0,7);
		
		pc.addCols("Cédula. ",0,1);
		pc.addCols("Nombre del Empleado ",0,2);													
		pc.addCols("No. Emp.",1,2);
		pc.addCols("Saldo ",2,1);
		pc.addCols("Monto ",2,1);		
 	
		pc.setTableHeader(5);//create de table header (2 rows) and add header to the table
	
	double total=0.00;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);    	
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		 
		pc.addCols(""+cdo.getColValue("cedula"),0,1);
		pc.addCols(""+cdo.getColValue("nombre_empleado"),0,2);													
		pc.addCols(""+cdo.getColValue("num_empleado"),1,2);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);		
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_total")),2,1);					
	  			
		total += Double.parseDouble(cdo.getColValue("monto_total"));
			
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
		
	if (al.size() == 0)pc.addCols("No existen registros",1,dHeader.size());
	else 
	{
		pc.setFont(7, 1);
	    pc.addCols(al.size()+" Registros en total",0,4);
	    pc.addCols(" Total Pagado : "+CmnMgr.getFormattedDecimal(total),2,3);
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>