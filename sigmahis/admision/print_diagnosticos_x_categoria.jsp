<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>  
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />  
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />   
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: José A. Acevedo C.     -->
<!-- CENTROS DE SERVICO                       -->
<!-- Reporte: "CATEGORIA DE LOS DIAGNÓSTICOS" -->
<!-- Reporte: CDS200070                       -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 30/03/2010                        -->    

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania        = (String) session.getAttribute("_companyId");
String categoriaDiag   = request.getParameter("categoriaDiag");

if (categoriaDiag == null) categoriaDiag = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//--------------Parámetros--------------------//
if (!categoriaDiag.equals(""))      
   {
    appendFilter1 += " and catDiag.codigo like "+categoriaDiag;	 
	}	
/*if (!fechaini.equals(""))
   {
   appendFilter1 += " and to_date(to_char(pac.fecha_fallecido, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
if (!fechafin.equals(""))
   {
  appendFilter1 += " and to_date(to_char(pac.fecha_fallecido, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
  */
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Diagnósticos x Categoria------------------------------------//
sql = 
" select diag.codigo codDiagnostico, decode(diag.observacion,null,diag.nombre,diag.observacion) descDiagnostico, " 
+" catDiag.codigo catDiagnostico, catDiag.descripcion descCategoria "
+" from tbl_cds_diagnostico diag, tbl_cds_categoria_diag  catDiag "  
+" where (diag.categoria = catDiag.codigo) "+appendFilter1
+" order by 3,4,1,2 ";         

//cdo = SQLMgr.getData(sql);
al = SQLMgr.getDataList(sql); 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";
		
	if(mon.equals("01")) month = "january";
	else if(mon.equals("02")) month = "february";
	else if(mon.equals("03")) month = "march";
	else if(mon.equals("04")) month = "april";
	else if(mon.equals("05")) month = "may";
	else if(mon.equals("06")) month = "june";
	else if(mon.equals("07")) month = "july";
	else if(mon.equals("08")) month = "august";
	else if(mon.equals("09")) month = "september";
	else if(mon.equals("10")) month = "october";
	else if(mon.equals("11")) month = "november";
	else month = "december";

    String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");	
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";	
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	
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
	String title = "ADMISION";
	String subtitle = "CATEGORIA DE LOS DIAGNÓSTICOS";  
	String xtraSubtitle = null;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".15");	
		dHeader.addElement(".85");			
	
	pc.createTable("titulos");	
	pc.setNoColumn(2);
	pc.setNoColumnFixWidth(dHeader);  			
		pc.setFont(7, 1);		
		pc.addBorderCols("CODIGO",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("NOMBRE",1,1,cHeight,Color.lightGray);	
			
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);
		
	String groupBy = "", pacId = "";
	int pxc = 0, pcant = 0;
	for (int i=0; i<al.size(); i++)
	{		
       cdo = (CommonDataObject) al.get(i);		   
	   // Inicio --- Agrupamiento x Categoria de Diagnóstico		 
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("catDiagnostico")+" ] "+cdo.getColValue("descCategoria"))) 
		   { // groupBy
			   if (i != 0)  
			     {// i 				  
				   pc.setFont(8, 1,Color.red);									
				   pc.addCols("  TOTAL DE DIAGNOSTICOS X CAT: "+ pxc,0,dHeader.size(),cHeight);					   	
				   pc.addCols(" ",0,dHeader.size(),cHeight);  
				   pxc = 0;	
	              }// i
			  pc.setFont(8, 1,Color.blue); 
			  pc.addCols("CATEGORIA:",0,1,cHeight);
		      pc.addCols("[ "+cdo.getColValue("catDiagnostico")+" ] "+cdo.getColValue("descCategoria"),0,dHeader.size());
			  pc.addTableToCols("titulos",1,dHeader.size());  
		    }// groupBy	
	// Fin --- Agrupamiento x Categoria de Diagnóstico	    
		
		   pc.setFont(7, 0);		   	
		   pc.addBorderCols(" "+cdo.getColValue("codDiagnostico"),0,1,cHeight);	
		   pc.addBorderCols(" "+cdo.getColValue("descDiagnostico"),0,1);		   
		   pxc++;  
		  pcant++;			     
		 
	groupBy = "[ "+cdo.getColValue("catDiagnostico")+" ] "+cdo.getColValue("descCategoria"); 
	
	}//for i  	
	
	if (al.size() == 0)                    
	{		
		pc.addCols("No existen registros",1,dHeader.size());        		
	}
	else 
	{  //Totales Finales	    			
			pc.setFont(8, 1,Color.red);
			pc.addCols("  TOTAL DE DIAGNOSTICOS X CAT: "+ pxc,0,dHeader.size(),cHeight);			
			pc.setFont(8, 1,Color.black);			  
		    pc.addCols("  CANT. TOTAL:                                    "+ al.size(),0,dHeader.size(),Color.lightGray);		 
			pc.addCols(" ",0,dHeader.size(),cHeight);             		
	}  
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>

