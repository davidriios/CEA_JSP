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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900093") || SecMgr.checkAccess(session.getId(),"900094") || SecMgr.checkAccess(session.getId(),"900095") || SecMgr.checkAccess(session.getId(),"900096")|| SecMgr.checkAccess(session.getId(),"900097")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";

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
	
	String anio = "";                 // variables para mantener el valor de los campos filtrados en la consulta
	String cta  = "", descrip = "";
  
  if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
  {     
    appendFilter += " and a.ano like '%"+request.getParameter("anio").toUpperCase()+"%'";
	anio       = request.getParameter("anio");   // utilizada para mantener el valor del año por el cual se filtró
  }
  if (request.getParameter("cuenta") != null && !request.getParameter("cuenta").trim().equals(""))
  {
    appendFilter += " and upper(a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6) like '%"+request.getParameter("cuenta").toUpperCase()+"%'";
	cta        = request.getParameter("cuenta");  // utilizada para mantener el valor de la cuenta por la que se filtró
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
	descrip    = request.getParameter("descripcion"); // utilizada para mantener el valor de la descripción por la que se filtró
  }
  
  sql = "SELECT a.ano, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6, a.cta1||'-'||a.cta2||'-'||a.cta3||'-'||a.cta4||'-'||a.cta5||'-'||a.cta6 as cta, b.descripcion as cuenta, decode(a.status_cta,'CR','Crédito','DB','Débito') as estado, a.saldo_actual FROM tbl_con_plan_cuentas a, tbl_con_catalogo_gral b WHERE a.cta1=b.cta1 and a.cta2=b.cta2 and a.cta3=b.cta3 and a.cta4=b.cta4 and a.cta5=b.cta5 and a.cta6=b.cta6 and a.compania=b.compania and a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.ano, a.cta1, a.cta2, a.cta3, a.cta4, a.cta5, a.cta6";    
  al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+")");

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
document.title = 'Saldos de Ctas Financieras - '+document.title;
function edit(i)
{
  var cta1 = eval('document.form1.cta1'+i).value;
  var cta2 = eval('document.form1.cta2'+i).value;
  var cta3 = eval('document.form1.cta3'+i).value;
  var cta4 = eval('document.form1.cta4'+i).value;
  var cta5 = eval('document.form1.cta5'+i).value;
  var cta6 = eval('document.form1.cta6'+i).value;
  var anio = eval('document.form1.anio'+i).value;
  abrir_ventana('../contabilidad/saldos_ctafinanciera_config.jsp?mode=view&cta1='+cta1+'&cta2='+cta2+'&cta3='+cta3+'&cta4='+cta4+'&cta5='+cta5+'&cta6='+cta6+'&anio='+anio);
}
function printList(){abrir_ventana('../contabilidad/print_list_saldos_ctafinanciera.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,250);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="CONTABILIDAD - SALDOS CTAS FINANCIERAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
  <tr>
    <td>
      <table width="100%" cellpadding="0" cellspacing="1">
          <tr class="TextFilter">   
           <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
            <%=fb.formStart()%>
          <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
            <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
            <td width="20%">A&ntilde;o
          <%=fb.textBox("anio",anio,false,false,false,15)%>
          </td>
          <td width="35%">Cuenta
          <%=fb.textBox("cuenta",cta,false,false,false,35)%>
          </td>
            <td width="45%">Cuenta Desc.
          <%=fb.textBox("descripcion",descrip,false,false,false,45)%>
          <%=fb.submit("go","Ir")%>
          </td>
            <%=fb.formEnd()%>   
          </tr>
      </table>
    </td>
  </tr>
    <tr>
        <td align="right"><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></td>
    </tr>
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder">
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
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("cuenta",cta)%>
		<%=fb.hidden("descripcion",descrip)%>
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
		  <%=fb.hidden("anio",anio)%>
		  <%=fb.hidden("cuenta",cta)%>
		  <%=fb.hidden("descripcion",descrip)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
	<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->    
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
      <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
      <%=fb.formStart(true)%>
        <tr class="TextHeader" align="center">
          <td width="5%">&nbsp;</td>
          <td width="10%">A&ntilde;o</td>
          <td width="25%">Cuenta</td>
          <td width="25%">Descripci&oacute;n</td>
          <td width="15%">Status Cta.</td>
          <td width="10%">Saldo Actual</td>
          <td width="10%">&nbsp;</td>
        </tr>       
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
        <%=fb.hidden("anio"+i,cdo.getColValue("ano"))%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="right"><%=preVal + i%>&nbsp;</td>
          <td><%=cdo.getColValue("ano")%></td>
          <td><%=cdo.getColValue("cta")%></td>
          <td><%=cdo.getColValue("cuenta")%></td>
          <td align="center"><%=cdo.getColValue("estado")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_actual"))%></td>
          <td align="center"><a href="javascript:edit(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">ver</a></td>
        </tr>
        <%
        }
        %>              
      <%=fb.formEnd(true)%>
      </table>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
    </div>
</div>
	</td>
  </tr>
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
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("cuenta",cta)%>
		<%=fb.hidden("descripcion",descrip)%>
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
		  <%=fb.hidden("anio",anio)%>
		  <%=fb.hidden("cuenta",cta)%>
		  <%=fb.hidden("descripcion",descrip)%>
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