<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Beneficio"%>
<%@ page import="issi.admision.Cama"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="FacDet" scope="session" class="issi.facturacion.Factura"/>
<jsp:useBean id="htCama" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="iAseg" scope="session" class="java.util.Hashtable"/>
<% 
/**
==================================================================================
FLAG      DESCRIPCION
tr2  = PAC_HD     Flag para filtrar pacientes, ambulatorios activos y en espera.
fg= PAC_S Flag para filtrar pacientes de las salas.
fg= PAC_U Flag para filtrar pacientes de las Urgencias.
fg= PAC_SOP Flag para filtrar pacientes de las Salon de Operaciones.
fg= PAC_D Flag para filtrar pacientes para cargos de Dietetica.
fg=CT y fp=cargo_tardio Pagina Expl. Cargo tardio
fg=SALDO  Pagina de Proceso en fact. para generar factura con saldo 0
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
ArrayList alCat = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String tr2 = request.getParameter("tr2");

String status = request.getParameter("status");
String centro = request.getParameter("centro");
String categoria = request.getParameter("categoria");
String tipoAdm = "";
String factura = request.getParameter("factura");
String noAdmision = request.getParameter("noAdmision");
String admRoot = request.getParameter("admRoot");
StringBuffer sbSql  = new  StringBuffer();
if(fg==null) fg = "";
if(fp==null) fp = "";
if(tr2==null) tr2 = "";
if(categoria==null) categoria = "";
if(centro==null) centro = "";
if(factura==null) factura = "";
if(noAdmision==null) noAdmision = "";
if(admRoot==null) admRoot = "";
String dob = request.getParameter("dob");
String compReplica = "",compFar = "";

try{compReplica = java.util.ResourceBundle.getBundle("farmacia").getString("compReplica");}catch(Exception e){compReplica="";}
try{compFar = java.util.ResourceBundle.getBundle("farmacia").getString("compFar");}catch(Exception e){compFar="";}
String compania =(String) session.getAttribute("_companyId");
if(compFar.trim().equals((String) session.getAttribute("_companyId")))compania=compReplica;

String provincia = "", sigla = "", tomo = "", asiento = "", pasaporte = "", cod_paciente = "", nombre = "", no_admision = "";
String estado = "A";
String filterCat = "";
String sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where codigo <> 5 order by codigo";

if(fp.equals("mat_paciente")){
	sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision  order by codigo";
}
else if(fp.equals("DM")){
	if(fg.equals("CU")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where codigo in (1, 2) order by codigo desc";
}else if(fp.equals("consulta_general") || fp.equals("edit_cita")  || fp.equals("secciones_guardadas") ){
	sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision order by codigo";
} else if(fp.equals("cargo_dev_so")){
	sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where codigo in (1, 2, 3, 4) order by codigo";
} else {
	if(fg.equals("salida")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision order by codigo";
	else if(fg.equals("sol_img_estudio") || fg.equals("sol_lab_estudio")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where codigo in (1, 2,3,4) order by codigo";
	else if(fg.equals("HON")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision order by descripcion";
	else if(fg.equals("extension_dias")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where codigo in (1, 5) order by codigo";
	else if(fp.equals("transferencia2")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where codigo in ( select column_value  from table( select split((select get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CAT_ADM_TRANF') from dual),',') from dual  )) order by codigo";
	else if(fg.equals("CT")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision order by codigo";//Explicacion cargo tardio
	else if(fg.equals("CARGO_OC")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision order by codigo";
}
if(fp.equals("corte_manual")) sqlCat = "select codigo, codigo||' - '||descripcion from tbl_adm_categoria_admision where  codigo in (1) order by codigo";

if(!fp.trim().equals("DM")){
if(request.getParameter("categoria")!=null) categoria = request.getParameter("categoria");
else {
	alCat = SQLMgr.getDataList(sqlCat);
	for(int j=0;j<alCat.size();j++){
		CommonDataObject cdo = (CommonDataObject) alCat.get(j);
		categoria = cdo.getColValue("codigo");

		break;
	}
}
}
//if(request.getParameter("categoria") != null && !request.getParameter("categoria").equals("")) categoria = request.getParameter("categoria");
if(request.getParameter("estado")!=null) estado = request.getParameter("estado");



if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if (dob == null) dob = "";// CmnMgr.getCurrentDate("dd/mm/yyyy");

if (request.getMethod().equalsIgnoreCase("GET")){
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null){
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (request.getParameter("provincia") != null && request.getParameter("sigla") != null && request.getParameter("tomo") != null && request.getParameter("asiento") != null && !request.getParameter("provincia").equals("") &&  !request.getParameter("sigla").equals("") &&  !request.getParameter("tomo").equals("") &&  !request.getParameter("asiento").equals("")){
		appendFilter += " and upper(p.provincia) like '"+request.getParameter("provincia").toUpperCase()+"%' and upper(p.sigla) like '"+request.getParameter("sigla").toUpperCase()+"%' and upper(p.tomo) like '"+request.getParameter("tomo").toUpperCase()+"%' and upper(p.asiento) like '"+request.getParameter("asiento").toUpperCase()+"%'";
		provincia = request.getParameter("provincia");
		sigla = request.getParameter("sigla");
		tomo = request.getParameter("tomo");
		asiento = request.getParameter("asiento");
	}
	 if (request.getParameter("pasaporte") != null && !request.getParameter("pasaporte").trim().equals("")){
		appendFilter += " and upper(p.pasaporte) like '%"+request.getParameter("pasaporte").toUpperCase()+"%'";
		pasaporte = request.getParameter("pasaporte");
	}
	 if (request.getParameter("no_admision") != null && !request.getParameter("no_admision").trim().equals("")){
		appendFilter += " and upper(a.secuencia) like '%"+request.getParameter("no_admision").toUpperCase()+"%'";
		no_admision = request.getParameter("no_admision");
	}
	if (request.getParameter("noAdmision") != null && !request.getParameter("noAdmision").trim().equals(""))
	{
		appendFilter += " and a.secuencia <> "+request.getParameter("noAdmision");
		noAdmision = request.getParameter("noAdmision");
	}
	 if (request.getParameter("cod_paciente") != null && !request.getParameter("cod_paciente").trim().equals("")){
		appendFilter += " and upper(a.pac_id) = "+request.getParameter("cod_paciente");
		cod_paciente = request.getParameter("cod_paciente");
	}
	 if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals("")){
		appendFilter += " and upper(p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada))) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
		nombre = request.getParameter("nombre");
	}
	 if (request.getParameter("dob") != null && !request.getParameter("dob").equals("")){
		appendFilter += " and to_char(p.f_nac,'dd/mm/yyyy')='"+dob+"'";
		dob = request.getParameter("dob");
	}
	 if (request.getParameter("tipoAdm") != null && !request.getParameter("tipoAdm").equals("")){
		appendFilter += " and a.categoria = "+request.getParameter("tipoAdm")+"";
		tipoAdm = request.getParameter("tipoAdm");
	}
	 if (request.getParameter("categoria") != null && !request.getParameter("categoria").equals("")){
		appendFilter += " and a.categoria = "+request.getParameter("categoria")+" ";
		categoria = request.getParameter("categoria");
	}
	if(fp.equals("transferencia2"))
	{
		if(fg.equals("TC")){if(!admRoot.trim().equals("")) appendFilter += " and a.adm_root="+admRoot;}
	}

	if(!appendFilter.trim().equals("") || ((request.getParameter("categoria")!=null && !request.getParameter("categoria").trim().equals("")) && (request.getParameter("estado")!=null && !request.getParameter("estado").trim().equals(""))) || (appendFilter.trim().equals("") && (fp.equals("consulta_general") ||fp.equals("SALDO"))))
	{

	if(!fg.equals("salida")&& !fg.equals("CT")&& !fp.equals("DM") && !fp.equals("corte_manual") && !fp.equals("consulta_general")&& !fp.equals("SALDO") && !fp.equals("secciones_guardadas") ) appendFilter += " and a.estado = '"+estado+"' and a.categoria = "+categoria;
	else if (fp.equals("secciones_guardadas")){
	  if (request.getParameter("estado")!=null && !request.getParameter("estado").equals("")) appendFilter += " and a.estado = '"+estado+"'";
	  if (request.getParameter("estado")!=null && !request.getParameter("estado").equals("")) appendFilter += " and a.categoria = '"+categoria+"'";
	}
	
	if(fp.equals("corte_manual")) appendFilter += "and a.estado in('A')";
	if(fp.equals("DM")) appendFilter += " and a.estado ='"+estado+"' " ;
	if((fp.equals("consulta_general")||fp.equals("SALDO")) && (request.getParameter("categoria") == null || request.getParameter("categoria").trim().equals(""))) appendFilter += " and a.categoria in (1, 2, 3, 4)";
	if(fp.equals("consulta_general") && (request.getParameter("estado") == null || request.getParameter("estado").equals(""))) appendFilter += " and a.estado in ('A', 'E', 'S', 'C', 'I', 'N', 'T', 'P')";

	if(request.getParameter("estado") !=null || fg.trim().equals("CU")){
		if (fp.equalsIgnoreCase("cargo_dev") ||fp.equalsIgnoreCase("ajuste_automatico") || fp.equalsIgnoreCase("cargo_oc")|| fp.equalsIgnoreCase("farmacia")|| fp.equalsIgnoreCase("req")){
		sql=" select z.*,substr(z.area_desc,0,15)||'.' area_desc2, nvl(e.clasificacion, ' ') clasificacion, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio from( select all p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), ' ') as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula, p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||','||p.primer_nombre||' '||p.segundo_nombre nombre_completo, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as desc_categoria, a.centro_servicio as area, /*c.descripcion */(select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio) area_desc,  a.medico, decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') mes,(select t.descripcion from tbl_adm_tipo_admision_cia t where t.codigo = a.tipo_admision and t.categoria = a.categoria) dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado ,nvl((select empresa  from tbl_adm_beneficios_x_admision where nvl(estado,'A')= 'A' and  prioridad  = 1 and pac_id=a.pac_id and admision = a.secuencia and rownum =1 ), 0)empresa,nvl(a.embarazada, 'N') embarazada, p.pac_id,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a where a.pac_id = p.pac_id and a.compania ="+compania+" "+appendFilter+" order by  p.primer_apellido, p.segundo_apellido, p.primer_nombre, p.segundo_nombre )z,tbl_adm_empresa e where z.empresa = e.codigo(+) order by z.nombre_completo";

		} else if (fp.equalsIgnoreCase("mat_paciente")){
			sbSql = new StringBuffer();
		if(!UserDet.getUserProfile().contains("0"))
		{
			sbSql.append(" and a.centro_servicio in (");
				if(session.getAttribute("_cds")!=null)
					sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_cds")));
				else sbSql.append("-1");
			sbSql.append(")");
		}
appendFilter += sbSql.toString();
			sql="select z.*,substr(z.area_desc,0,15)||'.' area_desc2,nvl(e.clasificacion, ' ') clasificacion, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio from( select all p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula, p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||','||p.primer_nombre||' '||p.segundo_nombre nombre_completo, decode(a.hosp_directa,'S','HOSPITALIZADA DIRECTO', (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria )) desc_categoria , a.centro_servicio as area,nvl(( select  descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ') area_desc ,a.medico, decode(p.pasaporte,null,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento,p.pasaporte)||'-'||p.d_cedula as cedulaPasaporte,decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') mes, t.descripcion  dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, a.estado, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado,nvl((select empresa  from tbl_adm_beneficios_x_admision where nvl(estado,'A')= 'A' and  prioridad  = 1 and pac_id=a.pac_id and admision = a.secuencia and rownum =1 ), 0)empresa,p.pac_id, nvl(a.hosp_directa, 'N') hosp_directa, nvl((select cama from tbl_adm_atencion_cu where pac_id = a.pac_id and secuencia = a.adm_root),' ') cama,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a ,tbl_adm_tipo_admision_cia t where a.pac_id = p.pac_id and a.estado = '"+estado+"' and a.categoria = "+categoria+"  and a.compania =  "+(String) session.getAttribute("_companyId")+" and t.categoria = a.categoria and t.codigo = a.tipo_admision   "+appendFilter+" order by  p.primer_apellido, p.segundo_apellido, p.primer_nombre, p.segundo_nombre )z,tbl_adm_empresa e where z.empresa = e.codigo(+) order by z.nombre_completo ";

		} else if (fp.equalsIgnoreCase("analisis_fact") || fp.equalsIgnoreCase("corte_manual")|| fp.equalsIgnoreCase("SALDO")|| fp.equalsIgnoreCase("transferencia2")){
			sql="select z.*,substr(z.area_desc,0,15)||'.' area_desc2, nvl(e.clasificacion, ' ') clasificacion, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio,nvl((select nombre from tbl_adm_empresa where codigo=z.empresa ),'') as nombreEmpresa ";
			if (fp.equalsIgnoreCase("analisis_fact")) sql += ", nvl(get_adm_doblecobertura_msg(z.pac_id,z.admision),' ') as doble_msg";
			sql+=" from(select p.nombre_paciente as nombre, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula, p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||','||p.primer_nombre||' '||p.segundo_nombre nombre_completo, decode(a.hosp_directa,'S','HOSPITALIZADA DIRECTO', (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria )) desc_categoria, a.centro_servicio as area, nvl(( select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ') area_desc, a.medico, decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') mes, t.descripcion dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, a.estado, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado,nvl((select empresa  from tbl_adm_beneficios_x_admision where nvl(estado,'A')= 'A' and  prioridad  = 1 and pac_id=a.pac_id and admision = a.secuencia and rownum =1 ), 0)empresa,nvl((select tipo_empresa  from tbl_adm_beneficios_x_admision be,tbl_adm_empresa e where nvl(be.estado,'A')= 'A' and  be.prioridad  = 1 and be.pac_id=a.pac_id and be.admision = a.secuencia and rownum =1 and e.codigo=be.empresa  ), 0)tipo_empresa, nvl(a.embarazada, 'N') embarazada, p.pac_id, nvl(a.hosp_directa, 'N') hosp_directa,p.id_paciente ,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a,  tbl_adm_tipo_admision_cia t where a.pac_id = p.pac_id and a.no_cuenta is null and a.compania =  "+(String) session.getAttribute("_companyId")+"   and t.categoria = a.categoria and t.codigo = a.tipo_admision "+appendFilter+"  /*order by  p.primer_apellido, p.segundo_apellido, p.primer_nombre, p.segundo_nombre*/   )z,tbl_adm_empresa e where z.empresa = e.codigo(+) order by z.nombre_completo";

		} else if (fp.equalsIgnoreCase("salida")){
		sql="select z.*,substr(z.area_desc,0,15)||'.' area_desc2, nvl(e.clasificacion, ' ') clasificacion, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio from(select  p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula, p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||','||p.primer_nombre||' '||p.segundo_nombre nombre_completo, decode(a.hosp_directa,'S','HOSPITALIZADA DIRECTO',  (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria )) desc_categoria, a.centro_servicio as area, nvl(( select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ') area_desc, a.medico, decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') mes, (select descripcion from tbl_adm_tipo_admision_cia where  categoria = a.categoria and codigo = a.tipo_admision ) dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, a.estado, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado, nvl((select empresa  from tbl_adm_beneficios_x_admision where nvl(estado,'A')= 'A' and  prioridad  = 1 and pac_id=a.pac_id and admision = a.secuencia and rownum =1 ), 0)empresa , nvl(a.embarazada, 'N') embarazada, p.pac_id, nvl(a.hosp_directa, 'N') hosp_directa ,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a where a.pac_id = p.pac_id and a.compania = "+(String) session.getAttribute("_companyId")+" "+appendFilter+"   and ((a.estado = 'A' and a.categoria in (1, 5) ) or (a.estado = 'S' and a.categoria = 4 )) )z,tbl_adm_empresa e where z.empresa = e.codigo(+) order by z.nombre_completo ";

		} else if (fp.equalsIgnoreCase("sol_img_estudio") || fp.equals("sol_lab_estudio")){
		sql=" select z.*,substr(z.area_desc,0,15)||'.' area_desc2, nvl(e.clasificacion, ' ') clasificacion, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio from( select  p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula, p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||','||p.primer_nombre||' '||p.segundo_nombre nombre_completo, decode(a.hosp_directa,'S','HOSPITALIZADA DIRECTO',(select descripcion from tbl_adm_categoria_admision where codigo = a.categoria )) desc_categoria, a.centro_servicio as area, nvl(( select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ') area_desc, a.medico, decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') mes, (select descripcion from tbl_adm_tipo_admision_cia where  categoria = a.categoria and codigo = a.tipo_admision ) dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, a.estado, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado,nvl((select empresa  from tbl_adm_beneficios_x_admision where nvl(estado,'A')= 'A' and  prioridad  = 1 and pac_id=a.pac_id and admision = a.secuencia and rownum =1 ), 0)empresa, nvl(a.embarazada, 'N') embarazada, p.pac_id, nvl(a.hosp_directa, 'N') hosp_directa,  decode(p.pasaporte,null,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento,p.pasaporte)||'-'||p.d_cedula as cedulaPasaporte,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a  where a.pac_id = p.pac_id and a.estado = 'A' and a.categoria in (1, 2) and a.compania = "+(String) session.getAttribute("_companyId")+""+appendFilter+" )z,tbl_adm_empresa e where z.empresa = e.codigo(+) order by z.nombre_completo ";

		} else if (fp.equalsIgnoreCase("general_page") && fg.equals("extension_dias")){
		sql="select z.*,substr(z.area_desc,0,15)||'.' area_desc2, nvl(e.clasificacion, ' ') clasificacion, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio from( select p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula, p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||','||p.primer_nombre||' '||p.segundo_nombre nombre_completo, decode(a.hosp_directa,'S','HOSPITALIZADA DIRECTO',(select descripcion from tbl_adm_categoria_admision where codigo = a.categoria )) desc_categoria, a.centro_servicio as area, nvl(( select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ')  area_desc, a.medico,decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') mes, (select descripcion from tbl_adm_tipo_admision_cia where  categoria = a.categoria and codigo = a.tipo_admision ) dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, a.estado, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado,nvl((select empresa  from tbl_adm_beneficios_x_admision where nvl(estado,'A')= 'A' and  prioridad  = 1 and pac_id=a.pac_id and admision = a.secuencia and rownum =1 ), 0)empresa, nvl(a.embarazada, 'N') embarazada, p.pac_id, nvl(a.hosp_directa, 'N') hosp_directa,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a   where a.pac_id = p.pac_id and a.categoria in (1, 5) and a.compania =  "+(String) session.getAttribute("_companyId")+" "+appendFilter+" )z,tbl_adm_empresa e where z.empresa = e.codigo(+) order by z.nombre_completo ";

		} else if (fp.equalsIgnoreCase("cargo_tardio") && fg.equals("CT")){

		sql="select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, a.codigo_paciente as codigo_paciente, a.secuencia as admision, to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso, a.categoria, a.tipo_admision as tipo_admision, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.compania, a.pac_id as pac_id, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, substr((select descripcion from tbl_adm_categoria_admision where codigo =a.categoria),0,4)||'.' as categoriaDesc, a.centro_servicio area , nvl(( select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ') area_desc, nvl(( select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ') area_desc2  ,p.sexo ,'' as clasificacion, 'N' as descuento, 'N' as cambioPrecio, nvl(a.embarazada, 'N') embarazada, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) desc_categoria, decode(a.estado,'A','ACTIVA','E','ESPERA') as desc_estado,p.jubilado, p.estatus, p.pasaporte,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from tbl_adm_admision a, vw_adm_paciente p where a.pac_id=p.pac_id/* and a.CATEGORIA = 1 and p.estatus = 'A' AND  a.FECHA_INGRESO >= to_date('01-01-2003','dd/mm/yyyy')*/ and a.compania="+(String) session.getAttribute("_companyId")+" "+ appendFilter +" order by nvl(a.fecha_ingreso,a.fecha_creacion) desc, nombre, a.secuencia  ";

		}	else if (fp.equalsIgnoreCase("DM")){

				if(!categoria.trim().equals("")) appendFilter += " and a.categoria = "+categoria;
				if(!centro.trim().equals("")) appendFilter += " and em.centro_servicio = "+centro+" and d.codigo ="+centro;
				appendFilter += " and em.centro_servicio = d.codigo";

			sql= "select  distinct to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso,nvl(decode(a.fecha_egreso,null, to_char(sysdate,'dd/mm/yyyy') ,to_char(a.fecha_egreso,'dd/mm/yyyy')),' ') as fecha_egreso ,a.categoria ,a.tipo_admision as tipo_admision ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento ,nvl(p.d_cedula, ' ') d_cedula, p.edad, p.edad_mes, p.edad_dias, a.compania, a.pac_id as pac_id, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, a.centro_servicio , d.descripcion as centro_servicio_desc ,p.sexo ,' ' as clasificacion, 'N' as descuento, 'N' as cambioPrecio, nvl(a.embarazada, 'N') embarazada, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula ,p.codigo codigo_paciente ,to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento ,a.secuencia admision ,a.estado estado ,decode(a.categoria,1,'HOSPITALIZADO',2,'AMBULATORIO') desc_categoria,  decode(a.estado,'A','ACTIVA','E','ESPERA') as desc_estado,p.jubilado, p.estatus, nvl(p.pasaporte,' ')pasaporte ,ta.descripcion dsp_tipo_admision ,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from  vw_adm_paciente p ,tbl_adm_admision a ,tbl_inv_entrega_material em ,tbl_adm_tipo_admision_cia ta, tbl_cds_centro_servicio d where a.pac_id = p.pac_id and em.pac_id = p.pac_id and a.compania="+(String) session.getAttribute("_companyId")+ appendFilter+ " and a.estado ='"+estado+"' and (ta.categoria   = a.categoria and ta.codigo = a.tipo_admision)  order by   to_date(to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy'),'dd/mm/yyyy') desc , nombre, a.secuencia ";


				String fgFilter1 ="";
		} else if (fp.equalsIgnoreCase("consulta_general")){
			if(request.getParameter("factura")!=null && !request.getParameter("factura").equals("")) appendFilter += " and exists (select 1 from tbl_fac_factura f where codigo = '"+request.getParameter("factura")+"' and a.pac_id = f.pac_id and a.secuencia = f.admi_secuencia)";
			sql= "select  distinct to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso ,nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso ,a.categoria ,a.tipo_admision as tipo_admision ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento ,nvl(p.d_cedula, ' ') d_cedula, p.edad, p.edad_mes, p.edad_dias, a.compania, a.pac_id as pac_id, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, substr(c.descripcion,0,4)||'.' as categoriadesc, a.centro_servicio , d.descripcion as centro_servicio_desc ,p.sexo ,' ' as clasificacion, 'N' as descuento, 'N' as cambioPrecio, nvl(a.embarazada, 'N') embarazada, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula ,p.codigo codigo_paciente ,to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, a.secuencia admision ,a.estado estado ,(select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) desc_categoria,  decode(a.estado,'A','ACTIVA','E','ESPERA') as desc_estado,p.jubilado, p.estatus, nvl(p.pasaporte,' ')pasaporte ,ta.descripcion dsp_tipo_admision, d.descripcion as area_desc2,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from  vw_adm_paciente p ,tbl_adm_admision a, /*tbl_inv_entrega_material em ,*/ tbl_adm_tipo_admision_cia ta, tbl_adm_categoria_admision c, tbl_cds_centro_servicio d where /*em.fecha_nacimiento = p.fecha_nacimiento and em.paciente = p.codigo and*/ a.fecha_nacimiento = p.fecha_nacimiento and a.pac_id = p.pac_id and a.codigo_paciente = p.codigo and ta.categoria = a.categoria and ta.codigo = a.tipo_admision and a.compania="+(String) session.getAttribute("_companyId")+ appendFilter+ " and a.categoria = c.codigo and a.centro_servicio=d.codigo order by to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') desc , nombre, a.secuencia";
		} else if (fp.equalsIgnoreCase("cargo_dev_so")){
			sql = "select all p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, nvl(p.provincia,0) provincia, nvl(p.sigla,' ') sigla, nvl(p.tomo,0) tomo, p.edad, p.edad_mes, p.edad_dias, nvl(p.asiento,0) asiento, nvl(p.d_cedula, ' ') d_cedula, a.secuencia admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'), to_char(sysdate,'dd/mm/yyyy')) as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula cedula, p.primer_apellido||' '||p.segundo_apellido||'  '||p.apellido_de_casada||','||p.primer_nombre||' '||p.segundo_nombre nombre_completo, decode(a.hosp_directa,'S','HOSPITALIZADA DIRECTO', f.descripcion) desc_categoria, c.codigo as area, c.descripcion area_desc, a.medico, decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') mes, t.descripcion dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, a.estado, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado, nvl(b.empresa,0) empresa, nvl(e.clasificacion, ' ') clasificacion, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio, nvl(a.embarazada, 'N') embarazada, p.pac_id, nvl(a.hosp_directa, 'N') hosp_directa,  decode(p.pasaporte,null,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento,p.pasaporte)||'-'||p.d_cedula as cedulaPasaporte, nvl(( select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio),' ') area_desc2,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a, tbl_cds_centro_servicio c, tbl_adm_tipo_admision_cia t, tbl_adm_categoria_admision f, (select distinct pac_id, admision, empresa from tbl_adm_beneficios_x_admision where nvl(estado,'N')= 'A' and prioridad = 1) b, tbl_adm_empresa e where a.pac_id = p.pac_id and a.compania = "+(String) session.getAttribute("_companyId")+" and c.codigo = a.centro_servicio and t.categoria = a.categoria and t.codigo = a.tipo_admision and f.codigo = t.categoria "+appendFilter+" and a.pac_id = b.pac_id(+) and a.secuencia = b.admision(+) and b.empresa = e.codigo(+) and a.estado in ('A', 'E') and a.categoria in (1, 2, 3, 4) and a.compania = "+(String) session.getAttribute("_companyId")+" order by  p.primer_apellido, p.segundo_apellido, p.primer_nombre, p.segundo_nombre";

		} else if (fp.equalsIgnoreCase("edit_cita") || fp.equalsIgnoreCase("secciones_guardadas") || fp.equalsIgnoreCase("citas_cons")){

			sql= "select  distinct to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso ,nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso ,a.categoria ,a.tipo_admision as tipo_admision ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento ,nvl(p.d_cedula, ' ') d_cedula,p.edad, p.edad_mes, p.edad_dias, a.compania, a.pac_id as pac_id, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, substr((select descripcion from tbl_adm_categoria_admision where codigo = a.categoria),0,4)||'.' as categoriadesc, a.centro_servicio , d.descripcion as centro_servicio_desc, d.descripcion as area_desc2 ,p.sexo ,' ' as clasificacion, 'N' as descuento, 'N' as cambioPrecio, nvl(a.embarazada, 'N') embarazada, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula ,p.codigo codigo_paciente ,to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, a.secuencia admision ,a.estado estado, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as desc_categoria,  decode(a.estado,'A','ACTIVA','E','ESPERA') as desc_estado,p.jubilado, p.estatus, nvl(p.pasaporte,' ')pasaporte ,ta.descripcion dsp_tipo_admision,id_paciente as cedulaPasaporte ,g.empresa,h.nombre nombreEmpresa,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from  vw_adm_paciente p ,tbl_adm_admision a, tbl_adm_tipo_admision_cia ta, tbl_cds_centro_servicio d, (select empresa,pac_id,admision from tbl_adm_beneficios_x_admision where nvl(estado,'A')='A' and prioridad=1) g, tbl_adm_empresa h where a.pac_id = p.pac_id and a.codigo_paciente = p.codigo and ta.categoria = a.categoria and ta.codigo = a.tipo_admision and a.compania="+(String) session.getAttribute("_companyId")+ appendFilter+ " /*and (a.estado in ('A','P') or (a.categoria = 2 and a.tipo_admision in (1, 4, 14) and a.estado = 'E'))*/ and a.centro_servicio=d.codigo and a.pac_id=g.pac_id(+) and a.secuencia=g.admision(+) and g.empresa=h.codigo(+) order by to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') desc , nombre, a.secuencia";

			System.out.println("SQL==:"+sql);
		}
		else if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext") || fp.equalsIgnoreCase("cds_solicitud_ima"))
		{
			sql = "select p.primer_nombre, nvl(p.segundo_nombre,' ') as segundo_nombre, nvl(p.primer_apellido,' ') as primer_apellido, nvl(p.segundo_apellido,' ') as segundo_apellido, nvl(p.apellido_de_casada,' ') as apellido_de_casada, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, nvl(p.provincia,0) as provincia, nvl(p.sigla,' ') as sigla, nvl(p.tomo,0) as tomo, nvl(p.asiento,0) as asiento, nvl(p.d_cedula,' ') as d_cedula, p.edad, p.edad_mes, p.edad_dias, a.secuencia as admision, a.codigo_paciente, to_char(p.fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fecha_ingreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso, p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula as cedula, p.primer_apellido||' '||p.segundo_apellido||' '||p.apellido_de_casada||', '||p.primer_nombre||' '||p.segundo_nombre as nombre_completo, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as desc_categoria, c.codigo as area, c.descripcion as area_desc, a.medico, decode(a.mes_cta_bolsa,'ENE','ENERO','FEB','FEBRERO','MAR','MARZO','ABR','ABRIL','MAY','MAYO','JUN','JUNIO','JUL','JULIO','AGO','AGOSTO','SEP','S EPTIEMBRE','OCT','OCTUBRE','NOV','NOVIEMBRE','DIC','DICIEMBRE','NA') as mes, t.descripcion as dsp_tipo_admision, a.categoria, p.sexo, p.estatus, p.pasaporte, decode(a.estado,'A','ACTIVA','E','ESPERA','S','ESPECIAL','C','CANCELADA') as desc_estado, p.jubilado, nvl(b.empresa,0) as empresa, nvl(e.clasificacion,' ') as clasificacion, nvl(e.nombre,' ') as empresa_nombre, nvl(e.descuento,'N') as descuento, nvl(e.cambio_precio,'N') as cambioPrecio, nvl(a.embarazada,'N') embarazada, p.pac_id, decode(m.sexo,'F','DRA. ','DR. ')||m.primer_nombre||decode(m.segundo_nombre,null,'',' '||m.segundo_nombre)||' '||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,null,'',' '||m.apellido_de_casada)) as nombre_medico, a.medico_cabecera, decode(mc.sexo,null,' ','F','DRA. ','DR. ')||decode(mc.primer_nombre,null,' ',mc.primer_nombre||decode(mc.segundo_nombre,null,'',' '||mc.segundo_nombre)||' '||mc.primer_apellido||decode(mc.segundo_apellido,null,'',' '||mc.segundo_apellido)||decode(mc.sexo,'F',decode(mc.apellido_de_casada,null,'',' '||mc.apellido_de_casada))) as nombre_medico_cabecera, p.residencia_direccion, p.telefono,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p, tbl_adm_admision a, tbl_cds_centro_servicio c, tbl_adm_tipo_admision_cia t, (select * from tbl_adm_beneficios_x_admision where nvl(estado,'A')='A' and prioridad=1) b, tbl_adm_empresa e, tbl_adm_medico m, tbl_adm_medico mc where a.pac_id=p.pac_id and a.compania="+(String) session.getAttribute("_companyId")+" and c.codigo=a.centro_servicio and t.categoria=a.categoria and t.codigo=a.tipo_admision"+appendFilter+" and a.codigo_paciente=b.paciente(+) and a.fecha_nacimiento=b.fecha_nacimiento(+) and a.secuencia=b.admision(+) and b.empresa=e.codigo(+) and a.medico=m.codigo and a.medico_cabecera=mc.codigo(+) order by p.primer_apellido, p.segundo_apellido, p.primer_nombre, p.segundo_nombre";
		}
		else if (fp.equalsIgnoreCase("rpt_pagos_aplicados")){
			sql= "select  distinct to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso ,nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso ,a.categoria ,a.tipo_admision as tipo_admision ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento ,nvl(p.d_cedula, ' ') d_cedula,p.edad, p.edad_mes, p.edad_dias, a.compania, a.pac_id as pac_id, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, substr((select descripcion from tbl_adm_categoria_admision where codigo = a.categoria),0,4)||'.' as categoriadesc, a.centro_servicio , d.descripcion as centro_servicio_desc ,p.sexo ,' ' as clasificacion, 'N' as descuento, 'N' as cambioPrecio, nvl(a.embarazada, 'N') embarazada,  nvl(p.pasaporte,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula) as cedula ,p.codigo codigo_paciente ,to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, a.secuencia admision ,a.estado estado, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) desc_categoria,  decode(a.estado,'A','ACTIVA','E','EN ESPERA','P','PRE-ADMISION',a.estado) as desc_estado,p.jubilado, p.estatus, nvl(p.pasaporte,' ')pasaporte ,ta.descripcion dsp_tipo_admision ,to_char(p.f_nac,'dd/mm/yyyy') as f_nac from vw_adm_paciente p ,tbl_adm_admision a, tbl_adm_tipo_admision_cia ta, tbl_cds_centro_servicio d where a.pac_id = p.pac_id and a.codigo_paciente = p.codigo and ta.categoria = a.categoria and ta.codigo = a.tipo_admision and a.compania="+(String) session.getAttribute("_companyId")+ appendFilter+ " /*****************************************/ and a.centro_servicio=d.codigo order by to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') desc , nombre, a.secuencia";
            
		}else if (fp.equalsIgnoreCase("liq_recl")){
			sql= "select  distinct to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') as fecha_ingreso ,nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fecha_egreso ,a.categoria ,a.tipo_admision as tipo_admision ,nvl(p.provincia,0) provincia ,nvl(p.sigla,' ') sigla ,nvl(p.tomo,0) tomo ,nvl(p.asiento,0) asiento ,nvl(p.d_cedula, ' ') d_cedula, nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))/12),0) as edad, nvl(mod(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))),12),0) as edad_mes, (nvl(a.fecha_ingreso,a.fecha_creacion)-add_months(coalesce(p.f_nac,a.fecha_nacimiento),(nvl(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))/12),0)*12+nvl(mod(trunc(months_between(nvl(a.fecha_ingreso,a.fecha_creacion),coalesce(p.f_nac,a.fecha_nacimiento))),12),0)))) as edad_dias, a.compania, a.pac_id as pac_id, p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)) as nombre, substr((select descripcion from tbl_adm_categoria_admision where codigo = a.categoria),0,4)||'.' as categoriadesc, a.centro_servicio , d.descripcion as centro_servicio_desc ,p.sexo ,' ' as clasificacion, 'N' as descuento, 'N' as cambioPrecio, nvl(a.embarazada, 'N') embarazada,  nvl(p.pasaporte,p.provincia||'-'||p.sigla||'-'||p.tomo||'-'||p.asiento||'-'||p.d_cedula) as cedula ,p.codigo codigo_paciente ,to_char(p.fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, a.secuencia admision ,a.estado estado, (select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) desc_categoria,  decode(a.estado,'A','ACTIVA','E','EN ESPERA','P','PRE-ADMISION',a.estado) as desc_estado,p.jubilado, p.estatus, nvl(p.pasaporte,' ')pasaporte ,ta.descripcion dsp_tipo_admision, bb.poliza, ff.codigo as fac from  tbl_adm_paciente p ,tbl_adm_admision a, tbl_adm_tipo_admision_cia ta, tbl_cds_centro_servicio d, (select * from tbl_adm_beneficios_x_admision where nvl(estado,'A')='A' and prioridad=1) bb, tbl_fac_factura ff  where a.pac_id = p.pac_id and a.codigo_paciente = p.codigo and ta.categoria = a.categoria and ta.codigo = a.tipo_admision and a.compania="+(String) session.getAttribute("_companyId")+ appendFilter+ " /*****************************************/ and a.centro_servicio=d.codigo and a.codigo_paciente=bb.paciente(+) and a.fecha_nacimiento=bb.fecha_nacimiento(+) and a.secuencia=bb.admision(+) and bb.empresa in ( select codigo from tbl_adm_empresa where tipo_empresa = get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'LIQ_RECL_TIPO_EMP') ) and ff.pac_id = a.pac_id and ff.admi_secuencia = a.secuencia and ff.facturar_a = 'E' and ff.estatus = 'P' order by to_char(nvl(a.fecha_ingreso,a.fecha_creacion),'dd/mm/yyyy') desc , nombre, a.secuencia /*------------------------*/";
		}
        
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	}//appendFilter
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Paciente - '+document.title;

