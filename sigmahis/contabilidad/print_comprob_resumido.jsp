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
StringBuffer sbFilter = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String estado = request.getParameter("estado");
String fechaIni = request.getParameter("fechaIni");
String fechaFin = request.getParameter("fechaFin");
String fp = request.getParameter("fp");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String no = request.getParameter("no");
String clase = request.getParameter("clase");
String group_type = request.getParameter("group_type");
String regType = request.getParameter("regType");
String tipo = request.getParameter("tipo");
String pMes13 = request.getParameter("pMes13");
String pRegManual = request.getParameter("pRegManual");

StringBuffer sbTable = new StringBuffer();

if (anio == null) anio = "";
if (mes == null) mes = "";
if (estado == null) estado = "";
if (fechaIni == null) fechaIni = "";
if (fechaFin == null) fechaFin = "";
if (no == null) no = "";
if (clase == null) clase = "";
if (group_type == null) group_type = "";
if (regType == null)regType="";
if (tipo == null) tipo = "";
if (pMes13 == null) pMes13 = "";
if (pRegManual == null) pRegManual = "";
if (appendFilter == null) appendFilter = "";
sbFilter = new StringBuffer(appendFilter);

if (!anio.trim().equals("")&&fechaIni.trim().equals("")) { sbFilter.append(" and a.ea_ano = "); sbFilter.append(anio); }
if (!mes.trim().equals("")&&fechaIni.trim().equals("")) { sbFilter.append(" and a.mes = to_number("); sbFilter.append(mes); sbFilter.append(")"); }
if (fp.trim().equals("mens")) {
if (estado.trim().equals("")) { sbFilter.append(" and a.status not in ('DE')"); }
else { sbFilter.append(" and a.status = '"); sbFilter.append(estado); sbFilter.append("'"); }
}
if (!fechaIni.trim().equals("")&&anio.trim().equals("")){sbFilter.append(" and trunc(a.fecha_comp) >= to_date('"); sbFilter.append(fechaIni);sbFilter.append("','dd/mm/yyyy')"); }
if (!fechaFin.trim().equals("")&&anio.trim().equals("")){sbFilter.append(" and trunc(a.fecha_comp) <= to_date('"); sbFilter.append(fechaFin);sbFilter.append("','dd/mm/yyyy')"); }
if (!no.trim().equals("")) { sbFilter.append(" and a.consecutivo = "); sbFilter.append(no); }
if (!clase.trim().equals("")) { sbFilter.append(" and a.clase_comprob in ("); sbFilter.append(clase); sbFilter.append(")"); }
if (!group_type.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_con_clases_comprob where codigo_comprob = a.clase_comprob and tipo='C' and group_type = "); sbFilter.append(group_type); sbFilter.append(")"); }
if (!regType.trim().equals("")) { sbFilter.append(" and a.reg_type = '"); sbFilter.append(regType);sbFilter.append("'"); }
if (!tipo.trim().equals("")) { sbFilter.append(" and a.tipo ="); sbFilter.append(tipo);}
if(pMes13.trim().equals("S"))
{  
	if(pRegManual.trim().equals("S")) sbFilter.append(" and a.creado_por = 'RCM' ");
}

sbTable.append(" tbl_con_encab_comprob a, tbl_con_detalle_comprob b ");

