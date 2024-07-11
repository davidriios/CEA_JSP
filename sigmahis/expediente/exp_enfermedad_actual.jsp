<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
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
if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

int rowCount = 0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	sql = "select to_char(fecha,'dd/mm/yyyy') as fecha, observacion, dolencia_principal, motivo_hospitalizacion, alergico_a, to_char(hora,'hh12:mi:ss am') as hora,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,usuario_creacion, fn_sal_ant_history("+pacId+", "+noAdmision+", "+seccion+",'secuencia','alergico_a',null,null) history from tbl_sal_padecimiento_admision where pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);

	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";

		cdo = new CommonDataObject();
		cdo.addColValue("fecha",cDateTime.substring(0,10));
		cdo.addColValue("hora",cDateTime.substring(11));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion",cDateTime);
	}
	else if (!viewMode) modeSec = "edit";

	String history = cdo.getColValue("history")==null?"":"Historial";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE - Enfermedad Actual - '+document.title;
function doAction(){newHeight();}
function imprimirExp(){abrir_ventana('../expediente/print_exp_seccion_1.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}

$(function(){
	$(".history").tooltip({
	content: function () {
		var $i = $(this).data("i");
		var $title = $($(this).prop('title'));
		var $content = $("#historyCont"+$i).val();
		var $cleanContent = $($content).text();
		if (!$cleanContent) $content = "";
		return $content;
	}

	});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true" >
	<jsp:param name="title" value="<%=desc%>" ></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1" >
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("modeSec",modeSec)%>
				<%=fb.hidden("seccion",seccion)%>
				<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
				<%=fb.hidden("dob","")%>
				<%=fb.hidden("codPac","")%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("desc",desc)%>
				<%=fb.hidden("fecha_creacion",cdo.getColValue("fecha_creacion"))%>
				<%=fb.hidden("usuario_creacion",cdo.getColValue("usuario_creacion"))%>

				<%=fb.hidden("historyCont0","<label class='historyCont' style='font-size:11px'>"+(cdo.getColValue("history")==null?"":cdo.getColValue("history"))+"</label>")%>

				<tr class="TextRow02" >
					<td colspan="4" align="right">&nbsp;<a href="javascript:imprimirExp()" class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
				</tr>
				<tr class="TextRow01" >
					<td width="15%" align="right"><cellbytelabel id="2">Fecha</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("fecha",cdo.getColValue("fecha"),false,false,true,10)%></td>
					<td width="15%" align="right"><cellbytelabel id="3">Hora</cellbytelabel></td>
					<td width="35%"><%=fb.textBox("hora",cdo.getColValue("hora"),false,false,true,10)%></td>
				</tr>

				<%
				CommonDataObject cdoSV = SQLMgr.getData("select listagg('<td><b>'||aa.descripcion,'</b></td>') within group(order by aa.orden) signos_header,listagg('<td><b>'||aa.resultado,'</b></td>') within group(order by aa.orden) signos_resultado from (select a.orden, a.descripcion, c.resultado from tbl_sal_signo_vital a, tbl_sal_signo_vital_um b, (select * from tbl_sal_detalle_signo z where pac_id = "+pacId+" AND secuencia = "+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = z.pac_id and secuencia = z.secuencia and fecha = z.fecha_signo and hora = z.hora and tipo_persona = z.tipo_persona and tipo_persona = 'T' and status = 'A') and decode(observaciones,'CONNEX',fecha_signo,fecha_creacion) = (select max(decode(observaciones,'CONNEX',fecha_signo,fecha_creacion))fechaMax from  tbl_sal_detalle_signo y WHERE pac_id="+pacId+" AND secuencia="+noAdmision+" and exists (select null from tbl_sal_signo_paciente where pac_id = y.pac_id and secuencia = y.secuencia and fecha = y.fecha_signo and hora = y.hora and tipo_persona = y.tipo_persona and tipo_persona = 'T' and status = 'A'))) c where a.codigo=b.cod_signo(+) and b.valor_default(+)='S' and a.codigo=c.signo_vital(+) and a.status = 'A' and c.resultado is not null) aa");
				if (cdoSV == null) cdoSV = new CommonDataObject();
				if(!cdoSV.getColValue("signos_header"," ").trim().equals("") && !cdoSV.getColValue("signos_resultado"," ").trim().equals("")) {
				%>
				<tr class="TextRow02">
					<td colspan="4">

						<table style="width:100%" cellpadding="0" cellspacing="0">
							<tr><%=cdoSV.getColValue("signos_header"," ")%></td>
							<td><b>CATEGORIA</b></td>
							</tr>
							<tr><%=cdoSV.getColValue("signos_resultado")%></td>
							<td>
							<%
							CommonDataObject cdoCat = SQLMgr.getData("select * from (select decode(categoria,1,'<span style=''background-color: #f00;''>[ I ] CRITICO</span>',2,'<span style=''background-color: #ff0;''>[ II ] URGENTE</span>',3,'<span style=''background-color: #008000;''>[ III ] NO URGENTE</span>') categoria from tbl_sal_signo_paciente where pac_id = "+pacId+" and tipo_persona = 'T' and status = 'A' and secuencia = "+noAdmision+" order by hora desc) where rownum = 1");
							%>
								<b><%=cdoCat.getColValue("categoria")%></b>
							</td>
							</tr>
						</table>
					</td>
				</tr>
				<%}%>


				<tr class="TextRow01">
					<td colspan="4" style="padding:0 10px 0 10px">
						<cellbytelabel id="4"><b>Motivo de Consulta</b></cellbytelabel>
						<br><%=fb.textarea("dolencia",cdo.getColValue("DOLENCIA_PRINCIPAL"),false,false,viewMode,0,4,2000,"","width:100%","")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="4" style="padding:0 10px 0 10px">
						<b><cellbytelabel id="5">Historia de la Enfermedad Actual
							(Inicio, Sintomas, Asistencia Medica y Otros)</cellbytelabel></b><br>
						<%=fb.textarea("observacion",cdo.getColValue("OBSERVACION"),false,false,viewMode,0,4,2000,"","width:100%","")%>
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="4" style="padding:0 10px 0 10px">
						<b><cellbytelabel id="6">Motivo de la Hospitalizaci&oacute;n</cellbytelabel></b>
						<br><%=fb.textarea("motivo",cdo.getColValue("MOTIVO_HOSPITALIZACION"),false,false,viewMode,0,4,2000,"","width:100%","")%>
					</td>
					<!--
					<td colspan="2">
						<label class="RedTextBold">Alergico a</label>&nbsp;&nbsp;
						<span class="history" title="" data-i="0"><span class="Link00 pointer"><%=history%></span></span>
						<br><%=fb.textarea("alergico",cdo.getColValue("ALERGICO_A"),false,false,viewMode,40,4,2000,"","","")%>
					</td>
					-->
				</tr>
				<tr class="TextRow02" align="right">
					<td colspan="4">
				<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="8">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="9">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
					</td>
				</tr>
				<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	cdo = new CommonDataObject();

	cdo.setTableName("TBL_SAL_PADECIMIENTO_ADMISION");
	cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
	cdo.addColValue("FECHA",request.getParameter("fecha"));
	cdo.addColValue("HORA",request.getParameter("hora"));
	cdo.addColValue("OBSERVACION",request.getParameter("observacion"));
	cdo.addColValue("DOLENCIA_PRINCIPAL",request.getParameter("dolencia"));
	cdo.addColValue("MOTIVO_HOSPITALIZACION",request.getParameter("motivo"));
	//cdo.addColValue("ALERGICO_A",request.getParameter("alergico"));
	cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"));
	cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"));

	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion",cDateTime);

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("SECUENCIA",request.getParameter("noAdmision"));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO",request.getParameter("dob"));
		SQLMgr.insert(cdo);
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{

		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript">
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>