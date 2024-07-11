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
StringBuffer appendFilterP = new StringBuffer();
StringBuffer appendFilter = new StringBuffer();
StringBuffer appendFilter2 = new StringBuffer();
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String tipoFac = request.getParameter("tipoFac");
String doc_morosidad = request.getParameter("doc_morosidad");
String prov_saldo = request.getParameter("prov_saldo");
String fg = request.getParameter("fg");

String comprob = request.getParameter("comprob");
String anio = request.getParameter("anio");
String consecutivo = request.getParameter("consecutivo");
if(fg==null) fg = "PR";
if(prov_saldo==null) prov_saldo = "";
String vista ="vw_cxp_mov_proveedor";
if(fg.trim().equals("MG"))vista ="vw_cxp_mov_proveedor_mg";

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

	appendFilterP.append(" and pp.compania = ");
	appendFilterP.append((String) session.getAttribute("_companyId"));
	if (!estado.equals("")){
		appendFilterP.append(" and pp.estado_proveedor = '");
		appendFilterP.append(request.getParameter("estado").toUpperCase());
		appendFilterP.append("'");
	}
 //else appendFilter=appendFilter+" and upper(p.estado_proveedor)<> 'INA'";

	if (!codigo.equals("")){
		appendFilterP.append(" and upper(pp.cod_provedor) like '%");
		appendFilterP.append(request.getParameter("codigo").toUpperCase());
		appendFilterP.append("%'");
	}
	if (!nombre.equals("")){
		appendFilterP.append(" and upper(pp.nombre_proveedor) like '%");
		appendFilterP.append(IBIZEscapeChars.forSingleQuots(request.getParameter("nombre").toUpperCase()));
		appendFilterP.append("%'");
	}
	if (!tipo_prov.equals("")){
		appendFilterP.append(" and upper(pp.tipo_prove) = '");
		appendFilterP.append(request.getParameter("tipo_prov").toUpperCase());
		appendFilterP.append("'");
	}
	if (tipoFac!=null && !tipoFac.equals("")){
		appendFilter.append(" and upper(v.fg) != '");
		appendFilter.append(tipoFac.toUpperCase());
		appendFilter.append("'");
	}
	if (anio!=null && !anio.equals("")){
		appendFilter.append(" and v.anio_comprob=");
		appendFilter.append(anio);
	}
	if (consecutivo!=null && !consecutivo.equals("")){
		appendFilter.append(" and v.consecutivo=");
		appendFilter.append(consecutivo);
	}
	if (comprob!=null && !comprob.equals("")){
		appendFilter.append(" and upper(v.comprob) = '");
		appendFilter.append(comprob.toUpperCase());
		appendFilter.append("'");
	}
	if(doc_morosidad==null) doc_morosidad="";
	if(!doc_morosidad.equals("")){
		appendFilter.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		appendFilter.append(doc_morosidad);
		appendFilter.append("'");
		appendFilter2.append(" and (case when fg in ('NA', 'PNA') and tipo_doc != 'AUX' then 'DSF' else 'DCF' end) = '");
		appendFilter2.append(doc_morosidad);
		appendFilter2.append("'");
	}

	if (request.getParameter("codigo") != null){

	sql = new StringBuffer();
	sql.append("select pp.compania, pp.cod_provedor codigo, pp.nombre_proveedor nombre, decode (pp.estado_proveedor, 'ACT', 'ACTIVO', 'INA', 'INACTIVO') as estado_desc, nvl(v.saldo_inicial, 0) saldo_inicial ,  nvl(p.debito, 0) debito, nvl(p.credito, 0) credito, nvl(p.movimiento, 0) movimiento, nvl(v.saldo_inicial,0) + nvl(p.movimiento,0) saldo,  pp.cat_cta1||'-'||pp.cat_cta2||'-'||pp.cat_cta3||'-'||pp.cat_cta4||'-'||pp.cat_cta5||'-'||pp.cat_cta6||' - '||(select descripcion from tbl_con_catalogo_gral where compania=pp.compania and cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6=pp.cat_cta1||'-'||pp.cat_cta2||'-'||pp.cat_cta3||'-'||pp.cat_cta4||'-'||pp.cat_cta5||'-'||pp.cat_cta6 ) cuenta from (select v.cod_proveedor, v.compania, sum(nvl(v.debito, 0)) debito,  sum(nvl(v.credito, 0)) credito, sum(nvl(v.debito, 0) - nvl(v.credito, 0)) movimiento from ");
		sql.append(vista);
	sql.append(" v where v.compania = ");
	sql.append((String) session.getAttribute("_companyId"));
	sql.append(appendFilter.toString());
	sql.append(" and trunc(v.fecha_documento) between to_date('");
	sql.append(fechaini);
	sql.append("', 'dd/mm/yyyy') and  to_date('");
	sql.append(fechafin);
	sql.append("', 'dd/mm/yyyy') and nvl(v.tipo_doc,'OT')  !='FACTP' group by v.compania, v.cod_proveedor) p, tbl_com_proveedor pp, (select compania, cod_proveedor, sum(nvl (debito, 0) - nvl(credito, 0)) saldo_inicial from ");
		sql.append(vista);
	sql.append("  where trunc(fecha_documento) < to_date('");
	sql.append(fechaini);
	sql.append("', 'dd/mm/yyyy') and nvl(tipo_doc,'OT') !='FACTP'");
	if(tipoFac!=null && !tipoFac.equals("")){
		sql.append(" and fg != '");
		sql.append(tipoFac);
		sql.append("'");
	}
	sql.append(appendFilter2.toString());
	sql.append(" group by compania, cod_proveedor) v where v.cod_proveedor(+) = pp.cod_provedor and v.compania(+) = pp.compania and p.cod_proveedor(+) = pp.cod_provedor and p.compania(+) = pp.compania");
	sql.append(appendFilterP.toString());
	if(prov_saldo.equals("CS")){
		sql.append(" and nvl(p.movimiento, 0) + nvl(v.saldo_inicial, 0) <> 0");
	} else if(prov_saldo.equals("SS")){
		sql.append(" and nvl(p.movimiento, 0) + nvl(v.saldo_inicial, 0) = 0");
	}

	sql.append(" order by pp.nombre_proveedor");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sql.toString()+")");
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
function edit(code){abrir_ventana('../cxp/ver_mov_proveedor.jsp?mode=ver&cod_proveedor='+code+'&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&tipoFac=<%=tipoFac%>&doc_morosidad=<%=doc_morosidad%>&fg=<%=fg%>');}
function printList(){abrir_ventana('../cxp/print_list_saldo_proveedor.jsp?codigo=<%=codigo%>&nombre=<%=IBIZEscapeChars.forURL(nombre)%>&tipo_prov=<%=tipo_prov%>&estado=<%=estado%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&tipoFac=<%=tipoFac%>&doc_morosidad=<%=doc_morosidad%>&prov_saldo=<%=prov_saldo%>&fg=<%=fg%>&comprob=<%=comprob%>&anio=<%=anio%>&consecutivo=<%=consecutivo%>');}
function cheques()
{
abrir_ventana('../cxp/ver_cxp_cheques.jsp?mode=ver&cod_proveedor=<%=codigo%>&fechaini=<%=fechaini%>&fechafin=<%=fechafin%>&fg=<%=fg%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CXP - SALDO DE PROVEEDORES"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
					<tr class="TextFilter">
					<%//=sql.toString()%>
					<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fg",fg)%>
						<td><cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("codigo",codigo,false,false,false,15)%>
					<cellbytelabel>Nombre</cellbytelabel>
					<%=fb.textBox("nombre",nombre,false,false,false,30)%>
					Tipo Prov:<%=fb.select(ConMgr.getConnection(), "select tipo_proveedor, descripcion||' - '||tipo_proveedor as descripcion from tbl_com_tipo_proveedor", "tipo_prov",tipo_prov,"S")%>
					<cellbytelabel>Estado Prov.</cellbytelabel>
					<%=fb.select("estado","ACT=Activo, INA=Inactivo",estado,false,false,0,"",null,null,null,"T")%>
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
					&nbsp;Facturas:
					<%=fb.select("tipoFac","CONT=SIN FACTURAS CONTADO, TD=TODAS LAS FACTURAS",tipoFac,false,false,0,"",null,null,null,"")%>
					Doctos. Morosidad:
					<%=fb.select("doc_morosidad","DCF=DOCUMENTOS CON FACTURAS, DSF=DOCUMENTOS SIN FACTURAS",doc_morosidad,false,false,0,"",null,null,null,"T")%>
					Saldo:
					<%=fb.select("prov_saldo","CS=CON SALDO, SS=SALDO 0",prov_saldo,false,false,0,"",null,null,null,"T")%>
					Comprob:
					<%=fb.select("comprob","GASTO=GASTO,RECEP=RECEPCIONES,CHEQUE=CHEQUE,AUX=AUXILIAR",comprob,false,false,0,"",null,null,null,"T")%>
					Año<%=fb.textBox("anio",anio,false,false,false,15)%>
					No. Comprob <%=fb.textBox("consecutivo",consecutivo,false,false,false,15)%>
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
		<authtype type='50'><a href="javascript:cheques()" class="Link00">[ <cellbytelabel>Ver Cheques</cellbytelabel> ]</a></authtype>
		<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel>Imprimir Lista</cellbytelabel> ]</a></authtype>
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
				<%=fb.hidden("tipoFac",tipoFac)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("comprob",comprob)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("consecutivo",consecutivo)%>
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
				<%=fb.hidden("tipoFac",tipoFac)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("comprob",comprob)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("consecutivo",consecutivo)%>
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
					<td width="5%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="24%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="28%"><cellbytelabel>Cuenta</cellbytelabel></td>
					<td width="6%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Débito</cellbytelabel></td>
					<td width="8%" align="center"><cellbytelabel>Crédito</cellbytelabel></td>
					<td width="10%" align="center"><cellbytelabel>Saldo</cellbytelabel></td>
					<td width="3%">&nbsp;</td>
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
					<td><%=cdo.getColValue("nombre")%></td>
					<td><%=cdo.getColValue("cuenta")%></td>
					<td align="center"><%=cdo.getColValue("estado_desc")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo_inicial"))%>&nbsp;&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("debito"))%>&nbsp;&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%>&nbsp;&nbsp;</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("saldo"))%>&nbsp;&nbsp;</td>
					<td align="center">
					<a href="javascript:edit('<%=cdo.getColValue("codigo")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><cellbytelabel>Ver</cellbytelabel></a>
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
				<%=fb.hidden("tipoFac",tipoFac)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("comprob",comprob)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("consecutivo",consecutivo)%>
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
				<%=fb.hidden("tipoFac",tipoFac)%>
				<%=fb.hidden("doc_morosidad",doc_morosidad)%>
				<%=fb.hidden("prov_saldo",prov_saldo)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("comprob",comprob)%>
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("consecutivo",consecutivo)%>
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
