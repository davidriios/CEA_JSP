<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.expediente.Rondas"%>
<%@ page import="issi.expediente.DetalleRondas"%>
<%@ page import="issi.expediente.DetalleRondasDiag"%>
<%@ page import="issi.expediente.DetalleRondasSignos"%>
<%@ page import="issi.expediente.DetalleRondasIndicaciones"%>
<%@ page import="issi.expediente.DetalleRondasTratamientos"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HashDet1" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HashDet2" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HashDet3" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HashDet4" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HashDet5" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="RonMgr" scope="page" class="issi.expediente.RondasMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
RonMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoTmp = new CommonDataObject();
Rondas ron = new Rondas();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fecha = request.getParameter("fecha");
String hora = request.getParameter("hora");
String fg = request.getParameter("fg");
String defaultAction = request.getParameter("defaultAction");
String desc = request.getParameter("desc");
String filter = "";
String codigo = request.getParameter("codigo");
String change1 = request.getParameter("change1");
String change2 = request.getParameter("change2");
String change3 = request.getParameter("change3");
String change4 = request.getParameter("change4");
String change5 = request.getParameter("change5");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

int lastLineNo1 = 0, lastLineNo2 = 0, lastLineNo3 = 0, lastLineNo4 = 0, lastLineNo5 = 0;
String key1 = "";
String key2 = "";
String key3 = "";
String key4 = "";
String key5 = "";
String colsPan = "";
String toDay = cDateTime.substring(0,10);

if (fecha == null) fecha = cDateTime.substring(0,10);
if (hora == null) hora = cDateTime.substring(11);

if (fg == null){
 fg = "";
 colsPan = "4";
}else colsPan ="6";

if (request.getParameter("lastLineNo5") != null) lastLineNo5 = Integer.parseInt(request.getParameter("lastLineNo5"));


if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (defaultAction == null) defaultAction = "";
if (desc == null) desc = "";
if (modeSec == null) modeSec = "";
if (codigo == null) codigo = "0";

if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;

al2 = SQLMgr.getDataList("select codigo, nvl(to_char(fecha,'dd/mm/yyyy'),(select to_char(fecha,'dd/mm/yyyy')  from tbl_sal_rondas_det where cod_ronda = codigo and rownum = 1)) fecha, nvl(to_char(fecha,'hh12:mi:ss am'),(select to_char(fecha,'hh12:mi:ss am')  from tbl_sal_rondas_det where cod_ronda = codigo and rownum = 1)) hora, usuario_creacion from tbl_sal_rondas where pac_id = "+pacId+" and admision = "+noAdmision+" order by fecha_creacion desc");

//toDay = "24/07/2017";

System.out.println("................................ mode = "+mode);
System.out.println("................................ modeSec = "+modeSec);
System.out.println("................................ viewMode = "+viewMode);

