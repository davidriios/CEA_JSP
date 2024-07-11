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

	sbSql.append("select a.codigo, a.descripcion, decode(b.cod_eval,null,'I','U') as action, b.valor, b.observacion from tbl_sal_transpl_params a, tbl_sal_protocolo_transplante b where a.estado = 'A' and a.codigo = b.cod_eval(+) and b.pac_id(+) = ");
	sbSql.append(pacId);
	sbSql.append(" and b.admision(+) = ");
	sbSql.append(noAdmision);
	sbSql.append(" and b.codigo(+) = ");
	sbSql.append(code);
	sbSql.append(" order by a.orden");
	al = SQLMgr.getDataList(sbSql.toString());

		ArrayList alH = SQLMgr.getDataList("select distinct codigo, to_char(fecha_creacion, 'dd/mm/yyyy') fc, to_char(fecha_creacion, 'hh12:mi am') hc, usuario_creacion from tbl_sal_protocolo_transplante where pac_id = "+pacId+" and admision = "+noAdmision+" order by 1 desc");

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

	$("#imprimir").click(function(e){
		e.preventDefault();
		var fc = $("#fc<%=code%>").val();
		var uc = $("#uc<%=code%>").val();
		abrir_ventana("../expediente3.0/print_protocolo_transplante.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=code%>&fecha_creacion="+fc+"&usuario_creacion="+uc);
	});
});

function setEscala(code){
		window.location = '../expediente3.0/exp_protocolo_transplante.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&fg=<%=fg%>&code='+code;
}
function add(){window.location = '../expediente3.0/exp_protocolo_transplante.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&code=0&fg=<%=fg%>';}

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




<!--fin tabla de boton imprimir-->
<table cellspacing="0" class="table table-small-font table-bordered table-striped table-hover">
<thead>
<tr class="bg-headtabla" >
		<td>LISTA DE VERFICACION DE TRANSPLANTE</td>
		<td align="center">SI</td>
		<td align="center">NO</td>
</tr>
</thead>

<tbody>
<% for (int i = 0; i<al.size(); i++){%>
<%
 cdo = (CommonDataObject) al.get(i);
%>
<tr>
		<td align="left"><label><%=cdo.getColValue("descripcion")%></label></td>
		<td align="center"><label><%=fb.radio("valor"+i,"1",cdo.getColValue("valor").equals("1"),viewMode,false,"",null,null)%></label></td>
		<td align="center"><label><%=fb.radio("valor"+i,"0",cdo.getColValue("valor").equals("0"),viewMode,false,"",null,null)%></label></td>
</tr>
<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
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

		CommonDataObject cdoId = SQLMgr.getData("select nvl(max(codigo),0) + 1 as nextId from tbl_sal_protocolo_transplante where pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));

		nextId = cdoId.getColValue("nextId");

		for (int i=0; i<size; i++) {
				cdo = new CommonDataObject();
				cdo.setTableName("tbl_sal_protocolo_transplante");

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
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&fg=<%=fg%>&code=<%=nextId%>';}
</script>
</head>
<body onLoad="closeWindow()"></body>
</html>
<% } %>
