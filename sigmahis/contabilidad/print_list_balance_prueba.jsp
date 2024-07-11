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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoSI = new CommonDataObject();
CommonDataObject cdoCta = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String fp = request.getParameter("fp");
String incluir_mes_13 = request.getParameter("incluir_mes_13");

String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta1H = request.getParameter("cta1H");
String cta2H = request.getParameter("cta2H");
String cta3H = request.getParameter("cta3H");
String cta4H = request.getParameter("cta4H");

String ctaDesde = "",ctaDesde2="";
String ctaHasta = "",ctaHasta2="";
String compania = (String) session.getAttribute("_companyId");
String con_movimiento = request.getParameter("con_movimiento");

if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(incluir_mes_13==null) incluir_mes_13="N";
if (con_movimiento == null) con_movimiento = "";

//if (fp == null) appendFilter = " and c.recibe_mov = 'S'";
//else appendFilter = " AND (((nvl(c.ult_mes,0) >= '"+mes+"' AND c.ult_anio >= "+anio+") OR c.recibe_mov = 'S') OR (nvl(c.ult_anio ,0) > "+anio+" AND c.ult_anio is not null)) ";

//if(!fechaini.equals("") && !fechafin.equals("")) appendFilter = " and trunc(fecha_documento) >= to_date('"+fechaini+"', 'dd/mm/yyyy') and  trunc(fecha_documento) <= to_date('"+fechafin+"', 'dd/mm/yyyy')";


if (!cta1.trim().equals("")) 
{ 
	ctaDesde   +="c.cta1";
	ctaDesde2  +=cta1;
}
if (!cta2.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaDesde   +="||c.cta2";
		ctaDesde2  +=""+cta2;
	}
}
if (!cta3.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaDesde   +="||c.cta3";
		ctaDesde2  +=""+cta3;
	}
}
if (!cta4.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaDesde   +="||c.cta4";
		ctaDesde2  +=""+cta4;
	}
}
if (!ctaDesde.trim().equals("") && !ctaDesde2.trim().equals("")) { sbFilter.append(" and to_number("); sbFilter.append(ctaDesde); sbFilter.append(") >= to_number('"); sbFilter.append(ctaDesde2); sbFilter.append("')"); }



if (!cta1H.trim().equals("")) 
{ 
	ctaHasta   +="c.cta1";
	ctaHasta2  +=cta1H;
}
if (!cta2H.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaHasta   +="||c.cta2";
		ctaHasta2  +=""+cta2H;
	}
}
if (!cta3H.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaHasta   +="||c.cta3";
		ctaHasta2  +=""+cta3H;
	}
}
if (!cta4H.trim().equals("")) 
{ 
	if (!ctaDesde.trim().equals("")) 
	{
		ctaHasta   +="||c.cta4";
		ctaHasta2  +=""+cta4H;
	}
}

if (!ctaHasta.trim().equals("") && !ctaHasta2.trim().equals("")) { sbFilter.append(" and to_number("); sbFilter.append(ctaHasta); sbFilter.append(") <= to_number('"); sbFilter.append(ctaHasta2); sbFilter.append("')"); }
if (!con_movimiento.trim().equals("")) sbFilter.append(" and abs(monto_ini) + abs(monto_db) + abs(monto_cr) <> 0 "); //appendFilter += " and (nvl(monto_db, 0) != 0 or nvl(monto_cr, 0) != 0)";

sbSql.append("select a.*, saldo_inicial+monto_db-monto_cr saldo_actual from (select  num_cuenta, descripcion, monto_db, monto_cr, getsaldoinicial(compania, ea_ano, mes, num_cuenta) saldo_inicial, monto_ini, monto_db_cta, monto_cr_cta/*,getsaldoAcumulado(compania, ea_ano, mes, num_cuenta) saldo_acumulado*/ from vw_con_catalogo_gral_bal c where compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and ea_ano = ");
sbSql.append(anio);
sbSql.append(" and mes = ");
sbSql.append(mes);
sbSql.append(sbFilter);
sbSql.append(") a");
if (con_movimiento.equalsIgnoreCase("SS")) sbSql.append(" where saldo_inicial+monto_db-monto_cr = 0");
else if (con_movimiento.equalsIgnoreCase("CS")) sbSql.append(" where saldo_inicial+monto_db-monto_cr <> 0");
sbSql.append(" order by num_cuenta");

