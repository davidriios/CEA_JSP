<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
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
/**
==================================================================================
		REPORTE:		INV0041.RDF
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
ArrayList alTotal = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String time=  CmnMgr.getCurrentDate("ddmmyyyyhh12mmssam");
String almacen = request.getParameter("almacen");
String compania = (String) session.getAttribute("_companyId");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String depto = request.getParameter("depto");
String anioEntrega = request.getParameter("anioEntrega");
String anioReq = request.getParameter("anioReq");
String noReq = request.getParameter("noReq");
String noEntrega = request.getParameter("noEntrega");
String articulo = request.getParameter("articulo");

String titulo = request.getParameter("titulo");
String descDepto = request.getParameter("descDepto");

if(almacen== null) almacen = "";
if(tDate== null) tDate = "";
if(fDate== null) fDate = "";
if(depto== null) depto = "";
if(anioEntrega== null) anioEntrega = "";
if(anioReq== null) anioReq = "";
if(noReq== null) noReq = "";
if(noEntrega== null) noEntrega = "";
if(articulo== null) articulo = "";
if(titulo== null) titulo = "";
if(descDepto== null) descDepto = "";

if (appendFilter == null) appendFilter = "";

if(!almacen.trim().equals(""))         appendFilter  = " and em.codigo_almacen = "+almacen;
if(!depto.trim().equals(""))           appendFilter  += " and ue.codigo = "+depto;
if(!fDate.trim().equals(""))
appendFilter += " and trunc(em.fecha_entrega) >= to_date('"+fDate+"','dd/mm/yyyy') ";
if(!tDate.trim().equals(""))
appendFilter += " and trunc(em.fecha_entrega) <= to_date('"+tDate+"','dd/mm/yyyy') ";

if(!anioEntrega.trim().equals(""))       appendFilter  += " and em.anio = "+anioEntrega;
if(!noEntrega.trim().equals(""))         appendFilter  += " and em.no_entrega ="+noEntrega;
if(!anioReq.trim().equals(""))           appendFilter  += " and sr.anio = "+anioReq;
if(!noReq.trim().equals(""))             appendFilter  += " and sr.solicitud_no = "+noReq;
if(!articulo.trim().equals(""))          appendFilter  += " and de.cod_articulo = '"+articulo+"'";


sql="select em.unidad_administrativa unidad, em.codigo_almacen cod_almacen, em.anio||' '||lpad(em.no_entrega, 6, '0') no_entrega, nvl(em.req_anio, em.pac_anio) ||'-'||nvl(em.req_solicitud_no, em.pac_solicitud_no)||'   '||(decode (em.req_tipo_solicitud,'D','DIARIA','S','SEMANAL', 'Q','QUINCENAL','M','MENSUAL'))  no_requisicion, de.cod_familia||'-'||de.cod_clase||'-'||de.cod_articulo cod_articulo, a.descripcion desc_articulo, de.cantidad entregado, i.disponible disponible, ue.descripcion desc_unidad, em.observaciones observacion, nvl(de.precio,0)*nvl(de.cantidad,0) monto, to_char(em.fecha_entrega,'dd/mm/yyyy') fecha_entrega from  tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_sec_unidad_ejec ue, tbl_inv_inventario i, tbl_inv_articulo a, tbl_inv_solicitud_req sr where em.unidad_administrativa is not null and em.compania= "+compania+"  /*se cambio compania x compania_sol*/ and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (de.cod_articulo = a.cod_articulo and de.compania = a.compania) and (em.compania_sol = ue.compania and em.unidad_administrativa = ue.codigo)	and (i.codigo_almacen = em.codigo_almacen and i.compania = em.compania /*se activo*/ and i.cod_articulo = de.cod_articulo )   and em.req_anio = sr.anio and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.compania = sr.compania and sr.tipo_transferencia = 'U' /* diferencia */  "+appendFilter+"   order by  em.unidad_administrativa asc,ue.descripcion asc,NVL(em.REQ_ANIO, em.PAC_ANIO) ||'-'||NVL(em.REQ_SOLICITUD_NO, em.PAC_SOLICITUD_NO) ||'   '||(DECODE (em.REQ_TIPO_SOLICITUD,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL'))  asc , em.anio||' '||lpad(em.no_entrega, 6, '0') asc,a.descripcion asc ";

//em.unidad_administrativa asc,ue.descripcion asc,NVL(em.REQ_ANIO, em.PAC_ANIO) ||'-'||NVL(em.REQ_SOLICITUD_NO, em.PAC_SOLICITUD_NO) ||'   '||(DECODE (em.REQ_TIPO_SOLICITUD,'D','DIARIA','S','SEMANAL','Q','QUINCENAL','M','MENSUAL'))  asc ,em.anio||' '||lpad(em.no_entrega, 6, '0') desc /* em.unidad_administrativa asc,ue.descripcion asc,em.codigo_almacen asc , em.anio||' '||lpad(em.no_entrega, 6, '0')  asc, a.descripcion desc */  ";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{

/*----------------------------------------------------------------------------------------------------------*/
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

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
	String title = "INVENTARIO";
	String subtitle =  " "+descDepto;
	String xtraSubtitle = ""+titulo+"    DESDE    "+fDate+"    HASTA    "+tDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
    //float cHeight = 12.0f;


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".60");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		  
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	//first row
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	//second row	
	//pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	//table body	
	String groupBy = "",subGroupBy = "",observ ="";	
	double totalUnd = 0.00,total= 0.00,totalReq= 0.00,totalArt =0.00;
	int totalRequision =0;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

/*-------------------------------------------------------------------------------------------------------------------*/				
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_requisicion")))
		{
			totalRequision ++;
			if (i != 0)
			{
				  if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_entrega")))
				  {					
					pc.setFont(7, 1,Color.red);
					pc.addCols("Observacion: "+observ,0,dHeader.size());
				   }
				
				pc.setFont(7, 1);			
				pc.addCols("Sub Total:  ",2,3);
				pc.addCols(" $ "+CmnMgr.getFormattedDecimal(totalReq),2,2);
				totalReq =0.00;
										
				pc.setFont(7, 1);
				pc.addCols("  ",0,dHeader.size());		
				
				pc.flushTableBody(true);
				pc.deleteRows(-2);	
				
				//agrega la unidad al encabezado en memoria				
			    pc.setFont(7, 1,Color.blue);			
			    pc.addCols(" "+cdo.getColValue("unidad"),1,1);
			    pc.addCols(" "+cdo.getColValue("desc_unidad"),0,4);	
				
				pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);			
				pc.addCols("Entrega No :   "+cdo.getColValue("no_entrega")+" "+" Fecha:   "+cdo.getColValue("fecha_entrega"),0,3);				
			 }
			
			pc.setFont(7, 1);
			pc.addBorderCols("CÓDIGO",1);
			pc.addBorderCols("DESC. ARTÍCULO",0);
			pc.addBorderCols("EXISTENCIA",1);
			pc.addBorderCols("ENTREGADO",1);
			pc.addBorderCols("MONTO",1);
			pc.setTableHeader(4);		
						
			//agrega la unidad al encabezado en memoria							
			pc.setFont(7, 1,Color.blue);			
			pc.addCols(" "+cdo.getColValue("unidad"),1,1);
			pc.addCols(" "+cdo.getColValue("desc_unidad"),0,4);		
			
			if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_entrega")))
			{			
				pc.setFont(7, 1,Color.blue);		
				pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);			
				pc.addCols("Entrega No :   "+cdo.getColValue("no_entrega")+" "+" Fecha:   "+cdo.getColValue("fecha_entrega"),0,3);							
			}		
			
		}
		else if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_entrega")))
		{		
			
			pc.setFont(7, 1,Color.red);
			pc.addCols("Observacion: "+observ,0,dHeader.size());	

			pc.flushTableBody(true);
			pc.deleteRows(-1);	
			//agrega el No de Req. al encabezado en memoria			
			pc.setFont(7, 1,Color.blue);		
			pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);		
			pc.addCols("Entrega No :   "+cdo.getColValue("no_entrega")+" "+" Fecha:   "+cdo.getColValue("fecha_entrega"),0,3);		

			//imprime la linea ya que el encabezado ya fue impreso			
			pc.setFont(7, 1,Color.blue);		
			pc.addCols("Requisicion No :  "+cdo.getColValue("no_requisicion"),0,2);			
			pc.addCols("Entrega No :   "+cdo.getColValue("no_entrega")+" "+" Fecha:   "+cdo.getColValue("fecha_entrega"),0,3);			
			
			pc.setFont(7, 1);
			pc.addBorderCols("CÓDIGO",1);
			pc.addBorderCols("DESC. ARTÍCULO",0);
			pc.addBorderCols("EXISTENCIA",1);
			pc.addBorderCols("ENTREGADO",1);
			pc.addBorderCols("MONTO",1);				
			
		}	
