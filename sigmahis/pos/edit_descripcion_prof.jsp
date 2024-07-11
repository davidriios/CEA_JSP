<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
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
String precio_app = request.getParameter("precio_app");
String precio_normal = request.getParameter("precio_normal");
String id_precio = request.getParameter("id_precio");
String codigo_almacen = request.getParameter("codigo_almacen");
String id_descuento = request.getParameter("id_descuento");
String tipo_descuento = request.getParameter("tipo_descuento");
String total_desc = request.getParameter("total_desc");
String gravable_perc = request.getParameter("gravable_perc");
String itbm = request.getParameter("itbm");
String tipo_art = request.getParameter("tipo_art");
String tipo_servicio = request.getParameter("tipo_servicio");
String cantidad = request.getParameter("cantidad");
String tipo_articulo = request.getParameter("tipo_articulo");
String afecta_inventario = request.getParameter("afecta_inventario");
String costo = request.getParameter("costo");
String cod_barra = request.getParameter("cod_barra");
String change_precio = request.getParameter("change_precio");
String touch = request.getParameter("touch") == null ? "" : request.getParameter("touch");
String useKeypad = request.getParameter("useKeypad") == null ? "" : request.getParameter("useKeypad");

codigo = codigo.replace("N@","").replace("I@","").replace("C@","");
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();

if(mode==null) mode="add";
if(fg==null) fg="";
if (change == null) change = "0";
if (type == null) type = "0";
if (change_precio == null) change_precio = "N";

String key = "";

if(request.getMethod().equalsIgnoreCase("GET")){

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
function doAction(){
null;
}

function doSubmit(valor){
	var descripcion = document.form1.descripcion.value;
	var new_descripcion = document.form1.new_descripcion.value;
	var new_precio = 0;
	if(document.form1.new_precio) new_precio = document.form1.new_precio.value;
	if(new_descripcion==descripcion) alert('La descripción del artículo no se modificó!');
	else {
		var flg = 'reem';
		var spn = document.form1.spn.value+'&descripcion='+$.URLEncode(new_descripcion)+'&touch=<%=touch%>&use_keypad=<%=useKeypad%>'<%if(change_precio.equalsIgnoreCase("S")){%>+'&change_precio=S&precio='+new_precio<%}%>;
		var txt = ajaxHandler('../pos/detail.jsp',spn+'&adding='+flg,'GET');
		$('#left',parent.document).html(txt);
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

<% if(touch.trim().equalsIgnoreCase("Y")){%>
<link rel="stylesheet" href="../css/styles_touch.css" type="text/css"/>
<%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
<link href="../js/jquery.keypad.css" rel="stylesheet">
<style>#inlineKeypad { width: 10em; }
input[type=radio] {
    display:none; 
    margin:10px;
}
</style>
<script src="../js/jquery.plugin.js"></script>
<script src="../js/jquery.keypad.js"></script>

<script>
$(document).ready(function(){
  <%if(useKeypad.trim().equalsIgnoreCase("Y")){%>
      var opts ={
        keypadOnly: false, 
        layout: [
        '1234567890-', 
        'qwertyuiop' + $.keypad.CLOSE, 
        'asdfghjkl' + $.keypad.CLEAR, 
        'zxcvbnm' + 
        $.keypad.SPACE_BAR + $.keypad.BACK]
      };
      $('#new_descripcion').keypad(opts);
      
      $(document).on('keyup',function(evt) {
        if (evt.keyCode == 27) {
           $('#new_descripcion').keypad("hide");
        }
      });
  <%}%>
});
</script>

<%}%>
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
<%=fb.hidden("descripcion", descripcion)%>
<%=fb.hidden("spn", "codigo="+codigo+"&cantidad="+cantidad+(change_precio.equalsIgnoreCase("N")?"&precio="+precio:"")+"&precio_app="+precio_app+"&precio_normal="+precio_normal+"&id_precio="+id_precio+"&id_descuento="+id_descuento+"&tipo_descuento="+tipo_descuento+"&total_desc="+total_desc+"&codigo_almacen="+codigo_almacen+"&gravable_perc="+gravable_perc+"&itbm="+itbm+"&tipo_art="+tipo_art+"&tipo_servicio="+tipo_servicio+"&tipo_articulo="+tipo_articulo+"&afecta_inventario="+afecta_inventario+"&costo="+costo+"&cod_barra="+cod_barra)%>
<%=fb.hidden("useKeypad",useKeypad)%>
<%=fb.hidden("touch",touch)%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
		<table align="center" width="100%" cellpadding="<%=touch.trim().equalsIgnoreCase("Y")?"7":"0"%>" cellspacing="1">
			<tr class="TextRow06">
				<td colspan="4" align="center">MODIFICAR DESCRIPCION DE ARTICULO: [<%=descripcion%>]</td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Nueva Descripci&oacute;n:</td>
				<td colspan="3"><%=fb.textBox("new_descripcion",descripcion/*issi.admin.IBIZEscapeChars.forURL()*/,true,false,false,50, 100)%></td>
			</tr>
			<%if(change_precio.equalsIgnoreCase("S")){%>
			<tr class="TextRow01">
				<td align="right">Nuevo Precio:</td>
				<td colspan="3"><%=fb.decBox("new_precio", precio, true, false, false, 4, 12.4, "text12", "", "", "", false, "", "")%></td>
			</tr>
			<%}%>
			<tr class="TextRow02">
				<td colspan="4" align="right">
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
