<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String id = request.getParameter("id");
String index = request.getParameter("index");
String filter = request.getParameter("filter");
String indexCta1 = request.getParameter("indexCta1");
String indexCta2 = request.getParameter("indexCta2");
String indexCta3 = request.getParameter("indexCta3");
String indexCta4 = request.getParameter("indexCta4");
String indexCta5 = request.getParameter("indexCta5");
String indexCta6 = request.getParameter("indexCta6");
String indexName = request.getParameter("indexName");

if (filter==null) filter="";

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
	String descripcion="",cta1="",cta2="",cta3="",cta4="",cta5="",cta6="";
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
	{
	appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
		descripcion = request.getParameter("descripcion");
	}
	if (request.getParameter("cta1") != null && !request.getParameter("cta1").trim().equals(""))
	{
	appendFilter += "and a.cta1 like '%"+request.getParameter("cta1").toUpperCase()+"%'";
		cta1 = request.getParameter("cta1");
	}
	if (request.getParameter("cta2") != null && !request.getParameter("cta2").trim().equals(""))
	{
	appendFilter += "and a.cta2 like '%"+request.getParameter("cta2").toUpperCase()+"%'";
		cta2 = request.getParameter("cta2");
	}
	if (request.getParameter("cta3") != null && !request.getParameter("cta3").trim().equals(""))
	{
	appendFilter += "and a.cta3 like '%"+request.getParameter("cta3").toUpperCase()+"%'";
		cta3 = request.getParameter("cta3");
	}
	if (request.getParameter("cta4") != null && !request.getParameter("cta4").trim().equals(""))
	{
	appendFilter += "and a.cta4 like '%"+request.getParameter("cta4").toUpperCase()+"%'";
		cta4 = request.getParameter("cta4");
	}
	if (request.getParameter("cta5") != null && !request.getParameter("cta5").trim().equals(""))
	{
	appendFilter += "and a.cta5 like '%"+request.getParameter("cta5").toUpperCase()+"%'";
		cta5 = request.getParameter("cta5");
	}
	if (request.getParameter("cta6") != null && !request.getParameter("cta6").trim().equals(""))
	{
	appendFilter += "and a.cta6 like '%"+request.getParameter("cta6").toUpperCase()+"%'";
		cta6 = request.getParameter("cta6");
	}


	sql= "SELECT DISTINCT a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 as ctaFinanciera, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.compania, a.descripcion, a.tipo_cuenta FROM tbl_con_catalogo_gral a, tbl_con_cla_ctas b, tbl_con_ctas_prin c, tbl_sec_compania d WHERE d.codigo=a.compania and b.codigo_clase=a.tipo_cuenta and c.codigo_prin=b.codigo_prin  and a.recibe_mov ='S' and a.status ='A' and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+filter+" order by a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.compania";

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT DISTINCT count(*) FROM ("+sql+")");

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
document.title = 'Cuenta Principal - '+document.title;

