<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Collection" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
if (request.getMethod().equalsIgnoreCase("GET"))
{
	SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);

	CmnMgr.setConnection(ConMgr);
	SQLMgr.setConnection(ConMgr);

	String customFirstTitle = request.getParameter("custom_first_title");
	String pacId = request.getParameter("pacId");
	String noAdmision = request.getParameter("noAdmision");
	String cds = request.getParameter("cds");
	String isTmp = request.getParameter("is_tmp");
	String sections = request.getParameter("sections");
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String userName = UserDet.getUserName();
	String boletaAdm = request.getParameter("boletaAdm")==null?"":request.getParameter("boletaAdm");
	int size = Integer.parseInt(request.getParameter("size")==null?"0":request.getParameter("size"));
    if (isTmp == null) isTmp = "";
    if (sections == null) sections = "";
    if (customFirstTitle == null) customFirstTitle = "";

	if (isTmp.equals("")){
        Exception up = new Exception("No encontramos ningún archivo para imprimir!");
        if (size < 1 && boletaAdm.trim().equals("")) throw up;
    }

	String printBoletaAdm = "";
	if ( boletaAdm.trim().equals("S") ){
	  printBoletaAdm = "../admision/print_admision.jsp";
	}
	
	Object al[] = {};
    
    if (!isTmp.equals("")) {
       session.setAttribute("_alRpt", null);
    }
	
	try{
	  al = ((Object[])session.getAttribute("_alRpt")).clone();
	}catch(Exception e){}
  
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	String title = "EXPEDIENTE GENERAL";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
    
    Vector vFooter = new Vector();
    vFooter.addElement("60");
    vFooter.addElement("40");
    
    PdfCreator footer = new PdfCreator(width, height, leftRightMargin);
	footer.setNoColumnFixWidth(vFooter);
	footer.createTable();
	footer.setFont(10, 0);
    footer.addBorderCols(" ",0,vFooter.size(),0.0f,0.0f,0.0f,0.0f);
    footer.addCols("Firma: __________________________",0,vFooter.size()-1);
    footer.addCols("Fecha: __________________________",0,vFooter.size()-1);
    footer.addBorderCols(" ",0,vFooter.size(),0.0f,0.0f,0.0f,0.0f);
    	
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, footer.getTable());
   
   session.setAttribute("printExpedienteUnico",pc);
   
   if ( !printBoletaAdm.equals("") ){%>
   		<jsp:include page="<%=printBoletaAdm%>">
	    	 <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
			<jsp:param name="noAdmision" value="<%=noAdmision%>"></jsp:param>
	    	<jsp:param name="cds" value="<%=cds%>"></jsp:param>
			<jsp:param name="desc" value="BOLETA DE ADMISION"></jsp:param>
		</jsp:include>
		<% pc.addNewPage(); %>
   <% 
   } 
   if(!isTmp.equals("")){
        ArrayList alS = SQLMgr.getDataList("select codigo, descripcion, replace(lower(a.report_path),'/expediente/','/expediente3.0/') page, codigo seccion from tbl_sal_expediente_secciones a where a.codigo in("+sections+") order by instr (get_filled_value('"+sections+"',',','0',3), lpad(a.codigo,3,'0') )");
        
        for (int s = 0; s<alS.size(); s++) {
            CommonDataObject cdoS = (CommonDataObject) alS.get(s);
            if(cdoS == null || "".equals(cdoS.getColValue("page"))) continue;
            String header = "N";
            if (s == 0) header = "Y";
            try{
            System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: PRINTING: "+cdoS.getColValue("page"));
            %>
                <jsp:include page="<%=cdoS.getColValue("page")%>">
                    <jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
                    <jsp:param name="noAdmision" value="<%=noAdmision%>"></jsp:param>
                    <jsp:param name="cds" value="<%=cds%>"></jsp:param>
                    <jsp:param name="desc" value="<%=cdoS.getColValue("descripcion")%>"></jsp:param>
                    <jsp:param name="seccion" value="<%=cdoS.getColValue("seccion")%>"></jsp:param>
                    <jsp:param name="showHeader" value="<%=header%>"></jsp:param>
                    <jsp:param name="exp" value="3"></jsp:param>
                    <jsp:param name="custom_first_title" value="<%=customFirstTitle%>"></jsp:param>
                    <jsp:param name="is_tmp" value="<%=isTmp%>"></jsp:param>
                </jsp:include>
                <% pc.addNewPage(); %>
            <% 
            }catch(Exception e){
                e.printStackTrace();
                System.out.println("::::::::::::::::::::::: ERROR WHILE PRINTING: \"["+cdoS.getColValue("seccion")+"] "+cdoS.getColValue("descripcion")+"\" ("+cdoS.getColValue("page")+") CAUSED BY: "+e+". PLEASE COMMENT THE ERROR LINE FOR MORE DETAIL.");
            %>
                 <jsp:include page="../expediente/fallback_pdf.jsp">
                   <jsp:param name="fbd" value="<%=cdoS.getColValue("descripcion")+", "+cdoS.getColValue("page")+", ::"+e+"::"%>"></jsp:param>
                 </jsp:include>
                 <% pc.addNewPage(); %>
            <% 
            } 
        
        } // for s
        
   } else {
   
   for(int i=0;i<al.length;i++) { 
      CommonDataObject cdo = (CommonDataObject) al[i];
	    if(cdo==null || "".equals(cdo.getColValue("page"))) continue;
		try{
	    %>
			<jsp:include page="<%=cdo.getColValue("page")%>">
				<jsp:param name="pacId" value="<%=pacId%>"></jsp:param>
				<jsp:param name="noAdmision" value="<%=noAdmision%>"></jsp:param>
				<jsp:param name="cds" value="<%=cds%>"></jsp:param>
				<jsp:param name="desc" value="<%=cdo.getColValue("desc")%>"></jsp:param>
				<jsp:param name="seccion" value="<%=cdo.getColValue("seccion")%>"></jsp:param>
			</jsp:include>
			<% pc.addNewPage(); %>
	    <% 
	    }catch(Exception e){
	     e.printStackTrace();
		 System.out.println("::::::::::::::::::::::: ERROR WHILE PRINTING: \"["+cdo.getColValue("seccion")+"] "+cdo.getColValue("desc")+"\" ("+cdo.getColValue("page")+") CAUSED BY: "+e+". PLEASE COMMENT THE ERROR LINE FOR MORE DETAIL.");
	    %>
			 <jsp:include page="../expediente/fallback_pdf.jsp">
			   <jsp:param name="fbd" value="<%=cdo.getColValue("desc")+", "+cdo.getColValue("page")+", ::"+e+"::"%>"></jsp:param>
			 </jsp:include>
			 <% pc.addNewPage(); %>
	    <% 
	    } 
   }
   }
   
   // got to remove flush=true, because this causes the response to be commited and therefore, screws my redirect. This pissed me off!
   
	session.removeAttribute("printExpedienteUnico");
	pc.close();
	try{
		response.sendRedirect(redirectFile);
		return;
	}catch(Exception e){
	  e.printStackTrace();
	}
}
%>