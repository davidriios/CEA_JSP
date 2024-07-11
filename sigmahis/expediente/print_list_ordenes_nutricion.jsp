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
ArrayList al1 = new ArrayList();
ArrayList al2= new ArrayList();
ArrayList al3= new ArrayList();
ArrayList al4= new ArrayList();

CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo0, cdoPacData = new CommonDataObject();

String sql = "", sqlTitle;
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String cds = request.getParameter("cds");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

String descSala ="",filter="";
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String turno ="";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

	sql=" select case when to_date(to_char(sysdate,'hh12 am'),'hh12 am') between to_date('03 pm','hh12 am') and to_date('11 pm','hh12 am')then '2=3/11' when to_date(to_char(sysdate,'hh12 am'),'hh12 am') between to_date('07 am','hh12 am') and to_date('03 pm','hh12 am')then '1=7/3' else '3=11/7' end turno from dual ";
	
	cdo0 = SQLMgr.getData(sql);
	turno = cdo0.getColValue("turno");
	
if (appendFilter == null) appendFilter = "";



if (desc == null) desc = "";

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
	float leftRightMargin = 9.0f;
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
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	Vector dHeader = new Vector();
		dHeader.addElement(".49");
		dHeader.addElement(".02");
		dHeader.addElement(".49");
        
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

	
	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");
	
	Vector detCol = new Vector();
		detCol.addElement(".04");
		detCol.addElement(".32");
		detCol.addElement(".04");
	Vector detCol1 = new Vector();
		detCol1.addElement(".40");
	Vector detCol2 = new Vector();
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");

Vector infoCol2 = new Vector();
		infoCol2.addElement(".08");
		infoCol2.addElement(".10");
		infoCol2.addElement(".20");
		infoCol2.addElement(".20");
		infoCol2.addElement(".07");
		infoCol2.addElement(".07");
		infoCol2.addElement(".08");
		infoCol2.addElement(".20");
		
		Vector infoCol3 = new Vector();
		infoCol3.addElement(".80");
		infoCol3.addElement(".20");



	sql="select a.id,decode(a.turno,1,'7/3',2,'3/11',3,'11/7') turnoDesc, to_char(a.fecha,'dd/mm/yyyy')fecha, a.turno, a.usuario_crea,a.cama, a.nombre, a.alimentacion, decode(a.tipo_alimentacion,'M','MATERNA','P','PECHO')tipo_alimentacion, a.toma,to_char(a.fecha_crea,'dd/mm/yyyy hh12:mi:ss am')fecha_crea, a.observacion, a.peso from tbl_sal_alimentacion_paciente a where a.pac_id= "+pacId+" and a.admision = "+noAdmision+" /*and turno = "+turno.substring(0,1)+"*/ order by turno, fecha asc";

al2 = SQLMgr.getDataList(sql);
pc.setNoColumnFixWidth(infoCol2);

pc.createTable();
pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, infoCol2.size());
		pc.setFont(9, 0);
		//pc.createTable("dietas"+i,false);
		//pc.addBorderCols("TURNO:  "+turno.substring(2),2,infoCol2.size(),Color.gray);
		//pc.addBorderCols("DIETAS",1,infoCol2.size(),Color.gray);
		
		pc.addBorderCols("Fecha",0,1);
		pc.addBorderCols("Cama",0,1);
		pc.addBorderCols("Nombre",0,1);
		pc.addBorderCols("Alimentacion",0,1);
		pc.addBorderCols("Tipo",1,1);
		pc.addBorderCols("Toma",1,1);
		pc.addBorderCols("Peso",1,1);
		pc.addBorderCols("Observacion",1,1);
		
		
pc.setTableHeader(3);