//function add(op,code1,code2,code3,code4,code5,code6,name,compId)
function setAcc(op, k)
{
	var code1 = eval('document.form1.cta1'+k).value;
	var code2 = eval('document.form1.cta2'+k).value;
	var code3 = eval('document.form1.cta3'+k).value;
	var code4 = eval('document.form1.cta4'+k).value;
	var code5 = eval('document.form1.cta5'+k).value;
	var code6 = eval('document.form1.cta6'+k).value;
	var name = eval('document.form1.descripcion'+k).value;
	var compId = eval('document.form1.compania'+k).value;

	switch(op)
	{
	case 1:
		window.opener.document.form1.cuenta1.value = code1;
		window.opener.document.form1.cuenta2.value = code2;
		window.opener.document.form1.cuenta3.value = code3;
		window.opener.document.form1.cuenta4.value = code4;
		window.opener.document.form1.cuenta5.value = code5;
		window.opener.document.form1.cuenta6.value = code6;
		window.opener.document.form1.ctaFinanciera.value = name;
		window.close();
	break;

	case 2:
		window.opener.document.form1.ctaFin1.value = code1;
		window.opener.document.form1.ctaFin2.value = code2;
		window.opener.document.form1.ctaFin3.value = code3;
		window.opener.document.form1.ctaFin4.value = code4;
		window.opener.document.form1.ctaFin5.value = code5;
		window.opener.document.form1.ctaFin6.value = code6;
		window.opener.document.form1.compId.value = compId;
		window.close();
	break;

	case 3:
		window.opener.document.form1.ctaIng1.value = code1;
		window.opener.document.form1.ctaIng2.value = code2;
		window.opener.document.form1.ctaIng3.value = code3;
		window.opener.document.form1.ctaIng4.value = code4;
		window.opener.document.form1.ctaIng5.value = code5;
		window.opener.document.form1.ctaIng6.value = code6;
		window.close();
	break;

	case 4:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.ctaFinanciera.value = name;
		window.close();
	break;

	case 5:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.catalogo.value = name;
		window.close();
	break;

	case 6:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.descripcion.value = name;
		window.opener.document.form1.cia_cta.value = <%=(String) session.getAttribute("_companyId")%>;
		window.close();
	break;

	case 7:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.descCuenta.value = name;
		window.close();
	break;

	case 8:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;

	case 9:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;

	case 10:
		eval('window.opener.document.formDetalle.<%=indexCta1%>').value = code1;
		eval('window.opener.document.formDetalle.<%=indexCta2%>').value = code2;
		eval('window.opener.document.formDetalle.<%=indexCta3%>').value = code3;
		eval('window.opener.document.formDetalle.<%=indexCta4%>').value = code4;
		eval('window.opener.document.formDetalle.<%=indexCta5%>').value = code5;
		eval('window.opener.document.formDetalle.<%=indexCta6%>').value = code6;
		eval('window.opener.document.formDetalle.<%=indexName%>').value = name;
		window.close();
	break;

	case 11:
		window.opener.document.form1.cg_cta1.value = code1;
		window.opener.document.form1.cg_cta2.value = code2;
		window.opener.document.form1.cg_cta3.value = code3;
		window.opener.document.form1.cg_cta4.value = code4;
		window.opener.document.form1.cg_cta5.value = code5;
		window.opener.document.form1.cg_cta6.value = code6;
		window.opener.document.form1.cuentaIngre.value = name;
		window.close();
	break;

	case 12:
		window.opener.document.form1.cos_cta1.value = code1;
		window.opener.document.form1.cos_cta2.value = code2;
		window.opener.document.form1.cos_cta3.value = code3;
		window.opener.document.form1.cos_cta4.value = code4;
		window.opener.document.form1.cos_cta5.value = code5;
		window.opener.document.form1.cos_cta6.value = code6;
		window.opener.document.form1.cuentaCost.value = name;
		window.close();
	break;

	case 13:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;

	case 14:
		window.opener.document.form1.cta1_a.value = code1;
		window.opener.document.form1.cta2_a.value = code2;
		window.opener.document.form1.cta3_a.value = code3;
		window.opener.document.form1.cta4_a.value = code4;
		window.opener.document.form1.cta5_a.value = code5;
		window.opener.document.form1.cta6_a.value = code6;
		window.opener.document.form1.cuentaDesc.value = name;
		window.close();
	break;

	case 15:
		window.opener.document.form1.cta1_a.value = code1;
		window.opener.document.form1.cta2_a.value = code2;
		window.opener.document.form1.cta3_a.value = code3;
		window.opener.document.form1.cta4_a.value = code4;
		window.opener.document.form1.cta5_a.value = code5;
		window.opener.document.form1.cta6_a.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;

	case 16:
		eval('window.opener.document.formDetalle.cg_1_cta1<%=index%>').value = code1;
		eval('window.opener.document.formDetalle.cg_1_cta2<%=index%>').value = code2;
		eval('window.opener.document.formDetalle.cg_1_cta3<%=index%>').value = code3;
		eval('window.opener.document.formDetalle.cg_1_cta4<%=index%>').value = code4;
		eval('window.opener.document.formDetalle.cg_1_cta5<%=index%>').value = code5;
		eval('window.opener.document.formDetalle.cg_1_cta6<%=index%>').value = code6;
		eval('window.opener.document.formDetalle.cuenta<%=index%>').value = name;
		window.close();
	break;

	case 17:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;

	case 18:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;

	case 19:
		eval('window.opener.document.formDetalle.cta1<%=index%>').value = code1;
		eval('window.opener.document.formDetalle.cta2<%=index%>').value = code2;
		eval('window.opener.document.formDetalle.cta3<%=index%>').value = code3;
		eval('window.opener.document.formDetalle.cta4<%=index%>').value = code4;
		eval('window.opener.document.formDetalle.cta5<%=index%>').value = code5;
		eval('window.opener.document.formDetalle.cta6<%=index%>').value = code6;
		eval('window.opener.document.formDetalle.cuenta<%=index%>').value = name;
		window.close();
	break;

	case 20:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;

	case 21:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuentaDesc.value = name;
		window.close();
	break;

	case 22:
		window.opener.document.form1.cta1.value = code1;
		window.opener.document.form1.cta2.value = code2;
		window.opener.document.form1.cta3.value = code3;
		window.opener.document.form1.cta4.value = code4;
		window.opener.document.form1.cta5.value = code5;
		window.opener.document.form1.cta6.value = code6;
		window.opener.document.form1.cuenta.value = name;
		window.close();
	break;
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
					<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("indexCta1",indexCta1)%>
<%=fb.hidden("indexCta2",indexCta2)%>
<%=fb.hidden("indexCta3",indexCta3)%>
<%=fb.hidden("indexCta4",indexCta4)%>
<%=fb.hidden("indexCta5",indexCta5)%>
<%=fb.hidden("indexCta6",indexCta6)%>
<%=fb.hidden("indexName",indexName)%>
<%=fb.hidden("filter",filter)%>
						<td width="30%">
							Descripci&oacute;n
							<%=fb.textBox("descripcion","",false,false,false,40,null,null,null)%>
						</td>
						<td width="70%">
							Cuenta:
							<%=fb.textBox("cta1",cta1,false,false,false,3,3)%>
							<%=fb.textBox("cta2",cta2,false,false,false,3,3)%>
							<%=fb.textBox("cta3",cta3,false,false,false,3,3)%>
							<%=fb.textBox("cta4",cta4,false,false,false,3,3)%>
							<%=fb.textBox("cta5",cta5,false,false,false,3,3)%>
							<%=fb.textBox("cta6",cta6,false,false,false,3,3)%>
							<%=fb.submit("go","Ir")%>
						</td>
<%=fb.formEnd()%>
					</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("indexCta1",indexCta1)%>
<%=fb.hidden("indexCta2",indexCta2)%>
<%=fb.hidden("indexCta3",indexCta3)%>
<%=fb.hidden("indexCta4",indexCta4)%>
<%=fb.hidden("indexCta5",indexCta5)%>
<%=fb.hidden("indexCta6",indexCta6)%>
<%=fb.hidden("indexName",indexName)%>
<%=fb.hidden("filter",filter)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("indexCta1",indexCta1)%>
<%=fb.hidden("indexCta2",indexCta2)%>
<%=fb.hidden("indexCta3",indexCta3)%>
<%=fb.hidden("indexCta4",indexCta4)%>
<%=fb.hidden("indexCta5",indexCta5)%>
<%=fb.hidden("indexCta6",indexCta6)%>
<%=fb.hidden("indexName",indexName)%>
<%=fb.hidden("filter",filter)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
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
					<td width="5%">&nbsp;</td>
					<td width="25%">C&oacute;digo</td>
					<td width="70%">Descripci&oacute;n</td>
				</tr>
				<%
				fb = new FormBean("form1");
				%>
					<%=fb.formStart()%>
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
					<%=fb.hidden("cta1"+i,cdo.getColValue("cta1"))%>
					<%=fb.hidden("cta2"+i,cdo.getColValue("cta2"))%>
					<%=fb.hidden("cta3"+i,cdo.getColValue("cta3"))%>
					<%=fb.hidden("cta4"+i,cdo.getColValue("cta4"))%>
					<%=fb.hidden("cta5"+i,cdo.getColValue("cta5"))%>
					<%=fb.hidden("cta6"+i,cdo.getColValue("cta6"))%>
					<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
					<%=fb.hidden("compania"+i,cdo.getColValue("compania"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setAcc(<%=id%>,<%=i%>)" style="cursor:pointer">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td align="center"><%=cdo.getColValue("ctaFinanciera")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
				</tr>
				<%
				}
				%>
					<%=fb.formEnd()%>
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
<%fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("indexCta1",indexCta1)%>
<%=fb.hidden("indexCta2",indexCta2)%>
<%=fb.hidden("indexCta3",indexCta3)%>
<%=fb.hidden("indexCta4",indexCta4)%>
<%=fb.hidden("indexCta5",indexCta5)%>
<%=fb.hidden("indexCta6",indexCta6)%>
<%=fb.hidden("indexName",indexName)%>
<%=fb.hidden("filter",filter)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
<%fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());%>
<%=fb.formStart()%>
<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("indexCta1",indexCta1)%>
<%=fb.hidden("indexCta2",indexCta2)%>
<%=fb.hidden("indexCta3",indexCta3)%>
<%=fb.hidden("indexCta4",indexCta4)%>
<%=fb.hidden("indexCta5",indexCta5)%>
<%=fb.hidden("indexCta6",indexCta6)%>
<%=fb.hidden("indexName",indexName)%>
<%=fb.hidden("filter",filter)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("cta1",cta1)%>
<%=fb.hidden("cta2",cta2)%>
<%=fb.hidden("cta3",cta3)%>
<%=fb.hidden("cta4",cta4)%>
<%=fb.hidden("cta5",cta5)%>
<%=fb.hidden("cta6",cta6)%>
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