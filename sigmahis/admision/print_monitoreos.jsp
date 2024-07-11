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
Reporte sal90022.rtf
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

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String fg = request.getParameter("fg");

if (appendFilter == null) appendFilter = " ";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";

if (fg == null) fg = "";
if(!tDate.trim().equalsIgnoreCase(""))
appendFilter += " and to_date(to_char(dm.fecha_adiciona,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date('"+tDate+"','dd/mm/yyyy') ";
if(!fDate.trim().equalsIgnoreCase(""))
appendFilter += " and to_date(to_char(dm.fecha_adiciona,'dd-mm-yyyy'),'dd/mm/yyyy') <= to_date('"+fDate+"','dd/mm/yyyy') ";


sql = "select   to_char(dm.fecha_adiciona,'dd-mon-yy hh:mi am') fecha_adiciona, dm.codigo noPaciente, m.primer_nombre||' '||m.primer_apellido||' '||m.apellido_de_casada nombre, to_char(m.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, dm.secuencia renglon, dm.p_diastolica, dm.p_sistolica, dm.semana_gesta,dm.num_monit,m.edad,m.provincia||'-'||m.sigla||'-'||m.tomo||'-'||m.asiento cedula,to_char(m.f_p_p,'dd/mm/yyyy')fpp, m.g gesta, m.p para, m.a aborto, m.c cesarea, m.medico,dm.mes ,decode(dm.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE') desc_mes ,a.primer_nombre||' '||a.primer_apellido /*a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada))*/ as nombre_medico from tbl_adm_monitoreo m, tbl_adm_detalle_monitoreo dm,tbl_adm_medico a where m.codigo=dm.codigo and m.medico = a.codigo(+) "+appendFilter+" group by dm.mes, dm.num_monit, m.fecha_registro,to_char(dm.fecha_adiciona,'dd-mon-yy hh:mi am'), dm.codigo, m.primer_nombre||' '||m.primer_apellido||' '||m.apellido_de_casada, to_char(m.fecha_nacimiento,'dd/mm/yyyy'), dm.secuencia , dm.p_diastolica, dm.p_sistolica, dm.semana_gesta,dm.num_monit,m.edad,m.provincia||'-'||m.sigla||'-'||m.tomo||'-'||m.asiento,to_char(m.f_p_p,'dd/mm/yyyy'), m.g, m.p, m.a, m.c, m.medico,dm.mes,decode(dm.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE'),a.primer_nombre||' '||a.primer_apellido order by dm.mes,dm.num_monit,m.fecha_registro ,3 asc ";

al = SQLMgr.getDataList(sql);

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
	String title = "ADMISION";
	String subtitle = "MONITOREOS POR PACIENTES";
	String xtraSubtitle = "DESDE    "+tDate+"    HASTA    "+fDate;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	int totalMes =0,total=0;
	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	
			dHeader.addElement(".17");
			dHeader.addElement(".05");
			dHeader.addElement(".12");
			dHeader.addElement(".06");
			dHeader.addElement(".04");
			dHeader.addElement(".09");
			dHeader.addElement(".06");
			dHeader.addElement(".05");
			dHeader.addElement(".02");
			dHeader.addElement(".02");
			dHeader.addElement(".02");
			dHeader.addElement(".02");
			dHeader.addElement(".15");
			dHeader.addElement(".05");
			dHeader.addElement(".05");

PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");
		
			//pc.createTable("paciente"+i,false);	
				pc.setNoColumnFixWidth(dHeader);
			pc.createTable("nombre",false);
			pc.setVAlignment(0);			
			pc.setFont(8, 1);
				pc.addBorderCols("NOMBRE",1);
				pc.addBorderCols("# Pte",1);
				pc.addBorderCols("REGISTRADO EL ",1);
				pc.addBorderCols("FECHA NAC.",1);
				pc.addBorderCols("EDAD",1);
				pc.addBorderCols("CEDULA",1);
				pc.addBorderCols("FPP",1);
				pc.addBorderCols("S.GESTA",1);
				pc.addBorderCols("G",1);
				pc.addBorderCols("P",1);
				pc.addBorderCols("A",1);
				pc.addBorderCols("C",1);
				pc.addBorderCols("MEDICO",1);
				pc.addBorderCols("P. SIST.",1);
				pc.addBorderCols("P. DIAST.",1);

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
		/*pc.setFont(7, 1);
			pc.addBorderCols("NOMBRE",1);
			pc.addBorderCols("# Pte",1);
			pc.addBorderCols("REGISTRADO EL ",1);
			pc.addBorderCols("FECHA NAC.",1);
			pc.addBorderCols("EDAD",1);
			pc.addBorderCols("CEDULA",1);
			pc.addBorderCols("FPP",1);
			pc.addBorderCols("S.GESTA",1);
			pc.addBorderCols("G",1);
			pc.addBorderCols("P",1);
			pc.addBorderCols("A",1);
			pc.addBorderCols("C",1);
			pc.addBorderCols("MEDICO",1);
			pc.addBorderCols("P. SIST.",1);
			pc.addBorderCols("P. DIAST.",1);*/
			pc.addTableToCols("nombre",0,dHeader.size());
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	pc.setVAlignment(0);
	String groupBy ="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		/*if (cdo.getColValue("estado").trim().equalsIgnoreCase("I")) pc.setFont(fontSize, 0, Color.RED);
		else pc.setFont(7, 0);*/
		if(!groupBy.trim().equalsIgnoreCase(cdo.getColValue("desc_mes")))
		{
			 pc.setFont(10, 0,Color.blue);
			if(i!=0){
			pc.addCols("Total por Mes ......................"+totalMes,0,dHeader.size());
			pc.addCols(" ",0,dHeader.size());
			totalMes=0;}
			
			
			 pc.addCols(cdo.getColValue("desc_mes"),0,dHeader.size());
			
		}
		pc.setFont(8, 0);
		pc.addBorderCols(cdo.getColValue("nombre"),0,1,cHeight);
		pc.addBorderCols(cdo.getColValue("noPaciente"),1,1);
		pc.addBorderCols(cdo.getColValue("fecha_adiciona"),1,1);
		pc.addBorderCols(cdo.getColValue("fecha_nacimiento"),1,1);
		pc.addBorderCols(cdo.getColValue("edad"),1,1);
		pc.addBorderCols(cdo.getColValue("cedula"),0,1);
		pc.addBorderCols(cdo.getColValue("fpp"),1,1);
		pc.addBorderCols(cdo.getColValue("semana_gesta"),1,1);
	
			pc.addBorderCols(cdo.getColValue("gesta"),1,1);
			pc.addBorderCols(cdo.getColValue("para"),1,1);
			pc.addBorderCols(cdo.getColValue("aborto"),1,1);
			pc.addBorderCols(cdo.getColValue("cesarea"),1,1);
		pc.addBorderCols(cdo.getColValue("nombre_medico"),0,1);
		pc.addBorderCols(cdo.getColValue("p_sistolica"),1,1);
		pc.addBorderCols(cdo.getColValue("p_diastolica"),1,1);
totalMes ++;
groupBy=cdo.getColValue("desc_mes");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	
	
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else
	{ 
		pc.setFont(10, 0,Color.blue);
		pc.addCols("Total por Mes ......................"+totalMes,0,dHeader.size());
		pc.setFont(10, 0,Color.red);
		pc.addCols("Total final   ......................"+al.size(),0,dHeader.size());
	}
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>