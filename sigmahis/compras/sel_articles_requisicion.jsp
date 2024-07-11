<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="OCDet" scope="session" class="issi.compras.OrdenCompra"/>
<jsp:useBean id="ocArt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ocArtKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
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
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
int anio = Integer.parseInt(request.getParameter("anio"));
int prevAnio = anio -1;
String fp = request.getParameter("fp");
String proveedor = request.getParameter("proveedor");

/*
String filterProveedor = request.getParameter("filterProveedor");
String proveedor = request.getParameter("proveedor");
if (filterProveedor == null) filterProveedor = "N";
if (filterProveedor.equalsIgnoreCase("Y")) { sbFilter.append(" and ap.cod_provedor = '"); sbFilter.append(proveedor); sbFilter.append("'"); }
*/

String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String articulo = request.getParameter("articulo");
String descripcion = request.getParameter("descripcion");
if (familia == null) familia = "";
if (clase == null) clase = "";
if (articulo == null) articulo = "";
if (descripcion == null) descripcion = "";
if (fp == null) fp = "";
if (proveedor == null) proveedor = "";

if (request.getMethod().equalsIgnoreCase("GET")) {
	int recsPerPage = 100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null) {
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (OCDet.getRequiAnio() != null && !OCDet.getRequiAnio().trim().equals("")) { sbFilter.append(" and z.requi_anio = "); sbFilter.append(OCDet.getRequiAnio()); }
	if (OCDet.getRequiNo() != null && !OCDet.getRequiNo().trim().equals("")) { sbFilter.append(" and z.requi_numero = "); sbFilter.append(OCDet.getRequiNo()); }
	if (!familia.trim().equals("")) { sbFilter.append(" and a.cod_flia = "); sbFilter.append(familia); }
	if (!clase.trim().equals("")) { sbFilter.append(" and a.cod_clase = "); sbFilter.append(clase); }
	if (!articulo.trim().equals("")) { sbFilter.append(" and a.cod_articulo = "); sbFilter.append(articulo); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and upper(a.descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }


	sbSql.append("select 'CS' as art_origen, to_char(z.requi_anio) as requi_anio, to_char(z.requi_numero) as requi_numero, y.cod_articulo, y.cantidad, y.precio_cotizado, y.especificacion, x.cod_provedor, nvl(getCantArtTramite(z.compania,z.codigo_almacen,y.cod_articulo),0) as cant_tramite, getlastprecioprovprueba(y.compania, ");
	if(fp.equals("parcial") && !proveedor.equals(""))	{sbSql.append(proveedor);sbSql.append(", ");}
	else sbSql.append("x.cod_provedor,");

	sbSql.append(OCDet.getCodAlmacen());
	sbSql.append(",y.cod_articulo) as ult_precio");
	sbSql.append(", (select cod_flia from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as cod_flia");
	sbSql.append(", (select cod_clase from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as cod_clase");
	sbSql.append(", (select cod_subclase from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as cod_subclase");
	sbSql.append(", (select descripcion from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as articulo");
	sbSql.append(", (select cod_medida from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as cod_medida");
	sbSql.append(", (select itbm from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as itbm");
	sbSql.append(", (select other1 from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as other1");
	sbSql.append(", (select other2 from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as other2");
	sbSql.append(", (select consignacion_sino from tbl_inv_articulo where compania = y.compania and cod_articulo = y.cod_articulo) as consignacion");
	sbSql.append(", nvl((select nombre_proveedor from tbl_com_proveedor where cod_provedor = x.cod_provedor and compania = x.compania),' ') as nombre_proveedor");
	sbSql.append(" from tbl_inv_requisicion z, tbl_inv_detalle_req y, tbl_inv_arti_prov x");
	sbSql.append(" where z.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" and z.activa = 'S' and z.estado_requi = 'A' and y.estado_renglon = 'P' and z.compania = y.compania and z.requi_numero = y.requi_numero and z.requi_anio = y.requi_anio and y.compania = x.compania(+) and y.cod_articulo = x.cod_articulo(+) and x.tipo_proveedor(+) = 1 and not exists (select null from tbl_com_comp_formales a, tbl_com_detalle_compromiso b where a.anio = b.cf_anio and a.tipo_compromiso = b.cf_tipo_com and a.num_doc = b.cf_num_doc and a.compania = b.compania and a.requi_anio = z.requi_anio and a.requi_numero = z.requi_numero and b.cod_articulo = y.cod_articulo and status <> 'N' )");

	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);


	System.out.println("Geetesh Printing Query #################################################"+sbSql);

	rowCount = CmnMgr.getCount("select count(*) count FROM ("+sbSql+")");

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
document.title = 'Inventario - '+document.title;
function verValue(i){
	if(!isNaN(eval('document.articles.cantidad'+i).value)){
		if(parseInt(eval('document.articles.cantidad'+i).value)>parseInt(eval('document.articles.disponible'+i).value)){
			alert("La cantidad introducida supera la cantidad disponible!");
			eval('document.articles.cantidad'+i).value=0;
			eval('document.articles.cantidad'+i).focus();
		}
	} else {
		alert("Introduzca valores numéricos enteros!");
		eval('document.articles.cantidad'+i).value=0;
		eval('document.articles.cantidad'+i).focus();
	}
}

function chkQty(){
	var size = document.articles.keySize.value;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.articles.chkArt'+i) != null && eval('document.articles.chkArt'+i).checked==true){
			if(!isNaN(eval('document.articles.cantidad'+i).value)){
				if(parseInt(eval('document.articles.cantidad'+i).value)>parseInt(eval('document.articles.disponible'+i).value)){
					//alert("La cantidad introducida supera la cantidad disponible!");
					eval('document.articles.cantidad'+i).value=0;
					eval('document.articles.cantidad'+i).focus();
					x++;
					break;
				}
			} else {
				//alert("Introduzca valores numéricos enteros!");
				eval('document.articles.cantidad'+i).value=0;
				eval('document.articles.cantidad'+i).focus();
				x++;
				break;
			}
		}
	}
	if(x==0) return true;
	else return false;
}

