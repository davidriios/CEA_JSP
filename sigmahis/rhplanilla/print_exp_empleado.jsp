<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.StringTokenizer" %>
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
ArrayList alEduc = new ArrayList();
Vector v = new Vector();
String sql = "";
String appendFilter = request.getParameter("appendFilter");
String empId = request.getParameter("empId");
String st = request.getParameter("p");
String userName = UserDet.getUserName();
ArrayList alCurso = new ArrayList();
ArrayList alHabil = new ArrayList();
ArrayList alEntre = new ArrayList();
ArrayList alIdiom = new ArrayList();
ArrayList alEnfe = new ArrayList();
ArrayList alDisc = new ArrayList();
ArrayList alRecon = new ArrayList();
ArrayList alParient = new ArrayList();

StringTokenizer  tr = new StringTokenizer(st," , ");
while(tr.hasMoreTokens())
{
v.add(tr.nextToken());
//String trev = tr.nextToken();
}





if (appendFilter == null) appendFilter = "";
//if (st != null)
if (v.contains("0"))
{
	sql="Select DISTINCT a.EMP_ID,a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula, a.firma, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1,  nvl(a.segundo_apellido,' ') as apellido2, nvl(a.apellido_casada, ' ') as casada, a.num_empleado as numEmpleado, nvl(a.num_ssocial, ' ') as seguro, a.num_dependiente as dependiente, a.licencia_conducir as conducir, a.OTROS_ING_FIJOS as otros, to_char(a.salario_base,'999,999,990.00') as salario, to_char(a.rata_hora,'99,990.00') as rata, a.REC_ALTO_RIESGO as recibe, nvl(a.calle_dir, ' ') as calle, nvl(a.casa__dir, ' ') as casa, nvl(a.apartado_postal, ' ') as apartado, nvl(a.zona_postal, ' ') as zona, nvl(a.telefono_casa, ' ') as telcasa, nvl(a.telefono_otro, ' ') as telotros, nvl(a.lugar_telefono, ' ') as tellugar, a.nacionalidad as nacionalidadCode, a.NUM_EMP_REMPLAZA as remplazado, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha,  (( to_number(to_char(SYSDATE,'yyyy')) - to_number(to_char(a.fecha_nacimiento,'yyyy'))) - 1) as edad, a.estado_civil as civil, a.sexo, a.vive_madre as vivemadre, a.vive_padre as vivepadre, nvl(a.nombre_madre, ' ') as madre, nvl(a.nombre_padre, ' ') as padre, nvl(a.emergencia_llamar, ' ') as llamar, a.telefono_emergencia as telefonos, a.num_hijos as hijos, a.num_cuenta as cta, nvl(a.email,' ') AS email, a.fecha_creacion as creacion, nvl(a.comentario, ' ') as comentario, nvl(a.cedula_beneficiario, ' ') as cbeneficiario, nvl(a.nombre_beneficiario, ' ') as nbeneficiario, nvl(a.apellido_beneficiario, ' ') as abeneficiario, nvl(a.num_contrato, ' ') as numero, to_char(a.fecha_contrato,'dd/mm/yyyy') as contrato, to_char(a.fecha_ingreso, 'dd/mm/yyyy') as ingreso, to_char(a.FECHA_EGRESO,'dd/mm/yyyy') as egreso, to_char(a.FECHA_PUESTOACT, 'dd/mm/yyyy') as puestoA, to_char(a.fecha_ult_aumento,'dd/mm/yyyy') as aumento, to_char(a.FECHA_INICIO_INCAPACIDAD, 'dd/mm/yyyy') as incapacidad , a.tipo_emple as tipos,  a.estado, a.tipo_pla as planilla, a.cargo, decode(a.comunidad_dir, null, ' ',a.comunidad_dir ) as comunidadC, decode(a.corregimiento_dir, null, ' ',a.corregimiento_dir) as corregimientoC, decode(a.distrito_dir,  null,'',a.distrito_dir) as distritoC, decode(a.provincia_dir, null, ' ', a.provincia_dir) as provinciaC, decode(a.pais_dir, null, ' ', a.pais_dir ) as paisC, decode(a.corregimiento_nac, null, ' ', a.corregimiento_nac) as corregimientoCode, decode(a.distrito_nac, null, ' ', a.distrito_nac) as distritoCode, decode(a.provincia_nac, null, ' ', a.provincia_nac) as provinciaCode, decode(a.pais_nac, null,' ',a.pais_nac) as paisCode, nvl(a.tipo_renta, ' ') as clave, a.forma_pago as forma, a.compania_uniorg, a.unidad_organi as secciones, nvl(a.tipo_sangre, ' ') as sang, nvl(a.rh, ' ') as sangre, a.tipo_cuenta as ahorro, to_char(a.gasto_rep,'999,999,990.00') as gastos, nvl(a.cargo_jefe, ' ') as jefe, a.sindicato as sindicatos, a.sind_nombre as spertenece, a.fuero, nvl(a.tipo_licencia, ' ') as licencia, nvl(a.numero_licencia, ' ') as nlicencia, a.horario, a.acum_decimo as acumulado, a.acum_decimo_gr as gastoAcum, a.seccion, nvl(a.ruta_bancaria, ' ') as ruta, a.CALCULO_RENTA_ESP as calculo, a.renta_fija as renta, a.valor_renta as valorenta, a.horas_base as horas, a.ubic_depto as direccion, a.ubic_seccion as seccion, a.ubic_fisica as ubicacion, a.usar_apellido_casada as usar, to_char(a.fecha_fin_contrato,'dd/mm/yyyy') as fincontrato, a.digito_verificador as digito, a.salario_especie as especie, a.aseg_grupo, aseg_certificado, a.emp_id, a.jefe_emp_id, nvl(b.nacionalidad, 'NA') as nacionalidad, nvl(d.nombre_comunidad, ' ') as comunidadN, nvl(d.nombre_corregimiento, ' ') as corregimientoN, nvl(d.nombre_distrito, ' ') as distritoN, nvl(d.nombre_provincia, ' ') as provinciaN, nvl(d.nombre_pais, ' ') as paisN, nvl(e.nombre_pais, ' ') as paisName, nvl(e.nombre_provincia, ' ') as provinciaName, nvl(e.nombre_corregimiento, ' ') as corregimientoName, nvl(e.nombre_distrito, ' ') as distritoName, f.codigo as cot, f.descripcion as nameEmpleado, g.codigo as dire, g.descripcion as namedireccion, h.codigo as se, h.descripcion as nameseccion, i.codigo as car, i.denominacion as nameCargo, z.CODIGO as uno, z.DENOMINACION as nameJefe, j.codigo as est, j.descripcion as nameEstado, k.codigo as fr, k.descripcion as nameForma, l.tipopla as tip, l.descripcion as namePlanilla, m.codigo as hor, m.descripcion as namehorario, n.clave as cls, n.descripcion as nameClave, p.codigo as ubs, p.descripcion as nameUbicacion,a.unidad_organi as gerencia, w.descripcion as nameGerencia from tbl_pla_empleado a, tbl_sec_pais b, tbl_pla_tipo_empleado f, (select codigo_pais, nombre_pais,  decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null, nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,  nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) e, tbl_sec_unidad_ejec g, tbl_sec_unidad_ejec h, tbl_pla_cargo i, TBL_PLA_CARGO z, tbl_pla_estado_emp j, tbl_pla_f_pago_emp k, tbl_pla_tipo_planilla l, tbl_pla_horario_trab m, tbl_pla_clave_renta n, tbl_sec_unidad_ejec w, tbl_sec_unidad_ejec p where a.nacionalidad = b.codigo(+) and a.pais_dir = d.codigo_pais(+) and a.provincia_dir = d.codigo_provincia(+) and a.distrito_dir = d.codigo_distrito(+) and a.corregimiento_dir = d.codigo_corregimiento(+) and a.comunidad_dir = d.codigo_comunidad(+) and a.pais_nac = e.codigo_pais(+) and a.provincia_nac = e.codigo_provincia(+) and a.distrito_nac = e.codigo_distrito(+) and a.corregimiento_nac = e.codigo_corregimiento(+) and a.tipo_emple=f.codigo and a.UBIC_DEPTO=g.codigo(+)and a.unidad_organi = w.codigo(+) and a.compania=w.compania and a.compania=g.compania(+) and a.ubic_seccion=h.codigo(+) and a.compania= h.compania(+) and a.CARGO= i.codigo(+) and a.CARGO_JEFE = z.CODIGO(+) and a.compania= i.compania(+) and a.ESTADO =j.codigo(+) and a.FORMA_PAGO = k.codigo(+) and a.TIPO_PLA= l.tipopla(+) and a.HORARIO= m.codigo(+) and a.compania=m.compania(+) and a.TIPO_RENTA = n.clave(+) and a.compania = z.COMPANIA(+) and a.UBIC_FISICA = p.codigo(+) and a.compania= p.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" AND a.COMPANIA_UNIORG="+(String) session.getAttribute("_companyId")+" and a.emp_id= "+empId;

al = SQLMgr.getDataList(sql);
}

