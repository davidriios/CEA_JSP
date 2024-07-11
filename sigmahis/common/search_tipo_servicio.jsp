<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="vCob" scope="session" class="java.util.Vector" />
<jsp:useBean id="vExcl" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500029") || SecMgr.checkAccess(session.getId(),"500030") || SecMgr.checkAccess(session.getId(),"500031") || SecMgr.checkAccess(session.getId(),"500032"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
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
String index = request.getParameter("index");
String centro = request.getParameter("centro");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (index == null) throw new Exception("El Indice no es válido. Por favor intente nuevamente!");

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
  String descripcion="",codigo ="";

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    if(fp!= null && !fp.trim().equals("notas"))
		appendFilter += "where and  upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
		else 		appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    if(fp!= null && !fp.trim().equals("notas")){
		if(appendFilter!= null && !appendFilter.trim().equals(""))appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		else appendFilter += " where upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";}
		else  appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	    descripcion = request.getParameter("descripcion");
  }


  if (fp.equalsIgnoreCase("convenio_cobertura") || fp.equalsIgnoreCase("pm_convenio_cobertura")  || fp.equalsIgnoreCase("convenio_exclusion") ||fp.equalsIgnoreCase("pm_convenio_exclusion") || fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
		String v = "";
		if ( (fp.equalsIgnoreCase("convenio_cobertura") || fp.equalsIgnoreCase("pm_convenio_cobertura")) && vCob.size() > 0)
		{
			v = vCob.toString().replaceAll(", ","','").replaceAll(",\'\'","");
			v = "'"+v.substring(1,v.length() - 1)+"'";
			v = v.replaceAll("T","");
			 if(appendFilter!= null && !appendFilter.trim().equals("")) appendFilter += " and codigo not in ("+v+")";
			 else appendFilter += " where codigo not in ("+v+")";
		}
		else if ( (fp.equalsIgnoreCase("convenio_exclusion") || fp.equalsIgnoreCase("pm_convenio_exclusion")) && vExcl.size() > 0)
		{
			v = vExcl.toString().replaceAll(", ","','").replaceAll(",''","");
			v = "'"+v.substring(1,v.length() - 1)+"'";
			v = v.replaceAll("T","");
			if(appendFilter!= null && !appendFilter.trim().equals(""))appendFilter += " and codigo not in ("+v+")";
			else appendFilter += " where codigo not in ("+v+")";
		}
		sql = "select codigo, descripcion from tbl_cds_tipo_servicio"+appendFilter+" order by descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	}
  else if (fp.equalsIgnoreCase("notas") || fp.equalsIgnoreCase("ajuste_cargoDev"))
	{
		sql = "select a.codigo as codigo, a.descripcion as descripcion  from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo=b.tipo_servicio and b.centro_servicio="+centro+" "+appendFilter+" order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Convenio - '+document.title;

function returnValue(k)
{
	var id = eval('document.form1.codigo'+k).value;
	var descripcion = eval('document.form1.descripcion'+k).value;
<%
if (fp.equalsIgnoreCase("convenio_cobertura") || fp.equalsIgnoreCase("pm_convenio_cobertura"))
{
%>
	window.opener.document.form0.tipoServicio<%=index%>.value = id;
	window.opener.document.form0.centroServicio<%=index%>.value = '';
	window.opener.document.form0.codigo<%=index%>.value = id;
	window.opener.document.form0.descripcion<%=index%>.value = descripcion;
	window.opener.document.form0.tipoCobertura<%=index%>.value = 'T';
	window.opener.doSubmit(0,'');
	window.close();
<%
}
else if (fp.equalsIgnoreCase("convenio_exclusion") || fp.equalsIgnoreCase("pm_convenio_exclusion"))
{
%>
	window.opener.document.form1.tipoServicio<%=index%>.value = id;
	window.opener.document.form1.centroServicio<%=index%>.value = '';
	window.opener.document.form1.codigo<%=index%>.value = id;
	window.opener.document.form1.descripcion<%=index%>.value = descripcion;
	window.opener.document.form1.tipoExclusion<%=index%>.value = 'T';
	window.opener.doSubmit(1,'');
	window.close();
<%
}
else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
{
%>
	window.opener.document.form0.tipoServicio<%=index%>.value = id;
	window.opener.document.form0.centroServicio<%=index%>.value = '';
	window.opener.document.form0.codigo<%=index%>.value = id;
	window.opener.document.form0.descripcion<%=index%>.value = descripcion;
	window.opener.document.form0.tipoCobertura<%=index%>.value = 'T';
	window.opener.doSubmit(0,'');
	window.close();

<%
}
else if (fp.equalsIgnoreCase("notas"))
{
%>
	window.opener.document.form1.tipoServicio<%=index%>.value = id;
	window.opener.document.form1.nameServicio<%=index%>.value = descripcion;
	window.close();

<%
}
else if (fp.equalsIgnoreCase("ajuste_cargoDev"))
{
%>
	window.opener.document.form1.tipoServicio<%=index%>.value = id;
	window.opener.document.form1.nServicio<%=index%>.value = descripcion;
	window.close();

<%
}

%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE TIPO DE SERVICIO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("centro",centro)%>
					<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
<%=fb.formEnd()%>

<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("centro",centro)%>
					<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
<%=fb.formEnd()%>
			    </tr>
			</table>
		</td>
	</tr>

</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("centro",centro)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
					%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("centro",centro)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
				<tr class="TextHeader" align="center">
					<td width="30%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="70%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
				</tr>
<%
}
%>
<%=fb.formEnd(true)%>
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
					<%
					fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("centro",centro)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("centro",centro)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
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