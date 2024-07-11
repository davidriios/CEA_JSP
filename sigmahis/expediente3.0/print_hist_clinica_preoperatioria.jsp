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
String subtitle = "HISTORIA CLÍNICA PRE-OPERATORIA";
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

ArrayList alT = SQLMgr.getDataList("select codigo, descripcion from tbl_sal_expediente_secciones where codigo in(1, 154, 63, 150, 7, 2, 4, 10, 89, 88, 155, 3, 16, 6, 27, 77, 163, 14, 15, 11, 166, 157) order by codigo ");
Hashtable iT = new Hashtable();
for (int t = 0; t < alT.size(); t++) {
	CommonDataObject cdoT = (CommonDataObject) alT.get(t);
	iT.put(cdoT.getColValue("codigo"), cdoT.getColValue("descripcion"));
}

String group = "", admision = "", si = "", no = "";

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

// ANTECEDENTE PATOLOGICOS PERSONALES
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
// END ANTECEDENTE PATOLOGICOS PERSONALES

//ANTECEDENTES MEDICAMENTOS (6)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
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

pc.setFont(8, 1);
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
		pc.setFont(8,0);
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


// ANTECEDENTES ALERGICOS
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("11"), 0, dHeader.size(),Color.gray);

sql = "select b.admision, a.descripcion as descripcion, a.codigo as codigoalergia, to_char(b.fecha,'dd/mm/yyyy hh12:mi:ss am') as fecha, b.usuario_creacion, b.meses as meses, b.observacion as observacion, b.edad as edad, nvl(b.codigo,0) as cod, b.aplicar as aplicar from TBL_SAL_TIPO_ALERGIA a, TBL_SAL_ALERGIA_PACIENTE b where a.codigo = b.tipo_alergia and b.pac_id = "+pacId+" and (nvl(b.admision,"+noAdmision+") = "+noAdmision+" or b.admision is null) ORDER BY a.orden ";

al = SQLMgr.getDataList(sql);

Vector vTbl22 = new Vector();
vTbl22.addElement(".17");
vTbl22.addElement(".03");
vTbl22.addElement(".06");
vTbl22.addElement(".10");
vTbl22.addElement(".29");
vTbl22.addElement(".12");
vTbl22.addElement(".10");

pc.setNoColumnFixWidth(vTbl22);
pc.createTable("tbl22");

pc.setFont(8, 1);
pc.setVAlignment(0);
pc.addBorderCols("Tipo de Alergia",1 ,1);
pc.addBorderCols("SI",1 ,1);
pc.addBorderCols("Edad",1 ,1);
pc.addBorderCols("Meses",1 ,1);
pc.addBorderCols("Observación",1 ,1);
pc.addBorderCols("Fecha",1 ,1);
pc.addBorderCols("Usuario",1 ,1);

for(int i = 0; i<al.size(); i++){

		cdo = (CommonDataObject) al.get(i);

		String compar = "S";
		if(cdo.getColValue("aplicar").trim().equalsIgnoreCase("S")){
			si = "x";
			no = "";
		}else{
			 no = "x";
			 si = "";
		}

		pc.setFont(8, 0);
		pc.addCols(cdo.getColValue("descripcion"),0,1,15.2f);

		pc.addCols(si,1,1);
		pc.addCols(cdo.getColValue("edad"),1,1,15.2f);
		pc.addCols(cdo.getColValue("meses"),1,1,15.2f);
		pc.addCols(cdo.getColValue("observacion"),0,1);
		pc.addCols(cdo.getColValue("fecha"),1,1);
		pc.addCols(cdo.getColValue("usuario_creacion"),1,1);

		pc.addBorderCols("",1,vTbl22.size(),0.0f,0.5f,0.0f,0.0f,8.2f);
}

pc.useTable("main");
pc.addTableToCols("tbl22",0,dHeader.size());
// END ANTECEDENTES ALERGICOS

