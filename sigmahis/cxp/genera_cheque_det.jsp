<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr"/>
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="opDet" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="opDetKey" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable"/>
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
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String index = request.getParameter("index");
String num_orden_pago = request.getParameter("num_orden_pago");
String anio = request.getParameter("anio");
if(num_orden_pago==null) num_orden_pago = "";
if(anio==null) anio = "";
if(index==null) index = "0";

int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null) opDet.clear();
	if(!num_orden_pago.equals("") && !anio.equals("") && change == null){
		sql="select a.renglon, a.anio, a.num_orden_pago, a.cod_compania, a.num_factura, a.monto_a_pagar, a.cg_1_cta1, a.cg_1_cta2, a.cg_1_cta3, a.cg_1_cta4, a.cg_1_cta5, a.cg_1_cta6, a.descripcion, b.descripcion cuenta_desc from tbl_cxp_detalle_orden_pago a, tbl_con_catalogo_gral b where a.cod_compania = "+(String) session.getAttribute("_companyId") + " and a.num_orden_pago = "+num_orden_pago + " and a.anio = " + anio + " and a.cod_compania = b.compania and a.cg_1_cta1 = b.cta1 and a.cg_1_cta2 = b.cta2 and a.cg_1_cta3 = b.cta3 and a.cg_1_cta4 = b.cta4 and a.cg_1_cta5 = b.cta5 and a.cg_1_cta6 = b.cta6";
		al = SQLMgr.getDataList(sql);
		for(int i=0;i<al.size();i++){
			CommonDataObject cdoDet = (CommonDataObject) al.get(i);
			if ((i+1) < 10) key = "00"+(i+1);
			else if ((i+1) < 100) key = "0"+(i+1);
			else key = ""+(i+1);

			try {
				opDet.put(key, cdoDet);
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){
	<% if (type != null && type.equals("1")) { %>//abrir_ventana1('../common/check_unidad_adm.jsp?fp=orden_pago&mode=<%=mode%>&num_orden_pago=<%=num_orden_pago%>');<% } %>
	verValues();
}

function doSubmit(action){
	document.form1.baction.value 			= action;
	if(!form1Validation()){
		form1BlockButtons(false);
		return false
	} else {
		document.form1.submit();
	}
}

function setCuenta(i)
{
	abrir_ventana1('../common/check_cuentas.jsp?fp=orden_pago&index='+i);
}

function verValues(){
	var size = document.form1.keySize.value;
	var tipoOP = '';
	if(parent.document.orden_pago.cod_tipo_orden_pago<%=index%>)tipoOP=parseFloat(parent.document.orden_pago.cod_tipo_orden_pago<%=index%>.value);
	var monto = 0.00;
	for(i=0;i<size;i++){
		if(!isNaN(eval('document.form1.monto_a_pagar'+i).value)){
			if(tipoOP=='1' || tipoOP=='4'){
				monto += parseFloat(eval('document.form1.monto_a_pagar'+i).value);
			}else if(eval('document.form1.monto_a_pagar'+i).value>0){
				monto += parseFloat(eval('document.form1.monto_a_pagar'+i).value);
			}
		}else{
			alert('Introduzca valores numéricos');
			eval('document.form1.monto_a_pagar'+i).value=0;
		}
	}
	document.form1.monto_total.value = monto.toFixed(2) ;
}

function chkMonto(){
	var monto = document.form1.monto_total.value;
	var parentMonto = parseFloat(parent.document.orden_pago.monto<%=index%>.value);
	var baction = document.form1.baction.value;
		if((baction=="Guardar" || baction=="GeneraCK" || baction=="GeneraACH") && monto != parentMonto){
			alert('Valor del cheque Incorrecto!'+monto+'----'+parentMonto);
			return false;
		} else return true;
}

function chkCeroRegisters(){
	var size = document.form1.keySize.value;
	if(size>0) return true;
	else{
		if(document.form1.baction.value!='Guardar') return true;
		else {
			alert('Seleccione al menos una Cuenta!');
			document.form1.baction.value = '';
			return false;
		}
	}

}

function chkCeroValues(){
	var size = document.form1.keySize.value;
	var x = 0;
	var monto = 0.00;
	if(document.form1.baction.value=="Guardar"){
		for(i=0;i<size;i++){
		var tipoOP = parseFloat(parent.document.orden_pago.cod_tipo_orden_pago<%=index%>.value)
		if(tipoOP !='1'){
			if(eval('document.form1.monto_a_pagar'+i).value<=0){
				alert('El monto no puede ser menor o igual a 0!');
				eval('document.form1.monto_a_pagar'+i).focus();
				x++;
				break;
			} else{
			 monto += parseFloat(eval('document.form1.monto_a_pagar'+i).value);
			}
		}else{monto += parseFloat(eval('document.form1.monto_a_pagar'+i).value);}
		}
	}

	if(x==0) return true;
	else return false;
}

function chkCuentas(){
	var size = document.form1.keySize.value;
	var x = 0;
	if(document.form1.baction.value=="Guardar"){
		for(i=0;i<size;i++){
			if(eval('document.form1.cg_1_cta1'+i).value=='' || eval('document.form1.cg_1_cta2'+i).value=='' || eval('document.form1.cg_1_cta3'+i).value=='' || eval('document.form1.cg_1_cta4'+i).value=='' || eval('document.form1.cg_1_cta5'+i).value=='' || eval('document.form1.cg_1_cta6'+i).value==''){
				alert('Seleccione Cuenta!');
				eval('document.form1.monto_a_pagar'+i).focus();
				x++;
				break;
			}
		}
	}
	if(x==0) return true;
	else return false;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("num_orden_pago",num_orden_pago)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("keySize",""+opDet.size())%>
<tr class="TextPanel">
	<td colspan="6"><cellbytelabel>Detalle de la Orden de Pago</cellbytelabel></td>
	<td align="center" width="9%"><%=fb.button("addClasic","Agregar",false,viewMode, "text10", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
</tr>
<tr class="TextHeader">
	<td width="5%" align="center"><cellbytelabel>No</cellbytelabel>.</td>
	<td width="5%" align="center"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
	<td width="6%" align="center"><cellbytelabel>Fact./Rec</cellbytelabel>.</td>
	<td width="22%" align="center"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="50%" align="center"><cellbytelabel>N&uacute;mero de Cuenta</cellbytelabel></td>
	<td width="9%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
	<td width="3%" align="center">&nbsp;</td>
</tr>
<%
if (opDet.size() > 0) al = CmnMgr.reverseRecords(opDet);
for (int i=0; i<opDet.size(); i++) {
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) opDet.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("usuario_creacion"+i, cdo.getColValue("usuario_creacion"))%>
<tr class="<%=color%>">
	<td align="center"><%=fb.intBox("renglon"+i,cdo.getColValue("renglon"),false,false,true,3,"Text10",null,"")%></td>
	<td align="center"><%=fb.intBox("anio"+i,cdo.getColValue("anio"),false,false,(cdo.getColValue("renglon").equals("0")?false:true),4,"Text10",null,"")%></td>
	<td align="center"><%=fb.textBox("num_factura"+i,cdo.getColValue("num_factura"),false,false,(cdo.getColValue("renglon").equals("0")?false:true),10,"Text10",null,"")%></td>
	<td align="left"><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,false,30,"Text10",null,"")%></td>
	<td><%=fb.textBox("cg_1_cta1"+i,cdo.getColValue("cg_1_cta1"),false,false,true,3,"Text10",null,"")%><%=fb.textBox("cg_1_cta2"+i,cdo.getColValue("cg_1_cta2"),false,false,true,3,"Text10",null,"")%><%=fb.textBox("cg_1_cta3"+i,cdo.getColValue("cg_1_cta3"),false,false,true,3,"Text10",null,"")%><%=fb.textBox("cg_1_cta4"+i,cdo.getColValue("cg_1_cta4"),false,false,true,3,"Text10",null,"")%><%=fb.textBox("cg_1_cta5"+i,cdo.getColValue("cg_1_cta5"),false,false,true,3,"Text10",null,"")%><%=fb.textBox("cg_1_cta6"+i,cdo.getColValue("cg_1_cta6"),false,false,true,3,"Text10",null,"")%><%=fb.textBox("cuenta_desc"+i,cdo.getColValue("cuenta_desc"),false,false,true,30,"Text10",null,"")%><%=fb.button("cta"+i,"...",false,viewMode,"Text10","","onClick=\"javascript:setCuenta("+i+")\"")%></td>
	<td align="center"><%=fb.decBox("monto_a_pagar"+i,cdo.getColValue("monto_a_pagar"),true,false,viewMode,10,8.2,"Text10",null,"onFocus=\"this.select();\" onChange=\"javascript:verValues();\"","Cantidad",false,"")%></td>
	<td width="3%" align="center"><%=fb.submit("del"+i,"X",false,viewMode,"Text10","","onClick=\"javascript:doSubmit(this.value);\"")%></td>
</tr>
<% } %>
<tr class="TextRow01" >
	<td colspan="5" align="right">&nbsp;<cellbytelabel>Total del Cheque</cellbytelabel></td>
	<td align="center"><%=fb.decBox("monto_total","0",true,false,true,10,8.2,"Text10",null,"onFocus=\"this.select();\"","Cantidad",false,"")%></td>
	<td width="3%" align="center">&nbsp;</td>
</tr>
<tr class="TextRow02">
	<td colspan="7" align="right">
		<cellbytelabel>Opciones de Guardar</cellbytelabel>:
		<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%>
	</td>
</tr>
<%
fb.appendJsValidation("\n\tif (!chkMonto()) error++;\n");
fb.appendJsValidation("\n\tif (!chkCeroRegisters()) error++;\n");
fb.appendJsValidation("\n\tif (!chkCeroValues()) error++;\n");
fb.appendJsValidation("\n\tif (!chkCuentas()) error++;\n");
%>
<%=fb.formEnd(true)%>
</table>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
} else {
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	al.clear();
	opDet.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("del"+i)==null){
			cdo.addColValue("renglon", request.getParameter("renglon"+i));
			cdo.addColValue("anio", request.getParameter("anio"+i));
			cdo.addColValue("num_factura", request.getParameter("num_factura"+i));
			cdo.addColValue("descripcion", request.getParameter("descripcion"+i));
			cdo.addColValue("cg_1_cta1", request.getParameter("cg_1_cta1"+i));
			cdo.addColValue("cg_1_cta2", request.getParameter("cg_1_cta2"+i));
			cdo.addColValue("cg_1_cta3", request.getParameter("cg_1_cta3"+i));
			cdo.addColValue("cg_1_cta4", request.getParameter("cg_1_cta4"+i));
			cdo.addColValue("cg_1_cta5", request.getParameter("cg_1_cta5"+i));
			cdo.addColValue("cg_1_cta6", request.getParameter("cg_1_cta6"+i));
			cdo.addColValue("cuenta_desc", request.getParameter("cuenta_desc"+i));
			cdo.addColValue("monto_a_pagar", request.getParameter("monto_a_pagar"+i));

			cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
			cdo.addColValue("usuario_creacion", request.getParameter("usuario_creacion"+i));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));

			if(request.getParameter("num_orden_pago")!= null && !request.getParameter("num_orden_pago").equals("")) cdo.addColValue("num_orden_pago", request.getParameter("num_orden_pago"));
			if(request.getParameter("anio")!= null && !request.getParameter("anio").equals("")) cdo.addColValue("anio", request.getParameter("anio"));

			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				opDet.put(key, cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			al.add(cdo);
		}
	}
	String currAnio = CmnMgr.getCurrentDate("yyyy");
	if (request.getParameter("baction").equalsIgnoreCase("Agregar")){
		CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("renglon", "0");
			cdo.addColValue("anio", currAnio);
			cdo.addColValue("num_factura", "");
			cdo.addColValue("descripcion", "");
			cdo.addColValue("cg_1_cta1", "");
			cdo.addColValue("cg_1_cta2", "");
			cdo.addColValue("cg_1_cta3", "");
			cdo.addColValue("cg_1_cta4", "");
			cdo.addColValue("cg_1_cta5", "");
			cdo.addColValue("cg_1_cta6", "");
			cdo.addColValue("cuenta_desc", "");
			cdo.addColValue("monto_a_pagar", "0");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				opDet.put(key, cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			al.add(cdo);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&change=1&type=2&fg="+fg+"&fp="+fp+"&anio="+anio+"&num_orden_pago="+num_orden_pago+"&index="+index);
		return;
	}


	if (request.getParameter("baction").equalsIgnoreCase("X")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&change=1&type=0&fg="+fg+"&fp="+fp+"&anio="+anio+"&num_orden_pago="+num_orden_pago+"&index="+index);
		return;
	}
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
	if(request.getParameter("baction").equalsIgnoreCase("Guardar")){OrdPagoMgr.addOPDet(al);}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<%if (OrdPagoMgr.getErrCode().equals("1")){
	%>
		alert('<%=OrdPagoMgr.getErrMsg()%>');
	<%
	} else throw new Exception(OrdPagoMgr.getErrMsg());
	%>
	window.location='<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&anio=<%=anio%>&num_orden_pago=<%=num_orden_pago%>&index=<%=index%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>