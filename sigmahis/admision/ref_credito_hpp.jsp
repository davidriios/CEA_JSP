<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
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

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String compania = (String) session.getAttribute("_companyId");
String lng = request.getParameter("lng");

String sql = "";

CommonDataObject cdo = new CommonDataObject();

cdo = SQLMgr.getData("SELECT  COALESCE( DECODE(P.pasaporte,NULL,'',P.pasaporte||'-'||P.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||'-'||P.D_CEDULA)) cedula, P.nombre_paciente AS nombrePaciente FROM vw_ADM_PACIENTE P WHERE P.PAC_ID = "+pacId+"");

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
	float leftRightMargin = 45.0f; //9.0f
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
	dHeader.addElement(".20");
	dHeader.addElement(".50");
	dHeader.addElement(".30");

	Vector dCenterFooter = new Vector();
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".15");
	dCenterFooter.addElement(".12");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".12");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".02");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".10");
	dCenterFooter.addElement(".02");

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("tblImg",false,0,0.0f,522f);
	   pc.addCols(" ",0,1);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),80.0f,1);
	   pc.addCols(" ",0,1);
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.addCols(" ",1,dHeader.size());

	pc.setFont(10,2);
	pc.addCols("Rep. de Panamá __________ de ___________________ de ____________",0,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("",1,dHeader.size());

	pc.setFont(10,3);
	pc.addCols("Señores",0,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("HOSPITAL "+_comp.getNombre()+"\nCiudad.-",0,dHeader.size());

	pc.setFont(10,2);
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("Estimados Señores",0,dHeader.size());

	pc.setNoColumnFixWidth(dCenterFooter);
	pc.createTable("dCenterFooter",false,0,0.0f,522f);

	pc.addCols(" ",1,dCenterFooter.size());
	pc.addCols("",1,dCenterFooter.size());
	pc.addCols("Por   este   medio   Yo, "+cdo.getColValue("nombrePaciente")+" con cédula de identidad personal número "+cdo.getColValue("cedula")+" autorizo expresamente al HOSPITAL "+_comp.getNombre()+" para que, de conformidad con lo expresado en el artículo 24 y demás disposiciones aplicables de la Ley 24 de 22 de mayo de 2002, consulte, suministre o intercambie información con bancos, agencias de información o agentes económicos de la localidad o del exterior, relacionada con mi historial de crédito y relaciones con acreedores.",3,dCenterFooter.size());

	pc.addCols(" ",0,dCenterFooter.size());
	pc.setFont(10,2);
	pc.addCols("Asimismo, HOSPITAL "+_comp.getNombre()+" también queda facultado, de conformidad con lo estipulado por el numeral 4 del artículo 23 de la Ley 24 de 22 de mayo de 2002, para recopilar y/o transmitir cualesquiera datos sobre mi historial de crédito y relaciones con mis acreedores, a cualesquiera agencias de información de datos, bancos o agentes económicos de la localidad o del exterior, así como para que solicite y obtenga información y documentos relacionados con mi persona, ya sea de oficinas o funcionarios gubernamentales o personas o empresas privadas, tanto nacionales como extranjeras.",3,dCenterFooter.size());

	pc.addCols(" ",0,dCenterFooter.size());

	pc.setFont(10,2);
	pc.addCols("Por este medio exonero expresamente a "+_comp.getNombre()+" así como a sus compañías afiliadas, subsidiarias, empleados, ejecutivos, directores, dignatarios o apoderados, de cualquier consecuencia o responsabilidad resultante del ejercicio que el haga del derecho a solicitar o suministrar información, o por razón de cualesquiera autorizaciones contenidas en la presente carta.\n\n\nEsta autorización se mantendrá vigente para que el HOSPITAL "+_comp.getNombre()+", S.A.  ejerza tantas veces como sea necesario, durante todo el tiempo que mantenga cualquier tipo de relación bancaria con el.",3,dCenterFooter.size());

	pc.addCols(" ",0,dCenterFooter.size());
	pc.addCols(" ",0,dCenterFooter.size());

	pc.addCols("Atentamente,\n"+cdo.getColValue("nombrePaciente"),3,dCenterFooter.size());

	pc.addCols("",0,dCenterFooter.size());
	pc.addCols(" ",0,dCenterFooter.size());

	pc.setFont(9,0);
	pc.addCols(" ",0,4);
	pc.addBorderCols(cdo.getColValue("cedula"),0,4,0.1f,0.0f,0.0f,0.0f);
	pc.addCols(" ",0,3);
	pc.addCols(" ",0,4);
	pc.addCols("Cédula N°",0,4);
	pc.addCols(" ",0,3);

	pc.useTable("main");
	pc.addTableToCols("dCenterFooter",1,dCenterFooter.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);


	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}
%>