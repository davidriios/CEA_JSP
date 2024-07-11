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

if (request.getMethod().equalsIgnoreCase("GET")){
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
	}
	String tipoClte = "", codigo = "", descripcion = "", fDate = "", tDate = "", refer_to = "", cod_caja = "", factura = "", cod_articulo = "", desc_articulo = "", orderBy = "F", tipoOtro = "", tipoFactura = "", tipoVenta = "";
	if(request.getParameter("tipoClte") != null) tipoClte = request.getParameter("tipoClte");
	if(request.getParameter("codigo") != null) codigo = request.getParameter("codigo");
	if(request.getParameter("descripcion") != null) descripcion = request.getParameter("descripcion");
	if(request.getParameter("fDate") != null) fDate = request.getParameter("fDate");
	if(request.getParameter("tDate") != null) tDate = request.getParameter("tDate");
	if(request.getParameter("refer_to") != null) refer_to = request.getParameter("refer_to");
	if(request.getParameter("cod_caja") != null) cod_caja = request.getParameter("cod_caja");
	if(request.getParameter("factura") != null) factura = request.getParameter("factura");
	if(request.getParameter("cod_articulo") != null) cod_articulo = request.getParameter("cod_articulo");
	if(request.getParameter("desc_articulo") != null) desc_articulo = request.getParameter("desc_articulo");
	if(request.getParameter("orderBy") != null) orderBy = request.getParameter("orderBy");
	if(request.getParameter("tipoOtro") != null) tipoOtro = request.getParameter("tipoOtro");
	if(request.getParameter("tipo_factura") != null) tipoFactura = request.getParameter("tipo_factura");
	if(request.getParameter("tipo_venta") != null) tipoVenta = request.getParameter("tipo_venta");
	
    String docType = request.getParameter("tipo_doc");
    
    if (docType == null) docType = "";//FAC

	StringBuffer sbCaja = new StringBuffer();
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


	StringBuffer sbSql = new StringBuffer();
	StringBuffer sbFilter = new StringBuffer();
	sbSql.append("select nvl(get_sec_comp_param(");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(",'POS_REP_VENTA_INCL_OBSERVATIONS'),'N') as incl_observ from dual");
	CommonDataObject p = SQLMgr.getData(sbSql.toString());

	sbSql = new StringBuffer();
	sbSql.append("select decode('");
	sbSql.append(orderBy);
	sbSql.append("', 'F', 'Factura: '||f.other3 ||', a '|| f.client_name");
	if ("SY".contains(p.getColValue("incl_observ"))) sbSql.append("||decode(f.observations,'NA','',' > '||f.observations)");
	sbSql.append(", 'A', fd.descripcion) group_by, decode('");
	sbSql.append(orderBy);
	sbSql.append("', 'F', f.doc_id, 'A', fd.codigo) group_rompe, decode('");
	sbSql.append(orderBy);
	sbSql.append("', 'A', 'Factura: '||f.other3 ||', a '|| f.client_name");
	if ("SY".contains(p.getColValue("incl_observ"))) sbSql.append("||decode(f.observations,'NA','',' > '||f.observations)");
	sbSql.append(", 'F', fd.descripcion) detalle, oc.descripcion ref_desc, f.doc_id, to_char(f.doc_date, 'dd/mm/yyyy') fecha, coalesce(f.printed_no, to_char(f.doc_id)) factura, f.client_id, f.client_name, decode(f.doc_type, 'NCR', -f.net_amount, f.net_amount) net_amount, decode(oc.refer_to, 'EMPL', (select num_empleado from tbl_pla_empleado e where to_char(emp_id) = f.client_id), f.client_id) num_empleado, oc.refer_to, (select nombre from tbl_cja_cajera where cod_cajera = f.cod_cajero and compania = f.company_id) nombre_cajero, decode(f.doc_type, 'FAC', f.other3, f.doc_id) codigo_ref,decode(f.doc_type, 'FAC', 'FACP', 'NCR', 'NCP', 'NDB', 'NDP') as tipoDocto, f.doc_type, f.tipo_factura, fd.codigo, fd.descripcion descripcion, decode(f.doc_type,'NCR',-fd.cantidad,fd.cantidad) as cantidad, fd.precio, fd.costo, decode(f.doc_type,'NCR',-1,1)*(fd.total) as total, decode(f.doc_type,'NCR',-fd.descuento,fd.descuento) as descuento, decode(f.doc_type,'NCR',-fd.costo_total,fd.costo_total) as costo_total , case when f.pac_id is null and f.admision is null then 'V' else 'I' end tipo_venta from tbl_fac_trx f, tbl_fac_tipo_cliente oc, (select compania, doc_id, codigo, descripcion, sum(decode(tipo_descuento, null, cantidad, 0)) cantidad, sum(decode(tipo_descuento, null, precio, 0)) precio, sum(decode(tipo_descuento, null, costo, 0)) costo, sum(decode(tipo_descuento, null, total+total_itbm, 0)) total, sum(decode(tipo_descuento, null, 0, total_desc)) descuento, sum(decode(tipo_descuento, null, costo*cantidad, 0)) costo_total from tbl_fac_trxitems group by compania, doc_id, codigo, descripcion) fd where f.client_ref_id = oc.codigo and f.company_id = oc.compania and oc.compania = ");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and f.doc_id = fd.doc_id ");
    
    if (!docType.equals("")) {
      sbFilter.append(" and f.doc_type = '");
      sbFilter.append(docType);
      sbFilter.append("'");
    }

	if(!codigo.equalsIgnoreCase("")){
		if(refer_to.equals("EMPL")){
			sbFilter.append(" and exists (select null from tbl_pla_empleado e where emp_id = f.client_id and num_empleado like '%");
			sbFilter.append(codigo);
			sbFilter.append("%')");
		} else {
			sbFilter.append(" and upper(f.client_id) like '");
			sbFilter.append(codigo);
			sbFilter.append("%'");
		}

	}
	if(!descripcion.equalsIgnoreCase("")){
		sbFilter.append(" and upper(f.client_name) like '");
		sbFilter.append(descripcion);
		sbFilter.append("%'");
	}
	if(!cod_caja.equalsIgnoreCase("")){
		sbFilter.append(" and f.cod_caja = ");
		sbFilter.append(cod_caja);
	}

	if(!fDate.equalsIgnoreCase("")){
		sbFilter.append(" and trunc(f.doc_date) >= to_date('");
		sbFilter.append(fDate);
		sbFilter.append("', 'dd/mm/yyyy')");
	}
	if(!tDate.equalsIgnoreCase("")){
		sbFilter.append(" and trunc(f.doc_date) <= to_date('");
		sbFilter.append(tDate);
		sbFilter.append("', 'dd/mm/yyyy')");
	}
	if(!factura.equals("")){
		sbFilter.append(" and coalesce(f.printed_no, to_char(f.doc_id)) like '%");
		sbFilter.append(factura);
		sbFilter.append("%'");
	}

	if(!tipoFactura.equals("")){
		sbFilter.append(" and f.tipo_factura = '");
		sbFilter.append(tipoFactura);
		sbFilter.append("'");
	}

	if(!cod_articulo.equals("")){
		sbFilter.append(" and exists (select null from tbl_fac_trxitems t where t.doc_id = f.doc_id and t.codigo = fd.codigo and t.tipo_descuento is null and t.codigo = ");
		sbFilter.append(cod_articulo);
		sbFilter.append(")");
	}

		if(!desc_articulo.equals("")){
		sbFilter.append(" and exists (select null from tbl_fac_trxitems t where t.doc_id = f.doc_id and t.codigo = fd.codigo and t.tipo_descuento is null and t.descripcion like '%");
		sbFilter.append(desc_articulo);
		sbFilter.append("%')");
	}


	if (!tipoClte.trim().equalsIgnoreCase("")) {

		sbFilter.append(" and oc.codigo = ");
		sbFilter.append(tipoClte);

		if (refer_to.equalsIgnoreCase("CXCO")) {

			if (!tipoOtro.trim().equals("")) {

				sbFilter.append(" and exists (select null from tbl_cxc_cliente_particular where compania = f.company_id and codigo = f.client_id and tipo_cliente = ");
				sbFilter.append(tipoOtro);
				sbFilter.append(")");

			}

		}

	}
    
    if (tipoVenta.equalsIgnoreCase("I")) sbFilter.append(" and (f.pac_id is not null and f.admision is not null) ");
    else if (tipoVenta.equalsIgnoreCase("V")) sbFilter.append(" and (f.pac_id is null and f.admision is null) ");
		sbSql.append(sbFilter.toString());
		sbSql.append(" order by 4, 1, f.client_name, f.client_id");
		StringBuffer sbSqlT = new StringBuffer();
		sbSqlT.append("select * from (select rownum as rn, z.* from (");
		sbSqlT.append(sbSql.toString());
		
		sbSqlT.append(") z) where rn between ");
		sbSqlT.append(previousVal);
		sbSqlT.append(" and ");
		sbSqlT.append(nextVal);
		if(sbFilter.length()>0) al = SQLMgr.getDataList(sbSqlT.toString());
		sbSqlT = new StringBuffer();
		sbSqlT.append("select count(*) as count from (");
		sbSqlT.append(sbSql.toString());
		sbSqlT.append(")");
		if(sbFilter.length()>0)rowCount = CmnMgr.getCount(sbSqlT.toString());

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
var xHeight=0;
var forceList = true;
function doAction(){debug("<%//=sbSqlT%>");chkOther('<%=refer_to%>');xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}

