<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.CitaPersonal"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htPersonal" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htPersonalKey" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
 
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String especialidad = request.getParameter("especialidad");
String status = request.getParameter("status");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String tab = request.getParameter("tab");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String userId = request.getParameter("userId");
String context = request.getParameter("context")==null?"":request.getParameter("context");
String noResultClose = request.getParameter("noResultClose")==null?"":request.getParameter("noResultClose");
String modalize = request.getParameter("modalize") == null ? "" : request.getParameter("modalize");
String cedula=request.getParameter("cedula");
String referencia=request.getParameter("referencia");
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (especialidad == null) especialidad = "";
if (status == null) status = "A";
if(fg==null) fg = "";
if (index==null) index= "";
if (cedula==null) cedula= "";
if (referencia==null) referencia= "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	StringBuffer sbSql = new StringBuffer();
	StringBuffer sbField = new StringBuffer();
	StringBuffer sbTable = new StringBuffer();
	StringBuffer sbFilter = new StringBuffer();
	StringBuffer sbOrder = new StringBuffer();

	sbField.append(", decode(c.codigo,null,' ',c.codigo) as especialidad, decode(c.descripcion,null,' ',c.descripcion) as especialidadDesc");
	sbTable.append(", tbl_adm_medico_especialidad b, tbl_adm_especialidad_medica c");
	sbFilter.append(" where a.codigo=b.medico(+) and b.especialidad=c.codigo(+)");
	sbOrder.append(" order by c.descripcion, 3, 2");

	boolean showEspecialidad = true;
	if (fp.equalsIgnoreCase("pUniversalAnest") || (fp.equalsIgnoreCase("citas") && fg.equals("dr_anestesiologo")) || fp.equalsIgnoreCase("protocolo") || fp.equalsIgnoreCase("EPA") || fp.equalsIgnoreCase("recuperacion_anes_sop")) {

		if (!fg.equalsIgnoreCase("CIR")) {
		  sbSql.append("select nvl(get_sec_comp_param(");
		  sbSql.append(session.getAttribute("_companyId"));
		  sbSql.append(",'ADM_MED_ANESTESIOLOGO'),'AN') as especialidad from dual");
		  CommonDataObject p = SQLMgr.getData(sbSql.toString());

		  showEspecialidad = false;
		  sbFilter.append(" and b.especialidad in (");
		  sbFilter.append(CmnMgr.vector2strSqlInClause(CmnMgr.str2vector(p.getColValue("especialidad","AN"))));
		  sbFilter.append(")");
		} else {
		   if (!especialidad.equals("")) {
			 sbFilter.append(" and b.especialidad = '");
			 sbFilter.append(especialidad);
			 sbFilter.append("'");
		   }
		}

	} else if (fp.equalsIgnoreCase("pUniversalPed")) {

		sbSql.append("select nvl(get_sec_comp_param(");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",'ADM_MED_PEDIATRA'),'PED') as especialidad from dual");
		CommonDataObject p = SQLMgr.getData(sbSql.toString());

		showEspecialidad = false;
		sbFilter.append(" and b.especialidad in (");
		sbFilter.append(CmnMgr.vector2strSqlInClause(CmnMgr.str2vector(p.getColValue("especialidad","PED"))));
		sbFilter.append(")");

	} else if (!especialidad.equals("")) {

		sbFilter.append(" and b.especialidad = '");
		sbFilter.append(especialidad);
		sbFilter.append("'");

	}

	if (fp.equalsIgnoreCase("admision_medico_esp") || fp.equalsIgnoreCase("sol_img_estudio") || fp.equalsIgnoreCase("sol_lab_estudio") || fp.equalsIgnoreCase("cargo_oc") || fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext") || fp.equalsIgnoreCase("pac_x_medicos"))
	{
		sbFilter.append(" and b.secuencia(+)=1");
	}
	else if (fp.equalsIgnoreCase("medico_id")||fp.equalsIgnoreCase("imagenologia")||fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("exp_interconsulta_medico")||fp.equalsIgnoreCase("exp_interconsultor")|| fp.equalsIgnoreCase("exp_hist_obstetrica")|| fp.equalsIgnoreCase("exp_informes")|| fp.equalsIgnoreCase("progreso") || fp.equalsIgnoreCase("notas_enf") || fp.equalsIgnoreCase("pUniversal") || fp.equalsIgnoreCase("exp_verif_cuidad_pre_oper")|| fp.equalsIgnoreCase("expOrdenesMed"))
	{
	}
	else if (fp.equalsIgnoreCase("user"))
		{
			if (userId == null) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");
		sbTable.append(", (select ref_code from tbl_sec_users where user_type in (select id from tbl_sec_user_type where ref_type='M') and user_id!=");
		sbTable.append(userId);
		sbTable.append(" and user_status <> 'I') z");
		sbFilter.append(" and a.codigo=z.ref_code(+) and z.ref_code is null");
	}
	else if (fp.equalsIgnoreCase("addEntregaDr"))
	{
	}
	else if (fp.equalsIgnoreCase("admision_medico_cab"))
	{
	}
	else if (fp.equalsIgnoreCase("admision_medico_resp") || fp.equalsIgnoreCase("admision_medico_resp_new"))
	{
		if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");

		sbField.append(", d.nacionalidad as nacionalidadDesc");
		sbTable.append(", tbl_sec_pais d");
		sbFilter.append(" and a.nacionalidad=d.codigo(+)");
	}
    else if(fp.equalsIgnoreCase("diag_pacientes")){
       sbFilter.append(" and b.secuencia(+)=1");
    }
	else if ((fp.equalsIgnoreCase("citas") && fg.equals("dr_anestesiologo")) ||fp.equalsIgnoreCase("protocolo") || fp.equalsIgnoreCase("EPA") || fp.equalsIgnoreCase("recuperacion_anes_sop"))
	{
		sbField.append(", d.nacionalidad as nacionalidadDesc");
		sbTable.append(", tbl_sec_pais d");
		sbFilter.append(" and a.nacionalidad=d.codigo(+) and a.estado='A'");
	}
	else if (fp.equalsIgnoreCase("cargo_dev") || fp.equalsIgnoreCase("liq_recl") || fp.equalsIgnoreCase("notas_ajustes")|| fp.equalsIgnoreCase("notas_h") || (fp.equalsIgnoreCase("citas") && fg.equals("dr_reserva")) ||fp.equalsIgnoreCase("protocoloOp")||fp.equalsIgnoreCase("protocolo_cesarea")||fp.equalsIgnoreCase("sumario_egreso_med_neo"))
	{
		sbField.append(", d.nacionalidad as nacionalidadDesc");
		sbTable.append(", tbl_sec_pais d");
		sbFilter.append(" and a.nacionalidad=d.codigo(+) ");
		if(fp.equalsIgnoreCase("liq_recl") && referencia!=null && !referencia.equals("")){
			sbFilter.append(" and referencia = '");
			sbFilter.append(referencia);
			sbFilter.append("'");
		}
		
		
			if (fg.equalsIgnoreCase("DEVHON")) {
			sbField.append(", e.monto_total,e.no_documento");
			sbTable.append(", (select x.no_documento,x.med_codigo, sum(decode(x.tipo_transaccion,'D',-y.cantidad,y.cantidad) * y.monto) as monto_total from tbl_fac_transaccion x, tbl_fac_detalle_transaccion y where x.pac_id = ");
			sbTable.append(pacId);
			sbTable.append(" and x.admi_secuencia = ");
			sbTable.append(noAdmision);
			sbTable.append(" and x.centro_servicio = 0 and x.codigo = y.fac_codigo and x.admi_secuencia = y.fac_secuencia and x.pac_id = y.pac_id and x.compania = y.compania and x.tipo_transaccion = y.tipo_transaccion group by x.no_documento,x.med_codigo having sum(decode(x.tipo_transaccion,'D',-y.cantidad,y.cantidad) * y.monto) > 0) e");
			sbFilter.append(" and a.codigo = e.med_codigo");
		} else {
			sbFilter.append(" and a.estado = 'A'");
		}
	}
	else if (fp.equalsIgnoreCase("resAdmision") || fp.equalsIgnoreCase("img_lab"))
	{
		sbField.append(", d.nacionalidad as nacionalidadDesc");
		sbTable.append(", tbl_sec_pais d");
		sbFilter.append(" and a.nacionalidad=d.codigo(+)");
	}
	else if(fp.equalsIgnoreCase("exp_hist_obstetrica") || fp.equalsIgnoreCase("edit_cita") || fp.equalsIgnoreCase("mat_paciente")|| fp.equalsIgnoreCase("monitoreos"))
	{
	}
	else if(fp.equalsIgnoreCase("responsable"))//Expediente seccion medico Responsable.
	{
		showEspecialidad = false;
		if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
		sbField = new StringBuffer();
		sbTable = new StringBuffer();
		sbFilter = new StringBuffer();
		sbOrder = new StringBuffer();
		sbField.append(", '0' as especialidad, 'TODAS' as especialidadDesc");
		sbTable.append(", (select medico from tbl_sal_interconsultor where pac_id=");
		sbTable.append(pacId);
		sbTable.append(" and secuencia=");
		sbTable.append(noAdmision);
		sbTable.append(" union select medico from tbl_sal_progreso_clinico where pac_id=");
		sbTable.append(pacId);
		sbTable.append(" and admision=");
		sbTable.append(noAdmision);
		sbTable.append(") d");
		sbFilter.append(" where a.codigo=d.medico");
		sbOrder.append(" order by 3, 2");
	}
	else if(fp.equalsIgnoreCase("paciente"))//Admision creacion de paciente
	{
		sbField.append(" ,a.tipo_id,a.provincia_ced,a.sigla,a.tomo,a.asiento,a.primer_nombre,a.segundo_nombre, a.primer_apellido, a.segundo_apellido, a.apellido_de_casada,a.estado_civil, to_char(a.fecha_de_nacimiento,'dd/mm/yyyy')as fecha_de_nacimiento, a.religion, a.direccion, a.comunidad, a.corregimiento, a.distrito, a.provincia, a.pais, a.zona_postal, a.apartado_postal, a.celular, a.telefono_trabajo, a.lugar_de_trabajo,  a.e_mail, a.fax  ,(select nacionalidad from tbl_sec_pais b  where  b.codigo = a.nacionalidad  )nacionalidadDesc,(select nvl(d.nombre_comunidad, ' ')     from vw_sec_regional_location d where d.codigo_comunidad=a.comunidad and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia and d.codigo_distrito=a.distrito and d.codigo_corregimiento=a.corregimiento and nivel=4) as comunidadNombre,(select nvl(d.nombre_corregimiento, ' ') from vw_sec_regional_location d where d.codigo_corregimiento=a.corregimiento  and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia and d.codigo_distrito=a.distrito and nivel=3 ) as corregimientoNombre, (select nvl(d.nombre_distrito, ' ')      from vw_sec_regional_location d where d.codigo_distrito=a.distrito  and d.codigo_pais=a.pais and d.codigo_provincia=a.provincia and nivel=2) as distritoNombre, (select nvl(d.nombre_provincia, ' ')     from vw_sec_regional_location d where d.codigo_provincia=a.provincia  and d.codigo_pais=a.pais and  nivel =1)  as provincianombre, (select nvl(d.nombre_pais, ' ')          from vw_sec_regional_location d where d.codigo_pais=a.pais and nivel =0) as paisnombre  ");
	}		
	if (!status.equals("")) {sbFilter.append(" and a.estado='");sbFilter.append(status);sbFilter.append("'");}
	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	String apellido = request.getParameter("apellido");
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
	if (apellido == null) apellido = "";
	if (!codigo.trim().equals("")) {sbFilter.append(" and upper(nvl(a.reg_medico,a.codigo)) like '%");sbFilter.append(codigo.toUpperCase());sbFilter.append("%'");}
	if (!cedula.trim().equals("")) {sbFilter.append(" and upper(a.identificacion) like '%");sbFilter.append(cedula.toUpperCase());sbFilter.append("%'");}	
	if (!nombre.trim().equals("")) {
      if (!fp.equalsIgnoreCase("diag_pacientes")) {
      sbFilter.append(" and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)) like '%");
      }else{     sbFilter.append(" and upper(a.primer_nombre||decode(a.primer_apellido,null,'',' '||a.primer_apellido)) like '%"); }
      sbFilter.append(nombre.toUpperCase());sbFilter.append("%'");      
     }
	if (!apellido.trim().equals("")) {sbFilter.append(" and upper(a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada))) like '%");sbFilter.append(apellido.toUpperCase());sbFilter.append("%'");}
	sbSql = new StringBuffer();
	sbSql.append("select a.codigo, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) as nombre, a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) as apellido, a.estado, a.identificacion, a.nacionalidad, a.sexo, a.telefono,nvl(a.reg_medico,a.codigo) as reg_medico ");
	sbSql.append(sbField);
	sbSql.append(" from tbl_adm_medico a");
	sbSql.append(sbTable);
	sbSql.append(sbFilter);
	sbSql.append(sbOrder);

		
		
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");

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
    
    String jsContext = "window.opener.";
    if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Médico - '+document.title;

function add()
{
	abrir_ventana2('../admision/medico_config.jsp?fp=<%=fg%>');
}

function edit(id)
{
	abrir_ventana2('../admision/medico_config.jsp?mode=edit&id='+id);
}

function doAction(){<% if(context.equalsIgnoreCase("preventPopupFrame")) { if (al.size()==1){%> setMedico(0); <%}}%>
<%if(noResultClose.equals("1") && al.size() < 1){%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}%>
}

function setMedico(k)
{
	if (eval('document.medico.estado'+k).value.toUpperCase() == 'I')
	{
		alert('No está permitido seleccionar médicos inactivos!!');
	}
	else
	{
<%
	if (fp.equalsIgnoreCase("admision_medico_esp"))//fp.equalsIgnoreCase("pac_x_medicos")
	{
%>
		<%=jsContext%>document.form0.medico.value = eval('document.medico.codigo'+k).value;
		<%=jsContext%>document.form0.nombreMedico.value = eval('document.medico.nombre'+k).value;
		<%=jsContext%>document.form0.especialidad.value = eval('document.medico.especialidadDesc'+k).value;
		if(<%=jsContext%>document.form0.reg_medico)<%=jsContext%>document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
		
		
        <%if(context.equalsIgnoreCase("preventPopupFrame")){ if(al.size()==1){%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
        <%}}%>
        
 <%} else if (fp.equalsIgnoreCase("diag_pacientes")){%>
    <%=jsContext%>document.form0.medico.value = eval('document.medico.codigo'+k).value;
    <%=jsContext%>document.form0.nombreMedico.value = eval('document.medico.nombre'+k).value;
	if(<%=jsContext%>document.form0.reg_medico)<%=jsContext%>document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
 <%
 }else if(fp.equalsIgnoreCase("pac_x_medicos")) //Reporte de Pacientes Admitidos x Médico   
     {%>
      window.opener.document.form0.medico.value    = eval('document.medico.codigo'+k).value;
      window.opener.document.form0.nombre.value = eval('document.medico.nombre'+k).value;
	  if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%}	
	else if (fp.equalsIgnoreCase("exp_interconsulta_medico"))// referencia exp_interconsulta
	{
	%>
		window.opener.document.form0.cod_medico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_medico.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form0.cod_especialidad.value = eval('document.medico.especialidad'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
		//window.opener.document.form0.especialidad.value =    eval('document.medico.especialidadDesc'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("exp_verif_cuidad_pre_oper"))// referencia exp_irevision_preocupacion
	{
	%>
		window.opener.document.form0.cirujano.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.desc_medico_cirujano.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
		//window.opener.document.form0.cod_especialidad.value = eval('document.medico.especialidad'+k).value;
		//window.opener.document.form0.especialidad.value =    eval('document.medico.especialidadDesc'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("exp_interconsultor"))// referencia exp_interconsulta_medica, orderset
	{
		if (fg.equalsIgnoreCase("orderset")) {%>
    		window.opener.document.form0.medico_interconsulta<%=index%>.value = eval('document.medico.reg_medico'+k).value;
    		window.opener.document.form0.especialidad_interconsulta<%=index%>.value = eval('document.medico.especialidad'+k).value;
			
    		window.opener.document.form0.med_int_name<%=index%>.value = eval('document.medico.nombre'+k).value;
			window.opener.document.form0.espe_med_int<%=index%>.value = eval('document.medico.especialidadDesc'+k).value;		
	<%	} else { %>
		
		window.opener.document.form0.cod_medico<%=index%>.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_medico<%=index%>.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form0.cod_espec<%=index%>.value = eval('document.medico.especialidad'+k).value;
		window.opener.document.form0.espec<%=index%>.value =    eval('document.medico.especialidadDesc'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
   <%
	}
	}
	else if (fp.equalsIgnoreCase("citas_personal"))// progreso == referencia expediente Progreso clinico; responsable=Medico Reponsable.
	{
	%>
		window.opener.document.form2.medico<%=index%>.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form2.nombre<%=index%>.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form2.sociedad<%=index%>.value = "N";
		window.opener.document.form2.tipoPersonal<%=index%>.value='M';
		if(window.opener.document.form2.reg_medico)window.opener.document.form2.reg_medico.value = eval('document.medico.reg_medico'+k).value;

<%}	
	else if (fp.equalsIgnoreCase("progreso") || fp.equalsIgnoreCase("responsable"))// progreso == referencia expediente Progreso clinico; responsable=Medico Reponsable.
	{
	if (fp.equalsIgnoreCase("progreso")) {
	%>
	  if(window.opener.document.form0.medico)window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
	  if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
		if(window.opener.document.form0.nombre_medico) window.opener.document.form0.nombre_medico.value = eval('document.medico.nombre'+k).value;
		
		if(window.opener.document.form0.medico<%=index%>)window.opener.document.form0.medico<%=index%>.value = eval('document.medico.codigo'+k).value;
		if(window.opener.document.form0.reg_medico<%=index%>)window.opener.document.form0.reg_medico<%=index%>.value = eval('document.medico.reg_medico'+k).value;
		if(window.opener.document.form0.nombre_medico<%=index%>) window.opener.document.form0.nombre_medico<%=index%>.value = eval('document.medico.nombre'+k).value;
	<%
	} else {
	%>
		if(window.opener.document.form0.medico<%=index%>)window.opener.document.form0.medico<%=index%>.value = eval('document.medico.codigo'+k).value;
		if(window.opener.document.form0.nombre_medico<%=index%>) window.opener.document.form0.nombre_medico<%=index%>.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico<%=index%>)window.opener.document.form0.reg_medico<%=index%>.value = eval('document.medico.reg_medico'+k).value;
	<%}%>

<%}else if (fp.equalsIgnoreCase("exp_hist_obstetrica"))//referencia expediente historia obstetrica parte I
	{
	%>
		window.opener.document.form0.codMedico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_medico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;

<%}else if (fp.equalsIgnoreCase("exp_informes"))//referencia expediente informes de Broncoscopia, etc.
	{
	%>
		window.opener.document.form0.codMedico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_medico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;

<%}	else if (fp.equalsIgnoreCase("citas") && fg.equals("dr_reserva"))//referencia citas creacion de citas
	{
%>
		window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_medico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.persona_reserva)window.opener.document.form0.persona_reserva.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%}	else if (fp.equalsIgnoreCase("presupuesto"))//presupuesto
	{
%>
		window.opener.document.search01.medico.value = eval('document.medico.reg_medico'+k).value;
		window.opener.document.search01.nombre_medico.value = eval('document.medico.nombre'+k).value;

<%}else if (fp.equals("cotizacion"))// 
	{
%>
		window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_medico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
 
<%}
	else if (fp.equalsIgnoreCase("citas") && fg.equals("dr_anestesiologo"))//referencia citas creacion de citas
	{
	%>
		window.opener.document.form0.anestesiologo.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.anestesiologoNombre.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;

<%}else if (fp.equalsIgnoreCase("protocoloOp"))//Protocolo operatorio Expediente
	{
	 if(fg.trim().equals("CR"))
	{%>

		window.opener.document.form0.cirujano.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.cirujanoName.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
	<%} else if(fg.trim().equals("AS"))
	{%>

		window.opener.document.form0.asistente.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.asistenteName.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
	<%} else if(fg.trim().equals("PA"))
	{%>

		window.opener.document.form0.patologo.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.patologoNombre.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
	<%}%>


<%}else if (fp.equalsIgnoreCase("protocolo"))//Protocolo operatorio anestesiologo
	{
	%>
		window.opener.document.form0.anestesiologo.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.anestesiologoNombre.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;

<%}else if (fp.equalsIgnoreCase("recuperacion_anes_sop")){%>
    <%if (fg.equalsIgnoreCase("ANES")) {%>
    window.opener.document.form0.anestesiologo.value = eval('document.medico.codigo'+k).value;
    window.opener.document.form0.anestesiologoNombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
    <%} else if (fg.equalsIgnoreCase("CIR")) {%>
    window.opener.document.form0.cirujano.value = eval('document.medico.codigo'+k).value;
    window.opener.document.form0.cirujanoNombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
    <%}%>
<%} else if(fp.equalsIgnoreCase("EPA")) { 
if (fg.equalsIgnoreCase("anestesiologo")) {%>
    window.opener.document.form0.codAnestesiologo.value    = eval('document.medico.codigo'+k).value;
    window.opener.document.form0.nombre_anestesiologo.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%} else if(fg.equalsIgnoreCase("CIR")) {%>
	window.opener.document.form0.cirujano.value    = eval('document.medico.codigo'+k).value;
    window.opener.document.form0.nombre_cirujano.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%}
}else if (fp.equalsIgnoreCase("imagenologia") || fp.equalsIgnoreCase("laboratorio")|| fp.equalsIgnoreCase("BDS"))
	{
%>

		window.opener.document.form001.codigoMedico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form001.nombreMedico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form001.reg_medico)window.opener.document.form001.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("expOrdenesMed"))
	{
%>
		if(window.opener.document.form0.medico)window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
		if(window.opener.document.form0.nombreMedico)window.opener.document.form0.nombreMedico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("addEntregaDr"))
	{
%>
		window.opener.document.form001.cambio_turno_id.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form001.cambio_turno.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form001.reg_medico)window.opener.document.form001.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("medico_id"))
	{
%>
		window.opener.document.form001.id_med.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form001.nombre_med.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form001.cod_especialidad_ce.value = eval('document.medico.especialidad'+k).value;
		window.opener.document.form001.especialidad.value =    eval('document.medico.especialidadDesc'+k).value;
		if(window.opener.document.form001.reg_medico)window.opener.document.form001.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("admision_medico_cab"))
	{
%>		
		<%=jsContext%>document.form0.medicoCabecera.value = eval('document.medico.codigo'+k).value;
		<%=jsContext%>document.form0.nombreMedicoCabecera.value = eval('document.medico.nombre'+k).value;
		if(<%=jsContext%>document.form0.medicoCabecera_reg)<%=jsContext%>document.form0.medicoCabecera_reg.value = eval('document.medico.reg_medico'+k).value;
		
		<%if(context.equalsIgnoreCase("preventPopupFrame")){ if(al.size()==1){%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
        <%}}%>
		
		
		
<%
	}
	else if (fp.equalsIgnoreCase("admision_medico_resp"))
	{
%>
		//		window.opener.document.form5.tipoIdentificacion<%=index%>.value = 'C';
		window.opener.document.form5.lugarNac<%=index%>.value = '';
		window.opener.document.form5.seguroSocial<%=index%>.value = '';
		window.opener.document.form5.sexo<%=index%>.value = '';
		window.opener.document.form5.empresa<%=index%>.value = '';
		window.opener.document.form5.numEmpleado<%=index%>.value = '';
		window.opener.document.form5.medico<%=index%>.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form5.nombre<%=index%>.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form5.identificacion<%=index%>.value = eval('document.medico.identificacion'+k).value;
		window.opener.document.form5.nacionalidad<%=index%>.value = eval('document.medico.nacionalidad'+k).value;
		window.opener.document.form5.sexo<%=index%>.value = eval('document.medico.sexo'+k).value;
		window.opener.document.form5.nacionalidadDesc<%=index%>.value = eval('document.medico.nacionalidadDesc'+k).value;
		if(window.opener.document.form5.reg_medico)window.opener.document.form5.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	} else if (fp.equalsIgnoreCase("admision_medico_resp_new"))
	{
%>
		//		window.opener.document.form1.tipoIdentificacion<%=index%>.value = 'C';
		window.opener.document.form1.lugarNac<%=index%>.value = '';
		window.opener.document.form1.seguroSocial<%=index%>.value = '';
		window.opener.document.form1.sexo<%=index%>.value = '';
		window.opener.document.form1.empresa<%=index%>.value = '';
		window.opener.document.form1.numEmpleado<%=index%>.value = '';
		window.opener.document.form1.medico<%=index%>.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form1.nombre<%=index%>.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form1.identificacion<%=index%>.value = eval('document.medico.identificacion'+k).value;
		window.opener.document.form1.nacionalidad<%=index%>.value = eval('document.medico.nacionalidad'+k).value;
		window.opener.document.form1.sexo<%=index%>.value = eval('document.medico.sexo'+k).value;
		window.opener.document.form1.nacionalidadDesc<%=index%>.value = eval('document.medico.nacionalidadDesc'+k).value;
		if(window.opener.document.form1.reg_medico)window.opener.document.form1.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("cargo_dev"))
	{
%>
		if(window.opener.document.form0.empreCodigo)window.opener.document.form0.empreCodigo.value='';
		if(window.opener.document.form0.empreDesc)window.opener.document.form0.empreDesc.value='';
		if(window.opener.document.form0.medico)window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
		if(window.opener.document.form0.nombreMedico)window.opener.document.form0.nombreMedico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.noDocumento)window.opener.document.form0.noDocumento.value = eval('document.medico.noDocumento'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
		 
<%
	} else if (fp.equalsIgnoreCase("liq_recl")){
%>  
     if ($("#medicoOrEmpre<%=index%>",window.opener.document).length) $("#medicoOrEmpre<%=index%>",window.opener.document).val(eval('document.medico.codigo'+k).value);
     if ($("#nombreMedicoOrEmpre<%=index%>",window.opener.document).length) $("#nombreMedicoOrEmpre<%=index%>",window.opener.document).val(eval('document.medico.codigo'+k).value+'-'+eval('document.medico.nombre'+k).value);
     
     if ($("#descripcion<%=index%>",window.opener.document).length && !$("#descripcion<%=index%>",window.opener.document).val()) $("#descripcion<%=index%>",window.opener.document).val(eval('document.medico.nombre'+k).value);

     if ($("#medico<%=index%>",window.opener.document).length) $("#medico<%=index%>",window.opener.document).val(eval('document.medico.codigo'+k).value);
     if ($("#medico_nombre<%=index%>",window.opener.document).length) $("#medico_nombre<%=index%>",window.opener.document).val(eval('document.medico.nombre'+k).value);
	 
	  if ($("#reg_medico<%=index%>",window.opener.document).length) $("#reg_medico<%=index%>",window.opener.document).val(eval('document.medico.reg_medico'+k).value);
<%
	} else if (fp.equalsIgnoreCase("hist_reclamo")){
%>  
     if ($("#medicoOrEmpre",window.opener.document).length) $("#medicoOrEmpre",window.opener.document).val(eval('document.medico.codigo'+k).value);
     if ($("#nombreMedicoOrEmpre",window.opener.document).length) $("#nombreMedicoOrEmpre",window.opener.document).val(eval('document.medico.codigo'+k).value+'-'+eval('document.medico.nombre'+k).value);
     
     if ($("#descripcion",window.opener.document).length && !$("#descripcion",window.opener.document).val()) $("#descripcion",window.opener.document).val(eval('document.medico.nombre'+k).value);

     if ($("#medico<%=index%>",window.opener.document).length) $("#medico",window.opener.document).val(eval('document.medico.codigo'+k).value);
     if ($("#medico_nombre",window.opener.document).length) $("#medico_nombre",window.opener.document).val(eval('document.medico.nombre'+k).value);
	 if ($("#reg_medico<%=index%>",window.opener.document).length) $("#reg_medico<%=index%>",window.opener.document).val(eval('document.medico.reg_medico'+k).value);
<%    
    }
	else if (fp.equalsIgnoreCase("resAdmision"))
	{
%>
		window.opener.document.form1.medicoRefId.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form1.medicoRefNombre.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form1.medicoRefTel.value = eval('document.medico.telefono'+k).value;
		if(window.opener.document.form1.reg_medico)window.opener.document.form1.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("img_lab")|| fp.equalsIgnoreCase("monitoreos"))
	{
%>
		window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.medicoDesc.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}//sol_img_estudio
	else if (fp.equalsIgnoreCase("sol_img_estudio") || fp.equalsIgnoreCase("sol_lab_estudio"))
	{//monitoreos Admision
%>
		window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.medicoDesc.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if(fp.equalsIgnoreCase("exp_hist_obstetrica"))
	{
%>
	window.opener.document.form0.codMedico.value= eval('document.medico.codigo'+k).value;
	window.opener.document.form0.nombre_medico.value= eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
}
else if (fp.equalsIgnoreCase("notas_ajustes"))
	{
%>
		window.opener.document.form1.v_codigo<%=index%>.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form1.name_code<%=index%>.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form1.reg_medico)window.opener.document.form1.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	//
	else if (fp.equalsIgnoreCase("notas_h"))
	{
%>
		window.opener.document.form1.codigo_medico<%=index%>.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form1.descripcion<%=index%>.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form1.reg_medico<%=index%>)window.opener.document.form1.reg_medico<%=index%>.value = eval('document.medico.reg_medico'+k).value;
<%}
	else if (fp.equalsIgnoreCase("mat_paciente"))
	{
%>
		window.opener.document.paciente.medico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.paciente.nombreMedico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.paciente.reg_medico)window.opener.document.paciente.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%}
	else if (fp.equalsIgnoreCase("cargo_oc"))
	{
%>
		window.opener.document.form0.medico_receta.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.medico_receta_desc.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("user"))
	{
%>
		window.opener.document.form0.refCode.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.name.value = eval('document.medico.nombre'+k).value;
		window.opener.document.form0.refCodeDisplay.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("notas_enf") || fp.equalsIgnoreCase("pUniversal"))
	{
%>
		window.opener.document.form0.cod_medico.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_medico.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("pUniversalPed"))
	{
%>
		window.opener.document.form0.pediatra.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.reg_pediatra.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_pediatra.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}else if (fp.equalsIgnoreCase("pUniversalASIS"))
	{
%>
		window.opener.document.form0.asistente.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_asistente.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.asistente_quirurgico)window.opener.document.form0.asistente_quirurgico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("pUniversalAnest"))
	{
%>
		window.opener.document.form0.anestesiologo.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.reg_anestesiologo.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.nombre_anestesiologo.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("cds_solicitud_rayx_lab_ped") || fp.equalsIgnoreCase("cds_solicitud_lab_ext"))
	{
%>
		<%if (modalize.equalsIgnoreCase("Y")) {%>
      var $form0 = $("#i-content", window.parent.document).contents().find("#form0");
      
      var form0 = $form0.get(0);
      form0["medCodigoResp"].value = eval('document.medico.codigo'+k).value;
      form0["medicoNombre"].value = eval('document.medico.nombre'+k).value;
      form0["reg_medico"].value = eval('document.medico.reg_medico'+k).value;
      
      window.parent.hidePopWin();
            
		<%} else {%>
		window.opener.document.form0.medCodigoResp.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form0.medicoNombre.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
		<%}%>
<%
	}
	else if (fp.equalsIgnoreCase("datos_bb"))
	{
%>
	window.opener.document.form1.pediatra.value = eval('document.medico.codigo'+k).value;
	window.opener.document.form1.nombreMedico.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form1.reg_medico)window.opener.document.form1.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	
	}
	else if (fp.equalsIgnoreCase("datos_mama"))
	{
%>
	window.opener.document.form1.ginecologo.value = eval('document.medico.codigo'+k).value;
	window.opener.document.form1.nombreGinecologo.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form1.reg_medico)window.opener.document.form1.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
}
 else if (fp.equalsIgnoreCase("saldoIni"))
 {
%>
	window.opener.document.form1.id_cliente.value = eval('document.medico.codigo'+k).value;
	window.opener.document.form1.nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form1.id_cliente_view)window.opener.document.form1.id_cliente_view.value = eval('document.medico.reg_medico'+k).value;