turno="";
		

		for (int j=0; j<al2.size(); j++) 
		{	
				
				pc.setFont(9, 0,Color.white);
				CommonDataObject cdo = (CommonDataObject) al2.get(j);
				    if(!turno.trim().equals(cdo.getColValue("turno")))
					pc.addBorderCols("TURNO:  "+cdo.getColValue("turnoDesc"),2,infoCol2.size(),Color.gray);
					
					pc.setFont(9,0);
					pc.addBorderCols(" "+cdo.getColValue("fecha"),1,1);
					pc.addBorderCols(" "+cdo.getColValue("cama"),1,1);
					pc.addBorderCols(cdo.getColValue("nombre"),0,1);
					pc.addBorderCols(cdo.getColValue("alimentacion"),0,1);
					pc.addBorderCols(cdo.getColValue("tipo_alimentacion"),0,1);
					pc.addBorderCols(cdo.getColValue("toma"),0,1);
					pc.addBorderCols(cdo.getColValue("peso"),0,1);
					pc.addBorderCols(cdo.getColValue("observacion"),0,1);
					
					
				turno =cdo.getColValue("turno");
					//pc.addCols(cdo.getColValue("fechaFinal"),1,1);
					//pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
					//pc.addCols(cdo.getColValue("descDieta"),0,1);
					//pc.addCols(cdo.getColValue("estado_orden"),1,1);
					
					//pc.addCols(cdo.getColValue("nombre_paciente"),1,1);
					//pc.addCols(cdo.getColValue("fechaInicio"),1,1);
					//pc.addCols(cdo.getColValue("fechaFinal"),1,1);
					//pc.addCols(cdo.getColValue("usuario_creacion"),0,1);
					//pc.addCols(cdo.getColValue("descDieta"),0,1);
					//pc.addCols(cdo.getColValue("estado_orden"),1,1);
		}
		
		pc.setFont(9, 0);
		//pc.addBorderCols("   ",1, infoCol2.size());
					pc.addBorderCols("",0,1);
					pc.addBorderCols("",0,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols("",0,1);
					pc.addBorderCols(" ",1,1);
					
					pc.addBorderCols("",0,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols("",0,1);
					pc.addBorderCols("",0,1);
					pc.addBorderCols(" ",1,1);
					
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
					pc.addBorderCols(" ",1,1);
		//pc.addBorderCols("  ",0,infoCol2.size(), 0.5f, 0.5f, 0.0f, 0.0f);			
			/*
		
		for (int k=0; k<al1.size(); k++) 
		{	
				*/
				
				/*
					pc.resetVAlignment();
					pc.setFont(9, 1);
					pc.addTableToCols("paciente"+k,0,3,0.0f,Color.gray);
					pc.addTableToCols("medicamento"+k,0,1,0.0f,Color.gray);
					pc.addCols(" ",0,1,Color.gray);
					pc.addTableToCols("tratamientos"+k,0,1,0.0f,Color.gray);
					
					
					pc.addTableToCols("dietas"+k,0,1,0.0f,Color.gray);
					pc.addCols(" ",0,1,Color.gray);
					pc.addTableToCols("otros"+k,0,1,0.0f,Color.gray);
					pc.setVAlignment(0);
				*/
				/*pc.addCols(" ",0,3);
				if(k!=0) pc.addCols(" ",0,3,Color.gray);
					pc.addCols(" ",0,3);
					pc.resetVAlignment();
					pc.setFont(9, 1);
					//pc.addTableToCols("paciente"+k,0,3);
					//pc.addTableToCols("medicamento"+k,0,1);
					//pc.addCols(" ",0,1);
					//pc.addTableToCols("tratamientos"+k,0,1);
					//pc.addCols(" ",0,3);
					pc.addTableToCols("paciente"+k,0,3);
					pc.addTableToCols("dietas"+k,0,3);
					
					//pc.addCols(" ",0,1);
					//pc.addTableToCols("otros"+k,0,1);
					pc.setVAlignment(0);
				System.out.println("****************************************k ====*"+k);
		}
		*/
		
	
	pc.addCols("  ",0,infoCol2.size());
	
if ( al.size() == 0 ){
	pc.setFont(9,0);
    pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>