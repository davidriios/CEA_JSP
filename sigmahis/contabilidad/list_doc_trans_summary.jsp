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
DocumentTransaction dtr = new DocumentTransaction();
int rowCount = 0;
String sql = "";
String dateType = "doc_date";
String docType = request.getParameter("docType");
String xDate = request.getParameter("xDate");
String toDate = request.getParameter("toDate");
String appendFilter = "";

if (docType == null) docType = "";
if (!docType.equals("") && !docType.equalsIgnoreCase("T")) appendFilter += " and doc_type='"+docType+"'";

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
	if (xDate != null && !xDate.equals("") && toDate != null && !toDate.equals(""))
	{
		sql = "select x.transDate, x.docType, x.cta1, x.cta2, x.cta3, x.cta4, x.cta5, x.cta6, decode(sign(x.bal),1,abs(x.bal),0) as debit, decode(sign(x.bal),-1,abs(x.bal),0) as credit, x.cta1||'-'||x.cta2||'-'||x.cta3||'-'||x.cta4||'-'||x.cta5||'-'||x.cta6 as ctaNo, y.descripcion as ctaDesc from (select to_char("+dateType+",'dd/mm/yyyy') as transDate, doc_type as docType, cta1, cta2, cta3, cta4, cta5, cta6, sum(debit) as debit, sum(credit) as credit, sum(debit-credit) as bal, compania from tbl_con_accdoc_trans where compania="+(String) session.getAttribute("_companyId")+" and trunc("+dateType+") between to_date('"+xDate+"', 'dd/mm/yyyy') and to_date('"+toDate+"', 'dd/mm/yyyy')"+appendFilter+" group by to_char("+dateType+",'dd/mm/yyyy'), doc_type, cta1, cta2, cta3, cta4, cta5, cta6, compania) x, tbl_con_catalogo_gral y where x.compania=y.compania and x.cta1=y.cta1 and x.cta2=y.cta2 and x.cta3=y.cta3 and x.cta4=y.cta4 and x.cta5=y.cta5 and x.cta6=y.cta6 order by x.docType, x.debit desc, x.credit";
		System.out.println("SQL=\n"+sql);
		al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, DocumentTransaction.class);
		
		 dtr= (DocumentTransaction) sbb.getSingleRowBean(ConMgr.getConnection(), "select sum(debit)debit,sum(credit) credit from (select rownum as rn, a.* from ("+sql+") a) where rn between 1 and "+nextVal, DocumentTransaction.class);
  
		rowCount = CmnMgr.getCount("select count(*) from (select to_char("+dateType+",'dd/mm/yyyy') as transDate, doc_type as docType, cta1, cta2, cta3, cta4, cta5, cta6, sum(debit) as debit, sum(credit) as credit, sum(debit-credit) as bal, compania from tbl_con_accdoc_trans where compania="+(String) session.getAttribute("_companyId")+" and trunc("+dateType+") between to_date('"+xDate+"', 'dd/mm/yyyy') and to_date('"+toDate+"', 'dd/mm/yyyy')"+appendFilter+" group by to_char("+dateType+",'dd/mm/yyyy'), doc_type, cta1, cta2, cta3, cta4, cta5, cta6, compania) x, tbl_con_catalogo_gral y where x.compania=y.compania and x.cta1=y.cta1 and x.cta2=y.cta2 and x.cta3=y.cta3 and x.cta4=y.cta4 and x.cta5=y.cta5 and x.cta6=y.cta6");
	}
	else {
		xDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
		toDate = xDate;
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
document.title = 'Transacciones de Documentos - '+document.title;

function getMain(formx)
{
  formx.docType.value = document.search00.docType.value;
	formx.xDate.value = document.search00.xDate.value;
  return true;
}

function viewDetails(docType,xDate,toDate)
{
	abrir_ventana('../contabilidad/list_doc_trans_detail.jsp?docType='+docType+'&xDate='+xDate+'&toDate='+toDate);
}

function printList()
{
  abrir_ventana('../contabilidad/print_list_doc_trans_summary.jsp');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
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
        <tr class="TextFilter">   
<%
fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");
%>
        <%=fb.formStart()%>
        <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
          <td colspan="2">
          Tipo Documento
          <%=fb.select("docType","CARGDEV=CARGO / DEVOLUCION,FACCXC=FACTURA CXC, FACCXCDET= FACTURA CXC DETALLADO, ADJUST= NOTAS DE AJUSTES",docType,false,false,0,"Text10",null,null,null,"T")%>
          Fecha
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="nameOfTBox1" value="xDate" />
          <jsp:param name="valueOfTBox1" value="<%=xDate%>" />
          <jsp:param name="nameOfTBox2" value="toDate" />
          <jsp:param name="valueOfTBox2" value="<%=toDate%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
          </jsp:include>
          <%=fb.submit("go","Ir",false,false,"Text10",null,null)%>
          </td>
        <%=fb.formEnd()%>   
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
        	<%=fb.hidden("docType",""+docType)%>
        	<%=fb.hidden("xDate",""+xDate)%>
          <%=fb.hidden("toDate",""+toDate)%>
          
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
          <%=fb.hidden("docType",""+docType)%>
        	<%=fb.hidden("xDate",""+xDate)%>
          <%=fb.hidden("toDate",""+toDate)%>
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
          <td width="20%">No. Cuenta</td>          
          <td width="50%">Descripci&oacute;n</td>          
          <td width="10%">D&eacute;bito</td>          
          <td width="10%">Cr&eacute;dito</td>         
          <td width="10%">&nbsp;</td>
        </tr>
<%
double debit = 0.00;
double credit = 0.00;
double tDebit = 0.00;
double tCredit = 0.00;
String group = "";
String groupDesc = "";
for (int i=0; i<al.size(); i++)
{
  DocumentTransaction dt = (DocumentTransaction) al.get(i);
  String color = "TextRow02";
  if (i % 2 == 0) color = "TextRow01";

	debit = Double.parseDouble(dt.getDebit());
	credit = Double.parseDouble(dt.getCredit());

	if (!group.equalsIgnoreCase(dt.getDocType()))
	{
		if (!group.equals(""))
		{
%>
        <tr class="TextRow06 Text10Bold">
					<td colspan="2" align="right">TOTAL DE <%=groupDesc%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tDebit)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tCredit)%></td>
					<td align="center">&nbsp;</td>
				</tr>
<%
		}
		tDebit = 0.00;
		tCredit = 0.00;
%>
        <tr class="TextRow07 Text10Bold">
					<td colspan="4">[ <%=dt.getDocType()%> ] <%=dt.getDocTypeDesc()%> (<%=xDate%>)</td>
					<td align="center"><a href="javascript:viewDetails('<%=dt.getDocType()%>','<%=dt.getTransDate()%>','<%=toDate%>')" class="Link03Bold">Ver Detalles</a></td>
				</tr>
<%
	}
%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><%=dt.getCtaNo()%></td>
          <td><%=dt.getCtaDesc()%></td>
          <td align="right"><%=(debit == 0)?"":CmnMgr.getFormattedDecimal(debit)%></td>
          <td align="right"><%=(credit == 0)?"":CmnMgr.getFormattedDecimal(credit)%></td>
          <td>&nbsp;</td>
        </tr>
<%
	group = dt.getDocType();
	groupDesc = dt.getDocTypeDesc();
	tDebit += debit;
	tCredit += credit;
}

if (al.size() > 0)
{
%>              
        <tr class="TextRow06 Text10Bold">
					<td colspan="2" align="right">TOTAL DE <%=groupDesc%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tDebit)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tCredit)%></td>
					<td align="center">&nbsp;</td>
				</tr>
        <tr class="TextRow06 Text10Bold">
					<td colspan="2" align="right">TOTAL</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(dtr.getDebit())%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(dtr.getCredit())%></td>
					<td align="center">&nbsp;</td>
				</tr>
<%
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
        	<%=fb.hidden("docType",""+docType)%>
        	<%=fb.hidden("xDate",""+xDate)%>
          <%=fb.hidden("toDate",""+toDate)%>
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
        	<%=fb.hidden("docType",""+docType)%>
        	<%=fb.hidden("xDate",""+xDate)%>
          <%=fb.hidden("toDate",""+toDate)%>
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
