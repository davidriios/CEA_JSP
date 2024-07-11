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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
boolean viewMode = false;
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);


if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script>
document.title = 'Honorarios Por Médicos - '+document.title;
function doAction(){}

function showReporte(value){

  var fechaIni = document.form0.fechaini.value;
  var fechaFin = document.form0.fechafin.value;
  var medico = document.form0.medico.value || 'ALL';
  var empresa = document.form0.empresa.value || 'ALL';
  var tipoAdm = document.form0.tipo_adm.value || 'ALL';
  var facturado = document.form0.facturado.value || 'ALL';
  var pCtrlHeader = $("#ctrlHeader").is(":checked");
  var tipo_fecha = document.form0.tipo_fecha.value ;
  var pSociedad = "T";
  //if($("#soloSociedad").is(":checked"))pSociedad="S";
  
  if (!fechaFin || !fechaIni) CBMSG.error('Por favor indique un rango de fecha!'+fechaFin+" "+fechaIni);
  else {
    switch (value){
      
      case "1":  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_honorarios_por_medico_res.rptdesign&medico='+medico+'&empresa='+empresa+'&tipo_adm='+tipoAdm+'&pCtrlHeader='+pCtrlHeader+'&fDesde='+fechaIni+'&fHasta='+fechaFin+'&facturado='+facturado+'&pTipoFecha='+tipo_fecha+'&pEsSociedad='+pSociedad); break;
      case "2":  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_honorarios_por_medico_det.rptdesign&medico='+medico+'&empresa='+empresa+'&tipo_adm='+tipoAdm+'&pCtrlHeader='+pCtrlHeader+'&fDesde='+fechaIni+'&fHasta='+fechaFin+'&facturado='+facturado+'&pTipoFecha='+tipo_fecha+'&pEsSociedad='+pSociedad); break;
	   case "3":  abrir_ventana('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_honorarios_medicos_detallado.rptdesign&medico='+medico+'&empresa='+empresa+'&tipo_adm='+tipoAdm+'&pCtrlHeader='+pCtrlHeader+'&fDesde='+fechaIni+'&fHasta='+fechaFin+'&facturado='+facturado+'&pTipoFecha='+tipo_fecha+'&pEsSociedad='+pSociedad); break;
	  
     
    }
  }			
	
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="POR MEDICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
	<td>
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>

<tr>
 <td>
   <table align="center" width="70%" cellpadding="0" cellspacing="1">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">

			<table align="center" width="100%" cellpadding="0" cellspacing="1">

				<tr class="TextFilter">
					<td align="right">M&eacute;dico</td>
					<td>
                    <%=fb.select(ConMgr.getConnection()," select c.codigo, c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre)||decode(c.primer_apellido,null,'',' '||c.primer_apellido)||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) as nombre from tbl_adm_medico c order by 2","medico","",false,false,0,null,null,"","","S")%>
                    </td>
				</tr>
                <tr class="TextFilter">
					<td align="right">Sociedad M&eacute;dica</td>
					<td>
                    <%=fb.select(ConMgr.getConnection()," select to_char(codigo), nombre from tbl_adm_empresa where tipo_empresa = 1 order by 2","empresa","",false,false,0,null,null,"","","S")%>
                    </td>
				</tr>
				<!-- <tr class="TextFilter">
					<td align="right">Solo Sociedades</td>
					<td><%=fb.checkbox("soloSociedad","",false,false,"","","","")%></td>
				</tr>-->

				<tr class="TextFilter">
					<td align="right">Facturado</td>
					<td><%=fb.select("facturado","S=SI,N=NO","",false,false,false,0,"Text10","","","","T")%></td>
				</tr>

                <tr class="TextFilter">
					<td align="right">Tipo Admisi&oacute;n</td>
					<td><%=fb.select("tipo_adm","I=IP,O=OP","",false,false,false,0,"Text10","","","","T")%></td>
				</tr>				
	
				<tr class="TextFilter" >
				   <td align="right">Fecha</td>
				   <td><%=fb.select("tipo_fecha","FCR=FECHA DE CREACION,FCA=FECHA DE CARGO","",false,false,false,0,"Text10","","","","")%>
			 &nbsp;&nbsp;
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
			  <tr class="TextFilter">
			    <td align="right">Esconder Cabecera (Excel)</td>
				<td><%=fb.checkbox("ctrlHeader","",false,false,"","","","")%></td>
			  </tr>			  
			</table>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="3">REPORTES</td>
				</tr>

				<authtype type='50'>
				<tr class="TextRow01">
					<td colspan="3"><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Resumido
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="3">
					<%=fb.radio("reporte1","2",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Detallado
					</td>
				</tr>
				<tr class="TextRow01">
					<td colspan="3">
					<%=fb.radio("reporte1","3",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Detallado Por Paciente
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
