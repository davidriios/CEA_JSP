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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String sala = request.getParameter("sala");

String categoria       = request.getParameter("categoria");
String centroServicio  = request.getParameter("area");
String codAseguradora  = request.getParameter("aseguradora");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");
String habitacion        = request.getParameter("habitacion");
String cdsAdm = request.getParameter("cdsAdm");
String cdsAdmDesc = request.getParameter("cdsAdmDesc");

if (categoria == null)     categoria       = "";
if (centroServicio == null) centroServicio = "";
if (codAseguradora == null) codAseguradora = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (sala == null) sala = "";
if (habitacion == null) habitacion = "";
if (cdsAdm == null) cdsAdm = "";
if (cdsAdmDesc == null) cdsAdmDesc = "";

//--------------Parámetros--------------------//
if (!habitacion.trim().equals("") || !centroServicio.trim().equals("")) {
	sbFilter.append(" and exists (select null from tbl_adm_cama_admision c where pac_id = zz.pac_id and admision = zz.admision and hora_inicio = zz.last_bed");
		if (!habitacion.trim().equals("")) { sbFilter.append(" and habitacion = '"); sbFilter.append(habitacion); sbFilter.append("'"); }
		if (!centroServicio.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_sal_habitacion where compania = c.compania and codigo = c.habitacion and unidad_admin = "); sbFilter.append(centroServicio); sbFilter.append(")"); }
	sbFilter.append(")");
}
if (!cdsAdm.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_admision where pac_id = zz.pac_id and secuencia = zz.admision and centro_servicio = "); sbFilter.append(cdsAdm); sbFilter.append(")"); }
if (!codAseguradora.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_adm_beneficios_x_admision where pac_id = zz.pac_id and admision = zz.admision and prioridad = 1 and nvl(estado,'A') = 'A' and empresa = "); sbFilter.append(codAseguradora); sbFilter.append(")"); }
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos de Pacientes Fallecidos----------------------------------------//
sbSql.append("select '('||zz.pac_id||' - '||zz.admision||')' as codigoPaciente");
sbSql.append(", (select to_char(fecha_ingreso,'dd/mm/yyyy') from tbl_adm_admision aa where pac_id = zz.pac_id and secuencia = zz.admision) as fechaIngreso");
sbSql.append(", (select getMedicosHonesp(compania,pac_id,secuencia) from tbl_adm_admision aa where pac_id = zz.pac_id and secuencia = zz.admision) as medicos");
sbSql.append(", (select habitacion from tbl_adm_cama_admision c where pac_id = zz.pac_id and admision = zz.admision and hora_inicio = zz.last_bed) as habitacion");
sbSql.append(", (select (select unidad_admin from tbl_sal_habitacion h where compania = c.compania and codigo = c.habitacion) from tbl_adm_cama_admision c where pac_id = zz.pac_id and admision = zz.admision and hora_inicio = zz.last_bed) as codSala");
sbSql.append(", (select (select (select descripcion from tbl_cds_centro_servicio where compania_unorg = h.compania and codigo = h.unidad_admin) from tbl_sal_habitacion h where compania = c.compania and codigo = c.habitacion) from tbl_adm_cama_admision c where pac_id = zz.pac_id and admision = zz.admision and hora_inicio = zz.last_bed) as descSala");
sbSql.append(", zz.* from (");
	sbSql.append("select z.fecha_fallecido, z.pac_id, z.pac_id as pacId, z.primer_apellido||' '||z.segundo_apellido||' '||z.apellido_de_casada||' '||z.primer_nombre||' '||z.segundo_nombre as nombrePaciente, coalesce(z.pasaporte,z.provincia||'-'||z.sigla||'-'||z.tomo||'-'||z.asiento)||'-'||z.d_cedula as cedula, to_char(z.fecha_fallecido,'dd/mm/yyyy') as fechaFallecimiento, to_char(z.f_nac,'dd/mm/yyyy') as fechaNacimiento, z.codigo as codPaciente, (select max(secuencia) from tbl_adm_admision a where pac_id = z.pac_id and estado in ('I','E','A') and categoria = 1 and exists (select null from tbl_adm_cama_admision where pac_id = a.pac_id and admision = a.secuencia)) as admision, (select count(*) from tbl_adm_cama_admision c where pac_id = z.pac_id and admision = (select max(secuencia) from tbl_adm_admision a where pac_id = z.pac_id and estado in ('I','E','A') and categoria = 1 and exists (select null from tbl_adm_cama_admision where pac_id = a.pac_id and admision = a.secuencia))) as camas, (select max(hora_inicio) from tbl_adm_cama_admision c where pac_id = z.pac_id and admision = (select max(secuencia) from tbl_adm_admision a where pac_id = z.pac_id and estado in ('I','E','A') and categoria = 1 and exists (select null from tbl_adm_cama_admision where pac_id = a.pac_id and admision = a.secuencia))) as last_bed from vw_adm_paciente z where z.fallecido = 'S'");
	sbSql.append(" and exists (select null from tbl_adm_admision a where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and pac_id = z.pac_id and estado in ('I','E','A') and categoria = 1");
		sbSql.append(" and exists (select null from tbl_adm_cama_admision c where pac_id = a.pac_id and admision = a.secuencia)");
	sbSql.append(")");
	if (!fechaini.trim().equals("") && !fechafin.trim().equals("")) { sbSql.append(" and trunc(z.fecha_fallecido) between to_date('"); sbSql.append(fechaini); sbSql.append("','dd/mm/yyyy') and to_date('"); sbSql.append(fechafin); sbSql.append("','dd/mm/yyyy')"); }
