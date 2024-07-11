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
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

String compania = (String) session.getAttribute("_companyId");

//--------------Query para obtener datos del Paciente ----------------------------------------//
sql = " select nombre_paciente nombrePaciente, decode(p.tipo_id_paciente, 'P',p.pasaporte,p.provincia||'-' ||p.sigla||'-' ||p.tomo||'-' ||p.asiento) cedula, getHabitacion("+compania+","+pacId+","+noAdmision+") as habitacion, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(sysdate,'Day dd \"de\" Month \"de\" yyyy','nls_date_language=spanish') as lat_date ,(select primer_nombre ||' '||primer_apellido from tbl_adm_medico where codigo = a.medico) as nombremedico, pa.nacionalidad, p.residencia_direccion, to_char(sysdate, 'dd \"de\" MONTH\" de\" yyyy', 'nls_date_language=Spanish') as dsp_date from vw_adm_paciente p, tbl_adm_admision a, tbl_sec_pais pa Where p.pac_id="+pacId+" and p.pac_id = a.pac_id and pa.codigo(+) = p.nacionalidad and a.secuencia = "+noAdmision;

cdo = SQLMgr.getData(sql);
//al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
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

	float width = 72* 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 50.0f;//30.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = " ADMISIÓN";
	String subTitle = "CONTRATO DE ARRENDAMIENTO DE INSTALACIONES Y EQUIPO";
	String xtraSubtitle = "";

	boolean displayPageNo = false;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 12;
	float cHeight = 90.0f;
	
	
	//------------------------------------------------------------------------------------

	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}


