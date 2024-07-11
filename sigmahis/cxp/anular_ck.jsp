<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
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
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");

String anio = request.getParameter("anio");
if(anio == null) anio = CmnMgr.getCurrentDate("yyyy");
String cod_tipo_cheque = request.getParameter("cod_tipo_cheque");
String tipo_orden = request.getParameter("tipo_orden");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;

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
}

function doSubmit(value){
	document.cheque.action.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function reloadPage(){
	var anio = document.cheque.anio.value;
	var cod_banco = document.cheque.cod_banco.value;
	var cuenta_banco = document.cheque.cuenta_banco.value;
	window.frames['itemFrame'].location = '../cxp/anular_cheque_det.jsp?anio='+anio+'&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco;
}

function selCuentaBancaria(i){
	var cod_banco = eval('document.cheque.cod_banco'+i).value;
	if(cod_banco=='') alert('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=cheque&cod_banco='+cod_banco+'&index='+i);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="ANULACION DE CHEQUES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("cheque","","post");
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
                <td colspan="7">Anular Cheques</td>
              </tr>
              <tr class="TextPanel">
              	<td colspan="7">
                <cellbytelabel>A&ntilde;o</cellbytelabel>:
                <%=fb.intBox("anio",anio,false,false,false,6,"text10","","")%>
                <cellbytelabel>Banco</cellbytelabel>:
								<%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" order by nombre","cod_banco","",false,false,0, "text10", "", "", "", "T")%>
                <cellbytelabel>Cta</cellbytelabel>.:
                <%=fb.textBox("cuenta_banco","",false,false,true,20,"text10",null,"")%> 
								<%=fb.textBox("nombre_cuenta","",false,false,true,40,"text10",null,"")%> 
                <%=fb.button("buscarCuenta","...",false, viewMode,"text10","","onClick=\"javascript:selCuentaBancaria('')\"")%>
                </td>
              </tr>
              <tr>
                <td colspan="7"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cxp/anular_ck_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <tr class="TextRow02">
          <td colspan="6" align="right"> 
          <cellbytelabel>Opciones de Guardar</cellbytelabel>: 
					<%=fb.button("save","Anular Cheques",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%> 
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
	window.location = '<%=request.getContextPath()%>/cxp/anular_cheque.jsp?anio=<%=request.getParameter("anio")%>&cod_tipo_cheque=<%=request.getParameter("cod_tipo_cheque")%>&tipo_orden=<%=request.getParameter("tipo_orden")%>';
<%
} else throw new Exception(errMsg);
%>
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>