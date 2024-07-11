<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.NotasEnfermeria"%>
<%@ page import="issi.expediente.DetalleResultadoNota"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2"/>
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="NEMgr" scope="page" class="issi.expediente.NotasEnfermeriaMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<%
/**
==================================================================================
SAL310111 Expediente Enfermeria

Flag       Descripcion
TD				 UTILIZADA PARA TODAS LAS SECCIONES DONDE APAREZCA NOTAS DE ENFERMERIAS.
HM 				 UTILIZADA PARA LA SECCION NOTAS DE ENFERMERIAS DE HEMODIALISIS.
UR  			 UTILIZADA PARA LAS NOTAS DE ENFERMERIA DE TODAS LAS AREAS QUE ATIENDEN URGENCIAS. (URGENCIA ADULTO y PEDIATRICO)

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
NEMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();

CommonDataObject cdo = new CommonDataObject();

NotasEnfermeria ne = new NotasEnfermeria();
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
String id = request.getParameter("id");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

int lastLineNo = 0;
String key = "";
String colsPan = "";
if (fecha == null) fecha = cDateTime.substring(0,10);
if (hora == null) hora = cDateTime.substring(11);

if (fg == null)
{
 fg = "";
 colsPan = "4";
}else colsPan ="6";
//System.out.println("mode  *****  == "+request.getParameter("mode"));

if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (defaultAction == null) defaultAction = "";
if (desc == null) desc = "";
if (modeSec == null) modeSec = "";
if (id == null) id = "";

if(fg != null && fg.trim().equals("UR"))// solo para los centros que atienden urgencias.
{
if (defaultAction.equals("1"))// Indica si la seccion es editable viene de expediente config,
{
	if (CmnMgr.getCount("select count(*) from tbl_adm_admision a, tbl_adm_paciente b, tbl_adm_categoria_admision c, tbl_adm_tipo_admision_cia d where a.pac_id=b.pac_id and a.categoria=c.codigo and a.categoria=d.categoria and a.tipo_admision=d.codigo and a.compania=d.compania and a.compania="+(String) session.getAttribute("_companyId")+" and a.pac_id="+pacId+" and a.secuencia="+noAdmision+" and a.categoria =1 ") == 0)// count para saber si la atencion es de urgencias solamente.
	{
		/* verifica si el paciente tiene notas registradas si es 0 debe permitir registrar las notas */
		if (CmnMgr.getCount("select count(*) from tbl_sal_notas_enfermeria z, tbl_sal_resultado_nota y where (z.pac_id=y.pac_id and z.secuencia=y.secuencia and z.id=y.id) and z.pac_id="+pacId+" and z.secuencia="+noAdmision+"") == 0) modeSec = "";
		/** Verifica Si las notas estan pendiente y tiene en el detalle notas activas o inactivas para seguir agregando hasta que no se hallan finalizado.*/
		else if (CmnMgr.getCount("select count(*) from tbl_sal_notas_enfermeria z, tbl_sal_resultado_nota y where (z.pac_id=y.pac_id and z.secuencia=y.secuencia and z.id=y.id) and z.pac_id="+pacId+" and z.secuencia="+noAdmision+" and z.estado='P' and y.estado in('A','I')") > 0) modeSec = "";
		/** si el paciente tiene notas registradas y el estado de las notas es finalizada indica que el expediente del paciente está cerrado por lo cual no puede registrar mas notas por lo cual asigna mode = view a la seccion.*/
		else modeSec ="view";
	}//else mode ="";
}

/* filtro para realizar la busqueda por hora al editar las notas*/
 filter = " and id="+id;
}
else if(fg != null && fg.trim().equals("HM"))//para las notas de hemodialisis
{
	if (CmnMgr.getCount("select count(*) from tbl_sal_notas_enfermeria z, tbl_sal_resultado_nota y where (z.pac_id=y.pac_id(+) and z.secuencia=y.secuencia(+) and z.id=y.id(+)) and z.pac_id="+pacId+" and z.secuencia="+noAdmision+" and z.estado='P' and y.estado(+)='A' and to_date(to_char(z.fecha,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('"+cDateTime.substring(0,10)+"','dd/mm/yyyy')  and z.no_hemodialisis is not null and nvl(y.comentario,' ') <> 'HM2' ") > 0 && cDateTime.substring(0,10).equals(fecha))
	{
		modeSec = "edit";
	}

	if (fecha == null && !mode.trim().equals("view")){
			 modeSec = "add";
	}else if (!mode.trim().equals("view")){
		 modeSec="edit";
	}
}else modeSec = "";

