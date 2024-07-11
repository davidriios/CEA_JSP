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
<!-- Desarrollado por: José A. Acevedo C.      -->
<!-- Reporte: "Pacientes Admitidos x Médico"   -->
<!-- Reporte: ADM_10033                        -->
<!-- Clínica Hospital San Fernando             -->
<!-- Fecha: 08/06/2010                         -->

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
String userName = UserDet.getUserName();  /*quitar el comentario * */

String sala = request.getParameter("sala");
String medico = request.getParameter("medico");
String compania = (String) session.getAttribute("_companyId");
String centroServicio  = request.getParameter("area");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin"); 
String habitacion = request.getParameter("habitacion") == null ? "" : request.getParameter("habitacion");
String cdsAdm = request.getParameter("cdsAdm");
String cdsAdmDesc = request.getParameter("cdsAdmDesc");

if (centroServicio == null) centroServicio = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (sala == null) sala = "";
if (medico == null) medico = "";
if (cdsAdm == null) cdsAdm = "";
if (cdsAdmDesc == null) cdsAdmDesc = "";

//--------------Parámetros--------------------//
if (!compania.trim().equals("")) { sbFilter.append(" and a.compania = "); sbFilter.append(compania); }
if (!medico.trim().equals("")) { sbFilter.append(" and a.medico = '"); sbFilter.append(medico); sbFilter.append("'"); }
if (!fechaini.equals("")) { sbFilter.append(" and trunc(a.fecha_ingreso) >= to_date('"); sbFilter.append(fechaini); sbFilter.append("', 'dd/mm/yyyy')"); }
if (!fechafin.equals("")) { sbFilter.append(" and trunc(a.fecha_ingreso) <= to_date('"); sbFilter.append(fechafin); sbFilter.append("', 'dd/mm/yyyy')"); }
if (!habitacion.trim().equals("")) { sbFilter.append(" and aca.habitacion = '"); sbFilter.append(habitacion); sbFilter.append("'"); }
if (!cdsAdm.trim().equals("")) { sbFilter.append(" and a.centro_servicio = "); sbFilter.append(cdsAdm); }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Pacientes Admitidos x Médico---------------------------------//
sbSql.append(" select decode(c.apellido_de_casada,null,c.segundo_apellido,c.apellido_de_casada||' '||c.segundo_apellido)||' '||c.primer_apellido||' '||c.primer_nombre||' '||c.segundo_nombre ||' - ' || (select em.descripcion from tbl_adm_medico_especialidad me, tbl_adm_especialidad_medica em where me.especialidad = em.codigo and me.secuencia = 1 and me.medico = a.medico) as nombreMedico, a.medico as codMedico, decode(b.apellido_de_casada,null,b.segundo_apellido,b.apellido_de_casada||' '||b.segundo_apellido)||' '||b.primer_apellido||' '||b.primer_nombre||' '||b.segundo_nombre as nombrePaciente, (to_char(a.fecha_nacimiento,'dd-mm-yyyy')||'('||a.codigo_paciente||' - '||a.secuencia||')') as codPaciente, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, to_char(a.fecha_egreso,'dd/mm/yyyy') as fechaEgreso, a.compania as cia, a.centro_servicio as codCentro, d.descripcion as descCentro, aca.habitacion from tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_medico c, tbl_cds_centro_servicio d, tbl_adm_cama_admision aca where (a.pac_id = b.pac_id) and (a.medico = c.codigo) and (a.centro_servicio = d.codigo) and aca.admision(+) = a.secuencia and aca.pac_id(+) = a.pac_id and a.estado not in ('N','P') ");
sbSql.append(sbFilter);
sbSql.append(" order by 1 asc, a.fecha_ingreso asc ");
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
	String subtitle = "INFORME DE PACIENTES ADMITIDOS POR MÉDICO";  
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
	    		
		dHeader.addElement(".30");	
		dHeader.addElement(".15");			
		dHeader.addElement(".11");				
		dHeader.addElement(".11");
		dHeader.addElement(".08");
		dHeader.addElement(".25");	  				
	
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		
		pc.addBorderCols("PACIENTE",1,1,cHeight,Color.lightGray);
		pc.addBorderCols("No. ADMISIÓN",1,1,cHeight,Color.lightGray);				
		pc.addBorderCols("F. INGRESO",1,1,cHeight,Color.lightGray);					
		pc.addBorderCols("F. EGRESO",1,1,cHeight,Color.lightGray);				 			
		pc.addBorderCols("HAB",1,1,cHeight,Color.lightGray);				 			
		pc.addBorderCols("ATENDIDO EN:",1,1,cHeight,Color.lightGray);				 			
	pc.setTableHeader(2);
		
	String groupBy = "", pacId = "";
	int pxc = 0, pcant = 0;
	for (int i=0; i<al.size(); i++)
	{		
       cdo = (CommonDataObject) al.get(i);		   
	   // Inicio --- Agrupamiento x Médico 
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codMedico")+" ] "+cdo.getColValue("nombreMedico"))) 
		   { // groupBy
			   if (i != 0)  
			     {// i 				  
				   pc.setFont(8, 1,Color.red);									
				   pc.addCols("  TOTAL DE PACIENTES ADMITIDOS POR MÉDICO: "+ pxc,0,dHeader.size(),cHeight);					   	
				   pc.addCols(" ",0,dHeader.size(),cHeight);    
				   pxc = 0;	
	              }// i
			  pc.setFont(8, 1,Color.blue); 
	pc.addCols("MÉDICO:   "+ " [ "+cdo.getColValue("codMedico")+" ]  "+cdo.getColValue("nombreMedico"),0,dHeader.size(),cHeight);
		//      pc.addCols("[ "+cdo.getColValue("codMedico")+" ] "+cdo.getColValue("nombreMedico"),0,dHeader.size(),cHeight);
		    }// groupBy	
	// Fin --- Agrupamiento x Médico	    
		
		   pc.setFont(7, 0);		   	
		   pc.addCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);	
		   pc.addCols(" "+cdo.getColValue("codPaciente"),0,1,cHeight);
		   pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);
		   pc.addCols(" "+cdo.getColValue("fechaEgreso"),1,1,cHeight);		   
		   pc.addCols(" "+cdo.getColValue("habitacion"),1,1,cHeight);		   
		   pc.addCols(" "+cdo.getColValue("descCentro"),0,1,cHeight);		   
		   pxc++;  
		  pcant++;			     
		 
	groupBy = "[ "+cdo.getColValue("codMedico")+" ] "+cdo.getColValue("nombreMedico"); 
	
	}//for i  	
	
	if (al.size() == 0)                  
	{		
		pc.addCols("No existen registros",1,dHeader.size());        		
	}
	else 
	{  //Totales Finales	    			
			pc.setFont(8, 1,Color.red);
			pc.addCols("  TOTAL DE PACIENTES POR MÉDICO: "+ pxc,0,dHeader.size(),cHeight);			
			pc.setFont(8, 1,Color.black);			  
		    pc.addCols("  CANT. TOTAL DE PACIENTES:             "+ al.size(),0,dHeader.size(),Color.lightGray);		 
			pc.addCols(" ",0,dHeader.size(),cHeight);           		
	}  
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>

