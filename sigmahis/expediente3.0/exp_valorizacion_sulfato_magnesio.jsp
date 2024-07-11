<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.expediente.Escalas"%>
<%@ page import="issi.expediente.DetalleEscala"%>
<%@ page import="java.util.Vector" %>
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
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String desc = request.getParameter("desc");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec == null) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (id == null) id = "0";
if (fg == null) fg = "";
if (desc == null) desc = "";

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cDate = cDateTime.substring(0,10);

if (request.getMethod().equalsIgnoreCase("GET")) {

al = SQLMgr.getDataList("select codigo, usuario_creacion as usuario, usuario_modificacion as usuarioMod, to_char(fecha_modificacion, 'dd/mm/yyyy hh12:mi:ss am') fechaMod, to_char(fecha_creacion, 'dd/mm/yyyy') fecha, to_char(fecha_modificacion, 'hh12:mi:ss am') hora from tbl_sal_val_criterios_sulfa_mg where pac_id = "+pacId+" and admision = "+noAdmision+" order by codigo desc");

if (!id.trim().equals("0")) {
		cdo = SQLMgr.getData("select to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, cefalea, fosfenos, tinitus, espigastralgia, estado_conciencia, reflejos_rot, observacion, p_a, tmp as temp, f_c, f_r, f_c_f, orina from tbl_sal_val_criterios_sulfa_mg where pac_id = "+pacId+" and admision = "+noAdmision+" and codigo = "+id);
}

if(cdo == null) cdo = new CommonDataObject();
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
		<jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
<script>
var noNewHeight = true;
document.title = 'VALORIZACION - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function add(){window.location = '../expediente3.0/exp_valorizacion_sulfato_magnesio.jsp?mode=<%=mode%>&modeSec=add&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=0&fg=<%=fg%>&desc=<%=desc%>';}
function doAction(){checkViewMode();}

function verHistorial() {
	$("#hist_container").toggle();
}

function canSubmit () {
		var proceed = true;

		return proceed;
}

function verEval(codigo) {
		window.location = '../expediente3.0/exp_valorizacion_sulfato_magnesio.jsp?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id='+codigo+'&fg=<%=fg%>&desc=<%=desc%>';
}

function imprimir(option) {
		var code = option ? '0' : '<%=id%>';
		abrir_ventana('../expediente3.0/print_valorizacion_sulfato_magnesio.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code='+code+'&fg=<%=fg%>&desc=<%=desc%>&seccion=<%=seccion%>');
}

$(function(){
		$("#btn_sv").click(function(){
				var fecha = $("#fecha_creacion").val();
				var url = encodeURI('../expediente3.0/exp_triage.jsp?modeSec=&mode=&fg=SV&seccion=77&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=&desc=SIGNO VITALES&from=val_sulfato&fecha_hora_eval='+fecha);
				abrir_ventana(url);
		});

		$("#btn_bh").click(function(){
				var fecha = $("#fecha_creacion").val();
				var a = getDBData('<%=request.getContextPath()%>','cantidad','tbl_sal_detalle_balance z',"z.pac_id = <%=pacId%> and adm_secuencia = <%=noAdmision%> and via_administracion = 6 and to_date('"+fecha.substr(0,10)+"','dd/mm/yyyy') >=fecha and to_date('"+fecha.substr(11)+"','hh12:mi:ss am') >= hora and fecha = (select max(fecha) from tbl_sal_detalle_balance where pac_id = <%=pacId%> and adm_secuencia = <%=noAdmision%> and via_administracion = 6 and to_date('"+fecha.substr(0,10)+"','dd/mm/yyyy') >= fecha and to_date('"+fecha.substr(11)+"','hh12:mi:ss am') >= hora) and hora = (select max(hora) from tbl_sal_detalle_balance where pac_id = <%=pacId%> and adm_secuencia = <%=noAdmision%> and via_administracion = 6 and to_date('"+fecha.substr(0,10)+"','dd/mm/yyyy') >= fecha and to_date('"+fecha.substr(11)+"','hh12:mi:ss am') >= hora)",'');

				if (a) $("#orina").val(a);
		});
});
</script>
</head>

<body class="body-form">
<div class="row">

<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%fb.appendJsValidation("if(!canSubmit()) { error++; }");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fg", fg)%>
<%=fb.hidden("id", id)%>
<%=fb.hidden("desc", desc)%>

<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-2">
<tr>
<td class="controls form-inline">
		<%if(!mode.trim().equalsIgnoreCase("view")){%>
			<%=fb.button("btnAdd","Agregar",true,false,"btn btn-inverse btn-sm|fa fa-plus fa-printico",null,"onclick='add()'")%>
		<%}%>
		<%if(!id.trim().equals("0")){%>
			<%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimir()\"")%>
		<%}%>

		<%if(al.size() > 0){%>
			<%=fb.button("btnPrintAll","Imprimir Todo",false,false,"btn btn-inverse btn-sm|fa fa-print fa-printico",null,"onClick=\"javascript:imprimir(1)\"")%>
			<%=fb.button("btnHistory","Historial",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"onClick=\"javascript:verHistorial()\"")%>
		<%}%>
