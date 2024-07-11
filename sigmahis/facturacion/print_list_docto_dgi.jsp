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
CommonDataObject cdo = new CommonDataObject();

StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
sbSql.append("select a.id, a.tipo_docto, a.compania, a.anio, a.codigo, a.monto, a.impuesto, a.descuento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.usuario_creacion, a.fecha_creacion, a.cod_ref, a.tipo_docto_ref, a.cliente||decode(interfaz_far,'S',' - '||campo8,'') as cliente, a.identificacion, nvl(a.impreso, 'N') impreso, a.codigo_dgi, a.campo1, a.campo2, a.campo3, a.campo4, a.campo5, a.campo6, a.campo7, a.dv, a.ruc_cedula, to_char(nvl(a.fecha_impresion,a.impresion_timestamp), 'dd/mm/yyyy hh12:mi:ss am') fecha_impresion, nvl(substr(a.impresion_webuser_ip,0,instr(a.impresion_webuser_ip,':') - 1),' ') as impreso_por, decode(nvl(a.impreso,'N'),'N',' ',case when a.tipo_docto in ('NC','ND') then (select codigo_dgi from tbl_fac_dgi_documents where tipo_docto = 'FACT' and cod_ref = a.cod_ref) when a.tipo_docto in ('FACP','FACT') then ' ' else a.cod_ref end) as codigo_dgi_ref from tbl_fac_dgi_documents a where a.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(appendFilter);
sbSql.append(" order by a.fecha desc, nvl(a.fecha_impresion,impresion_timestamp) desc");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "DOCUMENTOS DGI";
	String subtitle = "";
	String xtraSubtitle = "";
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
			dHeader.addElement(".08");
			dHeader.addElement(".07");
			dHeader.addElement(".04");
			dHeader.addElement(".15");
			dHeader.addElement(".20");
			dHeader.addElement(".10");
			dHeader.addElement(".07");
			dHeader.addElement(".07");
			dHeader.addElement(".07");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);

		pc.addBorderCols("CODIGO DGI",1);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("FECHA",1);
		pc.addBorderCols("TIPO DOC.",1);
		pc.addBorderCols("CODIGO DGI REF.",1);
		pc.addBorderCols("CLIENTE",1);
		pc.addBorderCols("IDENTIFICACION",1);
		pc.addBorderCols("MONTO",1);
		pc.addBorderCols("IMPRESO POR",1);
		pc.addBorderCols("FECHA IMPR.",1);


		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table


	//table body
	pc.setVAlignment(0);
	pc.setFont(8, 0);

	double totMonto = 0.00;

	for (int i=0; i<al.size(); i++)
	{
		 cdo = (CommonDataObject) al.get(i);
		 totMonto += Double.parseDouble(cdo.getColValue("monto"));


		pc.addCols(cdo.getColValue("codigo_dgi"),0,1);
		pc.addCols(cdo.getColValue("codigo"),1,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("tipo_docto"),0,1);
		pc.addCols(cdo.getColValue("codigo_dgi_ref"),0,1);
		pc.addCols(cdo.getColValue("cliente"),0,1);
		pc.addCols(cdo.getColValue("identificacion"),1,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		pc.addCols(cdo.getColValue("impreso_por"),1,1);
		pc.addCols(cdo.getColValue("fecha_impresion"),1,1);



		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addCols(" ",0,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else {
		pc.addBorderCols(al.size()+" Registro(s) en total",0,(dHeader.size()-2),0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols(""+CmnMgr.getFormattedDecimal(totMonto), 2, 1,0.0f,0.5f,0.0f,0.0f);
		pc.addBorderCols("", 2, 1,0.0f,0.5f,0.0f,0.0f);
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>