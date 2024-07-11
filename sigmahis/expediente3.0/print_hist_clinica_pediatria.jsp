<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
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
String subtitle = "HISTORIA CLÍNICA PEDIATRIA";
String xtraSubtitle = desc;
	
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

ArrayList alT = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_expediente_secciones where codigo in(1, 154, 63, 150, 7, 2, 4, 10, 89, 88, 155) ");
Hashtable iT = new Hashtable();
for (int t = 0; t < alT.size(); t++) {
  CommonDataObject cdoT = (CommonDataObject) alT.get(t);
  iT.put(cdoT.getColValue("codigo"), cdoT.getColValue("descripcion"));
}

String group = "", admision = "", si = "", no = "";    

// Enfermedad Actual
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("1"), 0, dHeader.size(),Color.gray);

pc.setFont(8, 1);
pc.addCols("Fecha: "+(cdo.getColValue("FECHA")==null?"":cdo.getColValue("FECHA")), 0, 1);
pc.addCols("Hora: "+(cdo.getColValue("HORA")==null?"":cdo.getColValue("HORA")), 0, 1);
pc.addCols("Usuario: "+cdo.getColValue("usuario_creacion"," ")+"/"+cdo.getColValue("usuario_modificacion"," "),1,2);

pc.addCols(" ",0,dHeader.size());
		
pc.setFont(8, 1);
pc.addCols("Dolencia Principal (Motivo de la consulta)", 0, dHeader.size());
pc.setFont(8, 0);
pc.addBorderCols(cdo.getColValue("DOLENCIA_PRINCIPAL"), 0, dHeader.size());
		
pc.addCols(" ",0,dHeader.size());

pc.setFont(8, 1);
pc.addCols("Historia de la Enfermedad Actual (inicio, síntomas, asistencia médica, hospitalización)", 0, dHeader.size());
pc.setFont(8, 0);
pc.addBorderCols(cdo.getColValue("observacion"), 0, dHeader.size());
// END Enfermedad Actual

// Historia Familiar
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("154"), 0, dHeader.size(),Color.gray); 

sql = "select d.admision, p.codigo, p.descripcion, d.edad, d.vivo_muerto, d.cod_grupo_sang, s.tipo_sangre from tbl_sal_parentesco p, tbl_sal_hist_familiar_det d, tbl_bds_tipo_sangre s where p.estado = 'A' and d.cod_grupo_sang = s.sangre_id(+) and p.codigo = d.cod_parentesco and d.pac_id = "+pacId+" and d.admision = "+noAdmision+" order by d.admision desc, p.codigo";
al = SQLMgr.getDataList(sql);

Vector vTbl11 = new Vector();
vTbl11.addElement(".55");
vTbl11.addElement(".05");
vTbl11.addElement(".10");
vTbl11.addElement(".30");

pc.setNoColumnFixWidth(vTbl11);
pc.createTable("tbl11");

pc.setFont(8, 1);
pc.addBorderCols("Parentesco",0,1);
pc.addBorderCols("Edad",1,1);
pc.addBorderCols("Vivo",1,1);
pc.addBorderCols("Grupo Sanguineo RH",0,1);

String admGroup = "";

for (int i=0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);

    /*if (!admGroup.equals(cdo.getColValue("admision"))){
        pc.setFont(8, 1);
        pc.addBorderCols("ADM #: "+cdo.getColValue("admision"),0,dHeader.size());
    }*/
    pc.setFont(8, 0);
    pc.addBorderCols(cdo.getColValue("descripcion"),0,1);
    pc.addBorderCols(cdo.getColValue("edad"),1,1);
    pc.addBorderCols(cdo.getColValue("vivo_muerto"),1,1);
    pc.addBorderCols(cdo.getColValue("tipo_sangre"),1,1);

    admGroup = cdo.getColValue("admision");
}

pc.useTable("main");
pc.addTableToCols("tbl11",0,dHeader.size());
// END Historia Familiar

// ANTECEDENTES ENFERMEDADES
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("63"), 0, dHeader.size(),Color.gray);

