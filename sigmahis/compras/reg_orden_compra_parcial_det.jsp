<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="OCDet" scope="session" class="issi.compras.OrdenCompra"/>
<jsp:useBean id="OCMgr" scope="session" class="issi.compras.OrdenCompraMgr"/>
<jsp:useBean id="ocArt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ocArtKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="cdo2" scope="page" class="issi.admin.CommonDataObject"/>
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
OCMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String key = "";
boolean viewMode = false;
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String anio = request.getParameter("anio");
if(anio == null) anio=fecha.substring(6, 10);
String type = request.getParameter("type");
String filterProveedor = request.getParameter("filterProveedor")==null?"":request.getParameter("filterProveedor");
String fg = request.getParameter("fg");
if (fg == null) fg = "view";  // Eso es solo para evitar null  y receibir valor que no debe equals  "EOC".

int lineNo = 0;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

String taxPercent = "0";
if (session.getAttribute("_taxPercent") != null && !session.getAttribute("_taxPercent").toString().trim().equals("")) {
	try {
		Double.parseDouble(session.getAttribute("_taxPercent").toString());
		taxPercent = session.getAttribute("_taxPercent").toString();
	} catch (Exception ex) {
		System.out.println("* * * _taxPercent is invalid! * * *");
	}
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change==null){
		OCDet = new OrdenCompra();
		session.setAttribute("OCDet",OCDet);
		ocArt.clear();
		ocArtKey.clear();
		OCDet.setAnio(anio);

		sbSql.append("select tipo_com, descripcion from tbl_com_tipo_compromiso where tipo_com = 3");
		cdo2 = SQLMgr.getData(sbSql.toString());
		OCDet.setTipoCompromiso(cdo2.getColValue("tipo_com"));
		OCDet.setDescTipoCompromiso(cdo2.getColValue("descripcion"));
		OCDet.setFechaDocto(fecha);
	}
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		OCDet.setNumDoc("0");
	}
	else
	{
		if (id == null) throw new Exception("Requisición no es válida. Por favor intente nuevamente!");

		if (change==null || change.equals("null")){
			/* quitamos sub_clase ya que en orden de compra, se esta ignorando los articulos
			sin sub_clase
			sql = "SELECT a.*, b.* FROM (SELECT a.cod_flia||'-'||a.cod_clase||'-'||a.cod_subclase||'-'||a.cod_articulo art_key, a.compania, a.cod_flia codFlia, a.cod_clase codClase,a.cod_subclase  subclaseId, a.cod_articulo codArticulo, a.descripcion articulo, a.itbm, a.cod_medida unidad, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, c.descripcion descArtClase FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c WHERE (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND a.compania = "+session.getAttribute("_companyId")+") a, (SELECT a.cod_familia||'-'||a.cod_clase||'-'||a.subclase_id||'-'||a.cod_articulo art_key, NVL(anio_requi,0) aniorequi, NVL(requi_num,0) requinum, a.cantidad, monto_articulo monto, round(cantidad*monto_articulo,6) total, entregado, nvl(a.estado_renglon,' ') estadorenglon, especificacion, a.cant_por_empaque cantPorEmpaque, a.unidad_empaque unidadEmpaque, (a.cantidad/a.cant_por_empaque) cantEmpaque FROM TBL_COM_DETALLE_COMPROMISO a WHERE a.cf_tipo_com = 3 and a.compania = "+session.getAttribute("_companyId")+" AND a.cf_anio = "+anio+" AND a.cf_num_doc = "+id+") b WHERE a.art_key = b.art_key order by a.codflia, a.codclase,a.subclaseId, a.codarticulo";*/

			cdo2 = new CommonDataObject();
			if (viewMode) {
				sbSql = new StringBuffer();
				sbSql.append("select nvl(get_sec_comp_param(");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(",'COM_OC_ADD_BARCODE'),'N') as add_barcode from dual");
				cdo2 = SQLMgr.getData(sbSql);
			}
			sbSql = new StringBuffer();
			sbSql.append("select a.compania, (select cod_flia from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as codFlia, (select cod_clase from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as codClase, (select cod_subclase from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as subclaseId, a.cod_articulo as codArticulo, a.cantidad, a.monto_articulo as monto, nvl(a.estado_renglon,' ') as estadoRenglon, nvl(a.especificacion,' ') as especificacion, a.cant_por_empaque as cantPorEmpaque, a.unidad_empaque as unidadEmpaque, (a.cantidad / a.cant_por_empaque) as cantEmpaque, (nvl(a.cant_promo,0) / a.cant_por_empaque) as cantPromoEmp, nvl(a.descuento,0) as descuento, nvl(a.tipo_descuento,'P') as tipoDescuento");
			if (viewMode) sbSql.append(", a.itbm ");
			else sbSql.append(", (select itbm from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as itbm");
			sbSql.append(", (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as unidad");
			sbSql.append(", (select ");
			if (cdo2.getColValue("add_barcode") != null && cdo2.getColValue("add_barcode").equalsIgnoreCase("S")) sbSql.append("decode(cod_barra,null,'','('||cod_barra||') ')||");
			sbSql.append("descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as articulo");
			if (viewMode) sbSql.append(", a.impuesto");
			else sbSql.append(", (select decode(itbm,'S',nvl(other5,0),0) from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as impuesto");
			sbSql.append(", nvl(a.entregado,0) as entregado,nvl(cantidad_acumulada,0) as cantidadAcumulada ,nvl(entregado_promo,0) as entregadoPromo");
			sbSql.append(", (join(cursor(select (select descripcion from tbl_inv_almacen where compania = z.compania and codigo_almacen = z.codigo_almacen)||': '||z.disponible from tbl_inv_inventario z where z.compania = a.compania and z.cod_articulo = a.cod_articulo order by z.codigo_almacen),'<br/>')) as usuarioCrea");
			sbSql.append(" from tbl_com_detalle_compromiso a where a.cf_tipo_com = 3 and a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.cf_anio = ");
			sbSql.append(anio);
			sbSql.append(" and a.cf_num_doc = ");
			sbSql.append(id);
			sbSql.append(" order by a.cod_familia, a.cod_clase, a.subclase_id, a.cod_articulo");
			System.out.println("sqlDetails.... jose ="+sbSql);

			OCDet.setOCDetails(sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),OrdenCompraDetail.class));
			for(int i=0;i<OCDet.getOCDetails().size();i++){
				OrdenCompraDetail oc = (OrdenCompraDetail) OCDet.getOCDetails().get(i);
				oc.setAction("U");
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try {
					ocArt.put(key, oc);
					ocArtKey.put(oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getSubclaseId()+"-"+oc.getCodArticulo(), key);
				}	catch (Exception e)	{
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Orden de Compra - '+document.title;
function doAction(){
<% if (type != null && type.equals("1")) {%>abrir_ventana1("../compras/sel_articles_orden_compra.jsp?fp=parcial&mode=<%=mode%>&id=<%=id%>&anio=<%=OCDet.getAnio()%>&filterProveedor=<%=filterProveedor%>&cod_almacen="+parent.document.ordencompra.codigo_almacen.value+"&proveedor="+parent.document.ordencompra.cod_proveedor.value);<% } else if (type != null && type.equals("3")) { %>abrir_ventana1('../compras/sel_articles_requisicion.jsp?fp=parcial&mode=<%=mode%>&id=<%=id%>&anio=<%=OCDet.getAnio()%>'+"&proveedor="+parent.document.ordencompra.cod_proveedor.value);<% } %>
calc();
newHeight();
}
function calcPromo(k){
	var cantXEmp=eval('document.ordencompra.cantPorEmpaque'+k).value;
	var cantPromoEmp=eval('document.ordencompra.cantPromoEmp'+k).value;
	if(cantPromoEmp==null||cantPromoEmp.trim()==''||isNaN(cantPromoEmp))cantPromoEmp=0.0;
	else cantPromoEmp=parseFloat(cantPromoEmp);
	var cantPromo=cantXEmp*cantPromoEmp;
	eval('document.ordencompra.cantPromo'+k).value=cantPromo;
}
/*
k=idx -> calculate row values and calculate totals column (global discount, taxes and totals)
k=-1  -> calculate totals column (global discount, taxes and totals)
k=undefined or null -> calculate all rows and totals column
*/
function calc(k){
try{
	var gDisc=document.ordencompra.porcentaje.value;//descuento global
	var gDiscType=document.ordencompra.tipodescuento.value;//tipo descuento global
	if(gDisc==null||gDisc.trim()==''||isNaN(gDisc))gDisc=0.0;
	else gDisc=parseFloat(gDisc);
		
	if(gDiscType=='M'){
		if(gDisc>subtotal1){
			gDisc=0.0;
			document.ordencompra.porcentaje.value=gDisc.toFixed(2);
			throw 'El Descuento es mayor al Subtotal!';
		}
	}else if(gDiscType=='P'){
		if(gDisc>100){
			gDisc=0.0;
			document.ordencompra.porcentaje.value=gDisc.toFixed(2);
			throw 'El Descuento es mayor al 100%!';
		}
	}
	document.ordencompra.porcentaje.value=gDisc.toFixed(2);

	var size=document.ordencompra.keySize.value;
	var cantXEmp=0,cantEmp=0.0,cant=0.0,costo=0.0,iDisc=0.0,iDiscType='',iTotal=0.0,iTax=0.0;
	var subtotal=0.0,tDisc=0.0,tTax=0.0;
	//loop para calculo de descuentos x item y de totales x item
	for(i=0;i<size;i++){
	  if (eval('document.ordencompra.action'+i).value !='D') {
		if(k==undefined||k==null||parseInt(k,10)==i){
			cantXEmp=eval('document.ordencompra.cantPorEmpaque'+i).value;
			cantEmp=eval('document.ordencompra.cantEmp'+i).value;
			cant=cantXEmp*cantEmp;
			eval('document.ordencompra.cantidad'+i).value=cant;
			calcPromo(i);
			costo=eval('document.ordencompra.costo'+i).value;
			if(costo==null||costo.trim()==''||isNaN(costo))costo=0.0;
			else costo=parseFloat(costo);
			//eval('document.ordencompra.costo'+i).value=parseFloat(costo).toFixed(10);

			/* D E S C U E N T O   X   I T E M */
			iDisc=eval('document.ordencompra.descuento'+i).value;
			iDiscType=eval('document.ordencompra.tipoDescuento'+i).value;
			if(iDisc==null||iDisc.trim()==''||isNaN(iDisc))iDisc=0.0;
			else iDisc=parseFloat(iDisc);
			if(iDiscType=='M'){
				if(iDisc>costo){
					iDisc=0.0;
					eval('document.ordencompra.descuento'+i).value=iDisc;
					throw 'El Descuento es mayor al Costo!';
				}
				iTotal=cant*(costo-iDisc);
			}else if(iDiscType=='P'){
				if(iDisc>100){
					iDisc=0.0;
					eval('document.ordencompra.descuento'+i).value=iDisc;
					throw 'El Descuento es mayor al 100%!';
				}
				iTotal=cant*costo*(1-(iDisc/100));
			}
			eval('document.ordencompra.descuento'+i).value=iDisc;
			iTotal=round(iTotal,6);
			eval('document.ordencompra.total'+i).value=iTotal.toFixed(6);
		}else iTotal=parseFloat(eval('document.ordencompra.total'+i).value);
		subtotal+=iTotal;
	  }
	}
	document.ordencompra.subtotal1.value=subtotal.toFixed(6);

	//loop para calculo de descuento global y de impuesto
	for(i=0;i<size;i++){
	if (eval('document.ordencompra.action'+i).value !='D') {
		iTotal=parseFloat(eval('document.ordencompra.total'+i).value);

		/* D E S C U E N T O   G L O B A L */
		var disc=0.0;
		if(gDiscType=='M')disc=round(gDisc*(iTotal/subtotal),6);
		else if(gDiscType=='P')disc=round((gDisc/100)*iTotal,6);
		tDisc+=disc;
		
		/* I M P U E S T O   X   I T E M */
		iTax=eval('document.ordencompra.impuesto'+i).value;//item tax
		if(iTax==null||iTax.trim()==''||isNaN(iTax))iTax=0.0;
		else iTax=parseFloat(iTax);
	<% if (!viewMode) { %>
		var isTaxable=eval('document.ordencompra.itbm'+i).value//is item taxable
		//es gravable y no tiene impuesto item, entonces toma impuesto de compañía
		if(isTaxable=='S'){if(parseFloat(iTax)==0)iTax=<%=taxPercent%>;}
		else iTax=0.0;
		//solo asignar impuesto al final cuando guarda
		if(document.ordencompra.baction.value=='Guardar')eval('document.ordencompra.impuesto'+i).value=iTax;
	<% } %>
		if(iTax!=0)tTax+=round((iTotal-disc)*(iTax/100),2);
	  }
	}
	//tDisc=round(tDisc,2);
	document.ordencompra.descuento.value=tDisc.toFixed(6);
	document.ordencompra.subtotal2.value=(subtotal-tDisc).toFixed(6);
	document.ordencompra.itbm.value=tTax.toFixed(6);
	document.ordencompra.total.value=(subtotal-tDisc+tTax).toFixed(6);
	return true;
}catch(err){
	alert(err);
	return false;
}
}
function doSubmit(value){

    var filterProveedor = value=="Art. Todos"?"N":"Y";
	
	document.ordencompra.baction.value=value;
	document.ordencompra.tipo_compromiso.value=parent.document.ordencompra.tipo_compromiso.value;
	document.ordencompra.desc_tipo_compromiso.value=parent.document.ordencompra.desc_tipo_compromiso.value;
	document.ordencompra.anio.value=parent.document.ordencompra.anio.value;
	document.ordencompra.num_doc.value=parent.document.ordencompra.num_doc.value;
	document.ordencompra.estatus.value=parent.document.ordencompra.estatus.value;
	document.ordencompra.tipo_pago.value=parent.document.ordencompra.tipo_pago.value;
	document.ordencompra.diaLimite.value=parent.document.ordencompra.diaLimite.value;
	document.ordencompra.filterProveedor.value=filterProveedor; //parent.document.ordencompra.filterProveedor.value;
	document.ordencompra.fecha_documento.value=parent.document.ordencompra.fecha_documento.value;
	document.ordencompra.fechaEntProv.value=parent.document.ordencompra.fechaEntProv.value;
	document.ordencompra.fechaEntVence.value=parent.document.ordencompra.fechaEntVence.value;
	document.ordencompra.cod_proveedor.value=parent.document.ordencompra.cod_proveedor.value;
	document.ordencompra.desc_cod_proveedor.value=parent.document.ordencompra.desc_cod_proveedor.value;
	document.ordencompra.codigo_almacen.value=parent.document.ordencompra.codigo_almacen.value;
	document.ordencompra.explicacion.value=parent.document.ordencompra.explicacion.value;
	document.ordencompra.anio_requi.value=parent.document.ordencompra.anio_requi.value;
	document.ordencompra.no_requi.value=parent.document.ordencompra.no_requi.value;
	//document.ordencompra.tieneDesc.value=parent.document.ordencompra.tieneDesc.value;
	//document.ordencompra.tipodescuento.value=parent.document.ordencompra.tipodescuento.value;
	if(!ordencompraValidation()){
		parent.ordencompraBlockButtons(false);
		ordencompraBlockButtons(false);
		return false;
	}else{
		if(parent.ordencompraValidation()){parent.ordencompraBlockButtons(false);if(value=='Guardar'){parent.ordencompraBlockButtons(true);}document.ordencompra.submit();}
	}
}

function setLastPrice(almacen){
	var size = document.ordencompra.keySize.value;
	var cod_prov = parent.document.ordencompra.cod_proveedor.value;
	var cod_art = '';
	if(size>0){
		if(confirm('Si cambia de almacén los precios de costo pueden ser modificados.  Desea cambiar el almacén?')){
			for(i=0;i<size;i++){
			if (eval('document.ordencompra.action'+i).value !='D') {
				cod_art = eval('document.ordencompra.cod_articulo'+i).value;
				var vprecio = getDBData('<%=request.getContextPath()%>','getlastprecioprov(<%=(String) session.getAttribute("_companyId")%>,'+cod_prov+', '+almacen+','+cod_art+')','dual','','');
				if(vprecio!=''){
					eval('document.ordencompra.costo'+i).value = vprecio;
				} else eval('document.ordencompra.costo'+i).value = 0;
			calMonto(i);
			}
			}
		} else parent.document.ordencompra.codigo_almacen.value = parent.document.ordencompra.codigo_almacen_bk.value;
	} else parent.document.ordencompra.codigo_almacen_bk.value = parent.document.ordencompra.codigo_almacen.value;
}
$(document).ready(function(){jqTooltip();});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("ordencompra",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("tipo_compromiso","")%>
<%=fb.hidden("desc_tipo_compromiso","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("num_doc","")%>
<%=fb.hidden("estatus","")%>
<%=fb.hidden("tipo_pago","")%>
<%=fb.hidden("diaLimite","")%>
<%=fb.hidden("filterProveedor","")%>
<%=fb.hidden("fecha_documento","")%>
<%=fb.hidden("fechaEntProv","")%>
<%=fb.hidden("fechaEntVence","")%>
<%=fb.hidden("cod_proveedor","")%>
<%=fb.hidden("desc_cod_proveedor","")%>
<%=fb.hidden("codigo_almacen","")%>
<%=fb.hidden("explicacion","")%>
<%=fb.hidden("anio_requi","")%>
<%=fb.hidden("no_requi","")%>
<%=fb.hidden("tieneDesc","")%>
<%//=fb.hidden("tipodescuento","")%>
<%=fb.hidden("keySize",""+ocArt.size())%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".validSize.value==0){alert('Seleccione por lo menos un (1) artículo!');error++;}else if(!calc())error++;");%>
<tr class="TextPanel">
	<td colspan="9"><cellbytelabel>Detalle de la Solicitud</cellbytelabel></td>
	<td colspan="7">
	<authtype type='50'>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<%=fb.button("addArticlesP","Art. Solo Proveedor",false,viewMode,"","","onClick=\"javascript:doSubmit(this.value)\"")%></authtype>
	<authtype type='51'>
	&nbsp;&nbsp;
	<%=fb.button("addArticlesA","Art. Todos",false,viewMode,"","","onClick=\"javascript:doSubmit(this.value)\"")%></authtype>
	</td>
</tr>
<tr align="center" class="TextHeader">
	<td colspan="4" rowspan="2"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
	<td rowspan="2" width="19%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td rowspan="2" width="13%"><cellbytelabel>Detalle</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Empaque</cellbytelabel></td>
	<td colspan="3"><cellbytelabel>Unidad</cellbytelabel></td>
	<td rowspan="2" width="11%"><cellbytelabel>Costo</cellbytelabel></td>
	<td rowspan="2" width="11%"><cellbytelabel>Descuento</cellbytelabel></td>
	<td rowspan="2" width="10%"><cellbytelabel>Total</cellbytelabel></td>
	<td rowspan="2" width="3%">&nbsp;</td>
</tr>
<tr align="center" class="TextHeader">
	<td width="3%"><cellbytelabel>Und</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Cant</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Prom</cellbytelabel></td>
	<td width="3%"><cellbytelabel>Und</cellbytelabel></td>
	<td width="5%"><cellbytelabel>Cant</cellbytelabel></td>
	<td width="4%"><cellbytelabel>Prom</cellbytelabel></td>
</tr>
<%
if (ocArt.size() != 0) al = CmnMgr.reverseRecords(ocArt);
int validSize = 0;
for (int i=0; i<ocArt.size(); i++) {
	OrdenCompraDetail oc = (OrdenCompraDetail) ocArt.get(al.get(i).toString());
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	boolean isReadOnly = false;
	if(!oc.getEntregado().trim().equals("0")||!oc.getEntregadoPromo().trim().equals("0"))isReadOnly=true;
%>
<%=fb.hidden("cod_flia"+i,oc.getCodFlia())%>
<%=fb.hidden("cod_clase"+i,oc.getCodClase())%>
<%=fb.hidden("subclase_id"+i,oc.getSubclaseId())%>
<%=fb.hidden("cod_articulo"+i,oc.getCodArticulo())%>
<%=fb.hidden("articulo"+i,oc.getArticulo())%>
<%=fb.hidden("cantPorEmpaque"+i,oc.getCantPorEmpaque())%>
<%=fb.hidden("unidadEmpaque"+i,oc.getUnidadEmpaque())%>
<%=fb.hidden("unidad"+i,oc.getUnidad())%>
<%=fb.hidden("itbm"+i,oc.getItbm())%>
<%=fb.hidden("impuesto"+i,oc.getImpuesto())%>
<%=fb.hidden("action"+i,oc.getAction())%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("entregado"+i,oc.getEntregado())%> 
<%=fb.hidden("cantidad_acumulada"+i,oc.getCantidadAcumulada())%> 
<%=fb.hidden("entregado_promo"+i,oc.getEntregadoPromo())%> 
<%=fb.hidden("estadoRenglon"+i,oc.getEstadoRenglon())%>  
<%=fb.hidden("usuarioCrea"+i,oc.getUsuarioCrea())%>

<%if(oc.getAction().equalsIgnoreCase("D")){%>

<%=fb.hidden("especificacion"+i,oc.getEspecificacion())%>
<%=fb.hidden("cantEmp"+i,oc.getCantEmpaque())%>
<%=fb.hidden("cantPromoEmp"+i,oc.getCantPromoEmp())%>
<%=fb.hidden("cantidad"+i,oc.getCantidad())%>
<%=fb.hidden("cantPromo"+i,oc.getCantPromo())%>
<%=fb.hidden("costo"+i,oc.getMonto())%>
<%=fb.hidden("descuento"+i,oc.getDescuento())%>
<%=fb.hidden("total"+i,oc.getTotal())%>

<% } else { validSize++; %>
<tr class="TextRow01" align="center">
	<td width="2%"><%=oc.getCodFlia()%></td>
	<td width="2%"><%=oc.getCodClase()%></td>
	<td width="3%"><%=oc.getSubclaseId()%></td>
	<td width="4%"><%=oc.getCodArticulo()%></td>
	<td align="left" class="_jqHint <%=(oc.getItbm()!=null && oc.getItbm().equals("S")?"RedText":"")%>" hintMsgId="disponible<%=i%>"><%=oc.getArticulo()%><span id="disponible<%=i%>" class="_jqHintMsg"><%=oc.getUsuarioCrea()%></span></td>
	<td><%=fb.textBox("especificacion"+i,oc.getEspecificacion(),false,false,viewMode,25,"Text10",null,"")%></td>
	<td><%=oc.getUnidadEmpaque()%></td>
	<td><%=fb.decPlusBox("cantEmp"+i,oc.getCantEmpaque(),true,false,viewMode,4,8.2,"Text10","","onChange=\"javascript:calc("+i+")\"")%></td>
	<td><%=fb.decPlusZeroBox("cantPromoEmp"+i,oc.getCantPromoEmp(),false,false,viewMode,3,8.2,"Text10",null,"onChange=\"javascript:calcPromo("+i+")\"")%></td>
	<td><%=oc.getUnidad()%></td>
	<td><%=fb.decPlusBox("cantidad"+i,oc.getCantidad(),true,false,true,6,8.2,"Text10",null,null)%></td>
	<td><%=fb.decPlusZeroBox("cantPromo"+i,oc.getCantPromo(),false,false,true,3,8.2,"Text10",null,null)%></td>
	<td><%=fb.decBox("costo"+i,oc.getMonto(),true,false,viewMode,20,"11.10","Text10",null,"onChange=\"javascript:calc("+i+")\"")%></td>
	<td><%=fb.decBox("descuento"+i,oc.getDescuento(),false,false,viewMode,9,"3.10","Text10",null,"onChange=\"javascript:calc("+i+")\"")%><% if (viewMode) { %><%=fb.hidden("tipoDescuento"+i,oc.getTipoDescuento())%><%=fb.select("tipoDescuentoDsp"+i,"P=%,M=$",oc.getTipoDescuento(),false,viewMode,0,"Text10",null,null)%><% } else { %><%=fb.select("tipoDescuento"+i,"P=%,M=$",oc.getTipoDescuento(),false,viewMode,0,"Text10",null,"onChange=\"javascript:calc("+i+")\"")%><% } %></td>
	<td><%=fb.decBox("total"+i,oc.getTotal(),true,false,viewMode,17,"Text10",null,"")%><% if (viewMode) { %><%=fb.textBox("estado_r"+i,oc.getEstadoRenglon(),false,false,true,1,"Text10",null,"")%><% } %></td>
	<td align="center"><%//=fb.submit("del"+i,"X",false,viewMode)%>
	<%=fb.submit("rem"+i,"X",true,(viewMode||isReadOnly),"",null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>
	</td>
</tr>
<%} } %>
<%=fb.hidden("validSize",""+validSize)%>
<tr class="TextRow01">
	<td colspan="12" align="right">&nbsp;</td>
	<td colspan="2"><cellbytelabel>Subtotal 1</cellbytelabel></td>
	<td align="center"><%=fb.decBox("subtotal1",OCDet.getSubTotal(),true,false,viewMode,17,"Text10",null,"")%></td>
	<td>&nbsp;</td>
</tr>
<tr class="TextRow01">
	<td colspan="12" align="right">&nbsp;</td>
	<td colspan="2"><cellbytelabel>Descuento</cellbytelabel>&nbsp;<%=fb.decPlusZeroBox("porcentaje",OCDet.getPorcentaje(),true,false,viewMode,9,"Text10",null,"onChange=\"javascript:calc(-1)\"")%><% if (viewMode) { %><%=fb.hidden("tipodescuento",OCDet.getTipodescuento())%><%=fb.select("tipodescuentoDsp","P=%,M=$",OCDet.getTipodescuento(),false,viewMode,0,"Text10",null,null)%><% } else { %><%=fb.select("tipodescuento","P=%,M=$",OCDet.getTipodescuento(),false,viewMode,0,"Text10",null,"onChange=\"javascript:calc(-1)\"")%><% } %></td>
	<td align="center"><%=fb.decBox("descuento",OCDet.getDescuento(),true,false,viewMode,17,"Text10",null,"")%></td>
	<td>&nbsp;</td>
</tr>
<tr class="TextRow01">
	<td colspan="12" align="right">&nbsp;</td>
	<td colspan="2"><cellbytelabel>Subtotal 2</cellbytelabel></td>
	<td align="center"><%=fb.decBox("subtotal2",OCDet.getSubTotal2(),true,false,viewMode,17,"Text10",null,"")%></td>
	<td>&nbsp;</td>
</tr>
<tr class="TextRow01">
	<td colspan="12" align="right">&nbsp;</td>
	<td colspan="2"><cellbytelabel>I.T.B.M.</cellbytelabel></td>
	<td align="center"><%=fb.decBox("itbm",OCDet.getItbm(),true,false,viewMode,17,"Text10",null,"")%></td>
	<td>&nbsp;</td>
</tr>
<tr class="TextRow01">
	<td colspan="12" align="right">&nbsp;</td>
	<td colspan="2"><cellbytelabel>Total</cellbytelabel></td>
	<td align="center"><%=fb.decBox("total",OCDet.getMontoTotal(),true,false,viewMode,17,"Text10",null,"")%></td>
	<td>&nbsp;</td>
</tr>
<%=fb.formEnd(true)%>
</table>
<%//@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{

	String companyId = (String) session.getAttribute("_companyId");
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	String artDel = "", orden_compra_no = "";
	OCDet.setCompania(companyId);
	OCDet.setAnio(request.getParameter("anio"));
	OCDet.setNumDoc(request.getParameter("num_doc"));
	OCDet.setTipoCompromiso(request.getParameter("tipo_compromiso"));
	OCDet.setFechaDocto(request.getParameter("fecha_documento"));
	OCDet.setTipoPago(request.getParameter("tipo_pago"));
	OCDet.setCodProveedor(request.getParameter("cod_proveedor"));
	OCDet.setCodAlmacen(request.getParameter("codigo_almacen"));
	OCDet.setLugarEntrega(request.getParameter("codigo_almacen"));
	OCDet.setExplicacion(request.getParameter("explicacion"));

	OCDet.setUsuario((String) session.getAttribute("_userName"));
	OCDet.setUsuarioMod((String) session.getAttribute("_userName"));

	OCDet.setNoInventario(request.getParameter("filterProveedor"));

	OCDet.setDescTipoCompromiso(request.getParameter("desc_tipo_compromiso"));
	OCDet.setDescCodProveedor(request.getParameter("desc_cod_proveedor"));
	OCDet.setRuc(request.getParameter("ruc"));
	OCDet.setDescCodAlmacen(request.getParameter("desc_codigo_almacen"));
	OCDet.setRequiAnio(request.getParameter("anio_requi"));
	OCDet.setRequiNo(request.getParameter("no_requi"));

	OCDet.setSubTotal(request.getParameter("subtotal1"));
	OCDet.setDescuento(request.getParameter("descuento"));
	OCDet.setSubTotal2(request.getParameter("subtotal2"));
	OCDet.setItbm(request.getParameter("itbm"));
	OCDet.setMontoTotal(request.getParameter("total"));
	OCDet.setStatus("T");
	OCDet.setDiaLimite(request.getParameter("diaLimite"));


	OCDet.setFechaEntProv(request.getParameter("fechaEntProv"));
	OCDet.setFechaEntVence(request.getParameter("fechaEntVence"));


	//OCDet.setTieneDesc(request.getParameter("tieneDesc"));
	OCDet.setPorcentaje(request.getParameter("porcentaje"));
	OCDet.setTipodescuento(request.getParameter("tipodescuento"));
	if (new Double(OCDet.getPorcentaje()).doubleValue() > 0) OCDet.setTieneDesc("S");
	else OCDet.setTieneDesc("N");

//	System.out.println("OCDet.getUnidadAdmin()...="+OCDet.getUnidadAdmin());

	/*
	OCDet.set(request.getParameter(""));
	*/

	OCDet.getOCDetails().clear();
	ocArt.clear();
	ocArtKey.clear();
	String itemRemoved = "";
	for(int i=0;i<keySize;i++){

		OrdenCompraDetail oc = new OrdenCompraDetail();
		oc.setCodFlia(request.getParameter("cod_flia"+i));
		oc.setCodClase(request.getParameter("cod_clase"+i));
		oc.setSubclaseId(request.getParameter("subclase_id"+i));
		oc.setCodArticulo(request.getParameter("cod_articulo"+i));
		oc.setArticulo(request.getParameter("articulo"+i));
		oc.setEspecificacion(request.getParameter("especificacion"+i));
		oc.setUnidad(request.getParameter("unidad"+i));
		oc.setCantidad(request.getParameter("cantidad"+i));
		oc.setMonto(request.getParameter("costo"+i));
		oc.setTotal(request.getParameter("total"+i));
		oc.setItbm(request.getParameter("itbm"+i));
		
		if(request.getParameter("estadoRenglon"+i)!= null&&!request.getParameter("estadoRenglon"+i).equals(""))oc.setEstadoRenglon(request.getParameter("estadoRenglon"+i));
		else oc.setEstadoRenglon("P");
		
		if(request.getParameter("cantidad_acumulada"+i)!= null && !request.getParameter("cantidad_acumulada"+i).equals(""))oc.setCantidadAcumulada(request.getParameter("cantidad_acumulada"+i));
		else oc.setCantidadAcumulada("0");
		if(request.getParameter("entregado"+i)!= null&&!request.getParameter("entregado"+i).equals("")) oc.setEntregado(request.getParameter("entregado"+i));
		else oc.setEntregado("0");		
		if(request.getParameter("entregado_promo"+i)!= null&&!request.getParameter("entregado_promo"+i).equals(""))oc.setEntregadoPromo(request.getParameter("entregado_promo"+i));
		else oc.setEntregadoPromo("0");
		if(request.getParameter("unidadEmpaque"+i)!= null && !request.getParameter("unidadEmpaque"+i).equals("")) oc.setUnidadEmpaque(request.getParameter("unidadEmpaque"+i));
		if(request.getParameter("cantEmp"+i)!= null && !request.getParameter("cantEmp"+i).equals("")) oc.setCantEmpaque(request.getParameter("cantEmp"+i));
		if(request.getParameter("cantPorEmpaque"+i)!= null && !request.getParameter("cantPorEmpaque"+i).equals("")) oc.setCantPorEmpaque(request.getParameter("cantPorEmpaque"+i));

		oc.setCantPromoEmp(request.getParameter("cantPromoEmp"+i));
		oc.setCantPromo(request.getParameter("cantPromo"+i));
		oc.setDescuento(request.getParameter("descuento"+i));
		oc.setTipoDescuento(request.getParameter("tipoDescuento"+i));
		oc.setImpuesto(request.getParameter("impuesto"+i));
		oc.setAction(request.getParameter("action"+i));

		//oc.set(request.getParameter(""+i));
		//oc.setRenglon(""+(i+1));

		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
			itemRemoved = key;
			artDel = oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getSubclaseId()+"-"+oc.getCodArticulo();
			if (oc.getAction().equalsIgnoreCase("I")) oc.setAction("X");//if it is not in DB then remove it
			else oc.setAction("D");
		}
		System.out.println("oc.getAction()..........................................."+oc.getAction());
		if (!oc.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				ocArt.put(key, oc);
				if (!oc.getAction().equalsIgnoreCase("D")) ocArtKey.put(oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getSubclaseId()+"-"+oc.getCodArticulo(), key);
				OCDet.getOCDetails().add(oc);
				System.out.println("adding...= "+key);
			}
			catch(Exception ex)
			{
				System.err.println(ex.getMessage());
			}
		}
	}

	if(!artDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../compras/reg_orden_compra_parcial_det.jsp?mode="+mode+"&id="+id+"&change=1&type=2");
		return;
	}
	if(request.getParameter("baction")!=null && (request.getParameter("baction").equalsIgnoreCase("Art. Solo Proveedor") || request.getParameter("baction").equalsIgnoreCase("Art. Todos") ) ){
		response.sendRedirect("../compras/reg_orden_compra_parcial_det.jsp?mode="+mode+"&id="+id+"&change=1&type=1&filterProveedor="+request.getParameter("filterProveedor"));
		return;
	}
	if(request.getParameter("baction")!=null && request.getParameter("baction").equalsIgnoreCase("Articulos de Solicitud")){
		response.sendRedirect("../compras/reg_orden_compra_parcial_det.jsp?mode="+mode+"&id="+id+"&change=1&type=3");
		return;
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode =="+mode+" fg="+fg); 
	if (mode.equalsIgnoreCase("add")){
		OCMgr.add(OCDet);
		orden_compra_no  = OCMgr.getPkColValue("orden_compra_no");
	} else {
		if(fg.equals("EOC")) OCDet.setStatus("A");
		OCMgr.update(OCDet);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (OCMgr.getErrCode().equals("1")){
%>
		parent.document.ordencompra.errCode.value = <%=OCMgr.getErrCode()%>;
		parent.document.ordencompra.errMsg.value = '<%=OCMgr.getErrMsg()%>';
		parent.document.ordencompra.orden_compra_no.value = '<%=orden_compra_no%>';
		parent.document.ordencompra.submit();
<%
} else throw new Exception(OCMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
