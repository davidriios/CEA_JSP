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
		REPORTE:		CDC400170.RDF
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();

CommonDataObject cdo1 = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
boolean withCost = request.getParameter("cost") != null && !request.getParameter("cost").trim().equals("");
boolean withPrice = request.getParameter("price") != null && !request.getParameter("price").trim().equals("");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();

String cpt = request.getParameter("cpt");
String compania = (String) session.getAttribute("_companyId");

if(cpt== null) cpt = "";

if (appendFilter == null) appendFilter = "";

	sql ="  select 'U' type,  proc.codigo codigo,nvl(proc.observacion,proc.descripcion) nombre,  nvl(proc.nombre_corto,' ') nombre_corto, precio, costo from tbl_cds_procedimiento proc where proc.codigo = '"+cpt+"' ";
	cdo1 = SQLMgr.getData(sql);
if(cdo1 == null)
{
	cdo1 = new CommonDataObject();
	cdo1.addColValue("type"," ");
	cdo1.addColValue("codigo"," ");
	cdo1.addColValue("nombre"," ");
	cdo1.addColValue("nombre_corto"," ");
	cdo1.addColValue("precio"," ");
	cdo1.addColValue("costo"," ");

}
/*Qurey medicamentos  A = Medicamentos  Quirurgicos,  B = Medicamentos de anestesia */
sql =" select 'A' type, ixp.compania iq_compania, ixp.cantidad cantidad, iq.descripcion , ixp.art_familia||'-'||ixp.art_clase||'-'||ixp.articulo codigo, ixp.cod_proced iq_cpt, to_char(iq.precio_venta, '9,999999.99') precio_venta ,(select to_char(precio, '9,999999.99') from tbl_inv_inventario where codigo_almacen = (select min(codigo_almacen) from tbl_inv_inventario where compania = iq.compania and cod_articulo = iq.cod_articulo) and compania = iq.compania and cod_articulo = iq.cod_articulo ) costo from tbl_cds_insumo_x_proc ixp,tbl_inv_articulo  iq where ((ixp.cod_proced= '"+cpt+"' ) and (iq.compania= ixp.compania) and (iq.cod_flia= ixp.art_familia) and (iq.cod_clase= ixp.art_clase) and (iq.cod_articulo= ixp.articulo)) order by iq.descripcion, ixp.art_familia||'-'||ixp.art_clase||'-'||ixp.articulo asc,4 asc,3,2 asc   ";
al = SQLMgr.getDataList(sql);

 /*union materiales  anestesia */ 
 
 sql = "select 'B' type , iaxp.compania   ia_compania, iaxp.cantidad ,  ia.descripcion , iaxp.cod_familia||'-'||iaxp.cod_clase||'-'||iaxp.cod_articulo   codigo, cp.codigo  ia_cpt, to_char(ia.precio_venta, '9,999999.99') precio_venta ,(select to_char(precio, '9,999999.99') from tbl_inv_inventario where codigo_almacen = (select min(codigo_almacen) from tbl_inv_inventario where compania = ia.compania and cod_articulo = ia.cod_articulo) and compania = ia.compania and cod_articulo = ia.cod_articulo ) costo from    tbl_cds_maletin_insumo iaxp, tbl_inv_articulo ia , tbl_cds_procedimiento cp where ((cp.codigo = '"+cpt+"') and (ia.compania= iaxp.compania) and (ia.cod_flia= iaxp.cod_familia) and (ia.cod_clase= iaxp.cod_clase) and (ia.cod_articulo= iaxp.cod_articulo)   and  cp.tipo_maletin_anestesia = iaxp.cod_maletin ) order by 1 asc, 4 asc";
al1 = SQLMgr.getDataList(sql);


/*Qurey de usos A = usos Quirurgicos, B = usos de anestesias */
sql=" select 'A ' type, axp.cod_compania   usoq_compania,  axp.cod_uso  codigo_uso, uso_q.descripcion descripcion_uso, axp.procedimiento usoq_cpt, to_char(nvl(uso_q.PRECIO_VENTA,0),'9,999999.99') precio_venta_uso, to_char(nvl(uso_q.COSTO,0),'9,999999.99') costo_uso, axp.cantidad cantidad_uso from  tbl_cds_activo_x_proc axp, tbl_sal_uso uso_q where ((axp.procedimiento = '"+cpt+"' ) and (uso_q.codigo = axp.cod_uso) and (uso_q.compania = axp.cod_compania ))  order by  1, 3 ,4 asc  ";
al2 = SQLMgr.getDataList(sql);


