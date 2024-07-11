<%//@ page errorPage="../error.jsp"%>
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
String nombreCompania = _comp.getNombre();

String sql = "";

CommonDataObject cdo = new CommonDataObject();

cdo = SQLMgr.getData("SELECT  COALESCE( DECODE(P.pasaporte,NULL,'',P.pasaporte||'-'||P.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||'-'||P.D_CEDULA)) cedula, c.habitacion, to_char(p.fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, primer_nombre, decode (segundo_nombre, null, '', ' ' || segundo_nombre)|| decode (primer_apellido, null, '', ' ' || primer_apellido)|| decode (segundo_apellido, null, '', ' ' || segundo_apellido)|| decode (sexo, 'F', decode (apellido_de_casada,  null, '', ' DE ' || apellido_de_casada)) apellidos, DECODE(sexo, 'F', 'MUJER', 'M', 'VARÓN', 'SIN ESPECIFICAR') sexo, nvl((select nacionalidad from tbl_sec_pais where codigo = p.nacionalidad), 'SIN ESPECIFICAR') nacionalidad, p.residencia_direccion direccion, (SELECT primer_nombre || ' ' || primer_apellido || decode(segundo_apellido, NULL, '', ' ' || segundo_apellido) medico FROM tbl_adm_medico where codigo = (select medico from tbl_adm_admision where pac_id = "+pacId+" and secuencia = "+noAdmision+")) medico FROM vw_ADM_PACIENTE P, TBL_ADM_CAMA_ADMISION c WHERE P.PAC_ID = "+pacId+" AND C.ADMISION(+) = "+noAdmision+"  AND C.PAC_ID(+) = P.PAC_ID and c.fecha_final is null");