<%
	} 
	else if (fp.equalsIgnoreCase("citas_x_medico"))
	{
%>
     window.opener.document.search00.medico.value = eval('document.medico.codigo'+k).value;
	 window.opener.document.search00.nombreMedico.value = eval('document.medico.nombre'+k).value;
	 if(window.opener.document.search00.reg_medico)window.opener.document.search00.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
	}
	else if (fp.equalsIgnoreCase("ajuste_cxp"))
{
%>
		window.opener.document.form1.ref_id.value = eval('document.medico.codigo'+k).value;
		window.opener.document.form1.nombre.value = eval('document.medico.nombre'+k).value;
		if(window.opener.document.form1.reg_medico)window.opener.document.form1.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%
}else if (fp.equalsIgnoreCase("citas_cons")){%>
    window.opener.document.search01.medico.value = eval('document.medico.codigo'+k).value;
	window.opener.document.search01.nombre_medico.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.search01.reg_medico)window.opener.document.search01.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("procedimientos_x_med")){%>
    if(window.opener.document.search00.medCodigo)window.opener.document.search00.medCodigo.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.search00.medNombre)window.opener.document.search00.medNombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.search00.reg_medico)window.opener.document.search00.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("valores_criticos")){%>
    if(window.opener.document.form2.medico_enterado<%=index%>)window.opener.document.form2.medico_enterado<%=index%>.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form2.medico_enterado_nombre<%=index%>)window.opener.document.form2.medico_enterado_nombre<%=index%>.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form2.reg_medico)window.opener.document.form2.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("ronda_uci")){%>
    if(window.opener.document.form0.medico)window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.medico_nombre)window.opener.document.form0.medico_nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("sad_person")){%>
    if(window.opener.document.form0.medico_verificador<%=index%>)
       window.opener.document.form0.medico_verificador<%=index%>.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.medico_verificador_nombre<%=index%>)
       window.opener.document.form0.medico_verificador_nombre<%=index%>.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico<%=index%>)window.opener.document.form0.reg_medico<%=index%>.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("handover")){%>
    if(window.opener.document.form0.medico)window.opener.document.form0.medico.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.medico_nombre)window.opener.document.form0.medico_nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("hm2")){%>
    if(window.opener.document.form0.medico_nefro)window.opener.document.form0.medico_nefro.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.medico_nefro_nombre)window.opener.document.form0.medico_nefro_nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("monitoreo_fetal")){%>
    if(window.opener.document.form0.medico_obstetra)window.opener.document.form0.medico_obstetra.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.medico_obstetra_nombre)window.opener.document.form0.medico_obstetra_nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("rondas")){%>
    if(window.opener.document.form0.medico<%=index%>)window.opener.document.form0.medico<%=index%>.value = eval('document.medico.nombre'+k).value;
<%	
}else if (fp.equalsIgnoreCase("plan_salida")){%>
    if(window.opener.document.form7.extra6)window.opener.document.form7.extra6.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form7.extra7)window.opener.document.form7.extra7.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form7.reg_medico)window.opener.document.form7.reg_medico.value = eval('document.medico.reg_medico'+k).value;
