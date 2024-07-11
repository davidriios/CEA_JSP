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
900093	VER LISTA DE CONTRATOS DE ALQUILERES
900094	IMPRIMIR LISTA DE CONTRATOS DE ALQUILERES
900095	AGREGAR CONTRATO DE ALQUILER
900096	MODIFICAR CONTRATO DE ALQUILER
900097	MODIFICAR ESTADO DE CONTRATO DE ALQUILER
900098	AGREGAR DETALLES AL CONTRATO DE ALQUILER
900099	MODIFICAR DETALLES AL CONTRATO DE ALQUILER
900100	MODIFICAR ESTADO DE DETALLE DEL CONTRATO DE ALQUILER
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900093") || SecMgr.checkAccess(session.getId(),"900094") || SecMgr.checkAccess(session.getId(),"900095") || SecMgr.checkAccess(session.getId(),"900096")|| SecMgr.checkAccess(session.getId(),"900097")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
	
	String contrato = "", cliente = ""; // variables para mantener el valor de los campos filtrados en la consulta
	String estado   = "";	
  
  if (request.getParameter("estado") != null )
  { if (!request.getParameter("estado").equals("")) 
	{
	  appendFilter = appendFilter+" and a.estado = '"+request.getParameter("estado").toUpperCase()+"' ";	
		estado    =  request.getParameter("estado"); // utilizada para mantener el valor del estado por el cual se filtró
	}
	else 
		{
		  appendFilter=appendFilter+" and upper(a.estado)<> 'I'";
			estado    =  request.getParameter("estado"); // utilizada para mantener el valor del estado por el cual se filtró
		}
  }else
      {
        appendFilter=appendFilter+" and upper(a.estado)<> 'I'";
				estado    =  request.getParameter("estado"); // utilizada para mantener el valor del estado por el cual se filtró
      }

  if (request.getParameter("contrato") != null)
  {     
    appendFilter += " and upper(a.contrato) like '%"+request.getParameter("contrato").toUpperCase()+"%'";
    searchOn = "a.contrato";
    searchVal = request.getParameter("contrato");
    searchType = "1";
    searchDisp = "Contrato";
		contrato   = request.getParameter("contrato"); // utilizada para mantener el valor del contrato por el cual se filtró
  }
  else if (request.getParameter("cliente") != null)
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("cliente").toUpperCase()+"%'";
    searchOn = "b.descripcion";
    searchVal = request.getParameter("cliente");
    searchType = "1";
    searchDisp = "Cliente";
		cliente    = request.getParameter("cliente"); // utilizada para mantener el valor del cliente por el cual se filtró
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

  sql = "SELECT a.contrato, decode(a.tipo_contrato,'1','Otros Cargos','2','Solo Cargos') as tipo, b.descripcion as cliente, decode(a.estado,'A','Activo','I','Inactivo') as estado FROM tbl_cxc_contrato_alq a, tbl_cxc_cliente_particular b WHERE a.particular=b.codigo and a.compania=b.compania "+appendFilter+" order by b.descripcion";		
  al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_cxc_contrato_alq a, tbl_cxc_cliente_particular b WHERE a.particular=b.codigo and a.compania=b.compania "+appendFilter);

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
document.title = 'Contrato de Alquiler - '+document.title;

function add()
{
	abrir_ventana('contratoalquiler_config.jsp');
}

function edit(code)
{
	abrir_ventana('contratoalquiler_config.jsp?mode=edit&code='+code);
}

function printList()
{
	abrir_ventana('print_list_contrato_alquiler.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - ALQUILER - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right">
        <%
		//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900095"))
		//{
		%>
	    <a href="javascript:add()" class="Link00">[ Registrar Nuevo Contrato de Alquiler ]</a>
   	    <%
		//}
	    %>
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
				    <td width="40%">No. Contrato
					<%=fb.textBox("contrato",contrato,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>
							
					<%
					  fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td width="40%">Cliente
					<%=fb.textBox("cliente",cliente,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>
					
					<%
					  fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td width="20%">Estado
					<%=fb.select("estado","A=Activo,I=Inactivo",estado,null)%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right">
		<%
		//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900094"))
		//{
		%>
		  <a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>
        <%
       // }
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
				<tr class="TextHeader" align="center">
					<td width="15%">Contrato</td>
					<td width="35%">Cliente</td>
					<td width="30%">Tipo Contrato</td>
					<td width="10%">Estado</td>
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
					<td><%=cdo.getColValue("contrato")%></td>
					<td><%=cdo.getColValue("cliente")%></td>
					<td><%=cdo.getColValue("tipo")%></td>
					<td><%=cdo.getColValue("estado")%></td>
					<td align="center">
					<%
					//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900096"))
					//{
					%>	
					<a href="javascript:edit(<%=cdo.getColValue("contrato")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a>
				    <%
					//}
					%>	
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
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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