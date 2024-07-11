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
<!-- Reporte: " Estadística de Neonatología (MATERNIDAD) "  -->
<!-- Reporte: SAL800172                            -->
<!-- Clínica Hospital San Fernando                 -->
<!-- Fecha: 06/07/2010                             -->

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
/*if (!compania.equals(""))
  {
   appendFilter1 += " and enc.compania = "+compania;  
  }
*/
if (!fechaini.equals(""))
   {
  appendFilter1 += " and to_date(to_char(neo.fecha_nacimiento, 'dd/mm/yyyy'), 'dd/mm/yyyy') >= to_date('"+fechaini+"', 'dd/mm/yyyy')";	
   }
if (!fechafin.equals(""))
   {
 appendFilter1 += " and to_date(to_char(neo.fecha_nacimiento, 'dd/mm/yyyy'), 'dd/mm/yyyy') <= to_date('"+fechafin+"', 'dd/mm/yyyy')" ;   
   }
  
//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener "Estadísticas de Neonatología (Maternidad)---------------------------//
sql = 
" select  neo.nombre_madre nombreMadre, neo.ginecologo codGinecologo, med.primer_nombre||' '||med.primer_apellido ginecologo, neo.diagnostico_mama diagMadre, neo.fiebre fiebre, neo.g, neo.p, neo.c, neo.a, decode(neo.tipo_parto, 'C','Cesarea','P','Parto') tipoParto, upper(neo.presentacion) presentacion, upper(decode(neo.liquido_amniotico, 'CL','Claro','MF','Meconial Fluido','ME','Meconial Espeso','SG','Sanguinolento')) liqAmniotico, ae.codigo codAseguradora, ae.nombre benefAseguradora, neo.medicamentos medicamentos, neo.semanas_gestacion semGestacion, decode(neo.vivo_sano, 'V','Vivo y Sano','F','Vivo y Falleció','B','Vivo y en Observación','R','Se reanimó','O','Obito') v, neo.apgar1||'/'||neo.apgar5 apgar, to_char(neo.fecha_nacimiento,'dd/mm/yyyy') fechaNac, to_char(neo.hora_nacimiento,'HH12:MI AM') horaNac, neo.sexo sexo, neo.peso_lb pesoLb, neo.peso_onz pesoOz, neo.diagnostico_bb diagBB, neo.fecha_crea, neo.nombre_bb, neo.pediatra from tbl_adm_neonato neo, tbl_adm_admision aa, tbl_adm_beneficios_x_admision ab, tbl_adm_empresa ae, tbl_adm_medico med where (aa.fecha_nacimiento = neo.fnac_madre and aa.codigo_paciente = neo.codpac_madre and aa.secuencia = neo.admsec_madre and aa.categoria IN (1, 5)) and (ab.fecha_nacimiento = aa.fecha_nacimiento and ab.paciente = aa.codigo_paciente and ab.admision = aa.secuencia and ab.prioridad = 1 and nvl (ab.estado, 'A') = 'A' and ab.empresa = ae.codigo) and (neo.ginecologo = med.codigo) "+appendFilter1+" order by neo.fecha_nacimiento, neo.nombre_madre ";

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
	String title = "ADMISIÓN";
	String subtitle = "ESTADÍSTICAS DE NEONATOLOGÍA";
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
		
		dHeader.addElement(".08");
		dHeader.addElement(".08");		
		dHeader.addElement(".07");				
		dHeader.addElement(".02");   
		dHeader.addElement(".01");
		dHeader.addElement(".01");
		dHeader.addElement(".01");		
		dHeader.addElement(".01");				
		dHeader.addElement(".04");	
		dHeader.addElement(".05");	
		dHeader.addElement(".05");		
		dHeader.addElement(".09");
		dHeader.addElement(".11");				
		dHeader.addElement(".04");   
		dHeader.addElement(".05");
		dHeader.addElement(".04");		
		dHeader.addElement(".04");		
		dHeader.addElement(".04");				
		dHeader.addElement(".03");			
		dHeader.addElement(".03");	
		dHeader.addElement(".03");			
		dHeader.addElement(".08");	

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	    pc.setFont(8, 1);
    	pc.addBorderCols("D A T O S   D E   L A   M A D R E",1,9,cHeight);
    	pc.addBorderCols("D A T O S   D E L   N E O N A T O",1,13,cHeight);			
		pc.setFont(7, 1);		
		pc.addBorderCols("NOMBRE",0,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("GINECÓLOGO",0,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("DIAGNÓSTICO",0,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("FIEBRE",1,1,cHeight * 2,Color.lightGray);			
		pc.addBorderCols("G",1,1,cHeight * 2,Color.lightGray);
		pc.addBorderCols("P",1,1,cHeight * 2,Color.lightGray);	
		pc.addBorderCols("C",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("A",1,1,cHeight * 2,Color.lightGray);						
		pc.addBorderCols("T. PARTO",0,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("PRESENT.",0,1,cHeight * 2,Color.lightGray);				
		pc.addBorderCols("LÍQ. AMNIÓTICO",0,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("BENEFICIOS",0,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("MEDICAMENTOS",0,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("S. GEST.",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("NACIÓ?",0,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("APGAR 1/5",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("FECHA NAC.",1,1,cHeight * 2,Color.lightGray);		
    	pc.addBorderCols("HORA NAC.",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("SEXO",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("PESO Lb",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("PESO Onz",1,1,cHeight * 2,Color.lightGray);		
		pc.addBorderCols("DIAGNÓSTICO",0,1,cHeight * 2,Color.lightGray);		
		
	pc.setTableHeader(2);
	
	int  pxe = 0;	
	int  pxCesarea = 0, pxNatural = 0, pxPO = 0, pxAseg = 0;
	for (int i=0; i<al.size(); i++)
	{		
        cdo = (CommonDataObject) al.get(i);	
		
		
		 if (cdo.getColValue("tipoParto").trim().equals("Cesarea"))
		    {
			 pxCesarea++;
			}else if(cdo.getColValue("tipoParto").trim().equals("Parto"))
			  {
			   pxNatural++;
			  }
			  
		  if (cdo.getColValue("codAseguradora").trim().equals("118"))
		     {
			   pxPO++;
			 }else pxAseg++;
			  
		    pc.setFont(7, 0);		
			pc.addCols(" "+cdo.getColValue("nombreMadre"),0,1);
			pc.addCols(" "+cdo.getColValue("ginecologo"),0,1);
			pc.addCols(" "+cdo.getColValue("diagMadre"),0,1,cHeight);
			pc.addCols(" "+cdo.getColValue("fiebre"),1,1);
			pc.addCols(" "+cdo.getColValue("g"),1,1);
			pc.addCols(" "+cdo.getColValue("p"),1,1);
			pc.addCols(" "+cdo.getColValue("c"),1,1);			
			pc.addCols(" "+cdo.getColValue("a"),1,1); 
			pc.addCols(" "+cdo.getColValue("tipoParto"),0,1); 
			pc.addCols(" "+cdo.getColValue("presentacion"),0,1); 			
			pc.addCols(" "+cdo.getColValue("liqAmniotico"),0,1,cHeight); 
			pc.addCols(" "+cdo.getColValue("benefAseguradora"),0,1,cHeight); 
			pc.addCols(" "+cdo.getColValue("medicamentos"),0,1,cHeight); 
			pc.addCols(" "+cdo.getColValue("semGestacion"),1,1); 
			pc.addCols(" "+cdo.getColValue("v"),0,1); 
			pc.addCols(" "+cdo.getColValue("apgar"),1,1);			
			pc.addCols(" "+cdo.getColValue("fechaNac"),0,1); 
			pc.addCols(" "+cdo.getColValue("horaNac"),0,1); 
			pc.addCols(" "+cdo.getColValue("sexo"),1,1); 
			pc.addCols(" "+cdo.getColValue("pesoLb"),1,1); 
			pc.addCols(" "+cdo.getColValue("pesoOz"),1,1); 
			pc.addCols(" "+cdo.getColValue("diagBB"),0,1,cHeight); 
			pxe++;
		
	}//for i
	
	    pc.addCols(" ",0,dHeader.size());
		pc.addCols(" ",0,dHeader.size());
		pc.setFont(9, 1,Color.blue);
		pc.addCols(" ",0,15);
		pc.addCols("                        TOTAL DE NEONATOS:             "+ al.size(),0,7);
		pc.setFont(8, 1,Color.blue);
		pc.addCols(" ",0,11);
	    pc.addCols("                        RESUMEN TOTALES POR NACIMIENTOS:   ",0,4);  
		pc.addCols("                        RESUMEN TOTALES POR TIPO DE CUENTAS:  ",0,7);	  
		
		pc.setFont(8, 1);
		pc.addCols(" ",0,11);
	    pc.addCols("                        PARTO NATURAL                          "+pxNatural,0,4);
	    pc.addCols("                        PACTES. ASEGURADOS                     "+pxAseg,0,7);
		
		pc.addCols(" ",0,11);
		pc.addCols("                        PARTO POR CESÁREA                 "+pxCesarea,0,4);
	    pc.addCols("                        PACTES. PAQUETE OBSTÉTRICO     "+pxPO,0,7);	

	if (al.size() == 0)
	{		
		pc.addCols("No existen registros",1,dHeader.size());    		
	}
	else 
	{//Totales Finales						
		pc.setFont(8, 1,Color.black);			
		pc.addCols(" ",0,dHeader.size());		  
		//pc.addCols(dHeader.size()+" Registros en total",0,cHeight); 		
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);  
}//get
%>





