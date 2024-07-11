<%@ page errorPage="../error.jsp"%>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admision.Admision"%>
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
Reporte adm_boleta2
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
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject(); // para datos de la orden de salida si hay una registrada

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fp = request.getParameter("fp");
String sql = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
Admision adm = new Admision();
ArrayList alHab = new ArrayList();
ArrayList alDiagI = new ArrayList();
ArrayList alDiagE = new ArrayList();
ArrayList alDoc = new ArrayList();
ArrayList alBenef = new ArrayList();
ArrayList alRespon = new ArrayList();

if (fp==null) fp = "";

sql="Select nvl(get_sec_comp_param(a.compania,'ADM_PATIENT_SIGNATURE'),'N') as pase, b.sexo, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),null) as paseK, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),'mm') as plan, get_age(b.f_nac,nvl(a.fecha_ingreso,a.fecha_creacion),'dd') as convenio,to_char(b.f_nac,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, nvl(decode(a.corte_cta,null,to_char(a.fecha_ingreso,'dd/mm/yyyy'), busca_f_ingreso(to_char(a.fecha_ingreso,'dd/mm/yyyy') ,a.secuencia,a.pac_id)),' ')as fechaIngreso, to_char(a.fecha_ingreso,'dd/mm/yyyy') fechaIngresoActiva, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi:ss am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, nvl(to_char(a.am_pm,'hh12:mi:ss am'),' ') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, decode(b.provincia,null,' ',b.provincia) as provincia, DECODE(b.nacionalidad, null,' ',(SELECT NACIONALIDAD FROM tbl_sec_pais WHERE CODIGO=b.nacionalidad)) as nacionalidad, decode(b.zona_postal,null,' ',b.zona_postal) as zonaPostal, decode(b.apartado_postal,null,' ',b.apartado_postal) as apartadoPostal, decode(b.residencia_direccion,null,' ',b.residencia_direccion) as direccion, decode(b.telefono,null,' ',b.telefono) as telefonoResidencia, decode(b.lugar_nacimiento,null,' ',b.lugar_nacimiento) as lugarNac, coalesce(b.telefono_urgencia,b.telefono_trabajo_urgencia,' ') as comunidad , decode(b.lugar_trabajo,null, ' ',b.lugar_trabajo) as lugarDeTrabajo, decode(b.PERSONA_DE_URGENCIA,null,' ',b.PERSONA_DE_URGENCIA) as parentesco, nvl(b.extension_oficina,' ') as extension, nvl(b.telefono_trabajo,' ') as telefonoDeTrabajo, decode(b.fax,null,' ',b.fax) as fax, DECODE(b.religion,0,' ',(SELECT DESCRIPCION from TBL_ADM_RELIGION where codigo=b.religion)) as cama, nvl(b.sigla,' ') as sigla, decode(b.tomo,null,' ',b.tomo) as tomo, decode(b.asiento,null,' ',b.asiento) as asiento, nvl(b.d_cedula,' ') as dCedula, nvl(b.pasaporte,' ') as pasaporte,b.tipo_id_paciente as vip, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, getResponsable(a.pac_id,a.secuencia) as responsabilidad /*responsabilidad*****/, b.nombre_paciente as nombrePaciente, decode(b.estado_civil,'CS','CASADO','DV','DIVORCIADO','SP','SEPARADO','ST','SOLTERO','UN','UNIDO','VD','VIUDO') estadoCivilDesc, b.estado_civil estadoCivil, b.puesto_que_ocupa puestoQueOcupa,  c.descripcion as categoriaDesc, d.descripcion as tipoAdmisionDesc, e.primer_nombre||decode(e.segundo_nombre,null,'',' '||e.segundo_nombre)||' '||e.primer_apellido||decode(e.segundo_apellido,null,'',' '||e.segundo_apellido)||decode(e.sexo,'F',decode(e.apellido_de_casada,null,'',' DE '||e.apellido_de_casada)) as nombreMedico, e.especialidad, decode(f.primer_nombre,null,' ',f.primer_nombre||decode(f.segundo_nombre,null,'',' '||f.segundo_nombre)||' '||f.primer_apellido||decode(f.segundo_apellido,null,'',' '||f.segundo_apellido)||decode(f.sexo,'F',decode(f.apellido_de_casada,null,'',' '||f.apellido_de_casada))) as nombreMedicoCabecera, g.descripcion as centroServicioDesc,(select nvl((select case when total >= 25 then 'Y' else 'N' end from tbl_sal_escalas  where pac_id = a.pac_id and admision = a.secuencia and tipo = 'MO' and rownum = 1),a.condicion_paciente) from dual) as condicionPaciente, (select rrr.seguro_social from tbl_adm_responsable rrr where rrr.pac_id = a.pac_id and rrr.admision = a.secuencia and rrr.estado = 'A' and rownum = 1) as seguroSocial, (select rrr.telefono_residencia from tbl_adm_responsable rrr where rrr.pac_id = a.pac_id and rrr.admision = a.secuencia and rrr.estado = 'A' and rownum = 1) as responsableTelResidencia, (select  aa.poliza||'@@'||ee.nombre from tbl_adm_beneficios_x_admision aa, tbl_adm_empresa ee where aa.empresa = ee.codigo and aa.admision=a.secuencia and aa.pac_id=a.pac_id and aa.estado = 'A' and aa.prioridad = 1 and rownum = 1) empresa     from tbl_adm_admision a, vw_adm_paciente b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d, (select x.codigo, x.primer_nombre, x.segundo_nombre, x.primer_apellido, x.segundo_apellido, x.apellido_de_casada, x.sexo, nvl(z.descripcion,'NO TIENE') as especialidad from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) e, tbl_adm_medico f, tbl_cds_centro_servicio g where a.pac_id=b.pac_id and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and a.medico=e.codigo and a.medico_cabecera=f.codigo(+) and a.centro_servicio=g.codigo and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id="+pacId+" and a.secuencia="+noAdmision;
System.out.println("SQL   ---   admision:\n"+sql);
adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Admision.class);

