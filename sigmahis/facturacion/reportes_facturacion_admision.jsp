<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr"/>

<!-- Pantalla: "Reportes de Admisiones Facturadas"                  -->
<!-- Reportes: ADM3082                                              -->
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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Reporte de Facturación de Admisiones- '+document.title;
function doAction()
{
}

function showReporte(value, xtraOpt)
{
	var categoria    = document.form0.categoria.value;
	var tipoAdmision = document.form0.tipoAdmision.value;
	var area         = document.form0.area.value;
	var aseguradora  = document.form0.aseguradora.value;
	var fechaini     = document.form0.fechaini.value;
	var fechafin     = document.form0.fechafin.value;
	var tipoResidencia  = document.form0.tipoResidencia.value;
	var estado_adm  = document.form0.estado_adm.value;
	var admType = document.form0.admType.value;
    
    debug(value)

	if(value=="1")
	{
 abrir_ventana2('../facturacion/print_admision_fact_tipo_residencia.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&tipoResidencia='+tipoResidencia);
	}
	else if(value=="2"){
	 if(!xtraOpt)abrir_ventana2('../facturacion/print_admisiones_sin_facturar.jsp?categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fechaini='+fechaini+'&fechafin='+fechafin+'&estado_adm='+estado_adm+'&admType='+admType);
     else {
        fechaini = $("#fechaini").toRptFormat();
        fechafin = $("#fechafin").toRptFormat();
        abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_admisiones_sin_facturar.rptdesign&categoria='+categoria+'&tipoAdmision='+tipoAdmision+'&area='+area+'&aseguradora='+aseguradora+'&fDesde='+fechaini+'&fHasta='+fechafin+'&estado_adm='+estado_adm+'&pAdmType='+admType+'&pCtrlHeader=false');
        }
   }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTES DE FACTURACION DE ADMISIONES"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
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
	 <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter" >
					 <td width="8"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
					 <td width="92%">
		<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
		&nbsp;&nbsp;Tipo: <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','HOSPITALIZADOS','AMBULATORIOS') categoria from tbl_adm_categoria_admision order by 1","admType","","T")%>
					 </td>
				</tr>

				<tr class="TextFilter">
						<td width="8%"><cellbytelabel>Tipo Admisi&oacute;n</cellbytelabel></td>
						<td width="92%"><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo tipoAdmision from tbl_adm_tipo_admision_cia order by 2","tipoAdmision",tipoAdmision,"T")%>
							</td>
					 </tr>

				<tr class="TextFilter">
						<td width="8%"><cellbytelabel>&Aacute;rea de Servicio</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A' and si_no = 'S' and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by 2","area",area,"T")%>
					</td>
				</tr>
				<tr class="TextFilter">
					<td width="8%"><cellbytelabel>Aseguradora</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,nombre||' - '||codigo codEmpresa from tbl_adm_empresa /*where tipo_empresa in(2,5)*/ order by 2","aseguradora",aseguradora,"T")%>
					</td>
				</tr>

				<tr class="TextFilter" >
					 <td width="50%"><cellbytelabel>Fecha</cellbytelabel></td>
					 <td width="50%">
			<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fechaini"/>
					<jsp:param name="valueOfTBox1" value="<%=cDateTime%>"/>
					<jsp:param name="nameOfTBox2" value="fechafin"/>
					<jsp:param name="valueOfTBox2" value="<%=cDateTime%>"/>
			</jsp:include>
							 </td>
				</tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES DE FACTURACION</cellbytelabel></td>
				</tr>

				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>Generales</cellbytelabel></td>
				</tr>

				<tr class="TextRow01">
					<td><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Admisiones facturadas seg&uacute;n tipo de residencia</cellbytelabel></td>
					<td>&nbsp;&nbsp;Tipo Residencia:&nbsp;<%=fb.select("tipoResidencia","T=TEMPORAL,P=PERMANENTE","",false,false,0,"",null,null,null," ")%></td>
				</tr>

				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Admisiones sin Facturar</cellbytelabel>&nbsp;
                    <a href="javascript:showReporte(2,2)" class="Link00Bold">Excel</a>
                    <%=fb.select("estado_adm","A=Activa, E=En espera","",false,false,0,"T")%></td>
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
