<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admin.Properties"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

CommonDataObject cdo, cdoPacData  = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String exp = request.getParameter("exp");
String edad = request.getParameter("edad");
String edadMes = request.getParameter("edad_mes");
String sexo = request.getParameter("sexo");
String cds = request.getParameter("cds");
String codigo = request.getParameter("codigo");

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(exp == null) exp = "";
if(edad == null) edad = "0";
if(edadMes == null) edadMes = "0";
if(sexo == null) sexo = "";
if(cds == null) cds = "0";
if(codigo == null) codigo = "1";

sql = "select to_char(FECHA,'dd/mm/yyyy') as FECHA, to_char(HORA, 'hh12:mi:ss am') as HORA, OBSERVACION, DOLENCIA_PRINCIPAL, MOTIVO_HOSPITALIZACION, ALERGICO_A, to_char(HORA,'hh12:mi:ss am') AS HORA, usuario_creacion, usuario_modificacion from TBL_SAL_PADECIMIENTO_ADMISION where pac_id = "+pacId+" and secuencia = "+noAdmision;

cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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

float width = 72 * 8.5f; 
float height = 72 * 11f;
boolean isLandscape = false;
float leftRightMargin = 25.0f;
float topMargin = 13.5f;
float bottomMargin = 13.5f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subtitle = "HISTORIA CLÍNICA NEONATO";
String xtraSubtitle = desc;
	
boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 5;
float cHeight = 13.0f;
    
CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
if (paramCdo == null) {
  paramCdo = new CommonDataObject();
  paramCdo.addColValue("is_landscape","N");
}
if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
  cdoPacData.addColValue("is_landscape",""+isLandscape);
}

PdfCreator pc = null;
boolean isUnifiedExp = false;
	
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
		
if(pc == null){
  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
  
  isUnifiedExp=true;
}

Vector dHeader = new Vector();
dHeader.addElement("30"); 
dHeader.addElement("20");
dHeader.addElement("20");
dHeader.addElement("30");
		
pc.setNoColumnFixWidth(dHeader);
pc.createTable(true);

pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
pc.setTableHeader(1);
		
issi.admin.Properties propL = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_cuestionarios where pac_id = "+pacId+" and admision = "+noAdmision+")");
if (propL == null) propL = new issi.admin.Properties();
    
CommonDataObject cdoL = SQLMgr.getData("select formulario from tbl_sal_nota_eval_enf_urg where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo_nota = 'NEEU'");
if (cdoL == null) cdoL = new CommonDataObject();

pc.setFont(11,1);
pc.addCols("PACIENTE VULNERABLE: "+(!cdoL.getColValue("formulario"," ").trim().equals("") && !cdoL.getColValue("formulario"," ").trim().equals("15")?"    [X] SI    [   ] NO":"        [   ] SI     [X] NO"),0,dHeader.size());
    
pc.setFont(11,0);
if (Integer.parseInt(edad) == 0 && Integer.parseInt(edadMes) <= 3) {
    pc.addCols("  -> PACIENTE NEONATO",0,dHeader.size());
}

ArrayList alL = SQLMgr.getDataList("select descripcion from tbl_sal_riesgo_vulnerab where codigo in("+cdoL.getColValue("formulario","-1")+")");
for (int l = 0; l<alL.size(); l++) {
    pc.setFont(11,0);
    cdoL = (CommonDataObject) alL.get(l);
    pc.addCols("     -> "+cdoL.getColValue("descripcion"," "),0,dHeader.size());
}
pc.setFont(11,1);
pc.addCols(" ",0,dHeader.size());
    
pc.addCols("VOLUNDAD MEDICA ANTICIPADA: "+(propL.getProperty("voluntades_anticipadas")!=null&&propL.getProperty("voluntades_anticipadas").equals("S")?"    [X] SI    [   ] NO":"    [   ] SI     [X] NO"),0,dHeader.size());
pc.addCols("RCP: "+(propL.getProperty("no_no0")!=null&&propL.getProperty("no_no0").equals("0")?"    [   ] SI     [X] NO":"        [X] SI    [   ] NO"),0,dHeader.size());

ArrayList alT = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_expediente_secciones where codigo in(3, 181, 182, 49,89) order by codigo ");
Hashtable iT = new Hashtable();
for (int t = 0; t < alT.size(); t++) {
  CommonDataObject cdoT = (CommonDataObject) alT.get(t);
  iT.put(cdoT.getColValue("codigo"), cdoT.getColValue("descripcion"));
}

// ANTECEDENTE GINECO-OBSTETRICO (3)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("3"), 0, dHeader.size(),Color.gray);

sql  ="select CODIGO, GESTACION, PARTO, ABORTO, CESAREA, MENARCA, nvl(to_char(FUM,'dd/mm/yyyy'),' ') as FUM, nvl(CICLO,' ') CICLO, INICIO_SEXUAL,CONYUGES, nvl(to_char(FECHA_PAP,'dd/mm/yyyy'),' ') as FECHA_PAP, nvl(METODO,' ') METODO, nvl(decode(SUSTANCIAS,'S','SI','N','NO'),' ') SUSTANCIAS, nvl(OTROS,' ') OTROS, nvl(OBSERVACION,' ') OBSERVACION, ECTOPICO from TBL_SAL_ANTECEDENTE_GINECOLOGO where pac_id="+pacId+" and nvl(admision, "+noAdmision+") = "+noAdmision;

cdo  = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

Vector vTbl14 = new Vector();
vTbl14.addElement(".40");
vTbl14.addElement(".10");
vTbl14.addElement(".40");
vTbl14.addElement(".10");

pc.setNoColumnFixWidth(vTbl14);
pc.createTable("tbl14");

pc.setFont(8,1);
pc.addBorderCols("DESCRIPCION",1,1);
pc.addBorderCols("VALOR",1,1);
pc.addBorderCols("DESCRIPCION",1,1);
pc.addBorderCols("VALOR",1,1);

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
pc.addCols("CICLO MENSTRUAL:",2,1); // 2
pc.addBorderCols(cdo.getColValue("CICLO"),0,1);
pc.addBorderCols("ECTÓPICO:",2,1,0f,0f,1f,0f); //5
pc.addBorderCols(cdo.getColValue("ECTOPICO"),1,1);
pc.addCols("METODO DE PLANIFICACION:",2,1);
pc.addBorderCols(cdo.getColValue("METODO"),0,1);

pc.addBorderCols("MENARCA",2,1,0f,0f,1f,0f);
pc.addBorderCols(cdo.getColValue("MENARCA"),1,1);
pc.addCols(" EXPOSICIÓN A TOXICOS Y SUSTANCIAS QUIMICAS O RADIOACTIVAS",2,1);
pc.addBorderCols(cdo.getColValue("SUSTANCIAS"),0,1,0f,1f,1f,1f);

pc.addBorderCols("I.V.S.A.",2,1,1f,0f,1f,0f);
pc.addBorderCols(cdo.getColValue("INICIO_SEXUAL"),1,1);
pc.addBorderCols(" ",2,1,1f,0f,0f,0f);

