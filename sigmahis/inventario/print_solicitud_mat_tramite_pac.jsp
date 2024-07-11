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
<!-- INVENTARIO                               -->
<!-- Reporte: "SOLICITUD DE MATERIALES EN TRAMITE PARA PACIENTES" -->
<!-- Reporte: INV00115_XP                     -->
<!-- Clínica Hospital San Fernando            -->
<!-- Fecha: 20/04/2010                        -->    

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
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String hora      = CmnMgr.getCurrentDate("hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania  = (String) session.getAttribute("_companyId");
String usuario   = request.getParameter("usuario");
String sala      = request.getParameter("sala");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (usuario == null) usuario = "";
if (sala == null) sala = "";
if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";

String appendFilter1 = "";  

//--------------Parámetros--------------------//
if (!usuario.equals(""))
  {
   appendFilter1 += " and UPPER(sp.usuario_creacion) = UPPER('"+usuario+"')";
  }
if (!sala.equals(""))  
   { 
    appendFilter1 += " and sp.centro_servicio = "+sala;	      
	}	
if (!fechaini.equals(""))
   {
   appendFilter1 += " and to_date(to_char(sp.fecha_documento, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	   }
if (!fechafin.equals(""))   
   {
  appendFilter1 += " and to_date(to_char(sp.fecha_documento, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }    
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener las Requisiciones de Mat. en Tramite para Pacientes------------------//
sql = 
" select ds.cantidad as cantSolicitada, sp.anio||'-'||sp.solicitud_no as codSolicitud, "
+" to_char(sp.fecha_creacion,'dd/mm/yyyy') as fechaPedido, sp.centro_servicio as codSala, cs.descripcion descSala, "
+" to_char(p.fecha_nacimiento,'dd-mm-yyyy')||'-'||p.codigo  paciente_cod, "
+" (to_char(aa.fecha_nacimiento,'dd-mm-yyyy')||'('||aa.codigo_paciente||' - '||aa.secuencia||')') as codigoPac, "
+" p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||', '||p.primer_nombre||' '||p.segundo_nombre nombrePaciente, "
+" ds.art_familia||'-'||ds.art_clase||'-'||ds.cod_articulo as articulo, a.descripcion as descArticulos, "
+" sp.observaciones as observacion, sp.usuario_creacion as usuario, ds.renglon renglon, "
+" sp.pac_id , nvl(x.hab,'No tiene Habitacion-No tiene Cama') cama "
+" from tbl_inv_solicitud_pac sp, tbl_inv_d_sol_pac ds, tbl_inv_articulo a, "
+" tbl_adm_paciente p, tbl_adm_admision aa, tbl_cds_centro_servicio cs, "
+" (select pac_id, admision, max(codigo) codCama, 'Habitacion: '||habitacion||' - '||'Cama:'||cama hab "
+" from tbl_adm_cama_admision where fecha_final is null "
+" group by 'Habitacion: '||habitacion||' - '||'Cama:'||cama, pac_id, admision) x "
+" where "
+" (ds.compania  = sp.compania and  ds.solicitud_no  = sp.solicitud_no and ds.anio = sp.anio)   and "
+" (sp.pac_id    = p.pac_id)   and (ds.compania  = a.compania  and ds.art_familia  = a.cod_flia and "
+"  ds.art_clase = a.cod_clase and ds.cod_articulo  = a.cod_articulo) and "
+" (sp.impreso_sino  = 'N'     and sp.estado        = 'T')  /*TRAMITE*/ and "
+" (aa.pac_id = sp.pac_id and aa.secuencia = sp.adm_secuencia and aa.estado not in ('I')) and "
+" (cs.codigo =  sp.centro_servicio(+)) and "
+" (sp.adm_secuencia = x.admision(+) and sp.pac_id = x.pac_id(+)) "+appendFilter1
+" order by 4,5,7,2,13 " ;    
  
//cdo = SQLMgr.getData(sql);
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
	float height = 72 * 11f;//792
	boolean isLandscape = false;  
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = false;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "INVENTARIO";
	String subtitle = "SOLICITUD DE MATERIALES EN TRAMITE PARA PACIENTES";	
	String xtraSubtitle = "DESDE:  "+fechaini+"  HASTA:  "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;  
	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	Vector dHeader = new Vector();
	    		
		dHeader.addElement(".12");	
		dHeader.addElement(".50");
		dHeader.addElement(".11");	
		dHeader.addElement(".12");	
		dHeader.addElement(".15");			
	
	pc.createTable("titulos");	
	pc.setNoColumn(5);
	pc.setNoColumnFixWidth(dHeader);  			
		pc.setFont(9, 0);
		pc.addCols("CÓDIGO",1,1);			
		pc.addCols("DESC. ARTÍCULO",1,1);
		pc.addCols("PEDIDO",1,1);
		pc.addCols("ENTREGADO",1,1);
	    pc.addCols("RECIBIDO",1,1);
		
			
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);
		
	String groupBy = "", groupBy2 = "", groupBy3 = "";
	int axreq = 0, req = 0;
	for (int i=0; i<al.size(); i++)
	{	
       cdo = (CommonDataObject) al.get(i);  		   
	   // Inicio --- Agrupamiento x Sala		 
		 if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"))) 
		   { // groupBy
			   if (i != 0)  
			     {// i				    
				   axreq = 0;	
	              }// i		        
			        pc.setFont(8, 0); 
					pc.addCols("USER: "+cdo.getColValue("usuario")+"            HORA: "+hora,1,dHeader.size());
					pc.setFont(10, 0); 			  
			        pc.addCols("SALA:",0,1,cHeight);
		            pc.addCols("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"),0,dHeader.size());			       
			        req++; 
		    }// groupBy	
			// Fin --- Agrupamiento x Sala 
			
         // Inicio --- Agrupamiento x Paciente
			if(!groupBy2.equalsIgnoreCase("[ "+cdo.getColValue("codigoPac")+" ] "))
			  {  // groupBy2
			    if (i != 0)  
			      {// i 				  
				     pc.setFont(10, 0);													
				     axreq = 0;	
	               }// i
				   pc.setFont(10, 0);	
				    pc.addCols(" ",0,dHeader.size()); 					
				    pc.addCols("Paciente:",0,1,cHeight);
			        pc.addCols("[ "+cdo.getColValue("codigoPac")+" ] "+"  "+cdo.getColValue("nombrePaciente"),0,dHeader.size());
			        pc.setFont(9, 0);
					pc.addCols("Cama:                    ",0,1,cHeight);
					pc.addCols(cdo.getColValue("cama"),0,dHeader.size());				
			        req++; 
			  }// groupBy2	
			// Fin --- Agrupamiento x Paciente 
			
			// Inicio --- Agrupamiento x Requisición
			if(!groupBy3.equalsIgnoreCase(cdo.getColValue("codSolicitud")))
			{  // groupBy3
			   if (i != 0)  
			     {// i 				  				   						   				  				 
				   axreq = 0;	
	              }// i
				    pc.setFont(10, 0);
     			    pc.addCols(" ",0,dHeader.size(),cHeight); 
					pc.addCols(" ",0,dHeader.size(),cHeight);
			        pc.addCols("Requisicion # :",0,1);  
			        pc.addCols(cdo.getColValue("codSolicitud"),0,1);
			        pc.addCols("Entrega # :"+"____________",0,2);
			        pc.addCols("Fecha: "+cdo.getColValue("fechaPedido"),0,1);	
					pc.setFont(10, 0);
					pc.addCols("Observación:    "+cdo.getColValue("observacion"),0,dHeader.size());		  			        
			        pc.addTableToCols("titulos",1,dHeader.size());       
			        req++; 
			   }// groupBy3
			// Fin --- Agrupamiento x Requisición
			
		   pc.setFont(10, 0);		   	
		   pc.addCols(cdo.getColValue("articulo"),0,1);	
		   pc.addCols(cdo.getColValue("descArticulos"),0,1);		
		   pc.addCols(cdo.getColValue("cantSolicitada"),1,1);
		   pc.addCols("____________",1,1);
		   pc.addCols("____________",1,1);   
		   axreq++;		  		     
		   
	groupBy = "[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala");  
	groupBy2 = "[ "+cdo.getColValue("codigoPac")+" ] ";
    groupBy3 = cdo.getColValue("codSolicitud");  
	
	}//for i  	
	
	if (al.size() == 0)                  
	{		
		pc.addCols("No existen registros",1,dHeader.size());        		
	}
	else 
	{  //Totales Finales	    			
			pc.setFont(8, 0);
			//pc.addCols("  TOTAL DE ART. X REQUISICIÓN: "+ axreq,0,dHeader.size(),cHeight);			
			//pc.setFont(8, 1,Color.black);
			//pc.addCols("  TOTAL DE REQUISICIONES:         "+ req,0,dHeader.size(),Color.lightGray);		 			
		    //pc.addCols("  TOTAL DE PACIENTES:                 "+ al.size(),0,dHeader.size(),Color.lightGray);		 
			pc.addCols(" ",0,dHeader.size(),cHeight);               		
	}  
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);    
}//get
%>



