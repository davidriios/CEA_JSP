<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String dateType = "trans_date";
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
		sql = "select  r.cta1||'-'||r.cta2||'-'||r.cta3||'-'||r.cta4||'-'||r.cta5||'-'||r.cta6  cuenta, r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6,r.lado,sum((nvl(r.totales_new,r.totales))) monto,c.descripcion from tbl_con_replibros r,      tbl_con_catalogo_gral c where trunc(r.fecha) >= to_date('"+xDate+"','dd/mm/yyyy') and trunc(r.fecha) <=to_date('"+toDate+"','dd/mm/yyyy') and r.compania = "+(String) session.getAttribute("_companyId")+" and c.compania = r.compania and c.cta1 = r.cta1 and c.cta2 = r.cta2 and c.cta3 = r.cta3 and c.cta4 = r.cta4 and c.cta5 = r.cta5 and c.cta6 = r.cta6  /*and nvl(r.comprobante,'N') = 'N'*/ group by r.tipo,r.lado,r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6,r.tipo,c.descripcion order by r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6";
		al = SQLMgr.getDataList(sql);
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Libro de Caja - '+document.title;

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
  abrir_ventana('../caja/print_list_libro_caja.jsp?xDate=<%=xDate%>&toDate=<%=toDate%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CONTABILIDAD - LIBRO DE CAJA"></jsp:param>
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
          <cellbytelabel>Fecha</cellbytelabel>
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
    <td align="right">&nbsp;<authtype type='3'><a href="javascript:printList()" class="Link00">[ Imprimir ]</a></authtype></td>
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
        	<%=fb.hidden("docType","").replaceAll(" id=\"docType\"","")%>
        	<%=fb.hidden("xDate","").replaceAll(" id=\"xDate\"","")%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
        	<%=fb.hidden("docType","").replaceAll(" id=\"docType\"","")%>
        	<%=fb.hidden("xDate","").replaceAll(" id=\"xDate\"","")%>
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
          <td width="20%"><cellbytelabel>No. Cuenta</cellbytelabel></td>          
          <td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>          
          <td width="10%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>          
          <td width="10%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>         
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
	CommonDataObject cdo = (CommonDataObject) al.get(i);
  String color = "TextRow02";
  if (i % 2 == 0) color = "TextRow01";

	if(cdo.getColValue("lado").trim().equals("DB"))
	debit = Double.parseDouble(cdo.getColValue("monto"));
	else 
	credit = Double.parseDouble(cdo.getColValue("monto"));

	%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center"><!--<a href="javascript:viewDetails('<%=cdo.getColValue("cuenta")%>')"></a>-->
					
					<%=cdo.getColValue("cuenta")%></td>
          <td><%=cdo.getColValue("descripcion")%></td>
          <td align="right"><%=(debit == 0)?"":CmnMgr.getFormattedDecimal(debit)%></td>
          <td align="right"><%=(credit == 0)?"":CmnMgr.getFormattedDecimal(credit)%></td>
          <td>&nbsp;</td>
        </tr>
<%
	tDebit += debit;
	tCredit += credit;
	debit =0;
	credit =0;
}

if (al.size() > 0)
{
%>
        <tr class="TextRow06 Text10Bold">
					<td colspan="2" align="right"><cellbytelabel>TOTAL</cellbytelabel> </td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tDebit)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tCredit)%></td>
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
        	<%=fb.hidden("docType","").replaceAll(" id=\"docType\"","")%>
        	<%=fb.hidden("xDate","").replaceAll(" id=\"xDate\"","")%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
          <td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
        	<%=fb.hidden("docType","").replaceAll(" id=\"docType\"","")%>
        	<%=fb.hidden("xDate","").replaceAll(" id=\"xDate\"","")%>
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
