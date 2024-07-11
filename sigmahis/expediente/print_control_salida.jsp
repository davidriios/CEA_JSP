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
Reporte sal10050
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
ArrayList al2= new ArrayList();

CommonDataObject cdo1, cdoPacData, cdoTitle = new CommonDataObject();

StringBuffer sql = new StringBuffer();
String sqlTitle="";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEscala = request.getParameter("fechaEscala");
String id = request.getParameter("id");
String cds = request.getParameter("cds");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);


if (appendFilter == null) appendFilter = "";
//if (fechaEscala== null) fechaEscala = fecha.substring(0,10);
if (fechaEscala== null) fechaEscala = "";
if (fg== null) fg = "NO";
if (cds== null) cds = "";
if (desc== null) desc = "";
if (pacId== null) pacId = "";
if (noAdmision== null) noAdmision = "";

sql.append("select a.id, case when to_date(to_char(a.fecha_crea,'hh12 am'),'hh12 am') between to_date('03 pm','hh12 am') and to_date('11 pm','hh12 am')then '3/11' when to_date(to_char(a.fecha_crea,'hh12 am'),'hh12 am') between to_date('07 am','hh12 am') and to_date('03 pm','hh12 am')then '7/3' else '11/7' end turno, to_char(a.fecha,'dd/mm/yyyy')fecha, a.usuario_crea, a.usuario_modif, to_char(a.hora_salida,'hh12:mi am')hora_salida, to_char(a.hora_entrada,'hh12:mi am')hora_entrada,  nvl(a.bacinete,'N') bacinete, nvl(a.marquilla,'N') marquilla, nvl(a.status,'A')status,  a.pac_id, a.admision, a.cds, a.observacion,to_char(a.fecha_crea,'dd/mm/yyyy hh12:mi:ss am')fecha_crea, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente from tbl_sal_control_paciente a,tbl_adm_paciente b where a.pac_id = b.pac_id and a.cds=");
sql.append(cds);
if(!pacId.trim().equals("")){sql.append(" and a.pac_id=");sql.append(pacId);}
if(!noAdmision.trim().equals("")){sql.append(" and a.admision=");sql.append(noAdmision);}

sql.append(" order by fecha asc ");

al = SQLMgr.getDataList(sql.toString());

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
		dHeader.addElement(".20");
		//dHeader.addElement(".06");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".08");
		dHeader.addElement(".20");
		dHeader.addElement(".20");
        
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
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".10");
		infoCol.addElement(".40");
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
		pc.setFont(8,0);
		pc.addBorderCols("PACIENTE",1);
		//pc.addBorderCols("FECHA",1);
		pc.addBorderCols("HORA SALIDA",1);
		pc.addBorderCols("HORA ENTRADA",1);
		pc.addBorderCols("VERIFICO BACINETE",1);
		pc.addBorderCols("VERIFICO MARQUILLA",1);
		pc.addBorderCols("USUARIO",1);
		pc.addBorderCols("OBSERVACION",1);
		pc.addBorderCols("FIRMA",1);

	   pc.setTableHeader(2);//create de table header (3 rows) and add header to the table
	   
	pc.setVAlignment(0);
	String groupBy = "";
	String idGroup = "";
	int imgSize = 7;
	pc.setFont(8,0);
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if(!groupBy.trim().equals(cdo.getColValue("fecha")+"-"+cdo.getColValue("turno")))
		{
			pc.setFont(8,1);
			pc.addCols("Fecha:    "+cdo.getColValue("fecha"),0,3);
			pc.addCols("Turno:    "+cdo.getColValue("turno"),2,5);
		}
		pc.setFont(8,0);
		pc.addBorderCols(" "+cdo.getColValue("nombrePaciente"),0,1);
		//pc.addBorderCols(" "+cdo.getColValue("fecha"),0,1);
		pc.addBorderCols(" "+cdo.getColValue("hora_salida"),0,1);
		pc.addBorderCols(" "+cdo.getColValue("hora_entrada"),0,1);
		pc.addBorderCols(" "+cdo.getColValue("bacinete"),1,1);
		pc.addBorderCols(" "+cdo.getColValue("marquilla"),1,1);
		pc.addBorderCols(" "+cdo.getColValue("usuario_crea")+" / "+cdo.getColValue("usuario_modif"),0,1);
		pc.addBorderCols(" "+cdo.getColValue("observacion"),0,1);
		pc.addBorderCols(" ",0,1);
		
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		groupBy=cdo.getColValue("fecha")+"-"+cdo.getColValue("turno");
	}
	
	if ( al.size() == 0 ){
		pc.setFont(8,1);
		pc.addCols(".::No Hay Datos::.",1,dHeader.size());
	}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>