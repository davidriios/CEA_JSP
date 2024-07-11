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
<!-- Desarrollado por: José A. Acevedo C.          -->
<!-- Reporte: " Encuesta (MATERNIDAD) "            -->
<!-- Reporte: ADM70022                             -->
<!-- Clínica Hospital San Fernando                 -->
<!-- Fecha: 29/06/2010                             -->

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

String evento    = request.getParameter("evento");
String encuesta  = request.getParameter("encuesta");
String fechaini  = request.getParameter("fechaini");
String fechafin  = request.getParameter("fechafin");

if (evento == null)   evento    = "";
if (encuesta == null) encuesta  = "";
if (fechaini == null) fechaini  = "";
if (fechafin == null) fechafin  = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//--------------Parámetros--------------------//
if (!compania.equals(""))
  {
   appendFilter1 += " and enc.compania = "+compania;  
  }

if (!evento.equals(""))
{
 appendFilter1 +=" and enc.tipo_evento = "+evento;
}

if(!encuesta.equals(""))
{
 appendFilter1 +=" and enc.tipo_encuesta= "+encuesta;
}

if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(enc.fecha_en1, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
if (!fechafin.equals(""))
   {
 appendFilter1 += " and to_date(to_char(enc.fecha_en2, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   
   }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener "Listado de Encuestas de Maternidad----------------------------------//
sql = 
" select enc.primer_nombre||' '||enc.segundo_nombre||' '||decode(enc.apellido_casada,null,enc.primer_apellido||' '||enc.segundo_apellido,enc.apellido_casada) nombreParticipante, "
+" enc.e_mail email, enc.telefono_residencial telfResidencial, enc.telefono_celular celular, "
+" enc.meses_gestacion mesesGestacion, enc.fecha_nacimiento fechaNacimiento, "
+" enc.hospital_parto hospitalParto, enc.ginecologo ginecologo, "
+" enc.pediatra pediatra, enc.interesada interesadaCurso, "
+" enc.tipo_evento evento, ev.descripcion descEvento, enc.tipo_encuesta encuesta, tipo.descrip_encuesta descEncuesta "
+" from tbl_adm_encuesta enc, tbl_adm_eventos ev, tbl_adm_tipo_encuesta tipo "
+" where enc.tipo_evento = ev.codigo and enc.tipo_encuesta = tipo.codigo_encuesta "+appendFilter1
+"order by enc.tipo_evento, ev.descripcion, enc.tipo_encuesta, tipo.descrip_encuesta, 1";

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
	String subtitle = "ENCUESTA";
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
		
		dHeader.addElement(".13");
		dHeader.addElement(".12");
		dHeader.addElement(".05");		
		dHeader.addElement(".05");   
		dHeader.addElement(".10");
		dHeader.addElement(".06");
		dHeader.addElement(".17");		
		dHeader.addElement(".12");		
		dHeader.addElement(".12");	
		dHeader.addElement(".08");	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		pc.setFont(7, 1);		
		pc.addBorderCols("NOMBRE DEL PARTICIPANTE",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("EMAIL",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("TELF. RES.",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("TELF. CEL.",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("MESES GESTACIÓN",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("FECHA. NAC.",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("HOSPITAL DONDE DARÁ A LUZ",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("GINECOLOGO",1,1,cHeight * 2,Color.lightGray);						
		pc.addBorderCols("PEDIATRA",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("INTER. EN CURSO",1,1,cHeight * 2,Color.lightGray);		
		
	pc.setTableHeader(2);
	
	int    pxe = 0, pxenc = 0;		
	String groupBy  = "", groupBy2 = "";
	String varEncuesta = "";
	
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);					
		
		// Inicio --- Agrupamiento x Evento	- Encuesta
		if (!groupBy.equalsIgnoreCase("[ "+cdo.getColValue("evento")+" ] "+cdo.getColValue("descEvento")) && 
		   (!groupBy2.equalsIgnoreCase("[ "+cdo.getColValue("encuesta")+" ] "+cdo.getColValue("descEncuesta"))))
		 {// groupBy
		    
			if (i != 0)
		     {// i
			    pc.setFont(8, 1,Color.blue);
				pc.addCols("  TOTAL DE PAC. X ENCUESTA:"+pxenc,0,dHeader.size(),cHeight);
				pc.setFont(8, 1,Color.blue);									
				pc.addCols("  TOTAL DE PAC. X EVENTO: "+ pxe,0,dHeader.size(),cHeight);					   	
				pc.addCols(" ",0,dHeader.size(),cHeight);  
				pxe = 0;	 
				pxenc = 0;
			 }// i
			  
			  pc.setFont(8, 1,Color.blue); 
			  pc.addCols("EVENTO:",0,1,cHeight);
		      pc.addCols("[ "+cdo.getColValue("evento")+" ] "+cdo.getColValue("descEvento"),0,dHeader.size());			
			  pc.addCols("ENCUESTA:",0,1,cHeight);
		      pc.addCols("[ "+cdo.getColValue("encuesta")+" ] "+cdo.getColValue("descEncuesta"),0,dHeader.size());			
			
	     }// groupBy
		// Fin --- Agrupamiento x Evento - Encuesta 
		
		else // Inicio --- Agrupamiento x Encuesta
		  if  (groupBy.equalsIgnoreCase("[ "+cdo.getColValue("evento")+" ] "+cdo.getColValue("descEvento")) &&
		      (!groupBy2.equalsIgnoreCase("[ "+cdo.getColValue("encuesta")+" ] "+cdo.getColValue("descEncuesta"))))
		    {// groupBy
			  if ( i != 0 )  
			   {// i
				 pc.setFont(8, 1,Color.blue);
				 pc.addCols("PACIENTES X ENCUESTA:"+pxenc,0,dHeader.size(),cHeight);	 			 
				 pc.addCols(" ",0,dHeader.size(),cHeight);				
				 pxenc = 0;	
			    }// i							
			  pc.addCols("ENCUESTA:",0,1,cHeight);
		      pc.addCols("[ "+cdo.getColValue("encuesta")+" ] "+cdo.getColValue("descEncuesta"),0,dHeader.size());		
			}// groupBy 
			// Fin --- Agrupamiento x Encuesta 		  
		 
		    pc.setFont(7, 0);		
			pc.addCols(" "+cdo.getColValue("nombreParticipante"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("email"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("telfResidencial"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("celular"),0,1);
			pc.addCols(" "+cdo.getColValue("mesesGestacion"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fechaNacimiento"),1,1,cHeight);
			pc.addCols(" "+cdo.getColValue("hospitalParto"),1,1);			
			pc.addCols(" "+cdo.getColValue("ginecologo"),0,1,cHeight); 
			pc.addCols(" "+cdo.getColValue("pediatra"),0,1,cHeight); 
			pc.addCols(" "+cdo.getColValue("interesadaCurso"),1,1,cHeight); 
			pxe++;
			pxenc++;
			
		groupBy  = "[ "+cdo.getColValue("evento")+" ] "+cdo.getColValue("descEvento");
		groupBy2 = "[ "+cdo.getColValue("encuesta")+" ] "+cdo.getColValue("descEncuesta");
		 
	}//for i

	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales	
	    pc.setFont(8, 1,Color.blue);
		pc.addCols(" TOTAL DE PAC. X ENCUESTA:  "+ pxenc,0,dHeader.size(),cHeight);				
		pc.addCols(" TOTAL DE PAC. X EVENTO:       "+ pxe,0,dHeader.size(),cHeight);				
		pc.setFont(8, 1,Color.black);			
		pc.addCols(" GRAN TOTAL DE PACIENTES:   "+ al.size(),0,dHeader.size(),Color.lightGray);	  
		//pc.addCols(dHeader.size()+" Registros en total",0,cHeight); 		
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>




