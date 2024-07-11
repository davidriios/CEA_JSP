<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Authtype"%>
<%@ page import="issi.admin.Process"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="ProcMgr" scope="page" class="issi.admin.ProcessMgr" />
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
ProcMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alCustom = new ArrayList();
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");

boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		al = SQLMgr.getDataList("select id, name, 0 as checked from tbl_sec_authtype where id!=0 and id<50 order by id");
		alCustom = SQLMgr.getDataList("select id, name, 0 as checked from tbl_sec_authtype where id!=0 and id>=50 order by id");
	}
	else
	{
		if (id == null) throw new Exception("El Proceso no es válido. Por favor intente nuevamente!");

		sql = "select process_id, module_id, name from tbl_sec_process where process_id="+id;
		cdo = SQLMgr.getData(sql);

		al = SQLMgr.getDataList("select a.id, a.name, decode(b.authtype,null,0,1) as checked from tbl_sec_authtype a, (select to_number(substr(entitlement_code,-2,2)) as authtype from tbl_sec_entitlements where to_number(substr(lpad(entitlement_code,8,'0'),1,2))="+cdo.getColValue("module_id")+" and to_number(substr(lpad(entitlement_code,8,'0'),3,4))="+id+" and to_number(substr(entitlement_code,-2,2))<50) b where a.id=b.authtype(+) and a.id!=0 and a.id<50 order by a.id");
		alCustom = SQLMgr.getDataList("select a.id, decode(b.authtype,null,a.name,b.description) as name, decode(b.authtype,null,0,1) as checked from tbl_sec_authtype a, (select to_number(substr(entitlement_code,-2,2)) as authtype, entitlement_desc as description from tbl_sec_entitlements where to_number(substr(lpad(entitlement_code,8,'0'),1,2))="+cdo.getColValue("module_id")+" and to_number(substr(lpad(entitlement_code,8,'0'),3,4))="+id+" and to_number(substr(entitlement_code,-2,2))>=50) b where a.id=b.authtype(+) and a.id>=50 order by a.id");
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Mantenimiento de Proceso - '+document.title;

function validate(k)
{
	obj = eval('document.form1.check'+k);
	sts = eval('document.form1.status'+k);
	if(!obj.checked)
	{
		if(hasDBData('<%=request.getContextPath()%>','tbl_sec_profile_entitlements','entitlement_code=to_number(trim(to_char(<%=cdo.getColValue("module_id")%>,\'09\'))||trim(to_char(<%=id%>,\'0009\'))||trim(to_char('+obj.value+',\'09\')))'))
		{
			obj.checked = true;
			alert('Este proceso está enlazada con uno o más perfiles!');
			return false;
		}
		if(hasDBData('<%=request.getContextPath()%>','tbl_sec_page_entitlement','entitlement_code=to_number(trim(to_char(<%=cdo.getColValue("module_id")%>,\'09\'))||trim(to_char(<%=id%>,\'0009\'))||trim(to_char('+obj.value+',\'09\')))'))
		{
			obj.checked = true;
			alert('Este proceso está enlazada con uno o más páginas!');
			return false;
		}
		sts.value = 'D';
	}
	return true;
}

function validateCustom(k)
{
	obj = eval('document.form1.customCheck'+k);
	sts = eval('document.form1.customStatus'+k);
	if(!obj.checked)
	{
		if(hasDBData('<%=request.getContextPath()%>','tbl_sec_profile_entitlements','entitlement_code=to_number(trim(to_char(<%=cdo.getColValue("module_id")%>,\'09\'))||trim(to_char(<%=id%>,\'0009\'))||trim(to_char('+obj.value+',\'09\')))'))
		{
			obj.checked = true;
			alert('Este proceso está enlazada con uno o más perfiles!');
			return false;
		}
		if(hasDBData('<%=request.getContextPath()%>','tbl_sec_page_entitlement','entitlement_code=to_number(trim(to_char(<%=cdo.getColValue("module_id")%>,\'09\'))||trim(to_char(<%=id%>,\'0009\'))||trim(to_char('+obj.value+',\'09\')))'))
		{
			obj.checked = true;
			alert('Este proceso está enlazada con uno o más páginas!');
			return false;
		}
		sts.value = 'D';
	}
	return true;
}

function validateModule(obj)
{
	if(hasDBData('<%=request.getContextPath()%>','tbl_sec_profile_entitlements','entitlement_code=to_number(trim(to_char('+obj.value+',\'09\'))||trim(to_char(<%=id%>,\'0009\'))||\'00\')'))
	{
		alert('Este proceso está enlazada con uno o más perfiles!');
		return false;
	}
	if(hasDBData('<%=request.getContextPath()%>','tbl_sec_page_entitlement','entitlement_code=to_number(trim(to_char('+obj.value+',\'09\'))||trim(to_char(<%=id%>,\'0009\'))||\'00\')'))
	{
		alert('Este proceso está enlazada con uno o más páginas!');
		return false;
	}
	return true;
}

function doAction()
{
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PROCESO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("customSize",""+alCustom.size())%>
		<tr class="TextRow02">
			<td colspan="4" align="center">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="10%" align="right"><cellbytelabel>M&oacute;dulo</cellbytelabel></td>
			<td width="30%"><%=fb.select(ConMgr.getConnection(),"select id, to_char(id,'09')||' - '||name, id from tbl_sec_module where status='A' and id!=0 order by name","module_id",cdo.getColValue("module_id"),false,viewMode,0,null,null,"onChange=\"javascript:validateModule(this)\"","","")%></td>
			<td width="10%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="50%"><%=fb.textBox("name",cdo.getColValue("name"),true,false,viewMode,70,49)%></td>
		</tr>
		<tr>
			<td colspan="4" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel>Marcar acciones que aplican para el proceso</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel1">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
				</tr>
<%
int iCounter = 0;
int iRow = 4;
for (int i=0; i<al.size(); i++)
{
  CommonDataObject at = (CommonDataObject) al.get(i);
  if (iCounter == 0)
  {
%>
				<tr class="TextRow01">
<%
	}
%>
					<%=fb.hidden("name"+i,at.getColValue("name"))%>
					<%=fb.hidden("authtype"+i,at.getColValue("id"))%>
					<%=fb.hidden("status"+i,"")%><!--used for update validation-->
					<td width="25%">
						<%=fb.checkbox("check"+i,at.getColValue("id"),(!at.getColValue("checked").equals("0")),viewMode,null,null,(mode.equalsIgnoreCase("edit"))?"onClick=\"javascript:validate("+i+")\"":"")%>
						[<%=at.getColValue("id")%>] <%=at.getColValue("name")%>
					</td>
<%
	iCounter++;
	if (iCounter == iRow)
	{
%>
				</tr>
<%
		iCounter = 0;
	}
}
if (iCounter != 0 && iRow - iCounter > 0)
{
	for (int i=0; i < (iRow - iCounter); i++)
	{
%>
					<td width="25%">&nbsp;</td>
<%
	}
%>
				</tr>
<%
}
%>

				</table>
			</td>
		</tr>
		<tr>
			<td colspan="4" onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
				<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPanel">
					<td width="95%">&nbsp;<cellbytelabel>Marcar y nombrar las acciones personalizadas si el proceso lo requiere</cellbytelabel></td>
					<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr id="panel2">
			<td colspan="4">
				<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
				</tr>
<%
iCounter = 0;
iRow = 3;
for (int i=0; i<alCustom.size(); i++)
{
  CommonDataObject at = (CommonDataObject) alCustom.get(i);
  if (iCounter == 0)
  {
%>
				<tr class="TextRow01">
<%
	}
%>
					<%=fb.hidden("customAuthtype"+i,at.getColValue("id"))%>
					<%=fb.hidden("customStatus"+i,"")%><!--used for update validation-->
					<td width="33.33%">
						<%=fb.checkbox("customCheck"+i,at.getColValue("id"),(!at.getColValue("checked").equals("0")),viewMode,null,null,(mode.equalsIgnoreCase("edit"))?"onClick=\"javascript:validateCustom("+i+")\"":"")%>
						[<%=at.getColValue("id")%>] <%=fb.textBox("customName"+i,at.getColValue("name"),false,false,false,40,"Text10",null,null)%>
					</td>
<%
	iCounter++;
	if (iCounter == iRow)
	{
%>
				</tr>
<%
		iCounter = 0;
	}
}
if (iCounter != 0 && iRow - iCounter > 0)
{
	for (int i=0; i < (iRow - iCounter); i++)
	{
%>
					<td width="25%">&nbsp;</td>
<%
	}
%>
				</tr>
<%
}
%>

				</table>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,null)%>
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
	Process proc = new Process();
	proc.setProcessId(id);
	proc.setModuleId(request.getParameter("module_id"));
	proc.setName(request.getParameter("name"));

	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null || (request.getParameter("status"+i) != null && request.getParameter("status"+i).trim().equalsIgnoreCase("D")))
		{
			Authtype at = new Authtype();
			at.setId(request.getParameter("authtype"+i));
			at.setName(request.getParameter("name"+i));
			at.setStatus(request.getParameter("status"+i));
			at.setCustomName(request.getParameter("customName"+i));
			proc.addAuthtype(at);
		}
	}

	size = Integer.parseInt(request.getParameter("customSize"));
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("customCheck"+i) != null || (request.getParameter("customStatus"+i) != null && request.getParameter("customStatus"+i).trim().equalsIgnoreCase("D")))
		{
			Authtype at = new Authtype();
			at.setId(request.getParameter("customAuthtype"+i));
			at.setName(request.getParameter("customName"+i));
			at.setStatus(request.getParameter("customStatus"+i));
			at.setCustomName(request.getParameter("customName"+i));
			proc.addAuthtype(at);
		}
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (mode.equalsIgnoreCase("add"))
	{
		ProcMgr.add(proc);
		id = ProcMgr.getPkColValue("processId");
	}
	else if (mode.equalsIgnoreCase("edit"))
	{
    ProcMgr.update(proc);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (ProcMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ProcMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_entitlements.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_entitlements.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_entitlements.jsp';
<%
	}

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
} else throw new Exception(ProcMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>