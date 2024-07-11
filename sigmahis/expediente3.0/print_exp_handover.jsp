<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admin.Properties"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

Properties prop = new Properties();
CommonDataObject cdo, cdoPacData  = new CommonDataObject();

String sql = "", sqlTitle = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String code = request.getParameter("code");
String condTitle = request.getParameter("cond_title");
String fp = request.getParameter("fp");
String reporte = request.getParameter("reporte");

if (condTitle == null) condTitle = "";
if (fp == null) fp = "";
if (reporte == null) reporte = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
prop = SQLMgr.getDataProperties("select params from tbl_sal_traslado_handover where codigo = "+code+" and pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+code);

if (prop == null) prop = new Properties();

String fecha = cDateTime;
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
float height = 72 * 14f;//792
boolean isLandscape = false;
float leftRightMargin = 5.0f;
float topMargin = 13.5f;
float bottomMargin = 9.0f;
float headerFooterFont = 4f;
StringBuffer sbFooter = new StringBuffer();
boolean logoMark = true;
boolean statusMark = false;
String xtraCompanyInfo = "";
String title = "EXPEDIENTE";
String subTitle = !desc.equals("")?desc:"HANDOVER";
String xtraSubtitle = "";

boolean displayPageNo = true;
float pageNoFontSize = 0.0f;//between 7 and 10
String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
String pageNoPoxX = null;//L=Left, R=Right
String pageNoPosY = null;//T=Top, B=Bottom
int fontSize = 5;
float cHeight = 90.0f;

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

if(pc==null){  pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);isUnifiedExp=true;}

Vector tblMain = new Vector();
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");
tblMain.addElement("10");

pc.setNoColumnFixWidth(tblMain);
pc.createTable();

pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, tblMain.size());
pc.setTableHeader(1);

cdo = SQLMgr.getData("select to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha, usuario_creacion from tbl_sal_traslado_handover where pac_id = "+pacId+" and admision = "+noAdmision);

if (cdo == null) cdo = new CommonDataObject();

pc.setFont(9,1);
pc.addCols("SITUACION S/S",1,tblMain.size());
pc.addCols(" ",1,tblMain.size());

