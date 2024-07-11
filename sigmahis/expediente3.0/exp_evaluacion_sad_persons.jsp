<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String fg = request.getParameter("fg");
String code = request.getParameter("code");
String key="";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (code == null) code = "0";
if (fg == null) fg = "SAD";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET")) {
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	sbSql.append("select a.codigo, a.descripcion, decode(b.cod_eval,null,'I','U') as action, b.valor, b.observacion from tbl_sal_sad_persons a, tbl_sal_escala_sad_persons b where a.estado = 'A' and a.tipo = '"+fg+"' and a.codigo = b.cod_eval(+) and b.pac_id(+) = ");
	sbSql.append(pacId);
	sbSql.append(" and b.admision(+) = ");
	sbSql.append(noAdmision);
	sbSql.append(" and b.codigo(+) = ");
	sbSql.append(code);
	sbSql.append(" order by a.codigo");
	al = SQLMgr.getDataList(sbSql.toString());

		ArrayList alH = new ArrayList();

		if (fg.trim().equalsIgnoreCase("SAD")){
				alH = SQLMgr.getDataList("select distinct codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_escala_sad_persons where pac_id="+pacId+" and admision="+noAdmision+" and tipo = '"+fg+"' order by 1 desc");
		} else {
				alH = SQLMgr.getDataList("select codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_calidad_ambulancia where pac_id="+pacId+" and admision="+noAdmision+" and tipo = '"+fg+"' order by 1 desc");
		}
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<script>
var noNewHeight = true;
$(function(){
	<%if(fg.trim().equalsIgnoreCase("SAD")){%>
	$(".__presente").click(function() {
		getTotal()
	});
	getTotal(true);
	<%}%>

	$("#imprimir").click(function(e){
		e.preventDefault();
		var fc = $("#fc<%=code%>").val();
		var uc = $("#uc<%=code%>").val();
		abrir_ventana("../expediente3.0/print_evaluacion_sad_persons.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>&fecha_creacion="+fc+"&usuario_creacion="+uc);
	});
});

function getTotal(afterSave) {
	var tot = 0;
	for (var i = 0; i<<%=al.size()%>; i++) {
		var val = $("input[name='valor"+i+"']:checked"). val() || $("input[name='_valor"+i+"Dsp']:checked"). val() || 0;
		tot += parseInt(val,10);
		debug(afterSave + "" +val)
	}
	if (afterSave && tot) {
		if (tot <= 2) parent.CBMSG.alert("Alta medica al domicilio con seguimiento ambulatorio");
		else if (tot > 2 && tot <= 4) parent.CBMSG.alert("Segumiento ambulatorio intensivo, considerar ingreso");
		else if (tot > 4 && tot <= 6) parent.CBMSG.alert("Recomendado ingreso sobre todo si hay ausencia de apoyo social");
		else if (tot > 6 && tot <= 10) parent.CBMSG.alert("Ingreso obligatorio incluso en contra de su voluntad");
	}
	$("#total").val(tot);
}

function setEscala(code){
		window.location = '../expediente3.0/exp_evaluacion_sad_persons.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_evaluacion_sad_persons.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>';}

function verHistorial() {
	$("#hist_container").toggle();
}

function verMedicos(){
abrir_ventana1('../common/search_medico.jsp?fp=sad_person');
}
</script>
</head>
<body class="body-form">

		<!---/INICIO Fila de Peneles/--------------->
<!--INICIO de una fila de elementos-->
<div class="row">
<!--INICIO de una fila de elementos-->

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fg",fg)%>

<!--tabla de boton imprimit-->
		<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
<tr>
<td>
		<%=fb.button("imprimir","Imprimir",false,(code.equals("0")),null,null,"")%>
		<%if(!mode.trim().equals("view")){%>
			<button type="button" class="btn btn-inverse btn-sm" onclick="add()">
				<i class="fa fa-plus fa-printico"></i> <b>Agregar</b>
			</button>
		<%}%>
			<button type="button" class="btn btn-inverse btn-sm" onclick="verHistorial()">
				<i class="fa fa-eye fa-printico"></i> <b>Historial</b>
			</button>
</td>
</tr>
</table>
		</div>

		<div class="table-wrapper" id="hist_container" style="display:none">
				<table cellspacing="0" class="table table-small-font table-bordered table-striped">
						<thead>
								<tr class="bg-headtabla2">
								<th style="vertical-align: middle !important;">C&oacute;digo</th>
								<th style="vertical-align: middle !important;">Fecha</th>
								<th style="vertical-align: middle !important;">Hora</th>
								<th style="vertical-align: middle !important;">Usuario</th>
						</thead>
						<%
						for (int p = 1; p <= alH.size(); p++){
								CommonDataObject cdoH = (CommonDataObject)alH.get(p-1);
						%>
						<%=fb.hidden("fc"+p,cdoH.getColValue("fc"))%>
						<%=fb.hidden("uc"+p,cdoH.getColValue("usuario_creacion"))%>
						<tbody>
								<tr onclick="javascript:setEscala('<%=cdoH.getColValue("codigo")%>')" class="pointer">
										<td><%=cdoH.getColValue("codigo")%></td>
										<td><%=cdoH.getColValue("fc")%></td>
										<td><%=cdoH.getColValue("hc")%></td>
										<td><%=cdoH.getColValue("usuario_creacion")%></td>
								</tr>
						</tbody>
						<% }%>
				</table>
		</div>




