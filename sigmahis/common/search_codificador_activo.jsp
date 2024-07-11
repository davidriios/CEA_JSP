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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

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
String filter = "",filter1 = "";
String index = request.getParameter("index");
String id = "";
String fp =  request.getParameter("fp");
String fg =  request.getParameter("fg");

String codigo ="",desc ="";

if(fg == null )      fg = "RAC";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (request.getParameter("index") != null) index = request.getParameter("index");
  
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

	if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "a.descripcion";
	  codigo = request.getParameter("codigo");
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Descipcion Activo";
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {    
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	desc = request.getParameter("descripcion");
    searchOn = "b.descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
  }
  
			
			sql="select a.descripcion descripcion1, a.cod_espec cuentah_activo, a.codigo_subesp cuentah_espec, a.codigo_detalle cuentah_detalle, a.cod_clasif cod_hacienda, b.descripcion descripcion2 from tbl_con_detalle a, tbl_con_clasif_hacienda b where a.cod_compania = "+(String) session.getAttribute("_companyId")+" and b.cod_clasif = a.cod_clasif";
						
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM (" +sql+")");


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
document.title = 'Listado de Codificador de Activos - '+document.title;

function returnValue(k)
{ 
  	window.opener.document.form1.cuentah_activo.value = eval('document.form1.cuentah_activo'+k).value;
		window.opener.document.form1.cuentah_espec.value = eval('document.form1.cuentah_espec'+k).value;
		window.opener.document.form1.cuentah_detalle.value = eval('document.form1.cuentah_detalle'+k).value;
		window.opener.document.form1.cuentah_desc.value = eval('document.form1.descripcion1'+k).value;
		window.opener.document.form1.cod_clasif.value = eval('document.form1.cod_hacienda'+k).value;
		window.opener.document.form1.clasif_desc.value = eval('document.form1.descripcion2'+k).value;

	 window.close(); 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - LISTADO DE CODIFICADOR DE ACTIVOS "></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			                       
					<%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
				   <tr class="TextFilter">	 
				    <td width="50%"><cellbytelabel>Nombre de Codificador</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,40)%>
					
					</td>
					
				<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion",desc,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
				  
			    </tr>
				  <%=fb.formEnd()%>		
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
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("filter",filter)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("fg",fg)%>
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
					<td width="5%">&nbsp;</td>
					<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Cuenta Activo</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Cuenta Espec</cellbytelabel>.</td>
					<td width="10%"><cellbytelabel>Cuenta Detalle</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Cuenta Hacienda</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				
				<%=fb.hidden("descripcion1"+i,cdo.getColValue("descripcion1"))%>
				<%=fb.hidden("cuentah_activo"+i,cdo.getColValue("cuentah_activo"))%>
				<%=fb.hidden("cuentah_espec"+i,cdo.getColValue("cuentah_espec"))%>
				<%=fb.hidden("cuentah_detalle"+i,cdo.getColValue("cuentah_detalle"))%>
				<%=fb.hidden("cod_hacienda"+i,cdo.getColValue("cod_hacienda"))%>
				<%=fb.hidden("descripcion2"+i,cdo.getColValue("descripcion2"))%>
			
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue(<%=i%>)" style="cursor:pointer"> 
				
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("descripcion1")%></td>
					<td align="center"><%=cdo.getColValue("cuentah_activo")%></td>
					<td align="center"><%=cdo.getColValue("cuentah_espec")%></td>		
					<td align="center"><%=cdo.getColValue("cuentah_detalle")%></td>
					<td align="center"><%=cdo.getColValue("cod_hacienda")%></td>
					<td><%=cdo.getColValue("descripcion2")%></td>			
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
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("filter",filter)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("filter",filter)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("fg",fg)%>
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