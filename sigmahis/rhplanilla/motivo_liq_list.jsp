
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

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
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
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

  String codigo   = "";    // variables para mantener el valor de los campos filtrados en la consulta
	String descrip  = "";
	String rec_pago = "";

	if (request.getParameter("codigo") != null)
	{
		appendFilter += " and upper(codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";

    searchOn = "codigo";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "C�digo";
		codigo     = request.getParameter("codigo");   // utilizada para mantener el C�digo del Estado del Empleado
	}
	else if (request.getParameter("descripcion") != null)
	{
		appendFilter += " and upper(descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";

    searchOn = "descripcion";
    searchVal = request.getParameter("descripcion");
    searchType = "1";
    searchDisp = "Descripci�n";
		descrip    = request.getParameter("descripcion");   // utilizada para mantener la descripci�n del Estado
	}
	else if (request.getParameter("recibe_pago") != null)
	{
		appendFilter += " and upper(recibe_pago) like '%"+request.getParameter("recibe_pago").toUpperCase()+"%'";

    searchOn = "recibe_pago";
    searchVal = request.getParameter("recibe_pago");
    searchType = "1";
    searchDisp = "Recibe Pago";
		rec_pago   = request.getParameter("recibe_pago");            // determina si recibe pago o no
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST"))
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


	sql = "select codigo, descripcion, decode(pagar_vacacion,'S','S�','N','No') pagar_vacacion, decode(pagar_xiii_mes,'S','S�','N','No') pagar_xiii_mes, decode(pagar_pantig,'S','S�','N','No') pagar_pantig, decode(pagar_indemn,'S','S�','N','No') pagar_indemn, decode(pagar_recargo25,'S','S�','N','No') pagar_recargo25, decode(pagar_recargo50,'S','S�','N','No') pagar_recargo50 from tbl_pla_li_motivo where compania = "+(String) session.getAttribute("_companyId")+appendFilter+" order by codigo";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from tbl_pla_li_motivo where compania = "+(String) session.getAttribute("_companyId")+appendFilter);

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
document.title = 'Planilla - '+document.title;

function add()
{
	abrir_ventana('../rhplanilla/reg_motivo_liq.jsp');
}

function edit(id)
{
	abrir_ventana('../rhplanilla/reg_motivo_liq.jsp?mode=edit&id='+id);
}

function printList()
{
	abrir_ventana('../rhplanilla/print_list_motivo_liq.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}

function del(codigo){
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	if(confirm('Est� seguro(a) que desea eliminar?')){
		if(executeDB('<%=request.getContextPath()%>','call sp_par_del_mantenimiento(\'tbl_pla_li_motivo\',\'codigo\',\''+codigo+'\')','tbl_pla_li_motivo')){
			var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
			if(msg!='') alert(msg);
			else alert('Registro eliminado satisfactoriamente!');
			window.location = '../rhplanilla/motivo_liq_list.jsp';
		} else {
			var msg = getMsg('<%=request.getContextPath()%>', clientIdentifier);
			alert(msg);
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MOTIVO DE TERMINACION DE CONTRATO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800023"))
{
%>
		<authtype type='3'>	<a href="javascript:add()" class="Link00">[ Registrar Nuevo Motivo ]</a></authtype>
<%
}
%>
		</td>
  </tr>
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
				<td width="50%">
					C&oacute;digo
					<%=fb.intBox("codigo",codigo,false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td width="50%">
					Descripci&oacute;n
					<%=fb.textBox("descripcion",descrip,false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>

			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800022"))
{
%>
		<authtype type='0'>	<a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype>
<%
}
%>
			&nbsp;
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
			<td width="5%">&nbsp;</td>
			<td width="15%">C&oacute;digo</td>
			<td width="30%">Descripci&oacute;n</td>
			<td width="05%">Vac.</td>
			<td width="05%">XIII</td>
			<td width="05%">P.Antig</td>
			<td width="05%">Indemn.</td>
      <td width="05%">Rec.25</td>
			<td width="05%">Rec.50</td>
			<td width="10%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=preVal + i%>&nbsp;</td>
			<td><%=cdo.getColValue("codigo")%></td>
			<td><%=cdo.getColValue("descripcion")%></td>
			<td align="center"><%=cdo.getColValue("pagar_vacacion")%></td>
			<td align="center"><%=cdo.getColValue("pagar_xiii_mes")%></td>
			<td align="center"><%=cdo.getColValue("pagar_pantig")%></td>
			<td align="center"><%=cdo.getColValue("pagar_indemn")%></td>
      <td align="center"><%=cdo.getColValue("pagar_recargo25")%></td>
			<td align="center"><%=cdo.getColValue("pagar_recargo50")%></td>
			<td align="center">
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800024"))
{
%>
		<authtype type='4'>	<a href="javascript:edit(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
<%
}
%>
			</td>
      <td align="center">
	      <authtype type='7'><a href="javascript:del(<%=cdo.getColValue("codigo")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Eliminar</a></authtype>
      </td>
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
