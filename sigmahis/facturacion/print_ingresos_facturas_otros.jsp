<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
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
ArrayList alTS = new ArrayList();
ArrayList alTST = new ArrayList();
CommonDataObject cdoHeader = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String status = request.getParameter("status");
String fg = request.getParameter("fg");
String doc_type = request.getParameter("doc_type");
String rep_type = request.getParameter("rep_type");

if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (appendFilter == null) appendFilter = "";
if (status == null) status = "";
if (fg == null) fg = "";
if (doc_type == null) doc_type = "";
if (rep_type == null) rep_type = "";

sbSql = new StringBuffer();

if (rep_type.trim().equals("R"))sbSql.append(" select descTipoCliente, sum(monto) monto, sum(descuento) descuento,sum(itbms) itbms from (");

sbSql.append("select decode(ft.other4,0,nvl(getMontoIngreso(ft.doc_id,ft.company_id),0),0) as monto, decode(ft.other4,1,(decode(ft.doc_type,'NCR', -nvl(ft.net_amount,0),nvl(ft.net_amount,0))),0)+nvl(getMontoDesc(ft.doc_id,ft.company_id),0) as  descuento,decode(ft.doc_type,'NCR',-(nvl(ft.tax_amount,0)),(nvl(ft.tax_amount,0))) itbms ,ft.client_name cliente,to_char(ft.doc_date,'dd/mm/yyyy')fecha,decode(ft.doc_type,'FAC',ft.other3,ft.doc_id) numero_factura, ft.created_by usuario_creacion, to_char(ft.doc_date,'yyyy')anio_cargo, ft.doc_id codigo_cargo,decode(ft.doc_type,'FAC','FACTURA','NCR','NOTA CREDITO','NDC','NOTA DEBITO',ft.doc_type) tipo_cargo,ft.doc_date fecha2,ft.client_ref_id clienteRef ,(select descripcion||' ( '||getCtaCxCCliente(ft.company_id,ft.client_ref_id,ft.sub_ref_id,-1)||')' from tbl_fac_tipo_cliente where codigo = ft.client_ref_id and compania =ft.company_id) descTipoCliente FROM tbl_fac_trx ft WHERE   ");
sbSql.append(" ft.company_id=");
sbSql.append(session.getAttribute("_companyId")); 

if (!fechaIni.trim().equals(""))
{
	sbSql.append(" and ft.doc_date >= to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy')");
}
if (!fechaFin.trim().equals(""))
{
	sbSql.append(" and ft.doc_date <= to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy')");
}

if (!doc_type.trim().equals(""))
{
	sbSql.append(" and ft.doc_type='");
	sbSql.append(doc_type);
	sbSql.append("'");
} 

sbSql.append(" order by 13 asc,ft.doc_date");
if (rep_type.trim().equals("R"))sbSql.append(") group by descTipoCliente ");

al = SQLMgr.getDataList(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	String title = "INGRESOS  (OTROS CLIENTES)";
	String subtitle = "DEL "+fechaIni+"  AL "+fechaFin;
	String xtraSubtitle = ""+((rep_type.trim().equals("R"))?" REPORTE RESUMIDO ":"");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".27");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");//30
		dHeader.addElement(".10");
		dHeader.addElement(".11");
		dHeader.addElement(".10");
		//dHeader.addElement(".09");
		//dHeader.addElement(".09");
		//dHeader.addElement(".09");
	
	
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(headerFontSize,1);
		if(rep_type.trim().equals("R"))
		{
			pc.addBorderCols("TIPO CLIENTE",0,6);
			pc.addBorderCols("ITBMS",1);
			pc.addBorderCols("DESCUENTOS",1);
			pc.addBorderCols("MONTO",1,1);
		}
		else{
		pc.addBorderCols("FECHA",1);
		pc.addBorderCols("CLIENTE",1);
		pc.addBorderCols("NO. DOC.",1);
		pc.addBorderCols("AÑO",1);
		pc.addBorderCols("CARGO",1,1);
		pc.addBorderCols("TIPO CARGO",1);
		pc.addBorderCols("ITBMS",1);
		pc.addBorderCols("DESCUENTOS",1);
		pc.addBorderCols("MONTO",1,1);}
	 pc.setTableHeader(2);//create de table header
	
	//table body
	String groupBy = "";
	String groupTitle = "";
	double totalItbms = 0.00,totalDescuento =0.00,total = 0.00;
	double totalItbmsTot = 0.00,totalDescuentoTot =0.00,totalTot = 0.00;
	boolean delPacDet = true;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setVAlignment(0);
		if(!rep_type.trim().equals("R"))
		{
		if(!groupBy.equals(cdo.getColValue("descTipoCliente")))
		{
			pc.setFont(groupFontSize,1,Color.blue);
			if(i!=0)
			{
				pc.addBorderCols("TOTAL: "+groupTitle,2,6,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(totalItbms),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(totalDescuento),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(total),2,1,0.0f,0.5f,0.0f,0.0f);
				totalItbms = 0.00;
				totalDescuento =0.00;
	 			total = 0.00;
				pc.addCols(" ",1,dHeader.size());
			}
			pc.addCols(" TIPO CLIENTE: "+cdo.getColValue("descTipoCliente"),0,dHeader.size());
		}
		}
		pc.setFont(contentFontSize,0);
		if(rep_type.trim().equals("R"))
		{
			pc.addCols(cdo.getColValue("descTipoCliente"),0,6);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("itbms")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("descuento")),2,1);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		}
		else
		{
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("cliente"),0,1);
		pc.addCols(cdo.getColValue("numero_factura"),0,1);
		pc.addCols(cdo.getColValue("anio_cargo"),1,1);
		pc.addCols(cdo.getColValue("codigo_cargo"),0,1);
		pc.addCols(cdo.getColValue("tipo_cargo"),1,1);
		
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("itbms")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("descuento")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		
		groupBy  = cdo.getColValue("descTipoCliente");
		groupTitle = cdo.getColValue("descTipoCliente");
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		total += Double.parseDouble(cdo.getColValue("monto"));
		totalItbms += Double.parseDouble(cdo.getColValue("itbms"));
		totalDescuento += Double.parseDouble(cdo.getColValue("descuento"));
		
		totalTot += Double.parseDouble(cdo.getColValue("monto"));
		totalItbmsTot += Double.parseDouble(cdo.getColValue("itbms"));
		totalDescuentoTot += Double.parseDouble(cdo.getColValue("descuento"));
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(groupFontSize,1,Color.blue);
		if(!rep_type.trim().equals("R"))
		{
			pc.addBorderCols("TOTAL: "+groupTitle,2,6,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(totalItbms),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(totalDescuento),2,1,0.0f,0.5f,0.0f,0.0f);
			pc.addBorderCols(CmnMgr.getFormattedDecimal(total),2,1,0.0f,0.5f,0.0f,0.0f);
		}
		pc.addBorderCols("TOTAL: ",2,6,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totalItbmsTot),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totalDescuentoTot),2,1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(CmnMgr.getFormattedDecimal(totalTot),2,1,0.0f,0.5f,0.0f,0.0f);
	}
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>