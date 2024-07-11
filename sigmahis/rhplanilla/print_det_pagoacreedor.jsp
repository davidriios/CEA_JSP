<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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

**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList tot = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fp = request.getParameter("fp");
String userName = UserDet.getUserName();
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
CommonDataObject cdo2 = null;


if (appendFilter == null) appendFilter = "";

sql = "select b.nombre as nombre, g.nombre as nomAcreedor, d.monto, to_char(d.comision,'999,990.00') as comision, to_char(a.fecha_pago,'dd-mm-yyyy') as fechaPago, ltrim(b.nombre,18)||' Descuentos Aplicados del '||to_char(a.fecha_inicial,'dd/mm/yyyy')||' al '||to_char(a.fecha_final,'dd/mm/yyyy') as descripcion, d.cod_planilla as codPlanilla, d.num_planilla as numPlanilla, d.anio, d.num_cheque as cheque, g.cod_acreedor as codigo from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_pla_pago_acreedor d, tbl_pla_acreedor g where  a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and  a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania  and d.cod_acreedor = g.cod_acreedor and d.cod_compania = g.compania"+appendFilter+" order by g.nombre";
al = SQLMgr.getDataList(sql);



sql = "select count(*)  as count, to_char(sum(d.monto),'999,990.00') as totmonto, to_char(sum(d.comision),'999,990.00') as totcomision, g.cod_acreedor as codigo from tbl_pla_planilla_encabezado a, tbl_pla_planilla b, tbl_pla_pago_acreedor d, tbl_pla_acreedor g where  a.cod_planilla = b.cod_planilla and a.cod_compania = b.compania and  a.anio = d.anio and a.cod_planilla = d.cod_planilla and d.anio = "+anio+" and d.num_planilla = "+num+" and d.cod_planilla = "+cod+" and a.num_planilla = d.num_planilla and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.cod_compania = d.cod_compania and d.cod_acreedor = g.cod_acreedor and d.cod_compania = g.compania"+appendFilter+" group by g.cod_acreedor";
tot =SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String montoTotal = "";
	
	Hashtable htUni = new Hashtable();

	for (int i=0; i<tot.size(); i++)
	{
		CommonDataObject cdo1 = (CommonDataObject) tot.get(i);

		htUni.put(cdo1.getColValue("codigo"),cdo1);
			
	}
	
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
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = "PLANILLA DE ACREEDORES";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".50");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
		

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Acreedor",1);
		pc.addBorderCols("Nombre del Acreedor",1);
		pc.addBorderCols("Monto",2);
		pc.addBorderCols("Num. Cheque",1);
		
				
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
    String acr = "";
	String totalAcr = "";
	double totAcr = 0.00;
	int cont=0;
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		/*if (!acr.equalsIgnoreCase(cdo.getColValue("codigo")))
		{
			if (i!=0)
			{
				pc.setFont(7, 0);
				pc.setVAlignment(0);
				cdo2 = (CommonDataObject) htUni.get(acr);
				pc.addCols(" TOTALES POR PROVEEDOR :    "+cdo2.getColValue("totmonto"),0,dHeader.size());
				acr =  cdo.getColValue("codigo");
				
				pc.setFont(7, 0);
				pc.addCols("",0,dHeader.size());
			}else 
			{
				pc.addCols("  "+cdo.getColValue("descripcion"),1,dHeader.size());
			}
		}*/
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("codigo"),1,1);
		pc.addCols(cdo.getColValue("nomAcreedor"),0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		pc.addCols(cdo.getColValue("cheque"),1,1);
		acr =  cdo.getColValue("codigo");
		cont = cont	+ 1;
      //  montoTotal += cdo.getColValue("monto");
		totAcr += Double.parseDouble(cdo.getColValue("monto"));

		
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	
	pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());
	
	/*pc.setFont(7, 0);
		pc.setVAlignment(0);
		cdo2 = (CommonDataObject) htUni.get(acr);
		
		pc.addCols(" TOTALES POR PROVEEDOR :    "+cdo2.getColValue("totmonto"),0,dHeader.size());
		
		pc.addCols("----------------",2,3);
		pc.addCols(" ",0,1);
		totalAcr += cdo2.getColValue("totmonto");*/
		//pc.addTable();
	
	
	pc.addCols(al.size()+"   Acreedor(es)                        TOTAL FINAL         "+"  ======>   "+CmnMgr.getFormattedDecimal(""+totAcr),2,3);
	pc.addCols(" ",0,1);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>