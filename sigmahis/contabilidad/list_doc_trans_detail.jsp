<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.DocumentTransaction"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String dateType = "doc_date";
String docType = request.getParameter("docType");
String xDate = request.getParameter("xDate");
String toDate = request.getParameter("toDate");

if (docType == null) throw new Exception("El Tipo de Documento no es válido. Por favor intente nuevamente!");
if (xDate == null) throw new Exception("La Fecha no es válida. Por favor intente nuevamente!");

if(request.getMethod().equalsIgnoreCase("GET"))
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

  sql = "select * from (select nvl(a.cds, -1) other1, nvl(c.descripcion, 'NO CDS') other2, nvl(a.service_type, '-1') other3, nvl(b.descripcion, 'NO TIPO SERVICIO') other4, a.trans_block_id as transBlockId, to_char(a.trans_date,'dd/mm/yyyy') as transDate, a.trans_type as transType, a.compania, a.doc_type as docType, a.doc_id as docId, a.doc_no as docNo, to_char(a.doc_date,'dd/mm/yyyy') as docDate, a.doc_amt as docAmt, "+dateType+", a.doc_description as docDescription, sum(a.debit-a.credit) as bal from tbl_con_accdoc_trans a, tbl_cds_tipo_servicio b, tbl_cds_centro_servicio c where a.cds = c.codigo(+) and a.service_type = b.codigo(+) and a.compania="+(String) session.getAttribute("_companyId")+" and a.doc_type='"+docType+"' and trunc("+dateType+") between to_date('"+xDate+"','dd/mm/yyyy') and to_date('"+toDate+"','dd/mm/yyyy') group by a.cds, c.descripcion, a.service_type, b.descripcion, a.trans_block_id, to_char(a.trans_date,'dd/mm/yyyy'), a.trans_type, a.compania, a.doc_type, a.doc_id, a.doc_no, "+dateType+", to_char(a.doc_date,'dd/mm/yyyy'), a.doc_amt, a.trans_date, a.doc_description) order by other1, other3, docDate desc, transBlockId desc";
  System.out.println("SQL=\n"+sql);
  al = sbb.getBeanList(ConMgr.getConnection(),"select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal,DocumentTransaction.class);
  rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");

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
document.title = 'Contabilidad - '+document.title;

function getMain(formx)
{
  formx.docType.value = document.search00.docType.value;
  return true;
}

function view(blockId)
{
  abrir_ventana1('../contabilidad/doc_trans.jsp?mode=view&blockId='+blockId);
}

function imprimir()
{
  abrir_ventana('../contabilidad/print_list_doc_trans_detail.jsp?dateType=<%=dateType%>&docType=<%=docType%>&xDate=<%=xDate%>&toDate=<%=toDate%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CONTABILIDAD - TRANSACCIONES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
		<table width="100%" cellpadding="1">
		<tr class="TextRow07 Text10Bold">
			<td width="50%">Tipo Documento: <%=(new DocumentTransaction()).getDocTypeDesc(docType)%></td>
			<td width="50%">Fecha: <%=xDate%>&nbsp; al &nbsp;<%=toDate%></td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td align="right">&nbsp;
<%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
		<!--<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a>-->
<%
//}
%>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("top",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
		<tr class="TextPager">
			<td colspan="4" align="right"><%=fb.button("impr","Imprimir",false,false,null,null,"onClick=\"javascript:imprimir()\"")%><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
		</tr>
<%=fb.formEnd()%>
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
<%=fb.hidden("docType",docType).replaceAll(" id=\"docType\"","")%>
<%=fb.hidden("xDate",xDate).replaceAll(" id=\"xDate\"","")%>
<%=fb.hidden("toDate",toDate).replaceAll(" id=\"toDate\"","")%>
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
<%=fb.hidden("docType",docType).replaceAll(" id=\"docType\"","")%>
<%=fb.hidden("xDate",xDate).replaceAll(" id=\"xDate\"","")%>
<%=fb.hidden("toDate",toDate).replaceAll(" id=\"toDate\"","")%>
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
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="8%">No. Bloque</td>
			<td width="8%">Fecha</td>
			<td width="16%">No. Documento</td>
			<td width="8%">Fecha Documento</td>
			<td width="40%">Descripci&oacute;n</td>
			<td width="10%">Monto</td>
			<td width="10%">&nbsp;</td>
		</tr>
<%
String docTypeDesc = "";
String cds = "", tipo_serv = "";
for (int i=0; i<al.size(); i++)
{
  DocumentTransaction dt = (DocumentTransaction) al.get(i);
  String color = "TextRow02";
  if (i % 2 == 0) color = "TextRow01";
	String color2 = "TextRow04";
	String color3 = "TextRow03";
	String notBalanced = "";
	if (!dt.getBal().equals("0")) notBalanced = " class=\"TextInfo\"";
		if(!cds.equals(dt.getOther1())){
%>
		<tr class="<%=color2%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color2%>')" align="center">
			<td colspan="7" align="left">&nbsp;&nbsp;<%=dt.getOther1()%>-<%=dt.getOther2()%></td>
		</tr>
    <%}
		if(!tipo_serv.equals(dt.getOther3())){
%>
		<tr class="<%=color3%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color3%>')" align="center">
			<td colspan="7" align="left">&nbsp;&nbsp;&nbsp;&nbsp;<%=dt.getOther3()%>-<%=dt.getOther4()%></td>
		</tr>
    <%}%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
			<td><%=dt.getTransBlockId()%></td>
			<td><%=dt.getDocDate()%></td>
			<td onClick="javascript:showStatusBar('<%=dt.getDocId()%>')"><%=dt.getDocNo()%></td>
			<td><%=dt.getDocDate()%></td>
			<td align="left"><%=dt.getDocDescription()%></td>
			<td align="right"<%=notBalanced%>><%=CmnMgr.getFormattedDecimal(dt.getDocAmt())%>&nbsp;</td>
			<td><a href="javascript:view(<%=dt.getTransBlockId()%>)" class="Link02Bold">Ver Detalle</a></td>
		</tr>
<%
	cds = dt.getOther1();
	tipo_serv = dt.getOther3();
}
%>
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
<%=fb.hidden("docType",docType).replaceAll(" id=\"docType\"","")%>
<%=fb.hidden("xDate",xDate).replaceAll(" id=\"xDate\"","")%>
<%=fb.hidden("toDate",toDate).replaceAll(" id=\"toDate\"","")%>
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
<%=fb.hidden("docType",docType).replaceAll(" id=\"docType\"","")%>
<%=fb.hidden("xDate",xDate).replaceAll(" id=\"xDate\"","")%>
<%=fb.hidden("toDate",toDate).replaceAll(" id=\"toDate\"","")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
<%fb = new FormBean("bottom",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
		<tr class="TextPager">
			<td colspan="4" align="right"><%=fb.button("cancel","Cerrar",false,false,null,null,"onClick=\"javascript:closeWin()\"")%></td>
		</tr>
<%=fb.formEnd()%>
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
