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
/**
==========================================================================================
==========================================================================================
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String mode = request.getParameter("mode");
String index = request.getParameter("index");

if(mode==null) mode = "";
if(fp==null) fp = "";
if(fg==null) fg = "";
if(pacId==null) pacId = "";
if(noAdmision==null) noAdmision = "";

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

	String codigo = request.getParameter("codigo");
	String nombre = request.getParameter("nombre");
	if (codigo == null) codigo = "";
	if (nombre == null) nombre = "";
 	if (!codigo.trim().equals("")) { sbFilter.append(" and upper(id) like '%"); sbFilter.append(request.getParameter("codigo").toUpperCase()); sbFilter.append("%'"); }
	if (!nombre.trim().equals("")) { sbFilter.append(" and upper(nombre) like '%"); sbFilter.append(request.getParameter("nombre").toUpperCase()); sbFilter.append("%'"); }

	if(fg.trim().equals("COT")){ sbFilter.append("and reg_type='COT' and estado ='A' and  trunc(sysdate- add_months (fecha,(nvl (trunc(months_between (sysdate,fecha)/ 12),0)* 12+ nvl (mod (trunc(months_between (sysdate,fecha)),12),0)))) <= to_number(get_sec_comp_param(a.compania,'FACT_DIAS_VALID_COTIZACION'))  "); }
	else { sbFilter.append(" and reg_type='PAQ' and estado <> 'I' "); }
	
	if(fg.trim().equals("PAQ")) {
		sbFilter.append(" and not exists (select null from tbl_fac_detalle_transaccion where pac_id = ");
		sbFilter.append(pacId);
		sbFilter.append(" and fac_secuencia = ");
		sbFilter.append(noAdmision);
		sbFilter.append(" and ref_type = a.reg_type and ref_id = a.id ) ");

		sbFilter.append(" and exists (select null from tbl_adm_clasif_x_plan_conv z where exists (select null from tbl_adm_beneficios_x_admision where pac_id = ");
		sbFilter.append(pacId);
		sbFilter.append(" and admision = ");
		sbFilter.append(noAdmision);
		sbFilter.append(" and categoria_admi = z.categoria_admi and tipo_admi = z.tipo_admi and clasif_admi = z.clasif_admi and empresa = z.empresa and convenio = z.convenio and plan = z.plan and estado = 'A') and z.paquete = 'S' and z.estado <> 'I' and z.cod_reg = a.id)");

		sbSql.append("select a.id, a.nombre,procedimiento,identificacion,(select count(*) from tbl_adm_clasif_x_plan_conv aa,tbl_adm_beneficios_x_admision b where b.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and b.admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" and aa.categoria_admi = b.categoria_admi and aa.tipo_admi = b.tipo_admi and aa.clasif_admi = b.clasif_admi and aa.empresa = b.empresa and aa.convenio = b.convenio and aa.plan = b.plan and aa.paquete = 'S' and b.estado = 'A' and aa.estado <> 'I' and aa.cod_reg = a.id ) as paq from tbl_fac_cotizacion a where compania = ");
		sbSql.append((String)session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 5 desc,id desc ");
	} else {
		sbSql.append("select a.id, a.nombre,procedimiento,identificacion,0 as paq from tbl_fac_cotizacion a where compania = ");
		sbSql.append((String)session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by id desc ");
	}

	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql+")");
	

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
document.title = 'Common - '+document.title;

function setValues(cod){
<%if(fp.trim().equals("convenio")){%>
window.opener.document.form1.codRegistro<%=index%>.value =cod;
window.opener.document.form1.paquete<%=index%>.checked =true;
<%}else{%>
  window.opener.location = '../facturacion/reg_cargo_cotizacion.jsp?change=1&mode=<%=mode%>&id='+cod+'&noAdmision=<%=noAdmision%>&pacId=<%=pacId%>&fp=<%=fg%>';
<%}%>
 window.close();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE COTIZACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("index",index)%>
				<td>
					<cellbytelabel>Codigo</cellbytelabel>
					<%=fb.intBox("codigo","",false,false,false,30)%>
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.intBox("nombre","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%> 
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
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
			<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="30%"><cellbytelabel>Nombre</cellbytelabel></td>
      <td width="15%"><cellbytelabel><%=(fg.trim().equals("PAQ"))?"":"Identificacion"%></cellbytelabel></td>
      <td width="30%"><cellbytelabel><%=(fg.trim().equals("PAQ"))?"":"Procedimiento"%></cellbytelabel></td>
			<td width="15%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setValues(<%=cdo.getColValue("id")%>)" style="cursor:pointer">
			<td ><%if(Integer.parseInt(cdo.getColValue("paq"))>0){%>&nbsp;<label  class="<%=color%>"><label class="RedTextBold">&nbsp;&nbsp;<%}%><%=cdo.getColValue("id")%><%if(Integer.parseInt(cdo.getColValue("paq"))>0){%>&nbsp;&nbsp;</label></label>&nbsp;<%}%></td>
			<td ><%if(Integer.parseInt(cdo.getColValue("paq"))>0){%>&nbsp;<label  class="<%=color%>"><label class="RedTextBold">&nbsp;&nbsp;<%}%><%=cdo.getColValue("nombre")%><%if(Integer.parseInt(cdo.getColValue("paq"))>0){%>&nbsp;&nbsp;</label></label>&nbsp;<%}%></td>
			<td ><%=cdo.getColValue("identificacion")%></td>
			<td ><%=cdo.getColValue("procedimiento")%></td>
			
			
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
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
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("nombre",nombre)%>
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
