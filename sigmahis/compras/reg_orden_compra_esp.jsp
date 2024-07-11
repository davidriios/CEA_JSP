<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.compras.OrdenCompra"%>
<%@ page import="issi.compras.OrdenCompraDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
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

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view") || mode.equalsIgnoreCase("delivery")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (change==null){
		OCDet = new OrdenCompra();
		session.setAttribute("OCDet",OCDet);
		ocArt.clear();
		ocArtKey.clear();
		OCDet.setAnio(anio);

		sql = "select tipo_com, descripcion from tbl_com_tipo_compromiso where tipo_com = 2";
		cdo2 = SQLMgr.getData(sql);
		if (cdo2 == null) throw new Exception("Tipo Compromiso no definido!");
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
			sql = "SELECT a.anio, a.tipo_compromiso tipoCompromiso, a.num_doc numDoc, a.compania, TO_CHAR(a.fecha_documento,'dd/mm/yyyy') fechaDocto, to_char(a.fecha_entrega_proveedor,'dd/mm/yyyy') as fechaEntProv, a.cod_proveedor codProveedor, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaEntVence, a.status, a.sub_total subTotal, a.itbm, a.monto_total montoTotal, a.ubic_actual ubicActual, a.tipo_pago tipoPago, a.cod_almacen codAlmacen, a.descuento, a.porcentaje, a.explicacion, a.activa, nvl(a.requi_numero,0) requiNo, nvl(a.requi_anio,0) requiAnio, b.nombre_proveedor descCodProveedor, b.ruc, c.descripcion descCodAlmacen, d.descripcion descTipoCompromiso from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d where a.tipo_compromiso = 2 and a.compania = "+session.getAttribute("_companyId")+" and a.anio = "+anio+" and a.num_doc="+id+" and a.cod_proveedor = b.cod_provedor and a.compania = c.compania AND a.cod_almacen = c.codigo_almacen and a.tipo_compromiso = d.tipo_com";

			System.out.println("sql....="+sql);
			OCDet = (OrdenCompra) sbb.getSingleRowBean(ConMgr.getConnection(), sql, OrdenCompra.class);

			sql = "SELECT a.*, b.* FROM (SELECT a.cod_flia||'-'||a.cod_clase||'-'||a.cod_articulo art_key, a.compania, a.cod_flia codFlia, a.cod_clase codClase, a.cod_articulo codArticulo, a.descripcion articulo, a.itbm, a.cod_medida unidad, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, c.descripcion descArtClase FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c WHERE (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND a.compania = "+session.getAttribute("_companyId")+") a, (SELECT a.cod_familia||'-'||a.cod_clase||'-'||a.cod_articulo art_key, NVL(anio_requi,0) aniorequi, NVL(requi_num,0) requinum, a.cantidad, monto_articulo monto, round(cantidad*monto_articulo,6) total, entregado, a.estado_renglon estadorenglon, especificacion FROM TBL_COM_DETALLE_COMPROMISO a WHERE a.compania = "+session.getAttribute("_companyId")+" AND a.cf_anio = "+anio+" AND a.cf_num_doc = "+id+") b WHERE a.art_key = b.art_key order by a.codflia, a.codclase, a.codarticulo";

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
					ocArtKey.put(oc.getCodFlia()+"-"+oc.getCodClase()+"-"+oc.getCodArticulo(), key);
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
document.title = 'Ordenes de Compras - '+document.title;

function doAction(){
	<%
	//if(type!=null && type.equals("1")){
	%>
	//abrir_ventana1('../compras/sel_articles_orden_compra.jsp?mode=<%//=mode%>&id=<%//=id%>&anio=<%//=OCDet.getAnio()%>');
	<%
	//} else if(type!=null && type.equals("3")){
	%>
	//abrir_ventana1('../compras/sel_articles_requisicion.jsp?mode=<%//=mode%>&id=<%//=id%>&anio=<%//=OCDet.getAnio()%>');
	<%
	//}
	%>
	calValues();
}

function buscaProv(){
	abrir_ventana1('../compras/sel_proveedor.jsp');
}

function buscaCA(flag)
{
	var codAlmacen = document.ordencompra.codigo_almacen.value;
	abrir_ventana1('../compras/sel_almacen.jsp?tr=x&flag=1&codAlmacen='+codAlmacen);
}