sql = "select b.id, b.descripcion, a.pac_id, a.admision, nvl(a.seleccionado,'N') as seleccionado, a.observacion, b.evaluable, b.comentable, a.usuario_creacion from tbl_sal_enfermedad_operacion a, tbl_sal_parametro b where a.pac_id="+pacId+" and b.tipo = 'PEO' and  a.parametro_id = b.id and b.status = 'A' order by b.orden";
al = SQLMgr.getDataList(sql);

Vector vTbl12 = new Vector();
vTbl12.addElement("42");
vTbl12.addElement("3");
vTbl12.addElement("3");
vTbl12.addElement("42");
vTbl12.addElement("10");

pc.setNoColumnFixWidth(vTbl12);
pc.createTable("tbl12");

pc.setFont(8, 1);
pc.addBorderCols("Descripción",1,1);
pc.addBorderCols("Si",1,1);
pc.addBorderCols("No",1,1);
pc.addBorderCols("Observación",1,1);
pc.addBorderCols("Usuario",1,1);

for(int i = 0; i<al.size(); i++){
  cdo = (CommonDataObject)al.get(i);

  if(cdo.getColValue("seleccionado").trim().equalsIgnoreCase("S")){
     si = "x";
     no = "";
  }else{
     si = "";
     no = "x";
  }

  pc.setFont(8, 0);
  pc.addBorderCols(cdo.getColValue("descripcion"),0,1,0.5f,0.0f,0.0f,0.0f);
  pc.addBorderCols(si,1,1,0.5f,0.0f,0.0f,0.0f);
  pc.addBorderCols(no,1,1,0.5f,0.0f,0.0f,0.0f);
  pc.addBorderCols(cdo.getColValue("observacion"),0,1,0.5f,0.0f,0.0f,0.0f);
  pc.addBorderCols(cdo.getColValue("usuario_creacion"),1,1,0.5f,0.0f,0.0f,0.0f);
}//end for


pc.useTable("main");
pc.addTableToCols("tbl12",0,dHeader.size());
// END ANTECEDENTES ENFERMEDADES

// ANTECEDENTE PERINATALES
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("150"), 0, dHeader.size(),Color.gray);

Properties prop = SQLMgr.getDataProperties("select antecedentes from tbl_sal_ant_perinatales where pac_id="+pacId+" and admision = "+noAdmision);
if (prop == null) prop = new Properties();

Vector vTbl13 = new Vector();
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");
vTbl13.addElement(".10");

pc.setNoColumnFixWidth(vTbl13);
pc.createTable("tbl13", true);

pc.setFont(9, 1);
pc.addCols("Creado por:", 0, 1);
pc.addCols(prop.getProperty("usuario_creacion"), 0, 1);

pc.addCols("Creado el:", 2, 1);
pc.addCols(prop.getProperty("fecha_creacion"), 0, 2);

pc.addCols("Modif. por:", 0, 1);
pc.addCols(prop.getProperty("usuario_modificacion"), 0, 1);

pc.addCols("Modif. el:", 2, 1);
pc.addCols(prop.getProperty("fecha_modificacion"), 0, 2);

pc.addCols(" ", 0, vTbl13.size());

pc.setFont(8, 1);
pc.addCols("DATOS MATERNOS DEL PACIENTE PEDIÁTRICO", 0, vTbl13.size());

pc.setFont(8, 0);
pc.addCols("G-Grava:", 0, 1);
pc.addCols(prop.getProperty("observacion11"), 0, 1);
pc.addCols("P-Para:", 0, 1);
pc.addCols(prop.getProperty("observacion12"), 0, 1);
pc.addCols("C-Cesarea:", 0, 1);
pc.addCols(prop.getProperty("observacion13"), 0, 1);
pc.addCols("A-Aborto:", 0, 1);
pc.addCols(prop.getProperty("observacion14"), 0, 1);
pc.addCols("", 0, 2);

