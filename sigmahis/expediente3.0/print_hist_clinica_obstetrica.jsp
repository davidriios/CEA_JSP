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
String subtitle = "HISTORIA CLÍNICA OBSTÉTRICA";
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

pc.setFont(9,1);
pc.addCols("PACIENTE VULNERABLE: "+(!cdoL.getColValue("formulario"," ").trim().equals("") && !cdoL.getColValue("formulario"," ").trim().equals("15")?"    [X] SI    [   ] NO":"        [   ] SI     [X] NO"),0,dHeader.size());

pc.setFont(9,0);
if (Integer.parseInt(edad) == 0 && Integer.parseInt(edadMes) <= 3) {
		pc.addCols("  -> PACIENTE NEONATO",0,dHeader.size());
}

ArrayList alL = SQLMgr.getDataList("select descripcion from tbl_sal_riesgo_vulnerab where codigo in("+cdoL.getColValue("formulario","-1")+")");
for (int l = 0; l<alL.size(); l++) {
		pc.setFont(9,0);
		cdoL = (CommonDataObject) alL.get(l);
		pc.addCols("     -> "+cdoL.getColValue("descripcion"," "),0,dHeader.size());
}
pc.setFont(9,1);
pc.addCols(" ",0,dHeader.size());

pc.addCols("VOLUNDAD MEDICA ANTICIPADA: "+(propL.getProperty("voluntades_anticipadas")!=null&&propL.getProperty("voluntades_anticipadas").equals("S")?"    [X] SI    [   ] NO":"    [   ] SI     [X] NO"),0,dHeader.size());
pc.addCols("RCP: "+(propL.getProperty("no_no0")!=null&&propL.getProperty("no_no0").equals("0")?"    [   ] SI     [X] NO":"        [X] SI    [   ] NO"),0,dHeader.size());

ArrayList alT = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_expediente_secciones where codigo in(1, 154, 63, 150, 7, 2, 4, 10, 89, 88, 155, 3, 16, 6, 27, 77, 163, 181, 182) order by codigo ");
Hashtable iT = new Hashtable();
for (int t = 0; t < alT.size(); t++) {
	CommonDataObject cdoT = (CommonDataObject) alT.get(t);
	iT.put(cdoT.getColValue("codigo"), cdoT.getColValue("descripcion"));
}

String group = "", admision = "", si = "", no = "";

// Enfermedad Actual
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("1"), 0, dHeader.size(),Color.gray);

pc.setFont(7, 1);
pc.addCols("Fecha: "+(cdo.getColValue("FECHA")==null?"":cdo.getColValue("FECHA")), 0, 1);
pc.addCols("Hora: "+(cdo.getColValue("HORA")==null?"":cdo.getColValue("HORA")), 0, 1);
pc.addCols("Usuario: "+cdo.getColValue("usuario_creacion"," ")+"/"+cdo.getColValue("usuario_modificacion"," "),1,2);

pc.addCols(" ",0,dHeader.size());

pc.setFont(7, 1);
pc.addCols("Dolencia Principal (Motivo de la consulta)", 0, dHeader.size());
pc.setFont(7, 0);
pc.addBorderCols(cdo.getColValue("DOLENCIA_PRINCIPAL"), 0, dHeader.size());

pc.addCols(" ",0,dHeader.size());

pc.setFont(7, 1);
pc.addCols("Historia de la Enfermedad Actual (inicio, síntomas, asistencia médica, hospitalización)", 0, dHeader.size());
pc.setFont(7, 0);
pc.addBorderCols(cdo.getColValue("observacion"), 0, dHeader.size());
// END Enfermedad Actual

// ANTECEDENTE GINECO-OBSTETRICO (3)
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("3"), 0, dHeader.size(),Color.gray);

sql  ="select CODIGO, GESTACION, PARTO, ABORTO, CESAREA, MENARCA, nvl(to_char(FUM,'dd/mm/yyyy'),' ') as FUM, nvl(CICLO,' ') CICLO, INICIO_SEXUAL,CONYUGES, nvl(to_char(FECHA_PAP,'dd/mm/yyyy'),' ') as FECHA_PAP, nvl(METODO,' ') METODO, nvl(decode(SUSTANCIAS,'S','SI','N','NO'),' ') SUSTANCIAS, nvl(OTROS,' ') OTROS, nvl(OBSERVACION,' ') OBSERVACION, ECTOPICO, edad_gestacional from TBL_SAL_ANTECEDENTE_GINECOLOGO where pac_id="+pacId+" and nvl(admision, "+noAdmision+") = "+noAdmision;

cdo  = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

Vector vTbl14 = new Vector();
vTbl14.addElement(".40");
vTbl14.addElement(".10");
vTbl14.addElement(".40");
vTbl14.addElement(".10");

pc.setNoColumnFixWidth(vTbl14);
pc.createTable("tbl14");

pc.setFont(7,1);
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
pc.addBorderCols("EDAD GESTACIONAL (semanas)",2,1,1f,0f,0f,0f);
pc.addBorderCols(cdo.getColValue("edad_gestacional"),0,1,1f,1f,1f,1f);

pc.setVAlignment(2);
pc.addCols(" ",0,dHeader.size());
pc.addBorderCols("OBSERVACION: "+cdo.getColValue("OBSERVACION"),0,2);
pc.addBorderCols("OTROS: "+cdo.getColValue("OTROS"),0,2);

pc.useTable("main");
pc.addTableToCols("tbl14",0,dHeader.size());
// END ANTECEDENTE GINECO-OBSTETRICO (3)

// ANTECEDENTE PATOLOGICOS
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("2"), 0, dHeader.size(),Color.gray);

sql="SELECT b.admision, a.codigo AS cod_antecedente, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion, decode(a.grupo,1,'PATOLOGICO','NO PATOLOGICO') as grupo_desc, a.grupo from TBL_SAL_DIAGNOSTICO_PERSONAL a, TBL_SAL_ANTECEDENTE_PERSONAL b where a.CODIGO = b.ANTECEDENTE AND b.PAC_ID = "+pacId+" /*and (b.admision = "+noAdmision+" or b.admision is null)*/ order by b.admision, a.grupo, a.orden ";

al = SQLMgr.getDataList(sql);

Vector vTbl2 = new Vector();
vTbl2.addElement(".40");
vTbl2.addElement(".05");
vTbl2.addElement(".05");
vTbl2.addElement(".50");

