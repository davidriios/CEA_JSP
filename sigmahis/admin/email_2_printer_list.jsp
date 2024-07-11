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
String email = request.getParameter("email")==null?"":request.getParameter("email");
String cds = request.getParameter("cds")==null?"":request.getParameter("cds");
String status = request.getParameter("status")==null?"":request.getParameter("status");
String tipo = request.getParameter("tipo")==null?"":request.getParameter("tipo");
String code = request.getParameter("code")==null?"":request.getParameter("code");

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

		if (!email.trim().equals("")) appendFilter += " and a.email like '%"+email+"%'";
	if (!cds.trim().equals("")) appendFilter += " and a.centro_servicio = "+cds;
	if (!status.trim().equals("")) appendFilter += " and a.status = '"+status+"'";
	if (!tipo.trim().equals("")) appendFilter += " and a.tipo = '"+tipo+"'";
	if (!code.trim().equals("")) appendFilter += " and a.id = "+code;

	sql = "select a.id, a.centro_servicio, c.descripcion as centro_servicio_desc, a.tipo, decode(a.tipo,'R','RECETAS',a.tipo) as tipo_desc, a.email, a.status,decode(a.status,'A','Activo','I','Inactivo',a.status) as status_desc, a.observacion, a.descripcion from tbl_email_to_printer a, tbl_cds_centro_servicio c where a.centro_servicio = c.codigo "+appendFilter;

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
document.title = 'EMAIL TO PRINTER - '+document.title;

function add(){abrir_ventana('../admin/email_2_printer_config.jsp');}
function edit(id, cds, tipo){abrir_ventana('../admin/email_2_printer_config.jsp?mode=edit&code='+id+'&cds='+cds+'&tipo='+tipo);}
function printList(){abrir_ventana('../admin/print_email_2_printer_list.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
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
		<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Nueva Impresora</cellbytelabel> ]</a></authtype></td>
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
						<cellbytelabel>Email</cellbytelabel>
						<%=fb.textBox("email","")%>
						<cellbytelabel>Estado</cellbytelabel>
						<%=fb.select("status","A=Activo,I=Inactivo",status,"T")%>
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
				<%=fb.hidden("email",email)%>
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
				<%=fb.hidden("email",email)%>
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
		<tr class="TextHeader" align="center">
			<td width="5%">ID</td>
			<td width="30%" align="left"><cellbytelabel>Centro de Servicio</cellbytelabel></td>
			<td width="20%" align="left"><cellbytelabel>Email</cellbytelabel></td>
			<td width="26%" align="left"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="7%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="7%" align="center"><cellbytelabel>Tipo</cellbytelabel></td>
			<td width="5%" align="center">&nbsp;</td>
		</tr>
		<%
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
			%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("id")%></td>
			<td><%=cdo.getColValue("centro_servicio_desc")%></td>
			<td><%=cdo.getColValue("email")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("status_desc")%></td>
			<td align="center"><%=cdo.getColValue("tipo_desc")%></td>
			<td align="center">&nbsp;<authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("id")%>,<%=cdo.getColValue("centro_servicio")%>,'<%=cdo.getColValue("tipo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Editar</cellbytelabel></a></authtype></td>
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
				<%=fb.hidden("email",email)%>
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
				<%=fb.hidden("email",email)%>
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