function calValues()
{
	var porc = document.ordencompra.porcentaje.value;
	var subtotal =  document.ordencompra.subtotal1.value;
	if(isNaN(porc)) porc = 0.00;
	var porc2 = porc;
	porc = porc/100;
	if(isNaN(subtotal)) subtotal = 0.00;
	document.ordencompra.porcentaje.value = (porc2*1).toFixed(6);
	document.ordencompra.subtotal1.value = (subtotal*1).toFixed(6);
	document.ordencompra.descuento.value = (subtotal*porc).toFixed(6);
	document.ordencompra.total.value = (subtotal-(subtotal*porc)).toFixed(6);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - CREAR/MODIFICAR ORDEN DE COMPRA ESPECIAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<!-- ======================   F O R M   S T A R T   H E R E   ================== -->
				<%
				fb = new FormBean("ordencompra","","post");
				%>
								<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("clearHT","")%>
				<%=fb.hidden("action","")%>
				<%=fb.hidden("fg",fg)%>

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
								<td width="10%" align="right"><cellbytelabel>N&uacute;mero</cellbytelabel>:</td>
								<td colspan="2">
								<%=fb.intBox("anio",OCDet.getAnio(),true,false,true,4,null,null,"")%>
								<%=fb.intBox("num_doc",OCDet.getNumDoc(),true,false,true,4,null,null,"")%>
				</td>
								<td align="right" colspan="2"><cellbytelabel>Forma de Compra</cellbytelabel></td>
								<td colspan="3">
								<%=fb.intBox("tipo_compromiso",OCDet.getTipoCompromiso(),true,false,true,4,null,null,"")%>
								<%=fb.textBox("desc_tipo_compromiso",OCDet.getDescTipoCompromiso(),true,false,true,35,null,null,"")%>
				</td>
							</tr>

							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>Forma de Pago</cellbytelabel></td>
							</tr>

							<tr class="TextRow01" >
								<td width="10%" align="right">Tipo de Pago</td>
								<td width="12%">
<%
if (mode.equalsIgnoreCase("delivery"))
{
%>
								<%=fb.hidden("tipo_pago",OCDet.getTipoPago())%>
								<%=fb.select("displayTipoPago","CRE=Crédito,CON=Contado",OCDet.getTipoPago(),false,viewMode,0)%>
<%
}
else
{
%>
								<%=fb.select("tipo_pago","CRE=Crédito,CON=Contado",OCDet.getTipoPago(),false,viewMode,0)%>
<%
}
%>
								</td>
								<td colspan="2">&nbsp;</td>
								<td width="11%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
								<td width="12%">
								<%=fb.textBox("fecha_documento",(OCDet.getFechaDocto()==null || OCDet.getFechaDocto().equals(""))?fecha:OCDet.getFechaDocto(),true,false,true,10,null,null,"")%>
				</td>
								<td width="42%" colspan="2">&nbsp;</td>
							</tr>

							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>Proveedor</cellbytelabel></td>
							</tr>

							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>Proveedor</cellbytelabel></td>
								<td colspan="4">
								<%=fb.intBox("cod_proveedor",OCDet.getCodProveedor(),true,false,true,5,null,null,"")%>
								<%=fb.textBox("desc_cod_proveedor",OCDet.getDescCodProveedor(),true,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,viewMode,"","","onClick=\"javascript:buscaProv()\"")%>
								</td>
				<td colspan="3">
<%
if (mode.equalsIgnoreCase("delivery"))
{
%>
					<cellbytelabel>Fecha de Entrega al Proveedor</cellbytelabel>
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fecha_ent_prov"/>
					<jsp:param name="valueOfTBox1" value="<%=OCDet.getFechaEntProv()%>"/>
					</jsp:include>
<%
}
else if (viewMode)
{
%>
					<cellbytelabel>Fecha de Entrega al Proveedor</cellbytelabel>
					<%=fb.textBox("fecha_ent_prov",OCDet.getFechaEntProv(),true,viewMode,true,10,null,null,"")%>
<%
}
%>
				</td>

							</tr>

							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>R.U.C</cellbytelabel>.:</td>
								<td colspan="4">
								<%=fb.textBox("ruc",OCDet.getRuc(),true,false,true,40,null,null,"")%>
								</td>

				<td colspan="3">
<%
if (mode.equalsIgnoreCase("delivery"))
{
%>
<cellbytelabel>Fecha de Entrega de Bienes (Vencimiento)</cellbytelabel>
<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="clearOption" value="true"/>
					<jsp:param name="nameOfTBox1" value="fecha_ent_vence"/>
					<jsp:param name="valueOfTBox1" value="<%=OCDet.getFechaEntVence()%>"/>
					</jsp:include>
<%
}
else if (viewMode)
{
%>
					<cellbytelabel>Fecha de Entrega de Bienes (Vencimiento)</cellbytelabel>
					<%=fb.textBox("fecha_ent_vence",OCDet.getFechaEntVence(),true,viewMode,true,10,null,null,"")%>
<%
}
%>
								</td>
							</tr>

							<tr class="TextPanel">
								<td colspan="8"><cellbytelabel>Lugar de Entrega</cellbytelabel></td>
							</tr>

							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>C&oacute;digo</cellbytelabel>:</td>
								<td colspan="7">
								<%=fb.intBox("codigo_almacen",OCDet.getCodAlmacen(),true,false,true,5,null,null,"")%>
								<%=fb.textBox("desc_codigo_almacen",OCDet.getDescCodAlmacen(),true,false,true,40,null,null,"")%>
								<%=fb.button("buscar","Buscar",false,viewMode,"","","onClick=\"javascript:buscaCA(1)\"")%>
								</td>
							</tr>

							<tr class="TextPanel">
								<td colspan="4"><cellbytelabel>Comentarios</cellbytelabel></td>
								<td colspan="4">&nbsp;</td>
							</tr>

							<tr class="TextRow01" >
								<td colspan="4" rowspan="4">&nbsp;
								<%=fb.textarea("explicacion",OCDet.getExplicacion(),false,false,viewMode,70,10)%>
								</td>
								<td colspan="2"><cellbytelabel>Total de la Orden</cellbytelabel></td>
								<td colspan="2"><%=fb.decBox("subtotal1",OCDet.getSubTotal(),true,false,viewMode,10,null,null,"onChange=\"javascript:calValues()\"")%></td>
							</tr>
							<tr class="TextRow01" >
								<td colspan="2"><cellbytelabel>Porcentaje</cellbytelabel></td>
								<td colspan="2"><%=fb.decBox("porcentaje",OCDet.getPorcentaje(),true,false,viewMode,10,null,null,"onChange=\"javascript:calValues()\"")%></td>
							</tr>
							<tr class="TextRow01" >
								<td colspan="2"><cellbytelabel>Descuento</cellbytelabel></td>
								<td colspan="2"><%=fb.decBox("descuento",OCDet.getDescuento(),true,false,viewMode,10,null,null,"")%></td>
							</tr>
							<tr class="TextRow01" >
								<td colspan="2"><cellbytelabel>Gran Total de la Orden</cellbytelabel></td>
								<td colspan="2"><%=fb.decBox("total",OCDet.getMontoTotal(),true,false,viewMode,10,null,null,"")%></td>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
							<tr class="TextRow02">
			<td colspan="10" align="right">
			<%=fb.submit("save","Guardar",true,(!mode.equalsIgnoreCase("delivery") && viewMode),"","","onClick=\"javascript:document.ordencompra.action.value = this.value;\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="6">&nbsp;</td>
				</tr>
				<%
				//fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
				//fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
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
	//int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	//if(clearHT.equals("S")) keySize = 0;
	System.out.println("clearHT...="+clearHT);
	String artDel = "";
	OCDet.setCompania(companyId);
	OCDet.setAnio(request.getParameter("anio"));
	OCDet.setNumDoc(request.getParameter("num_doc"));
	OCDet.setTipoCompromiso(request.getParameter("tipo_compromiso"));
	OCDet.setTipoPago(request.getParameter("tipo_pago"));
	OCDet.setCodProveedor(request.getParameter("cod_proveedor"));
	OCDet.setCodAlmacen(request.getParameter("codigo_almacen"));
	OCDet.setExplicacion(request.getParameter("explicacion"));
	OCDet.setFechaEntProv(request.getParameter("fecha_ent_prov"));
	OCDet.setFechaEntVence(request.getParameter("fecha_ent_vence"));

	OCDet.setUsuario((String) session.getAttribute("_userName"));
	OCDet.setUsuarioMod((String) session.getAttribute("_userName"));

	OCDet.setDescTipoCompromiso(request.getParameter("desc_tipo_compromiso"));
	OCDet.setDescCodProveedor(request.getParameter("desc_cod_proveedor"));
	OCDet.setRuc(request.getParameter("ruc"));
	OCDet.setDescCodAlmacen(request.getParameter("desc_codigo_almacen"));
	//OCDet.setRequiAnio(request.getParameter("anio_requi"));
	//OCDet.setRequiNo(request.getParameter("no_requi"));

	OCDet.setSubTotal(request.getParameter("subtotal1"));
	OCDet.setPorcentaje(request.getParameter("porcentaje"));
	OCDet.setDescuento(request.getParameter("descuento"));
	//OCDet.setSubTotal2(request.getParameter("subtotal2"));
	//OCDet.setItbm(request.getParameter("itbm"));
	OCDet.setMontoTotal(request.getParameter("total"));
	OCDet.setStatus("T");



	OCDet.getOCDetails().clear();
	ocArt.clear();
	ocArtKey.clear();

	if(!artDel.equals("") || clearHT.equals("S")){
		response.sendRedirect("../compras/reg_orden_compra_esp.jsp?mode="+mode+"&id="+id+"&anio="+anio+"&change=1&type=2");
		return;
	}


	if (mode.equalsIgnoreCase("add")){
		OCMgr.addEspecial(OCDet);
	} else {
		OCMgr.updateEspecial(OCDet);
	}
	session.removeAttribute("OCDet");
	session.removeAttribute("ocArt");
	session.removeAttribute("ocArtKey");
%>
<html>
<head>
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
		window.opener.location = '<%=request.getContextPath()%>/compras/list_orden_compra_entrega.jsp?tipo=2';
	<%}else if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/compras/list_orden_compra_especial.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/compras/list_orden_compra_especial.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/compras/list_orden_compra_especial.jsp';
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