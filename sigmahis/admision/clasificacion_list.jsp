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
400013	VER LISTA DE CLASIFICACIONES POR TIPOS DE ADMISIONES
400014	IMPRIMIR LISTA DE CLASIFICACIONES POR TIPOS DE ADMISIONES
400015	AGREGAR CLASIFICACION POR TIPO DE ADMISION
400016	MODIFICAR CLASIFICACION POR TIPO DE ADMISION
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"400013") || SecMgr.checkAccess(session.getId(),"400014") || SecMgr.checkAccess(session.getId(),"400015") || SecMgr.checkAccess(session.getId(),"400016"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String categoria = request.getParameter("categoria");
String tipo = request.getParameter("tipo");
String code = "";
String name = "";

if (categoria == null) categoria = "";
if (!categoria.equals(""))
{
	appendFilter = " and a.categoria="+categoria;

	if (tipo == null) tipo = "";
	if (!tipo.equals("")) appendFilter += " and a.tipo="+tipo;
}
if (tipo == null) tipo = "";

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

  if (request.getParameter("code") != null)
  {
    appendFilter += " and upper(a.codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";
    searchOn = "a.codigo";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
	code = 	request.getParameter("code");
  }
  else if (request.getParameter("name") != null)
  {
    appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";
    searchOn = "a.descripcion";
    searchVal = request.getParameter("name");
    searchType = "1";
    searchDisp = "Descripción";
	name = 	request.getParameter("name");	
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

  sql = "select a.categoria, a.tipo, a.codigo, a.descripcion, b.descripcion as catName, c.descripcion as tipoName from tbl_adm_clasif_x_tipo_adm a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_cia c where a.categoria=b.codigo and a.categoria=c.categoria and a.tipo=c.codigo"+appendFilter+" order by b.descripcion, c.descripcion, a.descripcion";
  
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("select count(*) from tbl_adm_clasif_x_tipo_adm a, tbl_adm_categoria_admision b, tbl_adm_tipo_admision_cia c where a.categoria=b.codigo and a.categoria=c.categoria and a.tipo=c.codigo "+appendFilter);

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
document.title = 'Clasificación de Admisión - '+document.title;

function add()
{
	abrir_ventana2('../admision/clasificacion_config.jsp');
}

function edit(catCode, tipoCode, code)
{
	abrir_ventana2('../admision/clasificacion_config.jsp?mode=edit&catCode='+catCode+'&tipoCode='+tipoCode+'&code='+code);
}

function printList()
{
	abrir_ventana2('../admision/print_list_clasificacion.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function getMain(formx)
{
	formx.categoria.value = document.search00.categoria.value;
	formx.tipo.value = document.search00.tipo.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLÍNICA - ADMISIÓN - MANTENIMIENTO"></jsp:param>
</jsp:include>
 
<table align="center" width="99%" cellpadding="1" cellspacing="0">
    <tr>
        <td align="right">&nbsp;
      	 <authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nueva Clasificaci&oacute;n</cellbytelabel> ]</a></authtype>
   	    </td>
    </tr>
<tr>
<td>
<table width="100%" cellpadding="0" cellspacing="0">
<tr class="TextFilter">		    
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>	
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<td colspan="2">
<cellbytelabel id="2">Categor&iacute;a</cellbytelabel>			            
<%=fb.select(ConMgr.getConnection(), "Select codigo, descripcion From tbl_adm_categoria_admision order by descripcion","categoria",categoria,false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/itemTipo.xml','tipo','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','T')\"",null,"T")%> Tipo
<%=fb.select("tipo","","")%>
<script language="javascript">
loadXML('../xml/itemTipo.xml','tipo','<%=tipo%>','VALUE_COL','LABEL_COL','KEY_COL','<%=categoria%>','T');
</script>
<%=fb.submit("go","Ir")%></td>
<%=fb.formEnd()%></tr>
				
		        <tr class="TextFilter">
		            <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>	
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("categoria","").replaceAll(" id=\"categoria\"","")%>
					<%=fb.hidden("tipo","").replaceAll(" id=\"tipo\"","")%>
		            <td width="50%">
					    <cellbytelabel id="3">C&oacute;digo</cellbytelabel>
					    <%=fb.textBox("code",code,false,false,false,30,null,null,null)%>
					    <%=fb.submit("go","Ir")%>
					</td>
		            <%=fb.formEnd()%>	

		            <%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp",FormBean.GET,"onSubmit=\"javascript:return(getMain(this))\"");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("categoria","").replaceAll(" id=\"categoria\"","")%>
					<%=fb.hidden("tipo","").replaceAll(" id=\"tipo\"","")%>
					<td width="50%">
						<cellbytelabel id="4">Descripci&oacute;n</cellbytelabel>
						<%=fb.textBox("name",name,false,false,false,30,null,null,null)%>
						<%=fb.submit("go","Ir")%>					
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
	</td>
	</tr>
    <tr>
        <td align="right">&nbsp;
					<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="5">Imprimir Lista</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
				<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
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
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
				<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
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
					<td width="20%"><cellbytelabel id="3">C&oacute;digo</cellbytelabel></td>
					<td width="70%"><cellbytelabel id="4">Descripci&oacute;n</cellbytelabel></td>
					<td width="10%">&nbsp;</td>
				</tr>				
				<%
				String categoriaTipo = "";
				   
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 
				 if (i % 2 == 0) color = "TextRow01";
				 
				 if (!categoriaTipo.equalsIgnoreCase("["+cdo.getColValue("catName")+"] "+cdo.getColValue("tipoName")))
				 {				 
				%>
				<tr class="TextHeader01">
					<td colspan="4">[<%=cdo.getColValue("catName")%>] <%=cdo.getColValue("tipoName")%></td>
				</tr>
				<%
					}
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center">
							<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("categoria")%>,<%=cdo.getColValue("tipo")%>,<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="9">Editar</cellbytelabel></a></authtype>
					</td>
				</tr>
				<%
				  categoriaTipo = "["+cdo.getColValue("catName")+"] "+cdo.getColValue("tipoName");
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
				<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
				<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
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
				<%=fb.hidden("categoria",categoria).replaceAll(" id=\"categoria\"","")%>
				<%=fb.hidden("tipo",tipo).replaceAll(" id=\"tipo\"","")%>
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