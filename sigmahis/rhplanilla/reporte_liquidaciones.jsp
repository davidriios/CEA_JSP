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

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String anio = request.getParameter("anio");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String caja = "";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Liquidaciones- '+document.title;
function doAction()
{
}

function showReporte(value)
{

var msg = '';
var fechaini = eval('document.form0.fechaini').value ;
var fechafin = eval('document.form0.fechafin').value ;
var anio = eval('document.form0.anio').value  ;

	if(anio =='') msg=' al menos el Año';
		if(msg=='')
			{
			if(value=="1")
			abrir_ventana2('../rhplanilla/print_list_emp_liquidaciones.jsp?fp=resumido&fecha_inicial='+fechaini+'&fecha_final='+fechafin+'&anio='+anio);
			else if(value=="2")
			abrir_ventana2('../rhplanilla/print_list_emp_liquidaciones_det.jsp?fp=detallado&fecha_inicial='+fechaini+'&fecha_final='+fechafin+'&anio='+anio);
			} else alert('Seleccione '+msg);
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE LIQUIDACIONES"></jsp:param>
</jsp:include>
<table align="center" width="90%" cellpadding="0" cellspacing="0">
	<tr>
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>

			<tr class="TextFilter">
				<td width="10%">Compañ&iacute;a:</td>
				<td width="60%"><%=fb.select(ConMgr.getConnection(),"select codigo, codigo||' - '||nombre from tbl_sec_compania where estado = 'A' ORDER BY 1","compania",(String) session.getAttribute("_companyId"),"")%>
				</td>
				<td width="10%" align="right">Desde:</td>
				<td width="20%"><jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="fechaini" />
												<jsp:param name="valueOfTBox1" value="" />
												</jsp:include>
				</td>
			</tr>

			<tr class="TextFilter">
				<td width="10%">Año de Pago</td>
				<td width="60%"><%=fb.intBox("anio",anio,false,false,false,5)%></td>
				<td width="10%" align="right">Hasta:</td>
				<td width="20%"><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fechafin" />
								<jsp:param name="valueOfTBox1" value="" />
								</jsp:include>
				</td>
			</tr>

		</table>
</td></tr>

		<tr><td>&nbsp;</td></tr>

<tr>
 <td>
   <table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

			<tr class="TextHeader">
				<td colspan="2" align="center">Reportes de Liquidaciones</td>
			</tr>
			<tr class="TextHeader">
				<td>Reportes Resumidos</td>
				<td>Reportes Detallados</td>
			</tr>

			<tr class="TextRow01">
				<td><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Liquidaciones Resumidas por Unidad </td>
				<td><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Liquidaciones Detalladas por Unidad</td>
			</tr>
				
			<!----
				<tr class="TextRow01">
					<td colspan="2" align="center"><%=fb.button("addReporte","Generar Reporte",true,false,null,null,"onClick=\"javascript:showReporte()\"","Reporte de Cajas")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
				</tr>---->

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
</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
