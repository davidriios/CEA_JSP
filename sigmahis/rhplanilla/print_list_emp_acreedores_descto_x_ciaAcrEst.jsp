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
==========================================================================
==========================================================================
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
String acr        = request.getParameter("acr");
String grupoDesc  = request.getParameter("grupoDesc");
String descontar  = request.getParameter("descontar");
String pendiente  = request.getParameter("pendiente");
String eliminar   = request.getParameter("eliminar");
String noDescontar = request.getParameter("noDescontar");

String filter = "", titulo = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (acr        == null) acr        = "";
if (grupoDesc  == null) grupoDesc  = "";

if (!compania.equals(""))
  {
   appendFilter += " and d.cod_compania = "+compania;
  }    
if (!acr.equals(""))   
 {
  appendFilter += " and d.cod_acreedor = "+acr;
 } 
  if(!grupoDesc.equals(""))
  {
   appendFilter += " and d.cod_grupo = "+grupoDesc;
  }

/*  
if (!fechaini.equals(""))
   {
  appendFilter += " and to_date(to_char(pe.fecha_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }

if (!fechafin.equals(""))
   {
   appendFilter += " and to_date(to_char(pe.fecha_final, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
   */

sql= " select d.cod_acreedor codAcreedor,'['||ac.cod_acreedor||'] '||ac.nombre nombreAcreedor,e.num_empleado numEmpleado, nvl(e.cedula1,e.cedula_beneficiario) cedula,e.nombre_empleado nombreEmpleado,d.num_documento numDocumento,d.descuento1 desc1,d.descuento2 desc2,d.descuento_mensual descMensual,d.monto_total montoTotal,d.saldo saldo,'['||gr.cod_grupo||'] '||gr.nombre descGrupo,decode(d.estado,'N','No Descontar','P','Pendiente','D','Descontar','E','Eliminado','') estado from vw_pla_empleado e,tbl_pla_descuento d,tbl_pla_acreedor ac,tbl_pla_grupo_descuento gr where (e.emp_id = d.emp_id and e.compania = d.cod_compania) and (d.cod_acreedor = ac.cod_acreedor and d.cod_compania = ac.compania) and (gr.cod_grupo = d.cod_grupo) and e.estado <> 3 "+appendFilter+" and (d.estado =decode('"+descontar+"','S','D','') or d.estado = decode('"+pendiente+"','S','P','') or d.estado = decode('"+noDescontar+"','S','N','') or d.estado = decode('"+eliminar+"','S','E',''))  order by ac.cod_acreedor,d.cod_grupo, e.nombre_empleado, e.num_empleado ";  
														
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
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 8f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "RECURSOS HUMANOS";
	String subtitle = " LISTADO DE DESCUENTOS POR ESTADO ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	Vector infoCol2 = new Vector();
		infoCol2.addElement(".15");
		infoCol2.addElement(".02");
		infoCol2.addElement(".09");		
		infoCol2.addElement(".02");
		infoCol2.addElement(".09");
		infoCol2.addElement(".02");
		infoCol2.addElement(".09");
		infoCol2.addElement(".02");
		infoCol2.addElement(".11");
		infoCol2.addElement(".39");

	Vector dHeader = new Vector();
		dHeader.addElement(".07");		
		dHeader.addElement(".04");				
		dHeader.addElement(".15");			
		dHeader.addElement(".24");	
		dHeader.addElement(".16");
		dHeader.addElement(".05");	
		dHeader.addElement(".05");	
		dHeader.addElement(".06");
		dHeader.addElement(".06");	
		dHeader.addElement(".06");	
		dHeader.addElement(".06");	
				
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(3);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = ""; 
		String sc = ""; 
		
		pc.setVAlignment(0);
		pc.setNoInnerColumnFixWidth(infoCol2);
		pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
		pc.createInnerTable();		
			
			pc.setFont(8, 1);
			pc.addInnerTableCols(" ",0,infoCol2.size());
			pc.addInnerTableCols("Estados:",0,1);
			
			if (descontar.equalsIgnoreCase("S")) pc.addInnerTableBorderCols(" ",0,1,6.5f,6.5f,6.5f,6.5f);
				else pc.addInnerTableBorderCols(" ",0,1,1.5f,1.5f,1.5f,1.5f);
				pc.addInnerTableCols("Descontar",0,1);
						
			if (pendiente.equalsIgnoreCase("S")) pc.addInnerTableBorderCols(" ",0,1,6.5f,6.5f,6.5f,6.5f);
				else pc.addInnerTableBorderCols(" ",0,1,1.5f,1.5f,1.5f,1.5f);
			         pc.addInnerTableCols("Pendiente",0,1);
					 
			if (eliminar.equalsIgnoreCase("S")) pc.addInnerTableBorderCols(" ",0,1,6.5f,6.5f,6.5f,6.5f);
				else pc.addInnerTableBorderCols(" ",0,1,1.5f,1.5f,1.5f,1.5f);
			         pc.addInnerTableCols("Eliminar",0,1);
						
			if (noDescontar.equalsIgnoreCase("S") ) pc.addInnerTableBorderCols(" ",0,1,6.5f,6.5f,6.5f,6.5f);
			else pc.addInnerTableBorderCols(" ",0,1,1.5f,1.5f,1.5f,1.5f);
				pc.addInnerTableCols("No Descontar",0,1);							
				pc.addInnerTableCols("",0,1);
				pc.addInnerTableCols("",0,infoCol2.size());	
		
		//pc.setFont(3, 0);
		//	pc.addInnerTableCols(" ",0,infoCol2.size());
			//pc.addInnerTableBorderCols(" ",0,infoCol2.size(),0.0f,0.10f,0.0f,0.0f);
			pc.resetVAlignment();
		pc.addInnerTableToCols(dHeader.size());
    
   
	pc.setFont(8, 1);
	pc.addBorderCols("CÉD.",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("No. EMP.",1,1,1.0f,1.0f,0.0f,0.0f);	
	pc.addBorderCols("NOMBRE DEL EMPLEADO",0,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("ACREEDOR",0,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("GRUPO DESCUENTO",0,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("DESCTO 1a.Quinc",1,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("DESCTO 2a.Quinc",1,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("DESCTO MENSUAL",1,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("MONTO TOTAL",1,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("SALDO",2,1,1.0f,1.0f,0.0f,0.0f);		
	pc.addBorderCols("ESTADO",1,1,1.0f,1.0f,0.0f,0.0f);	  
   
	String groupBy = "";
	int pxu = 0, pxs = 0, pxg = 0;
	
	double total = 0, totSaldo = 0, totDescontado = 0;
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
	    // Listado de Descuentos por Acreedor
	    pc.setFont(7, 0);
		pc.setVAlignment(0);
		    pc.addCols(" "+cdo.getColValue("cedula"),0,1);					
			pc.addCols(" "+cdo.getColValue("numEmpleado"),1,1);					
			pc.addCols(" "+cdo.getColValue("nombreEmpleado"),0,1);				
			pc.addCols(" "+cdo.getColValue("nombreAcreedor"),0,1);	
			pc.addCols(" "+cdo.getColValue("descGrupo"),0,1);													
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("desc1"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("desc2"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("descMensual"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("montoTotal"))),2,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("saldo"))),2,1);	
			pc.addCols(" "+cdo.getColValue("estado"),1,1);						
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());	
			
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
		pc.addCols("CANT. DE EMPLEADOS ==> "+" . . . "+pxu,0,11);	
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>