pc.setVAlignment(2);
pc.addBorderCols("",0,1,1f,0f,1f,1f);
pc.addCols(" ",0,vTbl14.size());
pc.addBorderCols("OBSERVACION: "+cdo.getColValue("OBSERVACION"),0,2);
pc.addBorderCols("OTROS: "+cdo.getColValue("OTROS"),0,2);

pc.useTable("main");
pc.addTableToCols("tbl14",0,dHeader.size());
// END ANTECEDENTE GINECO-OBSTETRICO (3)

//HOJA DE LABOR 1 (181)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("181"), 0, dHeader.size(),Color.gray);

Vector vTbl20 = new Vector();
vTbl20.addElement(".11");
vTbl20.addElement(".09");
vTbl20.addElement(".10");
vTbl20.addElement(".10");
vTbl20.addElement(".10");
vTbl20.addElement(".06");
vTbl20.addElement(".05");
vTbl20.addElement(".09");
vTbl20.addElement(".04");
vTbl20.addElement(".04");
vTbl20.addElement(".09");
vTbl20.addElement(".09");
vTbl20.addElement(".04");

Vector infoCol = new Vector();
infoCol.addElement(".16");
infoCol.addElement(".14");
infoCol.addElement(".11");
infoCol.addElement(".10");
infoCol.addElement(".14");
infoCol.addElement(".35");
Vector setBox = new Vector();
setBox.addElement("8");

String horasLabor = "";

sql="select decode(b.APELLIDO_DE_CASADA,null, b.PRIMER_APELLIDO||' '||b.SEGUNDO_APELLIDO, b.APELLIDO_DE_CASADA)||' '|| b.PRIMER_NOMBRE||' '||b.SEGUNDO_NOMBRE as nombreMedico, a.codigo as codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.fecha_u_r,'dd/mm/yyyy') as fechaUR, to_char(a.fecha_u_r,'dd') as dia,to_char(a.fecha_u_r,'mm') as mes,to_char(a.fecha_u_r,'yyyy') as anio, a.edad_gesta as edadGesta, a.gesta as gesta, a.para as para, a.cesarea as cesarea, a.aborto as aborto, nvl(a.embarazo,'S') as embarazo, a.numero_hijo as numeroHijo, nvl(a.trabajo_parto,'E') as trabajoParto, to_char(a.fecha_ini,'dd/mm/yyyy') as fechaIni, to_char(a.hora_ini,'hh12:mi:ss am') as horaIniFull,to_char(a.fecha_ini,'dd') as diaParto,to_char(a.fecha_ini,'mm') as mesParto,to_char(a.fecha_ini,'yyyy') as anioParto,to_char(a.hora_ini,'hh12:mi:ss') as horaIni,to_char(a.hora_ini,'AM') as ampmParto, nvl(a.ruptura_membrana,'E') as rupturaMembrana, to_char(a.fecha_ruptura,'dd/mm/yyyy') as fechaRuptura, to_char(a.fecha_ruptura,'dd') as diaRuptura,to_char(a.fecha_ruptura,'mm') as mesRuptura, to_char(a.fecha_ruptura,'yyyy') as anioRuptura,to_char(a.hora_ruptura,'hh12:mi:ss') as  horaRuptura, to_char(a.hora_ruptura,'AM') as ampmRuptura, to_char(a.hora_ruptura,'hh12:mi:ss am') as horaRupturaFull, decode(a.ALUMBRAMIENTO,'E','ESPONTANEO','AR','ARTIFICIAL','ME','MANIOBRAS EXTRERNAS','EXTRACCION MANUAL DE ANEXOS','CO','COMPLETA') alumbramiento, a.observ, a.minutos, a.sensibilizacion_rh rh, a.sensibilizacion_abo abo, a.serologia_lues, a.patologia pat, a.patologia_espec patdesc, a.ELECTROFORESIS_HB, a.TOXOPLASMOSIS, a.PATOLOGIA_HIJOS_ANT pat_ant, a.PATOLOGIA_HIJOS_ANT_ESPEC pat_ant_desc, a.ANOMALIA_CONGENITA, a.ANOMALIA_CONG_ESPECIFICAR, a.ecografia, a.horas_labor, a.MONITOREO, a.SIGNO_SUFRIMIENTO_FETAL, a.CAUSAS_INTERVENCION, a.DROGAS, a.DROGAS_NOMBRE, a.DROGAS_TIEMPO_ANTEPARTO_DOSIS, /*datos adicionales*/ /*tab 1*/nvl(a.cantidad_liquido,'N') as cantidadLiquido, nvl(a.aspecto_liquido,'CS') as aspectoLiquido, to_char(a.fecha_parto,'dd/mm/yyyy') as fechaParto, to_char(a.fecha_parto,'dd') as diaPara,to_char(a.fecha_parto,'mm') as mesPara,to_char(a.fecha_parto,'yyyy') as anioPara,   to_char(a.hora_parto,'hh12:mi:ss') as horaPara,to_char(a.hora_parto,'AM') as ampmPara , to_char(a.hora_parto,'hh12:mi:ss am') as horaParto/*tab 2*/, a.dia_tacto as diaTacto, to_char(a.hora_tacto,'hh12:mi:ss am') as horaTacto /*tab 3*/, a.cuello_dil as cuelloDil, a.segmento as segmento, a.planos as planos, a.foco as foco, a.funcion as funcion, a.membrana as membrana, a.temperatura as temperatura, a.observa_tacto as observaTacto, a.observa_tratamiento as observaTratamiento, a.tratamiento as tratamiento, nvl(a.tipo_anestesia,'N') as tipoAnestesia, nvl(a.presentacion_parto,'V') as presentacionParto, a.observa_presentacion as observaPresentacion, a.tipo_parto as tipoParto, nvl(a.episiotomia,'NO') as episiotomia, a.episografia as episografia, a.material_usado as materialUsado, nvl(a.tipo_instrumento,' ') as tipoInstrumento, a.forcep1 as forcep1, a.forcep2 as forcep2, nvl(a.indicacion,'PF') as indicacion, a.otras as otras, a.variedad_posicion as variedadPosicion, a.nivel_presenta as nivelPresenta, a.plano as plano, a.maniobras as maniobras, nvl(a.tipo_forcep,'K') as tipoForcep, a.cod_anestesia as codAnestesia, a.medico as medico, a.asp_liq as aspLiq, a.cant_liq as cantLiq, a.paridad_valor as paridadValor, a.paridad as paridad, a.control_prenatal as controlPrenatal,to_char(a.fecha_creacion,'dd/mm/yyyy') fechaCreacion,to_char(a.fecha_creacion,'hh12:mi:ss am') hora, a.tipo_sangre as tipoSangre, a.presion_arterial presionArterial, nvl(a.forma_terminacion,' ') as formaTerminacion from tbl_sal_historia_obstetrica_m a, tbl_adm_medico b where a.pac_id="+pacId+" and a.codigo="+noAdmision+" and a.medico=b.codigo(+)";

