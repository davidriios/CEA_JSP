<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CK" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ckDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ckDetKey" scope="session" class="java.util.Hashtable" />
<%
/**
==========================================================================================
FORMA CK_0001 Orden de pago
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
StringBuffer sbSql = new StringBuffer();
String key = "";
String mode = request.getParameter("mode");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String num_cheque = request.getParameter("num_cheque");
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;
String anio = request.getParameter("anio");
String num_orden_pago = request.getParameter("num_orden_pago");
String solicitadoPor = request.getParameter("solicitadoPor");
String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

if(fg==null) fg = "cxp";
if(fp==null) fp = "cxp";
if(anio==null) anio = "";
if(num_orden_pago==null) num_orden_pago = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	CK = new CommonDataObject();
	OrdPago = new OrdenPago();
	if (mode.equalsIgnoreCase("add")){
		ckDet.clear();
		ckDetKey.clear();
	} else {
		if (num_cheque == null && !fg.trim().equals("CSOP")) throw new Exception("Numero de cheque no es válido. Por favor intente nuevamente!");
		else if (num_orden_pago.trim().equals("") && fg.trim().equals("CSOP")) throw new Exception("Numero de Orden de Pago no es válido. Por favor intente nuevamente!");

		if (change==null){
			/*
			encabezado
			*/
			ckDet.clear();
			ckDetKey.clear();
			sbSql.append("select a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.tipo_pago, decode(a.tipo_pago,1,'Cheque',2,'ACH',3,'Transferencia',' ') as tipo_pago_desc, a.beneficiario, a.monto_girado, to_char(a.f_emision,'dd/mm/yyyy') as f_emision, a.estado_cheque, decode(a.estado_cheque,'G','Girado') as estado_desc, a.anio, a.num_orden_pago, b.nombre as nombre_banco, c.descripcion as nombre_cuenta, d.cod_tipo_orden_pago, d.tipo_orden, d.anio, a.usuario_creacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, nvl(to_char(a.f_anulacion,'dd/mm/yyyy'),'') as f_anulacion, a.observacion as descripcion_a from tbl_con_cheque a, tbl_con_banco b, tbl_con_cuenta_bancaria c, tbl_cxp_orden_de_pago d where a.cod_compania = b.compania and a.cod_banco = b.cod_banco and a.cod_compania = c.compania and a.cuenta_banco = c.cuenta_banco and a.anio = d.anio and a.num_orden_pago = d.num_orden_pago and a.cod_compania_odp = d.cod_compania and a.cod_compania = ");
			sbSql.append(session.getAttribute("_companyId"));
			if(!fg.trim().equals("CSOP")) {
				sbSql.append(" and a.num_cheque = '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(num_cheque));
				sbSql.append("' and a.cod_banco = '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(cod_banco));
				sbSql.append("' and a.cuenta_banco = '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(cuenta_banco));
				sbSql.append("'");
			} else {
				sbSql.append(" and a.num_orden_pago = ");
				sbSql.append(num_orden_pago);
				sbSql.append(" and a.anio = ");
				sbSql.append(anio);
			}
			CK = SQLMgr.getData(sbSql.toString());
			if(CK !=null){
				sbSql = new StringBuffer();
				sbSql.append("select compania, cod_banco, cuenta_banco, num_cheque, num_renglon, num_factura, monto_renglon, descripcion, cuenta1, cuenta2, cuenta3, cuenta4, cuenta5, cuenta6, cuenta1||'.'||cuenta2||'.'||cuenta3||'.'||cuenta4||'.'||cuenta5||'.'||cuenta6 as cuenta_financiera from tbl_con_detalle_cheque where compania = ");
				sbSql.append(session.getAttribute("_companyId"));
				sbSql.append(" and num_cheque = '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(CK.getColValue("num_cheque")));
				sbSql.append("' and cod_banco = '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(CK.getColValue("cod_banco")));
				sbSql.append("' and cuenta_banco = '");
				sbSql.append(IBIZEscapeChars.forSingleQuots(CK.getColValue("cuenta_banco")));
				sbSql.append("'");
				al = SQLMgr.getDataList(sbSql.toString());
			} else CK = new CommonDataObject();
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				if ((i+1) < 10) key = "00"+(i+1);
				else if ((i+1) < 100) key = "0"+(i+1);
				else key = ""+(i+1);

				try {
					ckDet.put(key, cdoDet);
					ckDetKey.put(cdoDet.getColValue("num_renglon"), key);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	session.setAttribute("CK",CK);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;
function doAction(){}
function doSubmit(value){window.document.cheque.action.value = value;window.frames['itemFrame'].doSubmit(value);}
function selOtros(){abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');}
function addFacturas(){abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=orden_pago');}
function chkDate(){var object = document.cheque.fecha_new_emision;var x = getDBData('<%=request.getContextPath()%>', '1','dual','to_date(\''+object.value+'\', \'dd/mm/yyyy\') >= trunc(sysdate)');if(x=='1'){CBMSG.warning('La fecha de emisión no puede anteceder la fecha actual!');object.value = '';} else null;}
function printCK(){	var cod_banco = document.cheque.cod_banco.value;var cuenta_banco = document.cheque.cuenta_banco.value;var cod_compania = '<%=(String) session.getAttribute("_companyId")%>';var fecha_emi = document.cheque.f_emision.value;var num_ck = document.cheque.num_cheque.value;abrir_ventana1('../cxp/print_cheque.jsp?fp=cheque&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&cod_compania='+cod_compania+'&num_ck='+num_ck+'&fecha_emi='+fecha_emi);}
function checkEstado(fg){var fecha = '';var oldFecha = '';
fecha = document.cheque.fecha_new_emision.value;
oldFecha = document.cheque.old_fecha_emision.value;

if(fecha!=oldFecha){
var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.cheque.fecha_new_emision.value='';return false;}else return true;
}else return true;
}

function checkEstadoAn(fg){var fecha = '';var oldFecha = '';
fecha = document.cheque.f_anulacion.value;
oldFecha = document.cheque.old_f_anulacion.value;

if(fecha!=oldFecha){
var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.cheque.f_anulacion.value='';return false;}else return true;
}else return true;
}
function chkDateAn(){var object = document.cheque.f_anulacion;var fechaEmi = document.cheque.fecha_new_emision;var x = getDBData('<%=request.getContextPath()%>', '1','dual','to_date(\''+object.value+'\', \'dd/mm/yyyy\') < to_date(\''+fechaEmi.value+'\', \'dd/mm/yyyy\')');if(x=='1'){CBMSG.warning('La fecha de Anulacion no puede ser menor a la fecha de emisión del cheque!');object.value = '';} else null;}
function verOrd (num_orden_pago, anio){abrir_ventana('../cxp/orden_pago.jsp?mode=view&num_orden_pago='+num_orden_pago+'&anio='+anio);}
function verFact(num_orden_pago, anio){abrir_ventana('../cxp/ingreso_facturas.jsp?fp=orden_pago&anio='+anio+'&num_orden_pago='+num_orden_pago+'&mode=view');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CHEQUES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<tr>
					<td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("cheque",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("saveOption","")%>
<%=fb.hidden("clearHT","")%>
<%=fb.hidden("action","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("solicitadoPor",solicitadoPor)%>
<%=fb.hidden("cod_tipo_orden_pago",CK.getColValue("cod_tipo_orden_pago"))%>
<%=fb.hidden("tipo_orden",CK.getColValue("tipo_orden"))%>
<%=fb.hidden("anio_op",CK.getColValue("anio"))%>
<%=fb.hidden("num_orden_pago",CK.getColValue("num_orden_pago"))%>
<%=fb.hidden("old_fecha_emision",CK.getColValue("f_emision"))%>
<%=fb.hidden("old_f_anulacion",CK.getColValue("f_anulacion"))%>
<%=fb.hidden("tipo_pago",CK.getColValue("tipo_pago"))%>
							<tr class="TextPanel">
								<td colspan="6"><cellbytelabel>Cheque</cellbytelabel></td>
							</tr>
							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>Banco</cellbytelabel></td>
								<td>
								<%=fb.textBox("cod_banco",CK.getColValue("cod_banco"),true,false,true,10,"text10",null,"")%>
								<%=fb.textBox("nombre_banco",CK.getColValue("nombre_banco"),true,false,true,50,"text10",null,"")%>
								</td>
								<td align="right"><cellbytelabel>Cuenta Financiera</cellbytelabel></td>
								<td>
								<%=fb.textBox("cuenta_banco",CK.getColValue("cuenta_banco"),true,false,true,10,"text10",null,"")%>
								<%=fb.textBox("nombre_cuenta",CK.getColValue("nombre_cuenta"),true,false,true,50,"text10",null,"")%>
								</td>
								<td align="right"><cellbytelabel>Estado</cellbytelabel></td>
								<td>
								<%if(mode.equals("edit") && fp.equalsIgnoreCase("cxp")){%>
								<%=fb.select("estado_cheque","G=Girado", CK.getColValue("estado_cheque"), false, false,0,"text10",null,"")%>
								<%} else if(mode.equals("edit") && fp.equalsIgnoreCase("conciliacion")){%>
								<%=fb.select("estado_cheque","G=Girado,A=Anulado", CK.getColValue("estado_cheque"), false, false,0,"text10",null,"")%>
								<%} else if(mode.equals("anular")){%>
								<%=fb.select("estado_cheque","G=Girado,A=Anulado", CK.getColValue("estado_cheque"), false, false,0,"text10",null,"onChange=\"javascript:if(this.value=='A') showPopWin('../cxp/reemplazar_cheque.jsp?cod_banco="+cod_banco+"&cuenta_banco="+cuenta_banco+"&num_cheque="+num_cheque+"&tipo_pago="+CK.getColValue("tipo_pago")+"',winWidth*.55,_contentHeight*.35,null,null,'');\"")%>
								<%}else{%>
				 <%=fb.select("estado_cheque","G=Girado,A=Anulado,P=Pagado", CK.getColValue("estado_cheque"), false, true,0,"text10",null,"")%>
				<%}%>
								</td>
							</tr>
							 <tr class="TextRow01">
								<td align="right"><cellbytelabel>Beneficiario</cellbytelabel></td>
								<td colspan="5"><%=fb.textBox("beneficiario",CK.getColValue("beneficiario"),false,false,true,50,"text10",null,"")%> </td>
				</tr>
				<tr class="TextRow01">
								<td align="right"><cellbytelabel>Orden de Pago</cellbytelabel></td>
								<td colspan="5"><%=fb.textBox("odp",CK.getColValue("anio")+" - "+CK.getColValue("num_orden_pago"),false,false,true,50,"text10",null,"")%>
				<%=fb.button("verOrden","Ver Orden",true,false,"","","onClick=\"javascript:verOrd("+CK.getColValue("num_orden_pago")+","+CK.getColValue("anio")+");\"")%>
				<%=fb.button("vFact","Ver Fact.",true,false,"","","onClick=\"javascript:verFact("+CK.getColValue("num_orden_pago")+","+CK.getColValue("anio")+");\"")%>
				</td>
				</tr>
							<tr class="TextRow01">
								<td align="right"><cellbytelabel>No. Cheque</cellbytelabel> <% if (!CK.getColValue("tipo_pago").equals("1")) { %>(<%=CK.getColValue("tipo_pago_desc")%>)<% } %></td>
								<td>
								<%if(mode.equals("edit") && fp.equals("cxp")){%>
								<%=fb.hidden("num_cheque",CK.getColValue("num_cheque"))%>
								<%=fb.textBox("num_new_ck",CK.getColValue("num_cheque"),true,false,false,12,"text10",null,"")%>
								<%}else if(mode.equals("anular") || (mode.equalsIgnoreCase("edit") && fp.equalsIgnoreCase("conciliacion")||fp.equalsIgnoreCase("modCheque"))||mode.equals("view")){%>
								<%=fb.textBox("num_cheque",CK.getColValue("num_cheque"),true,false,true,12,"text10",null,"")%>
								<%=fb.hidden("num_new_ck",CK.getColValue("num_cheque"))%>
								<%}%>
								</td>
								<td align="right"><cellbytelabel>Monto</cellbytelabel></td>
								<td><%=fb.textBox("monto_girado",CK.getColValue("monto_girado"),true,false,true,12,"text10",null,"")%> </td>
								<td align="right"><cellbytelabel>Fecha Emisi&oacute;n</cellbytelabel></td>
								<td>
				<%String checkEstado = "javascript:checkEstado(1);chkDate();newHeight();";%>
								<%if(mode.equals("edit")){%>
								<%=fb.hidden("f_emision",CK.getColValue("f_emision"))%>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha_new_emision" />
				<jsp:param name="readonly" value="<%=(fp.equalsIgnoreCase("conciliacion")?"y":"n")%>" />
								<jsp:param name="valueOfTBox1" value="<%=CK.getColValue("f_emision")%>" />
								<jsp:param name="jsEvent" value="<%=checkEstado%>" />
								<jsp:param name="onChange" value="<%=checkEstado%>" />
							</jsp:include>
								<%} else if(mode.equals("anular")){%>
								<%=fb.textBox("f_emision",CK.getColValue("f_emision"),true,false,true,12,"text10",null,"")%>
								<%//=fb.hidden("num_new_ck","")%>
								<%=fb.hidden("fecha_new_emision","")%>
								<%} else if(mode.equals("view")){%>
								<%=CK.getColValue("f_emision")%>
								<%} %>
								</td>
							</tr>
							<tr class="TextRow01" >
								<td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel>:</td>
								<td colspan="3"><%=fb.textarea("descripcion_a",CK.getColValue("descripcion_a"),false,false,viewMode,60,5,"text10",null,"")%> </td>
								<%if(mode.equals("edit") && fp.equalsIgnoreCase("cxp")){%>
								<td colspan="2">
								<%=fb.button("print_ck","Imprimir Cheque",false, viewMode,"","","onClick=\"javascript:printCK();\"")%>
								</td>
								<%} else if((mode.equals("edit") && fp.equalsIgnoreCase("conciliacion"))||mode.equals("view")){
				if((mode.equals("edit") && fp.equalsIgnoreCase("conciliacion") && CK.getColValue("f_anulacion").trim().equals(""))){ CK.addColValue("f_anulacion",fecha);}

				%>
								<td>
								<%
								if(mode.equals("edit") && fp.equalsIgnoreCase("conciliacion"))checkEstado = "javascript:checkEstadoAn(2);newHeight();chkDateAn();";
								else checkEstado = "javascript:checkEstadoAn(2);chkDate();chkDateAn();newHeight();";
								%>

								<cellbytelabel>Fecha Anulaci&oacute;n</cellbytelabel>:
								</td>
								<td>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="f_anulacion" />
				<jsp:param name="readonly" value="<%=(mode.equals("view")?"y":"n")%>" />
				<jsp:param name="jsEvent" value="<%=checkEstado%>" />
								<jsp:param name="onChange" value="<%=checkEstado%>" />
								<jsp:param name="valueOfTBox1" value="<%=CK.getColValue("f_anulacion")%>" />
							</jsp:include>
								</td>
								<%} else {%><td colspan="2">&nbsp;</td><%}%>
							</tr>
				<tr class="TextRow02" >
								<td colspan="3">Fecha Creacion: <%=CK.getColValue("fecha_creacion")%></td>
				<td colspan="3">Usuario Creacion: <%=CK.getColValue("usuario_creacion")%></td>
							</tr>
							<tr>
								<td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cxp/cheque_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&cod_banco=<%=cod_banco%>"></iframe></td>
							</tr>
						</table></td>
				</tr>
				<tr>
					<td colspan="6">&nbsp;</td>
				</tr>
		<%if(mode.equals("edit")&& fp.equalsIgnoreCase("conciliacion")){fb.appendJsValidation("if(/*!checkEstado(1)||*/!checkEstadoAn(2)){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");}%>
				<%=fb.formEnd(true)%>
				<!-- ================================   F O R M   E N D   H E R E   ================================ -->
			</table></td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
	session.removeAttribute("CK");
	session.removeAttribute("ckDet");
	session.removeAttribute("ckDetKey");
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	<%if(fp.equalsIgnoreCase("conciliacion")){
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/bancos/mov_banco_cheque_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/bancos/mov_banco_cheque_list.jsp")%>';
<%
		}else {%>
	window.opener.location = '<%=request.getContextPath()%>/bancos/mov_banco_cheque_list.jsp?banco=<%=request.getParameter("cod_banco")%>&cuenta=<%=request.getParameter("cuenta_banco")%>&nombre=<%=request.getParameter("nombre_banco")%>';
	<%}%>
	window.close();
	<%} else if(fp.equalsIgnoreCase("modCheque") ||fp.equalsIgnoreCase("cxp")){

	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/cxp/cheques_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/cxp/cheques_list.jsp")%>';
<%
		}else {%>
	window.opener.location = '<%=request.getContextPath()%>/cxp/cheques_list.jsp?fg=<%=fg%>&banco=<%=request.getParameter("cod_banco")%>&cuenta=<%=request.getParameter("cuenta_banco")%>&nombre=<%=request.getParameter("nombre_banco")%>&fg=<%=request.getParameter("fg")%>&solicitadoPor=<%=request.getParameter("solicitadoPor")%>';
	<%}%>
	<%}%>
	window.location = '<%=request.getContextPath()%>/cxp/cheque.jsp?mode=<%=(fp.equalsIgnoreCase("modCheque") || fp.equalsIgnoreCase("cxp"))?"view":mode%>&cod_banco=<%=request.getParameter("cod_banco")%>&cuenta_banco=<%=request.getParameter("cuenta_banco")%>&num_cheque=<%=request.getParameter("num_new_ck")%>&fp=<%=fp%>&fg=<%=fg%>';
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