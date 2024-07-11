<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.CitaPersonal"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htPersonal" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htPersonalKey" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
 
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String codigo = request.getParameter("codigo_precio");
String descripcion = request.getParameter("descripcion");
String id_clasif = request.getParameter("id_clasif");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if (codigo == null) codigo = "";
if (descripcion == null) descripcion = "";
if(fg==null) fg = "";
if (index==null) index= "";
if (id_clasif==null) id_clasif= "";

StringBuffer sbSql = new StringBuffer();

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
    
    if (fp.equalsIgnoreCase("liq_recl")){
      sbSql.append("select l.id, l.codigo_precio, l.precio, l.descripcion from tbl_pm_lista_precios l where l.estado = 'A' ");
      
      if (!codigo.trim().equals("")) {
         sbSql.append(" and l.codigo_precio = '");
         sbSql.append(codigo);
         sbSql.append("'");
      }
      
      if (!descripcion.trim().equals("")) {
         sbSql.append(" and l.descripcion like '%");
         sbSql.append(descripcion);
         sbSql.append("%'");
      } 
			if(!id_clasif.equals("")){
				sbSql.append(" and id_clasif = ");
				sbSql.append(id_clasif);
			}
		}
		

	if (sbSql != null){
        al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
        rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Plan Médico - '+document.title;

function setValues(k)
{
    <%if (fp.equalsIgnoreCase("liq_recl")){%>
       if ($("#cantidad<%=index%>", window.opener.document).length) $("#cantidad<%=index%>", window.opener.document).val("1");
       if ($("#codigo_precio<%=index%>", window.opener.document).length) $("#codigo_precio<%=index%>", window.opener.document).val($("#codigo_precio"+k).val());
       if ($("#descripcion<%=index%>", window.opener.document).length) $("#descripcion<%=index%>", window.opener.document).val($("#descripcion"+k).val());
       if ($("#monto<%=index%>", window.opener.document).length) {
            $("#monto<%=index%>", window.opener.document).val($("#precio"+k).val());
            $("#monto_bk<%=index%>", window.opener.document).val($("#precio"+k).val());
            if ($("#codigo_precio"+k).val()=="-01") $("#monto<%=index%>", window.opener.document).val("").prop("readonly",false);
       }
       
       if ($("#cantidad<%=index%>", window.opener.document).length && ($("#codigo_precio"+k).val()=="-02"||$("#codigo_precio"+k).val()=="-07")) {
          $("#cantidad<%=index%>", window.opener.document).val("").prop("readonly",false);
       }
       
       if(window.opener.setXtra){window.opener.$("#desc_aplicado").val('N');window.opener.setXtra()}
       
	<%}%>    
    window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE LISTA DE PRECIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
        <%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
        <%=fb.formStart()%>
        <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("fp",fp)%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("index",index)%>
		<tr class="TextFilter">
			<td width="30%">
				<cellbytelabel id="4">C&oacute;digo Precio</cellbytelabel>
				<%=fb.textBox("codigo_precio",codigo,false,false,false,15,"Text10",null,null)%>
			</td>
			<td width="30%">
				<cellbytelabel id="4">Clasificaci&oacute;n</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select id as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pm_clasif_lista_precio order by codigo","id_clasif",id_clasif,false,false,0,"Text10",null,null,"","T")%>
			</td>
			<td width="70%">
				<cellbytelabel id="5">Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion",descripcion,false,false,false,40,"Text10",null,null)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
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
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("index",index)%>
        <%=fb.hidden("codigo",codigo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("id_clasif",id_clasif)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("index",index)%>
        <%=fb.hidden("codigo",codigo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("id_clasif",id_clasif)%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
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
<%fb = new FormBean("lista","", "post","");%>
<%=fb.formStart()%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
<tr class="TextHeader" align="center">
    <td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
    <td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
    <td width="20%"><cellbytelabel>Precio</cellbytelabel></td>
</tr>

<%for (int i=0; i<al.size(); i++){
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
		<%=fb.hidden("codigo_precio"+i,cdo.getColValue("codigo_precio"))%>
		<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
		
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setValues(<%=i%>)" style="text-decoration:none; cursor:pointer">
			<td><%=cdo.getColValue("codigo_precio")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("precio")%></td>
		</tr>
<%}%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
		</table>
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
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("index",index)%>
        <%=fb.hidden("codigo",codigo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("id_clasif",id_clasif)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("fp",fp)%>
        <%=fb.hidden("fg",fg)%>
        <%=fb.hidden("index",index)%>
        <%=fb.hidden("codigo",codigo)%>
        <%=fb.hidden("descripcion",descripcion)%>
        <%=fb.hidden("id_clasif",id_clasif)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%
}
else
{
%>
<html>
<head>
<script>
function closeWindow()
{
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>