<%//@ page errorPage="../error.jsp"%>
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
String sql = "", key = "";
String mode = request.getParameter("mode");
String cod_banco = request.getParameter("cod_banco");
String cuenta_banco = request.getParameter("cuenta_banco");
String num_cheque = request.getParameter("num_cheque")==null?"":request.getParameter("num_cheque").trim();
String change = request.getParameter("change");
String pac_id = request.getParameter("pac_id");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;
String anio = request.getParameter("anio");
String num_orden_pago = request.getParameter("num_orden_pago");

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
		if (num_cheque.equals("") && !fg.trim().equals("CSOP")) throw new Exception("Numero de cheque no es válido. Por favor intente nuevamente!");

		if (change==null){
			/*
			encabezado
			*/
			ckDet.clear();
			ckDetKey.clear();
			sql="select a.cod_compania, a.cod_banco, a.cuenta_banco, a.num_cheque, a.beneficiario, a.monto_girado, to_char(a.f_emision, 'dd/mm/yyyy') f_emision, a.estado_cheque, decode(a.estado_cheque, 'G', 'Girado') estado_desc, a.anio, a.num_orden_pago, b.nombre nombre_banco, c.descripcion nombre_cuenta, d.cod_tipo_orden_pago, d.tipo_orden, d.anio,a.usuario_creacion,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')as fecha_creacion,nvl(to_char(a.f_anulacion,'dd/mm/yyyy'),'') as f_anulacion, a.observacion as descripcion_a from tbl_con_cheque a, tbl_con_banco b, tbl_con_cuenta_bancaria c, tbl_cxp_orden_de_pago d where a.cod_compania = b.compania and a.cod_banco = b.cod_banco and a.cod_compania = c.compania and a.cuenta_banco = c.cuenta_banco and a.anio = d.anio and a.num_orden_pago = d.num_orden_pago and a.cod_compania_odp = d.cod_compania and a.cod_compania = " + (String) session.getAttribute("_companyId");			
			if(!fg.trim().equals("CSOP")) sql +=" and a.num_cheque = '"+num_cheque+"' and a.cod_banco = '"+cod_banco+"' and a.cuenta_banco = '"+cuenta_banco+"'";
			else sql +=" and a.num_orden_pago = '"+num_orden_pago+"' and a.anio = "+anio;
			CK = SQLMgr.getData(sql);
			if(CK !=null){
			sql="select compania, cod_banco, cuenta_banco, num_cheque, num_renglon, num_factura, monto_renglon, descripcion, cuenta1, cuenta2, cuenta3, cuenta4, cuenta5, cuenta6, cuenta1||'.'||cuenta2||'.'||cuenta3||'.'||cuenta4||'.'||cuenta5||'.'||cuenta6 cuenta_financiera, cuenta1||'-'||cuenta2||'-'||cuenta3||'-'||cuenta4||'-'||cuenta5||'-'||cuenta6||' - '||(select descripcion from tbl_con_catalogo_gral where cta1||'-'||cta2||'-'||cta3||'-'||cta4||'-'||cta5||'-'||cta6 = dc.cuenta1||'-'||dc.cuenta2||'-'||dc.cuenta3||'-'||dc.cuenta4||'-'||dc.cuenta5||'-'||dc.cuenta6 and compania= dc.compania) as descCta,'U' as action from tbl_con_detalle_cheque  dc where compania = " + (String) session.getAttribute("_companyId")+" and num_cheque = '"+CK.getColValue("num_cheque")+"' and cod_banco = '"+CK.getColValue("cod_banco")+"' and cuenta_banco = '"+CK.getColValue("cuenta_banco")+"'";
			al = SQLMgr.getDataList(sql);}else CK = new CommonDataObject();
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

function doAction(){
}

function doSubmit(value){
	window.document.cheque.action.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function selOtros(){
	abrir_ventana1('../common/search_pago_otro.jsp?fp=orden_pago');
}

function addFacturas(){
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=orden_pago');
}

function chkDate(){
	var object = document.cheque.fecha_new_emision;
	var x = getDBData('<%=request.getContextPath()%>', '1','dual','to_date(\''+object.value+'\', \'dd/mm/yyyy\') >= trunc(sysdate)');
	if(x!='1'){
		CBMSG.warning('La fecha de emisión no puede anteceder la fecha actual!');
		object.value = '';
	} else null;
}

function printCK(){
	var cod_banco = document.cheque.cod_banco.value;
	var cuenta_banco = document.cheque.cuenta_banco.value;
	var cod_compania = '<%=(String) session.getAttribute("_companyId")%>';
	var fecha_emi = document.cheque.f_emision.value;
	var num_ck = document.cheque.num_cheque.value;
	abrir_ventana1('../cxp/print_cheque.jsp?fp=cheque&cod_banco='+cod_banco+'&cuenta_banco='+cuenta_banco+'&cod_compania='+cod_compania+'&num_ck='+num_ck+'&fecha_emi='+fecha_emi);
}
function checkEstado(fg){var fecha = '';
if(fg=='1')fecha = document.cheque.fecha_new_emision.value;
else fecha = document.cheque.f_anulacion.value;
var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){if(fg=='1')document.cheque.fecha_new_emision.value='';else document.cheque.f_anulacion.value='';return false;}else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
						<%
						fb = new FormBean("cheque","","post");
						%>
              <%=fb.formStart(true)%> 
							<%=fb.hidden("mode",mode)%> 
							<%=fb.hidden("errCode","")%> 
							<%=fb.hidden("errMsg","")%> 
              <%=fb.hidden("saveOption","")%> 
							<%=fb.hidden("clearHT","")%> 
							<%=fb.hidden("action","")%> 
              <%=fb.hidden("fp",fp)%> 
              <%=fb.hidden("fg",fg)%> 
              <%=fb.hidden("cod_tipo_orden_pago",CK.getColValue("cod_tipo_orden_pago"))%> 
              <%=fb.hidden("tipo_orden",CK.getColValue("tipo_orden"))%> 
              <%=fb.hidden("anio_op",CK.getColValue("anio"))%> 
              <%=fb.hidden("num_orden_pago",CK.getColValue("num_orden_pago"))%> 
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
								<%=fb.select("estado_cheque","G=Girado,A=Anulado", CK.getColValue("estado_cheque"), false, false,0,"text10",null,"onChange=\"javascript:if(this.value=='A') showPopWin('../cxp/reemplazar_cheque.jsp?cod_banco="+cod_banco+"&cuenta_banco="+cuenta_banco+"&num_cheque="+num_cheque+"',winWidth*.55,_contentHeight*.35,null,null,'');\"")%>
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
                <td align="right"><cellbytelabel>No. Cheque</cellbytelabel></td>
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
                <jsp:param name="valueOfTBox1" value="<%=CK.getColValue("f_emision")%>" />
                <jsp:param name="jsEvent" value="<%=checkEstado%>" />
                <jsp:param name="onChange" value="<%=checkEstado%>" />
				<jsp:param name="readonly" value="y"/>
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
                <td colspan="3"><%=fb.textarea("descripcion_a",CK.getColValue("descripcion_a"),false,false,true,60,5,"text10",null,"")%> </td>
                <%if(mode.equals("edit") && fp.equalsIgnoreCase("cxp")){%>
                <td colspan="2">
                <%=fb.button("print_ck","Imprimir Cheque",false, viewMode,"","","onClick=\"javascript:printCK();\"")%>
                </td>
                <%} else if((mode.equals("edit") && fp.equalsIgnoreCase("conciliacion"))||mode.equals("view")){
				if((mode.equals("edit") && fp.equalsIgnoreCase("conciliacion") && CK.getColValue("f_anulacion").trim().equals(""))){ CK.addColValue("f_anulacion",fecha);}
				
				%>
                <td><%checkEstado = "javascript:checkEstado(2);chkDate();newHeight();";%>
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
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../cxp/cheque_config_det.jsp?change=<%=change%>&mode=<%=mode%>&fg=<%=fg%>&fp=<%=fp%>&cod_banco=<%=cod_banco%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
		<%if(mode.equals("edit")&& fp.equalsIgnoreCase("conciliacion")){fb.appendJsValidation("if(!checkEstado(1)||!checkEstado(2)){error++;CBMSG.warning('Revise Fecha de la Transaccion!');}");}%>
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
	
	window.location = '<%=request.getContextPath()%>/cxp/cheque_config.jsp?mode=<%=mode%>&cod_banco=<%=request.getParameter("cod_banco")%>&cuenta_banco=<%=request.getParameter("cuenta_banco")%>&num_cheque=<%=request.getParameter("num_cheque")%>&fp=<%=fp%>&fg=<%=fg%>';

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