pc.setNoColumnFixWidth(vTbl2);
pc.createTable("tbl2");

pc.setFont(7,1);
pc.addBorderCols("DIAGNOSTICO",1,1);
pc.addBorderCols("SI",1,1);
pc.addBorderCols("NO",1,1);
pc.addBorderCols("OBSERVACION",1,1);

pc.setVAlignment(0);
pc.setFont(7, 0);

for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);

	 if(cdo.getColValue("valor").trim().equals("S")){ si = "x"; no = "";} else{si=""; no = "x";}

	 if(!admision.equals(cdo.getColValue("admision"))){
			pc.setFont(7, 1);
			if (i != 0) pc.addCols(" ",0,vTbl2.size());
			pc.addCols("ADM # "+cdo.getColValue("admision"," "),0,vTbl2.size());
	 }

	 if(!group.equals(cdo.getColValue("grupo"))){
			pc.setFont(7, 1);
			pc.addCols("    "+cdo.getColValue("grupo_desc"," "),0,vTbl2.size());
	 }

	 pc.setFont(7, 0);
	 pc.addCols("      "+cdo.getColValue("descripcion"," "),0,1);
	 pc.addCols("      "+si,1,1);
	 pc.addCols("      "+no,1,1);
	 pc.addCols("      "+cdo.getColValue("observacion"," "),0,1);

	 pc.addBorderCols("",0,vTbl2.size(),0.1f,0.0f,0.0f,0.0f);

	 admision = cdo.getColValue("admision");
	 group = cdo.getColValue("grupo");
}

pc.useTable("main");
pc.addTableToCols("tbl2",0,dHeader.size());
// END ANTECEDENTE PATOLOGICOS

// ANTECEDENTES FAMILIARES
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("7"), 0, dHeader.size(),Color.gray);

sql="SELECT a.codigo AS cod_antecedente, a.descripcion, nvl(b.valor,' ') AS valor, nvl(b.observacion,' ') as observacion from TBL_SAL_DIAGNOSTICO_FAMILIAR a, TBL_SAL_ANTECEDENTE_FAMILIAR b where a.CODIGO=b.ANTECEDENTE AND b.PAC_ID="+pacId+" order by a.orden";
al = SQLMgr.getDataList(sql);

Vector vTbl9 = new Vector();
vTbl9.addElement(".40");
vTbl9.addElement(".05");
vTbl9.addElement(".05");
vTbl9.addElement(".50");

pc.setNoColumnFixWidth(vTbl9);
pc.createTable("tbl9");

pc.setFont(7, 1);
pc.addBorderCols("DIAGNOSTICO",1,1);
pc.addBorderCols("SI",1,1);
pc.addBorderCols("NO",1,1);
pc.addBorderCols("OBSERVACION",1,1);

for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("valor"," ").trim().equals("S")){ si = "x"; no = "";} else{si=""; no = "x";}
		 pc.setFont(7, 0);
		 pc.addCols(cdo.getColValue("descripcion"),0,1);
		 pc.addCols(si,1,1);
		 pc.addCols(no,1,1);
		 pc.addCols(cdo.getColValue("observacion"),0,1);
}
pc.useTable("main");
pc.addTableToCols("tbl9",0,dHeader.size());
// END ANTECEDENTES FAMILIARES

// ANTECEDENTE QUIRURGICOS Y HOSPITALIZACION
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("4"), 0, dHeader.size(),Color.gray);

sql="select tipo_asa, plan, a.codigo, a.cod_paciente, to_char (a.fec_nacimiento, 'dd/mm/yyyy') as fec_nacimiento, a.edad, a.complicacion, a.observacion, a.tipo_registro, a.diagnostico, a.procedimiento, a.tipo_anestesia as tipoanestesia, to_char (a.fecha, 'dd/mm/yyyy') as fecha, a.pac_id, decode (a.tipo_registro, 'H', a.diagnostico, 'C', a.procedimiento) codregistro, c.descripcion as anestesia, decode(a.tipo_registro, 'H', a.desc_diag, 'C', a.desc_proc, nvl(a.desc_diag, a.desc_proc)) descRegistro from tbl_sal_cirugia_paciente a, tbl_sal_tipo_anestesia c where  a.tipo_anestesia = c.codigo(+) and pac_id = "+pacId+" order by codigo";

al = SQLMgr.getDataList(sql);

Vector vTbl3 = new Vector();
vTbl3.addElement("10");
vTbl3.addElement("30");
vTbl3.addElement("15");
vTbl3.addElement("8");
vTbl3.addElement("15");
vTbl3.addElement("30");
vTbl3.addElement("30");

pc.setNoColumnFixWidth(vTbl3);
pc.createTable("tbl3");

pc.setVAlignment(0);
pc.setFont(7,3);
pc.addCols("Tipo Registro: H = Hospitalizado, C=Cirugia",0,vTbl3.size());

pc.setFont(7, 0);
pc.addBorderCols("Tipo",1,1);
pc.addBorderCols("Diagnóstico",1,1);
pc.addBorderCols("Tipo Anestesia",1,1);
pc.addBorderCols("Edad",1,1);
pc.addBorderCols("Fecha",1,1);
pc.addBorderCols("Observación",1,1);
pc.addBorderCols("Complicación",1,1);

for(int i = 0; i < al.size(); i++){
	cdo = (CommonDataObject) al.get(i);

	pc.addCols(cdo.getColValue("tipo_registro"),1,1);
	pc.addCols(cdo.getColValue("descregistro"),0,1);
	pc.addCols(cdo.getColValue("tipoanestesia"),0,1);
	pc.addCols(cdo.getColValue("edad"),1,1);
	pc.addCols(cdo.getColValue("fecha"),1,1);
	pc.addCols(cdo.getColValue("observacion"),0,1);
	pc.addCols(cdo.getColValue("complicacion"),0,1);

	pc.addBorderCols("",1,vTbl3.size(),0.0f,0.5f,0.0f,0.0f,5.2f);
}

pc.useTable("main");
pc.addTableToCols("tbl3",0,dHeader.size());
// END ANTECEDENTE QUIRURGICOS Y HOSPITALIZACION

//ANTECEDENTE DE TRANSFUSION
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("16"), 0, dHeader.size(),Color.gray);

