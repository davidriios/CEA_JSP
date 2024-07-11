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
String caja = request.getParameter("caja");
String turno = request.getParameter("turno");
String com = request.getParameter("com");
String ip = request.getRemoteAddr();
String mode = request.getParameter("mode");
boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (request.getMethod().equalsIgnoreCase("GET"))
{
sql="select a.descripcion,codigo as caja from tbl_cja_cajas a where a.codigo ="+caja;
if (caja != null) cdo = SQLMgr.getData(sql);



%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>                     
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reporte de Cajas- '+document.title;
function doAction()
{
}
function showTurno()
{
var msg= '';
var fechaini = eval('document.form0.fecha_ini').value ;
var fechafin = eval('document.form0.fecha_fin').value ;
var usuario  = eval('document.form0.usuario').value ;

if(msg == ""){
<%if(com.trim().equals("4")){%>
abrir_ventana2('../caja/turnos_cajas_list.jsp?fp=reporte_com4&fechaini='+fechaini+'&fechafin='+fechafin+'&usuario='+usuario+"&com=<%=com%>");
<%}else{%>
abrir_ventana2('../caja/turnos_cajas_list.jsp?fp=reporte&fechaini='+fechaini+'&fechafin='+fechafin+'&usuario='+usuario+"&com=<%=com%>");
<%}%>
}else{ alert('Complete los Campos '+msg);}
}
function showCaja()
{
abrir_ventana2('../caja/compania_caja_list.jsp?fp=reporte');
}
function showReporte()
{
var msg= '';
var fechaini = eval('document.form0.fecha_ini').value ;
var fechafin = eval('document.form0.fecha_fin').value ;
var usuario  ="";// (eval('document.form0.usuario').value).toLowerCase() ;
var turno  = eval('document.form0.turno').value ;
var caja  = eval('document.form0.caja').value ;
if(fechaini == "")
msg = ', Fecha Inicial';
if(fechafin == "")
msg = ', Fecha Final';
//if(usuario == "")msg = ', Usuario';
if(turno == "")
msg = ', Turno';
if(caja == "")
msg = ', Caja';
if(msg == ""){
abrir_ventana2('../caja/print_reporte_deposito.jsp?fp=reporte&compania=<%=com%>&turno='+turno+'&caja='+caja+'&usuario='+usuario+'&fechaini='+fechaini+'&fechafin='+fechafin);
}else alert('Introduzca Valor en '+msg);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE CAJAS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">   
	<tr>  
		<td>   
		
		<table align="center" width="75%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
				<tr class="TextHeader">
							<td colspan="4"><cellbytelabel>Reporte de Registros de Depósitos Bancarios</cellbytelabel>[ <cellbytelabel>Seccion Cajas</cellbytelabel>]</td>
				</tr>
				<tr class="TextRow01"> 
					<td><cellbytelabel>Caja</cellbytelabel></td>
					<td colspan="3">
  				<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+" /*and ip = '"+ip+"'*/ order by descripcion asc","caja",cdo.getColValue("caja"),false,viewMode,0,null,null,"")%></td>
				</tr>
				<!--<tr class="TextRow01"> 
					<td><cellbytelabel>Usuario</cellbytelabel></td>
					<td colspan="3">
  				<%=fb.textBox("usuario",(String) session.getAttribute("_userName"),false,false,false,30)%></td>
				</tr>-->
				
				<tr class="TextRow01"> 
					<td width="25%"><cellbytelabel>Desde</cellbytelabel></td>
					<td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha_ini" />
											<jsp:param name="valueOfTBox1" value="" />
											</jsp:include></td>
					<td width="25%"><cellbytelabel>hasta</cellbytelabel></td>
					<td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fecha_fin" />
											<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,10)%>" />
											</jsp:include></td>
				</tr>
				<tr class="TextRow01"> 
					<td><cellbytelabel>Turno</cellbytelabel></td>
					<td colspan="3">
  				<%=fb.textBox("turno",turno,true,false,true,5)%>
					<%=fb.textBox("name_turno",cdo.getColValue("nombre"),false,false,true,30)%>
					<%=fb.button("addTurno","...",true,true,null,null,"onClick=\"javascript:showTurno()\"","Agregar Turno")%></td>
				</tr>
				<tr class="TextRow01"> 
					<td colspan="4" align="center"><%=fb.button("addReporte","Reporte",false,false,null,null,"onClick=\"javascript:showReporte()\"","Reporte de Cajas")%>
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