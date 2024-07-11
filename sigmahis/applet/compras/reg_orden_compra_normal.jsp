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
String sql = "", key = "";
boolean viewMode = false;
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
String anio = request.getParameter("anio");
if(anio == null) anio=fecha.substring(6, 10);
String type = request.getParameter("type");
String fg = request.getParameter("fg");
int lineNo = 0;

if (fg == null) fg = "view";  // Eso es solo para evitar null  y receibir valor que no debe equals  "EOC".

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change==null){
		OCDet = new OrdenCompra();
		session.setAttribute("OCDet",OCDet);
		ocArt.clear();
		ocArtKey.clear();
		OCDet.setAnio(anio);
		sql = "select tipo_com, descripcion from tbl_com_tipo_compromiso where tipo_com = 1";
		cdo2 = SQLMgr.getData(sql);
		OCDet.setTipoCompromiso(cdo2.getColValue("tipo_com"));
		OCDet.setDescTipoCompromiso(cdo2.getColValue("descripcion"));
		}

	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		OCDet.setNumDoc("0");
	}
	else
	{
		if (id == null) throw new Exception("Requisición no es válida. Por favor intente nuevamente!");
				if (change==null){
			sql = "SELECT a.tiene_desc  tieneDesc,a.anio, a.tipo_compromiso tipoCompromiso, a.num_doc numDoc, a.compania, TO_CHAR(a.fecha_documento,'dd/mm/yyyy') fechaDocto, a.cod_proveedor codProveedor, a.status, a.sub_total subTotal, a.itbm, a.monto_total montoTotal, a.ubic_actual ubicActual, a.tipo_pago tipoPago, a.cod_almacen codAlmacen, a.descuento, a.porcentaje, a.explicacion, a.activa, nvl(a.requi_numero,0) requiNo, nvl(a.requi_anio,0) requiAnio,nvl(to_char(a.fecha_entrega_proveedor,'dd/mm/yyyy'),' ') as fechaEntProv, nvl(to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy'),' ') as fechaEntVence, b.nombre_proveedor descCodProveedor, b.ruc, c.descripcion descCodAlmacen,tc.descripcion descTipoCompromiso  FROM TBL_COM_COMP_FORMALES a, TBL_COM_PROVEEDOR b, TBL_INV_ALMACEN c,tbl_com_tipo_compromiso tc WHERE a.tipo_compromiso = 1 and a.compania = "+session.getAttribute("_companyId")+" and a.anio = "+anio+" and a.num_doc="+id+" and a.cod_proveedor = b.cod_provedor AND a.compania = c.compania(+) AND a.cod_almacen = c.codigo_almacen(+) and tc.tipo_com = a.tipo_compromiso";

			System.out.println("sql....="+sql);
			OCDet = (OrdenCompra) sbb.getSingleRowBean(ConMgr.getConnection(), sql, OrdenCompra.class);

			sql = "SELECT a.*, b.* FROM (SELECT a.cod_flia||'-'||a.cod_clase||'-'||a.cod_subclase||'-'||a.cod_articulo art_key, a.compania, a.cod_flia codFlia, a.cod_clase codClase,a.cod_subclase  subclaseId, a.cod_articulo codArticulo, a.descripcion articulo, a.itbm, a.cod_medida unidad, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, c.descripcion descArtClase FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c WHERE (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND a.compania = "+session.getAttribute("_companyId")+") a, (SELECT a.cod_familia||'-'||a.cod_clase||'-'||a.subclase_id||'-'||a.cod_articulo art_key, NVL(anio_requi,0) aniorequi, NVL(requi_num,0) requinum, a.cantidad, monto_articulo monto, round(cantidad*monto_articulo,6) total, entregado, nvl(a.estado_renglon,' ') estadorenglon, especificacion FROM TBL_COM_DETALLE_COMPROMISO a WHERE a.cf_tipo_com = 1 and a.compania = "+session.getAttribute("_companyId")+" AND a.cf_anio = "+anio+" AND a.cf_num_doc = "+id+") b WHERE a.art_key = b.art_key order by a.codflia, a.codclase, a.subclaseId, a.codarticulo";

			System.out.println("sqlDetails....="+sql);

			OCDet.setOCDetails(sbb.getBeanList(ConMgr.getConnection(), sql, OrdenCompraDetail.class));
			for(int i=0;i<OCDet.getOCDetails().size();i++){
				OrdenCompraDetail oc = (OrdenCompraDetail) OCDet.getOCDetails().get(i);
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
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Administración - '+document.title;



function doAction(){
var filterProveedor = eval('document.ordencompra.filterProveedor').value;
//alert(filterProveedor)
var proveedor =eval('document.ordencompra.cod_proveedor').value;
	<%
	if(type!=null && type.equals("1")){
		%>
	abrir_ventana1('../compras/sel_articles_orden_compra.jsp?mode=<%=mode%>&id=<%=id%>&anio=<%=OCDet.getAnio()%>&filterProveedor='+filterProveedor+'&proveedor='+proveedor+' ');
	<%
	} else if(type!=null && type.equals("3")){
	%>
	//alert('<%=type%>');
	abrir_ventana1('../compras/sel_articles_requisicion.jsp?mode=<%=mode%>&id=<%=id%>&anio=<%=OCDet.getAnio()%>&filterProveedor='+filterProveedor+'&proveedor='+proveedor+' ');
	<%
	}
	%>
	calValues();
}

function buscaProv(){
	abrir_ventana2('../compras/sel_proveedor.jsp');
}

function buscaCA(flag){
	var codAlmacen = document.ordencompra.codigo_almacen.value;
	abrir_ventana2('../compras/sel_almacen.jsp?tr=x&flag=1&codAlmacen='+codAlmacen);
}

function buscaAN(){
	abrir_ventana2('../compras/sel_anio_no_requi.jsp');
}

function buscaCS(){
	abrir_ventana2('../compras/sel_compania.jsp');
}

function addRequi(){
	document.ordencompra.submit();
}

function chkCeroValues(){
	var size = document.ordencompra.keySize.value;
	var x = 0;
	if(document.ordencompra.action.value=="Guardar"){
		for(i=0;i<size;i++){
			if(eval('document.ordencompra.cantidad'+i).value<=0){
				alert('La cantidad no puede ser menor o igual a 0!');
				eval('document.ordencompra.cantidad'+i).focus();
				x++;
				break;
			} else {
			}
		}
	}
	if(x==0){
		calValues();
		return true;
	}	else return false;
}

function changeDesc(val){
	if(val=='S'){
		calValues();
	} else {
		document.ordencompra.porcentaje.value = 0.00;
		calValues();
	}

}


function calValues(){
	var size = document.ordencompra.keySize.value;
	var porc = document.ordencompra.porcentaje.value;
	if(isNaN(porc)) porc = 0;
	var desc = 0.00, acum_desc = 0.00, monto = 0.00, dif = 0.00, total_itbm = 0.00, sub_total1 = 0.00, sub_total2 = 0.00;
	var cantidad = 0;
	for(i=0;i<size;i++){
		cantidad		= eval('document.ordencompra.cantidad'+i).value;
		monto 			= eval('document.ordencompra.costo'+i).value;
		itbm	 			= eval('document.ordencompra.itbm'+i).value;
		sub_total1	+= cantidad*monto;
		desc  			= ((porc/100) * (cantidad*monto));
		dif 				= ((cantidad*monto) - desc);
		acum_desc 	+= desc;
		if(itbm=='S') total_itbm += dif * 0.05;
	}

	document.ordencompra.subtotal1.value = (sub_total1).toFixed(6);
	document.ordencompra.descuento.value = (acum_desc).toFixed(6);
	document.ordencompra.subtotal2.value = (sub_total1-acum_desc).toFixed(6);
	document.ordencompra.itbm.value = (total_itbm).toFixed(6);
	document.ordencompra.total.value = (sub_total1-acum_desc+total_itbm).toFixed(6);
}

function calMonto(j){
	cantidad		= eval('document.ordencompra.cantidad'+j).value;
	monto 			= eval('document.ordencompra.costo'+j).value;
	if(isNaN(cantidad) || isNaN(monto)) alert('Introduzca valores numéricos!');
	else {
		eval('document.ordencompra.total'+j).value = (cantidad * monto).toFixed(6);
		calValues();
	}
}






function chkCeroRegisters(){
	var size = document.ordencompra.keySize.value;
	if(size>0) return true;
	else{
		if(document.ordencompra.action.value!='Guardar') return true;
		else {
			alert('Seleccione al menos un (1) articulo!');
			document.ordencompra.action.value = '';
			return false;
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - CREAR/MODIFICAR ORDEN DE COMPRA NORMAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<%
				fb = new FormBean("ordencompra","","post");
				%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("clearHT","")%>
				<%=fb.hidden("action","")%>
				<tr>
					<td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr>
								<td colspan="8">&nbsp;</td>
							</tr>
							<tr class="TextRow02">
								<td colspan="8" align="right">&nbsp;</td>
							</tr>
							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>Compra</cellbytelabel></td>
							</tr>
							<tr class="TextRow01" >
								<td width="13%" align="right"><cellbytelabel>Tipo de Compra</cellbytelabel></td>
								<td colspan="3">
								<%=fb.intBox("tipo_compromiso",OCDet.getTipoCompromiso(),true,false,true,4,"text10",null,"")%>
								<%=fb.textBox("desc_tipo_compromiso",OCDet.getDescTipoCompromiso(),true,false,true,35,"text10",null,"")%>
								</td>
								<td width="13%" align="left"><cellbytelabel>N&uacute;mero</cellbytelabel>:</td>
								<td width="18%">
								<%=fb.intBox("anio",OCDet.getAnio(),true,false,true,4,"text10",null,"")%>
								<%=fb.intBox("num_doc",OCDet.getNumDoc(),true,false,true,4,"text10",null,"")%>
								</td>
								<td width="22%" colspan="2"><cellbytelabel>Estaus</cellbytelabel>
								<%=fb.select("estatus","A=APROBADO,N=ANULADO,P=PENDIENTE,R=PROCESADO,T=TRAMITE",OCDet.getStatus(),false,true,0,"text10",null, null)%>
								</td>
							</tr>
							<tr class="TextPanel">
								<td colspan="8">&nbsp;</td>
							</tr>
							<tr class="TextRow01" >
								<td width="13%" align="right"><cellbytelabel>Tipo de Pago</cellbytelabel></td>
								<td width="12%">
								<%=fb.select("tipo_pago","CRE=Crédito,CON=Contado",OCDet.getTipoPago(),false,viewMode,0,"text10",null, null)%>
								</td>
								<td colspan="2"> <cellbytelabel>Art&iacute;culo Proveedor</cellbytelabel>
								<%=fb.select("filterProveedor", "N=TODOS,Y=SOLO PROVEEDOR",OCDet.getNoInventario(),false,viewMode,0,"text10",null, null)%>
								</td>
								<!--td colspan="2"><%//=fb.checkbox("no_inventario",OCDet.getNoInventario(),false,viewMode)%>&nbsp;No Inventario</td>-->
								<td width="13%" align="left"><cellbytelabel>Fecha</cellbytelabel></td>
								<td width="18%">
								<%=fb.textBox("fecha_documento",(OCDet.getFechaDocto()==null || OCDet.getFechaDocto().equals(""))?fecha:OCDet.getFechaDocto(),true,false,true,10,"text10",null,"")%>
								</td>
								<td colspan="2">&nbsp;</td>
							</tr>
							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>Proveedor</cellbytelabel></td>
							</tr>
							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>Proveedor</cellbytelabel></td>
								<td colspan="3">
								<%=fb.intBox("cod_proveedor",OCDet.getCodProveedor(),true,false,true,5,"text10",null,"")%>
								<%=fb.textBox("desc_cod_proveedor",OCDet.getDescCodProveedor(),true,false,true,40,"text10",null,"")%>
								<%=fb.button("buscar","Buscar",false,viewMode,"","","onClick=\"javascript:buscaProv()\"")%>
								</td>
								<td colspan="4"> <cellbytelabel>Fecha de Entrega al Proveedor</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="fechaEntProv"/>
								<jsp:param name="valueOfTBox1" value="<%=OCDet.getFechaEntProv()%>"/>
								</jsp:include>
								</td>
							</tr>
							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>R.U.C</cellbytelabel>.:</td>
								<td colspan="3"><%=fb.textBox("ruc",OCDet.getRuc(),true,false,true,40,null,null,"")%></td>
								<td colspan="4"> <cellbytelabel>Fecha de Entrega de Bienes (Vencimiento)</cellbytelabel>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="fechaEntVence"/>
								<jsp:param name="valueOfTBox1" value="<%=OCDet.getFechaEntVence()%>"/>
								</jsp:include>
								</td>
							</tr>
							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>Almac&eacute;n De Entrega</cellbytelabel> </td>
							</tr>
							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>C&oacute;digo</cellbytelabel>:</td>
								<td colspan="7"><%=fb.select(ConMgr.getConnection(),"select codigo_almacen, descripcion from tbl_inv_almacen  order by codigo_almacen asc","codigo_almacen", OCDet.getCodAlmacen(),false,viewMode,0,null,null,null)%>
								<%//=fb.intBox("codigo_almacen",OCDet.getCodAlmacen(),true,false,true,5,"text10",null,"")%>
								<%//=fb.textBox("desc_codigo_almacen",OCDet.getDescCodAlmacen(),true,false,true,40,"text10",null,"")%>
								<%//=fb.button("buscar","Buscar",false,viewMode,"","","onClick=\"javascript:buscaCA(1)\"")%>
								</td>
							</tr>
							<tr class="TextPanel">
								<td colspan="4"><cellbytelabel>Comentarios</cellbytelabel></td>
								<td colspan="4"><cellbytelabel>Solicitud de Compra</cellbytelabel></td>
							</tr>
							<tr class="TextRow01" >
								<td colspan="4" rowspan="2">&nbsp;
								<%=fb.textarea("explicacion",OCDet.getExplicacion(),false,false,viewMode,40,4)%>
								</td>
								<td colspan="2"><cellbytelabel>N&uacute;mero</cellbytelabel>:</td>
								<td colspan="2">
								<%=fb.intBox("anio_requi",OCDet.getRequiAnio(),false,false,true,4,"text10",null,"")%>
								<%=fb.intBox("no_requi",OCDet.getRequiNo(),false,false,true,4,"text10",null,"")%>
								<%=fb.button("buscar","Buscar",false,viewMode,"","","onClick=\"javascript:buscaAN()\"")%>
								<%=fb.submit("addArticlesR","Articulos de Requi.",false,viewMode)%>
								</td>
							</tr>
							<tr class="TextRow01" >
								<td colspan="2">&nbsp;<cellbytelabel>Esta Orden tiene descuento</cellbytelabel>?</td>
								<td colspan="2">
								<%=fb.select("tieneDesc","N=No,S=Sí",OCDet.getTieneDesc(), false, viewMode, 0, "text10", "","onChange=\"javascript:changeDesc(this.value)\"")%>
								</td>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>Detalle de la Solicitud</cellbytelabel></td>
								<td colspan="3"><%=fb.submit("addArticles","Agregar Articulos",false,viewMode)%></td>
							</tr>
							<tr class="TextHeader">
								<td width="20%" align="center" colspan="4"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
								<td width="29%" align="center"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
								<td width="17%" align="center"><cellbytelabel>Detalle</cellbytelabel></td>
								<td width="5%" align="center"><cellbytelabel>Und</cellbytelabel>.</td>
								<td width="6%" align="center"><cellbytelabel>Cant</cellbytelabel>.</td>
								<td width="10%" align="center"><cellbytelabel>Costo</cellbytelabel></td>
								<td width="10%" align="center"><cellbytelabel>Total</cellbytelabel></td>
								<td width="3%" align="center">&nbsp;</td>
							</tr>
							<%
					key = "";
						if (ocArt.size() != 0) al = CmnMgr.reverseRecords(ocArt);
							for (int i=0; i<ocArt.size(); i++)
							{
								key = al.get(i).toString();
								System.out.println("key...="+key);
								OrdenCompraDetail oc = (OrdenCompraDetail) ocArt.get(key);

								String color = "TextRow02";
								if (i % 2 == 0) color = "TextRow01";
							%>
							<%=fb.hidden("itbm"+i,oc.getItbm())%>
							<%//=fb.hidden("precio"+i,oc.getPrecio())%>
							<%//=fb.hidden("ultimo_precio"+i,oc.getUltimoPrecio())%>
							<%//=fb.hidden("descuento"+i,oc.getDescuento())%>
							<%//=fb.hidden("porcentaje"+i,oc.getPorcentaje())%>
							<%=fb.hidden("cod_flia"+i,oc.getCodFlia())%> <%=fb.hidden("cod_clase"+i,oc.getCodClase())%> <%=fb.hidden("subclase_id"+i,oc.getSubclaseId())%> <%=fb.hidden("cod_articulo"+i,oc.getCodArticulo())%> <%=fb.hidden("articulo"+i,oc.getArticulo())%>
							<tr class="TextRow01" >
								<td><%=oc.getCodFlia()%></td>
								<td><%=oc.getCodClase()%></td>
								<td><%=oc.getSubclaseId()%></td>
								<td><%=oc.getCodArticulo()%></td>
								<td><%=oc.getArticulo()%></td>
								<td align="center"><%=fb.textBox("especificacion"+i,oc.getEspecificacion(),false,false,viewMode,22,"text10",null,"")%></td>
								<td align="center"><%=fb.textBox("unidad"+i,oc.getUnidad(),true,false,true,5,"text10",null,"")%></td>
								<td align="center"><%=fb.intBox("cantidad"+i,oc.getCantidad(),true,false,viewMode,6,"text10",null,"onChange=\"javascript:calMonto("+i+")\"")%></td>
								<td align="center"><%=fb.decBox("costo"+i,oc.getMonto(),true,false,viewMode,10,"11,10","text10",null,"onChange=\"javascript:calMonto("+i+")\"")%></td>
								<td><%=fb.decBox("total"+i,oc.getTotal(),true,false,viewMode,10,"text10",null,"")%>
									<%if(mode.trim().equals("view")){%>
									<%=fb.textBox("estado_r"+i,oc.getEstadoRenglon(),false,false,true,1,"text10",null,"")%>
									<%}%>
								</td>
								<td width="3%" align="center"><%=fb.submit("del"+i,"X",false,viewMode)%></td>
							</tr>
							<%
							}
							%>
							<%=fb.hidden("keySize",""+OCDet.getOCDetails().size())%>
							<tr class="TextRow01">
								<td colspan="7" align="right">&nbsp;</td>
								<td colspan="2"><cellbytelabel>Subtotal 1</cellbytelabel></td>
								<td colspan="2"><%=fb.decBox("subtotal1",OCDet.getSubTotal(),true,false,viewMode,10,"text10",null,"")%></td>
							</tr>
							<tr class="TextRow01">
								<td colspan="7" align="right">&nbsp;</td>
								<td colspan="2"><cellbytelabel>Descuento</cellbytelabel>&nbsp;<%=fb.decBox("porcentaje",OCDet.getPorcentaje(),true,false,viewMode,5,null,null,"onChange=\"javascript:calValues()\"")%></td>
								<td colspan="2"><%=fb.decBox("descuento",OCDet.getDescuento(),true,false,viewMode,10,"text10",null,"")%></td>
							</tr>
							<tr class="TextRow01">
								<td colspan="7" align="right">&nbsp;</td>
								<td colspan="2"><cellbytelabel>Subtotal 2</cellbytelabel></td>
								<td colspan="2"><%=fb.decBox("subtotal2",OCDet.getSubTotal2(),true,false,viewMode,10,"text10",null,"")%></td>
							</tr>
							<tr class="TextRow01">
								<td colspan="7" align="right">&nbsp;</td>
								<td colspan="2"><cellbytelabel>I.T.B.M</cellbytelabel>.</td>
								<td colspan="2"><%=fb.decBox("itbm",OCDet.getItbm(),true,false,viewMode,10,"text10",null,"")%></td>
							</tr>
							<tr class="TextRow01">
								<td colspan="7" align="right">&nbsp;</td>
								<td colspan="2"><cellbytelabel>Total</cellbytelabel></td>
								<td colspan="2"><%=fb.decBox("total",OCDet.getMontoTotal(),true,false,viewMode,10,"text10",null,"")%></td>
							</tr>
							<tr class="TextRow02">
								<%
							if (mode.equalsIgnoreCase("view") && fg.equalsIgnoreCase("EOC")){
							%>
								<td colspan="10" align="right"><%=fb.submit("save","Guardar",true,false,"","","onClick=\"javascript:document.ordencompra.action.value = this.value;\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
								<%
							}else {
							%>
								<td colspan="10" align="right"><%=fb.submit("save","Guardar",true,viewMode,"","","onClick=\"javascript:document.ordencompra.action.value = this.value;\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
								<%
								}
								%>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="6">&nbsp;</td>
				</tr>
				<%
				fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
				fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
				%>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
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
	System.out.println("clearHT...="+clearHT);
	String artDel = "";
	OCDet.setCompania(companyId);
	OCDet.setAnio(request.getParameter("anio"));
	OCDet.setNumDoc(request.getParameter("num_doc"));
	OCDet.setFechaDocto(request.getParameter("fecha_documento"));
	OCDet.setTipoCompromiso(request.getParameter("tipo_compromiso"));
	OCDet.setTipoPago(request.getParameter("tipo_pago"));
	OCDet.setCodProveedor(request.getParameter("cod_proveedor"));
	OCDet.setCodAlmacen(request.getParameter("codigo_almacen"));
	OCDet.setExplicacion(request.getParameter("explicacion"));

	OCDet.setNoInventario(request.getParameter("filterProveedor"));
	OCDet.setTieneDesc(request.getParameter("tieneDesc"));



	OCDet.setUsuario((String) session.getAttribute("_userName"));
	OCDet.setUsuarioMod((String) session.getAttribute("_userName"));

	OCDet.setDescTipoCompromiso(request.getParameter("desc_tipo_compromiso"));
	OCDet.setDescCodProveedor(request.getParameter("desc_cod_proveedor"));

	OCDet.setFechaEntProv(request.getParameter("fechaEntProv"));
	OCDet.setFechaEntVence(request.getParameter("fechaEntVence"));


	OCDet.setRuc(request.getParameter("ruc"));
	OCDet.setDescCodAlmacen(request.getParameter("desc_codigo_almacen"));
	OCDet.setRequiAnio(request.getParameter("anio_requi"));
	OCDet.setRequiNo(request.getParameter("no_requi"));

	OCDet.setSubTotal(request.getParameter("subtotal1"));
	OCDet.setPorcentaje(request.getParameter("porcentaje"));
	OCDet.setDescuento(request.getParameter("descuento"));
	OCDet.setSubTotal2(request.getParameter("subtotal2"));
	OCDet.setItbm(request.getParameter("itbm"));
	OCDet.setMontoTotal(request.getParameter("total"));
	OCDet.setStatus("T");


//	System.out.println("OCDet.getUnidadAdmin()...="+OCDet.getUnidadAdmin());

	/*
	OCDet.set(request.getParameter(""));
	*/

	OCDet.getOCDetails().clear();
	ocArt.clear();
	ocArtKey.clear();
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
		oc.setEstadoRenglon("P");
		oc.setEntregado("0");


		//oc.set(request.getParameter(""+i));
		//oc.setRenglon(""+(i+1));

		/*
		oc.set(request.getParameter(""+i));
		*/

		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		if(request.getParameter("del"+i)==null){
			try {
				ocArt.put(key, oc);
				ocArtKey.put(oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getSubclaseId()+"-"+oc.getCodArticulo(), key);
				OCDet.getOCDetails().add(oc);
				System.out.println("adding...= "+key);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item "+key);
			}
		} else {
			artDel = oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getSubclaseId()+"-"+oc.getCodArticulo();
		}
	}

	System.out.println("clearHT="+clearHT);
	System.out.println("addArticles"+request.getParameter("addArticles"));
	System.out.println("addArticlesR"+request.getParameter("addArticlesR"));

	if(!artDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../compras/reg_orden_compra_normal.jsp?mode="+mode+"&id="+id+"&change=1&type=2");
		return;
	}
	if(request.getParameter("addArticles")!=null){
		response.sendRedirect("../compras/reg_orden_compra_normal.jsp?mode="+mode+"&id="+id+"&change=1&type=1");
		return;
	}
	if(request.getParameter("addArticlesR")!=null/* && request.getParameter("anio_requi")!= null && !request.getParameter("anio_requi").equals("")*/){
		response.sendRedirect("../compras/reg_orden_compra_normal.jsp?mode="+mode+"&id="+id+"&change=1&type=3");
		return;
	}


	if (mode.equalsIgnoreCase("add")){
		OCMgr.add(OCDet);
	} else {
		OCMgr.update(OCDet);
	}
	session.removeAttribute("OCDet");
	session.removeAttribute("ocArt");
	session.removeAttribute("ocArtKey");
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
	alert('<%=OCMgr.getErrMsg()%>');
<%
if(fg != null && fg.trim().equals("EOC"))
	{%>
		window.opener.location = '<%=request.getContextPath()%>/compras/list_orden_compra_entrega.jsp?tipo=1';
	<%} else if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/compras/list_orden_compra_normal.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/compras/list_orden_compra_normal.jsp")%>';
<%
	} else {
%>
	window.opener.location = '<%=request.getContextPath()%>/compras/list_orden_compra_normal.jsp';
<%
	}
%>
	window.close();
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
