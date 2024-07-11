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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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

  if (request.getParameter("codigo") != null)  
  {
    appendFilter += " WHERE upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
    appendFilter += " WHERE upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripcion";
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
	{
		if (searchType.equals("1"))
		{
			appendFilter += " WHERE upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
		}
	}
  else
	{
		searchOn="SO";
		searchVal="Todos";
		searchType="ST";
		searchDisp="Listado";
  }

  sql = "SELECT a.CONSECUTIVO_AG as codigo, a.BANCO, a.COMPANIA, a.CUENTA_BANCO as cuenta, a.F_MOVIMIENTO, a.TIPO_MOVIMIENTO,a.MONTO, a.LADO, a.ESTADO_TRANS, a.OBSERVACION,a.caja ,a.descripcion||' - '||a.OBSERVACION as descripcion,con.nombre FROM TBL_CON_MOVIM_BANCARIO a,TBL_CON_TIPO_MOVIMIENTO b,TBL_SEC_COMPANIA con where a.COMPANIA=	con.codigo(+) and a.tipo_movimiento=1 and a.TIPO_MOVIMIENTO = b.cod_transac  and a.ESTADO_TRANS = 'T' AND a.ESTADO_DEP = 'DT' "+appendFilter+"order by a.CONSECUTIVO_AG , a.F_MOVIMIENTO desc";
  al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	//rowCount = CmnMgr.getCount(" SELECT count(*) FROM tbl_sal_recuperacion_anestesia "+appendFilter);

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
document.title = 'Listado de Movimientos Bancarios- '+document.title;

function add()
{
	abrir_ventana('../caja/registro_deposito.jsp');
}

function edit(id,cuenta,banco,caja,compania)
{
	abrir_ventana('../caja/registro_deposito.jsp?mode=edit&consecutivo='+id+'&cuenta='+cuenta+'&banco='+banco+'&caja='+caja+'&compania='+compania);
}
function printList()
{
	//abrir_ventana('../expediente/print_recuperacion_post_anestesia_list.jsp');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="MOVIMIENTOS BANCARIOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
<td align="right">&nbsp;
        <%
         // if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
        %>
	    <a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Dep&oacute;sito</cellbytelabel> ]</a>
   	    <%
		 //}
	    %>
</td>
</tr>
<tr>
<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<tr class="TextFilter">
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<td width="50%"><cellbytelabel>C&oacute;digo</ellbytelabel>
<%=fb.textBox("codigo",request.getParameter("codigo"),false,false,false,30,null,null,null)%>
<%=fb.submit("go","Ir")%>
</td>
<%=fb.formEnd()%>

<% fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
<%=fb.textBox("descripcion",request.getParameter("descripcion"),false,false,false,40,null,null,null)%>
<%=fb.submit("go","Ir")%>
</td>	
</tr>
<%=fb.formEnd()%>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
    <tr>
        <td align="right">&nbsp;
		<%
          //if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
		%>
		  <a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
        <%
    //      }
        %>
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
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
	
<table align="center" width="100%" cellpadding="0" cellspacing="1">
<tr class="TextHeader">
<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
<td width="30%"><cellbytelabel>Compañia</cellbytelabel></td>
<td width="50%"><cellbytelabel>Transacci&oacute;n</cellbytelabel></td>
<td width="10%">&nbsp;</td>
</tr>	
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
<%//=fb.hidden("codigo",cdo.getColValue("codigo"))%>
<%//=fb.hidden("caja",cdo.getColValue("caja"))%>
<%//=fb.hidden("banco",cdo.getColValue("banco"))%>
<%//=fb.hidden("cuenta",cdo.getColValue("cuenta"))%>
<%//=fb.hidden("compania",cdo.getColValue("compania"))%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td><%=cdo.getColValue("codigo")%></td>
<td><%=cdo.getColValue("nombre")%></td>		
<td><%=cdo.getColValue("descripcion")%></td>		
<td align="center">&nbsp;
<%
//	if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
//{
%>				
<a href="javascript:edit('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("cuenta")%>','<%=cdo.getColValue("banco")%>','<%=cdo.getColValue("caja")%>','<%=cdo.getColValue("compania")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a>
<%
//}
%></td>
</tr>
<% } %>	
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
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde<cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>