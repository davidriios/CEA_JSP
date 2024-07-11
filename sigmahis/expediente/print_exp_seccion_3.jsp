<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
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
Reporte
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
CommonDataObject cdo  = new CommonDataObject();
CommonDataObject cdop  = new CommonDataObject();


String sql = "";
String appendFilter = request.getParameter("appendFilter");
String seccion = request.getParameter("seccion");
String userName = UserDet.getUserName();
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = (request.getParameter("desc")==null?"":request.getParameter("desc"));

if (appendFilter == null) appendFilter = "";
if (desc.equals("")) desc = "ANTECEDENTE GINECO-OBSTETRICO";

cdop = SQLMgr.getPacData(pacId, noAdmision);

 sql  ="select CODIGO, GESTACION, PARTO, ABORTO, CESAREA, MENARCA, nvl(to_char(FUM,'dd/mm/yyyy'),' ') as FUM, nvl(CICLO,' ') CICLO, INICIO_SEXUAL,CONYUGES, nvl(to_char(FECHA_PAP,'dd/mm/yyyy'),' ') as FECHA_PAP, nvl(METODO,' ') METODO, nvl(decode(SUSTANCIAS,'S','SI','N','NO'),' ') SUSTANCIAS, nvl(OTROS,' ') OTROS, nvl(OBSERVACION,' ') OBSERVACION, ECTOPICO from TBL_SAL_ANTECEDENTE_GINECOLOGO where pac_id="+pacId;
 
	cdo  = SQLMgr.getData(sql);
	//if ( cdo == null ) cdo = new CommonDataObject();
		

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
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

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = "";
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
	
		dHeader.addElement(".40");
		dHeader.addElement(".10");
		dHeader.addElement(".40");
		dHeader.addElement(".10");
		
        CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdop.addColValue("is_landscape",""+isLandscape);
    }

		PdfCreator pc=null;
				
				boolean isUnifiedExp=false;
			
			//------------------------------------------------------------------------------------
		      pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
				
		if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
		isUnifiedExp=true;}

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdop, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8, 1);
		
		//pc.addCols("FECHA:  "+fecha.substring(0,10),0,1);
		//pc.addCols("HORA: "+fecha.substring(11),0,3);
	    //pc.addCols(" ",0,4);
		
		pc.setFont(8,1,Color.white);
		pc.addBorderCols("DESCRIPCION",1,1,Color.gray);
		pc.addBorderCols("VALOR",1,1,Color.gray);
		pc.addBorderCols("DESCRIPCION",1,1,Color.gray);
		pc.addBorderCols("VALOR",1,1,Color.gray);
		
      	

	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	pc.setVAlignment(0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.5f,cHeight);
	
//System.out.println(sql);

	pc.setFont(8,1);
   if (cdo == null){pc.addCols("No hemos encontrado registros!",1,dHeader.size());}
	else{
		pc.setFont(7,0);
		
		pc.addBorderCols("GESTACION:",2,1,0f,0f,1f,0f);
		pc.addBorderCols(cdo.getColValue("GESTACION"),1,1);
		pc.addCols("CONYUGES:",2,1); //5
		pc.addBorderCols(cdo.getColValue("CONYUGES"),0,1);
		pc.addBorderCols("PARTO:",2,1,0f,0f,1f,0f);
		pc.addBorderCols(cdo.getColValue("PARTO"),1,1);
		pc.addCols("FUM:",2,1); //5
		pc.addBorderCols(cdo.getColValue("FUM"),0,1);
		pc.addBorderCols("ABORTO:",2,1,0f,0f,1f,0f); // 2
		pc.addBorderCols(cdo.getColValue("aborto"),1,1);
		
		pc.addCols("ULTIMO PAPA NICOLAU:",2,1);
		pc.addBorderCols(cdo.getColValue("FECHA_PAP"),0,1);
		pc.addBorderCols("CESÁREA:",2,1,0f,0f,1f,0f);
		pc.addBorderCols(cdo.getColValue("CESAREA"),1,1);
		pc.addCols("CICLO MESTRUAL:",2,1); // 2
		pc.addBorderCols(cdo.getColValue("CICLO"),0,1);
		pc.addBorderCols("ECTÓPICO:",2,1,0f,0f,1f,0f); //5
		pc.addBorderCols(cdo.getColValue("ECTOPICO"),1,1);
		pc.addCols("METODO DE PLANIFICACION:",2,1);
		pc.addBorderCols(cdo.getColValue("METODO"),0,1);
		
		pc.addBorderCols("MENARCA",2,1,0f,0f,1f,0f);
		pc.addBorderCols(cdo.getColValue("MENARCA"),1,1);
		pc.addCols(" EXPOSICIÓN A TOXICOS Y SUSTANCIAS QUIMICAS O RADIOACTIVAS",2,1);
		pc.addBorderCols(cdo.getColValue("SUSTANCIAS"),0,1,0f,1f,1f,1f);
		
		/*pc.addBorderCols("I.V.S.A.",2,1,0f,0f,1f,0f);
		pc.addBorderCols(cdo.getColValue("INICIO_SEXUAL"),1,1);
		pc.addCols(" ",2,1);
		pc.addBorderCols(" ",0,1,0f,1f,1f,1f);*/
		//pc.addBorderCols("OBSERVACION:"+cdo.getColValue("OBSERVACION"),0,2,1f,0f,1f,0f);
		//pc.addBorderCols("OTROS:"+cdo.getColValue("OTROS"),0,2,1f,0f,0f,0f);
		
		/**/ pc.addBorderCols("I.V.S.A.",2,1,1f,0f,1f,0f);
		pc.addBorderCols(cdo.getColValue("INICIO_SEXUAL"),1,1);
		pc.addBorderCols(" ",2,1,1f,0f,0f,0f);
		
		
		
		
		
		pc.setVAlignment(2);
		pc.addBorderCols("",0,1,1f,0f,1f,1f);
		pc.addCols(" ",0,dHeader.size());
		pc.addBorderCols("OBSERVACION: "+cdo.getColValue("OBSERVACION"),0,2);
		pc.addBorderCols("OTROS: "+cdo.getColValue("OTROS"),0,2);
		
		}
		
		
		/*pc.addBorderCols("EXPOSICIÓN A TOXICOS Y SUSTANCIAS RADIOACTIVAS",2,1); //5
		pc.addBorderCols(cdo.getColValue("SUSTANCIAS"),0,1);
		
		 
	
		
		pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,15.2f);
	
		pc.addCols("",1,dHeader.size(),30.2f);*/
		 
		pc.setFont(8,0);
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>
