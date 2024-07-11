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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo2, cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaControl = request.getParameter("fechaControl");
String cod_Historia = request.getParameter("cod_Historia");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String seccion = request.getParameter("seccion");
String desc = request.getParameter("desc");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fechaControl== null) fechaControl = fecha.substring(0,10);
if (desc == null) desc = "";

if (!fechaControl.trim().equals(""))appendFilter +=" and to_date(to_char(b.fecha_inf(+),'dd/mm/yyyy'),'dd/mm/yyyy') =  to_date('"+fechaControl+"','dd/mm/yyyy') "; 
sql="select a.cod_paciente, a.fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.sexo, a.peso, a.talla, a.condicion, a.apgar as apgar1, a.apgar5 as apgar2, a.alumbramiento as alumbramiento, a.utero, a.consulta, a.observa_consulta as observConsulta, a.cavidad_uterina as cavidad, a.observa_cavidad as cavidU, a.cicatriz_ant as cicatriz, a.observa_cicatriz as cicatrizAnt, a.ruptura_uterina as ruptura, a.observa_ruptura as observRuptura, a.consulta_ruptura as conductaRuptura, a.observa_rup_uterina as obsvConducta, a.conducta as conductaCica, a.conducta_obsv as observaConducta, a.cuello, a.tratamiento_cuello as observCuello, a.vagina, a.tratamiento_vagina as observVagina, a.perine, tratamiento_perine as observPerine, a.recto, a.tratamiento_recto as observRect, a.medico as codMedico, a.alumbramiento_obsv as observ, a.pac_id, b.codigo medico, b.primer_nombre||' '||b.segundo_nombre||' '||DECODE(b.apellido_de_casada,NULL,b.primer_apellido||' '||b.segundo_apellido) AS nombre_medico,to_char(a.fecha_creacion,'dd/mm/yyyy') fechaCreacion,to_char(a.fecha_creacion,'hh12:mi:ss am') hora  from tbl_sal_historia_nacido a, tbl_adm_medico b where a.medico=b.codigo and a.pac_id="+pacId;

cdo2 = SQLMgr.getData(sql);

