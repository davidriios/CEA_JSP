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
if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");

UserDet = SecMgr.getUserDetails(session.getId());
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
int recsPerPage = 100;

if (request.getMethod().equalsIgnoreCase("GET"))
{
String sql = "";
String appendFilter = "";
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD";
String searchValFromDate = "";
String searchValToDate   = "";
String searchValDisp     = "";
  
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

	String fecha="";
	if (request.getParameter("fecha")!=null){
	fecha=request.getParameter("fecha").toUpperCase(); 
	appendFilter+=" and upper(fecha) like '"+fecha+"%'";
	}

	String dia_libre="";
	if (request.getParameter("dia_libre")!=null){
	dia_libre=request.getParameter("dia_libre").toUpperCase(); 
	appendFilter+=" and upper(dia_libre) like '"+dia_libre+"%'";
	}

	String descripcion=""; 
	if (request.getParameter("descripcion")!=null){ 
	descripcion=request.getParameter("descripcion").toUpperCase(); 
	appendFilter+=" and upper(descripcion) like '"+descripcion+"%'";
	}	
	
	if (request.getParameter("searchQuery")!=null)
	{ nextVal=request.getParameter("nextVal"); previousVal=request.getParameter("previousVal"); }


  sql = " SELECT fecha, dia_libre, descripcion FROM tbl_pla_dia_feriado WHERE compania>0 "+appendFilter+" ";
  al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum AS rn, a.* FROM ("+sql+") a) WHERE rn BETWEEN "+previousVal+" AND "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_pla_dia_feriado WHERE compania>0 "+appendFilter);

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
document.title = 'Caracteristicas por Clasificación - '+document.title;

function add()
{
	abrir_ventana('caracteristica_clasificacion_config.jsp');
}

function edit(id)
{
	abrir_ventana('caracteristica_clasificacion_config.jsp?mode=edit&id='+id);
}

function printList()
{
	abrir_ventana('print_list_caracteristica_clasificacion.jsp');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECURSOS HUMANOS - PLANILLA - MANTENIMIENTO - DIAS LIBRES "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right">
        <%
         // if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
        %>
	    <a href="javascript:add()" class="LinksTextred">[ Registrar Nuevo D&iacute;a Libre]</a>
   	    <%
		 //}
	    %>
	    </td>
    </tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
<table width="100%" cellpadding="0" cellspacing="1">
<tr class="TextFilter_Red">		
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<td width="25%">Fecha:
  <%=fb.textBox("fecha",fecha,false,false,false,20,null,null,null)%><%=fb.submit("go","Ir")%>					</td>
<td width="25%">&nbsp;D&iacute;a Libre  <%=fb.textBox("dia_libre",dia_libre,false,false,false,20,null,null,null)%> <%=fb.submit("go","Ir")%> </td>
<td width="50%">Descripci&oacute;n
<%=fb.textBox("descripcion",descripcion,false,false,false,40,null,null,null)%>
<%=fb.submit("go","Ir")%>					</td>
<%=fb.formEnd()%>			    </tr>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
</td>
</tr>
<tr>
<td align="right">
		<%
          //if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
		%>
		  <a href="javascript:printList()" class="LinksTextred">[ Imprimir Lista ]</a>
        <%
    //      }
        %>
		</td>
    </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorderRed TableTopBorderRed TableRightBorderRed">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRegisters_Red">
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
				  <td width="10%">
					<%
					if (preVal != 1)
					{
					%>
					<%=fb.submit("previous","<<-")%>
					<%
					}
					%></td>
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
					<td width="10%" align="right">
					<%
					if (!(rowCount <= nxtVal))
					{
					%>
					<%=fb.submit("next","->>")%>
					<%
					}
					%>					</td>
					<%=fb.formEnd()%>				</tr>
			</table>
		</td>
	</tr>
</table>	

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorderRed TableRightBorderRed">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextColumn_Red">
					<td width="5%">&nbsp;</td>
					<td width="15%">Fecha</td>
					<td width="15%">D&iacute;a Libre </td>
					<td width="50%">Descripcion</td>
					<td width="10%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow_Red02";
				 if (i % 2 == 0) color = "TextRow_Red01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRow_Red01_Over')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=preVal + i%>&nbsp;</td>
					<td><%=cdo.getColValue("fecha").substring(0,11)%></td>
					<td><%=cdo.getColValue("dia_libre").substring(0,11)%></td>
					<td><%=cdo.getColValue("descripcion")%></td>					
					<td align="center">&nbsp;
					<%
				//	if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
					//{
					%>					
					<a href="javascript:edit(<%=cdo.getColValue("")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Editar</a>
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
		<td class="TableLeftBorderRed TableBottomBorderRed TableRightBorderRed">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextRegisters_Red">
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
					<td width="10%">
					<%
					if (preVal != 1)
					{
					%>
					<%=fb.submit("previous","<<-")%>
					<%
					}
					%>
					</td>
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
					<td width="10%" align="right">
					<%
					if (!(rowCount <= nxtVal))
					{
					%>
					<%=fb.submit("next","->>")%>
					<%
					}
					%>
					</td>
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