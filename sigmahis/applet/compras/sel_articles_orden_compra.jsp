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
String anio = request.getParameter("anio");
String fp = request.getParameter("fp");
String filterProveedor = request.getParameter("filterProveedor");
String proveedor = request.getParameter("proveedor");

if (OCDet.getCodAlmacen() == null || OCDet.getCodAlmacen().trim().equals("")) throw new Exception("Por favor seleccione Almacen!");
if (filterProveedor == null) filterProveedor = "";
if (proveedor == null || proveedor.trim().equals("")) throw new Exception("Por favor seleccione Proveedor!");

String familia = request.getParameter("familia");
String clase = request.getParameter("clase");
String subclase = request.getParameter("subclase");
String articulo = request.getParameter("articulo");
String descripcion = request.getParameter("descripcion");
String codBarra = request.getParameter("cod_barra");
String nombreProveedor = request.getParameter("nombreProveedor");
if (familia == null) familia = "";
if (clase == null) clase = "";
if (subclase == null) subclase = "";
if (articulo == null) articulo = "";
if (descripcion == null) descripcion = "";
if (codBarra == null) codBarra = "";
if (nombreProveedor == null) nombreProveedor = "";

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

	if (filterProveedor.equalsIgnoreCase("Y")) {
		sbFilter.append(" and b.cod_provedor = ");
		sbFilter.append(proveedor);
	}

	if (!familia.trim().equals("")) { sbFilter.append(" and upper(a.cod_flia) = "); sbFilter.append(familia); }
	if (!clase.trim().equals("")) { sbFilter.append(" and upper(a.cod_clase) = "); sbFilter.append(clase); }
	if (!subclase.trim().equals("")) { sbFilter.append(" and upper(a.cod_subclase) = "); sbFilter.append(subclase); }
	if (!articulo.trim().equals("")) { sbFilter.append(" and upper(a.cod_articulo) = "); sbFilter.append(articulo); }
	//if (!codBarra.trim().equals("")) { sbFilter.append(" and  a.cod_barra like '%"); sbFilter.append(codBarra);sbFilter.append("%'"); }
	if (!descripcion.trim().equals("")) { sbFilter.append(" and  upper(a.descripcion) like '%"); sbFilter.append(descripcion.toUpperCase()); sbFilter.append("%'"); }
	if (!nombreProveedor.trim().equals("")) { sbFilter.append(" and exists (select null from tbl_com_proveedor where cod_provedor = b.cod_provedor and compania = b.compania and nombre_proveedor like '%"); sbFilter.append(nombreProveedor.toUpperCase()); sbFilter.append("%')"); }
	
	sbFilter.append(" and a.replicado_far='N' ");
	if (!codBarra.trim().equals(""))
	{
	  try{codBarra = issi.admin.IBIZEscapeChars.forBarCode(issi.admin.Aes.decrypt(request.getParameter("cod_barra"),"_cUrl",256));}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::::::::::::::: [Error] trying to decrypt the barcode. May be, someone uses the button. "+e);}
	  sbFilter.append(" and upper(a.cod_barra)= '");
	  sbFilter.append(issi.admin.IBIZEscapeChars.forSingleQuots(codBarra.toUpperCase()));
	  sbFilter.append("'");
	  codBarra = ""; 
	}

	sbSql.append("select a.cod_flia, a.cod_clase, a.cod_articulo, a.descripcion as articulo, a.cod_barra, a.cod_medida, a.itbm, a.cod_subclase as subclase_id, a.other1, a.other2, nvl(a.other5,0) as other5, getlastprecioprovprueba(a.compania,");
	sbSql.append(proveedor);
	sbSql.append(",");
	sbSql.append(OCDet.getCodAlmacen());
	sbSql.append(",a.cod_articulo) as ult_precio");
	sbSql.append(", nvl((select nombre_proveedor from tbl_com_proveedor where cod_provedor = b.cod_provedor and compania = b.compania and estado_proveedor = 'ACT'),' ') as nombre_proveedor");
	sbSql.append(", (select sum(disponible) from tbl_inv_inventario i where i.compania = a.compania and i.cod_articulo = a.cod_articulo) disponible");
	sbSql.append(" from tbl_inv_articulo a, tbl_inv_arti_prov b");
	sbSql.append(" where a.product_id = b.product_id(+) and a.compania = b.compania(+) and a.compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(sbFilter);
	sbSql.append(" and a.estado = 'A' and a.consignacion_sino = 'N' ");
	//sbSql.append(" and exists (select null from tbl_com_proveedor where cod_provedor = b.cod_provedor and compania = b.compania and estado_proveedor = 'ACT')");
	sbSql.append(" order by 4");
    
    if (request.getParameter("beginSearch") != null){
        al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql+") a) where rn between "+previousVal+" and "+nextVal);
        rowCount = CmnMgr.getCount("select count(*) from ("+sbSql+")");
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
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Compras - '+document.title;
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
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame(); $("#cod_barra").focus(); }
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,200);}
</script>

