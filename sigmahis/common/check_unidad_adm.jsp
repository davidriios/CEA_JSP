<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iUA" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vUA" scope="session" class="java.util.Vector"/>
<jsp:useBean id="opDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="opDetKey" scope="session" class="java.util.Hashtable"/>
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
int uaLastLineNo = 0;
int profLastLineNo = 0;
int uawhLastLineNo = 0;
int cdswhLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("cdsLastLineNo") != null) cdsLastLineNo = Integer.parseInt(request.getParameter("cdsLastLineNo"));
if (request.getParameter("uaLastLineNo") != null) uaLastLineNo = Integer.parseInt(request.getParameter("uaLastLineNo"));
if (request.getParameter("profLastLineNo") != null) profLastLineNo = Integer.parseInt(request.getParameter("profLastLineNo"));
if (request.getParameter("uawhLastLineNo") != null) uawhLastLineNo = Integer.parseInt(request.getParameter("uawhLastLineNo"));
if (request.getParameter("cdswhLastLineNo") != null) cdswhLastLineNo = Integer.parseInt(request.getParameter("cdswhLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

if(request.getMethod().equalsIgnoreCase("GET"))
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

	String compania = request.getParameter("compania");
	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (compania == null) compania = (String) session.getAttribute("_companyId");
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (!compania.trim().equals("")) appendFilter += " and z.compania="+compania+"";
	if (!codigo.trim().equals("")) appendFilter += " and z.codigo like '"+codigo+"%'";
	if (!descripcion.trim().equals("")) appendFilter += " and upper(z.descripcion) like '%"+descripcion.toUpperCase()+"%'";

	sql= "select z.codigo, z.descripcion, z.compania, y.nombre as compania_nombre, z.nivel from tbl_sec_unidad_ejec z, tbl_sec_compania y where z.compania=y.codigo and y.estado='A'"+appendFilter+" and z.nivel = 3 and z.estado = 'A' order by z.nivel, y.codigo, z.descripcion";
	if(fp.equals("orden_pago")){
		sql= "select z.codigo, z.descripcion, z.compania, y.nombre as compania_nombre, z.nivel from tbl_sec_unidad_ejec z, tbl_sec_compania y where z.compania=y.codigo and y.estado='A' and z.codigo < 100"+appendFilter+" and z.estado = 'A' order by z.compania, z.nivel, y.codigo, z.descripcion";
	} else if(fp.equals("user")){
	sql= "select z.codigo, z.descripcion, z.compania, y.nombre as compania_nombre, z.nivel from tbl_sec_unidad_ejec z, tbl_sec_compania y where z.compania=y.codigo and y.estado='A'"+appendFilter+" and z.nivel > 1 and z.estado = 'A' order by z.compania, z.nivel, y.codigo, z.descripcion";
	}
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
document.title = 'Unidad Administrativa - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE UNIDAD ADMINISTRATIVA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
			<% if (fp.equalsIgnoreCase("user")) { %><td width="40%">
				<cellbytelabel>Compan&iacute;a</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select codigo, '['||lpad(codigo,2,'0')||'] '||nombre from tbl_sec_compania where estado='A' order by 2","compania",compania,false,false,0,"Text10",null,null,null,"T")%>
			</td><% } else { %><%=fb.hidden("compania",compania)%><% } %>
			<td width="20%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,15,"Text10",null,null)%>
			</td>
			<td width="40%">
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion","",false,false,false,40,"Text10",null,null)%>
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
<%=fb.hidden("uaLastLineNo",""+uaLastLineNo)%>
<%=fb.hidden("profLastLineNo",""+profLastLineNo)%>
<%=fb.hidden("uawhLastLineNo",""+uawhLastLineNo)%>
<%=fb.hidden("cdswhLastLineNo",""+cdswhLastLineNo)%>
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
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
		</tr>
		</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel>Nivel</cellbytelabel></td>
			<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas los centros de servicios listados!")%></td>
		</tr>
<%
String displayUnd="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";

		if (!displayUnd.trim().equalsIgnoreCase(cdo.getColValue("compania_nombre")))
	{
%>
		<tr class="TextHeader01">
			<td colspan="4">[ <%=cdo.getColValue("compania")%> ] <%=cdo.getColValue("compania_nombre")%></td>
		</tr>
<%
	}


%>
		<%=fb.hidden("nivel"+i,cdo.getColValue("nivel"))%>
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("compania_nombre"+i,cdo.getColValue("compania_nombre"))%>

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("nivel")%></td>
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center">
			<%
			if(fp.equals("orden_pago")){
			%>
			<%=(opDetKey.containsKey(cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%>
			<%
			} else {
			%>
			<%=(vUA.contains(cdo.getColValue("compania")+"-"+cdo.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%>
			<%}%>
			</td>
		</tr>
<%
displayUnd = cdo.getColValue("compania_nombre");
}
%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

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
	if(fp.equals("orden_pago")){
		int lineNo = opDet.size();
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("unidad_adm",request.getParameter("codigo"+i));
				cdo.addColValue("nombre_unidad",request.getParameter("descripcion"+i));
				lineNo++;

				String key = "";
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try
				{
					opDet.put(key, cdo);
					opDetKey.put(cdo.getColValue("unidad_adm"), key);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	} else {
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();

				cdo.addColValue("ua",request.getParameter("codigo"+i));
				cdo.addColValue("compania",request.getParameter("compania"+i));
				cdo.addColValue("companiaNombre",request.getParameter("compania_nombre"+i));
				cdo.addColValue("uaDesc",request.getParameter("descripcion"+i));
				cdo.addColValue("comments","");
				uaLastLineNo++;

				String key = "";
				if (uaLastLineNo < 10) key = "00"+uaLastLineNo;
				else if (uaLastLineNo < 100) key = "0"+uaLastLineNo;
				else key = ""+uaLastLineNo;
				cdo.addColValue("key",key);
				if (fp.equalsIgnoreCase("user")){
					cdo.setKey(iUA.size()+1);
					cdo.setAction("I");
					key= cdo.getKey();
				}

				try
				{
					iUA.put(key, cdo);
					vUA.add(cdo.getColValue("compania")+"-"+cdo.getColValue("ua"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&profLastLineNo="+profLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&cdsLastLineNo="+cdsLastLineNo+"&uaLastLineNo="+uaLastLineNo+"&profLastLineNo="+profLastLineNo+"&uawhLastLineNo="+uawhLastLineNo+"&cdswhLastLineNo="+cdswhLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
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
	if (fp.equalsIgnoreCase("user"))
	{
%>
	window.opener.location = '../admin/reg_user.jsp?change=1&tab=3&mode=<%=mode%>&id=<%=id%>&cdsLastLineNo=<%=cdsLastLineNo%>&profLastLineNo=<%=profLastLineNo%>&uaLastLineNo=<%=uaLastLineNo%>&uawhLastLineNo=<%=uawhLastLineNo%>&cdswhLastLineNo=<%=cdswhLastLineNo%>';
<%
	} else if (fp.equalsIgnoreCase("orden_pago"))
	{
%>
	window.opener.location = '../cxp/reg_orden_pago_det.jsp?change=1&mode=<%=mode%>&id=<%=id%>';
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