Vector vTbl15 = new Vector();
vTbl15.addElement(".08");
vTbl15.addElement(".40");
vTbl15.addElement(".52");

pc.setNoColumnFixWidth(vTbl15);
pc.createTable("tbl15");

sql = "select transfusion_id, pac_id, admision,to_char(fecha,'dd/mm/yyyy') fecha,documento documento1, decode(documento,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("expedientedocs").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||documento) as documento, observacion from tbl_sal_ant_transfusion where pac_id = "+pacId+" and admision = "+noAdmision;
al = SQLMgr.getDataList(sql);

pc.setFont(7, 1);
pc.addBorderCols("Fecha",0,1);
pc.addBorderCols("OBSERVACION",1,1);
pc.addBorderCols("DOCUMENTO",1,1);

for (int i=0; i < al.size(); i++){
		cdo = (CommonDataObject) al.get(i);

		pc.addCols(cdo.getColValue("fecha"),0,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);

		if ( !cdo.getColValue("documento1").equals("") ){
				pc.addImageCols(java.util.ResourceBundle.getBundle("path").getString("expedientedocs")+"/"+cdo.getColValue("documento1"),0,1);
		}else{
			pc.addCols("  ",1,1);
		}

		pc.addCols(" ",0,dHeader.size());
}

pc.useTable("main");
pc.addTableToCols("tbl15",0,dHeader.size());
//END ANTECEDENTE DE TRANSFUSION (16)


//ANTECEDENTE TRAUMATICOS (6)
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("6"), 0, dHeader.size(),Color.gray);

Vector vTbl16 = new Vector();
vTbl16.addElement(".08");
vTbl16.addElement(".10");
vTbl16.addElement(".25");
vTbl16.addElement(".25");
vTbl16.addElement(".10");

pc.setNoColumnFixWidth(vTbl16);
pc.createTable("tbl16");

pc.setFont(7, 1);
pc.addBorderCols("FECHA",0,1);
pc.addBorderCols("HORA",1,1);
pc.addBorderCols("TIPO DE TRAUMA",1);
pc.addBorderCols("OBSERVACION",1);
pc.addBorderCols("USUARIO",1);

for (int i=0; i < al.size(); i++){
		cdo = (CommonDataObject) al.get(i);
		pc.addCols(cdo.getColValue("fecha"),0,1);
		pc.addCols(cdo.getColValue("hora"),0,1);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		pc.addCols(cdo.getColValue("usuario"),1,1);
}

pc.useTable("main");
pc.addTableToCols("tbl16",0,dHeader.size());
//END ANTECEDENTE TRAUMATICOS (6)


//ANTECEDENTES MEDICAMENTOS (6)
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("27"), 0, dHeader.size(),Color.gray);

sql = "SELECT A.RENGLON, nvl(A.DESCRIPCION,' ') as descripcion, nvl(A.DOSIS,' ') as dosis, nvl(A.OBSERVACION,' ') as observacion, A.USUARIO_CREAC UC, to_char(A.FECHA_CREAC,'dd/mm/yyyy hh12:mi am') as FECHA_CREAC, A.USUARIO_MODIF, to_char(A.FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, decode(A.VIA_ADMIN,null,' ',''||A.via_admin) as via_admin, decode(A.COD_GRUPO_DOSIS,null,' ',''||A.cod_grupo_dosis) as cod_grupo_dosis, nvl(A.COD_FRECUENCIA,' ') as cod_frecuencia, decode(A.CADA,null,' ',''||A.cada) as cada, nvl(A.TIEMPO,' ') as tiempo, nvl(A.FRECUENCIA,' ') as frecuencia, B.DESCRIPCION as desp, C.DESCRIPCION AS FORMA FROM TBL_SAL_ANTECEDENT_MEDICAMENTO A , TBL_SAL_VIA_ADMIN B, TBL_SAL_GRUPO_DOSIS C  where C.CODIGO(+)=A.COD_GRUPO_DOSIS AND B.CODIGO(+)=A.VIA_ADMIN and pac_id="+pacId+" and nvl(a.admision, "+noAdmision+") = "+noAdmision+" ORDER BY A.FECHA_CREAC DESC";

al = SQLMgr.getDataList(sql);

Vector vTbl17 = new Vector();
vTbl17.addElement(".28");
vTbl17.addElement(".19");
vTbl17.addElement(".14");
vTbl17.addElement(".14");
vTbl17.addElement(".18");
vTbl17.addElement(".35");
vTbl17.addElement(".14");
vTbl17.addElement(".13");

pc.setNoColumnFixWidth(vTbl17);
pc.createTable("tbl17");

pc.setFont(7, 1);
pc.addCols("",0,vTbl17.size());
pc.addBorderCols("MEDICAMENTOS",1,1);
pc.addBorderCols("CONCENTRACIÓN",1,1); //5
pc.addBorderCols("FORMA",1,1);
pc.addBorderCols("FRECUENCIAS",1,1); // 2
pc.addBorderCols("VIA. ADMIN",1,1);
pc.addBorderCols("OBSERVACIÓN",1,1); //5
pc.addBorderCols("CREADO POR",1,1);
pc.addBorderCols("F. CREACIÓN",1,1);

for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);
		pc.setFont(7,0);
		pc.addCols(cdo.getColValue("descripcion"),0,1);
		pc.addCols(cdo.getColValue("dosis"),0,1);
		pc.addCols(cdo.getColValue("FORMA"),0,1);
		pc.addCols(cdo.getColValue("frecuencia"),0,1);
		pc.addCols(cdo.getColValue("desp"),0,1);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		pc.addCols(cdo.getColValue("UC"),0,1);
		pc.addCols(cdo.getColValue("FECHA_CREAC"),0,1);
}

pc.useTable("main");
pc.addTableToCols("tbl17",0,dHeader.size());
//END ANTECEDENTES MEDICAMENTOS(6)




// SIGNOS VITALES(77)
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("77"), 0, dHeader.size(),Color.gray);

