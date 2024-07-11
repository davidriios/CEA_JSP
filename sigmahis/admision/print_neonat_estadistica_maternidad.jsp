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
<!-- Desarrollado por: José A. Acevedo C.       -->
<!-- Reporte: "Estadísticas de Maternidad"      -->
<!-- Reporte: ADM3083, ADM3083_BOR              -->
<!-- Clínica Hospital San Fernando              -->
<!-- Fecha: 07/07/2010                          -->

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
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

String sql = "";
String appendFilter  = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
String compania = (String) session.getAttribute("_companyId");

String evento    = request.getParameter("evento");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");
String fg        = request.getParameter("fg");

if (evento   == null) evento    = "";
if (fechaini == null) fechaini  = "";
if (fechafin == null) fechafin  = "";
if (fg       == null) fg        = "DE"; //flag para reportes Preeliminar
if (appendFilter  == null) appendFilter  = "";

String appendFilter1 = "", appendFilter2 = "";
String titulo = "";

//--------------Parámetros--------------------//
/*
if (!compania.equals(""))
  {
   appendFilter1 += " ae.compania = "+compania;  
  }
*/
if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(a.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
 appendFilter2 += " and to_date(to_char(a.fecha_nacimiento, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
if (!fechafin.equals(""))
   {
  appendFilter1 += " and to_date(to_char(a.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')";appendFilter2 += " and to_date(to_char(a.fecha_nacimiento, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')";   }
    
//--------------------------------------------------------------------------------------------------//
//--------------Query para obtener "Estadísticas de Maternidad"------------------------------------//

/*-----Listado de Pacientes x Tipo de Parto-----*/
sql = 
" select distinct 1 princip, 0, decode(a.tipo_parto,'C','CESAREA','V','PARTO VAGINAL') viaParto, count(a.tipo_parto) total from tbl_adm_admision a where a.estado not in ('N') and a.categoria = 1 and a.tipo_admision = 3 and a.tipo_parto is not null "+appendFilter1+" group by decode(a.tipo_parto,'C','CESAREA','V','PARTO VAGINAL') order by 2,1";

al = SQLMgr.getDataList(sql);

/*-----Listado de Pacientes x Aseguradora-----*/
sql = 
" select distinct 2 princip, b.empresa codEmpresa, ae.nombre empresa, count(a.fecha_nacimiento||a.codigo_paciente||a.secuencia) total from tbl_adm_admision a, tbl_adm_beneficios_x_admision b, tbl_adm_empresa ae where (a.pac_id = b.pac_id and a.secuencia = b.admision) and a.estado not in ('N') and a.categoria = 1 and a.tipo_admision = 3 and b.prioridad = 1 and a.tipo_parto is not null and b.empresa = ae.codigo "+appendFilter1+" group by ae.nombre, b.empresa order by 2,1 ";

al2 = SQLMgr.getDataList(sql);

/*-----Listado de Pacientes x Especialidad Médica-----*/
sql = 
" select m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido||' '||m.apellido_de_casada nomMedico, me.especialidad abrevEspecialidad, esp.descripcion descEspecialidad, u.ubicacion, decode(au.descripcion,null,'Ubicación nula o No Existe...',au.descripcion) descUbicacion, count(m.codigo) cantPacientes  from tbl_adm_admision a, tbl_adm_beneficios_x_admision b, tbl_adm_medico m, tbl_adm_medico_especialidad me, tbl_adm_medico_ubicacion u, tbl_adm_especialidad_medica esp ,tbl_adm_ubicacion au where (a.pac_id = b.pac_id and a.secuencia = b.admision) and a.estado not in ('N') and a.categoria = 1 and a.tipo_admision = 3 and b.prioridad = 1 and a.tipo_parto is not null and (a.medico = m.codigo and m.codigo = me.medico(+) and m.codigo = u.medico) and esp.codigo = me.especialidad and au.codigo = u.ubicacion "+appendFilter1+" group by me.especialidad, u.ubicacion, au.descripcion, esp.descripcion, m.codigo, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido||' '||m.apellido_de_casada order by 2,3,4,5,1 ";

if (fg.trim().equals("DE"))
{ //preeliminar (borrador)
sql = 
" select m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido||' '||m.apellido_de_casada nomMedico, me.especialidad abrevEspecialidad, decode(esp.descripcion,null,'Especialidad nula o No Existe...',esp.descripcion) descEspecialidad, u.ubicacion, decode(au.descripcion,null,'Ubicación nula o No Existe...',au.descripcion) descUbicacion, count(m.codigo) cantPacientes  from tbl_adm_admision a, tbl_adm_medico m, tbl_adm_medico_especialidad me, tbl_adm_medico_ubicacion u, tbl_adm_especialidad_medica esp ,tbl_adm_ubicacion au where a.estado not in ('N') and a.categoria = 1 and a.tipo_admision = 3 and a.tipo_parto is not null and (a.medico = m.codigo and m.codigo = me.medico(+) and m.codigo = u.medico(+)) and esp.codigo(+) = me.especialidad and au.codigo(+) = u.ubicacion "+appendFilter1+" group by me.especialidad, u.ubicacion, au.descripcion, esp.descripcion, m.codigo, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido||' '||m.apellido_de_casada order by 2,3,1 ";
}

al3 = SQLMgr.getDataList(sql);

/*-----Listado de Pacientes x Categoria de Habitación-----*/
sql=
" select descCategoria, count(*) cantPacientes from (select th.categoria_hab catHabitacion, decode(th.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','T','SUITE','C','COMPARTIDA','E','ECONOMICA') descCategoria, a.fecha_nacimiento fechaNac, a.codigo_paciente codPaciente, a.secuencia secuencia, sum(decode(d.tipo_transaccion,'C',d.cantidad * d.monto,'D', -d.cantidad * d.monto)) monto from tbl_adm_admision a, tbl_adm_beneficios_x_admision b, tbl_fac_detalle_transaccion d, tbl_sal_tipo_habitacion th where (a.pac_id = b.pac_id and a.secuencia = b.admision) and a.estado not in ('N') and a.categoria = 1 and  a.tipo_admision = 3 and  b.prioridad = 1 and a.tipo_parto is not null and (a.pac_id = d.pac_id and a.secuencia = d.fac_secuencia) and d.tipo_cargo = '01' and (to_number(th.codigo) = d.servicio_hab(+) and th.compania = a.compania) "+appendFilter1+" group by th.categoria_hab, a.fecha_nacimiento, a.codigo_paciente, a.secuencia, decode(d.tipo_transaccion,'C',d.cantidad * d.monto,'D', -d.cantidad * d.monto), decode(th.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','T','SUITE','C','COMPARTIDA','E','ECONOMICA') having sum(decode(d.tipo_transaccion,'C',d.cantidad * d.monto,'D', -d.cantidad * d.monto)) > 0) group by descCategoria order by 1";

if (fg.trim().equals("DE"))
{//preeliminar (borrador)
sql=
" select descCategoria, count(*) cantPacientes from (select th.categoria_hab catHabitacion, decode(th.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','T','SUITE','C','COMPARTIDA','E','ECONOMICA') descCategoria, a.fecha_nacimiento fechaNac, a.codigo_paciente codPaciente, a.secuencia secuencia from tbl_adm_admision a, tbl_fac_detalle_transaccion d, tbl_sal_tipo_habitacion th where a.estado not in ('N') and a.categoria = 1 and  a.tipo_admision = 3 and a.tipo_parto is not null and (a.pac_id = d.pac_id and a.secuencia = d.fac_secuencia) and d.tipo_cargo = '01' and to_char(d.servicio_hab) = th.codigo "+appendFilter1+" group by th.categoria_hab, a.fecha_nacimiento, a.codigo_paciente, a.secuencia, decode(th.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','T','SUITE','C','COMPARTIDA','E','ECONOMICA') having sum(decode(d.tipo_transaccion,'C',d.cantidad * d.monto,'D', -d.cantidad * d.monto)) > 0) group by descCategoria order by 1";
}

al4 =SQLMgr.getDataList(sql);

/*-----Listado de Pacientes x Médico-----*/
sql = 
" select  distinct 3 princip, 0, a.medico, m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido nomMedico, count(a.medico) casos, getneonat_especialidad_med(a.medico) as especialidad from tbl_adm_admision a, tbl_adm_medico m where m.codigo = a.medico and a.tipo_admision = 6 and a.categoria = 1 and a.estado not in ('N') "+appendFilter2+" group by m.primer_nombre||' '||m.segundo_nombre||' '||m.primer_apellido||' '||m.segundo_apellido, a.medico, getneonat_especialidad_med(a.medico) order by 3 ";

al5 = SQLMgr.getDataList(sql);

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
	
	if (fg.trim().equals("DE"))
	  {
	   //pc.setFont(8, 4);//
	   titulo = "(BORRADOR)";
	  }
		
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
	String subtitle = "ESTADÍSTICAS DE MATERNIDAD "+titulo;
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
		
		dHeader.addElement(".20");
		dHeader.addElement(".35");
		dHeader.addElement(".10");
		dHeader.addElement(".35");				

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.setTableHeader(2);	
	
	//-------------------------------------PACIENTES X TIPOS DE PARTOS-------------------------------//
	
	int pxc = 0;
	int totxAseg = 0;		 
	pc.setFont(8, 1);
	pc.addCols(" ",0,dHeader.size());	
	pc.addBorderCols(" VIA",0,2,Color.lightGray);				
	pc.addBorderCols(" CANT. PACIENTES",1,2,Color.lightGray);				
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);				
	
	    pc.setFont(7, 2);//
		pc.addBorderCols(" "+cdo.getColValue("viaParto"),0,2,cHeight);
		pc.setFont(8, 2);//
        pc.addBorderCols(" "+cdo.getColValue("total"),1,2,cHeight);		  
	}//for i

	//-------------------------------------PACIENTES X ASEGURADORA------------------------------------//	
	pc.setFont(8, 1);
	pc.addCols(" ",0,dHeader.size());
	pc.addBorderCols(" ASEGURADORAS",0,dHeader.size(),Color.lightGray);
	for (int j=0; j<al2.size(); j++)
	{
	    CommonDataObject cdo2 = (CommonDataObject) al2.get(j);
		
	    pc.setFont(7, 2);
		pc.addBorderCols(" "+cdo2.getColValue("empresa"),0,2,cHeight);
		pc.setFont(8, 2);
        pc.addBorderCols(" "+cdo2.getColValue("total"),1,2,cHeight);
		
		totxAseg += Integer.parseInt(cdo2.getColValue("total"));	
	}//for j	
	
	pc.setFont(8, 1);
	pc.addCols(" ",0,2);	  
	pc.addCols(" TOTAL POR ASEGURADORA:     "+totxAseg,0,2);	  


