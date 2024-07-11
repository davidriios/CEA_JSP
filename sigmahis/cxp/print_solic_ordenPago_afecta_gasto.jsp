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
<!-- Reporte: "Solic. de Orden de Pago Afecta el Gasto De: " -->   
<!-- Reporte: OP_0004.rdf                     -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 18/06/2011                        -->

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
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (unidad   == null) unidad   = "";
if (beneficiario == null) beneficiario = "";
if (estado   == null)     estado       = "";

String appendFilter1 = "";

//--------------Parámetros--------------------//
if (!compania.equals("")) appendFilter1 += " and sou.compania = "+compania;
if (!unidad.equals(""))   appendFilter1 += " and dsou.unidad_adm = "+unidad;
if (!estado.equals(""))   appendFilter1 += " and sou.estado1  = '"+estado+"' ";

if (!fechaini.equals("")) appendFilter1 += " and to_date(to_char(sou.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
if (!fechafin.equals("")) appendFilter1 += " and to_date(to_char(sou.fecha, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener los Órdenes de Pago ----------------------------------------//
sql= " select sou.unidad_adm1 , u.descripcion solicitadoPor, to_char(sou.fecha,'dd/mm/yyyy') fecha, dsou.unidad_adm, uni.descripcion gastoDe, decode(dsou.estado,'N',-dsou.monto,dsou.monto) monto, sou.compania, sou.documento, sou.beneficiario,  decode(dsou.estado,'A','Apro.','R','Proc.','T','Autor.','N','Anul.','X','Rechaz.','') estado, sou.estado1 estEnc, pg.nombre descBeneficiario, getChequeOrdenPago(sou.fecha, sou.compania, sou.documento) as infoCheque from TBL_cxp_orden_unidad_det dsou, tbl_cxp_orden_unidad sou, tbl_sec_unidad_ejec u, tbl_sec_unidad_ejec uni, tbl_con_pagos_otros pg where (dsou.compania = sou.compania  and dsou.documento = sou.documento and dsou.fecha = sou.fecha) and (u.codigo = sou.unidad_adm1 and u.compania = sou.compania) and (uni.CODIGO = dsou.UNIDAD_ADM and uni.COMPANIA = dsou.COMPANIA) and (pg.codigo = sou.beneficiario and pg.compania = sou.compania) "+appendFilter1+" order by 1,2,sou.fecha asc,sou.documento ";
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
	String subtitle = "POR UNIDAD";
	String xtraSubtitle = " Solicitadas Del:  "+fechaini+" Al:  "+fechafin;

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
		dHeader.addElement(".25");
		dHeader.addElement(".15");
		dHeader.addElement(".20");
		dHeader.addElement(".25");		

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable(true);
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.resetVAlignment();
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//headerHeight =  pc.getTableHeight();

	String groupBy = "", groupBy2 = "", groupBy3 = "", subGroupBy ="";
	int pxc = 0, diag = 0;
	int pxs = 0;
	
	int pxcat = 0;
	double monto = 0, totMonto = 0, totFinal = 0;
	
	for (int i=0; i<al.size(); i++)
	{
       cdo = (CommonDataObject) al.get(i);	 
		
	/*----------------------------NUEVO--------------------------------------------------------------*/

    if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad_adm1")))
		{
			if (i != 0)
			{			
			   if  (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad_adm1")+"-"+ cdo.getColValue("fecha")))
				 {				 
				    pc.setFont(7, 1,Color.red);
				    pc.addCols("TOTAL X FECHA:             ",2,3);
					pc.addCols(" "+CmnMgr.getFormattedDecimal(monto),2,1);
                    pc.addCols("",0,1);	
                	pc.addCols("TOTAL X UNIDAD:       ",2,3);
					pc.addCols("   "+CmnMgr.getFormattedDecimal(totMonto),2,1);	
                    pc.addCols("",0,1);				
                  }
				   monto    = 0;  
			       totMonto = 0;						
				 
				  pc.flushTableBody(true);
				  pc.deleteRows(-2);	
			  
				//agrega el almacen al encabezado en memoria						
				pc.setFont(8, 1,Color.blue);	
				pc.addCols("Solicitado Por: ",0,1);
				pc.addCols("[ "+cdo.getColValue("unidad_adm1")+" ] "+cdo.getColValue("solicitadoPor"),0,4);
				pc.addCols("Fecha: ",0,1);
				pc.addCols("[ "+cdo.getColValue("fecha")+" ] ",0,4);	
				//agrega la familia al encabezado en memoria	
		    }		 
			  pc.setTableHeader(3);
			   
			  if  (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad_adm1")+"-"+ cdo.getColValue("fecha")))
				{
					pc.setFont(8, 1,Color.blue);
					pc.addCols("Solicitado Por: ",0,1);
					pc.addCols("[ "+cdo.getColValue("unidad_adm1")+" ] "+cdo.getColValue("solicitadoPor"),0,4);
					pc.addCols("Fecha: ",0,1);
					pc.addCols("[ "+cdo.getColValue("fecha")+" ] ",0,4);
				}		 
			 
	}else if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad_adm1")+"-"+ cdo.getColValue("fecha")))
		{			 
			pc.flushTableBody(true);
			pc.deleteRows(-2);
				
			pc.setFont(8, 1,Color.blue);
			pc.addCols("Solicitado Por: ",0,1);
			pc.addCols("[ "+cdo.getColValue("unidad_adm1")+" ] "+cdo.getColValue("solicitadoPor"),0,4);
			pc.addCols("Fecha: ",0,1);
			pc.addCols("[ "+cdo.getColValue("fecha")+" ] ",0,4);						
			pc.setFont(7, 1,Color.red);
			pc.addCols("TOTAL X FECHA:             ",2,3);
		    pc.addCols(" "+CmnMgr.getFormattedDecimal(monto),2,1);
		    pc.addCols("",0,1);	
			pc.setFont(8, 1,Color.blue);
			pc.addCols("Fecha: ",0,1,cHeight);
			pc.addCols("[ "+cdo.getColValue("fecha")+" ] ",0,4);
			monto    = 0;			
			  }
	/*-----------------------------NUEVO-------------------------------------------------------------*/	 
		 monto    += Double.parseDouble(cdo.getColValue("monto"));
		 totMonto += Double.parseDouble(cdo.getColValue("monto"));
		 totFinal += Double.parseDouble(cdo.getColValue("monto"));

		   pc.setFont(7, 0);
		   pc.addCols(" "+cdo.getColValue("documento"),2,1);
		   pc.addCols(" "+cdo.getColValue("descBeneficiario"),0,1);
		   pc.addCols(" "+cdo.getColValue("estado"),1,1);
		   pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
		   pc.addCols(" "+cdo.getColValue("infoCheque"),1,1);			  
		   pxc++;	
		   		
		 if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);	
	
		groupBy    = cdo.getColValue("unidad_adm1");
		subGroupBy = cdo.getColValue("unidad_adm1")+"-"+cdo.getColValue("fecha");
	
	}//for i

	if (al.size() == 0)
	{
		pc.addCols(" ",0,dHeader.size());
		pc.addCols("No existen registros",1,dHeader.size());
	}
	else
	{  //Totales Finales
			pc.setFont(7, 1,Color.red);
			pc.addCols("TOTAL X FECHA:             ",2,3);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(monto),2,1);
            pc.addCols("",0,1);
			pc.addCols("TOTAL X UNIDAD:       ",2,3);
			pc.addCols(" "+CmnMgr.getFormattedDecimal(totMonto),2,1);
            pc.addCols("",0,1);			
            pc.setFont(8, 1,Color.black);
			pc.addCols("TOTAL FINAL:   ",2,3,Color.lightGray);
			pc.addCols(" "+(CmnMgr.getFormattedDecimal(totFinal)),2,1,Color.lightGray);
			pc.addCols("",0,1,Color.lightGray);
            pc.addCols(" ",0,dHeader.size());	  
    }
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>



