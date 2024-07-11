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

String sql = "", sqlTitle ="";
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

sql="select decode(b.APELLIDO_DE_CASADA,null, b.PRIMER_APELLIDO||' '||b.SEGUNDO_APELLIDO, b.APELLIDO_DE_CASADA)||' '|| b.PRIMER_NOMBRE||' '||b.SEGUNDO_NOMBRE as nombreMedico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha_u_r,'dd/mm/yyyy') as fechaUR, to_char(a.fecha_u_r,'dd') as dia,to_char(a.fecha_u_r,'mm') as mes,to_char(a.fecha_u_r,'yyyy') as anio, a.edad_gesta as edadGesta, a.gesta as gesta, a.para as para, a.cesarea as cesarea, a.aborto as aborto, nvl(a.embarazo,'S') as embarazo, a.numero_hijo as numeroHijo, nvl(a.trabajo_parto,'E') as trabajoParto, to_char(a.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(a.hora_ini,'hh12:mi:ss am') as horaIniFull,to_char(a.fecha_ini,'dd') as diaParto,to_char(a.fecha_ini,'mm') as mesParto,to_char(a.fecha_ini,'yyyy') as anioParto,to_char(a.hora_ini,'hh12:mi:ss') as horaIni,to_char(a.hora_ini,'AM') as ampmParto, nvl(a.ruptura_membrana,'E') as rupturaMembrana, to_char(a.fecha_ruptura,'dd/mm/yyyy') as fechaRuptura, to_char(a.fecha_ruptura,'dd') as diaRuptura,to_char(a.fecha_ruptura,'mm') as mesRuptura, to_char(a.fecha_ruptura,'yyyy') as anioRuptura,to_char(a.hora_ruptura,'hh12:mi:ss') as  horaRuptura, to_char(a.hora_ruptura,'AM') as ampmRuptura, to_char(a.hora_ruptura,'hh12:mi:ss am') as horaRupturaFull, decode(a.ALUMBRAMIENTO,'E','ESPONTANEO','AR','ARTIFICIAL','ME','MANIOBRAS EXTRERNAS','EXTRACCION MANUAL DE ANEXOS','CO','COMPLETA') alumbramiento, a.observ, a.minutos, a.sensibilizacion_rh rh, a.sensibilizacion_abo abo, a.serologia_lues, a.patologia pat, a.patologia_espec patdesc, a.ELECTROFORESIS_HB, a.TOXOPLASMOSIS, a.PATOLOGIA_HIJOS_ANT pat_ant, a.PATOLOGIA_HIJOS_ANT_ESPEC pat_ant_desc, a.ANOMALIA_CONGENITA, a.ANOMALIA_CONG_ESPECIFICAR, a.ecografia, a.horas_labor, a.MONITOREO, a.SIGNO_SUFRIMIENTO_FETAL, a.CAUSAS_INTERVENCION, a.DROGAS, a.DROGAS_NOMBRE, a.DROGAS_TIEMPO_ANTEPARTO_DOSIS, /*datos adicionales*/ /*tab 1*/nvl(a.cantidad_liquido,'N') as cantidadLiquido, nvl(a.aspecto_liquido,'CS') as aspectoLiquido, to_char(a.fecha_parto,'dd/mm/yyyy') as fechaParto, to_char(a.fecha_parto,'dd') as diaPara,to_char(a.fecha_parto,'mm') as mesPara,to_char(a.fecha_parto,'yyyy') as anioPara,   to_char(a.hora_parto,'hh12:mi:ss') as horaPara,to_char(a.hora_parto,'AM') as ampmPara , to_char(a.hora_parto,'hh12:mi:ss am') as horaParto/*tab 2*/, a.dia_tacto as diaTacto, to_char(a.hora_tacto,'hh12:mi:ss am') as horaTacto /*tab 3*/, a.cuello_dil as cuelloDil, a.segmento as segmento, a.planos as planos, a.foco as foco, a.funcion as funcion, a.membrana as membrana, a.temperatura as temperatura, a.observa_tacto as observaTacto, a.observa_tratamiento as observaTratamiento, a.tratamiento as tratamiento, nvl(a.tipo_anestesia,'N') as tipoAnestesia, nvl(a.presentacion_parto,'V') as presentacionParto, a.observa_presentacion as observaPresentacion, a.tipo_parto as tipoParto, nvl(a.episiotomia,'NO') as episiotomia, a.episografia as episografia, a.material_usado as materialUsado, nvl(a.tipo_instrumento,'E') as tipoInstrumento, a.forcep1 as forcep1, a.forcep2 as forcep2, nvl(a.indicacion,'PF') as indicacion, a.otras as otras, a.variedad_posicion as variedadPosicion, a.nivel_presenta as nivelPresenta, a.plano as plano, a.maniobras as maniobras, nvl(a.tipo_forcep,'K') as tipoForcep, a.cod_anestesia as codAnestesia, a.medico as medico, a.asp_liq as aspLiq, a.cant_liq as cantLiq, a.paridad_valor as paridadValor, a.paridad as paridad, a.control_prenatal as controlPrenatal,to_char(a.fecha_creacion,'dd/mm/yyyy') fechaCreacion,to_char(a.fecha_creacion,'hh12:mi:ss am') hora from tbl_sal_historia_obstetrica a, tbl_adm_medico b where a.pac_id="+pacId+" and a.codigo="+noAdmision+" and a.medico=b.codigo(+)";

