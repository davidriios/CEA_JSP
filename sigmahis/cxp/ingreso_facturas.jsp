<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr"/>
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vFac" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================
FORMA
INF800982						CLASIFICACION DE ORDENES DE PAGO
==================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);


ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String compania = request.getParameter("compania");
String documento = request.getParameter("documento");
String fecha = request.getParameter("fecha");
String num_orden_pago = request.getParameter("num_orden_pago");
String anio = request.getParameter("anio");
String cod_tipo_orden = request.getParameter("cod_tipo_orden");
String idBeneficiario = request.getParameter("idBeneficiario");
String tipoBenef = request.getParameter("tipoBenef");
String numFactura = request.getParameter("numFactura");
String tipo_orden = request.getParameter("tipo_orden");
String generadoPor = request.getParameter("generadoPor");

boolean viewMode = false;
int lineNo = 0;
CommonDataObject cdoDM = new CommonDataObject();

if (mode == null) mode = "add";
if (fp == null) fp = "sol_orden_pago";
if (fg == null) fg = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (compania == null) compania = "";
if (fecha == null) fecha = "";
if (documento == null) documento = "";
if (num_orden_pago == null) num_orden_pago = "";
if (anio == null) anio = "";
if (cod_tipo_orden == null) cod_tipo_orden = "";
if (numFactura == null) numFactura = "";
if (tipoBenef == null) tipoBenef = "";
if (tipo_orden == null) tipo_orden = "";
if (generadoPor == null) generadoPor = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(change==null){
		fact.clear();
		vFac.clear();
		if(!compania.equals("") && !fecha.equals("") && !documento.equals("") && fp.equals("sol_orden_pago")){
			sql = "select a.compania, a.documento, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.numero_factura, a.itbm, a.monto, a.cod_concepto, to_char(a.fecha_fact, 'dd/mm/yyyy') fecha_fact, a.usuario_creacion, b.descripcion from tbl_CXP_ORDEN_UNIDAD_FACT a, tbl_con_conceptos b where a.cod_concepto = b.codigo and a.compania = "+(String) session.getAttribute("_companyId")+" and a.documento = "+documento+" and fecha = to_date('"+fecha+"', 'dd/mm/yyyy')";
			alTPR = SQLMgr.getDataList(sql);
			fact.clear();
			for(int i=0;i<alTPR.size();i++){
				CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				try{
					fact.put(key, cdo);
				} catch (Exception e){
					System.out.println("Unable to add item...");
				}
			}
		} else if((fp.equals("orden_pago") && !num_orden_pago.equals("") && !anio.equals("")) || fp.equals("CXPHON") ){
			sql = "select a.cod_compania, a.anio, a.num_orden_pago, a.numero_factura, a.itbm, a.monto, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, to_char(a.fecha_fact, 'dd/mm/yyyy') fecha_fact, a.cod_concepto, b.descripcion concepto_desc ,'U' action, a.tipo_docto from tbl_cxp_orden_de_pago_fact a, tbl_con_conceptos b where a.cod_concepto = b.codigo and a.cod_compania = "+(String) session.getAttribute("_companyId");
			if(fp.equals("CXPHON"))sql += " and a.numero_factura='"+numFactura+"'";
			else sql += " and a.num_orden_pago = "+num_orden_pago+" and a.anio = "+anio;

			if (fg.equalsIgnoreCase("registro_orden_pago")) {
				sql = "select a.num_factura as numero_factura, to_char(a.fecha_creacion,'dd/mm/yyyy') as fecha_fact, a.monto_a_pagar as monto, 0 as itbm, (select cod_concepto from tbl_inv_recepcion_material where anio_recepcion = a.anio_recepcion and numero_documento = a.numero_documento and compania = a.rm_compania and numero_factura = a.num_factura and estado ='R') as cod_concepto, 'FAC' tipo_docto from tbl_cxp_detalle_orden_pago a where a.cod_compania = "+session.getAttribute("_companyId")+" and a.num_orden_pago = "+num_orden_pago+" and a.anio = "+anio;
			}
			alTPR = SQLMgr.getDataList(sql);
			fact.clear();
			for(int i=0;i<alTPR.size();i++){
				CommonDataObject cdo = (CommonDataObject) alTPR.get(i);
				lineNo++;
				if (lineNo < 10) key = "00"+lineNo;
				else if (lineNo < 100) key = "0"+lineNo;
				else key = ""+lineNo;
				try{
					fact.put(key, cdo);
				} catch (Exception e){
					System.out.println("Unable to add item...");
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
function doAction(){chkMontoTotal();}
function doSubmit(action){
	document.form.baction.value = action;
	if(!formValidation()){
		formBlockButtons(false);
		return false
	} else {
		document.form.submit();
	}
}

function chkSelected(){
	var size = document.form.keySize.value;
	var x = 0;
	for(i=0;i<size;i++){
		if(eval('document.form.chk'+i).checked==true) x++;
	}
	if(x==0) return false;
	else return true;
}

function chkMonto(){
	var size = document.form.keySize.value;
	var x = 0;
	var total = 0.00;
	for(i=0;i<size;i++){
		if(chkFactura(i,1)){x++;break;}
	if(isNaN(eval('document.form.monto'+i).value)||eval('document.form.monto'+i).value==''){x++;alert('Valor invalido en campo monto!');eval('document.form.monto'+i).select();break;return false;}
		if(!isNaN(eval('document.form.monto'+i).value)){total += parseFloat(eval('document.form.monto'+i).value);}else{ x++;alert('Valor invalido!');eval('document.form.monto'+i).select();break;return false;}
		if(!isNaN(eval('document.form.itbm'+i).value))total += parseFloat(eval('document.form.itbm'+i).value);
	}
	if(x==0){
	var total_odp = parseFloat(getDBData('<%=request.getContextPath()%>','monto','tbl_cxp_orden_de_pago','anio = <%=anio%> and num_orden_pago = <%=num_orden_pago%> and cod_compania = <%=(String) session.getAttribute("_companyId")%>',''));
	if(parseFloat(total_odp.toFixed(2)) < parseFloat(total.toFixed(2))) {
		alert('El Monto total de la(s) factura(s) es superior al de la orden de pago!.');
		return false;
	} else return true;
	}else return false;
}
function chkFactura(i,tp){
	var size = document.form.keySize.value;
	var x = 0;
	var total = 0.00;
	var factura = eval('document.form.numero_factura'+i).value;
	if(!isNaN(eval('document.form.monto'+i).value))total += parseFloat(eval('document.form.monto'+i).value);
	if(!isNaN(eval('document.form.itbm'+i).value))total += parseFloat(eval('document.form.itbm'+i).value);
	var saldo =0.00;
	if(tp==0)chkMontoTotal();

	//LA VALIDACION DE FACTURA 0 DEBE APLICARSE PARA TODOS LOS TIPOS DE ORDEN, CONSULTAR CON DEEPAK/JACINTO ANTES DE CAMBIAR
	if(factura.trim()==''||factura=='0'||factura=='00')return false;

<% if (cod_tipo_orden.equals("2")) { %>
if(tp==0){
	if(hasDBData('<%=request.getContextPath()%>','tbl_inv_recepcion_material rm, tbl_cxp_orden_de_pago op ','rm.compania = op.compania and rm.cod_proveedor = op.cod_provedor and op.compania = <%=session.getAttribute("_companyId")%> and op.anio = <%=anio%> and op.num_orden_pago = <%=num_orden_pago%> and rm.estado = \'R\' and rm.numero_factura = \''+factura+'\'','')){
		//if(saldo<total){
			saldo = parseFloat(getDBData('<%=request.getContextPath()%>','getSaldoFacturaProv(<%=(String) session.getAttribute("_companyId")%>, cod_provedor, \''+factura+'\', <%=anio%>, <%=num_orden_pago%>)','tbl_cxp_orden_de_pago','anio = <%=anio%> and num_orden_pago = <%=num_orden_pago%> and cod_compania = <%=(String) session.getAttribute("_companyId")%>',''));
			if(saldo<total){
				alert('El Monto Introducido es superior al del saldo de la Factura!.');
				eval('document.form.monto'+i).value=eval('document.form.monto_'+i).value;
				eval('document.form.itbm'+i).value=eval('document.form.itbm_'+i).value;
				return true;
			}
		//}
	}else{
		alert('Esta factura no existe para este proveedor!');
		eval('document.form.numero_factura'+i).value = eval('document.form.numero_factura_'+i).value;
		return true;
	}
  }//end tp.. 
<% } else if (cod_tipo_orden.equals("1") || (cod_tipo_orden.equals("3")&& generadoPor.trim().equals("HON"))) { %>

		var x = splitCols(getDBData('<%=request.getContextPath()%>','getsaldoFactHonDet(<%=session.getAttribute("_companyId")%>,\'<%=idBeneficiario%>\',\'<%=tipoBenef%>\',\''+factura+'\')','dual','',''));
		var _saldo = x[0];
		if(_saldo =='FNE' && <%=cod_tipo_orden%>==1){
			alert('No existe esta factura para este Beneficiario!');
			eval('document.form.numero_factura'+i).value='';
			return true;
		} else {
			saldo = parseFloat(_saldo);
			if(_saldo !='FNE')eval('document.form.fecha_fact'+i).value=x[1];
			//saldo=parseFloat(getDBData('<%=request.getContextPath()%>','getsaldoFactHon(<%=session.getAttribute("_companyId")%>,\'<%=idBeneficiario%>\',\'<%=tipoBenef%>\',\''+factura+'\')','dual','',''));

			if(saldo ==0){
				alert('La factura no tiene saldo. Favor Verifique!!! ');
				return true;
			}else if(saldo<total){
				alert('El Monto Introducido es superior al del saldo de la Factura!.');
				eval('document.form.monto'+i).value=eval('document.form.monto_'+i).value;
				eval('document.form.itbm'+i).value=eval('document.form.itbm_'+i).value;
				return true;
			}
		}

<% }  else if (cod_tipo_orden.equals("4")) { %>

			if(isNaN(total)) total = 0.00;
		var x = getDBData('<%=request.getContextPath()%>','chkHonReclamo(<%=session.getAttribute("_companyId")%>,\''+factura+'\',\'<%=idBeneficiario%>\',\'<%=tipo_orden%>\', '+total+')','dual','','');
		
		if(x!=''){
			eval('document.form.monto'+i).value=eval('document.form.monto_'+i).value;
			eval('document.form.itbm'+i).value=eval('document.form.itbm_'+i).value;
			eval('document.form.numero_factura'+i).value='';
			return true;
		}

	
<% } else { if (!cod_tipo_orden.equals("3")) {%>

		var c=splitCols(getDBData('<%=request.getContextPath()%>','to_char(a.fecha_creacion,\'dd/mm/yyyy\') as fecha_fact, (select cod_concepto from tbl_inv_recepcion_material where anio_recepcion = a.anio_recepcion and numero_documento = a.numero_documento and compania = a.rm_compania and numero_factura = a.num_factura and estado = \'R\') as cod_concepto','tbl_cxp_detalle_orden_pago a','a.cod_compania = <%=session.getAttribute("_companyId")%> and a.num_orden_pago = <%=num_orden_pago%> and a.anio = <%=anio%> and a.num_factura =\''+factura+'\''));
		if(c!=null){
			eval('document.form.fecha_fact'+i).value=c[0];
			eval('document.form.cod_concepto'+i).value=c[1];
		}

<% }} %>
	return false;
}
function sel_facturas(){
	var codProveedor = document.form.idBeneficiario.value;
	var num_orden_pago = document.form.num_orden_pago.value;
	var anio = document.form.anio.value;
	var tipoBenef = document.form.tipoBenef.value;
	var cod_tipo_orden = document.form.cod_tipo_orden.value;
	var tipoBenef = document.form.tipoBenef.value;
	abrir_ventana1('../inventario/sel_recepcion.jsp?fp=orden_pago&fg=pago_sin_fact&index=&codProveedor='+codProveedor+'&num_orden_pago='+num_orden_pago+'&anioOp='+anio+'&tipoBenef='+tipoBenef+'&cod_tipo_orden='+cod_tipo_orden);
}
function chkMontoTotal(){
	var size = document.form.keySize.value;
	var x = 0;
	var total = 0.00;
	var totalItbm= 0.00;
	for(i=0;i<size;i++){ 
	 
		if(eval('document.form.monto'+i).value!='')if(!isNaN(eval('document.form.monto'+i).value)){total += parseFloat(eval('document.form.monto'+i).value);}
		if(eval('document.form.itbm'+i).value!='')if(!isNaN(eval('document.form.itbm'+i).value)){totalItbm += parseFloat(eval('document.form.itbm'+i).value);}
	}
	
	 document.form.totalDet.value=total.toFixed(2);
	 document.form.totalDetItbms.value=totalItbm.toFixed(2);
	 document.form.totalt.value= parseFloat(total.toFixed(2))+ parseFloat(totalItbm.toFixed(2)); 
	 return false;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("compania",""+compania)%>
<%=fb.hidden("documento",""+documento)%>
<%=fb.hidden("fecha",""+fecha)%>
<%=fb.hidden("num_orden_pago",num_orden_pago)%>
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("cod_tipo_orden",cod_tipo_orden)%>
<%=fb.hidden("idBeneficiario",idBeneficiario)%>
<%=fb.hidden("tipoBenef",tipoBenef)%>
<%=fb.hidden("numFactura",numFactura)%>
<%=fb.hidden("tipo_orden",tipo_orden)%>
<%=fb.hidden("generadoPor",generadoPor)%>
<%fb.appendJsValidation("if(document.form.baction.value=='Guardar' && !chkMonto()) error++;");%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
	<tr class="TextHeaderOver">
		<td width="12%">
			<table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
				<tr class="TextHeader02" height="21">
					<td align="center" colspan="<%=(!tipoBenef.equals("M")?6:5)%>" width="90%"><cellbytelabel>Ingreso de Conceptos de Facturas (MEF)</cellbytelabel></td>
					<td align="right" width="10%">
					<%if(fp.equals("orden_pago") && fg.equals("pago_sin_fact")){%>
					<%=fb.button("selFactura","FACTURAS",false,mode.equalsIgnoreCase("view"),"","","onClick=\"javascript:sel_facturas();\"")%><%}%>
					</td>
					<td align="right" width="10%">
					
					<%=fb.button("addClasic","Agregar",false,viewMode, "Text10", "", "onClick=\"javascript: doSubmit(this.value);\"")%>
					</td>
				</tr>
				<tr class="TextHeader02" height="21">
					<td align="center" width="10%"><cellbytelabel>Tipo Docto.</cellbytelabel></td>
					<td align="center" width="10%"><cellbytelabel>No. Docto.</cellbytelabel></td>
					<td align="center" width="15%"><cellbytelabel>Fecha Factura</cellbytelabel></td>
					<td align="center" width="35%"><cellbytelabel>Conceptos</cellbytelabel></td>
					<td align="center" width="10%"><cellbytelabel>Monto</cellbytelabel></td>
					<%if(!tipoBenef.equals("M")){%>
					<td align="center" width="10%"><cellbytelabel>ITBM</cellbytelabel></td>
					<%}%>
					<td align="center" width="15%">Observaci&oacute;n</td>
					<td align="center" width="5%">&nbsp;</td>
				</tr>
				<%
				System.out.println("size........................."+fact.size());
				if (fact.size() > 0) alTPR = CmnMgr.reverseRecords(fact);
				for (int i=0; i<fact.size(); i++){
					key = alTPR.get(i).toString();
					CommonDataObject cdo = (CommonDataObject) fact.get(key);

					String color = "", fecha_fact = "fecha_fact"+i, fecha_val = cdo.getColValue("fecha_fact");
					if (i%2 == 0) color = "TextRow02";
					else color = "TextRow01";
					boolean readonly = false;
		 // if(!cdo.getColValue("action").trim().equals("I"))readonly = true;
				%>
				<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
				<%=fb.hidden("monto_"+i,cdo.getColValue("monto"))%>
				<%=fb.hidden("itbm_"+i,cdo.getColValue("itbm"))%>
				<%=fb.hidden("numero_factura_"+i,cdo.getColValue("numero_factura"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
				<tr class="<%=color%>" align="center">
					<td><%=fb.select("tipo_docto"+i,"FAC=FACTURA,NC=NOTA CREDITO,ND=NOTA DEBITO",cdo.getColValue("tipo_docto"), false, false, 0, "", "", "", "", "")%></td>
					<td align="center"><%=fb.textBox("numero_factura"+i,cdo.getColValue("numero_factura"),true,false,((fg.equals("registro_orden_pago") && !cdo.getColValue("numero_factura").equals("")) || viewMode || readonly),20,"Text10",null,(fp.equalsIgnoreCase("orden_pago")?"onChange=\"javascript:chkFactura("+i+",0);\"":""))%></td>
					<td align="center">
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1"/>
					<jsp:param name="nameOfTBox1" value="<%=fecha_fact%>"/>
					<jsp:param name="valueOfTBox1" value="<%=fecha_val%>"/>
					<jsp:param name="fieldClass" value="Text10"/>
					<jsp:param name="buttonClass" value="Text10"/>
			 <jsp:param name="readonly" value="<%=(viewMode||readonly)?"y":"n"%>"/>
					</jsp:include>
					</td>
					<td align="center"><%=fb.select(ConMgr.getConnection(), "select codigo, codigo||' - '||descripcion from tbl_con_conceptos where estado = 'A'"+(tipoBenef.equals("M")?" and codigo = 3":""), "cod_concepto"+i, cdo.getColValue("cod_concepto"), false, viewMode, 0, "Text10", "", "")%></td>
					<td align="center"><%=fb.decBox("monto"+i,cdo.getColValue("monto"),false,false,(viewMode||readonly),10, 8.2,"Text10",null,"","Monto",false,(fp!=null && fp.equals("orden_pago")?"onChange=\"javascript:chkFactura("+i+",0);\"":""))%></td>
					<%if(!tipoBenef.equals("M")){%>
					<td align="center"><%=fb.decBox("itbm"+i,cdo.getColValue("itbm"),false,false,(viewMode||readonly),10, 8.2,"Text10",null,"","ITBM",false,(fp!=null
 && fp.equals("orden_pago")?"onChange=\"javascript:chkFactura("+i+",0);\"":""))%></td>
					<%} else {%><%=fb.hidden("itbm"+i,cdo.getColValue("itbm"))%><%}%>
					<td align="center"><%=fb.textBox("comentario"+i,cdo.getColValue("comentario"),false,false,false,20,"Text10",null,"")%></td>
					<td align="center"><%=fb.submit("del"+i,"X",false,(viewMode||readonly), "Text10", "", "onClick=\"javascript: doSubmit(this.value);\"")%></td>
				</tr>
				<%}%>
				<tr class="TextHeader02" height="21">
					<td colspan="4" align="right">Totales:</td> 
					<td align="center"><%=fb.decBox("totalDet","",false,false,true,10, 10.2,"Text10",null,"","Total Monto Detalle",false,"")%></td>
					<%if(!tipoBenef.equals("M")){%>
					<td align="center"><%=fb.decBox("totalDetItbms","",false,false,true,10, 10.2,"Text10",null,"","Total Itbm Detalle",false,"")%></td>
					<%}%>
					<td colspan="2"><%=fb.decBox("totalt","",false,false,true,10, 10.2,"Text10",null,"","Total + Itbm",false,"")%></td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="<%=(!tipoBenef.equals("M")?8:7)%>">
					<%=fb.button("save","Guardar",true,viewMode,"","","onClick=\"javascript: doSubmit(this.value);\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
else
{
	String dl = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	fact.clear();
	OrdPago.getFactDet().clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("del"+i)==null){
			cdo.addColValue("numero_factura", request.getParameter("numero_factura"+i));
			cdo.addColValue("fecha_fact", request.getParameter("fecha_fact"+i));
			cdo.addColValue("cod_concepto", request.getParameter("cod_concepto"+i));
			if(request.getParameter("monto"+i)!= null && !request.getParameter("monto"+i).equals("")) cdo.addColValue("monto", request.getParameter("monto"+i));
			if(request.getParameter("itbm"+i)!= null && !request.getParameter("itbm"+i).equals(""))cdo.addColValue("itbm", request.getParameter("itbm"+i));

			cdo.addColValue("fecha", request.getParameter("fecha"));
			cdo.addColValue("documento", request.getParameter("documento"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));

			cdo.addColValue("usuario_creacion", request.getParameter("usuario_creacion"+i));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("action", request.getParameter("action"+i));
			if(request.getParameter("num_orden_pago")!= null && !request.getParameter("num_orden_pago").equals("")) cdo.addColValue("num_orden_pago", request.getParameter("num_orden_pago"));
			if(request.getParameter("tipo_docto"+i)!=null && !request.getParameter("tipo_docto"+i).equals("")) cdo.addColValue("tipo_docto",request.getParameter("tipo_docto"+i));
			if(request.getParameter("anio")!= null && !request.getParameter("anio").equals("")) cdo.addColValue("anio", request.getParameter("anio"));
			if(request.getParameter("comentario"+i)!= null && !request.getParameter("comentario"+i).equals("")) cdo.addColValue("comentario", request.getParameter("comentario"+i));

			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				fact.put(key, cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			alTPR.add(cdo);
		} else {
			dl = "1";
			if(request.getParameter("numero_factura"+i)!=null && !request.getParameter("numero_factura"+i).equals("")) vFac.remove(request.getParameter("numero_factura"+i));
		}
		OrdPago.setFactDet(alTPR);
	}

	if (request.getParameter("baction").equalsIgnoreCase("Agregar")){
		CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("numero_factura", "");
			cdo.addColValue("fecha_fact", CmnMgr.getCurrentDate("dd/mm/yyyy"));
			cdo.addColValue("cod_concepto", "");
			cdo.addColValue("monto_fact", "0");
			cdo.addColValue("itbm", "0");
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("action","I");
			cdo.addColValue("comentario","");
			lineNo++;
			if (lineNo < 10) key = "00"+lineNo;
			else if (lineNo < 100) key = "0"+lineNo;
			else key = ""+lineNo;
			try{
				fact.put(key, cdo);
			} catch (Exception e){
				System.out.println("Unable to add item...");
			}
			alTPR.add(cdo);
		response.sendRedirect("../cxp/ingreso_facturas.jsp?mode="+mode+"&change=1&type=2&fg="+fg+"&fp="+fp+"&compania="+compania+"&documento="+documento+"&fecha="+fecha+"&anio="+anio+"&num_orden_pago="+num_orden_pago+"&cod_tipo_orden="+cod_tipo_orden+"&idBeneficiario="+idBeneficiario+"&tipoBenef="+tipoBenef+"&tipo_orden="+tipo_orden+"&generadoPor="+generadoPor);
		return;
	}

	if (request.getParameter("baction").equalsIgnoreCase("X")){
		response.sendRedirect("../cxp/ingreso_facturas.jsp?mode="+mode+"&change=1&type=0&fg="+fg+"&fp="+fp+"&compania="+compania+"&documento="+documento+"&fecha="+fecha+"&anio="+anio+"&num_orden_pago="+num_orden_pago+"&cod_tipo_orden="+cod_tipo_orden+"&idBeneficiario="+idBeneficiario+"&tipoBenef="+tipoBenef+"&tipo_orden="+tipo_orden+"&generadoPor="+generadoPor);
		return;
	}

	if(request.getParameter("baction").equalsIgnoreCase("Guardar") && fp.equals("orden_pago")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"");
		OrdPagoMgr.addOPFact(alTPR);
		ConMgr.clearAppCtx(null);
	}
	%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<%if(fp.equals("orden_pago")){
	if (OrdPagoMgr.getErrCode().equals("1")){
	%>
		alert('<%=OrdPagoMgr.getErrMsg()%>');
	<%
	} else throw new Exception(OrdPagoMgr.getErrMsg());
}%>
	window.close();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
