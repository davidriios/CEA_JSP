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
ArrayList alT = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fg = request.getParameter("fg");

if (fg == null) fg = "";

cdo1 = SQLMgr.getData("select 'AL ' || to_char(last_day(to_date('"+mes+"/"+anio+"', 'mm/yyyy')), 'dd') || ' DE ' || to_char(to_date('"+mes+"','mm'), 'FMMONTH', 'NLS_DATE_LANGUAGE=SPANISH') || ' DEL "+anio+"' fecha from dual");

sql = "select g.codigo, g.descripcion nombre_grupo, g.nota, c.descripcion nombre_cta, c.lado_movim, d.nota, m.monto_i, m.monto_db, m.monto_cr, d.cod_grupo, d.cta1, d.cta2, d.cta3, d.cta4, d.cta5, d.cta6, d.cod_rep, decode(c.lado_movim, 'DB', (nvl(m.monto_i, 0) + nvl(m.monto_db, 0) - nvl(m.monto_cr, 0)), (nvl(m.monto_i, 0) + nvl(m.monto_cr, 0) - nvl(m.monto_db, 0))) saldo, nvl(substr(c.cta1, 1, 1), '0') cta, g.es_total from tbl_con_grupos_rep g, tbl_con_detalle_rep d, tbl_con_catalogo_gral c, tbl_con_mov_mensual_cta m where g.cod_rep = d.cod_rep(+) and g.codigo = d.cod_grupo(+) and g.compania = d.compania(+) and g.compania = "+(String) session.getAttribute("_companyId") +" and g.cod_rep = 1 and d.cta1 = c.cta1(+) and d.cta2 = c.cta2(+) and d.cta3 = c.cta3(+) and d.cta4 = c.cta4(+) and d.cta5 = c.cta5(+) and d.cta6 = c.cta6(+) and d.compania = c.compania(+) and m.ea_ano(+) = "+anio+" and m.mes(+) = "+mes+" and d.cta1 = m.cat_cta1(+) and d.cta2 = m.cat_cta2(+) and d.cta3 = m.cat_cta3(+) and d.cta4 = m.cat_cta4(+) and d.cta5 = m.cat_cta5(+) and d.cta6 = m.cat_cta6(+) and d.compania = m.pc_compania(+) order by g.orden, d.cta1, d.cta2, d.cta3, d.cta4, d.cta5, d.cta6, g.descripcion";


al = SQLMgr.getDataList(sql);

sql = "select cta, sum(saldo) saldo from ("+sql+") group by cta";
alT = SQLMgr.getDataList(sql);
double totActivo = 0.00, totPasivo = 0.00, totPasivoCapital = 0.00;
for(int i = 0; i<alT.size();i++){
	CommonDataObject cdoT = (CommonDataObject) alT.get(i);
	if(cdoT.getColValue("cta").equals("1")) totActivo = Double.parseDouble(cdoT.getColValue("saldo"));
	else {
		if(cdoT.getColValue("cta").equals("2")) totPasivo = Double.parseDouble(cdoT.getColValue("saldo"));
		totPasivoCapital += Double.parseDouble(cdoT.getColValue("saldo"));
	}
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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "BALANCE GENERAL";
	String subtitle = cdo1.getColValue("fecha");
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".04");
		infoCol.addElement(".04");
		infoCol.addElement(".04");
		infoCol.addElement(".60");
		infoCol.addElement(".09");
		infoCol.addElement(".09");
		infoCol.addElement(".10");

	//table header
	pc.setNoColumnFixWidth(infoCol);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol.size());

	pc.setTableHeader(1);//create de table header (2 rows) and add header to the table
	

	//table body
	String groupBy = "";
	
	pc.setVAlignment(0);
	boolean printActivo = true, printPasivo = true, printPasivoCapital = true, printSubTotal = true;
	double saldo = 0.00, saldoGrupo = 0.00;
	for (int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("es_total").equals("S")){
			pc.setFont(7, 0);

			pc.addBorderCols(" ",2,4,0.0f,0.0f,0.0f,0.0f);
			pc.addBorderCols(" ",2,1,0.0f,0.1f,0.0f,0.0f);
			pc.addCols(""+saldoGrupo,2,1);
			pc.addCols(" ",0,1,cHeight);
			printSubTotal = false;

			pc.addCols(cdo.getColValue("nombre_grupo"),0,6,cHeight);
			pc.addCols(""+CmnMgr.getFormattedDecimal(saldo),2,1,cHeight);
			saldo = 0.00;
		} else {
			saldo += Double.parseDouble(cdo.getColValue("saldo"));
			String cta = cdo.getColValue("cta");
			if(cta.equals("1") && printActivo){
				pc.setFont(7, 1);
				pc.addCols("ACTIVOS",1,infoCol.size(),cHeight);
				printActivo = false;
			} else if(cta.equals("2") && printPasivo){
				pc.setFont(7, 1);
				
				pc.addCols("TOTAL DE ACTIVOS",0,6,cHeight);
				pc.addCols(""+totActivo,2,1,cHeight);
				
				pc.flushTableBody(true);
				pc.addNewPage();
				pc.addCols("PASIVOS Y CAPITAL",1,infoCol.size(),cHeight);
				printPasivo = false;
			} else if(cta.equals("3") && printPasivoCapital){
				pc.setFont(7, 1);
				
				pc.addCols("TOTAL DE PASIVOS",0,6,cHeight);
				pc.addCols(""+totPasivo,2,1,cHeight);
				printPasivoCapital = false;
			}
	
			if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("codigo"))){ // groupBy
					pc.setFont(7, 0);
					if(i!=0 && printSubTotal){
						pc.addBorderCols(" ",2,4,0.0f,0.0f,0.0f,0.0f);
						pc.addBorderCols(" ",2,1,0.0f,0.1f,0.0f,0.0f);
						pc.addCols(""+saldoGrupo,2,1);
						pc.addCols(" ",0,1,cHeight);
						
						pc.addCols(" ",0,infoCol.size(),cHeight);
						saldoGrupo = 0.00;
					}
					printSubTotal = true;
					pc.addCols(" ",0,infoCol.size(),cHeight);
					pc.addCols(" ",0,3,cHeight);
					pc.addCols(cdo.getColValue("nombre_grupo"),0,3,cHeight);
					pc.addCols(" ",0,infoCol.size(),cHeight);
			}
	
			pc.setFont(6, 0);
			pc.addCols(cdo.getColValue("cta1"),1,1);
			pc.addCols(cdo.getColValue("cta2"),1,1);
			pc.addCols(cdo.getColValue("cta3"),1,1);
			pc.addCols(cdo.getColValue("nombre_cta"),0,1);
			pc.addCols(cdo.getColValue("saldo"),2,1);
			pc.addCols(" ",0,0);
			pc.addCols(" ",0,0);
	
			groupBy = cdo.getColValue("codigo");
			saldoGrupo += Double.parseDouble(cdo.getColValue("saldo"));
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if(al.size()>0){
		pc.setFont(7, 1);
		pc.addCols("TOTAL PASIVO Y CAPITAL",0,6,cHeight);
		pc.addCols(""+totPasivoCapital,2,1,cHeight);
	}
	pc.addBorderCols("",0,infoCol.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) pc.addCols("No existen registros",1,infoCol.size());
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>