if ( cdo == null ) cdo = new CommonDataObject();
if ( lng == null ) lng = "es";

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

   // PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	
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
	dHeader.addElement(".02");
	dHeader.addElement(".02");
	dHeader.addElement(".96");

	Vector dBullet = new Vector();
	dBullet.addElement(".03");
	dBullet.addElement(".01");
	dBullet.addElement(".96");

	Vector dFooter = new Vector();
	dFooter.addElement(".10");
	dFooter.addElement(".20");
	dFooter.addElement(".20");
	dFooter.addElement(".50");

	String bullet = ResourceBundle.getBundle("path").getString("images")+"/blackball.gif";

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();

	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("tblImg",false,0,0.0f,553f);
	   pc.addCols(" ",0,1);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),50.0f,1);
	   pc.addCols(" ",0,1);
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	//pc.addCols(" ",0,dHeader.size());

			pc.setFont(14,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"DECLARACIÓN DE VOLUNTAD ANTICIPADA":"DECLARACIÓN DE VOLUNTAD ANTICIPADA:",1,dHeader.size());
			pc.addCols(" ",0,dHeader.size());

			pc.setVAlignment(0);

			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"El  infrascrito  "+cdo.getColValue("primer_nombre")+" "+cdo.getColValue("apellidos")+",  de  nacionalidad "+cdo.getColValue("nacionalidad")+",  "+cdo.getColValue("sexo")+",  mayor de edad,  con documento de identificación personal número "+cdo.getColValue("cedula")+", con domicilio en "+cdo.getColValue("direccion")+", por este medio y bajo la gravedad de juramento realizo Declaración Voluntad Anticipada, la cual consta  de las siguientes disposiciones:":"El  infrascrito  "+cdo.getColValue("primer_nombre")+" "+cdo.getColValue("apellidos")+",  de  nacionalidad "+cdo.getColValue("nacionalidad")+",  "+cdo.getColValue("sexo")+",  mayor de edad,  con documento de identificación personal número "+cdo.getColValue("cedula")+", con domicilio en "+cdo.getColValue("direccion")+", por este medio y bajo la gravedad de juramento realizo Declaración Voluntad Anticipada, la cual consta  de las siguientes disposiciones:",0,3);

            pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"PRIMERO:":"PRIMERO:",0,3);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Que he sido ingresado a las instalaciones hospitalarias del "+nombreCompania+", por complicaciones de salud, bajo los cuidados del médico tratante "+cdo.getColValue("medico")+".":"Que he sido ingresado a las instalaciones hospitalarias del "+nombreCompania+", por complicaciones de salud, bajo los cuidados del médico tratante "+cdo.getColValue("medico")+".",0,3);

			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"SEGUNDO:":"SEGUNDO:",0,3);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Que es mi voluntad,  debido al cuadro clínico que presento, que al presentarse alguna situación sobre mi estado de salud que conlleve a un resultado irreversible respecto a mi proceso vital, SOLICITO al Médico Responsable de mi tratamiento y a los colaboradores de este Hospital, no utilizar ninguna técnica o procedimiento manual o mecánico que exceda mi vida de manera artificial o que prolongue un sufrimiento que menoscabe mi dignidad e integridad física y psíquica.":"Que es mi voluntad,  debido al cuadro clínico que presento, que al presentarse alguna situación sobre mi estado de salud que conlleve a un resultado irreversible respecto a mi proceso vital, SOLICITO al Médico Responsable de mi tratamiento y a los colaboradores de este Hospital, no utilizar ninguna técnica o procedimiento manual o mecánico que exceda mi vida de manera artificial o que prolongue un sufrimiento que menoscabe mi dignidad e integridad física y psíquica.",0,3);

			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"TERCERO:":"TERCERO:",0,3);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Por este medio, designo a --------------------------------------, varón/mujer, de nacionalidad ------------------, mayor de edad, con documento de identidad número -------------------------, con domicilio en --------------------------------- para que en caso de pérdida de conocimiento o cualquier menoscabo sufrido que vicie mi consentimiento, sea esta persona la que asuma mi Representación Legal a efectos de dar fiel cumplimiento a mi voluntad anticipada.":"Por este medio, designo a --------------------------------------, varón/mujer, de nacionalidad ------------------, mayor de edad, con documento de identidad número -------------------------, con domicilio en --------------------------------- para que en caso de pérdida de conocimiento o cualquier menoscabo sufrido que vicie mi consentimiento, sea esta persona la que asuma mi Representación Legal a efectos de dar fiel cumplimiento a mi voluntad anticipada.",0,3);

			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"CUARTO:":"CUARTO:",0,3);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"La voluntad aquí expresada ha de ser respetada y cumplida por todo el personal hospitalario médico que esté a cargo de mi tratamiento y en igual sentido lo deberán hacer mis familiares, los cuales no pondrán oposición alguna a la ejecutoria de dicha voluntad.":"La voluntad aquí expresada ha de ser respetada y cumplida por todo el personal hospitalario médico que esté a cargo de mi tratamiento y en igual sentido lo deberán hacer mis familiares, los cuales no pondrán oposición alguna a la ejecutoria de dicha voluntad.",0,3);

			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"QUINTA:":"QUINTA:",0,3);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Declaro que LIBERO de toda responsabilidad penal, médica, civil, administrativa y de cualquier índole al Centro Médico Mae Lewis, médicos y personal de salud encargados de mi tratamiento, personal directivo y administrativo, por lo tanto mi voluntad es que NINGUNO de mis familiares ni particulares interpondrán alguna clase de proceso legal en su contra por el hecho de cumplir con la voluntad que he expresado en este documento.":"Declaro que LIBERO de toda responsabilidad penal, médica, civil, administrativa y de cualquier índole al Centro Médico Mae Lewis, médicos y personal de salud encargados de mi tratamiento, personal directivo y administrativo, por lo tanto mi voluntad es que NINGUNO de mis familiares ni particulares interpondrán alguna clase de proceso legal en su contra por el hecho de cumplir con la voluntad que he expresado en este documento.",0,3);

			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"SEXTO:":"SEXTO:",0,3);
			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"En el evento de que Yo o mi Representante Legal soliciten mi salida y sustracción de los cuidados médicos del Centro Médico Mae Lewis, LIBERO de toda responsabilidad penal, médica, civil, administrativa o similar al Centro Médico Mae Lewis en toda su extensión, para efectos de reclamaciones legales.":"En el evento de que Yo o mi Representante Legal soliciten mi salida y sustracción de los cuidados médicos del Centro Médico Mae Lewis, LIBERO de toda responsabilidad penal, médica, civil, administrativa o similar al Centro Médico Mae Lewis en toda su extensión, para efectos de reclamaciones legales.",0,3);

			pc.setFont(11,1);
			pc.addCols(lng.equalsIgnoreCase("es")?"FUNDAMENTO LEGAL:":"FUNDAMENTO LEGAL:",0,3);
			pc.setFont(11,2);
			pc.addCols(lng.equalsIgnoreCase("es")?"Ley 68 de 20 de noviembre de 2003 que regula los Derechos y Obligaciones de los pacientes en materia de información y de decisión libre e informada.":"Ley 68 de 20 de noviembre de 2003 que regula los Derechos y Obligaciones de los pacientes en materia de información y de decisión libre e informada.",0,3);

            pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"Para constancia firmo este documento ante los testigos instrumentales que suscriben, hoy -------- de ------------- de ---------, en el Centro Médico Mae Lewis.":"Para constancia firmo este documento ante los testigos instrumentales que suscriben, hoy -------- de ------------- de ---------, en el Centro Médico Mae Lewis.",0,3);

            pc.setFont(30,0);
			pc.addCols(" ",0,dHeader.size());

			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"          --------------------------------------                                                                  -----------------------------------------":"          --------------------------------------                                                                  -----------------------------------------",0,dHeader.size());
			pc.addCols(lng.equalsIgnoreCase("es")?"                  EL DECLARANTE                                                                       REPRESENTANTE DESIGNADO":"                  EL DECLARANTE                                                                       REPRESENTANTE DESIGNADO",0,dHeader.size());

            pc.setFont(32,0);
			pc.addCols(" ",0,dHeader.size());

			pc.setFont(11,0);
			pc.addCols(lng.equalsIgnoreCase("es")?"   -----------------------------------                           -----------------------------------                      -----------------------------------":"   -----------------------------------                           -----------------------------------                      -----------------------------------",0,dHeader.size());
			pc.addCols(lng.equalsIgnoreCase("es")?"                TESTIGO                                                     TESTIGO                                                 TESTIGO":"                TESTIGO                                                     TESTIGO                                                 TESTIGO",0,dHeader.size());

            pc.setFont(20,0);
			pc.addCols(" ",0,dHeader.size());

			pc.setFont(11,2);
			pc.addCols(lng.equalsIgnoreCase("es")?"             Documento elaborado y refrendado por el Licenciado Jilmer José González Carrera, abogado en":"             Documento elaborado y refrendado por el Licenciado Jilmer José González Carrera, abogado en",0,dHeader.size());
			pc.addCols(lng.equalsIgnoreCase("es")?"                                            ejercicio, con cédula 4-736-1781 e Idoneidad 27166":"                                            ejercicio, con cédula 4-736-1781 e Idoneidad 27166",0,dHeader.size());

	pc.setNoColumnFixWidth(dFooter);
			pc.createTable("footer",false,0,0.0f,550);

	        pc.useTable("main");
			pc.addTableToCols("footer",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

	pc.addTable();
if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);} 
//}
%>