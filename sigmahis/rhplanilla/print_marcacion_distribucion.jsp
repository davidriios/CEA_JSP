<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al  = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo  = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania  = (String) session.getAttribute("_companyId");
//String compania = request.getParameter("compania");
String grupo  = request.getParameter("grupo");
String lote = request.getParameter("lote");
String factor = request.getParameter("factor");
String empId = request.getParameter("empId");
//String fecha = request.getParameter("fechaini");
String fechaDesde = request.getParameter("fecha");
String fechaHasta = request.getParameter("fechaHasta");
String fg       = request.getParameter("fg");

if (grupo  == null)   grupo    = "";
if (lote == null)   lote   = "";
if (factor == null) factor = "";
if (empId  == null)   empId    = "";
if (fechaDesde == null)   fechaDesde   = "";
if (fechaHasta == null)   fechaHasta   = "";
if (fg == null) fg = "";
if (appendFilter == null) appendFilter = "";
if (compania == null) compania = (String) session.getAttribute("_companyId");

//--------------Parámetros--------------------//
if (!compania.equals("")) appendFilter += " and d.compania = "+compania;
if (!grupo.equals(""))    appendFilter += " and d.ue_codigo = '"+grupo+"'";
if (!lote.equals(""))   appendFilter += " and d.lote = '"+lote+"'";
if (!factor.equals(""))   appendFilter += " and d.detalle_factor = '"+factor+"'";
if (!empId.equals(""))   appendFilter += " and d.empId = '"+empId+"'";


//------------------------------------------------------------------------------------------------------//
/*--------Query para Obtener los Datos----------------------------------------*/
sql= " select d.ue_codigo as grupo, d.emp_id, d.lote,  to_char(d.fecha, 'dd/mm/yyyy') fecha, d.cod_secuencia, d.codigo_marc_dist, d.marc_secuencia,  d.cantidad, d.factor, round(d.cantidad * d.factor * e.rata_hora, 2) total, d.estado , DECODE(d.estado,'A','APROBADO','P','PENDIENTE','R','REEMPLAZADO') estado_desc , e.rata_hora as rata,  e.nombre_empleado as nombre ,(select descripcion from tbl_pla_ct_grupo where codigo = d.ue_codigo and compania = d.compania) desc_grupo from TBL_PLA_MARC_DIST_DET d , vw_pla_empleado e where d.emp_id = e.emp_id and e.estado = 1 and d.compania = e.compania "+appendFilter+"  order by 1,2,4,9 asc" ;


al = SQLMgr.getDataList(sql);

sql= " select ' DEL '||to_char(to_date('"+fechaDesde+"','dd/mm/yyyy'),'DD')||' DE '||(rtrim(ltrim(to_char(to_date('"+fechaDesde+"','dd/mm/yyyy'),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))))||' DEL '||to_char(to_date('"+fechaDesde+"','dd/mm/yyyy'),'YYYY') || ' HASTA EL '||to_char(to_date('"+fechaHasta+"','dd/mm/yyyy'),'DD')||' DE '||(rtrim(ltrim(to_char(to_date('"+fechaHasta+"','dd/mm/yyyy'),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))))||' DEL '||to_char(to_date('"+fechaHasta+"','dd/mm/yyyy'),'YYYY')    fechaConv from dual ";
cdo1= SQLMgr.getData(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
	String xtraCompanyInfo = "PLANILLA";
	String title = "RECURSOS HUMANOS";
	String subtitle = "LISTADO DE MARCACIONES DISTRIBUIDAS";
	String xtraSubtitle = " "+cdo1.getColValue("fechaConv");

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

	dHeader.addElement(".35");
	dHeader.addElement(".15");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".20");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(7, 1);
 	pc.addBorderCols("NOMBRE EMPLEADO",1,1,Color.lightGray);
	pc.addBorderCols("FECHA DE MARCACION",1,1,Color.lightGray);
	pc.addBorderCols("ESTADO",1,1,Color.lightGray);
	pc.addBorderCols("CANTIDAD",1,1,Color.lightGray);
	pc.addBorderCols("FACTOR",1,1,Color.lightGray);
	pc.addBorderCols("MONTO",1,1,Color.lightGray);

	pc.resetVAlignment();

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//headerHeight =  pc.getTableHeight();

	String groupBy = "",groupBy2="";
	double monto = 0, montoTran = 0, montoTranF = 0,montoCuenta=0;

	for (int i=0; i<al.size(); i++)
	{//for-1
       cdo = (CommonDataObject) al.get(i);

	    if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("grupo")))
		 {
		   
		   
		   if (i != 0)//imprime total por banco
		   {
			
			 if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("grupo")))
			 {
				 pc.setFont(7, 1);
				 pc.addCols("Total x Grupo",1,5);
				 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTran),2,1);
				 pc.addCols(" ",0,dHeader.size());
				 montoTran = 0.00;
			 }
		   }
			pc.setFont(8, 1);
			
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("grupo")))
			pc.addCols("Grupo: "+cdo.getColValue("grupo")+ " - "+cdo.getColValue("desc_grupo") ,0,dHeader.size());
			
			else pc.addCols(" ",0,dHeader.size());
			
		  }
			montoTran   += Double.parseDouble(cdo.getColValue("total"));
			montoTranF  += Double.parseDouble(cdo.getColValue("total"));
			montoCuenta += Double.parseDouble(cdo.getColValue("total"));

   		    pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);
			pc.addCols(" "+cdo.getColValue("estado_desc"),1,1);
			pc.addCols(" "+cdo.getColValue("cantidad"),1,1);
			pc.addCols(" "+cdo.getColValue("factor"),1,1);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("total"))),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		groupBy   = cdo.getColValue("grupo");
	//	groupBy2  = cdo.getColValue("cuenta");

	}//for i-1

	if (al.size() == 0)
	{
		pc.addCols(" ",0,dHeader.size()*3);
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{  
	
	
		pc.addCols("Total x Grupo",1,5);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTran),2,1);
		pc.addCols(" ",0,dHeader.size()); 
		//Totales Finales
		pc.setFont(8, 1);
		pc.addCols("Monto Total",1,5);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(montoTranF),2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addCols(" ",0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>