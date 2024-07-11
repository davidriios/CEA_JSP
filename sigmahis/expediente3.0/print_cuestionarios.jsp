<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
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
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
<%@ include file="../common/pdf_header.jsp"%>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
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
String fp = request.getParameter("fp");
String formulario = request.getParameter("formulario");

if (fg == null) fg = "";
if (fp == null) fp = "";
if (formulario == null) formulario = "";
Vector vFormularios = CmnMgr.str2vector(formulario);

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

cdoUsr.addColValue("usuario",userName);
boolean isFragment = fp.trim().equalsIgnoreCase("exp_kardex")||fp.trim().equalsIgnoreCase("nutricional_riesgo")||fp.trim().equalsIgnoreCase("nutricional_riesgo_funcional")||fp.trim().equalsIgnoreCase("handover");

if(desc == null) desc = "";

prop = SQLMgr.getDataProperties("select cuestiones from tbl_sal_cuestionarios where pac_id="+pacId+" and admision="+noAdmision+" and tipo_cuestionario = '"+fg+"'");

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
	String subTitle = desc;
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

    Vector dHeader = new Vector();
    dHeader.addElement("10"); 
    dHeader.addElement("10");
    dHeader.addElement("2");
    dHeader.addElement("18");
    dHeader.addElement("2");
    dHeader.addElement("18");
    dHeader.addElement("2");
    dHeader.addElement("18");
    dHeader.addElement("2");
    dHeader.addElement("18");
    
    Vector tblEval = new Vector();
    tblEval.addElement("3");
    tblEval.addElement("97");
		
	cdo = SQLMgr.getData("select (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1) codigo_diag, (select (select nvl(observacion, nombre) from tbl_cds_diagnostico where codigo = a.diagnostico ) from tbl_adm_diagnostico_x_admision a where pac_id = adm.pac_id and admision = adm.secuencia and tipo = 'I' and orden_diag = 1)  desc_diag,(select edad_mes end from vw_adm_paciente where pac_id = adm.pac_id) as edad_mes,(select edad from vw_adm_paciente where pac_id = adm.pac_id) as edad,(select sexo from vw_adm_paciente where pac_id = adm.pac_id) as sexo from tbl_adm_admision adm where adm.pac_id = "+pacId+" and adm.secuencia = "+noAdmision);
    
    if (cdo == null) {
        cdo = new CommonDataObject();
        cdo.addColValue("codigo_diag","NA");
        cdo.addColValue("desc_diag","NA");
        cdo.addColValue("edad","0");
    }
    int edad = Integer.parseInt(cdo.getColValue("edad"));
    int edadMes = Integer.parseInt(cdo.getColValue("edad_mes"));
    ArrayList alC = new ArrayList();

    if (edad > 0 && edad < 4) {
      edadMes = edad * 12 + edadMes;
    } else if (edad >= 4) {
       edadMes = 0;
    }
	
    if (fg.trim().equalsIgnoreCase("PE")) {
        if (edadMes >=37 && edadMes <= 47) edadMes = 36;
		
		if (edadMes >= 0 && edadMes <= 36 && edad < 4) {
          alC = SQLMgr.getDataList("select codigo, mes, descripcion, grupo from tbl_sal_eval_creci_desarrollo where estado = 'A' and anio is null and mes = "+edadMes+" order by grupo");
        } else if (edad >=4 && edad <= 11) {
          alC = SQLMgr.getDataList("select codigo, mes, descripcion, grupo from tbl_sal_eval_creci_desarrollo where estado = 'A' and mes is null and anio = "+edad+" order by grupo");
        }
    }else {
        if (edad <= 19) {
          alC = SQLMgr.getDataList("select codigo, mes, descripcion, grupo from tbl_sal_eval_creci_desarrollo where estado = 'A' and mes is null and anio = "+edad+" order by grupo");
        }
    }

    if (prop == null) prop = new Properties();
		
    pc.setNoColumnFixWidth(dHeader);
    pc.createTable();
        
    pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
    pc.setTableHeader(3);
    
    System.out.println("::::::::::::::::::::::::::::::::::::::: prop = "+prop);
    
    pc.setFont(10,0);
    if(prop == null){
       pc.addCols(".:: No Se Ha Encontrado Registros! ::.",1,dHeader.size());
    }else{
    
        if(fg.trim().equals("PE") || fg.trim().equals("EM")){
            pc.addBorderCols("Fecha:",0,1,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols(prop.getProperty("fecha_creacion"),0,3,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols("Usuario:",2,2,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols(prop.getProperty("usuario_creacion"),0,2,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols("",0,3,0.1f,0.0f,0.0f,0.0f);
        }
        
        pc.addCols(" ",1,dHeader.size());
            
		if(!isFragment){
        if(fg.trim().equals("C1") /* || fg.trim().equals("PE") || fg.trim().equals("EM")*/){
            pc.setFont(9,1,Color.white);
            pc.addCols("INGRESO DE PACIENTE",0,dHeader.size(),15f,Color.gray);
            pc.addCols(" ",1,dHeader.size(),15f);
        
            pc.setFont(10,0);
            pc.addBorderCols("Fecha Ing.:",0,1,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols(prop.getProperty("fecha_ingreso"),0,1,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols("",0,1,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols("Hora Ing.:",2,2,0.1f,0.0f,0.0f,0.0f);
            pc.addBorderCols(prop.getProperty("hora_ingreso"),0,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("Usuario:",2,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(prop.getProperty("usuario_creacion"),0,2,0.1f,0.0f,0.0f,0.0f);
            //pc.addBorderCols("",0,4,0.1f,0.0f,0.0f,0.0f);
            
            pc.addCols(" ",1,dHeader.size());
            
            pc.setFont(10,1,Color.gray);
            pc.addCols("Procedente:",0,2);
            
            pc.setFont(10,0);
            pc.addImageCols( (prop.getProperty("procedente").equalsIgnoreCase("a"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Admisión",0,1);
            
            pc.addImageCols( (prop.getProperty("procedente").equalsIgnoreCase("e"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Emergencia",0,1);
            pc.addImageCols( (prop.getProperty("procedente").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otro",0,3);
            pc.addCols(" ",0,2);    
            pc.addCols(prop.getProperty("observacion18"),0,dHeader.size()-2);
            
            pc.setFont(10,1,Color.gray);
            pc.addCols("Diagnóstico de Ingreso:",0, 2);
            pc.setFont(10,0);
            pc.addCols("["+(prop.getProperty("codigo_diag")==null||prop.getProperty("codigo_diag").equals("")?cdo.getColValue("codigo_diag"):prop.getProperty("codigo_diag"))+"]  "+(prop.getProperty("desc_diag")==null||prop.getProperty("desc_diag").equals("")?cdo.getColValue("desc_diag"):prop.getProperty("desc_diag")),0,dHeader.size()-2);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.setFont(10,1,Color.gray);
            pc.addCols("Paciente llegó:",0,2);
            
            pc.setFont(10,0);
            pc.addImageCols( (prop.getProperty("paciente_llego").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Caminando",0,1);
            
            pc.addImageCols( (prop.getProperty("paciente_llego").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Silla de Rueda",0,1);
            
            pc.addImageCols( (prop.getProperty("paciente_llego").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Camilla",0,1);
            
            pc.addImageCols( (prop.getProperty("paciente_llego").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            
            pc.addCols(" ",0,2);
            pc.addCols(prop.getProperty("observacion20"),0,dHeader.size()-2);
                        
            pc.addCols(" ",0,dHeader.size());
            
            pc.setFont(10,1,Color.gray);
            pc.addCols("Acompañado por:",0,2);
            
            pc.setFont(10,0);
            pc.addImageCols( (prop.getProperty("acompaniado_por0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Familiar",0,1);
            
            pc.addImageCols( (prop.getProperty("acompaniado_por1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Amigo",0,1);
            
            pc.addImageCols( (prop.getProperty("acompaniado_por2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Escolta",0,1);
            
            pc.addImageCols( (prop.getProperty("acompaniado_por3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Médico",0,1);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("acompaniado_por4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Enfermera",0,1);
            
            pc.addImageCols( (prop.getProperty("acompaniado_por5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            
            pc.addCols(prop.getProperty("observacion19"),0,dHeader.size()-4);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
        }
        
        if(fg.trim().equals("C1")){
            pc.setFont(10,1);
            pc.addCols("EVALUACIÓN INICIAL DE LAS ENFERMEDADES TRANSMISIBLES",0,dHeader.size(),Color.lightGray);
            
            pc.setFont(10,1,Color.gray);
            pc.addCols(" ",0,2);
            
            pc.setFont(10,0);
            pc.addImageCols( (prop.getProperty("aislamiento").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("aislamiento").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addImageCols( (prop.getProperty("aislamiento_det1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Paciente con Aislamiento de Contacto",0,1);
            
            pc.addImageCols( (prop.getProperty("aislamiento_det3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Paciente Con Aislamiento de Gotas",0,1);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("aislamiento_det5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Paciente con Aislamiento Respiratorio (Gotitas)",0,1);
            
            pc.addImageCols( (prop.getProperty("aislamiento_det0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Orientación al paciente y familiar",0,1);
            
            pc.addImageCols( (prop.getProperty("aislamiento_det2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Coordinación con la enfermera de nosocomial",0,1);
            
            pc.addImageCols( (prop.getProperty("aislamiento_det4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Colocación del equipo de protección",0,1);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("aislamiento_det6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            pc.addCols(prop.getProperty("observacion27"),0,6);

            //if(cdo.getColValue("sexo","M").equalsIgnoreCase("M") && edad > 12){
            pc.setFont(10,1);
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("NUTRICION: CRIBADO NUTRICIONAL (No Aplica a Pediatría ni Obstetricia)",0,dHeader.size(),Color.lightGray);
            
            pc.setFont(10,0);
            
            pc.addCols("Pérdida de Peso en los últimos tres (3) meses?",0,6);
            pc.addImageCols( (prop.getProperty("perdido_peso").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("perdido_peso").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Disminución de la ingesta en la última semana?",0,6);
            pc.addImageCols( (prop.getProperty("disminucion").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("disminucion").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Tiene alguno de estos Diagnósticos: Diabetes, EPOC, Nefrópata (hemodiálisis), Enfermedad Oncológico, Fractura de Cadera, Cirrosis hepática)",0,6);
            pc.addImageCols( (prop.getProperty("diabetes").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("diabetes").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Paciente se encuentra en la Unidad de Cuidados Intensivos",0,6);
            pc.addImageCols( (prop.getProperty("unidad_cuidado").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("unidad_cuidado").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Paciente se encuentra con nutrición enteral",0,6);
            pc.addImageCols( (prop.getProperty("nutricion_enteral").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("nutricion_enteral").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Paciente con problemas de comunicación",0,6);
            pc.addImageCols( (prop.getProperty("problema_comunicacion").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("problema_comunicacion").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Que haya perdido >15% en los últimos meses",0,6);
            pc.addImageCols( (prop.getProperty("perdida_peso_15").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("perdida_peso_15").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Que el paciente >80 años deberán, comunicarse con la nutricionista para una evaluación completa, vía mensaje de texto",0,6);
            pc.addImageCols( (prop.getProperty("mayor_80").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("mayor_80").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.setFont(12,1);
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Observaciones de alerta a presentar:\n1. En caso de 2 o más alteraciones resulten en (SI)\n2. Si el Paciente se encuentra con nutrición enteral\n3. Si el Paciente con problemas de comunicación\n4. si es paciente de Cuidados Intensivos que mande alerta\n5. Que haya perdido >15% en los últimos meses\n6. Que el paciente >80 años deberán, comunicarse con la nutricionista para una evaluación completa, vía mensaje de texto",0,dHeader.size());
            pc.addCols(" ",0,dHeader.size());
            
            pc.setFont(10,1,Color.gray);
            pc.addCols("Nutricionista Enterada:",0,2);
            
            pc.setFont(10,0);
            
            String via = "";
            if (""+prop.getProperty("via")!=null){
              if (prop.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
              else if (prop.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
              else if (prop.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
              else if (prop.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
            }

            pc.addCols(prop.getProperty("nutricionista"),0,2);
            pc.addCols(" Hora: "+prop.getProperty("hora"),0,3);
            pc.addCols(" Vía Comunicación: "+via,0,3);
            //}
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("VALORACION FUNCIONAL",0,dHeader.size(),Color.lightGray);
            
            pc.setFont(10,0);
            
            pc.addCols("Baño / higiene",0,4);
            pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No requiere ayuda",0,1);
            
            pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ayuda parcial",0,1);
            
            pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ayuda total",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Vestirse / desvestirse / alimentación",0,4);
            pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No requiere ayuda",0,1);
            
            pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ayuda parcial",0,1);
            
            pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ayuda total",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Movilidad deambulación",0,4);
            pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No requiere ayuda",0,1);
            
            pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ayuda parcial",0,1);
            
            pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ayuda total",0,1);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
            pc.addCols("Alguna Dificultad Funcional:",0,2);
            
            pc.addImageCols( (prop.getProperty("movimiento").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("movimiento").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,5);
            
            
            pc.addCols(" ",0,2);            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Moverse",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Caminar",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Levantarse",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Sentarse",0,1);
            
            pc.addCols(" ",0,2);            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Pérdida Funcional",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Prótesis",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Paresias/plejia",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultad_movimiento7").equalsIgnoreCase("7"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Amputaciones",0,1);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("dificultad_movimiento8").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otro",0,1);
            pc.addCols(prop.getProperty("observacion0"), 0, dHeader.size()-4);
            
            pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            pc.addCols("Alguna necesidad especial: ",0,2);
            
            pc.addImageCols( (prop.getProperty("necesidad").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("necesidad").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addImageCols( (prop.getProperty("necesidad_especial0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Ciego",0,1);
            
            pc.addImageCols( (prop.getProperty("necesidad_especial1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Sordo",0,1);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("necesidad_especial2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Mudo",0,1);
            
            pc.addImageCols( (prop.getProperty("necesidad_especial3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otro",0,1);
            pc.addCols(prop.getProperty("observacion1"),0,dHeader.size() - 6);
            
            pc.setFont(12, 1);
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Observación: En caso de detectar alguna alteración funcional o necesidad especial, se deberá comunicar al médico inmediatamente para una evaluación más completa",0,dHeader.size());
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("VALORACION CREENCIAS / CULTURA / ESPIRITUAL",0,dHeader.size(),Color.lightGray);
            
            pc.setFont(10,0);
            
            pc.addCols("", 0, 2);
            
            pc.addImageCols( (prop.getProperty("religion").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Católico",0,1);
            
            pc.addImageCols( (prop.getProperty("religion").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Judío",0,1);
            
            pc.addImageCols( (prop.getProperty("religion").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Árabe",0,1);
            
            pc.addImageCols( (prop.getProperty("religion").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Musulmán",0,1);
            
            pc.addCols("", 0, 2);
            
            pc.addImageCols( (prop.getProperty("religion").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ninguno",0,1);
            
            pc.addImageCols( (prop.getProperty("religion").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            pc.addCols(prop.getProperty("observacion2"),0,dHeader.size()-6);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Tiene alguna Creencia religiosa o cultural que le gustaría que tuviéramos en cuenta en su hospitalización:", 0, 6);
            
            pc.addImageCols( (prop.getProperty("creencia").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("creencia").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addCols("Específique:",0,2);
            pc.addCols(prop.getProperty("observacion3"),0,dHeader.size()-2);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Solicita Servicios Religiosos:", 0, 6);
            
            pc.addImageCols( (prop.getProperty("servicio_religioso").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("servicio_religioso").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addCols("Específique:",0,2);
            pc.addCols(prop.getProperty("observacion4"),0,dHeader.size()-2);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Voluntades Anticipadas:", 0, 6);
            
            pc.addImageCols( (prop.getProperty("voluntades_anticipadas").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("voluntades_anticipadas").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addCols("Específique:",0,2);
            pc.addCols(prop.getProperty("observacion25"),0,dHeader.size()-2);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols(" ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("no_no0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("No reanimación cardiopulmonar (NO RCP)",0,1);
            
            pc.addImageCols( (prop.getProperty("no_no1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Donante de Órgano",0,1);
            
            pc.addImageCols( (prop.getProperty("no_no2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("No Transfusiones de sangre",0,3);
            
            pc.addCols(" ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("no_no3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otro",0,1);
            pc.addCols(prop.getProperty("observacion5"), 0, dHeader.size()-4);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("EVALUACION SOCIAL Y ACTIVIDADES",0,dHeader.size(),Color.lightGray);
            
            pc.setFont(10,0);
            
            if( prop.getProperty("realiza_ejercicio")!=null && !prop.getProperty("realiza_ejercicio").equals("S") ) prop.setProperty("realiza_ejercicio","N");
            if( prop.getProperty("ingiere_alcohol")!=null && !prop.getProperty("ingiere_alcohol").equals("S") ) prop.setProperty("ingiere_alcohol","N");
            
            pc.addCols("Realiza ejercicios:", 0, 2);
            
            pc.addImageCols( (prop.getProperty("realiza_ejercicio").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("realiza_ejercicio").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addCols(prop.getProperty("observacion6"),0,dHeader.size()-6);
                        
            pc.addCols(" ", 0, dHeader.size());
            
            pc.addCols("Ingiere Alcohol:", 0, 2);
            pc.addImageCols( (prop.getProperty("ingiere_alcohol").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("ingiere_alcohol").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addImageCols( (prop.getProperty("frecuencia_alcohol").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Esporádico",0,1);
            
            pc.addImageCols( (prop.getProperty("frecuencia_alcohol").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("a diario",0,1);
            
            pc.addCols(" ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("frecuencia_alcohol").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Fin de semana",0,1);
            
            pc.addImageCols( (prop.getProperty("frecuencia_alcohol").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otros",0,1);

            pc.addCols(prop.getProperty("observacion7"),0,dHeader.size()-6);
            
            pc.addCols(" ", 0, dHeader.size());
            
            pc.addCols("Ha sido usted consumidor de Tabaco:", 0, 4);
            
            pc.addImageCols( (prop.getProperty("fumador").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("fumador").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols("Específique: ", 0, 2);
            pc.addCols(prop.getProperty("observacion8"),0,dHeader.size()-2);
            
            if( prop.getProperty("fumador_frecuencia")!=null && !prop.getProperty("fumador_frecuencia").equals("S") ) prop.setProperty("fumador_frecuencia","N");
            
            pc.addCols(" ", 0, dHeader.size());
            
            pc.addCols("Ha fumado en los últimos 12 meses:", 0, 4);
            
            pc.addImageCols( (prop.getProperty("fumador_frecuencia").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("fumador_frecuencia").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols("(Especifique cuantos cigarrillos por día)", 0, 2);
            pc.addCols(prop.getProperty("observacion9"),0,dHeader.size()-2);

            if( prop.getProperty("drogadicto")!=null && !prop.getProperty("drogadicto").equals("S") ) prop.setProperty("drogadicto","N");
            
            pc.addCols(" ",0, dHeader.size());
            pc.addCols("Consume Drogas: ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("drogadicto").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("drogadicto").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addCols(prop.getProperty("observacion10"),0,dHeader.size()-6);
            
            pc.addCols(" ",0, dHeader.size());
            pc.addCols("Estado de Salud: ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("estado_salud").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Normal",0,1);
            pc.addImageCols( (prop.getProperty("estado_salud").equalsIgnoreCase("r"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Regular",0,1);
            pc.addImageCols( (prop.getProperty("estado_salud").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otros",0,3);
            
            pc.addCols("Específique:",0,2);
            pc.addCols(prop.getProperty("observacion11"),0,dHeader.size()-2);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("VALORACION PSICOSOCIAL Y ECONOMICA",0,dHeader.size(),Color.lightGray);
            
            pc.setFont(10,0);
            
            pc.addCols(" ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("vive_con").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Vive Solo",0,1);
            
            pc.addImageCols( (prop.getProperty("vive_con").equalsIgnoreCase("f"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Familia",0,1);
            
            pc.addImageCols( (prop.getProperty("vive_con").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otros",0,3);
            
            pc.addCols("Específique:",0,2);
            pc.addCols(prop.getProperty("observacion12"),0,dHeader.size()-2);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Se observa barreras:",0,2);
            
            pc.addImageCols( (prop.getProperty("se_observa0").equalsIgnoreCase("ca"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Carencia afectiva",0,1);
            
            pc.addImageCols( (prop.getProperty("se_observa1").equalsIgnoreCase("pi"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Problemas de Integración",0,1);
            
            pc.addImageCols( (prop.getProperty("se_observa2").equalsIgnoreCase("pf"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Problemas Familiares",0,1);
            
            pc.addImageCols( (prop.getProperty("se_observa3").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Ninguna",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Cuenta con apoyo:",0,2);
            
            pc.addImageCols( (prop.getProperty("tiene_a_cargo0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Familiar",0,1);
            
            pc.addImageCols( (prop.getProperty("tiene_a_cargo1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Amigos",0,1);
            
            pc.addImageCols( (prop.getProperty("tiene_a_cargo2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            
            pc.addImageCols( (prop.getProperty("tiene_a_cargo3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Ninguno",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Situación Laboral:",0,2);
            
            pc.addImageCols( (prop.getProperty("situacion_laboral").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Jubilado",0,1);
            
            pc.addImageCols( (prop.getProperty("situacion_laboral").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Desempleo",0,1);
            
            pc.addImageCols( (prop.getProperty("situacion_laboral").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Ama de casa",0,1);
            
            pc.addImageCols( (prop.getProperty("situacion_laboral").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Pensionado",0,1);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("situacion_laboral").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Labora",0,1);
            
            pc.addImageCols( (prop.getProperty("situacion_laboral").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otras",0,1);
            pc.addCols(prop.getProperty("observacion26"),0,5);
            
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Vivienda:",0,2);
            
            pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Adecuada a necesidades",0,1);
            
            pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Innadecuada",0,1);
            
            pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("ho"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Barreras",0,1);
            
            pc.addImageCols( (prop.getProperty("residencia_actual").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            
            pc.addCols("Específique:",0,2);
            pc.addCols(prop.getProperty("observacion13"),0,dHeader.size()-2);
            
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Aspecto Económico: Se detecta dificultades:",0,4);
            
            pc.addImageCols( (prop.getProperty("aspecto_economico").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addImageCols( (prop.getProperty("aspecto_economico").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,3);
          
            pc.addCols("Específique:",0,2);
            pc.addCols(prop.getProperty("observacion14"),0,dHeader.size()-2);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("VALORACION PARA PACIENTE QUIRURGICO (SOP y Hemodinámica)",0,dHeader.size()-4,Color.lightGray);
            
            pc.addImageCols( (prop.getProperty("valoracion").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addImageCols( (prop.getProperty("valoracion").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,3);
            
            pc.setFont(10,0);
            
            pc.addCols("Le explicaron la cirugía que le van a realizar:",0,4);
            
            pc.addImageCols( (prop.getProperty("valoracion_quir").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No Aplica",0,1);
            
            pc.addImageCols( (prop.getProperty("valoracion_quir").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("valoracion_quir").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Le explicaron el consentimiento informado, riesgo beneficio:",0,4);

            pc.addImageCols( (prop.getProperty("explicacion_consentimiento").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("explicacion_consentimiento").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No",0,3);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Tiene Prótesis Dental:",0,4);

            pc.addImageCols( (prop.getProperty("protesis_dental").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("protesis_dental").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No",0,3);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Lentes de Contactos:",0,4);

            pc.addImageCols( (prop.getProperty("lentes_contacto").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("lentes_contacto").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("No",0,3);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Cuando fue la última vez que ingirió alimento:",0,4);
            pc.addCols(prop.getProperty("ultima_comida"),0,6);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Observación:",0,2);
            pc.addCols(prop.getProperty("observacion15"),0,8);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("DATOS OBTENIDOS DE",0,dHeader.size(),Color.lightGray);
            pc.setFont(10,0);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("datos_obetenidos_de0").equalsIgnoreCase("p"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Paciente",0,1);
            
            pc.addImageCols( (prop.getProperty("datos_obetenidos_de1").equalsIgnoreCase("f"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Familiar",0,1);
            
            pc.addImageCols( (prop.getProperty("datos_obetenidos_de2").equalsIgnoreCase("a"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Amigo",0,1);
            
            pc.addImageCols( (prop.getProperty("datos_obetenidos_de3").equalsIgnoreCase("h"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Historia Clínica",0,1);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("datos_obetenidos_de4").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            pc.addCols(prop.getProperty("observacion16"),0,dHeader.size()-4);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("MEDICOS ENTERADOS",0,2);
            pc.addImageCols( (prop.getProperty("medicos_enterados").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("medicos_enterados").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addCols(prop.getProperty("observacion17"),0,dHeader.size() - 6);
        
        } else if (fg.equalsIgnoreCase("PE")) {
			
            pc.setFont(10,1);
            pc.addCols("HISTORIA DEL NACIMIENTO",0,dHeader.size(),Color.lightGray);
            pc.setFont(10,0);
            
            pc.addCols(" ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("historia_nacimiento").equalsIgnoreCase("pn"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Parto Normal",0,1);
            
            pc.addImageCols( (prop.getProperty("historia_nacimiento").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Cesárea",0,1);
            
            pc.addCols("Apgar: "+prop.getProperty("apgar"),0,2);
            pc.addCols("Peso al Nacer: "+prop.getProperty("peso_al_nacer"),0,2);
            
            pc.addCols(" ", 0, 2);
            
            pc.addImageCols( (prop.getProperty("cuidado_especial").equalsIgnoreCase("jm"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Sale junto a su madre",0,1);
            
            pc.addImageCols( (prop.getProperty("cuidado_especial").equalsIgnoreCase("ce"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Cuidados Especiales",0,1);
            pc.addCols(prop.getProperty("observacion0") ,0,4);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size(),Color.lightGray);
            pc.setFont(10,0);
            
            pc.addCols("Ha disminuido la ingesta en las últimas dos semanas:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional0").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols(" ", 0, dHeader.size());
            pc.addCols("Diagnostico Medico: Gastroenteritis, Vómitos, Nauseas:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols(" ", 0, dHeader.size());
            pc.addCols("Perdida de peso en las ultimas dos semanas:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols(" ", 0, dHeader.size());
            pc.addCols("Progreso de control de crecimiento y desarrollo:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("A"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Adecuado",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("e"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Excesivo",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Deficiente",0,1);
            
            pc.addCols(" ", 0, dHeader.size());
            pc.addCols("Paciente se encuentra con nutrición enteral:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols(" ", 0, dHeader.size());
            pc.addCols("Paciente en estado inconsciente:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional5").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional5").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols(" ", 0, dHeader.size());
            pc.addCols("Paciente en cuidados intensivos:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional6").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional6").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols(" ", 0, dHeader.size());
            pc.addCols("Pérdida de peso >10% en un mes, comunicarse con la nutricionista para una evaluación completa vía mensaje de texto:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional7").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional7").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,3);
            
            pc.addCols(" ",0,dHeader.size());
            
            String via = "";
            if (""+prop.getProperty("via")!=null){
              if (prop.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
              else if (prop.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
              else if (prop.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
              else if (prop.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
            }
            
            pc.addCols("Nombre de Nutricionista Enterada:",0,2);
            pc.addCols(prop.getProperty("nutricionista")+"          Hora: "+prop.getProperty("hora")+"          Via de comunicación: "+via,0,8);
            
            
            if(alC.size() > 0) {
				String tituloEdad = "";
				if (fg.trim().equalsIgnoreCase("PE")) {
					if (edadMes > 0 && edadMes <= 36 && edad < 4) tituloEdad = edadMes+" meses";
				else if (edad >=4 && edad <= 11) tituloEdad = edad+" años";
				} else {
				  if (edad <= 19) tituloEdad = edad+" años";
				}
				
				pc.setNoColumnFixWidth(tblEval);
				pc.createTable("tblEval");
					pc.addCols("____________________________________________________________________________________________________________________________________",1,tblEval.size(),15f);
					
					pc.setFont(10,1);
					pc.addCols("EVALUACIÓN DE CRECIMIENTO Y DESARROLLO ("+tituloEdad+")", 0, tblEval.size(),Color.lightGray);
					
					pc.setFont(10,0);
					
					String grupo = "";
					for (int i = 0; i<alC.size(); i++){
						CommonDataObject cdoC = (CommonDataObject) alC.get(i);

						if (!grupo.equals(cdoC.getColValue("grupo"))){
							pc.setFont(10,1);
							pc.addCols(cdoC.getColValue("grupo"), 0, tblEval.size());
						}
						pc.setFont(10,0);
						pc.addImageCols( (prop.getProperty("evaluacion_crecimiento"+i)!=null&&prop.getProperty("evaluacion_crecimiento"+i).equals(""+i))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
						pc.addCols(cdoC.getColValue("descripcion"),0,1);
						
						if( (i+1) == alC.size()) {
							pc.addCols(prop.getProperty("observacion1"), 0, tblEval.size());
						}
					}
			}
			
          if(alC.size() > 0) {
              pc.useTable("main");
              pc.addTableToCols("tblEval",0,dHeader.size(),0,null,null, 0.0f, 0.0f, 0.0f, 0.0f);
              pc.addCols(" ",0,dHeader.size());
          }
            
        } else {
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("HISTORIA GINECO- OBSTETRICA",0,dHeader.size(),Color.lightGray);
            pc.setFont(10,0);
            
            pc.addCols("EVOLUCION DE EMBARAZOS – PARTOS – PUERPERIOS",0, 6);
            pc.addImageCols( (prop.getProperty("evolucion_embarazos").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addImageCols( (prop.getProperty("evolucion_embarazos").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addCols(" ",1,dHeader.size());
            pc.addCols("Embarazos Anteriores",0, 2);
        
            pc.addImageCols( (prop.getProperty("embarazos_anteriores").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Normal(es)",0,1);
        
            pc.addImageCols( (prop.getProperty("embarazos_anteriores").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Complicado(s)",0,5);
        
            pc.addCols(" ",1,dHeader.size());
            pc.addCols("Partos Anteriores",0, 2);
        
            pc.addImageCols( (prop.getProperty("partos_anteriores").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Normal(es)",0,1);
        
            pc.addImageCols( (prop.getProperty("partos_anteriores").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Complicado(s)",0,5);
        
            pc.addCols(" ",1,dHeader.size());
            pc.addCols("Malformaciones Congénitas",0, 2);
        
            pc.addImageCols( (prop.getProperty("malformaciones_congenitas").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
        
            pc.addImageCols( (prop.getProperty("malformaciones_congenitas").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addCols(prop.getProperty("observacion21"),0,4);
        
            pc.addCols(" ",1,dHeader.size());
            
            pc.setFont(10,1);
            pc.addCols("ANTECEDENTES GINECO OBSTETRICOS",0,dHeader.size());
            pc.setFont(10,0);
            
            pc.addCols("GRAVA:",0,2);
            pc.addCols(prop.getProperty("grava"),0,2);
            pc.addCols("PARA:",0,2);
            pc.addCols(prop.getProperty("para"),0,4);

            pc.addCols("CESAREA:",0,2);
            pc.addCols(prop.getProperty("cesarea"),0,2);
            pc.addCols("ABORTO:",0,2);
            pc.addCols(prop.getProperty("aborto"),0,4);
        
            pc.addCols(" ",1,dHeader.size());
            
            pc.addCols("Última menstruación:",0,2);
            pc.addCols(prop.getProperty("fecha_ultima_menstruacion"),0,2);
            pc.addCols("Fecha Probable de Parto:",0,2);
            pc.addCols(prop.getProperty("fecha_probable_parto"),0,4);
            
            pc.addCols("Menarquia:",0,2);
            pc.addCols(prop.getProperty("menarquia"),0,2);
            pc.addCols("Tipaje y RH:",0,2);
            pc.addCols(prop.getProperty("tipaje_y_rh"),0,4);
            
            pc.addCols(" ",1,dHeader.size());
            pc.addCols("Control Prenatal:",0,2);
            
            pc.addImageCols( (prop.getProperty("control_prenatal").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("control_prenatal").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,5);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("EVALUACIÓN OBSTETRICA",0,dHeader.size(),Color.lightGray);
            pc.setFont(10,0);
            
            pc.addCols("Mamas:",0,2);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica0").equalsIgnoreCase("bl"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Blandas",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica0").equalsIgnoreCase("tu"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Turgentes",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica0").equalsIgnoreCase("du"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Duras",0,3);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Movimientos Fetales:",0,2);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica1").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica1").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addCols("FCF: "+prop.getProperty("fcf"),0,4);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Actividad Uterina:",0,2);
            pc.addCols(prop.getProperty("actividad_uterina"),0,8);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Sangrado transvaginal:",0,2);
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica2").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica2").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addCols("Color: "+prop.getProperty("color")+"            Cantidad: "+prop.getProperty("cantidad"),0,4);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Dilatación: "+prop.getProperty("dilatacion")+"            Borramiento: "+prop.getProperty("borramiento")+"            Plano: "+prop.getProperty("plano"),0,dHeader.size());
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Membranas:",0,2);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica3").equalsIgnoreCase("i"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Integras",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica3").equalsIgnoreCase("r"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Rotas",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica3").equalsIgnoreCase("h"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Horas",0,3);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Presentación:",0,2);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica4").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Cefálica",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica4").equalsIgnoreCase("p"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Pélvica",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica4").equalsIgnoreCase("t"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Transversa",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica4").equalsIgnoreCase("x"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("N/A",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Consistencia Líquido Amniótico:",0,2);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica5").equalsIgnoreCase("f"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Fluido",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica5").equalsIgnoreCase("e"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Espeso",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica5").equalsIgnoreCase("x"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("N/A",0,3);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Secreciones:",0,2);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica6").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica6").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addCols(prop.getProperty("observacion22"),0,4);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Abdomen:",0,2);
            
            pc.addImageCols( (prop.getProperty("abdomen0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Blando",0,1);
            
            pc.addImageCols( (prop.getProperty("abdomen1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Distendido",0,1);
            
            pc.addImageCols( (prop.getProperty("abdomen2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Doloroso",0,3);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("abdomen3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Gravídico",0,1);
            pc.addCols("Altura Uterina: "+prop.getProperty("altura_ulterina"),0,6);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Edema: ",0,2);
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica7").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica7").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addCols(prop.getProperty("observacion23"),0,4);
            
            pc.addCols(" ",0,dHeader.size());
            pc.addCols("Varices: ",0,2);
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica8").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("evaluacion_obstetrica8").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            pc.addCols(prop.getProperty("observacion24"),0,4);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(10,1);
            pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size(),Color.lightGray);
            pc.setFont(10,0);
            
            pc.addCols("Ha disminuido la ingesta en las &uacute;ltimas dos semanas: ",0,6);
            pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Padece de Diabetes Gestacional: ",0,6);
            pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Toma tres o más tragos de licor por día: ",0,6);
            pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            
            pc.addCols("Progreso de control de crecimiento y desarrollo:",0,4);
            pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("A"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Adecuado",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("e"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Excesivo",0,1);
            pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("Deficiente",0,1);
            
            pc.addCols(" ",0,dHeader.size());
            
            String via = "";
            if (""+prop.getProperty("via")!=null){
              if (prop.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
              else if (prop.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
              else if (prop.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
              else if (prop.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
            }
            
            pc.addCols("Nombre de Nutricionista Enterada:",0,2);
            pc.addCols(prop.getProperty("nutricionista")+"          Hora: "+prop.getProperty("hora")+"          Via de comunicación: "+via,0,8);

        }
        } else {
            if (fp.equalsIgnoreCase("exp_kardex")||fp.equalsIgnoreCase("handover")){
                pc.setFont(10,1);
                pc.addCols("EVALUACIÓN INICIAL DE LAS ENFERMEDADES TRANSMISIBLES",0,dHeader.size(),Color.lightGray);
                
                pc.setFont(10,1,Color.gray);
                pc.addCols(" ",0,2);
                
                pc.setFont(10,0);
                pc.addImageCols( (prop.getProperty("aislamiento").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("aislamiento").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addImageCols( (prop.getProperty("aislamiento_det1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Paciente con Aislamiento de Contacto",0,1);
                
                pc.addImageCols( (prop.getProperty("aislamiento_det3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Paciente Con Aislamiento de Gotas",0,1);
                
                pc.addCols(" ",0,2);
                
                pc.addImageCols( (prop.getProperty("aislamiento_det5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Paciente con Aislamiento Respiratorio (Gotitas)",0,1);
                
                pc.addImageCols( (prop.getProperty("aislamiento_det0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Orientación al paciente y familiar",0,1);
                
                pc.addImageCols( (prop.getProperty("aislamiento_det2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Coordinación con la enfermera de nosocomial",0,1);
                
                pc.addImageCols( (prop.getProperty("aislamiento_det4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Colocación del equipo de protección",0,1);
                
                pc.addCols(" ",0,2);
                pc.addImageCols( (prop.getProperty("aislamiento_det6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Otros",0,1);
                pc.addCols(prop.getProperty("observacion27"),0,6);
                
            } else if (fp.equalsIgnoreCase("nutricional_riesgo")) {
                if (fg.trim().equalsIgnoreCase("c1")){
                pc.setFont(10,1);
                pc.addCols(" ",0,dHeader.size());
                pc.addCols("NUTRICION: CRIBADO NUTRICIONAL (No Aplica a Pediatría ni Obstetricia)",0,dHeader.size(),Color.lightGray);
                
                pc.setFont(10,0);
                
                pc.addCols("Pérdida de Peso en los últimos tres (3) meses?",0,6);
                pc.addImageCols( (prop.getProperty("perdido_peso").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
            
                pc.addImageCols( (prop.getProperty("perdido_peso").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Disminución de la ingesta en la última semana?",0,6);
                pc.addImageCols( (prop.getProperty("disminucion").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
            
                pc.addImageCols( (prop.getProperty("disminucion").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Tiene alguno de estos Diagnósticos: Diabetes, EPOC, Nefrópata (hemodiálisis), Enfermedad Oncológico, Fractura de Cadera, Cirrosis hepática)",0,6);
                pc.addImageCols( (prop.getProperty("diabetes").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("diabetes").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
            
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Paciente se encuentra en la Unidad de Cuidados Intensivos",0,6);
                pc.addImageCols( (prop.getProperty("unidad_cuidado").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("unidad_cuidado").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Paciente se encuentra con nutrición enteral",0,6);
                pc.addImageCols( (prop.getProperty("nutricion_enteral").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("nutricion_enteral").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Paciente con problemas de comunicación",0,6);
                pc.addImageCols( (prop.getProperty("problema_comunicacion").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("problema_comunicacion").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
            
                pc.addCols("Que haya perdido >15% en los últimos meses",0,6);
                pc.addImageCols( (prop.getProperty("perdida_peso_15").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("perdida_peso_15").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Que el paciente >80 años deberán, comunicarse con la nutricionista para una evaluación completa, vía mensaje de texto",0,6);
                pc.addImageCols( (prop.getProperty("mayor_80").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("mayor_80").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
            
                pc.setFont(12,1);
                pc.addCols(" ",0,dHeader.size());
                pc.addCols("Observaciones de alerta a presentar:\n1. En caso de 2 o más alteraciones resulten en (SI)\n2. Si el Paciente se encuentra con nutrición enteral\n3. Si el Paciente con problemas de comunicación\n4. si es paciente de Cuidados Intensivos que mande alerta\n5. Que haya perdido >15% en los últimos meses\n6. Que el paciente >80 años deberán, comunicarse con la nutricionista para una evaluación completa, vía mensaje de texto",0,dHeader.size());
                pc.addCols(" ",0,dHeader.size());
                
                pc.setFont(10,1,Color.gray);
                pc.addCols("Nutricionista Enterada:",0,2);
                
                pc.setFont(10,0);
                
                String via = "";
                if (""+prop.getProperty("via")!=null){
                  if (prop.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
                  else if (prop.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
                  else if (prop.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
                  else if (prop.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
                }

                pc.addCols(prop.getProperty("nutricionista"),0,2);
                pc.addCols(" Hora: "+prop.getProperty("hora"),0,3);
                pc.addCols(" Vía Comunicación: "+via,0,3);
                
                } else if (fg.trim().equalsIgnoreCase("em")) {
                    pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
                    pc.setFont(10,1);
                    pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size(),Color.lightGray);
                    pc.setFont(10,0);
                    
                    pc.addCols("Ha disminuido la ingesta en las últimas dos semanas: ",0,6);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("SI",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("NO",0,1);
            
                    pc.addCols(" ",0,dHeader.size());
                    
                    pc.addCols("Padece de Diabetes Gestacional: ",0,6);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("SI",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("NO",0,1);
                    
                    pc.addCols(" ",0,dHeader.size());
            
                    pc.addCols("Toma tres o más tragos de licor por día: ",0,6);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("SI",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("NO",0,1);
                    
                    pc.addCols(" ",0,dHeader.size());
            
                    pc.addCols("Progreso de control de crecimiento y desarrollo:",0,4);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("A"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("Adecuado",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("e"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("Excesivo",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("Deficiente",0,1);
                    
                    pc.addCols(" ",0,dHeader.size());
            
                    String via = "";
                    if (""+prop.getProperty("via")!=null){
                      if (prop.getProperty("via").equalsIgnoreCase("c")) via = "Correo";
                      else if (prop.getProperty("via").equalsIgnoreCase("t")) via = "Teléfono";
                      else if (prop.getProperty("via").equalsIgnoreCase("p")) via = "Personal";
                      else if (prop.getProperty("via").equalsIgnoreCase("s")) via = "SMS";
                    }
                    
                    pc.addCols("Nombre de Nutricionista Enterada:",0,2);
                    pc.addCols(prop.getProperty("nutricionista")+"          Hora: "+prop.getProperty("hora")+"          Via de comunicación: "+via,0,8);
                
                } else if (fg.trim().equalsIgnoreCase("pe")) {
                    pc.setFont(10,1);
                    pc.addCols("NUTRICION: CRIBADO NUTRICIONAL",0,dHeader.size(),Color.lightGray);
                    pc.setFont(10,0);
                    
                    pc.addCols("Ha disminuido la ingesta en las últimas dos semanas:",0,4);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional0").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("SI",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("NO",0,3);
                    
                    pc.addCols(" ", 0, dHeader.size());
                    pc.addCols("Diagnostico Medico: Gastroenteritis, Vómitos, Nauseas:",0,4);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("SI",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional1").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("NO",0,3);
                    
                    pc.addCols(" ", 0, dHeader.size());
                    pc.addCols("Perdida de peso en las ultimas dos semanas:",0,4);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("SI",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional2").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("NO",0,3);
                    
                    pc.addCols(" ", 0, dHeader.size());
                    pc.addCols("Progreso de control de crecimiento y desarrollo:",0,4);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("A"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("Adecuado",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("e"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("Excesivo",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional3").equalsIgnoreCase("d"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("Deficiente",0,1);
                    
                    pc.addCols(" ", 0, dHeader.size());
                    pc.addCols("Paciente se encuentra con nutrición enteral:",0,4);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("SI",0,1);
                    pc.addImageCols( (prop.getProperty("cribado_nutricional4").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                    pc.addCols("NO",0,3);
                }
            } else if (fp.equalsIgnoreCase("nutricional_riesgo_funcional")) {
                pc.setFont(10,1);
                pc.addCols(" ",0,dHeader.size());
                pc.addCols("VALORACION FUNCIONAL",0,dHeader.size(),Color.lightGray);
                
                pc.setFont(10,0);
                
                pc.addCols("Baño / higiene",0,4);
                pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("No requiere ayuda",0,1);
                
                pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("Ayuda parcial",0,1);
                
                pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("Ayuda total",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Vestirse / desvestirse / alimentación",0,4);
                pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("No requiere ayuda",0,1);
                
                pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("Ayuda parcial",0,1);
                
                pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("Ayuda total",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Movilidad deambulación",0,4);
                pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("No requiere ayuda",0,1);
                
                pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("Ayuda parcial",0,1);
                
                pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("Ayuda total",0,1);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                
                pc.addCols("Alguna Dificultad Funcional:",0,2);
                
                pc.addImageCols( (prop.getProperty("movimiento").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("movimiento").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,5);
                
                
                pc.addCols(" ",0,2);            
                pc.addImageCols( (prop.getProperty("dificultad_movimiento0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Moverse",0,1);
                
                pc.addImageCols( (prop.getProperty("dificultad_movimiento1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Caminar",0,1);
                
                pc.addImageCols( (prop.getProperty("dificultad_movimiento2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Levantarse",0,1);
                
                pc.addImageCols( (prop.getProperty("dificultad_movimiento3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Sentarse",0,1);
                
                pc.addCols(" ",0,2);            
                pc.addImageCols( (prop.getProperty("dificultad_movimiento4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Pérdida Funcional",0,1);
                
                pc.addImageCols( (prop.getProperty("dificultad_movimiento5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Prótesis",0,1);
                
                pc.addImageCols( (prop.getProperty("dificultad_movimiento6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Paresias/plejia",0,1);
                
                pc.addImageCols( (prop.getProperty("dificultad_movimiento7").equalsIgnoreCase("7"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Amputaciones",0,1);
                
                pc.addCols(" ",0,2);
                pc.addImageCols( (prop.getProperty("dificultad_movimiento8").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Otro",0,1);
                pc.addCols(prop.getProperty("observacion0"), 0, dHeader.size()-4);
                
                pc.addBorderCols("  ",0,dHeader.size(), 0.5f);
                pc.addCols("Alguna necesidad especial: ",0,2);
                
                pc.addImageCols( (prop.getProperty("necesidad").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("necesidad").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
                pc.addCols("NO",0,1);
                
                pc.addImageCols( (prop.getProperty("necesidad_especial0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Ciego",0,1);
                
                pc.addImageCols( (prop.getProperty("necesidad_especial1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Sordo",0,1);
                
                pc.addCols(" ",0,2);
                
                pc.addImageCols( (prop.getProperty("necesidad_especial2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Mudo",0,1);
                
                pc.addImageCols( (prop.getProperty("necesidad_especial3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Otro",0,1);
                pc.addCols(prop.getProperty("observacion1"),0,dHeader.size() - 6);
                
                pc.setFont(12, 1);
                pc.addCols(" ",0,dHeader.size());
                pc.addCols("Observación: En caso de detectar alguna alteración funcional o necesidad especial, se deberá comunicar al médico inmediatamente para una evaluación más completa",0,dHeader.size());
            }            
        }
            
    }//else
	
	pc.addTable();
	
	SecMgr.setConnection(null);
  CmnMgr.setConnection(null);
  SQLMgr.setConnection(null);

	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
%>