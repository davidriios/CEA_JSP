
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector" buffer="16kb" autoFlush="true"%>
<%@ page import="java.util.Hashtable"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htuso" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vctuso" scope="session" class="java.util.Vector" />
<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0 SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) {
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alcentro = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
int insuLastLineNo = 0;
int usoLastLineNo = 0;
int equipLastLineNo = 0;
String change ="";
if (request.getParameter("insuLastLineNo") != null) insuLastLineNo = Integer.parseInt(request.getParameter("insuLastLineNo"));
if (request.getParameter("usoLastLineNo") != null) usoLastLineNo = Integer.parseInt(request.getParameter("usoLastLineNo"));
if (request.getParameter("equipLastLineNo") != null) equipLastLineNo = Integer.parseInt(request.getParameter("equipLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";

if(request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
System.out.println("**********"+request.getParameter("searchValFromDate"));
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

  if (request.getParameter("codigo") != null)
  {
    appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("descripcion") != null)
  {
    appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripción";
  }
  else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
      appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

  sql="select codigo, descripcion, compania from tbl_sal_uso where compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by descripcion";
  alcentro = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_sal_uso where compania="+(String) session.getAttribute("_companyId")+appendFilter);

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
document.title = 'Lista de Tarifas- '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">

<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="LISTADO DE TARIFAS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
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
        <%=fb.hidden("id",id)%>
        <%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%>
        <%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
        <%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>
        <%=fb.hidden("mode",mode)%>
        <td width="50%">&nbsp;C&oacute;digo
              <%=fb.intBox("codigo","",false,false,false,30,null,null,null)%>
              <%=fb.submit("go","Ir")%></td>
        <%=fb.formEnd()%>

        <%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
        %>
        <%=fb.formStart()%>
        <%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
        <%=fb.hidden("id",id)%>
        <%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%>
        <%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
        <%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>
        <%=fb.hidden("mode",mode)%>
        <td width="15%">&nbsp;Descripci&oacute;n</td>
        <td width="35%">&nbsp;
              <%=fb.textBox("descripcion","",false,false,false,30,null,null,null)%>
              <%=fb.submit("go","Ir")%> </td>
        <%=fb.formEnd()%>
      </tr>
      </table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("insuLastLineNo",""+insuLastLineNo)%>
<%=fb.hidden("usoLastLineNo",""+usoLastLineNo)%>
<%=fb.hidden("equipLastLineNo",""+equipLastLineNo)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+alcentro.size())%>
<tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr class="TextPager">
          <td align="right">
            <%=fb.submit("save","Guardar",true,false)%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td class="TableLeftBorder TableRightBorder">
      <table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
          <td width="40%">Total Registro(s) <%=rowCount%></td>
          <td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
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
          <td width="10%">&nbsp;</td>
          <td width="10%">&nbsp;C&oacute;digo</td>
          <td width="70%">&nbsp;Nombre</td>
          <td width="10%">&nbsp;<%//=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('cod_uso','check',"+alcentro.size()+",this,0)\"","Seleccionar todas las Tarifas de Uso listadas!")%></td>
        </tr>
  <%
        for (int i=0; i<alcentro.size(); i++)
        {
         CommonDataObject cdos = (CommonDataObject) alcentro.get(i);
         String color = "TextRow02";
         if (i % 2 == 0) color = "TextRow01";
        %>
        <%=fb.hidden("codigo"+i,cdos.getColValue("codigo"))%>
        <%=fb.hidden("descripcion"+i,cdos.getColValue("descripcion"))%>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="right"><%=preVal + i%>&nbsp;</td>
          <td>&nbsp;<%=cdos.getColValue("codigo")%></td>
          <td>&nbsp;<%=cdos.getColValue("descripcion")%></td>
          <td align="center"><%=(vctuso.contains(cdos.getColValue("codigo")))?"Elegido":fb.checkbox("check"+i,""+cdos.getColValue("codigo"),false,false)%></td>
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
    <td class="TableLeftBorder TableRightBorder">
      <table align="center" width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextPager">
          <td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
          <td width="40%">Total Registro(s) <%=rowCount%></td>
          <td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td class="TableLeftBorder TableBottomBorder TableRightBorder">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr class="TextPager">
          <td align="right">
            <%=fb.submit("save","Guardar",true,false)%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
      </table>
    </td>
  </tr>
<%=fb.formEnd()%>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
  int size = Integer.parseInt(request.getParameter("size"));
  for (int i=0; i<size; i++)
  {
    if (request.getParameter("check"+i) != null)
    {
      CommonDataObject cdo1 = new CommonDataObject();
      cdo1.addColValue("cod_uso",request.getParameter("codigo"+i));
      cdo1.addColValue("nametarifa",request.getParameter("descripcion"+i));
      usoLastLineNo++;

      String key = "";
      if (usoLastLineNo < 10) key = "00"+usoLastLineNo;
      else if (usoLastLineNo < 100) key = "0"+usoLastLineNo;
      else key = ""+usoLastLineNo;
      cdo1.addColValue("key",key);

      try
      {
        htuso.put(key,cdo1);
        vctuso.add(cdo1.getColValue("cod_uso"));
      }
      catch(Exception e)
      {
        System.err.println(e.getMessage());
      }
    }
  }

  if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
  {
    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
    return;
  }
  else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
  {
    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&insuLastLineNo="+insuLastLineNo+"&usoLastLineNo="+usoLastLineNo+"&equipLastLineNo="+equipLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
    return;
  }
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  window.opener.location = '../inventario/maletin_config.jsp?change=1&tab=2&mode=<%=mode%>&id=<%=id%>&insuLastLineNo=<%=insuLastLineNo%>&usoLastLineNo=<%=usoLastLineNo%>&equipLastLineNo=<%=equipLastLineNo%>';
  window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
