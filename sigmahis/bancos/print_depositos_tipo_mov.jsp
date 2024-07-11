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
<!-- Desarrollado por: Tirza Monteza	  -->
<!-- Bancos                               -->
<!-- Reporte: "DEPOSITOS EN SISTEMA"      -->
<!-- Reporte: CB123.rdf                   -->
<!-- Clínica Hospital San Fernando        -->
<!-- Fecha: 30/02/2012                    -->

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
String appendColumn = request.getParameter("appendColumn");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania  = (String) session.getAttribute("_companyId");
//String compania = request.getParameter("compania");
String banco  = request.getParameter("banco");
String cuenta = request.getParameter("cuenta");
String estado = request.getParameter("estado");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String deposito = request.getParameter("deposito");

String fg        = request.getParameter("fg");
String vMes = "";

if (banco  == null)   banco    = "";
if (cuenta == null)   cuenta   = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (deposito == null)   deposito   = "";
if (appendFilter == null) appendFilter = "";
if (appendColumn == null) appendColumn = "";
if (compania == null) compania = (String) session.getAttribute("_companyId");

//--------------Parámetros--------------------//
if (!compania.equals("")) appendFilter += " and mb.compania = "+compania;
if (!banco.equals(""))    appendFilter += " and mb.banco = '"+banco+"'";
if (!cuenta.equals(""))   appendFilter += " and cb.cuenta_banco = '"+cuenta+"'";
if (!deposito.equals("")) {
	if (deposito.equals("99"))   appendFilter += " and td.codigo in(1,3,5)";
	else  appendFilter += " and td.codigo = "+deposito;
}
// filtro por fechas
if (!fechaini.equals(""))
{
	appendFilter += " and trunc(mb.f_movimiento)>=  to_date('"+fechaini+"', 'dd/mm/yyyy')";
    appendColumn += "' DEL '||to_char(to_date('"+fechaini+"','dd/mm/yyyy'),'dd/mm/yyyy')  ";
}
if (!fechafin.equals(""))
{
	appendFilter += " and trunc(mb.f_movimiento)<=  to_date('"+fechafin+"', 'dd/mm/yyyy')";
    appendColumn += "||' AL '||to_char(to_date('"+fechafin+"','dd/mm/yyyy'),'dd/mm/yyyy')  ";
}


//------------------------------------------------------------------------------------------------------//
/*--------Query para Obtener los Datos de Depósitos en Tránsito----------------------------------------*/
sql= "select all cb.cuenta_banco, cb.descripcion nombre_cuenta, b.cod_banco,  b.nombre nombre_banco, nvl(td.descripcion,'* * SIN TIPO DE DEPOSITO * *') tipo_deposito, mb.consecutivo_ag,  nvl(num_documento,' ') as numDocto, mb.f_movimiento,  to_char(trunc(mb.f_movimiento),'dd/mm/yyyy') as f_movimientoDsp,nvl(mb.monto,0) as bruto, nvl(mb.mto_tot_tarjeta,0) as neto,nvl(mb.comision,0) as comision,nvl(mb.mto_tot_tarjeta,nvl(mb.monto,0))-nvl(mb.devoluc_tarj,0) as monto,  tm.cod_transac,  tm.descripcion  nombre_movimiento,  mb.descripcion desc_mb,  mb.usuario_creacion usuario,mb.caja,nvl(mb.devoluc_tarj,0) as devolucion from tbl_con_movim_bancario mb,  tbl_con_cuenta_bancaria cb,  tbl_con_banco b,  tbl_con_tipo_movimiento tm,  tbl_con_tipo_deposito td  where mb.cuenta_banco  = cb.cuenta_banco  and  mb.compania = cb.compania   and  mb.banco  = cb.cod_banco  and cb.compania = b.compania and cb.cod_banco  = b.cod_banco  and  mb.tipo_movimiento  = tm.cod_transac  and mb.estado_trans  !=   'A' and mb.tipo_movimiento=1  and mb.tipo_dep = td.codigo(+)  "+appendFilter+"  order by mb.tipo_movimiento, b.cod_banco, mb.cuenta_banco, td.descripcion, trunc(mb.f_movimiento)";
al = SQLMgr.getDataList(sql);