if (mes.equals("12") && incluir_mes_13.equals("Y")) {
	sbSql = new StringBuffer();
	sbSql.append("select a.num_cuenta, a.descripcion, a.monto_ini, (a.monto_db_cta + nvl(b.monto_db_cta, 0)) monto_db_cta, (a.monto_cr_cta + nvl (b.monto_cr_cta, 0)) monto_cr_cta, (a.monto_db + nvl(b.monto_db, 0)) monto_db, (a.monto_cr + nvl(b.monto_cr, 0)) monto_cr, (a.saldo_inicial + a.monto_db - a.monto_cr + nvl(b.monto_db, 0) - nvl(b.monto_cr, 0)) saldo_actual, a.saldo_inicial from (select  num_cuenta, descripcion, monto_db, monto_cr, getsaldoinicial (compania, ea_ano, mes, num_cuenta) saldo_inicial, monto_ini, monto_db_cta, monto_cr_cta from vw_con_catalogo_gral_bal c where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and ea_ano = ");
	sbSql.append(anio);
	sbSql.append(" and mes = ");
	sbSql.append(mes);
	sbSql.append(sbFilter);
	sbSql.append(") a, vw_con_catalogo_gral_bal b where a.num_cuenta = b.num_cuenta(+) and b.mes = 13 and b.ea_ano = ");
	sbSql.append(anio);
	if (con_movimiento.equalsIgnoreCase("SS")) sbSql.append(" and (a.saldo_inicial + a.monto_db - a.monto_cr + nvl(b.monto_db, 0) - nvl(b.monto_cr, 0)) = 0");
	else if (con_movimiento.equalsIgnoreCase("CS")) sbSql.append(" and (a.saldo_inicial + a.monto_db - a.monto_cr + nvl(b.monto_db, 0) - nvl(b.monto_cr, 0)) <> 0");
	sbSql.append(" order by a.num_cuenta");
}


	al = SQLMgr.getDataList(sbSql.toString());
		
if(!mes.trim().equals("13")){
	cdoSI = SQLMgr.getData("select 'AL ' || to_char((case when trunc(sysdate) < last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')) then sysdate else last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')) end), 'dd') || ' DE ' || to_char(to_date('"+mes+"','mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') || ' DE "+anio+"' fecha from  dual"); 
	}
	else
	{cdoSI = SQLMgr.getData("select 'MES CIERRE DE "+anio+"' fecha from  dual");}




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
	String title = "CONTABILIDAD";
	String subtitle = "BALANCE DE PRUEBA - HISTORICO";
	String xtraSubtitle = ""+cdoSI.getColValue("fecha");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	
			dHeader.addElement(".15");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".15");
			dHeader.addElement(".15");
			dHeader.addElement(".15");
			

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(7, 1);
			
			//pc.addCols("CREADO POR",0,1);
			//pc.addCols("CREADO EL",1,1);
			pc.addCols("CUENTA",0,1);
			pc.addCols("DESCRIPCION",0,1);
			pc.addCols("SALDO INICIAL",1,1);
			pc.addCols("DÉBITO",2,1);
			pc.addCols("CRÉDITO",2,1);
			pc.addCols("SALDO ACTUAL",1,1);
			
			
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	String db = "DB";
	double debito=0.00,credito=0.00,saldoInicial=0.00,saldoActual =0.00,saldoAcumulado =0.00,acumulado=0.00;
	
	
	
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		 saldoInicial   += Double.parseDouble(cdo.getColValue("monto_ini"));       
		 debito  += Double.parseDouble(cdo.getColValue("monto_db_cta"));	
		 credito    += Double.parseDouble(cdo.getColValue("monto_cr_cta"));       
		 saldoActual   += Double.parseDouble(cdo.getColValue("saldo_actual"));
		 //saldoAcumulado   += Double.parseDouble(cdo.getColValue("saldo_acumulado"));	
		
		//acumulado = Double.parseDouble(cdo.getColValue("saldo_actual"))+Double.parseDouble(cdo.getColValue("saldo_acumulado"));
		
			//pc.addCols(""+cdo.getColValue("uc"),0,1);
			//pc.addCols(""+cdo.getColValue("fc"),1,1);
		 	pc.addCols(""+cdo.getColValue("num_cuenta"),0,1);
			pc.addCols(""+cdo.getColValue("descripcion"),0,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_db")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cr")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_actual")),2,1);
			//pc.addCols(""+CmnMgr.getFormattedDecimal(""+acumulado),2,1);
			
			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else 
	{
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);	
	pc.addCols(" Total  ",3,4);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(saldoInicial),2,1);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(debito),2,1);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(credito),2,1);
	pc.addCols(" "+CmnMgr.getFormattedDecimal(saldoInicial+debito-credito),2,1);
		
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>