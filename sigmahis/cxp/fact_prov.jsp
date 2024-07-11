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
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htCtas" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCtas" scope="session" class="java.util.Vector" />
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable" />
<%
/**
==========================================================================================
FORMA OP_0001 Orden de pago
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
String numero_documento = request.getParameter("numero_documento");
String anio = request.getParameter("anio");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String appendFilter ="";
boolean viewMode = false;

String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");
if(anio == null) anio = CmnMgr.getCurrentDate("yyyy");
if(fg==null) fg = "fact_prov";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	OP = new CommonDataObject();
	OrdPago = new OrdenPago();
	if (mode.equalsIgnoreCase("add")){
		numero_documento = "0";
		OP.addColValue("fecha_sistema", fecha);
		OP.addColValue("fecha_documento", fecha);
		OP.addColValue("numero_documento", numero_documento);
		OP.addColValue("anio_recepcion", anio);
		OP.addColValue("comprobante","N");
		htCtas.clear();
		fact.clear();
		vCtas.clear();
		OrdPago.getAlDet().clear();
		session.removeAttribute("OP");
		session.removeAttribute("OrdPago");

	} else {
		if (numero_documento == null) throw new Exception("Requisición no es válida. Por favor intente nuevamente!");

		if (change==null){

		htCtas.clear();
		fact.clear();
		vCtas.clear();
		OrdPago.getAlDet().clear();
		session.removeAttribute("OP");
		//session.removeAttribute("OrdPago");
			/*
			encabezado
			*/
			sql="select to_char(a.fecha_sistema, 'dd/mm/yyyy') fecha_sistema, a.numero_documento, a.compania, a.anio_recepcion, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha_documento, a.numero_factura, a.monto_total, a.itbm, a.cod_proveedor, a.cod_concepto, a.explicacion, a.usuario_creacion, to_char(a.fecha_creacion, 'dd/mm/yyyy') fecha_creacion, a.estado, a.ref_cheque, a.correccion, b.nombre_proveedor desc_proveedor,nvl(a.comprobante,'N')comprobante from tbl_inv_recepcion_material a, tbl_com_proveedor b where a.cod_proveedor = b.cod_provedor and a.compania = "+(String) session.getAttribute("_companyId") + " and a.numero_documento = "+numero_documento+" and a.anio_recepcion = "+anio+" and tipo_factura='S' ";
			OP = SQLMgr.getData(sql);

			sql="select a.renglon, a.anio_recepcion, a.numero_documento, a.compania, a.monto, a.cg_1_cta1, a.cg_1_cta2, a.cg_1_cta3, a.cg_1_cta4, a.cg_1_cta5, a.cg_1_cta6, a.descripcion, b.descripcion descripcion_cuenta ,a.cg_1_cta1||'-'||a.cg_1_cta2||'-'||a.cg_1_cta3||'-'||a.cg_1_cta4||'-'||a.cg_1_cta5||'-'||a.cg_1_cta6||' - '||b.descripcion as descCta from tbl_adm_detalle_factura a, tbl_con_catalogo_gral b where a.compania = "+(String) session.getAttribute("_companyId") + " and a.numero_documento = "+numero_documento + " and a.anio_recepcion = " + anio + " and a.compania = b.compania and a.cg_1_cta1 = b.cta1 and a.cg_1_cta2 = b.cta2 and a.cg_1_cta3 = b.cta3 and a.cg_1_cta4 = b.cta4 and a.cg_1_cta5 = b.cta5 and a.cg_1_cta6 = b.cta6";
			al = SQLMgr.getDataList(sql);
			/*
			detalle
			*/
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				if ((i+1) < 10) key = "00"+(i+1);
				else if ((i+1) < 100) key = "0"+(i+1);
				else key = ""+(i+1);

				try {
					htCtas.put(key, cdoDet);
					String ctas = cdo.getColValue("cg_1_cta1")+"_"+cdo.getColValue("cg_1_cta2")+"_"+cdo.getColValue("cg_1_cta3")+"_"+cdo.getColValue("cg_1_cta4")+"_"+cdo.getColValue("cg_1_cta5")+"_"+cdo.getColValue("cg_1_cta6");
					vCtas.add(ctas);
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	}
	session.setAttribute("OP",OP);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Cuentas x Pagar- '+document.title;

function doAction(){
	calcSubTotal();
	//newHeight();
}

function doSubmit(valor){
	document.fact_prov.action.value = valor;
	document.fact_prov.clearHT.value = 'N';
	window.frames["itemFrame"]._doSubmit(valor);
}

function selOtros(){
	abrir_ventana1('../common/search_beneficiario.jsp?fp=fact_prov&flag_tipo=PR');
}

function setTrans(){
	if(document.fact_prov.chk_transf.checked){
		document.getElementById("_trans").style.display = '';
	} else {
		document.getElementById("_trans").style.display = 'none';
	}
}