pc.addCols(" ", 0, vTbl13.size());
pc.setFont(8, 1);
pc.addCols("DATOS DEL NACIMIENTO DEL PACIENTE PEDIATRICO", 0, vTbl13.size());
pc.setFont(8, 0);

if (prop.getProperty("parto")!=null&&prop.getProperty("parto").equalsIgnoreCase("PV")) {
  pc.addBorderCols("Parto Vaginal: ", 0, 1);
  pc.addBorderCols(prop.getProperty("observacion0"), 0, vTbl13.size()-1);
} else if (prop.getProperty("parto")!=null&&prop.getProperty("parto").equalsIgnoreCase("PC")) {
  pc.addBorderCols("Parto Cesárea: ", 0, 1);
  pc.addBorderCols(prop.getProperty("observacion1"), 0, vTbl13.size()-1);
}

pc.addBorderCols("Edad Gestacional al nacer (semanas):", 0, 3);
pc.addBorderCols(prop.getProperty("observacion21"), 0, vTbl13.size() - 3);

pc.addBorderCols("Peso al nacer:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion2"), 0, vTbl13.size() - 2);
pc.addBorderCols("Tall al nacer:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion3"), 0, vTbl13.size() - 2);
pc.addBorderCols("Perímetro cefálico:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion4"), 0, vTbl13.size() - 2);
pc.addBorderCols("Perímetro torácico:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion5"), 0, vTbl13.size() - 2);
pc.addBorderCols("Condición al nacer:", 0, 2);
pc.addBorderCols(prop.getProperty("observacion6"), 0, vTbl13.size() - 2);

pc.addBorderCols("APGAR:", 0, 1);
pc.addBorderCols(prop.getProperty("observacion7"), 1, 1);
pc.addBorderCols("Detallar:", 1, 1);
pc.addBorderCols(prop.getProperty("observacion8"), 0, vTbl13.size() - 3);

pc.addCols("", 0, vTbl13.size());

pc.setFont(8, 1);
pc.addCols("REANIMADO", 0, vTbl13.size());
pc.setFont(8, 0);

pc.addBorderCols(prop.getProperty("reanimado").equals("0") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("No require", 0, vTbl13.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("1") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Máscara simple", 0, vTbl13.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("2") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Máscara de Presión Positiva", 0, vTbl13.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("3") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Intubación endotraqueal", 0, vTbl13.size() - 1);
pc.addBorderCols(prop.getProperty("reanimado").equals("4") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("CPAP", 0, vTbl13.size() - 1);

pc.addBorderCols(prop.getProperty("reanimado").equals("OT") ? " [ X ] " : "[     ]", 0, 1);
pc.addBorderCols("Otros", 0, 1);
pc.addBorderCols(prop.getProperty("observacion9"), 0, vTbl13.size() - 2);

if (prop.getProperty("complicaion")!=null&&prop.getProperty("complicaion").equalsIgnoreCase("0")) {
  pc.setFont(8, 1);
  pc.addCols(" ", 0, vTbl13.size());
  pc.addCols("Complicaciones al nacer:", 0, 2);  
  pc.addCols("NINGUNA", 0, vTbl13.size()-2);
  
} else if (prop.getProperty("complicaion")!=null&&prop.getProperty("complicaion").equalsIgnoreCase("1")) {
  pc.setFont(8, 1);
  pc.addCols(" ", 0, vTbl13.size());
  pc.addCols("Complicaciones al nacer:", 0, 2);  
  pc.addCols("SI", 1, 1);
  pc.addCols(prop.getProperty("observacion10"), 0, vTbl13.size() - 3);
}

pc.addCols(" ", 0, vTbl13.size());
pc.setFont(8, 1);
pc.addCols("DATOS DEL DESARROLLO DEL PACIENTE PEDIATRICO", 0, vTbl13.size());
pc.setFont(8, 0);

pc.addBorderCols("Sostén Cefálico (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion15"), 0, vTbl13.size() - 2);

pc.addBorderCols("Primer Diente (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion16"), 0, vTbl13.size() - 2);

pc.addBorderCols("Se sentó (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion17"), 0, vTbl13.size() - 2);

