<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Pantalla: "Reportes de Licencias"           -->
<!-- Reportes: RH19003                           -->
<!-- Clínica Hospital San Fernando               -->
<!-- Fecha: 26/03/2011                           -->
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
Hashtable _mes = new Hashtable();
CommonDataObject cdo = new CommonDataObject();	

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String mes   = request.getParameter("mes");
String anio   = request.getParameter("anio");
String motivoFalta   = request.getParameter("motivoFalta");

String filter = "", titulo = "", rpt_Titulo = "";
String userName = UserDet.getUserName();
String compania = (String) session.getAttribute("_companyId");

if (!mes.equals("") ){
  _mes.put("01","ENERO");
  _mes.put("02","FEBRERO");
  _mes.put("03","MARZO");
  _mes.put("04","ABRIL");
  _mes.put("05","MAYO");
  _mes.put("06","JUNIO");
  _mes.put("07","JULIO");
  _mes.put("08","AGOSTO");
  _mes.put("09","SEPTIEMBRE");
  _mes.put("10","OCTUBRE");
  _mes.put("11","NOVIEMBRE");
  _mes.put("12","DICIEMBRE");
 }

if (appendFilter == null) appendFilter = "";
if (mes   == null) mes   = "";
if (anio   == null) anio   = "";
if (motivoFalta == null ) motivoFalta = "";

if (motivoFalta.equals("") ) throw new Exception("El Motivo Falta en inválido, Por favor contacte el administrado!");

if ( !mes.equals("") && !anio.equals("") ){
    appendFilter += " and to_char(a.fecha_inicio,'mm/yyyy') >= '"+mes+"/"+anio+"' and to_char(a.fecha_final,'mm/yyyy') <= '"+mes+"/"+anio+"'";
	
	titulo = " CORRESPONDIENTE AL MES DE "+_mes.get(mes)+" DEL "+anio; 
}

if ( motivoFalta.equals("37") ) {
   appendFilter += " and b.sexo = 'F'";
}

if ( !compania.equals("") ){
   appendFilter += " and a.compania = "+compania;
}

if (motivoFalta.equals("13") ) {
    rpt_Titulo = "LISTADO DE LICENCIA POR ENFERMEDAD"+titulo;
}
else if (motivoFalta.equals("35")) {
    rpt_Titulo = "LISTADO DE LICENCIA POR INCAPACIDAD"+titulo;
}
else if (motivoFalta.equals("37") ) {
     rpt_Titulo = "LISTADO DE LICENCIA POR GRAVIDEZ"+titulo;
}
else if (motivoFalta.equals("38") ) {
    rpt_Titulo = "LISTADO DE LICENCIA SIN SUELDO"+titulo;
}
else if (motivoFalta.equals("39") ) {
    rpt_Titulo = "LISTADO DE LICENCIA POR RIESGO PROFESIONAL"+titulo;
}
else if (motivoFalta.equals("40") ) {
    rpt_Titulo = "LISTADO DE LICENCIA CON SUELDO"+titulo;
}


sql= " SELECT a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento cedula,DECODE(TO_CHAR(a.motivo_falta),'39','RIESGO PROFESIONAL', '37','LICENCIA POR GRAVIDEZ','35','INCAPACIDAD' , '13','ENFERMEDAD','38','LICENCIA SIN SUELDO','40','LICENCIA CON SUELDO')  motivo_falta, TO_CHAR(a.fecha_inicio,'dd/mm/yyyy') fi,TO_CHAR(a.fecha_final,'dd/mm/yyyy') ff, b.primer_nombre||' '||DECODE(b.sexo,'F',DECODE(b.apellido_casada,NULL,b.primer_apellido,DECODE(b.usar_apellido_casada,'S','DE '||b.apellido_casada ,b.primer_apellido)),b.primer_apellido)  nombre_empleado,d.descripcion  dsp_unidad FROM tbl_pla_cc_licencia a, tbl_pla_empleado b, tbl_sec_unidad_ejec d WHERE b.provincia = a.provincia AND   b.sigla = a.sigla AND   b.tomo = a.tomo AND   b.asiento = a.asiento AND   b.compania = a.compania AND d.codigo = b.unidad_organi AND   d.compania = b.compania "+appendFilter+" AND  TO_CHAR(a.motivo_falta) = '"+motivoFalta+"' ORDER BY b.primer_nombre||' '||b.primer_apellido||' '|| DECODE(b.sexo,'F',DECODE(b.apellido_casada, NULL,b.segundo_apellido,'DE '||b.apellido_casada),'M',b.segundo_apellido), a.fecha_inicio";

//System.out.println("******************************************************************************SQL "+sql);
														
 al = SQLMgr.getDataList(sql);  	  

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	Hashtable htUni = new Hashtable();
	Hashtable htSec = new Hashtable();

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
	String title = "RECURSOS HUMANOS";
	String subtitle = rpt_Titulo;
	String xtraSubtitle = "";//" DEL "+fechaini+" AL "+fechafin;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".24");		
		dHeader.addElement(".50");				
		dHeader.addElement(".13");	
		dHeader.addElement(".13");			
		
				
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	    String groupDpt= ""; 

    pc.setFont(8, 1);
	
	
	    pc.addCols(" ",0,dHeader.size());
	    pc.addBorderCols("CEDULA",1,1,1.0f,1.0f,0.0f,0.0f);	
	    pc.addBorderCols("NOMBRE DEL EMPLEADO",0,1,1.0f,1.0f,0.0f,0.0f);		
	    pc.addBorderCols("DESDE",0,1,1.0f,1.0f,0.0f,0.0f);		
	    pc.addBorderCols("HASTA",1,1,1.0f,1.0f,0.0f,0.0f);
		pc.addCols(" ",0,dHeader.size());	  
	
	   if ( al.size() == 0 ){
	      pc.addCols("No hemos encontrado datos",1,dHeader.size());
	   }else{
	     pc.setFont(8, 0);
	    for ( int i = 0; i<al.size(); i++ ){
	       cdo = (CommonDataObject)al.get(i);
		  
		   pc.addCols(cdo.getColValue("CEDULA"),0,1);
		   pc.addCols(cdo.getColValue("NOMBRE_EMPLEADO"),0,1);
		   pc.addCols(cdo.getColValue("FI"),0,1);
		   pc.addCols(cdo.getColValue("FF"),0,1);
		   
		   pc.setFont(8,1);
		   pc.addCols(cdo.getColValue("DSP_UNIDAD"),0,dHeader.size());
		   pc.setFont(8,0);
           pc.addCols(" ",0,dHeader.size());
		
		}//for i
	
	   pc.addCols(" - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -",1,dHeader.size());
	  pc.addCols("TOTAL FINAL =>                "+al.size(),0,dHeader.size());
	
	  }//else

	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>