function addFacturas(){
	var num_orden = document.fact_prov.numero_documento.value;
	var anio = document.fact_prov.anio.value;
	<%if(mode.equals("add")){%>
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=fact_prov');
	<%} else if(mode.equals("edit")){%>
	abrir_ventana1('../cxp/ingreso_facturas.jsp?fp=fact_prov&anio='+anio+'&numero_documento='+num_orden);
	<%}%>
}

function selCuentaBancaria(){
	var cod_banco = document.fact_prov.cod_banco.value;
	if(cod_banco=='') CBMSG.warning('Seleccione Banco!');
	else abrir_ventana1('../common/search_cuenta_bancaria.jsp?fp=fact_prov&cod_banco='+cod_banco);
}
function calcSubTotal(){
	var monto = document.fact_prov.monto_total.value;
	var itbm = document.fact_prov.itbm.value;
	if(isNaN(monto) || monto =='') null;
	else {
		if(isNaN(itbm) || itbm =='') null;
		else document.fact_prov.subtotal.value = (monto - itbm).toFixed(2);
	}
}
function chkFechaFact(){
	if(document.fact_prov.fecha_documento.value == '') {CBMSG.warning('Introduzca fecha de factura!');return false;} else return true;
}

function chkOrdenPago(){
	var cod_proveedor = document.fact_prov.cod_proveedor.value;
	var num_factura = document.fact_prov.numero_factura.value;
	var estado = document.fact_prov.estado.value;
	if(estado == 'A'){
		var x = getDBData('<%=request.getContextPath()%>','b.num_factura','tbl_cxp_orden_de_pago a, tbl_cxp_detalle_orden_pago b','a.cod_compania = <%=(String) session.getAttribute("_companyId")%> and a.num_id_beneficiario = \''+cod_proveedor+'\' and b.num_factura = \''+num_factura+'\' and a.cod_tipo_orden_pago = 2 and a.estado = \'A\' and a.cod_compania = b.cod_compania and a.anio = b.anio and a.num_orden_pago = b.num_orden_pago');
		if(x!=''){
			CBMSG.warning('Existe una orden de pago para este proveedor asignada a esta factura! para anular esta factura debe proceder a anular la orden de pago primero.');
			document.fact_prov.estado.value = 'R';
		}
	}
}

