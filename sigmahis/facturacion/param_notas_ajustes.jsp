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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!"); /*quitar el comentario*** */

UserDet = SecMgr.getUserDetails(session.getId());  /* *** quitar el comentario **** */
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
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String fg = request.getParameter("fg");

if (mode == null) mode = "add";
if (fg == null) fg = "";

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
document.title = 'Consumo por Centro de Servicio - '+document.title;
function doAction()
{
}

function showReporte(value)
{
	var fechaini     = eval('document.form0.fechaini').value;
  	var fechafin     = eval('document.form0.fechafin').value;
	var tipo     = eval('document.form0.tipo').value;
	var pacId     = eval('document.form0.pacId').value;
	var factId     = eval('document.form0.factura').value;
	var cds     = eval('document.form0.cds').value;
	var tipoAj     = eval('document.form0.tipoAj').value;
	var tipoFecha     = eval('document.form0.tipoFecha').value;
	var aseguradora     = eval('document.form0.aseguradora').value;
	var aseguradoraDesc     = eval('document.form0.aseguradoraDesc').value;
    var fact     = eval('document.form0.fact').value;
	if(aseguradora==''){aseguradoraDesc='';eval('document.form0.aseguradoraDesc').value='';}
	if(value=='1')
	{
		var tipoUsuario  = eval('document.form0.tipoUser').value;
		var usuario      = eval('document.form0.usuario').value;
		var libro        = '';
		if(eval('document.form0.libro').checked)libro='S';
 	abrir_ventana('../facturacion/print_ingresos_notas_ajustes.jsp?fp=T&fg='+tipo+'&fechaIni='+fechaini+'&fechaFin='+fechafin+"&pacId="+pacId+"&factId="+factId+'&tipoUsuario='+tipoUsuario+'&usuario='+usuario+'&cds='+cds+'&tipoAj='+tipoAj+'&tipoFecha='+tipoFecha+'&libro='+libro+'&aseguradora='+aseguradora+'&aseguradoraDesc='+aseguradoraDesc+'&factA='+fact);
	}
	else if(value=='2')
	{
 	abrir_ventana('../facturacion/print_descuentos_x_cds_ajuste.jsp?fg='+tipo+'&fechaIni='+fechaini+'&fechaFin='+fechafin+"&pacId="+pacId+"&factId="+factId+'&cds='+cds+'&tipoAj='+tipoAj+'&tipoFecha='+tipoFecha+'&aseguradora='+aseguradora+'&aseguradoraDesc='+aseguradoraDesc);
	}
	else if(value=='3')
	{
 	abrir_ventana('../facturacion/print_ingresos_x_ajustes_cds.jsp?fg='+tipo+'&fechaIni='+fechaini+'&fechaFin='+fechafin+"&pacId="+pacId+"&factId="+factId+'&cds='+cds+'&tipoAj='+tipoAj+'&tipoFecha='+tipoFecha+'&aseguradora='+aseguradora+'&aseguradoraDesc='+aseguradoraDesc);
	}
}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=facturacionAj');}
function showPacienteList(){abrir_ventana1('../common/search_paciente.jsp?fp=facturacion');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR CENTRO"></jsp:param>
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
				   <td width="50%"><cellbytelabel>Fecha</cellbytelabel>&nbsp;&nbsp;<%=fb.select("tipoFecha","C=CREACION,A=APROBACION","A",false,false,0,"Text10",null,null,null,"")%></td>
				   <td width="50%">
			<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="2" />
        	<jsp:param name="clearOption" value="true" />
        	<jsp:param name="nameOfTBox1" value="fechaini" />
        	<jsp:param name="valueOfTBox1" value="" />
          <jsp:param name="nameOfTBox2" value="fechafin" />
        	<jsp:param name="valueOfTBox2" value="" />
			</jsp:include>
		           </td>
			  </tr>


			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Tipo Doc</cellbytelabel>. </td>
				   <td width="85%"><%=fb.select("tipo","F=FACTURA,R=RECIBO","F",false,false,0,"Text10",null,null,null,"")%></td>
			</tr>
			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Factura De:</cellbytelabel>. </td>
				   <td width="85%"><%=fb.select("fact","P=PACIENTE,E=EMPRESA,O=OTROS","",false,false,0,"Text10",null,null,null,"S")%></td>
			</tr>
			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Factura</cellbytelabel></td>
				   <td width="85%"> <%=fb.textBox("factura","",false,false,false,15,"Text10",null,null)%></td>
			</tr>
			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Paciente</cellbytelabel></td>
				   <td width="85%">
                  <%=fb.intBox("pacId","",false,false,false,5,"Text10",null,null)%>
									<%=fb.textBox("nombre","",false,false,true,35,"Text10",null,null)%>
                  <%=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
           			</td>
			</tr>
			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Usuario</cellbytelabel>&nbsp;&nbsp;&nbsp;<%=fb.select("tipoUser","C=CREACION,A=APROBACION","",false,false,0,"Text10",null,null,null,"S")%></td>
				   <td width="85%"><%=fb.textBox("usuario","",false,false,false,15,"Text10",null,null)%>
                  <%//=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
           			</td>
			</tr>
			<tr class="TextFilter">
				    <td><cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td>
					<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by descripcion","cds","","T")%>

					</td>
				</tr>
			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Tipo Ajuste</cellbytelabel></td>
				   <td width="85%"><%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo descripcion from tbl_fac_tipo_ajuste where estatus ='A' and compania = "+(String) session.getAttribute("_companyId")+" order by 1","tipoAj","","T")%>
                  <%//=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
           			</td>
			</tr>
			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Grupo Ajuste</cellbytelabel></td>
				   <td width="85%"><%=fb.select(ConMgr.getConnection(),"select id,description||' - '||id description from tbl_fac_adjustment_group where status ='A' order by 1","grupo","","T")%>
                  <%//=fb.button("btnPac","...",true,false,"Text10",null,"onClick=\"javascript:showPacienteList()\"")%>
           			</td>
			</tr>
			<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Para Libro Ingreso</cellbytelabel></td>
				   <td width="85%"><%=fb.checkbox("libro","N",false,false,"","","")%></td>
			</tr>
			<tr class="TextFilter" >
				   <td><cellbytelabel>Aseguradora</cellbytelabel></td>
				   <td>
                  <%=fb.intBox("aseguradora","",false,false,false,5,"Text10",null,null)%>
									<%=fb.textBox("aseguradoraDesc","",false,false,true,35,"Text10",null,null)%>
                  <%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
           </td>
		</tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"><authtype type='50'><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Notas de Ajustes</cellbytelabel>
					</authtype></td>
        		</tr>
				<tr class="TextRow01">
					<td colspan="2"><authtype type='51'><%=fb.radio("reporte1","2",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Notas de Ajustes a Facturas (Descuentos x CdS)</authtype></td>
        		</tr>
				<tr class="TextRow01">
					<td colspan="2"><authtype type='52'><%=fb.radio("reporte1","3",false,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Notas de Ajustes a Facturas (Centros y Tipos de Servicio)</cellbytelabel></authtype></td>
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