pc.setFont(9,0);
pc.addBorderCols("Creado el: ",0,2,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(cdo.getColValue("fecha"),0,3,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols("Usuario: ",1,2,0.1f,0.0f,0.0f,0.0f);
pc.addBorderCols(cdo.getColValue("usuario_creacion"),0,3,0.1f,0.0f,0.0f,0.0f);
pc.addCols(" ",1,tblMain.size());

pc.addCols("Fecha: "+prop.getProperty("fecha_traslado"),0,4);
pc.addCols("Médico: ["+prop.getProperty("medico")+"] "+prop.getProperty("medico_nombre"),0,6);

pc.addCols("Persona que reporta: "+prop.getProperty("persona_que_reporta"),0,5);
pc.addCols("Área: "+prop.getProperty("cds_persona_que_reporta"),0,5);

pc.addCols("Persona que recibe el reporte: ["+prop.getProperty("persona_que_recibe")+"] "+prop.getProperty("persona_que_recibe_nombre"),0,5);
pc.addCols("Área: ["+prop.getProperty("centro_servicio_recibe")+"] "+prop.getProperty("centro_servicio_recibe_desc"),0,5);

pc.addCols(" ",1,tblMain.size());

pc.setFont(9,1);
pc.addCols("MOTIVOS",0,tblMain.size());
pc.setFont(9,0);

if(prop.getProperty("motivo").equals("0")) pc.addBorderCols("[ X ]  Para Preparación por Cirugía y/o Procedimiento",0,5);
else pc.addBorderCols("[   ]  Para Preparación por Cirugía y/o Procedimiento",0,5);
pc.addBorderCols("(especifique): "+prop.getProperty("observacion0"),0,5);

if(prop.getProperty("motivo").equals("1")) pc.addBorderCols("[ X ]  Para Cirugía",0,5);
else pc.addBorderCols("[   ]  Para Cirugía",0,5);
pc.addBorderCols("(especifique): "+prop.getProperty("observacion1"),0,5);

if(prop.getProperty("motivo").equals("2")) pc.addBorderCols("[ X ]  Para Procedimiento",0,5);
else pc.addBorderCols("[   ]  Para Procedimiento",0,5);
pc.addBorderCols("(especifique): "+prop.getProperty("observacion1"),0,5);

if(prop.getProperty("motivo").equals("3")) pc.addBorderCols("[ X ]  Para Recuperación de anestesia",0,5);
else pc.addBorderCols("[   ]  Para Recuperación de anestesia",0,5);
pc.addBorderCols("(especifique): \n\n\n",0,5);

if(prop.getProperty("motivo").equals("4")) pc.addBorderCols("[ X ]  Traslado a otro servicio",0,5);
else pc.addBorderCols("[   ]  Traslado a otro servicio",0,5);
pc.addBorderCols("(especifique): \n\n\n",0,5);

if(prop.getProperty("motivo").equals("5")) pc.addBorderCols("[ X ]  Traslado a otra Institución",0,5);
else pc.addBorderCols("[   ]  Traslado a otra Institución",0,5);
pc.addBorderCols("(especifique): \n\n\n",0,5);

if(prop.getProperty("motivo").equals("6")) pc.addBorderCols("[ X ]   Para examen Radiología",0,5);
else pc.addBorderCols("[   ]   Para examen Radiología",0,5);
pc.addBorderCols("(especifique): "+prop.getProperty("observacion3"),0,5);

if(prop.getProperty("motivo").equals("7")) pc.addBorderCols("[ X ]   Otros (Diálisis, Fisioterapia)",0,5);
else pc.addBorderCols("[   ]   Otros (Diálisis, Fisioterapia)",0,5);
pc.addBorderCols("(especifique): "+prop.getProperty("observacion4"),0,5);

pc.addCols(" ",1,tblMain.size());

pc.setFont(9,1);
pc.addCols("OBSERVACIONES IMPORTANTES",0,tblMain.size(),Color.lightGray);
pc.setFont(9,0);

pc.setFont(9,1);
pc.addCols("1. ANTECEDENTES ALERGICOS",0,tblMain.size());
String alergias = "";
ArrayList al = new ArrayList();
/*
ArrayList al = SQLMgr.getDataList("select a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.usuario_creacion, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo=b.tipo_alergia and b.pac_id = "+pacId+" and nvl(b.admision,"+noAdmision+") = "+noAdmision);

pc.addBorderCols("Tipo de Alergia",1 ,2);
pc.addBorderCols("Edad",1 ,1);
pc.addBorderCols("Meses",1 ,1);
pc.addBorderCols("Observación",1 ,3);
pc.addBorderCols("Fecha",1 ,2);
pc.addBorderCols("Usuario",1 ,1);

pc.setFont(9,0);
for(int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);
		pc.addCols(cdo.getColValue("descripcion"),0,2,15.2f);
		pc.addCols(cdo.getColValue("edad"),1,1,15.2f);
		pc.addCols(cdo.getColValue("meses"),1,1,15.2f);
		pc.addCols(cdo.getColValue("observacion"),0,3);
		pc.addCols(cdo.getColValue("fecha"),1,2);
		pc.addCols(cdo.getColValue("usuario_creacion"),1,1);
}

Properties prop1 = SQLMgr.getDataProperties("select nota from tbl_sal_nota_eval_enf_urg where pac_id="+pacId+" and admision="+noAdmision+" and tipo_nota = 'NEEU'");

if (prop1 == null) prop1 = new Properties();

pc.addCols(" ",0,tblMain.size());



if (prop1.getProperty("alergia0").equalsIgnoreCase("n")) alergias = "[ X ] Niega     ";
else alergias = "[   ] Niega     ";
if (prop1.getProperty("alergia1").equalsIgnoreCase("a")) alergias += "[ X ] Alimentos     ";
else  alergias += "[   ] Alimentos     ";
if (prop1.getProperty("alergia2").equalsIgnoreCase("ai")) alergias += "[ X ] Aines     ";
else  alergias += "[   ] Aines     ";
if (prop1.getProperty("alergia3").equalsIgnoreCase("at")) alergias += "[ X ] Antibióticos     ";
else  alergias += "[ X ] Antibióticos     ";
if (prop1.getProperty("alergia4").equalsIgnoreCase("m")) alergias += "[ X ] Medicamentos     ";
else  alergias += "[   ] Medicamentos     ";
if (prop1.getProperty("alergia5").equalsIgnoreCase("y")) alergias += "[ X ] YODO     ";
else  alergias += "[   ] YODO     ";
if (prop1.getProperty("alergia6").equalsIgnoreCase("s")) alergias += "[ X ] Sulfa     ";
else  alergias += "[   ] Sulfa     ";
if (prop1.getProperty("alergia7").equalsIgnoreCase("o")) alergias += "[ X ] Otros";
else  alergias += "[  ] Otros";

pc.addCols("Alergias:    "+alergias,0,tblMain.size());
if( prop1.getProperty("alergia7").equalsIgnoreCase("o")&&!prop1.getProperty("alergia0").equalsIgnoreCase("n")){
		pc.addCols("Comentarios: "+prop1.getProperty("otros8"),0,tblMain.size());
}
*/

if (prop.getProperty("alergia").equalsIgnoreCase("0")) alergias = "[ X ] SI     [   ] NO          (especifique):  "+prop.getProperty("observacion5");
else if (prop.getProperty("alergia").equalsIgnoreCase("1")) alergias = "[   ] SI     [ X ] NO";
//else alergias = "[    ] SI     [    ] NO          (especifique):  \n\n";

pc.addCols("Alergias:    "+alergias,0,tblMain.size());

pc.addCols(" ",0,tblMain.size());

pc.setFont(9,1);
pc.addCols("2. AISLAMIENTO",0,tblMain.size());
pc.setFont(9,0);

String aislamientos = "";
/*
prop1 = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = 'C1'");

if (prop1 == null) prop1 = new Properties();

if (prop.getProperty("aislamiento").equalsIgnoreCase("0")) {

		if (prop1.getProperty("aislamiento_det1").equalsIgnoreCase("1")) aislamientos = "[ X ] Paciente con Aislamiento de Contacto";
		else  aislamientos = "[   ] Paciente con Aislamiento de Contacto";

		if (prop1.getProperty("aislamiento_det3").equalsIgnoreCase("3")) aislamientos += "      [ X ] Paciente Con Aislamiento de Gotas";
		else  aislamientos += "      [   ] Paciente Con Aislamiento de Gotas";

		if (prop1.getProperty("aislamiento_det5").equalsIgnoreCase("5")) aislamientos += "      [ X ] Paciente con Aislamiento Respiratorio (Gotitas)";
		else  aislamientos += "      [   ] Paciente con Aislamiento Respiratorio (Gotitas)";

		if (prop1.getProperty("aislamiento_det0").equalsIgnoreCase("0")) aislamientos += "\n\n[ X ] Orientación al paciente y familiar";
		else  aislamientos += "\n\n[   ] Orientación al paciente y familiar";

		if (prop1.getProperty("aislamiento_det2").equalsIgnoreCase("2")) aislamientos += "      [ X ] Coordinación con la enfermera de nosocomial";
		else  aislamientos += "      [   ] Coordinación con la enfermera de nosocomial";

		if (prop1.getProperty("aislamiento_det4").equalsIgnoreCase("4")) aislamientos += "      [ X ] Colocación del equipo de protección";
		else  aislamientos += "      [   ] Colocación del equipo de protección";

		pc.addCols(aislamientos,0,tblMain.size());

} else {
		pc.addCols(">>",0,tblMain.size());
		pc.addCols(">>",0,tblMain.size());
}
*/
if (prop.getProperty("aislamiento").equalsIgnoreCase("0")) aislamientos = "[ X ] SI     [   ] NO          (especifique):  "+prop.getProperty("observacion6");
else if (prop.getProperty("aislamiento").equalsIgnoreCase("1")) aislamientos = "[   ] SI     [ X ] NO";
else aislamientos = "[    ] SI     [    ] NO          (especifique):  \n\n";

/* */
pc.addCols(" ",0,tblMain.size());
pc.addCols("AISLAMIENTO:  "+aislamientos,0,tblMain.size());

pc.addCols(" ",0,tblMain.size());
pc.addCols("3. OTROS:  "+prop.getProperty("observacion7"),0,tblMain.size());

pc.setFont(9,1);
pc.addCols("ANTECEDENTES B/A",1,tblMain.size());
pc.addCols("DIAGNOSTICOS DE INGRESO",0,tblMain.size());

al = SQLMgr.getDataList("select a.diagnostico , a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss am') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss am') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'I' order by a.orden_diag");

Vector tbl0 = new Vector();
tbl0.addElement("7");
tbl0.addElement("35");
tbl0.addElement("10");
tbl0.addElement("10");
tbl0.addElement("10");
tbl0.addElement("10");
tbl0.addElement("10");

pc.setNoColumnFixWidth(tbl0);
pc.createTable("tbl0");

pc.setFont(9,1);
pc.addBorderCols("Código",1,1, Color.gray);
pc.addBorderCols("Nombre",1,1, Color.gray);
pc.addBorderCols("Prioridad",1,1, Color.gray);
pc.addBorderCols("Registrado por",1,1, Color.gray);
pc.addBorderCols("F. Creac.",1,1, Color.gray);
pc.addBorderCols("Modificado por",1,1, Color.gray);
pc.addBorderCols("F. Modif.",1,1, Color.gray);

pc.setFont(9,0);
for(int i = 0; i<al.size(); i++){
		cdo = (CommonDataObject)al.get(i);
		pc.addBorderCols(cdo.getColValue("diagnostico"),0,1);
		pc.addBorderCols(cdo.getColValue("diagnosticoDesc"),0,1);
		pc.addBorderCols(cdo.getColValue("orden_diag"),1,1);
		pc.addBorderCols(cdo.getColValue("usuario_creacion"),1,1);
		pc.addBorderCols(cdo.getColValue("fecha_creacion"),0,1);
		pc.addBorderCols(cdo.getColValue("usuario_modificacion"),1,1);
		pc.addBorderCols(cdo.getColValue("fecha_modificacion"),0,1);
}

pc.useTable("main");
pc.addTableToCols("tbl0",0,tblMain.size());
pc.addCols(" ",1,tblMain.size());
if(prop.getProperty("historia_medica_relevante").equals("0"))
		pc.addCols("HISTORIA MÉDICA RELEVANTE:           [ X ] SI          [   ] NO           (especifique):  "+prop.getProperty("observacion8"),0,tblMain.size());
else if(prop.getProperty("historia_medica_relevante").equals("1"))
		pc.addCols("HISTORIA MÉDICA RELEVANTE:           [   ] SI          [ X ] NO",0,tblMain.size());
else pc.addCols("HISTORIA MÉDICA RELEVANTE:           [   ] SI          [   ] NO",0,tblMain.size());

al = SQLMgr.getDataList("select codigo, descripcion, es_otro from tbl_sal_lista_handover where estado = 'A' and lista = "+prop.getProperty("reporte_transferencia")+" order by orden");

String descReporte = "VERIFICACIÓN PARA EL TRASLADO Y/O MOVIMIENTO";

if (prop.getProperty("reporte_transferencia").equals("1")) descReporte = "VERIFICACIÓN PARA SALÓN DE OPERACIONES Y/O PROCEDIMIENTOS ";
else if (prop.getProperty("reporte_transferencia").equals("2")) descReporte = "VERIFICACIÓN PARA RADIOLOGÍA";
else if (prop.getProperty("reporte_transferencia").equals("3")) descReporte = "VERIFICACIÓN PARA EL TRASLADO DE UN ÁREA A OTRA. REPORTE DE TRANSFERENCIA (SI APLICA)";
else if (prop.getProperty("reporte_transferencia").equals("4")) descReporte = "VERIFICACIÓN PARA PAUSA DE SEGURIDAD";


pc.setFont(9,1);
pc.addCols(" ",1,tblMain.size());
pc.addBorderCols(descReporte,1,6);
pc.addBorderCols("OBSERVACION",1,4);

pc.setFont(9,0);
for (int i = 0; i<al.size(); i++) {
	cdo = (CommonDataObject) al.get(i);

	if(prop.getProperty("seleccionado_"+i) != null && !"".equals(prop.getProperty("seleccionado_"+i)) )
	{
		pc.addBorderCols("[ X ] "+cdo.getColValue("descripcion"),0,6);

	}
	else pc.addBorderCols("[   ] "+cdo.getColValue("descripcion"),0,6);
	pc.addBorderCols(prop.getProperty("observacion_lista_"+i),0,4);
}

pc.setFont(9,1);
pc.addCols("EVALUACION A/E",1,tblMain.size());
pc.addCols("CONDICIÓN ACTUAL:",0,tblMain.size());

pc.setFont(9,0);
if (prop.getProperty("condicion_actual").equals("0")) pc.addCols("[ X ] Estable       [   ] Crítica       [   ] Otro: ",0,tblMain.size());
else if (prop.getProperty("condicion_actual").equals("1")) pc.addCols("[    ] Estable       [ X ] Crítica       [   ] Otro: ",0,tblMain.size());
else pc.addCols("[    ] Estable       [    ] Crítica       [ X ] Otro:  "+prop.getProperty("observacion10"),0,tblMain.size());

pc.setFont(9,1);
pc.addCols("EVALUACIONES IMPORTANTES",0,tblMain.size());
pc.addCols("Signos Vitales:",0,tblMain.size());

/* cdo = SQLMgr.getData("select a.tipo_persona as tipoPersona, nvl(a.observacion,' ') as observacion, nvl(a.accion,' ') as accion, decode(a.categoria,'1','I','2','II','3','III',a.categoria) as categoria, decode(a.evacuacion,'S','[ X ]','[__]') as evacuacion, decode(a.miccion,'S','[ X ]','[__]') as miccion, decode(a.vomito,'S','[ X ]','[__]') as vomito, nvl(a.miccion_obs,' ') as miccionObs, nvl(a.vomito_obs,' ') as vomitoObs, nvl(a.evacuacion_obs,' ') as evacuacionObs , to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, to_char(a.hora_registro,'hh12:mi:ss am') as horaRegistro, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif,decode(a.dolor,'S','SI','NO') as dolor,a.escala from tbl_sal_signo_paciente a where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and a.status = 'A' and fecha_creacion = ( select max(fecha_creacion) from tbl_sal_signo_paciente where pac_id = "+pacId+" and secuencia = "+noAdmision+" and status = 'A' ) order by a.fecha desc, a.hora_registro desc");

if (cdo == null) cdo = new CommonDataObject();

ArrayList alD = SQLMgr.getDataList("select a.signo_vital as signoVital, a.tipo_persona as tipoPersona, nvl(a.resultado,' ') resultado, b.descripcion as signoDesc, nvl(c.sigla_um,' ') as signoUnit from tbl_sal_detalle_signo a, tbl_sal_signo_vital b, tbl_sal_signo_vital_um c where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.signo_vital=b.codigo and a.signo_vital=c.cod_signo(+) and c.valor_default(+)='S' and a.tipo_persona = '"+cdo.getColValue("tipoPersona")+"' and to_date(to_char(a.fecha_signo,'dd/mm/yyyy'),'dd/mm/yyyy')  =  to_date('"+cdo.getColValue("fecha")+"','dd/mm/yyyy') and to_date(to_char(a.hora,'dd/mm/yyyy hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') =  to_date('"+cdo.getColValue("fecha")+" "+cdo.getColValue("hora")+"','dd/mm/yyyy hh12:mi:ss am') order by a.fecha_signo, a.hora, a.signo_vital desc");//depends on header's status

String signos = "Dolor:      "+prop.getProperty("escala");

for(int i = 0; i<alD.size(); i++){
		cdo = (CommonDataObject) alD.get(i);
		signos +="\n\n"+cdo.getColValue("signoDesc")+":      "+cdo.getColValue("resultado");
}

*/
String signos = "Dolor:      "+prop.getProperty("escala");
signos += "     Presión Arterial:      "+prop.getProperty("presion_arterial");
signos += "     Frecuencia cardiaca:      "+prop.getProperty("frecuencia_cardica");
signos += "     Temperatura:      "+prop.getProperty("temperatura");
signos += "     Respiración:      "+prop.getProperty("respiracion");

pc.setFont(9,0);
pc.addCols(signos,0,tblMain.size());
pc.setFont(9,1);
pc.addCols("",0,tblMain.size());

if(prop.getProperty("riesgo_caida").equals("0")) pc.addCols("Riesgo de caída:  [ X ] Alto      [   ] Bajo",0,tblMain.size());
else if(prop.getProperty("riesgo_caida").equals("1")) pc.addCols("Riesgo de caída:  [    ] Alto      [ X ] Bajo",0,tblMain.size());
else pc.addCols("Riesgo de caída:  [    ] Alto      [    ] Bajo",0,tblMain.size());

pc.addCols("",0,tblMain.size());
if(prop.getProperty("otros_reg_importantes").equals("0")) pc.addCols("Otros Registros Importantes:  "+prop.getProperty("observacion9"),0,tblMain.size());
else pc.addCols("Otros Registros Importantes:  ",0,tblMain.size());

pc.addCols(" ",0,tblMain.size());
pc.setFont(9,1);
pc.addCols("RECOMENDACION R/R",1,tblMain.size());

String reqPers = "";
if (prop.getProperty("req_pers_0").equals("0")) reqPers = "[ X ] Enfermera      ";
else reqPers = "[   ] Enfermera      ";

if (prop.getProperty("req_pers_1").equals("1")) reqPers += "[ X ] Médico      ";
else reqPers += "[   ] Médico      ";

if (prop.getProperty("req_pers_2").equals("2")) reqPers += "[ X ] Anestesiólogo      ";
else reqPers += "[   ] Anestesiólogo      ";

if (prop.getProperty("req_pers_3").equals("3")) reqPers += "[ X ] Técnico      ";
else reqPers += "[   ] Técnico      ";

if (prop.getProperty("req_pers_4").equals("4")) reqPers += "[ X ] Escolta      ";
else reqPers += "[   ] Escolta      ";

pc.addCols("REQUERIMIENTO DE PERSONAL: ",0,tblMain.size());
pc.setFont(9,0);
pc.addCols(reqPers,0,tblMain.size());

reqPers = "";

if (prop.getProperty("req_equipos_0").equals("0")) reqPers = "[ X ] NINGUNO      ";
else reqPers = "[   ] NINGUNO      ";

if (prop.getProperty("req_equipos_1").equals("1")) reqPers += "[ X ] Oxigeno      ";
else reqPers += "[   ] Oxigeno      ";

if (prop.getProperty("req_equipos_2").equals("2")) reqPers += "[ X ] Monitor de transporte      ";
else reqPers += "[   ] Monitor de transporte      ";

if (prop.getProperty("req_equipos_3").equals("3")) reqPers += "[ X ] Ambulancia      ";
else reqPers += "[   ] Ambulancia      ";

if (prop.getProperty("req_equipos_4").equals("4")) reqPers += "[ X ] Otro  (especifique): "+prop.getProperty("observacion11");
else reqPers += "[   ] Otro   (especifique):";

pc.setFont(9,1);
pc.addCols(" ",0,tblMain.size());
pc.addCols("REQUERIMIENTO DE EQUIPOS: ",0,tblMain.size());
pc.setFont(9,0);
pc.addCols(reqPers,0,tblMain.size());

pc.setFont(9,1);
pc.addCols(" ",0,tblMain.size());
pc.addCols("RECOMENDACIONES (si se requiere): ",0,tblMain.size());
pc.setFont(9,0);
pc.addCols(prop.getProperty("observacion12"),0,tblMain.size());


pc.addTable();
if(isUnifiedExp){
		pc.close();
		response.sendRedirect(redirectFile);
}
%>