</td>
</tr>
</table>

<div class="table-wrapper" id="hist_container" style="display:none">
<table cellspacing="0" class="table table-small-font table-bordered table-striped">
<thead>
<tr><th colspan="7" class="bg-headtabla"><cellbytelabel>Listado de Evaluaciones</cellbytelabel></th>
<tr class="bg-headtabla2">
		<th><cellbytelabel>C&oacute;digo</cellbytelabel></th>
		<th><cellbytelabel>Fecha</cellbytelabel></th>
		<th><cellbytelabel>Hora</cellbytelabel></th>
		<th><cellbytelabel>Creado Por</cellbytelabel></th>
		<th><cellbytelabel>Modif. por</cellbytelabel></th>
		<th><cellbytelabel>Fecha/Hora Mod</cellbytelabel>.</th>
</tr>
<tbody>
<%
for (int i=1; i<=al.size(); i++)
{
	CommonDataObject cdo1 = (CommonDataObject) al.get(i-1);
	%>
		<tr class="pointer" onClick="javascript:verEval(<%=cdo1.getColValue("codigo")%>)">
						<td><%=cdo1.getColValue("codigo")%></td>
						<td><%=cdo1.getColValue("fecha")%></td>
						<td><%=cdo1.getColValue("hora")%></td>
						<td><%=cdo1.getColValue("usuario")%></td>
						<td><%=cdo1.getColValue("usuarioMod")%></td>
						<td><%=cdo1.getColValue("fechaMod")%></td>
		</tr>
<%
}
%>
</tbody>
</table>
</div>
 </div>

