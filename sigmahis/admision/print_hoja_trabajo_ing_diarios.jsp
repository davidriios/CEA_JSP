<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
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
<!-- Desarrollado por: José A. Acevedo C.         -->
<!-- Reporte: "Hoja de Trabajo x Sección para Ingresos Diarios"  -->
<!-- Reporte: ADM3033                             -->
<!-- Clínica Hospital San Fernando                -->
<!-- Fecha: 22/03/2010                            -->    

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

ArrayList alTotal = new ArrayList();
ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  
String sala = request.getParameter("sala");
String compania = (String) session.getAttribute("_companyId");

if (sala == null) sala = "";
if (appendFilter == null) appendFilter = ""; 

if (!compania.equals(""))  
  {
   appendFilter += " and sh.compania = "+compania;   
  }
  
if (!sala.equals(""))
{
 appendFilter += "and sh.unidad_admin = nvl('"+sala+"',sh.unidad_admin)";    
}  

//--------------------------------------------------------------------------------------------------------------//
//------------Query que obtiene los datos para la Hoja de Trabajo x Sección para Ingresos Diarios--------------//
sql = 
 " select sc.estado_cama, sc.codigo as cama, sc.habitacion, sh.unidad_admin as centro, cs.descripcion as descCentro, sth.precio, sh.estado_habitacion, "
+" getpacts_hojatrabajo(sh.estado_habitacion, sc.estado_cama, sc.codigo) as nombre, "
+" nvl(decode(sc.estado_cama,'T',' ',p.vip),' ') vip,"
+" nvl(p.sexo,' ') sexo, nvl(p.med_nombre,' ') med_nombre, "  
+" nvl(p.aseguradora,' ') as aseguradora, nvl(p.fecha_ingreso,' ') as fecha_ingreso, nvl(p.corte_cta,0) corte_cta, "
+" p.pac_id,p.edad, "
+" p.pAlt pAlt, p.precioAlt precioAlt "      
+" from "  
+" (select aca.cama, "    
+" decode(ap.vip,'S','VIP','F','FREC','N') vip, "   
+" ap.sexo, ap.pac_id, aa.fecha_creacion, "  
+" am.primer_nombre||' '||am.primer_apellido||' '||am.apellido_de_casada as  med_nombre, "
+" nvl(decode(aba.empresa,null,decode(aa.tipo_cta,'J','JUBILADO','M','MEDICO','E','EMPLEADO','P','PARTICULAR',' '), emp.nombre),' ')as aseguradora, nvl(decode(aa.corte_cta,null,to_char(aa.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(aa.fecha_ingreso,'dd/mm/yyyy'), aa.secuencia, aa.pac_id)),' ') as fecha_ingreso, "
+" nvl(aa.corte_cta,0) corte_cta, ap.f_nac, "
+" aca.precio_alt as pAlt, aca.precio_alterno as precioAlt,ap.edad "
+" from tbl_adm_admision aa, vw_adm_paciente ap, tbl_adm_medico am, tbl_adm_empresa emp, "  
+" tbl_adm_beneficios_x_admision aba, tbl_adm_cama_admision aca "
+" where aca.pac_id = aa.pac_id and aca.admision = aa.secuencia and aa.pac_id = ap.pac_id and aa.medico = am.codigo and "
+" aca.fecha_final is null and aa.estado = 'A' and aa.categoria in (1,5) and "
+" aba.pac_id(+) = aa.pac_id and aba.admision(+) = aa.secuencia and aba.prioridad(+) = 1 and nvl(aba.estado,'A') = 'A' and "
+" emp.codigo(+) = aba.empresa) p,"
+" tbl_sal_habitacion sh, tbl_sal_cama sc, tbl_sal_tipo_habitacion sth, tbl_cds_centro_servicio cs "
+" where sc.compania = sh.compania and sc.habitacion = sh.codigo and sc.compania = sth.compania and " 
+" sc.tipo_hab = sth.codigo and sc.estado_cama <> 'I' and sh.estado_habitacion <>'I' and "
+" sc.codigo= p.cama(+) and sh.unidad_admin = cs.codigo(+) "+appendFilter
+" order by sh.unidad_admin, sc.codigo " ;  

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
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "HOJA DE TRABAJO POR SECCIÓN PARA INGRESOS DIARIOS"; 
	String xtraSubtitle = "AL: "+fecha;  

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;	
	
	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".06");
		dHeader.addElement(".22");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".22");
		dHeader.addElement(".07");
		dHeader.addElement(".20");
	
	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	
	footer.setNoColumnFixWidth(dHeader);	
	footer.createTable();
	footer.setFont(6, 0);
	footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);    
