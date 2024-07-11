<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<%@ page import="issi.admision.Admision" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
String compania = (String) session.getAttribute("_companyId");
String lng = request.getParameter("lng");
String consentTitle = request.getParameter("consentTitle");
String consentName = request.getParameter("consentName");

String sql = "";
if (consentTitle == null) consentTitle = "";
if (consentName == null) consentName = "";
if (consentTitle.trim().equals("")) consentTitle = consentName;
if (lng == null) lng = "es";

CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
Admision adm = new Admision();

sql="Select nvl(get_sec_comp_param(a.compania,'ADM_PATIENT_SIGNATURE'),'N') as pase, b.sexo, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),null) as paseK, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),'mm') as plan, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),'dd') as convenio,to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, nvl(decode(a.corte_cta,null,to_char(a.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id)),' ')as fechaIngreso, to_char(a.fecha_ingreso,'dd/mm/yyyy') fechaIngresoActiva, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi:ss am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, nvl(to_char(a.am_pm,'hh12:mi:ss am'),' ') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, decode(b.provincia,null,' ',b.provincia) as provincia, DECODE(b.nacionalidad, null,' ',(SELECT NACIONALIDAD FROM tbl_sec_pais WHERE CODIGO=b.nacionalidad)) as nacionalidad, decode(b.zona_postal,null,' ',b.zona_postal) as zonaPostal, decode(b.apartado_postal,null,' ',b.apartado_postal) as apartadoPostal, decode(b.residencia_direccion,null,' ',b.residencia_direccion) as direccion, decode(b.telefono,null,' ',b.telefono) as telefonoResidencia, decode(b.lugar_nacimiento,null,' ',b.lugar_nacimiento) as lugarNac, coalesce(b.telefono_urgencia,b.telefono_trabajo_urgencia,' ') as comunidad , decode(b.lugar_trabajo,null, ' ',b.lugar_trabajo) as lugarDeTrabajo, decode(b.PERSONA_DE_URGENCIA,null,' ',b.PERSONA_DE_URGENCIA) as parentesco, nvl(b.extension_oficina,' ') as extension, nvl(b.telefono_trabajo,' ') as telefonoDeTrabajo, decode(b.fax,null,' ',b.fax) as fax, DECODE(b.religion,0,' ',(SELECT DESCRIPCION from TBL_ADM_RELIGION where codigo=b.religion)) as cama, nvl(b.sigla,' ') as sigla, decode(b.tomo,null,' ',b.tomo) as tomo, decode(b.asiento,null,' ',b.asiento) as asiento, nvl(b.d_cedula,' ') as dCedula, nvl(b.pasaporte,' ') as pasaporte,b.tipo_id_paciente as vip, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, getResponsable(a.pac_id,a.secuencia) as responsabilidad /*responsabilidad*****/, b.nombre_paciente as nombrePaciente, decode(b.estado_civil,'CS','CASADO','DV','DIVORCIADO','SP','SEPARADO','ST','SOLTERO','UN','UNIDO','VD','VIUDO') estadoCivilDesc, b.estado_civil estadoCivil, b.puesto_que_ocupa puestoQueOcupa,  c.descripcion as categoriaDesc, d.descripcion as tipoAdmisionDesc, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' DE '||e.apellido_de_casada)) as nombreMedico, e.especialidad, decode(f.primer_nombre,null,' ',f.primer_nombre||decode(f.segundo_nombre,null,'',' '||f.segundo_nombre)||' '||f.primer_apellido||decode(f.segundo_apellido,null,'',' '||f.segundo_apellido)||decode(f.sexo,'F',decode(f.apellido_de_casada,null,'',' '||f.apellido_de_casada))) as nombreMedicoCabecera, g.descripcion as centroServicioDesc,(select nvl((select case when total >= 25 then 'Y' else 'N' end from tbl_sal_escalas  where pac_id = a.pac_id and admision = a.secuencia and tipo = 'MO' and rownum = 1),a.condicion_paciente) from dual) as condicionPaciente, (select rrr.seguro_social from tbl_adm_responsable rrr where rrr.pac_id = a.pac_id and rrr.admision = a.secuencia and rrr.estado = 'A' and rownum = 1) as seguroSocial, (select rrr.telefono_residencia from tbl_adm_responsable rrr where rrr.pac_id = a.pac_id and rrr.admision = a.secuencia and rrr.estado = 'A' and rownum = 1) as responsableTelResidencia, (select  aa.poliza||'@@'||ee.nombre from tbl_adm_beneficios_x_admision aa, tbl_adm_empresa ee where aa.empresa = ee.codigo and aa.admision=a.secuencia and aa.pac_id=a.pac_id and aa.estado = 'A' and aa.prioridad = 1 and rownum = 1) empresa     from tbl_adm_admision a, vw_adm_paciente b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d, (select x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl(z.descripcion,'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) e, tbl_adm_medico f, tbl_cds_centro_servicio g where a.pac_id=b.pac_id and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and a.medico=e.codigo and a.medico_cabecera=f.codigo(+) and a.centro_servicio=g.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id="+pacId+" and a.secuencia="+noAdmision;
System.out.println("SQL   ---   admision:\n"+sql);
adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Admision.class);

