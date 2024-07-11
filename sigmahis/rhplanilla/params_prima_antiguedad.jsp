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
boolean viewMode = false;
String sala = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes  = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String dia  = CmnMgr.getCurrentDate("dd");
String tipoCuenta = "", grupoDesc = "";
String descontar = "", eliminar = "", pendiente = "", noDescontar = "";

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
<script>
document.title = 'Prima Antiguedad - '+document.title;
function doAction(){}
function addEmpleado(){
 abrir_ventana("../common/search_empleado.jsp?fp=prima_antiguedad"); 
}

$(function() {
	$("#btn_print").click(function(e){
		var empId = $("#id").val() || '0';
		var cedula = $.trim($("#cedula").val()) || '0';
		var fIngresoFrom = $("#ingreso_desde").toRptFormat() || '1970-01-01';
		var fIngresoTo = $("#ingreso_hasta").toRptFormat() || '1970-01-01';
		var fEgresoFrom = $("#egreso_desde").toRptFormat() || '1970-01-01';
		var fEgresoTo = $("#egreso_hasta").toRptFormat() || '1970-01-01';
		var fechaCierre = $("#fecha_cierre").toRptFormat();
		var pCtrlHeader = $("#pCtrlHeader").is(":checked");
		
		if (!fechaCierre) alert("Por favor indicar el Escenario Fecha Cierre.")
		else
		
		if ((fIngresoFrom && fIngresoTo) || (fEgresoFrom && fEgresoTo)) abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_prima_antiguedad.rptdesign&pCtrlHeader='+pCtrlHeader+'&emp_id='+empId+'&cedula='+cedula+'&ingreso_desde='+fIngresoFrom+'&ingreso_hasta='+fIngresoTo+'&egreso_desde='+fEgresoFrom+'&egreso_hasta='+fEgresoTo+'&fecha_cierre='+fechaCierre)
	});
});
</script>  
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE ACREEDORES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
<tr>
 <td>
   <table align="center" width="50%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="0" cellspacing="1">
        
          <tr class="TextHeader">
            <td align="center">Parámetros</td>
          </tr>
      
          <tr class="TextRow01">  
            <td>No. Empleado:&nbsp;
			<%=fb.intBox("id","",false,false,true,5,3,"Text10",null,null)%>
			<%=fb.textBox("idDesc","",false,false,true,50,50,"Text10",null,null)%>
			<%=fb.textBox("num","",false,false,true,5,5,"Text10",null,null)%>
			<%=fb.button("btnmotivo","Ir",true,false,null,null,"onClick=\"javascript:addEmpleado()\"")%></td>
          </tr>
		  <tr class="TextRow01">  
            <td>C&eacute;dula:&nbsp;<%=fb.textBox("cedula","",false,false,false,86,50,"Text10",null,null)%></td>
          </tr>
		  <tr class="TextRow01">  
            <td>
			Ingreso Desde
			  <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />              
				<jsp:param name="clearOption" value="true" />              
				<jsp:param name="nameOfTBox1" value="ingreso_desde" />              
				<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			  </jsp:include>			  
			  &nbsp;&nbsp;&nbsp;&nbsp;Hasta &nbsp;&nbsp;&nbsp;&nbsp;
			  <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="ingreso_hasta" />
				<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			   </jsp:include>
			
			</td>
          </tr>
		  
		  <tr class="TextRow01">  
            <td>
			Egreso Desde&nbsp;
			  <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />              
				<jsp:param name="clearOption" value="true" />              
				<jsp:param name="nameOfTBox1" value="egreso_desde" />              
				<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			  </jsp:include>			  
			  &nbsp;&nbsp;&nbsp;&nbsp;Hasta &nbsp;&nbsp;&nbsp;&nbsp;
			  <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="clearOption" value="true" />
				<jsp:param name="nameOfTBox1" value="egreso_hasta" />
				<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			   </jsp:include>
			
			</td>
          </tr>
		  
		   <tr class="TextRow01">  
            <td>
			Escenario fecha cierre&nbsp;
			  <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />              
				<jsp:param name="clearOption" value="true" />              
				<jsp:param name="nameOfTBox1" value="fecha_cierre" />              
				<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			  </jsp:include>
			
			</td>
          </tr>
		  
		  <tr class="TextRow01">  
            <td>
				<label class="pointer">
				<input type="checkbox" name="pCtrlHeader" id="pCtrlHeader" />
				Esconder la cabecera ?
				</label>
			</td>
          </tr>
		  
		  <tr class="TextRow02">  
            <td>&nbsp;</td>
          </tr>
		  
		  <tr class="TextRow01">  
            <td>
			<%=fb.button("btn_print","Imprimir (Excel)",true,false,null,null,"")%>
			</td>
          </tr>

	       		  
        
          <%=fb.formEnd(true)%>
        </table>
		  <!-- ================================   F O R M   E N D   H E R E   ================================ --></td>
	</tr>
</table>
 </td>
	</tr>
	</td>
	</tr>

</table>
</body>
</html>
<%
}//GET
%>


