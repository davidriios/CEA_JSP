<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="java.util.ArrayList" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
String appendFilter = "";
ArrayList al = new ArrayList();
int rowCount = 0;
String descripcion = request.getParameter("descripcion");
String abreviatura = request.getParameter("abreviatura");
String tipo = request.getParameter("tipo");

if (request.getMethod().equalsIgnoreCase("GET"))
{
		int recsPerPage = 100;
		String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";

		if (request.getParameter("searchQuery") != null){
				nextVal = request.getParameter("nextVal");
				previousVal = request.getParameter("previousVal");
				if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
				if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
				if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
				if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
				if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
				if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
		}

		if (descripcion == null) descripcion = "";
		if (abreviatura == null) abreviatura = "";
		if (tipo == null) tipo = "";

		if (!descripcion.trim().equals("")) appendFilter += " and upper(descripcion) like upper('%"+descripcion+"%')";
		if (!abreviatura.trim().equals("")) appendFilter += " and upper(abreviatura) like upper('%"+abreviatura+"%')";
		if (!tipo.trim().equals("")) appendFilter += " and tipo = '"+tipo+"'";

		StringBuffer sb = new StringBuffer();
		sb.append("select codigo, abreviatura, descripcion, tipo, decode(tipo, 'A', 'APROBADAS', 'N', 'NO APROBADAS') tipo_desc from tbl_sal_abreviaturas where estado = 'A'");
		sb.append(appendFilter);
		sb.append(" order by tipo ");

		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sb.toString()+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sb.toString()+")");

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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<script>
var forceCapitalize=false;
$(function(){
		$("select#tipo").addClass("form-control input-sm");
});
</script>
</head>
<body class="body-form" style="padding-top: 0 !important;">
<div class="row">
		<div class="table-responsive" data-pattern="priority-columns" style="margin:10px auto">
				<table cellspacing="0" width="100%" class="table table-bordered table-striped">
						<tr class="bg-headtabla2">
								<td>ABREVIATURAS</td>
						</tr>
				</table>

				<table width="99%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean2("search00",request.getContextPath()+request.getServletPath());%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>

				<tr>
						<td class="controls form-inline">
								<b>Abreviatura:</b>
								<%=fb.textBox("abreviatura","",false,false,false,0,"form-control input-sm",null,null)%>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<b>Descripci&oacute;n:</b>
								<%=fb.textBox("descripcion","",false,false,false,0,"form-control input-sm",null,null)%>

								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<b><cellbytelabel id="4">Tipo:</cellbytelabel></b>
				<%=fb.select("tipo","A=APROBADAS, N=NO APROBADAS",tipo,"T")%>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<%=fb.submit("go","IR",true,false,"btn btn-inverse btn-sm",null,null)%>
						</td>
				</tr>

				<%=fb.formEnd()%>
			 </table>


						<table cellspacing="0" width="100%" class="table table-bordered table-striped">
								<tr>
										<td colspan="4">
												<table align="center" width="100%" cellpadding="1" cellspacing="0">
														<tr class="TextPager">
<%fb = new FormBean2("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("abreviatura",abreviatura)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("tipo",tipo)%>
																<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
																<td width="40%"><b><cellbytelabel id="3">&nbsp;Total Registro(s)</cellbytelabel> <%=rowCount%></b></td>
																<td width="40%" align="right"><b><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></b>&nbsp;</td>
<%fb = new FormBean2("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("abreviatura",abreviatura)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("tipo",tipo)%>
																<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
														</tr>
												</table>
										</td>
								</tr>

								<tr class="bg-headtabla">
										<td>C&oacute;digo</td>
										<td>Abreviatura</td>
										<td>Descripci&oacute;n</td>
										<td>Tipo</td>
								</tr>
								<%for (int i = 0; i < al.size(); i++){%>
										<%cdo = (CommonDataObject) al.get(i);%>
										<tr>
												<td><%=cdo.getColValue("codigo")%></td>
												<td><%=cdo.getColValue("abreviatura")%></td>
												<td><%=cdo.getColValue("descripcion")%></td>
												<td><%=cdo.getColValue("tipo_desc")%></td>
										</tr>
								<%}%>
								<tr>
										<td colspan="4">
												<table align="center" width="100%" cellpadding="1" cellspacing="0">
														<tr class="TextPager">
<%fb = new FormBean2("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("abreviatura",abreviatura)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("tipo",tipo)%>
																<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
																<td width="40%"><b><cellbytelabel id="3">&nbsp;Total Registro(s)</cellbytelabel> <%=rowCount%></b></td>
																<td width="40%" align="right"><b><cellbytelabel id="4">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="5">hasta</cellbytelabel> <%=nVal%></b>&nbsp;</td>
<%fb = new FormBean2("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
<%=fb.hidden("abreviatura",abreviatura)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("tipo",tipo)%>
															 <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>",false,false,"form-control input-sm",null,null):""%></td>
<%=fb.formEnd()%>
														</tr>
												</table>
										</td>
								</tr>
						</table>
		</div>
</div>

</body>
</html>
<%
}
%>