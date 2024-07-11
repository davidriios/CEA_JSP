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
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
	
	String estado  = "";   // variable para mantener el valor de los campos filtrados en la consulta
	String codigo  = "";
	String descrip = "";
  
  if (request.getParameter("estado") != null && !request.getParameter("estado").equals("")) 
  {
	 appendFilter = appendFilter+" and activo_inactivo='"+request.getParameter("estado").toUpperCase()+"' ";	
     estado  = request.getParameter("estado");  // utilizada para mantener el estado del cliente filtrado
  } 
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
	codigo     = request.getParameter("codigo");  // utilizada para mantener el código por el cual se filtró
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip    = request.getParameter("descripcion");  // utilizada para mantener la descripción del cliente filtrado
  }
  
  sql = "SELECT codigo, descripcion, decode(activo_inactivo,'A','Activo','I','Inactivo') as estado,porcentaje_recargo as recargo,impuesto ,(select hospital from tbl_sec_compania where codigo=compania ) as hospital FROM tbl_fac_tipo_cliente where compania="+ (String) session.getAttribute("_companyId")+appendFilter+" order by descripcion";
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
document.title = 'Tipo de Cliente - '+document.title;
function add(){abrir_ventana('../facturacion/tipocliente_config.jsp');}
function edit(code){abrir_ventana('../facturacion/tipocliente_config.jsp?mode=edit&code='+code);}
function replicar(code){abrir_ventana('../facturacion/tipocliente_config.jsp?mode=edit&code='+code+'&fg=REP');}
function printList(){abrir_ventana('../facturacion/print_list_tipocliente.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,350);}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
    <tr>
        <td align="right"><!--<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Tipo de Cliente</cellbytelabel> ]</a></authtype>--></td>
    </tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
			    <tr class="TextFilter">		
                    <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td width="40%"><cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,40,null,null,null)%>
					</td>
				    <td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("descripcion",descrip,false,false,false,40,null,null,null)%>
					</td>
				    <td width="20%"><cellbytelabel>Estado</cellbytelabel>
						<%=fb.select("estado","A=Activo,I=Inactivo",estado,false,false,0,"",null,null,null,"S")%>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
		</td>
	</tr>
    <tr>
        <td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
    </tr>
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
				<%=fb.hidden("descripcion",descrip)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("estado",estado)%> 
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
					<%=fb.hidden("descripcion",descrip)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("estado",estado)%> 
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
 	<tr>
		<td class="TableLeftBorder TableRightBorder">
	<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="5%">&nbsp;</td>
					<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
					<td width="10%">% <cellbytelabel>Recargo</cellbytelabel></td>
					<td width="10%">% <cellbytelabel>Impuesto</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
    				<td width="5%">&nbsp;</td>
					<td width="5%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr align="center" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("codigo")%></td>
					<td align="left"><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("recargo")%></td>
					<td><%=cdo.getColValue("impuesto")%></td>
					<td><%=cdo.getColValue("estado")%></td>
<td><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
<td><%if(cdo.getColValue("hospital").trim().equals("S")){%><authtype type='50'><a href="javascript:replicar(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>REPLICAR</cellbytelabel></a></authtype><%}%></td>
				</tr>
				<%
				}
				%>							
			</table>
	</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</td>
	</tr>
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
				<%=fb.hidden("descripcion",descrip)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("estado",estado)%> 
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
					<%=fb.hidden("descripcion",descrip)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("estado",estado)%> 
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
