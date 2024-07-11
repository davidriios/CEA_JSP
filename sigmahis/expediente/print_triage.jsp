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
String tipoPersona = request.getParameter("tipoPersona");
String filter = "";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if(desc == null) desc = "";
if(fc == null ) fc = "";
if (fg==null) fg = "";
if (tipoPersona==null) tipoPersona = "T";

String xtraH = "";
if (tipoPersona != null && !tipoPersona.trim().equals("")) xtraH = " and tipo_persona = '"+tipoPersona+"'";

if (fc.equals("") ){
		fc = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
		 filter = " and decode(observacion,'CONNEX',fecha,fecha_creacion) = (select max(decode(observacion,'CONNEX',fecha,fecha_creacion)) fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and status = 'A') ";
}else{
		 filter = " and decode(observacion,'CONNEX',fecha,fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am') ";
}

sql = "select tipo_persona as tipoPersona, categoria, to_char(fecha,'dd/mm/yyyy') as fecha, to_char(hora,'hh12:mi:ss am') as hora, to_char(hora_registro,'hh12:mi:ss am') as horaRegistro, usuario_creacion as usuarioCreacion, usuario_modif as usuarioModif, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fechaCreacion, to_char(fecha_modif,'dd/mm/yyyy hh12:mi:ss am') as fechaModif,decode(dolor,'S','SI','N','NO',' ')dolor, escala, trim(observacion) observacion, nvl(padecimiento_actual, ' ') as padecimientoActual from tbl_sal_signo_paciente where pac_id="+pacId+" and secuencia="+noAdmision+" and status = 'A'"+filter;

cdo = SQLMgr.getData(sql);

if (cdo == null) {
	cdo = new CommonDataObject();
	cdo.addColValue("categoria"," ");
	cdo.addColValue("tipoPersona","-");
}

if (cdo.getColValue("observacion")!=null && !cdo.getColValue("observacion").equals("")){
	 if (fc.equals("") ){
		 filter = " and decode(observaciones,'CONNEX',fecha_signo,fecha_creacion) = (select max(decode(observaciones,'CONNEX',fecha_signo,fecha_creacion)) fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and status = 'A') ";
	 }else{
		 filter = " and decode(observaciones,'CONNEX',fecha_signo,fecha_creacion) = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am') ";
	 }
}else{
		if (fc.equals("") ){
		fc = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
				filter = " and fecha_creacion = (select max(fecha_creacion) fechaMax from  tbl_sal_signo_paciente WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and status = 'A') ";
	}else{
			 filter = " and fecha_creacion = to_date('"+fc+"','dd/mm/yyyy hh12:mi:ss am')";
		}
}

//

//if (request.getMethod().equalsIgnoreCase("GET"))
//{

	sql = "select a.*, nvl(b.sigla_um,' ') as sigla_um, nvl(c.resultado,' ') as resultado from tbl_sal_signo_vital a, tbl_sal_signo_vital_um b, (select * from tbl_sal_detalle_signo z where pac_id = "+pacId+" AND secuencia = "+noAdmision+filter+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') ) c where a.codigo=b.cod_signo(+) and b.valor_default(+)='S' and a.codigo=c.signo_vital(+) order by a.codigo";

	alDet = SQLMgr.getDataList(sql);

 String fecha = cDateTime;
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

	//------------------------------------------------------------------------------------
 //PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

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

		pc.setNoColumnFixWidth(dHeader);
		pc.createTable();

		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subTitle, xtraSubtitle, userName, fecha, dHeader.size());
		pc.setTableHeader(1);

		if(alDet.size() < 1){
			pc.addCols("No encontramos registros!", 0, dHeader.size());
		}else{

	pc.setFont(9,0);

		pc.addCols("Fecha/Hora Toma: ", 0,2);

//System.out.println("---------------------Printing Gety "+cdo.getColValue("fecha"));

if ( cdo != null ){

	pc.addCols(cdo.getColValue("fecha"," ")+" / "+cdo.getColValue("horaRegistro"," "), 0, 2);
	pc.addCols("", 0, 2);
	pc.addCols("Registrado Por: ", 2, 2);
	pc.addCols("Triage" +" - "+ cdo.getColValue("usuarioCreacion"," "),0,2);

	pc.addCols("Dolor: [ "+cdo.getColValue("dolor"," ")+" ]",0,1);
	pc.addCols(" "+cdo.getColValue("escala"," "),0,9);

	pc.addCols("Padecimiento Actual: "+cdo.getColValue("padecimientoActual"," "),0,9);
}else{
		pc.addCols("", 0, 2);
	pc.addCols("", 0, 2);
	pc.addCols("Registrado Por: ", 2, 2);
	pc.addCols("Triage" +" - ",0,2);
	pc.addCols("Dolor: ",0,1);
	pc.addCols("",0,9);
}

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
				pc.addCols(cdoDet.getColValue("descripcion"),0,3);
				pc.addCols(cdoDet.getColValue("resultado"),1,1);
				pc.addCols(cdoDet.getColValue("sigla_um"),0,1);

		if (ic == 2 || (j + 1) == alDet.size())
		{
			if (ic != 2 && (j + 1) == alDet.size())
			{

				//pc.addCols(cdoDet.getColValue("descripcion"),0,3);
				//pc.addCols(cdoDet.getColValue("resultado"),1,1);
				//pc.addCols(cdoDet.getColValue("sigla_um"),0,1);

			}//end if
			ic = 0;

		}//end if
		} //end for

		pc.addCols("", 0,5); // empareja la uultima fila de los signos vitales

		pc.addCols(" ",1,dHeader.size(),10f);
		pc.setFont(9,0);

		String cat = "";
		Color c = null;

		if ( cdo != null ){

		if ( cdo.getColValue("categoria").equals("1") ) {
			if (fg.equals("TSV_ESI")) cat = "PRIORIDAD 1";
			else cat = "CRITICO";
			c = Color.red;
		}
		else if ( cdo.getColValue("categoria").equals("2") ) {
		 if (fg.equals("TSV_ESI")) cat = "PRIORIDAD 2";
		 else cat = "URGENTE";
		 c = Color.orange;
		}
		else if ( cdo.getColValue("categoria").equals("3") ){
		 if (fg.equals("TSV_ESI")) cat = "PRIORIDAD 3";
		 else cat = "NO URGENTEs";
			 c = Color.green;
		 }
		}

		if (cdo.getColValue("tipoPersona").equalsIgnoreCase("T")) {
			pc.addCols("Categoría:", 0,1);
			pc.setFont(9,1,c);
			pc.addCols(cat + " ", 0,9);
		}

	 pc.addCols(" ",1,dHeader.size(),50f);

	//pc.setFont(9,1,Color.white);
	//pc.addCols("Leyendas",0,dHeader.size(),15f,Color.green);

	pc.setFont(9,0);

	if (cdo == null) {
		cdo = new CommonDataObject();
		cdo.addColValue("categoria","");
	}

