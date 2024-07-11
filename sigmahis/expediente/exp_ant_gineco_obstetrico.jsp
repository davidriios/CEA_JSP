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

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}	
sql  ="select codigo, gestacion, parto, aborto, cesarea, menarca, to_char(fum,'dd/mm/yyyy') as fum, ciclo, inicio_sexual, conyuges, to_char(fecha_pap,'dd/mm/yyyy') as fecha_pap, metodo, sustancias, otros, observacion, ectopico,usuario_creacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion ,'U' action from tbl_sal_antecedente_ginecologo where pac_id="+pacId+" and nvl(admision,"+noAdmision+")="+noAdmision;
	cdo = SQLMgr.getData(sql);

	if (cdo == null)
	{
		if (!viewMode) modeSec = "add";
		cdo = new CommonDataObject();

		cdo.addColValue("FUM","");
		cdo.addColValue("FECHA_PAP","");
		cdo.addColValue("CODIGO","1");
	}
	else if (!viewMode) modeSec = "edit";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - Gineco-Obstetrico - '+document.title;
function doAction(){newHeight();}
function imprimir(){abrir_ventana('../expediente/print_exp_seccion_3.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("codigo",cdo.getColValue("codigo"))%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("usuarioCreacion",cdo.getColValue("usuario_creacion"))%>
<%=fb.hidden("fechaCreacion",cdo.getColValue("fecha_creacion"))%>
		<tr class="TextRow02">
			<td colspan="4" align="right"><a href="javascript:imprimir()"  class="Link00">[ <cellbytelabel id="1">Imprimir</cellbytelabel> ]</a></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="1" align=""> <cellbytelabel id="2">Descripci&aacute;n</cellbytelabel></td>
			<td colspan="1" align=""> <cellbytelabel id="3">Valor</cellbytelabel></td>
			<td colspan="1" align=""> <cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
			<td colspan="1" align=""> <cellbytelabel id="3">Valor</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td width="13%" align="right"><cellbytelabel id="4">Gestaci&oacute;n</cellbytelabel></td>
			<td width="12%"><%=fb.intBox("gesta",cdo.getColValue("GESTACION"),false,false,viewMode,5,2)%></td>
			<td width="25%" align="right"><cellbytelabel id="5">C&oacute;nyuge</cellbytelabel></td>
			<td width="50%"><%=fb.intBox("conyuge",cdo.getColValue("CONYUGES"),false,false,viewMode,5,3)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="6">Parto</cellbytelabel></td>
			<td><%=fb.intBox("parto",cdo.getColValue("PARTO"),false,false,viewMode,5,2)%></td>
			<td align="right"><cellbytelabel id="7">FUM</cellbytelabel></td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="fum" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("FUM")%>" />
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="8">Aborto</cellbytelabel></td>
			<td><%=fb.intBox("aborto",cdo.getColValue("ABORTO"),false,false,viewMode,5,2)%></td>
			<td align="right"><cellbytelabel id="9">&Uacute;ltimo Papa Nicolau</cellbytelabel></td>
			<td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="pap" />
				<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("FECHA_PAP")%>" />
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="10">Ces&aacute;rea</cellbytelabel></td>
			<td><%=fb.intBox("cesarea",cdo.getColValue("CESAREA"),false,false,viewMode,5,2)%></td>
			<td align="right"><cellbytelabel id="11">Ciclo Menstrual</cellbytelabel></td>
			<td><%=fb.textarea("ciclo",cdo.getColValue("CICLO"),false,false,viewMode,40,2,100,"","width:100%","")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="12">Ect&oacute;pico</cellbytelabel></td>
			<td><%=fb.intBox("ectopico",cdo.getColValue("ECTOPICO"),false,false,viewMode,5,2)%></td>
			<td align="right"><cellbytelabel id="13">M&eacute;todo de Planificaci&oacute;n</cellbytelabel></td>
			<td><%=fb.textarea("metodo",cdo.getColValue("METODO"),false,false,viewMode,40,2,100,"","width:100%","")%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="14">Menarca</cellbytelabel></td>
			<td><%=fb.intBox("menarca",cdo.getColValue("MENARCA"),false,false,viewMode,5,2)%>	</td>
			<td align="right" rowspan="2"><cellbytelabel id="15">Exposici&oacute;n a T&oacute;xicos y Substancia Qu&iacute;micas o Radiaciones</cellbytelabel></td>
			<td rowspan="2"><%=fb.select("exposicion","N=NO,S=SI",cdo.getColValue("SUSTANCIAS"),false,viewMode,1)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel id="16">I.V.S.A.</cellbytelabel></td>
			<td><%=fb.intBox("ivsa",cdo.getColValue("INICIO_SEXUAL"),false,false,viewMode,5,2)%></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3"><cellbytelabel id="17">Observaciones</cellbytelabel>:
			<br><%=fb.textarea("observacion",cdo.getColValue("OBSERVACION"),false,false,viewMode,40,3,2000,"","width:100%","")%>
			</td>
			<td colspan="2"><cellbytelabel id="18">Otros</cellbytelabel>
			<br><%=fb.textarea("otros",cdo.getColValue("OTROS"),false,false,viewMode,40,3,2000,"","width:100%","")%>
			</td>
		</tr>
	<% fb.appendJsValidation("if(error>0)doAction();"); %>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel id="19">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="20">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="21">Cerrar</cellbytelabel>
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
}//fin GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	cdo = new CommonDataObject();

	cdo.setTableName("tbl_sal_antecedente_ginecologo");
	cdo.addColValue("codigo",request.getParameter("codigo"));
	cdo.addColValue("GESTACION",request.getParameter("gesta"));
	cdo.addColValue("PARTO",request.getParameter("parto"));
	cdo.addColValue("ABORTO",request.getParameter("aborto"));
	cdo.addColValue("CESAREA",request.getParameter("cesarea"));
	cdo.addColValue("MENARCA",request.getParameter("menarca"));
	cdo.addColValue("FUM",""+request.getParameter("fum")+"");
	cdo.addColValue("CICLO",request.getParameter("ciclo"));
	cdo.addColValue("INICIO_SEXUAL",request.getParameter("ivsa"));
	cdo.addColValue("CONYUGES",request.getParameter("conyuge"));
	cdo.addColValue("FECHA_PAP",""+request.getParameter("pap")+"");
	cdo.addColValue("METODO",request.getParameter("metodo"));
	cdo.addColValue("SUSTANCIAS",request.getParameter("exposicion"));
	cdo.addColValue("OTROS",request.getParameter("otros"));
	cdo.addColValue("OBSERVACION",request.getParameter("observacion"));
	cdo.addColValue("ECTOPICO",request.getParameter("ectopico"));
	cdo.addColValue("admision",request.getParameter("noAdmision"));

	cdo.addColValue("fecha_modificacion",cDateTime);
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (modeSec.equalsIgnoreCase("add"))
	{
		cdo.addColValue("PAC_ID",request.getParameter("pacId"));
		cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
		cdo.addColValue("FEC_NACIMIENTO",request.getParameter("dob"));
		cdo.addColValue("fecha_creacion",cDateTime);
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
	
		SQLMgr.insert(cdo);
	}
	else if (modeSec.equalsIgnoreCase("edit"))
	{
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>














