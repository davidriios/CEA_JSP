
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
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
fg= PO  --->  Registro de Ajustes al Presupuesto Operativo
fg= PI  --->  Registro de Ajustes al presupuesto de Inversiones
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
String sql = "";
String appendFilter = "";
String anio        = request.getParameter("anio");

String fgFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
if(fg==null) fg = "PO";
if(fp==null) fp = "";
String fgLabel ="";
String tableName = "";
	if(fg.trim().equals("PO")){
	  tableName="tbl_con_ajuste_cta";fgLabel="Presupuesto Operativo";}
	else if(fg.trim().equals("PI")){ tableName="tbl_con_ajuste_cta_inv";fgLabel="Presupuesto De Inversiones";}
		

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
    String noAjuste="",tipoAjuste="",fechaDoc="";
	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and a.anio = "+request.getParameter("anio");
    	anio = request.getParameter("anio");
	} 
	if (request.getParameter("noAjuste") != null && !request.getParameter("noAjuste").trim().equals("") ){
		appendFilter += " and a.numero_ajuste = "+request.getParameter("noAjuste");
    	noAjuste = request.getParameter("noAjuste");
	} 
	if (request.getParameter("tipoAjuste") != null && !request.getParameter("tipoAjuste").trim().equals("") ){
		appendFilter += " and a.cod_ajuste = "+request.getParameter("tipoAjuste");
    	tipoAjuste = request.getParameter("tipoAjuste");
	}
	if (request.getParameter("fechaDoc") != null && !request.getParameter("fechaDoc").trim().equals("") ){
		appendFilter += " and trunc(a.fecha_documento) = to_date('"+request.getParameter("fechaDoc")+"','dd/mm/yyyy')";
    	fechaDoc = request.getParameter("fechaDoc");
	}	
	
	
	String sbField="";
	
	if (request.getParameter("anio")!= null){
	
		if (!UserDet.getUserProfile().contains("0")){ 	appendFilter +=" and codigo in(";
			if(session.getAttribute("_ua")!=null) appendFilter += CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_ua")); 
			else appendFilter +="-1";
			appendFilter +=")";
		}
	
		sql = "select  a.anio, a.cod_ajuste, a.numero_ajuste,  a.explicacion, a.monto, a.mes, to_char(a.fecha_documento,'dd/mm/yyyy')fechaDocumento,a.usuario, a.estado, a.numero_documento,b.descripcion descAjuste,decode(a.estado,'T','TRAMITE','A','APROBADO','R','RECHAZADO') descEstado from "+tableName+" a ,tbl_con_tipo_ajuste b where b.cod_ajuste=a.cod_ajuste"+appendFilter+" order by a.anio,a.cod_ajuste, a.numero_ajuste";
	
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
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
document.title = 'Ajustes a  <%=fgLabel%> - '+document.title;

function add(){
	abrir_ventana('../presupuesto/reg_ajuste_presupuesto.jsp?mode=add&fg=<%=fg%>');
}
function edit(anio,codAjuste,noAjuste){
	abrir_ventana('../presupuesto/reg_ajuste_presupuesto.jsp?mode=edit&fg=<%=fg%>&anio='+anio+'&noAjuste='+noAjuste+'&codAjuste='+codAjuste);
}
function view(anio,codAjuste,noAjuste){
	abrir_ventana('../presupuesto/reg_ajuste_presupuesto.jsp?mode=view&fg=<%=fg%>&anio='+anio+'&noAjuste='+noAjuste+'&codAjuste='+codAjuste);
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
	<jsp:param name="title" value="AJUSTES A <%=fgLabel%>"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right">&nbsp;
		<authtype type='3'><a href="javascript:add()" class="Link00">[ <cellbytelabel>Registrar Ajuste a</cellbytelabel> <%=fgLabel%> ]</a></authtype>
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
<%=fb.hidden("fp",fp)%>

			<td width="10%">
				<cellbytelabel>A&ntilde;o</cellbytelabel>
				<%=fb.intBox("anio",anio,false,false,false,10)%>
				
			</td>
			<td width="15%">
				<cellbytelabel>Fecha Doc</cellbytelabel>.
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fechaDoc" />
				<jsp:param name="valueOfTBox1" value="<%=fechaDoc%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="clearOption" value="true" />
				</jsp:include>
				
			</td>
			<td width="75%">
			<cellbytelabel>Tipo Ajuste</cellbytelabel>:
			
			<%=fb.select(ConMgr.getConnection(), "select b.cod_ajuste, b.cod_ajuste||' - '||b.descripcion, b.descripcion x from tbl_con_tipo_ajuste b order by b.descripcion, b.cod_ajuste", "tipoAjuste",tipoAjuste, false, false, 0, "", "", "", "Tipo de Ajuste", "T")%>

			
				<cellbytelabel>N&uacute;meno Ajuste</cellbytelabel>
				<%=fb.intBox("noAjuste",noAjuste,false,false,false,10)%>
				<%=fb.submit("go","Ir")%>
			</td>
<%=fb.formEnd()%>
		
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00"><!--[ Imprimir Lista ]--></a></authtype></td>
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
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("noAjuste",noAjuste)%>
<%=fb.hidden("tipoAjuste",tipoAjuste)%>
<%=fb.hidden("fechaDoc",fechaDoc)%>

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
<%=fb.hidden("noAjuste",noAjuste)%>
<%=fb.hidden("tipoAjuste",tipoAjuste)%>
<%=fb.hidden("fechaDoc",fechaDoc)%>

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
			<td width="5%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
			<td width="15%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>N&uacute;meno Ajuste</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Fecha Doc.</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Mes</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Monto</cellbytelabel></td>
			<td width="10%"><cellbytelabel>N&uacute;meno Documento</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
            <td width="5%">&nbsp;</td>
			<td width="5%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			
			<td align="center"><%=cdo.getColValue("anio")%></td>
			<td><%=cdo.getColValue("descAjuste")%></td>
			<td><%=cdo.getColValue("numero_ajuste")%></td>
			<td><%=cdo.getColValue("fechaDocumento")%></td>
			<td><%=cdo.getColValue("mes")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;</td>
			<td><%=cdo.getColValue("numero_documento")%></td>
			<td align="center"><%=cdo.getColValue("descEstado")%></td>
			
			<td align="center">
			<%if(cdo.getColValue("estado") != null && !cdo.getColValue("estado").trim().equals("") && !cdo.getColValue("estado").trim().equals("A")){%>
            <authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("cod_ajuste")%>,<%=cdo.getColValue("numero_ajuste")%>)" class="Link02Bold"><cellbytelabel>Editar</cellbytelabel></a></authtype><%}%>
            </td>
            <td align="center">           
         <authtype type='1'><a href="javascript:view(<%=cdo.getColValue("anio")%>,<%=cdo.getColValue("cod_ajuste")%>,<%=cdo.getColValue("numero_ajuste")%>)" class="Link02Bold"><cellbytelabel>ver</cellbytelabel></a></authtype>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("noAjuste",noAjuste)%>
<%=fb.hidden("tipoAjuste",tipoAjuste)%>
<%=fb.hidden("fechaDoc",fechaDoc)%>

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
<%=fb.hidden("noAjuste",noAjuste)%>
<%=fb.hidden("tipoAjuste",tipoAjuste)%>
<%=fb.hidden("fechaDoc",fechaDoc)%>

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
