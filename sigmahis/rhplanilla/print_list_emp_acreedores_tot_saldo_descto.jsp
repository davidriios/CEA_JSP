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
String fechaini   = request.getParameter("fechaini");
String fechafin   = request.getParameter("fechafin");
String acr        = request.getParameter("acr");
String tipoCuenta = request.getParameter("tipoCuenta");
String grupoDesc  = request.getParameter("grupoDesc");
String descMayor  = request.getParameter("descMayor");
//String descMenor  = request.getParameter("descMenor");

String filter = "", titulo = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (fechaini   == null) fechaini   = "";
if (fechafin   == null) fechafin   = "";
if (acr        == null) acr        = "";
if (tipoCuenta == null) tipoCuenta = "";
if (grupoDesc  == null) grupoDesc  = "";

if (!compania.equals(""))
  {
   appendFilter += " and pe.cod_compania = "+compania;
  }    
if (!acr.equals(""))   
 {
  appendFilter += " and d.cod_acreedor = "+acr;
 } 
/* if (!tipoCuenta.equals(""))
  {
   appendFilter += " and ac.tipo_cuenta = '"+tipoCuenta+"'";
  }
  */
  if(!grupoDesc.equals(""))
  {
   appendFilter += " and da.cod_grupo = "+grupoDesc;
  }
  
if (!fechaini.equals(""))
   {
  appendFilter += " and to_date(to_char(pe.fecha_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }

if (!fechafin.equals(""))
   {
   appendFilter += " and to_date(to_char(pe.fecha_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }

sql= " select da.cod_acreedor codAcreedor, ac.nombre nombreAcreedor, e.num_empleado numEmpleado, nvl(e.cedula1,e.cedula_beneficiario) cedula, e.nombre_empleado nombreEmpleado, d.num_documento numDocumento, d.saldo saldo, d.monto_total totalDescontar, da.cod_grupo codGrupo, gr.nombre descGrupo, sum(da.monto) montoTotal from tbl_pla_planilla_encabezado pe, tbl_pla_descuento_aplicado da, vw_pla_empleado e, tbl_pla_descuento d, tbl_pla_acreedor ac, tbl_pla_grupo_descuento gr where pe.cod_planilla in (select cod_planilla from planilla where beneficiarios = 'EM') and (da.anio = pe.anio and da.cod_planilla = pe.cod_planilla and da.num_planilla = pe.num_planilla and da.cod_compania = pe.cod_compania) and ( e.emp_id = da.emp_id  and e.compania = da.cod_compania) and (d.emp_id = da.emp_id and d.cod_compania = da.cod_compania and d.num_descuento = da.num_descuento) and (d.cod_acreedor = ac.cod_acreedor) and (d.cod_compania = ac.compania) and gr.cod_grupo = da.cod_grupo "+appendFilter+" group by da.cod_acreedor, ac.nombre, e.num_empleado, nvl(e.cedula1,e.cedula_beneficiario), e.nombre_empleado, d.num_documento, d.saldo, d.monto_total, da.cod_grupo, gr.nombre having sum(da.monto) >= "+descMayor+" order by da.cod_acreedor, e.nombre_empleado ";  
														
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
	String subtitle = " TOTAL DESCONTADO POR ACREEDOR (TOTAL-SALDO-DESCONTADO) ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".17");		
		dHeader.addElement(".38");				
		dHeader.addElement(".22");			
		dHeader.addElement(".15");	
		dHeader.addElement(".15");
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
    
    pc.setFont(8, 3);
	pc.addCols(" Total Descontado Mayor o Igual a :  $"+descMayor,0,dHeader.size());
	pc.setFont(8, 1);
	pc.addBorderCols("No. EMP.",1,1,1.0f,1.0f,0.0f,0.0f);	
	pc.addBorderCols("NOMBRE DEL EMPLEADO",0,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("DOCUMENTO",0,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("TOTAL",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("SALDO",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("DESCONTADO",2,1,1.0f,1.0f,0.0f,0.0f);	  
   
	String groupBy = "";
	int pxu = 0, pxs = 0, pxg = 0;
	
	double total = 0, totSaldo = 0, totDescontado = 0;
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);			
		
	//Inicio --Agrupamiento por Acreedor
		if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codAcreedor")+" ] "+cdo.getColValue("nombreAcreedor")))
		{ // groupBy
			if (i != 0)
			  {//i-1 
				   // Listado de Descuentos por Acreedor
				    pc.setFont(7, 1);
					pc.addCols("CANT. DE EMPLEADOS ==> "+" . . . "+pxu,0,2);
		            pc.addCols(" MONTO TOTAL ==> ",2,1);
		            pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(total),2,1,0.0f,1.0f,0.0f,0.0f);		
		            pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totSaldo),2,1,0.0f,1.0f,0.0f,0.0f);		
		            pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDescontado),2,1,0.0f,1.0f,0.0f,0.0f);				
					pc.addCols(" ",0,dHeader.size());
					pxu = 0;	
			   }//i-1					  
				pc.setFont(8, 1);					
		pc.addCols("Acreedor:  "+"[ "+cdo.getColValue("codAcreedor")+" ] "+cdo.getColValue("nombreAcreedor"),0,dHeader.size());					 
		
		 pxs++;
		 total = 0; totSaldo = 0; totDescontado = 0;
	   }//Final --Agrupamiento por Acreedor	
	
	    // Listado de Descuentos por Acreedor
	    pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("numEmpleado"),1,1);					
			pc.addCols(" "+cdo.getColValue("nombreEmpleado"),0,1);	
			pc.addCols(" "+cdo.getColValue("numDocumento"),0,1);									
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("totalDescontar"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("saldo"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("montoTotal"))),2,1);							
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());	
		
		 total         += (Double.parseDouble(cdo.getColValue("totalDescontar")));
		 totSaldo      += (Double.parseDouble(cdo.getColValue("saldo")));
		 totDescontado += (Double.parseDouble(cdo.getColValue("montoTotal")));	  

	  groupBy = "[ "+cdo.getColValue("codAcreedor")+" ] "+cdo.getColValue("nombreAcreedor");
	  pxu++;	 
			
	 if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	
	}// final del for
	
		pc.setFont(7, 0);
		pc.addCols("",0,dHeader.size()); 		  
		
	if (al.size() == 0) 
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	}
	else 
	{	
	    pc.setFont(7, 1);
		pc.addCols("CANT. DE EMPLEADOS ==> "+" . . . "+pxu,0,2);
		pc.addCols(" MONTO TOTAL ==> ",2,1);
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(total),2,1,0.0f,1.0f,0.0f,0.0f);		
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totSaldo),2,1,0.0f,1.0f,0.0f,0.0f);		
		pc.addBorderCols(" $"+CmnMgr.getFormattedDecimal(totDescontado),2,1,0.0f,1.0f,0.0f,0.0f);		
		
	  pc.setFont(9,0); 
	  pc.addCols("TOTAL DE ACREEDORES "+" . . . "+pxs,1,dHeader.size());	
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>




