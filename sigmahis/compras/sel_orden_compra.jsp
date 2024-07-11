<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="OCDet" scope="session" class="issi.compras.OrdenCompra" />
<jsp:useBean id="htOC" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
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
String sql = "";
String appendFilter = "";
String tipo_comp = request.getParameter("tipo_comp");
if(tipo_comp==null) tipo_comp = "1";
String mode = request.getParameter("mode");
if(mode==null) mode = "conf";
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

sql = "select tipo_com, descripcion from tbl_com_tipo_compromiso where tipo_com = "+tipo_comp;
cdo = SQLMgr.getData(sql);
OCDet.setTipoCompromiso(cdo.getColValue("tipo_com"));
OCDet.setDescTipoCompromiso(cdo.getColValue("descripcion"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  /*
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

	if (request.getParameter("cod_proveedor") != null)
	{
		appendFilter += " and upper(cod_proveedor) like '%"+request.getParameter("cod_proveedor").toUpperCase()+"%'";

    searchOn = "cod_proveedor";
    searchVal = request.getParameter("cod_proveedor");
    searchType = "1";
    searchDisp = "Código Proveedor";
	}
	else if (request.getParameter("num_doc") != null)
	{
		appendFilter += " and upper(num_doc) like '%"+request.getParameter("num_doc").toUpperCase()+"%'";

    searchOn = "num_doc";
    searchVal = request.getParameter("num_doc");
    searchType = "1";
    searchDisp = "Número Documento";
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
	*/
	/*
	sql = "SELECT a.anio, a.num_doc, a.cod_proveedor, b.nombre_proveedor, to_char(a.fecha_documento,'dd/mm/yyyy') fecha_documento, a.monto_total FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b where a.cod_proveedor = b.cod_proveedor and a.status = 'T' and a.compania = "+session.getAttribute("_companyId") + appendFilter;

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+") a");
	
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
	*/
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Inventario - '+document.title;
/*
function getFormHValues(formx){
	formx.tipo_comp.value = document.formH.tipo_comp.value;
}
*/
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRA - SELECCION DE ORDEN DE COMPRA"></jsp:param>
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
<%
fb = new FormBean("formH","","post");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("mode",mode)%>
				<td colspan="2">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.select(ConMgr.getConnection(), "select tipo_com, descripcion from tbl_com_tipo_compromiso", "tipo_comp",tipo_comp)%>
					<%if(mode.equals("app")){%>
					<%=fb.select("status","A=Aprobado,P=Pendiente","")%>
					<%}%>
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
			</tr>
<!--
			<tr class="TextFilter">
		
<%
//fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:getFormHValues(this);\"");
%>
				<%//=fb.formStart()%>
				<%////=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("tipo_comp","")%>
				<td width="33%">
					C&oacute;digo
					<%//=fb.intBox("num_doc","",false,false,false,30)%>
					<%//=fb.submit("go","Ir")%>
				</td>
<%//=fb.formEnd()%>
<%
//fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp","","onSubmit=\"javascript:getFormHValues(this);\"");
%>
				<%//=fb.formStart()%>
				<%//=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("tipo_comp","")%>
				<td width="34%">
					Descripci&oacute;n
					<%//=fb.textBox("cod_proveedor","",false,false,false,30)%>
					<%//=fb.submit("go","Ir")%>
				</td>
<%//=fb.formEnd()%>
			</tr>
-->
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
</table>
<!--
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableTopBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
//fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%//=fb.formStart()%>
				<%//=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%//=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%//=fb.hidden("searchOn",searchOn)%>
				<%//=fb.hidden("searchVal",searchVal)%>
				<%//=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%//=fb.hidden("searchValToDate",searchValToDate)%>
				<%//=fb.hidden("searchType",searchType)%>
				<%//=fb.hidden("searchDisp",searchDisp)%>
				<%//=fb.hidden("searchQuery","sQ")%>
					<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%//=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%//=rowCount%></td>
				<td width="40%" align="right">Registros desde <//%=pVal%> hasta <%//=nVal%></td>
<%
//fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%//=fb.formStart()%>
				<%//=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%//=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%//=fb.hidden("searchOn",searchOn)%>
				<%//=fb.hidden("searchVal",searchVal)%>
				<%//=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%//=fb.hidden("searchValToDate",searchValToDate)%>
				<%//=fb.hidden("searchType",searchType)%>
				<%//=fb.hidden("searchDisp",searchDisp)%>
				<%//=fb.hidden("searchQuery","sQ")%>
				<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%//=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<%
//fb = new FormBean("details",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<!--
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader" align="center">
			<td width="5%">&nbsp;</td>
			<td width="20%">A&ntilde;o</td>
			<td width="20%">N&uacute;mero</td>
			<td width="20%">Proveedor</td>
			<td width="60%">Total</td>
			<td width="15%">&nbsp;</td>
		</tr>
-->
<!--
<%
/*
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%//=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%//=color%>')">
			<td align="right"><%//=preVal + i%>&nbsp;</td>
			<td><%//=cdo.getColValue("anio")%></td>
			<td><%//=cdo.getColValue("num_doc")%></td>
			<td><%//=cdo.getColValue("nombre_proveedor")%></td>
			<td align="center">
			<a href="javascript:setValues(<%//=i%>)" onMouseOut="setoutc(this,'Link02Bold')">Seleccionar</a>
			</td>
			<%//=fb.hidden("anio",cdo.getColValue("anio"))%>
			<%//=fb.hidden("tipo_compromiso",cdo.getColValue("tipo_compromiso"))%>
			<%//=fb.hidden("num_doc",cdo.getColValue("num_doc"))%>
			<%//=fb.hidden("cod_proveedor",cdo.getColValue("cod_proveedor"))%>
			<%//=fb.hidden("cod_proveedor",cdo.getColValue("nombre_proveedor"))%>
			<%//=fb.hidden("nombre_proveedor",cdo.getColValue("nombre_proveedor"))%>
		</tr>
<%
}*/
%>
		</table>
<%//=fb.formEnd()%>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
<!--
	</td>
</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextPager">
<%
//fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%//=fb.formStart()%>
				<%//=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%//=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%//=fb.hidden("searchOn",searchOn)%>
				<%//=fb.hidden("searchVal",searchVal)%>
				<%//=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%//=fb.hidden("searchValToDate",searchValToDate)%>
				<%//=fb.hidden("searchType",searchType)%>
				<%//=fb.hidden("searchDisp",searchDisp)%>
				<%//=fb.hidden("searchQuery","sQ")%>
					<td width="10%"><%//=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%//=fb.formEnd()%>
				<td width="40%">Total Registro(s) <%//=rowCount%></td>
				<td width="40%" align="right">Registros desde <%//=pVal%> hasta <%//=nVal%></td>
<%
//fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%//=fb.formStart()%>
				<%//=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%//=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%//=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%//=fb.hidden("searchOn",searchOn)%>
				<%//=fb.hidden("searchVal",searchVal)%>
				<%//=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%//=fb.hidden("searchValToDate",searchValToDate)%>
				<%//=fb.hidden("searchType",searchType)%>
				<%//=fb.hidden("searchDisp",searchDisp)%>
				<%//=fb.hidden("searchQuery","sQ")%>
				<td width="10%" align="right"><%//=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%//=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
-->
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	String statFilter = " and a.status = 'T'";
	if(request.getParameter("status")!=null) statFilter = " and a.status = '"+request.getParameter("status")+"'";
	sql = "SELECT a.anio, a.num_doc numDoc, a.cod_proveedor codProveedor, b.nombre_proveedor descCodProveedor, to_char(a.fecha_documento,'dd/mm/yyyy') fechaDocto, a.monto_total montoTotal, a.status FROM TBL_COM_COMP_FORMALES a, tbl_com_proveedor b where a.cod_proveedor = b.cod_provedor and a.compania = "+session.getAttribute("_companyId") + " and a.tipo_compromiso = "+ tipo_comp +appendFilter+statFilter;
	System.out.println("sql...="+sql);
	
	al = sbb.getBeanList(ConMgr.getConnection(), sql, OrdenCompra.class);

	//al = SQLMgr.getDataList(sql);

	htOC.clear();
	int lineNo = 0;
	for(int i=0;i<al.size();i++){
		OrdenCompra oc = (OrdenCompra) al.get(i);
		/*
		oc.setAnio(cdo2.getColValue("anio"));
		oc.setNumDoc(cdo2.getColValue("num_doc"));
		oc.setCodProveedor(cdo2.getColValue("cod_proveedor"));
		oc.setDescCodProveedor(cdo2.getColValue("nombre_proveedor"));
		oc.setFechaDocto(cdo2.getColValue("fecha_documento"));
		oc.setMontoTotal(cdo2.getColValue("monto_total"));
		*/
%><%
		String key = "";		
		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		try {
			htOC.put(key, oc);
		}	catch (Exception e)	{
			System.out.println("Unable to addget item "+key);
		}
	}

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	window.opener.document.ordencompra.change.value = "1";
	window.opener.document.ordencompra.action.value = "adding";
	window.opener.document.ordencompra.mode.value = "<%=mode%>";
	window.opener.document.ordencompra.submit();
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}
%>
