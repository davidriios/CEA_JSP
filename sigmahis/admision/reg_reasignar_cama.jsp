<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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
<jsp:useBean id="htCama" scope="session" class="java.util.Hashtable" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();

String key = "";
String sql = "";
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

String area = "";

sql = "select codigo, descripcion from tbl_cds_centro_servicio where reporta_a = 885 and estado = 'A' and recibe_solicitud = 'S'";
al = SQLMgr.getDataList(sql);
for(int i=0;i<al.size();i++){
	CommonDataObject a = (CommonDataObject) al.get(i);
	area = a.getColValue("codigo");
	break;
}

int lineNo = 0;
if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		if(change==null){
			if(request.getParameter("pacienteId")==null) pacienteId = "0";
			if(request.getParameter("noAdmision")==null) noAdmision = "0";
			if(!pacienteId.equals("0") && !noAdmision.equals("0")){
				htCama.clear();
				sql = "select a.codigo, a.cama, a.compania, a.habitacion, to_char(a.fecha_inicio, 'dd/mm/yyyy') fecha_inicio, to_char(a.hora_inicio, 'HH:MI AM') hora_inicio, to_char(a.fecha_final, 'dd/mm/yyyy') fecha_final, a.hora_final, b.unidad_admin cod_sala, c.descripcion desc_sala, b.estado_habitacion,nvl(a.precio_alt,'N') as precio_alt,a.precio_alterno from tbl_adm_cama_admision a, tbl_sal_habitacion b, tbl_cds_centro_servicio c where a.compania = b.compania and a.habitacion = b.codigo and b.unidad_admin = c.codigo and a.admision = "+noAdmision+" and a.pac_id = "+pacienteId+" and a.fecha_final is null order by a.fecha_inicio";
				System.out.println("sql..............=\n"+sql);
				ArrayList alC = SQLMgr.getDataList(sql);
				System.out.println("alC.size()..............="+alC.size());
				for(int i=0;i<alC.size();i++){
					CommonDataObject cdo = (CommonDataObject) alC.get(i);
					lineNo++;
					if (lineNo < 10) key = "00"+lineNo;
					else if (lineNo < 100) key = "0"+lineNo;
					else key = ""+lineNo;
					htCama.put(key, cdo);
				}
			}
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
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reasignar Cama - '+document.title;

function removeItem(fName,k){
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue){
	document.forms[fName].baction.value = actionValue;
	window.frames['itemFrame'].doSubmit();
}

function showMedicoList(){
	abrir_ventana1('../common/search_medico.jsp?fp=cargo_dev');
}

function doAction(){}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
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
							<td width="95%">&nbsp;Datos del Paciente</td>
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
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("codigoPaciente","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
				<!--
				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextRow01">
							<td width="50%">&nbsp;Area:&nbsp;
								<%
								sql = "select codigo, descripcion from tbl_cds_centro_servicio where reporta_a = 885 and estado = 'A' and recibe_solicitud = 'S'";
								%>
								<%=fb.select(ConMgr.getConnection(), sql,"area",area,false,false,0,null,null,"",null,"")%>
							</td>
							<td width="50%">&nbsp;Radi&oacute;logo:&nbsp;
								<%
								sql = "select m.codigo, decode(m.apellido_de_casada,null, m.primer_apellido||' '|| m.segundo_apellido||' '|| m.apellido_de_casada||' '|| m.primer_nombre||' '|| m.segundo_nombre, m.apellido_de_casada||' '||m.primer_apellido||' '||m.segundo_apellido||' '|| m.primer_nombre||' '||m.segundo_nombre) descripcion from tbl_adm_medico m, tbl_adm_medico_especialidad e where nvl (m.estado, 'A') = 'A' and e.especialidad = 'RAD' and m.codigo = e.medico order by m.primer_nombre";
								%>
								<%=fb.select(ConMgr.getConnection(), sql,"medico","",false,false,0,null,null,"",null,"")%>
							</td>
						</tr>
						</table>
					</td>
				</tr>
				-->
				<tr>
					<td>
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../admision/reg_reasignar_cama_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>"></iframe>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar:
						<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
						<%=fb.radio("saveOption","O",false,viewMode,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C",true,viewMode,false)%>Cerrar
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
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
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/list_salida.jsp"))
	{
%>
	 window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/list_salida.jsp")%>';

<%
	} else
	{
%>
	  window.opener.location = '<%=request.getContextPath()%>/admision/list_salida.jsp';
<%
	}
	if (saveOption.equalsIgnoreCase("N")){
%>
	setTimeout('addMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("O")){
%>
	setTimeout('viewMode()',500);
<%
	}	else if (saveOption.equalsIgnoreCase("C")){
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&noAdmision=0&pacienteId=0';
}

function viewMode(){
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&noAdmision=<%=noAdmision%>&pacienteId=<%=pacienteId%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>