function setPaciente(k)
{
	if (eval('document.paciente.estatus'+k).value.toUpperCase() == 'I' && '<%=fp%>' != 'consulta_general' && '<%=fp%>' != 'farmacia' && '<%=fp%>' != 'liq_recl' ){
		alert('No está permitido seleccionar pacientes inactivos!!');
	}	else {
<%
	if(fp.equalsIgnoreCase("cargo_dev") || fp.equalsIgnoreCase("cargo_tardio") || fp.equalsIgnoreCase("ajuste_automatico") || fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext") || fp.equalsIgnoreCase("cds_solicitud_ima")){
%>
		window.opener.document.paciente.codigoPaciente.value 	= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.paciente.pacienteId.value 					= eval('document.paciente.pac_id'+k).value;
		window.opener.document.paciente.provincia.value 			= eval('document.paciente.provincia'+k).value;
		window.opener.document.paciente.sigla.value 					= eval('document.paciente.sigla'+k).value;
		window.opener.document.paciente.tomo.value 						= eval('document.paciente.tomo'+k).value;
		window.opener.document.paciente.asiento.value 				= eval('document.paciente.asiento'+k).value;
		window.opener.document.paciente.dCedula.value 				= eval('document.paciente.dCedula'+k).value;
		window.opener.document.paciente.pasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		if(eval('document.paciente.cedula'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value = eval('document.paciente.cedula'+k).value;
		else if(eval('document.paciente.pasaporte'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		//window.opener.document.paciente.pacienteId.value 		= eval('document.paciente.pacienteId'+k).value;
		window.opener.document.paciente.nombrePaciente.value 	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.paciente.fechaNacimiento.value	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.paciente.fechaIngreso.value		= eval('document.paciente.fechaIngreso'+k).value;
		window.opener.document.paciente.fechaEgreso.value			= eval('document.paciente.fechaEgreso'+k).value;
		window.opener.document.paciente.categoria.value				= eval('document.paciente.categoria'+k).value;
		window.opener.document.paciente.categoriaDesc.value		= eval('document.paciente.categoriaDesc'+k).value;
		window.opener.document.paciente.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		window.opener.document.paciente.estado.value					= eval('document.paciente.estado'+k).value;
		window.opener.document.paciente.desc_estado.value			= eval('document.paciente.desc_estado'+k).value;
		window.opener.document.paciente.empresa.value					= eval('document.paciente.empresa'+k).value;
		window.opener.document.paciente.clasificacion.value		= eval('document.paciente.clasificacion'+k).value;
		window.opener.document.paciente.edad.value						= eval('document.paciente.edad'+k).value;
		window.opener.document.paciente.embarazada.value			= eval('document.paciente.embarazada'+k).value;
		if(window.opener.document.paciente.f_nac)window.opener.document.paciente.f_nac.value	= eval('document.paciente.f_nac'+k).value;

		if(eval('document.paciente.jubilado'+k).value =='S'){
			window.opener.document.paciente.jubilado.checked = true;
			window.opener.document.paciente.jubilado.value = 'S';
		} else {
			window.opener.document.paciente.jubilado.checked = false;
			window.opener.document.paciente.jubilado.value = 'N';
		}

		window.opener.document.paciente.descuento.value				= eval('document.paciente.descuento'+k).value;
		window.opener.document.paciente.cambioPrecio.value		= eval('document.paciente.cambioPrecio'+k).value;
		window.opener.document.paciente.edad_mes.value				= eval('document.paciente.edad_mes'+k).value;
		window.opener.document.paciente.edad_dias.value				= eval('document.paciente.edad_dias'+k).value;
		window.opener.document.getElementById('lbl_edad').innerHTML = eval('document.paciente.edad'+k).value;
		window.opener.document.getElementById('lbl_edad_mes').innerHTML = eval('document.paciente.edad_mes'+k).value;
		window.opener.document.getElementById('lbl_edad_dias').innerHTML = eval('document.paciente.edad_dias'+k).value;
		window.opener.document.paciente.cds.value							= eval('document.paciente.area'+k).value;
		window.opener.document.paciente.cdsDesc.value					= eval('document.paciente.area_desc'+k).value;
		window.opener.document.paciente.medicoCabecera.value	= eval('document.paciente.medico_cabecera'+k).value;
		window.opener.document.paciente.nombreMedicoCabecera.value	= eval('document.paciente.nombre_medico_cabecera'+k).value;
		window.opener.document.paciente.empresaNombre.value		= eval('document.paciente.empresa_nombre'+k).value;
		window.opener.document.paciente.medico.value					= eval('document.paciente.medico'+k).value;
		window.opener.document.paciente.nombreMedico.value		= eval('document.paciente.nombre_medico'+k).value;
		window.opener.document.paciente.primerNombre.value		= eval('document.paciente.primer_nombre'+k).value;
		window.opener.document.paciente.segundoNombre.value		= eval('document.paciente.segundo_nombre'+k).value;
		window.opener.document.paciente.primerApellido.value		= eval('document.paciente.primer_apellido'+k).value;
		window.opener.document.paciente.segundoApellido.value		= eval('document.paciente.segundo_apellido'+k).value;
		window.opener.document.paciente.apellidoDeCasada.value		= eval('document.paciente.apellido_de_casada'+k).value;
		window.opener.document.paciente.sexo.value		= eval('document.paciente.sexo'+k).value;
		window.opener.document.paciente.residenciaDireccion.value		= eval('document.paciente.residenciaDireccion'+k).value;
		window.opener.document.paciente.telefono.value		= eval('document.paciente.telefono'+k).value;

		<%if(!fp.equalsIgnoreCase("ajuste_automatico") && !fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") && !fp.equalsIgnoreCase("cds_solicitud_lab_ext") && !fp.equalsIgnoreCase("cds_solicitud_ima")){%>
		window.opener.document.form0.codigoPaciente.value 	= eval('document.paciente.codigo_paciente'+k).value;
		<%}if(fp.equalsIgnoreCase("cargo_tardio")){%>
		//alert(eval('document.paciente.pac_id'+k).value);
		window.opener.document.form0.pac_id.value 	= eval('document.paciente.pac_id'+k).value;
		window.opener.document.form0.fecha_nacimiento.value 	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.form0.admision.value 	= eval('document.paciente.admision'+k).value;
		if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value	= eval('document.paciente.f_nac'+k).value;
		<%}%>
		<%if(fp.equalsIgnoreCase("cargo_dev")){%>
		//alert(eval('document.paciente.pac_id'+k).value);
		window.opener.document.paciente.pacienteId.value 	= eval('document.paciente.pac_id'+k).value;
		<%}%>
<%}
else if (fp.equalsIgnoreCase("mat_paciente")){
%>
		//PARA LIMPIAR LOS CAMPOS SOLICITADO POR Y SOLICITADO A.

		<%if(!fg.equals("HEM")){%>
		window.opener.document.requisicion.centroServicio.value = eval('document.paciente.area'+k).value;
		window.opener.setCSValues();
		window.opener.document.requisicion.tipoCds.value ='';
		window.opener.document.requisicion.reportaA.value = '';
		window.opener.document.requisicion.incremento.value = '';
		window.opener.document.requisicion.tipoInc.value = '';
		<%}
		if(!fg.equals("SOP") && !fg.equals("HEM") && !fg.equals("DIET")){%>
		<%if(tr2 == null || tr2.trim().equals("")){%>
		//window.opener.document.requisicion.codigo_almacen.value = '';
		//window.opener.document.requisicion.desc_codigo_almacen.value = '';
		<%}%>
		if(eval('document.paciente.hosp_directa'+k).value =='S'){
			window.opener.document.requisicion.hospitalizada.checked = true;
			window.opener.document.requisicion.hospitalizada.value = 'S';
		} else {
			window.opener.document.requisicion.hospitalizada.checked = false;
			window.opener.document.requisicion.hospitalizada.value = 'N';
		}
		<%}%>
		window.opener.document.paciente.codigoPaciente.value 	= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.paciente.pacienteId.value 			= eval('document.paciente.pac_id'+k).value;
		window.opener.document.paciente.provincia.value 			= eval('document.paciente.provincia'+k).value;
		window.opener.document.paciente.sigla.value 					= eval('document.paciente.sigla'+k).value;
		window.opener.document.paciente.tomo.value 						= eval('document.paciente.tomo'+k).value;
		window.opener.document.paciente.asiento.value 				= eval('document.paciente.asiento'+k).value;
		window.opener.document.paciente.dCedula.value 				= eval('document.paciente.dCedula'+k).value;
		window.opener.document.paciente.pasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		//window.opener.document.paciente.pacienteId.value 		= eval('document.paciente.pacienteId'+k).value;
		if(eval('document.paciente.cedula'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value = eval('document.paciente.cedula'+k).value;
		else if(eval('document.paciente.pasaporte'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		window.opener.document.paciente.nombrePaciente.value 	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.paciente.fechaNacimiento.value	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.paciente.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		window.opener.document.paciente.categoria.value				= eval('document.paciente.categoria'+k).value;
		window.opener.document.paciente.categoriaDesc.value		= eval('document.paciente.categoriaDesc'+k).value;
		window.opener.document.paciente.fechaIngreso.value		= eval('document.paciente.fechaIngreso'+k).value;
		window.opener.document.paciente.fechaEgreso.value			= eval('document.paciente.fechaEgreso'+k).value;
		window.opener.document.paciente.estado.value					= eval('document.paciente.estado'+k).value;
		window.opener.document.paciente.desc_estado.value			= eval('document.paciente.desc_estado'+k).value;
		window.opener.document.paciente.empresa.value					= eval('document.paciente.empresa'+k).value;
		window.opener.document.paciente.clasificacion.value		= eval('document.paciente.clasificacion'+k).value;
		window.opener.document.paciente.edad.value						= eval('document.paciente.edad'+k).value;
		window.opener.document.paciente.embarazada.value			= eval('document.paciente.embarazada'+k).value;
		window.opener.document.requisicion.area_desc.value		= eval('document.paciente.area_desc'+k).value;

		window.opener.document.paciente.descuento.value				= eval('document.paciente.descuento'+k).value;
		window.opener.document.paciente.cambioPrecio.value		= eval('document.paciente.cambioPrecio'+k).value;
		window.opener.document.paciente.edad_mes.value				= eval('document.paciente.edad_mes'+k).value;
		window.opener.document.paciente.edad_dias.value				= eval('document.paciente.edad_dias'+k).value;
		window.opener.document.paciente.cds.value							= eval('document.paciente.area'+k).value;
		window.opener.document.paciente.cdsDesc.value					= eval('document.paciente.area_desc'+k).value;
		window.opener.document.paciente.medicoCabecera.value	= eval('document.paciente.medico_cabecera'+k).value;
		window.opener.document.paciente.nombreMedicoCabecera.value	= eval('document.paciente.nombre_medico_cabecera'+k).value;
		window.opener.document.paciente.empresaNombre.value		= eval('document.paciente.empresa_nombre'+k).value;
		window.opener.document.paciente.medico.value					= eval('document.paciente.medico'+k).value;
		window.opener.document.paciente.nombreMedico.value		= eval('document.paciente.nombre_medico'+k).value;

		window.opener.document.requisicion.hosp_directa.value	= eval('document.paciente.hosp_directa'+k).value;
		window.opener.document.paciente.cedulaPasaporte.value	= eval('document.paciente.cedulaPasaporte'+k).value;
		window.opener.document.paciente.cama.value	= eval('document.paciente.cama'+k).value;
		if(window.opener.document.paciente.f_nac)window.opener.document.paciente.f_nac.value	= eval('document.paciente.f_nac'+k).value;
		<%if(fg.trim().equals("SAL")){%>
		window.opener.document.requisicion.cama.value	= eval('document.paciente.cama'+k).value;
		<%}%>
<%
	} else if (fp.equalsIgnoreCase("sol_img_estudio") || fp.equals("sol_lab_estudio")){
%>
		window.opener.document.paciente.codigoPaciente.value 	= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.paciente.pacienteId.value 			= eval('document.paciente.pac_id'+k).value;
		window.opener.document.paciente.provincia.value 			= eval('document.paciente.provincia'+k).value;
		window.opener.document.paciente.sigla.value 					= eval('document.paciente.sigla'+k).value;
		window.opener.document.paciente.tomo.value 						= eval('document.paciente.tomo'+k).value;
		window.opener.document.paciente.asiento.value 				= eval('document.paciente.asiento'+k).value;
		window.opener.document.paciente.dCedula.value 				= eval('document.paciente.dCedula'+k).value;
		window.opener.document.paciente.pasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		//window.opener.document.paciente.pacienteId.value 		= eval('document.paciente.pacienteId'+k).value;
		if(eval('document.paciente.cedula'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value = eval('document.paciente.cedula'+k).value;
		else if(eval('document.paciente.pasaporte'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		window.opener.document.paciente.nombrePaciente.value 	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.paciente.fechaNacimiento.value	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.paciente.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		window.opener.document.paciente.categoria.value				= eval('document.paciente.categoria'+k).value;
		window.opener.document.paciente.categoriaDesc.value		= eval('document.paciente.categoriaDesc'+k).value;
		window.opener.document.paciente.fechaIngreso.value		= eval('document.paciente.fechaIngreso'+k).value;
		window.opener.document.paciente.fechaEgreso.value			= eval('document.paciente.fechaEgreso'+k).value;
		window.opener.document.paciente.estado.value					= eval('document.paciente.estado'+k).value;
		window.opener.document.paciente.desc_estado.value			= eval('document.paciente.desc_estado'+k).value;
		window.opener.document.paciente.empresa.value					= eval('document.paciente.empresa'+k).value;
		window.opener.document.paciente.clasificacion.value		= eval('document.paciente.clasificacion'+k).value;
		window.opener.document.paciente.edad.value						= eval('document.paciente.edad'+k).value;
		window.opener.document.paciente.embarazada.value			= eval('document.paciente.embarazada'+k).value;
		window.opener.document.paciente.cedulaPasaporte.value	= eval('document.paciente.cedulaPasaporte'+k).value;

		window.opener.document.paciente.descuento.value				= eval('document.paciente.descuento'+k).value;
		window.opener.document.paciente.cambioPrecio.value		= eval('document.paciente.cambioPrecio'+k).value;
		window.opener.document.paciente.edad_mes.value				= eval('document.paciente.edad_mes'+k).value;
		window.opener.document.paciente.edad_dias.value				= eval('document.paciente.edad_dias'+k).value;
		window.opener.document.paciente.cds.value							= eval('document.paciente.area'+k).value;
		window.opener.document.paciente.cdsDesc.value					= eval('document.paciente.area_desc'+k).value;
		window.opener.document.paciente.medicoCabecera.value	= eval('document.paciente.medico_cabecera'+k).value;
		window.opener.document.paciente.nombreMedicoCabecera.value	= eval('document.paciente.nombre_medico_cabecera'+k).value;
		window.opener.document.paciente.empresaNombre.value		= eval('document.paciente.empresa_nombre'+k).value;
		window.opener.document.paciente.medico.value					= eval('document.paciente.medico'+k).value;
		window.opener.document.paciente.nombreMedico.value		= eval('document.paciente.nombre_medico'+k).value;
		if(window.opener.document.paciente.f_nac)window.opener.document.paciente.f_nac.value	= eval('document.paciente.f_nac'+k).value;
		//window.opener.document.requisicion.area_desc.value		= eval('document.paciente.area_desc'+k).value;
		//window.opener.document.requisicion.hosp_directa.value	= eval('document.paciente.hosp_directa'+k).value;
<%
	} else if (fp.equalsIgnoreCase("general_page") && fg.equals("extension_dias")){
%>
		/*
		window.opener.document.paciente.codigoPaciente.value 	= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.paciente.pacienteId.value 			= eval('document.paciente.pac_id'+k).value;
		window.opener.document.paciente.provincia.value 			= eval('document.paciente.provincia'+k).value;
		window.opener.document.paciente.sigla.value 					= eval('document.paciente.sigla'+k).value;
		window.opener.document.paciente.tomo.value 						= eval('document.paciente.tomo'+k).value;
		window.opener.document.paciente.asiento.value 				= eval('document.paciente.asiento'+k).value;
		window.opener.document.paciente.dCedula.value 				= eval('document.paciente.dCedula'+k).value;
		window.opener.document.paciente.pasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		window.opener.document.paciente.nombrePaciente.value 	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.paciente.fechaNacimiento.value	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.paciente.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		window.opener.document.paciente.categoria.value				= eval('document.paciente.categoria'+k).value;
		window.opener.document.paciente.categoriaDesc.value		= eval('document.paciente.categoriaDesc'+k).value;
		window.opener.document.paciente.fechaIngreso.value		= eval('document.paciente.fechaIngreso'+k).value;
		window.opener.document.paciente.fechaEgreso.value			= eval('document.paciente.fechaEgreso'+k).value;
		window.opener.document.paciente.estado.value					= eval('document.paciente.estado'+k).value;
		window.opener.document.paciente.desc_estado.value			= eval('document.paciente.desc_estado'+k).value;
		window.opener.document.paciente.empresa.value					= eval('document.paciente.empresa'+k).value;
		window.opener.document.paciente.clasificacion.value		= eval('document.paciente.clasificacion'+k).value;
		window.opener.document.paciente.edad.value						= eval('document.paciente.edad'+k).value;
		window.opener.document.paciente.embarazada.value			= eval('document.paciente.embarazada'+k).value;

		window.opener.document.paciente.descuento.value				= eval('document.paciente.descuento'+k).value;
		window.opener.document.paciente.cambioPrecio.value		= eval('document.paciente.cambioPrecio'+k).value;
		window.opener.document.paciente.edad_mes.value				= eval('document.paciente.edad_mes'+k).value;
		window.opener.document.paciente.edad_dias.value				= eval('document.paciente.edad_dias'+k).value;
		window.opener.document.paciente.cds.value							= eval('document.paciente.area'+k).value;
		window.opener.document.paciente.cdsDesc.value					= eval('document.paciente.area_desc'+k).value;
		window.opener.document.paciente.medicoCabecera.value	= eval('document.paciente.medico_cabecera'+k).value;
		window.opener.document.paciente.nombreMedicoCabecera.value	= eval('document.paciente.nombre_medico_cabecera'+k).value;
		window.opener.document.paciente.empresaNombre.value		= eval('document.paciente.empresa_nombre'+k).value;
		window.opener.document.paciente.medico.value					= eval('document.paciente.medico'+k).value;
		window.opener.document.paciente.nombreMedico.value		= eval('document.paciente.nombre_medico'+k).value;

		*/
		window.opener.location='../admision/reg_ext_dias.jsp?fp=<%=fp%>&fg=<%=fg%>&pacienteId='+eval('document.paciente.pac_id'+k).value+'&admisionNo='+eval('document.paciente.admision'+k).value;

<%
	} else if (fp.equals("analisis_fact") || fp.equals("salida")|| fp.equals("corte_manual") ){
%>
		window.opener.document.paciente.codigoPaciente.value 	= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.paciente.pacienteId.value 			= eval('document.paciente.pac_id'+k).value;
		window.opener.document.paciente.provincia.value 			= eval('document.paciente.provincia'+k).value;
		window.opener.document.paciente.sigla.value 					= eval('document.paciente.sigla'+k).value;
		window.opener.document.paciente.tomo.value 						= eval('document.paciente.tomo'+k).value;
		window.opener.document.paciente.asiento.value 				= eval('document.paciente.asiento'+k).value;
		window.opener.document.paciente.dCedula.value 				= eval('document.paciente.dCedula'+k).value;
		window.opener.document.paciente.pasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		//window.opener.document.paciente.pacienteId.value 		= eval('document.paciente.pacienteId'+k).value;
		if(eval('document.paciente.cedula'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value = eval('document.paciente.cedula'+k).value;
		else if(eval('document.paciente.pasaporte'+k).value != '')
			window.opener.document.paciente.cedulaPasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		window.opener.document.paciente.nombrePaciente.value 	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.paciente.fechaNacimiento.value	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.paciente.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		window.opener.document.paciente.categoria.value				= eval('document.paciente.categoria'+k).value;
		window.opener.document.paciente.categoriaDesc.value		= eval('document.paciente.categoriaDesc'+k).value;
		window.opener.document.paciente.fechaIngreso.value		= eval('document.paciente.fechaIngreso'+k).value;
		window.opener.document.paciente.fechaEgreso.value			= eval('document.paciente.fechaEgreso'+k).value;
		window.opener.document.paciente.estado.value					= eval('document.paciente.estado'+k).value;
		window.opener.document.paciente.desc_estado.value			= eval('document.paciente.desc_estado'+k).value;
		window.opener.document.paciente.empresa.value					= eval('document.paciente.empresa'+k).value;
		window.opener.document.paciente.clasificacion.value		= eval('document.paciente.clasificacion'+k).value;
		window.opener.document.paciente.edad.value						= eval('document.paciente.edad'+k).value;
		window.opener.document.paciente.embarazada.value			= eval('document.paciente.embarazada'+k).value;

		window.opener.document.paciente.descuento.value				= eval('document.paciente.descuento'+k).value;
		window.opener.document.paciente.cambioPrecio.value		= eval('document.paciente.cambioPrecio'+k).value;
		window.opener.document.paciente.edad_mes.value				= eval('document.paciente.edad_mes'+k).value;
		window.opener.document.paciente.edad_dias.value				= eval('document.paciente.edad_dias'+k).value;
		window.opener.document.paciente.cds.value							= eval('document.paciente.area'+k).value;
		window.opener.document.paciente.cdsDesc.value					= eval('document.paciente.area_desc'+k).value;
		window.opener.document.paciente.medicoCabecera.value	= eval('document.paciente.medico_cabecera'+k).value;
		window.opener.document.paciente.nombreMedicoCabecera.value	= eval('document.paciente.nombre_medico_cabecera'+k).value;
		window.opener.document.paciente.empresaNombre.value		= eval('document.paciente.empresa_nombre'+k).value;
		window.opener.document.paciente.medico.value					= eval('document.paciente.medico'+k).value;
		window.opener.document.paciente.nombreMedico.value		= eval('document.paciente.nombre_medico'+k).value;
		if(window.opener.document.paciente.f_nac)window.opener.document.paciente.f_nac.value	= eval('document.paciente.f_nac'+k).value;
		//window.opener.document.form0.area_desc.value		= eval('document.paciente.area_desc'+k).value;
		//window.opener.document.form0.hosp_directa.value	= eval('document.paciente.hosp_directa'+k).value;

		document.paciente.pacienteId.value 		= eval('document.paciente.pac_id'+k).value;
		document.paciente.admision.value 			= eval('document.paciente.admision'+k).value;
		document.paciente.categoria.value			= eval('document.paciente.categoria'+k).value;
		document.paciente.clasificacion.value = eval('document.paciente.clasificacion'+k).value;
		document.paciente.doble_msg.value=eval('document.paciente.doble_msg'+k).value;
		<%if(fp.equals("corte_manual")){%> 
		if(eval('document.paciente.empresa'+k).value =='')alert('La admision no tiene Beneficios Asignados Verifique!!!');
		<%}%>
		document.paciente.submit();
<%
	} else if (fp.equals("cargo_oc")){
%>
		window.opener.document.form0.codigo_pac.value				= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.form0.gasnet_pac_id.value		= eval('document.paciente.pac_id'+k).value;
		window.opener.document.form0.nombre_paciente.value	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.form0.fecha_nac.value				= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.form0.admision.value					= eval('document.paciente.admision'+k).value;
		if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value	= eval('document.paciente.f_nac'+k).value;
<%
	} else if (fp.equals("cargo_dev_so")){
%>
		window.opener.document.form_1.cod_paciente.value				= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.form_1.fec_nacimiento.value				= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.form_1.admision.value					= eval('document.paciente.admision'+k).value;
		if(window.opener.document.form_1.f_nac)window.opener.document.form_1.f_nac.value	= eval('document.paciente.f_nac'+k).value;
<%
	}
	else if (fp.equals("DM")){
%>
		window.opener.document.devolucion.codigoPaciente.value		= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.devolucion.pacId.value		        = eval('document.paciente.pac_id'+k).value;
		window.opener.document.devolucion.nombrePaciente.value	    = eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.devolucion.fechaNacimiento.value		= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.devolucion.noAdmision.value			= eval('document.paciente.admision'+k).value;

		window.opener.document.devolucion.provincia.value 			= eval('document.paciente.provincia'+k).value;
		window.opener.document.devolucion.sigla.value 				= eval('document.paciente.sigla'+k).value;
		window.opener.document.devolucion.tomo.value 				= eval('document.paciente.tomo'+k).value;
		window.opener.document.devolucion.asiento.value 			= eval('document.paciente.asiento'+k).value;
		//window.opener.document.devolucion.dCedula.value 			= eval('document.paciente.dCedula'+k).value;
		window.opener.document.devolucion.pasaporte.value 			= eval('document.paciente.pasaporte'+k).value;
		window.opener.document.devolucion.descAdmision.value 		= eval('document.paciente.dsp_tipo_admision'+k).value;
		window.opener.document.devolucion.fecha_egreso.value		= eval('document.paciente.fechaEgreso'+k).value;
		if(window.opener.document.devolucion.f_nac)window.opener.document.devolucion.f_nac.value	= eval('document.paciente.f_nac'+k).value;

<%
	}
	else if (fp.equals("edit_cita")){
%>

		window.opener.document.form0.cod_paciente.value 		= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.form0.provincia.value 				= eval('document.paciente.provincia'+k).value;
		window.opener.document.form0.sigla.value 						= eval('document.paciente.sigla'+k).value;
		window.opener.document.form0.tomo.value 						= eval('document.paciente.tomo'+k).value;
		window.opener.document.form0.asiento.value 					= eval('document.paciente.asiento'+k).value;
		window.opener.document.form0.d_cedula.value 				= eval('document.paciente.dCedula'+k).value;
		window.opener.document.form0.nombre_paciente.value 	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.form0.fec_nacimiento.value 	=	eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.form0.admision.value					= eval('document.paciente.admision'+k).value;
		window.opener.document.form0.pacId.value		        = eval('document.paciente.pac_id'+k).value;
		if(window.opener.document.form0.cedulaPasaporte)window.opener.document.form0.cedulaPasaporte.value = eval('document.paciente.cedulaPasaporte'+k).value;
		if(window.opener.document.form0.pasaporte)window.opener.document.form0.pasaporte.value = eval('document.paciente.pasaporte'+k).value;
		if(window.opener.document.form0.empresa){
			window.opener.document.form0.empresa.value = eval('document.paciente.empresa'+k).value;
			if(window.opener.document.form0.btnEmpresa)window.opener.document.form0.btnEmpresa.disabled=true;
		}
		if(window.opener.document.form0.empresa_desc)window.opener.document.form0.empresa_desc.value = eval('document.paciente.nombreEmpresa'+k).value;
		if(window.opener.document.form0.estado_admision)window.opener.document.form0.estado_admision.value = eval('document.paciente.desc_estado'+k).value;
		if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value	= eval('document.paciente.f_nac'+k).value;

		if(eval('document.paciente.pasaporte'+k).value !=''){
			window.opener.document.form0.provincia.value = '';
			window.opener.document.form0.sigla.value = '';
			window.opener.document.form0.tomo.value = '';
			window.opener.document.form0.asiento.value = '';
			}

<%
	}
	else if (fp.equals("SALDO")||fp.equals("farmacia")||fp.equals("req")){
%>
		window.opener.document.form0.pacId.value 		= eval('document.paciente.pac_id'+k).value;
		window.opener.document.form0.nombre.value 	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.form0.noAdmision.value = eval('document.paciente.admision'+k).value;
        <%if(fp.equals("farmacia")){%>
          if (window.opener.document.form0.categoria) window.opener.document.form0.categoria.value = eval('document.paciente.categoria'+k).value;
        <%}%>
<%
	}else if (fp.equals("transferencia2")){%>
		window.opener.document.form0.codigoPaciente2.value 		= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.form0.fechaNacimiento2.value 	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.form0.admSecuencia2.value		= eval('document.paciente.admision'+k).value;
		window.opener.document.form0.fechaIngreso2.value		= eval('document.paciente.fechaIngreso'+k).value;
		window.opener.document.form0.fechaEgreso2.value			= eval('document.paciente.fechaEgreso'+k).value;
		window.opener.document.form0.nombrePaciente2.value    	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.form0.pacId2.value		        = eval('document.paciente.pac_id'+k).value;
		window.opener.document.form0.estadoB.value		        = eval('document.paciente.estado'+k).value;
		if(window.opener.document.form0.f_nac2)window.opener.document.form0.f_nac2.value	= eval('document.paciente.f_nac'+k).value;
		if(window.opener.document.form0._estadoBDsp)window.opener.document.form0._estadoBDsp.value = eval('document.paciente.estado'+k).value;
		//if(window.opener.document.form0._categoriaDsp)window.opener.document.form0._categoriaDsp.value = eval('document.paciente.categoria'+k).value;
		window.opener.document.form0.empresa2.value		        = eval('document.paciente.empresa'+k).value;
		window.opener.document.form0.categoria2.value		        = eval('document.paciente.categoria'+k).value;
		if(window.opener.document.form0._categoria2Dsp)window.opener.document.form0._categoria2Dsp.value = eval('document.paciente.categoria'+k).value;
		window.opener.document.form0.clasificacion2.value		= eval('document.paciente.clasificacion'+k).value;
		window.opener.document.form0.tipo_empresa2.value		    = eval('document.paciente.tipo_empresa'+k).value;
		window.opener.document.form0.desc_empresa2.value		= eval('document.paciente.nombreEmpresa'+k).value;
		window.opener.document.form0.cedulaPasaporte2.value		= eval('document.paciente.id_paciente'+k).value;
<%	}else if (fp.equalsIgnoreCase("consulta_general")){
%>
		window.opener.location='../admision/consulta_general.jsp?mode=view&pacId='+eval('document.paciente.pac_id'+k).value+'&noAdmision='+eval('document.paciente.admision'+k).value;
<%
	}else if (fp.equals("rpt_pagos_aplicados")){
%>
		window.opener.document.form0.codigoPaciente.value 		= eval('document.paciente.codigo_paciente'+k).value;
		window.opener.document.form0.fechaNacimiento.value 	= eval('document.paciente.fechaNacimiento'+k).value;
		window.opener.document.form0.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		window.opener.document.form0.nombrePaciente.value    	= eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.form0.pacId.value = eval('document.paciente.pac_id'+k).value;
		if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value	= eval('document.paciente.f_nac'+k).value;
<%
	}else if (fp.equals("secciones_guardadas")){%>
	   window.opener.document.search01.noAdmision.value = eval('document.paciente.admision'+k).value;
	   window.opener.document.search01.careDate.value = eval('document.paciente.fechaIngreso'+k).value;
	   window.opener.document.search01.dob.value = eval('document.paciente.fechaNacimiento'+k).value;
	   window.opener.document.search01.patientCode.value = eval('document.paciente.codigo_paciente'+k).value;
		if(window.opener.document.search01.f_nac)window.opener.document.search01.f_nac.value	= eval('document.paciente.f_nac'+k).value;
	<% } else if (fp.equals("citas_cons")){%>
	    window.opener.document.search01.nombre_paciente.value = eval('document.paciente.nombrePaciente'+k).value;
		window.opener.document.search01.noAdmision.value = eval('document.paciente.admision'+k).value;
		window.opener.document.search01.pacId.value = eval('document.paciente.pac_id'+k).value;
	<%}else if (fp.equalsIgnoreCase("liq_recl")){ %>
        if(window.opener.document.form0.codigo_paciente)window.opener.document.form0.codigo_paciente.value 		= eval('document.paciente.codigo_paciente'+k).value;
		if(window.opener.document.form0.fecha_nacimiento)window.opener.document.form0.fecha_nacimiento.value 	= eval('document.paciente.fechaNacimiento'+k).value;
		if(window.opener.document.form0.admSecuencia)window.opener.document.form0.admSecuencia.value		= eval('document.paciente.admision'+k).value;
		if(window.opener.document.form0.nombreCliente)window.opener.document.form0.nombreCliente.value    	= eval('document.paciente.nombrePaciente'+k).value;
		if(window.opener.document.form0.pacId)window.opener.document.form0.pacId.value = eval('document.paciente.pac_id'+k).value;
        if(window.opener.document.form0.cedulaPasaporte)window.opener.document.form0.cedulaPasaporte.value = eval('document.paciente.cedula'+k).value;
        if(window.opener.document.form0.edad)window.opener.document.form0.edad.value = eval('document.paciente.edad'+k).value;
        if(window.opener.document.form0.sexo)window.opener.document.form0.sexo.value = eval('document.paciente.sexo'+k).value;
        if(window.opener.document.form0.fecha_ingreso)window.opener.document.form0.fecha_ingreso.value = eval('document.paciente.fechaIngreso'+k).value;
        if(window.opener.document.form0.fecha_egreso)window.opener.document.form0.fecha_egreso.value = eval('document.paciente.fechaEgreso'+k).value; 
		if(window.opener.document.form0.f_nac)window.opener.document.form0.f_nac.value	= eval('document.paciente.f_nac'+k).value;
        
        if(window.opener.document.form0.medico)window.opener.document.form0.medico.value = eval('document.paciente.medico_cabecera'+k).value; 
        if(window.opener.document.form0.medico_nombre)window.opener.document.form0.medico_nombre.value = eval('document.paciente.nombre_medico_cabecera'+k).value; 
        if(window.opener.document.form0.poliza)window.opener.document.form0.poliza.value = eval('document.paciente.poliza'+k).value; 
        if(window.opener.document.form0.no_factura)window.opener.document.form0.no_factura.value = eval('document.paciente.fac'+k).value; 
        
        if (window.opener.getHospDays()) window.opener.getHospDays()
    <%}
	if (!fp.equals("analisis_fact") && !fp.equals("salida")&& !fp.equals("corte_manual")){
%>
		window.close();
<%
	}
%>
	}
}

function getMain(formx)
{
	formx.estado.value = document.search00.estado.value;
	formx.categoria.value = document.search00.categoria.value;
	return true;
}
function setValue(id,obj)
{
var estado = document.search00.estado.value;
var tipo = document.search00.categoria.value;
<%if(fg != null && fg.trim().equals("CU")){%>
if(id=='0')
{
	if(tipo=='2') //obj.value = 'E';
	document.search00.estado.value='E';
	else if(tipo=='1')//	obj.value = 'A';
	document.search00.estado.value='A';
}else if(id=='1')
{
	if(estado =='E')
		document.search00.categoria.value = '2';
	if(estado =='A')
		document.search00.categoria.value = '1';
}
<%}%>
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PACIENTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("tr2",tr2)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>

					<td width="8%" align="right">
						<cellbytelabel id="1">Categor&iacute;a</cellbytelabel>
					</td>
					<td width="26%">
						<%=fb.select(ConMgr.getConnection(), sqlCat, "categoria", categoria,false,false,0,"",null,"onChange=\"javascript:setValue(0,this)\"","",((fp.equals("consulta_general")||fp.equals("SALDO")||fp.equals("secciones_guardadas"))?"T":""))%>
					</td>
					<td width="12%" align="right">
						<cellbytelabel id="2">Estado</cellbytelabel>
					 </td>
					<td width="21%">
						<%
						String strEstado = "A=Activo,E=Espera,S=Especial,C=Cancelada";
						if(fp.equals("mat_paciente") || fp.equals("cargo_tardio") ){
							if(fg.equals("SAL") || fg.equals("DIET")) strEstado = "A=Activo,E=Espera,S=Especial";
							else if(fg.equals("CU")||fg.equals("CT")) strEstado = "A=Activo,E=Espera";
							else if(fg.equals("SOP"))	strEstado = "A=Activa, E=Espera";
						if(!tr2.trim().equals("") && tr2.equals("HEMD")) strEstado = "A=Activo,E=Espera";
						} else if(fp.equals("consulta_general")){
							strEstado = "A=Activa, E=Espera, S=Especial, C=Cancelada, I=Inactiva, N=Anulada, T=Temporal, P=Pre-Admision";
						} else if(fp.equals("cargo_dev_so")||fp.equals("transferencia2")){
							strEstado = "E=Espera";
						} else if(fp.equals("edit_cita")){
							strEstado = "A=Activa, E=Espera, P=Pre-Admision";
						} else if(fp.equals("secciones_guardadas")){
							strEstado = "A=Activa, E=Espera, P=Pre-Admision, I=Inactiva";
						}
						else if(fp.equals("DM")){
							if(fg.equals("CU"))
							strEstado ="A=ACTIVA,E=ESPERA";
							else
							strEstado ="A=ACTIVA,E=ESPERA,S=ESPECIAL,C=CANCELADA";
						}

						else {
							if(fg.equals("salida")) strEstado = "A=Activo,S=Especial";
							else if(fg.equals("sol_img_estudio") || fg.equals("sol_lab_estudio")) strEstado = "A=Activo,E=Espera";
							else if(fg.equals("HON")||fp.equals("DM")) strEstado = "A=Activo,E=Espera,S=Especial";
						}
						if(fg.equals("AFA")) strEstado = "A=Activa,I=Inactiva,E=Espera,C=Cancelada,P=Preadmision,S=Especial";
						if(fp.equals("SALDO") || fp.equalsIgnoreCase("liq_recl")) strEstado = "I=Inactiva";
						if(fp.equals("corte_manual")) strEstado = "A=Activa";
						if(fp.equals("farmacia")||fp.equals("req")) strEstado += ",I=Inactiva, N=Anulada";

						%>
						<%=fb.select("estado",strEstado,estado,false,false,0,"",null,"onChange=\"javascript:setValue(1,this)\"","",(fp.equals("consulta_general")||fp.equals("secciones_guardadas")?"T":""))%>
						<%//=fb.select("existencia","MN=MENOR, M=MAYOR, I=IGUAL",existencia,false,false,0,"Text10",null,null,null,"T")%>
					</td>
					<td width="12%" align="right"><%=(fp.equals("consulta_general")?"Factura":"")%>&nbsp;</td>
					<td width="21%">
					<%if(fp.equals("consulta_general")){%>
					<%=fb.textBox("factura",factura,false,false,false,20)%>
					<%}%>
					&nbsp;</td>
				</tr>
				<tr class="TextFilter">
					<td width="8%" align="right">
						<cellbytelabel id="3">C&eacute;dula</cellbytelabel>
					</td>
					<td width="26%">
						<%=fb.textBox("provincia",provincia,false,false,false,2)%>
						<%=fb.textBox("sigla",sigla,false,false,false,2)%>
						<%=fb.intBox("tomo",tomo,false,false,false,4)%>
						<%=fb.intBox("asiento",asiento,false,false,false,5)%>
					</td>
					<td width="12%" align="right">
						<cellbytelabel id="4">Pasaporte</cellbytelabel>
					</td>
					<td width="21%">
						<%=fb.textBox("pasaporte",pasaporte,false,false,false,20)%>
					</td>
					<td width="12%" align="right">
					<cellbytelabel id="5">Cod. Paciente</cellbytelabel>
					</td>
					<td width="21%">
					<%=fb.intBox("cod_paciente",cod_paciente,false,false,false,20)%>
					</td>
				</tr>
				<tr class="TextFilter">

					<td width="8%" align="right">
						<cellbytelabel id="6">Nombre</cellbytelabel>
					</td>
					<td width="26%">
						<%=fb.textBox("nombre",nombre,false,false,false,40)%>
					</td>
					<td width="12%" align="right">
						<cellbytelabel id="7">Fecha de Nacimiento</cellbytelabel>
					</td>
					<td width="21%">
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="nameOfTBox1" value="dob"/>
						<jsp:param name="valueOfTBox1" value="<%=dob%>"/>
						</jsp:include>
					</td>
					<td width="12%" align="right">
					<cellbytelabel id="8">No. Admisi&oacute;n</cellbytelabel>
					</td>
					<td width="21%">
					<%=fb.intBox("no_admision",no_admision,false,false,false,20)%>
					<%=fb.submit("go","Ir")%>
					</td>
				</tr>
					<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("tr2",tr2)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="9">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="10">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="11">hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("tr2",tr2)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

			<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
				<tr class="TextHeader" align="center">
					<td width="10%"><cellbytelabel id="3">C&eacute;dula</cellbytelabel></td>
					<td width="10%"><cellbytelabel id="4">Pasaporte</cellbytelabel></td>
					<td width="25%"><cellbytelabel id="6">Nombre</cellbytelabel></td>
					<td width="7%"><cellbytelabel id="12">Sexo</cellbytelabel></td>
					<td width="7%"><cellbytelabel id="13">Fecha Nac.</cellbytelabel></td>
					<td width="6%"><cellbytelabel id="8">No. Admisi&oacute;n</cellbytelabel></td>
					<td width="7%"><cellbytelabel id="14">F. Ingreso</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="15">&Aacute;rea Admite</cellbytelabel></td>
					<td width="13%"><cellbytelabel id="1">Categor&iacute;a</cellbytelabel></td>
				</tr>
<%fb = new FormBean("paciente",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("categoria",categoria)%>
<%=fb.hidden("clasificacion","")%>
<%=fb.hidden("pacienteId","")%>
<%=fb.hidden("admision","")%>
<%=fb.hidden("centro",centro)%>
<%=fb.hidden("provincia",provincia)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("pasaporte",pasaporte)%>
<%=fb.hidden("cod_paciente",cod_paciente)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("no_admision",no_admision)%>
<%=fb.hidden("tr2",tr2)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("doble_msg","")%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("admRoot",admRoot)%>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("estatus"+i,cdo.getColValue("estatus"))%>
				<%=fb.hidden("codigo_paciente"+i,cdo.getColValue("codigo_paciente"))%>
				<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
				<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%>
				<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%>
				<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>
				<%=fb.hidden("dCedula"+i,cdo.getColValue("d_cedula"))%>
				<%=fb.hidden("pasaporte"+i,cdo.getColValue("pasaporte"))%>
				<%=fb.hidden("id_paciente"+i,cdo.getColValue("id_paciente"))%>
				<%=fb.hidden("pac_id"+i,cdo.getColValue("pac_id"))%>
				<%=fb.hidden("nombrePaciente"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("fechaNacimiento"+i,cdo.getColValue("fecha_nacimiento"))%>
				<%=fb.hidden("fechaIngreso"+i,cdo.getColValue("fecha_ingreso"))%>
				<%=fb.hidden("fechaEgreso"+i,cdo.getColValue("fecha_egreso"))%>
				<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>
				<%=fb.hidden("categoria"+i,cdo.getColValue("categoria"))%>
				<%=fb.hidden("categoriaDesc"+i,cdo.getColValue("desc_categoria"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("desc_estado"+i,cdo.getColValue("desc_estado"))%>
				<%=fb.hidden("jubilado"+i,cdo.getColValue("jubilado"))%>
				<%=fb.hidden("empresa"+i,cdo.getColValue("empresa"))%>
				<%=fb.hidden("clasificacion"+i,cdo.getColValue("clasificacion"))%>
				<%=fb.hidden("cedula"+i,cdo.getColValue("cedula"))%>
				<%=fb.hidden("nombreEmpresa"+i,cdo.getColValue("nombreEmpresa"))%>
				<%=fb.hidden("f_nac"+i,cdo.getColValue("f_nac"))%>
				<%if (fg.trim().equals("DIET") || fg.trim().equals("CU"))
				{%>
				<%=fb.hidden("tipoIncremento"+i,cdo.getColValue("tipoIncremento"))%>
				<%=fb.hidden("incremento"+i,cdo.getColValue("incremento"))%>
				<%}%>

				<%=fb.hidden("edad"+i,cdo.getColValue("edad"))%>
				<%=fb.hidden("embarazada"+i,cdo.getColValue("embarazada"))%>
				<%=fb.hidden("area"+i,cdo.getColValue("area"))%>
				<%=fb.hidden("hosp_directa"+i,cdo.getColValue("hosp_directa"))%>
				<%=fb.hidden("dsp_tipo_admision"+i,cdo.getColValue("dsp_tipo_admision"))%>
				<%if (fp.equalsIgnoreCase("mat_paciente") || fp.equalsIgnoreCase("sol_img_estudio") || fp.equals("sol_lab_estudio")|| fp.equals("edit_cita")|| fp.equals("liq_recl")){%>
				<%=fb.hidden("cedulaPasaporte"+i,cdo.getColValue("cedulaPasaporte"))%>
				<%}%>

				<%=fb.hidden("descuento"+i,cdo.getColValue("descuento"))%>
				<%=fb.hidden("cambioPrecio"+i,cdo.getColValue("cambioPrecio"))%>
				<%=fb.hidden("edad_mes"+i,cdo.getColValue("edad_mes"))%>
				<%=fb.hidden("edad_dias"+i,cdo.getColValue("edad_dias"))%>
				<%=fb.hidden("area_desc"+i,cdo.getColValue("area_desc"))%>
				<%=fb.hidden("medico"+i,cdo.getColValue("medico"))%>
				<%=fb.hidden("nombre_medico"+i,cdo.getColValue("nombre_medico"))%>
				<%=fb.hidden("medico_cabecera"+i,cdo.getColValue("medico_cabecera"))%>
				<%=fb.hidden("nombre_medico_cabecera"+i,cdo.getColValue("nombre_medico_cabecera"))%>
				<%=fb.hidden("empresa_nombre"+i,cdo.getColValue("empresa_nombre"))%>
				<%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
				<%=fb.hidden("segundo_nombre"+i,cdo.getColValue("segundo_nombre"))%>
				<%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
				<%=fb.hidden("segundo_apellido"+i,cdo.getColValue("segundo_apellido"))%>
				<%=fb.hidden("apellido_de_casada"+i,cdo.getColValue("apellido_de_casada"))%>
				<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
				<%=fb.hidden("residenciaDireccion"+i,cdo.getColValue("residencia_direccion"))%>
				<%=fb.hidden("telefono"+i,cdo.getColValue("telefono"))%>
				<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
				<%=fb.hidden("doble_msg"+i,cdo.getColValue("doble_msg"))%>
				<%=fb.hidden("tipo_empresa"+i,cdo.getColValue("tipo_empresa"))%>
				<%=fb.hidden("poliza"+i,cdo.getColValue("poliza"))%>
				<%=fb.hidden("fac"+i,cdo.getColValue("fac"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setPaciente(<%=i%>)" style="text-decoration:none; cursor:pointer">
					<td><%=cdo.getColValue("cedula")%></td>
					<td><%=cdo.getColValue("pasaporte")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=(cdo.getColValue("sexo").equalsIgnoreCase("F"))?"FEMENINO":"MASCULINO"%></td>
					<td align="center"><%=cdo.getColValue("f_nac")%></td>
					<td align="center"><%=cdo.getColValue("admision")%></td>
					<td align="center"><%=cdo.getColValue("fecha_ingreso")%></td>
					<td><%=(fg.trim().equals("SAL"))?cdo.getColValue("area_desc2"):cdo.getColValue("area_desc2")%></td>
					<td><%=cdo.getColValue("desc_categoria")%></td>
				</tr>
<%
}
%>
<%=fb.formEnd()%>
			</table>

</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("tr2",tr2)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="9">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="10">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="11">hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("estado",estado)%>
					<%=fb.hidden("categoria",categoria)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("status",status)%>
					<%=fb.hidden("centro",centro)%>
					<%=fb.hidden("provincia",provincia)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("pasaporte",pasaporte)%>
					<%=fb.hidden("cod_paciente",cod_paciente)%>
					<%=fb.hidden("nombre",nombre)%>
					<%=fb.hidden("no_admision",no_admision)%>
					<%=fb.hidden("tr2",tr2)%>
					<%=fb.hidden("dob",dob)%>
					<%=fb.hidden("noAdmision",noAdmision)%>
					<%=fb.hidden("admRoot",admRoot)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	if (fp.equals("analisis_fact")){
		sql = "select a.fecha_nacimiento as fechaNacimiento, a.paciente, a.admision, a.secuencia, a.poliza, nvl(a.certificado,' ') as certificado, nvl(a.convenio_solicitud,' ') as convenioSolicitud, nvl(a.convenio_sol_emp,' ') as convenioSolEmp, a.prioridad, decode(a.plan,null,' ',a.plan) as plan, decode(a.convenio,null,' ',a.convenio) as convenio, a.empresa, decode(a.categoria_admi,null,' ',a.categoria_admi) as categoriaAdmi, decode(a.tipo_admi,null,' ',a.tipo_admi) as tipoAdmi, decode(a.clasif_admi,null,' ',a.clasif_admi) as clasifAdmi, decode(a.tipo_poliza,null,' ',a.tipo_poliza) as tipoPoliza, decode(a.tipo_plan,null,' ',a.tipo_plan) as tipoPlan, nvl(to_char(a.fecha_ini,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaIni, nvl(to_char(a.fecha_fin,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaFin, nvl(a.clinica_asume_cargos,' ') as clinicaAsumeCargos, nvl(a.pac_asume_cargos,' ') as pacAsumeCargos, decode(a.dias_perdiem,null,' ',a.dias_perdiem) as diasPerdiem, decode(a.estatus_pac,null,' ',a.estatus_pac) as estatusPac, nvl(a.usuario_creacion,' ') as usuarioCreacion, nvl(a.usuario_modificacion,' ') as usuarioModificacion, nvl(to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaCreacion, nvl(to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaModificacion, nvl(a.estado,' ') as estado, nvl(a.jubilado,' ') as jubilado, decode(a.tipo_factura,null,' ',a.tipo_factura) as tipoFactura, nvl(a.pase,' ') as pase, nvl(a.pase_k,' ') as paseK, decode(a.num_aprobacion,null,' ',a.num_aprobacion) as numAprobacion, a.pac_id as pacId, b.nombre empresaNombre, c.nombre tipoPolizaDesc, d.nombre tipoPlanDesc, e.descripcion categoriaAdmiDesc, f.descripcion tipoAdmiDesc, g.descripcion clasifAdmiDesc, h.nombre convenioDesc, i.nombre planDesc from tbl_adm_beneficios_x_admision a, tbl_adm_empresa b, tbl_adm_tipo_poliza c, tbl_adm_tipo_plan d, tbl_adm_categoria_admision e, tbl_adm_tipo_admision_cia f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_convenio h, (select a.plan, a.clasif_admi, a.tipo_admi, a.categoria_admi, b.tipo_plan, b.tipo_poliza, b.empresa, b.convenio, b.nombre from tbl_adm_clasif_x_plan_conv a, tbl_adm_plan_convenio b where a.empresa = b.empresa and a.convenio = b.convenio and a.plan = b.secuencia) i where a.pac_id = "+request.getParameter("pacienteId")+" and a.admision = "+request.getParameter("admision")+" and a.estado = 'A' and a.empresa = b.codigo and a.tipo_poliza = c.codigo and a.tipo_poliza = d.poliza and a.tipo_plan = d.tipo_plan(+) and a.categoria_admi = e.codigo and a.categoria_admi = f.categoria and a.tipo_admi = f.codigo and a.categoria_admi = g.categoria and a.tipo_admi = g.tipo and a.clasif_admi = g.codigo and a.empresa = h.empresa and a.convenio = h.secuencia and a.plan = i.plan and a.clasif_admi = i.clasif_admi and a.tipo_admi = i.tipo_admi and a.categoria_admi = i.categoria_admi and a.tipo_plan = i.tipo_plan and a.tipo_poliza = i.tipo_poliza and a.empresa = i.empresa and a.convenio = i.convenio";
		System.out.println("sql=\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,Beneficio.class);

		FacDet.setPacId(request.getParameter("pacienteId"));
		FacDet.setAdmiSecuencia(request.getParameter("admision"));
		FacDet.setCategoriaAdmi(request.getParameter("categoria"));
		FacDet.setClasifAdmi(request.getParameter("clasificacion"));
		FacDet.setEstatus(request.getParameter("estado"));
		FacDet.setComentario(request.getParameter("doble_msg"));
		FacDet.getBeneficios().clear();
		FacDet.setBeneficios(al);

	} else if(fg.equals("salida")){
		sql = "select a.cama, a.habitacion, to_char(a.fecha_inicio,'dd/mm/yyyy') fechaInicio, nvl(to_char(a.fecha_final,'dd/mm/yyyy'), ' ') fechaFin, c.descripcion from tbl_adm_cama_admision a, tbl_sal_habitacion b, tbl_cds_centro_servicio c where a.pac_id = "+request.getParameter("pacienteId")+" and a.admision = "+request.getParameter("admision")+" and a.habitacion = b.codigo and b.unidad_admin = c.codigo";
		//sql = "select cama, habitacion, to_char(fecha_inicio,'dd/mm/yyyy') fechaInicio, to_char(fecha_final,'dd/mm/yyyy') fechaFin from tbl_adm_cama_admision where pac_id = "+FacDet.getPacId()+" and admision = "+FacDet.getAdmiSecuencia()+"";
		System.out.println("sql camas=\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(),sql,Cama.class);
		for(int i=0;i<al.size();i++){
			Cama ca = (Cama) al.get(i);
			htCama.put(""+i,ca);
		}
	}
	else if(fp != null && fp.trim().equals("corte_manual"))
	{

	//sql = "select empresa ,prioridad from tbl_adm_beneficios_x_admision a where  a.pac_id = "+request.getParameter("pacienteId")+" and a.admision = "+request.getParameter("admision");

	sql="select a.empresa codigo ,a.prioridad,e.nombre from tbl_adm_beneficios_x_admision a,tbl_adm_empresa e where  a.pac_id = "+request.getParameter("pacienteId")+" and a.admision = "+request.getParameter("admision")+" and a.empresa = e.codigo and a.estado ='A'";

	String key ="";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a)");
	iAseg.clear();
	for(int i=0;i<al.size();i++){
			CommonDataObject cdo = (CommonDataObject) al.get(i);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cdo.addColValue("key",key);

			try
			{
				iAseg.put(key, cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	window.opener.document.form0.change.value = "1";
	window.opener.document.form0.action.value = "adding";
	//window.opener.document.form0.mode.value = "<%//=mode%>";
	<%
	if(fp.equals("analisis_fact")){
	%>
	window.opener.location='../facturacion/reg_analisis_fact.jsp?change=1&action=adding&pacienteId=<%=request.getParameter("pacienteId")%>&noAdmision=<%=request.getParameter("admision")%>&fg=<%=fg%>';
	<%
	} else if(fp.equals("salida")){
	%>
	window.opener.location='../admision/reg_sal_pac.jsp?change=1&action=adding&pacienteId=<%=request.getParameter("pacienteId")%>&fg=<%=fg%>&noAdmision=<%=request.getParameter("admision")%>';
	<%
	}
	 else if(fp.equals("corte_manual")){
	%>
	window.opener.location='../facturacion/fac_corte_cuenta_manual.jsp?change=1&action=adding&pacienteId=<%=request.getParameter("pacienteId")%>&fg=<%=fg%>&noAdmision=<%=request.getParameter("admision")%>';
	<%
	}
	%>

	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>