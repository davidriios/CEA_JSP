<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================
==============================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
String cant = request.getParameter("cant");
String rata = request.getParameter("rata");

if (fp == null) throw new Exception("La Localizaci�n Origen no es v�lida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage=100;
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
  String codigo="",descripcion="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  

	if (fp.equalsIgnoreCase("planilla") || fp.equalsIgnoreCase("extra")|| fp.equalsIgnoreCase("autorizaTrx"))
	{
		sql = "SELECT codigo, descripcion, factor_multi as factor from tbl_pla_t_horas_ext where codigo >0 "+appendFilter; 
		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");
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
document.title = 'TIPOS DE HORAS EXTRAS - '+document.title;

function setTurno(i)
{
var cantidad = 0.00;
var rath = 0.00;
var fact = 0.00;
var monto = 0.00;
<%if (fp.equalsIgnoreCase("planilla")){%>
	rath     = eval('document.formPlanilla.rata'+i).value;
	cantidad = eval('document.formPlanilla.cant'+i).value;
	fact  	 = eval("document.formPlanilla.factor"+i).value;
	window.opener.document.formSobretiempo.tipoext<%=index%>.value = eval('document.formPlanilla.codigo'+i).value;
	window.opener.document.formSobretiempo.tipoextDesc<%=index%>.value = eval('document.formPlanilla.descripcion'+i).value;
	window.opener.document.formSobretiempo.factor<%=index%>.value = eval('document.formPlanilla.factor'+i).value;
	window.opener.document.formSobretiempo.monto<%=index%>.value = rath * cantidad * fact;
<%}else if (fp.equalsIgnoreCase("cambios_empleado")){%>	  
    window.opener.document.formCambio.codTurno.value = eval('document.formPlanilla.codigo'+i).value;
	window.opener.document.formCambio.turnoDesc.value = eval('document.formPlanilla.descripcion'+i).value;
<%}else if (fp.equalsIgnoreCase("extra")){%>
	rath     = eval('document.formPlanilla.rata'+i).value;
	cantidad = eval('document.formPlanilla.cant'+i).value;
	fact  	 = eval("document.formPlanilla.factor"+i).value;
	window.opener.document.form1.the_codigo<%=index%>.value = eval('document.formPlanilla.codigo'+i).value;
	window.opener.document.form1.tipoextDesc<%=index%>.value = eval('document.formPlanilla.descripcion'+i).value;
	window.opener.document.form1.factor<%=index%>.value = eval('document.formPlanilla.factor'+i).value;
	window.opener.chkValue('tc',<%=index%>);
<%}else if (fp.equalsIgnoreCase("autorizaTrx")){%>	  
    window.opener.document.form0.tipoTrx.value = eval('document.formPlanilla.codigo'+i).value;
	window.opener.document.form0.nombreTrx.value = eval('document.formPlanilla.descripcion'+i).value;
<%}%>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE HORAS EXTRAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">		
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
				    <%=fb.hidden("cant",cant)%>
				    <%=fb.hidden("rata",rata)%>
					<td width="50%"><cellbytelabel>C&oacute;digo</cellbytelabel>					
					<%=fb.textBox("codigo","",false,false,false,40)%>
					</td>
					<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
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
					<%=fb.hidden("index",index)%>
				    <%=fb.hidden("cant",cant)%>
				    <%=fb.hidden("rata",rata)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("index",index)%>
          			<%=fb.hidden("cant",cant)%>
           			<%=fb.hidden("rata",rata)%>
		 			<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
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

			<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="expe">
				<tr class="TextHeader" align="center">
					<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="80%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				</tr>
				<%fb = new FormBean("formPlanilla",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("factor"+i,cdo.getColValue("factor"))%>
				<%=fb.hidden("cant"+i,cant)%>
				<%=fb.hidden("rata"+i,rata)%>
        
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setTurno(<%=i%>)" style="cursor:pointer">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
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
           			<%=fb.hidden("cant",cant)%>
          			<%=fb.hidden("rata",rata)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("index",index)%>
           			<%=fb.hidden("cant",cant)%>
          			<%=fb.hidden("rata",rata)%>
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
	