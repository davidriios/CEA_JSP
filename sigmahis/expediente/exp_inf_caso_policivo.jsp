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
String cds = request.getParameter("cds");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (cds == null) cds = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
sql="SELECT distinct m.primer_nombre||decode(m.segundo_nombre,'','',' '||m.segundo_nombre)||' '||m.primer_apellido||decode(m.segundo_apellido,null,'',' '||m.segundo_apellido)||decode(m.sexo,'F',decode(m.apellido_de_casada,'','',' '||m.apellido_de_casada)) as nombre_medico, to_char(a.FECHA,'dd/mm/yyyy') as FECHA, to_char(a.HORA,'hh12:mi:ss am') AS HORA, a.ESTADO, a.TIPO_AUTORIDAD, a.NOM_AUTORIDAD, a.RANGO_AUTORIDAD, a.CIP_PLACA, a.FORMULARIO_VINTRA, a.TIPO_EVIDENCIA, a.EVIDENCIA_ENTREGA, to_char(a.FECHA_ENTREGA,'dd/mm/yyyy') as FECHA_ENTREGA, to_char(a.HORA_ENTREGA,'hh12:mi:ss am') AS HORA_ENTREGA, a.CIP_ENTREGA, a.NOMBRE_ENTREGA, a.NOMBRE_TESTIGO, a.CIP_TESTIGO, a.COD_MEDICO, a.USUARIO_CREACION, to_char(a.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREACION, a.USUARIO_MODIFICACION, to_char(a.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIFICACION, a.COD_TIPO_CASO, a.COD_TRANSPORTE FROM TBL_SAL_PRUEBA_FISICA_POLIC a, tbl_adm_medico m where m.codigo=a.cod_medico and a.pac_id="+pacId+" and a.secuencia="+noAdmision;
		cdo = SQLMgr.getData(sql);

		if (cdo == null)
		{
			if (!viewMode) modeSec = "add";
			cdo = new CommonDataObject();
			cdo.addColValue("fecha",cDate.substring(0,10));
			cdo.addColValue("hora","");
			cdo.addColValue("hora","");
			cdo.addColValue("FECHA_ENTREGA","");
			cdo.addColValue("HORA_ENTREGA","");
			cdo.addColValue("ESTADO","B");
			cdo.addColValue("FORMULARIO_VINTRA","");
			cdo.addColValue("USUARIO_CREACION",UserDet.getUserName());
			cdo.addColValue("FECHA_CREACION",cDate);
			cdo.addColValue("USUARIO_MODIFICACION",UserDet.getUserName());
			cdo.addColValue("FECHA_MODIFICACION",cDate);

		}
		else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - Informe de Caso Policivo - '+document.title;
