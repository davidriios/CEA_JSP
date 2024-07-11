
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />

<%
/**
==========================================================================================
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200069") || SecMgr.checkAccess(session.getId(),"200070") || SecMgr.checkAccess(session.getId(),"200071") || SecMgr.checkAccess(session.getId(),"200072"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo= new CommonDataObject();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String anio        = request.getParameter("anio");
String unidad="";

String fgFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fg==null) fg = "";
if(fp==null) fp = "";
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

	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and a.anio = "+request.getParameter("anio");
    	anio = request.getParameter("anio");
	} 
	if (request.getParameter("unidad") != null && !request.getParameter("unidad").trim().equals(""))
	{
		appendFilter += " and a.unidad = "+request.getParameter("unidad");
    	unidad = request.getParameter("unidad");
	} 
	
	if (request.getParameter("anio") != null)
	{
		sql="select distinct a.compania,a.unidad,a.anio, ue.descripcion descUnidad,nvl((select sum(nvl(c.asignacion,0)) from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania 	= a.compania and c.unidad = a.unidad and anio = a.anio),0) totalIngresos,nvl((select sum(nvl(c.asignacion,0)) v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = a.compania and c.unidad = a.unidad and anio = a.anio),0) totalGastos,nvl((select sum(nvl(c.asignacion,0)) v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = a.compania and c.unidad = a.unidad and anio = a.anio),0)totalCostos from tbl_con_ante_cuenta_mensual a, tbl_sec_unidad_ejec ue where a.compania ="+((String) session.getAttribute("_companyId"))+appendFilter+" and ue.codigo = a.unidad and ue.compania= a.compania and ( a.estado = 'B' or a.estado is null) and (a.unidad,a.compania) in (select distinct b.unidad,b.compania from tbl_con_ante_cuenta_anual b where b.anio = a.anio and b.compania = a.compania and b.unidad = a.unidad and (b.preaprobado = 'N' or b.preaprobado is null)) order by ue.descripcion, a.unidad";
		if(fg.trim().equals("AP"))
		{
			sql="select distinct a.compania,a.unidad,a.anio, ue.descripcion descUnidad,nvl((select sum(nvl(c.asignacion,0)) from tbl_con_ante_cuenta_mensual c where c.cta1 like '4%' and c.compania 	= a.compania and c.unidad = a.unidad and anio = a.anio),0) totalIngresos,nvl((select sum(nvl(c.asignacion,0)) v_gastos from tbl_con_ante_cuenta_mensual c where c.cta1 like '6%' and c.compania = a.compania and c.unidad = a.unidad and anio = a.anio),0) totalGastos,nvl((select sum(nvl(c.asignacion,0)) v_costos from tbl_con_ante_cuenta_mensual c where c.cta1 like '5%' and c.compania = a.compania and c.unidad = a.unidad and anio = a.anio),0)totalCostos from tbl_con_ante_cuenta_mensual a, tbl_sec_unidad_ejec ue where a.compania ="+((String) session.getAttribute("_companyId"))+appendFilter+" and ue.codigo = a.unidad and ue.compania= a.compania and a.preaprobado = 'N' order by ue.descripcion, a.unidad";
		}
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	//al = sbb.getBeanList(ConMgr.getConnection(), "select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal, Comprobante.class);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");
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
document.title = 'Presupuesto <%=(fg.equals("PO"))?"Operaativo":"De Inversiones"%> - '+document.title;

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BORRADOR DE PRESUPUESTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;
	</td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="0" cellspacing="0">
		
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
		<tr class="TextFilter">
			<td width="44%"></td>
			<td width="56%"></td>
		<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
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
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("anio",anio)%>
	<%=fb.hidden("unidad",unidad)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
	<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("anio",anio)%>
	<%=fb.hidden("unidad",unidad)%>
	
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
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
		<%=fb.hidden("size",""+al.size())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("unidad",unidad)%>
		<%=fb.hidden("baction","")%>
	
		<tr class="TextHeader" align="center">
			<td width="38%"><cellbytelabel>Unidad</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Ingresos</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Costos</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Gastos</cellbytelabel></td>
			<td width="12%"><cellbytelabel>Ganancia/Perdida</cellbytelabel></td>
            <td width="10%"><%//=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkSel('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los Registros listados!")%></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo2 = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	double v_ganancia = Double.parseDouble(cdo2.getColValue("totalIngresos"))-(Double.parseDouble(cdo2.getColValue("totalCostos"))+Double.parseDouble(cdo2.getColValue("totalGastos")));
			%>
		<%=fb.hidden("anio"+i,cdo2.getColValue("anio"))%>
		<%=fb.hidden("unidad"+i,cdo2.getColValue("unidad"))%>
		<%=fb.hidden("compania"+i,cdo2.getColValue("compania"))%>
		<%=fb.hidden("gastos"+i,cdo2.getColValue("totalGastos"))%>
		<%=fb.hidden("costos"+i,cdo2.getColValue("totalCostos"))%>
		<%=fb.hidden("ingresos"+i,cdo2.getColValue("totalIngresos"))%>
		<%=fb.hidden("v_ganancia"+i,""+v_ganancia)%>
			
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td>[<%=cdo2.getColValue("unidad")%>] - <%=cdo2.getColValue("descUnidad")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("totalIngresos"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("totalCostos"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo2.getColValue("totalGastos"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(v_ganancia)%>&nbsp;</td>
			<td align="center"><%//=fb.checkbox("check"+i,""+i,false,false,"","","")%></td>
		</tr>
<%
}
%>
					
		<tr class="TextRow02">
          <td colspan="6" align="right"><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
        </tr>
		</table>

        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>

			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("unidad",unidad)%>

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
}//End Method GET
%>
