<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500025") || SecMgr.checkAccess(session.getId(),"500026") || SecMgr.checkAccess(session.getId(),"500027") || SecMgr.checkAccess(session.getId(),"500028"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

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
	
	String codigo  = "";           // variables para mantener el valor de los campos filtrados en la consulta
	String descrip = "",edad="",estado="";

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo     = request.getParameter("codigo");     // utilizada para mantener el C�digo filtrado
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip    = request.getParameter("descripcion");    // utilizada para mantener la Descripci�n filtrada
  }
  if (request.getParameter("edad") != null && !request.getParameter("edad").trim().equals(""))
  {
    appendFilter += " and edad = "+request.getParameter("edad").toUpperCase()+"";
	edad    = request.getParameter("edad");    // utilizada para mantener la Descripci�n filtrada
  }
  if (request.getParameter("estado") != null && !request.getParameter("estado").trim().equals(""))
  {
    appendFilter += " and estado = '"+request.getParameter("estado").toUpperCase()+"'";
	estado    = request.getParameter("estado");    // utilizada para mantener la Descripci�n filtrada
  }

  sql = "SELECT codigo, descripcion,decode(edad,1,'2 MESES',2,'4 MESES',3,'6 MESES',4,'9 MESES',5,'12 MESES',6,'18 MESES',7,'2 A�OS',8,'3 A�OS',9,'5 A�OS',10,'OTRAS') descEdad,decode(estado,'A','ACTIVA','I','INACTIVA') estado FROM tbl_sal_crecimiento_desarrollo WHERE codigo<>0"+appendFilter+" order by codigo";
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

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
document.title = 'Posibles Factores de Desarrollo y Crecimiento - '+document.title;

function add()
{
	abrir_ventana('factorcrecimiento_config.jsp');
}

function edit(code)
{
	abrir_ventana('factorcrecimiento_config.jsp?mode=edit&code='+code);
}

function printList()
{
	abrir_ventana('print_list_factorcrecimiento.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right">
	       <authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Factor Crecimiento</cellbytelabel> ]</a></authtype>
	    </td>
    </tr>
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
				    <td width="15%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel>
						<%=fb.textBox("codigo",codigo,false,false,false,10)%>
					</td>
				    <td width="45%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("descripcion",descrip,false,false,false,40)%>
					</td>
					<td width="20%"><cellbytelabel id="4">Edad</cellbytelabel>
						<%=fb.select("edad","1=2 MESES,2=4 MESES,3=6 MESES,4=9 MESES,5=12 MESES,6=18 MESES,7=2 A�OS,8=3 A�OS,9=5 A�OS,10=OTRAS",edad,false,false,0,"S")%>
					</td>
					<td width="20%"><cellbytelabel id="5">Estado</cellbytelabel>
						<%=fb.select("estado","A=ACTIVA,I=INACTIVA",estado,false,false,0,"S")%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		      <authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="6">Imprimir Lista</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("descrip",""+descrip)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("edad",""+edad)%>
				<%=fb.hidden("estado",""+estado)%>
				
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("descrip",""+descrip)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("edad",""+edad)%>
					<%=fb.hidden("estado",""+estado)%>
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
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
				<tr class="TextHeader">
					<td width="15%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="3">Edad</cellbytelabel></td>
					<td width="50%"><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel id="5">Estado</cellbytelabel></td>
					<td width="10%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descEdad")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("estado")%></td>
					<td align="center">
						<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="10">Editar</cellbytelabel></a></authtype>
					</td>
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
				<%=fb.hidden("descrip",""+descrip)%>
				<%=fb.hidden("codigo",""+codigo)%>
				<%=fb.hidden("edad",""+edad)%>
				<%=fb.hidden("estado",""+estado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("descrip",""+descrip)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("edad",""+edad)%>
					<%=fb.hidden("estado",""+estado)%>
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