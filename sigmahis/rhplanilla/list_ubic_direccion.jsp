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
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = " where nivel>=0 and nivel<4";
String fp = request.getParameter("fp");
String[] lvlColor = {"TextRow01","TextRow02","TextRow03","TextRow04","TextRow05"};
String[] lvlType = {"Pais","Provincia","Distrito","Corregimiento"};
String lvl = request.getParameter("lvl");
String name = request.getParameter("name");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (lvl == null) lvl = "";
if (!lvl.equals("")) appendFilter = " where nivel="+lvl;
if (name == null) name = "";
if (appendFilter.length() == 0) appendFilter += " where upper(nivel_nombre) like '%"+name+"%'";
else if (!name.equals("")) appendFilter += " and upper(nivel_nombre) like '%"+name+"%'";

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

	if (fp.equalsIgnoreCase("empleDir"))
	{
		sql = "select codigo_pais, decode(nombre_pais,'NA',' ',nombre_pais) as nombre_pais, codigo_provincia, decode(nombre_provincia,'NA',' ',nombre_provincia) as nombre_provincia, codigo_distrito, decode(nombre_distrito,'NA',' ',nombre_distrito) as nombre_distrito, codigo_corregimiento, decode(nombre_corregimiento,'NA',' ',nombre_corregimiento) as nombre_corregimiento, nivel, nivel_codigo, nivel_nombre from vw_sec_regional_location"+appendFilter+" order by decode(nombre_pais,'NA',' ',nombre_pais), decode(nombre_provincia,'NA',' ',nombre_provincia), decode(nombre_distrito,'NA',' ',nombre_distrito), decode(nombre_corregimiento,'NA',' ',nombre_corregimiento)";   
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from vw_sec_regional_location"+appendFilter);
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
document.title = 'Dirección de Ubicación - '+document.title;

function setUbicacion(k)
{ 
<%
	if (fp.equalsIgnoreCase("empleDir"))
	{
%>
	window.opener.document.form0.paisCode.value = eval('document.ubicacion.paisCodigo'+k).value;
	window.opener.document.form0.paisName.value = eval('document.ubicacion.paisNombre'+k).value;
	window.opener.document.form0.provinciaCode.value = eval('document.ubicacion.provinciaCodigo'+k).value;
	window.opener.document.form0.provinciaName.value = eval('document.ubicacion.provinciaNombre'+k).value;
	window.opener.document.form0.distritoCode.value = eval('document.ubicacion.distritoCodigo'+k).value;
	window.opener.document.form0.distritoName.value = eval('document.ubicacion.distritoNombre'+k).value;
	window.opener.document.form0.corregimientoCode.value = eval('document.ubicacion.corregimientoCodigo'+k).value;
	window.opener.document.form0.corregimientoName.value = eval('document.ubicacion.corregimientoNombre'+k).value; 
<%
}
%>

	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCIONE DE UBICACION GEOGRAFICA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">    
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
			    <tr class="TextFilter">		
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>
				    <%=fb.formStart()%>
						<%=fb.hidden("fp",fp)%>
				    <td width="100%">
						<%=fb.select("lvl","0=PAIS,1=PROVINCIA,2=DISTRITO,3=CORREGIMIENTO",lvl,"T")%>
						Localizaci&oacute;n<%=fb.textBox("name","",false,false,false,45)%>
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
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("lvl",lvl)%>
					<%=fb.hidden("name",name)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("lvl",lvl)%>
					<%=fb.hidden("name",name)%>
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
	        <table align="center" width="100%" cellpadding="0" cellspacing="1">
			
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->	
			
				<tr class="TextHeader" align="center">
					<td width="25%">Pa&iacute;s</td>
					<td width="25%">Provincia</td>
					<td width="25%">Distrito</td>
					<td width="25%">Corregimiento</td>
				</tr>
<%
fb = new FormBean("ubicacion",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart()%>
<%
String pais = "";
String prov = "";
String dist = "";
String corr = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	int l = Integer.parseInt(cdo.getColValue("nivel"));
	String color = lvlColor[l];
%>
<%=fb.hidden("paisCodigo"+i,(cdo.getColValue("codigo_pais").equals("0"))?"":cdo.getColValue("codigo_pais"))%>
<%=fb.hidden("paisNombre"+i,cdo.getColValue("nombre_pais"))%>
<%=fb.hidden("provinciaCodigo"+i,(cdo.getColValue("codigo_provincia").equals("0"))?"":cdo.getColValue("codigo_provincia"))%>
<%=fb.hidden("provinciaNombre"+i,cdo.getColValue("nombre_provincia"))%>
<%=fb.hidden("distritoCodigo"+i,(cdo.getColValue("codigo_distrito").equals("0"))?"":cdo.getColValue("codigo_distrito"))%>
<%=fb.hidden("distritoNombre"+i,cdo.getColValue("nombre_distrito"))%>
<%=fb.hidden("corregimientoCodigo"+i,(cdo.getColValue("codigo_corregimiento").equals("0"))?"":cdo.getColValue("codigo_corregimiento"))%>
<%=fb.hidden("corregimientoNombre"+i,cdo.getColValue("nombre_corregimiento"))%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setUbicacion(<%=i%>)" style="cursor:pointer">
					<td><%=(!cdo.getColValue("nombre_pais").equalsIgnoreCase(pais))?cdo.getColValue("nombre_pais"):""%></td>
					<td><%=(!cdo.getColValue("nombre_provincia").equalsIgnoreCase(prov))?cdo.getColValue("nombre_provincia"):""%></td>
					<td><%=(!cdo.getColValue("nombre_distrito").equalsIgnoreCase(dist))?cdo.getColValue("nombre_distrito"):""%></td>
					<td><%=(!cdo.getColValue("nombre_corregimiento").equalsIgnoreCase(corr))?cdo.getColValue("nombre_corregimiento"):""%></td>		
				</tr>
<%
	pais = cdo.getColValue("nombre_pais");
	prov = cdo.getColValue("nombre_provincia");
	dist = cdo.getColValue("nombre_distrito");
	corr = cdo.getColValue("nombre_corregimiento");
}
%>							
<%=fb.formEnd()%>						
			
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
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
fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("lvl",lvl)%>
					<%=fb.hidden("name",name)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%
fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());
%>
					<%=fb.formStart()%>
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
					<%=fb.hidden("lvl",lvl)%>
					<%=fb.hidden("name",name)%>
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