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
<!-- Desarrollado por: Jos� A. Acevedo C.         -->
<!-- Reporte: "Listado de Pacientes Hospitalizados x Secci�n"  -->
<!-- Total de Habitaciones (Privada/Semi-Privada) -->
<!-- Reporte: ADM3035                             -->
<!-- Cl�nica Hospital San Fernando                -->
<!-- Fecha: 09/03/2010                            -->    

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); 

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String userName = UserDet.getUserName();  
String habitacion = request.getParameter("habitacion") == null ? "" : request.getParameter("habitacion");
String sala = request.getParameter("sala") == null ? "" : request.getParameter("sala");
String aseguradora = request.getParameter("aseguradora") == null ? "" : request.getParameter("aseguradora");
String cdsAdm = request.getParameter("cdsAdm");
String cdsAdmDesc = request.getParameter("cdsAdmDesc");
String compania = (String) session.getAttribute("_companyId");

if (cdsAdm == null) cdsAdm = "";
if (cdsAdmDesc == null) cdsAdmDesc = "";

sbFilter.append(" and a.compania = ");
sbFilter.append(compania); 

if (!habitacion.trim().equals("")) { sbFilter.append(" and cama.habitacion = '"); sbFilter.append(habitacion); sbFilter.append("'"); }
if (!sala.trim().equals("")) { sbFilter.append(" and salh.unidad_admin = "); sbFilter.append(sala); }
if (!aseguradora.trim().equals("")) { sbFilter.append(" and ae.codigo = "); sbFilter.append(aseguradora); }
if (!cdsAdm.trim().equals("")) { sbFilter.append(" and a.centro_servicio = "); sbFilter.append(cdsAdm); }