if (request.getMethod().equalsIgnoreCase("GET")){

    int tot = CmnMgr.getCount("select count(*) from tbl_sal_rondas where pac_id = "+pacId+" and admision = "+noAdmision+" and nvl(trunc(fecha),(select trunc(fecha)  from tbl_sal_rondas_det where cod_ronda = codigo and rownum = 1)) = to_date('"+fecha+"','dd/mm/yyyy')");
    
    if (tot > 0){
        if(toDay.equals(fecha)){
            if(!viewMode) modeSec = "edit";
        } else {
            modeSec = "view";
            viewMode = true;
        }
    }

    System.out.println("....................................... tot = "+tot);
    System.out.println("....................................... modeSec = "+modeSec);

	if(change1 == null) HashDet1.clear();
	if(change2 == null) HashDet2.clear();
	if(change3 == null) HashDet3.clear();
	if(change4 == null) HashDet4.clear();
	if(change5 == null) HashDet5.clear();
    
	if (modeSec.equalsIgnoreCase("add")){
    
        DetalleRondas dron = new DetalleRondas();
        dron.setFecha(cDateTime);
        
        lastLineNo1++;
		if (lastLineNo1 < 10) key1 = "00" + lastLineNo1;
		else if (lastLineNo1 < 100) key1 = "0" + lastLineNo1;
		else key1 = "" + lastLineNo1;
		dron.setKey(""+lastLineNo1);
    
        try{
			HashDet1.put(key1, dron);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}
        
        System.out.println("........ up key1 ="+key1);
        
        // diagnosticos
        DetalleRondasDiag drondiag = new DetalleRondasDiag();
        drondiag.setFecha(cDateTime);
        
        lastLineNo2++;
		if (lastLineNo2 < 10) key2 = "00" + lastLineNo2;
		else if (lastLineNo2 < 100) key2 = "0" + lastLineNo2;
		else key2 = "" + lastLineNo2;
		drondiag.setKey(""+lastLineNo2);
    
        try{
			HashDet2.put(key2, drondiag);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}
        
        // signos
        DetalleRondasSignos dronsignos = new DetalleRondasSignos();
        dronsignos.setFecha(cDateTime);
        
        lastLineNo3++;
		if (lastLineNo3 < 10) key3 = "00" + lastLineNo3;
		else if (lastLineNo3 < 100) key3 = "0" + lastLineNo3;
		else key3 = "" + lastLineNo3;
		dronsignos.setKey(""+lastLineNo3);
    
        try{
			HashDet3.put(key3, dronsignos);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}
        
        // indicaciones
        DetalleRondasIndicaciones dronindi = new DetalleRondasIndicaciones();
        dronindi.setFecha(cDateTime);
        
        lastLineNo4++;
		if (lastLineNo4 < 10) key4 = "00" + lastLineNo4;
		else if (lastLineNo4 < 100) key4 = "0" + lastLineNo4;
		else key4 = "" + lastLineNo4;
		dronindi.setKey(""+lastLineNo4);
    
        try{
			HashDet4.put(key4, dronindi);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}
        
        if (change5 == null){
            // tratamientos
            DetalleRondasTratamientos tratamiento = new DetalleRondasTratamientos();
            tratamiento.setFecha(cDateTime);
            
            lastLineNo5++;
            if (lastLineNo5 < 10) key5 = "00" + lastLineNo5;
            else if (lastLineNo5 < 100) key5 = "0" + lastLineNo5;
            else key5 = "" + lastLineNo5;
            tratamiento.setKey(""+lastLineNo5);
        
            try{
                HashDet5.put(key5, tratamiento);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }
        }
	}
	else if (modeSec.equalsIgnoreCase("edit") || modeSec.equalsIgnoreCase("view")){
        sql = "select codigo, nvl(interconsultor,' ')interconsultor, nvl(cirugia,' ') cirugia, to_char(fecha_cirugia,'dd/mm/yyyy') fechaCirugia, nvl(dias_post_cirugia, round( trunc(fecha) - trunc(fecha_cirugia) )) diasPostCirugia, nvl(responsable,' ') responsable, nvl(to_char(fecha,'dd/mm/yyyy'), (select to_char(fecha,'dd/mm/yyyy')  from tbl_sal_rondas_det where cod_ronda = codigo and rownum = 1)) fecha from tbl_sal_rondas where pac_id = "+pacId+" and admision = "+noAdmision+" and nvl(trunc(fecha), (select trunc(fecha)  from tbl_sal_rondas_det where cod_ronda = codigo and rownum = 1)) = to_date('"+fecha+"','dd/mm/yyyy')";
        
        if (!codigo.trim().equals("0")) sql += " and codigo = "+codigo;
        
        ron = (Rondas) sbb.getSingleRowBean(ConMgr.getConnection(), sql, Rondas.class);
                
        if (ron == null) {
            ron = new Rondas();
            ron.setCodigo("0");
        }
        codigo = ron.getCodigo();
                
        if (ron.getFecha() != null && !"".equals(ron.getFecha()) && !toDay.equals(ron.getFecha())) viewMode = true;
        
        sql = "select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, otros, medico, nutricion, farmacia, terapia_fisica terapiaFisica, terapia_respiratorio terapiaRespiratorio, enfermera from tbl_sal_rondas_det where cod_ronda = "+ron.getCodigo();
        
        al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleRondas.class);
		lastLineNo1 = al.size();
        
        for (int i=0; i<al.size(); i++){
			DetalleRondas dron = (DetalleRondas) al.get(i);

			if (i < 10) key1 = "00"+i;
			else if (i < 100) key1 = "0"+i;
			else key1 = ""+i;
			dron.setKey(key1);

			try{
				HashDet1.put(key1, dron);
			}
			catch(Exception e){
				System.err.println(e.getMessage());
			}
		}
        
        if (al.size() == 0) {
            DetalleRondas dron = new DetalleRondas();
            dron.setFecha(cDateTime);
            
            lastLineNo1++;
            if (lastLineNo1 < 10) key1 = "00" + lastLineNo1;
            else if (lastLineNo1 < 100) key1 = "0" + lastLineNo1;
            else key1 = "" + lastLineNo1;
            dron.setKey(""+lastLineNo1);
        
            try{
                HashDet1.put(key1, dron);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }            
        }
        
        
        // diagnosticos
        sql = "select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, diagnostico, diag_desc diagnosticoDesc from tbl_sal_rondas_diags where cod_ronda = "+ron.getCodigo();
        
        al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleRondasDiag.class);
		lastLineNo2 = al.size();
        
        for (int i=0; i<al.size(); i++){
			DetalleRondasDiag drondiag = (DetalleRondasDiag) al.get(i);

			if (i < 10) key2 = "00"+i;
			else if (i < 100) key2 = "0"+i;
			else key2 = ""+i;
			drondiag.setKey(key2);

			try{
				HashDet2.put(key2, drondiag);
			}
			catch(Exception e){
				System.err.println(e.getMessage());
			}
		}
        
        if (al.size() == 0) {
            // diagnosticos
            DetalleRondasDiag drondiag = new DetalleRondasDiag();
            drondiag.setFecha(cDateTime);
            
            lastLineNo2++;
            if (lastLineNo2 < 10) key2 = "00" + lastLineNo2;
            else if (lastLineNo2 < 100) key2 = "0" + lastLineNo2;
            else key2 = "" + lastLineNo2;
            drondiag.setKey(""+lastLineNo2);
        
            try{
                HashDet2.put(key2, drondiag);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }
        }
        
        
        // signos vitales
        sql = "select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, pa, fc, fr, temperatura, satoxi, glicemia, dolor from tbl_sal_rondas_signos where cod_ronda = "+ron.getCodigo();
        
        al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleRondasSignos.class);
		lastLineNo3 = al.size();
        
        for (int i=0; i<al.size(); i++){
			DetalleRondasSignos dronsignos = (DetalleRondasSignos) al.get(i);

			if (i < 10) key3 = "00"+i;
			else if (i < 100) key3 = "0"+i;
			else key3 = ""+i;
			dronsignos.setKey(key3);

			try{
				HashDet3.put(key3, dronsignos);
			}
			catch(Exception e){
				System.err.println(e.getMessage());
			}
		}
        
        if (al.size() == 0) {
            // signos
            DetalleRondasSignos dronsignos = new DetalleRondasSignos();
            dronsignos.setFecha(cDateTime);
            
            lastLineNo3++;
            if (lastLineNo3 < 10) key3 = "00" + lastLineNo3;
            else if (lastLineNo3 < 100) key3 = "0" + lastLineNo3;
            else key3 = "" + lastLineNo3;
            dronsignos.setKey(""+lastLineNo3);
        
            try{
                HashDet3.put(key3, dronsignos);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }
        }
        
        // indicaciones
        sql = "select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, plan_cuidado planCuidado, ind_medica indMedica, ind_farmacia indFarmacia, ind_nutricion indNutricion, estudios_pendientes estudiosPendientes, consultas_pendientes consultasPendientes from tbl_sal_rondas_indicaciones where cod_ronda = "+ron.getCodigo();
        
        al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleRondasIndicaciones.class);
		lastLineNo4 = al.size();
        
        for (int i=0; i<al.size(); i++){
			DetalleRondasIndicaciones dronindi = (DetalleRondasIndicaciones) al.get(i);

			if (i < 10) key4 = "00"+i;
			else if (i < 100) key4 = "0"+i;
			else key4 = ""+i;
			dronindi.setKey(key4);

			try{
				HashDet4.put(key4, dronindi);
			}
			catch(Exception e){
				System.err.println(e.getMessage());
			}
		}
        
         //indicaciones
        if (al.size() == 0) {
            DetalleRondasIndicaciones indicacion = new DetalleRondasIndicaciones();
            indicacion.setFecha(cDateTime);
            
            lastLineNo4++;
            if (lastLineNo4 < 10) key4 = "00" + lastLineNo4;
            else if (lastLineNo4 < 100) key4 = "0" + lastLineNo4;
            else key4 = "" + lastLineNo4;
            indicacion.setKey(""+lastLineNo4);
        
            try{
                HashDet4.put(key4, indicacion);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }
        }
        
        // tratamientos
        sql = "select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, tratamiento from tbl_sal_rondas_tratamientos where cod_ronda = "+ron.getCodigo();
        
        al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleRondasTratamientos.class);
		lastLineNo5 = al.size();
        
        for (int i=0; i<al.size(); i++){
			DetalleRondasTratamientos tratamiento = (DetalleRondasTratamientos) al.get(i);

			if (i < 10) key5 = "00"+i;
			else if (i < 100) key5 = "0"+i;
			else key5 = ""+i;
			tratamiento.setKey(key5);

			try{
				HashDet5.put(key5, tratamiento);
			}
			catch(Exception e){
				System.err.println(e.getMessage());
			}
		}
        
        //tratamientos
        if (al.size() == 0) {
            DetalleRondasTratamientos tratamiento = new DetalleRondasTratamientos();
            tratamiento.setFecha(cDateTime);
            
            lastLineNo5++;
            if (lastLineNo5 < 10) key5 = "00" + lastLineNo5;
            else if (lastLineNo5 < 100) key5 = "0" + lastLineNo5;
            else key5 = "" + lastLineNo5;
            tratamiento.setKey(""+lastLineNo5);
        
            try{
                HashDet5.put(key5, tratamiento);
            }
            catch(Exception e){
                System.err.println(e.getMessage());
            }
        } 
	}
        
    if ( ron.getInterconsultor() == null || "".equals(ron.getInterconsultor()) || ron.getFechaCirugia() == null || "".equals(ron.getFechaCirugia()) )  {
        StringBuffer sbSql = new StringBuffer();

        sbSql.append("select join(cursor(select b.primer_nombre||decode(b.segundo_nombre,'','',' '||b.segundo_nombre)||' '||b.primer_apellido|| decode(b.segundo_apellido, null,'',' '||b.segundo_apellido)||decode(b.sexo,'F', decode(b.apellido_de_casada,'','',' '||b.apellido_de_casada)) as nombre_medico from tbl_sal_interconsultor a, tbl_adm_medico b, tbl_adm_especialidad_medica esp Where a.medico=b.codigo(+) and esp.codigo(+)=a.cod_especialidad and a.pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and a.secuencia = ");
        sbSql.append(noAdmision);
        sbSql.append(" order by a.fecha_creacion desc),', ') interconsultores, (select to_char(fecha,'dd/mm/yyyy') from tbl_sal_protocolo_operatorio z where z.pac_id = "+pacId+" and z.admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha = (select max(fecha) from tbl_sal_protocolo_operatorio where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(")) fecha_cirugia ");
        
        sbSql.append(",(select round(to_date('"+ron.getFecha()+"','dd/mm/yyyy') - fecha) from tbl_sal_protocolo_operatorio z where z.pac_id = "+pacId+" and z.admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha = (select max(fecha) from tbl_sal_protocolo_operatorio where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(")) dias_post_cirugia ");
        
        sbSql.append(",(select join(cursor(select nvl(a.observacion,a.descripcion) from tbl_cds_procedimiento a, tbl_sal_proc_protocolo b where a.codigo = b.procedimiento and b.cod_protocolo = z.codigo ),'  <>  ') from tbl_sal_protocolo_operatorio z where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append(" and fecha = (select max(fecha) from tbl_sal_protocolo_operatorio where pac_id = ");
        sbSql.append(pacId);
        sbSql.append(" and admision = ");
        sbSql.append(noAdmision);
        sbSql.append("))procedimientos ");
        
        sbSql.append(", (select diagnostico from tbl_adm_diagnostico_x_admision where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'I' and orden_diag = 1 and rownum = 1) codigo_diag, (select (select nvl(observacion, nombre) from tbl_cds_diagnostico where codigo = a.diagnostico ) from tbl_adm_diagnostico_x_admision a where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'I' and orden_diag = 1 and rownum = 1)  desc_diag ");

        sbSql.append(" from dual");
        
        cdoTmp = SQLMgr.getData(sbSql.toString());
        
        if (cdoTmp == null)  {
            cdoTmp = new CommonDataObject();
        }
        ron.setInterconsultor(cdoTmp.getColValue("interconsultores"," "));
        ron.setCirugia(cdoTmp.getColValue("procedimientos"," "));
        ron.setFechaCirugia(cdoTmp.getColValue("fecha_cirugia",ron.getFechaCirugia()));
        ron.setDiasPostCirugia(cdoTmp.getColValue("dias_post_cirugia",ron.getDiasPostCirugia()));
    }
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
document.title = 'Notas Diarias de Enfermería - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){
    loaded = true;
    checkViewMode();
}

