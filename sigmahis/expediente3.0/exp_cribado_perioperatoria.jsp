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
<jsp:useBean id="iAlergia" scope="session" class="java.util.Hashtable" />
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
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String codigo = request.getParameter("codigo");

if (codigo == null) codigo = "0";
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
		if (codigo.equals("0")) {
				cdo = SQLMgr.getData("select codigo from tbl_sal_cribado_periope where pac_id = "+pacId+" and admision = "+noAdmision+" and fecha_creacion = (select max(fecha_creacion) from tbl_sal_cribado_periope where pac_id = "+pacId+" and admision = "+noAdmision+")");

				if (cdo == null) cdo = new CommonDataObject();
				if (!cdo.getColValue("codigo"," ").trim().equals("")) codigo = cdo.getColValue("codigo");
		}

	sql = "select a.codigo, a.pregunta, b.observacion, b.cod_plan, decode(b.cod_plan,null,'N','S') aplicado, decode(b.cod_plan,null,'I','U') action, b.aplicar, a.pregunta_secundaria_cuando, a.pregunta_secundaria, b.aplicar_secundario from tbl_sal_preguntas_cribado a, tbl_sal_cribado_periope_det b where a.estado = 'A' and a.codigo = b.tipo_pregunta(+) and b.pac_id(+) = "+pacId+" and b.admision(+) = "+noAdmision+" order by a.orden ";
	al = SQLMgr.getDataList(sql);

%>
		<!DOCTYPE html>
		<html lang="en">
		<!--comienza el head-->
		<head>
		<meta charset="utf-8">
		<title>Expediente Cellbyte</title>
		<%@ include file="../common/nocache.jsp"%>
		<%@ include file="../common/header_param_bootstrap.jsp"%>
		<script>
		var noNewHeight = true;
document.title = 'EXPEDIENTE - Antecedente Alergico - '+document.title;
function doAction(){newHeight();}
function imprimirExp(){abrir_ventana('../expediente3.0/print_cribado_perioperatoria.jsp?pacId=<%=pacId%>&seccion=<%=seccion%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo=<%=codigo%>');}

$(function(){
	$("input[name*='aplicar']").click(function(){
		var i = this.name.replace ( /[^\d.]/g, '' );
		$("#observacion"+i).prop("readOnly", false);
	});

	$(".aps").click(function(e) {
			var i = this.name.replace ( /[^\d.]/g, '');
			var aplicar = $("#aplicar"+i+":checked").val();
			var cuando = $("#pregunta_secundaria_cuando"+i).val();
			if (aplicar == cuando) {}
			else {
				e.preventDefault();
				return false
			}
	});

	 $(".aplicar").click(function(e) {
			var i = this.name.replace ( /[^\d.]/g, '');
			var cuando = $("#pregunta_secundaria_cuando"+i).val();
			if (this.value == cuando) {} else $(".aplicar_secundario"+i).prop({checked: false})
	});
});
</script>
		</head>
		<!--termina el head-->

		<!--comienza el cuerpo del sitio-->
		<body class="body-form">

				<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
		<!--INICIO de una fila de elementos-->
		<div class="row">
		<!--INICIO de una fila de elementos-->

		<div class="table-responsive" data-pattern="priority-columns">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("total",""+al.size())%>


		<!--tabla de boton imprimit-->
				<div class="headerform">
		<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
		<tr>
		<td><%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:imprimirExp()\"")%></td>
		</tr>
		</table>
				</div>
		<!--fin tabla de boton imprimit-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<thead>
		<tr class="bg-headtabla" >
				<th>Aspectos a evaluar</th>
				<th>Si</th>
				<th>No</th>
				<!--<th>Observación</th>-->
		</tr>
		</thead>

		<tbody>

		<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

		if (codigo.equals("0")) cdo.addColValue("aplicar","N");

