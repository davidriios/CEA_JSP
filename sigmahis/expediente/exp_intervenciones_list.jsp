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

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(d.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "d.codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "C�digo";
  }
  else if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(d.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "d.descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripci�n";
  }  
   else if (request.getParameter("estatus") != null && !request.getParameter("estatus").equals(""))
  {
    appendFilter += " and upper(d.estado) like '%"+request.getParameter("estatus").toUpperCase()+"%'";
    searchOn = "d.estado";
    searchVal = request.getParameter("estatus");
    searchType = "1";
    searchDisp = "Estatus";
  }  
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
   if (searchType.equals("1"))
   {
     appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

  sql = "select h.codigo cod_header, d.codigo as cod_det, h.descripcion desc_header, d.descripcion desc_det, d.valorizacion, d.estado, decode(d.estado,'A','ACTIVO','I','INACTIVO') estado_desc, decode(d.valorizacion,'low','BAJO','medium','MEDIO','high','ALTO','extreme','EXTREMADO') valorizacion_desc from tbl_sal_intervencion_header h, tbl_sal_intervencion d where h.codigo = d.cod_interv "+appendFilter+" order by 1";

  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

  rowCount = al.size();

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
<script>
document.title = 'Tipos de Dietas - '+document.title;

function add()
{
	abrir_ventana('exp_intervenciones_config.jsp');
}

function edit(codIntev, codIntevDet)
{
	abrir_ventana('exp_intervenciones_config.jsp?mode=edit&cod_interv='+codIntev+'&cod_interv_det='+codIntevDet);
}

function printList()
{
	abrir_ventana('');
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
    <!--<tr>
        <td align="right">
        <authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Condici&oacute;n</cellbytelabel> ]</a></authtype>
	    </td>
    </tr>-->
    <tr>
        <td align="right">&nbsp;</td>
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
				    <td><cellbytelabel id="2">C&oacute;digo</cellbytelabel>
						<%=fb.textBox("codigo","",false,false,false,10)%>
					<cellbytelabel id="3">Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("descripcion","",false,false,false,40)%>
					<cellbytelabel id="4">Estatus</cellbytelabel>
                    
                    <%=fb.select("estatus","A=Activo,I=Inactivo","",false,false,0)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>	
				
				</tr>
				
			</table>
		</td>
	</tr>
    <!--<tr>
        <td align="right">
            <authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
        </td>
    </tr>-->
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
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
					<td width="5%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
					<td width="40%"><cellbytelabel id="3">Valorizaci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel id="4">Estatus</cellbytelabel></td>
					<td width="5%">&nbsp;</td>
				</tr>				
				<%
				String grupo = "";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
			     String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
                 
                 if (!grupo.equals(cdo.getColValue("cod_header"))) {%>
                 
                 <tr>
                    <td colspan="5" class="TextHeader02"><%=cdo.getColValue("desc_header")%></td>
                 </tr>
                <% 
                 }
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("cod_det")%></td>
					<td><%=cdo.getColValue("desc_det")%></td>
					<td><%=cdo.getColValue("valorizacion_desc")%></td>
					<td><%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
							<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("cod_header")%>,<%=cdo.getColValue("cod_det")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="5">Editar</cellbytelabel></a></authtype>
					</td>
				</tr>
				<%
                grupo = cdo.getColValue("cod_header");
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
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="6">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="7">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="8">hasta</cellbytelabel> <%=nVal%></td>
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