function setAtencion(id, f,h){
    window.location = "../expediente3.0/exp_ronda_multi_disciplinario.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&mode=<%=mode%>&modeSec=edit&fg=<%=fg%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&defaultAction=<%=defaultAction%>&fecha="+f+"&hora="+h+"&codigo="+id;
}
function addAtencion(){
    window.location ="../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion=seccion=<%=seccion%>&mode=<%=mode%>&modeSec=add&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&defaultAction=<%=defaultAction%>";
}
function verHistorial() {$("#hist_container").toggle();}

function medicoList(i){
	abrir_ventana1('../common/search_medico.jsp?fp=rondas&index='+i);
}

function doSubmit(form, action) {
   parent.setPatientInfo(form,'iDetalle');
   $("#baction").val(action);
   
   var fecha = $("#fecha0").val();
   var tot = getDBData('<%=request.getContextPath()%>','count(*)','tbl_adm_admision',"pac_id=<%=pacId%> and secuencia=<%=noAdmision%> and fecha_ingreso <= trunc(to_date('"+fecha+"','dd/mm/yyyy hh12:mi:ss am')) and trunc(sysdate) >= trunc(to_date('"+fecha+"','dd/mm/yyyy hh12:mi:ss am'))",'') || '0';
   
   if (!fecha || !parseInt(tot)) {
     parent.CBMSG.error('La fecha no es válida!');
   } else {
     $("#"+form).submit();
   }   
}


function addNew1(form,objValue, opt){
    if (opt == 1)$("#baction1").val(objValue);
    else if (opt == 2)$("#baction2").val(objValue);
    else if (opt == 3)$("#baction3").val(objValue);
    else if (opt == 4)$("#baction4").val(objValue);
    else if (opt == 5)$("#baction5").val(objValue);
    $("#"+form.name).submit();
}

function empleadoList(opt, i){
    if (opt == 1) abrir_ventana1('../common/search_empleado.jsp?fp=rondas&fg=enfermera&index='+i);
    else if (opt == 2) abrir_ventana1('../common/search_empleado.jsp?fp=rondas&fg=nutricion&index='+i);
    else if (opt == 3) abrir_ventana1('../common/search_empleado.jsp?fp=rondas&fg=farmacia&index='+i);
    else if (opt == 4) abrir_ventana1('../common/search_empleado.jsp?fp=rondas&fg=terapista_fisica&index='+i);
    else if (opt == 5) abrir_ventana1('../common/search_empleado.jsp?fp=rondas&fg=terapista_respiratorio&index='+i);
}
function diagList(i){
    abrir_ventana1('../common/search_diagnostico.jsp?fp=rondas&index='+i);
}

function imprimirNotas() {
    abrir_ventana1('../expediente3.0/print_ronda_multi_disciplinario.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&seccion=<%=seccion%>&code=<%=codigo%>&fecha_creacion=<%=fecha%>');
}

