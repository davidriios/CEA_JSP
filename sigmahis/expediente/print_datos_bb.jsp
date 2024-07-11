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
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
==================================================================================
==================================================================================
**/
response.setCharacterEncoding("UTF-8");

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
StringBuffer sbSql = new StringBuffer();
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();

String dobMadre        = request.getParameter("dobMadre");
String codMadre        = request.getParameter("codMadre");
String noAdmisionMadre = request.getParameter("noAdmisionMadre");
String pacId 		   = request.getParameter("pacId");

if ( dobMadre == null )        dobMadre        = "";
if ( codMadre == null )        codMadre        = "";
if ( noAdmisionMadre == null ) noAdmisionMadre = "";
if ( pacId == null )		   pacId = "";

cdoPacData = SQLMgr.getPacData(pacId,noAdmisionMadre);

if ( dobMadre.equals("") || codMadre.equals("") || noAdmisionMadre.equals("") || pacId.equals("") ) throw new Exception("Fecha de nacimiento, código, id y el número de la admisión de la madre son obligatorios!");

sbSql.append("SELECT a.secuencia, A.nombre_bb, A.NOMBRE_MADRE, A.NOMBRE_PADRE, TO_CHAR(A.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento, TO_CHAR(A. hora_nacimiento,'hh12:mi am') hora_nacimiento, TO_CHAR(DECODE(A.edad_madre, NULL,TRUNC(MONTHS_BETWEEN(SYSDATE,'24/11/1986')/12), A.edad_madre)) edad, a.edad_padre ,TO_CHAR(A.sexo) sexo, TO_CHAR(A.peso_lb) peso_lb, TO_CHAR(A.peso_onz) peso_onz, TO_CHAR(A.semanas_gestacion) semanas_gestacion, decode( A.vivo_sano,'V','VIVO Y SANO','F','VIVO Y FALLECIO','B','VIVO Y EN OBSERVACION','R','SE REANIMO','O','OBITO') vivo_sano,  A.presentacion,  TO_CHAR(A.talla) talla, A.liquido_amniotico,  TO_CHAR(A.apgar1) apgar1 ,  A.pediatra, b.primer_nombre||DECODE(b.segundo_nombre,NULL,' ',' '||b.segundo_nombre)||''||b.primer_apellido||DECODE(b.segundo_apellido,NULL,' ',' '||b.segundo_apellido)||DECODE(b.sexo,'F',DECODE(b.apellido_de_casada,NULL,' ',' '||b.apellido_de_casada)) AS pediatraNombre, TO_CHAR(A.apgar5) apgar5, A.medicamentos, A.observacion, A.observacion_mama, A.diagnostico_bb diagnostico, a.diagnostico_mama, A.usuario_crea, TO_CHAR(A.fecha_crea,'dd/mm/yyyy hh12:mi:ss am')fecha_crea,  A.usuario_mod, TO_CHAR(A.fecha_mod,'dd/mm/yyyy hh12:mi:ss am') fecha_mod, decode(A.tipo_parto,'P','PARTO','C','CESAREA','NO SELECCIONADO') tipo_parto,  A.ginecologo ginecologo,  decode(A.fiebre,'S','SI','N','NO','NO SELECCIONADO') fiebre, TO_CHAR(A.valor_fiebre) valor_fiebre,  TO_CHAR(A.G) G,  TO_CHAR(A.P) P, TO_CHAR(A.c) C, TO_CHAR(A.A) A, c.primer_nombre||DECODE(c.segundo_nombre,NULL,' ',' '||c.segundo_nombre)||' '||c.primer_apellido||DECODE(c.segundo_apellido,NULL,' ',' '||c.segundo_apellido)||DECODE(c.sexo,'F',DECODE(c.apellido_de_casada,NULL,' ',' '||c.apellido_de_casada)) nombreGinecologo,  A.DIR_PADRE DIR_PADRE, decode(a.sin_datos,'S','SI','N','NO') sin_datos, a.tel_padre tel_padre FROM TBL_ADM_NEONATO A,TBL_ADM_MEDICO b, TBL_ADM_MEDICO c  WHERE TRUNC(fnac_madre) =  TO_DATE('");
sbSql.append(dobMadre);
sbSql.append("','dd/mm/yyyy') AND codpac_madre = ");
sbSql.append(codMadre);
sbSql.append(" AND admsec_madre = ");
sbSql.append(noAdmisionMadre);
sbSql.append(" and A.ginecologo = c.codigo(+) AND A.pediatra = b.codigo");
sbSql.append(" order by a.secuencia");


