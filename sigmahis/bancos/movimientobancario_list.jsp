<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
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
String cod_banco = request.getParameter("cod_banco");
String fDate = request.getParameter("fDate");
String tDate = request.getParameter("tDate");
String cuenta_banco = request.getParameter("cuenta_banco");
String nombre_cuenta = request.getParameter("nombre_cuenta");
String nombre_banco = request.getParameter("nombre_banco");
String estado = request.getParameter("estado");
String estado_dep = request.getParameter("estado_dep");
String codigoDesde   = request.getParameter("codigoDesde");
String codigoHasta   = request.getParameter("codigoHasta");
String docType  = request.getParameter("docType");
if (cod_banco == null) cod_banco = "";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";
if (cuenta_banco == null) cuenta_banco = "";
if (nombre_cuenta == null) nombre_cuenta = "";
if (nombre_banco == null) nombre_banco = "";
if (estado == null) estado = "";
//if (estado.trim().equals("")) estado = "T";
if (estado_dep == null) estado_dep = "";
if (codigoDesde == null) codigoDesde = "";
if (codigoHasta == null) codigoHasta = "";
if (docType == null) docType = "";

if (request.getMethod().equalsIgnoreCase("GET"))
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

	if (!cod_banco.trim().equals("")) { sbFilter.append(" and upper(a.banco) like '%"); sbFilter.append(cod_banco.toUpperCase()); sbFilter.append("%'"); }
	if (!tDate.trim().equals("") && !fDate.trim().equals("")) { sbFilter.append(" and trunc(a.f_movimiento) >= to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); sbFilter.append(" and trunc(a.f_movimiento) <= to_date('"); sbFilter.append(fDate); sbFilter.append("','dd/mm/yyyy')"); } else if (!tDate.trim().equals("")) { sbFilter.append(" and trunc(a.f_movimiento) = to_date('"); sbFilter.append(tDate); sbFilter.append("','dd/mm/yyyy')"); }
	if (!cuenta_banco.trim().equals("")) { sbFilter.append(" and upper(a.cuenta_banco) like '%"); sbFilter.append(cuenta_banco.toUpperCase()); sbFilter.append("%'"); }
	if (!estado.trim().equals("")) { sbFilter.append(" and a.estado_trans = '"); sbFilter.append(estado.toUpperCase()); sbFilter.append("'"); } else sbFilter.append(" and a.estado_trans in ('T', 'C', 'A')");
	if (!codigoDesde.trim().equals("")){sbFilter.append(" and a.consecutivo_ag  >= ");sbFilter.append(codigoDesde);}
	if (!codigoHasta.trim().equals("")){sbFilter.append(" and a.consecutivo_ag  <= ");sbFilter.append(codigoHasta);}
	if (!estado_dep.trim().equals("")) { sbFilter.append(" and a.estado_dep = '"); sbFilter.append(estado_dep.toUpperCase()); sbFilter.append("'"); }
	if (!docType.trim().equals("")) { sbFilter.append(" and a.tipo_movimiento = "); sbFilter.append(docType);}


	if (request.getParameter("cod_banco") != null) {
		sbSql = new StringBuffer();
		sbSql.append("select a.consecutivo_ag as consecutivo, a.tipo_movimiento as tipocode, a.cuenta_banco as cuentacode, a.banco as bancocode, to_char(a.f_movimiento,'dd/mm/yyyy') as fecha, to_char(a.fecha_pago,'dd/mm/yyyy') as fechapago, a.estado_dep, a.lado, decode(a.tipo_movimiento,'1',decode(a.estado_dep,'DN','Depositado','DT','En Tránsito'), decode(a.estado_trans,'T','Tramitada','C','Conciliada','A','Anulada'))as estado, a.num_documento as doc, a.estado_trans, a.monto, nvl(( select descripcion from tbl_con_tipo_deposito where codigo = a.tipo_dep), (select descripcion from tbl_con_tipo_movimiento where cod_transac = a.tipo_movimiento) ) as tipo, nvl((select descripcion from tbl_con_cuenta_bancaria where cuenta_banco = a.cuenta_banco and cod_banco = a.banco and compania = a.compania),' ') as cuenta, nvl((select nombre from tbl_con_banco where cod_banco = a.banco and compania = a.compania),' ') as banco,(select count(*) from tbl_con_detalle_cuenta where compania=a.compania and cod_banco=a.banco and cuenta_banco=a.cuenta_banco and fecha_mes=to_number(to_char(a.f_movimiento,'MM')) and cpto_anio=TO_NUMBER(TO_CHAR(a.f_movimiento,'YYYY')) )cr_concil,nvl(a.comprobante,'N') as comprobante from tbl_con_movim_bancario a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(sbFilter);
		sbSql.append(" order by 4, 14, a.f_movimiento, 2");
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from (" + sbSql + ") a) where rn between " + previousVal + " and " + nextVal);

		rowCount = CmnMgr.getCount("select count(*) from ("+sbSql.toString()+")");
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
document.title = 'Movimiento Bancario - '+document.title;
function add(){abrir_ventana('../bancos/movimientobancario_config.jsp');}
function edit(tipo,cuenta,banco,fecha,consecutivo,estado,mode,fp){abrir_ventana('../bancos/movimientobancario_config.jsp?mode='+mode+'&tipo_mov='+tipo+'&cuenta='+cuenta+'&banco='+banco+'&fecha='+fecha+'&consecutivo='+consecutivo+'&fp='+fp);}
function showList(){var cuenta="";var banco="";abrir_ventana1('../bancos/movimientobancario_cheque_list.jsp?mode=edit&cuenta='+cuenta+'&banco='+banco);}
function selCuentaBancaria(i){var cod_banco = eval('document.search01.cod_banco'+i).value;if(cod_banco=='') alert('Seleccione Banco!');else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=cheque&cod_banco='+cod_banco+'&index='+i);}
function printList(){abrir_ventana('../bancos/print_list_mov_bancario.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>');}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="BANCOS - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
		<tr>
				<td align="right"><authtype type='3'><a href="javascript:add()" class="Link00">[ Registrar Nuevo Movimiento Bancario ]</a></authtype></td>
		</tr>
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="1">
				 <%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
						<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				 <tr class="TextFilter">

					<td width="60%">Tipo Doc:

					<%=fb.select(ConMgr.getConnection(),"select cod_transac, cod_transac||' - '||descripcion from tbl_con_tipo_movimiento order by cod_transac","docType",docType,false,false,0, "text10", "", "", "", "T")%>
									<%//=fb.select("docType","1=DEPOSITO,2=N/DEBITO,3=N/CREDITO",docType, false, false,0,"text10",null,"","","T")%>Banco
						 <%=fb.select(ConMgr.getConnection(),"select cod_banco, cod_banco||' - '||nombre from tbl_con_banco where compania = "+session.getAttribute("_companyId")+" order by nombre","cod_banco",cod_banco,false,false,0, "text10", "", "onChange=\"javascript:setFormFieldsBlank(this.form.name,'cuenta_banco,nombre_cuenta')\"", "", "T")%>

					</td>
						<td width="40%"> Cta.:
								<%=fb.textBox("cuenta_banco",cuenta_banco,false,false,true,15,"text10",null,"")%>
				<%=fb.textBox("nombre_cuenta",nombre_cuenta,false,false,true,40,"text10",null,"")%>
								<%=fb.button("buscarCuenta","...",false, false,"text10","","onClick=\"javascript:selCuentaBancaria('')\"")%>
					</td>
										</tr>
					<tr class="TextFilter">
					<td>Estado :
						<%=fb.select("estado","T=Tramitada,C=Conciliada,A=Anulada",estado, false, false,0,"text10",null,"","","T")%>
					&nbsp;&nbsp;
										Fecha
						<jsp:include page="../common/calendar.jsp" flush="true">
						<jsp:param name="noOfDateTBox" value="2" />
						<jsp:param name="nameOfTBox1" value="tDate" />
						<jsp:param name="valueOfTBox1" value="<%=tDate%>" />
						<jsp:param name="fieldClass" value="Text10" />
						<jsp:param name="buttonClass" value="Text10" />
						<jsp:param name="clearOption" value="true" />
						<jsp:param name="nameOfTBox2" value="fDate" />
						<jsp:param name="valueOfTBox2" value="<%=fDate%>" />
						</jsp:include>


					</td>
						<td>Consecutivo:  Desde<%=fb.textBox("codigoDesde",codigoDesde,false,false,false,10,null,null,null)%>Hasta<%=fb.textBox("codigoHasta",codigoHasta,false,false,false,10,null,null,null)%>
					</td>
										</tr>
					<tr class="TextFilter">
						<td colspan="2">Estado Dep&oacute;sito :
						<%=fb.select("estado_dep","DT=EN TRANSITO,DN=DEPOSITADO",estado_dep, false, false,0,"text10",null,"","","T")%>
						<%=fb.submit("go","Ir")%>
						</td>
					</tr>

						<%=fb.formEnd()%>
			</table>
		</td>
	</tr>
		<tr>
				<td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00">[ Imprimir Lista ]</a></authtype></td>
		</tr>
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("docType",docType)%>
				<%=fb.hidden("codigoDesde",codigoDesde)%>
				<%=fb.hidden("codigoHasta",codigoHasta)%>
				<%=fb.hidden("estado_dep",estado_dep)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
				<%	fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp"); %>
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("docType",docType)%>
				<%=fb.hidden("codigoDesde",codigoDesde)%>
				<%=fb.hidden("codigoHasta",codigoHasta)%>
				<%=fb.hidden("estado_dep",estado_dep)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader">
									<td width="17%" align="center">Tipo</td>
										<td width="20%" align="center">Banco</td>
					<td width="18%" align="center">Cuenta</td>
					<td width="08%" align="center">Consecutivo</td>
						<td width="8%" align="center">Documento</td>
					<td width="7%" align="center">Fecha</td>
					<td width="7%" align="center">Estado</td>
										<td width="7%" align="center">Monto</td>
						<td width="4%">&nbsp;</td>
					<td width="4%">&nbsp;</td>

				</tr>
				<%
				String bank="";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>


								 <%
					if (!bank.equalsIgnoreCase(cdo.getColValue("bancoCode")+"-"+cdo.getColValue("cuenta")))
				{
				%>
								<tr class="TextRow03" onMouseOver="setoverc(this,'TextRow03')" onMouseOut="setoutc(this,'TextRow03')">
				<td colspan="7"> Banco : [ <%=cdo.getColValue("bancoCode")%> ] <%=cdo.getColValue("banco")%>  Cta : <%=cdo.getColValue("cuenta")%> </td>
								<td colspan="3" align="center">&nbsp;	</td>
								</tr>
								<% }
				%>
									<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("tipo")%></td>

										<td><%=cdo.getColValue("banco")%></td>
					<td><%=cdo.getColValue("cuenta")%></td>
					<td><%=cdo.getColValue("consecutivo")%></td>
					<td><%=cdo.getColValue("doc")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("estado")%></td>
										<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%></td>
					<td align="center">
					<%if((!cdo.getColValue("cr_concil").trim().equals("0") || cdo.getColValue("comprobante").trim().equals("S")) && cdo.getColValue("estado_trans").trim().equals("A")){%><authtype type='50'><a href="javascript:edit('<%=cdo.getColValue("tipoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("fecha")%>',<%=cdo.getColValue("consecutivo")%>,'<%=cdo.getColValue("estado_trans")%>','edit','sup')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar Sup. </a></authtype>
					
					<%}%>
					
					<%if(cdo.getColValue("tipoCode") != null && !cdo.getColValue("tipoCode").trim().equals("") && cdo.getColValue("tipoCode").trim().equals("1")&&cdo.getColValue("comprobante").trim().equals("N")){
					 if((cdo.getColValue("estado_trans") != null && !cdo.getColValue("estado_trans").trim().equals("") && cdo.getColValue("estado_trans").trim().equals("T") &&cdo.getColValue("estado_dep") != null && !cdo.getColValue("estado_dep").trim().equals("") && cdo.getColValue("estado_dep").trim().equals("DT"))||cdo.getColValue("cr_concil").trim().equals("0")){%>
					<authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("tipoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("fecha")%>',<%=cdo.getColValue("consecutivo")%>,'<%=cdo.getColValue("estado_trans")%>','edit','')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype><%}
					}else {if(((cdo.getColValue("estado_trans") != null && !cdo.getColValue("estado_trans").trim().equals("") && cdo.getColValue("estado_trans").trim().equals("T"))||cdo.getColValue("cr_concil").trim().equals("0"))&&cdo.getColValue("comprobante").trim().equals("N")){%>
					<authtype type='4'><a href="javascript:edit('<%=cdo.getColValue("tipoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("fecha")%>',<%=cdo.getColValue("consecutivo")%>,'<%=cdo.getColValue("estado_trans")%>','edit','')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
					<%}}%>
					</td>
					<td align="center">
					<authtype type='1'><a href="javascript:edit('<%=cdo.getColValue("tipoCode")%>','<%=cdo.getColValue("cuentaCode")%>','<%=cdo.getColValue("bancoCode")%>','<%=cdo.getColValue("fecha")%>',<%=cdo.getColValue("consecutivo")%>,'<%=cdo.getColValue("estado_trans")%>','view')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Ver</a></authtype>
					</td>

				</tr>
				<%
				bank = cdo.getColValue("bancoCode")+"-"+cdo.getColValue("cuenta");
				}
				%>
			</table>
	</div>
</div>
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("docType",docType)%>
				<%=fb.hidden("codigoDesde",codigoDesde)%>
				<%=fb.hidden("codigoHasta",codigoHasta)%>
				<%=fb.hidden("estado_dep",estado_dep)%>
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
				<%=fb.hidden("cuenta_banco",cuenta_banco)%>
				<%=fb.hidden("cod_banco",cod_banco)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("nombre_cuenta",nombre_cuenta)%>
				<%=fb.hidden("tDate",tDate)%>
				<%=fb.hidden("fDate",fDate)%>
				<%=fb.hidden("docType",docType)%>
				<%=fb.hidden("codigoDesde",codigoDesde)%>
				<%=fb.hidden("codigoHasta",codigoHasta)%>
				<%=fb.hidden("estado_dep",estado_dep)%>
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
