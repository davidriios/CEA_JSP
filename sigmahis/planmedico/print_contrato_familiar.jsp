<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.awt.Color" %>
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
ArrayList al = new ArrayList();

String compania = (String)session.getAttribute("_companyId");
String codBen = request.getParameter("cod_ben");
String noContrato = request.getParameter("no_contrato");
String noSecuencia = request.getParameter("no_secuencia");
String fp = request.getParameter("fp");
String id_cuota = request.getParameter("id_cuota");
String primaPlanMedico="0";

StringBuffer sbSql = new StringBuffer();

if (codBen == null) codBen = "";
if (noContrato == null) noContrato = "";
if (noSecuencia==null) noSecuencia = "";
if (fp==null) fp = "";
if (id_cuota==null) id_cuota = "";

sbSql = new StringBuffer();
sbSql.append("select get_sec_comp_param(-1, 'PORC_IMP_FACT_PLAN_MEDICO') PORC_IMP_FACT_PLAN_MEDICO from dual");
	CommonDataObject _cdP = SQLMgr.getData(sbSql.toString());

	if(_cdP==null) primaPlanMedico = "5";
	else {
		primaPlanMedico = _cdP.getColValue("PORC_IMP_FACT_PLAN_MEDICO");
	}
sbSql = new StringBuffer();
sbSql.append("SELECT LPAD (a.id, 10, '0') contrato, p.nombre_paciente,replace(p.id_paciente, '-D', '') AS cedula,p.sexo,TO_CHAR (p.fecha_nacimiento, 'dd/mm/yyyy') AS fecha_nacimiento,DECODE (p.estado_civil,'ST', 'Soltero(a)','CS', 'Casado(a)',               'DV', 'Divorciado(a)','UN', 'Unido(a)','SP', 'Separado(a)','VD', 'Viudo(a)')estado_civil,d.nacionalidad,p.residencia_direccion||decode(residencia_no,null,'',' Casa No./Edificio '||residencia_no) as residencia_direccion, p.puesto_que_ocupa,NVL(p.telefono,' ')||'/'||nvl(p.telefono_movil,' ') AS telefono, (");
if(fp.equals("ce")){sbSql.append("(select monto from tbl_pm_cuota_extra where id = ");sbSql.append(id_cuota);sbSql.append(")");}else sbSql.append("a.cuota_mensual");
sbSql.append("*(("+primaPlanMedico+"/100)+1)) as cuota_mensual,to_char(nvl(fecha_ini_plan,sysdate), 'dd \"de\" MONTH\" del año\" yyyy', 'nls_date_language=Spanish') as dsp_date,observacion FROM tbl_pm_solicitud_contrato a, vw_pm_cliente p, tbl_sec_pais d WHERE     a.id_cliente = p.codigo and a.afiliados = 1 AND p.nacionalidad = d.codigo(+) AND a.id = ");
sbSql.append(noContrato);
sbSql.append(" AND p.codigo = ");
sbSql.append(codBen);

