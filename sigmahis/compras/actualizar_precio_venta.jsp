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
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OCMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();

boolean viewMode = false;
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String anio = request.getParameter("anio");
if(anio == null) anio=fecha.substring(6, 10);
String fg = request.getParameter("fg");
String tipoComp = request.getParameter("tipoComp");
String descAlmacen = request.getParameter("descAlmacen");
String status = request.getParameter("status");
String delete = request.getParameter("del");
if(delete==null) delete="false";
if (fg == null) fg = "view";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
    if (id == null) throw new Exception("Orden de Compra no es válida. Por favor intente nuevamente!");
	if(delete.equalsIgnoreCase("true")) SQLMgr.execute("delete from tbl_com_cambio_precio_hist where cf_anio = "+
      	anio+" and tipo_comp = "+tipoComp+" and num_doc = "+id+" and compania = "+(String)session.getAttribute("_companyId"));
		
	sbSql = new StringBuffer();
	sbSql.append("select aa.* ,getnewsaleprice(aa.compania,aa.cod_proveedor, aa.cod_almacen,aa.codarticulo,aa.codflia, aa.codclase,aa.last_purch_price,aa.monto,aa.sale_price) as new_sale_price, aa.cantPorEmpaque*getnewsaleprice(aa.compania,aa.cod_proveedor, aa.cod_almacen,aa.codarticulo,aa.codflia, aa.codclase,aa.last_purch_price,aa.monto,aa.sale_price)*aa.cantEmpaque as new_sale_price_box from( select e.cod_proveedor, e.cod_almacen, a.compania, a.cod_familia as codFlia, a.cod_clase as codClase, a.subclase_id as subclaseId, a.cod_articulo as codArticulo, a.cantidad, a.monto_articulo as monto, nvl(a.estado_renglon,' ') as estadoRenglon, nvl(a.especificacion,' ') as especificacion, a.cant_por_empaque as cantPorEmpaque, a.unidad_empaque as unidadEmpaque, (a.cantidad / a.cant_por_empaque) as cantEmpaque, (nvl(a.cant_promo,0) / a.cant_por_empaque) as cantPromoEmp, nvl(a.descuento,0) as descuento, nvl(a.tipo_descuento,'P') as tipoDescuento, (select itbm from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as itbm, (select cod_medida from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as unidad, (select descripcion from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania) as articulo, a.impuesto , getlastprecio (a.compania, e.cod_almacen, a.cod_articulo) as last_purch_price, nvl((select precio_venta from tbl_inv_articulo where cod_articulo = a.cod_articulo and compania = a.compania), 0) as sale_price, get_incsaleprice(a.compania,a.cod_familia, a.cod_clase,a.cod_articulo) as perc_inc_sale_price, (select count(*) from  tbl_com_cambio_precio_hist h where a.compania = h.compania and a.cf_tipo_com = h.tipo_comp and a.cf_num_doc = h.num_doc and a.cf_anio = h.cf_anio and a.cod_articulo = h.cod_articulo) as action from tbl_com_detalle_compromiso a, tbl_com_comp_formales e where a.compania = ");
	
	sbSql.append((String)session.getAttribute("_companyId"));
	sbSql.append(" and a.cf_anio = ");
	sbSql.append(anio);
	sbSql.append(" and a.cf_num_doc = ");
	sbSql.append(id);
	sbSql.append(" and a.compania = e.compania and a.cf_tipo_com = e.tipo_compromiso and a.cf_num_doc = e.num_doc and a.cf_anio = e.anio and a.monto_articulo <> getlastprecio (a.compania, e.cod_almacen, a.cod_articulo)  order by a.cod_familia, a.cod_clase, a.subclase_id, a.cod_articulo)aa");

	al = SQLMgr.getDataList(sbSql.toString());
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Orden de Compra - '+document.title;
function doAction(){
  if( parseInt("<%=al.size()%>",10) < 1 ) 
  {
	$("#saveU, #saveB", window.parent.document).attr("disabled",false);
	return parent.hidePopWin(false);
  }
}
function printDet(){
	var num = "<%=id%>";
	var anio = "<%=anio%>";
	var tp = "<%=tipoComp%>";
	var wh = "<%=descAlmacen%>";
	var st = "<%=status%>";
	if(st=='A') st = 'APROBADO';
	else if(st=='N') st = 'ANULADO';
	else if(st=='T') st = 'TRAMITE';
	else if(st=='P') st = 'PENDIENTE';
	abrir_ventana('../compras/print_orden_parcial.jsp?num='+num+'&anio='+anio+'&tp='+tp+'&wh='+wh+'&status='+st+'&fp=cambio_precio');
}
$(document).ready(function(r){
  $("#saveU, #saveB").click(function(c){
     var _submit = false;
	if($("input[type='checkbox']").is(":checked")==false){
	  if(confirm("No tiene ningún item seleccionado. Quiere seguir?")) _submit = true;
	  else _submit = false;
	}else _submit = true;
	if (_submit){
	  $("#baction").val("Guardar");
	  $("#cambiarprecio").submit();
	}
  });  
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("cambiarprecio",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("tipoComp",tipoComp)%>
<%=fb.hidden("descAlmacen",descAlmacen)%>
<%=fb.hidden("status",status)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("keySize",""+al.size())%>
<tr class="TextPanel">
	<td colspan="10"><cellbytelabel>Detalle de la Solicitud</cellbytelabel></td>
</tr>
<tr class="TextRow02">
	<td colspan="10" align="right">
	<%//=fb.button("printA","Imprimir",true,false,null,null,"onclick=\"printDet()\"")%>
	&nbsp;&nbsp;
	<%=fb.button("saveU","Aprobar e Imprimir Cambio Precio",true,false,null,null,"")%>
	</td>
</tr>
<tr align="center" class="TextHeader">
	<td width="13%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
	<td width="24%" align="left"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="5%"><cellbytelabel><span title="Costo">Costo</span></cellbytelabel></td>
	<td width="10%" align="right"><cellbytelabel>&Uacute;lt. Costo</cellbytelabel></td>
	<td width="8%" align="right"><cellbytelabel>Costo act.</cellbytelabel></td>
	<td width="5%"><cellbytelabel><span title="Venta">Venta</span></cellbytelabel></td>
	<td width="8%" align="right"><cellbytelabel>P.Venta Ant.</cellbytelabel></td>
	<td width="12%" align="right"><cellbytelabel>Nuevo P.Venta U</cellbytelabel></td>
	<td width="12%" align="right"><cellbytelabel>Nuevo P.Venta P</cellbytelabel></td>
	<td width="3%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"checkAll('"+fb.getFormName()+"','check',"+al.size()+",this)\"","Seleccionar todas las órdenes")%></td>
</tr>
<%
for (int i=0; i<al.size(); i++) {
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	CommonDataObject oc = (CommonDataObject)al.get(i);
%>
<%=fb.hidden("cod_flia"+i,oc.getColValue("codFlia"))%>
<%=fb.hidden("cod_clase"+i,oc.getColValue("codClase"))%>
<%=fb.hidden("subclase_id"+i,oc.getColValue(""))%>
<%=fb.hidden("cod_articulo"+i,oc.getColValue("codArticulo"))%>
<%=fb.hidden("articulo"+i,oc.getColValue("articulo"))%>
<%=fb.hidden("cantPorEmpaque"+i,oc.getColValue("cantPorEmpaque"))%>
<%=fb.hidden("unidadEmpaque"+i,oc.getColValue("unidadEmpaque"))%>
<%=fb.hidden("unidad"+i,oc.getColValue("unidad"))%>
<%=fb.hidden("itbm"+i,oc.getColValue("itbm"))%>
<%=fb.hidden("impuesto"+i,oc.getColValue("impuesto"))%>
<%=fb.hidden("last_purch_price"+i,oc.getColValue("last_purch_price"))%>
<%=fb.hidden("new_sale_price"+i,oc.getColValue("new_sale_price"))%>
<%=fb.hidden("sale_price"+i,oc.getColValue("sale_price"))%>
<%=fb.hidden("monto"+i,oc.getColValue("monto"))%>
<%=fb.hidden("perc_inc_sale_price"+i,oc.getColValue("perc_inc_sale_price"))%>
<%=fb.hidden("new_sale_price_box"+i,oc.getColValue("new_sale_price_box"))%>
<%=fb.hidden("action"+i,oc.getColValue("action"))%>
<tr class="TextRow01" align="center">
	<td><%=oc.getColValue("codArticulo")%>-<%=oc.getColValue("codFlia")%>-<%=oc.getColValue("codClase")%></td>
	<td align="left"><%=oc.getColValue("articulo")%></td>
	<%
	   String _legendC = "", _legendV = "", _colorC="",_colorV="", _titleC="", _titleV="", hintClass=""; 
	   double lastPprice = Double.parseDouble(oc.getColValue("last_purch_price")==null?"0":oc.getColValue("last_purch_price"));
	   double curPprice = Double.parseDouble(oc.getColValue("monto")==null?"0":oc.getColValue("monto"));
	   
	   double lastSprice = Double.parseDouble(oc.getColValue("sale_price")==null?"0":oc.getColValue("sale_price"));
	   double curSprice = Double.parseDouble(oc.getColValue("new_sale_price")==null?"0":oc.getColValue("new_sale_price"));
	   
	   if (lastPprice>curPprice){
	     _colorC=" style='color:green;'";
		 _legendC="&#x25BC;";
		 _titleC="Baj&oacute;";
		 hintClass = "hint hint--left";
	   }
	   else if(lastPprice<curPprice) {
	     _colorC=" style='color:red;'";
	     _legendC="&#x25B2;";
		 _titleC="Subi&oacute;";
		 hintClass = "hint hint--left";
	   }
	   
	   if (lastSprice>curSprice){
	     _colorV=" style='color:red;'";
		 _legendV ="&#x25BC;";
		 _titleV="Baj&oacute;";
		 hintClass = "hint hint--left";
	   }
	   else if(lastSprice<curSprice ) {
	     _colorV=" style='color:green;'";
	     _legendV="&#x25B2;";
		 _titleV="Subi&oacute;";
		 hintClass = "hint hint--left";
	   }
	  %>
	<td style="cursor:pointer">
	   <div class="<%=hintClass%>" data-hint="<%=_titleC%>">
	   <span<%=_colorC%>><%=_legendC%></span>
	   </div>
	</td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(oc.getColValue("last_purch_price"))%></td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(oc.getColValue("monto"))%></td>
	<td style="cursor:pointer">
	  <div class="<%=hintClass%>" data-hint="<%=_titleV%>">
	    <span<%=_colorV%>><%=_legendV%></span>
	  </div>
	</td>
	<td align="right"><%=CmnMgr.getFormattedDecimal(oc.getColValue("sale_price"))%></td>
	<td style="cursor:pointer">
	   <div class="<%=hintClass%>" data-hint="+<%=oc.getColValue("perc_inc_sale_price")%>%">
			<%=CmnMgr.getFormattedDecimal(oc.getColValue("new_sale_price"))%>
	   </div>
	 </td>
	<td align="right" style="cursor:pointer">
	  <div class="<%=hintClass%>" data-hint="Qty x Emp: <%=oc.getColValue("cantPorEmpaque")%>, Qty Emp: <%=oc.getColValue("cantEmpaque")%>">
	   <%=CmnMgr.getFormattedDecimal(oc.getColValue("new_sale_price_box"))%>&nbsp;(<%=oc.getColValue("cantEmpaque")%>)
	  </div>
	</td>
	<td><%=oc.getColValue("action")!=null&&oc.getColValue("action").equals("0")?fb.checkbox("check"+i,"",false,false):""%></td>
</tr>
<% } %>
<tr class="TextRow02">
	<td colspan="10" align="right">
		<%=fb.button("saveB","Aprobar e Imprimir Cambio Precio",true,false,null,null,"")%>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{

	String companyId = (String) session.getAttribute("_companyId");
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String baction = request.getParameter("baction")==null?"":request.getParameter("baction");
	
	OCDet.setCompania(companyId);
	OCDet.setAnio(request.getParameter("anio"));
	OCDet.setNumDoc(request.getParameter("id"));
	OCDet.setTipoCompromiso(request.getParameter("tipoComp"));

	OCDet.setUsuario((String) session.getAttribute("_userName"));
	OCDet.setUsuarioMod((String) session.getAttribute("_userName"));

	OCDet.getOCDetails().clear();
	
	for(int i=0;i<keySize;i++){

		OrdenCompraDetail oc = new OrdenCompraDetail();
		oc.setCodFlia(request.getParameter("cod_flia"+i));
		oc.setCodClase(request.getParameter("cod_clase"+i));
		oc.setSubclaseId(request.getParameter("subclase_id"+i));
		oc.setCodArticulo(request.getParameter("cod_articulo"+i));
		oc.setArticulo(request.getParameter("articulo"+i));

		oc.setCostoAnt(request.getParameter("last_purch_price"+i));
		oc.setCostoAct(request.getParameter("monto"+i));
		oc.setPrecioVentaAnt(request.getParameter("sale_price"+i));
		oc.setPrecioVentaAct(request.getParameter("new_sale_price"+i));
		oc.setPrecioVentaActEmp(request.getParameter("new_sale_price_box"+i));
		oc.setPorcInc(request.getParameter("perc_inc_sale_price"+i));
		
		oc.setFechaCrea(fecha);
		oc.setUsuarioCrea((String) session.getAttribute("_userName"));
		oc.setFechaModifica(fecha);
		oc.setUsuarioModifica((String) session.getAttribute("_userName"));

		if(request.getParameter("check"+i)!=null){
			try {
				OCDet.getOCDetails().add(oc);
			}	catch (Exception e)	{
				System.out.println("Unable to addget item OC ");
			}
		}
	}
	
	if (baction.equalsIgnoreCase("Guardar") && OCDet.getOCDetails().size() > 0){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		OCMgr.addCambiarPrecio(OCDet);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
OCMgr.setErrCode("1");
if (OCMgr.getErrCode().equals("1")){
%>
	<% if(!baction.equalsIgnoreCase("GuardarSCP") ) {%> alert("<%=OCMgr.getErrMsg()%>");<%}%>
	
	window.open("../compras/print_orden_parcial.jsp?num=<%=request.getParameter("id")%>&anio=<%=request.getParameter("anio")%>&tp=<%=request.getParameter("tipoComp")%>&wh=<%=request.getParameter("descAlmacen")%>&status=<%=request.getParameter("status")%>&fp=cambio_precio_all","_blank", "toolbar=yes, scrollbars=yes, resizable=yes, fullscreen=yes");
		
	parent.hidePopWin(false);
	parent.window.document.getElementById("form1").submit();
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