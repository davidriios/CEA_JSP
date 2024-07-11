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
String fechaHoraNac = request.getParameter("fecha_hora_nac");
String tiempoRuptura = request.getParameter("tiempo_ruptura");
String numeroBebe = request.getParameter("numero_bebe");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (appendFilter == null) appendFilter = "";
if (fechaControl== null) fechaControl = fecha.substring(0,10);
if (desc == null) desc = "";
if (fechaHoraNac == null) fechaHoraNac = "";
if (tiempoRuptura == null) tiempoRuptura = "";
if (numeroBebe == null) numeroBebe = "1";

if (!fechaControl.trim().equals(""))appendFilter +=" and to_date(to_char(b.fecha_inf(+),'dd/mm/yyyy'),'dd/mm/yyyy') =  to_date('"+fechaControl+"','dd/mm/yyyy') "; 
sql="select a.cod_paciente, a.fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.sexo,'M','MASCULINO','F','FEMENINO','I','INDEFINIDO') sexo, a.peso, a.talla, a.condicion, a.apgar as apgar1, a.apgar5 as apgar2, decode(a.alumbramiento,'ES','Espontáneo', 'AR','Artificial','ME','Maniobras Externas','EM','Extracción Manual de Anexos','CO','Completa') as alumbramiento, a.utero, a.consulta, a.observa_consulta as observConsulta, a.cavidad_uterina as cavidad, a.observa_cavidad as cavidU, a.cicatriz_ant as cicatriz, a.observa_cicatriz as cicatrizAnt, a.ruptura_uterina as ruptura, a.observa_ruptura as observRuptura, a.consulta_ruptura as conductaRuptura, a.observa_rup_uterina as obsvConducta, a.conducta as conductaCica, a.conducta_obsv as observaConducta, a.cuello, a.tratamiento_cuello as observCuello, a.vagina, a.tratamiento_vagina as observVagina, a.perine, tratamiento_perine as observPerine, a.recto, a.tratamiento_recto as observRect, a.medico as codMedico, a.alumbramiento_obsv as observ, a.pac_id,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion,to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, a.alumbramiento_min minutos, decode(a.vigoroso,'S','SI', 'N','NO') vigoroso, a.observacion , perimetro_toracico, tiempo_vida, perimetro_cefalico, decode(eval_riesgo,'C','CON RIESGO','SIN RIESGO') eval_riesgo, decode(rcp,'S','SI','N','NO') rcp, lugar_permanencia, lugar_transf, to_char(fecha_transf,'dd/mm/yyyy hh12:mi:ss am') fecha_transf, decode(tipo_nacimiento,'S','SIMPLE','M','MULTIPLE') tipo_nacimiento, orden_nac, to_char(hora,'hh12:mi:ss am') hora, to_char(a.fecha,'dd/mm/yyyy') fecha, get_idoneidad(usuario_creacion, 1) usuario_creacion, get_idoneidad(usuario_modificacion,1) usuario_modificacion from tbl_sal_historia_nacido a where a.pac_id="+pacId+" and nvl(admision, "+noAdmision+") = "+noAdmision+" and nvl(orden_nac, "+numeroBebe+") = "+numeroBebe;

cdo2 = SQLMgr.getData(sql);

if (cdo2 == null) cdo2 = new CommonDataObject();

