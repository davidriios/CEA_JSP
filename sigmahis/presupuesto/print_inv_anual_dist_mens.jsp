<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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

ArrayList al,al2 = new ArrayList();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSql2 = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String anio = request.getParameter("anio");
String unidad = request.getParameter("unidad");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
String compania = (String) session.getAttribute("_companyId");

Hashtable iMes = new Hashtable();
iMes.put("01","ENERO");
iMes.put("02","FEBRERO");
iMes.put("03","MARZO");
iMes.put("04","ABRIL");
iMes.put("05","MAYO");
iMes.put("06","JUNIO");
iMes.put("07","JULIO");
iMes.put("08","AGOSTO");
iMes.put("09","SEPTIEMBRE");
iMes.put("10","OCTUBRE");
iMes.put("11","NOVIEMBRE");
iMes.put("12","DICIEMBRE");

sbSql.append("select  a.anio, a.compania,a.tipo_inv tipoInv,a.descripcion,a.consec,DECODE(a.CATEGORIA, 1, 'GENERADOR DE INGRESOS', 2, 'APOYO OPERATIVO', 3,'APOYO ADMINISTRATIVO')  categoria,a.cantidad,DECODE(a.PRIORIDAD, 1, 'URGENTE', 2,'MUY NECESARIO', 3, 'NECESARIO') prioridad,a.codigo_proveedor  codigoProveedor,(select nombre_proveedor from tbl_com_proveedor where compania= a.compania and cod_provedor = a.codigo_proveedor)descProveedor, a.codigo_ue unidad,a.origen,  ue.descripcion descUnidad from tbl_con_inversion_anual a,tbl_sec_unidad_ejec ue where a.compania = ");
sbSql.append(compania);
sbSql.append(" and a.codigo_ue = ");
sbSql.append(unidad);
sbSql.append(" and a.anio = ");
sbSql.append(anio);
sbSql.append(" and  a.codigo_ue = ue.codigo and a.compania = ue.compania ");
sbSql.append(" order by a.anio desc");

al = SQLMgr.getDataList(sbSql.toString());

sbSql2.append("select m.mes, M.CANTIDAD_PRESUPUESTADA, M.APROBADO, nvl(M.CANTIDAD,0) cantidad, M.EJECUTADO, M.EXTRAORDINARIO, nvl(M.ANIOANT_EJECUTADO,0) anioant_ejec, m.aprobado - (nvl(m.ejecutado,0) + nvl(m.extraordinario,0)+ nvl(m.anioant_ejecutado,0)) disponible from  tbl_con_INVERSION_MENSUAL m where M.COMPANIA =");
sbSql2.append(compania);
sbSql2.append(" and m.codigo_ue = ");
sbSql2.append(unidad);
sbSql2.append(" and m.anio = ");
sbSql2.append(anio);
sbSql2.append(" order by m.mes");

al2 = SQLMgr.getDataList(sbSql2.toString());

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
	String title = "PRESUPUESTO";
	String subtitle = "INVERSIONES ANUALES Y SU DIST. MENSUAL";
	String xtraSubtitle = " ";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");
	dHeader.addElement(".10");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setFont(7,1,Color.white);
	pc.addCols("INVERSION ANUAL",0,dHeader.size(),Color.gray);

	pc.setFont(7,0);
	pc.addBorderCols("Año",1,1);
	pc.addBorderCols("Unidad",1,3);
	pc.addBorderCols("Descripción",1,3);
	pc.addBorderCols("Categoría",1,2);
	pc.addBorderCols("Prioridad",1,1);

	pc.setTableHeader(2);//create de table header

	double presApro = 0.0, cantEjec = 0.0, presAnioActual = 0.0, presExtr = 0.0, presAnioAnt = 0.0, disp = 0.0;

	for (int i=0; i<al.size(); i++)
	{
		cdo1 = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.addCols(" "+cdo1.getColValue("anio"),1,1);
		pc.addCols(" ["+cdo1.getColValue("unidad")+"] "+cdo1.getColValue("descUnidad"),0,3);
		pc.addCols(" "+cdo1.getColValue("descripcion"),0,3);
		pc.addCols(" "+cdo1.getColValue("categoria"),0,2);
		pc.addCols(" "+cdo1.getColValue("prioridad"),0,1);
	}

	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());

	pc.addCols(" ",0,dHeader.size());
	pc.setFont(7,1,Color.white);
	pc.addCols("INVERSION ANUAL",0,dHeader.size(),Color.gray);

	pc.setFont(7,0);
	pc.addBorderCols("Mes",1,2);
	pc.addBorderCols("Cant. Presup",1,1);
	pc.addBorderCols("Presupuesto Aprobado",2,1);
	pc.addBorderCols("Cant. Ejec",2,1);
	pc.addBorderCols("Presupuesto Año Actual",2,1);
	pc.addBorderCols("Presupuesto Extraordinario",2,1);
	pc.addBorderCols("Presupuesto Año Anterior",2,2);
	pc.addBorderCols("Disponible",2,1);

	for ( int j = 0; j<al2.size(); j++ ){
	   cdo2 = (CommonDataObject)al2.get(j);
	   pc.addCols(""+iMes.get(cdo2.getColValue("mes")),0,2);
	   pc.addCols(""+cdo2.getColValue("CANTIDAD_PRESUPUESTADA"),1,1);
	   pc.addCols(""+cdo2.getColValue("aprobado"),2,1);
	   pc.addCols(""+cdo2.getColValue("cantidad"),2,1);
	   pc.addCols(""+cdo2.getColValue("ejecutado"),2,1);
	   pc.addCols(""+cdo2.getColValue("extraordinario"),2,1);
	   pc.addCols(""+cdo2.getColValue("anioant_ejec"),2,2);
	   pc.addCols(""+cdo2.getColValue("disponible"),2,1);

	   presApro += Double.parseDouble(cdo2.getColValue("aprobado"));
	   cantEjec += Double.parseDouble(cdo2.getColValue("cantidad"));
	   presAnioActual += Double.parseDouble(cdo2.getColValue("ejecutado"));
	   presExtr += Double.parseDouble(cdo2.getColValue("extraordinario"));
	   presAnioAnt += Double.parseDouble(cdo2.getColValue("anioant_ejec"));
	   disp += Double.parseDouble(cdo2.getColValue("disponible"));
	}

	pc.addCols(" ",0,dHeader.size());
	pc.setFont(7,1);
	pc.addCols(" Totales --->",2,3);
	pc.addCols(CmnMgr.getFormattedDecimal(presApro),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(cantEjec),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(presAnioActual),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(presExtr),2,1);
	pc.addCols(CmnMgr.getFormattedDecimal(presAnioAnt),2,2);
	pc.addCols(CmnMgr.getFormattedDecimal(disp),2,1);


	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>