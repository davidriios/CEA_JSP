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
<!-- Reporte: "REPORTE ESTADÍSTICAS DE CONSULTAS EN CU - AXA"  -->
<!-- Reporte: ADM100222                       -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 05/08/2010                        --> 

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

ArrayList al  = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
//CommonDataObject cdo2 = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
String compania = (String) session.getAttribute("_companyId");

String area      = request.getParameter("area");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (area         == null) area         = "";
if (fechaini     == null) fechaini     = "";
if (fechafin     == null) fechafin     = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//Variables de trabajo//
String lab  = "", rx    = "", ekg    = "";
int cantLab = 0, cantRX = 0, cantEKG = 0;

//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and c.compania = "+compania;  
  }
  
if (!area.equals(""))
{
  appendFilter1 += " and c.centro_servicio = "+area;
}

if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(c.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
   
if (!fechafin.equals(""))
   {
appendFilter1 += " and to_date(to_char(c.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener Estadísticas de Consulta en CU - AXA---------------------------------//
sql = 
" select to_char(c.fecha_ingreso,'dd/mm/yyyy') fechaIngreso, to_char(c.fecha_ingreso,'mm') mes, to_char(c.fecha_ingreso,'dd') dia, (to_char(c.fecha_nacimiento,'dd-mm-yyyy')||'('||c.codigo_paciente||' - '||c.secuencia||')') as codigoPac, decode(p.apellido_de_casada,null,p.primer_apellido||' '||p.segundo_apellido,p.apellido_de_casada)||' '||p.primer_nombre||' '||p.segundo_nombre nombrePac, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||' '||p.provincia cedula, c.fecha_nacimiento, c.codigo_paciente, c.secuencia, c.medico codMedico, e.nombre as aseguradora, b.certificado, b.poliza poliza, c.categoria, c.centro_servicio codCentro, cds.descripcion descCentro, decode(med.apellido_de_casada,null,med.primer_apellido||' '||med.segundo_apellido,med.apellido_de_casada)||' '||med.primer_nombre||' '||med.segundo_nombre medico, c.pac_id pacId, getDiagnosticoSalidaCU(c.pac_id,c.secuencia) diagnosticos from tbl_adm_paciente p, tbl_adm_admision c, tbl_adm_empresa e, tbl_adm_beneficios_x_admision b, tbl_cds_centro_servicio cds, tbl_adm_medico med where p.codigo = c.codigo_paciente and p.fecha_nacimiento = c.fecha_nacimiento and c.pac_id = b.pac_id(+) and c.secuencia = b.admision(+) and b.prioridad(+) = 1 /*and p.pac_id = b.pac_id*/ and b.empresa = e.codigo(+) and c.estado in ('A','E','I') and e.codigo = 236 /*** SOLO (AXA) ***/ and c.centro_servicio = cds.codigo and med.codigo = c.medico "+appendFilter1+" group by to_char(c.fecha_ingreso,'dd/mm/yyyy'), to_char(c.fecha_ingreso,'mm'), to_char(c.fecha_ingreso,'dd'), (p.fecha_nacimiento||'/'|| p.codigo||'-'||c.secuencia), decode(p.apellido_de_casada,null,p.primer_apellido||' '||p.segundo_apellido,p.apellido_de_casada)||' '||p.primer_nombre||' '||p.segundo_nombre, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||' '||p.provincia, c.fecha_nacimiento, c.codigo_paciente, c.secuencia, c.medico, e.nombre, b.certificado, b.poliza, c.categoria, c.centro_servicio, cds.descripcion, decode(med.apellido_de_casada,null,med.primer_apellido||' '||med.segundo_apellido,med.apellido_de_casada)||' '||med.primer_nombre||' '||med.segundo_nombre, c.pac_id, getDiagnosticoSalidaCU(c.pac_id,c.secuencia) order by 15,16,1,2,3,4,5 ";

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
	String subtitle = "ESTADÍSTICAS DE CONSULTAS EN CU - AXA";
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
		
		dHeader.addElement(".03");		
		dHeader.addElement(".03");
		dHeader.addElement(".08");
		dHeader.addElement(".16");
		dHeader.addElement(".05");
		dHeader.addElement(".18");
		dHeader.addElement(".24");
		//dHeader.addElement(".15");			
		dHeader.addElement(".04");	
		dHeader.addElement(".04");	
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".07");	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	   pc.setFont(7, 1);		
	   pc.addBorderCols("FECHA",1,2,cHeight);
	   pc.addBorderCols("PACIENTE",1,2,cHeight);
	   pc.addCols(" ",1,8,cHeight);
	   
	   pc.setFont(7, 1);		
	   pc.addBorderCols(" ",1,5,cHeight);
	   pc.addBorderCols("DIAGNÓSTICO DE ADMISIÓN",1,2,cHeight);
	   pc.addBorderCols("ANCILARES",1,3,cHeight);
	   pc.addBorderCols(" ",1,2,cHeight);
		
		pc.setFont(7, 1);		
		pc.addBorderCols("MES",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DÍA",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("CÓDIGO",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRE",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("No. AXA",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("MÉDICO",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols(" ICD9         -          DESCRIPCIÓN",0,1,cHeight * 2,Color.lightGray);		
		//pc.addBorderCols("DESCRIPCIÓN",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("LAB",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("RX",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("EKG",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("HOSP.",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("OBSERVACIONES",1,1,cHeight * 2,Color.lightGray);
		
	pc.setTableHeader(2);
	
	int    pxa = 0;		
	String groupBy = "";	
	
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);					
		
		 // Inicio --- Agrupamiento x Centro		 
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codCentro")+" ] ")) 
		   { // groupBy2
			   if (i != 0)
			      {// i - 1			  
				    pc.setFont(8, 1,Color.red);
				    pc.addCols("  TOTAL DE PACIENTES X ÁREA: "+ pxa,0,dHeader.size(),cHeight);	
					pc.addCols(" ",0,dHeader.size(),cHeight);	
					pxa   = 0;						
	               }// i - 1		 
		       
			pc.setFont(8, 1,Color.blue);
			pc.addCols("CENTRO:",0,2,cHeight);
			pc.addCols("[ "+cdo.getColValue("descCentro")+" ] ",0,dHeader.size(),cHeight);								
		  }// groupBy	
	// Fin --- Agrupamiento x Centro	
	
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener la cant. de Laboratorios - AXA---------------------------------------//
sql = " select count (t.centro_servicio) cantLab from tbl_fac_transaccion t, tbl_fac_detalle_transaccion dt where (t.codigo = dt.fac_codigo and t.admi_secuencia = dt.fac_secuencia and t.pac_id = dt.pac_id and t.compania = dt.compania and t.tipo_transaccion = dt.tipo_transaccion) and t.centro_servicio in (select cs.codigo from tbl_cds_centro_servicio cs where cs.reporta_a = 14) and t.pac_id = "+cdo.getColValue("pacId")+" and t.admi_secuencia = "+cdo.getColValue("secuencia");

 cantLab = CmnMgr.getCount(sql);	  
   
     if (cantLab > 0) lab = "S";	 
	   else lab = " ";	
	   
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener la cantidad de RX - AXA----------------------------------------------//
sql = " select count (t.centro_servicio) cantRX from tbl_fac_transaccion t, tbl_fac_detalle_transaccion dt where (t.codigo = dt.fac_codigo and t.admi_secuencia = dt.fac_secuencia and t.pac_id = dt.pac_id and t.compania = dt.compania and t.tipo_transaccion = dt.tipo_transaccion) and t.centro_servicio in (select cs.codigo from tbl_cds_centro_servicio cs where cs.codigo in(15,116)) and t.pac_id = "+cdo.getColValue("pacId")+" and t.admi_secuencia = "+cdo.getColValue("secuencia");

   cantRX = CmnMgr.getCount(sql);
     
	  if (cantRX > 0) rx = "S";
	    else rx = " ";
		
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener los EKG - AXA---------------------------------------------------------//
sql = " select count(descripcion) cantEKG from tbl_sal_resultado_ekg r where r.pac_id = "+cdo.getColValue("pacId")+" and r.secuencia = "+cdo.getColValue("secuencia");	

 cantEKG = CmnMgr.getCount(sql);
	   
	   if (cantEKG > 0) ekg = "S";
	     else ekg = "N";
	    	 
		    pc.setFont(7, 0);		
   			pc.addCols(" "+cdo.getColValue("mes"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("dia"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("codigoPac"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("nombrePac"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("poliza"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("medico"),0,1,cHeight); 			
			pc.addCols(" "+cdo.getColValue("diagnosticos"),0,1,cHeight);    //icd9 - diagnostico						
			//pc.addCols(" "+cdo.getColValue("diagnosticos"),0,1,cHeight); //					
			pc.addBorderCols(" "+lab,1,1,cHeight);
			pc.addBorderCols(" "+rx,1,1,cHeight);
			pc.addBorderCols(" "+ekg,1,1,cHeight);
			pc.addBorderCols(" "+((cdo.getColValue("categoria").trim().equals("1"))?"SI":"NO"),1,1,cHeight);//hospitalizado
			pc.addCols("______________________"+" ",0,1,cHeight);//observaciones			
			pxa++;
		
		groupBy = "[ "+cdo.getColValue("codCentro")+" ] ";
		 
	}//for i 

	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales	
	    pc.setFont(8, 1,Color.red);
		pc.addCols("  TOTAL DE PACIENTES X ÁREA: "+ pxa,0,dHeader.size(),cHeight);				
		pc.setFont(8, 1,Color.black);			
		pc.addCols(" GRAN TOTAL:   "+ al.size(),0,dHeader.size(),Color.lightGray);	 			
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>






