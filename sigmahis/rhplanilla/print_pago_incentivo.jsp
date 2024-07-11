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
String fechaTrx = request.getParameter("fecha"); 
String anio = request.getParameter("anio");
String quinc = request.getParameter("quinc");
String cod = request.getParameter("cod");
String trimestre = request.getParameter("trimestre");

String mes1 = ""; 
String mes2 = "";
String mes3 = "";
String subTitle = "";
String mes = fechaTrx.substring(4, 6);

CommonDataObject cdo2 = null;
if (fp == null) fp="";

Hashtable _mes = new Hashtable();

if (mes != null )
{
  _mes.put("01","ENERO");
  _mes.put("02","FEBRERO");
  _mes.put("03","MARZO");
  _mes.put("04","ABRIL");
  _mes.put("05","MAYO");
  _mes.put("06","JUNIO");
  _mes.put("07","JULIO");
  _mes.put("08","AGOSTO");
  _mes.put("09","SEPTIEMBRE");
  _mes.put("10","OCTUBRE");
  _mes.put("11","NOVIEMBRE");
  _mes.put("12","DICIEMBRE");
 }

if (appendFilter == null) appendFilter = "";

sql = "SELECT ALL d.cedula1 cedula, d.nombre_empleado nombre, d.num_empleado, d.num_ssocial, d.num_dependiente, d.salario_base, d.rata_hora, d.tipo_renta, d.valor_renta, d.gasto_rep, NVL(a.monto,0) monto, to_char(a.fecha,'dd/mm/yyyy') fecha, a.tipo_trx, '[ '||b.codigo||' ] '||b.descripcion descTrx, c.nombre planilla, e.descripcion, nvl(d.ubic_seccion,d.seccion) unidad FROM VW_PLA_EMPLEADO d, tbl_pla_transac_emp a , tbl_pla_tipo_transaccion b, tbl_pla_planilla c, tbl_sec_unidad_ejec e WHERE a.anio_pago = "+anio+" and a.quincena_pago = "+quinc+" and a.cod_planilla_pago = "+cod+" and d.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and d.emp_id = a.emp_id and d.compania = a.compania and a.tipo_trx = b.codigo and a.compania = b.compania and a.vobo_estado = 'N' and a.compania = c.compania and a.cod_planilla_pago = c.cod_planilla and a.compania = e.compania and nvl(d.ubic_seccion,d.seccion) = e.codigo ORDER BY d.ubic_seccion, d.nombre_empleado,  a.tipo_trx, to_number(d.num_empleado)";
al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
		
	Hashtable htUni = new Hashtable();
	
	cdo2 = (CommonDataObject) al.get(0);
	subTitle = cdo2.getColValue("planilla");
	
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

	float height = 72 * 8.5f;//612height
	float width = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "TRANSACCIONES EN LOTE GENERADAS";
	String subtitle = "APLICABLE A "+subTitle+" PARA EL MES DE "+_mes.get(mes)+" DE "+anio ;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".35");
		dHeader.addElement(".10");
		dHeader.addElement(".25");
		dHeader.addElement(".10");

		//table header
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		pc.addBorderCols("No. EMPLEADO",0,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("CÉDULA",1,1,1.5f,1.5f,0.0f,0.0f);
		pc.addBorderCols("NOMBRE DEL EMPLEADO",0,1,1.5f,1.5f,0.0f,0.0f);	
		pc.addBorderCols("FECHA",1,1,1.5f,1.5f,0.0f,0.0f);	
		pc.addBorderCols("TIPO DE TRANSACCION",1,1,1.5f,1.5f,0.0f,0.0f);	
		pc.addBorderCols("MONTO",2,1,1.5f,1.5f,0.0f,0.0f);	
		
		pc.addCols("",0,dHeader.size());
			
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
    
		//table body
		double totSalarios = 0.00;
		double totUnidad = 0.00;
		int contUnidad = 0;
		String unidad = "";
		
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
				if (!unidad.equalsIgnoreCase(cdo.getColValue("unidad")))
				{
				if(i!=0)
				{
				pc.addCols("",0,4);
				pc.addCols("  TOTAL  X  UNIDAD   ==>  . . .  "+contUnidad,1,1);
				pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totUnidad),2,1,0.0f,1.0f,0.0f,0.0f);
				
				totUnidad =0.00;
				contUnidad =0;
				}
				pc.setFont(8, 0);
				pc.setVAlignment(0);
				pc.addCols("UNIDAD ADMINISTRATIVA  :   "+cdo.getColValue("unidad"),0,2);
				pc.addCols(cdo.getColValue("descripcion"),0,4);
				}
		pc.setFont(8, 0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("num_empleado"),0,1);
		pc.addCols(cdo.getColValue("cedula"),0,1);
		pc.addCols(cdo.getColValue("nombre"),0,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("descTrx"),0,1);
		pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		
		 totSalarios += Double.parseDouble(cdo.getColValue("monto"));	
		 totUnidad += Double.parseDouble(cdo.getColValue("monto"));	
		 unidad = cdo.getColValue("unidad");
		 contUnidad += 1;
		
				
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
	pc.addCols("",0,4);
	pc.addCols("  TOTAL  X  UNIDAD   ==>  . . .  "+contUnidad,1,1);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totUnidad),2,1,0.0f,1.0f,0.0f,0.0f);
	
	pc.addCols("",0,6);
 	pc.setFont(8, 1);
	pc.addCols(" ",0,4);
	pc.addCols("TOTAL DE EMPLEADOS ==> "+" . . . "+al.size(),1,1);
	pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totSalarios),2,1,0.0f,1.0f,0.0f,0.0f);
	}
  	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>