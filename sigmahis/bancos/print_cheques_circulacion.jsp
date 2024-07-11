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
<!-- Reporte: "CHEQUES EN CIRCULACIÓN"    -->
<!-- Reporte: CB126.rdf                   -->
<!-- Clínica Hospital San Fernando        -->
<!-- Fecha: 14/10/2011                    -->

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
String fechaini = request.getParameter("fechaini");
String fg       = request.getParameter("fg");

if (banco  == null)   banco    = "";
if (cuenta == null)   cuenta   = "";
if (fechaini == null) fechaini = "";
if (appendFilter == null) appendFilter = "";
if (compania == null) compania = (String) session.getAttribute("_companyId");

//--------------Parámetros--------------------//
if (!compania.equals("")) appendFilter += " and ch.cod_compania = "+compania;
if (!banco.equals(""))    appendFilter += " and ch.cod_banco = '"+banco+"'";
if (!cuenta.equals(""))   appendFilter += " and ch.cuenta_banco = '"+cuenta+"'";

String appendFilter1 = "";
if (appendFilter1 == null) appendFilter1 = "";
if (!compania.equals("")) appendFilter1 += " and ch.compania = "+compania;
if (!banco.equals(""))    appendFilter1 += " and ch.cod_banco = '"+banco+"'";
if (!cuenta.equals(""))   appendFilter1 += " and ch.cuenta_banco = '"+cuenta+"'";

//------------------------------------------------------------------------------------------------------//
/*--------Query para Obtener los Datos de Cheques en Circulación----------------------------------------*/
sql= " select all ch.num_cheque cheque, ch.beneficiario benef, ch.monto_girado monto, to_char(ch.f_emision,'dd/mm/yyyy') fechaEmision, to_char(ch.che_date,'dd/mm/yyyy') fechaCk, ch.tipo_pago tipoPago, ch.cod_banco codBanco, b.nombre descBanco, cb.descripcion descCuenta,ch.cuenta_banco as cuenta from tbl_con_cheque ch, tbl_con_banco b, tbl_con_cuenta_bancaria cb where ch.tipo_pago in(1,2,3) "+appendFilter+" and (trunc(ch.f_pago_banco) > to_date('"+fechaini+"','dd/mm/yyyy') or ch.f_pago_banco is null) and ((ch.f_anulacion is null or trunc(ch.f_anulacion) > to_date('"+fechaini+"','dd/mm/yyyy'))) and ((ch.fecha_anulacion_anual is null or trunc(ch.fecha_anulacion_anual) > to_date('"+fechaini+"','dd/mm/yyyy'))) and trunc(ch.f_emision) <= to_date('"+fechaini+"','dd/mm/yyyy') and (ch.cod_compania = b.compania and ch.cod_banco = b.cod_banco and ch.cod_compania = cb.compania and ch.cod_banco = cb.cod_banco and ch.cuenta_banco = cb.cuenta_banco)  union select  x.num_documento num_cheque, x.descripcion benef, x.monto, to_char(x.f_movimiento,'dd/mm/yyyy') fechaEmision, to_char(x.f_movimiento,'dd/mm/yyyy') fechaCk, to_number(x.tipo_movimiento) tipoPago, x.banco codBanco,b.nombre descBanco, ch.descripcion descCuenta,x.cuenta_banco as cuenta from tbl_con_movim_bancario x , tbl_con_banco b, tbl_con_cuenta_bancaria ch  where x.compania = b.compania and x.banco = b.cod_banco and x.cuenta_banco = ch.cuenta_banco and x.compania = ch.compania and ch.cod_banco = b.cod_banco and b.compania = ch.compania "+appendFilter1+" and x.tipo_movimiento = '5'  and x.estado_trans = 'T' and ((x.estado_dep = 'DT' and x.fecha_pago is null) or (x.estado_dep = 'DN' and trunc(x.fecha_pago) > to_date('"+fechaini+"','dd/mm/yyyy'))) and trunc(x.f_movimiento) < to_date('"+fechaini+"','dd/mm/yyyy') order by 7 asc ,10 asc,6,1";
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
	String subtitle = "LISTADO DE CHEQUES EN CIRCULACIÓN";
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

	dHeader.addElement(".15");
	dHeader.addElement(".15");
	dHeader.addElement(".15");
	dHeader.addElement(".37");
	dHeader.addElement(".18");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(7, 1);
 	pc.addBorderCols("NÚMERO DE CHEQUE",1,1,Color.lightGray);
	pc.addBorderCols("FECHA DE EMISIÓN",1,1,Color.lightGray);
	pc.addBorderCols("FECHA DE CREACIÓN",1,1,Color.lightGray);
	pc.addBorderCols("BENEFICIARIO",1,1,Color.lightGray);
	pc.addBorderCols("MONTO GIRADO",1,1,Color.lightGray);

	pc.resetVAlignment();

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//headerHeight =  pc.getTableHeight();

	String groupBy = "",groupBy2="";
	double monto = 0, montoTran = 0, montoTranF = 0,montoCuenta=0;

	for (int i=0; i<al.size(); i++)
	{//for-1
       cdo = (CommonDataObject) al.get(i);

	    if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codBanco"))||!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("cuenta")))
		 {
		   
		   
		   if (i != 0)//imprime total por banco
		   {
			 if (!groupBy2.trim().equalsIgnoreCase(cdo.getColValue("cuenta")))
			 {
				 pc.setFont(7, 1);
				 pc.addCols("Total x Cuenta",1,4);
				 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoCuenta),2,1);
				 pc.addCols(" ",0,dHeader.size());
				 montoCuenta = 0.00;
			 }
			 if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codBanco")))
			 {
				 pc.setFont(7, 1);
				 pc.addCols("Total x Banco",1,4);
				 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTran),2,1);
				 pc.addCols(" ",0,dHeader.size());
				 montoTran = 0.00;
			 }
		   }
			pc.setFont(8, 1);
			
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codBanco")))
			pc.addCols("Banco: "+cdo.getColValue("codBanco")+" "+cdo.getColValue("descBanco"),0,dHeader.size());
			else pc.addCols(" ",0,dHeader.size());
			pc.addCols("Cuenta: "+cdo.getColValue("descCuenta"),0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
		  }
			montoTran   += Double.parseDouble(cdo.getColValue("monto"));
			montoTranF  += Double.parseDouble(cdo.getColValue("monto"));
			montoCuenta += Double.parseDouble(cdo.getColValue("monto"));

   		    pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("cheque"),0,1);
			pc.addCols(" "+cdo.getColValue("fechaEmision"),1,1);
			pc.addCols(" "+cdo.getColValue("fechaCk"),1,1);
			pc.addCols(" "+cdo.getColValue("benef"),0,1);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		groupBy   = cdo.getColValue("codBanco");
		groupBy2  = cdo.getColValue("cuenta");

	}//for i-1

	if (al.size() == 0)
	{
		pc.addCols(" ",0,dHeader.size()*3);
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{  
	
		pc.setFont(7, 1);
		pc.addCols("Total x Cuenta",1,4);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoCuenta),2,1);
		pc.addCols(" ",0,dHeader.size()); 
	 
		pc.addCols("Total x Banco",1,4);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTran),2,1);
		pc.addCols(" ",0,dHeader.size()); 
		//Totales Finales
		pc.setFont(8, 1);
		pc.addCols("Monto Total",1,4);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(montoTranF),2,1,0.0f,0.1f,0.0f,0.0f);
		pc.addCols(" ",0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>