<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<tr>
				<td class="controls form-inline" colspan="5">
					 <b>SIGNOS VITALES</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					 <b>P/A:</b>&nbsp;<%=fb.textBox("p_a",cdo.getColValue("p_a"),false,false,true,3,15,"form-control input-sm",null,null)%>
					 &nbsp;&nbsp;&nbsp;
					 <b>F.C.:</b>&nbsp;<%=fb.textBox("f_c",cdo.getColValue("f_c"),false,false,true,3,15,"form-control input-sm",null,null)%>
					 &nbsp;&nbsp;&nbsp;
					 <b>F.R.:</b>&nbsp;<%=fb.textBox("f_r",cdo.getColValue("f_r"),false,false,true,3,15,"form-control input-sm",null,null)%>
					 &nbsp;&nbsp;&nbsp;
					 <b>Temp.:</b>&nbsp;<%=fb.textBox("temp",cdo.getColValue("temp"),false,false,true,3,15,"form-control input-sm",null,null)%>
					 &nbsp;&nbsp;&nbsp;
					 <b>F.C.F.:</b>&nbsp;<%=fb.textBox("f_c_f",cdo.getColValue("f_c_f"),false,false,true,3,15,"form-control input-sm",null,null)%>

					 &nbsp;&nbsp;
					 <%=fb.button("btn_sv"," ",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"")%>
				</td>
				<td colspan="2" class="controls form-inline">
						<b>B. HIDRICO</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					 <b>Diuresis Horaria:</b>&nbsp;<%=fb.textBox("orina",cdo.getColValue("orina"),false,false,true,6,15,"form-control input-sm",null,null)%>
					 &nbsp;&nbsp;
					 <%=fb.button("btn_bh"," ",false,false,"btn btn-inverse btn-sm|fa fa-eye fa-printico",null,"")%>
				</td>
		</tr>
		<tr class="bg-headtabla2">
				<td width="20%">Fecha/Hora</td>
				<td width="10%">Cefalea</td>
				<td width="10%">Fosfenos</td>
				<td width="10%">Tinitus</td>
				<td width="17%">Espigastralgia</td>
				<td width="17%">Estado Conciencia</td>
				<td width="16%">Reflejos ROT</td>
		</tr>

		<tr>
				<td class="controls form-inline">
						<jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox1" value="fecha_creacion" />
						<jsp:param name="format" value="dd/mm/yyyy hh12:mi:ss am" />
						<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_creacion", cDateTime)%>" />
						<jsp:param name="readonly" value="<%=(viewMode)?"y":"n"%>"/>
						</jsp:include>
				</td>
				<td>
						<%=fb.textBox("cefalea",cdo.getColValue("cefalea"),false,false,viewMode,3,15,"form-control input-sm",null,null)%>
				</td>
				<td>
						<%=fb.textBox("fosfenos",cdo.getColValue("fosfenos"),false,false,viewMode,3,15,"form-control input-sm",null,null)%>
				</td>
				<td>
						<%=fb.textBox("tinitus",cdo.getColValue("tinitus"),false,false,viewMode,3,15,"form-control input-sm",null,null)%>
				</td>
				<td>
						<%=fb.textBox("espigastralgia",cdo.getColValue("espigastralgia"),false,false,viewMode,3,15,"form-control input-sm",null,null)%>
				</td>
				<td>
						<%=fb.select("estado_conciencia","D=DESPIERTO,S=SEDADO,O=ORIENTADO,Z=OTROS",cdo.getColValue("estado_conciencia"),false,false,viewMode,0,"form-control input-sm","width:150px","",null,"S")%>
				</td>
				<td>
						<%=fb.select("reflejos_rot","S=SI,N=NO",cdo.getColValue("reflejos_rot"),false,false,viewMode,0,"form-control input-sm","width:100px","",null,"S")%>
				</td>
		</tr>

		<tr>
				<td colspan="9" class="controls form-inline">
						<b>Observaci&oacute;n:</b>
						<%=fb.textarea("observacion", cdo.getColValue("observacion"),false,false,viewMode,0,2,2000,"form-control input-sm","width:100%",null)%>
				</td>
		</tr>
</table>





<div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
				<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
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
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption")==null?"":request.getParameter("saveOption");
	String baction = request.getParameter("baction");

		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_val_criterios_sulfa_mg");
		cdo.addColValue("cefalea", request.getParameter("cefalea"));
		cdo.addColValue("fosfenos", request.getParameter("fosfenos"));
		cdo.addColValue("tinitus", request.getParameter("tinitus"));
		cdo.addColValue("espigastralgia", request.getParameter("espigastralgia"));
		cdo.addColValue("estado_conciencia", request.getParameter("estado_conciencia"));
		cdo.addColValue("reflejos_rot", request.getParameter("reflejos_rot"));
		cdo.addColValue("observacion", request.getParameter("observacion"));
		cdo.addColValue("p_a", request.getParameter("p_a"));
		cdo.addColValue("tmp", request.getParameter("temp"));
		cdo.addColValue("f_c", request.getParameter("f_c"));
		cdo.addColValue("f_r", request.getParameter("f_r"));
		cdo.addColValue("f_c_f", request.getParameter("f_c_f"));
		cdo.addColValue("orina", request.getParameter("orina"));

		if(modeSec.equalsIgnoreCase("add")) {
				cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_creacion", request.getParameter("fecha_creacion"));
				cdo.addColValue("fecha_modificacion", cDateTime);
				cdo.addColValue("pac_id", pacId);
				cdo.addColValue("admision", noAdmision);

				CommonDataObject cdoN = SQLMgr.getData("select nvl(max(codigo),0)+1 next_code from tbl_sal_val_criterios_sulfa_mg where pac_id = "+pacId+" and admision = "+noAdmision);
				if (cdoN == null) cdoN = new CommonDataObject();

				cdo.addColValue("codigo", cdoN.getColValue("next_code","0"));

		} else {
				cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and codigo = "+id);
		cdo.addColValue("fecha_creacion", request.getParameter("fecha_creacion"));
				cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_modificacion", cDateTime);
		}


	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(modeSec.trim().equalsIgnoreCase("add")){
				SQLMgr.insert(cdo);
				id = cdo.getColValue("codigo");
		}
		else {
				SQLMgr.update(cdo);
		}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equalsIgnoreCase("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>';
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
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&id=<%=id%>&fg=<%=fg%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>