<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>

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
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

String key = "";
String sql = "";
String mode = request.getParameter("mode");
String secuencia = request.getParameter("secuencia");
String fp = request.getParameter("fp");
String pac_id = request.getParameter("pac_id");
String admision = request.getParameter("admision");
String centro = request.getParameter("centro");

boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
//if (fp == null) fp = "deposito";
if (mode != null && mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET"))
{


if (mode.equalsIgnoreCase("add"))
	{
		secuencia = "0";
		pac_id = "0";
		
		cdo = new CommonDataObject();
		cdo.addColValue("fecha_creacion",cDateTime.substring(0,10));
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_modifica",cDateTime.substring(0,10));
		cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
		
		if (!viewMode) mode = "add";
	}
	else
	{
			if (secuencia == null || pac_id == null || admision== null || centro== null) throw new Exception("Los datos no son válido. Por favor intente nuevamente!");
sql="select a.secuencia,a.estatus, to_char(a.fecha_nacimiento,'dd/mm/yyyy')as fecha_nacimiento, a.paciente, a.admision, a.centro,a.observacion, a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy')as fecha_creacion ,a.usuario_modifica, to_char(a.fecha_modifica,'dd/mm/yyyy') as fecha_modifica, a.pase,a.pase_k,pac_id,c.descripcion from tbl_fac_cargo_tardio a, tbl_cds_centro_servicio c where a.centro = c.codigo and a.pac_id= "+pac_id+" and a.admision= "+admision+" and a.secuencia= "+secuencia+" and centro= "+centro;

cdo = SQLMgr.getData(sql);
pac_id=cdo.getColValue("pac_id");
admision=cdo.getColValue("admision");
if (!viewMode) mode = "edit";	
	
}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Explicacion Cargo Tardio- '+document.title;

function doAction()
{
}
function CheckPaciente()
{
	if (pacienteValidation()) return true;
	else return false;
	
}

function showCentro()
{
abrir_ventana1('../common/search_centro_servicio.jsp?fp=cargo_tardio');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPLICACION CARGO TARDIO"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">   
	<tr>  
		<td>   
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextRow02">
						<td colspan="4">&nbsp;</td>
					</tr>
			<tr>
					<td colspan="4" onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Datos del Paciente</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td colspan="4">
						<jsp:include page="../common/paciente.jsp" flush="true">
							<jsp:param name="pacienteId" value="<%=pac_id%>"></jsp:param>
							<jsp:param name="admisionNo" value="<%=admision%>"></jsp:param>
							<jsp:param name="fp" value="cargo_tardio"></jsp:param>
							<jsp:param name="tr" value="CT"></jsp:param>
							<jsp:param name="mode" value="<%=(mode.equalsIgnoreCase("edit"))?"view":mode%>"></jsp:param>
						</jsp:include>
					</td>
				</tr>
		
		
		
		
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("pase",cdo.getColValue("pase"))%>
			<%=fb.hidden("pase_k",cdo.getColValue("pase_k"))%>
			<%=fb.hidden("pac_id",pac_id)%>
			<%=fb.hidden("fecha_nacimiento","")%>
			<%=fb.hidden("admision",admision)%>
			<%=fb.hidden("codigoPaciente","")%>
				<tr class="TextHeader">
							<td colspan="4"><cellbytelabel>CARGO TARDIO</cellbytelabel></td>
				</tr>
				<tr class="TextRow01"> 
				<td width="20%"><cellbytelabel>Secuencia</cellbytelabel></td>
				<td width="25%"><%=fb.intBox("secuencia",secuencia,false,false,true,5,10)%></td>
				<td width="25%" align="right"><cellbytelabel>Estatus</cellbytelabel></td>
				<td width="30%"><%=fb.select("estatus","P = PENDIENTE, T = REGISTRADO, A = ANULADO",cdo.getColValue("estatus"),false,viewMode,0,"",null,"")%> 	</td>
				</tr>
				<tr class="TextRow01"> 
				<td><cellbytelabel>Centro De Servicio</cellbytelabel></td>
				<td colspan="3"><%=fb.textBox("centro",cdo.getColValue("centro"),true,false,true,10,30)%>
				<%=fb.textBox("name_centro",cdo.getColValue("descripcion"),false,false,true,40,200)%><%=fb.button("addDesc","...",true,(mode.equalsIgnoreCase("edit"))?true:viewMode,null,null,"onClick=\"javascript:showCentro()\"","Centro de Servicio")%></td>
				</tr>
				<tr class="TextRow01"> 
						<td><cellbytelabel>Observaciones</cellbytelabel></td>
						<td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,viewMode,60,3,200,"","width:100%","")%></td>
				</tr>
				<tr class="TextRow01"> 
						<td><cellbytelabel>Creado Por</cellbytelabel>: </td>
						<td><%=fb.textBox("usuario_creacion",cdo.getColValue("usuario_creacion"),false,false,true,15)%><%=fb.textBox("fecha_creacion",cdo.getColValue("fecha_creacion"),false,false,true,15)%></td>
						<td align="right"><cellbytelabel>Modificado Por</cellbytelabel>:</td>
						<td><%=fb.textBox("usuario_modifica",cdo.getColValue("usuario_modifica"),false,false,true,15)%><%=fb.textBox("fecha_modifica",cdo.getColValue("fecha_modifica"),false,false,true,15)%></td>
						
				 </tr>
	<%fb.appendJsValidation("\n\tif (!CheckPaciente()) error++;\n");%>			
	<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guarda</cellbytelabel>r: 
						<!--< -<%=fb.radio("saveOption","N")%>Crear Otro-->
						<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>	
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
					pac_id = request.getParameter("pac_id");
					admision = request.getParameter("admision");
					centro = request.getParameter("centro");
					
					cdo = new CommonDataObject();
					cdo.setTableName("TBL_FAC_CARGO_TARDIO");  
					cdo.setWhereClause("pac_id="+request.getParameter("pac_id")+" and admision="+request.getParameter("admision")+" and centro ="+request.getParameter("centro"));
					cdo.addColValue("observacion",request.getParameter("observacion"));
					cdo.addColValue("estatus",request.getParameter("estatus"));
					cdo.addColValue("usuario_modifica",(String) session.getAttribute("_userName"));
					cdo.addColValue("fecha_modifica",cDateTime);
					
					if (mode.equalsIgnoreCase("add"))
					{
							cdo.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"));
							cdo.addColValue("paciente",request.getParameter("codigoPaciente"));
							cdo.addColValue("admision",request.getParameter("admision"));
							cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
							cdo.addColValue("fecha_creacion",cDateTime);
							cdo.addColValue("pase",request.getParameter("pase"));
							cdo.addColValue("pase_k",request.getParameter("pase_k"));
							cdo.addColValue("pac_id",request.getParameter("pac_id"));
							cdo.addColValue("centro",request.getParameter("centro"));

							cdo.setAutoIncCol("secuencia");
							cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pac_id")+" and admision="+request.getParameter("admision")+" and centro ="+request.getParameter("centro"));
													
							cdo.addPkColValue("secuencia","");
							
							ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
							SQLMgr.insert(cdo);
							secuencia = SQLMgr.getPkColValue("secuencia");
							ConMgr.clearAppCtx(null);
					}
					else if (mode.equalsIgnoreCase("edit"))
					{
						secuencia = request.getParameter("secuencia");
						cdo.setWhereClause("pac_id="+request.getParameter("pac_id")+" and secuencia="+request.getParameter("secuencia")+" and admision="+request.getParameter("admision")+" and centro ="+request.getParameter("centro"));
						 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						 SQLMgr.update(cdo);
						 ConMgr.clearAppCtx(null);
					}
	
	%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/facturacion/list_cargo_tardio.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/facturacion/list_cargo_tardio.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/facturacion/list_cargo_tardio.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&secuencia=<%=secuencia%>&admision=<%=admision%>&pac_id=<%=pac_id%>&centro=<%=centro%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>