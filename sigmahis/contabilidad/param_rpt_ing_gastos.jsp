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
  var anio     = document.form0.anio.value;
  var ctaPrin     = document.form0.ctaPrin.value;
  var nivel     			  = document.form0.nivel.value;
	var titulo = $('#ctaPrin option:selected').text();
	var movParam     			  = document.form0.movParam.value;
	if(anio == '') alert('Introduzca año!');
	else
		if(value=="1")
		{
			 abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_con_ing_gastos.rptdesign&anioParam="+anio+"&ctaPrincParam="+ctaPrin+"&nivelParam="+nivel+"&tituloParam="+titulo+"&movParam="+movParam+'&flag=1');
		} else if(value=="2")
		{
			 abrir_ventana("../cellbyteWV/report_container.jsp?reportName=contabilidad/rpt_con_ing_gastos_x_nivel.rptdesign&anioParam="+anio+"&ctaPrincParam="+ctaPrin+"&nivelParam="+nivel+"&tituloParam="+titulo+"&movParam="+movParam+'&flag=2');
		}

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
<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextFilter" >
				   <td width="10%"><cellbytelabel>A&ntilde;o:</cellbytelabel></td>
				   <td width="10%">
					 <%=fb.intBox("anio","",false,false,false,4,4,"Text10",null,null)%>
					 </td>
				   <td width="20%">CUENTA PRINCIPAL:</td>
					 <td width="20%"><%=fb.select(ConMgr.getConnection(),"select codigo_prin as codigo, descripcion cta_dsp from tbl_con_ctas_prin WHERE CODIGO_PRIN IN (4, 5, 6) order by descripcion","ctaPrin","",false,false,0,"Text10",null,"",null,"")%></td>
				   <td width="10%">CUENTAS:</td>
				   <td width="10%">
					 <%=fb.select("movParam","N=TODAS,S=CON MOVIMIENTO","",false,false,0,"Text10",null,null,null,"")%>
					 </td>
				   <td width="10%">NIVEL:</td>
				   <td width="10%">
					 <%=fb.select("nivel","1=1,2=2,3=3","3",false,false,0,"Text10",null,null,null,"")%>
					 </td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTE</cellbytelabel></td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Reporte hasta nivel de cuenta</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Reporte por nivel de cuenta</cellbytelabel></td>
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
