<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.Item"%>
<%@ page import="issi.inventory.ConvDetails"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="ItemMgr" scope="page" class="issi.inventory.ItemMgr"/>
<jsp:useBean id="item" scope="session" class="issi.inventory.Item"/>
<jsp:useBean id="ajuArt" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="ajuArtKey" scope="session" class="java.util.Hashtable"/>
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
ItemMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();

StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String familyCode = request.getParameter("familyCode");
String classCode = request.getParameter("classCode");
String subClassCode = request.getParameter("subClassCode");
String codProveedorPrim = request.getParameter("codProveedorPrim");
String codProveedorSecu = request.getParameter("codProveedorSecu");
String productId = request.getParameter("productId");
//thebrain
String printBC = request.getParameter("printBC");
String qtyToPrint = request.getParameter("qtyToPrint");
String fg = request.getParameter("fg");
String wh = request.getParameter("wh");

String type = request.getParameter("type");
String key = "";
int lineNo = 0;
String change = request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
String codBarra = "";
String tabLabel = "";
String indTab = request.getParameter("indTab");
if(indTab == null) indTab = "0";
if(productId == null) productId = "";
if (printBC == null) printBC = "";
if (qtyToPrint == null) qtyToPrint = "1";

if (mode == null) mode = "add";
if (fg == null) fg = "INV";
if (wh == null) wh = "";
String minCarBarCode = "8";
try {minCarBarCode =java.util.ResourceBundle.getBundle("issi").getString("minCharBarCode");}catch(Exception e){ minCarBarCode = "8";}
if(minCarBarCode == null || minCarBarCode.trim().equals("")) minCarBarCode = "8";
String maxCharBarCode = "35";
try {maxCharBarCode =java.util.ResourceBundle.getBundle("issi").getString("maxCharBarCode");}catch(Exception e){ maxCharBarCode = "35";}
if(maxCharBarCode == null || maxCharBarCode.trim().equals("")) maxCharBarCode = "35";
String  barCodeEdit= "S";
try {barCodeEdit =java.util.ResourceBundle.getBundle("issi").getString("barCodeEdit");}catch(Exception e){ barCodeEdit = "S";}
if(barCodeEdit == null || barCodeEdit.trim().equals("")) barCodeEdit = "S";
String  afectaConta= "S";
try {afectaConta =java.util.ResourceBundle.getBundle("issi").getString("afectaConta");}catch(Exception e){ afectaConta = "S";}
if(afectaConta == null || afectaConta.trim().equals("")) afectaConta = "S";

if (mode.equalsIgnoreCase("add"))barCodeEdit = "S";
boolean viewMode = false;
if(mode.trim().equals("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		if (change == null)
		{
			item = new Item();
			session.setAttribute("item",item);
			ajuArt.clear();
			ajuArtKey.clear();
			item.setFamilyCode("");
			item.setClassCode("");
			item.setItemCode("0");
			if(fg.trim().equals("INV"))
			{
				item.setOther3("Y");
				item.setOther4("Y");
			}
						id = item.getItemCode();
						System.out.println(":::::::::::::::::::::::::::::::::::::::::  = "+item.getItemCode());
		}
	}
	else
	{
		if (change == null)
		{
		ajuArt.clear();
		ajuArtKey.clear();

		//if (productId == null) throw new Exception("El Articulo no es válido. Por favor intente nuevamente!");
		if (id == null) throw new Exception("El Articulo no es válido. Por favor intente nuevamente!");


		sbSql.append("select a.product_id as productId, a.compania as companyCode, a.cod_flia as familyCode, a.cod_clase as classCode, a.cod_articulo as itemCode, a.descripcion as description, a.itbm as payTax, nvl(a.cod_medida,' ') as unitCode, nvl(a.precio_venta,0.00) as salePrice, nvl(a.venta_sino,' ') as isSaleItem, nvl(a.consignacion_sino,'N') as isAppropiation, a.tipo as type, a.estado as status, nvl(a.tipo_material,' ') as typeMaterial, nvl(a.reuso,' ') as reuse, a.usuario_creacion as createdBy, a.usuario_modif as modifiedBy, a.fecha_creacion as creationDate, a.fecha_modif as modificationDate, nvl(a.grupo_dosis,0) as doseGroup, nvl(a.fuera_cuadrob,' ') as isOutsideCoreCadre, nvl(a.id_articulo,' ') as PAMDItemId, nvl(a.cod_hna,' ') as HNACode, a.cod_subclase as subClassCode, a.cod_ref as refCode, a.tech_descripcion as techDescription, nvl(a.cod_barra,'') as barCode, a.other1, a.other2,  decode(a.other3,'0','N',a.other3)other3, decode(a.other4,'0','N',a.other4)other4, a.other5");
		sbSql.append(", (select nombre from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as familyName");
		sbSql.append(", (select descripcion from tbl_inv_clase_articulo where cod_clase = a.cod_clase and cod_flia = a.cod_flia and compania = a.compania) as className");
		sbSql.append(", (select descripcion from tbl_inv_subclase where compania = a.compania and cod_flia = a.cod_flia and cod_clase = a.cod_clase and subclase_id = a.cod_subclase) as subClassName");
		if (fg.equalsIgnoreCase("CTRL")) {
			sbSql.append(", ");
			sbSql.append(wh);
			sbSql.append(" as warehouseCode, (select precio from tbl_inv_inventario where codigo_almacen = ");
			sbSql.append(wh);
			sbSql.append(" and compania = a.compania and cod_articulo = a.cod_articulo) as costPerStock");
		} else {
			sbSql.append(", (select min(codigo_almacen) from tbl_inv_inventario where compania = a.compania and cod_articulo = a.cod_articulo) as warehouseCode");
			sbSql.append(", (select precio from tbl_inv_inventario where codigo_almacen = (select min(codigo_almacen) from tbl_inv_inventario where compania = a.compania and cod_articulo = a.cod_articulo) and compania = a.compania and cod_articulo = a.cod_articulo ) as costPerStock");
		}
		sbSql.append(", decode((select count(*) from tbl_inv_inventario where compania = a.compania and cod_articulo = a.cod_articulo),0,'N','S') as addToInventory, nvl(a.mostrar_fecha_vence, 'N') mostrarFechaVence");
		sbSql.append(" ,decode(a.foto,null,' ','");
		sbSql.append(java.util.ResourceBundle.getBundle("path").getString("articulosimage").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),".."));
		sbSql.append("/'||a.foto) as foto, nvl(a.foto,' ') as marcaDesc, nvl(a.excepcion_costo, 'N') excepcionCosto, (select nvl(costo_cero,'N') from tbl_inv_familia_articulo where cod_flia = a.cod_flia and compania = a.compania) as other6, nvl(implantable, 'N') implantable, modelo, fabricante, marca, nombre_generico as nombreGenerico  ");
		sbSql.append(" from tbl_inv_articulo a where a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.cod_articulo = ");
		sbSql.append(id);
		System.out.println("#########################################"+sbSql);

		item = (Item) sbb.getSingleRowBean(ConMgr.getConnection(), sbSql.toString(), Item.class);
		//familyCode = item.getFamilyCode();
		//classCode  = item.getClassCode();
		//subClassCode  = item.getSubClassCode();
		//productId = item.getProductId();
		//id = item.getItemCode();
		codBarra = item.getBarCode();
		//if(item.getType().equals("B") || item.getType().equals("K"))
		//{
			sbSql = new StringBuffer();
			sbSql.append("select a.compania, a.cod_flia artCodFlia, a.cod_clase artCodClase, a.cod_articulo artCodArticulo, a.cantidad, b.descripcion articulo from tbl_inv_art_contenido a, tbl_inv_articulo b where a.compania = b.compania and a.cod_articulo = b.cod_articulo and a.compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(" and a.cod_articulo_b = ");
			sbSql.append(item.getItemCode());
			System.out.println("items=\n"+sbSql);
			item.setKBDetails(sbb.getBeanList(ConMgr.getConnection(), sbSql.toString(), ConvDetails.class));
			for(int i=0;i<item.getKBDetails().size();i++)
			{
				ConvDetails it = (ConvDetails) item.getKBDetails().get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;

				try
				{
					ajuArt.put(key, it);
					ajuArtKey.put(it.getArtCodFlia()+"-"+it.getArtCodClase()+"-"+it.getArtCodArticulo(), key);
				}	catch (Exception e)
				{
					System.out.println("Unable to addget item "+key);
				}
			}
		//}

		if ((item.getIsAppropiation().equalsIgnoreCase("S") && item.getReuse().equalsIgnoreCase("S")) || item.getAddToInventory().equalsIgnoreCase("S"))
		{
//		  al = sbb.getBeanList(ConMgr.getConnection(), "select compania as companyCode, art_familia as familyCode, art_clase as classCode, cod_articulo as itemCode, codigo_almacen as warehouseCode from tbl_inv_inventario where compania="+(String) session.getAttribute("_companyId")+" and cod_articulo="+id+" group by compania, art_familia, art_clase, cod_articulo", Item.class);
		}
	}//else
	}//change null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title="Artículo - "+document.title;
