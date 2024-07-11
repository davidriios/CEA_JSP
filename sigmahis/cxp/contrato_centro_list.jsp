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
String status = request.getParameter("status");
String cod_centro_servicio = "";
String descripcion = "";
String estado = "";

if (status == null) status = "";
if (!status.equals("")) appendFilter = " and a.estado='"+status+"'";

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

	if (request.getParameter("cod_centro_servicio") != null)
	{
		appendFilter += " and upper(a.cod_centro_servicio) like '%"+request.getParameter("cod_centro_servicio").toUpperCase()+"%'";

    searchOn = "a.cod_centro_servicio";
    searchVal = request.getParameter("cod_centro_servicio");
    searchType = "1";
    searchDisp = "Código";
    cod_centro_servicio = request.getParameter("cod_centro_servicio");	
	}
	else if (request.getParameter("descripcion") != null)
	{
		appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";

    searchOn = "a.descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Nombre";
    descripcion = request.getParameter("descripcion");	
	}
	else if (request.getParameter("status") != null)
  {
    appendFilter += " and upper(a.estado) like '%"+request.getParameter("status").toUpperCase()+"%'";
    searchOn = "a.estado";
    searchVal = request.getParameter("status");
    searchType = "1";
    searchDisp = "estado";
    estado = request.getParameter("status");	
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

	sql = "select a.num_contrato, a.cod_centro_servicio, b.descripcion, '[ '||a.cod_centro_servicio||' ]'||b.descripcion centroDesc, a.estado,  a.porcentaje, nvl(a.cant_desc,0) cant_desc, decode(a.estado,'A','Activo','I','Inactivo') estadoDesc, decode(a.tipo,'M','Médico','A','Asociación') tipo, nvl(a.monto_desc,0) monto_desc from tbl_cxp_contrato_centro_serv a, tbl_sec_unidad_ejec b where  b.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and  a.cod_centro_servicio = b.codigo order by 2,1";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from tbl_cxp_contrato_centro_serv a, tbl_sec_unidad_ejec b where  b.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and  a.cod_centro_servicio = b.codigo ");

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
document.title = ' Contrato de Centros de Servicios - '+document.title;

function add()
{
	abrir_ventana('../cxp/contrato_centro_config.jsp');
}

function edit(id,num)
{
	abrir_ventana('../cxp/contrato_centro_config.jsp?mode=edit&id='+id+'&num='+num);
}

function printList()
{
	abrir_ventana('../cxp/print_list_contrato_centro.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function getMain(formx)
{
	formx.status.value = document.search00.status.value;
	return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CLINICA - CXP - MANTENIMIENTOS - CONTRATOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;
				<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nuevos Contratos</cellbytelabel> ]</a></authtype>
		</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextFilter">
<%
fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td colspan="2">
					<cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,"T")%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("status","").replaceAll(" id=\"status\"","")%>
				<td width="50%">
					<cellbytelabel>C&oacute;digo de Centro</cellbytelabel>
					<%=fb.textBox("cod_centro_servicio",cod_centro_servicio,false,false,false,15)%>
			  	<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp",fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("status","").replaceAll(" id=\"status\"","")%>
				<td width="50%">
					<cellbytelabel>Nombre</cellbytelabel> 
					<%=fb.textBox("descripcion",descripcion,false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list">
	<tr class="TextHeader" align="center">
	  <td width="10%"><cellbytelabel>No.Contrato</cellbytelabel></td>
		<td width="40%"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Porcentaje</cellbytelabel>(%)</td>
		<td width="10%"><cellbytelabel>Cantidad</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Monto</cellbytelabel>($)</td>
		<td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="7%">&nbsp;</td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("num_contrato")%></td>
			<td><%=cdo.getColValue("centroDesc")%></td>
			<td align="center"><%=cdo.getColValue("porcentaje")%></td>
			<td align="center"><%=cdo.getColValue("cant_desc")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_desc"))%></td>
			<td align="center">
				<%//=(cdo.getColValue("estado").equalsIgnoreCase("A"))?"Activo":"Inactivo"%>
				<%if(cdo.getColValue("estado").equalsIgnoreCase("A")){%> <cellbytelabel>Activo</cellbytelabel>
				<%}else{%> <cellbytelabel>Inactivo</cellbytelabel>
				<%}%>
			</td>
			<td align="center">
			<authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("cod_centro_servicio")%>','<%=cdo.getColValue("num_contrato")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype>
			</td>
		</tr>
<%
}
%>				
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
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
				<%=fb.hidden("status",status).replaceAll(" id=\"status\"","")%>
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