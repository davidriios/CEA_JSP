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
  var mes     = document.form0.mes.value;
  var contrato     = document.form0.contrato.value||'ALL';
  var plan     = document.form0.afiliados.value||'ALL';
  var responsable     = document.form0.responsable.value||'ALL';
  var identificacion     = document.form0.identificacion.value||'ALL';
  var estado     = document.form0.estado.value||'ALL';
	if(anio=='') alert('Introduzca año!');
	else if(value=="1")
	{
 	abrir_ventana("../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_cxc_pm_detalle.rptdesign&anioParam="+anio+"&mesParam="+mes+"&contratoParam="+contrato+"&planParam="+plan+"&responsableParam="+responsable+"&idenParam="+identificacion+"&estado="+estado);
	}

}

function addCliente(){
	abrir_ventana('../planmedico/pm_sel_cliente.jsp?fp=rep_cxc_detalle&fg=responsable');
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
				   <td width="20%"><cellbytelabel>No. Contrato:</cellbytelabel></td>
				   <td width="40%">
					 <%=fb.textBox("contrato","",false,false,false,20,20,"Text10",null,null)%>
					 </td>
				   <td width="40%">Plan:
  				  <%if(cuota.equals("SF")){%>
						<%=fb.select("afiliados","1=1 - 2 Afiliados,2=3 - 4 Afiliados, 3 = 5 y mas Afiliados","","T")%>
						<%} else if(cuota.equals("SFE")){%>
						<%=fb.select("afiliados","1=PLAN FAMILIAR,2=PLAN TERCERA EDAD", "", "T")%>
						<%}%>
					 </td>
			  </tr>
				<tr class="TextFilter" >
				   <td><cellbytelabel>Responsable:</cellbytelabel></td>
				   <td>
					 <%=fb.hidden("id_responsable","")%>
					 <%=fb.textBox("responsable","",false,false,false,50,20,"Text10",null,null)%>
					 <%=fb.button("btncliente","...",true,viewMode,null,null,"onClick=\"javascript:addCliente()\"")%>
					 </td>
				   <td>Identificaci&oacute;n
					 <%=fb.textBox("identificacion","",false,false,false,30,20,"Text10",null,null)%>
					 </td>
			  </tr>
				<tr class="TextFilter" >
				   <td><cellbytelabel>A&ntilde;o/Mes:</cellbytelabel></td>
				   <td><%=fb.textBox("anio",anio,true,false,(mode.equals("edit")),5,4,"Text12","","")%>
					 <%=fb.select("mes","01=Enero, 02=Febrero, 03=Marzo, 04=Abril, 05=Mayo, 06=Junio, 07=Julio, 08=Agosto, 09 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",mes,false,false,false,0,"Text12","","","","")%>
		           </td>
				   <td>Estado:
					 <%=fb.select("estado","A=Activo,I=Inactivo,P=Pendiente, F=Finalizado","A",false,false,false,0,"Text12","","","","T")%>
		           </td>
			  </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTE</cellbytelabel></td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>CXC Detalle</cellbytelabel></td>
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
