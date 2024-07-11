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
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"900089") || SecMgr.checkAccess(session.getId(),"900090") || SecMgr.checkAccess(session.getId(),"900091") || SecMgr.checkAccess(session.getId(),"900092"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");

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
	
	String codigo   = "";   // variable para mantener el valor de los campos filtrados en la consulta
	String descrip  = "";

  if (request.getParameter("codigo") != null)  
  {
    appendFilter += " and upper(a.secuencia) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    searchOn = "secuencia";
    searchVal = request.getParameter("codigo");
    searchType = "1";
    searchDisp = "Secuencia";
		codigo     = request.getParameter("codigo");   // utilizada para mantener el código filtrado
  }
  
	else if (request.getParameter("fechaini") != null || request.getParameter("fechafin") != null )
  {
    appendFilter += " and to_date(to_char(a.fecha_inicial,'DD-MM-YYYY'),'DD-MM-YYYY') >='"+request.getParameter("fechaini")+"'";
    searchOn = "fecha_inicial";
    searchVal = request.getParameter("fechaini");
    searchType = "1";
    searchDisp = "Fecha";
  
	if (request.getParameter("fechafin") != null)
  {
    appendFilter += " and to_date(to_char(a.fecha_final,'DD-MM-YYYY'),'DD-MM-YYYY') <='"+request.getParameter("fechafin")+"'";
    searchOn = "fecha_final";
    searchVal = request.getParameter("fechafin");
    searchType = "1";
    searchDisp = "Fecha";
  }
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

sql = "select a.secuencia, a.anio,a.cod_empresa, to_char(a.fecha_inicial,'dd/mm/yyyy')as fecha_inicial ,to_char(a.fecha_final,'dd/mm/yyyy') as fecha_final, nvl(a.pagar_inasa,0)as pagar_inasa ,b.nombre from tbl_fac_param_pago_automatico a, tbl_adm_empresa b where a.cod_empresa = b.codigo(+)"+appendFilter+" order by a.secuencia desc";
al = SQLMgr.getDataList(" select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
	//rowCount = CmnMgr.getCount(" SELECT count(*) FROM tbl_sal_recuperacion_anestesia "+appendFilter);

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
document.title = 'Pagos Automaticos axa- '+document.title;
function add()
{
	abrir_ventana1('../caja/pago_factura_axa.jsp');
}
function edit(id,anio)
{
	abrir_ventana1('../caja/pago_factura_axa.jsp?mode=view&secuencia='+id+'&anio='+anio);
}
function printList()
{
	abrir_ventana('../caja/print_list_pago_factura_axa.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="PARAMETROS PAGOS AUTOMATICOS AXA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
<td align="right">&nbsp;
        <%
         // if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
        %>
	    <a href="javascript:add()" class="Link00">[ <cellbytelabel>Parametros Pago Automatico Axa</cellbytelabel> ]</a>
   	    <%
		 //}
	    %>
</td>
</tr>
<tr>
<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
<table width="100%" cellpadding="0" cellspacing="1">
<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>

<%=fb.formStart()%>
<tr class="TextFilter">
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<td width="50%"><cellbytelabel>C&oacute;digo</cellbytelabel>
<%=fb.intBox("codigo","",false,false,false,30,10,null,null,null)%>
<%=fb.submit("go","Ir")%>
</td>
<%=fb.formEnd()%>

<td width="50%">&nbsp;</td>	
</tr>
<tr class="TextFilter">
<% fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fp",fp)%>
<td width="50%"><cellbytelabel>Fecha Inicial</cellbytelabel> <jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaini" />
											<jsp:param name="valueOfTBox1" value="" />
											</jsp:include>
</td>
<td width="50%"><cellbytelabel>Fecha Final</cellbytelabel> 
<jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechafin" />
											<jsp:param name="valueOfTBox1" value="" />
											</jsp:include>
<%=fb.submit("go","Ir")%>

</td>
</tr>
<%=fb.formEnd()%>
</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
    <tr>
        <td align="right">&nbsp;
		<%
          //if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),""))
		//  {
		%>
		  <a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>
        <%
    //      }
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
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
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
					<%=fb.hidden("fp",fp)%>
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
<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
<td width="10%"><cellbytelabel>Año</cellbytelabel></td>
<td width="35%" align="left"><cellbytelabel>Empresa</cellbytelabel></td>
<td width="10%"><cellbytelabel>Desde</cellbytelabel> </td>
<td width="10%"><cellbytelabel>Hasta</cellbytelabel></td>
<td width="15%" align="right"><cellbytelabel>Monto Inasa</cellbytelabel></td>
<td width="10%">&nbsp;</td>
</tr>	
<%
for (int i=0; i<al.size(); i++){
CommonDataObject cdo = (CommonDataObject) al.get(i);
String color = "TextRow02";
if (i % 2 == 0) color = "TextRow01";
%>
<tr align="center" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
		<td><%=cdo.getColValue("secuencia")%></td>
		<td><%=cdo.getColValue("anio")%></td>		
		<td align="left"><%=cdo.getColValue("nombre")%></td>		
		<td><%=cdo.getColValue("fecha_inicial")%></td>
		<td><%=cdo.getColValue("fecha_final")%></td>
		<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("pagar_inasa"))%></td>
		<td><a href="javascript:edit('<%=cdo.getColValue("secuencia")%>','<%=cdo.getColValue("anio")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Consultar</cellbytelabel></a></td>
</tr>
<% } %>	
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
				<%=fb.hidden("fp",fp)%>			
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
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
					<%=fb.hidden("fp",fp)%>
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