<!--fin tabla de boton imprimit-->
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
<%if(fg.trim().equalsIgnoreCase("AMBU")){
CommonDataObject cdoA = SQLMgr.getData("select to_char(fecha,'dd/mm/yyyy hh12:mi:ss am') fecha, paramedico, destino, medico_acompanante, tipo_ambulancia, proveedor, medico_verificador, (select primer_nombre||' '||primer_apellido from tbl_adm_medico where codigo = medico_verificador and estado = 'A' and rownum = 1) medico_verificador_nombre from tbl_sal_calidad_ambulancia where pac_id = "+pacId+" and admision = "+noAdmision+" and tipo = 'AMBU' and codigo = "+code);
if (cdoA == null) cdoA = new CommonDataObject();
%>
<tr>
	<td class="controls form-inline" colspan="4">
		<b>Fecha Traslado</b>:
		<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am"/>
				<jsp:param name="nameOfTBox1" value="fecha"/>
				<jsp:param name="valueOfTBox1" value="<%=cdoA.getColValue("fecha",cDateTime)%>"/>
				<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
		</jsp:include>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<b>Param&eacute;dico:</b>
		<%=fb.textBox("paramedico", cdoA.getColValue("paramedico"," "),false,false,viewMode,0,"form-control input-sm",null,null)%>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<b>Destino:</b>
		<%=fb.textBox("destino", cdoA.getColValue("destino"," "),false,false,viewMode,0,"form-control input-sm",null,null)%>
		<br>
		<b>M&eacute;dico que acompa&ntilde;a al traslado:</b>
		<%=fb.textBox("medico_acompanante", cdoA.getColValue("medico_acompanante"," "),false,false,viewMode,0,"form-control input-sm",null,null)%>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<b>Tipo Ambulancia:</b>
		<%=fb.textBox("tipo_ambulancia", cdoA.getColValue("tipo_ambulancia"," "),false,false,viewMode,0,"form-control input-sm",null,null)%>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<b>Proveedor:</b>
		<%=fb.textBox("proveedor", cdoA.getColValue("proveedor"," "),false,false,viewMode,0,"form-control input-sm",null,null)%>
		<br>
		<b>Verificado por M&eacute;dico ER:</b>
		<%=fb.textBox("medico_verificador", cdoA.getColValue("medico_verificador"," "),false,false,true,0,"form-control input-sm","width:80px",null)%>
		<%=fb.textBox("medico_verificador_nombre", cdoA.getColValue("medico_verificador_nombre"," "),false,false,true,0,"form-control input-sm","width:300px",null)%>

		<button type="button" class="btn btn-inverse btn-sm" onclick="verMedicos()"<%=viewMode?" disabled":""%>>...</button>
	</td>
</tr>
<%}%>

<%
String descripcion = "SINTOMAS";
if(fg.trim().equalsIgnoreCase("AMBU")) descripcion = "PARAMETROS";
%>

<tr class="bg-headtabla" >
		<td><%=descripcion%></td>
		<td align="center">SI</td>
		<td align="center">NO</td>
		<%if(fg.trim().equalsIgnoreCase("AMBU")){%>
		<td align="center">OBSERVACI&Oacute;N</td>
		<%}%>
</tr>
</thead>

<tbody>
<% for (int i = 0; i<al.size(); i++){%>
<%
 cdo = (CommonDataObject) al.get(i);
%>
<tr>
		<td align="left"><label><%=cdo.getColValue("descripcion")%></label></td>
		<td align="center"><label><%=fb.radio("valor"+i,"1",cdo.getColValue("valor").equals("1"),viewMode,false,"__presente",null,null)%></label></td>
		<td align="center"><label><%=fb.radio("valor"+i,"0",cdo.getColValue("valor").equals("0"),viewMode,false,"__presente",null,null)%></label></td>
		<%if(fg.trim().equalsIgnoreCase("AMBU")){%>
			<td>
				<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode,50,1,2000,"form-control input-sm","width='100%'",null)%>
			</td>
		<%}%>
</tr>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
<%}%>
<%if(fg.trim().equalsIgnoreCase("SAD")){%>
<tr>
		<td colspan="3" align="right" class="form-inline"><label>Puntuaci&oacute;n: <%=fb.textBox("total","0",false,false,true,0,"form-control input-sm",null,null)%></label></td>
</tr>
<%}%>
</tbody>
</table>
<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			 <td>
						Opciones de Guardar:
						<label><%=fb.radio("saveOption","O",true,viewMode,false,null,null,null)%> Mantener Abierto</label>
						<label><%=fb.radio("saveOption","C",false,viewMode,false,null,null,null)%> Cerrar</label>
						<%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
				</td>
		</tr>
		</table>