%>
		<%=fb.hidden("tipo_pregunta"+i, cdo.getColValue("codigo"))%>
		<%=fb.hidden("action"+i, cdo.getColValue("action"))%>
		<%=fb.hidden("cod_plan"+i, cdo.getColValue("cod_plan"))%>

				<tr>
			<td>
				<%=cdo.getColValue("pregunta")%>
				<%if(!cdo.getColValue("pregunta_secundaria", " ").trim().equals("")){%>
					<br>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("pregunta_secundaria")%>
				<%}%>
		 </td>
			<td>
				<%=fb.radio("aplicar"+i,"S",(cdo.getColValue("aplicar").equalsIgnoreCase("S")),viewMode,false,"aplicar","","")%>

				<%if(!cdo.getColValue("pregunta_secundaria", " ").trim().equals("")){%>
					<br><%=fb.radio("aplicar_secundario"+i,"S",(cdo.getColValue("aplicar_secundario", " ").equalsIgnoreCase("S")),viewMode,false,"aps aplicar_secundario"+i,"","")%>
					<%=fb.hidden("pregunta_secundaria_cuando"+i, cdo.getColValue("pregunta_secundaria_cuando"))%>
				<%}%>
			</td>
			<td>
				<%=fb.radio("aplicar"+i,"N",(cdo.getColValue("aplicar").equalsIgnoreCase("N")),viewMode,false,"aplicar","","")%>

				<%if(!cdo.getColValue("pregunta_secundaria", " ").trim().equals("")){%>
					<br><%=fb.radio("aplicar_secundario"+i,"N",(cdo.getColValue("aplicar_secundario", " ").equalsIgnoreCase("N")),viewMode,false,"aps aplicar_secundario"+i,null,"")%>
				<%}%>
			</td>
			<!--<td align="left"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode||cdo.getColValue("observacion"," ").trim().equals(""),50,1,2000,"form-control input-sm","width='100%'",null)%></td>-->
		</tr>

				<%}%>

		</tbody>
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

		<!-- FIN contenido del sitio aqui-->
		</div>
		<!-- FIN contenido del sitio aqui-->


		<!-- FIN Cuerpo del sitio -->
		</body>
		<!-- FIN Cuerpo del sitio -->


		</html>
		<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("total"));
	al.clear();

		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_cribado_periope");

		if (request.getParameter("codigo") != null && !request.getParameter("codigo").equals("") && !request.getParameter("codigo").equals("0")) {

				cdo.addColValue("fecha_modificacion",cDateTime);
				cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
				cdo.setAction("U");
				cdo.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and codigo = "+codigo);
		} else {
				CommonDataObject cdo1 = SQLMgr.getData("select nvl(max(codigo),0) + 1 nextid from tbl_sal_cribado_periope where pac_id = "+pacId+" and admision = "+noAdmision);

				codigo = cdo1.getColValue("nextid");

				cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_creacion", cDateTime);
				cdo.addColValue("pac_id", pacId);
				cdo.addColValue("admision", noAdmision);
				cdo.addColValue("codigo", codigo);
				cdo.setAction("I");
		}

	for (int i = 0; i < size; i++)
	{
				CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_sal_cribado_periope_det");

						if (request.getParameter("aplicar"+i)!= null){

								if (request.getParameter("cod_plan"+i) != null && !request.getParameter("cod_plan"+i).equals("") && !request.getParameter("cod_plan"+i).equals("0")) {
										cdo2.setAction("U");
										cdo2.setWhereClause("pac_id = "+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision")+" and cod_plan = "+request.getParameter("cod_plan"+i)+" and tipo_pregunta = "+request.getParameter("tipo_pregunta"+i));
								} else {
										cdo2.setAction("I");
										cdo2.addColValue("pac_id", pacId);
										cdo2.addColValue("admision", noAdmision);
										cdo2.addColValue("cod_plan", codigo);
										cdo2.addColValue("tipo_pregunta", request.getParameter("tipo_pregunta"+i));
								}

								cdo2.addColValue("observacion", request.getParameter("observacion"+i));
								cdo2.addColValue("aplicar", request.getParameter("aplicar"+i));
								cdo2.addColValue("aplicar_secundario", request.getParameter("aplicar_secundario"+i));

								System.out.println("...................................... aplicar_secundario = "+request.getParameter("aplicar_secundario"+i));

								al.add(cdo2);
						}

	}//for

	if (al.size() == 0)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_cribado_periope_det");
		cdo.setWhereClause("pac_id = "+request.getParameter("pacId"));
		cdo.setAction("I");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.save(cdo, al, true ,true, true, true);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&codigo=<%=codigo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
