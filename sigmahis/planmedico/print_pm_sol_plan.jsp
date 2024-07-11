<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header_consentimiento.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String id = ((request.getParameter("id")==null || request.getParameter("id").trim().equals(""))?"0":request.getParameter("id"));
String clientId = ((request.getParameter("clientId")==null || request.getParameter("clientId").trim().equals(""))?"0":request.getParameter("clientId"));
String compania = (String) session.getAttribute("_companyId");
if(fg==null) fg="";
if(fp==null) fp="";
//--------------Patient info ----------------------------------------//
sql = "select a.deseo, a.preferencia ,a.tipo_id_paciente, nvl(a.provincia,'') provincia, nvl(a.sigla,'') sigla, nvl(a.tomo,'') tomo, nvl(a.asiento,'') asiento, nvl(a.d_cedula,'') d_cedula, nvl(a.pasaporte,'') pasaporte, to_char(a.fecha_nacimiento,'dd') as fn_d, to_char(a.fecha_nacimiento,'mm') as fn_m, to_char(a.fecha_nacimiento,'yyyy') as fn_a, a.codigo, a.primer_nombre, a.estado_civil, decode(a.estado_civil,'ST','Soltero','CS','Casado','DV','Divorciado','UN','Unido','SP','Separado','VD','Viudo') estadoCivilDesc, a.segundo_nombre, a.sexo, a.primer_apellido, a.segundo_apellido, a.apellido_de_casada, a.seguro_social, (select distinct tipo_sangre from tbl_bds_tipo_sangre where tipo_sangre = a.tipo_sangre) ||rh tipo_sangre, decode(a.nh,'S','Naci+¦ en el hospital',null,' ') nh, a.numero_de_hijos, a.vip, a.lugar_nacimiento, a.nacionalidad, b.nacionalidad nacionalidad_desc, a.religion, c.descripcion as religion_desc, a.estatus, a.fallecido, a.nombre_padre, a.nombre_madre, a.datos_correctos, to_char(a.fecha_fallecido,'dd/mm/yyyy') as fecha_fallecido, to_char(a.f_nac,'dd/mm/yyyy') as f_nac, a.jubilado, a.residencia_direccion, a.tipo_residencia, a.telefono, a.residencia_pais, decode(a.residencia_pais,null,null,d.nombre_pais) as pais_name, a.residencia_provincia, decode(a.residencia_provincia,null,null,d.nombre_provincia) as residencia_provincia_name, a.residencia_distrito, decode(a.residencia_distrito,null,null,d.nombre_distrito) as residencia_distrito_name, a.residencia_corregimiento, decode(a.residencia_corregimiento,null,null,d.nombre_corregimiento) as residencia_corregimiento_name, a.residencia_comunidad, decode(a.residencia_comunidad,null,null,d.nombre_comunidad) as residencia_comunidad_name, a.zona_postal, a.apartado_postal, a.fax, nvl(a.e_mail,'sincorreo@dominio.com') e_mail, a.persona_de_urgencia, a.direccion_de_urgencia, a.telefono_urgencia, a.telefono_trabajo_urgencia, a.id_empresa, nvl(e.nombre, ' ') lt_nombre, nvl(e.direccion, ' ') lt_direccion, nvl(e.telefono, ' ') lt_telefono, a.puesto_que_ocupa, a.residencia_no, a.telefono_movil, get_age(a.fecha_nacimiento,sysdate,'d') edad FROM tbl_pm_cliente a, tbl_sec_pais b, tbl_adm_religion c, vw_sec_regional_location d, tbl_pm_empresa e WHERE a.nacionalidad = b.codigo(+) and a.religion = c.codigo(+) and nvl(a.residencia_pais,0) = d.codigo_pais(+) and nvl(a.residencia_provincia,0)=d.codigo_provincia(+) and nvl(a.residencia_distrito,0)=d.codigo_distrito(+) and nvl(a.residencia_corregimiento,0)=d.codigo_corregimiento(+) and nvl(a.residencia_comunidad,0)=d.codigo_comunidad(+) and a.id_empresa = e.id_empresa(+) and a.codigo = "+clientId+"";