/*-------------------------------------------------------------------------------------------------------------------*/		
		  
        pc.setVAlignment(0);	
		pc.setFont(7, 0);		
		pc.addCols(""+cdo.getColValue("cod_articulo"),0,1);
		pc.addCols(""+cdo.getColValue("desc_articulo"),0,1);
		pc.addCols(""+cdo.getColValue("disponible"),1,1);
		pc.addCols(""+cdo.getColValue("entregado"),1,1);
		pc.addCols(" $ "+CmnMgr.getFormattedDecimal(cdo.getColValue("monto")),2,1);
				
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);	

		groupBy    = cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+ cdo.getColValue("no_requisicion");
		subGroupBy = cdo.getColValue("unidad")+"-"+cdo.getColValue("cod_almacen")+"-"+cdo.getColValue("no_entrega");
		observ     = cdo.getColValue("observacion");
		
		totalReq += Double.parseDouble(cdo.getColValue("monto"));
		total += Double.parseDouble(cdo.getColValue("monto"));
		totalArt += Double.parseDouble(cdo.getColValue("entregado"));
		
	}//for i
	
	if (al.size() == 0)
	 {
	   pc.addCols("No existen registros",1,dHeader.size());
	  }else{	    
		
		pc.setFont(7, 1,Color.red);
		pc.addCols("Observacion: "+observ,0,dHeader.size());
		pc.setFont(7, 1);
		
		pc.addCols("SutTotal:  ",2,3);
		pc.addCols(" $ "+CmnMgr.getFormattedDecimal(totalReq),2,2);
		
		pc.addCols("Total:  ",2,3);
		pc.addCols(" $ "+CmnMgr.getFormattedDecimal(""+total),2,2);
		
		pc.addCols("Cantidad Total de articulos Entregados :  ",2,3);
		pc.addCols(" "+CmnMgr.getFormattedDecimal("###,###,###",totalArt),2,2);
		
		pc.addCols("Cantidad de Requisiciones ",2,3);
		pc.addCols(" "+totalRequision,2,2);		
		pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	  }
		
	pc.flushTableBody(true);
	pc.close();
	response.sendRedirect(redirectFile);		

}//get
%>