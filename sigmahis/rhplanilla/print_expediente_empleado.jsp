<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="AdmMgr" scope="page" class="issi.admision.AdmisionMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR 
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
//CommonDataObject emple = new CommonDataObject();
	String empId = request.getParameter("empId");
	String c1 = request.getParameter("c1");
	String sql = "";	
	String appendFilter = request.getParameter("appendFilter");
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String userName = UserDet.getEmpDetails().getEmpName();
	Admision adm = new Admision();
	Company com= new Company ();
	ArrayList list   = new ArrayList();
	ArrayList emple   = new ArrayList();
	ArrayList al = new ArrayList();
	ArrayList alEduc = new ArrayList();
	ArrayList alCurso = new ArrayList();
	ArrayList alHabil = new ArrayList();
	ArrayList alEntre= new ArrayList();
	ArrayList alIdiom = new ArrayList();
	ArrayList alEnfe= new ArrayList();
	ArrayList alDisc = new ArrayList();
	ArrayList alRecon= new ArrayList();
	ArrayList alParient = new ArrayList();

//	if(request.getParameter("noAdmision")!=null	{	noAdmision=request.getParameter("noAdmision");}
//if (request.getParameter("pacId")!=null){	pacId= request.getParameter("pacId"); }

//----------------------------------------------- Company ---------------------------
sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);
		
