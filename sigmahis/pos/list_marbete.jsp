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
<jsp:useBean id="_companyId" scope="session" class="java.lang.String" />
<jsp:useBean id="htT" scope="page" class="java.util.Hashtable" />
<%
/*
==========================================================================================
==========================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alT = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbSqlAll = new StringBuffer();
String appendFilter = "";
String compId = _companyId;
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String filtrado_por = request.getParameter("filtrado_por");
String client_name = request.getParameter("client_name");
String no_factura = request.getParameter("no_factura");
String admision = request.getParameter("admision");
String pac_id = request.getParameter("pac_id");

if(fg == null) fg = "";
if(admision == null) admision = "";
if(pac_id == null) pac_id = "";
if(fp == null) fp = "POS";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdoF = SQLMgr.getData("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_desde, to_char(sysdate, 'dd/mm/yyyy') fecha_hasta from dual");
	if(fecha_desde==null || fecha_desde.equals("")) fecha_desde = cdoF.getColValue("fecha_desde");
	if(fecha_hasta==null || fecha_hasta.equals("")) fecha_hasta = cdoF.getColValue("fecha_hasta");
  int recsPerPage = 1000;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }
	
	if(request.getParameter("client_name")==null) client_name = "";
	if(request.getParameter("no_factura")==null) no_factura = "";
	if(fp.equals("FAR")){
		sbSql.append("select f.compania, f.other2 doc_id, f.pac_id codigo, to_char(f.fecha_creacion, 'dd/mm/yyyy') doc_date, f.pac_id client_id, (select nombre_paciente from vw_adm_paciente p where p.pac_id = f.pac_id) || ', Orden No. ' || f.other2 client_name, sum(nvl(f.precio_venta, 0)) net_amount, 'N' printed_no, nvl((select 'S' from tbl_fac_marbete m where m.compania = f.compania and m.doc_id = f.other2 and m.estado = 'A' and m.tipo = 'OM'), 'N') existe, f.admision from tbl_int_orden_farmacia f, tbl_sal_detalle_orden_med od where f.estado = 'A' and exists (select null from tbl_inv_articulo a, tbl_inv_familia_articulo fa where f.codigo_articulo = a.cod_articulo and f.compania = a.compania and a.compania = fa.compania and a.cod_flia = fa.cod_flia and fa.marbete = 'S') and od.pac_id = f.pac_id and od.secuencia = f.admision and od.tipo_orden = f.tipo_orden and od.orden_med = f.orden_med and od.codigo = f.codigo and f.compania = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		if(!client_name.equals("")){
			sbSql.append(" and exists (select null from vw_adm_paciente p where p.nombre_paciente like '%");
			sbSql.append(client_name);
			sbSql.append("%' and p.pac_id = f.pac_id)");
		}
		if(!fecha_desde.equals("")){
			sbSql.append(" and trunc(f.fecha_creacion) >= to_date('");
			sbSql.append(fecha_desde);
			sbSql.append("', 'dd/mm/yyyy')");
		}
		if(!fecha_hasta.equals("")){
			sbSql.append(" and trunc(f.fecha_creacion) <= to_date('");
			sbSql.append(fecha_hasta);
			sbSql.append("', 'dd/mm/yyyy')");
		}
		if(!pac_id.equals("")){
			sbSql.append(" and f.pac_id = ");
			sbSql.append(pac_id);
		}
		if(!admision.equals("")){
			sbSql.append(" and f.admision = ");
			sbSql.append(admision);
		}
		sbSql.append(" group by f.compania, f.other2, f.pac_id, TO_CHAR (f.fecha_creacion, 'dd/mm/yyyy'), f.pac_id, 'N', f.admision");
	} else {
		sbSql.append("select f.doc_id, f.other3 codigo, to_char(f.doc_date, 'dd/mm/yyyy') doc_date, f.client_id, f.client_name, f.net_amount, f.printed_no, nvl((select distinct 'S' from tbl_fac_marbete m where m.compania = f.company_id and m.doc_id = f.doc_id and m.estado = 'A' and tipo = 'FAC'), 'N') existe from tbl_fac_trx f where f.status != 'I' and exists (select null from tbl_fac_trxitems ti, tbl_inv_articulo a, tbl_inv_familia_articulo fa where ti.codigo = a.cod_articulo and ti.compania = a.compania and a.compania = fa.compania and a.cod_flia = fa.cod_flia and fa.marbete = 'S' and f.company_id = ti.compania and f.doc_id = ti.doc_id) and f.doc_type = 'FAC' and f.company_id = ");
		sbSql.append((String) session.getAttribute("_companyId"));
		if(!client_name.equals("")){
			sbSql.append(" and f.client_name like '%");
			sbSql.append(client_name);
			sbSql.append("%'");
		}
		if(!fecha_desde.equals("")){
			sbSql.append(" and trunc(f.doc_date) >= to_date('");
			sbSql.append(fecha_desde);
			sbSql.append("', 'dd/mm/yyyy')");
		}
		if(!fecha_hasta.equals("")){
			sbSql.append(" and trunc(doc_date) <= to_date('");
			sbSql.append(fecha_hasta);
			sbSql.append("', 'dd/mm/yyyy')");
		}
		if(!no_factura.equals("")){
			sbSql.append(" and f.other3 = '");
			sbSql.append(no_factura);
			sbSql.append("'");
		}
		sbSql.append(" order by other3");
	}

  sbSqlAll.append("select * from (select rownum as rn, a.* from (");
	sbSqlAll.append(sbSql.toString());
	sbSqlAll.append(") a) where rn between ");
	sbSqlAll.append(previousVal);
	sbSqlAll.append(" and ");
	sbSqlAll.append(nextVal);
  al = SQLMgr.getDataList(sbSqlAll.toString());
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+") z");
	
  
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
document.title = 'Marbete - '+document.title;
var ignoreSelectAnyWhere = true;

function printList()
{	
	abrir_ventana('');
}

function showReport(){
	var fDate 			= document.search01.fecha_desde.value;
	var tDate 			= document.search01.fecha_hasta.value;
	var client_name 		= document.search01.client_name.value;
	var no_factura 			= document.search01.no_factura.value;
	//abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=facturacion/informe_ingreso_cxc.rptdesign&pacienteParam='+client_name+'&facturaParam='+no_factura+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&grupoParam='+grupo_empresa+'&empresaParam='+empresa);
}

function addMarbete(doc_id, pac_id, admision, mode)
{
	showPopWin('../pos/reg_marbete.jsp?fg=list_marbete&fp=FAR&mode='+mode+'&doc_id='+doc_id+'&pac_id='+pac_id+'&admision='+admision,winWidth*.75,winHeight*.80,null,null,'');
}

function printMarbete(idDoc){
   abrir_ventana('../pos/print_marbete.jsp?fp=FAR&idDoc='+idDoc);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td><!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
      <table width="100%" cellpadding="0" cellspacing="0">
        <tr class="TextFilter">
          <%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
          <%=fb.formStart()%> 
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
          <td>Fecha: 
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fecha_desde" />
          <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
          <jsp:param name="nameOfTBox2" value="fecha_hasta" />
          <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
          </jsp:include>
					&nbsp;&nbsp;
					Cliente:
					<%=fb.textBox("client_name",client_name,false,false,false,40,"Text10",null,"")%> 
          &nbsp;&nbsp;
					<%if(fp.equals("FAR")){%>
					Admis&oacute;n/Pac. ID:
					<%=fb.textBox("admision",admision,false,false,false,12,"Text10",null,"")%> 
					<%=fb.textBox("pac_id",pac_id,false,false,false,12,"Text10",null,"")%> 
					<%} else {%>
					No. Factura:
					<%=fb.textBox("no_factura",no_factura,false,false,false,12,"Text10",null,"")%> 
					<%}%>
          <%=fb.submit("go","Ir")%> 
          </td>
          <%=fb.formEnd()%> </tr>
      </table>
      <!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
    </td>
  </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableTopBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("admision",admision)%> 
					<%=fb.hidden("pac_id",pac_id)%> 
					<%=fb.hidden("fp",fp)%> 
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("admision",admision)%> 
					<%=fb.hidden("pac_id",pac_id)%> 
					<%=fb.hidden("fp",fp)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
	<tr>
		<td align="right"><authtype type='0'><!--<a href="javascript:showReport()" class="Link00">[ Reporte ]</a>--></authtype></td>
	</tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableLeftBorder TableRightBorder"><!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
      <table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextHeader" align="center">
					<td width="10%"><%=(fp.equals("FAR")?"PAC ID":"No. Factura")%></td>
					<td width="10%"><%=(fp.equals("FAR")?"Admisi&oacute;n":"No. Factura DGI")%></td>
					<td width="10%">Fecha</td>
					<td width="35%">Nombre de Cliente</td>
					<td width="10%">Monto</td>
					<td width="15%">&nbsp;</td>
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
          <td align="center"><%=cdo.getColValue("codigo")%></td>
          <td align="center"><%=(fp.equals("FAR")?cdo.getColValue("admision"):cdo.getColValue("printed_no"))%></td>
          <td align="center"><%=cdo.getColValue("doc_date")%></td>
          <td><%=cdo.getColValue("client_name")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("net_amount"))%></td>
          <td align="center"><authtype type='1'>
					<a href="javascript:addMarbete(<%=cdo.getColValue("doc_id")%>, 'view')" class="Link00Bold">Ver</a>
					</authtype>&nbsp;&#166;&nbsp;
					<authtype type="2">
					  <a href="javascript:printMarbete('<%=cdo.getColValue("doc_id")%>')" class="Link00Bold">Imprimir</a>
					</authtype>
					</td>
          <td align="center">
					<%if(cdo.getColValue("existe").equals("N")){%>
					<authtype type='3'>
					<a href="javascript:addMarbete(<%=cdo.getColValue("doc_id")%>,<%=cdo.getColValue("codigo")%>, <%=cdo.getColValue("admision")%>, 'add')" class="Link00Bold">Registrar</a>
					</authtype>
					<%} else {%>
					<authtype type='4'>
					<a href="javascript:addMarbete(<%=cdo.getColValue("doc_id")%>,<%=cdo.getColValue("codigo")%>, <%=cdo.getColValue("admision")%>, 'edit')" class="Link00Bold">Editar</a>
					</authtype>
					<%}%>
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
    <td class="TableLeftBorder TableBottomBorder TableRightBorder"><table align="center" width="100%" cellpadding="1" cellspacing="0">
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("admision",admision)%> 
					<%=fb.hidden("pac_id",pac_id)%> 
					<%=fb.hidden("fp",fp)%>
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
					<%=fb.hidden("no_factura",no_factura)%> 
					<%=fb.hidden("client_name",client_name)%> 
					<%=fb.hidden("fecha_desde",fecha_desde)%> 
					<%=fb.hidden("fecha_hasta",fecha_hasta)%> 
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("admision",admision)%> 
					<%=fb.hidden("pac_id",pac_id)%> 
					<%=fb.hidden("fp",fp)%>
          <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
          <%=fb.formEnd()%> </tr>
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>
