<%@ page errorPage="../error.jsp"%>
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
String fg = request.getParameter("fg");
String mode = request.getParameter("mode");
if (fp == null) fp = "";
if (fg == null) fg = "";
if (mode == null) mode = "add";

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

	String Refer_To = request.getParameter("Refer_To");
	String code = request.getParameter("code");
	String name = request.getParameter("name");
	String ruc = request.getParameter("ruc");
	String dob = request.getParameter("dob");
	String tipoCliente = request.getParameter("tipoCliente");
	String estado = request.getParameter("estado");

	if (Refer_To == null) Refer_To = "";
	if (code == null) code = "";
	if (name == null) name = "";
	if (ruc == null) ruc = "";
	if (dob == null) dob = "";
	if (tipoCliente == null) tipoCliente = "";
	if (estado == null) estado = "";
	if (!code.trim().equals("")) {
		sbFilter.append(" and codigo like '");
		sbFilter.append(code);
		sbFilter.append("%'");
	}
	if (!name.trim().equals("")) {
		sbFilter.append(" and upper(descripcion) like '%");
		sbFilter.append(name.toUpperCase());
		sbFilter.append("%'");
	}
	if (!ruc.trim().equals("")){
		sbFilter.append(" and ruc like '");
		sbFilter.append(ruc);
		sbFilter.append("%'");
	}
	if (!tipoCliente.trim().equals("")) {
		sbFilter.append(" and tipo_cliente = ");
		sbFilter.append(tipoCliente);
	}
	if (!estado.trim().equals("")) {
		sbFilter.append(" and estado = '");
		sbFilter.append(estado);
		sbFilter.append("'");
	}

	sbSql = new StringBuffer();
	sbSql.append("select forma_pago, tipo_cliente, dias_cr_limite, nvl(monto_cr_limite, 0) monto_cr_limite, codigo, descripcion, cliente_alquiler, compania, aplica_descuento, dv, ruc, colaborador, decode(forma_pago, 'CR', 'Credito', 'CO', 'Contado', forma_pago) forma_pago_desc, decode(dias_cr_limite, 0, '', 1, '15 Dias', 2, '30 Dias', 3, '45 Dias', 4, '60 Dias', 5, '90 Dias', 6, '120 Dias') dias_cr_limite_desc, decode(aplica_descuento, 'Y', 'Si', 'No') permite_descuento_desc, (select descripcion from tbl_cxc_tipo_otro_cliente where compania = p.compania and id = p.tipo_cliente) tipo_cliente_desc from tbl_cxc_cliente_particular p where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" order by descripcion");

	if (sbSql.length() > 0){
		StringBuffer sbTmp = new StringBuffer();
		sbTmp.append("select * from (select rownum as rn, a.* from (").append(sbSql).append(") a) where rn between ").append(previousVal).append(" and ").append(nextVal);
		al = SQLMgr.getDataList(sbTmp.toString());
		sbTmp = new StringBuffer();
		sbTmp.append("select count(*) from (").append(sbSql).append(")");
		rowCount = CmnMgr.getCount(sbTmp.toString());
	}
	else System.out.println("* * *   There is not sql statement to execute!   * * *");

	sbSql = new StringBuffer();
	sbSql.append("select get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(", 'TP_CLIENTE_OTROS') ref_id from dual");
	CommonDataObject cdoOC = SQLMgr.getData(sbSql.toString());
	if(cdoOC==null){
		cdoOC = new CommonDataObject();
		cdoOC.addColValue("ref_id", "");
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Common - '+document.title;

function add(){
	showPopWin('../pos/add_cliente.jsp?mode=add&fp=list_otros_clientes&ref_id=<%=cdoOC.getColValue("ref_id")%>&refer_to=CXCO',winWidth*.80,_contentHeight*.80,null,null,'');
}

function edit(codigo){
	showPopWin('../pos/add_cliente.jsp?mode=edit&fp=list_otros_clientes&ref_id=<%=cdoOC.getColValue("ref_id")%>&refer_to=CXCO&codigo='+codigo,winWidth*.80,_contentHeight*.80,null,null,'');
}
function printList(){abrir_ventana('../cellbyteWV/report_container.jsp?reportName=pos/rpt_list_otros_clientes.rptdesign&pCtrlHeader=False&code=<%=code%>&name=<%=name%>&ruc=<%=ruc%>&tipoCliente=<%=tipoCliente%>&estado=<%=estado%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE COMPA&Ntilde;&Iacute;A"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo ]</a></authtype></td>
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
				<tr class="TextFilter">
					<td>
					<!--Tipo:-->
					<%//=fb.select(ConMgr.getConnection(),"select refer_to, descripcion from tbl_fac_tipo_cliente where es_clt_cr = 'S' and compania = "+(String) session.getAttribute("_companyId")+" order by descripcion","Refer_To",Refer_To,false,false,0, "text10", "", "", "", "T")%>
					C&oacute;digo&nbsp;
					<%=fb.textBox("code",code,false,false,false,12,20,"Text10",null,null)%>
					Nombre
					<%=fb.textBox("name",name,false,false,false,34,"Text10",null,null)%>
					RUC:
					<%=fb.textBox("ruc",ruc,false,false,false,10,"Text10",null,null)%>
					<!--Fecha Nac.:
					<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="1"/>
						<jsp:param name="format" value="dd/mm/yyyy"/>
						<jsp:param name="nameOfTBox1" value="dob" />
						<jsp:param name="valueOfTBox1" value="<%=dob%>" />
					</jsp:include>-->
					Tipo Otro Cliente:
					<%=fb.select(ConMgr.getConnection(), "select id, descripcion from tbl_cxc_tipo_otro_cliente where compania = "+session.getAttribute("_companyId"), "tipoCliente", tipoCliente, false, false, 0, "text12", "", "", "", "T")%>
					Estado:
					<%=fb.select("estado","A=Activo,I=Inactivo",estado,false,false,0,"Text12",null,null,"","S")%>
					<%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
					</td>
				</tr>
				<%=fb.formEnd()%>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>&nbsp;</td>
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
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("estado",estado)%>
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
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("estado",estado)%>
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
				<td width="33%">Tipo Cliente</td>
				<td width="33%">Nombre</td>
				<td width="8%">C&oacute;digo</td>
				<td width="10%">RUC</td>
				<td width="4%">DV</td>
				<td width="10%">Forma Pago</td>
				<td width="10%">D&iacute;as Cr&eacute;dito</td>
				<td width="10%">Monto Cr&eacute;dito</td>
				<td width="10%">Permite Descuento</td>
				<td width="5%">&nbsp;</td>
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
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:setValue('<%=i%>')" align="center">
					<td align="left"><%=cdo.getColValue("tipo_cliente_desc")%></td>
					<td align="left"><%=cdo.getColValue("descripcion")%></td>
					<td><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("ruc")%></td>
					<td><%=cdo.getColValue("dv")%></td>
					<td><%=cdo.getColValue("forma_pago_desc")%></td>
					<td><%=cdo.getColValue("dias_cr_limite_desc")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_cr_limite"))%></td>
					<td><%=cdo.getColValue("permite_descuento_desc")%></td>
					<td><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="positive"><font class="Link00">Editar</font></a></authtype></td>
				</tr>
			<%
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
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("estado",estado)%>
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
				<%=fb.hidden("code",code)%>
				<%=fb.hidden("name",name)%>
				<%=fb.hidden("ruc",ruc)%>
				<%=fb.hidden("dob",dob)%>
				<%=fb.hidden("tipoCliente",tipoCliente)%>
				<%=fb.hidden("estado",estado)%>
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
