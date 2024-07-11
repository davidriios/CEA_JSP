<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
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
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String id = (request.getParameter("id")==null?"":request.getParameter("id"));
String primerNombre = (request.getParameter("primerNombre")==null?"":request.getParameter("primerNombre"));
String primerApellido = (request.getParameter("primerApellido")==null?"":request.getParameter("primerApellido"));
String index = (request.getParameter("index")==null?"":request.getParameter("index"));

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");

if (!id.equals("")) appendFilter += " and id="+id+"";
if (!primerNombre.equals("")) appendFilter += " and primer_nombre like '%"+primerNombre+"%'";
if (!primerApellido.equals("")) appendFilter += " and primer_apellido like '%"+primerApellido+"%'";

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

	if (fp.equalsIgnoreCase("escort"))
	{
		sql = "select e.id, e.primer_nombre, e.primer_apellido, e.provincia,e.sigla,e.tomo,e.asiento, e.sexo ,decode(e.estado_civil,'ST','SOLTER','CS','CASAD','DV','DIVORCIAD','UN','UNID','SP','SEPARAD','VD','VIUD')||decode(e.sexo,'M','O','A') marital_status, e.pasaporte,e.emp_id,e.usuario_creacion,e.fecha_creacion, e.fecha_modificacion, decode(e.estado,'I','INACTIVO','ACTIVO') status,  coalesce(e.pasaporte,decode (e.provincia, 0, '', 00, '', e.provincia)|| decode (e.sigla, '00', '', '0', '', e.sigla)|| '-'|| e.tomo|| '-'|| e.asiento) identification, primer_nombre||' '||segundo_nombre||' '||primer_apellido||' '||segundo_apellido||' ['||e.id||'] ['|| coalesce(e.pasaporte,decode (e.provincia, 0, '', 00, '', e.provincia)|| decode (e.sigla, '00', '', '0', '', e.sigla)|| '-'|| e.tomo|| '-'|| e.asiento)||']' escInfo from tbl_esc_escolta e where e.estado != 'I' and e.id not in ( (select escolta_id from tbl_esc_sol_escolta where estado in('E') and sub_estado != 'LIBESC' ) ) "+appendFilter+" order by 1";

		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  		rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_esc_escolta where estado in('P','E') "+appendFilter);
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

function setEscort(k)
{
<%
	if (fp.equalsIgnoreCase("escort"))
	{
		String escortId = "window.opener.document.form1.escortId"+index+".value";
		String escortInfo = "window.opener.document.form1.escInfo"+index+".value";
%>
	<%=escortId%> = eval('document.frm.escort'+k).value;
	<%=escortInfo%> = eval('document.frm.escortInfo'+k).value;
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
			<%=fb.hidden("index",index)%>
			<td colspan="2">
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="20%">
				<cellbytelabel>C&oacute;digo</cellbytelabel>
				<%=fb.textBox("id",id,false,false,false,10)%>
			</td>
			<td width="40%">
				<cellbytelabel>Primer Nombre</cellbytelabel>
				<%=fb.textBox("primerNombre",primerNombre,false,false,false,40)%>
			</td><td width="40%">
				<cellbytelabel>Primer Apellido</cellbytelabel>
				<%=fb.textBox("primerApellido","",false,false,false,40)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
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
		<tr class="TextHeader">
			<td width="10%" align="center"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Primer Nombre</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Primer Apellido</cellbytelabel></td>
			<td width="20%" align="center"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
		</tr>
<%fb = new FormBean("frm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%
	for (int i=0; i<al.size(); i++){

	  CommonDataObject cdo = (CommonDataObject) al.get(i);
	  String color = "TextRow02";
	  if (i % 2 == 0) color = "TextRow01";
	  %>
	  <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setEscort(<%=i%>)" style="cursor:pointer">
		<td align="center"><%=cdo.getColValue("id")%></td>
		<td><%=cdo.getColValue("primer_nombre")%></td>
		<td><%=cdo.getColValue("primer_apellido")%></td>
		<td align="center"><%=cdo.getColValue("identification")%></td>
		<%=fb.hidden("primerNombre"+i,cdo.getColValue("primer_nombre"))%>
		<%=fb.hidden("primerApellido"+i,cdo.getColValue("primer_apellido"))%>
		<%=fb.hidden("escort"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("escortInfo"+i,cdo.getColValue("escInfo"))%>
	 </tr>
<%}%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
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