$(function(){
    $("#btn_tratamientos").click(function(){
        abrir_ventana1('../expediente/exp_list_tratamiento.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
    });
});

function setNextDate(){
   var fecha = $(".default_fecha").val();
   $(".next_fecha").val(fecha);
}

function setTotPostCirDays() {
    var fechaToma = $("#fecha0").val();
    var fechaCir = $("#fecha_cirugia").val();
    if (fechaCir) {
        var tot = getDBData('<%=request.getContextPath()%>',"round(trunc( to_date('"+fechaToma+"','dd/mm/yyyy hh12:mi:ss am') )-to_date('"+fechaCir+"','dd/mm/yyyy'))",'dual','','');
        $("#dias_post_cirugia").val(tot);
    }
}

function imprimirHistoria() {
    abrir_ventana1('../expediente3.0/print_ronda_multi_disciplinario_historial.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&desc=<%=desc%>&seccion=<%=seccion%>');
}
</script>
</head>
<body class="body-form">
  <div class="row">
    <div class="table-responsive" data-pattern="priority-columns">

       <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("baction1","")%>
        <%=fb.hidden("baction2","")%>
        <%=fb.hidden("baction3","")%>
        <%=fb.hidden("baction4","")%>
        <%=fb.hidden("baction5","")%>
        <%=fb.hidden("baction","")%>
        <%=fb.hidden("mode",mode)%>
        <%=fb.hidden("modeSec",modeSec)%>
        <%=fb.hidden("seccion",seccion)%>
        <%=fb.hidden("pacId",pacId)%>
        <%=fb.hidden("noAdmision",noAdmision)%>
        <%=fb.hidden("dob","")%>
        <%=fb.hidden("codPac","")%>
        <%=fb.hidden("errCode","")%>
        <%=fb.hidden("errMsg","")%>
        <%=fb.hidden("fg",""+fg)%>
        <%=fb.hidden("defaultAction",defaultAction)%>
        <%=fb.hidden("desc",desc)%>
        <%=fb.hidden("codigo",codigo)%>
        <%=fb.hidden("fecha",fecha)%>
        <%=fb.hidden("lastLineNo1",""+lastLineNo1)%>
        <%=fb.hidden("lastLineNo2",""+lastLineNo2)%>
        <%=fb.hidden("lastLineNo3",""+lastLineNo3)%>
        <%=fb.hidden("lastLineNo4",""+lastLineNo4)%>
        <%=fb.hidden("lastLineNo5",""+lastLineNo5)%>
        <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
        <%=fb.hidden("size1",""+HashDet1.size())%>
        <%=fb.hidden("size2",""+HashDet2.size())%>
        <%=fb.hidden("size3",""+HashDet3.size())%>
        <%=fb.hidden("size4",""+HashDet4.size())%>
        <%=fb.hidden("size5",""+HashDet5.size())%>
       <div class="headerform"> 
       <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td class="controls form-inline">
                    
                    <%if(!mode.trim().equals("view") && ron.getFecha() != null && !"".equals(ron.getFecha()) && !toDay.equals(ron.getFecha())){%>
                        <button type="button" class="btn btn-inverse btn-sm" onclick="javascript:addAtencion()">
                            <i class="fa fa-plus fa-lg"></i> <cellbytelabel>Agregar</cellbytelabel>
                        </button>
                    <%}%>
                    
                    <%if (!codigo.equals("0")) {%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimirNotas()"><i class="fa fa-print fa-printico"></i> <b>Imprimir</b>
                    </button>
                    <%}%>
                    
                    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimirHistoria()"><i class="fa fa-print fa-printico"></i> <b>Imprimir Historial</b>
                    </button>
                    
                    <button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
                       <i class="fa fa-eye fa-printico"></i> <b>Historial</b>
                    </button>
                    
                 </td>
            </tr>
        </table>
        </div>
        
        <div class="table-wrapper" id="hist_container" style="display:none">
         <table class="table table-small-font table-bordered table-striped table-hover">
         <tr class="bg-headtabla2 pull-center">
			<td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
            <td><cellbytelabel id="2">Fecha</cellbytelabel></td>
            <td><cellbytelabel id="2">Hora</cellbytelabel></td>
            <td><cellbytelabel id="4">Usuario</cellbytelabel></td>
         </tr>
         
         <% for (int a = 1; a<=al2.size(); a++){
            cdo = (CommonDataObject)al2.get(a-1);
         %>
             <tr onClick="javascript:setAtencion('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha")%>','<%=cdo.getColValue("hora")%>')" class="pointer">
                <td><%=cdo.getColValue("codigo")%></td>
                <td><%=cdo.getColValue("fecha")%></td>
                <td><%=cdo.getColValue("hora")%></td>
                <td><%=cdo.getColValue("usuario_creacion")%></td>
             </tr>
		<%}%>
       </table>
        </div>

        <table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">
    
          <tr class="bg-headtabla2">
              <td>
               <span class="pull-left">RONDA MULTIDISCIPLINARIAS</span>
               <span class="pull-right">
                  <%//=fb.submit("agregar1","+",false,viewMode,null,null,"onClick=\"addNew1(this.form, this.value,1)\"","Agregar Nota")%>
               </span>
              </td>
          </tr>
          
        <%
        String nextFecha = "";
        al = CmnMgr.reverseRecords(HashDet1);
        for (int i = 0; i<HashDet1.size(); i++){
            key1 = al.get(i).toString();
            DetalleRondas dron = (DetalleRondas) HashDet1.get(key1);
            System.out.println("........... key1 = "+key1);
            
            nextFecha = dron.getFecha();
        %>
         <%=fb.hidden("key_1_"+i,key1)%>
		 <%=fb.hidden("remove_1_"+i,"")%>
        
           <tr class="header_1_<%=i%>">
              <td>
                    <table cellspacing="0" class="table-striped table-hover" width="100%">
                        <tr>
                            <td class="controls form-inline">
                            Fecha:
                                <%if(i == 0){%>
                                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                                    <jsp:param name="noOfDateTBox" value="1"/>
                                    <jsp:param name="clearOption" value="true"/>
                                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                                    <jsp:param name="nameOfTBox1" value="<%="fecha"+i%>"/>
                                    <jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
                                    <jsp:param name="valueOfTBox1" value="<%=dron.getFecha()%>"/>
                                    <jsp:param name="jsEvent" value="setNextDate()"/>
                                    <jsp:param name="fieldClass" value="default_fecha"/>
                                </jsp:include>
                                <%} else {%>
                                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                                    <jsp:param name="noOfDateTBox" value="1"/>
                                    <jsp:param name="clearOption" value="true"/>
                                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                                    <jsp:param name="nameOfTBox1" value="<%="fecha"+i%>"/>
                                    <jsp:param name="readonly" value="<%=viewMode?"y":"n"%>"/>
                                    <jsp:param name="valueOfTBox1" value="<%=dron.getFecha()%>"/>
                                </jsp:include>
                                <%}%>
                            Médico Hospitalista:
                                <%=fb.textBox("medico"+i,dron.getMedico(),false,false,viewMode,30,"form-control input-sm","display:inline;",null)%>
                                <%=fb.button("btn_medico"+i,"...",true,viewMode,null,null,"onClick=\"javascript:medicoList("+i+")\"","seleccionar medico")%>
                            Enfermería:
                                <%=fb.textBox("enfermera"+i,dron.getEnfermera(),false,false,viewMode,30,"form-control input-sm","display:inline;",null)%>
                                <%=fb.button("btn_enfermera"+i,"...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(1,"+i+")\"","seleccionar enfermera")%>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class="controls form-inline">
                            Nutrición:
                                <%=fb.textBox("nutricion"+i,dron.getNutricion(),false,false,viewMode,30,"form-control input-sm","display:inline;",null)%>
                                <%=fb.button("btn_nutricion"+i,"...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(2,"+i+")\"","seleccionar nutricion")%>
                                Farmacia:
                                <%=fb.textBox("farmacia"+i,dron.getFarmacia(),false,false,viewMode,30,"form-control input-sm","display:inline;",null)%>
                                <%=fb.button("btn_farmacia"+i,"...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(3,"+i+")\"","seleccionar farmacia")%>
                                Terapia física:
                                <%=fb.textBox("terapia_fisica"+i,dron.getTerapiaFisica(),false,false,viewMode,30,"form-control input-sm","display:inline;",null)%>
                                <%=fb.button("btn_terapia_fisica"+i,"...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(4,"+i+")\"","seleccionar terapia física")%>
                            </td>
                        </tr>
                        
                        <tr>
                            <td class="controls form-inline">
                                Terapia respiratoria:
                                <%=fb.textBox("terapia_respiratorio"+i,dron.getTerapiaRespiratorio(),false,false,viewMode,30,"form-control input-sm","display:inline;",null)%>
                                <%=fb.button("btn_terapia_respiratorio"+i,"...",true,viewMode,null,null,"onClick=\"javascript:empleadoList(5,"+i+")\"","seleccionar terapia respiratoria")%>
                                Otros:
                                <%=fb.textBox("otros_1_"+i,dron.getOtros(),false,false,viewMode,60,"form-control input-sm","display:inline;",null)%>
                            </td>
                        </tr>
                        
                    </table>
              </td>              
           </tr>           
        
        <%}%>
        
        <tr>
            <td class="controls form-inline">
                Interconsultor:
                <%=fb.textBox("interconsultor",ron.getInterconsultor(),false,false,viewMode,120,"form-control input-sm","display:inline;",null)%>
            </td>
        </tr>
        
        <tr class="bg-headtabla2">
          <td>
           <span class="pull-left">DIAGNOSTICOS</span>
           <span class="pull-right">
              <%//=fb.submit("agregar2","+",false,viewMode,null,null,"onClick=\"addNew1(this.form, this.value, 2)\"","Agregar Diagnosticos")%>
           </span>
          </td>
       </tr>
      
      <%
        al = CmnMgr.reverseRecords(HashDet2);
        for (int i = 0; i<HashDet2.size(); i++){
            key2 = al.get(i).toString();
            DetalleRondasDiag drondiag = (DetalleRondasDiag) HashDet2.get(key2);
            
            drondiag.setFecha(nextFecha);
            if (!cdoTmp.getColValue("codigo_diag"," ").trim().equals("")) drondiag.setDiagnostico(cdoTmp.getColValue("codigo_diag"," "));
            if (!cdoTmp.getColValue("desc_diag"," ").trim().equals("")) drondiag.setDiagnosticoDesc(cdoTmp.getColValue("desc_diag"," "));
        %>
         <%=fb.hidden("key_2_"+i,key2)%>
		 <%=fb.hidden("remove_2_"+i,"")%>
        
           <tr>
              <td>
                    <table cellspacing="0" class="table-striped table-hover">
                        <tr>
                            <td class="controls form-inline">
                            Fecha:
                                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                                    <jsp:param name="noOfDateTBox" value="1"/>
                                    <jsp:param name="clearOption" value="true"/>
                                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                                    <jsp:param name="nameOfTBox1" value="<%="fecha_diag"+i%>"/>
                                    <jsp:param name="readonly" value="y"/>
                                    <jsp:param name="fieldClass" value="next_fecha"/>
                                    <jsp:param name="valueOfTBox1" value="<%=drondiag.getFecha()%>"/>
                                </jsp:include>
                                Diagn&oacute;stico:
                                <%=fb.textBox("diagnostico"+i,drondiag.getDiagnostico(),false,false,true,10,"form-control input-sm","display:inline;",null)%>
                                <%=fb.textBox("diagnostico_desc"+i,drondiag.getDiagnosticoDesc(),false,false,true,50,"form-control input-sm","display:inline;",null)%>
                                <%=fb.button("btn_diag"+i,"...",true,viewMode,null,null,"onClick=\"javascript:diagList("+i+")\"","seleccionar terapia respiratoria")%>
                                
                            </td>    
                        </tr>    
                    </table>    
            </td>
        </tr>
        <%}%>
        
        <tr>
            <td class="controls form-inline">
                Cirugía:
                <%=fb.textBox("cirugia",ron.getCirugia(),false,false,viewMode||(ron.getCirugia()!=null&&!ron.getCirugia().trim().equals("")),120,"form-control input-sm","display:inline;",null)%>
            </td>
        </tr>
        
        <tr>
            <td class="controls form-inline">
                Fecha de la Cirugía:
                <%//=fb.textBox("fecha_cirugia",,false,false,true,15,"form-control input-sm","display:inline;",null)%>

                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                    <jsp:param name="noOfDateTBox" value="1"/>
                    <jsp:param name="clearOption" value="true"/>
                    <jsp:param name="format" value="dd/mm/yyyy"/>
                    <jsp:param name="nameOfTBox1" value="fecha_cirugia"/>
                    <jsp:param name="readonly" value="<%=viewMode||(ron.getFechaCirugia()!=null&&!ron.getFechaCirugia().trim().equals(""))?"y":"n"%>"/>
                    <jsp:param name="valueOfTBox1" value="<%=ron.getFechaCirugia()%>"/>
                    <jsp:param name="jsEvent" value="setTotPostCirDays()"/>
                </jsp:include>
                
                
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Dias Post cirugía:
                <%=fb.textBox("dias_post_cirugia",ron.getDiasPostCirugia(),false,false,true,15,"form-control input-sm","display:inline;",null)%>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <!--
                <button type="button" class="btn btn-inverse btn-sm" id="btn_tratamientos">
                    <i class="fa fa-eye fa-lg"></i>
                    <b>Tratamientos actuales</b>
                </button>
                -->
            </td>
        </tr>
        
        <tr class="bg-headtabla2">
          <td>
           <span class="pull-left">TRATAMIENTOS</span>
           <span class="pull-right">
              <%=fb.submit("agregar5","+",false,viewMode,null,null,"onClick=\"addNew1(this.form, this.value, 5)\"","Agregar Tratamientos")%>
           </span>
          </td>
       </tr>
       
       
      <%
        al = CmnMgr.reverseRecords(HashDet5);
        for (int i = 0; i<HashDet5.size(); i++){
            key5 = al.get(i).toString();
            DetalleRondasTratamientos tratamiento = (DetalleRondasTratamientos) HashDet5.get(key5);
            tratamiento.setFecha(nextFecha);
        %>
         <%=fb.hidden("key_5_"+i,key5)%>
		 <%=fb.hidden("remove_5_"+i,"")%>
        
           <tr>
              <td>
                    <table cellspacing="0" class="table-striped table-hover" width="100%">
                        <tr>
                            <td class="controls form-inline">
                            Fecha:
                                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                                    <jsp:param name="noOfDateTBox" value="1"/>
                                    <jsp:param name="clearOption" value="true"/>
                                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                                    <jsp:param name="nameOfTBox1" value="<%="fecha_tratamiento"+i%>"/>
                                    <jsp:param name="readonly" value="y"/>
                                    <jsp:param name="valueOfTBox1" value="<%=tratamiento.getFecha()%>"/>
                                    <jsp:param name="fieldClass" value="next_fecha"/>
                                </jsp:include>
                            </td>
                            <td>
                                <%=fb.textarea("tratamiento"+i,tratamiento.getTratamiento(),false,false,viewMode,0,1,2000,"form-control input-sm","width:100%",null)%>
                            </td>
                        </tr>    
                    </table>    
            </td>
        </tr>
        <%}%>

        <tr class="bg-headtabla2">
          <td>
           <span class="pull-left">SIGNOS VITALES</span>
           <span class="pull-right">
              <%//=fb.submit("agregar3","+",false,viewMode,null,null,"onClick=\"addNew1(this.form, this.value, 3)\"","Agregar Signos vitales")%>
           </span>
          </td>
       </tr>
      
      <%
        al = CmnMgr.reverseRecords(HashDet3);
        for (int i = 0; i<HashDet3.size(); i++){
            key3 = al.get(i).toString();
            DetalleRondasSignos dronsignos = (DetalleRondasSignos) HashDet3.get(key3);
            dronsignos.setFecha(nextFecha);
        %>
         <%=fb.hidden("key_3_"+i,key3)%>
		 <%=fb.hidden("remove_3_"+i,"")%>
        
           <tr>
              <td>
                    <table cellspacing="0" class="table-striped table-hover" width="100%">
                        <tr>
                            <td class="controls form-inline">
                            Fecha:
                                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                                    <jsp:param name="noOfDateTBox" value="1"/>
                                    <jsp:param name="clearOption" value="true"/>
                                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                                    <jsp:param name="nameOfTBox1" value="<%="fecha_signos"+i%>"/>
                                    <jsp:param name="readonly" value="y"/>
                                    <jsp:param name="valueOfTBox1" value="<%=dronsignos.getFecha()%>"/>
                                    <jsp:param name="fieldClass" value="next_fecha"/>
                                </jsp:include>&nbsp;&nbsp;
                                PA:
                                <%=fb.textBox("pa"+i,dronsignos.getPA(),false,false,viewMode,5,"form-control input-sm","display:inline;",null)%>&nbsp;&nbsp;
                                FC:
                                <%=fb.textBox("fc"+i,dronsignos.getFC(),false,false,viewMode,5,"form-control input-sm","display:inline;",null)%>&nbsp;&nbsp;
                                FR:
                                <%=fb.textBox("fr"+i,dronsignos.getFR(),false,false,viewMode,5,"form-control input-sm","display:inline;",null)%>&nbsp;&nbsp;
                                T:
                                <%=fb.textBox("temperatura"+i,dronsignos.getTemperatura(),false,false,viewMode,5,"form-control input-sm","display:inline;",null)%>&nbsp;&nbsp;&nbsp;
                                SatO2:
                                <%=fb.textBox("satoxi"+i,dronsignos.getSatoxi(),false,false,viewMode,5,"form-control input-sm","display:inline;",null)%>&nbsp;&nbsp;&nbsp;&nbsp;
                                Glicemia Capilar:
                                <%=fb.textBox("glicemia"+i,dronsignos.getGlicemia(),false,false,viewMode,5,"form-control input-sm","display:inline;",null)%>&nbsp;&nbsp;&nbsp;&nbsp;
                                Dolor:
                                <%=fb.textBox("dolor"+i,dronsignos.getDolor(),false,false,viewMode,5,"form-control input-sm","display:inline;",null)%>
                            </td>    
                        </tr>    
                    </table>    
            </td>
        </tr>
        <%}%>
        
        
        <tr class="bg-headtabla2">
          <td>
           <span class="pull-left">INDICACIONES</span>
           <span class="pull-right">
              <%//=fb.submit("agregar4","+",false,viewMode,null,null,"onClick=\"addNew1(this.form, this.value, 4)\"","Agregar Indicaciones")%>
           </span>
          </td>
       </tr>
       
       
      <%
        al = CmnMgr.reverseRecords(HashDet4);
        for (int i = 0; i<HashDet4.size(); i++){
            key4 = al.get(i).toString();
            DetalleRondasIndicaciones indicacion = (DetalleRondasIndicaciones) HashDet4.get(key4);
            indicacion.setFecha(nextFecha);
        %>
         <%=fb.hidden("key_4_"+i,key4)%>
		 <%=fb.hidden("remove_4_"+i,"")%>
        
           <tr>
              <td>
                    <table cellspacing="0" class="table-striped table-hover" width="100%">
                        <tr>
                            <td class="controls form-inline">
                            Fecha:
                                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                                    <jsp:param name="noOfDateTBox" value="1"/>
                                    <jsp:param name="clearOption" value="true"/>
                                    <jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
                                    <jsp:param name="nameOfTBox1" value="<%="fecha_indicaciones"+i%>"/>
                                    <jsp:param name="readonly" value="y"/>
                                    <jsp:param name="valueOfTBox1" value="<%=indicacion.getFecha()%>"/>
                                    <jsp:param name="fieldClass" value="next_fecha"/>
                                </jsp:include>
                            </td>
                            <td class="controls form-inline">
                                Plan Cuidado:&nbsp;<%=fb.textBox("plan_cuidado"+i,indicacion.getPlanCuidado(),false,false,viewMode,60,"form-control input-sm","display:inline;",null)%>
                            </td>
                        </tr>
                        <tr>
                            <td class="controls form-inline">
                                Indicaciones médicas especiales:&nbsp;<%=fb.textBox("ind_medica"+i,indicacion.getIndMedica(),false,false,viewMode,30,"form-control input-sm","display:inline;",null)%>
                            </td>
                            <td class="controls form-inline">
                                Farmacia:&nbsp;<%=fb.textBox("ind_medica"+i,indicacion.getIndFarmacia(),false,false,viewMode,60,"form-control input-sm","display:inline;",null)%>
                            </td>
                        </tr> 
                        <tr>
                            <td class="controls form-inline">
                                Nutrición:&nbsp;<%=fb.textBox("ind_nutricion"+i,indicacion.getIndNutricion(),false,false,viewMode,60,"form-control input-sm","display:inline;",null)%>
                            </td>
                            <td class="controls form-inline">
                                Estudios Pendientes:&nbsp;<%=fb.textBox("estudios_pendientes"+i,indicacion.getEstudiosPendientes(),false,false,viewMode,60,"form-control input-sm","display:inline;",null)%>
                            </td>
                        </tr> 
                        <tr>
                            <td class="controls form-inline" colspan="3">
                                Consultas Pendientes:&nbsp;<%=fb.textBox("consultas_pendientes"+i,indicacion.getConsultasPendientes(),false,false,viewMode,120,"form-control input-sm","display:inline;",null)%>
                            </td>
                        </tr>    
                    </table>    
            </td>
        </tr>
        <%}%>
        
        <tr>
            <td class="controls form-inline">
                Personal Responsable:
                <%=fb.textBox("responsable",ron.getResponsable(),false,false,viewMode,120,"form-control input-sm","display:inline;",null)%>
            </td>
        </tr>
        
		
        
            <tr>
                <td align="right">
                    <%=fb.hidden("saveOption","O")%>
                    <button type="button" class="btn btn-inverse btn-sm" id="save" name="save"
                    onclick="doSubmit('<%=fb.getFormName()%>', 'Guardar')"<%=viewMode?" disabled":""%>
                    >
                        <i class="fa fa-floppy-o fa-lg"></i>
                        <b>Guardar</b>
                    </button>
                </td>
            </tr>  
    </table> 
    
    