function confirma(obj){
	obj.checked = confirm('Confirma que desea hacer una orden de compra de este articulo a pesar de que ya está en trámite en otra orden de compra?');
}

function chkRequisicion(j){
	var cod_proveedor = eval('document.articles.cod_proveedor'+j).value;
	var size = document.articles.keySize.value;
	var x = 0;
	if(eval('document.articles.chkArt'+j).checked){
		for(i=0;i<size;i++){
			var _cod_proveedor = eval('document.articles.cod_proveedor'+i).value;
			if(cod_proveedor!=_cod_proveedor && (eval('document.articles.chkArt'+i) == null || eval('document.articles.chkArt'+i).checked)){
				x++;
				break;
			}
		}
		if(x>0){
			alert('No puede escojer artículos de diferentes Proveedores!');
			eval('document.articles.chkArt'+j).checked = false;
		}
	}
}
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
//function resetFrameHeight(frame,currHeight,minHeight,fixedHeight)
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td colspan="2" align="right">&nbsp;</td>
</tr>
<!--
<tr>
	<td>
		<table width="100%" cellpadding="0" cellspacing="0">
		<tr class="TextFilter">
<% //fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
<%//=fb.formStart()%>
<%//=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%//=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%//=fb.hidden("mode",mode)%>
<%//=fb.hidden("id",id)%>
<%//=fb.hidden("anio",""+anio)%>
<%//=fb.hidden("fp",""+fp)%>
			<td width="20%">
				Familia
				<%//=fb.intBox("familia","",false,false,false,15)%>
			</td>
			<td width="20%">
				Clase
				<%//=fb.intBox("clase","",false,false,false,15)%>
			</td>
			<td width="20%">
				Art&iacute;culo
				<%//=fb.intBox("articulo","",false,false,false,15)%>
			</td>
			<td width="40%">
				Descripci&oacute;n
				<%//=fb.textBox("descripcion","",false,false,false,20)%>
				<%//=fb.submit("go","Ir")%>
			</td>
<%//=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
-->
<tr>
	<td colspan="2" class="TableLeftBorder TableTopBorder TableRightBorder">
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",""+anio)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("proveedor",proveedor)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s) </cellbytelabel><%=rowCount%></td>
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",""+anio)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("proveedor",proveedor)%>

			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<%fb = new FormBean("articles",request.getContextPath()+request.getServletPath(),FormBean.POST);/*onSubmit=\"javascript:return (chkQty())\"*/%>
<%=fb.formStart()%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",""+anio)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("proveedor",proveedor)%>

<tr>
	<td align="left" class="TableLeftBorder TextInfo">* <cellbytelabel>Art&iacute;culos se encuentran en otra requisicion aprobada y sin entregar</cellbytelabel>!</td>
	<td align="right" class="TableRightBorder"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