function showReport(conBc){
	var tipoClte 		= document.search01.tipoClte.value || 'ALL';
	var codigo 			= document.search01.codigo.value || 'ALL';
	var descripcion	= document.search01.descripcion.value || 'ALL';
	var fDate 			= document.search01.fDate.value || 'ALL';
	var tDate 			= document.search01.tDate.value || 'ALL';
	var cod_caja 			= document.search01.cod_caja.value;
	var factura 			= document.search01.factura.value || 'ALL';
	var orderBy 			= document.search01.orderBy.value || 'ALL';
	var codArt				= document.search01.cod_articulo.value || 'ALL';
	var descArt 			= document.search01.desc_articulo.value || 'ALL';
	var tipoClteLabel=getSelectedOptionLabel(document.search01.tipoClte)  || 'ALL';
	var tipoOtro=document.search01.tipoOtro.value || 'ALL';
	var tipoFactura = document.search01.tipo_factura.value;
	var tipoVenta = document.search01.tipo_venta.value || 'ALL';
	var tipoDoc = document.search01.tipo_doc.value || 'ALL';
    var wbc = '&with_barcode=ALL';// + (conBc ? 'Y':'ALL');
	var reporte = (conBc=='D' ?'rep_ventas':'rep_ventas_res');
    
	if(cod_caja=='') cod_caja='-1';
	if(tipoOtro==undefined||tipoOtro==null)tipoOtro='';
	if(tipoFactura==undefined||tipoFactura==null||tipoFactura=='')tipoFactura='ALL';
	abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=pos/'+reporte+'.rptdesign&tipoCltParam='+tipoClte+'&codCltParam='+codigo+'&nameCltParam='+descripcion+'&fechaDesdeParam='+fDate+'&fechaHastaParam='+tDate+'&codCajaParam='+cod_caja+'&facturaParam='+factura+'&tipoClteLabelParam='+tipoClteLabel+'&orderByParam='+orderBy+'&codArtParam='+codArt+'&descArtParam='+descArt+'&tipoOtroParam='+tipoOtro+'&tipoFacturaParam='+tipoFactura+'&pCtrlHeader=false'+'&pTipoVenta='+tipoVenta+'&tipoDoc='+tipoDoc+wbc+'&inclObserv=<%=("SY".contains(p.getColValue("incl_observ")))?"1":"0"%>');

}
function setReferTo(obj){
  var referTo=getSelectedOptionTitle(obj,'');document.search01.refer_to.value=referTo;chkOther(referTo);
  if (obj.value == "7") $(".tipo-venta").show(0);
  else {
    $("#tipo_venta").val("");
    $(".tipo-venta").hide(0);
  }
}
function chkOther(referTo){document.search01.tipoOtro.disabled=(referTo!='CXCO');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
		<jsp:param name="title" value="TITLE"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
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
					<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, refer_to from tbl_fac_tipo_cliente where compania = "+(String) session.getAttribute("_companyId")+" and es_clt_cr = 'S' order by descripcion","tipoClte",tipoClte,false,false,0, "Text10", "", "onChange=\"javascript:setReferTo(this);\"", "", "T")%>
					<%=fb.select(ConMgr.getConnection(),"select id, descripcion, id from tbl_cxc_tipo_otro_cliente where compania = "+session.getAttribute("_companyId")+" and estado = 'A' order by descripcion","tipoOtro",tipoOtro,false,false,0,"Text10","","","","T")%>
                    
                    <span class="tipo-venta" style="display:<%=tipoVenta.equals("")?"none":""%>;">
                    Tipo Venta:
                    <%=fb.select("tipo_venta","I=Interfaz,V=POS",tipoVenta,false,false,0,null,null,"", "", "T", "")%>
                    </span>
                    
					Caja:
					<%=fb.select(ConMgr.getConnection(),sbCaja.toString(),"cod_caja",cod_caja,false,false,0, "Text10", "", "", "", "T")%>
					C&oacute;digo:
					<%=fb.textBox("codigo", codigo, false, false, false, 8, 40, "Text12", "", "", "", false, "", "")%>
					Nombre:
					<%=fb.textBox("descripcion", descripcion, false, false, false, 30, 200, "Text12", "", "", "", false, "", "")%>
					Factura:
					<%=fb.textBox("factura", factura, false, false, false, 8, 30, "Text12", "", "", "", false, "", "")%>
                    
                    &nbsp;&nbsp;Tipo Doc.:
					<%=fb.select("tipo_doc","FAC=FAC,NCR=NCR,FACP=FACP,NCP=NCP,NDB=NDB,NDP=NDP",docType,false,false,0,"T")%>
                    
					<br>
					Fecha:
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="2"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fDate"/>
					<jsp:param name="valueOfTBox1" value="<%=fDate%>"/>
					<jsp:param name="nameOfTBox2" value="tDate"/>
					<jsp:param name="valueOfTBox2" value="<%=tDate%>"/>
					</jsp:include>
					Cod. Art&iacute;culo:
					<%=fb.textBox("cod_articulo", cod_articulo, false, false, false, 8, 200, "Text12", "", "", "", false, "", "")%>
					Desc. Art&iacute;culo:
					<%=fb.textBox("desc_articulo", desc_articulo, false, false, false, 20, 200, "Text12", "", "", "", false, "", "")%>

					&nbsp;&nbsp;
					Tipo Factura:
					<%=fb.select("tipo_factura","CR=Credito,CO=Contado",tipoFactura,false,false,0,null,null,"", "", "T", "")%>

					&nbsp;&nbsp;Agrupar por:
					<%=fb.select("orderBy","F=Factura,A=Articulo",orderBy,false,false,0,"")%>
					<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd()%>
				</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
	<tr>
		<td align="right"><authtype type='0'>
            <a href="javascript:showReport('D')" class="Link00Bold">[ Imprimir ]</a><a href="javascript:showReport('R')" class="Link00Bold">[ Imprimir Resumido ]</a><!--&nbsp;|&nbsp;<a href="javascript:showReport(1)" class="Link00">[ Reporte CB ]--></a>
        </authtype></td>
	</tr>
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
					<%=fb.hidden("cod_articulo", cod_articulo)%>
					<%=fb.hidden("desc_articulo", desc_articulo)%>
					<%=fb.hidden("orderBy", orderBy)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
					<%=fb.hidden("tipo_factura",tipoFactura)%>
					<%=fb.hidden("tipo_venta",tipoVenta)%>
					<%=fb.hidden("tipo_doc",docType)%>
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
					<%=fb.hidden("cod_articulo", cod_articulo)%>
					<%=fb.hidden("desc_articulo", desc_articulo)%>
					<%=fb.hidden("orderBy", orderBy)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
					<%=fb.hidden("tipo_factura",tipoFactura)%>
					<%=fb.hidden("tipo_venta",tipoVenta)%>
					<%=fb.hidden("tipo_doc",docType)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="14%">Tipo Cliente</td>
					<td width="9%">Cajero</td>
					<td width="6%">Fecha</td>
					<td width="3%">Tipo</td>
					<td width="5%">Tipo Doc.</td>
					<td width="7%">C&oacute;digo</td>
					<td width="20%">Descripci&oacute;n</td>
					<td width="5%">Cant.</td>
					<td width="6%">Costo</td>
					<td width="6%">Precio</td>
					<td width="6%">Venta</td>
					<td width="7%">Costo Total</td>
					<td width="6%">Descuento</td>
				</tr>
				<%
				double venta = 0.00, costo = 0.00, descuento = 0.00;
				String docId = "", nfactura = "";
				for (int i=0; i<al.size(); i++){
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 if(cdo.getColValue("doc_type").equals("NCR")) color = "RedText";
				 if(!docId.equals(cdo.getColValue("group_by"))){
				 %>
				 <%
				 if(i!=0){
				 %>
				<tr class="Text10Bold">
					<td align="right" colspan="10">Total para <%=nfactura%>:</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(venta)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(costo)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
				</tr>
				 <%
					venta=0.00;
					costo=0.00;
					descuento=0.00;
				 }
				 %>
				<tr class="Text10Bold">
					<td align="center" colspan="11"><%=cdo.getColValue("group_by")%></td>
				</tr>
				 <%
				 }
				%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="left"><%=cdo.getColValue("ref_desc")%></td>
					<td align="center"><%=cdo.getColValue("nombre_cajero")%></td>
					<td align="center"><%=cdo.getColValue("fecha")%></td>
					<td align="center"><%=cdo.getColValue("tipo_factura")%><%=tipoClte.equals("7")?cdo.getColValue("tipo_venta"):""%></td>
          <td align="center"><%=cdo.getColValue("doc_type")%></td>
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td align="center"><%=cdo.getColValue("detalle")%></td>
					<td align="center"><%=cdo.getColValue("cantidad")%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("costo"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("total"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("costo_total"))%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("descuento"))%></td>
				</tr>
				<%
					docId = cdo.getColValue("group_by");
					nfactura = cdo.getColValue("group_by");
					if(cdo.getColValue("total")!=null) venta += Double.parseDouble(cdo.getColValue("total"));
					if(cdo.getColValue("costo_total")!=null) costo += Double.parseDouble(cdo.getColValue("costo_total"));
					if(cdo.getColValue("descuento")!=null) descuento += Double.parseDouble(cdo.getColValue("descuento"));
				}
				if(al.size()!=0){
				 %>
				<tr class="Text10Bold">
					<td align="right" colspan="10">Total para <%=nfactura%>:</td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(venta)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(costo)%></td>
					<td align="right"><%=CmnMgr.getFormattedDecimal(descuento)%></td>
				</tr>
				 <%
				 }
				 %>
			</table>
</div>
</div>
			<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
		</td>
	</tr>
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
					<%=fb.hidden("cod_articulo", cod_articulo)%>
					<%=fb.hidden("desc_articulo", desc_articulo)%>
					<%=fb.hidden("orderBy", orderBy)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
					<%=fb.hidden("tipo_factura",tipoFactura)%>
					<%=fb.hidden("tipo_venta",tipoVenta)%>
					<%=fb.hidden("tipo_doc",docType)%>
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
					<%=fb.hidden("cod_articulo", cod_articulo)%>
					<%=fb.hidden("desc_articulo", desc_articulo)%>
					<%=fb.hidden("orderBy", orderBy)%>
					<%=fb.hidden("tipoOtro",tipoOtro)%>
					<%=fb.hidden("tipo_factura",tipoFactura)%>
					<%=fb.hidden("tipo_venta",tipoVenta)%>
					<%=fb.hidden("tipo_doc",docType)%>
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
