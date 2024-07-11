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
String cargo = request.getParameter("cargo");
String depto = request.getParameter("depto");
String seccion = request.getParameter("sec");


if (appendFilter == null) appendFilter = "";

if (cargo==null) cargo = "";
if (depto==null) depto = "";
if (seccion==null) seccion = "";
if (empId==null) empId = "";

 if (!depto.trim().equals(""))   appendFilter += " and  a.ubic_depto = "+depto;
 if (!seccion.trim().equals(""))   appendFilter += " and  a.seccion = "+seccion;
 if (!empId.trim().equals(""))   appendFilter += " and  a.emp_id = "+empId;
  if (!cargo.trim().equals(""))   appendFilter += " and  a.cargo = '"+cargo+"'";
//if (st != null)

	sql="Select DISTINCT a.EMP_ID,nvl(a.pasaporte,a.provincia|| '-' ||a.sigla|| '-' ||a.tomo|| '-' ||a.asiento) as cedula, a.firma, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, a.primer_nombre as nombre1, nvl(a.segundo_nombre,' ')  as nombre2, a.primer_apellido as apellido1,  nvl(a.segundo_apellido,' ') as apellido2, nvl(a.apellido_casada, ' ') as casada, a.num_empleado as numEmpleado, nvl(a.num_ssocial, ' ') as seguro, a.num_dependiente as dependiente, a.licencia_conducir as conducir, a.OTROS_ING_FIJOS as otros, to_char(a.salario_base,'999,999,990.00') as salario, to_char(a.rata_hora,'99,990.00') as rata, a.REC_ALTO_RIESGO as recibe, nvl(a.calle_dir, ' ') as calle, nvl(a.casa__dir, ' ') as casa, nvl(a.apartado_postal, ' ') as apartado, nvl(a.zona_postal, ' ') as zona, nvl(a.telefono_casa, ' ') as telcasa, nvl(a.telefono_otro, ' ') as telotros, nvl(a.lugar_telefono, ' ') as tellugar, a.nacionalidad as nacionalidadCode, a.NUM_EMP_REMPLAZA as remplazado, to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha,  (( to_number(to_char(SYSDATE,'yyyy')) - to_number(to_char(a.fecha_nacimiento,'yyyy'))) - 1) as edad, a.estado_civil as civil, a.sexo, a.vive_madre as vivemadre, a.vive_padre as vivepadre, nvl(a.nombre_madre, ' ') as madre, nvl(a.nombre_padre, ' ') as padre, nvl(a.emergencia_llamar, ' ') as llamar, a.telefono_emergencia as telefonos, a.num_hijos as hijos, a.num_cuenta as cta, nvl(a.email,' ') AS email, a.fecha_creacion as creacion, nvl(a.comentario, ' ') as comentario, nvl(a.cedula_beneficiario, ' ') as cbeneficiario, nvl(a.nombre_beneficiario, ' ') as nbeneficiario, nvl(a.apellido_beneficiario, ' ') as abeneficiario, nvl(a.num_contrato, ' ') as numero, to_char(a.fecha_contrato,'dd/mm/yyyy') as contrato, to_char(a.fecha_ingreso, 'dd/mm/yyyy') as ingreso, to_char(a.FECHA_EGRESO,'dd/mm/yyyy') as egreso, to_char(a.FECHA_PUESTOACT, 'dd/mm/yyyy') as puestoA, to_char(a.fecha_ult_aumento,'dd/mm/yyyy') as aumento, to_char(a.FECHA_INICIO_INCAPACIDAD, 'dd/mm/yyyy') as incapacidad , a.tipo_emple as tipos,  a.estado, a.tipo_pla as planilla, a.cargo, decode(a.comunidad_dir, null, ' ',a.comunidad_dir ) as comunidadC, decode(a.corregimiento_dir, null, ' ',a.corregimiento_dir) as corregimientoC, decode(a.distrito_dir,  null,'',a.distrito_dir) as distritoC, decode(a.provincia_dir, null, ' ', a.provincia_dir) as provinciaC, decode(a.pais_dir, null, ' ', a.pais_dir ) as paisC, decode(a.corregimiento_nac, null, ' ', a.corregimiento_nac) as corregimientoCode, decode(a.distrito_nac, null, ' ', a.distrito_nac) as distritoCode, decode(a.provincia_nac, null, ' ', a.provincia_nac) as provinciaCode, decode(a.pais_nac, null,' ',a.pais_nac) as paisCode, nvl(a.tipo_renta, ' ') as clave, a.forma_pago as forma, a.compania_uniorg, a.unidad_organi as secciones, nvl(a.tipo_sangre, ' ') as sang, nvl(a.rh, ' ') as sangre, a.tipo_cuenta as ahorro, to_char(a.gasto_rep,'999,999,990.00') as gastos, nvl(a.cargo_jefe, ' ') as jefe, a.sindicato as sindicatos, a.sind_nombre as spertenece, a.fuero, nvl(a.tipo_licencia, ' ') as licencia, nvl(a.numero_licencia, ' ') as nlicencia, a.horario, a.acum_decimo as acumulado, a.acum_decimo_gr as gastoAcum, a.seccion, nvl(a.ruta_bancaria, ' ') as ruta, a.CALCULO_RENTA_ESP as calculo, a.renta_fija as renta, a.valor_renta as valorenta, a.horas_base as horas, a.ubic_depto as direccion, a.ubic_seccion as seccion, a.ubic_fisica as ubicacion, a.usar_apellido_casada as usar, to_char(a.fecha_fin_contrato,'dd/mm/yyyy') as fincontrato, a.digito_verificador as digito, a.salario_especie as especie, a.aseg_grupo, aseg_certificado, a.emp_id, a.jefe_emp_id, nvl(b.nacionalidad, 'NA') as nacionalidad, nvl(d.nombre_comunidad, ' ') as comunidadN, nvl(d.nombre_corregimiento, ' ') as corregimientoN, nvl(d.nombre_distrito, ' ') as distritoN, nvl(d.nombre_provincia, ' ') as provinciaN, nvl(d.nombre_pais, ' ') as paisN, nvl(e.nombre_pais, ' ') as paisName, nvl(e.nombre_provincia, ' ') as provinciaName, nvl(e.nombre_corregimiento, ' ') as corregimientoName, nvl(e.nombre_distrito, ' ') as distritoName, f.codigo as cot, f.descripcion as nameEmpleado, g.codigo as dire, g.descripcion as namedireccion, h.codigo as se, h.descripcion as nameseccion, i.codigo as car, i.denominacion as nameCargo, z.CODIGO as uno, z.DENOMINACION as nameJefe, j.codigo as est, j.descripcion as nameEstado, k.codigo as fr, k.descripcion as nameForma, l.tipopla as tip, l.descripcion as namePlanilla, m.codigo as hor, m.descripcion as namehorario, n.clave as cls, n.descripcion as nameClave, p.codigo as ubs, p.descripcion as nameUbicacion,a.unidad_organi as gerencia, w.descripcion as nameGerencia from tbl_pla_empleado a, tbl_sec_pais b, tbl_pla_tipo_empleado f, (select codigo_pais, nombre_pais,  decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null, nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) d, (select codigo_pais, nombre_pais, decode(codigo_provincia,0,null,codigo_provincia) as codigo_provincia, decode(nombre_provincia,'NA',null,  nombre_provincia) as nombre_provincia, decode(codigo_distrito,0,null,codigo_distrito) as codigo_distrito, decode(nombre_distrito,'NA',null,nombre_distrito) as nombre_distrito,decode(codigo_corregimiento,0,null, codigo_corregimiento) as codigo_corregimiento, decode(nombre_corregimiento,'NA',null,nombre_corregimiento) as nombre_corregimiento, decode(codigo_comunidad,0,null,codigo_comunidad) as codigo_comunidad, decode(nombre_comunidad,'NA',null,nombre_comunidad) as nombre_comunidad from vw_sec_regional_location) e, tbl_sec_unidad_ejec g, tbl_sec_unidad_ejec h, tbl_pla_cargo i, TBL_PLA_CARGO z, tbl_pla_estado_emp j, tbl_pla_f_pago_emp k, tbl_pla_tipo_planilla l, tbl_pla_horario_trab m, tbl_pla_clave_renta n, tbl_sec_unidad_ejec w, tbl_sec_unidad_ejec p where a.nacionalidad = b.codigo(+) and a.pais_dir = d.codigo_pais(+) and a.provincia_dir = d.codigo_provincia(+) and a.distrito_dir = d.codigo_distrito(+) and a.corregimiento_dir = d.codigo_corregimiento(+) and a.comunidad_dir = d.codigo_comunidad(+) and a.pais_nac = e.codigo_pais(+) and a.provincia_nac = e.codigo_provincia(+) and a.distrito_nac = e.codigo_distrito(+) and a.corregimiento_nac = e.codigo_corregimiento(+) and a.tipo_emple=f.codigo and a.UBIC_DEPTO=g.codigo(+)and a.unidad_organi = w.codigo(+) and a.compania=w.compania and a.compania=g.compania(+) and a.ubic_seccion=h.codigo(+) and a.compania= h.compania(+) and a.CARGO= i.codigo(+) and a.CARGO_JEFE = z.CODIGO(+) and a.compania= i.compania(+) and a.ESTADO =j.codigo(+) and a.FORMA_PAGO = k.codigo(+) and a.TIPO_PLA= l.tipopla(+) and a.HORARIO= m.codigo(+) and a.compania=m.compania(+) and a.TIPO_RENTA = n.clave(+) and a.compania = z.COMPANIA(+) and a.UBIC_FISICA = p.codigo(+) and a.compania= p.compania(+) and a.compania="+(String) session.getAttribute("_companyId")+" AND a.COMPANIA_UNIORG="+(String) session.getAttribute("_companyId")+" "+appendFilter;