var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();<%if(type!=null && type.equals("1")){%>var fg = '';  var codAlmacen = document.form1.warehouseCode.value;abrir_ventana1('../inventario/sel_articles_kb.jsp?mode=<%=mode%>&fg='+fg+'&fp=articles&codAlmacen='+codAlmacen+'&id=<%=id%>&familyCode=<%=familyCode%>&classCode=<%=classCode%>&subClassCode=<%=subClassCode%>&codProveedorPrim<%=codProveedorPrim%>&codProveedorSecu<%=codProveedorSecu%>');<%}if (!printBC.equals("")){%>printBarcode("<%=printBC%>");<%}%>}
function resizeFrame(){resetFrameHeight(document.getElementById('itemFrame'),xHeight,400);}

//function doAction(){setHeight('itemFrame',150);}
function getClassList(){var familia = document.form1.familyCode.value;abrir_ventana('../inventario/list_subclase.jsp?mode=<%=mode%>&familia='+familia);}
function setWarehouseDetails(costo){document.form1.costPerStock.value=costo;}
function checkCostPrice(){
	//if(!document.form1.isAppropiation.disabled&&document.form1.isAppropiation.checked){
		if(document.form1.costoCero.value =='N'){
		if(isNaN(document.form1.costPerStock.value)||document.form1.costPerStock.value==''||parseFloat(document.form1.costPerStock.value)<=0.00){
			alert('Costo Inválido!');document.form1.costPerStock.focus();return false;
		}}
	//}
	if(!document.form1.isSaleItem.disabled&&document.form1.isSaleItem.checked /*&& document.form1.regalia.checked*/){
		if(isNaN(document.form1.salePrice.value)||document.form1.salePrice.value==''||parseFloat(document.form1.salePrice.value)<0.00){
			alert('Precio Inválido!');document.form1.salePrice.focus();return false;
		}else if(<%=item.getItemCode()%>>=0){
			if(parseFloat(document.form1.salePrice.value)<=parseFloat(document.form1.costPerStock.value)){
				alert('El Precio no puede ser menor o igual que el Costo!');document.form1.salePrice.focus();return false;
			}
		}
	}
	return true;
}
function verificarCliente(){var wh = document.form1.warehouseCode.value;var chk_axa = '';if(document.form1.checkAxa)document.form1.checkAxa.value;var flia = document.form1.familyCode.value;var precio = 0;var x=0;if(flia == 1){<%if(!mode.trim().equals("add")){%>var clase = document.form1.classCode.value;var code = document.form1.itemCode.value;if (wh ==""){if(document.form1.checkAxa)document.form1.checkAxa.value='N';if(document.form1.checkAxa)document.form1.checkAxa.checked = false;alert('No puede procesar artículo, hasta que tenga almacén designado...');x++;}precio = parseFloat(getDBData('<%=request.getContextPath()%>','nvl(precio,0)','tbl_inv_inventario','art_familia='+flia+' and art_clase='+clase+' and cod_articulo = '+code+' and codigo_almacen = '+wh+' and compania = <%=compania%>',''));if(isNaN(precio)) precio =0;if((document.form1.checkAxa) && document.form1.checkAxa.checked == true && precio==0 ){document.form1.checkAxa.value='I';document.form1.checkAxa.checked = false;alert('El articulo no tiene precio...');x++;}<%}%>}else{alert('Sólo para medicamentos...');document.form1.checkAxa.value='N';document.form1.checkAxa.checked = false;}if(x==0){return true;}else{return false;}}
function check(val){
	if(val=='C'){
		if(!document.form1.isAppropiation.disabled){
			<% if (mode.equalsIgnoreCase("add")) { %>if(document.form1.isAppropiation.checked){
				if(getDBData('<%=request.getContextPath()%>','case when (select nvl(get_sec_comp_param(<%=compania%>,\'INV_CHK_FLIA_CONSIG\'),\'N\') from dual) in (\'Y\',\'S\') then \'Y\' else \'N\' end','dual','','')=='Y'&&(document.form1.familyCode.value==''||getDBData('<%=request.getContextPath()%>','nvl(consignacion,\'N\')','tbl_inv_familia_articulo','cod_flia='+document.form1.familyCode.value+' and compania = <%=compania%>','')=='N')){alert('Debe seleccionar una Familia de Consignación!');document.form1.isAppropiation.checked=false;}
				/*document.form1.costPerStock.readOnly=false;document.form1.costPerStock.className='FormDataObjectRequired';*/document.form1.costPerStock.focus();
			}<% } %>
		}else{
			document.form1.costPerStock.readOnly=true;document.form1.costPerStock.className='FormDataObjectDisabled';document.form1.costPerStock.value=document.form1.costPerStockInit.value;
		}
	}else if(val=='V'){
		if(!document.form1.isSaleItem.disabled&&document.form1.isSaleItem.checked){
			<% if (mode.equalsIgnoreCase("add")) { %>document.form1.salePrice.readOnly=false;document.form1.salePrice.className='FormDataObjectEnabled';document.form1.salePrice.focus();<% } %>
		}else{
			document.form1.salePrice.readOnly=true;document.form1.salePrice.className='FormDataObjectDisabled';document.form1.salePrice.value=document.form1.salePriceInit.value;
		}
	}
}
function buscaProv(){abrir_ventana2('../compras/sel_proveedor.jsp?fp=PR');}
function buscaPro1(){abrir_ventana2('../compras/sel_proveedor.jsp?fp=SE');}
function doSubmitArt(){if (!form1Validation()) return false;else document.form1.submit();}
function doSubmit(value){window.frames['itemFrame'].doSubmit(value);}
function changePrice(){if(!document.form1.isSaleItem.disabled&&document.form1.isSaleItem.checked){document.form1.salePrice.readOnly=false;document.form1.salePrice.className='FormDataObjectEnabled';document.form1.salePrice.focus();}}

