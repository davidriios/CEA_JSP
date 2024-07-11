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
String tab = request.getParameter("tab");
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (estado == null) estado = "";
if (cds == null) cds = "";
if (code == null) code = "0";
if (fg == null) fg = "";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (tab == null) tab = "0";

String active0 = "", active1 = "", active2 = "";

if (request.getMethod().equalsIgnoreCase("GET")) {

	sbSql.append("select a.codigo, a.descripcion, b.observacion, b.valor, decode(b.cod_param,null,'I','U') action, b.cod_param from tbl_sal_ant_med_importantes a, tbl_sal_proc_cir_ambu_det b where a.codigo = b.cod_param(+) and b.pac_id(+) = ");

		sbSql.append(pacId);
	sbSql.append(" and b.admision(+) = ");
	sbSql.append(noAdmision);
	sbSql.append(" and b.cod_header(+) = ");
	sbSql.append(code);

		if (modeSec.equalsIgnoreCase("add")) {
				sbSql.append(" and a.estado = 'A' ");
		}

	sbSql.append(" order by a.orden");
	al = SQLMgr.getDataList(sbSql.toString());

		ArrayList alH = SQLMgr.getDataList("select codigo, to_char(fecha_creacion,'dd/mm/yyyy') fecha_creacion, to_char(fecha_creacion,'hh12:mi:ss am') hora_creacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion, usuario_creacion, usuario_modificacion from tbl_sal_proc_cir_ambu where pac_id = "+pacId+" and admision = "+noAdmision+" order by 1 desc");

		if (tab.equals("0")) active0 = "active";
		else if (tab.equals("1")) active1 = "active";
		else if (tab.equals("2")) active2 = "active";
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script src="../js/iframe-resizer/iframeResizer.min.js"></script>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
var noNewHeight = true;
function setEscala(code){
		window.location = '../expediente3.0/exp_proc_y_cirugia_ambu.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&tab=<%=tab%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&cds=<%=cds%>&estado=<%=estado%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_proc_y_cirugia_ambu.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&tab=<%=tab%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>&cds=<%=cds%>&estado=<%=estado%>';}

function verHistorial() {
	$("#hist_container").toggle();
}

function addDx(){
		abrir_ventana1('../common/search_diagnostico.jsp?fp=proc_y_cirugia_ambu&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
}
function procedimientoList(){abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=proc_y_cirugia_ambu');}

$(function(){
	$('iframe').iFrameResize({
		log: false
	});

	$("#imprimir").click(function(e){
		e.preventDefault();
		abrir_ventana("../expediente3.0/print_proc_y_cirugia_ambu.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>");
	});

	$("input:radio[name*='valor']").click(function(){
		var i = $(this).data('index');
		$("#observacion"+i).prop("readOnly",false);
	});

	$("input:radio[name*='vulnerable']").click(function(){
		if (this.value == 'S') {
				$("#vul_container").show(0);
		} else {
				$("input[name*='vulnerabilidades'][type='radio']").prop("checked", false);
				$("#otras_vulnerabilidades").prop("readOnly", true).val("");
				$("#vul_container").hide(0);
		}
	});

	$("input[name*='alergico'][type='radio']").click(function(){
		if (this.value == 'S') $("#alergias").prop("readOnly", false);
		else $("#alergias").prop("readOnly", true).val("");
	});

	$("input[name*='voluntario'][type='radio']").click(function(){
		if (this.value == 'S') $("#voluntad_desc").prop("readOnly", false);
		else $("#voluntad_desc").prop("readOnly", true).val("");
	});

	$("input[name*='vulnerabilidades'][type='radio']").click(function(){
		if (this.value == 'O') $("#otras_vulnerabilidades").prop("readOnly", false);
		else $("#otras_vulnerabilidades").prop("readOnly", true).val("");
	});

});

function canSubmit() {
		var proceed = true;

		if ( $("input:checked[name*='alergico'][value='S']").length && !$.trim($("#alergias").val())  ) {
				parent.CBMSG.error("Por favor indicar las Alergias!");
				proceed = false;
		} else if ( $("input:checked[name*='voluntario'][value='S']").length && !$.trim($("#voluntad_desc").val()) ) {
				parent.CBMSG.error("Por favor indicar las Voluntades Anticipadas!");
				proceed = false;
		} else if ( $("input:checked[name*='vulnerabilidades'][value='O']").length && !$.trim($("#otras_vulnerabilidades").val()) ) {
				parent.CBMSG.error("Por favor indicar las Otras Vulnerabilidades!");
				proceed = false;
		}
		return proceed;
}
</script>
</head>
<body class="body-form">

		<!---/INICIO Fila de Peneles/--------------->
<!--INICIO de una fila de elementos-->
<div class="row">
<!--INICIO de una fila de elementos-->

<div class="table-responsive" data-pattern="priority-columns">

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
						<tbody>
								<tr onclick="javascript:setEscala('<%=cdoH.getColValue("codigo")%>')" class="pointer">
										<td><%=cdoH.getColValue("codigo")%></td>
										<td><%=cdoH.getColValue("fecha_creacion")%></td>
										<td><%=cdoH.getColValue("hora_creacion")%></td>
										<td><%=cdoH.getColValue("usuario_creacion")%></td>
								</tr>
						</tbody>
						<% }%>
				</table>
		</div>

<ul class="nav nav-tabs" role="tablist">
		<li role="presentation" class="<%=active0%>">
				<a href="#generales" aria-controls="generales" role="tab" data-toggle="tab"><b>Datos Generales</b></a>
		</li>
		<%if (!modeSec.equalsIgnoreCase("add")){%>

		<li role="presentation" class="<%=active1%>">
				<a href="#examen_fisico" aria-controls="examen_fisico" role="tab" data-toggle="tab"><b>Examen F&iacute;sico</b></a>
		</li>
		<li role="presentation" class="<%=active2%>">
				<a href="#ordenes" aria-controls="ordenes" role="tab" data-toggle="tab"><b>&Oacute;rdenes</b></a>
		</li>
		<%}%>
</ul>

<!-- Tab panes -->
	<div class="tab-content">

		<!-- Generales -->
		<div role="tabpanel" class="tab-pane <%=active0%>" id="generales">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tab", "0")%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("code",code)%>




<!--fin tabla de boton imprimit-->
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
<%
cdo = SQLMgr.getData("select a.cod_diag, nvl(d.observacion,nombre) diag_desc, a.cod_procedimiento, nvl(c.observacion,nombre) procedimiento_desc, a.alergico, a.alergias_desc, a.voluntario, a.voluntad_desc, a.vulnerable, a.vulnerabilidad vulnerabilidades, a.vulnerabilidad_desc, a.presion_arterial, a.peso from tbl_sal_proc_cir_ambu a, tbl_cds_diagnostico d, tbl_cds_procedimiento c where a.cod_diag = d.codigo(+) and a.cod_procedimiento = c.codigo(+) and a.pac_id = "+pacId+" and a.admision = "+noAdmision+" and a.codigo = "+code);
if (cdo == null) cdo = new CommonDataObject();
%>

<tbody>
<tr>
	<td class="controls form-inline" colspan="4">

		<b>Diagn&oacute;stico:</b>
		<%=fb.textBox("diag",cdo.getColValue("cod_diag"),false,false,true,5,"form-control input-sm",null,"")%>
		<%=fb.textBox("diag_desc",cdo.getColValue("diag_desc"),false,false,true,35,"form-control input-sm",null,"")%>
		<%=fb.button("btn_dx","...",true,viewMode,null,null,"onClick=\"javascript:addDx()\"")%>

		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<b>Procedimiento:</b>
		<%=fb.textBox("procedimiento",cdo.getColValue("cod_procedimiento"),false,false,true,5,"form-control input-sm","",null)%>
		<%=fb.textBox("desc_proc", cdo.getColValue("procedimiento_desc"),false,true,viewMode,35,"form-control input-sm","",null)%>
		<%=fb.button("oper","...",true,viewMode,null,null,"onClick=\"javascript:procedimientoList()\"","seleccionar Operación")%>

		</label>

	</td>
</tr>
</tbody>

<tbody>
<tr>
	<td class="controls form-inline" colspan="4">

		<b>ALERGIAS: </b>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>SI</b>&nbsp;
		<%=fb.radio("alergico", "S" ,cdo.getColValue("alergico"," ").trim().equalsIgnoreCase("S"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>NO</b>&nbsp;
		<%=fb.radio("alergico", "N" ,cdo.getColValue("alergico"," ").trim().equalsIgnoreCase("N"),false,viewMode,null,"",null,"")%>
		</label>

		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cu&aacute;l (es):&nbsp;
		<%=fb.textBox("alergias",cdo.getColValue("alergias_desc"),false,false,viewMode||cdo.getColValue("alergias_desc"," ").trim().equals(""),100,100,"form-control input-sm",null,null)%>

	</td>
</tr>
</tbody>

<tbody>
<tr>
	<td class="controls form-inline" colspan="4">

		<b>Voluntades Anticipadas: </b>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>SI</b>&nbsp;
		<%=fb.radio("voluntario", "S" ,cdo.getColValue("voluntario"," ").trim().equalsIgnoreCase("S"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>NO</b>&nbsp;
		<%=fb.radio("voluntario", "N" ,cdo.getColValue("voluntario"," ").trim().equalsIgnoreCase("N"),false,viewMode,null,"",null,"")%>
		</label>

		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cu&aacute;l (es):&nbsp;
		<%=fb.textBox("voluntad_desc",cdo.getColValue("voluntad_desc"),false,false,viewMode||cdo.getColValue("voluntad_desc"," ").trim().equals(""),100,100,"form-control input-sm",null,null)%>

	</td>
</tr>
</tbody>



<tbody>
<tr>
	<td class="controls form-inline" colspan="4">

		<b>Paciente Vulnerable: </b>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>SI</b>&nbsp;
		<%=fb.radio("vulnerable", "S" ,cdo.getColValue("vulnerable"," ").trim().equalsIgnoreCase("S"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>NO</b>&nbsp;
		<%=fb.radio("vulnerable", "N" ,cdo.getColValue("vulnerable"," ").trim().equalsIgnoreCase("N"),false,viewMode,null,"",null,"")%>
		</label>

		<div <%=cdo.getColValue("vulnerabilidades"," ").trim().equals("")?"style='display:none'":""%> id="vul_container">
		Vulnerabilidades:&nbsp;
		<label class="pointer">
		<b>PEDIAT.</b>&nbsp;
		<%=fb.radio("vulnerabilidades", "P" ,cdo.getColValue("vulnerabilidades"," ").trim().equalsIgnoreCase("P"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>GERIAT.</b>&nbsp;
		<%=fb.radio("vulnerabilidades", "G" ,cdo.getColValue("vulnerabilidades"," ").trim().equalsIgnoreCase("G"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>PSIQUIAT.</b>&nbsp;
		<%=fb.radio("vulnerabilidades", "Q" ,cdo.getColValue("vulnerabilidades"," ").trim().equalsIgnoreCase("Q"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>GINEC.</b>&nbsp;
		<%=fb.radio("vulnerabilidades", "J" ,cdo.getColValue("vulnerabilidades"," ").trim().equalsIgnoreCase("J"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>ABUSO</b>&nbsp;
		<%=fb.radio("vulnerabilidades", "A" ,cdo.getColValue("vulnerabilidades"," ").trim().equalsIgnoreCase("A"),false,viewMode,null,"",null,"")%>
		</label>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<label class="pointer">
		<b>OTRO</b>&nbsp;
		<%=fb.radio("vulnerabilidades", "O" ,cdo.getColValue("vulnerabilidades"," ").trim().equalsIgnoreCase("O"),false,viewMode,null,"",null,"")%>
		</label>

		&nbsp;
		<%=fb.textBox("otras_vulnerabilidades",cdo.getColValue("vulnerabilidad_desc"),false,false,viewMode||cdo.getColValue("vulnerabilidad_desc"," ").trim().equals(""),50,100,"form-control input-sm",null,null)%>
		</div>

	</td>
</tr>

<tr>
		<td class="controls form-inline" colspan="4">
				<b>P/A:</b>&nbsp;
				<%=fb.textBox("presion_arterial",cdo.getColValue("presion_arterial"),false,false,viewMode,15,7,"form-control input-sm",null,null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Peso (kg):</b>&nbsp;
				<%=fb.textBox("peso",cdo.getColValue("peso"),false,false,viewMode,15,10,"form-control input-sm",null,null)%>
		</td>
</tr>


</tbody>

<tr class="bg-headtabla" >
		<td>ANTECEDENTES MEDICOS IMPORTANTES</td>
		<td align="center">SI</td>
		<td align="center">NO</td>
		<td>OBSERVACI&Oacute;N</td>
</tr>
</thead>

<tbody>
<% for (int i = 0; i<al.size(); i++){%>
<%
 cdo = (CommonDataObject) al.get(i);
%>
<tr>
		<td align="left"><label><%=cdo.getColValue("descripcion")%></label></td>
		<td align="center"><label><%=fb.radio("valor"+i,"S",cdo.getColValue("valor"," ").trim().equalsIgnoreCase("S"),false,false,"",null,null,null," data-index="+i,null)%></label></td>
		<td align="center"><label><%=fb.radio("valor"+i,"N",cdo.getColValue("valor"," ").trim().equalsIgnoreCase("N"),false,false,"",null,null,null," data-index="+i,null)%></label></td>
		<td>
				<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode||cdo.getColValue("observacion"," ").trim().equals(""),50,1,2000,"form-control input-sm","width='100%'",null)%>
		</td>
</tr>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("cod_param"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
<%}%>

</tbody>
</table>
<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			 <td>
						<%=fb.hidden("saveOption","O")%>
						<%=fb.submit("save","Guardar",true,viewMode,"",null,"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
				</td>
		</tr>
		</table>
</div>

<%=fb.formEnd(true)%>
</div>

<%
cdo = SQLMgr.getData("select to_char(fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento, codigo from tbl_adm_paciente where pac_id = "+pacId);
if (cdo == null) cdo = new CommonDataObject();
%>
<div role="tabpanel" class="tab-pane <%=active1%>" id="examen_fisico">
		<table width="100%" cellpadding="1" cellspacing="1" >
				<tr>
						<td>
								<iframe id="doc_esc" name="doc_esc" width="100%" scrolling="yes" frameborder="0" src="../expediente3.0/exp_examen_fisico.jsp?mode=&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=expediente&exp=3&estado=<%=estado%>&seccion=10&desc=EXAMEN%20FISICO&cds=<%=cds%>&fg=proc_y_cirugia_ambu&fecha_nacimiento=<%=cdo.getColValue("fecha_nacimiento")%>&codigo_paciente=<%=cdo.getColValue("codigo")%>"></iframe>
						</td>
				</tr>
		</table>
</div>

<div role="tabpanel" class="tab-pane <%=active2%>" id="ordenes">
		<%fb = new FormBean2("form2",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("modeSec",modeSec)%>
		<%=fb.hidden("seccion",seccion)%>
		<%=fb.hidden("size",""+al.size())%>
		<%=fb.hidden("pacId",pacId)%>
		<%=fb.hidden("noAdmision",noAdmision)%>
		<%=fb.hidden("desc",desc)%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("tab","2")%>
		<%=fb.hidden("cds",cds)%>
		<%=fb.hidden("estado",estado)%>
		<%=fb.hidden("code",code)%>

		<%
		ArrayList alN = SQLMgr.getDataList("select nota, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion_dsp from tbl_sal_proc_cir_ambu_notas where pac_id = "+pacId+" and admision = "+noAdmision+" and cod_header = "+code+" order by fecha_creacion desc");
		%>

		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
				<tr class="bg-headtabla2">
						<td colspan="2">ORDENES</td>
				</tr>
				<%if(!mode.equalsIgnoreCase("view")){%>
						<tr>
								<td colspan="2">
										<b>Nota:</b>&nbsp;
										<%=fb.textarea("nota","",false,false,false,50,1,2000,"form-control input-sm","width='100%'",null)%>
								</td>
						</tr>
						<%=fb.hidden("action","I")%>
				<%}%>

				<%for(int i = 0; i < alN.size(); i++){
						cdo = (CommonDataObject) alN.get(i);
				%>
						<tr>
								<td><b><%=cdo.getColValue("fecha_creacion_dsp")%></b></td>
								<td>
										<%=fb.textarea("nota"+i,cdo.getColValue("nota"),false,false,true,50,1,2000,"form-control input-sm","width='100%'",null)%>
								</td>
						</tr>
				<%}%>
		</table>

<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			 <td>
						<%=fb.hidden("saveOption","O")%>
						<%=fb.submit("save","Guardar",true,mode.equalsIgnoreCase("view"),"",null,"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onclick=\"parent.doRedirect(0)\"")%>
				</td>
		</tr>
		</table>
</div>
<%=fb.formEnd(true)%>
</div>
</div> <!-- Container -->





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

	if (tab.trim().equals("0")) {

				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_proc_cir_ambu");
				cdo.addColValue("cod_diag", request.getParameter("diag"));
				cdo.addColValue("cod_procedimiento", request.getParameter("procedimiento"));
				cdo.addColValue("alergico", request.getParameter("alergico"));
				if (request.getParameter("alergico")!=null && request.getParameter("alergico").equalsIgnoreCase("S")) cdo.addColValue("alergias_desc", request.getParameter("alergias"));
				cdo.addColValue("voluntario", request.getParameter("voluntario"));
				if (request.getParameter("voluntario")!=null && request.getParameter("voluntario").equalsIgnoreCase("S")) cdo.addColValue("voluntad_desc", request.getParameter("voluntad_desc"));

				cdo.addColValue("presion_arterial", request.getParameter("presion_arterial"));
				cdo.addColValue("peso", request.getParameter("peso"));
				cdo.addColValue("vulnerable", request.getParameter("vulnerable"));

				if (request.getParameter("vulnerable") != null && request.getParameter("vulnerable").equalsIgnoreCase("S")) {
						cdo.addColValue("vulnerabilidad", request.getParameter("vulnerabilidades"));

						if (request.getParameter("vulnerabilidades") != null && request.getParameter("vulnerabilidades").equalsIgnoreCase("O")) cdo.addColValue("vulnerabilidad_desc", request.getParameter("otras_vulnerabilidades"));
				}

				if (!code.trim().equals("0")) {
						cdo.setAction("U");
						cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and codigo = "+code);
						cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
						cdo.addColValue("fecha_modificacion", cDateTime);
				} else {
						CommonDataObject cdoH = SQLMgr.getData("select nvl(max(codigo),0)+1 as nextId from tbl_sal_proc_cir_ambu where pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision"));

						cdo.addColValue("codigo", cdoH.getColValue("nextId","0"));
						cdo.addColValue("pac_id", pacId);
						cdo.addColValue("admision", noAdmision);
						cdo.setAction("I");
						cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
						cdo.addColValue("fecha_creacion", cDateTime);
						cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
						cdo.addColValue("fecha_modificacion", cDateTime);
				}

				for (int i = 0; i<size; i++) {
						if (request.getParameter("valor"+i) != null) {
								CommonDataObject cdoD = new CommonDataObject();
								cdoD.setTableName("tbl_sal_proc_cir_ambu_det");
								cdoD.addColValue("cod_param", request.getParameter("cod_param"+i));
								cdoD.addColValue("observacion", request.getParameter("observacion"+i));
								cdoD.addColValue("valor", request.getParameter("valor"+i));

								if (!code.trim().equals("0")) {
										cdoD.setAction("U");
										cdoD.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and cod_header = "+code+" and cod_param = "+request.getParameter("cod_param"+i));
										cdoD.addColValue("cod_header", code);
								} else {
										cdoD.addColValue("cod_header", cdo.getColValue("codigo"));
										cdoD.setAction("I");
										cdoD.addColValue("pac_id", pacId);
										cdoD.addColValue("admision", noAdmision);
								}

								al.add(cdoD);
						}
				}

				if (al.size() == 0) {
						CommonDataObject cdoD = new CommonDataObject();
						cdoD.setTableName("tbl_sal_proc_cir_ambu_det");
						cdoD.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and cod_header = "+code);

						al.add(cdoD);
				}

				ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
				SQLMgr.save(cdo,al,true,false,true,true);
				if (modeSec.equals("add")) {
						// code = SQLMgr.getPkColValue("codigo");
						code = cdo.getColValue("codigo");
				}
				ConMgr.clearAppCtx(null);

				errorCode = SQLMgr.getErrCode();
				errorMsg = SQLMgr.getErrMsg();
		}
		else if (tab.trim().equals("2")) {

				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_proc_cir_ambu_notas");
				cdo.addColValue("nota", request.getParameter("nota"));

				if (request.getParameter("action") != null && request.getParameter("action").equalsIgnoreCase("I")) {
						cdo.addColValue("pac_id", pacId);
						cdo.addColValue("admision", noAdmision);
						cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
						cdo.addColValue("fecha_creacion", cDateTime);
						cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
						cdo.addColValue("fecha_modificacion", cDateTime);
						cdo.addColValue("cod_header", code);

						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						SQLMgr.insert(cdo);
						ConMgr.clearAppCtx(null);

				} else {
						cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision"));
						cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
						cdo.addColValue("fecha_modificacion", cDateTime);

						ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						SQLMgr.update(cdo);
						ConMgr.clearAppCtx(null);
				}

				errorCode = SQLMgr.getErrCode();
				errorMsg = SQLMgr.getErrMsg();
		}
%>
<html>
<head>
<script>
function closeWindow(){
<% if (errorCode.equals("1")) { %>
	alert('<%=errorMsg%>');
<%
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
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>&tab=<%=tab%>&cds=<%=cds%>&estado=<%=estado%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