cdo2 = SQLMgr.getData(sql);

//	Query de tactos
sql="select to_char(a.fecha_hist,'dd/mm/yyyy') as fechahist, a.cod_hist as codhist, a.secuencia as secuencia, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, a.cuello_dilata as cuellodilata, a.seg_inf as seginf, a.pre_pos_plan as preposplan, a.foco_fetal as focofetal, a.func_contrac as funccontrac, a.membr as membr, a.temp as temp, a.observacion as observacion from tbl_sal_hist_obst_tactos a, TBL_SAL_HISTORIA_OBSTETRICA b where b.pac_id="+pacId+" and a.pac_id="+pacId+" and a.cod_hist=b.codigo and a.pac_id=b.pac_id and a.cod_hist="+cod_Historia;

al = SQLMgr.getDataList(sql);

if(cdo2 == null)
{
//System.out.println("null null null ");
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
	int permission = 1;//0=no print no copy 1=only print 2=only copy 3=print copy
	boolean passRequired = false;
	boolean showUI = false;
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 13.0f;
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
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

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
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setFont(7, 1);
	pc.setTableHeader(2);//create de table header (3 rows) and add header to the table
	pc.setVAlignment(0);

	pc.setFont(7, 0);
	pc.addCols("Fecha:  "+cdo2.getColValue("fechaCreacion"),0,1);
		pc.addCols("Hora: "+cdo2.getColValue("hora"),0,4);
		pc.addCols("",0,13);
        pc.addCols("",0,13);

	pc.addBorderCols("Fecha Ultima Menstruación    Dia "+(cdo2.getColValue("dia")==null?"":cdo2.getColValue("dia"))+"/  Mes   "+(cdo2.getColValue("mes")==null?"":cdo2.getColValue("mes"))+"/ Año  "+(cdo2.getColValue("anio")==null?"":cdo2.getColValue("anio")),0,6,0.5f,0.0f,0.0f,0.0f,cHeight);

	pc.addBorderCols(" Edad Gestacional    "+(cdo2.getColValue("edadGesta")==null?"":cdo2.getColValue("edadGesta"))+"      Semanas",0,7,0.5f,0.0f,0.0f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.addBorderCols("PARIDAD: ",0,2,0.5f,0.0f,0.0f,0.0f,cHeight);
	pc.addBorderCols((cdo2.getColValue("gesta")==null?"":cdo2.getColValue("gesta"))+"   Gesta",0,1,0.5f,0.0f,0.0f,0.0f,cHeight);
	pc.addBorderCols((cdo2.getColValue("para")==null?"":cdo2.getColValue("para"))+"   Para",0,1,0.5f,0.0f,0.0f,0.0f,cHeight);
	pc.addBorderCols((cdo2.getColValue("aborto")==null?"":cdo2.getColValue("aborto"))+"   Aborto",0,3,0.5f,0.0f,0.0f,0.0f,cHeight);
	pc.addBorderCols((cdo2.getColValue("cesarea")==null?"":cdo2.getColValue("cesarea"))+"   Cesarea",0,4,0.5f,0.0f,0.0f,0.0f,cHeight);
	pc.addBorderCols(" ",0,2,0.5f,0.0f,0.0f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.addCols("EMBARAZO: ",0,2,cHeight);
	pc.addCols("Simple",2,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("embarazo") != null && cdo2.getColValue("embarazo").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addCols("Multiple",2,2,cHeight);
		pc.setVAlignment(1);
	pc.setFont(7, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("embarazo") != null && cdo2.getColValue("embarazo").trim().equals("M"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("   Numero:  "+(cdo2.getColValue("numeroHijo")==null?"":cdo2.getColValue("numeroHijo")),0,6,cHeight);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("TRABAJO DE PARTO ",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols("FECHA Y HORA DE INICIO    ",1,9,cHeight);
		pc.setVAlignment(1);
	pc.addCols("Espontàneo",0,1,cHeight);
	//pc.addBorderCols(" ",0,1);
	pc.setVAlignment(1);
	pc.setFont(7, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("trabajoParto") != null && cdo2.getColValue("trabajoParto").trim().equals("E"))
			pc.addInnerTableBorderCols("x",7,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addCols("Inducido",0,1,cHeight);
		pc.setVAlignment(1);
	pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("trabajoParto") != null && cdo2.getColValue("trabajoParto").trim().equals("I"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols("DIA",1,1,cHeight);
	pc.addBorderCols("MES",1,2,cHeight);
	pc.addBorderCols("AÑO",1,1,cHeight);
	pc.addBorderCols("HORA: "+cdo2.getColValue("horaIni"," "),1,5,0.5f,0.5f,0.0f,0.5f,cHeight);

	pc.addCols(" ",1,1,cHeight);
	pc.addCols(" ",1,1,cHeight);
	pc.addCols(" ",1,1,cHeight);
	pc.addCols(" ",1,1,cHeight);

	pc.addBorderCols(" "+(cdo2.getColValue("diaParto")==null?"":cdo2.getColValue("diaParto")),1,1,cHeight);
	pc.addBorderCols(" "+(cdo2.getColValue("mesParto")==null?"":cdo2.getColValue("mesParto")),1,2,cHeight);
	pc.addBorderCols(" "+(cdo2.getColValue("anioParto")==null?"":cdo2.getColValue("anioParto")),1,1,cHeight);
	pc.addCols("AM ",2,1,cHeight);
	pc.setVAlignment(1);
		pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ampmParto") != null && cdo2.getColValue("ampmParto").trim().equals("AM"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("/ PM ",2,1,cHeight);
	pc.setVAlignment(1);
		pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ampmParto") != null && cdo2.getColValue("ampmParto").trim().equals("PM"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols("  ",2,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("RUPTURA DE MEMBRANAS ",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols("DIA",1,1,cHeight);
	pc.addBorderCols("MES",1,2,cHeight);
	pc.addBorderCols("AÑO",1,1,cHeight);
	pc.addBorderCols("HORA: "+cdo2.getColValue("horaRuptura"," "),1,5,0.5f,0.5f,0.0f,0.5f,cHeight);

	pc.setVAlignment(1);
	pc.addCols("Espontàneo",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("rupturaMembrana") != null && cdo2.getColValue("rupturaMembrana").trim().equals("E"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addCols("Artificial",0,1,cHeight);
		pc.setVAlignment(1);
	pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("rupturaMembrana") != null && cdo2.getColValue("rupturaMembrana").trim().equals("A"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols(" "+(cdo2.getColValue("diaRuptura")==null?"":cdo2.getColValue("diaRuptura")),1,1,cHeight);
	pc.addBorderCols(" "+(cdo2.getColValue("mesRuptura")==null?"":cdo2.getColValue("mesRuptura")),1,2,cHeight);
	pc.addBorderCols(" "+(cdo2.getColValue("anioRuptura")==null?"":cdo2.getColValue("anioRuptura")),1,1,cHeight);
	pc.addCols("AM ",2,1,cHeight);
	pc.setVAlignment(1);
		pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ampmRuptura") != null && cdo2.getColValue("ampmRuptura").trim().equals("AM"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("/ PM ",2,1,cHeight);
	pc.setVAlignment(1);
		pc.setFont(4, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ampmRuptura") != null && cdo2.getColValue("ampmRuptura").trim().equals("PM"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols("  ",2,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addCols(" ",1,4,cHeight);
	pc.addBorderCols(" ",0,9,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("ALUMBRAMIENTO",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);
	pc.addCols((cdo2.getColValue("alumbramiento")==null?"":cdo2.getColValue("alumbramiento")),0,4);
	pc.addCols("Describa: "+(cdo2.getColValue("observ")==null?"":cdo2.getColValue("observ")),0,9);

	pc.addCols("Minutos para el Alumbramiento:",0,2,cHeight);
	pc.addCols((cdo2.getColValue("minutos")==null?"":cdo2.getColValue("minutos")),0,11,cHeight);

	pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);


	/*********DATOS ADICIONALES **************/

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("DATOS ADICIONALES",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.setFont(7, 0);
	pc.addBorderCols("SENSIBILIZACION",0,1,0.0f,0.0f,0.0f,0.0f,cHeight);
	pc.addBorderCols("Rh:",1,1,0.0f,0.0f,0.0f,0.0f,cHeight);

	pc.addBorderCols("SI",1,1,0.0f,0.0f,0.0f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("rh") != null && cdo2.getColValue("rh").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addBorderCols("NO",1,1,0.0f,0.0f,0.0f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("rh") != null && cdo2.getColValue("rh").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addBorderCols("ABO:",1,1,0.0f,0.0f,0.0f,0.0f,cHeight);
	pc.addBorderCols("SI",1,1,0.0f,0.0f,0.0f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("abo") != null && cdo2.getColValue("abo").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);


	pc.addBorderCols("NO",1,1,0.0f,0.0f,0.0f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("abo") != null && cdo2.getColValue("abo").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.addCols(" ",0,2);

	pc.addCols("Serología-LUES:",2,2);
	pc.addCols("Positivo",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("serologia_lues") != null && cdo2.getColValue("serologia_lues").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Negativo",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("serologia_lues") != null && cdo2.getColValue("serologia_lues").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols(" ",0,8);

	pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("PATOLOGIA",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.addCols(" ",0,2);

	pc.addCols("SI",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("pat") != null && cdo2.getColValue("pat").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("NO",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("pat") != null && cdo2.getColValue("pat").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Describa:"+(cdo2.getColValue("patdesc")!=null && cdo2.getColValue("pat").trim().equals("S")?cdo2.getColValue("patdesc"):"") ,0,7);

    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.addCols("ELECTROFORESIS HB:",0,2);
	pc.addCols((cdo2.getColValue("ELECTROFORESIS_HB")!=null?cdo2.getColValue("ELECTROFORESIS_HB"):"") ,0,5);
	pc.addCols("TOXOPLASMOSIS:",0,2);
	pc.addCols((cdo2.getColValue("TOXOPLASMOSIS")!=null?cdo2.getColValue("TOXOPLASMOSIS"):"") ,0,4);

	pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("PATOLOGIA EN HIJOS ANTERIORES",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.addCols(" ",0,2);

	pc.addCols("SI",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("pat_ant") != null && cdo2.getColValue("pat_ant").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("NO",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("pat_ant") != null && cdo2.getColValue("pat_ant").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Describa:"+(cdo2.getColValue("pat_ant_desc")!=null && cdo2.getColValue("pat_ant").trim().equals("S")?cdo2.getColValue("pat_ant_desc"):"") ,0,7);
    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);


	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("ANOMALÍAS CONGÉNITAS EN HIJOS ANTERIORES",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.addCols(" ",0,2);

	pc.addCols("SI",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ANOMALIA_CONGENITA") != null && cdo2.getColValue("ANOMALIA_CONGENITA").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("NO",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ANOMALIA_CONGENITA") != null && cdo2.getColValue("ANOMALIA_CONGENITA").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Describa:"+(cdo2.getColValue("ANOMALIA_CONG_ESPECIFICAR")!=null && cdo2.getColValue("ANOMALIA_CONGENITA").trim().equals("S")?cdo2.getColValue("ANOMALIA_CONG_ESPECIFICAR"):"") ,0,7);
    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);


	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("ECOGRAFIA",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.addCols(" ",0,2);

	pc.addCols("Normal",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ecografia") != null && cdo2.getColValue("ecografia").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Anormal",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ecografia") != null && cdo2.getColValue("ecografia").trim().equals("A"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Horas Labor: "+(cdo2.getColValue("horas_labor")!=null?cdo2.getColValue("horas_labor"):"") ,0,7);
    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("MONITOREO",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.addCols(" ",0,2);

	pc.addCols("SI",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("MONITOREO") != null && cdo2.getColValue("MONITOREO").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("NO",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("MONITOREO") != null && cdo2.getColValue("MONITOREO").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("",0,7);
    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("SIGNOS DE SUFRIMIENTO FETAL",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.addCols(" ",0,2);

	pc.addCols("SI",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("SIGNO_SUFRIMIENTO_FETAL") != null && cdo2.getColValue("SIGNO_SUFRIMIENTO_FETAL").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("NO",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("SIGNO_SUFRIMIENTO_FETAL") != null && cdo2.getColValue("SIGNO_SUFRIMIENTO_FETAL").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Ignorado",2,2);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("SIGNO_SUFRIMIENTO_FETAL") != null && cdo2.getColValue("SIGNO_SUFRIMIENTO_FETAL").trim().equals("I"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("",0,4);
    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);


	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("CAUSAS INTERVENCION",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" "+(cdo2.getColValue("CAUSAS_INTERVENCION")!=null?cdo2.getColValue("CAUSAS_INTERVENCION"):""),0,9);

	pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("DROGAS",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.addCols(" ",0,2);

	pc.addCols("SI",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("DROGAS") != null && cdo2.getColValue("DROGAS").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("NO",2,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("DROGAS") != null && cdo2.getColValue("DROGAS").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);

	pc.addCols("Nombre Droga: "+(cdo2.getColValue("DROGAS_NOMBRE") != null && cdo2.getColValue("DROGAS").trim().equals("S")?cdo2.getColValue("DROGAS_NOMBRE"):""),0,5);

    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.addCols("TIEMPO ANTEPARTO DOSIS:",2,7);
	pc.addCols((cdo2.getColValue("DROGAS_TIEMPO_ANTEPARTO_DOSIS") != null?cdo2.getColValue("DROGAS_TIEMPO_ANTEPARTO_DOSIS"):""),0,6);


    pc.addBorderCols(" ",0,4,0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.addBorderCols(" ",0,9,0.0f,0.5f,0.0f,0.0f,cHeight);

	/*********LIQUIDOS AMNIOTICOS **************/
	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("LIQUIDO AMNIOTICO ",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols("CANTIDAD",1,2,cHeight);
	pc.addBorderCols("ASPECTO",1,7,0.5f,0.5f,0.0f,0.5f,cHeight);


	pc.addCols("  ",0,4,cHeight);
	pc.addBorderCols(" ",0,9,0.5f,0.0f,0.0f,0.0f,cHeight);

	pc.addCols("  ",0,4,cHeight);
	pc.setFont(7, 0);
	//pc.addBorderCols(" ",0,dHeader.size(),0.5f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols("ESCASO",0,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cantidadLiquido") != null && cdo2.getColValue("cantidadLiquido").trim().equals("E"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols("CLARO: SIN GRUMOS ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("CS"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols("MECONIAL: FLUIDO ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("MF"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addCols("  ",0,4,cHeight);
	pc.setFont(7, 0);
	pc.addBorderCols("NORMAL",0,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CantidadLiquido") != null && cdo2.getColValue("CantidadLiquido").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols("CLARO: CON GRUMOS ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("CC"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols("MECONIAL: ESPESO ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("ME"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addCols("  ",0,4,cHeight);
	pc.setFont(7, 0);
	pc.addBorderCols("ABUNDANTE",0,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CantidadLiquido") != null && cdo2.getColValue("CantidadLiquido").trim().equals("A"))
			pc.addInnerTableBorderCols(" ",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols("HEMÀTICO: LEVE ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("HM"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols("AMARILLO ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("AR"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addCols("  ",0,4,cHeight);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols("HEMORRÀGICO ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("HE"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols("OSCURO ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("OS"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();
	pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addCols("  ",0,4,cHeight);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols("PURULENTO ",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("aspectoLiquido") != null && cdo2.getColValue("aspectoLiquido").trim().equals("PU"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols("  ",0,3,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols(" ",1,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addCols(" ",0,4,cHeight);
	pc.addBorderCols(" ",0,9,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.addCols("  ",0,dHeader.size());
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.addCols("  ",0,dHeader.size());

	pc.addCols("  ",0,2,cHeight);
	pc.addBorderCols("FECHA Y HORA DE PARTO",1,8,cHeight);
	pc.addCols("  ",0,3,cHeight);

	pc.addCols("  ",0,2,cHeight);
	pc.addBorderCols("DIA",1,1,cHeight);
	pc.addBorderCols("MES",1,1,cHeight);
	pc.addBorderCols("AÑO",1,1,cHeight);
	pc.addBorderCols("HORA",1,5,cHeight);
	pc.addCols("  ",0,3,cHeight);


	pc.addCols("  ",0,2,cHeight);
	pc.addBorderCols(""+(cdo2.getColValue("diaPara")==null?"":cdo2.getColValue("diaPara")),1,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols(""+(cdo2.getColValue("mesPara")==null?"":cdo2.getColValue("mesPara")),1,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols(""+(cdo2.getColValue("anioPara")==null?"":cdo2.getColValue("anioPara")),1,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols(""+(cdo2.getColValue("horaPara")==null?"":cdo2.getColValue("horaPara")),2,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.addBorderCols(" AM ",2,1,0.0f,0.0f,0.0f,0.0f,cHeight);

	pc.setVAlignment(1);
		pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ampmPara") != null && cdo2.getColValue("ampmPara").trim().equals("AM"))
			pc.addInnerTableBorderCols(" ",1,1,5.0f,5.0f,5.0f,5.0f);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols(" /PM ",2,1,0.0f,0.0f,0.0f,0.0f,cHeight);

	pc.setVAlignment(1);
		pc.setFont(4, 0);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ampmPara") != null && cdo2.getColValue("ampmPara").trim().equals("PM"))
			pc.addInnerTableBorderCols(" ",1,1,5.0f,5.0f,5.0f,5.0f);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols("",1,3,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.addCols(" ",0,2,cHeight);
	pc.addBorderCols(" ",0,8,0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.addCols(" ",0,3,cHeight);
	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("TACTOS ",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9,cHeight);

		pc.addBorderCols("DIA",1,1);
		pc.addBorderCols("HORA",1,1);
		pc.addBorderCols("CUELLO Y DILATAC",1,1);
		pc.addBorderCols("SEGMENTO INFERIOR",1,1);
		pc.addBorderCols("PRENTAC. POS Y PLANOS",1,1);
		pc.addBorderCols("FOCO FETAL",1,2);
		pc.addBorderCols("FUNCION CONTRAC",1,1);
		pc.addBorderCols("MEMBR",1,1);
		pc.addBorderCols("TEMP",1,1);
		pc.addBorderCols("OBSERVACION",0,3);

	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);



		pc.addBorderCols(""+cdo.getColValue("fecha"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("hora"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("cuelloDilata"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("segInf"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("prePosPlan"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("focoFetal"),1,2,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("funcContrac"),1,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+cdo.getColValue("membr"),1,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+cdo.getColValue("temp"),1,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+cdo.getColValue("observacion"),0,3,0.5f,0.0f,0.5f,0.5f);


		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols(" ",1,dHeader.size());

	pc.addCols(" ",0,dHeader.size());

	pc.addBorderCols("OBSERVACIONES",0,5);
	pc.addBorderCols("TRATAMIENTO",0,8);

	pc.addBorderCols(" "+(cdo2.getColValue("observaTratamiento")==null?"":cdo2.getColValue("observaTratamiento")),0,5,0.5f,0.0f,0.0f,0.5f);
	pc.addBorderCols(" "+(cdo2.getColValue("tratamiento")==null?"":cdo2.getColValue("tratamiento") ),0,8,0.5f,0.0f,0.0f,0.0f);
	for (int j=0; j<4; j++)
	{
		pc.addBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.5f);
		pc.addBorderCols(" ",0,8,0.5f,0.0f,0.0f,0.0f);
	}

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("ANESTESIA ",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols("SI",2,1,0.0f,0.0f,0.0f,0.0f);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoAnestesia") != null && cdo2.getColValue("tipoAnestesia").trim().equals("S"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addBorderCols("NO",2,1,0.0f,0.0f,0.0f,0.0f);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoAnestesia") != null && cdo2.getColValue("tipoAnestesia").trim().equals("N"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols(" ",0,5);

	//pc.addBorderCols(" ",0,13,cHeight);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols("LOCAL ",0,1);

	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("1"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("BLOQUEO PUDENDO",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("2"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("GENERAL",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("3"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("DISOCIATIVA",0,2);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("4"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();


	pc.addCols("",0,4);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols("RAQUIDEA ",0,1);

	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("5"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("EPIDURAL",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("6"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("SIMPLE",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("7"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("CONTINUA",0,2);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("CodAnestesia") != null && cdo2.getColValue("CodAnestesia").trim().equals("8"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();


	pc.addCols("",0,4);



	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("PARTO ",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols("VARIEDAD",1,9,cHeight);

	pc.addCols("PRESENTACION ",0,2);
	pc.addCols("VERTICE ",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("PresentacionParto") != null && cdo2.getColValue("PresentacionParto").trim().equals("V"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("  ",0,9);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols(" ",0,2);
	pc.addCols("PODALICA ",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("PresentacionParto") != null && cdo2.getColValue("PresentacionParto").trim().equals("P"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("  ",0,9);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);



	pc.addCols(" ",0,2);
	pc.addCols("CARA ",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("PresentacionParto") != null && cdo2.getColValue("PresentacionParto").trim().equals("C"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("  ",0,9);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols(" ",0,2);
	pc.addCols("BREGMA ",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("PresentacionParto") != null && cdo2.getColValue("PresentacionParto").trim().equals("B"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("  ",0,9);

	pc.setFont(0, 0);
	pc.addCols("",0,dHeader.size());
	pc.setFont(7, 0);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("TIPO DE PARTO ",0,4,cHeight,Color.GRAY);
	pc.setFont(7, 0);
	pc.addBorderCols(" ",0,9);

	pc.setFont(7, 0);
	pc.addBorderCols("1.  NORMAL ",0,dHeader.size(),cHeight);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols("EPISIOTAMIA  NO",0,1);

	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("episiotomia") != null && cdo2.getColValue("episiotomia").trim().equals("NO"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("MEDIA",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("episiotomia") != null && cdo2.getColValue("episiotomia").trim().equals("ME"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("OBLICUA DERECHA",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("episiotomia") != null && cdo2.getColValue("episiotomia").trim().equals("OD"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("OBLICUA IZQUIERDA",0,2);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("episiotomia") != null && cdo2.getColValue("episiotomia").trim().equals("OI"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("",0,4);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols("EPISOGRAFIA: (Describa)    "+(cdo2.getColValue("episografia")==null?"":cdo2.getColValue("episografia")),0,dHeader.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 1);

	pc.addCols(" ",0,dHeader.size());
	pc.addBorderCols("",0,dHeader.size(),0.5f,0.0f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols("MATERIAL USADO: (Describa)     "+(cdo2.getColValue("materialUsado")==null?"":cdo2.getColValue("materialUsado")),0,dHeader.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 1);
	pc.addCols(" ",0,dHeader.size());

	pc.setFont(7, 0);
	pc.addBorderCols("2.  INSTRUMENTAL ",0,dHeader.size());


	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols("ESPATULAS",0,1);

	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoInstrumento") != null && cdo2.getColValue("tipoInstrumento").trim().equals("E"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("FORCEPS",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoInstrumento") != null && cdo2.getColValue("tipoInstrumento").trim().equals("F"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("1  "+(cdo2.getColValue("forcep1")==null?"":cdo2.getColValue("materialUsado")),0,2);
	pc.addCols("2  "+(cdo2.getColValue("forcep2")==null?"":cdo2.getColValue("forcep2")),0,2);
	pc.addCols("",0,5);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);


	pc.setFont(7, 0);
	pc.addCols("  ",0,dHeader.size());
	pc.addCols("INDICACION ",0,dHeader.size());

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols("PROFILÀCTICO",0,1);

	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("indicacion") != null && cdo2.getColValue("indicacion").trim().equals("PF"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("DISTOCIA DE ROTACION",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("indicacion") != null && cdo2.getColValue("indicacion").trim().equals("DR"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("DETENCION DEL MÒVIL",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("indicacion") != null && cdo2.getColValue("indicacion").trim().equals("DM"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("CABEZA ULTIMA",0,2);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("indicacion") != null && cdo2.getColValue("indicacion").trim().equals("CU"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("",0,5);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols("OTRAS: (Describa)    "+(cdo2.getColValue("otras")==null?"":cdo2.getColValue("otras")),0,dHeader.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols("VARIEDAD DE POSICIÒN:    "+(cdo2.getColValue("variedadPosicion")==null?"":cdo2.getColValue("variedadPosicion")),0,dHeader.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols(" ",0,dHeader.size());
	/*pc.addCols("NIVEL DE LA PRESENTACION"+cdo2.getColValue("variedadPosicion"),0,5);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 1);*/

	pc.addBorderCols("NIVEL DE LA PRESENTACION",0,5);
	pc.addBorderCols("PLANO",0,8);

	pc.addBorderCols(" "+(cdo2.getColValue("nivelPresenta")==null?"":cdo2.getColValue("nivelPresenta")),0,5,0.5f,0.0f,0.0f,0.5f);
	pc.addBorderCols(" "+(cdo2.getColValue("plano")==null?"":cdo2.getColValue("plano")),0,8,0.5f,0.0f,0.0f,0.0f);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols(" ",0,dHeader.size());

	/**--------------------------------------------*/
	pc.setFont(7, 0);
	//pc.addBorderCols("OTRAS MANIOBRAS: ",0,dHeader.size(),cHeight);
	pc.addBorderCols("OTRAS MANIOBRAS:   " ,0,dHeader.size(),0.5f,0.5f,0.0f,0.0f);



	pc.addCols("KRISTELLER",0,1);

	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoForcep") != null && cdo2.getColValue("tipoForcep").trim().equals("K"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("MORICEAUX",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoForcep") != null && cdo2.getColValue("tipoForcep").trim().equals("M"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("BRACHT",0,1);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoForcep") != null && cdo2.getColValue("tipoForcep").trim().equals("B"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("ROJAS",0,2);
	pc.setVAlignment(1);
		pc.setFont(7, 1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("tipoForcep") != null && cdo2.getColValue("tipoForcep").trim().equals("R"))
			pc.addInnerTableBorderCols("x",1,1);
	else pc.addInnerTableBorderCols(" ",1,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7, 0);
	pc.resetVAlignment();

	pc.addCols("",0,4);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>