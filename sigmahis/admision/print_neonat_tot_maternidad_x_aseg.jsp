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
<!-- Desarrollado por: José A. Acevedo C.                        -->
<!-- Reporte: "Total de Pacientes (MATERNIDAD) por Aseguradora"  -->
<!-- Reporte: ADM70022_TOTAL                                     -->
<!-- Clínica Hospital San Fernando                               -->
<!-- Fecha: 30/06/2010                                           -->

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
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName(); 
String compania = (String) session.getAttribute("_companyId");

String aseguradora = request.getParameter("aseguradora");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (aseguradora == null) aseguradora = "";
if (fechaini    == null) fechaini  = "";
if (fechafin    == null) fechafin  = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and aa.compania = "+compania;  
  }
  
if (!aseguradora.equals(""))
{
  appendFilter1 += " and ab.empresa = "+aseguradora;
}

if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(aa.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
   
if (!fechafin.equals(""))
   {
appendFilter1 += " and to_date(to_char(aa.fecha_ingreso, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener "Listado de Totales (MATERNIDAD) por Aseguradora---------------------//
sql = 
" select aa.fecha_nacimiento, aa.codigo_paciente, aa.secuencia, aa.pac_id, "
+" (to_char(aa.fecha_nacimiento,'dd-mm-yyyy')||'('||aa.codigo_paciente||' - '||aa.secuencia||')') as codigoPaciente, "
+" ap.primer_nombre||decode(ap.segundo_nombre,null,'',' '||ap.segundo_nombre)||decode(ap.primer_apellido,null,'',' '||ap.primer_apellido)||decode(ap.segundo_apellido,null,'',' '||ap.segundo_apellido)||decode(ap.sexo,'F',decode(ap.apellido_de_casada,null,'',' '||ap.apellido_de_casada)) as nombrePaciente, "
+" coalesce(ap.pasaporte,ap.provincia||'-'||ap.sigla||'-'||ap.tomo||'-'||ap.asiento)||'-'||ap.d_cedula as cedula, "
+" to_char(aa.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso, to_char(aa.fecha_egreso,'dd/mm/yyyy') as fechaEgreso, "
+" aa.centro_servicio codCentro, cds.descripcion descCentro, "
+" ab.empresa as codAseguradora, emp.nombre as descAseguradora, "
+" ad.diagnostico, decode(d.observacion,null,d.nombre,d.observacion) as descDiagnostico "
+" from  tbl_adm_admision aa, tbl_adm_paciente ap, tbl_adm_beneficios_x_admision ab, "
+" tbl_adm_diagnostico_x_admision ad, tbl_adm_empresa emp, tbl_cds_centro_servicio cds, tbl_cds_diagnostico d "
+" where "
+" (aa.pac_id = ap.pac_id) and (aa.pac_id = ab.pac_id(+) and aa.secuencia  = ab.admision(+)      and "
+" ab.prioridad(+) = 1 and nvl(ab.estado(+),'A') = 'A' and ab.empresa = emp.codigo(+))           and "
+" (aa.pac_id = ad.pac_id(+) and aa.secuencia = ad.admision(+) and d.codigo(+) = ad.diagnostico) and "
+" (aa.centro_servicio = cds.codigo) and aa.categoria in (1,5) and aa.tipo_admision = 3 and aa.fnac_madre is null "
+" and aa.cpac_madre is null and aa.admi_madre is null "+appendFilter1
+" group by  aa.fecha_nacimiento, aa.codigo_paciente, aa.secuencia, aa.pac_id, "
+" (to_char(aa.fecha_nacimiento,'dd-mm-yyyy')||'('||aa.codigo_paciente||' - '||aa.secuencia||')'), "
+" ap.primer_nombre||decode(ap.segundo_nombre,null,'',' '||ap.segundo_nombre)||decode(ap.primer_apellido,null,'',' '||ap.primer_apellido)||decode(ap.segundo_apellido,null,'',' '||ap.segundo_apellido)||decode(ap.sexo,'F',decode(ap.apellido_de_casada,null,'',' '||ap.apellido_de_casada)), "
+" coalesce(ap.pasaporte,ap.provincia||'-'||ap.sigla||'-'||ap.tomo||'-'||ap.asiento)||'-'||ap.d_cedula, "
+" to_char(aa.fecha_ingreso,'dd/mm/yyyy'), to_char(aa.fecha_egreso,'dd/mm/yyyy'), "
+" aa.centro_servicio, cds.descripcion, ab.empresa, emp.nombre, "
+" ad.diagnostico, decode(d.observacion,null,d.nombre,d.observacion) "
+" order by  11,10,12,13, 5";

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
	float height = 72 * 11f;//792
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
	String subtitle = "TOTAL DE PACIENTES (MATERNIDAD) POR ASEGURADORA";
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
		
		dHeader.addElement(".10");
		dHeader.addElement(".24");
		dHeader.addElement(".10");
		dHeader.addElement(".11");
		dHeader.addElement(".11");
		dHeader.addElement(".34");			

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pc.setFont(7, 1);		
		pc.addBorderCols("CÓDIGO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("NOMBRE DEL PACIENTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("CÉDULA",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA INGRESO",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("FECHA EGRESO",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("DIAGNÓSTICO",1,1,cHeight * 2,Color.lightGray);		
		
	pc.setTableHeader(2);
	
	int    pxa = 0, pxc = 0;		
	String groupBy  = "", groupBy2 = "";	
	
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);					
		
		 // Inicio --- Agrupamiento x Centro		 
		 if (!groupBy2.equalsIgnoreCase("[ "+cdo.getColValue("codCentro")+" ] "+cdo.getColValue("descCentro"))) 
		   { // groupBy
			   if (i != 0)
			      {// i - 3				  
				    pc.setFont(8, 1,Color.red);
				    pc.addCols("                     TOTAL DE PACIENTES X AREA:                   "+ pxc,0,dHeader.size(),cHeight);		
					pc.addCols(" ",0,dHeader.size(),cHeight);	
					pxc   = 0;						
	               }// i - 3		 
		       
			pc.setFont(8, 1,Color.blue);
			pc.addCols("ASEG:",0,1,cHeight);
			pc.addCols("[ "+cdo.getColValue("codAseguradora")+" ] "+cdo.getColValue("descAseguradora"),0,dHeader.size(),cHeight);
			pc.addCols("AREA:",0,1,cHeight);
			pc.addCols("[ "+cdo.getColValue("codCentro")+" ] "+cdo.getColValue("descCentro"),0,dHeader.size(),cHeight); 					
		  }// groupBy	
	// Fin --- Agrupamiento x Centro			 
		 
		    pc.setFont(7, 0);		
   			pc.addCols(" "+cdo.getColValue("codigoPaciente"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("nombrePaciente"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("cedula"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fechaIngreso"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fechaEgreso"),1,1);
			pc.addCols(" "+cdo.getColValue("descDiagnostico"),0,1,cHeight);			
			pxc++;
		
		groupBy2 = "[ "+cdo.getColValue("codCentro")+" ] "+cdo.getColValue("descCentro");
		 
	}//for i

	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales	
	    pc.setFont(8, 1,Color.red);
		pc.addCols("                     TOTAL DE PACIENTES X AREA:                   "+ pxc,0,dHeader.size(),cHeight);				
		pc.setFont(8, 1,Color.black);			
		pc.addCols(" GRAN TOTAL:   "+ al.size(),0,dHeader.size(),Color.lightGray);	 			
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>





