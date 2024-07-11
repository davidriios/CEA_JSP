<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
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
if (fg == null) fg = "EC";
StringBuffer sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'TP_CLIENTE_EMP'),'N') as ref_type_emp from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());

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
document.title = 'Estado Cuenta - '+document.title;
function doAction(){}
function showReporte()
{
  var fechaini     = eval('document.form0.fechaini').value;
  var fechafin     = eval('document.form0.fechafin').value;
  var aseguradora     = eval('document.form0.aseguradora').value;
  var tipo_fecha     = 'FE';
  if(eval('document.form0.tipo_fecha'))tipo_fecha=eval('document.form0.tipo_fecha').value;
  
  var referTo ='EMPR';
  var pagos = eval('document.form0.pagos').value;
	if(aseguradora.trim()==''){CBMSG.warning('Seleccione la aseguradora');return true;}
 
if(/*fechaini != '' && */fechafin !='' )
{
 abrir_ventana('../facturacion/print_estado_cuenta_aseg.jsp?fDate='+fechaini+'&tDate='+fechafin+"&refId="+aseguradora+"&referTo="+referTo+'&refType=<%=p.getColValue("ref_type_emp")%>&pagos='+pagos+'&tipo_fecha='+tipo_fecha);
}
else CBMSG.warning('Seleccione rango de Fecha');
}
function showEmpresaList(){abrir_ventana1('../common/search_empresa.jsp?fp=facturacion');}
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
				   <td width="50%"><cellbytelabel>Fecha</cellbytelabel></td>
				   <td width="50%">
			<jsp:include page="../common/calendar.jsp" flush="true">
        	<jsp:param name="noOfDateTBox" value="2" />
        	<jsp:param name="clearOption" value="true" />
        	<jsp:param name="nameOfTBox1" value="fechaini" />
        	<jsp:param name="valueOfTBox1" value="" />
          <jsp:param name="nameOfTBox2" value="fechafin" />
        	<jsp:param name="valueOfTBox2" value="<%=CmnMgr.getCurrentDate("dd/mm/yyyy")%>" />
			</jsp:include>
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
		<!--<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Tipo Fecha</cellbytelabel></td>
				   <td width="85%"><%=fb.select("tipo_fecha","FE=FECHA ENVIO DE FACTURAS,FF=FECHA DE FACTURAS","",false,false,0,"Text10",null,"")%></td>
		</tr>-->
		<tr class="TextFilter" >
				   <td width="15%"><cellbytelabel>Pagos???</cellbytelabel></td>
				   <td width="85%"><%=fb.select("pagos","SP=FACTURAS SIN PAGOS,PP=FACTURAS CON PAGOS PARCIALES","",false,false,0,"Text10",null,null,null,"SP")%></td>
		</tr>
		 
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>
				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="2"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte()\"")%><cellbytelabel>Estado Cuenta</cellbytelabel> 
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
