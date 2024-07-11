<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iGT" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vGT" scope="session" class="java.util.Vector"/>
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
StringBuffer sbSqlComp = new StringBuffer();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
int profLastLineNo = 0;
int cdsLastLineNo = 0;
int uaLastLineNo = 0;
int whLastLineNo = 0;
int ajLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
if (request.getParameter("uaLastLineNo") != null) uaLastLineNo = Integer.parseInt(request.getParameter("uaLastLineNo"));
if (request.getParameter("whLastLineNo") != null) whLastLineNo = Integer.parseInt(request.getParameter("whLastLineNo"));
if (request.getParameter("ajLastLineNo") != null) ajLastLineNo = Integer.parseInt(request.getParameter("ajLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	sbSqlComp.append("select a.codigo, lpad(a.codigo,5,'0')||' - '||a.nombre from tbl_sec_compania a where a.estado = 'A'");
	/*if (fp.equalsIgnoreCase("user")) {
		if (id == null || id.trim().equals("")) throw new Exception("El Usuario no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select count(*) as nRecs from tbl_sec_user_profile where user_id = ");
		sbSql.append(id);
		sbSql.append(" and profile_id = 0");
		CommonDataObject cdo = SQLMgr.getData(sbSql.toString());
		if (cdo.getColValue("nRecs").equals("0")) {
			sbSqlComp.append(" and exists (select null from tbl_sec_user_comp where user_id = ");
			sbSqlComp.append(id);
			sbSqlComp.append(" and status = 'A' and company_id = a.codigo)");
		}
	} else {
		if (!UserDet.getUserProfile().contains("0")) {
			sbSqlComp.append(" and exists (select null from tbl_sec_user_comp where user_id = ");
			sbSqlComp.append(UserDet.getUserId());
			sbSqlComp.append(" and status = 'A' and company_id = a.codigo)");
		}
	}*/
	sbSqlComp.append(" order by a.nombre");

	String compania = request.getParameter("compania");
	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (compania == null) compania = "";
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";

	if (!compania.trim().equals("")) { sbFilter.append(" and a.compania = "); sbFilter.append(compania); }
	if (!codigo.trim().equals("")) { sbFilter.append(" and a.codigo = "); sbFilter.append(codigo); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and upper(a.descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }

	sbSql = new StringBuffer();
	sbSql.append("select a.codigo, a.compania, a.descripcion, (select nombre from tbl_sec_compania where codigo = a.compania) as compania_nombre from tbl_pla_ct_grupo a");
	if (sbFilter.length() > 0) {
		sbSql.append(" where");
		sbSql.append(sbFilter.substring(4));
	}
	sbSql.append(" order by 2, 3");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");

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
document.title = 'Selección Grupo Trabajo - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE GRUPO DE TRABAJO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("ajLastLineNo",""+ajLastLineNo)%>
			<td width="50%">
				Compa&ntilde;&iacute;a
				<%=fb.select(ConMgr.getConnection(),sbSqlComp.toString(),"compania",compania,false,false,0,"Text10",null,null,null,"T")%>
			</td>
			<td width="12%">
				C&oacute;digo
				<%=fb.intBox("codigo","",false,false,false,4,4,"Text10",null,null)%>
			</td>
			<td width="38%">
				Descripci&oacute;n
				<%=fb.textBox("descripcion","",false,false,false,40,200,"Text10",null,null)%>
				<%=fb.submit("go","Ir",true,false,"Text10",null,null)%>
			</td>
<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("empresa",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
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
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("cdsLastLineNo",""+cdsLastLineNo)%>
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("whLastLineNo",""+whLastLineNo)%>
<%=fb.hidden("ajLastLineNo",""+ajLastLineNo)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
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
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="30%">C&oacute;digo</td>
			<td width="60%">Nombre</td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll(this.form.name,'check',"+al.size()+",this)\"","Seleccionar todos los grupos listados!")%></td>
		</tr>
<%
String groupBy = "";
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (!groupBy.equalsIgnoreCase(cdo.getColValue("compania"))) {
%>
		<tr>
			<td class="TextHeader02" colspan="3"><%=cdo.getColValue("compania")%> - <%=cdo.getColValue("compania_nombre")%></td>
		</tr>
<% } %>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("compania_nombre"+i,cdo.getColValue("compania_nombre"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=(vGT.contains(cdo.getColValue("codigo")+"-"+cdo.getColValue("compania")))?"Elegido":fb.checkbox("check"+i,"x",false,false)%></td>
		</tr>
<%
	groupBy = cdo.getColValue("compania");
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
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
} else {
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++) 	{
		if (request.getParameter("check"+i) != null) {
			CommonDataObject cdo = new CommonDataObject();

			cdo.setKey(""+(iGT.size() + 1));
			cdo.setAction("I");
			cdo.addColValue("grupo",request.getParameter("codigo"+i));
			cdo.addColValue("compania",request.getParameter("compania"+i));
			cdo.addColValue("grupo_desc",request.getParameter("descripcion"+i));
			cdo.addColValue("compania_nombre",request.getParameter("compania_nombre"+i));
			cdo.addColValue("observacion","");

			try {
				iGT.put(cdo.getKey(),cdo);
				vGT.add(cdo.getColValue("grupo")+"-"+cdo.getColValue("compania"));
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&profLastLineNo="+profLastLineNo+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&whLastLineNo="+whLastLineNo+"&ajLastLineNo="+ajLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	} else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&profLastLineNo="+profLastLineNo+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&whLastLineNo="+whLastLineNo+"&ajLastLineNo="+ajLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow(){<% if (fp.equalsIgnoreCase("user")) { %>window.opener.location='../admin/reg_user.jsp?change=1&tab=8&mode=<%=mode%>&id=<%=id%>&profLastLineNo=<%=profLastLineNo%>&cdsLastLineNo=<%=cdsLastLineNo%>&uaLastLineNo=<%=uaLastLineNo%>&whLastLineNo=<%=whLastLineNo%>&ajLastLineNo=<%=ajLastLineNo%>';<% } %>window.close();}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<% } %>