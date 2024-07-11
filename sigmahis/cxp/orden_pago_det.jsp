<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Vector"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr"/>
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector"/>
<jsp:useBean id="vFac" scope="session" class="java.util.Vector"/>
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

ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String num_orden_pago = request.getParameter("num_orden_pago");
String anio = request.getParameter("anio");
int lineNo = 0;
CommonDataObject cdoParam = new CommonDataObject();
boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add") && change == null) htCtas.clear();
	sql = "select nvl(get_sec_comp_param("+(String) session.getAttribute("_companyId")+",'CXP_SET_CTA_BENEF'),'N') as setCuenta from dual";
	cdoParam = SQLMgr.getData(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction(){<% if (type != null && type.equals("1")) { %>abrir_ventana1('../common/check_cuentas.jsp?fp=orden_pago&mode=<%=mode%>&num_orden_pago=<%=num_orden_pago%>');<% } else if (type != null && type.equals("2")) {%>setAccAll();<%} %>verValues();}

function doSubmit(){
	document.form1.baction.value=parent.document.orden_pago.baction.value;
	document.form1.saveOption.value=parent.document.orden_pago.saveOption.value;

	document.form1.num_orden_pago.value = parent.document.orden_pago.num_orden_pago.value;
	document.form1.anio.value = parent.document.orden_pago.anio.value;
	document.form1.fecha_solicitud.value = parent.document.orden_pago.fecha_solicitud.value;
	document.form1.estado.value = parent.document.orden_pago.estado.value;
	document.form1.cod_tipo_orden_pago.value = parent.document.orden_pago.cod_tipo_orden_pago.value;

	document.form1.cod_concepto.value = parent.document.orden_pago.cod_concepto.value;
	document.form1.tipo_orden.value = parent.document.orden_pago.tipo_orden.value;
	document.form1.tipo_orden_2.value = parent.document.orden_pago.tipo_orden_2.value;
	document.form1.cod_hacienda.value = parent.document.orden_pago.cod_hacienda.value;
	document.form1.cod_paciente.value = parent.document.orden_pago.cod_paciente.value;
	document.form1.num_id_beneficiario.value = parent.document.orden_pago.num_id_beneficiario.value;
	document.form1.nom_beneficiario.value = parent.document.orden_pago.nom_beneficiario.value;
	document.form1.tipo_persona.value = parent.document.orden_pago.tipo_persona.value;
	document.form1.ruc.value = parent.document.orden_pago.ruc.value;
	document.form1.dv.value = parent.document.orden_pago.dv.value;
	document.form1.beneficiario2.value = parent.document.orden_pago.beneficiario2.value;
	document.form1.monto.value = parent.document.orden_pago.monto.value;
	document.form1.cod_banco.value = parent.document.orden_pago.cod_banco.value;
	document.form1.cuenta_banco.value = parent.document.orden_pago.cuenta_banco.value;
	document.form1.nuevo.value = parent.document.orden_pago.nuevo.value;
	document.form1.observacion.value = parent.document.orden_pago.observacion.value;

	if (!form1Validation()){
		parent.orden_pagoBlockButtons(false);
		form1BlockButtons(false);
		return false;
	} else document.form1.submit();
}

function chkFactura(i,flag){
	var cod_tipo_orden_pago = parent.document.orden_pago.cod_tipo_orden_pago.value;
	var num_id_beneficiario = parent.document.orden_pago.num_id_beneficiario.value;
	var num_factura = eval('document.form1.num_factura'+i).value; 
	if(cod_tipo_orden_pago=='2'){
	 var y=0;
		var size=document.form1.keySize.value;
		 for(x=0;x<size;x++){
		 if(x != i)
		 { 
		  if(eval('document.form1.num_factura'+x).value == num_factura){
		  top.CBMSG.alert('La factura ya está agregada!');
		  eval('document.form1.num_factura'+i).value='';
		  eval('document.form1.num_factura'+i).focus();
		  y++;
		  break;
		  }
		 }
		 
		}
	 if(y==0){	
		var x = getDBData('<%=request.getContextPath()%>','to_char(rm.fecha_documento, \'dd/mm/yyyy\') || \' FACTURA \' || rm.numero_factura,	nvl(getSaldoFactProv(rm.compania,rm.cod_proveedor,rm.numero_factura,'+cod_tipo_orden_pago+'),0) saldo, rm.anio_recepcion, rm.numero_documento','tbl_inv_recepcion_material rm','rm.numero_factura = \''+num_factura+'\' and rm.compania= <%=session.getAttribute("_companyId")%> and rm.cod_proveedor = '+num_id_beneficiario+' and rm.estado!=\'A\'');
		if(x==''){
			top.CBMSG.alert('La Factura no existe ó no tiene saldo Pendiente!');
			eval('document.form1.num_factura'+i).value = '';
			eval('document.form1.descripcion'+i).value = '';
			eval('document.form1.monto_a_pagar'+i).value = '';
			eval('document.form1.anio_recepcion'+i).value = '';
			eval('document.form1.numero_documento'+i).value = '';
		} else {
			var data = splitCols(x);
			var saldo =parseFloat(eval('document.form1.monto_a_pagar'+i).value = data[1]);
			if(saldo>0){			
			eval('document.form1.descripcion'+i).value = data[0];
			eval('document.form1.monto_a_pagar'+i).value = data[1];
			eval('document.form1.anio_recepcion'+i).value = data[2];
			eval('document.form1.numero_documento'+i).value = data[3];
			<%//if(cdoParam.getColValue("setCuenta").equals("S") ) {%>setAcc(i);<%//}%>
			}else{top.CBMSG.alert('La Factura no tiene saldo Pendiente!');eval('document.form1.num_factura'+i).value = '';
			eval('document.form1.descripcion'+i).value = '';
			eval('document.form1.monto_a_pagar'+i).value = '';
			eval('document.form1.anio_recepcion'+i).value = '';
			eval('document.form1.numero_documento'+i).value = '';}
		}
	  }
	}
	else if(cod_tipo_orden_pago=='3')
	{
		if(num_factura.substring(0,1)=='R'||num_factura.substring(0,1)=='r')
		{ 
			if(!hasDBData('<%=request.getContextPath()%>','tbl_cja_transaccion_pago','recibo = \''+num_factura.substring(1)+'\' and compania = <%=session.getAttribute("_companyId")%> /* and rec_status !=\'I\'*/'))
			{
			CBMSG.warning('El Número de Recibo no existe!'); eval('document.form1.num_factura'+i).value='';eval('document.form1.monto_a_pagar'+i).value = '';
			}
			else
			{		
				
			var estado = getDBData('<%=request.getContextPath()%>','rec_status','tbl_cja_transaccion_pago','recibo = \''+num_factura.substring(1)+'\' and compania = <%=session.getAttribute("_companyId")%>');
						
 			if(estado == 'I')
			{
				top.CBMSG.alert('El recibo Está anulado .!');eval('document.form1.monto_a_pagar'+i).value = '';eval('document.form1.num_factura'+i).value='';
			}
			else
			{
			 var x=getDBData('<%=request.getContextPath()%>','nvl(getSaldoRecibo(\''+num_factura.substring(1)+'\',<%=session.getAttribute("_companyId")%>),0) saldo','dual','');
 	
			 if(parseFloat(x)==0){top.CBMSG.alert('El recibo no tiene Saldo. Verifique .!');eval('document.form1.num_factura'+i).value = '';eval('document.form1.monto_a_pagar'+i).value = '';}
			 else if(parseFloat(x) < parseFloat(eval('document.form1.monto_a_pagar'+i).value))
			 {
				top.CBMSG.alert('El monto a pagar es mayor que el saldo del recibo. Verifique .!');
				eval('document.form1.monto_a_pagar'+i).value = '';
			 }	
		    }
		  }		
		}		
	}
	if(flag =='FACT')verValues();
}
function selRecepcion(i){
	var codProveedor = parent.document.orden_pago.num_id_beneficiario.value;
	var top = parent.document.orden_pago.cod_tipo_orden_pago.value;
	var tipo = parent.document.orden_pago.tipo_orden.value;
	if(top == '1') tipo = 'M';
	else if(top == '2') tipo = 'PR';
	else if(top == '4') tipo = 'PM';

	abrir_ventana1('../inventario/sel_recepcion.jsp?fp=orden_pago&index='+i+'&codProveedor='+codProveedor+'&flag_tipo='+tipo);
}


function chkCeroValues(){
	var size=document.form1.keySize.value;
	var x=0;
	var monto=0.00;
	var cod_tipo_orden_pago = parent.document.orden_pago.cod_tipo_orden_pago.value;
	var tipo_orden = parent.document.orden_pago.tipo_orden.value;
	for(i=0;i<size;i++){
		if(cod_tipo_orden_pago=='3'&&(tipo_orden=='O'||tipo_orden=='P')&&eval('document.form1.num_factura'+i).value==''){
			top.CBMSG.alert('Introduzca el Numero de Factura!');
			eval('document.form1.num_factura'+i).focus();
			x++;
			break;
		}else if(eval('document.form1.monto_a_pagar'+i).value<=0){
			top.CBMSG.alert('El monto no puede ser menor o igual a 0!');
			eval('document.form1.monto_a_pagar'+i).focus();
			x++;
			break;
		}else{
		 monto+=parseFloat(eval('document.form1.monto_a_pagar'+i).value);
		}
	}
	if(x!=0)return false;
	parent.document.orden_pago.monto.value=monto.toFixed(2);
	return true;
}

function verValues(){
	var size = document.form1.keySize.value;
	var monto = 0.00;
	var cod_tipo_orden_pago = parent.document.orden_pago.cod_tipo_orden_pago.value;
	for(i=0;i<size;i++)
	{
		if(cod_tipo_orden_pago=='1' )
		{
			if(eval('document.form1.monto_a_pagar'+i).value!=0)
			{
			 monto += parseFloat(eval('document.form1.monto_a_pagar'+i).value);
			}
		}
		else
		{
			if(cod_tipo_orden_pago=='3' )
			{
				chkFactura(i,'');
			}
			 
			if(eval('document.form1.monto_a_pagar'+i).value >0)
			{
			 monto += parseFloat(eval('document.form1.monto_a_pagar'+i).value);
			} else if(eval('document.form1.monto_a_pagar'+i).value <0 && cod_tipo_orden_pago==4)
			{
			 monto += parseFloat(eval('document.form1.monto_a_pagar'+i).value);
			}
			
		}
	}
	parent.document.orden_pago.monto.value=monto.toFixed(2);
}

function chkCeroRegisters(doAlert){
	if(doAlert==undefined||doAlert==null)doAlert=true;
	var size = document.form1.keySize.value;
	if(size>0)return true;
	else{
		if(doAlert)top.CBMSG.alert('Seleccione al menos una Unidad!');
		document.form1.baction.value = '';
		return false;
	}
}
function setBenefAcc(){
if(parent.document.orden_pago.num_id_beneficiario.value.trim()==''){top.CBMSG.alert('Por favor seleccione el Beneficiario!');return false;}
document.form1.cta1.value=parent.document.orden_pago.cta1.value;
document.form1.cta2.value=parent.document.orden_pago.cta2.value;
document.form1.cta3.value=parent.document.orden_pago.cta3.value;
document.form1.cta4.value=parent.document.orden_pago.cta4.value;
document.form1.cta5.value=parent.document.orden_pago.cta5.value;
document.form1.cta6.value=parent.document.orden_pago.cta6.value;
document.form1.ctaDesc.value=parent.document.orden_pago.ctaDesc.value;
return true;
}
function searchAcc(k){abrir_ventana1('../common/check_cuentas.jsp?fp=orden_pago&index='+k);}
function setAcc(k){
<%//if(cdoParam.getColValue("setCuenta").equals("S") ) {%>
if(setBenefAcc()){ 
if(eval('document.form1.num_factura'+k).value.trim()!=''){
	if(eval('document.form1.cg_1_cta1'+k).value.trim()=='')eval('document.form1.cg_1_cta1'+k).value=document.form1.cta1.value;
	if(eval('document.form1.cg_1_cta2'+k).value.trim()=='')eval('document.form1.cg_1_cta2'+k).value=document.form1.cta2.value;
	if(eval('document.form1.cg_1_cta3'+k).value.trim()=='')eval('document.form1.cg_1_cta3'+k).value=document.form1.cta3.value;
	if(eval('document.form1.cg_1_cta4'+k).value.trim()=='')eval('document.form1.cg_1_cta4'+k).value=document.form1.cta4.value;
	if(eval('document.form1.cg_1_cta5'+k).value.trim()=='')eval('document.form1.cg_1_cta5'+k).value=document.form1.cta5.value;
	if(eval('document.form1.cg_1_cta6'+k).value.trim()=='')eval('document.form1.cg_1_cta6'+k).value=document.form1.cta6.value;
	if(eval('document.form1.cuenta_desc'+k).value.trim()=='')eval('document.form1.cuenta_desc'+k).value=document.form1.ctaDesc.value;}
}<%//}%>
}

function setAccAll(){	
	var size = document.form1.keySize.value;
	for (i=0;i<size;i++){
		setAcc(i);
	}
}

function sel_facturas(){
	var codProveedor = parent.document.orden_pago.num_id_beneficiario.value;
	var top = parent.document.orden_pago.cod_tipo_orden_pago.value;
	var tipo = parent.document.orden_pago.tipo_orden.value;
	if(top == '1') tipo = 'M';
	else if(top == '2') tipo = 'PR';
	else if(top == '4') tipo = 'PM';

	abrir_ventana1('../inventario/sel_recepcion.jsp?fp=orden_pago&index=&codProveedor='+codProveedor+'&flag_tipo='+tipo);
}

function replicaAll(){
	var size = document.form1.keySize.value;
	for (i=0;i<size;i++){
		if(eval('document.form1.cg_1_cta1'+i).value!='') document.getElementById('replica'+i).style.display='';
		else document.getElementById('replica'+i).style.display='none';
	}
}

function replica(x){
	var size = document.form1.keySize.value;
	for (i=x;i<size;i++){
		eval('document.form1.cg_1_cta1'+i).value = eval('document.form1.cg_1_cta1'+x).value;
		eval('document.form1.cg_1_cta2'+i).value = eval('document.form1.cg_1_cta2'+x).value;
		eval('document.form1.cg_1_cta3'+i).value = eval('document.form1.cg_1_cta3'+x).value;
		eval('document.form1.cg_1_cta4'+i).value = eval('document.form1.cg_1_cta4'+x).value;
		eval('document.form1.cg_1_cta5'+i).value = eval('document.form1.cg_1_cta5'+x).value;
		eval('document.form1.cg_1_cta6'+i).value = eval('document.form1.cg_1_cta6'+x).value;
		eval('document.form1.cuenta_desc'+i).value = eval('document.form1.cuenta_desc'+x).value;
	}
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" align="center" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("keySize",""+htCtas.size())%>

<%=fb.hidden("anio",anio)%>
<%=fb.hidden("num_orden_pago",num_orden_pago)%>
<%=fb.hidden("fecha_solicitud","")%>
<%=fb.hidden("estado","")%>
<%=fb.hidden("cod_concepto","")%>
<%=fb.hidden("cod_tipo_orden_pago","")%>
<%=fb.hidden("tipo_orden","")%>
<%=fb.hidden("tipo_orden_2","")%>
<%=fb.hidden("cod_hacienda","")%>
<%=fb.hidden("cod_paciente","")%>
<%=fb.hidden("num_id_beneficiario","")%>
<%=fb.hidden("nom_beneficiario","")%>
<%=fb.hidden("tipo_persona","")%>
<%=fb.hidden("ruc","")%>
<%=fb.hidden("dv","")%>
<%=fb.hidden("beneficiario2","")%>
<%=fb.hidden("monto","")%>
<%=fb.hidden("cod_banco","")%>
<%=fb.hidden("cuenta_banco","")%>
<%=fb.hidden("nuevo","S")%>
<%=fb.hidden("observacion","")%>
<%int colspan = 5;%>
<%fb.appendJsValidation("if(document.form1.baction.value!='Guardar'){if(document.form1.baction.value=='+'){if(!setBenefAcc()){error++;}else return true;}else return true;}");%>
<%fb.appendJsValidation("if(!chkCeroValues())error++;");%>
<%fb.appendJsValidation("if(!chkCeroRegisters())error++;");%>
<%=fb.hidden("cta1","")%>
<%=fb.hidden("cta2","")%>
<%=fb.hidden("cta3","")%>
<%=fb.hidden("cta4","")%>
<%=fb.hidden("cta5","")%>
<%=fb.hidden("cta6","")%>
<%=fb.hidden("ctaDesc","")%>
<!--<tr class="TextPanel">
	<td colspan="<%=colspan-2%>"><cellbytelabel>Detalle</cellbytelabel></td>
	<td colspan="2" align="right">
		<%//=fb.submit("addCuentas","Agregar Cuentas",false,viewMode,"","","onClick=\"javascript:setBAction(this.form.name,this.value);\"")%>
		<%//=fb.button("printOrder","Imprimir Orden Pago",false,mode.equalsIgnoreCase("add"),"","","onClick=\"javascript:parent._printOrder();\"")%>
	</td>
</tr>-->
<tr class="TextHeader">
	<td width="13%" align="center"><cellbytelabel>Fact./Rec</cellbytelabel>.<%=fb.button("selFactura","...",false,mode.equalsIgnoreCase("view"),"","","onClick=\"javascript:sel_facturas();\"")%></td>
	<td width="30%" align="center"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
	<td width="8%" align="center"><cellbytelabel>Monto</cellbytelabel></td>
	<td width="40%" align="center"><cellbytelabel>N&uacute;mero de Cuenta</cellbytelabel></td>
	<td width="6%" align="center">&nbsp;</td>
	<td width="3%" align="center"><%=fb.submit("addCuentas","+",false,viewMode,"","","onClick=\"javascript:setBAction(this.form.name,this.value);\"")%></td>
</tr>
<%
key = "";
if (htCtas.size() != 0) al = CmnMgr.reverseRecords(htCtas);
for (int i=0; i<htCtas.size(); i++) {
	key = al.get(i).toString();
	CommonDataObject cdo = (CommonDataObject) htCtas.get(key);

	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
<%=fb.hidden("anio_recepcion"+i,cdo.getColValue("anio_recepcion"))%>
<%=fb.hidden("numero_documento"+i,cdo.getColValue("numero_documento"))%>
<tr align="center" class="<%=color%>">
	<td><%=fb.textBox("num_factura"+i,cdo.getColValue("num_factura"),false,false,viewMode,15,22,"Text10",null,"onFocus=\"this.select();\" onChange=\"javascript:chkFactura("+i+",'FACT');\"")%><%=fb.button("buscaR"+i,"...",false,viewMode,"Text10","","onClick=\"javascript:selRecepcion("+i+")\"")%></td>
	<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,viewMode,50,"Text10",null,"onFocus=\"this.select();\"")%></td>
	<td><%=fb.decBox("monto_a_pagar"+i,cdo.getColValue("monto_a_pagar"),false,false,viewMode,9,8.2,"Text10",null,"onFocus=\"this.select();\" onChange=\"javascript:verValues();\"","Cantidad",false,"")%></td>
	<td><%=fb.textBox("cg_1_cta1"+i,cdo.getColValue("cg_1_cta1"),true,false,true,1,"Text10",null,null)%><%=fb.textBox("cg_1_cta2"+i,cdo.getColValue("cg_1_cta2"),true,false,true,1,"Text10",null,null)%><%=fb.textBox("cg_1_cta3"+i,cdo.getColValue("cg_1_cta3"),true,false,true,1,"Text10",null,null)%><%=fb.textBox("cg_1_cta4"+i,cdo.getColValue("cg_1_cta4"),true,false,true,1,"Text10",null,null)%><%=fb.textBox("cg_1_cta5"+i,cdo.getColValue("cg_1_cta5"),true,false,true,1,"Text10",null,null)%><%=fb.textBox("cg_1_cta6"+i,cdo.getColValue("cg_1_cta6"),true,false,true,1,"Text10",null,null)%><%=fb.textBox("cuenta_desc"+i,cdo.getColValue("cuenta_desc"),true,false,true,40,"Text10",null,null)%><%=fb.button("buscaCta"+i,"...",false,viewMode,"Text10","","onClick=\"javascript:searchAcc("+i+")\"")%></td>
	<td><label id="replica<%=i%>" style="display:none"><a href="javascript:replica(<%=i%>)">replicar</a></label></td>
	<td><%=fb.submit("del"+i,"X",false,viewMode,"Text10","","onClick=\"javascript:setBAction(this.form.name,this.value);\"")%></td>
</tr>
<% } %>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String baction = request.getParameter("baction");
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	String uAdmDel = "";
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;

	OP.addColValue("num_orden_pago", request.getParameter("num_orden_pago"));
	OP.addColValue("anio", request.getParameter("anio"));
	OP.addColValue("fecha_solicitud", request.getParameter("fecha_solicitud"));
	OP.addColValue("estado", request.getParameter("estado"));
	OP.addColValue("cheque_girado", "N");
	if(request.getParameter("cod_tipo_orden_pago").equals("1")){
		OP.addColValue("cod_medico", request.getParameter("num_id_beneficiario"));
	} else if(request.getParameter("cod_tipo_orden_pago").equals("2")){
		OP.addColValue("estado", "A");
		OP.addColValue("cod_provedor", request.getParameter("num_id_beneficiario"));
		OP.addColValue("fecha_aprobado","sysdate");
		OP.addColValue("user_aprobado", (String) session.getAttribute("_userName"));
	} else if(request.getParameter("cod_tipo_orden_pago").equals("4")){
		OP.addColValue("estado", "A");
	}
	if(request.getParameter("cod_concepto")!= null && !request.getParameter("cod_concepto").equals("")) OP.addColValue("cod_concepto", request.getParameter("cod_concepto"));
	OP.addColValue("cod_tipo_orden_pago", request.getParameter("cod_tipo_orden_pago"));
	OP.addColValue("tipo_orden", request.getParameter("tipo_orden"));
	if(request.getParameter("tipo_orden").equals("E")) OP.addColValue("cod_empresa", request.getParameter("num_id_beneficiario"));
	if(OP.getColValue("cod_tipo_orden_pago").equals("4")){
		OP.addColValue("tipo_orden", request.getParameter("tipo_orden_2"));
	}
	OP.addColValue("cod_hacienda", request.getParameter("cod_hacienda"));
	if(request.getParameter("cod_paciente")!= null && !request.getParameter("cod_paciente").equals("")) OP.addColValue("cod_paciente", request.getParameter("cod_paciente"));
	OP.addColValue("num_id_beneficiario", request.getParameter("num_id_beneficiario"));
	OP.addColValue("nom_beneficiario", request.getParameter("nom_beneficiario"));
	if(request.getParameter("beneficiario2")!= null && !request.getParameter("beneficiario2").equals("")) OP.addColValue("beneficiario2", request.getParameter("beneficiario2"));
	OP.addColValue("monto", request.getParameter("monto"));
	OP.addColValue("compania", (String) session.getAttribute("_companyId"));
	OP.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
	OP.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
	OP.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
	OP.addColValue("user_creacion", (String) session.getAttribute("_userName"));
	if(request.getParameter("cod_banco")!= null && !request.getParameter("cod_banco").equals("")) OP.addColValue("cod_banco", request.getParameter("cod_banco"));
	if(request.getParameter("cuenta_banco")!= null && !request.getParameter("cuenta_banco").equals("")) OP.addColValue("cuenta_banco", request.getParameter("cuenta_banco"));
	if(request.getParameter("ruc")!= null && !request.getParameter("ruc").equals("")) OP.addColValue("ruc", request.getParameter("ruc"));
	if(request.getParameter("dv")!= null && !request.getParameter("dv").equals("")) OP.addColValue("dv", request.getParameter("dv"));
	if(request.getParameter("tipo_persona")!= null && !request.getParameter("tipo_persona").equals("")) OP.addColValue("tipo_persona", request.getParameter("tipo_persona"));
	if(request.getParameter("observacion")!= null && !request.getParameter("observacion").equals("")) OP.addColValue("observacion", request.getParameter("observacion"));
	OP.addColValue("nuevo", request.getParameter("nuevo")); /*utilizado para identificar si el beneficiario fue seleccionado del listado o si fue escrito por el usuario.  En el caso de que el usuario Seleccione Tipo de Orden 3=Otros y Pago Otros O=Otros y el usuario haya introducido los valores se guardara en la tabla pagos_otros un nuevo registro con esta informacion*/
	OP.addColValue("hacer", "S");

	OP.addColValue("fecha_creacion","sysdate");
	OP.addColValue("fecha_modificacion","sysdate");

	htCtas.clear();
	vCtas.clear();
	vFac.clear();
	al = new ArrayList();
	for(int i=0;i<keySize;i++){
		CommonDataObject cdo = new CommonDataObject();
		if (request.getParameter("num_factura"+i)!=null && !request.getParameter("num_factura"+i).equals("") && !request.getParameter("num_factura"+i).equals("0") && vFac.contains(request.getParameter("num_factura"+i)))
		{
		cdo.addColValue("num_factura","");
		cdo.addColValue("monto_a_pagar","");
		}
		else{cdo.addColValue("num_factura",request.getParameter("num_factura"+i));
		cdo.addColValue("monto_a_pagar",request.getParameter("monto_a_pagar"+i));
		}
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		
		cdo.addColValue("cg_1_cta1",request.getParameter("cg_1_cta1"+i));
		cdo.addColValue("cg_1_cta2",request.getParameter("cg_1_cta2"+i));
		cdo.addColValue("cg_1_cta3",request.getParameter("cg_1_cta3"+i));
		cdo.addColValue("cg_1_cta4",request.getParameter("cg_1_cta4"+i));
		cdo.addColValue("cg_1_cta5",request.getParameter("cg_1_cta5"+i));
		cdo.addColValue("cg_1_cta6",request.getParameter("cg_1_cta6"+i));
		cdo.addColValue("descripcion_cuenta",request.getParameter("cuenta_desc"+i));
		cdo.addColValue("cuenta_desc",request.getParameter("cuenta_desc"+i));
		if(mode.equals("add")) cdo.addColValue("estado", "P");
		cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
		cdo.addColValue("cod_compania", (String) session.getAttribute("_companyId"));
		cdo.addColValue("cg_compania", (String) session.getAttribute("_companyId"));
		if(request.getParameter("observacion2"+i)!= null && !request.getParameter("observacion2"+i).equals("")) cdo.addColValue("observacion2", request.getParameter("observacion2"+i));
		if(request.getParameter("monto"+i)!= null && !request.getParameter("monto"+i).equals("")) cdo.addColValue("monto", request.getParameter("monto"+i));

		cdo.addColValue("fecha_creacion","sysdate");
		cdo.addColValue("fecha_modificacion","sysdate");
		cdo.addColValue("anio_recepcion",request.getParameter("anio_recepcion"+i));
		cdo.addColValue("numero_documento",request.getParameter("numero_documento"+i));
		cdo.addColValue("rm_compania",(String) session.getAttribute("_companyId"));

		cdo.setKey(htCtas.size());
		

		if(request.getParameter("del"+i)==null){
			try {
				htCtas.put(cdo.getKey(), cdo);
				String ctas = cdo.getColValue("cg_1_cta1")+"_"+cdo.getColValue("cg_1_cta2")+"_"+cdo.getColValue("cg_1_cta3")+"_"+cdo.getColValue("cg_1_cta4")+"_"+cdo.getColValue("cg_1_cta5")+"_"+cdo.getColValue("cg_1_cta6");
				vCtas.add(ctas);
				vFac.add(cdo.getColValue("num_factura"));
				al.add(cdo);
			} catch (Exception e) {
				System.out.println("Unable to addget item "+key);
			}
		} else {
			uAdmDel = "1";
		}
	}

	if(!uAdmDel.equals("") || clearHT.equals("S")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&num_orden_pago="+num_orden_pago+"&change=1&fg="+fg+"&fp="+fp);
		return;
	}

	if(baction.equalsIgnoreCase("Agregar Cuentas")) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&num_orden_pago="+num_orden_pago+"&change=1&type=1&fg="+fg);
		return;
	} else if(baction.equalsIgnoreCase("+")) {
		CommonDataObject cdo = new CommonDataObject();
		 
		cdo.setKey(htCtas.size());

		try { htCtas.put(cdo.getKey(),cdo); } catch(Exception e) { System.err.println(e.getMessage()); }

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode="+mode+"&num_orden_pago="+num_orden_pago+"&change=1&type=3&fg="+fg);
		return;
	} else if (baction.equalsIgnoreCase("Guardar")) {
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		if (mode.equalsIgnoreCase("add")) {

			CommonDataObject cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+session.getAttribute("_companyId")+",'CXP_OP_CONTA_UA'),'-') as ua from dual");
			if (cdo == null || cdo.getColValue("ua").equals("-")) throw new Exception("La Unidad Administrativa del departamento de CONTABILIDAD no está definida en los parámetros!");
			else OP.addColValue("cod_unidad_ejecutora",cdo.getColValue("ua"));

			OrdPago.setCdo(OP);
			OrdPago.setAlDet(al);
			OrdPagoMgr.addOP(OrdPago);
			num_orden_pago = OrdPagoMgr.getPkColValue("num_orden_pago");
		} //else {    ReqMgr.update(ReqDet);  }
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
	<%if (OrdPagoMgr.getErrCode().equals("1")){%>
			parent.document.orden_pago.errCode.value = <%=OrdPagoMgr.getErrCode()%>;
			parent.document.orden_pago.errMsg.value = '<%=OrdPagoMgr.getErrMsg()%>';
			parent.document.orden_pago.num_orden_pago.value = '<%=num_orden_pago%>';
			parent.document.orden_pago.submit();
	<%} else throw new Exception(OrdPagoMgr.getErrMsg());%>

}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>