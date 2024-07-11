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
/** Check whether the user is logged in or not what access rights he has----------------------------
0 SISTEMA         TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
  String codigo="",nombre="";
  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals(""))
  {
    appendFilter += " and upper(cod_banco) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    codigo = request.getParameter("codigo");
  }
  if (request.getParameter("nombre") != null && !request.getParameter("nombre").trim().equals(""))
  {
    appendFilter += " and upper(nombre) like '%"+request.getParameter("nombre").toUpperCase()+"%'";
    nombre = request.getParameter("nombre");
  }
 

  sql = "SELECT a.cod_banco as codigo, a.nombre as nombre, a.ruta_transito as rutaTrans, a.contacto as contacto FROM tbl_con_banco a  where compania = "+session.getAttribute("_companyId")+appendFilter;
  al = SQLMgr.getDataList(sql);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql+") ");

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
document.title = 'Banco - '+document.title;

function returnValue(code, name)
{
  window.opener.document.form1.bancoCode.value = code;
  window.opener.document.form1.banco.value = name;
  window.close();
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
        <%fb = new FormBean("search01",request.getContextPath()+request.getServletPath());%>
            <%=fb.formStart()%>
             <td width="12%">&nbsp;C&oacute;digo</td>
			  <td width="38%">&nbsp;
			  <%=fb.textBox("codigo","",false,false,false,30,null,null,null)%>
			  </td>
              <td width="12%">&nbsp;Nombre</td>
              <td width="38%">&nbsp;
          <%=fb.textBox("nombre","",false,false,false,40,null,null,null)%>
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
		<%=fb.hidden("codigo",""+codigo)%>
        <%=fb.hidden("nombre",""+nombre)%>
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
		  <%=fb.hidden("codigo",""+codigo)%>
          <%=fb.hidden("nombre",""+nombre)%>
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
        <tr class="TextHeader">
          <td width="15%">&nbsp;C&oacute;digo</td>
          <td width="30%">&nbsp;Nombre</td>
          <td width="25%">&nbsp;Ruta Tr&aacute;nsito</td>
          <td width="30%">&nbsp;Contacto</td>
        </tr>
        <%
        for (int i=0; i<al.size(); i++)
        {
         CommonDataObject cdo = (CommonDataObject) al.get(i);
         String color = "TextRow02";
         if (i % 2 == 0) color = "TextRow01";
        %>
        <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:returnValue('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("nombre")%>')">
          <td>&nbsp;<%=cdo.getColValue("codigo")%></td>
          <td>&nbsp;<%=cdo.getColValue("nombre")%></td>
          <td>&nbsp;<%=cdo.getColValue("rutaTrans")%></td>
          <td>&nbsp;<%=cdo.getColValue("contacto")%></td>
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
        fb = new FormBean("bottomPrevious",request.getContextPath()+request.getServletPath());
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
		<%=fb.hidden("codigo",""+codigo)%>
        <%=fb.hidden("nombre",""+nombre)%>
          <td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
          <%=fb.formEnd()%>
          <td width="40%">Total Registro(s) <%=rowCount%></td>
          <td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
          <%
          fb = new FormBean("bottomNext",request.getContextPath()+request.getServletPath());
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
		  <%=fb.hidden("codigo",""+codigo)%>
          <%=fb.hidden("nombre",""+nombre)%>
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