sbSql.append(") zz");
if (sbFilter.length() > 0) { sbSql.append(" where"); sbSql.append(sbFilter.substring(4)); }
sbSql.append(" order by 5, 6, 7");
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
	String subtitle = "INFORME DE PACIENTES FALLECIDOS";
	String xtraSubtitle = "DEL "+fechaini+" AL "+fechafin;
	//if (!cdsAdmDesc.trim().equals("")) xtraSubtitle += "\nADMITIDO POR (CDS): "+cdsAdmDesc;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".28");	
		dHeader.addElement(".08");	
		dHeader.addElement(".07");
		dHeader.addElement(".11");		
		dHeader.addElement(".08");		
		dHeader.addElement(".08");		
		dHeader.addElement(".35");	  	
		//dHeader.addElement(".30");	  			
	
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
		
		pc.addBorderCols("NOMBRE DEL PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA NAC.",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("PID",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("IDENTIFICACION",1,1,cHeight * 2,Color.lightGray);					
		pc.addBorderCols("F. INGRESO",1,1,cHeight * 2,Color.lightGray);				
		pc.addBorderCols("F. FALLECE",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("MEDICOS / ESPECIALIDAD",1,1,cHeight * 2,Color.lightGray);
		//pc.addBorderCols("ESPECIALIDAD",1,1,cHeight * 2,Color.lightGray);  			
	pc.setTableHeader(2);
	
	String groupBy = "", pacId = "";
	int pxc = 0, pcant = 0;
	for (int i=0; i<al.size(); i++)
	{		
       cdo = (CommonDataObject) al.get(i);	
	   
	   // Inicio --- Agrupamiento x Sala		 
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"))) 
		   { // groupBy
			   if (i != 0)  
			     {// i 				  
				   pc.setFont(8, 1,Color.red);									
				   pc.addCols("  TOTAL DE PACIENTES X SALA: "+ pxc,0,dHeader.size(),cHeight);	
				   //pc.addCols(" ",0,dHeader.size(),cHeight);
				   pc.setFont(6, 0,Color.black);
	               pc.addCols("(AD) - MEDICO QUE ADMITE",0,dHeader.size(),cHeight);   
	               pc.addCols("(HM) - HONORARIO MEDICO ",0,dHeader.size(),cHeight);
	               pc.addCols("(CJ) - MEDICO CIRUJANO",0,dHeader.size(),cHeight);	
				   pc.addCols(" ",0,dHeader.size(),cHeight);
				   pxc = 0;	
	              }// i
				 pc.setFont(8, 1,Color.blue); 
				 pc.addCols("SALA:",0,1,cHeight);
		         pc.addCols("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"),0,dHeader.size(),cHeight); 	   
		    }// groupBy	
	// Fin --- Agrupamiento x Sala  	    
		
		   pc.setFont(7, 0);
		   if (!pacId.trim().equals(cdo.getColValue("pacId")))
		   {		   	
		   pc.addBorderCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);	
		   pc.addBorderCols(" "+cdo.getColValue("fechaNacimiento"),1,1,cHeight);
		   pc.addBorderCols(" "+cdo.getColValue("pacId"),1,1,cHeight);
		   pc.addBorderCols(" "+cdo.getColValue("cedula"),0,1,cHeight);
		   pc.addBorderCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);		
		   pc.addBorderCols(" "+cdo.getColValue("fechaFallecimiento"),1,1,cHeight);		
		   pc.addBorderCols(" "+cdo.getColValue("medicos"),0,1);		 
		   //pc.addBorderCols(" ",0,1);   
		   pxc++;  
		   pcant++;			   
		   }else{
		    pc.addCols(" ",0,1,cHeight);	
		    pc.addBorderCols(" ",1,1,cHeight);
		    pc.addBorderCols(" ",0,1,cHeight);
		    pc.addBorderCols(" ",0,1,cHeight);
		    pc.addBorderCols(" ",1,1,cHeight);		
		    pc.addBorderCols(" ",1,1,cHeight);		
		    pc.addBorderCols(" "+cdo.getColValue("medicos"),0,1);	
			//pc.addBorderCols(" "+cdo.getColValue("especialidad"),0,1);     
		   }
		   pacId=cdo.getColValue("pacId");
		   	
	groupBy = "[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"); 
	
	}//for i	
	
	if (al.size() == 0)                  
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{  //Totales Finales	    			
			pc.setFont(8, 1,Color.red);
			pc.addCols("  TOTAL DE PACIENTES X SALA: "+ pxc,0,dHeader.size(),cHeight);
			pc.setFont(6, 0,Color.black);				
			pc.addCols("(AD) - MEDICO QUE ADMITE",0,dHeader.size(),cHeight);   
	        pc.addCols("(HM) - HONORARIO MEDICO ",0,dHeader.size(),cHeight);
	        pc.addCols("(CJ) - MEDICO CIRUJANO",0,dHeader.size(),cHeight);	
			pc.addCols(" ",0,dHeader.size(),cHeight);
			pc.setFont(8, 1,Color.black);			  
			pc.addCols("  CANT. TOTAL DE PACIENTES:   "+ pcant,0,dHeader.size(),Color.lightGray);				 
			pc.addCols(" ",0,dHeader.size(),cHeight);       		
	}  
	pc.addTable();  
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>



