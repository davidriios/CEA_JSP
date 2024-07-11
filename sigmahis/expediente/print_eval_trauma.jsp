<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
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
Reporte
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2= new ArrayList();

CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdoPacData = new CommonDataObject();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String userName = UserDet.getUserName();
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
String fechaEscala = request.getParameter("fechaEscala");
String horaEscala = request.getParameter("horaEscala");

String fp = request.getParameter("fp");
String fechaEval= request.getParameter("fechaEval");
String horaEval = request.getParameter("horaEval");

String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (appendFilter == null) appendFilter = "";
if (fechaEscala== null) fechaEscala = fecha.substring(0,10);
if (horaEscala== null) horaEscala = fecha.substring(11);
if (fechaEval== null) fechaEval = fecha.substring(0,10);
if (horaEval== null) horaEval = fecha.substring(11);

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

if (fg== null) fg = "A";


sql = "select ap.primer_nombre||' '||ap.segundo_nombre||' '||decode(ap.apellido_de_casada,null,ap.primer_apellido||' '||ap.segundo_apellido,ap.apellido_de_casada) as nombre_paciente, decode(ap.pasaporte,null,ap.provincia||'-'||ap.sigla||'-'||ap.tomo||'-'||ap.asiento||'-'||ap.d_cedula,ap.pasaporte) as identificacion, to_char(aa.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, to_char(aa.fecha_egreso,'dd/mm/yyyy') as fecha_egreso, nvl(aa.medico,' ') as medico, ap.codigo as codigo_paciente, aa.secuencia as admision, m.primer_nombre||' '||m.segundo_nombre||' '||decode(m.apellido_de_casada,null,m.primer_apellido||' '||m.segundo_apellido,m.apellido_de_casada) as nombre_medico, aca.habitacion||decode(aca.habitacion,null,'','/'||aca.cama) as cama , to_char(eg.fecha,'dd/mm/yyyy') as fecha, to_char(eg.hora,'hh12:mi:ss am') as hora, decode(eg.evaluacion_derecha,null,0,eg.evaluacion_derecha) as evaluacionDerecha, decode(eg.evaluacion_izquierda,null,0,eg.evaluacion_izquierda) as evaluacionIzquierda, eg.observacion as observacion , to_char(eg.fecha_registro,'dd/mm/yyyy') as fechaRegistro, to_char(eg.hora_registro,'hh12:mi:ss am') as horaRegistro, nvl(eg.total,0) as total from tbl_sal_escala_coma eg,tbl_adm_paciente ap, tbl_adm_admision aa, tbl_adm_medico m, tbl_adm_cama_admision aca where ap.pac_id="+pacId+" and aa.secuencia="+noAdmision+" and ap.pac_id=aa.pac_id and aa.medico=m.codigo(+) and aca.pac_id(+)=aa.pac_id and aca.admision(+)=aa.secuencia and aca.fecha_final(+) is null and aca.hora_final(+) is null and eg.pac_id(+) = aa.pac_id and eg.secuencia (+)= aa.secuencia  and to_date(to_char(eg.fecha(+),'dd/mm/yyyy'),'dd/mm/yyyy')  = to_date('"+fechaEval+"','dd/mm/yyyy') and to_date(to_char(eg.hora(+),'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEval+"','hh12:mi:ss am') ";
cdo1 = SQLMgr.getData(sql);

