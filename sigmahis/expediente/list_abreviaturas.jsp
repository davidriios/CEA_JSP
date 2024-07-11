 <%//@ page errorPage="../error.jsp"%>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

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
	String abreviatura = request.getParameter("abreviatura");
	String descripcion = request.getParameter("descripcion");
	String estado  = request.getParameter("estado");
	String tipo  = request.getParameter("tipo");
	if (codigo == null) codigo  = "";
	if (abreviatura == null) abreviatura  = "";
	if (descripcion == null) descripcion = "";
	if (estado == null) estado  = "";
	if (tipo == null) tipo  = "";

  if (!codigo.trim().equals("")) { sbFilter.append(" and codigo = "); sbFilter.append(request.getParameter("codigo")); }
	if (!abreviatura.trim().equals("")) { sbFilter.append(" and upper(abreviatura) like '%"); sbFilter.append(request.getParameter("abreviatura").toUpperCase()); sbFilter.append("%'"); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and upper(descripcion) like '%"); sbFilter.append(request.getParameter("descripcion").toUpperCase()); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and estado = '"); sbFilter.append(request.getParameter("estado")); sbFilter.append("'"); }
  if (!tipo.trim().equals("")) { sbFilter.append(" and tipo = '"); sbFilter.append(request.getParameter("tipo")); sbFilter.append("'");  }

  sbSql.append("select codigo, abreviatura, descripcion, estado, tipo, decode(tipo,'A','APROBADAS','N','NO APROBADAS') as tipo_desc, orden from tbl_sal_abreviaturas");
	if (sbFilter.length() > 0) {
		sbSql.append(sbFilter.replace(0,4," where"));
	}
	sbSql.append(" order by tipo, orden");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql+")");

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
document.title = 'Abreviaturas - '+document.title;
var forceCapitalize = false;
function add(){
    abrir_ventana('../expediente/abreviaturas_config.jsp');
}

function edit(id, tipo){
    abrir_ventana('../expediente/abreviaturas_config.jsp?mode=edit&id='+id+'&tipo='+tipo);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ABREVIATURAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
			<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel id="1">Registrar Nueva Abreviaturas</cellbytelabel> ]</a></authtype>
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
				<td>
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo",codigo,false,false,false,10)%>
                    &nbsp;&nbsp;
					<cellbytelabel>Abreviatura</cellbytelabel>
					<%=fb.textBox("abreviatura",abreviatura,false,false,false,10)%>
                    &nbsp;&nbsp;
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion",descripcion,false,false,false,30)%>
                    &nbsp;&nbsp;
					<cellbytelabel>Tipo</cellbytelabel>
					<%=fb.select("tipo","A=APROBADAS, N=NO APROBADAS",tipo,"T")%>
                    &nbsp;&nbsp;
					<cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("estado","A=ACTIVO, I=INACTIVO",estado,"T")%>
                    &nbsp;&nbsp;&nbsp;&nbsp;
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>				
		
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <!--<tr>
    <td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="5">Imprimir Lista</cellbytelabel> ]</a></authtype> &nbsp;
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("abreviatura",abreviatura)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo",tipo)%>
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
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("abreviatura",abreviatura)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("tipo",tipo)%>
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
		<tr class="TextHeader" align="center">
			<td width="9%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
			<td width="10%"><cellbytelabel id="3">Abreviatura</cellbytelabel></td>
			<td width="56%"><cellbytelabel id="3">Descripci&oacute;n</cellbytelabel></td>
			<td width="9%"><cellbytelabel id="4">Orden</cellbytelabel></td>
			<td width="9%"><cellbytelabel id="4">Estado</cellbytelabel></td>
			<td width="7%">&nbsp;</td>
		</tr>
<%
String gTipo = "";

for (int i=0; i<al.size(); i++){
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
    
    if (!gTipo.equalsIgnoreCase(cdo.getColValue("tipo"))) {
    %>
        <tr class="TextHeader01">
            <td colspan="6"><%=cdo.getColValue("tipo_desc")%></td>
        </tr>
    <%
    }
    %>   
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<!--td align="right"><%=preVal + i%>&nbsp;</td-->
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("abreviatura")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("orden")%></td>
			<td align="center"><%=(cdo.getColValue("estado").equalsIgnoreCase("A")?"ACTIVO":"INACTIVO")%></td>
			<td align="center">
			<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("tipo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel id="9">Editar</cellbytelabel></a></authtype>
			</td>
		</tr>
        <%
        
        gTipo = cdo.getColValue("tipo");
        
        }%>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("abreviatura",abreviatura)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("tipo",tipo)%>
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
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("abreviatura",abreviatura)%>
				<%=fb.hidden("descripcion",descripcion)%>
				<%=fb.hidden("estado",estado)%>
                <%=fb.hidden("tipo",tipo)%>
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