if ( cdo == null ) cdo = new CommonDataObject();

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String title = "CONSENTIMIENTO";
	String subTitle = "DEBERES Y DERECHOS";
	String xtraSubtitle = "";
	
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 90.0f;
	
	Vector tblImg = new Vector();
	tblImg.addElement(".20");
	tblImg.addElement(".40");
	tblImg.addElement(".40");
	
	Vector dHeader = new Vector();
    
	dHeader.addElement(".05");
	dHeader.addElement(".75");
	dHeader.addElement(".10"); 
	dHeader.addElement(".10"); 
		
	Vector tblTopInfo = new Vector();
	tblTopInfo.addElement(".40");
	tblTopInfo.addElement(".60");
	
	Vector nHeader = new Vector();
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	nHeader.addElement(".10");
	
	PdfCreator pc=null;
	boolean isUnifiedExp=false;
	pc = (PdfCreator) session.getAttribute("printConsentUnico");
	if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
	isUnifiedExp=true;}
		
	pc.setNoColumnFixWidth(tblTopInfo);
	pc.createTable("tblTopInfo",false, 0, 0.0f, 230f);
		pc.addBorderCols("Código", 2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("IMG-DO-01", 1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Versión", 2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("01", 1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Fecha de Ingreso", 2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getFechaIngreso(), 1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Hora de Ingreso", 2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getAmPm(), 1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("P-ID", 2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(pacId+"-"+noAdmision, 1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Médico", 2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getNombreMedico(), 1,1,0.1f,0.1f,0.1f,0.1f);

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	
	pc.setFont(11, 0);
	pc.addCols(" ",2,dHeader.size());
	
	pc.resetFont();
	
	pc.setNoColumnFixWidth(tblImg);
	pc.createTable("tblImg",false,0,0.0f,553f);
	   pc.setVAlignment(0);
	   pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);
	   
	   pc.addCols(consentTitle, 1,1);
	   
	   pc.useTable("tblImg");
	   pc.addTableToCols("tblTopInfo",1,1,0.0f);
	   
	pc.useTable("main");
	pc.addTableToCols("tblImg",0,dHeader.size(),0,null,null,0.0f,0.0f,0.0f,0.0f);
	
	pc.setNoColumnFixWidth(nHeader);
			pc.createTable("NewHeader");

		//displaying tblTitle
		//String tableName, int hAlign, int colSpan, float height
		pc.useTable("NewHeader");
		pc.addTableToCols("tblTitle",1,nHeader.size(),0.0f);

		pc.addCols("",0,nHeader.size());
		pc.addCols("Cat. Adm.",0,1);
		pc.addCols(adm.getCategoriaDesc(),0,2,8.0f);
		pc.addCols("Tipo Adm.",1,1);
		pc.addCols(adm.getTipoAdmisionDesc(),0,3,8.0f);
		pc.addCols("Área Adm.",1,1);
		pc.addCols(adm.getCentroServicioDesc(),0,2,8.0f);

		pc.setFont(8,1,Color.white);
		pc.addCols("",0,nHeader.size());
		pc.addCols("I.DATOS DE IDENTIFICACÍON DEL PACIENTE",1,nHeader.size(),Color.lightGray);
		pc.setFont(7,0);

		pc.addBorderCols("Nombre",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getNombrePaciente(),0,4,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("Sexo",1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(((adm.getSexo().equalsIgnoreCase("F"))?"FEMENINO":"MASCULINO"),1,1,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("N°Identif",1,1,0.1f,0.1f,0.1f,0.1f);
		if(adm.getVIP()!=null && adm.getVIP().equals("P"))  pc.addBorderCols(adm.getPasaporte(),0,2,0.1f,0.1f,0.1f,0.1f,8.0f);
		else pc.addBorderCols(adm.getProvincia()+"-"+adm.getSigla()+"-"+adm.getTomo()+"-"+adm.getAsiento()+"-"+adm.getDCedula(),0,2,0.1f,0.1f,0.1f,0.1f,8.0f);

		pc.addBorderCols("Edad",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getPaseK()+" A "+adm.getPlan()+" M "+adm.getConvenio()+" D",1,2,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("F.Nac.",1,1,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols(adm.getFechaNacimiento(),1,1,0.1f,0.1f,0.1f,0.1f,8.0f);

		pc.addBorderCols("E.Civil",1,1,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols(adm.getEstadoCivilDesc() ,1,2,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("Tel.",1,1,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols(adm.getTelefonoResidencia()  ,1,1,0.1f,0.1f,0.1f,0.1f,8.0f);

		pc.addBorderCols("Dirección",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getDireccion() ,0,9,0.1f,0.1f,0.1f,0.1f,8.0f);

		String insData[] = {};
		String insComp = "", pol = "";
		try{
			insData = adm.getEmpresa().split("@@");
			insComp = insData[1];
			pol = insData[0];
		}catch(Exception ee){insComp = ""; pol = "";}

		pc.addBorderCols("Cía Aseg.",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(insComp,0,3,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("Estudio a Realizar",0,2,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("",0,4,0.1f,0.1f,0.1f,0.1f,8.0f);

		pc.addBorderCols("Responsable",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getResponsabilidad(),0,9,0.1f,0.1f,0.1f,0.1f,8.0f);

		pc.addCols(" ",1,nHeader.size());

	//table header
	pc.useTable("main");
	pc.addTableToCols("NewHeader",1,dHeader.size(),0.0f);
	
	pc.addCols(" ",1,dHeader.size());
    
    int fontsize = 11;
	
	pc.setFont(fontsize,1);
	pc.setVAlignment(0);
	pc.addBorderCols("Motivo para realizarse el estudio y/o síntomas:",0,dHeader.size(), 0.1f,0.1f,0.1f,0.1f,50.0f);

	pc.addCols(" ",1,dHeader.size());
	
	pc.setFont(fontsize, 0);
	pc.addBorderCols("1. Anteriormente le han realizado alguna cirugía (artroscopía, endoscopía, etc.)?",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 1);
	pc.addBorderCols("Si respondió afirmativamente, indique la fecha y tipo de cirugía:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
	pc.setFont(fontsize, 0);
	pc.addBorderCols("Tipo de Cirugía:",0, dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Fecha: ",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Tipo de Cirugía:",0, dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Fecha: ",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 0);
	pc.addBorderCols("2. Anteriormente le han realizado estudios de diagnóstico (RM, CT, Ultrasonido, rayos X)",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 1);
	pc.setVAlignment(0);
	pc.addBorderCols("Si respondió afirmativamente, descríbalos a continuación:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f, 30f);

	pc.setFont(fontsize, 0);
	pc.addBorderCols("3. Ha tenido algún problema relacionado con estudios o procedimientos anteriores con resonancia magnética?",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 1);
	pc.setVAlignment(0);
	pc.addBorderCols("Sí respondió afirmativamente, descríbalos:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f, 30f);
	
	pc.setFont(fontsize, 0);
	pc.addBorderCols("4. Sufre de alguno de los siguientes trastornos:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("                  Claustrofobia:",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("                  Trastorno de la respiración",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("                  Trastorno del movimiento",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 0);
	pc.addBorderCols("5. Se ha golpeado con objetos o fragmentos metálicos (astillas metálicas, virutas, cuerpos extraños, balas, perdigones)?",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 1);
	pc.setVAlignment(0);
	pc.addBorderCols("Si respondió afirmativamente, describa el incidente:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f, 30f);
	
	pc.setFont(fontsize, 0);
	pc.addBorderCols("6. Está tomando actualmente algún tipo de medicamento?",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 1);
	pc.setVAlignment(0);
	pc.addBorderCols("Si respondió afirmativamente, indique los medicamentos:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f, 40f);
	
	
	pc.setFont(fontsize, 0);
	pc.setVAlignment(0);
	pc.addBorderCols("7. Tiene historia de reacción alérgica o reacciones alérgicas a medios de contraste utilizados en resonancia magnética o tomografía",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.setFont(fontsize, 1);
	pc.setVAlignment(0);
	pc.addBorderCols("Si respondió afirmativamente, descríbala:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f, 40f);

	pc.setFont(fontsize, 0);
	pc.setVAlignment(0);
	pc.addBorderCols("8. Tiene alguna enfermedad que afecte su riñón",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.setFont(fontsize, 1);
	pc.setVAlignment(0);
	pc.addBorderCols("Si respondió afirmativamente, descríbala:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f, 40f);

	pc.addCols(" ",1,dHeader.size());
	
	pc.setFont(fontsize, 1);
	pc.setVAlignment(0);
	pc.addBorderCols("El estudio de Resonancia Magnética (RM) es una técnica de imagen que combina la acción de un potente campo magnético creado por un imán con la aplicación de ondas de radiofrecuencia.\nCiertos implantes, dispositivos u objetos metálicos pueden ser peligrosos y/o pueden interferir con el estudio de resonancia magnética.\nAntes de entrar a la sala del equipo debe quitarse todo objeto metálico, aparatos electrónicos incluyendo relojes, teléfonos, joyas, tarjetas bancarias o magnéticas, monedas, lentes, bolígrafos, cuchillos.\nEn caso de tener alguna pregunta o duda relacionada con algún objeto, implante o dispositivo debe consultar con el Médico Radiólogo o Técnico de Resonancia Magnética antes de entrar a la sala del equipo.",3,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
	pc.setFont(fontsize, 1, Color.RED);
	pc.addBorderCols("Advertencia:   El equipo de resonancia magnética siempre tiene el imán encendido",3,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
	
	pc.setFont(fontsize, 1);
	pc.addCols(" ",0,dHeader.size());
	pc.addCols("      Para las pacientes de sexo femenino:",0,dHeader.size());
	
	pc.setFont(fontsize, 0);
	pc.addBorderCols("Fecha de su último periodo menstrual",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Fecha:",0,2,0.1f,0.1f,0.1f,0.1f);
	
	pc.addBorderCols("Está embarazada o tiene retraso del período",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.addBorderCols("Está amamantando a su bebé",0,dHeader.size()-2,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.addCols(" ",0,dHeader.size());
	
	pc.setFont(fontsize, 1);
	pc.addBorderCols("Indique si tiene alguno de los siguientes dispositivos en su cuerpo:",0,dHeader.size(),0.1f,0.1f,0.1f,0.1f);
	pc.setFont(fontsize, 0);
	
	pc.addBorderCols("1.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Algún tipo de prótesis, implante o dispositivo electrónico",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("2.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Articulaciones artificiales (rodillas, cadera)",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("3.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Bomba de infusión de insulina",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("4.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Implante coclear u otro implante del oído",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("5.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Catéter de acceso vascular",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("6.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Clip de aneurisma",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("7.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Cualquier cuerpo o fragmento metálico",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("8.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Dentaduras o placas parciales",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("9.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Dispositivo implantado para infusión de medicamento",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("10.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Dispositivo intrauterino",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("11.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Electrodos o alambres internos",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("12.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Estimulador de crecimiento/fusión de huesos",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("13.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Grapas quirúrgicas",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("14.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Implante o dispositivo activado magnéticamente",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);
	
	pc.addBorderCols("15.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Implante con desfibrilador para conversión cardiaca",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("16.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Marcapasos cardiaco",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("17.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Malla metálica",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("18.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Parche de medicamentos",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("19.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Perforación o piercings",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("20.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Placas, tornillos o alambres",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("21.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Prótesis de reemplazo valvular cardiaca",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("22.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Semillas o implantes de radiación",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("23.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sistema de neuroestimulación",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.addBorderCols("24.",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Tatuaje o maquillaje permanente",0,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("Sí",1,1,0.1f,0.1f,0.1f,0.1f);
	pc.addBorderCols("No",1,1,0.1f,0.1f,0.1f,0.1f);

	pc.flushTableBody(true);
	pc.addNewPage();
	
	pc.addCols(" ",2,dHeader.size());
	pc.addCols("",1,dHeader.size());
	
	pc.addCols("Leído y entendido el contenido de este cuestionario y habiendo tenido la oportunidad de aclarar cualquier duda con relación a la información de este y sobre el estudio de Resonancia Magnética al que me voy a someter, afirmo que toda la información suministrada por mi persona es correcta.",0,dHeader.size());
	
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("Nombre: _________________________________________	Firma: _________________________",0,dHeader.size());
	
	pc.addCols(" ",1,dHeader.size());
	
	pc.setFont(fontsize, 1);
	pc.addCols("En caso de no ser el paciente:",0,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	
	pc.setFont(fontsize, 0);
	pc.addCols("Nombre Completo:",0,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("____________________________________________________________________________________",0,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	
	pc.addCols("Parentesco: _________________________________________	Firma: _________________________",0,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("",1,dHeader.size());
	pc.addCols("Revisado por: _________________________________________	Firma: _________________________",0,dHeader.size());
	
	pc.addCols(" ",1,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	pc.addCols(" ",1,dHeader.size());
	pc.addCols("Este documento es propiedad del "+_comp.getNombre()+". El uso de terceras personas está prohibido sin autorización escrita.",1,dHeader.size());
	
	pc.addTable();
	if(isUnifiedExp){pc.close();
	response.sendRedirect(redirectFile);}
//}
%>