sql = "select a.tipo_persona as tipoPersona, nvl(a.observacion,' ') as observacion, nvl(a.accion,' ') as accion, decode(a.categoria,'1','I','2','II','3','III',a.categoria) as categoria, decode(a.evacuacion,'S','[ X ]','[__]') as evacuacion, decode(a.miccion,'S','[ X ]','[__]') as miccion, decode(a.vomito,'S','[ X ]','[__]') as vomito, nvl(a.miccion_obs,' ') as miccionObs, nvl(a.vomito_obs,' ') as vomitoObs, nvl(a.evacuacion_obs,' ') as evacuacionObs , to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(a.hora_registro,'hh12:mi:ss am') as horaRegistro, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif,decode(a.dolor,'S','SI','NO') as dolor,a.escala, decode(a.preocupacion,'S', '[ X ]','[__]') preocupacion, nvl(preocupacion_obs,' ') preocupacionObs, nivel_conciencia nivelConciencia, dificultad_resp dificultadResp, loquios, proteinuria, liq_amnio liqAmnio from tbl_sal_signo_paciente a where a.pac_id = "+pacId+" and a.secuencia = "+noAdmision+" and a.status = 'A' order by a.fecha_registro desc, a.hora_registro desc";

al = sbb.getBeanList(ConMgr.getConnection(), sql, SignoPaciente.class);

Vector vTbl18 = new Vector();
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");
vTbl18.addElement(".10");

ArrayList alDet = new ArrayList();

pc.setNoColumnFixWidth(vTbl18);
pc.createTable("tbl18");

for(int i = 0; i<al.size(); i++){

			SignoPaciente sp = (SignoPaciente) al.get(i);

			sql = "select a.signo_vital as signoVital, a.tipo_persona as tipoPersona, nvl(a.resultado,' ') resultado, b.descripcion as signoDesc, nvl(c.sigla_um,' ') as signoUnit from tbl_sal_detalle_signo a, tbl_sal_signo_vital b, tbl_sal_signo_vital_um c where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.signo_vital=b.codigo and a.signo_vital=c.cod_signo(+) and c.valor_default(+)='S' and a.tipo_persona = '"+sp.getTipoPersona()+"' and to_date(to_char(a.fecha_signo,'dd/mm/yyyy'),'dd/mm/yyyy')  =  to_date('"+sp.getFecha()+"','dd/mm/yyyy') and to_date(to_char(a.hora,'dd/mm/yyyy hh12:mi:ss am'),'dd/mm/yyyy hh12:mi:ss am') =  to_date('"+sp.getFecha()+" "+sp.getHora()+"','dd/mm/yyyy hh12:mi:ss am') order by b.orden, a.fecha_signo, a.hora, a.signo_vital desc";//depends on header's status
			//System.out.println("sql = "+sql);
			alDet = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleSignoPaciente.class);

		 for (int j=0; j<alDet.size(); j++) {
				DetalleSignoPaciente spd = (DetalleSignoPaciente) alDet.get(j);
				if (sp.getTipoPersona().equals(spd.getTipoPersona())) sp.addDetalleSignoPaciente(spd);
		 } //end for j

		al.set(i,sp);
}//end for i

String tipoPersona = "";

for (int i = 0; i<al.size(); i++) {

	SignoPaciente sp = (SignoPaciente) al.get(i);
	if (sp.getTipoPersona().equalsIgnoreCase("T")) tipoPersona = "TRIAGE";
	else if (sp.getTipoPersona().equalsIgnoreCase("M")) tipoPersona = "MEDICO";
	else if (sp.getTipoPersona().equalsIgnoreCase("E")) tipoPersona = "ENFERMERA";
	else if (sp.getTipoPersona().equalsIgnoreCase("A")) tipoPersona = "AUXILIAR";
	else tipoPersona = 	sp.getTipoPersona();

	pc.setFont(9,1);
	pc.addBorderCols("No.: "+(1+i),0,vTbl18.size(),2f,0f,0f,0f,15.2f);

	pc.setFont();

		pc.addCols("Fecha/Hora Toma: ", 0,2);
	pc.addCols(sp.getFechaRegistro()+ " "+sp.getHoraRegistro(), 0, 2);
	pc.addCols("", 0, 2);
	pc.addCols("Registrado Por: ", 2, 2);
	pc.addCols(tipoPersona +" - "+ sp.getUsuarioCreacion(),0,2);

	pc.addCols("Evacuación: ",2,1);
	pc.addCols(sp.getEvacuacion(),0,1);
	pc.addCols("Observación: ",2,1);
	pc.addCols(sp.getEvacuacionObs(),0,7);

	pc.addCols("Micción: ",2,1);
	pc.addCols(sp.getMiccion(),0,1);
	pc.addCols("Observación:",2,1);
	pc.addCols(sp.getMiccionObs(),0,7);

		if(exp.trim().equals("3")){
				pc.addCols("Existe preocupación: ",2,1);
				pc.addCols(sp.getPreocupacion(),0,1);
				pc.addCols("Observación:",2,1);
				pc.addCols(sp.getPreocupacionObs(),0,7);
		}

	pc.addCols("Vómito: ",2,1);
	pc.addCols(sp.getVomito(),0,1);
	pc.addCols("Observación:",2,1);
	pc.addCols(sp.getVomitoObs(),0,7);

	pc.addCols("Dolor: ",2,1);
	pc.addCols(sp.getDolor(),0,1);
	pc.addCols(" Valor:",2,1);
	pc.addCols(sp.getEscala(),0,7);

		if(exp.equals("3")){
				if(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("0") ) pc.addCols("Nivel de conciencia:  [ X ] Normal       [___] Disminuido",0,10);
				else if(sp.getNivelConciencia() != null && sp.getNivelConciencia().equals("1") ) pc.addCols("Nivel de conciencia:  [___] Normal       [ X ] Disminuido",0,10);
				else  pc.addCols("Nivel de conciencia:  [___] Normal       [___] Disminuido",0,10);

				if(sp.getDificultadResp() != null && sp.getDificultadResp().equals("1") ) pc.addCols("Dificultad respiratoria:  [ X ] Severa/Moderada       [___] Leve/Ninguna",0,10);
				else if(sp.getDificultadResp() != null && sp.getDificultadResp().equals("0") ) pc.addCols("Dificultad respiratoria:  [___] Severa/Moderada       [ X ] Leve/Ninguna",0,10);
				else  pc.addCols("Dificultad respiratoria:  [___] Severa/Moderada       [___] Leve/Ninguna",0,10);

				if(sp.getLoquios() != null && sp.getLoquios().equals("0") ) pc.addCols("Loquios:  [ X ] Normal       [___] Aumentado / Falta",0,10);
				else if(sp.getLoquios() != null && sp.getLoquios().equals("3") ) pc.addCols("Loquios:  [___] Normal       [ X ] Aumentado / Falta",0,10);
				else  pc.addCols("Loquios:  [___] Normal       [___] Aumentado / Falta",0,10);

				if (sp.getProteinuria() == null) sp.setProteinuria("");

				pc.addCols("Proteinuria: "+sp.getProteinuria(),0,10);

				if(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("0") ) pc.addCols("Líquido amniótico:  [ X ] Claro / Rosa       [___] Verde",0,10);
				else if(sp.getLiqAmnio() != null && sp.getLiqAmnio().equals("3") ) pc.addCols("Líquido amniótico:  [___] Claro / Rosa       [ X ] Verde",0,10);
				else  pc.addCols("Líquido amniótico:  [___] Claro / Rosa       [___] Verde",0,10);


		}

		pc.setFont(7,1,Color.white);
	pc.addBorderCols("Signo Vital",1,3, Color.gray);
	pc.addBorderCols("Valor",1,1, Color.gray);
	pc.addBorderCols("",1,1, Color.gray);

	pc.addBorderCols((alDet.size()>1)?"Signo Vital":"  ",1,3, Color.gray);
	pc.addBorderCols((alDet.size()>1)?"Valor":"  ",1,1, Color.gray);
	pc.addBorderCols("",1,1, Color.gray);
	pc.setFont(7,0);


	for (int j=0; j<sp.getDetalleSignoPaciente().size(); j++) {
		DetalleSignoPaciente spd = sp.getDetalleSignoPaciente(j);

		pc.addCols(spd.getSignoDesc(),0,3);
		pc.addCols(spd.getResultado(),1,1);
		pc.addCols(spd.getSignoUnit(),0,1);
	} //end for

	if (sp.getDetalleSignoPaciente().size()%2 != 0) {
		pc.addCols("",0,3);
		pc.addCols("",1,1);
		pc.addCols("",0,1);
	}

	pc.addCols(" ",1,vTbl18.size(),7.2f);

} //end for 2nd i

