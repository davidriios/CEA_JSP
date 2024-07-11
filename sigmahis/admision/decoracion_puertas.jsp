<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
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

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

String decoracionPuertaCargosIncomplimento = "";
try{decoracionPuertaCargosIncomplimento=ResourceBundle.getBundle("issi").getString("decoracionPuertaCargosIncomplimento=");}catch(Exception e){decoracionPuertaCargosIncomplimento="50.00";}

CommonDataObject cdo = new CommonDataObject();

cdo = SQLMgr.getData("select  coalesce( decode(p.pasaporte,null,'',p.pasaporte||'-'||p.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||'-'||P.D_CEDULA)) cedula, p.nombre_paciente AS nombrePaciente from vw_adm_paciente p where P.PAC_ID = "+pacId);

if ( cdo == null ) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";

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
	float leftRightMargin = 30.0f; //9.0f
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONSENTIMIENTO";
	String subTitle = "DEBERES Y DERECHOS";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 90.0f;

    //PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}

	Vector tblImg = new Vector();
	tblImg.addElement(".20");
	tblImg.addElement(".60");
	tblImg.addElement(".20");

	Vector dHeader = new Vector();
	dHeader.addElement(".10");
	dHeader.addElement(".16");
	dHeader.addElement(".07");
	dHeader.addElement(".15");
	dHeader.addElement(".52");

	Vector dCenterFooter = new Vector();
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".07");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".03");

	String img_proc_decor = ResourceBundle.getBundle("path").getString("images")+"/proc_decor.png";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("tblImg",false,0,0.0f,553f);
	   pc.addCols(" ",0,1);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
	   pc.addCols(" ",0,1);
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.addCols(" ",1,dHeader.size());

	pc.setFont(10,1);
	pc.addCols("PROCEDIMIENTO PARA LA DECORACION DE LAS PUERTAS\nDE LAS HABITACIONES DEL HOSPITAL "+_comp.getNombre()+".",1,dHeader.size());

	pc.setFont(10,0);

	pc.addCols(" ",1,dHeader.size());

	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("img_proc_decor",false,0,0.0f,0);
	   pc.addCols(" ",0,1);
	   pc.addImageCols(img_proc_decor,0,1);
	   pc.addCols(" ",0,1);
	pc.useTable("main");
	pc.addTableToCols("img_proc_decor",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.addCols("Estimada (s)  Paciente (s)",0,dHeader.size(), 20f);
	pc.addCols(" ",1,dHeader.size());

	pc.addCols("El Hospital "+_comp.getNombre()+", se une a la  celebración del nacimiento de su bebé.\n Somos conocedores de que este gran acontecimiento conlleva festejos y decoraciones de la habitación hospitalaria; Es por ello, que  a través  de este formulario, deseamos orientarle por su seguridad, sobre las normas establecidas para la decoración  de la puerta de su habitación (si usted decide decorarla).",3,dHeader.size());

	pc.addCols(" ",1,dHeader.size());
	pc.setFont(10,1);
	pc.addCols("DECORACION DE LA PUERTA DE SU HABITACION:",0,dHeader.size());

	pc.setFont(10,0);
	pc.addCols("1. Las medidas de las puertas de las habitaciones del Hospital "+_comp.getNombre()+" son: ( Ver dibujo 1)",0,dHeader.size());
	pc.setFont(10,1);
	pc.addCols("     83 5/8",1,1);
	pc.setFont(10,0);
	pc.addCols("pulgadas de Alto x",0,1);
	pc.setFont(10,1);
	pc.addCols("461/2",1,1);
	pc.setFont(10,0);
	pc.addCols("pulgadas de Ancho (usted debe restar 10 pulgadas de ancho considerando",0,2);
	pc.addCols("       que la cerradura toma espacio)",0,dHeader.size());

	pc.addCols(" ",1,dHeader.size());

	pc.setNoColumnFixWidth(dCenterFooter);
	pc.createTable("tblCenter",false,0,0.0f,553f);
	pc.setFont(10,4);
	  pc.addCols("2. Las decoraciones deben colocarse con:",0,4);
      pc.addCols(" ",0,7);

	  pc.setFont(10,0);
	  pc.addCols("a. Un gancho de puerta (como los utilizados para guindar  coronas navideñas) (Ver dibujo 2)\nb. Con cintas fuertes o soga, acompañados de una cornisa donde usted puede guindar el papel o la tela\nutilizada para decorar (Ver dibujo 3)",0,dCenterFooter.size());
	  pc.addCols(" ",1,dCenterFooter.size());

	  pc.addCols("3. Las decoraciones deben ser pegadas al papel o cocidas a la tela directamente.\n4. Las decoraciones que conlleven el uso de goma, cintas adhesivas, tornillos, clips, tachuelas u otros materiales que\nse utilicen de manera directa a la puerta de su habitación no serán permitidas, le solicitamos su colaboración para\npreservar las mismas.\n5. La paciente deberá dar un abono de B/."+decoracionPuertaCargosIncomplimento+" para la decoración de su (s) puerta(s) al momento de admitirse.\n6. Si se incumple con este procedimiento detallado se le adicionará este cargo a su cuenta de\n$ "+decoracionPuertaCargosIncomplimento+" balboas y si cumplió con el procedimiento se le reembolsará a su cuenta. Un personal de Relaciones Públicas con mucho gusto le asesorará al momento de la instalación de la decoración, si usted así lo desea. Por favor marque el "+_comp.getTelefono()+". ",0,dCenterFooter.size());

	  pc.addCols(" ",0,dCenterFooter.size());
	  pc.addCols(" ",0,dCenterFooter.size());
	  pc.addCols("Recibido:",0,dCenterFooter.size());
	  pc.addCols("",1,dCenterFooter.size());
	  pc.addCols(" ",1,dCenterFooter.size());

	  pc.addCols("Nombre: ",0,1);
	  pc.addBorderCols(""+cdo.getColValue("nombrePaciente"),0,5,0.1f,0.0f,0.0f,0.0f);
	  pc.addCols(" ",0,1);
	  pc.addCols("Fecha: ",0,1);
	  pc.addBorderCols(" ",0,3,0.1f,0.0f,0.0f,0.0f);

	pc.useTable("main");
	pc.addTableToCols("tblCenter",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
	
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>