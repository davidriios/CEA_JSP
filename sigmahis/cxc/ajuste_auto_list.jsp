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
<%
/**
==================================================================================
cxc90061
cxc90062
==================================================================================
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
	String tipo = request.getParameter("tipo");
	String cobrador = request.getParameter("cobrador");
	String nombre = request.getParameter("nombre");
	String estado = request.getParameter("estado");
	String mis_listas = request.getParameter("mis_listas");
	String anio = request.getParameter("anio");
	if (codigo == null) codigo = "";
	if (tipo == null) tipo = "";
	if (cobrador == null) cobrador = "";
	if (nombre == null) nombre = "";
	if (estado == null) estado = "";
	if (mis_listas == null) mis_listas = "";
	else mis_listas = "S";
	if (anio == null) anio = "";

	if (!codigo.trim().equals("")) { sbFilter.append(" and lista = "); sbFilter.append(codigo.toUpperCase());}
	if (!tipo.trim().equals("")) { sbFilter.append(" and a.tipo_ajuste = '"); sbFilter.append(tipo.toUpperCase()); sbFilter.append("'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.status = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); }
	if (mis_listas.trim().equals("S")) { sbFilter.append(" and a.usuario_creacion = '"); sbFilter.append((String) session.getAttribute("_userName")); sbFilter.append("'"); }
	if (!anio.trim().equals("")) { sbFilter.append(" and a.anio = "); sbFilter.append(anio);}

	//if (!cobrador.trim().equals("")) { sbFilter.append(" and upper(decode(a.tipo_cobrador,'E',a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento,'M',''||a.codigo_empresa,' ')) like '"); sbFilter.append(cobrador); sbFilter.append("%'"); }
	//if (!nombre.trim().equals("")) { sbFilter.append(" and upper(a.nombre_cobrador) like '%"); sbFilter.append(nombre.toUpperCase()); sbFilter.append("%'"); }
	//if (sbFilter.length() > 0) sbFilter.replace(0,4," where");

	sbSql.append("select distinct tipo_ajuste, lista, status, compania, decode(status, 'O', 'PENDIENTE', 'C', 'CERRADO', 'R', 'RECHAZADO', status) estado_desc, (case when not exists (select referencia from tbl_fac_nota_ajuste where referencia =a.anio||a.lista and ajuste_lote = 'S') and a.status = 'O'  then 'S' else 'N' end) editar, (case when not exists (select referencia from tbl_fac_nota_ajuste where referencia =a.anio||a.lista and ajuste_lote = 'S') and a.status = 'C' then 'S' else 'N' end) aprobar, anio, (select join(cursor((select descripcion from tbl_fac_tipo_ajuste where compania = a.compania and codigo = a.tipo_ajuste)), ',') from dual) tipo_ajuste_desc, (case when exists (select referencia from tbl_fac_nota_ajuste where referencia =a.anio||a.lista and ajuste_lote = 'S') and a.status = 'C' then 'S' else 'N' end) ver, (select join (cursor ((select distinct usuario_creacion from tbl_cxc_cuentasm cm where cm.compania = a.compania and cm.anio = a.anio and cm.lista = a.lista)), ',') from dual) usuario_creacion,(case when exists (select null from tbl_fac_nota_ajuste where referencia =a.anio||a.lista and ajuste_lote = 'S' and ref_reversion is null) and a.status = 'R' then 'S' else 'N' end) revertirAj from tbl_cxc_cuentasm a where a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" and a.status != 'I' order by 2 desc, 1");
	System.out.println("........................"+sbSql.toString());
	if(sbFilter.length()>0){
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql.toString()+")");
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
<script language="javascript">
document.title = 'Analistas / Cobradores - '+document.title;
function add(){abrir_ventana('../cxc/list_fact_incob_x_saldo.jsp?mode=add&fg=FIS');}
function edit(id,tipo, anio){abrir_ventana('../cxc/list_fact_incob_x_saldo.jsp?mode=edit&lista='+id+'&fg=FIS&tipo_ajuste='+tipo+'&anio='+anio);}
function aprobar(id,tipo, anio){abrir_ventana('../cxc/list_rebajar_incobrables.jsp?mode=edit&lista='+id+'&fg=RI&tipo_ajuste='+tipo+'&anio='+anio);}
function view(id,tipo, anio){abrir_ventana('../cxc/list_rebajar_incobrables.jsp?mode=view&lista='+id+'&fg=RI&tipo_ajuste='+tipo+'&anio='+anio);}
function printList(){abrir_ventana('../cxc/print_ajuste_auto_list.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
function saveTipoCobranza(id,tipo){abrir_ventana('../cxc/reg_analista_tipo_cobranza.jsp?id='+id+'&tipo='+tipo);}
function printNA(){
	var data_ref = eval('document.form0.data_refer'+k).value;
	if(data_ref =='O')abrir_ventana1('../facturacion/print_nota_ajuste.jsp?compania='+compania+'&codigo='+id);else abrir_ventana1('../facturacion/print_nota_ajuste.jsp?fg=ajust&compania='+compania+'&codigo='+id);
}

function rechazar(id,tipo, anio){
	showPopWin('../common/run_process.jsp?fp=LISTA_AJUSTE&actType=5&docType=LISTA_AJUSTE&docId='+id+'&docNo='+id+'&anio='+anio+'&compania=<%=session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');
	}
function revertir(id,anio){
showPopWin('../common/run_process.jsp?fp=LISTA_AJUSTE&actType=51&docType=LISTA_AJUSTE&docId='+id+'&docNo='+id+'&anio='+anio+'&compania=<%=session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CUENTAS POR COBRAR - ANALISTAS / COBRADORES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;<authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Lote de Ajuste ]</a></authtype></td>
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
				<td width="13%">
					<%=fb.checkbox("mis_listas", "S", (!mis_listas.equals("")), false)%>Solo mis Listas
					A&ntilde;o
					<%=fb.textBox("anio",anio,false,false,false,5)%>
					C&oacute;digo
					<%=fb.intBox("codigo","",false,false,false,5)%>
					Tipo
					<%=fb.select(ConMgr.getConnection(),"select fta.codigo as codigo,fta.descripcion as descripcion,decode(fta.tipo_doc,'R','RECIBO','FACTURA')||' - '||(select description from tbl_fac_adjustment_group where id = fta.group_type and status ='A')descGrupo from tbl_fac_tipo_ajuste fta where fta.compania = "+(String) session.getAttribute("_companyId")+" and fta.group_type not in('A','H','D','E','O')  and fta.estatus ='A' and fta.tipo_doc ='F' order by fta.group_type,fta.descripcion ","tipo",tipo,true,false,false,0,"Text10","",null,null,"S")%>
				  	Estado:&nbsp;
					<%=fb.select("estado","O=PENDIENTE,C=CERRADO,R=RECHAZADO",estado,false,false,0,"Text10",null,null,null,"T")%>
					<!--C&oacute;d. Cobrador
					<%=fb.textBox("cobrador","",false,false,false,16)%>-->
					<%=fb.submit("go","Ir")%>
				</td>
<%=fb.formEnd()%>
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right">&nbsp;<authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("mis_listas",mis_listas)%>
<%=fb.hidden("anio",anio)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("mis_listas",mis_listas)%>
<%=fb.hidden("anio",anio)%>
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
		<table align="center" width="100%" cellpadding="0" cellspacing="1" id="list" class="sortable" exclude="4,5">
		<tr class="TextHeader" align="center">
			<td width="7%">A&ntilde;o</td>
			<td width="7%">C&oacute;digo</td>
			<td width="10%">Tipo Ajuste</td>
			<td width="10%">Usuario Creaci&oacute;n</td>
			<td width="12%">Estado</td>
			<td width="8%">&nbsp;</td>
			<td width="8%">&nbsp;</td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="right"><%=cdo.getColValue("anio")%></td>
			<td align="right"><%=cdo.getColValue("lista")%></td>
			<td align="center"><%=cdo.getColValue("tipo_ajuste_desc")%></td>
			<td align="center"><%=cdo.getColValue("usuario_creacion")%></td>
			<td><%=cdo.getColValue("estado_desc")%></td>
			<td align="center">&nbsp;<%if(cdo.getColValue("editar").equals("S")){%><authtype type='4'><a href="javascript:edit(<%=cdo.getColValue("lista")%>,'<%=cdo.getColValue("tipo_ajuste")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>/<authtype type='5'><a href="javascript:rechazar(<%=cdo.getColValue("lista")%>,'<%=cdo.getColValue("tipo_ajuste")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Rechazar</a></authtype><%}%>
			&nbsp;<%if(cdo.getColValue("revertirAj").equals("S")){%><authtype type='51'><a href="javascript:revertir(<%=cdo.getColValue("lista")%>,<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Revertir Aj.</a></authtype>
			<%}%>
			</td>
			<td align="center">&nbsp;<%if(cdo.getColValue("aprobar").equals("S")){%><authtype type='6'><a href="javascript:aprobar(<%=cdo.getColValue("lista")%>,'<%=cdo.getColValue("tipo_ajuste")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Aprobar</a></authtype>/<authtype type='5'><a href="javascript:rechazar(<%=cdo.getColValue("lista")%>,'<%=cdo.getColValue("tipo_ajuste")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Rechazar</a><%}%></authtype>&nbsp;<authtype type='0'><%if(cdo.getColValue("ver").equals("S")){%><a href="javascript:view(<%=cdo.getColValue("lista")%>,'<%=cdo.getColValue("tipo_ajuste")%>',<%=cdo.getColValue("anio")%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a><%}%></authtype></td>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("mis_listas",mis_listas)%>
<%=fb.hidden("anio",anio)%>
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
<%=fb.hidden("codigo",codigo)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("cobrador",cobrador)%>
<%=fb.hidden("nombre",nombre)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("mis_listas",mis_listas)%>
<%=fb.hidden("anio",anio)%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
			</tr>
		</table>
	</td>
</tr>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>