sbSql.append("select salh.unidad_admin as codSala, cds.descripcion as descSala, decode(saltipoh.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','E','ECONOMICA','T','SUITE','Q','QUIROFANO','O','OTRO','R','RECOBRO') categoriaHabit, decode(p.apellido_de_casada,null,p.primer_apellido,p.apellido_de_casada)||' '||p.primer_nombre as nombrePaciente, (to_char(a.fecha_nacimiento,'dd-mm-yyyy')||' ('||a.codigo_paciente||' - '||a.secuencia||')') as codigoPaciente, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as cod_pac, a.secuencia as noAdmision, p.pac_id, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, ae.codigo as codAseguradora, decode(ae.nombre,null,decode(a.tipo_cta,'P','PARTICULAR','A','ASEGURADO','M','MEDICO','E','EMPLEADO','J','JUBILADO'),ae.nombre) descAseguradora, decode(p.vip,'S','VIP','F','FREC','N') as vip, cama.habitacion as habitacion, saltipoh.precio as precio, decode(med.apellido_de_casada,null,med.primer_apellido,med.apellido_de_casada)||' '||med.primer_nombre as medico from tbl_adm_admision a, tbl_adm_paciente p, tbl_adm_medico med, tbl_adm_beneficios_x_admision aba, tbl_adm_empresa ae, tbl_cds_centro_servicio cds, tbl_adm_cama_admision cama, tbl_sal_cama salc, tbl_sal_habitacion salh, tbl_sal_tipo_habitacion saltipoh where (a.fecha_nacimiento = p.fecha_nacimiento and a.codigo_paciente = p.codigo) and (a.compania = cama.compania(+) and a.pac_id = cama.pac_id(+) and a.secuencia = cama.admision(+) and cama.fecha_final(+) is null) and a.estado = 'A' and a.categoria in (1,5) and (cama.compania = salc.compania and cama.habitacion = salc.habitacion and cama.cama = salc.codigo and salc.estado_cama = 'U') and (salc.compania = salh.compania and salc.habitacion = salh.codigo) and (salc.compania = saltipoh.compania and salc.tipo_hab = saltipoh.codigo) and (a.pac_id = aba.pac_id(+) and a.secuencia = aba.admision(+) and nvl(aba.estado(+),'A') = 'A' and aba.prioridad(+) = 1 and aba.empresa = ae.codigo(+)) and (a.medico = med.codigo) and (cds.codigo = salh.unidad_admin) ");
sbSql.append(sbFilter);
sbSql.append(" order by 2,1,3,14,9,7,6 ");
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
	String subtitle = "PACIENTES HOSPITALIZADO POR SECCI�N  "; 
	String xtraSubtitle = "TOTALES POR HABITACIONES AL: "+fecha;  
	//if (!cdsAdmDesc.trim().equals("")) xtraSubtitle += "\nADMITIDO POR (CDS): "+cdsAdmDesc;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;	
	
	Vector dHeader = new Vector();		
		dHeader.addElement(".20"); //
		dHeader.addElement(".07");
		dHeader.addElement(".23");
		dHeader.addElement(".13");		
		dHeader.addElement(".06");				
		dHeader.addElement(".16");
		dHeader.addElement(".07");		
		dHeader.addElement(".08");
		
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);  	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);		
		pc.addBorderCols("NOMBRE PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("PID-ADMISION ",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("ASEGURADORA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CODIGO PACIENTE",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("HAB.",1,1,cHeight * 2,Color.lightGray);				
		pc.addBorderCols("MEDICO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("PRECIO",1,1,cHeight * 2,Color.lightGray);				
		pc.addBorderCols("F. INGRESO",1,1,cHeight * 2,Color.lightGray);    
				
	pc.setTableHeader(2);
	
	String groupBy = "", groupBy2 = "";
	int varPrecio = 0, varPrecioxhab = 0, varPrecioxsala = 0, vartotPrecio = 0;
	int pxs = 0, pxcath = 0;
	for (int i=0; i<al.size(); i++)
	{			
      cdo = (CommonDataObject) al.get(i);	
	  
	    varPrecio = Integer.parseInt(cdo.getColValue("precio")); 

	    //Inicio --- Agrupamiento por Sala/Secci�n
      if(!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala")))
	    {
		  if (i != 0)  
		   {//i-1
		     pc.setFont(8, 1,Color.red);
			 pc.addCols(" ",0,dHeader.size(),cHeight);
			 pc.addCols("PACIENTES X HABITACI�N:                     "+pxcath+"                                                                                                TOTAL X HABITACI�N:                   "+"$"+CmnMgr.getFormattedDecimal(varPrecioxhab),0,dHeader.size(),cHeight);	 			 
			 pc.addCols("TOTAL DE PACTS. X SALA O SECCI�N: "+ pxs+"                                                                                                TOTAL DE HABITACION X SALA:   "+"$"+CmnMgr.getFormattedDecimal(varPrecioxsala),0,dHeader.size(),cHeight);
			 pc.addCols(" ",0,dHeader.size(),cHeight);			
			 pxcath = 0;
			 pxs    = 0;
			 varPrecioxhab  = 0;	
			 varPrecioxsala = 0;
		   }//i-1		  		
		   pc.setFont(8, 1,Color.blue);  
		   pc.addCols("SALA:",0,1,cHeight);
		   pc.addCols("[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala"),0,dHeader.size(),cHeight);	
		   pc.addCols("HABITACI�N:",0,1,cHeight);
		   pc.addCols(cdo.getColValue("categoriaHabit"),0,dHeader.size(),cHeight);  	   
		}//Fin --- Agrupamiento por Sala/Secci�n

        //Inicio --- Agrupamiento por Habitaci�n		
      else if(!groupBy2.equalsIgnoreCase(cdo.getColValue("categoriaHabit")))
	    {
		  if (i != 0)  
		   {//i-1		   	
		     pc.setFont(8, 1,Color.red);
			 pc.addCols("PACIENTES X HABITACI�N:                     "+pxcath+"                                                                                                TOTAL X HABITACI�N:                   "+"$"+CmnMgr.getFormattedDecimal(varPrecioxhab),0,dHeader.size(),cHeight);	 			 
			 pc.addCols(" ",0,dHeader.size(),cHeight);				
			 pxcath        = 0;			
			 varPrecioxhab = 0;			 
		   }//i-1		  		
		   pc.setFont(8, 1,Color.blue);  
		   pc.addCols("HABITACI�N:",0,1,cHeight);
		   pc.addCols(cdo.getColValue("categoriaHabit"),0,dHeader.size(),cHeight);		   
		 }//Fin --- Agrupamiento por Habitaci�n
		  
		pc.setFont(7, 0);		
		pc.addCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);  
		pc.addCols(cdo.getColValue("pac_id")+"-"+(cdo.getColValue("noAdmision")),0,1);
		pc.addCols(" "+cdo.getColValue("descAseguradora"),0,1,cHeight);  
		pc.addCols(" "+cdo.getColValue("codigoPaciente"),0,1,cHeight);
		pc.addCols(" "+cdo.getColValue("habitacion"),1,1,cHeight);		
		pc.addCols(" "+cdo.getColValue("medico"),0,1,cHeight);		
		pc.addCols(" "+"$"+CmnMgr.getFormattedDecimal(varPrecio),2,1,cHeight);  	 	
		pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);    
		pxs++;
		pxcath++;
		
	     groupBy  = "[ "+cdo.getColValue("codSala")+" ] "+cdo.getColValue("descSala");
	     groupBy2 = cdo.getColValue("categoriaHabit");
	     varPrecioxhab  = varPrecioxhab  + varPrecio;	
	     varPrecioxsala = varPrecioxsala + varPrecio; 
	     vartotPrecio   = vartotPrecio   + varPrecio;  
	  }//for i

	if (al.size() == 0)  
	{		
	   pc.addCols("No existen registros",1,dHeader.size());	         	
	}
	else   
	{//Totales Finales
	  pc.setFont(8, 1, Color.red);
  	  pc.addCols(" ",0,dHeader.size(),cHeight);
	  pc.addCols("PACIENTES X HABITACI�N:                     "+pxcath+"                                                                                                TOTAL X HABITACI�N:                   "+"$"+CmnMgr.getFormattedDecimal(varPrecioxhab),0,dHeader.size(),cHeight);	 			 
			 pc.addCols("TOTAL DE PACTS. X SALA O SECCI�N: "+ pxs+"                                                                                             TOTAL DE HABITACION X SALA:   "+"$"+CmnMgr.getFormattedDecimal(varPrecioxsala),0,dHeader.size(),cHeight);
	  pc.setFont(8, 1,Color.black);  
	  pc.addCols(" ",0,dHeader.size(),cHeight);
pc.addCols(" GRAN TOTAL DE PACIENTES:   "+ al.size()+"                                                                                                            GRAN TOTAL DE HABITACION:   "+ CmnMgr.getFormattedDecimal(vartotPrecio),0,dHeader.size(),Color.lightGray);	  
	}    
	 pc.addTable();  
	 pc.close();    
	response.sendRedirect(redirectFile);   
}//get
%>