//---------------------------------PACIENTES X ESPECIALIDAD - UBICACIÓN------------------------------------------//			
	int  pxe = 0, pxu = 0;
	int  totFinal = 0; 		
	String groupBy  = "", groupBy2 = "";

    pc.setFont(8, 1);
	pc.addCols(" ",0,dHeader.size());
	pc.addBorderCols(" ESPECIALIDADES MÉDICAS",0,dHeader.size(),Color.lightGray);
	
if (!fg.trim().equals("DE"))	
  { //if fg	 
  
	for (int i=0; i<al3.size(); i++)
	{//for i		
      	 CommonDataObject cdo3 = (CommonDataObject) al3.get(i);		  
	   
		 // Inicio --- Agrupamiento x Especialidad - Ubicación
		 if (!groupBy.equalsIgnoreCase("[ "+cdo3.getColValue("abrevEspecialidad")+" ] ") 
		 && (!groupBy2.equalsIgnoreCase("[ "+cdo3.getColValue("ubicacion")+" ] ")))
		   {// groupBy		    			
			  if (i != 0)
		       {// i			 
			     pc.setFont(8, 1,Color.blue);
				 pc.addCols("  TOTAL DE PAC. X UBICACIÓN: ",2,2,cHeight);
				 pc.addCols("  "+pxu,1,2,cHeight);
				 pc.setFont(8, 1,Color.blue);									
				 pc.addCols("  TOTAL DE PAC. X ESPECIALIDAD: ",2,2,cHeight);					   	
				 pc.addCols("  "+pxe,1,2,cHeight);					   	
				 pc.addCols(" ",0,dHeader.size(),cHeight);  
				 pxu = 0;	 
				 pxe = 0;				
			   }// i
			  			  		  
			   pc.setFont(8, 1,Color.blue); 
			   pc.addCols("ESPECIALIDAD:",0,1,cHeight);
		       pc.addCols("[ "+cdo3.getColValue("abrevEspecialidad")+" ] "+cdo3.getColValue("descEspecialidad"),0,dHeader.size());			
			   pc.addCols("UBICACIÓN:",0,1,cHeight);
		       pc.addCols("[ "+cdo3.getColValue("ubicacion")+" ] "+cdo3.getColValue("descUbicacion"),0,dHeader.size());			
	       }// groupBy
		   // Fin --- Agrupamiento x Especialidad - Ubicación
			
		   else // Inicio --- Agrupamiento x Ubicación
	         if (groupBy.equalsIgnoreCase("[ "+cdo3.getColValue("abrevEspecialidad")+" ] ") 
	       && (!groupBy2.equalsIgnoreCase("[ "+cdo3.getColValue("ubicacion")+" ] ")))
		    {// groupBy 
			
			   if ( i!= 0)  
			    {// i			   
				  pc.setFont(8, 1,Color.blue);
				  pc.addCols("  TOTAL DE PAC. X UBICACIÓN: ",2,2,cHeight);	 			 
				  pc.addCols(" "+pxu,1,2,cHeight);	 			 
				  pc.addCols(" ",0,dHeader.size(),cHeight);				
				  pxu = 0;					 
			     }// i	
							  
			   pc.addCols("UBICACIÓN:",0,1,cHeight);
		       pc.addCols("[ "+cdo3.getColValue("ubicacion")+" ] "+cdo3.getColValue("descUbicacion"),0,dHeader.size());			  
			 }// groupBy 
			 // Fin --- Agrupamiento x Ubicación 		  
				 
		    pc.setFont(7, 2);		
			pc.addCols(" "+cdo3.getColValue("nomMedico"),0,2,cHeight);
			pc.setFont(8, 2);
			pc.addCols(" "+cdo3.getColValue("cantPacientes"),1,2,cHeight);		
			
	    pxe += Integer.parseInt(cdo3.getColValue("cantPacientes"));
		pxu += Integer.parseInt(cdo3.getColValue("cantPacientes"));
			
		groupBy  = "[ "+cdo3.getColValue("abrevEspecialidad")+" ] ";
		groupBy2 = "[ "+cdo3.getColValue("ubicacion")+" ] ";
		
		totFinal += Integer.parseInt(cdo3.getColValue("cantPacientes"));
		 
	}//for i
		
	    pc.setFont(8, 1,Color.blue);
        pc.addCols("  TOTAL DE PAC. X UBICACIÓN: ",2,2,cHeight);
		pc.addCols(" "+pxu,1,2,cHeight);
		pc.addCols("  TOTAL DE PAC. X ESPECIALIDAD: ",2,2,cHeight);					   	
		pc.addCols(" "+pxe,1,2,cHeight);					
		pc.setFont(8, 1,Color.black);			
		pc.addCols(" GRAN TOTAL DE PACIENTES: ",2,2,cHeight);	  
		pc.addCols(" "+totFinal,1,2,cHeight);	
							
}else{ //preeliminar (borrador)

 for (int i=0; i<al3.size(); i++)
	{//for i		
      	 CommonDataObject cdo3 = (CommonDataObject) al3.get(i);
	   
		 // Inicio --- Agrupamiento x Especialidad - Ubicación
		 if (!groupBy.equalsIgnoreCase("[ "+cdo3.getColValue("abrevEspecialidad")+" ] "))
		   {// groupBy		 
		      			
			  if (i != 0)
		       {// i					  
				 pc.setFont(8, 1,Color.blue);
				 pc.addCols(" ",0,1,cHeight);									
				 pc.addCols(" TOTAL DE PAC. X ESPECIALIDAD:                             "+pxe,0,3,cHeight);			   	
				 //pc.addCols("  "+pxe,2,2,cHeight);					   	
				 pc.addCols(" ",0,dHeader.size(),cHeight);  
				// pxu = 0;	 
				 pxe = 0;				
			   }// i
			  			  		  
			   pc.setFont(8, 1,Color.blue); 
			   pc.addCols("ESPECIALIDAD:",0,1,cHeight);
		       pc.addCols("[ "+cdo3.getColValue("abrevEspecialidad")+" ] "+cdo3.getColValue("descEspecialidad"),0,dHeader.size());						   	       }// groupBy
		   // Fin --- Agrupamiento x Especialidad - Ubicación
			
		   else // Inicio --- Agrupamiento x Ubicación
	         if (groupBy.equalsIgnoreCase("[ "+cdo3.getColValue("abrevEspecialidad")+" ] "))	     
		    {// groupBy 
			
			   if ( i!= 0)  
			    {// i			   
				  pc.setFont(8, 1,Color.blue);				 
				  pxu = 0;					 
			     }// i					  
			 }// groupBy 
			 // Fin --- Agrupamiento x Ubicación 		  
				 
		    pc.setFont(7, 2);		
			pc.addCols(" "+cdo3.getColValue("nomMedico"),0,1,cHeight);
			pc.setFont(8, 2);
			pc.addCols(" "+cdo3.getColValue("cantPacientes"),2,1,cHeight);	
			pc.setFont(8, 2);		
			pc.addCols("   "+cdo3.getColValue("descUbicacion"),0,2,cHeight);	
			
	    pxe += Integer.parseInt(cdo3.getColValue("cantPacientes"));
		//pxu += Integer.parseInt(cdo3.getColValue("cantPacientes"));
			
		groupBy  = "[ "+cdo3.getColValue("abrevEspecialidad")+" ] ";		
		totFinal += Integer.parseInt(cdo3.getColValue("cantPacientes"));
		 
	}//for i
		
	    pc.setFont(8, 1,Color.blue);       
		pc.addCols(" ",0,1,cHeight);
		pc.addCols(" TOTAL DE PAC. X ESPECIALIDAD:                           "+pxe,0,3,cHeight);			   			   	
		//pc.addCols("TOTAL DE PAC. X ESPECIALIDAD:",1,1,cHeight);					   	
		//pc.addCols(" "+pxe,0,2,cHeight);					
		pc.setFont(8, 1,Color.black);	
		pc.addCols(" ",0,1,cHeight);		
		pc.addCols(" GRAN TOTAL DE PACIENTES:                                  "+totFinal,0,3,cHeight);	  
		//pc.addCols(" "+totFinal,0,2,cHeight);	
 } //if fg


