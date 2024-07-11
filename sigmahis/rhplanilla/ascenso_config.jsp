<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String appendFilter = "";
String id = "1";
String key = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");

String seccion = "";
String cod_pac = request.getParameter("cod_pac");
String secuencia = request.getParameter("secuencia");
//String fec_nacimiento = IBIZEscapeChars.forURL("22/02/2008");
String fec_nacimiento = request.getParameter("fec_nacimiento");
String pac_id = request.getParameter("pac_id");

if(seccion==null){ 
sql = "SELECT codigo, descripcion FROM tbl_sec_unidad_ejec where compania="+(String) session.getAttribute("_companyId")+" and nivel = 3 and codigo > 100 "+appendFilter+" ORDER BY descripcion";
CommonDataObject cdo = SQLMgr.getData(sql);
seccion=cdo.getColValue("codigo"); 
}

if (mode == null) mode = "add";
if (request.getParameter("id") != null) id = request.getParameter("id"); 
if (id == null) throw new Exception("Sin ID!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Recursos Humanos - "+document.title;

function doRedirect(seccion)
{
	document.getElementById("iDetalle").src = '../rhplanilla/accion_empleado.jsp?seccion='+seccion+'&mode=<%=mode%>&pac_id=<%=pac_id%>&secuencia=<%=secuencia%>&fec_nacimiento=<%=fec_nacimiento%>&cod_pac=<%=cod_pac%>';
}

function doAction()
{
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RECURSOS HUMANOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	      <table align="center" width="100%" cellpadding="0" cellspacing="0">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2">
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right">&nbsp;</td>
							<td width="35%">&nbsp;</td>
							<td width="15%" align="right">&nbsp;</td>
							<td width="35%">&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td width="25%" class="TableBorder">	
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader">
							<td>Departamentos</td>
						</tr>
						<tr>
							<td>
								<div id="secciones" style="overflow:scroll; position:static; height:400">
								<table width="100%" border="0" cellpadding="1" cellspacing="0">
<%
al = SQLMgr.getDataList("select codigo, descripcion from tbl_sec_unidad_ejec where compania="+(String) session.getAttribute("_companyId")+" and nivel = 3 and codigo > 100 "+appendFilter+" order by descripcion");
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo2 = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
								<tr class="<%=color%>" onClick="javascript:doRedirect('<%=cdo2.getColValue("codigo")%>')" style="cursor:pointer" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
								<td><%=cdo2.getColValue("descripcion")%></td>
								</tr>
<%
}
%>
								</table>
								</div>
						  </td>
						</tr>														
						</table>
					</td>
					<td width="75%" class="TableBorder TextRow01">
						<iframe id="iDetalle" name="iDetalle" width="100%" height="418" scrolling="no" frameborder="0" src="../expediente/expediente_redirect.jsp"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2" align="right"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
%>