//------------------------------------ Tab Habilitaciones y Cama  ----------------------------------------------
sql = "select a.codigo, a.cama, a.habitacion, to_char(a.fecha_inicio,'dd/mm/yyyy') as fechaInicio, to_char(a.hora_inicio,'hh12:mi am') as horaInicio, nvl(a.precio_alt,'N') as precioAlt, a.precio_alterno as precioAlterno, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, c.unidad_admin as centroServicio, d.descripcion as centroServicioDesc, e.precio, e.descripcion||' - '||decode(e.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','O','OTROS','E','ECONOMICA','T','SUITE','Q','QUIROFANO','C','COMPARTIDA') as habitacionDesc from tbl_adm_cama_admision a, tbl_sal_cama b, tbl_sal_habitacion c, tbl_cds_centro_servicio d, tbl_sal_tipo_habitacion e where a.compania=b.compania and a.habitacion=b.habitacion and a.cama=b.codigo and a.compania=c.compania and a.habitacion=c.codigo and c.unidad_admin=d.codigo and a.compania=e.compania and b.tipo_hab=e.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss')";
System.out.println("SQL    ---    habitaciones y camas:\n"+sql);
alHab  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);

//--------------------------------------   Tab de Diagnostico  --------------------------------------------------
sql = "select a.diagnostico, a.tipo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.orden_diag as ordenDiag, coalesce(b.observacion,b.nombre) as diagnosticoDesc, nvl(a.icd10,' ') as icd10 from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.tipo='I' and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by a.orden_diag";
System.out.println("SQL   ---   diagnosticos ingreso:\n"+sql);
alDiagI  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);

sql = "select a.diagnostico, a.tipo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.orden_diag as ordenDiag, coalesce(b.observacion,b.nombre) as diagnosticoDesc, nvl(a.icd10,' ') as icd10 from tbl_adm_diagnostico_x_admision a, tbl_cds_diagnostico b where a.diagnostico=b.codigo and a.tipo='S' and a.admision="+noAdmision+" and a.pac_id="+pacId+" order by a.orden_diag";
System.out.println("SQL   ---    diagnosticos salida:\n"+sql);
alDiagE  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);