//-------------------------------------PACIENTES X CATEGORIA DE HABITACIÓN---------------------------------//	
int  totxHab = 0;
String groupBy3 = "";

pc.setFont(8, 1);
pc.addCols(" ",0,dHeader.size());
pc.addBorderCols(" HABITACIONES",0,dHeader.size(),Color.lightGray);

if (!fg.trim().equals("DE"))	
 { //if fg	
    for (int i=0; i<al4.size(); i++)
	 {//for i		
       CommonDataObject cdo4 = (CommonDataObject) al4.get(i);				
					  			  		  
		pc.setFont(7, 2);
		pc.addBorderCols(" "+cdo4.getColValue("descCategoria"),0,2,cHeight);
		pc.setFont(8, 2);
        pc.addBorderCols(" "+cdo4.getColValue("cantPacientes"),1,2,cHeight); 
		
		totxHab += Integer.parseInt(cdo4.getColValue("cantPacientes"));
	  }//for i

	pc.setFont(8, 1);
	pc.addCols(" ",0,2);	  
	pc.addCols(" TOTAL:                                              "+totxHab,0,2);
	
  }else{ //preeliminar (borrador)
    for (int i=0; i<al4.size(); i++)
	 {//for i		
       CommonDataObject cdo4 = (CommonDataObject) al4.get(i);				
					  			  		  
		pc.setFont(7, 2);
		pc.addBorderCols(" "+cdo4.getColValue("descCategoria"),0,2,cHeight);
		pc.setFont(8, 2);
        pc.addBorderCols(" "+cdo4.getColValue("cantPacientes"),1,2,cHeight); 
		
		totxHab += Integer.parseInt(cdo4.getColValue("cantPacientes"));
	  }//for i

	pc.setFont(8, 1);
	pc.addCols(" ",0,2);	  
	pc.addCols(" TOTAL:                                           "+totxHab,0,2);
   } //if fg	     
	