if (cdo.getColValue("tipoPersona").equalsIgnoreCase("T")) {
	if (cdo.getColValue("categoria").equals("1"))
		pc.addBorderCols(fg.equals("TSV_ESI")?"PRIORIDAD 1":"CRITICO",1,3,Color.red);
		else pc.addBorderCols(fg.equals("TSV_ESI")?"PRIORIDAD 1":"CRITICO",1,3);

	if (cdo.getColValue("categoria").equals("2"))
		pc.addBorderCols(fg.equals("TSV_ESI")?"PRIORIDAD 2":"URGENTE",1,3,Color.orange);
	else pc.addBorderCols(fg.equals("TSV_ESI")?"PRIORIDAD 2":"URGENTE",1,3);

	if (cdo.getColValue("categoria").equals("3"))
		pc.addBorderCols(fg.equals("TSV_ESI")?"PRIORIDAD 3":"NO URGENTE",1,4,Color.GREEN);
	else pc.addBorderCols(fg.equals("TSV_ESI")?"PRIORIDAD 3":"NO URGENTE",1,4);

	//pc.addBorderCols("NO URGENTE",1,4,c);

	pc.setFont(8,1);

	pc.addCols("Para Cardiorespiratorio",0,3);
	pc.addCols("Dolor de cabeza intenso y comienzo súbito",0,3);
	pc.addCols("Crisis hipertensivas sin factores de riesgos cardiovascular para su vida",0,4);

		pc.addCols("Apnea",0,3);
	pc.addCols("Compromiso del estado de conciencia",0,3);
	pc.addCols("Hemorragias recientes (no activas)",0,4);

	pc.addCols("Quemadura de vías aéreas",0,3);
	pc.addCols("Estado de confusión, Letárgico",0,3);
	pc.addCols("Niños con saturación de oxígeno entre 90-95%",0,4);

	pc.addCols("Insuficiencia respiratoria severa",0,3);
	pc.addCols("Cardiopatías",0,3);
	pc.addCols("Convulsiones de pacientes epilépticos",0,4);

		pc.addCols("Status convulsivo",0,3);
	pc.addCols("Hipertensión arterial",0,3);
	pc.addCols("Vomito persistente en niños",0,4);

	pc.addCols("Intoxicaciones",0,3);
	pc.addCols("Signos de deshidratación en niño pequeño",0,3);
	pc.addCols("Cuadro gastrointestinal en adultos",0,4);

	pc.addCols("Hemorragia severa",0,3);
		pc.addCols("Reacción alérgica severa",0,3);
		pc.addCols("Fractura de cadera o de una extremidad",0,4);

	pc.addCols("",0,3);
		pc.addCols("Trauma ocular",0,3);
		pc.addCols("Aspiración de cuerpo extraño sin dificultad respiratoria",0,4);

		pc.addCols("",0,3);
		pc.addCols("Hemorragia mayor",0,3);
		pc.addCols("Diarreas",0,4);

	pc.addCols("",0,3);
		pc.addCols("Traumatismo moderado",0,3);
		pc.addCols("",0,4);

	pc.addCols("",0,3);
		pc.addCols("Dolor severo en escala de 7 a 10",0,3);
		pc.addCols("",0,4);
}

}//end else


	pc.addTable();
	if(isUnifiedExp){
		pc.close();
		response.sendRedirect(redirectFile);
	}
//}
%>