cdo = SQLMgr.getData(sql);
StringBuffer sbSql = new StringBuffer();
sbSql.append("select a.cobertura_mi, a.cobertura_cy, a.cobertura_hi, a.cobertura_ot, a.afiliados, a.forma_pago, to_char(a.fecha_ini_plan,'dd/mm/yyyy') f_ini_plan, to_char(a.cuota_mensual,'$9999.99') cuota_mensual, lpad(id, 10, '0')||'-'||(select no_contrato from tbl_pm_sol_contrato_det where id_solicitud = a.id and id_cliente = ");
sbSql.append(clientId);
sbSql.append(" and estado = 'A') secuencia_contrato from tbl_pm_solicitud_contrato a where ");
if(fp.equals("adenda")){ 
	sbSql.append(" exists (select id_solicitud from tbl_pm_adenda pa where pa.id = ");
	sbSql.append(id);
	sbSql.append(" and pa.id_solicitud = a.id)");
}	else sbSql.append(" a.id = "+id);
CommonDataObject cdoCob = (CommonDataObject)SQLMgr.getData(sbSql.toString());

if(fg.equals("beneficiario")){
	cdoCob.addColValue("cobertura_mi", "S");
	cdoCob.addColValue("cobertura_cy", "N");
	cdoCob.addColValue("cobertura_hi", "N");
	cdoCob.addColValue("cobertura_ot", "N");
}

ArrayList alInfPago = (ArrayList)SQLMgr.getDataList("select id, descripcion, to_char(monto,'$9999.99') monto from tbl_pm_afiliado where estado = 'A'");

ArrayList alBen = (ArrayList)SQLMgr.getDataList("select a.id_solicitud, a.id, a.id_cliente, a.parentesco, a.estado, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.observacion, coalesce(b.pasaporte,b.provincia||'-'||b.sigla||'-'||b.tomo||'-'||b.asiento)||'-'||b.d_cedula as identificacion, b.nombre_paciente as client_name, b.sexo, nvl(trunc(months_between(sysdate, coalesce(b.f_nac, b.fecha_nacimiento))/12), 0) as edad, to_char(b.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, a.costo_mensual, (select descripcion from tbl_pla_parentesco where codigo =a.parentesco and rownum = 1) parentezco_desc, get_age(a.fecha_creacion,sysdate,'d') edad2 from tbl_pm_sol_contrato_det a, vw_pm_cliente b where a.id_cliente = b.codigo and a.estado != 'I' and "+(fp.equals("adenda")?"id_adenda":"id_solicitud")+ " = "+id+ (fg.equals("beneficiario")?" and a.id_cliente = "+clientId:""));

