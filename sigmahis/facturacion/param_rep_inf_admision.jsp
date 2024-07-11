<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
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

String sql = "";
String mode = request.getParameter("mode");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String fg = request.getParameter("fg");

if (mode == null) mode = "add";
if (fg == null) fg = "RE";

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

function showReporte(value){
  var anio     		= document.form0.anio.value;
  var mes     		= document.form0.mes.value;
	var categoria   = document.form0.categoria2.value;
	var pacId     	= document.form0.pacId.value;
	var aseguradora	= document.form0.aseguradora.value;
	var admType     = document.form0.categoria.value;
	var cds     		= document.form0.cds.value;

	if(anio != ''){
		if(value=='1'){
		abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/informe_axa.rptdesign&categoriaParam='+categoria+'&anioParam='+anio+'&mesParam='+mes+"&pacIdParam="+pacId+"&aseguradoraParam="+aseguradora+"&admTypeParam="+admType);
		}
		
	} else alert('Anio');
}
function showEmpresaList()
{
	abrir_ventana1('../common/search_empresa.jsp?fp=facturacion');
}
function showPacienteList()
{
	abrir_ventana1('../common/search_paciente.jsp?fp=facturacion');
}
function showPaciente()
{
	abrir_ventana1('../common/sel_paciente.jsp?fp=SALDO');
}

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
			  <%if(fg.trim().equals("RE")){%>
			  <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Tipo de Categor&iacute;a</cellbytelabel></td>
				   <td width="85%">
           <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%>
           </td>
			  </tr>
         <tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
				   <td width="85%">
           <%=fb.select(ConMgr.getConnection(),"select distinct  codigo,descripcion||' - '||codigo from tbl_adm_categoria_admision order by 1","categoria2","","T")%>
           </td>
			  </tr>

				<tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>A&ntilde;o/Mes:</cellbytelabel></td>
				   <td width="50%"><%=fb.intBox("anio","",false,false,false,5,"Text10",null,null)%><%=fb.select("mes","01=Enero, 02=Febrero, 03=Marzo, 04=Abril, 05=Mayo, 06=Junio, 07=Julio, 08=Agosto, 09=Septiembre, 10=Octubre, 11=Noviembre, 12=Diciembre","",false,false,0,"Text10",null,null,null,"T")%>
		           </td>
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
				   <td width="15%"><cellbytelabel>Aseguradora</cellbytelabel></td>
				   <td width="85%">
                  <%=fb.intBox("aseguradora","",false,false,false,5,"Text10",null,null)%>
									<%=fb.textBox("aseguradoraDesc","",false,false,true,35,"Text10",null,null)%>
                  <%=fb.button("btnAseg","...",true,false,"Text10",null,"onClick=\"javascript:showEmpresaList()\"")%>
           </td>
		</tr>
		 <tr class="TextFilter">
				<td><cellbytelabel>Centro de Servicio</cellbytelabel></td>
				<td><%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by descripcion","cds","","T")%>

				</td>
		</tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>
				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%><cellbytelabel>Informe</cellbytelabel></td>
				</tr>
				</authtype>
								   
												   
				
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
