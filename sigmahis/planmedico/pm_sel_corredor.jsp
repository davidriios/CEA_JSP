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
<jsp:useBean id="htClt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vClt" scope="session" class="java.util.Vector"/>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

boolean isFpEnabled = CmnMgr.isValidFpType("PAC");
ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String codigo = request.getParameter("codigo");
String nombre = request.getParameter("nombre");
String identificacion = request.getParameter("identificacion");
String status = request.getParameter("status");
int iconHeight = 32;
int iconWidth = 32;
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (codigo == null) codigo = "";
if (nombre == null) nombre = "";
if (identificacion == null) identificacion = "";
if (status == null) status = "A";

if (!nombre.trim().equals("")) { sbFilter.append(" and upper(nombre) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
if (!identificacion.trim().equals("")) { sbFilter.append(" and upper(identificacion) like '%"); sbFilter.append(identificacion.toUpperCase()); sbFilter.append("%'"); }
if (!status.trim().equals("")) { sbFilter.append(" and estado='"); sbFilter.append(status); sbFilter.append("'"); }
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

	sbSql.append("select id, identificacion as identificacion, nombre, estado");
	sbSql.append(" from tbl_pm_corredor where id is not null ");
		sbSql.append(sbFilter);
	sbSql.append(" order by nombre");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");

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
<%@ include file="../common/calendar_base.jsp" %>
<style type="text/css">
	/* needed for stacked instances for ie & sf z-index bug of absolute inside relative els */
	#result_container {z-index:9001; color:#333; font-weight:normal;}
</style>
<script language="javascript">
document.title = 'Paciente - '+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}


<!-- W I N D O W S -->
//Windows Size and Position
var _winWidth=screen.availWidth*0.35;
var _winHeight=screen.availHeight*0.26;
var _winPosX=(screen.availWidth-_winWidth)/2;
var _winPosY=(screen.availHeight-_winHeight)/2;
var _popUpOptions='toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width='+_winWidth+',height='+_winHeight+',top='+_winPosY+',left='+_winPosX;

function loadCliente(id){
	<%if(fp.equals("hist_comision")){%>
	window.opener.document.form0.id_corredor.value= eval('document.result.id'+id).value;
	window.opener.document.form0.nombre_corredor.value= eval('document.result.client_name'+id).value;
	<%} else {%>
	window.opener.document.solicitud.id_corredor.value= eval('document.result.id'+id).value;
	window.opener.document.solicitud.nombre_corredor.value= eval('document.result.client_name'+id).value;
	<%}%>
	window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLAN MEDICO - CORREDOR - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<!--<tr>
	<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='3'><a href="javascript:goOption(0)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,0)" onMouseOut="javascript:mouseOut(this,0)" src="../images/add_client.png"></a></authtype>
	</td>
</tr>
-->
<tr>
	<td>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
			<td>
				<cellbytelabel id="1">Identificaci&oacute;n</cellbytelabel>
				<%=fb.textBox("identificacion",identificacion,false,false,false,30,"Text10",null,null)%>
				<cellbytelabel id="4">Nombre</cellbytelabel>
				<%=fb.textBox("nombre",nombre,false,false,false,30,"Text10",null,"")%>
				<cellbytelabel id="8">Estado</cellbytelabel>
				<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,false,false,0,"Text10",null,null,null,"T")%>
				<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
			</td>
<%=fb.formEnd(true)%>
		</tr>
		</table>
	</td>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="10">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="11">Registros desde </cellbytelabel> <%=pVal%><cellbytelabel id="12"> hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%fb = new FormBean("result","","post","");%>
<%=fb.formStart()%>
<%=fb.hidden("index","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1"> <!--class="sortable" id="list" exclude="8,9"-->
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel id="1">ID</cellbytelabel></td>
			<td width="13%"><cellbytelabel id="7">C&eacute;dula / Pasaporte</cellbytelabel></td>
			<td width="23%"><cellbytelabel id="4">Nombre</cellbytelabel></td>
			<td width="5%"><cellbytelabel id="8">Estado</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("client_name"+i,cdo.getColValue("nombre"))%>
		<%=fb.hidden("identificacion"+i,cdo.getColValue("identificacion"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onDblClick="javascript:loadCliente(<%=i%>)">
			<td align="center"><%=cdo.getColValue("id")%></td>
			<td><%=cdo.getColValue("identificacion")%></td>
			<td><%=cdo.getColValue("nombre")%></td>
			<td align="center"><%=(cdo.getColValue("estado").equalsIgnoreCase("A"))?"ACTIVO":"INACTIVO"%></td>
		</tr>
<%
}
%>
<%=fb.hidden("keySize",""+al.size())%>
		</table>
		</div>
	</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<%=fb.formEnd()%>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel id="10">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel id="11">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="12"> hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("identificacion",identificacion)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
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
else
{
	System.out.println("=====================POST=====================");
	int lineNo = 0;
	lineNo = htClt.size();

	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	if((fp.equalsIgnoreCase("plan_medico") || fp.equalsIgnoreCase("adenda")) && fg.equalsIgnoreCase("beneficiario")){
		for(int i=0;i<keySize;i++){
			CommonDataObject cd = new CommonDataObject();

			cd.addColValue("id_cliente", request.getParameter("clientId"+i));
			cd.addColValue("client_name", request.getParameter("client_name"+i));
			cd.addColValue("identificacion", request.getParameter("identificacion"+i));
			cd.addColValue("fecha_nacimiento", request.getParameter("fecha_nacimiento"+i));
			cd.addColValue("edad", request.getParameter("edad"+i));
			cd.addColValue("sexo", request.getParameter("sexo"+i));
			cd.addColValue("id", "0");
			cd.addColValue("id_solicitud", "0");


			if(request.getParameter("check"+i)!=null){

				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					htClt.put(key, cd);
					vClt.add(cd.getColValue("id_cliente"));
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}

			}
		}
	}
	/*
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../common/sel_procedimiento.jsp?change=1&type=1&fg="+fg+"&fp="+fp+"&cs="+cs);
		return;
	}
	*/

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	<%if((fp.equals("plan_medico") || fp.equals("adenda")) && fg.equals("beneficiario")){%>
	window.opener.location = '<%=request.getContextPath()+"/planmedico/reg_solicitud_det.jsp?mode=add&change=1&fg="+fg%>&fp=<%=fp%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>