if (v.contains("1"))
{
//------------------------------ Query EDUCACION  ------------------------------
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.lugar, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.carrera, a.certificado_obt , a.termino, a.nivel , a.tipo as tipo, b.provincia as pr, b.sigla as s, b.tomo as t, b.asiento as ast, b.primer_nombre, b.primer_apellido, c.codigo as cot, c.descripcion as educacioName from tbl_pla_educacion a, tbl_pla_empleado b, tbl_pla_tipo_educacion c where a.emp_id=b.emp_id and a.tipo=c.codigo and a.compania=b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alEduc=SQLMgr.getDataList(sql);
}	
		if (v.contains("2"))
{
//=================================  QUERY DE CURSO  =======================
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.descripcion, a.institucion, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.duracion, a.tipo, b.codigo as ot, b.descripcion as nameCurso, c.primer_nombre, c.primer_apellido from tbl_pla_cursos_fuera a, tbl_pla_tipo_actividad b, tbl_pla_empleado c where a.tipo=b.codigo(+) and a.emp_id=c.emp_id and a.compania= c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alCurso=SQLMgr.getDataList(sql);
	}	
	if (v.contains("3"))
{
//=============================== QUERY DE HABILIDADES ========================
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.habilidad, a.calificacion, b.descripcion  as habilidadName, c.primer_apellido, c.primer_nombre  from tbl_pla_habilidad_empl a, tbl_pla_habilidad b, tbl_pla_empleado c where a.habilidad=b.codigo(+) and a.emp_id= c.emp_id 	and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alHabil=SQLMgr.getDataList(sql);
}
if (v.contains("4"))
{

//============================  QUERY DE ENTRETENIMINETO  ==================		
	sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.entretenimiento, decode(a.tipo,'P','PASATIEMPO','D','DEPORTE') as tipo, b.descripcion as entretenimientoName, c.primer_apellido, c.primer_nombre from tbl_pla_entretenimiento_empl a, tbl_pla_entretenimiento b, tbl_pla_empleado c where a.entretenimiento=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alEntre=SQLMgr.getDataList(sql);
		}
		if (v.contains("5"))
{
			
//============================  QUERY DE IDIOMAS =========================			 
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.idioma, decode (a.nivel_conversacional,'A','AVANZADO','I','INTERMEDIO','B','BASICO') as conversacion, DECODE(a.nivel_lectura,'A','AVANZADO','I','INTERMEDIO','B','BASICO')as lectura, decode(a.nivel_escritura,'A','AVANZADO','I','INTERMEDIO','B','BASICO')as escritura, b.descripcion as nameidioma, c.primer_nombre, c.primer_apellido from tbl_pla_idioma_empl a,tbl_pla_idioma b, tbl_pla_empleado c where a.idioma=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alIdiom=SQLMgr.getDataList(sql);
		
		}
		if (v.contains("6"))
{	
//============================  QUERY DE ENFERMEDAD ======================	
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.enfermedad, decode(a.alto_riesgo,'S','SI','N','NO') riesgo, b.descripcion as enfermedadName, c.primer_apellido, c.primer_nombre from tbl_pla_enfermedad_empl a, tbl_pla_enfermedad b, tbl_pla_empleado c where a.enfermedad=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alEnfe=SQLMgr.getDataList(sql);
		}
		if (v.contains("7"))
{		
//========================  QUERY DE MEDIDAS DISCIPLINARIAS ==============
sql="select a.provincia, a.sigla, a.tomo, a.asiento, a.tipo_med, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fechamed, a.motivo, a.descripcion, a.autorizapo_por, c.primer_apellido, c.primer_nombre, b.descripcion as medidaName from tbl_pla_medidas_disciplinarias a ,tbl_pla_tipo_medida b, tbl_pla_empleado c where a.tipo_med=b.codigo(+) and a.emp_id=c.emp_id and a.compania= c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;		
		alDisc=SQLMgr.getDataList(sql);
		}
		
		if (v.contains("8"))
{
				
//=========================  QUERY DE RECONOCIMIENTOS  ==================
	
sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.motivo, a.descripcion, a.comentario, c.primer_apellido, c.primer_nombre  from tbl_pla_reconocimiento a, tbl_pla_empleado c where a.emp_id=c.emp_id and a.compania=c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;

	alRecon  = SQLMgr.getDataList(sql);
	}
	if (v.contains("9"))
{
			
//=======================  QUERY DE PARIENTES  =========================
sql="select a.codigo, a.provincia, a.sigla, a.tomo, a.asiento, a.nombre , a.apellido , a.sexo, a.parentesco, a.dependiente, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento , a.vive_con_empleado, a.invalido, a.proteg_por_riesgo, a.trabaja, a.lugar_trabajo, a.telefono_trabajo, a.estudia, a.emp_provincia, a.emp_sigla, a.emp_tomo, a.emp_asiento, a.cod_compania, a.vive, to_char(a.fecha_fallecimiento,'dd/mm/yyyy') as fecha_fallecimiento, a.beneficiario, b.descripcion as parentescoName, c.primer_apellido, c.primer_nombre from tbl_pla_pariente a, tbl_pla_parentesco b, tbl_pla_empleado c where a.parentesco=b.codigo(+) and a.emp_id=c.emp_id and a.cod_compania = c.compania(+) and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;

	alParient = SQLMgr.getDataList(sql);

}