if (appendColumn.equals("")) appendColumn += "' AL '||to_char(SYSDATE,'dd/mm/yyyy') ";
sql= " select "+appendColumn+" fechaConv from dual ";
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
	String subtitle = "DEPOSITOS EN SISTEMAS";
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

	dHeader.addElement(".10");
	dHeader.addElement(".15");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".15");
	dHeader.addElement(".10");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(7, 1);
 	pc.addBorderCols("CONSECUTIVO",1,1,Color.lightGray);
	pc.addBorderCols("No. DOCTO",1,1,Color.lightGray);
	pc.addBorderCols("FECHA",1,1,Color.lightGray);
	pc.addBorderCols("BRUTO",1,1,Color.lightGray);
	pc.addBorderCols("COMISION",1,1,Color.lightGray);
	pc.addBorderCols("DEVOLUC.",1,1,Color.lightGray);
	pc.addBorderCols("NETO",1,1,Color.lightGray);
	pc.addBorderCols("USUARIO",1,1,Color.lightGray);
	pc.addBorderCols("CAJA",1,1,Color.lightGray);

	pc.resetVAlignment();

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//headerHeight =  pc.getTableHeight();

	String groupBy = "", groupByTipo ="", groupByDate = "";
	double monto = 0, montoTran = 0, montoTranF = 0, montoDep = 0, montoDate = 0;
	double bruto = 0, brutoTran = 0, brutoTranF = 0, brutoDep = 0, brutoDate = 0;
	double comision = 0, comisionTran = 0, comisionTranF = 0, comisionDep = 0, comisionDate = 0;
	double dev = 0, devTran = 0, devTranF = 0, devDep = 0, devDate = 0;

	for (int i=0; i<al.size(); i++)
	{//for-1
       cdo = (CommonDataObject) al.get(i);

	    if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("nombre_banco")+"-"+cdo.getColValue("cuenta_banco")))
		 {
		  if (i != 0)  // imprime total por banco/cuenta
		   {
			 /// Totales date
			 pc.setFont(7, 1);
			 pc.addCols("Total "+groupByDate,2,3);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(devDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoDate),2,1);
		     pc.addCols(" ",2,2);
			 montoDate = 0.00;
			 brutoDate = 0.00;
			 comisionDate = 0.00;
			 devDate = 0.00;
			 groupByDate ="";

			 /// Totales tipo deposito
			 pc.setFont(7, 1);
			 pc.addCols("Total "+groupByTipo,2,3);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoDep),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionDep),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(devDep),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoDep),2,1);
		     pc.addCols(" ",2,2);
			 montoDep = 0.00;
			 brutoDep = 0.00;
			 comisionDep = 0.00;
			 devDep = 0.00;
			 groupByTipo ="";

			 /// Totales banco/cta
			 pc.setFont(7, 1);
			 pc.addCols("Total "+groupBy,2,3);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoTran),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionTran),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(devTran),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTran),2,1);
		     pc.addCols(" ",2,2);
			 pc.addCols(" ",0,dHeader.size());
			 montoTran = 0.00;
			 brutoTran = 0.00;
			 comisionTran = 0.00;
			 devTran = 0.00;

		   }
			pc.setFont(8, 1);
			pc.addCols("Banco: "+cdo.getColValue("cod_banco")+" "+cdo.getColValue("nombre_banco"),0,dHeader.size());
			pc.addCols("Cuenta: "+cdo.getColValue("nombre_cuenta"),0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
		  }

	    if (!groupByTipo.trim().equalsIgnoreCase(cdo.getColValue("tipo_deposito")))
		 {
		  if (i != 0  && !groupByTipo.trim().equalsIgnoreCase("") )  // imprime total por tipo deposito
		   {
			 pc.setFont(7, 1);

			 pc.addCols("Total "+groupByDate,2,3);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(devDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoDate),2,1);
		     pc.addCols(" ",2,2);
			 pc.addCols(" ",0,dHeader.size());
			 // por date
			 montoDate = 0.00;
			 brutoDate = 0.00;
			 comisionDate = 0.00;
			 devDate = 0.00;
			 groupByDate ="";

			 pc.addCols("Total "+groupByTipo,2,3);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoDep),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionDep),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(devDep),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoDep),2,1);
		     pc.addCols(" ",2,2);
			 pc.addCols(" ",0,dHeader.size());
			 // por tipo deposito
			 montoDep = 0.00;
			 brutoDep = 0.00;
			 comisionDep = 0.00;
			 devDep = 0.00;
		   }
			pc.setFont(8, 1);
			pc.addCols("Tipo Depósito: "+cdo.getColValue("tipo_deposito"),0,dHeader.size());
		  }

	    if (!groupByDate.trim().equalsIgnoreCase(cdo.getColValue("f_movimientoDsp")))
		 {
		  if (i != 0  && !groupByDate.trim().equalsIgnoreCase("") )  // imprime total por tipo deposito
		   {
			 pc.setFont(7, 1);
			 pc.addCols("Total "+groupByDate,2,3);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(devDate),2,1);
			 pc.addCols(" "+CmnMgr.getFormattedDecimal(montoDate),2,1);
		     pc.addCols(" ",2,2);
			 pc.addCols(" ",0,dHeader.size());
			 montoDate = 0.00;
			 brutoDate = 0.00;
			 comisionDate = 0.00;
			 devDate = 0.00;
		   }
		  }

			montoTran  += Double.parseDouble(cdo.getColValue("monto"));
			montoTranF += Double.parseDouble(cdo.getColValue("monto"));
			montoDep   += Double.parseDouble(cdo.getColValue("monto"));
			montoDate   += Double.parseDouble(cdo.getColValue("monto"));

			brutoTran  += Double.parseDouble(cdo.getColValue("bruto"));
			brutoTranF += Double.parseDouble(cdo.getColValue("bruto"));
			brutoDep   += Double.parseDouble(cdo.getColValue("bruto"));
			brutoDate   += Double.parseDouble(cdo.getColValue("bruto"));

			comisionTran  += Double.parseDouble(cdo.getColValue("comision"));
			comisionTranF += Double.parseDouble(cdo.getColValue("comision"));
			comisionDep   += Double.parseDouble(cdo.getColValue("comision"));
			comisionDate   += Double.parseDouble(cdo.getColValue("comision"));
			
			devTran  += Double.parseDouble(cdo.getColValue("devolucion"));
			devTranF += Double.parseDouble(cdo.getColValue("devolucion"));
			devDep   += Double.parseDouble(cdo.getColValue("devolucion"));
			devDate   += Double.parseDouble(cdo.getColValue("devolucion"));

   		    pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("consecutivo_ag"),0,1);
			pc.addCols(" "+cdo.getColValue("numDocto"),0,1);
			pc.addCols(" "+cdo.getColValue("f_movimientoDsp"),1,1);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("bruto"))),2,1);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("comision"))),2,1);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("devolucion"))),2,1);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))),2,1);
			pc.addCols(" "+cdo.getColValue("usuario"),2,1);
			pc.addCols(" "+cdo.getColValue("caja"),1,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		groupBy  = cdo.getColValue("nombre_banco")+"-"+cdo.getColValue("cuenta_banco");
		groupByTipo  = cdo.getColValue("tipo_deposito");
		groupByDate  = cdo.getColValue("f_movimientoDsp");

	}//for i-1

	if (al.size() == 0)
	{
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{
		// Totales por date
		pc.setFont(7, 1);
		pc.addCols("Total "+groupByDate,2,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoDate),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionDate),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(devDate),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoDate),2,1);
		pc.addCols(" ",2,2);
		pc.addCols(" ",0,dHeader.size());

		// Totales tipo deposito
		pc.setFont(7, 1);
		pc.addCols("Total "+groupByTipo,2,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoDep),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionDep),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(devDep),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoDep),2,1);
		pc.addCols(" ",2,2);
		pc.addCols(" ",0,dHeader.size());

		// Totales transaccion
		pc.setFont(7, 1);
		pc.addCols("Total "+groupBy,2,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoTran),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionTran),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(devTran),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTran),2,1);
		pc.addCols(" ",2,2);
		pc.addCols(" ",0,dHeader.size());

		//Totales Finales
		pc.setFont(8, 1);
		pc.addCols("Totales Finales",2,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(brutoTranF),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(comisionTranF),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(devTranF),2,1);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoTranF),2,1);
		pc.addCols(" ",2,2);
		pc.addCols(" ",0,dHeader.size());
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>