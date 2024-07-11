<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==============================================================================================

==============================================================================================
**/
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
String periodo = "";
String cod = "";
String num = "";
String anio = "";


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
  String codPlanilla ="",descripcion="";
  if (request.getParameter("periodo") != null && !request.getParameter("periodo").trim().equals(""))
  {
    appendFilter += " and upper(a.PERIODO) like '%"+request.getParameter("periodo").toUpperCase()+"%'";
    periodo = request.getParameter("periodo");
  }
  if (request.getParameter("codPlanilla") != null && !request.getParameter("codPlanilla").trim().equals(""))
  {
    appendFilter += " and upper(a.TIPOPLA) like '%"+request.getParameter("codPlanilla").toUpperCase()+"%'";
    codPlanilla = request.getParameter("codPlanilla");
  }
  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper( b.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }
  
 
	sql="select a.TIPOPLA as codePlanilla, a.PERIODO, to_char(to_date(a.FECHA_FINAL, 'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') mes, decode(mod(a.periodo,2),0,'SEGUNDA','PRIMERA') quincena, to_char(a.FECHA_INICIAL, 'dd/mm/yyyy') as fechainicial, to_char(a.FECHA_FINAL, 'dd/mm/yyyy') as fechafinal, to_char(a.TRANS_DESDE,'dd/mm/yyyy') as transdesde, to_char(a.TRANS_HASTA,'dd/mm/yyyy') as transhasta, to_char(a.FECHA_CIERRE,'dd/mm/yyyy') as fechacierre, to_char(a.CIERRE_CAMBIO_TURNO,'dd/mm/yyyy') as cambios, to_char(a.cierre_descuentos,'dd/mm/yyyy') as descuentos,b.tipopla as codigo, b.descripcion from TBL_PLA_CALENDARIO a, tbl_pla_tipo_planilla b where a.TIPOPLA=b.tipopla and  a.periodo!=0 "+appendFilter+" order by a.tipopla, a.periodo";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
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
document.title = 'Planilla - Calendario de Planilla - '+document.title;

