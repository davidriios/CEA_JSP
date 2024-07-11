<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/* Check whether the user is logged in or not what access rights he has----------------------------
0         ACCESO TODO SISTEMA
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
SQLMgr.setConnection(ConMgr);
CmnMgr.setConnection(ConMgr);

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

String creatorId = UserDet.getUserEmpId();

String mode=request.getParameter("mode");
String change=request.getParameter("change");
String type=request.getParameter("type");
String compId=(String) session.getAttribute("_companyId");
String id = request.getParameter("id");
String fg = request.getParameter("fg");
String title = "";

String codigo = request.getParameter("codigo");
String descripcion = request.getParameter("descripcion");
String precio = request.getParameter("precio");
String cantidad = request.getParameter("cantidad");
String itbm = request.getParameter("itbm");
String gravable_perc = request.getParameter("gravable_perc");
String codigo_almacen = request.getParameter("codigo_almacen");
String tipo_articulo = request.getParameter("tipo_articulo");
String afecta_inventario = request.getParameter("afecta_inventario");
String costo = request.getParameter("costo");
String tipo_servicio = request.getParameter("tipo_servicio");
String cod_barra = request.getParameter("cod_barra");
String touch = request.getParameter("touch");
String val_desc = request.getParameter("val_desc");
codigo = codigo.replace("N@","").replace("I@","").replace("C@","");

codigo = codigo.replaceAll("@PA@","");
System.out.println("codigo.................................."+codigo);
CommonDataObject cdo = new CommonDataObject();
cdo.addColValue("valor", "0");
StringBuffer sbSql = new StringBuffer();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
//ArrayList alDesc = sbb.getBeanList(ConMgr.getConnection(),"select id as optValueColumn, codigo||'-'||descripcion as optLabelColumn, tipo||'|'||valor as optTitleColumn from tbl_par_descuento d where compania = "+(String) session.getAttribute("_companyId")+" and estado = 'A' and (exists (select null from tbl_par_descuento_det dd where d.compania = dd.compania and d.id = dd.id_descuento and dd.estado = 'A' and ((dd.codigo = "+codigo+" and dd.tipo_desc = 'A') or (dd.tipo_desc = 'F' and dd.codigo = (select a.cod_flia from tbl_inv_articulo a where a.compania = dd.compania and a.cod_articulo = "+codigo+")) or (dd.tipo_desc = 'C' and dd.codigo = "+codigo+"))) or d.aplica_todo_art = 'S') order by codigo||' - '||descripcion",CommonDataObject.class);

ArrayList alDesc = SQLMgr.getDataList("select id as optValueColumn, codigo||'-'||descripcion as optLabelColumn, tipo||'|'||valor||'|'||(case to_char(id) when get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'ID_TIPO_DESC_JUBIL') then 'J' when get_sec_comp_param("+(String) session.getAttribute("_companyId")+", 'ID_TIPO_DESC_EMPL') then 'E' else '' end) as optTitleColumn from tbl_par_descuento d where compania = "+(String) session.getAttribute("_companyId")+" and estado = 'A' and (exists (select null from tbl_par_descuento_det dd where d.compania = dd.compania and d.id = dd.id_descuento and dd.estado = 'A' and ((dd.codigo = "+codigo+" and dd.tipo_desc = 'A') or (dd.tipo_desc = 'F' and dd.codigo = (select a.cod_flia from tbl_inv_articulo a where a.compania = dd.compania and a.cod_articulo = "+codigo+")) or (dd.tipo_desc = 'C' and dd.codigo = "+codigo+"))) or d.aplica_todo_art = 'S') order by codigo||' - '||descripcion");
if(alDesc.size()==0) throw new Exception("A ESTE ARTICULO NO SE LE PUEDE APLICAR DESCUENTO!");
if(mode==null) mode="add";
if(fg==null) fg="";
if (change == null) change = "0";
if (type == null) type = "0";
if (touch == null) touch = "Y";

String key = "";

if(request.getMethod().equalsIgnoreCase("GET")){

CommonDataObject cdoP = SQLMgr.getData("select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'POS_USE_KEYPAD'),'N') use_keypad from dual ");
    if (cdoP == null) {
      cdoP = new CommonDataObject();
      cdoP.addColValue("use_keypad","N");
    }
    boolean useKeypad = cdoP.getColValue("use_keypad").equalsIgnoreCase("S") || cdoP.getColValue("use_keypad").equalsIgnoreCase("Y");

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>
<script language="javascript">
function doAction(){
//setDesc();
}

function setDesc(valor, titulo){
	var x = splitCols(titulo);
	setCheckedValue(document.form1.tipo, x[0]);
	document.form1.descuento.value=valor;
	if(x[1]==''){
		alert('El valor de tipo de descuento no está definido!');
	} else {
		var total = 0.00;
		var tipo_desc = x[2]||'';
		if(x[0]=='M') total = parseFloat(document.form1.precio.value)-parseFloat(x[1]);
		else if(x[0]=='P') total = parseFloat(document.form1.precio.value)*(parseFloat(x[1])/100);
		else if(x[0]=='R') total = parseFloat(document.form1.precio.value)*(parseFloat(x[1])/100);
		document.form1.valor.value = total.toFixed(4);
		document.form1.tipo_desc.value = tipo_desc;
		doSubmit('Aceptar');
	}
}

function roundNumber(s,n){
	var valor = document.form1.valor.value;
	var cantidad = document.form1.cantidad.value;
    var x = getDBData('<%=request.getContextPath()%>', 'round('+valor+' * '+cantidad+', '+n+')', 'dual',''); 
    return x;
}

function doSubmit(valor){
	var codigo = document.form1.codigo.value+'@D@';
	var precio = parseFloat(document.form1.valor.value);
	var _cantidad = parseFloat(document.form1._cantidad.value);
	var cantidad = parseFloat(document.form1.cantidad.value);
	if(precio>parseFloat(document.form1.precio.value)) CBMSG.alert('El precio con descuento es mayor al precio original!');
	else if(precio<0) CBMSG.alert('El descuento no puede ser menor a 0');
	else if(_cantidad < cantidad) {CBMSG.alert('La cantidad no puede ser mayor a la original!');document.form1.cantidad.value=_cantidad;}
	else {
		var descripcion = $.URLEncode(document.form1.descripcion.value);
		var cantidad = document.form1.cantidad.value;
		var itbm = document.form1.itbm.value;
		var gravable_perc = document.form1.gravable_perc.value;
		var codigo_almacen = document.form1.codigo_almacen.value;
		var id_descuento = document.form1.descuento.value;
		var tipo_articulo = document.form1.tipo_articulo.value;
		var afecta_inventario = document.form1.afecta_inventario.value;
		var tipo_servicio = document.form1.tipo_servicio.value;
		var cod_barra = document.form1.cod_barra.value;
		var val_desc = document.form1.val_desc.value;
		var tipo_desc = document.form1.tipo_desc.value;
		var costo = 0;//document.form1.costo.value;
		var tipo_descuento = getRadioButtonValue(document.form1.tipo);
		var total_desc2 = precio*cantidad;//getDBData('<%=request.getContextPath()%>', 'round('+precio+' * '+cantidad+', 2)', 'dual',''); 
		var total_desc = total_desc2.toFixed(2);//getDBData('<%=request.getContextPath()%>', 'round('+precio+' * '+cantidad+', 2)', 'dual',''); 
		var spn = 'codigo='+codigo+'&descripcion='+descripcion+'&cantidad='+cantidad+'&precio=-'+precio+'&itbm='+itbm+'&tipo_art=D&codigo_almacen='+codigo_almacen+'&id_descuento='+id_descuento+'&tipo_descuento='+tipo_descuento+'&total_desc='+total_desc+'&tipo_articulo='+tipo_articulo+'&afecta_inventario='+afecta_inventario+'&costo='+costo+'&tipo_servicio='+tipo_servicio+'&cod_barra='+cod_barra+'&total='+total_desc+'&gravable_perc='+gravable_perc+'&val_desc='+val_desc+'&tipo_desc='+tipo_desc+'&touch=<%=touch%>&use_keypad=<%=useKeypad?"Y":"N"%>';
		var flg = 'add';
		var txt = ajaxHandler('../pos/detail.jsp',spn+'&adding='+flg+'&show_desc=S','GET');
		//alert(spn);
		$('#left',parent.document).html(txt);
		parent.calcTotal();
		parent.hidePopWin(false);
	}
}

$.extend ({
URLEncode: function (s) {
s = encodeURIComponent (s);
s = s.replace (/\~/g, '%7E').replace (/\!/g, '%21').replace (/\(/g, '%28').replace (/\)/g, '%29').replace (/\'/g, '%27');
s = s.replace (/%20/g, '+');
return s;
},
URLDecode: function (s) {
s = s.replace (/\+/g, '%20');
s = decodeURIComponent (s);
return s;
}
});
</script>
<style>
.container { width: 100%;}
.copyright { margin-top: 50px; font-size: 12px; text-transform: uppercase; }
.copyright a { text-decoration: none; padding: 5px;background: #c0392b; color: #FFFFFF; }
.copyright a:hover { background: transparent; color: #c0392b; }

.button-container{
  display: table;
  float: left;
  height: 50px;
  width: 60px;
  margin-bottom: 7px;
  margin-right: 7px;
  overflow: hidden;
}

.button {
  padding-right: 10px;
  padding-left: 10px;
  background-color:rgb(41,127,184);
  color:rgb(255,255,255);
  text-transform: uppercase;
  display:table-cell;
  vertical-align:middle;
  border-radius: 5px;
  text-shadow:0px 1px 0px rgba(0,0,0,0.5);
  box-shadow:0px 2px 2px rgba(0,0,0,0.2);
}

.button span {
  position: absolute;
  left: 0;
  width: 50px;
  background-color:rgba(0,0,0,0.5);
  border-top-left-radius: 5px;
  border-bottom-left-radius: 5px;
  border-right: 1px solid  rgba(0,0,0,0.15);
}

.button:hover span, .button.active span {
  background-color:rgb(0,102,26);
  border-right: 1px solid  rgba(0,0,0,0.3);
}

.button:active {
  margin-top: 2px;
  margin-bottom: 13px;
  box-shadow:0px 1px 0px rgba(255,255,255,0.5);
}

.button.grey {
  background: #575757;
}

.button.purple {
  background: #8e44ad;
}

.button.turquoise {
  background: #1abc9c;
}

.button.red {
  background: #e74c3c;
}
</style>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<%if(useKeypad){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>
#inlineKeypad { width: 10em; }
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>
<script>
$(function () {
    //$.keypad.setDefaults({prompt: 'Please use the keypad',keypadOnly: false,layout: $.keypad.qwertyLayout});
    //$.keypad.setDefaults({prompt: 'Please use the keypad'});
	$('#cantidad').keypad();
    $('#valor').keypad();
	$('#inlineKeypad').keypad({onClose: function() {
	}});
});
</script>
<%}%>
</head>
<body bgcolor="#ffffff" topmargin="0" leftmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
    <jsp:param name="title" value=""></jsp:param>
</jsp:include>
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("id", cdo.getColValue("id"))%>
<%=fb.hidden("change", change)%>
<%=fb.hidden("baction", "")%>
<%=fb.hidden("fg", fg)%>
<%=fb.hidden("codigo", codigo)%>
<%=fb.hidden("descripcion", descripcion)%>
<%=fb.hidden("_cantidad", cantidad)%>
<%=fb.hidden("precio", precio)%>
<%=fb.hidden("itbm", itbm)%>
<%=fb.hidden("gravable_perc", gravable_perc)%>
<%=fb.hidden("codigo_almacen", codigo_almacen)%>
<%=fb.hidden("tipo_articulo", tipo_articulo)%>
<%=fb.hidden("afecta_inventario", afecta_inventario)%>
<%=fb.hidden("costo", costo)%>
<%=fb.hidden("tipo_servicio", tipo_servicio)%>
<%=fb.hidden("cod_barra", cod_barra)%>
<%=fb.hidden("touch", touch)%>
<%=fb.hidden("val_desc", val_desc)%>
<%=fb.hidden("tipo_desc", "")%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="8" cellspacing="1">
			<tr class="TextRow06">
				<td colspan="6" align="center">DESCUENTO POR ARTICULO: [<%=descripcion%>]</td>
			</tr>
			
			<tr align="center">
	<td colspan="6" class="TableBottomBorder">
		<table width="100%" align="center">
			<tr>
			<td>
			<div id="dvClassFlia" class="dvClassFlia">
			<%
			StringBuffer sbEvent = new StringBuffer();
			%>
				<%
				for (int i=0; i<alDesc.size(); i++){
					CommonDataObject fdo = (CommonDataObject) alDesc.get(i);
					sbEvent = new StringBuffer();
					sbEvent.append(" onClick=\"javascript:setDesc(");
					sbEvent.append(fdo.getColValue("optValueColumn"));
					sbEvent.append(", '");
					sbEvent.append(fdo.getColValue("optTitleColumn"));
					sbEvent.append("')\" style=\"cursor:pointer\"");
					System.out.println("descuento.........................."+fdo.getColValue("optLabelColumn"));
				%>
			<div class="button-container">
          <div class="button" <%=sbEvent%>>
            <%=(fdo.getColValue("optLabelColumn").length()>20) ? fdo.getColValue("optLabelColumn").substring(0,20):fdo.getColValue("optLabelColumn")%>
          </div>        
			</div>
				<%}%>
				</div>
</td>
</tr>
</table>
</td>
</tr>
			<%=fb.hidden("descuento", "")%>
			
			
			<tr class="TextRow01">
				<td align="right">Tipo:</td>
				<td>
				<label class="pointer"><%=fb.radio("tipo","M",true,false,false)%>&nbsp;Monto</label>
				<label class="pointer"><%=fb.radio("tipo","P",false,false,false)%>&nbsp;Porcentual</label>
				<label class="pointer"><%=fb.radio("tipo","R",false,false,false)%>&nbsp;Cantidad</label>
				</td>
				<td align="right">Cantidad:</td>
				<td><%=fb.decBox("cantidad", cantidad, true, false, false, 4, 12.4, "text12", "", "", "", false, "", "")%></td>
				<td align="right">Valor:</td>
				<td><%=fb.decBox("valor", cdo.getColValue("valor"), true, false, false, 4, 12.4, "text12", "", "", "", false, "", "")%></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="6" align="right">
				<%=fb.button("save","Aceptar",true,false,null,null,"onClick=\"javascript:doSubmit(this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false);\"")%>
				</td>
			</tr>
		</table>
		</td>
	</tr>
</table>
<%=fb.formEnd(true)%>
<%
%>
</body>
</html>
<%
}
%>
