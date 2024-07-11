<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
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
      REPORTE   COM0008.RDF                 
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
appendFilter += " and to_date(to_char(cf.fecha_entrega_vencimiento,'dd/mm/yyyy'),'dd/mm/yyyy') between to_date('"+fDate+"','dd/mm/yyyy') and  to_date('"+tDate+"','dd/mm/yyyy') ";

if(!proveedor.trim().equals("")) 
appendFilter += " and to_char(pr.cod_provedor) = "+proveedor ;

if(!tipo.trim().equals("")) 
appendFilter += " and to_char(tc.tipo_com) = "+tipo ;

if (appendFilter == null) appendFilter = "";

	sql = "select cf.tipo_compromiso tipo, tc.descripcion compromiso, cf.anio||' '||cf.num_doc compra, pr.nombre_proveedor casa, to_char(cf.fecha_documento,'dd/mm/yyyy') fecha, to_char(cf.fecha_entrega_vencimiento,'dd/mm/yyyy') vencimiento, decode(cf.tipo_pago,'CON','CONTADO','CRE','CREDITO') tipo_pagos , decode(cf.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE','C','APROBADO POR CONTABILIDAD','F','APROBADO FINA','Z','CERRADO') estado, cf.monto_total valor from tbl_com_comp_formales cf, tbl_com_proveedor pr, tbl_com_tipo_compromiso tc where (cf.cod_proveedor = pr.cod_provedor and cf.tipo_compromiso = tc.tipo_com) and cf.compania = "+compania+appendFilter+" order by cf.tipo_compromiso, pr.nombre_proveedor";
al = SQLMgr.getDataList(sql);

sql = "select tc.descripcion compromiso, cf.tipo_compromiso, count(*) tipo from tbl_com_comp_formales cf, tbl_com_proveedor pr, tbl_com_tipo_compromiso tc where (cf.cod_proveedor=pr.cod_provedor and cf.tipo_compromiso = tc.tipo_com) and cf.compania = "+compania+appendFilter+" group by tc.descripcion, cf.tipo_compromiso ";
alTipo = SQLMgr.getDataList(sql);


if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 35; //max lines of items
		int total_page =0;
			
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
		String fileNamePrefix = "print_list_compromiso_fvencimiento";
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
				setDetail.addElement(".40");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");
				setDetail.addElement(".10");			
		
		int lCounter = 0;
		int pCounter = 1;
		float cHeight = 12.0f;
		String groupBy = "";
		

		pdfHeader(pc, _comp, pCounter, nPages," DEPARTAMENTO DE COMPRAS Y PROVEEDURIAS" ," LISTADO DE COMPROMISOS POR FECHA DE VENCIMIENTO  desde  "+fDate+ " hasta "+tDate, userName, fecha);
		
		pc.setNoColumnFixWidth(setDetail);									
		pc.createTable();
		pc.setFont(7, 0, Color.red);
			pc.addBorderCols("Orden/Compra",0);
			pc.addBorderCols("Proveedor",0);
			pc.addBorderCols("Fecha de O/C.",1);						
			pc.addBorderCols("Vencimiento",1);
			pc.addBorderCols("Tipo Pago ",0);
			pc.addBorderCols("Estado",0);
			pc.addBorderCols("Valor",2);
		pc.copyTable("detailHeader");		
					
	for (int i=0; i<al.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		 if (!groupBy.equalsIgnoreCase(cdo.getColValue("tipo")))
		 {
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			
			pc.createTable();
				pc.addCols("", 0,setDetail.size(),cHeight);		
			pc.addTable();
						
			pc.createTable();
				pc.addBorderCols("Tipo de Compromiso : "+cdo.getColValue("compromiso"), 0,setDetail.size(),cHeight);		
			pc.addTable();
				
			pc.addCopiedTable("detailHeader");	
			
					
			lCounter = lCounter + 2 ;
		}
						
		pc.createTable();
		pc.setFont(7, 0);
			pc.addCols(" "+cdo.getColValue("compra"),0,1);							
			pc.addCols(" "+cdo.getColValue("casa"),0,1) ;
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);							
			pc.addCols(" "+cdo.getColValue("vencimiento"),1,1) ;
			pc.addCols(" "+cdo.getColValue("tipo_pagos"),0,1);							
			pc.addCols(" "+cdo.getColValue("estado"),1,1) ;
			pc.addCols(""+CmnMgr.getFormattedDecimal(cdo.getColValue("valor")),2,1);
			
		pc.addTable();
						
		lCounter++;
			
		if(lCounter >= maxLines)
		{
			lCounter = lCounter - maxLines;
			pCounter++;
			pc.addNewPage();
		
		pdfHeader(pc, _comp, pCounter, nPages," DEPARTAMENTO DE COMPRAS Y PROVEEDURIAS" ," LISTADO DE COMPROMISOS POR FECHA DE VENCIMIENTO  desde  "+fDate+ " hasta "+tDate, userName, fecha);
							
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1,Color.blue);
			pc.createTable();
				pc.addBorderCols("Tipo de Compromiso : "+cdo.getColValue("compromiso"), 0,setDetail.size(),cHeight);		
			pc.addTable();
			
			pc.addCopiedTable("detailHeader");
		}
			
		groupBy = cdo.getColValue("tipo");
	}	// end for i	
	
if (al.size() == 0)
	{
	pc.createTable();
		pc.addCols("No existen registros",1,setDetail.size());
	pc.addTable();
	} else 
	{
	pc.setFont(7, 0,Color.blue);
	
		
	pc.createTable();
		pc.addCols("Total de Compromisos  :  "+al.size(),0,setDetail.size());
	pc.addTable();
		
	}
pc.addNewPage();
pc.close();
response.sendRedirect(redirectFile);
}//get
%>