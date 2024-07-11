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
ArrayList al2 = new ArrayList();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");
String empId     = request.getParameter("empId");

String filter = "", titulo = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (appendFilter == null) appendFilter = "";
if (fechaini   == null) fechaini  = "";
if (fechafin   == null) fechafin  = "";
if (empId      == null) empId     = "";

if (!compania.equals(""))
  {
   appendFilter += " and c.codigo = "+compania;
  }    
if (!empId.equals(""))   
 {
  appendFilter += " and e.emp_id = "+empId;
 } 

/*
if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(ac.fecha_creacion, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";
   }

if (!fechafin.equals(""))
   {
appendFilter1 += " and to_date(to_char(ac.fecha_creacion, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
*/
	

sql= " select all ac.cod_acreedor codAcreedor, ac.nombre nombreAcreedor, e.primer_apellido, e.provincia, e.sigla, e.tomo, e.asiento, nvl(e.cedula1,e.cedula_beneficiario) cedula, e.nombre_empleado nombreEmpleado, e.num_empleado numEmpleado, e.ubic_depto depto, f.descripcion descUnidad, e.ubic_seccion seccion, e.ubic_fisica ubicacion, s.descripcion descSeccion, c.nombre descCia, c.logo, d.saldo, d.num_documento documento, d.descuento_mensual descMensual, d.descontado, d.descuento1, d.descuento2, to_char(d.fecha_inicial,'dd/mm/yyyy') fechaInicial, x.nombre grupo from tbl_pla_acreedor ac, tbl_sec_compania c, tbl_pla_descuento d, vw_pla_empleado e, tbl_pla_grupo_descuento x, tbl_sec_unidad_ejec f, tbl_sec_unidad_ejec s where (e.emp_id = d.emp_id and e.compania = d.cod_compania) and (x.cod_grupo = d.cod_grupo) and (d.cod_acreedor = ac.cod_acreedor and d.cod_compania = ac.compania) and (d.cod_compania = c.codigo) and (d.estado <> 'E') and  (f.codigo = e.ubic_depto and f.compania = e.compania) /*Depto*/ and (s.codigo = e.ubic_fisica and s.compania = e.compania) /*Seccion*/"+appendFilter+" order by e.ubic_depto, e.ubic_fisica, to_number(e.num_empleado), e.primer_apellido ";
														
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
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "PLANILLA";
	String subtitle = " DETALLE DE DESCUENTOS POR EMPLEADO ";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".28");	
		dHeader.addElement(".24");
		dHeader.addElement(".12");	
		dHeader.addElement(".13");		
		dHeader.addElement(".13");		
				
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String un = ""; 
		String sc = ""; 

    pc.setFont(8, 1);
	pc.addBorderCols("No. ACREEDOR",1,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("NOMBRE DEL ACREEDOR",0,1,1.0f,1.0f,0.0f,0.0f);	
	pc.addBorderCols("GRUPO DE DESCUENTO",0,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("TIPO DESC.",0,1,1.0f,1.0f,0.0f,0.0f);
	pc.addBorderCols("SALDO DEL DESCUENTO",2,1,1.0f,1.0f,0.0f,0.0f);	  
	pc.addBorderCols("DESCUENTO MENSUAL",2,1,1.0f,1.0f,0.0f,0.0f);	  
   
	String groupBy = "", groupBy1= "", periodo = "";
	int pxu = 0, pxs = 0, pxg = 0;	
	double descuento1 = 0, descuento2;
	double totDescuento = 0, totSaldo = 0;
			 
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);	
		
		descuento1 = Double.parseDouble(cdo.getColValue("descuento1"));		
		descuento2 = Double.parseDouble(cdo.getColValue("descuento2"));		
		
	//Inicio --Agrupamiento por Empleado - Depto - Sección
		if (!groupBy1.equalsIgnoreCase("[ "+cdo.getColValue("numEmpleado")+" ] "+cdo.getColValue("nombreEmpleado"))
		   && !groupBy.equalsIgnoreCase("[ "+cdo.getColValue("unidadOrgani")+" ] "+cdo.getColValue("ubicacion")))
		{ // groupBy
			if (i != 0)
			  {//i-1 			  			  	
					pc.setFont(7, 1);
					pc.addCols("CANT. DE DESCUENTOS ==> "+" . . . "+pxu,1,3);
		            pc.addCols(" TOTAL ==> ",2,1);
		            pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totSaldo),2,1,0.0f,1.0f,0.0f,0.0f);
		            pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totDescuento),2,1,0.0f,1.0f,0.0f,0.0f);	
					pc.addCols(" ",0,dHeader.size());
					pxu = 0;	 
				        
			   }//i-1					  
			pc.setFont(8, 4);		
			pc.addCols(" "+"[ "+cdo.getColValue("ubicacion")+" ] "+cdo.getColValue("descSeccion"),0,3);		
			pc.addCols(" "+cdo.getColValue("descUnidad"),2,3);	
			pc.setFont(8, 3);						
			pc.addCols("Empleado:  "+"[ "+cdo.getColValue("numEmpleado")+" ] "+cdo.getColValue("nombreEmpleado"),0,2);
			pc.addCols(" "+cdo.getColValue("cedula"),0,4);		
			pxs++;
			totSaldo     = 0;
			totDescuento = 0;
	}else
	   if (!groupBy1.equalsIgnoreCase("[ "+cdo.getColValue("numEmpleado")+" ] "+cdo.getColValue("nombreEmpleado"))
		   && groupBy.equalsIgnoreCase("[ "+cdo.getColValue("unidadOrgani")+" ] "+cdo.getColValue("ubicacion")))
		 { // groupBy
		   if (i != 0)
			  {//i-1 			  			  	
					pc.setFont(7, 1);
					pc.addCols("CANT. DE DESCUENTOS ==> "+" . . . "+pxu,1,3);
		            pc.addCols(" TOTAL ==> ",2,1);
		            pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totSaldo),2,1,0.0f,1.0f,0.0f,0.0f);
		            pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totDescuento),2,1,0.0f,1.0f,0.0f,0.0f);	
					pc.addCols(" ",0,dHeader.size());
					pxu = 0;				        
			   }//i-1				   
			pc.setFont(8, 3);					
			pc.addCols("Empleado:  "+"[ "+cdo.getColValue("numEmpleado")+" ] "+cdo.getColValue("nombreEmpleado"),0,2);
			pc.addCols(" "+cdo.getColValue("cedula"),0,4);		
			pxs++;
			totSaldo     = 0;
			totDescuento = 0;
		}//Final --Agrupamiento por Empleado - Depto - Sección	
		
		
		  if ((descuento1 == 0 /*|| descuento1 == null*/ ) && (descuento2 == 0 /*|| descuento2 == null*/))
		   {
		     periodo = "MENSUAL 1";
		   }
		   else if ((descuento1 > 0 /*|| descuento1 != null*/) &&  (descuento2 == 0 /*|| descuento2 == null*/))
		    {
			 periodo = "MENSUAL 2";
			}
		   else if ((descuento1 == 0 /*|| descuento1 != null*/) && (descuento2 > 0 /*|| descuento2 != null*/))
		   {
		     periodo = "MENSUAL 1";			 
		   }
		   else if ((descuento1 > 0 /*|| descuento1 != null*/) && (descuento2 > 0 /*|| descuento2 != null*/))
		    {
			  periodo = "QUINCENAL";
			}
			else periodo = "***";
		   
		 /*IF (:DESCUENTO1 = 0 OR :DESCUENTO1 IS NULL) AND (:DESCUENTO2 = 0 OR :DESCUENTO2 IS NULL) THEN
  	 	          V_PERIODO_DESCTO	:= 'MENSUAL 1';
          ELSIF (:DESCUENTO1 > 0 OR :DESCUENTO1 IS NOT NULL) AND (:DESCUENTO2 = 0 OR :DESCUENTO2 IS NULL) THEN
  	 	         V_PERIODO_DESCTO := 'MENSUAL 2';
          ELSIF (:DESCUENTO1 = 0 OR :DESCUENTO1 IS NOT NULL) AND (:DESCUENTO2 > 0 OR :DESCUENTO2 IS NOT NULL) THEN
  	 	        V_PERIODO_DESCTO := 'MENSUAL 1';  	 	
          ELSIF (:DESCUENTO1 > 0 OR :DESCUENTO1 IS NOT NULL) AND (:DESCUENTO2 > 0 OR :DESCUENTO2 IS NOT NULL) THEN
  	 	     V_PERIODO_DESCTO := 'QUINCENAL';
         ELSE  V_PERIODO_DESCTO := '***';
       END IF;
		*/
	
	    pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codAcreedor"),1,1);		
			pc.addCols(" "+cdo.getColValue("nombreAcreedor"),0,1);	
			pc.addCols(" "+cdo.getColValue("grupo"),0,1);	
			pc.addCols(" "+periodo,0,1);	
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("saldo"))),2,1);							
			pc.addCols(" "+CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("descMensual"))),2,1);							
			pc.setFont(7, 0);
			pc.addCols("",0,dHeader.size());	

	  groupBy1  = "[ "+cdo.getColValue("numEmpleado")+" ] "+cdo.getColValue("nombreEmpleado");
	  groupBy   = "[ "+cdo.getColValue("unidadOrgani")+" ] "+cdo.getColValue("ubicacion");
	  
	  pxu++;
	  totSaldo     += (Double.parseDouble(cdo.getColValue("saldo")));	   
	  totDescuento += (Double.parseDouble(cdo.getColValue("descMensual")));
			
	 if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	
	}
		pc.setFont(7, 0);
		pc.addCols(" ",0,dHeader.size()); 		  
		
	if (al.size() == 0) 
	{
	 pc.addCols("No existen registros",1,dHeader.size());
	}
	else 
	{		  
		pc.setFont(7, 1);
		pc.addCols("CANT. DE DESCUENTOS ==> "+" . . . "+pxu,1,3);
		pc.addCols(" TOTAL ==> ",2,1);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totSaldo),2,1,0.0f,1.0f,0.0f,0.0f);
		pc.addBorderCols(" "+CmnMgr.getFormattedDecimal(totDescuento),2,1,0.0f,1.0f,0.0f,0.0f);		
	  pc.setFont(9,0);
	  pc.addCols("TOTAL DE EMPLEADOS "+" . . . "+pxs,1,dHeader.size());	
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>

