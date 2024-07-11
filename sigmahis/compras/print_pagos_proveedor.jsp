<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" /> 
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" /> 
<%@ include file="../common/pdf_header.jsp"%>
<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR 
      REPORTE   COM0001.RDF                 
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alTipo = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String fp       = request.getParameter("fp");
String compania = (String) session.getAttribute("_companyId");	
String tDate    = request.getParameter("tDate");
String fDate    = request.getParameter("fDate");
String proveedor = request.getParameter("proveedor");
String tipo = request.getParameter("tipo");

if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(proveedor== null) proveedor = "";
if(tipo== null) tipo = "";

if (appendFilter == null) appendFilter = "";

if(!fDate.trim().equals("")&&!tDate.trim().equals("")) 
appendFilter += " and to_date(to_char(b.fecha_documento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and  to_date('"+tDate+"','dd/mm/yyyy') ";

if(!proveedor.trim().equals("")) 
appendFilter += " and to_char(a.cod_provedor) = "+proveedor ;

if(!tipo.trim().equals("")) 
appendFilter += " and to_char(b.tipo_compromiso) = "+tipo ;

if (appendFilter == null) appendFilter = "";

	sql = "select a.nombre_proveedor nombre_proveedor, to_char(b.fecha_documento,'dd/mm/yyyy') fcomp, b.anio||'-'||b.num_doc numero, c.descripcion nombre_compromiso, decode(b.status,'PEN','PENDIENTE','APR','APROBADO') estado, b.tipo_compromiso tipo, decode(b.tipo_pago,'CON','CONTADO','CRE','CREDITO') tipo_pago, b.numero_factura, nvl(b.monto_total,0) total, nvl(b.monto_pagado,0) pagado, nvl(b.monto_total,0) - nvl(b.monto_pagado,0) saldo from tbl_com_proveedor a, tbl_com_comp_formales b, tbl_com_tipo_compromiso c where b.cod_proveedor= a.cod_provedor and b.tipo_compromiso = c.tipo_com and b.compania = "+compania+appendFilter+" order by a.nombre_proveedor";
al = SQLMgr.getDataList(sql);

sql = "select nombre, codigo, total, pagado, saldo from ( select a.nombre_proveedor nombre, a.cod_provedor codigo, sum(nvl(b.monto_total,0)) total, sum(nvl(b.monto_pagado,0)) pagado, sum(nvl(b.monto_total,0) - nvl(b.monto_pagado,0)) saldo from tbl_com_proveedor a, tbl_com_comp_formales b, tbl_com_tipo_compromiso c where b.cod_proveedor= a.cod_provedor and b.tipo_compromiso = c.tipo_com and b.compania = "+compania+appendFilter+" group by a.nombre_proveedor, a.cod_provedor) ";
alTipo = SQLMgr.getDataList(sql);


