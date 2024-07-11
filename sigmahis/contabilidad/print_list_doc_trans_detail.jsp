<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color" %>
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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String dateType = request.getParameter("dateType");
String docType = request.getParameter("docType");
String xDate = request.getParameter("xDate");
String toDate = request.getParameter("toDate");
if (docType == null) throw new Exception("El Tipo de Documento no es válido. Por favor intente nuevamente!");
if (xDate == null) throw new Exception("La Fecha no es válida. Por favor intente nuevamente!");

if (appendFilter == null) appendFilter = "";

sbSql = new StringBuffer();

  sbSql.append("select * from (select nvl(a.cds, -1) cds, nvl(c.descripcion, 'NO CDS') desc_cds, nvl(a.service_type, '-1') tipo_servicio, nvl(b.descripcion, 'NO TIPO SERVICIO') desc_tipo_servicio, a.trans_block_id, to_char(a.trans_date,'dd/mm/yyyy') as trans_date, a.trans_type, a.compania, a.doc_type, a.doc_id, a.doc_no, to_char(a.doc_date,'dd/mm/yyyy') as doc_date, a.doc_amt, a.doc_description, sum(a.debit-a.credit) as bal from tbl_con_accdoc_trans a, tbl_cds_tipo_servicio b, tbl_cds_centro_servicio c where a.status = 'A' and a.cds = c.codigo(+) and a.service_type = b.codigo(+) and a.compania=");
	sbSql.append((String) session.getAttribute("_companyId")+" and a.doc_type='");
	sbSql.append(docType);
	sbSql.append("' and trunc(");
	sbSql.append(dateType);
	sbSql.append(") between to_date('");
	sbSql.append(xDate);
	sbSql.append("','dd/mm/yyyy') and to_date('");
	sbSql.append(toDate);
	sbSql.append("','dd/mm/yyyy') group by a.cds, c.descripcion, a.service_type, b.descripcion, a.trans_block_id, to_char(a.trans_date,'dd/mm/yyyy'), a.trans_type, a.compania, a.doc_type, a.doc_id, a.doc_no, to_char(a.doc_date,'dd/mm/yyyy'), a.doc_amt, a.trans_date, a.doc_description) order by cds, tipo_servicio, ");
	sbSql.append(dateType);
	sbSql.append(" desc, trans_block_id desc");


al = SQLMgr.getDataList(sbSql.toString());

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "TRANSACCIONES DE DOCUMENTOS";
	String subtitle = "DEL "+xDate+ " AL " + toDate;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".06");
		dHeader.addElement(".1");
		dHeader.addElement(".14");
		dHeader.addElement(".1");
		dHeader.addElement(".5");
		dHeader.addElement(".1");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);

		pc.addBorderCols("No. Bloque",1);
		pc.addBorderCols("Fecha",1);
		pc.addBorderCols("No. Documento",1);
		pc.addBorderCols("Fecha Documento",1);
		pc.addBorderCols("Descripcion",1);
		pc.addBorderCols("Monto",1);
	//pc.setTableHeader(10);//create de table header

	//table body
	String groupBy = "";
	String groupTitle = "";
	String subGroupBy = "";
	String subGroupTitle = "";
	double cdsTotal = 0.00;
	double total = 0.00;
	double tsTotal = 0.00;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		
		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("tipo_servicio")))
		{
			if (i != 0)
			{
				pc.setFont(contentFontSize,1,Color.GRAY);
				pc.addBorderCols(" "+" "+"TOTAL DE "+subGroupTitle,0,5,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(tsTotal),2,1,0.0f,0.5f,0.0f,0.0f);
				tsTotal = 0.00;
				if (groupBy.equalsIgnoreCase(cdo.getColValue("cds"))){
					pc.setFont(contentFontSize,1,Color.GRAY);
					pc.addBorderCols(" "+" "+cdo.getColValue("desc_tipo_servicio")+" [ "+cdo.getColValue("tipo_servicio")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				}
			}
		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("cds")))
		{
			if (i != 0)
			{
				pc.setFont(groupFontSize,1);
				pc.addBorderCols("TOTAL DE "+groupTitle,0,5,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cdsTotal),2,1,0.0f,0.5f,0.0f,0.0f);
				cdsTotal = 0.00;

				//delete previous cds
				//pc.deleteRows(-1);
				//set current cds as header
				pc.setFont(groupFontSize,1);
				//pc.addBorderCols(cdo.getColValue("desc_cds")+" [ "+cdo.getColValue("cds")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
					//pc.deleteRows(2,1);//delete patient details for next pages, leave only patient name
				//pc.setTableHeader(3);//reset header size and cds
			}
			pc.addBorderCols(cdo.getColValue("desc_cds")+" [ "+cdo.getColValue("cds")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("tipo_servicio")))
			{
				pc.setFont(contentFontSize,1,Color.GRAY);
				pc.addBorderCols(" "+" "+cdo.getColValue("desc_tipo_servicio")+" [ "+cdo.getColValue("tipo_servicio")+" ]",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			}
			if (i == 0) pc.setTableHeader(2);//set first header with cds
		}//diff cds

		pc.setFont(contentFontSize,0);
		pc.setVAlignment(0);
		pc.addCols(cdo.getColValue("trans_block_id"),2,1);
		pc.addCols(cdo.getColValue("trans_date"),1,1);
		pc.addCols(cdo.getColValue("doc_no"),1,1);
		pc.addCols(cdo.getColValue("doc_date"),1,1);
		pc.addCols(cdo.getColValue("doc_description"),0,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("doc_amt")),2,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy = cdo.getColValue("cds");
		groupTitle = cdo.getColValue("desc_cds")+" [ "+cdo.getColValue("cds")+" ]";
		cdsTotal += Double.parseDouble(cdo.getColValue("doc_amt"));
		subGroupBy = cdo.getColValue("tipo_servicio");
		subGroupTitle = " "+" "+cdo.getColValue("desc_tipo_servicio")+" [ "+cdo.getColValue("tipo_servicio")+" ]";
		tsTotal += Double.parseDouble(cdo.getColValue("doc_amt"));
		total += Double.parseDouble(cdo.getColValue("doc_amt"));
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(contentFontSize,1,Color.GRAY);
		pc.addBorderCols(" "+" "+"TOTAL DE "+subGroupTitle,0,5,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(tsTotal),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.setFont(groupFontSize,1);
		pc.addBorderCols("TOTAL DE "+groupTitle,0,5,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(cdsTotal),2,1,0.0f,0.5f,0.0f,0.0f);

		pc.addCols(" ",0,dHeader.size());

	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>