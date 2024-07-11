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
<!-- Desarrollado por: José A. Acevedo C. -->
<!-- Bancos                               -->
<!-- Reporte: "DEPÓSITOS EN TRÁNSITO"     -->
<!-- Reporte: CB119.rdf                   -->
<!-- Clínica Hospital San Fernando        -->
<!-- Fecha: 13/10/2011                    -->

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
String banco  = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");
String estado = request.getParameter("estado");
String fechaini = request.getParameter("fechaini");

String fg        = request.getParameter("fg");
String vMes = "";

if (banco  == null)   banco    = "";
if (cuenta == null)   cuenta   = "";
if (estado == null)   estado   = "";
if (fechaini == null) fechaini = "";
if (appendFilter == null) appendFilter = "";
if (compania == null) compania = (String) session.getAttribute("_companyId");

//--------------Parámetros--------------------//
if (!compania.equals("")) appendFilter += " and mb.compania = "+compania;
if (!banco.equals(""))    appendFilter += " and mb.banco = '"+banco+"'";
//if (!banco.equals(""))  appendFilter += " and b.cod_banco = '"+banco+"'";
if (!cuenta.equals(""))   appendFilter += " and cb.cuenta_banco = '"+cuenta+"'";
//if (!fechaini.equals("")) appendFilter += " and to_date(to_char(mb.f_movimiento, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";

String appendFilter1 = "";

//------------------------------------------------------------------------------------------------------//
/*--------Query para Obtener los Datos de Depósitos en Tránsito----------------------------------------*/
sql= " select all tm.cod_transac codTransacc, tm.descripcion, mb.consecutivo_ag consecutivo, to_char(mb.f_movimiento,'dd/mm/yyyy') fecha, mb.monto, mb.num_documento numDocto, mb.cuenta_banco cuenta, decode(mb.estado_dep,'DN','DEPOSITADOS','DT','DEPOSITOS EN TRANSITO') status, b.cod_banco codBanco, b.nombre descBanco, cb.descripcion descCuenta from tbl_con_movim_bancario mb, tbl_con_tipo_movimiento tm, tbl_con_banco b, tbl_con_cuenta_bancaria cb where (mb.tipo_movimiento = tm.cod_transac and  mb.compania = b.compania and mb.banco = b.cod_banco and mb.estado_trans = 'T' and cb.cod_banco = mb.banco and cb.compania = mb.compania and cb.cuenta_banco = mb.cuenta_banco and mb.tipo_movimiento = '1') and ((mb.estado_dep = 'DT' and mb.fecha_pago is null) or (mb.estado_dep = 'DN' and to_date(to_char(mb.fecha_pago,'dd/mm/yyyy'),'dd/mm/yyyy') > to_date('"+fechaini+"','dd/mm/yyyy'))) and to_date(to_char(mb.f_movimiento,'dd/mm/yyyy'),'dd/mm/yyyy') <= to_date('"+fechaini+"','dd/mm/yyyy')"+appendFilter+" order by mb.consecutivo_ag ";
al = SQLMgr.getDataList(sql);

sql= " select ' AL '||to_char(to_date('"+fechaini+"','dd/mm/yyyy'),'DD')||' DE '||(rtrim(ltrim(to_char(to_date('"+fechaini+"','dd/mm/yyyy'),'MONTH','NLS_DATE_LANGUAGE = SPANISH'))))||' DEL '||to_char(to_date('"+fechaini+"','dd/mm/yyyy'),'YYYY') fechaConv from dual ";
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
	String xtraCompanyInfo = "BANCOS";
	String title = "DEPARTAMENTO DE CONTABILIDAD";
	String subtitle = "LISTADO DE LOS DEPOSITOS EN TRANSITO";
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

		dHeader.addElement(".25");
		dHeader.addElement(".20");
		dHeader.addElement(".25");
		dHeader.addElement(".30");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(7, 1);
 	pc.addBorderCols("CONSECUTIVO",1,1,Color.lightGray);
	pc.addBorderCols("FECHA",1,1,Color.lightGray);
	pc.addBorderCols("MONTO",1,1,Color.lightGray);
	pc.addBorderCols("No. VOUCHER",1,1,Color.lightGray);

	pc.resetVAlignment();

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//headerHeight =  pc.getTableHeight();

	String groupBy = "";
	double monto = 0, montoTran = 0, montoTranF = 0;

	for (int i=0; i<al.size(); i++)
	{//for-1
       cdo = (CommonDataObject) al.get(i);

	    if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codBanco")))
		 {
		  if (i != 0)  // imprime total por banco
		   {
			 pc.setFont(7, 1);
			 pc.addCols("Total x Banco",1,2);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTran),2,1);
		     pc.addCols(" ",2,1);
			 pc.addCols(" ",0,dHeader.size());
			 montoTran = 0.00;
		   }
			pc.setFont(8, 1);
			pc.addCols("Cuenta: "+cdo.getColValue("descCuenta"),0,dHeader.size());
			pc.addCols("Banco: "+cdo.getColValue("codBanco")+" "+cdo.getColValue("descBanco"),0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
		  }

			montoTran  += Double.parseDouble(cdo.getColValue("monto"));
			montoTranF += Double.parseDouble(cdo.getColValue("monto"));

   		    pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("consecutivo"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))),2,1);
			pc.addCols(" "+cdo.getColValue("numDocto"),1,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		groupBy  = cdo.getColValue("codBanco");

	}//for i-1

	if (al.size() == 0)
	{
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{  //Totales Finales
		pc.setFont(8, 1);
		pc.addCols("Total x Banco",1,2);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(montoTranF),2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addCols(" ",2,1);
		pc.addCols(" ",0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>