<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
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
===============================================================================
===============================================================================
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
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String anio = request.getParameter("anio");
String unidad = request.getParameter("unidad");

if (anio == null) anio = "";
if (unidad == null) unidad = "";

if (anio.trim().equals("")) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
if (unidad.trim().equals("")) throw new Exception("La Unidad Administrativa no es válida. Por favor intente nuevamente!");

sbSql = new StringBuffer();
sbSql.append("select descripcion from tbl_sec_unidad_ejec where codigo = ");
sbSql.append(unidad);
sbSql.append(" and compania = ");
sbSql.append(session.getAttribute("_companyId"));
cdo = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.anio, a.tipo_inv, a.compania, a.codigo_ue, a.consec, a.descripcion, decode(a.categoria,1,'GENERADOR DE INGRESOS',2,'APOYO OPERATIVO',3,'APOYO ADMINISTRATIVO') as categoria, a.cantidad, decode(a.prioridad,1,'URGENTE',2,'MUY NECESARIO',3,'NECESARIO') as prioridad, a.codigo_proveedor, (select nombre_proveedor from tbl_com_proveedor where compania = a.compania and cod_provedor = a.codigo_proveedor) as descProveedor, a.origen, (select descripcion from tbl_sec_unidad_ejec where codigo = a.codigo_ue and compania = a.compania) as descUnidad, (select descripcion from tbl_con_tipo_inversion where tipo_inv = a.tipo_inv and compania = a.compania) as tipo_inv_desc, to_char(to_date(lpad(b.mes,2,'0'),'mm'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') as mes, b.cantidad_presupuestada, b.aprobado, nvl(b.cantidad,0) as cantidad, b.ejecutado, b.extraordinario, nvl(b.anioant_ejecutado,0) as anioant_ejec, b.aprobado - (nvl(b.ejecutado,0) + nvl(b.extraordinario,0) + nvl(b.anioant_ejecutado,0)) as disponible from tbl_con_inversion_anual a, tbl_con_inversion_mensual b where a.compania = ");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and a.codigo_ue = ");
sbSql.append(unidad);
sbSql.append(" and a.tipo_inv = b.tipo_inv and a.anio = b.anio and a.consec = b.consec and a.codigo_ue = b.codigo_ue and a.compania = b.compania order by a.anio, a.tipo_inv, a.consec, to_number(b.mes)");
al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+System.currentTimeMillis()+".pdf";

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
	String title = "PRESUPUESTO";
	String subtitle = "INVERSIONES ANUALES Y SU DIST. MENSUAL - "+anio;
	String xtraSubtitle = "UNIDAD ADMINISTRATIVA: "+cdo.getColValue("descripcion");
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".07");
	dHeader.addElement(".15");
	dHeader.addElement(".09");
	dHeader.addElement(".12");
	dHeader.addElement(".09");
	dHeader.addElement(".12");
	dHeader.addElement(".12");
	dHeader.addElement(".12");
	dHeader.addElement(".12");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	int cantEjec = 0, cantEjecT = 0;
	double presApro = 0.0, presAnioActual = 0.0, presExtr = 0.0, presAnioAnt = 0.0, disp = 0.0;
	double presAproT = 0.0, presAnioActualT = 0.0, presExtrT = 0.0, presAnioAntT = 0.0, dispT = 0.0;
	String key = "";
	for (int i=0; i<al.size(); i++)
	{
		cdo = (CommonDataObject) al.get(i);

		if (!key.equalsIgnoreCase(cdo.getColValue("codigo_ue")+"-"+cdo.getColValue("anio")+"-"+cdo.getColValue("tipo_inv")+"-"+cdo.getColValue("consec")))
		{
			if (i != 0)
			{
				pc.flushTableBody(true);
				pc.setFont(8,1);
				pc.addCols(" ",1,1,20.0f);
				pc.addBorderCols("T O T A L",2,2,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(presApro),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(cantEjec),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(presAnioActual),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(presExtr),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(presAnioAnt),2,1,0.0f,0.5f,0.0f,0.0f);
				pc.addBorderCols(CmnMgr.getFormattedDecimal(disp),2,1,0.0f,0.5f,0.0f,0.0f);
				cantEjec = 0;
				presApro = 0.0;
				presAnioActual = 0.0;
				presExtr = 0.0;
				presAnioAnt = 0.0;
				disp = 0.0;
			}

			pc.setVAlignment(0);
			pc.setFont(8,1);
			pc.addBorderCols("Consec.",1,1);
			pc.addBorderCols("Tipo Inversión",1,1);
			pc.addBorderCols("Descripción",1,4);
			pc.addBorderCols("Categoría",1,2);
			pc.addBorderCols("Prioridad",1,1);

			pc.setFont(8,0);
			pc.addCols(cdo.getColValue("consec"),0,1);
			pc.addCols(cdo.getColValue("tipo_inv_desc"),0,1);
			pc.addCols(cdo.getColValue("descripcion"),0,4);
			pc.addCols(cdo.getColValue("categoria"),0,2);
			pc.addCols(cdo.getColValue("prioridad"),0,1);

			pc.setFont(8,1);
			pc.addCols(" ",1,1);
			pc.addBorderCols("Mes",1,1);
			pc.addBorderCols("Cant. Presup",1,1);
			pc.addBorderCols("Presup. Aprobado",1,1);
			pc.addBorderCols("Cant. Ejec",1,1);
			pc.addBorderCols("Presup. Año Actual",1,1);
			pc.addBorderCols("Presup. Extraordinario",1,1);
			pc.addBorderCols("Presup. Año Anterior",1,1);
			pc.addBorderCols("Disponible",1,1);
		}

		pc.setFont(8,0);
		pc.addCols(" ",1,1);
		pc.addCols(cdo.getColValue("mes"),0,1);
		pc.addCols(cdo.getColValue("cantidad_presupuestada"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("aprobado")),2,1);
		pc.addCols(cdo.getColValue("cantidad"),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("ejecutado")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("extraordinario")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("anioant_ejec")),2,1);
		pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("disponible")),2,1);

		presApro += Double.parseDouble(cdo.getColValue("aprobado"));
		cantEjec += Integer.parseInt(cdo.getColValue("cantidad"));
		presAnioActual += Double.parseDouble(cdo.getColValue("ejecutado"));
		presExtr += Double.parseDouble(cdo.getColValue("extraordinario"));
		presAnioAnt += Double.parseDouble(cdo.getColValue("anioant_ejec"));
		disp += Double.parseDouble(cdo.getColValue("disponible"));

		presAproT += Double.parseDouble(cdo.getColValue("aprobado"));
		cantEjecT += Integer.parseInt(cdo.getColValue("cantidad"));
		presAnioActualT += Double.parseDouble(cdo.getColValue("ejecutado"));
		presExtrT += Double.parseDouble(cdo.getColValue("extraordinario"));
		presAnioAntT += Double.parseDouble(cdo.getColValue("anioant_ejec"));
		dispT += Double.parseDouble(cdo.getColValue("disponible"));

		key = cdo.getColValue("codigo_ue")+"-"+cdo.getColValue("anio")+"-"+cdo.getColValue("tipo_inv")+"-"+cdo.getColValue("consec");
	}//for i

	pc.flushTableBody(true);
	pc.setFont(8,1);
	pc.addCols(" ",1,1,20.0f);
	pc.addBorderCols("T O T A L",2,2,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presApro),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(cantEjec),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presAnioActual),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presExtr),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presAnioAnt),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(disp),2,1,0.0f,0.5f,0.0f,0.0f);

	pc.setFont(8,1);
	pc.addBorderCols("G R A N   T O T A L",2,3,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presAproT),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(cantEjecT),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presAnioActualT),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presExtrT),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(presAnioAntT),2,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(CmnMgr.getFormattedDecimal(dispT),2,1,0.0f,0.5f,0.0f,0.0f);

	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>