pc.useTable("main");
pc.addTableToCols("tbl18",0,dHeader.size());
//END SIGNOS VITALES(77)

// EXAMEN FISICO 10
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("10"), 0, dHeader.size(),Color.gray);

sql = "select * from (select a.orden, c.sec_orden, a.codigo as codArea, 0 as codCarac, a.descripcion as areaDesc, nvl(b.normal,' ') as status, nvl(b.observaciones,' ') as areaObservacion from tbl_sal_examen_areas_corp a,(select normal, cod_area, observaciones from tbl_sal_areas_corp_paciente where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c  where a.codigo=b.cod_area(+) and a.codigo = c.cod_area  and c.centro_servicio ="+cds+" and a.usado_por in('T','M') union select a.orden, c.sec_orden, a.cod_area_corp, a.codigo, a.descripcion, nvl(b.seleccionar,' '), nvl(b.observacion,' ') from tbl_sal_caract_areas_corp a, (select seleccionar, cod_area_corp, observacion, cod_caract_corp from tbl_sal_prueba_fisica where pac_id="+pacId+" and secuencia="+noAdmision+") b, tbl_sal_examen_area_corp_x_cds c where a.cod_area_corp=b.cod_area_corp(+) and a.codigo=b.cod_caract_corp(+) and a.cod_area_corp = c.cod_area and c.centro_servicio ="+cds+" and a.codigo in (select distinct cod_caract from tbl_sal_caract_area_corp_x_cds where cod_area=a.cod_area_corp and centro_servicio="+cds+") and a.usado_por in('T','M') ) order by 2,3,4";

al = SQLMgr.getDataList(sql);

Vector vTbl6 = new Vector();
vTbl6.addElement("25"); //area
vTbl6.addElement("8"); //NE 10
vTbl6.addElement("8");//normal 10
vTbl6.addElement("10"); //anomral 10
vTbl6.addElement("30"); //caracteristica
vTbl6.addElement("5"); //si
vTbl6.addElement("5"); //no
vTbl6.addElement("35"); //observacion

pc.setNoColumnFixWidth(vTbl6);
pc.createTable("tbl6");

