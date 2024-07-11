<%@ page errorPage="../error.jsp"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<%
/**
================================================================================
================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTurno = new ArrayList();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (codigo == null) codigo = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (viewMode) alTurno = sbb.getBeanList(ConMgr.getConnection(),"select a.cod_turno as optValueColumn, a.cod_turno||' - '||b.descripcion as optLabelColumn, a.cod_caja as optTitleColumn from tbl_cja_turnos_x_cajas a, tbl_cja_cajas b where a.compania = b.compania and a.cod_caja = b.codigo and a.compania = "+session.getAttribute("_companyId")+" order by b.descripcion, a.cod_turno",CommonDataObject.class);
	else alTurno = sbb.getBeanList(ConMgr.getConnection(),"select a.cod_turno as optValueColumn, a.cod_turno||' - '||b.descripcion as optLabelColumn, a.cod_caja as optTitleColumn from tbl_cja_turnos_x_cajas a, tbl_cja_cajas b where a.compania = b.compania and a.cod_caja = b.codigo and a.compania = "+session.getAttribute("_companyId")+" and a.estatus = 'A'"+((UserDet.getUserProfile().contains("0"))?"":" and b.ip = '"+request.getRemoteAddr()+"'")+" and b.estado = 'A' order by b.descripcion, a.cod_turno",CommonDataObject.class);
	if (codigo.trim().equals("0"))
	{
		if (alTurno.size() == 0) throw new Exception("No existe TURNO válido para la(s) CAJA(s) registrada en el IP "+request.getRemoteAddr()+". Por favor consulte con su Administrador!");
		cdo.addColValue("codigo",codigo);
		cdo.addColValue("fecha",cDate);
	}
	else
	{
		sbSql = new StringBuffer();
		sbSql.append("select codigo, compania, turno, to_char(fecha,'dd/mm/yyyy') as fecha, nombre, ref_type, referencia, monto, nvl(descripcion,' ') as descripcion, status from tbl_cja_cambio where codigo = ");
		sbSql.append(codigo);
		cdo = SQLMgr.getData(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Registro de Cambio - "+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javacript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - CAMBIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document.form0.turno.value==''){error++;alert('Por favor seleccione el Turno');}if(document.form0.ref_type.value==''){error++;alert('Por favor seleccione el Tipo de Documento');}");%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("fecha",cdo.getColValue("fecha"))%>
		<tr class="TextRow02">
			<td colspan="8" align="right">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="8%">C&oacute;digo</td>
			<td width="17%"><%=cdo.getColValue("codigo")%></td>
			<td width="8%">Turno</td>
			<td colspan="3" width="42%"><%=fb.select("turno",alTurno,cdo.getColValue("turno"),false,viewMode,0,"Text10",null,"",null,"S")%></td>
			<td width="8%">Fecha</td>
			<td width="17%"><%=cdo.getColValue("fecha")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Nombre</td>
			<td colspan="3" width="42%"><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,false,viewMode,50,100,"Text10",null,null)%></td>
			<td>Tipo Doc.</td>
			<td><%=fb.select("ref_type","CH=CHEQUE",cdo.getColValue("ref_type"),false,viewMode,0,"Text10",null,"",null,"S")%></td>
			<td>Doc. #</td>
			<td><%=fb.textBox("referencia",cdo.getColValue("referencia"),true,false,viewMode,20,"Text10",null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td rowspan="2">Descripci&oacute;n</td>
			<td rowspan="2" colspan="5"><%=fb.textarea("descripcion",cdo.getColValue("descripcion"),false,false,viewMode,70,5,"","","")%></td>
			<td>Monto</td>
			<td><%=fb.decPlusBox("monto",cdo.getColValue("monto"),true,false,viewMode,15,10.2,"Text10","","")%></td>
		</tr>
		<tr class="TextRow01">
			<td>Estado</td>
			<td><%=fb.select("status","A=ACTIVO,I=ANULADO",cdo.getColValue("status"),false,true,0,"Text10",null,"")%></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				Opciones de Guardar:
				<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro
				<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
				<%=fb.radio("saveOption","C",false,viewMode,false)%>Cerrar
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"","Guardar")%>
				<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");

	cdo = new CommonDataObject();
	cdo.setTableName("tbl_cja_cambio");
	cdo.setAutoIncCol("codigo");
	cdo.addPkColValue("codigo","");

	cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	cdo.addColValue("turno",request.getParameter("turno"));
	cdo.addColValue("fecha",request.getParameter("fecha"));
	cdo.addColValue("nombre",request.getParameter("nombre"));
	cdo.addColValue("ref_type",request.getParameter("ref_type"));
	cdo.addColValue("referencia",request.getParameter("referencia"));
	cdo.addColValue("monto",request.getParameter("monto"));
	cdo.addColValue("descripcion",request.getParameter("descripcion"));

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("status","A");
		SQLMgr.insert(cdo);
		codigo = SQLMgr.getPkColValue("codigo");
	}
	/*
	else if (mode.equalsIgnoreCase("edit"))
	{
		cdo.setWhereClause("codigo = "+codigo);
		SQLMgr.update(cdo);
	}
	*/
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){<% if (SQLMgr.getErrCode().equals("1")) { %>alert('<%=SQLMgr.getErrMsg()%>');<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/list_cambio.jsp")) { %>window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/list_cambio.jsp")%>';<% } else { %>window.opener.location='<%=request.getContextPath()%>/caja/list_cambio.jsp';<% } %><% if (saveOption.equalsIgnoreCase("N")) { %>setTimeout('addMode()',500);<% } else if (saveOption.equalsIgnoreCase("O")) { %>setTimeout('editMode()',500);<% } else if (saveOption.equalsIgnoreCase("C")) { %>window.close();<% } %><% } else throw new Exception(SQLMgr.getErrException()); %>}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=add';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&codigo=<%=codigo%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>