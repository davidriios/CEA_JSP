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
int rowCount = 0;

String appendFilter = "";

String patientId = request.getParameter("patient_id")==null?"":request.getParameter("patient_id");
String patientName = request.getParameter("patient_name")==null?"":request.getParameter("patient_name");
String subsNo = request.getParameter("subs_no")==null?"":request.getParameter("subs_no");

if (!patientId.trim().equals("")) appendFilter += " and aa.axa_cedula = '"+patientId.trim()+"' or aa.cb_cedula = '"+patientId+"'";
if (!patientName.trim().equals("")) appendFilter += " and aa.axa_paciente_nombre like '%"+patientName.trim()+"%' or aa.cb_nombre_paciente like '%"+patientName+"%'";
if (!subsNo.trim().equals("")) appendFilter += " and aa.axa_subs_no = '"+subsNo+"' or aa.cb_subs_no = '"+subsNo.trim()+"'";

if (request.getMethod().equalsIgnoreCase("GET"))
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
	
	if (request.getParameter("beginSearch") != null ){
	
		String sql = "select aa.axa_subs_no, aa.axa_primer_nombre, aa.axa_segundo_nombre, aa.axa_subs_type, aa.axa_cedula, aa.axa_paciente_nombre, aa.cb_subs_no, aa.cb_nombre_paciente, aa.cb_cedula from (select a.b_col as axa_subs_no, a.c_col as axa_primer_nombre, a.d_col as axa_segundo_nombre, a.h_col as axa_subs_type, a.c_col||' '||a.d_col as axa_paciente_nombre, a.p_col as axa_cedula, p.apartado_postal as cb_subs_no,p.nombre_paciente as cb_nombre_paciente, p.id_paciente as cb_cedula from vw_adm_paciente p, axa_elig_report a where a.b_col = p.apartado_postal(+) order by 2,3 )aa where 1=1 "+appendFilter;
	
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+") ");
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
<script type="text/javascript">
	document.title = 'FACTURACION - AXA ELIG REPORT '+document.title;
	$(document).ready(function(r){
	  $("#subs_no, #patient_name, #patient_id").click(function(c){
	     $(this).select();
	  });
	});
	function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" onLoad="javascript:doAction()">
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
					Nombre Paciente
					<%=fb.textBox("patient_name",patientName,false,false,false,40)%>
					C&eacute;dula
					<%=fb.textBox("patient_id",patientId,false,false,false,10)%>
					N&uacute;mero suscriptor
					<%=fb.textBox("subs_no",subsNo,false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
			<%=fb.formEnd()%>
			</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
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
			<%=fb.hidden("patient_id",patientId)%>
			<%=fb.hidden("patient_name",patientName)%>
			<%=fb.hidden("subs_no",subsNo)%>
			<%=fb.hidden("beginSearch","")%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
			<%=fb.formEnd()%>
			<td width="40%">Total Registro(s) <%=rowCount%></td>
			<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
			<%=fb.hidden("patient_id",patientId)%>
			<%=fb.hidden("patient_name",patientName)%>
			<%=fb.hidden("subs_no",subsNo)%>
			<%=fb.hidden("beginSearch","")%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
			<%=fb.formEnd()%>
			</tr>
			</table>
		</td>
	</tr>	
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="1" >
			 <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			 <%=fb.formStart(true)%>
			 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			 <%=fb.hidden("baction","")%>
			 <tr class="TextHeader" align="center">
				<td colspan="4" width="50%">AXA</td>
				<td colspan="4" width="50%">Sistema</td>
			 </tr>
			 <tr class="TextHeader">
				<td width="7%">No Subs</td>
				<td width="25%">Nombre</td>
				<td width="8%">C&eacute;dula</td>
				<td width="10%">Tipo</td>
						
				<td width="7%">No Subs</td>
				<td width="25%">Nombre</td>
				<td width="8%">C&eacute;dula</td>
				<td width="10%">Tipo</td>
			 </tr> 
				<%
				for ( int i = 0; i<al.size(); i++ ){ 
					cdo = (CommonDataObject) al.get(i);
					String color = i%2==0?"TextRow01":"TextRow02";
				%>
					<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
						<td><%=cdo.getColValue("axa_subs_no")%></td>
						<td><%=cdo.getColValue("axa_paciente_nombre")%></td>
						<td><%=cdo.getColValue("axa_cedula")%></td>
						<td><%=cdo.getColValue("axa_subs_type")%></td>
						
						<td><%=cdo.getColValue("cb_subs_no")%>&nbsp;</td>
						<td><%=cdo.getColValue("cb_nombre_paciente")%>&nbsp;</td>
						<td><%=cdo.getColValue("cb_cedula")%>&nbsp;</td>
						<td>-</td>
					</tr>
			 <%	
			 } // for i
			 %>
			<%=fb.formEnd(true)%>
			</table>
	    </td>
	</tr>
	
	<tr>
	<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">
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
		<%=fb.hidden("patient_id",patientId)%>
			<%=fb.hidden("patient_name",patientName)%>
			<%=fb.hidden("subs_no",subsNo)%>
			<%=fb.hidden("beginSearch","")%>
		<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
		<%=fb.formEnd()%>
		<td width="40%">Total Registro(s) <%=rowCount%></td>
		<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
	<%=fb.hidden("patient_id",patientId)%>
			<%=fb.hidden("patient_name",patientName)%>
			<%=fb.hidden("subs_no",subsNo)%>
			<%=fb.hidden("beginSearch","")%>
		<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
		<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%}%>