if (mode == null || mode.trim().equals("")) mode = "add";
if (modeSec == null || modeSec.trim().equals("")) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;

if(fg != null && fg.trim().equals("HM")){
	 al2 = SQLMgr.getDataList("select NE.NO_HEMODIALISIS,  NE.ESTADO, to_char(ne.fecha,'dd/mm/yyyy') fecha ,to_char(ne.hora,'hh12:mi:ss am') hora, ne.pac_id, no_hemodialisis noHemodialisis, ne.maquina, ne.filtro, ne.solucion, ne.peso_inicial pesoInicial, ne.peso_final pesoFinall, NE.USUARIO_CREACION,to_char(NE.FECHA_CREACION,'dd/mm/yyyy hh12:mi am') FECHA_CREACION from tbl_sal_notas_enfermeria ne where ne.pac_id ="+pacId+" and ne.secuencia="+noAdmision+" and NE.NO_HEMODIALISIS is not null and nvl(ne.observacion,' ') <> 'HM2' order by ne.fecha desc, ne.hora desc");
}
//if ((!defaultAction.equals("1") && mode.trim().equals("view"))) viewMode=true;
if (mode.trim().equals("view")) viewMode=true;
if (request.getMethod().equalsIgnoreCase("GET"))
{

if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	HashDet.clear();
	if (modeSec.equalsIgnoreCase("add"))
	{
		String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
		ne.setFecha(cDate.substring(0,10));
		ne.setHora(cDate.substring(11));
		DetalleResultadoNota drn = new DetalleResultadoNota();
		drn.setCodigo("0");
		drn.setEstado("A");
		drn.setFecha(cDate.substring(0,10));
		drn.setHoraR(cDate.substring(11,16)+cDate.substring(19));
		drn.setUsuarioCreacion((String) session.getAttribute("_userName"));

		lastLineNo++;
		if (lastLineNo < 10) key = "00" + lastLineNo;
		else if (lastLineNo < 100) key = "0" + lastLineNo;
		else key = "" + lastLineNo;
		drn.setKey(""+lastLineNo);

		try
		{
			HashDet.put(key, drn);
		}
		catch(Exception e)

		{
			System.err.println(e.getMessage());
		}
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{
		sql=" select  to_char(fecha,'dd/mm/yyyy') fecha ,to_char(hora,'hh12:mi:ss am') hora, pac_id, no_hemodialisis noHemodialisis, maquina, filtro, solucion, peso_inicial pesoInicial, peso_final pesoFinal,ne.id from tbl_sal_notas_enfermeria ne where pac_id = "+pacId+" and secuencia = "+noAdmision+" and estado = 'P'  "+filter+" ";
if(fg != null && fg.trim().equals("HM")){
		 sql +=" and ne.no_hemodialisis is not null and nvl(ne.observacion,' ') <> 'HM2' ";

	 if(!cDateTime.substring(0,10).equals(fecha) ) {
	 viewMode=true;
	 modeSec = "view";
}

}


		ne = (NotasEnfermeria) sbb.getSingleRowBean(ConMgr.getConnection(), sql, NotasEnfermeria.class);
		System.out.println("Sql :: == "+sql);
		if (ne == null)
		{
			ne = new NotasEnfermeria();
			ne.setFecha(fecha);
			ne.setHora(hora);
			ne.setId("0");
		}
		if(fg != null && fg.trim().equals("HM"))
		{
		 hora = ne.getHora();
		 filter += " and id ="+ne.getId();
		}

		/*
			//query para hemodialisis.
		*/
		sql = "select a.codigo, nvl(to_char(a.fecha,'dd/mm/yyyy'),' ') as fecha, nvl(to_char(a.hora_r,'hh12:mi am'),' ') as horaR, nvl(a.temperatura,' ') as temperatura, nvl(a.pulso,' ') as pulso, nvl(a.p_arterial,' ') as pArterial, nvl(a.respiracion,' ') as respiracion, nvl(a.med_trat,' ') as medTrat, nvl(a.observacion,' ') as observacion, nvl(a.estado,'A') as estado, a.usuario_creacion usuarioCreacion , nvl(a.flujo_sanguineo,' ') flujoSanguineo, nvl(a.p_venosa,' ') pVenosa , nvl(a.p_transmembranica,' ') pTransmembranica, nvl(a.ultrafijacion,' ') ultrafijacion , a.recormon_unid recormon from tbl_sal_resultado_nota a where a.pac_id="+pacId+" and a.secuencia="+noAdmision+" "+filter+" and a.estado ='A' and nvl(a.comentario,' ') <> 'HM2' order by  to_date( to_char(a.fecha,'dd/mm/yyyy')||' '||to_char(a.hora_r,'hh12:mi am') ,'dd/mm/yyyy hh12:mi am')/*fecha_creacion*/";
		al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleResultadoNota.class);
		System.out.println("SqlDet :: == "+sql);
		lastLineNo = al.size();
		for (int i=1; i<=al.size(); i++)
		{
			DetalleResultadoNota drn = (DetalleResultadoNota) al.get(i - 1);

			if (i < 10) key = "00"+i;
			else if (i < 100) key = "0"+i;
			else key = ""+i;
			drn.setKey(key);

			try
			{
				HashDet.put(key, drn);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}

System.out.println(" viewMode === "+viewMode);
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
function doAction()
{loaded=true;/*checkViewMode();*/}
function verNotas(){abrir_ventana1('../expediente/notas_enfermeria_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&defaultAction=<%=defaultAction%>');}
function verListaNotas(){abrir_ventana1('../expediente/exp_notas_enfermeria_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&fg=<%=fg%>&seccion=<%=seccion%>&defaultAction=<%=defaultAction%>');}
function imprimirNotas(){var fg = eval('document.form0.fg').value; var fecha_reporte = ''; if (fg = 'HM'){fecha_reporte    = eval('document.form0.fecha_reporte').value;}abrir_ventana1('../expediente/print_notas_enfermeria.jsp?pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&fg=NE&fp=<%=fg%>&fecha='+fecha_reporte);}
function viewChart(){var ddl = document.form0.horario;var horario = getHorario(ddl);var fecha = eval('document.form0.fecha').value ;var from = document.form0.from.value;var to = document.form0.to.value;if(from == null || from =="undefined" || to == null || to =="undefined"){from = "";to = "";}var go = showHideRangoFecha();if(go){abrir_ventana1('../expediente/chart_nota_enfer.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&stamp=<%=new java.util.Date()%>&horario='+horario+'&from='+from+'&to='+to+'');}}
function printChart(){var ddl = document.form0.horario;var horario = getHorario(ddl);var fecha = eval('document.form0.fecha').value ;var from = document.form0.from.value;var to = document.form0.to.value;if(from == null || from == undefined || to == null || to == undefined){from = "";to = "";}var go = showHideRangoFecha();if(go){abrir_ventana1('../expediente/print_chart_nota_enfer.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&seccion=<%=mode%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&stamp=<%=new java.util.Date()%>&horario='+horario+'&from='+from+'&to='+to+'');}}
function getHorario(ddl){
    var _index  = ddl.selectedIndex;
    var selVal = ddl.options[_index].value;
    $("#chart-options").toggle();
    if(selVal == "todos"){
        document.getElementById("rangoFecha").style.display = "";
    }else{
        document.getElementById("rangoFecha").style.display = "none";
    }
    return selVal;
}
function showHideRangoFecha(){var theSelOpt = document.form0.horario.selectedIndex;var option = document.form0.horario.options[theSelOpt].value;var from = document.form0.from.value;var to = document.form0.to.value;if(option == 'todos'){var rangoFecha = document.getElementById("rangoFecha").style.display='';if(from.length == "" || to.length == "" ) {alert("Por favor selecciona un rango de fecha!"); return false;}else return true;}else{return true;}}
function doSubmit(formName,bAction){parent.setPatientInfo(formName,'iDetalle');setBAction(formName,bAction);window.frames['iDetalle'].doSubmit();}
function setAtencion(f,h){window.location = "../expediente3.0/exp_notas_enfermeria.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&mode=<%=mode%>&modeSec=<%=modeSec%>&fg=<%=fg%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&defaultAction=<%=defaultAction%>&fecha="+f+"&hora="+h;}
function addAtencion(){window.location ="../expediente3.0/exp_notas_enfermeria.jsp?seccion=seccion=<%=seccion%>&mode=<%=mode%>&modeSec=add&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&defaultAction=<%=defaultAction%>";}
</script>
</head>
<body class="body-form">
  <div class="row">
    <div class="table-responsive" data-pattern="priority-columns">
    
       <%if(fg != null && fg.trim().equals("HM")){%>
       <table class="table table-small-font table-bordered table-striped table-hover">
         <%fb = new FormBean2("lista",request.getContextPath()+request.getServletPath());%>
         <%=fb.formStart(true)%>
         <%=fb.hidden("desc",desc)%>
         
         <tr class="bg-headtabla2 pull-center">
			<th><cellbytelabel>Hemodialisis</cellbytelabel></th>
            <th><cellbytelabel id="2">Fecha Nota</cellbytelabel></th>
            <th><cellbytelabel id="3">Hora Nota</cellbytelabel></th>
            <th><cellbytelabel id="4">Creada Por</cellbytelabel></th>
            <th><cellbytelabel id="5">Fecha Registro</cellbytelabel></th>
         </tr>
         
         <% for (int a = 1; a<=al2.size(); a++){
            cdo = (CommonDataObject)al2.get(a-1);
            String color = "TextRow02";
            if (a % 2 == 0) color = "TextRow01";
        %>

             <tr onClick="javascript:setAtencion('<%=cdo.getColValue("fecha")%>','<%=cdo.getColValue("hora")%>')">
                 <td><%=cdo.getColValue("no_hemodialisis")%></td>
                 <td><%=cdo.getColValue("fecha")%></td>
                 <td><%=cdo.getColValue("hora")%></td>
                 <td><%=cdo.getColValue("usuario_creacion")%></td>
                 <td><%=cdo.getColValue("FECHA_creacion")%></td>
             </tr>
             
		<%}%>
         <%=fb.formEnd(true)%>
       </table>
       <%}%>
       
       <%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
            <%=fb.formStart(true)%>
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
            <%=fb.hidden("size",""+HashDet.size())%>
            <%=fb.hidden("defaultAction",defaultAction)%>
            <%=fb.hidden("desc",desc)%>
            <%=fb.hidden("idNe",ne.getId())%>
            <%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
       <div class="headerform"> 
       <table cellspacing="0" class="table pull-right table-striped table-custom-1">
            <tr>
                <td>
                    <%if (fg!=null && fg.equals("HM")){%>
                     <button type="button" class="btn btn-inverse btn-sm" onclick="addAtencion()"><i class="fa fa-plus fa-printico"></i> <b>Agregar</b></button>
                    <%}%>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="verListaNotas()"><i class="fa fa-search fa-printico"></i> <b>Ver Notas</b></button>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="verNotas()"><i class="fa fa-times fa-printico"></i> <b>Invalidar Notas</b></button>
                    
                    <button type="button" class="btn btn-inverse btn-sm" onclick="imprimirNotas()"><i class="fa fa-print fa-printico"></i> <b>Imprimir Notas (Validas)</b></button>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="viewChart()"><i class="fa fa-search fa-printico"></i> <b>Ver Grafica</b></button>
                    <button type="button" class="btn btn-inverse btn-sm" onclick="printChart()"><i class="fa fa-print fa-printico"></i> <b>Imprimir Grafica</b></button>
                 </td>
            </tr>
            <tr style="display:none" id="chart-options">
             <td colspan="<%=colsPan%>" class="controls form-inline"><cellbytelabel>Opciones</cellbytelabel>: <%=fb.select("horario","todos=TODOS|_24h=ULTIMAS 24/H|turnoActual=TURNO ACTUAL","todos=TODOS",false,false,0,"form-control",null,"onChange=\"getHorario(this)\"",null,null,null,"|",null)%>
             <span style="text-align:right; display:;" id="rangoFecha">
									<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="2"/>
									<jsp:param name="nameOfTBox1" value="from"/>
									<jsp:param name="valueOfTBox1" value=""/>
									<jsp:param name="nameOfTBox2" value="to"/>
									<jsp:param name="valueOfTBox2" value=""/>
									<jsp:param name="clearOption" value="true"/>
					</jsp:include>
								</span>
             </td>
            </tr>
        </table>
        </div>
        
        <table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">

            <%if(!fg.trim().equals("HM")){%>
            <tr>
                <td align="right"><cellbytelabel id="13">Fecha</cellbytelabel></td>
                <td><%=fb.textBox("fecha",ne.getFecha(),true,false,true,10)%></td>
                <td align="right"><cellbytelabel id="14">Hora</cellbytelabel></td>
                <td><%=fb.textBox("hora",ne.getHora(),true,false,true,11)%></td>
                <%=fb.hidden("fecha_reporte","")%>
            </tr>
            <%}%>
            <%if(fg.trim().equals("HM")){%>
            <%=fb.hidden("hora",""+ne.getHora())%>
		<tr>
			<td align="right"><cellbytelabel id="13">Fecha</cellbytelabel></td>
			<td colspan="2" class="controls form-inline"><%//=fb.textBox("fecha",ne.getFecha(),true,false,true,10)%>
			<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fecha"/>
					<jsp:param name="valueOfTBox1" value="<%=ne.getFecha()%>"/>
			</jsp:include>
			<!--ne.getFecha()-->
			</td>
			<td align="right"><cellbytelabel id="15">Fecha Reporte de Notas</cellbytelabel></td>
			<td colspan="2" class="controls form-inline">
			<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fecha_reporte"/>
					<jsp:param name="valueOfTBox1" value="<%=ne.getFecha()%>"/>
			</jsp:include>
			<%//=fb.textBox("fecha",ne.getFecha(),true,false,true,10)%></td>
			<!--<td align="right">Hora</td>
			<td colspan="2"><%//=fb.textBox("hora",ne.getHora(),true,false,true,11)%></td>--->
		</tr>
		<tr class="bg-headtabla2 pull-center">
			<th width="24%"><cellbytelabel id="1">Hemodialisis</cellbytelabel> #</th>
			<th width="19%"><cellbytelabel id="16">M&aacute;quina</cellbytelabel></th>
			<th width="19%"><cellbytelabel id="17">Filtro</cellbytelabel></th>
			<th width="19%"><cellbytelabel id="18">Peso Inicial</cellbytelabel></th>
			<th width="19%"><cellbytelabel id="19">Peso Final</cellbytelabel></th>
		</tr>
		<tr>
			<td>
                <div class="form-group m-xs-2">
                    <input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=ne.getNoHemodialisis()%>" name="noHemodialisis" id="noHemodialisis" maxlength="10" size="10%">
                </div>
            </td>
			<td>
                <div class="form-group m-xs-2">
                    <input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=ne.getMaquina()%>" name="maquina" id="maquina" maxlength="10" size="10%">
                </div>
            </td>
			<td>
                <div class="form-group m-xs-2">
                    <input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=ne.getFiltro()%>" name="filtro" id="filtro" maxlength="10" size="10%">
                </div>
            </td>
			<td>
                <div class="form-group m-xs-2">
                    <input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=ne.getPesoInicial()%>" name="pesoInicial" id="pesoInicial" maxlength="10" size="10%">
                </div>
            </td>
			<td>
                <div class="form-group m-xs-2">
                    <input class="form-control input-md<%=viewMode?" disabled":""%>" value="<%=ne.getPesoFinal()%>" name="pesoFinal" id="pesoFinal" maxlength="10" size="10%">
                </div>
            </td>
		</tr>
		<tr>
		<td colspan="<%=colsPan%>"><cellbytelabel id="20">Soluci&oacute;n</cellbytelabel><%=fb.textarea("solucion",ne.getSolucion(),false,false,viewMode,25,2,2000,"form-control input-sm","width:100%","")%></td>
		</tr>
		<%}%>
        
        <tr>
			<td style="vertical-align:top !important" colspan="<%=colsPan%>"><iframe name="iDetalle" id="iDetalle" width="100%" height="400px" scrolling="yes" frameborder="0" src="../expediente3.0/exp_notas_enfermeria_det.jsp?seccion=<%=seccion%>&mode=<%=mode%>&modeSec=<%=modeSec%>&fg=<%=fg%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo=<%=lastLineNo%>&defaultAction=<%=defaultAction%>"></iframe></td>
		</tr>
        
        <tr>
			<td colspan="<%=colsPan%>" align="right">
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	NEMgr.setErrCode(request.getParameter("errCode"));
	NEMgr.setErrMsg(request.getParameter("errMsg"));
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (NEMgr.getErrCode().equals("1"))
{
%>
	alert('<%=NEMgr.getErrMsg()%>');
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
} else throw new Exception(NEMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=add&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo=<%=lastLineNo%>&fg=<%=fg%>&defaultAction=<%=defaultAction%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&lastLineNo=<%=lastLineNo%>&fecha=<%=request.getParameter("fecha")%>&hora=<%=request.getParameter("hora")%>&desc=<%=desc%>&defaultAction=<%=defaultAction%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>