function printBarcode(printExpress){
	var mode = "<%=mode%>";
	var printBC = document.getElementById("printBC").value;
	var barCode = document.getElementById("barCodeOld").value;
	var tipo = document.getElementById("type").value;
	var qtyToPrint = document.getElementById("qtyToPrint").value;

	if ((mode!="add" && document.getElementById("printBC").checked==true)||(typeof printExpress != "undefined" && tipo!="A" && barCode != "")){if (barCode !="" && tipo!="A"){
	barCode = encodeURIComponent(Aes.Ctr.encrypt("<%=codBarra%>",'barCode',256));
	abrir_ventana('../inventario/print_rep_placa.jsp?fp=articulos&barCode='+barCode+'&qtyToPrint='+qtyToPrint);}}

	}
/**
* Permite solamente dígitos de 0 a 9
* @param: evt (El evento onkeypress)
* return boolean
*/
function allowNumericOnly(evt){if (window.event){var charCode = (evt.which) ? evt.which : event.keyCode;if (charCode > 31 && (charCode < 48 || charCode > 57)){return false;}}else if(evt.which){var charCode = (evt.which) ? evt.which : event.keyCode;if (charCode > 31 && (charCode < 48 || charCode > 57)){return false;}}return true;}
function validateBC(){
	var type = document.getElementById("type").value;
	var bcObj = document.getElementById("barCode");
	var flag = true;var mode = "<%=mode%>";
	if (type=="A"){
		bcObj.value = "";
		bcObj.readOnly = true;
		bcObj.className = 'FormDataObjectDisabled';
		flag = true;
		return true;
	}else{
		bcObj.readOnly = false;
		bcObj.className = 'FormDataObjectEnabled';
		if (bcObj.value != ""){
			var codBar = getGS1BarcodeData('<%=request.getContextPath()%>',replaceAll(bcObj.value,"\'","\'\'"),'01');
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',bcObj,'tbl_inv_articulo','cod_barra=\''+codBar+'\' and compania=<%=compania%>','<%=(item.getBarCode()!=null)?item.getBarCode().trim().replaceAll("'","\\\\'"):""%>')){
				alert("El código de barra Ya existe !");
				document.form1.barCode.value = '';
				flag = false;
				return false;
			}else if (bcObj.value.length < parseInt(<%=minCarBarCode%>)){
				alert("El código de barra debe ser mayor a <%=minCarBarCode%> carácteres!");
				flag = false;
				return false;
			}else{ flag = true; return true;}
		} else return true;
 }
}
function chkItbm(){	if(document.form1.payTax.checked){document.form1.other5.readOnly = false;} else {document.form1.other5.readOnly = true;document.form1.other5.value = 0;}}

function tabFunctions(tab){
	var iFrameName = 'itemFrame';
	if(tab==1){
		if(window.frames[iFrameName])window.frames[iFrameName].doAction();
	}
}

$(document).on("keypress", "form", function(event) {
		return event.keyCode != 13;
});

function chkDisponible(){
	var codigo = document.form1.id.value;
	var wh = document.form1.warehouseCode.value;
	var estado = document.form1.status.value;

	var disp = parseInt(getDBData('<%=request.getContextPath()%>','disponible','tbl_inv_inventario','cod_articulo = '+codigo+' and codigo_almacen = '+wh+' and compania = <%=compania%>',''));
	if(disp>0 && estado == 'I'){
		alert('El artículo tiene disponibilidad y no se puede inactivar!');
		return false;
	} else if(disp<0 && estado == 'I'){
		alert('El artículo tiene disponibilidad negativa y no se puede inactivar!');
		return false;
	} else return true;
}

