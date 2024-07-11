<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormularioTest"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="FormularioTestMgr" scope="page" class="issi.admin.FormularioTestMgr" />
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String id = request.getParameter("id");
String root = request.getParameter("root");
String status = request.getParameter("status");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (id == null)  throw new Exception("El Menu no es válido. Por favor intente nuevamente!");
if (root == null)
	if (id.equals("0")) root = "";
	else root = ((FormularioTest) sbb.getSingleRowBean(ConMgr.getConnection(),"select root_id as root from tbl_frm_terapias_test where id="+id+"",FormularioTest.class)).getRoot();
if (status == null) status = "";
if (!root.equals("")) appendFilter += " and a.root_id="+root+"";
if (!status.equals("")) appendFilter += " and a.status='"+status+"'";

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

	String xid = request.getParameter("xid");
	String displayLabel = request.getParameter("displayLabel");
	String path = request.getParameter("path");
	if (xid == null) xid = "";
	if (displayLabel == null) displayLabel = "";
	if (path == null) path = "";
	if (!xid.equals("")) appendFilter += " and a.id like '"+xid.toUpperCase()+"%'";
	if (!displayLabel.equals("")) appendFilter += " and upper(a.titulo_frm) like '%"+displayLabel.toUpperCase()+"%'";
	if (!path.equals("")) appendFilter += " and upper(a.path) like '%"+path.toUpperCase()+"%'";

	if (fp.equalsIgnoreCase("frm"))
	{
		sql = "select a.id, a.titulo_frm as displayLabel, a.display_order as displayOrder, nvl(a.desc_terapia,'NA') as description, a.parent_id as parentId, a.level_frm as frmLevel, a.root_id as root, get_frm_tree(a.id,0) as parentLabel from tbl_frm_terapias_test a, (select * from tbl_frm_terapias_test where get_frm_code(id) like get_frm_code("+id+")"+((id.equals("0"))?"":"||'%'")+") b where a.id=b.id(+) and b.id is null"+appendFilter+" order by Get_Frm_Code(a.id), a.id";
		//System.out.println("\n\n"+sql+"\n\n");
		al = sbb.getBeanList(ConMgr.getConnection(),sql,FormularioTest.class);
		rowCount = CmnMgr.getCount("select count(*) from tbl_frm_terapias_test a, (select * from tbl_frm_terapias_test where get_frm_code(id) like get_frm_code("+id+")"+((id.equals("0"))?"":"||'%'")+") b where a.id=b.id(+) and b.id is null"+appendFilter+"");
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
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Administración de Menu - '+document.title;

function setMenu(k)
{
<%
	if (fp.equalsIgnoreCase("frm"))
	{
%>
	window.opener.document.form1.parentId.value = eval('document.frm.id'+k).value;
	window.opener.document.getElementById('parentLabel').innerHTML = eval('document.frm.displayLabel'+k).value;
	window.opener.document.form1.root.value = eval('document.frm.root'+k).value;
	window.opener.document.form1.frmLevel.value = eval('document.frm.frmLevel'+k).value;
<%
	}
%>
	window.close();
}

function getMain(formX)
{
	formX.root.value = document.search00.root.value;
	formX.status.value = document.search00.status.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MENU PADRE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">

<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("id",id)%>
			<td colspan="2">
				<cellbytelabel>Formulario Principal</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select root_id as root, titulo_frm, Get_Frm_Code(id) from tbl_frm_terapias_test where parent_id=0 order by 2","root",root,"T")%>
				<!--Estado-->
				<%//=fb.select("status","A=ACTIVO,I=INACTIVO",status,"T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">
				C<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("xid","",false,false,false,10)%>
			</td>
			<td width="50%">
				<cellbytelabel>Formulario</cellbytelabel>
				<%=fb.textBox("displayLabel","",false,false,false,40)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableLeftBorder TableTopBorder TableRightBorder">
	<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
		<tr class="TextHeader" align="center">
			<td width="6%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Nivel</cellbytelabel></td>
			<td width="40%"><cellbytelabel>Formulario</cellbytelabel></td>
			<td width="5%"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="20%">&nbsp;</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%fb = new FormBean("frm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%
for (int i=0; i<al.size(); i++)
{

	FormularioTest frm = (FormularioTest) al.get(i);
	int lvl = Integer.parseInt(frm.getFrmLevel());
	
	String color = "";
	if (lvl == 1) color = "TextRow01";
	else if (lvl == 2) color = "TextRow02";
	else if (lvl == 3) color = "TextRow03";

	String indent = "";
	for (int ind=1; ind<lvl; ind++) indent += "&nbsp;&nbsp;&nbsp;";
%>
		<%=fb.hidden("id"+i,frm.getId())%>
		<%=fb.hidden("displayLabel"+i,frm.getParentLabel())%>
		<%=fb.hidden("root"+i,frm.getRoot())%>
		<%=fb.hidden("frmLevel"+i,""+(lvl + 1))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setMenu(<%=i%>)" style="cursor:pointer">
			<td align="right"><%=frm.getId()%></td>
			<td align="center"><%=lvl%></td>
			<td><%=indent+frm.getDisplayLabel()%></td>
            <td align="center"><%=frm.getDisplayOrder()%></td>
			<td><%//=(frm.getPath().equalsIgnoreCase("NA"))?"":frm.getPath()%></td>
			<td align="center"><%//=(frm.getStatus().equalsIgnoreCase("A"))?"Activo":"Inactivo"%></td>
		</tr>
<%
}
%>
<%=fb.formEnd()%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><!--Registros desde <%=pVal%> hasta <%=nVal%>--></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("root",root).replaceAll(" id=\"root\"","")%>
<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
			<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>