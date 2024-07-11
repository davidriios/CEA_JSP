<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
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
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdox = new CommonDataObject();

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String dateType = "trans_date";
String docType = request.getParameter("docType");
String xDate = request.getParameter("xDate");
String toDate = request.getParameter("toDate");
String fg = request.getParameter("fg");
String cds = request.getParameter("cds");

String appendFilter = "";
if (xDate == null) xDate = "";
if (toDate == null) toDate = "";
if (docType == null) docType = "";
if (fg == null) fg = "";

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
  String cta1="",cta2="",cta3="",cta4="",cta5="",cta6="",admType="";
  if (request.getParameter("cta1") != null && !request.getParameter("cta1").trim().equals(""))
  {
	appendFilter += "and r.cta1 like '%"+request.getParameter("cta1").toUpperCase()+"%'";
    cta1 = request.getParameter("cta1");
  }
  if (request.getParameter("cta2") != null && !request.getParameter("cta2").trim().equals(""))
  {
	appendFilter += "and r.cta2 like '%"+request.getParameter("cta2").toUpperCase()+"%'";
    cta2 = request.getParameter("cta2");
  }
  if (request.getParameter("cta3") != null && !request.getParameter("cta3").trim().equals(""))
  {
	appendFilter += "and r.cta3 like '%"+request.getParameter("cta3").toUpperCase()+"%'";
    cta3 = request.getParameter("cta3");
  }
  if (request.getParameter("cta4") != null && !request.getParameter("cta4").trim().equals(""))
  {
	appendFilter += "and r.cta4 like '%"+request.getParameter("cta4").toUpperCase()+"%'";
    cta4 = request.getParameter("cta4");
  }
  if (request.getParameter("cta5") != null && !request.getParameter("cta5").trim().equals(""))
  {
	appendFilter += "and r.cta5 like '%"+request.getParameter("cta5").toUpperCase()+"%'";
    cta5 = request.getParameter("cta5");
  }
  if (request.getParameter("cta6") != null && !request.getParameter("cta6").trim().equals(""))
  {
	appendFilter += "and r.cta6 like '%"+request.getParameter("cta6").toUpperCase()+"%'";
    cta6 = request.getParameter("cta6");
  }  
  if (request.getParameter("admType") != null && !request.getParameter("admType").trim().equals(""))
  {
	appendFilter += "and r.adm_type ='"+request.getParameter("admType")+"'";
    admType = request.getParameter("admType");
  }    
  
	if (!xDate.trim().equals("") && !toDate.trim().equals("")){
		appendFilter += " and trunc(r.fecha) between to_date('"+xDate+"','dd/mm/yyyy') and to_date('"+toDate+"','dd/mm/yyyy')";
        xDate = request.getParameter("xDate");
        toDate = request.getParameter("toDate");
	}
    
    if (request.getParameter("beginSearch") != null){
       sql = "select  r.cta1||'-'||r.cta2||'-'||r.cta3||'-'||r.cta4||'-'||r.cta5||'-'||r.cta6  cuenta, r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6,r.lado as lado,sum(nvl(r.montos,0)) monto,c.descripcion,r.tipo from tbl_con_libro_ingresos r,      tbl_con_catalogo_gral c where r.compania = "+(String) session.getAttribute("_companyId")+" and c.compania = r.compania and c.cta1 = r.cta1 and c.cta2 = r.cta2 and c.cta3 = r.cta3 and c.cta4 = r.cta4 and c.cta5 = r.cta5 and c.cta6 = r.cta6 "+appendFilter+" group by r.lado,r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6,c.descripcion,r.tipo order by r.cta1,r.cta2,r.cta3,r.cta4,r.cta5,r.cta6";

       al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		
		cdox = SQLMgr.getData("select nvl(sum(decode(lado ,'DB',nvl(monto,0))),0) totalDebito, nvl(sum(decode(lado ,'CR',nvl(monto,0))),0) totalCredito from("+sql+")");
		
		rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
document.title = 'Libro de Ingresos - '+document.title;
function viewDetails(docType,xDate,toDate)
{
	abrir_ventana('../contabilidad/list_doc_trans_detail.jsp?docType='+docType+'&xDate='+xDate+'&toDate='+toDate);
}

function printList()
{
  abrir_ventana('../contabilidad/print_libro_ingreso_detail.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>&xDate=<%=xDate%>&toDate=<%=toDate%>');
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
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("beginSearch","")%>
          <td width="50%">
          Fecha
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="nameOfTBox1" value="xDate" />
          <jsp:param name="valueOfTBox1" value="<%=xDate%>" />
          <jsp:param name="nameOfTBox2" value="toDate" />
          <jsp:param name="valueOfTBox2" value="<%=toDate%>" />
          <jsp:param name="fieldClass" value="Text10" />
          <jsp:param name="buttonClass" value="Text10" />
          </jsp:include>Categoria
		            <%=fb.select(ConMgr.getConnection(),"select distinct adm_type,decode(adm_type,'I','INGRESOS - IP','INGRESOS - OP') categoria from tbl_adm_categoria_admision order by 1","admType",admType,"T")%>

</td>
		  <td width="50%"> Cuenta: 
					<%=fb.textBox("cta1",cta1,false,false,false,3,3)%> 
					<%=fb.textBox("cta2",cta2,false,false,false,3,3)%> 
					<%=fb.textBox("cta3",cta3,false,false,false,3,3)%> 
					<%=fb.textBox("cta4",cta4,false,false,false,3,3)%> 
					<%=fb.textBox("cta5",cta5,false,false,false,3,3)%> 
					<%=fb.textBox("cta6",cta6,false,false,false,3,3)%> 
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
		  <%=fb.hidden("toDate",toDate)%>
          <%=fb.hidden("xDate",xDate)%>
		  <%=fb.hidden("fg",fg)%>
          <%=fb.hidden("beginSearch","")%>
		  <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%>
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
          <%=fb.hidden("toDate",toDate)%>
          <%=fb.hidden("xDate",xDate)%>
		  <%=fb.hidden("fg",fg)%>
          <%=fb.hidden("beginSearch","")%>
		  <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%>
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
					<td colspan="2" align="right">TOTAL EN ESTA PAGINA</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tDebit)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(tCredit)%></td>
					<td align="center">&nbsp;</td>
				</tr>
				
				<tr class="TextRow06 Text10Bold">
					<td colspan="2" align="right">GRAN TOTAL</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdox.getColValue("totalDebito"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdox.getColValue("totalCredito"))%></td>
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
          <%=fb.hidden("toDate",toDate)%>
          <%=fb.hidden("xDate",xDate)%>
		  <%=fb.hidden("fg",fg)%>
          <%=fb.hidden("beginSearch","")%>
		  <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%>
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
          <%=fb.hidden("toDate",toDate)%>
          <%=fb.hidden("xDate",xDate)%>
		  <%=fb.hidden("fg",fg)%>
          <%=fb.hidden("beginSearch","")%>
		  <%=fb.hidden("cta1",cta1)%> <%=fb.hidden("cta2",cta2)%> <%=fb.hidden("cta3",cta3)%> <%=fb.hidden("cta4",cta4)%> <%=fb.hidden("cta5",cta5)%> <%=fb.hidden("cta6",cta6)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%>
        </tr>
      </table>
    </td>
  </tr>
</table>

</body>
</html>
<%
}
%>