function validCostPrice(){
	if(document.form1.costoCero.value =='N'){
		if(isNaN(document.form1.costPerStock.value)||document.form1.costPerStock.value==''||parseFloat(document.form1.costPerStock.value)<=0.00){
				alert('Costo Inválido!!');
				document.form1.costPerStock.focus();
				return false;
		}
		}
		return true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ARTICULOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0" id="_tblMain">
	<tr>
		<td class="TableBorder"><div id="dhtmlgoodies_tabView1">
				<!--GENERALES TAB0-->
				<!-- ARTICULO -->
				<div class="dhtmlgoodies_aTab">
					<table align="center" width="99%" cellpadding="0" cellspacing="0">

						<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%//fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("id",id)%>
	<%=fb.hidden("clearHT","")%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("consignacion",item.getIsAppropiation())%>
	<%=fb.hidden("itbm",item.getPayTax())%>
	<%=fb.hidden("addInv",item.getAddToInventory())%>
	<%=fb.hidden("reuso",item.getReuse())%>
	<%=fb.hidden("saleItem",item.getIsSaleItem())%>
	<%=fb.hidden("productId",item.getProductId())%>
	<%=fb.hidden("barCodeOld",item.getBarCode())%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("wh",wh)%>
	<%=fb.hidden("costoCero",""+item.getOther6())%>

	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
	</tr>
		<tr class="TextRow01">
			<td width="15%">Familia</td>
			<td width="35%">
			<%=fb.intBox("familyCode",item.getFamilyCode(),true,false,true,5)%>
			<%=fb.textBox("familyName",item.getFamilyName(),false,false,true,40)%>
			</td>

			<td width="15%">Clase</td>
			<td width="35%">
			<%=fb.intBox("classCode",item.getClassCode(),true,false,true,5)%>
			<%=fb.textBox("className",item.getClassName(),false,false,true,40)%>
			</td>
			</tr>

		<tr class="TextRow01">
			<td width="15%">SubClase</td>
			<td width="35%">
			<%=fb.intBox("subClassCode",item.getSubClassCode(),true,false,true,5)%>
			<%=fb.textBox("subClassName",item.getSubClassName(),false,false,true,40)%>

			<%//if (mode.equalsIgnoreCase("add"))	{%>
			<%=fb.button("selectClass","...",false,viewMode,null,null,"onClick=\"javascript:getClassList()\"")%>
			<%//}	%>
			</td>



			<td>Codigo Ref.</td>
			<td><%=fb.textBox("refCode",item.getRefCode(),false,false,false,40,50)%></td>

		</tr>

		<tr class="TextRow01" >
			<td>C&oacute;digo</td>
			<td><%=fb.intBox("itemCode",id,false,false,true,10)%></td>
			<td>Nombre</td>
			<td><%=fb.textBox("description",item.getDescription(),true,false,false,40,2000)%></td>
		</tr>
		<tr class="TextRow01" >
			<td>Unidad de Medida</td>
			<td>
			<%=fb.select(ConMgr.getConnection(),"select cod_medida, cod_medida||' - '||descripcion as descripcion from tbl_inv_unidad_medida where status = 'A' order by cod_medida","unidadMedCode",item.getUnitCode(),true,false,false,0,null,null,null,null,"S")%>
			</td>
			<td>Estado</td>
			<td><%=fb.select("status","A=Activo,I=Inactivo",item.getStatus())%></td>
		</tr>
		<!--onChange=\"javascrip:_showHide(0,this.value);\"-->
		<tr class="TextRow01">
			<td>Tipo de Art&iacute;culo</td>
			<td><%=fb.select("type","N=Normal,A=Activo,K=Kit,B=Bandeja",item.getType(), false, false, 0, "", "", "onChange=\"validateBC()\"")%></td>
			<td>Unidad de Medida Compra</td>
			<td><%=fb.select(ConMgr.getConnection(),"select cod_medida, cod_medida||' - '||descripcion as descripcion from tbl_inv_unidad_medida where status = 'A' order by cod_medida","other1",item.getOther1(),true,false,false,0,null,null,null,null,"S")%></td>
		</tr>

			<tr class="TextRow01">
			<td>Codigo Barra</td>
			<td><%=fb.textBox("barCode",item.getBarCode(),false,false,(!barCodeEdit.equalsIgnoreCase("S"))?true:false,25,Integer.parseInt(maxCharBarCode),null,null,"onChange=\"validateBC()\"","",false)%>&nbsp;&nbsp;
					 Imprimir
				 <%=fb.textBox("qtyToPrint",qtyToPrint,false,false,false,4,4,null,null,"onkeypress=\"return allowNumericOnly(event)\"; onFocus=\"this.select();\" onpaste=\"return false;\" ","Cantidad de copia",false)%>
				 &nbsp;&nbsp;Copia(s)?&nbsp;&nbsp;
				 <%=fb.checkbox("printBC","S",false,false ,null,null,"onClick=\"javascript:printBarcode()\"")%>
			</td>
			<td>Cant. por Medida de Compra</td>
			<td><%=fb.intBox("other2",item.getOther2(),true,false,false,10,10)%>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			Mostrar Fecha Vence?:
			<%=fb.select("mostrar_fecha_vence","S=SI,N=NO",item.getMostrarFechaVence(), false, false, 0, "", "", "")%>
			</td>
		</tr>
		<!--<tr class="TextRow01">
			<!--<td>Proveedor Primaria</td>-->

			<!--<td><%//=fb.intBox("codProveedorPrim",item.getCodProveedorPrim(),true,false,true,5,null,null,"")%>
				<%//=fb.textBox("desProveedorPrim",item.getDesProveedorPrim(),true,false,true,40,null,null,"")%>
				 <%//=fb.button("buscar","Buscar",false,false,"","","onClick=\"javascript:buscaProv()\"")%></td>-->
					<!--<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>-->
			<!--<td>Proveedor Secundaria</td>
			<td><%//=fb.intBox("codProveedorSecu",item.getCodProveedorSecu(),true,false,true,5,null,null,"")%>
				<%//=fb.textBox("desProveedorSecu",item.getDesProveedorSecu(),false,false,true,40,null,null,"")%>
				<%//=fb.button("buscar","Buscar",false,false,"","","onClick=\"javascript:buscaPro1()\"")%></td>
		</tr>-->
		<!--<%if(compania.trim().equals("5")){%>
		<tr class="TextRow01">
			<td>Grupo Dosis</td>
<td>
<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_sal_grupo_dosis order by descripcion ","grupoDosis",item.getDoseGroup(),false,false,0,"S")%>
</td>
<td colspan="2">Cliente AXA ???<%=fb.checkbox("checkAxa","A",(item.getClienteAxa() != null && item.getClienteAxa().equalsIgnoreCase("A")),false,null,null,"onClick=\"javascript:verificarCliente()\"")%></td>
		</tr>
		<%}
		%>-->
		<tr>
			<tr class="TextRow01">
			<td>Tech. Descripcion</td>
			<td colspan="2"><%=fb.textarea("techDescription",item.getTechDescription(),false,false,false,85,4,2000)%></td>
			<td><%//=item.getFoto()%>
			<!-- <%
			String  disp = "";
			String hidden = "";
			boolean hasPic = false;

			if (item.getMarcaDesc()!= null && !item.getMarcaDesc().trim().equals("")){
									disp = "style=\"display:none;\"";
								hasPic = true;
								hidden = item.getFoto();
							}else{
								 disp = "style=\"display:'';\"";
								 hasPic = false;
								 hidden = "";
							}
						%>
						<%=fb.hidden("has_pic",""+hasPic)%>
						<%//=(hasPic?fb.button("show_btn"+hidden,"+",true,viewMode,null,"","onClick=\"show('"+hidden+"')\"","Agregar imágen"):"")%>
							<span id="lb_hidden<%=hidden%>" <%=disp%>>&nbsp;&nbsp;&nbsp;<cellbytelabel id="11">Foto</cellbytelabel><%=fb.fileBox("foto",item.getFoto(),false,false,15,"","","")%></span><%=fb.fileBox("foto2",item.getFoto(),false,false,15,"","","")%>
			<img src="../images/search.gif" id="scan" width="20" height="20" onClick="javascript:showImage()"/>-->

			<!--<img src="../images/search.gif" id="scan" width="20" height="20" onClick="javascript:showPopWin('../common/abrir_ventana.jsp?fileName=<%=item.getFoto()%>',winWidth*.75,winHeight*.65,null,null,'')" style="cursor:pointer; display:inline; vertical-align:middle;" title="<%=item.getMarcaDesc()%>"/>&nbsp;&nbsp;<%=item.getMarcaDesc()%>&nbsp;&nbsp;-->

			<%=fb.fileBox("foto",item.getFoto(),false,viewMode,20,"","","")%><%=item.getMarcaDesc()%>






			</td>
		</tr>

		<%if(fg.trim().equals("CONT")||afectaConta.equals("S")){%>
		<tr class="TextRow01">
			<td><authtype type='51'>Afecta Inventario:</authtype></td>
			<td><authtype type='51'><%=fb.select("other3","Y=Si,N=No",item.getOther3(), false, false, 0, "", "", "")%></authtype></td>
			<td><authtype type='52'>Afecta Contabilidad:</authtype></td>
			<td><authtype type='52'><%=fb.select("other4","Y=Si,N=No",item.getOther4(), false, false, 0, "", "", "")%></authtype></td>
		</tr>
		<%}else{%>
		<%=fb.hidden("other3",item.getOther3())%>
		<%=fb.hidden("other4",item.getOther4())%>
		<%}%>


<td colspan="4">
	<table width="100%" cellpadding="0" cellspacing="1">
		<tr class="TextRow01">
			<td width="20%">
			ITBM <%=fb.checkbox("payTax","S",(item.getPayTax() != null && item.getPayTax().trim().equalsIgnoreCase("S")),false,"","","onClick=\"javascript:chkItbm();\"")%>
			<%=fb.intBox("other5",item.getOther5(),false,false,(item.getPayTax() != null && item.getPayTax().trim().equalsIgnoreCase("N")),2,2)%>
			</td>
			<td width="20%">Consig.
			<%=fb.checkbox("isAppropiation",((mode.equalsIgnoreCase("add"))?"S":item.getIsAppropiation()),(item.getIsAppropiation() != null && item.getIsAppropiation().equalsIgnoreCase("S")),!mode.equalsIgnoreCase("add")/*(mode.equalsIgnoreCase("edit") && item.getIsAppropiation() != null && item.getIsAppropiation().equalsIgnoreCase("S"))*/,null,null,"onClick=\"javascript:check('C')\"")%></td>


			<%//if(compania.trim().equals("5")){%>

			<td width="20%">
			Excepci&oacute;n Costo:
			<%=fb.select("excepcion_costo","N=No,S=Si",item.getExcepcionCosto(), false, false, 0, "", "", "")%>
			<!--Ing. Inv. <%=fb.checkbox("addToInventory","S",true,false,null,null,"onClick=\"javascript:check('C')\"")%>
			Fra. CBasico <%=fb.checkbox("isOutsideCoreCadre","S",(item.getIsOutsideCoreCadre() != null && item.getIsOutsideCoreCadre().equalsIgnoreCase("S")),false /*(mode.equalsIgnoreCase("edit"))*/,null,null,"")%>--></td>

			<%//}//else{%>


			<!--<td width="20%">Ing. Inv. <%//=fb.checkbox("addToInventory","S",true,false /*(mode.equalsIgnoreCase("edit"))*/,null,null,"onClick=\"javascript:check('C')\"")%></td>-->
			<%//}%>
				<td width="20%">&nbsp;
				<!---Reusar <%=fb.checkbox("reuse","S",(item.getReuse() != null && item.getReuse().trim().equalsIgnoreCase("S")),false /*(mode.equalsIgnoreCase("edit"))*/,null,null,"onClick=\"javascript:check('C')\"")%>-->&nbsp;
				</td>
			<td width="20%">Ventas <%=fb.checkbox("isSaleItem","S",(item.getIsSaleItem() != null && item.getIsSaleItem().trim().equalsIgnoreCase("S")),false /*(!mode.equalsIgnoreCase("add"))*/,null,null,"onClick=\"javascript:check('V')\"")%></td>
		</tr>

		<!-- MINSA -->
		<tr class="TextRow01">
			<td width="20%">Implantable?&nbsp;<%=fb.checkbox("implantable","S",(item.getImplantable() != null && item.getImplantable().trim().equalsIgnoreCase("S")),false ,null,null,"")%>
			</td>
			<td width="20%">Modelo:&nbsp;<%=fb.textBox("modelo",item.getModelo(),false,false,false,30,100)%>
			</td>
			<td width="20%">Fabricante:&nbsp;<%=fb.textBox("fabricante",item.getFabricante(),false,false,false,30,100)%>
				
			</td>
			<td width="20%"><!--Marca:-->&nbsp;<%//=fb.textBox("marca",item.getMarca(),false,false,false,30,100)%></td>
			<td width="20%">Nombre Gen&eacute;rico:&nbsp;<%=fb.textBox("nombre_generico",item.getNombreGenerico(),false,false,false,30,100)%>				
			</td>
		</tr>
		<!-- /MINSA -->

		<tr class="TextRow01">
			<td colspan="3">
			Almac&eacute;n
			<%=fb.select(ConMgr.getConnection(),"select codigo_almacen, codigo_almacen||' - '||descripcion, "+((mode.equalsIgnoreCase("add"))?"0":"nvl((select precio from tbl_inv_inventario where compania = "+item.getCompanyCode()+" and cod_articulo = "+item.getItemCode()+" and art_familia = "+item.getFamilyCode()+" and art_clase = "+item.getClassCode()+" and codigo_almacen = z.codigo_almacen),0)")+" as precio from tbl_inv_almacen z where compania = "+session.getAttribute("_companyId")+(UserDet.getUserProfile().contains("0")?"":" and codigo_almacen in ("+CmnMgr.vector2numSqlInClause((Vector) session.getAttribute("_almacen_ua"))+")")+" order by descripcion","warehouseCode",item.getWarehouseCode(),true,false,(fg.equalsIgnoreCase("CTRL")),0,"Text10","","")%><%//"onChange=\"javascript:setWarehouseDetails(this.options[this.selectedIndex].title);\""%>
			</td>
			<td>
			Costo
			<%=fb.decBox("costPerStock",item.getCostPerStock(),true,false,!mode.equalsIgnoreCase("add"),20,"11.10")%>
			<%=fb.hidden("costPerStockInit",item.getCostPerStock())%>
			</td>
			<td>
			<%=fb.decBox("salePrice",item.getSalePrice(),false,false,true,5,"10.4",null,null,"onChange=\"javascript:checkCostPrice()\"")%>
			<%=fb.hidden("salePriceInit",item.getSalePrice())%>
			<authtype type='50'><%=fb.button("chPrice","Modificar Precio",false,(mode.equalsIgnoreCase("add")||viewMode),null,null,"onClick=\"javascript:changePrice()\"")%></authtype>
			</td>
		</tr>
	</table>
</td>
		</tr>
		<%
		String display = "";
		if(item.getType().equals("K") || item.getType().equals("B")) display = "";
		//onClick=\"javascript: return(doSubmit());\"
		%>
		<tr id="panel0" style="display:<%=display%>">
			<td colspan="5">
				<table width="100%" align="center">
					<tr class="TextHeader" align="center">
						<td colspan="6" align="right"><%=fb.submit("addArticles","Articulos Para Kit/Bandeja",false,false,"", "","onClick=\"javascript:document."+fb.getFormName()+".baction.value=this.value;\"", "Articulos Para Kit/Bandeja")%></td>
					</tr>
					<tr class="TextHeader" align="center">
						<td colspan="3">C&oacute;digo</td>
						<td rowspan="2" width="36%">Descripci&oacute;n</td>
						<td rowspan="2" width="9%">Cantidad</td>
						<td rowspan="2" width="2%">&nbsp;</td>
					</tr>
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
						ConvDetails ad = (ConvDetails) ajuArt.get(key);
						String color = "";

						if (i%2 == 0) color = "TextRow02";
						else color = "TextRow01";
					%>
					<%=fb.hidden("cod_familia"+i,ad.getArtCodFlia())%>
					<%=fb.hidden("cod_clase"+i,ad.getArtCodClase())%>
					<%=fb.hidden("cod_articulo"+i,ad.getArtCodArticulo())%>
					<%=fb.hidden("articulo"+i,ad.getArticulo())%>
					<%=fb.hidden("delx"+i,"")%>
					<%//=fb.hidden("consignacion"+i,ad.getConsignacionSN())%>
					<tr class="<%=color%>" align="center">
						<td><%=ad.getArtCodFlia()%></td>
						<td><%=ad.getArtCodClase()%></td>
						<td><%=ad.getArtCodArticulo()%></td>
						<td align="left"><%=ad.getArticulo()%></td>
						<td><%=fb.intBox("cantidad"+i,ad.getCantidad(),false,false,false,5)%></td>
						<td align="center"><%=fb.submit("del"+i,"X",false,false,"","","onClick=\"javascript:document."+fb.getFormName()+".baction.value=this.value;document."+fb.getFormName()+".delx"+i+".value='X'\"","")%></td>
					</tr>
				<%
				}

				%>
				<%=fb.hidden("keySize",""+ajuArt.size())%>
				</table>
		</tr>
		<tr class="TextRow02">
										<td colspan="4" align="right">
										Opciones de Guardar:
										<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro
										<%//=fb.radio("saveOption","O",true,false,false)%>
					<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
										<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
										
										<%if(fg.trim().equals("FAR")){%>
									<%=fb.button("save","Guardar",true,true,null,null,"onClick=\"javascript:document."+fb.getFormName()+".baction.value=this.value;doSubmitArt()\"")%>
								<%}else{%>
									<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:document."+fb.getFormName()+".baction.value=this.value;doSubmitArt()\"")%>
								<%}%>
					<%//=fb.submit("save","Guardar",true,false)%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
										</td>
									</tr>
									<tr>
										<td colspan="4">&nbsp;</td>
									</tr>
									<%
									fb.appendJsValidation("\n\tif (!checkCostPrice()) error++;\n");
									fb.appendJsValidation("\n\tif (!validCostPrice()) error++;\n");
									if(mode.trim().equals("add")){fb.appendJsValidation("\n\tif (!validateBC()) error++;\n");}
									if(mode.trim().equals("edit")){fb.appendJsValidation("\n\tif (!chkDisponible()) error++;\n");}
									%>
									<%=fb.formEnd(true)%>
									<!-- ================================   F O R M   E N D   H E R E   ================================ -->
								</table>
				</td>
					</table>
				</div>
				<div class="dhtmlgoodies_aTab">
					<table align="center" width="99%" cellpadding="5" cellspacing="1">
					<tr>
						<td class="TableBorder">
							<table align="center" width="100%" cellpadding="0" cellspacing="0">
							<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
							<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
							<%=fb.formStart(true)%>
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("id",id)%>
							<%=fb.hidden("indTab","1")%>
							<%=fb.hidden("baction","")%>
							<%=fb.hidden("familia","")%>
							<%=fb.hidden("clase","")%>
							<%=fb.hidden("articulo","")%>
							<%=fb.hidden("fg",fg)%>
							<tr>
								<td>&nbsp;</td>
							</tr>
							<tr class="TextRow02">
								<td>&nbsp;</td>
							</tr>
							<tr class="TextHeader">
								<td><% if (fg.equalsIgnoreCase("CTRL")) { %>Almac&eacute;n / Anaquel<% } else { %>Art&iacute;culos por Proveedor<% } %></td>
							</tr>
							<tr>
								<td>
									<table width="100%" cellpadding="1" cellspacing="0">
									<tr class="TextPanel" onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
										<td width="95%">&nbsp;Detalle</td>
										<td width="5%" align="right">[<font face="Courier New, Courier, mono">
											<label id="plus1" style="display:none">+</label>
											<label id="minus1">-</label>
											</font>]&nbsp;</td>
									</tr>
									<tr id="panel1">
										<td colspan="2"><% if (fg.equalsIgnoreCase("CTRL")) { %><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../inventario/articulo_anaquel.jsp?fg=<%=fg%>&id=<%=id%>"></iframe><% } else { %><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="200px" scrolling="yes" src="../inventario/reg_art_x_prov.jsp?product_id=<%=item.getProductId()%>&fg=<%=fg%>"></iframe><% } %></td>
									</tr>
									</table>
								</td>
							</tr>
							<tr class="TextRow02">
								<td align="right">
								<%if(fg.trim().equals("FAR")){%>
									
									<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
								<%}else{%>
									<%=fb.button("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
								<%}%>
									<%//=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
									<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
							</tr>
							<tr>
								<td>&nbsp;</td>
							</tr>
							<%=fb.formEnd(true)%>
							<!-- ================================   F O R M   E N D   H E R E   ================================ -->
							</table>
						</td>
					</tr>
					</table>
			</div>
			</div>
			<script type="text/javascript">
<%
if(mode.equals("add")) tabLabel = "'Articulo'";
else if (fg.equalsIgnoreCase("CTRL")) tabLabel = "'Articulo','Almac&eacute;n / Anaquel'";
else tabLabel = "'Articulo','Art. por Proveedor'";
String tabFunctions = "'1=tabFunctions(1)'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=indTab%>,'100%','',null,null,Array(<%=tabFunctions%>),null);
</script>
		</td>
	</tr>
</table>

</body>
</html>
<%
}//GET
else
{
System.out.println(":::::::::::::::::::::::::::::::::: SUBMITTING...");
Hashtable ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("articulosimage"),20);
String saveOption = (String) ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
String clearHT = (String) ht.get("clearHT");
	mode = (String) ht.get("mode");
	fg = (String) ht.get("fg");
	wh = (String) ht.get("wh");
String dl = "";
item.getKBDetails().clear();
item.setCompanyCode((String) session.getAttribute("_companyId"));
item.setFamilyCode((String) ht.get("familyCode"));
item.setFamilyName((String) ht.get("familyName"));
item.setClassCode((String) ht.get("classCode"));
item.setClassName((String) ht.get("className"));
item.setProductId((String) ht.get("productId"));
item.setItemCode((String) ht.get("id"));
item.setFoto((String) ht.get("foto"));

//item.setMarcaId(request.getParameter("marcaId"));
//item.setBarCode(request.getParameter("barCode"));
item.setRefCode((String) ht.get("refCode"));
if((((String) ht.get("techDescription")) == null) || ((String) ht.get("techDescription")).trim().equals(""))item.setTechDescription(" ");
else item.setTechDescription((String) ht.get("techDescription"));

item.setSubClassCode((String) ht.get("subClassCode"));
item.setSubClassName((String) ht.get("subClassName"));

item.setDescription((String) ht.get("description"));

if ((String) ht.get("payTax")== null) item.setPayTax("N");
else item.setPayTax((String) ht.get("payTax"));
item.setUnitCode((String) ht.get("unidadMedCode"));
item.setSalePrice((String) ht.get("salePrice"));

if ((String) ht.get("isSaleItem") == null) item.setIsSaleItem("N");
else item.setIsSaleItem((String) ht.get("isSaleItem") );

System.out.println("-------------------------> consignacino = "+ht.get("isAppropiation"));
if ((String) ht.get("isAppropiation") == null || ((String) ht.get("isAppropiation")).trim().equals(""))  item.setIsAppropiation("N");
else item.setIsAppropiation((String) ht.get("isAppropiation"));

item.setType((String) ht.get("type"));
item.setStatus((String) ht.get("status"));
item.setTypeMaterial((String) ht.get("typeMaterial"));
item.setCreatedBy((String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
item.setModifiedBy((String) session.getAttribute("_userName"));//UserDet.getUserEmpId()
if ((String) ht.get("addToInventory") == null) item.setAddToInventory("");
item.setAddToInventory("S");

if ((String) ht.get("nit_number")== null) item.setNitNumber("");
else item.setNitNumber((String) ht.get("nit_number"));

item.setBarCode((((String) ht.get("barCode"))==null || ((String) ht.get("type")).equals("A"))?"":(String) ht.get("barCode"));

codBarra =(String) ht.get("barCode");
item.setBarCodeRefer( (((String) ht.get("barCode")==null )|| ((String) ht.get("type")).equals("A"))?"":"RA");

item.setMarcaId((String) ht.get("marca_id"));
item.setSubclaseId((String) ht.get("subclase_id"));
item.setMarcaDesc((String) ht.get("marca_desc"));
item.setSubClassName((String) ht.get("subclase_desc"));

if((((String) ht.get("other1")) != null) && !((String) ht.get("other1")).trim().equals("")) item.setOther1((String) ht.get("other1"));else item.setOther1("null");
if((((String) ht.get("other2")) != null) && !((String) ht.get("other2")).trim().equals("")) item.setOther2((String) ht.get("other2"));else item.setOther2("null");
if((((String) ht.get("other3")) != null) && !((String) ht.get("other3")).trim().equals(""))item.setOther3((String) ht.get("other3"));else item.setOther3("Y");
if((((String) ht.get("other4")) != null) && !((String) ht.get("other4")).trim().equals(""))item.setOther4((String) ht.get("other4"));else item.setOther4("Y");
if((((String) ht.get("other5")) != null) && !((String) ht.get("other5")).trim().equals(""))item.setOther5((String) ht.get("other5"));
if((((String) ht.get("implantable")) != null) && !((String) ht.get("implantable")).trim().equals(""))item.setImplantable((String) ht.get("implantable"));
else item.setImplantable("N");
if((((String) ht.get("modelo")) != null) && !((String) ht.get("modelo")).trim().equals(""))item.setModelo((String) ht.get("modelo"));
else item.setModelo("");
if((((String) ht.get("fabricante")) != null) && !((String) ht.get("fabricante")).trim().equals(""))item.setFabricante((String) ht.get("fabricante"));
else item.setFabricante("");
if((((String) ht.get("marca")) != null) && !((String) ht.get("marca")).trim().equals(""))item.setMarca((String) ht.get("marca"));
else item.setMarca("");
if((((String) ht.get("nombre_generico")) != null) && !((String) ht.get("nombre_generico")).trim().equals(""))item.setNombreGenerico((String) ht.get("nombre_generico"));
else item.setNombreGenerico("");
/*Campos de los articulos de Farmacia Pamd */

		if(((String) ht.get("isOutsideCoreCadre")) == null) item.setIsOutsideCoreCadre("");
		else item.setIsOutsideCoreCadre((String) ht.get("isOutsideCoreCadre"));
		if (((String) ht.get("checkAxa")) == null) item.setClienteAxa("I");
		else item.setClienteAxa((String) ht.get("checkAxa"));

		if (((String) ht.get("grupoDosis")) == null) item.setDoseGroup("");
		else item.setDoseGroup((String) ht.get("grupoDosis"));


item.setCostPerStock((String) ht.get("costPerStock"));
item.setCost((String) ht.get("costPerStock"));
item.setLastCost((String) ht.get("costPerStock"));
item.setWarehouseCode((String) ht.get("warehouseCode"));
item.setMostrarFechaVence((String) ht.get("mostrar_fecha_vence"));
item.setExcepcionCosto((String) ht.get("excepcion_costo"));
item.setFg(fg);
if(fg.trim().equals("FAR"))item.setReplicadoFar("S");

	int size = Integer.parseInt((String) ht.get("keySize"));
	//ConDet.getConversionDetail().clear();
	ajuArt.clear();
	lineNo = 0;
	for (int i=0; i<size; i++)
	{
		ConvDetails di = new ConvDetails();

		di.setArtCodFlia((String) ht.get("cod_familia"+i));
		di.setArtCodClase((String) ht.get("cod_clase"+i));
		di.setArtCodArticulo((String) ht.get("cod_articulo"+i));
		di.setArticulo((String) ht.get("articulo"+i));
		di.setCantidad((String) ht.get("cantidad"+i));

		//di.setConsignacionSN(request.getParameter("consignacion"+i));
		lineNo++;
		if (lineNo < 10) key = "00"+lineNo;
		else if (lineNo < 100) key = "0"+lineNo;
		else key = ""+lineNo;
		System.out.println("delx... "+(String) ht.get("delx"+i));
		if(((String) ht.get("delx"+i))==null || ((String) ht.get("delx"+i)).equals(""))
		{
			System.out.println("..............................andrea");
			if (((String) ht.get("baction")).equalsIgnoreCase("Guardar"))
			{
				if (di.getCantidad() != null && !di.getCantidad().equals("") && !di.getCantidad().equals("0"))
				{
						try
						{
							ajuArt.put(key,di);
							ajuArtKey.put(di.getArtCodFlia()+"-"+di.getArtCodClase()+"-"+di.getArtCodArticulo(), key);
							item.getKBDetails().add(di);
							System.out.println("Adding item... "+key +"_"+di.getArtCodFlia()+"-"+di.getArtCodClase()+"-"+di.getArtCodArticulo());
						}
						catch (Exception e)
						{
							System.out.println("Unable to add item...");
						}
				}
			}//baction guardar
			 else
			 {
					try
					{
						ajuArt.put(key,di);
						ajuArtKey.put(di.getArtCodFlia()+"-"+di.getArtCodClase()+"-"+di.getArtCodArticulo(), key);
						item.getKBDetails().add(di);
						System.out.println("Adding item... "+key +"_"+di.getArtCodFlia()+"-"+di.getArtCodClase()+"-"+di.getArtCodArticulo());
					}
					catch (Exception e)
					{
						System.out.println("Unable to add item...");
					}
			}
		} else {
			dl = "1";
		}
	}
	id = item.getItemCode();
	if(!dl.equals("") || clearHT.equals("S")){
				response.sendRedirect("../inventario/articulo_config.jsp?mode="+mode+"&id="+id+"&codProveedorPrim="+codProveedorPrim+"&codProveedorSecu="+codProveedorSecu+"&change=1&type=2&fg="+fg);
		return;
	}
	System.out.println("...................................................................................baction="+(String) ht.get("baction"));
	if(((String) ht.get("baction"))!=null && ((String) ht.get("baction")).equals("Articulos Para Kit/Bandeja")){
		response.sendRedirect("../inventario/articulo_config.jsp?mode="+mode+"&id="+id+"&codProveedorPrim="+codProveedorPrim+"&codProveedorSecu="+codProveedorSecu+"&change=1&type=1&fg="+fg);
		return;
	}

 ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
 ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"fg="+fg+"&mode="+mode+"&wh="+wh);
	if (((String) ht.get("mode")).equalsIgnoreCase("add"))
	{
	 ItemMgr.add(item);
	 productId = item.getProductId(); //ItemMgr.getPkColValue("product_id");
	 id = item.getItemCode(); //ItemMgr.getPkColValue("cod_articulo");
	}else{
		 item.setItemCode((String) ht.get("id"));
		 item.setProductId((String) ht.get("productId"));
		//if(((String) ht.get("isAppropiation"))==null)item.setIsAppropiation((String) ht.get("consignacion"));
		//item.setPayTax(request.getParameter("itbm"));
		//item.setAddToInventory(request.getParameter("addInv"));
		//item.setReuse(request.getParameter("reuso"));
		// item.setIsSaleItem(request.getParameter("saleItem"));
			id = item.getItemCode();
				ItemMgr.update(item);
		 }
	 ConMgr.clearAppCtx(null);

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (ItemMgr.getErrCode().equals("1"))
{	session.removeAttribute("item");
	session.removeAttribute("ajuArt");
	session.removeAttribute("ajuArtKey");

%>
	alert('<%=ItemMgr.getErrMsg()%>');
<%
	if (fg.equalsIgnoreCase("CTRL")) {
%>
	window.opener.location.reload(true);
<%
	} else {
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/inventario/articulo_list.jsp?fg="+fg)) {
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/inventario/articulo_list.jsp")%>?fg=<%=fg%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/inventario/articulo_list.jsp?fg=<%=fg%>';
<%
		}
	}

if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
}
} else throw new Exception(ItemMgr.getErrMsg());
%>
}
function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&productId=<%=productId%>&id=<%=id%>&codBarra=<%=IBIZEscapeChars.forURL(codBarra)%>&printBC=<%=(((String) ht.get("printBC"))==null?"":((String) ht.get("printBC")))%>&qtyToPrint=<%=(((String) ht.get("qtyToPrint"))==null?"1":(String) ht.get("qtyToPrint"))%>&fg=<%=fg%><% if (fg.equalsIgnoreCase("CTRL")) { %>&wh=<%=wh%><% } %>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>