function checkFactura()
{
  var cod_prov=document.fact_prov.cod_proveedor.value;
 	var obj = document.fact_prov.numero_factura;
	if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_inv_recepcion_material','compania=<%=(String) session.getAttribute("_companyId")%> and cod_proveedor=\''+cod_prov+'\' and numero_factura=\''+obj.value+'\' and estado=\'R\' ',''))
  {
       obj.value = '';
       return true;
  } else return false;
}
function checkEstado(){var fecha = document.fact_prov.fecha_documento.value;var anio = fecha.substring(6,10);var mes = fecha.substring(3,5);var y=false;var x=false;if(anio!=''){  y=getEstadoAnio('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio);if(y==true)x=getEstadoMes('<%=request.getContextPath()%>',<%=session.getAttribute("_companyId")%>,anio,mes);}if(y==false||x==false){document.fact_prov.fecha_documento.value='';return false;}else return true;}
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
			<%fb = new FormBean("fact_prov","","post");%>
            <%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("errException","")%>
			<%=fb.hidden("clearHT","")%>
			<%=fb.hidden("action","")%>
            <%=fb.hidden("fg",fg)%>
            <%=fb.hidden("nuevo","S")%>
            <%//=fb.hidden("",OP.getColValue(""))%>

              <tr class="TextPanel">
                <td colspan="8"><cellbytelabel>FACTURA</cellbytelabel></td>
              </tr>
              <tr class="TextRow01" >
                <td align="right"><cellbytelabel>Registro No</cellbytelabel>.</td>
                <td>
								<%=fb.intBox("anio_recepcion",OP.getColValue("anio_recepcion"),true,false,true,6,"text10",null,"")%>
								<%=fb.intBox("numero_documento",OP.getColValue("numero_documento"),true,false,true,10,"text10",null,"")%>
                </td>
                <td align="right"><cellbytelabel>Estado</cellbytelabel></td>
                <td><%=fb.select("estado","R=RECIBIDO,A=ANULADO", OP.getColValue("estado"),false,viewMode,0,"text10",null,"onChange=\"javascript:chkOrdenPago();\"")%></td>
                <td align="right"><cellbytelabel>Fecha</cellbytelabel></td>
                <td><%=fb.textBox("fecha_sistema",OP.getColValue("fecha_sistema"),true,false,true,12,"text10",null,"")%> </td>
                <td align="right">&nbsp;<!--<cellbytelabel>Factura para</cellbytelabel>:--></td>
                <td><%=fb.hidden("correccion",OP.getColValue("correccion"))%>
				<%//=fb.select("correccion","O=OTROS,C=COMPROBANTE,E=ESTIMADAS", OP.getColValue("correccion"), false, viewMode,0,"text10",null,"")%></td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><cellbytelabel>Fecha Factura</cellbytelabel>:</td>
                <td><%String checkEstado = "javascript:checkEstado();newHeight();";%>
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha_documento" />
								<jsp:param name="valueOfTBox1" value="<%=OP.getColValue("fecha_documento")%>" />
								<jsp:param name="fieldClass" value="text10" />
								<jsp:param name="buttonClass" value="text10" />
								<jsp:param name="jsEvent" value="<%=checkEstado%>" />
								<jsp:param name="onChange" value="<%=checkEstado%>" />
								<jsp:param name="readonly" value="<%=(viewMode||OP.getColValue("comprobante").trim().equals("S"))?"y":"N"%>" />
								</jsp:include>
                &nbsp;&nbsp;
                </td>
                <td align="right"><cellbytelabel>N&uacute;mero Factura</cellbytelabel>:</td>
                <td><%=fb.textBox("numero_factura",OP.getColValue("numero_factura"),true,viewMode,false,12,22,"text10",null,"onBlur=\"javascript:checkFactura();\"")%></td>
                <td align="left" colspan="4">
                <cellbytelabel>Valor</cellbytelabel>:&nbsp;<%=fb.decBox("monto_total",OP.getColValue("monto_total"),true,false,(viewMode||OP.getColValue("comprobante").trim().equals("S")),10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcSubTotal();\"","Monto Total",false,"")%>
                &nbsp;<cellbytelabel>ITBMS</cellbytelabel>:&nbsp;<%=fb.decBox("itbm",OP.getColValue("itbm"),true,false,(viewMode||OP.getColValue("comprobante").trim().equals("S")),10, 8.2,"text10",null,"onFocus=\"this.select();\" onChange=\"javascript:calcSubTotal();\"","ITBM",false,"")%>
                &nbsp;<cellbytelabel>Subtotal</cellbytelabel>:&nbsp;<%=fb.decBox("subtotal",OP.getColValue("subtotal"),false,false,true,10, 8.2,"text10",null,"onFocus=\"this.select();\"","Sub-Total",false,"")%>
                </td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><cellbytelabel>Proveedor</cellbytelabel>:</td>
                <td colspan="5">
								<%=fb.textBox("cod_proveedor",OP.getColValue("cod_proveedor"),true,viewMode,true,20,"text10",null,"")%>
								<%=fb.textBox("desc_proveedor",OP.getColValue("desc_proveedor"),true,viewMode,true,80,"text10",null,"")%>
                <%=fb.button("buscar","...",false, (viewMode||OP.getColValue("comprobante").trim().equals("S")),"","","onClick=\"javascript:selOtros()\"")%>
                </td>
                <td align="right"><cellbytelabel>Cheque</cellbytelabel>:</td>
                <td>
								<%=fb.textBox("ref_cheque",OP.getColValue("ref_cheque"),false,viewMode,(OP.getColValue("ref_cheque")==null || OP.getColValue("ref_cheque").equals("")?false:true),12,"text10",null,"")%>
                </td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><cellbytelabel>Cod. Econ. y Fin</cellbytelabel>.</td>
                <td colspan="7">
								<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_con_conceptos order by codigo","cod_concepto",OP.getColValue("cod_concepto"),false,viewMode,0, "text10", "", "")%>
                &nbsp;&nbsp;
                </td>
              </tr>
              <tr class="TextRow01">
                <td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel>:</td>
                <td colspan="7">
								<%=fb.textarea("explicacion",OP.getColValue("explicacion"),false,false,viewMode,40,4)%>
                </td>
              </tr>
              <tr>
                <td colspan="8"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="99" scrolling="no" src="../cxp/fact_prov_det.jsp?change=<%=change%>&mode=<%=(OP.getColValue("comprobante").trim().equals("S"))?"view":mode%>&fg=<%=fg%>&fp=<%=fp%>&numero_documento=<%=numero_documento%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr class="TextRow02">
          <td colspan="6" align="right">
          <cellbytelabel>Opciones de Guardar</cellbytelabel>:
					<%=fb.radio("saveOption","N",false,false,false)%><cellbytelabel>Crear Otro </cellbytelabel>
					<%=fb.radio("saveOption","O",false,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
					<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>
					<%=fb.button("save","Guardar",true,((mode.equals("add") || mode.equals("edit")) && (OP.getColValue("ref_cheque")==null || OP.getColValue("ref_cheque").equals(""))?false:true),"","","onClick=\"javascript: doSubmit(this.value);\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
        <tr>
          <td colspan="8">&nbsp;</td>
        </tr>
				<%fb.appendJsValidation("\n\tif (!chkFechaFact()) error++;\n");%>
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

	numero_documento = request.getParameter("numero_documento");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
	String errException = request.getParameter("errException");
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function unload(){closeChild=false;}
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.opener.location = '<%=request.getContextPath()%>/cxp/fact_prov_list.jsp';
<%
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
} else throw new Exception(errException);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&tr=<%=tr%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=view&anio_recepcion=<%=request.getParameter("anio_recepcion")%>&numero_documento=<%=request.getParameter("numero_documento")%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
