<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
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
String cds = request.getParameter("cds")==null?"":request.getParameter("cds");
String status = request.getParameter("status")==null?"":request.getParameter("status");
String id = request.getParameter("id")==null?"":request.getParameter("id");
String descripcion = request.getParameter("descripcion")==null?"":request.getParameter("descripcion");
String compania = (String) session.getAttribute("_companyId");

if (cds.trim().equalsIgnoreCase("")) {
	if (SecMgr.getParValue(UserDet,"cds") != null && !SecMgr.getParValue(UserDet,"cds").trim().equals("")) cds = SecMgr.getParValue(UserDet,"cds");
	else cds = "";
}

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

	if (!cds.trim().equals("")) appendFilter += " and e.cds = "+cds;
	if (!status.trim().equals("")) appendFilter += " and e.status = '"+status+"'";
	if (!id.trim().equals("")) appendFilter += " and e.id = "+id;
	if (!descripcion.trim().equals("")) appendFilter += " and upper(c.descripcion) like '% = upper("+descripcion+")%'";

	sql = "select e.cds, c.descripcion as cds_desc, e.compania, e.observacion, e.status, decode(e.status,'A','ACTIVO','INACTIVO') status_desc from tbl_cds_entregan_turnos e, tbl_cds_centro_servicio c where e.cds = c.codigo and e.compania = c.compania_unorg and e.compania = "+compania;

	if (request.getParameter("beginSearch")!=null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from("+sql+") ");
	}

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
document.title = 'ENTREGA DE TURNO - '+document.title;

function add(){
	abrir_ventana('../expediente/exp_centros_entregan_turnos_config.jsp');
}
function edit(id){
	abrir_ventana('../expediente/entrega_turno_config.jsp?mode=edit&id='+id);
}
function printList(){
	//abrir_ventana('../expediente/print_entrega_turno_list.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function printEntrega(i){
	var pCtrlHeader = false;
	var idTurno = $("#id_turno"+i).val();
	var idEntrega = $("#id_entrega"+i).val();
	abrir_ventana('../cellbyteWV/report_container.jsp?reportName=expediente/print_entrega_turno.rptdesign&pCtrlHeader='+pCtrlHeader+'&pTurno='+idTurno+'&pEntrega='+idEntrega);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMINISTRACION - EMAIL TO PRINTER"></jsp:param>
</jsp:include>
<table width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Centros</cellbytelabel> ]</a></authtype></td>
	</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextFilter">

					<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("beginSearch","")%>
					<td colspan="2">
						<cellbytelabel>Centro de Servicio</cellbytelabel>
						<%
							try{
							if(UserDet.getUserProfile().contains("0")){%><!--Change this line if CHSF-->
								<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId")),cds,false,false,0,"Text10",null,null,null,"T")%>
							<%}else{%>
								<%=fb.select("cds",xmlRdr.read("cds_all.xml",(String) session.getAttribute("_companyId"),false,CmnMgr.vector2numSqlInClause((java.util.Vector) session.getAttribute("_cds"))),cds,false,false,0,"Text10",null,null,null,"T")%>
							<%}
							}catch(Exception e){throw new Exception("No pudimos cargar el archivo XML. Por favor entra en Administración > Centro de Servicio y edita cualquiera para crear el archivo y vuelve a probar!");}
						%>
						&nbsp;&nbsp;<cellbytelabel>Estado</cellbytelabel>
						<%=fb.select("status","A=Activo, I=Inactivo",status,"T")%>
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
		<tr>
			<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype></td>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("cds",cds)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("id",id)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb=new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("cds",cds)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("id",id)%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td width="35%" align="left"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
			<td width="19%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="46%" align="left"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
		</tr>
		<%
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
			%>
		<%=fb.hidden("id_entrega"+i,cdo.getColValue("id"))%>
		<%=fb.hidden("id_turno"+i,cdo.getColValue("id_turno"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>[<%=cdo.getColValue("cds")%>]&nbsp;<%=cdo.getColValue("cds_desc")%></td>
			<td align="center"><%=cdo.getColValue("status_desc")%></td>
			<td align="center"><%=cdo.getColValue("observacion")%></td>
		</tr>
		<%}%>
		</table>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("cds",cds)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("id",id)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
				<%=fb.hidden("beginSearch","")%>
				<%=fb.hidden("cds",cds)%>
				<%=fb.hidden("status",status)%>
				<%=fb.hidden("id",id)%>
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