<!--
	Dejar en blanco [fieldsToBeCleared] si el form donde esta el cod barra tiene bastante
	inputs y no quieres enumerar todos :D

	La orden importa de los mensajes en wrongFrmElMsg
	ver formExists() in inc_barcode_filter.jsp
-->
<jsp:include page="../common/inc_barcode_filter.jsp" flush="true" >
	<jsp:param name="formEl" value="search00"></jsp:param>
	<jsp:param name="barcodeEl" value="cod_barra"></jsp:param>
	<jsp:param name="fieldsToBeCleared" value=""></jsp:param>
	<jsp:param name="wrongFrmElMsg" value="No podemos encontrar el formulario que tiene el input código barra,No podemos encontrar en el DOM el formulario,No encontramos el campo de texto para el código de barra,No encontramos en el DOM el campo de texto"></jsp:param>
</jsp:include>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - SELECCION DE ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
<tr>
	<td align="right">&nbsp;</td>
</tr>
<tr>
	<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
		<table width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextFilter">
<%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("filterProveedor",filterProveedor)%>
<%=fb.hidden("proveedor",proveedor)%>
<%=fb.hidden("beginSearch","")%>
			<td>
				<cellbytelabel>Familia</cellbytelabel>
				<%=fb.intBox("familia",familia,false,false,false,4)%>
				<cellbytelabel>Clase</cellbytelabel>
				<%=fb.intBox("clase",clase,false,false,false,4)%>
				<cellbytelabel>Sub Clase</cellbytelabel>
				<%=fb.intBox("subclase",subclase,false,false,false,4)%>
				<cellbytelabel>Art&iacute;culo</cellbytelabel>
				<%=fb.intBox("articulo",articulo,false,false,false,4)%>
				<cellbytelabel>Descripci&oacute;n</cellbytelabel>
				<%=fb.textBox("descripcion",descripcion,false,false,false,20)%>
				<cellbytelabel>Proveedor</cellbytelabel>
				<%=fb.textBox("nombreProveedor",nombreProveedor,false,false,false,20)%>
				<%=fb.submit("go","Ir")%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<cellbytelabel>C.Barra</cellbytelabel>
				<%=fb.textBox("cod_barra",codBarra,false,false,false,15,null,null,"onkeypress=\"allowEnter(event);\", onFocus=\"this.select()\"")%>
			</td>
<%=fb.formEnd()%>
		</tr>
		</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</td>
</tr>
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("filterProveedor",filterProveedor)%>
<%=fb.hidden("proveedor",proveedor)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("cod_barra",codBarra)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("nombreProveedor",nombreProveedor)%>
<%=fb.hidden("beginSearch","")%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("filterProveedor",filterProveedor)%>
<%=fb.hidden("proveedor",proveedor)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("cod_barra",codBarra)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("nombreProveedor",nombreProveedor)%>
<%=fb.hidden("beginSearch","")%>
			<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
<%=fb.formEnd()%>
		</tr>
		</table>
	</td>