</tr>
<tr>
	<td colspan="2" class="TableLeftBorder TableRightBorder" colspan="2">
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextHeader">
			<td width="5%" align="center" rowspan="2"><cellbytelabel>Sol. A&ntilde;o</cellbytelabel></td>
			<td width="5%" align="center" rowspan="2"><cellbytelabel>Sol. No</cellbytelabel></td>
			<td align="center" colspan="3"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="25%" align="center" rowspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="12%" align="center" rowspan="2"><cellbytelabel>Proveedor</cellbytelabel></td>
			<td width="8%" align="center" rowspan="2"><cellbytelabel>Consignaci&oacute;n</cellbytelabel></td>
			<td width="6%" align="center" rowspan="2"><cellbytelabel>Und. Compra</cellbytelabel></td>
			<td width="8%" align="center" rowspan="2"><cellbytelabel>Cantidad</cellbytelabel></td>
			<td width="8%" align="center" rowspan="2"><cellbytelabel>Cant. Tr&aacute;mite</cellbytelabel></td>
			<td width="3%" align="center" rowspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td width="6%" align="center"><cellbytelabel>Familia</cellbytelabel></td>
			<td width="6%" align="center"><cellbytelabel>Clase</cellbytelabel></td>
			<td width="8%" align="center"><cellbytelabel>Art&iacute;culo</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	if (cdo.getColValue("art_origen") != null && cdo.getColValue("art_origen").equalsIgnoreCase("PR")) {
		color = "TextRow10";
		if (i % 2 == 0) color = "TextRow09";
	}
%>
		<%=fb.hidden("requi_anio"+i,cdo.getColValue("requi_anio"))%>
		<%=fb.hidden("requi_numero"+i,cdo.getColValue("requi_numero"))%>
		<%=fb.hidden("cod_flia"+i,cdo.getColValue("cod_flia"))%>
		<%=fb.hidden("cod_clase"+i,cdo.getColValue("cod_clase"))%>
		<%=fb.hidden("cod_subclase"+i,cdo.getColValue("cod_subclase"))%>
		<%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
		<%=fb.hidden("art_desc"+i,cdo.getColValue("articulo"))%>
		<%=fb.hidden("itbm"+i,cdo.getColValue("itbm"))%>
		<%=fb.hidden("unidad"+i,cdo.getColValue("cod_medida"))%>
		<%=fb.hidden("precio_cotizado"+i,cdo.getColValue("precio_cotizado"))%>
		<%=fb.hidden("especificacion"+i,cdo.getColValue("especificacion"))%>
		<%=fb.hidden("cod_proveedor"+i,cdo.getColValue("cod_provedor"))%>
		<%=fb.hidden("ult_precio"+i,cdo.getColValue("ult_precio"))%>
		<%=fb.hidden("other1"+i,cdo.getColValue("other1"))%>
		<%=fb.hidden("other2"+i,cdo.getColValue("other2"))%>
<%
	String onChange = "onFocus=\"this.select();\" onChange=\"javascript:setChecked(this,document.articles.chkArt"+i+")\"";
	String onClick = "";
	if(fp!=null && fp.equals("parcial")) onClick = "onClick=\"javascript:chkRequisicion("+i+");\""; //&& cdo.getColValue("cant_tramite")!=null && !cdo.getColValue("cant_tramite").equals("") && Double.parseDouble(cdo.getColValue("cant_tramite"))>0.00) onClick = "onClick=\"javascript:confirma(this);\"";

	String key = "";
	String artKey = cdo.getColValue("cod_flia") +"-"+cdo.getColValue("cod_clase") +"-"+cdo.getColValue("cod_subclase")+"-"+cdo.getColValue("cod_articulo");
	if(ocArtKey.containsKey(artKey)) key = (String) ocArtKey.get(artKey);

%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td align="center"><%=cdo.getColValue("requi_anio")%></td>
			<td align="center"><%=cdo.getColValue("requi_numero")%></td>
			<td><%=cdo.getColValue("cod_flia")%></td>
			<td><%=cdo.getColValue("cod_clase")%></td>
			<td><%=cdo.getColValue("cod_articulo")%></td>
			<td align="left"><%=cdo.getColValue("articulo")%></td>
			<td align="center"><%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="center"><%=cdo.getColValue("consignacion")%></td>
			<td align="center"><%=cdo.getColValue("other1")%></td>