ArrayList alCS = (ArrayList)SQLMgr.getDataList("select a.id id_pregunta, a.pregunta, a.tipo_pregunta, nvl(b.respuesta, ' ') respuesta, nvl(b.detalle, ' ') detalle, nvl(b.id, 0) id from tbl_pm_cuestionario_salud a, tbl_pm_cliente_cuestionario b where a.estado = 'A' and a.id = b.id_pregunta(+) and id_cliente(+) = "+clientId+"");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String timeStamp = fecha.replaceAll("/","").replaceAll(" ","").replaceAll(":","");
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+timeStamp+".pdf";

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
	String fotosFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72* 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 10.0f;
	float topMargin = 20.0f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subTitle = "";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;


	//Main table
	Vector tblWrapper = new Vector();
	tblWrapper.addElement("0.05");
	tblWrapper.addElement("0.95");

	//Title table
	Vector tblTitle = new Vector();
	tblTitle.addElement(".20");
	tblTitle.addElement(".60");
	tblTitle.addElement(".20");

	//Client Table
	Vector tblClient = new Vector();
	tblClient.addElement(".15"); // primer nombre
	tblClient.addElement(".02");
	tblClient.addElement(".13");
	tblClient.addElement(".02");
	tblClient.addElement(".13");
	tblClient.addElement(".15"); // primer apellido
	tblClient.addElement(".25");
	tblClient.addElement(".20"); //apellido de casada

	//DOB Table
	Vector tblDOB = new Vector();
	tblDOB.addElement(".09");
	tblDOB.addElement(".09");
	tblDOB.addElement(".09");

	tblDOB.addElement(".02");
	tblDOB.addElement(".05");
	tblDOB.addElement(".02");
	tblDOB.addElement(".05");
	tblDOB.addElement(".25");
	tblDOB.addElement(".10");
	tblDOB.addElement(".24");

	//Table direction
	Vector tblDir = new Vector();
	tblDir.addElement(".18");
	tblDir.addElement(".25");
	tblDir.addElement(".05");
	tblDir.addElement(".02");
	tblDir.addElement(".16");
	tblDir.addElement(".02");
	tblDir.addElement(".14");
	tblDir.addElement(".02");
	tblDir.addElement(".14");
	tblDir.addElement(".02");

	//Table informacion de pago
	Vector tblInfPago = new Vector();
	tblInfPago.addElement(".18");
	tblInfPago.addElement(".09");
	tblInfPago.addElement(".02");
	tblInfPago.addElement(".02");
	tblInfPago.addElement(".02");
	tblInfPago.addElement(".20");
	tblInfPago.addElement(".02");
	tblInfPago.addElement(".20");
	tblInfPago.addElement(".25");

	Vector tblIP1 = new Vector();
	tblIP1.addElement(".60");
	tblIP1.addElement(".32");
	tblIP1.addElement(".08");

	Vector tblIP2 = new Vector();
	tblIP2.addElement(".03");
	tblIP2.addElement(".30");
	tblIP2.addElement(".03");
	tblIP2.addElement(".30");
	tblIP2.addElement(".34");

	Vector tblIPWrapper = new Vector();
	tblIPWrapper.addElement(".31");
	tblIPWrapper.addElement(".69");

	//Table Beneficiarios
	Vector tblBen = new Vector();
	tblBen.addElement(".30");
	tblBen.addElement(".20");
	tblBen.addElement(".15");
	tblBen.addElement(".15");
	tblBen.addElement(".15");
	tblBen.addElement(".05");

	//Table Cuestionario de salud
	Vector tblCS = new Vector();
	tblCS.addElement(".07"); // num
	tblCS.addElement(".26");
	tblCS.addElement(".10"); //space
	tblCS.addElement(".26");
	tblCS.addElement(".10"); //space
	tblCS.addElement(".05");
	tblCS.addElement(".02");
	tblCS.addElement(".05");
	tblCS.addElement(".02");
	tblCS.addElement(".07"); //

	Vector tblFooter = new Vector();
	tblFooter.addElement("100");

	PdfCreator footer = new PdfCreator(width, height, leftRightMargin);

	footer.setNoColumnFixWidth(tblCS);
	footer.createTable();
	footer.setFont(10, 0);
	footer.addBorderCols("Nombre del Solcitante:",1,2,0.0f,0.1f,0.0f,0.0f);
	footer.addCols(" ",7,1);

	footer.addCols(" ",1,tblCS.size());footer.addCols(" ",1,tblCS.size());footer.addCols(" ",1,tblCS.size());footer.addCols(" ",1,tblCS.size());

	footer.addBorderCols("Firma:",1,2,0.0f,0.1f,0.0f,0.0f);
	footer.addCols(" ",0,1);

	footer.addBorderCols("Preparado Por:",1,1,0.0f,0.1f,0.0f,0.0f);
	footer.addCols(" ",0,1);

	footer.addBorderCols("Fecha:",1,5,0.0f,0.1f,0.0f,0.0f);

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY,footer.getTable());


	//Title
	pc.setNoColumnFixWidth(tblTitle);
	pc.createTable("tblTitle");
	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);
	pc.setVAlignment(1);
	pc.addCols(" ",1,1);
	pc.addImageCols(companyImageDir+"/blank.gif",30.0f,1);
	pc.resetVAlignment();
	//---- end table title

	//fotosFolder+"/"+((cdo.getColValue("extra_logo") != null && !cdo.getColValue("extra_logo").trim().equals(""))?cdo.getColValue("extra_logo")

	//Client
	pc.setNoColumnFixWidth(tblClient);
	pc.createTable("tblClient");
	pc.setFont(10,0);
	pc.addBorderCols("Contrato No.: ",2,7,0.0f,0.0f,0.0f,0.0f);
	pc.addBorderCols(cdoCob.getColValue("secuencia_contrato"),2,1,0.0f,0.0f,0.0f,0.0f);
	pc.addBorderCols("Primer Nombre",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("primer_nombre"),0,4,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Primer Apellido",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("primer_apellido"),0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Apellido de Casada",1,1,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols("Segundo Nombre",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("segundo_nombre"),0,4,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Segundo Apellido",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("segundo_apellido"),0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("apellido_de_casada"),1,1,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols("Estado Civil",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("estadoCivilDesc"),0,4,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Ocupación:",0,3,0.0f,0.1f,0.1f,0.1f);

	//DOB
	pc.setNoColumnFixWidth(tblDOB);
	pc.createTable("tblDOB");
	pc.setFont(10,0);
	pc.addBorderCols("Fecha Nacimiento",1,3,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Lugar de Trabajo:",0,7,0.0f,0.1f,0.1f,0.1f);

	pc.setFont(10,1);
	pc.addBorderCols(cdo.getColValue("fn_d"),0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("fn_m"),0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("fn_a"),0,1,0.0f,0.1f,0.1f,0.0f);
	pc.setFont(10,0);
	pc.addBorderCols("Dirección de Trabajo:",0,7,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols("Tel. Residencia: "+cdo.getColValue("telefono"),0,3,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Tel.Trabajo: "+cdo.getColValue("telefono_trabajo_urgencia"),0,5,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Ext.: ",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Cel.: "+cdo.getColValue("telefono_movil"),0,1,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols("Edad: "+cdo.getColValue("edad"),0,2,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Sexo:",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(" ",0,1,( cdo.getColValue("sexo").equals("M")?Color.black:Color.white) );
	pc.addBorderCols("M:",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(" ",0,1,( cdo.getColValue("sexo").equals("F")?Color.black:Color.white) );
	pc.addBorderCols("F:",0,1,0.0f,0.1f,0.1f,0.0f);

	pc.addBorderCols("Tipo Sangre: "+cdo.getColValue("tipo_sangre"),0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Nacionalidad: "+cdo.getColValue("nacionalidad_desc"),0,2,0.0f,0.1f,0.1f,0.1f);

	pc.useTable("tblClient");
	pc.addTableToCols("tblDOB",1,tblClient.size(),0.0f);


	//Dirección
	pc.setNoColumnFixWidth(tblDir);
	pc.createTable("tblDir");
	pc.setFont(10,0);
	pc.addBorderCols(" ",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdo.getColValue("residencia_provincia_name"),1,1,0.0f,0.1f,0.1f,0.1f);
	pc.addBorderCols(cdo.getColValue("residencia_corregimiento_name"),1,4,0.0f,0.1f,0.1f,0.1f);
	pc.addBorderCols(cdo.getColValue("residencia_distrito_name"),1,4,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols("Dirección:",1,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Provincia",1,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Corregimiento",1,4,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Barrio o Sector",1,4,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols(" ",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Calle: "+cdo.getColValue("residencia_direccion"),0,5,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("No.Casa / Edificio: "+cdo.getColValue("residencia_no"),0,4,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols("Estoy  solicitando  la  cobertura  de  salud  para: ",0,2,0.1f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Mi:",0,1,0.1f,0.1f,0.1f,0.0f);
	pc.addBorderCols("",0,1,(cdoCob.getColValue("cobertura_mi").equals("S")?Color.black:Color.white));
	pc.addBorderCols("Cónjugue:",2,1,0.1f,0.1f,0.1f,0.0f);
	pc.addBorderCols("",0,1,(cdoCob.getColValue("cobertura_cy").equals("S")?Color.black:Color.white));
	pc.addBorderCols("Hijo(s):",2,1,0.1f,0.1f,0.1f,0.0f);
	pc.addBorderCols("",0,1,(cdoCob.getColValue("cobertura_hi").equals("S")?Color.black:Color.white));
	pc.addBorderCols("Otros(s):",2,1,0.1f,0.1f,0.1f,0.0f);
	pc.addBorderCols("",0,1,(cdoCob.getColValue("cobertura_ot").equals("S")?Color.black:Color.white));

	pc.setFont(10,1);
	pc.addCols("\nINFORMACION DE PAGO",1,tblDir.size());
	pc.setFont(10,0);

	pc.useTable("tblClient");
	pc.addTableToCols("tblDir",1,tblClient.size(),0.0f);

	//String tableName, boolean splitRowOnEndPage, int showBorder, float margin, float tableWidth

	pc.setNoColumnFixWidth(tblIP1);
	pc.createTable("tblIP1",false,1,0.0f,180.0f);

	CommonDataObject cdoP = new CommonDataObject();
	for (int p = 0; p<alInfPago.size(); p++){
	  cdoP = (CommonDataObject)alInfPago.get(p);
	  float bb = 0.0f;
	  if ((p+1)==alInfPago.size()) bb = 0.1f;
	  pc.setFont(9,0);
	  pc.addBorderCols(cdoP.getColValue("descripcion"),0,1,bb,0.1f,0.1f,bb);
	  pc.addBorderCols(cdoP.getColValue("monto"),2,1,bb,0.1f,0.1f,bb);
	  pc.addBorderCols(" ",0,1,(cdoCob.getColValue("afiliados").equals(cdoP.getColValue("id"))?Color.black:Color.white));
	}

	pc.setNoColumnFixWidth(tblIP2);
	pc.createTable("tblIP2",false,1,0.0f,407.0f);

	pc.addBorderCols("Forma de Pago",1,4,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Cuota Mensual: "+cdoCob.getColValue("cuota_mensual"),0,1,0.0f,0.1f,0.1f,0.1f);
	pc.setFont(9,0);

	pc.addBorderCols(" ",0,1,(cdoCob.getColValue("forma_pago").equals("1")?Color.black:Color.white));
	pc.addBorderCols("Tarjeta de Crédito",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols(" ",0,1,(cdoCob.getColValue("forma_pago").equals("3")?Color.black:Color.white));
	pc.addBorderCols("Pago Anual (CHK o Efectivo)",0,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Fecha Inicio Plan",1,1,0.0f,0.1f,0.1f,0.1f);

	pc.addBorderCols(" ",0,1,(cdoCob.getColValue("forma_pago").equals("2")?Color.black:Color.white));
	pc.addBorderCols("ACH",0,1,0.1f,0.1f,0.1f,0.0f);
	pc.addBorderCols(" ",0,1,(cdoCob.getColValue("forma_pago").equals("4")?Color.black:Color.white));
	pc.addBorderCols("Descuento de Salario",0,1,0.1f,0.1f,0.1f,0.0f);
	pc.addBorderCols(cdoCob.getColValue("f_ini_plan"),1,1,0.1f,0.1f,0.1f,0.1f);

	pc.setNoColumnFixWidth(tblIPWrapper);
	pc.createTable("tblIPWrapper");
	pc.addCols("",1,tblIPWrapper.size());


	pc.useTable("tblIPWrapper");
	pc.addTableToCols("tblIP1",0,1,0.0f);
	pc.addTableToCols("tblIP2",0,1,0.0f);

	pc.useTable("tblClient");
	pc.addTableToCols("tblIPWrapper",1,tblClient.size(),0.0f);


    // table beneficiario
	pc.setNoColumnFixWidth(tblBen);
	pc.createTable("tblBen");
	pc.setFont(10,1);
	pc.addCols("\nINFORMACION DEL CONJUGUE Y LOS HIJOS INCLUIDOS EN ESTA SOLICITUD",1,tblBen.size());
	pc.addCols("",1,tblBen.size());

	pc.setFont(9,0);

	pc.addBorderCols("Nombre",1,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Cédula",1,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Patentesco",1,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("F.Nac.",1,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Edad",1,1,0.0f,0.1f,0.1f,0.0f);
	pc.addBorderCols("Sexo",1,1,0.0f,0.1f,0.1f,0.1f);

	CommonDataObject cdoBen = new CommonDataObject();
	for (int b = 0; b<alBen.size(); b++){
	   cdoBen = (CommonDataObject)alBen.get(b);
	   float bb = 0.0f;

	   if ((b+1)==alBen.size()) bb = 0.1f;

	   pc.addBorderCols(cdoBen.getColValue("client_name"),0,1,bb,0.1f,0.1f,bb);
	   pc.addBorderCols(cdoBen.getColValue("identificacion"),1,1,bb,0.1f,0.1f,bb);
	   pc.addBorderCols(cdoBen.getColValue("parentezco_desc"),0,1,bb,0.1f,0.1f,bb);
	   pc.addBorderCols(cdoBen.getColValue("fecha_nacimiento"),1,1,bb,0.1f,0.1f,bb);
	   pc.addBorderCols(cdoBen.getColValue("edad"),1,1,bb,0.1f,0.1f,bb);
	   pc.addBorderCols(cdoBen.getColValue("sexo"),1,1,bb,0.1f,0.1f,bb);
	}

	pc.setNoColumnFixWidth(tblCS);
	pc.createTable("tblCS");
	pc.setFont(10,1);
	pc.addCols("\nCUESTIONARIO DE SALUD",1,tblBen.size());
	pc.addCols("",1,tblCS.size());

	CommonDataObject cdoCS = new CommonDataObject();

	pc.setFont(9,0);
    for (int cs = 0; cs<alCS.size();cs++){
	  float bb = 0.0f;
	  if ((cs+1)==alCS.size()) bb = 0.1f;
	  cdoCS = (CommonDataObject)alCS.get(cs);

	  pc.addBorderCols((cs+1)+".",0,1,bb,0.1f,0.1f,bb);
	  pc.addBorderCols(cdoCS.getColValue("pregunta"),0,4,bb,0.1f,0.1f,bb);

	  pc.addBorderCols("SI",2,1,bb,0.1f,0.1f,bb);
	  pc.addBorderCols(" ",0,1,(cdoCS.getColValue("respuesta").equals("S")?Color.black:Color.white));
	  pc.addBorderCols("NO",2,1,bb,0.1f,0.1f,bb);
	  pc.addBorderCols(" ",0,1,(cdoCS.getColValue("respuesta").equals("N")?Color.black:Color.white));
	  pc.addBorderCols(" ",0,1,bb,0.1f,0.1f,bb);

	  pc.addBorderCols("Indique cuál: "+cdoCS.getColValue("detalle"),0,tblCS.size(),bb,0.1f,0.1f,0.1f);
	}

	/*
	pc.addCols(" ",1,tblCS.size());pc.addCols(" ",1,tblCS.size());pc.addCols(" ",1,tblCS.size());pc.addCols(" ",1,tblCS.size());

	pc.addBorderCols("Nombre del Solcitante:",1,2,0.0f,0.1f,0.0f,0.0f);
	pc.addCols(" ",7,1);

	pc.addCols(" ",1,tblCS.size());pc.addCols(" ",1,tblCS.size());pc.addCols(" ",1,tblCS.size());pc.addCols(" ",1,tblCS.size());

	pc.addBorderCols("Firma:",1,2,0.0f,0.1f,0.0f,0.0f);
	pc.addCols(" ",0,1);

	pc.addBorderCols("Preparado Por:",1,1,0.0f,0.1f,0.0f,0.0f);
	pc.addCols(" ",0,1);

	pc.addBorderCols("Fecha:",1,5,0.0f,0.1f,0.0f,0.0f);
	*/

	//Main Table
	pc.setNoColumnFixWidth(tblWrapper);
	pc.createTable();

	pc.setTableHeader(2);

	//displaying tblTitle
	//String tableName, int hAlign, int colSpan, float height
	pc.useTable("main");
	pc.addTableToCols("tblTitle",1,tblWrapper.size(),0.0f);

	pc.setFont(10,1);
	pc.addCols("", 0, tblWrapper.size());
	pc.addCols("PLAN MEDICO FAMILIAR "+_comp.getNombre()+"\nFORMULARIO DEL SOLICITANTE",1,tblWrapper.size());
	pc.addCols("", 0, tblWrapper.size());

	//displaying tblClient
	pc.useTable("main");
	pc.addTableToCols("tblClient",1,tblWrapper.size(),0.0f);

	//displaying tblBen
	pc.useTable("main");
	pc.addTableToCols("tblBen",1,tblWrapper.size(),0.0f);

	//displaying tblCS
	pc.useTable("main");
	pc.addTableToCols("tblCS",1,tblWrapper.size(),0.0f);

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}
%>