if(cdo2 == null)
{
	cdo2 = new CommonDataObject();
}
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
        
        String showHeader = request.getParameter("showHeader");
        if (showHeader == null) showHeader = "Y";
        if (showHeader.equals("Y")){
            pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
        } else {
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(desc,1,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
        }

	pc.setTableHeader(2);
	pc.setVAlignment(0);
	
	pc.setFont(10, 1);

	pc.addCols("Creado el:    "+cdo2.getColValue("fechacreacion"),0,6);
	pc.addCols("Creado por:    "+cdo2.getColValue("usuario_creacion"),1,7);
	
	if (!cdo2.getColValue("usuario_modificacion"," ").trim().equals("")) {
		pc.addCols("Modificado el:    "+cdo2.getColValue("fecha_modificacion"),0,6);
		pc.addCols("Modificado por:    "+cdo2.getColValue("usuario_modificacion"),1,7);
	}
	pc.addCols(" ",0,13);
    
    pc.setFont(10,1,Color.WHITE);
	pc.addBorderCols("DATOS RECIEN NACIDO",0,13,Color.gray);

	pc.setFont(10, 1);
    pc.addBorderCols("Fecha:    "+cdo2.getColValue("fecha"),0,4);
	pc.addBorderCols("Hora:    "+cdo2.getColValue("hora"),0,6);
    pc.addBorderCols("Sexo:    "+cdo2.getColValue("sexo"),0,3);
    
    pc.setFont(10,1,Color.WHITE);
	pc.addBorderCols("Datos antropométricos al nacer",0,13,Color.gray);
    
    pc.setFont(10, 0);
    
    pc.addBorderCols("Peso:    "+cdo2.getColValue("peso"),0,6);
	pc.addBorderCols("Perímetro torácito:    "+cdo2.getColValue("perimetro_toracico"),0,7);
    pc.addBorderCols("Talla:    "+cdo2.getColValue("talla"),0,6);
	pc.addBorderCols("Tiempo de vida:    "+cdo2.getColValue("tiempo_vida"),0,7);
	pc.addBorderCols("Perímetro cefálico:    "+cdo2.getColValue("perimetro_cefalico"),0,dHeader.size());
    
	pc.addCols(" ",0,dHeader.size());
    pc.addBorderCols("Evaluación de riesgo:    "+cdo2.getColValue("eval_riesgo"),0,dHeader.size());
    pc.addBorderCols("Se realizará RCP:    "+cdo2.getColValue("rcp"),0,dHeader.size());

	pc.addBorderCols("Vigoroso: "+cdo2.getColValue("vigoroso"," "),0,4);
	pc.addBorderCols("Apgar 2:   ",0,1);
	pc.addBorderCols(cdo2.getColValue("apgar2"," "),0,1);
    pc.addBorderCols("Apgar 1:   ",0,2);
	pc.addBorderCols(cdo2.getColValue("apgar1"," "),0,2);
	pc.addBorderCols("  ",0,3);
    
    pc.addCols(" ",0,dHeader.size());
    
    pc.setFont(10,1,Color.WHITE);
	pc.addBorderCols("Lugar de permanencia del neonato",0,13,Color.gray);
    
    pc.setFont(10, 0);
    
    java.util.Vector LP = CmnMgr.str2vector(cdo2.getColValue("lugar_permanencia"), java.util.regex.Pattern.quote(","));
    
    pc.addBorderCols(CmnMgr.vectorContains(LP,"UCIN")?"[ x ] Unidad de cuidado Neonatales":"[   ] Unidad de cuidado Neonatales",0,6);
    pc.addBorderCols(CmnMgr.vectorContains(LP,"JM")?"[ x ] Junto a la madre":"[   ] Junto a la madre",0,7);
    
    pc.addBorderCols(CmnMgr.vectorContains(LP,"USIN")?"[ x ] Unidad de Semi intensivo Neonatal":"[   ] Unidad de Semi intensivo Neonatal",0,6);
    pc.addBorderCols(CmnMgr.vectorContains(LP,"NS")?"[ x ] Niño Sano":"[   ] Niño Sano",0,7);
    
    pc.addBorderCols(CmnMgr.vectorContains(LP,"AIS")?"[ x ] Transferido":"[   ] Transferido",0,6);
    pc.addBorderCols(CmnMgr.vectorContains(LP,"TRANS")?"[ x ] Transferido":"[   ] Transferido",0,7);
    
    pc.addBorderCols("Lugar:    "+cdo2.getColValue("lugar_transf"),0,6);
    pc.addBorderCols("Fecha/Hora:    "+cdo2.getColValue("fecha_transf"),0,7);
    
    pc.addCols(" ",0,dHeader.size());
    
    pc.addBorderCols("Tipo Nacimiento:    "+cdo2.getColValue("tipo_nacimiento"),0,dHeader.size()-2);
    pc.addBorderCols("Orden:    "+cdo2.getColValue("orden_nac"),0,2);
        
    pc.addBorderCols("Condición al nacer:",0,2);
	pc.addBorderCols(cdo2.getColValue("condicion"),0,11);
    
    pc.addBorderCols("Observación: ",0,2);
	pc.addBorderCols(cdo2.getColValue("observacion"),0,11);
    
    pc.setFont(10,1);
    pc.addBorderCols("Fecha y hora de Nacimiento:",0,3);
	pc.addBorderCols(fechaHoraNac,0,11);
    pc.addBorderCols("Tiempo de ruptura de membranas:",0,3);
	pc.addBorderCols(tiempoRuptura,0,11);
    
    
	pc.addCols(" ",0,13,cHeight);
    pc.setFont(10,1,Color.WHITE);
	pc.addBorderCols("REVISION POST PARTO: ",0,13,Color.gray);
	pc.setFont(10,0);
    
	pc.setVAlignment(1);
	pc.addBorderCols("UTERO:  BIEN CONTRAIDO",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("utero") != null && cdo2.getColValue("utero").trim().equals("C"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("HIPÓTONICO",0,1,cHeight);
		pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("utero") != null && cdo2.getColValue("utero").trim().equals("H"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
		
	pc.addCols("CONSULTA:    MÈDICA",1,3);	
	
	pc.setVAlignment(1);
		pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("consulta") != null && cdo2.getColValue("consulta").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	
	pc.addCols("QUIRÙRGICA",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("consulta") != null && cdo2.getColValue("consulta").trim().equals("Q"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	
	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);
	
	pc.addBorderCols("(Describa) "+obsCon,0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols("(Ver Hoja Operatoria)",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(10,0);
	
	pc.setVAlignment(1);
	pc.addBorderCols("CAVIDAD UTERINA",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("LI"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
		pc.addBorderCols(" ",0,10,0.0f,0.0f,0.0f,0.5f);
	
	
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(10,0);
	
	pc.setVAlignment(1);
	pc.addBorderCols("CON RESTOS PLACENTAROS",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("RP"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("REMOVIDOS TOTALMENTE",0,2,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("RT"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
		
	pc.addCols("MANUAL",1,2);	
	
	pc.setVAlignment(1);
		pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("MA"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	
	pc.addCols("INTRUMENTAL",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("IN"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
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
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("DESHISCENCIA DE CICATRIZ ANTERIOR",0,2,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("D"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
		
	pc.addCols("PARCIAL (NO TRASPASA MIOMETRIO) ",1,3);	
	
	pc.setVAlignment(1);
		pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("P"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	
	pc.addCols("AMPLIA (TRASPASA MIOMETRIO)",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("A"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	
	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);
	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	
	
	

	pc.setVAlignment(1);
	pc.addCols("CONDUCTA",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaCica") != null && cdo2.getColValue("conductaCica").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("QUIRÚRGICA",0,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaCica") != null && cdo2.getColValue("conductaCica").trim().equals("Q"))
			pc.addInnerTableBorderCols(" ",0,1,5.0f,5.0f,5.0f,5.0f);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
		
	String observaConducta = "";
	if(cdo2.getColValue("observaConducta") == null) observaConducta = "n/a";
	else observaConducta = cdo2.getColValue("observaConducta");
		
	pc.addCols("(Describa)  "+observaConducta,0,8);	
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	
	pc.setVAlignment(1);
	pc.addCols("RUPTURA UTERINA",0,2);
	pc.addCols("NO",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ruptura") != null && cdo2.getColValue("ruptura").trim().equals("N"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("SI",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ruptura") != null && cdo2.getColValue("ruptura").trim().equals("S"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
	
	String   observRuptura ="";
	if(cdo2.getColValue("observRuptura")==null)observRuptura = "n/a";
	else observRuptura =cdo2.getColValue("observRuptura");
		
	pc.addCols("(Describa)  "+observRuptura,0,7);	
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	
	
	pc.setVAlignment(1);
	pc.addCols("CONDUCTA:",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaRuptura") != null && cdo2.getColValue("conductaRuptura").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("QUIRÚRGICA",0,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaRuptura") != null && cdo2.getColValue("conductaRuptura").trim().equals("Q"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
	
	String obsvConducta = "";
	if(cdo2.getColValue("obsvConducta")==null) obsvConducta = "n/a";
	else obsvConducta = cdo2.getColValue("obsvConducta");
		
	pc.addCols("(Describa)  "+obsvConducta,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	
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
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("LACERADO",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cuello") != null && cdo2.getColValue("cuello").trim().equals("L"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
	
	String observCuello = "";
	if(cdo2.getColValue("observCuello")==null) observCuello = "n/a";
	else observCuello = cdo2.getColValue("observCuello");
		
	pc.addCols("Descripcion y tratamiento: "+observCuello,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	
	pc.setVAlignment(1);
	pc.addCols("VAGINA",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("vagina") != null && cdo2.getColValue("vagina").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
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
	pc.setFont(10,0);
	pc.resetVAlignment();
	
	String observVagina = "";
	if(cdo2.getColValue("observVagina")==null) observVagina = "n/a";
	else observVagina = cdo2.getColValue("observVagina");
		
	pc.addCols("Descripcion y tratamiento  "+observVagina,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	
	pc.setVAlignment(1);
	pc.addCols("PERINE",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("perine") != null && cdo2.getColValue("perine").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("LACERADO",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("perine") != null && cdo2.getColValue("perine").trim().equals("L"))
			pc.addInnerTableBorderCols(" ",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
	
	String observPerine = "";
	if(cdo2.getColValue("observPerine")==null) observPerine = "n/a";
	else observPerine = cdo2.getColValue("observPerine");
		
	pc.addCols("Descripcion y tratamiento  "+observPerine,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	
	pc.setVAlignment(1);
	pc.addCols("ANO-RECTO",0,1);
	pc.addCols("INDEMNE",2,1);
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("recto") != null && cdo2.getColValue("recto").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment(); 
	pc.addCols("LACERADO",2,1,cHeight);
	
	pc.setVAlignment(1);
	pc.setFont(10,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("recto") != null && cdo2.getColValue("recto").trim().equals("L"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();
	
	String observRect = "";
	if(cdo2.getColValue("observRect")==null)observRect = "n/a";
	else observRect = cdo2.getColValue("observRect");
		
	pc.addCols("Descripcion y tratamiento  "+observRect,0,8);	
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	
	pc.addCols(" ",0,dHeader.size());
    
    pc.setFont(10,1,Color.WHITE);
	pc.addBorderCols("ALUMBRAMIENTO",0,13,Color.gray);
    
    pc.setFont(10, 0);
    pc.addBorderCols("Alumbramiento: ",0,2);
    pc.addBorderCols(cdo2.getColValue("alumbramiento"),0,3);
    pc.addBorderCols(cdo2.getColValue("observ"),0,8);
    pc.addBorderCols("Minutos para el Alumbramiento: ",0,3);
    pc.addBorderCols(cdo2.getColValue("minutos"),0,10);
    
			
pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
%>