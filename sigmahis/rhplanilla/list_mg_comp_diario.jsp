
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
int rowCount = 0;
String sql = "";
String appendFilter = "";
String consecutivo = request.getParameter("consecutivo");
String anio        = request.getParameter("ea_ano");
String clase       = request.getParameter("clase_comprob");

String fgFilter = "";
String fg = request.getParameter("fg");
if(fg==null) fg = "";

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

	if (request.getParameter("ea_ano") != null){
		appendFilter += " and a.ea_ano = "+request.getParameter("ea_ano");
    searchOn = "a.ea_ano";
    searchVal = request.getParameter("ea_ano");
    searchType = "1";
    searchDisp = "No. Documento";
	} else if (request.getParameter("consecutivo") != null){
		appendFilter += " and a.consecutivo = "+request.getParameter("consecutivo");
    searchOn = "a.consecutivo";
    searchVal = request.getParameter("consecutivo");
    searchType = "1";
    searchDisp = "Año";
	} else if (request.getParameter("clase_comprob") != null){
		appendFilter += " and clase_comprob = "+request.getParameter("clase_comprob");
    searchOn = "a.clase_comprob";
    searchVal = request.getParameter("clase_comprob");
    searchType = "1";
    searchDisp = "Estado";
	}	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST")){
    if (searchType.equals("1")){
			appendFilter += " and "+searchOn+" = "+searchVal;
    }
  } else {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
	String tableName = "";
	if(fg.equals("CD")) tableName = "tbl_con_encab_comprob";
	else if(fg.equals("PLA")) tableName = "tbl_pla_pre_encab_comprob";
	sql = "select a.ea_ano, a.consecutivo, a.compania, decode(a.mes,1,'ENERO',2,'FEBRERO',3,'MARZO',4,'ABRIL',5,'MAYO',6,'JUNIO',7,'JULIO',8,'AGOSTO',9,'SEPTIEMBRE',10,'OCTUBRE',11,'NOVIEMBRE',12,'DICIEMBRE') as mes, a.clase_comprob, a.descripcion, b.descripcion as comprob_desc , a.total_cr, a.total_db, nvl(a.n_doc,' ') as nDoc, to_char(a.fecha_sistema,'dd/mm/yyyy') as fechaSistema, a.status, a.usuario from "+tableName+" a, tbl_con_clases_comprob b, TBL_PLA_planilla_encabezado e where a.status!='DE' and a.clase_comprob=b.codigo_comprob"+appendFilter+" and a.clase_comprob <> 99 /*and usuario_aprob is null and fecha_a is null*/ and e.asconsecutivo = a.consecutivo and e.anio = a.ea_ano and e.cod_compania = a.compania and a.compania ="+(String) session.getAttribute("_companyId")+" order by 1 desc,2 desc";
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from "+tableName+" a, tbl_con_clases_comprob b , tbl_pla_planilla_encabezado e where a.status!='DE' and a.clase_comprob <> 99 /*and usuario_aprob is null and fecha_a is null*/ and e.asconsecutivo = a.consecutivo and e.anio = a.ea_ano and e.cod_compania = a.compania and a.compania ="+(String) session.getAttribute("_companyId")+" and a.clase_comprob=b.codigo_comprob"+appendFilter);

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
document.title = 'Comprobante <%=(fg.equals("CD"))?"Diario":"Histórico"%> - '+document.title;

function add(){
	abrir_ventana('../rhplanilla/reg_comp_diario.jsp?mode=add&fg=<%=fg%>');
}

function app(id, anio, clase){
	abrir_ventana('../rhplanilla/reg_app_comp_diario.jsp?mode=pase&&fg=CD&tipo=26&no='+id+'&anio='+anio+'&clase='+clase);
}

function del(id, anio, clase){
	abrir_ventana('../rhplanilla/reg_app_comp_diario.jsp?mode=del&no='+id+'&fg=<%=fg%>&anio='+anio);
}

function printList(){
	//abrir_ventana('../inventario/');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - PASE DE COMPROBANTE A CONTABILIDAD"></jsp:param>
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
		<tr class="TextFilter">
<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
			<td width="20%">
				A&ntilde;o
				<%=fb.intBox("ea_ano",anio,false,false,false,10)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		
<%fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
			<td width="20%">
				Consecutivo
				<%=fb.intBox("consecutivo",consecutivo,false,false,false,10)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		
<%fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("fg",fg)%>
			<td width="60%">
				Clase
	   <%=fb.select("clase_comprob","1=COMPROBANTE PLANILLA QUINCENAL,2=COMPROBANTE PLANILLA XIII MES,3=COMPROBANTE PLANILLA DE VACACIONES","")%>
                <%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
<tr>
	<td align="right">&nbsp;
<%
//if (SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"200070")){
%>
			<a href="javascript:printList()" class="Link00"><!--[ Imprimir Lista ]--></a>
<%
//}
%>
	</td>
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
<%=fb.hidden("fg",fg)%>
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
			<td width="5%">A&ntilde;o</td>
			<td width="10%">Consecutivo</td>
			<td width="10%">Mes</td>
			<td width="40%">Descripciòn</td>
           	<td width="10%">Total CR</td>
			<td width="10%">Total DB</td>
			<td width="15%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("ea_ano")%></td>
			<td align="center"><%=cdo.getColValue("consecutivo")%></td>
			<td align="center"><%=cdo.getColValue("mes")%></td>
            <td align="left"><%=cdo.getColValue("descripcion")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_cr"))%>&nbsp;</td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total_db"))%>&nbsp;</td>
			<td align="center">
<%
	if (cdo.getColValue("status").equals("PE") && fg.equals("PLA")){
%>
			<a href="javascript:app(<%=cdo.getColValue("consecutivo")%>,<%=cdo.getColValue("ea_ano")%>,<%=cdo.getColValue("clase_comprob")%>)" class="Link02Bold">Pasar a Contabilidad</a> 
<%
	}
%>
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
<%=fb.hidden("fg",fg)%>
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
