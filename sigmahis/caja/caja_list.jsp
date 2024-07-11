<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
fp	descripción
----------------------------------------------------------------------------------
		Mantenimiento
1		Consulta de Depósito x Caja
2		Proceso de Cierre de Caja
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String statusList = "A=ACTIVO,I=INACTIVO";
if (fp == null) fp = "";

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

	String code = request.getParameter("code");
	String desc = request.getParameter("desc");
	String ubic = request.getParameter("ubic");
	String ip = request.getParameter("ip");
	String status = request.getParameter("status");
	if (code == null) code = "";
	if (desc == null) desc = "";
	if (ubic == null) ubic = "";
	if (ip == null) ip = "";
	if (status == null) status = "";
	if (fp.equalsIgnoreCase("2"))
	{
		status = "A";
		statusList = "A=ACTIVO";
	}

	if (!code.trim().equals("")) { sbFilter.append(" and codigo="); sbFilter.append(code); }
	if (!desc.trim().equals("")) { sbFilter.append(" and upper(descripcion) like '%"); sbFilter.append(desc.toUpperCase()); sbFilter.append("%'"); }
	if (!ubic.trim().equals("")) { sbFilter.append(" and upper(ubicacion) like '%"); sbFilter.append(ubic.toUpperCase()); sbFilter.append("%'"); }
	if (!ip.trim().equals("")) { sbFilter.append(" and upper(ip) like '%"); sbFilter.append(ip.toUpperCase()); sbFilter.append("%'"); }
	if (!status.trim().equals("")) { sbFilter.append(" and estado='"); sbFilter.append(status.toUpperCase()); sbFilter.append("'"); }

	sbSql = new StringBuffer();
	sbSql.append("select * from (select rownum as rn, a.* from (");
		sbSql.append("select codigo, descripcion, decode(estado,'A','ACTIVO','I','INACTIVO') as estado, nvl(ubicacion,' ') as ubicacion, nvl(ip,' ') as ip,no_recibo as ultRecibo from tbl_cja_cajas where compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 2");
	sbSql.append(") a) where rn between ");
	sbSql.append(previousVal);
	sbSql.append(" and ");
	sbSql.append(nextVal);
	al = SQLMgr.getDataList(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select count(*) from tbl_cja_cajas where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	rowCount = CmnMgr.getCount(sbSql.toString());

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
document.title = 'Caja - '+document.title;
function add(){abrir_ventana('../caja/reg_caja.jsp');}
function edit(id){abrir_ventana('../caja/reg_caja.jsp?mode=edit&id='+id);}
function view(id){abrir_ventana('../caja/reg_caja.jsp?mode=view&id='+id);}
function ver(id){abrir_ventana('../caja/depositos_x_caja.jsp?id='+id);}
//function closeCashDrawer(caja){abrir_ventana('../caja/cierre_caja.jsp?id='+caja);}

function closeCashDrawer(caja){
	if(confirm('En este punto usted ya se aseguró de que los montos de los recibos físicos y la infomación del sistema concuerden muy bien... Desea continuar con el cierre?')){
		var count=parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_cja_turnos_x_cajas','compania=<%=(String) session.getAttribute("_companyId")%> and cod_caja='+caja+' and estatus=\'A\''),10);
		if(count==1) abrir_ventana('../caja/cierre_caja.jsp?id='+caja);
		else if(count>1)alert('Se ha detectado más de un turno activo en esta caja...');
		else alert('La caja no existe o ya está cerrada. Por favor verifique!');
		window.location.reload(true);
	}
}

function printList(){abrir_ventana('../caja/print_caja_list.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CAJA - MANTENIMIENTOS - CAJAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00"><cellbytelabel>[ Registrar Nueva Caja ]</cellbytelabel></a></authtype></td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
		<tr class="TextFilter">
			<td width="7%"><cellbytelabel>
				C&oacute;digo</cellbytelabel><br>
				<%=fb.textBox("code","",false,false,false,5,"Text10",null,null)%>
			</td>
			<td width="34%"><cellbytelabel>
				Descripci&oacute;n</cellbytelabel><br>
				<%=fb.textBox("desc","",false,false,false,50,"Text10",null,null)%>
			</td>
			<td width="34%"><cellbytelabel>
				Ubicaci&oacute;n</cellbytelabel><br>
				<%=fb.textBox("ubic","",false,false,false,50,"Text10",null,null)%>
			</td>
			<td width="12%"><cellbytelabel>
				Direcci&oacute;n IP</cellbytelabel><br>
				<%=fb.textBox("ip","",false,false,false,15,"Text10",null,null)%>
			</td>
			<td width="13%"><cellbytelabel>
				Estado</cellbytelabel><br>
				<%=fb.select("status",statusList,status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir",false,false,"Text10 UpperCaseText SpacingTextBold",null,null)%>
			</td>
		</tr>
<%=fb.formEnd()%>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
</tr>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("ubic",ubic)%>
<%=fb.hidden("ip",ip)%>
<%=fb.hidden("status",status)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde <%=pVal%> hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("ubic",ubic)%>
<%=fb.hidden("ip",ip)%>
<%=fb.hidden("status",status)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1" class="sortable" id="list" exclude="4">
		<tr class="TextHeader" align="center">
			<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="25%"><cellbytelabel>Ubicaci&oacute;n</cellbytelabel></td>
			<!--<td width="10%"><cellbytelabel>Ult.Rec.</cellbytelabel></td>-->
			<td width="22%"><cellbytelabel>Direcci&oacute;n IP</cellbytelabel></td>
			<td width="8%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td><%=cdo.getColValue("ubicacion")%></td>
			<!--<td align="center"><%//=cdo.getColValue("ultRecibo")%></td>-->
			<td align="center"><%=cdo.getColValue("ip")%></td>
			<td align="center"><%=cdo.getColValue("estado")%></td>
			<td align="center">
				<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype>
				<authtype type='1+4'> | </authtype>
				<authtype type='1'><a href="javascript:view(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a></authtype>
			</td>
		</tr>
<% } %>
		</table>
</div>
</div>
	</td>
</tr>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("ubic",ubic)%>
<%=fb.hidden("ip",ip)%>
<%=fb.hidden("status",status)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde <%=pVal%> hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("desc",desc)%>
<%=fb.hidden("ubic",ubic)%>
<%=fb.hidden("ip",ip)%>
<%=fb.hidden("status",status)%>
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
<% } %>