if(cdo2 == null)
{
	cdo2 = new CommonDataObject();
}


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
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 13.0f;
	String peso = "", talla = "", condNac="", apgar1="", apgar2="", obsCon="";
		PdfCreator footer = new PdfCreator();
	Vector dHeader = new Vector();
		dHeader.addElement(".11");
		dHeader.addElement(".09");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".06");
		dHeader.addElement(".05");
		dHeader.addElement(".09");
		dHeader.addElement(".04");
		dHeader.addElement(".04");
		dHeader.addElement(".09");
		dHeader.addElement(".09");
		dHeader.addElement(".04");
        
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
	Vector setBox = new Vector();
		setBox.addElement("8");
	Vector setBox1 = new Vector();
		setBox1.addElement("8");
		setBox1.addElement("8");
		setBox1.addElement("8");
		setBox1.addElement("8");
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		pc.setFont(7, 1);
	pc.setTableHeader(2);//create de table header (3 rows) and add header to the table
	pc.setVAlignment(0);
	
	pc.setFont(7, 0,Color.WHITE);

	pc.addCols("Fecha:  "+cdo2.getColValue("fecha"),0,1,Color.gray);
	pc.addCols("Hora: "+cdo2.getColValue("hora"),0,7,Color.gray);
	pc.addCols("",0,8);
	pc.addCols("",0,13);
	pc.addBorderCols("RECIEN NACIDO: ",0,4,cHeight,Color.gray);

	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9,cHeight);
	
	pc.setVAlignment(1);
	pc.addCols("SEXO: ",0,1,cHeight);
	pc.addCols("MASC.",2,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("sexo") != null && cdo2.getColValue("sexo").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("FEM",2,1,cHeight);
		pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("sexo") != null &&  cdo2.getColValue("sexo").trim().equals("F"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	pc.addCols("INDEF",2,1,cHeight);
		pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("sexo") != null && cdo2.getColValue("sexo").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	if(cdo2.getColValue("peso") == null){peso = "n/a";}else{peso = cdo2.getColValue("peso")+ " Grs";}
	if(cdo2.getColValue("talla") == null){talla = "n/a";}else{talla = cdo2.getColValue("talla") + " cms";}
	if(cdo2.getColValue("condicion") == null){condNac = "n/a";}
	if(cdo2.getColValue("apgar1") == null){apgar1="n/a";}
	if(cdo2.getColValue("apgar2") == null){apgar2="n/a";}
	if(cdo2.getColValue("observConsulta") == null){obsCon="n/a";}
	else{obsCon=cdo2.getColValue("observConsulta");}
	
	pc.addCols("PESO:   "+peso,0,2);
	pc.addCols("TALLA:  "+talla,0,4);
		
	pc.addBorderCols("CONDICION AL NACER ",0,2,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(" "+condNac,0,12,0.0f,0.5f,0.0f,0.0f);
	
	
	pc.addBorderCols("APGAR ",0,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols("  1   ",0,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(""+apgar1,0,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols("  5   ",0,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(""+apgar2,0,1,0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols("  ",0,8,0.0f,0.5f,0.0f,0.0f);
	
	
	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("ALUMBRAMIENTO ",0,4,cHeight,Color.gray);
	pc.setFont(7, 0);
	
	pc.addBorderCols(" A LOS            MINUTOS    ",0,9);
	
	pc.setVAlignment(1);
	pc.addBorderCols("Espontàneo",0,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("alumbramiento") != null &&  cdo2.getColValue("alumbramiento").trim().equals("ES"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("Artificial",0,1,cHeight);
		pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("alumbramiento") != null && cdo2.getColValue("alumbramiento").trim().equals("AR"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
		
	pc.addCols("MANIOBRAS EXTERNA ",1,2,cHeight);	
	
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("alumbramiento") != null && cdo2.getColValue("alumbramiento").trim().equals("ME"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addCols("EXTRACCION MANUAL DE ANEXOS ",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("alumbramiento") != null && cdo2.getColValue("alumbramiento").trim().equals("EM"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addBorderCols("  ",2,3,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);
	
	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("REVISION POST PARTO ",0,4,cHeight,Color.gray);
	pc.setFont(7, 0);
	
	pc.addBorderCols(" ",0,9,0.0f,0.5f,0.0f,0.5f,cHeight);
	
	
	pc.setVAlignment(1);
	pc.addBorderCols("UTERO:  BIEN CONTRAIDO",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("utero") != null && cdo2.getColValue("utero").trim().equals("C"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("HIPÓTONICO",0,1,cHeight);
		pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("utero") != null && cdo2.getColValue("utero").trim().equals("H"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
		
	pc.addCols("CONSULTA:    MÈDICA",1,3);	
	
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("consulta") != null && cdo2.getColValue("consulta").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addCols("QUIRÙRGICA",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("consulta") != null && cdo2.getColValue("consulta").trim().equals("Q"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);
	
	pc.addBorderCols("(Describa) "+obsCon,0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols("(Ver Hoja Operatoria)",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(7, 0);
	
	pc.setVAlignment(1);
	pc.addBorderCols("CAVIDAD UTERINA",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("LI"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
		pc.addBorderCols(" ",0,10,0.0f,0.0f,0.0f,0.5f);
	
	
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(7, 0);
	
	pc.setVAlignment(1);
	pc.addBorderCols("CON RESTOS PLACENTAROS",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("RP"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("REMOVIDOS TOTALMENTE",0,2,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("RT"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
		
	pc.addCols("MANUAL",1,2);	
	
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("MA"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addCols("INTRUMENTAL",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("IN"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);
	
	String cavidU = "";
	if(cdo2.getColValue("cavidU")==null){cavidU="n/a";}
	else{cavidU = cdo2.getColValue("cavidU");}
	
	pc.addBorderCols("(Describa) "+cavidU,0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);

	pc.addBorderCols("CICATRIZ ANTERIOR",0,dHeader.size());

	pc.setVAlignment(1);
	pc.addBorderCols("INDEMNE",0,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("DESHISCENCIA DE CICATRIZ ANTERIOR",0,2,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("D"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
		
	pc.addCols("PARCIAL (NO TRASPASA MIOMETRIO) ",1,3);	
	
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("P"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addCols("AMPLIA (TRASPASA MIOMETRIO)",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("A"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	
	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);
	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	
	
	

	pc.setVAlignment(1);
	pc.addCols("CONDUCTA",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaCica") != null && cdo2.getColValue("conductaCica").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("QUIRÚRGICA",0,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaCica") != null && cdo2.getColValue("conductaCica").trim().equals("Q"))
			pc.addInnerTableBorderCols(" ",0,1,5.0f,5.0f,5.0f,5.0f);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
		
	String observaConducta = "";
	if(cdo2.getColValue("observaConducta") == null) observaConducta = "n/a";
	else observaConducta = cdo2.getColValue("observaConducta");
		
	pc.addCols("(Describa)  "+observaConducta,0,8);	
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	
	pc.setVAlignment(1);
	pc.addCols("RUPTURA UTERINA",0,2);
	pc.addCols("NO",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ruptura") != null && cdo2.getColValue("ruptura").trim().equals("N"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("SI",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ruptura") != null && cdo2.getColValue("ruptura").trim().equals("S"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	String   observRuptura ="";
	if(cdo2.getColValue("observRuptura")==null)observRuptura = "n/a";
	else observRuptura =cdo2.getColValue("observRuptura");
		
	pc.addCols("(Describa)  "+observRuptura,0,7);	
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	
	
	pc.setVAlignment(1);
	pc.addCols("CONDUCTA:",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaRuptura") != null && cdo2.getColValue("conductaRuptura").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("QUIRÚRGICA",0,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaRuptura") != null && cdo2.getColValue("conductaRuptura").trim().equals("Q"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	String obsvConducta = "";
	if(cdo2.getColValue("obsvConducta")==null) obsvConducta = "n/a";
	else obsvConducta = cdo2.getColValue("obsvConducta");
		
	pc.addCols("(Describa)  "+obsvConducta,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
		
	pc.setVAlignment(1);
	pc.addCols("CUELLO",0,1);
	pc.addCols("INDEMNE",2,1);
	pc.setVAlignment(1);
	pc.setFont(7, 7);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cuello") != null && cdo2.getColValue("cuello").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("LACERADO",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cuello") != null && cdo2.getColValue("cuello").trim().equals("L"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	String observCuello = "";
	if(cdo2.getColValue("observCuello")==null) observCuello = "n/a";
	else observCuello = cdo2.getColValue("observCuello");
		
	pc.addCols("Descripcion y tratamiento: "+observCuello,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	
	pc.setVAlignment(1);
	pc.addCols("VAGINA",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("vagina") != null && cdo2.getColValue("vagina").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("LACERADO",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 7);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("vagina") != null && cdo2.getColValue("vagina").trim().equals("L"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	String observVagina = "";
	if(cdo2.getColValue("observVagina")==null) observVagina = "n/a";
	else observVagina = cdo2.getColValue("observVagina");
		
	pc.addCols("Descripcion y tratamiento  "+observVagina,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	
	pc.setVAlignment(1);
	pc.addCols("PERINE",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("perine") != null && cdo2.getColValue("perine").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("LACERADO",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("perine") != null && cdo2.getColValue("perine").trim().equals("L"))
			pc.addInnerTableBorderCols(" ",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	String observPerine = "";
	if(cdo2.getColValue("observPerine")==null) observPerine = "n/a";
	else observPerine = cdo2.getColValue("observPerine");
		
	pc.addCols("Descripcion y tratamiento  "+observPerine,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	
	pc.setVAlignment(1);
	pc.addCols("ANO-RECTO",0,1);
	pc.addCols("INDEMNE",2,1);
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("recto") != null && cdo2.getColValue("recto").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment(); 
	pc.addCols("LACERADO",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("recto") != null && cdo2.getColValue("recto").trim().equals("L"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	
	String observRect = "";
	if(cdo2.getColValue("observRect")==null)observRect = "n/a";
	else observRect = cdo2.getColValue("observRect");
		
	pc.addCols("Descripcion y tratamiento  "+observRect,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
				
	
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	pc.addCols(" ",0,dHeader.size());
	
	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.setFont(7, 0);
	
	pc.setFont(7, 0,Color.WHITE);
	pc.addCols("MEDICO TRATANTE:",0,2,Color.gray);
	pc.setFont(7, 0);
	pc.setVAlignment(1);
	pc.addCols((cdo2.getColValue("medico")!=null?"["+cdo2.getColValue("medico")+"] "+cdo2.getColValue("nombre_medico"):""),0,11);

		
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	
			
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>