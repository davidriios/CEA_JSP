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
<!-- CXP                                      -->
<!-- Reporte: "Solic. de Orden de Pago x Fecha: " -->
<!-- Reporte: OP_0005.rdf                     -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 23/06/2011                        -->

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
CommonDataObject cdo  = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania  = (String) session.getAttribute("_companyId");
String unidad    = request.getParameter("unidad");
String beneficiario  = request.getParameter("beneficiario");
String estado	 = request.getParameter("estado");
String observ    = request.getParameter("observ");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");
String fg        = request.getParameter("fg");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (unidad   == null) unidad   = "";
if (beneficiario == null) beneficiario = "";
if (estado == null) estado = "";
if (observ == null) observ = "";
if (fg == null) fg = "BENEF";

String appendFilter1 = "";

//--------------Parámetros--------------------//
if (!compania.equals("")) appendFilter1 += " and sou.compania = "+compania;
if (!unidad.equals(""))   appendFilter1 += " and sou.unidad_adm1 = "+unidad;
if (!estado.equals(""))   appendFilter1 += " and sou.estado1  = '"+estado+"'";

if (!fechaini.equals("")) appendFilter1 += " and to_date(to_char(sou.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
if (!fechafin.equals("")) appendFilter1 += " and to_date(to_char(sou.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener los Órdenes de Pago ----------------------------------------//
sql= " select sou.unidad_adm1 , u.descripcion solicitadoPor, to_char(sou.fecha,'dd/mm/yyyy') fecha, dsou.unidad_adm, uni.descripcion gastoDe, decode(dsou.estado,'N',-dsou.monto,dsou.monto) monto, decode(sou.estado1,'N',-sou.monto,sou.monto) montoP, sou.observacion, sou.compania, sou.documento, sou.beneficiario, decode(dsou.estado,'A','Apro.','R','Proc.','T','Autor.','N','Anul.','X','Rechaz.','') estado, sou.estado1 estEnc, pg.nombre descBeneficiario, getChequeOrdenPago(sou.fecha, sou.compania, sou.documento) as infoCheque from TBL_cxp_orden_unidad_det dsou, tbl_cxp_orden_unidad sou, tbl_sec_unidad_ejec u, tbl_sec_unidad_ejec uni, tbl_con_pagos_otros pg where (dsou.compania = sou.compania  and dsou.documento = sou.documento and dsou.fecha = sou.fecha) and (u.codigo = sou.unidad_adm1 and u.compania = sou.compania) and (uni.CODIGO = dsou.UNIDAD_ADM and uni.COMPANIA = dsou.COMPANIA) and (pg.codigo = sou.beneficiario and pg.compania = sou.compania) "+appendFilter1+" order by sou.unidad_adm1, sou.fecha, sou.documento, sou.beneficiario  ";  
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
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam")+".pdf";

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
	String title = "SOLICITUDES DE ÓRDENES DE PAGO";
	String subtitle = "POR RANGO DE FECHA";
	String xtraSubtitle = " Desde:  "+fechaini+" Al:  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();

		dHeader.addElement(".11");
		dHeader.addElement(".25");
		dHeader.addElement(".15");
		dHeader.addElement(".25");
		dHeader.addElement(".24");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.resetVAlignment();
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//headerHeight =  pc.getTableHeight();

	String groupBy = "", groupBy2 = "", groupBy3 = "", subGroupBy = "", noDocto = "";
	String est = "", observacion = "";
	int pxc = 0, diag = 0, pxs = 0, pxcat = 0;
	double monto = 0, totBenef = 0, totFinal = 0, tot= 0,montoProv=0,montoUnd =0;
	
	for (int i=0; i<al.size(); i++) 
	{
       cdo = (CommonDataObject) al.get(i);
	   
	   if (!groupBy2.equalsIgnoreCase(cdo.getColValue("fecha")))
	   {
	   		if (i != 0)
			{			
			pc.setFont(7, 1,Color.red);
			pc.addCols("Total por Fecha ",2,3);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(montoProv)),2,1);//beneficiario
			pc.addCols(" ",0,1);			
			pc.addCols(" ",0,dHeader.size());  			
			//pc.addCols("Total      "+montoProv,2,5);	
			montoProv=0;					
			}
	   }	   
	   
	   if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad_adm1")))
	   {
	   		if (i != 0)
			{
				pc.setFont(7, 1,Color.red);
				pc.addCols("Total por Unidad ",2,3);
				pc.addCols(" "+(CmnMgr.getFormattedDecimal(montoUnd)),2,1);//unidad_adm1
				pc.addCols(" ",0,1);			
			    pc.addCols(" ",0,dHeader.size());  		
				montoUnd =0;
			}
	   }	   
	   
	   if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad_adm1")))
	   {
	   		pc.setFont(8, 1,Color.blue);
			pc.addCols("Solicitado Por: ",0,1);
			pc.addCols("    "+cdo.getColValue("unidad_adm1")+" "+cdo.getColValue("solicitadoPor"),0,4);				
	   }
	   
	   if (!groupBy2.equalsIgnoreCase(cdo.getColValue("fecha")))
	   {
	      pc.setFont(8, 1,Color.blue);
	   	  pc.addCols("Fecha:    "+cdo.getColValue("fecha"),0,5);			
	   }
	
	/*-----------------------------NUEVO-------------------------------------------------------------*/	 		
		 est       = cdo.getColValue("estado");	 
		 
		 pc.setFont(7, 1);		 
		 if (!noDocto.trim().equals(cdo.getColValue("documento")))
		 {
			 pc.addCols(" "+cdo.getColValue("documento"),1,1);
			 pc.addCols(" "+cdo.getColValue("descBeneficiario"),0,1);
			 pc.addCols(" "+cdo.getColValue("estado"),2,1);			 
			 pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("montoP"))),2,1);		   		 		  	   
			 pc.addCols(" "+cdo.getColValue("infoCheque"),1,1);			  
		 
			  if (observ.trim().equals("S"))
			  { 		  
				pc.addBorderCols("    "+cdo.getColValue("observacion"),0,dHeader.size());		
			  }	
			  pc.setFont(7, 0);	  
			 // pc.addCols(" ",2,1);		  			
			pc.addCols("                                       "+cdo.getColValue("unidad_adm")+" "+cdo.getColValue("gastoDe"),0,2);
			  pc.addCols("    "+cdo.getColValue("estado"),2,1);
			  pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))),2,1);
			  pc.addCols(" ",0,1);					
			 
			  montoProv += Double.parseDouble(cdo.getColValue("montoP"));				     
		      totFinal  += Double.parseDouble(cdo.getColValue("montoP"));
			  pxc++;	
			 
		 }else{		     
			 // pc.addCols(" ",2,1);		  			 
			pc.addCols("                                       "+cdo.getColValue("unidad_adm")+" "+cdo.getColValue("gastoDe"),0,2);
			  pc.addCols("    "+cdo.getColValue("estado"),2,1);
			  pc.addCols(" "+(CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))),2,1);
			  pc.addCols(" ",0,1);							 
		 }	 
		   		
		 montoUnd += Double.parseDouble(cdo.getColValue("monto"));				
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);	
		
		noDocto = cdo.getColValue("documento");
	
		groupBy  = cdo.getColValue("unidad_adm1");  
		groupBy2 = cdo.getColValue("fecha");
	
	}//for i

	if (al.size() == 0)
	{
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{  //Totales Finales		
		pc.setFont(7, 1,Color.red);
		pc.addCols("Total por Fecha ",2,3);
		pc.addCols(" "+(CmnMgr.getFormattedDecimal(montoProv)),2,1);//beneficiario	
		pc.addCols(" ",0,1);
		pc.addCols("Total por Unidad ",2,3);
		pc.addCols(" "+(CmnMgr.getFormattedDecimal(montoUnd)),2,1);//unidad_adm1
		pc.addCols(" ",0,1);		  						
		pc.setFont(8, 1,Color.black);			
		pc.addCols("TOTAL FINAL:   ",2,3);	
		pc.addCols("                      "+(CmnMgr.getFormattedDecimal(totFinal)),2,1);
		pc.addCols(" ",0,1);		   
		pc.addCols(" ",0,dHeader.size());  
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>






