<%//@ page errorPage="../error.jsp"%>
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
ArrayList al = new ArrayList();

String compania = (String) session.getAttribute("_companyId");

String userName = UserDet.getUserName();
String sql = "", sql2 = "";

String _option = request.getParameter("opt");
String anio_ini = request.getParameter("anio_i");
String mes_ini = request.getParameter("mes_i");
String subTitle = "";

Hashtable _mes = new Hashtable();

if (mes_ini != null ){
  _mes.put("01","Enero");
  _mes.put("02","Febrero");
  _mes.put("03","Marzo");
  _mes.put("04","Abril");
  _mes.put("05","Mayo");
  _mes.put("06","Junio");
  _mes.put("07","Julio");
  _mes.put("08","Agosto");
  _mes.put("09","Septiembre");
  _mes.put("10","Octubre");
  _mes.put("11","Noviembre");
  _mes.put("12","Diciembre");
 }

if ( _option == null || _option.equals("") ) throw new Exception("La opción de impresión no es válida!");
if ( anio_ini == null || anio_ini.equals("") || mes_ini == null || mes_ini.equals("") ) throw new Exception("El año o el mes no es válido!");

if (_option.equalsIgnoreCase("x_tot_gasto_sal_dept")) {

     subTitle = "ESTADÍSTICA MENSUAL DE EMPLEADOS Y GASTOS DE SALARIOS POR SECCIÓN";
	 
	 sql = "SELECT NVL(A.UBIC_SECCION,999) UBIC_SECCION, U.DESCRIPCION, COUNT(*) CANTIDAD, SUM(NVL(B.SAL_BRUTO,0)) SAL_BRUTO FROM  TBL_PLA_EMPLEADO A, TBL_PLA_PAGO_EMPLEADO B, TBL_PLA_PLANILLA_ENCABEZADO C, TBL_SEC_UNIDAD_EJEC U WHERE A.EMP_ID = B.EMP_ID    AND    B.COD_COMPANIA =A.COMPANIA   AND  C.ANIO  = B.ANIO AND  C.COD_PLANILLA = B.COD_PLANILLA AND C.NUM_PLANILLA = B.NUM_PLANILLA AND  C.COD_COMPANIA = B.COD_COMPANIA AND C.ANIO = "+anio_ini+" AND    U.CODIGO = A.UBIC_SECCION AND    U.COMPANIA = A.COMPANIA AND    TO_NUMBER(TO_CHAR(C.FECHA_PAGO,'MM')) = "+mes_ini+" AND A.FECHA_INGRESO <= LAST_DAY(TO_DATE('01/'||"+mes_ini+"||'/'||"+anio_ini+",'DD/MM/YYYY')) AND (A.FECHA_EGRESO >  LAST_DAY(TO_DATE('01/'||"+mes_ini+"||'/'||"+anio_ini+",'DD/MM/YYYY')) OR A.FECHA_EGRESO IS NULL) AND A.COMPANIA = "+compania+" GROUP BY NVL(A.UBIC_SECCION,999) , U.DESCRIPCION ORDER BY UBIC_SECCION";
	 
}else{

	 subTitle = "ESTADÍSTICA MENSUAL DE EMPLEADOS Y GASTOS DE SALARIOS GENERAL";
	 
	 sql = "SELECT U.NOMBRE,   COUNT(*) CANTIDAD,  SUM(NVL(B.SAL_BRUTO,0)) V_SALARIO FROM TBL_PLA_EMPLEADO A, TBL_PLA_PAGO_EMPLEADO B, TBL_PLA_PLANILLA_ENCABEZADO C, TBL_SEC_COMPANIA U WHERE B.EMP_ID = A.EMP_ID  AND    B.COD_COMPANIA = A.COMPANIA  AND    C.ANIO     = B.ANIO AND    C.COD_PLANILLA = B.COD_PLANILLA AND    C.NUM_PLANILLA = B.NUM_PLANILLA AND    C.COD_COMPANIA = B.COD_COMPANIA AND  C.ANIO = "+anio_ini+" AND A.COMPANIA = U.CODIGO AND    TO_NUMBER(TO_CHAR(C.FECHA_PAGO,'MM')) = "+mes_ini+" AND  A.FECHA_INGRESO      <= LAST_DAY(TO_DATE('01/'||"+mes_ini+"||'/'||"+anio_ini+",'DD/MM/YYYY')) AND (A.FECHA_EGRESO  >  LAST_DAY(TO_DATE('01/'||"+mes_ini+"||'/'||"+anio_ini+",'DD/MM/YYYY')) OR  A.FECHA_EGRESO IS NULL) GROUP BY  U.NOMBRE";
}

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
	float height = 72 *11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 5.0f;
	float topMargin = 9.5f;
	float bottomMargin = 1.0f;
	float headerFooterFont = 4f;
	boolean logoMark = true;
	boolean statusMark = false;
	StringBuffer sbFooter = new StringBuffer();
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = subTitle;
	String xtraSubtitle = " CORRESPONDE AL MES DE "+""+_mes.get(mes_ini).toString().toUpperCase()+" DE "+anio_ini;
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
	
	pc.setVAlignment(3);
	int cant = 0;
	double totSalBruto = 0.0;
	
	if ( al.size() == 0 ) { 
	
			pc.setFont(9,0);
			pc.addCols("No hemos encontrado registros!!! ",1,dHeader.size());
	
	}else{
	  
			pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size(),15f);
		
			pc.addCols((_option.equalsIgnoreCase("x_tot_gasto_sal_dept")?"UNIDAD ADMINISTRATIVA":"COMPAÑIA"),1,4);
			pc.addCols(" ",0,1);
			pc.addCols("CANTIDAD",0,1);
			pc.addCols(" ",0,1);
			pc.addCols("G. SALARIO",0,1);
			pc.addCols(" ",0,2);
		
			pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size(),15f);
			
			
			for ( int i = 0; i<al.size(); i++ ){
			     cdo = (CommonDataObject) al.get(i);
				 
				 if (!_option.equalsIgnoreCase("x_tot_gasto_sal_dept")) {
					 pc.addCols(" "+cdo.getColValue("NOMBRE"),0,4);
					 pc.addCols(" ",0,1);
					 pc.addCols(" "+cdo.getColValue("CANTIDAD"),0,1);
					 pc.addCols(" ",0,1);
					 pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("V_SALARIO")),0,1);
					 pc.addCols(" ",0,2);
				 }
				 else{
				     pc.addCols(" "+cdo.getColValue("DESCRIPCION"),0,4);
					 pc.addCols(" ",0,1);
					 pc.addCols(" "+cdo.getColValue("CANTIDAD"),0,1);
					 pc.addCols(" ",0,1);
					 pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("SAL_BRUTO")),0,1);
					 pc.addCols(" ",0,2);
					 
					 cant += Integer.parseInt(cdo.getColValue("CANTIDAD"));
					 totSalBruto += Double.parseDouble(cdo.getColValue("SAL_BRUTO"));
				 }
				 
			}//for i
	
		  pc.addCols(" ",0,dHeader.size(),15f);
		  
		  if (_option.equalsIgnoreCase("x_tot_gasto_sal_dept")) {
				pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size(),15f);
				
				pc.addCols("T O T A L E S   F I N A L E S",1,5);
				pc.addCols(""+cant,0,1);
				pc.addCols(" ",1,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(totSalBruto),0,1);
				pc.addCols(" ",0,2);
				
				pc.addCols("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",0,dHeader.size(),15f);
			}
			
		   pc.addCols(" ",0,dHeader.size(),20f);
	       pc.addCols("CONFECCIONADO POR:",0,2);
		   pc.addCols("_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _",0,dHeader.size()-2);
		   pc.addCols(" ",0,dHeader.size(),15f);
		   pc.addCols("REVISADO POR:",0,2);
		   pc.addCols("_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _",0,dHeader.size()-2);
	
	
	}//else
	
	
	
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//'GET
%>