//}
if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+".pdf";

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
	String title = "PLANILLA";
	String subtitle = "EXPEDIENTE DE EMPLEADO";
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
	  dHeader.addElement(".10");
		dHeader.addElement(".20");
		dHeader.addElement(".15");
		dHeader.addElement(".20");
		dHeader.addElement(".10");
		dHeader.addElement(".05");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		
		
	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row
	//	pc.setFont(7, 1);
	//	pc.addBorderCols("Cédula",0,2);
	//	pc.addBorderCols("Nombre",0);								
	
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table
	  int no = 0;
		String dir = "";
		String sec = "";
	
	//table body
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);

		if (!dir.equalsIgnoreCase(cdo.getColValue("dire")))
			{
			
			pc.setFont(7, 1);
			pc.addCols("DRECCION: ",0,1);
			pc.addCols(" "+cdo.getColValue("namedireccion"),0,7);
			
			
			pc.setFont(7, 1);
			pc.addCols("SECCION: ",0,1);
			pc.addCols(" "+cdo.getColValue("nameseccion"),0,7);
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("DATOS GENERALES DEL EMPLEADO: ",0,8);
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			}
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Cedula: ",0,1);
			pc.addCols(" "+cdo.getColValue("cedula"),0,1);
			pc.addCols("Seguro Social:",0,1);	
			pc.addCols(" "+cdo.getColValue("seguro"),0,1);
			pc.addCols(" ",0,2);
			pc.addCols("No. Empleado: ",0,1);
			pc.addCols(" "+cdo.getColValue("numEmpleado"),0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Primer Nombre: ",0,1);
			pc.addCols(" "+cdo.getColValue("nombre1"),0,1);
			pc.addCols("Segundo Nombre:",0,1);	
			pc.addCols(" "+cdo.getColValue("nombre2"),0,1);
			pc.addCols(" ",0,2);
			pc.addCols("Apellido Casada: ",0,1);
			pc.addCols("Usar?: ",0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Primer Apellido: ",0,1);
			pc.addCols(" "+cdo.getColValue("apellido1"),0,1);
			pc.addCols("Segundo Apellido:",0,1);	
			pc.addCols(" "+cdo.getColValue("apellido2"),0,1);
			pc.addCols("Sexo: ",0,1);
			pc.addCols(" "+cdo.getColValue("sexo"),0,1);
			pc.addCols(" "+cdo.getColValue("casada"),0,1);
			pc.addCols(" "+cdo.getColValue("usar"),0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Fehca de Nac.: ",0,1);
			pc.addCols(" "+cdo.getColValue("fecha"),0,1);
			pc.addCols("Tipo de Sangre:",0,1);	
			pc.addCols(" "+cdo.getColValue("sang")+cdo.getColValue("sangre"),0,1);
			pc.addCols("Edad: ",0,1);
			pc.addCols(" "+cdo.getColValue("edad"),0,1);
			pc.addCols("Estado Civil: ",0,1);
			pc.addCols(" "+cdo.getColValue("civil"),0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Nacionalidad: ",0,1);
			pc.addCols(" "+cdo.getColValue("nacionalidad"),0,1);
			pc.addCols("Dirección: ",0,1);
			pc.addCols(" "+cdo.getColValue("distritoN")+" "+cdo.getColValue("corregimientoN")+" "+cdo.getColValue("comunidadN"),0,3);
      pc.addCols("Apartado Postal: ",0,1);
			pc.addCols(" "+cdo.getColValue("apartado"),0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Teléfono: ",0,1);
			pc.addCols(" "+cdo.getColValue("telcasa"),0,1);
			pc.addCols("Calle: ",0,1);
			pc.addCols(" "+cdo.getColValue("calle")+"  "+cdo.getColValue("casa"),0,3);
			pc.addCols("Tel. Conyuge: ",0,1);
			pc.addCols(" "+cdo.getColValue("apartado"),0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Celular: ",0,1);
			pc.addCols(" "+cdo.getColValue("telotros"),0,1);
			pc.addCols("E-Mail: ",0,1);
			pc.addCols(" "+cdo.getColValue("email"),0,2);
			pc.addCols(" ",0,1);
			pc.addCols("Tel. Emergencia: ",0,1);
			pc.addCols(" "+cdo.getColValue("telefonos"),0,1);
			
		pc.setFont(7, 1);
		pc.addCols("",0,8);
			pc.setFont(7, 1);
			pc.addCols("",0,8);
	
		pc.setFont(7, 1);
		pc.addCols("DATOS DEL PUESTO: ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Ocupación: ",0,1);
			pc.addCols(" "+cdo.getColValue("nameCargo"),0,2);
			pc.addCols("",0,3);	
			pc.addCols("Fecha Ingreso: ",0,1);
			pc.addCols(" "+cdo.getColValue("ingreso"),0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Forma de Pago: ",0,1);
			pc.addCols(" "+cdo.getColValue("nameForma"),0,1);
			pc.addCols("#. de Cuenta: ",0,1);
			pc.addCols(" "+cdo.getColValue("cta"),0,1);
			pc.addCols(" ",0,2);
			pc.addCols("Ruta Banca: ",0,1);
			pc.addCols(" "+cdo.getColValue("ruta"),0,1);
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Salario Mensual: ",0,1);
			pc.addCols(" "+cdo.getColValue("salario"),0,1);
			pc.addCols("Gasto de Rep.: ",0,1);
			pc.addCols(" "+cdo.getColValue("gastos"),0,1);
			pc.addCols("# Dependientes: ",0,1);
			pc.addCols(" "+cdo.getColValue("dependiente"),0,1);
			pc.addCols("Rata x Hora: ",0,1);
			pc.addCols(" "+cdo.getColValue("rata"),0,1);
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Horario: ",0,1);
			pc.addCols(" "+cdo.getColValue("namehorario"),0,3);
			pc.addCols("Jefe del Empleado: ",0,2);
			pc.addCols(" "+cdo.getColValue("uno")+" "+cdo.getColValue("nameJefe"),0,2);
		
		pc.setFont(7, 1);
		pc.addCols("",0,8);
		
				
		dir=cdo.getColValue("dire");	
		sec=cdo.getColValue("se");	
	
		//if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		}
		
		
		if (v.contains("1"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("EDUCACION DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Tipo Estudio ",1);
			pc.addBorderCols("Lugar",1);
			pc.addBorderCols("Carrera ",1);
			pc.addBorderCols("Titulo ",1);
			pc.addBorderCols("Fecha Desde -  Hasta",1,2);
			pc.addBorderCols("Años Cursado ",1);
			pc.addBorderCols("Terminó",1);
	
	if (alEduc.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{	
			for (int i=0; i<alEduc.size(); i++)
		{
		CommonDataObject cdo = (CommonDataObject) alEduc.get(i);
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("educacioname"),0,1);
			pc.addCols(" "+cdo.getColValue("lugar"),0,1);
			pc.addCols(" "+cdo.getColValue("carrera"),0,1);
			pc.addCols(" "+cdo.getColValue("certificado_obt"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha_inicio")+"   "+cdo.getColValue("fecha_final"),1,2);
			pc.addCols(" "+cdo.getColValue("nivel"),1,1);
			pc.addCols(" "+cdo.getColValue("termino"),1,1);
		
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
	if (v.contains("2"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("CURSOS DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Secuencia",1,1);
			pc.addBorderCols("Tipo Curso ",1);
			pc.addBorderCols("Lugar",1);
			pc.addBorderCols("Descripcion ",1,2);
			pc.addBorderCols("Fecha Desde -  Hasta",1,2);
			pc.addBorderCols("Duración (días)",1);
	
	  if (alCurso.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{				
			
	for (int i=0; i<alCurso.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alCurso.get(i);
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),1,1);
			pc.addCols(" "+cdo.getColValue("namecurso"),0,1);
			pc.addCols(" "+cdo.getColValue("institucion"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,2);
			pc.addCols(" "+cdo.getColValue("fecha_inicio")+"   "+cdo.getColValue("fecha_final"),1,2);
			pc.addCols(" "+cdo.getColValue("duracion"),1,1);
	
		
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
		if (v.contains("3"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("HABILIDADES DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Código ",1,1);
			pc.addBorderCols("Descripcion ",0,7);
						
		if (alHabil.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{
	for (int i=0; i<alHabil.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alHabil.get(i);
	
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("habilidad"),1,1);
			pc.addCols(" "+cdo.getColValue("habilidadName"),0,7);
				
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
	
			if (v.contains("4"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("ENTRETENIMIENTOS DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Código ",1,1);
			pc.addBorderCols("Descripcion ",0,2);
			pc.addBorderCols("Tipo ",0,5);
		
			if (alEntre.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{			
			
	for (int i=0; i<alEntre.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alEntre.get(i);
	
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("entretenimiento"),1,1);
			pc.addCols(" "+cdo.getColValue("entretenimientoName"),0,2);
			pc.addCols(" "+cdo.getColValue("tipo"),0,5);
			
				
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
				if (v.contains("5"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("IDIOMAS DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Código ",1,1);
			pc.addBorderCols("Idioma",0,2);
			pc.addBorderCols("Lectura ",0,1);
			pc.addBorderCols("Conversación ",1,2);
			pc.addBorderCols("Escritura",0,2);
	
		if (alIdiom.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{	
				
	for (int i=0; i<alIdiom.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alIdiom.get(i);
	
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("idioma"),1,1);
			pc.addCols(" "+cdo.getColValue("nameidioma"),0,2);
			pc.addCols(" "+cdo.getColValue("lectura"),0,1);
			pc.addCols(" "+cdo.getColValue("conversacion"),0,2);
			pc.addCols(" "+cdo.getColValue("escritura"),0,2);
				
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
			if (v.contains("6"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("ENFERMEDADES DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Código ",1,1);
			pc.addBorderCols("Descripción",0,4);
			pc.addBorderCols("Alto Riesgo ",0,3);
		
	if (alEnfe.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{				
			
	for (int i=0; i<alEnfe.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alEnfe.get(i);
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("enfermedad"),1,1);
			pc.addCols(" "+cdo.getColValue("enfermedadName"),0,4);
			pc.addCols(" "+cdo.getColValue("riesgo"),0,3);
		
				
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
				if (v.contains("7"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("MEDIDAS DISCIPLINARIAS DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Secuencia ",1,1);
			pc.addBorderCols("Motivo",0,1);
			pc.addBorderCols("Descripción ",0,1);
			pc.addBorderCols("Medida ",0,3);
			pc.addBorderCols("Autorización",1,1);
			pc.addBorderCols("Fecha Medida ",1,1);
		
		if (alDisc.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{			
		
	for (int i=0; i<alDisc.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alDisc.get(i);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),1,1);
			pc.addCols(" "+cdo.getColValue("motivo"),0,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("medidaName"),1,3);
			pc.addCols(" "+cdo.getColValue("autorizapo_por"),0,1);
			pc.addCols(" "+cdo.getColValue("fechamed"),1,1);
		
				
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
					if (v.contains("8"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("RECONOCIMIENTOS DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Secuencia ",1,1);
			pc.addBorderCols("Descripción ",0,1);
			pc.addBorderCols("Motivo ",1,2);
			pc.addBorderCols("Comentario",1,3);
			pc.addBorderCols("Fecha ",1,1);
		
		if (alRecon.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{			
			
	for (int i=0; i<alRecon.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alRecon.get(i);
		
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("codigo"),1,1);
			pc.addCols(" "+cdo.getColValue("descripcion"),0,1);
			pc.addCols(" "+cdo.getColValue("motivo"),0,2);
			pc.addCols(" "+cdo.getColValue("comentario"),0,3);
			pc.addCols(" "+cdo.getColValue("fecha"),1,1);
		
				
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
	if (v.contains("9"))
			{
		
			pc.setFont(7, 1);
			pc.addCols("",0,8);
			pc.setFont(7, 1);
		  pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("PARIENTES DEL EMPLEADO ",0,dHeader.size());
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			pc.setFont(7, 0);
			pc.setVAlignment(0);
			pc.addBorderCols("Cedula ",1,1);
			pc.addBorderCols("Nombre ",0,1);
			pc.addBorderCols("Apellido ",1,1);
			pc.addBorderCols("Parentesco",1,1);
			pc.addBorderCols("Fecha Nacimiento",1,1);
				pc.addBorderCols("Sexo ",1,1);
			pc.addBorderCols("Trabajo",1,1);
			pc.addBorderCols("Beneficiario ",1,1);
		
		if (alParient.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else 
		{			
			
	for (int i=0; i<alParient.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) alParient.get(i);

		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols(" "+cdo.getColValue("provincia")+"-"+cdo.getColValue("sigla")+"-"+cdo.getColValue("tomo")+" "+cdo.getColValue("asiento"),0,1);
			pc.addCols(" "+cdo.getColValue("nombre"),0,1);
			pc.addCols(" "+cdo.getColValue("apellido"),0,1);
			pc.addCols(" "+cdo.getColValue("parentescoName"),0,1);
			pc.addCols(" "+cdo.getColValue("fecha_nacimiento"),1,1);
			pc.addCols(" "+cdo.getColValue("sexo"),1,1);
			pc.addCols(" "+cdo.getColValue("lugar_trabajo"),0,1);
			pc.addCols(" "+cdo.getColValue("beneficiario"),1,1);
			
		}
		//if ((i % 50 == 0) || ((i + 1) == al.size()+alEduc.size())) pc.flushTableBody(true);
	}
	}
	
	//	if (al.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
	//	else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>