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
ArrayList alDet = new ArrayList();

int rowCount = 0;
String sql = "", sqlDet = "";
String appendFilter = "";
String tipo = request.getParameter("tipo");
String status = request.getParameter("status");
if (tipo == null) tipo = "";
if (status == null) status = "";
if (!tipo.trim().equals("")) appendFilter = " where upper(a.tipo)='"+tipo.toUpperCase()+"'";
if (!status.trim().equals(""))
{
	if (appendFilter.trim().equals("")) appendFilter = " where";
	else appendFilter += " and";
	appendFilter += " upper(a.status)='"+status.toUpperCase()+"'";
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

	String codigo = request.getParameter("codigo");
	String descripcion = request.getParameter("descripcion");
	if (codigo == null) codigo = "";
	if (descripcion == null) descripcion = "";

	if (!codigo.trim().equals(""))
	{
		if (appendFilter.trim().equals("")) appendFilter = " where";
		else appendFilter += " and";
		appendFilter += " upper(a.id) like '%"+codigo.toUpperCase()+"%'";
	}
	if (!descripcion.trim().equals(""))
	{
		if (appendFilter.trim().equals("")) appendFilter = " where";
		else appendFilter += " and";
		appendFilter += " upper(a.descripcion) like '%"+descripcion.toUpperCase()+"%'";
	}

	sql = "select a.id, a.descripcion, a.tipo, a.orden, decode(a.status,'A','ACTIVO','I','INACTIVO') as status, (select description from tbl_sal_tipo_parametro where code=a.tipo) as tipoDesc from tbl_sal_parametro a"+appendFilter+" order by a.tipo, a.descripcion";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");

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
document.title = 'Expediente - Parámetros '+document.title;
function add(){abrir_ventana('../expediente/parametro_config.jsp');}
function edit(id,tipo){abrir_ventana('../expediente/parametro_config.jsp?mode=edit&id='+id+'&tipo='+tipo);}
function editDet(id,param_id,tipo){abrir_ventana('../expediente/parametro_config_det.jsp?mode=edit&id='+id+'&param_id='+param_id+'&tipo='+tipo);}
function printList(){abrir_ventana('../expediente/print_list_parametro.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}

function addChild(id,tipo){
	abrir_ventana('../expediente/parametro_config_det.jsp?id='+id+'&tipo='+tipo);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE- PARAMETROS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nuevo Par&aacute;metro</cellbytelabel> ]</a></authtype>	</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<td colspan="2">
				<cellbytelabel id="2">Tipo</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select code, code||' - '||description, code from tbl_sal_tipo_parametro order by description","tipo",tipo,false,false,0,"Text10",null,null,null,"T")%>
				<cellbytelabel id="3">Estado</cellbytelabel>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,"","T")%>
			</td>
		</tr>
		<tr class="TextFilter">
			<td width="50%">
				<cellbytelabel id="4">C&oacute;digo</cellbytelabel>
				<%=fb.intBox("codigo","",false,false,false,20,"Text10",null,null)%>
			</td>
			<td width="50%">
				<cellbytelabel id="5">Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion","",false,false,false,40,"Text10",null,null)%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="6">Imprimir Lista</cellbytelabel> ]</a></authtype></td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
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

		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="10%"><cellbytelabel id="4">C&oacute;digo</cellbytelabel></td>
			<td width="50%"><cellbytelabel id="5">Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="10">Orden</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Estado</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
            <td width="10%">&nbsp;</td>
		</tr>

<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>

<%
String tipoDesc = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
	sqlDet = "select id, param_id, descripcion, orden, decode(status,'A','ACTIVO','I','INACTIVO') as status, evaluable, comentable from tbl_sal_parametro_det where param_id="+cdo.getColValue("id");
	
	alDet = SQLMgr.getDataList(sqlDet);
	
	if (!tipoDesc.equals(cdo.getColValue("tipoDesc")))
	{
%>
	<tr class="TextHeader02">
		<td colspan="6">[<%=cdo.getColValue("tipo")%>] <%=cdo.getColValue("tipoDesc")%></td>
	</tr>
<%
	}
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=cdo.getColValue("id")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="right"><%=cdo.getColValue("orden")%></td>
			<td align="center"><%=cdo.getColValue("status")%></td>
                 
			<td align="center"><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("id")%>,'<%=cdo.getColValue("tipo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="11">Editar</cellbytelabel></a></authtype></td>
            
            
            <% if(cdo.getColValue("tipo").equalsIgnoreCase("ETO") || cdo.getColValue("tipo").equalsIgnoreCase("ETF")){%>
				
			<td align="center"><a href="javascript:addChild(<%=cdo.getColValue("id")%>,'<%=cdo.getColValue("tipo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="12">Agregar</cellbytelabel></a></td>	
				
			<%	
             for(int det = 0; det<alDet.size(); det++){
				 CommonDataObject cdoDet = (CommonDataObject) alDet.get(det);
				 String colorDet = "TextRow03";%>
            
            <tr class="<%=colorDet%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=colorDet%>')">
            <td align="right"><%=cdoDet.getColValue("id")%></td>
			<td><%="   "+cdoDet.getColValue("descripcion").toLowerCase()%></td>
			<td align="right"><%=cdoDet.getColValue("orden")%></td>
			<td align="center"><%=cdoDet.getColValue("status")%></td>
            
          		<td align="center"><authtype type='4'><a href="javascript:editDet(<%=cdoDet.getColValue("id")%>,<%=cdo.getColValue("id")%>,'<%=cdo.getColValue("tipo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="11">Editar</cellbytelabel></a></authtype></td>
            

            <%}
			}
			%>
     </tr>
<%
	tipoDesc = cdo.getColValue("tipoDesc");
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
<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="7">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="8">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="9">hasta</cellbytelabel> <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("descripcion",descripcion)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>