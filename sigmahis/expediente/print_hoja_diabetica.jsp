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
Reporte sal10060   
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
CommonDataObject cdoPacData, cdoTitle = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String fechaEval = request.getParameter("fechaEval")==null?"":request.getParameter("fechaEval");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (desc == null) desc = "";

if (!fechaEval.equals("")) appendFilter+=" and fecha_hoja = to_date('"+fechaEval+"','dd/mm/yyyy') ";

sql = " select to_char(fecha_hoja,'dd/mm/yyyy') fecha,to_char(hora,'hh12:mi am') hora, acetona, decode(tiempo,6,'6 A.M',11,'11 A.M',4,'4 P.M',9,'9 P.M') tiempo, glucosa,insulina,observacion,(select descripcion from tbl_sal_via_admin where status='A' and tipo_liquido='D' and codigo=si_no)via,glicema glicemia, (select hd.usuario_creacion||'/'||hd.usuario_modificacion from tbl_sal_hoja_diabetica hd where hd.fecha = fecha_hoja and hd.secuencia = secuencia and hd.fec_nacimiento = fec_nacimiento and hd.cod_paciente = cod_paciente ) usuario from tbl_sal_detalle_diabetica where pac_id = "+pacId+" and secuencia = "+noAdmision+appendFilter+" order by 1,2";
al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

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
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = !fechaEval.equals("")?"(Evaluación: "+fechaEval+")":"";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	
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


	Vector dHeader = new Vector();
		
			dHeader.addElement(".07"); //f
			dHeader.addElement(".07");//h
			dHeader.addElement(".12");
			dHeader.addElement(".07");
			dHeader.addElement(".08");
			dHeader.addElement(".07");
			dHeader.addElement(".08");
			dHeader.addElement(".07");
			dHeader.addElement(".13");
			dHeader.addElement(".24");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(7, 1);
		pc.addBorderCols("FECHA",1);
		pc.addBorderCols("HORA",1);
		pc.addBorderCols("USUARIO",1);
		pc.addBorderCols("GLUCOSA",1);
		pc.addBorderCols("ACETONA",1);
		pc.addBorderCols("INSULINA",1);
		pc.addBorderCols("GLICEMIA",1);
		pc.addBorderCols("TIEMPO",1);
		pc.addBorderCols("VIA",1);
		pc.addBorderCols("OBSERVACION",1);
	    pc.setTableHeader(3);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		pc.setFont(7, 0);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("hora"),1,1);
		pc.addCols(cdo.getColValue("usuario"),1,1);
		pc.addCols(cdo.getColValue("glucosa"),1,1);
		pc.addCols(cdo.getColValue("acetona"),1,1);
		pc.addCols(cdo.getColValue("insulina"),1,1);
		pc.addCols(cdo.getColValue("glicemia"),1,1);
		pc.addCols(cdo.getColValue("tiempo"),1,1);
		pc.addCols(cdo.getColValue("via"),1,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);

		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.setFont(3, 0);
	pc.addBorderCols(" ",1,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	
if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>