<%	
}else if (fp.equalsIgnoreCase("protocolo_cesarea")){%>
    <%if(fg.trim().equalsIgnoreCase("CI")){%>
    if(window.opener.document.form0.cirujano)window.opener.document.form0.cirujano.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.cirujano_nombre)window.opener.document.form0.cirujano_nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
    <%} else if(fg.trim().equalsIgnoreCase("AN")){%>
    if(window.opener.document.form0.anestesiologo)window.opener.document.form0.anestesiologo.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.anestesiologo_nombre)window.opener.document.form0.anestesiologo_nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
    <%} else if(fg.trim().equalsIgnoreCase("PE")){%>
    if(window.opener.document.form0.pediatra)window.opener.document.form0.pediatra.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.pediatra_nombre)window.opener.document.form0.pediatra_nombre.value = eval('document.medico.nombre'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
    <%}%>
<%	
}else if (fp.equalsIgnoreCase("sumario_egreso_med_neo")){%>
    <%if(fg.trim().equalsIgnoreCase("2")){%>
	if(window.opener.document.form0.pediatra_neo)
       window.opener.document.form0.pediatra_neo.value = eval('document.medico.nombre'+k).value;
    <%} else if(fg.trim().equalsIgnoreCase("1")){%>
	if(window.opener.document.form0.doctor_nombre)
       window.opener.document.form0.doctor_nombre.value = eval('document.medico.nombre'+k).value;
    <%}%>
<%	
}else if (fp.equalsIgnoreCase("paciente")){%>
    if(window.opener.document.form0.nacionalCode)window.opener.document.form0.nacionalCode.value = eval('document.medico.nacionalidad'+k).value;
	if(window.opener.document.form0.nacional)window.opener.document.form0.nacional.value = eval('document.medico.nacionalidadDesc'+k).value;
	if(window.opener.document.form0.sexo)window.opener.document.form0.sexo.value = eval('document.medico.sexo'+k).value;
	if(window.opener.document.form0.telefono)window.opener.document.form0.telefono.value = eval('document.medico.telefono'+k).value;
	if(window.opener.document.form0.primerNom)window.opener.document.form0.primerNom.value = eval('document.medico.primer_nombre'+k).value;	
	if(window.opener.document.form0.segundoNom)window.opener.document.form0.segundoNom.value = eval('document.medico.segundo_nombre'+k).value;
	if(window.opener.document.form0.primerApell)window.opener.document.form0.primerApell.value = eval('document.medico.primer_apellido'+k).value;	
	if(window.opener.document.form0.segundoApell)window.opener.document.form0.segundoApell.value = eval('document.medico.segundo_apellido'+k).value;
	if(window.opener.document.form0.casadaApell)window.opener.document.form0.casadaApell.value = eval('document.medico.apellido_de_casada'+k).value;
	if(window.opener.document.form0.fechaCorrec)window.opener.document.form0.fechaCorrec.value = eval('document.medico.fecha_de_nacimiento'+k).value;
	if(window.opener.document.form0.fechaNaci)window.opener.document.form0.fechaNaci.value = eval('document.medico.fecha_de_nacimiento'+k).value;
	if(window.opener.document.form0.religionCode)window.opener.document.form0.religionCode.value = eval('document.medico.religion'+k).value;
	if(window.opener.document.form0.direccion)window.opener.document.form0.direccion.value = eval('document.medico.direccion'+k).value;
	
	if(window.opener.document.form0.comunidadCode)window.opener.document.form0.comunidadCode.value = eval('document.medico.comunidad'+k).value;
	if(window.opener.document.form0.corregiCode)window.opener.document.form0.corregiCode.value = eval('document.medico.corregimiento'+k).value;
	if(window.opener.document.form0.distritoCode)window.opener.document.form0.distritoCode.value = eval('document.medico.distrito'+k).value;
	if(window.opener.document.form0.provCode)window.opener.document.form0.provCode.value = eval('document.medico.provincia'+k).value;
	if(window.opener.document.form0.paisCode)window.opener.document.form0.paisCode.value = eval('document.medico.pais'+k).value;
	
	if(window.opener.document.form0.comunidad)window.opener.document.form0.comunidad.value = eval('document.medico.comunidadNombre'+k).value;
	if(window.opener.document.form0.corregi)window.opener.document.form0.corregi.value = eval('document.medico.corregimientoNombre'+k).value;
	if(window.opener.document.form0.distrito)window.opener.document.form0.distrito.value = eval('document.medico.distritoNombre'+k).value;
	if(window.opener.document.form0.prov)window.opener.document.form0.prov.value = eval('document.medico.provincianombre'+k).value;
	if(window.opener.document.form0.pais)window.opener.document.form0.pais.value = eval('document.medico.paisnombre'+k).value;
	
	
	if(window.opener.document.form0.zonaPostal)window.opener.document.form0.zonaPostal.value = eval('document.medico.zona_postal'+k).value;
	if(window.opener.document.form0.aptdoPostal)window.opener.document.form0.aptdoPostal.value = eval('document.medico.apartado_postal'+k).value;
	
	//if(window.opener.document.form0.telefono_movil)window.opener.document.form0.telefono_movil.value = eval('document.medico.celular'+k).value;
	if(window.opener.document.form2.telTrabajo)window.opener.document.form2.telTrabajo.value = eval('document.medico.telefono_trabajo'+k).value;
	if(window.opener.document.form2.lugarTrab)window.opener.document.form2.lugarTrab.value = eval('document.medico.lugar_de_trabajo'+k).value;
	if(window.opener.document.form0.e_mail)window.opener.document.form0.e_mail.value = eval('document.medico.e_mail'+k).value;
	if(window.opener.document.form0.fax)window.opener.document.form0.fax.value = eval('document.medico.fax'+k).value;
	if(window.opener.document.form0.ref_id)window.opener.document.form0.ref_id.value = eval('document.medico.codigo'+k).value;
	if(window.opener.document.form0.estadoCivil)window.opener.document.form0.estadoCivil.value = eval('document.medico.estado_civil'+k).value;
	window.opener.CalculateAge();
	
	if(window.opener.document.form0.tipoSangre)window.opener.document.form0.tipoSangre.value = '';
	if(window.opener.document.form0.tipoId)window.opener.document.form0.tipoId.value = eval('document.medico.tipo_id'+k).value;
	if(window.opener.document.form0.reg_medico)window.opener.document.form0.reg_medico.value = eval('document.medico.reg_medico'+k).value;
	window.opener.setId(true);
	if(eval('document.medico.tipo_id'+k).value=='C')
	{ 
		window.opener.document.form0.provincia.value=eval('document.medico.provincia_ced'+k).value;
		window.opener.document.form0.sigla.value=eval('document.medico.sigla'+k).value;
		window.opener.document.form0.tomo.value=eval('document.medico.tomo'+k).value;
		window.opener.document.form0.asiento.value=eval('document.medico.asiento'+k).value;
	}
	else
	{
		if(window.opener.document.form0.pasaporte)window.opener.document.form0.pasaporte.value = eval('document.medico.identificacion'+k).value;
  	}
  window.opener.isValidId();
	
	       
<%	
}
%>
		<%if(context.equalsIgnoreCase("preventPopupFrame")){%>
           <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
		<%}else{%>
        window.close();
        <%}%>
}
}