al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{

 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String cTime = fecha.substring(11, 22);
	String cDate = fecha.substring(0,11);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

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
	float height = 72 * 11f;//792
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
	String subTitle = "DATOS DEL BEBE";
	String xtraSubtitle = ""; //"DEL "+fechaini+" AL "+fechafin;

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
PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);


		Vector dHeader = new Vector();
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");
		dHeader.addElement("10");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if ( al.size() == 0 ){
			pc.setFont(8,1);
			pc.addCols(".::No hemos encontrados datos::.",1,dHeader.size());
		}else{

			for ( int i = 0; i<al.size(); i++ ){

					cdo = (CommonDataObject) al.get(i);

							pc.setVAlignment(1);
							pc.setFont(8,1,Color.white);
							pc.addCols("DATOS DEL BEBE", 0, dHeader.size(),15f,Color.lightGray);
							pc.addCols("", 0, dHeader.size());

							pc.setFont(8,1);
							pc.addCols("Nombre del bebé: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("nombre_bb"), 0,(dHeader.size()-2));

							pc.setFont(8,1);
							pc.addCols("Fecha de Nacimiento: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("fecha_nacimiento"), 0,1);
							pc.setFont(8,1);
							pc.addCols("Hora de Nacimiento: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("hora_nacimiento"), 0,1);
							pc.setFont(8,1);
							pc.addCols("Sexo: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("sexo"), 0,2);

							pc.setFont(8,1);
							pc.addCols("Peso: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("peso_lb")+" lbs   "+cdo.getColValue("peso_onz")+" Onz", 0,1);
							pc.setFont(8,1);
							pc.addCols("Semana de gestación: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("semanas_gestacion"), 0,1);
							pc.setFont(8,1);
							pc.addCols("Nació: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("vivo_sano"), 0,2);

							pc.setFont(8,1);
							pc.addCols("Presentación: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("presentacion"), 0,2);
							pc.setFont(8,1);
							pc.addCols("Talla: ", 2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("talla")+" Cms", 0,2);
							pc.setFont(8,1);
							pc.addCols("Valoración: ", 0,2);

							pc.setFont(8,1);
							pc.addCols("Líquido Amniótico: ",2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("liquido_amniotico"), 0,6);
							pc.setFont(8,1);
							pc.addCols("Apgar1: ",1,1);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("apgar1"),0,1);

							pc.setFont(8,1);
							pc.addCols("Pediatra: ",2,2);
							pc.setFont(8,0);
							pc.addCols("[ "+cdo.getColValue("pediatra")+" ] "+cdo.getColValue("pediatraNombre"), 0,6);
							pc.setFont(8,1);
							pc.addCols("Apgar5: ",1,1);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("apgar5"),0,1);

							pc.setFont(8,1);
							pc.addCols("Medicamentos: ",2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("medicamentos"),0,(dHeader.size()-2));

							pc.setFont(8,1);
							pc.addCols("Diagnósticos: ",2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("diagnostico"),0,(dHeader.size()-2));

							pc.setFont(8,1);
							pc.addCols("Observación: ",2,2);
							pc.setFont(8,0);
							pc.addCols(""+cdo.getColValue("observacion"),0,(dHeader.size()-2));

							pc.addCols(" ", 0, dHeader.size());

							//Datos de la madre
							pc.setVAlignment(1);
							pc.setFont(8,1,Color.white);
							pc.addCols("DATOS DE LA MAMA", 0, dHeader.size(),15f,Color.lightGray);
							pc.addCols("", 0, dHeader.size());

							     pc.setFont(8,1);
							     pc.addCols("Nombre: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols("[ "+pacId+"-"+noAdmisionMadre+" ] "+cdo.getColValue("nombre_madre"), 0,(dHeader.size()-2));

								 pc.setFont(8,1);
							     pc.addCols("Edad: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("edad")+" Años", 0,1);
								 pc.setFont(8,1);
							     pc.addCols("G(Embarazo): ", 2,1);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("g"), 0,1);
								 pc.setFont(8,1);
							     pc.addCols("P(Parto): ", 2,1);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("p"), 0,1);
								 pc.setFont(8,1);
							     pc.addCols("C(Cesárea): ", 2,1);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("c"), 0,1);
								 pc.setFont(8,1);
							     pc.addCols("A(Aborto): "+cdo.getColValue("a"), 2,1);

								 pc.setFont(8,1);
							     pc.addCols("Ginecólogo: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols((cdo.getColValue("ginecologo")==null || cdo.getColValue("ginecologo").equals("")?"":"[ "+cdo.getColValue("ginecologo")+" ] ")+cdo.getColValue("nombreginecologo"), 0,dHeader.size()-2);

								 pc.setFont(8,1);
							     pc.addCols("Diagnóstico: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("diagnostico_mama"), 0,dHeader.size()-2);

								 pc.setFont(8,1);
							     pc.addCols("Fiebre: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("fiebre"), 0,2);
								 pc.setFont(8,1);
							     pc.addCols((cdo.getColValue("fiebre").equals("SI")?"Valor: ":""
								 ), 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("valor_fiebre"), 0,4);

								 pc.setFont(8,1);
							     pc.addCols("Tipo parto: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("tipo_parto"), 0,2);
								 pc.setFont(8,1);
							     pc.addCols("Observación: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("observacion_mama"), 0,4);

						//datos del viejo
							     pc.addCols(" ", 0, dHeader.size());

								 pc.setFont(8,1,Color.white);
							     pc.setVAlignment(1);
								 pc.addCols("DATOS DEL PADRE", 0, dHeader.size(),15f,Color.lightGray);
							     pc.addCols("", 0, dHeader.size());

							     pc.setFont(8,1);
							     pc.addCols("Se dieron los datos del Padre?: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("sin_datos"), 0,(dHeader.size()-2));

								 pc.setFont(8,1);
							     pc.addCols("Nombre: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("nombre_padre"), 0,(dHeader.size()-2));

								 pc.setFont(8,1);
							     pc.addCols("Dirección: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("dir_padre"), 0,(dHeader.size()-2));

								 pc.setFont(8,1);
							     pc.addCols("Edad: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("edad_padre")+(cdo.getColValue("edad_padre")==null || cdo.getColValue("edad_padre").equals("")?"":" Años"), 0,(dHeader.size()-2));

								 pc.setFont(8,1);
							     pc.addCols("Teléfono: ", 2,2);
						         pc.setFont(8,0);
							     pc.addCols(""+cdo.getColValue("tel_padre"), 0,(dHeader.size()-2));

							pc.addCols(" ", 0, dHeader.size());
							pc.setFont(8,1,Color.white);
							pc.addCols("Creado por: ",2,2,Color.gray);
							pc.addCols(""+cdo.getColValue("usuario_crea"),0,2,Color.gray);
							pc.addCols(""+cdo.getColValue("fecha_crea"),0,(dHeader.size()-4),Color.gray);
							pc.addCols("Modificado por: ",2,2,Color.gray);
							pc.addCols(""+cdo.getColValue("usuario_mod"),0,2,Color.gray);
							pc.addCols(""+cdo.getColValue("fecha_mod"),0,(dHeader.size()-4),Color.gray);

							pc.flushTableBody(true);
							pc.addNewPage();
			}//for i
		}//else

	    pc.addTable();
	    pc.close();
	    response.sendRedirect(redirectFile);
}
%>