pc.setFont(7, 1);
pc.addBorderCols("Area",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("N/E",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Normal",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Anormal",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Característica",1 ,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("SI",1,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("NO",1,1, 0.8f, 0.8f, 0.8f, 0.8f);
pc.addBorderCols("Observación",1,1, 0.8f, 0.8f, 0.8f, 0.8f);

String noEvaluado="", normal="", anormal="" , area="";

for(int i = 0; i<al.size(); i++){

		cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("status").equals("")){
				noEvaluado = "x";
				normal = "";
				anormal = "";
				si= "";
				no= "";
		}

		if(cdo.getColValue("status").trim().equalsIgnoreCase("N")){
				noEvaluado = "";
				normal = "x";
				anormal = "";
				si= "";
				no= "";
		}

		if(cdo.getColValue("status").trim().equalsIgnoreCase("A")){
				noEvaluado = "";
				normal = "";
				anormal = "x";
				si= "";
				no= "";
		}
		pc.setFont(7, 0);

		if(cdo.getColValue("codCarac").equals("0")) {
				pc.addBorderCols(cdo.getColValue("areaDesc"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(noEvaluado,1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(normal,1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(anormal,1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(""+cdo.getColValue("areaObservacion"," "),0,1,0.5f,0.0f,0.0f,0.0f);
		}

		if (area.equals(cdo.getColValue("codArea"))){

				ArrayList alSubDet = SQLMgr.getDataList("select a.codigo, a.descripcion, d.seleccionar sub_status, d.observacion from tbl_sal_sub_carat_areas_corp a, tbl_sal_prueba_fisica_det d where d.cod_area_corp(+) = a.cod_area_corp and d.cod_sub_caract(+) = a.codigo and d.cod_caract_corp(+) = a.cod_caract and d.pac_id(+) = "+pacId+" and d.admision(+) = "+noAdmision+" and a.cod_area_corp = "+cdo.getColValue("codArea")+" and a.cod_caract = "+cdo.getColValue("codCarac")+" order by a.orden ");

				if(cdo.getColValue("status").trim().equalsIgnoreCase("S") ){
						si = "x";
						no = "";
				}else{
						si= "";
						no = "x";
				}

				pc.setFont(7, 1);
				pc.addCols(" ",0,1);
				pc.addCols("",0,1);
				pc.addCols("",0,1);
				pc.addCols("",0,1);
				pc.addBorderCols(cdo.getColValue("areaDesc"),0,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(si,1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(no,1,1,0.5f,0.0f,0.0f,0.0f);
				pc.addBorderCols(cdo.getColValue("areaObservacion"),0,1,0.5f,0.0f,0.0f,0.0f);

				for (int d = 0; d < alSubDet.size(); d++){
						CommonDataObject cdoD = (CommonDataObject) alSubDet.get(d);
						pc.setFont(7,0);
						pc.addCols(" ",0,4);
						pc.addBorderCols("       "+cdoD.getColValue("descripcion"),0,1);
						pc.addBorderCols(cdoD.getColValue("sub_status")!=null&&cdoD.getColValue("sub_status").trim().equalsIgnoreCase("S")?"x":"",1,1);
						pc.addBorderCols(cdoD.getColValue("sub_status")!=null&&cdoD.getColValue("sub_status").trim().equalsIgnoreCase("N")?"x":"",1,1);
						pc.addBorderCols("       "+cdoD.getColValue("observacion"),0,1);

				}

		}

		area = cdo.getColValue("codArea");
}//end for

pc.useTable("main");
pc.addTableToCols("tbl6",0,dHeader.size());
// END EXAMEN FISICO 10



// END EVALUACIÓN OBSTÉTRICA DE PARTO 163
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("163"), 0, dHeader.size(),Color.gray);

Vector vTbl19 = new Vector();
vTbl19.addElement("12");
vTbl19.addElement("8");
vTbl19.addElement("10");
vTbl19.addElement("10");
vTbl19.addElement("12");
vTbl19.addElement("8");
vTbl19.addElement("10");
vTbl19.addElement("10");
vTbl19.addElement("10");
vTbl19.addElement("10");

pc.setNoColumnFixWidth(vTbl19);
pc.createTable("tbl19");

al = SQLMgr.getDataList("select observacion, diag, diag_desc, presentacion, dilatacion,borramiento, estacion, variedad_posicion, decode(membranas,'R','ROTAS','I','INTEGRAS') membranas, decode(liquido,'C','CLARO','MECONIAL') liquido, USUARIO_CREACion, to_char(FECHA_CREACion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREACion, USUARIO_MODIFicacion, to_char(FECHA_MODIFicacion,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIFicacion, tiempo_ruptura from tbl_sal_eval_obstetrica_parto where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc");

for (int i = 0; i < al.size();  i++) {
		cdo = (CommonDataObject) al.get(i);
		if (i > 0) {
				pc.addCols(" ",1,vTbl19.size());
				pc.addCols("************************************************************************************************************",1,vTbl19.size());
				pc.addCols(" ",1,vTbl19.size());
		}

		pc.setFont(7,1);
		pc.addBorderCols("Fecha creación:   "+cdo.getColValue("fecha_creacion"," "),0,5);
		pc.addBorderCols("Creado por:   "+cdo.getColValue("usuario_creacion"," "),0,5);

		pc.setFont(7,1);
		pc.addBorderCols("Presentación:",0,1);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("presentacion"),0,1);

		pc.setFont(7,1);
		pc.addBorderCols("Dilatación:",0,1);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("dilatacion"),0,1);

		pc.setFont(7,1);
		pc.addBorderCols("Borramiento:",0,1);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("Borramiento"),0,1);

		pc.setFont(7,1);
		pc.addBorderCols("Estación:",0,1);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("estacion"),0,1);
		pc.addBorderCols(" ", 0, 2);

		pc.setFont(7,1);
		pc.addBorderCols("Variedad de Posición:", 0, 2);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("variedad_posicion"),0,vTbl19.size() - 2);

		pc.setFont(7,1);
		pc.addBorderCols("Membranas:", 0, 2);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("membranas"),0,2);

		pc.setFont(7,1);
		pc.addBorderCols("Tiempo de Ruptura:", 0, 1);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("tiempo_ruptura"),0,1);

		pc.setFont(7,1);
		pc.addBorderCols("Líquido:", 0, 1);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("liquido"),0,3);

		pc.setFont(7,1);
		pc.addBorderCols("Plan de Manejo:", 0, 2);
		pc.setFont(7,0);
		pc.addBorderCols(cdo.getColValue("observacion"),0,vTbl19.size() - 2);
}

pc.useTable("main");
pc.addTableToCols("tbl19",0,dHeader.size());
// END EVALUACIÓN OBSTÉTRICA DE PARTO 163

//HOJA DE LABOR 1 (181)
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
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
sql="select to_char(a.fecha_hist,'dd/mm/yyyy') as fechahist, a.cod_hist as codhist, a.secuencia as secuencia, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, a.cuello_dilata as cuellodilata, a.seg_inf as seginf, a.pre_pos_plan as preposplan, a.foco_fetal as focofetal, a.func_contrac as funccontrac, a.membr as membr, a.temp as temp, a.observacion as observacion, a.presion_arterial presionArterial, decode(a.tipo_parto,'V','VAGINAL','C','CESAREA') tipoParto, a.motivo_cesarea motivoCesarea from tbl_sal_hist_obst_tactos a, TBL_SAL_HISTORIA_OBSTETRICA_m b where b.pac_id="+pacId+" and a.pac_id="+pacId+" and a.cod_hist=b.codigo and a.pac_id=b.pac_id and a.cod_hist="+cdo2.getColValue("codigo", "0");

al = SQLMgr.getDataList(sql);



pc.setNoColumnFixWidth(vTbl20);
pc.createTable("tbl20");

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
	pc.addCols("CARA BREGMA",0,1);
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
	pc.addCols("EPISIOTOMIA  NO",0,1);

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

	pc.addCols("MEDIO LATERAL",0,1);
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

	pc.addCols("EPISIORRAFIA",0,2);
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
	/*pc.setFont(7, 0);
	pc.addCols("EPISOGRAFIA: (Describa)    "+(cdo2.getColValue("episografia")==null?"":cdo2.getColValue("episografia")+"°"),0,vTbl20.size());
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl20.size(),0.0f,0.5f,0.0f,0.0f);*/
	pc.setFont(7, 1);

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
pc.addTableToCols("tbl20",0,vTbl20.size());
//HOJA DE LABOR 1 (14)