function medicoList(){abrir_ventana1('../common/search_medico.jsp?fp=exp_interconsulta_medico');}
function printInforme(){abrir_ventana1('print_informe_policivo.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&cds=<%=cds%>');}
function doAction(){newHeight();}
function checkHora(){if(eval('document.form0.hora').value.trim()==''){alert('Por favor ingrese la hora!');return false;}return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
		<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="1" >
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("cds",cds)%>
			<%=fb.hidden("modeSec",modeSec)%>
			<%=fb.hidden("seccion",seccion)%>
			<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
			<%=fb.hidden("dob","")%>
			<%=fb.hidden("codPac","")%>
			<%=fb.hidden("pacId",pacId)%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("desc",desc)%>
			<%=fb.hidden("cod_especialidad","")%>
			<%=fb.hidden("usuario_creac",cdo.getColValue("USUARIO_CREACION"))%>
			<%=fb.hidden("fecha_creac",cdo.getColValue("fecha_creacion"))%>
			<%=fb.hidden("usuario_modific",cdo.getColValue("usuario_modificacion"))%>
			<%=fb.hidden("fecha_modific",cdo.getColValue("fecha_modificacion")) %>
			<%fb.appendJsValidation("if(!checkHora())error++;");%>

			<tr class="TextRow01" >
				<td colspan="4">&nbsp;</a></td>
			</tr>
			<tr class="TextRow02" align="right">
				<td colspan="4"><a href="javascript:printInforme()" class="Link00">[ <cellbytelabel id="1">Imprimir Informe</cellbytelabel> ]</a></td>
			</tr>
			<tr class="TextRow01">
				<td  width="20%"><cellbytelabel id="2">Fecha</cellbytelabel> </td>
				<td width="20%">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("FECHA")%>" />
								<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
								</jsp:include>
							</td>


				<td width="21%"><cellbytelabel id="3">hora</cellbytelabel></td>
				<td width="30%">
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="format" value="hh12:mi:ss am" />
								<jsp:param name="nameOfTBox1" value="hora" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("HORA")%>" />
								<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("edit"))?"y":"n"%>"/>
								</jsp:include>
								</td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel id="4">Tipo de caso</cellbytelabel></td>
				<td><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM TBL_SAL_TIPO_CASO ORDER  BY 2","tipo_caso",cdo.getColValue("COD_TIPO_CASO"),false,viewMode,0,"",null,null)%></td>
				<td><cellbytelabel id="5">Forma de Llegar</cellbytelabel> </td>
				<td><%=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM						TBL_SAL_FORMA_TRANSPORTE ORDER  BY 1","tipo_transporte",cdo.getColValue("COD_TRANSPORTE"),false,viewMode,0,"",null,null)%></td>
			</tr>
			<tr class="TextRow01" >
				<td><cellbytelabel id="6">Estado del paciente</cellbytelabel></td>
				<td colspan="3">
				<%=fb.radio("estado","B",cdo.getColValue("ESTADO").equals("B"),viewMode,false)%><cellbytelabel id="7">Bueno</cellbytelabel>
				<%=fb.radio("estado","R",cdo.getColValue("ESTADO").equals("R"),viewMode,false)%><cellbytelabel id="8">Regular</cellbytelabel>
				<%=fb.radio("estado","G",cdo.getColValue("ESTADO").equals("G"),viewMode,false)%><cellbytelabel id="9">Grave</cellbytelabel>
				<%=fb.radio("estado","M",cdo.getColValue("ESTADO").equals("M"),viewMode,false)%><cellbytelabel id="10">Muerto</cellbytelabel> </td>
			</tr>
			<tr class="TextRow01" >
				<td>S&eacute; <cellbytelabel id="11">Informo A</cellbytelabel> </td>
				<td><%=fb.textBox("tipo_autoridad",cdo.getColValue("TIPO_AUTORIDAD"),false,false,viewMode,25)%> </td>
				<td><cellbytelabel id="12">Autoridad Informada</cellbytelabel> </td>
				<td><%=fb.textBox("nom_autoridad",cdo.getColValue("NOM_AUTORIDAD"),false,false,viewMode,25)%> </td>
			</tr>
			<tr class="TextRow01" >
				<td><cellbytelabel id="13">Rango</cellbytelabel></td>
				<td><%=fb.textBox("rango_autoridad",cdo.getColValue("RANGO_AUTORIDAD"),false,false,viewMode,15)%></td>
				<td><cellbytelabel id="14">CIP/Placa</cellbytelabel> </td>
				<td><%=fb.textBox("cip_placa",cdo.getColValue("CIP_PLACA"),false,false,viewMode,15)%></td>
			</tr>
			<tr class="TextRow01" >
				<td colspan="2"><cellbytelabel id="15">S&eacute; Lleno el Formulario de Violencia intrafamiliar/ Maltrato al menor</cellbytelabel> </td>
				<td colspan="2"><%=fb.radio("f_maltrato","S",(!cdo.getColValue("FORMULARIO_VINTRA").equals("N")),viewMode,false)%>SI <%=fb.radio("f_maltrato","N",(!cdo.getColValue("FORMULARIO_VINTRA").equals("S")),viewMode,false)%>NO</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="2"><cellbytelabel id="16">Tipo de Evidencia Legal(balas, armas, ropa)</cellbytelabel> </td>
				<td colspan="2"><%=fb.textBox("tipo_evidencia",cdo.getColValue("TIPO_EVIDENCIA"),false,false,viewMode,30)%> </td>
			</tr>
			<tr class="TextRow01" >
				<td colspan="2"><cellbytelabel id="17">S&eacute; Entrego la Evidencia Legal A</cellbytelabel>: </td>
				<td colspan="2"><%=fb.textBox("evidencia_entrega",cdo.getColValue("EVIDENCIA_ENTREGA"),false,false,viewMode,30)%> </td>
			<tr class="TextRow01" >
				<td><cellbytelabel id="18">Fecha de Entrega</cellbytelabel> </td>
				<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_entrega" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("FECHA_ENTREGA")%>" />
								</jsp:include>

				</td>
				<td><cellbytelabel id="19">Hora Entrega</cellbytelabel>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="format" value="hh12:mi:ss am" />
								<jsp:param name="nameOfTBox1" value="hora_entrega" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("HORA_ENTREGA")%>" />
								</jsp:include> </td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel id="20">Nombre/Firma</cellbytelabel> </td>
				<td><%=fb.textBox("nombre_entrega",cdo.getColValue("NOMBRE_ENTREGA"),false,false,viewMode,25)%></td>
				<td><cellbytelabel id="21">CIP</cellbytelabel>:</td>
				<td><%=fb.textBox("cip_entrega",cdo.getColValue("CIP_ENTREGA"),false,false,viewMode,15)%> </td>
			</tr>
			<tr class="TextRow01">
				<td><cellbytelabel id="22">Testigos</cellbytelabel></td>
				<td><%=fb.textBox("nombre_testigo",cdo.getColValue("NOMBRE_TESTIGO"),false,false,viewMode,25)%> </td>
				<td><cellbytelabel id="21">CIP</cellbytelabel>: </td>
				<td><%=fb.textBox("cip_testigo",cdo.getColValue("CIP_TESTIGO"),false,false,viewMode,15)%></td>
			</tr>
			<tr class="TextRow01">
				<td> <cellbytelabel id="23">M&eacute;dico	del CU</cellbytelabel> </td>
				<td colspan="3"><%=fb.textBox("cod_medico",cdo.getColValue("COD_MEDICO"),true,false,true,5)%>
				<%=fb.textBox("nombre_medico",cdo.getColValue("nombre_medico"),false,false,true,35)%><%=fb.button("medico","...",true,viewMode,null,null,"onClick=\"javascript:medicoList()\"","seleccionar medico")%>
								</td>


			</tr>

			<tr class="TextRow02" align="right">
				<td colspan="4">
				<cellbytelabel id="24">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="25">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="26">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