System.out.println(sql);

 sql="select x.*,case when x.codigo in (10,11,12,13,15)  then 'T' else 'F' end viewMode,decode(x.codigo,10, decode(cod_escala,0,case when x.codEvaluacion >=13 and  x.codEvaluacion <=15 then 1 "
									+" when x.codEvaluacion >=9 and  x.codEvaluacion <=12 then 2"
									+" when x.codEvaluacion >=6 and  x.codEvaluacion <=8 then 3"
									+" when x.codEvaluacion >=4 and  x.codEvaluacion <=5 then 4"
									+" when x.codEvaluacion =3 then 5 else 0 end,0),"

				 +" 11, decode(cod_escala,0,case when x.codEvaluacion >89  then 1"
								+"   when x.codEvaluacion >80 and  x.codEvaluacion <89 then 2"
								 +"  when x.codEvaluacion >=50 and  x.codEvaluacion <=70 then 3"
								 +"  when x.codEvaluacion >=1 and  x.codEvaluacion <=49 then 4"
									+" when x.codEvaluacion =0 then 5 else 0 end,0),"

					+"12, decode(cod_escala,0,case when (x.codEvaluacion >=10 and x.codEvaluacion <=29) then 1 "
									+" when x.codEvaluacion >29 then 2 "
									 +"when x.codEvaluacion >=6 and  x.codEvaluacion <=9 then 3 "
									+" when x.codEvaluacion >=1 and  x.codEvaluacion <=5 then 4 "
									+" when x.codEvaluacion =0 then 5 else 0 end,0), "
					+"13, decode(cod_escala,0,case when x.codEvaluacion >20  then 1"
									+" when x.codEvaluacion >=10 and  x.codEvaluacion <=20	then 2 "
									+" when x.codEvaluacion <10 then 3 "
									+" else 0 end,0),"

					+"15, decode(cod_escala,0,case when x.codEvaluacion >89 /*<=90*/ then 1  "
									+" when x.codEvaluacion >=50 and  x.codEvaluacion <=89 then 2  "
									+" when x.codEvaluacion <50  then 3 else 0 end,0), detalle1) detalle "

 +"from( SELECT nvl(a.codigo,0)as codigo, 0 as cod_escala,nvl(b.detalle ,0)as detalle1, a.descripcion as descripcion , 0 as escala ,b.FECHA_ESCALA, b.HORA_ESCALA , b.OBSERVACION as observacion, nvl(b.VALOR,0) as valor, b.APLICAR  ,decode(a.codigo,10,( select total from tbl_sal_escala_coma where pac_id = "+pacId+" and secuencia = "+noAdmision+" and tipo ='"+fg+"' and  to_date(to_char(fecha,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fechaEscala+"','dd/mm/yyyy') and  to_date(to_char(hora,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEscala+"','hh12:mi:ss pm') ),11, (select decode(instr(resultado,'/'),0,null,substr(resultado,1,instr(resultado,'/') - 1)) sistolica from tbl_sal_detalle_signo z where  signo_vital =4 and pac_id="+pacId+"  AND secuencia= "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+"  AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))),12,( select resultado from tbl_sal_detalle_signo z where  signo_vital =3 and pac_id="+pacId+"  AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))), 13,(select resultado  from tbl_sal_detalle_signo z where  signo_vital = 8 /*6*/ and pac_id="+pacId+" AND secuencia= "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+"  AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))), 15, (select decode(instr(resultado,'/'),0,null,substr(resultado,1,instr(resultado,'/') - 1)) sistolica from tbl_sal_detalle_signo z where  signo_vital =4 and pac_id="+pacId+"  AND secuencia= "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and status = 'A') and fecha_creacion = (select max(fecha_creacion)fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and status = 'A'))),'0') codEvaluacion FROM TBL_SAL_TIPO_ESCALA a, (SELECT nvl(TIPO_ESCALA ,0)as tipo_escala, nvl(DETALLE,0)as detalle, FECHA_ESCALA, HORA_ESCALA, OBSERVACION, VALOR, APLICAR FROM TBL_SAL_RESULTADO_ESCALA  where pac_id = "+pacId+"  and secuencia = "+noAdmision+" and to_date(to_char(fecha_escala,'dd/mm/yyyy'),'dd/mm/yyyy') = to_date('"+fechaEval+"','dd/mm/yyyy') and  to_date(to_char(hora_escala,'hh12:mi:ss am'),'hh12:mi:ss am') = to_date('"+horaEval+"','hh12:mi:ss pm') order by 1,2) b where a.codigo=b.tipo_escala(+) and a.tipo = '"+fp+"' union SELECT a.tipo_escala,a.codigo, 0, a.descripcion, a.escala,null, null, null ,0, '',0 FROM TBL_SAL_DETALLE_ESCALA a,(select nvl(TIPO_ESCALA,0) as tipo_escala  from TBL_SAL_RESULTADO_ESCALA a where pac_id = "+pacId+"  and secuencia = "+noAdmision+" order by 1 ) b where  a.codigo = b.tipo_escala(+) and a.tipo='"+fp+"' ORDER BY 1,2 )x ";
		 al = SQLMgr.getDataList(sql);


al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

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
	String title = "EXPEDIENTE";
	String subtitle = "EVALUACIÓN DE TRAUMA";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	Vector dHeader = new Vector();
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".35");
		dHeader.addElement(".35");

		CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
		if (paramCdo == null) {
		paramCdo = new CommonDataObject();
		paramCdo.addColValue("is_landscape","N");
		}
		if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
		cdoPacData.addColValue("is_landscape",""+isLandscape);
		}


	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY, null);

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");

	Vector detCol = new Vector();
		detCol.addElement(".04");
		detCol.addElement(".32");
		detCol.addElement(".04");
	Vector detCol1 = new Vector();
		detCol1.addElement(".40");
	Vector detCol2 = new Vector();
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");
		detCol2.addElement(".04");

	int iconImgSize = 9;
	int imgSize = 10;
	String escalaDer =cdo1.getColValue("evaluacionDerecha");
		String escalaIzq = cdo1.getColValue("evaluacionIzquierda");
	String iconUnchecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
	String iconChecked = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";
	String iconImg = ResourceBundle.getBundle("path").getString("images")+"/blackball.gif";

	pc.setNoColumn(1);

	//radioChecked table
	pc.createTable("radioChecked",false,0,588);
	pc.addImageCols(iconChecked,imgSize,1);

	//radioUnchecked table
	pc.createTable("radioUnchecked",false,0,588);
	pc.addImageCols(iconUnchecked,imgSize,1);

	//pupilas tables
	for( int j=1; j<=9; j++)
	{
		pc.createTable("pupila"+j,false,0,588);
		pc.addImageCols(iconImg,iconImgSize,1);
		iconImgSize += 2;
	}

	//evaluacion table
	pc.setFont(9, 0);
	pc.resetVAlignment();
	pc.setNoColumnFixWidth(detCol2);
	pc.createTable("evaluacion",false,0,379);
		pc.addBorderCols(" ",1,1);
		for (int j=1; j<=9; j++) pc.addBorderCols(""+j,1,1);

		pc.setVAlignment(1);
		pc.addCols(" ",1,1);
		for (int j=1; j<=9; j++) pc.addTableToCols("pupila"+j,1,1,iconImgSize);


		pc.addBorderCols("Der.",1,1);
		for (int j=1; j<=9; j++) pc.addTableToCols(((escalaDer.trim().equals(""+j))?"radioChecked":"radioUnchecked"),1,1,imgSize);

		pc.addBorderCols("Izq.",1,1);
		for (int j=1; j<=9; j++) pc.addTableToCols(((escalaIzq.trim().equals(""+j))?"radioChecked":"radioUnchecked"),1,1,imgSize);
		pc.resetVAlignment();

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());


		pc.setFont(9, 1);
		pc.setVAlignment(1);
		pc.addBorderCols("FECHA:    "+fechaEval+"     HORA:   "+horaEval+" ",0,dHeader.size());
		//pc.addTableToCols("evaluacion",1,1);
		pc.setVAlignment(0);

		pc.addBorderCols("FACTORES",1);
		pc.addBorderCols("VALOR",1);
		pc.addBorderCols("ESCALA",1);
		pc.addBorderCols("OBSERVACION",1);


	pc.setVAlignment(0);

	String desc = "",observ="",detalle="",codEvaluacion="";

	for (int i=0; i<al.size(); i++)
	{
		String iconDisplay = "";
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		//pc.addCols(" ",0,dHeader.size());

		pc.setVAlignment(1);
		pc.setFont(9, 0);

		if(cdo.getColValue("cod_escala").equals("0"))
		{
		if(cdo.getColValue("cod_escala").equals("0")&& i != 0)
		{

				pc.setVAlignment(1);
				pc.addBorderCols(" "+desc,0,1);
				pc.addBorderCols(" "+(codEvaluacion.equals("0")?"":codEvaluacion),0,1);
				pc.resetVAlignment();
				pc.addInnerTableToBorderCols(1);
				pc.setVAlignment(1);
				pc.addBorderCols(" "+observ,0,1);
				//pc.addBorderCols(" "+cdo.getColValue("observacion"),0,1);

				pc.resetVAlignment();
				pc.setVAlignment(2);
		}

		//pc.addBorderCols(" "+cdo.getColValue("descripcion"),0,1);
		detalle = cdo.getColValue("detalle");
		desc = cdo.getColValue("descripcion");
		observ = cdo.getColValue("observacion");
		codEvaluacion= cdo.getColValue("codEvaluacion");
		pc.setVAlignment(0);

		pc.setNoInnerColumnFixWidth(detCol);
		pc.setInnerTableWidth(208);
		pc.createInnerTable();
			pc.setFont(9, 0);
		//pc.addCols("",0,1);
		}else
		{



				if(detalle.trim().equals(cdo.getColValue("cod_escala")))
				{
				//pc.addInnerTableBorderCols(" ",0,1);
				iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_checked.gif";

				}
				else
				{
				//pc.addInnerTableBorderCols(" ",0,1);
					iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
				}
				//iconDisplay = ResourceBundle.getBundle("path").getString("images")+"/radiobutton_unchecked.gif";
				pc.setVAlignment(1);
				pc.addInnerTableImageCols(iconDisplay,imgSize,1);
				pc.setVAlignment(0);
				pc.addInnerTableBorderCols(" "+cdo.getColValue("descripcion"),0,1);
				pc.setFont(9, (detalle.trim().equals(cdo.getColValue("cod_escala"))?1:0));
				pc.addInnerTableBorderCols(" "+cdo.getColValue("escala"),2,1);
				pc.setFont(9, 0);

			}
		if(al.size()-1==i)
		{

		pc.setVAlignment(1);
		pc.addBorderCols(" "+desc,0,1);
		pc.addBorderCols(" "+(codEvaluacion.equals("0")?"":codEvaluacion),0,1);
		pc.resetVAlignment();
		pc.addInnerTableToBorderCols(1);
		pc.setVAlignment(1);
		pc.addBorderCols(" "+observ,0,1);
		//pc.addBorderCols(" "+cdo.getColValue("observacion"),0,1);

		pc.resetVAlignment();
		pc.setVAlignment(2);
		}
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}


	pc.addCols("Puntaje Total:   ",0,2);
	pc.addCols(" "+cdo1.getColValue("total"),2,1);
	pc.addCols(" ",0,1);
	if(cdo1.getColValue("total") == null || cdo1.getColValue("total").trim().equals("0"))
	pc.addCols("No se ha Registrado esta Evaluación   ",0,dHeader.size());

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>