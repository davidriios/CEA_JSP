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
<%
/** ---------------------------------------------------------------------------------------------------*/
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
StringBuffer sbSql = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from dual";
	CommonDataObject cdoF = SQLMgr.getData(sql);
	if(fechaini==null) fechaini = cdoF.getColValue("fecha_ini");
	if(fechafin==null) fechafin = cdoF.getColValue("fecha_fin");

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
	String estado  = "",id_beneficiario  = "",nombre  = "",tipo_benef="";
	if (request.getParameter("estado") != null) estado = request.getParameter("estado");
	if (request.getParameter("id_beneficiario") != null) id_beneficiario = request.getParameter("id_beneficiario");
	if (request.getParameter("nombre") != null) nombre = request.getParameter("nombre");
	if (request.getParameter("tipo_benef") != null) tipo_benef = request.getParameter("tipo_benef");

 if (!estado.equals("")){
	appendFilter.append(" and p.estado_proveedor = '");
	appendFilter.append(estado);
	appendFilter.append("'");
 }
 
  if (!id_beneficiario.equals("")){
		appendFilter.append(" and upper(v.id_beneficiario) like '%");
		appendFilter.append(id_beneficiario);
		appendFilter.append("%'");
	}
  if (!nombre.equals("")){
		appendFilter.append(" and upper(v.nombre_cliente) like '%");
		appendFilter.append(nombre.toUpperCase());
		appendFilter.append("%'");
  }
	if (!tipo_benef.equals("")){
		appendFilter.append(" and upper(v.tipo_benef) = '");
		appendFilter.append(tipo_benef.toUpperCase());
		appendFilter.append("'");
	}
	
	//if (!id_beneficiario.equals("")){		
	sbSql.append("select p.*, nvl(v.saldo_inicial, 0) saldo_inicial from (select v.compania, v.id_beneficiario, v.tipo_benef, v.nombre_cliente nombre, sum(nvl(v.debito, 0) - nvl(v.credito, 0)) saldo from vw_pm_mov_clte v where v.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(appendFilter);
	sbSql.append(" and trunc (v.fecha_documento(+)) between to_date('");
	sbSql.append(fechaini);
	sbSql.append("', 'dd/mm/yyyy') and to_date('");
	sbSql.append(fechafin);
	sbSql.append("', 'dd/mm/yyyy') group by compania, id_beneficiario, v.tipo_benef, nombre_cliente) p, (select compania, id_beneficiario, tipo_benef, sum (nvl(debito, 0) - nvl (credito, 0)) saldo_inicial from vw_pm_mov_clte where trunc(fecha_documento) < to_date('");
	sbSql.append(fechaini);
	sbSql.append("', 'dd/mm/yyyy') group by compania, id_beneficiario, tipo_benef) v where v.id_beneficiario(+) = p.id_beneficiario and v.compania(+) = p.compania order by p.nombre");	
	
	
	//sql = "select p.*, nvl(v.saldo_inicial, 0) saldo_inicial from (select p.compania, p.cod_provedor id_beneficiario, p.nombre_proveedor nombre, decode (p.estado_proveedor, 'ACT', 'ACTIVO', 'INA', 'INACTIVO') as estado_desc, sum(nvl(v.debito, 0) - nvl(v.credito, 0)) saldo from tbl_com_proveedor p, vw_cxp_mov_proveedor v where p.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and upper(p.estado_proveedor) <> 'INA' and v.cod_proveedor(+) = p.cod_provedor and v.compania(+) = p.compania and trunc(v.fecha_documento(+)) between to_date('"+fechaini+"', 'dd/mm/yyyy') and  to_date('"+fechafin+"', 'dd/mm/yyyy') and nvl(v.tipo_doc,'OT')  !='FACTP' group by p.compania, p.cod_provedor, p.nombre_proveedor, decode(estado_proveedor, 'ACT', 'ACTIVO', 'INA', 'INACTIVO')) p, (select   compania, cod_proveedor, sum(nvl (debito, 0) - nvl(credito, 0)) saldo_inicial from vw_cxp_mov_proveedor where trunc(fecha_documento) < to_date('"+fechaini+"', 'dd/mm/yyyy') and nvl(tipo_doc,'OT') !='FACTP' group by compania, cod_proveedor) v where v.cod_proveedor(+) = p.id_beneficiario and v.compania(+) = p.compania order by p.nombre";
	
  al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
  rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
  //}

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
document.title = 'Proveedor - '+document.title;
function edit(code,i){var nombre = eval('document.detail.nombre_beneficiario'+i).value;abrir_ventana('../planmedico/ver_mov_clte.jsp?mode=ver&id_beneficiario='+code+'&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&nombre='+nombre);}
function printList(){abrir_ventana('../cxp/print_list_saldo_proveedor.jsp?id_beneficiario=<%=id_beneficiario%>&nombre=<%=nombre%>&tipo_benef=<%=tipo_benef%>&estado=<%=estado%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
			    <tr class="TextFilter">	                    
					<%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				    <td><cellbytelabel>C&oacute;digo</cellbytelabel>					
					<%=fb.textBox("id_beneficiario",id_beneficiario,false,false,false,15)%>
				  <cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,30)%>
					<%=fb.select("tipo_benef","E=Empresa,B=Beneficiario,M=Medico,S=Sociedad Medica",tipo_benef,false,false,false,0,"Text10","","")%>
				  <!--<cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("estado","ACT=Activo, INA=Inactivo",estado,null)%>-->
          &nbsp;<cellbytelabel>Fecha</cellbytelabel>
          <jsp:include page="../common/calendar.jsp" flush="true">
          <jsp:param name="noOfDateTBox" value="2" />
          <jsp:param name="clearOption" value="true" />
          <jsp:param name="nameOfTBox1" value="fechaini" />
          <jsp:param name="valueOfTBox1" value="<%=fechaini%>" />
          <jsp:param name="nameOfTBox2" value="fechafin" />
          <jsp:param name="valueOfTBox2" value="<%=fechafin%>" />
          <jsp:param name="fieldClass" value="text10" />
          <jsp:param name="buttonClass" value="text10" />
          </jsp:include>
					<%=fb.submit("go","Ir")%>
					</td>
				    <%=fb.formEnd()%>		
			    </tr>
			</table>
		</td>
	</tr>
    </tr>
</table>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right">
		<authtype type='0'><!--<a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a>--></authtype>
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
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("tipo_benef",tipo_benef)%>
				<%=fb.hidden("id_beneficiario",id_beneficiario)%>
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
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fechaini",fechaini)%>
					<%=fb.hidden("fechafin",fechafin)%>
					<%=fb.hidden("tipo_benef",tipo_benef)%>
					<%=fb.hidden("id_beneficiario",id_beneficiario)%>
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
			<%
					fb = new FormBean("detail",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
					<td width="5%">&nbsp;</td>
					<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Nombre</cellbytelabel></td>
					<!--<td width="10%" align="center"><cellbytelabel>Estado</cellbytelabel></td>-->
					<td width="10%" align="center"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>Movimiento</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>Saldo</cellbytelabel></td>
					<td width="5%">&nbsp;</td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("nombre_beneficiario"+i, cdo.getColValue("nombre"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td align="center"><%=cdo.getColValue("id_beneficiario")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<!--<td align="center"><%=cdo.getColValue("estado_desc")%></td>-->
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial"))%>&nbsp;&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%>&nbsp;&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("saldo_inicial"))+Double.parseDouble(cdo.getColValue("saldo")))%>&nbsp;&nbsp;</td>
					<td align="center">
					<a href="javascript:edit('<%=cdo.getColValue("id_beneficiario")%>', <%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a>
					</td>
				</tr>
				<%
				}
				%>							
			</table>
	<%=fb.formEnd()%>
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
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("fechaini",fechaini)%>
				<%=fb.hidden("fechafin",fechafin)%>
				<%=fb.hidden("tipo_benef",tipo_benef)%>
				<%=fb.hidden("id_beneficiario",id_beneficiario)%>
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
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fechaini",fechaini)%>
					<%=fb.hidden("fechafin",fechafin)%>
					<%=fb.hidden("tipo_benef",tipo_benef)%>
					<%=fb.hidden("id_beneficiario",id_beneficiario)%>
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