function add()
{
abrir_ventana('../rhplanilla/calendario_config.jsp');
}
function edit(id,tipo)
{
abrir_ventana('../rhplanilla/calendario_config.jsp?mode=edit&id='+id+'&tipo='+tipo);
}
function  printList()
{
abrir_ventana('../rhplanilla/print_list_calendario.jsp?appendFilter=<%=IBIZEscapeChars.forURL(appendFilter)%>');
}
function changeCal()
{
 var anio = document.form0.anio.value;
 if(anio !=''){
  showPopWin('../common/run_process.jsp?fp=CAL&actType=51&docType=CAL&docId='+anio+'&docNo='+anio+'&anio='+anio,winWidth*.75,winHeight*.65,null,null,'');
 } else alert('Introduzca año!!');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO - CALENDARIO DE PLANILLA "></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td colspan="4" align="right"><authtype type='3'>	<a href="javascript:add()" class="Link00">[ Registrar Nuevo Calendario de Planilla ]</a></authtype></td>
	</tr>

	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td width="50%">&nbsp;Periodo
					<%=fb.textBox("periodo",periodo,false,false,false,30,null,null,null)%>
		</td>
		<td width="50%">&nbsp;Tipo de Planilla
						<%=fb.textBox("codPlanilla",codPlanilla,false,false,false,5,null,null,null)%>
					Descripcion<%=fb.textBox("descripcion",descripcion,false,false,false,30,null,null,null)%>
					<%=fb.submit("go","Ir")%>	</td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("codPlanilla",codPlanilla)%>
				<%=fb.hidden("descripcion",descripcion)%>
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
					<%=fb.hidden("periodo",periodo)%>
					<%=fb.hidden("codPlanilla",codPlanilla)%>
					<%=fb.hidden("descripcion",descripcion)%>
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
    <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
    <%=fb.hidden("cod",cod)%>
	<%=fb.hidden("num",num)%>
	<%=fb.hidden("periodo",periodo)%>
	<%=fb.hidden("codPlanilla",codPlanilla)%>
	<%=fb.hidden("descripcion",descripcion)%>
	<tr class="TextHeader" align="center">
      	<td colspan="12">&nbsp;&nbsp;Para el año: <%=fb.textBox("anio","",false,false,false,6,4,null,null,null)%>&nbsp;
        <authtype type='51'><%=fb.button("btnCambio",".Actualizar Calendario..",true,false,null,null,"onClick=\"javascript:changeCal();\"")%></authtype></td>
	</tr>
	<tr class="TextHeader" align="center">
	   <td width="3%" rowspan="2">&nbsp;</td>
	    <td width="5%" rowspan="2">&nbsp;Perd.</td>
		<td width="10%" rowspan="2">&nbsp;Mes</td>
		<td width="10%" rowspan="2">&nbsp;Quincena</td>
		<td width="9%" rowspan="2">&nbsp;Fecha Inicial</td>
		<td width="9%" rowspan="2">&nbsp;Fecha Final</td>
		<td width="9%" rowspan="2">&nbsp;Fecha Cierre</td>
      	<td width="18%" colspan="2">Transacciones</td>
      	<td width="18%" colspan="2">Cierre</td>
        <td width="9%" rowspan="2">&nbsp;</td>
	</tr>
	<tr class="TextHeader" align="center">
		<td width="8%">&nbsp;Desde</td>
		<td width="8%">&nbsp;Hasta</td>
		<td width="8%">&nbsp;C.Turnos</td>
		<td width="8%">&nbsp;Descuentos</td>
	</tr>

            <%
			String descPlanilla = "";
			for (int i=0; i<al.size(); i++)
				{
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
			if (!descPlanilla.equalsIgnoreCase(cdo.getColValue("descripcion")))
			 {
			 %>
			<tr align="left" bgcolor="#FFFFFF" class="TextHeader02">
            <td colspan="12" class="TitulosdeTablas"> [<%=cdo.getColValue("codePlanilla")%>] - <%=cdo.getColValue("descripcion")%></td>
            </tr>
			 <%
			 }
			 %>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=preVal + i%>&nbsp;</td>
			<td>&nbsp;<%=cdo.getColValue("PERIODO")%></td>
			<td>&nbsp;<%=cdo.getColValue("mes")%></td>
			<td>&nbsp;<%=cdo.getColValue("quincena")%></td>
		    <td align="center">&nbsp;<%=cdo.getColValue("fechainicial")%></td>
			<td align="center">&nbsp;<%=cdo.getColValue("fechafinal")%> </td>
            <td align="center">&nbsp;<%=cdo.getColValue("fechacierre")%> </td>
            <td align="center">&nbsp;<%=cdo.getColValue("transDesde")%> </td>
            <td align="center">&nbsp;<%=cdo.getColValue("transHasta")%> </td>
            <td align="center">&nbsp;<%=cdo.getColValue("cambios")%> </td>
            <td align="center">&nbsp;<%=cdo.getColValue("descuentos")%> </td>
            <td align="center"><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("PERIODO")%>,'<%=cdo.getColValue("codePlanilla")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype></td>
			</tr>
			<%
	         descPlanilla = cdo.getColValue("descripcion");
            }
            %>
             <%=fb.formEnd(true)%>
			</table>
	<!-- ===============   R E S U L T S   E N D   H E R E   ================ -->
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
				<%=fb.hidden("periodo",periodo)%>
				<%=fb.hidden("codPlanilla",codPlanilla)%>
				<%=fb.hidden("descripcion",descripcion)%>
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
					<%=fb.hidden("periodo",periodo)%>
					<%=fb.hidden("codPlanilla",codPlanilla)%>
					<%=fb.hidden("descripcion",descripcion)%>
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
}// else throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
%>
