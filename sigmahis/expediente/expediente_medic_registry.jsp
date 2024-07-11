<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String estado = request.getParameter("estado");
String estadoAdm = request.getParameter("estadoAdm");
String expId = request.getParameter("expId");

if (mode == null) mode = "add";
if (estadoAdm == null) estadoAdm = "";
if (expId == null) expId = "";

String expVersion = "1";
try { expVersion = java.util.ResourceBundle.getBundle("issi").getString("expediente.version"); } catch (Exception e) { }

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

	String medicoNew = "";
	String registroNew = "";
	if (UserDet.getRefType().equalsIgnoreCase("M")) {
		sbSql.append("select nvl(reg_medico,codigo) as reg_medico from tbl_adm_medico where codigo = '");
		sbSql.append(IBIZEscapeChars.forSingleQuots(UserDet.getRefCode()));
		sbSql.append("'");
		cdo = SQLMgr.getData(sbSql.toString());
		if (cdo != null) {
			medicoNew = UserDet.getRefCode();
			registroNew = cdo.getColValue("reg_medico");
		}
	}

	String estadoAtencion = "";
	sbSql = new StringBuffer();
	sbSql.append("select estado from tbl_adm_atencion_cu where pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and secuencia = ");
	sbSql.append(noAdmision);
	cdo = SQLMgr.getData(sbSql.toString());
	if (cdo != null) estadoAtencion = cdo.getColValue("estado");

	sbSql = new StringBuffer();
	sbSql.append("select a.medico, (select nvl(reg_medico,codigo) from tbl_adm_medico where codigo = a.medico) as reg_medico, (select cambia_otro from tbl_adm_medico where codigo = a.medico) as cambia_otro, b.primer_nombre||decode(b.segundo_nombre,null,'',' '||b.segundo_nombre)||decode(b.primer_apellido,null,'',' '||b.primer_apellido)||decode(b.segundo_apellido,null,'',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,'',' '||b.apellido_de_casada)) as nombrePaciente from tbl_adm_admision a, tbl_adm_paciente b where a.pac_id = b.pac_id and a.pac_id = ");
	sbSql.append(pacId);
	sbSql.append(" and a.secuencia = ");
	sbSql.append(noAdmision);
	cdo = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title='Registro Médico - '+document.title;

function validateRegistry(registro){
	if(registro.value.trim()!=''){
		var c=splitCols(getDBData('<%=request.getContextPath()%>','codigo, nvl(reg_medico,codigo) as reg_medico, decode(sexo,\'F\',\'DRA. \',\'M\',\'DR. \')||primer_nombre||decode(segundo_nombre,null,\'\',\' \'||segundo_nombre)||\' \'||primer_apellido||decode(segundo_apellido,null,\'\',\' \'||segundo_apellido)||decode(sexo,\'F\',decode(apellido_de_casada,null,\'\',\' \'||apellido_de_casada)) as nombreMedico','tbl_adm_medico','nvl(reg_medico,codigo) = \''+registro.value+'\''));
		if(c==null){
			alert('Este Registro Médico no existe en la Base de Datos,  verifique...');
			registro.value='';
			document.form1.medico_new.value='';
		}else{
			document.form1.medico_new.value=c[0];
			window.document.getElementById('medicRecord').innerHTML='['+c[1]+'] ';
			window.document.getElementById('medicName').innerHTML=c[2];
		}
	}
}