cdo = SQLMgr.getData(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.parentesco, b.nombre_paciente as client_name, b.sexo, nvl(trunc(months_between(sysdate, coalesce(b.f_nac, b.fecha_nacimiento))/12), 0) as edad, to_char(b.fecha_nacimiento, 'dd') dia, to_char(b.fecha_nacimiento, 'mm') mes, to_char(b.fecha_nacimiento, 'yyyy') anio, (select descripcion  from tbl_pla_parentesco where disponible_en_pm = 'S' and codigo = a.parentesco) parentesco_desc,a.diagnostico from tbl_pm_sol_contrato_det a, vw_pm_cliente b where a.id_cliente = b.codigo and a.estado != 'I' and a.parentesco <> 0 and a.id_solicitud = ");
sbSql.append(noContrato);

al = SQLMgr.getDataList(sbSql.toString());

sbSql = new StringBuffer();
sbSql.append("select a.parentesco, b.nombre_paciente as client_name, b.sexo, nvl(trunc(months_between(sysdate, coalesce(b.f_nac, b.fecha_nacimiento))/12), 0) as edad, to_char(b.fecha_nacimiento, 'dd') dia, to_char(b.fecha_nacimiento, 'mm') mes, to_char(b.fecha_nacimiento, 'yyyy') anio, (select descripcion  from tbl_pla_parentesco where disponible_en_pm = 'S' and codigo = a.parentesco) parentesco_desc,a.diagnostico, a.medicamento from tbl_pm_sol_contrato_det a, vw_pm_cliente b where a.id_cliente = b.codigo and a.estado != 'I' and a.id_solicitud = ");
sbSql.append(noContrato);
ArrayList alD = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy  hh12:mi:ss am");
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
	String imageDir = ResourceBundle.getBundle("path").getString("images");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float height = 72 * 8.5f;//612
	float width = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 15.0f;
	float topMargin = 60f;
	float bottomMargin = 13.5f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "CONTRATO DE SERVICIOS\nMEDICOS Y HOSPITALARIOS\nDEL PLAN MEDICO SANTA FE";
	String subtitle = "";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 10.0f;//between 7 and 10
	String pageNoLabel = "XXX";//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = "B";//T=Top, B=Bottom
	float cHeight = 11.0f;
	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector setDetail = new Vector();
	setDetail.addElement("04");
	setDetail.addElement("20");
	setDetail.addElement("24");
	setDetail.addElement("16");
	setDetail.addElement("04");
	setDetail.addElement("22");
	setDetail.addElement("20");

	//table header
	pc.setNoColumnFixWidth(setDetail);
	pc.createTable();

	//first row
	//pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, UserDet.getUserName(), fecha, setDetail.size());

    int fontSize = 10;

	pc.addCols("Empresa regulada por la Superintendencia de Seguros y Reaseguros de Panamá ",2,6);
  pc.addImageCols(imageDir+"/acerta.jpg",35.0f, 1);
	//pc.addCols(" ",1,setDetail.size()-1);
    pc.setFont(fontSize-1, 0);
	//pc.addCols(" ",1,1);
    pc.setFont(fontSize, 1);
	pc.addCols(title,1,setDetail.size());
	pc.addCols(" ",1,setDetail.size());

	pc.setFont(fontSize, 1);
	pc.addCols("CONTRATO NÚMERO: "+cdo.getColValue("contrato"),0,setDetail.size());
	pc.addCols(" ",0,setDetail.size());

    pc.setFont(fontSize, 0);
    pc.addCols("Entre los suscritos a saber: HOSPITAL SANTA FE S.A., sociedad constituida según las leyes de la República de Panamá e inscrita en el Registro Público Sección Mercantil a la Ficha 67198, Rollo 5409 e Imagen 060, representada en este acto por Carlos García de Paredes, varón, panameño, mayor de edad, casado, médico, vecino de esta ciudad, portador de la cédula de identidad personal N° 8-90-989, actuando en su condición de Presidente y Representante Legal quien en adelante se denominará EL HOSPITAL, por una parte, y por la otra:",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());

      pc.setNoColumnFixWidth(setDetail);
      pc.createTable("principal");
        pc.addCols("Nombre Completo:", 0, 2);
        pc.addCols(cdo.getColValue("nombre_paciente"), 0, setDetail.size() - 2);

        pc.addCols("Cédula/Pasaporte:", 0, 2);
        pc.addCols(cdo.getColValue("cedula"), 0, 1);
        pc.addCols("Sexo:", 2, 1);
        pc.addCols(cdo.getColValue("sexo"), 0, 1);
        pc.addCols("Fecha Nacimiento:", 2, 1);
        pc.addCols(cdo.getColValue("fecha_nacimiento"), 0, 1);

        pc.addCols("Estado Civil:", 0, 2);
        pc.addCols(cdo.getColValue("estado_civil"), 0, 1);
        pc.addCols("Nacionalidad:", 2, 1);
        pc.addCols(cdo.getColValue("nacionalidad"), 0, 3);

        pc.addCols("Dirección:", 0, 2);
        pc.addCols(cdo.getColValue("residencia_direccion"), 0, setDetail.size() - 2);

        pc.addCols("Ocupación:", 0, 2);
        pc.addCols(cdo.getColValue("puesto_que_ocupa"), 0, 1);
        pc.addCols("Teléfono:", 2, 1);
        pc.addCols(cdo.getColValue("telefono"), 0, 3);

      pc.useTable("main");
      pc.addTableToCols("principal",0,setDetail.size(), 0, Color.white, Color.black, 0.5f, 0.5f, 0.5f, 0.5f);

    pc.addCols(" ",0,setDetail.size());

    pc.addCols("Quien en adelante se denominará EL MIEMBRO, han acordado el presente contrato de Servicios Médicos y Hospitalarios de acuerdo a las siguientes cláusulas",0,setDetail.size());
    pc.addCols(" ",0,setDetail.size());

    pc.setBoldChunk("PRIMERO: ",fontSize);
    pc.addCols("EL HOSPITAL, se compromete a prestar los servicios médicos y hospitalarios del PLAN MEDICO SANTA FE (en adelante, EL PLAN) a EL MIEMBRO y a los siguientes dependientes, todos los cuales han sido incluidos en el formulario de solicitud y han sido declarados por EL MIEMBRO como elegibles para recibir los servicios de EL PLAN según las estipulaciones de EL FOLLETO.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());

    if ( al.size() > 0 ) {
    Vector benT = new Vector();
	benT.addElement("15");
	benT.addElement("48");
	benT.addElement("07");
	benT.addElement("10");
	benT.addElement("10");
	benT.addElement("10");

    pc.setNoColumnFixWidth(benT);
      pc.createTable("beneficiarios");

        pc.addCols(" ",1,1);
		pc.addCols("Nombres y Apellidos",0,1);
		pc.addCols("Sexo",1,1);
		pc.addCols("Fecha de Nacimiento",1,3);

        pc.addCols(" ",1,3);
		pc.addCols("Día",1,1);
		pc.addCols("Mes",1,1);
		pc.addCols("Año",1,1);

        for (int n=0; n<al.size(); n++){
            CommonDataObject cdoB = (CommonDataObject) al.get(n);
            pc.addCols(cdoB.getColValue("parentesco_desc"),0,1);
            pc.addCols(cdoB.getColValue("client_name"),0,1);
            pc.addCols(cdoB.getColValue("sexo"),1,1);
            pc.addCols(cdoB.getColValue("dia"),1,1);
            pc.addCols(cdoB.getColValue("mes"),1,1);
            pc.addCols(cdoB.getColValue("anio"),1,1);
        }

        pc.useTable("main");
        pc.addTableToCols("beneficiarios",0,setDetail.size(), 0, Color.white, Color.black, 0.5f, 0.5f, 0.5f, 0.5f);
        pc.addCols(" ",0,setDetail.size());
      }

    pc.setBoldChunk("SEGUNDO: ",fontSize);
    pc.addCols("Los servicios médicos y hospitalarios a que se refiere la cláusula anterior están descritos en las siguientes secciones de EL FOLLETO de EL PLAN que EL MIEMBRO declara haber leído y comprendido en su totalidad:",3,setDetail.size());

    int space = 3;
    pc.setFont(fontSize,1);
	pc.addCols(" ",0, space);
	pc.addCols("(a) Cuadros de Beneficios",0,setDetail.size()-space);
    pc.addCols(" ",0, space);
	pc.addCols("(b) Notas de Importancia",0,setDetail.size()-space);
    pc.addCols(" ",0, space);
	pc.addCols("(c) Definiciones",0,setDetail.size()-space);
    pc.addCols(" ",0, space);
	pc.addCols("(d) Exclusiones",0,setDetail.size()-space);

    pc.setFont(fontSize,0);
	pc.addCols("El Folleto, igual que sus modificaciones o adiciones (presentes y futuras), se adjunta a este Contrato y para todos los efectos se considera como parte integral del mismo. EL HOSPITAL, se reserva el derecho de modificar EL FOLLETO cuando lo estime conveniente.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("TERCERO: ",fontSize);
    pc.addCols("EL MIEMBRO declara que todas las manifestaciones y respuestas a las preguntas en el Formulario de Solicitud y la Declaración de salud son completas y verídicas y que son la base sobre la cual ha solicitado los servicios médicos y hospitalarios de EL PLAN.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("CUARTO: ",fontSize);
    pc.addCols("EL MIEMBRO autoriza a EL HOSPITAL para que solicite y obtenga de cualquier médico u hospital información sobre cualquier consulta o tratamiento médico referente a él mismo o a los dependientes mencionados en la Cláusula Primera.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("QUINTA: ",fontSize);
    pc.addCols("EL MIEMBRO se compromete a pagar mensualmente a EL HOSPITAL la suma de $"+CmnMgr.getFormattedDecimal(cdo.getColValue("cuota_mensual"))+" que corresponde a la cuota que se ha asignado por la prestación de los servicios médicos y hospitalarios de EL PLAN.  El pago de la cuota mensual deberá recibirlo EL HOSPITAL, durante los primeros cinco (5) días de cada mes.  Se considera que el pago se ha recibido cuando algún funcionario responsable de EL HOSPITAL, haya firmado el documento de recibo de la cuota o se pueda comprobar de alguna otra forma que el pago en efecto lo ha recibido EL HOSPITAL en el término señalado.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("SEXTO: ",fontSize);
    pc.addCols("EL MIEMBRO además se compromete a hacer todos los pagos correspondientes a los servicios médicos y hospitalarios, según lo estipulado en EL FOLLETO, sus adiciones o modificaciones. Igualmente, EL MIEMBRO se compromete a pagar a EL HOSPITAL por cualquier servicio o atención que no sea ofrecido por EL PLAN y que haya sido solicitado por EL MIEMBRO o cualquiera de sus dependientes incluidos en este contrato o agregados posteriormente.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("SEPTIMA: ",fontSize);
    pc.addCols("EL MIEMBRO se compromete a cumplir con todos los procedimientos administrativos establecidos en EL FOLLETO para el buen funcionamiento de EL PLAN.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("OCTAVA: ",fontSize);
    pc.addCols("EL MIEMBRO reconoce que los servicios médicos y hospitalarios de EL PLAN se prestarán solamente mientras no haya morosidad mayor de treinta (30) días calendario en el pago de la cuota mensual mencionada en la Cláusula Quinta, o cualquier modificación a la cuota, de acuerdo a lo que establece la Cláusula Décimo Cuarta.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("NOVENA: ",fontSize);
    pc.addCols("Las partes convienen en que la entrada en vigor de este contrato será el primer día del mes siguiente al que EL HOSPITAL haya recibido el primer pago de la cuota mensual.",0,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA: ",fontSize);
    pc.addCols("Este contrato tendrá una duración de doce (12) meses contados desde la entrada de vigor del mismo.  Sin embargo, el contrato se prorrogará automáticamente por períodos iguales, a menos que se cumplan algunas de las condiciones mencionadas en las siguientes tres cláusulas.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA PRIMERA: ",fontSize);
    pc.addCols("EL MIEMBRO podrá notificar por escrito a EL HOSPITAL su intención de no prorrogar este Contrato por lo menos 30 días antes de terminar su vigencia.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA SEGUNDA: ",fontSize);
    pc.addCols("EL HOSPITAL podrá dar por terminado este Contrato, en cualquier momento y sin mediar condición de aviso previo si se cumple alguna de las siguientes situaciones:",3,setDetail.size());

    space = 1;
    pc.setVAlignment(3);
    pc.addCols("",0,setDetail.size());

    pc.addCols("(a)",0,space);
    pc.addCols("La Declaración de Salud de EL MIEMBRO o de cualquiera de sus dependientes incluidos en este contrato al momento de su firma o inscritos con posterioridad difiere notablemente de su estado actual de salud.",3,setDetail.size()-space);

    pc.addCols("(b)",0,space);
    pc.addCols("Se comprueba que alguna manifestación o respuesta ofrecida por EL MIEMBRO o cualquiera de sus dependientes en el Formulario de Solicitud o Declaración de Salud no ha sido verídica.",3,setDetail.size()-space);

    pc.addCols("(c)",0,space);
    pc.addCols("El estado de salud de EL MIEMBRO o de alguno de sus dependientes se ha visto empeorado o complicado por el hecho de haberse negado EL MIEMBRO o dependiente a recibir algún tratamiento o estudio diagnóstico recomendado por algún médico afiliado a EL PLAN.",3,setDetail.size()-space);

    pc.addCols("(d)",0,space);
    pc.addCols("EL MIEMBRO se ha negado a hacer los pagos de las cuotas mensuales o de los servicios médicos y hospitalarios, o se ha negado a cumplir con los procedimientos administrativos establecidos en EL FOLLETO, sus adiciones o modificaciones, para el buen funcionamiento de EL PLAN.",3,setDetail.size()-space);

    pc.addCols("(e)",0,space);
    pc.addCols("Si EL MIEMBRO se encuentra moroso por más de treinta (30) días en el pago de sus cuotas mensuales.",3,setDetail.size()-space);

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA TERCERA: ",fontSize);
    pc.addCols("El contrato quedará automáticamente cancelado y sin efecto cuando EL MIEMBRO cumpla los sesenta (60) años de edad. Los dependientes podrán permanecer en EL PLAN mediante la firma de un nuevo contrato.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA CUARTA: ",fontSize);
    pc.addCols("EL HOSPITAL no podrá modificar la cuota mensual mencionada en la Cláusula Quinta durante el primer año de vigencia de este Contrato, a menos que EL MIEMBRO incluya nuevos dependientes. Sin embargo EL HOSPITAL podrá cambiar la cuota mensual que debe pagar EL MIEMBRO después de los primeros doce (12) meses de vigencia de este contrato, con notificación previa a EL MIEMBRO con un mínimo de treinta (30) días calendario.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA QUINTA: ",fontSize);
    pc.addCols("EL MIEMBRO podrá solicitar la inclusión de dependientes elegibles adicionales en este Contrato, sujeto a la aprobación de los mismos por EL HOSPITAL. Para los efectos, se firmarán documentos adicionales, incluyendo la Declaración de Salud y se harán los ajustes necesarios en la cuota mensual que deberá pagar EL MIEMBRO al HOSPITAL.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA SEXTA: ",fontSize);
    pc.addCols("EL MIEMBRO acepta que EL HOSPITAL en cualquier momento podrá cambiar la Lista de Médicos y Hospitales Afiliados, siempre con la intención de ofrecer mejores y mayores servicios a EL MIEMBRO y sus dependientes. Es obligación de EL MIEMBRO mantenerse informado sobre la Lista actualizada.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA SEPTIMA: ",fontSize);
    pc.addCols("EL HOSPITAL descontinuará los servicios médicos y hospitalarios a algún cónyuge que pierda su elegibilidad por efecto de dejar de ser cónyuge de EL MIEMBRO o haber cumplido los sesenta años de edad.  Igualmente, EL HOSPITAL descontinuará los servicios a cualquier hijo mencionado en la Cláusula Primera que pierda su elegibilidad por efecto de haber llegado a los 19 años de edad, haber contraído matrimonio, haber dejado de convivir bajo el mismo techo o haber cesado la dependencia económica con EL MIEMBRO. Este último queda obligado a informar a EL HOSPITAL inmediatamente cuando algún dependiente haya perdido su elegibilidad.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA OCTAVA: ",fontSize);
    pc.addCols("EL HOSPITAL podrá en cualquier momento hacer cambios en los servicios médicos y hospitalarios que ofrece EL PLAN mediante modificaciones o adiciones a EL FOLLETO.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("DECIMA NOVENA: ",fontSize);
    pc.addCols("Las comunicaciones entre las partes se realizarán en el domicilio social de EL HOSPITAL, en la VIA BOLIVAR y AVENIDA FRANGIPANI.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("VIGESIMA: ",fontSize);
    pc.addCols("Si EL MIEMBRO es lesionado a causa de imprudencia o negligencia de una tercera persona, EL MIEMBRO acuerda subrogar a EL HOSPITAL cualquier indemnización o derecho a indemnización que tenga contra la tercera persona, hasta cubrir los gastos en que ha incurrido EL HOSPITAL en la atención médico-hospitalaria de EL MIEMBRO lesionado, más los gastos legales y otros que ocasione la recuperación de dicha indemnización; y se compromete a cooperar con y asistir a EL HOSPITAL para efectuar la recuperación de la indemnización.",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("VIGESIMA PRIMERA: ",fontSize);
    pc.addCols("EL MIEMBRO acepta que EL HOSPITAL no prestará servicios médicos y hospitalarios de EL PLAN directamente o indirectamente relacionados con las siguientes condiciones, ni con ninguna otra condición preexistente:",3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());

     Vector diagT = new Vector();
	diagT.addElement("22");
	diagT.addElement("43");
	diagT.addElement("35");

    pc.setNoColumnFixWidth(diagT);
      pc.createTable("diagnosticos");



        pc.setFont(fontSize,0);
        for (int n=0; n<alD.size(); n++){
					CommonDataObject cdoD = (CommonDataObject) alD.get(n);
					pc.setFont(fontSize,0);
					pc.addCols("Nombre Completo:",0,1);
					pc.setFont(fontSize,1);
					pc.addBorderCols(cdoD.getColValue("client_name", " "),1,2,0.5f,0.0f,0.0f,0.0f);
					pc.setFont(fontSize,0);
					pc.addCols("Exclusion Diagnostico:",0,1);
					pc.addCols(cdoD.getColValue("diagnostico"),0,2);
					pc.addCols("Exclusion Medicamento:",0,1);
					pc.addCols(cdoD.getColValue("medicamento"),0,2);
        }

      pc.useTable("main");
      pc.addTableToCols("diagnosticos",0,setDetail.size(), 0, Color.white, Color.black, 0.5f, 0.5f, 0.5f, 0.5f);

		pc.flushTableBody(true);
    //pc.addNewPage();
		//pc.addCols(" ",0,setDetail.size());
    pc.setBoldChunk("OBSERVACION: ",fontSize);
    pc.addCols(cdo.getColValue("observacion"),3,setDetail.size());
		pc.addCols(" ",0,setDetail.size());
    pc.setFont(fontSize,1);
    pc.addCols("En fé de lo cual, las partes suscriben el presente Contrato, en dos (2) ejemplares del mismo tenor y efecto, en la Ciudad de Panamá, República de Panamá, el "+cdo.getColValue("dsp_date"),3,setDetail.size());

    pc.addCols(" ",0,setDetail.size());
    pc.addCols(" ",0,setDetail.size());

    pc.addCols("EL HOSPITAL",0,3);
    pc.addCols(" ",0,1);
    pc.addCols("EL MIEMBRO",1,3);

    pc.addCols(" ",0,setDetail.size());
    pc.addCols(" ",0,setDetail.size());

    pc.setFont(fontSize,0);
    pc.addBorderCols("Cédula: ",0,3,0.0f,0.5f,0.0f,0.0f);
    pc.addCols(" ",0,1);
    pc.addBorderCols("Cédula: "+cdo.getColValue("cedula"),0,3,0.0f,0.5f,0.0f,0.0f);




    pc.addCols(" ",0,setDetail.size());

	//pc.setTableHeader(3);



	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>