</div>

<%=fb.formEnd(true)%>
</div>
</div>
</body>

</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size= Integer.parseInt(request.getParameter("size"));
		String errorCode = "";
		String errorMsg = "";
		String nextId = "";

	fg = request.getParameter("fg");
		if (fg == null) fg = "";

		al.clear();

		if (fg.trim().equalsIgnoreCase("SAD")){
				CommonDataObject cdoId = SQLMgr.getData("select nvl(max(codigo),0) + 1 as nextId from tbl_sal_escala_sad_persons where pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and tipo = '"+fg+"'");

				nextId = cdoId.getColValue("nextId");

				for (int i=0; i<size; i++) {
						cdo = new CommonDataObject();
						cdo.setTableName("tbl_sal_escala_sad_persons");

						cdo.addColValue("codigo",cdoId.getColValue("nextId"));
						cdo.addColValue("pac_id",request.getParameter("pacId"));
						cdo.addColValue("admision",request.getParameter("noAdmision"));
						cdo.addColValue("cod_eval",request.getParameter("codigo"+i));
						if (request.getParameter("valor"+i) != null) cdo.addColValue("valor",request.getParameter("valor"+i));
						cdo.setAction(request.getParameter("action"+i));
						if (cdo.getAction().equalsIgnoreCase("I")) {
								cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
								cdo.addColValue("fecha_creacion","sysdate");
								cdo.addColValue("tipo",request.getParameter("fg"));
						}
						cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
						cdo.addColValue("fecha_modificacion","sysdate");
						al.add(cdo);
				}

				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				SQLMgr.saveList(al,true);
				ConMgr.clearAppCtx(null);

				errorCode = SQLMgr.getErrCode();
				errorMsg = SQLMgr.getErrMsg();

		} else {
				issi.expediente.CalidadAmbulancia calidadAmbu = new issi.expediente.CalidadAmbulancia();
				issi.expediente.CalidadAmbulanciaMgr calidadAmbuMgr = new issi.expediente.CalidadAmbulanciaMgr();

				calidadAmbuMgr.setConnection(ConMgr);

				calidadAmbu.setPacId(request.getParameter("pacId"));
				calidadAmbu.setAdmision(request.getParameter("noAdmision"));
				calidadAmbu.setTipo(request.getParameter("fg"));
				calidadAmbu.setFechaCreacion(cDateTime);
				calidadAmbu.setFechaModificacion(cDateTime);
				calidadAmbu.setUsuarioCreacion((String) session.getAttribute("_userName"));
				calidadAmbu.setUsuarioModificacion((String) session.getAttribute("_userName"));

				if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals("")) calidadAmbu.setFecha(request.getParameter("fecha"));
				if (request.getParameter("paramedico") != null && !request.getParameter("paramedico").trim().equals("")) calidadAmbu.setParamedico(request.getParameter("paramedico"));
				if (request.getParameter("destino") != null && !request.getParameter("destino").trim().equals("")) calidadAmbu.setDestino(request.getParameter("destino"));
				if (request.getParameter("medico_acompanante") != null && !request.getParameter("medico_acompanante").trim().equals("")) calidadAmbu.setMedicoAcompanante(request.getParameter("medico_acompanante"));
				if (request.getParameter("tipo_ambulancia") != null && !request.getParameter("tipo_ambulancia").trim().equals("")) calidadAmbu.setTipoAmbulancia(request.getParameter("tipo_ambulancia"));
				if (request.getParameter("proveedor") != null && !request.getParameter("proveedor").trim().equals("")) calidadAmbu.setProveedor(request.getParameter("proveedor"));
				if (request.getParameter("medico_verificador") != null && !request.getParameter("medico_verificador").trim().equals("")) calidadAmbu.setMedicoVerificador(request.getParameter("medico_verificador"));

				for (int i=0; i<size; i++) {
						issi.expediente.Calidades calidades = new issi.expediente.Calidades();

						calidades.setCodEval(request.getParameter("codigo"+i));
						if (request.getParameter("valor"+i) != null) calidades.setValor(request.getParameter("valor"+i));
						if (request.getParameter("observacion"+i) != null) calidades.setObservacion(request.getParameter("observacion"+i));

						al.add(calidades);
				}

				calidadAmbu.setCalidades(al);

				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				calidadAmbuMgr.add(calidadAmbu);
				ConMgr.clearAppCtx(null);

				nextId = calidadAmbuMgr.getPkColValue("codigo");;

				errorCode = calidadAmbuMgr.getErrCode();
				errorMsg = calidadAmbuMgr.getErrMsg();
		}
%>
<html>
<head>
<script>
function closeWindow(){
<% if (errorCode.equals("1")) { %>
	alert('<%=errorMsg%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp")) { %>

<% } else { %>
<%
	}

	if (saveOption.equalsIgnoreCase("N")) {
%>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(errorMsg);
%>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=nextId%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
