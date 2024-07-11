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
<%
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);%><%
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100031") || SecMgr.checkAccess(session.getId(),"100032") || SecMgr.checkAccess(session.getId(),"100033") || SecMgr.checkAccess(session.getId(),"100034"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String indexCode = request.getParameter("indexCode");
String indexName = request.getParameter("indexName");
String index = request.getParameter("index");
String cds = request.getParameter("cds");

if (id == null) throw new Exception("El Id no es válido. Por favor intente nuevamente!");

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
	String codigo ="",descripcion="";
	
	if (request.getParameter("code") != null && !request.getParameter("code").trim().equals(""))
	{   
	    if(id !="6") if (appendFilter.trim().equals("")) appendFilter = "WHERE ";
		else appendFilter += " and ";
		appendFilter += "  upper(codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";
	    codigo = request.getParameter("code");
	}
	if (request.getParameter("name") != null && !request.getParameter("name").trim().equals(""))
	{
	    if(id !="6")if (appendFilter.trim().equals("")) appendFilter = " WHERE ";
		else appendFilter += " and ";
		appendFilter += "  upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
    	descripcion = request.getParameter("name");
	}
	
	sql = "select a.codigo as code, a.descripcion as name from tbl_cds_tipo_servicio a "+appendFilter+" order by a.descripcion";
	if(id.trim().equals("6"))sql="select a.descripcion name,a.codigo code from tbl_cds_tipo_servicio a,tbl_cds_servicios_x_centros b where a.codigo = b.tipo_servicio and   b.centro_servicio = "+cds+" order by 1 ";


	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Administraci&oacute;n - '+document.title;
function setValue(id,code,name,indexCode,indexName,index)
{
   switch(id)
   {
     case 1:
	   window.opener.document.form1.tipoServCode.value = code;
	   window.opener.document.form1.tipoServ.value = name;
	   window.close();
	 break;
	 
	 case 2:
	   window.opener.document.form1.tipoServCode.value = code;
	   window.opener.document.form1.tipoServ.value = name;
	   window.close();
	 break;  
	 
	 case 3:
	   window.opener.document.form1.tipoServCode.value = code;
	   window.opener.document.form1.tipoServ.value = name;
	   window.close();
	 break;
	 
	 case 4:  //Revisar este case ya que no se encuentra en ninguna pagina que lo llama.
	   eval('window.opener.document.formDetalle.'+indexCode).value = code;
       eval('window.opener.document.formDetalle.'+indexName).value = name;
       window.close();
	 break; 
	 
	 case 5:
	   eval('window.opener.document.formDetalle.tipoServCode'+index).value = code;
       window.close();
	 break;  
	 
	 case 6:
	   eval('window.opener.document.formPuntos.tipoServicio'+index).value = code;
       window.close();
	 break; 
   }	   
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACIÓN - TIPO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("id",""+id)%>
				<%=fb.hidden("index",""+index)%>
				<td width="50%">
					<cellbytelabel id="1">C&oacute;digo</cellbytelabel>
					<%=fb.textBox("code","",false,false,false,30)%>
				</td>
				<td width="50%">
					<cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("name","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

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
				<%=fb.hidden("id",""+id)%>
				<%=fb.hidden("index",""+index)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			    <td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
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
				<%=fb.hidden("id",""+id)%>
				<%=fb.hidden("index",""+index)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
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

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
	    <td width="10%">&nbsp;</td>
		<td width="30%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
		<td width="60%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setValue(<%=id%>,'<%=cdo.getColValue("code")%>','<%=cdo.getColValue("name")%>','<%=indexCode%>','<%=indexName%>',<%=index%>)" style="cursor:pointer">
			<td align="right"><%=preVal + i%>&nbsp;</td>
			<td><%=cdo.getColValue("code")%></td>
			<td><%=cdo.getColValue("name")%></td>			
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
				<%=fb.hidden("id",""+id)%>
				<%=fb.hidden("index",""+index)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel id="3">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			    <td width="40%" align="right"><cellbytelabel id="4">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("id",""+id)%>
				<%=fb.hidden("index",""+index)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
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