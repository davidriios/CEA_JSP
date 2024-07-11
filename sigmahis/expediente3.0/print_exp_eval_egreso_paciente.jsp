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
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
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

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
if(desc == null) desc = "";

prop = SQLMgr.getDataProperties("select sumario from tbl_sal_sumario_egreso_enf where pac_id="+pacId+" and admision="+noAdmision+" and tipo_sumario = '"+fg+"'");

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
	String subTitle = !desc.equals("")?desc:"SUMARIO DE EGRESO DE ENFERMERÍA";
	String xtraSubtitle = fg.trim().equalsIgnoreCase("AD") ? "(ADULTO)" : "(NEONATO)";
	
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
            
            cdo = SQLMgr.getData("select to_char(fecha_creacion,'dd/mm/yyyy hh12:mi am') fc, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi am') fm, usuario_creacion, usuario_modificacion from tbl_sal_sumario_egreso_enf where pac_id = "+pacId+" and admision = "+noAdmision);
            
            if (cdo == null) {
              cdo = new CommonDataObject();
            }
            
			pc.setFont(9,0);
			
			pc.addBorderCols("Fecha: ",0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("fc"," "),0,3,0.1f,0.0f,0.0f,0.0f);
		    pc.addBorderCols("Usuario: ",1,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("usuario_creacion", " "),0,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,4,0.1f,0.0f,0.0f,0.0f);
            pc.addCols(" ",1,dHeader.size());
            
            pc.addBorderCols("Modificado: ",0,1,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("fm"," "),0,3,0.1f,0.0f,0.0f,0.0f);
		    pc.addBorderCols("Por: ",1,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols(cdo.getColValue("usuario_modificacion"," "),0,2,0.1f,0.0f,0.0f,0.0f);
			pc.addBorderCols("",0,4,0.1f,0.0f,0.0f,0.0f);
            pc.addCols(" ",1,dHeader.size());
            
            pc.setFont(9,1,Color.white);
			pc.addCols("Condición de Salida",0,dHeader.size(),15f,Color.gray);
			pc.addCols(" ",1,dHeader.size(),15f);
			
			pc.setFont(9,1,Color.gray);
			pc.addCols("Salida: ",0,2);
			
			pc.setFont(9,0);
			pc.addImageCols( (prop.getProperty("salida").equalsIgnoreCase("a"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
            pc.addCols("Autorizada",0,1);
			
			pc.addImageCols( (prop.getProperty("salida").equalsIgnoreCase("v"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Voluntaria",0,1);
            
            if (prop.getProperty("salida") != null && prop.getProperty("salida").equalsIgnoreCase("v")) {
            
                pc.addImageCols( (prop.getProperty("relevo_responsabilidad").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("Relevo de Responsabilidades",0,1);
			
                pc.addImageCols( (prop.getProperty("relevo_responsabilidad").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("NO Relevo de Responsabilidades",0,1);
                
            } else {
              pc.addCols("",0,4);
            }
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
  
			pc.setFont(9,1,Color.gray);
			pc.addCols("Condición del paciente al egreso: ",0,2);
			
			pc.setFont(9,0);

			pc.addImageCols( (prop.getProperty("condicion_paciente").equalsIgnoreCase("r"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Recuperado",0,1,10f);

			pc.addImageCols( (prop.getProperty("condicion_paciente").equalsIgnoreCase("c"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Convaleciente",0,1,10f);

			pc.addImageCols( (prop.getProperty("condicion_paciente").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
			pc.addCols("Otros",0,3,10f);
			
			//eol
			
			if (prop.getProperty("condicion_paciente").equalsIgnoreCase("ot")){
			  pc.addCols("Comentarios: ",2,2);
			  pc.addCols(prop.getProperty("observacion0"),0,8);
			}  
          
            if(!fg.trim().equals("NEO")){
                pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
          
                pc.setFont(9,1,Color.white);
                pc.addCols("Necesidades Personales",0,dHeader.size(),15f,Color.gray);
            
                pc.setFont(9,1,Color.black);
                pc.addCols("Autonomía para la vida diaria",0,dHeader.size(),15f);
                pc.addCols(" ",1,dHeader.size(),15f);

                pc.setFont(9,1,Color.gray);  
                pc.addCols("Baño / higiene: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("No requiere ayuda",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("Ayuda parcial",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("banio_higiene").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("Ayuda total",0,1);
                pc.addCols("",0,2);
                
                pc.setFont(9,1,Color.gray);  
                pc.addCols("Vestirse desvestirse alimentación: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("No requiere ayuda",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("Ayuda parcial",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("vestir_desvestir_ali").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("Ayuda total",0,1);
                pc.addCols("",0,2);
                
                pc.setFont(9,1,Color.gray);  
                pc.addCols("Movilidad deambulación: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("No requiere ayuda",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("ap"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("Ayuda parcial",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("movilidad_deambulacion").equalsIgnoreCase("at"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("Ayuda total",0,1);
                pc.addCols("",0,2);
                
                //piel
                pc.addCols(" ",0,dHeader.size());
                pc.setFont(9,1,Color.gray);  
                pc.addCols("Condición de la piel: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_piel0").equalsIgnoreCase("in"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Integra",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_piel1").equalsIgnoreCase("ul"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Ulcera",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_piel2").equalsIgnoreCase("hq"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Herida Quirúrgica",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_piel3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Otro",0,1);
                
                if (prop.getProperty("condicion_piel3").equalsIgnoreCase("ot")){
                  pc.addCols("Comentarios: ",2,2);
                  pc.addCols(prop.getProperty("observacion1"),0,8);
                }
                
                //mental
                pc.addCols(" ",0,dHeader.size());
                pc.setFont(9,1,Color.gray);  
                pc.addCols("Condición mental: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_mental0").equalsIgnoreCase("al"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Alerta",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_mental1").equalsIgnoreCase("or"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Orientado",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_mental2").equalsIgnoreCase("co"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Confuso",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("condicion_mental3").equalsIgnoreCase("ot"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Otro",0,1);
                
                if (prop.getProperty("condicion_mental3").equalsIgnoreCase("ot")){
                  pc.addCols("Comentarios: ",2,2);
                  pc.addCols(prop.getProperty("observacion2"),0,8);
                }
            }
            
            //sigonos vitales
            pc.addCols(" ",0,dHeader.size());
            pc.setFont(9,1,Color.gray);  
            pc.addCols("Signos Vitales: ",0,2);
            
            pc.setFont(9,0);
            pc.addCols("Temperatura: "+prop.getProperty("signos_vitales0"),0,2);
            pc.addCols("Pulso: "+prop.getProperty("signos_vitales1"),0,2);
            pc.addCols("Respiración: "+prop.getProperty("signos_vitales2"),0,2);
            pc.addCols("Presión Arterial: "+prop.getProperty("signos_vitales3"),0,2);
            
            pc.addCols(" ",0,2);
            pc.addCols("SO2: "+prop.getProperty("signos_vitales4"),0,2);
            pc.addCols("Dolor: "+prop.getProperty("signos_vitales5"),0,6);
                        
            if(fg.trim().equalsIgnoreCase("NEO")){            
                pc.addCols("",1,dHeader.size(),15f);
                pc.setFont(9,1,Color.white);
                pc.addCols("Tamizajes",0,dHeader.size(),15f,Color.gray);

                pc.setFont(9,1,Color.gray);  
                pc.addCols("Auditivo: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("auditivo").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("SI",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("auditivo").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("NO",0,1);
                pc.addCols(prop.getProperty("observacion25"),0,4);
                
                pc.setFont(9,1,Color.gray);  
                pc.addCols("Metabólico: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("metabolico").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("SI",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("metabolico").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("NO",0,1);
                pc.addCols(prop.getProperty("observacion26"),0,4);
                
                pc.setFont(9,1,Color.gray);  
                pc.addCols("Cardiáco: ",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("cardiaco").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("SI",0,1);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("cardiaco").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("NO",0,1);
                pc.addCols(prop.getProperty("observacion27"),0,4);
            }

            if(!fg.trim().equalsIgnoreCase("NEO")){
            
                pc.addCols("",1,dHeader.size(),15f);
                pc.setFont(9,1,Color.white);
                pc.addCols("Instrucciones al Egreso",0,dHeader.size(),15f,Color.gray);
                pc.setFont(9,0,Color.black); 
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Equipos especiales",0,3);
                pc.addCols(prop.getProperty("observacion3"),0,4); 
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Cuidados post operatorios",0,3);
                pc.addCols(prop.getProperty("observacion4"),0,4); 
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Curación de heridas",0,3);
                pc.addCols(prop.getProperty("observacion5"),0,4); 
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Signos y síntomas de infección",0,3);
                pc.addCols(prop.getProperty("observacion6"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Terapia respiratoria",0,3);
                pc.addCols(prop.getProperty("observacion7"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Fisioterapia",0,3);
                pc.addCols(prop.getProperty("observacion8"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Glicemia capilar",0,3);
                pc.addCols(prop.getProperty("observacion9"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones7").equalsIgnoreCase("7"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Dieta especial",0,3);
                pc.addCols(prop.getProperty("observacion10"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones8").equalsIgnoreCase("8"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Prevención de caídas",0,3);
                pc.addCols(prop.getProperty("observacion11"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones9").equalsIgnoreCase("9"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Manejo del dolor",0,3);
                pc.addCols(prop.getProperty("observacion12"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones10").equalsIgnoreCase("10"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Medicamentos",0,3);
                pc.addCols(prop.getProperty("observacion13"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones11").equalsIgnoreCase("11"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Otros",0,3);
                pc.addCols(prop.getProperty("observacion14"),0,4);
            } else {
            
                pc.addCols("",1,dHeader.size(),15f);
                pc.setFont(9,1,Color.white);
                pc.addCols("Instrucciones al Egreso",0,dHeader.size(),15f,Color.gray);
                pc.setFont(9,0,Color.black); 
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones0").equalsIgnoreCase("0"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Lactancia materna",0,3);
                pc.addCols(prop.getProperty("observacion3"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Complemento (tipo formula)",0,3);
                pc.addCols(prop.getProperty("observacion4"),0,4); 
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones2").equalsIgnoreCase("2"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Forma de preparación",0,3);
                pc.addCols(prop.getProperty("observacion5"),0,4); 
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Posición de la madre y bebe",0,3);
                pc.addCols(prop.getProperty("observacion6"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Baño del bebe",0,3);
                pc.addCols(prop.getProperty("observacion7"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Forma de sacar los gases",0,3);
                pc.addCols(prop.getProperty("observacion8"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Cuidados del cordón umbilical",0,3);
                pc.addCols(prop.getProperty("observacion9"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones7").equalsIgnoreCase("7"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Higiene de genitales",0,3);
                pc.addCols(prop.getProperty("observacion10"),0,4);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("instrucciones8").equalsIgnoreCase("8"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Cuidados de circuncisión",0,3);
                pc.addCols(prop.getProperty("observacion11"),0,4);
                
                pc.addCols("",0,dHeader.size());
                pc.setFont(9,1,Color.gray);  
                pc.addCols("Comprendió las instrucciones ofrecidas:",0,2);
                
                pc.setFont(9,0); 
                pc.addImageCols( (prop.getProperty("comprendio_instrucciones").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("SI",0,1);
                
                pc.addImageCols( (prop.getProperty("comprendio_instrucciones").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
                pc.addCols("NO",0,1);
                pc.addCols(prop.getProperty("observacion24"),0,4);
            }

            if (fg.trim().equalsIgnoreCase("NEO")) {
                Hashtable iNeoEval = new Hashtable();
                iNeoEval.put("0","Condición General");
                iNeoEval.put("1","Activo");
                iNeoEval.put("2","Llanto fuerte");
                iNeoEval.put("3","Condición de la piel");
                iNeoEval.put("4","Color de la piel");
                iNeoEval.put("5","Area del pañal");
                
                pc.addCols("",1,dHeader.size(),15f);
                pc.setFont(9,1,Color.white);
                pc.addCols("Evaluación de Enfermería para neonatos con salida",0,dHeader.size(),15f,Color.gray);
                pc.setFont(9,0,Color.black);
                
                pc.setFont(9,0); 
                for (int e = 0; e<iNeoEval.size(); e++) {
                    pc.addCols(" ",0,2);
                    pc.addImageCols( (prop.getProperty("eval_neo"+e).equalsIgnoreCase(""+e))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                    pc.addCols(""+iNeoEval.get(""+e),0,4);
                    pc.addCols(prop.getProperty("observacion"+(e+15)),0,3);
                }
            }
            
            pc.addCols("",1,dHeader.size(),15f);
            pc.setFont(9,1,Color.white);
            pc.addCols("Sumario del plan de Cuidado",0,dHeader.size(),15f,Color.gray);
            pc.setFont(9,0,Color.black);
            
            pc.addCols("",0,2);
            pc.setFont(9,0); 
            pc.addImageCols( (prop.getProperty("entrega_pertenencia").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Entrega de pertenencias",0,1);
            
            pc.addImageCols( (prop.getProperty("entrega_pertenencia").equalsIgnoreCase("s"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
            pc.addCols("SI",0,1);
                
            pc.addImageCols( (prop.getProperty("entrega_pertenencia").equalsIgnoreCase("n"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
            pc.addCols("NO",0,1);
            
            pc.addImageCols( (prop.getProperty("entrega_pertenencia").equalsIgnoreCase("na"))?ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif":ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif",10,0);
            pc.addCols("No Aplica",0,1);

            pc.addCols("",0,2);
            pc.setFont(9,0); 
            pc.addImageCols( (prop.getProperty("sumario_plan_cuidado1").equalsIgnoreCase("1"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Entrega de recetas y educación acerca de medicamentos",0,7);
            
            pc.addCols("",0,2);
            pc.setFont(9,0); 
            pc.addImageCols( (prop.getProperty("sumario_plan_cuidado3").equalsIgnoreCase("3"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Médico entrega el Egreso médico de medicamentos",0,7);
            
            pc.addCols("",0,2);
            pc.setFont(9,0); 
            pc.addImageCols( (prop.getProperty("sumario_plan_cuidado4").equalsIgnoreCase("4"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Cita dada en la clínica del Dr.:",0,3);
            pc.addCols(prop.getProperty("observacion23"),0,4);
            
            if (fg.trim().equalsIgnoreCase("NEO")) {
                pc.setFont(9,0); 
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("sumario_plan_cuidado5").equalsIgnoreCase("5"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Fecha Cita:",0,1);
                pc.addCols(prop.getProperty("fecha"),0,6);
                
                pc.addCols("",0,2);
                pc.addImageCols( (prop.getProperty("sumario_plan_cuidado6").equalsIgnoreCase("6"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
                pc.addCols("Entrega de panfletos",0,7);
            }
            
            pc.addCols("",0,2);
            pc.addImageCols( (prop.getProperty("sumario_plan_cuidado7").equalsIgnoreCase("7"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Requiere ambulancia / equipos especiales",0,7);
            
            pc.addCols("",0,2);
            pc.addImageCols( (prop.getProperty("sumario_plan_cuidado8").equalsIgnoreCase("8"))?ResourceBundle.getBundle("path").getString("images")+"/checkbox-checked.png":ResourceBundle.getBundle("path").getString("images")+"/checkbox-unchecked.png",10,0);
            pc.addCols("Instrucciones adicionales:",0,3);
            pc.addCols(prop.getProperty("observacion21"),0,4);
            
            pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
            pc.addCols("Observaciones",0,2);
            pc.addCols(prop.getProperty("observacion22"),0,8);
            
            if (prop.getProperty("observacion28") != null && !"".equals(prop.getProperty("observacion28"))){
                pc.setFont(9,1);
                pc.addCols("____________________________________________________________________________________________________________________________________",1,dHeader.size(),15f);
                pc.addCols("RECOMENDACIONES PARA SU DIETA (SI APLICA):",0,dHeader.size());
                pc.addBorderCols(prop.getProperty("observacion28"),0,dHeader.size());
            }

		}//else
		
	
	pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}
%>