sql = " /* union uso anestesia */  select 'B ' type, aaxp.compania   usoa_compania,  aaxp.cod_uso  codigo_uso, uso_a.descripcion  descripcion_uso, cp.codigo   usoa_cpt, to_char(nvl(uso_a.PRECIO_VENTA,0),'9,999999.99') precio_venta_uso, to_char(nvl(uso_a.COSTO,0),'9,999999.99') costo_uso, 1 cantidad_uso from tbl_cds_maletin_activo aaxp, tbl_sal_uso uso_a , tbl_cds_procedimiento cp  where ((cp.codigo = '"+cpt+"' ) and (uso_a.codigo = aaxp.cod_uso) and (uso_a.compania =aaxp.compania ) and aaxp.cod_maletin = cp.tipo_maletin_anestesia) order by  1, 4 asc";
al3 = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int totalArt = 0;
	double total = 0.00;
	int maxLines = 48; //max lines of items
	int nPages = 0;	//number of pages
	int lineFill = 0; //empty lines to be fill
	int maxSize =0;
	if(al.size() <=  al2.size())
	maxSize += al2.size();
	else maxSize += al.size();
	
	if(al1.size() <=  al3.size())
	maxSize += al3.size();
	else maxSize += al1.size();
	
	
	int nItems = maxSize;
	int extraItems = nItems % maxLines;
	if (extraItems == 0) nPages += (nItems / maxLines);
	else nPages += (nItems / maxLines) + 1;
	if (nPages == 0) nPages = 1;

	String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	boolean logoMark = true;
	boolean statusMark = false;

	String folderName = "inventario";
	String fileNamePrefix = "print_cdc_insumos";
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
	String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+"_"+System.currentTimeMillis()+".pdf";
	String create = CmnMgr.createFolder(directory, folderName, year, month);
	if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");

	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
	int width = 612;
	int height = 792;
	boolean isLandscape = false;

	int headerFooterFont = 4;
	StringBuffer sbFooter = new StringBuffer();

	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;

	issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	Vector setDetail = new Vector();
		setDetail.addElement(".10");
		setDetail.addElement(".30");
		setDetail.addElement(".05");
		setDetail.addElement(".10"); // Costo/Precio
		
		setDetail.addElement(".07");
		setDetail.addElement(".30");
		setDetail.addElement(".07");
	

	String groupBy = "",subGroupBy = "",groupByWh ="", type  = "", type2 = "";
	int lCounter = 0;
	int pCounter = 1;
	float cHeight = 11.0f;
    int cantArt = 0,cantDev=0,whCant=0;
	double subTotal =0.0,itbm=0.0,monto=0.00;
	
	String xtraTitle = "";
  if (withCost) xtraTitle = "(COSTO)";
  else if (withPrice) xtraTitle = "(PRECIO)";
				
	pdfHeader(pc, _comp, pCounter, nPages, "INSUMOS Y USOS X PROCEDIMIENTO "+xtraTitle, " ", userName, fecha);
	
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		pc.setFont(7, 1);
		pc.addBorderCols("Materiales y Medicamentos",0,4, 0.5f, 0.0f, 0.5f, 0.5f,cHeight);
		pc.addBorderCols("Usos",0,3, 0.5f, 0.0f, 0.0f, 0.5f,cHeight);
	pc.copyTable("detailHeader");

		pc.setNoColumnFixWidth(setDetail);
		pc.setFont(7, 1);
		pc.createTable();
			pc.addBorderCols("CPT: "+cdo1.getColValue("codigo")+"         Nombre Corto: "+cdo1.getColValue("nombre_corto"),0,setDetail.size(), 0.0f, 0.5f, 0.5f, 0.5f,cHeight);
		pc.addTable();
		
		pc.createTable();
			pc.addBorderCols("Descripcion ",0,1, 0.5f, 0.0f, 0.5f, 0.0f,cHeight);
			pc.addBorderCols(" "+cdo1.getColValue("nombre"),0,6, 0.5f, 0.0f, 0.0f, 0.5f,cHeight);
		pc.addTable();

  double totPV = 0, totPVUso = 0, totCosto = 0, totCostoUso = 0, totPVA = 0 , totCostoA = 0, totPVUsoA = 0 , totCostoUsoA = 0;
					
	int h=0, j = 0,k =0 , l =0;		
	for (int i=0; i < maxSize; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
		CommonDataObject cdo2 = new CommonDataObject();
	
	if(h < al.size() || j < al2.size() )
	{
		if(h==0 && j==0)
		{
			pc.createTable();
				pc.setFont(7, 1,Color.blue);
				pc.addBorderCols("Q U I R U R G I C O",1,setDetail.size(), 0.5f, 0.0f, 0.5f, 0.5f,cHeight);
			pc.addTable();
			pc.copyTable("detailHeader1");
			pc.addCopiedTable("detailHeader");
		}
		
		if(h < al.size())
		{
		  cdo2 = (CommonDataObject) al.get(h);
		  cdo.addColValue("codigo",cdo2.getColValue("codigo"));
		  cdo.addColValue("descripcion",cdo2.getColValue("descripcion"));
		  
		  if (withPrice)
        cdo.addColValue("cantidad",cdo2.getColValue("cantidad","1")+" x " +cdo2.getColValue("precio_venta"," "));
      else if(withCost) cdo.addColValue("cantidad",cdo2.getColValue("cantidad","1")+" x " +cdo2.getColValue("costo"," "));
      else cdo.addColValue("cantidad",cdo2.getColValue("cantidad","1"));  
      
		  cdo.addColValue("precio_venta", ""+ ( Double.parseDouble(cdo2.getColValue("precio_venta","0")) * Double.parseDouble(cdo2.getColValue("cantidad","1")) ) );
		  
		  
		  // cdo.addColValue("costo","****"+cdo2.getColValue("costo"));
		  cdo.addColValue("costo", ""+ ( Double.parseDouble(cdo2.getColValue("costo","0")) * Double.parseDouble(cdo2.getColValue("cantidad","1")) ) );
		  
		  totPV += Double.parseDouble(cdo.getColValue("precio_venta", "0"));
		  totCosto += Double.parseDouble(cdo.getColValue("costo", "0"));
		  
		}
		else 
		{
			cdo.addColValue("codigo"," ");
		  	cdo.addColValue("descripcion"," ");
		  	cdo.addColValue("cantidad"," ");
		  	cdo.addColValue("precio_venta"," ");
		  	cdo.addColValue("costo"," ");
		
		}
		
		if(j < al2.size())
		{
		  cdo2 = (CommonDataObject) al2.get(j);
		  
		  cdo.addColValue("codigo_uso",cdo2.getColValue("codigo_uso"));
		  
		  String descUso = cdo2.getColValue("descripcion_uso");
		  if (withCost) descUso += " ("+cdo2.getColValue("cantidad_uso")+" x "+cdo2.getColValue("costo_uso", "0")+")";
		  else if (withPrice) descUso += " ("+cdo2.getColValue("cantidad_uso")+" x "+cdo2.getColValue("precio_venta_uso", "0")+")";
		  
		  
		  cdo.addColValue("descripcion_uso",descUso);
		  
		  //cdo.addColValue("costo_uso",cdo2.getColValue("costo_uso"));
		  //cdo.addColValue("precio_venta_uso",cdo2.getColValue("precio_venta_uso"));
		  cdo.addColValue("costo_uso", ""+ ( Double.parseDouble(cdo2.getColValue("costo_uso","0")) * Double.parseDouble(cdo2.getColValue("cantidad_uso","1")) ) );
		  cdo.addColValue("precio_venta_uso", ""+ ( Double.parseDouble(cdo2.getColValue("precio_venta_uso","0")) * Double.parseDouble(cdo2.getColValue("cantidad_uso","1")) ) );
		  
		  totPVUso += Double.parseDouble(cdo.getColValue("precio_venta_uso", "0"));
		  totCostoUso += Double.parseDouble(cdo.getColValue("costo_uso", "0"));
		  
	  }
	  else
	  {
		   cdo.addColValue("codigo_uso","");
		   cdo.addColValue("descripcion_uso","");
		   cdo.addColValue("costo_uso"," ");
		   cdo.addColValue("precio_venta_uso"," ");
	  }
	 
	 
	 	pc.setFont(7, 0);
			pc.createTable();	
				pc.addBorderCols(""+cdo.getColValue("codigo"),0,1, 0.0f, 0.0f, 0.5f, 0.0f,cHeight);
				pc.addCols(cdo.getColValue("descripcion"),0,(withCost||withPrice) ? 1 : 2,cHeight);
				pc.addBorderCols(""+cdo.getColValue("cantidad"),0,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				
				if (withCost)pc.addBorderCols(cdo.getColValue("costo", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				else if (withPrice)pc.addBorderCols(cdo.getColValue("precio_venta", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				
				// uso				
				pc.addCols(""+cdo.getColValue("codigo_uso"),1,1,cHeight);
				pc.addBorderCols(""+cdo.getColValue("descripcion_uso"),0,(withCost||withPrice) ? 1 : 2, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				
				if (withCost)pc.addBorderCols(cdo.getColValue("costo_uso", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				else if (withPrice)pc.addBorderCols(cdo.getColValue("precio_venta_uso", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				
				
			pc.addTable();
			lCounter++;
	 
	}

	if(h >= al.size() && j >= al2.size())
	 {
		if(k==0 && l==0)
		{
			pc.setFont(7, 1);
			pc.createTable();
				pc.addBorderCols(" ",0, 4, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",0, 3, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
			pc.addTable();
			
			pc.createTable();
				pc.setFont(7, 1,Color.blue);
				pc.addBorderCols("A N E S T E S I A",1,setDetail.size(), 0.5f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addTable();
			pc.copyTable("detailHeader1");
			pc.addCopiedTable("detailHeader");
		}
			
			if(k < al1.size())
			{
				  cdo2 = (CommonDataObject) al1.get(k);
				  cdo.addColValue("codigo",cdo2.getColValue("codigo"));
				  cdo.addColValue("descripcion",cdo2.getColValue("descripcion"));
				  
				  //cdo.addColValue("cantidad",cdo2.getColValue("cantidad"));
				  
				  if (withPrice)
            cdo.addColValue("cantidad",cdo2.getColValue("cantidad","1")+" x " +cdo2.getColValue("precio_venta"," "));
          else if(withCost) cdo.addColValue("cantidad",cdo2.getColValue("cantidad","1")+" x " +cdo2.getColValue("costo"," "));
          else cdo.addColValue("cantidad",cdo2.getColValue("cantidad","1")); 

				  //cdo.addColValue("precio_venta",cdo2.getColValue("precio_venta"));
				  cdo.addColValue("precio_venta", ""+ ( Double.parseDouble(cdo2.getColValue("precio_venta","0")) * Double.parseDouble(cdo2.getColValue("cantidad","1")) ) );
				  
				  //cdo.addColValue("costo",cdo2.getColValue("costo"));
				  cdo.addColValue("costo", ""+ ( Double.parseDouble(cdo2.getColValue("costo","0")) * Double.parseDouble(cdo2.getColValue("cantidad","1")) ) );
				  		  
				totPVA += Double.parseDouble(cdo.getColValue("precio_venta", "0"));
		  		totCostoA += Double.parseDouble(cdo.getColValue("costo", "0"));
				  
			  	  k++;
			}
			else 
			{
				cdo.addColValue("codigo"," ");
				cdo.addColValue("descripcion"," ");
				cdo.addColValue("cantidad"," ");
				cdo.addColValue("precio_venta"," ");
		  	        cdo.addColValue("costo"," ");
			
			}
			
			if(l < al3.size())
			{
			  cdo2 = (CommonDataObject) al3.get(l);
			  
			  cdo.addColValue("codigo_uso",cdo2.getColValue("codigo_uso"));
			  
			  String descUso = cdo2.getColValue("descripcion_uso");
		    if (withCost) descUso += " ("+cdo2.getColValue("cantidad_uso")+" x "+cdo2.getColValue("costo_uso", "0")+")";
		    else if (withPrice) descUso += " ("+cdo2.getColValue("cantidad_uso")+" x "+cdo2.getColValue("precio_venta_uso", "0")+")";
			  
			  cdo.addColValue("descripcion_uso",descUso);
			  
			  //cdo.addColValue("descripcion_uso",cdo2.getColValue("descripcion_uso"));
			  
			  //cdo.addColValue("costo_uso",cdo2.getColValue("costo_uso"));
        //cdo.addColValue("precio_venta_uso",cdo2.getColValue("precio_venta_uso"));
			  
			  cdo.addColValue("costo_uso", ""+ ( Double.parseDouble(cdo2.getColValue("costo_uso","0")) * Double.parseDouble(cdo2.getColValue("cantidad_uso","1")) ) );
		    cdo.addColValue("precio_venta_uso", ""+ ( Double.parseDouble(cdo2.getColValue("precio_venta_uso","0")) * Double.parseDouble(cdo2.getColValue("cantidad_uso","1")) ) );
			  		  
			  totPVUsoA += Double.parseDouble(cdo.getColValue("precio_venta_uso", "0"));
		          totCostoUsoA += Double.parseDouble(cdo.getColValue("costo_uso", "0"));
			  l++;
		  }
		  else
		  {
			   cdo.addColValue("codigo_uso","");
			   cdo.addColValue("descripcion_uso","");
		  }
		  pc.setFont(7, 0);
			pc.createTable();	
				pc.addBorderCols(""+cdo.getColValue("codigo"),0,1, 0.0f, 0.0f, 0.5f, 0.0f,cHeight);
				pc.addCols(""+cdo.getColValue("descripcion"),0,(withCost||withPrice) ? 1 : 2,cHeight);
				pc.addBorderCols(""+cdo.getColValue("cantidad"),0,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
								
				if (withCost)pc.addBorderCols(cdo.getColValue("costo", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				else if (withPrice)pc.addBorderCols(cdo.getColValue("precio_venta", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				
				pc.addCols(""+cdo.getColValue("codigo_uso"),0,1,cHeight);
				pc.addBorderCols(""+cdo.getColValue("descripcion_uso"),0,(withCost||withPrice) ? 1 : 2, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
								
				if (withCost)pc.addBorderCols(cdo.getColValue("costo_uso", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
				else if (withPrice)pc.addBorderCols(cdo.getColValue("precio_venta_uso", " "),2,1, 0.0f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addTable();
		  lCounter++;
	 }
	 
			if (lCounter >= maxLines)
			{
			lCounter = lCounter - maxLines;
			pc.setNoColumnFixWidth(setDetail);
			
			pc.setFont(7, 1);
			pc.createTable();
				pc.addBorderCols(" ",0, 4, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
				pc.addBorderCols(" ",0, 3, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
			pc.addTable();
			
			pCounter++;
			pc.addNewPage();
			
			pdfHeader(pc, _comp, pCounter, nPages, "INSUMOS Y USOS X PROCEDIMIENTO "+xtraTitle, " ", userName, fecha);
			
			pc.setNoColumnFixWidth(setDetail);
			pc.setFont(7, 1);
			pc.createTable();
				pc.addBorderCols("CPT: "+cdo1.getColValue("codigo")+"         Nombre Corto: "+cdo1.getColValue("nombre_corto"),0,setDetail.size(), 0.0f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addTable();
			
			pc.createTable();
				pc.addBorderCols("Descripcion ",0,1, 0.5f, 0.0f, 0.5f, 0.0f,cHeight);
				pc.addBorderCols(" "+cdo1.getColValue("nombre"),0,6, 0.5f, 0.0f, 0.0f, 0.5f,cHeight);
			pc.addTable();
			
      pc.createTable();
        pc.addBorderCols("Costo ",0,1, 0.5f, 0.0f, 0.5f, 0.0f,cHeight);
        pc.addBorderCols(" "+cdo1.getColValue("costo"," "),0,6, 0.5f, 0.0f, 0.0f, 0.5f,cHeight);
      pc.addTable();
      
      pc.createTable();
        pc.addBorderCols("Precio ",0,1, 0.5f, 0.0f, 0.5f, 0.0f,cHeight);
        pc.addBorderCols(" "+cdo1.getColValue("precio"," "),0,6, 0.5f, 0.0f, 0.0f, 0.5f,cHeight);
      pc.addTable();
      
			pc.setFont(7, 1);
			pc.createTable();
				pc.addBorderCols("",0,setDetail.size(), 0.0f, 0.5f, 0.5f, 0.5f,cHeight);
			pc.addTable();
			pc.setNoColumnFixWidth(setDetail);
			pc.addCopiedTable("detailHeader1");	
			pc.addCopiedTable("detailHeader");
					
		}
		  j++;
		  h++;
		
	}//for i

	if (al.size() +al1.size()+al2.size()+al3.size() == 0)
	{
		pc.createTable();
			pc.addCols("No existen registros",1,setDetail.size());
		pc.addTable();
	}
	else
	{
		pc.createTable();
      if (withCost || withPrice) {
        pc.addBorderCols("Total: ",2, 3, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
        pc.addBorderCols(CmnMgr.getFormattedDecimal(withCost ? totCosto + totCostoA : totPV + totPVA ),2, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
                
        pc.addBorderCols("Total: ",2, 2, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
        pc.addBorderCols(CmnMgr.getFormattedDecimal(withCost ? totCostoUso + totCostoUsoA : totPVUso + totPVUsoA),2, 1, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);

      } else {
        pc.addBorderCols("",0, 4, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
        pc.addBorderCols(" ",0, 3, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);
			}
		pc.addTable();
	}
	
	pc.addNewPage();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>