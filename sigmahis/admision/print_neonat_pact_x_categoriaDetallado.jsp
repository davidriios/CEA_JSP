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
<!-- Desarrollado por: José A. Acevedo C.                 -->
<!-- Reporte: "Estadística de Pacientes en Neonatología"  -->
<!--          "Por Categoria (Detallado y Resumido)"      -->
<!-- Reporte: FAC71020R, FAC71020D                        -->
<!-- Clínica Hospital San Fernando                        -->
<!-- Fecha: 02/07/2010                                    -->

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
CommonDataObject cdo2 = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
String compania = (String) session.getAttribute("_companyId");

String fg = request.getParameter("fg");
String aseguradora = request.getParameter("aseguradora");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (aseguradora  == null) aseguradora = "";
if (fechaini     == null) fechaini    = "";
if (fechafin     == null) fechafin    = "";
if (fg           == null) fg          = "DE";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";
String titulo = "";
//--------------Parámetros--------------------//
/*if (!compania.equals(""))
  {
   appendFilter1 += " and aa.compania = "+compania;  
  }*/

if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(dt.fecha_cargo, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
   
if (!fechafin.equals(""))
   {
appendFilter1 += " and to_date(to_char(dt.fecha_cargo, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;  
 }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener "Pacts. en NEONATOLOGÍA por Categoria (Detallado-Resumido)-----------//
sql = 
" select dt.servicio_hab servicio, dt.habitacion habitacion, "
+" dt.descripcion, salth.descripcion tipohabitacion, to_char(dt.fecha_cargo,'dd/mm/yyyy') fechaCargo, "
+" sum(decode(dt.tipo_transaccion,'C',nvl(dt.monto,0),'D',nvl(-dt.monto,0)) ) monto "
+" from tbl_fac_detalle_transaccion dt, tbl_sal_tipo_habitacion salth "
+" where "
+"  dt.tipo_cargo = '01' and "
+" (dt.servicio_hab in (7,52,54,18,56,44,24,57,55)) and salth.codigo = dt.servicio_hab "+appendFilter1
+" group by dt.fecha_cargo, dt.servicio_hab, dt.habitacion, dt.descripcion,salth.descripcion, monto "
+" order by  1";

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
	
	if (fg.trim().equals("DE"))
	  {
	   titulo = "(DETALLADO)";
	  }else titulo = "(RESUMEN)";
		
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
	String subtitle = "ESTADÍSTICA DE PACIENTES EN NEONATOLOGÍA "+titulo;
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
		
		dHeader.addElement(".10");
		dHeader.addElement(".15");
		dHeader.addElement(".33");
		dHeader.addElement(".11");
		dHeader.addElement(".20");
		dHeader.addElement(".12");	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	 if (fg.trim().equals("DE"))
	   {	
		pc.setFont(7, 1);		
		pc.addBorderCols("FECHA",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("HABITACIÓN",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DESCRIPCIÓN",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("SERVICIO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("CATEGORIA",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("MONTO",1,1,cHeight * 2,Color.lightGray);		
	   } 	   
	   
	pc.setTableHeader(2);
	
	int    pxs = 0, pxi = 0, pxint = 0, pxio = 0;
	int    totPacientes = 0;
	double montoSanos = 0.0, montoIntermedio = 0.0, montoIntensivo = 0.0, montoIncubadora = 0.0;		
	double totMontos  = 0.0;
	
	String categoria = "";	
	
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);			
		
		 if (cdo.getColValue("servicio").trim().equals("7") || (cdo.getColValue("servicio").trim().equals("52")) || (cdo.getColValue("servicio").trim().equals("54")))
		   {
		       categoria = "SANOS";			   
			   
			   if (!cdo.getColValue("monto").trim().equals("0")) 
			     {
				  montoSanos = montoSanos + Double.parseDouble(cdo.getColValue("monto"));
				  pxs++;
				 }
			 
		   }else if (cdo.getColValue("servicio").trim().equals("18") || (cdo.getColValue("servicio").trim().equals("56")) || (cdo.getColValue("servicio").trim().equals("44"))) 
		   {
		       categoria = "INTERMEDIO";
			 
			   if (!cdo.getColValue("monto").trim().equals("0")) 
			    {
			      montoIntermedio = montoIntermedio + Double.parseDouble(cdo.getColValue("monto"));
				  pxi++;
			    }
				
		   }else if (cdo.getColValue("servicio").trim().equals("24") || (cdo.getColValue("servicio").trim().equals("57"))) 
		    {
			    categoria = "INTENSIVO";	
			  
			     if (!cdo.getColValue("monto").trim().equals("0"))
			     {
                   montoIntensivo = montoIntensivo + Double.parseDouble(cdo.getColValue("monto"));
			       pxint++;
			     }
				
			}else if (cdo.getColValue("servicio").trim().equals("55"))
			{
			    categoria = "INCUBADORA + OXÍGENO";

			    if (!cdo.getColValue("monto").trim().equals("0")) 
				 {
				   montoIncubadora = montoIncubadora + Double.parseDouble(cdo.getColValue("monto"));
				   pxio++;
				 }
			}				
		
		  if (fg.trim().equals("DE"))
	      {
		    pc.setFont(7, 0);		
   			pc.addCols(" "+cdo.getColValue("fechaCargo"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("habitacion"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("tipoHabitacion"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("servicio"),1,1,cHeight);
			pc.addCols(" "+categoria,0,1);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1,cHeight);	
		  }		
			 
	}//for i	
	
	    pc.setFont(10, 1);
		pc.addCols(" ",0,dHeader.size());
		pc.addBorderCols(" R E S U M E N ",1,dHeader.size());
		pc.setFont(8, 1);		
		pc.addBorderCols("CATEGORIA",1,2,cHeight,Color.lightGray);	
		pc.addBorderCols("PACIENTES",1,2,cHeight,Color.lightGray);
		pc.addBorderCols("MONTO",1,2,cHeight,Color.lightGray);
			
		pc.setFont(7, 1);
	    pc.addCols(" SANOS ",0,2);
		pc.addCols(" "+pxs,1,2);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoSanos),2,2);		
			 			
		pc.addCols(" INTERMEDIO ",0,2);	
		pc.addCols(" "+pxi,1,2);	
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoIntermedio),2,2);	
		
		pc.addCols(" INTENSIVO ",0,2);	 			
		pc.addCols(" "+pxint,1,2);	 			
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoIntensivo),2,2);
		
		pc.addCols(" INCUBADORA + OXIGENO ",0,2);
		pc.addCols(" "+pxio,1,2);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(montoIncubadora),2,2);
		
        totPacientes =  pxs + pxi + pxint + pxio;
		totMontos    = montoSanos + montoIntermedio + montoIntensivo + montoIncubadora;

	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales		    		
		pc.setFont(8, 1,Color.black);		
			 			
		pc.addCols(" TOTALES:   ",0,2,Color.lightGray);
		pc.addCols(" "+totPacientes,1,2,Color.lightGray);
		pc.addCols(" "+CmnMgr.getFormattedDecimal(totMontos),2,2,Color.lightGray);		
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>