<% if (ocArt.containsKey(key)){ %>
			<td align="right"><%=fb.intBox("cantidad"+i,((OrdenCompraDetail) ocArt.get(key)).getCantidad(),true,false,false,5,"","",onChange)%></td>
			<td align="right"><%=fb.intBox("cantidad_tramite"+i,cdo.getColValue("cant_tramite"),true,false,false,5,"","","")%></td>
			<td align="center"><cellbytelabel>elegido</cellbytelabel></td>
<% } else { %>
			<td align="right"><%=fb.intBox("cantidad"+i,cdo.getColValue("cantidad"),true,false,false,5,"","",onChange)%></td>
			<td align="right"><%=fb.intBox("cantidad_tramite"+i,cdo.getColValue("cant_tramite"),false,false,true,5,"","","")%></td>
			<td align="center"><%=fb.checkbox("chkArt"+i,""+i, false, cdo.getColValue("consignacion").equalsIgnoreCase("S"), "", "", onClick)%></td>
<% } %>
		</tr>
<% } %>
<% if (al.size() == 0) { %>
		<tr><td align="center" colspan="8"><cellbytelabel>No registros encontrados</cellbytelabel>.</td></tr>
<% } %>
		</table>
</div>
</div>
	</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
<tr>
	<td colspan="2" class="TableLeftBorder TableBottomBorder TableRightBorder">
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",""+anio)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("proveedor",proveedor)%>

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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",""+anio)%>
<%=fb.hidden("fp",""+fp)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("proveedor",proveedor)%>

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
else
{
	System.out.println("=====================POST=====================");
	int lineNo = OCDet.getOCDetails().size();
	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	for(int i=0;i<keySize;i++){

		OrdenCompraDetail oc = new OrdenCompraDetail();
		oc.setCodFlia(request.getParameter("cod_flia"+i));
		oc.setCodClase(request.getParameter("cod_clase"+i));
		oc.setSubclaseId(request.getParameter("cod_subclase"+i));
		oc.setCodArticulo(request.getParameter("cod_articulo"+i));
		oc.setArticulo(request.getParameter("art_desc"+i));
		oc.setItbm(request.getParameter("itbm"+i));
		oc.setUnidad(request.getParameter("unidad"+i));
		oc.setCantidad(request.getParameter("cantidad"+i));
		oc.setMonto(request.getParameter("ult_precio"+i));
		oc.setEspecificacion(request.getParameter("especificacion"+i));
		oc.setAnioRequi(OCDet.getRequiAnio());
		oc.setRequiNum(OCDet.getRequiNo());
		oc.setCantEmpaque(request.getParameter("cantidad"+i));
		if(request.getParameter("other1"+i)!=null && !request.getParameter("other1"+i).equals("")) oc.setUnidadEmpaque(request.getParameter("other1"+i));
		if(request.getParameter("other2"+i)!=null && !request.getParameter("other2"+i).equals("")) oc.setCantPorEmpaque(request.getParameter("other2"+i));
		if(oc.getCantPorEmpaque()!=null && !oc.getCantPorEmpaque().equals("")) oc.setCantidad(""+(Integer.parseInt(oc.getCantPorEmpaque())*Integer.parseInt(oc.getCantEmpaque())));
		oc.setAction("I");

		oc.setEntregado("0");
		oc.setCantidadAcumulada("0");
		oc.setEntregadoPromo("0");

		/*
		rq.set(request.getParameter(""+i));
		*/
		if(request.getParameter("chkArt"+i)!=null && request.getParameter("del"+i)==null){

			String artKey = oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getSubclaseId()+"-"+oc.getCodArticulo();

			if(!ocArtKey.containsKey(artKey)){
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					ocArt.put(key, oc);
					ocArtKey.put(oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getSubclaseId()+"-"+oc.getCodArticulo(), key);
					OCDet.getOCDetails().add(oc);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		} else if(request.getParameter("del"+i)!=null){
			artDel = oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getCodArticulo();
			if (ocArtKey.containsKey(artDel)){
				System.out.println("- remove item "+artDel);
				ocArt.remove((String) ocArtKey.get(artDel));
				ocArtKey.remove(artDel);
			}
		}
	}
	if(request.getParameter("addCont")!=null){
		response.sendRedirect("../compras/sel_articles_requisicion.jsp?mode="+mode+"&id="+id+"&change=1&type=1&anio="+anio);
		return;
	}

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if(fp!= null && fp.equals("approve")){%>
	window.opener.location = '<%=request.getContextPath()+"/compras/aprove_orden_compra_normal.jsp?change=1&mode="+mode+"&id="+id%>';
	<%} else if(fp != null && fp.equals("parcial")) {%>
	window.opener.location = '<%=request.getContextPath()+"/compras/reg_orden_compra_parcial_det.jsp?change=1&mode="+mode+"&id="+id%>';
	<%} else {%>
	window.opener.location = '<%=request.getContextPath()+"/compras/reg_orden_compra_normal.jsp?change=1&mode="+mode+"&id="+id%>';
	<%}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%

}//POST
%>
