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
String aseguradora = "", area = "", categoria = "", tipoAdmision = "", tipoServicio = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mes = cDateTime.substring(3,5);
String anio = cDateTime.substring(6,10);
String fg = request.getParameter("fg");
if (mode == null) mode = "add";
if (fg == null) fg = "";
StringBuffer sbSql = new StringBuffer();

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
function doAction(){}
function showReporte(value,printRes)
{
  var cds         = document.form0.area.value;
  var ts           = document.form0.ts.value;
  var fechaini     = document.form0.fechaini.value;
  var fechafin     = document.form0.fechafin.value; 
  var categoria    = document.form0.categoria.value; 
  var cargosFact   = document.form0.cargosFact.value; 
  var tipo_fecha   = document.form0.tipo_fecha.value ;
  
	var pCtrlHeader = false;
	if(document.form0.pCtrlHeader.checked==true) pCtrlHeader = "true"; 
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/rpt_ingresos_cds_ts.rptdesign&pCategoria='+categoria+'&pCds='+cds+'&pTs='+ts+'&fDesde='+fechaini+'&fHasta='+fechafin+'&pCtrlHeader='+pCtrlHeader+'&facturado='+cargosFact+'&pTipoFecha='+tipo_fecha);

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

				<tr class="TextFilter">
				    <td width="8%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_centro_servicio where estado = 'A'  and compania_unorg = "+(String)session.getAttribute("_companyId")+" order by 2","area",area,"T")%>
					</td>
				</tr>
				<tr class="TextFilter">
				    <td width="8%"><cellbytelabel>Tipo de Servicio</cellbytelabel></td>
					<td width="92%">
					<%=fb.select(ConMgr.getConnection(),"select codigo,descripcion||' - '||codigo centroServicio from tbl_cds_tipo_servicio where compania = "+(String) session.getAttribute("_companyId")+"  order by 2","ts","","T")%>
					</td>
				</tr> 
			  <tr class="TextFilter" >
				   <td width="8">Categoría</td>
				   <td width="92%"> 
           <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","categoria",categoria,"T")%> 
           			</td>
			  </tr> 
				<tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Fecha Creacion</cellbytelabel></td>
				   <td width="50%"><%=fb.select("tipo_fecha","FCR=FECHA DE CREACION,FCA=FECHA DE CARGO","",false,false,false,0,"Text10","","","","")%>&nbsp;&nbsp;
						<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="2" />
							<jsp:param name="clearOption" value="true" />
							<jsp:param name="nameOfTBox1" value="fechaini" />
							<jsp:param name="valueOfTBox1" value="<%=(fg.trim().equals("CA"))?"":cDateTime%>" />
							<jsp:param name="nameOfTBox2" value="fechafin" />
							<jsp:param name="valueOfTBox2" value="<%=(fg.trim().equals("CA"))?"":cDateTime%>" />
						</jsp:include>
		           </td>
			  </tr>
			   
			  <tr class="TextFilter" >
				   <td width="50%"><cellbytelabel>Cargos:</cellbytelabel></td>
				   <td width="50%"><%=fb.select("cargosFact","S=FACTURADOS,N=NO FACTURADOS","",false,false,0,"Text10",null,null,null,"T")%>
		           </td>
			  </tr> 
			  <tr class="TextFilter" align="left">
                            <td>Esconder Cabecera?</td>
							<td><%=fb.checkbox("pCtrlHeader","false")%></td>
              </tr>
			</table>

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td colspan="2"><cellbytelabel>REPORTES</cellbytelabel></td>
				</tr>
				<tr class="TextRow01">
					<td colspan="2"> 
      	<authtype type='50'><%=fb.radio("reporte1","1",true,false,false,null,null,"onClick=\"javascript:showReporte(this.value)\"")%>Cargos a Pacientes</authtype>  </td>
				</tr>
		   </table>
		</td>
     </tr> 
				
				 
	</table>	 
        	</td>
        </tr>

<%=fb.formEnd(true)%>

	</td>
	</tr>
</table>
</body>
</html>
<%
}//GET
%>
