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
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
<%@ include file="../common/pdf_header.jsp"%>

<!-- Desarrollado por: Oscar Hawkins      -->
<!-- Reporte: ""-->
<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData = new CommonDataObject();
String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String compania = (String) session.getAttribute("_companyId");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

cdoUsr.addColValue("usuario",userName);

sql = "select a.codigo,a.edad, a.descripcion, b.crecimiento,decode(b.crecimiento,null,'N','S') as valor, decode(a.edad,1,'2 MESES',2,'4 MESES',3,'6 MESES',4,'9 MESES',5,'12 MESES',6,'18 MESES',7,'2 A�OS',8,'3 A�OS',9,'5 A�OS',10,'OTRAS') descEdad, b.meses, b.pac_id from  tbl_sal_crecimiento_desarrollo a, tbl_sal_crecimiento_paciente b where a.codigo=b.crecimiento(+) and b.pac_id(+)="+pacId+" and a.edad is not null order by a.edad,a.orden";
	
//cdo = SQLMgr.getData(sql);

al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

if(desc == null) desc = "";

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
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 82 * 8.5f;//612 
	float height = 62 * 14f;//792
	boolean isLandscape = false;
	float leftRightMargin = 35.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title =  "EXPEDIENTE";//"Antecedentes Neonatal / Pediatrico";
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	String si,no , edad = "";
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);
	}
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

   String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
   String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";

			
		Vector dHeader = new Vector();
		dHeader.addElement(".08"); 
		dHeader.addElement(".45");
		dHeader.addElement(".47");
		

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);
		
		pc.setVAlignment(0);
	
		pc.setFont(7, 0);
		
		pc.addCols("",0,3);
		pc.addBorderCols("Edad",1 ,1);
		pc.addBorderCols("Desarrollo Psicomotor",1 ,2);
		for(int i = 0; i<al.size(); i++){
		
		cdo = (CommonDataObject) al.get(i);
		
		if(cdo.getColValue("crecimiento") != ""){
		    si =  "x"; //iconChecked;
			no = ""; //iconUnchecked;
		}else{
		    si = ""; //iconUnchecked;r
			no = "x"; //iconChecked;
		}
		 
		if(cdo.getColValue("crecimiento") != ""){
		pc.setFont(8, 0);
		
		if(!edad.equals(cdo.getColValue("descEdad"))){
		pc.addCols(cdo.getColValue("descEdad"),0,1);
		}else{
		pc.addCols("",0,1);	
		}
		
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue(""),0,1);
		pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,15.2f);
		}
		
		
		edad = cdo.getColValue("descEdad");
		
		}
		
		pc.addCols("",1,dHeader.size(),30.2f);
		
	
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
