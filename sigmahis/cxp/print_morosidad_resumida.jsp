<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator"%>
<%@ include file="../common/pdf_header.jsp"%>


<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p?gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlTot = new StringBuffer();
CommonDataObject cdoT = new CommonDataObject();

String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String compania = request.getParameter("compania");
String proveedor = request.getParameter("proveedor");
String fecha_inicial = request.getParameter("fecha");
String tipo_proveedor = request.getParameter("tipo_proveedor");
String con_morosidad = request.getParameter("con_morosidad");

if (appendFilter == null) appendFilter = "";

if (compania == null ) compania = (String) session.getAttribute("_companyId");
if (proveedor == null ) proveedor = "";
if (tipo_proveedor == null ) tipo_proveedor = "";
if (con_morosidad == null ) con_morosidad = "";


sbSql.append(" select nvl(m.cod_prov,0) proveedor, nvl((select nombre_proveedor from tbl_com_proveedor where cod_provedor = m.cod_prov),' ') as desc_proveedor, sum(nvl(m.scorriente,0)) scorriente, sum(nvl(m.s30,0)) s30, sum(nvl(m.s60,0)) s60, sum(nvl(m.s90,0)) s90, sum(nvl(m.s120,0)) s120, sum(nvl(m.scorriente,0) + nvl(m.s30,0) + nvl(m.s60,0) + nvl(m.s90,0) + nvl(m.s120,0)) saldo_actual from tbl_cxp_morosidad m where /*m.factura not like 'F SI_%' and*/ m.cia = ");
sbSql.append(compania);

if (!proveedor.trim().equals("")){
sbSql.append(" and m.cod_prov = ");
sbSql.append(proveedor);

}
if (!tipo_proveedor.trim().equals("")) {
sbSql.append(" and exists (select null from tbl_com_proveedor where cod_provedor = m.cod_prov and tipo_prove = '");
sbSql.append(tipo_proveedor);
sbSql.append("')");
}
sbSql.append(" and to_date(m.fecha,'dd/mm/yyyy') <= to_date('");
sbSql.append(fecha_inicial);
sbSql.append("' ,'dd/mm/yyyy')");

sbSql.append(" group by m.cod_prov ");
if(con_morosidad.equals("S")){
sbSql.append(" having SUM (NVL (m.scorriente, 0) + NVL (m.s30, 0) + NVL (m.s60, 0) + NVL (m.s90, 0) + NVL (m.s120, 0)) > 0");
sbSql.append(" order by 2 asc");
}
al = SQLMgr.getDataList(sbSql.toString());

sbSqlTot.append("select sum(scorriente) scorriente, sum(s30) s30, sum(s60) s60, sum(s90) s90, sum(s120) s120, sum(saldo_actual) saldo_actual from (");
sbSqlTot.append(sbSql.toString());
sbSqlTot.append(")");
cdoT = SQLMgr.getData(sbSqlTot.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "REPORTE DE MOROSIDAD RESUMIDO";
	String subtitle = " AL "+fecha_inicial;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);



				Vector dHeader=new Vector();
				dHeader.addElement(".07");
				  dHeader.addElement(".33");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");
					dHeader.addElement(".10");



				pc.setNoColumnFixWidth(dHeader);
				pc.createTable();
				pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

				pc.setFont(headerFontSize,1);
				pc.addBorderCols("Cod.Prov",0,1);
				pc.addBorderCols("Nombre Proveedor",0);
				pc.addBorderCols("Corriente",2);
				pc.addBorderCols("A 30 dias",2);
				pc.addBorderCols("A 60 dias",2);
				pc.addBorderCols("A 90 dias",2);
				pc.addBorderCols("A 120 dias",2);
				pc.addBorderCols("Total por Cia.",2);

				pc.setTableHeader(2);//create de table header

			//table body
			String groupBy = "",groupBy2 = "",groupBy3="";
			String groupTitle = "",groupTitle2 = "",groupTitle3="";
			String tipo="";
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo1 = (CommonDataObject) al.get(i);


				  pc.setFont(8, 0);
				  pc.addBorderCols(""+cdo1.getColValue("proveedor"),0,1);
					pc.addBorderCols(""+cdo1.getColValue("desc_proveedor"),0,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("scorriente")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s30")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s60")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s90")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("s120")),2,1);
					pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo_actual")),2,1);


		}

		if (al.size()==0)pc.addCols("No existe Registros para este Reporte ",1,dHeader.size());
		else
		{


				pc.setFont(8, 1,Color.blue);
				pc.addBorderCols("TOTALES ", 0,2, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("scorriente")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s30")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s60")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s90")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("s120")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);
				pc.addBorderCols(""+CmnMgr.getFormattedDecimal(cdoT.getColValue("saldo_actual")),2,1, 0.0f, 0.5f, 0.0f, 0.0f);


		}



pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>

