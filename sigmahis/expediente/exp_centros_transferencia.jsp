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
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

String id = (request.getParameter("id") == null?"":request.getParameter("id"));
String nombre = (request.getParameter("nombre") == null?"":request.getParameter("nombre"));
String status = (request.getParameter("status") == null?"":request.getParameter("status"));

if(request.getMethod().equalsIgnoreCase("GET"))
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

	if ( !id.equals(""))
	{
		appendFilter += " and fa.id = "+id;
		searchOn = "id";
		searchVal = id;
		searchType = "1";
	}

	if (!nombre.trim().equals(""))
	{
		appendFilter += " and upper(fa.nombre) like '%"+nombre.toUpperCase()+"%'";
		searchOn = "nombre";
		searchVal = nombre;
		searchType = "1";
	}
  
    if (!status.trim().equals("") && !status.trim().equals("T"))
    { 
		appendFilter += " and fa.status = '"+status+"'";
		searchOn = "status";
		searchVal = status;
		searchType = "1";
   }

   if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
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
   
   sql="select fa.id, fa.nombre, fa.status, decode(fa.status,'A','ACTIVO','I','INACTIVO') status_desc, fa.direccion, fa.telefonos from tbl_sal_centros_tranf fa where fa.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by fa.id";
   al = SQLMgr.getDataList(sql);
   rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+") ");

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
document.title = 'Expediente - Centros de Tranferencia - '+document.title;
function add(){
  abrir_ventana("../expediente/exp_centros_tranferencia_config.jsp");
}

function edit(id){
   abrir_ventana("../expediente/exp_centros_tranferencia_config.jsp?mode=edit&id="+id);
}
function printList(){
  abrir_ventana("../expediente/print_centros_tranferencia.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>");
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO - CENTROS DE TRANSFERENCIAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">
			<authtype type='3'><a class="Link00Bold" href="javascript:add();">[ Registrar Centros ]</a></authtype>
			<authtype type='0'><a class="Link00Bold" href="javascript:printList();">[ Imprimir ]</a></authtype>
		</td>
	</tr>

	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
				<%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
				<%=fb.formStart()%>
					<td width="5%">C&oacute;digo</td>
					<td width="20%">
					  <%=fb.textBox("id",id,false,false,false,20,null,null,"onFocus=\"this.select()\"")%></td>
					<td width="5%" align="right">&nbsp;Nombre</td>
					<td width="20%">
						<%=fb.textBox("nombre",nombre,false,false,false,40,null,null,"onFocus=\"this.select()\"")%>
					</td>	
					<td width="10%" align="right">&nbsp;Estado</td>
					<td width="40%">
						<%=fb.select("status","T=Todos,A=Activo,N=Inactivo",status)%>
						&nbsp;&nbsp;&nbsp;&nbsp;
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
					<%fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());%>
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
						<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
						<td width="40%">Total Registro(s) <%=rowCount%></td>
						<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());%>
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
				<tr class="TextHeader">
					<td width="5%">C&oacute;digo</td>
					<td width="30%">Nombre</td>
					<td width="30%">Direcci&iacute;on</td>
					<td width="20%">Tel&eacute;fonos</td>
					<td width="10%" align="center">Estado</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("id")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("direccion")%></td>
					<td><%=cdo.getColValue("telefonos")%></td>
					<td><%=cdo.getColValue("status_desc")%></td>
					<td align="center"><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("id")%>)" class="Link00Bold">Editar</a></authtype></td>
				</tr>
				<%}%>
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
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
				<tr>
					<td colspan="4" align="right"> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
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