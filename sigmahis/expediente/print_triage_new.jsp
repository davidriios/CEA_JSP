<%@ page errorPage="../error.jsp" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.expediente.SignoPaciente"%>
<%@ page import="issi.expediente.DetalleSignoPaciente"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="cdoUsr" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="SPMgr" scope="page" class="issi.expediente.SignoPacienteMgr" />
<%@ page import="java.util.Hashtable" %>
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
SPMgr.setConnection(ConMgr);

ArrayList alDet = new ArrayList();
ArrayList al = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
//Hashtable det = new Hashtable();

CommonDataObject cdo, cdoPacData, cdoDet  = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String compania = (String) session.getAttribute("_companyId");
String desc = request.getParameter("desc");
String fc = request.getParameter("fc");
String fg = request.getParameter("fg");
String filter = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(fc == null ) fc = "";
if(fg == null ) fg = "";

if (fc.equals("") ){
		fc = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
		 filter = " and fecha_creacion = (select max(fecha_creacion) fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and tipo_persona = 'T' and status = 'A') ";

}else{
		 filter = " and fecha_creacion = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
}

if ( fg.equals("") ) filter = "";

sql = "select a.tipo_persona as tipoPersona, a.categoria, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora,'hh12:mi:ss am') as hora, to_char(a.fecha_registro,'dd/mm/yyyy') as fechaRegistro,  to_char(a.hora_registro,'hh12:mi:ss am') as horaRegistro, a.usuario_creacion as usuarioCreacion, a.usuario_modif as usuarioModif, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(a.fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif, a.escala, nvl(padecimiento_actual, ' ') as padecimientoActual from tbl_sal_signo_paciente a where a.pac_id="+pacId+" and a.secuencia="+noAdmision+filter+" and a.tipo_persona = 'T' and a.status = 'A' order by  a.fecha_registro desc, a.hora_registro desc";

