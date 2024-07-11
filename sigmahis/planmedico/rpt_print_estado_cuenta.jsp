<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
StringBuffer sbSql = new StringBuffer();
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String codigo = request.getParameter("codigo");
String contrato = request.getParameter("contrato");

sbSql.append("select id_cliente from tbl_pm_solicitud_contrato where id = ");
sbSql.append(contrato);
CommonDataObject _ci = SQLMgr.getData(sbSql.toString());
codigo = _ci.getColValue("id_cliente");
sbSql = new StringBuffer();
sbSql.append("select nvl(to_char((select min(least(fecha_ini_plan,fecha_creacion)) from tbl_pm_solicitud_contrato c where c.id_cliente = ");//toma la fecha min entre ambas
sbSql.append(codigo);
sbSql.append("),'dd/mm/yyyy'),'01/'||to_char(sysdate,'mm/yyyy')) as fecha_ini, to_char(sysdate,'dd/mm/yyyy') as fecha_fin from dual");
CommonDataObject _si = SQLMgr.getData(sbSql.toString());

	
	if(fecha_ini==null || fecha_ini.equals("")) fecha_ini = _si.getColValue("fecha_ini");
	if(fecha_fin==null || fecha_fin.equals("")) fecha_fin = _si.getColValue("fecha_fin");

String redirectFile = "../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_estado_cuenta.rptdesign&fecha_ini="+fecha_ini+"&fecha_fin="+fecha_fin+"&contrato="+contrato+"&codigo="+codigo;
System.out.println("redirectFile="+redirectFile);
if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function closeWindow(){window.close();}
function buscar(){
var fechaIni = document.formPrinted.fechaIni.value;
var fechaFin = document.formPrinted.fechaFin.value;
window.location = '../planmedico/rpt_print_estado_cuenta.jsp?codigo=<%=codigo%>&contrato=<%=contrato%>&fecha_ini='+fechaIni+'&fecha_fin='+fechaFin;
}
</script>
</head>
<body>
<table width="100%" height="100%" cellpadding="5" cellspacing="0" align="center">
<%fb = new FormBean("formPrinted",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("contrato", contrato)%>
<tr class="TextRow02">
	<td align="center" class="TableBorder">
		Fecha:
		<%if(UserDet.getUserProfile().contains("0")){%>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="2" />
		<jsp:param name="nameOfTBox1" value="fechaIni" />
		<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
		<jsp:param name="nameOfTBox2" value="fechaFin" />
		<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="buttonClass" value="Text10" />
		</jsp:include>
		<%} else {%>
		<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="noOfDateTBox" value="1" />
		<jsp:param name="nameOfTBox1" value="fechaIni" />
		<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
		<jsp:param name="fieldClass" value="Text10" />
		<jsp:param name="buttonClass" value="Text10" />
		</jsp:include>
		<%=fb.textBox("fechaFin",fecha_fin,false,false,true,10,"Text10",null,null)%>
		<%}%>
		<%=fb.button("_filtrar","Filtrar",false,false,null,null,"onClick=\"javascript:buscar();\"")%>
		<%=fb.button("close","Cerrar",false,false,null,null,"onClick=\"javascript:window.close();\"")%>
	</td>
</tr>

<%=fb.formEnd(true)%>
</table>
<div class="dhtmlgoodies_aTab">
<iframe name="cargos_net" id="cargos_net" frameborder="0" align="center" width="100%" height="550" scrolling="no" src="<%=redirectFile%>"></iframe>
</div>
</body>
</html>
<%
}//GET
%>