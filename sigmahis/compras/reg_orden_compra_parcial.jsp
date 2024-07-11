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

if (fg == null) fg = "view";  // Eso es solo para evitar null  y receibir valor que no debe equals  "EOC".

int lineNo = 0;
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

		sql = "select tipo_com, descripcion from tbl_com_tipo_compromiso where tipo_com = 3";
		cdo2 = SQLMgr.getData(sql);
		if (cdo2 == null) throw new Exception("Tipo Compromiso no definido!");
		OCDet.setTipoCompromiso(cdo2.getColValue("tipo_com"));
		OCDet.setDescTipoCompromiso(cdo2.getColValue("descripcion"));
		OCDet.setFechaDocto(fecha);
		OCDet.setNoInventario("Y");
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
			sql = "SELECT a.tipo_descuento tipodescuento,a.dia_limite diaLimite,a.anio, a.tipo_compromiso tipoCompromiso, a.num_doc numDoc, a.compania, TO_CHAR(a.fecha_documento,'dd/mm/yyyy') fechaDocto, a.cod_proveedor codProveedor, a.status, a.sub_total subTotal, a.itbm, a.monto_total montoTotal, a.ubic_actual ubicActual, a.tipo_pago tipoPago, a.cod_almacen codAlmacen, nvl(a.descuento,0) descuento, nvl(a.porcentaje,0) porcentaje, a.explicacion, a.activa, nvl(a.requi_numero,0) requiNo, nvl(a.requi_anio,0) requiAnio,a.tiene_desc as tieneDesc , b.nombre_proveedor descCodProveedor, b.ruc, d.descripcion descTipoCompromiso, nvl(to_char(a.fecha_entrega_proveedor,'dd/mm/yyyy'),' ') as fechaEntProv, nvl(to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy'),' ') as fechaEntVence,'Y' noInventario,a.motivo as descCodAlmacen  FROM TBL_COM_COMP_FORMALES a, TBL_COM_PROVEEDOR b, TBL_INV_ALMACEN c, TBL_COM_TIPO_COMPROMISO d WHERE a.tipo_compromiso = 3 and a.compania = "+session.getAttribute("_companyId")+" and a.anio = "+anio+" and a.num_doc="+id+" and a.cod_proveedor = b.cod_provedor AND a.compania = c.compania AND a.cod_almacen = c.codigo_almacen AND a.tipo_compromiso = d.tipo_com";

			System.out.println("sql....="+sql);
			OCDet = (OrdenCompra) sbb.getSingleRowBean(ConMgr.getConnection(), sql, OrdenCompra.class);

			/*sql = "SELECT a.*, b.* FROM (SELECT a.cod_flia||'-'||a.cod_clase||'-'||a.cod_subclase||'-'||a.cod_articulo art_key, a.compania, a.cod_flia codFlia, a.cod_clase codClase,a.cod_subclase  subclaseId, a.cod_articulo codArticulo, a.descripcion articulo, a.itbm, a.cod_medida unidad, a.precio_venta, a.tipo, a.tipo_material, b.nombre descArtFamilia, c.descripcion descArtClase FROM TBL_INV_ARTICULO a, TBL_INV_FAMILIA_ARTICULO b, TBL_INV_CLASE_ARTICULO c WHERE (a.compania = c.compania AND a.cod_flia = c.cod_flia AND a.cod_clase = c.cod_clase) AND (c.compania = b.compania AND c.cod_flia = b.cod_flia) AND a.compania = "+session.getAttribute("_companyId")+") a, (SELECT a.cod_familia||'-'||a.cod_clase||'-'||a.subclase_id||'-'||a.cod_articulo art_key, NVL(anio_requi,0) aniorequi, NVL(requi_num,0) requinum, a.cantidad, monto_articulo monto, round(cantidad*monto_articulo,6) total, nvl(entregado,0) as entregado, nvl(a.estado_renglon,' ') estadorenglon, especificacion, a.cant_por_empaque cantPorEmpaque, a.unidad_empaque unidadEmpaque, (a.cantidad/a.cant_por_empaque) cantEmpaque,nvl(cantidad_acumulada,0) as cantidadAcumulada FROM TBL_COM_DETALLE_COMPROMISO a WHERE a.cf_tipo_com = 3 and a.compania = "+session.getAttribute("_companyId")+" AND a.cf_anio = "+anio+" AND a.cf_num_doc = "+id+") b WHERE a.art_key = b.art_key order by a.codflia, a.codclase,a.subclaseId, a.codarticulo";

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
			}*/
		}
		session.setAttribute("OCDet",OCDet);
	}
    CommonDataObject cdoP = SQLMgr.getData("select get_sec_comp_param("+(String)session.getAttribute("_companyId")+",'COMP_DEL_BEFORE_PROCEED') as del_before_proceed from dual ");
    if (cdoP==null) cdoP = new CommonDataObject();
    boolean delBeforeProceed = (cdoP.getColValue("del_before_proceed","N")).equals("S") || (cdoP.getColValue("del_before_proceed","N").equals("Y"));
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Administración - '+document.title;

