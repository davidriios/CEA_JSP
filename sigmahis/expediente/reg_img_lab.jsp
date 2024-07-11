<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String pacienteId = request.getParameter("pacienteId");
String noAdmision = request.getParameter("noAdmision");
String codigo = request.getParameter("codigo");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
if(fg==null) fg = "sol_img_estudio";
String fp = request.getParameter("fp");
if(fp==null) fp = "sol_img_estudio";
boolean viewMode = false;
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		if(change==null){
			pacienteId = "0";
			noAdmision = "0";
		}
	}
	else if (mode.equalsIgnoreCase("view"))
	{
		if (pacienteId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");
		viewMode = true;
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Imagenología - '+document.title;

function removeItem(fName,k){
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue){
	document.forms[fName].baction.value = actionValue;
	window.frames['itemFrame'].doSubmit();
}

function showMedicoLista(){
	abrir_ventana1('../common/search_medico.jsp?fp=<%=fp%>&fg=<%=fg%>');
}

function doAction(){}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARGO O DEVOLUCION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Datos del Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pacienteId%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
							<jsp:param name="fp" value="<%=fp%>"></jsp:param>
							<jsp:param name="tr" value="<%=fg%>"></jsp:param>
							<jsp:param name="mode" value="<%=mode%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("pacienteId",pacienteId)%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextRow01">
							<td width="50%">&nbsp;<cellbytelabel id="2">&Aacute;rea</cellbytelabel>:&nbsp;
<%
sbSql = new StringBuffer();
sbSql.append("select codigo, codigo||' - '||descripcion from tbl_cds_centro_servicio where estado = 'A'");
if (fp.equalsIgnoreCase("sol_lab_estudio")) sbSql.append(" and interfaz='LIS'");
else sbSql.append(" and interfaz ='RIS' and recibe_solicitud = 'S'");
sbSql.append(" order by descripcion");
%>
								<%=fb.select(ConMgr.getConnection(),sbSql.toString(),"area","",false,false,0,null,null,"",null,"")%>
							</td>
							<td width="50%">&nbsp;<cellbytelabel id="3">M&eacute;dico</cellbytelabel>:&nbsp;
								<%=fb.textBox("medico","",true,false,true,10,"Text10",null,null)%>
								<%=fb.textBox("medicoDesc","",true,false,true,60,"Text10",null,null)%>
								<%=fb.button("btnMedico","...",true,false,null,"Text10","onClick=\"javascript:showMedicoLista();\"")%>
								<%
								//sql = "select m.codigo, decode(m.apellido_de_casada,null, m.primer_apellido||' '|| m.segundo_apellido||' '|| m.apellido_de_casada||' '|| m.primer_nombre||' '|| m.segundo_nombre, m.apellido_de_casada||' '||m.primer_apellido||' '||m.segundo_apellido||' '|| m.primer_nombre||' '||m.segundo_nombre) descripcion from tbl_adm_medico m, tbl_adm_medico_especialidad e where nvl (m.estado, 'A') = 'A' /*and e.especialidad = 'RAD'*/ and m.codigo = e.medico order by m.primer_nombre";
								%>
								<%//=fb.select(ConMgr.getConnection(), sql,"medico","",false,false,0,null,null,"",null,"")%>
							</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="yes" src="../expediente/reg_img_lab_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>"></iframe>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String errCode = "";
	String errMsg = "";
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.opener.location.reload(true);//= '<%=request.getContextPath()%>/expediente/reg_sol_imag_item.jsp';
	window.close();
<%
} else throw new Exception(errMsg);
%>
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>