CommonDataObject cdo2 = SQLMgr.getData(sql);
if (cdo2 == null) cdo2 = new CommonDataObject();

//	Query de tactos
sql="select to_char(a.fecha_hist,'dd/mm/yyyy') as fechahist, a.cod_hist as codhist, a.secuencia as secuencia, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, a.cuello_dilata as cuellodilata, a.seg_inf as seginf, a.pre_pos_plan as preposplan, a.foco_fetal as focofetal, a.func_contrac as funccontrac, a.membr as membr, a.temp as temp, a.observacion as observacion, a.presion_arterial presionArterial, decode(a.tipo_parto,'V','VAGINAL','C','CESAREA') tipoParto, a.motivo_cesarea motivoCesarea from tbl_sal_hist_obst_tactos_m a, TBL_SAL_HISTORIA_OBSTETRICA_M b where b.pac_id="+pacId+" and a.pac_id="+pacId+" and a.cod_hist=b.codigo and a.pac_id=b.pac_id and a.cod_hist="+cdo2.getColValue("codigo", "0");

al = SQLMgr.getDataList(sql);

pc.setNoColumnFixWidth(vTbl20);
pc.createTable("tbl20");

pc.setFont(8, 1);
pc.addCols("Fecha:  "+cdo2.getColValue("fechaCreacion"),0,1);
pc.addCols("Hora: "+cdo2.getColValue("hora"),0,4);
pc.addCols("",0,vTbl20.size());
pc.addCols("",0,vTbl20.size());

pc.addBorderCols("GENERALES PARTO",0,vTbl20.size(),cHeight);

pc.addBorderCols("Fecha Ultima Menstruación    Dia "+(cdo2.getColValue("dia")==null?"":cdo2.getColValue("dia"))+"/  Mes   "+(cdo2.getColValue("mes")==null?"":cdo2.getColValue("mes"))+"/ Año  "+(cdo2.getColValue("anio")==null?"":cdo2.getColValue("anio")),0,6,0.5f,0.0f,0.0f,0.0f,cHeight);

pc.addBorderCols(" Edad Gestacional    "+(cdo2.getColValue("edadGesta")==null?"":cdo2.getColValue("edadGesta"))+"      Semanas",0,7,0.5f,0.0f,0.0f,0.0f,cHeight);
pc.addBorderCols("No. de controles Pre-natales: "+cdo2.getColValue("controlPrenatal"," "),0,vTbl20.size(),0.5f,0.0f,0.0f,0.0f,cHeight);
pc.addBorderCols("Tipo Sangre: "+cdo2.getColValue("tipoSangre"," "),0,vTbl20.size(),0.5f,0.0f,0.0f,0.0f,cHeight);
pc.addBorderCols("Presión Arterial: "+cdo2.getColValue("presionArterial"," "),0,vTbl20.size(),0.5f,0.0f,0.0f,0.0f,cHeight);

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
pc.addBorderCols(" ",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f,cHeight);


// dHeader

pc.setFont(7, 1);
	pc.addBorderCols("TRABAJO DE PARTO ",0,4,cHeight);
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