footer.addCols("[ VIP/F] "+"  Esta Columna indica el programa de Fidelización al que pertenece el Paciente. ",0,dHeader.size());
footer.addCols("                   VIP      = Paciente pertenece al programa de clientes VIP.",0,dHeader.size());
footer.addCols("                   FREC  = Paciente pertenece al programa de clientes FRECUENTES.",0,dHeader.size());
footer.addCols("                   N         = Paciente es un cliente NORMAL.",0,dHeader.size());
footer.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);
		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());  	

    pc.createTable("titulos");
	pc.setNoColumn(9);
	pc.setNoColumnFixWidth(dHeader);	  	
	pc.setFont(7, 1);				
		pc.addBorderCols("MONTO",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("CAMA",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("VIP/F",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("SEXO",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("EDAD",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("MEDICO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("INGRESO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("ASEGURADORA",1,1,cHeight * 2,Color.lightGray);    	
				
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);
	
	String groupBy = " ", cama = "";
	int montos = 0, totMontos = 0, totFinalMontos = 0;      	
	int totPact =0, totFinalPact = 0;
	int cantPact =0;
	
	for (int i=0; i<al.size(); i++)
	{			
      cdo = (CommonDataObject) al.get(i);
		 
      // Inicio --- Agrupamiento x Sala	
	  if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("centro")+" ] "+cdo.getColValue("descCentro")))
		{ // groupBy
			if (i != 0)
			{// i 
			     totFinalPact   = totFinalPact   + totPact;  
				 totFinalMontos = totFinalMontos + totMontos;	
				   	
		     pc.setFont(8, 1,Color.blue);
	        pc.addCols("Camas En Uso:   "+totPact+"     Por:     "+CmnMgr.getFormattedDecimal(totMontos),0,dHeader.size(),cHeight); 	         pc.addCols(" ",0,dHeader.size(),cHeight); 			
			 totPact   = 0;
			 totMontos = 0;				 	 
			}// i	
			   	pc.setFont(8, 1,Color.blue);  
				pc.addCols("SALA:",0,1,cHeight); 
				pc.addCols("[ "+cdo.getColValue("centro")+" ] "+cdo.getColValue("descCentro"),0,dHeader.size(),cHeight);	
		        pc.addTableToCols("titulos",1,dHeader.size()); 						    	  				
	     }// groupBy		 		
		// Fin --- Agrupamiento x Sala 	
		 
       // valida el conteo de las Camas en Uso (conteo de pacientes)	
if ((cdo.getColValue("nombre") != "") && (!cdo.getColValue("nombre").trim().equals("CAMA EN TRAMITE")) && (!cdo.getColValue("nombre").trim().equals("EN MANTENIMIENTO")) &&  (!cama.trim().equals(cdo.getColValue("cama"))))     
		 {
		  totPact++;        	  	           		  
		 }
		 
	// valida el tipo de Monto a mostrar
	if (cdo.getColValue("pAlt").equals("S"))
	   {
	     montos = Integer.parseInt(cdo.getColValue("precioAlt"));  
	   }else{
	     montos = Integer.parseInt(cdo.getColValue("precio"));
	     }	

	if (!cama.trim().equals(cdo.getColValue("cama"))) 
	  {//valida si se asigna una cama a + de un paciente
		   if (!cdo.getColValue("nombre").trim().equals("CAMA EN TRAMITE")) 
		     {//cambia color del registro para CAMAS EN TRAMITE
		       pc.setFont(7, 0,Color.black);  	
			   pc.addBorderCols(""+CmnMgr.getFormattedDecimal(montos),2,1,cHeight);  
			   pc.addBorderCols(""+cdo.getColValue("cama"),1,1,cHeight);
		       pc.addBorderCols(""+cdo.getColValue("nombre"),0,1,cHeight);
			   pc.addBorderCols(""+cdo.getColValue("vip"),1,1,cHeight);    
			   pc.addBorderCols(""+cdo.getColValue("sexo"),1,1,cHeight);    
			   pc.addBorderCols(""+cdo.getColValue("edad"),1,1,cHeight);
			   pc.addBorderCols(""+cdo.getColValue("med_nombre"),0,1,cHeight);  
			   pc.addBorderCols(""+cdo.getColValue("fecha_ingreso"),0,1,cHeight);
			   pc.addBorderCols(""+cdo.getColValue("aseguradora"),0,1,cHeight);	
		     }else{
		       pc.setFont(7, 0,Color.red);
			   pc.addBorderCols(""+CmnMgr.getFormattedDecimal(montos),2,1,cHeight);  
			   pc.addBorderCols(""+cdo.getColValue("cama"),1,1,cHeight);
		       pc.addBorderCols(""+cdo.getColValue("nombre"),0,1,cHeight);
			   pc.addBorderCols(""+cdo.getColValue("vip"),1,1,cHeight);  
			   pc.addBorderCols(""+cdo.getColValue("sexo"),1,1,cHeight);    
			   pc.addBorderCols(""+cdo.getColValue("edad"),1,1,cHeight);  
			   pc.addBorderCols(""+cdo.getColValue("med_nombre"),0,1,cHeight);  
			   pc.addBorderCols(""+cdo.getColValue("fecha_ingreso"),0,1,cHeight);
			   pc.addBorderCols(""+cdo.getColValue("aseguradora"),0,1,cHeight);		
		     } 
	  }else{
		    pc.setFont(7, 0,Color.black);  	
			pc.addBorderCols("",2,1,cHeight);  
			pc.addBorderCols("",1,1,cHeight);
		    pc.addBorderCols("",0,1,cHeight);
			pc.addBorderCols("",1,1,cHeight);    
			pc.addBorderCols("",1,1,cHeight);    
			pc.addBorderCols("",1,1,cHeight);
			pc.addBorderCols("",0,1,cHeight);  
			pc.addBorderCols("",0,1,cHeight);
			pc.addBorderCols("",0,1,cHeight);		
		}
  
   // valida el Monto de las Camas en Uso   
  if ((cdo.getColValue("nombre") != "") && (!cdo.getColValue("nombre").trim().equals("EN MANTENIMIENTO")) && (!cama.trim().equals(cdo.getColValue("cama"))))     
		 {		  
		  totMontos = totMontos + montos ;	  	            		        	  	           		  
		 }
		
	cama     = cdo.getColValue("cama"); 		 
	groupBy  = "[ "+cdo.getColValue("centro")+" ] "+cdo.getColValue("descCentro");	      	   
	  
	}//for i

	if (al.size() == 0)        
	{		
	   pc.addCols("No existen registros",1,dHeader.size());    	               	
	}
	else 	    
	{//Totales Finales  	   
	  totFinalPact   = totFinalPact   + totPact;
	  totFinalMontos = totFinalMontos + totMontos;
	   
	  pc.setFont(8, 1,Color.blue);       
      pc.addCols("Camas En Uso:   "+totPact+"     Por:     "+CmnMgr.getFormattedDecimal(totMontos),0,dHeader.size(),cHeight);  	  
	  pc.addCols(" ",0,dHeader.size(),cHeight);	 
	  pc.addCols(" GRAN TOTAL :   "+totFinalPact+"               $"+CmnMgr.getFormattedDecimal(totFinalMontos),0,dHeader.size(),Color.lightGray);	  
	}      
	 pc.addTable();      
	 pc.close();    
	response.sendRedirect(redirectFile);              
}//get
%>
