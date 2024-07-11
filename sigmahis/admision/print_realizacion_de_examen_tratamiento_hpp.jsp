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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
String sql = "";
String cDateTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String userName = UserDet.getUserName();

String compania = (String) session.getAttribute("_companyId");

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

sql = " select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) nombre, coalesce(pasaporte,provincia||'-' ||sigla||'-' ||tomo||'-' ||asiento) cedula from tbl_adm_paciente Where pac_id="+pacId;

cdo = SQLMgr.getData(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
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
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;	
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "";
	String subtitle = "ADMISION\nCONSENTIMIENTO PARA LA REALIZACION DE EXAMEN";
	String xtraSubtitle = "Y/O TRATAMIENTO "; 
	
	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;						 
							 
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
	dHeader.addElement(".07");	
	dHeader.addElement(".20");	
	dHeader.addElement(".16");
	dHeader.addElement(".04");		
	dHeader.addElement(".12");		
	dHeader.addElement(".14");		
	dHeader.addElement(".03");	  	
			
	pc.setNoColumnFixWidth(dHeader);  
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
		
	pc.setFont(11, 1);
	pc.addCols(subtitle, 1, dHeader.size());
	pc.addCols(xtraSubtitle, 1, dHeader.size(),20.2f);
	
	pc.setFont(11, 0);		
	
	pc.addCols("Fecha:",1,0);
	pc.addBorderCols(fecha,0,1,0.5f,0.0f,0.0f,0.0f);
	pc.addCols("",0,2);
	pc.addCols("hora:",2,1);
	pc.addBorderCols(cDateTime,0,1,0.5f,0.0f,0.0f,0.0f);
	pc.addCols("",0,1);
	pc.addCols("",0,7);	
	
	pc.addCols("1. Por éste medio autorizo expresamente a el/la Dr.(a)__________________________________________ Y a cualquiera que el/ella asigne como sus asociados y/o asistentes, para practicar el/los siguiente(s) examen(es) y/o procedimiento(s): ",3,dHeader.size());
	
	pc.addCols("  ",3,dHeader.size());  
	pc.addCols("  ",3,dHeader.size());  
	
	pc.addCols("2. Notifico que se ha explicado y/o a mis familiares acerca de el(los) examen(es) y/o procedimiento (s) y de los riesgos involucrados y la posibilidad de complicaciones",3,dHeader.size());
	
	pc.addCols("  ",3,dHeader.size()); 
	pc.addCols("3. Si surgiera en el curso de el(los) exame(es) y/o procedimiento(s), o posterior a ellos, cualquier condición o complicación que a su jucio requiera intervención,  procedimientos o tratamientos diferentes a los antes consignados, solicito y autorizo expresamente a dicho facultativo, a sus asistentes y/o asociados  para hacer lo que estime más conviniente.",3,dHeader.size());
	
	pc.addCols("  ",3,dHeader.size()); 
	pc.addCols("4. Doy mi consentimiento para la administración de medicamentos excepto:",3,dHeader.size());
	pc.addCols("  ",3,dHeader.size()); 
	pc.addCols("por el facultivo arriba mencionado.",3,dHeader.size());
	
	pc.addCols("  ",3,dHeader.size(),50f);
	
	
	pc.addBorderCols(" Firma del paciente y/o Familiar",0,2,0.0f,0.5f,0.0f,0.0f);
	pc.addCols("",0,3);
	pc.addBorderCols("Firma del Testigos",0,2,0.0f,0.5f,0.0f,0.0f);
	
	pc.addCols("",0,7);			
	pc.addCols("",0,7);	  		
	pc.addCols("Cuando el paciente no puede firmar o si es menor de edad, completar lo siguiente. Paciente es menor de edad, tiene_______años, o no puede firmar por:\n\n\n",0,dHeader.size()); 
	
	pc.addBorderCols(" ",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);
	pc.addCols("",0,dHeader.size(),30f);

	pc.addBorderCols("Firma del padre o de la persona autorizada / Firma en nombre del paciente",0,dHeader.size(),0.0f,0.5f,0.0f,0.0f);

	pc.addTable();  
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}   
//}
%>