//HOJA DE LABOR 2 (182)
pc.addCols(" ",0,dHeader.size());
pc.setFont(9,1, Color.white);
pc.addCols(""+iT.get("182"), 0, dHeader.size(),Color.gray);

sql="select a.cod_paciente, a.fec_nacimiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, decode(a.sexo,'M','MASCULINO','F','FEMENINO','I','INDEFINIDO') sexo, a.peso, a.talla, a.condicion, a.apgar as apgar1, a.apgar5 as apgar2, decode(a.alumbramiento,'ES','Espontáneo', 'AR','Artificial','ME','Maniobras Externas','EM','Extracción Manual de Anexos','CO','Completa','DG','Dirigido') as alumbramiento, a.utero, a.consulta, a.observa_consulta as observConsulta, a.cavidad_uterina as cavidad, a.observa_cavidad as cavidU, a.cicatriz_ant as cicatriz, a.observa_cicatriz as cicatrizAnt, a.ruptura_uterina as ruptura, a.observa_ruptura as observRuptura, a.consulta_ruptura as conductaRuptura, a.observa_rup_uterina as obsvConducta, a.conducta as conductaCica, a.conducta_obsv as observaConducta, a.cuello, a.tratamiento_cuello as observCuello, a.vagina, a.tratamiento_vagina as observVagina, a.perine, tratamiento_perine as observPerine, a.recto, a.tratamiento_recto as observRect, a.medico as codMedico, a.alumbramiento_obsv as observ, a.pac_id,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion,to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, a.alumbramiento_min minutos, decode(a.vigoroso,'S','SI', 'N','NO') vigoroso, a.observacion , perimetro_toracico, tiempo_vida, perimetro_cefalico, decode(eval_riesgo,'C','CON RIESGO','SIN RIESGO') eval_riesgo, decode(rcp,'S','SI','N','NO') rcp, lugar_permanencia, lugar_transf, to_char(fecha_transf,'dd/mm/yyyy hh12:mi:ss am') fecha_transf, decode(tipo_nacimiento,'S','SIMPLE','M','MULTIPLE') tipo_nacimiento, orden_nac, to_char(hora,'hh12:mi:ss am') hora, to_char(a.fecha,'dd/mm/yyyy') fecha, usuario_creacion,usuario_modificacion from tbl_sal_historia_nacido a where a.pac_id = "+pacId;

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

pc.setFont(7, 1);

pc.addCols("Creado el:    "+cdo2.getColValue("fechacreacion"),0,6);
pc.addCols("Creado por:    "+cdo2.getColValue("usuario_creacion"),1,7);
pc.addCols("Modificado el:    "+cdo2.getColValue("fecha_modificacion"),0,6);
pc.addCols("Modificado por:    "+cdo2.getColValue("usuario_modificacion"),1,7);
pc.addCols(" ",0,13);

pc.setFont(7,1,Color.WHITE);
pc.addBorderCols("DATOS RECIEN NACIDO",0,13,Color.gray);

pc.setFont(7, 1);
pc.addBorderCols("Fecha:    "+cdo2.getColValue("fecha"),0,4);
pc.addBorderCols("Hora:    "+cdo2.getColValue("hora"),0,6);
pc.addBorderCols("Sexo:    "+cdo2.getColValue("sexo"),0,3);

pc.setFont(7,1,Color.WHITE);
pc.addBorderCols("Datos antropométricos al nacer",0,13,Color.gray);

pc.setFont(7, 0);

pc.addBorderCols("Peso:    "+cdo2.getColValue("peso"),0,6);
pc.addBorderCols("Perímetro torácito:    "+cdo2.getColValue("perimetro_toracico"),0,7);
pc.addBorderCols("Talla:    "+cdo2.getColValue("talla"),0,6);
pc.addBorderCols("Perímetro cefálico:    "+cdo2.getColValue("perimetro_cefalico"),0,7);

pc.addCols(" ",0,vTbl21.size());

pc.addBorderCols("Vigoroso: "+cdo2.getColValue("vigoroso"," "),0,4);
pc.addBorderCols("Apgar 1:   ",0,1);
pc.addBorderCols(cdo2.getColValue("apgar1"," "),0,1);
pc.addBorderCols("Apgar 2:   ",0,2);
pc.addBorderCols(cdo2.getColValue("apgar2"," "),0,2);
pc.addBorderCols("  ",0,3);

pc.addCols(" ",0,13,cHeight);
pc.setFont(7,1,Color.WHITE);
pc.addBorderCols("REVISION POST PARTO: ",0,13,Color.gray);
pc.setFont(7,0);
//cHeight=20.0f;
pc.setVAlignment(1);
pc.addBorderCols("UTERO:  BIEN CONTRAIDO",0,2,0.0f,0.0f,0.5f,0.0f);

pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("utero") != null && cdo2.getColValue("utero").trim().equals("C"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	//pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("HIPOTONICO",0,1);
		pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("utero") != null && cdo2.getColValue("utero").trim().equals("H"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	//pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addCols("CONSULTA:    MÈDICA",1,3);

	pc.setVAlignment(1);
		pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("consulta") != null && cdo2.getColValue("consulta").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	//pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addCols("QUIRÙRGICA",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("consulta") != null && cdo2.getColValue("consulta").trim().equals("Q"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	//pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.addBorderCols("(Describa) ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);

	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f,cHeight);
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(7,0);

	pc.setVAlignment(1);
	pc.addBorderCols("CAVIDAD UTERINA:",0,3,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	/*pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("LI"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);*/
	//pc.setFont(7,0);
	pc.resetVAlignment();
		pc.addBorderCols(" ",0,10,0.0f,0.0f,0.0f,0.5f);


	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.5f,0.5f);
	pc.setFont(7,0);

	pc.setVAlignment(1);
	pc.addBorderCols("CON RESTOS PLACENTAROS",0,2,0.0f,0.0f,0.5f,0.0f,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("RP"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("REMOVIDOS TOTALMENTE",0,2,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("RT"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addCols("MANUAL",1,2);

	pc.setVAlignment(1);
		pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("MA"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addCols("INTRUMENTAL",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cavidad") != null && cdo2.getColValue("cavidad").trim().equals("IN"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	String cavidU = "";
	if(cdo2.getColValue("cavidU")==null){cavidU="n/a";}
	else{cavidU = cdo2.getColValue("cavidU");}

	pc.addBorderCols("(Describa) "+cavidU,0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);

	/*pc.addBorderCols("CICATRIZ ANTERIOR",0,vTbl21.size());

	pc.setVAlignment(1);
	pc.addBorderCols("INDEMNE",0,1,0.0f,0.0f,0.5f,0.0f,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("DESHISCENCIA DE CICATRIZ ANTERIOR",0,2,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("D"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addCols("PARCIAL (NO TRASPASA MIOMETRIO) ",1,3);

	pc.setVAlignment(1);
		pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("P"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	pc.addCols("AMPLIA (TRASPASA MIOMETRIO)",2,2,cHeight);
	pc.setVAlignment(1);
		pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cicatriz") != null && cdo2.getColValue("cicatriz").trim().equals("A"))
			pc.addInnerTableBorderCols("x",2,1);
	else pc.addInnerTableBorderCols(" ",2,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	
	pc.addBorderCols(" ",0,1,0.0f,0.0f,0.0f,0.5f,cHeight);

	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);




	pc.setVAlignment(1);
	pc.addCols("CONDUCTA",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaCica") != null && cdo2.getColValue("conductaCica").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("QUIRÚRGICA",0,1,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaCica") != null && cdo2.getColValue("conductaCica").trim().equals("Q"))
			pc.addInnerTableBorderCols(" ",0,1,5.0f,5.0f,5.0f,5.0f);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	String observaConducta = "";
	if(cdo2.getColValue("observaConducta") == null) observaConducta = "n/a";
	else observaConducta = cdo2.getColValue("observaConducta");

	pc.addCols("(Describa)  "+observaConducta,0,8);
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
*/
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);

	pc.setVAlignment(1);
	pc.addCols("RUPTURA UTERINA",0,2);
	pc.addCols("NO",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ruptura") != null && cdo2.getColValue("ruptura").trim().equals("N"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("SI",2,1,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("ruptura") != null && cdo2.getColValue("ruptura").trim().equals("S"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	String   observRuptura ="";
	if(cdo2.getColValue("observRuptura")==null)observRuptura = "n/a";
	else observRuptura =cdo2.getColValue("observRuptura");

	pc.addCols("(Describa)  "+observRuptura,0,7);
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);


	pc.setVAlignment(1);
	pc.addCols("CONDUCTA:",0,1);
	pc.addCols("MEDICA",0,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaRuptura") != null && cdo2.getColValue("conductaRuptura").trim().equals("M"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("QUIRÚRGICA",0,1,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("conductaRuptura") != null && cdo2.getColValue("conductaRuptura").trim().equals("Q"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	String obsvConducta = "";
	if(cdo2.getColValue("obsvConducta")==null) obsvConducta = "n/a";
	else obsvConducta = cdo2.getColValue("obsvConducta");

	pc.addCols("(Describa)  "+obsvConducta,0,8);
	pc.setFont(0, 0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);

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
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("LACERADO",2,1,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("cuello") != null && cdo2.getColValue("cuello").trim().equals("L"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	String observCuello = "";
	if(cdo2.getColValue("observCuello")==null) observCuello = "n/a";
	else observCuello = cdo2.getColValue("observCuello");

	pc.addCols("Descripcion y tratamiento: "+observCuello,0,8);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.setVAlignment(1);
	pc.addCols("VAGINA",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("vagina") != null && cdo2.getColValue("vagina").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
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
	pc.setFont(7,0);
	pc.resetVAlignment();

	String observVagina = "";
	if(cdo2.getColValue("observVagina")==null) observVagina = "n/a";
	else observVagina = cdo2.getColValue("observVagina");

	pc.addCols("Descripcion y tratamiento  "+observVagina,0,8);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.setVAlignment(1);
	pc.addCols("PERINE",0,1);
	pc.addCols("INDEMNE",2,1);
	//pc.addCols("BIEN CONTRAIDO",0,1,cHeight);
	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("perine") != null && cdo2.getColValue("perine").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("LACERADO",2,1,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("perine") != null && cdo2.getColValue("perine").trim().equals("L"))
			pc.addInnerTableBorderCols(" ",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	String observPerine = "";
	if(cdo2.getColValue("observPerine")==null) observPerine = "n/a";
	else observPerine = cdo2.getColValue("observPerine");

	pc.addCols("Descripcion y tratamiento  "+observPerine,0,8);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.setVAlignment(1);
	pc.addCols("ANO-RECTO",0,1);
	pc.addCols("INDEMNE",2,1);
	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("recto") != null && cdo2.getColValue("recto").trim().equals("I"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();
	pc.addCols("LACERADO",2,1,cHeight);

	pc.setVAlignment(1);
	pc.setFont(7,1);
	pc.setNoInnerColumnFixWidth(setBox);
	pc.createInnerTable();
	if(cdo2.getColValue("recto") != null && cdo2.getColValue("recto").trim().equals("L"))
			pc.addInnerTableBorderCols("x",0,1);
	else pc.addInnerTableBorderCols(" ",0,1);
	pc.addInnerTableToCols(1);
	pc.setFont(7,0);
	pc.resetVAlignment();

	String observRect = "";
	if(cdo2.getColValue("observRect")==null)observRect = "n/a";
	else observRect = cdo2.getColValue("observRect");

	pc.addCols("Descripcion y tratamiento  "+observRect,0,8);
	pc.setFont(0, 0);
	pc.addBorderCols("",0,vTbl21.size(),0.0f,0.5f,0.0f,0.0f);
	pc.setFont(7,0);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);
	pc.addBorderCols(" ",0,vTbl21.size(),0.5f,0.0f,0.0f,0.0f);

	pc.addCols(" ",0,vTbl21.size());

		pc.setFont(7,1,Color.WHITE);
	pc.addBorderCols("ALUMBRAMIENTO",0,13,Color.gray);

		pc.setFont(7, 0);
		pc.addBorderCols("Alumbramiento: ",0,2);
		pc.addBorderCols(cdo2.getColValue("alumbramiento"),0,3);
		pc.addBorderCols(cdo2.getColValue("observ"),0,8);
		pc.addBorderCols("Minutos para el Alumbramiento: ",0,3);
		pc.addBorderCols(cdo2.getColValue("minutos"),0,10);


pc.useTable("main");
pc.addTableToCols("tbl21",0,dHeader.size());
// END HOJA DE LABOR 2 (15)


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