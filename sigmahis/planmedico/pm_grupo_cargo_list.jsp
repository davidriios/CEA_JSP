<%//@ page errorPage="../error.jsp"%>
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

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String compania = (String)session.getAttribute("_companyId");
String userName = (String)session.getAttribute("_userName");
String status = request.getParameter("estado");
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String grupo = request.getParameter("grupo");
String tipoPlan = request.getParameter("tipo_plan");

StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

if (codigo == null) codigo = "";
if (descripcion == null) descripcion = "";
if (status==null) status = "";
if (grupo==null) grupo = "";
if (tipoPlan==null) tipoPlan = "";

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

	sbSql = new StringBuffer();
    sbSql.append("select gc.codigo, gc.descripcion, decode(gc.estado,'A','Activo','I','Inactivo') estado_desc, p.monto, decode(gc.grupo,'C','Consulta','H','Hospitalización') grupo_desc, decode(p.tipo_plan,1,'Familiar', 2, 'Tercera Edad') tipo_plan_desc, gc.grupo from tbl_pm_grupo_copago gc , tbl_pm_plan_copago p where gc.codigo = p.id_copago and compania = ");
    sbSql.append(compania);
    
    if (!codigo.trim().equals("")) {
      sbFilter.append(" and gc.codigo = ");
      sbFilter.append(codigo);
    }
    
    if (!descripcion.trim().equals("")) {
      sbFilter.append(" and gc.descripcion like '%");
      sbFilter.append(descripcion);
      sbFilter.append("%'");
    }
    
    if (!status.trim().equals("")) {
      sbFilter.append(" and gc.estado = '");
      sbFilter.append(status);
      sbFilter.append("'");
    }
    
    if (!grupo.trim().equals("")) {
      sbFilter.append(" and gc.grupo = '");
      sbFilter.append(grupo);
      sbFilter.append("'");
    }
    
    if (!tipoPlan.trim().equals("")) {
      sbFilter.append(" and gc.tipo_plan = ");
      sbFilter.append(tipoPlan);
    }
    
    sbSql.append(sbFilter.toString());
    sbSql.append(" order by gc.descripcion, p.tipo_plan ");
	
	if (request.getParameter("beginSearch") != null ){
        al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
        rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Plan Medicico - Grupo Cargo - '+document.title;

function doAction(){}

$(document).ready(function(){
  //new
  $("#new").click(function(c){
    showPopWin('../planmedico/reg_pm_grupo_cargo.jsp',winWidth*.80,winHeight*.80,null,null,'');
  });
  
  //printing
  $("#print").click(function(p){
    abrir_ventana('../planmedico/print_pm_grupo_cargo_list.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');
  });
  
  //viewing
  $(".view").click(function(c){
    var code = $(this).data("codigo");
    showPopWin('../planmedico/reg_pm_grupo_cargo.jsp?mode=edit&codigo='+code,winWidth*.80,winHeight*.80,null,null,'');
  });
  
  //monto
  $(".monto").click(function(c){
    var code = $(this).data("codigo");
    var desc = $(this).data("desc");
    var grupo = $(this).data("grupo");
    showPopWin('../planmedico/reg_pm_grupo_cargo_monto.jsp?mode=edit&codigo='+code+'&desc='+desc+'&grupo='+grupo,winWidth*.80,winHeight*.80,null,null,'');
  });

});

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value=""></jsp:param>
</jsp:include>
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr><td>
<table align="center" width="100%" cellpadding="1" cellspacing="0">
    <tr class="TextRow02"><td>&nbsp;</td></tr>
	<tr>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='3'>
			<a href="#" class="Link00Bold" id="new">Crear Nuevo Grupo</a>
			</authtype>&nbsp;
			<authtype type='2'>
			<a href="#" class="Link00Bold" id="print">Imprimir</a>
			</authtype>
		</td>
	</tr>
	<tr class="TextFilter">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("beginSearch","")%>
			<td colspan="2">
            <cellbytelabel id="2">C&oacute;digo</cellbytelabel>
            <%=fb.textBox("codigo",codigo,false,false,false,10,10,null,null,"")%>
            &nbsp;&nbsp;
            <cellbytelabel id="2">Descripci&oacute;n</cellbytelabel>
            <%=fb.textBox("descripcion",descripcion,false,false,false,20,500,null,null,"")%>
            &nbsp;&nbsp;
            <cellbytelabel>Grupo</cellbytelabel>
            <%=fb.select("grupo","C=Consulta,H=Hospitalización",grupo,false,false,0,null,null,null,null,"T")%>
            &nbsp;&nbsp;
            <cellbytelabel>Tipo Plan</cellbytelabel>
            <%=fb.select("tipo_plan","1=Familiar,2=Tercera Edad",tipoPlan,false,false,0,null,null,null,null,"T")%>
            &nbsp;&nbsp;
            <cellbytelabel>Estado</cellbytelabel>
            <%=fb.select("estado","A=Activo,I=Inactivo",status,false,false,0,null,null,null,null,"T")%>
			
			<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>
	</tr>
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("estado","")%>
                <%=fb.hidden("beginSearch","")%>
                <%=fb.hidden("codigo",codigo)%>
                <%=fb.hidden("descripcion",descripcion)%>
                <%=fb.hidden("grupo",grupo)%>
                <%=fb.hidden("tipo_plan",tipoPlan)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
                    <%=fb.hidden("estado","")%>
                    <%=fb.hidden("beginSearch","")%>
                    <%=fb.hidden("codigo",codigo)%>
                    <%=fb.hidden("descripcion",descripcion)%>
                    <%=fb.hidden("grupo",grupo)%>
                <%=fb.hidden("tipo_plan",tipoPlan)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader">
		<td width="10%" align="center">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="40%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Tipo Plan</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Grupo</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curVal","")%>
	<%=fb.hidden("curIndex","")%>
<%
				String grp = "";
                double monto = 0.0;
                
                for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
                 %>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("monto")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("tipo_plan_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("grupo_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					  <a href="#" class="Link00Bold view" data-codigo="<%=cdo.getColValue("codigo")%>">Edit</a>
					</td>
                    <td align="center">
					  <a href="#" class="Link00Bold monto" data-codigo="<%=cdo.getColValue("codigo")%>" data-desc="<%=cdo.getColValue("descripcion")%>" data-grupo="<%=cdo.getColValue("grupo")%>">Monto</a>
					</td>
				</tr>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
                <%}%>
				
<%=fb.formEnd(true)%>

</table>
	</td>
</tr>
</table>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
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
				<%=fb.hidden("estado","")%>
                <%=fb.hidden("beginSearch","")%>
                <%=fb.hidden("codigo",codigo)%>
                <%=fb.hidden("descripcion",descripcion)%>
                <%=fb.hidden("grupo",grupo)%>
                <%=fb.hidden("tipo_plan",tipoPlan)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
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
                    <%=fb.hidden("estado","")%>
                    <%=fb.hidden("beginSearch","")%>
                    <%=fb.hidden("codigo",codigo)%>
                    <%=fb.hidden("descripcion",descripcion)%>
                    <%=fb.hidden("grupo",grupo)%>
                <%=fb.hidden("tipo_plan",tipoPlan)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>	</td>
	</tr>
</table>
</body>
</html>
<%
}
%>