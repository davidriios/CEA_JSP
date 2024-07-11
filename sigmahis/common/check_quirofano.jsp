<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iWH" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vWH" scope="session" class="java.util.Vector" />
<jsp:useBean id="iUAWH" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vUAWH" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCDSWH" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCDSWH" scope="session" class="java.util.Vector" />
<jsp:useBean id="iWhInv" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vWhInv" scope="session" class="java.util.Vector" />
<jsp:useBean id="iQx" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vQx" scope="session" class="java.util.Vector" />

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
String fg = request.getParameter("fg");
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!"); 

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

	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	String estado = request.getParameter("estado");
	String cds = request.getParameter("cds");
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";
	if (estado == null) estado = "";
	if (cds == null) cds = "";
	sbFilter.append(" and quirofano = 2 and nvl(centro_servicio,unidad_admin) in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO')) ");
	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(codigo) like '%"); sbFilter.append(codigo.toUpperCase()); sbFilter.append("%'"); }
	if (!descripcion.trim().equals("")) {  sbFilter.append(" and upper(descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) {  sbFilter.append(" and estado_habitacion = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }
	if (!cds.trim().equals("")) {  sbFilter.append(" and unidad_admin = "); sbFilter.append(cds);}	
	if (sbFilter.length() > 0) sbFilter.replace(0, 4, " where");
	sbSql = new StringBuffer();
	sbSql.append("select codigo, descripcion, compania, estado_habitacion as estado,(select descripcion from tbl_cds_centro_servicio where codigo =unidad_admin) descCds from tbl_sal_habitacion ");
	sbSql.append(sbFilter);
	sbSql.append(" order by unidad_admin, descripcion");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_sal_habitacion"+sbFilter);


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
document.title = 'Almacén - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE HABITACION"></jsp:param>
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
<%=fb.hidden("fg",fg)%>
			<td width="50%">
				<cellbytelabel>Sala o Secci&oacute;n</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select distinct a.codigo, a.descripcion, a.codigo from tbl_cds_centro_servicio a, tbl_sal_habitacion b where a.codigo=b.unidad_admin and a.flag_cds in ('SOP','HEM','ENDO') and b.quirofano =2  order by a.codigo","cds",cds,"T")%>
				<cellbytelabel id="2">C&oacute;digo</cellbytelabel>
				<%=fb.textBox("codigo",codigo,false,false,false,30)%>
			</td>
			<td width="30%">
				<cellbytelabel id="3">Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion",descripcion,false,false,false,30)%>
			</td>
			<td width="20%">&nbsp;</td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("fg",fg)%>
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

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="20%">C&oacute;digo</td>
			<td width="35%">Descripci&oacute;n</td>
			<td width="35%">Centro de Servicio</td>
			<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todos los almacenes listados!")%></td>
		</tr>
<%
String displayComp = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	boolean checked = false;
	if (vQx.contains(cdo.getColValue("codigo"))) checked = true; 
	
	%> 
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		<%=fb.hidden("descCds"+i,cdo.getColValue("descCds"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("descCds")%></td>
			<td align="center"><%=(checked)?"Elegido":fb.checkbox("check"+i,cdo.getColValue("codigo"),false,false)%></td>
		</tr>
<%
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
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	int lineNo = 0;
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.addColValue("compania",(String)session.getAttribute("_companyId")); 
			cdo.addColValue("habitacion",request.getParameter("codigo"+i));
			cdo.addColValue("hab_desc",request.getParameter("descripcion"+i));
			cdo.addColValue("centro",request.getParameter("descCds"+i));
 			cdo.setAction("I"); 

			try
			{
				 
					cdo.setKey(iQx.size()+1);
					iQx.put(cdo.getKey(), cdo);
					vQx.add(cdo.getColValue("habitacion"));
				
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}
	 
	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&id="+id+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fg="+fg+"&fp="+fp+"&mode="+mode+"&id="+id+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&compania="+request.getParameter("compania")+"&codigo="+request.getParameter("codigo")+"&descripcion="+request.getParameter("descripcion"));
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
	window.opener.location = '../admin/reg_user.jsp?change=1&tab=9&mode=<%=mode%>&id=<%=id%>';
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