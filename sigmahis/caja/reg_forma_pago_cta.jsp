<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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

CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String id = request.getParameter("id");

String mode = request.getParameter("mode");
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	 
		if (id == null) throw new Exception("El Código de forma de pago no es válido. Por favor intente nuevamente!");

		sbSql.append("SELECT a.CODIGO,a.descripcion, nvl(b.USUARIO_CREACION,'') as CPOR , nvl(b.USUARIO_MODIFICACION,'') as MPOR, nvl(to_char(b.FECHA_CREACION,'dd/mm/yyyy hh12:mi:ss am'),'') as FC, nvl(to_char(b.FECHA_MODIFICACION,'dd/mm/yyyy hh12:mi:ss am'),'') as FM,cta1,cta2,cta3,cta4,cta5,cta6,(select descripcion from tbl_con_catalogo_gral where cta1=b.cta1 and cta2=b.cta2 and cta3=b.cta3 and cta4=b.cta4 and cta5=b.cta5 and cta6=b.cta6 and compania=b.compania ) descCuenta,b.estado,case when b.codigo is null then 'add' else 'edit' end as action  FROM tbl_cja_forma_pago a, tbl_cja_forma_pago_cta b  WHERE a.codigo=b.codigo(+) and b.compania(+)=");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.codigo=");
		sbSql.append(id);
		cdo = SQLMgr.getData(sbSql.toString());
		
		mode =cdo.getColValue("action"); 
	 
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Mantenimiento de Caja - "+document.title;
function selCuenta(){abrir_ventana1('../common/search_catalogo_gral.jsp?fp=formaPago');}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - MANTENIMIENTO - FORMA DE PAGO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%//fb.appendJsValidation("if(checkIP(document.form1.ip))error++;");%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="40%"><%=fb.textBox("codigo",cdo.getColValue("CODIGO"),false,false,true,2,null,null,null)%></td>
			<td width="10%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="40%"><%=fb.textBox("descripcion",cdo.getColValue("DESCRIPCION"),true,false,true,50)%></td>
		</tr>
		<tr class="TextRow01" >
			<td><cellbytelabel>F. Creación</cellbytelabel></td>
			<td><%=fb.textBox("creado_por",cdo.getColValue("FC"),false,false,true,50)%></td>
			<td><cellbytelabel>F. Modificación</cellbytelabel></td>
			<td><%=fb.textBox("modif_por",cdo.getColValue("FM"),false,false,true,50)%></td>
		</tr>
		 <tr class="TextRow01" >
			<td><cellbytelabel>Creado por</cellbytelabel>:</td>
			<td><%=fb.textBox("f_creacion",cdo.getColValue("CPOR"),false,false,true,50)%></td>
			<td><cellbytelabel>Modificado por</cellbytelabel>:</td>
			<td><%=fb.textBox("f_modif",cdo.getColValue("MPOR"),false,false,true,50)%></td>
		</tr>
		<tr class="TextRow01" >
			<td><cellbytelabel>Estado:</cellbytelabel>:</td>
			<td><%=fb.select("estado","A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,false,0,"Text10",null,null,null,"")%></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr class="TextRow01">
					<td><cellbytelabel>Cuenta Contable(L. Caja)</cellbytelabel></td>
					<td colspan="3"><%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,3)%>
								<%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,3)%>
								<%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,3)%>
								<%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,3)%>
								<%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,3)%>
								<%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,3)%>&nbsp;
								<%=fb.textBox("descCuenta",cdo.getColValue("descCuenta"),false,false,true,51)%>&nbsp;
								<%=fb.button("btnCta","...",true,false,null,null,"onClick=\"javascript:selCuenta();\"")%> 
								</td>

		</tr>
	 <tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_cja_forma_pago_cta"); 
	cdo.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));
    cdo.addColValue("FECHA_MODIFICACION","sysdate"); 
	
	cdo.addColValue("cta1", request.getParameter("cta1"));
	cdo.addColValue("cta2", request.getParameter("cta2"));
	cdo.addColValue("cta3", request.getParameter("cta3"));
	cdo.addColValue("cta4", request.getParameter("cta4"));
	cdo.addColValue("cta5", request.getParameter("cta5"));
	cdo.addColValue("cta6", request.getParameter("cta6"));
	cdo.addColValue("estado", request.getParameter("estado"));
	cdo.addColValue("compania",(String)session.getAttribute("_companyId"));
	
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.addColValue("CODIGO",id);
		cdo.addColValue("USUARIO_CREACION",(String) session.getAttribute("_userName"));
		cdo.addColValue("FECHA_CREACION","sysdate"); 
		SQLMgr.insert(cdo); 
	}
	else
	{
		cdo.setWhereClause("CODIGO="+id+" and compania="+(String) session.getAttribute("_companyId"));
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/caja/forma_pago_list_cta.jsp")) { %>
	window.opener.location='<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/caja/forma_pago_list_cta.jsp")%>';
<% } else { %>
	window.opener.location='<%=request.getContextPath()%>/caja/forma_pago_list_cta.jsp';
<% } if (saveOption.equalsIgnoreCase("N")) { %>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<% } } else throw new Exception(SQLMgr.getErrMsg()); %>
}
function addMode(){
	window.location='<%=request.getContextPath()+request.getServletPath()%>';
	}
function editMode(){
	window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
	}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>