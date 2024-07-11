<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

	CmnMgr.setConnection(ConMgr);
	SQLMgr.setConnection(ConMgr);
	CommonDataObject cdo=new CommonDataObject();
	ArrayList al = new ArrayList();
	ArrayList alE = new ArrayList();
	
	String admCat = request.getParameter("admCat")==null?"1":request.getParameter("admCat");
	
	String sql = "", appendFilter = "";
	
	String p_dia  	= "01";   //-- valor fijo para el primer día de cada mes.
	String p_mes  	= request.getParameter("mes1");
	String p_anio 	= request.getParameter("anio");
	
if (p_mes==null) p_mes = "";
if (p_anio == null) p_anio = "";
if (appendFilter == null) appendFilter = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "REPORTE DE ADMISIONES";
	String xtraSubtitle = "AL AÑO "+p_anio;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
		setDetail.addElement(".50");
		setDetail.addElement(".50");
	
		

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, "", fecha, setDetail.size());

		//second row
		pc.setFont(10, 1);
		pc.addBorderCols("MES",0,1);
		pc.addBorderCols("Admisiones",1,1);
		
		
	
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    int no = 0;
	
	     if (p_mes.trim().equals("01")) month = "ENERO";
	else if (p_mes.trim().equals("02")) month = "FEBRERO";
	else if (p_mes.trim().equals("03")) month = "MARZO";
	else if (p_mes.trim().equals("04")) month = "ABRIL";
	else if (p_mes.trim().equals("05")) month = "MAYO";
	else if (p_mes.trim().equals("06")) month = "JUNIO";
	else if (p_mes.trim().equals("07")) month = "JULIO";
	else if (p_mes.trim().equals("08")) month = "AGOSTO";
	else if (p_mes.trim().equals("09")) month = "SEPTIEMBRE";
	else if (p_mes.trim().equals("10")) month = "OCTUBRE";
	else if (p_mes.trim().equals("11")) month = "NOVIEMBRE";
	else if (p_mes.trim().equals("12")) month = "DICIEMBRE";
	
			 
	//table body
	int total=0, totales=0,totalfem =0, totalmas =0;
	
	if (p_mes.trim().equals("")){
for (int i=1; i<=12; i++){ 
 
	sql = "select count(*) total from tbl_adm_admision where categoria= "+admCat+" and trunc(fecha_ingreso)>= to_date('01/'||lpad("+i+",2,0)||'/"+p_anio+"','dd/mm/yyyy')and trunc(fecha_ingreso)<=last_day (to_date('01/'||lpad("+i+",2,0)||'/"+p_anio+"','dd/mm/yyyy'))";
		
	cdo = SQLMgr.getData(sql);

	
	if (i == 1) month = "ENERO";
	else if (i == 2) month = "FEBRERO";
	else if (i == 3) month = "MARZO";
	else if (i == 4) month = "ABRIL";
	else if (i == 5) month = "MAYO";
	else if (i == 6) month = "JUNIO";
	else if (i == 7) month = "JULIO";
	else if (i == 8) month = "AGOSTO";
	else if (i == 9) month = "SEPTIEMBRE";
	else if (i == 10) month = "OCTUBRE";
	else if (i == 11) month = "NOVIEMBRE";
	else if (i == 12) month = "DICIEMBRE";
	
if (cdo == null) cdo = new CommonDataObject();
if (cdo.getColValue("total")!= null && !cdo.getColValue("total").trim().equals("")){
  total += Integer.parseInt(cdo.getColValue("total"));
  totalmas += Integer.parseInt(cdo.getColValue("total"));
  totales += Integer.parseInt(cdo.getColValue("total"));
  }


			 
			pc.addCols(" "+month,0,1);
	  		pc.addCols(" "+cdo.getColValue("total"),1,1);
		
			
	   
	total = 0;		
	//if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
}
}else
{
	sql = "select (select count(*) from tbl_adm_neonato where  trunc(fecha_nacimiento)>= to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy')and trunc(fecha_nacimiento)<=last_day (to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy')) and sexo='F') femenino,(select count(*) from tbl_adm_neonato where  trunc(fecha_nacimiento)>= to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy') and trunc(fecha_nacimiento) <=last_day (to_date('01/"+p_mes+"/"+p_anio+"','dd/mm/yyyy'))and sexo='M') masculino from dual";
	
cdo = SQLMgr.getData(sql);
			 if (cdo == null) cdo = new CommonDataObject();
if (cdo.getColValue("admision")!= null && !cdo.getColValue("admision").trim().equals("")){
  total += Integer.parseInt(cdo.getColValue("admision"));
  totalmas += Integer.parseInt(cdo.getColValue("admision"));
  totales += Integer.parseInt(cdo.getColValue("admision"));
  }
if (cdo.getColValue("admision")!= null && !cdo.getColValue("admision").trim().equals("")){

  total += Integer.parseInt(cdo.getColValue("admision"));
  totalfem += Integer.parseInt(cdo.getColValue("admision"));
  totales += Integer.parseInt(cdo.getColValue("admision"));
}
			pc.addCols(""+month,0,1);
	  		pc.addCols(" "+cdo.getColValue("admision"),1,1);
			
total =0;
} 
	pc.addBorderCols(" TOTAL : ",0,1);
	  		pc.addBorderCols(" "+totalmas,1,1);
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>