//-------------------------------------------PACIENTES X MÉDICOS------------------------------------------//
    int totxMed = 0;		
	pc.setFont(8, 1);
	pc.addCols(" ",0,dHeader.size());
	pc.addBorderCols(" MÉDICOS DE LOS NEONATOS",1,4);
	pc.addBorderCols(" CÓDIGO",1,1,Color.lightGray);
	pc.addBorderCols(" NOMBRE DEL MÉDICO",1,1,Color.lightGray);
	pc.addBorderCols(" CASOS",1,1,Color.lightGray);
	pc.addBorderCols(" ESPECIALIDAD",1,1,Color.lightGray);
	
	for (int i=0; i<al5.size(); i++)
	{
	    CommonDataObject cdo5 = (CommonDataObject) al5.get(i);
		
	    pc.setFont(7, 2);
		pc.addBorderCols(" "+cdo5.getColValue("medico"),0,1,cHeight);
		pc.addBorderCols(" "+cdo5.getColValue("nomMedico"),0,1,cHeight);	        
		pc.setFont(8, 2);
		pc.addBorderCols(" "+cdo5.getColValue("casos"),1,1,cHeight);
		pc.setFont(7, 2);
		pc.addBorderCols(" "+cdo5.getColValue("especialidad"),0,1,cHeight);
		
		totxMed += Integer.parseInt(cdo5.getColValue("casos"));	
	}//for i
	
	pc.setFont(8, 1);
	pc.addCols(" ",0,1);	  
	pc.addCols("                                                           TOTAL DE CASOS:          "+totxMed,0,3);	  
    pc.addCols(" ",0,dHeader.size());	
	
	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales	
        pc.setFont(8, 1,Color.black); 			
		pc.addCols(" ",0,dHeader.size());	  
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>





