<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

String sql = "";
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String cds = request.getParameter("cds");
String tipo = request.getParameter("tipo");

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")) code = "0";
	else
	{
		if (code == null) throw new Exception("La Impresora no es válida. Por favor intente nuevamente!");

		sql = "select a.id, a.centro_servicio, c.descripcion as centro_servicio_desc, a.tipo, decode(a.tipo,'R','RECETAS',a.tipo) as tipo_desc, a.email, a.status,decode(a.status,'A','Activo','I','Inactivo',a.status) as status_desc, a.observacion, a.descripcion from tbl_email_to_printer a, tbl_cds_centro_servicio c where a.centro_servicio = c.codigo and id ="+code+" and a.centro_servicio = "+cds+" and tipo = '"+tipo+"'";
		cdo = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script language="javascript">
var allowAll = true;
document.title=" EMAIL TO PRINTER - "+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EMAIL TO PRINTER MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="80%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("mode",mode)%>
		<%=fb.hidden("code",code)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel>Direcciones de la Impresora</cellbytelabel></td>
		</tr>

		<tr class="TextRow01">
			<td>Centro de Servicio</td>
			<td>
				<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId"),false,CmnMgr.vector2numSqlInClause((java.util.Vector) session.getAttribute("_cds"))),cdo.getColValue("centro_servicio"),false,false,0,"Text10",null,null,null,"")%>
			</td>
			<td>Tipo</td>
			<td>
				<%=fb.select("tipo","R=Recetas, P=Plan de Salida",cdo.getColValue("tipo"),"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td>Correo</td>
			<td>
				 <%=fb.textBox("email",cdo.getColValue("email"),false,false,viewMode,100,"","","")%>
			</td>
			<td>Estado</td>
			<td>
				<%=fb.select("status","A=Activo,I=Inactivo",cdo.getColValue("status"),"")%>
			</td>
		</tr>

		<tr class="TextRow01">
			<td>Descripci&oacute;n</td>
			<td colspan="3">
				 <%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,viewMode,100,"","","")%>
			</td>
		</tr>

		<tr class="TextRow01">
			<td><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
			<td colspan="3"><%=fb.textarea("observacion", cdo.getColValue("observacion"), false, false, viewMode, 0, 2,1000, "", "width:100%", "")%></td>
		</tr>


		<tr class="TextRow02">
			<td align="right" colspan="4">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	mode = request.getParameter("mode");
	code = request.getParameter("code");
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_email_to_printer");
	cdo.addColValue("id",request.getParameter("code"));
	cdo.addColValue("centro_servicio",request.getParameter("cds"));
	cdo.addColValue("tipo",request.getParameter("tipo"));
	cdo.addColValue("email",request.getParameter("email"));
	cdo.addColValue("status",request.getParameter("status"));
	cdo.addColValue("observacion",request.getParameter("observacion"));
	cdo.addColValue("descripcion",request.getParameter("descripcion"));

	cdo.setCreateXML(true);
	cdo.setFileName("cds_email_2_printer.xml");
	cdo.setOptValueColumn("distinct tipo, centro_servicio");
	cdo.setOptLabelColumn("(select descripcion from tbl_cds_centro_servicio where codigo = centro_servicio )||' *** '||decode(tipo,'P','PLAN','R','RECETAS')");
	cdo.setKeyColumn("centro_servicio");
	cdo.setXmlWhereClause("status='A'");
	cdo.setXmlOrderBy("3");

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		cdo.setAutoIncWhereClause("centro_servicio = "+request.getParameter("cds") +" and tipo = '"+request.getParameter("tipo")+"'");
		cdo.setWhereClause("centro_servicio = "+request.getParameter("cds") +" and tipo = '"+request.getParameter("tipo")+"'");
		cdo.setAutoIncCol("id");
		cdo.addPkColValue("id","");
		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("id");
	}
	else
	{
		cdo.setWhereClause("id="+request.getParameter("code")+" and centro_servicio = "+request.getParameter("cds") +" and tipo = '"+request.getParameter("tipo")+"'" );
		SQLMgr.update(cdo);
	}

	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.opener.location = '<%=request.getContextPath()%>/admin/email_2_printer_list.jsp?beginSearch=&cds=<%=request.getParameter("cds")%>&tipo=<%=request.getParameter("tipo")%>&code=<%=code%>';
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>&cds=<%=request.getParameter("cds")%>&tipo=<%=request.getParameter("tipo")%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>