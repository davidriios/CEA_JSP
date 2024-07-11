<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.MessageCode"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="vAccess" scope="session" class="java.util.Vector"/>
<jsp:useBean id="htAccess" scope="session" class="java.util.Hashtable"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdo = null;
int rowCount = 0;
String sql = "";
String id = request.getParameter("id");
String appendFilter = "";
String module = request.getParameter("module");
String accessCode = request.getParameter("accessCode");
String access = request.getParameter("access");
String change = request.getParameter("change");
String mode = request.getParameter("mode");

if (module == null)
{
	sql = "select lpad(id,2,'0') as module, lpad(id,2,'0')||' - '||name as moduleName from tbl_sec_module where status='A' and id!=0 order by name";
	cdo = SQLMgr.getData(sql);
	module = cdo.getColValue("module");
}
if (id == null) throw new Exception("La Página no es válido. Por favor intente nuevamente!");
if (module != null && !module.trim().equals("")) appendFilter += " and lpad(z.entitlement_code,8,'0') like '"+module+"%'";
if (accessCode != null && !accessCode.trim().equals("")) appendFilter += " and lpad(z.entitlement_code,8,'0') like '%"+accessCode.toUpperCase()+"%'";
if (access != null && !access.trim().equals("")) appendFilter += " and upper(z.entitlement_desc) like '%"+access.toUpperCase()+"%'";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (change == null)
	{
		sql = "select lpad(entitlement_code,8,'0') as entitlement_code, qs, comments from tbl_sec_page_entitlement where page_id="+id+"";
		al = SQLMgr.getDataList(sql);
		vAccess.clear();
		htAccess.clear();
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject entitle = (CommonDataObject) al.get(i);

			cdo = new CommonDataObject();

			cdo.setTableName("tbl_sec_page_entitlement");
			cdo.addColValue("page_id",id);
			cdo.addColValue("entitlement_code",entitle.getColValue("entitlement_code"));
			cdo.addColValue("qs",entitle.getColValue("qs"));
			cdo.addColValue("comments",entitle.getColValue("comments"));
			cdo.setWhereClause("page_id="+id);

			vAccess.addElement(entitle.getColValue("entitlement_code"));
			htAccess.put(entitle.getColValue("entitlement_code"),cdo);
		}
	}

	sql = "select name||decode(qs,null,'','?'||qs) as name, nvl(qs,' ') as qs, status, id from tbl_sec_pages where id="+id;
	cdo = SQLMgr.getData(sql);

	if (viewMode)
	{
		sql = "select substr(lpad(z.entitlement_code,8,'0'),0,2) as module_id, lpad(z.entitlement_code,8,'0') as entitlement_code, z.entitlement_desc, y.name as module_name, nvl(v.name||decode(v.qs,null,nvl(x.qs,''),'?'||v.qs||decode(x.qs,null,'','&'||x.qs)),' ') as url, x.comments from tbl_sec_entitlements z, tbl_sec_module y, tbl_sec_page_entitlement x, tbl_sec_pages v where substr(lpad(z.entitlement_code,8,'0'),0,2)=lpad(y.id,2,'0') and z.entitlement_code!=0 and z.entitlement_code=x.entitlement_code and x.page_id=v.id and x.page_id="+id+" order by 5, 1, 2";
		al = SQLMgr.getDataList(sql);
		rowCount = CmnMgr.getCount("select count(*) from tbl_sec_entitlements z, tbl_sec_module y, tbl_sec_page_entitlement x, tbl_sec_pages v where substr(lpad(z.entitlement_code,8,'0'),0,2)=lpad(y.id,2,'0') and z.entitlement_code!=0 and z.entitlement_code=x.entitlement_code and x.page_id=v.id and x.page_id="+id+"");
	}
	else
	{
		sql = "select substr(lpad(z.entitlement_code,8,'0'),0,2) as module_id, lpad(z.entitlement_code,8,'0') as entitlement_code, z.entitlement_desc, y.name as module_name from tbl_sec_entitlements z, tbl_sec_module y where substr(lpad(z.entitlement_code,8,'0'),0,2)=lpad(y.id,2,'0') and z.entitlement_code!=0"+appendFilter+" order by 1, 2";
		//al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		al = SQLMgr.getDataList(sql);
		rowCount = CmnMgr.getCount("select count(*) from tbl_sec_entitlements z, tbl_sec_module y where substr(lpad(z.entitlement_code,8,'0'),0,2)=lpad(y.id,2,'0') and z.entitlement_code!=0"+appendFilter);
	}

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";

	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);

	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;

	if(rowCount==0) pVal=0;
	else pVal=preVal;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_nocaps.jsp"%>