pc.addBorderCols("Primeras Palabras (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion18"), 0, vTbl13.size() - 2);

pc.addBorderCols("Caminó (meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion19"), 0, vTbl13.size() - 2);

pc.addBorderCols("Control de esfínteres(meses):", 0, 2);
pc.addBorderCols(prop.getProperty("observacion20"), 0, vTbl13.size() - 2);

pc.addCols(" ", 0, vTbl13.size());
pc.setFont(8, 1);
pc.addCols("ALIMENTACIÓN", 0, vTbl13.size());
pc.setFont(8, 0);

if (prop.getProperty("pecho")!=null&&prop.getProperty("pecho").equalsIgnoreCase("0")) {
  pc.setFont(8, 1);
  pc.addBorderCols("PECHO", 0, vTbl13.size());
  
} else if (prop.getProperty("pecho")!=null&&prop.getProperty("pecho").equalsIgnoreCase("1")) {
  pc.setFont(8, 1);
  pc.addBorderCols("PECHO + FORMULA", 0, vTbl13.size());
}


pc.setFont(8, 1);
pc.addBorderCols("Diestas suaves:", 0, 2);
pc.setFont(8, 0);
pc.addBorderCols(prop.getProperty("observacion22"), 0, vTbl13.size() - 2);

pc.setFont(8, 1);
pc.addBorderCols("Dieta actual:", 0, 2);
pc.setFont(8, 0);
pc.addBorderCols(prop.getProperty("observacion23"), 0, vTbl13.size() - 2);
















pc.useTable("main");
pc.addTableToCols("tbl13",0,dHeader.size());
// END ANTECEDENTE PERINATALES


// ANTECEDENTES FAMILIARES
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
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

pc.setFont(8, 1);
pc.addBorderCols("DIAGNOSTICO",1,1);
pc.addBorderCols("SI",1,1);
pc.addBorderCols("NO",1,1);
pc.addBorderCols("OBSERVACION",1,1);

for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);

		if(cdo.getColValue("valor"," ").trim().equals("S")){ si = "x"; no = "";} else{si=""; no = "x";}
     pc.setFont(8, 0);
	   pc.addCols(cdo.getColValue("descripcion"),0,1);
	   pc.addCols(si,1,1);
	   pc.addCols(no,1,1);
	   pc.addCols(cdo.getColValue("observacion"),0,1);
}
pc.useTable("main");
pc.addTableToCols("tbl9",0,dHeader.size());
// END ANTECEDENTES FAMILIARES


// ANTECEDENTE PATOLOGICOS
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
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

pc.setFont(8,1);
pc.addBorderCols("DIAGNOSTICO",1,1);
pc.addBorderCols("SI",1,1);
pc.addBorderCols("NO",1,1);
pc.addBorderCols("OBSERVACION",1,1);

pc.setVAlignment(0);
pc.setFont(8, 0);
      
for (int i=0; i<al.size(); i++){
		cdo = (CommonDataObject) al.get(i);

   if(cdo.getColValue("valor").trim().equals("S")){ si = "x"; no = "";} else{si=""; no = "x";}
     
   if(!admision.equals(cdo.getColValue("admision"))){
      pc.setFont(8, 1);
      if (i != 0) pc.addCols(" ",0,vTbl2.size());
      pc.addCols("ADM # "+cdo.getColValue("admision"," "),0,vTbl2.size());
   } 
     
   if(!group.equals(cdo.getColValue("grupo"))){
      pc.setFont(8, 1);
      pc.addCols("    "+cdo.getColValue("grupo_desc"," "),0,vTbl2.size());
   } 

   pc.setFont(8, 0);
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

// ANTECEDENTE QUIRURGICOS Y HOSPITALIZACION
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
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
pc.setFont(8,3);
pc.addCols("Tipo Registro: H = Hospitalizado, C=Cirugia",0,vTbl3.size());

pc.setFont(8, 0);
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

// EXAMEN FISICO
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
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

pc.setFont(8, 1);
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
    pc.setFont(8, 0);

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
        
        pc.setFont(8, 1);
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
            pc.setFont(8,0);
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
// END EXAMEN FISICO

// DIAGNOSTICO DE INGRESO
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
// END DIAGNOSTICO DE INGRESO

// DIAGNOSTICO DE SALIDA
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("88"), 0, dHeader.size(),Color.gray);

