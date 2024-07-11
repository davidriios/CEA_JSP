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
<jsp:useBean id="iFlia" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFlia" scope="session" class="java.util.Vector" />

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

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String key = "";

int fliaLastLineNo = 0;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (request.getParameter("fliaLastLineNo") != null) fliaLastLineNo = Integer.parseInt(request.getParameter("fliaLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("profile_name","");
		cdo.addColValue("page","");
		iFlia.clear();
		vFlia.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Perfil no es válido. Por favor intente nuevamente!");

		sbSql.append("select a.profile_name, a.profile_desc, a.profile_status, a.module_id, decode(a.default_page,null,' ',a.default_page) as default_page, nvl((select name||decode(qs,null,'','?'||qs) from tbl_sec_pages where id = a.default_page),' ') as page from tbl_sec_profiles a where a.profile_id = ").append(id);
		cdo = SQLMgr.getData(sbSql.toString());

		if(change == null)
		{
			iFlia.clear();
			vFlia.clear();
			sbSql = new StringBuffer();
			sbSql.append("select a.profile, a.familia, a.compania, a.comments, (select nombre from tbl_inv_familia_articulo where cod_flia = a.familia and compania = a.compania) as desc_familia, (select nombre from tbl_sec_compania where codigo = a.compania) as compania_name from tbl_sec_profile_familia a where a.profile = ").append(id).append(" order by 2");
			al  = SQLMgr.getDataList(sbSql.toString());
			fliaLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo2 = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo2.addColValue("key",key);

				try
				{
					iFlia.put(key, cdo2);
					vFlia.addElement(cdo2.getColValue("compania")+"-"+cdo2.getColValue("familia"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}

		}

	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Agregar / Modificar Perfil - '+document.title;

function checkName(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_sec_profiles','profile_name=\''+obj.value+'\'','<%=cdo.getColValue("profile_name")%>');
}
function doAction()
{
}
function showFliaList(tab)
{
	abrir_ventana1('../common/check_familia.jsp?fp=profile&mode=<%=mode%>&id=<%=id%>&tab='+tab+'&fliaLastLineNo=<%=fliaLastLineNo%>');
}

function getPage(){abrir_ventana1('../common/search_page.jsp?fp=profile&profile=<%=id%>');}
function clearPage(){document.form1.default_page.value='';document.getElementById('lblPage').innerHTML='';}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - PERFIL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("fliaLastLineNo",""+fliaLastLineNo)%>
<%=fb.hidden("fliaSize",""+iFlia.size())%>
<%=fb.hidden("oldStatus",cdo.getColValue("profile_status"))%>

<%fb.appendJsValidation("if(checkName(document.form1.name))error++;");%>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="15%" align="right"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("name",cdo.getColValue("profile_name"),true,false,false,40,null,null,"onBlur=\"javascript:checkName(this)\"")%></td>
			<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="35%"><%=fb.textBox("desc",cdo.getColValue("profile_desc"),true,false,false,40)%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>M&oacute;dulo</cellbytelabel></td>
			<td><%=fb.select(ConMgr.getConnection(),"select id, name, id from tbl_sec_module where status='A' order by name","module",cdo.getColValue("module_id"))%></td>
			<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("status","A=Activo,I=Inactivo",cdo.getColValue("profile_status"))%></td>
		</tr>
		<tr class="TextRow01">
			<td align="right">
				<cellbytelabel>Pantalla Inicial</cellbytelabel>
				<%=fb.button("btnPage","...",true,false,null,null,"onClick=\"javascript:getPage()\"")%>
			</td>
			<td colspan="3">
				<%=fb.hidden("default_page",cdo.getColValue("default_page"))%>
				<label id="lblPage" onDblClick="javascript:clearPage()"><%=cdo.getColValue("page")%></label>
			</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
		</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

		</table>


		<!-- TAB0 DIV END HERE-->
</div>

<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="1" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fliaLastLineNo",""+fliaLastLineNo)%>
<%=fb.hidden("fliaSize",""+iFlia.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Perfil</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="85%"><%=cdo.getColValue("profile_name")%></td>
						</tr>
						</table>
					</td>
				</tr>


				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Familias</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td colspan="2"><cellbytelabel>Compa&ntilde;&iacute;a</cellbytelabel></td>
							<td colspan="2"><cellbytelabel>Familia</cellbytelabel></td>
							<td width="37%" rowspan="2"><cellbytelabel>Comentarios</cellbytelabel></td>
							<td width="3%" rowspan="2"><%=fb.button("addFlia","+",true,false,null,null,"onClick=\"javascript:showFliaList(1)\"","Agregar Familias")%></td>
						</tr>
						<tr class="TextHeader" align="center">
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Nombre</cellbytelabel></td>
							<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
							<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iFlia);
for (int i=1; i<=iFlia.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject cdo2 = (CommonDataObject) iFlia.get(key);
%>
						<%=fb.hidden("key"+i,""+cdo2.getColValue("key"))%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("compania"+i,""+cdo2.getColValue("compania"))%>
						<%=fb.hidden("compania_name"+i,""+cdo2.getColValue("compania_name"))%>
						<%=fb.hidden("familia"+i,""+cdo2.getColValue("familia"))%>
						<%=fb.hidden("desc_familia"+i,""+cdo2.getColValue("desc_familia"))%>

						<tr class="TextRow01">
							<td><%=cdo2.getColValue("compania")%></td>
							<td><%=cdo2.getColValue("compania_name")%></td>
							<td><%=cdo2.getColValue("familia")%></td>
							<td><%=cdo2.getColValue("desc_familia")%></td>
							<td><%=fb.textarea("comments"+i,cdo2.getColValue("comments"),false,false,false,50,2,2000)%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
<%
}
	fb.appendJsValidation("if(error>0)doAction();");

%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td colspan="4" align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<!--<%//=fb.radio("saveOption","N")%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>

<%=fb.formEnd(true)%>
</table>
</div>
<!-- TAB1 DIV END HERE-->

<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
String tabLabel = "'Generales'";
if(!mode.trim().equals("add")) tabLabel += ",'Familia'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

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
	String baction = request.getParameter("baction");

	if (tab.equals("0")){ //Generales
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sec_profiles");
		cdo.addColValue("profile_name",request.getParameter("name"));
		cdo.addColValue("profile_desc",request.getParameter("desc"));
		cdo.addColValue("profile_status",request.getParameter("status"));
		cdo.addColValue("module_id",request.getParameter("module"));
		cdo.addColValue("default_page",request.getParameter("default_page"));

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add")) {
			cdo.setAutoIncCol("profile_id");
			cdo.addPkColValue("profile_id","");
			SQLMgr.insert(cdo);
			id = SQLMgr.getPkColValue("profile_id");
		} else {
			cdo.setWhereClause("profile_id="+id);
			if (request.getParameter("oldStatus").equalsIgnoreCase(request.getParameter("status"))) SQLMgr.update(cdo);
			else {
				SQLMgr.update(cdo,true,true,false);
				if (SQLMgr.getErrCode().equals("1")) {

					CommonDataObject param = new CommonDataObject();
					param.setSql("call sp_sec_save_profile_menu_tree (?)");
					param.addInNumberStmtParam(1,id);
					param = SQLMgr.executeCallable(param,false,true);

				}
			}
		}
		ConMgr.clearAppCtx(null);

	}
	else if (tab.equals("1")) //Familias
	{
		int size = 0;
		if (request.getParameter("fliaSize") != null) size = Integer.parseInt(request.getParameter("fliaSize"));
		String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setTableName("tbl_sec_profile_familia");
			cdo2.setWhereClause("profile="+id);

			cdo2.addColValue("compania",request.getParameter("compania"+i));
			cdo2.addColValue("profile",id);
			cdo2.addColValue("familia",request.getParameter("familia"+i));
			cdo2.addColValue("compania_name",request.getParameter("compania_name"+i));
			cdo2.addColValue("desc_familia",request.getParameter("desc_familia"+i));
			cdo2.addColValue("comments",request.getParameter("comments"+i));
			cdo2.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo2.getColValue("key");
			else
			{
				try
				{
					iFlia.put(cdo2.getColValue("key"),cdo2);
					al.add(cdo2);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			vFlia.remove(((CommonDataObject) iFlia.get(itemRemoved)).getColValue("compania")+"-"+((CommonDataObject) iFlia.get(itemRemoved)).getColValue("familia"));
			iFlia.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&fliaLastLineNo="+fliaLastLineNo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&tab=1&mode="+mode+"&id="+id+"&fliaLastLineNo="+fliaLastLineNo);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo2 = new CommonDataObject();

			cdo2.setTableName("tbl_sec_profile_familia");
			cdo2.setWhereClause("profile="+id);

			al.add(cdo2);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
		ConMgr.clearAppCtx(null);
	}
	//***************************************************************************
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
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admin/list_profile.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admin/list_profile.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admin/list_profile.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&tab=<%=tab%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>