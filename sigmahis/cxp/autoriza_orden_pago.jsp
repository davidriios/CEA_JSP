<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "", key = "";
String mode = request.getParameter("mode");

String anio = request.getParameter("anio");
if(anio == null) anio = CmnMgr.getCurrentDate("yyyy");
String cod_tipo_orden_pago = request.getParameter("cod_tipo_orden_pago");
String tipo_orden = request.getParameter("tipo_orden");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String agrupa_hon = request.getParameter("agrupa_hon");
if(agrupa_hon==null) agrupa_hon = "";
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;

if(agrupa_hon.equals("")){
		CommonDataObject cd = new CommonDataObject();
		cd = SQLMgr.getData("select get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'LIQ_RECL_AGRUPAR_HON') agrupa_hon from dual");
		agrupa_hon = cd.getColValue("agrupa_hon");
	}
if(fg==null) fg = "";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;

function doAction(){
	var cod_tipo_orden_pago = document.orden_pago.cod_tipo_orden_pago.value;
	<%if(!fg.equals("PM")){%>
	if(cod_tipo_orden_pago!=3) document.orden_pago.tipo_orden.value = 'O';
	<%}%>
}

function doSubmit(value){
	document.orden_pago.action.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function reloadPage(){
	var anio = document.orden_pago.anio.value;
	var cod_tipo_orden_pago = document.orden_pago.cod_tipo_orden_pago.value;
	<%if(!fg.equals("PM")){%>
	if(cod_tipo_orden_pago!=3) document.orden_pago.tipo_orden.value = 'O';
	<%}%>
	var tipo_orden = document.orden_pago.tipo_orden.value;
	if(anio!='' && cod_tipo_orden_pago !='' && tipo_orden != ''){
		window.frames['itemFrame'].location = '../cxp/autoriza_orden_pago_det.jsp?anio='+anio+'&cod_tipo_orden_pago='+cod_tipo_orden_pago+'&tipo_orden='+tipo_orden+'&agrupa_hon=<%=agrupa_hon%>';
	}
}

function aplicaEstado(){
	var estado = document.orden_pago.estado.value;
	window.frames['itemFrame'].aplicaEstado(estado);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("orden_pago","","post");
						%>
              <%=fb.formStart(true)%> 
							<%=fb.hidden("mode",mode)%> 
							<%=fb.hidden("errCode","")%> 
							<%=fb.hidden("errMsg","")%> 
              <%=fb.hidden("saveOption","")%> 
							<%=fb.hidden("clearHT","")%> 
							<%=fb.hidden("action","")%> 
              <%=fb.hidden("fg",fg)%> 
              <tr class="TextPanel">
                <td colspan="7"><cellbytelabel>Autorizaci&oacute;n de Orden de Pago</cellbytelabel></td>
              </tr>
              <tr class="TextPanel">
              	<td colspan="5">
                <cellbytelabel>A&ntilde;o</cellbytelabel>:
                <%=fb.intBox("anio",anio,false,false,false,6,"text10","","")%>
                <cellbytelabel>Tipo de Orden</cellbytelabel>:
                <%if(fg.equals("PM")){%>
								<%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in (4) order by cod_tipo_orden_pago","cod_tipo_orden_pago","",false,false,0, "text10", "", "onChange=\"javascript:reloadPage();\"", "", "S")%>
               <cellbytelabel>Pagos Otros</cellbytelabel>:
                <%=fb.select("tipo_orden","E=Empresa,B=Beneficiario,C=Corredor,"+(agrupa_hon.equals("Y")?"H=Honorarios":"M=Medico,S=Sociedad Medica"), "", false, false,0,"text10",null,"onChange=\"javascript:reloadPage();\"")%>
								<%} else {%>
								<%=fb.select(ConMgr.getConnection(),"select cod_tipo_orden_pago, descripcion from tbl_cxp_tipo_orden_pago where cod_tipo_orden_pago in (1, 2, 3) order by cod_tipo_orden_pago","cod_tipo_orden_pago","",false,false,0, "text10", "", "onChange=\"javascript:reloadPage();\"", "", "S")%>
               <cellbytelabel>Pagos Otros</cellbytelabel>:
                <%=fb.select("tipo_orden","E=Empresa,P=Paciente,L=Liquidacion,D=Dividendo,O=Otros,C=Contratos,M=Medico,U=Empleados,N=Ninguno", "", false, false,0,"text10",null,"onChange=\"javascript:reloadPage();\"")%>
								<%}%>
                </td>
								<td colspan="2"><%=fb.select("estado","R=Rechazado,P=Pendiente,A=Aprobado", "", false, false,0,"text10",null,"onChange=\"javascript:aplicaEstado();\"")%></td>
              </tr>
              <tr>
                <td colspan="7"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cxp/autoriza_orden_pago_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="6" align="right"> 
          <cellbytelabel>Opciones de Guardar</cellbytelabel>: 
					<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%> 
          </td>
        </tr>
        <%
        fb.appendJsValidation("\n\tif (!chkMotivoRechazo()) error++;\n");
        fb.appendJsValidation("\n\tif (!chkMonto()) error++;\n");
				%>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.location = '<%=request.getContextPath()%>/cxp/autoriza_orden_pago.jsp?anio=<%=request.getParameter("anio")%>&cod_tipo_orden_pago=<%=request.getParameter("cod_tipo_orden_pago")%>&tipo_orden=<%=request.getParameter("tipo_orden")%>&fg=<%=request.getParameter("fg")%>';
<%
if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view';
	///reg_sol_mat_pacientes.jsp?mode=view&id=1&anio=2009&tr=PAC_S
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>