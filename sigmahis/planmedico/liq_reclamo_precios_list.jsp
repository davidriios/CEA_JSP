<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLReader"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="xmlRdr" scope="page" class="issi.admin.XMLReader"/>
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
String status = request.getParameter("estado");
String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String id_clasif = request.getParameter("id_clasif");

StringBuffer sbSql = new StringBuffer();
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");

if (codigo == null) codigo = "";
if (descripcion == null) descripcion = "";
if (status==null) status = "";
if (id_clasif==null) id_clasif= "";

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
    sbSql.append("select l.id, lpad(l.codigo_precio,15,' ') codigo, l.descripcion, l.precio, decode(l.estado,'A','Activo','Inactivo') estado_desc, nvl(id_clasif, 0) id_clasif, nvl((select descripcion from tbl_pm_clasif_lista_precio lp where lp.id = l.id_clasif), 'NO ASIGNADO') clasificacion_desc from tbl_pm_lista_precios l where 1=1 ");
    
    if (!codigo.trim().equals("")) {
      sbSql.append(" and l.codigo_precio = '");
      sbSql.append(codigo);
      sbSql.append("'");
    }
    
    if (!descripcion.trim().equals("")) {
      sbSql.append(" and l.descripcion like '%");
      sbSql.append(descripcion);
      sbSql.append("%'");
    }
    
    if (!status.trim().equals("")) {
      sbSql.append(" and l.estado = '");
      sbSql.append(status);
      sbSql.append("'");
    }
		if(!id_clasif.equals("")){
				sbSql.append(" and id_clasif = ");
				sbSql.append(id_clasif);
			}
    
    sbSql.append(" order by nvl(id_clasif, 0) asc, lpad(l.codigo_precio,15,' ') asc");
	
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
document.title = 'Plan Medicico - Liquidación de Reclamo - '+document.title;

function doAction(){}

$(document).ready(function(){
  //new
  $("#new").click(function(c){
    abrir_ventana('../planmedico/reg_liq_reclamo_precios.jsp');
  });
  
  //printing
  $("#print").click(function(p){
    abrir_ventana('../planmedico/print_liq_reclamo_precios_list.jsp?codigo=<%=codigo%>&descripcion=<%=descripcion%>&estado=<%=status%>&id_clasif=<%=id_clasif%>');
  });
  
  //ediying
  $(".edit").click(function(c){
    var code = $(this).data("codigo");
    var tipoTrx = $(this).data("tipotrx");
    abrir_ventana('../planmedico/reg_liq_reclamo_precios.jsp?mode=edit&id='+code);
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
			<a href="#" class="Link00Bold" id="new">Crear Nuevo Precio</a>
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
            <%=fb.textBox("descripcion",descripcion,false,false,false,50,500,null,null,"")%>
            &nbsp;&nbsp;
            <cellbytelabel>Estado</cellbytelabel>
            <%=fb.select("estado","A=Activo,I=Inactivo",status,false,false,0,null,null,null,null,"T")%>
						<cellbytelabel id="4">Clasificaci&oacute;n</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select id as optValueColumn, codigo||' - '||descripcion as optLabelColumn from tbl_pm_clasif_lista_precio order by codigo","id_clasif",id_clasif,false,false,0,"Text10",null,null,"","T")%>
			
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
        <%=fb.hidden("id_clasif",id_clasif)%>
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
        <%=fb.hidden("id_clasif",id_clasif)%>
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
		<td width="15%" align="center">&nbsp;<cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="50%">&nbsp;<cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td width="15%" align="center"><cellbytelabel>Precio</cellbytelabel></td>
		<td width="15%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
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
								 
				<%if(!cdo.getColValue("id_clasif").equals(grp)){%>
				<tr class="TextHeader"><td colspan="5"><%=cdo.getColValue("clasificacion_desc")%></td></tr>
				<%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("descripcion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("precio")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					  <a href="#" class="Link00Bold edit" data-codigo="<%=cdo.getColValue("id")%>" data-tipotrx="<%=cdo.getColValue("tipo_transaccion")%>">Editar</a>
					</td>
				</tr>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("tipo_transaccion"+i,cdo.getColValue("tipo_transaccion"))%>
                <%
								grp=cdo.getColValue("id_clasif");
								}%>
				
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
        <%=fb.hidden("id_clasif",id_clasif)%>
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
        <%=fb.hidden("id_clasif",id_clasif)%>
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