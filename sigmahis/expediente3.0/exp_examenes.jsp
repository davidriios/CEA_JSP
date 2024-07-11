<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
sal310150
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
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fp = request.getParameter("fp");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String interfaz = request.getParameter("interfaz");
String medico = request.getParameter("medico");
String from = request.getParameter("from");
String usaPerfilCpt = "N";
try {usaPerfilCpt =java.util.ResourceBundle.getBundle("issi").getString("usaPerfilCpt");}catch(Exception e){ usaPerfilCpt = "N";}
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (fp == null) fp = "imagenologia";
//if (cds == null) throw new Exception("El Centro de Servicio no es válido. Por favor intente nuevamente!");
String docTitle = "";
String title = "";
if (medico == null) medico = "";
if (from == null) from = "";
if (fp.equalsIgnoreCase("imagenologia"))
{
	docTitle = "Imagenolog&iacute;a";
	title = "EXAMENES IMAGENOLOGIA";
	interfaz = "RIS";
}
else if (fp.equalsIgnoreCase("laboratorio"))
{
	docTitle = "Laboratorio";
	title = "EXAMENES LABORATORIO";
	interfaz = "LIS";
}
else if (fp.equalsIgnoreCase("BDS"))
{	
	docTitle = "Banco de Sangre";
	title = "EXAMENES BANCO DE SANGRE";
	interfaz = "BDS";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	HashDet.clear();
	int pending = CmnMgr.getCount("select count(*) from tbl_sal_ficha_procedimiento z where interfaz = '"+interfaz+"' and exists (select null from tbl_adm_admision where pac_id = z.pac_id and secuencia = z.admision and pac_id = "+pacId+" and adm_root = "+noAdmision+")");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
document.title = 'EXPEDIENTE - Exámenes de <%=docTitle%> - '+document.title;
function doAction(){setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function showProcedimientos(examen)
{
	var xCds = document.form001.xCds.value;
	if (xCds != "") if(document.form001.profile)document.form001.profile.value = "";
	if(examen==undefined||examen==null) window.frames['iExaLab'].location = '../expediente3.0/exp_examenes_list.jsp?fp=<%=fp%>&seccion='+<%=seccion%>+'&pacId='+<%=pacId%>+'&noAdmision=<%=noAdmision%>&xCds='+xCds+'&cds=<%=cds%>';
	else
	{
		/*if(xCds!='') */window.frames['iExaLab'].location = '../expediente3.0/exp_examenes_list.jsp?fp=<%=fp%>&seccion='+<%=seccion%>+'&pacId='+<%=pacId%>+'&noAdmision=<%=noAdmision%>&xCds='+xCds+'&examen='+examen+'&cds=<%=cds%>';
		//else alert('Por favor seleccione un Centro de Servicio antes de ejecutar la búsqueda!');
	}
}

function ctrlProfile(obj){
	 var profile = document.getElementById("profile").value;
	 var selectedVal = "";
	 if (profile != "") {
			document.form001.xCds.value = "";
			selectedVal = obj.options[obj.selectedIndex].text;
	 }
	 window.frames['iExaLab'].location = '../expediente3.0/exp_examenes_list.jsp?fp=<%=fp%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&profileCPT='+profile+'&cds=<%=cds%>&selectedVal='+selectedVal;
}

function showMedicList()
{
	abrir_ventana1('../common/search_medico.jsp?fp=<%=fp%>');
}

function doSubmit()
{
	if(form001Validation())
	{
		if(confirm('¿Está seguro que desea generar la Orden Médica?\nNOTA: Las Ordenes Incompletas se solicitarán junto con las actuales, si no desea que sean procesados deberá cancelarlos!'))
		{
			setBAction('form001','Solicitar');
			document.form001.admMedico.value =
<%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%>;
			if(document.getElementById('iExaLab').src!='')window.frames['iExaLab'].doSubmit();
		}
		else
		{
			window.location.reload(true);
			//showCDSList('');
			return false;
		}
	}
	else
	{
		form001BlockButtons(false);
		return false;
	}
}

function setFormaSolicitud(val){document.form001.formaSolicitud.value=val;}

function setExtraccion(val)
{
	document.form001.extraccion.value=val;
}

function goResults()
{
	abrir_ventana1('../expediente/exp_examen_estudios.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>');
}

function goPrevious()
{
	abrir_ventana1('../expediente/exp_examen_estudios.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&type=previous');
}

function goPending()
{
	abrir_ventana1('../expediente/exp_examen_pending.jsp?mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>');
}

function imprimir(){
	//abrir_ventana('../expediente/print_exp_seccion_19.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&interfaz=<%=interfaz%>');
	abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=1&interfaz=<%=interfaz%>');
}
function hasPending(){alert('Existen Estudios Pendientes por Solicitar!\nNOTA: Las Ordenes Incompletas se solicitarán junto con las actuales, si no desea que sean procesados deberá cancelarlos.');goPending();}



</script>
<style type="text/css">
<!--
.RedAlert {color: #ff0000; font-weight:bold; !important;}
-->
</style>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script> 
</head>
<body  class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
		<table cellspacing="0" class="table pull-right table-striped table-custom-1" style="text-align: right !important;">
		<tr>
		<td align="left"><% if (pending > 0) { %><a href="javascript:goPending()" class="RedAlert">Existen Ordenes Incompletas por Solicitar!</a><script>hasPending();</script><% } %></td>
		<td>
	<%fb = new FormBean("form001",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<% if (!fp.equalsIgnoreCase("BDS")) { %>
	<%=fb.button("resultsTop","Estudios y Resultados",true,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:goResults()\"","Estudios y Resultados")%>
				<%=fb.button("previousTop","Resultados Previos",true,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:goPrevious()\"","Resultados Previos")%>
<% } %>
				<%=fb.button("pendingTop","Orden Médica Incompleta",true,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:goPending()\"","Estudios Pendientes")%>

	<button type="button" class="btn btn-inverse btn-sm" onClick="imprimir()"><i class="material-icons fa-printico">print</i> <b>Consulta</b></button></td>
		</tr>
		</table>
				</div>

<table class="table table-bordered table-striped">
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("formaSolicitud","P")%>
<%=fb.hidden("extraccion",(fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("BDS"))?"S":"N")%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("admMedico",medico)%>
<%=fb.hidden("from",from)%>
		<tr>
			<td width="20%"><%=docTitle%></td>
			<td width="30%" class="controls form-inline">
<%
			String tipo = "";
			if (fp.equalsIgnoreCase("imagenologia")) {
				sql = "select codigo, descripcion, estado,cod_centro_sol_lis centroSol from tbl_cds_centro_servicio where estado in ('A','I') and reporta_a  in(select codigo from tbl_cds_centro_servicio where interfaz='RIS') and compania_unorg="+(String) session.getAttribute("_companyId")+" order by descripcion";
				tipo = "I";
			}else if (fp.equalsIgnoreCase("laboratorio")) {
				sql = "select codigo, codigo||'-'||descripcion, estado,cod_centro_sol_lis centroSol from tbl_cds_centro_servicio where estado in ('A','I') and reporta_a  in(select codigo from tbl_cds_centro_servicio where interfaz='LIS') and compania_unorg ="+(String) session.getAttribute("_companyId")+"order by descripcion";
				tipo = "L";
			}else if (fp.equalsIgnoreCase("BDS")) {
				sql = "select codigo, codigo||'-'||descripcion, estado,cod_centro_sol_lis centroSol from tbl_cds_centro_servicio where estado in ('A','I') and reporta_a  in(select codigo from tbl_cds_centro_servicio where interfaz='BDS') and compania_unorg ="+(String) session.getAttribute("_companyId")+"order by descripcion";
				tipo = "B";
			}

			%>
				<%=fb.select(ConMgr.getConnection(),sql,"xCds","",false,false,0,"form-control input-sm","","onChange=\"javascript:showProcedimientos();\"", "","S")%>
			</td>
			<td colspan="2" class="controls form-inline">
				<%if (usaPerfilCpt.trim().equals("S")){%>
				Perfil CPT
				<%=fb.select(ConMgr.getConnection(),"select id, nombre from tbl_cdc_cpt_profile where estado = 'A' and tipo = '"+tipo+"' ","profile","",false,false,0,"form-control input-sm","","onChange=\"javascript:ctrlProfile(this);\"", "","S")%>
				<%}%>
				&nbsp;
			</td>
		</tr>
		<%

			%>
		<!--<tr class="TextRow01">
			<td><cellbytelabel id="2">M&eacute;dico Solicitante</cellbytelabel></td>
			<td colspan="3" class="controls form-inline">
				<%//=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,80,"form-control input-sm","","")%>
								<button type="button" class="btn btn-sm btn-inverse" onClick="showMedicList()" id="btnMed" name="btnMed"<%=viewMode?" disabled":""%>><i class="fa fa-ellipsis-h fa-printico"></i></button>
						</td>
		</tr>-->
		<tr class="TextRow01">
			<td  colspan="4" class="controls form-inline"><cellbytelabel id="3">Forma de Solicitud</cellbytelabel>&nbsp;&nbsp;
				<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
				<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>&nbsp;&nbsp;&nbsp;Usuario que Recibe, Transcribe, lee y Confirma:
					<%=fb.textBox("userCrea",UserDet.getName(),true, false,true,15,"form-control input-sm","","")%>
				&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante
				<%=fb.hidden("codigoMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getRefCode():"")%>
				<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,25,"form-control input-sm","","")%>
								<button type="button" class="btn btn-sm btn-inverse" onClick="showMedicList()" id="btnMed" name="btnMed"<%=viewMode?" disabled":""%>><i class="fa fa-ellipsis-h fa-printico"></i></button>
				</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="<%=(fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("BDS"))?3:2%>" align="right" class="controls form-inline">
<% if (fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("BDS")) { %>
<%=fb.radio("extraccionX","S",true,viewMode,false,null,null,"onClick=\"javascript:setExtraccion(this.value)\"")%> <cellbytelabel>Extraer Muestra</cellbytelabel>&nbsp;&nbsp;
<%=fb.radio("extraccionX","N",false,viewMode,false,null,null,"onClick=\"javascript:setExtraccion(this.value)\"")%> <cellbytelabel>Utilizar Muestra Extra&iacute;da</cellbytelabel>
&nbsp;&nbsp;&nbsp;
<% } %>
				<%=fb.textBox("examen","",false,false,viewMode,45,"form-control input-sm","","")%>
				<%//=fb.button("btnBuscar","Buscar",true,viewMode,null,null,"onClick=\"javascript:showProcedimientos(document.form001.examen.value)\"")%>

								<button type="button" class="btn btn-inverse btn-sm" onClick="showProcedimientos(document.form001.examen.value)"<%=viewMode?" disabled":""%>><i class="material-icons fa-printico">search</i> <b>Buscar</b></button>
			</td>
			<td colspan="<%=(fp.equalsIgnoreCase("laboratorio")||fp.equalsIgnoreCase("BDS"))?1:2%>" align="right">
<% if (fp.equalsIgnoreCase("imagenologia")) { %><strong><cellbytelabel id="8">S&oacute;lo se solicitar&aacute;n los ex&aacute;menes con sospechas</cellbytelabel></strong><% } %>
				<%=fb.button("saveTop","Generar Orden Médica",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:doSubmit()\"","Solicitar")%>
				<%=fb.button("cancelTop","Cancelar",true,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"","Cancelar")%>			</td>
		</tr>
		<tr>
			<td colspan="4">
			<iframe id="iExaLab" name="iExaLab" width="100%" height="300px" scrolling="yes" frameborder="0" src="../expediente3.0/exp_examenes_list.jsp?fp=<%=fp%>&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
<% if (fp.equalsIgnoreCase("imagenologia")) { %><strong><cellbytelabel id="8">S&oacute;lo se solicitar&aacute;n los ex&aacute;menes con sospechas</cellbytelabel></strong><% } %>
				<%=fb.button("saveBottom","Generar Orden Médica",true,viewMode,"btn btn-inverse btn-sm",null,"onClick=\"javascript:doSubmit()\"","Solicitar")%>
				<%=fb.button("cancelBottom","Cancelar",true,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"","Cancelar")%>			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>

</div>
</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = "O";//N=Create New,O=Keep Open,C=Close
	if (!request.getParameter("errCode").trim().equals(""))
	{
		SQLMgr.setErrCode(request.getParameter("errCode"));
		SQLMgr.setErrMsg(request.getParameter("errMsg"));
	}
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
	alert('La Orden Médica fue generada satisfactoriamente!');<%//=SQLMgr.getErrMsg()%>
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
	//window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&from=<%=from%>&medico=<%=medico%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&from=<%=from%>&medico=<%=medico%>';
}


/*function getSelProc(p){
	var selProc = "";
	var fram = documtn
			 if(window.frames["iExaLab"].form0.document.getElementsByTagName("valor"+p).checked){
						 var selProc = selProc + window.frames["iExaLab"].form0.document.getElementsByTagName("valor"+p).value;
			 }
	alert(selProc);
}*/





//Testing function ----------------------------------------
function getSelProc(p){
	var selProc = "";
			 if(document.getElementById("iExaLab").contentWindow.document.getElementsByTagName("valor"+p).checked){
						 var selProc = selProc + document.getElementById("iExaLab").contentWindow.document.getElementsByTagName("valor"+p).value;
			 }
	//alert(selProc);
}
//--------------------------------------------------------

</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
