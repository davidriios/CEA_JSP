<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Ajuste"%>
<%@ page import="issi.inventory.AjusteDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="AjuMgr" scope="page" class="issi.inventory.AjusteMgr"/>
<jsp:useBean id="ajuArt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ajuArtKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="AjuDet" scope="session" class="issi.inventory.Ajuste"/>
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
AjuMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String type = request.getParameter("type");
String id = request.getParameter("id");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");

boolean viewMode = false;

if (mode == null) mode = "add";
if (fp == null) fp = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) ajuArt.clear();
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
function doAction()
{
	<%
	if(type!=null && type.equals("1")){
	%>
	var fg = parent.document.form1.fg.value;
	abrir_ventana1('../inventario/sel_articles_ajuste.jsp?mode=<%=mode%>&fg='+fg+'&fp=ajuste&id=<%//=id%>');
	<%
	}
	%>
	calc();
	//if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function calc()
{
	var iCounter = 0;
	var availableQty = 0;
	var qty = 0;
	var action = document.form1.baction.value;
	var total = 0.00;
	var art_flia = '', art_clase = '', cod_art = '';
	var almacen 				= parent.document.form1.codigoAlmacen.value;
	var cia = <%=(String) session.getAttribute("_companyId")%>;
	var conChk = 0;
	var signo = parent.document.form1.sign_tipo_ajuste.value;
	var estado = parent.document.form1.estado.value;

<%
	for (int i=0; i<ajuArt.size(); i++){
%>
		art_flia 				= document.form1.cod_familia<%=i%>.value;
		art_clase 			= document.form1.cod_clase<%=i%>.value;
		cod_art 				= document.form1.cod_articulo<%=i%>.value;
		availableQty = getInvDisponible('<%=request.getContextPath()%>', cia, almacen, art_flia, art_clase, cod_art);

	if (isNaN(document.form1.cantidad<%=i%>.value) || document.form1.cantidad<%=i%>.value == '' || parseFloat(document.form1.cantidad<%=i%>.value) < 0){
		top.CBMSG.warning('Por favor ingresar Cant. Entregada válida!');
		document.form1.cantidad<%=i%>.select();
		return false;
	} else if (document.form1.cantidad<%=i%>.value != '' && parseInt(document.form1.cantidad<%=i%>.value,10) > 0){
		iCounter++;
		qty = parseFloat(document.form1.cantidad<%=i%>.value);

	<% 	if(AjuDet.getFg().equals("GEN")){ %>
	if(signo=='-') qty = qty *-1;
	<%}%>
	<%if(AjuDet.getFg().equals("GEN")){%>
		if(qty < 0.00 && (qty*-1) > availableQty){
			if(action=="Guardar" && estado!="R" ){
			top.CBMSG.warning('Cantidad excede la existencia!');
			document.form1.cantidad<%=i%>.value=0;
			document.form1.cantidad<%=i%>.select();
			return false;
			} else return true
		} else {
	<%} else {%>
		if (qty > availableQty){
			if(action=="Guardar"  && estado!="R"){
			top.CBMSG.warning('Cantidad excede la existencia!');
			document.form1.cantidad<%=i%>.value=0;;
			document.form1.cantidad<%=i%>.select();
			return false;
			} else return true
		} else {
	<%
		}
	%>

<%
	if(AjuDet.getFg().equals("NE")){
%>
			total += qty * parseFloat(document.form1.precio<%=i%>.value);
			document.form1.total<%=i%>.value = (qty * parseFloat(document.form1.precio<%=i%>.value)).toFixed(2);
<%
	}
%>
		}
	} else if (parseInt(document.form1.cantidad<%=i%>.value,10) == 0 && action=='Guardar'){
		iCounter++;

		top.CBMSG.warning('Cantidad de Ajuste no puede ser igual a 0!');
		document.form1.cantidad<%=i%>.select();
		return false;
	}
	<%
	if(fp.equals("aprob")){
	%>
	if(document.form1.chk<%=i%>.checked) conChk++;
	<%
	}
	}
	if(AjuDet.getFg().equals("NE")){
%>
	document.form1.subtotal.value = (total).toFixed(2);
<%
	}
%>
	<%
	if(fp.equals("aprob")){
	%>
	if(conChk==0 && document.form1.estado.value=='A'){
		top.CBMSG.warning('Seleccione al menos un artículo a ajustar!');
		iCounter=0;
	}
	<%}%>
    
	if(action=="Guardar"){
	   if (iCounter > 0) return true;
	   else return false;
	} else return true;
}

function doSubmit()
{ 
	document.form1.observacion.value = parent.document.form1.observacion.value;
	document.form1.baction.value = parent.document.form1.baction.value;
	document.form1.anio.value = parent.document.form1.anio.value;
	document.form1.noAjuste.value = parent.document.form1.noAjuste.value;
	document.form1.fechaAjuste.value = parent.document.form1.fechaAjuste.value;
	document.form1.codigoAjuste.value = parent.document.form1.codigoAjuste.value;
	document.form1.codigoAlmacen.value = parent.document.form1.codigoAlmacen.value;
	//document.form1.nombreAlmacen.value = parent.document.form1.nombreAlmacen.value;
	document.form1.saveOption.value = parent.document.form1.saveOption.value;
	document.form1.fg.value = parent.document.form1.fg.value;
	document.form1.clearHT.value = parent.document.form1.clearHT.value;
	document.form1.estado.value = parent.document.form1.estado.value;
    if (parent.document.form1.cod_ref) document.form1.cod_ref.value = parent.document.form1.cod_ref.value;
	<%if(AjuDet.getFg().equals("GEN")){%>
	if(parent.document.form1.proveedor.value!=''){
		document.form1.proveedor.value = parent.document.form1.proveedor.value;
		document.form1.nombre_proveedor.value = parent.document.form1.nombre_proveedor.value;
	}
	<%}%>
	<%if(AjuDet.getFg().equals("FAC")){%>
	document.form1.proveedor.value = parent.document.form1.proveedor.value;
	document.form1.nombre_proveedor.value = parent.document.form1.nombre_proveedor.value;
	document.form1.anio_doc.value = parent.document.form1.anio_doc.value;
	document.form1.numero_doc.value = parent.document.form1.numero_doc.value;
	document.form1.num_factura.value = parent.document.form1.num_factura.value;
	<%}%>
	<%if(AjuDet.getFg().equals("NE")){%>
	document.form1.proveedor.value = parent.document.form1.proveedor.value;
	document.form1.nombre_proveedor.value = parent.document.form1.nombre_proveedor.value;
	document.form1.numero_doc.value = parent.document.form1.numero_doc.value;
	<%}%>
	<%if(AjuDet.getFg().equals("AI")){%>
	document.form1.sala.value = parent.document.form1.sala.value;
	document.form1.desc_centro.value = parent.document.form1.desc_centro.value;
	<%}%>
	document.form1.sign_tipo_ajuste.value = parent.document.form1.sign_tipo_ajuste.value;
	if (document.form1.codigoAlmacen.value == '')
	{
		top.CBMSG.warning('Por favor seleccione un Almacén!');
		<% if (fp.equals("aprob")) { %>parent.buscaCA();<% } %>
		return false;
	}
	if (document.form1.baction.value=='Guardar'&&!parent.form1Validation()) return false;
	//if (!checkActive()) return false;
	else if(calc()){
		document.form1.submit();
		return true;
	} else {
		parent.form1BlockButtons(false);
		return false;
	}
}

function calMonto(j,field){

	cantidad				= parseInt(eval('document.form1.cantidad'+j).value,10);
	cant_disponible	= parseInt(eval('document.form1.cant_disponible'+j).value,10);
	monto 					= eval('document.form1.precio'+j).value;
	if(isNaN(cantidad) || isNaN(monto)){
		top.CBMSG.warning('Introduzca valores numéricos!');
		if(field=='c') eval('document.form1.cantidad'+j).value = 0;
		else if(field=='p') eval('document.form1.precio'+j).value = 0;
		return false;
	} else {
		if(cantidad <= (cant_disponible)){
			eval('document.form1.total'+j).value = (cantidad * monto).toFixed(6);
			calc();
			return true;
		} else {
			top.CBMSG.warning('Cantidad excede la existencia!');
			eval('document.form1.cantidad'+j).value = 0;

			return false;
		}
	}
}

function checkAll(){
	var size = <%=ajuArt.size()%>;
	if(document.form1.chkAll.checked){
		for(i=0;i<size;i++){
			eval('document.form1.chk'+i).checked = true;
		}
	} else {
		for(i=0;i<size;i++){
			eval('document.form1.chk'+i).checked = false;
		}
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("size",""+ajuArt.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("anio","")%>
<%=fb.hidden("noAjuste","")%>
<%=fb.hidden("fechaAjuste","")%>
<%=fb.hidden("codigoAjuste","")%>
<%=fb.hidden("codigoAlmacen","")%>
<%=fb.hidden("nombreAlmacen","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg","")%>
<%=fb.hidden("fp","")%>
<%=fb.hidden("clearHT","")%>

<%=fb.hidden("proveedor","")%>
<%=fb.hidden("nombre_proveedor","")%>
<%=fb.hidden("anio_doc","")%>
<%=fb.hidden("numero_doc","")%>
<%=fb.hidden("num_factura","")%>
<%=fb.hidden("n_d","")%>
<%=fb.hidden("sala","")%>
<%=fb.hidden("desc_centro","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("observacion","")%>
<%=fb.hidden("sign_tipo_ajuste","")%>
<%=fb.hidden("cod_ref","")%>
<%
String colspan = "8";
if(AjuDet.getFg().equals("NE")) colspan = "9";
else if(AjuDet.getFg().equals("FAC")) colspan = "11";
%>
<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td colspan="<%=colspan%>" align="right"><%if((AjuDet.getFg().equals("GEN") || AjuDet.getFg().equals("NE")) && mode.equals("add")){%>
	<%=fb.submit("addArticles","Agregar Articulos",false,viewMode,"", "", "onClick=\"javascript: return(doSubmit());\"")%><%}%>&nbsp;</td>
</tr>
	<%
	if(AjuDet.getFg().equals("GEN")){
	%>
<tr class="TextHeader" align="center">
	<td colspan="3">C&oacute;digo</td>
	<td rowspan="2" width="15%">Cod. Barra</td>
	<td rowspan="2" width="36%">Descripci&oacute;n</td>
	<td rowspan="2" width="7%">Precio</td>
	<td rowspan="2" width="9%">Ajuste</td>
	<td rowspan="2" width="2%">
  <%if(fp.equals("aprob")){%>Aprobar<br>
  <%=fb.checkbox("chkAll","",false,false,"","","onClick=\"javascript:checkAll();\"","Aprobar todos los articulos listados")%>
  <%}%>
  </td>
</tr>
	<%
	} else if(AjuDet.getFg().equals("NE")){
	%>
<tr class="TextHeader" align="center">
	<td colspan="3">C&oacute;digo</td>
	<td rowspan="2" width="15%">Cod. Barra</td>
	<td rowspan="2" width="36%">Descripci&oacute;n</td>
	<td rowspan="2" width="7%">Disponible</td>
	<td rowspan="2" width="7%">Cantidad</td>
	<td rowspan="2" width="7%">Precio</td>
	<td rowspan="2" width="7%">Total</td>
</tr>
	<%
	} else {
	%>
<tr class="TextHeader" align="center">
	<td colspan="3">C&oacute;digo</td>
	<td rowspan="2" width="15%">Cod. Barra</td>
	<td rowspan="2" width="36%">Descripci&oacute;n</td>
	<td rowspan="2" width="7%">Unid.</td>
	<td rowspan="2" width="7%">Facturado</td>
	<td rowspan="2" width="7%">Recibido</td>
	<td rowspan="2" width="7%">Ajuste</td>
	<td rowspan="2" width="9%">Precio
	<td rowspan="2" width="2%">
  <%if(fp.equals("aprob")){%>
  <%=fb.checkbox("chkAll","",false,false,"","","onClick=\"javascript:checkAll();\"")%>
  <%}%>
  </td>
</tr>
	<%
	}
	%>
<tr class="TextHeader" align="center">
	<td width="5%">Familia</td>
	<td width="5%">Clase</td>
	<td width="10%">Art&iacute;culo</td>
</tr>
<%
if (ajuArt.size() > 0) al = CmnMgr.reverseRecords(ajuArt);
for (int i=0; i<ajuArt.size(); i++)
{
	key = al.get(i).toString();
	AjusteDetails ad = (AjusteDetails) ajuArt.get(key);
	String color = "";
	boolean precioRO = true, cantidadRO = false;

	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
	if(AjuDet.getFg().equals("FAC")){
		cantidadRO = true;
	} else if(AjuDet.getFg().equals("GEN")){
		cantidadRO = false;
	}

	if(!AjuDet.getFg().equals("NE")){
%>
		<%=fb.hidden("cant_disponible"+i,ad.getCantidadDisponible())%>
	<%}%>
	<%=fb.hidden("cod_familia"+i,ad.getCodFamilia())%>
  <%=fb.hidden("cod_clase"+i,ad.getCodClase())%>
  <%=fb.hidden("cod_articulo"+i,ad.getCodArticulo())%>
  <%=fb.hidden("articulo"+i,ad.getArticulo())%>
  <%=fb.hidden("consignacion"+i,ad.getConsignacionSN())%>
  <%=fb.hidden("cod_barra"+i,ad.getCodBarra())%>
	<%
	if(AjuDet.getFg().equals("GEN")){
	%>
<tr class="<%=color%>" align="center">
	<td><%=ad.getCodFamilia()%></td>
	<td><%=ad.getCodClase()%></td>
	<td><%=ad.getCodArticulo()%></td>
	<td><%=ad.getCodBarra()%></td>
	<td align="left"><%=ad.getArticulo()%></td>
	<td><%=fb.decBox("precio"+i,ad.getPrecio(),false,false,precioRO,5,"11.10")%></td>
	<td><%=fb.intBox("cantidad"+i,ad.getCantidadAjuste(),false,false,(viewMode || cantidadRO),5)%></td>
	<td align="center">
  <%if(fp.equals("aprob")||mode.trim().equals("view")){%>
  <%=fb.checkbox("chk"+i,""+i,(ad.getCheckAprov().trim().equals("S")),viewMode)%>
  <%} else {%>
	<%=fb.submit("del"+i,"x",false,(viewMode||cantidadRO),null,null,"onClick=\"javascript:parent.doSubmit(this.value)\"")%>
  <%}%>
  </td>
</tr>
	<%
	} else if(AjuDet.getFg().equals("NE")){
	%>
<tr class="<%=color%>" align="center">
	<td><%=ad.getCodFamilia()%></td>
	<td><%=ad.getCodClase()%></td>
	<td><%=ad.getCodArticulo()%></td>
	<td><%=ad.getCodBarra()%></td>
	<td align="left"><%=ad.getArticulo()%></td>
	<td><%=fb.intBox("cant_disponible"+i,ad.getCantidadDisponible(),false,false,true,5)%></td>
	<td><%=fb.intBox("cantidad"+i,ad.getCantidadAjuste(),false,false,(viewMode || cantidadRO),5,null,null,"onChange=\"javascript:calMonto("+i+",'c')\"")%></td>
	<td><%=fb.decBox("precio"+i,ad.getPrecio(),false,false,precioRO,7,"11.10",null,null,"onChange=\"javascript:calMonto("+i+",'p')\"")%></td>
	<td><%=fb.decBox("total"+i,ad.getTotal(),false,false,true,7)%></td>

</tr>
	<%
	} else {
	%>
<tr class="<%=color%>" align="center">
	<td><%=ad.getCodFamilia()%></td>
	<td><%=ad.getCodClase()%></td>
	<td align="left"><%=ad.getCodArticulo()%></td>
	<td><%=ad.getCodBarra()%></td>
	<td><%=ad.getArticulo()%></td>
	<td><%=fb.intBox("cantUnidad"+i,ad.getCantUnidad(),false,false,true,5)%></td>
	<td><%=fb.intBox("cantFact"+i,ad.getCantFact(),false,false,true,5)%></td>
	<td><%=fb.intBox("cantRec"+i,ad.getCantRec(),false,false,true,5)%></td>
	<td><%=fb.decBox("cantidad"+i,ad.getCantidadAjuste(),false,false,(viewMode || cantidadRO),5)%></td>
	<td><%=fb.decBox("precio"+i,ad.getPrecio(),false,false,precioRO,7,"11.10")%></td>
	<td align="center">
  <%if(fp.equals("aprob") ||mode.trim().equals("view")){%>
  <%=fb.checkbox("chk"+i,""+i,(ad.getCheckAprov().trim().equals("S")),viewMode)%>
  <%} else {%>
	<%=fb.submit("del"+i,"x",false,(viewMode||cantidadRO),null,null,"onClick=\"javascript:parent.doSubmit(this.value)\"")%>
  <%}%>
  </td>
</tr>
	<%
	}
}
%>
<%=fb.hidden("keySize",""+ajuArt.size())%>
	<%
	if(AjuDet.getFg().equals("NE")){
	%>
<tr class="TextRow02" align="center">
	<td colspan="8" align="right">Total</td>
	<td><%=fb.decBox("subtotal",AjuDet.getSubtotal(),false,false,true,7)%></td>
</tr>
	<%
	}
	%>
</table>
<%//fb.appendJsValidation("\n\tif (!calc())\n\t{\n\t\talert('Por favor hacer entrega de por lo menos un articulo!');\n\t\terror++;\n\t}\n");%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "";
	//Ajuste AjuDet = new Ajuste();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	double total = 0;
	String clearHT = request.getParameter("clearHT");
	String anio ="", codigoAjuste = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	AjuDet.setAnioAjuste(request.getParameter("anio"));
	AjuDet.setNumeroAjuste(request.getParameter("noAjuste"));
	AjuDet.setFechaAjuste(request.getParameter("fechaAjuste"));
	AjuDet.setFechaSistema(cDateTime);
	AjuDet.setCodigoAjuste(request.getParameter("codigoAjuste"));
	AjuDet.setCodigoAlmacen(request.getParameter("codigoAlmacen"));
	//AjuDet.setDescAlmacen(request.getParameter("nombreAlmacen"));
	AjuDet.setEstado(request.getParameter("estado"));
	AjuDet.setCodRef(request.getParameter("cod_ref"));System.out.println("-------------"+AjuDet.getCodRef());
	AjuDet.setPagado("N");
	

	if (request.getParameter("observacion") != null && !request.getParameter("observacion").trim().equals(""))
	 AjuDet.setObservacion(request.getParameter("observacion"));
	if (request.getParameter("proveedor") != null && !request.getParameter("proveedor").equals("") && !request.getParameter("proveedor").equals("NA")) AjuDet.setCodProveedor(request.getParameter("proveedor"));
	if (request.getParameter("nombre_proveedor") != null && !request.getParameter("nombre_proveedor").equals("") && !request.getParameter("nombre_proveedor").equals("NA")) AjuDet.setNombreProveedor(request.getParameter("nombre_proveedor"));
	if (request.getParameter("anio_doc") != null && !request.getParameter("anio_doc").equals("") && !request.getParameter("anio_doc").equals("NA")) AjuDet.setAnioDoc(request.getParameter("anio_doc"));
	if (request.getParameter("numero_doc") != null && !request.getParameter("numero_doc").equals("") && !request.getParameter("numero_doc").equals("NA")) AjuDet.setNumeroDoc(request.getParameter("numero_doc"));
	if (request.getParameter("num_factura") != null && !request.getParameter("num_factura").equals("") && !request.getParameter("num_factura").equals("NA")) AjuDet.setNumFactura(request.getParameter("num_factura"));
	if (request.getParameter("n_d") != null && !request.getParameter("n_d").equals("") && !request.getParameter("n_d").equals("NA")) AjuDet.setND(request.getParameter("n_d"));
	if (request.getParameter("sala") != null && !request.getParameter("sala").equals("") && !request.getParameter("sala").equals("NA")) AjuDet.setCentroServicio(request.getParameter("sala"));
	if (request.getParameter("desc_centro") != null && !request.getParameter("desc_centro").equals("") && !request.getParameter("desc_centro").equals("NA")) AjuDet.setDescCentroServ(request.getParameter("desc_centro"));
	AjuDet.setSignTipoAjuste(request.getParameter("sign_tipo_ajuste"));

/*
	AjuDet.setMonto(request.getParameter("total"));
	AjuDet.setItbm("0.00");
	AjuDet.setSubtotal(request.getParameter("total"));
*/
	int size = Integer.parseInt(request.getParameter("size"));
	AjuDet.getAjusteDetail().clear();
	ajuArt.clear();
	ajuArtKey.clear();
	int lineNo = 0;
	for (int i=0; i<size; i++){
		AjusteDetails di = new AjusteDetails();

		di.setCantidadDisponible(request.getParameter("cant_disponible"+i));
		di.setCodFamilia(request.getParameter("cod_familia"+i));
		di.setCodClase(request.getParameter("cod_clase"+i));
		di.setCodArticulo(request.getParameter("cod_articulo"+i));
		di.setArticulo(request.getParameter("articulo"+i));
		di.setCantidadAjuste(request.getParameter("cantidad"+i));
		di.setPrecio(request.getParameter("precio"+i));
		di.setTotal(request.getParameter("total"+i));
		di.setConsignacionSN(request.getParameter("consignacion"+i));
		if(request.getParameter("cod_barra"+i)!=null) di.setCodBarra(request.getParameter("cod_barra"+i));

		if(request.getParameter("fg").equalsIgnoreCase("FAC")) {
		di.setCantUnidad(request.getParameter("cantUnidad"+i));
		di.setCantFact(request.getParameter("cantFact"+i));
		di.setCantRec(request.getParameter("cantRec"+i));
		}


		if(request.getParameter("fp").equalsIgnoreCase("aprob")&&AjuDet.getEstado().trim().equals("A")){
		di.setCheckAprov("S");
		}else{
		di.setCheckAprov("N");
		}
		if(request.getParameter("chk"+i)!=null && !request.getParameter("chk"+i).equals("")&&AjuDet.getEstado().trim().equals("A")) di.setCheckAprov("S");
		total += Double.parseDouble(request.getParameter("precio"+i));
		if(request.getParameter("fg")!=null && request.getParameter("fg").equals("ND")) di.setCantidadAjuste("0");
		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;

		if(request.getParameter("del"+i)==null){
			if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
				if(mode.equals("add") || (request.getParameter("baction").equalsIgnoreCase("Guardar") && mode.equals("edit") && request.getParameter("chk"+i)!=null)){
					try{
						ajuArt.put(key,di);
						ajuArtKey.put(di.getCodFamilia()+"-"+di.getCodClase()+"-"+di.getCodArticulo(), key);
						AjuDet.getAjusteDetail().add(di);
						System.out.println("Adding item... "+key +"_"+di.getCodFamilia()+"-"+di.getCodClase()+"-"+di.getCodArticulo());
					} catch (Exception e){
						System.out.println("Unable to add item...");
					}
				}
			} else {
				try{
					ajuArt.put(key,di);
					ajuArtKey.put(di.getCodFamilia()+"-"+di.getCodClase()+"-"+di.getCodArticulo(), key);
					AjuDet.getAjusteDetail().add(di);
					System.out.println("Adding item... "+key +"_"+di.getCodFamilia()+"-"+di.getCodClase()+"-"+di.getCodArticulo());
				} catch (Exception e){
					System.out.println("Unable to add item...");
				}
			}
		} else {
			dl = "1";
		}
	}

	if(!dl.equals("") || clearHT.equals("S")){
		//AjuDet.getAjusteDetail().clear();
		//ajuArt.clear();
		response.sendRedirect("../inventario/reg_ajuste_item.jsp?mode="+mode+ "&change=1&type=2&fg="+request.getParameter("fg"));
		return;
	}

	if(request.getParameter("addArticles")!=null){
		response.sendRedirect("../inventario/reg_ajuste_item.jsp?mode="+mode+"&id="+id+"&change=1&type=1");
		return;
	}

	System.out.println("request.getParameter(addArticles)="+request.getParameter("addArticles"));

	if (request.getParameter("baction").equalsIgnoreCase("Guardar")){
		AjuDet.setCompania((String) session.getAttribute("_companyId"));
		AjuDet.setUsuarioCreacion((String) session.getAttribute("_userName"));
		AjuDet.setUsuarioMod((String) session.getAttribute("_userName"));
		AjuDet.setUsuarioModificacion((String) session.getAttribute("_userName"));
		if(request.getParameter("fg") != null && !request.getParameter("fg").trim().equals("") && request.getParameter("fg").trim().equals("DE"))
		AjuDet.setFechaMod(cDateTime);

		AjuDet.setTotal(""+total);
		if(request.getParameter("fg") != null && !request.getParameter("fg").trim().equals("") && (request.getParameter("fg").trim().equals("DM") || request.getParameter("fg").trim().equals("ND")))
		{
			AjuDet.setTipoDoc("F");
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if(mode.equals("add")){
		AjuMgr.add(AjuDet);
			id =  AjuMgr.getPkColValue("numero_ajuste");
			anio = AjuDet.getAnioAjuste();
		} else if(mode.equals("edit")){
			AjuMgr.update(AjuDet);
			id = AjuDet.getNumeroAjuste();
		}
		codigoAjuste = AjuDet.getCodigoAjuste();
		ConMgr.clearAppCtx(null);


	}
%>
<html>
<head>
<script>
function closeWindow()
{
	<%if (AjuMgr.getErrCode().equals("1")){%>

	parent.document.form1.errCode.value = <%=AjuMgr.getErrCode()%>;
	parent.document.form1.errMsg.value = '<%=AjuMgr.getErrMsg()%>';
	parent.document.form1.anio.value = '<%=request.getParameter("anio")%>';
	parent.document.form1.codigoAjuste.value = '<%=codigoAjuste%>';
	parent.document.form1.noAjuste.value = '<%=id%>';
	parent.document.form1.submit();
<%} else throw new Exception(AjuMgr.getErrMsg());%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>