//---------------------------------------------    Tab General   ------------------------------------------------
sql="Select DISTINCT a.emp_id,a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento as cedula, a.firma, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1, nvl(a.segundo_apellido,' ') as apellido2, nvl(a.apellido_casada, ' ') as casada, a.num_empleado as numEmpleado, nvl(a.num_ssocial, ' ') as seguro, a.num_dependiente as dependiente, a.licencia_conducir as conducir, a.otros_ing_fijos as otros, to_char(a.salario_base,'999,999,990.00') as salario, to_char(a.rata_hora,'999,990.00') as rata, a.rec_alto_riesgo as recibe, nvl(a.calle_dir, ' ') || nvl(a.casa__dir, ' ') as casa, nvl(a.apartado_postal, ' ') as apartado, nvl(a.zona_postal, ' ') as zona, nvl(a.telefono_casa, ' ') as telcasa, nvl(a.telefono_otro, ' ') as telotros, nvl(a.lugar_telefono, ' ') as tellugar, a.nacionalidad as nacionalidadCode, a.num_emp_remplaza as remplazado, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha, a.tipo_sangre||'-'||a.rh as sangre, to_char(a.gasto_rep,'999,999,990.00') as gasto, decode(a.estado_civil,'ST','SOLTERO(A)','CS','CASADO(A)','VD','VIUDO(A)','DV','DIVORCIADO(A)','UN','UNIDO(A),''SP','SEPARADO(A)') as civil, decode(a.sexo,'M','MASCULINO','F','FEMENINO') as sexo, a.vive_madre as vivemadre, a.vive_padre as vivepadre, nvl(a.nombre_madre, ' ') as madre, nvl(a.nombre_padre, ' ') as padre, nvl(a.emergencia_llamar, ' ') as llamar, a.telefono_emergencia as telefonos, a.num_hijos as hijos, a.num_cuenta as cta, nvl(a.email,' ') as email, a.fecha_creacion as creacion, nvl(a.comentario, ' ') as comentario, nvl(a.cedula_beneficiario, ' ') as cbeneficiario, nvl(a.nombre_beneficiario, ' ') as nbeneficiario, nvl(a.apellido_beneficiario, ' ') as abeneficiario, nvl(a.num_contrato, ' ') as numero, to_char(a.fecha_contrato,'dd/mm/yyyy') as contrato, to_char(a.fecha_ingreso, 'dd/mm/yyyy') as ingreso, to_char(a.fecha_egreso,'dd/mm/yyyy') as egreso, to_char(a.fecha_puestoact, 'dd/mm/yyyy') as puestoA, to_char(a.fecha_ult_aumento,'dd/mm/yyyy') as aumento, to_char(a.fecha_inicio_incapacidad, 'dd/mm/yyyy') as incapacidad , a.tipo_emple as tipos,  a.estado, a.tipo_pla as planilla, a.cargo, decode(a.comunidad_dir, null, ' ',a.comunidad_dir ) as comunidadC, decode(a.corregimiento_dir, null, ' ',a.corregimiento_dir) as corregimientoC, decode(a.distrito_dir,  null,'',a.distrito_dir) as distritoC, decode(a.provincia_dir, null, ' ', a.provincia_dir) as provinciaC, decode(a.pais_dir, null, ' ', a.pais_dir ) as paisC, decode(a.corregimiento_nac, null, ' ', a.corregimiento_nac) as corregimientoCode, decode(a.distrito_nac, null, ' ', a.distrito_nac) as distritoCode, decode(a.provincia_nac, null, ' ', a.provincia_nac) as provinciaCode, decode(a.pais_nac, null,' ',a.pais_nac) as paisCode, nvl(a.tipo_renta, ' ')||nvl(a.num_dependiente,'0') as clave, a.forma_pago as forma, a.compania_uniorg, a.unidad_organi as secciones, nvl(a.tipo_sangre, ' ') as sang, nvl(a.rh, ' ') as sangre, a.tipo_cuenta as ahorro, a.gasto_rep as gastos, nvl(a.cargo_jefe, ' ') as jefe, a.sindicato as sindicatos, a.sind_nombre as spertenece, a.fuero, nvl(a.tipo_licencia, ' ') as licencia, nvl(a.numero_licencia, ' ') as nlicencia, a.horario, a.acum_decimo as acumulado, a.acum_decimo_gr as gastoAcum, a.seccion, nvl(a.ruta_bancaria, ' ') as ruta, a.calculo_renta_esp as calculo, a.renta_fija as renta, a.valor_renta as valorenta, a.horas_base as horas, a.ubic_depto as direccion, a.ubic_seccion as seccion, a.ubic_fisica as ubicacion, a.usar_apellido_casada as usar, to_char(a.fecha_fin_contrato,'dd/mm/yyyy') as fincontrato, a.digito_verificador as digito, a.salario_especie as especie, a.aseg_grupo, aseg_certificado, a.emp_id, a.jefe_emp_id, nvl(b.nacionalidad, 'NA') as nacionalidad, nvl(d.nombre_comunidad, ' ') as comunidadN, nvl(d.nombre_corregimiento, ' ') as corregimientoN, nvl(d.nombre_distrito, ' ') as distritoN, nvl(d.nombre_provincia, ' ') as provinciaN, nvl(d.nombre_pais, ' ') as paisN, nvl(e.nombre_pais, ' ') as paisName, nvl(e.nombre_provincia, ' ') as provinciaName, nvl(e.nombre_corregimiento, ' ') as corregimientoName, nvl(e.nombre_distrito, ' ') as distritoName, f.codigo as cot, f.descripcion as nameEmpleado, g.codigo as dire, g.descripcion as namedireccion, h.codigo as se, h.descripcion as nameseccion, i.codigo as car, i.denominacion as nameCargo, z.codigo as uno, z.denominacion as nameJefe, j.codigo as est, j.descripcion as nameEstado, k.codigo as fr, k.descripcion as nameForma, l.tipopla as tip, l.descripcion as namePlanilla, m.codigo as hor, m.descripcion as namehorario, n.clave as cls, n.descripcion as nameClave, p.codigo as ubs, p.descripcion as nameUbicacion,a.unidad_organi as gerencia, w.descripcion as nameGerencia from tbl_pla_empleado a, tbl_sec_pais b, tbl_pla_tipo_empleado f, (select codigo_pais, nombre_pais,  decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null, nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,  nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) e, tbl_sec_unidad_ejec g, tbl_sec_unidad_ejec h, tbl_pla_cargo i, tbl_pla_cargo z, tbl_pla_estado_emp j, tbl_pla_f_pago_emp k, tbl_pla_tipo_planilla l, tbl_pla_horario_trab m, tbl_pla_clave_renta n, tbl_sec_unidad_ejec w, tbl_sec_unidad_ejec p where a.nacionalidad = b.codigo(+) and a.pais_dir = d.codigo_pais(+) and a.provincia_dir = d.codigo_provincia(+) and a.distrito_dir = d.codigo_distrito(+) and a.corregimiento_dir = d.codigo_corregimiento(+) and a.comunidad_dir = d.codigo_comunidad(+) and a.pais_nac = e.codigo_pais(+) and a.provincia_nac = e.codigo_provincia(+) and a.distrito_nac = e.codigo_distrito(+) and a.corregimiento_nac = e.codigo_corregimiento(+) and a.tipo_emple=f.codigo and a.ubic_depto=g.codigo(+)and a.unidad_organi = w.codigo(+) and a.compania=g.compania(+) and a.ubic_seccion=h.codigo(+) and a.compania= h.compania(+) and a.CARGO= i.codigo(+) and a.cargo_jefe = z.codigo(+) and a.compania= i.compania(+) and a.estado =j.codigo(+) and a.forma_pago = k.codigo(+) and a.tipo_pla= l.tipopla(+) and a.horario= m.codigo(+) and a.compania=m.compania(+) and a.tipo_renta = n.clave(+) and a.emp_id= "+empId+" and a.compania = z.compania(+) and a.ubic_fisica = p.codigo(+) and a.compania= p.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.compania_uniorg="+(String) session.getAttribute("_companyId")+"";
    	al = SQLMgr.getDataList(sql);
	
	
	/*
//------------------------------ Query EDUCACION  ------------------------------
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.lugar, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.carrera, a.certificado_obt , a.termino, a.nivel , a.tipo as tipo, b.provincia as pr, b.sigla as s, b.tomo as t, b.asiento as ast, b.primer_nombre, b.primer_apellido, c.codigo as cot, c.descripcion as educacioName from tbl_pla_educacion a, tbl_pla_empleado b, tbl_pla_tipo_educacion c where a.emp_id=b.emp_id and a.tipo=c.codigo and a.compania=b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alEduc=SQLMgr.getDataList(sql);
		
		
//=================================  QUERY DE CURSO  =======================
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.descripcion, a.institucion, to_char(a.fecha_inicio,'dd/mm/yyyy') as fecha_inicio, to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, a.duracion, a.tipo, b.codigo as ot, b.descripcion as nameCurso, c.primer_nombre, c.primer_apellido from tbl_pla_cursos_fuera a, tbl_pla_tipo_actividad b, tbl_pla_empleado c where a.tipo=b.codigo(+) and a.emp_id=c.emp_id and a.compania= c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alCurso=SQLMgr.getDataList(sql);
		
	
//=============================== QUERY DE HABILIDADES ========================
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.habilidad, a.calificacion, b.descripcion  as habilidadName, c.primer_apellido, c.primer_nombre  from tbl_pla_habilidad_empl a, tbl_pla_habilidad b, tbl_pla_empleado c where a.habilidad=b.codigo(+) and a.emp_id= c.emp_id 	and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alHabil=SQLMgr.getDataList(sql);


//============================  QUERY DE ENTRETENIMINETO  ==================		
	sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.entretenimiento, a.tipo, b.descripcion as entretenimientoName, c.primer_apellido, c.primer_nombre from tbl_pla_entretenimiento_empl a, tbl_pla_entretenimiento b, tbl_pla_empleado c where a.entretenimiento=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alEntre=SQLMgr.getDataList(sql);
		
			
//============================  QUERY DE IDIOMAS =========================			 
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.idioma, a.nivel_conversacional, a.nivel_lectura, a.nivel_escritura, b.descripcion as nameidioma, c.primer_nombre, c.primer_apellido from tbl_pla_idioma_empl a,tbl_pla_idioma b, tbl_pla_empleado c where a.idioma=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alIdiom=SQLMgr.getDataList(sql);
		
			
//============================  QUERY DE ENFERMEDAD ======================	
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.enfermedad, a.alto_riesgo,b.descripcion as enfermedadName, c.primer_apellido, c.primer_nombre from tbl_pla_enfermedad_empl a, tbl_pla_enfermedad b, tbl_pla_empleado c where a.enfermedad=b.codigo(+) and a.emp_id=c.emp_id and a.compania = c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;
		alEnfe=SQLMgr.getDataList(sql);
		
				
//========================  QUERY DE MEDIDAS DISCIPLINARIAS ==============
sql="select a.provincia, a.sigla, a.tomo, a.asiento, a.tipo_med, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fechamed, a.motivo, a.descripcion, a.autorizapo_por, c.primer_apellido, c.primer_nombre, b.descripcion as medidaName from tbl_pla_medidas_disciplinarias a ,tbl_pla_tipo_medida b, tbl_pla_empleado c where a.tipo_med=b.codigo(+) and a.emp_id=c.emp_id and a.compania= c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;		
		alDisc=SQLMgr.getDataList(sql);
		
		
				
//=========================  QUERY DE RECONOCIMIENTOS  ==================
	
sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, a.motivo, a.descripcion, a.comentario, c.primer_apellido, c.primer_nombre  from tbl_pla_reconocimiento a, tbl_pla_empleado c where a.emp_id=c.emp_id and a.compania=c.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;

	alRecon  = SQLMgr.getDataList(sql);
	
			
//=======================  QUERY DE PARIENTES  =========================
sql="select a.codigo, a.provincia, a.sigla, a.tomo, a.asiento, a.nombre , a.apellido , a.sexo, a.parentesco, a.dependiente, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento , a.vive_con_empleado, a.invalido, a.proteg_por_riesgo, a.trabaja, a.lugar_trabajo, a.telefono_trabajo, a.estudia, a.emp_provincia, a.emp_sigla, a.emp_tomo, a.emp_asiento, a.cod_compania, a.vive, to_char(a.fecha_fallecimiento,'dd/mm/yyyy') as fecha_fallecimiento, a.beneficiario, b.descripcion as parentescoName, c.primer_apellido, c.primer_nombre from tbl_pla_pariente a, tbl_pla_parentesco b, tbl_pla_empleado c where a.parentesco=b.codigo(+) and a.emp_id=c.emp_id and a.cod_compania = c.compania(+) and a.cod_compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+empId;

	alParient = SQLMgr.getDataList(sql);
*/