</tr>
<%fb = new FormBean("articles",request.getContextPath()+request.getServletPath(),FormBean.POST);//onSubmit=\"javascript:return (chkQty())\"%>
<%=fb.formStart()%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("filterProveedor",filterProveedor)%>
<%=fb.hidden("proveedor",proveedor)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("cod_barra",codBarra)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("nombreProveedor",nombreProveedor)%>
<%=fb.hidden("beginSearch","")%>
<tr>
	<td class="TableLeftBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr>
			<td align="left" class="TextInfo"><!--* Art&iacute;culos se encuentran en otra requisicion aprobada y sin entregar!--></td>
			<td align="right"><%=fb.submit("add","Agregar")%>&nbsp;<%=fb.submit("addCont","Agregar y Continuar")%>&nbsp;</td>
		</tr>
		</table>
	</td>
</tr>
<tr>
	<td class="TableLeftBorder TableRightBorder">
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextHeader">
			<td align="center" colspan="4"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="11%" align="center" rowspan="2"><cellbytelabel>Código Barra</cellbytelabel></td>
			<td width="20%" align="center" rowspan="2"><cellbytelabel>Proveedor</cellbytelabel></td>
			<td width="30%" align="center" rowspan="2"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="5%" align="center" rowspan="2"><cellbytelabel>Und</cellbytelabel>.</td>
			<td width="5%" align="center" rowspan="2"><cellbytelabel>Disponible</cellbytelabel></td>
			<td width="6%" align="center" rowspan="2"><cellbytelabel>Cantidad</cellbytelabel></td>
			<td width="9%" align="center" rowspan="2">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td width="4%" align="center"><cellbytelabel>Familia</cellbytelabel></td>
			<td width="4%" align="center"><cellbytelabel>Clase</cellbytelabel></td>
			<td width="6%" align="center"><cellbytelabel>SubClase</cellbytelabel></td>
			<td width="5%" align="center"><cellbytelabel>Art&iacute;culo</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al.size(); i++) {
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("cod_flia"+i,cdo.getColValue("cod_flia"))%>
		<%=fb.hidden("cod_clase"+i,cdo.getColValue("cod_clase"))%>
		<%=fb.hidden("subclase_id"+i,cdo.getColValue("subclase_id"))%>
		<%=fb.hidden("nombre_proveedore"+i,cdo.getColValue("nombre_proveedore"))%>
		<%=fb.hidden("cod_articulo"+i,cdo.getColValue("cod_articulo"))%>
		<%=fb.hidden("cod_barra"+i,cdo.getColValue("cod_barra"))%>
		<%=fb.hidden("art_desc"+i,cdo.getColValue("articulo"))%>
		<%=fb.hidden("itbm"+i,cdo.getColValue("itbm"))%>
		<%=fb.hidden("unidad"+i,cdo.getColValue("cod_medida"))%>
		<%=fb.hidden("ult_precio"+i,cdo.getColValue("ult_precio"))%>
		<%=fb.hidden("other1"+i,cdo.getColValue("other1"))%>
		<%=fb.hidden("other2"+i,cdo.getColValue("other2"))%>
		<%=fb.hidden("other5"+i,cdo.getColValue("other5"))%>
		<%=fb.hidden("disponible"+i,cdo.getColValue("disponible"))%>
<%
	String onChange = "onFocus=\"this.select();\" onChange=\"javascript:setChecked(this,document.articles.chkArt"+i+")\"";
	/*if(OCDet.getReqType().equals("EC") || OCDet.getReqType().equals("EA")){
		onChange = "onBlur=\"javascript:verValue("+i+")\"";
	}*/
	String key = "";
	String artKey = cdo.getColValue("cod_flia") +"-"+cdo.getColValue("cod_clase")  +"-"+cdo.getColValue("subclase_id") +"-"+cdo.getColValue("cod_articulo");
	if(ocArtKey.containsKey(artKey)) key = (String) ocArtKey.get(artKey);
	if (ocArt.containsKey(key)){
%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("cod_flia")%></td>
			<td><%=cdo.getColValue("cod_clase")%></td>
			<td><%=cdo.getColValue("subclase_id")%></td>
			<td><%=cdo.getColValue("cod_articulo")%></td>
			<td><%=cdo.getColValue("cod_barra")%></td>
			<td align="left"><%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="left"><%=cdo.getColValue("articulo")%></td>
			<td align="center"><%=cdo.getColValue("cod_medida")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal("###,###", cdo.getColValue("disponible"))%>&nbsp;&nbsp;</td>
			<td align="right"><%=fb.intBox("cantidad"+i,((OrdenCompraDetail) ocArt.get(key)).getCantidad(),true,false,false,5,"","",onChange)%></td>
			<td align="center"><cellbytelabel>elegido</cellbytelabel></td>
		</tr>
<% } else { %>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("cod_flia")%></td>
			<td><%=cdo.getColValue("cod_clase")%></td>
			<td><%=cdo.getColValue("subclase_id")%></td>
			<td><%=cdo.getColValue("cod_articulo")%></td>
			<td><%=cdo.getColValue("cod_barra")%></td>
			<td align="left"><%=cdo.getColValue("nombre_proveedor")%></td>
			<td align="left"><%=cdo.getColValue("articulo")%></td>
			<td align="center"><%=cdo.getColValue("cod_medida")%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal("###,###", cdo.getColValue("disponible"))%>&nbsp;&nbsp;</td>
			<td align="right"><%=fb.intBox("cantidad"+i,"0",true,false,false,5,"","",onChange)%></td>
			<td align="center"><%=fb.checkbox("chkArt"+i,""+i)%></td>
		</tr>
<%
	}
}
%>
		</table>
