<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al2 = new ArrayList(); 
StringBuffer sbSql = new StringBuffer(); 
String userName = UserDet.getUserName();
String time =  ""+System.currentTimeMillis();  
String idOset = request.getParameter("id_oset"); 
  
if (idOset == null) idOset = ""; 

sbSql = new StringBuffer();
 
CommonDataObject cdoHd1 = SQLMgr.getData("select oset_desc from TBL_OSET_HEADER1 where ID_OSET = "+idOset);
if (cdoHd1 == null) cdoHd1 = new CommonDataObject();

al2 = SQLMgr.getDataList("select id_oset_h2, nvl(display_text, desc_header2) desc_header2, extra_info, tipo from TBL_OSET_HEADER2 where id_oset = "+idOset+" order by oder_no");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"-"+time+".pdf";

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
	int headerFontSize = 8;
	int groupFontSize = 8;
	int contentFontSize = 7;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = "ORDERSET";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	Vector dHeader = new Vector();
  dHeader.addElement(".05");
  dHeader.addElement(".05");
  dHeader.addElement(".10");
  
  dHeader.addElement(".20");
  dHeader.addElement(".20");
  dHeader.addElement(".20");
  dHeader.addElement(".20");
 
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(11, 1);
		pc.addCols(cdoHd1.getColValue("oset_desc"), 0, dHeader.size());

		 for (int h2 = 0; h2<al2.size(); h2++) {
        CommonDataObject cdo2 = (CommonDataObject) al2.get(h2);
        
        if ( cdo2.getColValue("tipo"," ").trim().equals("1") ) {
            if (h2 > 0 ) pc.addCols("", 0, dHeader.size());
           
            pc.setFont(9, 1);
            pc.addCols(" ",1,1);
            pc.addCols(cdo2.getColValue("desc_header2"), 0, dHeader.size() - 1);
         }
         if ( cdo2.getColValue("tipo"," ").trim().equals("2") ) {
            pc.setFont(9, 0);
            pc.addCols(" ",1,1);
            pc.addCols(cdo2.getColValue("desc_header2"," ").replaceAll("</br>","\\n").replaceAll("<br/>","\\n").replaceAll("<br>","\\n"), 0, dHeader.size() - 1);
         }
         if ( cdo2.getColValue("tipo"," ").trim().equals("3") ) {
            if (h2 > 0 ) pc.addCols("", 0, dHeader.size());
            
            pc.setFont(9, 1);
            pc.addCols(" ",1,1);
            pc.addCols(cdo2.getColValue("desc_header2"), 0, dHeader.size() - 1);
         }
         
         if(cdo2.getColValue("tipo"," ").trim().equals("3")){
              ArrayList alDet = SQLMgr.getDataList("select nvl(ref_name, '') ref_name,nvl(display_text,'') display_text, ref_code, frecuencia, dosis, nvl(add_info_text,' ') add_info_text, (select descripcion from TBL_OSET_TIPO_OM_CONFIG where id = om_type) tipo_om from TBL_OSET_HEADER2_DET where oset_header1 = "+idOset+" and oset_header2 = "+cdo2.getColValue("id_oset_h2")+" order by disp_order");
              
              for(int d = 0; d<alDet.size(); d++){
                  CommonDataObject cdoD = (CommonDataObject) alDet.get(d);
                  
                  pc.setFont(7, 0);
                  pc.addCols(" ",1,2);
                  pc.addCols(cdoD.getColValue("display_text"," ")+" / "+cdoD.getColValue("ref_name"," ") + "                       (" + cdoD.getColValue("tipo_om") + ")", 0, dHeader.size() - 2);
              } //d
          }
              
       } // for
		
		
		
		
		
		
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>