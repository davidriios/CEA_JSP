<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
PLANILLA: PLA0124
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoTot = new CommonDataObject();
ArrayList al = new ArrayList();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
String sql = "";

String _option = request.getParameter("opt");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String subTitle = "";
String mesDesc ="";

if (mes == null)mes="";
if (!mes.trim().equals("")){
if (mes.trim().equals("01"))mesDesc = "ENERO";
if (mes.trim().equals("02"))mesDesc = "FEBRERO";
if (mes.trim().equals("03"))mesDesc = "MARZO";
if (mes.trim().equals("04"))mesDesc = "ABRIL";
if (mes.trim().equals("05"))mesDesc = "MAYO";
if (mes.trim().equals("06"))mesDesc = "JUNIO";
if (mes.trim().equals("07"))mesDesc = "JULIO";
if (mes.trim().equals("08"))mesDesc = "AGOSTO";
if (mes.trim().equals("09"))mesDesc = "SEPTIEMBRE";
if (mes.trim().equals("10"))mesDesc = "OCTUBRE";
if (mes.trim().equals("11"))mesDesc = "NOVIEMBRE";
if (mes.trim().equals("12"))mesDesc = "DICIEMBRE";
}


if (_option == null || _option.equals("")) throw new Exception("La opción de impresión no es válida!");
if (anio == null || anio.equals("") || mes == null || mes.equals("")) throw new Exception("El año o el mes no es válido!");

if (_option.equalsIgnoreCase("gasto_rep")) {
     subTitle = "INFORME DE GASTO DE REPRESENTACION MENSUAL";
}

sql = "select pa.provincia, pa.sigla, pa.tomo, pa.asiento, nvl(pa.num_empleado,'0') num_empleado, em.nombre_empleado,em.cedula1 cedula, sum(nvl(pa.gasto_rep,0)) gasto_rep from tbl_pla_acumulado_mensual pa, vw_pla_empleado em where em.emp_id = pa.emp_id and em.compania  = pa.cod_compania and pa.cod_compania= "+compania+" and pa.mes = "+mes+" and pa.anio  = "+anio+" group by pa.provincia, pa.sigla, pa.tomo, pa.asiento, nvl(pa.num_empleado,'0'),em.nombre_empleado,em.cedula1 having sum(nvl(pa.gasto_rep,0)) <> 0 order by nombre_empleado";

al = SQLMgr.getDataList(sql);

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
	String title = "PLANILLA";
	String subtitle = subTitle;
	String xtraSubtitle = "CORRENPONDIENTE AL MES DE "+mesDesc+" DE "+anio ;
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

	double totGastoRep = 0.0;

	if ( al.size() == 0 ){
	    pc.setFont(8,1);
	    pc.addCols(" ",0,dHeader.size());
	    pc.addCols(" ",0,dHeader.size());
	    pc.addCols("****** NO EXISTEN REGISTROS! ******",1,dHeader.size());
	    pc.addCols(" ",0,dHeader.size());
	}else{
		pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(8,1);
		pc.addCols("   NO.",0,1);
		pc.addCols("CEDULA.",0,2);
		pc.addCols("NOMBRE",0,4);
		pc.addCols("GASTOS DE REP.",2,2);
		pc.addCols("  ",2,1);
		pc.setFont(9,1);
		pc.addCols("================================================================================================================",1,dHeader.size());

		for ( int i = 0; i<al.size(); i++ ){

			cdo = (CommonDataObject) al.get(i);

			pc.setFont(8,0);
			pc.addCols(cdo.getColValue("num_empleado"),0,1);
			pc.addCols(cdo.getColValue("cedula"),0,2);
			pc.addCols(cdo.getColValue("nombre_empleado"),0,4);
			pc.addCols(CmnMgr.getFormattedDecimal(cdo.getColValue("gasto_rep"))+"          ",2,2);
			pc.addCols("  ",2,1);

			totGastoRep += Double.parseDouble(cdo.getColValue("gasto_rep"));

			if ( (i+1) < al.size() ) pc.addBorderCols("",1,dHeader.size(),0.1f,0.0f,0.0f,0.0f);

		}//for i

	//FINALES TOTALES

		pc.setFont(9,1);
		pc.addCols("================================================================================================================",1,dHeader.size());

		pc.addCols("                TOTAL DE EMPLEADOS:    "+al.size(),0,3);
		pc.addCols(" ",0,2);
		pc.addCols("TOTAL FINAL:",2,2);
		pc.addCols(CmnMgr.getFormattedDecimal(totGastoRep)+"          ",2,2);
		pc.addCols("  ",2,1);

		pc.setFont(9,1);
		pc.addCols("================================================================================================================",1,dHeader.size());


   }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>