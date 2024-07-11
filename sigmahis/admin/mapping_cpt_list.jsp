<%@page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
CommonDataObject cdo = new CommonDataObject();

String appendFilter = "";

String status = request.getParameter("status")==null?"":request.getParameter("status");
String revenueCode = request.getParameter("revenuecode")==null?"":request.getParameter("revenuecode");
String description = request.getParameter("description")==null?"":request.getParameter("description");

if (!status.trim().equals("")) appendFilter += " and status = '"+status+"'";
if (!revenueCode.trim().equals("")) appendFilter += " and code = '"+revenueCode+"'";
if (!description.trim().equals("")) appendFilter += " and description like '%"+description+"%'";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (request.getParameter("beginSearch") != null )
		al = SQLMgr.getDataList("select id as revenueid, code as revenuecode, adm_type,  decode(adm_type,'I','INPATIENT HOSPITAL','O','OUTPATIENT HOSPITAL','INPATIENT HOSPITAL / OUTPATIENT HOSPITAL') as adm_type_desc,cds,ts,description,comments,status, decode(status,'A','ACTIVO','I','INACTIVO') as status_desc from tbl_map_axa_revenue where id is not null "+appendFilter);
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script type="text/javascript">
	document.title = 'ADMINISTRACIÓN - MAPPING CPT '+document.title;
	function doAction(){}
	function edit(revId){abrir_ventana("../admin/mapping_cpt.jsp?mode=edit&revenueId="+revId);}
	function add(){abrir_ventana("../admin/mapping_cpt.jsp?mode=add");}
function showRep(){abrir_ventana('../cellbyteWV/report_container.jsp?reportName=admin/mapping_cpt.rptdesign&pCtrlHeader=false&pId=<%=revenueCode%>&pDescripcion=<%=description%>&pEstado=<%=status%>');}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="ADMINISTRACIÓN - MAPPING CPT"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextFilter">
			<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("beginSearch","")%>
				<td>
					Mapping AXA
					<%=fb.textBox("revenuecode",revenueCode,false,false,false,10)%>
					Descripci&oacute;n&nbsp;&nbsp;
					<%=fb.textBox("description",description,false,false,false,40)%>
					Estado&nbsp;&nbsp;
					<%=fb.select("status","A=ACTIVO,I=INACTIVO",status,"T")%>
					<%=fb.submit("go","Ir")%>
				</td>
			<%=fb.formEnd()%>
			</tr>
			</table>
		</td>
	</tr>
	
	<tr>
		<td align="right">
			<authtype type='1'><a href="javascript:showRep()" class="Link00">[ Imprimir]</a></authtype> 
			<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Mapping]</a></authtype>
		</td>
	</tr>

	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
			 <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			 <%=fb.formStart(true)%>
			 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			 <%=fb.hidden("baction","")%>
			 <tr class="TextHeader" >
				<td colspan="6">MAPPING CPT</td>
			 </tr>
			 <tr class="TextHeader">
				<td width="10%">Mapping AXA</td>
				<td width="28%">Descripci&oacute;n</td>
				<td width="22%">Lugar de Servicio</td>
				<td width="28%">Comentario</td>
				<td width="7%" align="center">Estado</td>
				<td width="5%">&nbsp;</td>
			 </tr> 
			 <%
				for ( int i = 0; i<al.size(); i++ ){ 
					cdo = (CommonDataObject) al.get(i);
					String color = i%2==0?"TextRow01":"TextRow02";
			%>
					<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
						<td><%=cdo.getColValue("revenuecode")%></td>
						<td><%=cdo.getColValue("description")%></td>
						<td><%=cdo.getColValue("adm_type_desc")%></td>
						<td><%=cdo.getColValue("comments")%></td>
						<td align="center"><%=cdo.getColValue("status_desc")%></td>
						<td align="center">
							<a href="javascript:edit(<%=cdo.getColValue("revenueid")%>)" class="Link00Bold">Editar</a>
						</td>
					</tr>
			 <%	
			 } // for i
			 %>
			<%=fb.formEnd(true)%>
			</table>
	    </td>
	</tr>
</table>
</body>
</html>
<%}%>