// EXAMEN FISICO 10
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
// END EXAMEN FISICO 10

// SIGNOS VITALES(77)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
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

// EVALUACION PRE OPERATORIA (166)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("166"), 0, dHeader.size(),Color.gray);

cdo = SQLMgr.getData("select to_char(fecha_eval, 'dd/mm/yyyy') fecha_eval, to_char(hora_eval, 'hh12:mi:ss am') hora_eval, cod_diag, cod_proc, (select nvl(observacion,nombre) from tbl_cds_diagnostico where codigo = cod_diag and rownum  = 1) desc_diag, (select nvl(observacion,descripcion) from tbl_cds_procedimiento where codigo = cod_proc and rownum  = 1 ) desc_proc, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, usuario_creacion, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fm, usuario_modificacion from tbl_sal_hist_clinica_pre_ope where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = 1");

ArrayList alA = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = 1 and tipo = 'A' order by a.orden");

ArrayList alB = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = 1 and tipo = 'B' order by a.orden");

ArrayList alC = SQLMgr.getDataList("select a.codigo, a.descripcion, a.tipo, a.titulo, a.tiene_total, a.observacion, b.valor, decode(b.codigo_eval, null, 'I','U') action from tbl_sal_hist_cli_pre_ope_param a, tbl_sal_hist_clini_pre_ope_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" and b.codigo_eval(+) = 1 and tipo = 'C' and estado = 'A' order by a.orden, a.observacion");

Vector vTbl23 = new Vector();
vTbl23.addElement(".46");
vTbl23.addElement(".04");
vTbl23.addElement(".04");
vTbl23.addElement(".46");

pc.setNoColumnFixWidth(vTbl23);
pc.createTable("tbl23");

pc.setFont(10, 1);
pc.setVAlignment(0);
if (cdo == null) cdo = new CommonDataObject();

pc.addCols("Creado el: "+cdo.getColValue("fc"," "), 0,2);
pc.addCols("Creado por: "+cdo.getColValue("usuario_creacion"," "), 0,2);
pc.addCols("Modificado el: "+cdo.getColValue("fm"," "), 0,2);
pc.addCols("Modificado por: "+cdo.getColValue("usuario_modificacion"," "), 0,2);

pc.addCols(" ", 0, vTbl23.size());

pc.setFont(10, 0);
pc.addBorderCols("Diagnóstico:     "+cdo.getColValue("desc_diag"," "), 0, vTbl23.size(),0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("Procedimiento:     "+cdo.getColValue("desc_proc"," "), 0, vTbl23.size(),0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("Fecha de evaluación preoperatoria:     "+cdo.getColValue("fecha_eval"," "), 0, 2,0.1f,0.1f,0.1f,0.1f);
pc.addBorderCols("Hora de evaluación preoperatoria:     "+cdo.getColValue("hora_eval"," "), 0, 2,0.1f,0.1f,0.1f,0.1f);

pc.addCols(" ", 0, vTbl23.size());

for (int a = 0; a < alA.size(); a++) {
		CommonDataObject cdoA = (CommonDataObject) alA.get(a);

		if (a == 0) {
				pc.setFont(10,1);
				pc.addCols(cdoA.getColValue("titulo"), 1, vTbl23.size(), Color.lightGray);

				pc.addBorderCols("METs",0,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("SI",1,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("NO",1,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("DESCRIPCION DE LA ACTIVIDAD REALIZADA",0,1,0.1f,0.1f,0.1f,0.1f);
		}
		pc.setFont(10,0);

		String valorSi = cdoA.getColValue("valor")!=null&&cdoA.getColValue("valor").equalsIgnoreCase("S") ? " [ x ]":"";
		String valorNo = cdoA.getColValue("valor")!=null&&cdoA.getColValue("valor").equalsIgnoreCase("N") ? " [ x ]":"";

		pc.addBorderCols(cdoA.getColValue("descripcion"),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(valorSi,1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(valorNo,1,1,0.1f,0.1f,0.1f,0.1f);

		pc.setFont(8,3);
		pc.addBorderCols(cdoA.getColValue("observacion"),0,1,0.1f,0.1f,0.1f,0.1f);
}

Vector tblB = new Vector();
tblB.addElement(".80");
tblB.addElement(".08");
tblB.addElement(".08");

Vector tblC = new Vector();
tblC.addElement(".84");
tblC.addElement(".08");
tblC.addElement(".08");

pc.addCols(" ", 0, vTbl23.size());

pc.setNoColumnFixWidth(tblB);
pc.createTable("tblB", false,15, 0.0f, 320f);

for (int b = 0; b < alB.size(); b++) {
		CommonDataObject cdoB = (CommonDataObject) alB.get(b);

		if (b == 0) {
				pc.setFont(10,1);

				pc.addBorderCols(cdoB.getColValue("titulo"," ").replaceAll("<br>","\n"),0,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("SI",1,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("NO",1,1,0.1f,0.1f,0.1f,0.1f);
		}

		pc.setFont(10,0);

		String valorSi = cdoB.getColValue("valor")!=null&&cdoB.getColValue("valor").equalsIgnoreCase("S") ? " [ x ]":"";
		String valorNo = cdoB.getColValue("valor")!=null&&cdoB.getColValue("valor").equalsIgnoreCase("N") ? " [ x ]":"";

		pc.addBorderCols(cdoB.getColValue("descripcion"),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(valorSi,1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(valorNo,1,1,0.1f,0.1f,0.1f,0.1f);

		if(b+1 == alB.size()){
				pc.addBorderCols("Total",1,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("",1,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("",1,1,0.1f,0.1f,0.1f,0.1f);
		}
}

pc.setNoColumnFixWidth(tblC);
pc.createTable("tblC", false,15, 0.0f,320f);
String groupC = "";

for (int c = 0; c < alC.size(); c++) {
		CommonDataObject cdoC = (CommonDataObject) alC.get(c);

		if (c == 0) {
				pc.setFont(10,1);

				pc.addBorderCols(cdoC.getColValue("titulo"),0,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("SI",1,1,0.1f,0.1f,0.1f,0.1f);
				pc.addBorderCols("NO",1,1,0.1f,0.1f,0.1f,0.1f);
		}

		if (!groupC.equalsIgnoreCase(cdoC.getColValue("observacion"))) {
				pc.setFont(10,1);
				pc.addCols(cdoC.getColValue("observacion"),0,3,Color.lightGray);
		}

		pc.setFont(10,0);

		String valorSi = cdoC.getColValue("valor")!=null&&cdoC.getColValue("valor").equalsIgnoreCase("S") ? " [ x ]":"";
		String valorNo = cdoC.getColValue("valor")!=null&&cdoC.getColValue("valor").equalsIgnoreCase("N") ? " [ x ]":"";

		pc.addBorderCols(cdoC.getColValue("descripcion"),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(valorSi,1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(valorNo,1,1,0.1f,0.1f,0.1f,0.1f);

		groupC = cdoC.getColValue("observacion");
}

pc.useTable("tbl23");
pc.addTableToCols("tblB",0,2);
pc.addTableToCols("tblC",0,2);

pc.addCols(" ", 0, vTbl23.size());
pc.setFont(10,1);
pc.addCols("PRUEBAS DE LABORATORIO Y GABINETE", 1, vTbl23.size(),Color.lightGray);

al = SQLMgr.getDataList("select codigo, laboratorio, resultado, to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, nec_cruce, cant_cruce, consulta_esp, observ_esp from tbl_sal_hist_cli_lab where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo_eval = "+codigo+" order by codigo");

Vector tblLab = new Vector();
tblLab.addElement(".40");
tblLab.addElement(".40");
tblLab.addElement(".20");

pc.addCols(" ", 0, vTbl23.size());

pc.setNoColumnFixWidth(tblLab);
pc.createTable("tblLab");

String gCodigo = "";
for (int i = 0; i < al.size(); i++) {
		cdo = (CommonDataObject) al.get(i);

		if (!gCodigo.equals(cdo.getColValue("codigo"))) {
				if (i > 0) {
					 pc.addBorderCols(" ",0,tblLab.size(), 0.0f, 0.0f, 0.1f, 0.1f);
					 pc.addBorderCols(" ",0,tblLab.size(), 0.0f, 0.0f, 0.1f, 0.1f);
				}

				pc.setFont(10,1);
				pc.addBorderCols("# "+cdo.getColValue("codigo"),0,tblLab.size(), 0.1f, 0.1f, 0.1f, 0.1f);
				pc.addBorderCols("PRUEBAS",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
				pc.addBorderCols("RESULTADO",0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
				pc.addBorderCols("FECHA",1, 1, 0.1f, 0.1f, 0.1f, 0.1f);
		}

		pc.setFont(10,0);
		pc.addBorderCols(cdo.getColValue("laboratorio"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
		pc.addBorderCols(cdo.getColValue("resultado"),0, 1, 0.1f, 0.1f, 0.1f, 0.1f);
		pc.addBorderCols(cdo.getColValue("fecha"),1, 1, 0.1f, 0.1f, 0.1f, 0.1f);

		gCodigo = cdo.getColValue("codigo");
}

pc.useTable("tbl23");
pc.addTableToCols("tblLab",0,vTbl23.size());

pc.useTable("main");
pc.addTableToCols("tbl23",0,dHeader.size());
//END EVALUACION PRE OPERATORIA (166)


// CRIBADO CLINICA PERI OPERATORIA (157)
pc.addCols(" ",0,dHeader.size());
pc.setFont(11,1, Color.white);
pc.addCols(""+iT.get("157"), 0, dHeader.size(),Color.gray);

cdo = SQLMgr.getData("select codigo, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fc, to_char(a.fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fm, observacion, a.usuario_creacion, a.usuario_modificacion from tbl_sal_cribado_periope a where a.codigo = "+codigo+" and a.pac_id = "+pacId+" and a.admision = "+noAdmision);
if (cdo == null) cdo = new CommonDataObject();

sql = "select a.codigo, a.pregunta, b.observacion, b.aplicar from tbl_sal_preguntas_cribado a, tbl_sal_cribado_periope_det b where a.estado = 'A' and a.codigo = b.tipo_pregunta and b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and b.cod_plan = "+cdo.getColValue("codigo", "0")+" order by a.orden ";

al = SQLMgr.getDataList(sql);

Vector vTbl24 = new Vector();
vTbl24.addElement(".92"); // pregunta
vTbl24.addElement(".04"); // SI
vTbl24.addElement(".04"); // NO

pc.setNoColumnFixWidth(vTbl24);
pc.createTable("tbl24");

pc.setFont(9, 1);

pc.setVAlignment(0);

pc.addCols("Creado el: "+cdo.getColValue("fc"," ")+"                                Creado por:  "+cdo.getColValue("usuario_creacion"," "), 0,vTbl24.size());
pc.addCols("Modificado el: "+cdo.getColValue("fm")+"                                Modificado por:  "+cdo.getColValue("usuario_modificacion"," "), 0,vTbl24.size());

pc.addCols(" ", 0, vTbl24.size());

pc.addBorderCols("ASPECTOS A EVALUAR",0 ,1,Color.lightGray);
pc.addBorderCols("SI",1 ,1,Color.lightGray);
pc.addBorderCols("NO",1 ,1,Color.lightGray);

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

		pc.addBorderCols(cdo.getColValue("pregunta"),0,1);
		pc.addBorderCols(si,1,1);
		pc.addBorderCols(no,1,1);
}


pc.useTable("main");
pc.addTableToCols("tbl24",0,dHeader.size());
//END CRIBADO CLINICA PERI OPERATORIA (157)






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