// -------------------------------------------- Tab de Beneficios  ---------------------------------------
sql = "select a.secuencia, a.poliza, nvl(a.certificado,' ') as certificado, nvl(a.convenio_solicitud,'C') as convenioSolicitud, nvl(a.convenio_sol_emp,'N') as convenioSolEmp, prioridad, decode(a.plan,null,' ',a.plan) as plan, decode(a.convenio,null,' ',a.convenio) as convenio, a.empresa, decode(a.categoria_admi,null,' ',a.categoria_admi) as categoriaAdmi, decode(a.tipo_admi,null,' ',a.tipo_admi) as tipoAdmi, decode(a.clasif_admi,null,' ',a.clasif_admi) as clasifAdmi, decode(a.tipo_poliza,null,' ',a.tipo_poliza) as tipoPoliza, decode(a.tipo_plan,null,' ',a.tipo_plan) as tipoPlan, to_char(nvl(a.fecha_ini,sysdate),'dd/mm/yyyy hh24:mi:ss') as fechaIni, nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaFin, nvl(a.usuario_creacion,' ') as usuarioCreacion, nvl(a.usuario_modificacion,' ') as usuarioModificacion, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaModificacion, nvl(a.estado,' ') as estado, decode(a.num_aprobacion,null,' ',a.num_aprobacion) as numAprobacion, b.tipo_poliza as tipoPoliza, b.tipo_plan as tipoPlan, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, e.nombre as nombreTipoPlan, f.nombre as nombreTipoPoliza, g.descripcion as clasifAdmiDesc, h.descripcion as tipoAdmiDesc, i.descripcion as categoriaAdmiDesc from tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and c.empresa=d.codigo and b.tipo_plan=e.tipo_plan and b.tipo_poliza=e.poliza and b.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo and a.admision="+noAdmision+" and a.pac_id="+pacId+" and a.estado = 'A' order by a.secuencia, a.prioridad, a.empresa, a.convenio, a.plan, a.categoria_admi, a.tipo_admi, a.clasif_admi";
System.out.println("SQL   ---   beneficios:\n"+sql);
alBenef  = sbb.getBeanList(ConMgr.getConnection(),sql,Admision.class);

// -------------------------------------- Datos de orden de salida  ---------------------------------------------------------
sql = "select a.codigo ordenMed,to_char(a.fecha,'dd/mm/yyyy') fechaOrden,a.tipo_salida tipoSalida, decode(nvl(a.relevo,'N'),'S','SI','NO') relevo, u.ref_code reg_medico, u.name nombre_usuario  from tbl_sal_orden_medica a, tbl_sal_detalle_orden_med b, tbl_sec_users u where a.pac_id=b.pac_id and a.secuencia = b.secuencia and a.codigo = b.orden_med and b.estado_orden in ('A','F') and u.user_name = b.usuario_creacion and b.tipo_orden = 7  and a.pac_id = "+pacId+" and a.secuencia="+noAdmision+"  and b.codigo = 1";
System.out.println("SQL  --- datos de salida:\n"+sql);
cdo2 = SQLMgr.getData(sql);
if (cdo2 == null) cdo2 = new CommonDataObject();