if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 35; //max lines of items
		int total_page =0;
		Hashtable htTipo = new Hashtable(); 
		for (int i=0; i<alTipo.size(); i++)
	{
	 CommonDataObject cdo  = (CommonDataObject) alTipo.get(i);
	  htTipo.put(cdo.getColValue("nombre"),cdo);

	}
		int nItems = (al.size() + alTipo.size() *3 + 1); //number of items
		int extraItems = nItems % maxLines;
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		if (extraItems == 0)
		   nPages = (nItems / maxLines);
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;
		if (total_page == 0) total_page = 1;
		
		String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		String statusPath = "";
		boolean logoMark = true;
		boolean statusMark = false;
		
		String folderName = "compras";  
		String fileNamePrefix = "print_pagos_proveedor";
		String fileNameSuffix = "";
		String fecha = cDateTime;
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = null;
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

		String day=fecha.substring(0, 2);
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
		String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);
		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
			
		String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
		
		int width = 612;
		int height = 792;
		boolean isLandscape = true;	
		int headerFooterFont = 4;
		StringBuffer sbFooter = new StringBuffer();
				
		float leftRightMargin = 9.0f;
		float topMargin = 13.5f;
		float bottomMargin = 9.0f;
						
				
		issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);
					
		Vector setDetail=new Vector();
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".20");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");	
				setDetail.addElement(".10");		
		
		int lCounter = 0;
		int pCounter = 0;
		float cHeight = 12.0f;
		String groupBy = "";
		

		
		pc.setNoColumnFixWidth(setDetail);									
		pc.createTable();
		pc.setFont(7, 0, Color.red);
			pc.addBorderCols("Fecha/Comp",0);
			pc.addBorderCols("Compromiso",0);
			pc.addBorderCols("Tipo de Compromiso",1);						
			pc.addBorderCols("Estado",1);
			pc.addBorderCols("Tipo Pago ",1);
			pc.addBorderCols("Factura",1);
			pc.addBorderCols("Monto Total",2);
			pc.addBorderCols("Monto Pagado",2);
			pc.addBorderCols("Saldo",2);
		pc.copyTable("detailHeader");		
					
	for (int i=0; i<al.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		 if (!groupBy.equalsIgnoreCase(cdo.getColValue("nombre_proveedor")))
		 {
			if (i==0) 
			{
			pCounter++;
			pc.addNewPage();
		
		pdfHeader(pc, _comp, pCounter, nPages," DEPARTAMENTO DE COMPRAS " ," PAGOS REALIZADOS A PROVEEDORES POR COMPROMISOS  desde  "+fDate+ " hasta "+tDate, userName, fecha);
						
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			
			pc.createTable();
				pc.addCols("", 0,setDetail.size(),cHeight);		
			pc.addTable();
						
			pc.createTable();
				pc.addBorderCols("Proveedor ....: "+cdo.getColValue("nombre_proveedor"), 0,setDetail.size(),cHeight);		
			pc.addTable();
				
			pc.addCopiedTable("detailHeader");	
			
					
			lCounter = lCounter + 2 ;
			} 
			else
			{
			
			CommonDataObject cdo1 = (CommonDataObject) htTipo.get(groupBy);
			
			pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.addCols("", 0,setDetail.size(),cHeight);		
			pc.addTable();
						
			pc.createTable();
				pc.addCols("Total por Proveedor ....: ", 2,6,cHeight);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("total")),2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("pagado")),2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo")),2,1);	
			pc.addTable();
			
			
			pCounter++;
			pc.addNewPage();
		
		pdfHeader(pc, _comp, pCounter, nPages," DEPARTAMENTO DE COMPRAS " ," PAGOS REALIZADOS A PROVEEDORES POR COMPROMISOS  desde  "+fDate+ " hasta "+tDate, userName, fecha);
						
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			
			pc.createTable();
				pc.addCols("", 0,setDetail.size(),cHeight);		
			pc.addTable();
						
			pc.createTable();
				pc.addBorderCols("Proveedor ....: "+cdo.getColValue("nombre_proveedor"), 0,setDetail.size(),cHeight);		
			pc.addTable();
				
			pc.addCopiedTable("detailHeader");	
			
					
			lCounter = lCounter + 2 ;
			}
		}
		
		pc.createTable();
		pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("fcomp"),0,1);							
			pc.addCols(" "+cdo.getColValue("numero"),0,1) ;
			pc.addCols(" "+cdo.getColValue("nombre_compromiso"),1,1);							
			pc.addCols(" "+cdo.getColValue("estado"),1,1) ;
			pc.addCols(" "+cdo.getColValue("tipo_pago"),1,1);							
			pc.addCols(" "+cdo.getColValue("numero_factura"),1,1) ;
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("total")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("pagado")),2,1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("saldo")),2,1);
			
		pc.addTable();
						
		lCounter++;
			
		if(lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();
		
		pdfHeader(pc, _comp, pCounter, nPages," DEPARTAMENTO DE COMPRAS " ," PAGOS REALIZADOS A PROVEEDORES POR COMPROMISOS  desde  "+fDate+ " hasta "+tDate, userName, fecha);
							
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			
			pc.createTable();
				pc.addCols("", 0,setDetail.size(),cHeight);		
			pc.addTable();
			
			pc.createTable();
				pc.addBorderCols("Proveedor ....: "+cdo.getColValue("nombre_proveedor"), 0,setDetail.size(),cHeight);		
			pc.addTable();
				
			
			pc.addCopiedTable("detailHeader");
		}
			
		groupBy = cdo.getColValue("nombre_proveedor");
	}	// end for i	
	
if (al.size() == 0)
	{
	pc.createTable();
		pc.addCols("No existen registros",1,setDetail.size());
	pc.addTable();
	}
	else
	{
	CommonDataObject cdo1 = (CommonDataObject) htTipo.get(groupBy);
	pc.setNoColumnFixWidth(setDetail);
			pc.createTable();
				pc.addCols("", 0,setDetail.size(),cHeight);		
			pc.addTable();
						
			pc.createTable();
				pc.addCols("Total por Proveedor ....: ", 2,6,cHeight);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("total")),2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("pagado")),2,1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo")),2,1);		
			pc.addTable();
	}
pc.addNewPage();
pc.close();
response.sendRedirect(redirectFile);
}//get
%>