function doAction(){
	document.ordencompra.codigo_almacen_bk.value = document.ordencompra.codigo_almacen.value;
}

function buscaProv(){
  <%if(delBeforeProceed){%>
   var keySize = $("#itemFrame").contents().find("#validSize").val() || '0';
	if(parseInt(keySize)>0){
      CBMSG.alert("Por favor borrar el detalle de solicitud antes de cambiar de proveedor.");
    } else abrir_ventana2('../compras/sel_proveedor.jsp');
    <%}else{%>
    abrir_ventana2('../compras/sel_proveedor.jsp');
    <%}%>
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


function doSubmit(value){
	ordencompraBlockButtons(true);
	document.ordencompra.baction.value = value;

	if (!ordencompraValidation()){
		 ordencompraBlockButtons(false);
	} else{
		if(value=='Guardar')
		{
			if ($("#tipo_pago").val()=="2" && $("#diaLimite").val()=="0") {
				ordencompraBlockButtons(false);
				CBMSG.error("Por favor seleccione el día límite!");
			}
			else if('<%=fg%>'=='EOC'){window.frames['itemFrame'].doSubmit(value);}
			else if('<%=mode%>' !='add'){var estatus = getDBData('<%=request.getContextPath()%>','status','tbl_com_comp_formales','compania = <%=session.getAttribute("_companyId")%> and tipo_compromiso = 3 and anio = <%=anio%> and num_doc = <%=id%>','');
			if(estatus !='T'){alert('La orden de Compra no Puede ser Modificada !!');ordencompraBlockButtons(false);}
			else {
			   if ($("#tipo_pago").val()=="1") $("#diaLimite").val("0");
			   window.frames['itemFrame'].doSubmit(value);
			}
			}else {
			   if ($("#tipo_pago").val()=="1") $("#diaLimite").val("0");
			   window.frames['itemFrame'].doSubmit(value);
			}

		}else{ ordencompraBlockButtons(false);window.frames['itemFrame'].doSubmit(value);}
	}
}

function validaFechaVence(){
	var fecha = document.ordencompra.fechaEntProv.value;
	var fecha_vence = document.ordencompra.fechaEntVence.value;
	if(getDBData('<%=request.getContextPath()%>','case when to_date(\''+fecha_vence+'\',\'dd/mm/yyyy\')<=to_date(\''+fecha+'\',\'dd/mm/yyyy\') then 1 else 0 end','dual','','')==1){alert('La fecha de vencimiento no puede ser menos a la fecha de entrega!');document.ordencompra.fechaEntVence.value='';}//'
}

function setLastPrice(value){
	window.frames['itemFrame'].setLastPrice(value);
}

$(document).ready(function(){
  $("#tipo_pago").change(function(){
    tipoPago = $(this).val();
	if (tipoPago=="0" || tipoPago=="1"){
	  $("#diaLimite").val("0").attr("disabled",true);
	}else if (tipoPago=="2"){
	   $("#diaLimite").attr("disabled",false);
	}
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="COMPRAS - CREAR/MODIFICAR ORDEN DE COMPRA PARCIAL"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<%fb = new FormBean("ordencompra",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("orden_compra_no","")%>
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
		<tr class="TextRow02">
			<td colspan="8" align="right">&nbsp;</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="8"><cellbytelabel>Compra</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Tipo de Compra</cellbytelabel></td>
			<td colspan="3">
				<%=fb.intBox("tipo_compromiso",OCDet.getTipoCompromiso(),true,false,true,4,null,null,"")%>
				<%=fb.textBox("desc_tipo_compromiso",OCDet.getDescTipoCompromiso(),true,false,true,35,null,null,"")%>
			</td>
			<td width="10%" align="right"><cellbytelabel>N&uacute;mero</cellbytelabel>:</td>
			<td colspan="2">
				<%=fb.intBox("anio",OCDet.getAnio(),true,false,true,3,null,null,"")%>
				<%=fb.intBox("num_doc",OCDet.getNumDoc(),true,false,true,4,null,null,"")%>
			</td>
			<td width="20%"><cellbytelabel>Estatus</cellbytelabel> <%=fb.select("estatus","A=APROBADO,N=ANULADO,P=PENDIENTE,R=PROCESADO,T=TRAMITE,Z=CERRADO",OCDet.getStatus(),false,true,0)%></td>
		</tr>
		<tr class="TextPanel">
			<td colspan="8">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td width="10%" align="right"><cellbytelabel>Tipo de Pago</cellbytelabel></td>
			<!--// CRE=CREDITO,CO=CONTADO-->
			<td width="12%"><%=fb.select("tipo_pago","2=Crédito,1=Contado",OCDet.getTipoPago(),false,viewMode,0)%></td>
			<td width="10%" align="right"><cellbytelabel>D&iacute;a L&iacute;mite</cellbytelabel>:</td>
			<td width="12%"><%=fb.select("diaLimite","0=-SELECCIONE-,1=15 Dias,2=30 Dias,3=45 Dias,4=60 Dias,5=90 Dias,6=120 Dias",OCDet.getDiaLimite(),false,viewMode,0)%></td>
			<td colspan="2">
				<!--<cellbytelabel>Art. Proveedor</cellbytelabel>-->
				<%//=fb.select("filterProveedor", "N=TODOS,Y=SOLO PROVEEDOR",OCDet.getNoInventario(),false,viewMode,0)%>
			</td>
			<td width="10%" align="right"><cellbytelabel>Fecha</cellbytelabel></td>
			<td width="20%">
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fecha_documento"/>
				<jsp:param name="valueOfTBox1" value="<%=OCDet.getFechaDocto()%>"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="8"><cellbytelabel>Proveedor</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>Proveedor</cellbytelabel></td>
			<td colspan="4">
				<%=fb.intBox("cod_proveedor",OCDet.getCodProveedor(),true,false,true,5,null,null,"")%>
				<%=fb.textBox("desc_cod_proveedor",OCDet.getDescCodProveedor(),true,false,true,40,null,null,"")%>
				<%=fb.button("buscar","Buscar",false,viewMode,"","","onClick=\"javascript:buscaProv()\"")%>
			</td>
			<td colspan="3">
				<cellbytelabel>Fecha Entrega al Proveedor</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fechaEntProv"/>
				<jsp:param name="valueOfTBox1" value="<%=OCDet.getFechaEntProv()%>"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>R.U.C</cellbytelabel>.:</td>
			<td colspan="4"><%=fb.textBox("ruc",OCDet.getRuc(),true,false,true,40,null,null,"")%></td>
			<td colspan="3">
				<cellbytelabel>Fecha Entrega de Bienes (Vencimiento)</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="clearOption" value="true"/>
				<jsp:param name="nameOfTBox1" value="fechaEntVence"/>
				<jsp:param name="valueOfTBox1" value="<%=OCDet.getFechaEntVence()%>"/>
				<jsp:param name="jsEvent" value="validaFechaVence()"/>
				<jsp:param name="onChange" value="validaFechaVence()"/>
				</jsp:include>
			</td>
		</tr>
		<tr class="TextPanel">
			<td colspan="8"><cellbytelabel>Lugar de Entrega</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td align="right"><cellbytelabel>C&oacute;digo</cellbytelabel>:</td>
			<td colspan="7"><%=fb.hidden("codigo_almacen_bk",OCDet.getCodAlmacen())%><%=fb.select(ConMgr.getConnection(),"SELECT codigo_almacen, codigo_almacen ||'-'||descripcion descripcion FROM TBL_INV_ALMACEN a WHERE compania = "+session.getAttribute("_companyId") +" ORDER BY descripcion","codigo_almacen",(OCDet.getCodAlmacen()!=null && !OCDet.getCodAlmacen().equals("")?OCDet.getCodAlmacen():(SecMgr.getParValue(UserDet,"almacen_ua")!=null && !SecMgr.getParValue(UserDet,"almacen_ua").equals("")?SecMgr.getParValue(UserDet,"almacen_ua"):"")),false,false,0,null,null,"onChange=\"javascript:setLastPrice(this.value);\"")%></td>
		</tr>
		<tr class="TextPanel">
			<td colspan="3"><cellbytelabel>Comentarios</cellbytelabel></td>
			<td colspan="2"><cellbytelabel><%=((OCDet.getStatus().trim().equals("Z"))?"Comentario Cierre":"")%></cellbytelabel></td>
			<td colspan="3"><cellbytelabel>Solicitud de Compra</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3" rowspan="2"><%=fb.textarea("explicacion",OCDet.getExplicacion(),false,false,viewMode,40,3)%> </td>
			<td colspan="2" rowspan="2">
			<%=((OCDet.getStatus().trim().equals("Z"))?fb.textarea("explicacion_cierre",OCDet.getDescCodAlmacen(),false,false,viewMode,40,3):"")%> </td>
			 <td colspan="3"><cellbytelabel>N&uacute;mero</cellbytelabel>:
				<%=fb.intBox("anio_requi",OCDet.getRequiAnio(),false,false,true,4,null,null,"")%>
				<%=fb.intBox("no_requi",OCDet.getRequiNo(),false,false,true,4,null,null,"")%>
				<%=fb.button("buscar","Buscar",false,viewMode,"","","onClick=\"javascript:buscaAN()\"")%>
				<%=fb.button("addArticlesR","Articulos de Solicitud",false,viewMode,"","","onClick=\"javascript:doSubmit(this.value)\"")%>
			</td>
		</tr>
		<tr class="TextRow01">
			<td><!--<cellbytelabel>Esta Orden tiene descuento</cellbytelabel>?--></td>
			<td colspan="3">
				<%//=fb.select("tieneDesc","N=No,S=Sí",OCDet.getTieneDesc(),false,viewMode,0,"","","onChange=\"javascript:changeDesc()\"")%>
				<%//=fb.select("tipodescuento","N=No Applica,P=Porcentaje,M=Monto",OCDet.getTipodescuento(),false,viewMode,0,"","","onChange=\"javascript:calValues()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="8"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../compras/reg_orden_compra_parcial_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&id=<%=id%>&anio=<%=anio%>"></iframe></td>
		</tr>
		<tr class="TextRow02">
			<td colspan="8" align="right">
				<%=fb.button("save","Guardar",true,(mode.equalsIgnoreCase("view") && fg.equalsIgnoreCase("EOC"))?false:viewMode,"","","onClick=\"javascript:doSubmit(this.value);\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
		<tr>
			<td colspan="8">
				<jsp:include page="../common/bitacora.jsp" flush="true">
				<jsp:param name="audCollapsed" value="n"></jsp:param>
				<jsp:param name="audTable" value="tbl_com_comp_formales"></jsp:param>
				<jsp:param name="audCreatedUser" value="usuario"></jsp:param>
				<jsp:param name="audFilter" value="<%="anio = "+anio+" and tipo_compromiso = 3 and num_doc = "+id+" and compania = "+(String) session.getAttribute("_companyId")%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table>
	</td>
</tr>
<%
//fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
//fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
%>
<%=fb.formEnd(true)%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String errCode = "";
	String errMsg = "";
	String orden_compra_no = request.getParameter("orden_compra_no");
	if(request.getParameter("errCode")!=null) errCode = request.getParameter("errCode");
	if(request.getParameter("errMsg")!=null) errMsg = request.getParameter("errMsg");

%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
	var mode = '<%=mode%>';
	var alerta = 'Guardado Satisfactoriamente!';
	if(mode=='add') alerta += ' Año | No. Orden Compra = <%=orden_compra_no%>';

<%
if (errCode.equals("1")){
%>
	alert(alerta);
<%

	if(fg != null && fg.trim().equals("EOC"))
	{%>
		window.opener.location = '<%=request.getContextPath()%>/compras/list_orden_compra_entrega.jsp?tipo=3';
	<%}else if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/compras/list_orden_compra_parcial.jsp")){
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/compras/list_orden_compra_parcial.jsp")%>';
<%
	} else {
%>
	window.opener.location = '<%=request.getContextPath()%>/compras/list_orden_compra_parcial.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(errMsg);
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
