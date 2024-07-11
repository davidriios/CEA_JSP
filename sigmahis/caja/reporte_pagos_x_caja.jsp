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
String mode = request.getParameter("mode");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

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
document.title = 'Reporte de Cajas- '+document.title;
function showCajera()
{
abrir_ventana2('../caja/mantenimientoturno_cajeros_list.jsp?id=2');
}
function showCaja()
{
abrir_ventana2('../caja/compania_caja_list.jsp?fp=reporte');
}
function showTurno()
{
var fechaini = document.form0.fecha_ini.value ;
var caja  = document.form0.caja.value ;
var cajera = document.form0.name_cajera.value ;
abrir_ventana2('../caja/turnos_list.jsp?caja='+caja+'&cajera='+cajera+'&fecha_desde='+fechaini);
}

function doAction()
{
}
function showReporte(id)
{
var msg= '';
var com = <%=(String) session.getAttribute("_companyId")%>;
var fechaini = eval('document.form0.fecha_ini').value ;
var turno  = eval('document.form0.turno').value ;
var caja  = eval('document.form0.caja').value ;
var descCaja = '';//eval('document.form0.name_caja').value ;
var descCajera = eval('document.form0.name_cajera').value ;

if(com == "")
msg = ', compañia';
if(fechaini == "")
msg = ', Fecha Inicial';
if(turno == "")
msg = ', Turno';
if(caja == "")
msg = ', Caja';
if(msg == ""){
if(id=="0")
abrir_ventana2('../caja/print_caja_pagos.jsp?fp=reporte&compania='+com+'&turno='+turno+'&caja='+caja+'&fechaini='+fechaini+'&descCaja='+descCaja+'&descCajera='+descCajera);
else if(id=="1")
abrir_ventana2('../caja/print_caja_pagos_recibos.jsp?fp=reporte&compania='+com+'&turno='+turno+'&caja='+caja+'&fecha_ini='+fechaini+'&descCaja='+descCaja+'&descCajera='+descCajera);

}else alert('Introduzca Valor en '+msg);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE CAJAS"></jsp:param>
</jsp:include>
<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>  
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"> 
		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
				<tr class="TextHeader">
							<td colspan="4"><cellbytelabel>Reporte de Pagos x Caja</cellbytelabel></td>
				</tr>
				<!--
        <tr class="TextRow01"> 
					<td>Compania</td>
					<td colspan="3">
  				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || nombre descripcion from tbl_sec_compania where estado = 'A' order by nombre asc","conpania",(String) session.getAttribute("_companyId"),false,viewMode,0,null,null,"")%>
					<%//=fb.textBox("compania",(String) session.getAttribute("_companyId"),true,false,false,5)%></td>
				</tr>
        -->
				<tr class="TextRow01"> 
					<td><cellbytelabel>Caja</cellbytelabel></td>
					<td colspan="3">
         	<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion asc","caja","",false,false,0,"text10",null,"", "", "S")%>
				</tr>
				<tr class="TextRow01"> 
					<td><cellbytelabel>Cajera</cellbytelabel></td>
					<td colspan="3">
  				<%=fb.textBox("cajera","",true,false,false,5)%>
					<%=fb.textBox("name_cajera","",false,false,true,30)%>
					<%=fb.button("addCajera","...",true,false,null,null,"onClick=\"javascript:showCajera()\"","Agregar Cajera")%></td>
				</tr>
				
				
				
				<tr class="TextRow01"> 
					<td width="25%"><cellbytelabel>Desde</cellbytelabel></td>
					<td width="25%" colspan="3"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha_ini" />
											<jsp:param name="valueOfTBox1" value="" />
											</jsp:include></td>
				
				</tr>
				<tr class="TextRow01"> 
					<td><strong><cellbytelabel>Turno</cellbytelabel></td>
					<td colspan="3">
  				<%=fb.textBox("turno","",true,false,false,5)%>
					<%=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Seleccionar Turno")%></td>
          </td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="4" align="center">
					<%=fb.button("addReporte","Reporte",false,false,null,null,"onClick=\"javascript:showReporte(0)\"","Reporte de Cajas")%>
					<%=fb.button("addReporteR","Reporte Resumido",false,false,null,null,"onClick=\"javascript:showReporte(1)\"","Reporte Resumido")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			
	<%fb.appendJsValidation("if(error>0)doAction();");%>		
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
%>