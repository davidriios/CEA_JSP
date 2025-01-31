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
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
String tipoCliente = request.getParameter("tipoCliente");
String codigo = request.getParameter("codigo");
String compania = request.getParameter("compania");
String anio = request.getParameter("anio");
String referTo = request.getParameter("referTo");
String fecha = request.getParameter("fecha");

if (fp == null) fp = "";
if (fg == null) fg = "";
if (mode == null) mode = "add";
if (tipoCliente == null) tipoCliente = "";
if (referTo == null) referTo = "";
if (fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

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
	String name = request.getParameter("name");
	String dob = request.getParameter("dob");
	String pCode = request.getParameter("pCode");
	String ruc = request.getParameter("ruc");
	String Refer_To = request.getParameter("Refer_To");

	if (code == null) code = "";
	if (name == null) name = "";
	if (Refer_To == null) Refer_To = "";
	if (!code.trim().equals("")) {
		sbFilter.append(" and codigo like '"); 
		sbFilter.append(code); 
		sbFilter.append("%'"); 
	}
	if (!Refer_To.trim().equals("")) {
		sbFilter.append(" and refer_to = '"); 
		sbFilter.append(Refer_To); 
		sbFilter.append("'"); 
	}
	if (!name.trim().equals("")) {
		sbFilter.append(" and upper(nombre) like '%"); 
		sbFilter.append(name.toUpperCase()); 
		sbFilter.append("%'"); 
	}
	if (dob == null) dob = "";
	if (pCode == null) pCode = "";
	if (ruc == null) ruc = "";
	if (!ruc.trim().equals("")){
		sbFilter.append(" and ruc like '"); 
		sbFilter.append(ruc); 
		sbFilter.append("%'"); 
	}

	sbSql = new StringBuffer();
	sbSql.append("select compania, ref_id, ref_desc, refer_to, codigo, nombre, to_char(fecha_nac, 'dd/mm/yyyy') fecha_nacimiento, ruc, dv from vw_fac_otros_clientes a where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter.toString());
	sbSql.append(" order by ref_desc, nombre");


	if (sbSql.length() > 0){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
	}
	else System.out.println("* * *   There is not sql statement to execute!   * * *");

		

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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Common - '+document.title;

function setValue(i){
	<%
	if(fp.equals("cargo_dev_oc")){%>
		window.opener.document.form0.client_id.value = eval('document.detail.codigo'+i).value;
		window.opener.document.form0.client_name.value = eval('document.detail.nombre'+i).value;
		window.opener.document.form0.ref_id.value = eval('document.detail.ref_id'+i).value;
		window.opener.document.form0.refer_to.value = eval('document.detail.refer_to'+i).value;
		window.opener.document.form0.ruc.value = eval('document.detail.ruc'+i).value;
		window.opener.document.form0.dv.value = eval('document.detail.dv'+i).value;
		window.opener.chkArt();
	<%
		}
	%>
	window.close();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE COMPA&Ntilde;&Iacute;A"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("compania",compania)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("fecha",fecha)%>
				<tr class="TextFilter">
					<td>
					Tipo:
					<%=fb.select(ConMgr.getConnection(),"select refer_to, descripcion from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion","Refer_To",Refer_To,false,false,0, "text10", "", "", "", "T")%>
					C&oacute;digo&nbsp;
					<%=fb.textBox("code","",false,false,false,20,20,"Text10",null,null)%>
					Nombre
					<%=fb.textBox("name","",false,false,false,50,"Text10",null,null)%>
					RUC:
					<%=fb.textBox("ruc","",false,false,false,10,"Text10",null,null)%>
					Fecha Nac.:
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="dd/mm/yyyy"/>
						<jsp:param name="nameOfTBox1" value="dob" />
						<jsp:param name="valueOfTBox1" value="" />
					</jsp:include>
					<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
					</td>
				</tr>
				<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;</td>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
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
				<td>Nombre</td>
				<td>C&oacute;digo</td>
				<td>RUC</td>
				<td>DV</td>
			</tr>
			<%
			fb = new FormBean("detail","","post","");
			%>
			<%=fb.formStart()%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("fp",fp)%>
			<%
			String refer_to = "";
			for (int i=0; i<al.size(); i++){
				CommonDataObject cdo = (CommonDataObject) al.get(i);
				String color = "TextRow02";
				if (i % 2 == 0) color = "TextRow01";
			%>
				<%=fb.hidden("ref_id"+i,cdo.getColValue("ref_id"))%>
				<%=fb.hidden("refer_to"+i,cdo.getColValue("refer_to"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("ruc"+i,cdo.getColValue("ruc"))%>
				<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
				<%if(i!=0 && !refer_to.equals(cdo.getColValue("refer_to"))){%>
				<tr class="TextRow03">			
					<td colspan = "4"><%=cdo.getColValue("ref_desc")%></td>
				</tr>
				<%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:setValue('<%=i%>')">			
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("ruc")%></td>
					<td><%=cdo.getColValue("dv")%></td>
				</tr>
			<%
			refer_to=cdo.getColValue("refer_to");
			}
			%>
			<%=fb.hidden("keySize",""+al.size())%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%=rowCount%></td>
				<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("referTo",referTo)%>
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("Refer_To",Refer_To)%>
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