if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 60; //max lines of items
		int nItems = list.size(); //number of items
		int extraItems = nItems % maxLines;
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page
		if (extraItems == 0) nPages = (nItems / maxLines);
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;
		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
		String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		String cubo = java.util.ResourceBundle.getBundle("path").getString("images")+"/"+"cuboS.JPG";
		String statusPath = "";
		boolean logoMark = true;
		boolean statusMark = false;
		//String currDate = CmnMgr.getCurrentDate("dd/mm/yyyy");

		String folderName = "rhplanilla";
		String fileNamePrefix = "print_expediente";
		String fileNameSuffix = "";
		String fecha = cDateTime;
		//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = null;
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
		String day=fecha.substring(0, 2);
		//System.out.println("Year is: "+year+" Month is: "+month+" Day is: "+day);
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
		String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else {
					
			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
			
			int headerFooterFont = 4;
			
			StringBuffer sbFooter = new StringBuffer();
				
			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;
						
				
			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);
				

		int no = 0;	
		int y=0;
		String pla = "";			
					
for (int j=1; j<=nPages; j++)
{

//***************//GENERAL HEADER BEGIN HERE //*********************//	
				Vector setHeader0=new Vector();
					   setHeader0.addElement(".2");
					   setHeader0.addElement(".8");
					   setHeader0.addElement(".2");
				pc.setNoColumnFixWidth(setHeader0);
	 
				pc.createTable();
				pc.setFont(12, 1);
				pc.addImageCols(""+logoPath,30.0f,0);
				pc.setVAlignment(2);
				pc.addCols(com.getCompLegalName(),1, 1,15.0f);
				pc.addCols("",1,1,15.0f);
				pc.addTable();	
							
				Vector setHeader1 = new Vector();
				setHeader1.addElement(".1000");
				pc.setNoColumnFixWidth(setHeader1);
				
				pc.createTable();
				pc.addBorderCols("1",0,1,1.5f,0.0f,0.0f,0.0f,5.0f);
				pc.addTable();
	
				Vector setHeader9=new Vector();
				setHeader9.addElement(".100");
				pc.setNoColumnFixWidth(setHeader9);

				pc.createTable();
				pc.setFont(9, 1);
				pc.addCols("RUC."+" "+com.getCompRUCNo(),1,1);
				pc.addTable();
				
				pc.createTable();
				pc.setFont(9, 1);
				pc.addCols("Apdo."+" "+com.getCompPAddress()+" "+" "+" "+" "+" "+" "+" "+" Tels."+com.getCompTel1(),1,1);
				pc.addTable();
				
					pc.createTable();
				pc.setFont(9, 1);
				  pc.addCols("PLANILLA",1,1);
				  pc.addCols("EXPEDIENTE DE EMPLEADOS", 1, 1);
				pc.addTable();

			    pc.createTable();
			        pc.setFont(7, 0);
			        pc.addCols("Por: "+userName+"                        Fecha :  "+fecha, 0, 1);
			        pc.addCols("Página: "+j+" de "+nPages, 2, 1);
			    pc.addTable();
	
				Vector setHeader2=new Vector();
					setHeader2.addElement(".15");
					setHeader2.addElement(".55");
					setHeader2.addElement(".10");
					setHeader2.addElement(".20");
				pc.setNoColumnFixWidth(setHeader2);
				
				pc.createTable();
				pc.setFont(7, 1);					
				pc.addCols("", 0,4);
				pc.addTable();
				
				

//*****************************************//
//***************//GENERAL HEADER END HERE
//***************//

//***************//
//***************//GENERAL BODY BEGIN HERE
//*****************************************//	


 
				pc.resetFont();
				setHeader2=new Vector();
					setHeader2.addElement(".15");
					setHeader2.addElement(".55");
					setHeader2.addElement(".10");
					setHeader2.addElement(".20");
				pc.setNoColumnFixWidth(setHeader2);
				pc.createTable();
				pc.addCols("",0,8,1);
				pc.addTable();
						
				
				pc.createTable();
				pc.setFont(9, 1);					
				pc.addBorderCols("DATOS GENERALES DEL EMPLEADO", 0,8); 
				pc.addTable();
				
				
				pc.createTable();
				pc.setFont(7, 1);					
				pc.addCols("", 0,4);
				pc.addTable();
				
				pc.createTable();
				pc.setFont(7, 1);					
				pc.addCols("", 0,4);
				pc.addTable();
					
					
				pc.createTable();
				pc.setFont(8, 1);					
				pc.addCols("", 0,4);
				pc.addTable();
			
				Vector setHeader3=new Vector();
					setHeader3.addElement(".10");
					setHeader3.addElement(".25");
					setHeader3.addElement(".15");
					setHeader3.addElement(".20");
					setHeader3.addElement(".10");
					setHeader3.addElement(".20");
				pc.setNoColumnFixWidth(setHeader3);
				
				pc.resetFont();
				   setHeader3=new Vector();
					setHeader3.addElement(".10");
					setHeader3.addElement(".25");
					setHeader3.addElement(".15");
					setHeader3.addElement(".20");
					setHeader3.addElement(".10");
					setHeader3.addElement(".20");
				pc.setNoColumnFixWidth(setHeader3);
				
				if (al.size()==0) {
						pc.createTable();
							pc.addCols("No existe el código seleccionado",1,5);
						pc.addTable();

						}
				else{
					if (al.size() > 0)
					{
						//for(int i=0;i<maxLines;i++)
						for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)
						{
						if (y < al.size())
						{
						    CommonDataObject cdo1 = (CommonDataObject) al.get(y);
							no += 1;			
				
				pc.createTable();
				pc.setFont(7,1);
				pc.addCols("Primer Nombre.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Nombre1"),0,1);
				pc.addCols("Segundo Nombre:",0,1);
				pc.addCols(" "+cdo1.getColValue("Nombre2"),0,1);
				pc.addCols("Cédula.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Cedula"),0,1);
				pc.addTable();
								
				pc.createTable();
				pc.setFont(7, 1);	
				pc.addCols("Primer Apellido", 0,1);
				pc.addCols(" "+cdo1.getColValue("Apellido1"), 0,1);				
				pc.addCols("Segundo Apellido:", 0,1);
				pc.addCols(" "+cdo1.getColValue("Apellido2"), 0,1);
				pc.addCols("Casada", 0,1);
				pc.addCols(" "+cdo1.getColValue("Casada"), 0,1);
				pc.addTable();
										
  			String strSexo = "";
				pc.createTable();
				pc.setFont(7, 1);		
				pc.addCols("Num. Seguro:", 0,1);
				pc.addCols(" "+cdo1.getColValue("Seguro"), 0,1);
				pc.addCols("Sexo:",0,1);
				pc.addCols(" "+cdo1.getColValue("Sexo"),0,1);
				pc.addCols("Estado Civil:", 0,1);
				pc.addCols(" "+cdo1.getColValue("Civil"), 0,1);
				pc.addTable();
				
			
				pc.createTable();
				pc.setFont(7,1);
				pc.addCols("Telefono:",0,1);
				pc.addCols(" "+cdo1.getColValue("TelCasa"),0,1);
				pc.addCols("Apdo.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Apartado"),0,1);
				pc.addCols("Zona:",0,1);
				pc.addCols(" "+cdo1.getColValue("Zona"),0,1);
				pc.addTable();
				
				pc.createTable();
				pc.setFont(7,1);
				pc.addCols("Dir. Actual:",0,1);
				pc.addCols(" "+cdo1.getColValue("Casa"),0,1);
				pc.addCols("Nacionalidad:",0,1);
				pc.addCols(" "+cdo1.getColValue("Nacionalidad"),0,1);
				pc.addCols("Fecha de Nacimiento.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Fecha"),0,1);
				pc.addTable();
				
				pc.createTable();
				pc.setFont(7,1);					
				pc.addCols("E-mail:",0,1);
				pc.addCols(" "+cdo1.getColValue("Email"),0,1);
				pc.addCols("Fecha de Ingreso.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Fecha"),0,1);
				pc.addCols("Num. Cuenta ACH:", 0,1);
				pc.addCols(" "+cdo1.getColValue("Cta"), 0,1);
				pc.addTable();
				
				pc.createTable();
				pc.setFont(7,1);					
				pc.addCols("Tipo de Sangre:",0,1);
				pc.addCols(" "+cdo1.getColValue("Sangre"),0,1);
				pc.addCols("Otros Telef..:",0,1);
				pc.addCols(" "+cdo1.getColValue("TelOtros"),0,1);
				pc.addCols("Num.Empleado:", 0,1);
				pc.addCols(" "+cdo1.getColValue("NumEmpleado"), 0,1);
				pc.addTable();
					
				
					
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();
				
				pc.createTable();
				pc.setFont(9, 1);					
				pc.addBorderCols("DATOS DEL TRABAJO", 0,8); 
				pc.addTable();
				
				pc.createTable();
				pc.setFont(7, 1);	
				pc.addCols("Gerencia", 0,1);
				pc.addCols(" "+cdo1.getColValue("NameDireccion"), 0,1);				
				pc.addCols("Dirección:", 0,1);
				pc.addCols(" "+cdo1.getColValue("NameGerencia"), 0,1);
				pc.addCols("Sección:", 0,1);
				pc.addCols(" "+cdo1.getColValue("NameSeccion"), 0,1);
				pc.addTable();
				
				pc.createTable();
				pc.setFont(7,1);
				pc.addCols("Cargo.:",0,1);
				pc.addCols(" "+cdo1.getColValue("NameCargo"),0,1);
				pc.addCols("",0,1);
				pc.addCols(" ",0,1);
				pc.addCols("Fecha Ingreso:",0,1);
				pc.addCols(" "+cdo1.getColValue("Ingreso"),0,1);
				pc.addTable();
								
				pc.createTable();
				pc.setFont(7, 1);	
				pc.addCols("Forma Pago", 0,1);
				pc.addCols(" "+cdo1.getColValue("NameForma"), 0,1);				
				pc.addCols("Num.Cuenta:", 0,1);
				pc.addCols(" "+cdo1.getColValue("Cta"), 0,1);
				pc.addCols("Ruta Bancaria", 0,1);
				pc.addCols(" "+cdo1.getColValue("Ruta"), 0,1);
				pc.addTable();
				
					
				pc.createTable();
				pc.setFont(7,1);
				pc.addCols("Salario.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Salario"),0,1);
				pc.addCols("Gasto Rep.",0,1);
				pc.addCols(" "+cdo1.getColValue("Gasto"),0,1);
				pc.addCols("Rata x Hora:",0,1);
				pc.addCols(" "+cdo1.getColValue("Rata"),0,1);
				pc.addTable();
				
					pc.createTable();
				pc.setFont(7,1);
				pc.addCols("Renta Fija.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Renta"),0,1);
				pc.addCols("Horas Labor.",0,1);
				pc.addCols(" "+cdo1.getColValue("Horas"),0,1);
				pc.addCols("Fuero:",0,1);
				pc.addCols(" "+cdo1.getColValue("Fuero"),0,1);
				pc.addTable();
				
								
				pc.createTable();
				pc.setFont(7, 1);	
				pc.addCols("Horario", 0,1);
				pc.addCols(" "+cdo1.getColValue("Namehorario"), 0,3);
				pc.addCols("Clave Renta:",0,1);
				pc.addCols(" "+cdo1.getColValue("Clave"),0,1);				
				pc.addTable();
				
				pc.createTable();
				pc.setFont(7,1);
				pc.addCols("Salario Especie.:",0,1);
				pc.addCols(" "+cdo1.getColValue("Especie"),0,1);
				pc.addCols("Alto Riesgo.",0,1);
				pc.addCols(" "+cdo1.getColValue("Recibe"),0,1);
				pc.addCols("Sindicalizado:",0,1);
				pc.addCols(" "+cdo1.getColValue("Spertenece"),0,1);
				pc.addTable();
				
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();
				
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();
				pc.createTable();
				pc.addCols("",0,6,1);
				pc.addTable();	
				
				y++;
				}								
							if ((i + 1) == nItems)
							{
							
							 	break;
							}	
						}//End For
												
						}//End If
						if((no+2)<=maxLines){
						}else{
							pc.addNewPage();
						}
				}
								
			}//End For
						
	pc.close();
				response.sendRedirect(redirectFile);
		}
		}

%>