</div>
</div>
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	</td>
</tr>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
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
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("filterProveedor",filterProveedor)%>
<%=fb.hidden("proveedor",proveedor)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("cod_barra",codBarra)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("nombreProveedor",nombreProveedor)%>
<%=fb.hidden("beginSearch","")%>
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("filterProveedor",filterProveedor)%>
<%=fb.hidden("proveedor",proveedor)%>
<%=fb.hidden("familia",familia)%>
<%=fb.hidden("clase",clase)%>
<%=fb.hidden("subclase",subclase)%>
<%=fb.hidden("articulo",articulo)%>
<%=fb.hidden("cod_barra",codBarra)%>
<%=fb.hidden("descripcion",descripcion)%>
<%=fb.hidden("nombreProveedor",nombreProveedor)%>
<%=fb.hidden("beginSearch","")%>
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
} else {
	System.out.println("=====================POST=====================");
	int lineNo = OCDet.getOCDetails().size();
	String artDel = "", key = "";;
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	for(int i=0;i<keySize;i++){

		OrdenCompraDetail oc = new OrdenCompraDetail();
		oc.setCodFlia(request.getParameter("cod_flia"+i));
		oc.setCodClase(request.getParameter("cod_clase"+i));
		oc.setSubclaseId(request.getParameter("subclase_id"+i));
		oc.setCodArticulo(request.getParameter("cod_articulo"+i));
		oc.setArticulo(request.getParameter("art_desc"+i));
		oc.setItbm(request.getParameter("itbm"+i));
		oc.setUnidad(request.getParameter("unidad"+i));
		oc.setCantEmpaque(request.getParameter("cantidad"+i));
		oc.setMonto(request.getParameter("ult_precio"+i));
		if(request.getParameter("other1"+i)!=null && !request.getParameter("other1"+i).equals("")) oc.setUnidadEmpaque(request.getParameter("other1"+i));
		if(request.getParameter("other2"+i)!=null && !request.getParameter("other2"+i).equals("")) oc.setCantPorEmpaque(request.getParameter("other2"+i));
		if(oc.getCantPorEmpaque()!=null && !oc.getCantPorEmpaque().equals("")) oc.setCantidad(""+(Integer.parseInt(oc.getCantPorEmpaque())*Integer.parseInt(oc.getCantEmpaque())));
		oc.setTotal("0");

		oc.setDescuento("0");
		oc.setTipoDescuento("P");
		oc.setCantPromo("0");
		oc.setCantPromoEmp("0");
		oc.setImpuesto(request.getParameter("other5"+i)); 
		oc.setEntregado("0");
		oc.setCantidadAcumulada("0");
		oc.setEntregadoPromo("0");

		oc.setAction("I");

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
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&id="+id+"&filterProveedor="+filterProveedor+"&proveedor="+proveedor+"&change=1&type=1&anio="+anio+"&fp="+fp+"&beginSearch=");


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