function getMain(formx)
{
	formx.especialidad.value = document.search00.especialidad.value;
	formx.status.value = document.search00.status.value;
	return true;
}

function verificarCant(){
	size = <%=al.size()%>;
	var contChk =0;
	var htPersonal = <%=htPersonal.size()%>;
	for(i=0;i<size;i++){
		if(eval('document.medico.chkMed'+i) && eval('document.medico.chkMed'+i).checked) contChk++;
		if((contChk+htPersonal)==3){
			alert('No puede seleccionar más de 2 médicos!')
			eval('document.medico.chkMed'+i).checked = false;
			break;
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MEDICO"></jsp:param>
</jsp:include>
<%if(!context.equalsIgnoreCase("preventPopupFrame")){%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;
<%if (fg.equalsIgnoreCase("admision")||fg.equalsIgnoreCase("admision_new")){%>
			<authtype type='50'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo M&eacute;dico</cellbytelabel> ]</a></authtype>
<%}%>
	</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
			<td colspan="3">
				<% if (showEspecialidad) { %>
<cellbytelabel id="2">Especialidad</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_adm_especialidad_medica order by descripcion","especialidad",especialidad,false,false,0,"Text10",null,null,null,"T")%>
				<%}%><cellbytelabel id="3">Estado</cellbytelabel>
					<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
					<cellbytelabel id="4">Identificacion</cellbytelabel>
				<%=fb.textBox("cedula",cedula,false,false,false,15,"Text10",null,null)%>
				<%if (fp.trim().equalsIgnoreCase("liq_recl")){%>
				Referencia:<%=fb.textBox("referencia",referencia,false,false,false,15,"Text10",null,null)%>
				<%}%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="26%">
				<cellbytelabel id="4">Registro M&eacute;dico</cellbytelabel>
				<%=fb.textBox("codigo","",false,false,false,15,"Text10",null,null)%>
			</td>
			<td width="37%">
				<cellbytelabel id="5">Nombre</cellbytelabel>
				<%=fb.textBox("nombre","",false,false,false,40,"Text10",null,null)%>
			</td>
				<td width="37%">
				<cellbytelabel id="6">Apellido</cellbytelabel>
				<%=fb.textBox("apellido","",false,false,false,40,"Text10",null,null)%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
				</td>
<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<%}%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("especialidad",especialidad).replaceAll(" id=\"especialidad\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("referencia",referencia)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("especialidad",especialidad).replaceAll(" id=\"especialidad\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("referencia",referencia)%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("medico","", "post","");%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cedula",cedula)%>
<%
if(fp.equals("edit_cita")){
%>
		<tr>
			<td align="right" colspan="5"><%=fb.submit("add","Agregar")%><!--<%=fb.submit("addCont","Agregar y Continuar")%>--></td>
		</tr>
<%
}
%>
		<tr class="TextHeader" align="center">
			<td width="30%"><cellbytelabel id="5">Nombre</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="6">Apellido</cellbytelabel></td>
			<td width="20%"><cellbytelabel id="6">Identificacion</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td width="10%">&nbsp; <%if (fp.equalsIgnoreCase("cargo_dev") || fp.equalsIgnoreCase("liq_recl")){%>Boletas <%}%></td>
		</tr>
<%
String especial = "";
int cont = 0;
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("reg_medico"+i,cdo.getColValue("reg_medico"))%>
		<%=fb.hidden("nombre"+i,cdo.getColValue("nombre")+" "+cdo.getColValue("apellido"))%>
		<%=fb.hidden("especialidad"+i,cdo.getColValue("especialidad"))%>
		<%=fb.hidden("especialidadDesc"+i,cdo.getColValue("especialidadDesc"))%>
		<%=fb.hidden("identificacion"+i,cdo.getColValue("identificacion"))%>
		<%=fb.hidden("noDocumento"+i,cdo.getColValue("no_documento"))%>		
		
		<%=fb.hidden("nacionalidadDesc"+i,cdo.getColValue("nacionalidadDesc"))%>
		<%=fb.hidden("nacionalidad"+i,cdo.getColValue("nacionalidad"))%>
		<%=fb.hidden("sexo"+i,cdo.getColValue("sexo"))%>
		<%=fb.hidden("telefono"+i,cdo.getColValue("telefono"))%>

		<%if(fp.equalsIgnoreCase("paciente")){%>		
		
		<%=fb.hidden("primer_nombre"+i,cdo.getColValue("primer_nombre"))%>
		<%=fb.hidden("segundo_nombre"+i,cdo.getColValue("segundo_nombre"))%>
		<%=fb.hidden("primer_apellido"+i,cdo.getColValue("primer_apellido"))%>
		<%=fb.hidden("segundo_apellido"+i,cdo.getColValue("segundo_apellido"))%>
		<%=fb.hidden("apellido_de_casada"+i,cdo.getColValue("apellido_de_casada"))%>
		<%=fb.hidden("estado_civil"+i,cdo.getColValue("estado_civil"))%>
		<%=fb.hidden("fecha_de_nacimiento"+i,cdo.getColValue("fecha_de_nacimiento"))%>
		<%=fb.hidden("religion"+i,cdo.getColValue("religion"))%>
		<%=fb.hidden("direccion"+i,cdo.getColValue("direccion"))%>
		<%=fb.hidden("comunidad"+i,cdo.getColValue("comunidad"))%>
		<%=fb.hidden("corregimiento"+i,cdo.getColValue("corregimiento"))%>
		<%=fb.hidden("distrito"+i,cdo.getColValue("distrito"))%>
		
		<%=fb.hidden("provincia"+i,cdo.getColValue("provincia"))%>
		<%=fb.hidden("pais"+i,cdo.getColValue("pais"))%>
		<%=fb.hidden("zona_postal"+i,cdo.getColValue("zona_postal"))%>
		<%=fb.hidden("apartado_postal"+i,cdo.getColValue("apartado_postal"))%>
		<%=fb.hidden("celular"+i,cdo.getColValue("celular"))%>
		<%=fb.hidden("telefono_trabajo"+i,cdo.getColValue("telefono_trabajo"))%>
		<%=fb.hidden("lugar_de_trabajo"+i,cdo.getColValue("lugar_de_trabajo"))%>
		<%=fb.hidden("e_mail"+i,cdo.getColValue("e_mail"))%>
		<%=fb.hidden("fax"+i,cdo.getColValue("fax"))%>
		<%=fb.hidden("comunidadNombre"+i,cdo.getColValue("comunidadNombre"))%>
		<%=fb.hidden("corregimientoNombre"+i,cdo.getColValue("corregimientoNombre"))%>
		<%=fb.hidden("distritoNombre"+i,cdo.getColValue("distritoNombre"))%>
		<%=fb.hidden("provincianombre"+i,cdo.getColValue("provincianombre"))%>
		<%=fb.hidden("paisnombre"+i,cdo.getColValue("paisnombre"))%> 
		
		<%=fb.hidden("provincia_ced"+i,cdo.getColValue("provincia_ced"))%> 
		<%=fb.hidden("sigla"+i,cdo.getColValue("sigla"))%> 
		<%=fb.hidden("tomo"+i,cdo.getColValue("tomo"))%> 
		<%=fb.hidden("asiento"+i,cdo.getColValue("asiento"))%>  
		<%=fb.hidden("tipo_id"+i,cdo.getColValue("tipo_id"))%>  
   
		
<%}
	if (!especial.equalsIgnoreCase(cdo.getColValue("especialidad")+"|"+cdo.getColValue("especialidadDesc")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="5">[<%=cdo.getColValue("especialidad")%>] <%= (cdo.getColValue("especialidadDesc").trim().equals(""))?"NO TIENE":cdo.getColValue("especialidadDesc")%></td>
		</tr>
<%
	}
%>
		<%if(!fp.equalsIgnoreCase("edit_cita")){%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setMedico(<%=i%>)" style="text-decoration:none; cursor:pointer">
		<%} else {%>
		<tr class="<%=color%>">
		<%}%>
			<td><%=cdo.getColValue("nombre")%></td>
			<td><%=cdo.getColValue("apellido")%>-<%=cdo.getColValue("reg_medico")%></td>
			<td><%=cdo.getColValue("identificacion")%></td>
			<td align="center"><%=(cdo.getColValue("estado").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
			<td align="center">
			<%if(fp.equals("edit_cita") && htPersonalKey.containsKey(cdo.getColValue("codigo"))){
				cont++;
			%>
			<cellbytelabel id="10">elegido</cellbytelabel>
			<%} else if(fp.equals("edit_cita") && !htPersonalKey.containsKey(cdo.getColValue("codigo"))){%>
			<%=fb.checkbox("chkMed"+i,""+i,false, false, "", "", "onClick=\"javascript:verificarCant()\"")%>
			<%}%>
			 <%if (fp.equalsIgnoreCase("cargo_dev") || fp.equalsIgnoreCase("liq_recl")){%><%=cdo.getColValue("no_documento")%> <%}%>

<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100030"))
//{
%>
			<!--<a href="javascript:edit('<%//=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a>-->
<%
//}
%>
			</td>
		</tr>
<%
	especial = cdo.getColValue("especialidad")+"|"+cdo.getColValue("especialidadDesc");
}
%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.hidden("cont",""+cont)%>
<%=fb.formEnd()%>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("especialidad",especialidad).replaceAll(" id=\"especialidad\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("referencia",referencia)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("especialidad",especialidad).replaceAll(" id=\"especialidad\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("apellido",apellido)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("userId",userId)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("noResultClose",noResultClose)%>
<%=fb.hidden("cedula",cedula)%>
<%=fb.hidden("referencia",referencia)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
else
{
	String key = "";
	int lineNo = htPersonal.size();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	if(fp.equalsIgnoreCase("edit_cita")){
		for(int i=0;i<keySize;i++){
			CitaPersonal det = new CitaPersonal();
			det.setCodigo("");
			det.setMedico(request.getParameter("codigo"+i));
			det.setMedicoNombre(request.getParameter("nombre"+i));

			if(request.getParameter("chkMed"+i)!=null){
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				htPersonal.put(key, det);
			}
		}
	}
	/*
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_diagnostico.jsp?change=1&type=1&procKey="+procKey+"&fp="+fp+"&cs="+cs);
		return;
	}
	*/
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("edit_cita")){%>
	window.opener.location = '<%=request.getContextPath()+"/cita/edit_cita.jsp?mode=edit&change=1"%>&fp=<%=fp%>&tab=<%=tab%>&codCita=<%=codCita%>&fechaCita=<%=fechaCita%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>