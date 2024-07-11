<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
=========================================================================
=========================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String code = request.getParameter("code");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET")) {
	if (mode.equalsIgnoreCase("add")) {
		code = "";
	} else {
		if (code == null) throw new Exception("El Banco no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.cod_banco as codigo, a.nombre, a.ruta_transito as rutatrans, a.compania as compid, a.direccion, a.telefono_1 as telefono1, a.telefono_2 as telefono2, a.e_mail as email, a.fax, a.apartado, a.zona, a.contacto, a.usuario_creacion as usercrea, a.usuario_modificacion as usermod, a.fecha_creacion as fechacrea, a.fecha_modificacion as fechamod from tbl_con_banco a where compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		sbSql.append(" and a.cod_banco = '");
		sbSql.append(code);
		sbSql.append("'");
		cdo = SQLMgr.getData(sbSql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Banco - "+document.title;
function getRuta(){abrir_ventana1('../convenio/empresa_rutatransito_list.jsp?id=2');}
function checkCode(obj){return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_con_banco','compania = <%=session.getAttribute("_companyId")%> and cod_banco = \''+obj.value+'\'','<%=code%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>
<%fb.appendJsValidation("if(checkCode(document.form1.codigo))error++;");%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="13%">C&oacute;digo</td>
			<td width="39%"><%=fb.textBox("codigo",code,true,false,(mode.equals("edit")),45,3,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>
			<td width="10%">Nombre</td>
			<td width="38%"><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,true,55,50)%></td>
		</tr>
		<tr class="TextRow02">
			<td>Ruta Tr&aacute;nsito</td>
			<td><%=fb.textBox("rutaTrans",cdo.getColValue("rutaTrans"),true,false,true,45)%><%=fb.button("btnruta","...",true,false,null,null,"onClick=\"javascript:getRuta()\"")%></td>
			<td>Contacto</td>
			<td><%=fb.textBox("contacto",cdo.getColValue("contacto"),false,false,false,50,50)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Tel&eacute;fono 1</td>
			<td><%=fb.textBox("telefono1",cdo.getColValue("telefono1"),true,false,false,15,11)%></td>
			<td>Telefono 2</td>
			<td><%=fb.textBox("telefono2",cdo.getColValue("telefono2"),false,false,false,15,11)%></td>
		</tr>
		<tr class="TextRow02">
			<td>E-Mail</td>
			<td><%=fb.emailBox("email",cdo.getColValue("email"),false,false,false,45,100)%></td>
			<td>Fax</td>
			<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,false,false,45,11)%></td>
		</tr>
		<tr class="TextRow01">
			<td>Apartado Postal</td>
			<td><%=fb.textBox("apartado",cdo.getColValue("apartado"),false,false,false,30,20)%></td>
			<td>Zona Postal</td>
			<td><%=fb.textBox("zona",cdo.getColValue("zona"),false,false,false,30,20)%></td>
		</tr>
		<tr class="TextRow02">
			<td>Direcci&oacute;n</td>
			<td colspan="3"><%=fb.textBox("direccion",cdo.getColValue("direccion"),true,false,false,60,60)%></td>
		</tr>
		<tr>
			<td colspan="4">
				<jsp:include page="../common/bitacora.jsp" flush="true">
				<jsp:param name="audTable" value="tbl_con_banco"></jsp:param>
				<jsp:param name="audFilter" value="<%="compania = "+session.getAttribute("_companyId")+" and cod_banco = '"+code+"'"%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				Opciones de Guardar:
				<%=fb.radio("saveOption","N")%>Crear Otro
				<%=fb.radio("saveOption","O")%>Mantener Abierto
				<%=fb.radio("saveOption","C",true,false,false)%>Cerrar
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	code = request.getParameter("codigo");
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_con_banco");
	cdo.addColValue("nombre",request.getParameter("nombre"));
	cdo.addColValue("ruta_transito",request.getParameter("rutaTrans"));
	cdo.addColValue("direccion",request.getParameter("direccion"));
	cdo.addColValue("telefono_1",request.getParameter("telefono1"));
	cdo.addColValue("telefono_2",request.getParameter("telefono2"));
	cdo.addColValue("e_mail",request.getParameter("email"));
	cdo.addColValue("fax",request.getParameter("fax"));
	cdo.addColValue("apartado",request.getParameter("apartado"));
	cdo.addColValue("zona",request.getParameter("zona"));
	cdo.addColValue("contacto",request.getParameter("contacto"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion","sysdate");

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&code="+code);
	if (mode.equalsIgnoreCase("add")) {
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");
		cdo.addColValue("cod_banco",request.getParameter("codigo"));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		SQLMgr.insert(cdo);
	} else {
		cdo.setWhereClause("cod_banco='"+request.getParameter("codigo")+"'");
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/banco_list.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/banco_list.jsp")%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/bancos/banco_list.jsp';
<% } %>
<% if (saveOption.equalsIgnoreCase("N")) { %>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<% } %>
<% } else throw new Exception(SQLMgr.getErrMsg()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<% } %>