//dHeader
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

	pc.setFont(7, 1);
	pc.addBorderCols("RUPTURA DE MEMBRANAS ",0,4,cHeight);
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


	// dHeader
	pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);


	/*********DATOS ADICIONALES **************/

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("DATOS ADICIONALES",0,13,cHeight,Color.GRAY);

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

	pc.setFont(7, 1);
	pc.addBorderCols("PATOLOGIA",0,4,cHeight);
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

	pc.setFont(7, 1);
	pc.addBorderCols("PATOLOGIA EN HIJOS ANTERIORES",0,4,cHeight);
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


	pc.setFont(7, 1);
	pc.addBorderCols("ANOMALÍAS CONGÉNITAS EN HIJOS ANTERIORES",0,4,cHeight);
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


	pc.setFont(7, 1);
	pc.addBorderCols("ECOGRAFIA",0,4,cHeight);
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

	//pc.addCols("Horas Labor: "+(cdo2.getColValue("horas_labor")!=null?cdo2.getColValue("horas_labor"):"") ,0,7);
	pc.addCols("" ,0,7);
    pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);

	pc.setFont(7, 1);
	pc.addBorderCols("MONITOREO",0,4,cHeight);
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

	pc.setFont(7, 1);
	pc.addBorderCols("SIGNOS DE SUFRIMIENTO FETAL",0,4,cHeight);
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


	pc.setFont(7, 1);
	pc.addBorderCols("CAUSAS INTERVENCION",0,4,cHeight);
	pc.setFont(7, 0);
	pc.addBorderCols(" "+(cdo2.getColValue("CAUSAS_INTERVENCION")!=null?cdo2.getColValue("CAUSAS_INTERVENCION"):""),0,9);

	pc.addBorderCols(" ",0,13,0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.setFont(7, 1);
	pc.addBorderCols("DROGAS",0,4,cHeight);
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
    pc.addBorderCols("LIQUIDO AMNIOTICO ",0,13,cHeight,Color.GRAY);

	pc.addCols("",0,4,cHeight);
	pc.setFont(7, 0);
	pc.addBorderCols("CANTIDAD",1,2,cHeight);
	pc.addBorderCols("ASPECTO",1,7,0.5f,0.5f,0.0f,0.5f,cHeight);


	pc.addCols("  ",0,4,cHeight);
	pc.addBorderCols(" ",0,9,0.5f,0.0f,0.0f,0.0f,cHeight);

	pc.addCols("  ",0,4,cHeight);
	pc.setFont(7, 0);
	//pc.addBorderCols(" ",0,vTbl20.size(),0.5f,0.0f,0.5f,0.0f,cHeight);
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

	pc.addCols("  ",0,vTbl20.size());
	pc.addBorderCols(" ",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.addBorderCols(" ",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.addCols("  ",0,vTbl20.size());

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

    /*
    pc.addCols("", 0, 13);
    pc.addBorderCols("FORMA TERMINACION DE PARTO",0,2);
    pc.addBorderCols(cdo2.getColValue("formaTerminacion"),0,11);
    */

	pc.addCols(" ",0,2,cHeight);
	pc.addBorderCols(" ",0,8,0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.addCols(" ",0,3,cHeight);

	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("TACTOS ",0,13,cHeight,Color.GRAY);
	pc.setFont(7, 0);

		pc.addBorderCols("DIA",1,1);
		pc.addBorderCols("HORA",1,1);
		pc.addBorderCols("CUELLO Y DILATAC",1,1);
		pc.addBorderCols("SEGMENTO INFERIOR",1,1);
		pc.addBorderCols("PRENTAC. POS Y PLANOS",1,1);
		pc.addBorderCols("FOCO FETAL",1,2);
		pc.addBorderCols("FUNCION CONTRAC",1,1);
		pc.addBorderCols("MEMBR",1,1);
		pc.addBorderCols("TEMP",1,1);
		pc.addBorderCols("P/A",1,1);
		pc.addBorderCols("OBSERVACION",0,2);

	for (int i=0; i<al.size(); i++)
	{
		 cdo = (CommonDataObject) al.get(i);
		pc.addBorderCols(""+cdo.getColValue("fecha"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("hora"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("cuelloDilata"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("segInf"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("prePosPlan"),1,1,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("focoFetal"),1,2,0.5f,0.0f,0.5f,0.0f);
		pc.addBorderCols(""+cdo.getColValue("funcContrac"),1,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+cdo.getColValue("membr"),1,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+cdo.getColValue("temp"),1,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+cdo.getColValue("presionArterial"),1,1,0.5f,0.0f,0.5f,0.5f);
		pc.addBorderCols(""+cdo.getColValue("observacion"),0,2,0.5f,0.0f,0.5f,0.5f);

        if (i+1 == al.size()) {
            pc.addCols("Horas de labor:   "+horasLabor,0,vTbl20.size());
            pc.addCols("Tipo de parto:   "+cdo.getColValue("tipoParto"),0,vTbl20.size());
            pc.addCols("Motivo Cesarea:   "+cdo.getColValue("motivoCesarea"),0,vTbl20.size());

        }

	}

	if (al.size() == 0) pc.addCols(" ",1,vTbl20.size());

	pc.addCols(" ",0,vTbl20.size());

	pc.addBorderCols("OBSERVACIONES",0,5);
	pc.addBorderCols("TRATAMIENTO",0,8);

	pc.addBorderCols(" "+(cdo2.getColValue("observaTratamiento")==null?"":cdo2.getColValue("observaTratamiento")),0,5,0.5f,0.0f,0.0f,0.5f);
	pc.addBorderCols(" "+(cdo2.getColValue("tratamiento")==null?"":cdo2.getColValue("tratamiento") ),0,8,0.5f,0.0f,0.0f,0.0f);
	for (int j=0; j<4; j++)
	{
		pc.addBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.5f);
		pc.addBorderCols(" ",0,8,0.5f,0.0f,0.0f,0.0f);
	}

    // PARTO
    pc.addCols("",0, 13);
	pc.setFont(7, 0,Color.WHITE);
	pc.addBorderCols("PARTO NORMAL",0,4,cHeight,Color.GRAY);
	pc.addBorderCols("VARIEDAD",1,9,cHeight,Color.GRAY);
    pc.setFont(7, 0);

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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
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
	pc.addCols("",0,vTbl20.size());
	pc.setFont(7, 0);

	pc.setFont(7, 1);
	pc.addBorderCols("TIPO DE PARTO ",0,4,cHeight);
	pc.addBorderCols(" ",0,9);

	pc.setFont(7, 0);
	pc.addBorderCols("1.  NORMAL ",0,vTbl20.size(),cHeight);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols("EPISOGRAFIA: (Describa)    "+(cdo2.getColValue("episografia")==null?"":cdo2.getColValue("episografia")+"°"),0,vTbl20.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 1);

    ArrayList alMat = SQLMgr.getDataList("select m.codigo valor, h.conteo_inicial conteoInicial, h.conteo_final conteoFinal, m.descripcion descripcionMat from tbl_sal_hist_obst_materiales_m h , tbl_sal_obst_materiales_m m where h.pac_id(+) = "+pacId+" and h.admision(+) = "+noAdmision+" and h.cod_historial(+)  = "+cdo2.getColValue("codigo", "0")+" and m.codigo = h.valor(+)");

	pc.addCols(" ",0,vTbl20.size());
	pc.addBorderCols("",0,vTbl20.size(),0.5f,0.0f,0.0f,0.0f);
	pc.setFont(7, 1);
	pc.addBorderCols("MATERIALES USADOS",0,vTbl20.size());

    pc.addBorderCols("DESCRIPCION",0,9);
    pc.addBorderCols("CONTEO INI.",1,2);
    pc.addBorderCols("CONTEO FIN.",1,2);
    pc.setFont(7, 0);

    for (int m = 0; m<alMat.size(); m++){
        CommonDataObject cdoM = (CommonDataObject) alMat.get(m);
        pc.addBorderCols(cdoM.getColValue("descripcionMat"),0,9);
        pc.addBorderCols(cdoM.getColValue("conteoInicial"),1,2);
        pc.addBorderCols(cdoM.getColValue("conteoFinal"),1,2);
    }

    // Instrumental
	pc.setFont(7, 1,Color.WHITE);
	pc.addCols(" ",0,vTbl20.size());
	pc.addBorderCols("PARTO INSTRUMENTAL ",0,vTbl20.size(),Color.GRAY);


	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols("VACUUM EXTRACTOR ",0,1);

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

	pc.addCols("1:  "+cdo2.getColValue("forcep1"," "),0,2);
	pc.addCols("2:  "+cdo2.getColValue("forcep2"," "),0,2);
	pc.addCols("",0,5);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);


	pc.setFont(7, 0);
	pc.addCols("  ",0,vTbl20.size());
	pc.addCols("INDICACION ",0,vTbl20.size());

	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols("OTRAS: (Describa)    "+(cdo2.getColValue("otras")==null?"":cdo2.getColValue("otras")),0,vTbl20.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols("VARIEDAD DE POSICIÒN:    "+(cdo2.getColValue("variedadPosicion")==null?"":cdo2.getColValue("variedadPosicion")),0,vTbl20.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);
	pc.addCols(" ",0,vTbl20.size());
	/*pc.addCols("NIVEL DE LA PRESENTACION"+cdo2.getColValue("variedadPosicion"),0,5);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 1);*/

	pc.addBorderCols("NIVEL DE LA PRESENTACION",0,5);
	pc.addBorderCols("PLANO",0,8);

	pc.addBorderCols(" "+(cdo2.getColValue("nivelPresenta")==null?"":cdo2.getColValue("nivelPresenta")),0,5,0.5f,0.0f,0.0f,0.5f);
	pc.addBorderCols(" "+(cdo2.getColValue("plano")==null?"":cdo2.getColValue("plano")),0,8,0.5f,0.0f,0.0f,0.0f);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

	pc.addCols(" ",0,vTbl20.size());

	/**--------------------------------------------*/
	pc.setFont(7, 0);
	//pc.addBorderCols("OTRAS MANIOBRAS: ",0,vTbl20.size(),cHeight);
	pc.addBorderCols("OTRAS MANIOBRAS:   " ,0,vTbl20.size(),0.5f,0.5f,0.0f,0.0f);



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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7, 0);

    pc.addCols(" ",0,vTbl20.size());

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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
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
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);
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



pc.useTable("main");
pc.addTableToCols("tbl20",0,dHeader.size());
//HOJA DE LABOR 1 (181)


//HOJA DE LABOR 2 (182)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("182"), 0, dHeader.size(),Color.gray);

sql="select a.cod_paciente, a.fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.sexo,'M','MASCULINO','F','FEMENINO','I','INDEFINIDO') sexo, a.peso, a.talla, a.condicion, a.apgar as apgar1, a.apgar5 as apgar2, decode(a.alumbramiento,'ES','Espontáneo', 'AR','Artificial','ME','Maniobras Externas','EM','Extracción Manual de Anexos','CO','Completa') as alumbramiento, a.utero, a.consulta, a.observa_consulta as observConsulta, a.cavidad_uterina as cavidad, a.observa_cavidad as cavidU, a.cicatriz_ant as cicatriz, a.observa_cicatriz as cicatrizAnt, a.ruptura_uterina as ruptura, a.observa_ruptura as observRuptura, a.consulta_ruptura as conductaRuptura, a.observa_rup_uterina as obsvConducta, a.conducta as conductaCica, a.conducta_obsv as observaConducta, a.cuello, a.tratamiento_cuello as observCuello, a.vagina, a.tratamiento_vagina as observVagina, a.perine, tratamiento_perine as observPerine, a.recto, a.tratamiento_recto as observRect, a.medico as codMedico, a.alumbramiento_obsv as observ, a.pac_id,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion,to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, a.alumbramiento_min minutos, decode(a.vigoroso,'S','SI', 'N','NO') vigoroso, a.observacion , perimetro_toracico, tiempo_vida, perimetro_cefalico, decode(eval_riesgo,'C','CON RIESGO','SIN RIESGO') eval_riesgo, decode(rcp,'S','SI','N','NO') rcp, lugar_permanencia, lugar_transf, to_char(fecha_transf,'dd/mm/yyyy hh12:mi:ss am') fecha_transf, decode(tipo_nacimiento,'S','SIMPLE','M','MULTIPLE') tipo_nacimiento, orden_nac, to_char(hora,'hh12:mi:ss am') hora, to_char(a.fecha,'dd/mm/yyyy') fecha, usuario_creacion,usuario_modificacion from tbl_sal_historia_nacido_m a where a.pac_id = "+pacId;

cdo2 = SQLMgr.getData(sql);

if (cdo2 == null) cdo2 = new CommonDataObject();

Vector vTbl21 = new Vector();
vTbl21.addElement(".11");
vTbl21.addElement(".09");
vTbl21.addElement(".10");
vTbl21.addElement(".10");
vTbl21.addElement(".10");
vTbl21.addElement(".06");
vTbl21.addElement(".05");
vTbl21.addElement(".09");
vTbl21.addElement(".04");
vTbl21.addElement(".04");
vTbl21.addElement(".09");
vTbl21.addElement(".09");
vTbl21.addElement(".04");

pc.setNoColumnFixWidth(vTbl21);
pc.createTable("tbl21");

pc.setFont(8, 1);

pc.addCols("Creado el:    "+cdo2.getColValue("fechacreacion"),0,6);
pc.addCols("Creado por:    "+cdo2.getColValue("usuario_creacion"),1,7);
pc.addCols("Modificado el:    "+cdo2.getColValue("fecha_modificacion"),0,6);
pc.addCols("Modificado por:    "+cdo2.getColValue("usuario_modificacion"),1,7);
pc.addCols(" ",0,13);

pc.setFont(8,1,Color.WHITE);
pc.addBorderCols("DATOS RECIEN NACIDO",0,13,Color.gray);

pc.setFont(8, 1);
pc.addBorderCols("Fecha:    "+cdo2.getColValue("fecha"),0,4);
pc.addBorderCols("Hora:    "+cdo2.getColValue("hora"),0,6);
pc.addBorderCols("Sexo:    "+cdo2.getColValue("sexo"),0,3);

pc.setFont(8,1,Color.WHITE);
pc.addBorderCols("Datos antropométricos al nacer",0,13,Color.gray);

pc.setFont(8, 0);

pc.addBorderCols("Peso:    "+cdo2.getColValue("peso"),0,6);
pc.addBorderCols("Perímetro torácito:    "+cdo2.getColValue("perimetro_toracico"),0,7);
pc.addBorderCols("Talla:    "+cdo2.getColValue("talla"),0,6);
pc.addBorderCols("Tiempo de vida:    "+cdo2.getColValue("tiempo_vida"),0,7);
pc.addBorderCols("Perímetro cefálico:    "+cdo2.getColValue("perimetro_cefalico"),0, vTbl21.size());

pc.addCols(" ",0,vTbl21.size());
pc.addBorderCols("Evaluación de riesgo:    "+cdo2.getColValue("eval_riesgo"),0,vTbl21.size());
pc.addBorderCols("Se realizará RCP:    "+cdo2.getColValue("rcp"),0,vTbl21.size());

pc.addBorderCols("Vigoroso: "+cdo2.getColValue("vigoroso"," "),0,4);
pc.addBorderCols("Apgar 2:   ",0,1);
pc.addBorderCols(cdo2.getColValue("apgar2"," "),0,1);
pc.addBorderCols("Apgar 1:   ",0,2);
pc.addBorderCols(cdo2.getColValue("apgar1"," "),0,2);
pc.addBorderCols("  ",0,3);

pc.addCols(" ",0,vTbl21.size());

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

pc.addCols(" ",0,vTbl21.size());

pc.addBorderCols("Tipo Nacimiento:    "+cdo2.getColValue("tipo_nacimiento"),0,vTbl21.size()-2);
pc.addBorderCols("Orden:    "+cdo2.getColValue("orden_nac"),0,2);

pc.addBorderCols("Condición al nacer:",0,2);
pc.addBorderCols(cdo2.getColValue("condicion"),0,11);

pc.addBorderCols("Observación: ",0,2);
pc.addBorderCols(cdo2.getColValue("observacion"),0,11);

pc.setFont(10,1);
pc.addBorderCols("Fecha y hora de Nacimiento:",0,3);
pc.addBorderCols(cdo2.getColValue("fec_nacimiento"),0,11);
pc.addBorderCols("Tiempo de ruptura de membranas:",0,3);
pc.addBorderCols(cdo2.getColValue("ruptura"),0,11);


pc.addCols(" ",0,13,cHeight);
pc.setFont(10,1,Color.WHITE);
pc.addBorderCols("REVISION POST PARTO: ",0,13,Color.gray);
pc.setFont(10,0);

pc.setVAlignment(1);
pc.addBorderCols("UTERO:  BIEN CONTRAIDO",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
		pc.setFont(8,1);
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
		pc.setFont(8,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("consulta") != null && cdo2.getColValue("consulta").trim().equals("Q"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(10,0);
	pc.resetVAlignment();

	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addBorderCols("(Describa) ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols("(Ver Hoja Operatoria)",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);

	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(10,0);

	pc.setVAlignment(1);
	pc.addBorderCols("CAVIDAD UTERINA",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(10,0);

	pc.setVAlignment(1);
	pc.addBorderCols("CON RESTOS PLACENTAROS",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
		pc.setFont(8,1);
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
		pc.setFont(8,1);
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

	pc.addBorderCols("(Describa) "+cavidU,0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);

	pc.addBorderCols("CICATRIZ ANTERIOR",0,vTbl21.size());

	pc.setVAlignment(1);
	pc.addBorderCols("INDEMNE",0,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
		pc.setFont(8,1);
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
		pc.setFont(8,1);
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
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);




	pc.setVAlignment(1);
	pc.addCols("CONDUCTA",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);

	pc.setVAlignment(1);
	pc.addCols("RUPTURA UTERINA",0,2);
	pc.addCols("NO",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);


	pc.setVAlignment(1);
	pc.addCols("CONDUCTA:",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);

	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

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
	pc.setFont(8,1);
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
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.setVAlignment(1);
	pc.addCols("VAGINA",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.setVAlignment(1);
	pc.addCols("PERINE",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.setVAlignment(1);
	pc.addCols("ANO-RECTO",0,1);
	pc.addCols("INDEMNE",2,1);
	pc.setVAlignment(1);
	pc.setFont(8,1);
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
	pc.setFont(8,1);
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
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.addCols(" ",0,vTbl21.size());

    pc.setFont(10,1,Color.WHITE);
	pc.addBorderCols("ALUMBRAMIENTO",0,13,Color.gray);

    pc.setFont(10, 0);
    pc.addBorderCols("Alumbramiento: ",0,2);
    pc.addBorderCols(cdo2.getColValue("alumbramiento"),0,3);
    pc.addBorderCols(cdo2.getColValue("observ"),0,8);
    pc.addBorderCols("Minutos para el Alumbramiento: ",0,3);
    pc.addBorderCols(cdo2.getColValue("minutos"),0,10);


pc.useTable("main");
pc.addTableToCols("tbl21",0,dHeader.size());
// END HOJA DE LABOR 2 (15)

// EXAMEN FISICO RECIEN NACIDO (49)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("49"), 0, dHeader.size(),Color.gray);

Vector tbl15 = new Vector();
tbl15.addElement(".32");
tbl15.addElement(".32");
tbl15.addElement(".18");
tbl15.addElement(".18");

	//table header
	pc.setNoColumnFixWidth(tbl15);
	pc.createTable("tbl15");
		
	pc.setTableHeader(1);
	
	//------------------------------              DESCRIPCION TAB 1            --------------------- //
	sql = "select a.codigo as cod_apgar, a.descripcion as desc_apgar from tbl_sal_indicador_apgar a";
	al = SQLMgr.getDataList(sql);
	
	//1: FRECUENCIA CARDIACA 2: ESFUERZO RESPIRATORIO

	//----------------------------------        LISTADO DE CORDON UMBILICAL TAB2    ---------------------------------- //
	sql = "select a.descripcion, a.codigo as cordon, b.secuencia, nvl(b.respuesta,'N') as respuesta from tbl_sal_rn_cordon a, tbl_sal_evaluacion_cordon b where a.codigo=b.cod_cordon(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" order by a.descripcion";
	ArrayList alCordon = SQLMgr.getDataList(sql);
	
	
//------------------------------             MANIOBRAS TAB 3               --------------------- //
	sql = "select fecha_nacimiento, codigo_paciente, secuencia, rn_apgar7, rn_calor as calor, rn_secado as secado, rn_asp_nasofar as aspNaso, rn_asp_gast as aspGast, rn_man_esp_rean as reAnimacion, rn_rean_card as cardiaca, rn_metabol as metabolica, rn_estim_ext as estimulacion, rn_estim_ext_otras as otras, rn_talla as talla, rn_peso as peso, rn_edad_gest_ex_fis as edad, rn_dif_resp as difResp, rn_cp_ictericia as piel, rn_cp_palidez as palidez, rn_cp_cianosis as cianosis, rn_malforma as malForm, rn_neuro as neuro, rn_abdomen as abdomen, rn_orino as orino, rn_exp_meco as meconio, rn_cardio as cardio, pac_id, nvl(to_char(dn_fecha_nacimiento,'dd/mm/yyyy'),' ') as dnFechaNac, nvl(to_char(dn_hora_nacimiento,'hh12:mi:ss am'),' ') as dnHoraNac, nvl(dn_sexo,' ') as dnSexo, decode(perm_ano,'S','SI','N','NO') perm_ano, decode(perm_coanas,'S','SI','N','NO') perm_coanas, decode(perm_esofago,'S','SI','N','NO') perm_esofago, decode(lesiones,'S','SI','N','NO') lesiones, lesiones_obs from tbl_sal_serv_neonatologia where pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);

	pc.setFont(7,0,Color.WHITE);
    pc.addCols("PUNTUACION APGAR",0,tbl15.size(), Color.gray);
	
    pc.setFont(7,0);
	pc.addBorderCols("Descripción",1,1);
	pc.addBorderCols("Escala",1,1);	
	pc.addBorderCols("Minuto 1",1,1);
	pc.addBorderCols("Minuto 5",1,1);
	
	String apgar = "";
	String minuto1 = "";
	String minuto5 = "";
	
	CommonDataObject cdoT = new CommonDataObject();
	ArrayList alEscala = new ArrayList();
	
	int ln = -1;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdoS = (CommonDataObject) al.get(i);
		
       //--------------------------------      ESCALA TAB 1    ----------------------------------------//
		sql = "select cod_apgar, codigo, descripcion, valor from tbl_sal_ptje_x_ind_apgar where cod_apgar="+cdoS.getColValue("cod_apgar");
		alEscala = SQLMgr.getDataList(sql);
		
		pc.addBorderCols(cdoS.getColValue("desc_apgar"),0,tbl15.size(),0.5f,0.0f,0.0f,0.0f); //DESCRIPCION
		
		for(int e=0; e<alEscala.size();e++){
			
			pc.addCols("",0,1);
			
			CommonDataObject cdoE = (CommonDataObject)alEscala.get(e);
			
			
				//------------------------     GETTING THE RADIOBUTTONS VALUE    -----------------------------//
				sql = "select secuencia, cod_apgar,minuto1, minuto5, pac_id from tbl_sal_apgar_neonato where cod_apgar="+cdoE.getColValue("cod_apgar") +" and pac_id="+pacId +" order by cod_apgar";
			 cdoT = SQLMgr.getData(sql);
			 
			 if ( cdoT == null ) cdoT = new  CommonDataObject();
			 
			if(cdoS.getColValue("cod_apgar").equals(cdoE.getColValue("cod_apgar"))){
				
		   		    pc.addCols(cdoE.getColValue("descripcion")+" ["+cdoE.getColValue("valor")+"]",0,1); //ESCALA
		   			
		
			} //end if
			
			if(!apgar.equals(cdoE.getColValue("cod_apgar"))){
			  pc.addCols(cdoT.getColValue("minuto1"),1,1);
			}else{
			  pc.addCols("",1,1);	
			}
			if(!apgar.equals(cdoE.getColValue("cod_apgar"))){
			  pc.addCols(cdoT.getColValue("minuto5"),1,1);
			}else{
			  pc.addCols("",1,1);
			}
			
			apgar =   cdoE.getColValue("cod_apgar");
			
		
		} // end for e
		//pc.addCols("",1,1);
				
	}//End For
	
	if ( cdo == null ) cdo = new CommonDataObject();
	
	
	//-------------------------- GETTING THE TOTAL -------------------------------//
	String sqlGetTot = "select sum(minuto1) as totmin1, sum(minuto5) as totmin5 from tbl_sal_apgar_neonato where pac_id = "+pacId;
	CommonDataObject cdoGetTot = SQLMgr.getData(sqlGetTot);
	
	if (cdoGetTot == null) cdoGetTot = new CommonDataObject();
	
	pc.addCols("",1,tbl15.size(),20.2f);
	
	pc.setFont(7,1);
	pc.addCols("Si está deprimido al 5to minuto. Tiempo en que logra Apgar 7: ",1,1);
	pc.addCols(cdo.getColValue("rn_apgar7"),0,1);
	pc.addBorderCols(cdoGetTot.getColValue("totmin1")+" Pts",1,1,0.0f,0.5f,0.0f,0.0f); //MINUTO 1 TOTAL
	pc.addBorderCols(cdoGetTot.getColValue("totmin5")+" Pts",1,1,0.0f,0.5f,0.0f,0.0f); //MINUTO 5 TOTAL
   
    
//*********************************************** EN TAB 1 **************************************************//	
	
//*********************************************** TAB 2 **************************************************//

CommonDataObject cdoX = SQLMgr.getData("select distinct decode(eval_cordon,'S','SI','N','NO')eval_cordon, decode(analisis_sangre,'S','SI','N','NO')analisis_sangre, analisis_sangre_obs, eval_cordon_obs from tbl_sal_evaluacion_cordon_hdr where pac_id = "+pacId+" and admision = "+noAdmision);
if (cdoX == null) cdoX = new CommonDataObject();

	pc.addCols("",1,tbl15.size(),25.2f);
	pc.setFont(7,1, Color.WHITE);
	pc.addCols("EVALUACION CORDON UMBILICAL",0,tbl15.size(), Color.gray);
    
    pc.setFont(8,1);
    pc.addCols(" ",0,4);
    pc.addCols("Análisis de sangre:    "+cdoX.getColValue("analisis_sangre"," "),0,1);
    pc.addCols(cdoX.getColValue("analisis_sangre_obs"," "),0,3);
    pc.addCols("Evaluación de Cordón:    "+cdoX.getColValue("eval_cordon"," "),0,1);
    pc.addCols(cdoX.getColValue("eval_cordon_obs"," "),0,3);
    pc.addCols(" ",0,4);
	
	pc.setFont(8,1);
	pc.addBorderCols("Descripción",1,1);
	pc.addBorderCols("SI",1,1);
	pc.addBorderCols("NO",1,1);
    pc.addCols("",1,1);
    
	
	String marcadoS="", marcadoN="";

    pc.setFont(8,0);
	for(int i=0; i<alCordon.size();i++)
	{
        CommonDataObject cdoS = (CommonDataObject) alCordon.get(i);
			pc.addBorderCols(cdoS.getColValue("descripcion"),0,1,0.5f,0.0f,0.0f,0.0f);
			
			
			if(cdoS.getColValue("respuesta").equals("S")){
				marcadoS = "x";
				marcadoN = "";
			}else{
				marcadoS = "";
				marcadoN = "x";
			}
		
			  pc.addBorderCols(marcadoS,1,1,0.5f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(marcadoN,1,1,0.5f,0.0f,0.0f,0.0f);
	          pc.addCols("",1,1);

	}//End For
//***************************************** END TAB 2 **********************************************************//

//******************************************* TAB 3 *************************************************************// 

String calor = "", secado="", aspNaso="", aspGastro="", reanim="", cardio="",metabol="", estimul="",otras="", difResp="",colPiel="", palidez="", cianosis="", malformaciones="", neurologico="",abdo="", orino="",xpulso="",cardiov="";

sexo = "";
		
		pc.addCols("",1,tbl15.size(),20.2f);
		pc.setFont(7,1,Color.white);
		pc.addBorderCols("GENERALES DEL RECIEN NACIDO",0,tbl15.size(), Color.gray);
		
		pc.setFont(7,1);
	    pc.addBorderCols("Fecha Nacimiento",1,1);
	    pc.addBorderCols("Hora Nacimiento",1,1);
	    pc.addBorderCols("Sexo",1,2);

		pc.addCols(cdo.getColValue("dnFechaNac"),0,1);
		pc.addCols(cdo.getColValue("dnHoraNac"),0,1);
		
		if(cdo.getColValue("dnSexo")!=null && cdo.getColValue("dnSexo").equals("F")){
			sexo = "Niña";
		}else{
			sexo = "Niño";
		}
		pc.addCols(sexo,1,2);
//************************************************* END GENERALES DEL RECIEN NACIDO *************************************//	
	
		pc.addCols("",1,tbl15.size(),15.2f);
		pc.setFont(7,1,Color.white);
		pc.addBorderCols("MANIOBRAS DE RUTINA",0,tbl15.size(), Color.gray);
		
		if(cdo.getColValue("calor")!=null && cdo.getColValue("calor").equals("S")){
			 calor= "Si";
		}else{
			 calor= "No";
		}
		
		if(cdo.getColValue("secado")!=null && cdo.getColValue("secado").equals("S")){
			secado = "Si";
		}else{
		   secado = "No";	
		}
		
		if(cdo.getColValue("aspNaso")!= null && cdo.getColValue("aspNaso").equals("S")){
			aspNaso = "Si";
		}else{
			aspNaso = "No";
		}
		
		if(cdo.getColValue("aspGast")!= null && cdo.getColValue("aspGast").equals("S")){
			aspGastro = "Si";
		}else{
			aspGastro = "No";
		}
		
		pc.setFont(7,0);
	    pc.addCols("Calor: "+calor,1,1);
		pc.addCols("Secado: "+secado,1,1);
		pc.addCols("Aspiración Nasofaringea: "+aspNaso,1,1);
		pc.addCols("Aspiración Gastrica: "+aspGastro,1,1);
//************************************************* END MANIOBRAS DE RUTINA *************************************//			
		
		pc.addCols("",1,tbl15.size(),20.2f);
		pc.setFont(7,1,Color.white);
		pc.addBorderCols("MANIOBRAS ESPECIALES DE REANIMACION",0,tbl15.size(), Color.gray);
		
		pc.setFont(7,0);
		
		if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("NH")){
			reanim = "No se hizo";
		}
		
		if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("MS")){
			reanim = "Máscara Simple";
		}
		
	    if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("MP")){
			reanim = "Máscara Presión Positiva";
		}
		
		if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("IN")){
			reanim = "Intubación";
		} // Reanimacion
		
	    if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("NH")){
		   cardio = "No se hizo";
	    }
	
		if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("ME")){
		   cardio = "Masaje Externo";
		}	
		
		if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("DG")){
		  cardio = "Drogas";
		}
		
		if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("DG")){
		  cardio = "Drogas";
	    } //cardio
	
		if(cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("NH")){
		  metabol = "No se hizo";
		}
		
	    if(cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("AL")){
		  metabol = "Alcalinizantes";
	    }
		
	   if(cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("OT")){
		  metabol = "Otros";
	   }  //metabol
	
	   if(cdo.getColValue("Estimulacion")!=null && cdo.getColValue("Estimulacion").equals("S")){
		  estimul = "Si";
	   }else{
		 estimul = "No";
	   }
	
	   if(cdo.getColValue("otras")!=null && cdo.getColValue("otras").equals("S")){
		 otras = "Si";
	   }else{
		 otras = "No";
	   }
	
	   if(cdo.getColValue("difResp")!=null && cdo.getColValue("difResp").equals("S")){
		  difResp = "Si";
	   }else{
		 difResp = "No";
	   }
	
    pc.addBorderCols("Reanimación: "+reanim+"                                     Cardiaca: "+cardio+ "                                     Metabolica: "+metabol+ "                                     Estimulación Externa: "+estimul+"                                     Otras: "+otras,0,tbl15.size());
     
    pc.addCols("",1,tbl15.size(),15.2f);
    pc.setFont(8,1,Color.white);
    pc.addBorderCols("EXAMEN FISICO INMEDIATO",0,tbl15.size(), Color.gray);
    
    pc.setFont(8,1);
	
    pc.addBorderCols("Talla",1,1);
	pc.addBorderCols("Peso",1,1);
	pc.addBorderCols("Edad Gest. por Examen Físico",1,1);
	pc.addBorderCols("Dificultad Respiratoria",1,1);
    
    pc.setFont(8,0);
	pc.addCols(cdo.getColValue("talla"),1,1);
	pc.addCols(cdo.getColValue("peso"),1,1);
	pc.addCols("Semanas: "+cdo.getColValue("edad"),1,1);
    pc.addCols(difResp,1,1);
	
	
	if(cdo.getColValue("piel")!=null && cdo.getColValue("piel").equals("S")){
		colPiel="Si"; 
	}else{
		colPiel="No"; 
	}
	
	if(cdo.getColValue("palidez")!=null && cdo.getColValue("palidez").equals("S")){
	   palidez="Si"; 
	}else{
		palidez="No";
	}
	
	if(cdo.getColValue("cianosis")!= null && cdo.getColValue("cianosis").equals("S")){
	   cianosis="Si";
	}else{
		cianosis="No";
	}
	
	if(cdo.getColValue("malform")!=null && cdo.getColValue("malform").equals("S")){
	   malformaciones="Si";
	}else{
	  malformaciones="No";
	}
	
	if(cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("N")){
	   neurologico="Normal";
	}
	if(cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("D")){
			neurologico="Deprimido";
	}
	else{
	   neurologico="Excitado";
	}
	
	pc.addCols("",1,tbl15.size(),15.2f);
	pc.addBorderCols("Color de la Piel Ictericia: "+colPiel+"                                   Palidez: "+palidez+ "                                   Cianosis: "+cianosis+ "                                   Malformaciones: "+malformaciones+"                                   Neurologico: "+neurologico,0,tbl15.size());


   pc.addCols("",1,tbl15.size(),15.2f);

   pc.addBorderCols("Abdomen",1,1);
   pc.addBorderCols("Orinó",1,1);
   pc.addBorderCols("Expulso Meconio",1,1);
   pc.addBorderCols("Cardiovascular",1,1);

   if(cdo.getColValue("abdomen")!=null && cdo.getColValue("abdomen").equals("N")){
	   abdo="Normal";
   }else{
	   abdo="Anormal";
   }

   if(cdo.getColValue("mecomio")!=null && cdo.getColValue("mecomio").equals("S")){
	  xpulso= "Si"; 
   }else{
	  xpulso= "No"; 
   }
   
    if(cdo.getColValue("orino")!=null && cdo.getColValue("orino").equals("S")){
	  orino= "Si"; 
   }else{
	  orino= "No"; 
   }
   
   if(cdo.getColValue("cardio")!=null && cdo.getColValue("cardio").equals("S")){
	 cardiov= "Normal";  
   }else{
	 cardiov= "Anormal"; 
   }		
					
 pc.addCols(abdo,1,1);
 pc.addCols(orino,1,1);
 pc.addCols(xpulso,1,1);
 pc.addCols(cardiov,1,1);
 
 pc.addCols("Lesiones:   "+cdo.getColValue("lesiones"," "),0,1);
 pc.addCols(cdo.getColValue("lesiones_obs"," "),0,3);
 
 
 
pc.addCols(" ",1,tbl15.size());
pc.setFont(9,1);
pc.addCols("EXAMEN FISICO AL NACER",0,tbl15.size(),Color.lightGray);
    
pc.setFont(9,0);
pc.addCols("Permeabilidad de las coanas:   "+cdo.getColValue("perm_coanas"," "),0,tbl15.size());
pc.addCols("Permeabilidad del esofago:   "+cdo.getColValue("perm_esofago"," "),0,tbl15.size());
pc.addCols("Permeabilidad del ano:   "+cdo.getColValue("perm_ano"," "),0,tbl15.size());

pc.useTable("main");
pc.addTableToCols("tbl15",0,dHeader.size());
// END EXAMEN FISICO RECIEN NACIDO (49)



// DIAGNOSTICO DE INGRESO (89)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("89"), 0, dHeader.size(),Color.gray);

sql = "select a.diagnostico , a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss am') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss am') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'I' order by a.orden_diag";

al = SQLMgr.getDataList(sql);

Vector vTbl7 = new Vector();
vTbl7.addElement("7");
vTbl7.addElement("35");
vTbl7.addElement("10");
vTbl7.addElement("10");
vTbl7.addElement("10");
vTbl7.addElement("10");
vTbl7.addElement("10");

pc.setNoColumnFixWidth(vTbl7);
pc.createTable("tbl7");

pc.setFont(8, 1);
pc.addBorderCols("Código",1,1);
pc.addBorderCols("Nombre",1,1);
pc.addBorderCols("Prioridad",1,1);
pc.addBorderCols("Registrado por",1,1);
pc.addBorderCols("F. Creac.",1,1);
pc.addBorderCols("Modificado por",1,1);
pc.addBorderCols("F. Modif.",1,1);

for(int i = 0; i<al.size(); i++){

    cdo = (CommonDataObject)al.get(i);

    pc.setFont(8, 0);
    pc.addCols(cdo.getColValue("diagnostico"),0,1);
    pc.addCols(cdo.getColValue("diagnosticoDesc"),0,1);
    pc.addCols(cdo.getColValue("orden_diag"),1,1);
    pc.addCols(cdo.getColValue("usuario_creacion"),1,1);
    pc.addCols(cdo.getColValue("fecha_creacion"),0,1);
    pc.addCols(cdo.getColValue("usuario_modificacion"),1,1);
    pc.addCols(cdo.getColValue("fecha_modificacion"),0,1);

}//end for
        
pc.useTable("main");
pc.addTableToCols("tbl7",0,dHeader.size());
// END DIAGNOSTICO DE INGRESO (89) (49)



pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols(" ", 0, dHeader.size());
pc.addCols("Firma del Médico: _____________________________________________________________________", 0, dHeader.size());

pc.addTable();
if(isUnifiedExp){
  pc.close();
  response.sendRedirect(redirectFile);
}
%>