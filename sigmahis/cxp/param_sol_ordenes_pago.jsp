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
<!-- Desarrollado por: José A. Acevedo C.  -->
<!-- Pantalla: Para generar reportes de Solicitudes de Órdenes de Pago -->
<!-- Reportes: OP_0004, OP_0005, OP_0006   -->
<!-- Clínica Hospital San Fernando         -->
<!-- Fecha: 17/06/2011                     -->
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
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al       = new ArrayList();
ArrayList alUnidad = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String observ = "", estado = "", unidad = "", beneficiario = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String compania = (String) session.getAttribute("_companyId");
String user     = (String) session.getAttribute("_userName");

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
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reportes de Cuentas por Pagar - '+document.title;
function doAction()
{
}

function showReporte(value)
{
	var unidad       = eval('document.form0.unidad').value;
	var beneficiario ='';// eval('document.form0.beneficiario').value;
	var estado       = eval('document.form0.estado').value;
	var observ       = '';//eval('document.form0.observ').value;
	var fechaini     = eval('document.form0.fechaini').value;
	var fechafin     = eval('document.form0.fechafin').value;
    var pCtrlHeader ="false";
	var excluirConta ="ALL";
	
	
	 if(document.form0.excluirConta)if(eval('document.form0.excluirConta').value!='') excluirConta =eval('document.form0.excluirConta').value;
	 if(document.form0.pCtrlHeader.checked==true) pCtrlHeader = "true";
	 if(value=="1")
	 {
 abrir_ventana2('../cxp/print_solic_ordenPago_x_beneficiario.jsp?unidad='+unidad+'&beneficiario='+beneficiario+'&estado='+estado+'&observ='+observ+'&fechaini='+fechaini+'&fechafin='+fechafin);
	 }
	 else if(value=="2")
	 {
	 abrir_ventana2('../cxp/print_solic_ordenPago_x_fecha.jsp?unidad='+unidad+'&beneficiario='+beneficiario+'&estado='+estado+'&observ='+observ+'&fechaini='+fechaini+'&fechafin='+fechafin).value;
	 }
	else if(value=="3")
	{
	abrir_ventana2('../cxp/print_solic_ordenPago_afecta_gasto.jsp?unidad='+unidad+'&beneficiario='+beneficiario+'&estado='+estado+'&fechaini='+fechaini+'&fechafin='+fechafin);
	}
	else if(value=="4")
	{
		var fdArray = fechaini.split("/");
	var fhArray = fechafin.split("/");
	if(unidad=='')unidad="ALL";
	fechaini = fdArray[2]+"-"+fdArray[1]+"-"+fdArray[0];
	fechafin = fhArray[2]+"-"+fhArray[1]+"-"+fhArray[0];
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=cxp/rpt_entregas_und.rptdesign&pUnidad='+unidad+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pCtrlHeader='+pCtrlHeader+'&pExcluirConta='+excluirConta+'&pAfectaConta=ALL');
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONSULTA DE ÓRDENES DE PAGO"></jsp:param>
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
					 <td width="8">Unidad</td>
					 <td width="92%">
					 
					 <%StringBuffer sbSql= new StringBuffer();
							if(!UserDet.getUserProfile().contains("0"))
							{
								sbSql.append(" and b.codigo in (");
									if(session.getAttribute("_ua")!=null)
										sbSql.append(CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")));
									else sbSql.append("-1");
								sbSql.append(")");
							}
							%>
		<%=fb.select(ConMgr.getConnection(),"select b.codigo, b.descripcion||' - '||b.codigo unidad from tbl_sec_unidad_ejec b where b.compania = "+compania+sbSql.toString()+"  order by b.descripcion","unidad",unidad,"T")%>
					 </td>
				</tr>

				<!--<tr class="TextFilter">
						<td width="8%">Beneficiario</td>
						<td width="92%">
					<%//=fb.select(ConMgr.getConnection(),"select distinct nombre, nombre nombre2 from tbl_con_pagos_otros where compania = "+compania+" and estado = 'A' order by 1","beneficiario",beneficiario,"T")%>
							</td>
					 </tr>-->

				<tr class="TextFilter">
						<td width="8%">Estado</td>
					<td width="92%">
					<%=fb.select("estado","A=APROBADA, P=PENDIENTE, T=AUTORIZADA, R=PROCESADA, N=ANULADA ",estado,false,false,0,null,null,"","","T")%>
				</td>
				</tr>
 				<tr class="TextFilter" >
					 <td width="50%">Fecha</td>
					 <td width="50%">
			Desde &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="clearOption" value="true" />
					<jsp:param name="nameOfTBox1" value="fechaini" />
					<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			</jsp:include>
						 Hasta &nbsp;&nbsp;
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="1" />
			<jsp:param name="clearOption" value="true" />
			<jsp:param name="nameOfTBox1" value="fechafin" />
			<jsp:param name="valueOfTBox1" value="<%=cDateTime%>" />
			</jsp:include>
							 </td>
				</tr>
				<tr class="TextFilter" align="left">
                            <td width="15%">Esconder Cabecera?</td>
							<td width="60%"><%=fb.checkbox("pCtrlHeader","false")%></td>
                </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<authtype type='50,51'>
				<tr class="TextHeader">
					<td colspan="2">Solicitado por:</td>
				</tr>
				</authtype>
				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Por Beneficiario</td>
				</tr>
				</authtype>
				<authtype type='51'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Por Fecha</td>
				</tr>
				</authtype>
				<authtype type='52'>
				<tr class="TextHeader">
					<td colspan="2">Afecta el Gasto:</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","3",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Afecta el Gasto de</td>
				</tr>
				</authtype>
				<authtype type='53'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","4",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Gastos de Unidad Administrativas
					&nbsp;&nbsp;&nbsp;<%=fb.select("excluirConta","S=SI","",false,false,0,null,null,"","","S")%>&nbsp;&nbsp;Solo Ordenes de Unidades Admin.
					
					</td>
				</tr>
				</authtype>
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

