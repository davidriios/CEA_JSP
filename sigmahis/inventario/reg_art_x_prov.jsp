<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="htArtProv" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="htArtProvKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="IMgr" scope="page" class="issi.inventory.ItemMgr"/>
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
IMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String product_id = request.getParameter("product_id");
String id ="";
String anio ="";
int ln = 0;
boolean viewMode = false;

if (mode == null) mode = "add";
if (fg == null) fg = "";
if (product_id == null||product_id.trim().equals("null")) product_id = "";

if (mode.equalsIgnoreCase("view")) viewMode = true;
CommonDataObject cdoT = new CommonDataObject();
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		htArtProv.clear();
		if(!product_id.trim().equals("")){
		sql = "select a.cod_provedor cod_proveedor, a.compania, a.cod_articulo, a.art_familia, a.art_clase, a.precio_articulo, a.cantidad_vendida, a.marca, a.referencia, a.casa_productora, a.pais, a.product_id,  tipo_proveedor , b.descripcion marca_desc, c.nombre_proveedor proveedor_desc,a.estado, a.cod_barra from tbl_inv_arti_prov a, tbl_inv_marca b, tbl_com_proveedor c where a.marca = b.marca_id and a.cod_provedor = c.cod_provedor and product_id = " + product_id;
		al = SQLMgr.getDataList(sql);
				System.out.println("Printing query.."+sql);
				}
		for(int i=0; i<al.size(); i++){
			CommonDataObject cdo = (CommonDataObject) al.get(i);
			try{
				cdo.setAction("U");
				cdo.setKey(i);

				htArtProv.put(cdo.getKey(),cdo);
				//System.out.println("Adding item...");
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{	calcTotales();
	//newHeight();
	//adjustHeight('itemFrame');
}

function calcTotales(a)
{
/*	var iCounter = 0;
	var size = parseInt(document.form1.keySize.value);
	var sal_bruto = 0.00, gasto_rep = 0.00;
	var t_sal_bruto = 0.00, t_gasto_rep = 0.00;
	for(i=0;i<size;i++){
		sal_bruto 				= eval('document.form1.sal_bruto'+i).value;
		gasto_rep 				= eval('document.form1.gasto_rep'+i).value;
		if(!isNaN(sal_bruto) && sal_bruto!='') t_sal_bruto += parseFloat(sal_bruto);
		if(!isNaN(gasto_rep) && gasto_rep!='') t_gasto_rep += parseFloat(gasto_rep);
	}
	document.form1.sal_bruto.value 				= t_sal_bruto.toFixed(2);
	document.form1.gasto_rep.value 				= t_gasto_rep.toFixed(2);
	if (iCounter > 0) return true;
	else return false;
*/}

function doSubmit(value)
{
	document.form3.baction.value = value;
	//alert(document.form1.productId.value);
	//alert(document.form1.product_id.value);
	document.form3.product_id.value = parent.document.form1.productId.value;
	document.form3.art_familia.value = parent.document.form1.familyCode.value;
	document.form3.art_clase.value = parent.document.form1.classCode.value;
	document.form3.cod_articulo.value = parent.document.form1.itemCode.value;
	if (!form3Validation()) return false;
	else document.form3.submit();
}

function setPerDetail(i){
/*	var periodo = eval('document.form1.periodo'+i).value;
	var x = getDBData('<%//=request.getContextPath()%>', 'descripcion, decode(quincena1, '+periodo+', \'PRIMERA\', \'SEGUNDA\')','tbl_pla_vac_parametro','quincena1 = '+periodo+' or quincena2 = '+periodo,'');
	var arr_cursor = new Array();
	if(x!=''){
		arr_cursor = splitCols(x);
		eval('document.form1.mes'+i).value	= arr_cursor[0];
		eval('document.form1.quincena'+i).value	= arr_cursor[1];
	}
*/}

function selMarca(index)
{
	abrir_ventana1('../inventario/list_marca.jsp?fp=art_prov&index='+index);
}

function selProveedor(index){
	abrir_ventana1('../common/sel_proveedor.jsp?fg=articulo&index='+index+'&articulo=<%=product_id%>');
}

//suppress submit on enter
$(document).on("keypress", "form", function(event) {
		return event.keyCode != 13;
});
$(function(){
		$(".cod_barra")
		.focus(function(){
			$(this).select();
		})
		.blur(function(){
			var _this = $(this);
			_this.select();
			var completeText = $.trim(_this.val());
			var i = _this.data('i');
			var type = _this.data('type');
			var newValue;
			if (completeText){
				newValue = getGS1BarcodeData('<%=request.getContextPath()%>',completeText, type)
				if(newValue){
					_this.val(newValue);
					_this.blur();
				}
			}
		});
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%//=fb.hidden("size",""+DI.size())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","C")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("product_id", product_id)%>
<%=fb.hidden("art_familia","")%>
<%=fb.hidden("art_clase","")%>
<%=fb.hidden("cod_articulo","")%>
<%fb.appendJsValidation("if(document.form3.baction.value!='Guardar')return true;");%>

<table width="100%" align="center">
<tr class="TextHeader" align="center">
	<td width="23%">Cod. Proveedor</td>
	<td width="5%">Precio</td>
	<td width="23%">Marca</td>
	<td width="7%">Referencia</td>
	<td width="8%">Casa Productora</td>
	<td width="7%">Pa&iacute;s</td>
	<td width="9%">Tipo Proveedor</td>
	<td width="15%">C&oacute;d.Barra</td>
	<td width="3%">
	<%=fb.submit("btnagregar","+",false,viewMode,"","","onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
	</td>
</tr>
<%
if (htArtProv.size() > 0) al = CmnMgr.reverseRecords(htArtProv);

for (int i=0; i<htArtProv.size(); i++)
{
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) htArtProv.get(key);

	String color = "";
	if (i%2 == 0) color = "TextRow02";
	else color = "TextRow01";
%>
<%=fb.hidden("remove"+i,"")%>
<%=fb.hidden("key"+i,cdo.getKey())%>
<%=fb.hidden("action"+i,cdo.getAction())%>
<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
<%if(cdo.getAction().trim().equals("D")){%>
<%=fb.hidden("cod_proveedor"+i,cdo.getColValue("cod_proveedor"))%>
<%}else{%>
<tr class="<%=color%>" align="center">
	<td><%=fb.intBox("cod_proveedor"+i,cdo.getColValue("cod_proveedor"),true,false,true,4,"Text10","","")%>
	<%=fb.textBox("proveedor_desc"+i,cdo.getColValue("proveedor_desc"),false,false,true,27,"Text10","","")%>
	<%=fb.button("addProv"+i,"...",true,false,"Text10",null,"onClick=\"javascript:selProveedor("+i+")\"")%></td>
	<td><%=fb.decBox("precio_articulo"+i,cdo.getColValue("precio_articulo"),true,false,viewMode,4,"12.10","Text10",null,"onFocus=\"this.select();\"","",false,"")%></td>
	<td><%=fb.intBox("marca"+i,cdo.getColValue("marca"),true,false,true,4,"Text10","","")%>
	<%=fb.textBox("marca_desc"+i,cdo.getColValue("marca_desc"),false,false,true,27,"Text10","","")%>
	<%=fb.button("addMarca"+i,"...",true,false,"Text10",null,"onClick=\"javascript:selMarca("+i+")\"")%></td>
	<td><%=fb.textBox("referencia"+i,cdo.getColValue("referencia"),false,false,false,8,"Text10","","")%></td>
	<td><%=fb.textBox("casa_productora"+i,cdo.getColValue("casa_productora"),false,false,false,8,"Text10","","")%></td>
	<td><%=fb.textBox("pais"+i,cdo.getColValue("pais"),false,false,false,10,"Text10","","")%></td>
	<td><%=fb.select("tipo_proveedor"+i,"1=Primario,2=Secundario",cdo.getColValue("tipo_proveedor"), false, false, 0, "Text10", "", "")%></td>
	<td>
		<%=fb.textBox("cod_barra"+i,cdo.getColValue("cod_barra"),false,false,false,25,100,"Text10 cod_barra","","","",false,"autocomplete='off' data-i="+i+" data-type='01'")%></td>
	<td><%=fb.submit("rem"+i,"X",false,(viewMode),"","","onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
<%}
}
%>
<tr class="TextRow02">
 <td colspan="9" align="right">&nbsp;</td>
</tr>
<tr class="TextRow02">
 <!-- <td colspan="8" align="right"><%//=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%></td>-->
</tr>
<%=fb.hidden("keySize",""+al.size())%>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{

	String dl = "", close = "true";
	String itemRemoved = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	ln = 0;
	htArtProv.clear();
	//htArtProvKey.clear();
	ArrayList alTV = new ArrayList();
	for (int i=0; i<keySize; i++){

			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion", "sysdate");
			cdo.addColValue("fecha_modificacion", "sysdate");
			cdo.addColValue("product_id", request.getParameter("product_id"));
			cdo.addColValue("art_familia", request.getParameter("art_familia"));
			cdo.addColValue("art_clase", request.getParameter("art_clase"));
			cdo.addColValue("cod_articulo", request.getParameter("cod_articulo"));
			cdo.addColValue("estado", request.getParameter("estado"+i));

if (request.getParameter("cod_barra"+i) != null && !request.getParameter("cod_barra"+i).equals("")) {
	cdo.addColValue("cod_barra", request.getParameter("cod_barra"+i));
}
if (request.getParameter("cod_proveedor"+i) != null && !request.getParameter("cod_proveedor"+i).equals("")) cdo.addColValue("cod_proveedor", request.getParameter("cod_proveedor"+i));
if (request.getParameter("proveedor_desc"+i) != null && !request.getParameter("proveedor_desc"+i).equals("")) cdo.addColValue("proveedor_desc", request.getParameter("proveedor_desc"+i));
if (request.getParameter("precio_articulo"+i) != null && !request.getParameter("precio_articulo"+i).equals("")) cdo.addColValue("precio_articulo", request.getParameter("precio_articulo"+i));
if (request.getParameter("marca"+i) != null && !request.getParameter("marca"+i).equals("")) cdo.addColValue("marca", request.getParameter("marca"+i));
if (request.getParameter("referencia"+i) != null && !request.getParameter("referencia"+i).equals("")) cdo.addColValue("referencia", request.getParameter("referencia"+i));
if (request.getParameter("casa_productora"+i) != null && !request.getParameter("casa_productora"+i).equals("")) cdo.addColValue("casa_productora", request.getParameter("casa_productora"+i));
if (request.getParameter("pais"+i) != null && !request.getParameter("pais"+i).equals("")) cdo.addColValue("pais", request.getParameter("pais"+i));

if (request.getParameter("tipo_proveedor"+i) != null && !request.getParameter("tipo_proveedor"+i).equals("")) cdo.addColValue("tipo_proveedor", request.getParameter("tipo_proveedor"+i));

if (request.getParameter("marca_desc"+i) != null && !request.getParameter("marca_desc"+i).equals("")) cdo.addColValue("marca_desc", request.getParameter("marca_desc"+i));
if (request.getParameter("proveedor_desc"+i) != null && !request.getParameter("proveedor_desc"+i).equals("")) cdo.addColValue("proveedor_desc", request.getParameter("proveedor_desc"+i));

		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");
			else cdo.setAction("D");
		}
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				htArtProv.put(cdo.getKey(),cdo);
				alTV.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}
	if (!itemRemoved.equals("")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+ "&change=1&type=2&product_id="+product_id);
		return;
	}
	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("+")){
		CommonDataObject cdo = new CommonDataObject();
		cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
		cdo.addColValue("product_id", request.getParameter("product_id"));
		cdo.setKey(htArtProv.size()+1);
		cdo.setAction("I");
		try{
			htArtProv.put(cdo.getKey(),cdo);
			//htArtProvKey.put(cdo.getColValue("secuencia"),key);
		} catch (Exception e){
			System.out.println("Unable to add item...");
		}
	}

	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("+")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+ "&change=1&type=2&product_id="+product_id);
		return;
	}
	System.out.println("baction="+request.getParameter("baction"));
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode);
	if(request.getParameter("baction").equalsIgnoreCase("Guardar")){
		IMgr.addArtProv(alTV);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%
	if(IMgr.getErrCode().equals("1")){
	%>
		alert('<%=IMgr.getErrMsg()%>');
		window.location = '<%=request.getContextPath()+request.getServletPath()%>?product_id=<%=request.getParameter("product_id")%>';
	<%
	} else throw new Exception(IMgr.getErrMsg());
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
