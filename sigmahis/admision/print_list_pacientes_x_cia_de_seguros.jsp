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
<!-- Desarrollado por: José A. Acevedo C.              -->
<!-- Reporte: "Informe de Pacientes x Cia. de Seguro"  -->
<!-- Reporte: FAC70680                                 -->
<!-- Clínica Hospital San Fernando                     -->
<!-- Fecha: 03/03/2010                                 -->

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
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();
String sala = request.getParameter("sala");

String compania = (String) session.getAttribute("_companyId");

String categoria       = request.getParameter("categoria");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");  
String habitacion        = request.getParameter("habitacion");
String poliza        = request.getParameter("poliza");
String cdsAdm = request.getParameter("cdsAdm");
String cdsAdmDesc = request.getParameter("cdsAdmDesc");

if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (sala == null) sala = "";
if (habitacion == null) habitacion = "";
if (poliza == null) poliza = "";
if (cdsAdm == null) cdsAdm = "";
if (cdsAdmDesc == null) cdsAdmDesc = "";

//--------------Parámetros--------------------//
if (!compania.trim().equals("")) { sbFilter.append(" and aa.compania = "); sbFilter.append(compania); }
if (!codAseguradora.trim().equals("")) { sbFilter.append(" and c.empresa = "); sbFilter.append(codAseguradora); }
if (!poliza.trim().equals("")) { sbFilter.append(" and c.poliza = '"); sbFilter.append(poliza); sbFilter.append("'"); }
if (!habitacion.trim().equals("")) { sbFilter.append(" and aca.habitacion = '"); sbFilter.append(habitacion); sbFilter.append("'"); }
if (!cdsAdm.trim().equals("")) { sbFilter.append(" and aa.centro_servicio = "); sbFilter.append(cdsAdm); }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Pacientes x Cia. de Seguros---------------------------------//
sbSql.append("select distinct c.empresa as codAseguradora, emp.nombre as descAseguradora, pac.primer_nombre||' '||pac.segundo_nombre as nombresPacientes, aa.pac_id, aa.secuencia, decode(pac.apellido_de_casada,null,pac.primer_apellido||' '||pac.segundo_apellido,pac.apellido_de_casada) as apellidosPacientes, coalesce(pac.pasaporte,pac.provincia||'-'||pac.sigla||'-'||pac.tomo||'-'||pac.asiento)||'-'||pac.d_cedula as identificacion, pac.telefono||' / '||pac.telefono||' / '||pac.telefono_trabajo||' / '||pac.telefono_trabajo_conyugue||' / '||pac.telefono_trabajo_urgencia||' / '||telefono_urgencia as telefonosPac, c.poliza from tbl_adm_paciente pac, tbl_adm_admision aa, tbl_adm_beneficios_x_admision c, tbl_adm_empresa emp, tbl_adm_cama_admision aca where (pac.fecha_nacimiento = aa.fecha_nacimiento and pac.codigo = aa.codigo_paciente) and (aa.pac_id = c.pac_id and aa.secuencia = c.admision and c.prioridad = 1 and c.empresa = emp.codigo) ");
sbSql.append(sbFilter);
sbSql.append(" and aca.admision = aa.secuencia and aca.pac_id = aa.pac_id order by c.empresa, emp.nombre, decode(pac.apellido_de_casada,null,pac.primer_apellido||' '||pac.segundo_apellido,pac.apellido_de_casada), pac.primer_nombre||' '||pac.segundo_nombre");   
al = SQLMgr.getDataList(sbSql.toString()); 

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";
		
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
	String subtitle = "INFORME DE PACIENTES POR COMPAÑIA DE SEGUROS";  
	String xtraSubtitle = null;
	//if (!cdsAdmDesc.trim().equals("")) xtraSubtitle = "ADMITIDO POR (CDS): "+cdsAdmDesc;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".22");	
		dHeader.addElement(".13");	
		dHeader.addElement(".16");		
		dHeader.addElement(".14");		
		dHeader.addElement(".15");				
		dHeader.addElement(".20");	  				
	
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		
		pc.addBorderCols("APELLIDOS",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("NOMBRES",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID / ADMISION",1,1,cHeight * 2,Color.lightGray);						
		pc.addBorderCols("POLIZA",1,1,cHeight * 2,Color.lightGray);						
		pc.addBorderCols("IDENTIFICACION",1,1,cHeight * 2,Color.lightGray);					
		pc.addBorderCols("TELEFONOS",1,1,cHeight * 2,Color.lightGray);				 			
	pc.setTableHeader(2);
		
	String groupBy = "", pacId = "";
	int pxc = 0, pcant = 0;
	for (int i=0; i<al.size(); i++)
	{		
       cdo = (CommonDataObject) al.get(i);		   
	   // Inicio --- Agrupamiento x Aseguradora		 
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"))) 
		   { // groupBy
			   if (i != 0)  
			     {// i 				  
				   pc.setFont(8, 1,Color.red);									
				   pc.addCols("  TOTAL DE PACIENTES X ASEG: "+ pxc,0,dHeader.size(),cHeight);					   	
				   pc.addCols(" ",0,dHeader.size(),cHeight);  
				   pxc = 0;	
	              }// i
			  pc.setFont(8, 1,Color.blue); 
			  pc.addCols("ASEG:",0,1,cHeight);
		      pc.addCols("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
		    }// groupBy	
	// Fin --- Agrupamiento x Aseguradora	    
		
		   pc.setFont(7, 0);		   	
		   pc.addBorderCols(" "+cdo.getColValue("apellidosPacientes"),0,1,cHeight);	
		   pc.addBorderCols(" "+cdo.getColValue("nombresPacientes"),0,1,cHeight);
		   pc.addBorderCols(cdo.getColValue("pac_id")+"  -  "+(cdo.getColValue("secuencia")),0,1);
		   pc.addBorderCols(cdo.getColValue("poliza"),0,1);
		   pc.addBorderCols(" "+cdo.getColValue("identificacion"),0,1,cHeight);
		   pc.addBorderCols(" "+cdo.getColValue("telefonosPac"),0,1);		   
		   pxc++;  
		  pcant++;			     
		 
	groupBy = "[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"); 
	
	}//for i  	
	
	if (al.size() == 0)                  
	{		
		pc.addCols("No existen registros",1,dHeader.size());        		
	}
	else 
	{  //Totales Finales	    			
			pc.setFont(8, 1,Color.red);
			pc.addCols("  TOTAL DE PACIENTES X ASEG: "+ pxc,0,dHeader.size(),cHeight);			
			pc.setFont(8, 1,Color.black);			  
		    pc.addCols("  CANT. TOTAL DE PACIENTES:    "+ al.size(),0,dHeader.size(),Color.lightGray);		 
			pc.addCols(" ",0,dHeader.size(),cHeight);           		
	}  
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>