<%=fb.formEnd(true)%>
        
    </div>
  </div>
</body>
</html>
<%
}//GET
else
{
    String saveOption = request.getParameter("saveOption");
    String baction = request.getParameter("baction");
    String baction1 = request.getParameter("baction1");
    String baction2 = request.getParameter("baction2");
    String baction3 = request.getParameter("baction3");
    String baction4 = request.getParameter("baction4");
    String baction5 = request.getParameter("baction5");
    int size1 = Integer.parseInt(request.getParameter("size1"));
    int size2 = Integer.parseInt(request.getParameter("size2"));
    int size3 = Integer.parseInt(request.getParameter("size3"));
    int size4 = Integer.parseInt(request.getParameter("size4"));
    int size5 = Integer.parseInt(request.getParameter("size5"));
    if (baction == null) baction = "";
        
    lastLineNo1 = Integer.parseInt(request.getParameter("lastLineNo1"));
    lastLineNo2 = Integer.parseInt(request.getParameter("lastLineNo2"));
    lastLineNo3 = Integer.parseInt(request.getParameter("lastLineNo3"));
    lastLineNo4 = Integer.parseInt(request.getParameter("lastLineNo4"));
    lastLineNo5 = Integer.parseInt(request.getParameter("lastLineNo5"));
    
    ron = new Rondas();
    ron.setPacId(pacId);
	ron.setAdmision(noAdmision);
    
    ron.setInterconsultor(request.getParameter("interconsultor"));
    ron.setCirugia(request.getParameter("cirugia"));
    ron.setFechaCirugia(request.getParameter("fecha_cirugia"));
    ron.setDiasPostCirugia(request.getParameter("dias_post_cirugia"));
    ron.setResponsable(request.getParameter("responsable"));
    
    if (modeSec.equalsIgnoreCase("edit")) {
        ron.setCodigo(request.getParameter("codigo"));
        ron.setFechaCreacion(cDateTime);
        ron.setFechaModificacion(cDateTime);
    } else {
        ron.setFechaCreacion(cDateTime);
        ron.setFechaModificacion(cDateTime);
        ron.setUsuarioCreacion((String) session.getAttribute("_userName"));
        ron.setUsuarioModificacion((String) session.getAttribute("_userName"));
        ron.setFecha(request.getParameter("fecha0"));
    }
        
    String ItemRemoved = "";
	for (int i=0; i<size1; i++){
        DetalleRondas dron = new DetalleRondas();
        
        dron.setFecha(request.getParameter("fecha"+i));
        dron.setMedico(request.getParameter("medico"+i));
        dron.setEnfermera(request.getParameter("enfermera"+i));
        dron.setNutricion(request.getParameter("nutricion"+i));
        dron.setFarmacia(request.getParameter("farmacia"+i));
        dron.setTerapiaFisica(request.getParameter("terapia_fisica"+i));
        dron.setTerapiaRespiratorio(request.getParameter("terapia_respiratorio"+i));
        dron.setOtros(request.getParameter("otros_1_"+i));
        
        dron.setKey(request.getParameter("key_1_"+i));
		key1 = request.getParameter("key_1_"+i);
                
        if (request.getParameter("remove_1_"+i) != null && !request.getParameter("remove_1_"+i).equals("")){
			ItemRemoved = key1;
		}
        try {
            HashDet1.put(key1, dron);
            ron.addDetalleRondas(dron);
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }
    
    if (!ItemRemoved.equals("")){
        response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo1="+lastLineNo1+"&change1=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
	}
    if (baction1 != null && baction1.trim().equalsIgnoreCase("+")){
        DetalleRondas dron = new DetalleRondas();
        dron.setFecha(cDateTime);
        
        
        lastLineNo1++;
		if (lastLineNo1 < 10) key1 = "00" + lastLineNo1;
		else if (lastLineNo1 < 100) key1 = "0" + lastLineNo1;
		else key1 = "" + lastLineNo1;
		dron.setKey(""+lastLineNo1);

        System.out.println("..................... adding ... = "+lastLineNo1);

		try{
			HashDet1.put(key1, dron);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}

		response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo1="+lastLineNo1+"&change1=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
    }
    
    // diagnosticos
    ItemRemoved = "";
	for (int i=0; i<size2; i++){
        DetalleRondasDiag drondiag = new DetalleRondasDiag();
        
        drondiag.setFecha(request.getParameter("fecha_diag"+i));
        drondiag.setDiagnostico(request.getParameter("diagnostico"+i));
        drondiag.setDiagnosticoDesc(request.getParameter("diagnostico_desc"+i));
        
        drondiag.setKey(request.getParameter("key_2_"+i));
		key2 = request.getParameter("key_2_"+i);
        
        
        if (request.getParameter("remove_2_"+i) != null && !request.getParameter("remove_2_"+i).equals("")){
			ItemRemoved = key2;
		}
        try {
            HashDet2.put(key2, drondiag);
            ron.addDiags(drondiag);
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }
    
    if (!ItemRemoved.equals("")){
        response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo2="+lastLineNo2+"&change2=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
	}
    if (baction2 != null && baction2.trim().equalsIgnoreCase("+")){
        DetalleRondasDiag drondiag = new DetalleRondasDiag();
        drondiag.setFecha(cDateTime);
        
        lastLineNo2++;
		if (lastLineNo2 < 10) key2 = "00" + lastLineNo2;
		else if (lastLineNo2 < 100) key2 = "0" + lastLineNo2;
		else key2 = "" + lastLineNo2;
		drondiag.setKey(""+lastLineNo2);


		try{
			HashDet2.put(key2, drondiag);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}

        System.out.println("..................... adding2 ... = "+lastLineNo2);
        System.out.println("..................... lastLineNo2 ... = "+lastLineNo2);
        
		response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo2="+lastLineNo2+"&change2=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
    }
    
    
    // signos
    ItemRemoved = "";
	for (int i=0; i<size3; i++){
        DetalleRondasSignos dronsignos = new DetalleRondasSignos();
        
        dronsignos.setFecha(request.getParameter("fecha_signos"+i));
        dronsignos.setPA(request.getParameter("pa"+i));
        dronsignos.setFR(request.getParameter("fr"+i));
        dronsignos.setFC(request.getParameter("fc"+i));
        dronsignos.setTemperatura(request.getParameter("temperatura"+i));
        dronsignos.setSatoxi(request.getParameter("satoxi"+i));
        dronsignos.setGlicemia(request.getParameter("glicemia"+i));
        dronsignos.setDolor(request.getParameter("dolor"+i));
        
        dronsignos.setKey(request.getParameter("key_3_"+i));
		key3 = request.getParameter("key_3_"+i);
        
        
        if (request.getParameter("remove_3_"+i) != null && !request.getParameter("remove_3_"+i).equals("")){
			ItemRemoved = key3;
		}
        try {
            HashDet3.put(key3, dronsignos);
            ron.addSignos(dronsignos);
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }
    
    if (!ItemRemoved.equals("")){
        response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo3="+lastLineNo3+"&change3=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
	}
    if (baction3 != null && baction3.trim().equalsIgnoreCase("+")){
        DetalleRondasSignos dronsignos = new DetalleRondasSignos();
        dronsignos.setFecha(cDateTime);
        
        lastLineNo3++;
		if (lastLineNo3 < 10) key3 = "00" + lastLineNo3;
		else if (lastLineNo3 < 100) key3 = "0" + lastLineNo3;
		else key3 = "" + lastLineNo3;
		dronsignos.setKey(""+lastLineNo3);


		try{
			HashDet3.put(key3, dronsignos);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}

        System.out.println("..................... adding3 ... = "+lastLineNo3);
        
		response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo3="+lastLineNo3+"&change3=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
    }
    
    // tratamientos
    ItemRemoved = "";
	for (int i=0; i<size5; i++){
        DetalleRondasTratamientos tratamiento = new DetalleRondasTratamientos();
        
        tratamiento.setFecha(request.getParameter("fecha_tratamiento"+i));
        tratamiento.setTratamiento(request.getParameter("tratamiento"+i));
        
        tratamiento.setKey(request.getParameter("key_5_"+i));
		key5 = request.getParameter("key_5_"+i);
        
        
        if (request.getParameter("remove_5_"+i) != null && !request.getParameter("remove_5_"+i).equals("")){
			ItemRemoved = key5;
		}
        try {
            HashDet5.put(key5, tratamiento);
            ron.addTratamientos(tratamiento);
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }
    
    if (!ItemRemoved.equals("")){
        response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo5="+lastLineNo5+"&change5=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
	}
    if (baction5 != null && baction5.trim().equalsIgnoreCase("+")){
        DetalleRondasTratamientos tratamiento = new DetalleRondasTratamientos();
        tratamiento.setFecha(cDateTime);
        
        lastLineNo5++;
		if (lastLineNo5 < 10) key5 = "00" + lastLineNo5;
		else if (lastLineNo5 < 100) key5 = "0" + lastLineNo5;
		else key5 = "" + lastLineNo5;
		tratamiento.setKey(""+lastLineNo5);

		try{
			HashDet5.put(key5, tratamiento);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}

        System.out.println("..................... adding5 ... = "+lastLineNo5);
        
		response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo5="+lastLineNo5+"&change5=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
    }
    
    // indicaciones
    ItemRemoved = "";
	for (int i=0; i<size4; i++){
        DetalleRondasIndicaciones indicacion = new DetalleRondasIndicaciones();
        
        indicacion.setFecha(request.getParameter("fecha_indicaciones"+i));
        indicacion.setPlanCuidado(request.getParameter("plan_cuidado"+i));
        indicacion.setIndFarmacia(request.getParameter("ind_farmacia"+i));
        indicacion.setIndMedica(request.getParameter("ind_medica"+i));
        indicacion.setIndNutricion(request.getParameter("ind_nutricion"+i));
        indicacion.setConsultasPendientes(request.getParameter("consultas_pendientes"+i));
        indicacion.setEstudiosPendientes(request.getParameter("estudios_pendientes"+i));
        
        indicacion.setKey(request.getParameter("key_4_"+i));
		key4 = request.getParameter("key_4_"+i);
        
        
        if (request.getParameter("remove_4_"+i) != null && !request.getParameter("remove_4_"+i).equals("")){
			ItemRemoved = key4;
		}
        try {
            HashDet4.put(key4, indicacion);
            ron.addIndicaciones(indicacion);
        }
        catch(Exception e){
            System.err.println(e.getMessage());
        }
    }
    
    if (!ItemRemoved.equals("")){
        response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo4="+lastLineNo4+"&change4=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
	}
    if (baction4 != null && baction4.trim().equalsIgnoreCase("+")){
        DetalleRondasIndicaciones indicacion = new DetalleRondasIndicaciones();
        indicacion.setFecha(cDateTime);
        
        lastLineNo4++;
		if (lastLineNo4 < 10) key4 = "00" + lastLineNo4;
		else if (lastLineNo4 < 100) key4 = "0" + lastLineNo4;
		else key4 = "" + lastLineNo4;
		indicacion.setKey(""+lastLineNo4);


		try{
			HashDet4.put(key4, indicacion);
		}
		catch(Exception e){
			System.err.println(e.getMessage());
		}

        System.out.println("..................... adding4 ... = "+lastLineNo4);
        
		response.sendRedirect("../expediente3.0/exp_ronda_multi_disciplinario.jsp?seccion="+seccion+"&mode="+mode+"&modeSec="+modeSec+"&pacId="+pacId+"&noAdmision="+noAdmision+"&fg="+fg+"&lastLineNo4="+lastLineNo4+"&change4=1&defaultAction="+defaultAction+"&codigo="+codigo);
		return;
    }
     
    if (baction != null && baction.trim().equalsIgnoreCase("Guardar")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (modeSec.equalsIgnoreCase("add")) RonMgr.add(ron);
		else if (modeSec.equalsIgnoreCase("edit")) RonMgr.update(ron);
		ConMgr.clearAppCtx(null);
	}
    
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (RonMgr.getErrCode().equals("1"))
{
%>
	alert('<%=RonMgr.getErrMsg()%>');
<%
	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.parent.doRedirect(0);
<%
	}
} else throw new Exception(RonMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo1=<%=lastLineNo1%>&fg=<%=fg%>&defaultAction=<%=defaultAction%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&lastLineNo1=<%=lastLineNo1%>&lastLineNo2=<%=lastLineNo2%>&lastLineNo3=<%=lastLineNo3%>&lastLineNo4=<%=lastLineNo4%>&lastLineNo5=<%=lastLineNo5%>&fecha=<%=request.getParameter("fecha")%>&hora=<%=request.getParameter("hora")%>&desc=<%=desc%>&defaultAction=<%=defaultAction%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>

