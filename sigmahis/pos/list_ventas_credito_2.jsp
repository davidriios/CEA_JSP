<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
int rowCount = 0;
String usuario_factura =request.getParameter("usuario_factura");


if (request.getMethod().equalsIgnoreCase("GET")){
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
	}
	String tipoClte = "", codigo = "", descripcion = "", fDate = "", tDate = "", refer_to = "", cod_caja = "", cajero = "", turno = "", tipo_factura = "", tipoOtro = "";
	if(request.getParameter("tipoClte") != null) tipoClte = request.getParameter("tipoClte");
	if(request.getParameter("codigo") != null) codigo = request.getParameter("codigo");
	if(request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");
	if(request.getParameter("fDate") != null) fDate = request.getParameter("fDate");
	if(request.getParameter("tDate") != null) tDate = request.getParameter("tDate");
	if(request.getParameter("refer_to") != null) refer_to = request.getParameter("refer_to");
	if(request.getParameter("cod_caja") != null) cod_caja = request.getParameter("cod_caja");
	if(usuario_factura==null) usuario_factura = (String) session.getAttribute("_userName");
	if(request.getParameter("cajero") != null) cajero = request.getParameter("cajero");
	if(request.getParameter("turno") != null) turno = request.getParameter("turno");
	if(request.getParameter("tipo_factura") != null) tipo_factura = request.getParameter("tipo_factura");
	if(request.getParameter("tipoOtro") != null) tipoOtro = request.getParameter("tipoOtro");


	StringBuffer sbCaja = new StringBuffer();
	StringBuffer sbUsuario = new StringBuffer();
	if (UserDet.getUserProfile().contains("0")) {
		sbCaja.append("select codigo id, trim(to_char(codigo,'009')) ||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
		sbCaja.append((String) session.getAttribute("_companyId"));
		sbCaja.append(" and estado = 'A' order by descripcion");
	} else {
		sbCaja.append("select codigo id, trim(to_char(codigo,'009')) ||' - '||descripcion as descripcion from tbl_cja_cajas where compania = ");
		sbCaja.append((String) session.getAttribute("_companyId"));
		sbCaja.append(" and codigo in (");
		sbCaja.append((String) session.getAttribute("_codCaja"));
		sbCaja.append(") and ip = '");
		sbCaja.append(request.getRemoteAddr());
		sbCaja.append("' and estado = 'A' order by descripcion");
	}

	sbUsuario.append("select user_name, name from tbl_sec_users u where user_status = 'A' and exists (select null from tbl_cja_cajera c where c.usuario = u.user_name and c.compania = ");
	sbUsuario.append(session.getAttribute("_companyId"));
	sbUsuario.append(") order by name");

	StringBuffer sbSql = new StringBuffer();

	sbSql.append("select oc.descripcion ref_desc, f.doc_id, to_char(f.doc_date, 'dd/mm/yyyy') fecha, f.printed_no factura, f.client_id, f.client_name, decode(f.doc_type, 'NCR', -f.net_amount, f.net_amount) net_amount, decode(oc.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = f.client_id), f.client_id) num_empleado, oc.refer_to, (select nombre from tbl_cja_cajera where cod_cajera = f.cod_cajero and compania = f.company_id) nombre_cajero, decode(f.doc_type, 'FAC', f.other3, f.doc_id) codigo_ref,decode(f.doc_type, 'FAC', 'FACP', 'NCR', 'NCP', 'NDB', 'NDP')as tipoDocto, f.doc_type, f.tipo_factura,nvl((select max(ruc) from tbl_cxc_cliente_particular where compania = f.company_id and to_char(codigo) = f.client_id),' ') as clientRuc, fp.monto monto_credito, (select limite_subsidio from tbl_cxc_tipo_otro_cliente toc where toc.id = f.sub_ref_id and toc.compania = f.company_id) monto_subsidio from tbl_fac_trx f, tbl_fac_tipo_cliente oc, (select compania, doc_id, sum(monto) monto from tbl_fac_trx_forma_pagos where compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and to_char(fp_codigo) = (select get_sec_comp_param(compania, 'FORMA_PAGO_CREDITO') from dual) group by compania, doc_id) fp where f.client_ref_id = oc.codigo and f.company_id = oc.compania and oc.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and oc.es_clt_cr = 'S' ");
	sbSql.append(" and f.company_id = fp.compania and f.doc_id = fp.doc_id and fp.monto > 0");

	if(!codigo.equalsIgnoreCase("")){
		if(refer_to.equals("EMPL")){
			sbSql.append(" and exists (select null from tbl_pla_empleado e where to_char(emp_id) = f.client_id and num_empleado like '%");
			sbSql.append(codigo);
			sbSql.append("%')");
		} else {
			sbSql.append(" and upper(f.client_id) like '");
			sbSql.append(codigo);
			sbSql.append("%'");
		}

	}
	if(!descripcion.equalsIgnoreCase("")){
		sbSql.append(" and upper(f.client_name) like '%");
		sbSql.append(descripcion);
		sbSql.append("%'");
	}
	if(!cod_caja.equalsIgnoreCase("")){
		sbSql.append(" and f.cod_caja = ");
		sbSql.append(cod_caja);
	}

	if(!fDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(f.doc_date) >= to_date('");
		sbSql.append(fDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!tDate.equalsIgnoreCase("")){
		sbSql.append(" and trunc(f.doc_date) <= to_date('");
		sbSql.append(tDate);
		sbSql.append("', 'dd/mm/yyyy')");
	}

		if(!cajero.equals("")){
		sbSql.append(" and f.cod_cajero = '");
		sbSql.append(cajero);
		sbSql.append("'");
	}
	if(!turno.equals("")){
		sbSql.append(" and f.turno = ");
		sbSql.append(turno);
	}
	if(!tipo_factura.equals("")){
		sbSql.append(" and f.tipo_factura = '");
		sbSql.append(tipo_factura);
		sbSql.append("'");
	}





	if(!tipoClte.equalsIgnoreCase("")){
		sbSql.append(" and oc.codigo = ");
		sbSql.append(tipoClte);

		if (refer_to.equalsIgnoreCase("CXCO")) {

			if (!tipoOtro.trim().equals("")) {

				sbSql.append(" and exists (select null from tbl_cxc_cliente_particular where compania = f.company_id and to_char(codigo) = f.client_id and tipo_cliente = ");
				sbSql.append(tipoOtro);
				sbSql.append(")");

			}

		}

		sbSql.append(" order by f.tipo_factura, oc.descripcion, f.client_name, f.client_id");
		StringBuffer sbSqlT = new StringBuffer();
		sbSqlT.append("select * from (select rownum as rn, z.* from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(") z) where rn between ");
		sbSqlT.append(previousVal);
		sbSqlT.append(" and ");
		sbSqlT.append(nextVal);
		al = SQLMgr.getDataList(sbSqlT.toString());
		sbSqlT = new StringBuffer();
		sbSqlT.append("select count(*) as count from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(")");
		rowCount = CmnMgr.getCount(sbSqlT.toString());
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
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Ventas a Crédito - '+document.title;
function view(idRef,tipoDocto){abrir_ventana('../facturacion/ver_impresion_dgi.jsp?fg=POS&fp=docto_dgi_list&actType=2&docType=DGI&docId='+idRef+'&tipoDocto='+tipoDocto);}
function showReport(){
	var refer_to 		= document.search01.refer_to.value;
	var tipoClte 		= document.search01.tipoClte.value;
	var codigo 			= document.search01.codigo.value;
	var descripcion	= document.search01.descripcion.value;
	var fDate 			= document.search01.fDate.value;
	var tDate 			= document.search01.tDate.value;
	var cod_caja 			= document.search01.cod_caja.value;
	var cajero 			= document.search01.cajero.value;
	var turno 			= document.search01.turno.value;
	var tipo_factura 			= document.search01.tipo_factura.value;
	var tipoOtro=document.search01.tipoOtro.value;
	if(cod_caja=='') cod_caja='-1';
	if(tipoOtro==undefined||tipoOtro==null)tipoOtro='';
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=pos/ventas_credito_2.rptdesign&tipoCltParam='+tipoClte+'&codCltParam='+codigo+'&nameCltParam='+descripcion+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&cajeroParam='+cajero+'&turnoParam='+turno+'&codCajaParam='+cod_caja+'&tipoOtroParam='+tipoOtro+'&referToParam='+refer_to+'&tipoFactParam='+tipo_factura);
}
function setReferTo(obj){var referTo=getSelectedOptionTitle(obj,'');document.search01.refer_to.value=referTo;chkOther(referTo);}

function showTurno()
{
var cajero = document.search01.cajero.value ;
if(cajero=='') alert('Seleccione Cajero!');
else abrir_ventana2('../caja/turnos_list.jsp?fp=ventas_descuento&cod_cajera='+cajero);
}
function doAction(){chkOther('<%=refer_to%>');}
function chkOther(referTo){document.search01.tipoOtro.disabled=(referTo!='CXCO');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="TITLE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">
			<authtype type='3'><!--<a href="javascript:add()" class="Link00">[ Registrar Nuevo ]</a>--></authtype>
		</td>
	</tr>
	<tr>
		<td>
		<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
					<%
					fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("refer_to", refer_to)%>
					<td>
					Tipo:
					<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, refer_to from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" and es_clt_cr = 'S' order by descripcion","tipoClte",tipoClte,false,false,0,"Text10","","onChange=\"javascript:setReferTo(this);\"","","S")%>
					<%=fb.select(ConMgr.getConnection(),"select id, descripcion, id from tbl_cxc_tipo_otro_cliente where compania = "+session.getAttribute("_companyId")+" and estado = 'A' order by descripcion","tipoOtro",tipoOtro,false,false,0,"Text10","","","","T")%>
					Tipo Factura:
					<%=fb.select("tipo_factura","CR=Credito,CO=Contado",tipo_factura,false,false,0,null,null,"", "", "T", "")%>
					Caja:
					<%=fb.select(ConMgr.getConnection(),sbCaja.toString(),"cod_caja",cod_caja,false,false,0, "text10", "", "", "", "T")%>
					Cajero:
					<%=fb.select(ConMgr.getConnection(),"select cod_cajera, lpad(cod_cajera, 3, '0') ||' - ' || nombre descripcion from tbl_cja_cajera where compania = "+(String) session.getAttribute("_companyId")+" order by nombre asc","cajero",cajero,false,false,0,"text10",null,"", "", "S")%>
					Turno:
					<%=fb.textBox("turno",turno,false,false,false,5)%>
					<%=fb.button("addTurno","...",true,false,null,null,"onClick=\"javascript:showTurno()\"","Seleccionar Turno")%>

					C&oacute;digo:
					<%=fb.textBox("codigo", codigo, false, false, false, 20, 40, "text12", "", "", "", false, "", "")%>
					Nombre:
					<%=fb.textBox("descripcion", descripcion, false, false, false, 50, 200, "text12", "", "", "", false, "", "")%>
					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fDate"/>
					<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
					<jsp:param name="nameOfTBox2" value="tDate"/>
					<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
					</jsp:include>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'><a href="javascript:showReport()" class="Link00">[ Reporte ]</a></authtype></td>
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
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("tipoClte", tipoClte)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("refer_to", refer_to)%>
					<%=fb.hidden("cod_caja", cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("tipo_factura",tipo_factura)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("tipoClte", tipoClte)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("refer_to", refer_to)%>
					<%=fb.hidden("cod_caja", cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("tipo_factura",tipo_factura)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
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
					<td width="12%">Tipo Cliente</td>
					<td width="15%">Cajero</td>
					<td width="8%">Fecha</td>
					<td width="8%">Tipo Docto.</td>
					<td width="12%">No. Docto.</td>
					<td width="8%">C&oacute;digo</td>
					<td width="22%">Nombre</td>
					<td width="9%">Monto CR Emp.</td>
					<td width="9%">Monto</td>
					<td width="5%">&nbsp;</td>
				</tr>
				<%
				double net_amount = 0.00;
				String cltId = "", refDesc = "", tipoFact = "";
				for (int i=0; i<al.size(); i++){
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if(cdo.getColValue("doc_type").equals("NCR")) color = "RedText";
				 if((!cltId.equals(cdo.getColValue("client_id")) || !refDesc.equals(cdo.getColValue("ref_desc"))) && i!=0){
				 %>
				<tr class="SpacingTextBold Text14">
					<td align="right" colspan="8">Total:</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(net_amount)%></td>
					<td align="right">&nbsp;</td>
				</tr>
				 <%
					net_amount=0.00;
				 }
				 if(!tipoFact.equals(cdo.getColValue("tipo_factura"))){
				 %>
				<tr class="SpacingTextBold Text14">
					<td align="center" colspan="10"><%=(cdo.getColValue("tipo_factura").equals("CR")?"VENTAS A CREDITO":"VENTAS A CONTADO")%></td>
				</tr>
				 <%
				 }
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="left"><%=cdo.getColValue("ref_desc")%></td>
					<td align="center"><%=cdo.getColValue("nombre_cajero")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("doc_type")%></td>
					<td align="center"><%=cdo.getColValue("factura")%></td>
					<td align="center"><%=(cdo.getColValue("refer_to").equals("EMPL")?cdo.getColValue("num_empleado"):cdo.getColValue("client_id"))%></td>
					<td align="left"><%=cdo.getColValue("clientRuc") + " - "+ cdo.getColValue("client_name")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_subsidio"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto_credito"))%></td>
					<td align="center"><authtype type='4'><a href="javascript:view('<%=cdo.getColValue("codigo_ref")%>','<%=cdo.getColValue("tipoDocto")%>')" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')">Ver</a></authtype></td>
				</tr>
				<%
					cltId = cdo.getColValue("client_id");
					refDesc = cdo.getColValue("ref_desc");
					tipoFact = cdo.getColValue("tipo_factura");
					if(cdo.getColValue("monto_credito")!=null) net_amount += Double.parseDouble(cdo.getColValue("monto_credito"));
				}
				if(al.size()!=0){
				 %>
				<tr class="SpacingTextBold Text14">
					<td align="right" colspan="8">Total:</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(net_amount)%></td>
					<td align="right">&nbsp;</td>
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
		<td class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%
					fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("tipoClte", tipoClte)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("refer_to", refer_to)%>
					<%=fb.hidden("cod_caja", cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("tipo_factura",tipo_factura)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("codigo", codigo)%>
					<%=fb.hidden("descripcion", descripcion)%>
					<%=fb.hidden("tipoClte", tipoClte)%>
					<%=fb.hidden("fDate", fDate)%>
					<%=fb.hidden("tDate", tDate)%>
					<%=fb.hidden("refer_to", refer_to)%>
					<%=fb.hidden("cod_caja", cod_caja)%>
					<%=fb.hidden("usuario_factura",""+usuario_factura)%>
					<%=fb.hidden("turno",turno)%>
					<%=fb.hidden("cajero",cajero)%>
					<%=fb.hidden("tipo_factura",tipo_factura)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
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
