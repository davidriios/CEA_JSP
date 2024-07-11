<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

String filter = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (fechaini   == null) fechaini   = "";
if (fechafin   == null) fechafin   = "";

if (!compania.equals(""))
  {
   appendFilter += " and ac.compania = "+compania;
  }    

/*
if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(ac.fecha_creacion, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }

if (!fechafin.equals(""))
   {
appendFilter1 += " and to_date(to_char(ac.fecha_creacion, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
*/
	
sql = " select ac.cod_acreedor codAcreedor, ac.nombre nombreAcreedor, ac.direccion direccion, ac.telefono telefono, ac.fax fax, decode(ac.forma_pago,1,'CHEQUE',2,'ACREDITAMIENTO','---')  formaPago, decode(ac.tipo_cuenta,'A','AHO','C','COR','P','EMP','---') tipoCuenta, ac.ruta, ac.cuenta_bancaria cuentaBanco, decode(ac.estado,'A','ACTIVO','I','INACTIVO') estadoAcreedor, ac.ruc, ac.email, c.nombre descCia from tbl_pla_acreedor ac, tbl_sec_compania c where c.codigo = ac.compania "+appendFilter+" order by ac.nombre, ac.cod_acreedor ";	
														
 al = SQLMgr.getDataList(sql); 
 	

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	Hashtable htUni = new Hashtable();
	Hashtable htSec = new Hashtable();

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String subtitle = " INFORMACIÓN GENERAL DE ACREEDORES ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15");
		dHeader.addElement(".34");	
		dHeader.addElement(".15");
		dHeader.addElement(".36");	
		//dHeader.addElement(".05");		
		
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = ""; 
		String sc = ""; 
		
	/*pc.setFont(8, 1);
	pc.addCols("Cod.",1,1,Color.lightGray);
	pc.addCols("NOMBRE DEL ACREEDOR",0,1,Color.lightGray);	
	pc.addCols("TELÉFONO",1,1,Color.lightGray);	
	pc.addCols("DIRECCIÓN",0,1,Color.lightGray);
	pc.addCols("RUC",1,1,Color.lightGray);	
	*/
	
	String groupBy1 = "", groupBy2 = "", groupBy3 = "";
	int pxu = 0, pxs = 0, pxg = 0;
			 
	//table body  
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);		
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
		    pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
			pc.addCols(" ACREEDOR:        "+cdo.getColValue("codAcreedor")+" - ",1,1);	
			pc.addCols(" "+cdo.getColValue("nombreAcreedor"),0,1);		
			pc.addCols("  ",0,1);		
			pc.addCols(" ESTADO:  "+cdo.getColValue("estadoAcreedor"),1,1);		
			
	  		pc.addCols("     DIRECCIÓN: ",0,1);
			pc.addCols(" "+cdo.getColValue("direccion"),0,1);
			pc.addCols(" TELÉFONO: ",0,1);
			pc.addCols(" "+cdo.getColValue("telefono"),0,1);
			
			pc.addCols("     FAX: ",0,1);
			pc.addCols(" "+cdo.getColValue("fax"),0,1);
			pc.addCols(" FORMA PAGO: ",0,1);
			pc.addCols(" "+cdo.getColValue("formaPago"),0,1);
			
			pc.addCols("     RUTA: ",0,1);
			pc.addCols(" "+cdo.getColValue("ruta"),0,1);
			pc.addCols(" CUENTA BANCARIA: ",0,1);
			pc.addCols(" "+cdo.getColValue("cuentaBanco"),0,1);
			
			pc.addCols("     R.U.C.: ",0,1);
			pc.addCols(" "+cdo.getColValue("ruc"),0,1);
			pc.addCols(" E-MAIL: ",0,1);
			pc.addCols(" "+cdo.getColValue("email"),0,1);
			/*
			 pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
			
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());		
			*/
	if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	
		}
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size()); 
		  
		
	if (al.size() == 0) 
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	}
	else 
	{
	pc.setFont(9,0);
	pc.addBorderCols("TOTAL DE ACREEDORES "+" . . . "+al.size(),1,dHeader.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>
