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
String acr       = request.getParameter("acr");
String fg        = request.getParameter("fg");

String filter = "", titulo = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (fechaini   == null) fechaini  = "";
if (fechafin   == null) fechafin  = "";
if (acr        == null) acr       = "";
if (fg         == null) fg        = "DESC"; //DESC = Listado de Descuentos por Empleados


if (!compania.equals(""))
  {
   appendFilter += " and c.codigo = "+compania;
  }    
if (!acr.equals(""))   
 {
  appendFilter += " and d.cod_acreedor = "+acr;
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


sql= " select all ac.cod_acreedor codAcreedor, ac.nombre nombreAcreedor, e.provincia, e.sigla, e.tomo, e.asiento, nvl(e.cedula1,e.cedula_beneficiario) cedula, e.nombre_empleado nombreEmpleado, e.num_empleado numEmpleado, e.emp_id empId, c.nombre descCia, c.logo, d.saldo, d.num_documento documento, d.descuento_mensual descMensual, to_char(d.fecha_inicial,'dd/mm/yyyy') fechaInicial from tbl_pla_acreedor ac, tbl_sec_compania c, tbl_pla_descuento d, vw_pla_empleado e where (e.emp_id = d.emp_id and e.compania = d.cod_compania) and (d.cod_acreedor = ac.cod_acreedor) and (d.cod_compania = ac.compania) and (d.cod_compania = c.codigo) and (d.estado <> 'E') and e.estado <> 3 "+appendFilter+" order by ac.cod_acreedor, e.primer_nombre||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.primer_apellido,decode(e.usar_apellido_casada,'S','DE '||e.apellido_casada,e.primer_apellido)), e.primer_apellido) ";
														
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
	String subtitle = " LISTADO DE SALDOS DE DESCUENTOS POR ACREEDOR ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".18");
		dHeader.addElement(".15");
		dHeader.addElement(".29");	
		dHeader.addElement(".23");			
		dHeader.addElement(".15");		
				
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = ""; 
		String sc = ""; 

    // Listado de Saldos de Descuentos por Acreedores
    pc.setFont(8, 1);
	pc.addBorderCols("No. EMP.",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("CÉDULA",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("NOMBRE DEL EMPLEADO",0,1,1.0f,1.0f,0.0f,0.0f);	
	pc.addBorderCols("No. DOCUMENTO",0,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("SALDO DEL DESCUENTO",1,1,1.0f,1.0f,0.0f,0.0f);	
  
   
	String groupBy = "";
	int pxu = 0, pxs = 0, pxg = 0;
	
	double totDescuento = 0;
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);			
		
	//Inicio --Agrupamiento por Acreedor
		if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codAcreedor")+" ] "+cdo.getColValue("nombreAcreedor")))
		{ // groupBy
			if (i != 0)
			  {//i-1 
				     // Listado de Saldos de Descuentos por Acreedor
				    pc.setFont(7, 1);
					pc.addCols("CANT. DE EMPLEADOS ==> "+" . . . "+pxu,0,2);
					pc.addCols(" ",0,1);
					pc.addBorderCols("MONTO TOTAL ==> "+CmnMgr.getFormattedDecimal(totDescuento),2,2,0.0f,1.0f,0.0f,0.0f);					
					pc.addCols(" ",0,dHeader.size());
					pxu = 0;	
			   }//i-1					  
				pc.setFont(8, 1);					
		pc.addCols("Acreedor:  "+"[ "+cdo.getColValue("codAcreedor")+" ] "+cdo.getColValue("nombreAcreedor"),0,dHeader.size());
				pxs++;
				totDescuento = 0;
		}//Final --Agrupamiento por Acreedor	
	
	
	    // Listado de Saldos de Descuentos por Acreedor
	    pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("numEmpleado"),1,1);		
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);		
			pc.addCols(" "+cdo.getColValue("nombreEmpleado"),0,1);	
			pc.addCols(" "+cdo.getColValue("documento"),0,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("saldo"))),2,1);							
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());	
			
		 totDescuento += (Double.parseDouble(cdo.getColValue("saldo")));	  

	  groupBy = "[ "+cdo.getColValue("codAcreedor")+" ] "+cdo.getColValue("nombreAcreedor");
	  pxu++;	   
	  //totDescuento += (Double.parseDouble(cdo.getColValue("descMensual")));
			
	 if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	
	}
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size()); 		  
		
	if (al.size() == 0) 
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	}
	else 
	{	// Listado de Saldos de Descuentos por Acreedor  
	    pc.setFont(7, 1);
		pc.addCols("CANT. DE EMPLEADOS ==> "+" . . . "+pxu,0,2);
		pc.addCols(" MONTO TOTAL ==> ",2,2);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totDescuento),2,1,0.0f,1.0f,0.0f,0.0f);		
		
	  pc.setFont(9,0); 
	  pc.addCols("TOTAL DE ACREEDORES "+" . . . "+pxs,1,dHeader.size());	
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>

