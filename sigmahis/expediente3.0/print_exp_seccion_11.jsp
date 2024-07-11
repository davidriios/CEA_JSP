<%@ page errorPage="../error.jsp" %>
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

<!-- Desarrollado por: José A. Acevedo C.      -->
<!-- Reporte: "Informe de Pacientes Fallecidos"-->
<!-- Reporte: ADM3087                          -->
<!-- Clínica Hospital San Fernando             -->
<!-- Fecha: 25/02/2010                         -->

<%
/**
==================================================================================
==================================================================================
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo, cdoPacData = new CommonDataObject();
String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String compania = (String) session.getAttribute("_companyId");

if (fg == null) fg = "";
boolean isFragment = fg.trim().equalsIgnoreCase("exp_kardex")||fg.trim().equalsIgnoreCase("handover");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

cdoUsr.addColValue("usuario",userName);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

	sql = "select b.admision, a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.usuario_creacion, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar, get_idoneidad(usuario_creacion, 1) usuario_creacion, get_idoneidad(usuario_modificacion, 1)usuario_modificacion, to_char(FECHA_CREACION, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(FECHA_MODIFICACION , 'dd/mm/yyyy hh12:mi am') fecha_modificacion  from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where 1=1";
    
    if (isFragment) {
        sql += " and a.codigo = b.tipo_alergia and b.pac_id = "+pacId+" /*and (nvl(b.admision,"+noAdmision+") = "+noAdmision+" or b.admision is null)*/";
    } else {
        sql += " and a.codigo = b.tipo_alergia and b.pac_id = "+pacId+" /*and (nvl(b.admision,"+noAdmision+") = "+noAdmision+" or b.admision is null)*/";
    }
    sql += " ORDER BY b.admision, a.orden ";
	
	al = SQLMgr.getDataList(sql);
    //cdo = SQLMgr.getData(sql);
	if(desc == null) desc = "";

	String fecha = cDateTime;
    //java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.lastIndexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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

	float width = 72 * 8.5f;//612 
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 35.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subTitle = desc;
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	String si,no ;
	int countSi = 0, countNo = 0;
    
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
		dHeader.addElement(".17"); 
		dHeader.addElement(".03");
		//dHeader.addElement(".04");
		dHeader.addElement(".06");
		dHeader.addElement(".10");
		dHeader.addElement(".29");
		dHeader.addElement(".12");
		
		dHeader.addElement(".10");	
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
		
		
        String showHeader = request.getParameter("showHeader");
        if (showHeader == null) showHeader = "Y";
        if (showHeader.equals("Y")){
            pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
        } else {
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(desc,1,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
        }

		pc.setFont(8, 1);
		
		pc.setVAlignment(0);
	
		pc.addBorderCols("Tipo de Alergia",1 ,1);
		pc.addBorderCols("SI",1 ,1);
		//pc.addBorderCols("NO",1 ,1);
		pc.addBorderCols("Edad",1 ,1);
		pc.addBorderCols("Meses",1 ,1);
		pc.addBorderCols("Observación",1 ,1);
		pc.addBorderCols("Creac.",1 ,1);
		pc.addBorderCols("Modif.",1 ,1);
		
		//pc.addCols("",1,dHeader.size(),8.2f);
		
		pc.setTableHeader(3);
		
        String gAdm = "";
		for(int i = 0; i<al.size(); i++){
		
		cdo = (CommonDataObject) al.get(i);
		
		String compar = "S";
		if(cdo.getColValue("aplicar").trim().equalsIgnoreCase("S")){
			si = "x"; //iconChecked;
			no = ""; //iconUnchecked;
		
		}else{
		   no = "x"; //iconChecked;
		   si = "";	//iconUnchecked;
		}
        
        if (!gAdm.equals(cdo.getColValue("admision"))) {
            pc.setFont(9, 1);
            pc.addCols("ADM.# "+cdo.getColValue("admision"," "),0,dHeader.size(),Color.gray);
        }
		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("descripcion"),0,1,15.2f);
        
		pc.addCols(si,1,1);
		//pc.addCols(no,1,1);
		pc.addCols(cdo.getColValue("edad"),1,1,15.2f);
		pc.addCols(cdo.getColValue("meses"),1,1,15.2f);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		pc.addCols(cdo.getColValue("fecha_creacion"," ")+" / "+cdo.getColValue("usuario_creacion"," "),0,1);
	   pc.addCols(cdo.getColValue("fecha_modificacion"," ")+" / "+cdo.getColValue("usuario_modificacion"," "),0,1);
		
		pc.addBorderCols("",1,dHeader.size(),0.0f,0.5f,0.0f,0.0f,8.2f);
        gAdm = cdo.getColValue("admision");
		}
	
		pc.addCols("",1,dHeader.size(),30.2f);
	
if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",0,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
