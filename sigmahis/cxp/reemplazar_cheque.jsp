<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
FORMA CK_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String tipoPago = request.getParameter("tipo_pago");
boolean viewMode = false;
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

if(fg==null) fg = "";
if(fp==null) fp = "";
if (tipoPago == null) tipoPago = "";

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
function doAction(){}
function doSubmit(){return true;}
function chkNumCK(object){
	var numChk=object.value.toUpperCase();
	<% if (tipoPago.equals("2")) { %>
	if (!numChk.startsWith('A'))numChk='A'+numChk;
	<% }  else if (tipoPago.equals("3")) { %>
	if (!numChk.startsWith('T'))numChk='T'+numChk;
	<% } %>
	object.value=numChk;
	if(hasDBData('<%=request.getContextPath()%>', 'tbl_con_cheque','cod_compania = <%=(String) session.getAttribute("_companyId")%> and cod_banco = \'<%=cod_banco%>\' and cuenta_banco = \'<%=cuenta_banco%>\' and num_cheque = \''+numChk+'\'')){
		top.CBMSG.warning('Este cheque ya existe!');
		object.value = '';
	}else if(!validarSec(object.value)){
		object.value = '';
	}
}
function chkDate(){
	/**/
	var object = document.reemplazar.fecha_new_emision;
	var z = splitCols(getDBData('<%=request.getContextPath()%>', 'get_sec_comp_param(-1, \'CHECK_FECHA_EMISION_CK\'), (case when to_date(\''+object.value+'\', \'dd/mm/yyyy\') >= trunc(sysdate) then 1 else 0 end)','dual',''));
	if(z[0]=='S' && z[1]!='1'){
		top.CBMSG.warning('La fecha de emisión no puede anteceder la fecha actual!');
		object.value = '';
	}
}
function validarSec(numero){
	var secTrx = numero.substring(1);
	if (!/^([0-9])*$/.test(secTrx)){top.CBMSG.warning("La secuencia del Cheque/Ach [" + secTrx + "] no es valida");return false;}
	return true;
}

function reemplaza(accion){
	if(accion=='N') {
		parent.document.cheque.estado_cheque.value='G';
		parent.hidePopWin(false);
		parent.doSubmit('Anular');
	}else{
		if(document.reemplazar.num_ck_reemplazo.value!='' && document.reemplazar.fecha_new_emision.value != ''){
			parent.document.cheque.num_new_ck.value=$.trim(document.reemplazar.num_ck_reemplazo.value);
			parent.document.cheque.fecha_new_emision.value=document.reemplazar.fecha_new_emision.value;
			parent.hidePopWin(false);
			parent.doSubmit('Anular');
		} else top.CBMSG.warning('Introduzca Numero de Cheque/Fecha Reemplazo!');
	}
}
function checkEstado(){var fecha = '';
fecha = document.reemplazar.fecha_new_emision.value;
var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.reemplazar.fecha_new_emision.value='';return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REEMPLAZAR CHEQUES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<tr>
					<td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("reemplazar",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("num_ck_prefix",tipoPago.trim())%>
							<tr class="TextRow01">
								<td align="center">&nbsp;</td>
							</tr>
							<tr class="TextHeader02">
								<td align="center"><cellbytelabel>Desea Reemplazar el cheque</cellbytelabel><% if (tipoPago.equals("2")) { %> (ACH)<% } else if (tipoPago.equals("3")) { %>Transferencia<% } %>?</td>
							</tr>
							<tr class="TextRow01">
								<td align="center"><font class="RedTextBold">
								<cellbytelabel>Num. Cheque</cellbytelabel><% if (tipoPago.equals("2")) { %> (ACH)<% } else if (tipoPago.equals("3")) { %>Transferencia<% } %>:</font>
								<%=fb.textBox("num_ck_reemplazo","",false,false,false,10,"text10",null,"onChange=\"javascript:chkNumCK(this);\"")%>
								<%String checkEstado = "javascript:checkEstado();chkDate();newHeight();";%>
								<cellbytelabel>Fecha de Emisi&oacute;n</cellbytelabel>:
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_new_emision" />
								<jsp:param name="valueOfTBox1" value="<%=fecha%>" />
								<jsp:param name="jsEvent" value="<%=checkEstado%>" />
								<jsp:param name="onChange" value="chkDate();" />
								</jsp:include>
								</td>
							</tr>
							<% if (tipoPago.equals("2")) { %>
							<tr class="TextRow01 RedTextBold">
								<td align="center">Recuerde que la numeraci&oacute;n del Pago por ACH tiene como prefijo "A".</td>
							</tr>
							<% } else if (tipoPago.equals("3")) { %>
							<tr class="TextRow01 RedTextBold">
								<td align="center">Recuerde que la numeraci&oacute;n del Pago por Transferencia tiene como prefijo "T".</td>
							</tr>
							<% } %>
							<tr class="TextHeader02">
								<td align="center">
								<%=fb.button("reemp","Reemplazar",false, viewMode,"","","onClick=\"javascript:reemplaza('S')\"")%>
								<%=fb.button("no_reemp","No Reemplazar",false, viewMode,"","","onClick=\"javascript:reemplaza('N');\"")%>
								</td>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="6">&nbsp;</td>
				</tr>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>