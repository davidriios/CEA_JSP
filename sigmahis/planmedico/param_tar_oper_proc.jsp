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
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String cuota = "";
	StringBuffer sbSql = new StringBuffer();
	sbSql.append("select get_sec_comp_param(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CALC_CUOTA_PLAN_MED') cuota, get_sec_comp_param(-1, 'COD_PARENTESCO_HIJO') COD_PARENTESCO_HIJO from dual");
	CommonDataObject _cdP = SQLMgr.getData(sbSql.toString());
	ArrayList alTipoEmp = sbb.getBeanList(ConMgr.getConnection(), "select id as optValueColumn, nombre as optLabelColumn, id||'-'||nombre as optTitleColumn from tbl_pm_centros_atencion ", CommonDataObject.class);

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
  var anio     = document.form0.anio.value;
  var mes     = document.form0.mes.value;
  var mesDesc = $( "#mes option:selected" ).text();
	if(anio=='') alert('Introduzca Año!');
	else if(value=="1")
	{
 	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_tar_oper_proc.rptdesign&anioParam="+anio+"&mesParam="+mes+'&mes_desc='+mesDesc);
	}
		else if(value=="2")
	{
		
 	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_hon_pagado_x_especialidad.rptdesign&anio="+anio+"&mes="+mes+'&mes_desc='+mesDesc);
	}

}

function addCliente(){
	abrir_ventana('../common/search_paciente_pm.jsp?fp=hist_reclamo');
}

function addCorredor(){
abrir_ventana('../planmedico/pm_sel_corredor.jsp?fp=hist_comision');
}

function searchMedicoOrEmpreList(){
       var isSociedad = $("#pagar_sociedad").is(":checked");
       if (isSociedad) abrir_ventana1('../common/search_empresa.jsp?fp=hist_reclamo');
       else abrir_ventana1('../common/search_medico.jsp?fp=hist_reclamo');
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
				   <td width=""><cellbytelabel>A&ntilde;o:</cellbytelabel></td>
				   <td width="">
					 <%=fb.textBox("anio",anio,false,false,false,5,4,"Text10",null,null)%>
					 </td>
				   <td><cellbytelabel>Mes:</cellbytelabel></td>
				   <td>
					 <%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE",mes, true, false, viewMode, 0,"","","",null,"S")%>
					 </td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTE</cellbytelabel></td>
				</tr>
				<%if(fg.equals("")){%>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Reporte</cellbytelabel></td>
				</tr>
				<%} else {%>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Reporte</cellbytelabel></td>
				</tr>
				<%}%>
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
