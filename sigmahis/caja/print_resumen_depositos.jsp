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
CommonDataObject cdoTot = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlTot = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String turno = request.getParameter("turno");
String fpOtros = "Otros";
try {fpOtros = java.util.ResourceBundle.getBundle("issi").getString("fpOtros"); } catch(Exception e){ fpOtros = "Otros";}

if (appendFilter  == null) appendFilter  = "";
if (fechaini  == null) fechaini  = "";
if (fechafin  == null) fechafin  = "";
if (turno  == null) turno  = "";

sbSql.append("select x.* ,case when nvl(x.total_cja,0) > nvl(x.final_total,0) then nvl(x.final_total,0) - nvl(x.total_cja,0)  else 0 end as faltante,case when nvl(x.total_cja,0) < nvl(x.final_total,0) then nvl(x.final_total,0)-nvl(x.total_cja,0)  else 0 end as sobrante from (select a.session_id turno, nvl(a.total_cash,0) as efectivo, nvl(a.total_cheque,0)as cheque, nvl(a.total_accdeposit,0) as depositos, nvl(a.total_creditcard,0) as tarjeta_cr, nvl(a.total_debitcard,0) as tarjeta_db,nvl(a.final_total,0)as final_total,nvl(fn_cja_total_cajero(a.company_id,a.session_id,'N'),0) total_cja,nvl(a.otros,0)as otros from tbl_cja_sesdetails a,tbl_cja_turnos t where a.session_id =t.codigo and a.company_id =t.compania and company_id =");
 sbSql.append((String) session.getAttribute("_companyId"));


	if(!fechaini.trim().equals("")){sbSql.append(" and trunc(t.fecha_creacion) >= to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	if(!fechafin.trim().equals("")){sbSql.append(" and trunc(t.fecha_creacion) <= to_date('");
	sbSql.append(fechafin);
	sbSql.append("','dd/mm/yyyy')");} 
	if(!turno.trim().equals("")){sbSql.append(" and a.session_id= ");sbSql.append(turno);}

sbSql.append(") x order by x.turno"); 


al = SQLMgr.getDataList(sbSql.toString());

sbSqlTot.append("select sum (nvl(efectivo,0))as efectivo, sum(nvl(cheque,0))as cheque, sum(nvl(depositos,0)) as depositos, sum(nvl(tarjeta_cr,0)) as tarjeta_cr, sum(nvl(tarjeta_db,0)) as tarjeta_db, sum(nvl(final_total,0))as final_total,sum(nvl(total_cja,0))as total_cja,sum(nvl(faltante,0))as faltante ,sum(nvl(sobrante,0))as sobrante,sum(nvl(otros,0))as otros from(");sbSqlTot.append(sbSql);
sbSqlTot.append(")");
if(al.size()!=0)cdoTot = SQLMgr.getData(sbSqlTot.toString());
else{ cdoTot = new CommonDataObject();
cdoTot.addColValue("efectivo","0");
cdoTot.addColValue("depositos","0");
cdoTot.addColValue("cheque","0");
cdoTot.addColValue("tarjeta_cr","0");
cdoTot.addColValue("tarjeta_db","0");
cdoTot.addColValue("otros","0");
cdoTot.addColValue("final_total","0");
cdoTot.addColValue("total_cja","0");
cdoTot.addColValue("faltante","0");
cdoTot.addColValue("sobrante","0");
}


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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;

	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTABILIDAD";
	String subtitle = "RESUMEN DE DEPOSITOS";
	String xtraSubtitle = "DEL  "+fechaini+"   AL   "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".10");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".10");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");
			dHeader.addElement(".08");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

			pc.setFont(8, 1);

			pc.addBorderCols("TURNO",0);
			pc.addBorderCols("EFECTIVO",1);
			pc.addBorderCols("CHEQUES",1);
			pc.addBorderCols(""+fpOtros.toUpperCase(),1);
			pc.addBorderCols("TOT. EF. CH. COMP.",1);
			pc.addBorderCols("TOT. REC. CAJA",1);
			pc.addBorderCols("FALTANTE",1);
			pc.addBorderCols("SOBRANTE",1);
			pc.addBorderCols("DEPOSITO",1);
			pc.addBorderCols("TARJETAS CR",1);
			pc.addBorderCols("TARJETAS DB",1);
			pc.addBorderCols("TOT. CIERRE",1);
			//pc.addBorderCols("CREDITO",0);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String groupBy = "";
	double total = 0.00, totalCja = 0.00,totalSob=0.00;
	double total_efe_ch_comp=0.00,total_efe_ch_comp_fin=0.00;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

			pc.addCols(" "+cdo.getColValue("turno"),0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("efectivo")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("cheque")),2,1);			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("otros")),2,1);		
	total_efe_ch_comp = Double.parseDouble(cdo.getColValue("efectivo"))+Double.parseDouble(cdo.getColValue("cheque"))+Double.parseDouble(cdo.getColValue("otros"));
	total_efe_ch_comp_fin += Double.parseDouble(cdo.getColValue("efectivo"))+Double.parseDouble(cdo.getColValue("cheque"))+Double.parseDouble(cdo.getColValue("otros"));
	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(total_efe_ch_comp),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("total_cja")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("faltante")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("sobrante")),2,1);		
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("depositos")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("tarjeta_cr")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("tarjeta_db")),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("final_total")),2,1);				

			if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

	}
	pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	{
			pc.setFont(9, 1);
			pc.addCols(" TOTALES ",2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("efectivo")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("cheque")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("otros")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(total_efe_ch_comp_fin),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("total_cja")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("faltante")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("sobrante")),2,1);			
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("depositos")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("tarjeta_cr")),2,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("tarjeta_db")),2,1);		
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdoTot.getColValue("final_total")),2,1);
			
			
			pc.setFont(10, 1,Color.blue);
			//total = Double.parseDouble(cdoTot.getColValue("efectivo"))+Double.parseDouble(cdoTot.getColValue("faltante"))+Double.parseDouble(cdoTot.getColValue("sobrante"));
			totalCja = Double.parseDouble(cdoTot.getColValue("final_total"))+Double.parseDouble(cdoTot.getColValue("faltante"))+Double.parseDouble(cdoTot.getColValue("sobrante"));
			//totalSob = Double.parseDouble(cdoTot.getColValue("faltante"))+Double.parseDouble(cdoTot.getColValue("sobrante"));
			totalSob = total_efe_ch_comp_fin - Double.parseDouble(cdoTot.getColValue("efectivo"))-Double.parseDouble(cdoTot.getColValue("cheque"));
			//totalSob = total_efe_ch_comp_fin - Double.parseDouble(cdoTot.getColValue("efectivo"))- Double.parseDouble(cdoTot.getColValue("cheque"));
			
			pc.addCols(" ",1,dHeader.size());
			pc.addCols("FALTANTE",0,1);
			if(totalSob >0)pc.addCols(" ---"+CmnMgr.getFormattedDecimal(totalSob),2,1);
			else pc.addCols(" ",2,1);
			pc.addCols(" ",2,10);
			pc.addCols(" ",1,dHeader.size());
			if(totalSob <0){
			pc.addCols("SOBRANTE",0,1);
			if(totalSob <0)pc.addCols(" "+CmnMgr.getFormattedDecimal(totalSob),2,1);
			else pc.addCols(" ",2,1);
			pc.addCols(" ",2,10);}
			
			/*pc.addCols(" ",1,dHeader.size());
			pc.addCols("TOTAL A DEPOSITAR",0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(total),2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);			
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);
			pc.addCols(" ",2,1);		*/		
			
	}	

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
