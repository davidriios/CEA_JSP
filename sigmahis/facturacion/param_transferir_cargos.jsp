
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

String sql ="";
String compania = (String) session.getAttribute("_companyId");	
String fg = request.getParameter("fg");
String almacen = request.getParameter("almacen");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String admRoot = request.getParameter("admRoot");
String cedulaPasaporte=request.getParameter("cedulaPasaporte");
String noAdmisionMadre = request.getParameter("noAdmisionMadre");
String pacIdMadre = request.getParameter("pacIdMadre");
String fNacMadre = request.getParameter("fNacMadre");
String codPacMadre = request.getParameter("codPacMadre");
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (admRoot == null) admRoot = "";
if(fg == null)fg="";
if(cedulaPasaporte == null)cedulaPasaporte ="";
if(pacId == null)pacId ="";
if(codPacMadre == null)codPacMadre ="";
if(noAdmision == null)noAdmision ="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturación - Transferencia de Cargos - '+document.title;
function doAction()
{
}
function reporteSalidas()
{
var aseguradora = document.form0.aseguradora.value;
abrir_ventana('../facturacion/print_corte_cuentas.jsp?empresa='+aseguradora);
}
function transCargos(fg)
{
	var dia =0; 
	if(fg=='TC')
	{
	  dia=getDBData('<%=request.getContextPath()%>','case when trunc(sysdate)-to_date(\'01/\'||to_char(sysdate,\'mm/yyyy\'),\'dd/mm/yyyy\') <= 3 then 0 else 1 end','dual ','');
	  if(dia==0)
	  abrir_ventana1('../facturacion/transferir_cargos_admision.jsp?fp=trans'+fg+'&fg='+fg+'&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&admRoot=<%=admRoot%>');
	  else alert('NO puede ejecutar este Proceso, la Fecha Actual debe estar entre los tres (3) primeros días del mes... ');
	}
	else if(fg=='CBB')
	{
		abrir_ventana1('../facturacion/transferir_cargos_admision.jsp?fp=trans'+fg+'&fg='+fg+'&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&admRoot=<%=admRoot%>&cedulaPasaporte=<%=cedulaPasaporte%>');
	}
	else abrir_ventana1('../facturacion/transferir_cargos_admision.jsp?fp=trans'+fg+'&fg='+fg+'&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&admRoot=<%=admRoot%>');
}
function refrescaAdm()
{
//alert('xyz');
//closeChildWin();
parent.window.location.reload(true);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%if(fg.trim().equals("")){%>
<%@ include file="../common/menu_base.jsp"%>
<%}%>
	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURACIÓN - TRANSFERENCIA DE CARGOS"></jsp:param>
	</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("fg",""+fg)%>
			<%=fb.hidden("pacId",""+pacId)%>
			<%=fb.hidden("noAdmision",""+noAdmision)%>
			<tr class="TextHeader">
				<td colspan="3"><cellbytelabel>TRANSFERENCIA DE CARGOS</cellbytelabel></td>
			</tr>
				<authtype type='54'>
					<tr class="TextRow01"> 
						<td colspan="3"><%=fb.radio("reporte1","CBB",true,false,false,null,null,"onClick=\"javascript:transCargos(this.value)\"")%>
						<cellbytelabel>Transferencia De Cargos de Bebe A Madre</cellbytelabel>.</td>
					</tr>
				</authtype>
                <authtype type='51'>
					<tr class="TextRow01"> 
						<td colspan="3"><%=fb.radio("reporte1","TC",false,false,false,null,null,"onClick=\"javascript:transCargos(this.value)\"")%>
						<cellbytelabel>Transferencia De Cargos por Corte de Cuenta</cellbytelabel>.</td>
					</tr>
				</authtype>
				<authtype type='52'>
					<tr class="TextRow02"> 
						<td colspan="3"><%=fb.radio("reporte1","TPI",false,false,false,null,null,"onClick=\"javascript:transCargos(this.value)\"")%>
						<cellbytelabel>Transferencia De Cargos de Admisión Particular - Internacional ó  Internacional - Particular </cellbytelabel>.</td>
					</tr>
				</authtype>
				<tr class="TextRow02"> 
						<td colspan="3" align="center"><%=fb.button("cancel","Cancelar",false,false,"Text10",null,"onClick=\"javascript:parent.hidePopWin(false);\"")%></td>
					</tr>
				
	<%=fb.formEnd(true)%>
	<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
		
</td></tr>
		

</table>
</body>
</html>
<%
}//GET
%>
