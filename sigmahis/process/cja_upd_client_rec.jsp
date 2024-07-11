<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alRefType = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
StringBuffer sbSql = new StringBuffer();
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");
String tipoCliente = request.getParameter("tipoCliente");
String recibo = request.getParameter("recibo");
String refType = request.getParameter("refType");
String subRefType = request.getParameter("subRefType");
String refId = request.getParameter("refId");
if (compania == null || compania.trim().equals("")) throw new Exception("Compañía no definida!");
if (anio == null || anio.trim().equals("")) throw new Exception("Año no definido!");
if ( (codigo == null || codigo.trim().equals("")) && (tipoCliente == null || tipoCliente.trim().equals("") || recibo == null || recibo.trim().equals("")) ) throw new Exception("El Código de Recibo, o el Número y Tipo de Recibo no está definido!");

if (request.getMethod().equalsIgnoreCase("GET")) {
	sbSql.append("select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn, refer_to as optTitleColumn from tbl_fac_tipo_cliente where compania = ");
	sbSql.append(compania);
	if (tipoCliente.equalsIgnoreCase("O")) sbSql.append(" and activo_inactivo = 'A'");
	sbSql.append(" and refer like '%");
	sbSql.append(tipoCliente);
	sbSql.append("%' order by descripcion");
	alRefType = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);

  CommonDataObject r = new CommonDataObject();
	sbSql = new StringBuffer();
	sbSql.append("select nombre, sub_ref_id||' - '||(select descripcion from tbl_cxc_tipo_otro_cliente where id = z.sub_ref_id and compania = z.compania) as sub_ref_type from tbl_cja_transaccion_pago z where compania = ");
	sbSql.append(compania);
	sbSql.append(" and anio = ");
	sbSql.append(anio);
	sbSql.append(" and codigo = ");
	sbSql.append(codigo);
  r = SQLMgr.getData(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'CAJA - '+document.title;
function doAction(){setReferTo(document.form0.refType,false);}
function setReferTo(obj,onChangeClear){var referTo=getSelectedOptionTitle(obj,'');document.form0.referTo.value=referTo;if(referTo!='CXCO'){document.form0.subRefType.value='';document.form0.subRefTypeDesc.value='';}if(onChangeClear==undefined||onChangeClear==null||onChangeClear==true){document.form0.refId.value='';document.form0.nombre.value='';}}
function searchClient(){if(document.form0.referTo.value.trim()!=''){abrir_ventana('../common/search_cliente.jsp?fp=caja&referTo='+document.form0.referTo.value);}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CAMBIAR CLIENTE"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="5" cellspacing="1" id="_tblMain">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipoCliente",tipoCliente)%>
<%=fb.hidden("recibo",recibo)%>
<%=fb.hidden("referTo","")%>
<%=fb.hidden("subRefType",subRefType)%>
		<tr class="TextPanel" align="center">
			<td colspan="2"><cellbytelabel>Cambio de Cliente</cellbytelabel></td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="2">
				Nuevo Tipo de Referencia:
				<%=fb.select("refType",alRefType,refType,true,false,false,0,"Text10",null,"onChange=\"javascript:setReferTo(this);\"",null,"S")%>
				<%=fb.textBox("subRefTypeDesc",r.getColValue("sub_ref_type"),false,false,true,40,"Text10",null,null)%>
			</td>
		</tr>
		<tr class="TextHeader02">
			<td colspan="2">
				Nuevo Cliente:
				<%=fb.textBox("refId",refId,true,false,true,15,"Text10",null,null)%>
				<%=fb.textBox("nombre",r.getColValue("nombre"),false,false,true,50,"Text10",null,null)%>
				<%=fb.button("btnSearchClient","...",false,false,null,"","onClick=\"javascript:searchClient()\"")%>
			</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="2">
				<%=fb.submit("save","Guardar",true,false,null,"","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",false,false,null,"","onClick=\"javascript:parent.hidePopWin(false)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
} else {

	CommonDataObject param = new CommonDataObject();//parametros para el procedimiento
	String rParam = null;//parámetro que devuelve el procedimiento almacenado
	sbSql = new StringBuffer();
	sbSql.append("call sp_cja_upd_client_rec(?,?,?,?,?,?,?,?)");
	param.setSql(sbSql.toString());
	param.addInStringStmtParam(1,compania);
	param.addInStringStmtParam(2,anio);
	param.addInNumberStmtParam(3,codigo);
	param.addInStringStmtParam(4,tipoCliente);
	param.addInNumberStmtParam(5,recibo);
	param.addInNumberStmtParam(6,refType);
	param.addInNumberStmtParam(7,subRefType);
	param.addInNumberStmtParam(8,refId);

	ConMgr.setClientIdentifier(((String) session.getAttribute("_userName")).trim()+":"+request.getRemoteAddr(),true);
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"compania="+compania+"&anio="+anio+"&codigo="+codigo+"&recibo="+recibo+"&tipoCliente="+tipoCliente+"&refType="+refType+"&subRefType="+subRefType+"&refId="+refId);
	param = SQLMgr.executeCallable(param);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
alert('<%=SQLMgr.getErrMsg()%>');
<% } else throw new Exception(SQLMgr.getErrException()); %>
parent.window.location.reload(true);
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>