al = SQLMgr.getDataList(sql);


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
	String subtitle = "INFORMACION GENERAL DE EMPLEADOS";
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
			pc.addCols("",0,8);
			
			pc.setFont(7, 1);
			pc.addBorderCols("DRECCION: ",0,1);
			pc.addBorderCols(" "+cdo.getColValue("namedireccion"),0,7);
			
			}
			
			if (!sec.equalsIgnoreCase(cdo.getColValue("se")))
			{
			
			pc.setFont(7, 1);
			pc.addBorderCols("SECCION: ",0,1);
			pc.addBorderCols(" "+cdo.getColValue("nameseccion"),0,7);
		
			}
			pc.setFont(7, 1);
			pc.addCols("",0,8);
	
			pc.setFont(7, 1);
			pc.addCols("DATOS GENERALES DEL EMPLEADO: ",0,8);
		  pc.setFont(7, 1);
			pc.addCols("",0,8);
			
			
			
		pc.setFont(7, 0);
		pc.setVAlignment(0);
			pc.addCols("Cedula/Pass: ",0,1);
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
	
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
		
	}
		if (al.size() == 0) pc.addCols("No hay información registrada para esta sección ",1,dHeader.size());
		else pc.addCols(al.size()+" Registro(s) en total",0,dHeader.size());
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>