<%//@ page errorPage="../error.jsp"%>
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
StringBuffer sb = new StringBuffer();
String sql = "", appendFilter = "";  
String p_anio 	= request.getParameter("anio");
String nh = request.getParameter("nh");
	 
if (p_anio == null) p_anio = ""; 
if (nh == null) nh = "";


    sb.append(" select  to_char(add_months(trunc(sysdate, 'yyyy'), a.lvl - 1), 'MONTH', 'NLS_DATE_LANGUAGE = spanish') mes, (select count(b.pac_id) cumple from  tbl_adm_paciente b where extract(month from nvl(f_nac,fecha_nacimiento)) = a.lvl ");
	if(!nh.trim().equals("")){sb.append(" and nh='");sb.append(nh);sb.append("'");}
	if(!p_anio.trim().equals("")){sb.append(" and extract(year from nvl(f_nac,fecha_nacimiento)) = ");sb.append(p_anio);}
	
 	sb.append("  and estatus ='A' ) nacimientos from (select level as lvl from dual connect by rownum <= 12 ) a ");
 
al = SQLMgr.getDataList(sb.toString());


if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String subtitle = "REPORTE DE NACIMIENTOS ";
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
		pc.addBorderCols("Nacimientos",1,1);
		pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	    
	  //table body
	  int totNaci=0,totalfem =0, totalmas =0;
	
	  for (int i = 0; i < al.size(); i++) 
	  {
        cdo = (CommonDataObject) al.get(i);
        pc.addCols(cdo.getColValue("mes"),0,1);
        pc.addCols(cdo.getColValue("nacimientos") ,1,1);
        //pc.addBorderCols(cdo.getColValue("femeninos"),1,1);
        //pc.addBorderCols(cdo.getColValue("masculinos"),1,1);
        
        totNaci += Integer.parseInt(cdo.getColValue("nacimientos","0"));
        //totF += Integer.parseInt(cdo.getColValue("femeninos","0"));
        //totM += Integer.parseInt(cdo.getColValue("masculinos","0"));
     }
 
		pc.addBorderCols(" TOTAL : ",0,1);
	  	pc.addBorderCols(" "+totNaci,1,1);
			
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>