</td>
			</tr>
			<%=fb.formEnd(true)%>
		</table></td>
	</tr>
</table>

</body>
</html>
<%
}//fin GET
else
{

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

					cdo = new CommonDataObject();
					cdo.setTableName("TBL_SAL_PRUEBA_FISICA_POLIC");
					cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
					cdo.addColValue("FECHA",request.getParameter("fecha"));
					cdo.addColValue("HORA",request.getParameter("hora"));
					cdo.addColValue("ESTADO",request.getParameter("estado"));
					cdo.addColValue("TIPO_AUTORIDAD",request.getParameter("tipo_autoridad"));
					cdo.addColValue("NOM_AUTORIDAD",request.getParameter("nom_autoridad"));
					cdo.addColValue("RANGO_AUTORIDAD",request.getParameter("rango_autoridad"));
					cdo.addColValue("CIP_PLACA",request.getParameter("cip_placa"));
					cdo.addColValue("FORMULARIO_VINTRA",request.getParameter("f_maltrato"));
					cdo.addColValue("TIPO_EVIDENCIA",request.getParameter("tipo_evidencia"));
					cdo.addColValue("EVIDENCIA_ENTREGA",request.getParameter("evidencia_entrega"));
					cdo.addColValue("FECHA_ENTREGA",request.getParameter("fecha_entrega"));
					cdo.addColValue("HORA_ENTREGA",request.getParameter("hora_entrega"));
					cdo.addColValue("CIP_ENTREGA",request.getParameter("cip_entrega"));
					cdo.addColValue("NOMBRE_ENTREGA",request.getParameter("nombre_entrega"));
					cdo.addColValue("NOMBRE_TESTIGO",request.getParameter("nombre_testigo"));
					cdo.addColValue("CIP_TESTIGO",request.getParameter("cip_testigo"));
					cdo.addColValue("COD_MEDICO",request.getParameter("cod_medico"));
					cdo.addColValue("USUARIO_CREACION",request.getParameter("usuario_creac"));
					cdo.addColValue("FECHA_CREACION",request.getParameter("fecha_creac"));
					cdo.addColValue("USUARIO_MODIFICACION",UserDet.getUserName());
					cdo.addColValue("FECHA_MODIFICACION",cDate);
					cdo.addColValue("COD_TIPO_CASO",request.getParameter("tipo_caso"));
					cdo.addColValue("COD_TRANSPORTE",request.getParameter("tipo_transporte"));

					if (modeSec.equalsIgnoreCase("add"))
					{
							cdo.addColValue("PAC_ID",request.getParameter("pacId"));
							cdo.addColValue("SECUENCIA",request.getParameter("noAdmision"));
							cdo.addColValue("CODIGO_PACIENTE",request.getParameter("codPac"));
							cdo.addColValue("FECHA_NACIMIENTO", request.getParameter("dob"));
							ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
							SQLMgr.insert(cdo);
							ConMgr.clearAppCtx(null);
					}
					else if (modeSec.equalsIgnoreCase("edit"))
					{
						 cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
						 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						 SQLMgr.update(cdo);
						 ConMgr.clearAppCtx(null);
					}
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>