//control imgae

		Vector tblImg = new Vector();
		tblImg.addElement("1");
		pc.setNoColumnFixWidth(tblImg);
		pc.createTable();

		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
		pc.addTable();

		Vector dHeader = new Vector();
		dHeader.addElement("0.13");
		dHeader.addElement("0.15");
		dHeader.addElement("0.15");
		dHeader.addElement("0.10");
		dHeader.addElement("0.07");
		dHeader.addElement("0.05");
		dHeader.addElement("0.10");
		dHeader.addElement("0.05");
		dHeader.addElement("0.10");
		dHeader.addElement("0.10");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		pc.setFont(10, 1);

		pc.addCols(title, 1, dHeader.size(),15.2f);
		pc.addCols(subTitle, 1, dHeader.size());
		pc.addCols(xtraSubtitle, 1, dHeader.size());
		pc.addCols("", 1, dHeader.size(), 10.2f);

        pc.setVAlignment(0);
		
		pc.addCols("\n", 1, dHeader.size());
		pc.setFont(10, 0);
	
		pc.addCols("Los que suscriben a saber Doctor(a) _______________________________________________, panameño (a), mayor de edad, con cédula de identidad personal No. ____________________ actuando en nombre y representación legal de la sociedad jurídica "+_comp.getNombre()+", inscrita en el Registro Público a la Ficha 178793, Rollo 19613, Imagen 0181, de la Sección de Micropelículas Mercantiles, quien en adelante se denominará EL HOSPITAL por una parte, y por la otra el (la) señor(a) "+cdo.getColValue("nombrePaciente")+", ____________________________________________ (Representante)*, de nacionalidad "+(cdo.getColValue("nacionalidad")!=null && !cdo.getColValue("nacionalidad").equals("")?cdo.getColValue("nacionalidad"):" _____________________")+", mayor de edad, con cédula de identidad personal o pasaporte No. "+cdo.getColValue("cedula")+", domiciliado o residente en "+cdo.getColValue("residencia_direccion")+" quien en adelante se conocerá como EL (LA) PACIENTE, acuerdan celebrar el presente contrato de acuerdo a las siguientes cláusulas:", 3, dHeader.size());
		
		pc.addCols("\n", 1, dHeader.size());
		
		pc.setFont(10, 1);
		pc.addCols("PRIMERA:",3,1);
		
		pc.setFont(10, 0);
		pc.addCols("Declara EL (LA) PACIENTE que requiere los servicios que brinda EL HOSPITAL por recomendación de su médico tratante con quien mantiene contrato de servicios profesionales, o por su propia decisión así puesta de manifiesta a aquel.",3, dHeader.size()-1);
		
		pc.addCols("En base a lo anterior, ambas partes reconocen que EL HOSPITAL no tiene ninguna otra relación con el contrato de servicios profesionales que mantiene EL (LA) PACIENTE con su médico tratante, que no sea la de fungir como agente retensor de los honorarios que deba recibir el galeno o cualquier otro integrante de su equipo profesional de apoyo, en el caso que así sea solicitado expresamente por estos. EL ESTABLECIMIENTO DE ESTOS HONORARIOS PROFESIONALES DEBEN SER ACORDADOS ENTRE EL PACIENTE Y EL MÉDICO TRATANTE, PREFERIBLEMENTE ANTES DE RECIBIR CUALQUIER ATENCIÓN MÉDICA.",3, dHeader.size());
		
		pc.addCols("", 1, dHeader.size());
		
		pc.setFont(10, 1);
		pc.addCols("SEGUNDA:",3,1);
		
		pc.setFont(10, 0);
		pc.addCols("EL (LA) PACIENTE acepta todas las condiciones previas y posteriores que establezcan las leyes e imponga EL HOSPITAL para proceder a su Hospitalización y/o uso de las instalaciones, equipos e insumos que por prescripción de su médico tratante se requiera en un procedimiento quirúrgico o cualquier otro procedimiento médico hospitalario.",3, dHeader.size()-1);
		
		pc.addCols("", 1, dHeader.size());
		
		pc.setFont(10, 1);
		pc.addCols("TERCERA:",3,1);
		
		pc.setFont(10, 0);
		pc.addCols("EL HOSPITAL se obliga a poner a disposición del médico tratante de EL (LA) PACIENTE las instalaciones, equipo e insumos que éste requiera para la atención a dispensar, los cuales deben estar en óptimas condiciones de funcionamiento y eficacia.",3, dHeader.size()-1);
		
		pc.addCols("", 1, dHeader.size());
		pc.setFont(10, 1);
		pc.addCols("CUARTA:",3,1);
		pc.setFont(10, 0);
		pc.addCols("Declaran las partes que EL HOSPITAL no se hace responsable por las actuaciones profesionales del médico tratante, así mismo como tampoco del equipo humano que éste utilice como personal de apoyo en los actos quirúrgicos o en cualquier otro procedimiento médico hospitalario que realicen éstos a EL (LA) PACIENTE en las instalaciones de EL HOSPITAL por tratarse de personal no subordinado jurídicamente a sus condiciones laborales.",3, dHeader.size()-1);
		
		pc.addCols("", 1, dHeader.size());
		pc.setFont(10, 1);
		pc.addCols("QUINTA:",3,1);
		pc.setFont(10, 0);
		pc.addCols("EL (LA) PACIENTE, quien lo (a) represente o se haga cargo, se declara totalmente responsable de todos los gastos por la utilización de las instalaciones, equipo, insumos, servicios hospitalarios, así como de cualquier otro gasto que se produzca por o con ocasión de la atención médica que reciba en su condición de paciente por parte de su médico tratante y demás personal de apoyo, así como también de sumas resultantes de daños intencionales o producidos por mal uso.",3, dHeader.size()-1);
		
		pc.addCols("", 1, dHeader.size());
		pc.setFont(10, 1);
		pc.addCols("SEXTA:",3,1);
		pc.setFont(10, 0);
		pc.addCols("EL (LA) PACIENTE o la persona que lo (a) represente o se haga cargo, se obliga a efectuar el pago de las sumas adeudadas, que se determinen como consecuencia del presente contrato a requerimiento formal por parte de EL HOSPITAL, lo cual constará en documentos negociables que determinarán el vencimiento del plazo de toda la deuda y dará derecho a EL HOSPITAL a exigir su pago inmediato.",3, dHeader.size()-1);
		
		pc.addCols("", 1, dHeader.size());
		pc.setFont(10, 1);
		pc.addCols("SÉPTIMA:",3,1);
		pc.setFont(10, 0);
		pc.addCols("De tener EL HOSPITAL que proceder judicialmente, declara EL (LA) PACIENTE, o la persona que lo represente o se haya hecho cargo de la obligación, que renuncia a la presentación del pago del documento negociable, al protesto, al aviso que los trámites del Juicio Ejecutivo y conviene pagar, además, los gastos judiciales en caso de cobros por dicha vía.",3, dHeader.size()-1);
	
		pc.addCols("\n\nEn reconocimiento y aceptación, firmamos hoy "+cdo.getColValue("dsp_date")+".", 1, dHeader.size());
		
		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("\n", 1, dHeader.size());
		
		pc.addCols(" ",1,4);
		pc.addCols(" ",1,2);
		pc.addCols(" "/*cdo.getColValue("nombrePaciente")*/,1,4);
		
		
		pc.addBorderCols("EL HOSPITAL",1,4,0.0f,0.5f,0.0f,0.0f);
		pc.addCols(" ",1,2);
		pc.addBorderCols("EL PACIENTE/RESPONSABLE",1,4,0.0f,0.5f,0.0f,0.0f);

		pc.addCols("\n", 1, dHeader.size());
		pc.addCols("Cédula No.",0,1);
		pc.addBorderCols("",0,3,0.5f,0.0f,0.0f,0.0f);
		pc.addCols(" ",1,2);
		pc.addCols("Cédula No.",0,1);
		pc.addBorderCols(""/*cdo.getColValue("cedula")*/,0,3,0.5f,0.0f,0.0f,0.0f);
		
		

	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}  
//}
%>