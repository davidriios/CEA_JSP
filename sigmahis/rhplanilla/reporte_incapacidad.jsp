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
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />

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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String key = "";
String sql = "";

String grupo = request.getParameter("grupo");
String rep = request.getParameter("rep");
String empId = request.getParameter("empId");

String ip = request.getRemoteAddr();
String mode = request.getParameter("mode");
boolean viewMode = false;
String displayCob = " style=\"display:none\"";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String appendFilter = "";

if (mode == null) mode = "add";
if (grupo!=null) appendFilter += " and a.codigo ="+grupo;
if (request.getMethod().equalsIgnoreCase("GET"))
{
sql="select a.descripcion from tbl_pla_ct_grupo a where a.compania = "+(String) session.getAttribute("_companyId")+appendFilter;
cdo = SQLMgr.getData(sql);


%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Incapacidades- '+document.title;
function doAction()
{
}


function showReporte(k)
{
var msg= '';
var desde = document.form0.fecha_ini.value ;
var hasta = document.form0.fecha_fin.value ;
var grupo  = document.form0.codigo.value ;
var grupoDesc  =document.form0.grupo.value ;

if(desde == "")
msg = ', Fecha Inicial';
if(hasta == "")
msg = ', Fecha Final';
if(grupo == "")
msg = ', Grupo';

if(msg == ""){

if(k==1)
{
  abrir_ventana1('../rhplanilla/print_list_inc_det.jsp?empId=<%=empId%>&grupo='+grupo+'&desde='+desde+'&hasta='+hasta+'&grupoDesc='+grupoDesc);
} else  abrir_ventana1('../rhplanilla/print_list_incapacidades.jsp?grupo='+grupo+'&desde='+desde+'&hasta='+hasta+'&grupoDesc='+grupoDesc);
}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE INCAPACIDADES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>

		<table align="center" width="99%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("codigo",grupo)%>
			<%=fb.hidden("empId",empId)%>
			<%=fb.hidden("baction","")%>
				<tr class="TextHeader">
							<td colspan="4">Reporte de Incapacidades</td>
				</tr>
				<tr class="TextRow01">
					<td>Grupo</td>
					<td colspan="3">
  				<%=fb.select(ConMgr.getConnection(),sql,"grupo",cdo.getColValue("grupo"),false,viewMode,0,null,null,"")%></td>
				</tr>


				<tr class="TextRow01">
					<td width="25%">Desde</td>
					<td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha_ini" />
											<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
											</jsp:include></td>
					<td width="25%">Hasta</td>
					<td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha_fin" />
											<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
											</jsp:include></td>
				</tr>

				<tr class="TextRow01">
					<td colspan="4" align="center"><%=fb.button("addReporte","Reporte",false,false,null,null,"onClick=\"javascript:showReporte("+rep+")\"","Reporte de Incapacidades")%>

					</td>
				</tr>

	<%fb.appendJsValidation("if(error>0)doAction();");%>
	<!--<tr class="TextRow02">
					<td colspan="4" align="right">
						Opciones de Guardar:
						< <%=fb.radio("saveOption","N")%>Crear Otro
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
						<%=fb.radio("saveOption","C")%>Cerrar
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
</tr>	--->
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




	%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SBMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SBMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/empl_incapacidad_list.jsp"))
		{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/empl_incapacidad_list.jsp")%>';
<%
		}
		else
		{
%>
	//window.opener.location = '<%=request.getContextPath()%>/rhplanilla/empl_incapacidad_list.jsp';
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
} else throw new Exception(SBMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>