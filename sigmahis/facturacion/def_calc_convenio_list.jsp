
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
200017	VER LISTA DE TIPOS DE AJUSTES
200018	IMPRIMIR LISTA DE TIPOS DE AJUSTES
200019	AGREGAR TIPO DE AJUSTE
200020	MODIFICAR TIPO DE AJUSTE
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
/*if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200017") || SecMgr.checkAccess(session.getId(),"200018") || SecMgr.checkAccess(session.getId(),"200019") || SecMgr.checkAccess(session.getId(),"200020"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta p�gina.");*/
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
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
	
	String codigo  = "";                   // variables para mantener el valor de los campos filtrados en la consulta
	String descrip = "";

  if (request.getParameter("code") != null)
  {
    appendFilter += " where upper(codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "C�digo";
		codigo     = request.getParameter("code");              // utilizada para mantener el C�digo del Tipo de Ajuste
  }
  else if (request.getParameter("descripcion") != null)
  {
    appendFilter += " where upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripcion";
		descrip    = request.getParameter("descripcion");      // utilizada para mantener la Descripci�n del Tipo de Ajuste
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
   if (searchType.equals("1"))
   {
     appendFilter += " where upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
   }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

 sql="select codigo as code, descripcion, program_unit, comentario, comentario2, estado, decode(estado,'A','Activo', 'I', 'Inactivo') estado_desc, comentario3  from tbl_adm_calculo_beneficio"+appendFilter+" order by descripcion";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_adm_calculo_beneficio"+appendFilter);
	
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

<style type="text/css">
.tdHt{
padding:10px 0 10px 7px;
}


</style>

<script language="javascript">
document.title = 'Inventario - Administraci�n - Tipo Ajuste - '+document.title;

function add()
{
abrir_ventana('../facturacion/def_calc_convenio_config.jsp');
}

function edit(id)
{
	abrir_ventana('../facturacion/def_calc_convenio_config.jsp?mode=edit&id='+id);
}

function  printList()
{
abrir_ventana('print_list_tipoajuste.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - TIPO AJUSTE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200019")){
%>
		<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevo Tipo Ajuste</cellbytelabel> ]</a></authtype>
<%
//}
%>
		</td>
	</tr>	
	
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
					<td width="50%"><cellbytelabel>C&oacute;digo</cellbytelabel>
								<%=fb.textBox("code",codigo,false,false,false,30)%>
								<%=fb.submit("go","Ir")%></td>
					<%=fb.formEnd()%>	
					
					<%
					fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
								<%=fb.textBox("descripcion",descrip,false,false,false,30)%>
								<%=fb.submit("go","Ir")%></td>
					<%=fb.formEnd()%>	
				 </tr>
			 </table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>
<br/>	
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200018")){
%>
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
<%
//}
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

<table align="center" width="100%" cellpadding="5" cellspacing="1">
	<tr class="TextHeader" align="center">
	    <td width="5%">&nbsp;</td>
		<td width="15%">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="65%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td>&nbsp;</td>
	</tr>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td>&nbsp;<%=cdo.getColValue("code")%></td>
					<td>&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td>&nbsp;<%=cdo.getColValue("descripcion")%></td>
				<td align="center">
                  <authtype type='4'>
                      <a href="javascript:edit(<%=cdo.getColValue("code")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a>
                  </authtype>
<%//}%>					

				  </td>
				</tr>
				
				<%}%>							
								
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