<script language="javascript">
document.title = 'Derechos de Accesos - '+document.title;

function checkAll(module)
{
	var size = document.form1.size.value;

	for (i=0; i<size; i++)
	{
		if (eval('document.form1.module'+module).checked)
		{
			if (eval('document.form1.module_id'+i).value.substr(0,2) == module) eval('document.form1.entitlement_check'+i).checked = true;
		}
		else
		{
			if (eval('document.form1.module_id'+i).value.substr(0,2) == module) eval('document.form1.entitlement_check'+i).checked = false;
		}
	}
}

function checkParent(obj,k)
{
	if(obj.checked)eval('document.form1.entitlement_check'+k).checked=true;
}

function doSubmit()
{
	document.search00.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PERFIL - DERECHOS DE ACCESOS"></jsp:param>
</jsp:include>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

<table align="center" width="99%" cellpadding="1" cellspacing="1">
<tr class="TextHeader">
	<td colspan="2" align="center">PAGINA: <%=cdo.getColValue("name")%></td>
</tr>
<%
if (!viewMode)
{
%>
<tr class="TextFilter">

	<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
	<%=fb.formStart()%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("mode",mode)%>
	<td colspan="2">
		<cellbytelabel>M&oacute;dulo</cellbytelabel>
		<%=fb.select(ConMgr.getConnection(),"select lpad(id,2,'0'), lpad(id,2,'0')||' - '||name from tbl_sec_module where status='A' and id!=0 order by name","module",module,false,false,0,"Text10",null,"onChange=\"javascript:doSubmit()\"")%>
		<cellbytelabel>Derecho de Acceso</cellbytelabel>
		<%=fb.textBox("accessCode","",false,false,false,8,"Text10",null,null)%>
		<%=fb.textBox("access","",false,false,false,40,"Text10",null,null)%>
		<%=fb.submit("go","Ir")%>
	</td>
	<%=fb.formEnd()%>

</tr>
<%
}
%>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("qs",cdo.getColValue("qs"))%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("module",module).replaceAll(" id=\"module\"","")%>
<%=fb.hidden("accessCode",accessCode).replaceAll(" id=\"accessCode\"","")%>
<%=fb.hidden("access",access).replaceAll(" id=\"access\"","")%>
		<tr class="TextPager">
			<td colspan="5" align="right">
				<!--Opciones de Guardar:
				<%=fb.radio("saveOptionT","N")%>Crear Otro
				<%=fb.radio("saveOptionT","O",true,false,false)%>Mantener Abierto
				<%=fb.radio("saveOptionT","C")%>Cerrar -->
				<%=fb.submit("saveT","Guardar",true,viewMode)%>
				<%=fb.button("cancelT","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="5">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%//=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><!--<cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%>--></td>
					<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
			</td>
		</tr>
		<tr class="TextHeader01" align="center">
			<td colspan="3"><cellbytelabel>Derecho de Acceso</cellbytelabel></td>
			<td>Query String</td>
			<td>Comentario</td>
		</tr>
<%
String moduleName = "";
String parent = "";
String style = "";
for (int i=0; i<al.size(); i++)
{
	boolean containAccess = false;
	String qs = "";
	String comments = "";
	cdo = (CommonDataObject) al.get(i);

	if(vAccess.contains(cdo.getColValue("entitlement_code"))){
		containAccess = true;
		CommonDataObject cdo2 = (CommonDataObject) htAccess.get(cdo.getColValue("entitlement_code"));
		qs = cdo2.getColValue("qs");
		comments = cdo2.getColValue("comments");
	}

	style = "";
	if (cdo.getColValue("entitlement_code").trim().endsWith("00"))
	{
		parent = ""+i;
		style=" style=\"font-weight:bold;\"";
	}

	if (!moduleName.equalsIgnoreCase(cdo.getColValue("module_name")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="5">
				<%=fb.checkbox("module"+cdo.getColValue("module_id"),cdo.getColValue("module_id"),false,viewMode,null,null,"onClick=\"javascript:checkAll('"+cdo.getColValue("module_id")+"')\"")%>
				<label for="module<%=cdo.getColValue("module_id")%>"><%=cdo.getColValue("module_name")%></label>
			</td>
		</tr>
<%
	}
%>
		<%=fb.hidden("module_id"+i,cdo.getColValue("module_id"))%>
		<%=fb.hidden("entitlement_code"+i,cdo.getColValue("entitlement_code"))%>
		<tr class="TextRow01">
			<td width="4%" align="right"><%=fb.checkbox("entitlement_check"+i,"y",containAccess,viewMode,null,null,(cdo.getColValue("entitlement_code").trim().endsWith("00"))?"":"onClick=\"javascript:checkParent(this,'"+parent+"')\"")%></td>
			<td width="9%" align="center"><label for="entitlement_check<%=i%>"<%=style%>>[<%=cdo.getColValue("entitlement_code")%>]</label></td>
			<td width="36%"><label for="entitlement_check<%=i%>"<%=style%>><%=cdo.getColValue("entitlement_desc")%></label></td>
			<td width="20%" align="center"><%=fb.textBox("qs"+i,qs,false,viewMode,false,30,"Text10",null,null)%></td>
			<td width="31%" align="center"><%=fb.textBox("comments"+i,comments,false,viewMode,false,50,"Text10",null,null)%></td>
		</tr>
<%
	moduleName = cdo.getColValue("module_name");
}
%>
		<tr>
			<td colspan="5">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%//=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><!--<cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%>--></td>
					<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
			</td>
		</tr>
		<tr class="TextPager">
			<td colspan="5" align="right">
				<!--Opciones de Guardar:
				<%=fb.radio("saveOptionB","N")%>Crear Otro
				<%=fb.radio("saveOptionB","O",true,false,false)%>Mantener Abierto
				<%=fb.radio("saveOptionB","C")%>Cerrar -->
				<%=fb.submit("saveB","Guardar",true,viewMode)%>
				<%=fb.button("cancelB","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	String saveOption = (request.getParameter("saveOptionT") == null)?((request.getParameter("saveOptionB") == null)?"C":request.getParameter("saveOptionB")):request.getParameter("saveOptionT");//N=Create New,O=Keep Open,C=Close
	int size = Integer.parseInt(request.getParameter("size"));
	String qs = request.getParameter("qs");

	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sec_page_entitlement");
		cdo.addColValue("page_id",id);
		cdo.addColValue("entitlement_code",request.getParameter("entitlement_code"+i));
		cdo.addColValue("qs",request.getParameter("qs"+i));
		cdo.addColValue("comments",request.getParameter("comments"+i));
		cdo.setWhereClause("page_id="+id);

		if (vAccess.contains(request.getParameter("entitlement_code"+i)))
		{
			vAccess.remove(request.getParameter("entitlement_code"+i));
			htAccess.remove(request.getParameter("entitlement_code"+i));
		}

		if (request.getParameter("entitlement_check"+i) != null)
		{
			vAccess.addElement(request.getParameter("entitlement_code"+i));
			htAccess.put(request.getParameter("entitlement_code"+i),cdo);
		}
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&module="+module+"&accessCode="+accessCode+"&access="+access+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&id="+id+"&module="+module+"&accessCode="+accessCode+"&access="+access+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}

	al.clear();
	Enumeration e = htAccess.elements();
	while(e.hasMoreElements())
	{
		al.add((CommonDataObject) e.nextElement());
	}

	if (al.size() == 0)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sec_page_entitlement");
		cdo.setWhereClause("page_id="+id+"");

		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.insertList(al,true,true,true,false);
	if (SQLMgr.getErrCode().equals(MessageCode.SUCCESS)) SQLMgr.execute("call sp_sec_save_page_menu_tree("+id+")",false,true);
	ConMgr.clearAppCtx(null);
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_page.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_page.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_page.jsp';
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
out.flush();
%>