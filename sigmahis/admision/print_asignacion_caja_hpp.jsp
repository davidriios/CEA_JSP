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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania = (String) session.getAttribute("_companyId");

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
if (pacId == null) pacId = request.getParameter("pac_id");

 sql = " select nombre_paciente nombre, id_paciente cedula from vw_adm_paciente Where pac_id="+pacId;

cdo = SQLMgr.getData(sql);
if (cdo == null) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);	
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+request.getParameter("__ct")+".pdf";
		
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
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
	
	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 75.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISIÓN";
	String subtitle = "ASIGNACIÓN DE CAJA DE SEGURIDAD";
	String xtraSubtitle = " ";
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;
	
	String consentimientoGeneral="El Hospital "+_comp.getNombre()+" le ofrece Cajas de Seguridad para que pueda guardar y retirar sus valores sin intervención directa del  personal del Hospital. El Hospital no se hace responsable por objeto de valor que usted decida conservar, tales como anteojos, prótesis bucal, relojes, audífonos, celulares y cualquier objeto de valor.\n\n\n";	
								 
    String nota="Después de 15 días del egreso de los pacientes que no retiran sus valores se procederá a guardar los mismos en la Caja Fuerte de Seguridad del Departamento de Finanzas.";								 
							 	
	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);	
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}
			
	Vector tblImg = new Vector();
	tblImg.addElement("1");
	pc.setNoColumnFixWidth(tblImg);
	pc.createTable();
	
	pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
	pc.addTable();	
	
	Vector dHeader = new Vector();
	    		
	dHeader.addElement(".03");	
	dHeader.addElement(".17");	
	dHeader.addElement(".16");
	dHeader.addElement(".06");		
	dHeader.addElement(".12");		

	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();	  
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
    
    fontSize = 11; 
	
	pc.setFont(fontSize, 1);
	pc.addCols(title, 1, dHeader.size(),20.2f);
	pc.addCols("",1, dHeader.size(),10.2f);
	pc.addCols(subtitle, 1, dHeader.size(),20.2f);
	pc.addCols("", 1, dHeader.size(),10.2f);
			
	pc.setFont(fontSize, 1);
	pc.addCols(consentimientoGeneral,3,dHeader.size());
    pc.setFont(fontSize, 0);
    
    pc.addCols("Yo, "+cdo.getColValue("nombre", "__________________________________________")+" con cédula de identidad personal o pasaporte Nº:\n"+cdo.getColValue("cedula","_____________________")+" he guardado mis valores en la Caja de Seguridad Nº_______________________y entiendo que debo recordar los 5 dígitos de la combinación de la Caja de Seguridad. Para retirar los mismos autorizo a\n\n__________________________________________________________",3,dHeader.size());
    
    pc.addCols(" ",0,dHeader.size());
    pc.addCols("Parentesco: ____________________________________ con teléfono y/ o celular___________________ a retirar los mismos.",3,dHeader.size());
    
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    
    pc.addCols("Firma del Paciente: ______________________________",0, dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols("Firma del Oficial de Admision: ______________________________",0, dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols("Habitación:_________",0, dHeader.size());
    pc.addCols("Fecha:  "+fecha,0,dHeader.size());
    
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    pc.addCols(" ",0,dHeader.size());
    
    pc.setFont(fontSize, 1);
    pc.addCols("NOTA:  "+ nota,3,dHeader.size());
   
	pc.addTable();  
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>