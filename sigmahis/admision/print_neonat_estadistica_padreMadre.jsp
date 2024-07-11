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
<!-- Desarrollado por: José A. Acevedo C.               -->
<!-- Reporte: "Estadística del Padre y de la Madre "    -->
<!-- Reporte: SAL800176                                 -->
<!-- Clínica Hospital San Fernando                      -->
<!-- Fecha: 29/06/2010                                  -->

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
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
String compania = (String) session.getAttribute("_companyId");

String evento    = request.getParameter("evento");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (evento == null)   evento    = "";
if (fechaini == null) fechaini  = "";
if (fechafin == null) fechafin  = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//--------------Parámetros--------------------//
/*
if (!compania.equals(""))
  {
   appendFilter1 += " ae.compania = "+compania;  
  }
*/
if (!fechaini.equals(""))
   {
  appendFilter1 += " to_date(to_char(neo.fecha_crea, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
if (!fechafin.equals(""))
   {
  appendFilter1 += " and to_date(to_char(neo.fecha_crea, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener "Estadística del Padre y de la Madre"--------------------------------//
sql = 
" select distinct(neo.nombre_madre) madre, neo.edad_madre edadMadre, "
+" neo.tipo_parto parto, neo.ginecologo ginecologo, "
+" neo.nombre_padre padre, neo.edad_padre edadPadre, "
+" neo.tel_padre telPadre, neo.dir_padre direccionPadre, "
+" to_char(neo.fecha_crea,'dd/mm/yyyy') fechaCreacion "
+" from tbl_adm_neonato neo where "+appendFilter1+" order by 1";

cdo = SQLMgr.getData(sql);

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
	float height = 72 * 14f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "ESTADÍSTICA DEL PADRE Y DE LA MADRE";
	String xtraSubtitle = "DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	Vector dHeader = new Vector();	

		dHeader.addElement(".16");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".13");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".21");
	    dHeader.addElement(".05");   
				

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pc.setFont(7, 1);			
		pc.addBorderCols("NOMBRE MADRE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("EDAD MADRE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("TIPO PARTO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("GINECÓLOGO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("NOMBRE PADRE",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("EDAD PADRE",1,1,cHeight * 2,Color.lightGray);				
		pc.addBorderCols("TELF. PADRE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DIRECCIÓN",1,1,cHeight * 2,Color.lightGray);				
	    pc.addBorderCols("FEC. CREACIÓN",1,1,cHeight * 2,Color.lightGray);
		
	pc.setTableHeader(2);
	
	int pxc = 0;		
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);					
		 
		    pc.setFont(7, 0);					
			pc.addCols(" "+cdo.getColValue("madre"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("edadMadre"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("parto"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("ginecologo"),1,1,cHeight); 
			pc.addCols(" "+cdo.getColValue("padre"),0,1);
			pc.addCols(" "+cdo.getColValue("edadPadre"),1,1,cHeight);			
			pc.addCols(" "+cdo.getColValue("telPadre"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("direccionPadre"),0,1);			
			pc.addCols(" "+cdo.getColValue("fechaCreacion"),1,1,cHeight);
		 
	}//for i

	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales	
	        pc.setFont(8, 1,Color.black);			
			pc.addCols(" TOTAL FINAL:   "+ al.size(),0,dHeader.size(),Color.lightGray);	  
			//pc.addCols(dHeader.size()+" Registros en total",0,cHeight); 		
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>