sql = "select a.diagnostico , a.tipo, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy') as fecha_modificacion, a.orden_diag, coalesce(b.observacion,b.nombre) as diagnosticoDesc from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and tipo = 'S' order by a.orden_diag";

al = SQLMgr.getDataList(sql);

Vector vTbl10 = new Vector();
vTbl10.addElement("7");
vTbl10.addElement("35");
vTbl10.addElement("10");
vTbl10.addElement("10");
vTbl10.addElement("10");
vTbl10.addElement("10");
vTbl10.addElement("10");

pc.setNoColumnFixWidth(vTbl10);
pc.createTable("tbl10");

pc.setFont(8, 1);
pc.addBorderCols("Código",1,1);
pc.addBorderCols("Nombre",1,1);
pc.addBorderCols("Prioridad",1,1);
pc.addBorderCols("Registrado por",1,1);
pc.addBorderCols("F. Creación",1,1);
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
pc.addTableToCols("tbl10",0,dHeader.size());
// END DIAGNOSTICO DE SALIDA

// PLAN DE TRATAMIENTO
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("155"), 0, dHeader.size(),Color.gray);

cdo = SQLMgr.getData("select to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, to_char(a.fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fm, observacion, a.usuario_creacion, a.usuario_modificacion from tbl_sal_plan_tratamientos a where a.codigo = "+codigo+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision);
if (cdo == null) cdo = new CommonDataObject();

sql = "select a.codigo, a.descripcion, b.observacion, b.aplicar from tbl_sal_tipo_tratamientos_med a, tbl_sal_plan_tratamientos_det b where a.estado = 'A' and a.codigo = b.tipo_tratamiento and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_plan = "+codigo+" order by a.orden ";
al = SQLMgr.getDataList(sql);

Vector vTbl8 = new Vector();
vTbl8.addElement(".60"); // pregunta
vTbl8.addElement(".04"); // SI
vTbl8.addElement(".04"); // NO
vTbl8.addElement(".32"); // Observación

pc.setNoColumnFixWidth(vTbl8);
pc.createTable("tbl8");

pc.setFont(8, 1);

pc.setVAlignment(0);

pc.addCols("Creado el: "+cdo.getColValue("fc"," "), 0,2);
pc.addCols("Creado por: "+cdo.getColValue("usuario_creacion"," "), 0,2);
pc.addCols("Modificado el: "+cdo.getColValue("fm"," "), 0,2);
pc.addCols("Modificado por: "+cdo.getColValue("usuario_modificacion"," "), 0,2);

pc.addCols(" ", 0, vTbl8.size());

pc.addBorderCols("TRATAMIENTO",0 ,1);
pc.addBorderCols("SI",1 ,1);
pc.addBorderCols("NO",1 ,1);
pc.addBorderCols("OBSERVACIÓN",0 ,1);

for(int i = 0; i<al.size(); i++){
    cdo = (CommonDataObject) al.get(i);
    
    pc.setFont(8, 0);
    
    if(cdo.getColValue("aplicar"," ").trim().equalsIgnoreCase("S")){
        si = "x";
        no = "";
    
    }else{
       no = "x";
       si = "";
    }
	
    pc.addBorderCols(cdo.getColValue("descripcion"),0,1);
    pc.addBorderCols(si,1,1);
    pc.addBorderCols(no,1,1);
    pc.addBorderCols(cdo.getColValue("observacion"),0,1);

}

pc.useTable("main");
pc.addTableToCols("tbl8",0,dHeader.size());
// END PLAN DE TRATAMIENTO

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