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
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
int lvl = 0;
String paisCode = request.getParameter("paisCode");
String provCode = request.getParameter("provCode");
String distCode = request.getParameter("distCode");

String pais = request.getParameter("pais");
String provNomb = request.getParameter("provNomb");
String distNomb = request.getParameter("distNomb");
String corrNomb = request.getParameter("corrNomb");
String corrName = request.getParameter("corrName");

String corrCode ="";// request.getParameter("corrCode");

System.out.println("Printing comunidad code%%%%%%%%%%%%%%%%%%%%%%%%"+request.getParameter("corrCode"));

if (request.getParameter("corrCode").equals("undefined") || request.getParameter("corrCode").equals("")) corrCode="0";
else corrCode =request.getParameter("corrCode");

System.out.println("Printing comunidad code%%%%%%%%%%%%%%%%%%%%%%%%"+corrCode);

String comuCode = request.getParameter("comuCode");
String lvlCode = "";
String lvlName = "";
String[] lvlType = {"Pais","Provincia","Distrito","Corregimiento","Comunidad"};

if (request.getParameter("lvl") != null) lvl = Integer.parseInt(request.getParameter("lvl"));

if (lvl == 0) {lvlCode = paisCode; lvlName = request.getParameter("lvlName"); }
else if (lvl == 1) { lvlCode = provCode; lvlName = request.getParameter("lvlName"); }
else if (lvl == 2) { lvlCode = distCode; lvlName = request.getParameter("lvlName"); }
else if (lvl == 3) { lvlCode = corrCode; lvlName = request.getParameter("lvlName"); }
else if (lvl == 4) { lvlCode = comuCode; lvlName = request.getParameter("lvlName"); }

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	}
	else
	{
	  if (lvlCode == null) throw new Exception("El Código no es válido. Por favor intente nuevamente!");
      /*
	  sql = "SELECT CODIGO_PAIS, NOMBRE_PAIS, CODIGO_PROVINCIA, NOMBRE_PROVINCIA, CODIGO_DISTRITO, NOMBRE_DISTRITO, CODIGO_CORREGIMIENTO, NOMBRE_CORREGIMIENTO, CODIGO_COMUNIDAD, NOMBRE_COMUNIDAD, nivel, nivel_codigo, nivel_nombre FROM vw_sec_regional_location";
	  cdo = SQLMgr.getData(sql);
	  */  
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Administración - '+document.title;

var formInUse = false;

function setFocus()
{
 if(!formInUse) {
  document.form1.name.focus();
 }
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onload="setFocus()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CREAR <%=lvlType[lvl].toUpperCase()%>"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%=fb.formStart(true)%>
<%=fb.hidden("lvl",""+lvl)%>
<%=fb.hidden("paisCode",paisCode)%>
<%=fb.hidden("provCode",provCode)%>
<%=fb.hidden("distCode",distCode)%>
<%=fb.hidden("corrCode",corrCode)%>
<%=fb.hidden("comuCode",comuCode)%>
<%=fb.hidden("code",lvlCode)%>
<%=fb.hidden("mode",mode)%>

<tr>

<td colspan="2"  bgcolor="#CCCCCC">&nbsp;<cellbytelabel>PAIS</cellbytelabel>= <%=request.getParameter("pais")%>---------->  &nbsp;<cellbytelabel>PROVENCIA</cellbytelabel>= <%=request.getParameter("provNomb")%>&nbsp;---------->    <cellbytelabel>DISTRICTO</cellbytelabel>= <%=request.getParameter("distNomb")%>---------->  <cellbytelabel>CORREGIMIENTO</cellbytelabel>= <%=request.getParameter("corrNomb")%>&nbsp;---------->  <cellbytelabel>COMUNIDAD</cellbytelabel>= <%=request.getParameter("comuName")%></td>
				</tr>
				<tr class="TextRow02">
					<td colspan="2">&nbsp;</td>
				</tr>	
				<tr class="TextRow01" >
					<td><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td><%=lvlCode%></td>
				</tr>
				<tr class="TextRow02" >
					<td><cellbytelabel>Nombre</cellbytelabel></td>
					<td ><%=fb.textBox("name",lvlName,true,false,false,65)%></td>
				</tr>							
				<tr>
					<td colspan="2" align="right">
					<%=fb.submit("save","Guardar",true,false)%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>	
			</table>		
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
	cdo = new CommonDataObject();

	if (lvl == 1)
	{
		cdo.setTableName("tbl_sec_provincia");
		cdo.addColValue("pais",request.getParameter("paisCode"));
		cdo.addColValue("codigo",request.getParameter("code"));
		cdo.addColValue("nombre",request.getParameter("name"));

	    cdo.setWhereClause("pais="+request.getParameter("paisCode")+" and codigo="+request.getParameter("code"));
	}
	else if (lvl == 2)
	{
		cdo.setTableName("tbl_sec_distrito");
		cdo.addColValue("pais",request.getParameter("paisCode"));
		cdo.addColValue("provincia",request.getParameter("provCode"));
		cdo.addColValue("codigo",request.getParameter("code"));
		cdo.addColValue("nombre",request.getParameter("name"));

	    cdo.setWhereClause("pais="+request.getParameter("paisCode")+" and provincia="+request.getParameter("provCode")+" and codigo="+request.getParameter("code"));
	}
	else if (lvl == 3)
	{
		cdo.setTableName("tbl_sec_corregimiento");
		cdo.addColValue("pais",request.getParameter("paisCode"));
		cdo.addColValue("provincia",request.getParameter("provCode"));
		cdo.addColValue("distrito",request.getParameter("distCode"));
		cdo.addColValue("codigo",request.getParameter("code"));
		cdo.addColValue("nombre",request.getParameter("name"));

	    cdo.setWhereClause("pais="+request.getParameter("paisCode")+" and provincia="+request.getParameter("provCode")+" and distrito="+request.getParameter("distCode")+" and codigo="+request.getParameter("code"));
	}
	else if (lvl == 4)
	{
		cdo.setTableName("tbl_sec_comunidad");
		cdo.addColValue("pais",request.getParameter("paisCode"));
		cdo.addColValue("provincia",request.getParameter("provCode"));
		cdo.addColValue("distrito",request.getParameter("distCode"));
		cdo.addColValue("corregimiento",request.getParameter("corrCode"));
		cdo.addColValue("codigo",request.getParameter("code"));
		cdo.addColValue("nombre",request.getParameter("name"));

	    cdo.setWhereClause("pais="+request.getParameter("paisCode")+" and provincia="+request.getParameter("provCode")+" and distrito="+request.getParameter("distCode")+" and corregimiento="+request.getParameter("corrCode")+" and codigo="+request.getParameter("code"));
	}
	

	if (mode.equalsIgnoreCase("add"))
	{
		cdo.setAutoIncCol("codigo");

		SQLMgr.insert(cdo);
	}
	else
	{
		SQLMgr.update(cdo);
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/pais_detalle_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/pais_detalle_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/pais_detalle_list.jsp?paisCode=<%=paisCode%>';
<%
	}
%>
	window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
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