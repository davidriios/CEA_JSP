<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DocuMedicoAreas"%>
<%@ page import="issi.expediente.DetalleDocumentos"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iProf" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vProf" scope="session" class="java.util.Vector" />
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");

int cdsLastLineNo = 0;
int profLastLineNo = 0;
int seccLastLineNo = 0;
int uaLastLineNo = 0;
int uawhLastLineNo = 0;
int cdswhLastLineNo = 0;
int userLastLineNo = 0;
if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("seccLastLineNo") != null) seccLastLineNo = Integer.parseInt(request.getParameter("seccLastLineNo"));
if (request.getParameter("uaLastLineNo") != null) uaLastLineNo = Integer.parseInt(request.getParameter("uaLastLineNo"));
if (request.getParameter("uawhLastLineNo") != null) uawhLastLineNo = Integer.parseInt(request.getParameter("uawhLastLineNo"));
if (request.getParameter("cdswhLastLineNo") != null) cdswhLastLineNo = Integer.parseInt(request.getParameter("cdswhLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));

if (mode == null) mode = "add";

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

	String code = request.getParameter("code");
	String name = request.getParameter("name");
	if (code == null) code = "";
	if (name == null) name = "";
	if (!code.trim().equals("")) appendFilter += " and profile_id="+code;
	if (!name.trim().equals("")) appendFilter += " and upper(profile_name) like '%"+name.toUpperCase()+"%'";

	if (fp.equalsIgnoreCase("seccion") || fp.equalsIgnoreCase("documentos")) appendFilter += " and module_id=11";
	sql = "select profile_id, profile_name from tbl_sec_profiles where profile_id!=0 and profile_status='A'"+appendFilter+" order by profile_name";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_sec_profiles where profile_id!=0 and profile_status='A'"+appendFilter);

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
document.title = 'Centro de Servicio - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE PERFILES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
			<td width="50%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.intBox("code","",false,false,false,15)%>
			</td>
			<td width="50%">
				<cellbytelabel>Nombre</cellbytelabel>
				<%=fb.textBox("name","",false,false,false,40)%>
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
<%fb = new FormBean("cds",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
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
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("seccLastLineNo",""+seccLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("name",name)%>
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>

<table width="99%" cellpadding="0" cellspacing="0" align="center">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="70%"><cellbytelabel>Nombre</cellbytelabel></td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas los perfiles listados!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("profile_id"+i,cdo.getColValue("profile_id"))%>
		<%=fb.hidden("profile_name"+i,cdo.getColValue("profile_name"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("profile_id")%></td>
			<td><%=cdo.getColValue("profile_name")%></td>
			<td align="center"><%=(vProf.contains(cdo.getColValue("profile_id")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("profile_id"),false,false)%></td>
		</tr>
<%
}
%>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
			<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr class="TextPager">
			<td align="right">
				<%=fb.submit("save","Guardar",true,false)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%=fb.formEnd()%>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			if (fp.equalsIgnoreCase("seccion"))
			{
				DocuMedicoAreas prof = new DocuMedicoAreas();

				prof.setProfileId(request.getParameter("profile_id"+i));
				prof.setProfileName(request.getParameter("profile_name"+i));
				prof.setEditable("0");
				profLastLineNo++;

				String key = "";
				if (profLastLineNo < 10) key = "00"+profLastLineNo;
				else if (profLastLineNo < 100) key = "0"+profLastLineNo;
				else key = ""+profLastLineNo;
				prof.setKey(key);

				try
				{
					iProf.put(key, prof);
					vProf.add(request.getParameter("profile_id"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("documentos"))
			{
				DetalleDocumentos prof = new DetalleDocumentos();

				prof.setProfileId(request.getParameter("profile_id"+i));
				prof.setProfileName(request.getParameter("profile_name"+i));
				prof.setDisplayOrder("0");
				profLastLineNo++;

				String key = "";
				if (profLastLineNo < 10) key = "00"+profLastLineNo;
				else if (profLastLineNo < 100) key = "0"+profLastLineNo;
				else key = ""+profLastLineNo;
				prof.setKey(key);

				try
				{
					iProf.put(key, prof);
					vProf.add(request.getParameter("profile_id"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			else if (fp.equalsIgnoreCase("user") || fp.equalsIgnoreCase("alert"))
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("profile_id",request.getParameter("profile_id"+i));
				cdo.addColValue("profile_name",request.getParameter("profile_name"+i));
				
				cdo.setKey(iProf.size()+1);
				cdo.setAction("I");

				try
				{
					iProf.put(cdo.getKey(), cdo);
					vProf.add(request.getParameter("profile_id"+i));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&userLastLineNo="+userLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&code="+request.getParameter("code")+"&name="+request.getParameter("name"));

		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&profLastLineNo="+profLastLineNo+"&seccLastLineNo="+seccLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&userLastLineNo="+userLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&code="+request.getParameter("code")+"&name="+request.getParameter("name"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("seccion"))
	{
%>
		window.opener.location = '../expediente/doc_medico_config.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("documentos"))
	{
%>
		window.opener.location = '../expediente/exp_doc_secciones.jsp?change=1&tab=3&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&seccLastLineNo=<%=seccLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("user"))
	{
%>
		window.opener.location = '../admin/reg_user.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&uaLastLineNo=<%=uaLastLineNo%>&uawhLastLineNo=<%=uawhLastLineNo%>&cdswhLastLineNo=<%=cdswhLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("alert"))
	{
%>
		window.opener.location = '../admin/reg_alert.jsp?change=1&tab=1&mode=<%=mode%>&id=<%=id%>&profLastLineNo=<%=profLastLineNo%>&userLastLineNo=<%=userLastLineNo%>';
<%
	}
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>