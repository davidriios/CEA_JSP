<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/*------------------------------------------------------------------------------------------------*/
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
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
String fp= request.getParameter("fp");
String index = request.getParameter("index");
String nt = request.getParameter("nt");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
String tipo_docto = request.getParameter("tipo_docto");
String codigo = request.getParameter("codigo");
String paciente = request.getParameter("paciente");
String impreso = request.getParameter("impreso");

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();

int iconHeight = 20;
int iconWidth = 20;

if(fecha_ini==null) fecha_ini = "";
if(fecha_fin==null) fecha_fin = "";
if(tipo_docto==null) tipo_docto = "";
if(codigo==null) codigo = "";
if(paciente==null) paciente = "";
if(impreso==null) impreso = "N";

if(request.getMethod().equalsIgnoreCase("GET"))
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

  if (!codigo.trim().equals("")){
    sbFilter.append(" and a.doc_no like'%");
		sbFilter.append(codigo);
		sbFilter.append("%'");
  }
  if (!paciente.trim().equals("")){
    sbFilter.append(" and upper(a.client_name) like '%");
		sbFilter.append(paciente);
		sbFilter.append("%'");
  }
  if (!fecha_ini.trim().equals("")){
    sbFilter.append(" and trunc(a.doc_date) >= to_date('");
		sbFilter.append(fecha_ini);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
  if (!fecha_fin.trim().equals("")){
    sbFilter.append(" and trunc(a.doc_date) <= to_date('");
		sbFilter.append(fecha_fin);
		sbFilter.append("', 'dd/mm/yyyy')");
  }
	if (!tipo_docto.trim().equals("")){
    sbFilter.append(" and doc_type = '");
		sbFilter.append(tipo_docto);
		sbFilter.append("'");
  }
	/*
	if (!impreso.trim().equals("")){
    sbFilter.append(" and nvl(impreso, 0) = ");
		sbFilter.append(impreso);
  }
	*/
	sbSql.append("select ruc, dv, client_ref_id, cod_caja, turno, centro_servicio, tipo_factura, cod_cajero, (select id from tbl_fac_dgi_documents d where codigo = a.doc_no and d.tipo_docto in ('FACP','NCP','NDP')) doc_id, doc_no, to_char(doc_date, 'dd/mm/yyyy') docto_date, doc_type, reference_id, reference_no, to_char(expiration, 'dd/mm/yyyy') expiration, delivery_address, client_id, client_name, company_id, status, observations, gross_amount, gross_amount_gravable, total_discount, total_discount_gravable, sub_total, sub_total_gravable, pay_tax, tax_percent, tax_amount, total_charges, net_amount, created_by, to_char(sys_date, 'dd/mm/yyyy') sys_date, modified_by, to_char(modified_date, 'dd/mm/yyyy') modified_date, printed, printed_no, printed_by, to_char(printed_date, 'dd/mm/yyyy') printed_date, other1, other2, other3, other4, other5, client_type, decode(a.doc_type, 'FAC', 'FACT', 'NCR', 'NC', 'NDB', 'ND') tipo_docto_dgi from tbl_fac_trx a where a.company_id = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	if (!impreso.trim().equals("")){
    sbSql.append(" and nvl(printed, '0') = ");
		sbSql.append(impreso);
  }
		
		sbSql.append(sbFilter.toString());

		sbSql.append(" order by doc_date desc, doc_id desc");

		if(request.getParameter("impreso") != null){
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
		System.out.println("sbFilter.toString()="+sbFilter.toString());
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Facturas - '+document.title;

function printFact(i, flag)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto_dgi'+i).value;
	var ruc = eval('document.form0.ruc_cedula'+i).value;
if(flag=='2') abrir_ventana('../pos/ver_impresion_dgi.jsp?fp=docto_dgi_list&actType=2&docType=DGI&docId='+id+'&docNo='+codigo+'&tipo='+tipo_docto+'&ruc='+ruc);	
else if(flag=='1') showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=2&docType=DGI&docId='+id+'&docNo='+codigo+'&tipo='+tipo_docto+'&ruc='+ruc,winWidth*.75,winHeight*.90,null,null,'');
else if(flag=='5') showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=5&docType=DGI&docId='+id+'&docNo='+codigo+'&tipo='+tipo_docto+'&ruc='+ruc,winWidth*.75,winHeight*.90,null,null,'');
}

function goOption(x)
{
	if(x==1) showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=3&docType=DGI'+'&docNo=X',winWidth*.75,winHeight*.65,null,null,'');
	else if(x==2) showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=4&docType=DGI'+'&docNo=X',winWidth*.75,winHeight*.65,null,null,'');
}

function printDoct(i)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto'+i).value;
	var ruc = eval('document.form0.ruc_cedula'+i).value;
	abrir_ventana('../facturacion/print_fact.jsp?fp=docto_dgi_list&actType=2&docType=DGI&docId='+id+'&docNo='+codigo+'&tipo='+tipo_docto+'&ruc='+ruc,winWidth*.75,winHeight*.65,null,null,'');
}
function mouseOver(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	var msg='&nbsp;';
	switch(option)
	{
		case 1:msg='Corte Z';break;
		case 2:msg='Corte X';break;
	}
	setoverc(obj,'ImageBorderOver');
	optDescObj.innerHTML=msg;
	obj.alt=msg;
}
function mouseOut(obj,option)
{
	var optDescObj=document.getElementById('optDesc');
	setoutc(obj,'ImageBorder');
	optDescObj.innerHTML='&nbsp;';
}
function corregirDgi(i)
{
	var id = eval('document.form0.id'+i).value;
	var codigo = eval('document.form0.codigo'+i).value;
	var tipo_docto = eval('document.form0.tipo_docto'+i).value;
	var codigoDgi = eval('document.form0.codigo_dgi'+i).value;
	showPopWin('../common/run_process.jsp?fp=docto_dgi_list&actType=52&docType=DGI'+'&docNo='+codigo+'&tipo='+tipo_docto+'&docId='+id+'&codigoDgi='+codigoDgi,winWidth*.75,winHeight*.65,null,null,'');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="FACTURAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<!--
	<tr>
		<td align="right">
		<div id="optDesc" class="TextInfo Text10">&nbsp;</div>
		<authtype type='50'><a href="javascript:goOption(1)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,1)" onMouseOut="javascript:mouseOut(this,1)" src="../images/printer_z.gif"></a></authtype>
		<authtype type='51'><a href="javascript:goOption(2)"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" onMouseOver="javascript:mouseOver(this,2)" onMouseOut="javascript:mouseOut(this,2)" src="../images/printer_x.gif"></a></authtype>
		</td>
	</tr>
	-->
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("nt",nt)%>
				<td>No. Factura:
							<%=fb.textBox("codigo",codigo,false,false,false,12,null,null,null)%>
							Cliente:<%=fb.textBox("paciente","",false,false,false,30,null,null,null)%>
				</td>
				<td>Tipo Docto.
							<%=fb.select("tipo_docto","FAC=Factura, NC=Nota de Credito, ND=Nota de Debito",tipo_docto,"S")%>
				</td>
				<td>Impreso
							<%=fb.select("impreso","1=Si, 0=No",impreso,"")%>
				</td>
				<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_ini" />
								<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
								<jsp:param name="nameOfTBox2" value="fecha_fin" />
								<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
								</jsp:include>

							<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>

			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>

</table>
<tr><td colspan="2">&nbsp;</td></tr>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
fb = new FormBean("topPrevious",request.getContextPath()+request.getServletPath());
%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>

<%
fb = new FormBean("topNext",request.getContextPath()+request.getServletPath());
%>
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
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
	<div id="list_opMain" width="100%" style="overflow:scroll;position:fixed;height:300;float:left;">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("index","")%>

<table align="center" width="100%" cellpadding="0" cellspacing="1" class="sortable" id="list">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;C&oacute;digo DGI</td>
		<td width="5%" align="center">&nbsp;Corregir</td>
		<td width="10%">&nbsp;C&oacute;digo</td>
		<td width="8%">&nbsp;Fecha </td>
		<td width="8%">&nbsp;Tipo Docto. </td>
		<td width="28%">&nbsp;Cliente </td>
		<td width="15%">&nbsp;RUC </td>
		<td width="8%" align="right">Monto</td>
		<td width="4%">&nbsp;</td>
		<td width="4%">&nbsp;</td>
	</tr>

	<%
	for (int i=0; i<al.size(); i++)
	{
	 CommonDataObject cdo = (CommonDataObject) al.get(i);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";

%>
	<%=fb.hidden("id"+i,cdo.getColValue("doc_id"))%>
	<%=fb.hidden("ruc_cedula"+i,cdo.getColValue("ruc"))%>
	<%=fb.hidden("dv"+i,cdo.getColValue("dv"))%>
	<%=fb.hidden("codigo"+i,cdo.getColValue("doc_no"))%>
	<%=fb.hidden("tipo_docto"+i,cdo.getColValue("doc_type"))%>
	<%=fb.hidden("codigo_dgi"+i,cdo.getColValue("printed_no"))%>
	<%=fb.hidden("tipo_docto_dgi"+i,cdo.getColValue("tipo_docto_dgi"))%>

	<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" >
		<td><%=cdo.getColValue("printed_no")%></td>
		<td align="center"><%if(cdo.getColValue("printed")!=null && cdo.getColValue("printed").trim().equals("1")){%><authtype type='52'>	
		<a href="javascript:corregirDgi(<%=i%>)"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/actualizar.gif"></a></authtype><%}%>
		</td>
<td><%=cdo.getColValue("doc_no")%></td>
		<td><%=cdo.getColValue("docto_date")%></td>
		<td><%=cdo.getColValue("doc_type")%></td>
		<td><%=cdo.getColValue("client_name")%></td>
		<td><%=cdo.getColValue("ruc")%></td>
		<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
		<td align="center">
		<%if(cdo.getColValue("printed")!=null && cdo.getColValue("printed").trim().equals("0")){%>
		<authtype type='53'><a href="javascript:printFact(<%=i%>,'1')"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/printer.gif"></a></authtype>
		<%}else if(cdo.getColValue("printed")!=null && cdo.getColValue("printed").trim().equals("1")){%>
		<authtype type='54'>
		<a href="javascript:printFact(<%=i%>,'5')"><img height="<%=iconHeight+10%>" width="<%=iconWidth+10%>" class="ImageBorder" src="../images/imprimir_copia.png" alt="Reimprimir"></a></authtype>
		
		<%}%>
		</td>
		
		<td align="center"><authtype type='1'><a href="javascript:printFact(<%=i%>,'2')"><img height="<%=iconHeight%>" width="<%=iconWidth%>" class="ImageBorder" src="../images/search.gif"></a></authtype></td>
		
	</tr>
	<%
	}
	%>

</table>

<%=fb.formEnd()%>
</div>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
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
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("nt",nt)%>
					<%=fb.hidden("codigo",""+codigo)%>
					<%=fb.hidden("paciente",""+paciente)%>
					<%=fb.hidden("tipo_docto",""+tipo_docto)%>
					<%=fb.hidden("impreso",""+impreso)%>
					<%=fb.hidden("fecha_ini",""+fecha_ini)%>
					<%=fb.hidden("fecha_fin",""+fecha_fin)%>
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