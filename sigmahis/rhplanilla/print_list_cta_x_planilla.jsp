<%@ page errorPage="../error.jsp"%>
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
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();

if (appendFilter == null) appendFilter = "";
sql="select distinct a.cod_compania, a.cod_planilla, a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 as cuenta, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.cod_concepto, a.lado, decode(a.tipo,'A','DETALLADA','G','GLOBAL') as tipo, b.descripcion as cosd, '[ '||a.cod_concepto||' ] '||c.descripcion as nameConcepto, d.nombre as namePlanilla,(select descripcion from tbl_sec_unidad_ejec where codigo=a.unidad_adm and compania=a.cod_compania ) descUnd,a.tipo cod_tipo,a.unidad_adm from tbl_pla_cuenta_planilla a, tbl_con_catalogo_gral b, tbl_pla_cuenta_concepto c, tbl_pla_planilla d where a.cta1=b.cta1(+) and a.cta2=b.cta2(+) and a.cta3=b.cta3(+) and a.cta4=b.cta4(+) and a.cta5=b.cta5(+) and a.cta6=b.cta6(+) and a.cod_compania=b.compania(+) and a.cod_concepto=c.cod_concepto(+)  and a.cod_compania=c.cod_compania(+) and  a.cod_planilla = d.cod_planilla(+) and a.cod_compania=d.compania(+) and a.cod_compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by  a.cod_planilla ,a.tipo desc,a.unidad_adm";

al = SQLMgr.getDataList(sql);

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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = "CUENTAS POR PLANILLA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  dHeader.addElement(".15");
		dHeader.addElement(".27");
		dHeader.addElement(".18");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".25");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(7, 1);
		pc.addBorderCols("Cuenta",1,1);
		pc.addBorderCols("Nombre de Cuenta",1,1);
		pc.addBorderCols("Unidad",1,1);
		pc.addBorderCols("Lado ",1,1);
		pc.addBorderCols("Tipo de Cuenta",1,1);
		pc.addBorderCols("Cod.Concepto",1,1);


	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
		String pla = "";

	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!pla.equalsIgnoreCase(cdo.getColValue("cod_planilla")))
			{

			pc.setFont(7, 2);
			pc.addCols(" ",0,dHeader.size());
			pc.addCols(" "+cdo.getColValue("cod_planilla")+" - "+cdo.getColValue("namePlanilla"),0,dHeader.size());
			}

		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("cuenta"),0,1);
			pc.addCols(" "+cdo.getColValue("cosd"),0,1);
			pc.addCols(" "+cdo.getColValue("descUnd"),0,1);
			pc.addCols(" "+cdo.getColValue("lado"),1,1);
			pc.addCols(" "+cdo.getColValue("tipo"),0,1);
			pc.addCols(" "+cdo.getColValue("nameConcepto"),0,1);



		pla=cdo.getColValue("cod_planilla");

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}

		if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
		else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>