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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
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
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String cuota = "";
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CALC_CUOTA_PLAN_MED') cuota, get_sec_comp_param(-1, 'COD_PARENTESCO_HIJO') COD_PARENTESCO_HIJO from dual");
	CommonDataObject _cdP = SQLMgr.getData(sbSql.toString());

	if(_cdP==null) cuota = "SF";
	else {
		cuota = _cdP.getColValue("cuota");
	}	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Reporte de Facturación de Admisiones- '+document.title;
function doAction()
{
}

function showReporte(value)
{
  var fDesde     = document.form0.fDesde.value;
  var fHasta     = document.form0.fHasta.value;
  var contrato     = document.form0.contrato.value||'ALL';
  var plan     = document.form0.afiliados.value||'ALL';
  var responsable     = document.form0.id_responsable.value||'ALL';
  var corredor     = document.form0.id_corredor.value||'ALL';
	if(fDesde=='' || fHasta=='') alert('Introduzca Rango de Fecha!');
	else if(value=="1")
	{
 	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_hist_com_x_contrato.rptdesign&contratoParam="+contrato+"&idRespParam="+responsable+"&planParam="+plan+"&fDesdeParam="+fDesde+"&fHastaParam="+fHasta+"&corredorParam="+corredor);
	}	else if(value=="2")
	{
 	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_hist_com_x_corredor.rptdesign&contratoParam="+contrato+"&idRespParam="+responsable+"&planParam="+plan+"&fDesdeParam="+fDesde+"&fHastaParam="+fHasta+"&corredorParam="+corredor);
	}

}

function addCliente(){
	abrir_ventana('../common/search_paciente_pm.jsp?fp=hist_comision');
}

function addCorredor(){
abrir_ventana('../planmedico/pm_sel_corredor.jsp?fp=hist_comision');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CARGOS POR MONITOREO FETAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("afiliados","")%>
<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextFilter" >
				   <td width=""><cellbytelabel>No. Contrato:</cellbytelabel></td>
				   <td width="">
					 <%=fb.textBox("contrato","",false,false,false,20,20,"Text10",null,null)%>
					 </td>
				   <td><cellbytelabel>Responsable:</cellbytelabel></td>
				   <td>
					 <%=fb.hidden("id_responsable","")%>
					 <%=fb.textBox("responsable","",false,false,false,50,20,"Text10",null,null)%>
					 <%=fb.button("btncliente","...",true,viewMode,null,null,"onClick=\"javascript:addCliente()\"")%>
					 </td>
			  </tr>
				<tr class="TextFilter" >
				   <td>Corredor:</td>
					 <td>
					 <%=fb.textBox("id_corredor","",false,false,false,5,100,"Text10","","")%>
						<%=fb.textBox("nombre_corredor","",false,false,false,45,100,"Text10","","")%>
						<%=fb.button("btnCorredor","...",true,viewMode,null,null,"onClick=\"javascript:addCorredor()\"")%>
					 </td>
				   <td><cellbytelabel>Fecha</cellbytelabel></td>
				   <td>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fDesde" />
				<jsp:param name="valueOfTBox1" value="" />
				<jsp:param name="nameOfTBox2" value="fHasta" />
				<jsp:param name="valueOfTBox2" value="" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				</jsp:include>
		           </td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTE</cellbytelabel></td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Por Contrato</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Por Corredor</cellbytelabel></td>
				</tr>


<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
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
