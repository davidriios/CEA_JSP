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
StringBuffer sql = new StringBuffer();
StringBuffer tablas = new StringBuffer();
StringBuffer appendFilterP = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();
StringBuffer appendFilter2 = new StringBuffer();
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String ref_type = request.getParameter("ref_type");
String doc_morosidad = request.getParameter("doc_morosidad");
String prov_saldo = request.getParameter("prov_saldo");
String facturado = request.getParameter("facturado");
if(prov_saldo==null) prov_saldo = "";
if(facturado==null) facturado = "";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql.append("select '01/'||to_char(sysdate, 'mm/yyyy') fecha_ini, to_char(last_day(sysdate), 'dd/mm/yyyy') fecha_fin from dual");
	CommonDataObject cdoF = SQLMgr.getData(sql.toString());
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
	String estado  = "",codigo  = "",nombre  = "",tipo_prov="";
	if (request.getParameter("estado") != null) estado = request.getParameter("estado");
	if (request.getParameter("codigo") != null) codigo = request.getParameter("codigo");
	if (request.getParameter("nombre") != null) nombre = request.getParameter("nombre");
	if (request.getParameter("tipo_prov") != null) tipo_prov = request.getParameter("tipo_prov");

	if (!estado.equals("")){
		appendFilter.append(" and a.estado = '");
		appendFilter.append(request.getParameter("estado").toUpperCase());
		appendFilter.append("'");
	}
 
  if (!codigo.equals("")){ 
		appendFilter.append(" and upper(a.codigo) like '%");
		appendFilter.append(request.getParameter("codigo").toUpperCase());
		appendFilter.append("%'");
	}
  if (!nombre.equals("")){ 
		appendFilter.append(" and upper(a.nombre) like '%");
		appendFilter.append(request.getParameter("nombre").toUpperCase());
		appendFilter.append("%'");
	}
	
  if (ref_type!=null && !ref_type.equals("")){
		appendFilter.append(" and a.ref_type = '");
		appendFilter.append(ref_type.toUpperCase());
		appendFilter.append("'");
		if(ref_type.equals("E")) tablas.append("select 'E' ref_type, to_char(codigo) codigo, nombre, estado from tbl_adm_empresa");
		else if(ref_type.equals("H")) tablas.append("select 'H' ref_type, codigo, primer_nombre || ' ' || segundo_nombre || ' ' || primer_apellido || ' ' || segundo_apellido nombre, estado from tbl_adm_medico");
	} else {
		tablas.append("select 'E' ref_type, to_char(codigo) codigo, nombre, estado from tbl_adm_empresa union select 'H' ref_type, codigo, primer_nombre || ' ' || segundo_nombre || ' ' || primer_apellido || ' ' || segundo_apellido nombre, estado from tbl_adm_medico");
	}
	

	if (request.getParameter("codigo") != null){
	
	sql = new StringBuffer();
	sql.append("select a.nombre, a.ref_type, decode(a.estado, 'A', 'Activo', 'I', 'Inactivo') estado_desc, a.codigo, nvl(b.saldo_inicial, 0) saldo_inicial, nvl(c.debito, 0) debito, nvl(c.credito, 0) credito, (nvl(c.debito, 0) - nvl(c.credito, 0)) saldo from (");
	sql.append(tablas);
	sql.append(") a, (select compania, ref_type, medico, sum(debito) - sum(credito) saldo_inicial from vw_cxp_mov_honorario where compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	if (facturado.equals("S")){ sql.append(" and upper(facturado) = 'S'");}
	sql.append(" and fecha < to_date('");
	sql.append(fechaini);
	sql.append("', 'dd/mm/yyyy') group by compania, ref_type, medico) b, (select compania, ref_type, medico, sum(debito) debito, sum(credito) credito from vw_cxp_mov_honorario where compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	if (facturado.equals("S")){ sql.append(" and upper(facturado) = 'S'");}
	sql.append(" and fecha >= to_date('");
	sql.append(fechaini);
	sql.append("', 'dd/mm/yyyy') and fecha <= to_date('");
	sql.append(fechafin);
	sql.append("', 'dd/mm/yyyy') group by compania, ref_type, medico) c where a.codigo = b.medico(+) and a.codigo = c.medico(+) and a.ref_type = b.ref_type(+) and a.ref_type = c.ref_type(+)");
	if(prov_saldo.equals("CS")){
		sql.append(" and (nvl(b.saldo_inicial, 0) + nvl(c.debito, 0) - nvl(c.credito, 0)) <> 0");
	} else if(prov_saldo.equals("SS")){
		sql.append(" and (nvl(b.saldo_inicial, 0) + nvl(c.debito, 0) - nvl(c.credito, 0)) = 0");
	}
	sql.append(appendFilter.toString());
	al = SQLMgr.getDataList("select * from (select rownum as rn, tmp.* from ("+sql.toString()+" and rownum <= "+nextVal+" order by a.nombre ) tmp ) where rn >= "+previousVal);
    rowCount = CmnMgr.getCount("SELECT count(*) FROM (select 'E' ref_type, to_char(codigo) codigo, nombre, estado from tbl_adm_empresa union select 'H' ref_type, codigo, primer_nombre || ' ' || segundo_nombre || ' ' || primer_apellido || ' ' || segundo_apellido nombre, estado from tbl_adm_medico )"); 
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
document.title = 'Proveedor - '+document.title;
function viewEC(code, tipo){var fechaini = document.search01.fechaini.value;var fechafin = document.search01.fechafin.value;abrir_ventana('../cxp/ver_mov_hon_cargo.jsp?mode=ver&beneficiario='+code+'&tipo='+tipo+'&fechaini='+fechaini+'&fechafin='+fechafin);}
function printList(){abrir_ventana('../cxp/print_list_saldo_proveedor.jsp?codigo=<%=codigo%>&nombre=<%=nombre%>&tipo_prov=<%=tipo_prov%>&estado=<%=estado%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&ref_type=<%=ref_type%>&doc_morosidad=<%=doc_morosidad%>&prov_saldo=<%=prov_saldo%>');}
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
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
					<%
					  fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
				    <%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
 				    <%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			    <tr class="TextFilter">	                    
				    <td><cellbytelabel>C&oacute;digo</cellbytelabel>					
					<%=fb.textBox("codigo",codigo,false,false,false,15)%>
				  <cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,30)%>
					Tipo:<%=fb.select("ref_type","H=MEDICO, E=EMPRESA",ref_type,false,false,0,"",null,null,null,"T")%>
				  <cellbytelabel>Estado</cellbytelabel>
					<%=fb.select("estado","A=Activo, I=Inactivo",estado,false,false,0,"",null,null,null,"T")%>
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
					&nbsp;
					</td>
			    </tr>
			    <tr class="TextFilter">	                    
				    <td>
					Saldo:
					<%=fb.select("prov_saldo","CS=CON SALDO, SS=SALDO 0",prov_saldo,false,false,0,"",null,null,null,"T")%>
					Honorarios:
					<%=fb.select("facturado","S=SOLO FACTURADOS",facturado,false,false,0,"",null,null,null,"T")%>
					<%=fb.submit("go","Ir")%>
					</td>
			    </tr>
				    <%=fb.formEnd()%>		
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
				<%=fb.hidden("tipo_prov",tipo_prov)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("ref_type",ref_type)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("facturado",facturado)%>
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
					<%=fb.hidden("tipo_prov",tipo_prov)%>
					<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("ref_type",ref_type)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("facturado",facturado)%>
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
				<tr class="TextHeader">
					<td width="5%">&nbsp;</td>
					<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="40%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
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
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="right"><%=preVal + i%>&nbsp;</td>
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=cdo.getColValue("estado_desc")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial"))%>&nbsp;&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%>&nbsp;&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(Double.parseDouble(cdo.getColValue("saldo_inicial"))+Double.parseDouble(cdo.getColValue("saldo")))%>&nbsp;&nbsp;</td>
					<td align="center">
					<a href="javascript:viewEC('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("ref_type")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a>
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
				<%=fb.hidden("tipo_prov",tipo_prov)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("ref_type",ref_type)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("facturado",facturado)%>
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
					<%=fb.hidden("tipo_prov",tipo_prov)%>
					<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("ref_type",ref_type)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("facturado",facturado)%>
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