sbSql.append("select z.*, (select descripcion from tbl_con_clases_comprob where codigo_comprob = z.clase_comprob and tipo='C') as descComprob, (select (select descripcion from tbl_con_group_comprob where id = y.group_type) from tbl_con_clases_comprob y where codigo_comprob = z.clase_comprob and y.tipo='C') as group_type, (select descripcion from tbl_con_catalogo_gral where cta1 = z.cta1 and cta2 = z.cta2 and cta3 = z.cta3 and cta4 = z.cta4 and cta5 = z.cta5 and cta6 = z.cta6 and compania = z.compania) as cuentaDesc from (");


	sbSql.append("select a.compania, a.clase_comprob, b.cta1, b.cta2, b.cta3, b.cta4, b.cta5, b.cta6, b.cta1||'-'||b.cta2||'-'||b.cta3||'-'||b.cta4||'-'||b.cta5||'-'||b.cta6 as cuenta, sum(nvl(decode(b.tipo_mov,'DB',b.valor),0)) as db, sum(nvl(decode(b.tipo_mov,'CR',b.valor),0)) as cr from ");
	sbSql.append(sbTable);
	sbSql.append(" where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" and ((b.compania = a.compania and b.ano = a.ea_ano and b.consecutivo = a.consecutivo and a.tipo=b.tipo and a.reg_type=b.reg_type)) ");
	
	if (!fp.trim().equals("listComp"))sbSql.append(" and a.estado = 'A' and a.tipo <> 2 ");
	
	sbSql.append("  group by a.compania,a.clase_comprob, b.cta1, b.cta2, b.cta3, b.cta4, b.cta5, b.cta6");
	
sbSql.append(") z ");

sbSql.append(" order by 13, z.clase_comprob, z.cta1, z.cta2, z.cta3, z.cta4, z.cta5, z.cta6");
al = SQLMgr.getDataList(sbSql.toString());

if (mes.trim().equals("")) mes = fecha.substring(3,5);
if (anio.trim().equals("")) anio = fecha.substring(6,10);

sbSql = new StringBuffer();
sbSql.append("select ");
if (!mes.trim().equals("13")){
if (!fechaIni.trim().equals("")) {

	sbSql.append("'DEL '||replace(to_char(to_date('");
	sbSql.append(fechaIni);
	sbSql.append("','dd/mm/yyyy'),'dd FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH'),' ',' DE ')||");

}

if (!fechaFin.trim().equals("")) {

	sbSql.append("' AL '||replace(to_char(to_date('");
	sbSql.append(fechaFin);
	sbSql.append("','dd/mm/yyyy'),'dd FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH'),' ',' DE ')");

} else {

	sbSql.append("' AL '||replace(to_char(last_day(to_date('");
	sbSql.append(mes);
	sbSql.append("/");
	sbSql.append(anio);
	sbSql.append("','mm/yyyy')),'dd FMMONTH yyyy','NLS_DATE_LANGUAGE=SPANISH'),' ',' DE ')");

}
}else {sbSql.append("  'MES CIERRE  "+anio+"' ");}
sbSql.append(" as fecha from dual");
cdoSI = SQLMgr.getData(sbSql.toString());


if (request.getMethod().equalsIgnoreCase("GET")) {
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
	String subtitle = "COMPROBANTE"+(fp.trim().equals("mens")?"S MENSUALES ":"");
	String xtraSubtitle = "";
	if(fp.trim().equals("listComp")){if(regType.trim().equals("D"))subtitle +=" DIARIO ";else subtitle +=" HISTORICO " ; subtitle +=" NO: "+anio+" - "+no;}else xtraSubtitle = cdoSI.getColValue("fecha");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

			dHeader.addElement(".20");
			dHeader.addElement(".25");
			dHeader.addElement(".25");
			dHeader.addElement(".15");
			dHeader.addElement(".15");


PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(8, 1);
		pc.addBorderCols(" NO. CUENTA",0,1);
		pc.addBorderCols(" DESCRIPCION ",0,2);
		pc.addBorderCols(" DEBITO",2,1);
		pc.addBorderCols(" CREDITO",2,1);
		pc.setTableHeader(2);//create de table header (1 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	pc.setFont(7, 0);
	String sgroupBy = "", groupBy = "", descTipo="", descGrupo="";
	double saldo = 0.00;
	double totalDb = 0.00,montoDb=0.00,montoCr=0.00;
	double totalCr = 0.00,totalDbDet  =0.00,totalCrDet  =0.00;
	double gCr = 0.0, gDb = 0.0;

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		pc.setFont(fontSize, 0);

		totalDb += Double.parseDouble(cdo.getColValue("db"));
		totalCr += Double.parseDouble(cdo.getColValue("cr"));
		//montoDb += Double.parseDouble(cdo.getColValue("total_db"));
		//montoCr += Double.parseDouble(cdo.getColValue("total_cr"));

		if (!sgroupBy.equals(cdo.getColValue("group_type"))) {
			if (i != 0) {
				pc.setFont(fontSize+1,0,Color.blue);
				pc.addCols(" TOTAL COMPROBANTE:  "+descTipo,2,3);
				pc.addCols(CmnMgr.getFormattedDecimal(totalDbDet),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalCrDet),2,1);

				pc.setFont(fontSize+1,1,Color.blue);
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" TOTAL GRUPO:  "+descGrupo,0,3);
				pc.addCols(CmnMgr.getFormattedDecimal(gDb),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(gCr),2,1);
				pc.addCols(" ",1,dHeader.size());
			}

			pc.setFont(fontSize+1,1,Color.blue);
			pc.addCols("GRUPO:    "+cdo.getColValue("group_type"),0,dHeader.size());
			pc.setFont(fontSize+1,0,Color.blue);
			pc.addCols(" ",1,dHeader.size());
			pc.addCols(" COMPROBANTE:    "+cdo.getColValue("descComprob"),2,dHeader.size()-2);
			pc.addCols(" ",1,2);
			totalDbDet  =0.00;
			totalCrDet  =0.00;
			gDb = 0.0;
			gCr = 0.0;
		} else if (!groupBy.equals(cdo.getColValue("clase_comprob"))) {
			pc.setFont(fontSize+1,0,Color.blue);
			if (i != 0) {
				pc.addCols(" ",1,dHeader.size());
				pc.addCols(" TOTAL COMPROBANTE:  "+descTipo,2,3);
				pc.addCols(CmnMgr.getFormattedDecimal(totalDbDet),2,1);
				pc.addCols(CmnMgr.getFormattedDecimal(totalCrDet),2,1);
				pc.addCols(" ",1,dHeader.size());
			}

			pc.addCols(" COMPROBANTE:    "+cdo.getColValue("descComprob"),2,dHeader.size()-2);
			pc.addCols(" ",1,2);
			totalDbDet  =0.00;
			totalCrDet  =0.00;
		}
		pc.setFont(fontSize, 0);
		pc.addCols(cdo.getColValue("cuenta"),0,1);
		pc.addCols(cdo.getColValue("cuentaDesc"),0,2);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("db")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("cr")),2,1);
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);

		totalDbDet += Double.parseDouble(cdo.getColValue("db"));
		totalCrDet += Double.parseDouble(cdo.getColValue("cr"));
		descTipo = cdo.getColValue("descComprob");
		groupBy =cdo.getColValue("clase_comprob");

		gDb += Double.parseDouble(cdo.getColValue("db"));
		gCr += Double.parseDouble(cdo.getColValue("cr"));
		descGrupo = cdo.getColValue("group_type");
		sgroupBy = cdo.getColValue("group_type");
	}
	//pc.addCols(" ",1,dHeader.size());
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{
		pc.setFont(fontSize+1,0,Color.blue);
		pc.addCols(" TOTAL COMPROBANTE:  "+descTipo,2,3);
		pc.addCols(CmnMgr.getFormattedDecimal(totalDbDet),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totalCrDet),2,1);

		pc.setFont(fontSize+1,1,Color.blue);
		pc.addCols(" ",1,dHeader.size());
		pc.addCols(" TOTAL GRUPO:  "+descGrupo,0,3);
		pc.addCols(CmnMgr.getFormattedDecimal(gDb),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(gCr),2,1);
		pc.addCols(" ",1,dHeader.size());

		pc.setFont(fontSize+2,1,Color.blue);
		pc.addCols(" GRAN TOTAL     ",2,3);
		pc.addCols(CmnMgr.getFormattedDecimal(totalDb),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(totalCr),2,1);

		pc.setFont(fontSize,0,Color.blue);
		pc.addCols(" ",1,dHeader.size());
		pc.addCols(" ",1,dHeader.size());
		pc.addBorderCols(" Revisado por :     ",1,2, 0.0f, 0.5f, 0.0f, 0.0f);
		pc.addCols("  ",1,1);
		pc.addBorderCols(" Contabilizado por :    ",1,2, 0.0f, 0.5f, 0.0f, 0.0f);

	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>