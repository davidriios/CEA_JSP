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

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String banco = request.getParameter("banco");
String nombre = request.getParameter("nombre");
String descripcion = request.getParameter("cuenta");
String cuenta = request.getParameter("cuenta");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String tipo = request.getParameter("tipo");
String titulo = "";

if (appendFilter  == null) appendFilter  = "";
if (fechaini  == null) fechaini  = "";
if (fechafin  == null) fechafin  = "";
if (tipo  == null) tipo  = "";

if (!fechaini.trim().equals("")) appendFilter += " and trunc(mb.f_movimiento) >= to_date('"+fechaini+"','dd/mm/yyyy') ";
if (!fechafin.trim().equals("")) appendFilter += " and trunc(mb.f_movimiento) <= to_date('"+fechafin+"','dd/mm/yyyy') ";
if (!tipo.trim().equals("")) appendFilter += " and mb.tipo_movimiento =  '"+tipo+"'";
if (!banco.trim().equals("")) appendFilter += " and mb.banco ='"+banco+"'";
if (!cuenta.trim().equals("")) appendFilter += " and mb.cuenta_banco ='"+cuenta+"'";

sbSql.append("select all cb.cuenta_banco, cb.descripcion nombre_cuenta,  b.cod_banco, b.nombre nombre_banco, mb.consecutivo_ag, num_documento, to_char(mb.f_movimiento,'dd/mm/yyyy') as fMovimientoDsp, mb.f_movimiento, mb.monto,  tm.cod_transac, tm.descripcion  nombre_movimiento, mb.notas_debito desc_mb, c.descripcion   from tbl_con_movim_bancario mb, tbl_con_cuenta_bancaria cb,  tbl_con_banco b, tbl_con_tipo_movimiento tm,  tbl_con_tipo_nota_cr_db c  where mb.cuenta_banco = cb.cuenta_banco  and  mb.compania= cb.compania    and  mb.banco= cb.cod_banco   and cb.compania = b.compania and cb.cod_banco= b.cod_banco   and (mb.notas_debito = c.codigo  or mb.notas_credito = c.codigo)   and mb.tipo_movimiento = tm.cod_transac   and mb.estado_trans != 'A' ");
sbSql.append(appendFilter);
sbSql.append(" order by b.nombre, cb.cuenta_banco, mb.tipo_movimiento,  mb.f_movimiento ");
al = SQLMgr.getDataList(sbSql.toString());

//// titulo
if (tipo.trim().equals("2")) titulo = "NOTAS DE DEBITO ";
else if  (tipo.trim().equals("3")) titulo = "NOTAS DE CREDITO ";
else titulo = "TRANSACCIONES ";

if (!fechaini.trim().equals("")) titulo +="   DESDE EL    "+fechaini;
if (!fechafin.trim().equals("")) titulo +="   HASTA EL   "+fechafin;


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
	String xtraSubtitle = ""+titulo;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

			dHeader.addElement(".35");
			dHeader.addElement(".10");
			dHeader.addElement(".10");
			dHeader.addElement(".35");
			dHeader.addElement(".10");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);

			pc.addBorderCols("DESCRIPCION",0);
			pc.addBorderCols("No. DOC",1);
			pc.addBorderCols("FECHA",1);
			pc.addBorderCols("TIPO",0);
			pc.addBorderCols("MONTO",2);

			pc.addCols("",1,dHeader.size());

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	double saldo = 0.00, montoFinal = 0;

//if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));


	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		//saldo += Double.parseDouble(cdo.getColValue("debito"));
		//saldo -= Double.parseDouble(cdo.getColValue("credito"));
			if (i==0) {
				pc.setFont(8,1);
				pc.addCols("BANCO:     "+cdo.getColValue("nombre_banco"),0,dHeader.size());
				pc.addCols("CUENTA BANCARIA: "+cdo.getColValue("nombre_cuenta"),0,dHeader.size());
				pc.addCols("",1,dHeader.size());
			}
			pc.setFont(7,0);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);

			pc.addCols(" "+cdo.getColValue("consecutivo_ag"),1,1);
			pc.addCols(" "+cdo.getColValue("fMovimientoDsp"),1,1);
			pc.addCols(" "+cdo.getColValue("nombre_movimiento"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);

			montoFinal += Double.parseDouble(cdo.getColValue("monto"));


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else{
			pc.setFont(8,1);
			pc.addCols("Total Final . . . . . ",2,4);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(montoFinal),2,1);
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
		}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>