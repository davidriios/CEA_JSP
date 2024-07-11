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

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

    cdoUsr.addColValue("usuario",userName);
    if(desc == null) desc = "";
    if(fg == null) fg = "AD";

    prop = SQLMgr.getDataProperties("select plan from tbl_sal_plan_egreso_ingreso where pac_id="+pacId+" and admision="+noAdmision);

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
		
		Vector tblGPCA = new Vector();
		tblGPCA.addElement("8"); //g
		tblGPCA.addElement("17");
		tblGPCA.addElement("8"); //p
		tblGPCA.addElement("17");
		tblGPCA.addElement("8"); //c
		tblGPCA.addElement("17");
		tblGPCA.addElement("8"); //a
		tblGPCA.addElement("17");
		
		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();
			
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if(prop == null){
		   pc.addCols(".:: No Se Ha Encontrado Registros! ::.",1,dHeader.size());
		}else{
      pc.setFont(9,0);
      
			pc.addCols("Fecha: ",0,1);
			pc.addCols(prop.getProperty("fecha_creacion"),0,3);
		  pc.addCols("Usuario: ",2,2);
			pc.addCols(prop.getProperty("usuario_creacion"),0,2);
			pc.addCols("",0,3);
      
      if (!"".equals(prop.getProperty("fecha_modificacion"))) {      
        pc.addCols("Modificado: ",0,1);
        pc.addCols(prop.getProperty("fecha_modificacion"),0,3);
        pc.addCols("Por: ",2,2);
        pc.addCols(prop.getProperty("usuario_modificacion"),0,2);
        pc.addCols("",0,3);
			}
			
			pc.addCols(" ",1,dHeader.size(),7f);
            
			pc.setFont(9,1,Color.white);
			pc.addCols("EVALUACIÓN AL INGRESO DEL PACIENTE",0,dHeader.size(),15f,Color.gray);

            pc.setFont(9,1);
			pc.addCols("Disposiciones Generales para el Egreso",0,dHeader.size(),15f);
			pc.addCols(" ",1,dHeader.size(),7f);
            
			pc.setFont(9,1,Color.gray);
			pc.addCols("Cuenta con familiar para su cuidado: ",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("disposicion0").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("disposicion0").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
                                
			pc.setFont(9,1,Color.gray);
			pc.addCols("Hogar preparado para su salida: ",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("disposicion1").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("disposicion1").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
            
                                
			pc.setFont(9,1,Color.gray);
			pc.addCols("Cuenta con medio de transporte para la salida: ",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("disposicion2").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("disposicion2").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(9,1,Color.gray);
			pc.addCols("El paciente tiene alguna dificultad Para su egreso:",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("dificultad_egreso").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("dificultad_egreso").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("dificultades_egresos0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Transporte al hogar",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultades_egresos1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Uso de escaleras",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultades_egresos2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Ambulancia",0,1);
            
            pc.addImageCols( (prop.getProperty("dificultades_egresos3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Distancia",0,1);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("dificultades_egresos4").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            pc.addCols(prop.getProperty("observacion0"),0,6);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(9,1,Color.gray);
			pc.addCols("El Paciente conoce su Diagnóstico/Pronóstico/Tratamiento:",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("conocer_diag").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("conocer_diag").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("conocer_diags0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Educación al paciente y familiar acerca de su diagnóstico",0,1);
            
            pc.addImageCols( (prop.getProperty("conocer_diags1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Educación al paciente y familiar acerca de su Tratamiento",0,1);
            
            pc.addImageCols( (prop.getProperty("conocer_diags2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Ambulancia",0,3);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(9,1,Color.gray);
			pc.addCols("Toma el Paciente Medicamentos en Casa:",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("medicamento_en_casa").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("medicamento_en_casa").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("_medicamentos_en_casa0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Lista de Medicamentos de admisión, conciliación de medicamentos",0,1);
            
            pc.addImageCols( (prop.getProperty("_medicamentos_en_casa1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Educación al paciente y familiar acerca de medicamentos",0,5);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
			pc.addCols(" ",0,dHeader.size());
            pc.setFont(9,1,Color.white);
			pc.addCols("PLAN DE SALIDA",0,dHeader.size(),Color.gray);
            
            pc.setFont(9,1,Color.gray);
			pc.addCols("Educación para el paciente, familia y/o Acompañante:",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("educacion_paciente").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("educacion_paciente").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("educaciones_paciente0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Folleto de Ingreso",0,1);
            
            pc.addImageCols( (prop.getProperty("educaciones_paciente1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Folleto de Egreso",0,1);
            
            pc.addImageCols( (prop.getProperty("educaciones_paciente2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Care Notes",0,3);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("educaciones_paciente3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            pc.addCols(prop.getProperty("observacion1"),0,6);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
            pc.setFont(9,1,Color.gray);
			pc.addCols("Medicamentos:",0,2);
            
            pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("medicamento").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
			
			pc.addImageCols( (prop.getProperty("medicamento").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
			pc.addCols("NO",0,5);
            
            pc.addCols(" ",0,2);
            
            pc.addImageCols( (prop.getProperty("medicamentos0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Lista de Medicamentos",0,1);
            
            pc.addImageCols( (prop.getProperty("medicamentos1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Conciliación de Medicamentos",0,1);
            
            pc.addImageCols( (prop.getProperty("medicamentos2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Recetas",0,3);
            
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("medicamentos3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Otros",0,1);
            pc.addCols(prop.getProperty("observacion2"),0,6);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
			pc.addCols(" ",0,dHeader.size());
            pc.setFont(9,1,Color.white);
			pc.addCols("Instrucciones de egreso",0,dHeader.size(),Color.gray);
            
            pc.setFont(9,0);
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("inst_egr").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("inst_egr").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,5);
            
            pc.addCols("Técnicas de Rehabilitación",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion3"),0,7);
            
            pc.addCols("Dispositivos de Rehabilitación",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion4"),0,7);
            
            pc.addCols("Dietas",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion5"),0,7);
            
            pc.addCols("Otras",0,2);
            pc.addImageCols( (prop.getProperty("insts_egr3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion6"),0,7);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
			pc.addCols(" ",0,dHeader.size());
            pc.setFont(9,1,Color.white);
			pc.addCols("Tratamientos",0,dHeader.size(),Color.gray);
            
            pc.setFont(9,0);
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("tratamiento").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("tratamiento").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,5);
            
            pc.addCols("Equipos especiales",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion7"),0,7);
            
            pc.addCols("Cuidados Post-Operatorios",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion8"),0,7);
            
            pc.addCols("Curación de heridas",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Terapia respiratoria",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Glicemia capilar",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Fisioterapia",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Otros",0,2);
            pc.addImageCols( (prop.getProperty("tratamientos6").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion9"),0,7);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
			pc.addCols(" ",0,dHeader.size());
            pc.setFont(9,1,Color.white);
			pc.addCols("Pacientes de alto riesgo, considerar",0,dHeader.size(),Color.gray);
            
            pc.setFont(9,0);
            pc.addCols(" ",0,2);
            pc.addImageCols( (prop.getProperty("alto_riesgo").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("SI",0,1);
            
            pc.addImageCols( (prop.getProperty("alto_riesgo").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radio-checked.png":ResourceBundle.getBundle("path").getString("images")+"/radio-unchecked.png",10,0);
            pc.addCols("NO",0,5);
            
            pc.addCols("Equipo multidisciplinario previa salida",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Comunicación directa con médico de cabecera, previa salida",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Cita con médico tratante antes de los 7 días de salida",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Contacto directo con acompañante para salida",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Dieta especial",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion11"),0,7);
            
            pc.addCols("Restricciones",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion12"),0,7);
            
            pc.addCols("Otros",0,2);
            pc.addImageCols( (prop.getProperty("altos_riesgos6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion13"),0,7);
            
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            
			pc.addCols(" ",0,dHeader.size());
            pc.setFont(9,1,Color.white);
			pc.addCols("Instrucciones al ingreso",0,dHeader.size(),Color.gray);
            
            pc.setFont(9,0);
            
            pc.addCols("Funcionamiento y uso del llamado de enfermera",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Derechos y deberes",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Resaltar importancia de no tener objetos de valor consigo durante la hospitalización",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Visitas, rutinas, restricciones y normas de la unidad",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Importancia del respeto de las normas de bioseguridad",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Prevención de caídas",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Evaluación , reevaluación y Manejo del dolor",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Seguridad y uso efectivo de la tecnología médica(alarmas, ruidos, equipos)",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing7").equalsIgnoreCase("7"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Restricciones de Medicamentos usados en casa",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing8").equalsIgnoreCase("8"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Estándar de Seguridad, Identificación del Paciente y lavado de manos",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing9").equalsIgnoreCase("9"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("",0,7);
            
            pc.addCols("Otros",0,2);
            pc.addImageCols( (prop.getProperty("insts_ing10").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols(prop.getProperty("observacion14"),0,7);
            
            
            
            
            

		}//else
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
%>
 