function validateMedic(){
	var medicoNew=document.form1.medico_new.value.trim();
	var estadoAdm=document.form1.estadoAdm.value;
	var expId=document.form1.expId.value;
	if(medicoNew==''){
		alert('Por favor introduzca el registro médico!');
		document.form1.registro_new.focus();
	}else{
		if(document.form1.cambia_otro.value.trim()=='N'&&document.form1.medico.value.trim()!=medicoNew){
			alert('Sr. Usuario: Este expediente fue abierto por otro Médico!');
			medicoNew=document.form1.medico.value.trim();//keep the same medic
		}
		<% if (expVersion.equalsIgnoreCase("2")) { %>
		var page='../expediente/expediente_iconificado.jsp';
		<% } else if (expVersion.equalsIgnoreCase("3")) { %>
		var page='../expediente3.0/expediente.jsp';
		<% } else { %>
		var page='../expediente/expediente_config.jsp';
		<% } %>
<% if (expVersion.equalsIgnoreCase("3")) { %>
		CBMSG.confirm("Recuerde que <%=_comp.getNombreCorto().trim().equals("")?_comp.getNombre():_comp.getNombreCorto()%>, maneja estricta confidencialidad con la información de nuestros pacientes. Toda Actividad en el Expediente Clínico será monitoreada. ¿Desea continuar?",{
			btnTxt:'Si,No',
			cb:function(r){
				if(r=='Si'){
<% } %>
					if(estadoAdm=='I'||estadoAdm=='N'){
						CBMSG.confirm("La admisión del Expediente #"+expId+" tiene estado Anulado/Inactivo. Desea Continuar con el proceso?",{
							btnTxt:'Si,No',
							cb: function(r){
								if(r=='Si'){
									if(executeDB('<%=request.getContextPath()%>','call exp_iniciar_atencion(<%=pacId%>,<%=noAdmision%>,\''+medicoNew+'\')','')){
										window.opener.abrir_ventana(page+'?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=cds%>&estado=<%=estado%>');
										window.opener.reloadPage();
										closeWin();
									}else CBMSG.alert('No se pudo iniciar la atención debido a un error interno.\nPor favor consulte con su Administrador!');
								}
							}
						});
					}else{
						if(executeDB('<%=request.getContextPath()%>','call exp_iniciar_atencion(<%=pacId%>,<%=noAdmision%>,\''+medicoNew+'\')','')){
							window.opener.abrir_ventana(page+'?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&cds=<%=cds%>&estado=<%=estado%>');
							window.opener.reloadPage();
							closeWin();
						}else CBMSG.alert('No se pudo iniciar la atención debido a un error interno.\nPor favor consulte con su Administrador!');
					}
<% if (expVersion.equalsIgnoreCase("3")) { %>
				}
			}
		});
<% } %>
	}
}

jQuery(document).ready(function(){
	<% if (expVersion.equalsIgnoreCase("2")) { %>
	var page='../expediente/expediente_iconificado.jsp';
	<% } else if (expVersion.equalsIgnoreCase("3")) { %>
	var page='../expediente3.0/expediente.jsp';
	<% } else { %>
	var page='../expediente/expediente_config.jsp';
	<% } %>
<% if (estadoAtencion.equalsIgnoreCase("F")) { %>
	window.opener.abrir_ventana(page+'?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=view&cds=<%=cds%>');
	closeWin();
<% } else { %>
	validateRegistry(document.form1.registro_new);
<% } %>
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - REGISTRO MEDICO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("medico",cdo.getColValue("medico"))%>
<%=fb.hidden("reg_medico",cdo.getColValue("reg_medico"))%>
<%=fb.hidden("cambia_otro",cdo.getColValue("cambia_otro"))%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("estadoAdm",estadoAdm)%>
<%=fb.hidden("expId",expId)%>

		<tr class="TextRow02">
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2"><cellbytelabel id="1">Paciente a Atender</cellbytelabel>: <b><%=cdo.getColValue("nombrePaciente")%></b></td>
		</tr>
		<tr class="TextRow01">
			<td width="80%"><cellbytelabel id="2">Introduzca su registro m&eacute;dico para iniciar la atenci&oacute;n</cellbytelabel>:</td>
			<td width="20%"><%=fb.hidden("medico_new",medicoNew)%><%=fb.textBox("registro_new",registroNew,true,false,false,15,15,null,null,"onBlur=\"javascript:validateRegistry(this)\"")%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="2" align="center">&nbsp;<b><label id="medicRecord"></label><label id="medicName"></label></b></td>
		</tr>
		<tr class="TextRow02">
			<td align="right" colspan="2">
				<%=fb.button("save","Aceptar",true,false,null,null,"onClick=\"javascript:validateMedic()\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
			</td>
		</tr>
<%=fb.formEnd()%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>
	</td>
</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
%>