al = SQLMgr.getDataList(sql);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

	sql = "select a.*, nvl(b.sigla_um,'') as sigla_um, nvl(c.resultado,' ') as resultado, to_char(c.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion from tbl_sal_signo_vital a, tbl_sal_signo_vital_um b, (select * from tbl_sal_detalle_signo z where pac_id = "+pacId+" AND secuencia = "+noAdmision+filter+" and tipo_persona = 'T' and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') ) c where a.codigo=b.cod_signo(+) and b.valor_default(+)='S' and a.codigo=c.signo_vital(+) order by c.fecha_signo desc, c.hora desc, a.codigo";

	alDet = SQLMgr.getDataList(sql);

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
	String subTitle = desc;
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
		cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc=null;
	boolean isUnifiedExp=false;
		pc = (PdfCreator) session.getAttribute("printExpedienteUnico");

	if(pc==null){
		pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
		isUnifiedExp=true;
	}

	String groupByFecha = "";

		Vector dHeader = new Vector();
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".10");

		Vector legenda = new Vector();
		legenda.addElement(".25");
		legenda.addElement(".25");
		legenda.addElement(".25");
		legenda.addElement(".25");

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if(alDet.size() < 1){
			pc.addCols("No encontramos registros!", 0, dHeader.size());
		}else{

			String cat = "";
			Color c = Color.green;
			Color bg = Color.white;

			pc.setFont(9,0);

		for ( int h = 0; h<al.size(); h++ ){
			 cdo = (CommonDataObject)al.get(h);

			 if ( h != 0 ){
				 pc.addBorderCols(" ",0,dHeader.size(),0.5f,0f,0f,0f);
				 pc.addCols(" ",0,dHeader.size());
			}

			pc.addCols("Fecha/Hora Toma: "+(h+1), 0,2);
			pc.addCols(cdo.getColValue("fechaRegistro")+" / "+cdo.getColValue("horaRegistro"), 0, 2);
			pc.addCols("", 0, 2);
			pc.addCols("Registrado Por: ", 2, 2);
			pc.addCols("Triage" +" - "+ cdo.getColValue("usuarioCreacion"),0,2);

			pc.addCols("Dolor: ",0,1);
			pc.addCols(cdo.getColValue("escala"),0,9);

			pc.addCols("Padecimiento Actual: ",0,1);
			pc.addCols(cdo.getColValue("padecimientoActual"),0,9);

			/* pc.addCols("", 0, 2);
			pc.addCols("", 0, 2);
			pc.addCols("Registrado Por: ", 2, 2);
			pc.addCols("Triage" +" - ",0,2);
			pc.addCols("Dolor: ",0,1);
			pc.addCols("",0,9); */

			pc.addCols("",0,dHeader.size(),10f);
			pc.setFont(9,0,Color.white);
			pc.addBorderCols("Signo Vital",1,3,Color.gray);
			pc.addBorderCols("Valor",1,1, Color.gray);
			pc.addBorderCols("",1,1, Color.gray);

			pc.addBorderCols((alDet.size()>1)?"Signo Vital":"  ",1,3, Color.gray);
			pc.addBorderCols((alDet.size()>1)?"Valor":"  ",1,1, Color.gray);
			pc.addBorderCols("",1,1, Color.gray);

			pc.setFont(9,0);

			int ic = 0;
			for (int j=1; j<=alDet.size(); j++)
			{
				cdoDet = (CommonDataObject) alDet.get(j-1);

				ic++;
				//if (cdo.getColValue("fechaCreacion").equals(cdoDet.getColValue("fechaCreacion")) ){
					pc.addCols(cdoDet.getColValue("descripcion"),0,3);
					pc.addCols(cdoDet.getColValue("resultado"),1,1);
					pc.addCols(cdoDet.getColValue("sigla_um"),0,1);
				//}

				if (ic == 2 || (j + 1) == alDet.size())
				{
					if (ic != 2 && (j + 1) == alDet.size())
					{
					if (cdo.getColValue("fechaCreacion").equals(cdoDet.getColValue("fechaCreacion")) ){
						//pc.addCols(cdoDet.getColValue("descripcion"),0,3);
						//pc.addCols(cdoDet.getColValue("resultado"),1,1);
						//pc.addCols(cdoDet.getColValue("sigla_um"),0,1);
					}

					}//end if
					ic = 0;

				}//end if
				} //end for

				pc.addCols("", 0,5); // empareja la uultima fila de los signos vitales

				pc.addCols(" ",1,dHeader.size(),10f);
				pc.setFont(9,0);

				if ( cdo.getColValue("categoria").equals("1") ){ cat = "PRIORIDAD 1"; c = Color.blue;}
				else if ( cdo.getColValue("categoria").equals("2") ) {cat = "PRIORIDAD 2"; c = Color.red;}
				else if ( cdo.getColValue("categoria").equals("3") ) {cat = "PRIORIDAD 3"; c = Color.yellow; bg = Color.black;}
				else {cat = "PRIORIDAD 4"; c= Color.green;}

			pc.addCols("Categoría:", 0,1);
			pc.setFont(9,1,bg);
			pc.addCols(cat, 1,2,c);
			pc.addCols(" ", 0,7);

		}//for h

			pc.flushTableBody(true);
			pc.addNewPage();

			pc.addCols(" ",1,dHeader.size());
			pc.setFont(7,1,Color.white);


			pc.setNoColumnFixWidth(legenda);
			pc.createTable("legenda",false,0,0.0f,602f);
			pc.setFont(7,1,Color.white);
			pc.addCols("PRIORIDADES DE EMERGENCIAS (TRIAGE)",1,legenda.size(),15f,Color.gray);

			pc.addCols("PRIORIDAD 1\n(AZUL)",1,1,Color.blue);
			pc.addCols("PRIORIDAD 2\n(ROJO)",1,1,Color.red);
			pc.setFont(7,1,Color.black);
			pc.addCols("PRIORIDAD 3\n(AMARILLO)",1,1,Color.yellow);
			pc.setFont(7,1,Color.white);
			pc.addCols("PRIORIDAD 4\n(VERDE)",1,1,Color.green);

			pc.setFont(7,0);
			pc.addCols("\u2022POLITRAUMATISMO\n\n\u2022TRAUMO PENETRANTE DE CUALQUIER ETIOLOGIA O LOCALIZACION\n\n\u2022DETERIORO AGUDO DEL ESTADO DEL CONCIENCIA.\n\n\u2022SHOCK DE CUALQUIER ETIOLOGIA\n\n\u2022PARO CARADIORESPIRATORIO DE CUALQUIER ETIOLOGIA\n\n\u2022DOLOR TORACICO CON PALIDEZ CUTANEA, HIPO O HIPERTENSION ARTERIAL, CON ALTERACION DE LA FRECUENCIA CARDIACA O INCREMENTO DE LA FRECUENCIA RESPIRATORIA.\n\n\u2022ARRITMIA CARDIACA CON INESTABILIDAD HEMODINAMICA.\n\n\u2022INFARTO AGUDO AL MIOCARDIO\n\n\u2022DISNEA CON ALGUNOS DE LOS DATOS QUE ESPECIFICAN PARA EL DOLOR TORACICO.\n\n\u2022OBSTRUCCION DE LA VIA AEREA POR CUERPO EXTRAÑO.\n\n\u2022CEFALEA INTENSA ACOMPAÑADA DE FIEBRE, ALTERACION DE LA CONCIENCIA, HIPERTENSION ARTERIAL, VOMITOS, FOCALIDAD NEUROLOGICA.",3,1);

			pc.setFont(7,0,Color.white);
			pc.addCols("\u2022CRISIS ASMATICA CON INSUFICIENCIA RESPIRATORIA\n\n\u2022ESTADO POSTICTAL\n\n\u2022HEMOPTISIS NO MASIVA\n\n\u2022COLICO URETERAL DE INTENSIDAD DE 7-10\n\n\u2022SANGRADO VAGINAL DURANTE EL EMBARAZO\n\n\u2022DIABETES MELLITUS CON SIGNOS DE HIPO O HIPERGLICEMIA CON COMPROMISO DEL ESTADO GENERAL\n\n\u2022QUEMADURAS DE I° Y II°, MENORES AL 20% DE LA SUPERFICIE CORPORAL Y QUE NO COMPROMETAN AREAS ESPECIALES\n\n\u2022FRACTURAS DISTALES ESTABLES EN EXTREMIDADES, LUXACIONES CON COMPROMISO NEUROVASCULAR.\n\n\u2022SINDROME FEBRIL EN NIÑOS CON TEMP. MAYOR DE 38°\n\n\u2022CEFALEA SEVERA (8-10) DE INICIO RECIENTE O CON SINTOMAS NEUROLOGICOS.\n\n\u2022VOMITOS PERSISTENTES CON DESHIDRATACION MODERADA A SEVERA",3,1,Color.gray);

			pc.setFont(7,0);

			pc.addCols("\u2022VERTIGO LEVE\n\n\u2022OTALGIA MODERADA\n\n\u2022INFECCIONES RESPIRATORIAS ALTAS NO COMPLICADAS EN NIÑOS\n\n\u2022INFECCIONES SIN COMPROMISO DEL ESTADO GENERAL\n\n\u2022TRAUMA LEVE AISLADO, MAYOR DE 24 HORAS DE EVOLUCION\n\n\u2022SINDROME FEBRIL EN ADULTOS CON TEMP. MAYOR DE 38°.\n\n\u2022ABRASIONES Y LESIONES SUPERFICIALES EN PIEL\n\n\u2022LESIONES OSTEOMUSCULARES SIN DEFORMIDAD.\n\n\u2022ESPISTAXIS CON SIGNOS VITALES NORMALES.\n\n\u2022HEMORRAGIAS SUBCONJUNTIVALES.\n\n\u2022HERIDAS CONTUSAS SIN DEFORMIDAD\n\n\u2022HEMATURIA.\n\n\u2022CEFALEA AGUDA SIN SINTOMAS NEUROLOGICOS\n\n\u2022SINDROME ICTERICO",3,1);

			pc.setFont(7,0,Color.white);
			pc.addCols("\u2022INFECCIONES RESPIRATORIAS ALTAS NO COMPLICADAS EN EL ADULTO\n\n\u2022ESTADO GRIPAL EN ADULTOS\n\n\u2022SINTOMAS GASTROINTESTINALES\n\n\u2022HIPERTENSION ARTERIAL NO COMPLICADA\n\n\u2022DOLOR MUSCULO-ESQUELETICO LEVE.\n\n\u2022ENFERMEDAD DERMATOLOGICA CRONICA\n\n\u2022DIARREA SIN COMPROMISO DEL ESTADO GENERAL EN ADULTOS.\n\n\u2022INFECCION URINARIA SIN COMPROMISO DEL ESTADO GENERAL\n\n\u2022CEFALEA CRONICA LEVE\n\n\u2022ESTREÑIMIENTO\n\n\u2022ANOREXIA\n\n\u2022LEUCORREA\n\n\u2022DISMINORREA.",3,1,Color.gray);


			// New Row

			pc.setFont(7,0);
			pc.addCols("\u2022DOLOR ABDOMINAL CON INTENSIDAD DE 7-10\n\n\u2022TENSION ARTERIAL MAYOR O IGUAL A 180/120\n\n\u2022HEMORRAGIAS DE VIAS DIGESTIVAS ALTAS O BAJAS CON INESTABILIDAD HEMODINAMICA\n\n\u2022QUEMADURA DE CUALQUIER ETIOLOGIA, MAYORES AL 20% DE EN CUALQUIER GRADO Y LOCALIZACION\n\n\u2022INSUFICIENCIA RESPIRATORIA DE CUALQUIER ETIOLOGIA\n\n\u2022ESTATUS EPILEPTICO\n\n\u2022REACCION ANAFILACTICA, CON COMPROMISO RESPIRATORIO\n\n\u2022INTOXICACION EXOGENA\u2022ESTATUS PSICOTICO AGUDO\n\n\u2022SINCOPE DE CUALQUIER ETIOLOGIA\n\n\u2022TRABAJO DE PARTO EXPULSIVO\n\n\u2022HEMORRAGIA AGUDA\n\n\u2022FRACTURA CON COMPROMISO NEURO-VASCULAR\n\n\u2022DIABETES DESCOMPENSADA Y OTRAS PATOLOGIAS METABOLICAS DESCOMPENSADAS\n\n\u2022INSUFICIENCIA VASCULAR AGUDA\n\n\u2022QUEMADURA ELECTRICA\n\n\u2022CUERPO EXTRAÑO EN VIAS AEREAS\n\n\u2022INTENTO DE SUICIDIO O AUTOLITICO\n\n\u2022MALTRATO INFANTIL",3,1);

			pc.setFont(7,0,Color.white);
			pc.addCols("\u2022ACCIDENTE CEREBRO VASCULAR TRANSITORIO\n\n\u2022DELIRIUM TREMENS\n\n\u2022TRAUMA CRANEO ENCEFALICO MODERADO\n\n\u2022LUMBALGIA AGUDA MODERADA A SEVERA O CRONICA AGUDIZADA\n\n\u2022RETENCION URINARIA AGUDA.\n\n\u2022INSUFICIENCIA RENAL CRONICA CON SIGNOS DE DESCOMPRESION\n\n\u2022MORDEDURA DE ANIMALES\n\n\u2022PERDIDA SUBITA DE LA VISION\n\n\u2022VIOLACION\n\n\u2022DIARREA QUE COMPROMETE EL ESTADO GENERAL\n\n\u2022ESGUINCES SEVEROS\n\n\u2022CUERPOS EXTRAÑOS EN OJOS OIDOS O NARIZ\n\n\u2022TROMBOSIS VENOSA PROFUNDA\n\n\u2022HEMORROIDES TROMBOSADAS O PROLAPSADAS\n\n\u2022HERIDAS POR ARMA CORTOPUNZANTE SIN SANGRADO\n\n\u2022VERTIGO SEVERO\n\n\u2022DOLOR PLEURITICO\n\n\u2022HERIDAS INFECTADAS\n\n\u2022ACCIDENTES DE TRANSITO O LABORALES SIN COMPROMISO DEL ESTADO GENERAL\n\n\u2022ABSCESOS PARA DRENAR CON DOLOR DE INTENSIDAD DE (7-10)",3,1,Color.gray);

			pc.addCols("\u2022SINDROME DIARREICO SIN COMPROMISO  DEL ESTADO GENERAL EN EL ADULTO.\n\n\u2022METRORRAGIA LEVE, SIN COMPROMISO HEMODINAMICO\n\n\u2022LUMBALGIA AGUDA LEVE O CRONICA AGUDIZADA",3,1);
			pc.addCols("",3,1);

			pc.flushTableBody(true);
			//pc.addNewPage();

			pc.useTable("main");
			pc.addTableToCols("legenda",1,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);

		}//end else

		pc.addTable();
	if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
%>