//CommonDataObject xtraData = SQLMgr.getData("select nombre from tbl_adm_responsable where pac_id = "+pacId+" and admision="+noAdmision+" and estado ='A'");

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
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
	String title = "ADMISION";
	String subtitle = "DATOS DEL PACIENTE";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
	//PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	//------------------------------------------------------------------------------------
	PdfCreator pc = null;
	boolean isUnifiedExp = false;
	pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
	if (pc == null)
	{
		pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
		isUnifiedExp = true;
	}

	Vector dHeader = new Vector();
		dHeader.addElement(".12");
		dHeader.addElement(".23");
		dHeader.addElement(".12");
		dHeader.addElement(".23");
		dHeader.addElement(".10");
		dHeader.addElement(".20");

	Vector infoCol = new Vector();
		infoCol.addElement(".16");
		infoCol.addElement(".14");
		infoCol.addElement(".11");
		infoCol.addElement(".10");
		infoCol.addElement(".14");
		infoCol.addElement(".35");
	Vector setHab = new Vector();
		setHab.addElement(".04");
		setHab.addElement(".07");
		setHab.addElement(".08");
		setHab.addElement(".25");
		setHab.addElement(".25");
		setHab.addElement(".08");
		setHab.addElement(".10");
		setHab.addElement(".13");
	Vector setDiagI = new Vector();
		setDiagI.addElement(".20");
		setDiagI.addElement(".20");
		setDiagI.addElement(".60");
	Vector setDiagE = new Vector();
		setDiagE.addElement(".20");
		setDiagE.addElement(".20");
		setDiagE.addElement(".60");
	Vector setBenef = new Vector();
		setBenef.addElement(".35");
		setBenef.addElement(".15");
		setBenef.addElement(".15");
		setBenef.addElement(".25");
		setBenef.addElement(".10");
	Vector setCpt = new Vector();
		setCpt.addElement(".17");
		setCpt.addElement(".03");
		setCpt.addElement(".60");
		setCpt.addElement(".03");
		setCpt.addElement(".17");
	Vector setFooter = new Vector();
		setFooter.addElement(".18");
		setFooter.addElement(".02");
		setFooter.addElement(".13");
		setFooter.addElement(".02");
		setFooter.addElement(".13");
		setFooter.addElement(".02");
		setFooter.addElement(".11");
		setFooter.addElement(".39");
	Vector setBox = new Vector();
		setBox.addElement("8");

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

		Vector tblTitle = new Vector();
		tblTitle.addElement(".20");
		tblTitle.addElement(".40");
		tblTitle.addElement(".40");

		Vector tblRightInfo = new Vector();
		tblRightInfo.addElement(".40");
		tblRightInfo.addElement(".60");

		String strResponsable = "";
		if (adm.getResponsabilidad().equals("P")) strResponsable = "PACIENTE"; else if(adm.getResponsabilidad().equals("O")) strResponsable = "OTRA EMPRESA"; else  strResponsable = "EMPRESA";

		//String tableName, boolean splitRowOnEndPage, int showBorder, float margin, float tableWidth
		pc.setNoColumnFixWidth(tblRightInfo);
		pc.createTable("tblRightInfo",false,0,0.0f,230.0f);


		String selVal = "";
		if (adm.getCondicionPaciente() != null && (adm.getCondicionPaciente().equalsIgnoreCase("Y") || adm.getCondicionPaciente().equalsIgnoreCase("S"))) {
			selVal = "*** PACIENTE CON RIESGO DE CAIDA ***";
		}

		if (!selVal.equals("")){
			pc.setFont(8,1,Color.red);
			pc.addBorderCols(selVal,1,2,0.1f,0.1f,0.1f,0.1f);
			pc.resetFont();
		}

		pc.addBorderCols("Fecha Ingreso ",2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getFechaIngreso(),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Hora Ingreso ",2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getAmPm(),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("Usuario de Admisión",2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getUsuarioCreacion(),0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("No. de Recibo ",2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(" ",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols("P-ID ",2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getPacId()+"-"+adm.getNoAdmision(),0,1,0.1f,0.1f,0.1f,0.1f);

		String medName = fp.equals("CUSTOM")?" ":adm.getNombreMedico();

		pc.addBorderCols("Médico ",2,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(medName,0,1,0.1f,0.1f,0.1f,0.1f);

		pc.setNoColumnFixWidth(tblTitle);
		pc.createTable("tblTitle");
		pc.addImageCols(companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif"),30.0f,1);

				cdo1 = SQLMgr.getData("select get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'CUS_BOLETA_TITULO')boleta_titulo from dual ");

				if (cdo1 == null) {
					cdo1 = new CommonDataObject();
					cdo1.addColValue("boleta_titulo", "");
				}

		pc.addCols(_comp.getNombre()+(cdo1.getColValue("boleta_titulo") != null && (cdo1.getColValue("boleta_titulo").equals("Y") || cdo1.getColValue("boleta_titulo").equals("S"))?"\nBOLETA DE ADMISION\n":"\nHOJA DE ATENCIÓN\n"),1,1);
		pc.useTable("tblTitle");
		pc.addTableToCols("tblRightInfo",1,1,0.0f);

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

		pc.addBorderCols("Ocupación",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getPuestoQueOcupa(),0,4,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("Lugar de Trabajo",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getLugarDeTrabajo(),0,4,0.1f,0.1f,0.1f,0.1f,8.0f);

		String insData[] = {};
		String insComp = "", pol = "";
		try{
			insData = adm.getEmpresa().split("@@");
			insComp = insData[1];
			pol = insData[0];
		}catch(Exception ee){insComp = ""; pol = "";}

		pc.addBorderCols("Cía Aseg.",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(insComp,0,7,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("Póliza",1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(pol,0,1,0.1f,0.1f,0.1f,0.1f,8.0f);

		pc.addBorderCols("Responsable",0,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getResponsabilidad(),0,4,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("Tel.",1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getResponsableTelResidencia(),0,1,0.1f,0.1f,0.1f,0.1f,8.0f);
		pc.addBorderCols("N°Ident.Resp.",1,1,0.1f,0.1f,0.1f,0.1f);
		pc.addBorderCols(adm.getSeguroSocial(),0,2,0.1f,0.1f,0.1f,0.1f,8.0f);

		pc.addCols(" ",1,nHeader.size());

	//table header

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

	pc.useTable("main");
	pc.addTableToCols("NewHeader",1,dHeader.size(),0.0f);

	if (!fp.equals("CUSTOM")){

	if ( adm.getTipoAdmisionDesc() != null && (adm.getTipoAdmisionDesc()).lastIndexOf("(EGY)") < 1 ){

		if (!adm.getCategoria().equals("2"))
		{

				pc.resetVAlignment();
				pc.setNoColumnFixWidth(setHab);
				pc.setFont(9, 1);
				pc.addCols("HABITACIONES Y CAMAS ASIGNADAS ",0,setHab.size());

				pc.setFont(7, 1);
				pc.addInnerTableBorderCols("Cód.",1,1);
				pc.addInnerTableBorderCols("Cama",1,1);
				pc.addInnerTableBorderCols("Habitación",1,1);
				pc.addInnerTableBorderCols("Sala o Sección",1,1);
				pc.addInnerTableBorderCols("Categoría",1,2);
				//pc.addInnerTableBorderCols("Precio",1,1);
				pc.addInnerTableBorderCols("Precio Alterno",1,1);
				pc.addInnerTableBorderCols("Fecha y Hora Asignada",1,1);

			for (int i=0; i<alHab.size(); i++)
			{
				Admision obj = (Admision) alHab.get(i);

					pc.setFont(7, 0);
					pc.addInnerTableCols(" "+obj.getCodigo(),1,1);
					pc.addInnerTableCols(" "+obj.getCama(),1,1);
					pc.addInnerTableCols(" "+obj.getHabitacion(),1,1);
					pc.addInnerTableCols(" "+obj.getCentroServicioDesc(),0,1);
					pc.addInnerTableCols(" "+obj.getHabitacionDesc(),0,2);
					//pc.addInnerTableCols(" "+CmnMgr.getFormattedDecimal(obj.getPrecio()),2,1);
					pc.addInnerTableCols(" "+obj.getPrecioAlt(),1,1);
					pc.addInnerTableCols(" "+obj.getFechaInicio()+" "+obj.getHoraInicio(),1,1);
			}//for i

			if (alHab.size() == 0)
			{
					pc.addInnerTableCols(" ",1,setHab.size(),cHeight);
			}



		}//Fin de Habitaciones y camas
			pc.resetVAlignment();
			pc.addInnerTableToCols(dHeader.size());

			pc.setVAlignment(0);
			pc.setNoInnerColumnFixWidth(setDiagI);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();
				pc.setFont(5, 0);
				pc.addInnerTableCols(" ",0,setDiagI.size());

			pc.setFont(9, 1);
			pc.addInnerTableCols("DIAGNOSTICOS DE INGRESO",0,setDiagI.size());

			pc.setFont(7, 1);
			pc.addInnerTableBorderCols("ICD9",1,1);
			pc.addInnerTableBorderCols("ICD10",1,1);
			pc.addInnerTableBorderCols("Nombre",1,1);

		for (int i=0; i<alDiagI.size(); i++)
		{
			Admision diag = (Admision) alDiagI.get(i);

				pc.setFont(7, 0);
				pc.addInnerTableCols(" "+diag.getDiagnostico(),0,1);
				pc.addInnerTableCols(" "+diag.getIcd10(),0,1);
				pc.addInnerTableCols(" "+diag.getDiagnosticoDesc(),0,1);
		}//for i

		if (alDiagI.size() == 0)
		{
				pc.addInnerTableCols(" ",1,setDiagI.size());
		}
			pc.resetVAlignment();
			pc.addInnerTableToCols(dHeader.size());
		//End de Diagnostico de Ingreso

		//Begin Diagnostico de Egreso
		pc.setVAlignment(0);
			pc.setNoInnerColumnFixWidth(setDiagE);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();
				pc.setFont(7, 0);
				pc.addInnerTableCols(" ",0,setDiagE.size());
			pc.setFont(9, 1);
			pc.addInnerTableCols("DIAGNOSTICOS DE EGRESO",0,setDiagE.size());

			pc.setFont(7, 1);
			pc.addInnerTableBorderCols("ICD9",1,1);
			pc.addInnerTableBorderCols("ICD10",1,1);
			pc.addInnerTableBorderCols("Nombre",1,1);

		for (int i=0; i<alDiagE.size(); i++)
		{
			Admision diagE = (Admision) alDiagE.get(i);

				pc.setFont(7, 0);
				pc.addInnerTableCols(" "+diagE.getDiagnostico(),0,1);
				pc.addInnerTableCols(" "+diagE.getIcd10(),0,1);
				pc.addInnerTableCols(" "+diagE.getDiagnosticoDesc(),0,1);
		}//for i

		if (alDiagE.size() == 0)
		{
				pc.addInnerTableCols(" ",1,setDiagE.size());
		}
			pc.resetVAlignment();
			pc.addInnerTableToCols(dHeader.size());
		//End Diagnostico de Egreso


		//Begin Beneficios
			pc.setVAlignment(0);
			pc.setNoInnerColumnFixWidth(setBenef);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();

			pc.setFont(9, 1);
			pc.addInnerTableCols(" ",0,setBenef.size());
			pc.addInnerTableCols("BENEFICIOS ASIGNADOS",0,setBenef.size());

			pc.setFont(7, 1);
			pc.addInnerTableBorderCols("Aseguradora",1,1);
			pc.addInnerTableBorderCols("Prioridad",1,1);
			pc.addInnerTableBorderCols("# Póliza",1,1);
			pc.addInnerTableBorderCols("Certificado",1,1);
			pc.addInnerTableBorderCols("Doble Cobertura?",1,1);

		for (int i=0; i<alBenef.size(); i++)
		{
			Admision benef = (Admision) alBenef.get(i);

			String strEstado="";
			if(benef.getEstado().equals("A")){ strEstado="Activo";} else {strEstado="Inactivo";}

				pc.setFont(7, 0);
				pc.addInnerTableCols(" "+benef.getEmpresa()+" "+benef.getNombreEmpresa(),0,1);
				pc.addInnerTableCols(" "+benef.getPrioridad(),1,1);
				pc.addInnerTableCols(" "+benef.getPoliza(),1,1);
				pc.addInnerTableCols(" "+benef.getCertificado(),1,1);
				pc.addInnerTableCols(" "+benef.getConvenioSolEmp(),1,1);
		}//for i

		if (alBenef.size() == 0)
		{
				//pc.addCols("No Existen Beneficios Asignados Registrados.",1,setBenef.size(),cHeight);
					pc.addInnerTableCols(" ",1,setBenef.size());
		}
			pc.resetVAlignment();
			pc.addInnerTableToCols(dHeader.size());
		//End Beneficios


		//OPERACIONES
		pc.setVAlignment(0);
			pc.setNoInnerColumnFixWidth(setCpt);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();
			pc.addInnerTableCols(" ",1,setCpt.size());
			pc.setFont(9, 1);
			pc.addInnerTableCols("DIAGNOSTICOS                      DE                      SALIDA                      Y                      COMPLICACIONES                      ",0,4);
			pc.addInnerTableCols("CODIGO",1,1);

			pc.setFont(7, 0);
			pc.addInnerTableBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableBorderCols(" ",0,5,0.5f,0.0f,0.0f,0.0f,12.0f);

			pc.addInnerTableCols(" ",1,setCpt.size());
			pc.setFont(9, 1);
			pc.addInnerTableCols("FECHA",1,1);
			pc.addInnerTableCols(" ",0,1);
			pc.addInnerTableCols("OPERACIONES",1,1);
			pc.addInnerTableCols(" ",0,1);
			pc.addInnerTableCols("CODIGO",1,1);

			pc.setFont(7, 0);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);

			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);

			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);

			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);

			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);
			pc.addInnerTableCols(" ",0,1,12.0f);
			pc.addInnerTableBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,12.0f);

			pc.resetVAlignment();
			pc.addInnerTableToCols(dHeader.size());

			pc.setVAlignment(0);
			pc.setNoInnerColumnFixWidth(setFooter);
			pc.setInnerTableWidth(pc.getWidth() - (pc.getLeftRightMargin() * 2));
			pc.createInnerTable();
			pc.addInnerTableCols(" ",0,setFooter.size());
			pc.addInnerTableCols("Condición de Salida:",0,1);


			// salida autorizada
			if (cdo2.getColValue("tipoSalida") != null && cdo2.getColValue("tipoSalida").trim().equals("A"))
				pc.addInnerTableBorderCols(" ",0,1,5.50f,5.50f,5.50f,5.50f);
			else
				pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols("Autorizada",0,1);

			// salida x defuncion
			if (cdo2.getColValue("tipoSalida") != null && cdo2.getColValue("tipoSalida").trim().equals("D"))
				pc.addInnerTableBorderCols(" ",0,1,5.50f,5.50f,5.50f,5.50f);
			else
				pc.addInnerTableBorderCols(" ",0,1);
			pc.addInnerTableCols("Muerte",0,1);

			// salida voluntaria
			if (cdo2.getColValue("tipoSalida") != null && cdo2.getColValue("tipoSalida").trim().equals("V"))
				pc.addInnerTableBorderCols(" ",0,1,5.50f,5.50f,5.50f,5.50f);
			else pc.addInnerTableBorderCols(" ",0,1);
				pc.addInnerTableCols("Voluntaria",0,1);

			// firma de relevo
			if (cdo2.getColValue("tipoSalida") != null && cdo2.getColValue("tipoSalida").trim().equals("V"))
				pc.addInnerTableCols("(Firmar Revelo de Responsabilidad)  [ "+cdo2.getColValue("relevo")+" ]",0,1);
			else
				pc.addInnerTableCols("(Firmar Revelo de Responsabilidad)",0,1);


			pc.resetVAlignment();
			pc.addInnerTableToCols(dHeader.size());

			pc.setVAlignment(2);
			pc.addCols("Días de Estadía:",0,1);
			pc.addBorderCols(" ",0,1,0.5f,0.0f,0.0f,0.0f,cHeight*2);

			pc.addCols("FIRMA Y SELLO DEL MEDICO TRATANTE:",2,2);

			if (cdo2.getColValue("reg_medico") != null)
				pc.addBorderCols("["+cdo2.getColValue("reg_medico")+"]  "+cdo2.getColValue("nombre_usuario"),0,2,0.5f,0.0f,0.0f,0.0f);
			else
				pc.addBorderCols(" ",0,2,0.5f,0.0f,0.0f,0.0f);
	}

	if (adm.getPase().equalsIgnoreCase("S")) {
		pc.setVAlignment(2);
		pc.addCols("",0,1);
		pc.addCols("FIRMA DEL PACIENTE:",2,2);
		pc.addBorderCols("",0,1,0.5f,0.0f,0.0f,0.0f,cHeight*2);
		pc.addCols("",0,2);
	}
	} // custom
	pc.resetVAlignment();

	pc.addTable();
	if(isUnifiedExp){
		pc.close();
		response.sendRedirect(redirectFile);
	}
//}//GET

%>