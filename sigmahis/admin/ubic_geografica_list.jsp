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
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
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
String appendFilter = "";
String[] lvlColor = {"TextRow01","TextRow02","TextRow03","TextRow04","TextRow05"};
String[] lvlType = {"Pais","Provincia","Distrito","Corregimiento","Comunidad"};
appendFilter = " where nivel>=0 and nivel<4";
String xLvl = "";
String fp = request.getParameter("fp");
String descripcion ="",seleccion = "";

if (fp == null) fp = "default";

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
  
 
  if (request.getParameter("seleccion") != null && !request.getParameter("seleccion").trim().equals(""))
  {
	if (!request.getParameter("seleccion").equals("-1")){ appendFilter += " and nivel="+request.getParameter("seleccion");
	seleccion=request.getParameter("seleccion");}
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
 	
	
	if (request.getParameter("seleccion") != null )
	{ 
		if (request.getParameter("seleccion").equals("0")||request.getParameter("seleccion").equals("-1"))appendFilter += " and upper(nombre_pais) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		else if (request.getParameter("seleccion").equals("1"))appendFilter += " and upper(nombre_provincia) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		else if (request.getParameter("seleccion").equals("2"))appendFilter += " and upper(nombre_distrito) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		else if (request.getParameter("seleccion").equals("3"))appendFilter += " and upper(nombre_corregimiento) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	
	}
	 
	
	descripcion = request.getParameter("descripcion");
  }

  sql = "SELECT CODIGO_PAIS, NOMBRE_PAIS, CODIGO_PROVINCIA, NOMBRE_PROVINCIA, CODIGO_DISTRITO, NOMBRE_DISTRITO, CODIGO_CORREGIMIENTO, NOMBRE_CORREGIMIENTO, nivel, nivel_codigo, nivel_nombre FROM vw_sec_regional_location"+appendFilter+" order by decode(nombre_pais,'NA',' '||nombre_pais,nombre_pais), decode(nombre_provincia,'NA',' '||nombre_provincia,nombre_provincia), decode(nombre_distrito,'NA',' '||nombre_distrito,nombre_distrito), decode(nombre_corregimiento,'NA',' '||nombre_corregimiento,nombre_corregimiento)";   
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
document.title = 'Ubicación Geográfica - '+document.title;

function add(paisCode, pais, provCode, provincia, distCode, distrito, corregiCode, corregimiento)
{ 
<%
if (fp.equalsIgnoreCase("unidadAdmin"))
{
%>
  window.opener.document.form1.pais.value = paisCode;
  window.opener.document.form1.paNombre.value = pais;
  window.opener.document.form1.provincia.value = provCode;
  window.opener.document.form1.pNombre.value = provincia;
  window.opener.document.form1.distrito.value = distCode;
  window.opener.document.form1.dNombre.value = distrito;
  window.opener.document.form1.corregimiento.value = corregiCode;
  window.opener.document.form1.cNombre.value = corregimiento;  
<%
}
else if (fp.equalsIgnoreCase("empleado"))
{
%>
  window.opener.document.form1.paisCode.value = paisCode;
  window.opener.document.form1.paisName.value = pais;
  window.opener.document.form1.provinciaCode.value = provCode;
  window.opener.document.form1.provinciaName.value = provincia;
  window.opener.document.form1.distritoCode.value = distCode;
  window.opener.document.form1.distritoName.value = distrito;
  window.opener.document.form1.corregimientoCode.value = corregiCode;
  window.opener.document.form1.corregimientoName.value = corregimiento; 
<%
}
else
{
%>
  window.opener.document.compania.paisCode.value = paisCode;
  window.opener.document.compania.pais.value = pais;
  if(provCode!='0')window.opener.document.compania.provCode.value = provCode;
  window.opener.document.compania.provincia.value = provincia;
  if(distCode!='0')window.opener.document.compania.distCode.value = distCode;
  window.opener.document.compania.distrito.value = distrito;
  if(corregiCode!='0')window.opener.document.compania.corregiCode.value = corregiCode;
  window.opener.document.compania.corregimiento.value = corregimiento;  
<%
}
%>
  window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="UBICACIÓN GEOGRÁFICA"></jsp:param>
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
				    <td width="100%">&nbsp;
					<%=fb.select("seleccion","-1=TODOS,0=PAIS,1=PROVINCIA,2=DISTRITO,3=CORREGIMIENTO",seleccion)%>&nbsp;&nbsp;
					Descripcion:<%=fb.textBox("descripcion",descripcion,false,false,false,45)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("seleccion",""+seleccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("seleccion",""+seleccion)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
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
			
				<tr class="TextHeader">
					<td width="5%">&nbsp;</td>
					<td width="15%"><cellbytelabel>Pa&iacute;s</cellbytelabel></td>
					<td width="15%"><cellbytelabel>Provincia</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Distrito</cellbytelabel></td>
					<td width="25%"><cellbytelabel>Corregimiento</cellbytelabel></td>
					<td width="10%">&nbsp;</td>					
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 int lvl = Integer.parseInt(cdo.getColValue("nivel"));
				 String color = lvlColor[lvl];
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td><%=(lvl == 0)?cdo.getColValue("nombre_pais"):""%></td>
					<td><%=(lvl == 1)?cdo.getColValue("nombre_provincia"):""%></td>
					<td><%=(lvl == 2)?cdo.getColValue("nombre_distrito"):""%></td>
					<td><%=(lvl == 3)?cdo.getColValue("nombre_corregimiento"):""%></td>					
					<td align="center">
					<a href="javascript:add('<%=cdo.getColValue("codigo_pais")%>','<%=cdo.getColValue("nombre_pais")%>','<%=cdo.getColValue("codigo_provincia")%>','<%=cdo.getColValue("nombre_provincia")%>','<%=cdo.getColValue("codigo_distrito")%>','<%=cdo.getColValue("nombre_distrito")%>','<%=cdo.getColValue("codigo_corregimiento")%>','<%=cdo.getColValue("nombre_corregimiento")%>')"	class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Seleccionar</cellbytelabel> <%=lvlType[lvl]%></a></td>					
				</tr>
				<%
				}
				%>							
			
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("seleccion",""+seleccion)%>
				<%=fb.hidden("descripcion",""+descripcion)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("seleccion",""+seleccion)%>
					<%=fb.hidden("descripcion",""+descripcion)%>
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
%>