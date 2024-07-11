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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");
String exp = request.getParameter("exp");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fg == null) fg = "";
if (exp == null ) exp="";

sql = " select a.fec_nacimiento,a.cod_paciente, a.secuencia, to_char(a.fecha_medica,'dd/mm/yyyy') fecha_medica, to_char( a.hora,'hh12:mi am') hora, to_char(a.hora_medica,'hh12:mi am') hora_medica, a.medicamento, a.dosis, b.descripcion as via , a.frecuencia, a.observacion ";

if (exp.equals("3")) sql += ", get_idoneidad(c.usuario_creacion, 1) usuario_creacion, ";
else sql += ", c.usuario_creacion, ";

sql += " to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion,a.dosis_desc  from tbl_sal_medicamento_admision c, tbl_sal_detalle_medicamento a, tbl_sal_via_admin b where c.pac_id = a.pac_id and c.secuencia = a.secuencia and c.fecha = a.fecha_medica and c.hora = a.hora_medica and  a.pac_id = "+pacId+" and a.secuencia =  "+noAdmision+" and a.via = b.codigo order by  to_date(a.fecha_medica,'dd/mm/yyyy'), to_date(to_char(a.hora_medica,'hh12:mi am'),'hh12:mi am'), a.codigo asc ";

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
	String subtitle = desc;//"HOJA DE MEDICAMENTOS";
	String xtraSubtitle = "";
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
		dHeader.addElement(".08");
		dHeader.addElement(".20");
		dHeader.addElement(".08");
		dHeader.addElement(".13");
		dHeader.addElement(".13");
		dHeader.addElement(".25");
		dHeader.addElement(".13");


	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setVAlignment(0);
		
	pc.setTableHeader(1);//create de table header (2 rows) and add header to the table

	//table body
	String groupBy = "";
	pc.setVAlignment(0);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

 		//if (!groupBy.trim().equalsIgnoreCase(cdo.getColValue("fecha_medica")))
		 if(!groupBy.trim().equals(cdo.getColValue("fecha_medica")+"-"+cdo.getColValue("hora_medica")))
		  { // groupBy
		  		if (i != 0)
		     {
						pc.addCols(" ",0,dHeader.size(),cHeight);
						pc.addCols(" ",0,dHeader.size(),cHeight);
		     }

					pc.setFont(8, 1);
					pc.addBorderCols("Fecha: "+cdo.getColValue("fecha_medica"),0,4);
					pc.addBorderCols("Hora: "+cdo.getColValue("hora_medica"),0,3);

					pc.setFont(7, 1);
					//pc.addBorderCols("HORA",1);
					pc.addBorderCols("MEDICAMENTOS",1,2);
					pc.addBorderCols("DOSIS",1);
					pc.addBorderCols("VIA",1);
					pc.addBorderCols("FRECUENCIA",1);
					pc.addBorderCols("OBSERVACION",1);
					pc.addBorderCols("APLICADO POR",1);
			}

		pc.setFont(7, 0);
		//pc.addCols(cdo.getColValue("hora_medica"),1,0);
		pc.addCols(cdo.getColValue("medicamento"),0,2);
		
		pc.addCols((exp.equals("3")?cdo.getColValue("dosis_desc"):cdo.getColValue("dosis")),1,0);
		pc.addCols(cdo.getColValue("via"),1,0);
		pc.addCols(cdo.getColValue("frecuencia"),0,0);
		pc.addCols(cdo.getColValue("observacion"),0,0);
		pc.addCols(cdo.getColValue("usuario_creacion"),0,0);

		// groupBy = cdo.getColValue("fecha_medica");
		groupBy = cdo.getColValue("fecha_medica")+"-"+cdo.getColValue("hora_medica");


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	pc.addBorderCols("",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);

	if (al.size() == 0) {pc.setFont(8,1); pc.addCols("No existen registros",1,dHeader.size());}
	//else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>